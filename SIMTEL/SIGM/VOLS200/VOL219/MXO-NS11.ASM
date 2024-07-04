;
;	Title	'MEX overlay for the North Star Horizon version 1.1'
;
;
REV	EQU	11		;overlay revision level
;
; MEX NORTH STAR OVERLAY VERSION 1.1
; MEX HSIO-4 OVERLAY VERSION 1.1
; MEX SEATTLE COMPUTER PRODUCTS MULTI-PORT SERIAL CARD VERSION 1.1
; Modified from MXO-PM10.ASM and MDM712NS.ASM by Ted H. Emigh
;	24 May 1984  (emigh@ecsvax.uucp)
;
; Last Revision: 23 July 1984, THE
;
; Version 1.1:  Fixed bug in routine which changes parity.  23 July 1984,
;	Ted H. Emigh (emigh@ecsvax.uucp)
;
;
; This is a MEX overlay file for the North Star Horizon with the standard
; serial ports (modem on the second serial port) OR the North Star HSIO-4
; serial board OR the Seattle Computer Products Multi-port Serial Card.
; **NOTE**  If you are using the Horizon second serial port, you MUST set
; the speed on the second serial port for 1200 bps, even if your modem is
; only 300 bps.
;
; Note that all overlays may freely use memory up to 0CFFH.  If your
; overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM) or
; the MEX DATEC 212 overlay (MXO-DT10.ASM), the physical modem overlay
; should terminate by 0AFFH.
;
; The SET command allows the user to change the baud rates, and the
; parity.  The parity options are: No parity (NONE); Even parity (EVEN);
; Even parity with 8 data bits (EVEN8); Odd parity (ODD); and Odd parity
; with 8 data bits (ODD8).  EVEN8 and ODD8 are for special purposes and
; will most likely never be used.
;------------------------------------------------------------
;
; Misc equates
;
YES	EQU	0FFH
NO	EQU	0
NA	EQU	0FFH		;Value for baud rate not available
TPA	EQU	100H		;Beginning of TPA
CR	EQU	13		;carriage return
LF	EQU	10		;line feed
TAB	EQU	9		;tab
BELL	EQU	07H		;bell
ESC	EQU	1BH		;escape
;
; Change the following information to match your equipment
; Only one of the next three equates should be YES
;
SECSER:	EQU	NO		;YES if N* Horizon's Second Serial Port
HSIO4:	EQU	NO		;YES if HSIO-4 Serial Card
SCP4:	EQU	YES		;YES if SCP Multi-port Serial Card
;
IF SECSER
PORT:	EQU	4H		;modem data port
CDPORT:	EQU	6		;carrier detect port
MODCDB:	EQU	10H		;CARRIER DETECT BIT
MODCDA:	EQU	0		;VALUE WHEN ACTIVE
ENDIF
;
IF HSIO4
BASE:	EQU	10H		;Base address (0, 10H, 20H, ...)
CHANEL:	EQU	1		;Channel number (A=0, B=1, C=2, D=3)
PORT:	EQU	BASE+4*CHANEL+2	;Data port
BAUDRP:	EQU	BASE+4*CHANEL	;Baud rate port
ENDIF
;
IF SCP4
BASE:	EQU	10H		;Base address (0, 10H, 20H, ...)
CHANEL:	EQU	1		;Channel number (0, 1, 2, 3)
PORT:	EQU	BASE+2*CHANEL	;Data port
BAUDRP:	EQU	BASE+CHANEL+8	;Baud rate port
ENDIF
;
MODCTL:		EQU	PORT+1	;MODEM CONTROL PORT
MODDAT:		EQU	PORT	;MODEM DATA PORT
MDRCVB:		EQU	2	;BIT TO TEST FOR RECEIVE
MDRCVR:		EQU	2	;VALUE WHEN READY
MDSNDB:		EQU	1	;BIT TO TEST FOR SEND
MDSNDR:		EQU	1	;VALUE WHEN READY
EVEN		EQU	78H	;even parity, 7 data bits
EVEN8		EQU	7CH	;even parity, 8 data bits
ODD		EQU	58H	;odd parity, 7 data bits
ODD8		EQU	5CH	;odd parity, 8 data bits
NONE		EQU	4CH	;no parity, 8 data bits
;
; Baud rate values
;
IF SECSER
BD110:		EQU	NA		;NO 110
BD300:		EQU	3		;300
BD450:		EQU	NA		;NO 450
BD600:		EQU	NA		;NO 600
BD710:		EQU	NA		;NO 710
BD1200:		EQU	2		;1200
BD2400:		EQU	NA		;NO 2400
BD4800:		EQU	NA		;NO 4800
BD9600:		EQU	NA		;NO 9600
BD19K:		EQU	NA		;NO 19200
ENDIF
;
IF HSIO4
BD110:		EQU	7		;110
BD300:		EQU	6		;300
BD450:		EQU	NA		;NO 450
BD600:		EQU	5		;600
BD710:		EQU	NA		;NO 710
BD1200:		EQU	4		;1200
BD2400:		EQU	3		;2400
BD4800:		EQU	2		;4800
BD9600:		EQU	1		;9600
BD19K:		EQU	0		;19200
CLCK:		EQU	2		;16X clock
ENDIF
;
IF SCP4
BD110:		EQU	2H		;110
BD300:		EQU	5H		;300
BD450:		EQU	NA		;NO 450
BD600:		EQU	6H		;600
BD710:		EQU	NA		;NO 710
BD1200:		EQU	7H		;1200
BD2400:		EQU	0AH		;2400
BD4800:		EQU	0CH		;4800
BD9600:		EQU	0EH		;9600
BD19K:		EQU	0FH		;19200
CLCK:		EQU	2		;16X clock
ENDIF
;
; Initial baud rate
;
INITBD:		EQU	5		;Initial baud rate (1200)
;
; Control bytes
;
RESET1		EQU	0B7H		;Initialize UART
RESET2		EQU	77H		;Internal reset
CHIPSET		EQU	27H		;DTR, RTS, RE, TE
DISCNT		EQU	07H		;no DTR, RTS, RE, TE
;
BREAK		EQU	CHIPSET OR 8H	;BREAK character
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
PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	NO		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	INITBD		;sets initial baud rate
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
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
CRCDFL:	DB	NO		;yes=default to CRC checking
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
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
; Equates used only by PMMI routines grouped together here.
;
	DS	2		;not used
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL:	IN	MODCTL		;in modem control port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed
;
OTDATA:	OUT	MODDAT		;out modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed
;
INPORT:	IN	MODDAT		;in modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed
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
; MEX will be retained.
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		;dial digit in A (see info at PDIAL)
DISCV:	JMP	MDISC		;disconnect the modem
GOODBV:	JMP	DUMMY		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	SBAUD		;set baud rate
NOPARV:	DS	3		;set for no parity (called after transfer)
PARITV:	DS	3		;set modem parity (called before transfer)
SETUPV:	JMP	SETCMD		;SET command
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		;send a break
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
CLS:	LXI	D,CLSMSG		;null unless patched
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
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	ESC,'Y',0,0,0,0,'$'	;clear to end-of-screen (0 for pause)
CLSMSG:	DB	ESC,'+',0,0,0,0,'$'	;clear whole screen (0 for pause)
;
; Modem initialization.
;
NITMOD:	MVI	A,RESET1	;Initialize 8251 chip
	OUT	MODCTL
	MVI	A,RESET1	;Initialize 8251 chip again
	OUT	MODCTL
	LDA	MSPEED
	CALL	SBAUD		;set the baudrate
	RET
;
; Send-break routine
;
SBREAK:	MVI	A,BREAK
	OUT	MODCTL
	MVI	B,2		;wait 200 ms
	MVI	C,TIMER
	CALL	MEX
	MVI	A,CHIPSET	;reset break
	OUT	MODCTL
	RET
;
; disconnect the modem
;
MDISC:	MVI	A,DISCNT	;hang up
	OUT	MODCTL
	MVI	B,20		;wait for modem to disconnect (2 sec)
	MVI	C,TIMER
	CALL	MEX
	MVI	A,CHIPSET	;reset modem
	OUT	MODCTL
	RET
;
; Exit routine --  called just before MEX exits to CP/M
;
DUMMY:	RET			;we don't need one
;
;
; Set Baud Rate
;
; New baud-rate code in A.
; NOTE: this routine (ie, the one vectored through NEWBDV) should
; update MSPEED with the passed code, but ONLY if that rate is
; supported by the hardware.
;
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
;
SBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	C,A		;save baud rate code
	MVI	B,0
	LXI	H,BTABL		;Get baudrate value
	DAD	B
	MOV	A,M
	CPI	NA		;See if baud rate valid
	STC			;set for not valid
	JZ	NOTVAL		;not valid
;
IF SCP4 OR HSIO4
	OUT	BAUDRP
	MVI	A,CLCK		;set up clock multiplier
ENDIF
;
	LXI	H,PARITY
	ORA	M		;put in parity and data length
	PUSH	PSW		;first reset the UART
	MVI	A,RESET2
	OUT	MODCTL
	XTHL			;delay -- must be in pairs
	XTHL
	POP	PSW
	OUT	MODCTL
	MOV	A,C
	STA	MSPEED		;save new baud rate code
	MVI	A,CHIPSET	;set chip for I/O
	OUT	MODCTL
	XRA	A		;clear carry flag
NOTVAL:	POP	B
	POP	D
	POP	H
	RET
;
; Parity control byte location
;
PARITY:	DB	NONE
;
; Baud rate table
;
BTABL:	DB	BD110
	DB	BD300
	DB	BD450
	DB	BD600
	DB	BD710
	DB	BD1200
	DB	BD2400
	DB	BD4800
	DB	BD9600
	DB	BD19K
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
CARRSH:
;
IF SCP4 OR HSIO4
	RET
ENDIF
;
IF SECSER
	LXI	D,NOMESG	;tell about carrier
	CALL	CARRCK		;check for it
	MVI	C,PRINT
	CNZ	MEX		;print the "no" if no carrier
	LXI	D,CARMSG	;print "carrier present"
	MVI	C,PRINT
	CALL	MEX
	RET
;
NOMESG:	DB	'no $'
CARMSG:	DB	'carrier present',CR,LF,'$'
;
; Check for carrier present (NZ=no)
;
CARRCK:	IN	CDPORT		;get carrier status
	ANI	MODCDB		;get carrier detect bit
	CPI	MODCDA		;see if active
	RET
ENDIF	;SECSER
;
SOMESG:
;
IF SECSER
	DB	'North Star Horizon on Second Serial Port V.'
ENDIF
IF HSIO4
	DB	'North Star HSIO-4 Serial Card V.'
ENDIF
IF SCP4
	DB	'Seattle Computer Products Muli-port Serial Card  V.'
ENDIF
;
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0',CR,LF,'$'
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
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command
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
	DB	'PARIT','Y'+80H		;"set parity"
	DW	STPAR
;
	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	CALL	CARRSH		;show carrier present/not present
	LXI	H,SHOTBL	;get table of SHOW subroutines
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
	DW	PSHOW
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
HLPMSG:	DB	CR,LF,'SET command:',CR,LF,LF
;
IF SECSER
	DB	CR,LF,'SET BAUD 300 <or> 1200'
ENDIF
IF HSIO4
	DB	CR,LF,'SET BAUD 110, 300, 600, 1200,'
	DB	' 2400, 4800, 9600, <or> 19200'
ENDIF
IF SCP4
	DB	CR,LF,'SET BAUD 110, 300, 600, 1200,'
	DB	' 2400, 4800, 9600, <or> 19200'
ENDIF
;
	DB	CR,LF,'SET PARITY EVEN[8] <or> ODD[8] <or> NONE'
	DB	CR,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	SBAUD		;no, try to set it
	JC	SETERR		;not-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
; SET PARITY processor
;
STPAR:	LXI	D,PARTBL	;lookup next input item in table
	CALL	TSRCH
	JC	SETERR		;if not found, error
	MOV	A,L		;get parity code
	STA	PARITY		;store it for NITMOD
	LDA	MSPEED		;don't change baud rate
	CALL	SBAUD		;set parity
PSHOW:	CALL	ILPRT		;show parity
	DB	'Parity:',TAB,TAB,' ',0
	LXI	H,PARFND	;find proper message
	LDA	PARITY		;get parity value
	MOV	B,A
FNDP:	MOV	A,M		;see if parity value matches
	ORA	A		;first see if zero
	JZ	SETERR		;should never get here
	CMP	B		;match?
	INX	H		;point to first letter of message
	JZ	CDISP		;matches, type message
FNDNXT:	MOV	A,M
	ORA	A		;see if end of last message
	INX	H
	JP	FNDNXT		;not finished
	INX	H		;increment past parity byte
	JMP	FNDP
;
; PARITY argument table
; Format of the table is:  Starting at PARTBL, the name is
; given (ending with 80H bit set), then the one byte code
; for setting that parity.  The next byte duplicates the
; NEXT parity code (used in PSHOW).  The byte at PARFND
; duplicates the first parity code.
;
PARFND:	DB	EVEN
PARTBL:	DB	'EVE','N'+80H	;even parity, 7 data bits
	DB	EVEN,EVEN8
	DB	'EVEN','8'+80H	;even parity, 8 data bits
	DB	EVEN8,ODD
	DB	'OD','D'+80H	;odd parity, 7 data bits
	DB	ODD,ODD8
	DB	'ODD','8'+80H	;odd parity, 8 data bits
	DB	ODD8,NONE
	DB	'NON','E'+80H	;no parity, 8 data bits
	DB	NONE,0
;
	DB	0		;<<== table terminator
;
;  Print message ending with 80H bit set
;
CDISP:	MOV	A,M		;get character to print
	INX	H		;point to next character
	PUSH	PSW		;save 80H bit
	ANI	7FH		;strip 80H bit just in case
	CALL	TYPE
	POP	PSW
	ORA	A
	JM	CRLF		;finished
	JMP	CDISP
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
;------------------------------------------------------------
;
; End of North Star MEX modem overlay
;
;------------------------------------------------------------
;
	END
