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
#include	<unistd.h>
#include	<ctype.h>
#include	<errno.h>
#include	<termio.h>
#include	<signal.h>
#include	<time.h>
#include	<sys/stat.h>
#include	<fcntl.h>
#include	"cpm.h"

#define		FILLER_SIZE	(16 - sizeof(FILE *))

FILE	**fcb_fp(byte *fcb)
{
	return((FILE **)(fcb + 16));
}

#define		FCB_DR(x)		(x)[0]		/* drive: 0 = def, 1 = A, 2 = B, etc */
#define		FCB_NAME(x)		((x) + 1)	/* file name up to 8 characters */
#define		FCB_TYP(x)		((x) + 9)	/* file type up to 3 characters */
#define		FCB_EX(x)		(x)[12]		/* extent number */
#define		FCB_S1(x)		(x)[13]
#define		FCB_S2(x)		(x)[14]
#define		FCB_RC(x)		(x)[15]		/* record count for extent "ex" */
#define		FCB_FP(x)		(*fcb_fp(x))/* internal use only */
#define		FCB_CR(x)		(x)[32]		/* current record */
#define		FCB_R0(x)		(x)[33]		/* record number */
#define		FCB_R1(x)		(x)[34]		/* R0 + (R1 << 8) + ((R2  & 1) << 16) */
#define		FCB_R2(x)		(x)[35]
#define		FCB_RR(x)		(long)((x)[33] + ((x)[34]<<8) + (((x)[35] & 1)<<16))

#ifdef		CPM_DEBUG
#define		dump_registers(output) 
	fprintf(output, reg_dump, A, BC, DE, HL, SP, PC,
					SIGN ? 'S' : '-',
					ZERO ? 'Z' : '-',
					HALF_CARRY ? 'H' : '-',
					PARITY ? 'P' : '-',
					BCD ? 'N' : '-',
					CARRY ? 'C' : '-',
					ram[PC], dasm

static int		dasm_flag = 0;
static const char	*reg_dump =
	"A=%02.2x BC=%4.4x DE=%04.4x HL=%04.4x SP=%04.4x PC=%04.4x %c%c%c%c%c%c %02.2x %srn";
#else
#define		dump_registers(output)
#endif

extern char		*optarg;
struct termio	old_term, termp;
static int		user_break;

#ifndef		COMPILE_TEST
static byte		*dma;
static char		*tail;
static int		out_delim = '$', def_drive = 1;
static FILE		*reader = NULL, *punch = NULL, *list = NULL;
#endif

/* clean up routine */
static void	cleanup(int sig)
{
	if (sig == SIGINT)
	{
		user_break = 1;
		signal(SIGINT, cleanup);
		return;
	}

	ioctl(0, TCSETA, &old_term);
	printf("nWe now return you to your regularly scheduled OSn");
	exit(0);
}

#ifndef		COMPILE_TEST

/* get a character from the terminal */
static int		getch(int check)
{
#if 0
	byte	c = 0;
	int		ret_val;

	while ((ret_val = read(0, &c, 1)) != 1)
		if (ret_val == -1 && errno == EINTR)
			return(-1);

	return(c);
#else
	static unsigned char	buf[1024];
	static int				index = 0, sz = 0;
	int						err_ret;

	if (index != sz)
		return(buf[check ? index : index++]);

	index = 0;

	/* first try to get everything that's waiting */
	fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NDELAY);
	sz = read(0, buf, 1024);
	err_ret = errno;

	if (fcntl(0, F_SETFL, fcntl(0, F_GETFL) & ~O_NDELAY) < 0)
		return(-1);

	/* error other than no data ready? */
	if (sz == -1)
	{
		sz = 0;
		return(-1);
	}

	/* no data ready */
	if (!sz)
	{
		if (check)
			return(0);

		/* protect against signals */
		while ((sz = read(0, buf, 1)) == 0)
			;

		if (sz != 1)
		{
			sz = 0;
			return(-1);
		}
	}

	return(buf[check ? index : index++]);
#endif
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
	return(full_name);
}

/* given a file spec in standard CP/M format returns Unix file name */
static char	*real_name(char *fname)
{
	/* does it include a drive letter? */
	if (fname[1] == ':')
		return(mk_name(*fname & 0x0f, fname + 2));

	/* else use default drive */
	/* return(mk_name(0, fname)); */
	return(fname);
}


/* given a pointer to an FCB, returns real file name */
static char	*fcb2real(byte *buf)
{
	char	temp[16], *p = temp;
	int		k = 0;

	for (k = 0; k < 8; k++)
		if (!isspace(FCB_NAME(buf)[k]))
			*p++ = tolower(FCB_NAME(buf)[k]);

	*p++ = '.';

	for (k = 0; k < 3; k++)
		if (!isspace(FCB_TYP(buf)[k]))
			*p++ = tolower(FCB_TYP(buf)[k]);

	*p-- = 0;

	if (*p == '.')
		*p = 0;

	return(mk_name(FCB_DR(buf), temp));
}

/* calls system command with CP/M file name converted to Unix */
static void		fsystem(const char *s, char *file)
{
	char	command[256];

	sprintf(command, s, real_name(file));
	ioctl(0, TCSETAW, &old_term);
	system(command);
	ioctl(0, TCSETAW, &termp);
}

/* formats a CP/M file name into an FCB */
static void	mk_fcb(byte *buf, char *fname)
{
	char	*p = fname;
	int		k, l;

	/* clear FCB to start with */
	memset(buf, 0, 16);

	/* check for drive name */
	if (p[1] == ':')
	{
		FCB_DR(buf) = *p & 0x0f;
		p += 2;
	}

	k = l = 0;

	/* format primary name */
	for (k = 0; k < 8; k++)
	{
		if ((p[l] == '.') || (p[l] == 0))
			while (k < 8)
				FCB_NAME(buf)[k++] = ' ';
		else if (p[l] == '*')
		{
			while (k < 8)
				FCB_NAME(buf)[k++] = '?';

			while (p[l] && (p[l] != '.'))
				l++;
		}
		else
			FCB_NAME(buf)[k] = p[l];

		l++;
	}

	/* format file type */
	for (k = 0; k < 3; k++)
	{
		if ((p[l] == '.') || (p[l] == 0))
			while (k < 3)
				FCB_TYP(buf)[k++] = ' ';
		else if (p[l] == '*')
			while (k < 3)
				FCB_TYP(buf)[k++] = '?';
		else
			FCB_TYP(buf)[k] = p[l];

		l++;
	}

	return;
}

/* add extension to file name.  replace current one if necessary */
static void	addext(char *s1, const char *s2)
{
	char	*p;

	if ((p = strchr(s1, '.')) == NULL)
		strcat(s1, ".");

	strcat(s1, s2);
}


/* get a string */
static int		get_str(char *buffer, int maxlen)
{
	int		k = 0, c;

	/* break will interrupt input as if nothing entered */
	while ((c = getch(0)) != 'r' && c != 'n' && c != -1)
	{
		if (k == maxlen)
			c = 'a';
		else if (c == 'b')
		{
			if (k)
			{
				fprintf(stderr, "b b");
				k--;
			}
		}
		else
		{
			fputc(c, stdout);
			buffer[k++] = c;
		}

	}

	fprintf(stderr, "rn");
	return(c == -1 ? 0 : k);
}

/* see if character waiting */
#define		kbhit()		ioctl(0, FIORDCHK, NULL)

/* Convert string to lower case */
static void		strtolow(char *s)
{
	while (*s)
	{
		*s = tolower(*s);
		s++;
	}
}

/* Convert string to upper case */
static void		strtoup(char *s)
{
	while (*s)
	{
		*s = toupper(*s);
		s++;
	}
}


#ifdef	CPM_DEBUG
#define		is_breakpoint(x)	breakpoint(0, (x))
#define		list_breakpoints()	breakpoint(0, 0)
#define		add_breakpoint(x)	breakpoint(1, (x))
#define		del_breakpoint(x)	breakpoint(2, (x))

static int		breakpoint(int cmd, int bpoint)
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
						fprintf(stderr, "Breakpoint %2d: 0x%04.4xrn");
					else if (bp[k] == bpoint)
						return(1);
				}
			}

			return(0);

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

			fprintf(stderr, "Too many breakpointsrn");
			return(-1);

		case 2:		/* delete a breakpoint */
			for (k = 0; k < 64; k++)
				if (bp[k] == bpoint)
					bp[k] = 0;

			return(0);
	}

	return(-1);
}


static int		debugger(void)
{
	char	entry[128], *ptr;
	int		c;

	user_break = 0;

	for (;;)
	{
		fprintf(stderr, "rnDEBUG> ");
		ptr = entry;

		while ((c = getch(0)) != 'n')
		{
			if (c == -1)
				return(1);

			if ((*ptr = c) == 'b')
			{
				if (ptr > entry)
				{
					fprintf(stderr, "b b");
					ptr--;
				}
			}
			else
				fputc(*ptr++, stdout);
		}

		*ptr = 0;
		strtolow(entry);
		fprintf(stderr, "rn");

		if (!*entry)
			;
		else if (*entry == 'g')
			return(0);
		else if (*entry == 'q')
			return(1);
		else if (*entry == 'r')
			dump_registers(stdout);
		else if (*entry == '+')
			add_breakpoint(atoi(entry + 1));
		else if (*entry == '-')
			del_breakpoint(atoi(entry + 1));
		else if (*entry == 'l')
			list_breakpoints();
		else if (isdigit(*entry))
			dasm_flag = *entry - '0';
		else if (*entry == '?')
		{
			printf("  g     Run from current PCrn");
			printf("  q     Quit to command interpreterrn");
			printf("  r     Dump registersrn");
			printf("  +###  Add breakpoint at numberrrn");
			printf("  -###  Delete breakpoint at numberrn");
			printf("  l     list current breakpointsrn");
			printf("  ###   Set debug level to numberrn");
		}
		else
			fprintf(stderr, "aUnknown command: %cn", *entry);
	}
}
#endif	/* CPM_DEBUG */

/* run a program */
static int	run(char *program)
{
	byte	*mem_ptr = ram + 0x100;
	char	*fn, fn2[128];
	int		c, k, pc;
	FILE	*fp;
	byte	*fcb = NULL;
	long	f_pos;
	struct stat	s;


	/* find the program name */
	strcpy((char *)(mem_ptr), program);
	addext((char *)(mem_ptr), "com");

	/* open the command file - return error if not found */
	if ((fp = fopen((char *)(mem_ptr), "rb")) == NULL)
		return(-1);

	/* load command into memory */
	while (fread(mem_ptr, 1, 0x100, fp))
	{
		if (mem_ptr > (ram + 0xf000))
		{
			fprintf(stderr, "aCommand file too bigrn");
			return(-2);
		}

		mem_ptr += 0x100;
	}

	fclose(fp);
	PC = 0x100;

	/* BDOS, BIOS and default stack */
#if defined(USUAL_MICROSOFT_STUPIDITY)
	for (k = BIOS; k < 0x10000; k += 3)
	{
		ram[k] = 0xc3;	/* JP */
		ram[k + 1] = k & 0xff;
		ram[k + 2] = k >> 8;
	}

	for (k = BDOS - 0x10; k < BDOS; k++)
		ram[k] = 0;

	SP = BDOS - 0x10;
#else
	for (k = 0xfff0; k < 0x10000; k++)
		ram[k] = 0;

	SP = 0xfff0;
#endif

	strcpy((char *)(ram + 0x80), tail);
	mem_ptr = (byte *)(chop_cmd(tail));
	mk_fcb(ram + 0x5c, tail);
	mk_fcb(ram + 0x6c, (char *)(mem_ptr));
	memcpy(ram, page_zero, sizeof(page_zero));
	dma = ram + 0x80;

	
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
			fprintf(stderr, "rnna* Program Interrupted by user *rn", ram[PC]);
			dump_registers(stderr);
			return(-5);
		}

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
						fprintf(stderr, "BDOS: System resetrn");
#endif
					return(0);

				case 1:						/* conin */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Console inrn");
#endif

					if ((A = getch(0)) == -1)
						A = '*';

					fputc(A, stdout);
					break;

				case 2:						/* conout */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Console out (%c)rn", E >= ' ' ? E : '.');
#endif

					fputc(E, stdout);
					break;

				case 3:						/* RDR */ 
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reader inrn");
#endif

					if (reader != NULL)
						A = fgetc(reader);
					break;

				case 4:						/* PUN */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Punch out (%c)rn", E >= ' ' ? E : '.');
#endif

					if (punch != NULL)
						fputc(E, punch);
					break;

				case 5:						/* LST */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: List out (%c)rn", E >= ' ' ? E : '.');
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
							fprintf(stderr, "inrn");
						else
							fprintf(stderr, "out (%c)rn", E >= ' ' ? E : '.');
					}
#endif

					if (E == 0xff)
					{
						if ((A = getch(1)) != 0)
							A = getch(0);
					}
					else
						fputc(E, stdout);

					break;

				case 7:						/* get IOBYTE */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get IOBYTErn");
#endif

					A = 0x95;
					break;

				case 8:						/* set IOBYTE */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set IOBYTErn");
#endif

					break;

				case 28:					/* write protect disk */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Write protect diskrn");
#endif

					break;

				case 9:						/* prstr */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Print stringrn");
#endif

					mem_ptr = ram + DE;
					while (*mem_ptr != out_delim)
						fputc(*mem_ptr++, stdout);
					break;

				case 10:					/* rdstr */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Read console bufferrn");
#endif

					ram[DE + 1] = get_str((char *)(ram) + DE + 2, ram[DE]);
					break;

				case 11:				/* CONSTAT */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get console statusrn");
#endif

					A = kbhit() ? 0xff : 0;
					break;

				case 12:				/* VERSION */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Return version numberrn");
#endif

					HL = 0x0022;
					break;

				case 13:				/* RSTDSK */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reset disk systemrn");
#endif

					break;

				case 14:				/* SELDSK */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Select disk %c:rn", E + 'A');
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
					fcb = ram + DE;
					fn = fcb2real(fcb);
					memset(&FCB_FP(fcb), 0, 24);

#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Open file %srn", fn);
#endif

					A = 0xff;

					if (strchr(fn, '?') != NULL)
						HL = 9;
					else if ((FCB_DR(fcb) < 0) || (FCB_DR(fcb) > 16))
						HL = 4;
					else if (*cpm_drive[FCB_DR(fcb)] == 0)
						HL = 1;
					else if ((FCB_FP(fcb) = fopen(fn, "r+")) == NULL)
						HL = 0;
					else
						A = HL = 0;

					break;

				case 16:
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Close filern");
#endif

					fcb = ram + DE;

					if (FCB_FP(fcb) != NULL)
						fclose(FCB_FP(fcb));

					FCB_FP(fcb) = 0;
					break;

				case 19:
					fcb = ram + DE;

#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Delete file %srn",
															fcb2real(fcb));
#endif

					unlink(fcb2real(fcb));
					FCB_FP(fcb) = NULL;
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

					fcb = ram + DE;
					memset(dma, 0x1a, 0x80);

					if (C == 33)
					{
						f_pos = FCB_RR(fcb);
						fseek(FCB_FP(fcb), f_pos * 0x80, SEEK_SET);
					}

					if (fread(dma, 1, 0x80, FCB_FP(fcb)) == 0)
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
							fprintf(stderr, "sequentialrn");
						else if (C == 34)
							fprintf(stderr, "randomrn");
						else
							fprintf(stderr, "random with zero fillrn");
					}
#endif

					fcb = ram + DE;

					if (C == 34)
					{
						f_pos = FCB_RR(fcb);
						fseek(FCB_FP(fcb), f_pos * 0x80, SEEK_SET);
					}

					if (fwrite(dma, 1, 0x80, FCB_FP(fcb)) == 0)
						A = 1;
					else
						A = 0;

					break;

				case 22:					/* MAKEF */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Make file %srn",
												fcb2real(fcb));
#endif

					fcb = ram + DE;
					fn = fcb2real(fcb);

					if ((FCB_FP(fcb) = fopen(fn, "r")) != NULL)
					{
						fclose(FCB_FP(fcb));
						A = 0xff;
						HL = 8;
						break;
					}

					memset(&FCB_FP(fcb), 0, 24);
					A = 0xff;

					if (strchr(fn, '?') != NULL)
						HL = 9;
					else if ((FCB_DR(fcb) < 0) || (FCB_DR(fcb) > 16))
						HL = 4;
					else if (*cpm_drive[FCB_DR(fcb)] == 0)
						HL = 1;
					else if ((FCB_FP(fcb) = fopen(fn, "w")) == NULL)
						HL = 1;
					else
						A = HL = 0;

#ifdef	CPM_DEBUG
					if (HL == 1 && dasm_flag)
						fprintf(stderr, "Can't open %s: %srn",
												fn, strerror(errno));
#endif
					break;
	
				case 23:					/* RENAME */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Rename filern");
#endif

					fcb = ram + DE;
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
						fprintf(stderr, "BDOS: Get login vectorrn");
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
						fprintf(stderr, "BDOS: Return current diskrn");
#endif

					A = def_drive - 1;
					break;

				case 26:
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set DMA addressrn");
#endif

					dma = ram + DE;
					break;

				case 29:					/*  get R/O vector */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Get read only vectorrn");
#endif

					HL = 0;
					break;

				case 32:					/* set/get user code */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Set/get user codern");
#endif
					if (E == 0xff)
						A = 0;

					break;

				case 35:					/* get file size */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Compute file sizern");
#endif
					fcb = ram + DE;
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
						fprintf(stderr, "BDOS: Set random recordrn");
#endif

					if (C == 36)
					{
						fcb = ram + DE;
						s.st_size = ftell(FCB_FP(fcb));
					}

					s.st_size >>= 7;
					FCB_R0(fcb) = s.st_size & 0xff;
					s.st_size >>= 8;
					FCB_R1(fcb) = s.st_size & 0xff;
					s.st_size >>= 8;
					FCB_R2(fcb) = s.st_size & 1;

					break;

				case 37:					/* reset drive */
#ifdef	CPM_DEBUG
					if (dasm_flag)
						fprintf(stderr, "BDOS: Reset drivern");
#endif

					A = 0;
					break;

				default:
					fprintf(stderr, "arnInvalid BDOS call %drn", C);
					return(-3);
			}
		}
		else if (PC >= BIOS)
		{
			if (PC % 3)
			{
				fprintf(stderr, "arnInvalid BIOS jump 0%04.4xrn", pc);
				PC = pc;
				dump_registers(stderr);
				return(-5);
			}

#ifdef	CPM_DEBUG
			if (dasm_flag)
				fprintf(stderr, "BIOS: Function %drn",
							(PC - BIOS)/(unsigned)(3));
#endif

			switch (PC)
			{
				case bios(0):	/* BOOT */
				case bios(1):	/* WBOOT */
					return(0);

				case bios(2):	/* CONST */
					if ((A = getch(1)) != 0)
						A = 0xff;

					break;

				case bios(3):	/* CONIN */
					A = getch(0);
					break;

				case bios(4):	/* CONOUT */
					fputc(C, stdout);
					break;

				case bios(5):	/* LIST */
					fputc(C, list);
					break;

				case bios(6):	/* PUNCH */
					fputc(C, punch);
					break;

				case bios(7):	/* READER */
					A = fgetc(reader);
					break;

				case bios(15):	/* LISTST */
					A = 0xff;		/* it's always ready */
					break;

				default:
					PC = pc;
					fprintf(stderr, "Unimplemented BIOS jmp 0%04.4xH (%d)rn",
										PC, (PC - BIOS)/(size_t)(3));
					dump_registers(stderr);
					return(-6);
			}
		}

		if (decode())
		{
			PC = pc;
			fprintf(stderr, "arnInvalid processor instruction 0x%02.2xrn", ram[PC]);
			dump_registers(stderr);
			return(-4);
		}

#ifdef	CPM_DEBUG
		if (dasm_flag > 1 && pc >= BDOS)
			getch(0);
#endif
	}

	return(0);
}
#endif

#ifndef	COMPILE_TEST
static FILE	*open_device(const char *dev, const char *typ)
{
	FILE	*fp;

	if (*dev == '!')
		fp = popen(dev + 1, typ);
	else
		fp = fopen(dev, typ);

	if (fp != NULL)
		return(fp);

	fprintf(stderr, "Error on %srn", dev);
	perror("Can't open virtual device");
	exit(1);
	return(NULL);
}

static int	do_command(char *cmd_str)
{
	char	entry[256];
	FILE	*fp;

	/* allow comments */
	if ((*cmd_str == ';') || (*cmd_str == '#'))
		return(0);

	/* get our own copy of the command */
	strcpy(entry, cmd_str);

	/* request for Unix shell escape? */
	if (*entry == '!')
	{
		int		r;

		ioctl(0, TCSETA, &old_term);
		r = system(entry + 1);
		ioctl(0, TCSETA, &termp);
		return(r);
	}

	strtolow(entry);
	tail = chop_cmd(entry);
	user_break = 0;

	/* check for request to change default drive */
	if ((isspace(entry[2]) || (entry[2] == 0)) && (entry[1] == ':'))
	{
		*entry &= 0x0f;

		if ((*entry < 1) || (*entry > MAX_DRIVES) || *cpm_drive[*entry] == 0)
		{
			fprintf(stderr, "arnInvalid drive specificationrn");
			return(-1);
		}

		if (chdir(cpm_drive[*entry]))
		{
			fprintf(stderr, "arnCan't change to drive %c: %srn",
						entry + '@', strerror(errno));
			return(-1);
		}

		def_drive = *entry;
		strcpy(cpm_drive[0], cpm_drive[def_drive]);
		entry[0] = entry[1] = ' ';
		tail = chop_cmd(entry);
	}

	if (*entry == 0)
		return(0);

	/* handle some builtins */
	if (strcmp(entry, "dir") == 0)
		fsystem("ls -C %s", tail);
	else if (strcmp(entry, "dump") == 0)
		fsystem("hd %s", tail);
	else if (strcmp(entry, "ed") == 0)
		fsystem("$EDITOR %s", tail);
	else if (strcmp(entry, "era") == 0)
		fsystem("rm %s", tail);
#ifdef	CPM_DEBUG
	else if (strcmp(entry, "dasm") == 0)
	{
		if(++dasm_flag > 2)
			dasm_flag = 0;

		fprintf(stderr, "DASM is %drn", dasm_flag);
	}
#endif
	else if (strcmp(entry, "save") == 0)
	{
		char	*fname = chop_cmd(tail);
		int		p = atoi(tail);

		if ((p == 0) || (*fname == 0))
			fprintf(stderr, "Usage: SAVE #pages filenamern");
		else
		{
			if ((fp = fopen(real_name(fname), "wb")) == NULL)
				perror("aCan't open save file");
			else
			{
				if (fwrite(ram + 256, 256, p, fp) != p)
					perror("aCan't write to file");

				fclose(fp);
			}
		}
	}
	else if (strcmp(entry, "type") == 0)
	{
		char	*ptr;

		while (*tail)
		{
			ptr = tail;
			tail = chop_cmd(ptr);
			fsystem("cat %s", ptr);
		}
	}
	else if (strcmp(entry, "exit") == 0)
		cleanup(0);
	else
#ifdef	CPM_DEBUG
	{
		time_t	start = time(NULL);
		int		r = run(real_name(entry));

		fprintf(stderr, "Run took %ld secondsnr", time(NULL) - start);
		return(r);
	}
#else
		return(run(real_name(entry)));
#endif

	return(0);
}
#endif

int		main(int argc, char **argv)
{
#ifdef	COMPILE_TEST
	/* test code useful for testing different architectures */
	int		test;

	dasm_flag = 1;
	test = (int)(&acc);
	printf("Position of A = %dn", (int)(&A) - test);
	printf("Position of FLAGS = %dn", (int)(&FLAGS) - test);

	test = (int)(&gr);
	printf("Position of B = %dn", (int)(&B) - test);
	printf("Position of C = %dn", (int)(&C) - test);
	printf("Position of BC = %dn", (int)(&BC) - test);
	printf("Position of D = %dn", (int)(&D) - test);
	printf("Position of E = %dn", (int)(&E) - test);
	printf("Position of DE = %dn", (int)(&DE) - test);
	printf("Position of H = %dn", (int)(&H) - test);
	printf("Position of L = %dn", (int)(&L) - test);
	printf("Position of HL = %dn", (int)(&HL) - test);

	AF = 0x1234;
	printf("AF = %04.4x, A = %02.2x, FLAGS = %02.2xn", AF, A, FLAGS);
	printf("Flags: S=%d Z=%d H=%d P=%d N=%d C=%dn",
			SIGN, ZERO, HALF_CARRY, PARITY, BCD, CARRY);
	acc_bank = 1;
	AF = 0x4321;
	printf("AF = %04.4x, A = %02.2x, FLAGS = %02.2xn", AF, A, FLAGS);
	printf("Flags: S=%d Z=%d H=%d P=%d N=%d C=%dn",
			SIGN, ZERO, HALF_CARRY, PARITY, BCD, CARRY);

	BC = 0x2345;
	printf("BC = %04.4x, B = %02.2x, C = %02.2xn", BC, B, C);
	gr_bank = 1;
	BC = 0x5432;
	printf("BC = %04.4x, B = %02.2x, C = %02.2xn", BC, B, C);
	gr_bank = 0;

	DE = 0x3456;
	printf("DE = %04.4x, D = %02.2x, E = %02.2xn", DE, D, E);
	gr_bank = 1;
	DE = 0x6543;
	printf("DE = %04.4x, D = %02.2x, E = %02.2xn", DE, D, E);
	gr_bank = 0;

	HL = 0x4567;
	printf("HL = %04.4x, H = %02.2x, L = %02.2xn", HL, H, L);
	gr_bank = 1;
	HL = 0x7654;
	printf("HL = %04.4x, H = %02.2x, L = %02.2xn", HL, H, L);
	gr_bank = 0;

	A = BC = DE = HL = SP = PC = 0;

	while (PC < TEST_SIZE)
	{
		dump_registers(stdout);

		if (decode())
		{
			printf("* * * Processor error * * *n");
			exit(1);
		}
	}

	dump_registers(stdout);

	for (test = 0; test < 0x10; test++)
		printf("%02.2x ", ram[test]);

	printf("n");
	for (test = 0xfff0; test < 0x10000; test++)
		printf("%02.2x ", ram[test]);

	printf("nTest code ended normallyn");
	return(0);
#else	/* COMPILE_TEST */

	char	entry[256] = "";
	int		c;

	/* make current directory the default one */
	getcwd(cpm_drive[1], 127);

	while ((c = getopt(argc, argv, "d:c:r:p:h")) != -1)
	{
		char	*ptr;
		int		k;

		switch (c)
		{
			case 'd':
				ptr = optarg + 2;

				if (optarg[1] == ':')
					k = *optarg & 0x0f;
				else
				{
					k = 1;
					ptr = optarg;

					while ((k < 17) && (*cpm_drive[k]))
						k++;
				}

				if ((k < 1) || (k > 16))
				{
					fprintf(stderr, "Can't set up %sn", optarg);
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
				fprintf(stderr, "Usage:n");
				fprintf(stderr, "cpm [options]n");
				fprintf(stderr, "  Options:n");
				fprintf(stderr,
"    -d [d:]directory    map CP/M drive to Unix directory.  If then");
				fprintf(stderr,
"                        second character is not a colon then the nextn");
				fprintf(stderr,
"                        available drive letter is used otherwise then");
				fprintf(stderr,
"                        letter preceding the colon is used.n");
				fprintf(stderr,
"    -c command          runs the command file then exits.  builtinsn");
				fprintf(stderr,
"                        not supported.  COM file must existn");
				fprintf(stderr,
"    -[r|p|l] dev        This allows the I/O to be routed through then");
				fprintf(stderr,
"                        Unix file system.  The devices mapped are asn");
				fprintf(stderr,
"                        follows: r = RDR input, p = PUN output and l forn");
				fprintf(stderr,
"                        LST output.  The dev argument is opened as a Unixn");
				fprintf(stderr,
"                        file and I/O for specified device is done throughn");
				fprintf(stderr,
"                        it.  If the first character is '!' then the restn");
				fprintf(stderr,
"                        of the line is taken as a command and popen() isn");
				fprintf(stderr,
"                        called to handle the I/O.n");
				fprintf(stderr,
"    -h                  Show this help screenn");

				exit(1);
		}
	}
 
	strcpy(cpm_drive[0], cpm_drive[1]);
	def_drive = 1;

	/* set up terminal */
	if (ioctl(0, TCGETA, &old_term) == -1)
	{
		perror("Can't get terminal parameters");
		exit(-1);
	}

	termp = old_term;
	termp.c_oflag =  0;
	termp.c_lflag =  ISIG;
	termp.c_cc[VEOF] = 1;
	termp.c_cc[VSWTCH] = -1;
	
	if (ioctl(0, TCSETAW, &termp) == -1)
	{
		perror("Can't set terminal parameters");
		exit(1);
	}

	signal(SIGHUP, cleanup);
	signal(SIGINT, cleanup);
	signal(SIGQUIT, cleanup);
	signal(SIGTERM, cleanup);

	setbuf(stdout, NULL);

	/* tell them who we are - note stderr */
	fprintf(stderr, "nCP/U - Control Program for Unixrn");
	fprintf(stderr, "CP/M emulator Version 0.920rn");
	fprintf(stderr, "Written by D'Arcy J.M. Cainrn");
	fprintf(stderr, "darcy@druid.UUCPrn");

	/* see if we have a command to run */
	if (*entry)
	{
		do_command(entry);
		ioctl(0, TCSETA, &old_term);
		return(0);
	}

	for (;;)
	{
		fprintf(stderr, "%c> ", def_drive + '@');
		entry[get_str(entry, 128)] = 0;

		if (*entry)
		{
			if (do_command(entry) == -1)
			{
				chop_cmd(entry);
				strtoup(entry);
				fprintf(stderr, "%s?rn", entry);
			}
		}
	}
#endif	/* COMPILE_TEST */
}
