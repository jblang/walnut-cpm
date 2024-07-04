; MXH-AM11.ASM
; MEX overlay for the Ampro Little Board Computer

; Version 1.1  07 Feb 1986
;  Changed to MXH-AM11 from MXO=AM10, added DCD & DTR support and
;  made LOADable from within MEX+	--Bob Connolly
;
; Version 1.0: 28 Nov 1984  

REV	EQU	11		;overlay revision level


; This is a MEX overlay file for the Ampro Computer.  It is designed
; to work with the modem connected to serial port 'B'.  It also       
; requires the CTC and SIO parameter tables at the front of the
; Ampro bios, as well as the I/O initialization routine in the
; Ampro bios.  This is a non-standard bios call and if not present
; in the bios it must be duplicated in this overlay.

; Note that all overlays may freely use memory up to 0CFFH.  If the
; overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM),
; the physical modem overlay should terminate by 0AFFH.
 
;------------------------------------------------------------

; Misc equates

NO	EQU	0
YES	EQU	0FFh   
TPA	EQU	100h
CR	EQU	13
LF	EQU	10
TAB	EQU	9

; Ampro definitions

IOINT	EQU	57	;BIOS call of initialization routine
SIOB	EQU	52h	;relative location in bios
SIOB1	EQU	53h
SIOB3	EQU	55h
SIOB5	EQU	57h
CT1	EQU	42h

; port definitions

MODCTL	EQU	8Ch		;modem control port B
MODDAT	EQU	88h		;modem data port B

; bit definitions

MDRCVB	EQU	01h		;modem receive bit (DAV)
MDRCVR	EQU	01h		;modem receive ready
MDSNDB	EQU	04h		;modem send bit
MDSNDR	EQU	04h		;modem send ready bit

; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).

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

CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10

	ORG	TPA		;we begin

	db	0c3h
	DS	2		;MEX has a JMP START here

; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.

PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	6		;sets display time for sending a file
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
SCRTST:	DB	YES		;yes=if home cursor and clear screen	10Ch
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC	110h
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	YES		;yes=allow transmission of logon
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
IGNCTL:	DB	NO		;yes=do not send control characters
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
EXTCHR:	DB	'^'-40H		;^^ = Send next character		127h

	ds	2		;make addresses right

; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)

INCTL1:	IN	MODCTL		;in modem control port			12Ah
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI

OTDATA:	OUT	MODDAT		;out modem data port			134h
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI

INPORT:	IN	MODDAT		;in modem data port			13Eh
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI

; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format

MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready		148h
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready


dcdtst:	jmp	dcdvec	;data carrier detect				154h
rngdet:	jmp	rngvec	;ring-detect					157h
	db	0,0,0,0,0

; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.  Thus, if your modem can't dial, change the
; JMP PDIAL at DIALV to DS 3, and MEX will print a "not-implemented"
; diagnostic for any commands that require dialing.

; DIALV  dials the digit in A. See the comments at PDIAL for specs.

; DISCV  disconnects the modem

; GOODBV is called just before MEX exits to CP/M.  If your overlay
;        requires some exit cleanup, do it here.

; INMODV is called when MEX starts up; use INMODV to initialize the modem.

; NEWBDV is used for phone-number baud rates and is called with a baud-rate
;        code in the A register, value as follows:

;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud

;        If your overlay supports the passed baud rate, it should store the
;	 value passed in A at MSPEED (107H), and set the requested rate. If
;	 the value passed is not supported, you should simply return (with-
;	 out modifying MSPEED) -or- optionally request a baud-rate from the
;	 user interactively.

; NOPARV is called at the end of each file transfer; your overlay may simply
;	 return here, or you may want to restore parity if you set no-parity
;	 in the following vector (this is the case with the PMMI overlay).
	 
; PARITV is called at the start of each file transfer; your overlay may simply
;	 return here, or you may want to enable parity detection (this is the
;	 case with the PMMI overlay).

; SETUPV is the user-defined command ... to use this routine to build your own
;	 MEX command, set the variable SETFL (117H) non-zero, and add your SET
;	 code.  You can use the routine presented in the PMMI overlay as a 
;	 guide for parsing, table lookup, etc.

; SPMENU is provided only for MDM compatibility, and is not used by MEX 1.0 for
;	 any purpose (it will be gone in MEX 2).

; VERSNV is called immediately after MEX prints its sign-on message at cold
;	 startup -- use this to identify your overlay in the sign-on message
;	 (include overlay version number in the line).
; BREAKV is provided for sending a BREAK (<ESC>-B in terminal mode).  If your
;	 modem doesn't support BREAK, or you don't care to code a BREAK rou-
;	 tine, you may simply execute a RET instruction.
;
smdisc:	ds	3		;smartmodem disc (not here}		15Fh
DIALV:	DS	3		;dial digit in A (see info at PDIAL)	162h
DISCV:	jmp	drdtr		;disconnect the modem			165h
GOODBV:	DS	3		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	JMP	NOPAR		;set modem for no-parity
PARITV:	JMP	PARITY		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message	17Dh
BREAKV:	DS	3		;send a break				180h

; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.

; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).

ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254

; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).

; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).

CLREOS:	LXI	D,EOSMSG		;		195h
	MVI	C,PRINT
	CALL	MEX
	RET

CLS:	LXI	D,CLSMSG		;null unless patched  19Eh
	MVI	C,PRINT
	CALL	MEX
	RET
;
	org	200h		; area above is reserved
;

EOSMSG:	DB	27,89,0,0,0,'$'

CLSMSG:	DB	27,42,0,0,0,'$'

NOPAR:	RET

PARITY:	RET

;
DRDTR:	MVI	A,5		; Setup to write register 5
	OUT	MODCTL
	MVI	A,68H		; Clear RTS causing shutdown
	OUT	MODCTL
	RET
;

dcdvec:	mvi	a,10h		;reset status
	out	modctl		;  0=NO CARRIER  255=CARRIER
	in	modctl		;  254=NOT SUPPORTED
	ani	20h		;dcd from modem must
	rz			; be connected to
	ori	0ffh		; cts (ampro) else
	ret			; return 0feh (unsupported)
;
rngvec:	mvi	a,0feh
	ret
;
NITMOD:	MVI	A,6		;initialize to 2400 baud.  No other
				;parameters changed... fall thru

;------------------------------------------------------------------

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
	STA	BSAVE1		;save it
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
	LXI	H,BAUDTX	;offset into second table
	DAD	D
	MOV	A,M		;get second value
	STA	BSAVE2		;save it also

	LHLD	1		;get location of bios
	MVI	L,CT1		;add 42 to reach CT1 in i/o table
	MVI	A,47h
	MOV	M,A
	INX	H		;move to next location
	LDA	BSAVE1		;get first table value
	MOV	M,A		;store it
	LDA	BSAVE2		;get second table value
	MOV	B,A		;and save it
	MVI	L,SIOB1		;move ahead to siob+1 values
	MOV	A,M		;get current value
	ANI	3Fh		
	ORA	B		;or it with second value
	MOV	M,A		;store it in work table
	INX	H
	INX	H
	MOV	A,M		;get last value and make
	ORI	80h		;sure msb is set
	MOV	M,A		;put it back in working table
	CALL	IOINIT		;do the initialization
	STC
	CMC			;return no error for STBAUD
PBEXIT:	POP	B		;all done
	POP	D
	POP	H
	RET

IOINIT	MVI	A,IOINT		;offset into bios jump table
	LHLD	1		;address of bios in HL
	MOV	L,A		;add offset
	JMP	GOHL		;and go there with auto return

; table of baud rate divisors for supported rates

BAUDTB:	DB	0,208,139,208,0,104	;110,300,450,600,710,1200
	DB	52,26,13,0		;2400,4800,9600,19200

BAUDTX:	DB	0,80h,80h,40h,0,40h
	DB	40h,40h,40h,0

BSAVE1	DB	0			;current setting from
BSAVE2	DB	0			;tables - uninitialized

; Sign-on message

SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
	RET

SOMESG:	DB	'Ampro Overlay Version '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF,'$'

; Newline on console

CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE

; type char in A on console

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

; Data area

;------------------------------------------------------------

; The remainder of this overlay implements a very versatile
; SET command -- if you prefer not to write a SET for your
; modem, you may delete the code from here to the END statement.

; Control is passed here after MEX parses a SET command.

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

SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'

; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.

; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.

CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'BIT','S'+80H		;"set bits"
	DW	STBITS
	DB	'PARIT','Y'+80H		;"set parity"
	DW	STPAR
	DB	'STO','P'+80H		;"set stop"
	DW	STSTOP
	DB	'SHAK','E'+80H		;"set shake"
	DW	STSHAK

	DB	0		;<<=== table terminator

; SET <no-args>: print current statistics

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

GOHL:	PCHL

; table of SHOW subroutines

SHOTBL:	DW	BDSHOW
	DW	BITSH
	DW	PARSH
	DW	STPSH
	DW	SHKSH
	DW	0		;<<== table terminator

; SET ?  processor

STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET

; The help message

HLPMSG:	DB	CR,LF,'SET command, Ampro version:',CR,LF
	DB	CR,LF,'  >SET BAUD 300, 450, 600, 1200, 2400, 4800, or 9600.'
	DB	CR,LF,'  >SET BITS 5, 6, 7, or 8.'
	DB	CR,LF,'  >SET PARITY ODD, EVEN, or NONE.'
	DB	CR,LF,'  >SET STOP 1, or 2.'
	DB	CR,LF,'  >SET SHAKE ON, or OFF.'
	DB	CR,LF,CR,LF,'$'

; SET BAUD processor

STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;not-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'  Baud rate: ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET

; SET BITS processor

STBITS:	LXI	D,BITTBL	;load lookup table
	CALL	TSRCH		;look for 7 or 8
	JC	SETERR		;if not found
	MOV	C,L		;save selection value
	LHLD	1		;get bios address
	MVI	L,SIOB3		;move to siob+3
	MOV	A,M		;wr5 info 
	ANI	9Fh		;mask
	ORA	C		;add selection
	MOV	M,A		;store it
	MOV	A,C		;get selection
	RAL	
	MOV	C,A		;shift selection left
	MVI	L,SIOB5		;move to siob+5
	MOV	A,M		;wr3 info
	ANI	3Fh		;mask
	ORA	C
	MOV	M,A		;store it
	CALL	IOINIT		;do it.

BITSH:	CALL	ILPRT
	DB	'  Data bits: ',0
	LHLD	1		;get bios location
	MVI	L,SIOB3		;move to siob+3
	MOV	A,M		;get current value
	ANI	60h
	CPI	60h
	JZ	BITSH8
	CPI	20h
	JZ	BITSH7
	CPI	40h
	JZ	BITSH6
	CALL	ILPRT
	DB	'5',0		;show a 5
	RET
BITSH6	CALL	ILPRT
	DB	'6',0		;show a 6
	RET
BITSH7	CALL	ILPRT
	DB	'7',0		;show a 7
	RET
BITSH8:	CALL	ILPRT
	DB	'8',0
	RET

BITTBL:	DB	'5'+80h
	DW	00h
	DB	'6'+80h
	DW	40h
	DB	'7'+80h
	DW	20h
	DB	'8'+80h
	DW	60h
	DB	0
;
STPAR:	LXI	D,PARTBL
	CALL	TSRCH
	JC	SETERR
	MOV	C,L
	LHLD	1		;get bios address
	MVI	L,SIOB1		;go to siob+1
	MOV	A,M
	ANI	0FCh
	ORA	C
	MOV	M,A
	CALL	IOINIT

PARSH:	CALL 	ILPRT
	DB	'     Parity: ',0
	LHLD	1		;get bios address
	MVI	L,SIOB1
	MOV	A,M
	ANI	03h		;mask
	CPI	01h		;check for none
	JZ	PARSHO
	CPI	03h
	JZ	PARSHE

	CALL	ILPRT
	DB	'none',0
	RET

PARSHO	CALL	ILPRT
	DB	'odd',0
	RET
PARSHE:	CALL	ILPRT
	DB	'even',0
	RET

PARTBL:	DB	'OD','D'+80h
	DW	01h
	DB	'EVE','N'+80h
	DW	03h
	DB	'NON','E'+80h
	DW	00h
	DB	0

STSTOP:	LXI	D,STPTBL
	CALL	TSRCH
	JC	SETERR
	MOV	C,L
	LHLD	1		;get bios address
	MVI	L,53h		;shift to bios+1
	MOV	A,M
	ANI	0F3h
	ORA	C
	MOV	M,A
	CALL	IOINIT

STPSH:	CALL	ILPRT
	DB	'  Stop bits: ',0
	LHLD	1		;get bios address
	MVI	L,53h		;shift to bios+1
	MOV	A,M
	ANI	0Ch
	CPI	0Ch
	JZ	STPSH2
	CALL	ILPRT
	DB	'1',0
	RET
STPSH2:	CALL	ILPRT
	DB	'2',0
	RET
STPTBL:	DB	'1'+80h
	DW	04h
	DB	'2'+80h
	DW	0Ch
	DB	0

STSHAK:	LXI	D,SHKTBL	;get handshake table
	CALL	TSRCH		;search it for parameter
	JC	SETERR		;if not found
	MOV	C,L		;temp store value in C
	LHLD	1		;get location of BIOS
	MVI	L,6Dh		;location of HSB in bios
	MOV	M,C		;put new value in it

SHKSH:	CALL	ILPRT
	DB	' Hand Shake: ',0
	LHLD	1		;get bios location
	MVI	L,6DH		;location of HSB in bios
	MOV	A,M		;get current value
	CPI	1
	JZ	SHKSHY		;show a yes
	CALL	ILPRT
	DB	'off',0
	RET
SHKSHY	CALL	ILPRT
	DB	'on',0
	RET

SHKTBL	DB	'OF','F'+80h
	DW	0
	DB	'O','N'+80h
	DW	1
	DB	0

;----------------------------------------------------------

; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item

TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor

; Print in-line message ... blows away C register

ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it

;------------------------------------------------------------

; End of AMPRO MEX modem overlay

;------------------------------------------------------------
	END
