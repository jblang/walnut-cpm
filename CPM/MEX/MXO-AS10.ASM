;	Title	'MEX overlay for the ALSPA Computer version 1.0'
;
REV	EQU	10		; Overlay revision level
;
; MEX ALSPA OVERLAY VERSION 1.0
; Modified from MXO-NS10.ASM  by Bill Duerr  12/28/84
;
; This is a MEX overlay file for the ALSPA Computer with the standard
; serial ports (Modem on the second serial port as default).
;
; ***NOTE***  If you are using the ALSPA second serial port, you MUST set
; the speed on the second serial port for 1200 bps, even if your modem is
; only 300 bps.  (See instructions for "baud-rate header" - page 7 of the
; ALSPA User's Guide.)
;
; Note that all overlays may freely use memory up to 0CFFH.  If your
; overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM) or
; the MEX DATEC 212 overlay (MXO-DTxx.ASM), the physical modem overlay
; should terminate by 0AFFH.
;
; The SET command allows the user to change the baud rate, parity, pulse
; or tone dialing, and the port assignment.  The parity options are: No
; parity (NONE); Even parity (EVEN); Even parity with 8 data bits
; (EVEN8); Odd parity (ODD); and Odd parity with 8 data bits (ODD8).
; EVEN8 and ODD8 are for special purposes and will most likely never be
; used.  The port assignments may be "0" (printer), "2" (console), or
; "4" (modem).
;
; Misc equates.
;
YES	EQU	0FFH
NO	EQU	0
NA	EQU	0FFH		; Value for baud rate not available
TPA	EQU	100H		; Beginning of TPA
CR	EQU	13		; Carriage return
LF	EQU	10		; Line feed
TAB	EQU	9		; Tab
BELL	EQU	07H		; Bell
ESC	EQU	1BH		; Escape
;
; Change the following information to match your equipment
;
PORT	EQU	4H		; Modem data port (see also SET command)
;
MODCTL	EQU	PORT+1		; MODEM control port
MODDAT	EQU	PORT		; MODEM data port
MDRCVB	EQU	2		; Bit to test for receive
MDRCVR	EQU	2		; Value when ready
MDSNDB	EQU	1		; Bit to test for send
MDSNDR	EQU	1		; Value when ready
EVEN	EQU	78H		; Even parity, 7 data bits
EVEN8	EQU	7CH		; Even parity, 8 data bits
ODD	EQU	58H		; Odd parity, 7 data bits
ODD8	EQU	5CH		; Odd parity, 8 data bits
NONE	EQU	4CH		; No parity, 8 data bits
;
; Initial baud rate
;
INITBD	EQU	5		; Initial baud rate (1200) (MSPEED=5)
;
; EOS and CLS is set up for ADM-3 terminal
;
EOS	EQU	17H		; Clear to end of screen
CLS	EQU	1AH		; Clear screen
;
; Control bytes
;
RESET1	EQU	0B7H		; Initialize UART
RESET2	EQU	77H		; Internal reset
CHIPSET	EQU	27H		; DTR, RTS, RE, TE
DISCNT	EQU	07H		; No DTR, RTS, RE, TE
;
BREAK	EQU	CHIPSET	OR 8H	; BREAK character
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).	If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queuing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately
; preceeding the actual FCB (to contain user # information).  If
; you've used MEX-10 for input instead of BDOS-10 (or you're
; parsing part of a SET command line that's already been input),
; then MEX will take care of DU specs, and set up the FCB
; accordingly.	Thereafter all file I/O calls done through the MEX
; service processor will handle drive and user with no further
; effort necessary on the part of the programmer.
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
LKAHED	EQU	242		; Get next char w/o removing from input
GNC	EQU	241		; Get char from input, cy=1 if none
ILP	EQU	240		; Inline print
DECOUT	EQU	239		; Decimal output
PRBAUD	EQU	238		; Print baud rate
;
CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10
;
	ORG	TPA		; We begin
;
	DS	3		; MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly.  They will
; be moved in MEX 2.0.
;
PMODEM:	DB	NO		; Yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		; Yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'P'		; T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		; Clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	INITBD		; Sets initial baud rate
				; 0=110  1=300	2=450  3=600  4=710
				; 5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		; Default time to send character in
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
BAKFLG:	DB	NO		; Yes=make .BAK file
CRCDFL:	DB	NO		; Yes=default to CRC checking
				; No=default to Checksum checking
TOGCRC:	DB	YES		; Yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		; Yes=convert backspace to rub
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub
ADDLF:	DB	NO		; No=no LF after CR to send file in
				; Terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR
TRNLOG:	DB	NO		; Yes=allow transmission of logon
				; Write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP
LOCNXT:	DB	NO		; Yes=local cmd if EXTCHR precedes
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
	DS	2		; Not used
;
; Low-level modem I/O routines: this will be replaced with a jump table
; in MEX 2.0 (You can insert jumps here to longer routines if you'd
; like.  I'd recommend NOT putting part of a routine in this area, then
; jumping to the rest of the routine in the non-fixed area; that will
; complicate the 2.0 conversion.)
;
;				; MODCTL is modified by set command
INCTL:	IN	MODCTL		; In modem control port
	RET			;
;				; MODCTL is modified by set command
OUTCTL:	OUT	MODCTL		; Out modem control port
	RET
	DB	0,0,0,0		; Spares if needed
;
;				; MODDAT is modified by set command
OTDATA:	OUT	MODDAT		; Out modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed
;
;				; MODDAT is modified by set command
INDATA:	IN	MODDAT		; In modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI	MDRCVB ! RET	; Bit to test for receive ready
TESTR:	CPI	MDRCVR ! RET	; Value of receive bit when ready
MASKS:	ANI	MDSNDB ! RET	; Bit to test for send ready
TESTS:	CPI	MDSNDR ! RET	; Value of send bit when ready
;
; Unused area: was once used for special PMMI functions, Now used
; only to retain compatibility with MDM overlays.  You may use this
; area for any miscellaneous storage you'd like but the length of
; the area *must* be 12 bytes.
;
	DS	12
;
; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.
;
LOGON:	DS	2		; Needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		; Dial digit in A (see info at PDIAL)
DISCV:	JMP	MDISC		; Disconnect the modem
GOODBV:	RET	! NOP !	NOP	; Called before exit to CP/M
INMODV:	JMP	NITMOD		; Initialization. Called at cold-start
NEWBDV:	JMP	SBAUD		; Set baud rate
NOPARV:	DS	3		; Set for no parity (called after transfer)
PARITV:	DS	3		; Set modem parity (called before transfer)
SETUPV:	JMP	SETCMD		; SET command
SPMENV:	DS	3		; Not used with MEX
VERSNV:	JMP	SYSVER		; Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		; Send a break
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
; Clear/screen and clear/end-of-screen. Each routine must use the full
; 9 bytes alloted (may be padded with nulls).
;
; These routines (and other screen routines that MEX 2.0 will support)
; will be accessed through a jump table in 2.0, and will be located in
; an area that won't tie the screen functions to the modem overlay
; (as the MDM format does).
;
	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
	LXI	D,CLSMSG	; Null unless patched
	MVI	C,PRINT
	CALL	MEX
	RET
;
;	*** END OF FIXED FORMAT AREA ***
;
; Modem initialization.
;
NITMOD:	MVI	A,RESET1	; Initialize 8251 chip
	CALL	OUTCTL
	MVI	A,RESET1	; Initialize 8251 chip again
	CALL	OUTCTL
	LDA	MSPEED		; Fall thru to set initial baud rate
;
; Set Baud Rate.
;
; New baud-rate code in A.
; NOTE: this routine (ie, the one vectored through NEWBDV) should
; update MSPEED with the passed code, but ONLY if that rate is
; supported by the hardware.
;
;	 A=0:	110 baud       A=1:   300 baud	    A=2:   450 baud
;	 A=3:	600 baud       A=4:   710 baud	    A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud	    A=8:  9600 baud
;
SBAUD:	PUSH	H		; Don't alter anybody
	PUSH	D
	PUSH	B
	MOV	C,A		; Save baud rate code
	MVI	B,0		; Use BC as index to table
	LXI	H,BTABL		; Get baudrate value
	DAD	B		; Add the index value
	MOV	A,M		; Get the value from table
	CPI	NA		; See if baud rate valid
	STC			; Set for not valid
	JZ	NOTVAL		; Not valid
;
	LXI	H,PARITY	; Baud rate and parity are in save byte
	ORA	M		; Put in parity and data length
	PUSH	PSW		; First reset the UART
	MVI	A,RESET2
	CALL	OUTCTL
	XTHL			; Delay -- must be in pairs
	XTHL
	POP	PSW
	CALL	OUTCTL
	MOV	A,C
	STA	MSPEED		; Save new baud rate code
	MVI	A,CHIPSET	; Set chip for I/O
	CALL	OUTCTL
	XRA	A		; Clear carry flag
NOTVAL:	POP	B		; Restore the registers and return
	POP	D
	POP	H
	RET
;
; Send-break routine.
;
SBREAK:	MVI	A,BREAK		; Output the break code
	CALL	OUTCTL		; To the control port
	MVI	B,2		; Wait 200 ms
	JMP	MDISC1		; Go wait, and return
;
; Disconnect the modem (this routine is not used if MXO-SMxx is installed).
;
MDISC:	MVI	A,DISCNT	; Hang up
	CALL	OUTCTL
	MVI	B,20		; Wait for modem to disconnect (2 sec)
MDISC1:	MVI	C,TIMER
	CALL	MEX		; Use MEX timer routine
	MVI	A,CHIPSET	; Reset modem
	JMP	OUTCTL		; Out to control port and return
;
; SET command processor.
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	MVI	C,SBLANK	; Any arguments?
	CALL	MEX
	JC	SETSHO		; If not, go print out values
	LXI	D,CMDTBL	; Parse command
	CALL	TSRCH		; From table
	PUSH	H		; Any address on stack
	RNC			; If we have one, execute it
	POP	H		; Nope, fix stack
SETERR:	LXI	D,SETEMS	; Print error message
	JMP	MPRINT		; Print message and return
;
; SET <no-args>: print current statistics.
;
SETSHO:	CALL	BDSHOW		; For active baud rate
	CALL	PSHOW		; For active parity
	CALL	SSHOW		; For number of stop bits
	CALL	DSHOW		; For type of dialing
	CALL	PTSHOW		; For active port
	RET			; Return
;
; SET ?  processor.
;
STHELP:	LXI	D,HLPMSG	; Print HELP message
	JMP	MPRINT		; Print message and return
;
; SET BAUD processor.
;
STBAUD:	MVI	C,BDPARS	; Function code
	CALL	MEX		; Let MEX look up code
	JC	SETERR		; Invalid code
	CALL	SBAUD		; No, try to set it
	JC	SETERR		; Not-supported code
BDSHOW:	CALL	ILPRT		; Display baud
	DB	CR,LF,'Baud rate:  ',0
	LDA	MSPEED
	MVI	C,PRBAUD	; Use MEX routine
	JMP	MEX		; And return
;
; SET STOP BIT processor.
;
STSTOP:	LXI	D,STOPTBL	; Lookup input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	LDA	PARITY		; Get the parity byte
	ANI	03FH		; Wipe out old stop bit value
	ORA	L		; Get new stop bit value
	STA	PARITY		; Store it for NITMOD
	LDA	MSPEED		; Get current baud rate
	CALL	SBAUD		; Set parity and stop bits
;
SSHOW:	LDA	PARITY		; Get the parity and stop bits
	LXI	D,SMSG1		; Message for 1 stop bit
	ANI	080H		; Is it 1 or 2 bits
	JZ	SSHOW1		; 1 bit, go print
	LXI	D,SMSG2		; 2 bit message
SSHOW1:	JMP	MPRINT		; Print number of stop bits and return
;
; SET PARITY processor.
;
STPAR:	LXI	D,PARTBL	; Lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	LDA	PARITY		; Get old parity/stop bits
	ANI	0C0H		; Wipe out parity
	ORA	L		; Get parity code
	STA	PARITY		; Store it for NITMOD
	LDA	MSPEED		; Get current baud rate
	CALL	SBAUD		; Set parity
;
PSHOW:	CALL	ILPRT		; Show parity
	DB	CR,LF,'Parity:     ',0
	LXI	H,PARFND	; Find proper message
	LDA	PARITY		; Get parity value
	ANI	07FH		; Drop stop bits
	MOV	B,A		; Save it
FNDP:	MOV	A,M		; See if parity value matches
	ORA	A		; First see if zero
	JZ	SETERR		; Should never get here
	CMP	B		; Match?
	INX	H		; Point to first letter of message
	JZ	CDISP		; Matches, type message
FNDNXT:	MOV	A,M
	ORA	A		; See if end of last message
	INX	H
	JP	FNDNXT		; Not finished
	INX	H		; Increment past parity byte
	JMP	FNDP
;
; Dialing Mode Processor.
;
STTONE:	MVI	A,'T'		; Indicate tone dialing
	JMP	STDIAL		; Go store it
STPULSE:MVI	A,'P'		; Indicate tone dialing
STDIAL:	STA	TPULSE		; Store in MEX parms
;
DSHOW:	LDA	TPULSE		; Get the Dialing code
	LXI	D,PMSG		; Pulse dialing message
	CPI	'P'		; Is it Pulse
	JZ	DTONE		; Yes, go print
	LXI	D,TMSG		; Tone dialing message
DTONE:	JMP	MPRINT		; Print dialing type and return
;
; Set PORT processor.
;
STPORT:	LXI	D,PORTTBL	; Lookup input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	MOV	A,L		; Get new data port number
	STA	OTDATA+1	; Modify instruction
	STA	INDATA+1	; Modify instruction
	INR	A		; Control port is one greater than data port
	STA	INCTL+1		; Modify instruction
	STA	OUTCTL+1	; Modify instruction
	MOV	A,H		; ASCII port returned in H
	STA	PORTA		; Store in print message
	CPI	'2'		; Set up for console
	JZ	PTSHOW		; Do not initialize the console we are using
	CALL	NITMOD		; Initialize the net port
PTSHOW:	LXI	D,PORTM		; Get message to tell port number
	JMP	MPRINT		; Print port number and return
;
GOHL:	PCHL
;
;  Print message ending with 80H bit set.
;
CDISP:	MOV	A,M		; Get character to print
	INX	H		; Point to next character
	PUSH	PSW		; Save 80H bit
	ANI	7FH		; Strip 80H bit just in case
	MOV	E,A		; Move to "E" for CONOUT
	MVI	C,CONOUT	; CONOUT routine
	CALL	MEX
	POP	PSW		; Restore character
	ORA	A		; Check high order bit
	JM	CRLF		; Finished
	JMP	CDISP		; Loop till finished
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	; Get function code
	JMP	MEX		; Pass to MEX processor
;
; Print in-line message ... blows away C register.
;
CRLF:	CALL	ILPRT
	DB	CR,LF,0
	RET
;
ILPRT:	MVI	C,ILP		; Get function code
	JMP	MEX		; Go do it
;
; Sign-on message (MPRINT is used as print subroutine).
;
SYSVER:	LXI	D,SOMESG	; Sign on message to show version of overlay
MPRINT:	MVI	C,PRINT		; This label will be used as print subroutine
	JMP	MEX		; Let MEX print message and return
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
	DB	'STOPBI','T'+80H ; "set number of stop bits"
	DW	STSTOP
	DB	'TON','E'+80H	; "set tone dialing"
	DW	STTONE
	DB	'PULS','E'+80H	; "set pulse dialing"
	DW	STPULSE
	DB	'POR','T'+80H	; "set port number"
	DW	STPORT
;
	DB	0		; <<=== table terminator
;
; Baud rate table
;
BTABL:	DB	NA		; -	0	 110
	DB	3		; X64	1	 300
	DB	NA		; -	2	 450
	DB	NA		; -	3	 600
	DB	NA		; -	4	 710
	DB	2		; X16	5	1200
	DB	3		; -	6	2400
	DB	NA		; -	7	4800
	DB	2		; -	8	9600
	DB	0		; X01	9      19200
;
; PARITY argument table
; Format of the table is:  Starting at PARTBL, the name is
; given (ending with 80H bit set), then the one byte code
; for setting that parity.  The next byte will duplicate the
; NEXT parity code (used in PSHOW).  The byte at PARFND
; will duplicate the first parity code.
;
PARFND:	DB	EVEN
PARTBL:	DB	'EVE','N'+80H	; Even parity, 7 data bits
	DB	EVEN,EVEN8
	DB	'EVEN','8'+80H	; Even parity, 8 data bits
	DB	EVEN8,ODD
	DB	'OD','D'+80H	; Odd parity, 7 data bits
	DB	ODD,ODD8
	DB	'ODD','8'+80H	; Odd parity, 8 data bits
	DB	ODD8,NONE
	DB	'NON','E'+80H	; No parity, 8 data bits
	DB	NONE,0
;
	DB	0		; <<== table terminator
;
; Stop bit messages
;
SMSG1:	DB	'1 stop bit',CR,LF,'$'
SMSG2:	DB	'2 stop bit',CR,LF,'$'
;
; Parity control byte location.
;
PARITY:	DB	NONE		; Default parity to "no parity"
;
PORTM:	DB	'Using port '
PORTA:	DB	'4',CR,LF,LF,'$'
;
; Table of valid port numbers.
;
PORTTBL:DB	'0'+80H,0,'0'
	DB	'2'+80H,2,'2'
	DB	'4'+80H,4,'4'
	DB	0
;
; Table of valid stop bit values.
;
STOPTBL:DB	'1'+80H,040H,'1'
	DB	'2'+80H,0C0H,'2'
	DB	0
;
; Strings to clear-to-end-of-screen, and clear-screen.
;
EOSMSG:	DB	EOS,'$'		; Clear to end-of-screen
CLSMSG:	DB	CLS,'$'		; Clear whole screen
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
PMSG:	DB	'Pulse dialing',CR,LF,'$'
TMSG:	DB	'Tone dialing',CR,LF,'$'
;
; The help message.
;
HLPMSG:	DB	CR,LF,'SET command:',CR,LF
;
	DB	CR,LF,'SET BAUD 300 <or> 1200'
	DB	CR,LF,'SET PARITY EVEN[8] <or> ODD[8] <or> NONE'
	DB	CR,LF,'SET STOPBIT 1 <or> 2'
	DB	CR,LF,'SET TONE'
	DB	CR,LF,'SET PULSE'
	DB	CR,LF,'SET PORT 0 <or> 2 <or> 4'
	DB	CR,LF		; Will also print overlay version
;
; Sign on Message.
;
SOMESG:	DB	'using ALSPA Overlay - Version '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD	10+'0',' - 12/28/84',CR,LF,LF,'$'
;
; End of ALSPA MEX modem overlay.
;
	END
