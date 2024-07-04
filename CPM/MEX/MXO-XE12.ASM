; MXO-XE10.ASM -- XEROX 820 and 820-II overlay file for MEX10.  05/24/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the XEROX 820 and 820-II computers to MDM7xx.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 08/23/84 - Restored code for manipulating the
;            z80 sio (# of bits and parity) and patch
;            to mask 'DEL' characters going to screen
;            in terminal mode.                  - Mike Komorowski
; 05/24/84 - MEXified overlay			- Biff Bueffel
; 11/11/83 - Renamed to M7XE-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 03/03/83 - Modified MDM705KP for XEROX
;	     820-II computers with external
;	     modems				- David Wurz	
;
;============================================================================
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; MEX service processor stuff
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
PRINT	EQU	9		;MEX/BDOS print-string function call

;
PORT:		EQU	04H		;XEROX 820, II serial output port
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+2		;Modem status port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	04H		;Your bit to test for send
MODSNDR:	EQU	04H		;Your value when send ready		
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO 	;yes=HAYES Smartmodem, no=non-PMMI	104H
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
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO 	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
20H
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
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts	12AH
		OUT	MODCTL1
		IN	MODCTL1		;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port 	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
;
		DS	2		;Not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD	JMP	SETUPR     	;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;				17AH
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
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
;
CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'Mex  Version 1.2 FOR XEROX 820-II'            
		DB	CR,LF,0
		RET
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	GOODBYE1
;
GOODBYE:  MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;WAIT FOR 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;The following are used in setting up the Z80 SIO.
;No need to change for another micro if INIT and SETUP are FALSE.
;
;control bytes
RSTINS	EQU	18H	;reset SIO - register 0
RSTERR	EQU	30H	;reset parity and overrun flags - register 0
REG1INS	EQU	0	;no interrupts - register 1
REG3INS	EQU	0C1H	;8 Rx bits, Rx enable -register 3
RENABL	EQU	1	;Rx enable
REG4INS	EQU	44H	;16X baud rate, 1 stop bit, no parity - register 4
CLK16	EQU	40H	;16X baud rate
REG5INS	EQU	0EAH	;8 Tx bits, Tx enable, RTS, DTR - register 5
ONINS	EQU	8AH	;Tx enable, RTS, DTR - register 5
OFFINS	EQU	68H	;8 Tx bits, Tx enable, no RTS, no DTR -register 5
;End of Z80 SIO specific equates for initialization.
BAUD12	EQU	07H	;1200 baud (SET TO 1200 BAUD FOR MY VERSION- MCK)
;
;The following is used to initialize the Z80 SIO on execution
;of MODEM9.
;
INITMOD:
	MVI	A,5		;MSPEED 1200 baud value
	STA	MSPEED
;
	MVI	A,0		;select register 0
	OUT	MODCTL1 
	MVI	A,RSTINS
	OUT	MODCTL1
      	MVI	A,4
	OUT	MODCTL1
PARM2:	MVI	A,REG4INS
	OUT	MODCTL1
	MVI	A,1		;select register 1
	OUT	MODCTL1
	MVI	A,REG1INS
	OUT	MODCTL1
	MVI	A,3		;select register 3
	OUT	MODCTL1
PARM1:	MVI	A,REG3INS
	OUT	MODCTL1
	MVI	A,5		;select register 5
	OUT	MODCTL1
PARM3:	MVI	A,REG5INS
	OUT	MODCTL1
SETBD:	MVI	A,BAUD12	;now set up for 1200 baud (MK)
	OUT	00
	RET
;
;
;
;The following routine changes the baud rate, stop bits and parity on
;the Z80 SIO from the command level. Note the routine MUST modify the
;parameters used by the INITMOD routine.
;
;The following are parameters/masks used in setting word length
;stop bits and parity for the Z80 SIO.
MSKWD	EQU	0C0H	;word length mask
RSEVEN	EQU	40H	;receive seven bit word
REIGHT	EQU	0C0H	;receive eight bit word
TSEVEN	EQU	20H	;transmit seven bit word
TEIGHT	EQU	60H	;transmit eight bit word
MSKST	EQU	0CH	;stop bit mask
ONE	EQU	04H	;one stop bit
TWO	EQU	0CH	;two stop bits
MSKPA	EQU	03H	;mask for parity bits
NONE	EQU	00H	;no parity
ODD	EQU	01H	;odd parity
EVEN	EQU	03H	;even parity
;
;
SETUPR:	PUSH	H
	CALL	JMP$ILPRT
	DB	'                 UART/Modem Control',CR,LF,LF,LF
	DB	'Current settings -',CR,LF,0
	CALL	SETTIM2
	CALL	GIVEPRM
	CALL	JMP$ILPRT
	DB	CR,LF
	DB	'Enter choices below - <CR> for no change',CR,LF,0
AGAIN:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Baud Rate (300, 600, 1200, 2400, 4800, 9600): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'300',0
	MVI	A,1
	JNC	OK		;go if got match
	CALL	JMP$INLNCOMP
	DB	'600',0
	MVI	A,3
	JNC	OK
	CALL	JMP$INLNCOMP
	DB	'1200',0
	MVI	A,5
	JNC	OK
	CALL	JMP$INLNCOMP
	DB	'2400',0
	MVI	A,6
	JNC	OK
	CALL	JMP$INLNCOMP
	DB	'4800',0
	MVI	A,7
	JNC	OK
	CALL	JMP$INLNCOMP
	DB	'9600',0
	MVI	A,8
	JNC	OK
	CALL	JMP$INLNCOMP
	DB	' ',0
	JNC	AGAIN2
	CALL	JMP$INLNCOMP
	DB	CR,0
	JNC	AGAIN2
	CALL	WRONG
	JMP	AGAIN		;try again
;
OK:	STA	INITMOD+1
	STA	MSPEED
	DCR	A		
	ADD	A
	MVI	D,0
	MOV	E,A
	LXI	H,BD300
	DAD	D
	MOV	A,M		;get baud rate
	STA	SETBD+1		;store in INITMOD
;
AGAIN2:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Word Length (7, 8): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'7',0
	MVI	A,RSEVEN
	MVI	B,TSEVEN
	JNC	OK2
	CALL	JMP$INLNCOMP
	DB	'8',0
	MVI	A,REIGHT
	MVI	B,TEIGHT
	JNC	OK2
	CALL	JMP$INLNCOMP
	DB	' ',0
	JNC	AGAIN3
	CALL	JMP$INLNCOMP
	DB	CR,0
	JNC	AGAIN3
	CALL	WRONG
	JMP	AGAIN2
;
OK2:	STA	RWDLEN
	MOV	A,B
	STA	TWDLEN
;
AGAIN3:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Stop Bits (1, 2): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'1',0
	MVI	A,ONE
	JNC	OK3
	CALL	JMP$INLNCOMP
	DB	'2',0
	MVI	A,TWO
	JNC	OK3
	CALL	JMP$INLNCOMP
	DB	' ',0
	JNC	AGAIN4
	CALL	JMP$INLNCOMP
	DB	CR,0
	JNC  	AGAIN4
	CALL	WRONG
	JMP	AGAIN3
;
OK3:	STA	STPLN
;
AGAIN4:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Parity (None, Even, Odd): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'NONE',0
	MVI	A,NONE
	JNC	OK4		;go if got match
	CALL	JMP$INLNCOMP
	DB	'EVEN',0
	MVI	A,EVEN
	JNC	OK4
	CALL	JMP$INLNCOMP
	DB	'ODD',0
	MVI	A,ODD
	JNC	OK4
	CALL	JMP$INLNCOMP
	DB	' ',0
	JNC	GOSET
	CALL	JMP$INLNCOMP
	DB	CR,0
	JNC	GOSET	
	CALL	WRONG
	JMP	AGAIN4		;try again
;
OK4:	STA	PARIT
;
GOSET:	LDA	RWDLEN
	MOV	B,A
	MVI	A,RENABL
	ADD	B
	STA	PARM1+1
	LDA	TWDLEN
	MOV	B,A
	MVI	A,ONINS
	ADD	B
	STA	PARM3+1
	LDA	STPLN
	MOV	B,A
	LDA	PARIT
	ADD	B
	MOV	B,A
	MVI	A,CLK16
	ADD	B
	STA	PARM2+1
	CALL	JMP$ILPRT
	DB	CR,LF
	DB	'New settings -',CR,LF,0
	CALL	SETTIM2
	CALL	GIVEPRM
	POP	H
	JMP	INITMOD		;reset Z80 SIO
;
GIVEPRM:
	CALL	GETPRM
	CALL	JMP$ILPRT
	DB	'Word length is ',0
	LDA	RWDLEN
	CPI	RSEVEN
	JNZ	NOTSEV
	CALL	JMP$ILPRT
	DB	'seven',0
	JMP	GIVEST
NOTSEV:	CALL	JMP$ILPRT
	DB	'eight',0
GIVEST:	CALL	JMP$ILPRT
	DB	', number of stop bits is ',0
	LDA	STPLN
	CPI	ONE
	JNZ	NOTONE
	CALL	JMP$ILPRT
	DB	'one',0
	JMP	GIVEPA
NOTONE:	CALL	JMP$ILPRT
	DB	'two',0
GIVEPA:	CALL	JMP$ILPRT
	DB	', parity is ',0
	LDA	PARIT
	CPI	NONE
	JNZ	NOTNON
	CALL	JMP$ILPRT
	DB	'none',CR,LF,0
	RET
NOTNON:	LDA	PARIT
	CPI	ODD
	JNZ	NOTODD
	CALL	JMP$ILPRT
	DB	'odd',CR,LF,0
	RET
NOTODD:	CALL	JMP$ILPRT
	DB	'even',CR,LF,0
	RET
;
GETPRM:	LDA	PARM1+1	;get present word length
	ANI	MSKWD	
	STA	RWDLEN
	LDA	PARM2+1	;get stop bits and parity
	MOV	B,A
	ANI	MSKST
	STA	STPLN
	MOV	A,B
	ANI	MSKPA
	STA	PARIT
	RET
;
WRONG:	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	RET
;
SETTIM2:
	LDA	SETUPTST
	ORA	A
	JNZ	SETTIM3
	CALL	JMP$ILPRT
	DB	'Rate for the S mode time-to-send message is set to ',0
	JMP	SETTIM4
SETTIM3:
	CALL	JMP$ILPRT
	DB	'Modem speed is ',0
SETTIM4:
	CALL	BAUDPRT
	RET
;
;Shows baud rates set for 'time to send' file transfer.
;
BAUDPRT:
	LXI	H,BAUDSPD
	MVI	D,0
	LDA	MSPEED		;GET BAUD RATE CODE
	ADD	A		;X2
	MOV	E,A
	DAD	D		;POINT TO CORRECT RATE
	MOV	A,M		;GET FIRST DIGIT
	CALL	0F00CH
	INX	H
	MOV	A,M		;GET SECOND DIGIT
	CALL	TYPE  
	LDA	MSPEED		;CHECK FOR GREATER THAN 1000
	CPI	5
	JC	NOTHOU		;GO IF LESS
	MVI	A,'0'		;PRINT EXTRA 0
	CALL	TYPE  
NOTHOU:	CALL	JMP$ILPRT
	DB	'0 baud',CR,LF,0
	RET
;
;  ON XEROX 820-II this can be replaced by doing a call to 0F00C instead
;    of the call to type
;
TYPE	STA	TYPE1
	CALL	JMP$ILPRT 
	DB	' ',0
	RET
;
BAUDSPD	DB	'11','30','45','60','71','12','24','48','96'
;
;Table of baud rate parameters
BD300:	DW	0005H
BD450:	DW	0000H		;not used
BD600:	DW	0006H
BD710:	DW	0000H		;not used
BD1200:	DW	0007H
BD2400:	DW	000AH
BD4800:	DW	000CH
BD9600:	DW	000EH
RWDLEN:	DB	REIGHT
TWDLEN:	DB	TEIGHT
STPLN:	DB	ONE
PARIT:	DB	NONE
;
BAUDBUF:
	DB	10,0
	DS	10
;
;
EOSMSG:	  DB	11h,0,0,'$'		  	
CLSMSG:	  DB	1AH,0,0,'$'
;
;
;  This is a patch to look for 'DEL' characters which some systems
;    use instead of 'NULL' charaters for timing. The 'DEL' characters
;    don't look good on the screen, so the patch gets rid of them
;    just before they got to the screen.
;	
	ORG	640H	;this is the location I chose, but it can 
;			 be anywhere as long as the call below is the same
	CPI	7FH
	RZ
	PCHL  
;
	ORG 	43A9H	;this changes the instruction just before the
	CALL	0640H	;"console out" routine
;
;
	  END
