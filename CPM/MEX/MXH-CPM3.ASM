; MXH-CPM3.ASM  --  MEXP hardware overlay for CP/M Plus.
;
; This MEXP overlay includes SET and ABAUD routines (for
; setting and ; automatically changing baud rates) which
; use  generic  CP/M+  BDOS  calls. The SET command also
; allows one to switch between any two CP/M+ i/o devices
; (called modem and xmodem here).  As  such, the overlay
; can be configured for any CP/M+ system  in  which  the
; character i/o device table has been implemented simply
; by  including  the hardware dependent modem and xmodem
; port specifications  in  the tables MODTBL and XMODTBL
; at the end of the overlay.
;
; MXH-CPM3.ASM  was  derived  from  the  general purpose
; overlay  file  M7GP-1.ASM  with  baudrate  code   from
; M7C3-1.ASM by R. Saeks - 5/7/85.
;
VERSION:	EQU	00H		;Version number
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
YES:		EQU	0FFH
NO:		EQU	0
BDOS:		EQU	5
DUMMY:		EQU	0		;dummy byte to be filled in
					;by SETPORT with correct data
;
MODFIRST:	EQU	YES		;yes if modem port at logon
XMODFIRST:	EQU	NO		;yes if xmodem port at logon
;
; The following JUMP instruction is necessary for MEXPLUS
; loadable overlays.
;
		ORG	100H
		DB	0C3H		; JMP instruction for MEX 1.2
		DS	2	;(for  "JMP   START" instruction)
;
; The following DB statements define the initial MEX parameters.
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	08DH	! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	08CH	! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	08CH	! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	02H	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	02H	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	04H	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	04H	! RET	;value of send bit when ready	151H
;
;  Following are two new entry points for MEXPLUS
;  DCDTST returns data-carrier detect in A: 0 if no carrier
;  present, 0FFH if carrier is present, and 0FEH if overlay
;  doesn't know (i.e., doesn't support carrier detect)
;  RNGDET works similarly for ring-detect.
;
DCDTST:	JMP	DCDVEC		;data carrier detect			154H
RNGDET:	JMP	RNGVEC		;ring-detect				157H
;
; End of MEXPLUS added vectors
;
OUT$MODCTL1:	OUT	08DH	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	08DH	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INIT:	JMP	INIT		;go to user written routine	16BH
JMP$ABAUD:	JMP	ABAUD		;auto baud rate change		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER	DS	3		;				192H
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		CALL	JMP$ILPRT	;VT-52 change for 		195H
		DB	ESC,'k',0,0,0	;your terminal			198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;VT-52 change for		19EH
		DB	ESC,'v',0,0,0	;your terminal			1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for CP/M Plus'
		DB	CR,LF,'Hardware Overlay MXH-CPM3'
                DB      VERSION / 10 + ' ',VERSION mod 10 + ' '
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter
; so long as the maximum length for the overlay is not exceeded.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	'How are you today?',CR,LF,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:	RET
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
;
GOODBYE:	RET
;.....
;
;  return data carrier detect status
;      0    = no carrier
;      255  = carrier present
;      254  = we don't know (DCD not supported)
;
DCDVEC:		MVI	A,0FEH		;return 255 if carrier detect
		RET
;......
;
;  return ring-detect status:
;
;     0   =  not ringing
;     255 =  ring detected
;     254 =  we don't know
;
RNGVEC:		MVI	A,0FEH		;return "we don't know"
		RET
;
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INIT:	  	MVI	C,12		;routine to check if CP/M+
		CALL	BDOS		;Get version #
		CPI	30H
		JNC	INITPORT	;jump if CP/M+
		CALL	JMP$ILPRT	;return error message if not CP/M+
		DB	'Requires CP/M Version 3',CR,LF,0
		RST	0

INITPORT:	MVI	A,3EH
		OUT	9DH
		MVI	A,27H
		OUT	8DH
		RET
;
; Routine to automatically set baud rate from data stored
; in phone directory
;
ABAUD:		PUSH	H		;don't alter anybody
		PUSH	D
		PUSH	B
		CPI	1		;check if 300 baud
		JZ	OK300
		CPI	5		;check if 1200 baud
		JZ	OK1200
		CPI	6		;check if 2400 baud
		JZ	OK2400
		CPI	7		;check if 4800 baud
		JZ	OK4800
		CPI	8		;check if 9600 baud
		JZ	OK9600
		STC			;return error for STBAUD caller
		JMP	SETEXIT		;restore BC, DE and HL regs
;
; Routine to set baud rate from command line input
;
SETUPR:		PUSH	H		;don't alter anybody
		PUSH	D
		PUSH	B
SETUPR1:  	CALL	JMP$ILPRT	;display SET message
		DB	CR,LF,'             Input Baud Rate or Port'
		DB	CR,LF,'<300, 1200, 2400, 4800, 9600,'
		DB	' (M)odem, or (X)modem>: ',0
		LXI	D,SETBUF
		CALL	JMP$INBUF	;input command
		LXI	D,SETBUF+2
		CALL	JMP$INLNCOMP
		DB	'300',0		;check if 300 baud
		JNC	OK300
		CALL	JMP$INLNCOMP
		DB	'1200',0	;check if 1200 baud
		JNC	OK1200
		CALL	JMP$INLNCOMP
		DB	'2400',0	;check if 2400 baud
		JNC	OK2400
		CALL	JMP$INLNCOMP
		DB	'4800',0	;check if 4800 baud
		JNC	OK4800
		CALL	JMP$INLNCOMP
		DB	'9600',0	;check if 9600 baud
		JNC	OK9600
		CALL	JMP$INLNCOMP
		DB	'M',0		;check if Modem port
		JNC	SETMOD
		CALL	JMP$INLNCOMP
		DB	'm',0
		JNC	SETMOD
		CALL	JMP$INLNCOMP
		DB	'X',0		;check if Xmodem port
		JNC	SETXMOD
		CALL	JMP$INLNCOMP
		DB	'x',0
		JNC	SETXMOD
		CALL	JMP$ILPRT
		DB	'              ++ Incorrect entry ++',CR,LF,BELL,0
		JMP	SETUPR1		;repeate if incorrect entry


SETMOD:		LXI	H,MODTBL	;load modem port equate table
		CALL	SETPORT		;set MODTBL equates in DUMMY bytes
		JMP	SETEXIT		;restore BC, DE, and HL regs

SETXMOD:	LXI	H,XMODTBL	;load xmodem port equate table
		CALL	SETPORT		;set XMODTBL equates in DUMMY bytes
		JMP	SETEXIT		;restore BC, DE, and HL regs
;
;subroutine to insert port addresses and masks into DUMMY
;bytes in mex I/O subroutines.  Routine enters with the
;address of the port data table in reg hl.
;

SETPORT:
		MOV	A,M		;get modem control port
		STA	IN$MODCTL1+1
		STA	OUT$MODCTL1+1
		STA	OUT$MODCTL2+1
		INX	H		;get modem data port
		MOV	A,M
		STA	OUT$MODDATP+1
		STA	IN$MODDATP+1
		INX	H		;get carrier detact bit
		MOV	A,M
		STA	DCDVEC+5
		INX	H		;get receive ready bit
		MOV	A,M
		STA	ANI$MODRCVB+1
		INX	H		;get receive ready mask
		MOV	A,M
		STA	CPI$MODRCVR+1
		INX	H		;get trans ready bit
		MOV	A,M
		STA	ANI$MODSNDB+1
		INX	H		;get trans ready mask
		MOV	A,M
		STA	CPI$MODSNDR+1
		INX	H		;get CPM3 device number
		MOV	A,M
		STA	DEVICE
;
;routine to compute the address of baudrate parameter
;in the CPM3 char i/o device table for the specified device.
;

ADCHRTBL:	MVI	A,20		;BIOS call to return character I/O
		STA	FUNC		;device table address
		MVI	C,50		;cp/m+ direct BIOS call
		LXI	D,FUNC		;direct BIOS call data structure
		CALL	BDOS
		PUSH	H		;Save the table address
		LXI	H,7		;Offset to baudrate
		LDA	DEVICE
		ORA	A
		JZ	ISZERO		;jump if cp/m+ i/o device # 0
		LXI	D,8

DEVLP:		DAD	D		;add (8xDEV #) to baudrate offset
		DCR	A
		JNZ	DEVLP

ISZERO:		POP	D		;Get Table address
		DAD	D		;Form baudrate address
		SHLD	BAUDAD		;save baudrate address for DEV #
		RET
;
;subroutines to load mspeed and cp/m+ baudrate codes 
;
						;baudrate  mspeed  cpm3
OK300:		MVI	A,1	;300 baud	;           code   code
		MVI	B,6			;-----------------------
		JMP	LOADBD			;300          1     6
						;600          3     7
OK1200:		MVI	A,5	;1200 baud	;1200         5     8
		MVI	B,8			;2400         6    10
		JMP	LOADBD			;4800         7    12
						;9600         8    14
OK2400		MVI	A,6	;2400 baud	;19200        9    15
		MVI	B,10
		JMP	LOADBD

OK4800		MVI	A,7	;4800 baud
		MVI	B,12
		JMP	LOADBD

OK9600		MVI	A,8	;9600 baud
		MVI	B,14	;fall through to LOADBD
;
;routine to store mspeed baudrate code (reg a) in MSPEED and
;cp/m+ baudrate code (reg b) at (BAUDAD) in i/o device table
;and to reset the i/o port to the new baudrate.
;

LOADBD:		STA	MSPEED		;store mspeed
		LHLD	BAUDAD		;set CPM3 char table
		MOV	M,B
		LDA	DEVICE		;reset device
		MOV	L,A		;store cp/m+ device number
		MVI	H,0		;in "reg c" of direct BIOS
		SHLD	BCREG		;data structure
		MVI	A,21		;device init BIOS call
		STA	FUNC
		MVI	C,50		;cp/m+ direct BIOS call
		LXI	D,FUNC		;direct BIOS call data structure
		CALL	BDOS
SETEXIT:	POP	B		;restore BC, DE, and HL regs
		POP	D
		POP	H
		RET
;
DEVICE:		DB	DUMMY		;storage for cp/m+ device number
SETBUF:		DB	10,0
		DS	2

FUNC:		DS	1		;cp/m+ direct BIOS call
AREG:		DS	1		;data structure
BCREG:		DS	2
DEREG:		DS	2
HLREG:		DS	2
BAUDAD:		DS	2		;storage for baudrate address
					;in char i/o device table
;
;Equates for Modem port (set for CompuPro Interfacer 4)
;
MODBASE:	EQU	08CH
;
MODTBL:
	DB	MODBASE+1		;modem control/status port
	DB	MODBASE			;modem data port
	DB	040H			;mask for carrier detect bit
	DB	02H			;mask to test for receive
	DB	02H			;value when receive ready
	DB	04H			;mask to test for send
	DB	04H			;value when ready to send
	DB	8			;cp/m+ device number
;
;Equates for Xmodem port (set for Zilog DART)
;
XMODBASE:		EQU	08CH
;
	XMODTBL:
	DB	XMODBASE+1		;modem control/status port
	DB	XMODBASE		;modem data port
	DB	040H			;mask carrier detect bit
	DB	02H			;mask to test for receive
	DB	02H			;value when receive ready
	DB	04H			;mask to test for send
	DB	04H			;value when ready to send
	DB	9			;cp/m+ device number
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
;.....
;
	  END
;
tructure
BCREG:		DS	2
DEREG:		DS	2
HLREG:		DS	2
BAUDAD:		DS	2		;storage for baudrate addr