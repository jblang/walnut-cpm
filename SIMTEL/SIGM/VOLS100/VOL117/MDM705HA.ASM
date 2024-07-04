; MDM705HA.ASM -- DCHayes S100 overlay file MDM705.  830326:1727
;
; THIS FILE SUPPORTS COMMUNICATION AT 300 BAUD ONLY, ORIG OR ANSWER.
; GO INTO TERMINAL MODE (T, L, OR E) AND TYPE A CONTROL-D TO DISCONNECT.
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM705.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4180 0100
;		-IMDM705HA.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4200 0000
;		-G0			(return to CP/M)
;		A>SAVE 65 MDM705.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 830326:1728 - Creation - modified from: CF file - Paul Kelley (author)
;			 - modification by Greg Louis with info taken
;				from MODEM221.ASM (*NO guarantees*)
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
TRUE:		EQU	0FFH
FALSE:		EQU	0
;
INITMODADR:	EQU	01F8H		;**THESE ADDRESSES **MUST** BE CHECKED
SETUPRADR:	EQU	242FH		;**BY ANY PROGRAMMER UPDATING SUBSEQUENT
TOGLPAR		EQU	1A1AH		;**RELEASES.  THEY CORRESPOND TO THE
NOLST		EQU	78AH		;**POINTS TO BE MODIFIED IN THE NAMED
S2		EQU	7ADH		;**ROUTINES
DISCONNT	EQU	2713H
PARITY		EQU	3813H
S6		EQU	383CH
DISCON1		EQU	38C1H
ANSWFLG		EQU	4152H
ORIGFLG		EQU	4156H
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
LF:		EQU	0AH		;linefeed
ESC:		EQU	1BH		;escape
;
;
INIT:		EQU	TRUE		;change to TRUE if you have written a
					;routine at location INITMOD in this
					;file to initialize your modem port.
;
SETUP:		EQU	FALSE		;change to TRUE if you have written a
					;routine at location SETUPR to change
					;MSPEED, baud rate, etc.
;
EOSCLR:		EQU	FALSE		;change to TRUE if you have defined the
					;clear to end of screen sequence for
					;your terminal. "Clear to end of screen"
					;is used on returning from terminal mode
					;to keep the screen from getting jumbled
					;if the remote can positon your cursor.
;
SCRNCLR:	EQU	FALSE		;change to TRUE if you have defined the
					;home cursor and clear-screen sequence
					;for your terminal.

PMMI:		EQU	FALSE		;Don't use this file if you have a PMMI
;
;
		 IF	NOT PMMI
MODDATP:	EQU	30H		;data port
MODCTLP:	EQU	MODDATP+2	;modem control port
MODCTL2		EQU	MODDATP+1	;control/status port
MODRCVB:	EQU	1		;bit to test for received data
MODRCVR:	EQU	1		;modem receive ready
MODSNDB:	EQU	2		;bit to test for ready to send
MODSNDR:	EQU	2		;modem send ready bit
ORIGMD		EQU	86H
ANSWMD		EQU	82H
EVN7		EQU	5		;7 bits, even parity
NONE8		EQU	17H		;8 bits, no parity
		 ENDIF			;NOT PMMI
;
;
; THE FOLLOWING VALUES ARE FOR 'CLEAR TO END OF SCREEN'.  CHANGE TO SUIT
; YOUR TERMINAL.  THOSE SHOWN ARE FOR THE HEATH UNITS.  PLACE 'EOSCLR'
; FALSE IF YOU DON'T KNOW YOUR VALUES.
;
		 IF	EOSCLR
CLR1:		EQU	1BH		;ESC-J is the H89 clear to end
CLR2:		EQU	'J'		;of screen sequence
CLR3:		EQU	0		;the unused bytes MUST be 0
CLR4:		EQU	0
		 ENDIF			;EOSCLR
;
; THE FOLLOWING VALUES ARE FOR 'CLEAR SCREEN, LEAVE CURSOR AT TOP LEFT'.
; CHANGE TO SUIT YOUR TERMINAL.  THOSE SHOWN ARE FOR THE HEATH UNITS.
; PLACE 'SCRNCLR' FALSE IF YOU DON'T KNOW YOUR VALUES.
;

		 IF	SCRNCLR
SCLR1:		EQU	1BH		;ESC-E is the H89 home cursor
SCLR2:		EQU	'E'		;and clear screen sequence
SCLR3:		EQU	0		;the unused bytes MUST be 0
SCLR4:		EQU	0
		 ENDIF			;SCRNCLR
;
;
;
; CLOCK SHOULD BE CHANGED TO SUIT YOUR SYSTEM.
; (PMMI USERS SHOULD ALSO CHANGE PULSERATE AND CLDBOOT AS NECESSARY)
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIBYTE:	DB	PMMI	;don't change this line			103H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz maxm	104H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   105H
				;6=2400, 7=4800, 8=9600 default modem speed
				;PMMI and H89 routines reset this value
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   106H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 107H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		108H
SETUPTST:	DB	SETUP	;this line set from EQU above		109H
SCRNTEST:	DB	SCRNCLR	;test for home cursor and clear screen	10AH
				;routine at CLRSCRN, don't change this
BAKUPBYTE:	DB	FALSE	;true=make .BAK file			10BH
CKSUMDFLT:	DB	FALSE	;true=default to Checksum checking	10CH
				;false=default to CRC checking
TOGGLECRC:	DB	TRUE	;true=allow toggling of Checksum to CRC	10DH
CONVBKSP:	DB	FALSE	;true=convert backspace to rub		10EH
TOGGLEBK:	DB	TRUE	;true=allow toggling of bksp to rub	10FH
ADDLF:		DB	FALSE	;true=add LF after CR			110H
TOGGLELF:	DB	TRUE	;true=allow toggling of LF after CR	111H
TRANLOGON:	DB	FALSE	;true=allow transmission of logon	112H
				;write logon sequence at location LOGON
SAVCCP:		DB	TRUE	;true=do not overwrite CCP		113H
LOCONEXTCHR:	DB	FALSE	;true=local command if EXTCHR precedes	114H
				;false=not local command if EXTCHR precedes
TOGGLELOC:	DB	TRUE	;true=allow toggling of LOCONEXTCHR	115H
LSTTST:		DB	TRUE	;true=allow toggling of printer on/off	116H
				;in terminal mode, set to false if your
				;printer can't keep up with the modem
XOFFTST:	DB	FALSE	;true=allow testing of XOFF from remote 117H
				;while transmitting a file in term. mode
XONWAIT:	DB	FALSE	;true=wait for XON after sending CR	118H
				;while transmitting a file in term. mode
TOGXOFF:	DB	TRUE	;true=allow toggling of XOFF testing	119H
EXITCHR:	DB	'E'-40H	;^E = Exit without disconnect		11AH
LOGCHR:		DB	'O'-40H	;^O = Send logon			11BH
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			11CH
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		11DH
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		11EH
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		11FH
EXTCHR:		DB	'^'-40H	;^^ = Send next character		120H
;
;
; Space used only by PMMI routines grouped together here
;
PULSERATE:	DB	250	;125 for 20pps, 250 for 10pps on PMMI	121H
				;not used if PMMI FALSE
CLDBOOT:	DW	0000H	;currently set to warm boot with    122-123H
				;BYE routine for PMMI, put your cold
				;boot entry here if you have one and
				;desire to do on BYE
BRKCHR:		DB	'@'-40H ;^@ = Transmit "BREAK" with PMMI	124H
CHGBAUD:	DB	'B'-40H	;^B = Used with PMMI in terminal	125H
				;mode to change baud rate on fly
DISCCHR:	DB	'D'-40H	;^D = PMMI Disconnect			126H
;
; (End of special PMMI routines)
;
;
IN$MODCTLP:	IN	MODCTL2 ! RET	;in modem control port	     	127H
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI	12AH
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		131H
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI	134H
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13BH
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI	13EH
;
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	145H
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	148H
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	14BH
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14EH
		DS	6		;not changed				145H
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #2	157H
OUT$MODCTLP:	OUT	MODCTLP		;out modem control port		15AH
		DS	9		;line not changed		15CH
;
JMP$SETUPR:				;				165H
;
		 IF 	SETUP	
		JMP	SETUPR
		 ENDIF			;SETUP
;
		 IF	NOT SETUP
		DS	3
		 ENDIF			;NOT SETUP
;
PARTY:		DB	NONE8
PARTOG:		DB	NONE8+EVN7
CLREOS:		CALL	JMP$ILPRT	;				16AH
;
		 IF	EOSCLR
		DB	CLR1,CLR2,CLR3,CLR4,0
		RET
		 ENDIF			;EOSCLR
;
		 IF	NOT EOSCLR
		DB	0,0,0,0,0
		RET
		 ENDIF			;NOT EOSCLR
;
CLRSCRN:	CALL	JMP$ILPRT	;				173H
;
		 IF	SCRNCLR
		DB	SCLR1,SCLR2,SCLR3,SCLR4,0
		RET
		 ENDIF			;SCRNCLR
;
		 IF	NOT SCRNCLR
		DB	0,0,0,0,0
		RET
		 ENDIF			;NOT SCRNCLR
;
JMP$ILPRT:	DS	3		;				17CH
JMP$INLNCOMP:	DS	3		;				17FH
JMP$INBUF	DS	3		;				182H
;
;
		ORG	INITMODADR
;
		IF	(NOT INIT) AND (NOT PMMI)
INITMOD:	RET
		 ENDIF			;NOT INIT AND NOT PMMI
;
;
; *** WARNING - YOUR ROUTINE AT INITMOD CANNOT EXCEED 80 BYTES.   ***
; *** YOUR ROUTINE AT SETUPR CANNNOT EXCEED 900 BYTES.  THESE     ***
; *** OVERWRITE AREAS NORMALLY USED BY THE PMMI INITIALIZATION.   ***
;
	  IF	INIT
INITMOD:  MVI	A,1			;MSPEED 300 baud value
	  STA	MSPEED
;
	  MVI	C,1
	  LDA	PARTY
	  CALL	OUT$MODCTL2
	  LDA	ANSWFLG
	  ORA	A
	  MVI	A,ANSWMD
	  JZ	INTIM1
	  LDA	ORIGFLG
	  ORA	A
	  RNZ
	  MVI	A,ORIGMD
INTIM1:	  ORI	1		;set baud rate 300
OFFHOOK:  LXI	H,1000
OFFDLY:	  DCR	L
	  JNZ	OFFDLY
	  DCR	H
	  JNZ	OFFDLY
	  JMP	OUT$MODCTLP
	  ENDIF			;INIT
	  ORG	NOLST
	  LDA	DISCCHR
	  CMP	B
	  JNZ	S2
	  JMP	DISCON1
	  ORG	TOGLPAR
	  CALL	OUT$MODCTL2
	  ORG	DISCONNT
	  JMP	OUT$MODCTLP
	  ORG	PARITY
	  NOP
	  NOP
	  NOP
	  DS	10
	  JMP	S6
	  END
                                                                                                                                                                                                              