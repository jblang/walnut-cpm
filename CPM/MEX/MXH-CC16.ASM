REV	EQU	16		;overlay revision level
;
; MXH-CC16 MEX Overlay for Columbia Data Prod M64
;
; Use for MEX 1.14 or MEXplus
;
; Application: small CP/M computer known as any of the following....
;
;	       - Columbia Data Products "Shoebox"
;		     Model M64 or M64-1
;	       - Kodak Ektalog Diskette Controller
;	       - CONKEY-64 (local moniker)
;
; SET commands available: (*optional)
;
;	 SET BAUD: controls MEX timing only, use switches on back on unit
;		   for USART
;	 SET PARITY: off, odd or even
;	 SET WORD: 7 or 8
;	 SET STOP: 1, 1.5 or 2
;	 SET PULSE or TONE: type of dialing
;	*SET WAIT: "n" seconds to wait for Modem result.
;	 SET UART: 7 or 8 bit console UART (see SET UART section)
;	*SET VT220: on/off if terminal is VT220
;
;------+--------+----------+----------------------------------------------
; REV  |  Date	|  Author  |	      Description
;------+--------+----------+----------------------------------------------
; 1.6  |12/12/86|  Lill    | - tested DCD (uses CTS, need spec. cable) in
;      |	|	   |   MEX+ REO
;      |	|	   | - added SET WAIT for selection of time to wait
;      |	|	   |   after dialing (see SETDLY etc. in MXO-SM14)
;------+--------+----------+----------------------------------------------
; 1.5  |10/28/86|  Lill    | - cleaned up new code added in 1.4
;      |	|	   | - completed commenting
;      |	|	   | - testing complete on all but DCD and RNG stuff
;------+--------+----------+----------------------------------------------
; 1.4  |10/21/86|  Lill    | - created original MEXplus from MXO-CC13
;      |	|	   |   adding DCD and RNG routines.
;      |	|	   | - added INITB equate
;      |	|	   | - added VT220 option to 8-bit console routine
;      |	|	   | - added SET control of 8-bit and VT220 stuff
;------+--------+----------+----------------------------------------------
; 1.3  |10/19/86|  Keane   | - added hardware DSC (via DTR)
;      |	|	   | - added SET TONE/PULSE
;      |	|	   | - added 8-bit console routines (experimental)
;      |	|	   | - tested with SmarTEAM 1200 (MXO-SM14)
;      |	|	   |   and SmarTEAM 2400 (MXM-2411)
;------+--------+----------+----------------------------------------------
; 1.2  |10/16/86|  Lill/   | - corrected Columbia model number
;      |	|  Keane   | - first fixes for SmartModem (MXO-SM14)
;------+--------+----------+----------------------------------------------
; 1.1  |10/12/86|Jim Lill  | - fixed SET BAUD messages and history etc.
;      |	|	   | - doesn't send dial string to smartmodem
;------+--------+----------+----------------------------------------------
; 1.0  |10/12/86|Tony Keane| - created original, adapting MXO-SX10
;      |	|	   |   by Bill Meahan.
;      |	|	   | - Tested w/acoustic modem only.
;-------------------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
ESC	EQU	1BH
BEL	EQU	7
TAB	EQU	9
XON	EQU	011H
XOFF	EQU	013H
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;---------------------------------------------------------------------------
; Options ......

INITB	EQU	5	;set for initial (startup) baud rate
			;0=110	5=1200
			;1=300	6=2400
			;	7=4800
			;	8=9600
			;	9=19200
PLUS	EQU	FALSE	;set true for MEXplus
VT220	EQU	FALSE	;TRUE if terminal is VT220
WAIT	EQU	TRUE	;TRUE if you use MXO-SM14 and want selectable wait
			;delay after dialing
WAITSEC	EQU	45	;default WAIT time in seconds
;---------------------------------------------------------------------------
; CONKEY port definitions  (serial port 1)
;
PORT	EQU	058H		;CONKEY base port (data or status)
MODCT1	EQU	PORT+1		;modem control port
MODDAT	EQU	PORT		;modem data port
MODCT2	EQU	PORT+1		;modem status port
BAUDRP	EQU	044H		;modem baud rate port, (unused port in CONKEY)
BAUDMD	EQU	045H		;modem baud rate mode control port
AUXPORT	EQU	05EH		;modem aux status port CTS RNG etc.
;
; CONKEY bit definitions
;
MDRCVB	EQU	02H		;modem receive bit (DAV)
MDRCVR	EQU	02H		;modem receive ready
MDSNDB	EQU	01H		;modem send bit
MDSNDR	EQU	01H		;modem send ready bit
;
;
CTSMSK	EQU	01H		;mask for CTS bit
BRKMSK	EQU	8		;mask to set break
PARMSK	EQU	0CFH		;mask to remove parity bits
RNGMSK	EQU	08H		;mask to get ring
OPARIT	EQU	10H		;odd-parity bits
EPARIT	EQU	30H		;even-parity bits
NPARIT	EQU	00H		;no-parity bits
PARTST	EQU	10H		;mask to test parity enabled bit
EVNTST	EQU	20H		;mask to test even parity bit
MODEMK	EQU	06EH		;mode mask
MODEGO	EQU	027H		;default control command
DTRON	EQU	027H		;default control with DTR on
DTROFF	EQU	025H		;default control with DTR off
RSTCTL	EQU	040H		;reset USART command
WORD7	EQU	08H		;mask for 7 bit characters
WORD8	EQU	0CH		;mask for 8 bit characters
WORD8T	EQU	04H		;mask to test for 8 bit characters
STBIT1	EQU	040H		;mask to set 1 stop bit
STBI15	EQU	080H		;mask to set 1.5 stop bits
STBIT2	EQU	0C0H		;mask to set 2 stop bits
;
; MEX service processor stuff ... MEX supports an overlay service
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
; next 2 lines are MEXplus changes
;
	DB	0C3H	;flags a LOADable file
	DS	2	;MEX has a jump start here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	YES	;yes=	   modem \ / These 2 locations are not	103H
SMODEM:	DB	YES	;yes=Smartmodem  / \ referenced by MEX		104H
TPULSE:	DB	'T'	;smart modem touch tone/dial pulse flag 	105H
CLOCK:	DB	46	;clock speed x .1, up to 25.5 mhz.		106H
			;46 checks as correct for CONKEY
MSPEED:	DB	INITB	;sets display time for sending a file		107H
			;0=110	1=300  2=450  3=600  4=710
			;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	2	;default time to send character in		108H
			;terminal mode file transfer (0-9)
			;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	2	;end-of-line delay after CRLF in terminal	109H
			;mode file transfer for slow BBS systems
			;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5	;number of directory columns			10AH
SETFL:	DB	YES	;yes=user-defined SET command			10BH
SCRTST:	DB	YES	;yes=if home cursor and clear screen		10CH
			;routine at CLRSCRN
	DB	0	;was once ACKNAK, now spare			10DH
BAKFLG:	DB	NO	;yes=make .BAK file				10EH
CRCDFL:	DB	YES	;yes=default to CRC checking			10FH
			;no=default to Checksum checking
TOGCRC:	DB	YES	;yes=allow toggling of Checksum to CRC		110H
CVTBS:	DB	NO	;yes=convert backspace to rub			111H
TOGLBK:	DB	YES	;yes=allow toggling of bksp to rub		112H
ADDLF:	DB	NO	;no=no LF after CR to send file in		113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR		114H
TRNLOG:	DB	NO	;yes=allow transmission of logon		115H
			;write logon sequence at location LOGON
SAVCCP:	DB	YES	;yes=do not overwrite CCP			116H
LOCNXT:	DB	NO	;yes=local cmd if EXTCHR precedes		117H
			;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES	;yes=allow toggling of LOCNXTCHR		118H
LSTTST:	DB	YES	;yes=allow toggling of printer on/off		119H
			;in terminal mode. Set to no if using
			;the printer port for the modem
XOFTST:	DB	NO	;yes=allow testing of XOFF from remote		11AH
			;while sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after sending CR while	11BH
			;transmitting a file in terminal mode
TOGXOF:	DB	YES	;yes=allow toggling of XOFF testing		11CH
IGNCTL:	DB	NO	;yes=do not send control characters		11DH
			;above CTL-M to CRT in terminal mode
			;no=send any incoming CTL-char to CRT
EXTRA1:	DB	WAITSEC	;passes wait time to Modem overlay		11EH
EXTRA2:	DB	0	;for future expansion				11FH
BRKCHR:	DB	'@'-40H	;^@ = Send a 300 ms. break tone 		120H
NOCONN:	DB	'N'-40H	;^N = Disconnect from phone line		121H
LOGCHR:	DB	'L'-40H	;^L = Send logon				122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer				123H
UNSVCH:	DB	'R'-40H	;^R = Close input text buffer			124H
TRNCHR:	DB	'T'-40H	;^T = Transmit file to remote			125H
SAVCHR:	DB	'Y'-40H	;^Y = Open input text buffer			126H
EXTCHR:	DB	'^'-40H	;^^ = Send next character			127H
;
; unused equates grouped here
;
	DB	0	;not used					128H
	DB	0	;not used					129H
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:	IN	MODCT1		;in modem control port			12AH
	RET			;					12CH
	DS	7		;spares if needed for non-CONKEY	12DH
;
OTDATA:	OUT	MODDAT		;out modem data port			134H
	RET			;					136H
	DS	7		;spares if needed for non-CONKEY	137H
;
INPORT:	IN	MODDAT		;in modem data port			13EH
	RET			;					140H
	DS	7		;spares if needed for non-CONKEY	141H
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready		148H
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready	14BH
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready		14EH
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready		151H
;
;----------------------------------------------------------------------------
; MEXplus changes.....
;   -was unused area (must total 12 bytes)
;
DCDTST:	JMP	DCDVEC		;jump to carrier detect routine 	154H
RNGTST:	JMP	RNGVEC		;jump to ring detect routine		157H

	DS	6		;remainder of space
;----------------------------------------------------------------------------
; Special modem function jump table:
;
LOGON:	DS	2	;needed for MDM compat, not ref'd by MEX	160H
DIALV:	DS	3	;dial digit in A (see info at PDIAL)
DISCV:	JMP	DISCON	;disconnect the modem
GOODBV:	JMP	GOODBYE	;called before exit to CP/M
INMODV:	JMP	NITMOD	;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD	;set baud rate
NOPARV:	JMP	DUMMY	;set modem for no-parity
PARITV:	JMP	DUMMY	;set modem parity
SETUPV:	JMP	SETCMD	;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3	;not used with MEX
VERSNV:	JMP	SYSVER	;Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK	;send a break
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

	ORG	TPA + 100H	;Leave space for MEX Plus.

; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	09BH,'$'	;clear to end-of-screen
CLSMSG:	DB	LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF	;clear whole screen
	DB	LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,'$'	;'generic' CLS
;
; Data area
;
ERRFLG:	DB	0		;connection error code
MODMOD	DB	MODEMK		;uart-control byte image
BAUDSV:	DB	01		;current baud rate (dflt 300)
MODCTB:	DB	MODEGO		;modem control byte

;--------------------------------------------------------------------------
; Modem initialization.

NITMOD:
	CALL	URTSET		;Extra console patch init (if installed)
	MVI	A,INITB		;default IBAUD eqaute setting
	CALL	PBAUD		;Currently ignored by CONKEY, sets MEX timing
	LDA	MODMOD		;default mode command in A
ALTINI:				;alternate entry point for mode change routines
	PUSH	PSW		;save mode command on stack
	XRA	A		;force 8251 USART to look for reset command
	OUT	MODCT2
	OUT	MODCT2
	OUT	MODCT2
	MVI	A,RSTCTL	;reset USART
	OUT	MODCT2
	POP	PSW		;retreive mode command
	STA	MODMOD		;save copy for future use
	OUT	MODCT2		;set USART mode
	MVI	A,MODEGO	;enable transmitter and receiver
	OUT	MODCT2
	RET
;
;--------------------------------
; CONKEY cause disconnect routine
;
DISCON:	MVI	A,DTROFF	;turn off DTR
	OUT	MODCT2		;	"
				;
	MVI	B,10		;wait 1 second
	MVI	C,TIMER		;	"
	CALL	MEX		;	"
				;
	MVI	A,DTRON		;turn on DTR
	OUT	MODCT2		;	"
				;
	MVI	B,10		;wait 1 more second
	MVI	C,TIMER		;	"
	CALL	MEX		;	"
				;
	RET			;return to calling program

;---------------------------
; CONKEY  send-break routine
;
PBREAK:	LDA	MODCTB		;get the last modem control byte
	ORI	BRKMSK		;set the transmit break bit low
	OUT	MODCT2		;send it to the modem
	LXI	B,02FEH		;B=2, C=254
	CALL	MEX		;send a space tone for 200 ms.
	LDA	MODCTB		;get the last modem control byte
	OUT	MODCT2		;restore to normal
;
; exit routine
;
DUMMY:	RET			;we don't need one
;
;-----------------------------------
; MEXplus DCD and RNG routines......
;
DCDVEC:	IN	AUXPORT		;Conkey ring/CTS port
	ANI	CTSMSK		;isolate status bit (Look for CTS instead)
	JNZ	SETACC		;0=carrier detected
	JMP	CLRACC		;
;.......			;
				;
RNGVEC:	IN	AUXPORT		;Conkey ring/CTS port
	ANI	RNGMSK		;mask for bit
	JNZ	SETACC		;0=ring detected
	JMP	CLRACC		;
;.........			;
				;
CLRACC:	MVI	A,0		;make A=0
	RET			;
SETACC:	MVI	A,0FFH		;make A=255
	RET			;
				;
;------------------------
; Set baud-rate code in A
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	STA	MSPEED
	ADD	A		;double value to get word address
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	C,M		;fetch code
	INX	H
	MOV	B,M
	MVI	A,076H
	OUT	BAUDMD		;control counter
	MOV	A,C
	OUT	BAUDRP
	MOV	A,B
	OUT	BAUDRP		;good rate, set it
PBEXIT:	POP	B		;all done
	POP	D
	POP	H
	RET
;
; table of baud rate divisors for supported rates
;
BAUDTB:	DW	1048,384,256,192,162	;110,300,450,610,710
	DW	96,48,24,12,6		;1200,2400,4800,9600,19200
;
;-----------------------
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
	RET
;
SOMESG:

IF PLUS
	DB	'MEXplus for Conkey-64'
ENDIF

IF NOT PLUS
	DB	'MEX for Conkey-64'
ENDIF

IF VT220
	DB	', VT220 Exit Option'
ENDIF
	DB	CR,LF,' Version: '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD	10+'0'
	DB	'$'
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
; SET command --
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
	DB	'PARIT','Y'+80H		;"set parity"
	DW	SETPAR
	DB	'WOR','D'+80H		;"set bits" (word)
	DW	SETBIT
	DB	'STO','P'+80H		;"set stop"
	DW	SETSTO
	DB	'PULS','E'+80H		;"set pulse dialing"
	DW	SETPUL
	DB	'TON','E'+80H		;"set tone dialing"
	DW	SETTON
IF WAIT
	DB	'WAI','T'+80H		;"set wait time"
	DW	SETDLY
ENDIF
	DB	'UAR','T'+80H		;"set UART mode"
	DW	SETURT
IF VT220
	DB	'VT22','0'+80H		;"set VT220 mode"
	DW	SETVT2
ENDIF
;
	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:
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
	DW	PARSHO
	DW	WORDHO
	DW	STOSHO
	DW	DIASHO
IF WAIT
	DW	DLYSHO
ENDIF
	DW	URTSHO
IF VT220
	DW	VT2SHO
ENDIF
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
HLPMSG:	DB	CR,LF,'SET command, Conkey-64 version:'
	DB	LF
	DB	CR,LF,'  SET BAUD 1200 etc. for MEX timing'
	DB	CR,LF,'      use MOD switches on rear of computer'
	DB	CR,LF,'  SET PARITY ODD <or> EVEN <or> OFF'
	DB	CR,LF,'  SET WORD 7 <or> 8'
	DB	CR,LF,'  SET STOP 1 <or> 1.5 <or> 2'
	DB	CR,LF,'  SET PULSE dialing'
	DB	CR,LF,'  SET TONE  dialing'
IF WAIT
	DB	CR,LF,'  SET WAIT "n" seconds'
ENDIF
	DB	CR,LF,'  SET UART 7 <or> 8'
IF VT220
	DB	CR,LF,'  SET VT220 Exit Reset ON <or> OFF'
ENDIF
	DB	CR,LF,'$'
;
;-------------------
; SET BAUD processor
;
STBAUD:	CALL	ILPRT		;ring console bell
	DB	BEL,0		;a warning for the switches
	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;no-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'BAUD:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
;---------------------
; SET PARITY processor
;
SETPAR:
	LXI	D,PARTBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	LDA	MODMOD		;get current mode byte
	ANI	PARMSK		;mask away current parity bits
	ORA	L		;add new parity bits
	CALL	ALTINI
PARSHO:
	CALL	ILPRT		;show current status
	DB	'PARITY:',TAB,' ',0
	LDA	MODMOD		;get current mode word
	ANI	PARTST		;test for parity enabled
	JNZ	PAR		;skip if it is
	CALL	ILPRT
	DB	'Off',0
	RET
PAR:
	LDA	MODMOD
	ANI	EVNTST		;test mode byte for even parity
	JNZ	PAREVN		;skip if it is
	CALL	ILPRT
	DB	'Odd',0
	RET
PAREVN:
	CALL	ILPRT
	DB	'Even',0
	RET
;
;PARITY argument table
;
PARTBL:	DB	'OD','D'+80H
	DB	OPARIT,0
	DB	'EVE','N'+80H
	DB	EPARIT,0
	DB	'OF','F'+80H
	DB	NPARIT,0
	DB	0
;
;------------------
;SET WORD processor
;
SETBIT:
	LXI	D,BITTBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	LDA	MODMOD		;get current mode command
	ANI	(NOT WORD8) AND	255	;mask away current bits
	ORA	L		;set new bits
	CALL	ALTINI		;change mode
WORDHO:
	CALL	ILPRT		;show current status
	DB	'WORD:',TAB,' ',0
	LDA	MODMOD		;get current mode word
	ANI	WORD8		;test for number of bits
	JZ	SETERR
	ANI	WORD8T
	JNZ	B8		;skip if it is
	CALL	ILPRT
	DB	'7 Bits',0
	RET
B8:
	CALL	ILPRT
	DB	'8 Bits',0
	RET
;
;WORD argument table
;
BITTBL:	DB	'8'+80H
	DB	WORD8,0
	DB	'7'+80H
	DB	WORD7,0
	DB	0
;
;SET STOP processor
;
SETSTO:
	LXI	D,STPTBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	LDA	MODMOD		;get current mode command
	ANI	(NOT STBIT2) AND 255	 ;mask away current bits
	ORA	L		;set new bits
	CALL	ALTINI		;change mode
STOSHO:
	CALL	ILPRT		;show current status
	DB	'STOP:',TAB,' ',0
	LDA	MODMOD		;get current mode word
	ANI	STBIT2		;test for number of bits
	JZ	SETERR
	RLC
	RLC
	ADD	A		;form word table index
	LXI	H,STJTBL	;get address of jump table
	ADD	L		;point to address of proper routine
	MOV	L,A
	MVI	A,0
	ADC	H
	MOV	H,A
	MOV	A,M		;get address of proper routine
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL			;branch to proper routine
PRT1:
	CALL	ILPRT
	DB	'1 Bit',0
	RET
PRT2:
	CALL	ILPRT
	DB	'2 Bits',0
	RET
PRT15:
	CALL	ILPRT
	DB	'1.5 Bits',0
	RET
;
STJTBL:				;jump table for stop bit show routines
	DW	SETERR
	DW	PRT1
	DW	PRT15
	DW	PRT2
;
;STOP argument table
;
STPTBL:	DB	'1'+80H
	DB	STBIT1,0
	DB	'1.','5'+80H
	DB	STBI15,0
	DB	'2'+80H
	DB	STBIT2,0
	DB	0
;
;-----------------------------
;SET PULSE and TONE processors

SETPUL:
	MVI	A,'P'		;Set modem to pulse dial mode
	STA	TPULSE		;	"	   "
	JMP	DIASHO		;Print out new mode.


SETTON:
	MVI	A,'T'		;Set modem to tone dial mode
	STA	TPULSE		;	"	   "
	JMP	DIASHO		;Print out new mode.


DIASHO:	LDA	TPULSE		;Output dialing type message
	CPI	'P'		;	"	   "
	JZ	PULPRN		;	"	   "
	CALL	ILPRT		;show current status
	DB	'TONE',TAB,' Dial',0
	RET			;Return to calling program
				;
PULPRN:	CALL	ILPRT		;show current status
	DB	'PULSE',TAB,' Dial',0
	RET			;Return to calling program

;-------------------------------------------------
; SET WAIT processor

SETDLY:	MVI	C,EVALA
	CALL	MEX
	MOV	A,H
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	EXTRA1

DLYSHO:	CALL	ILPRT
	DB	'WAIT:',TAB,' ',0
	LDA	EXTRA1
	MOV	L,A
	MVI	H,0
	MVI	C,DECOUT
	CALL	MEX
	CALL	ILPRT
	DB	' Seconds for Modem Result',0
	RET

;-------------------------------------------------
; SET UART Processor
;   as received the Conkey-64 BIOS runs the console USART at 7-bit. This
;   is wholly adequate for normal hobbyist CP/M type communications, a
;   problem was encountered when running the unit on a network to a
;   large mainframe. Here, 8-bit was required for terminal ID and other
;   "invisible" stuff.	The solution was the UART control routines
;   at the end of this overlay.  This SET command allows changing
;   it from normal 7-bit to 8-bit.  This option was included for
;   other experiments A/R. Normally it's 8-Bit at power. This can run
;   like this for all work.
;
SETURT:
	LXI	D,URTTBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	MOV	A,L		;
	STA	URTFLG		;set flag
	CALL	URTSET		;set UART itself
URTSHO:
	CALL	ILPRT		;show current status
	DB	'UART:',TAB,' ',0
	LDA	URTFLG		;get current mode word
	ORA	A		;
	JNZ	URT		;skip if it is
	CALL	ILPRT		;print it
	DB	'7 Bit Console',0
	RET			;
				;
URT:	CALL	ILPRT		;print it
	DB	'8 Bit Console',0		;
	RET			;
;
;UART argument table
;
URTTBL:	DB	'7'+80H
	DB	0,0
	DB	'8'+80H
	DB	0FFH,0
	DB	0
;
;-------------------------------------------------
; SET VT220 Processor
;   again this was a mainframe problem where, software on it changed
;   the VT220 being used back and forth from VT100 mode to VT220 mode.
;   If you left MEX while still in VT220 mode you'd get strange VT220
;   only characters. This SET command will turn on/off an option to
;   send a VT100 reset string to the terminal upon exiting MEX.
;

SETVT2:
	LXI	D,VT2TBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	MOV	A,L		;
	STA	VT2FLG		;

VT2SHO:
	CALL	ILPRT		;show current status
	DB	'VT220:',TAB,' ',0
	LDA	VT2FLG		;get current mode word
	ORA	A		;
	JNZ	VT2		;skip if it is
	CALL	ILPRT		;
	DB	'OFF',0		;
	RET			;
				;
VT2:	CALL	ILPRT		;print it
	DB	'ON',0		;
	RET			;
;
;VT220 argument table
;
VT2TBL:	DB	'OF','F'+80H
	DB	0,0
	DB	'O','N'+80H
	DB	0FFH,0
	DB	0

;-------------------------------------------------
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


;+----------------------------------------------------------------------+
;|	       SPECIAL 8 BIT CONSOLE TRANSIENT ROUTINES 		|
;+----------------------------------------------------------------------+
; Conkey has UART set up for 7-bit even parity....  this causes problems
; with VT-100 on mainframes and who knows what else.  This will make
; console UART port eight bit. Your terminal must be same.  Port
; is restored to normal on MEX exit.
x
CINVEC:	DS	2		;Storage for current console vectors.
COUVEC:	DS	2		;	"	   "	      "
URTFLG:	DB	0FFH		;beware... do not default to 0

IF NOT VT220
VT2FLG:	DB	0		;VT220 exit string not used
ENDIF

IF VT220
VT2FLG:	DB	0FFH		;VT220 exit string (VT100 mode) used.
ENDIF

URTSET:	PUSH	D		;save regs
	PUSH	H		; "  "
	LDA	URTFLG		;get flag
	ORA	A		;test it
	JZ	SEVEN		;jump to Seven or fall to Eight
	MVI	A,01000000B	;Select mode register.
	OUT	41H		;	"
	MVI	A,01101110B	;Set UART to 8 bit no parity 1 stop.
	OUT	41H		;	"	   "
	MVI	A,00100111B	;re-enable transmitter and receiver.
	OUT	41H		;	"	   "	       "
				;
	LHLD	0001H		;Save current console BIOS vectors.
	LXI	D,7		;	"	   "	      "
	DAD	D		;	"	   "	      "
	PUSH	H		;	"	   "	      "
	MOV	A,M		;	"	   "	      "
	STA	CINVEC+0	;	"	   "	      "
	INX	H		;	"	   "	      "
	MOV	A,M		;	"	   "	      "
	STA	CINVEC+1	;	"	   "	      "
	INX	H		;	"	   "	      "
	INX	H		;	"	   "	      "
	MOV	A,M		;	"	   "	      "
	STA	COUVEC+0	;	"	   "	      "
	INX	H		;	"	   "	      "
	MOV	A,M		;	"	   "	      "
	STA	COUVEC+1	;	"	   "	      "
				;
	POP	H		;Set up new vectors.
	LXI	D,UARTIN	;	"
	MOV	M,E		;	"
	INX	H		;	"
	MOV	M,D		;	"
	INX	H		;	"
	INX	H		;	"
	LXI	D,UARTOU	;	"
	MOV	M,E		;	"
	INX	H		;	"
	MOV	M,D		;	"
				;
	POP	H		;Restore registers.
	POP	D		;	"
				;
	RET			;Return to calling program.
				;
SEVEN:	MVI	A,01000000B	;Select mode register.
	OUT	41H		;	"
	MVI	A,01111010B	;Set UART to 7 bit even parity 1 stop.
	OUT	41H		;	"	   "
	MVI	A,00100111B	;re-enable transmitter and receiver.
	OUT	41H		;	"	   "	       "
				;
	LHLD	0001H		;Save current console BIOS vectors.
	LXI	D,7		;	"	   "	      "
	DAD	D		;	"	   "	      "
	LDA	CINVEC+0	;	"	   "	      "
	MOV	M,A		;	"	   "	      "
	INX	H		;	"	   "	      "
	LDA	CINVEC+1	;	"	   "	      "
	MOV	M,A		;	"	   "	      "
	INX	H		;	"	   "	      "
	INX	H		;	"	   "	      "
	LDA	COUVEC+0	;	"	   "	      "
	MOV	M,A		;	"	   "	      "
	INX	H		;	"	   "	      "
	LDA	COUVEC+1	;	"	   "	      "
	MOV	M,A		;	"	   "	      "
				;
	POP	H		;Restore registers.
	POP	D		;	"
	RET			;Return to calling program.
				;
GOODBYE:LDA	VT2FLG		;check VT220 flag
	ORA	A		;it set then send string
	LXI	D,VTMSG		;load exit string
	MVI	C,PRINT		;send it to terminal
	CNZ	MEX		;let MEX do it
	MVI	A,0		;set A to 0
	STA	URTFLG		;change URT flag
	CALL	URTSET		;make UART normal (7-bit)
	LXI	D,EXIMSG	;load DE with Exit Msg.
	MVI	C,PRINT		;load exit msg string (gets UART working right)
	CALL	MEX		;let MEX do it
	RET			;
				;
EXIMSG:	DB	CR,LF		;send some chars. to screen after resetting	DB	'   ',CR,LF,'$'
	DB	' ',CR,LF,'$'	;the UART

VTMSG:	DB	'        ',ESC,'[61"p',CR,LF,'$'	;VT100 mode string

UARTIN:	IN	41H		;Wait for data.
	ANI	00000010B	;	"
	JZ	UARTIN		;	"
				;
	IN	41H		;Check for errors.
	ANI	00110000B	;	"
	JZ	NOERR		;	"
	MVI	A,00110111B	;Reset the error flags.
	OUT	41H		;	"
				;
NOERR:	IN	40H		;Load acc with data.
				;
	RET			;Return to calling program.



UARTOU:	IN	41H		;Wait for UART to become ready.
	ANI	00000001B	;	"	   "
	JZ	UARTOU		;	"	   "
				;
	MOV	A,C		;Output data to console UART.
	OUT	40H		;	"	   "
	RET			;Return to calling program.
	ENDIF			;
				;
				;
	END			;end of MXH-CCnn
