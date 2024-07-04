; Title  'MEX Overlay for the XEROX 820-I and 820-II Computers Version 3.6'
;
;
REV	EQU	36		; Overlay revision level
;
;  MEX Overlay for XEROX 820-I and XEROX 820-II Computers with
;  external modems. The table outlines the SET command options:
;
;	SET Command			     Available
;
;	DELAY <n> (seconds)			YES
;	BAUD <rate>				YES
;	ORIG (originate mode)			YES
;	ANSWER	(mode)				YES
;	TONE (dialing)				YES
;	PULSE (dialing) 			YES
;	PBX (telephone system)			YES
;	STANDARD (telephone system)		YES
;	BLOCK (block call-waiting)		YES
;	MONITOR (speaker on)			YES
;	QUIET (speaker off)			YES
;	PARITY (Odd, Even, None)		YES
;	STOPBITS (1, 1.5, 2)			YES
;	LENGTH (5, 6, 7, or 8)			YES
;
;............
;
;  This overlay includes the smartmodem dialing routine from
;  MXO-SM10.ASM by Ron Fowler which has been slightly modified
;  to allow programmable delay for answer.  (Note that this is
;  different from the "ATS7=nn").
;
;  This overlay is intended to be fully compatible with the
;  MEX structure and should be readily upward compatible with
;  the predicted MEX 2.0.
;
;  Calling conventions for the various overlay entry points
;  are detailed more fully in the PMMI overlay (MXO-PMxx.ASM,
;  where xx=revision number).
;
;  Note that all overlays may freely use memory up to 0CFFH.
;  If your overlay must work with the MEX Smartmodem overlay
;  (MXO-SMXX.ASM), the physical modem overlay should terminate
;  by 0AFFH.
;
;  The SSET commands vector SSETV is at location 0D57H, see ORG
;  instruction and the SSETCMD section near the end of this overlay.
;
;  The program uses the RS-232 serial port, lines that are used are
;  shown below, pin-to-pin connections.
;	1 = ground (protective)
;	2 = Tx data to modem
;	3 = Rx data from modem
;	4 = RTS request to send to modem
;	5 = CTS clear to send from modem
;	7 = signal ground
;	8 = DCD data carrier detect from modem
;	20= DTR data terminal ready to modem
;
;  These are required to implement proper hand shaking.
;
;  History:
;  03/27/88     Added equates for the Anchor Volksmodem 12.  I found 
;               this modem accepts a very limited number of commands,
;               and has a fondness of returning to verbal response codes
;               as opposed to numeric.  It's slow, but it's sure.
;
;               Also, I am suggesting that the equates in BAUDTB: be set to
;               0 for baud rates that your modem cannot support.  I found
;               that when I accidently set a baud rate to 2400 on the
;               Volksmodem12 I was configuring that it locked the modem
;               completely.  This is to solve that.  If you get an error
;               when you try to set a higher, valid rate, check the equates
;               at this label.
;
;               Lastly, fixed a bug that has been bugging me for some time
;               with the SET LENGTH command.
;                                               Lee McEwen
;
;  11/21/87	Added equates for the Practical Peripherals PM2400SA
;		2400 baud modem.  This is one of the very good quality
;		inexpensive clone modems, but needs a few tricks to
;		use, particularly with DTR disconnects and numeric 
;		codes.
;
;		Also changed the SYSVER screen to something I rather
;		prefer.  Don't mean to step on toes.  Return it to
;		the original if you prefer....
;						Lee McEwen
;						(904) 272-3964
;
;  08/04/87	Minor changes to allow it to assemble with ASM or LASM.
;						Bill Duerr
;
;  07/11/86	Added two new Equates to help support my Xerox 820-I
;		with the newer Model Hayes Smartmodem 1200.  The
;		reason for the equates are as follows:
;
;		NOBLINK was added for Xerox 820-I owners that don't
;		wish to see a BLINKY BLINKY Sys Ver at the begining
;		of MEX may be nice for Xerox 820-II but annoying for
;		Xerox 820-I Owners.
;
;		NEW1200 was added to insure that NUMERIC RESULTS would
;		be displayed after calling a phone number.  The reason for
;		this was because I run a PBBS Bulletin Board and when I
;		wish to use MEX I need to perform an "ATZ" to reset the
;		status of my MODEM after exiting BYE.  This Equate also
;		sets the Monitor Speaker to high volume for I can here it
;		in the noisy environment that my SYSTEM is in.
;
;					- Carol L. Miller, Sr.
;					- EDP Consultants,  - PBBS
;					- (405) 237-9890
;
;
;  02/21/86	Added code that stores the baud rate being used on
;		exit to CP/M.  This vaule is recovered on return to
;		MEX.  This permits the proper calculation for the
;		transfer time when sending a file after a return.
;						Harry Leman
;
;  02/08/86	Added code for the call-waiting block that will be
;		available at some later date.  The number '70' is
;		dialed prior to the number being called.  This will
;		disable the call-waiting signal to interrupt the call.
;		This feature will be active only during the current
;		call.  Corrected a problem with the pulse/tone flag so
;		that it is used while in the PBX function.  However
;		the pulse mode is always used to get through the PBX
;		but the pulse/tone flag is used after access to the
;		outside line.  The pulse/tone flag is also used for
;		the call-waiting block function, to dial the '70' and
;		the number to be called.
;						Harry Leman
;
;  10/18/85	Added code for operating through a PBX system and
;		call waiting block function if supported by your
;		telephone company.  Also corrected display atributes
;		for the XEROX 820-II.
;						Harry Leman
;
;  05/30/85	Added equates for 300/1200/ or USR2400 to initialize the
;		modem properly and take advantage of all available codes
;		from the different modems. Added auto baud set for 1200
;		baud fall-back when using a USR2400. Added equates for
;		ANCHOR 1200 for it's special ideocyncracies.
;						Russ Pencin
;
;  05/28/85	Added the NOPAR and PARITY Mex calls. A few minor cleanups.
;						      Ron Carter
;
;  05/14/85	Appropriated all of the code from the MXO-KP28 overlay.
;		Removed code pertaining to internal modems. Added code
;		to support the U.S. Robotics Courier 2400 extended responce
;		messages (enabled by equate). This overlay will work on
;		both 820-I and 820-II		      Russ Pencin TDC
;
;  Credits:
;
;  All of the individuals who perfected the KP28 overlay.
;  M7KP-1 overlay structure by Irv Hoff
;  Smartmodem dialing routine by Ron Fowler
;
;  Bug Reports:
;
;  Would appreciate a note of any problems be left on the
;  THE Dallas Connection RCP/M (214) 238-1016 (300/1200/2400)
;
;
;------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
TPA	EQU	100H
BELL	EQU	07H		; Activate bell
TAB	EQU	09H		; Tab
LF	EQU	0AH		; Line feed
CR	EQU	0DH		; Carrage return
CLCRT	EQU	1AH		; Clear screen code
ESC	EQU	1BH		; Start of escape sequence
DENABL	EQU	28H		; Disables attribute display
ENABL	EQU	29H		; Enables attribute display
CSPEED	EQU	003CH		; Actual connect speed of modem
MONITOR	EQU	0F00H		; Entry of XEROX monitor
MODE	EQU	0D54H		; Contents of location indicates mode of MEX
				; 00 - MEX in command mode
				; 01 - MEX in terminal mode
				; 02 - SENDOUT active
				; 03 - Keysting being transmitted
				; Christensen-protocol
				; 04 - File transfer send
				; 05 - File transfer receive
				; CIS protocol
				; 06 - File transfer, send
				; 07 - File transfer, receive
SSETV	EQU	0D57H		; SSET vector as determined by using
				; MEXPAT11.ASM, a DW at this location
				; Should point to address of SSETCM,
				; The command processor for the SSET cmd.
;
;  PLEASE SET THE FOLLOWING EQUATE TO YES IF YOU WISH TO DO "ATZ"'s
;  and want to set the following defaults before dialing.
;    V0 = Display NUMERIC RESULT CODES
;    L3 = Set Monitor Speaker Volume to High
;
NEW1200	EQU	NO		; Yes, if using newer Model of Hayes 1200
NOBLINK	EQU	NO 		; Yes, If using Xerox 820-I and you don't
				; Wish to have a blinking SYSVER Message
;
;  PLEASE SET ONLY ONE OF THE FOLLOWING SEVEN EQUATES TO YES !
;
USR2400	EQU	NO 		; Yes, if using A U.S.Robotics 2400
PM2400SA EQU    YES		; Yes, if Practical Peripherals 2400
B1200	EQU	NO		; Yes, if using a Hayes 1200 compatible
B300	EQU	NO		; Yes, if using a Hayes 300 compatible
ANCHOR	EQU	NO		; Yes, if using an Anchor XII modem
VOLKS12 EQU     NO              ; Yes, if using an Anchor Volksmodem 12
PRO1200	EQU	NO		; Yes, if Prometheus 1200 modem
;
	 IF	ANCHOR OR VOLKS12
DIALAB	EQU	041H            ; Special Anchor Modem dial abort
	 ENDIF
;
	 IF	NOT ANCHOR AND NOT VOLKS12
DIALAB	EQU	CR		; All others use CR to abort dial
	 ENDIF
;
; XEROX 820 port definitions
;
DATPORT	EQU	04H		; Base data port
CTLPORT	EQU	DATPORT+2	; Modem status port
BAUDRP	EQU	00H		; Modem baud rate port
;
; XEROX 820 bit definitions
;
MDRCVB	EQU	01H		; Modem receive bit (DAV)
MDRCVR	EQU	01H		; Modem receive ready
	 IF	NOT PRO1200
MDSNDB	EQU	04H		; Modem send bit
MDSNDR	EQU	04H		; Modem send ready bit
	 ENDIF
	 IF	PRO1200
MDSNDB	EQU	24H		; Mask for pin 5, CTC to allow 1200 baud
MDSNDR	EQU	24H		; Port and 300 baud phone, command ATB1
	 ENDIF
;
; MEX Service Processor
;
MEX	EQU	0D00H		; Address of the service processor
INMDM	EQU	255		; Get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		; Delay 100ms * reg B
TMDINP	EQU	253		; B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		; Check for ^C from KBD, Z=present
SNDRDY	EQU	251		; Test for modem-send ready
RCVRDY	EQU	250		; Test for modem-receive ready
SNDCHR	EQU	249		; Send a character to the modem (after sndrdy)
RCVCHR	EQU	248		; Recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		; Table search: see CMDTBL comments for info
PARSFN	EQU	246		; Parse filename from input stream
BDPARS	EQU	245		; Parse baud-rate from input stream
SBLANK	EQU	244		; Scan input stream to next non-blank
EVALA	EQU	243		; Evaluate numeric from input stream
LKAHED	EQU	242		; Get nxt char w/o removing from input
GNC	EQU	241		; Get char from input, cy=1 if none
ILP	EQU	240		; Inline print
DECOUT	EQU	239		; Decimal output
PRBAUD	EQU	238		; Print baud rate
PRNTBL	EQU	237		; Prints table in columnar format, table
				; Pointer passed in HL, returns CY=1 if
				; Output aborted with ^C
PRID	EQU	236		; Prints current MEX ID on console
				;
CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10
;==========================================================================
;		Start of actual overlay
;==========================================================================
	ORG	TPA		; We begin
;
	DS	3		; MEX has a JMP START here
	DS	2		; Not used by MEX
TPULSE:	DB	'T'		; T=touch, P=pulse (Used by this overlay)
CLOCK:	DB	25		; Clock speed x .1, up to 25.5 mhz.
;
	 IF	B300
MSPEED:	DB	1		; Sets display time for sending a file
	 ENDIF			; 0=110  1=300	2=450  3=600  4=710
				; 5=1200 6=2400 7=4800 8=9600 9=19200
	 IF	B1200 OR ANCHOR	OR PRO1200 OR VOLKS12
MSPEED:	DB	5		; SET 1200 BAUD
	 ENDIF
	 IF	USR2400 OR PM2400SA
MSPEED:	DB	6		; SET 2400 BAUD
	 ENDIF
;
BYTDLY:	DB	4		; Default time to send character in
				; Terminal mode file transfer (0-9)
				; 0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		; End-of-line delay after CRLF in terminal
				; Mode file transfer for slow BBS systems
				; 0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		; Number of directory columns
SETFL:	DB	YES		; Yes=user-defined SET command
SCRTST:	DB	YES		; Yes=if home cursor and clear screen
				; Routine at CLRSCRN
	DB	0		; Was once ACKNAK, now spare
BAKFLG:	DB	YES		; Yes=make .BAK file
CRCDFL:	DB	YES		; Yes=default to CRC checking
				; No=default to Checksum checking
TOGCRC:	DB	YES		; Yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		; Yes=convert backspace to rub
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub
ADDLF:	DB	YES		; No=no LF after CR to send file in
				; Terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR
TRNLOG:	DB	NO		; Yes=allow transmission of logon
				; Write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP
LOCNXT:	DB	YES		; Yes=local cmd if EXTCHR precedes
				; No=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		; Yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		; Yes=allow toggling of printer on/off
				; In terminal mode. Set to no if using
				; The printer port for the modem
XOFTST:	DB	NO		; Yes=allow testing of XOFF from remote
				; While sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after sending CR while
				; Transmitting a file in terminal mode
TOGXOF:	DB	YES		; Yes=allow toggling of XOFF testing
IGNCTL:	DB	NO		; Yes=do not send control characters
				; Above CTL-M to CRT in terminal mode
				; No=send any incoming CTL-char to CRT
EXTRA1:	DB	0		; For future expansion
EXTRA2:	DB	0		; For future expansion
;
;  See MEX Newsletter #002, the low bit of location 0D06H, in MEX.COM,
;  must  be set in order to use this alternate "terminal command set".
;  Use DDT or some other program to set the bit if this alternate
;  terminal command set is desired.
;
BRKCHR:	DB	'@'		; @ = Send a 300 ms. break tone
NOCONN:	DB	'N'		; N = Disconnect from phone line
LOGCHR:	DB	'L'		; L = Send logon
LSTCHR:	DB	'P'		; P = Toggle printer
SAVCHR:	DB	'S'		; S = Open input text buffer
TRNCHR:	DB	'T'		; T = Transmit file to remote
UNSVCH:	DB	'Q'		; U = Close input text buffer
EXTCHR:	DB	'^'		; ^ = Send next character
;
	DS	2		; Not used
;
; Low-level modem I/O area.  Next 3 need to be ten bytes long!
;
INC:	MVI	A,10H		; Read modem control port
	OUT	CTLPORT
	IN	CTLPORT
	DB	0,0,0		; Spares of needed
	RET
;
	OUT	DATPORT		; Output data to modem port
	DB	0,0,0,0,0,0,0	; Spares if needed
	RET
;
	IN	DATPORT		; Input data from modem port
	ANI	07FH		; Mask location for parity test
MASK	EQU	$-1
	DB	0,0,0,0,0	; Spares if needed
	RET
;
; Bit-test routines.
;
MASKR:	ANI	MDRCVB ! RET	; Bit to test for receive ready
TESTR:	CPI	MDRCVR ! RET	; Value of receive bit when ready
MASKS:	ANI	MDSNDB ! RET	; Bit to test for send ready
TESTS:	CPI	MDSNDR ! RET	; Value of send bit when ready
;
	DS	12
;
LOGON:	DS	2		; Needed for MDM compat, not ref'd by MEX
DIALV:	JMP	DIAL
DISCV:	JMP	DISCON
GOODBV:	JMP	GOODBYE		; Called before exit to CP/M
INMODV:	JMP	NITMOD		; Initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		; Set baud rate
NOPARV:	JMP	NOPAR		; Set modem for no-parity
PARITV:	JMP	PARITY		; Set modem parity
SETUPV:	JMP	SETCMD		; SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		; Not used with MEX
VERSNV:	JMP	SYSVER		; Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		; Send a break
;
; MDM calls supported in MEX 1.0 but not recommended for use.
;
ILPRTV:	DS	3		; Replace with MEX function 9
INBUFV:	DS	3		; Replace with MEX function 10
ILCMPV:	DS	3		; Replace with table lookup funct. 247
INMDMV:	DS	3		; Replace with MEX function 255
NXSCRV:	DS	3		; Not supported by MEX (returns w/no action)
TIMERV:	DS	3		; Replace with MEX function 254
;
;  Next 2 must be 9 bytes long!
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;==================================================================
;		End of fixed area
;==================================================================
;
; Print out the overlay version
;
SYSVER:	CALL	MILP
	;
	 IF	NOT NOBLINK
	DB	ESC,ENABL
	 ENDIF
	;
	DB	CLCRT
	DB	'___________________',CR,LF
	DB	'MEX Modem Executive',CR,LF
	DB	'    Version 1.14',CR,LF,LF
	DB	'(c) 1984 Ronald G. Fowler',CR,LF,LF
	;
	DB	'Configured for XEROX 820-II with',CR,LF
	;
	 IF	USR2400
 	DB	'U.S.Robotics Courier 2400'
	 ENDIF
	 IF	PM2400SA
	DB	'Practical Peripherals PM2400SA'
	 ENDIF
	 IF	B1200
	DB	'Hayes Compatiable 1200 baud'
	 ENDIF
	 IF	B300
	DB	'Hayes Compatiable 300 baud'
	 ENDIF
	 IF	ANCHOR
	DB	'Anchor Signalman Mark XII'
	 ENDIF
         IF     VOLKS12
        DB      'Anchor Volksmodem 12'              
         ENDIF
	 IF	PRO1200
	DB	'Prometheus 1200 ProModem'
	 ENDIF
	;
	DB	' modem',CR,LF
	DB	'using MXO-XE'
	DB	REV/10+'0'
	DB	REV MOD	10+'0'
	DB	' overlay.',CR,LF,LF,LF,LF
	;
	 IF	NOT NOBLINK
	DB	ESC,DENABL
	 ENDIF
	;
	DB	0		; Termination of signon message
	RET
;
;
; Break, disconnect and goodbye routines
;
SBREAK:	MVI	A,5
	OUT	CTLPORT
	LDA	REG5
	ORI	00010000B	; SEND A BREAK TONE
	JMP	GOODBYE1
	 IF	NOT ANCHOR AND NOT VOLKS12
DISCON:	MVI	A,5
	OUT	CTLPORT		; SEND TO THE STATUS PORT
	LDA	REG5
	ANI	01001000B	; TURN OFF DTR
	 ENDIF
	 IF	ANCHOR OR VOLKS12
DISCON:	MVI	B,20
	MVI	C,TIMER		; Wait 2 seconds
	CALL	MEX
	LXI	H,SMATN		; Send '+++'
	CALL	SMSEND
	MVI	B,40		; Wait 4 more seconds (Anchor is slow)
	MVI	C,TIMER
	CALL	MEX
	LXI	H,SMDISC	; Send 'ATH'
	CALL	SMSEND
	MVI	B,10            ; Wait 1 second
	MVI	C,TIMER
	CALL	MEX
	RET
	 ENDIF
;
GOODBYE1: OUT	CTLPORT
	MVI	B,5		; DELAY 500 mS. for slow modems
	MVI	C,TIMER		; Increase this value to drop
	CALL	MEX		; DTR longer
GOODBYE:LDA	MSPEED		; Get baud rate
	STA	CSPEED		; Save for return from cpm
	MVI	A,5
	OUT	CTLPORT
	LDA	REG5		; RESTORE TO NORMAL
	OUT	CTLPORT
	CALL	MILP
	 IF	NOBLINK
	DB	BELL,0
	 ENDIF
	 IF	NOT NOBLINK
	DB	ESC,DENABL,BELL,0
	 ENDIF
	RET
;
; Initialize RS-232 port, default modes.
;
NITMOD:	CALL	INC		; SEE IF MODEM IS CONNECTED, I.E., RETURNING
	ANI	08H		; TO ACTIVE MODEM, WITH CARRIER FROM CP/M
	JNZ	OLDMOD		; Stay with old baud rate
	CALL	NITSIO		; INITIALIZE EXTERNAL RS-232 PORT
;
NITMOD2:LDA	DFBAUD		; SET DEFAULT BAUD RATE
	OUT	BAUDRP		; SEND TO BAUD GENERATOR
	LDA	MONFLG		; GET MONITOR DEFAULT
	ORA	A
	MVI	A,'0'		; Turn speaker off
	JZ	NITMOD4
	 IF	NOT USR2400 AND NOT ANCHOR AND NOT VOLKS12
                                ; Anchor and Volksmodem 12 modems 
                                ; do not have speakers
	MVI	A,'1'		; Turn speaker on
	 ENDIF
	 IF	USR2400
	MVI	A,'3'
	 ENDIF
NITMOD4:STA	SMINIT+3	; PUT IT IN SMINIT STRING
	LDA	ANSFLG		; GET MODE DEFAULT
	ORA	A
	MVI	A,'0'		; ORIGINATE
	JZ	NITMOD5
	MVI	A,'1'		; ANSWER
NITMOD5:STA	SMINIT+8	; PUT IT IN SMINIT STRING
	LXI	H,SMINIT
SINIT:	CALL	SMSEND		; SEND THE INIT STRING
SMTLP1:	MVI	C,INMDM		; WAIT FOR MODEM RESPONSE
	CALL	MEX
	JNC	SMTLP1		; EAT EVERYTHING UNTIL SILENCE FOR
	RET			; 100 mS.
;
OLDMOD:	LDA	CSPEED		; Get old baud rate
	STA	MSPEED		; Use after return from cpm
	RET
;
;	Initialize the Zilog SIO chip
;
NITSIO:	MVI	A,00H		; Select reg. 0
	OUT	CTLPORT
	LDA	REG0		; Command byte
	OUT	CTLPORT
	MVI	A,04H		; Select reg. 4
	OUT	CTLPORT
	LDA	REG4		; Receive/transmit control byte
	OUT	CTLPORT
	MVI	A,03H		; Select reg. 3
	OUT	CTLPORT
	LDA	REG3		; Receiver logic byte
	OUT	CTLPORT
	MVI	A,05H		; Select reg. 5
	OUT	CTLPORT
	LDA	REG5		; Transmitter logic byte
	OUT	CTLPORT
	RET
;
; Set to mask parity from input
;
NOPAR:	MVI	A,07FH
	STA	MASK
	RET
;
; Set to not mask parity from input
;
PARITY:	MVI	A,0FFH
	STA	MASK
	RET
;
; Set command processor
;
SETCMD:	MVI	C,SBLANK	; ANY ARGUMENTS?
	CALL	MEX
	JC	SETSHO		; IF NOT, DISPLAY DEFAULT(S)
	LXI	D,ECMDTBL
SETCMD1:MVI	C,LOOKUP
	CALL	MEX		; PARSE THE ARGUMENT
	PUSH	H		; SAVE ANY PARSED ARGUMENTS ON STACK
	RNC			; IF WE HAVE ONE, RETURN TO IT
	POP	H		; OOPS, INPUT NOT FOUND IN TABLE
SETERR:	LXI	D,SETEMS
	MVI	C,PRINT
	CALL	MEX
	RET
SETEMS:	DB	CR,LF,BELL,'SET command error',CR,LF,'$'
;
; Argument table
;
ECMDTBL:DB	'?'+80H		; HELP
	DW	SETHELP
	DB	'ORI','G'+80H	; ORIGINATE MODE
	DW	ORIG
	DB	'ANSWE','R'+80H	; ANSWER MODE
	DW	ANS
	DB	'TON','E'+80H	; TONE DIALING
	DW	STTONE
	DB	'PULS','E'+80H	; PULSE DIALING
	DW	STPULSE
	DB	'BLOC','K'+80H	; BLOCK CALL WAITING
	DW	BLK
	DB	'UNBLOC','K'+80H ; PERMIT CALL WAITING
	DW	NOBLK
	DB	'MONITO','R'+80H ; MONITOR ON
	DW	MONIT
	DB	'QUIE','T'+80H	; MONITOR OFF
	DW	QUIET
	DB	'BAU','D'+80H	; SET BAUD
	DW	STBAUD
	DB	'DELA','Y'+80H	; SET DELAY
	DW	DELAY
	DB	'PARIT','Y'+80H	; SET PARITY
	DW	STPRTY
	DB	'STOPBIT','S'+80H ; SET STOPBITS
	DW	STSTOP
	DB	'LENGT','H'+80H	; SET LENGTH
	DW	STBITS
	DB	'PB','X'+80H	; SET FOR PBX SYSTEM
	DW	SETPBX
	DB	'STANDAR','D'+80H ; SET STANDARD PHONE
	DW	SETSTD
	DB	0		; TABLE TERMINATOR
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	CALL	MILP
	DB	CLCRT,LF,LF
	DB	'Current SET values:',CR,LF,0
	CALL	CRLF
	CALL	MODEMSH		; Type of modem, external
	CALL	CRLF
	CALL	MDSHOW		; Mode, answer or originate
	CALL	CRLF
	CALL	PBXSHOW		; Telephone system being used
	CALL	CRLF
	CALL	TPSHOW		; Tone or pulse dialing
	CALL	CRLF
	CALL	BDSHOW		; Baud rate in effect
	CALL	CRLF
	CALL	DLSHOW		; Delay for answer after dial
	CALL	CRLF
	CALL	CRLF
	CALL	SHPRTY		; Parity being used
	CALL	CRLF
	CALL	SHSTOP		; Show stop bit(s)
	CALL	CRLF
	CALL	SHBITS		; Bits/charcter
	CALL	CRLF
	CALL	MONSHO		; State of monitor speaker
	CALL	CRLF
	CALL	CRLF
	RET
;
; "SET ?" processor
;
SETHELP:CALL	MILP
	DB	CLCRT
	DB	LF,LF,'SET ORIG      - Originate Mode'
	DB	CR,LF,'SET ANSWER    - Answer Mode'
	DB	CR,LF,'              < pulse dial through PBX >'
	DB	CR,LF,'SET PBX       - Use for PBX system'
	DB	CR,LF,'SET STANDARD  - Use for standard phone system'
	DB	CR,LF,'SET TONE      - Use Tone Dialing'
	DB	CR,LF,'SET PULSE     - Use Pulse Dialing'
	DB	CR,LF,'              < No call-waiting functions if PBX >'
	DB	CR,LF,'SET BLOCK     - Block Call-waiting'
	DB	CR,LF,'SET UNBLOCK   - Permit Call-waiting'
	DB	CR,LF,'SET DELAY     - <N> seconds to wait for answer'
	DB	CR,LF,'SET QUIET     - Disable Speaker'
	DB	CR,LF,'SET MONITOR   - Enable Speaker'
	DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	DB	CR,LF,'SET BAUD      - 110, 300, 1200, 2400, '
	DB	'4800, 9600, or 19200'
	DB	CR,LF,CR,LF,0
	RET
;
; "SET MODEM" processor
;
EXTM	EQU	$
MODEMSH:CALL	MILP
	DB	'External Modem',0
	RET
;
; "SET BAUD" processor
;
STBAUD:	MVI	C,BDPARS	; FUNCTION CODE: PARSE A BAUDRATE
	CALL	MEX		; LET MEX LOOK UP CODE
	JC	SETERR		; JUMP IF INVALID CODE
	CALL	PBAUD		; NO, TRY TO SET IT
	JC	SETERR		; IF NOT ONE OF OURS, BOMB OUT
BDSHOW:	LDA	MSPEED		; GET CURRENT BAUD RATE
	MVI	C,PRBAUD	; LET MEX PRINT IT
	CALL	MEX
	RET
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported.
;
PBAUD:	PUSH	H		; DON'T ALTER ANYBODY
	PUSH	D
	PUSH	B
	MOV	E,A		; MSPEED CODE TO DE
	MVI	D,0
	LXI	H,BAUDTB	; OFFSET INTO TABLE
	DAD	D
	MOV	A,M		; FETCH CODE
	ORA	A		; 0 MEANS UNSUPPORTED CODE
	STC			; PREP CARRY IN CASE UNSUPPORTED
	JZ	PBEXIT		; EXIT IF BAD
	OUT	BAUDRP		; NO, SET THE RATE
	STA	DFBAUD		; SAVE CURRENT RATE
	MOV	A,E		; GET MSPEED CODE BACK
	STA	MSPEED		; SET IT
	ORA	A		; RETURN NO ERRORS
PBEXIT:	POP	B
	POP	D
	POP	H
	RET
;
; Setting baud rates unsupported by your modem to 0 will prevent accidentally
; putting your modem into an error condition and possibly locking it up.
BAUDTB:	DB	02H		; 02H =   110 baud
	DB	05H		; 05H =   300 baud
	DB	0		; 450 (not supported in this overlay)
	DB	0  		; 06H =   600 baud
	DB	0		; 710 (not supported in this overlay)
	DB	07H		; 07H =  1200 baud
	DB	0AH		; 0AH =  2400 baud
	DB	0CH             ; 0CH =  4800 baud
	DB	0EH  		; 0EH =  9600 baud
	DB	0FH  		; 0FH = 19200 baud
;
SET12:	PUSH	PSW		; DON'T ALTER ANYBODY
	PUSH	B
	MVI	A,07H
	OUT	BAUDRP
	STA	DFBAUD		; SAVE CURRENT RATE
	MVI	A,05H		; GET MSPEED CODE BACK
	STA	MSPEED		; SET IT
	POP	B
	POP	PSW
	ORA	A		; RETURN WITH NO ERROR
	RET
;
; Set mode processor
;
ORIG:	XRA	A
	STA	ANSFLG		; SET ORIG FLAG
	LXI	H,SMO		; SEND OUT ATS0=0
	CALL	SINIT
	JMP	MDSHOW
ANS:	MVI	A,0FFH
	STA	ANSFLG		; SET ANS FLAG
	LXI	H,SMA		; SEND OUT ATS0=1
	CALL	SINIT
MDSHOW:	LDA	ANSFLG
	ORA	A
	JZ	MDORIG
MDSHW1:	CALL	MILP
	DB	'Answer mode',0
	RET
MDORIG:	CALL	MILP
	DB	'Originate mode',0
	RET
SMO:	DB	'ATS0=0',CR,0
SMA:	DB	'ATS0=1',CR,0
;
; Monitor control processor
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
	DB	'Monitor Speaker: On',0
	RET
MONOFF:	CALL	MILP
	DB	'Monitor Speaker: Off',0
	RET
SMQT:	DB	'ATM0',CR,0
SMMON:
	 IF	NOT USR2400
	DB	'ATM1',CR,0
	 ENDIF
	 IF	USR2400
	DB	'ATM3',CR,0
	 ENDIF
;
; Set dial processor
;
STTONE:	MVI	B,'T'
	JMP	SDIAL1
STPULSE:MVI	B,'P'
SDIAL1:	LDA	TPULSE
	CMP	B
	JZ	TPSHOW
	MOV	A,B
	STA	TPULSE
TPSHOW:	LDA	TPULSE
	CPI	'T'
	JZ	TPTONE
	CALL	MILP
	DB	'Pulse Dialing',0
	RET
TPTONE:	CALL	MILP
	DB	'Tone Dialing',0
	RET
;
; Set Call-waiting processor
;
BLK:	XRA	A		; Clear accumulator
	STA	BLKFLG		; Store in flag area
	JMP	BLKSHOW		; Show mode of operation
NOBLK:	MVI	A,0FFH		; Allow call waiting
	STA	BLKFLG		; Store in flag area
BLKSHOW:LDA	PBXFLG		; Check for PBX system
	ORA	A		; Set flags
	JNZ	PBXBLK		; Can't use both PBX & BLOCK
	LDA	BLKFLG		; Get mode flag
	CPI	0		; Check for block of call waiting
	JZ	BLKSYS		; Yes, go tell
	CALL	MILP
	DB	'Call-waiting interrupt OK',0
	RET
BLKSYS:	CALL	MILP
	DB	'Call-waiting BLOCKED',0
	RET
PBXBLK:	CALL	MILP
	DB	'Call-waiting BLOCK not active with PBX',0
	RET
;
; Set delay processor
;
DELAY:	MVI	C,EVALA
	CALL	MEX
	MOV	A,H
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	NDELAY
DLSHOW:	CALL	MILP
	DB	'Answer Delay is ',0
	LDA	NDELAY
	MOV	L,A
	MVI	H,0
	MVI	C,DECOUT
	CALL	MEX
	CALL	MILP
	DB	' seconds',0
	RET
;
;	SET PARITY command: reset transmit/receive parity
;
;		Parity is controlled by bits 0 and 1 of
;		the byte sent to the SIO write-register
;		4 as follows:
;
;		   Parity	Bit 1	   Bit 0
;		     Off	  -	     0
;		     Odd	  0	     1
;		     Even	  1	     1
;
STPRTY:	MVI	C,SBLANK	; Check for parity code
	CALL	MEX		;
	JC	SETERR		; If none, print error
	LXI	D,PARTBL	; Check for proper syntax
	MVI	C,LOOKUP
	CALL	MEX
	PUSH	H		; Match found, go do it!
	RNC			;
	POP	H		; No match: fix stack and
	JMP	SETERR		; Print error
;
PROFF:	LDA	REG4		; Get register 4 byte
	ANI	0FEH		; Reset bit 0
	JMP	PARTB1		;
PREVEN:	LDA	REG4		;
	ORI	003H		; Set bits 0 & 1
	JMP	PARTB1		;
PRODD:	LDA	REG4		;
	ORI	001H		; Set bit 0
	ANI	0FDH		; Reset bit 1
PARTB1:	STA	REG4		;
	CALL	NITSIO		; Re-initialize the USART
	CALL	SHPRTY		; Print the result
	RET			;
SHPRTY:	CALL	MILP		; Display parity
	DB	'Parity:  ',TAB,' ',0
	LDA	REG4		;
	ANI	001H		; Test bit 0
	CPI	0		; If bit0=0 then parity off
	JNZ	SHPRT1		;
	CALL	MILP		;
	DB	'Off',0		;
	RET
SHPRT1:	LDA	REG4		;
	ANI	002H		; Test bit 1
	CPI	0		; If bit1=0 then parity odd
	JNZ	SHPRT2		;
	CALL	MILP		;
	DB	'Odd',0		;
	RET			;
SHPRT2:	CALL	MILP		;
	DB	'Even',0	;
	RET
;
;	SET PARITY command table
;
PARTBL:	DB	'OF','F'+80H	; set parity off
        DW      PROFF
        DB      'NON','E'+80H   ; set parity to none (off)
        DW      PROFF
	DB	'EVE','N'+80H	; set parity even
	DW	PREVEN
	DB	'OD','D'+80H	; set parity odd
	DW	PRODD
	DB	0		; <<== end of parity table
;
;	SET STOPBITS command: reset number of stop bits
;
;		The number of stop bits is controlled by bits
;		2 and 3 of the byte sent to the SIO write-
;		register 4, as follows:
;
;		    Stop bits	   Bit 3	Bit 2
;			1	     0		  1
;		       1.5	     1		  0
;			2	     1		  1
;
;
STSTOP:	MVI	C,SBLANK	; Check for stop bits
	CALL	MEX		;
	JC	SETERR		; If none, print error
	LXI	D,STPTBL	; Check for proper syntax
	MVI	C,LOOKUP
	CALL	MEX		;
	PUSH	H		; Match found, go do it!
	RNC			;
	POP	H		; No match: fix stack and
	JMP	SETERR		; Print error
;
STOP01:	LDA	REG4		; Get register 4 byte
	ANI	0F7H		; Reset bit 3
	ORI	004H		; Set bit 2
	JMP	STSTP1		;
STOP02:	LDA	REG4		;
	ORI	00CH		; Set bits 2 and 3
	JMP	STSTP1		;
STOP15:	LDA	REG4		;
	ORI	008H		; Set bit 3
	ANI	0F8H		; Reset bit 2
STSTP1:	STA	REG4		;
	CALL	NITSIO		;
	CALL	SHSTOP		; Print the result
	RET
SHSTOP:	CALL	MILP		; Display stop-bits
	DB	'Stop bits:',TAB,' ',0
	LDA	REG4		;
	ANI	004H		; Test bit 2
	CPI	0		; If bit2=0 then 1.5
	JNZ	SHSTP1		;
	CALL	MILP		;
	DB	'1.5',0		;
	RET
SHSTP1:	LDA	REG4		;
	ANI	008H		; Test bit 3
	CPI	0		; If bit3=0 then 1
	JNZ	SHSTP2		;
	CALL	MILP		;
	DB	'1',0		;
	RET
SHSTP2:	CALL	MILP		;
	DB	'2',0		;
	RET
;
;	SET STOPBITS command table
;
STPTBL:	DB	'1'+80H		; "set stop 1"
	DW	STOP01
	DB	'2'+80H		; "set stop 2"
	DW	STOP02
	DB	'1.','5'+80H	; "set stop 1.5"
	DW	STOP15
	DB	0		; <<== End of stop-bits table
;
;	SET LENGTH command: set bits per character
;
;		The number of bits per character is controlled for
;		the receiver circuit by bits 6 and 7 of the byte
;		sent to the SIO write-register 3 and for the trans-
;		mitter circuit by bits 5 and 6 of the byte sent to
;		the SIO write-register 5.  The assumption has been
;		made here that both transmission and reception will
;		be carried on at the same number of bits per charac-
;		ter.  The bit configurations are shown for register
;		3 only, but are the same for register 5:
;
;		    BPC 	Bit 7		Bit 6
;		     5		  0		  0
;		     6		  1		  0
;		     7		  0		  1
;		     8		  1		  1
;
STBITS:	MVI	C,SBLANK	; Check for bits/char parameter
	CALL	MEX		;
	JC	SETERR		; If none, print error
	LXI	D,BITTBL	; Check for proper syntax
	MVI	C,LOOKUP
	CALL	MEX
	PUSH	H		; Match found, go do it!
	RNC			;
	POP	H		; No match: fix stack and
	JMP	SETERR		; Print error
;
BIT5:	LDA	REG3		;
	ANI	0BFH		; Reset bit 6
	ANI	07FH		; Reset bit 7
	STA	REG3		;
	LDA	REG5		;
	ANI	0DFH		; Reset bit 5
	ANI	0BFH		; Reset bit 6
	JMP	STBTS1		;
BIT6:	LDA	REG3		;
	ANI	0BFH		; Reset bit 6
	ORI	080H		; Set bit 7
	STA	REG3		;
	LDA	REG5		;
	ANI	0DFH		; Reset bit 5
	ORI	040H		; Set bit 6
	JMP	STBTS1		;
BIT7:	LDA	REG3		;
	ORI	040H		; Set bit 6
	ANI	07FH		; Reset bit 7
	STA	REG3		;
	LDA	REG5		;
	ORI	020H		; Set bit 5
	ANI	0BFH		; Reset bit 6
	JMP	STBTS1		;
BIT8:	LDA	REG3		;
	ORI	040H		; Set bit 6
	ORI	080H		; Set bit 7
	STA	REG3		;
	LDA	REG5		;
	ORI	020H		; Set bit 5
	ORI	040H		; Set bit 6
STBTS1:	STA	REG5		;
	CALL	NITSIO		;
	CALL	SHBITS		; Print the result
	RET
SHBITS:	CALL	MILP		; Display bits/char
	DB	'Bits/char:',TAB,' ',0
	LDA	REG5		;
	ANI	040H		; Test bit 6
	CPI	0		; If bit6=0 then 6 bpc
	JNZ	SHBTS2		;
	LDA	REG5		;
	ANI	020H		; Test bit 5
	CPI	0		; If bit5=0 then 5 bpc
	JNZ	SHBTS1		;
	CALL	MILP		;
	DB	'5',0		;
	RET			;
;
SHBTS1:	CALL	MILP		;
	DB	'7',0		;
	RET			;
SHBTS2:	LDA	REG5		;
	ANI	20H		; Test bit 5
	CPI	0		; If bit=5 then 6 bpc
	JNZ	SHBTS3		;
	CALL	MILP		;
	DB	'6',0		;
	RET			;
SHBTS3:	CALL	MILP		;
	DB	'8',0		;
	RET			;
;
; Set lenght command table
;
BITTBL:	DB	'5'+80H	; "set bits 5"
	DW	BIT5
	DB	'6'+80H	; "set bits 6"
	DW	BIT6
	DB	'7'+80H	; "set bits 7"
	DW	BIT7
	DB	'8'+80H	; "set bits 8"
	DW	BIT8
	DB	0		; <<== end of bpc table
;
;	 Set PBX command table
;
SETSTD:	XRA	A		; Clear accumulator
	STA	PBXFLG		; Store in flag area
	JMP	PBXSHOW		; Show system in use
SETPBX:	MVI	A,0FFH		; PBX system value
	STA	PBXFLG		; Store in flag area
PBXSHOW:LDA	PBXFLG		; Get system flag
	CPI	0FFH		; Check for PBX
	JZ	PBXSYS		; Yes, go tell
	CALL	MILP		;
	DB	'Standard phone system',CR,LF,0
	JMP	BLKSHOW		; Show call-waitig status
PBXSYS:	CALL	MILP
	DB	'PBX phone system',0
	RET
;
;This is the DIAL routine called by MEX to dial a digit. The digit
;to be dialed is passed in the A register. Note that two special
;codes must be intercepted as non-digits: 254 (start dial sequence)
;and 255 (end-dial sequence).  MEX will always call DIAL with 254
;in the accumulator prior to dialing a number. MEX will also call
;dial with 255 in A as an indication that dialing is completed. Thus,
;the overlay may use these values to "block" the number, holding it
;in a buffer until it is completely assembled (in fact, that's the
;scheme employed here).
;
;After the 254-start-dial sequence, MEX will call the overlay with
;digits, one-at-a-time.  MEX will make no assumtionns about the dig-
;its, and will send each to the DIAL routine un-inspected (some modems,
;like the Smartmodem, allow special non-numeric characters in the
;phone number, and MEX may make no assumptions about these).
;
;After receiving the end-dial sequence (255) the overlay must take
;whatever end-of-dial actions are necessary *including* waiting for
;carrier at the distant end.  The overlay should monitor the keyboard
;during this wait (using the MEX keystat service call), and return
;an exit code to MEX in the A registerm as follows:
;	0-Carrier detected, connection established
;	1-Far end busy (only for modems that can detect this condition)
;	2-No answer (or timed out waiting for modem response)
;	3-Keyboard abort (^C only: all others should be ignored)
;	4-Error reported by modem
;	5-No ring reported by modem
;	6-No dial tone reported by modem
; (No other codes should be returned after an end-dial sequence)
;
;The overlay should not loop forever in the carrier-eait routine, but
;instead use either the oberlay timer vector, of the INMDMV (timed 100
;ms character wait) service call routine.
;
;The DIAL routine is free to use any of the registers, but must return
;the above code after the end-dial sequence.
;
;Dialing routine
;
;
DIAL:	LHLD	DIALPT		; Fetch pointer
	CPI	254		; Start dial?
	JZ	STDIAL1		; Jump if so
	CPI	255		; End dial?
	JZ	ENDIAL1		; Jump if so
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	MOV	M,A		; Put character in buffer
	INX	H		; Advance pointer
	SHLD	DIALPT		; Stuff pointer
	RET
;
; Here on a start-dial sequence
;
STDIAL1:LXI	H,DIALBF	; Set up buffer pointer
	SHLD	DIALPT
	RET
;
PBXRTN:	LDA	TPULSE		; Get type dial
	STA	PBXDIAL+7	; Put it into string
	LXI	H,PBXDIAL	; Get PBX string
	CALL	SMSEND		; Send the string
	LXI	H,DIALBF	; Get address of dial buffer
	CALL	SMSEND		; Send the number
	JMP	WAITSM		; Wait for modem response
;
BLKRTN:	LDA	TPULSE		; Get type dial
	STA	BLKDIAL+3	; Put it into string
	LXI	H,BLKDIAL	; Get dial string
	CALL	SMSEND		; Send it
	LXI	H,DIALBF	; Get number to dial
	CALL	SMSEND		; Dial the number
	JMP	WAITSM		; Wait for midem response
;
; Here on end-dial sequence
;
ENDIAL1:MVI	M,CR		; Stuff end-of-line into buffer
	INX	H		; Followed by terminator
	MVI	M,0		;
	LDA	TPULSE		; Set overlay's touch-tone flag
	STA	SMDIAL+3	; Put into string
	LDA	PBXFLG		; Get PBX flag
	CPI	0FFH		; What system is it?
	JZ	PBXRTN		; Jump if PBX
	LDA	BLKFLG		; Get call waiting flag*
	CPI	0FFH		; Block call waiting?
	JNZ	BLKRTN		; Yes, then go block call waiting
	LXI	H,SMDIAL	; Point to dialing string
	CALL	SMSEND		; Send the string
WAITSM:	MVI	C,INMDM		; Get function
	CALL	MEX		; Catch any output from modem
	JNC	WAITSM		; Loop unitl no more characters
;
; The following loop waits for a result from the modem
;
RESULT:
	 IF	PRO1200
	XRA	A		; Clear accumulator
	STA	MDMRESP		; Clear storage area
	 ENDIF
	LDA	NDELAY		; Set delay count
	MOV	C,A		; Put delay count into C
SMWLP:	PUSH	B		; Save B&C on stack
	MVI	B,1		; Check for a char, up to 1 sec wait
	MVI	C,TMDINP	; Timed input function
	CALL	MEX		;
	POP	B		; Restore B after return
	JNC	SMTEST		; Jump if modem had a character
	PUSH	B		; No character, test for ^C from console
	MVI	C,CHEKCC	;
	CALL	MEX		;
	POP	B		;
	JNZ	SMNEXT		; If not, jump
	CALL	SMDMOFF		; Yes, shut down the modem
	MVI	A,3		; Return abort code
	RET
SMNEXT:	DCR	C		; No
	JNZ	SMWLP		; Continue
;
; No modem response within the time specified is SET DELAY command
;
SMTIMO:	CALL	SMDMOFF
	MVI	A,2		; Return timeout code
	RET
;
; Modem gave us a result, check it!
;
	 IF	NOT PRO1200
SMTEST:	ANI	07FH		; Ignore any parity
	CALL	SMANAL		; Test the result
	JC	RESULT		; Go try again if unknown response
	MOV	A,B		; A=result, returns with result in B
	PUSH	PSW		; Save it
	 ENDIF
	 IF	PRO1200
SMTEST:	ANI	0FH		; Mask ASCII data
	STA	MDMRESP		; Store character received
	MVI	B,0		; Clear B for transfer
NEXTBIT:MVI	C,INMDM		; Check for second ASCII character
	CALL	MEX
	CPI	CR		; Was it a carrage return?
	JZ	DONE		; Jump if it was the last
	ANI	0FH		; Make it ASCII
	MOV	B,A		; Save it in B
	LDA	MDMRESP		; Get the previous character
	RAL			; Make room for new LSB
	RAL
	RAL
	RAL
	ORA	B		; Put into BCD form
	STA	MDMRESP		; Store the two digit result
	JMP	NEXTBIT		; Check for another character
DONE:	LDA	MDMRESP		; Get the whole result
	CALL	SMANAL		; Test the result
	JC	RESULT		; If unknown, try again
	MOV	A,B		; Put result code in A
	PUSH	PSW		; Save the result
	 ENDIF
;
SMTLP:	MVI	C,INMDM		; Eat any additional chars from modem
	CALL	MEX
	JNC	SMTLP		; Until 100mS of quiet time
	POP	PSW		; Return the code
	RET
;
SMANAL:	MVI	B,0		; Prep connect code
	 IF	B300
	CPI	'C'		; "connect"?
	RZ
	 ENDIF
	 IF	NOT B300 AND NOT PRO1200
	CPI	'1'		; Numeric version of "connect"
	RZ
	CPI	'5'		; Numeric version of "connect 1200"
	JZ	SET12		; Insure that baud gets set to 1200
	 ENDIF
	 IF	PRO1200
	CPI	1		; Numeric for "connect"
	RZ
	CPI	5		; Numeric for "connect 1200"
	JZ	SET12
	 ENDIF
	INR	B		; Prep busy code B=1
	 IF	PRO1200
	CPI	62H		; Remote busy code
	JNZ	NOBZY		; Jump arround if not busy
	MVI	A,CR		; Get ready ot abort call
	MVI	C,SNDCHR	; Send carrage return to modem
	CALL	MEX
	RET
	 ENDIF
	 IF	NOT PRO1200 AND	NOT B300
	CPI	'B'
	RZ
	 ENDIF
	 IF	USR2400	OR ANCHOR OR PM2400SA
	CPI	'7'
	RZ
	 ENDIF
         IF     VOLKS12
        CPI     '3'
        RZ
         ENDIF
NOBZY:	INR	B		; Prep no connect message B=2
	CPI	'N'		; N=no connect
	RZ
	 IF	NOT PRO1200 AND	NOT B300
	CPI	'3'		; Numeric version of "no connect"
	RZ
	 ENDIF
	 IF	PRO1200
	CPI	3		; Not ASCII
	RZ
	 ENDIF
	MVI	B,4		; Prep for modem error
	CPI	'E'		; E=error
	RZ
	 IF	NOT B300 AND NOT PRO1200
	CPI	'4'		; Numeric version of error
	 ENDIF
	 IF	PRO1200
	CPI	4		; Not ASCII
	RZ
	CPI	41H		; Invalid command result code
	RZ
	CPI	45H		; Buffer overflow
	RZ
	MVI	B,5		; Prep no response (ring) to dial
	CPI	44H
	RZ
	 ENDIF
	 IF	USR2400	OR PRO1200 OR PM2400SA
	MVI	B,6
	 ENDIF
	 IF	USR2400 OR PM2400SA
	CPI	'6'		; No dial tone detected
	 ENDIF
	 IF	PRO1200
	CPI	43H		; No dial tone detected
	 ENDIF
	RZ
; Note: The Volksmodem12 has no response code for 'No dialtone detected'.
;
; Unknown response, return but first clear modem
;
WTLF:	CPI	LF		; Linefeed?
	STC			; Set carry flag
	RZ			; End if so
	 IF	PRO1200
	CPI	CR
	STC
	RZ
	 ENDIF
	MVI	C,INMDM		; No, get next character
	CALL	MEX
	JNC	WTLF		; Unless busy, then loop
	RET
;
; Utility sub-routines
;
SMSEND:	MVI	C,SNDRDY	; Wait for modem ready
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		; Fetch next character
	INX	H
	ORA	A		; End?
	RZ			; Done of so
	MOV	B,A		; No, position for sending
	MVI	C,SNDCHR	; Nope, send the character
	CALL	MEX
	JMP	SMSEND
;
SMDMOFF:MVI	B,DIALAB
	MVI	C,SNDCHR
	CALL	MEX
	MVI	B,10
	CALL	MTIME
;
	 IF	ANCHOR OR VOLKS12
	RET
	 ENDIF
;
	 IF	NOT ANCHOR AND NOT VOLKS12
	JMP	DISCON		; Make sure that it is off
	 ENDIF
;
MILP:	MVI	C,ILP
	JMP	MEX
	RET
;
MTIME:	MVI	C,TIMER
	JMP	MEX
	RET
;
COMMA:	CALL	MILP
	DB	',',0
	RET
;
CRLF:	CALL	MILP
	DB	CR,LF,0
	RET
;
;==============================================================
; Data area
;==============================================================
;
; Default UART parameters
;
REG0:	DB	00011000B	; Reset channel A
REG3:	DB	11000001B	; Enable receive at 8 bits/char
REG4:	DB	01000100B	; No parity, 1 stop bit, clock x16
REG5:	DB	11101010B	; Enable transmit at 8 bits/char
;
; Miscellaneous Default Data
;
	 IF	NOT PRO1200 AND	NOT USR2400 AND NOT PM2400SA
PBXDIAL:DB	'ATDP9, T',0	; String for PBX dial
	 ENDIF
	 IF	USR2400 OR PM2400SA
PBXDIAL:DB	'ATDP,9WT',0	; String for PBX dial
	 ENDIF
	 IF	PRO1200
PBXDIAL:DB	'ATDP 9WT',0
	 ENDIF
;
BLKDIAL:DB	'ATV0 DT70',0	; String to block call waaiting*
PBXFLG:	DB	00		; FF=PBX, 00=standard phone
;
	 IF	NEW1200	OR PM2400SA
SMDIAL:	DB	'ATV0 L3 DT '	; Please Read below:
;
;The Above DB Sets the NEW SMARTMODEM Defaults before dialing.
;The above SMDIAL was used to support my newer Model SMARTMODEM,
;and sets the following defaults before dialing.  The reason for this
;was when I took down the BBS on my System it set the Modem to OFF-HOOK
;and I have chosen to do an "ATZ" before trying to call another BBS with
;my system.
;
;	 V0 = NUMERIC RESULT CODES are displayed.
;	 L3 = Sets Monitor Speaker Volume to high volume.
;
;		   - Carol L. Miller, Sr.
;		    - SYSOP
;		     - EDP Consultants	- PBBS
;		      - (405) 237-9890
;
	 ENDIF			;
;
         IF VOLKS12
SMDIAL: DB      'ATV0 DT'       ;
         ENDIF
; The Volksmodem12 continually tries to return to verbose response codes.
; The best way I've found to avoid this is to always specify numeric
; responses each time you dial.
;
	 IF	NOT NEW1200 AND NOT PM2400SA AND NOT VOLKS12
SMDIAL:	DB	'ATDT '		;
	 ENDIF			;
DIALBF:	DS	52		; 2* 24 char max, + CR + NULL + SLOP
DIALPT:	DS	2		; Dial position pointer
EOSMSG:	DB	17H,'$'		; Clear to end of screen
CLSMSG:	DB	CLCRT,'$'	; Clear whole screen
DIGIT:	DB	0		; Save dialed digit
;
	 IF	B300
DFBAUD:	DB	05		; 5=300, 6=600, 7=1200, 0AH=2400, 0EH=9600
	 ENDIF
	 IF	B1200 OR ANCHOR	OR PRO1200 OR VOLKS12
DFBAUD:	DB	07
	 ENDIF
	 IF	USR2400 OR PM2400SA
DFBAUD:	DB	0AH
	 ENDIF
	 IF	ANCHOR OR VOLKS12
MONFLG:	DB	00H		; No monitor in ANCHOR or VOLKS12
	 ENDIF
	 IF     NOT ANCHOR AND NOT VOLKS12
MONFLG:	DB	0FFH		; 0=monitor off, 0FFH=monitor on
	 ENDIF
	 IF 	ANCHOR OR VOLKS12
SMATN:	DB	'+++',0		; ANCHOR uses Smartmodem codes for disconnect
SMDISC:	DB	'ATH',CR,0
	 ENDIF
;
BLKFLG:	DB	0FFH		; 0=block, FF=permit call waiting
ANSFLG:	DB	0		; 0=originate, 0FFH=answer
NDELAY:	DB	25		; Number of seconds for answer
MDMRESP:DB	0		; Storage for modem response characters
;
	 IF	USR2400
SMINIT:	DB	'ATM3 S0=0 S7=60 S10=20 X4 V0',CR,0 ; Extended codes
	 ENDIF
	 IF	PM2400SA
SMINIT:	DB	'ATM3 S0=0 S7=60 L3 X4 V0 &D2',CR,0 ; Extended codes
	 ENDIF
	 IF	B1200 OR ANCHOR
SMINIT:	DB	'ATM1 S0=0 S7=60 X1 V0 Q0',CR,0	; Some extended codes
	 ENDIF
         IF     VOLKS12
SMINIT: DB      'ATS0=0 V0'     ;No extended codes
         ENDIF
	 IF	PRO1200
SMINIT:	DB	'ATM1 S0=0 S7=60 S10=10 X1 V2 Q0 @TD',CR,0
	 ENDIF
	 IF	B300
SMINIT:	DB	'ATM1 S0=0 S7=60 S10=10 V1',CR,0 ; No extended commands
	 ENDIF
;
	END
