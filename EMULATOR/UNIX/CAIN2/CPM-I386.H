/*
cpm-i386

Written by D'Arcy J.M. Cain
darcy@druid

This file is the header used by the CP/M emulator when running under
the following machine(s):

	System V Rel 3.2 or 4.0 on Intel 80386 processor

Link this file to cpm.h on the above system.  Other entries will be added
as they are tested.

To use this program on systems which differ from the above in significant
ways, a header must be created such that the Z80 registers can be accessed
using the following register names:
	A, B, C, D, E, H, L, BC, DE, HL, IX, IY, SP, PC, AF and FLAGS
In addition the following flags sould be available:
	CARRY, BCD, PARITY, HALF_CARRY, ZERO and SIGN
Also the HL, SP, IX and IY registers should have a H and L version for
accessing half-words and TEMP should be a scratch variable accessed the
same way.  See below for examples.

There should also be a variable IFF and an array of 0x10000 (65,536) bytes
called ram.

The two variables psw_bank and gr_bank should allow register context
switching for the AF register and the general registers

Note:  If the manifest constant USUAL_MICROSOFT_STUPIDITY is defined then
extra code is included to allow Microsoft BASIC and other programs which
use the same stupidity to work.  The problem is that Microsoft, rather
than CALLing BIOS+CONOUT and BIOS+LIST and who knows what else, looks at
the BIOS jump table and roots out the targets for various jumps and self
modifies itself to CALL those locations directly.  My fix is to have actual
jumps in those locations but it jumps to itself.  If this is not required
then the space is available to the running program.

*/

#define	USUAL_MICROSOFT_STUPIDITY

#ifdef	COMPILE_TEST
#define	CPM_DEBUG
#endif

typedef	unsigned char	byte;
typedef unsigned short	word;
/* We use unsigned short to guarantee two byte words and roll-over */
/* use caution on other architectures (and even other compilers) */

#define	lonyb(v)	(v & 0xf)
#define	hinyb(v)	((v >> 4) & 0xf)

typedef union {
	word	af;
	struct {
		byte	flags, a;
	} b;
	struct {
		unsigned int	carry:1;
		unsigned int	bcd:1;
		unsigned int	parity:1;
		unsigned int	x1:1;
		unsigned int	half:1;
		unsigned int	x2:1;
		unsigned int	zero:1;
		unsigned int	sign:1;
	} bits;
} ACC;

typedef union {
	struct {
		word	bc;
		word	de;
		word	hl;
	} w;
	struct {
		byte	c, b;
		byte	e, d;
		byte	l, h;
	} b;
} GR;

typedef union {
	unsigned char	half[2];
	unsigned short	whole;
} REG;

#define	TEMPH	(reg.half[1])
#define	TEMPL	(reg.half[0])
#define	TEMP	(reg.whole)
#define	SPH		(sp.half[1])
#define	SPL		(sp.half[0])
#define	SP		(sp.whole)
#define IXH		(ix.half[1])
#define IXL		(ix.half[0])
#define IX		(ix.whole)
#define IYH		(iy.half[1])
#define IYL		(iy.half[0])
#define IY		(iy.whole)

#ifdef	CPM_DATA
ACC		acc[2];
GR		gr[2];
word	PC;
byte	R, IV;
int		gr_bank = 0, acc_bank = 0, IFF = 1;
REG		reg, sp, ix, iy;

#ifdef	COMPILE_TEST
byte	ram[0x10000] = {
	0x00,				/* 0000: nop */
	0x21, 0x00, 0x10,	/* 0001: ld hl, 1000h */
	0xe5,				/* 0004: push hl */
	0x3e, 0xbb,			/* 0005: ld a, 0bbh */
	0x87,				/* 0007: add a, a */
	0x8f,				/* 0008: adc a, a */
	0x3d,				/* 0009: dec a */
	0x2f,				/* 000a: cpl */
	0xb8,				/* 000b: cp b */
	0xcc, 0x14, 0x00,	/* 000c: call z, 0014h */
	0xbf,				/* 000f: cp a */
	0xcc, 0x14, 0x00,	/* 0010: call z, 0014h */
	0x00,				/* 0013: nop */
	0xc3, 0x19, 0x00,	/* 0014: jp 0019h */
	0x18, 0x03,			/* 0x17: jr 001bh */
	0x18, 0xfd,			/* 0x19: jr 0014h */
	0xc9,				/* 001b: ret */
	0x00 };				/* 0015: nop */
#define		TEST_SIZE	24
#else
byte	ram[0x10000];
#endif

byte	page_zero[] = {
	0xc3, 0x03, 0xff,	/* JP BIOS+3 */
	0x00, 0x00,			/* reserved */
	0xc3, 0xc0, 0xfe,	/* JP BDOS */
};

#else
extern ACC	acc[];
extern GR	gr[];
extern word	PC;
extern byte	R, IV, ram[];
extern int	gr_bank, acc_bank, IFF;
extern REG	reg, sp, ix, iy;
#endif

#define		AF			(acc[acc_bank].af)
#define		A			(acc[acc_bank].b.a)
#define		FLAGS		(acc[acc_bank].b.flags)
#define		CARRY		(acc[acc_bank].bits.carry)
#define		BCD			(acc[acc_bank].bits.bcd)
#define		PARITY		(acc[acc_bank].bits.parity)
#define		OVERFLOW	(acc[acc_bank].bits.parity)
#define		HALF_CARRY	(acc[acc_bank].bits.half)
#define		ZERO		(acc[acc_bank].bits.zero)
#define		SIGN		(acc[acc_bank].bits.sign)

#define		B			(gr[gr_bank].b.b)
#define		C			(gr[gr_bank].b.c)
#define		D			(gr[gr_bank].b.d)
#define		E			(gr[gr_bank].b.e)
#define		H			(gr[gr_bank].b.h)
#define		L			(gr[gr_bank].b.l)
#define		BC			(gr[gr_bank].w.bc)
#define		DE			(gr[gr_bank].w.de)
#define		HL			(gr[gr_bank].w.hl)

#define		BDOS		0xfec0
#define		BIOS		0xff00
#define		bios(x)		(BIOS + (x * 3))

#define		MAX_DRIVES	16

int			decode(void);
const char	*dasm(const byte *buf);
