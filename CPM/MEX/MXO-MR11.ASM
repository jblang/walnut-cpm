; MXO-MR11.ASM -- MEX Port Overlay file for the Morrow Descision 11  03-OCT-85
;-----------------------------------------------------------------------------;
; This overlay adapts the MEX modem program for the Morrow Micro  Decision 11.
; This MEX Port overlay digresses from pure by encompassing a Hayes Smartmodem
; feature in  the SET command.  If this offends you in anyway,  set the SMODEM
; flag to "NO" to eliminate.
;
; The SET command used in this overlay will allow the setting of the baud rate
; (speed) of the modem hardware port. As mentioned, the Smartmodem speaker is
; setable by the user  to one of three setting: OFF: such that  the speaker is
; always off, HALF: such that the  speaker is on during the  dialing sequence,
; but turns off when the carrier is detected,  and FULL: the speaker stays  on
; when carrier detected. This is useful when one doesn't wish the stereo to be
; drowned out by the Smartmodem dialing.
;
; A more  detailed description of the calling conventions used by this overlay
; overlay can be found in the PMMI modem overlay (MXO-PMxx.ASM where the  "xx"
; is the current version number).
;-----------------------------------------------------------------------------;
; History as a MEX overlay
;
; 10/02/85 - Stolen from MXO-SZ20.ASM                 (V1.1)	- Stuart Rose
;
;-----------------------------------------------------------------------------;
;
OVERSION	equ	1	; overlay version number
OREVISION	equ	1	; overlay revision level
;
;=============================================================================;
; CP/M system addresses							      ;
;=============================================================================;
;
WBOOT		equ	0000H	; address of warm boot jump vector
TPA		equ	0100H	; address of transient program area
;
;=============================================================================;
; MEX system bytes. This overlay helps MEX remember the baud rate of the      ;
; modem port and speaker volume of the Smartmodem when hopping in and out of  ;
; MEX **DURING THE SAME CALL**. These values are used instead of the overlay  ;
; defaults (MSPEED and VOLUME respectively) when a call-in-progress is de-    ;
; tected on MEX startup. Then these values are used. To protect them, they    ;
; live in the system page (0000H-00FFH), in a location not used by the OS     ;
; (operating system). Generally 0040H-004FH is reserved for CBIOSes and is    ;
; fine for uses, as long as your CBIOS doesn't use it. If you are really un-  ;
; sure, set both values to 0000H, and this feature will be eliminated.	      ;
;=============================================================================;
;
MEXBAUD		equ	004FH	; address of system byte for MEX baud rate
MEXSPKR		equ	004EH	; address of system byte for MEX speaker volume
;
;=============================================================================;
; MEX service processor address and functions				      ;
;=============================================================================;
;
MEX		equ	0D00H	; address of the MEX service processor
INMDM		equ	255	; A = char from modem,CARRY = no char in 100 ms
TIMER		equ	254	; delay B, in 100 ms units
TMDINP		equ	253	; wait B seconds for char, CARRY = no char
CHEKCC		equ	252	; check for ^C from keyboard, ZERO = present
SNDRDY		equ	251	; test for modem-send ready
RCVRDY		equ	250	; test for modem-receive ready
SNDCHR		equ	249	; send a character to the modem (after sndrdy)
RCVCHR		equ	248	; receive a character from modem (after rcvrdy)
LOOKUP		equ	247	; table search: see CMDTBL comments for info
PARSFN		equ	246	; parse filename from input stream
PARSBD		equ	245	; parse baud-rate from input stream
SBLANK		equ	244	; scan input stream to next non-blank
EVALA		equ	243	; evaluate numeric from input stream
LKAHED		equ	242	; get next char w/o removing from input stream
GNC		equ	241	; get next char from input stream, CARRY = none
ILP		equ	240	; inline print
DECOUT		equ	239	; decimal output
PRBAUD		equ	238	; print baud rate
PRNTBL		equ	237	; print command table CARRY SET for ^C abort
PRID		equ	236	; print current MEX ID string on console
PRINT		equ	9	; BDOS/MEX print-string function call
CONOUT		equ	2	; BDOS/MEX output a character to console call
;
;=============================================================================;
; Define new MEX modes (granted in MEX V1.10 and up)			      ;
;=============================================================================;
;
CMDMOD	equ	0		; 00 - MEX is in command mode
TRMMOD	equ	1		; 01 - MEX is in terminal mode
SNDMOD	equ	2		; 02 - SENDOUT active
KEYMOD	equ	3		; 03 - Keystring being transmitted
XMDMSND	equ	4		; 04 - File transfer: Christensen-protocol send
XMDMRCV	equ	5		; 05 - File transfer: Christensen-protocol rcv
CISSND	equ	6		; 06 - File transfer: CIS-protocol send
CISRCV	equ	7		; 07 - File transfer: CIS-protocol receive
;
;=============================================================================;
; define some ASCII control characters					      ;
;=============================================================================;
;
NULL		equ	'@'-'@'	; (^@) null
BELL		equ	'G'-'@'	; (^G) bell
TAB		equ	'I'-'@'	; (^I) tab
CR		equ	'M'-'@'	; (^M) carriage return
LF		equ	'J'-'@'	; (^J) line feed
ESC		equ	'['-'@'	; (^[) escape
CTRL$Z		equ	'Z'-'@'	; (^Z) control Z
DEL		equ	7FH	; delete
EOS		equ	DEL	; SNDLIN end-of-string character
;
;=============================================================================;
; define some boolean variables						      ;
;=============================================================================;
;
YES		equ	0ffH	; affirmative response
NO		equ	000H	; negative response
TRUE		equ	YES	; true (affirmative) response
FALSE		equ	NO	; false (negative) response
;
;=============================================================================;
; MEX dial subroutine return error codes				      ;
;=============================================================================;
;
CARRIER		equ	0	; CARRIER DETECTED return code
BUSY		equ	1	; FAR END BUSY return code
NOANSWER	equ	2	; NO ANSWER return code
ABORT		equ	3	; KEYBOARD ABORT return code
ERROR		equ	4	; MODEM ERROR return code
NORING		equ	5	; NO RING return code
NODIALTONE	equ	6	; NO DIAL TONE return code

;=============================================================================;
; MEX system page parameters (are correct for MEX V1.1x)		      ;
; see MEXPATxx for current values.					      ;
;=============================================================================;
;
PROMPT		equ	MEX+13H	; addr of address of id prompt
CANCHR		equ	MEX+1CH	; addr of cancel character
ERRID		equ	MEX+2EH	; addr of error id flag (0 = no id in err msg)
;
;=============================================================================;
; miscellaneous equates							      ;
;=============================================================================;
;
OFF		equ	'0'	; Smartmodem code for speaker always off
HALF		equ	'1'	; Smartmodem code for speaker on until CD
FULL		equ	'2'	; Smartmodem code for speaker always on
;
;=============================================================================;
; MEX format baud rates							      ;
;=============================================================================;
;
MEX110		equ	0	; MEX baud rate of 110
MEX300		equ	1	; MEX baud rate of 300
MEX450		equ	2	; MEX baud rate of 450
MEX600		equ	3	; MEX baud rate of 600
MEX710		equ	4	; MEX baud rate of 710
MEX1200		equ	5	; MEX baud rate of 1200
MEX2400		equ	6	; MEX baud rate of 2400
MEX4800		equ	7	; MEX baud rate of 4800
MEX9600		equ	8	; MEX baud rate of 9600
MEX19200	equ	9	; MEX baud rate of 19200
;
;=============================================================================;
; Baud rate parameters for Morrow Descision 11 Zilog DART		      ;
;=============================================================================;
;
BD300		equ	0C4H	; 300 baud
BD600		equ	084H	; 600 baud
BD1200		equ	044H	; 1200 baud
BD19200		equ	004H	; 19200 baud
;
;=============================================================================;
; Morrow Descision 11 base port for modem serial port			      ;
;=============================================================================;
; 
BASE		equ	062H	; base port of modem port for MD-11
;
;=============================================================================;
; Morrow initialization values for modem port baud rate, and the Hayes        ;
; Smartmodem speaker volume (the last two values take on values stored in     ;
; the MEX scratch area of the system parameter page when re-entering MEX      ;
; with a call-in-progress).						      ;
;=============================================================================;
;
MD$BAUD		equ	MEX1200	; initial baud rate (speed) for Morrow modem
MD$SPKR		equ	OFF	; initial speaker volume, speaker always off
;
;=============================================================================;
; Port offsets (from BASE)						      ;
;=============================================================================;
;
DPORT		equ	0	; data port
SPORT		equ	1	; status port
CPORT		equ	1	; control port
;
;=============================================================================;
; UAR/T status bits (for Zilog and Plymouth DART)			      ;
;=============================================================================;
;
TBMT		equ	04H	; transmit buffer empty
DAV		equ	01H	; data available
DCDLIN		equ	08H	; carrier detect (use DCD line itself)
;DCDLIN		equ	20H	; carrier detect (use CTS line)
;
;=============================================================================;
;  Overlay starts here							      ;
;=============================================================================;
;
	org	TPA
;
;=============================================================================;
; MDM7xx/MEX parameter page						      ;
;=============================================================================;
;
JMPMEX:	DS	3		;(for "jmp START" instruction)		100H
PMODEM:	DB	NO		;yes=PMMI S-100 Modem			103H
SMODEM:	DB	YES		;yes=HAYES Smartmodem, no=non-PMMI	104H
TPULSE:	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	40		;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	MD$BAUD		;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	0		;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:	DB	0		;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:	DB	5		;number of DIR columns shown		10AH
SETFLG:	DB	YES		;yes=user-added Setup routine		10BH
SCRTST:	DB	YES		;Cursor control routine 		10CH
ACKNAK: DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG:	DB	NO		;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES		;yes=default to CRC checking		10FH
TOGCRC:	DB	YES		;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		;yes=convert backspace to rub		111H
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR	114H
LOGOK:	DB	NO		;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP		116H
LOCXCHR:DB	NO		;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGEXC:	DB	YES		;yes=allow toggling of EXTCHR		118H
LSTTST:	DB	YES		;yes=printer available on printer port	119H
XOFTST:	DB	YES		;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:	DB	YES		;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	NO		;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		;for future expansion			11EH
;
;=============================================================================;
; Terminal mode escape character (for MDM7xx only)			      ;
;=============================================================================;
;
EXITCHR DB	'E'-'@'		; ^E = Exit to main menu		11FH
BRKCHR	DB	'@'-'@'		; ^@ = Send 300 ms. break tone		120H
NOCONN	DB	'N'-'@'		; ^N = Disconnect from the phone line	121H
LOGCHR	DB	'L'-'@'		; ^L = Send logon			122H
LSTCHR	DB	'P'-'@'		; ^P = Toggle printer			123H
UNSAVE	DB	'Z'-'@'		; ^Z = Close input text buffer		124H
TRNCHR	DB	'T'-'@'		; ^T = Transmit file to remote		125H
SAVCHR	DB	'A'-'@'		; ^A = Open input text buffer		126H
EXTCHR	DB	'\'-'@'		; ^\ = Send next character		127H
;
;=============================================================================;
; Overlay parameter page (unused by MEX)				      ;
;=============================================================================;
;
	ds	2		;
;
;=============================================================================;
; Modem I/O routines							      ;
;=============================================================================;
;
MDMSTAT:JMP	INPSP		; get modem status			12AH
	DS	7
;
MDMOUT:	JMP	OUTDP		; output a character to the modem	134H
	DS	7
;
MDMIN:	JMP	INPDP		; input a character from the modem	13EH
	DS	7
;
;=============================================================================;
; Modem status register send/receive bit test routines			      ;
;=============================================================================;
;
MASKR:	ANI	DAV	! RET	; bit to test for receive ready		148H
TESTR:	CPI	DAV	! RET	; value of receive bit when ready	14BH
MASKS:	ANI	TBMT	! RET	; bit to test for send ready		14EH
TESTS:	CPI	TBMT	! RET	; value of send bit when ready		151H
	DS	14		;					154H
;
;=============================================================================;
; MEX subroutine jump table						      ;
;=============================================================================;
;
DIALV:	ds	3		; Smartmodem dial a number		162H
DISCV:	jmp	DISCON		; disconnect from target system		165H
GOODBV:	jmp	GOODBYE		; MEX un-initialization subroutine	168H
INMODV:	jmp	HELLO		; MEX initialization subroutine		16BH
NEWBDV:	jmp	BAUD		; new baud rate subroutine		16EH
NOPARV:	RET ! NOP ! NOP		; no parity subroutine			171H
PARITV:	RET ! NOP ! NOP		; new parity subroutine			174H
SETUPV:	jmp	SETCMD		; Spider/Z SET command subroutine	177H
SMENUV:	DS	3		; not used by MEX			17AH
VERSNV:	jmp	OVRVER		; display overlay version subroutine	17DH
BREAKV:	jmp	SBREAK		; send a break tone subroutine		180H
ILPRTV:	DS	3		; inline print	    (gone by MEX V2.0)	183H
INBUFV:	DS	3		; input buffer	    (gone by MEX V2.0)	186H
ILCMPV:	DS	3		; line compare	    (gone by MEX V2.0)	189H
INMDMV:	DS	3		; timed modem input (gone by MEX V2.0)	18CH
NXTSNV:	DS	3		; next screen	    (gone by MEX V2.0)	18FH
TIMERV:	DS	3		; timer routine	    (gone by MEX V2.0)	192H
;
;=============================================================================;
; CLREOS subroutine							      ;
; This subroutine will clear the console screen from the current cursor	      ;
; position, to the end of the console screen (insure that SCRTST (010AH)      ;
; is set to YES if you wish to use this subroutine).			      ;
;=============================================================================;
;
CLREOS:	lxi	D,CLRE		; clear to end-of-screen		195H
	mvi	C,PRINT		;
	call	MEX		;
	ret			;
;
;=============================================================================;
; CLRSCN subroutine							      ;
; This subroutine will clear the console screen (insure that SCRTST (010AH)   ;
; is set to YES if you wish to use this subroutine).			      ;
;=============================================================================;
;
CLRSCN:	lxi	D,CLRS		; clear screen				19EH
	mvi	C,PRINT		;
	call	MEX		;
	ret			;
;
;=============================================================================;
; BOLD subroutine							      ;
; This subroutine will turn on the bold attribute (insure that SCRTST (010AH) ;
; is set to YES if you wish to use this subroutine).			      ;
;=============================================================================;
;
BOLD:	lda	SCRTST		; termcap?
	cpi	YES		;
	rnz			; nope
	lxi	D,BLD		; yep, turn bold on
	mvi	C,PRINT		;
	call	MEX		;
	ret			;
;
;=============================================================================;
; UNBOLD subroutine							      ;
; This subroutine will turn off the bold attribute (insure that SCRTST (010AH);
; is set to YES if you wish to use this subroutine).			      ;
;=============================================================================;
;
UNBOLD:	lda	SCRTST		; termcap?
	cpi	YES		;
	rnz			; nope
	lxi	D,UNBLD		; yep, turn bold off
	mvi	C,PRINT		;
	call	MEX		;
	ret			;
;
;=============================================================================;
; Escape sequences for MD-11s						      ;
;=============================================================================;
;
CLRE:	db	ESC,'Y','$'	; clear to end-of-screen
CLRS:	db	ESC,'*','$'	; clear screen 
BLD:	db	'$'		; turn on character bold attribute
UNBLD:	db	'$'		; turn off character bold attribute
;
;=============================================================================;
; OVRVER subroutine							      ;
; This subroutine will print the overlay id and version on the console.	      ;
;=============================================================================;
;
OVRVER:	mvi	C,ILP		; print overlay id and version number
	call	MEX
	db	'Morrow Micro Decision 11 Computer Port Overlay V'
	db	OVERSION + '0','.',OREVISION + '0',CR,LF,0
	call	CIPMSG		; display "call in progress" if need be
	rc			;
	mvi	C,ILP		; aestetic newline
	call	MEX		;
	db	CR,LF,0		;
	ret
;
;=============================================================================;
; GOODBYE subroutine							      ;
; This subroutine is executed just prior to exiting from MEX to CP/M. All un- ;
; initialization procedures are done here.				      ;
;============================================================================;
;
GOODBYE:call	CIPMSG		; echo "call in progess" if need be
	ret			;
;
;=============================================================================;
; CIPMSG subroutine							      ;
; This subroutine will display the "call in progress" message (Spider/Z users ;
; are forgetful) if BOTH a carriet is detected AND the current MEX modem port ;
; is not the current CP/M console.					      ;
;=============================================================================;
;
CIPMSG:	call	CDTEST		; gotta carrier?
	rnc			; nope, then don't display "call in progress"
	call	BOLD		; use bolding if possible
	mvi	C,ILP		; print a newline
	call	MEX		;
	db	CR,LF,0		;
	call	IDMSG		; blapp out ID prompt if need be
	mvi	C,ILP		; print "call in progess" message
	call	MEX		;
	db	'[call in progress]',BELL,CR,LF,0
	call	UNBOLD		; undo bolding damage if need be
	stc			; show "call in progess" message printed
	ret
;
;=============================================================================;
; SBREAK subroutine							      ;
; This routine will mimic the function of the BREAK key by sending an	      ;
; interrupt to the modem (transmit line held high) for a period of 300 ms.    ;
;=============================================================================;
;
SBREAK: push	H		; save registers
	push	D		;
	push	B		;
	push	PSW		;
	mvi	A,0FAH		; force break for 300 ms
	mvi	B,3		; set duration for 300 ms
	call	TOUTCP		; do it!
	pop	PSW		; restore registers
	pop	B		;
	pop	D		;
	pop	H		;
	ret			;
;
;=============================================================================;
; DISCON subroutine							      ;
; This subroutine will disconnect the modem from the target computer. This    ;
; is done by dropping the DTR line to the modem for a period of 1.5 seconds   ;
; in theory, 300 ms is more than sufficient (this is what a BREAK key does),  ;
; but when the Smartmodem is dialing, a 300 ms pulse is not long enough to be ;
; recognized.								      ;
;=============================================================================;
;
DISCON:	push	H		; save registers
	push	D		;
	push	B		;
	push	PSW		;
	mvi	A,06AH		; turn off DTR, no break sent
	mvi	B,15		; set duration for 1.5 seconds
	call	TOUTCP		; do it!
	pop	PSW		; restore registers
	pop	B		;
	pop	D		;
	pop	H		;
	ret			;
;
;=============================================================================;
; TOUTCP subroutine							      ;
; This is a timed output to command port (OUTCP) subroutine. The value in the ;
; A register is output to the command port, then a time delay equal to the    ;
; value of the B register (in 100 ms units) is done.			      ;
;=============================================================================;
;
TOUTCP:	push	PSW		; save UAR/T command
	mvi	A,5		; write to control register 5
	call	OUTCP		;
	pop	PSW		; restore UAR/T command
	call	OUTCP		; send passed byte to CPORT
	mvi	C,TIMER		; wait alotted time
	call	MEX		;
	mvi	A,5		; write to control register 5
	call	OUTCP		;
	mvi	A,0EAH		; turn DTR back on, no break
	call	OUTCP		;
	ret			;
;
;=============================================================================;
; HELLO subroutine							      ;
; This subroutine is used to initialize the modem and the modem port. This    ;
; is done via using some of the system reserved bytes in the CP/M system      ;
; parameter page (0000H - 00FFH). There is a 16 byte system scratch area      ;
; (0040H - 004FH) that is never referenced by CP/M. For the Spizer/Z, the     ;
; addresses 0040H - 0042H are reserved for the Jade Double-D Floppy Disk      ;
; Controller. All others are scratch. MEX uses 004FH as the byte reserved     ;
; for stating the current baud rate for the modem port, while 004EH is 	      ;
; reserved for the current Smartmodem speaker volume. These locations can     ;
; can be checked whenever re-entering MEX. Protocol used:		      ;
;									      ;
;	if a call is in progress (determined by the testing for a	      ;
;	carrier detect (CDTEST)), MEX then uses the values stored in	      ;
;	then MEX system reserved bytes for modem baud rate (the value	      ;
;	is stored in MEX compatible format), and the Smartmodem speaker	      ;
;	volume.								      ;
;									      ;
;	otherwise set the modem baud rate and Smartmodem speaker volume	      ;
;	to the preset values (values set in this overlay or current values    ;
;       when CLONEing MEX).						      ;
;									      ;
;=============================================================================;
;
HELLO:	call	CDTEST		; check for call in progress
	jnc	COLDMEX		; nope, initialize the modem and port

GETBAUD:lxi	H,MEXBAUD	; valid MEX baud byte?
	mov	A,H		;
	ora	L		;
	jz	GETSPKR		; nope
	lda	MEXBAUD		; yep, get the system byte for MEX baud rate
	sta	MSPEED		; save it

GETSPKR:lxi	H,MEXSPKR	; valid MEX speaker byte?
	mov	A,H		;
	ora	L		;
	rz			; nope
	lda	MEXSPKR		; yep, get the system byte for MEX speaker volume
	sta	VOLUME		; save it

	ret			;
;
; cold starting MEX. load the baud rate and speaker volume with those values
; specified by this overlay.
;
COLDMEX:lda	MSPEED		; get the initial baud rate
	call	BAUD		; set it up
	lda	VOLUME		; get the initial speaker volume
	call	SPEAKER		; set it up
	ret
;
;=============================================================================;
; IDMSG subroutine							      ;
; this subroutine will check whether or not the ID prompt should be displayed ;
; prior to an error message. If so, the prompt will be displayed.	      ;
;=============================================================================;
;
IDMSG:	push	H		; save registers
	push	D		;
	push	B		;
	push	PSW		;
	lda	ERRID		; ID printed in "call in progress" message?
	cpi	NO		;
	jz	IDRET		; nope, then don't!
	mvi	C,PRID		; yep, then print it!
	call	MEX		;
IDRET:	pop	PSW		; restore registers
	pop	B		;
	pop	D		;
	pop	H		;
	ret			;
;
;=============================================================================;
; CDTEST subroutine							      ;
; This routine will test for a carrier detected on the designated modem	      ;
; status line (eithe DCD or DSR, depending on the overlay equates). If a      ;
; carrier is detect then thus subroutine returns with the CARRY set.	      ;
;=============================================================================;
;
CDTEST:	mvi	A,0		; read status register 0
	call	OUTCP		;
	call	INPSP		; look at the modem port status register
	ani	DCDLIN		; is there a carrier?
	rz			; nope, then return
	stc			; yep, set the CARRY and return
	ret			;
;
;=============================================================================;
; SET COMMAND:								      ;
;									      ;
; This command will allow the user to set a number of hardware dependent      ;
; functions. At the moment the allowable parameters are:		      ;
;									      ;
;	BAUD RATE:	This will allow the baud rate of the current user     ;
;			port to be changed on the fly. Valid baud rates       ;
;			are 300, 600, 1200, 19200.     			      ;
;									      ;
;	SPEAKER VOLUME:	This will allow the user to change the volume of      ;
;			the speaker of the Hayes Smartmodem. Valid volumes    ;
;			are OFF = speaker is always off, HALF = speaker	      ;
;			is on until carrier is detected, FULL = speaker	      ;
;			is always on.					      ;
;									      ;
;	usage:								      ;
;									      ;
;			SET BAUD 9600					      ;
;			SET SPEAKER OFF					      ;
;									      ;
;=============================================================================;
;
SETCMD:	call	GETARG		; any arguments?
	jc	SHWALL		; if not, go display set parmeters
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;parse argument
	PUSH	H		;save any parsed argument adrs on stack
	RNC			;if we have one, return to it
	POP	H		;oops, input not found in table
	jmp	SETERR		;
;
; Argument table (note last character of set parameter MUST have the MSB
; turned on. MEX uses this as a flag for the end-of-parameter).
;
CMDTBL:	DB	'?'+80H			; help
	DW	SETHELP
	DB	'BAU','D'+80H		; "set baud"
	DW	SETBAUD
	DB	'SPEAKE','R'+80H	; "set speaker"
	DW	SETSPKR
	DB	0			;<<=== table terminator
;
;=============================================================================;
; "SET" command (equates to a "SHOW ALL" command)			      ;
;=============================================================================;
;
SHWALL:	call	NEWLINE		; start off with a newline character
	call	BOLD		; bold the console output
	call	SHWBAUD		; show the current baud rate
	call	SHWSPKR		; show the current speaker volume
	call	UNBOLD		; unbold the console output
	call	NEWLINE		; terminate with a newline character
	ret			;
;
;=============================================================================;
; "SET ?" command (output HELP message to console)			      ;
;=============================================================================;
;
SETHELP:lda	SCRTST		; cursor control ability?
	cpi	NO		;
	cnz	CLRSCN		; yep, then clear the screen
	mvi	C,ILP		; print out help message to console
	call	MEX		;
	db	CR,LF
	db	'SET BAUD ',0
	call	BOLD
	mvi	C,ILP
	call	MEX
	db	'<baud-rate>',CR,LF,0
	call	UNBOLD
	lda	SMODEM		; got a Smartmodem?
	cpi	NO		;
	jz	NOSM01		; nope, then don't show "SET SPEAKER"
	call	UNBOLD
	mvi	C,ILP
	call	MEX
	db	'SET SPEAKER ',0
	call	BOLD
	mvi	C,ILP
	call	MEX
	db	'<volume>',CR,LF,0
NOSM01:	mvi	C,ILP
	call	MEX
	db	CR,LF
	db	'Baud rate is one of:',CR,LF,0
	call	UNBOLD
	mvi	C,ILP
	call	MEX
	db	'300 600 1200 19200',CR,LF
	db	CR,LF,0
	lda	SMODEM		; got a Smartmodem?
	cpi	NO		;
	jz	NOSM02		; nope, then don't show volume value
	call	BOLD
	mvi	C,ILP
	call	MEX
	db	'Volume is one of:',CR,LF,0
	call	UNBOLD
	mvi	C,ILP
	call	MEX
	db	'OFF     : Smartmodem speaker is always off',CR,LF
	db	'HALF    : Smartmodem speaker is on until carrier detect',CR,LF
	db	'FULL    : Smartmodem speaker is always on',CR,LF
	db	CR,LF,0
NOSM02:	ret			;
;
;=============================================================================;
; "SET BAUD" command							      ;
;=============================================================================;
;
SETBAUD:MVI	C,PARSBD	;nope, function code: parse a baudrate
	CALL	MEX		;let MEX look up code
	JC	BAUDERR		;jump if invalid code
	CALL	BAUD		;no, try to set it
	JC	BAUDERR		;if not one of ours, bomb out
	call	NEWLINE		;show the current baud rate
	call	SHWBAUD		;
	ret			;
;
;=============================================================================;
; "SHOW BAUD" command							      ;
;=============================================================================;
;
SHWBAUD:mvi	C,ILP		; nope, then display current baud rate
	call	MEX		;
	db	'Modem baud rate is set to ',0
	lda	MSPEED		; get current baud rate
	mvi	C,PRBAUD	; let MEX print it
	call	MEX
	call	NEWLINE		; terminate with newline character
	ret
;
;=============================================================================;
; BAUD subroutine							      ;
; This subroutine will set the baud of the current modem port. The new baud   ;
; rate is passed in the A register, and is also stored in the MEX parameter   ;
; page (MSPEED), and the MEX system reserved byte (MEXBAUD). If the new baud  ;
; rate specified is either illegal or not supported, this subroutine returns  ;
; with the CARRY set.							      ;
;=============================================================================;
;
BAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B

	MOV	E,A		;MSPEED code to DE
	MVI	D,0

	LXI	H,BAUDTBL	; nope, then fine offset into table
	DAD	D
	MOV	A,M		;fetch code
	ORA	A		;0? (means unsupported code)
	jz	BADBAUD		;yep, show it!
	PUSH	PSW		;no, set the rate
	mvi	A,0		; setup control register 0
	call	OUTCP		;
	mvi	A,0		;
	call	OUTCP		;
	mvi	A,1		; setup control register 1
	call	OUTCP		;
	mvi	A,0		;
	call	OUTCP		;
	mvi	A,2		; setup control register 2
	call	OUTCP		;
	mvi	A,0		;
	call	OUTCP		;
	mvi	A,3		; setup control register 3
	call	OUTCP		;
	mvi	A,0C1H		; Rx 8 bits, Rx enable
	call	OUTCP		;
	mvi	A,4		; setup control register 4
	call	OUTCP		;
	pop	PSW		; clock for baud rate, 1 stop bit, no parity
	call	OUTCP		;
	mvi	A,5		; setup control register 5
	call	OUTCP		;
	mvi	A,0EAH		; DTR on, Tx 8 bits, no break, Tx enable, RTS on
	call	OUTCP		;
	mvi	A,6		; setup control register 6
	call	OUTCP		;
	mvi	A,0		;
	call	OUTCP		;
	mvi	A,7		; setup control register 7
	call	OUTCP		;
	mvi	A,0		;
	call	OUTCP		;
	MOV	A,E		; get MEX format baud rate
	STA	MSPEED		; store in MEX
	lxi	H,MEXBAUD	; valid MEX baud byte in system page?
	mov	A,H		;
	ora	L		;
	mov	A,E		;
	jz	NOMEXB		; nope
	STA	MEXBAUD		; store it in the system byte for MEX baud rate
NOMEXB:	ORA	A		; return no-errors
	jmp	BDEXIT		;

BADBAUD:stc			; set CARRY to show bad baud rate specified

BDEXIT:	POP	B
	POP	D
	POP	H
	RET
;
; this is the baud rate converstion table. The MEX format baud rate value is
; used as an offset into this table. The grabbed value is the Interfacer 4
; mode register format containing the new baud rate.
;
BAUDTBL:DB	0		;110 (not supported)
	DB	BD300		;300
	DB	0		;450 (not supported)
	DB	BD600		;600
	DB	0		;710 (not supported)
	DB	BD1200		;1200
	DB	0		;2400 (not supported)
	DB	0		;4800 (not supported)
	DB	0		;9600 (not supported)
	DB	BD19200		;19200
;
;=============================================================================;
; "SET SPEAKER" command							      ;
;=============================================================================;
;
SETSPKR:lda	SMODEM		; got a Smartmodem?
	cpi	NO		;
	jz	SETERR		; nope, then show a SET error

	mvi	C,SBLANK	; yep, then scan for volume argument
	call	MEX
	jc	SPKRERR		; if no argument, let user know
	lxi	D,SPKTBL	; parse the argument
	mvi	C,LOOKUP
	call	MEX		; parse argument
	jc	SPKRERR		; bad volume argument

	mov	A,L		; store the new speaker volume
	call	SPEAKER		; set the Smartmodem speaker volume
	call	NEWLINE		; show the new speaker volume
	call	SHWSPKR		;
	ret			;
;
; speaker table for MEX table search
;
SPKTBL:	db	'OF','F'+80H	; turn speaker off keyword
	db	OFF,OFF		; Smartmodem ATM code for it
	db	'HAL','F'+80H	; turn speaker off after carrier detect keyword
	db	HALF,HALF	; Smartmodem ATM code for it
	db	'FUL','L'+80H	; turn speaker on keyword
	db	FULL,FULL	; Smartmodem ATM code for it
	db	0		; argument table terminator
;
;=============================================================================;
; "SHOW SPEAKER" command						      ;
;=============================================================================;
;
SHWSPKR:lda	SMODEM		; got a Smartmodem?
	cpi	NO		;
	rz			; nope, then don't show speaker volume

	mvi	C,ILP		; yep, then show the speaker volume
	call	MEX		;
	db	'Smartmodem speaker ',0
	mvi	C,ILP		;
	lda	VOLUME		;
	cpi	OFF		; speaker always off
	jz	SPKOFF		;
	cpi	HALF		; speaker on until carrier detect
	jz	SPKHALF		;
	cpi	FULL		; speaker always on
	jz	SPKFULL		;
SPKUNKN:call	MEX		; speaker volume status unknown
	db	'volume status not known',CR,LF,0
	ret			;
SPKOFF:	call	MEX		; speaker is turned off
	db	'is always turned off',CR,LF,0
	ret			;
SPKHALF:call	MEX		; speaker is set to half
	db	'is turned on until carrier detected',CR,LF,0
	ret			;
SPKFULL:call	MEX		; speaker is set to full
	db	'is always turned on',CR,LF,0
	ret			;
;
;=============================================================================;
; SPEAKER subroutine							      ;
; This subroutine will set the Smartmodem speaker to the requested volume.    ;
; The new volume value is passed in the A register, and is also stored in the ;
; MEX parameter page (VOLUME), and the MEX system reserved byte (MEXSPKR).    ;
;=============================================================================;
;
SPEAKER:push	H		; save registers
	push	D		;
	push	B		;
	mov	E,A		; save the new speaker volume
	
	lda	SMODEM		; got a Smartmodem?
	cpi	NO		;
	jz	SPKRET		; nope, then don't change the speaker volume

	mov	A,E		; restore the new speaker volume
	sta	VOLUME		; store the current volume for MEX
	lxi	H,MEXSPKR	; valid MEX speaker byte in system page?
	mov	A,H		;
	ora	L		;
	mov	A,E		;
	jz	NOMEXS		; nope
	sta	MEXSPKR		; store the current volume in reserved byte

NOMEXS:	call	SNDESC		; send the Smartmodem escape seq. if need be
	call	SNDATM		; send the Smartmodem speaker volume code
	call	SNDATO		; send the Smartmodem on-line code if need be

SPKRET:	pop	B		; restore registers
	pop	D		;
	pop	H		;
	ret
;
;=============================================================================;
; xxxERR subroutines							      ;
; These routines blapp out error messages on the console if the user somehow  ;
; screwed up the SET command line (bad syntax, or bad keyword values).        ;
;=============================================================================;
;
SETERR:	call	IDMSG		;print ID prompt if need be
	MVI	C,ILP		;inline print
	CALL	MEX		;
	DB	'++ bad SET parameter specified ++',BELL,CR,LF,0
	RET
;
BAUDERR:call	IDMSG		;print ID prompt if need be
	MVI	C,ILP		;inline print
	CALL	MEX		;
	DB	'++ bad baud rate specifed ++',BELL,CR,LF,0
	RET
;
SPKRERR:call	IDMSG		;print ID prompt if need be
	MVI	C,ILP		;inline print
	CALL	MEX		;
	DB	'++ bad speaker volume specifed ++',BELL,CR,LF,0
	RET
;
;=============================================================================;
; SNDSEC subroutine							      ;
; This subroutine will place the Smartmodem in command state. If a carrier    ;
; is detected, the Smartmodem escape sequence is sent, sandwiched between     ;
; two guard time delays. An initial null is sent just incase we are in the    ;
; "just CONNECTed" case (IE: Smartmodem has connected to target computer,     ;
; but Morrow hasn't sent anything yet). If there is no carrier, then this   ;
; routine merely returns.						      ;
;=============================================================================;
;
SNDESC:	call	CDTEST		; check for call in progress
	rnc			; nope, then return
	lxi	H,SMNULL	; yep, send a null (just CONNECTed case)
	call	SNDLIN		;
	mvi	B,12		; yep, goto command mode
	mvi	C,TIMER		; wait 1.2 seconds
	call	MEX		;
	lxi	H,SMESCAP	; send '+++'
	call	SNDLIN		;
	mvi	B,12		; wait 1.2 seconds
	mvi	C,TIMER		;
	call	MEX		;
	call	EATCODE		; eat result code
	ret			;
;
;=============================================================================;
; SNDCAN subroutine							      ;
; This subroutine will send the CANCEL character to the target computer	      ;
; system. The primary use of this subroutine is to cancel the Smartmodem      ;
; escape sequence sent to the target system to place the Smartmodem in	      ;
; command state. At the target computer end, there is an un-terminated	      ;
; command ("+++") that should not be executed.				      ;
;=============================================================================;
;
SNDCAN:	lda	CANCHR		; get the CANCEL character
	sta	CANMSG		; store in the CANCEL character message
	lxi	H,CANMSG	; get the CANCEL character message address
	call	SNDLIN		; send it
	ret			;
;
;=============================================================================;
; SNDATM subroutine							      ;
; This routine will send the Smartmodem code to set the speaker volume	      ;
;=============================================================================;
;
SNDATM:	lxi	H,ATMCODE	; send 'ATM'
	call	SNDLIN		;
	lxi	H,VOLUME	; send the volume code
	call	SNDLIN		;
	call	EATCODE		; eat result code
	ret			;
;
;=============================================================================;
; SNDATO subroutine							      ;
; This subroutine will send the code to place the Smartmodem back to on-line  ;
; state ONLY if a carrier is detected. If no carrier is detected, then this   ;
; subroutine merely returns.						      ;
;=============================================================================;
;
SNDATO:	call	CDTEST		; check for call in progess
	rnc			; nope, then return
	lxi	H,ATOCODE	; yep, then send 'ATO' (goto on-line mode)
	call	SNDLIN		;
	call	EATCODE		; eat result code
	call	SNDCAN		; send the cancel character (cancel SNDESC)
	ret			;
;
;=============================================================================;
; EATCODE subroutine							      ;
; This subroutine will eat all the characters recieved from the modem until   ;
; a 100 ms "quiet" period is detected (used to eat Smartmodem result codes).  ;
; The initial delay is for the Smartmodem result code turn-around time).      ;
;=============================================================================;
;
EATCODE:mvi	B,2		; wait 200 ms for Smartmodem turn-around
	mvi	C,TIMER		;
	call	MEX		;
EATCHAR:mvi	C,INMDM		; eat a character
	call	MEX		;
	jnc	EATCHAR		; if more, then eat another character
	ret			; otherwise return
;
;=============================================================================;
; GETARG subroutine							      ;
; This subroutine will scan the input stream for an argument. If no argument  ;
; present, then this subroutine returns with the CARRY set		      ;
;=============================================================================;
;
GETARG:	mvi	C,SBLANK	; scan input stream for <key-word>
	call	MEX		;
	ret			; and simply return
;
;=============================================================================;
; EATARG subroutine							      ;
; This subroutine will eat (throw away) the remaining characters in the	      ;
; current argument. This is an aid for other routines which do not need to    ;
; (and thus do not) check the entire argument for a unique match to be made   ;
; (EG: "SET PORT C" and "SET PORT CONSOLE" will do the same thing, execept    ;
; the SBLANK MEX function will see the next "argument" as being "ONSOLE"      ;
; opposed to the line terminator).					      ;
;=============================================================================;
;
EATARG:	mvi	C,LKAHED	; look ahead to next character in command line
	call	MEX		;
	rc			; return if done (burp)
	cpi	' '		; is it a blank?
	rz			; yep, then we've finished eating the argument
	mvi	C,GNC		; nope, eat the next character in command line
	call	MEX		;
	jmp	EATARG		; check the next character in command line
;
;=============================================================================;
; NEWLINE subroutine							      ;
; This subroutine will send a newline character (CR-LF pair) to the console   ;
;=============================================================================;
;
NEWLINE:mvi	C,ILP		; output a newline character to console
	call	MEX		;
	db	CR,LF,0		;
	ret			;
;
;=============================================================================;
; SNDLIN subroutine							      ;
; This routine will send a string to the modem port. Works similar to the     ;
; BDOS 9 function. The string start address is in the HL register pair, and   ;
; the end-of-string character is set to EOS.				      ;
;=============================================================================;
;
SNDLIN:	mvi	C,SNDRDY	; is modem ready to read another character?
	call	MEX		;
	jnz	SNDLIN		; nope, wait for it
	mov	A,M		; yep, get next character to send to modem
	cpi	EOS		; end-of-string character?
	rz			; yep, then return
	mov	B,A		; nope, get the next character to send
	mvi	C,SNDCHR	;
	call	MEX		; send it!
	inx	H		; bump up the string point
	jmp	SNDLIN		; send the next character
;
;=============================================================================;
; Smartmodem codes to do what we want it do (for "SNDATx" routines)	      ;
;=============================================================================;
;
SMNULL:	db	NULL,EOS	; null for justed CONNNECTed case
SMESCAP:db	'+++',EOS	; Smartmodem code for goto command state
CANMSG:	db	'?',EOS		; cancel character message string
ATMCODE:db	'ATM',EOS	; Smartmodem code for speaker volume
VOLUME:	db	MD$SPKR,CR,EOS	; initial speaker volume
ATOCODE:db	'ATO',CR,EOS	; Smartmodem code for goto on-line state
;
;=============================================================================;
; Modem input (get a character or status) driver			      ;
;=============================================================================;
;
INPSP:	MVI	A,SPORT		; get modem status
	JMP	INP1
INPDP:	MVI	A,DPORT		; get a character from the modem
	JMP	INP1		;

INP1:	PUSH	B		; save BC register pair
	MOV	C,A		; save port offset
	mvi	A,BASE		; get the base port
	ADD	C		; add offset for desired port (data/status)
	STA	INP2+1		; store for IN command
INP2:	IN	0		; input data/status
	POP	B		; restore BC register pair
	RET			; and return
;
;=============================================================================;
; Modem output (put a character or command) driver			      ;
;=============================================================================;
;
OUTDP:	push	B		; save the BC register pair
	mvi	C,DPORT		; put a character to the modem
	jmp	OUT1		;
OUTCP:	push	B		; save the BC register pair
	mvi	C,CPORT		; change modem control register
	jmp	OUT1		;

OUT1:	mov	B,A		; save the output character
	mvi	A,BASE		; get the base port address
	ADD	C		; add offset for desired port (data/ctrl)
	sta	OUT2+1		; store for OUT command
	mov	A,B		; restore the output character
OUT2:	out	0		; send it (or change mode/control port)
	pop	B		; restore the BC register pair
	ret			; return

	end
