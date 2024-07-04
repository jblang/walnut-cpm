	PAGE	0		; Let print utility paginate
	Title	'MEX overlay for the U.S. Robotics S-100 version 1.3'
; 	08/27/84 by Don Wilke
;	08/29/84 added fancy video conditionals
;	08/30/84 added parity routines
;
REV	EQU	13		; Overlay revision level
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
BELL	EQU	07H		; Bell
TAB	EQU	09H		; Tab
LF	EQU	0AH		; Line feed
CR	EQU	0DH		; Carriage return
ESC	EQU	1BH		; Escape
TPA	EQU	100H		; Transient prog area
MEX	EQU	0D00H		; Address of the service processor
ATTRIB	EQU	YES		; Yes if fancy video supported
;
; USR port equates
;
PORT	EQU	0C0H		; Base I/O address for USR S-100 card
MODCT1  EQU	PORT+1		; 8251 control port
MODDAT  EQU	PORT		; 8251 data port
MDDCDB	EQU	10000000B	; Carrier detect bit
MDDCDA	EQU	10000000B	; Value when active
MDRCVB	EQU	00000010B	; Bit to test for receive
MDRCVR	EQU	00000010B	; Value when ready
MDSNDB	EQU	00000001B	; Bit to test for send
MDSNDR	EQU	00000001B	; Value when ready
MMODEA	EQU	11001111B	; 8 bits, clock/64, 2 stop bits 
MMODEB	EQU	01001110B	; 8 bits, clock/16, 1 stop bit
MMCMDA	EQU	00110111B	; RTS hi, error reset, DTR hi, enable TX/RX
MMCMDB	EQU	00010111B	; Error reset, DTR hi, enable TX/RX
MRESET	EQU	01000000B	; 8251 reset
;
; Following are function codes for the MEX service call processor
;
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
; 
CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer,same structure as BDOS 10

	ORG	TPA		; We begin
; 
	DS	3		; MEX has a JMP START here
; 
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
; 
PMODEM:	DB	NO		; Yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		; Yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'P'		; T=touch,P=pulse (not referenced by MEX)
CLOCK:	DB	40		; Clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	5		; Sets display time for sending a file
				; 0=110	1=300  2=450  3=600  4=710
				; 5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		; Default time to send character in
				; terminal mode file transfer (0-9)
				; 0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		; End-of-line delay after CRLF in terminal
				; mode file transfer for slow BBS systems
				; 0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		; Number of directory columns
SETFL:	DB	YES		; Yes=user-defined SET command
SCRTST:	DB	YES		; Yes=if home cursor and clear screen
				; routine at CLRSCRN
	DB	0		; Was once ACKNAK,now spare
BAKFLG:	DB	NO		; Yes=make .BAK file
CRCDFL:	DB	YES		; Yes=default to CRC checking
				; No=default to Checksum checking
TOGCRC:	DB	YES		; Yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		; Yes=convert backspace to rub
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub
ADDLF:	DB	NO		; No=no LF after CR to send file in
				; terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR
TRNLOG:	DB	NO		; Yes=allow transmission of logon
				; write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP
LOCNXT:	DB	NO		; Yes=local cmd if EXTCHR precedes
				; No=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		; Yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		; Yes=allow toggling of printer on/off
				; in terminal mode. Set to no if using
				; the printer port for the modem
XOFTST:	DB	NO		; Yes=allow testing of XOFF from remote
				; while sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after sending CR while
				; transmitting a file in terminal mode	
TOGXOF:	DB	YES		; Yes=allow toggling of XOFF testing
IGNCTL:	DB	YES		; Yes=do not send control characters
				; above CTL-M to CRT in terminal mode
				; no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		; For future expansion
EXTRA2:	DB	0		; For future expansion
BRKCHR:	DB	'@'-40H		; ^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		; ^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		; ^L = Send logon
LSTCHR:	DB	'P'-40H		; ^P = Toggle printer
UNSVCH:	DB	'R'-40H		; ^R = Close input text buffer
TRNCHR:	DB	'T'-40H		; ^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		; ^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		; ^^ = Send next character
; 
; Equates used only by PMMI routines grouped together here.
; 
PRATE:	DB	250		; 125=20pps dialing, 250=10pps
	DB	0		; Not used
; 
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area,then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
; 
INCTL1:	IN	MODCT1		; In modem control port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed for non-PMMI
; 
OTDATA:	OUT	MODDAT		; Out modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed for non=PMMI
; 
INPORT:	IN	MODDAT		; In modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed for non-PMMI
; 
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
; 
MASKR:	ANI MDRCVB ! RET	; Bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	; Value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	; Bit to test for send ready
TESTS:	CPI MDSNDR ! RET	; Value of send bit when ready
; 
; 
; Unused area: was once used for special PMMI functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.
; 
	DS	12
; 
; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.  Thus, if your modem can't dial, change the
; JMP PDIAL at DIALV to DS 3, and MEX will print a "not-implemented"
; diagnostic for any commands that require dialing.
; 
; DIALV  dials the digit in A. See the comments at PDIAL for specs.
; 
; DISCV  disconnects the modem
; 
; GOODBV is called just before MEX exits to CP/M.  If your overlay
;        requires some exit cleanup, do it here.
; 
; INMODV is called when MEX starts up; use INMODV to initialize the modem.
; 
; NEWBDV is used for phone-number baud rates and is called with a baud-rate
;        code in the A register, value as follows:
; 
; 	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
; 	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
; 	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
; 
;        If your overlay supports the passed baud rate,it should store the
; 	 value passed in A at MSPEED (107H), and set the requested rate. If
; 	 the value passed is not supported, you should simply return (with-
; 	 out modifying MSPEED) -or- optionally request a baud-rate from the
; 	 user interactively.
; 
; NOPARV is called at the end of each file transfer; your overlay may simply
; 	 return here, or you may want to restore parity if you set no-parity
; 	 in the following vector (this is the case with the PMMI overlay).
; 	 
; PARITV is called at the start of each file transfer; your overlay may simply
; 	 return here, or you may want to enable parity detection (this is the
; 	 case with the PMMI overlay).
; 
; SETUPV is the user-defined command ... to use this routine to build your own
; 	 MEX command, set the variable SETFL (117H) non-zero,and add your SET
; 	 code.  You can use the routine presented in the PMMI overlay as a 
; 	 guide for parsing, table lookup, etc.
; 
; SPMENU is provided only for MDM compatibility, and is not used by MEX 1.0 
; 	 for any purpose (it will be gone in MEX 2).
; 
; VERSNV is called immediately after MEX prints its sign-on message at cold
; 	 startup -- use this to identify your overlay in the sign-on message
; 	 (include overlay version number in the line).
; 
; BREAKV is provided for sending a BREAK (<ESC>-B in terminal mode).  If your
; 	 modem doesn't support BREAK, or you don't care to code a BREAK rou-
; 	 tine, you may simply execute a RET instruction.
; 
LOGON:	DS	2		; Needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		; Dial digit in A 
DISCV:	DS	3		; Disconnect the modem
GOODBV:	JMP	GOODBYE		; Called before exit to CP/M
INMODV:	JMP	NITMOD		; Initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		; Set baud rate
NOPARV:	RET ! NOP ! NOP		; Set modem for no-parity
PARITV:	RET ! NOP ! NOP		; Set modem parity
SETUPV:	JMP	SETCMD		; SET cmd
SPMENV:	RET ! NOP ! NOP		; Not used with MEX
VERSNV:	JMP	SYSVER		; Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK		; Send a break
; 
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
; 
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
; 
ILPRTV:	DS	3		; Replace with MEX function 9
INBUFV:	DS	3		; Replace with MEX function 10
ILCMPV:	DS	3		; Replace with table lookup funct. 247
INMDMV:	DS	3		; Replace with MEX function 255
NXSCRV:	DS	3		; Not supported by MEX (returns w/no action)
TIMERV:	DS	3		; Replace with MEX function 254
; 
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).  Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
; 
; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).
; 
CLREOS:	LXI	D,EOSMSG	; Point to clear to EOS msg
	MVI	C,PRINT		; MEX print string funct #
	CALL	MEX		; Let MEX do it
	RET
; 
CLS:	LXI	D,CLSMSG	; Point to clear screen msg
	MVI	C,PRINT		; MEX print string funct #
	CALL	MEX		; Let MEX do it
	RET
; 
; The following routine sends a break "character" to the remote computer 
; for 300 ms.  The "MSPEED" value is needed to decide whether the modem 
; is at 300, 600, or 1200 baud.  The routine must know this because U.S.R. 
; sets up the RTS bit of the command register as a baud rate selection bit, 
; and this routine must be careful not to change it, or the user will end up 
; at a different baud rate after the break "character" is sent.  Note that 
; the "MVI A,01FH" does not change any flags.
; 
PBREAK:	LDA	MSPEED		; Get speed byte
	CPI	3		; Are we at 600 baud?
	MVI	A,01FH		; Set up for 600 (no flag changes)
	JZ	PBRK2		; And if we are, go do that
	MVI	A,03FH		; Otherwise,set up for 300/1200
PBRK2:	OUT	MODCT1		; Send break
	PUSH	PSW		; Save value
	MVI	B,3		; 300 ms delay value
	MVI	C,TIMER		; MEX service function #254
	CALL	MEX		; Wait that long
	POP	PSW		; Restore command byte
	ANI	0F7H		; Turn off break bit
	OUT	MODCT1		; Send command byte to UART
	RET
; 
; The U.S.R. S-100 does not have a "quick-disconnect" feature like
; the Hayes does (by lowering DTR).  Therefore, "GOODBYE" is not
; implemented.  Yet control-N still works to hang up (see note
; above in introduction)
; 
GOODBYE:	RET
; 
; *	*	*	*	*	*	*	*	*
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	This initialization
; sets up 1200 baud, 8 data bits, 1 stop bit, no parity.  Due to a
; quirk in the U.S.R. S-100 (it seems to have plenty of 'em), after
; you change baud rates, you should send an "AT" followed by a
; carriage return.  Therefore, this is done after every initialization
; when there is no carrier present.
; 
; NOTE: The U.S.R. S-100 does not operate too well at clock speeds of
; 	over 4 MHz.  If you are running at that speed or higher,you
; 	should uncomment (by removing the preceding semicolon) the
; 	lines with XCHG.  These serve as time wasting routines to
; 	let the U.S.R. S-100 catch up.  This is not a problem when
; 	doing character I/O, as the program checks to see if the
; 	modem is ready to accept a character.
; 
NITMOD: MVI	A,0		; Zero accumulator
	OUT	MODCT1		; Once
	XCHG			; For fast systems
	XCHG			; 
	OUT	MODCT1		; Twice
	XCHG			; For fast systems
	XCHG			; 
	OUT	MODCT1		; Three times,even
	XCHG			; For fast systems
	XCHG			; 
	MVI	A,MRESET	; Reset UART command
	OUT	MODCT1		; Send to control port
	XCHG			; For fast systems
	XCHG			; 
	DB	3EH		; "MVI,A" code
MODEBT:	DB	MMODEB		; Mode byte
	OUT	MODCT1		; Send to control port
	XCHG			; For fast systems
	XCHG			; 
	DB	3EH		; "MVI,A" code
CMDBT:	DB	MMCMDA		; Command byte
	OUT	MODCT1		; Send to control port
	XCHG			; For fast systems
	XCHG			; 
	DB	3EH		; "MVI,A" code
BDCODE:	DB	5		; Default baud rate code
	STA	MSPEED		; Stuff it
	CALL	CARRCK		; See if there is a carrier
	RNZ			; If so, don't do AT stuff
	LXI	H,INISTR	; Point to initialization string
SNDL:	MOV	A,M		; Get char to look at it
	CPI	'$'		; EOS char?
	JZ	INITEX		; Yes, exit
	MOV	B,A		; No, save char in B
	CALL	OUTMOD		; Output char to modem
	INX	H		; Point to next
	JMP	SNDL		; Loop 'til EOS
;
INITEX:	MVI	B,15		; Wait 1.5 sec
	MVI	C,TIMER		; MEX service function #254
	CALL	MEX		; Wait for USR to say "OK"
	RET
;
; Command string sent to modem after I/O initialization
;
INISTR:	DB	'AT'		; Get modem's attention
	DB	'X1'		; Send extended result codes
SPBYTE:	DB	'M1'		; Speaker on 'til connect
	DB	'S0=0'		; Disable auto-answer
WABYTE:	DB	'S7=30'		; Wait 30 seconds for carrier
	DB	'V1'		; Set verbose result codes
	DB	CR,'$'		; End of command string
; 
; Output a character to the U.S.R. S-100
; (NOTE: This routine is not normally present in most overlays,
; 	 and is used by the NITMOD routine above.)
; 
OUTMOD:	IN	MODCT1		; Get status
	ANI	MDSNDB		; Mask for ready status
	JZ	OUTMOD		; Loop if not ready
	MOV	A,B		; Otherwise get the character
	OUT	MODDAT		; Output to the data port
	RET			; And return
; 
PBAUD:	CPI	5		; 5=1200 baud
	JZ	OK1200		; Set to 1200
	CPI	3		; 3=600 baud
	JZ	OK600		; Set to 600
				; Else set to 300
OK300:	CALL	WAIT60		; Set longer wait for carrier
	LXI	B,BD300		; Point to initializers for 300 baud
	MVI	A,1		; 300 baud value
	JMP	LOADBD		; Go load it
OK600:	CALL	WAIT60		; Set longer wait for carrier
	LXI	B,BD600		; Point to initializers for 600 baud
	MVI	A,3		; 600 baud value
	JMP	LOADBD		; Go load it
OK1200:	CALL	WAIT30		; Set short wait for carrier
	LXI	B,BD1200	; Point to initializers for 1200 baud
	MVI	A,5		; 1200 baud value
LOADBD:	STA	BDCODE		; Change baud rate code value
	LDAX	B		; Get mode byte value
	STA	MODEBT		; Change mode byte
	INX	B		; Point to cmd byte
	LDAX	B		; Get cmd byte
	STA	CMDBT		; Change cmd byte
	CALL	NITMOD		; (Re)initialize modem
	LDA	SETFLG		; Get setflg
	CPI	0FFH		; Is it a 'SET'
	JNZ	PBPSA		; No, print bps in dial prompt
	RET			; Yes, just return
PBPSA:	
	 IF	ATTRIB
	LXI	D,INDVID	; Set video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	JMP	PBPS		; Print bps rate
;
; Wait for carrier 30/60 seconds
;
WAIT30:	MVI	A,'3'		; Set up for short wait
	JMP	SWAIT		; Jump around
WAIT60:	MVI	A,'6'		; Set up for long wait
SWAIT:	STA	WABYTE+3	; store the wait msb value
	MVI	A,'0'		; fake lsbyte
	STA	WABYTE+4	; store the wait lsb value
	RET
; 
; Baudrate parameters (mode byte, command byte)
; 
BD300:	DB	MMODEA,MMCMDA	; 300  baud, 8 bits, 2 stop, no parity.
BD600:	DB	MMODEB,MMCMDB	; 600  baud, 8 bits, 1 stop, no parity.
BD1200:	DB	MMODEB,MMCMDA	; 1200 baud, 8 bits, 1 stop, no parity.
; 
; Sign-on message
; 
SYSVER:	
	 IF	ATTRIB
	LXI	D,INVID		; Set video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,SOMESG	; Point to signon message
	CALL	PMSG		; Print message on term
CARRSH:	
	 IF	ATTRIB
	LXI	D,NORVID	; Reset video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,NOMESG	; Tell about carrier
	CALL	CARRCK		; Check for it
	CZ	PMSG		; Print the "No" if no carrier
	LXI	D,CARMSG	; Print "carrier present"
	CALL	PMSG		; Print message on term
	 IF	ATTRIB
	LXI	D,NORVID	; Reset video attribute
	 ENDIF	;ATTRIB
	 IF	NOT ATTRIB
	RET
 	 ENDIF	;NOT ATTRIB
PMSG:	MVI	C,PRINT		; Get print funct #
	CALL	MEX		; Let MEX do it
	RET
;
SOMESG:	DB	' U. S. Robotics S-100 ',CR,LF
	DB	' Autodial Version '
	DB	REV/10+'0','.'
	DB	REV MOD 10+'0',' '
	DB	CR,LF,'$'
; 
NOMESG:	DB	'No$'
CARMSG:	DB	' carrier present '
	DB	CR,LF,'$'
; 
; Strings to clear-to-end-of-screen, and clear-screen
; 
EOSMSG:	DB	ESC,'[J$'	; ANSI clear EOS
CLSMSG:	DB	ESC,'[2J$'	; ANSI clear screen
;
; Strings for setting video attributes
;
UNVID:	DB	ESC,'[4m$'	; ANSI underscore
INDVID:	DB	ESC,'[7m$'	; ANSI inverse
INVID:	DB	ESC,'[1;7m$'	; ANSI bold, inverse
BLVID:	DB	ESC,'[1;5;7m$'	; ANSI bold, inverse, blinking
NORVID:	DB	ESC,'[0m$'	; ANSI return to normal video
; 
; Check the USR for carrier-present (Z=no)
; 
CARRCK:	IN	MODCT1		; Get status byte
	ANI	MDDCDB
	RET
; 
; Newline on console
; 
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		; Fall into TYPE
; 
; Type char in A on console
; 
TYPE:	PUSH	H		; Save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		; Align output character
	MVI	C,CONOUT	; Print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
; 
; The remainder of this overlay implements a very versatile
; SET command -- if you prefer not to write a SET for your
; modem, you may delete the code from here to the END statement.
; 
; Control is passed here after MEX parses a SET command.
; 
SETCMD:	PUSH	PSW		; Save modem speed code
	MVI	A,0FFH		; Get all ones
	STA	SETFLG		; Set setflg
	POP	PSW		; Get modem spd back
	MVI	C,SBLANK	; Any arguments?
	CALL	MEX
	JC	SETSHO		; If not, go print out values
	LXI	D,CMDTBL	; Parse command
	CALL	TSRCH		; From table
	PUSH	H		; Any address on stack
	RNC			; If we have one, execute it
	POP	H		; Nope, fix stack
SETERR:	
	 IF	ATTRIB
	LXI	D,BLVID		; Set video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,SETEMS	; Point to error msg
	CALL	PMSG		; Print message on term
	 IF	ATTRIB
	LXI	D,NORVID	; Reset video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	CALL	STHELP		; Print help on error
	MVI	A,0		; Clear acc
	STA	SETFLG		; Reset setflg
	RET
; 
SETEMS:	DB	CR,LF,' SET COMMAND ERROR ',CR,LF,BELL,'$'
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
CMDTBL:	DB	'?'+80H		; "set ?"
	DW	STHELP
	DB	'BAU','D'+80H	; "set baud"
	DW	STBAUD
	DB	'PARIT','Y'+80H	; "set parity"
	DW	STPAR
	DB	'SPK','R'+80H	; "set spkr"
	DW	STSPKR
	DB	'WAI','T'+80H	; "set wait"
	DW	STWAIT
	DB	'DIA','L'+80H	; "set dial"
	DW	STDIAL
	DB	0		; <<=== table terminator
; 
; SET <no-args>: print current statistics
; 
SETSHO:	CALL	CARRSH		; Show carrier present/not present
	LXI	H,SHOTBL	; Get table of SHOW subroutines
SETSLP:	MOV	E,M		; Get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		; End of table?
	ORA	E
	RZ			; Exit if so
	PUSH	H		; Save table pointer
	XCHG			; Adrs to HL
	CALL	GOHL		; Do it
	CALL	CRLF		; Print newline
	MVI	C,CHEKCC	; Check for console abort
	CALL	MEX
	POP	H		; It's done
	JNZ	SETSLP		; Continue if no abort
	RET
; 
GOHL:	PCHL
; 
; table of SHOW subroutines
; 
SHOTBL:	DW	BDSHOW
	DW	PASHOW
	DW	SPSHOW
	DW	WASHOW
	DW	DISHOW
	DW	0		; <<== table terminator
; 
; SET ?  processor
; 
STHELP:	
	 IF	ATTRIB
	LXI	D,UNVID		; Set video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,HLPHDR	; Point to HELP header
	CALL	PMSG		; Print message on term
	 IF	ATTRIB
	LXI	D,NORVID	; Reset video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,HLPMSG	; Point to HELP msg
	CALL	PMSG		; Print message on term
	 IF	ATTRIB
	LXI	D,INDVID	; Set video attribute
	CALL	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
	LXI	D,HLPNOT	; Point to HELP note
	CALL	PMSG		; Print message on term
	 IF	NOT ATTRIB
	RET
	 ENDIF	;NOT ATTRIB
	 IF	ATTRIB
	LXI	D,NORVID	; Reset video attribute
	JMP	PMSG		; Issue attribute to term
	 ENDIF	;ATTRIB
; 
; The help message
; 
HLPHDR:	DB	CR,LF,'THE FOLLOWING ARE VALID SET COMMANDS:$'
HLPMSG:	DB	CR,LF,'SET BAUD <300> or <600> or <1200>'
	DB	CR,LF,'SET PARITY <NONE> or <ODD> or <EVEN>'
	DB	CR,LF,'SET SPKR <OFF> or <ON> or <DEBUG>'
	DB	CR,LF,'SET WAIT <30> or <60> or <90>'
	DB	CR,LF,'SET DIAL <TOUCH> or <PULSE>$'
HLPNOT:	DB	CR,LF,LF,'NOTE: SET BAUD defaults to NO parity.'
	DB	CR,LF,LF,'$'
;
SETFLG:	DB	0		; SET command flag
; 
; SET BAUD processor
; 
STBAUD:	MVI	C,BDPARS	; Function code
	CALL	MEX		; Let MEX look up code
	JC	SETERR		; Invalid code
	CALL	PBAUD		; No, try to set it
	JC	SETERR		; Not-supported code
	JMP	SETSHO		; review parameters
;
BDSHOW:	LDA	SETFLG		; Get setflg
	CPI	0FFH		; Is it a 'SET' operation?
	JNZ	PBPS		; No, must be dial - just display bps
	CALL	ILPRT		; Yes, display the 'Baud' prompt
	DB	'Baud rate: ',0
PBPS:	LDA	MSPEED		; Load modem speed code
	MVI	C,PRBAUD	; Use MEX function #
	CALL	MEX		; To print bps
	LXI	D,NORVID	; Reset video attribute
	CALL	PMSG		; Issue attribute to term
	MVI	E,' '		; Followed by space
	MVI	C,CONOUT	; Use MEX function #
	CALL	MEX		; Let MEX do it
	MVI	A,0		; Clear acc
	STA	SETFLG		; Reset setflg
	RET
;
; SET PARITY processor
;
STPAR:	LXI	D,PARTBL	; point to parity table
	CALL	TSRCH		; lookup next input item in table
	JC	SETERR		; if not found, error
	PUSH	PSW		; a=byte from table
	LDA	MODEBT		; get old mode byte
	ANI	0C3H		; strip off parity bits, word length
	MOV	B,A		; old modebt into b
	POP	PSW		; get table entry back
	ANI	3CH		; mask parity bits, word length
	ADD	B		; adjust new parity values
	STA	MODEBT		; store the new mode byte
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
PASHOW:	CALL	ILPRT		; show parity mode
	DB	'Parity: ',0
	LDA	MODEBT		; get mode byte
	ANI	30H		; mask off parity bits
	CPI	10H		; bit 4 hi?
	JZ	ODDPAR		; yes, odd parity
	CPI	30H		; bits 5,4 hi?
	JZ	EVPAR		; yes, even parity
				; else no parity
NOPAR:	CALL	ILPRT		; in-line print
	DB	'NONE',0
	RET
EVPAR:	CALL	ILPRT		; in-line print
	DB	'EVEN',0
	RET
ODDPAR:	CALL	ILPRT		; in-line print
	DB	'ODD',0
	RET
;
PARTBL:	DB	'NON','E'+80H	; set parity off
	DB	0CH,0		; 8 bit word length
	DB	'EVE','N'+80H	; set parity even
	DB	38H,0		; bits 5,4,3 hi (7 bit word length)
	DB	'OD','D'+80H	; set parity odd
	DB	18H,0		; bits 4,3 hi (7 bit word length)
	DB	0		; <<=== table terminator
;
; SET SPKR processor
;
STSPKR:	LXI	D,SPKTBL	; lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; if not found, error
	STA	SPBYTE+1	; store the spkr command
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
SPSHOW:	CALL	ILPRT		; show spkr mode
	DB	'Speaker: ',0
	LDA	SPBYTE+1	; get spkr byte
	CPI	'1'
	JZ	SPONPT		; spkr on part-time
	CPI	'2'
	JZ	SPON		; spkr on continuously
;
SPOFF:	CALL	ILPRT
	DB	'OFF',0
	RET
;
SPONPT:	CALL	ILPRT
	DB	'ON until connect',0
	RET
;
SPON:	CALL	ILPRT
	DB	'ON always',0
	RET
;
SPKTBL:	DB	'OF','F'+80H	; set spkr off
	DB	'0',0
	DB	'O','N'+80H	; set spkr on 'til connect	
	DB	'1',0
	DB	'DEBU','G'+80H	; set spkr on continuously
	DB	'2',0
	DB	0		; <<=== table terminator
;
; SET WAIT processor
;
STWAIT:	LXI	D,WAITBL	; lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; if not found, error
	STA	WABYTE+3	; store the wait msb value
	MVI	A,'0'		; fake lsbyte
	STA	WABYTE+4	; store the wait lsb value
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
WASHOW:	CALL	ILPRT
	DB	'Wait: ',0
	LDA	WABYTE+3
	CALL	TYPE		; show msb
	LDA	WABYTE+4
	CALL	TYPE		; show lsb
	CALL	ILPRT
	DB	' seconds for carrier',0
	RET
;
WAITBL:	DB	'3','0'+80H	; "set wait 30"
	DB	'3',0
	DB	'6','0'+80H	; "set wait 60"
	DB	'6',0
	DB	'9','0'+80H	; "set wait 90"
	DB	'9',0
	DB	0		; <<=== table terminator
;
; SET DIAL processor
;
STDIAL:	LXI	D,DIATBL	; lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; if not found, error
	STA	TPULSE		; store the dial command
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
DISHOW:	CALL	ILPRT		; show dial mode
	DB	'Dial: ',0
	LDA	TPULSE		; get dial byte
	CPI	'T'
	JZ	TTONE		; touch tone 
;
PDIAL:	CALL	ILPRT
	DB	'Pulse',0
	RET
;
TTONE:	CALL	ILPRT
	DB	'Touch Tone',0
	RET
;
; DIAL argument table
;
DIATBL:	DB	'TOUC','H'+80H	; touch tone
	DB	'T',0
	DB	'PULS','E'+80H	; pulse dial
	DB	'P',0
	DB	0		; <<=== table terminator
; 
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
; 
TSRCH:	MVI	C,LOOKUP	; Get function code
	JMP	MEX		; Pass to MEX processor
; 
; Print in-line message ... blows away C register
; 
ILPRT:	MVI	C,ILP		; Get function code
	JMP	MEX		; Go do it
; 
; NOTE:  Must terminate prior to 0B00H 
; 
	  END
