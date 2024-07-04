; title	'cp/m communication program version 7.23'

VERS	EQU	7$23	;version number..
MONTH	EQU	06	;..month..
DAY	EQU	18	;..day..
YEAR	EQU	83	;..and year.

;comm7 provides extensive communications capabilities using the established
;christensen 'modem' protocol.  additionally, integrated file manipulation
;routines ('utl' and 'sap') allow disk housekeeping functions to be performed
;efficiently without leaving the program.  a full single-screen main menu
;plus sub-menus provide summaries of commands and options available to the
;operator.  lasm.com or linkasm.com is required to assembly comm7.  operating
;procedures are detailed in comm7.doc.

;the program is designed around features of the pmmi mm-103 s-100 modem
;board.  external ported modems can be used if applicable code and equates
;are fittingly altered.  (a modular program technique is presently being
;developed to conventiently handle features of other popular modems.)

;comm7 is dedicated to public domain software (pds) contributions made
;by rich berg, david boruff, ben bronson, ward christensen, bob clyne,
;richard conn, bill earnest, bob fischer, bob fisher, ron fowler, richard
;greenlaw, irv hoff, dave jaffe, paul kelley, bruce kendall, bob kuhman,
;jim mills, keith petersen, bob plouffe, bruce ratoff, kelly smith, paul
;traina, hal walchli, and mark zeiger.  comm7 is updated as changes are
;indicated to maintain a friendly, end-user interface and a consistency of
;form compatible with changing microcomputer equipment environment.  (the
;listing style is unique and should remain a characteristic of comm7.)

; latest changes 

;06/18/83  fixed bug when writing (wrt) zero-length second and subsequent
;buffers to ram during file colon-save in terminal mode.  program returns to
;last established drive at command line on re-entering command mode,
;regardless of drives logged-in while in 'utl'.  added 'stat' (s) and 'file
;size' (f) commands, tagged file sizes accumulated and displayed in parenthe-
;ses.  reordered 'utl' menu.  disk system reset after 'sap' is used even on
;previously sorted disk.  'dir' command can now be used even if file-save
;(esc t/esc y) is active in terminal mode.  when auto-dialing, the 'waiting
;for dial tone' message is removed as tone is detected.  tnx to joe wright for
;suggesting change.  program put on diet to reduce code size.  (723)  fg

;04/27/83  bug fixed in waitnak routine -- would crash if trying to use
;quiet mode (there cannot be a cz ilprt, it will simply try to execute
;the text if the conditional fails).  bug fixed in recvack routine --
;missing line (mvi a,ack) there.  added new way of controlling comm7
;in the terminal mode,  before you typed ^e, etc to exit,  now you type
;an "intercept" character to flag a command, then you type an uppercase
;letter for the desired function.  (and if you have a televideo 925/950
;or a heath/zenith-19, it will print a quickie menu on your 25th line).
;on a televideo, the <home> key generates a ^^, this works out beautifully
;as an "intercept" key.  if you want a different one, change the equate
;cmdchr.  to send the intercept character, just type it twice.
;  also i removed some extremely long lables and replaced them with "sensible"
;lables. (eg: mask$8$data$bits is a bit long for my taste, so it became
;"m8data", ck$in$port became "instat", out$ctrl$port and out$ctrl$port2
;became "outctrl" and "outctr2".  i admit some long lables can make more
;sense, but it was getting to be ridiculous. >grrr<  (722)  paul traina <pst>

;04/25/83  'utl [d:] *.ft' permitted as call from main command line.  fixed
;major bug with 'utl' not copying files larger than 16k to other than user
;area zero.  'utl' includes multi-file mass copy routine, tagging/untagging
;ability.  added more invalid drive/user area keyboard-entry error traps.
;now d, d:, dn, dn:, dnn, and dnn: are all permitted responses to utl 'c',
;'l', and 'm' prompts.  added the pds program 'sap' as a main menu command.
;now directory of any drive can be 'sorted and packed' with dispatch, staying
;in the program.  'sap' and 'sap d:' are valid entries.  tnx to 1977 original
;author, l.e. hughes, and all hackers who have contributed to making 'sap'
;the useful program it is today.  program re-modularized in preparation for
;use with pmmi mm-212a and other modems.  (721)  fg

;04/10/83  major utility 'utl' added to primary command list.  'utl' provides
;full file manipulation without leaving program and is based on 'disk7'
;program.  operation is explained by self-help menu.  set 'utl' equate 'true',
;if feature desired instead of 'vue'.  'sel' function expanded to permit
;selection of half-duplex operation and filtering-out of received control
;codes in terminal mode.  removed pmmi parity secondary command option.
;installed fast table-driven 'crc' calculation method using techniques of
;dave barker (same as used in chek13 and disk73).  mended 'softkey' equate if
;set false.  also, finally, fixed ss1 board equates -- time feature now works
;(tnx to bob greene for assistance).  to my understanding, this is the only
;successful implementation of the compupro/godbout board with the 'cw' clock-
;read code.  (the 'rtc' program supplied by godbout doesn't set the 'day'...
;greene is rewriting so it does.)  'wrtdsk' routine uses 'shiftlp' to divide
;by 128.  improved 'ramsave' routine so no bytes are lost when ram-to-disk
;save occurs at full 'colon-save' buffer, if remote computer recognizes
;'xoff/xon' protocol.  'break' function reworked for improved operation.
;made 'quiet' mode friendlier.  (720)  fg

;03/05/83  introduced console screen attributes.  added more terminals to
;equate list.  eliminated 'ret' command, replaced by simply 't' to re-enter
;terminal mode after using ^e to enter command mode.  if a file has been
;opened, 't' retains all data until 'wrt' or 'del' is employed.  'm' now can
;be used when a file is open.  improved technique of removing characters from
;printer ring-buffer.  re-organination eliminated requirement for 'uartflg',
;thus it was removed.  'getbaud' changed to retain current baudrate even if
;command 'to fn.ft' is given.  presently both mode and baudrate are maintained
;until explicitly changed.  'show', used to view ascii files on-the-fly,
;displays control codes as ' ^x', instead of (xx).  program ready for updating
;to handle new pmmi mm-212a.  eliminated 'imsaibyte'...sori abt that, zoso.
; (719)  fg

;02/25/83  added 'exit-to-cp/m-with-disconnect-and-reboot' as secondary option
;'e' (a suggestion from jerry wolfson) and updated main menu.  completed set-
;drive/user error-trapping at the command-line prompt.  added equate to allow
;'time' display at command line, instead of 'day, date, and time'.  eliminated
;need for 'origsav' flag by simplifying 'fixbaud' subroutine; also 'blkfile',
;'termsel', and 'savagn' deleted, all made possible by re-organizing 'setfcb'
;and 'procopt' routines.  'auto-linefeed after cursor-return' added to echo 
;('e') primary mode loop to more accurately resemble a computer.  trap
;installed denying 'q' and 'b' secondary options in terminal and echo modes.
;added auto-routine-cancel if send/receive re-try error limit exceeded and
;an equate to handle cp/m base address other than zero.  added selected
;messages to be-sent/show in quiet mode.  several command-mode operational
;messages now overwrite command line instead of scrolling screen.  added
;primary command of 'vue' to permit viewing (type) an ascii file on the
;console.  vue displays with <ctrl-x> used to cancel, <space> to turn-up
;one line, and any other key to page screen.  (717/718)  fg

; (comm7.his file lists years of development changes associated with modem,
; modem7, and comm7.)

; comm7 is copyright (c) 1983 by frank gaude'
; released to public domain for non-commerical use.  monetary gain is not
; permitted under any circumstance by individual, partnership, or corporation.

; assemble using 'lasm.com' or 'linkasm.com'.  comm723.asm, comm723a, b, c,
; and d.asm must be on same drive.  (edit each assembly subfile independently,
; as required.)

; enter -> lasm comm723.aaz b:  (source on 'a' drive, hex goes on 'a', no prn
;			        file, and symbol table on drive b: for use by
;			        sid.com.  'lasm comm723' produces prn, all 
;			        files on default drive, no symbol table.  see
;			        lasm.doc for complete details.)

;          load comm723		(produces com file.)

; starting definitions

TRUE	  EQU	0FFH		;define true..
FALSE	  EQU	0		;..and false.
CPM$BASE  EQU	0000H		;cp/m system base
TPA	  EQU	100H		;cp/m transient program area base
DBUFSIZ	  EQU	16		;file s/r buffer size in kbytes (k=1024)
MAXDR	  EQU	'C'		;maximum drive in system: 'a', 'b', 'c', etc.
RING	  EQU	32		;printer ring-buffer and..
CCP	  EQU	8		;..cp/m 'ccp/zcpr' size in 256-byte pages.
PMMI	  EQU	TRUE		;true if using a pmmi, false if not
UTL	  EQU	TRUE		;true if 'utl' disk file manipulator
VUE	  EQU	FALSE		;true if 'vue' instead of 'utl'.  must be
				;set false if 'utl' is set true.
DUMB	  EQU  	TRUE		;true if not smart line-editor transfers
ERRLIM	  EQU	10		;number of re-tries on send/receive..
				;..error before auto-quitting.
ERRCRC	  EQU	6		;number of tries (at 10 seconds each)..
				;..for crc before switching to checksum.
LPS	  EQU	24-2		;lines-per-screen 'vue' pagination
NPL	  EQU	5		; 'dir' display names-per-line
RBUF	  EQU	10		;buffer at auto-colon-file ram-to-disk save
GET	  EQU	0FFH		;get user area e-reg value
SOFTKEY	  EQU	TRUE		;true for soft dual-key auto-text output

; crt terminal selection

ADM21	  EQU	TRUE		;true for lsi adm-21
ADM31	  EQU	FALSE		;true for lsi adm-31
ADM42	  EQU	FALSE		;true for lsi adm-42
ADM5	  EQU	FALSE		;true for lsi adm-5
SOROC	  EQU	FALSE		;true for soroc 120
TELEVIDEO EQU	FALSE		;true for tvi910/912/920/925/950 or 970
TELE25TH  EQU	FALSE		;true if your tvi has 25th line (925/950/970)
VIEWPOINT EQU	FALSE		;true for adds viewpoint
VISUAL	  EQU	FALSE		;true for visual 200
ZENITH	  EQU	FALSE		;true for zenith h19/z19 terminals

; set system cpu clock frequency to nearest tenth megahertz x 10.
; 4 mhz = 40, 3.7 mhz = 37, up to 15.7 mhz = 157 (max)

MHZ	  EQU	40		;cpu speed * 10 in mhz

; waiting limit for remote computer carrier (cts)

WAITCTS	  EQU	125		;seconds x 5 to wait for computer tone..
				;..after pmmi auto-dial function.
				; (125 = 25 second-wait, to 255 max.)

; rtc clock port (if using hardware time/date circuit)

RTC	  EQU	TRUE		;true if using clock/calendar circuit
CW	  EQU	TRUE		;true if compu/time cw board
SS1	  EQU	FALSE		;true if compupro/godbout ss1 board
TIME$ONLY EQU	FALSE		;true if 'time' without 'day/date' at cmd line
CLKBASE	  EQU	54H		;base port of clock board (if rtc true)

; crt terminal equates
; (add values as required and known.  if half-intensity not available for
; terminal, it may be better to use dummy character instead of reverse
; video.)

	   IF	TELEVIDEO OR ADM21
CLS	  EQU	0D1AH		; ^z = clear screen/home cursor + 'cr' pad
	   ENDIF		;televideo or adm21

	   IF	ADM31
CLS	  EQU	2A1BH		; <esc> '*' = clear screen
	   ENDIF		;adm31

	   IF	TELEVIDEO OR ADM21 OR ADM31
ETEOP	  EQU	'Y'		; <esc> 'y' = erase-to-end-of-page
BDIM	  EQU	')'		;begin and..
EDIM	  EQU	'('		;..end half-intensity.
	   ENDIF		;televideo or adm21 or adm31

	   IF	ADM42
CLS	  EQU	451BH		; <esc> 'e' = clear screen
ETEOP	  EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	  EQU	06H		;dummy
EDIM	  EQU	06H		;dummy
	   ENDIF		;adm42

	   IF	ADM5
CLS	  EQU	0D1AH		; ^z = clear + cr pad
ETEOP	  EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	  EQU	06H		;dummy
EDIM	  EQU	06H		;dummy
	   ENDIF		;adm5

	   IF SOROC
CLS	  EQU	2A1BH		;clear = <esc> '*'
ETEOP	  EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	  EQU	06H		;dummy
EDIM	  EQU	06H		;dummy
	   ENDIF		;soroc

	   IF	VIEWPOINT
CLS	  EQU	0D0CH		; ^l = clear screen + 'cr' pad
ETEOP	  EQU	'K'		; <esc> 'k' = erase to end of page
BDIM	  EQU	06H		;dummy
EDIM	  EQU	06H		;dummy
	   ENDIF		;viewpoint

	   IF	VISUAL
CLS	  EQU	761BH		;clear = <esc> 'v'
ETEOP	  EQU	'y'		; <esc> 'y' = erase to end of page
BDIM	  EQU	06H		;dummy
EDIM	  EQU	06H		;dummy
	   ENDIF		;visual

	   IF	ZENITH
CLS	  EQU	451BH		; <esc> 'e' = clear screen/home cursor 
ETEOP	  EQU	'J'		; <esc> 'j' = erase-to-end-of-page
BDIM	  EQU	'p'		;begin and..
EDIM	  EQU	'q'		;..end half-intensity.
	   ENDIF		;zenith

; modem sensitive equates

PORT	  EQU	0C0H		;modem base address..
SPORT	  EQU	PORT		;..of control port.
DPORT	  EQU	PORT+1		;modem data..
BPORT	  EQU	PORT+2		;..baudrate (status port)..
CPORT2	  EQU	PORT+3		;..and 2nd control port.
TBMT$B	  EQU	1		;modem send bit (tbmt)..
TBMT$R	  EQU	1		;..send ready..
DAV$B	  EQU	2		;..receive bit (dav) and..
DAV$R	  EQU	2		;..receive ready.
CTS	  EQU	4		;clear-to-send mask
BRK	  EQU	0FBH		;mask to set break
FE	  EQU	020H		;framing..
OE	  EQU	010H		;..overrun and..
PE	  EQU	008H		;..parity error mask.
ODDPARM	  EQU	0CFH		;mask to set odd parity..
EVNPARM	  EQU	020H		;..even parity and..
NOPARM	  EQU	010H		;..reset to no parity.
ERRCDM	  EQU	038H		;mask for all error codes

; modem uart control bit equates -- set for originate mode

M5DATA	EQU	00000001B	; 5..
M6DATA	EQU	00000101B	;..6..
M7DATA	EQU	00001001B	;..7 or..
M8DATA	EQU	00001101B	;..8 data bits.
MEPAR	EQU	00100001B	;even..
MOPAR	EQU	00000001B	;..odd or..
MNPAR	EQU	00010001B	;..no parity.
M1STOP	EQU	00000001B	;one or..
M2STOP	EQU	01000001B	;..two stop bits.

; ascii	definitions

SOH	EQU	1		; ^a, start of header.
EOT	EQU	4		; ^d, end of text.
ACK	EQU	6		; ^f, acknowledge.
BELL	EQU	7		; ^g, bell character.
BS	EQU	8		; ^h, back-space.
HT	EQU	9		; ^i, tab character.
LF	EQU	10		; ^j, linefeed.
CR	EQU	13		; ^m, cursor return.
NAK	EQU	21		; ^u, negative acknowledge.
ESC	EQU	27		; ^[, escape character.
CRC	EQU	'C'		;  c, crc request character.
BDNMCH	EQU	'U'		;  u, bad name match.
OKNMCH	EQU	ACK		; ^f, okay name match.

; control equates

CHGBAUD	EQU	'B'-40H		; ^b = baudrate change 'on-the-fly'
EXITCHR	EQU	'E'-40H		; ^e = exit to command mode without and..
CAN	EQU	'X'-40H		; ^x = cancel dial/send/receive/view-file
EOFCHAR	EQU	'Z'-40H		; ^z = end of ascii cp/m file
XOFF	EQU	'S'-40H		; ^s = xoff character
XON	EQU	'Q'-40H		; ^q = xon character
INTCHR	EQU	'['-40H		; ^[ = enter terminal command mode

; assembly origin (load address) and program beginning

SOURCE	  ORG	CPM$BASE+TPA
	  JMP	START

; storage is here for quick com file patching by a monitor without
; re-assembling program.

BAKUPBYTE DB	TRUE		;true=make .bak file
XPRFLG	  DB	TRUE		;false=print menu 1st time thru
SAVCCP	  DB	TRUE		;true=do not overwrite ccp (or ring-buffer)
CMDCHR	  DB	INTCHR		;set interrupt character

	   IF	PMMI
PULSERATE DB	125		; 125=20pps dialing, 250=10pps.
ORIGMOD	  DB	1DH		;originate mode
ANSWMOD	  DB	1EH		;answer mode
           ENDIF		;pmmi

; baudrate index register -- 0=110, 1=300, 2=450, 3=600, 4=710
; and 5=1200 baud

MSPEED	  DB	1		;initial and new baudrate index register

; modem sensitive routines

OUTSTAT	IN 	SPORT		;in (from) modem control port
	ANI	TBMT$B		;bit to test for send ready
	CPI	TBMT$R ! RET	;send bit value when ready
INSTAT	IN 	SPORT
	ANI	DAV$B		;bit to test for receive ready
	CPI	DAV$R  ! RET	;receive bit value when ready
INCHAR	IN 	DPORT  ! RET	;in (from) and..
OUTCHAR	OUT	DPORT  ! RET	;..out (thru) modem data port.
INBAUD	IN 	BPORT  ! RET	;in and..
OUTBAUD	OUT	BPORT  ! RET	;..out baudrate port.
INCTRL	IN 	SPORT  ! RET	;in and..
OUTCTRL	OUT	SPORT  ! RET	;..out modem control port.
OUTCTR2	OUT	CPORT2 ! RET	;out modem control port #2

; the 'softkey' simplifies sending of frequently used command
; lines or short messages to a remote line-editor or cp/m ccp.
; stored text is issued by pressing the 'cmdchar' (presently
; set to the 'esc' character) followed by a number from 0 to 9.
; the db's below indicate the stings set for automatic trans-
; mission.  when in terminal mode, entering 'esc 1' outputs:
;
;                   dir *.* $u0ad <return>
;
; this is an often manually typed entry to display the directory of
; each remote drive.  'esc 3' outputs the 'xmodem r ' string.  set
; 'softkey' equate true if this feature is desired.

	   IF	SOFTKEY
SOFTMSG	  DB	CR,ESC,ETEOP,' -- Softkey Stored '	;header of..
	  DB	'Strings --',CR,LF			;..local..
	  DB	'      <ESC> 1,2,3...9,0',CR,LF,LF	;..display.
SKONE	  DB	'DIR *.* $U0AD',CR,0			;esc '1'
SKTWO	  DB	'*.* $U0AD',CR,0			;esc '2'
SKTHREE	  DB	'XMODEM R ',0				;esc '3'
SKFOUR	  DB	'XMODEM S ',0				;esc '4'
SKFIVE	  DB	'USER',CR,0				;esc '5'
SKSIX	  DB	'WHATSNEW',CR,0				;esc '6'
SKSEVEN	  DB	'Frank;Gaude''',cr,0			;esc '7'
SKEIGHT	  DB	'Frank Gaude''',CR,0			;esc '8'
SKNINE	  DB	'Los Altos Hills, CA',CR,0		;esc '9'	
SKZERO	  DB	'See you down the lines...',CR,0,'@'	;esc '0'
	   ENDIF					;softkey

START	LXI	H,0		;save..
	DAD	SP		;..cp/m return..
	SHLD	STACK		;..address.
	LXI	SP,STACK 	;start local stack
	CALL	INITCRC		;generate tables for fast 'crc' calculations
	CALL	INITADR		;establish bios/print-buffer addresses
	CALL	PROCOPT		;process primary/secondary options
	LDA	XPRFLG		;show menu 1st time thru..
	ORA	A		;..if..
	JZ	MENU		;..xprt mode set false.
	CALL	CAPTION		;show program title header
	CALL	CRLF

; react to cp/m and comm7 command line entries

RESTART	LXI	SP,STACK	;start a fresh stack at restart
	LDA	OPTION	 	;react to main (primary) option

	 IF	PMMI		;if a pmmi modem
	CPI	'C'		;call (dial) function?
	JZ	DLFONE		;yes, go for it.
	CPI	'D'		;disconnect?
	JZ	DISCON1		;yes, say disconnected and go to menu.
	 ENDIF			;pmmi

	CPI	'M' 		;menu asked for?
	JZ	MENU2		;yes, go menu.
	CALL	INITMOD		;set modem parameters and 'setbaud'
	CALL	MOVEFCB	   	;put filename at fcb, if there's one.
	CALL	INCHAR	 	;remove noise..
	CALL	INCHAR	 	;..character on line.
	LDA	OPTION	   	;now process main (primary) option
	CPI	'T'		;terminal mode?
	JZ	DSKSAVE		;yes
	CPI	'E'	   	;echo (resemble-a-computer) mode?
	JZ	TERM$ECHO	;yes
	CPI	'S'		;send a file?
	JZ	SENDFIL		;yes
	CPI	'R'		;receive a file?
	JZ	RCVFIL		;yes
	JMP	MENU		;no valid option spec'd, go menu.

; initialize console i/o and printer ring-buffer addresses -- save initial
; drive/user area for use in returning to cp/m

INITADR	LHLD	CPM$BASE+1	;entry to bios jmp table
	LXI	D,3
	DAD	D
	SHLD	VSTAT+1		;store const..
	DAD	D
	SHLD	VKEYIN+1	;..conin and..
	LXI	D,36
	DAD	D
	SHLD	LISTST+1	;..list stat.
	LDA	BDOS+2		;get 'bdos' base page and..
	SUI	CCP		;..substract 'ccp' length in pages.
	STA	BUFEND+1	;store as ring-buffer end..
	SUI	RING		; (end - ring --> buffer begin)
	STA	BUFBEG+1	;..and beginning address.  put also..
	STA	BUFRIN+1	;..as 'in' and..
	STA	BUFROUT+1	;..'out' pointers.
	MVI	E,GET		;get current user..
	CALL	GET$USR		;..and..
	STA	O$USR		;..save for exit to cp/m.

	 IF	PMMI
	RET
	 ENDIF

; set requested baudrate -- initialize non-pmmi modem, as required.  set
; operating mode to last requested determined by 'procopt'.  routine
; retains current mode and baudrate until explicitly changed at command
; line or with <ctrl-b> in terminal mode.

INITMOD				; (put custom code here, as required.)
SETBAUD 
	 IF	NOT PMMI
	RET
	 ENDIF

	 IF	PMMI
	LDA	ANSWFLG		; (don't go 'off-hook if mode not specifed)
	ORA	A
	JZ	FIXBAUD		;if already 'off-hook' and if..
	LDA	ORIGFLG		;..neither mode specified, current baudrate..
	ORA	A		;..is retained even if declared (t.450 -->..
	RNZ			;..last rate declared using, e.g., to.xxx).
FIXBAUD	CALL	GETBAUD		;baudrate divisor returned in a-reg
	CALL	SETMSPD		;index to print rate in c-reg; a-reg, divisor.
	CALL	OUTBAUD		;set modem baud divisor
	CPI	52		; >300 baud?
	MVI	A,5FH		;dtr (filter for >300 baud)
	JC	GT300		;yes, greater than.
	MVI	A,7FH		;dtr (filter for 300 baud and less)
GT300	CALL	OUTCTR2		;set modem filter
	STA	MODCTLB		;store above filter value
	LDA	UARTCTLB	;put last requested mode to modem but first..
	MVI	B,1		;..a little delay, then..
	CALL	TIMER		;..go 'off-hook' with..
	CALL	OUTCTRL		;..selected parameters.
	MOV	A,C		;get index to print..
	STA	MSPEED		;..baudrate in 'openok'.
	XRA	A		;ret to caller with flags..
	RET			;..set.

; determine if rate-change is necessary

GETBAUD	LDA	FCB+9		;get 1st digit of baudrate from cmdline
	CPI	' '		;if 'blank', return with..
	LDA	BAUDRATE	;..current rate.
	RZ

; convert ascii baudrate to binary modem divisor -- store divisor in
; 'baudrate' register

	LXI	D,FCB+9
	LXI	H,0
DECLP	LDAX	D		;get ascii digit
	INX	D
	CPI	' '
	JZ	DECLP
	CPI	'0'		;validate digit here..
	JC	BADRATE	
	CPI	'9'+1		;..and again here then..
	JNC	BADRATE
	SUI	'0'		;..make digit binary.
	MOV	B,H		;set-up to multiply previous..
	MOV	C,L		;..value by ten.
	DAD	H		; x2
	DAD	H		; x2
	DAD	B		; +1
	DAD	H		; x2 = 10.
	ADD	L
	MOV	L,A
	JNZ	DIGNC
	INR	H
DIGNC	MOV	A,E		;see if past..
	CPI	FCB+12		;..last digit. ('e' is lsb of 'de')
	JNZ	DECLP		;loop till done
	MOV	A,H
	CMA			;one's complement
	MOV	D,A
	MOV	A,L
	CMA
	MOV	E,A
	INX	D		;two's complement
	LXI	H,15625		; 250000/16
	LXI	B,-1
DIVLP	INX	B
	DAD	D		; ('dad' sets carry)
	JC	DIVLP
	MOV	A,B		;assume valid divisor in c-reg..
	ORA	A		;..if b-reg is zero.
	MOV	A,C		;divisor into a-reg for output to modem
	STA	BAUDRATE	;retain as current rate
	RZ			;ret if <256, else error exit.

; announce invalid baudrate entry

BADRATE	CALL	ERXIT
	DB	'++ Invalid baudrate ++','@'

; determine index for printing baudrate (divisor from 'getbaud' in a-reg)

SETMSPD	MVI	C,0		; 0 --> 110 baud
	CPI	100
	RNC
	INR	C		; 1 --> 300 baud
	CPI	40
	RNC
	INR	C
	CPI	30
	RNC
	INR	C
	CPI	24
	RNC
	INR	C		; 4 --> 710 baud
	CPI	15
	RNC
	INR	C		; 5 --> 1200 baud
	RET
	 ENDIF			;pmmi

; change baudrate on-the-fly with <ctrl-b> in terminal mode

NEWBAUD	
	 IF	NOT PMMI
	RET
	 ENDIF			;not pmmi

	 IF	PMMI
	CALL	ILPRT
	DB	CR,ESC,ETEOP
	DB	'Enter baudrate (110/300/450/600/710): ',0
	LXI	H,FCB+9
	MVI	M,' '		;put a 'blank' in first position to..
LOOP5	CALL	KEYIN		;..signal using current baudrate.
	CPI	CR		; <return> enters baudrate
	CZ	CRLF		;loop 'till <return> entered
	JZ	FIXBAUD		;make baudrate

; check and show keyboard entries

	CPI	'0'		;make sure it's..
	JC	LOOP5		;..a number, else..
	CPI	'9'+1		;..don't accept it.
	JNC	LOOP5
	MOV	M,A		; 3 digits to memory (fcb9 to fcb11)
	CALL	TYPE		;echo character entered
	INX	H
	JMP	LOOP5		;loop till <return> entered
	 ENDIF			;pmmi

; t e l e p h o n e   n u m b e r   t a b l e

; dial from library of numbers entered into storage here before assembly-
; time.  each db must be 34 characters long for correct operation.  last
; db must end with 0 (null).  up to 26 numbers are allowed.  'r' as last
; character in line indicates an automatic ringback call, i.e., ring once,
; hang up, ring back and let ring until connection or 'timeout'.  don't use
; tabs in the db fields.

NUMBLIB	DB	'A Portola Valley PMS*.....851-3453'
	DB	'B Bob Kohler RCP/M...408/246-3182R'
	DB	'C Dave Morgan RCP/M*..503/641-7276'
	DB	'D Hayward FORTH Tree......538-3580'
	DB	'E Milpitas OxGate*....408/263-2588'
	DB	'F Marin RCP/M RBBS........383-0473'
	DB	'G Napa Valley RCP/M...707/226-6502'
	DB	'H SF DataTech.............563-4953'
	DB	'I Sunnyvale RCP/M.....408/730-8733'
	DB	'J Sunnyvale OxGate....408/732-9190'
	DB	'K Mountain View PicoNET*..965-4097'
	DB	'L Saratoga OxGate*....408/867-1243'
	DB	'M Al Mehr San Jose*...408/238-9621'
	DB	'N San Carlos Oasis CBBS*..591-5509'
	DB	'O San Carlos DataTech*....595-0541'
	DB	'P       (*=24hr/R=ring back)      '
	DB	'Q Keith Petersen*....313/759-6569R'
	DB	'R LA RCP/M RBBS.......213/296-5927'
	DB	'S COMPUSERVE/Mtn View.....961-7242'
	DB	'T Pasadena RBBS.......213/577-9947'
	DB	'U UAHsv RCP/M RBBS...205/895-6749R'
	DB	'V Pasadena CBBS*......213/799-1632'
	DB	'W Kelly Smith.........805/527-9321'
	DB	'X San Diego RCP/M.....714/273-4354'
	DB	'Y Ward/Randy CBBS*....312/545-8086'
	DB	'Z Tim Linehan RCP/M*..206/357-7400',0	;end

; c a l

; modem auto-dial routines
; options from main command line:
;	1. cal <return>
;	2. cal 'x', where x is a library letter.
;	3. cal nnn-nnn-nnnn[r], where n is a number digit to auto-dial.
; options from the library prompt line:
;	1. 'x' where x is a library letter
;	2. nnn-nnn-nnnn[r], where n is a manually entered number to dial.
;          [r] = 'r' is optional, used for ring-back type of auto-dial.

; modem control masks and library equate

	 IF	PMMI
BRKMASK	EQU	0		;tele line on-hook (break during dialing)
CLEAR	EQU	3FH		;idle mode
DTMSK	EQU	1		;dial tone mask
LIBLEN	EQU	34		;library entry length
MAKEM	EQU	1		;tele line make (off-hook)
RBLMT	EQU	35		; 7 sec to wait till no-ring-heard msg shows
RBWAIT	EQU	50		; 5 sec delay before re-dialing number
TMPUL	EQU	80H		;timer pulses mask bit
	 ENDIF			;pmmi

; dial phone number

DLFONE	
	 IF	NOT PMMI
	RET
	 ENDIF			;not pmmi

	 IF	PMMI
	XRA	A		;zero the..
	STA	CRFLAG		;..continuous re-dial and..
	STA	RBFLAG		;..ringback flags..
	LXI	H,0		;..and..
	SHLD	DIALCNT		;..the dial-count register.
	LXI	H,CMDBUF+1	; # of chars in buffer..
	MOV	A,M		;..copied to determine move.
	CPI	3+1		; >3 chars typed before <return>?
	JC	ENTNUM		;no, go library, ask letter/numbers.
	MOV	B,A		; move count in b-reg for..
	SUI	4		;scratch the 'cal' header
	MOV	M,A		;store new count at cmdbuf+1
	INX	H		;at cmdbuf+2, 1st character of string.
	XCHG			;destination in de-pair
	LXI	H,CMDBUF+6	;point to # or letter to dial
	CALL	MOVE		; ..shifting down 4 characters.
	JMP	DIALLP1		;ck if library #, then dial.

; set-up for local print at entnum2.  enters here if 'cal' and telephne
; number were typed.  displays phone number library and asks for entry.

ENTNUM	CALL	ILPRT
	DW	CLS
	DB	ESC,BDIM,CR,LF,LF
	DB	HT,HT,HT,'        M o d e m',CR,LF
	DB	HT,HT,HT,'    T e l e p h o n e',CR,LF
	DB	HT,HT,HT,'      L i b r a r y',CR,LF,LF,ESC,EDIM,0
	MVI	C,13		;number of lines to move.
	LXI	H,NUMBLIB 	;address of source memory..
	LXI	D,DBUF		;..and target memory.
ENTNUM1	MVI	B,LIBLEN	;number of bytes..
	CALL	MOVE		;..to move to buffer.
	MVI	A,' '		;space (4 + (2 * 'liblen') = line length)
	STAX	D		; 1st
	INX	D
	STAX	D		; 2nd
	INX	D
	STAX	D		; 3rd
	INX	D
	STAX	D		; 4rd space
	INX	D
	MVI	B,LIBLEN
	CALL	MOVE
	MVI	A,CR		;cr (cursor return)
	STAX	D		;store it
	MVI	A,LF		;lf (newline) 
	INX	D		;bump pointer
	STAX	D		;store lf
	INX	D		;bump pointer
	DCR	C		;bump # of lines to print
	JNZ	ENTNUM1
ENTNUM2	MVI	A,'@'		;put terminator as last..
	STAX	D		;..character in table.
	LXI	H,DBUF		;point to library..
	CALL	TEXTOUT		;..numbers to display locally.
	CALL	ILPRT
	DB	ESC,BDIM,CR,LF,'Enter library letter or phone '
	DB	'number -- press <RETURN> to start dialing.',CR,LF
	DB	'<CTRL-X> aborts dialing routine: ',ESC,EDIM,0
	LXI	D,CMDBUF
	CALL	INBUF
	CALL	CRLF
	CALL	CRLF
DIALLP1	LXI	H,CMDBUF+1	; # of characters in buffer
	MOV	A,M
	ORA	A   		;null means <return> pressed so..
	JZ	MENU		;..simply return to menu.
	INX	H 		;ltr or 1st typed number of # to dial

; enter routine with hl-pair pointing to # to dial

DIAL10	CALL	DIALPL0		;disconnect, reconnect, wait dial tone.
	JC	MENU		;if no dial tone, go menu.
	CALL	ILPRT		;clear 'waiting...' line
	DB	ESC,ETEOP,0
	MVI	B,'A'		;first letter of alphabet
	MVI	E,0		;counts number of letters to match
	MVI	C,26		;number of letters in alphabet
	MOV	A,M		;get char buffer
DIAL11	CMP	B		;letter from library table?
	JZ	LIBSET
	INR	B		;make next letter (a --> z)
	INR	E		;count up
	DCR	C		;count down
	JZ	DIALLPX		;not a letter, go get typed numbers.
	JMP	DIAL11		;loop

; match between requested ltr and one in library
; (e-reg contains decimal equivalent of ltr)

LIBSET	LXI	H,NUMBLIB	;phone number library
	LXI	B,LIBLEN	;length of library entry
	MOV	A,E		;number of times to add 34 to hl-pair
	ORA	A		;set flags
	JZ	DIAL13
DIAL12	MOV	A,M		;get first char of selected lib entry
	ORA	A
	JZ	DIALLP2		;send badlib msg
	DAD	B		;increment hl-pair by 34
	DCR	E		;countdown
	JNZ	DIAL12		;not there yet, loop.
DIAL13	MVI	B,LIBLEN	;number of characters to get from table
	LXI	D,CMDBUF+1	;point to buffer
	XCHG			;hl-pair points to cmdbuf+1 (exchange de/hl)
	MOV	M,B		;store # of bytes in each library entry
	XCHG			;restore regs
	INX	D		;point to first char position in buffer
	CALL	MOVE		;move table entry to buffer

; full telephone number in 'cmdbuf' -- shows # of dialing attempts

DIALLPX	LXI	H,CMDBUF+1
	MOV	E,M		; # of chars in buffer with pointer..
	INX	H		;..to first chararacter to dial.
DIALLP2	MOV	A,M		;get first # from buffer

; routine to print 'badlib' message, abort if null encountered

	ORA	A		;set flags
	PUSH	H		;save hl-pair registers
	PUSH	PSW		;save a and flags
	LXI	H,BADLIB	;bad library number if null
	CZ	TEXTOUT
	POP	PSW		;restore a-reg and flags
	POP	H		;restore hl-pair
	JZ	BORTIT0		;abort dialing

; dial a digit -- check kbd for abort

	CALL	DIAL		;dial it (type all letters & numbers dialed)
	CALL	STAT		;keypress?
	CNZ	KEYIN		;yes, go get it.
	CPI	CAN		; ^x?
	JZ	BORTIT0		;yes, abort.
	INX	H		;bump pointer
	MVI	B,1		;wait 1 time interval (.1 sec)
	CALL	TIMER
	DCR	E		;count dial-characters down
	JNZ	DIALLP2		;not done, loop.

; dialing completed

	CALL	ILPRT
	DB	ESC,BDIM,' (dial #',0
	LHLD	DIALCNT		;update number of..
	INX	H	
	SHLD	DIALCNT		;..dialings and display..
	CALL	DECOUT		;..connection attempts.
	CALL	ILPRT
	DB	') ',ESC,ETEOP,ESC,EDIM,0
	MVI	A,7FH		;turn-on 'dtr'
	CALL	OUTCTR2
	MVI	B,1
	CALL	TIMER	  	;wait for modem to turn-on 'dtr'
	MVI	A,5DH	  	;no parity, 2 stop & 8 data bits + no..
	CALL	OUTCTRL		;..disconnect after 17 secs.
	MVI	D,CTS	  	;clear to send mask
	MVI	C,WAITCTS 	;wait-time for 'cts'
	CALL	WAIT
 	JNC	CONMADE	  	; 'connection made' (cm) else..
	CALL	DISCONN	  	;..go on-hook.
DILAGN	LDA	CRFLAG	  	;continuous re-dial (cr) flag
	ORA	A
	JNZ	DILAGN0
	CALL	ILPRT
	DB	CR,'No answer after normal time-out.  Re-dial?  '
	DB	'Y>es, N>o, or C>ontinuous: ',BELL,0
	CALL	RESPOND		;get response
	CALL	CRONLY		;overwrite with new line to be dialed
	CPI	'N'		;re-dial?
	JZ	MENU		;no, go menu.
	CPI	'Y'
	JZ	DILAGN0		;yes, re-dial.
	CPI	'C'		;continuous re-dial?
	JNZ	DILAGN		;invalid response, ask again.
	MVI	A,TRUE		;set continuous re-dial flag..
	STA	CRFLAG		;..true.
DILAGN0	MVI	B,70		; 7-second wait for pmmi reset else busy..
	CALL	TIMER		;..signal may be sensed as dial tone.
	LDA	RBFLAG		;ringback type of dial?
	ORA	A
	JZ	DIALLP1		;no, re-dial a normal number..
	STA	CMDBUF+1	;..else restore full # including 'r'.
	JMP	DIALLP1		;re-dial entry point at cmdbuf+2

BADLIB	DB	CR,LF,'++ Faulty dialing ++',CR,LF,'@'

; auto dialer

DIAL	CALL	TYPE		;print all characters, dashes, etc.
	CPI	'0'		;digit must be at least 0..
	RC
	CPI	'R'		;ringback character?
	JNZ	DIAL1		;if not, jump.
	PUSH	PSW		;save accumulator & flags..
	MOV	A,E		;put # of char left into a-reg
	CPI	1		;is this the last character?
	JZ	RINGBK		;yes, must be ringback char so ringback.
	POP	PSW		;..and restore.
DIAL1	CPI	'9'+1		;..and not more than 9 (numeral parse).
	RNC
	ANI	0FH		;strip ascii
	JNZ	DIALS
	MVI	A,10		;convert zero to 10 pulses
DIALS	MOV	C,A
	LDA	PULSERATE	;contains value for dial speed
	CALL	OUTBAUD
DIALC	CALL	INBAUD
	ANI	TMPUL
	JNZ	DIALC
DIALB	CALL	INBAUD
	ANI	TMPUL
	JZ	DIALB
MAKEP	MVI	A,MAKEM
	CALL	OUTCTRL
TIMEM	CALL	INBAUD
	ANI	TMPUL
	JNZ	TIMEM
	MVI	A,BRKMASK
	CALL	OUTCTRL
TIMEB	CALL	INBAUD
	ANI	TMPUL
	JZ	TIMEB
	DCR	C
	JNZ	MAKEP
	MVI	A,MAKEM
	CALL	OUTCTRL
	MVI	B,2
	JMP	TIMER	  	;ret to caller

RINGBK	POP	PSW	  	;balance stack
	CALL	ILPRT
	DB	ESC,ETEOP,0	;clear console line
	LDA	CMDBUF+1  	;get # of char in buffer
	STA	RBFLAG		;store # including the 'r'
	DCR	A 	  	;subtract 1 to avoid 'r' char
	STA	CMDBUF+1  	;store new value for next time
	MVI	D,DTMSK	  	;load tone detect mask
	MVI	C,RBLMT	  	;set timer for rblmt # of seconds
	CALL	WAIT
	JC	RBTIME	  	;jump if no tone detected
	MVI	B,25	  	;wait 2.5 sec
	CALL	TIMER
	CALL	INBAUD	 	;is tone still present?
	ANA	D
	JNZ	RNGBK1
	JMP	DILAGN	  	;yes, must be busy now.

; hangup -- re-dial -- listen for dial tone

RBTIME	CALL	CRONLY		;just a cursor return
RNGBK1	CALL	HANGUP	 	;hang up the phone
	MVI	B,RBWAIT 	;wait x sec before re-dialing
	CALL	TIMER
	CALL	DIALPL0	 	;go off-hook, listen for dialtone.
	JNC	DIALLPX	 	;dial number and wait till..
	JMP	MENU	 	;..time-out or connection.

; modem go on-hook

HANGUP	MVI	A,CLEAR		;idle
	CALL	OUTCTR2
	XRA	A
	CALL	OUTCTRL		;clear dtr/etc
	RET

; time-out routine.  called with mask in d-reg for input at
; relative port 2 and # of seconds * 5 in c-reg.  checks kbd
; for abort.

WAIT	MVI	B,2		;makes interval..
	CALL	TIMER	  	;..200 milliseconds.
	CALL	INBAUD	 	;modem status port
	ANA	D	  	; ('cts' or dialtone mask)
	RZ		  	;active low, so return on zero.
	PUSH	D		;save mask
	CALL	STAT	  	;keypress?
	CNZ	KEYIN	  	;yes, get char.
	CPI	CAN		; ^x?
	JZ	BORTIT0		;yes, disconnect, jmp to menu.
	POP	D		;get mask back
	DCR	C		;count-down (100 = 20 sec)
	JNZ	WAIT
	CALL	DISCONN	  	;go on-hook
	STC			;set carry to indicate either dial tone..
	RET			;..not detected or 'cts' not received.

; disconnect and start anew

BORTIT0 CALL	CRLF		;a 'crlf' followed by..
BORTIT	CALL	DISCONN 	;..disconnect, reset option..
	JMP	MENU		;..table, and show prompt.

; disconnect then wait for dial tone

DIALPL0	CALL	DISCONN		;go on-hook
	CALL	ILPRT
	DB	CR,ESC,ETEOP,ESC,BDIM
	DB	'           WAITING FOR DIAL TONE  ',ESC,EDIM,CR,0
	MVI	A,MAKEM		;make 'make' (off-hook)
	CALL	OUTCTRL
	MVI	D,DTMSK		;dial tone mask
	MVI	C,25		; 25 = 5 second wait
	CALL	WAIT		;wait for dial tone delay

; 'wait' returns with carry not set if dialtone recieved

	RNC			;if dial tone within 5 seconds..
	CALL	ILPRT		;..else msg and return to menu.
	DB	CR,LF,LF
	DB	'++ No dial tone ++'
	DB	CR,LF,LF,BELL,0
	STC			;set carry true
	RET

; modem disconnect routine

DISCONN XRA	A		;store a disconnected..
	STA	LINEFLG		;..condition here.
	CALL	OUTCTR2		;clear dtr, esd, etc., and..
	CALL	OUTCTRL		;..hang-up (go on-hook).
	MVI	B,8		;wait for pmmi to disconnect
	JMP	TIMER		;ret to caller

; telephone-connection-made announcement

CONMADE	CALL	ILPRT
	DB	CR,LF,'Connection established -- select options '
	DB	'(e.g., TO.300 fn.ft): ',0
	MVI	A,TRUE		;indicate line..
	STA	LINEFLG		;..is connected.
CMLP	CALL	STAT		;ck for keypress
	JNZ	GETCMD		;key pressed, go get options.
	MVI	A,BELL		;ring bell until..
	CALL	TYPE		;..a key pressed.
	MVI	B,1		;delay for console..
	CALL	TIMER		;..to process bell.
	JMP	CMLP		;loop 'til keypress
	 ENDIF			;pmmi

; d i r

; display drive directory & reset disk system

DIR	CALL	RESET		;reset system for disk changes
	CALL	DIRLIST		;show directory and space remaining

; m e n u   (command mode)

MENU	LXI	H,RESTRN	;restore record numbers, etc,..
	LXI	D,RECDNOB	;..for new file transfer.
	MVI	B,RECDNOE-RECDNOB
	CALL	MOVE
	LXI	H,RESTROPT	;restore secondary option table
	LXI	D,OPTBL
	MVI	B,OPTBE-OPTBL
	CALL	MOVE
	XRA	A
	STA	MFFLG1		; reset mfname (multi-filename) routine..
	STA	ABORTFLG	;clear abort flag
	CMA			; ..and batch mode to recover..
	STA	FSTFLG		; ..from an abort.
MENU1	LDA	XPRFLG		;test if menu should be shown
	ORA	A
	JNZ	XPRT		;don't show menu
MENU2	CALL	CAPTION		;show program title header
	CALL	ILPRTQ
	DB	ESC,BDIM
	DB	'                    -- M E N U --',CR,LF,LF
	DB	'C o m m a n d   M o d e',CR,LF,ESC,EDIM
	DB	'DIR - Directory roster (reset disk system) [d: *.ft]'
	DB	CR,LF

	 IF	UTL
	DB	'UTL - Utility for disk file manipulation',CR,LF
	 ENDIF			; 'utl'

	DB	'WRT - Write-to-disk file Terminal Mode saved',CR,LF
	DB	'DEL - Delete file Terminal Mode saved ',CR,LF
	DB	'ERA - Erase CP/M files (ERA fn.ft)'

	 IF	VUE
	DB	CR,LF
	DB	'VUE - View a text file (VUE fn.ft)'
	 ENDIF			; 'vue'

	DB	ESC,BDIM
	DB	'        T e r m i n a l   M o d e',CR,LF,ESC,EDIM
	DB	'T   - Terminal Mode (TO.300 fn.ft)      ',ESC,BDIM
	DB	'(command lead-in character =',0
	LDA	CMDCHR		;get command character and..
	CALL	SHOWCTL		;..print it.
	CALL	ILPRT
	DB	')',ESC,EDIM,CR,LF
	DB	'E   - Echo (computer) Mode                R - '
	DB	'Review softkey strings',CR,LF
	DB	'S   - Send CP/M file (ST fn.ft)           T - '
	DB	'Transfer file',CR,LF
	DB	'R   - Receive CP/M file (RT fn.ft)        S - '
	DB	'Save-file (fn.ft) toggle',CR,LF
	DB	'M   - Menu presentation                   E - '
	DB	'Exit to command mode',CR,LF

 	 IF	PMMI
	DB	'CAL - Dial telephone number               B - '
	DB	'Baudrate change on-the-fly',CR,LF
	DB	'DSC - Disconnect telephone                D - '
	DB	'Disconnect telephone',CR,LF
	 ENDIF			;pmmi

	DB	'SEL - Select transmission format          P - '
	DB	'Printer toggle',CR,LF
	DB	'SAP - Sort and Pack Directory           ',0
	LDA	CMDCHR		;get command character and..
	CALL	SHOWCTL		;..print it.
	CALL	ILPRT
	DB	' - Send lead-in character',CR,LF
	DB	'CPM - Exit to CP/M                        n - '
	DB	'Send text string (0 to 9)',CR,LF,LF
	DB	ESC,BDIM
	DB	'Secondary Options: '
	DB	ESC,EDIM,'O>riginate, A>nswer, .xxx = baudrate xxx, '
	DB	'T>erminal return,',CR,LF
	DB	'B>atch, Q>uiet or V>iew transfers.  D>isconnect/E>xit-'
	DB	'to-CP/M when transfer is',CR,LF
	DB	'completed.',CR,LF,LF,0
	JMP	C$LINE		;set up to show command line

	LINK	COMM723A	;chains to 'comm723a.asm' using lasm.com
