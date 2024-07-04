; MXO-HU11.ASM --  U.S. Robotics S-100 overlay for MEX11.COM adapted for
; V.86/07/27	   Heath/Zenith-100	    
;
; This overlay follows MEX coventions and is all you need to get MEX running.
; 
; Significant quantities of ideas and code for this program have been
; drawn from M7US-2.ASM, M712US.ASM and MXO-SM13.ASM and I am greatfully
; taking this opportunity to extend credit to the people involved in
; the development of these overlays.
;
; This version will assemble directly for a Z-100 using the S-100 bus 
; auto dial/auto answer modem by US Robotics.  The port switches on the
; modem board should be set to 20h 21h as follows:
;
;	DIP SWITCH SEGMENT(S6)		SLIDE SWITCH(J6)
;	   4	 3    2    1
;	  OFF	OFF   ON  OFF		      UP
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Heath/Zenith "100"
; equipment.  Much of the information contained here is not in the main
; file.
;
; This overlay is capable of setting the baud rate and sending breaks.
; Although disconnecting the modem is not supported by use of a function to
; lower DTR. However, the control-N and DSC commands still work, as they use
; "+++" which causes the U.S.R. S-100 modem to hang up. Some do-nothing time
; wasting statements have beeen added to the INITMODEM routine to slow the
; computer down for the modem. The regular U.S.R. S-100 modem initialization
; routine will not work reliably with computer clock speeds above 4 MHz.
;
; Baud rates supported are 150, 300, 600 and 1200. Note that 150 baud has 
; been included in place of 110 baud which is not supported by the U.S.R.
; S-100 modem. (The SET command when entered without argument will with
; 150 baud selected still indicate 110 baud unless MEX.COM is patched. For
; MEX114.COM this may be done by changing the contents of address 4FF8 from
; 31H to 35H.)
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD.COM to overlay the the results
;		of this program to the original .COM file:
;
;		MLOAD MEX11.COM=MEXHU.COM,MXO-HU11
; 
;		Refer to MEX10.INF, MEX10.DOC and updates for complete
;		instructions.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 86/07/86 - Code added to GOODBYE to warn user if	- Bo Gedda
;	     modem is still on line upon use of
;	     BYE, CPM and SYSTEM commands.
;	  
; 85/12/26 - Initialization changed to include reset of - Bo Gedda
;	     modem (RESETST and minor code added).
;
; 85/08/03 - Dial routine changed to allow conditional	- Bo Gedda
;	     assembly for Swedish pulse dialing which
;	     is different for some crazy reason.
;	     Set SWEPU true to allow this option, which
;	     differs as follows:
;	     
;		Number		International	Swedish  
;		of pulses	   #		   #
;		---------------------------------------
;		   1		   1		   0
;		   2		   2		   1
;		   3		   3		   2
;		   4		   4		   3
;		   5		   5		   4
;		   6		   6		   5
;		   7		   7		   6
;		   8		   8		   7
;		   9		   9		   8
;		  10		   0		   9
;
; 84/11/22 - Call in INITMOD modified to follow MEX	- Bo Gedda
;	     conventions. SMANAL modified to exclude
;	     busy and include error code. SMDIAL
;	     modified to add extra 2 second delay
;	     before dialing.
;
; 84/09/09 - Initialization modified to allow other	- Bo Gedda
;	     default baud rate then 300 baud
;
; 84/08/29 - First version of this file.		- Bo Gedda 
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Use the MEX "SET" command to change the baudrate when desired.  Default
; baud rate may be set to 150, 300, 600 or 1200 by modifying MSPEED below.
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
PRNTBL	EQU	237		;get MEX format command table pointer
PRID	EQU	236		;print MEX ID string on console
 
PRINT	EQU	9		;MEX/BDOS print-string function call
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
FALSE		EQU	0	
TRUE		EQU	NOT FALSE
;
; SYSTEM CONSTANTS
;
TPULSE	EQU	0105H		;TONE/PULSE FLAG IN MODEM OVERLAY
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165H		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
;
	ORG	DIALV		;OVERLAY THE DIALING VECTOR
	JMP	DIAL
;
	ORG	DISCV		;OVERLAY THE DISCONNECT VECTOR
	JMP	DISCON
;
;
; Change the following information to match your equipment
;
SWEPU		EQU	FALSE		;SET TRUE IF SWEDISH TYPE PULSE
;					 DIALING IS REQUIRED THIS FORCES
;					 PULSE DIALLING
PORT:		EQU	020H		;SET TO MATCH MODEM SWITCHES
MODCTL1:	EQU	PORT+1		;MODEM CONTROL PORT
MODDATP:	EQU	PORT		;MODEM DATA IN PORT
MODDATO:	EQU	PORT		;MODEM DATA OUT PORT
MODDCDB:	EQU	080H		;CARRIER DETECT BIT
MODDCDA:	EQU	080H		;VALUE WHEN ACTIVE
MODRCVB:	EQU	2		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	2		;VALUE WHEN READY
MODSNDB:	EQU	1		;BIT TO TEST FOR SEND
MODSNDR:	EQU	1		;VALUE WHEN READY
;
FRMER		EQU	20H		;FRAMING ERROR
ORUNER		EQU	10H		;OVERRUN ERROR
PARER		EQU	08H		;PARITY ERROR
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	45	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: 	DB	1	;0=150 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: 	DB	5	;0=0 delay 1=10 ms  5=50 ms  9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms  5=500 ms  9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
NORETRY 	DB	NO	;yes=DON'T ALLOW RETRY/QUIT OPTION      10DH
				;no=ALLOW RETRY/QUIT AFTER 10 TIMEOUTS
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: 	DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: 	DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: 	DB	0	;for future expansion			11EH
EXTRA2: 	DB	0	;for future expansion			11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H ;^N = Disconnect from the phone line	121H
LOGCHR: 	DB	'L'-40H ;^L = Send logon			122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer			123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H ;^Y = Open input text buffer		126H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7

maskr:		ani	2
		ret
testr:		cpi	2
		ret
masks:		ani	1
		ret
tests:		cpi	1
		ret
		ds	12

		DS	2		;				160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE 	;				168H
JMP$INITMOD:	JMP	INITMOD 	;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD 	;change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK 	;				180H
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
;	routine to clear to end of screen.
;
CLREOS: 	LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
SYSVER: 	MVI	C,ILP
		call	mex
		DB	'Version for Heath/ZDS 100 Series Computers'
		DB	CR,LF
		DB	'  with the U.S. Robotics S-100 modem.'
IF SWEPU
		DB	CR,LF
		DB	'Swedish type pulse dialing.'
ENDIF
		DB	CR,LF,0

		RET
;     
;.....
;
;
; The following routine sends a break "character" to the remote
; computer for 300 ms.	The "MSPEED" value is needed to decide whether
; the modem is at 150, 300, 600, or 1200 baud.	The routine must know
; this because U.S.R. set up the RTS bit of the command resgister as a
; baud rate selection bit.  Note that the "MVI A, 01FH" does not change
; any flags.
;
SENDBRK:	LDA	MSPEED		; Get speed byte
		CPI	1		; Are we at 150 baud?
		MVI	A, 01FH 	; Set up for 150/600 (no flag changes)
		JZ	SBRK2		; And if we are, go do that
		LDA	MSPEED		; Get speed byte
		CPI	3		; Are we at 600 baud?
		MVI	A, 01FH 	; Set up for 150/600
		JZ	SBRK2
		MVI	A, 03FH 	; Otherwise, set up for 300/1200
SBRK2:		OUT	MODCTL1 	; Send break
		MVI	B, 3		; 300 ms delay value
		MVI	C,TIMER
		CALL	MEX		; Wait that long
		JMP	INITMOD1	; Restore USRT
;.....
;
;
; The U.S.R. S-100 does not have a "quick-disconnect" feature like
; the Hayes does (by lowering DTR).  Therefore, "GOODBYE" is not
; implemented except to check if modem is connected. Control-N still
; works to hang up (see note above in introduction)
;
GOODBYE:	IN	MODCTL1 	;CHECK IF CARRIER
		ANI	MODDCDB
		RZ
		MVI	B,10		;WAIT 1 SECOND
		MVI	C,TIMER
		CALL	MEX
		IN	MODCTL1 	;CHECK IF STILL CARRIER  
		ANI	MODDCDB
		RZ
		CALL	DISCFAIL
		RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	This initialization
; sets up 300 baud, 8 data bits, 1 stop bit, no parity.  Due to a
; quirk in the U.S.R. S-100 (it seems to have plenty of 'em), after
; you change baud rates, you should send an "AT" followed by a
; carriage return.  Therefore, this is done after every initialization
; when there is no carrier present.
;
;
; NOTE: The U.S.R. S-100 does not operate too well at clock speeds   
;	over 4 MHz.  As we are running at that speed or higher, the
;	lines with XCHG have been inserted.  These serve as time wasting
;	routines to let the U.S.R. S-100 catch up.  This is not a
;	problem when doing character I/O, as the program checks to see
;	if the modem is ready to accept a character.
;
;
INITMOD:	LDA	MSPEED		; Get the default baude rate
		CPI	0		; Is it 150 baud?
		JZ	OK150		; If so set up for 150 baud
		CPI	1		; Is it 300 baud?
		JZ	OK300		; If so set up for 300 baud
		CPI	3		; Is it 600 baud?
		JZ	OK600
		CPI	5		; Is it 1200 baud?
		JZ	OK1200
		MVI	C,ILP
		CALL	MEX		; Tell user if not valid
		DB	'++ Incorrect default baud rate ++',CR,LF,BELL,0
INITMOD1:	XRA	A		; Zero accumulator
		OUT	MODCTL1 	; Clear 8251A
		XCHG			; For fast systems
		XCHG			; For fast systems
		OUT	MODCTL1 	; Twice
		XCHG			; For fast systems
		XCHG			; For fast systems
		OUT	MODCTL1 	; Three times, even
		XCHG			; For fast systems
		XCHG			; For fast systems
		MVI	A, 040H 	; Reset UART command
		OUT	MODCTL1
		XCHG			; For fast systems
		XCHG			; For fast systems
MODEBT: 	MVI	A, 04FH 	; 8 bits, 1 stop, no parity
		OUT	MODCTL1
		XCHG			; For fast systems
		XCHG			; For fast systems
CMDBT:		MVI	A, 037H 	; On hook, Tx/Rx enable, reset errs
		OUT	MODCTL1
		XCHG			; For fast systems
		XCHG			; For fast systems
BDCODE: 	MVI	A, 1		; 300 baud code
		STA	MSPEED
		IN	MODCTL1 	; Get the current status
		ANI	MODDCDB 	; See if there is a carrier
		RNZ			; If so, don't do AT stuff
		MVI	B, 1		; 100 ms
		MVI	C,TIMER
		CALL	MEX		; Wait that long 
		LXI	H,RESETST	; Point to resetstring
		CALL	SMSEND		; Reset modem
		MVI	B, 5		; 500 ms
		MVI	C,TIMER
		CALL	MEX		; Wait that long
		LXI	H,INITST	; Point to initstring
		CALL	SMSEND		; Initialize command status
		RET
;
RESETST:DB	'ATZ',CR,0		; Reset modem command status
INITST: DB	'ATS0=0S7=45E1',CR,0	; Don't answer, wait 45 s for carrier
;
; This routine is used to set up for a new baud rate
; which on the U.S.R. can be 150, 300, 600, or 1200.
; This modem does not have a provision for the MEX   
; 110 rate and the U.S.R. 150 baud possibility is
; therefore utilized. You should not exepect 150 baud
; to work unless modems at both ends are set up for
; this same baud rate.
;
;
SETUPR:   MVI	C,SBLANK	;Any arguments?
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
	  DB	CR,LF,'Only 150, 300, 600 or 1200 allowed by SET',CR,LF,0
	  RET
;
CMDTBL:   DB	'15','0'+80H
	  DW	OK150
	  DB	'30','0'+80H
	  DW	OK300
	  DB	'60','0'+80H
	  DW	OK600
	  DB	'120','0'+80H
	  DW	OK1200
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
OK150:	MVI	A,0		;MSPEED 150
	LHLD	BD150		;Get 150 baud values in (HL)
	JMP	LOADBD		;Go load them
OK300:	MVI	A,1		;MSPEED 300
	LHLD	BD300		;Get 300 baud values in (HL)
	JMP	LOADBD		;Go load them
OK600:	MVI	A,3		;MSPEED 600
	LHLD	BD600		;Get 600 baud values in (HL)
	JMP	LOADBD		;Go load them
OK1200: MVI	A,5		;MSPEED 1200
	LHLD	BD1200		;Get 1200 baud values in (HL)
	JMP	LOADBD		;Go load them
;
LOADBD: 	STA	BDCODE + 1	; Change baud rate code value
		MOV	A,L		; Get mode byte value
		STA	MODEBT + 1	; Change mode byte
		MOV	A,H		; Get cmd byte
		STA	CMDBT + 1	; Change cmd byte
		JMP	INITMOD1	; (Re)initialize modem
;
NEWBAUD:  CPI	0
	  JZ	OK150
	  CPI	1
	  JZ	OK300
	  CPI	3
	  JZ	OK600
	  CPI	5
	  JZ	OK1200
	  RET
;
; Baud Rate Table
;
BD150	DW	274FH		;150 baud
BD300	DW	374FH		;300 baud
BD600	DW	274EH		;600 baud
BD1200	DW	374EH		;1200 baud
;		__--
;		 \  \___ Mode Byte to select baud rate (4E or 4F)
;		  \_____ Command Byte to select speed (27 or 37)
;
BAUDBUF:	DB	10, 0
		DS	10
;
;
;
;
EOSMSG:   DB	ESC,'J',0,0,0,'$'			
CLSMSG:   DB	ESC,'E',0,0,0,'$'
;
;
;
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).	Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the Smartmodem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  Except as noted below, MEX will make no
; assumptions about the digits, and will send each to the DIAL routine
; un-inspected (some modems, like the Smartmodem, allow special
; non-numeric characters in the  phone number, and MEX may make
; no assumptions about these).
;
; If SWEPU is set true MEX will modify numbers (0 to 9) to correct
; the number of pulses sent to the telephone switching equipment.
; Note that letters will not be modified and and should not be used
; with this special type of pulse dialing.
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this condition)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;	5 - No ring
;	6 - No dialtone
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
;
DIAL:	LHLD	DIALPT		;FETCH POINTER
	CPI	254		;START DIAL?
	JZ	STDIAL		;JUMP IF SO
	CPI	255		;END DIAL?
	JZ	ENDIAL		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
IF	SWEPU
	CALL	CKDIG
NOMOD:	MOV	M,A		;PUT CHAR IN BUFFER
	INX	H		;ADVANCE POINTER
	SHLD	DIALPT		;STUFF PNTR
	RET			;ALL DONE
CKDIG:	CPI	'9' + 1 	;0 TO 9 IS THE RANGE TO ADJUST
	RNC			;TOO LARGE
	MOV	C,A		;SAVE THE NUMBER
	SUI	'0'			   
	MOV	A,C		;RECOVER IT	   
	RC			;TOO SMALL 
	CPI	'9'		;9 CORRESPONDS TO ZERO
	JZ	ZERO
	ADI	1		;ADD ONE PULSE TO ALL FROM 0 TO 8
	RET
ZERO:	MVI	A,'0'
	RET
ENDIF
;
IF NOT SWEPU
	MOV	M,A		;PUT CHAR IN BUFFER
	INX	H		;ADVANCE POINTER
	SHLD	DIALPT		;STUFF PNTR
	RET			;ALL DONE
ENDIF
;
; Here on a start-dial sequence
;
STDIAL: LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
IF SWEPU
	MVI	A,'P'		;FORCE PULSE DIALING
	STA	TPULSE
ENDIF
	RET
;
; Here on an end-dial sequence
;
ENDIAL: MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY TERMINATOR
	MVI	M,0
	LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
	STA	SMDIAL+3	;PUT INTO STRING
	LXI	H,SMDIAL	;POINT TO DIALING STRING
	CALL	SMSEND		;SEND IT
WAITSM: MVI	C,INMDM
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 75 SECONDS. YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
; NOTE THAT THE SMARTMODEM HAS AN INTERNAL 30 SECOND TIMEOUT WHILE
; FOR A CARRIER ON THE OTHER END.  YOU CAN CHANGE BY PLAYING WITH THE
; S7 VARIABLE (I.E. SEND THE SMARTMODEM "AT S7=20" TO LOWER THE 30 SECOND
; WAIT TO 20 SECONDS).
;
RESULT: MVI	C,75		;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	JNC	SMTEST		;JUMP IF MODEM HAD A CHAR
	PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	SMNEXT		;IF NOT, JUMP
	MVI	B,CR		;YES, SHUT DOWN THE MODEM
	MVI	C,SNDCHR
	CALL	MEX
	MVI	A,3		;RETURN ABORT CODE
	RET
SMNEXT: DCR	C		;NO
	JNZ	SMWLP		;CONTINUE
;
; 75 SECONDS WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO: MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST: ANI	7FH		;IGNORE ANY PARITY
	CALL	SMANAL		;TEST THE RESULT
	MOV	A,B		;A=RESULT (CY SIGNIFICANT HERE TOO)
	PUSH	PSW		;SAVE IT
SMTLP:	MVI	C,INMDM 	;FLUSH ANY REMAINING COMMAND LINE
	CALL	MEX
	JC	SMCHEK		;JUMP IF NO INPUT
	CPI	LF		;GOT SOME ... WAITING FOR EOL
	JNZ	SMTLP		;EAT ANY IN-BETWEEN
SMCHEK: POP	PSW		;A HAS MEX RETURN-CODE, CY=1 IF UNKNOWN
	JC	RESULT		;IF RESULT UNKNOWN, IGNORE IT
	RET
;
SMANAL: MVI	B,0		;PREP CONNECT CODE
	CPI	'C'		;"CONNECT"?
	RZ

	MVI	B,2		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO CONNECT
	RZ

	MVI	B,4		;PREP ERROR MSG B=4
	CPI	'E'		;E=ERROR
	RZ

	STC			;UNKNOWN...
	RET
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING SMARTMODEM
; CODES. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; RESULT IS RETURNED TO USER.  
;
;
DISCON: MVI	B,10
	MVI	C,TIMER 	;WAIT 1 SECONDS
	CALL	MEX
	LXI	H,SMATN 	;SEND '+++'
	CALL	SMSEND
	MVI	B,30		;WAIT 3 MORE SECONDS
	MVI	C,TIMER
	CALL	MEX
	IN	MODCTL1 	;CHECK IF CARRIER
	ANI	MODDCDB
	JZ	DISCOK
	MVI	B,30		;WAIT ANOTHER 3 SECONDS
	MVI	C,TIMER
	CALL	MEX
	IN	MODCTL1 	;CHECK IF STILL CARRIER  
	ANI	MODDCDB
	JNZ	DISCFAIL	;IF STILL CARRIER TELL USER
DISCOK: MVI	C,ILP
	CALL	MEX
	DB	CR,LF,'++DISCONNECTED++',CR,LF,0
	RET
DISCFAIL:
	MVI	C,ILP
	CALL	MEX
	DB	CR,LF,'+++ WARNING !!!   NOT DISCONNECTED +++',CR,LF,0
	RET

;
SMATN:	DB	'+++',0
;
; SMARTMODEM UTILITY ROUTINE: SEND STRING TO MODEM
;
SMSEND: MVI	C,SNDRDY	;WAIT FOR MODEM READY
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
; DATA AREA
;
SMDIAL: DB	'ATDT, '
DIALBF: DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT: DS	2		;DIAL POSITION POINTER
;
	END
