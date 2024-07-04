;//////////////////////////////////////////////////////////////////////////////
;
     TITLE  'MEX Overlay for Toshiba T100 and Serial Interface Adapter '
;
;	NOTE - this overlay is designed to be specific for a Toshiba T00
;	together with a Hayes Smartmodem 300/1200 driven in conjunction with
;	a Toshiba Support Group Serial Async Interface Adapter. 
;
;	--- A very good starting point for ANY 2651 usart IO device, however.
;	 
;//////////////////////////////////////////////////////////////////////////////
;
REV	EQU	10		; revision number * 10
;
;******************************************************************************
;
;	One problem with the Toshiba T100 is the inabillity to do 1200
;	bps. This is due to the fact that Toshiba, for some reason - which is
;	completely beyond comprehension of civilized man - had decided to 
;	implement a software usart on an 8255 PIA. It is impossible to get 
;	1200 bps out of the infernal thing. Need I say that 300 bps gets
;	a bit frustrating to sysops, including myself. Well, to solve the
;	problem, I've designed a serial interface with a National INS2651 
;	usart to get up to 19.2K baud out of the Tosh. (I don't own a Tosh, 
;	but I got tired of all of the bitching about not being able to do 
;	1200 with the thing). Tha adapter plugs into the rampack 2 expansion 
;	slot. You still can use slot 1 for the prom expansion. 
;
;	Tosh does furnish a serial port adapter - matter of fact, they are 
;	glad to sell you one. So would I at $400.00+ - arrghhhh ... gag me with
;	a microchip.... whats that old saying coined by Ward.....
;
;			   Sempus Non Rippus Offis
;
;	My adapter goes for about 40 bucks (+/-) in small quanity. If there 
;	is a demand for it, this will be reduced as it costs a lot less to 
;	build 100 of 'em than it does 10. If you are 1) a poor soul with a 
;	Tosh, 2) are tired of paying Ma Bell and 3) would really like to do 
;	1200/2400 all the way up to 19,200 (dream on, we all wish...) baud on 
;	dialups, then contact me, the Sysop at Smokin Silicon RCP/M to leave 
;	a private message in 'TOS' - Ill get back to you. Smokin Silicon is 
;	the central point for the Toshiba Support group. If Toshiba won't 
;	support it at a reasonable price, We will. I'll be happy to fill yall 
;	in on the details. Flawless performance in computer <=> computer batch 
;	xfers with MEX at 9600 bps. This is the first in a series of RCPM 
;	overlays to support the serial adapter and the machine. 
;
;					    modem to the max / happy hacking
;			
;						    JP Sojak - sysop -
;					           Smokin Silicon RCP/M
;					           (312)941-0049 24 hrs 
;
;  ps - if you have a special problem with your machine, Ill try to help out.
;       By helping you out, many benifit. (Sempus Non Rippus Offis - FIGHT
;	BACK - don't put up with the garbage many manufactures try to feed 
;	you) 
;	
;******************************************************************************
;
;  02/24/84 ... mxo-tsa.asm   (for TS A-dapter)
;
;		Base version for a Toshiba T100 and a serial adapter. Roots
;		are everywhere by a cast of thousands. Thanks all... 
;		- Especially Ron Fowler for doing the single most important
;		public domain work since the original Modem7
;		
;						    		JP Sojak 
;
;//////////////////////////////////////////////////////////////////////////////
;
;	There is a Zilog SIO style full featured SET command implemented on
;	the INS2651 USART device ... The SET is specific to Smartmodem 
;	compatables. The available commands are:
;
;	delay <n> (seconds) .... SET the delay between dial and "NO CARRIER"
;	baud <rate> 110-19.2k .. SET the baud rate 110-19.2K, no 450 and 710
;	orig (originate mode) .. SET the modem originate (callout) carrier 
;	answer	(answer mode) .. SET the modem answer (callin) carrier 
;	tone ................... SET touch tone dialing
;	pulse .................. SET pulse dialing
;       monitor ................ SET the speaker ON
;	quiet .................. SET the speaker OFF
;	parity ................. SET the parity to odd, even, or none
;	stop ................... SET 1, 1.5, or 2 stopbits
;	bits ................... SET 5, 6, 7, or 8 bit data word length
;	digit .................. SET the interdigit dial time in mS 
;
;	"SET" <cr> will bring up the current settings.
;	"SET ?"<cr> will bring up the syntax for the SET commands available. 
;	And additionally, all 'SET'tings are 100% cloneable to new defaults.
;
;//////////////////////////////////////////////////////////////////////////////
;
; adapter port definitions
;
BASEP	EQU	018H		; port base address
DATAPT	EQU	BASEP		; serial data port
SPORT	EQU	BASEP+1		; status register
MODE1	EQU	BASEP+2		; first mode register
MODE2	EQU	BASEP+2		; second mode register
CPORT	EQU	BASEP+3		; command register
;	
;
; 2651 usart bit definitions
;
MDRCVB	EQU	00000010B	; modem receive bit (dav)
MDRCVR	EQU	00000010B	; modem receive ready
MDSNDB	EQU	00000001B	; modem send bit
MDSNDR	EQU	00000001B	; modem send ready bit
MDMDTR	EQU	00000010B	; modem data trm ready bit
;
; PLEASE NOTE ... The use of DCD (Data Carrier Detect) status register bit
; within the USART should be avoided. It is actually a Tx enable for the
; hardware. It MUST be pulled high on the EIA cable or the USART will seem
; to "hang". When it is active, the initialization routine thinks there 
; is returning from CP/M with a carrier present even when there isnt - 
; improper switch settings could unconditionally force an active (HIGH) state 
; - and abort the routine. The adapter has been defaulted with a pullup to 
; avoid "hanging" the hardware if the DCD #8 is left unconnected. It is 
; desirable to redefine the carrier sence bit to DSR #6 (Data Set Ready). It 
; is customary to leave DCD #8 open on the interface side and connect DCD #8 
; from the modem to DSR #6 (Data Set Ready) on the interface side. In this 
; way, the USART will never "hang". If you wish to use DCD then by all means 
; do so. As a matter of fact, ANY rcpm work REQUIRES it, but if you do not
; follow what all of this is about, then it is best to leave the equate as 
; is and prepare a cable as follows.... 
;
;	MODEM			 INTERFACE
;	(DCE)			   (DTE)
;
;	#1 <------------------------> #1  water pipe ground (optional)
;	#2 <------------------------> #2  \
;					   (Tx and Rx data)
;	#3 <------------------------> #3  / 
;
;	#7 <------------------------> #7  Signal Ground
; (DCD)	#8 <------------------------> #6  Data Set Ready
;      #20 <------------------------> #20 Data Terminal Ready
;
;
;MDMDCD	EQU	01000000B	; DCD used to sence carrier present 
;
MDMDCD	EQU	10000000B	; DSR used to sence a carrier present 	
;
;
;******************************************************************************
;
; Status register definitions within the 8251 USART device:
;
;	MODE 0 REGISTER (base + 2)
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;  | 00 - invalid    | X0 - no parity  | 00 - 5 bits     |     must be     |
;  | 01 - 1 stop     | 01 - odd        | 01 - 6 bits     |   1    |   0    |
;  | 10 - 1.5 stop   | 10 - no parity  | 10 - 7 bits     | for the adapter |
;  | 11 - 2 stops    | 11 - even       | 11 - 8 bits     |        |        |
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;
;	MODE 1 REGISTER (base + 2)
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;  |        |        |     must be     | internal baud rate select register|
;  |   X    |   X    |   1    |   1    |        +        +        +        |
;  |        |        |  for the adapter|   B3   |   B2   |   B1   |   B0   |
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;
; Where the internal generator is selected and is represented by:
;
;	NOTE - some of these are NOT supported by MEX - the USART does em,
;		but MEX has no idea they exist.
;	
;   Bx=	3 2 1 0			|  3 2 1 0
;   ----------------------------+-------------------------------
;	0 0 0 0 .... 50 baud	|  0 0 0 1 .... 75 baud
;	0 0 1 0 .... 110 baud	|  0 0 1 1 .... 134.5 baud
;	0 1 0 0 .... 150 baud	|  0 0 0 1 .... 300 baud
;	0 1 1 0 .... 600 baud	|  0 1 1 1 .... 1200 baud
;	1 0 0 0 .... 1800 baud	|  1 0 0 1 .... 2000 baud
;	1 0 1 0 .... 2400 baud	|  1 0 1 1 .... 3600 baud
;	1 1 0 0 .... 4800 baud  |  1 1 0 1 .... 7200 baud
;	1 1 1 0 .... 9600 baud	|  1 1 1 1 .... 19.2K baud
; 	
;	COMMAND	REGISTER (base + 3)
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;  | 00 - normal     | RTS    | ERROR  | FORCE  | RECV   | DTR    | TRNSMT |
;  | 01 - auto echo  | CTRL   | RESET  | BREAK  | CTRL   | CTRL   | CTRL   |
;  | 10 - lcl lopbak | 0 - hi | 0 -norm| 0 -norm| 0 -dsbl| 0 -hi  | 0 -dsbl|
;  | 11 - rmt lopbak | 1 - lo | 1 -rst | 1 -brk | 1 -enbl| 1 -lo  | 1 -enbl|
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;
;	STATUS REGISTER (base + 1)
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;  |        |        | FRAME  | OVERRUN| PARITY |Tx SHIFT| Rx CHAR| Tx BUFR|
;  | DSR lo | DCD lo | ERROR  | ERROR  | ERRORY |REGISTER| READY  |  EMPTY |
;  |        |        |        |        |        | EMPTY  |        |        |
;  +--------+--------+--------+--------+--------+--------+--------+--------+
;
;	MODE 1 register must be written into before MODE 2 - it is a toggle 
;	type operation. a COMMAND register <read> operation will reset the
;	toggle so the next MODE operation will be performed on the first 
;	register - REGISTER 1.
;
;******************************************************************************
;
; standard mex service processor hooks
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to a, cy=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg b
TMDINP	EQU	253		;b=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^c from kbd, z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see cmdtbl comments for info
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
CONOUT	EQU	2		;simulated bdos function 2: console char out
PRINT	EQU	9		;simulated bdos function 9: print string
INBUF	EQU	10		;input buffer, same structure as bdos 10
;
; msc crud
;
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
DING	EQU	'G'-40H
;
YES	EQU	0FFFFH		;it is so
NO	EQU	NOT YES 	;it is not so
;
;//////////////////////////////////////////////////////////////////////////////
;
	ORG	TPA
;
;//////////////////////////////////////////////////////////////////////////////
;
	DS	3		;mex has a jmp start here
	DS	2		;not used by mex
TPULSE:	DB	'T'		;t=touch, p=pulse (used by this overlay)
CLOCK:	DB	40		;clock speed x 10 (up to 25.5 mhz.)
MSPEED:	DB	5		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after crlf in terminal
				;mode file transfer for slow bbs systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined set command
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at clrscrn
	DB	0		;was once acknak, now spare
BAKFLG:	DB	YES		;yes=make .bak file
CRCDFL:	DB	YES		;yes=default to crc checking
				;no=default to checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of checksum to crc
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no lf after cr to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of lf after cr
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location logon
SAVCCP:	DB	YES		;yes=do not overwrite ccp
LOCNXT:	DB	NO		;yes=local cmd if extchr precedes
				;no=not local cmd if extchr precedes
TOGLOC:	DB	YES		;yes=allow toggling of locnxtchr
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. set to no if using
				;the printer port for the modem
XOFTST:	DB	NO		;yes=allow testing of xoff from remote
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for xon after sending cr while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of xoff testing
IGNCTL:	DB	NO 		;yes=do not send control characters
				;above ctl-m to crt in terminal mode
				;no=send any incoming ctl-char to crt
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^n = disconnect from phone line
LOGCHR:	DB	'L'-40H		;^l = send logon
LSTCHR:	DB	'P'-40H		;^p = toggle printer
UNSVCH:	DB	'R'-40H		;^r = close input text buffer
TRNCHR:	DB	'T'-40H		;^t = transmit file to remote
SAVCHR:	DB	'Y'-40H		;^y = open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = send next character
;
	DS	2		;not used
;
; low-level modem i/o routines.
;
INCTL1:	JMP	INC		;in modem control port
	DB	0,0,0,0,0,0,0	;spares if needed for non-pmmi
;
OTDATA:	JMP	OUTD		;out modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non=pmmi
;
INPORT: JMP	IND		;in modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non-pmmi
;
; bit-test routines. 
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
	DS	12
;
LOGON:	DS	2		;needed for mdm compat, not ref'D BY MEX
DIALV:	JMP	DIAL
DISCV:	JMP	DISCON
GOODBV:	JMP	GOODBYE		;called before exit to cp/m
INMODV:	JMP	NITMOD		;initialization. called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	RET!NOP!NOP		;set modem for no-parity
PARITV:	RET!NOP!NOP		;set modem parity
SETUPV:	JMP	SETCMD		;set cmd: jump to a ret if you don'T WRITE SET
SPMENV:	RET!NOP!NOP		;not used with mex
VERSNV:	JMP	SYSVER		;overlay'S VOICE IN THE SIGN-ON MESSAGE
BREAKV:	JMP	SBREAK		;send a break
;
; mdm calls supported in mex 1.0 but not recommended for use.
;
ILPRTV:	DS	3		;replace with mex function 9
INBUFV:	DS	3		;replace with mex function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with mex function 255
NXSCRV:	DS	3		;not supported by mex (returns w/no action)
TIMERV:	DS	3		;replace with mex function 254
;
; terminal specific control sequences
;
; if you wish to use the terminal screen operations, uncomment the code below 
; and insert your terminal specific routines at the clsmsg and eosmsg string 
; areas.
;	
CLREOS:		
;	lxi	d,eosmsg
;	mvi	c,print
;	call	mex
	RET
;
CLS:	
;	lxi	d,clsmsg
;	mvi	c,print
;	call	mex
	RET
;
; put your terminal specific strings here ... (I don't know what they are) 
;	... dont forget the '$'
;
EOSMSG:	  DB	17H,'$'		;clear to end-of-screen
CLSMSG:	  DB	1AH,'$'		;clear whole screen
;
;------------------------------------------------------------
;
; input control/status port
;
INC:	IN	SPORT		; get the status bits
	RET
;
; input data port
;
IND:	IN	DATAPT		
	RET
;
; output data port
;
OUTD:	OUT	DATAPT
	RET
;
; print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	'Toshiba Support Group Serial Interface',CR,LF
;	  DB	'Trashiba T100 - V' 	;he.. he.. he...
	  DB	'Toshiba T100 - V'	
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
	  DB	CR,LF
	  DB    0
	  RET
;
; send break routine
;
SBREAK: 
;
; disconnect routine
;
DISCON:   
;
; goodbye routines are called by mex prior to exit to cp/m
;
GOODBYE:MVI	A,00011101B	; drop cts, dtr and force break a
	OUT	CPORT
	MVI	B,3		; 300 ms
	CALL	MTIME
	MVI	A,00100111B	; initial default
	OUT	CPORT
	RET
;
; initialize rs-232 to default modes.
;
NITMOD: CALL	INC		;see if carrier ie returning to mex with
	ANI	MDMDCD		;a call active 
	RNZ			;skip if connected

	LDA	SPEED		; load default ascii baud rate 
	STA	MSPEED		;and keep it current
	CALL	PBAUD		;set the baud rate
;
; default the modem to either speaker ON or OFF - as CLONED
;
	LDA	MONFLG		;get monitor default
	ORA	A
	MVI	A,'0'		;speaker off
	JZ	NIT4
	MVI	A,'1'		;speaker on

NIT4:  	STA	SMINIT+3	;put it in sminit string
;
; default the modem mode to either answer or originate - as CLONED
; 
	LDA	ANSFLG		;get mode default
	ORA	A
	MVI	A,'0'		;originate
	JZ	NIT5
	MVI	A,'1'		;answer

NIT5:  	STA	S0NIT+3		;put it in sminit string
;
; set up the modem with the initial string 
;	
	LXI	H,SMINIT
SINIT:	CALL	SMSEND		;send the init string
SMTLP1:	MVI	C,INMDM		;wait for modem response
	CALL	MEX
	JNC	SMTLP1		;eat everything until silence for
	RET			; 100 msec
;
; set command processor
;
SETCMD:	  MVI	C,SBLANK	;any arguments?
	  CALL  MEX
	  JC	SETSHO		;if not, display default(s)
	  LXI	D,CMDTBL
          MVI	C,LOOKUP
	  CALL  MEX		;parse the argument
	  PUSH	H		;save any parsed arguments on stack
	  RNC			;if we have one, return to it
	  POP	H		;oops, input not found in table
SETERR:	  LXI	D,SETEMS
	  MVI	C,PRINT
	  CALL	MEX
	  CALL  CRLF
	  RET
SETEMS:	  DB	CR,LF,'Unrecognized SET command',DING,CR,LF,'$'
;
SETBAD:	  LXI	D,SETBMS
	  MVI	C,PRINT
	  CALL	MEX
	  RET
SETBMS:	  DB	CR,LF,'Invalid SET parameter',DING,CR,LF,'$'
;
; argument table
;
CMDTBL:   DB	'?'+80H			; help
	  DW	SETHELP
	  DB	'ORI','G'+80H		; originate mode
	  DW	ORIG
	  DB	'ANSWE','R'+80H		; answer mode
	  DW	ANS
	  DB	'TON','E'+80H		; tone dialing
	  DW	STTONE
	  DB	'PULS','E'+80H		; pulse dialing
	  DW	STPULSE
	  DB	'MONITO','R'+80H	; monitor on
	  DW	MONIT
	  DB	'QUIE','T'+80H		; monitor off
	  DW	QUIET
	  DB	'BAU','D'+80H		; set baud
	  DW	STBAUD
	  DB	'DELA','Y'+80H		; set delay
	  DW	DELAY
	  DB	'PARIT','Y'+80H		; set parity
	  DW	STPRTY
	  DB	'STO','P'+80H		; set stopbits
	  DW    STSTOP
	  DB	'BIT','S'+80H		; set length
	  DW	STBITS
	  DB	'DIGI','T'+80H		; set inter-digit delay
	  DW    SDIGIT
	  DB	0			;table terminator
;
;  "set (no args): print current statistics
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'Current settings:',CR,LF,0
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL  CRLF
	  CALL	MONSHO
	  CALL	CRLF
	  CALL  SHOWP
	  CALL	CRLF
	  CALL	SHOWS
	  CALL	CRLF
	  CALL  SHOWBT
	  CALL  CRLF
	  CALL	DLSHOW
	  CALL	CRLF
	  CALL	DDSHOW
	  CALL  CRLF
	  CALL  CRLF
	  RET
;
; "set ?" processor
;
SETHELP:  CALL	MILP
	  DB	CR,LF,'SET ORIG      - Modem Originate mode'
	  DB	CR,LF,'SET ANSWER    - Modem Answer mode'
	  DB	CR,LF,'SET TONE      - Touch Tone dial'
	  DB	CR,LF,'SET PULSE     - Dial Pulse dial'
	  DB	CR,LF,'SET PARITY    - None, Even or Odd'
	  DB	CR,LF,'SET STOP      - 1, 1.5 or 2'
	  DB	CR,LF,'SET BITS      - 5, 6, 7 or 8'
	  DB	CR,LF,'SET QUIET     - Speaker Off'
	  DB	CR,LF,'SET MONITOR   - Speaker On'
	  DB	CR,LF,'SET BAUD <X>  - <X> = 110, 300, 600, 1200, 2400, '
	  DB	'4800, 9600, 19200'
	  DB	CR,LF,'SET DELAY <X> - <X> seconds'
	  DB	CR,LF,'SET DIGIT <X> - <X> 0-99 mS'	
	  DB	CR,LF,CR,LF,0
	  RET
;
; "set baud" processor
;
STBAUD:	  	MVI	C,BDPARS	;function code: parse a baudrate
	  	CALL	MEX		;let mex look up code
	  	JC	SETERR		;jump if invalid code
	  	CALL	PBAUD		;no, try to set it
	  	JC	SETERR		;if not one of ours, bomb out
;
; let MEX print the baud rate
;
BDSHOW:	  	LDA	MSPEED		;get current baud rate
	  	MVI	C,PRBAUD	;let mex print it
	  	CALL	MEX
	  	RET 
;
; this routine sets baud rate passed as mspeed code in a.
; returns cy=1 if baud rate not supported.
;
PBAUD:	  	PUSH	H		;don't alter anyboby
	  	PUSH	D
	  	PUSH 	B
;
		LXI	H,BAUDS		; get the table base
		MOV	E,A
		MVI	D,00
		DAD	D		; offset it
		MOV	A,M
		CPI	11111111B	; is it bad ?
		STC
		JZ	BADEX		; yup - quit now
;
; selected rate is good ... save parameters
;
		STA	DFTBAUD		; setup for reinitialization
		MOV	A,E
		STA	SPEED		; save it in case of CLONE command
		STA	MSPEED
		CALL	SINITL		; reinitialize the usart
		STC		
		CMC			; no error here
BADEX:		POP	B
	  	POP	D
	  	POP	H
		RET
;
; lookup table for all of the valid bit rates 
;
BAUDS:		DB	00000010B	; 110 baud
		DB	00000101B	; 300 baud
		DB	11111111B	; 450 baud	
		DB	00000110B	; 600 baud
		DB	11111111B	; 710 baud
		DB	00000111B	; 1200 baud
		DB	00001010B	; 2400 baud
		DB	00001100B	; 4800 baud
		DB	00001110B	; 9600 baud
		DB	00001111B	; 19.2k baud
;
; "set mode" processor
;
ORIG:	XRA	A
	STA	ANSFLG		;set orig flag
	LXI	H,SMO		;send out ats0=0
	CALL	SINIT
	CALL	MILP
	DB	'Originate mode',0
	RET
;
ANS:	MVI	A,0FFH
	STA	ANSFLG		;set ans flag
	LXI	H,SMA		;send out ats0=1
	CALL	SINIT
	CALL	MILP
	DB	'Answer mode',0
	RET
;
SMO:	DB	'ATS0=0',CR,0
SMA:	DB	'ATS0=1',CR,0
;
;
; "monitor" processor
;
QUIET:	XRA	A
	STA	MONFLG
	LXI	H,SMQT
	CALL	SINIT
	JMP	MONSHO

MONIT:	MVI	A,0FFH
	STA	MONFLG
	LXI	H,SMMON
	CALL	SINIT

MONSHO:	LDA	MONFLG
	ORA	A
	JZ	MONOFF
	CALL	MILP
	DB	'Speaker On',0
	RET

MONOFF:	CALL	MILP
	DB	'Speaker Off',0
	RET

SMQT:	DB	'ATM0',CR,0
SMMON:	DB	'ATM1',CR,0
;
; "dial" processor
;
STTONE:	MVI	B,'T'
	JMP	SDIAL1
STPULSE:MVI	B,'P'

SDIAL1: LDA	TPULSE
	CPI	B
	JZ	TPSHOW
	MOV	A,B
	STA	TPULSE
	CPI	'P'
	MVI	A,01010000B	;pulse dial
	JZ	SDIAL2
	MVI	A,01000000B	;tone dial
SDIAL2: STA	DIALWD

TPSHOW:	LDA	DIALWD
	ANI	00010000B
	JZ	TPTONE

	CALL	MILP
	DB	'Pulse Dial',0
	RET

TPTONE:	CALL	MILP
	DB	'Tone Dial',0	  
	RET
;
; "delay" processor
;
DELAY:	MVI	C,EVALA
	CALL	MEX
	MOV	A,H
	ORA	A
	JNZ	SETERR
	MOV	A,L
	CPI	100		;too big ?
	JNC	SETERR

	PUSH	D		; convert binary to ascii
	CALL	CVDCML
	MOV	A,D
	STA	S7NIT+3		; 10's digit
	STA	LDSTR+5
	MOV	A,E
	STA	S7NIT+4		; 1's digit
	STA	LDSTR+6
	POP	D

	LXI	H,LDSTR		; send the local string to the modem
	CALL	SMSEND

DLSHOW:	CALL	MILP		;finally tell the user about it
	DB	'Answer delay is ',0
;
	LDA	S7NIT+3		;print 10'S DIGIT
	MOV	E,A	
	MVI	C,CONOUT
	CALL	MEX
;
	LDA	S7NIT+4		;print 1'S DIGIT
	MOV	E,A	
	MVI	C,CONOUT	
	CALL	MEX
;
	CALL	MILP		;print units
	DB	' Seconds.',0
	RET

LDSTR:	DB	'ATS7=30',CR,0

;
; "digit" processor - interdigit time 
 
SDIGIT:	MVI	C,EVALA
	CALL	MEX
	MOV	A,H
	ORA	A
	JNZ	SETERR
	MOV	A,L
	CPI	100		;too big ?
	JNC	SETERR
;
	PUSH	D		; convert binary to ascii
	CALL	CVDCML
	MOV	A,D
	STA	S11NIT+4	; 10's digit
	STA	LSTR+6
	MOV	A,E
	STA	S11NIT+5	; 1's digit
	STA	LSTR+7
	POP	D
;
	LXI	H,LSTR		; send the local string to the modem
	CALL	SMSEND

DDSHOW:	CALL	MILP		;finally tell the user about it
	DB	'Dial digit time is ',0
;
	LDA	S11NIT+4		;print 10'S DIGIT
	MOV	E,A	
	MVI	C,CONOUT
	CALL	MEX
;
	LDA	S11NIT+5		;print 1'S DIGIT
	MOV	E,A	
	MVI	C,CONOUT	
	CALL	MEX
;
	CALL	MILP		;print units
	DB	' Ms.',0
	RET

LSTR:	DB	'ATS11=40',CR,0
;
; convert to ascii the hard way
;
CVDCML:	MVI	B,0		; make ascii out of 7 bit binary 
TENS:	SUI	10
	JC	ONES		; gone negative yet ?
	INR	B
	JMP	TENS		; nope... keep bumping the 10'S DIGIT
;
ONES:	ADI	10		; fix it
	PUSH	PSW		; save the number for a sec
	MOV	A,B
	ADI	'0'		; add in the ascii bias
	MOV	D,A
	POP	PSW
 	ADI	'0'		; add in the ascii bias - must be 0-9
	MOV	E,A
	RET

;
;	set parity command: reset transmit/receive parity
;
;		parity is controlled by bits 4 and 5 of mode register 1
;		for the 2651 
;
;		   parity	bit 5	   bit 4
;	             off          -          0
;	 	     odd	  0	     1
;		     even	  1	     1
;
STPRTY:	MVI	C,SBLANK	;check for parity code
	CALL	MEX		;
	JC	SETERR		;if none, print error
	LXI	D,PARTBL	;check for proper syntax
	MVI	C,LOOKUP
	CALL	MEX
	PUSH	H		;match found, go do it!
	RNC			;
	POP	H		;no match: fix stack and
	JMP	SETERR		;  print error
;
PROFF:	MVI	A,00000000B
	STA	DFTPAR
	JMP	SHOWP1

PREVEN:	MVI	A,00110000B
	STA	DFTPAR
	JMP	SHOWP1

PRODD:	MVI	A,00010000B
	STA	DFTPAR

SHOWP1:	CALL	SINITL

SHOWP:	LDA	DFTPAR
	RRC
	RRC	
	RRC
	RRC
	ANI	00000011B
	ADD	A
	MOV	E,A
	MVI	D,00
	PUSH	D
	CALL	MILP		;display parity
	DB	'Parity is ',0
	POP	D
	LXI	H,PVECT
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL

PVECT:	DW	OFFMSG
	DW	ODDMSG
	DW	OFFMSG		
	DW	EVNMSG
	
OFFMSG:	CALL	MILP		;
	DB	'(None)',0	;
	RET

ODDMSG:	CALL	MILP		;
	DB	'Odd',0		;
	RET			;

EVNMSG:	CALL	MILP		;
	DB	'Even',0	;
	RET
;
;	set parity command table
;
PARTBL:	  DB	'NON','E'+80H	;"set parity off"
	  DW	PROFF
	  DB	'EVE','N'+80H	;"set parity even"
	  DW	PREVEN
	  DB	'OD','D'+80H	;"set parity odd"
	  DW	PRODD
	  DB	0		;<<== end of parity table
;
;	set stopbits command: reset number of stop bits
;
;		the stop bits are controlled by bits 7 and 8 of mode register 
;		1 for the 2651 
;
;		    stop bits	   bit 7	bit 8
;			1	     0            1
;		       1.5	     1		  0
;			2	     1		  1
;
;
STSTOP:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX
	  JC	SETERR		;if none, print error
	  LXI	D,STPTBL	;check syntax
	  MVI   C,LOOKUP
	  CALL	MEX
	  PUSH	H		;match found, go do it!
	  RNC	
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;print error
;
STOP01:	MVI	A,01000000B	; 1 stop bit
	STA	DFTSTP
	JMP	SHOWS
;
STOP02:	MVI	A,11000000B	; 2 stop bits
	STA	DFTSTP
	JMP	SHOWS
;
STOP15:	MVI	A,10000000B	; 1 1/2 stop bits
	STA	DFTSTP
;
SHOWS:	LDA	DFTSTP		; print the current setting
	RRC
	RRC
	RRC
	RRC
	RRC
	RRC
	ANI	00000011B	; mask any possible crap	
	ADD	A		; <a> * 2
	MOV	E,A
	MVI	D,00
	PUSH	D
	CALL	SINITL		; reinit the usart
	CALL	MILP
	DB	'There ',0
	POP	D
	LXI	H,SVECT
	DAD	D
	MOV	A,M		; dispatch
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL

SVECT:	DW	MSG0
	DW	MSG1
	DW	MSG15
	DW	MSG2

MSG0:	CALL	MILP
	DB	'is an INVALID MODE COMMAND - UNKNOWN ERROR in MEX'
	DB	DING,CR,LF,0
	RET

MSG1:	CALL	MILP		; display '1'	
	DB	'is 1 stop bit',0		;
	RET

MSG2:	 CALL	MILP		; display '2' 
	 DB	'are 2 stop bits',0		;
	 RET

MSG15:	CALL	MILP		; display '1.5'
	DB	'are 1.5 stop bits',0
	RET

;	set stopbits command table
;
STPTBL:	  DB	'1'+80H		;"set stop 1"
	  DW	STOP01
	  DB	'2'+80H		;"set stop 2"
	  DW	STOP02
	  DB	'1.','5'+80H	;"set stop 1.5"
	  DW	STOP15
	  DB	0		;<<== end of stop-bits table
;
;	set length command: set bits per character
;
;		the number of bits per character is controlled by 
;		bits 3 and 2 of mode register 1 for the 2651
;		3 only, but are the same for register 5:
;
;		    bpc		bit 3		bit 2
;		     5		  0		  0
;		     6		  0   		  1
;		     7		  1		  0
;		     8		  1		  1
;
STBITS:	  MVI	C,SBLANK	;check for bits/char
	  CALL	MEX
	  JC	SETERR		;if none, print error
	  LXI	D,BITTBL	;check syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  PUSH	H		;match found, go do it!
	  RNC	
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;print error
;
BIT5:	MVI	A,00000000B
	STA	DFTBITS
	JMP	SHOWBT

BIT6:	MVI	A,00000100B
	STA	DFTBITS
	JMP	SHOWBT

BIT7:	MVI	A,00001000B
	STA	DFTBITS
	JMP	SHOWBT

BIT8:	MVI	A,00001100B
	STA	DFTBITS

SHOWBT:	LDA	DFTBITS		; get default setting
	RRC
	RRC
	ANI	00000011B	; mask garbage if any
	ADD	A		; <a> * 2
	MOV	E,A
	MVI	D,00
	PUSH	D
	CALL	SINITL		; reinit the usart
	CALL	MILP
	DB	'There are ',0
	POP	D
	LXI	H,BVECT
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL

BVECT:	DW	BITS5
	DW	BITS6
	DW	BITS7
	DW	BITS8

BITS5:	  CALL	MILP		; display '5'
	  DB	'5 bits/char',0		
	  RET			
BITS6:	  CALL	MILP		; display '6'
	  DB	'6 bits/char',0		
	  RET			
BITS7:	  CALL	MILP		; display '7'
	  DB	'7 bits/char',0		
	  RET			
BITS8:	  CALL	MILP		; display '8'
	  DB	'8 bits/char',0		
	  RET			
;
;	set length command table
;
BITTBL:	  DB	'5'+80H		;"set bits 5"
	  DW	BIT5
	  DB	'6'+80H		;"set bits 6"
	  DW	BIT6
	  DB	'7'+80H		;"set bits 7"
	  DW	BIT7
	  DB	'8'+80H		;"set bits 8"
	  DW	BIT8
	  DB	0		;<<== end of bpc table
;
;
; build the default initialization from ram so as to be cloneable
;
SINITL:	IN	CPORT		; reset the mode registers	
	LDA	DFTSTP		; get default stop bits
	MOV	B,A
	LDA	DFTPAR		; get default parity
	ORA	B
	MOV	B,A
	LDA	DFTBITS		; get default character length
	ORA	B
	ORI	00000010B	; force divide by 16 - use internal baud gen
	OUT	MODE1		; set the register

	LDA	DFTBAUD		; get the default baud rate
	ORI	00110000B	; force internal clocks
	OUT	MODE2		; set the register

	MVI	A,00100111B	; force dtr, cts, async, txe, rxe, no loopbak
	OUT 	CPORT
	RET
;
;
; smartmodem dialing routine ... by a "cast of thousands"
;
DIAL:	  LHLD	DIALPT		;fetch pointer
	  CPI	254		;start dial?
	  JZ	STDIAL1		;jump if so
	  CPI	255		;end dial?
	  JZ	ENDIAL1		;jump if so
;
; not start or end sequence, must be a digit to be sent to the modem
;
	  MOV	M,A		;put char in buffer
	  INX	H		;advance pointer
	  SHLD	DIALPT		;stuff pntr
	  RET			;all done
;
; here on a start-dial sequence
;
STDIAL1:  LXI	H,DIALBF	;set up buffer pointer
	  SHLD	DIALPT
	  RET
;
; here on an end-dial sequence
;
ENDIAL1:  MVI	M,CR		;stuff end-of-line into buffer
	  INX	H		;followed by terminator
	  MVI	M,0
	  LDA	TPULSE		;get overlay'S TOUCH-TONE FLAG
	  STA	SMDIAL+3	;put into string
	  LXI	H,SMDIAL	;point to dialing string
	  CALL	SMSEND		;send it
WAITSM:	  MVI	C,INMDM
	  CALL	MEX		;catch any output from the modem
	  JNC	WAITSM		;loop until no more characters
;
; the following loop waits for a result from the modem.
;
RESULT:	  MVI	A,60		; dont hang longer than a minute
	  MOV	C,A

SMWLP:	  PUSH	B
	  MVI	B,1		;check for a char, up to 1 sec wait
	  MVI	C,TMDINP	;do timed input
	  CALL	MEX
	  POP	B
	  JNC	SMTEST		;jump if modem had a char
	  PUSH	B		;no, test for control-c from console
	  MVI	C,CHEKCC
	  CALL	MEX
	  POP	B
	  JNZ	SMNEXT		;if not, jump
	  CALL	SMDMOFF		;yes, shut down the modem
	  MVI	A,3		;return abort code
	  RET
SMNEXT:	  DCR	C		;no
	  JNZ	SMWLP		;continue
;
; no modem response within the time specified in set delay command
;
SMTIMO:	CALL	SMDMOFF
	MVI	A,2		;return timeout code
	RET
;
; modem gave us a result, check it
;
SMTEST:	  ANI	7FH		;ignore any parity
	  CALL	SMANAL		;test the result
	  JC	RESULT		;go try again if unknown response
	  MOV	A,B		;a=result 
	  PUSH	PSW		;save it
SMTLP:	  MVI	C,INMDM		;eat any additional chars from smartmodem
	  CALL	MEX
	  JNC	SMTLP		;until 100ms of quiet time
	  POP	PSW		;return the code
	  RET
;
; analyze character returned from modem
;
SMANAL:	  MVI	B,0		;prep connect code
	  CPI	'C'		;"connect"?
	  RZ
	  CPI	'1'		;numeric version of "connect"
	  RZ
	  CPI	'5'		;numeric version of "connect 1200"
	  RZ
	  INR	B		;prep busy code b=1
	  CPI	'B'
	  RZ
	  INR	B		;prep no connect msg b=2
	  CPI	'N'		;n=no connect
	  RZ
	  CPI	'3'		;numeric version of "no connect"
	  RZ
	  MVI	B,4		;prep modem error
	  CPI	'E'		;e=error
	  RZ
	  CPI	'4'		;numeric version of "error"
	  RZ
;
; unknown response, return carry to caller. but first,
; flush the unknown response line from the modem.
;
WTLF:	  CPI	LF		;linefeed?
	  STC
	  RZ			;end if so
	  MVI	C,INMDM		;no. get next char
	  CALL	MEX
	  JNC	WTLF		;unless busy, loop
	  RET
;
; send string to the external modem
;
SMSEND:	  MVI	C,SNDRDY	;wait for modem ready
	  CALL	MEX
	  JNZ	SMSEND
	  MOV	A,M		;fetch next character
	  INX	H
	  ORA	A		;end?
	  RZ			;done if so
	  MOV	B,A		;no, position for sending
	  MVI	C,SNDCHR	;nope, send the character
	  CALL	MEX
	  JMP	SMSEND
;
; disconnect smodem - if DTR didnt, this will...
;
SMDMOFF:  MVI	B,CR
	  MVI	C,SNDCHR
	  CALL	MEX
	  MVI	B,10		;one second wait for hayes, etc
     	  CALL	MTIME
	  JMP	DISCON		;make sure it is off
;
; general utility routines
;
MILP:	  MVI	C,ILP		;in-line print
	  JMP	MEX
	  RET
;
MTIME:	  MVI	C,TIMER		; mex timer
	  JMP	MEX
	  RET
;
CRLF:	  CALL	MILP		; print carriage return, line feed
	  DB	CR,LF,0
	  RET

DONEW:	  PUSH	H		; save the new command string fro a sec 
	  LXI	H,ATNSTR
	  CALL	SMSEND		; wake up the modem with 'AT'
	  POP	H
	  JMP	SINIT		; now send the new parameter

ATNSTR:	  DB	'AT',0
;
;==========================================================================
;                            data area
;==========================================================================
;
; default uart parameters 
;
DFTSTP:	   DB	 01000000B	; default stop bits - 1
DFTPAR:	   DB	 00000000B	; default parity - none
DFTBITS:   DB	 00001100B	; default character length - 8 bits
DFTBAUD:   DB    00000000B	; default baud rate scratch area 
;
SMDIAL:	  DB	'ATDT '		; smartmodem dial prefix
DIALBF:	  DS	52		; 2* 24 char max, + cr + null + slop
DIALPT:	  DS	2		; dial position pointer
DIALWD:	  DB	01000000B	; pulse/tone dial word
DIGIT	  DB	0		; save dialed digit
SPEED:	  DB	5		; default baud rate 
				; 0=110,1=300,3=600,5=1200,6=2400
				; 7=4800,8=9600,9=19200 
MONFLG:	  DB	0FFH		; 0: monitor off - 0ffh: monitor on
ANSFLG:	  DB	0		; 0: originate   - 0ffh: ans
;
SMATN:    DB	'+++',0		; smartmodem online 'ATTENTION'
SMDISC:	  DB	'ATH',CR,0	; smartmodem disconnect 
SMINIT:   DB	'ATM1 '		; speaker
S0NIT:	  DB	'S0=0 '		; answer ring counter
S7NIT:	  DB	'S7=30'		; carrier wait delay seconds
XNIT:	  DB	'X1'		; result code mode 
S11NIT:	  DB	'S11=40 '	; interdigit delay in ms
	  DB	CR,0		; modem init string

;
;******************************************************************************
;
				  END
;
;******************************************************************************
