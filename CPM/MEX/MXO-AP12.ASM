; MXO-AP12.ASM     Apple overlay file for MEX10.COM     06/03/84
;
REV	EQU	12
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 06/03/84   Completely MEXized, with all new lables, exclusive use of
;	     MEX processor, and a MEX SET routine which allows setting
;	     baud rate, smodem speaker on/off, and smodem auto answer
;	     on/off.  Type SET ? for command syntax, SET for current 
;	     settings.					-Norman Beeler	
; 05/27/84   Modified initialization routine (CPS) to check for carrier
;	     before initializing, to allow exiting MEX to CPM, (intentional
;	     or otherwise) and re-entering MEX without dropping line.
;	     Changed smodem wait-for-answer to 20 sec (Ma Bell charges for 
;	     30 sec, busy signal or not)		-Norman Beeler
;
; 05/17/84   Revised MDM7AP-4.ASM and renamed as MEX overlay.  Added
;	     PBAUD subroutine to allow auto baud set by MEX.   
;						        - Norman Beeler
;		 
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; This overlay file enables Apple II computers with various serial 
; cards and external modems to use the MEX10  phone modem program.
; It supports the following Apple configurations:
;
;	1.Microsoft Z80 card or equivalent
;			 or
;	2.         PCPI Applicard
;			with	
;	a) CCS 7710 serial interface and external modem
;	b) SSM serial interface and external modem
;	c) Apple communications interface and external modem
;	d) Mountain Hardware CPS Multifunction card and external modem
;	e) Prometheus Versacard with software baud select and ext. modem
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MEX10.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
; Use the "SET" command to change the baudrate during program execution.  
;
; To use SET with the Prometheus Versacard a small hardware mod must be
; made, since the Versacard only supports baud rate selection via DIP 
; switches. This Mod will allow the Versacard to be switched between
; 300 and 1200 baud via software.
; A wire should be attached from Pin #12 on U16 (IC marked 8126)
; on the Versacard into Annunciator #3 (Pin #12) on the Apple game port.
; This will allow switch #4 on s2 of the Versacard to be toggled by setting
; or clearing annunciator #3. The default baud rate is set at MSPEED Below
; either (300 or 1200). Note: This method could be extended to all other
; Versacard baud rates and by using Annunciators 0,1,2 but 300 and
; 1200 are really needed for a modem program. The DIP switches on the
; Versacard should be set as follows:		-Tony Antonucci
;
; On switch bank #2: 
;			s2 - ON
;			s3 - OFF
;			s4 - OFF
;			s5 - OFF
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then follow instructions in MEX doc to 
;		overlay program.
;

;
BELL:		EQU	07H	;bell
CR:		EQU	0DH	;carriage return
ESC:		EQU	1BH	;escape
LF:		EQU	0AH	;linefeed
TAB:		EQU	09H	;tab
;
YES:		EQU	0FFH
NO:		EQU	0
;
SLOT:		EQU	2	;slot of serial interface
SLOTOFF:	EQU	16*SLOT	;serial card slot offset
;
APPLICARD	EQU	NO 	;YES for Applicard
CCS:		EQU	NO	;YES for CCS 7710
VERSA:		EQU	NO 	;YES for Prometheus Versacard
COMCARD:	EQU	NO	;YES for Apple comcard
SSC:		EQU	NO	;YES for Super Serial Card
SSM:		EQU	NO	;YES for SSM serial card
CPS:		EQU	YES     ;YES for CPS card
;
		 IF 	APPLICARD
OFFSET		EQU	0C000H	;Applicard/Apple addressing offset
;
RDBYTE:		EQU	0FFE0H	;Read a byte from apple (A=byte)
WRBYTE:		EQU	0FFE3H	;Write a byte to apple (c=byte)
RDWORD		EQU	0FFE6H	;Read 2 bytes from apple (de=bytes)
WRWORD:		EQU	0FFE9H	;Write 2 bytes to apple (de=bytes)
RDNBYTS:	EQU	0FFECH  ;Read N bytes (de=count, hl=buffer)
WRNBYTS:	EQU	0FFEFH  ;Write N bytes (de=count, hl=buffer)
PEEK1BYTE:	EQU	6	;Command to peek 1 byte in apple
POKE1BYTE:	EQU	7	;Command to poke 1 byte in apple
		 ENDIF		;APPLICARD 
;
		 IF	NOT APPLICARD
OFFSET		EQU	0E000H	;Microsoft z80 (and everybody else)
		 ENDIF		;NOT APPLICARD
;
		 IF	VERSA
AN3SET:		EQU	0E05FH	;set annunciator #3
AN3CLR:		EQU	0E05EH	;clr	  "
		 ENDIF		;Versacard hardware mod support
;
		 IF	CCS
MODDAT:		EQU	  081H+OFFSET+SLOTOFF	;data port of CCS 7710
MODCT2:		EQU	  080H+OFFSET+SLOTOFF	;status port of CCS 7710
		 ENDIF		;endif CCS
;
		 IF	COMCARD OR VERSA
MODDAT:		EQU	  08FH+OFFSET+SLOTOFF	;data port of Comcard
MODCT2:		EQU	  08EH+OFFSET+SLOTOFF	;status port of Comcard
		 ENDIF		;endif Comcard or Versacard
;
		 IF	SSM
MODDAT:		EQU	  085H+OFFSET+SLOTOFF	;data port of SSM
MODCT2:		EQU	  084H+OFFSET+SLOTOFF	;status port of SSM
		 ENDIF		;endif SSM
;
		 IF	SSC
MODDAT:		EQU	  088H+OFFSET+SLOTOFF	;data port of Apple Super Serial Card
MODCT2:		EQU	  089H+OFFSET+SLOTOFF	;modem status port of Super Serial Card
MDRCVB:		EQU	08H	;bit to test for received data
MDRCVR:		EQU	08H	;modem receive ready
MDSNDB:		EQU	10H	;bit to test for ready to send
MDSNDR:		EQU	10H	;modem send ready bit
		 ENDIF		;endif SSC
;
;
; (Any slot with any CPS function assigned to it may be used.)
;
		 IF	CPS
MODCT1:		EQU	  0FEH+OFFSET+SLOT*100H  ;control port of CPS card
MODDAT:		EQU	  0FAH+OFFSET+SLOT*100H  ;data port of CPS card
MODCT2:		EQU	  0FBH+OFFSET+SLOT*100H  ;status port of CPS card
MDRCVB:		EQU	02H			;bit to test for receive
MDRCVR:		EQU	02H			;value when ready
MDSNDB:		EQU	01H			;bit to test for send
MDSNDR:		EQU	01H			;value when ready
MDDCDB:		EQU	01000000B		;DCD carrier bit mask
MDDCDR:		EQU	01000000B		;value if carrier received
MDDSRB:		EQU	10000000B		;DSR bit mask (used instead
MDDSRR:		EQU	10000000B		;...of dcd for BYE compat
;
; Command port equates
;
CBASE:		EQU	00000101B	;Command base
RESET:		EQU	00010000B	;Reset errors
DTR:		EQU	00000010B	;Turn on DTR
RTS:		EQU	00100000B	;Turn on RTS
		 ENDIF		;endif CPS
;
;
; Apple status bit equates for CCS, Comcard, Versacard and SSM
;
		 IF	NOT SSC AND NOT CPS
MDSNDB:		EQU	02H	;bit to test for send
MDSNDR:		EQU	02H	;value when ready
MDRCVB:		EQU	01H	;bit to test for receive
MDRCVR:		EQU	01H	;value when ready
		 ENDIF		;not SSC and not CPS
;
;
; We have software control over the Super Serial, CPS cards and
; Versacard; if hardware mod is made, so SETCMDTST is YES for
; those cards, below.
;.......
;  MEX processor stuff
;.......
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
CONOUT	EQU	2		;simulated BDOS function 2
PRINT	EQU	9		;simulated BDOS function 9
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
; ************************************************************************
		ORG	100H
;
;
; Change the clock speed to match your equipment.  The Microsoft Softcard
; operates at 2 MHz.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMODEM:		DB	NO	;yes=PMMI S-100 Modem			103H
SMODEM:		DB	YES	;yes=HAYES Smartmodem, no=non-pmmi	104H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHz, 37=3.68 MHz, 40=4 MHz, etc.
				;Applicard values should not be multiplied
				;by 10 because of 6502 overhead
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
				;program when used. 
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES 	;Cursor control routine 		10CH
		DB	0 	;was ACKNAK, now a spare	10DH
BAKFLG:		DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:		DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling of LOCNXT	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFTST:		DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'B'-40H	;^B = Send 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'W'-40H	;^W = Send next character		127H
		DS	2		;				128H
;
	IF	NOT APPLICARD
;
INCTL2:		LDA	MODCT2 ! RET	;in modem control port		12AH
		DS	6		;spares
OUTDATA:	STA	MODDAT ! RET	;out modem data port		134H
		DS	6
INPORT:		LDA	MODDAT ! RET	;in modem data port		13EH
		DS	6		;spares if needed
;
	ENDIF				;NOT APPLICARD
;
	IF	APPLICARD
;
INCTL2:		JMP	RD$MODCT2 					12AH
		DS	7
OUTDATA:	JMP	WR$MODDAT
		DS	7
INPORT:		JMP	RD$MODDAT
		DS	7
;
	ENDIF				;APPLICARD
;
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
LOGON:		DS	2		;not used by MEX  		160H
DIALV:		DS	3		;not used in this overlay	162H
DISCV:		JMP	MDINIT		;drops DTR to hang-up fast!
GOODBV:		JMP	GOODBYE		;called before exit to CPM	168H
INMODV:		JMP	INITMOD		;go to user written routine	16BH
NEWBDV:		JMP	PBAUD		;changes baud with phone #
NOPARV:		RET  !	NOP  !	NOP	;set modem for no-parity 	171H
PARITV:		RET  !	NOP  !	NOP	;set modem parity         	174H
SETUPV:		JMP	SETCMD		;				177H
SPMENV:		DS 	3		;not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
ILPRTV:		DS	3		;replace with MEX function 9 	183H
INBUFV:		DS	3		;replace with MEX functin 10	186H
ILCMPV:		DS	3		;replace with table lookup funct 247
INMDMV:		DS	3		;replace with MEX function 255	18CH
NXSCRV:		DS	3		;not supported by MEX		18FH
TIMERV:		DS	3		;replace with MEX function 254	192H
;
;
CLREOS:		LXI	D,EOSMSG	;				195H
		MVI	C,PRINT
		CALL	MEX
		RET			;				19DH
;
CLS:		LXI	D,CLSMSG	;				19EH
		MVI	C,PRINT
		CALL	MEX
		RET			;				1A6H
;----------------------------
;
;		*** END OF FIXED FORMAT AREA ***
;
;----------------------------
;
	IF	APPLICARD
RD$MODCT2:			;Read the modem control port
	PUSH 	D
	LXI	D,MODCT2
	CALL	PEEK
	POP	D
	RET
;
WR$MODCT2:			;Write the modem control port
	PUSH	D
	LXI	D,MODCT2
	CALL	POKE
	POP	D
	RET
;
RD$MODDAT:			;Read the modem data port
	PUSH	D
	LXI	D,MODDAT
	CALL	PEEK
	POP 	D
	RET
;
WR$MODDAT:			;Write the modem data port
	PUSH	D
	LXI	D,MODDAT
	CALL	POKE
	POP	D
	RET
;
RD$MODCTL2:			;read the baud rate port
	PUSH	D
	LXI	D,MODCTL2
	CALL	PEEK
	POP	D
	RET
;
WR$MODCTL2:			;Write the modem baud rate port
	PUSH	D
	LXI	D,MODCTL2
	CALL	POKE
	POP	D
	RET
;
WR$MODCMDP:			;write the control port 2
	PUSH D
	LXI D,MODCMDP
	CALL	POKE
	POP	D
	RET
;
PEEK:				;Peek at 1 byte in the apple
				;Entry  DE=address
				;Exit   A=data
	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	RET
;
POKE:				;Poke 1 byte into the apple
				;Entry DE=address
				;Exit  A=data
	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	RET
;
	ENDIF		;APPLICARD
;
;..........
; You can add your own routine here to send a break tone to reset time-
; share computers, if desired.
;
	 IF NOT CPS
SENDBRK:	RET
	 ENDIF		;endif not CPS
;
	 IF CPS
SENDBRK:	MVI	A,80H	;open the command register
		STA	MODCT1	;by storing 80H in MODCT1
		MVI	A,3FH	;send a break by storing
		STA	MODCT2	;$3F in MODCT2
		XRA	A	;close the command register
		STA	MODCT1	;by storing 00H in MODCT1
		RET
	 ENDIF		;endif CPS
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:			;just return for MEX to allow return
				;to system w/o dropping line
	RET
;
;.....
;
;
; The following address is used to set data bits, parity, stop bits
; and baud rate on the Super Serial Card.
;
	 IF SSC
;MODDLL:	EQU	 0E0ABH		;SSC ACIA control register
;
;
; Control over number of data bits, parity and number of stop
; bits (thru MSB300:) has not been implemented.  These must be
; set using the slide switches on the Super Serial Card.
;
; The following is used to initialize the Apple SSC on execution of the
; program.  Change it to initialize the modem port on your micro if you
; wish.  It initializes to 300 baud.
;
INITMOD:
	MVI	A,1		;default transfer time to 300
	STA	MSPEED
	LDA	MODDLL		;current baudrate from MODDLL
	ANI   0F0H		;zero the last 4 bits
;
INITMOD1:
	ORI   BDSET             ;get default baudrate (300)
	STA	MODDLL		;store default baudrate
	RET
	 ENDIF			;SSC
;.....
;
;
; The following may be used to initialize the Mountain Hardware CPS
; Multifunction Card for eight bits, no parity, one stop bit, and
; 1200 baud.  This does not alter the CPS defaults outside of MEX
;
	 IF CPS
INITMOD: 
	CALL	CARRCK		;check for carrier already present
	RZ			;if it is, don't do the rest!
	MVI	A,5
	CALL 	PBAUD
	MVI	A,1
	CALL	PBAUD
	CALL	MDINIT		;Initialize modem 
	MVI	A,5
	CALL 	PBAUD
	RET			;INITMOD return
;
INITMOD1:
	CALL	OPENCMD		;Open CPS command register
	MVI	A,37H		;initialize the serial chip
	STA	MODCT2		;by storing 37H in MODCT2
	MVI	A,4EH		;set 1 stop bit, no parity
	STA	MODDAT		;by storing $4E in MODDAT
	LDA     BDSET           ;set baud rate at BDSET  by storing
	STA	MODDAT		;in MODDAT (same address - the two 
				;registers cycle with each write)
	CALL    CLOSECMD	;Close CPS command register
	RET
;
;
OPENCMD:			;Open the CPS command register
	MVI	A,80H
	STA	MODCT1
	RET	
;
;
CLOSECMD:			;Close the CPS command register
	 MVI	A,0
	 STA	MODCT1
	 RET
;
;
MDINIT:				;Turns off DTR and re-initializes
	CALL	OPENCMD		;Open the cmd register
	MVI	A,CBASE		;Turn off DTR
	STA	MODCT2
	MVI	B,10		;Wait 1 second
	MVI     C,TIMER
	CALL	MEX
	MVI	A,CBASE+DTR+RTS ;Turn everything back on
	STA	MODCT2
	CALL	CLOSECMD	;Close the cmd register
	MVI	B,10		;Wait 1 second
	MVI	C,TIMER
	CALL	MEX
	LXI	H,SMATZ		;Send 'ATZ' to initialize modem
	CALL	SMSEND
	MVI	B,10		;Wait 1 more sec (sigh)
	MVI	C,TIMER
	CALL	MEX
	RET
;
SMATZ:	DB	'ATS7=20',CR,0
;....
;
; SMODEM UTILITY ROUTINE: SEND STRING TO MODEM
;
SMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	SMSEND
;
; carrier detect routine
;
CARRCK:
	LDA	MODCT2		;look at modem status port
	ANI	MDDSRB 		;mask for DSR-change if using DCD
	CPI	MDDSRR		;see if carrier is present (0=yes)
	RET
;
	ENDIF				;CPS
;
;.....
;
; The following routine initializes the Versacard to the default 
; baud rate which is set at MSPEED above. If MSPEED is set to something
; other then 300 or 1200 this routine does'nt alter The annunciator
; settings.
;
       	 IF VERSA 
INITMOD:LDA	MSPEED		;set annunciators to known state
	CPI	1		;is it 300 ?
	JZ	OK300
	CPI	5		;is it 1200 ?
	JZ	OK1200
	RET
	 ENDIF			;Versacard
;.....
;
	 IF NOT SSC AND NOT CPS AND NOT VERSA
INITMOD:RET			;intialization goes here, if needed
SETCMD:	RET			;routine to change baud rates, if needed
	 ENDIF			;NOT SSC AND NOT CPS
;.....
;
; Changes the modem baud rate with phone list entry
;.....
;
;
; Set baud-rate code in A (if supported by your modem overlay).  PMMI
; supports only five rates, which are validated here. NOTE: this routine
; (ie, the one vectored through NEWBDV) should update MSPEED with the
; passed code, but ONLY if that rate is supported by the hardware.
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	A,M		;fetch code
	ORA	A		;0? (means unsupported code)
	
	JZ	PBEXIT		;exit if so
	STA	BDSET 		;good rate, set it
	CALL	INITMOD1	;Baud set subroutine
	STA	BAUDSV		;save it
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
	JMP	PBEXIT + 1	;jump error flag set
PBEXIT:	STC			;set return error for STBAUD caller
	POP	B		;all done
	POP	D
	POP	H
	RET
;
; table of baud rate parameters for supported rates
;
	  IF	CPS	
BAUDTB:	DB	0,035h,0,0,0		;110,300,450,610,710
	DB	037h,0,0,0,0		;1200,2400,4800,9600,19200
BAUDSV: DB	037H			;1200 bps default
BDSET:	DB	037H
	  ENDIF ;CPS
;
	   IF 	SSC
BAUDTB:	DB	0,0006,0,0,0		;110,300,450,610,710
	DB	0007,0,0,0,0		;1200,2400,4800,9600,19200
BAUDSV: DB	0006			;300 bps default
BDSET:	DB	0006
	  ENDIF ;SSC
;
	   IF VERSA
BAUDTB:	DB	0,0E05EH,0,0,0		;110,300,450,610,710 (CLR AN#3)
	DB	0E05FH,0,0,0,0		;1200,2400,4800,9600,19200 (Set AN#3)
BAUDSV:	DB	0E05EH			;300 bps default
BDSET:	DB	0E05EH
	  ENDIF ;CPS
;
;
; Sign-on message
;
SYSVER:	LXI	D,VERMSG
	MVI	C,PRINT
	CALL	MEX
CARSHOW: LXI	D,NOMESG		;tell about carrier
	CALL	CARRCK			;check for it
	MVI	C,PRINT
	CNZ	MEX			;print the "NO" if no carrier
	LXI	D,CARMSG		;print "carrier present"
	MVI	C,PRINT
	CALL	MEX
	CALL	CRLF
	RET
;
;
NOMESG:	DB	'no $'
CARMSG:	DB	'carrier present','$'
;
; Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		;align output character
	MVI	C,CONOUT	;print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
; Data area
;
ERRFLG:	DB	0		;connection error code
SPKST:	DB	YES		;default to speaker on
ANST:	DB	NO		;default to not answer
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command -- if you prefer not to write a SET for your
; modem, you may delete the code from here to the END statement.
;
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	CALL 	CARRCK		;first check for carrier
	JZ	CARRON		;if carrier, jmp to on msg and print
	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse command
	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
CARRON:	LXI	D,CONMSG	;print carrier on msg
	MVI	C,PRINT
	CALL	MEX
	RET
;
CONMSG:	DB	CR,LF,'Carrier on...can not set',CR,LF,'$'
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.
;
; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'SPK','R'+80H		;"set spkr"
	DW	STSPKR
	DB	'ANS','R'+80H		;"set ans(wer)"
	DW	STANSR
;
	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	LXI	H,SHOTBL	;get table of SHOW subroutines
SETSLP:	MOV	E,M		;get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		;end of table?
	ORA	E
	RZ			;exit if so
	PUSH	H		;save table pointer
	XCHG			;adrs to HL
	CALL	GOHL		;do it
	CALL	CRLF		;print newline
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
; table of SHOW subroutines
;
SHOTBL:	DW	CARSHOW
	DW	BDSHOW
	DW	SPKSHOW
	DW	ANSHOW
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	CALL 	CLS			;clear screen
	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET Commands, Smartmodem version:',CR,LF
	DB	CR,LF,'SET BAUD 300 <or> 1200'
	DB	CR,LF,'SET SPKR ON <or> OFF'
	DB	CR,LF,'SET ANSR ON <or> OFF'
	DB	CR,LF,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX	
	JC	SETERR		;invalid code
	CALL	PBAUD		;try to set it
	JC	SETERR		;unsupported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
;............
;
;	SET SPEAKER  processor
;............
STSPKR:	LXI	D,SPKTBL		;look for valid input
	CALL 	TSRCH			
	JC	SETERR			;error if not valid
	MOV	A,L			;looks good, move it
	STA 	SPKST
	CPI	YES			;speaker on or off?
	JZ	SPKON			;wants it on-skip to speaker on
	LXI 	H,SPOFMSG		;wants it off-load msg and send
	CALL	SMSEND			;...to modem
	JMP	SPKSHOW			;show the reset on screen
SPKON:	LXI	H,SPONMSG		;wants it on-load msg and send
	CALL	SMSEND			;...to modem
SPKSHOW: CALL	ILPRT			;display status msg- on or off
	DB	'Speaker is:',TAB,' ',0
	LDA 	SPKST
	CPI 	YES
	JZ	SPSHON
	CALL	ILPRT
	DB	'Off',0
	RET
SPSHON: CALL 	ILPRT
	DB	'On',0
	RET
;
SPKTBL:	DB	'O','N'+80H		;command table for speaker on or off,
	DB	YES,0			;also used for Answer on or off
	DB	'OF','F'+80H
	DB	NO,0
	DB	0
;
SPONMSG: DB	'ATM1',CR,0		;smodem msg for speaker on
SPOFMSG: DB	'ATM0',CR,0		;smodem msg for speaker off
;
;..........
;
;   SET AUTO ANSWER processor
;.........
STANSR:	LXI	D,SPKTBL		;same table used for STSPKR & STANSR
	CALL 	TSRCH			;tests for on or off
	JC	SETERR
	MOV	A,L
	STA 	ANST
	CPI	YES
	JZ	ANSON
	LXI 	H,ANOFMSG
	CALL	SMSEND
	JMP	ANSHOW
ANSON:	LXI	H,ANONMSG
	CALL	SMSEND
ANSHOW: CALL	ILPRT
	DB	'Auto-answer is:',TAB,' ',0
	LDA 	ANST
	CPI 	YES
	JZ	ANSHON
	CALL	ILPRT
	DB	'Off',CR,LF,0
	RET
ANSHON: CALL 	ILPRT
	DB	'On',CR,LF,0
	RET
;
ANONMSG: DB	'ATS0=1',CR,0
ANOFMSG: DB	'ATS0=0',CR,0
;
;.........
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
;------------------------------------------------------------
;
EOSMSG:		DB	1BH,59H,0,0,'$'	;clear to end of screen message
;
CLSMSG:		DB	1BH,2AH,0,0,'$'	;clear screen message
;
VERMSG:		DB	CR,LF,LF,LF,TAB,TAB,TAB,'Version for Apple ][',CR,LF
		DB	TAB,TAB,TAB,'    with '
;
			IF VERSA
		DB	'Versacard'
			ENDIF
;
			IF SSC
		DB	'Super Serial Card'
			ENDIF
;
			IF COMCARD
		DB	'Comcard'
			ENDIF
;
			IF CPS
		DB	'CPS card',CR,LF
			ENDIF
;
			IF CCS OR SSM
		DB	'Serial card'
			ENDIF
;
		DB	TAB,TAB,TAB,'HAYES Smart modem',CR,LF
		DB	TAB,TAB,'Overlay V. ',REV/10+'0','.'
		DB	REV MOD 10+'0',':',' By Norman Beeler'
		DB	CR,LF,LF,'$'
;----------------------
; NOTE: MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	END
