/*
 * Z80SIM  -  a	Z80-CPU	simulator
 *
 * Copyright (C) 1987-92 by Udo Munk
 *
 * This modul contains the user interface, a full qualified ICE,
 * for the Z80-CPU simulation. This modul is released to the public domain,
 * and may be modified by user.
 *
 * History:
 * 28-SEP-87 Development on TARGON/35 with AT&T Unix System V.3
 * 11-JAN-89 Release 1.1
 * 08-FEB-89 Release 1.2
 * 13-MAR-89 Release 1.3
 * 09-FEB-90 Release 1.4 Ported to TARGON/31 M10/30
 * 20-DEC-90 Release 1.5 Ported to COHERENT 3.0
 * 10-JUN-92 Release 1.6 long casting problem solved with COHERENT 3.2
 *			 and some optimization
 * 25-JUN-92 Release 1.7 comments in english and ported to COHERENT 4.0
 */

/*
 *	This modul is an ICE type user interface to debug Z80 programs
 *	on a host system.
 */

#include <stdio.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#else
#include <fcntl.h>
#endif
#ifndef COHERENT
#include <memory.h>
#endif
#include <ctype.h>
#include <signal.h>
#include "sim.h"
#include "simglb.h"

/*
 *	The function "mon()" is the dialog user interface, called
 *	from the simulation just after program start.
 */
mon()
{
	register int eoj = 1;
	static char cmd[LENCMD];

	if (x_flag) {
		if (do_getfile(xfn) == 0)
			do_go("");
	}
	while (eoj) {
		next:
		printf(">>> ");
		fflush(stdout);
		if (fgets(cmd, LENCMD, stdin) == NULL) {
			putchar('\n');
			goto next;
		}
		switch (*cmd) {
		case '\n':
			do_step();
			break;
		case 't':
			do_trace(cmd + 1);
			break;
		case 'g':
			do_go(cmd + 1);
			break;
		case 'd':
			do_dump(cmd + 1);
			break;
#if !defined(COHERENT) || defined(_I386)
		case 'l':
			do_list(cmd + 1);
			break;
#endif
		case 'm':
			do_modify(cmd +	1);
			break;
		case 'f':
			do_fill(cmd + 1);
			break;
#if !defined(COHERENT) || defined(_I386)
		case 'v':
			do_move(cmd + 1);
			break;
#endif
		case 'x':
			do_reg(cmd + 1);
			break;
		case 'p':
			do_port(cmd + 1);
			break;
		case 'b':
			do_break(cmd + 1);
			break;
		case 'h':
			do_hist(cmd + 1);
			break;
		case 'z':
			do_count(cmd + 1);
			break;
#if !defined(COHERENT) || defined(_I386)
		case 'c':
			do_clock();
			break;
#endif
		case 's':
			do_show();
			break;
		case '?':
			do_help();
			break;
		case 'r':
			do_getfile(cmd + 1);
			break;
		case '!':
			do_unix(cmd + 1);
			break;
		case 'q':
			eoj = 0;
			break;
		default:
			puts("what??");
			break;
		}
	}
}

/*
 *	Execute a single step
 */
static do_step()
{
#if !defined(COHERENT) || defined(_I386)
	BYTE *p;
#endif

	cpu_state = SINGLE_STEP;
	cpu_error = NONE;
	cpu();
	if (cpu_error == OPHALT)
		handel_break();
	cpu_err_msg();
	print_head();
	print_reg();
#if !defined(COHERENT) || defined(_I386)
	p = PC;
	disass(&p, p - ram);
#endif
}

/*
 *	Execute several steps with trace output
 */
static do_trace(s)
register char *s;
{
	register int count, i;

	while (isspace(*s))
		s++;
	if (*s == '\0')
		count =	20;
	else
		count =	atoi(s);
	cpu_state = SINGLE_STEP;
	cpu_error = NONE;
	print_head();
	print_reg();
	for (i = 0; i <	count; i++) {
		cpu();
		print_reg();
		if (cpu_error) {
			if (cpu_error == OPHALT) {
				if (!handel_break()) {
					break;
				}
			} else
				break;
		}
	}
	cpu_err_msg();
}

/*
 *	Run the CPU emulation endless
 */
static do_go(s)
register char *s;
{
	while (isspace(*s))
		s++;
	if (isxdigit(*s))
		PC = ram + exatoi(s);
	cont:
	cpu_state = CONTIN_RUN;
	cpu_error = NONE;
	cpu();
	if (cpu_error == OPHALT)
		if (handel_break())
			if (!cpu_error)
				goto cont;
	cpu_err_msg();
	print_head();
	print_reg();
}

/*
 *	Handling of software breakpoints (HALT opcode):
 *	Behandlung von Software	Breakpoints (HALT Op-Code)
 *	Output:	0 breakpoint or other HALT opcode reached (stop)
 *		1 breakpoint reached, passcounter not reached (continue)
 */
static handel_break()
{
#ifdef SBSIZE
	register int i;
	int break_address;

	for (i = 0; i <	SBSIZE;	i++)	/* search for breakpoint */
		if (soft[i].sb_adr == PC - ram - 1)
			goto was_softbreak;
	return(0);
	was_softbreak:
#ifdef HISIZE
	h_next--;			/* correct history */
	if (h_next < 0)
		h_next = 0;
#endif
	break_address =	PC - ram - 1;	/* store adr of breakpoint */
	cpu_error = NONE;		/* HALT	was a breakpoint */
	PC--;				/* substitute HALT opcode by */
	*PC = soft[i].sb_oldopc;	/* original opcode */
	cpu_state = SINGLE_STEP;	/* and execute it */
	cpu();
	*(ram +	soft[i].sb_adr)	= 0x76;	/* restore HALT	opcode again */
	soft[i].sb_passcount++;		/* increment passcounter */
	if (soft[i].sb_passcount != soft[i].sb_pass)
		return(1);		/* pass	not reached, continue */
	printf("Software breakpoint %d reached at %04x\n", i, break_address);
	soft[i].sb_passcount = 0;	/* reset passcounter */
	return(0);			/* pass	reached, stop */
#endif
}

/*
 *	Memory dump
 */
static do_dump(s)
register char *s;
{
	register int i,	j;
	BYTE c;

	while (isspace(*s))
		s++;
	if (isxdigit(*s)) {
#if defined(COHERENT) && !defined(_I386)
		if (exatoi(s) < 0) {
			puts(adr_err);
			return;
		}
#endif
		wrk_ram	= ram +	exatoi(s) - exatoi(s) %	16;
	}
	printf("Adr    ");
	for (i = 0; i <	16; i++)
		printf("%02x ",	i);
	puts(" ASCII");
	for (i = 0; i <	16; i++) {
		printf("%04x - ", wrk_ram - ram);
		for (j = 0; j <	16; j++) {
			printf("%02x ",	*wrk_ram);
			wrk_ram++;
#if !defined(COHERENT) || defined(_I386)
			if (wrk_ram > ram + 65535)
#else
			if (wrk_ram > ram + 32767)
#endif
				wrk_ram	= ram;
		}
		putchar('\t');
		for (j = -16; j	< 0; j++)
			printf("%c",((c	= *(wrk_ram+j))>=' ' &&	c<=0x7f) ? c : '.');
		putchar('\n');
	}
}

#if !defined(COHERENT) || defined(_I386)
/*
 *	Disassemble
 */
static do_list(s)
register char *s;
{
	register int i;

	while (isspace(*s))
		s++;
	if (isxdigit(*s))
		wrk_ram	= ram +	exatoi(s);
	for (i = 0; i <	10; i++) {
		printf("%04x - ", wrk_ram - ram);
		disass(&wrk_ram, wrk_ram - ram);
		if (wrk_ram > ram + 65535)
			wrk_ram	= ram;
	}
}
#endif

/*
 *	Memory modify
 */
static do_modify(s)
register char *s;
{
	static char nv[LENCMD];

	while (isspace(*s))
		s++;
	if (isxdigit(*s)) {
#if defined(COHERENT) && !defined(_I386)
		if (exatoi(s) < 0) {
			puts(adr_err);
			return;
		}
#endif
		wrk_ram	= ram +	exatoi(s);
	}
	for (;;) {
		printf("%04x = %02x : ", wrk_ram - ram,	*wrk_ram);
		fgets(nv, sizeof(nv), stdin);
		if (nv[0] == '\n') {
			wrk_ram++;
#if !defined(COHERENT) || defined(_I386)
			if (wrk_ram > ram + 32767)
#else
			if (wrk_ram > ram + 65535)
#endif
				wrk_ram	= ram;
			continue;
		}
		if (!isxdigit(nv[0]))
			break;
		*wrk_ram++ = exatoi(nv);
#if !defined(COHERENT) || defined(_I386)
		if (wrk_ram > ram + 32767)
#else
		if (wrk_ram > ram + 65535)
#endif
			wrk_ram	= ram;
	}
}

/*
 *	Memory fill
 */
static do_fill(s)
register char *s;
{
	register BYTE *p;
	register int i;
	register BYTE val;

	while (isspace(*s))
		s++;
#if defined(COHERENT) && !defined(_I386)
	if (exatoi(s) < 0) {
		puts(adr_err);
		return;
	}
#endif
	p = ram	+ exatoi(s);
	while (*s != ',' && *s != '\0')
		s++;
	if (*s)
		i = exatoi(++s);
	while (*s != ',' && *s != '\0')
		s++;
	if (*s)
		val = exatoi(++s);
	while (i--) {
		*p++ = val;
#if !defined(COHERENT) || defined(_I386)
		if (p > ram + 32767)
#else
		if (p >	ram + 65535)
#endif
			p = ram;
	}
}

#if !defined(COHERENT) || defined(_I386)
/*
 *	Memory move
 */
static do_move(s)
register char *s;
{
	register BYTE *p1, *p2;
	register int count;

	while (isspace(*s))
		s++;
	p1 = ram + exatoi(s);
	while (*s != ',' && *s != '\0')
		s++;
	if (*s)
		p2 = ram + exatoi(++s);
	while (*s != ',' && *s != '\0')
		s++;
	if (*s)
		count =	exatoi(++s);
	while (count--)	{
		*p2++ =	*p1++;
		if (p1 > ram + 65535)
			p1 = ram;
		if (p2 > ram + 65535)
			p2 = ram;
	}
}
#endif

/*
 *	Port modify
 */
static do_port(s)
register char *s;
{
	register BYTE port;
	static char nv[LENCMD];
	extern BYTE io_out(), io_in();

	while (isspace(*s))
		s++;
	port = exatoi(s);
	printf("%02x = %02x : ", port, io_in(port));
	fgets(nv, sizeof(nv), stdin);
	if (isxdigit(*nv))
		io_out(port, (BYTE) exatoi(nv));
}

/*
 *	Register modify
 */
static do_reg(s)
register char *s;
{
	static char nv[LENCMD];

	while (isspace(*s))
		s++;
	if (*s == '\0')	{
		print_head();
		print_reg();
	} else {
		if (strncmp(s, "bc'", 3) == 0) {
			printf("BC' = %04x : ",	B_ * 256 + C_);
			fgets(nv, sizeof(nv), stdin);
			B_ = (exatoi(nv) & 0xffff) / 256;
			C_ = (exatoi(nv) & 0xffff) % 256;
		} else if (strncmp(s, "de'", 3)	== 0) {
			printf("DE' = %04x : ",	D_ * 256 + E_);
			fgets(nv, sizeof(nv), stdin);
			D_ = (exatoi(nv) & 0xffff) / 256;
			E_ = (exatoi(nv) & 0xffff) % 256;
		} else if (strncmp(s, "hl'", 3)	== 0) {
			printf("HL' = %04x : ",	H_ * 256 + L_);
			fgets(nv, sizeof(nv), stdin);
			H_ = (exatoi(nv) & 0xffff) / 256;
			L_ = (exatoi(nv) & 0xffff) % 256;
		} else if (strncmp(s, "pc", 2) == 0) {
			printf("PC = %04x : ", PC - ram);
			fgets(nv, sizeof(nv), stdin);
			PC = ram + (exatoi(nv) & 0xffff);
		} else if (strncmp(s, "bc", 2) == 0) {
			printf("BC = %04x : ", B * 256 + C);
			fgets(nv, sizeof(nv), stdin);
			B = (exatoi(nv)	& 0xffff) / 256;
			C = (exatoi(nv)	& 0xffff) % 256;
		} else if (strncmp(s, "de", 2) == 0) {
			printf("DE = %04x : ", D * 256 + E);
			fgets(nv, sizeof(nv), stdin);
			D = (exatoi(nv)	& 0xffff) / 256;
			E = (exatoi(nv)	& 0xffff) % 256;
		} else if (strncmp(s, "hl", 2) == 0) {
			printf("HL = %04x : ", H * 256 + L);
			fgets(nv, sizeof(nv), stdin);
			H = (exatoi(nv)	& 0xffff) / 256;
			L = (exatoi(nv)	& 0xffff) % 256;
		} else if (strncmp(s, "ix", 2) == 0) {
			printf("IX = %04x : ", IX);
			fgets(nv, sizeof(nv), stdin);
			IX = exatoi(nv)	& 0xffff;
		} else if (strncmp(s, "iy", 2) == 0) {
			printf("IY = %04x : ", IY);
			fgets(nv, sizeof(nv), stdin);
			IY = exatoi(nv)	& 0xffff;
		} else if (strncmp(s, "sp", 2) == 0) {
			printf("SP = %04x : ", STACK - ram);
			fgets(nv, sizeof(nv), stdin);
			STACK =	ram + (exatoi(nv) & 0xffff);
		} else if (strncmp(s, "fs", 2) == 0) {
			printf("S-FLAG = %c : ", (F & S_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	S_FLAG)	: (F & ~S_FLAG);
		} else if (strncmp(s, "fz", 2) == 0) {
			printf("Z-FLAG = %c : ", (F & Z_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	Z_FLAG)	: (F & ~Z_FLAG);
		} else if (strncmp(s, "fh", 2) == 0) {
			printf("H-FLAG = %c : ", (F & H_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	H_FLAG)	: (F & ~H_FLAG);
		} else if (strncmp(s, "fp", 2) == 0) {
			printf("P-FLAG = %c : ", (F & P_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	P_FLAG)	: (F & ~P_FLAG);
		} else if (strncmp(s, "fn", 2) == 0) {
			printf("N-FLAG = %c : ", (F & N_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	N_FLAG)	: (F & ~N_FLAG);
		} else if (strncmp(s, "fc", 2) == 0) {
			printf("C-FLAG = %c : ", (F & C_FLAG) ?	'1' : '0');
			fgets(nv, sizeof(nv), stdin);
			F = (exatoi(nv)) ? (F |	C_FLAG)	: (F & ~C_FLAG);
		} else if (strncmp(s, "a'", 2) == 0) {
			printf("A' = %02x : ", A_);
			fgets(nv, sizeof(nv), stdin);
			A_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "f'", 2) == 0) {
			printf("F' = %02x : ", F_);
			fgets(nv, sizeof(nv), stdin);
			F_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "b'", 2) == 0) {
			printf("B' = %02x : ", B_);
			fgets(nv, sizeof(nv), stdin);
			B_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "c'", 2) == 0) {
			printf("C' = %02x : ", C_);
			fgets(nv, sizeof(nv), stdin);
			C_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "d'", 2) == 0) {
			printf("D' = %02x : ", D_);
			fgets(nv, sizeof(nv), stdin);
			D_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "e'", 2) == 0) {
			printf("E' = %02x : ", E_);
			fgets(nv, sizeof(nv), stdin);
			E_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "h'", 2) == 0) {
			printf("H' = %02x : ", H_);
			fgets(nv, sizeof(nv), stdin);
			H_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "l'", 2) == 0) {
			printf("L' = %02x : ", L_);
			fgets(nv, sizeof(nv), stdin);
			L_ = exatoi(nv)	& 0xff;
		} else if (strncmp(s, "i", 1) == 0) {
			printf("I = %02x : ", I);
			fgets(nv, sizeof(nv), stdin);
			I = exatoi(nv) & 0xff;
		} else if (strncmp(s, "a", 1) == 0) {
			printf("A = %02x : ", A);
			fgets(nv, sizeof(nv), stdin);
			A = exatoi(nv) & 0xff;
		} else if (strncmp(s, "f", 1) == 0) {
			printf("F = %02x : ", F);
			fgets(nv, sizeof(nv), stdin);
			F = exatoi(nv) & 0xff;
		} else if (strncmp(s, "b", 1) == 0) {
			printf("B = %02x : ", B);
			fgets(nv, sizeof(nv), stdin);
			B = exatoi(nv) & 0xff;
		} else if (strncmp(s, "c", 1) == 0) {
			printf("C = %02x : ", C);
			fgets(nv, sizeof(nv), stdin);
			C = exatoi(nv) & 0xff;
		} else if (strncmp(s, "d", 1) == 0) {
			printf("D = %02x : ", D);
			fgets(nv, sizeof(nv), stdin);
			D = exatoi(nv) & 0xff;
		} else if (strncmp(s, "e", 1) == 0) {
			printf("E = %02x : ", E);
			fgets(nv, sizeof(nv), stdin);
			E = exatoi(nv) & 0xff;
		} else if (strncmp(s, "h", 1) == 0) {
			printf("H = %02x : ", H);
			fgets(nv, sizeof(nv), stdin);
			H = exatoi(nv) & 0xff;
		} else if (strncmp(s, "l", 1) == 0) {
			printf("L = %02x : ", L);
			fgets(nv, sizeof(nv), stdin);
			L = exatoi(nv) & 0xff;
		} else
			printf("can't change register %s\n", nv);
		print_head();
		print_reg();
	}
}

/*
 *	Output header for the CPU registers
 */
static print_head()
{
	printf("\nPC   A  SZHPNC I  IFF BC   DE   HL   A'F' B'C' D'E' H'L' IX   IY   SP\n");
}

/*
 *	Output all CPU registers
 */
static print_reg()
{
	printf("%04x %02x ", PC	- ram, A);
	printf("%c", F & S_FLAG	? '1' :	'0');
	printf("%c", F & Z_FLAG	? '1' :	'0');
	printf("%c", F & H_FLAG	? '1' :	'0');
	printf("%c", F & P_FLAG	? '1' :	'0');
	printf("%c", F & N_FLAG	? '1' :	'0');
	printf("%c", F & C_FLAG	? '1' :	'0');
	printf(" %02x ", I);
	printf("%c", IFF & 1 ? '1' : '0');
	printf("%c", IFF & 2 ? '1' : '0');
	printf("  %02x%02x %02x%02x %02x%02x %02x%02x %02x%02x %02x%02x %02x%02x %04x %04x %04x\n",
		 B, C, D, E, H,	L, A_, F_, B_, C_, D_, E_, H_, L_, IX, IY, STACK - ram);
}

/*
 *	Software breakpoints
 */
static do_break(s)
register char *s;
{
#ifndef	SBSIZE
	puts("Sorry, no breakpoints available");
	puts("Please recompile with SBSIZE defined in sim.h");
#else
	register int i;

	if (!break_flag) {
		puts("Can't use softbreaks with -h option.");
		return;
	}
	if (*s == '\n')	{
		puts("No Addr Pass  Counter");
		for (i = 0; i <	SBSIZE;	i++)
			if (soft[i].sb_pass)
				printf("%02d %04x %05d %05d\n",	i,
				soft[i].sb_adr,soft[i].sb_pass,soft[i].sb_passcount);
		return;
	}
	if (isxdigit(*s)) {
		i = atoi(s++);
		if (i >= SBSIZE) {
			printf("breakpoint %d not available\n",	i);
			return;
		}
	} else {
		i = sb_next++;
		if (sb_next == SBSIZE)
			sb_next	= 0;
	}
	while (isspace(*s))
		s++;
	if (*s == 'c') {
		*(ram +	soft[i].sb_adr)	= soft[i].sb_oldopc;
		memset((char *)	&soft[i], 0, sizeof(struct softbreak));
		return;
	}
#if defined(COHERENT) && !defined(_I386)
	if (exatoi(s) < 0) {
		puts(adr_err);
		return;
	}
#endif
	if (soft[i].sb_pass)
		*(ram +	soft[i].sb_adr)	= soft[i].sb_oldopc;
	soft[i].sb_adr = exatoi(s);
	soft[i].sb_oldopc = *(ram + soft[i].sb_adr);
	*(ram +	soft[i].sb_adr)	= 0x76;
	while (!iscntrl(*s) && !ispunct(*s))
		s++;
	if (*s != ',')
		soft[i].sb_pass	= 1;
	else
		soft[i].sb_pass	= exatoi(++s);
	soft[i].sb_passcount = 0;
#endif
}

/*
 *	History
 */
static do_hist(s)
register char *s;
{
#ifndef	HISIZE
	puts("Sorry, no history available");
	puts("Please recompile with HISIZE defined in sim.h");
#else
	register int i,	l, b, e, c, sa;

	while (isspace(*s))
		s++;
	switch (*s) {
	case 'c':
		memset((char *)	his, 0,	sizeof(struct history) * HISIZE);
		h_next = 0;
		h_flag = 0;
		break;
	default:
		if ((h_next == 0) && (h_flag ==	0)) {
			puts("History memory is empty");
			break;
		}
		e = h_next;
		b = (h_flag) ? h_next +	1 : 0;
		l = 0;
		while (isspace(*s))
			s++;
		if (*s)
			sa = exatoi(s);
		else
			sa = -1;
		for (i = b; i != e; i++) {
			if (i == HISIZE)
				i = 0;
			if (sa != -1)
				if (his[i].h_adr < sa)
					continue;
				else
					sa = -1;
			printf("%04x AF=%04x BC=%04x DE=%04x HL=%04x IX=%04x IY=%04x SP=%04x\n",
			       his[i].h_adr, his[i].h_af, his[i].h_bc,
			       his[i].h_de, his[i].h_hl, his[i].h_ix,
			       his[i].h_iy, his[i].h_sp);
			l++;
			if (l == 20) {
				l = 0;
				printf("q = quit, else continue: ");
				c = getkey();
				putchar('\n');
				if (toupper(c) == 'Q')
					break;
			}
		}
		break;
	}
#endif
}

/*
 *	Runtime measurement by counting the executed T states
 */
static do_count(s)
register char *s;
{
#ifndef	WANT_TIM
	puts("Sorry, no t-state count available");
	puts("Please recompile with WANT_TIM defined in sim.h");
#else
	while (isspace(*s))
		s++;
	if (*s == '\0')	{
		puts("start  stop  status  T-states");
		printf("%04x   %04x    %s   %lu\n",
		t_start	- ram, t_end - ram, t_flag ? "on ": "off", t_states);
	} else {
		t_start	= ram +	exatoi(s);
		while (*s != ',' && *s != '\0')
			s++;
		if (*s)
			t_end =	ram + exatoi(++s);
		t_states = 0L;
		t_flag = 0;
	}
#endif
}

#if !defined(COHERENT) || defined(_I386)
/*
 *	Calculate the clock frequency of the emulated CPU:
 *	into memory locations 0000H to 0002H the following
 *	code will be stored:
 *		LOOP: JP LOOP
 *	It uses 10 T states for each execution. A 3 secound
 *	timer is started and then the CPU. For every opcode
 *	fetch the R register is incremented by one and after
 *	the timer is down and stopps the emulation, the clock
 *	speed of the CPU is calculated with:
 *		f = R /	300000
 */
static do_clock()
{
	static BYTE save[3];
	int timeout();
	unsigned alarm();

	save[0]	= *(ram	+ 0x0000);	/* save memory locations */
	save[1]	= *(ram	+ 0x0001);	/* 0000H - 0002H */
	save[2]	= *(ram	+ 0x0002);
	*(ram +	0x0000)	= 0xc3;		/* store opcode JP 0000H at address */
	*(ram +	0x0001)	= 0x00;		/* 0000H */
	*(ram +	0x0002)	= 0x00;
	PC = ram + 0x0000;		/* set PC to this code */
	R = 0L;				/* clear refresh register */
	cpu_state = CONTIN_RUN;		/* initialize CPU */
	cpu_error = NONE;
	signal(SIGALRM,	timeout);	/* initialize timer interrupt handler */
	alarm(3);			/* start 3 secound timer */
	cpu();				/* start CPU */
	*(ram +	0x0000)	= save[0];	/* restore memory locations */
	*(ram +	0x0001)	= save[1];	/* 0000H - 0002H */
	*(ram +	0x0002)	= save[2];
	if (cpu_error == NONE)
		printf("clock frequency = %5.2f Mhz\n",	((float) R) / 300000.0);
	else
		puts("Interrupted by user");
}

/*
 *	This function is the signal handler for the timer interrupt.
 *	The CPU emulation is stopped here.
 */
static timeout()
{
	cpu_state = STOPPED;
}
#endif

/*
 *	Output informations about compiling options
 */
static do_show()
{
	register int i;

	printf("Release: %s\n",	RELEASE);
#ifdef HISIZE
	i = HISIZE;
#else
	i = 0;
#endif
	printf("No. of entrys in history memory: %d\n",	i);
#ifdef SBSIZE
	i = SBSIZE;
#else
	i = 0;
#endif
	printf("No. of software breakpoints: %d\n", i);
#ifdef WANT_SPC
	i = 1;
#else
	i = 0;
#endif
	printf("Stackpointer turn around %schecked\n", i ? "" :	"not ");
#ifdef WANT_PCC
	i = 1;
#else
	i = 0;
#endif
	printf("Programcounter turn around %schecked\n", i ? ""	: "not ");
#ifdef WANT_TIM
	i = 1;
#else
	i = 0;
#endif
	printf("T-State counting %spossible\n",	i ? "" : "im");
#ifdef CNTL_C
	i = 1;
#else
	i = 0;
#endif
	printf("CPU simulation %sstopped on cntl-c\n", i ? "" :	"not ");
#ifdef CNTL_BS
	i = 1;
#else
	i = 0;
#endif
	printf("CPU simulation %sstopped on cntl-\\\n",	i ? "" : "not ");
}

/*
 *	Read a file into the memory of the emulated CPU.
 *	The following file formats are supported:
 *
 *		binary images with Mostek header
 */
static do_getfile(s)
register char *s;
{
	char fn[LENCMD];
	BYTE fileb[5];
	register char *pfn = fn;
	int fd;
	long lseek();

	while (isspace(*s))
		s++;
	while (*s != ',' && *s != '\n' && *s !=	'\0')
		*pfn++ = *s++;
	*pfn = '\0';
	if (strlen(fn) == 0) {
		puts("no input file given");
		return 1;
	}
	if ((fd	= open(fn, O_RDONLY)) == -1) {
		printf("can't open file %s\n", fn);
		return 1;
	}
	if (*s == ',')
		wrk_ram	= ram +	exatoi(++s);
	else
		wrk_ram	= NULL;
	read(fd, (char *) fileb, 5); /*	read first 5 bytes of file */
	if (*fileb == (BYTE) 0xff) {	  /* Mostek header ? */
		lseek(fd, 0l, 0);
		return (load_mos(fd, fn));
	}
	else {
		printf("unkown format, can't load file %s\n", fn);
		close(fd);
		return 1;
	}
}

/*
 *	Loader for binary images with Mostek header.
 *	Format of the first 3 bytes:
 *
 *	0xff ll	lh
 *
 *	ll = load address low
 *	lh = load address high
 */
static load_mos(fd, fn)
int fd;
char *fn;
{
	BYTE fileb[3];
	unsigned count,	readed;
	int rc = 0;

	read(fd, (char *) fileb, 3);	/* read load address */
	if (wrk_ram == NULL)		/* and set if not given */
		wrk_ram	= ram +	(fileb[2] * 256	+ fileb[1]);
#if !defined(COHERENT) || defined(_I386)
	count =	ram + 32767 - wrk_ram;
	if ((readed = read(fd, (char *)	wrk_ram, count)) == count) {
		puts("Too much to load, stopped at 0x7fff");
		rc = 1;
	}
#else
	count =	ram + 65535 - wrk_ram;
	if ((readed = read(fd, (char *)	wrk_ram, count)) == count) {
		puts("Too much to load, stopped at 0xffff");
		rc = 1;
	}
#endif
	close(fd);
	printf("Loader statistics for file %s:\n", fn);
	printf("START : %04x\n", wrk_ram - ram);
	printf("END   : %04x\n", wrk_ram - ram + readed	- 1);
	printf("LOADED: %04x\n", readed);
	PC = wrk_ram;
	return rc;
}

/*
 *	Call system function from simulator
 */
static do_unix(s)
register char *s;
{
	int_off();
	system(s);
	int_on();
}

/*
 *	Output help text
 */
static do_help()
{
	puts("r filename[,address]      read object into memory");
	puts("d [address]               dump memory");
#if !defined(COHERENT) || defined(_I386)
	puts("l [address]               list memory");
#endif
	puts("m [address]               modify memory");
	puts("f address,count,value     fill memory");
#if !defined(COHERENT) || defined(_I386)
	puts("v from,to,count           move memory");
#endif
	puts("p address                 show/modify port");
	puts("g [address]               run program");
	puts("t [count]                 trace program");
	puts("return                    single step program");
	puts("x [register]              show/modify register");
	puts("x f<flag>                 modify flag");
	puts("b[no] address[,pass]      set soft breakpoint");
	puts("b                         show soft breakpoints");
	puts("b[no] c                   clear soft breakpoint");
	puts("h [address]               show history");
	puts("h c                       clear history");
	puts("z start,stop              set trigger adr for t-state count");
	puts("z                         show t-state count");
#if !defined(COHERENT) || defined(_I386)
	puts("c                         measure clock frequency");
#endif
	puts("s                         show settings");
	puts("! command                 execute UNIX command");
	puts("q                         quit");
}

/*
 *	Error handler after CPU is stopped
 */
static cpu_err_msg()
{
	switch (cpu_error) {
	case NONE:
		break;
	case OPHALT:
		printf("HALT Op-Code reached at %04x\n", PC-ram-1);
		break;
	case IOTRAP:
		printf("I/O Trap at %04x\n", PC-ram);
		break;
	case OPTRAP1:
		printf("Op-code trap at %04x %02x\n", PC-1-ram,	*(PC-1));
		break;
	case OPTRAP2:
		printf("Op-code trap at %04x %02x %02x\n", PC-2-ram,
		       *(PC-2),	*(PC-1));
		break;
	case OPTRAP4:
		printf("Op-code trap at %04x %02x %02x %02x %02x\n",
		PC-4-ram, *(PC-4), *(PC-3), *(PC-2), *(PC-1));
		break;
	case USERINT:
		puts("User Interrupt");
		break;
	default:
		printf("Unknown error %d\n", cpu_error);
		break;
	}
}
