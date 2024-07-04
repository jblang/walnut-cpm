	title	'MEX overlay for MEGA SuperComputer SBC'
;
; MXO-MG10.ASM -- MEX Overlay file for the MEGA SuperComputer SBC
;
; Version 1.0: Written 09/04/84 by Ron Fowler
;
; This overlay adapts the MEX modem program to the Mega Computer Co. Single
; Board Computer, using the Zilog SIO or DART.
;
; This overlay is adaptable to any computer using an SIO or DART for
; serial communications, and is especially useful if such adaptations
; are for computer with multiple SIO chips.  It's also helpful if
; the target computer uses a CTC for generating the serial clock.
;
; This overlay is capable of setting baud rate and setting port number
; (via the SET command), and setting baud rate from the phone library.
;
; Note: to take advantage of software baud-rate selection, you must strap
; the MEGA baud-rate block (J10) as follows:
;
;		CTCI0 - 19200\  For non-MEGA computers, this is a 307KB
;		CTCI1 - 19200 > input clock rate (307KB/16=19200)
;		CTCI2 - 19200/                          
;		CTC00 - first SIO clock (RAn, RTAn/RTBn)--\  
;		CTC01 - second SIO clock                --| 
;		CTC02 - third SIO clock			--|  
; 						   |------/			
;						   |   
;				These may be to any of the 6 SIO
;				clock lines, but MAX of three unless
;				you hack in another CTC.  You must
;				change the values in CTCTBL if you
;				don't use CTC port 4 -- SIO on P5
;					  CTC port 5 -- SIO on P6
;					  CTC port 6 -- SIO on P3
;
; The SIO channels are numbered as follows:
;
;	PORT	Connector   SIO Chip
;	----    ---------   --------
;	0	   P5	       U61
;	1	   P6	       U61
;	2	   P3	       U58
;	3	   P4	       U58	(usually, the console)
;	4	   P7	       U64
;	5	   P8	       U64
;
; The reason for this strange numbering scheme is for compatibility with
; MEGA TurboDOS, where ports 4,5 don't exist (U64 is the network control-
; ler port for TurboDOS, and is not used for RS232 serial communications).
;
; Be aware that, if you're running MEGA TurboDOS, this overlay will dis-
; able the interrupts of any port it's SET to ... you can use the TurboDOS
; version of MEX if this is a problem.  You might prefer to use this overlay
; to communicate in terminal mode at the higher baudrates, which is a losing
; situation with the TurboDOS MEX.
; 
; Set the following NPORT value to the relative port # (table above) you
; want MEX to use on start up.
;
NPORT	EQU	1
;
REV	EQU	10	;V 1.0
;
RDA	EQU	1		;mask for recv-data available
TBE	EQU	4		;mask for transmit-bufr empty
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
PRINT	EQU	9		;BDOS/MEX print-string function call
;
BELL	EQU	7		;bell
TAB	EQU	9
CR	EQU	13		;carriage return
LF	EQU	10		;linefeed
ESC	EQU	1BH		;escape
YES	EQU	0FFH
NO	EQU	0
;
;
	ORG	100H
;
; Change the clock speed to suit your system
;
	DS	3		;(for  "JMP   START" instruction)

	DB	NO		;yes=PMMI S-100 Modem			103H
	DB	NO		;yes=HAYES Smartmodem, no=non-PMMI	104H
	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	50		;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5		;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5		;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:	DB	5		;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:	DB	5		;number of DIR columns shown		10AH
SETFLG:	DB	YES		;yes=user-added Setup routine		10BH
SCRTST:	DB	YES		;Cursor control routine 		10CH
	DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG:	DB	YES		;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	NO		;yes=default to CRC checking		10FH
TOGCRC:	DB	YES		;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		;yes=convert backspace to rub		111H
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR	114H
	DB	YES		;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP		116H
	DB	NO		;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
	DB	YES		;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:	DB	YES		;yes=printer available on printer port	119H
XOFTST:	DB	NO		;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:	DB	YES		;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	NO		;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		;for future expansion			11EH
EXITCHR	DB	'E'-40H		;^E = Exit to main menu			11FH
BRKCHR:	DB	'@'-40H		;^@ = Send 300 ms. break tone		120H
NOCONN:	DB	'N'-40H		;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H		;^L = Send logon			122H
LSTCHR:	DB	'P'-40H		;^P = Toggle printer			123H
UNSAVE:	DB	'R'-40H		;^R = Close input text buffer		124H
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote		125H
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer		126H
EXTCHR:	DB	'^'-40H		;^^ = Send next character		127H
	DS	2		;unused by MEX				128H
;
INCTL1:	JMP	INSP		;go input status port			12AH
	DS	7
;
OTDATA:	JMP	OUTDP		;go output data port			134H
	DS	7
;
INPORT:	JMP	INDP		;go input data port			13EH
	DS	7
;
MASKR:	ANI	RDA	! RET	;bit to test for receive ready		148H
TESTR:	CPI	RDA	! RET	;value of rcv. bit when ready		14BH
MASKS:	ANI	TBE	! RET	;bit to test for send ready		14EH
TESTS:	CPI	TBE	! RET	;value of send bit when ready		151H
	DS	14		;					156H
;
;
	DS	3		;DIALV: not done here (maybe MXO-SM)	162H
DISCV:	JMP	DISCON		;disconnect
GOODBV:	JMP	GOODBY		;					168H
INMODV:	JMP	NITMOD		;go to user written routine		16BH
	RET ! NOP ! NOP		;NEWBDV					16EH
	RET ! NOP ! NOP		;NOPARV					171H
	RET ! NOP ! NOP		;PARITV					174H
SETUPV:	JMP	SETCMD		;					177H
	DS	3		;not used by MEX			17AH
VERSNV:	JMP	SYSVER		;					17DH
BREAKV:	JMP	SBREAK		;					180H
;
; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).
;
ILPRTV:	DS	3		;					183H
INBUFV	DS	3		;					186H
ILCMPV:	DS	3		;					189H
INMDMV:	DS	3		;					18CH
	DS	3		;					18FH
TIMERV	DS	3		;					192H
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRTEST to YES at 010AH (above).
;
CLREOS:	LXI	D,EOSMSG	;					195H
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG	;					19EH
	MVI	C,PRINT
	CALL	MEX
	RET
;									1A7H
;
; end of fixed area
;
SYSVER:	MVI	C,ILP		;in-line print
	CALL	MEX
	DB	'MEGA SuperComputer rev '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF,0
	RET
;
; Routine to exit just prior to exit-to-cpm
;
GOODBY:	RET			;not done here
;
; Send break to remote
;
SBREAK:	RET			;not yet implemented
;
; Disconnect the modem (not done here, relies on SM overlay)
;
DISCON:	RET
;
; SET command: select baud rate, port name. Port name may be any of
; ABC, DELTA, USR (names may be changed by altering PNMTBL entries),
; baud rate any of xxxxxxxxxxxxxxxxxxxxx
; Special set-port syntax allows baud rate after port name.  Examples:
;
;	SET PORT DELTA3
;	SET PORT ABC 1200
;	SET PORT USR 300
;	SET BAUD 9600
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	TELL		;if not, go display port/baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;parse argument
	PUSH	H		;save any parsed argument adrs on stack
	RNC			;if we have one, return to it
	POP	H		;oops, input not found in table
SETERR:	MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET command error',CR,LF,0
	RET
;
; Argument table
;
CMDTBL:	DB	'?'+80H		;help
	DW	STHELP
	DB	'BAU','D'+80H	;"set baud"
	DW	STBAUD
	DB	'POR','T'+80H	;"set port"
	DW	SETPOR
	DB	0		;<<=== table terminator
;
; "SET ?" processor
;
STHELP:	MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET BAUD <rate>'
	DB	CR,LF,'SET PORT <port-number>'
	DB	CR,LF
	DB	CR,LF,'Baud rate is one of:'
	DB	CR,LF,'   300 600 1200 4800 9600 19200'
	DB	CR,LF,'Port number is one of:'
	DB	CR,LF,'   0-7 : interfacer 3 or 4 port number'
	DB	CR,LF,'   S   : System Support I serial port'
	DB	CR,LF,0
	RET
;
; "SET BAUD" processor
;
STBAUD:	MVI	C,BDPARS	;function code: parse a baudrate
	CALL	MEX		;let MEX look up code
	JC	SETERR		;jump if invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;if not one of ours, bomb out
BDSHOW:	MVI	C,ILP		;inline print
	CALL	MEX		;display baud
	DB	'Baud: ',0
	LDA	MSPEED		;get current baud rate
	MVI	C,PRBAUD	;let MEX print it
	CALL	MEX
	RET
;
; SET PORT processor
;
SETPOR:	MVI	C,SBLANK	;scan to argument
	CALL	MEX
	JC	SETERR		;if no arg, bomb out
	MVI	C,GNC		;else consume it
	CALL	MEX
	SUI	'0'		;convert
	JC	SETERR
	CPI	5+1
	JNC	SETERR
	CALL	SPA		;set port addresses
	MVI	C,SBLANK	;any thing more?
	CALL	MEX
	JNC	STBAUD		;if so, go parse as baud rate
TELL:	MVI	C,ILP
	CALL	MEX
	DB	CR,LF,'Port: ',0
	LDA	PORT
	ADI	'0'		;get port # in ASCII
	STA	PORTAS
	MVI	C,ILP
	CALL	MEX
PORTAS:	DB	'    ',0
	JMP	BDSHOW
;
; Initialize channel ... as distributed, this code simply
; sets the default port, default port addresses, and default
; MSPEED (based on MSPTBL table).  You might want to modify
; this do do a full channel initialization, including SIO
; setup and baud rate.  If so, delete the commented-out code
; in between NITMOD and SPA, and enter your initial baudrate
; just prior to the call on PBAUD.  If you do this, you should
; be aware that whenever you enter MEX, the baudrate will be
; set to this default rate (even if a connection is in prog-
; ress at a different rate).
;
NITMOD:	MVI	A,NPORT		;get initial port number
;
;; De-comment the following for full initialization
;;
;;	CALL	SPA		;calculate harware port addresses
;;	MVI	A,??		;substitute MSPEED baud value for ??
;;	CALL	PBAUD		;set rate, init channel
;;	RET			;end of init block
;
; Calculate hardware status and data port addresses for
; relative port number passed in A.
;
SPA:	STA	PORT		;save port number
	MOV	E,A		;port # to DE
	MVI	D,0		;index into table
	LXI	H,PORTBL	;get table of port hardware addresses
	DAD	D
	DAD	D
	MOV	A,M		;fetch status port #
	STA	SPORT		;set it
	INX	H
	MOV	A,M		;fetch data port #
	STA	DPORT
	LXI	H,MSPTBL	;get port's MSPEED value
	DAD	D
	MOV	A,M		;set MSPEED
	STA	MSPEED
	RET
;
; Port assignment table for each SIO.  Each entry
; consists of status-port adrs followed by data-
; port address.
;
PORTBL:	DB	0EH,0CH		;port 0	 (SIO #1, A)
	DB	0FH,0DH		;port 1  (SIO #1, B)
	DB	16H,14H		;port 2  (SIO #2, A)
	DB	17H,15H		;port 3  (SIO #2, B)
	DB	1AH,18H		;port 4  (SIO #3, A)
	DB	1BH,19H		;port 5  (SIO #3, B)
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported (if supported,
; this routine must set the new MSPEED code).
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;MSPEED code to DE
	MVI	D,0
	LDA	PORT		;get port #
	MOV	C,A		;to BC
	MVI	B,0
	LXI	H,BAUDFL	;offset to flags for this port
	DAD	B
	MOV	A,M		;software baudrate supported
	ORA	A		;  for this port?
	STC			;prep carry in case not
	JZ	PBEXIT		;jump if not supported
	LXI	H,MSPTBL	;yes. offset MSPEED for this port
	DAD	B
	MOV	M,E		;store current rate
	LXI	H,MSPEED	;set MSPEED value also
	MOV	M,E
	LXI	H,BAUDTB	;offset into divisor table
	DAD	D		;indexed by SPEED value
	MOV	A,M		;fetch divisor
	PUSH	PSW		;save divisor
	PUSH	B		;save relative port #
	LDA	SPORT		;get status port adrs
	MOV	C,A		;status port adrs to C
	MVI	B,SIOLEN	;b=length of SIO code
	LXI	H,SIONIT	;point to init code
	DB	0EDH,0B3H	;Z80 OUTIR
	POP	B		;recall relative port #
	LXI	H,CTCTBL	;offset to CTC register, this port
	DAD	B
	MOV	C,M		;PORT # IN C
	MVI	A,45H		;SEND COMMAND CODE
	DB	0EDH,079H	;Z80 OUTP A instruction
	POP	PSW		;recall divisor
	DB	0EDH,079H	;Z80 OUTP A instruction
	ORA	A		;return no-errors
PBEXIT:	POP	B
	POP	D
	POP	H
	RET
;
; table of CTC divisors for each rate
;
BAUDTB:	DB	175		;110 (not exact, but close enuf)
	DB	64		;300
	DB	48		;450
	DB	32		;600
	DB	27		;710 (not exact)
	DB	16		;1200
	DB	8		;2400
	DB	4		;4800
	DB	2		;9600
	DB	1		;19200
;
; baud rate flags for each SIO port.  Set to 0
; for a port that doesn't support software baudrate
; change, 1 for ports that can.
;
BAUDFL:	DB	1,1,1,0,0,0	;6 ports (I have only first 3 connected to CTC)
;
;
; the following table associates each port with a CTC
; hardware address.  Valid port addresses must correspond
; with the BAUDFL table above
;
CTCTBL:	DB	4,5,6,0,0,0	;only 3 channels available on 1 ctc
;
; The following table holds MSPEED for each port.
; Since it's not possible to tell divisors exist in
; the CTC prior to bringing up MEX, this table is
; set with defaults, and is filled in with actual
; values as each port gets a SET BAUD command.
;
MSPTBL:	DB	5,5,5,5,5,5	;speed for each port: 1200
;
; Init code for an SIO channel
;
SIONIT:	DB	18H		;reset channel
	DB	4		;select write reg 4
	DB	44H		;16*clock, 1 stop bit,  no parity
	DB	5		;select write reg 5
	DB	0EAH		;DTR, 8 bits xmit, TX enabl, RTS
	DB	3		;select write reg 3
	DB	0C1H		;8 bits recv, recv enable
SIOLEN	EQU	$-SIONIT	;length of SIO init code
;
;	Port access routines
;
; Input
;
INSP:	LDA	SPORT		;get status-port adrs
	JMP	INP1
INDP:	LDA	DPORT		;get data-port adrs
INP1:	STA	INP2+1		;modify the code
INP2:	IN	0		;do the input
	RET
;
;
; output status port
;
OUTSP:	PUSH	PSW		;save the value
	LDA	SPORT		;get port adrs
	JMP	OUTT		;on to common code
;
; output data port
;
OUTDP:	PUSH	PSW		;save the char
	LDA	DPORT		;get data-port adrs
OUTT:	STA	OUT1+1		;modify the code
	POP	PSW		;recall data byte
OUT1:	OUT	0
	RET
;
;
PORT:	DS	1		;put your initial port # here
;
DPORT:	DS	1		;data port address
SPORT:	DS	1		;status port address
;
; Clear-to-end-of-screen and clear-screen sequences
;
EOSMSG:	DB	ESC,'T','$'
CLSMSG:	DB	26,'$'
;
;
	END
;
                                                                                  