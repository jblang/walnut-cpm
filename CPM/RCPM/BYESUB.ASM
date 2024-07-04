;
;                          BYESUB.ASM
;         A routine to load/run a .com file on request
; 
;   When used by itself, or, as intended, as a called subroutine for
;RCP/M conditional logoffs, (security violation, overstayers, etc.),
;this routine will make use of the autorun feature buried in the CCP 
;module of CP/M. The file specified at the equate near the end of the 
;program will be loaded into the ccp command buffer, and the ccp will
;be cold started. This will act as if the name had been typed in at
;the console, and the return key hit.
;
;   Note that the value of CPR is system dependant. This must be 
;changed for your paticular system.
;
;              ----------------------------------
;
;------------------
;   Mods / Fixes  :
;------------------
;
;11/06/82    Initial Release
;
;			Mark J. Pulver
;			AIMS  (312) 789-0499
;
;
;-----------------
;   Code starts  :
;-----------------
;
CPR	EQU	0C700H	;ccp cold start
CBUFF	EQU	CPR+7	;address of command length pointer
CIVAL	EQU	CPR+8	;address of command buffer
CIBPTR	EQU	CPR+59H	;address of pointer to ccp command buffer
;
OFFSET	EQU	0
;
;
	ORG	0100H
;
BYE:	EQU	$+OFFSET
	LHLD	BYEFIL		;get length
	MOV	B,L		;B needs it for MOVE
	LXI	H,BYEFIL	;get name of file
	LXI	D,CBUFF		;where its going
	CALL	MOVE		;move name into buffer
	LXI	H,CIVAL		;get command buffer location
	SHLD	CIBPTR		;stuff it in pointer
	LDA	USER
	MOV	C,A		;C must have user/drive
	JMP	CPR		;cold start ccp
;
MOVE:	EQU	$+OFFSET	;hl to de length in b
	MOV	A,M
	STAX	D
	INX	D
	INX	H
	DCR	B
	JNZ	MOVE
	RET
;
USER:	EQU	$+OFFSET
	DB	0			;user/drive spec for file,
					;follows 0004h conventions
BYEFIL:	EQU	$+OFFSET
	DB	5,'BYE',0		;comfile to run
;command length ^       ^- - - "0" must be here
;+2 for first and last bytes
;
;
	END
