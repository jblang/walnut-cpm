	Title	'MEX overlay for the Epson QX-10, version 1.0'
;
;
; (delete above title line if not assembling with MAC)
;
;
REV	EQU	10		;overlay revision level
;
; MEX Epson QX-10 (CP/M-80) overlay, version 1.0
;		   04 July 84, Chatland Whitmore
; Adapted from:
;  MEX PMMI OVERLAY VERSION 1.0: written 04/27/84 by Ron Fowler
;  and M712QS.ASM by Bruce Ratoff, 10/13/83
;
;------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
ESC	EQU	1BH
;
; QX-10 port definitions
;
PORT	EQU	011H		;QX-10 base port 
MODCT1	EQU	PORT+2		;modem control port
MODDAT	EQU	PORT		;modem data port
;
BRPRTS	EQU	007H		;baud rate setup port
BRPRTC	EQU	006H		;baud rate counter port
BRSET	EQU	0B6H		;command to setup baud rate
CRAM	EQU	23H		;CMOS ram baud rate offset location
MOSADR	EQU	3DH		;CMOS ram address port
MOSDAT	EQU	3CH		;CMOS ram data port
;
;
; QX-10 bit definitions
;
MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
MDDCDB	EQU	08H		;modem dcd bit
;
; 
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately pre-
; ceeding the actual FCB (to contain user # information).  If you've
; used MEX-10 for input instead of BDOS-10 (or you're parsing part
; of a SET command line that's already been input), then MEX will
; take care of DU specs, and set up the FCB accordingly.  There-
; after all file I/O calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
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
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
	ORG	TPA		;we begin
;
;
	DS	3		;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	no		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	yes		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	5		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST:	DB	yes		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	yes		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP
LOCNXT:	DB	NO		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	DB	NO		;yes=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of XOFF testing
IGNCTL:	DB	yes		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
	DS	2		;(some PMMI stuff was here)
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:	IN	MODCT1		;in modem control port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
OTDATA:	OUT	MODDAT		;out modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
;
INPORT:	IN	MODDAT		;in modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
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
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8:  9600 baud
;	 A=9: 19200 baud
;
;        If your overlay supports the passed baud rate, it should store the
;	 value passed in A at MSPEED (107H), and set the requested rate. If
;	 the value passed is not supported, you should simply return (with-
;	 out modifying MSPEED) -or- optionally request a baud-rate from the
;	 user interactively.
;
; NOPARV is called at the end of each file transfer; your overlay may simply
;	 return here, or you may want to restore parity if you set no-parity
;	 in the following vector (this is the case with the PMMI overlay).
;	 
; PARITV is called at the start of each file transfer; your overlay may simply
;	 return here, or you may want to enable parity detection (this is the
;	 case with the PMMI overlay).
;
; SETUPV is the user-defined command ... to use this routine to build your own
;	 MEX command, set the variable SETFL (117H) non-zero, and add your SET
;	 code.  You can use the routine presented in the PMMI overlay as a 
;	 guide for parsing, table lookup, etc.
;
; SPMENU is provided only for MDM compatibility, and is not used by MEX 1.0 for
;	 any purpose (it will be gone in MEX 2).
;
; VERSNV is called immediately after MEX prints its sign-on message at cold
;	 startup -- use this to identify your overlay in the sign-on message
;	 (include overlay version number in the line).
; BREAKV is provided for sending a BREAK (<ESC>-B in terminal mode).  If your
;	 modem doesn't support BREAK, or you don't care to code a BREAK rou-
;	 tine, you may simply execute a RET instruction.
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	JMP	PDIAL		;dial digit in A (see info at PDIAL)
DISCV:	JMP	PDISC		;disconnect the modem
GOODBV:	JMP	DUMMY		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	JMP	NOPAR		;set modem for no-parity
PARITV:	JMP	PARITY		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	DS	3		;send a break   *** DISABLED ***
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
ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;
CLS:	LXI	D,CLSMSG	
	MVI	C,PRINT
	CALL	MEX
	RET
;
;------------------------------------------------------------
;
;	*** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
; modem port initialization
;
NITMOD:	CALL	GTBAUD		;adjust mspeed to QX-10's stored value
	CALL	SIONIT		;send out default SIO initialization
	RET
;
;-------------------------------------------------------------
;
; send-break routine
;
PBREAK:	RET
;
;-------------------------------------------------------------
;
; setup for odd/even parity.
;
PARITY:	RET
;
;-------------------------------------------------------------
; 
; set no-parity
;
NOPAR:	RET
;
;-------------------------------------------------------------
;
; disconnect the modem
;
PDISC:	RET
;
;-------------------------------------------------------------
;
; exit routine
;
DUMMY:	RET
;
;-------------------------------------------------------------
;
; dial routine
;
PDIAL:	RET
;
;------------------------------------------------------------
;
; Set baud-rate code in A (if supported by your overlay).
; NOTE: this routine (i.e.; the one vectored through NEWBDV) 
; should update MSPEED with the passed code, but ONLY if 
; that rate is supported by the hardware.
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	A,M		;fetch code
	CPI	0FFH		;0FFH? (means unsupported code)
	STC			;return error for STBAUD caller
	JZ	PBEXIT		;exit if so
	ORA	A		;clear the carry flag
	CALL	FNDRAT		;go set up baud rate
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
PBEXIT:	POP	B		;all done
	POP	D
	POP	H
	RET
;
; table of QX-10 modem port baud rate codes for each MSPEED value.
;
BAUDTB:	DB	0	;  110 baud --> QX-10 code = 0
	DB	3	;  300                       3
	DB	9	;  450                       9
	DB	4	;  600			     4
	DB	0FFH	;  710			     n/a
	DB	5	; 1200			     5
	DB	6	; 2400			     6
	DB	7	; 4800			     7
	DB	8	; 9600			     8
	DB	0FFH	;19200			     n/a
;
;----------------------------------------------------------------
;
; enter here with QX-10 baud rate code in A.
;
FNDRAT:
	MOV	C,A		;save baud rate code in C
	ADD	A		;double the baud rate code
	LXI	H,DIVTBL	;add result to table address
	ADD	L		;     and leave result in HL
	MOV	L,A
	JNC	FNDRT2
	INR	H
FNDRT2:
	MVI	A,BRSET		;tell system we want to set up
	OUT	BRPRTS		;   baud rate divisor
	MOV	A,M		;get low order byte
	OUT	BRPRTC		;   and send to counter
	INX	H
	MOV	A,M		;do same for high order byte
	OUT	BRPRTC
	CALL	INPORT		;flush modem port
	CALL	INPORT
	MVI	A,CRAM		;prepare to set QX-10 baud value
	DI			;MUST disable interrupts now
	OUT	MOSADR		;ask for access to CMOS ram
	MOV	A,C		;recall the baud rate code
	OUT	MOSDAT		;send it to CMOS ram
	EI			;don't forget to restore interrupts
	RET
;
; table of timer chip divisors for each QX-10 baud rate code.
;
DIVTBL:
	DW	1135 	; 0 =   110 baud
	DW	928	; 1 =   135      \  not used
	DW	832	; 2 =   150      /  by MEX
	DW	416	; 3 =   300
	DW	208	; 4 =   600
	DW	104	; 5 =  1200
	DW	52	; 6 =  2400
	DW	26	; 7 =  4800
	DW	13	; 8 =  9600
	DW	277	; 9 =   450
;
;---------------------------------------------------------------
;
; get baud rate of QX-10 modem port and translate to MSPEED value.
;
GTBAUD:
	MVI	A,CRAM
	OUT	MOSADR
	IN	MOSDAT
	ANI	0FH
	LXI	H,MSPTBL
	ADD	L
	MOV	L,A
	JNC	STMSP2
	INR	H
STMSP2:
	MOV	A,M
	STA	MSPEED
	RET
;
; table of MSPEED values for each possible QX-10 baud rate.
;
MSPTBL:
	DB	0	; 110 baud
	DB	0	; 135      \  QX-10 possible baud rates not
	DB	0	; 150      /  supported with MSPEED values
	DB	1	; 300
	DB	3	; 600
	DB	5	;1200
	DB	6	;2400
	DB	7	;4800
	DB	8	;9600
	DB	2	; 450
;
;-----------------------------------------------------------
;
SIONIT:
	PUSH	H
	MVI	C,MODCT1	;modem control port
	MVI	B,MINLEN	;length of modem init table
	LXI	H,MINTBL	;point to init table
	DB	0EDH,0B3H	;OUTIR the init table (Z80 code)
	POP	H
	RET
;
MINTBL	DB	4		;select write register 4
	DB	44H		;X1 clock mode, 1 stop, no parity
	DB	3		;select register 3
	DB	0C1H		;Rx: 8 bit word, Rx enabled
	DB	5		;select register 5
	DB	0EAH		;Tx: 8 bit word, DTR & RTS set
MINLEN	EQU	$-MINTBL
;
;----------------------------------------------------------------
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;------------------------------------------------------------
;
; Data area
;
EOSMSG:	DB	ESC,'Y','$'	;clear to end-of-screen
CLSMSG:	DB	ESC,'+','$'	;clear whole screen
SOMESG:	DB	'Epson QX-10 (CP/M-80) overlay V. '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF,'$'
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a SET command -- if 
; you prefer not to write a SET for your modem, you may delete 
; the code from here to the END statement.
;
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	MVI	C,SBLANK	;any arguments?
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
SHOTBL:	DW	BDSHOW
	DW	0		;<<== table terminator
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
HLPMSG:	DB	CR,LF
	DB	'SET command, Epson QX-10 version:',CR,LF,LF
	DB	'Baud rates:   110    300    450    600',CR,LF
	DB	'             1200   2400   4800   9600',CR,LF,LF
	DB	'Example:  SET BAUD 300',CR,LF,LF
	DB	'$'
;
;---------------------------------------------------------------------
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;not-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
;
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
;-------------------------------------------------------
;
; new line on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;and fall into TYPE
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
;------------------------------------------------------------
;
; End of Epson QX-10 MEX modem overlay
;
;------------------------------------------------------------
;
	END
