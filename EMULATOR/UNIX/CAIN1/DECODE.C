/*
 * execute()
 *
 * There are 256 possible opcodes.  The switch statement selects one.
 * $Header: /g/zmob/zrun/RCS/execute.c,v 1.1.1.5 84/04/19 17:51:14 bennet Exp $
 */

#include	"cpm.h"

static byte	partab[256]=		/* Parity table, 1=even */
{
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	0,1,1,0,1,0,0,1, 1,0,0,1,0,1,1,0,
	1,0,0,1,0,1,1,0, 0,1,1,0,1,0,0,1,
};

static byte	setmask[] = { 1, 2, 4, 8, 16, 32, 64, 128 };
static byte	resmask[] = { ~1, ~2, ~4, ~8, ~16, ~32, ~64, ~128 };

int		pop(void)
{
	long	r = ram[SP++];
	return(r + (ram[SP++] << 8));
}

void	push(int v)
{
	ram[--SP] = v >> 8;
	ram[--SP] = v & 0xff;
}

int		decode(void)
{
	byte	*ptr;
	long	a, s, s1;
	byte	opcode = ram[PC++];

	if (PC >= BDOS)
	{
		PC = pop();
		return(0);
	}

	switch(opcode)
	{
	case 0:			/* 00 NOP */
	when 1:			/* 01 LD BC,nn */
		C = ram[PC++];
		B = ram[PC++];
	when 2:			/* 02 LD (BC),A */
		ram[BC] = A;
	when 3:			/* 03 INC BC */
		++BC;
	when 4:			/* 04 INC B */
		HALF_CARRY = (lonyb(B) == 0xf);
		++B;
		SIGN = B >> 7;
		ZERO = B == 0;
		PARITY = B == 0x80;
		BCD = 0;
	when 5:			/* 05 DEC B */
		HALF_CARRY = lonyb(B) != 0;
		--B;
		SIGN = B >> 7;
		ZERO = B == 0;
		PARITY = B == 0x7f;
		BCD = 1;
	when 6:			/* 06 LD B,n */
		B = ram[PC++];
	when 7:			/* 07 RLCA */
		HALF_CARRY = BCD = 0;
		CARRY = A >> 7;
		A = (A << 1);
		if (CARRY) ++A;
	when 8:			/* 08 EX AF,AF' */
		acc_bank = acc_bank ? 0 : 1;
	when 9:			/* 09 ADD HL,BC */
		s = BC;
		a = (HL & 0xfff) + (s & 0xfff);
		s += HL;
		HL = s;
		BCD = 0;
		CARRY = s >> 16;
		HALF_CARRY = a >> 12;
	when 10:		/* 0a LD A,(BC) */
		A = ram[BC];
	when 11:		/* 0b DEC BC */
		--BC;
	when 12:		/* 0c INC C */
		HALF_CARRY = lonyb(C) == 0xf;
		++C;
		SIGN = C >> 7;
		ZERO = C == 0;
		PARITY = C == 0x80;
		BCD = 0;
	when 13:		/* 0d DEC C */
		HALF_CARRY = lonyb(C) != 0;
		--C;
		SIGN = C >> 7;
		ZERO = C == 0;
		PARITY = C == 0x7f;
		BCD = 1;
	when 14:		/* 0e LD C,n */
		C = ram[PC++];
	when 15:		/* 0f RRCA */
		BCD = HALF_CARRY = 0;
		CARRY = A;
		A = (A >> 1) | (CARRY ? 128 : 0);
	when 16:		/* 10 DJNZ e */
		s = (signed char)(ram[PC++] + 1);
		if (--B) PC += s;
	when 17:		/* 11 LD DE,nn */
		E = ram[PC++];
		D = ram[PC++];
	when 18:		/* 12 LD (DE),A */
		ram[DE] = A;
	when 19:		/* 13 INC DE */
		++DE;
	when 20:		/* 14 INC D */
		HALF_CARRY = lonyb(D) == 0xf;
		++D;
		SIGN = D >> 7;
		ZERO = D == 0;
		PARITY = D == 0x80;
		BCD = 0;
	when 21:		/* 15 DEC D */
		HALF_CARRY = lonyb(D) != 0;
		--D;
		SIGN = D >> 7;
		ZERO = D == 0;
		PARITY = D == 0x7f;
		BCD = 1;
	when 22:		/* 16 LD D,n */
		D = ram[PC++];
	when 23:		/* 17 RLA */
		s = A << 1;
		A = s | CARRY;
		CARRY = s >> 8;
		BCD = HALF_CARRY = 0;
	when 24:		/* 18 JR e */
		PC += (signed char)(ram[PC] + 1);
	when 25:		/* 19 ADD HL,DE */
		s = DE;
		a = (HL & 0xfff) + (s & 0xfff);
		s += HL;
		HL = s;
		BCD = 0;
		CARRY = s >> 16;
		HALF_CARRY = a >> 12;
	when 26:		/* 1a LD A,(DE) */
		A = ram[DE];
	when 27:		/* 1b DEC DE */
		--DE;
	when 28:		/* 1c INC E */
		HALF_CARRY = lonyb(E) == 0xf;
		++E;
		SIGN = E >> 7;
		ZERO = E == 0;
		PARITY = E == 0x80;
		BCD = 0;
	when 29:		/* 1d DEC E */
		HALF_CARRY = lonyb(E) != 0;
		--E;
		SIGN = E >> 7;
		ZERO = E == 0;
		PARITY = E == 0x7f;
		BCD = 1;
	when 30:		/* 1e LD E,n */
		E = ram[PC++];
	when 31:		/* 1f RRA */
		CARRY = (s = A | (CARRY << 8));
		A = s >> 1;
		BCD = HALF_CARRY = 0;
	when 32:		/* 20 JR NZ,e */
		if (ZERO) ++PC;
		else PC += (signed char)(ram[PC] + 1);
	when 33:		/* 21 LD HL,nn */
		L = ram[PC++];
		H = ram[PC++];
	when 34:		/* 22 LD (nn),HL */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		ram[TEMP] = L;
		ram[TEMP + 1] = H;
	when 35:		/* 23 INC HL */
		++HL;
	when 36:		/* 24 INC H */
		HALF_CARRY = lonyb(H) == 0xf;
		++H;
		SIGN = H >> 7;
		ZERO = H == 0;
		PARITY = H == 0x80;
		BCD = 0;
	when 37:		/* 25 DEC H */
		HALF_CARRY = lonyb(H) != 0;
		--H;
		SIGN = H >> 7;
		ZERO = H == 0;
		PARITY = H == 0x7f;
		BCD = 1;
	when 38:		/* 26 LD H,n */
		H = ram[PC++];
	when 39:		/* 27 DAA */
		s = A & 0x0f;
		a = (A >> 4) & 0x0f;
		s1 = 0;

		if (BCD)
		{
			if (CARRY)
			{
				if (HALF_CARRY)
					s1 = ((a > 5) && (s > 5)) ? 0x9a : 0;
				else
					s1 = ((a > 6) && (s < 10)) ? 0xa0 : 0;
			}
			else
				if(HALF_CARRY)
					s1 = ((a < 9) && (s > 5)) ? 0xfa : 0;
		}
		else
		{
			if (CARRY)
			{
				if(HALF_CARRY)
					s1 = ((a < 4) && (s < 4)) ? 0x66 : 0;
				else if (a < 3)
					s1 = (s < 10) ? 0x60 : 0x66;
			}
			else
			{
				if(HALF_CARRY)
				{
					if (s < 4)
						if (a > 9)
						{
							s1 = 0x66;
							CARRY = 1;
						}
						else s1 = 0x06;
				}
				else
				{
					if ((a > 8) && (s > 9))
					{
						s1 = 0x66;
						CARRY = 1;
					}
					else if ((a > 9) && (s < 10))
					{
						s1 = 0x60;
						CARRY = 1;
					}
					else if ((a < 10) && (s < 10))
							;
					else if ((a < 9) && (s > 9))
						s1 = 6;
				}
			}
		}

		HALF_CARRY = ((int)(A) + (int)(s1)) > 0xf;
		A += s1;
		SIGN = A >> 7;
		ZERO = (A == 0);
		PARITY = partab[A];
	when 40:		/* 28 JR Z,e */
		if (ZERO) PC += (signed char)(ram[PC] + 1);
		else ++PC;
	when 41:		/* 29 ADD HL,HL */
		s = HL;
		a = (HL & 0xfff) + (s & 0xfff);
		s += HL;
		HL = s;
		BCD = 0;
		CARRY = s >> 16;
		HALF_CARRY = a >> 12;
	when 42:		/* 2a LD HL,(nn) */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		L = ram[TEMP];
		H = ram[TEMP + 1];
	when 43:		/* 2b DEC HL */
		--HL;
	when 44:		/* 2c INC L */
		HALF_CARRY = lonyb(L) == 0xf;
		++L;
		SIGN = L >> 7;
		ZERO = L == 0;
		PARITY = L == 0x80;
		BCD = 0;
	when 45:		/* 2d DEC L */
		HALF_CARRY = lonyb(L) != 0;
		--L;
		SIGN = L >> 7;
		ZERO = L == 0;
		PARITY = L == 0x7f;
		BCD = 1;
	when 46:		/* 2e LD L,n */
		L = ram[PC++];
	when 47:		/* 2f CPL */
		A = ~A;
		HALF_CARRY = BCD = 1;
	when 48:		/* 30 JR NC,e */
		if(CARRY) ++PC;
		else PC += (signed char)(ram[PC] + 1);
	when 49:		/* 31 LD SP,nn */
		SPL = ram[PC++];
		SPH = ram[PC++];
	when 50:		/* 32 LD (nn),A */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		ram[TEMP] = A;
	when 51:		/* 33 INC SP */
		++SP;
	when 52:		/* 34 INC (HL) */
		HALF_CARRY = lonyb(ram[HL]) == 0xf;
		++ram[HL];
		SIGN = ram[HL] >> 7;
		ZERO = ram[HL] == 0;
		PARITY = ram[HL] == 0x80;
		BCD = 0;
	when 53:		/* 35 DEC (HL) */
		HALF_CARRY = lonyb(ram[HL]) != 0;
		--ram[HL];
		SIGN = ram[HL] >> 7;
		ZERO = ram[HL] == 0;
		PARITY = ram[HL] == 0x7f;
		BCD = 1;
	when 54:		/* 36 LD (HL),n */
		ram[HL] = ram[PC++];
	when 55:		/* 37 SCF */
		HALF_CARRY = BCD = 0;
		CARRY = 1;
	when 56:		/* 38 JR C,e */
		if (CARRY) PC += (signed char)(ram[PC] + 1);
		else ++PC;
	when 57:		/* 39 ADD HL,SP */
		s = SP;
		a = (HL & 0xfff) + (s & 0xfff);
		s += HL;
		HL = s;
		BCD = 0;
		CARRY = s >> 16;
		HALF_CARRY = a >> 12;
	when 58:		/* 3a LD A,(nn) */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		A = ram[TEMP];
	when 59:		/* 3b DEC SP */
		--SP;
	when 60:		/* 3c INC A */
		HALF_CARRY = lonyb(A) == 0xf;
		++A;
		SIGN = A >> 7;
		ZERO = A == 0;
		PARITY = A == 0x80;
		BCD = 0;
	when 61:		/* 3d DEC A */
		HALF_CARRY = lonyb(A) != 0;
		--A;
		SIGN = A >> 7;
		ZERO = A == 0;
		PARITY = A == 0x7f;
		BCD = 1;
	when 62:		/* 3e LD A,n */
		A = ram[PC++];
	when 63:		/* 3f CCF */
		HALF_CARRY = CARRY;
		CARRY = ~CARRY;
		BCD = 0;
	when 64:		/* 40 LD B,B */
	when 65:		/* 41 LD B,C */
		B = C;
	when 66:		/* 42 LD B,D */
		B = D;
	when 67:		/* 43 LD B,E */
		B = E;
	when 68:		/* 44 LD B,H */
		B = H;
	when 69:		/* 45 LD B,L */
		B = L;
	when 70:		/* 46 LD B, (HL) */
		B = ram[HL];
	when 71:		/* 47 LD B,A */
		B = A;
	when 72:		/* 48 LD C,B */
		C = B;
	when 73:		/* 49 LD C,C */
	when 74:		/* 4a LD C,D */
		C = D;
	when 75:		/* 4b LD C,E */
		C = E;
	when 76:		/* 4c LD C,H */
		C = H;
	when 77:		/* 4d LD C,L */
		C = L;
	when 78:		/* 4e LD C, (HL) */
		C = ram[HL];
	when 79:		/* 4f LD C,A */
		C = A;
	when 80:		/* 50 LD D,B */
		D = B;
	when 81:		/* 51 LD D,C */
		D = C;
	when 82:		/* 52 LD D,D */
	when 83:		/* 53 LD D,E */
		D = E;
	when 84:		/* 54 LD D,H */
		D = H;
	when 85:		/* 55 LD D,L */
		D = L;
	when 86:		/* 56 LD D, (HL) */
		D = ram[HL];
	when 87:		/* 57 LD D,A */
		D = A;
	when 88:		/* 58 LD E,B */
		E = B;
	when 89:		/* 59 LD E,C */
		E = C;
	when 90:		/* 5a LD E,D */
		E = D;
	when 91:		/* 5b LD E,E */
	when 92:		/* 5c LD E,H */
		E = H;
	when 93:		/* 5d LD E,L */
		E = L;
	when 94:		/* 5e LD E, (HL) */
		E = ram[HL];
	when 95:		/* 5f LD E,A */
		E = A;
	when 96:		/* 60 LD H,B */
		H = B;
	when 97:		/* 61 LD H,C */
		H = C;
	when 98:		/* 62 LD H,D */
		H = D;
	when 99:		/* 63 LD H,E */
		H = E;
	when 100:		/* 64 LD H,H */
	when 101:		/* 65 LD H,L */
		H = L;
	when 102:		/* 66 LD H, (HL) */
		H = ram[HL];
	when 103:		/* 67 LD H,A */
		H = A;
	when 104:		/* 68 LD L,B */
		L = B;
	when 105:		/* 69 LD L,C */
		L = C;
	when 106:		/* 6a LD L,D */
		L = D;
	when 107:		/* 6b LD L,E */
		L = E;
	when 108:		/* 6c LD L,H */
		L = H;
	when 109:		/* 6d LD L,L */
	when 110:		/* 6e LD L,(HL) */
		L = ram[HL];
	when 111:		/* 6f LD L,A */
		L = A;
	when 112:		/* 70 LD (HL),B */
		ram[HL] = B;
	when 113:		/* 71 LD (HL),C */
		ram[HL] = C;
	when 114:		/* 72 LD (HL),D */
		ram[HL] = D;
	when 115:		/* 73 LD (HL),E */
		ram[HL] = E;
	when 116:		/* 74 LD (HL),H */
		ram[HL] = H;
	when 117:		/* 75 LD (HL),L */
		ram[HL] = L;
	when 118:		/* 76 HALT */
		return(0x76);
	when 119:		/* 77 LD (HL),A */
		ram[HL] = A;
	when 120:		/* 78 LD A,B */
		A = B;
	when 121:		/* 79 LD A,C */
		A = C;
	when 122:		/* 7a LD A,D */
		A = D;
	when 123:		/* 7b LD A,E */
		A = E;
	when 124:		/* 7c LD A,H */
		A = H;
	when 125:		/* 7d LD A,L */
		A = L;
	when 126:		/* 7e LD A,(HL) */
		A = ram[HL];
	when 127:		/* 7f LD A,A */
	when 128:		/* 80 ADD A,B */
		s = B;
		goto add;
	case 129:		/* 81 ADD A,C */
		s = C;
		goto add;
	case 130:		/* 82 ADD A,D */
		s = D;
		goto add;
	case 131:		/* 83 ADD A,E */
		s = E;
		goto add;
	case 132:		/* 84 ADD A,H */
		s = H;
		goto add;
	case 133:		/* 85 ADD A,L */
		s = L;
		goto add;
	case 134:		/* 86 ADD A,(HL) */
		s = ram[HL];
		goto add;
	case 135:		/* 87 ADD A,A */
		s = A;
		goto add;
	case 136:		/* 88 ADC A,B */
		s = B;
		goto adc;
	case 137:		/* 89 ADC A,C */
		s = C;
		goto adc;
	case 138:		/* 8a ADC A,D */
		s = D;
		goto adc;
	case 139:		/* 8b ADC A,E */
		s = E;
		goto adc;
	case 140:		/* 8c ADC A,H */
		s = H;
		goto adc;
	case 141:		/* 8d ADC A,L */
		s = L;
		goto adc;
	case 142:		/* 8e ADC A,(HL) */
		s = ram[HL];
		goto adc;
	case 143:		/* 8f ADC A,A */
		s = A;

adc:
		a = A & 0x0f;
		s1 = s & 0x0f;
		if (CARRY) { s++; a++; }
		goto add1;

add:
		a = A & 0x0f;
		s1 = s & 0x0f;

add1:
		BCD = 0;
		s += A;
		A = s;
		a += s1;

set_flags:
		CARRY = s >> 8;
		HALF_CARRY = a >> 4;
		SIGN = s >> 7;
		ZERO = s ? 0 : 1;
		PARITY = partab[A];

	when 144:		/* 90 SUB A,B */
		s = B;
		goto sub;
	case 145:		/* 91 SUB A,C */
		s = C;
		goto sub;
	case 146:		/* 92 SUB A,D */
		s = D;
		goto sub;
	case 147:		/* 93 SUB A,E */
		s = E;
		goto sub;
	case 148:		/* 94 SUB A,H */
		s = H;
		goto sub;
	case 149:		/* 95 SUB A,L */
		s = L;
		goto sub;
	case 150:		/* 96 SUB A,(HL) */
		s = ram[HL];
		goto sub;
	case 151:		/* 97 SUB A,A */
		s = A;
		goto sub;
	case 152:		/* 98 SBC A,B */
		s = B;
		goto sbc;
	case 153:		/* 99 SBC A,C */
		s = C;
		goto sbc;
	case 154:		/* 9a SBC A,D */
		s = D;
		goto sbc;
	case 155:		/* 9b SBC A,E */
		s = E;
		goto sbc;
	case 156:		/* 9c SBC A,H */
		s = H;
		goto sbc;
	case 157:		/* 9d SBC A,L */
		s = L;
		goto sbc;
	case 158:		/* 9e SBC A,(HL) */
		s = ram[HL];
		goto sbc;
	when 159:		/* 9f SBC A,A */
		s = A;

sbc:
		a = A & 0x0f;
		s1 = s & 0x0f;
		if (CARRY) { s--; a--; }
		goto sub1;

sub:
		a = A & 0x0f;
		s1 = s & 0x0f;

sub1:
		s = A - s;
		A = s;
		a -= s1;
		BCD = 1;
		goto set_flags;

	when 160:		/* a0 AND A,B */
		s = B;
		goto and;
	case 161:		/* a1 AND A,C */
		s = C;
		goto and;
	case 162:		/* a2 AND A,D */
		s = D;
		goto and;
	case 163:		/* a3 AND A,E */
		s = E;
		goto and;
	case 164:		/* a4 AND A,H */
		s = H;
		goto and;
	case 165:		/* a5 AND A,L */
		s = L;
		goto and;
	case 166:		/* a6 AND A,(HL) */
		s = ram[HL];
		goto and;
	case 167:		/* a7 AND A,A */
		s = A;

and:
		a = A & 0x0f;
		s1 = s & 0x0f;

		s &= A;
		A = s;
		a &= s;
		goto set_flags;
		
	when 168:		/* a8 XOR A,B */
		s = B;
		goto xor;
	case 169:		/* a9 XOR A,C */
		s = C;
		goto xor;
	case 170:		/* aa XOR A,D */
		s = D;
		goto xor;
	case 171:		/* ab XOR A,E */
		s = E;
		goto xor;
	case 172:		/* ac XOR A,H */
		s = H;
		goto xor;
	case 173:		/* ad XOR A,L */
		s = L;
		goto xor;
	case 174:		/* ae XOR A,(HL) */
		s = ram[HL];
		goto xor;
	case 175:		/* af XOR A,A */
		s = A;

xor:
		a = A & 0x0f;
		s1 = s & 0x0f;

		s ^= A;
		A = s;
		a ^= s;
		goto set_flags;

	when 176:		/* b1 OR B */
		s = B;
		goto or;
	case 177:		/* b1 OR C */
		s = C;
		goto or;
	case 178:		/* b2 OR D */
		s = D;
		goto or;
	case 179:		/* b3 OR E */
		s = E;
		goto or;
	case 180:		/* b4 OR H */
		s = H;
		goto or;
	case 181:		/* b5 OR L */
		s = L;
		goto or;
	case 182:		/* b6 OR (HL) */
		s = ram[HL];
		goto or;
	case 183:		/* b7 OR A */
		s = A;

or:
		a = A & 0x0f;
		s1 = s & 0x0f;

		s |= A;
		A = s;
		a |= s;
		goto set_flags;

	when 184:		/* b8 CP B */
		s = B;
		goto cp;
	when 185:		/* b9 CP C */
		s = C;
		goto cp;
	when 186:		/* ba CP D */
		s = D;
		goto cp;
	when 187:		/* bb CP E */
		s = E;
		goto cp;
	when 188:		/* bc CP H */
		s = H;
		goto cp;
	when 189:		/* bd CP L */
		s = L;
		goto cp;
	when 190:		/* be CP (HL) */
		s = A;
		goto cp;
	when 191:		/* bf CP A */
		s = ram[HL];

cp:
		a = A & 0x0f;
		s1 = s & 0x0f;
		s = A - s;
		a -= s1;
		BCD = 1;
		goto set_flags;

	when 192:		/* c0 RET NZ */
		if (!ZERO) PC = pop();
	when 193:		/* c1 POP BC */
		BC = pop();
	when 194:		/* c2 JP NZ,nn */
		if (ZERO) { PC += 2; break;}
	case 195:		/* c3 JP nn */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		PC = TEMP;
	when 196:		/* c4 CALL NZ,nn */
		if (ZERO) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
	when 197:		/* c5 PUSH BC */
		push(BC);
	when 198:		/* c6 ADD A,n */
		s = ram[PC++];
		goto add;
	case 199:		/* c7 RST 0 */
		push(PC);
		PC = 0;
	when 200:		/* c8 RET Z */
		if (!ZERO) break;
	case 201:		/* c9 RET */
		PC = pop();
	when 202:		/* ca JP Z,nn */
		if (ZERO)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
		else PC += 2;
	when 203:		/* cb oh boy */
		switch (ram[PC] & 0x03)
		{
			case 0: ptr = &B;
			case 1: ptr = &C;
			case 2: ptr = &D;
			case 3: ptr = &E;
			case 4: ptr = &H;
			case 5: ptr = &L;
			case 6: ptr = ram + HL;
			case 7: ptr = &A;
			default: ptr = (void *)(0);
		}

cb_stuff:
		if ((s1 = ((s = ram[PC++]) & 0xc0)) != 0)
		{
			a = 1 << ((s & 0x3f) >> 3);

			switch (s1)
			{
				case 0x40:		/* BIT */
					ZERO = *ptr & a;
					HALF_CARRY = 1;
					BCD = 0;
				when 0x80:		/* RES */
					*ptr &= ~a;
				when 0xb0:		/* SET */
					*ptr |= a;
			}
		}
		else
		{
			switch (s & 0xf8)
			{
				case 0x00:			/* RLC */
					CARRY= *ptr >> 7;
					*ptr <<= 1;
					if (CARRY) ++*ptr;
				when 0x08:			/* RRC */
					CARRY = *ptr;
					*ptr >>= 1;
					if (CARRY) *ptr |= 0x80;
				when 0x10:			/* RL */
					a = CARRY;
					CARRY = *ptr >> 7;
					*ptr <<= 1;
					*ptr += a;
				when 0x18:			/* RR */
					a = CARRY;
					CARRY = *ptr;
					*ptr >>= 1;
					if (a) *ptr |= 0x80;
				when 0x20:			/* SLA */
					CARRY = *ptr >> 7;
					*ptr <<= 1;
				when 0x28:			/* SRA */
					CARRY = *ptr;
					*ptr >>= 1;
					if (*ptr & 0x40) *ptr |= 0x80;
				when 0x30:			/* SLL ???? Oh well.  It fits */
					CARRY = *ptr >> 7;
					*ptr <<= 1;
					*ptr |= 1;
				when 0x38:			/* SRL */
					CARRY = *ptr;
					*ptr >>= 1;
			}

			SIGN = *ptr >> 7;
			ZERO = *ptr == 0;
			HALF_CARRY = BCD = 0;
			PARITY = partab[*ptr];
		}
	when 204:		/* cc CALL Z,nn */
		if (ZERO)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
		else PC += 2;
	when 205:		/* cd CALL nn */
		TEMPL = ram[PC++];
		TEMPH = ram[PC++];
		push(PC);
		PC = TEMP;
	when 206:		/* ce ADC A,n */
		s = ram[PC++];
		goto adc;
	when 207:		/* cf RST 08 */
		push(PC);
		PC = 8;
	when 208:		/* d0 RET NC */
		if (!CARRY)
			PC = pop();
	when 209:		/* d1 POP DE */
		DE = pop();
	when 210:		/* d2 JP NC,nn */
		if (CARRY) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
	when 211:		/* d3 OUT (n),A */
		return(211);
	when 212:		/* d4 CALL NC,nn */
		if (CARRY) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
	when 213:		/* d5 PUSH DE */
		push(DE);
	when 214:		/* d6 SUB N */
		s = ram[PC++];
		goto sub;
	when 215:		/* d7 RST 10 */
		push(PC);
		PC = 16;
	when 216:		/* d8 RET C */
		if (CARRY)
			PC = pop();
	when 217:		/* d9 EXX */
		gr_bank = gr_bank ? 0 : 1;
	when 218:		/* da JP C,nn */
		if (CARRY)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
		else PC += 2;
	when 219:		/* db IN A,(n) */
		return(219);
	when 220:		/* dc CALL C,nn */
		if (CARRY)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
		else PC += 2;
	when 221:		/* DD instructions - use IX register */
		opcode = ram[PC++];
		switch (opcode)
		{
			case 0x09:		/* 09 ADD IX,BC */
				s = BC;
				a = (IX & 0xfff) + (s & 0xfff);
				s += IX;
				IX = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x19:		/* ADD IX, DE */
				s = DE;
				a = (IX & 0xfff) + (s & 0xfff);
				s += IX;
				IX = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x21:		/* LD IX, nn */
				IXL = ram[PC++];
				IXH = ram[PC++];
			when 0x22:		/* LD (nn), IX) */
				TEMPL = ram[PC++];
				TEMPH = ram[PC++];
				ram[TEMP] = IXL;
				ram[TEMP + 1] = IXH;
			when 0x23:		/* INC IX */
				IX++;
			when 0x29:		/* ADD IX, IX */
				s = IX;
				a = (IX & 0xfff) + (s & 0xfff);
				s += IX;
				IX = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x2a:		/* LD IX, (nn) */
				TEMPL = ram[PC++];
				TEMPH = ram[PC++];
				IXL = ram[TEMP];
				IXH = ram[TEMP + 1];
			when 0x2b:		/* DEC IX */
				IX--;
			when 0x34:		/* INC (IX + d) */
				ptr = ram + IX + ram[PC++];
				HALF_CARRY = lonyb(*ptr) == 0xf;
				++(*ptr);
				SIGN = *ptr >> 7;
				ZERO = *ptr == 0;
				PARITY = *ptr == 0x80;
				BCD = 0;
			when 0x35:		/* DEC (IX + d) */
				ptr = ram + IX + ram[PC++];
				HALF_CARRY = lonyb(*ptr) != 0;
				--(*ptr);
				SIGN = *ptr >> 7;
				ZERO = *ptr == 0;
				PARITY = *ptr == 0x7f;
				BCD = 1;
			when 0x36:		/* LD (IX + d), n */
				TEMP = IX + ram[PC++];
				ram[TEMP] = ram[PC++];
			when 0x39:		/* ADD IX, SP */
				s = SP;
				a = (IX & 0xfff) + (s & 0xfff);
				s += IX;
				IX = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x46:		/* LD B, (IX + d) */
				B = ram[IX + ram[PC++]];
			when 0x4e:		/* LD C, (IX + d) */
				C = ram[IX + ram[PC++]];
			when 0x56:		/* LD D, (IX + d) */
				D = ram[IX + ram[PC++]];
			when 0x5e:		/* LD E, (IX + d) */
				E = ram[IX + ram[PC++]];
			when 0x66:		/* LD H, (IX + d) */
				H = ram[IX + ram[PC++]];
			when 0x6e:		/* LD L, (IX + d) */
				L = ram[IX + ram[PC++]];
			when 0x70:		/* LD (IX + d, B */
				ram[IX + ram[PC++]] = B;
			when 0x71:		/* LD (IX + d, C */
				ram[IX + ram[PC++]] = C;
			when 0x72:		/* LD (IX + d, D */
				ram[IX + ram[PC++]] = D;
			when 0x73:		/* LD (IX + d, E */
				ram[IX + ram[PC++]] = E;
			when 0x74:		/* LD (IX + d, H */
				ram[IX + ram[PC++]] = H;
			when 0x75:		/* LD (IX + d, L */
				ram[IX + ram[PC++]] = L;
			when 0x77:		/* LD (IX + d, A */
				ram[IX + ram[PC++]] = A;
			when 0x7e:		/* LD A, (IX + d) */
				A = ram[IX + ram[PC++]];
			when 0x86:		/* ADD A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto add;
			when 0x8e:		/* ADC A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto adc;
			when 0x96:		/* SUB A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto sub;
			when 0x9e:		/* SBC A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto sbc;
			when 0xa6:		/* AND A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto and;
			when 0xae:		/* XOR A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto xor;
			when 0xb6:		/* OR A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto or;
			when 0xbe:		/* CP A, (IX + d) */
				s = ram[IX + ram[PC++]];
				goto cp;
			when 0xcb:
				ptr = ram + IX + ram[PC++];
				goto cb_stuff;
			when 0xe1:		/* POP IX */
				IX = pop();
			when 0xe3:		/* EX (SP), IX */
				s = IX;
				IX = pop();
				push(s);
			when 0xe5:		/* PUSH IX */
				push(IX);
			when 0xe9:		/* JP (IX) */
				PC = IX;
			when 0xf9:		/* LD SP, IX */
				SP = IX;
			break; default: return(-1);
		}
	when 222:		/* de SBC A,n */
		s = ram[PC++];
		goto sbc;
	when 223:		/* df RST 18 */
		push(PC);
		PC = 0x18;
	when 224:		/* e0 RET PO */
		if (!PARITY)
			PC = pop();
	when 225:		/* e1 POP HL */
		HL = pop();
	when 226:		/* e2 JP PO,nn */
		if (PARITY) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
	when 227:		/* e3 EX (SP),HL */
		s = HL;
		HL = pop();
		push(s);
	when 228:		/* e4 CALL PO,nn */
		if (PARITY) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
	when 229:		/* e5 PUSH HL */
		push(HL);
	when 230:		/* e6 AND n */
		s = ram[PC++];
		goto and;
	when 231:		/* e7 RST 20 */
		push(PC);
		PC = 0x20;
	when 232:		/* e8 RET PE */
		if (PARITY)
			PC = pop();
	when 233:		/* e9 JP (HL) */
		PC = HL;
	when 234:		/* ea JP PE,nn */
		if (PARITY)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
		else PC += 2;
	when 235:		/* eb EX DE,HL */
		s = HL;
		HL = DE;
		DE = s;
	when 236:		/* ec CALL PE,nn */
		if (PARITY)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
	when 237:		/* ed oh boy */
		a = ram[PC++];
		switch(a)
		{
		case 0x40:		/* IN B,(C) */
		case 0x41:		/* OUT (C),B */
		case 0x48:		/* IN C,(C) */
		case 0x49:		/* OUT (C),C */
		case 0x50:		/* IN D,(C) */
		case 0x51:		/* OUT (C),D */
		case 0x58:		/* IN E,(C) */
		case 0x59:		/* OUT (C),E */
		case 0x60:		/* IN H,(C) */
		case 0x61:		/* OUT (C),H */
		case 0x68:		/* IN L,(C) */
		case 0x69:		/* OUT (C),L */
		when 0x78:		/* IN A,(C) */
		when 0x79:		/* OUT (C),A */
		case 0xa2:		/* INI */
		case 0xa3:		/* OUTI */
		case 0xaa:		/* IND */
		case 0xab:		/* OUTD */
		case 0xb2:		/* INIR */
		case 0xb3:		/* OTIR */
		case 0xba:		/* INDR */
		case 0xbb:		/* OTDR */
			return(0xed00 + a);
		when 0x42:		/* SBC HL,BC */
			TEMP = BC;
			goto edsbc;
		when 0x43:		/* LD (nn),BC */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			ram[TEMP] = C;
			ram[TEMP + 1] = B;
		when 0x44:		/* NEG */
			HALF_CARRY = lonyb(A) != 0;
			CARRY = A!= 0;
			PARITY = A == 0x80;
			A = 0 - A;
			SIGN = A >> 7;
			ZERO = A == 0;
			BCD = 1;
		when 0x45:		/* RETN */

			/*
			 * INTERRUPT: Add restore IFF states
			 */

			PC = pop();
		when 0x46:		/* IM 0 */

			/*
			 * INTERRUPT: Set IM 0
			 */
			;
		when 0x47:		/* LD I,A */

			/*
			 * INTERRUPT: Load I from A
			 */
			;
		when 0x4a:		/* ADC HL,BC */
			TEMP = BC;
			goto edadc;
		when 0x4b:		/* LD BC,(nn) */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			C = ram[TEMP];
			B = ram[TEMP + 1];
		when 0x4d:		/* RETI */
			PC = pop();
		when 0x4f:		/* LD R,A */
			R = A + 1;
		when 0x52:		/* SBC HL,DE */
			TEMP = DE;
			goto edsbc;
		when 0x53:		/* LD (nn),DE */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			ram[TEMP] = E;
			ram[TEMP + 1] = D;
		when 0x56:		/* IM 1 */

			/*
			 * INTERRUPT: Set IM 1
			 */
			;
		when 0x57:		/* LD A,I */

			/*
			 * INTERRUPT: A=I
			 */
			;
		when 0x5a:		/* ADC HL,DE */
			TEMP = DE;
			goto edadc;
		when 0x5b:		/* LD DE,(nn) */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			E = ram[TEMP];
			D = ram[TEMP + 1];
		when 0x5e:		/* IM 2 */

			/*
			 * INTERRUPT: Set IM 2
			 */
			;
		when 0x5f:		/* LD A,R */
			A = ++R;
			SIGN = A >> 7;
			ZERO = A == 0;
			HALF_CARRY = BCD = 0;

			/*
			 * INTERRUPT: Copy IFF2 into PARITY
			 */

			PARITY = 0;
		when 0x62:		/* SBC HL,HL */
			TEMP = HL;
			goto edsbc;
		when 0x63:		/* LD (nn),HL */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			ram[TEMP] = L;
			ram[TEMP + 1] = H;
		when 0x67:		/* RRD */
			s = lonyb(ram[HL]);
			HL = (ram[HL] >> 4) | (lonyb(A) << 4);
			A = (A & 0xf0) | s;
			SIGN = A >> 7;
			ZERO = A == 0;
			PARITY = partab[A];
			HALF_CARRY = BCD = 0;
		when 0x6a:		/* ADC HL,HL */
			TEMP = HL;
			goto edadc;
		when 0x6b:		/* LD HL,(nn) */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			L = ram[TEMP];
			H = ram[TEMP + 1];
		when 0x6f:		/* RLD */
			s = hinyb(ram[HL]);
			ram[HL] = (ram[HL] << 4) | lonyb(A);
			A = ( A & 0xf0) | s;
			SIGN = A >> 7;
			ZERO = A == 0;
			PARITY = partab[A];
			HALF_CARRY = BCD = 0;
		when 0x72:		/* SBC HL,SP */
			TEMP = SP;
edsbc:
			s = (HL & 0xfff) - (TEMP & 0xfff);
			if (CARRY) --s;
			HALF_CARRY = s < 0;
			s = (int)(HL - TEMP);
			if (CARRY) --s;
			PARITY = s < -32768 || s > 32767;
			s = (int)(HL - TEMP);
			if (CARRY) --s;
			CARRY = s < 0;
			HL = s;
			SIGN =HL >> 15;
			ZERO = HL == 0;
			BCD = 1;
		when 0x73:		/* LD (nn),SP */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			ram[TEMP] = SPL;
			ram[TEMP + 1] = SPH;
		when 0x7a:		/* ADC HL,SP */
			TEMP = SP;
edadc:
			s = (HL & 0xfff) + (TEMP & 0xfff);
			if (CARRY) ++s;
			HALF_CARRY = s > 0xfff;
			s = (int)(HL + TEMP);
			if (CARRY) ++s;
			s1 = s > 0xffff;
			s = (int)(HL + TEMP);
			if (CARRY) ++s;
			PARITY = s < -32768 || s > 32767;
			HL = s;
			CARRY = s1;
			SIGN = HL >> 15;
			ZERO = HL == 0;
			BCD = 0;
		when 0x7b:		/* LD SP,(nn) */
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			SPL = ram[TEMP];
			SPH = ram[TEMP + 1];
		when 0xa0:		/* LDI */
			ram[DE++] = ram[HL++];
			PARITY = --BC != 0;
			HALF_CARRY = BCD = 0;
		when 0xa1:		/* CPI */
			s = ram[HL++];
			PARITY= --BC!=0;
			ZERO = A == s;
			HALF_CARRY = (int)((A & 0xf) - (s & 0xf)) < 0;
			s = A - s;
			SIGN = s >> 7;
			BCD = 0;
		when 0xa8:		/* LDD */
			ram[DE--] = ram[HL--];
			PARITY = --BC != 0;
			HALF_CARRY = BCD = 0;
		when 0xa9:		/* CPD */
			s = ram[HL--];
			PARITY = --BC != 0;
			ZERO = A == s;
			HALF_CARRY = (int)((A & 0xf) - (s & 0xf)) < 0;
			s = A - s;
			SIGN = s >> 7;
			BCD = 0;
		when 0xb0:		/* LDIR */
			do
				ram[DE++] = ram[HL++];
			while (--BC);
			HALF_CARRY = BCD = PARITY = 0;

			/*
			 * INTERRUPT: Convert for PC-=2
			 * Also conv CPIR,INIR,OTIR,LDDR,CPDR, etc
			 */

		when 0xb1:		/* CPIR */
			do
			{
				s = ram[HL++];
				PARITY = --BC != 0;
				ZERO = A == s;
			} while(!ZERO && PARITY);
			HALF_CARRY = (int)((A & 0xf) - (s & 0xf)) < 0;
			s = A - s;
			SIGN = s >> 7;
			BCD = 0;
		when 0xb8:		/* LDDR */
			do
				ram[DE--] = ram[HL--];
			while (--BC);
			HALF_CARRY = BCD = PARITY = 0;
		when 0xb9:		/* CPDR */
			do
			{
				s = ram[HL--];
				PARITY = --BC != 0;
				ZERO = A == s;
			} while(!ZERO && PARITY);
			HALF_CARRY = (int)((A & 0xf) - (s & 0xf)) < 0;
			s = A - s;
			SIGN = s >> 7;
			BCD = 0;
		}
	when 238:		/* ee XOR n */
		s = ram[PC++];
		goto xor;
	when 239:		/* ef RST 28 */
		push(PC);
		PC = 0x28;
	when 240:		/* f0 RET P */
		if (!SIGN)
			PC = pop();
	when 241:		/* f1 POP AF */
		AF = pop();
	when 242:		/* f2 JP P,nn */
		if (SIGN) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
	when 243:		/* f3 DI */

		/*
		 * INTERRUPT: Disable
		 */
		;
	when 244:		/* f4 CALL P,nn */
		if (SIGN) PC += 2;
		else
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
	when 245:		/* f5 PUSH AF */
		push(AF);
	when 246:		/* f6 OR n */
		s = ram[PC++];
		goto or;
	when 247:		/* f7 RST 30 */
		push(PC);
		PC = 0x30;
	when 248:		/* f8 RET M */
		if (SIGN)
			PC = pop();
	when 249:		/* f9 LD SP,HL */
		SP = HL;
	when 250:		/* fa JP M,nn */
		if (SIGN)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			PC = TEMP;
		}
		else PC += 2;
	when 251:		/* fb EI */

		/*
		 * INTERRUPT: Enable
		 */
		;
	when 252:		/* fc CALL M,nn */
		if (SIGN)
		{
			TEMPL = ram[PC++];
			TEMPH = ram[PC++];
			push(PC);
			PC = TEMP;
		}
		else PC += 2;
	when 253:		/* FD instructions - use IY register */
		opcode = ram[PC++];
		switch (opcode)
		{
			case 0x09:		/* 09 ADD IY,BC */
				s = BC;
				a = (IY & 0xfff) + (s & 0xfff);
				s += IY;
				IY = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x19:		/* ADD IY, DE */
				s = DE;
				a = (IY & 0xfff) + (s & 0xfff);
				s += IY;
				IY = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x21:		/* LD IY, nn */
				IYL = ram[PC++];
				IYH = ram[PC++];
			when 0x22:		/* LD (nn), IY) */
				TEMPL = ram[PC++];
				TEMPH = ram[PC++];
				ram[TEMP] = IYL;
				ram[TEMP + 1] = IYH;
			when 0x23:		/* INC IY */
				IY++;
			when 0x29:		/* ADD IY, IY */
				s = IY;
				a = (IY & 0xfff) + (s & 0xfff);
				s += IY;
				IY = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x2a:		/* LD IY, (nn) */
				TEMPL = ram[PC++];
				TEMPH = ram[PC++];
				IYL = ram[TEMP];
				IYH = ram[TEMP + 1];
			when 0x2b:		/* DEC IY */
				IY--;
			when 0x34:		/* INC (IY + d) */
				ptr = ram + IY + ram[PC++];
				HALF_CARRY = lonyb(*ptr) == 0xf;
				++(*ptr);
				SIGN = *ptr >> 7;
				ZERO = *ptr == 0;
				PARITY = *ptr == 0x80;
				BCD = 0;
			when 0x35:		/* DEC (IY + d) */
				ptr = ram + IY + ram[PC++];
				HALF_CARRY = lonyb(*ptr) != 0;
				--(*ptr);
				SIGN = *ptr >> 7;
				ZERO = *ptr == 0;
				PARITY = *ptr == 0x7f;
				BCD = 1;
			when 0x36:		/* LD (IY + d), n */
				TEMP = IY + ram[PC++];
				ram[TEMP] = ram[PC++];
			when 0x39:		/* ADD IY, SP */
				s = SP;
				a = (IY & 0xfff) + (s & 0xfff);
				s += IY;
				IY = s;
				BCD = 0;
				CARRY = s >> 16;
				HALF_CARRY = a >> 12;
			when 0x46:		/* LD B, (IY + d) */
				B = ram[IY + ram[PC++]];
			when 0x4e:		/* LD C, (IY + d) */
				C = ram[IY + ram[PC++]];
			when 0x56:		/* LD D, (IY + d) */
				D = ram[IY + ram[PC++]];
			when 0x5e:		/* LD E, (IY + d) */
				E = ram[IY + ram[PC++]];
			when 0x66:		/* LD H, (IY + d) */
				H = ram[IY + ram[PC++]];
			when 0x6e:		/* LD L, (IY + d) */
				L = ram[IY + ram[PC++]];
			when 0x70:		/* LD (IY + d, B */
				ram[IY + ram[PC++]] = B;
			when 0x71:		/* LD (IY + d, C */
				ram[IY + ram[PC++]] = C;
			when 0x72:		/* LD (IY + d, D */
				ram[IY + ram[PC++]] = D;
			when 0x73:		/* LD (IY + d, E */
				ram[IY + ram[PC++]] = E;
			when 0x74:		/* LD (IY + d, H */
				ram[IY + ram[PC++]] = H;
			when 0x75:		/* LD (IY + d, L */
				ram[IY + ram[PC++]] = L;
			when 0x77:		/* LD (IY + d, A */
				ram[IY + ram[PC++]] = A;
			when 0x7e:		/* LD A, (IY + d) */
				A = ram[IY + ram[PC++]];
			when 0x86:		/* ADD A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto add;
			when 0x8e:		/* ADC A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto adc;
			when 0x96:		/* SUB A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto sub;
			when 0x9e:		/* SBC A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto sbc;
			when 0xa6:		/* AND A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto and;
			when 0xae:		/* XOR A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto xor;
			when 0xb6:		/* OR A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto or;
			when 0xbe:		/* CP A, (IY + d) */
				s = ram[IY + ram[PC++]];
				goto cp;
			when 0xcb:
				ptr = ram + IY + ram[PC++];
				goto cb_stuff;
			when 0xe1:		/* POP IY */
				IY = pop();
			when 0xe3:		/* EX (SP), IY */
				s = IY;
				IY = pop();
				push(s);
			when 0xe5:		/* PUSH IY */
				push(IY);
			when 0xe9:		/* JP (IY) */
				PC = IY;
			when 0xf9:		/* LD SP, IY */
				SP = IY;
			break; default: return(-1);
		}
	when 254:		/* fe CP n */
		s = ram[PC++];
		goto cp;
	when 255:		/* ff RST 38 */
		push(PC);
		PC = 0x38;
	default: return(-1);
	}

	return(0);
}
