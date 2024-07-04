; TITLE 'MEX overlay for the NCR DMV using the K801 adapter'
; Comment out above line if assembling with asm.com
; MXO-DM20.ASM - NCR DecisionMate V overlay file for MEX1.14.  02/10/87
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; This file adapts the NCR DMV to Mex1.14. It assumes that you have the 
; K801 (switchable) adapter, with the ifsel set to 1A (as recommended by 
; NCR for the communication port). If you are using a different ifsel,
; change the value of the PORT equate.
;
;	MEX NOTES: Several of the data locations below (from 0103h to
;	0194h are not referenced by MEX, and are retained only for MDM740
;	compatability. These locations are marked with an "*1".
;
; Edit this file for your preferences. Pay particular attention to 
; the DFLTBD, DFLTPR, DFLTPA, AFLTPA, DFLTDT, AFLTDT, DFLTST, AFLTST,
; NOTASC, and FNBUF
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at the value specified by DFLTBD when the program is first called up.
; If DFLTBD is changed, DFLTPR must also be changed (get the value from
; the table of baud rate parameters). You may also use the set command to 
; change the parity, data bits, and stop bits. Similarly, DFLTPA and AFLTPA
; (for parity), DFLTST and AFLTST (for stop bits), and DFLTDT and AFLTDT
; (for data bits) must be changed for your preferences. Most likely the
; settings you want will be NONE, 'N', STOP1, '1', DATA8, and '8'
; respectively.
;
; You may also use the "SET" command to temporarily change the definition
; of the DMV's function keys. Any redefinition will remain until a cold 
; boot is performed or the key is redefined. The maximum length for any
; function key string is defined by FNBUF, although the total may not
; exceed 236 characters. The strings follow Mex conventions (i.e. between 
; double quotes, Control characters entered as, for instance, ^M),  
; additionally, a '^' may be entered by typing '^~'. Note that a '\' is 
; entered as just that, not as '\\'.
;
; Finally, you may use the SET DUMP command to view memory. The format is
; "SET DUMP xxxxx yyyyy", where xxxxx is the start address, and yyyyy is 
; the end address of the memory to display. The two numbers are entered
; in either hex or decimal, depending on the current values of the hex and
; dec STAT switches.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/06/87 - Added SET commands for data bits, stop bits, and parity, 
;	     and added second parameter to dump command. Version 2.0
;							- Brent B. Powers
;
; 02/20/87 - Fixed a bug with setting a function key to a zero
;	     length string ("")				- Brent B. Powers
;
; 02/10/87 - Adapted from MXO-OS14 and M7NC-1		- Brent B. Powers
;	     written by, respectively, Bob Schultz and Robert Flagg
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL	EQU	07H		; Bell
CR	EQU	0DH		; Carriage return
ESC	EQU	1BH		; Escape
LF	EQU	0AH		; Linefeed
TAB	EQU	09H		; Tab
TPA	EQU	0100H		; Standard start of TPA
DIM	EQU	')'		; Highlighting off
UNDIM	EQU	'('		; Highlighting on
CLS	EQU	01AH		; Clear Screen
PRINV	EQU	'G'		; Prefix for invert/uninvert
INVERT	EQU	'4'		; Invert on
UNINV	EQU	'0'		; Invert off
;
NOTASC	EQU	'.'		; Char. to print for unprintable ascii codes
FNBUF	EQU	020h		; Maximum length of a function key string
;
VERSN	EQU	20
;
YES	EQU	0FFH
NO	EQU	0
;
DFLTBD	EQU	05		; Default Baud rate: use 0 for 110 baud,
				; 1 for 300, 5 for 1200, 6 for 2400,
				; 8 for 9600, and 9 for 19200.
DFLTPR	EQU	00F7H		; Default rate parameter for the IO chip.
				; use F4h for 110 baud, F5h for 300,
				; F7h for 1200, FBh for 2400, FCh for 9600,
				; and FEh for 19200
;
; DATA BITS EQUATES
DATA8	EQU	0CH
DATA7	EQU	08H
DATA6	EQU	04H
DATA5	EQU	00H
;
;	fill this in with your default data bits
DFLTDT	EQU	DATA8
;	fill this in with the ascii representation '5', '6', '7', or '8'
AFLTDT	EQU	'8'
;
;
; PARITY EQUATES
NONE	EQU	000H
ODD	EQU	010H
EVEN	EQU	030H
;
;	fill this in with your default parity
DFLTPA	EQU	NONE
;	fill this in with the ascii representation  'N', 'E', or 'O'
AFLTPA	EQU	'N'
;
;
; STOP BITS EQUATES
STOP1	EQU	040H
STOP2	EQU	0C0H
;
;	fill this in with your default stop bits
DFLTST	EQU	STOP1
;	fill this in with the ascii representation '1' or '2'
AFLTST	EQU	'1'
;
;
DFLTPM	EQU	DFLTST+DFLTDT+DFLTPA+1
;
PORT	EQU	070H		; NCR modem base
MODDAT	EQU	PORT		; Data port
MODSTAT EQU	PORT+1		; Status port
MODMODE EQU	PORT+2		; Mode port
MODCMD	EQU	PORT+3		; Command port
WRITE	EQU	4		; Offset to the above for write ops
;
RCVB	EQU	02H		; Modem receive bit
RCVR	EQU	02H		; Modem receive ready
SNDB	EQU	01H		; Modem send bit
SNDR	EQU	01H		; Modem send ready bit
;
; MEX service processor stuff
;
MEX	EQU	0D00H		; Address of Mex service processor
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
PRINT	EQU	09		; As BDOS 9
CONOUT	EQU	02		; As BDOS 2
;
;
	ORG	100H
;
	DS	3		; (for  "JMP   START" instruction)
;
PMMI:	DB	NO		; Yes=PMMI S-100 Modem, *1		103H
SMART:	DB	YES		; Yes=HAYES Smartmodem, no=non-PMMI, *1	104H
TOUCH:	DB	'T'		; T=Touch, P=Pulse (Smartmodem-only), *1	105H
CLOCK:	DB	40		; Clock speed in MHz x10, 25.5 MHz max.	106H
				; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	DFLTBD		; Change the DFLTBD equate above rather	107H
				; than this byte
BYTDLY:	DB	3		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				; Default time to send character in ter-
				; Minal mode file transfer for slow BBS.
CRDLY:	DB	5		; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				; Default time for extra wait after CRLF
				; In terminal mode file transfer
NOCOL:	DB	5		; Number of DIR columns shown		10AH
SETTST:	DB	YES		; Yes=user-added Setup routine		10BH
SCRTST:	DB	YES		; Cursor control routine 		10CH
	DB	0		; This was once NAK/ACK, not used, *1	10DH
BAKFL:	DB	NO		; Yes=change any file same name to .BAK	10EH
CRCDFT:	DB	YES		; Yes=default to CRC checking		10FH
TOGCRC:	DB	YES		; Yes=allow toggling of CRC to Checksum	110H
CONVBS:	DB	NO		; Yes=convert rub to backspace		111H
TOGBS:	DB	YES		; Yes=allow toggling of rub to bksp	112H
ADDLF:	DB	NO		; No=no LF after CR to send file in	113H
				; Terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR	114H
TRNLOG:	DB	YES		; Yes=allow transmission of logon	115H
				; Write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP		116H
LOCNXT:	DB	NO		; Yes=local command if EXTCHR precedes	117H
				; No=external command if EXTCHR precedes
TOGLOC:	DB	YES		; Yes=allow toggling of LOCONEXTCHR	118H
LSTTST:	DB	YES		; No=using modem on printer port		119H
XOFTST:	DB	NO		; Yes=checks for XOFF from remote while	11AH
				; Sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after CR while	11BH
				; Sending a file in terminal mode
TOGXOF:	DB	YES		; Yes=allow toggling of XOFF checking	11CH
FILTER:	DB	YES		; Yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		; For future expansion, *1		11EH
EXTRA2:	DB	0		; For future expansion, *1		11FH
BRKCHR:	DB	'@'-40H		; ^@ = Send 50 ms. break tone		120H
NOCONT:	DB	'N'-40H		; ^N = Disconnect from phone line	121H
LOGCHR:	DB	'L'-40H		; ^L = Send logon			122H
LSTCHR:	DB	'P'-40H		; ^P = Toggle printer			123H
UNSAVE:	DB	'R'-40H		; ^R = Close input text buffer		124H
TRANCHR:DB	'T'-40H		; ^T = Transmit file to remote		125H
SAVECHR:DB	'Y'-40H		; ^Y = Open input text buffer		126H
EXTCHR:	DB	']'-40H		; ^] = Send next character		127H
;
;
	DS	2		; PMMI specific, *1			128H
;
INCTL1:	IN	MODSTAT		; In modem control port			12AH
	RET
	DS	7
OUTDAT:	OUT	MODDAT+WRITE	; Out modem data port			134H
	RET
	DS	7
INDAT:	IN	MODDAT		; In modem data port			13EH
	RET
	DS	7
MSKRCV:	ANI	RCVB		; Bit to test for receive ready
	RET
TSTRCV:	CPI	RCVR		; Value of receive bit when ready
	RET
MSKSND:	ANI	SNDB		; Bit to test for send ready
	RET
TSTSND:	CPI	SNDR		; Value of send bit when ready
	RET
	DS	12
;
LOGON:	DS	2		; For user message, *1		160H
	DS	3		; 				162H
DISCV:	DS	3		; Use Mex's routine		165H
GDBYEV:	JMP	GDBYE		; 				168H
MINITV:	JMP	INITMOD		; Go to user written routine	16BH
NEWBDV:	JMP	SETBD		; Sets baud rate associated with#16EH
	RET			; (by-passes PMMI routine), *1	171H
	NOP
	NOP
	RET			; (by-passes PMMI routine), *1	174H
	NOP
	NOP
SETUPV:	JMP	SETUPR		; 				177H
	DS	3		; Old call to special menu, *1	17AH
VRMSGV:	JMP	SYSVER		; 				17DH
BRKV:	JMP	SENDBRK		; 				180H
;
; Do not change the following six lines. None should be used, and are
; retained for overlay compatibility. Rumor says they're gone in MexPlus.
ILPRTV:	DS	3		; Use Mex Fn 240		183H
INBUFV:	DS	3		; Use Mex Fn 10			186H
ILCMPV:	DS	3		; Use Table lookup Fn 247	189H
INMDMV:	DS	3		; Use Mex Fn 255		18CH
	DS	3		; Once NextScnv, not supported, *1
				; 				18FH
TIMERV:	DS	3		; Use Mex Fn 254		192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCR is clear
; entire screen.  Must use 9 bytes each, (pad with NOPs if necessary),
; and SCRTST must be yes
;
CLREOS:	LXI	D, CLEOS
	MVI	C, PRINT
	CALL	MEX
	RET
;
CLRSCR:	MVI	C, PRINT
	LXI	D, CLSC
	JMP	MEX
;
;	End of fixed format area
;
CLSC:	DB	CLS, '$'
CLEOS:	DB	ESC, 'Y$'
;
SYSVER:	CALL	ILPRT
	DB	'NCR Decision Mate V overlay ',ESC,DIM
	DB	'V',VERSN/10+'0','.',VERSN MOD 10+'0'
	DB	' for the K801 adapter',ESC,UNDIM
	DB	' by Brent B. Powers.',CR,LF,0
	RET
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0B00H if using the
;	Hayes Smartmodem or by address 0D00H otherwise.
;=======================================================================
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:MVI	A, 1DH		; SEND BREAK TONE
	JMP	GDBYE1
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GDBYE:	MVI	A, 05H		; SEND BREAK, TURN OFF DTR
;
GDBYE1:	OUT	MODCMD+WRITE	; TAKE COMMAND REGISTER OUT
	IN	MODCMD
	IN	MODCMD		; WAIT TO CLEAR
	MVI	B, 3		; WAIT 300 MS.
	MVI	C, TIMER
	CALL	MEX
	MVI	A, 37H		; NORMAL SEND/RECEIVE WITH DTR LOW
	OUT	MODCMD+WRITE	; SEND TO COMMAND REGISTER
	IN	MODCMD
	IN	MODCMD		; WAIT TO SET
	XRA	A		; CLEAR AND LEAVE
	RET
;
;
; Set up the 2651 ports
INITMOD:MVI	A, DFLTBD	; DEFAULT TRANSFER TIME TO 300 BAUD
	STA	MSPEED
	XRA	A		; SET RTS, FLAGS, DTR, DISABLE R/T
	OUT	MODCMD+WRITE	; PUT COMMAND REGISTER OUT OF MODE
	IN	MODCMD		; MAKE SURE IT IS NOW CLEAR
	IN	MODCMD		; TRY ONCE MORE
INITPM:	MVI	A, DFLTPM	; N81
	OUT	MODMODE+WRITE	; SEND TO MODE REGISTER 1
;
INITMOD1:
	MVI	A, DFLTPR	; START WITH DEFAULT BAUD, INTERNAL 5.0 CLOCK
				; AND DEFAULT SERIAL PORT PARAMETERS
	OUT	MODMODE+WRITE	; SEND TO MODE REGISTER 2
	MVI	A, 37H		; RESET RTS, FLAGS, DTR LOW, ENABLE R/T
	OUT	MODCMD+WRITE	; SEND TO COMMAND REGISTER
	IN	MODCMD		; CLEAR ANY INCOMING CHARS.
	IN	MODCMD		; TRY ONCE MORE
	XRA	A		; CLEAR THE 'A' REG.
	RET
;
SETUPR:	MVI	C, SBLANK	; ANY ARGUMENTS?
	CALL	MEX
	JC	TELL		; NO, GO DISPLAY OPTIONS
	
	LXI	D, CMDTBL	; YES
	MVI	C, LOOKUP
	CALL	MEX		; PARSE ARGUMENT
	PUSH	H		; SAVE ANY PARSED ARGUMENT ADRS ON STACK
	RNC			; IF WE HAVE ONE, RETURN TO IT
	POP	H		; OOPS, INPUT NOT FOUND IN TABLE
SETERR:	CALL	ILPRT		; TELL USER INPUT NOT VALID
	DB	CLS,CR,LF,LF,'++ Invalid SET command ++',CR,LF,0
	JMP	TELL1
;
CMDTBL:	DB	'BAU','D'+80H	; Set Baud rate
	DW	STBAUD
	DB	'PARIT','Y'+80H	; Set Parity
	DW	SETPAR
	DB	'BIT','S'+80H	; Set Data Bits
	DW	SETBIT
	DB	'STO','P'+80H	; Set Stop Bits
	DW	SETSTP
	DB	'KE','Y'+80H	; Set function key
	DW	SETKEY
	DB	'DUM','P'+80H	; Peek at memory
	DW	DUMP
	DB	'?'+80H		; Help
	DW	TELL
	DB	0
;
TELL:	CALL	ILPRT
	DB	CLS,LF,LF,LF,0
TELL1:	CALL	ILPRT
	DB	CR,LF,LF,ESC,DIM,'Options are :',LF
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET BAUD XXXX',ESC,DIM
	DB	TAB,TAB,'sets the baud rate to xxxx (110 to 19200).'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET PARITY X ',ESC,DIM
	DB	TAB,TAB,'sets the parity to X (N, E, or O).'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET BITS X   ',ESC,DIM
	DB	TAB,TAB,'sets Data Bits to X (5 to 8).'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET STOP X   ',ESC,DIM
	DB	TAB,TAB,'sets stop bits to x (1 or 2).'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET KEY  n "string"',ESC,DIM
	DB	TAB,    'sets function key n (1 to 20) to "string".'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET DUMP xxxx yyyy',ESC,DIM
	DB	TAB,    'dumps memory from xxxx to yyyy (0 to 0FFFFh)'
	DB	CR,LF,LF,TAB,ESC,UNDIM,'SET ?',ESC,DIM
	DB	TAB,TAB,TAB,'prints this help screen'
	DB	ESC,UNDIM,ESC,'=',54,32,0 ; GoToXY 22,0
	RET
;
;	Set baud to that specified
STBAUD:	MVI	C, BDPARS
	CALL	MEX		; ASK FOR BAUD RATE CODE
	JC	SHOWBD
	CALL	SETBD
	JC	SETERR		; BAD CODE
;				ELSE FALL INTO SHOWBD
;
SHOWBD:	CALL	ILPRT		; PRINT CURRENT BAUD RATE
	DB	LF,ESC,UNDIM,CR,LF,'Baud ',ESC,DIM,'Rate is now: ',ESC,UNDIM
	DB	TAB,TAB,TAB,ESC,PRINV,INVERT,0
	LDA	MSPEED
	MVI	C, PRBAUD
	CALL	MEX
	CALL	ILPRT
	DB	ESC,PRINV,UNINV,CR
	DB	LF,ESC,UNDIM,CR,LF,'Parameters ',ESC,DIM,'are now: ',ESC,UNDIM
	DB	TAB,TAB,TAB,ESC,PRINV,INVERT
DATA	DB	AFLTDT
PARITY	DB	AFLTPA
STOPS	DB	AFLTST
	DB	ESC,PRINV,UNINV,CR,LF,LF,0
	RET
;
; TABLE	OF BAUDRATE PARAMETERS FOR 2661 I/O
BD110	EQU	00F4H		; FOR 110, 0
BD300	EQU	00F5H		; FOR 300, 
BD1200	EQU	00F7H
BD2400	EQU	00FBH
BD9600	EQU	00FCH
BD1920	EQU	00FEH
;
BAUDTB:	DB	BD110, BD300, 0, 0, 0
	DB	BD1200, BD2400, 0
	DB	BD9600, BD1920
;
SETBD:	CPI	10		; LEGIT CODE (i.e. <10?)
	JNC	PBX		; CONTINUE IF SO
	MOV	E, A		; BAUD CODE SAVED IN E
	MVI	D, 0
	LXI	H, BAUDTB
	DAD	D		; HL NOW POINTS AT APPROPRIATE ENTRY
	MOV	A, M		; GET IT
	ORA	A		; ZERO? (means unsupported)
	JZ	PBX		; BLOW IF SO
	STA	INITMOD1+1	; SET PARAMETER
	MOV	A, E
	STA	INITMOD+1	; SET BAUD RATE
	CALL	INITMOD		; GO DO IT
;
PBX:	STC			; ERROR, SET THE CARRY
	RET
;
SETPRM:	LDA	INITPM+1	; SET UP SERIAL PORT PARAMETERS
	ANA	C		; CLEAR OLD VALUE
	ORA	B		; SET NEW VALUE
	STA	INITPM+1	; STORE IT
	CALL	INITMOD		; GO DO IT
	JMP	SHOWBD		; AND TELL 'EM ABOUT IT.
;
SETPAR:	MVI	C,GNC		; GET THE NEXT CHARACTER FROM STREAM
	CALL	MEX
	JC	SETERR
	CPI	' '
	JZ	SETPAR
	CPI	9		; TAB
	JZ	SETPAR
	MVI	D, 'N'
	LXI	B, 000CFH	; ASSUME NO PARITY
	CPI	'N'
	JZ	PARSET
	CPI	'n'
	JZ	PARSET
	MVI	D, 'E'
	MVI	B, 030H		; NOT NO PARITY, MAYBE EVEN
	CPI	'E'
	JZ	PARSET
	CPI	'e'
	JZ	PARSET
	MVI	D, 'O'
	MVI	B, 010H		; NOT EVEN, LAST TRY ON ODD
	CPI	'O'
	JZ	PARSET
	CPI	'o'
	JNZ	SETERR		; STRUCK OUT
PARSET:	MOV	A,D
	STA	PARITY
	JMP	SETPRM
;
SETBIT:	MVI	C, EVALA	; CHANGE DATA BITS, START BY GETTING NUMBER
	CALL	MEX
	MOV	A, L
	CPI	5
	JC	SETERR
	CPI	9
	JNC	SETERR
	ADI	'0'
	STA	DATA
	SUI	'5'		; ADJUST TO 0-3
	ANI	3
	RLC
	RLC			; ADJUST TO 0,4,8,C
	MOV	B, A		; A IS OR VALUE
	MVI	C, 0F3H		; C IS CLEAR VALUE
	JMP	SETPRM		; AND DO IT.
;
SETSTP:	MVI	C, EVALA	; CHANGE STOP BITS, GET NUMBER FIRST
	CALL	MEX
	MOV	A, L
	LXI	B, 0403FH	; ASSUME 1 STOP BIT
	CPI	1
	JC	SETERR
	JZ	STPSET
	CPI	3
	JNC	SETERR
	MVI	B, 0C0H
STPSET:	ADI	'0'
	STA	STOPS
	JMP	SETPRM
;
KEYBUF:	DS	FNBUF		; BUFFER FOR FUNCTION KEY STRINGS
FNSTRT:	DB	ESC,'F'
FNNUM:	DB	0		; SELF MODIFYING
	DB	'$'
;
SETKEY:	MVI	C, EVALA
	CALL	MEX		; GET THE FUNCTION KEY NUMBER
	MOV	A, L		; INTO A
	CPI	21		; LEGAL?
	JNC	SETERR		; NO.
	CPI	1		; BIG ENOUGH?
	JC	SETERR		; NO.
	ADI	0DFh		; 1 ==> E0, 20 ==> F3
	STA	FNNUM		; SAVE IT
SKLD:	CALL	GNCD
	JNZ	SKLD
	MVI	B, 0		; ZERO THE COUNTER
	LXI	H, KEYBUF	; POINT HL TO BEGINNING OF BUFFER
;
LKLD:	CALL	GNCD
	JZ	DOKEY
	CPI	'^'		; CARAT?
	CZ	GETCTL		; YES, GO GET A CONTROL CHARACTER
	MOV	M, A		; STORE IT
	INX	H
	INR	B
	MOV	A, B
	CPI	FNBUF+1
	JC	LKLD
	JP	SETERR
;
GETCTL:	CALL	GNCD		; GET A CONTROL CHARACTER BY GETTING NEXT CHAR
	SUI	40H		; AND MAKING IT A CONTROL CHARACTER
	CPI	'>'		; IS IT A '~' ('~'-40H='>')
	RNZ			; NO, RETURN
	MVI	A, '^'		; YES, STUFF IN A '^'
	RET
;
DOKEY:	PUSH	B		; SAVE THE LENGTH
	LXI	D, FNSTRT
	MVI	C, PRINT
	CALL	MEX
	POP	B
	MOV	A, B
	ORA	A
	JZ	DKEY
	LXI	H, KEYBUF
DKLP:	MOV	A, M		; GET THE CHARACTER
	CALL	TYPE		; SEND IT TO THE TERMINAL
	INX	H
	DCR	B
	JNZ	DKLP
DKEY:	LXI	D, FNNUM
	MVI	C, PRINT
	JMP	MEX
;
GNCD:	PUSH	H
	PUSH	B
	MVI	C, GNC		; ASK MEX FOR NEXT CHAR
	CALL	MEX
	POP	B
	POP	H
	JC	GNER		; RUN TO ERROR IF CARRY
	CPI	'"'		; TERMINATOR?
	RET			; RETURN WITH ZFLAG SET
;
GNER:	POP	H		; KILL RETURN ADDRESS
	JMP	SETERR		; INFORM USER OF HIS ERROR
;
;
DUMP:	MVI	C, EVALA	; GET OFFSET
	CALL	MEX
	MOV	A,L
	ANI	0F0H		; 11110000
	PUSH	H
	MVI	C, EVALA
	CALL	MEX
	MOV	B, H
	MOV	C, L		; ENDING ADDRESS IN BC
	POP	H
	CALL	CPHLBC
	JC	SETERR
LLP:	PUSH	B
	PUSH	H
	PUSH	H
	CALL	PADD		; AND PRINT IT
	POP	H
	PUSH	H
	MVI	B, 16		; DO 16 BYTES
HXLP:	MOV	A, M		; LOAD NEXT BYTE
	CALL	HEX		; PRINT IT
	MVI	A, ' '
	CALL	TYPE
	INX	H		; POINT TO NEXT BYTE
	DCR	B		; DONE?
	JNZ	HXLP		; LOOP IF NOT
;
	CALL	ILPRT		; SET UP TO PRINT ASCII
	DB	'    "',0
	POP	H		; POINT TO START AGAIN
	MVI	B, 16
;
ASCLP:	MOV	A, M		; GET NEXT BYTE
	CPI	20H
	JC	CTLCHR
	CPI	80H		; THE DMV CAN PRINT A DELETE
	JNC	HIASC
	CALL	TYPE
	JMP	NEXASC
CTLCHR:	CALL	ILPRT
	DB	ESC,DIM,NOTASC,ESC,UNDIM,0
	JMP	NEXASC
HIASC:	ANI	07FH		; STRIP THE HIGH BIT
	CPI	20H		; LEGAL NOW?
	JNC	HIPRT
	MVI	A,NOTASC	; NO, PRINT THE PERIOD
HIPRT:	STA	HIP
	CALL	ILPRT
	DB	ESC,PRINV,INVERT
HIP:	DB	0		; WILL BE REPLACED
	DB	ESC,PRINV,UNINV,0
NEXASC:	INX	H
	DCR	B
	JNZ	ASCLP
	CALL	ILPRT
	DB	'"',0
;
	POP	H
	POP	B
	LXI	D, 16
	DAD	D
	CALL	CPHLBC
	JC	LLP
	CALL	ILPRT
	DB	CR,LF,LF,0
	RET
;
PADD:	CALL	ILPRT		; PRINT A CRLF, AND THEN THE ADDRESS IN HL
	DB	CR,LF,ESC,PRINV,INVERT,0
	MOV	A,H
	PUSH	H
	CALL	HEX
	POP	H
	MOV	A,L
	CALL	HEX
	CALL	ILPRT
	DB	ESC,PRINV,UNINV,':    ',0
	RET
;
; compare hl with bc, return c-flag if hl<bc
CPHLBC:	MOV	A, H
	CMP	B
	RC
	MOV	A, L
	CMP	C
	RET
;
; Print the hex byte in A
HEX:	MOV	D,A		; Save A
	RRC
	RRC
	RRC
	RRC			; Switch nybbles
	CALL	PNYB		; Print high nybble
	MOV	A, D		; Get it back, and fall into PNYB
;
PNYB:	ANI	0FH		; Kill high nybble
	ADI	90H		; This is out of the Osborne Mex overlay,
	DAA			; which author gives credit to Kelly Smith,
	ACI	40H		; who must be a very sick, albeit fast and 
	DAA			; efficient, person
	JMP	TYPE		; and print it(?)
;
ILPRT:	MVI	C, ILP
	JMP	MEX		; INLINE PRINT CALL
;
TYPE:	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E, A
	MVI	C, CONOUT
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
;	       (END OF INITMOD AND SET ROUTINES)
;=======================================================================
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem).
;
	END
