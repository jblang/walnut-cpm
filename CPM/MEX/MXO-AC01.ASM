; MXO-AC01 - MEX overlay for the Apple-Cat ][ - jms 84/06/14
;
; This overlay is for use with MEX. It was adapted from the M7AC+3.ASM
;     	overlay for modem7xx.
;
; This version DOES NOT support dialing. It works with either the
;  	MicroSoft Softcard implementation (V2.2) or the ALS CP/M Card
;	(V3.01). See the Customization section equates for details.
;
;
; Please report any bugs, etc. to:
;			James M. Scardelis
;			Director
;			CP/M Plus Users' Group
;			P.O. Box 295
;			Little Falls, NJ 07424-0295
;
; Please upload a copy of any updates to:
;
; 		CNY-Tech RBBS	(315)437-4890
;		CP/M Net East	(201)249-0691
;
;     Both of those systems are 300/1200 baud...
;
; I plan to implement dialing capabilities in the next version of this
;	file, but only for the ALS CP/M CARD!
;
;======================================================================
;
;       Misc. Equates
;
;----------------------------------------------------------------------
		ORG	100H
;
BELL:		EQU	07H		;Bell
CR:		EQU	0DH		;Carriage return
ESC:		EQU	1BH		;Escape
LF:		EQU	0AH		;Line feed
;
YES		EQU	0FFH		
NO		EQU	0H
;
;-----------------------------------------------------------------------
;	A misc. macro to generate i/o subs for the ALSCARD
;-----------------------------------------------------------------------
PUT		MACRO	DUMMY
		PUSH	H
		LXI	H,DUMMY
		JMP	APWRT
		ENDM

;
;=======================================================================
;
; 	Customization Area
;
;-----------------------------------------------------------------------
;
ALSCARD:	EQU	YES		;Yes if ALS CP/M Card
CPM2CARD:	EQU	NO		;Yes if SoftCard or clone
;
MODCTL1:	EQU	0		;Dummy modem control port
MODCTL2:	EQU	0		;Dummy modem control port
;
CATSLOT:	EQU	2		;Slot of Apple-Cat
;
;======================================================================
;
		IF	ALSCARD
;
MAPOFF:		EQU	0		;ALS memory map offset is 0

		ENDIF
;
		IF 	CPM2CARD

MAPOFF:		EQU	2000H		;MicroSoft offset is 2000h

		ENDIF

SLOT		EQU	CATSLOT*16
COM		EQU	0C08CH+SLOT+MAPOFF
XMTBYT		EQU	0C08DH+SLOT+MAPOFF
CON		EQU	0C08AH+SLOT+MAPOFF
BSRBYT		EQU	0C083H+SLOT+MAPOFF
SHBYT		EQU	0C082H+SLOT+MAPOFF
SQUBYT		EQU	0C081H+SLOT+MAPOFF
RECBYT		EQU	0C089H+SLOT+MAPOFF
INDAT		EQU	0C08BH+SLOT+MAPOFF
OUTDAT		EQU	0C08EH+SLOT+MAPOFF
SPDBYT		EQU	0C08BH+SLOT+MAPOFF
STATUS		EQU	0C08FH+SLOT+MAPOFF
DEVBYT		EQU	0C08FH+SLOT+MAPOFF
DACBYT		EQU	0C080H+SLOT+MAPOFF

		IF	CPM2CARD

XMTRAM		EQU	0F01BH		;to clear status 

		ENDIF

		IF	ALSCARD

XMTRAM		EQU	001BH		;to clear status

		ENDIF

MODDCD3		EQU	0		
MODDCD12	EQU	0		;for 212 board
MODRCVB:	EQU	2		;bit to test for receive
MODRCVR:	EQU	2		;value when ready
MODSNDB:	EQU	1		;bit to test for send
MODSNDR:	EQU	1		;value when ready
;
CONOUT		EQU	2		;simulated bdos fcn 2
PRINT		EQU	9		;simulated bdos fcn 9
MEX		EQU	0D00H		;mex's command processor
;
;
; ALS CP/M Card clock is 6mHz; MicroSoft is 2mHz...adjust clock: to
;  match your system.


		DS	3		;Mex has a JMP START here.

PMODEM:		DB	NO
SMODEM:		DB	NO
TPULSE:		DB	'T'
CLOCK:		DB	60		;clock speed x .1, up to 25.5mHz
MSPEED:		DB	1		;0=110 1=300 2=450 3=600 4=710
					;5=1200 6=2400 7=4800 8=9600
					;9=19200

BYTDLY:		DB	5
CRDLY:		DB	5
COLUMS:		DB	5
SETFL:		DB	YES		;must be yes for this overlay
SCRTST:		DB	YES
		DB	0
BAKFLG:		DB	YES		;yes to make .bak file
CRCDFL:		DB	YES		;default to CRC
TOGCRC:		DB	YES
CVTBS:		DB	NO
TOGLBK:		DB	YES
ADDLF:		DB	NO
TOGLF:		DB	YES
TRNLOG:		DB	NO
SAVCCP:		DB	NO
LOCNXT:		DB	YES
TOGLOC:		DB	YES
LSTTST:		DB	YES
XOFTST:		DB	NO
XONWT:		DB	NO
TOGXOF:		DB	YES
IGNCTL:		DB	YES
EXTRA1:		DB	0
EXTRA2:		DB	0
BRKCHR:		DB	'@'-40H	
NOCONN:		DB	'N'-40H
LOGCHR:		DB	'L'-40H
LSTCHR:		DB	'P'-40H
UNSVCH:		DB	'R'-40H
TRNCHR:		DB	'T'-40H
SAVCHR:		DB	'Y'-40H
EXTCHR:		DB	'^'-40H
		DS	2

; Low-level modem i/o routines - will be jump table in mex2.0

INCTL1:		JMP	LDASTAT
		DS	7
OTDATA:		JMP	STAOUTD
		DS	7
INPORT:		JMP	LDADATP
		DS	7

; Bit-test routines

MASKR:		ANI	00001000B ! RET
TESTR:		CPI	00001000B ! RET
MASKS:		ANI	00010000B ! RET
TESTS:		CPI	00010000B ! RET

		DS	12
LOGON:		DS	2
DIALV:		DS	3		;dial routine not yet implemented.
DISCV:		JMP	DISCON
GOODBV:		DS	3
INMODV:		JMP	INITMOD
NEWBDV:		DS	3
NOPARV:		DS	3
PARITV:		DS	3
SETUPV:		JMP	SETUPR
SPMENU:		DS	3
VERSNV:		JMP	SYSVER
BREAKV		JMP	SENDBRK

ILPRTV:		DS	3
INBUFV:		DS	3
ILCMPV:		DS	3
INMDMV:		DS	3
NXSCRV:		DS	3
TIMERV:		DS	3

CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET
CLS:		LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET

;--------------------End of Fixed Format Area-------------------------

SYSVER:		LXI	D,VERSMSG
		MVI	C,PRINT
		CALL	MEX

		IF	ALSCARD
		LXI	D,VERS2MSG
		MVI	C,PRINT
		CALL	MEX
		ENDIF

		RET


SENDBRK:	RET

DISCON:		MVI	A,0
		CALL	STASHBT
		MVI	A,1FH
		CALL	STAXMTB
		CALL	STAXMTR
		MVI	A,0A1H
		JMP	STASQBT

; If you are using a MicroSoft Card, see M7AC+x.ASM for info as to
; what this is all about..

INITMOD:

		IF	CPM2CARD


		LDA	LSTTST
		CPI	0
		JZ	FIRSTIN
		LHLD	0001
		MOV	A,L
		ADI	02AH
		MOV	L,A
		MVI	A,03EH
		MOV	M,A
		INR	L
		MVI	A,0FFH
		MOV	M,A
		INR	L
		MVI	A,0C9H
		MOV	M,A

		ENDIF

		IF 	ALSCARD

		LHLD	1
		LXI	D,60H
		DAD	D
		SHLD	APREAD+1
		INX	H
		INX	H
		INX	H
		SHLD	APWRITE+1
		JMP	FIRSTIN

APREAD:		JMP	$-$
APWRITE:	JMP	$-$

		ENDIF
;
;
;
FIRSTIN:	LDA	80H
		CPI	0
		JZ	NOINMSG
		LDA	5DH
		ANI	0FH
		CPI	3
		JNZ	CK2
		CALL	INIT3
		JMP	ORIG103

CK2:		CPI	2H
		JNZ	NOINMSG
		CALL	INIT2
		JMP	ORIG212

NOINMSG:	RET

INIT3:		CALL	PICKUP
		MVI	A,0A1H
		CALL	STARECB
		MVI	A,00000011B
		CALL	STACON
		MVI	A,22H
		CALL	STASPDB
		MVI	A,1
		STA	MSPEED
		RET

ORIG103:
		MVI	A,11H
		CALL	STAXMTB
		CALL	STAXMTR
		MVI	A,65H
		JMP	STARECB

ANS103:
		MVI	A,10H
		CALL	STAXMTB
		CALL	STAXMTR
		MVI	A,64H
		JMP	STARECB

INIT2:		CALL	PICKUP
		MVI	A,0
		CALL	STASPDB
		MVI	A,18H
		CALL	STAXMTB
		CALL	STAXMTR
		MVI	A,0AH
		CALL	STADEVB
		MVI	A,13H
		CALL	STACON
		MVI	A,05H
		CALL	STACOM
		STA	MSPEED
		RET


ORIG212:	MVI	A,0A1H
		CALL	STASQBT
		CALL	DELAY5
		MVI	A,21H
		JMP	STASQBT

ANS212:		MVI	A,81H
		CALL	STASQBT
		CALL	DELAY5
		MVI	A,01
		JMP	STASQBT

SETORIG:	LDA	MSPEED
		CPI	1
		JZ	ORIG103
		JMP	ORIG212

SETANS:		LDA	MSPEED
		CPI	1
		JZ	ANS103
		JMP	ANS212

PICKUP:
		MVI	A,0A1H
		CALL	STASQBT
		MVI	A,'T'
		STA	5DH
		MVI	A,2
		CALL	STASHBT
		MVI	A,0FH
		CALL	STABSRB
		MVI	A,13H
		CALL	STACON
		MVI	A,05H
		CALL	STACOM
		MVI	A,0
		JMP	STADEVB

SETUPR1:	LXI	D,MENUMSG
		MVI	C,PRINT
		CALL	MEX
		MVI	C,1
		CALL	MEX
		PUSH	PSW
		MVI	E,CR
		MVI	C,CONOUT
		CALL	MEX
		MVI	E,LF
		MVI	C,CONOUT
		CALL	MEX
		POP	PSW
		ANI	01011111B
		CPI	'O'
		JZ	SETORIG
		CPI	'A'
		JZ	SETANS
		CPI	'D'
		JZ	DISCON
		LXI	D,ERRMSG
		MVI	C,PRINT
		CALL	MEX
		JMP	SETUPR1

SETUPR:		LXI	D,BAUDMSG
		MVI	C,PRINT
		CALL	MEX
		MVI	C,1
		CALL	MEX
		PUSH	PSW
		MVI	E,CR
		MVI	C,CONOUT
		CALL	MEX
		MVI	E,LF
		MVI	C,CONOUT
		CALL	MEX
		POP	PSW
		SUI	30H
		CPI	3
		JNZ	CK2A
		CALL	INIT3
		JMP	SETUPR1

CK2A:		CPI	2
		JNZ	NOT2
		CALL	INIT2
		JMP	SETUPR1
NOT2:		LXI	D,ERRMSG
		MVI	C,PRINT
		CALL	MEX
		JMP	SETUPR


DELAY5:		PUSH	PSW
		PUSH	B
		LXI	B,1000

DELAY5A: 	DCX	B
		MOV	A,B
		ORA	C
		JNZ	DELAY5A
		POP	B
		POP	PSW
		RET

;
;   APPLE IO SUBROUTINES
;
		IF	CPM2CARD

STAXMTR:	STA	XMTRAM	! RET
STACOM:		STA	COM	! RET
STAXMTB:	STA	XMTBYT  ! RET
STACON:		STA	CON	! RET
STABSRB:	STA	BSRBYT	! RET
STASHBT:	STA	SHBYT	! RET
STASQBT:	STA	SQUBYT	! RET
STARECB:	STA	RECBYT	! RET
LDAIND:		LDA	INDAT	! RET
STAOUTD:	STA	OUTDAT	! RET
STATSPDB:	STA	SPDBYT	! RET
LDASTAT:   	LDA	STATUS	! RET
STADEVB:	STA	DEVBYT	! RET
LDADATP:	LDA	XMTRAM
		STA	XMTBYT
		LDA	INDAT
		RET

		ENDIF

		IF	ALSCARD


 
STAXMTR:	PUT	XMTRAM
STACOM:		PUT	COM
STAXMTB:	PUT	XMTBYT
STACON:		PUT	CON
STABSRB:	PUT	BSRBYT
STASHBT:	PUT	SHBYT
STASQBT:	PUT	SQUBYT
STARECB:	PUT	RECBYT
STAOUTD:	PUT	OUTDAT
STASPDB:	PUT	SPDBYT
STADEVB:	PUT	DEVBYT

APWRT:		PUSH	D
		PUSH	B
		CALL	APWRITE
		POP	B
		POP	D
		POP	H
		RET

LDADATP:	PUSH	H
		PUSH	D
		PUSH	B
		LXI	H,XMTRAM
		CALL	APREAD
		LXI	H,XMTBYT
		CALL	APWRITE
		LXI	H,INDAT
		JMP	APRD2

LDASTAT:	PUSH	H
		LXI	H,STATUS
		PUSH	D
		PUSH	B
APRD2:		CALL	APREAD
		POP	B
		POP 	D
		POP	H
		RET

		ENDIF

;------------------------------------------------------------------
;  Table of messages that are printed out in the overlay....
;------------------------------------------------------------------

EOSMSG:		DB	'K'-40H,'$'
CLSMSG:		DB	'L'-40H,'$'
VERSMSG:	DB	'Version for Apple Cat ][ modem',CR,LF,'$'
VERS2MSG:	DB	'and ALS CP/M Card',CR,LF,'$'
MENUMSG:	DB	'(O)riginate, (A)nswer, or (D)isconnect $'
ERRMSG:		DB	'Error - must be one of above.',CR,LF,'$'
BAUDMSG:	DB	'(3)00 or 1(2)00 bps: $'

		END
