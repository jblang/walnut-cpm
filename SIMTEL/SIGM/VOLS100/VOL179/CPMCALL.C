
/*
CP/M bdos and bios calls for C/80
  by T. Bolstad, ELEKTROKONSULT AS
  Konnerudgaten. 3, N-3000 Drammen, Norway
  1/17/83
 NOTES : 
         I found this in Dr. Dobb's Journal.
If you have Software Toolworks C compiler and
you have found it frustrating when writing asm
subroutines to imbed in your C program because
you could not call a BDOS or BIOS function,    
here is the answer to your problems. You can modify
it easily to fit your needs (by that, I mean you
can reduce the number of functions to only those
you require by eliminating them from the #define
statements) and to use it you merely include  it
in your source (#include <filename.c>).
Helpful hint: when compiling this as it stands,
with ALL the functions defined, you must use
the -d compiler directive to expand the macro
table. I used a value of 700, but I think that
was a bit of overkill.
 At the end of this program is something called
'LISTING 2' this is a test prohram to verify
you have se written the program correctly and
that it functions properly. This was also in
Dr. Dobbs.
                           Doug Haire
                                            */



/*  definintion of BDOS functions  */

#define RESET	0	/* system RESET	*/
#define	CONSIN	1	/* console INPUT */
#define	CONSOUT	2	/* reader INPUT */
#define	READIN	3	/* punch input  */
#define	PUNOUT	4	/* punch output  */
#define	LISTOUT	5	/* list output  */
#define	DIRCON	6	/* direct console I/0 */
#define	GETIOB	7	/* get I/O byte  */
#define	SETIOB	8	/* set I/O byte  */
#define	PRNTST	9	/* print string  */
#define	READCB	10	/* read console buffer */
#define	GETCST	11	/* get console status  */
#define	RETVN	12	/* return version number */
#define	RESDSK	13	/* reset disk system */
#define	SELDISK	14	/* select disk */
#define	OPENF	15	/* open file   */
#define	CLOSEF	16	/* close file  */
#define	SRCHFF	17	/* search for first */
#define	SRCHFN	18	/* search for next  */
#define	DELF	19	/* delete file */
#define	RDSEQ	20	/* read sequential */
#define	WRSEQ	21	/* write sequential */
#define	MAKEF	22	/* make file */
#define	RENF	23	/* rename file */
#define	RETLV	24	/* return login vector */
#define	RETCD	25	/* return current disk */
#define	STDMA	26	/* set dma address */
#define	GETAA	27	/* get allocation address */
#define	WPDSK	28	/* write protect disk */
#define	GETROV	29	/* get read-only vector */
#define	SETFAT	30	/* set file attributes */
#define	GETDPA	31	/* get disk parameters adr */
#define	SGUC	32	/* set/get user code */
#define	RDRAN	33	/* read random */
#define	WRRAN	34	/* write random */
#define	COMFS	35	/* compute file size */
#define	SETRRC	36	/* set random record */
#define	RESDRV	37	/* reset drive */
#define	WRRZF	38	/* write random w/ zero fill */


bdos(funct, arg)	/* corresponds to bdos((BC),(DE)) */
int	funct,arg;


/*BCALL EXAMPLE:  bdos(RETVN,0)
    BOTH ARGUMENTS MUST BE SPECIFIED!
    Values are returned in HL. BDOS errors
    are returned as -1.                   */

{
#asm
CPBASE	EQU	0		;normal 0 org'ed CP/M 
CPNTRY	EQU	CPBASE+5	;BDOS entry

	POP	H		;get return adr
	POP	D		;get arg (information adr)
	POP	B		;get function no.
	PUSH	B		;restore stack
	PUSH	D
	PUSH	H

	PUSH	B		;save function no. on stack
	CALL	CPNTRY		;BDOS call
	XCHG			;save HL in DE
	MOV	L,A		;save A in L
				;sign ext. to H:
	RLC			;get sign bit into CY
	SBB	A		;if CY=0, result after SBB is zero
				;if CY=1, result after SBB is -1 (i.e. all ones
	MOV	H,A		;now A is moved to HL with sign extention
	POP 	B		;get function no. in BC
	MOV	A,C		;get function no. in A
	CPI	12		;was it 'return version number' ?
	JZ	RETHL1		
	CPI	24		;return login vector ?
	JZ	RETHL1
	CPI	27		;set allocation adr ?
	JZ	RETHL1
	CPI	29		;get read-only vector ?
	JZ	RETHL1
	CPI	31	 	;get disk parameter adr ?
	JZ	RETHL1
	JMP	BDOSRET

RETHL1:	XCHG
BDOSRET: RET			;with returned value in HL

#endasm
}

/*    definition of BIOS functions  */

#define BOOT	0	/* cold boot */
#define WBOOT	1	/* warm boot */
#define	CONST	2	/* console status */
#define CONIN	3	/* console input */
#define CONOUT	4	/* console output */
#define LIST	5	/* list device */
#define	PUNCH	6	/* punch */
#define READER	7	/* reader */
#define	HOME	8	/* home disk drive head */
#define	SELDSK	9	/* select disk drive */
#define SETTRK	10	/* set track */
#define	SETSEC	11	/* set sector */
#define SETDMA  12	/* set dma adr */
#define READ	13	/* read one sector */
#define	WRITE	14	/* write one sector */
#define LISTST	15	/* list status */
#define SECTRAN	16	/* sector translator */

bios(funct,arg1,arg2)	/* corresponds to bios(function, (BC),(DE)) */
int funct,arg1,arg2;

/* CALL EXAMPLE:   bios(SETTRK,5,0)
ALL 3 ARGUMENTS MUST BE SPECIFIED, even though
the last one is only used by SELDSK and SECTRAN. */

{
#asm

	POP	D		;return adr
	POP	H		;argument 2
	SHLD	ARG2S		;save it
	POP	B		;argument 1
	XCHG			;set return adr into HL

	POP	D		;function no

	PUSH	D		;restore SP
	PUSH	B
	PUSH	B
	PUSH	H		;restore return adr

	PUSH	D		;save function no. on stack

	LXI	H,0		;calculate offset adr from function:
	DAD	D		; get function no. (offset) in HL
	DAD	H		; 2 * offset
	DAD	D		; 3 * offset
	XCHG			;save offset adr in DE

	LHLD	CPBASE+1	;get pointer to BIOS WBOOT entry
	DCX	H		;decrement to
	DCX	H		; point to
	DCX	H		;  start of BIOS entry jump table

	DAD	D		; add offset (result in HL)
	XCHG			;get result in DE
	LXI	H,RET1	
	PUSH	H		;save return adr on stack

	LHLD	ARG2S		;get argument 2
	XCHG			;get argument 2 into DE

	PCHL			;go to BIOS

RET1:	XCHG			;save HL in DE
	MOV	L,A

	RLC			;get sign bit into CY
	SBB	A		;if CY=0, result after SBB is zero
				;if CY=1, result after SBB is -1
	MOV	H,A
	POP	B		;get BIOS function no. in BC
	MOV	A,C
	CPI	9		;select disk function ?
	JZ	RETHL2
	CPI	16		;sector translation function ?
	JZ	RETHL2

	JMP	RETBIOS
RETHL2: XCHG			;return value in HL
RETBIOS: RET
ARG2S:	DS	2

#endasm
}

/* LISTING 2 - a test */
/* This will return the designation of
    the logged in disk */

#include "cpmcall.c"
main()
{
	bios(c CONOUT,bdos(RETCD,0)+'A',0);
}

