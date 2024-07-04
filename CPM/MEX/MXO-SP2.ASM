; MXO-SP2.ASM  -  Spectravideo SV328 overlay for MEX		01/28/87
;
; You will want to look over this file as there are a number of options
; that you can use to reconfigure the overlay to suit different equipment.
; This overlay is a modification of MXOH8.14 of 04/06/85, changed to suit
; the SV328 using the SV805 RS232 card having the 8250 I/O, driving a
; Hayes - protocol external modem.  The SET command is active to change
; baudrate when desired (but stay within the modem limits though).
; The word is fixed at 8 bits, 1 stop bit, no parity, in this overlay.
;
; Use the appropriate modem overlay next.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;
;       TO USE: First edit this file filling in answers for your own
;               equipment.  Then assemble with ASM.COM or equivalent
;               assembler. Then use MLOAD to overlay the the results
;               of this program to the original .COM file.
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 01/28/87 - Modified to suit SV328 (8250 I/O) ports and clock.
;            Renamed MXO-SP2 from MXOH8.14              O. Bilharz
; 06/20/84 - Added routines for 2661 I/O,       - Jim McAfee
;          - renamed MXO-H814 (4/6/85)
; 05/28/84 - MEXify labels/Change disconnect.   - Biff Bueffel
; 05/23/84 - Corrected clear-screen error       - Biff Bueffel
; 05/19/84 - Converted for MEX10                - Biff Bueffel
; 11/11/83 - Renamed to M7H8-1.ASM, no changes  - Irv Hoff
; 07/27/83 - Renamed to work with MDM712        - Irv Hoff
; 07/01/83 - Revised to work with MDM711        - Irv Hoff
; 06/22/83 - Revised to work with MDM710        - Irv Hoff
; 05/27/83 - Revised to work with MDM709        - Irv Hoff
; 05/15/83 - Revised to work with MDM708        - Irv Hoff
; 04/17/83 - Revised to work with MDM707        - Irv Hoff
; 04/04/83 - Updated to work with MDM706        - Irv Hoff
; 02/27/83 - Updated to work with MDM705        - Irv Hoff
; 02/17/83 - Updated to work with MDM704        - Irv Hoff
; 02/07/83 - Updated to work with MDM703        - Irv Hoff
; 01/27/83 - Updated to work with MDM702        - Irv Hoff
; 01/10/83 - Updated to work with MDM701        - Irv Hoff
; 10/03/82 - First version of this file
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:           EQU     07H             ;bell
CR:             EQU     0DH             ;carriage return
ESC:            EQU     1BH             ;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
; Change the value at MODDATP if it does not match what you are using.
;
DPORT:		EQU	028H		; Modem Data Port
SPORT:		EQU	DPORT+5		; Modem Status Port
MDRCVB: 	EQU	1		;bit to test for received data
MDRCVR: 	EQU	1		;modem receive ready
MDSNDB: 	EQU	20H		;bit to test for ready to send
MDSNDR: 	EQU	20H		;modem send ready bit
;
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
PRINT	EQU	9		;BDOS print-string function
;
		ORG	100H
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMODEM:		DB	NO	;yes=PMMI S-100 Modem			103H
SMODEM:		DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	104H
TPULSE:		DB	'P'	;T=Touch, P=Pulse (Smartmodem only)
CLOCK:		DB	37	;clock speed in MHz x 10, 25.5 MHz max	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFLG:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKFLG:		DB	YES	;yes=change any file same name to .BAK	10EH
CRCFLG:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFTST:		DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
;
;   	The following CTRL- sequences are active in Terminal mode
;
EXITCHR:	DB	'E'-40H	;^E = Exit to main menu			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
INCTL1:		IN	SPORT ! RET	;in modem control port		12AH
		DS	7
OTDATA:		OUT	DPORT ! RET	;out modem data port		134H
		DS	7
INPORT:		IN	DPORT ! RET	;in modem data port		13EH
		DS	7
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
;
		DS	2		;Not used by MEX		160H
		DS	3		;				162H
DISCV:		JMP	DISCON		;disconnect			
GOODBV:		JMP	GOODBY		;				168H
INMODV:		JMP	NITMOD		;go to user written routine	16BH
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETCMD		;				177H
		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SBREAK		;				180H
;
; -----------------------------------------------------------------
;
; Do not change the following six lines.
;
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
INCMPV:		DS	3		;				189H
INMDMV:		DS	3		;				18CH
		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
; ---------------------------------------------------------------------
;
; The following are screen clearing routines
;
CLREOS:  	LXI 	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLS:		LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
; -----------
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for SV328 with 8250 I/O.',CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0B00H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0D00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
;
GOODBY:	  RET			;Not done here
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
;
SBREAK:   MVI	A,40H		;SET BREAK TONE
	  OUT	DPORT+3
	  JMP	DISC1		;SEND A 300 MS. BREAK TONE
;.....
;
;				Disconnect modem
DISCON:	  XRA	A
;
DISC1:	  OUT	DPORT+4		;SET DTR AND RTS LOW
	  MVI	B,3		;WAIT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX	
	  MVI	A,03H		;RESET TO NORMAL 8 BITS
	  OUT	DPORT+3
	  MVI	A,01H
	  OUT	DPORT+4		;RESET DTR HIGH
	  RET
;
;.....
;
;
; The following is used to initialize the I/O port
;
NITMOD: MVI	A,1		;default transfer speed to 300 baud
	STA	MSPEED
 	DI			;turn off interrupts for init.
;
;			 	;initialize the 8250
	  XRA	A
	  OUT	DPORT+1		;interrupt enable register
	MVI	A,80H		;Set LCR bit 7 to access divisor
	  OUT	DPORT+3		;line control register
	  OUT	DPORT+3
;
LSPSPD:	  MVI	A,80H		;default 'LSP' speed for 300 baud
	  OUT	DPORT		;register for 'LSP' speed if enabled
;
MSPSPD:	  MVI	A,01H		;default 'MSP' speed for 300 baud
	  OUT	DPORT+1		;register for 'MSP' speed if enabled
;
	  MVI	A,03H		;8-level, 1 stop bit, no parity
	  OUT	DPORT+3		;line control register
	  MVI	A,01H		;set 'DTR' for proper modem output level
	  OUT	DPORT+4		;modem control register
;
	  EI			;restore interrupts to normal
	  RET
;.....
;
;
; The following changes the baud rate with the SET command.
;
;
SETCMD:	  MVI	C,SBLANK	;Any arguments?
	  CALL	MEX
	  JC	TELL		;If not, go display baud
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;Tell user input not valid
	  DB	CR,LF,'Only 300, 600, 1200, 2400, or 9600'
          DB	' allowed on SET command',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'60','0'+80H
	  DW	OK600
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'240','0'+80H
	  DW	OK2400
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	0
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP 	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
;
;
LOADBD:	  STA	NITMOD+1	;store speed to show transfer time
;
	  MOV	A,L		;get least significant baud rate byte
	  STA	LSPSPD+1	;store in NITMOD
	  MOV	A,H		;get most signifcant baud rate byte
	  STA	MSPSPD+1	;store in NITMOD
	  JMP	NITMOD		;reset H89 8250
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	3
	  JZ	OK600
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ    OK2400
	  CPI	8
	  JZ 	OK9600
	  RET
;
;
; Table of baud rate parameters
;    8250  with 3.072 MHz Xtal
;
BD300:	DW	0280H
BD600:	DW	0140H
BD1200:	DW	00A0H
BD2400:	DW	0050H
BD9600:	DW	0014H
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END
;
