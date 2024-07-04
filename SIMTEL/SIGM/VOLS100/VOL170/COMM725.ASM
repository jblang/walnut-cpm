; title	'cp/m-80 communication program version 7.25'

VERS	EQU	7$25	;version number..
MONTH	EQU	11	;..month..
DAY	EQU	26	;..day..
YEAR	EQU	83	;..and year.

;comm7 provides extensive communications capabilities using the established
;christensen 'xmodem' protocol.  additionally, integrated file manipulation
;routines ('utl' and 'sap') allow disk housekeeping functions to be performed
;efficiently without leaving the program.  a full single-screen main menu
;plus sub-menus provide summaries of commands and options available to the
;operator.  lasm.com or linkasm.com is required to assembly comm7.  operating
;procedures are detailed in comm7.doc.

;s-100 bus features are emphasized.  primarily, u.s. robotics s-100 (smart
;modem), pmmi mm-103, and hayes mm-100 plug-in boards are handled.
;external (rs-232c) ported modems can be used if applicable code and equates
;are fittingly altered.  clock/calendar s-100 boards from compupro (ss1) and
;compu/time (cw) are provided for.

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

;11/26/83  maximum allowed cpu clock rate increased to 25.5 mhz.  code added
;to manage u.s. robotics s-100 modem board.  operation is similar (though
;not identical) to that of mm-100 and mm-103.  baudrate must be set while
;off-line and can't change from originate to answer mode.  program comes
;up in 1200 baud default mode.  tnx to paul traina, mark edwards, walter
;blady, and jim mills for assistance in learning some required code fragments.
;also tnx to irv hoff for 'mci/sprint' type alternate dialing approach.  and
;for their help, special tnx to the great guys (bob fulton and jim butler) at
;u.s. robotics in chicago.  set crt attribute code equates to refer to memory
;hopefully permitting future use of 'comm7ins' to change from one crt to
;another.  (725)  fg

;copyright to program has been maintained for one reason -- we can get very
;(legally) annoyed if somebody tries to sell these fruits of our labor for a
;profit.  you may make copies for yourself and your friends, and you can even
;sell it for disk cost plus postage.  we encourage this to get the program to
;people who need it, to keep them from reinventing it.  we would appreciate
;you keeping our names on it.  (oh, come on...it's not that much trouble.)
;if we give up money-making on the thing, it's hardly fair for someone
;else to mop up.  (but on the other hand, who said "living is fair"?)

;		frank gaude'			paul traina
;		los altos hills, calif.		saratoga, calif.

; comm7 is copyright (c) 1980, 1983 by mark zeiger, paul traina, and frank
; gaude' and released to public domain for non-commerical use.  monetary gain
; is not permitted under any circumstance by individual, partnership, or
; corporation without written permission of the authors.

; assemble using 'lasm.com' or 'linkasm.com'.  comm725.asm, comm725a, b, c,
; and d.asm must be on same drive.  (edit each assembly subfile independently,
; as required.)

; enter -> lasm comm725.aaz b:  (source on 'a' drive, hex goes on 'a', no prn
;			        file, and symbol table on drive b: for use by
;			        sid.com.  'lasm comm725' produces prn, all 
;			        files on default drive, no symbol table.  see
;			        lasm.doc for complete details.)

;          load comm725		(produces com file.)

; starting definitions

TRUE	  EQU	0FFH		;define true..
FALSE	  EQU	0		;..and false.

; set modem port address and type

PORT	  EQU	070H		;modem port base address (use 70h or c0h)

US100	  EQU	TRUE		;true for u.s. robotics s-100, else false.
DL$TYPE	  EQU	'T'		;touch-tone (t) or pulse (p) dial
ALT$DIAL  EQU	TRUE		;true if 'mci/sprint' type dialing permitted
PMMI	  EQU	FALSE		;true if using a pmmi, false if not.
MM100	  EQU	FALSE		;true if using a mm-100, false if not.
EXTERNAL  EQU	FALSE		;true if external modem, else false.

; set utilities

SOFTKEY	  EQU	TRUE		;true for soft dual-key auto-text output
UTL	  EQU	TRUE		;true if 'utl' disk file manipulator (disk7)
VUE	  EQU	FALSE		;true if 'vue' instead of 'utl'.  must be
DUMB	  EQU  	TRUE		;true if not smart line-editor transfers

; rtc clock port (if using s-100 hardware time/date circuit)

RTC	  EQU	FALSE		;true if using clock/calendar circuit
CW	  EQU	FALSE		;true if compu/time cw board
SS1	  EQU	FALSE		;true if compupro/godbout ss1 board
TIME$ONLY EQU	FALSE		;true if 'time' without 'day/date' at cmd line
CLKBASE	  EQU	54H		;base port of clock board (if rtc true)

; system equates

CPM$BASE  EQU	000H		;cp/m system entry address
TPA	  EQU	100H		;cp/m transient program area base
DBUFSIZ	  EQU	16		;file s/r buffer size in kbytes (k=1024)
MAXDR	  EQU	'C'		;maximum drive in system: 'a', 'b', 'c', etc.
RING	  EQU	32		;printer ring-buffer and..
CCP	  EQU	8		;..cp/m 'ccp/zcpr' size in 256-byte pages.
ERRLIM	  EQU	10		;number of re-tries on send/receive..
				;..error before auto-quitting.
ERRCRC	  EQU	6		;number of tries (at 10 seconds each)..
				;..for crc before switching to checksum.
LPS	  EQU	24-2		;lines-per-screen 'vue' pagination
NPL	  EQU	5		; 'dir' display filenames-per-line
RBUF	  EQU	40		;buffer at auto-colon-file ram-to-disk save
				; (set to 128 if using 'mci/sprint' circuits)
GET	  EQU	0FFH		;get user area e-reg value

; set system cpu clock frequency to nearest tenth megahertz x 10.
; 4 mhz = 40, 3.7 mhz = 37, up to 25.5 mhz = 255 (max).

MHZ	  EQU	40		;cpu speed * ten in megahertz

; crt terminal selection

ADM21	  EQU	FALSE 		;true for lsi adm-21
ADM31	  EQU	FALSE		;true for lsi adm-31
ADM42	  EQU	FALSE		;true for lsi adm-42
ADM5	  EQU	FALSE		;true for lsi adm-5
SOROC	  EQU	FALSE		;true for soroc 120
TELEVIDEO EQU	TRUE		;true for tvi910/912/920/925/950 or 970
TELE25TH  EQU	TRUE		;true if tvi has 25th line (925/950/970)
VIEWPOINT EQU	FALSE		;true for adds viewpoint
VISUAL	  EQU	FALSE		;true for visual 200
ZENITH	  EQU	FALSE		;true for zenith h19/z19 terminals

; waiting limit for remote computer carrier (cd/cts/tone)

WAIT$CD	  EQU	'25'		;seconds to wait for remote computer..
				;..carrier tone after auto-dial function.
				;used by u.s. robotics (99 max value).  up
				;to 60 seconds required for int'l calls.

WAITCTS	  EQU	125		;seconds x 5, 255 max. (used by pmmi and mm100)

; crt terminal equates
; ((add values as required and known.  if half-intensity (dim) not available
; for your terminal, you may prefer to use dummy character instead of reverse
; video.))

	 IF	TELEVIDEO OR ADM21
CLS	EQU	1AH		; '^z' = clear screen/home cursor
CLS2	EQU	1AH		;send again to fill memory space pervided
	 ENDIF			;televideo or adm21

	 IF	ADM31
CLS	EQU	1BH		; <esc> '*' = clear screen
CLS2	EQU	2AH
	 ENDIF			;adm31

	 IF	TELEVIDEO OR ADM21 OR ADM31
ETEOP	EQU	'Y'		; <esc> 'y' = erase-to-end-of-page
BDIM	EQU	')'		;begin and..
EDIM	EQU	'('		;..end half-intensity.
	 ENDIF			;televideo or adm21 or adm31

	 IF	ADM42
CLS	EQU	1BH		; <esc> 'e' = clear screen
CLS2	EQU	45H
ETEOP	EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	EQU	00H		;dummy
EDIM	EQU	00H		;dummy
	 ENDIF			;adm42

	 IF	ADM5
CLS	EQU	1AH		; '^z' = clear
CLS2	EQU	1AH
ETEOP	EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	EQU	00H		;dummy
EDIM	EQU	00H		;dummy
	 ENDIF			;adm5

	 IF SOROC
CLS	EQU	1BH		;clear = <esc> '*'
CLS2	EQU	2AH
ETEOP	EQU	'Y'		; <esc> 'y' = erase to end of page
BDIM	EQU	00H		;dummy
EDIM	EQU	00H		;dummy
	 ENDIF			;soroc

	 IF	VIEWPOINT	; (handled in custom way in various routines)
CLS	EQU	0CH		; '^l' = clear screen
CLS2	EQU	0CH
ETEOP	EQU	'K§		» <esc> 'k§ = erase to end of page
BDIM	EQU	'N'-40H
EDIM	EQU	'O'-40H
	 ENDIF			;viewpoint

	 IF	VISUAL
CLS	EQU	1BH		;clear = <esc> 'v'
CLS2	EQU	76H
ETEOP	EQU	'y'		; <esc> 'y' = erase to end of page
BDIM	EQU	00H		;dummy
EDIM	EQU	00H		;dummy
	 ENDIF			;visual

	 IF	ZENITH
CLS	EQU	451BH		; <esc> 'e' = clear screen/home cursor 
ETEOP	EQU	'J'		; <esc> 'j' = erase-to-end-of-page
BDIM	EQU	'p'		;begin and..
EDIM	EQU	'q'		;..end half-intensity.
	 ENDIF			;zenith

; modem sensitive equates (set base port address above)

; u.s. robotics s-100 (uses 8251a usart)

	 IF	US100
SPORT  	EQU	PORT+1		;status/command/mode and..
DPORT  	EQU	PORT		;..data port.
CPORT2	EQU	SPORT		;dummy 2nd control port
TBMT$B	EQU	1		;modem send bit (tbmt)..
TBMT$R	EQU	1		;..send ready..
DAV$B	EQU	2		;..receive bit (dav) and..
DAV$R	EQU	2		;..receive ready.
CTS	EQU	80H		;clear-to-send mask (status bit 7)
BRK	EQU	08H		;set break (command bit 3)
FE	EQU	020H		;framing..
OE	EQU	010H		;..overrun and..
PE	EQU	008H		;..parity error. (all status bits)
ERRCDM	EQU	FE+OE+PE	;mask for all error codes
NOPARM	EQU	0CFH		;reset to no parity (mode bits 4 & 5)
ODDPARM	EQU	010H		;set odd and.. (mode bit 4)
EVNPARM	EQU	030H		;..even parity. (mode bits 4 & 5)


; modem usart (mode) control bit equates

M5DATA	EQU	0000$0000B	;5 data bits
M6DATA	EQU	0000$0100B	;6 data bits
M7DATA	EQU	0000$1000B	;7 data bits
M8DATA	EQU	0000$1100B	;8 data bits
MEPAR	EQU	0011$0000B	;even or..
MOPAR	EQU	0001$0000B	;..odd parity.
MNPAR	EQU	0000$0000B	;no parity
M1STOP	EQU	0100$0000B	;one or..
M2STOP	EQU	1100$0000B	;..two stop bits.
	 ENDIF			;us100

; hayes mm-100

	 IF	MM100
DPORT	EQU	PORT		;data port
SPORT	EQU	PORT+1		;status port
CPORT2	EQU	PORT+2		;control port #2
TPORT	EQU	PORT+3		;timer port
DAV$B	EQU	00000001B	;data available (mask)
DAV$R	EQU	00000001B	;data available (test)
TBMT$B	EQU	00000010B	;xmit buffer empty (mask)
TBMT$R	EQU	00000010B	;xmit buffer empty (test)
CTS	EQU	01000000B	;clear to send (carrier detect)
FE	EQU	00001000B	;framing..
OE	EQU	00010000B	;..overrun and..
PE	EQU	00000100B	;..parity error.
TMPUL	EQU	00100000B	;timer end-up
ERRCDM	EQU	PE+FE+OE	;mask to detect all errors
BRK	EQU	00001000B	;set break
NOPARM	EQU	11111110B	;mask to remove parity attributes
ODDPARM	EQU	00000000B	;set odd parity attributes
EVNPARM	EQU	00000001B	;set even parity attributes

OFFHOOK	EQU	10000111B	;bring modem off hook
ONHOOK	EQU	00000101B	;bring modem on hook (hangup)

; modem uart control bit equates

M5DATA	EQU	00000000B	; 5..
M6DATA	EQU	00000010B	;..6..
M7DATA	EQU	00000100B	;..7..
M8DATA	EQU	00000110B	;..and 8 data bits.
MEPAR	EQU	00000001B	;even parity
MOPAR	EQU	00000000B	;odd parity
MNPAR	EQU	00010000B	;no parity
M1STOP	EQU	00000000B	;one stop bit
M2STOP	EQU	00001000B	;two stop bits
	 ENDIF			;mm100

; pmmi mm-103

	 IF	PMMI
SPORT  	EQU	PORT		;status (control) and..
DPORT  	EQU	PORT+1		;..data port.
BPORT	EQU	PORT+2		;baudrate and status port
CPORT2	EQU	PORT+3		;control port #2
TBMT$B	EQU	1		;modem send bit (tbmt)..
TBMT$R	EQU	1		;..send ready..
DAV$B	EQU	2		;..receive bit (dav) and..
DAV$R	EQU	2		;..receive ready.
CTS	EQU	4		;clear-to-send mask
BRK	EQU	0FBH		;mask to set break
PE	EQU	008H		;parity..
FE	EQU	020H		;..framing and..
OE	EQU	010H		;..overrun error.
ODDPARM	EQU	0CFH		;set odd parity..
EVNPARM	EQU	020H		;set even parity
ERRCDM	EQU	FE+OE+PE	;mask for all error codes

; dialing routine equates

BRKMASK	EQU	0		;tele line on-hook (break during dialing)
CLEAR	EQU	3FH		;idle mode
DTMSK	EQU	1		;dial tone mask
MAKEM	EQU	1		;tele line make (off-hook)
TMPUL	EQU	80H		;timer pulses mask bit

; modem uart control bit equates -- set for originate mode

M5DATA	EQU	00000001B	; 5..
M6DATA	EQU	00000101B	;..6..
M7DATA	EQU	00001001B	;..7 and..
M8DATA	EQU	00001101B	;..8 data bits.
MEPAR	EQU	00100001B	;even and..
MOPAR	EQU	00000001B	;..odd parity.
MNPAR	EQU	00010001B	;no parity
M1STOP	EQU	00000001B	;one or..
M2STOP	EQU	01000001B	;..two stop bits.
	 ENDIF			;pmmi

; external modem equates

	 IF	EXTERNAL
PORT	EQU	??H		;serial base (rs-232c) port
DPORT	EQU	PORT		;data port
SPORT	EQU	PORT+1		;status port
DAV$B	EQU	00000001B	;data available (mask)
DAV$R	EQU	00000001B	;data available (test)
TBMT$B	EQU	00000010B	;xmit buffer empty (mask)
TBMT$R	EQU	00000010B	;xmit buffer empty (test)
	 ENDIF			;external

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

LEADIN	EQU	ESC		;crt screen control character
CAN	EQU	'X'-40H		; ^x = cancel dial/send/receive/view-file
EOFCHAR	EQU	'Z'-40H		; ^z = end of ascii cp/m file
XOFF	EQU	'S'-40H		; ^s = xoff character
XON	EQU	'Q'-40H		; ^q = xon character
INTCHR	EQU	'['-40H		; ^[ = enter terminal command mode (cmd)

; assembly origin (load address) and program beginning

SOURCE	ORG	CPM$BASE+TPA
	JMP	START

; storage is here for quick com file patching by a monitor without
; re-assembling program.  comm7ins uses this area for installing
; (changing) on-the-fly.

BAKUPBYTE DB	TRUE		;true=make .bak file
XPRFLG	  DB	TRUE		;false=print menu 1st time thru
SAVCCP	  DB	TRUE		;true=do not overwrite ccp (or ring-buffer)
CMDCHR	  DB	INTCHR		;set intercept (lead-in) character
BELLFLG	  DB	TRUE		;true=beep for printer/file-save in term mode
MCLS	  DB	CLS
MCLS2	  DB	CLS2
MLEADIN	  DB	LEADIN
METEOP	  DB	ETEOP
MBDIM	  DB	BDIM
MEDIM	  DB	EDIM
DIAL$TP	  DB	DL$TYPE		;touch-tone (t) or pulse (p) dialing
TOUCH$T	  DB	ALT$DIAL	;permits 'mci/sprint' type dialing

; baudrate index register -- 0=110, 1=300, 2=450, 3=600, 4=710
; and 5=1200 baud

MSPEED	  DB	1		;initial and new baudrate index register

	   IF	PMMI
PULSERATE DB	150		; 125=20pps dialing, 250=10pps.
ORIGMOD	  DB	1DH		;originate mode
ANSWMOD	  DB	1EH		;answer mode
           ENDIF		;pmmi

	   IF	MM100
ORIGMOD	  DB	87H		;originate mode
ANSWMOD	  DB	83H		;answer mode
	   ENDIF		;mm100

; modem sensitive routines

OUTSTAT	IN 	SPORT		;in (from) modem control port
	ANI	TBMT$B		;bit to test for send ready
	CPI	TBMT$R ! RET	;send bit value when ready
INSTAT	IN 	SPORT
	ANI	DAV$B		;bit to test for receive ready
	CPI	DAV$R  ! RET	;receive bit value when ready
INCHAR	IN 	DPORT  ! RET	;in (from) and..
OUTCHAR	OUT	DPORT  ! RET	;..out (thru) modem data port.

	 IF	PMMI OR MM100 OR US100
INCTRL	IN 	SPORT  ! RET	;in and..
OUTCTRL	OUT	SPORT  ! RET	;..out modem control port.
OUTCTR2	OUT	CPORT2 ! RET	;out modem control port #2
	 ENDIF			;pmmi or mm100 or us100

	 IF	PMMI
INBAUD	IN 	BPORT  ! RET	;in and..
OUTBAUD	OUT	BPORT  ! RET	;..out baudrate port.
	 ENDIF			;pmmi

	 IF	MM100
OUTTIME	OUT	TPORT  ! RET	;output to timer port
	 ENDIF			;mm100

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
;
; for compatibility with comm7 install program (comm7ins), each string
; should be exactly 32 characters long -- pad out unused bytes with 0s.

	 IF	SOFTKEY
SOFTMSG	DB	CR,ESC,ETEOP,' -- Softkey Stored '	;header of..
	DB	'Strings --',CR,LF			;..local..
	DB	'      <cmd> 1,2,3...9,0',CR,LF,LF	;..display.
SKONE	DB	'DIR *.* $U0AD',CR,0			;esc '1'
	DB	'                ',CR
SKTWO	DB	'*.* $U0AD',CR,0			;esc '2'
	DB	'                    ',CR
SKTHREE	DB	'XMODEM R ',0				;esc '3'
	DB	'                     ',CR
SKFOUR	DB	'XMODEM S ',0				;esc '4'
	DB	'                     ',CR
SKFIVE	DB	'USER',CR,0				;esc '5'
	DB	'                         ',CR
SKSIX	DB	'WHATSNEW',CR,0				;esc '6'
	DB	'                     ',CR
SKSEVEN	DB	'Frank;Gaude''',cr,0			;esc '7'
	DB	'                 ',CR
SKEIGHT	DB	'Frank Gaude''',CR,0			;esc '8'
	DB	'                 ',CR
SKNINE	DB	'Los Altos Hills, CA',CR,0		;esc '9'	
	DB	'          ',CR
SKZERO	DB	'See you down the lines...',CR,0	;esc '0'
	DB	'   ',CR,'@'
	 ENDIF						;softkey

; mainline beginning

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

	 IF	VIEWPOINT
	CALL	ILPRT		;set half-intensity..
	DB	ESC,'0A',0	;..attribute.  (just for joe wright)
	 ENDIF			;viewpoint

	CALL	CAPTION		;show program title/header
	CALL	CRLF

; react to cp/m and comm7 command line entries

RESTART	LXI	SP,STACK	;start a fresh stack at restart
	CALL	CLR$L		;remove noise characters from line
	LDA	OPTION	 	;react to main (primary) option

	 IF	PMMI OR MM100 OR US100
	CPI	'C'		;call (dial) function?
	JZ	DLFONE		;yes, go for it.
	CPI	'D'		;disconnect?
	JZ	DISCON1		;yes, say disconnected and go to menu.
	 ENDIF			;pmmi or mm100 or us100

	CPI	'M' 		;menu asked for?
	JZ	MENU2		;yes, go menu.
	CALL	INITMOD		;set modem parameters and 'setbaud'
	CALL	MOVEFCB	   	;put filename at fcb, if there's one.
	LDA	OPTION	   	;now process main (primary) option
	CPI	'T'		;terminal mode?
	JZ	DSKSAVE		;yes
	CPI	'E'	   	;echo (resemble host computer) mode?
	JZ	TERM$ECHO	;yes
	CPI	'S'		;send a file?
	JZ	SENDFIL		;yes
	CPI	'R'		;receive a file?
	JZ	RCVFIL		;yes
	JMP	MENU		;no valid option spec'd, go menu.

; initialize console i/o and printer ring-buffer addresses -- save initial
; drive/user area for use in returning to cp/m -- initialize modem

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

	 IF	US100
INITUS	XRA	A		;clear..
	CALL	OUTCTRL		;..command register.
	CALL	OUTCTRL
	CALL	OUTCTRL
INITA   MVI	A,5		;default transfer time at 1200 baud
	STA	MSPEED
	MVI	A,40H		;reset 8251a usart in modem
	CALL	OUTCTRL
INITB	MVI	A,4EH		; 1/16 clock rate, 8 data, no parity, 1 stop.
	STA	UARTCTLB	; (mode byte) (4fh for 300 baud)
	CALL	OUTCTRL
INITC	MVI	A,37H		;dtr hi/rts on (hi-speed), xmit/rec enabled..
	STA	MODCTLB		;..reset error flags, no break.  (command byte)
	CALL	OUTCTRL
	RET
	 ENDIF			;us100

	 IF	MM100
	MVI	A,23		;set initial uart control block
	STA	UARTCTLB
	LDA	ORIGMOD		;set originate mode
	STA	MODCTLB
	RET
	 ENDIF			;mm100

	 IF	PMMI
	MVI	A,1EH		;set initial uart control block..
	STA	UARTCTLB	;..as asnwer mode.
	RET
	 ENDIF			;pmmi

; set requested baudrate -- initialize external modem, as required.  set
; operating mode to last requested determined by 'procopt'.  routine
; retains current mode and baudrate until explicitly changed at command
; line or with <cmd> 'b' in terminal mode.

INITMOD				; (external rs-232c goes here, as required)
SETBAUD 
	 IF	(NOT PMMI) AND (NOT MM100) AND (NOT US100)
	RET
	 ENDIF			;not pmmi/mm100/us100

	 IF	MM100
	LDA	UARTCTLB
	CALL	OUTCTRL
	 ENDIF			;mm100

	 IF	PMMI OR MM100 OR US100
	LDA	ANSWFLG		; (don't go off-hook if mode not specifed)
	ORA	A
	JZ	FIXBAUD		;if already 'off-hook' and if..
	LDA	ORIGFLG		;..neither mode specified, current baudrate..
	ORA	A		;..is retained even if declared (t.450 -->..
	RNZ			;..last rate declared.  use to.xxx to change.)
	 ENDIF			;pmmi or mm100 or us100

	 IF	PMMI OR MM100
FIXBAUD	CALL	GETBAUD		;baudrate divisor returned in a-reg
	CALL	SETMSPD		;index to print rate in c-reg; a-reg, divisor.
	 ENDIF			;pmmi or mm100

	 IF	US100
FIXBAUD RET
;	LDA	MODCTLB		;get current modem command byte
;	ANI	1111$1101B	;set 'dtr' low (logical on-hook) to allow..
;	CALL	OUTCTRL		;..baudrate/mode change while on-line (0fdh).
;	CALL	GETBAUD		;get rate and set 'mspeed' time-to-send index
;	CALL	INCTRL		;see if on-line and..
;	ANI	CTS		;..if..
;	ORA	A		;..so..
;	JZ	SETMODE		;..output..
;	CALL	ON$PLUS		;..escape string, delay fore and aft.
;SETMODE	LDA	ANSWFLG		;see if answer mode requested, else..
;	LXI	H,ATA
;	ORA	A
;	JZ	SMODE2
;	LDA	ORIGFLG
;	LXI	H,ATD		;..it is maybe originate..
;	ORA	A
;	JNZ	REINIT		;..or none.
;SMODE2	CALL	SM$STR
;REINIT	JMP	INITA		; (rets to caller)
	 ENDIF			;us100

	 IF	PMMI
	CALL	OUTBAUD		;set modem baud divisor
	CPI	52		; >300 baud?
	MVI	A,5FH		;dtr (filter for >300 baud)
	JC	GT300		;yes, greater than.
	MVI	A,7FH		;dtr (filter for 300 baud and less)
GT300	STA	MODCTLB		;store above filter value
	CALL	OUTCTR2		;set modem filter (go off-hook)
	MVI	B,1		;wait a bit after we said go off-hook
	CALL	TIMER
	LDA	UARTCTLB	;put last requested mode.. 
	CALL	OUTCTRL		;..to modem.
	 ENDIF			;pmmi

	 IF	MM100
	MOV	A,C		;get baudrate (0=110, 1=300)
	ANI	1		;keep only the first bit
	MOV	B,C		;put it in b
	LDA	ORIGMOD		;get originate mode parameters
	ANI	11111110B	;keep all but baud rate
	ORA	B		;set in new rate (0=110/1=300)
	STA	ORIGMOD		;save new baud rate
	LDA	ANSWMOD		;get answer mode parameters
	ANI	11111110B	;keep all but baud rate
	ORA	B		;set in new rate
	STA	ANSWMOD
	LDA	MODCTLB		;get uart control
	ANI	11111110B	;keep all but baud rate
	ORA	B		;set in new rate
	STA	MODCTLB
	CALL	OUTCTR2		;set new baudrate
	 ENDIF			;mm100

	 IF	PMMI OR MM100
	MOV	A,C		;get index to print..
	STA	MSPEED		;..baudrate in 'openok'.
	XRA	A		;ret to caller with flags..
	RET			;..set.
	 ENDIF			;pmmi or mm100

; determine if rate-change is necessary

	 IF	PMMI OR MM100
GETBAUD	LDA	FCB+9		;get 1st digit of baudrate from cmdline
	CPI	' '		;if 'blank', return with..
	LDA	BAUDRATE	;..current rate.
	RZ
	 ENDIF			;pmmi or mm100

; sm/usr baudrate determination routine

	 IF	US100
US$SET	CALL	CRONLY
	CALL	CTEOP
	LXI	D,BAUDBUF
	CALL	ILPRT
	DB	'Enter baudrate (300, 600, 1200): ',0
	CALL	INBUF
	LXI	D,BAUDBUF+2
        CALL	ILCOMP		;compare for match with characters..
        DB	'300',0 	;..here and..
        JNC	OK300
        CALL	ILCOMP
        DB	'600',0		;..here and..
        JNC	OK600
        CALL	ILCOMP
	DB	'1200',0	;..here. (cp/m truncates digits over 3)
        JNC	OK1200
        CALL	ILPRT		;no match, tell operator.
        DB	'++ Invalid baudrate ++',CR,LF,BELL,0
        JMP	US$SET		;loop 'till good entry

OK300	MVI	A,1		; 'mspeed' baud value into a-reg..
	LHLD	BD300		;..and 300 baud parameters in hl-pair.
	JMP	LOADBD		;now load them

OK600	MVI	A,3
	LHLD	BD600
	JMP	LOADBD

OK1200	MVI	A,5
	LHLD	BD1200
	JMP	LOADBD

LOADBD	STA	INITA+1		;change time-to-send index to match baudrate
	MOV	A,H		;get baudrate byte and..
	STA	INITB+1		;..store in.. (mode)
	MOV	A,L		;..'initus'.
	STA	INITC+1		; (command)
	CALL	INITA		;initialize to new rate..
	JMP	MENU		;..then back to command line.

; table of sm/usr baudrate parameters -- uart and modem control

BD300	DW	04F37H		; 300..
BD600	DW	04E27H		;..600 and.. (pmmi fsk compatible)
BD1200	DW	04E37H		;..1200 baud.

BAUDBUF	DB	10,0
	DS	10
	 ENDIF			;us100

; convert ascii baudrate to binary modem divisor -- store divisor in
; 'baudrate' register

	 IF	PMMI OR MM100
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
	RET
	 ENDIF			;pmmi or mm100

; change baudrate on-the-fly with <cmd> b in terminal mode

	 IF	PMMI OR MM100 OR US100
NEWBAUD	MVI	A,TRUE		;don't print question on printer
	STA	LISTFLG
	CALL	ILPRT
	 ENDIF		        ;pmmi or mm100 or us100
                                 
	 IF	(NOT TELE25TH) AND (PMMI OR MM100 OR US100)
	DB	CR,ESC,ETEOP     
	 ENDIF			;(not tele25th) and (pmmi or mm100 or us100)

	 IF	TELE25TH AND (PMMI OR MM100 OR US100)
	DB	ESC,'g',ESC,'f'
	 ENDIF			;tele25th and (pmmi or mm100 or us100)

	 IF	US100
	DB	'Enter baudrate (300/600/1200): ',0
	 ENDIF			;us100

	 IF	PMMI
	DB	'Enter baudrate (110/300/450/600/710): ',0
	 ENDIF			;pmmi

	 IF	MM100
	DB	'Enter baudrate (110/300): ',0
	 ENDIF			;mm100

	 IF	PMMI OR MM100 OR US100
	LXI	H,FCB+9
	MVI	M,' '		;put a 'blank' in first position to..
LOOP5	CALL	KEYIN		;..signal using current baudrate.
	CPI	CR		; <return> enters baudrate
	JNZ	LOOP6		;not cursor return
	 ENDIF			;pmmi or mm100 or us100

	 IF	TELE25TH AND (PMMI OR MM100 OR US100)
	CALL	ILPRT
	DB	CR,ESC,'h',0	;turn off 25th line
	 ENDIF			;tele25th and (pmmi or mm100 or us100)

	 IF	PMMI OR MM100 OR US100
	LDA	LSTRETF		;get printer status
	CMA			;flip it
	STA	LISTFLG		;turn printer back on (maybe)
	CALL	CRLF
	JMP	FIXBAUD		;make baudrate

; check and show keyboard entries

LOOP6	CPI	'0'		;make sure it's..
	JC	LOOP5		;..a number, else..
	CPI	'9'+1		;..don't accept it.
	JNC	LOOP5
	MOV	M,A		; 3 digits to memory (fcb9 to fcb11)
	CALL	TYPE		;echo character entered
	INX	H
	JMP	LOOP5		;loop till <return> entered
	 ENDIF			;pmmi or mm100 or us100

; t e l e p h o n e   n u m b e r   t a b l e

; dial from library of numbers entered into storage here before assembly-time.
; each db must be 'liblen' characters long for correct operation.  last db
; must end with 0 (null).  up to 26 numbers are allowed.  'r' as last
; character in line indicates an automatic ringback call, i.e., ring once,
; hang up, ring back and let ring until connection or 'timeout'.

; alternate dial feature:  use '<' or '>' in front of telephone number for
; alternate dial through 'mci/sprint' type services.  for example,
; 'g al mehr servu......>408/238-9621' dials 'alt$dial2' set
; of digits, 408/238-9621 digits next.  x's represent service
; access number; y's, user charge code; and each comma is a 2-second delay
; as necessary for correct circuit opeation.  'altdial' stings can be of any
; reasonable length, terminated by '@'. characters '<' and '>' cannot be used
; other than as first byte of station to be dialed.

	   IF	US100
ALT$DIAL1 DB	'xxxxxxx,,,,,,yyyyyyyy,,','@'	;accessed by '<' and..
ALT$DIAL2 DB	'xxxxxxx,,,,,,yyyyyyyy,,','@'	;..'>' character.
	   ENDIF				;us100

NUMBLIB	DB	'A Portola Valley PMS*.....851-3453'
	DB	'B Bob Nelson RCP/M....408/733-1364'
	DB	'C Dave Morgan RCP/M*..503/641-7276'
	DB	'D Hayward FORTH Tree......538-3580'
	DB	'E Milpitas OxGate*....408/263-2588'
	DB	'F Marin RCP/M RBBS........383-0473'
	DB	'G Al Mehr SERVU.......408/238-9621'
	DB	'H Thousand Oaks*......805/492-5472'
	DB	'I Tim Gary ''C'' RCP/M......949-1476'
	DB	'J Ed Svoboda*.........408/732-9190'
	DB	'K Mountain View PicoNET*..965-4097'
	DB	'L Paul Traina*........408/354-5934'
	DB	'M Bruce Ratoff RIBBS..201/272-1874'
	DB	'N TCBBS Dave Hardy*...313/846-6127'
	DB	'O Ed Huang DataTech*......595-0541'
	DB	'P       (*=24hr/R=ring back)      '
	DB	'Q Keith Petersen*....313/759-6569R'
	DB	'R LA RCP/M RBBS.......213/296-5927'
	DB	'S CompuServe/Mtn View.....961-7242'
	DB	'T Pasadena RBBS.......213/577-9947'
	DB	'U UAHsv RCP/M RBBS...205/895-6749R'
	DB	'V Pasadena CBBS*......213/799-1632'
	DB	'W Kelly Smith.........805/527-9321'
	DB	'X Chuck Forsberg*.....503/621-3193'
	DB	'Y Ward/Randy CBBS*....312/545-8086'
	DB	'Z Tim Linehan RCP/M*..206/357-7400',0	;end

; c a l

; modem auto-dial routines
; options from main command line:
;	1. cal <return>
;	2. cal x
;	3. cal nnn-nnn-nnnn[r]
;
; options from the library prompt line:
;	1. x
;	2. nnn-nnn-nnnn[r]
;
; where:   x = a telephone library letter
;	   n = a manually entered number to auto-dial
;        [r] = 'r' is optionally used for ring-back type of auto-dial

; modem control masks and library equate

RBLMT	EQU	35		; 7 sec to wait till no-ring-heard msg shows
RBWAIT	EQU	50		; 5 sec delay before re-dialing number
LIBLEN	EQU	34		;library entry length

; smartmodem/usr control strings

	 IF	US100
ATTEN	DB	'ATV0S7='	;get attention, terse, wait-time..
	DW	WAIT$CD		;..for remote tone (carrier) and..
STYLE	DB	'D?','@'	;..dial number (touch-tone or pulse).
ATA	DB	'ATA',CR,'@'	;change to answer and..
ATD	DB	'ATD',CR,'@'	;..to originate mode.
PLUS	DB	'+++','@'	;to ascii command mode while on-line, hang-up.
	 ENDIF			;us100

; dial phone number

	 IF	PMMI OR MM100 OR US100
DLFONE	XRA	A		;zero the..
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

; set-up for local print at entnum2.  enters here if 'cal' and no telephone
; number or letter were typed.  displays phone number library and asks for
; entry.

ENTNUM	CALL	CLEAR$S
	CALL	TO$DIM
	CALL	ILPRT
	DB	CR,LF,LF
	DB	HT,HT,HT,'        M o d e m',CR,LF
	DB	HT,HT,HT,'    T e l e p h o n e',CR,LF
	DB	HT,HT,HT,'      L i b r a r y',CR,LF,LF,0
	CALL	TO$FULL
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
	STAX	D		; 4th space
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
	CALL	TO$DIM
	CALL	ILPRT
	DB	CR,LF,'Enter library letter or phone '
	DB	'number -- press <RETURN> to start dialing.',CR,LF
	DB	'^X aborts dialing routine: ',0
	CALL	TO$FULL
	LXI	D,CMDBUF
	CALL	INBUF
	CALL	CRLF
	CALL	CRLF
DIALLP1	LXI	H,CMDBUF+1	; # of characters in buffer (auto-redial..
	MOV	A,M		;..entry here.)
	ORA	A   		;null means <return> pressed so..
	JZ	MENU		;..simply return to menu.
	INX	H 		;ltr or 1st typed number of # to dial
	 ENDIF			;pmmi or mm100 or us100

; enter routine with hl-pair pointing to # to dial

DIAL10
	 IF	PMMI OR MM100
	CALL	WTTONE		;disconnect, reconnect, wait dial tone.
	JC	MENU		;if no dial tone, go menu.
	 ENDIF			;pmmi or mm100

	 IF	US100
	MVI	B,1		; *** test wait routine ***
	CALL	TIMER
	 ENDIF			;us100

	 IF	PMMI OR MM100 OR US100
	CALL	ILPRT		;clear 'waiting...' line
	DB	CR,ESC,ETEOP,0
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
DIALLPX CALL	ILPRT
	DB	CR,ESC,ETEOP,0	;clear crt line on re-dial
	 ENDIF			;pmmi or mm100 or us100

; get smartmodem/usr attention for dialing

	 IF	US100
	LDA	DIAL$TP		;touch-tone or pulse dial?
	STA	STYLE+1		;put 't' or 'p' here
	LXI	H,ATTEN		;point to string
	CALL	SM$STR
CLS$L	CALL	IN$SM
	JNC	CLS$L
	 ENDIF			;us100

; full telephone number in 'cmdbuf' -- show # of dialing attempts at end

	 IF	PMMI OR MM100 OR US100
	LXI	H,CMDBUF+1
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
	DCR	E		;count dial-characters down
	JNZ	DIALLP2		;not done, loop.

; dialing completed

	CALL	TO$DIM
	CALL	ILPRT
	DB	' (dial #',0
	LHLD	DIALCNT		;update number of..
	INX	H	
	SHLD	DIALCNT		;..dialings and display these..
	CALL	DECOUT		;..connection attempts.
	CALL	ILPRT
	DB	') ',0
	CALL	CTEOP
	CALL	TO$FULL
	 ENDIF			;pmmi or mm100 or us100

	 IF	US100
	MVI	A,CR		;enter command
	CALL	SM$TYPE
SM$DLP	CALL	IN$SM		;clear modem line of 'ok' (0)
	JNC	SM$DLP
	JMP	SM$ANS		;get response (connect/no carrier)
	 ENDIF			;us100

	 IF	PMMI
	MVI	A,7FH		;turn-on 'dtr'
	CALL	OUTCTR2
	MVI	B,1
	CALL	TIMER	  	;wait for modem to turn-on 'dtr'
	MVI	A,5DH	  	;no parity, 2 stop & 8 data bits + ..
	CALL	OUTCTRL		;..disconnect on carrier loss after 17 secs.
	 ENDIF			;pmmi

	 IF	MM100
	LDA	UARTCTLB	;set uart word format
	CALL	OUTCTRL
	LDA	ORIGMOD		;set modem mode
	STA	MODCTLB		;and force it to originate mode
	CALL	OUTCTR2
	 ENDIF			;mm100

	 IF	PMMI OR MM100
	MVI	D,CTS		;clear to send mask
	MVI	C,WAITCTS 	;wait-time for 'cts'
	CALL	WAIT
 	JNC	CONMADE	  	; 'connection made' (cm) else..
	CALL	DISCONN	  	;..go on-hook.
	 ENDIF			;pmmi or mm100

	 IF	PMMI OR MM100 OR US100
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
DILAGN0	MVI	B,50		; 5-second wait for modem reset else busy..
	CALL	TIMER		;..signal may be sensed as dial tone.
	LDA	RBFLAG		;ringback type of dial? (# of chars to dial)
	ORA	A
	JZ	DIALLP1		;no, re-dial a normal number..
	STA	CMDBUF+1	;..else restore full # including 'r'.
	JMP	DIALLP1		;re-dial entry point at cmdbuf+2

BADLIB	DB	CR,LF,'++ Faulty dialing ++',CR,LF,'@'

; auto dialer

DIAL	CALL	TYPE		;print all characters, dashes, etc.
	CPI	'R'		;ringback character?
	JNZ	DIAL1		;if not, jump.
	PUSH	PSW		;save accumulator & flags..
	MOV	A,E		;put # of char left into a-reg
	CPI	1		;is this the last character?
	JZ	RINGBK		;yes, must be ringback char so ringback.
	POP	PSW		;..and restore.
DIAL1 	 ENDIF			;pmmi or mm100 or us100

	 IF	US100
     	MOV	B,A
	CALL	ALT$DL		;see if 'mci/sprint' type call
	MOV	A,B		;ascii character retained in b-reg
	CPI	','		; 2-second delay requested?
	JZ	SM$TYPE		;branch, if yes.  returns to caller.
	 ENDIF			;us100

	 IF	PMMI OR MM100 OR US100
	CPI	'0'		;byte must be at least 0..
	RC
	CPI	'9'+1		;..but not more than 9 to be dialed.
	RNC
	ANI	0FH		;make ascii into binary for dialing
	JNZ	DIALS		;convert a zero into..
	MVI	A,10		;..10 pulses.
DIALS	MOV	C,A		; # of pulses to dial in a/c-regs
	 ENDIF			;pmmi or mm100 or us100

	 IF	US100
	MOV	A,B		;put ascii digit to dial in a-reg
	JMP	SM$TYPE		;send digit and return to caller
	 ENDIF			;us100

	 IF	PMMI
	LDA	PULSERATE	;contains value for dial speed
	CALL	OUTBAUD
DIALC	CALL	INBAUD		;is timer done?
	ANI	TMPUL
	JNZ	DIALC		;no, so loop
DIALB	CALL	INBAUD		;wait one more time...
	ANI	TMPUL
	JZ	DIALB
MAKEP	MVI	A,MAKEM		;pulse phone off hook for a bit
	CALL	OUTCTRL
TIMEM	CALL	INBAUD		;wait n ms
	ANI	TMPUL
	JNZ	TIMEM
	MVI	A,BRKMASK	;pulse phone on hook for a bit
	CALL	OUTCTRL
TIMEB	CALL	INBAUD		;wait n ms
	ANI	TMPUL
	JZ	TIMEB
	DCR	C		;end of pulses?
	JNZ	MAKEP		;no, go pulse phone some more
	MVI	A,MAKEM		;yes, make sure phone is still off hook
	CALL	OUTCTRL
	 ENDIF			;pmmi

	 IF	MM100
MAKEP	MVI	A,OFFHOOK	;spend 50ms off hook
	CALL	OUTCTR2
	CALL	OUTTIME		;start 50ms timer
TIMEM	CALL	INCTRL		;time up?
	ANI	TMPUL
	JZ	TIMEM
	MVI	A,ONHOOK	;now spend 50ms on hook
	CALL	OUTCTR2
	CALL	OUTTIME		;start timer
TIMEB	CALL	INCTRL		;time up?
	ANI	TMPUL
	JZ	TIMEB
	DCR	C
	JNZ	MAKEP
	MVI	A,OFFHOOK	;phone off hook while we wait for next digit
	CALL	OUTCTR2
	 ENDIF			;mm100

	 IF	PMMI OR MM100
	MVI	B,2		; 200 milliseconds between..
	JMP	TIMER		;..each dialed digit.
	 ENDIF			;pmmi or mm100

; ring once -- hang up -- redial

	 IF	PMMI OR MM100 OR US100
RINGBK	POP	PSW	  	;balance stack
	CALL	ILPRT
	DB	ESC,ETEOP,0	;clear console line
	LDA	CMDBUF+1  	;get # of char in buffer
	STA	RBFLAG		;store # including the 'r'
	DCR	A 	  	;subtract 1 to avoid 'r' char
	STA	CMDBUF+1  	;store new value for next ring
	 ENDIF			;pmmi or mm100 or us100

	 IF	US100
	MVI	A,CR		;enter dial-number command
	CALL	SM$TYPE
	MVI	B,80		;wait for..
	CALL	TIMER		;..one ring.
	MVI	A,CR		;abort..
	CALL	SM$TYPE		;..dial routine, then..
	MVI	B,25		;..wait more..
	CALL	TIMER		;..before..
	JMP	DIALLPX		;..redialing.
	 ENDIF			;us100

	 IF	PMMI
	MVI	D,DTMSK	  	;load tone detect mask
	MVI	C,RBLMT	  	;set timer for rblmt # of seconds
	CALL	WAIT
	JC	RBTIME	  	;jump if no tone detected
	MVI	B,25	  	;wait 2.5 sec
	CALL	TIMER
	CALL	INBAUD		;get dial tone status
	ANA	D		;active low
	JNZ	RNGBK1
	JMP	DILAGN	  	;yes, must be busy now.
	 ENDIF			;pmmi

	 IF	MM100
	MVI	B,25		;wait 2.5 seconds to get dial tone
	CALL	TIMER
	JMP	DILAGN		;dial number again
	 ENDIF			;mm100

; hangup -- re-dial -- listen for dial tone

	 IF	PMMI OR MM100
RBTIME	CALL	CRONLY		;just a cursor return
RNGBK1	CALL	HANGUP	 	;hang up the phone
	MVI	B,RBWAIT 	;wait x sec before re-dialing
	CALL	TIMER
	CALL	WTTONE	 	;go off-hook, listen for dialtone.
	JNC	DIALLPX	 	;dial number and wait till..
	JMP	MENU	 	;..time-out or connection.
	 ENDIF			;pmmi or mm100

; modem go on-hook

	 IF	PMMI
HANGUP	MVI	A,CLEAR		;idle
	CALL	OUTCTR2
	XRA	A
	CALL	OUTCTRL		;clear dtr/etc.
	RET
	 ENDIF			;pmmi

	 IF	MM100
HANGUP	XRA	A		;turn off carrier, go on-hook.
	CALL	OUTCTR2
	RET
	 ENDIF			;mm100

; smartmodem/u.s. robotics special routines

; get sm/usr response to dialing (connect, no carrier, or error) -- abort
; call with ^x from keyboard

	 IF	US100
SM$ANS	CALL	INSTAT
	JZ	SM$ANS2		;loop if no character ready, but 1st..
	CALL	STAT		;..see if abort requested.
	JZ	SM$ANS
	CALL	KEYIN
	CPI	CAN		;cancel?  (^x)
	JNZ	SM$ANS		;branch if not, to loop beginning.
	MVI	A,CR		;exit from..
	CALL	SM$TYPE		;..dialing..
	JMP	BORT$IT		;..disconnect, then to cmd line.

SM$ANS2	CALL	INCHAR
	ANI	7FH
	CPI	'1'		;connected?
;	JZ	PRETERM		; *** test line ***
	jz	conmade		;get options from operator (cmd line)
	CPI	'4'		;error occurred?
	JZ	SM$ANS4		;if no, abort.
	CPI	'3'		;no carrier?
	JNZ	SM$ANS
SM$ANS3	CALL	IN$SM		;strip remaining characters and..
	JNC	SM$ANS3
	JMP	DILAGN		;..redial.

SM$ANS4	CALL	NO$DT		;show trouble and..
	JMP	BORT$IT		;..return to command line.

PRETERM CALL	ILPRT
	DB	CR,LF,LF,'In Terminal Mode',CR,LF,LF,BELL,0
	JMP	TERM

; get character from line (return with carry set at time-out)

IN$SM	LXI	B,312*MHZ	;set for 300 millisec time-out loop
IN$SMLP	CALL	INSTAT
	JZ	INCHAR		;get character (rets to caller)
	DCX	B
        MOV	A,B
	ORA	C
	JNZ	IN$SMLP		;loop till count-down to zero
	STC			;if time-out, return with..
	RET			;..carry set.

; string out to sm/usr modem

SM$STR	MOV	A,M
	CPI	'@'
	RZ			;return to caller at string terminator
	CALL	SM$TYPE		;send to modem
	INX	H
	JMP	SM$STR		;loop until done

; character out to sm/usr modem

SM$TYPE	PUSH	PSW		;save character and..
SM$LP	CALL	OUTSTAT		;see if ready for next character
	JNZ	SM$LP		;loop 'till ready
	POP	PSW		;..restore
	CALL	OUTCHAR		;send to modem but..
	MVI	B,1 		;..send..
	JMP	TIMER		;..slowly (for drama at the console).

; sm/usr disconnect

DISCONN	XRA	A		;store a disconnected..
	STA	LINEFLG		;..condition.
	CALL	ILPRT
	DB	CR,ESC,ETEOP	;clear line and to-end-of-page
	DB	'Stand by... ',0	;fall-thru to go on-hook command

; send on-hook escape command with delay fore and wait for response aft

ON$PLUS	MVI	B,12
	CALL	TIMER
	LXI	H,PLUS		;send escape string..
	CALL	SM$STR		;..to modem.
	MVI	B,12
	JMP	TIMER

; esc$2	call	instat		;wait for response
; 	jnz	esc$2
;    	call	inchar
;  	ani	7fh
;	cpi	'3'		;disconnected?
;	jz	esc$3
;	cpi	'N'		;disconnected?
;	jnz	esc$2
;esc$3	call	in$sm		;bucket 'cr' and anything else on-line
;	jnc	esc$3
;	ret

; alternate dialing using 'mci', 'sprint', etc.  only used with touch-tone
; dialing and smart modems.

ALT$DL	LDA	TOUCH$T		;return if..
	ORA	A		;..alternate 'mci/sprint' type
	RZ			;..dialing not indicated.
	MOV	A,B		;get byte from 'dial'
	CPI	'<'
	JNZ	ALT$DL2
	PUSH	H
	LXI	H,ALT$DIAL1
	JMP	ALT$DL3

ALT$DL2	CPI	'>'
	RNZ
	PUSH	H
	LXI	H,ALT$DIAL2
ALT$DL3	MOV	A,M
	CPI	'@'
	JZ	ALT$DL4
	MOV	B,A
	CALL	SM$TYPE
	INX	H
	CALL	STAT
	JZ	ALT$DL3
	CALL	KEYIN
	CPI	CAN
	JZ	DISCONN
	JMP	ALT$DL3

ALT$DL4	MVI	A,' '		;space between alternate and station
	CALL	TYPE
	POP	H
	RET
	 ENDIF			;us100

; time-out routine.  called with mask in d-reg for input at
; relative port 2 and # of seconds * 5 in c-reg.  checks kbd
; for abort.

	 IF	PMMI OR MM100
WAIT	MVI	B,2		;makes interval..
	CALL	TIMER	  	;..200 milliseconds.
	 ENDIF			;pmmi or mm100

	 IF	PMMI
	CALL	INBAUD	 	;modem status port
	ANA	D		;mask status bit
	RZ			;return active 'lo'
	 ENDIF			;pmmi

	 IF	MM100
	CALL	INCTRL		;modem status port
	ANA	D
	RNZ			;return active 'hi'
	 ENDIF			;mm100

	 IF	PMMI OR MM100
	PUSH	D		;save mask
	CALL	STAT	  	;keypress?
	CNZ	KEYIN	  	;yes, get character.
	CPI	CAN		; ^x?
	JZ	BORTIT0		;yes, disconnect, jmp to menu.
	POP	D		;get mask back
	DCR	C		;count-down (100 = 20 sec)
	JNZ	WAIT
	CALL	DISCONN	  	;go on-hook
	STC			;set carry to indicate either dial tone..
	RET			;..not detected or 'cts' not received.
	 ENDIF			;pmmi or mm100

; disconnect and start anew

	 IF	PMMI OR MM100 OR US100
BORTIT0 CALL	CRLF		;a 'crlf' followed by..
BORT$IT	CALL	DISCONN 	;..disconnect, reset option..
	JMP	MENU		;..table, and show prompt.
	 ENDIF			;pmmi or mm100 or us100

; disconnect then wait for dial tone

	 IF	PMMI OR MM100
WTTONE	CALL	DISCONN		;go on-hook
	CALL	CRONLY
	CALL	CTEOP
	CALL	TO$DIM
	CALL	ILPRT
	DB	'           Waiting for dial tone  ',CR,0
	CALL	TO$FULL
	 ENDIF			;pmmi or mm100

	 IF	PMMI
	MVI	A,MAKEM		;make 'make' (off-hook)
	CALL	OUTCTRL
	MVI	D,DTMSK		;dial tone mask
	MVI	C,25		; 25 = 5 second wait, wait for dial tone
	CALL	WAIT		;delay -- 'wait' returns with no carry if tone
	RNC			;if dial tone within 5 seconds..
	 ENDIF			;pmmi

	 IF	PMMI OR US100
NO$DT	CALL	ILPRT		;..else show msg and return to menu.
	DB	CR,LF,LF
	DB	'++ NO DIAL TONE -- line/hardware problem ++'
	DB	CR,LF,LF,BELL,0
	STC			;set carry true
	RET
	 ENDIF			;pmmi or us100

	 IF	MM100
	MVI	A,OFFHOOK	;bring modem off-hook
	CALL	OUTCTR2
	MVI	B,10		;wait some more
	CALL	TIMER
	XRA	A		;clear carry
	RET
	 ENDIF			;mm100

; modem disconnect routine

	 IF	PMMI OR MM100
DISCONN XRA	A		;store a disconnected..
	STA	LINEFLG		;..condition here.
	CALL	OUTCTR2		;clear dtr, esd, etc., and..
	 ENDIF			;pmmi or mm100

	 IF	PMMI
	CALL	OUTCTRL
	 ENDIF			 ;pmmi
                                 
	 IF	PMMI OR MM100    
	CALL	OUTCTRL		;..hang-up (go on-hook).
	MVI	B,8		;wait for modem to disconnect
	JMP	TIMER		;ret to caller
	 ENDIF			;pmmi or mm100

; telephone-connection-made announcement

	 IF	PMMI OR MM100 OR US100
CONMADE	CALL	TO$FULL
	CALL	CTEOP
	CALL	ILPRT
	DB	CR,LF
	DB	'Connection established -- '
	 ENDIF			;pmmi or mm100 or us100

	 IF	PMMI OR MM100
	DB	'select options (e.g., TO.300 fn.ft): ',0
	 ENDIF			;pmmi or mm100

	 IF	US100
	DB	'select E or T [fn.ft]: ',0
	 ENDIF			;us100

	 IF	PMMI OR MM100 OR US100
	MVI	A,TRUE		;indicate line..
	STA	LINEFLG		;..is connected.
CMLP	CALL	STAT		;check for keypress
	JNZ	GETCMD		;key pressed, go get options.
	MVI	A,BELL		;ring bell until..
	CALL	TYPE		;..a key pressed.
	MVI	B,1		;delay for console..
	CALL	TIMER		;..to process bell.
	JMP	CMLP		;loop 'til keypress
	 ENDIF			;pmmi or mm100 or us100

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
MENU2	CALL	CAPTION		;show program title (header)
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'                                    -- M E N U --',CR,LF,LF
	DB	'                        C o m m a n d   M o d e',CR,LF,0
	CALL	TO$FULL
	CALL	ILPRTQ
	DB	'------- File Operations --------     ---------- Modem Contro'
	DB	'l ---------',CR,LF,0
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'DIR - Directory [d: *.ft]             CAL - Dial telephone n'
	DB	'umber    ',CR,LF
	DB	'WRT - Write save-file buffer          SEL - Select transmiss'
	DB	'ion format    ',CR,LF
	DB	'DEL - Delete save-file buffer         DSC - Disconnect telep'
	DB	'hone line    ',CR,LF

	 IF	UTL
	DB	'UTL - Utility file manipulation       '
	 ENDIF			;utl

	 IF	VUE
	DB	'VUE - View text file                  '
	 ENDIF			;vue

	 IF	US100
	DB	'SET - Set baudrate (off-line)'
	 ENDIF			;us100

	DB	CR,LF
	DB	'SAP - Sort and Pack Directory        ',CR,LF
	DB	'ERA - Erase files (ERA fn.ft)',0
	CALL	TO$FULL
	CALL	ILPRTQ
	DB	'        --------- Miscellaneous ---------',CR,LF,0
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'                                      M - Menu     CPM - Exi'
	DB	't to CP/M',CR,LF,0
	CALL	TO$FULL
	CALL	ILPRTQ
	DB	' ------- Primary Options -------',CR,LF,0
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'  T - Terminal Mode (T fn.ft)        ',0
	CALL	TO$FULL
	CALL	ILPRTQ
	DB	'------- Secondary Options -------',CR,LF,0
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'  E - Echo Mode (host computer)       B - Batch Transfer    '
	DB	'Q - Quiet',CR,LF
	DB	'  S - Send CP/M file (ST fn.ft)       D - Disconnect        '
	DB	'V - View',CR,LF
	DB	'  R - Receive file (RT fn.ft)         E - Exit to CP/M when '
	DB	'completed',CR,LF,LF,0
	CALL	TO$FULL
	CALL	ILPRTQ
	DB	'--- T e r m i n a l   M o d e ------------------------------'
	DB	'------------------',CR,LF,0
	CALL	TO$DIM
	CALL	ILPRTQ
	DB	'R - Review stored strings   S - Save-file (fn.ft) toggle   '
	DB	'T - Transfer file',CR,LF
	DB	'E - Exit to Command Mode  ',0
	LDA	CMDCHR		;get command character and.. 
 	CALL	SHOWCTL		;..print it.                        
 	CALL	ILPRTQ                                              
	DB	' - Send lead-in character     '            
	DB	'D - Disconnect line',CR,LF                                  
	DB	'n - Send string (0 to 9)   '

	 IF	PMMI OR MM100
	DB	'B - Baudrate change on-the-fly  '
	 ENDIF			;pmmi or mm100

	DB	' P - Printer toggle',CR,LF
	DB	'                (terminal mode command lead-in character =',0
	LDA	CMDCHR		;get command character and..
	CALL	SHOWCTL		;..print it.
	CALL	ILPRTQ
	DB	')',CR,LF,LF,0
	CALL	TO$FULL
	JMP	C$LINE		;go show command line

	LINK	COMM725A	;chains to 'comm725a.asm' using lasm.com


