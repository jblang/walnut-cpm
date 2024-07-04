;======================================================================
; MXH-VI10.ASM -- Visual 1050 overlay for MexPlus
;======================================================================
;
REV	EQU	10	; Version 1.0
; From MXO-VI10-ASM 2/18/86  Michael Conley
; From M7VI-2.ASM  12/02/85  Wilson Bent [WHB]
; Last update  03/10/85  Jim Offenbecher
; Last update  03/01/84  Steve Sanders
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.  See comments at
; the label INITMOD1: to change this to 300 baud default start-up if desired.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Revisions/changes:
;
; 02/18/86 - Modified for MexPlus use - Michael Conley
;		 MexPlus changes are marked with ##
;
; 12/02/85 - Modified from M7VI-2.ASM (for MDM740.COM)
;						- Wilson Bent
;
; 11/06/85 - Use BDOS calls for interrupt-	 - Charlie Fenton
;	     driven modem I/O to eliminate need
;	     for nulls after CR in term mode.
;
; 03/10/85 - Combined m7kp-2 and m7sy-3 for visual 1050 -
;						- Jim Offenbecher
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
;
PORT:		EQU	8CH		;Visual 1050 serial output port
MODCTL1:	EQU	PORT+1		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem control port
MODRCVB:	EQU	02H		;Your bit to test for receive
MODRCVR:	EQU	02H		;Your value when receive ready
MODSNDB:	EQU	01H		;Your bit to test for send
MODSNDR:	EQU	01H		;Your value when send ready
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
		ORG	100H
;
		DB	0C3H	; ## JMP INSTRUCTION MexPlus
		DS	2	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	1	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	1	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
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
XOFFTST:	DB	YES	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCXNNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon ** NOT USED **		122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
		DS	2		;				128H
;
IN$MODCTL1:	RET			;Control port input not used.	12AH
		DS	9
;
OUT$MODDATP:	JMP	BDOS4		;out modem data port		134H
		DS	7
IN$MODDATP:	JMP	BDOS3		;in modem data port		13EH
		DS	7
ANI$MODRCVB:	RET ! NOP ! NOP		;BDOS7 tests receive ready	148H
CPI$MODRCVR:	JMP	BDOS7		;instead of IN,ANI,CPI sequence	14BH
ANI$MODSNDB:	RET ! NOP ! NOP		;BDOS8 tests send ready	instead	14EH
CPI$MODSNDR:	JMP	BDOS8		;of IN, ANI, CPI sequence.	151H
;
; ## the following are two new MexPlus added vectors.  DCDTEST
; returns a 0 for no carrier, 0FFH for carrier, and 0FEH if unknown
; while RNGDET returns similar results for ring-detect
;
DCDTEST:	JMP	DCDVEC		; ## data carrier		154H
RNGDET:		JMP	RNGVEC		; ## ring detect		157H
;
		DB	0,0,0,0,0	; reserved space / assume 0	15AH
SMDISC:		DS	3		; SmartModem disc / not here	15FH
DIALV:		DS	3		; Dial vector / not here	162H
DISCV:		JMP	DISCON		; Hardware disconnect		165H
JMP$GOODBYE:	JMP	GOODBYE		; Reset port 			168H
JMP$INITMOD:	JMP	INITMOD		; go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		; Change baudrate		16EH 
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;(Not used by MEX)		17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
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
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.
;
CLREOS:		LXI	D,EOSMSG	;				195H
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG	;				19EH
		MVI	C,PRINT
		CALL	MEX
		RET			
;
; end of fixed area - from here to 1FFFh is reserved
;
		ORG	200H		; ## new boundary for MexPlus	200H
SYSVER:		MVI	C,ILP		;				
		CALL	MEX
		DB	'Version for Visual 1050 (version '
		DB	REV/10+'0'
		DB	'.'
		DB	REV MOD 10+'0'
		DB	')'
		DB	CR,LF,0
		RET
;.....
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,1FH		;SEND BREAK TONE
	  JMP	GOODBYE1
;...
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
DISCON:				;use same routine as goodbye
GOODBYE:  MVI	A,15H		;SEND BREAK, TURN OFF DTR
;
GOODBYE1: CALL	SETMCTL		;SEND TO STATUS PORT
	  MVI	B,3		;WAIT 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,07H		;NORMAL SEND/RECEIVE WITH DTR
	  CALL	SETMCTL		;SEND TO STATUS PORT
	  RET
; ## Mexplus carrier and ring detect service calls -- for both we
; return 'we don't know' result so program ignores.
DCDVEC:
RNGVEC:
	  MVI	A,0FEH
	  RET


;.....
;
;(Taken from...)
; Sanyo initialization -- sets the 8251A for 8 bits, 1 stop pulse,
; DTR high, requires jumper to be set internally to 1200 baud then
; divides by 64 for 300, or by 16 for 1200 baud via "SET" command.  Set
; at present to default to 1200 baud.
;
INITMOD:  MVI	A,5		;TRANSFER TIME FOR 1200 BAUD
	  STA	MSPEED	
	  MVI	A,3FH		;GET BYTE TO ENABLE INTERRUPTS
	  OUT	9DH		;ENABLE THEM...
;
; The Visual 1050 provides a special function which returns the
; address of the byte where the BIOS keeps the current value of
; the modem control register.  We must modify this byte whenever
; we change the value of this register, or the BIOS will clobber
; it whenever it gets an interrupt from the modem port.
;
	  LXI	D,BIOSPB	;Parameter block for BIOS call.
	  MVI	C,50		;BDOS function for direct BIOS call.
	  CALL	5
	  SHLD	RSPAR		;Save the returned address
;
	  MVI	A,087H		;INSURE OUT OF MODE
	  OUT	MODCTL1		;MODEM STATUS PORT
	  OUT	MODCTL1		;SLIGHT EXTRA DELAY
	  MVI	A,40H		;INITIALIZE USART
	  OUT	MODCTL1		;MODEM STATUS PORT
;
INITMOD1: MVI	A,4EH		;DEFAULT TO DIVIDE BY 16 FOR 1200 BAUD
				;CHANGE TO 4FH TO DIVIDE BY 64 FOR 300 BAUD
	  OUT	MODCTL1		;MODEM STATUS PORT (MODE WORD)
	  MVI	A,17H		;DTR, RCV, XMT, ERROR RESET
	  CALL	SETMCTL		;MODEM STATUS PORT
; now set the baud rate with 2 bits from the table
	  IN	92H		;GET WHAT WAS THERE
	  ANI	0F3H		;CLEAR OUT THE OLD BAUD RATES
INITMOD3: ORI	0		;SET NEW DEFAULT TO 1200
	  OUT	92H		;NEW BAUD RATE NOW SET
	  RET
;
BIOSPB:	  DB	30,3
;.....
;
; Sets the modem speed via the SET command.
;   - Major MEX Mods here [WHB]
;
SETUPR:	  MVI	C,SBLANK	;Any arguments?
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
	  DB	CR,LF,'Valid baud rates are: '
	  DB	'300, 600, 1200, 2400, 4800, 9600, 19200 only!'
	  DB	CR,LF,0
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
	  DB	'480','0'+80H
	  DW	OK4800
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	'1920','0'+80H
	  DW	OK19200
	  DB	0
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Baud rate is: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
OK19200:  MVI	A,9
	  LHLD	BD19200
;
LOADBD:	  STA	INITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	INITMOD3+1	;SEND TO 'CTC' FOR NEW BAUDRATE
	  MOV	A,H
	  STA	INITMOD1+1
	  JMP	INITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  DW	04F00H
BD600:	  DW	04F04H
BD1200:	  DW	04E00H
BD2400:	  DW	04E04H
BD4800:   DW	04F08H
BD9600:	  DW	04E0CH
BD19200:  DW	04E08H
;
BAUDBUF:  DB	10,0
	  DS	10
;
; The following routines replace direct modem port I/O with BDOS calls.
; The Visual 1050 BIOS uses interrupt-driven I/O with ring buffers.
; This solves the problem of losing modem input while the console
; display does a carriage return.
;
; Check for input character (receive ready).
BDOS7:	PUSH	B	;Save the registers
	MVI	C,7	;BDOS function number
	JMP	BDOS78	;Common routine for BDOS 7 & 8.
;
; Check for output character (send ready).
BDOS8:	PUSH	B	;Save the registers
	MVI	C,8	;BDOS function number
BDOS78:	PUSH	D
	PUSH	H
	CALL	5
	POP	H	;Restore the registers
	POP	D
	POP	B
	ORA	A	;BDOS returns A=0 if NOT ready.
	JZ	CLRZ	;Return Z flag OFF if not ready.
	XRA	A	;Set Z flag if ready.
	RET
CLRZ:	INR	A	;Clear Z flag (make A non-zero).
	RET
;
; Input a character from modem via BIOS ring buffer.
BDOS3:	PUSH	B	;Save the registers
	PUSH	D
	PUSH	H
	MVI	C,3	;BDOS function number
	CALL	5
	POP	H	;Restore the registers
	POP	D
	POP	B
	RET		;Input character is in A
;
; Ouput a character to modem via BIOS ring buffer.
BDOS4:	PUSH	B	;Save the registers
	PUSH	D
	PUSH	H
	MVI	C,4	;BDOS function number
	MOV	E,A	;Character to output must be in E
	CALL	5
	POP	H	;Restore the registers
	POP	D
	POP	B
	RET
;
; The Visual 1050 BIOS keeps the current value of the modem control
; register in a special byte.  We must modify this byte whenever
; we change the value of this register, or the BIOS will clobber
; it whenever it gets an interrupt from the modem port.
SETMCTL: PUSH	H
	 LHLD	RSPAR	;Address of BIOS byte
	 MOV	M,A	;Save new value there
	 OUT	MODCTL1	;Output to modem control register
	 POP	H
	 RET
;
RSPAR:	 DS	2	;Address of BIOS copy of modem control register
;
; Newbaud - most popular only for now
;   Not in M7VI-2.ASM - Why? [WHB]
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  cpi	3
	  jz	OK600
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  cpi	7
	  jz	OK4800
	  CPI	8
	  JZ	OK9600
	  cpi	9
	  jz	OK19200
	  RET
;
; Visual 1050 Clear Sequences: to End Of Screen and Entire Screen
;
EOSMSG:	  DB	1Bh,5Bh,4Ah,'$'		  	
CLSMSG:	  DB	0Ch,'$'
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
LSMSG:	  DB	0Ch,'$'
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmod