; 	PIPXFR.ASM handshaked file transfer via PIP INP: and OUT: devices.
;	------------------------------------------------------------------

; 	V01 L00 created on 1983 June 24 by Dennis E. Hamilton 


;	PIPXFR patches Digital Research PIP.COM so that the INP: and OUT:
;	devices are defined at the RDR: and PUN: logical devices *AND*
;	subject to special echo handshaking so that the sender does not
;	overrun the receiver.

;	The basic patch procedure for PIP is that described in PIPIO.ASM
;	by T. Jennings (written 1982 February 1).

;	This implementation uses a protocol suggested by Steven Fisher
;	[PIP Data Between Computers. MICROSYSTEMS 4, 7(July 1983), 48-54].
;	(The patch itself was developed 1978 March 3.)

;	A typical installation of this modification is as follows:

;		>ASM PIPXFR
;		>DDT PIP.COM
;		-IPIPXFR.HEX
;		-R
;		-G0
;		>SAVE 29 PIP.COM 	




;		CP/M SYSTEM INTERFACE DEFINITIONS***************************
;		============================================================

BBASE	EQU	0000H		; system base location

WBOOT	EQU	BBASE		; warm-boot exit instruction

IOBYTE	EQU	BBASE+3		; CP/M 2.x Serial Device Assignments
DEFAULT	EQU	BBASE+4		; CP/M 2.x Default Disk Assignment

BDOS	EQU	BBASE+5		; BDOS operation entry point

TICCNT	EQU	BBASE+11	; H/Z CP/M 2.2.03 2ms tick counter
H88CTL	EQU	BBASE+13	; H88/Z89 latch 362Q contents
H8CTL	EQU	BBASE+14	; H8 latch 360Q contents (or zero)
HA82	EQU	BBASE+22	; word for HA8-2 music output

FILE1	EQU	BBASE+92	; Default FCB built by CCP

RECORD1	EQU	BBASE+128	; Default DMA record location and the 
				; CCP deposit of the command-line tail

TPA	EQU	BBASE+0100H	; CP/M Transient Program Area


				; STANDARD CP/M 2.2 BDOS OPERATIONS
AUXIN	EQU	3		; AUXilliary byte INput
AUXOUT	EQU	4		; AUXilliary byte OUTput




;		TPA PAGE INP: AND OUT: INTERFACE
;		================================


	ORG	TPA+3		; start just past PIP entry point
	
	JMP	INPUT		; INP: procedure entry point
	JMP	OUTPUT		; OUT: procedure entry point
INBYTE:
	DB	80H		; delivery cell for received bytes



;===========================================================================;
;									    ;
; *******************  INP: CHARACTER INPUT PROCEDURE  ******************** ;
;									    ;
;===========================================================================;

;		On entry to INPUT from PIP, the additional subroutine should
;		obtain one character and return with it stored in INBYTE.


INPUT:
	MVI	C,AUXIN		; read the next input character, if any,
	CALL	BDOS		; into INBYTE
	ANI	7FH		
	STA	INBYTE

	MOV	E,A		; return the same character as 
	MVI	C,AUXOUT	; confirmation
	JMP	BDOS



;==========================================================================;
;									   ;
; *******************  OUT: CHARACTER OUTPUT PROCEDURE  ****************** ;
;									   ;
;==========================================================================;

;		On entry to OUTPUT from PIP, the character to be output is
;		found in register C.


OUTPUT:
	MOV	E,C		; send the character to AUXOUT
	MVI	C,AUXOUT
	CALL	BDOS

	MVI	C,AUXIN		; wait for any character to return as
	JMP	BDOS		; confirmation before continuing



	DS	TPA+256-$	; the patches must fit in 1st TPA page
	END
r to return as
	JMP	BDOS		; confirmation before continuing



	DS	TPA+256-$	; the patches must fit in 1st TPA page
	END