; XM91ZRB.ASM -- XMODEM91 PATCH FILE FOR ZORBA BIOS AND HAYES SMARTMODEM
;
;
;
;                        HOW TO USE :
;
; 1) TO USE THE SPEED FUNCTION -- TELLS TRANSFER TIME IN MINUTES
;    AT CURRENT BAUD RATE -- SET THE MSPEED EQUATE IN THIS FILE
;    AND BYExx.ASM TO THE SAME NUMBER. SEE 'SPEED' ROUTINE IN THIS
;    FILE; THERE ARE TWO VERSIONS -- SELECT ONE.
;
; 2) SET THE EQUATES AND ASSEMBLE XMODEM91.ASM  (ASM.COM WILL DO)
;
; 3) ASSEMBLE THIS FILE (ASM.COM WILL DO)
;
; 4) PUT DDT.COM, XMODEM91.HEX, & XM91ZRB.HEX ON DRIVE A:
;
; 5) USE DDT TO OVERLAY XMODEM91.HEX WITH THIS FILE (XM91ZRB.HEX)
;
;    example:	A>DDT XMODEM91.HEX <CR>
;               -IXM91ZRB.HEX <CR>
;               -R <CR>
;               -G0 <CR>
;               A>SAVE 21 XMODEM.COM <CR>
;
;   you now have the ZORBA version of XMODEM91
;
;   NOTE: SAVE 22 IF 'TIMEON' SET TO YES
;
; * * * * * * * * * * * * * * * * * * * * * * * 
; UPDATED 05/27/84      J.E. CROWELL
; FOR XMODEM91          San Jose, CA
;
; EDITED 04/26/84       DONALD G  KRANTZ (TCOG)
;
; * * * * * * * * * * * * * * * * * * * * * * * 
;
MSPORT	EQU	21H		; status register for rs232
TXRDY	EQU	1		; bit to test for ready to send
RXRDY	EQU	2		; bit to test for received data
DPORT	EQU	20H		; data port
;
FALSE	EQU	00H
TRUE	EQU	0FFH
;
CONOUT	EQU	0E20CH		;console output jump vector v1.7 +
;
BASE:	EQU	100H		;start of TPA
;
MSPEED:	EQU	03CH 		;patch location to agree with your version
;				;of BYE
;
;-------------------------------------------------------------------
;
; Jump table: The jump table must be in exactly the same sequence
; as the one in XMODEM. Note the ORG of 103H - This jump table has
; no jump to BEGIN.
;
;
	 ORG	BASE+3	;start after JMP BEGIN
;
;
PCONOUT: JMP	CONOUT	;CRT out vector (MUST BE JMP 0 IF NOT IMPLEM.)
PMINIT:	 JMP	MINIT	;initialize whatever has to be (or do RET)
PUNINIT: JMP	UNINIT	;undo whatever MINIT did (or RET)
PSENDR:	 JMP	SENDR	;send data byte on stack (POP PSW / OUT)
PCAROK:	 JMP	CAROK	;test for carrier. RET Z=ok, NZ=no carrier
PMDIN:	 JMP	MDIN	;receive data byte
PGETCHR: JMP	MDIN	;IN from modem data only
PRCVRDY: JMP	RREADY	;check receive ready RET Z=ready
PSNDRDY: JMP	SREADY	;check send ready RET Z=ready
PSPEED:	 JMP	SPEED	;get speed factor in ACC
PSPARE1: JMP	SPARE	;3 jumps for custom routines
PSPARE2: JMP	SPARE
PSPARE3: JMP	SPARE
;
;-----------------------------------------------------------------------
;
SPARE:				;for later use
MINIT:				;no initialization required
UNINIT:	
	RET
RREADY:
	IN	MSPORT		; get status
	ANI	RXRDY		; mask
	SUI	RXRDY		; z = ready
	RET			; done
SREADY:
	IN	MSPORT		; get status
	ANI	TXRDY		; mask
	SUI	TXRDY		; z = ready
	RET			; done
SENDR:
	POP	PSW		;load up the character from the stack
	OUT	DPORT		; send char
	RET
MDIN:
	IN	DPORT
	RET
;
; USE THE FIRST SPEED IF SETTING UP XMODEM TO AGREE WITH BYE
; ELSE, USE THE SECOND SPEED (WHICH ONLY DISPLAYS THE TIME
; AT 300 BAUD).
;
SPEED:	LDA	MSPEED		;get byte stored at MSPEED location
	RET
;
;SPEED:
;	MVI	A,1		;300 BAUD
;	RET
CAROK:
	IN	MSPORT
	ANI	80H		; mask dsr
	XRI	80H
	RET
	END
