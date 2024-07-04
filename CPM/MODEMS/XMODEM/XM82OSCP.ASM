;XM82OSCP.ASM - XMODEMxx PATCH FILE FOR Osborne MODEM  01/16/84
;
; This is adapted from Irv Hoff's XMEX-1.ASM dated 11/17/83
;
;		by John Riehl 1-713-644-7070 days
;			      1-713-488-1257 evenings	
;
; This file adapts XMODEMxx to the Osborne 01 with the
; Osborne COMM-PAC modem. To use, first edit any options desired into
; XMODEMxx.ASM, then assemble (can use ASM.COM) and load which supplies
; XMODEMxx.COM.  Then edit this file as needed (check the CONOUT routine
; if you want to locally see file transfer time and the record count
; while programs are being sent).  Then assemble (can use ASM.COM) and
; merge via DDT or SID:
;
;	B>DDT XMODEMxx.COM
;	DDT VERS 2.2
;	NEXT  PC
;	1180 0100
;	-IXM82OSCP.HEX		(note the 'I' command)
;	-R			('R' loads in the .HEX file)
;	NEXT  PC
;	1180 0000
;	-G0			(return to CP/M)
;	B>SAVE 17 XMODEMxx.COM  (now have a modified .COM file)
;
; NOTE: Save 22 (rather than 17) if LOGCAL is YES
;
;=======================================================================
;
; 01/16/84 - Original version adapted from XMEX-1.ASM by Irv Hoff
;					John Riehl	
;
;=======================================================================
; 
YES:	EQU	0FFH
NO:	EQU	0
;
;=======================================================================
;
; The following options must be set as shown in XMODEM82:
;
; LARGEIO:	EQU	YES
; LARSIZE:	EQU	0B0H
;
; USECON:	EQU	NO	;if you are using this XMODEM with BYE3
;
; Only one of the following can be yes and the others no
;
BIOS13:	EQU	NO	;yes = Osborne uses BIOS 1.3
BIOS14: EQU	YES	;yes = Osborne uses BIOS 1.4 or 1.41
BIOS144:EQU	NO	;yes = Osborne uses BIOS 1.44+ 
			;      (Nuevos Electronics 80 column mod.)
;
; If you have none of the above you have to use DDT to find out
; where the 5th JMP instruction in your BIOS jumps to and use it
; for the JMP at 103H. Set all three equates above to NO
;
;=======================================================================
;
MODDATP: EQU	2A01H		;data in port
MODDATO: EQU	MODDATP		;data out port
MODCTLP: EQU	MODDATP-1	;control/status port
MODSNDB: EQU	2		;bit to test for send
MODSNDR: EQU	2		;value when ready
MODRCVB: EQU	1		;bit to test for receive
MODRCVR: EQU	1		;value when ready
MODDCDB: EQU	4		;carrier detect bit
MODDCDA: EQU	4		;value when active
MODPARE: EQU	40H		;value for parity error
MODOVRE: EQU	10H		;value for overrun error
MODFRME: EQU	20H		;value for framing error
;

LSPEED:	EQU	YES		;yes if using 'BYE' with speed selection
				;no if using 'SPEED' manual selection
MSPEED:	EQU	3CH		;location of baud rate factor (set by
				;'BYE')  set location in 'BYE' to agree.
				;3dh and 3eh often used by newer ver-
				;sions of 'ZCPR'.
XSPEED:	EQU	1		;speed for file time transfer without
				;auto-set.  use one of the following:
				;0=110 1=300 2=450 3=600 4=710 5=1200
BASE:	EQU	100H		;start of cp/m normal program area
;
;-------------------------------------------------------------------
;
; Jump table: The jump table must be in exactly the same sequence as the
; one in XMODEM.  Note the ORG of 103H - This jump table has no jump to
; 'BEGIN'.
;
;
	 ORG	BASE+3		;start after 'JMP BEGIN'
;
CONOUT:	  IF	BIOS13
	 JMP	0E915H		;BIOS 1.3 console output routine
	  ENDIF			;BIOS13
;
	  IF	BIOS14
	 JMP	0E738CH		;BIOS 1.4 console output routine
	  ENDIF			;BIOS14
;
	  IF	BIOS144		;BIOS 1.44+ console output routine
	 JMP	0E749H
	  ENDIF			;BIOS144
;
	  IF (NOT BIOS13) AND (NOT BIOS14) AND (NOT BIOS144)
	 JMP	0000H		;put your BIOS console out jump address here
	  ENDIF		;(NOT BIOS13) AND (NOT BIOS14) AND (NOT BIOS144)
;
;
PMINIT:	 JMP	MINIT		;initialization routine (if needed)
PUNINIT: RET ! NOP ! NOP	;not required
PSENDR:	 JMP	SENDR		;send character (via pop psw)
PCAROK:	 JMP	CAROK		;test for carrier
PMDIN:	 JMP	MDIN		;receive data byte
PGETCHR: JMP	GETCHR		;get character from modem
PRCVRDY: JMP	RCVRDY		;check receive ready
PSNDRDY: JMP	SNDRDY		;check send ready
PSPEED:	 JMP	SPEED		;get speed value for file transfer time
POSTAT:  JMP	OSTAT		;get I/O status
PEXTRA1: RET ! NOP ! NOP	;extra for custom routine
PEXTRA2: RET ! NOP ! NOP	;extra for custom routine
;
;=======================================================================
;
; ---> CAROK - check for presence of carrier.  RET with Z = carrier on
;
CAROK:	CALL	POSTAT		;get status
	ANI	MODDCDB		;get carrier detect bit
	PUSH	PSW
	CNZ	MDIN
	POP	PSW
	RET
;
;=======================================================================
;
; ---> GETCHR - - initialize if not already done, then get character
; ---> MDIN - - get a character
;
GETCHR:	CALL	MINIT
MDIN:	JMP	OSIN		;get character from data in port
;
;=======================================================================
;
; This is the Osborne initialization routine which is required
; to relocate the memory mapped above 4000H.
;
INITFLG:  DB	0		;initialization flag
;	
MINIT:	  LDA	INITFLG		;have we been here before?
	  ORA	A
	  RNZ			;if yes, exit
	  INR	A
	  STA	INITFLG
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  LXI	H,OSIN		;get address of first byte to move
	  LXI	D,0A000H	;get place to put first byte
	  LXI	B,RCVRDY-OSIN	;get length of code to move
	  DB	0EDH,0B0H	;Z80 LDIR
;
	  LXI	H,0A000H	;get new address of OSIN
	  SHLD	MDIN+1		;PATCH CALL FOR "GET CHAR." ROUTINE
	  LXI	H,0A000H+OSOUT-OSIN
	  SHLD	SENDR+2		;PATCH CALL FOR "SEND CHAR." ROUTINE
	  LXI	H,0A000H+OSTAT-OSIN
	  SHLD	POSTAT+1	;PATCH CALL FOR "GET STATUS" ROUTINE
	  POP	H
	  POP	D
	  POP	B
	  RET
;
;
; --- Routines that get placed just under 'BYE' ---
;
OSIN:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODDATP		;GET DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;.....
;
;
OSOUT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITDH TO ALTERNATE PAGE
	STA	MODDATO		;SEND DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;.....
;
;
OSTAT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODCTLP		;GET STATUS BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;
;
;=======================================================================
;
; ---> RCVRDY - check receive ready.  RET with Z = character available.
;	        Return with error code in A-reg.
;
RCVRDY:	CALL	POSTAT		;get modem status
	PUSH	B		;save scratch register
	PUSH	PSW		;check error status
	ANI	MODFRME+MODOVRE
	MOV	B,A		;save it for a moment
	POP	PSW
	ANI	MODRCVB		;isolate ready bit
	CPI	MODRCVR		;test it
	MOV	A,B		;get the error code char. back
	POP	B
	RET
;
;=======================================================================
;
; ---> SENDR - send character
;
SENDR:	POP	PSW		;get the character back
	JMP	OSOUT		;send it to the modem output
;
;=======================================================================
;
; ---> SNDRDY - check if ready to send.
;
SNDRDY:	CALL	POSTAT		;get status byte
	ANI	MODSNDB		;isolate ready bit
	CPI	MODSNDR		;ready to send?
	RET
;
;=======================================================================
;
; ---> SPEED - sets the time shown for program transfer.
;
SPEED:	 IF	LSPEED
	LDA	MSPEED		;get index for baud rate from 'BYE'
	 ENDIF
;
	 IF 	NOT LSPEED
	MVI	A,XSPEED	;get index for baud rate from 'XSPEED'
	 ENDIF
;
	RET
;
;=======================================================================
;
	END
