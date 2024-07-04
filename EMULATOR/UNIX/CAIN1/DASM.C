/*
dasm

CP/M emulator - instruction disassembler
Written by D'Arcy J.M. Cain
darcy@druid

*/

#include	<stdio.h>
#include	<string.h>
#include	"cpm.h"

#define		get_prog_word(buf)	(buf[1] + (buf[2] << 8))
#define		get_prog_byte(buf)	(*buf)

static char		*get_b_reg(int reg)
{
	switch(reg & 0x07)
	{
		case 7:		return("A");
		case 6:		return("(HL)");
		case 0:		return("B");
		case 1:		return("C");
		case 2:		return("D");
		case 3:		return("E");
		case 4:		return("H");
		case 5:		return("L");
	}

	return(NULL);
}

static char		*get_w_reg(int reg)
{
	switch (reg & 0x03)
	{
		case 2:		return("HL");
		case 1:		return("DE");
		case 0:		return("BC");
		case 3:		return("SP");
	}

	return(NULL);
}

static char		*get_s_reg(int reg)
{
	switch (reg & 0x03)
	{
		case 2:		return("HL");
		case 1:		return("DE");
		case 0:		return("BC");
		case 3:		return("AF");
	}

	return(NULL);
}

static int		relative(int r)
{
	if (r & 0x80)
		r |= -256;

	return(PC + r + 2);
}

static char		*condition(int word)
{
	switch (word & 0x07)
	{
		case 0:		return("NZ");
		case 1:		return("Z");
		case 2:		return("NC");
		case 3:		return("C");
		case 4:		return("PO");
		case 5:		return("PE");
		case 6:		return("P");
		case 7:		return("M");
	}

	return("\a* * * Internal error (condition()) * * *");
}

const char 	*dasm(const byte *buf)
{
	static char	str[32];
	char		s[32];

	switch (*buf & 0xc0)				/* get class of opcode */
	{
		case 0x40:						/* data transfer */
			if (*buf == 0x76)			/* HALT - special case */
				return("HALT");

			sprintf(str, "LD\t%s, %s", get_b_reg(*buf >> 3), get_b_reg(*buf));
			return(str);

		case 0x80:						/* 8 bit math & logic */
			strcpy(s, get_b_reg(*buf));
			strcpy(str, "* * * Internal error * * *");

math_immediate:							/* comes from misc instructions */
			switch ((*buf >> 3) & 7)		/* logic op */
			{
				case 1:					/* ADC */
					sprintf(str, "ADC\tA, %s", s);
					break;

				case 0:					/* ADD */
					sprintf(str, "ADD\tA, %s", s);
					break;
	
				case 3:					/* SBC */
					sprintf(str, "SBC\tA, %s", s);
					break;

				case 2:					/* SUB */
					sprintf(str, "SUB\tA, %s", s);
					break;

				case 4:					/* AND */
					sprintf(str, "AND\tA, %s", s);
					break;

				case 5:					/* XOR */
					sprintf(str, "XOR\tA, %s", s);
					break;

				case 6:					/* OR */
					sprintf(str, "OR\tA, %s", s);
					break;

				case 7:					/* CP */
					sprintf(str, "CP\tA, %s", s);
					break;
			}							/* end - logic op */

			return(str);

		case 0xc0:						/* Misc */
			if ((*buf & 0x07) == 0x06)
			{
				sprintf(s, "0%02.2xH", buf[1]);
				goto math_immediate;	/* sometimes they're necessary */
			}

			if ((*buf & 0x0f) == 1)		/* POP */
			{
				sprintf(str, "POP\t%s", get_s_reg(*buf >> 4));
				return(str);
			}

			if ((*buf & 0x0f) == 5)		/* PUSH */
			{
				sprintf(str, "PUSH\t%s", get_s_reg(*buf >> 4));
				return(str);
			}


			switch (*buf & 0x07)		/* BRANCH */
			{
				case 0:					/* RET cc */
					sprintf(str, "RET\t%s", condition(*buf >> 3));
					return(str);

				case 2:					/* JP cc */
					sprintf(str, "JP\t%s, 0%02.2x%02.2xH",
								condition(*buf >> 3), buf[2], buf[1]);
					return(str);

				case 4:					/* CALL cc */
					sprintf(str, "CALL\t%s, 0%02.2x%02.2xH",
								condition(*buf >> 3), buf[2], buf[1]);
					return(str);

				case 7:					/* RST n */
					sprintf(str, "RST\t%d", (*buf >> 3) & 0x07);
					return(str);
			}							/* end - BRANCH */

			switch (*buf)				/* misc */
			{
				case 0xcd:				/* CALL */
					sprintf(str, "CALL\t0%02.2x%02.2xH", buf[2], buf[1]);
					return(str);

				case 0xc3:				/* JP */
					sprintf(str, "JP\t0%02.2x%02.2xH", buf[2], buf[1]);
					return(str);

				case 0xc9:				/* RET */
					sprintf(str, "RET");
					return(str);

				case 0xeb:				/* EX DE, HL */
					return("EX\tDE, HL");

				case 0xe9:				/* JP (HL) */
					return("JP\t(HL)");

				case 0xe3:				/* EX (SP), HL */
					return("EX\t(SP), HL");

				case 0xf9:				/* LD SP, HL */
					return("LD\tSP, HL");

				case 0xf3:				/* DI */
					return("DI");

				case 0xfb:				/* EI */
					return("EI");
			}								/* misc */

			sprintf(str, "Unrecognized command (0x%02.2x)", *buf);
			return(str);

		case 0:
			switch (*buf & 0x07)			/* misc data (3) */
			{
				case 4:						/* INC byte */
					sprintf(str, "INC\t%s", get_b_reg(*buf >> 3));
					return(str);

				case 5:						/* DEC byte */
					sprintf(str, "DEC\t%s", get_b_reg(*buf >> 3));
					return(str);

				case 6:						/* LD byte immediate */
					sprintf(str, "LD\t%s, 0%02.2xH",
								get_b_reg(*buf >> 3), buf[1]);
					return(str);
			}								/* end - misc data (3) */

			switch (*buf & 0x0f)			/* misc data (4) */
			{
				case 1:						/* LD word immediate */
					sprintf(str, "LD\t%s, 0%02.2x%02.2xH",
								get_w_reg(*buf >> 4), buf[2], buf[1]);
					return(str);

				case 0x03:					/* INC word */
					sprintf(str, "INC\t%s", get_w_reg(*buf >> 4));
					return(str);

				case 0x0b:					/* DEC word */
					sprintf(str, "DEC\t%s", get_w_reg(*buf >> 4));
					return(str);

				case 0x09:					/* ADD HL, ss */
					sprintf(str, "ADD\tHL, %s", get_w_reg(*buf >> 4));
					return(str);
			}								/* end - misc date (4) */

			switch (*buf)					/* misc data */
			{
				case 0:						/* NOP */
					return("NOP");

				case 0x02:					/* LD (BC), A */
					return("LD\t(BC), A");

				case 0x10:
					sprintf(str, "DJNZ\t0%04.4xH", relative(buf[1]));
					return(str);

				case 0x20:
					sprintf(str, "JR\tNZ, 0%04.4xH", relative(buf[1]));
					return(str);

				case 0x30:
					sprintf(str, "JR\tNC, 0%04.4xH", relative(buf[1]));
					return(str);

				case 0x18:
					sprintf(str, "JR\t, 0%04.4xH", relative(buf[1]));
					return(str);

				case 0x28:
					sprintf(str, "JR\tZ, 0%04.4xH", relative(buf[1]));
					return(str);

				case 0x38:
					sprintf(str, "JR\tC, 0%04.4xH", relative(buf[1]));
					return(str);

				case 0x12:					/* LD (DE), A */
					return("LD\t(DE), A");

				case 0x22:					/* LD (nn), HL */
					sprintf(str, "LD\t(0%02.2x%02.2xH), HL", buf[2], buf[1]);
					return(str);

				case 0x32:					/* LD (nn), A */
					sprintf(str, "LD\t(0%02.2x%02.2xH), A", buf[2], buf[1]);
					return(str);

				case 0x0a:					/* LD A, (BC) */
					return("LD\tA, (BC)");

				case 0x1a:					/* LD A, (DE) */
					return("LD\tA, (DE)");

				case 0x2a:					/* LD HL, (nn) */
					sprintf(str, "LD\tHL, (0%02.2x%02.2xH)", buf[2], buf[1]);
					return(str);

				case 0x3a:					/* LD A, (nn) */
					sprintf(str, "LD\tA, (0%02.2x%02.2xH)", buf[2], buf[1]);
					return(str);

				case 7:						/* RLCA */
					return("RLCA");

				case 0x0f:					/* RRCA */
					return("RRCA");

				case 0x17:					/* RLA */
					return("RLA");

				case 0x1f:					/* RRA */
					return("RRA");

				case 0x27:					/* DAA */
					return("DAA");

				case 0x2f:					/* CPL */
					return("CPL");

				case 0x37:					/* SCF */
					return("SCF");

				case 0x3f:					/* CCF */
					return("CCF");
			}								/* end - misc date */

			return("* * * Internal error * * *");
	}										/* end class */

	return("* * * Internal error * * *");
}
