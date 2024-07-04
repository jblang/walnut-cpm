
; (comm725c.asm)

; command line called by main menu in 'header' file

C$LINE	MVI	A,TRUE		;automatic transfer to xprt mode
	STA	XPRFLG
XPRT	CALL	CRONLY 		; <cr> then..
	CALL	CTEOP		;..erase-to-end-of page.
	CALL	TO$DIM

	 IF	RTC AND (CW OR SS1) AND (NOT TIME$ONLY)
	CALL	TIMEDAY
	 ENDIF			;rtc and (cw or ss1) and (not time$only)

	 IF	RTC AND (CW OR SS1) AND TIME$ONLY
	CALL	TIME
	 ENDIF			;rtc and (cw or ss1) and time$only

	CALL	ILPRTQ
	DB	'>>>',0
	MVI	C,INQDISK	;get default drive
	CALL	BDOS		;store as prevailing..
	STA	CMD$DR		;..command line drive.
	ADI	'A'		;make ascii and..
	CALL	TYPE		;..show on crt.
	MVI	E,GET		;set to get..
	MVI	C,SGUSER	;..current user area..
	CALL	BDOS		;..and..
	STA	C$U$A		;..store.
	ORA	A		;if user area 0 then..
	JZ	XPRT2		;..don't process.
	CPI	10		;user <10?
	JC	XPRT1		;no, then print now.
	SUI	10		;if not, subtract 10 from it..
	PUSH	PSW		;..and save.
	MVI	A,'1'		;output 10's digit..
	CALL	TYPE		;..locally.
	POP	PSW		;get 1's digit back and..
XPRT1	ADI	'0'		;..convert to ascii then..
	CALL	TYPE		;..finally show it.
XPRT2	CALL	ILPRTQ
	DB	': ',0		;default drive prompt
	CALL	TO$FULL
GETCMD	LXI	D,CMDBUF 	;point to storage for..
	CALL	INBUF		;..command entry.
	LDA	CMDBUF+3	;see if drive/user select
	CPI	':'		;yes, then..
	JZ	SETDRV		;..change, else..
	LXI	D,CMDBUF+2 	;..point to other command.

	 IF	US100
	CALL	ILCOMP
	DB	'SET',0
	JNC	US$SET
	 ENDIF			;us100

	CALL	ILCOMP
	DB	'SAP',0
	JNC	S$A$P		;sort and pack directory of selected drive
	CALL	ILCOMP
	DB	'SEL',0
	JNC	SETDPS		;select transmission characteristics
	CALL	ILCOMP
	DB	'CPM',0
	JNC	PREEXIT		;leave modem, test line connection first
	CALL	ILCOMP
	DB	'DIR',0
	JNC	DIR		;display directory and reset disk system
	CALL	ILCOMP
	DB	'WRT',0
	JNC	WRTFILE		;write-to-ram or..
	CALL	ILCOMP
	DB	'DEL',0
	JNC	DELNEWF		;..delete newly saved file.
	CALL	ILCOMP
	DB	'ERA',0
	JNC	ERASEF		;erase or..

	 IF	UTL
	CALL	ILCOMP
	DB	'UTL',0
	JNC	DISK7
	 ENDIF			; 'utl'

	 IF	VUE
	CALL	ILCOMP
	DB	'VUE',0
	JNC	VIEWFIL		;..type-to-console declared file(s).
	 ENDIF			; 'vue'

	 IF	PMMI OR MM100 OR US100
	CALL	ILCOMP		;de-pair set from 1st ilcomp call
	DB	'DSC',0
	JNC	DISCON1
	CALL	ILCOMP
	DB	'CAL',0
	JC	NEXTOPT
	CALL	ILPRT
	DB	CR,ESC,ETEOP,0
	MVI	A,' '		;blank-out 'l' of 'cal' and..
	STA	CMDBUF+4	;..fool cmdbuf to..
	JMP	DOOPT		;..look at option for dial.
	 ENDIF			;pmmi or mm100 or us100

NEXTOPT	LDA	CMDBUF+1
	ORA	A		;ignore if null from.. 
	JZ	MENU		;..only <return> entered.
	LDA	CMDBUF+2
	LXI	H,COMPLIST	;compares list pointed to by hl-pair to char..
	CALL	COMPARE		;..in a-reg.  (validate primary option)
	JC	BADCMD		;carry set --> no match, show bad command.
DOOPT	CALL	SETFCB		;setup cp/m-convention cmd line at fcb
	CALL	PROCOPT		;process options.  then..
	JMP	RESTART		;..go to beginning-of-program routine.

; 'setdrv' selects requested drive/user area with full entry error trapping

SETDRV 	LDA	CMDBUF+2
	CPI	'A'		;don't allow less than 'a'..
	JC	BADCMD
	CPI	(MAXDR)+1	;..or more than 'maxdr'.
	JNC	BADCMD
	SUI	'A'		;convert a: to 0
	MOV	E,A
	MVI	C,LOGIN		;login new drive
	CALL	BDOS
	LDA	CMDBUF+5
	CPI	'0'		;no valid user area request..
	JC	MENU		;..then back to cmd line.
	CPI	'9'+1
	JNC	BADCMD		;error, not a user area.
	SUI	30H		;convert to binary and..
	CPI	1		;..test if 10's digit.
	JNZ	SETUSER		;no, then set user area now.
	LDA	CMDBUF+6	;anything else there?
	CPI	'0'		;test for 1's digit
	JC	SETUONE
	CPI	'5'+1		;if user area >15..
	JNC	BADCMD		;..go cmd line.
	SUI	30H-10		;make 1 --> 11, 2 --> 12, etc.
	JMP	SETEXIT

SETUONE	MVI	A,1		;set to user area one
SETUSER	MOV	B,A
	LDA	CMDBUF+6
	CPI	'0'		;if >19 user area, go menu.
	JNC	BADCMD
	MOV	A,B
SETEXIT	STA	C$U$A		;store as user area and..
	CALL	SET$USR		;..establish as current.
	JMP	MENU

; d e l

; delete file ram-saved in terminal mode

DELNEWF	CALL	OKFILE		;file open?
	LXI	D,FCB3
	MVI	C,ERASE		;erase file ram-saved..
	CALL	BDOSRET		;..in terminal mode.
	JMP	LEAVE

; w r t

; write-to-disk file saved in terminal mode

WRTFILE	CALL	OKFILE		;file open?
	CALL	RAMDISK		;get # of records indicated by hl-pair..
	CALL	CLOSE3		;..then write-to-disk and close file.

; default setting of file-save flag registers

LEAVE	MVI	A,TRUE
	STA	NFILFLG		;true indicates no-file being saved..
	CMA
	STA	ALERTFG		;..but false is required here..
	STA	SAVEFLG		;..and here for no-save.
	LXI	H,FCB3
	CALL	INITFCB		; (now written-file can't be 'del'ed)
	CALL	ILPRT
	DB	CR,ESC,ETEOP,'---> Operation completed ',0
	JMP	MSGREAD

; file-open check and no-file-presently-open announcement

OKFILE	LDA	NFILFLG		;make doubly sure..
	ORA	A
	JNZ	NOFILE
	LDA	FCB3+1		;..a file is open.
	CPI	' '
	RNZ
NOFILE	CALL	ILPRT
	DB	CR,ESC,ETEOP,'++ No file presently open ++ ',0
	JMP	MSGREAD

; e r a

; erase cp/m file(s) -- wildcard (*.ft) filenames permitted

ERASEF	CALL	VERIFY		;does file exist?
	JNZ	ERAFILE 	;this is why we're here, do it.
REDO	CALL	ILPRT
	DB	CR,ESC,ETEOP,'++ Unable to locate file -- check '
	DB	'spelling ++ ',0
	JMP	MSGREAD		;get delay to read message, go menu.
 
ERAFILE CALL	NOASK		;erase routine for filename at 'fcb'
	CALL	ILPRT
	DB	CR,ESC,ETEOP,'---> File(s) erased ',0
MSGREAD	MVI	B,20		; 2-second time..
	CALL	TIMER		;..to read console message.
	JMP	MENU

; v u e
; type file to console with pagination set to 'lps' -- single-line scroll
; using <space> bar , <ctrl-x> to cancel, any other key to page screen.

	 IF	VUE
VIEWFIL	CALL	VERIFY
	JZ	REDO
	CALL	TO$DIM
	CALL	ILPRT
	DB	'<CTRL-X> cancels, <space> turns up one line, '
	DB	'other keys page screen.',CR,LF,LF,0
	CALL	TO$FULL
	MVI	A,1		;initialize..
	STA	LPSCNT		;..lines-per-screen counter.
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
	LXI	D,TBUF
	MVI	C,SETDMA
	CALL	BDOS
READF	LXI	D,FCB
	MVI	C,READ		;read 128 bytes
	CALL	BDOS	
	ORA	A		;good read?
	JNZ	MENU		;to cmd line if 'eof' or bad read
	MVI	B,80H		;ready to read..
	LXI	H,TBUF		;..128-byte record from 'tbuf'.
READLP	MOV	A,M		;get character from memory
	CPI	EOFCHAR		;don't send to console
EXITVUE	CZ	CRLF		;exit with fresh line
	JZ	MENU
	CALL	TYPEQ		;display on console
	CPI	LF		;at end of line?
	CZ	PAGER		;yes, test if at # of lines limit.
	INX	H
	DCR	B
	JNZ	READLP		;loop for 128 bytes or 'eofchar'
	JMP	READF		;get more

PAGER	LDA	LPSCNT		;is counter..
	INR	A		;..at..
	STA	LPSCNT		;..limit..
	CPI	LPS		;..of lines-per-screen?
	RC			;no, return.
	XRA	A		;yes, initialize..
	STA	LPSCNT		;..for next screen full.
	CALL	TO$DIM
	CALL	ILPRT
	DB	'  [more...]',CR,0	;show msg line
	CALL	TO$FULL
	CALL	KEYIN		;wait for keyboard input
	CPI	CAN		;cancel?
	PUSH	PSW
	CALL	CTEOP		;clear msg line
	POP	PSW
	JZ	EXITVUE		;yes, else..
	CPI	' '		;..see if <space> bar.
	RNZ			;if not, return for another page.
	MVI	A,LPS-1		;if so, set up for single-line..
	STA	LPSCNT		;..scroll and..
	RET			;..return for one more line.
	 ENDIF			; 'vue'

; 'cmdbuf' set up for file procesing -- return with zero flag set if file
; not found.  jump to 'redo' if filename not entered.

VERIFY	CALL	SETFCB		;setup cp/m-convention cmd line at fcb
	CALL	MOVEFCB		;move fcb+16 to fcb
	LDA	FCB+1
	CPI	' '
	JZ	REDO		;redo, if desired.
	LXI	D,FCB
	MVI	C,SRCHF
	CALL	BDOS
	INR	A		; 0ffh --> 0 means file not found
	RET			; ret with not-zero if found

; d s c

; disconnect telephone line with announcement -- check to protect
; for open save-file

	 IF	PMMI OR MM100 OR US100
DISCON1	CALL	DISCONN		;if pmmi, disconnect..
	CALL	ILPRT		;..and display message.
	DB	CR,ESC,ETEOP,'---> Disconnected ',0
	MVI	B,10
	CALL	TIMER		;get time to read message
	 ENDIF			;pmmi or mm100 or us100

ALERT	XRA	A		;turn off direct i/o
	STA	DTYPE
	LDA	LISTFLG		;is printer on?
	ORA	A	
	JNZ	LETFGBE		;no, let printer flags be.
	MVI	A,TRUE		;turn printer off and..
	STA	LISTFLG		;..set flag to turn back on..
	STA	LSTRETF		;..if re-entering terminal mode.
LETFGBE	LDA	ALERTFG		;check if save-file is active (i.e., if..
	ORA	A		;..'<cmd> s' has been used at least once).
	JZ	MENU		;reset options here or..
FILOPEN	CALL	ILPRT		;announce file still open
	DB	CR,LF,'++ A file is open -- use T-WRT-DEL-DIR-M '
	DB	'before other commands ++',BELL,CR,LF,0
	JMP	MENU		;..here.

; bad entry message

BADCMD	CALL	ILPRTQ
	DB	CR,ESC,ETEOP,'++ Invalid command ++ ',BELL,0
	JMP	MSGREAD

; list compare

COMPARE	MOV	B,M		;compares a-reg with list..
COMPLP	INX	H		;..addressed by hl-pair.  first character..
	CMP	M		;..of list must be number of elements..
	RZ			;..being compared.  returns with..
	DCR	B		;..carry set if a-reg does not..
	JNZ	COMPLP		;..match a character in list.
	STC
	RET

COMPLIST DB 5, 'S', 'R', 'T', 'E', 'M'	;address in hl-pair

; s e l

; set data, parity, and stop (dps) bits.  select full or half-duplex and
; filtering of control codes from received data in terminal mode.

SETDPS	CALL	CLEAR$S		 	 ;clear screen
	CALL	TO$DIM
	CALL	ILPRT
	DB	LF,LF,LF,LF,LF,LF 	;lf down
	DB	'   Transmission Characteristics -- <RETURN> for default '
	DB	'settings',CR,LF,LF,0
	CALL	TO$FULL

	 IF	PMMI OR MM100 OR US100
DATABIT	CALL	ILPRT
	DB	CR,'    How many data bits (5,6,7,8)? ',0
	CALL	KEYIN
	CPI	CR			;default requested so retain current..
	JNZ	DATAB			;..then show menu & cmd-line prompt.
	MVI	A,'8'
DATAB	CPI	'5'
	MVI	B,M5$DATA		; 5-data-bits mask
	JZ	EQUAL
	CPI	'6'
	MVI	B,M6DATA
	JZ	EQUAL
	CPI	'7'
	MVI	B,M7DATA
	JZ	EQUAL
	MVI	B,M8DATA
	CPI	'8'
	JNZ	DATABIT
EQUAL	CALL	TYPE			;print character
	MOV	A,B			;put request into a-reg
	STA	BITTEMP			;store parity request
	CALL	LFONLY
PARLP	CALL	ILPRT
	DB	CR,'  Parity (O>dd, E>ven, or N>one)? ',0
	CALL	KEYIN
	CALL	UCASE
	CPI	CR
	JNZ	PARLP1
	MVI	A,'N'
PARLP1	CPI	'O'
	MVI	B,MOPAR			;odd parity..
	JZ	STOPBIT
	CPI	'E'
	MVI	B,MEPAR			;..even..
	JZ	STOPBIT
	CPI	'N'
	MVI	B,MNPAR			;..or none.
	JNZ	PARLP
STOPBIT	CALL	TYPE			;print character
	LDA	BITTEMP
	ORA	B			;add parity to data bits
	STA	BITTEMP
	CALL	LFONLY
TSBLP	CALL	ILPRT
	DB	CR,'              Stop bits (1 or 2)? ',0
	CALL	KEYIN
	CPI	CR
	JNZ	TSBLP1
	MVI	A,'1'
TSBLP1	CPI	'1'
	MVI	B,M1STOP		; 1 stop bit
	JZ	SETBITS
	CPI	'2'
	MVI	B,M2STOP		; 2 stop bits
	JNZ	TSBLP
SETBITS	CALL	TYPE			; print character
	LDA	BITTEMP
	ORA	B			;add stop to data and parity bits
	 ENDIF				;pmmi or mm100 or us100

	 IF	PMMI
	STA	ORIGMOD			;store full format here, then..
	INR	A			;..convert to answer mode and..
	STA	ANSWMOD			;..store again.
	 ENDIF				;pmmi

	 IF	US100
	MOV	B,A			;save bits 2 thru 7
	LDA	UARTCTLB		;get mode byte
	ANI	3			;save baudrate bits 0 and 1
	ORA	B			;combine word structure with baudrate
	STA	INITB+1			;put all bits in mode byte
	LDA	MODCTLB			;ready to change on-the-fly by..
	ANI	1111$1101B		;..setting 'dtr' low for 'logical'..
	CALL	OUTCTRL			;..on-hook state.
	CALL	INITA			;reset uart and reinit modem
	 ENDIF				;us100

	 IF	MM100
	STA	UARTCTLB
	CALL	OUTCTRL
	 ENDIF				;mm100

	CALL	LFONLY
F$H$LP	CALL	ILPRT
	DB	CR,'           F>ull or H>alf-duplex? ',0
	CALL	KEYIN
	CALL	UCASE
	CPI	CR
	JNZ	F$H$LP1
	MVI	A,'F'
F$H$LP1	CPI	'F'
	JZ	FUL$DUP
	CPI	'H'
	JNZ	F$H$LP			;neither, so query again.
	CALL	TYPE			;print character
	ORI	TRUE
	STA	HALFDUP
	JMP	FILCTRL

FUL$DUP	CALL	TYPE			;print character
	XRA	A			; 'full' is default
	STA	HALFDUP
FILCTRL	CALL	LFONLY
FIL$LP	CALL	ILPRT
	DB	CR,'Filter out control codes?  (Y/N): ',0
	CALL	KEYIN
	CALL	UCASE
	CPI	CR
	JNZ	FIL$LQ
	MVI	A,'N'
FIL$LQ	CPI	'N'
	JZ	FIL$NO
	CPI	'Y'
	JNZ	FIL$LP			;query again
	CALL	TYPE			;print character
	ORI	TRUE
	STA	FILBYTE
	JMP	DIRCTIO

FIL$NO	CALL	TYPE			;print character
	XRA	A			;no filtering is default
	STA	FILBYTE
DIRCTIO	CALL	LFONLY			;go to next line
DCTLP	CALL	ILPRT
	DB	CR,' Use direct I/O in Terminal Mode? ',0
	CALL	KEYIN
	CALL	UCASE
	CPI	CR			;default = no
	JNZ	DCT$IO
	MVI	A,'N'
DCT$IO	CPI	'N'			;no
	JZ	DCT$NO
	CPI	'Y'			;no
	JNZ	DCTLP
	CALL	TYPE			;print character
	ORI	TRUE
	STA	DIRECTB			;set byte
	JMP	SETEND

DCT$NO	CALL	TYPE			;print character
	XRA	A
	STA	DIRECTB			;set byte
SETEND	CALL	ILPRT
	DB	CR,LF,'                All okay?  (Y/N): ',0
	CALL	RESPOND
	CPI	'N'			;any other key starts the..
	JZ	SETDPS			;..routine over.
	JMP	MENU2			;go menu

; routine to show day and time at the command prompt line

	 IF	RTC AND CW
CLKCTL	EQU	CLKBASE+1	;clock control port
CLKDATA	EQU	CLKBASE+2	;clock data port
TIMEDAY	MVI	A,10H		;prevent reg roll-over during read
	OUT	CLKCTL
	 ENDIF			;rtc and cw

	 IF	RTC AND SS1
CLKCTL	EQU	CLKBASE+10
CLKDATA	EQU	CLKBASE+11
TIMEDAY	EQU	$
	 ENDIF			;rtc and ss1

	 IF	RTC AND (CW OR SS1)
	MVI	A,6		;day of week
	CALL	CLKREAD
	RLC			; *2 for tbl offset
	LXI	H,DTBL		;point to day table
	CALL	TBLO		;table out
	CALL	CS		;output ", "
	MVI	A,9		;get month units digit
	CALL	CLKREAD
	MOV	B,A		;save in b
	MVI	A,10		;get month tens digit
	CALL	CLKREAD
	MOV	A,B		;get the units back (don't set flags)
	JZ	SKIP		;was 1-9 (january-september)
	ADI	10		;plus 10 if (october-december)
SKIP	DCR	A		;make 0-11
	RLC			; *2 for tbl offset
	LXI	H,MTBL		;point to month table
	CALL	TBLO		;table out
	MVI	A,' '		;print a space
	CALL	TYPE		;output byte
	MVI	A,8		;get day tens digit
	CALL	CLKREAD
	ANI	3		;strip leap year bit
	MOV	B,A		;save day tens for 11, 12, or 13 check
	CNZ	ODGT		;output the digit, if it is non-zero.
	MVI	A,7		;get day units digit
	CALL	CLKREAD
	MOV	C,A
	CALL	ODGT		;output the digit
	MOV	A,B		;put day tens in reg-a
	CPI	1		;if one for day tens..
	JZ	THER		;..don't test for day units else..
	MOV	A,C		;..get day units back and..
	CPI	1		;..check if 1, 2, or 3 day units.
	JZ	STER
	CPI	2
	JZ	NDER
	CPI	3
	JZ	RDER
THER	CALL	ILPRT
	DB	'th',0
	JMP	PAST

STER	CALL	ILPRT
	DB	'st',0
	JMP	PAST

NDER	CALL	ILPRT
	DB	'nd',0
	JMP	PAST

RDER	CALL	ILPRT
	DB	'rd',0
PAST	CALL	CS		;output ", "
	CALL	ILPRT
	DB	'19',0		;comtemporary century (19th)
	MVI	A,12		;year tens
	CALL	RDOD		;read and output digit
	MVI	A,11		;year units
	CALL	RDOD		;read and output digit
	CALL	CS		;output ", "

; call here for time display without day and date

TIME	EQU	$
	 ENDIF			;rtc and (cw or ss1)

	 IF	RTC AND CW AND TIME$ONLY
	MVI	A,10
	OUT	CLKCTL
	 ENDIF			;rtc and cw

	 IF	RTC AND (CW OR SS1)
	MVI	A,5		;hour tens
	CALL	CLKREAD
	PUSH	PSW		;save 12/24. am/pm bits and..
	ANI	3		;..now strip them.
	CALL	ODGT
	MVI	A,4		;hour units
	CALL	RDOD		;read and output digit
	MVI	A,':'		;separator
	CALL	TYPE
	MVI	A,3		;minute tens
	CALL	RDOD		;read and output digit
	MVI	A,2		;minute units
	CALL	RDOD		;read and output digit
	MVI	A,':'		;another separator
	CALL	TYPE
	MVI	A,1		;seconds tens
	CALL	RDOD		;read and output digit
	MVI	A,0		;seconds units
	CALL	RDOD		;read and output digit		
	POP	PSW		;restore to test 12/24, am/pm bits
	MOV	B,A		;save tmp
	ANI	8		; 24 hour mode?
	JNZ	T4HR		;yes, print trailing spaces at exit ret.
	MOV	A,B		;restore
	ANI	4		;am or pm?
	JZ	AM		;if am, branch.
	CALL	ILPRT		;pm
	DB	' pm  ',0	;do afternoon or..
	JMP	FOO

T4HR	CALL	ILPRT		; 2 spaces after 24-hr mode display
	DB	'  ',0
	JMP	FOO

AM	CALL	ILPRT
	DB	' am  ',0	;..morning display.
	 ENDIF			;rtc and (cw or ss1)

	 IF RTC AND CW
FOO	XRA	A		;let register..
	OUT	CLKCTL		;..go free.
	RET

CLKREAD	ORI	20H		;add register offset
	OUT	CLKDATA		;this digit is wanted so..
	PUSH	PSW		;..a short..
	POP	PSW		;..delay then..
	IN	CLKDATA		;..go read it.
	ORA	A		;set flags
	RET
	 ENDIF			;rtc and cw

	 IF RTC AND SS1
FOO	RET

CLKREAD	ORI	10H+40H		;register offset and hold
	OUT	CLKCTL
	IN	CLKDATA
	PUSH	PSW		;save data
	XRA	A		;let register..
	OUT	CLKCTL		;..go free.
	POP	PSW		;data back to a-reg
	ORA	A		;set flags
	RET
	 ENDIF			;rtc and ss1

; calendar subroutines

	 IF	RTC AND (CW OR SS1)
RDOD	CALL	CLKREAD		;read and output digit
ODGT	ORI	30H		;convert to ascii
	MOV	E,A
	JMP	TYPE

TBLO	MOV	E,A		;shift factor..
	MVI	D,0		;..into de-pair.
	DAD	D		;add offset to hl-pair
	MOV	E,M		;put address into..
	INX	H
	MOV	D,M		;..de-pair.  then..
	XCHG			;..into hl-pair and..
	JMP	TEXTOUT		;..go display it.

CS	CALL	ILPRT
	DB	', ',0		;print ", "
	RET

; dispatch tables

MTBL	DW	JAN		;month table
	DW	FEB
	DW	MAR
	DW	APR
	DW	MAY
	DW	JUN
	DW	JUL
	DW	AUG
	DW	SEP
	DW	OCT
	DW	NOV
	DW	DEC
JAN	DB	'January','@'
FEB	DB	'February','@'
MAR	DB	'March','@'
APR	DB	'April','@'
MAY	DB	'May','@'
JUN	DB	'June','@'
JUL	DB	'July','@'
AUG	DB	'August','@'
SEP	DB	'September','@'
OCT	DB	'October','@'
NOV	DB	'November','@'
DEC	DB	'December','@'

DTBL	DW	SUN		;daytable
	DW	MON
	DW	TUE
	DW	WED
	DW	THU
	DW	FRI
	DW	SAT

SUN	DB	'Sunday','@'
MON	DB	'Monday','@'
TUE	DB	'Tuesday','@'
WED	DB	'Wednesday','@'
THU	DB	'Thursday','@'
FRI	DB	'Friday','@'
SAT	DB	'Saturday','@'
	 ENDIF			;rtc and (cw or ss1)

; s a p   (sort and pack routine)

; obtain 'bios' vectors

S$A$P	LDA	ALERTFG		; 'sap' not allowed if..
	ORA	A		;..a file is being..
	JNZ	FILOPEN		;..saved in terminal mode.

; move 'bios' addresses into place

	LXI	D,S$WBOOT	;point to local storage table
	LHLD	CPM$BASE+1	;entry address for 'bios' jump table
	MVI	B,53
	CALL	MOVE
	MVI	C,GETVERS	;cp/m function 12
	CALL	BDOS
	MOV	A,H		;hl-pair --> 0020h if cp/m 2
	ORA	A		;exit if..
	JNZ	MPM$YES		;..mp/m.
	ORA	L		;else store a zero..
	STA	VERFLG		;..if cp/m 1.

; setup for selecting drive and loading disk parmeter block

	CALL	SETFCB		;get comm7 command line..
	CALL	MOVEFCB		;..drive entry, if..
	LDA	FCB		;..one entered.
	DCR	A
	JP	SELDISK		;branch if specific drive requested
	MVI	C,INQDISK	;otherwise get current default drive
	CALL	BDOS		;query 'bdos' for drive
SELDISK	MOV	C,A
	CALL	SELDSK		;direct 'bios' call for 'dph'
	LDA	VERFLG		;if cp/m 1.4, show..
	ORA	A		;..no-support..
	JZ	CPM14		;..message.

; determine cp/m 2 disk parameter block from address base in hl-pair

	MOV	E,M		;base of 'dph' for selected drive
	INX	H
	MOV	D,M
	INX	H
	XCHG
	SHLD	RECTBL
	XCHG
	LXI	D,8		;offset to 'dpb' within header..
	DAD	D		;..returned by 'seldsk' in cp/m 2.
	MOV	A,M		;get address of 'dpb'
	INX	H
	MOV	H,M
	MOV	L,A
	LXI	D,DPB		;point to destination: our 'dpb'
	MVI	B,15		; 'dpb' length
	CALL	MOVE

; 'sap' main-line

	CALL	RD$DIR		;read requested drive directory
	CALL	CLEAN
	CALL	S$SORT		; 'sap' sort
	CALL	PACK
	CALL	WR$DIR
	CALL	ILPRT
	DB	'-- done',CR,LF,LF,0
	CALL	RESET		;rewritten directory requires system reset
	JMP	MENU		;return to comm7 command line

; 'sap' subroutines

; read (or write) directory routines

RD$DIR	CALL	ILPRT
	DB	CR,LF,LF,'---> Reading, ',0
	XRA	A
	JMP	DO$DIR

WR$DIR	LDA	NOSSWAP		;rewrite unnecessary?
	ORA	A
	JZ	OK$NOW
	CALL	ILPRT
	DB	'writing ',0
	MVI	A,1
DO$DIR	STA	WR$FLAG
	LHLD	SYSTRK
	CALL	DO$TRAK		;set track
	LXI	H,0
	SHLD	SECTOR
	LHLD	DRM		;number of directory entries..
	INX	H		;..relative to 1.
	MVI	B,2+1		;divide by 4 to..
	CALL	SHIFTLP		;..get sector count.
	SHLD	DIRCNT
	LXI	H,BOTTRAM
	SHLD	ADDR		;for dma address
DIRLOP	LHLD	SECTOR		;get sectors per track
	INX	H
	XCHG
	LHLD	SPT		;current sector
	CALL	SUBDE		; 'sector' minus 'spt'
	XCHG
	JNC	NO$TROV		;branch if no track overflow
	LHLD	TRACK
	INX	H
	CALL	DO$TRAK
	LXI	H,1		;rewind sector number
NO$TROV	CALL	DO$SEC		;set current sector
	LHLD	ADDR
	MOV	B,H		;set up dma address
	MOV	C,L
	CALL	SSETDMA
	LDA	WR$FLAG		;time to figure out..
	ORA	A		;..if we are reading..
	JNZ	D$WRT		;..or writing.

; read

	CALL	SREAD
	ORA	A		;test flags on read
	JNZ	RERROR		;nz --> error, else good read.
	JMP	MORE

; directory already sap'd

OK$NOW	CALL	ILPRT
	DB	'(previously sorted) -- done',CR,LF,LF,0
	CALL	RESET
	JMP	MENU

; write

D$WRT	MVI	C,1		;for cp/m 2 deblocking bios's
	CALL	SWRITE
	ORA	A		;test flags on write
	JNZ	WERROR		;nz --> bad directory write

; good write (or read)

MORE	LHLD	ADDR		;bump dma address for next pass
	LXI	D,80H
	DAD	D
	SHLD	ADDR
	LHLD	DIRCNT		;countdown entries
	DCX	H
	SHLD	DIRCNT
	MOV	A,H		;test for zero left
	ORA	L
	JNZ	DIRLOP		;loop till zero

; directory i/o done -- reset dma address

	LXI	B,80H
	JMP	SSETDMA		;returns to caller

; track and sector update routines

DO$TRAK	SHLD	TRACK
	MOV	B,H
	MOV	C,L
	CALL	SETTRK
	RET

DO$SEC	SHLD	SECTOR
	MOV	B,H
	MOV	C,L
	LHLD	RECTBL
	XCHG
	DCX	B
	CALL	SECTRN
	MOV	B,H
	MOV	C,L
	LDA	VERFLG
	ORA	A
	RZ
	CALL	SETSEC
	RET

; clean -- reformat with e5's -- delete files of zero length (except those
; starting with fn's of '-')

CLEAN	LXI	H,0		;i = 0
CLEANLP	SHLD	I
	CALL	INDEX		;hl = bottram + 16 * i
	MOV	A,M		;jump if this is a deleted file
	CPI	0E5H
	JZ	FILL$E5
	LXI	D,12
	DAD	D		;hl = hl + 12
	MOV	A,M		;check extent field
	ORA	A
	JNZ	CLBUMP		;skip if not extent zero
	INX	H		;point to record count field
	INX	H
	MOV	A,M		;get s2 byte (extended rc)
	ANI	0FH		;for cp/m 2, 0 for cp/m 1.
	MOV	E,A
	INX	H
	MOV	A,M		;check record count field
	ORA	E
	JNZ	CLBUMP		;jump if non-zero
	LHLD	I		;clear all 32 bytes of..
	CALL	INDEX		;..directory entry to e5h.
	INX	H
	MOV	A,M		;get first char of filename
	DCX	H		;  (ward christensen's cat pgms
	CPI	'-'		;  have diskname of zero length
	JZ	CLBUMP		;  that start with '-', don't delete.)
FILL$E5	MVI	C,32		;number of bytes to clear
FILLOP	MVI	M,0E5H		;make it all e5's
	INX	H
	DCR	C
	JNZ	FILLOP
CLBUMP	LHLD	DRM		;get count of filenames
	INX	H
	XCHG
	LHLD	I		;our current count
	INX	H
	PUSH	H
	CALL	SUBDE		;subtract
	POP	H
	JC	CLEANLP		;loop till all cleaned
	RET

; fcb buffer offset

INDEX	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,BOTTRAM
	DAD	D
	RET

; sort directory

S$SORT	XRA	A
	STA	NOSSWAP		;set zero flag to indicate 'already sorted'
	CALL	ILPRT
	DB	'sorting ',0
	LXI	H,0		;i = 0
	SHLD	I
SSORT1	LHLD	I		;j = i + 1
	INX	H
	SHLD	J
SSORT2	CALL	COMP		;if name(j) < name(i), swap.
	CC	S$SWAP
	LHLD	J		;j = j + 1
	INX	H
	SHLD	J
	XCHG
	LHLD	DRM
	INX	H
	XCHG
	PUSH	H
	CALL	SUBDE		;if j < drm goto sort2
	POP	H
	JC	SSORT2
	LHLD	I		;i = i + 1
	INX	H
	SHLD	I
	XCHG
	LHLD	DRM
	XCHG
	CALL	SUBDE		;if i < drm goto sort1
	JC	SSORT1
	RET

; compare subroutine

COMP	LHLD	I		;hl = bottram + 16 * i
	CALL	INDEX
	PUSH	H
	LHLD	J		;hl = bottram + 16 * j
	CALL	INDEX
	XCHG
	POP	H
	MVI	C,13		;number of bytes to compare
COMP1	MOV	A,M		;get next byte
	ANI	7FH		;remove attributes
	MOV	B,A		;save in b
	LDAX	D
	ANI	7FH		;remove attributes
	CMP	B		;compare character
	RNZ			;return if not equal
	INX	D
	INX	H
	DCR	C		;loop thru first 13 bytes
	JNZ	COMP1
	XRA	A		;clear flags and exit
	RET

; swap subroutine

S$SWAP	MVI	A,1
	STA	NOSSWAP		;swap used, rewrite needed.
	LHLD	I
	CALL	INDEX
	PUSH	H
	LHLD	J
	CALL	INDEX
	XCHG
	POP	H
	MVI	C,32
S$SWAP1	LDAX	D
	MOV	B,A
	MOV	A,M
	STAX	D
	MOV	M,B
	INX	D
	INX	H
	DCR	C
	JNZ	S$SWAP1
	RET

; pack directory

PACK	CALL	ILPRT
	DB	'and packing, ',0
	LXI	H,0		;i = 0
PACK1	SHLD	I
	CALL	INDEX		;hl = bottram + 16 * i
	LXI	D,9
	DAD	D		;hl = hl + 9
	MOV	A,M		;jump if filetype not 'x$$'..
	SUI	'0'		;..where 0.le.x.le.9.
	JC	PACK2
	CPI	10
	JNC	PACK2
	STA	J
	INX	H
	MOV	A,M
	CPI	'$'
	JNZ	PACK2
	INX	H
	MOV	A,M
	CPI	'$'
	JNZ	PACK2
	INX	H		;set extent number to x
	LDA	J
	MOV	M,A
	DCX	H		;set filetype to '$$$'
	MVI	M,'$'
	DCX	H
	MVI	M,'$'
	DCX	H
	MVI	M,'$'
PACK2	LHLD	I		;i = i + 1
	INX	H
	XCHG
	LHLD	DRM
	INX	H
	XCHG
	PUSH	H
	CALL	SUBDE
	POP	H		;loop until i > drm
	JC	PACK1
	RET

; 'sap' error messages

; cp/m 1.4 not allowed with comm7

CPM14	CALL	ILPRT
	DB	CR,ESC,ETEOP,'++ Comm7 not used with CP/M 1.4 ++',0
	JMP	MSGREAD

; mp/m not allowed with comm7

MPM$YES	CALL	ILPRT
	DB	CR,ESC,ETEOP,'++ SAP not used with MP/M ++',0
	JMP	MSGREAD

; read error

RERROR	CALL	ILPRT
	DB	CR,LF,'++ Read error -- directory unchanged ++'
	DB	CR,LF,BELL,0
	JMP	MENU

; write error

WERROR	CALL	ILPRT
	DB	'++ Write error -- directory in '
	DB	'unknown condition ++',BELL,CR,LF,0
	JMP	MENU

	LINK	COMM725D	;chain to 'comm725d.asm' using lasm.com
