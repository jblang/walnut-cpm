/*
cpm

CP/M emulator.
Written by D'Arcy J.M. Cain
darcy@druid

*/

#define		CPM_DATA

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<getopt.h>
#include	<ctype.h>
#include	<errno.h>
#include	<termio.h>
#include	<io.h>
#include	<signal.h>
#include	<time.h>
#include	<sys/stat.h>
#include	<sys/fcntl.h>
#include	"cpm.h"

#define		FILLER_SIZE	(16 - sizeof(FILE *))

#ifdef		DEBUG
#define		debug(x)	fprintf(stderr, "%s: %4d  %s\n", __FILE__, __LINE__, x)
#else
#define		debug(x)
#endif

typedef struct {
	byte	dr;			/* drive: 0 = default, 1 = A, 2 = B, etc. */
	char	name[8];	/* file name up to 8 characters */
	char	typ[3];		/* file type up to 3 characters */
	byte	ex, s1, s2, rc;
	FILE	*fp;		/* Unix file pointer */
	byte	filler[FILLER_SIZE];
	byte	cr, r0, r1, r2;
} FCB;

#ifdef		CPM_DEBUG
#define		dump_registers(output) \
	fprintf(output, reg_dump, A, BC, DE, HL, SP, PC,\
					SIGN ? 'S' : '-',\
					ZERO ? 'Z' : '-',\
					HALF_CARRY ? 'H' : '-',\
					PARITY ? 'P' : '-',\
					BCD ? 'N' : '-',\
					CARRY ? 'C' : '-',\
					ram[PC], dasm(ram + PC))

static int		dasm_flag = 0;
static char	*reg_dump =
	"A=%02.2x BC=%4.4x DE=%04.4x HL=%04.4x SP=%04.4x PC=%04.4x %c%c%c%c%c%c %02.2x %s\r\n";
#else
#define		dump_registers(output)
#endif


struct termio	old_term, termp;
static int		console, user_break;

#ifndef		COMPILE_TEST
static byte		*dma;
static char		*tail;
static int		out_delim = '$', def_drive = 1;
static FILE		*reader = NULL, *punch = NULL, *list = NULL;
#endif

/* clean up routine */
void	cleanup(int sig)
{
	if (sig == SIGINT)
	{
		user_break = 1;
		signal(SIGINT, cleanup);
		return;
	}

	ioctl(console, TCSETA, &old_term);
	printf("\nWe now return you to your regularly scheduled OS\n");
	exit(0);
}

/* How CP/M drives map to Unix: */
/* below is an array of 17 strings.  This corresponds to the allowable */
/* drive names in CP/M (A to P) plus the default drive which actually */
/* is a duplicate of one of the next 16.  At startup, The current Unix */
/* directory is copied into cpm_drive[1] and becomes drive A.  This may */
/* be modified by the startup sequence.  As well, the other drives may */
/* be set up to other directories.  At the end of the startup sequence */
/* the "strcpy(cpm_drive[0], cpm_drive[1]) causes drive A to be the CP/M */
/* default drive.  From that point on, a switch to a new drive involves */
/* simply copying that drive's directory into cpm_drive[0].  I did this */
/* in this way since I expect changing drives to occur less frequently */
/* than accessing files. */

static char		cpm_drive[17][128];

/* Convert string to upper case */
static void		strtoup(char *s)
{
	while (*s)
	{
		*s = toupper(*s);
		s++;
	}
}

#ifndef		COMPILE_TEST
/* take a string, terminate it at the first white space and return the
   string that follows.  I.E: "DIR *.COM" puts a 0 in the first space
   and returns a pointer to "*.COM".  Note that "DIR" returns a pointer
   to a NULL string - NOT a NULL pointer. */
static char	*chop_cmd(char *buf)
{
	char	*ptr = buf;

	/* discard leading space */
	while (isspace(*ptr))
		ptr++;

	/* quad left the string */
	strcpy(buf, ptr);

	/* terminate first word */
	ptr = buf;
	while (!isspace(*ptr) && *ptr)
		ptr++;

	/* is there more? */
	if (*ptr)
	{
		/* terminate first word */
		*ptr++ = 0;

		/* skip any leading space */
		while (isspace(*ptr))
			ptr++;

	}

	return(ptr);
}

/* given a drive unit (0 - 16) and a file name, returns Unix file name */
static char *mk_name(int dr, char *fname)
{
	static char	full_name[148];

	sprintf(full_name, "%s/%s", cpm_drive[dr], fname);

	if (strchr(fname, '.') == NULL)
		strcat(full_name, ".");

	return(full_name);
}

/* given a file spec in standard CP/M format returns Unix file name */
static char	*real_name(char *fname)
{
	/* does it include a drive letter? */
	if (fname[1] == ':')
		return(mk_name(*fname - '@', fname + 2));

	/* else use default drive */
	return(mk_name(0, fname));
}


/* given a pointer to an FCB, returns real file name */
char	*fcb2real(FCB *buf)
{
	char	temp[16], *p = temp;
	int		k = 0;

	for (k = 0; k < 8; k++)
		if (!isspace(buf->name[k]))
			*p++ = buf->name[k];

	*p++ = '.';

	for (k = 0; k < 3; k++)
		if (!isspace(buf->typ[k]))
			*p++ = buf->typ[k];

	*p = 0;
	return(mk_name(buf->dr, temp));
}

/* calls system command with CP/M file name converted to Unix */
static void		fsystem(const char *s, char *file)
{
	char	command[256];

	sprintf(command, s, real_name(file));
	ioctl(console, TCSETA, &old_term);
	system(command);
	ioctl(console, TCSETA, &termp);
}

/* formats a CP/M file name into an FCB */
static void	mk_fcb(FCB *buf, char *fname)
{
	char	*p = fname;
	int		k, l;

	/* clear FCB to start with */
	memset(buf, 0, 16);

	/* check for drive name */
	if (p[1] == ':')
	{
		debug("");
		buf->dr = *p - '@';
		p += 2;
	}

	k = l = 0;

	/* format primary name */
	for (k = 0; k < 8; k++)
	{
		debug("");

		if ((p[l] == '.') || (p[l] == 0))
		{
			debug("");

			while (k < 8)
			{
				debug("");
				buf->name[k++] = ' ';
			}
		}
		else if (p[l] == '*')
		{
			debug("");

			while (k < 8)
				buf->name[k++] = '?';

			debug("");
			while (p[l] && (p[l] != '.'))
				l++;

			debug("");
		}
		else
			buf->name[k] = p[l];

		debug("");
		l++;
	}

	debug("");

	/* format file type */
	for (k = 0; k < 3; k++)
	{
		debug("");
		if ((p[l] == '.') || (p[l] == 0))
			while (k < 3)
				buf->typ[k++] = ' ';
		else if (p[l] == '*')
			while (k < 3)
				buf->typ[k++] = '?';
		else
			buf->typ[k] = p[l];

		debug("");
		l++;
	}

	debug("");
	return;
}

/* add extension to file name.  replace current one if necessary */
static void	addext(char *s1, char *s2)
{
	char	*p;

	if ((p = strchr(s1, '.')) == NULL)
		strcat(s1, ".");

	strcat(s1, s2);
}
#endif

/* get a character from the terminal */
int		getch(void)
{
	byte	c = 0;
	int		ret_val;

	while ((ret_val = read(console, &c, 1)) != 1)
		if (ret_val == -1 && errno == EINTR)
			return(-1);

	return(c);
}

/* see if character waiting */
#define		kbhit()		ioctl(console, FIORDCHK, NULL)

/* get a string */
int		get_str(char *buffer, int maxlen)
{
	int		k = 0, c;

	/* break will interrupt input as if nothing entered */
	while ((c = getch()) != '\r' && c != '\n' && c != -1)
	{
		if (k == maxlen)
			c = '\a';
		else if (c == '\b')
		{
			if (k)
			{
				fprintf(stderr, "\b \b");
				k--;
			}
		}
		else
		{
			fputc(c, stdout);
			buffer[k++] = c;
		}

	}

	fprintf(stderr, "\r\n");
	return(c == -1 ? 0 : k);
}

#ifdef	CPM_DEBUG
#define		is_breakpoint(x)	breakpoint(0, (x))
#define		list_breakpoints()	breakpoint(0, 0)
#define		add_breakpoint(x)	breakpoint(1, (x))
#define		del_breakpoint(x)	breakpoint(2, (x))

int		breakpoint(int cmd, int bpoint)
{
	static int	bp[64];
	int			k;

	switch(cmd)
	{
		case 0:		/* set breakpoint if not 0 or print all */
			for (k = 0; k < 64; k++)
			{
				if (bp[k])
				{
					if (!bpoint)
						fprintf(stderr, "Breakpoint %2d: 0x%04.4x\r\n");
					else if (bp[k] == bpoint)
						return(1);
				}
			}

			return(0);
			break;

		case 1:		/* add breakpoint */
			/* check if already in table */
			for (k = 0; k < 64; k++)
				if (bp[k] == bpoint)
					return(k);

			/* else put it there if there is room */
			for (k = 0; k < 64; k++)
			{
				if (!bp[k])
				{
					bp[k] = bpoint;
					return(k);
				}
			}

			fprintf(stderr, "Too many breakpoints\r\n");
			return(-1);
			break;

		case 2:		/* delete a breakpoint */
			for (k = 0; k < 64; k++)
				if (bp[k] == bpoint)
					bp[k] = 0;

			return(0);
			break;
	}

	return(-1);
}

				
int		debugger()
{
	char	entry[128], *ptr;
	int		c;

	user_break = 0;

	for (;;)
	{
		fprintf(stderr, "\r\nDEBUG> ");
		ptr = entry;

		while ((c = getch()) != '\n')
		{
			if (c == -1)
				return(1);

			if ((*ptr = c) == '\b')
			{
				if (ptr > entry)
				{
					fprintf(stderr, "\b \b");
					ptr--;
				}
			}
			else
				fputc(*ptr++, stdout);
		}

		*ptr = 0;
		strtoup(entry);
		fprintf(stderr, "\r\n");

		if (!*entry)
			;
		else if (*entry == 'G')
			return(0);
		else if (*entry == 'Q')
			return(1);
		else if (*entry == 'R')
			dump_registers(stdout);
		else if (*entry == '+')
			add_breakpoint(atoi(entry + 1));
		else if (*entry == '-')
			del_breakpoint(atoi(entry + 1));
		else if (*entry == 'L')
			list_breakpoints();
		else if (isdigit(*entry))
			dasm_flag = *entry - '0';
		else if (*entry == '?')
		{
			printf("  G     Run from current PC\r\n");
			printf("  Q     Quit to command interpreter\r\n");
			printf("  R     Dump registers\r\n");
			printf("  +###  Add breakpoint at numberr\r\n");
			printf("  -###  Delete breakpoint at number\r\n");
			printf("  L     list current breakpoints\r\n");
			printf("  ###   Set debug level to number\r\n");
		}
		else
			fprintf(stderr, "\aUnknown command: %c\n", *entry);
	}
}
#endif

#ifndef	COMPILE_TEST
/* run a program */
static int	run(char *program)
{
	byte	*mem_ptr = ram + 0x100;
	char	*fn, fn2[128];
	int		c, k, pc;
	FILE	*fp;
	FCB		*fcb = NULL;
	long	f_pos;
	struct stat	s;

	debug("Start run function");

	/* find the program name */
	strcpy((char *)(mem_ptr), program);
	addext((char *)(mem_ptr), "COM");

	/* open the command file - return error if not found */
	if ((fp = fopen((char *)(mem_ptr), "rb")) == NULL)
		return(-1);

	debug("");

	/* load command into memory */
	while (fread(mem_ptr, 1, 0x100, fp))
	{
		if (mem_ptr > (ram + 0xf000))
		{
			fprintf(stderr, "\aCommand file too big\r\n");
			return(-2);
		}

		mem_ptr += 0x100;
	}

	fclose(fp);
	debug("");

	/* set up registers and page zero */
	PC = 0x100;
	SP = 0xfff0;

	/* following for test purposes */
	A = 1;
	BC = 0x2345;
	DE = 0x6789;
	HL = 0xabcd;

	debug("");
	strcpy((char *)(ram + 0x80), tail);
	debug("");
	mem_ptr = (byte *)(chop_cmd(tail));
	debug("");
	mk_fcb((FCB *)(ram + 0x5c), tail);
	debug("");
	mk_fcb((FCB *)(ram + 0x6c), (char *)(mem_ptr));
	debug("");
	memcpy(ram, page_zero, sizeof(page_zero));
	debug("");
	dma = ram + 0x80;
	debug("");

	debug("");

	/* BDOS, BIOS and default stack */
	for (k = 0xfc00; k < 0x10000; k++)
		ram[k] = 0;

	debug("");

	/* run program.  loop stops if PC = 0 - "JP 0" e.g. */
	while (PC)
	{

#ifdef	CPM_DEBUG
		if (dasm_flag > 1)
			dump_registers(stderr);

		if ((user_break && debugger()) || is_breakpoint(PC))
#else
		if (user_break)
#endif
		{
			fprintf(stderr, "\r\n\n\a* Program Interrupted by user *\r\n", ram[PC]);
			dump_registers(stderr);
			return(-5);
		}

		debug("");
		pc = PC;

		/* check if PC = BDOS entry point */
		if (PC == BDOS)
		{
			/* do CP/M service if so */
			switch (C)
			{
				case 0:						/* system reset */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: System reset\r\n");
#endif
					return(0);

				case 1:						/* conin */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Console in\r\n");
#endif

					if ((A = getch()) == -1)
						A = '*';

					fputc(A, stdout);
					break;

				case 2:						/* conout */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Console out (%c)\r\n", E >= ' ' ? E : '.');
#endif

					fputc(E, stdout);
					break;

				case 3:						/* RDR */ 
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reader in\r\n");
#endif

					if (reader != NULL)
						A = fgetc(reader);
					break;

				case 4:						/* PUN */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Punch out (%c)\r\n", E >= ' ' ? E : '.');
#endif

					if (punch != NULL)
						fputc(E, punch);
					break;

				case 5:						/* LST */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: List out (%c)\r\n", E >= ' ' ? E : '.');
#endif

					if (list != NULL)
						fputc(E, list);
					break;

				case 6:						/* CONIO */
#ifdef	CPM_DEBUG
					if (dasm_flag)
					{
						fprintf(stderr, "BDOS: Conio ");
						if (E == 0xff)
							fprintf(stderr, "in\r\n");
						else
							fprintf(stderr, "out (%c)\r\n", E >= ' ' ? E : '.');
					}
#endif

					if (E == 0xff)
						A = getch();
					else
						fputc(E, stdout);

					break;

				case 7:						/* get IOBYTE */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get IOBYTE\r\n");
#endif

					A = 0x95;
					break;

				case 8:						/* set IOBYTE */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set IOBYTE\r\n");
#endif

					break;

				case 28:					/* write protect disk */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Write protect disk\r\n");
#endif

					break;

				case 9:						/* prstr */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Print string\r\n");
#endif

					mem_ptr = ram + DE;
					while (*mem_ptr != out_delim)
						fputc(*mem_ptr++, stdout);
					break;

				case 10:					/* rdstr */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Read console buffer\r\n");
#endif

					ram[DE + 1] = get_str((char *)(ram) + DE + 2, ram[DE]);
					break;

				case 11:				/* CONSTAT */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get console status\r\n");
#endif

					A = kbhit() ? 0xff : 0;
					break;

				case 12:				/* VERSION */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Return version number\r\n");
#endif

					HL = 0x0022;
					break;

				case 13:				/* RSTDSK */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reset disk system\r\n");
#endif

					break;

				case 14:				/* SELDSK */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Select disk %c:\r\n", E + 'A');
#endif

					k = E + 1;
					A = 0xff;

					if ((k < 1) || (k > 16))
						H = 4;
					else if (*cpm_drive[k] == 0)
						H = 1;
					else
					{
						def_drive = k;
						strcpy(cpm_drive[0], cpm_drive[k]);
						A = 0;
					}
					break;

				case 15:				/* OPENF */
					fcb = (FCB *)(ram + DE);
					fn = fcb2real(fcb);
					memset(&fcb->fp, 0, 24);

#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Open file %s\r\n", fn);
#endif

					A = 0xff;

					if (strchr(fn, '?') != NULL)
						HL = 9;
					else if ((fcb->dr < 0) || (fcb->dr > 16))
						HL = 4;
					else if (*cpm_drive[fcb->dr] == 0)
						HL = 1;
					else if ((fcb->fp = fopen(fn, "r+")) == NULL)
						HL = 0;
					else
						A = HL = 0;

					break;

				case 16:
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Close file\r\n");
#endif

					fcb = (FCB *)(ram + DE);

					if (fcb->fp != NULL)
						fclose(fcb->fp);

					fcb->fp = NULL;
					break;

				case 19:
					fcb = (FCB *)(ram + DE);

#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Delete file\r\n", fcb2real(fcb));
#endif

					unlink(fcb2real(fcb));
					fcb->fp = NULL;
					break;

				case 20:					/* READ */
				case 33:					/* READ RANDOM */
#ifdef	CPM_DEBUG
					if (dasm_flag)
					{
						fprintf(stderr, "BDOS: Read ");
						if (C == 20)
							fprintf(stderr, "sequential");
						else
							fprintf(stderr, "random");
					}
#endif

					if ((fcb = (FCB *)(ram + DE)) == NULL)
					{
						A = 9;
						break;
					}

					memset(dma, 0x1a, 0x80);

					if (C == 33)
					{
						f_pos = (fcb->r2 << 16) + (fcb->r1 << 8) + fcb->r0;
						fseek(fcb->fp, f_pos * 0x80, SEEK_SET);
					}

					if (fread(dma, 1, 0x80, fcb->fp) == 0)
						A = 1;
					else
						A = 0;

					break;

				case 21:					/* WRITE */
				case 34:					/* WRITE RANDOM */
				case 40:					/* Write Random Zero Fill */
#ifdef	CPM_DEBUG
					if (dasm_flag)
					{
						fprintf(stderr, "BDOS: Write ");
						if (C == 21)
							fprintf(stderr, "sequential\r\n");
						else if (C == 34)
							fprintf(stderr, "random\r\n");
						else
							fprintf(stderr, "random with zero fill\r\n");
					}
#endif

					if ((fcb = (FCB *)(ram + DE)) == NULL)
					{
						A = 9;
						break;
					}

					if (C == 34)
					{
						f_pos = (fcb->r2 << 16) + (fcb->r1 << 8) + fcb->r0;
						fseek(fcb->fp, f_pos * 0x80, SEEK_SET);
					}

					if (fwrite(dma, 1, 0x80, fcb->fp) == 0)
						A = 1;
					else
						A = 0;

					break;

				case 22:					/* MAKEF */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Make file\r\n");
#endif

					fcb = (FCB *)(ram + DE);
					fn = fcb2real(fcb);

					if ((fcb->fp = fopen(fn, "r")) != NULL)
					{
						fclose(fcb->fp);
						A = 0xff;
						break;
					}

					memset(&fcb->fp, 0, 24);
					A = 0xff;

					if (strchr(fn, '?') != NULL)
						HL = 9;
					else if ((fcb->dr < 0) || (fcb->dr > 16))
						HL = 4;
					else if (*cpm_drive[fcb->dr] == 0)
						HL = 1;
					else if ((fcb->fp = fopen(fn, "w")) == NULL)
						HL = 0;
					else
						A = HL = 0;

					break;
	
				case 23:					/* RENAME */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Rename file\r\n");
#endif

					fcb = (FCB *)(ram + DE);
					strcpy(fn2, fcb2real(fcb));
					fn = fcb2real(fcb + 16);

					if (link(fn2, fn) == -1)
						A = 0xff;
					else
					{
						unlink(fn2);
						A = 0;
					}
					break;

				case 24:					/* get log in vector */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get login vector\r\n");
#endif

					c = 1;
					HL = 0;

					for (k = 1; k <= 16; k++)
					{
						if (*cpm_drive[k])
							HL |= c;

						c <<= 1;
					}

					A = L;
					break;

				case 25:
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Return current disk\r\n");
#endif

					A = def_drive - 1;
					break;

				case 26:
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set DMA address\r\n");
#endif

					dma = ram + DE;
					break;

				case 29:					/*  get R/O vector */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get read only vector\r\n");
#endif

					HL = 0;
					break;

				case 35:					/* get file size */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Compute file size\r\n");
#endif
					fcb = (FCB *)(ram + DE);
					if (stat(fcb2real(fcb), &s) == -1)
					{
						A = 0xff;
						break;
					}

					A = 0;
					/* fall through */

				case 36:					/* set random record */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set random record\r\n");
#endif

					if (C == 36)
					{
						if ((fcb = (FCB *)(ram + DE)) == NULL)
							break;

						s.st_size = ftell(fcb->fp);
					}

					s.st_size >>= 7;
					fcb->r0 = s.st_size & 0xff;
					s.st_size >>= 8;
					fcb->r1 = s.st_size & 0xff;
					s.st_size >>= 8;
					fcb->r2 = s.st_size & 0xff;

					break;

				case 37:					/* reset drive */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reset drive\r\n");
#endif

					A = 0;
					break;

				default:
					fprintf(stderr, "\a\r\nInvalid BDOS call %d\r\n", C);
					return(-3);
			}
		}
		else if (PC >= BIOS)
		{
			if (PC % 3)
			{
				fprintf(stderr, "\a\r\nInvalid BIOS jump 0%04.4x\r\n", pc);
				PC = pc;
				dump_registers(stderr);
				return(-5);
			}

#ifdef	CPM_DEBUG
			if (dasm_flag)
				fprintf(stderr, "BIOS: Function %d\r\n", (PC - BIOS)/3);
#endif

			switch (PC)
			{
				case bios(0):
					return(0);

				default:
					PC = pc;
					fprintf(stderr, "Unimplemented BIOS jump 0%04.4xH\r\n", PC);
					dump_registers(stderr);
					return(-6);
			}
		}

		if (decode())
		{
			PC = pc;
			fprintf(stderr, "\a\r\nInvalid processor instruction 0x%02.2x\r\n", ram[PC]);
			dump_registers(stderr);
			return(-4);
		}

#ifdef	CPM_DEBUG
		if (dasm_flag > 1 && pc >= BDOS)
			getch();
#endif
	}

	return(0);
}
#endif

FILE	*open_device(char *dev, char *typ)
{
	FILE	*fp;

	if (*dev == '!')
		fp = popen(dev + 1, typ);
	else
		fp = fopen(dev, typ);

	if (fp != NULL)
		return(fp);

	fprintf(stderr, "Error on %s\r\n", dev);
	perror("Can't open virtual device");
	exit(1);
	return(NULL);
}

#ifndef	COMPILE_TEST
static int	do_command(char *cmd_str)
{
	char	entry[256];
	FILE	*fp;

	if ((*cmd_str == ';') || (*cmd_str == '#'))
		return(0);

	strcpy(entry, cmd_str);

	if (*entry == '!')
	{
		int		r;

		ioctl(console, TCSETA, &old_term);
		r = system(entry + 1);
		ioctl(console, TCSETA, &termp);
		return(r);
	}

	strtoup(entry);
	tail = chop_cmd(entry);
	user_break = 0;

	if ((isspace(entry[2]) || (entry[2] == 0)) && (entry[1] == ':'))
	{
		*entry -= '@';

		if ((*entry < 1) || (*entry > MAX_DRIVES) || (*cpm_drive[*entry] == 0))
		{
			fprintf(stderr, "\a\r\nInvalid drive specification\r\n");
			return(-1);
		}

		def_drive = *entry;
		strcpy(cpm_drive[0],cpm_drive[def_drive]);
		entry[0] = entry[1] = ' ';
		tail = chop_cmd(entry);
	}

	if (*entry == 0)
		return(0);

	debug(entry);

	if (strcmp(entry, "DIR") == 0)
		fsystem("ls -C %s", tail);
	else if (strcmp(entry, "DUMP") == 0)
		fsystem("hd %s", tail);
	else if (strcmp(entry, "ED") == 0)
		fsystem("$EDITOR %s", tail);
	else if (strcmp(entry, "ERA") == 0)
		fsystem("rm %s", tail);
#ifdef	CPM_DEBUG
	else if (strcmp(entry, "DASM") == 0)
	{
		if(++dasm_flag > 2)
			dasm_flag = 0;

		fprintf(stderr, "DASM is %d\r\n", dasm_flag);
	}
#endif
	else if (strcmp(entry, "SAVE") == 0)
	{
		char	*fname = chop_cmd(tail);
		int		p = atoi(tail);

		if ((p == 0) || (*fname == 0))
			fprintf(stderr, "Usage: SAVE #pages filename\r\n");
		else
		{
			if ((fp = fopen(real_name(fname), "wb")) == NULL)
				perror("\aCan't open save file");
			else
			{
				if (fwrite(ram + 256, 256, p, fp) != p)
					perror("\aCan't write to file");

				fclose(fp);
			}
		}
	}
	else if (strcmp(entry, "TYPE") == 0)
	{
		char	*ptr;

		while (*tail)
		{
			ptr = tail;
			tail = chop_cmd(ptr);
			fsystem("cat %s", ptr);
		}
	}
	else if (strcmp(entry, "EXIT") == 0)
		cleanup(0);
	else
#ifdef	CPM_DEBUG
	{
		time_t	start = time(NULL);
		int		r = run(real_name(entry));

		fprintf(stderr, "Run took %ld seconds\n\r", time(NULL) - start);
		return(r);
	}
#else
		return(run(real_name(entry)));
#endif

	return(0);
}
#endif

void	main(int argc, char **argv)
{
#ifdef	COMPILE_TEST
	/* test code useful for testing different architectures */
	int		test;

	dasm_flag = 1;
	test = (int)(&acc);
	printf("Position of A = %d\n", (int)(&A) - test);
	printf("Position of FLAGS = %d\n", (int)(&FLAGS) - test);

	test = (int)(&gr);
	printf("Position of B = %d\n", (int)(&B) - test);
	printf("Position of C = %d\n", (int)(&C) - test);
	printf("Position of BC = %d\n", (int)(&BC) - test);
	printf("Position of D = %d\n", (int)(&D) - test);
	printf("Position of E = %d\n", (int)(&E) - test);
	printf("Position of DE = %d\n", (int)(&DE) - test);
	printf("Position of H = %d\n", (int)(&H) - test);
	printf("Position of L = %d\n", (int)(&L) - test);
	printf("Position of HL = %d\n", (int)(&HL) - test);

	AF = 0x1234;
	printf("AF = %04.4x, A = %02.2x, FLAGS = %02.2x\n", AF, A, FLAGS);
	printf("Flags: S=%d Z=%d H=%d P=%d N=%d C=%d\n",
			SIGN, ZERO, HALF_CARRY, PARITY, BCD, CARRY);
	acc_bank = 1;
	AF = 0x4321;
	printf("AF = %04.4x, A = %02.2x, FLAGS = %02.2x\n", AF, A, FLAGS);
	printf("Flags: S=%d Z=%d H=%d P=%d N=%d C=%d\n",
			SIGN, ZERO, HALF_CARRY, PARITY, BCD, CARRY);

	BC = 0x2345;
	printf("BC = %04.4x, B = %02.2x, C = %02.2x\n", BC, B, C);
	gr_bank = 1;
	BC = 0x5432;
	printf("BC = %04.4x, B = %02.2x, C = %02.2x\n", BC, B, C);
	gr_bank = 0;

	DE = 0x3456;
	printf("DE = %04.4x, D = %02.2x, E = %02.2x\n", DE, D, E);
	gr_bank = 1;
	DE = 0x6543;
	printf("DE = %04.4x, D = %02.2x, E = %02.2x\n", DE, D, E);
	gr_bank = 0;

	HL = 0x4567;
	printf("HL = %04.4x, H = %02.2x, L = %02.2x\n", HL, H, L);
	gr_bank = 1;
	HL = 0x7654;
	printf("HL = %04.4x, H = %02.2x, L = %02.2x\n", HL, H, L);
	gr_bank = 0;

	A = BC = DE = HL = SP = PC = 0;

	while (PC < TEST_SIZE)
	{
		dump_registers(stdout);

		if (decode())
		{
			printf("* * * Processor error * * *\n");
			exit(1);
		}
	}

	dump_registers(stdout);

	for (test = 0; test < 0x10; test++)
		printf("%02.2x ", ram[test]);

	printf("\n");
	for (test = 0xfff0; test < 0x10000; test++)
		printf("%02.2x ", ram[test]);

	printf("\nTest code ended normally\n");
	exit(0);
#else

	char	entry[256];
	int		c;

	getcwd(cpm_drive[1], 127);
	entry[0] = 0;
	debug("");

	while ((c = getopt(argc, argv, "d:c:r:p:h")) != -1)
	{
		char	*ptr;
		int		k;

		switch (c)
		{
			case 'd':
				ptr = optarg + 2;

				if (optarg[1] == ':')
					k = toupper(*optarg) - '@';
				else
				{
					k = 1;
					ptr = optarg;

					while ((k < 17) && (*cpm_drive[k]))
						k++;
				}

				if ((k < 1) || (k > 16))
				{
					fprintf(stderr, "Can't set up %s\n", optarg);
					exit(1);
				}

				strcpy(cpm_drive[k], ptr);
				break;

			case 'c':
				strcpy(entry, optarg);
				break;

			case 'r':
				reader = open_device(optarg, "r");
				break;

			case 'p':
				punch = open_device(optarg, "w");
				break;

			case 'l':
				list = open_device(optarg, "w");
				break;

			default:
				fprintf(stderr,
"Usage:\n");
				fprintf(stderr,
"cpm [options]\n");
				fprintf(stderr,
"  Options:\n");
				fprintf(stderr,
"    -d [d:]directory    map CP/M drive to Unix directory.  If the\n");
				fprintf(stderr,
"                        second character is not a colon then the next\n");
				fprintf(stderr,
"                        available drive letter is used otherwise the\n");
				fprintf(stderr,
"                        letter preceding the colon is used.\n");
				fprintf(stderr,
"    -c command          runs the command file then exits.  builtins\n");
				fprintf(stderr,
"                        not supported.  COM file must exist\n");
				fprintf(stderr,
"    -[r|p|l] dev        This allows the I/O to be routed through the\n");
				fprintf(stderr,
"                        Unix file system.  The devices mapped are as\n");
				fprintf(stderr,
"                        follows: r = RDR input, p = PUN output and l for\n");
				fprintf(stderr,
"                        LST output.  The dev argument is opened as a Unix\n");
				fprintf(stderr,
"                        file and I/O for specified device is done through\n");
				fprintf(stderr,
"                        it.  If the first character is '!' then the rest\n");
				fprintf(stderr,
"                        of the line is taken as a command and popen() is\n");
				fprintf(stderr,
"                        called to handle the I/O.\n");
				fprintf(stderr,
"    -h                  Show this help screen\n");

				exit(1);
		}
	}
 
	strcpy(cpm_drive[0], cpm_drive[1]);
	def_drive = 1;

	if ((console = open("/dev/tty", O_RDWR)) == -1)
	{
		perror("Can't open terminal");
		exit(1);
	}

	if (ioctl(console, TCGETA, &old_term) == -1)
	{
		perror("Can't get terminal parameters");
		exit(-1);
	}

	termp = old_term;
	termp.c_oflag =  0;
	termp.c_lflag =  ISIG;
	termp.c_cc[VEOF] = 1;
	termp.c_cc[VSWTCH] = 0xff;
	
	if (ioctl(console, TCSETA, &termp) == -1)
	{
		perror("Can't set terminal parameters");
		exit(1);
	}

	signal(SIGHUP, cleanup);
	signal(SIGINT, cleanup);
	signal(SIGQUIT, cleanup);
	signal(SIGTERM, cleanup);
	debug("Signals captured");

	setbuf(stdout, NULL);

	fprintf(stderr, "\nCP/U - Control Program for Unix\r\n");
	fprintf(stderr, "CP/M emulator Version 0.900\r\n");
	fprintf(stderr, "Written by D'Arcy J.M. Cain\r\n");
	fprintf(stderr, "darcy@druid.UUCP\r\n");

	if (*entry)
	{
		do_command(entry);
		ioctl(console, TCSETA, &old_term);
		exit(0);
	}

	debug("Start main loop");

	for (;;)
	{
		fprintf(stderr, "%c> ", def_drive + '@');
		entry[get_str(entry, 128)] = 0;

		if (*entry)
		{
			if (do_command(entry) == -1)
			{
				debug("chop_cmd(entry)");
				chop_cmd(entry);
				debug("strtoup(entry)");
				strtoup(entry);
				debug("fprintf(stderr, \"%s?\r\n\", entry)");
				fprintf(stderr, "%s?\r\n", entry);
			}
		}
	}
#endif
}
