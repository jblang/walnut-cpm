; SMDMPAT.ASM
;
; XMODEMxx PATCH FILE FOR SMARTMODEM
;
; 07/17/84 - Modified to use with the TRS-4 and an Anchor
;            modem. Renamed to XMTR4SM.ASM  - Ed Richter
; 11/17/83 - Renamed to XMSM-1.ASM	- Irv Hoff
; 02/11/83 - Edited			- Sigi Kluger
;
MODCTLP: EQU	0EAH		;CONTROL/STATUS
MODSNDB: EQU	40H		;BIT TO TEST FOR SEND
MODSNDR: EQU	40H		;VALUE WHEN READY
MODRCVB: EQU	80H		;BIT TO TEST FOR RECEIVE
MODRCVR: EQU	80H		;VALUE WHEN READY
MODDCDB: EQU	20H		;CARRIER DETECT BIT
MODDCDA: EQU	0		;VALUE WHEN ACTIVE
MODDATP: EQU	0E8H		;PORT RESET/CARRIER DETECT
MODDATO: EQU	0EBH		;DATA IN/OUT PORT
MSPEED:	 EQU    03CH		;MSPEED-LOADED AFTER BYE SPEED DETECT 	
;
BASE:	 EQU	100H		;start of TPA
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
CONOUT:	 JMP	00000	;CRT out vector (MUST BE JMP 0 IF NOT IMPLEM.)
PMINIT:	 JMP	MINIT	;initialize whatever has to be (or do RET)
PUNINIT: JMP	UNINIT	;undo whatever MINIT did (or RET)
PSENDR:	 JMP	SENDR	;send data byte on stack (POP PSW / OUT)
PCAROK:	 JMP	CAROK	;test for carrier. RET Z=ok, NZ=no carrier
PMDIN:	 JMP	MDIN	;receive data byte
PGETCHR: JMP	GETCHR	;IN from modem data only
PRCVRDY: JMP	RCVRDY	;check receive ready RET Z=ready
PSNDRDY: JMP	SNDRDY	;check send ready RET Z=ready
PSPEED:	 JMP	SPEED	;get speed factor in ACC
PSPARE1: JMP	SPARE	;3 jumps for custom routines
PSPARE2: JMP	SPARE
PSPARE3: JMP	SPARE
;
;-----------------------------------------------------------------------
;
SPARE:	RET			;for later use
MINIT:	RET			;no initialization required
UNINIT:	RET			;not initialized, so no un-initialize.
;.....
;
;
; SNDRDY - check if ready to send
;
SNDRDY:	IN	MODCTLP		;get status byte
	ANI	MODSNDB		;mask off bit to be tested
	XRI	MODSNDR		;set status flag
	RET
;.....
;
;
; SENDR - send character
;
SENDR:	POP	PSW		;get character from stack
	OUT	MODDATO		;send character
	RET
;.....
;
;
; RCVRDY - check receive ready
;   RET with Z = character available.
;   RET error code in A
;
RCVRDY:	IN	MODCTLP
	ANI	MODRCVB		;isolate ready bit
	CPI	MODRCVR		;test it
	MVI	A,0
	RET
;.....
;
;
; MDIN - receive a character (GETCHR is identical)
;
GETCHR:
MDIN:	IN	MODDATO		;get character
	RET			;return it
;.....
;
;
; SPEED - This routine returns the speed code.
;   0=110, 1=300, 2=450, 3=600, 4=710, 5=1200
;   Load your speed byte from low memory, or
;   simply MVI A,n and RET for default speed only
;
SPEED:  LDA	MSPEED		;BYEII is being used with this system
	RET			;check with yours
;.....
;
;
; CAROK - check for presence of carrier.
;   RET with Z = carrier on
;
CAROK:	IN	MODDATP		;get status
	ANI	MODDCDB		;get cd bit
	CPI	MODDCDA		;test bit
	RET
;.....
