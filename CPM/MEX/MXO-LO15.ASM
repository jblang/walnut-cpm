; MXO-LO15.ASM -- Lobo Max-80 overlay file for MEX112.  11/05/84
;
; This overlay adapts the MEX112 program to Max-80 computers from Lobo.
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using an external modem that
; does not match one of the other special overlays.
;
; If using the Hayes Smartmodem, switch SW6 should normally be down.  If
; for any reason you must have it up, then use the Lobo XCONFIG.COM to
; to disable the hardware and sofware handshaking on the RS-232C ports.
;
; This latest revision of the overlay allows useage of both of the MAX's
; RS-232 ports, each of which can have a different baud rate.  No provision,
; however, is made to allow control of the various handshaking options these
; ports can be set for.  BE SURE that all hardware and software handshake
; options have been DISABLED from XCONFIG and that both ports have been set
; for 8 data bits, 1 stop bit, & no parity....hh
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 11/05/84 - Added DISCV. Renamed MXO-LO15      - Hal Hostetler
; 10/24/84 - Fixed bugs. Renamed to MXO-LO14    - Hal Hostetler
; 10/17/84 - MXO-LO13 -- added SETPORT          - Hal Hostetler
; 10/01/84 - Added full baud rate range (LO-12) - Hal Hostetler
; 05/29/84 - Renamed LO-11 because LO-10 existed - Keith Petersen
; 05/25/84 - MEXified the overlay.		- Biff Bueffel
; 11/11/83 - Renamed to M7LO-1.ASM, no changes	- Irv Hoff
; 10/07/83 - Revised to include modem break	- Steven J. Davidson
; 08/22/83 - Revised to work with Max-80	- Larry Richards
; 07/27/83 - Revised to work with MDM712	- Irv Hoff
; 04/04/83 - 1st version of M712GP		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
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
PRNTBL	EQU	237		;print CMDTBL in column format: pointer => HL,
				;returns CY=1 for abort (^C) from console.
PRID	EQU	236		;prints current MEX ID string on console
;
PRINT	EQU	9		;MEX/BDOS print-string function call
;
;
; Change the following information to match your equipment
;
PORT1:		EQU	0F7E4H		;MAX-80 data port 1
PORT2:		EQU	0F7E6H		;MAX-80 data port 2
MODCTL1:	EQU	PORT1+1		;modem control port 1 MAX-80
MODCTL2:	EQU	PORT2+1		;modem control port 2 MAX-80
MODATP1:	EQU	PORT1		;modem data in port 1
MODATP2:	EQU	PORT2		;modem data in port 2
MODATO1:	EQU	PORT1		;modem data out port 1
MODATO2:	EQU	PORT2		;modem data out port 2
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
BAUDRP1:	EQU	0F7D0H		;baud rate port 1 MAX-80
BAUDRP2:	EQU	0F7D4H		;baud rate port 2 MAX-80
MODRCVB:	EQU	1		;bit to test for receive
MODRCVR:	EQU	1		;value when ready
MODSNDB:	EQU	4		;bit to test for send
MODSNDR:	EQU	4		;value when ready
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
		DB	NO	;yes=PMMI S-100 Modem			103H
		DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	50	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
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
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
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
IN$MODCTL1:	PUSH	H 		;save HL		   	12AH
		LHLD	CURSP		;get CTL port address
		MOV	A,M		;get byte from it
		POP	H		;restore HL
		RET
		DS	3
OUT$MODDATP:	PUSH	H		;save HL 			134H
		LHLD	CURDP		;get DATA port address
		MOV	M,A		;send byte to it
		POP	H		;restore HL
		RET
		DS	3
IN$MODDATP:	PUSH	H		;save HL		 	13EH
		LHLD	CURDP		;get DATA port address
		MOV	A,M		;get byte from it
		POP	H		;restore HL
		RET
		DS	3
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	NOP  !	NOP		;out modem control port #2	15AH
OUT$MODCTL2:	STA	MODCTL2	! RET	;out modem control port #1	15DH
;
		DS	2		;Not used by MEX		160H
		DS	3		;				162H
JMP$DISCON:	JMP	GOODBYE		;set DTR low - return to MEX	165H
JMP$GOODBYE:	JMP	GOODBYE		;set DTR low - exit to CPM	168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD	JMP	NEWBAUD		;Change baudrate		16EH
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
JMP$TIMER	DS	3		;				192H
;
;
; Routine to clear to end of screen.
;
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
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'Version for Lobo Max-80 (rev 1.5)',CR,LF,0
		RET
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:	PUSH	H 		;save HL
	  	LHLD	CURSP		;get CTL port
	  	MVI	A,5		
	  	MOV 	M,A
		MVI	A,0F8H		;send a break tone
		JMP 	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and/or sets DTR low for the
; same length of time to disconnect some modems such as the Bell 212A,
; etc.	The second entry (GOODBYE1) just sends the modem break, needed
; to "alert" some timesharing services.
;
;
GOODBYE:  	PUSH 	H		;save HL
		LHLD	CURSP		;get the CTL port
		MVI	A,5		
	  	MOV	M,A  		;send to the CTL port
		MVI	A,68H		;turn off DTR
;
GOODBYE1: 	MOV	M,A		
		MVI	B,3		;wait for 300 ms.
	  	MVI	C,TIMER
	  	CALL	MEX
	  	MVI	A,5
	  	MOV	M,A
	  	MVI	A,0E8H		;restore to 8 bits, dtr on, etc.
	  	MOV	M,A
	  	POP	H		;restore HL
		RET
;.......
;
; This new INITMOD routine first sets the port to the last PORTID value, 
; then sets the baud rate to the last MSPEED value.
;
INITMOD:	MVI	A,YES
		STA	INITFLG		;inform PBAUD we're initializing
		PUSH	H		;save HL
		LXI	H,BAUDRP1	;BAUD port 1 
		SHLD	CURBP		;activate it temporarily
		LDA	OLDASPD		;get its last baudrate
		CALL	PBAUD		;and set it
		LXI	H,BAUDRP2	;BAUD port 2
		SHLD	CURBP		;activate temporarily
		LDA	OLDBSPD		;get its last baudrate
		CALL	PBAUD		;and set it also
		POP	H		;retrieve HL
		MVI	A,NO		;done with baudrate init.
		STA	INITFLG		;tell PBAUD
	  	LDA	PORTID		;get port ID letter
		ANI	05FH		;convert it to upper case
		CPI	'A'		;port A?
		CZ	SETA		;go set it
		CPI	'B'		;port B then?
		CZ	SETB		;go set it
		LDA	MSPEED		;pick up MSPEED value next
		JMP	PBAUD		;go set baud rate
;.....
;
;
;
SETUPR:	  	MVI	C,SBLANK	;Any arguments?
	  	CALL	MEX
	  	JC	TELL		;If not, go display baud
	  	LXI	D,CMDTBL
	  	MVI	C,LOOKUP
	  	CALL	MEX		;Parse argument
	  	PUSH	H		;Save any parsed arg. addrs on stack
	  	RNC			;If we have one, return to it
	  	POP	H		;Oops, input not found in table
SETERR:	  	MVI	C,ILP
	  	CALL	MEX		;Tell user input not valid
		DB	CR,LF,'++ SET command error ++'
	  	DB	CR,LF,CR,LF,0
	  	RET
;.....
; Argument table
;
CMDTBL:	  	DB	'?'+80H		;help
	  	DW	STHELP
	  	DB	'BAU','D'+80H	;set baud
	  	DW	STBAUD
	  	DB	'POR','T'+80H	;set port
	  	DW	STPORT
		DB	0		;<=== table terminator
;.....
; SET ? processor
;
STHELP:		MVI	C,ILP		;inline print
		CALL	MEX
		DB	CR,LF,'SET BAUD <rate>'
		DB	CR,LF,'SET PORT <A or B> [<baud rate>]'
		DB	CR,LF
		DB	CR,LF,'Baud rate is one of:'
		DB	CR,LF,'   110 300 600 1200 2400 4800 9600 19200'
		DB	CR,LF,'Port is A or B and can have an optional baud'
		DB	CR,LF,'   rate appended to it - A0>> SET PORT A 1200'
		DB	CR,LF,CR,LF,0
		RET
;.....
; SET BAUD processor
;
STBAUD:		MVI	C,BDPARS	;MEX parse baudrate function
		CALL	MEX		;look it up
		JC	SETERR		;bomb out if invalid value
		CALL	PBAUD		;try to set it
		JC	SETERR		;not one of ours so bomb out
BDSHOW:		MVI	C,ILP		;inline print
		CALL	MEX
		DB	CR,LF,'Baud rate is now: ',0
		LDA	MSPEED		;get current baud rate
		MVI	C,PRBAUD	;let MEX print it
		CALL	MEX
		MVI	C,ILP		;inline print
		CALL	MEX
		DB	CR,LF,CR,LF,0	;neatens up display a little
		RET
;.....
; SET PORT processor
;
STPORT:		MVI	C,SBLANK	;scan for argument
		CALL	MEX
		JC	SETERR		;quit if none found
		MVI	C,GNC		;else gobble it up
		CALL	MEX
		ANI	05FH		;convert input to upper case
		CPI	'A'		;port A?
		CZ	SETA		;go set it
		JZ	SETX		;then exit
		CPI	'B'		;port B?
		CZ	SETB		;go set it
		JNZ	SETERR		;if not A or B, bad input - bomb out
SETX:		JMP	TELL		;tell operator and look for baudrate
SETA:		PUSH	H		;save HL
		LXI	H,PORT1		;get DATA port 1 address
		SHLD	CURDP		;store it
		LXI	H,MODCTL1	;get CTL port 1 address
		SHLD	CURSP		;store it
		LXI	H,BAUDRP1	;get BAUD port 1 address
		SHLD	CURBP		;store it
		POP	H		;restore HL
		PUSH	PSW		;save new port id and flags
		LDA	PORTID		;get old port letter
		CPI	'A'		;see if A was already active
		JZ	SETX1		;exit if so else we screw up MSPEED
		POP	PSW		;restore new portid and flags
		STA	PORTID		;save current port letter
		LDA	MSPEED		;get rate for port we're leaving (B)
		STA	OLDBSPD		;save it for next time 
		LDA	OLDASPD		;speed we left A set at last time
		STA	MSPEED		;make it current
		RET
SETB:		PUSH	H		;save HL
		LXI	H,PORT2		;DATA port 2
		SHLD	CURDP		;store it
		LXI	H,MODCTL2	;CTL port 2
		SHLD	CURSP
		LXI	H,BAUDRP2	;BAUD port 2
		SHLD	CURBP
		POP	H		;restore HL
		PUSH	PSW		;save new port id and flags
		LDA	PORTID		;get old port id letter
		CPI	'B'		;see if B was already active
		JZ	SETX1		;exit if so else we trash MSPEED
		POP	PSW		;restore new port id and flags
		STA	PORTID		;save port letter
		LDA	MSPEED		;current rate for port A
		STA	OLDASPD		;save it for next time
		LDA	OLDBSPD		;rate we left B set for last time
		STA	MSPEED		;make it current
		RET
SETX1		POP	PSW		;restore A and important flags
		RET
;
TELL:		MVI	C,ILP		;inline print
		CALL	MEX
		DB	CR,LF,'Port in use is: '
PORTID:		DB	'A ',0
;
BAUDCK:		MVI	C,SBLANK	;more arguments?
		CALL	MEX
		JNC	STBAUD		;if so, go parse as a baudrate
		JMP	BDSHOW		;else show current rate
;...
; Current port values
;
CURDP:		DW	PORT1
CURSP:		DW	MODCTL1
CURBP:		DW	BAUDRP1
OLDASPD:	DB	1
OLDBSPD		DB	1
INITFLG:	DB	NO
;...
;
;
OK110:	  	MVI	A,0		;for 110 baud
	  	MVI	B,2
	  	JMP	SAVEALL
;...
;
;
OK300:	  	MVI	A,1		;for 300 baud
	  	MVI	B,5
	  	JMP	SAVEALL
;...
;
;
OK600:	  	MVI	A,3		;for 600 baud
	  	MVI	B,6
	  	JMP	SAVEALL
;...
;
;
OK1200:	  	MVI	A,5		;for 1200 baud
	  	MVI	B,7
	  	JMP	SAVEALL
;...
;
;
OK2400:	  	MVI	A,6		;for 2400 baud
	  	MVI	B,10
	  	JMP	SAVEALL
;...
;
;
OK4800:	  	MVI	A,7		;for 4800 baud
	  	MVI	B,12
	  	JMP	SAVEALL
;...
;
;
OK9600:	  	MVI	A,8		;for 9600 baud
	  	MVI	B,14
	  	JMP	SAVEALL
;...
;
;
OK19200:  	MVI	A,9		;for 19200 baud
	  	MVI	B,15
	  	JMP	SAVEALL
;...
;
;
SAVEALL:  	PUSH	PSW		;save new mspeed and flags
	  	MOV	A,B		;get new rate code
	  	PUSH	H		;save HL
		LHLD	CURBP		;get BAUD port
		MOV	M,A		;set the rate
		POP	H		;restore HL
		LDA	INITFLG		;get initmod flag
		CPI	YES		;see if it's active
		JZ	SAVEX		;exit if so - don't change MSPEED
		POP	PSW		;get new mspeed and flags
		STA	MSPEED		;and update it
	  	RET
SAVEX:		POP	PSW		;restore A and important flags
		RET
;.....
; PBAUD and NEWBAUD routines
;
PBAUD:  	CPI	0
		JZ	OK110
		CPI	1
	  	JZ	OK300
		CPI	3
		JZ	OK600
	  	CPI	5
	  	JZ	OK1200
		CPI	6
		JZ	OK2400
		CPI	7
		JZ	OK4800
		CPI	8
		JZ	OK9600
		CPI	9
		JZ	OK19200
		STC			;bad rate: set CY flag for error det.
	  	RET
;
NEWBAUD:	CPI	1
		JZ	OK300
		CPI	5
		JZ	OK1200
;.....
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'Y',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'*',0,0,0,'$'
;
;
; NOTE:  Must terminate prior to 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;.....
;
	  END
;
