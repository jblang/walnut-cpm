;	Title	'MEX overlay for the NEC PC-8801 version 1.0'
;
;
; (delete above title line if not assembling with MAC)
;
;
REV	EQU	10		;overlay revision level
;
; MEX NEC PC-8801 OVERLAY VERSION 1.0: written 06/24/84 by Bob Schultz
;
;   based on MXO-PM10.ASM  by Ron Fowler
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
BS	EQU	8
ESC	EQU	1BH
CLRSCR	EQU	1AH
;
; Equates for the 8251 mode register
;
BAUDMSK	EQU	3		;mask to get baud rate bits
BIT5	EQU	00H		;5 bits
BIT6	EQU	04H		;6 bits
BIT7	EQU	08H		;7 bits
BIT8	EQU	0CH		;8 bits
BITMSK	EQU	0CH		;mask to get character length
PARE	EQU	30H		;even parity
PARO	EQU	10H		;odd parity
PARN1	EQU	00H		;no parity
PARN2	EQU	20H		;another code for no parity
PARMSK	EQU	30H		;mask to get parity bits
STP1	EQU	40H		;1 stop bit
STP15	EQU	80H		;1.5 stop bits
STP2	EQU	0C0H		;2 stop bits
STPMSK	EQU	0C0H		;mask to get stop bits
;
; Equates for the 8251 command register
;
RTSBIT	EQU	20H		;bit to turn RTS ON
BRKBIT	EQU	08H		;bit to send break
DTRBIT	EQU	02H		;bit to turn on DTR
CMND	EQU	37H		;RTS, error reset, Rx enable, DTR, Tx enable
MODRST	EQU	40H		;reset the 8251
;
; 8251 port and bit definitions
;
PORT	EQU	20HŠMODCTL	EQU	PORT+1		;status register for RS232
MODDAT	EQU	PORT		;data resister for RS232
MDSNDB	EQU	01H		;bit to test for ready to send
MDSNDR	EQU	01H		;modem send ready when high
MDRCVB	EQU	02H		;bit to test for received data
MDRCVR	EQU	02H		;modem receive ready when high
;
; MEX service processor
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
PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systemsŠ				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	3		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
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
IGNCTL:	DB	YES		;yes=do not send control characters
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
; Equates used only by PMMI routines grouped together here.
;
PRATE:	DB	250		;125=20pps dialing, 250=10pps
	DB	0		;not used
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:	JMP	INSTAT		;in modem control portŠ	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
OTDATA:	JMP	OUTDAT		;out modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
;
INPORT:	JMP	INDAT		;in modem data port
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
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		;dial digit in A (see info at PDIAL)
DISCV:	JMP	PDISC		;disconnect the modem
GOODBV:	JMP	DUMMY		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	DS	3		;set modem for no-parity
PARITV:	DS	3		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK		;send a break
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
INBUFV:	DS	3		;replace with MEX function 10ŠILCMPV:	DS	3		;replace with table lookup funct. 247
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
CLS:	LXI	D,CLSMSG		;null unless patched
	MVI	C,PRINT
	JMP	MEX
;
;------------------------------------------------------------
;
;	*** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
; If the dip switches are set externally to NNNN baud then you get
; NNNN or NNNN/4 baud with the SET command.  The switches should
; normally be set to 1200 baud.
;
NITMOD:	XRA	A		;insure that the 8251 is in the command mode
	OUT	MODCTL
	OUT	MODCTL
	OUT	MODCTL
	LDA	MSPEED		;get the baud rate code
	JMP	PBAUD		;  and go set it
;
; Sends a 300 msec break tone.
;
PBREAK:	MVI	A,CMND		;default command byte
	ORI	BRKBIT		;turn on the break bit
	OUT	MODCTL
	PUSH	B
	MVI	B,3		;wait for 300 ms
	MVI	C,TIMER
	CALL	MEX
	POP	B
	MVI	A,CMND		;restore the command byte
	OUT	MODCTL
	RET
;Š; Drops DTR for 300 msec to disconnect the modem.
;
PDISC:	MVI	A,CMND
	ANI	0FFH AND NOT DTRBIT	;mask out the DTR bit
	OUT	MODCTL
	PUSH	B
	MVI	B,3		;wait for 300 ms
	MVI	C,TIMER
	CALL	MEX
	POP	B
	MVI	A,CMND		;restore command byte
	OUT	MODCTL
	RET
;
; exit routine
;
DUMMY:	RET
;
;
;------------------------------------------------------------
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
	STC			;return error for STBAUD caller
	JZ	PBEXIT		;exit if so
	LDA	MODCTB		;last 8251 mode byte
	ANI	0FFH AND NOT BAUDMSK	;clear out baud bits
	ORA	M		;put new baud bits in
	CALL	STMODE		;send it to the mode register
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
PBEXIT:	POP	B		;all done
	POP	D
	POP	H
	RET
;
; table of baud rate bits for supported rates
;
BAUDTB:	DB	0,3,0,0,0	;110,300,450,600,710
	DB	2,0,0,0,0	;1200,2400,4800,9600,19200
;
; send the byte in reg A to the 8251 mode register
;ŠSTMODE:	STA	MODCTB		;save it so we know what it was
	MVI	A,MODRST	;reset the 8251
	OUT	MODCTL
	LDA	MODCTB		;send the baud rate, etc
	OUT	MODCTL		;  as the mode byte
	MVI	A,CMND		;rx enable, tx enable, etc
	OUT	MODCTL		;  as a command byte
	RET
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	JMP	MEX
;
SOMESG:	DB	CR,LF,ESC,')'		;into half intensity
	DB	'    Overlay Version  '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	'      ',CR,LF
	DB	'     Configured for the       ',CR,LF
	DB	'        NEC  PC-8801          ',CR,LF
	DB	'       by Bob Schultz         ',CR,LF
	DB	'                              ',CR,LF
	DB	'                              '
	DB	ESC,'(',CR,LF		;out of half intensity
	DB	LF,'$'
	RET
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
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	CR,LF,'$'		;clear to end of screen
CLSMSG:	DB	CLRSCR,'$'		;clear whole screen
;
; Data areaŠ;
MODCTB:	DB	BIT8 OR PARN1 OR STP1	;modem control byte
;					   default  8N1
;
;------------------------------------------------------------
;
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
	JMP	MEX
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF
	DB	'Type ',ESC,')SET ?',ESC,'( for help',CR,LF,LF,'$'
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
	DB	'BIT','S'+80H		;"set bits"
	DW	STBITS
	DB	'PA','R'+80H		;"set par"
	DW	STPAR
	DB	'STO','P'+80H		;"set stop"
	DW	STSTOP
	DB	'H'+80H			;"set h"
	DW	STH
	DB	'L'+80H			;"set l"
	DW	STL
	DB	'PEE','K'+80H
	DW	STPEEK
	DB	'BEL','L'+80H
	DW	STBELL
;
	DB	0		;<<=== table terminator
;Š; SET <no-args>: print current statistics
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
SHOTBL:	DW	CLS
	DW	CRLF
	DW	BDSHOW
	DW	BTSHOW
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	JMP	MEX
;
; The help message
;
HLPMSG:	DB	CLRSCR,'SET command, NEC PC-8801 version',CR,LF,LF
	DB	ESC,')SET BAUD',ESC,'(  <',ESC,')300',ESC,'(>  <'
	DB	ESC,')1200',ESC,'(>',CR,LF,LF

	DB	ESC,')SET BITS',ESC,'(  <',ESC,')5',ESC,'(> <',ESC,')6'
	DB	ESC,'(> <',ESC,')7',ESC,'(> <',ESC,')8',ESC,'(>',CR,LF,LF

	DB	ESC,')SET PAR',ESC,'(   <',ESC,')E',ESC,'(>  <',ESC,')O'
	DB	ESC,'(>  <',ESC,')N',ESC,'(>',CR,LF,LF

	DB	ESC,')SET STOP',ESC,'(  <',ESC,')1',ESC,'(>  <',ESC,')1.5'
	DB	ESC,'(>  <',ESC,')2',ESC,'(>',CR,LF,LF

	DB	'$'
;
; SET BAUD processor
;ŠSTBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
STBD:	CALL	PBAUD		;no, try to set it
	JC	SETERR		;not-supported code
	CALL	CRLF
	CALL	BDSHOW
	JMP	CRLF
;
BDSHOW:	CALL ILPRT
	DB	ESC,')',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	CALL	ILPRT
	DB	BS,BS,BS,BS,ESC,'( Baud',CR,LF,0
	RET
;
; SET H		1200 baud for lazy typists
;
STH:	MVI	A,5
	JMP	STBD
;
; SET L		300 baud for lazy typists
;
STL:	MVI	A,1
	JMP	STBD
;
; SET BITS	character length
;
STBITS:	LXI	D,BITTBL	;point to table
	CALL	TSRCH		;  and search for command
	JC	SETERR
	LDA	MODCTB		;get the last 8251 mode byte
	ANI	0FFH AND NOT BITMSK	;zero the character length
	ORA	L			;  and put in the new value
	CALL	STMODE		;send to the 8251 mode register
	CALL	CRLF
	CALL	BTSHOW
	JMP	CRLF
;
; BITS table
;
BITTBL:	DB	'8'+80H
	DW	BIT8
	DB	'7'+80H
	DW	BIT7
	DB	'6'+80H
	DW	BIT6
	DB	'5'+80H
	DW	BIT5
;
	DB	0		;<== table terminator
;
; display the character length, parity and number of stop bitsŠ;
BTSHOW:	CALL	ILPRT		;into inverse video
	DB	ESC,')',0
	LDA	MODCTB		;8251 mode register image
	ANI	BITMSK		;keep only the character length
	RAR
	RAR			;shift bits down to bit 0
	ADI	'5'		;0 is 5 bits, 1 is 6...
	CALL	TYPE
	CALL	ILPRT
	DB	ESC,'( Bits  ',ESC,')',0
	LDA	MODCTB
	ANI	PARMSK		;get the parity bits
	LXI	D,EVNMSG
	MVI	C,PRINT
	CPI	PARE
	CZ	MEX		;for EVEN parity
	LXI	D,ODDMSG
	CPI	PARO
	CZ	MEX		;for ODD parity
	LXI	D,NOMSG
	CPI	PARN1
	CZ	MEX		;for NO parity-first code
	CPI	PARN2
	CZ	MEX		;for NO parity-second code
	CALL	ILPRT
	DB	ESC,'( Parity  ',ESC,')',0
	LDA	MODCTB
	ANI	STPMSK		;get the stop bits
	PUSH	PSW
	LXI	D,S1MSG
	MVI	C,PRINT
	CPI	STP1
	CZ	MEX		;for 1 stop bit
	LXI	D,S15MSG
	CPI	STP15
	CZ	MEX		;for 1.5 stop bits
	LXI	D,S2MSG
	CPI	STP2
	CZ	MEX		;for 2 stop bits
	CALL	ILPRT
	DB	ESC,'( Stop bit',0
	POP	PSW
	CPI	STP1
	MVI	A,'s'
	CNZ	TYPE		;if 1 don't put out 's'
	JMP	CRLF
;
EVNMSG:	DB	'EVEN$'
ODDMSG:	DB	'ODD$'
NOMSG:	DB	'NO$'
;
S1MSG:	DB	'1$'
S2MSG:	DB	'2$'
S15MSG:	DB	'1.5$'Š;
; SET PAR	set the parity
;
STPAR:	LXI	D,PARTBL	;point to the table of commands
	CALL	TSRCH		;  and search it
	JC	SETERR
	LDA	MODCTB
	ANI	0FFH AND NOT PARMSK	;zero the parity bits
	ORA	L			;  and put in the new parity
	CALL	STMODE		;send it to the 8251 mode register
	CALL	CRLF
	CALL	BTSHOW
	JMP	CRLF
;
; table for PAR
;
PARTBL:	DB	'E'+80H
	DW	PARE
	DB	'O'+80H
	DW	PARO
	DB	'N'+80H
	DW	PARN1
;
	DB	0		;<== table terminator
;
; SET STOP	set the stop bits
;
STSTOP:	LXI	D,STPTBL	;point to the command table
	CALL	TSRCH		;  and search it
	JC	SETERR
	LDA	MODCTB
	ANI	0FFH AND NOT STPMSK	;zero the stop bits
	ORA	L			;  and put in the new ones
	CALL	STMODE		;send to the 8251 mode register
	CALL	CRLF
	CALL	BTSHOW
	JMP	CRLF
;
; table for STOP
;
STPTBL:	DB	'1'+80H
	DW	STP1
	DB	'1.','5'+80H
	DW	STP15
	DB	'2'+80H
	DW	STP2
;
	DB	0		;<== table terminator
;
; SET PEEK	display memory location in hex and ascii
;
STPEEK:	CALL	CRLF
	MVI	C,EVALA
	CALL	MEX		;get numeric
	PUSH	HŠ	MVI	B,16		;will do 16 bytes
PKLP1:	MOV	A,M		;get byte
	MOV	C,A
	RAR			;swap nibbles
	RAR
	RAR
	RAR
	CALL	HEX1		;put out first nibble
	MOV	A,C
	CALL	HEX1		;put out second nibble
	MVI	A,' '
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	PKLP1		;keep doing it
	CALL	CRLF
	POP	H		;point to starting byte again
	MVI	B,16
PKLP2:	MVI	A,' '
	CALL	TYPE
	MOV	A,M
	CPI	20H
	JC	NOTASC		;must be control
	CPI	7FH
	JNC	NOTASC		;del and above
	CALL	TYPE		;put out printable
	JMP	ASC
NOTASC:	MVI	A,'.'		;put out a '.' for non-printable
	CALL	TYPE
ASC:	MVI	A,' '
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	PKLP2		;keep doing it
	CALL	CRLF
	JMP	CRLF
;
HEX1:	ANI	0FH		;zero top nibble
	ADI	90H		;thanks to
	DAA			;  Kelly Smith
	ACI	40H		;    for this strange
	DAA			;      looking code
	CALL	TYPE
	RET
;
; It's easy to get carried away adding new commands for SET
;
STBELL:	CALL	ILPRT
	DB	7,CR,LF,ESC,')Ding!!  Dong!!',ESC,'(',CR,LF,LF,7,0
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processorŠ;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
; end of SET command
;
;---------------------------------------------------------------
;
; These routines are down here to make it easy to hang things
; on them.  For example you might add code to check for framing
; errors and then throw the charater away or zero it or...
;
; Modem status in
;
INSTAT:	IN	MODCTL
	RET
;
; Modem data in
;
INDAT:	IN	MODDAT
	RET
;
; Modem data out
;
OUTDAT:	OUT	MODDAT
	RET
;
;---------------------------------------------------------------
;
; End of NEC PC8801 MEX modem overlay
;
;------------------------------------------------------------
;
	END

