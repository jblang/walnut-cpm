; MXO13PX8  MEX overlay for Epson PX-8			    Oct 18. 1985
;
; (delete the ";" in the above title line if assembling with MAC)
;
;
REV	EQU	12		; Overlay revision level
;
; MEX overlay for Epson PX-8 with MFU, Direct Connect modem, or external
; modem.  Support is provided for an external dialing overlay such as
; MXO-SM13.ASM. For details see MXO-PX8.DOC.
;
; Written 3/10/85 by David B. Kozinn
;
;	Copyright (C) 1985 by David B. Kozinn
;
; This program (in source or object code form) may be copied and distri-
; buted for non-commercial purposes.  Sale of this program is forbidden
; without written consent of the author.
;
; The author can be contacted on CompuServe [76703,565] via Easyplex, or
; (preferably) in CP-MIG (PCS-47) or EpsOnline (PCS-19).
;
;     PLEASE READ THE FOLLOWING IF YOU INTEND TO MODIFY THIS OVERLAY:
;     ---------------------------------------------------------------
; Much of the commentary has been removed in order to save space.  For
; complete documentation of how an overlay is structured, see the origi-
; nal overlay, MXO-PM.ASM, written by Ron Fowler.  Please be sure to
; read the comments in that overlay if you intend to change this one.
;
;	Version Date	Changes
;	------- ------- -------
;	  1.2	870502	Fixed another bug in the SET COMM command that
;			kept the uart from being properly set when using
;			the internal modem.  Also added pulse dial capa-
;			bility.  Removed all references to the letters
;			A-D in the tone dialing area to make room.
;					- Bob Kitchen
;
;	  1.1	870301	Fixed bugs in the SET COMM command so that the
;			correct values for "even" parity and "2" stop
;			bits were sent to the RS-232 device.  Also fixed
;			the problem with the screen not keeping up when
;			running at 1200 baud.
;					- Bob Kitchen
;
;	  1.0	850310	First general release version
;
;-----------------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
;
;
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
BELL	EQU	7
ESC	EQU	01BH
CUROFF	EQU	032H
CURON	EQU	033H
XON	EQU	011H
XOFF	EQU	013H
;
; PX-8 port definitions
;
MCTLR2	EQU	002H		; Misc control signals (output)
CCR	EQU	00DH		; 8251 command port
DCRREG	EQU	084H		; Modem tone dialer control port (output)
OCR	EQU	085H		; Modem control register (output)
STR	EQU	086H		; Modem status register (input)
OMR	EQU	087H		; Modem port setup (output)
;
; PX-8 Special locations (see code for use)
;
WBLOC	EQU	0EC03H		; BIOS call Warm Boot location
WRSDAT	EQU	0F6A9H		; Working RS-232 data
CTLR1	EQU	0F0B0H		; CTLR1 register value
CTLR2	EQU	0F0B2H		; CTLR2 register value
RSMODE	EQU	0F6D0H		; 8251 Mode byte location
RSCMD	EQU	0F6D1H		; 8251 Command byte location
RSOPN	EQU	0F2C8H		; RS-232 open flag (00=Open)
SLVFLG	EQU	0F358H		; Slave cpu (6301) flag
INTBUF	EQU	0FB90H		; Internal rs232 buffer
INTBUFL	EQU	0160H		; Internal buffer length
;
; Bit definitions
;
MDMINIT	EQU	089H		; 8251 initialization string
BRKBIT	EQU	008H		; 8251 bit to turn break on
MDRCVB	EQU	001H		; Modem receive bits
MDRCVR	EQU	001H		; Modem recieve ready
MDSNDB	EQU	002H		; Modem send bits
MDSNDR	EQU	002H		; Modem recieve ready
USEINT	EQU	020H		; Set to 0, send this to CTLR2 to use int.
DCD	EQU	008H		; Use with RSIOX CTLIN
;
; Bit definitions for OCR
;
OHC	EQU	001H		; Off hook
HSC	EQU	002H		; Handset control
MON	EQU	004H		; Enable speaker
TXC	EQU	008H		; Transmit carrier
ANS	EQU	010H		; Answer mode
TEST	EQU	020H		; Test function
PWR	EQU	040H		; Modem Power
CCT	EQU	080H		; Connect to phone lne
;
; Bit definitions for STR
;
BDS	EQU	001H		; Bell Detect Signal. 0 if ringing
CTSMSK	EQU	004H		; Clear to send. (carrier det) =0 if clear
MII	EQU	080H		; Modem Installation Indicator 0=installed
;
; Special BIOS call locations
;
CONIN	EQU	WBLOC+006H	; Direct console input
CONOUT	EQU	WBLOC+009H	; Direct console output
RSOPEN	EQU	WBLOC+039H	; Open RS-232 port
RSCLOSE	EQU	WBLOC+03CH	; Close RS-232	port
RSINST	EQU	WBLOC+03FH	; Check for input
RSOUTST	EQU	WBLOC+042H	; Check for output
RSIN	EQU	WBLOC+045H	; Get a character
RSOUT	EQU	WBLOC+048H	; Send a character
RSIOX	EQU	WBLOC+051H	; Special RS-232 calls
SLAVE	EQU	WBLOC+072H	; Use slave CPU
;
; Equates for use with RSIOX
;
OPNIOX	EQU	010H		; Open using RSIOX
CLSIOX	EQU	020H		; Close using RSIOX
INSTS	EQU	030H		; Check for data in recieve buffer
CTLIN	EQU	070H		; Check carrier & DSR
;
; MEX locations
;
QUEUE	EQU	00D51H		; Queued I/O variable
MODE	EQU	00D54H		; Terminal mode byte (01 = in terminal mode)
SMART	EQU	00B00H		; Entry point for smart modem overlay
;
; Other equates
;
WTCTS	EQU	125		; How long to wait for carrier. 125=25 seconds
;
; MEX service processor stuff
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
;
NOSMART	EQU	NO		; Yes=no Smartmodem dialing overlay
;
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10
;
	 IF	NOSMART
	ORG	SMART		; Put code in in case he calls Smartmodem
	CPI	255		;   without installing the overlay first
	RNZ			; Only do it once, at the end
	CALL	ILPRT
	DB	'** You have not installed a dialing overlay **'
	DB	BELL,CR,LF,0
	XRA	A		; Set zero flag
	MVI	A,3		; Tell him dialing has been aborted
	RET
	 ENDIF
;
;
	ORG	TPA		; We begin
;
;
	DS	3		; MEX has a JMP START here
;
; The following variables are located at the beginning of the program to
; facilitate modification without the need of re-assembly.
;
PMODEM:	DB	NO		; Yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	NO		; Yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		; T=tone, P=pulse (tone or pulse dial flag)
CLOCK:	DB	28		; Clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		; Sets display time for sending a file
				; 0=110  1=300	2=450  3=600  4=710
				; 5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	1		; Default time to send character in
				; Terminal mode file transfer (0-9)
				; 0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	1		; End-of-line delay after CRLF in terminal
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
XOFTST:	DB	YES		; Yes=allow testing of XOFF from remote
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
; The next two are for PMMI, we don't use them, but they have to hang
; around anyway.
;
	DB	250
	DB	0
;
; Low-level modem I/O routines
;
INCTL1:	JMP	MODSTAT		; In modem control port
	DB	0,0,0,0,0,0,0	; Spares
;
OTDATA:	JMP	MODOUT		; Out modem data port
	DB	0,0,0,0,0,0,0	; Spares
;
INPORT:	JMP	MODIN		; In modem data port
	DB	0,0,0,0,0,0,0	; Spares
;
; Bit-test routines
;
MASKR:	ANI	MDRCVB ! RET	; Bit to test for receive ready
TESTR:	CPI	MDRCVR ! RET	; Value of receive bit when ready
MASKS:	ANI	MDSNDB ! RET	; Bit to test for send ready
TESTS:	CPI	MDSNDR ! RET	; Value of send bit when ready
;
;
; Unused area: was once used for special PMMI functions, now used only
; to retain compatibility with MDM overlays.  You may use this area for
; any miscellaneous storage you'd like but the length of the area *must*
; be 12 bytes.
;
	DS	12
;
; Special modem function table
;
LOGON:	DS	2		; Needed for MDM compat, not ref'd by MEX
DIALV:	JMP	PDIAL		; Dial digit in A (see info at PDIAL)
DISCV:	JMP	PDISC		; Disconnect the modem
GOODBV:	DS	3		; Called before exit to CP/M
INMODV:	JMP	NITMOD		; Initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		; Set baud rate
NOPARV:	DS	3		; Set modem for no-parity
PARITV:	DS	3		; Set modem parity
SETUPV:	JMP	SETCMD		; SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		; Not used with MEX
VERSNV:	JMP	SYSVER		; Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK		; Send a break
;
; Entry points here are for compatibility with MDM7
;
ILPRTV:	DS	3		; Replace with MEX function 9
INBUFV:	DS	3		; Replace with MEX function 10
ILCMPV:	DS	3		; Replace with table lookup funct. 247
INMDMV:	DS	3		; Replace with MEX function 255
NXSCRV:	DS	3		; Not supported by MEX (returns w/no action)
TIMERV:	DS	3		; Replace with MEX function 254
;
; Clear/screen and clear/end-of-screen.  Each routine must use the full
; 9 bytes alloted (may be padded with nulls).
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG	; Null unless patched
	MVI	C,PRINT
	CALL	MEX
	RET
;
	XRA	A		; Don't allow queued I/O (it interferes
				; With the stuff we're doing)
	STA	QUEUE		; Set to Queued I/O flag location
;
;-----------------------------------------------------------------------
;
;		*** END OF FIXED FORMAT AREA ***
;
;-----------------------------------------------------------------------
;
; Modem initialization.  First make sure that the dialing overlay ad-
; dress is correct (some overlays ORG the dial vector and stick a JMP
; B00 there.)  We have to make sure that we get control first.	Also,
; store away the current value in the DISCV address, because it might be
; the address of the dialing overlay disconnect vector.  We'll use this
; to disconnect along with the regular disconnect code if an external
; modem is being used.	Then, set up the default communications parame-
; ters.  Then, if the port is already open, just return, else set up to
; use the built-in modem.
;
NITMOD:	LXI	H,PDIAL		; Get address of our dialing routine
	SHLD	DIALV+1		; Store it as the address to jump to
	LHLD	DISCV+1		; Get address of disconnect vector
	SHLD	SMDISCV+1	; Save it in case it's needed
	LXI	B,PDISC		; Get our disconnect routine address
	XRA	A		; Clear carry flag
	DB	0EDH,042H	; SBC HL,BC If zero, then the same
	JZ	NIT0		; Don't do anything special
	DCR	A		; Get 0FFH to store
	STA	GOTDISC		; Indicate that we've got external disc
	LXI	H,PDISC		; Get the address of our disconnect routine
	SHLD	DISCV+1		; Store it in the proper place
;
NIT0:	LXI	H,WRSDAT	; Get working rs232 data
	LXI	D,BAUDRATE
	LXI	B,4
	DB	0EDH,0B0H	; LDIR
	LDA	BAUDRATE	; Find out what baud we're set to
	LXI	H,BAUDTBL
	MVI	B,0
;
NIT1:	CMP	M		; Do we match this table entry?
	JZ	NIT2		; Yes
	INX	H
	INR	B
	JMP	NIT1
;
NIT2:	MOV	A,B		; Store the table entry locally
	STA	MDMSPD
	CALL	SMSPEED		; Set modem speed for time for xfer
	LDA	RSOPN		; See if the port is already open
	ORA	A
	RZ			; Don't do anything if so
	CALL	RSOPEN		; Turn the port on
	CALL	PWRON		; Try to turn the modem on
	IN	STR		; Read status register
	ANI	MII		; Is modem installed?
	JNZ	OPENIT		; No, open the RS-232 port normally
	CALL	STPORT		; Set up to use the direct connect
	LDA	OCRVAL		; Turn off modem power to conserve
	ANI	(NOT PWR) AND 0FFH
	STA	OCRVAL
	OUT	OCR
	MVI	A,0FFH		; Indicate we're using the internal modem
	STA	MDMTYPE
	RET
;
OPENIT:	CALL	RSCLOSE		; Close the port to clean things up
	CALL	RSOPEN		; Open it up for the regular port
	RET
;
; Send-break routine
;
PBREAK:	LDA	RSCMD		; Get the current command for the 8251
	ORI	BRKBIT		; Turn break on
	OUT	CCR		; Send it to the 8251
	MVI	B,3		; Wait 300 ms
	MVI	C,TIMER
	CALL	MEX
	LDA	RSCMD		; Restore the 8251 to normal
	OUT	CCR
	RET
;
; Disconnect the modem
;
PDISC:	LDA	MDMTYPE		; See if we're using an external modem
	ORA	A		; This will be zero if so
	JNZ	PDISC0		; If not, don't worry about it
	LDA	GOTDISC		; See if we had an external routine
	ORA	A		; This will be non-zero if so
	JNZ	SMDISCV		; Call it if it's there
;
PDISC0:	CALL	RSCLOSE
	LDA	OCRVAL		; Get current modem control values
	ANI	0FFH-(CCT+TXC+OHC) ; On-hook, carrier off,disconnect
	OUT	OCR		; Send it
	ANI	(NOT PWR) AND 0FFH ; Now turn power off too
	OUT	OCR
	STA	OCRVAL		; Save this as current mod. ctl. value
	CALL	RESPORT		; Reset to use internal
	CALL	SPKROFF		; Turn the speaker off
	CALL	RSOPEN
	RET
;
; External dialing routine disconnect code is called through here.
;
SMDISCV:JMP	PDISC		; <-----This may be modified
;
;-----------------------------------------------------------------------
;
;			DIALING ROUTINES
;
; The DIGITS table is a translation for digit to register value for all
; of the supported tone digits.  The modem also understands that a com-
; ma (,) means to wait for n seconds before continuing (for compatabil-
; ity with various intelligent modems).  Any other values (such as -,
; (, or ) ) are ignored.  For pulse dialing, only the digits 0-9 are
; used, all else, except a comma, is ignored.
;
DIGITS:	DB	1DH,10H,11H,12H	; 0, 1, 2, 3
	DB	14H,15H,16H,18H	; 4, 5, 6, 7
	DB	19H,1AH		; 8, 9
;
SPLAT:	DB	1CH		; *
;
CRUNCH:	DB	1EH		; #
;
PDIAL:	MOV	B,A		; Save the digit
	LDA	MDMTYPE		; See if we're using an external modem
	ORA	A
	MOV	A,B		; Restore the digit
	JZ	SMART		; If so, jump to the Hayes routines
	CPI	254		; Start-dial?
	JZ	STDIAL
	CPI	255		; End-dial
	JZ	ENDIAL
	CPI	','		; Smartmodem pause command
	JNZ	CKDIG		; If not pause, continue
	LDA	COMDLY		; Delay n seconds
	MOV	B,A
	ADD	A		; X 2
	ADD	A		; X 4
	ADD	A		; X 8
	ADD	B		; X 9
	ADD	B		; X 10
	MOV	B,A
	MVI	C,TIMER
	CALL	MEX
	RET
;
CKDIG:	CPI	'9'+1		; Digits are 0-9
	RNC			; Too big...return
	SUI	'0'
	JC	CKSPEC		; Too small....check if it's * or #
	PUSH	A
	LDA	TPULSE		; Check to see if tone or pulse
	CPI	'P'
	JZ	PUDIAL		; Go to pulse dial routines
	POP	A
	LXI	H,DIGITS	; Get start of digits table
	JMP	DIALIT
;
CKSPEC:	LXI	H,SPLAT		; Check for specials
	CPI	('*'-'0') AND 0FFH ; Is it *?
	JZ	DIALIT1		; Yup, go dial
	INX	H		; Point to CRUNCH
	CPI	('#'-'0') AND 0FFH ; Is it #?
	RNZ			; No, forget it
	JMP	DIALIT1		; Yup, go dial
;
; First get the value to send to the tone control register.  At DIALIT,
; HL contains the proper table, and A contains the offset into that table.
;
DIALIT:	MVI	B,0
	MOV	C,A		; Get offset into BC
	DAD	B		; Get real byte location into HL
;
DIALIT1:LDA	TPULSE		; Check for tone or pulse
	CPI	'P'
	RZ			; Return if pulse
	MOV	A,M		; Get value to dial into A
	OUT	DCRREG		; Start sending the tone
	MVI	B,1		; Send it for 100ms (which is kinda long
	MVI	C,TIMER		; But it's easier than coding my own timing
	CALL	MEX		; Routine.)
	XRA	A
	OUT	DCRREG		; Turn tone off
	MVI	B,1		; Wait for 100ms for the inter-digit delay
	MVI	C,TIMER
	CALL	MEX
	RET
;
; Pulse dialing routines (one pulse is 60ms onhook followed by 40ms off-
; hook).
;
PUDIAL:	POP	A
	CPI	0
	JNZ	PUDIAL1		; Jump if not equal to zero
	MVI	A,0AH		; 0 is 10 for pulse dialing
;
PUDIAL1:CALL	ST60		; Onhook for 60ms
	CALL	ST40		; Offhook for 40ms
	DCR	A
	CPI	0
	JNZ	PUDIAL1		; Repeat per value of each digit
	MVI	B,7		; 700ms between digits
	MVI	C,TIMER
	CALL	MEX
	RET
;
STDEL:	DCX	B		; Time delay subroutine for
	MOV	A,B		; Producing the correct pulse
	ORA	C		; Lengths
	JNZ	STDEL
	RET
;
ST60:	PUSH	A
	LDA	OCRVAL		; Connect to phone, offhook, speaker on
	ANI	(NOT OHC) AND 0FFH ; Onhook
	OUT	OCR
	LXI	B,6000		; 60ms onhook
	CALL	STDEL
	POP	A
	RET
;
ST40:	PUSH	A
	LDA	OCRVAL		; Connect to phone, offhook, speaker on
	OUT	OCR
	LXI	B,4000		; 40ms offhook
	CALL	STDEL
	POP	A
	RET
;
; Start-dial sequence:	Go thru normal init sequence, assuming that the
; guy is not trying to dial while connected.  (This should disconnect
; him anyway).
;
STDIAL:	CALL	PDISC		; Disconnect
	LDA	OCRVAL		; Turn on monitor soon
	ORI	MON
	STA	OCRVAL
	CALL	RESPORT		; I don't know why, but I gotta do this
	CALL	PWRON		; Init modem and ports
	CALL	SPKRON		; Turn power to speaker on
	LDA	OCRVAL		; Get current value for OCR
	ANI	(NOT ANS) AND 0FFH ; Set originate mode
	STA	OCRVAL
	OUT	OCR
OFFHK:	LDA	OCRVAL		; Have to reload 'cause we're called directly
	ORI	CCT		; Connect to phone
	OUT	OCR
	ORI	OHC		; Go off hook
	OUT	OCR
	STA	OCRVAL
	MVI	B,20		; Wait 2 seconds for dial tone
	MVI	C,TIMER
	CALL	MEX
	RET			; Dialing init done
;
; End-dial sequence: Watch to see if CTS goes on within 50 seconds.   If
; so, turn on carrier, turn speaker off, and connect to the line.
;
ENDIAL:	LDA	OCRVAL		; Turn on carrier
	ORI	TXC
	OUT	OCR
	STA	OCRVAL
	CALL	STPORT
	MVI	E,WTCTS		; # of ms * 5 to wait
;
LP1:	MVI	B,2		; 200 ms.
	MVI	C,TIMER
	CALL	MEX
	IN	STR		; Check modem status register
	ANI	CTSMSK		; See if we've got carrier yet
	JZ	GOTCAR		; If it's zero, then we've got carrier
	MVI	C,CHEKCC	; Not yet, see if he hit ctl-c
	CALL	MEX
	MVI	A,3		; Get ready to return code
	JZ	NOCAR		; Yup, return
	DCR	E		; Nope, count down
	JNZ	LP1		; Keep going if more time
	MVI	A,2		; Set code in A to 2 (no answer)
;
NOCAR:	PUSH	PSW		; Save the return code
	CALL	PDISC		; Hang up
	POP	PSW		; Get the return code back
	RET
;
; GOTCAR - Come here to go on-line, we've got a carrier from remote
;
GOTCAR:	CALL	SPKROFF		; Turn the speaker off
	XRA	A		; Report that we got carrier
	RET
;
;		  <end of PX-8 dialing routines>
;-----------------------------------------------------------------------
;
PBAUD:	RET			; Use SET COMM for this
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
	RET
;
SOMESG:	DB	'Epson PX-8 overlay V'
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD	10+'0'
	DB	CR,LF,'$'
;
; Input from the status port.  Since the PX-8 has 2 status ports, and
; we can't tell why we're being call (for input or output), we have to
; kludge here.	We'll call both in & out status, and fake a 1 byte sta-
; tus word.  See the MOD??? bytes for the values. Also, we check here
; to see if carrier has been lost (only if we were using the modem.)  If
; so, then we'll disconnect from the phone line, reset the port and tell
; the user.
;
;	 NOTE:	There is really no need for output status, so
;		these routines always return "ready to output".
;		However, the basic code structure to support
;		both input and output status has been left in
;		should it ever be necessary.
;
; Automatic X-ON/X-OFF flow control is also done from this point.
;
;	 NOTE:	For the automatic X-ON/X-OFF flow control to
;		work properly, ASIZE: must be set to 255h at
;		memory location 0D22h.	If not, use MEXPAT.ASM
;		to reset the buffers.
;
MODSTAT:PUSH	B		; Push all registers (except A)
	PUSH	D
	PUSH	H
	LDA	CTLR2		; See if we're using an MFU
	ANI	USEINT
	JNZ	MDSTAT1		; If not, forget about it
	IN	STR		; Else check modem status register
	ANI	CTSMSK
	JZ	MDSTAT1		; Everything Ok if it's there
	CALL	PDISC		; Otherwise hang up
	CALL	ILPRT		; And say something about it
	DB	CR,LF,'** Carrier Lost **',BELL,CR,LF,0
;
MDSTAT1:LDA	MODE		; Get terminal mode
	CPI	1		; 01 means in terminal mode
	JNZ	MDSTAT4		; If not, then don't worry about it
;
MDSTAT2:MVI	B,INSTS		; Check for characters in input buffer
	LXI	H,WIPEOUT	; Here's where to put the returned info
	CALL	RSIOX
	JNZ	MDSTAT2		; Wait until we get good status
	XRA	A		; Clear carry
	LXI	H,200		; 3/4 full buffer
	DB	0EDH,042H	; SBC HL,BC
	JNC	MDSTAT3		; Continue if < 200 chars in buffer
	LDA	PENDXOFF	; Is there an XOFF outstanding already?
	ORA	A		; It'll be 0 if not
	JNZ	MDSTAT4		; If so, then just go ahead
	MVI	C,XOFF		; Send out an XOFF
	CALL	RSOUT
	XRA	A
	DCR	A
	STA	PENDXOFF	; Indicate a pending XOFF
	JMP	MDSTAT4		; Continue
;
MDSTAT3:MVI	B,INSTS		; Check input again, this time we're
	LXI	H,WIPEOUT	; Seeing if it's time to send an XON
	CALL	RSIOX
	JNZ	MDSTAT3
	XRA	A
	LXI	H,50
	DB	0EDH,042H	; SBC HL,BC
	JC	MDSTAT4		; Don't send XON until < 50 chars in buffer
	LDA	PENDXOFF	; Ok, we've got < 50, did we send an XOFF?
	ORA	A
	JZ	MDSTAT4		; No, so don't do anything
	MVI	C,XON
	CALL	RSOUT		; Send the XON
	XRA	A
	STA	PENDXOFF
;
MDSTAT4:CALL	RSINST		; Now get status
	ANI	MDRCVB		; Mask off what we don't care about
	ORI	MDSNDB		; Always say that output is ready
;
POPEM:	POP	H
	POP	D
	POP	B
	RET
;
; Get a character
;
MODIN:	PUSH	B
	PUSH	D
	PUSH	H
	MVI	B,INSTS
	LXI	H,STATBLK
	CALL	RSIOX		; Make sure there is really data so we
	ORA	A		; Don't ever hang waiting
	JZ	MODIN1
	CALL	RSIN
;
MODIN1:	POP	H
	POP	D
	POP	B
	RET
;
; Send a character
;
MODOUT:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A
	CALL	RSOUT
	POP	H
	POP	D
	POP	B
	RET
;
; Type character in A on console
;
TYPE:	PUSH	H		; Save 'em
	PUSH	D
	PUSH	B
	MOV	C,A		; Align output character
	CALL	CONOUT
	POP	B
	POP	D
	POP	H
	RET
;
; SETPORT - set up to use internal modem
;
STPORT:	LDA	CTLR2		; Get current port info
	ANI	(NOT USEINT) AND 0FFH ; Use internal modem
;
SPORT:	STA	CTLR2
	OUT	MCTLR2
	RET
;
; RESPORT - set up to use external modem
;
RESPORT:LDA	CTLR2		; Get current port info
	ORI	USEINT		; Use external modem
	JMP	SPORT		; Store & send to modem
;
; PWRON - Turn power on to the modem (& some other initialization stuff)
;
PWRON:	MVI	A,MDMINIT	; Initialize the 7508
	OUT	OMR
	LDA	OCRVAL		; Get current parameters
	ORI	PWR		; Turn the power on
	OUT	OCR
	STA	OCRVAL		; Save the parameters
	MVI	B,1		; Wait a while to let things settle
	MVI	C,TIMER
	CALL	MEX
	RET
;
; SPKRON - Turn the speaker on
;
SPKRON:	MVI	A,0FFH
	STA	SLVFLG
	LXI	D,SLVPRAM1
	CALL	SLAVE
	RET
;
; SPKROFF - Turn speaker off
;
SPKROFF:LDA	OCRVAL		; Get current params
	ANI	(NOT MON) AND 0FFH ; We're not monitoring anymore
	OUT	OCR
	STA	OCRVAL
	MVI	A,0FFH
	STA	SLVFLG
	LXI	D,SLVPRAM2
	CALL	SLAVE
	RET
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		; Get function code
	JMP	MEX		; Go do it
;
; PLACECUR - Place cursor at row/col specified by BC.
;
PLACECUR:
	PUSH	PSW
	MOV	A,B
	ADI	01FH		; Add in offset
	STA	ROW
	MOV	A,C
	ADI	01FH		; Add in offset
	STA	COL
	CALL	ILPRT
	DB	ESC,'='
;
ROW:	DS	1
;
COL:	DS	1
	DB	0
	POP	PSW
	RET
;
; Keyin - get a character into A
;
KEYIN:	PUSH	B
	PUSH	D
	PUSH	H
	CALL	CONIN		; Direct console input
	POP	H
	POP	D
	POP	B
	RET
;
; UCASE - Convert character in A to uppercase
;
UCASE:	CPI	'a'
	RC			; Return if not lower case
	CPI	'z'+1
	RNC			; Return if > lower case z
	ANI	05FH		; Else change to upper case
	RET
;
; SMSPEED - Set time to transfer speed
;
SMSPEED:LDA	MDMSPD		; Get locally stored speed value
	MOV	C,A		; Put in lower half of BC
	MVI	B,0		; Zap upper half of BC
	LXI	H,XSPDTBL	; Get address of xfer speed table
	DAD	B		; Get address of time for xfer byte
	MOV	A,M		; Get the value
	STA	MSPEED		; Store it
	RET
;
; Data area
;
;
; XSPDTBL - transfer speed table. The number in parenthesis is the value
;	    given to MEX.  This differs from the actual baud rate in
;	    some cases due to the baud rates available on the PX-8.
;
XSPDTBL:  DB	0		; Unused
	  DB	0		; 110 Baud	 (110)
	  DB	0		; 150 Baud	 (110)
	  DB	1		; 300 Baud	 (300)
	  DB	3		; 800 Baud	 (600)
	  DB	5		; 1200 Baud	 (1200)
	  DB	6		; 2400 Baud	 (2400)
	  DB	7		; 4800 Baud	 (4800)
	  DB	8		; 9600 Baud	 (9600)
	  DB	9		; 19200 Baud	 (19200)
;
EOSMSG:	  DB	ESC,'Y','$'	; Clear to end-of-screen
CLSMSG:	  DB	ESC,'*','$'	; Clear whole screen
OCRVAL:	  DB	0		; OCR register value
MDMTYPE:  DB	0		; Modem type, 0FFH=external, 0=internal
GOTDISC:  DB	0		; Got external disconnect routine, FF=Yes
MDMSPD:	  DS	1		; Current port speed
COMDLY:	  DB	2		; #secs to wait for , in dial string
PENDXOFF: DB	0		; 0FFH if XOFF pending, 0 otherwise
STATBLK:  DS	9		; Returned info from RSIOX INSTS call
;
;--------------------Start of slave CPU data----------------------------
;
; The following group of data items are for using the slave CPU.
;
;	DO NOT ADD OR REMOVE ANYTHING IN THIS AREA!!!
;
SLVPRAM1: DW	ONSNDCMD
	  DW	ONSNDLEN
	  DW	ONRETVAL
	  DW	ONRETLEN
;
ONSNDCMD: DB	072H,080H
ONSNDLEN: DB	2
ONRETVAL: DB	1
ONRETLEN: DB	1
SLVPRAM2: DW	OFFSDCMD
	  DW	OFFSDLEN
	  DW	OFFRTVAL
	  DW	OFFRTLEN
OFFSDCMD: DB	072H,0
OFFSDLEN: DB	2
OFFRTVAL: DB	1
OFFRTLEN: DB	1
;
;--------------------End of Slave CPU data------------------------------
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
;
SETERR:	LXI	D,SETEMS	; Print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
CMDTBL:	DB	'?'+80H		; "set ?"
	DW	STHELP
	DB	'OFFHOO','K'+80H ; "set offhook"
	DW	SETOFF
	DB	'COM','M'+80H	; "set comm"
	DW	SETCOMM
	DB	'DELA','Y'+80H	; "set delay"
	DW	SETDLY
	DB	'PULS','E'+80H	; "set pulse"
	DW	SETPUL
	DB	0		; <<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	CALL	CARRSH		; Show carrier present/not present
	LXI	H,SHOTBL	; Get table of SHOW subroutines
;
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
SHOTBL:	DW	SHSEP
	DW	SHHOOK
	DW	SHDLY
	DW	SHPUL
	DW	SHSEP
	DW	0		; <<== table terminator
;
; LF seperator
;
SHSEP:	CALL	ILPRT
	DB	CR,LF,0
	RET
;
; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	0CH,'SET command, PX-8 version:',CR,LF
	DB	CR,LF,'SET COMM     set/display comm parameters'
	DB	CR,LF,'SET DELAY n  set delay for comma in dial string'
	DB	CR,LF,'SET PULSE    set pulse dialing'
	DB	CR,LF,'SET OFFHOOK  go offhook'
	DB	CR,LF,LF,'$'
;
; Show carrier status
;
CARRSH:	CALL	CARRCK		; Check for it
	LXI	D,NOMESG	; Tell about carrier
	MVI	C,PRINT
	CZ	MEX		; Print the "NO" if no carrier
	LXI	D,CARMSG	; Print "carrier present"
	MVI	C,PRINT
	CALL	MEX
	RET
;
NOMESG:	DB	'no $'
CARMSG:	DB	'carrier present',CR,LF,'$'
;
; Check the PX-8 for carrier-present (Z=no)
;
CARRCK:	MVI	B,CTLIN		; Get status byte
	CALL	RSIOX
	ANI	DCD		; Check for carrier detect
	RET
;
; Set OFFHOOK processor
;
SETOFF:	CALL	PDISC		; Disconnect if anything was there
	CALL	PWRON		; Fire up the modem
	CALL	OFFHK
;
SHHOOK:	CALL	ILPRT
	DB	'modem is ',0
	LDA	OCRVAL
	ANI	OHC
	JZ	SHONHK
	CALL	ILPRT
	DB	'off-hook',CR,LF,0
	RET
;
SHONHK:	CALL	ILPRT
	DB	'on-hook',CR,LF,0
	RET
;
; Set delay for comma
;
SETDLY:	MVI	C,EVALA		; Get the number
	CALL	MEX
	MOV	A,H		; Validate
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	COMDLY		; Store new rate
;
; Show dialing delay
;
SHDLY:	CALL	ILPRT
	DB	'delay time for dialing: ',0
	LDA	COMDLY
	MOV	L,A
	MVI	H,0
	MVI	C,DECOUT
	CALL	MEX
	CALL	ILPRT
	DB	' sec',CR,LF,0
	RET
;
; Set for tone or pulse dialing
;
SETPUL:	MVI	C,SBLANK	; Any arguments?
	CALL	MEX
	JC	PULSON		; If not, pulse on
	MVI	A,'T'		; Tone dial flag
	STA	TPULSE
	JMP	SHPUL
PULSON:	MVI	A,'P'		; Pulse dial flag
	STA	TPULSE
;
; Show tone or pulse status
;
SHPUL:	CALL	ILPRT
	DB	'dialing mode: ',0
	LDA	TPULSE
	CPI	'T'
	JZ	SHPUL1
	CALL	ILPRT
	DB	'pulse',CR,LF,0
	RET
;
SHPUL1:	CALL	ILPRT
	DB	'tone',CR,LF,0
	RET
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	; Get function code
	JMP	MEX		; Pass to MEX processor
;
SETCOMM:CALL	CLS		; Clear the screen
	LXI	D,MENU
	MVI	C,PRINT
	CALL	MEX		; Display the setup menu
;
; Display current values on setup screen
;
	CALL	DBAUD
	CALL	DDBITS
	CALL	DPARITY
	CALL	DSTP
	CALL	DMODEM
;
; Get user's response and set paramiters
;
SETUP0:	CALL	KEYIN
	CALL	UCASE
	CPI	ESC
	JZ	SETUP
	CPI	'9'+1		; Greater than baud selection
	JNC	SDBITS		; Check for data bits
	CPI	'1'		; Less than 1?
	JC	SETUP0		; Get another response
	ANI	0FH
	MOV	E,A
	MVI	A,10
	SUB	E
	STA	MDMSPD
	MOV	C,A
	MVI	B,0
	LXI	H,BAUDTBL
	DAD	B
	MOV	A,M
	STA	BAUDRATE
	CALL	DBAUD
	JMP	SETUP0
;
SDBITS:	CPI	'B'+1		; Greater than data bits
	JNC	SPARITY		; Check for parity
	CPI	'A'		; Less than 'a'
	JC	SETUP0		; Get another response
	SUI	3FH		; Make 2 or 3
	STA	DBITS
	CALL	DDBITS
	JMP	SETUP0
;
SPARITY:CPI	'E'+1		; Greater than parity
	JNC	SSTOP		; Check for stop bits
	CPI	'E'		; Check for "even" parity
	JNZ	SPAR0
	SUI	'B'		; Even parity = 3
	JMP	SPAR1
;
SPAR0:	SUI	'C'		; Make 0 or 1
;
SPAR1:	STA	PARBITS
	CALL	DPARITY
	JMP	SETUP0
;
SSTOP:	CPI	'G'+1		; Greater than stop bits
	JNC	SMOD		; Check for modem
	SUI	'F'-1
	CPI	1
	JZ	SSTOP1
	ADI	1		; Two stop bits = 3
;
SSTOP1:	STA	STP
	CALL	DSTP
	JMP	SETUP0
;
SMOD:	CPI	'I'+1		; Greater than baud
	JNC	SETUP0		; Bad selection get another response
	SUI	'H'
	JZ	SMOD1
	CALL	PWRON		; Try to turn the modem on
	IN	STR		; Read status register
	ANI	MII		; Is modem installed?
	JNZ	SMOD2
	MVI	A,0FFH
;
SMOD1:	STA	MDMTYPE
	CALL	DMODEM
	JMP	SETUP0
;
SMOD2:	MVI	A,BELL
	CALL	TYPE
;
SMOD3:	LXI	B,0201H
	CALL	PLACECUR
	CALL	ILPRT
	DB	TAB,'** NO MODEM **',0
	XRA	A
	STA	MDMTYPE
	CALL	DMODEM
	JMP	SETUP0
;
; Display baud rate
;
DBAUD:	LXI	B,30DH
	CALL	PLACECUR
	LXI	H,BAUDSPD
	MVI	D,0
	LDA	MDMSPD		; Get baud rate code
	CPI	0FFH
	RZ			; Unknown baud rate
	MOV	E,A		; X1
	ADD	A		; X2
	ADD	A		; X4
	ADD	E		; X5
	ADD	E
	MOV	E,A
	DAD	D		; Point to correct rate
	XCHG
	MVI	C,PRINT
	CALL	MEX
	CALL	ILPRT
	DB	' bps ',CR,LF,0
	RET
;
; Display data bits
;
DDBITS:	LXI	B,50DH
	CALL	PLACECUR
	LDA	DBITS
	CPI	2
	MVI	A,'7'
	JZ	DDBITS1
	MVI	A,'8'
;
DDBITS1:CALL	TYPE
	RET
;
; Display parity
;
DPARITY:LXI	B,60DH
	CALL	PLACECUR
	LDA	PARBITS
	ORA	A
	JNZ	DPAR1
	CALL	ILPRT
	DB	'none',0
	RET
DPAR1:	CPI	1
	JNZ	DPAR2
	CALL	ILPRT
	DB	'odd ',0
	RET
DPAR2:	CALL	ILPRT
	DB	'even',0
	RET
;
; Display stop bits
;
DSTP:	LXI	B,70DH
	CALL	PLACECUR
	LDA	STP
	CPI	1
	MVI	A,'1'
	JZ	DSTP1
	MVI	A,'2'
;
DSTP1:	CALL	TYPE
	RET
;
; Display modem type
;
DMODEM:	LXI	B,80DH
	CALL	PLACECUR
	LDA	MDMTYPE
	ORA	A
	JNZ	DMODEM1
	CALL	ILPRT
	DB	'external',0
	RET
;
DMODEM1:CALL	ILPRT
	DB	'internal',0
	RET
;
SETUP:	CALL	STPORT		; Set up for internal modem just in case
	CALL	SMSPEED		; Set time to xfer speed
	LDA	MDMTYPE		; See what kind of modem we're using
	INR	A		; If FF, then it's internal
	JZ	SETUP1		; Yep, it's internal
	CALL	RESPORT		; Using external, do setup
;
SETUP1:	LXI	H,PARAMS	; Copy all settings to RSIOX string
	LXI	D,WIPEOUT
	LXI	B,9
	DB	0EDH,0B0H	; LDIR
	LXI	H,BAUDRATE	; Copy uart settings to working area
	LXI	D,WRSDAT
	LXI	B,4
	DB	0EDH,0B0H	; LDIR
	MVI	B,CLSIOX
	CALL	RSIOX		; Close port first
	MVI	B,OPNIOX
	LXI	H,WIPEOUT
	CALL	RSIOX		; Open with new parameters
	CALL	CLS
	CALL	ILPRT
	DB	ESC,CURON
	DB	CR,LF,LF,LF
	DB	TAB,TAB,'Communication initialization completed',CR,LF
	DB	LF,LF,0
	RET
;
BAUDSPD:DB	'50   $110  $150  $300  $600  $'
	DB	'1200 $2400 $4800 $9600 $19200$'
;
BAUDTBL:DB	0FFH		; 50   baud not supported
	DB	2		; 110  baud
	DB	4		; 150  baud
	DB	6		; 300  baud
	DB	8		; 600  baud
	DB	0AH		; 1200 baud
	DB	0CH		; 2400 baud
	DB	0DH		; 4800 baud
	DB	0EH		; 9600 baud
	DB	0FH		; 19.2k baud
;
MENU:	DB	ESC,CUROFF
	DB	TAB,'Select alphanumeric or ESC to return',CR,LF,LF
	DB	'bit rate  :           1=19200    2=9600     3=4800'
	DB	'     4=2400'
	DB	'     5=1200',CR,LF
	DB	'                      6=600      7=300      8=150'
	DB	'      9=110',CR,LF
	DB	'data bits :           A=7        B=8',CR,LF
	DB	'parity    :           C=none     D=odd      E=even'
	DB	CR,LF
	DB	'stop bits :           F=1        G=2',CR,LF
	DB	'modem type:           H=external I=internal$'
;
PARAMS:	  DW	INTBUF
	  DW	INTBUFL
BAUDRATE: DS	1
DBITS:	  DS	1
PARBITS:  DS	1
STP:	  DS	1
SPECIAL:  DB	0FFH		; Not XON/XOFF, not SI/SO, DTR on, RTS on
;
WIPEOUT:  DS	9		; This area gets overwritten by BIOS call
;
;-----------------------------------------------------------------------
;
;		   End of PX-8 MEX modem overlay
;
;-----------------------------------------------------------------------
;
	END
