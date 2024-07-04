;RUNIT.ASM	Vers. 1.0            4/24/84
;
;Dennis Recla
;Lost Island RCP/M
;Garland, Texas
;214-681-4789
;
;Application of the techinque described in another program called
;RUNFILE by Phil Cary.
;
;This program will call up a file in another user area, without reguard
;to the MAXDRV or MAXUSR settings.  So you can put RBBS or other programs
;in user 14 and use this program to 'CALL' them up without having to 
;modify the WHEEL byte.
;
;USES:  Run RBBS from user 14 (MAXUSR set to 'say' 10) this program will
;       let you 'CALL' RBBS down in 14 after you have entered CP/M in
;	case a caller wants to get back in and leave a message.  Just
;	rename this file RBBS and leave it in A0:.  With RBBS, the P
;	option is supported for 'log-back-on'.
;
;	Rename it BYE, and use it to CALL an EXIT program down in user 14
;	and let the EXIT program actually CALL BYE.  Allows caller to leave
;	messages before leaving CP/M.
; 
;This also resets the current Default Drive to 'A' if a program is 
;called from another drive.  Programs using BRUN look for BRUN on the
;default drive, so not having it set to 'A' could be a problem.
;
;BDOS FUNCTONS
;
;
WRCON:	EQU	2		;Console output
PRINTF:	EQU	9		;Print string
BDOS:	EQU	5		;Bdos Call
SELDRV: EQU	14		;Select Default Drive
OPEN:	EQU	15		;Open file
READ:	EQU	20		;Read sequential
SETDMA:	EQU	26		;Set DMA Address
USER:	EQU	32		;Set user area
;
;MISC EQUATES
;
CR:	EQU	0DH
LF:	EQU	0AH
;
;
	ORG	100H
;
;
	JMP	START		;Skip following data
;
;
;CHANGE THE FOLLOWING TO MEET YOUR REQUIREMENTS
;
DEFDRV:	EQU	'A'-'@'		;Drive containing the COM file you want
DEFUSR:	EQU	14		;User area "     "     "      "    "
;
RUNFIL:	DB	'RBBS    '	;Filename you are CALLING 
;Eight Chars-->> ^^^^^^^^<<	; 
;
ERRMSG:	DB	CR,LF		
	DB	'Chain Error !! $'	;Print Error Message
;
;
START:	MVI	C,8		;Move the filename into fcb
	LXI	H,RUNFIL	;location of filename
	LXI	D,FCB+1		;destination
	CALL	MOVE		;8 bytes
;
;       If you need to reset the default drive back to 'A' then
;	include the next three lines of code.
;
	MVI	C,SELDRV	;If necessary for BASCOM
	MVI	E,00H		;Set Default Drive back to A '0'
	CALL	BDOS		;Set it
;
	MVI	C,USER		;set up set user function
	MVI	E,DEFUSR	;Desired user area
	CALL	BDOS		;do it
;
	LHLD	BDOS+1		;Start of BDOS address
	LXI	B,-CODELN	;subtract length of code to be moved
	DAD	B		;to make room at top of TPA
	SHLD	JMPR+1		;Fill in jump address below
	PUSH	H		;save code address for RET
	XCHG			;and use to calculate final location of FCB
	LXI	H,FCB-LOADER	;distance between start of loader and FCB
	DAD	D		;add address computed above
	SHLD	FCBR+1		;and put in LXI below for eventual file read
	PUSH	H		;save FCB destination address
	LXI	H,LOADER	;point to start of loader
	MVI	C,CODELN	;length of loader
	CALL	MOVE		;Destination still in DE from above
	POP	D		;Recover FCB address (saved as push H above)
	MVI	C,OPEN		;
	CALL	BDOS		;Open file
	INR	A		;
	JZ	ERROR		;signal if error
	POP	H		;recover start of loader
	SPHL			;point stack to top of
	PUSH	H		;start of loader and save address again
	LXI	H,100H		;point to start of TPA for set DMA below
	RET			;To address on stack which is start of loader
;
LOADER:	PUSH	H		;DMA address at start of TPA
	XCHG			;put in DE for DMA set
	MVI	C,SETDMA		;
	CALL	BDOS		;set DMA address
;
FCBR:	LXI	D,$-$		;Address of moved FCB filled in earlier
	MVI	C,READ		;
	CALL	BDOS		;Read next record
	ORA	A		;check for end of file
	JNZ	100H		;EOF -> Start TPA
	POP	H
	LXI	D,128		;....and bump DMA address
	DAD	D
;
JMPR:	JMP	$-$		;jump to loader address filled in earlier
;
FCB:	DB	DEFDRV		;drive code
	DS	8		;room for filename
	DB	'COM'		;File type
	DB	0,0,0,0,0,0	;Zero out remaining 24 bytes of FCB
	DB	0,0,0,0,0,0
	DB	0,0,0,0,0,0
	DB	0,0,0,0,0,0
;
CODELN:	EQU	$-LOADER
;
MOVE:	; C= # Bytes,  HL= Source, DE= Destination
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	C
	JNZ	MOVE
	RET
;
ERROR:	LXI	D,ERRMSG
	CALL	PRNMSG
	JMP	0
;
;Write a string of characters to the CRT
;
PRNMSG:	MVI	C,PRINTF
	CALL	BDOS
	RET
;
END
