; (comm723a.asm)

; process primary option and process/validate secondary options (set
; 'uartctlb' to last declared operating mode.)
 
PROCOPT	LXI	D,FCB+1
	LDAX	D
	STA	OPTION		;primary option stored herein
OPTLP	INX	D
	LDAX	D		; 1st secondary option into a-reg
	CPI	' '		;delimiter for filename-beginning flags..
	JZ	ENDOPT		;..end of secondary option string. 
	LXI	H,OPTBL
	MVI	B,OPTBE-OPTBL	; (test each character over table length)
OPTCK	CMP	M
	JNZ	OPTNO

	 IF	PMMI
	CPI	'O'		;originate mode?
	MOV	C,A		;preserve a-reg for 'a' test
	LDA	ORIGMOD		;get word structure and..
	JZ	OPTCK2		;branch if not
	MOV	A,C		;get a-reg for character test
	CPI	'A'		;answer mode?
	JNZ	OPTCK3		;no, neither mode requested.
	LDA	ANSWMOD		;yes, do..
OPTCK2	STA	UARTCTLB	;..store here.
	 ENDIF			;pmmi

OPTCK3	MVI	M,0		;zero-out options requested in table
	JMP	OPTLP		;loop 'till done
	
OPTNO	INX	H		;see if..
	DCR	B		;..end..
	JNZ	OPTCK		;..of table string length.
	JMP	BADCMD		;option not valid, show message.

ENDOPT	LDA	VSEEFLG		;if 'viewing', suppress..
	ORA	A		;..all..
	JNZ	SW3		;..but..
	STA	QFLG		;..ascii-file text.
SW3	LDA	OPTION		;check primary option
	CPI	' '		;check if initial option requested
	RZ			;blank --> no '.com' file attribute entered
	CPI	'T'		;terminal mode
	RZ
	CPI	'E'		;return if echo option
	RZ
	CPI	'M'		;return to menu
	RZ

	 IF	PMMI
	CPI	'C'		;go to call (telephone) library or..
	RZ
	CPI	'D'		;..disconnect using pmmi.
	RZ
	 ENDIF			;pmmi

	CPI	'S'		;send a file
	JZ	CKFILE
	CPI	'R'		;receive a file
	JNZ	BADCMD
	LDA	BATCHFLG	;if multi-file mode, receive..
	ORA	A		;..option doesn't need filename.
	RZ

; enter command again if no filename specified

CKFILE	LDA	FCB2+1		;option needs filename, check..
	CPI	' '		;..to see if name exists.
	RNZ			;if none, request to do everything over.
REENTER	CALL	ILPRTQ
	DB	ESC,ETEOP,'Filename required (S/R fn.ft), '
	DB	'<RETURN> continues: ',BELL,0
	LXI	D,CMDBUF
	CALL	INBUF		;wait for keyboard input
	LDA	CMDBUF+1	;return to command line..
	ORA	A		;..if only..
	JZ	MENU		;..a <return> entered.
	JMP	DOOPT		;loop back 'till good response entered

; t e r m i n a l   m o d e

; terminal routine allowing memory save

DSKSAVE	LDA	DIRECTB		;load direct bios flag
	STA	DTYPE		;and copy it into tempoary register
	LDA	LSTRETF		;was printer on before..
	ORA	A		;..entering command mode?
	JZ	NOLIST		;no, then branch. 
	XRA	A		;zero resets terminal return..
	STA	LSTRETF		;..flag for next time and sets..
	STA	LISTFLG		;..printer to list characters.
NOLIST	CALL	CROSSCK		;verify option compatibility
	LDA	NFILFLG		;if file open go..
	ORA	A		;..directly..
	JZ	TERM		;..to 'term' loop.
	LXI	H,FCB		;filename moved from fcb2 --> fcb by 'movefcb'
	MVI	B,11		;make sure..
CKOKLP	INX	H		;..no..
	MOV	A,M		;..wildcards..
	CPI	'?'		;..in filename.
	JZ	NGMSG		;if so, say so.
	DCR	B
	JNZ	CKOKLP		;if not, check..
	LDA	FCB+1		;..if a filename..
	CPI	' '		;..was declared.
	JNZ	GOODNM		;yes, name seems okay.
	JMP	TERM		; (no file being saved --> terminal mode)

CROSSCK	LDA	BATCHFLG	;make sure..
	ORA	A
	JZ	BADCMD
	LDA	QFLG		;..primary and secondary options..
	ORA	A
	JZ	BADCMD
	RET			;..are fully compatible.

NGMSG	CALL	ILPRT
	DB	ESC,ETEOP,BELL,' ++ WILDCARDS not allowed ++ ',0
	JMP	MSGREAD

GOODNM	CALL	ERASFIL		;see if file already exists.  erase?
	JNZ	MENU		;no, go to cmd mode.
	CALL	MOVE2		;shifts 1st 12 bytes of fcb to fcb3..
	LXI	D,FCB3		;..(fcb2 previously shifted to fcb).
	MVI	C,MAKE		;create and..
	CALL	BDOS
	LXI	D,FCB3
	MVI	C,OPEN		;..open new file.
	CALL	BDOS
	LXI	H,BOTTRAM	;start address for file-save
	SHLD	HLSAVE		; 'hlsave' --> last byte into file.
	XRA	A		;zero'd so a file can be toggled for save..
	STA	NFILFLG 	;..and 't' used for terminal return.

; main terminal loop with file-save/transfer, output to printer,
; 'softkey' and other capabilities

TERM	CALL	LISTST		;character for printer?
	CALL	STAT		;console keypress?
	JZ	TERML		;no, check line.
	CALL	KEYIN		;get char from kbd
	MOV	B,A		;save and..
	LDA	CMDFLG		; ignore next (ctrl) char locally..
	ORA	A		; ..if zero flag not set.
	MVI	A,0
	STA	CMDFLG		;clear for next time
	MOV	A,B		;..restore.
	JZ	CHROUT		;send character (control code out)

; check for in-line terminal commands

	 IF	TELE25TH	;others don't have 25th line
	PUSH	PSW		;save a-reg and flags
	CALL	ILPRT
	DB	ESC,'h',0	;turn off 25th line
	POP	PSW
	 ENDIF			;tele25th

	 IF	ZENITH
	PUSH	PSW
	CALL	ILPRT
	DB	ESC,'x1',0	;turn off 25th line
	POP	PSW
	 ENDIF			;zenith

	MOV	B,A
	LDA	CMDCHR		; get command character
	CMP	B		; check it out
	MOV	A,B
	JZ	CHROUT1
	CALL	UCASE		;convert to uppercase
	CPI	'E'		;  e = exit terminal mode
	JZ	ALERT		;      (see if save memory file is wanted)
	CPI	'T'		;  t = transfer a file
	CZ	TRANSFER
	JZ	TERM

	 IF	PMMI
	CPI	'@'-40h		; ^@ = send a break (<break> on 'televideo'
	JZ	BREAK		;      equal to a ^@)
	CPI	'D'		;  d = disconnect and return to command mode
	JZ	DISCON1		
	CPI	'B'		;  b = change baud rate
	CZ	NEWBAUD		;get baudrate request (returns with..
	JZ	TERML		;..flags set)
	 ENDIF			;pmmi

	 IF	SOFTKEY
	CPI	'R'		;  r = display softkey table
	CZ	REVIEW		;      yes, show current string-storage.
	JZ	TERM		;      continue looping
	CPI	'0'		;  0 - 9 are soft keys
	JC	CHROUT		;      less than 0
	CPI	'9'		;
	CC	SOFTCMD		;yes, we have a soft key
	JZ	TERM		;      then return to term loop
	 ENDIF			;softkey

	CPI	'P'		;  p = test for printer list
	JNZ	SW6		;no, by-pass toggle.
	LDA	LISTFLG
	CMA
	STA	LISTFLG
	JMP	BELLOUT		;audible printer toggle

SW6	CPI	'S'		;  s = "colon-save"
	JNZ	CHROUT		;no toggle, it's a char to send.
	LDA	NFILFLG		;save not allowed if flag true
	ORA	A
	JNZ	TERML		;check line for another character
	MVI	A,TRUE
	STA	ALERTFG		; 1st time thru announces a save
	LDA	SAVEFLG
	CMA
	STA	SAVEFLG		;toggled by savechr
BELLOUT	MVI	A,BELL		;start/stop printer/file-save..
	CALL	TYPE		;..with audible toggle.
	JMP	TERML		;ck for another char from remote

; exit character storage

EXTFLG	MVI	A,TRUE
	STA	CMDFLG
	JMP	TERML

; character-out through modem port

COMMAND	MVI	A,TRUE
	STA	CMDFLG	;command next

	 IF	TELE25TH
	CALL	ILPRT
	DB	ESC,'f'		;turn on 25th line
	 ENDIF

	 IF	ZENITH
	CALL	ILPRT
	DB	ESC,'j',ESC,'x1',ESC,'Y8 '	;turn on 25th line
	 ENDIF

	 IF	TELE25TH OR ZENITH
;		'----5---10---15---20---25---30---35---40'
	DB	'B>aud | D>isc | E>xit | P>rint | R>evie'
	DB	'w | S>ave | T>ransfer | <break> | (0-9)'
	 ENDIF			;tele25th or zenith

	 IF	TELE25TH	;restore cursor
	DB	ESC,'g',0
	 ENDIF			;tele25th

	 IF	ZENITH
	DB	ESC,'Y  ',ESC,'k',0	;restore cursor
	 ENDIF	;ZENITH

	JMP	TERML		;print message on 25th line

; character-out through modem port -- full/half-duplex option from 'sel'

CHROUT	MOV	B,A
	LDA	CMDCHR		;get command character
	CMP	B		;check it out
	MOV	A,B
	JZ	COMMAND		;it was a command, so show menu
CHROUT1	CALL	OUTCHAR
	MOV	B,A
	LDA	HALFDUP		;if half-duplex..
	ORA	A
	MOV	A,B
	CNZ	TYPE		;..show character locally.

; character input from telephone line -- filter out control codes option

TERML	CALL	INSTAT
	JNZ	TERM
	CALL	INCHAR
	ANI	7FH		;strip parity
	JZ	TERM		;don't process nulls
	MOV	B,A
	LDA	FILBYTE		;filter control codes out?
	ORA	A
	MOV	A,B
	JZ	TERML1		;no, process them.
	CPI	' '
	JNC	TERML1
	CPI	BS		;print backspace,..
	JZ	TERML1
	CPI	HT		;..horizontal tab..
	JZ	TERML1
	CPI	CR		;..carriage return..
	JZ	TERML1
	CPI	LF		;..and line feed.
	JNZ	TERM
TERML1	CALL	TYPE		;print locally
	MOV	B,A		; save line character and..
	LDA	SAVEFLG
	ORA	A
	JZ	TERM		;branch if no-file-save
	LHLD	HLSAVE		;get address of last saved character
	MOV	M,B		;last character copied into ram, pointed..
	INX	H		;..to by 'hlsave-1'.
	SHLD	HLSAVE
	MOV	A,B		; ..put back here.
	CPI	LF		; lf?  if yes,..
	JNZ	NOCOLON		;..type ":" after each line feed..
	MVI	A,':'		;..when memory save active.  (don't put into..
	CALL	TYPEQ		;..colon-save file or send to printer.)
NOCOLON	LDA	SAVCCP
	ORA	A
	LDA	BDOS+2		;check to see if..
	JZ	SUB1
	SUI	CCP+RING	;..page below 'ccp+ring'..
SUB1	DCR	A		;..or 'bdos' has been..
	CMP	H		;..reached and disksave is needed.
	JNZ	TERM		;no, continue looping.  else fall-thru.

; ramsave:  routine automatically stops remote computer when colon-save buffer
; is full and writing to disk is required.  after 'xoff' is sent, up to 'rbuf'
; characters are saved, if necessary, waiting for remote computer to stop
; sending.  if remote never stops, characters are lost during auto-write to
; disk.

RAMSAVE	MVI	A,XOFF		;send a <ctrl-s>, 'xoff', to stop..
	CALL	OUTCHAR		;..remote computer sending.
	MVI	D,RBUF		;initialize for maximum ram buffer length
	CALL	INMODEM		;get characters received after sending 'xoff'
	PUSH	D		;protect d-reg counter
	CALL	WRTDSK		;write 'colon-save' memory to disk
	POP	D		;counter restore
	LXI	H,BOTTRAM	;reset 'colon-save' memory and..
	LXI	B,LASTBYTE	;..buffer areas.
TORAMLP INR	D		;bump 'till..
	MOV	A,D		;..at..
	CPI	RBUF+1		;..maximum.
	JZ	CTRLQ		;branch if at limit
	LDAX	B		;get character from buffer and..
	MOV	M,A		;..put in 'colon-save' memory area.
	INX	H		;ready for..
	INX	B		;..another character.
	CALL	TYPE		;show locally
	JMP	TORAMLP		;continue 'till d-reg tops out

CTRLQ	SHLD	HLSAVE		; 'last character + one' position
	MVI	A,XON		;restart remote computer
	CALL	OUTCHAR
	JMP	TERM		;continue terminal looping

INMODEM	LXI	B,LASTBYTE	;set pointer to buffer begin-address
	PUSH	B
INMDM	LXI	B,104*MHZ	;constand for 100 msec wait
DELAYLP	CALL	INSTAT		;character from line?  if yes, store..
	JZ	GETBYTE		;..received character after 'xoff' sent.
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAYLP		;loop 'till time-out
	POP	B		;restore stack
	RET			;return if remote computer stops sending

GETBYTE	CALL	INCHAR
	POP	B		;get pointer to 'lastbyte' buffer and..
	STAX	B		;..store character there.
	INX	B		;increment pointer and..
	PUSH	B		;..save if a next time thru occurs.
	DCR	D		;bump character count.  at zero yet?
	JNZ	INMDM		;get more, if not.
	POP	B		;restore stack
	RET			;return if buffer full

; routine to send 'break' (null) code -- used by to reboot some remotes

	 IF	PMMI
BREAK	LDA	MODCTLB		;get modem control byte
	ANI	BRK		;set break bit low (active)
	CALL	OUTCTR2	 	;send it to the modem
	LXI	B,104*MHZ   	;constant for 100 msec wait
	 ENDIF			;pmmi

BRKLP	CALL	INSTAT
	JZ	FETCHEM
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	BRKLP

	 IF	PMMI
	LDA	MODCTLB		;restore previous..
	CALL	OUTCTR2		;..modem condition if time-out.
	 ENDIF			;pmmi

	LHLD	HLSAVE		;last address written if colon-save active
	LDA	SAVCCP
	ORA	A
	LDA	BDOS+2		;check to see if..
	JZ	SUB2
	SUI	CCP+RING	;..page below 'ccp+ring'..
SUB2	DCR	A		;..or 'bdos' has been..
	CMP	H		;..reached and disksave is needed.
	JNZ	TERM		;if a-reg not equal to h-reg continue
	CALL	ILPRT		;if equal, show msg and continue.
	DB	CR,LF,'++ File buffer full ++',CR,LF,BELL,0
	JMP	TERM

FETCHEM	CALL	INCHAR
	ORA	A		;check for nulls (cpi 0) but..
	JZ	BRKLP		;..don't process them.
	ANI	7FH		;strip parity
	CALL	TYPE
	MOV	B,A		;copy line character here..
	LDA	SAVEFLG
	ORA	A
	JZ	BRKLP
	LHLD	HLSAVE		;get last address of ram-saved character
	MOV	M,B		;..and here..
	INX	H		; update hl-pair, char by char..
	SHLD	HLSAVE		; ..and store in 'hlsave'.
	MOV	A,B		;..and put back here.
	CPI	LF		;lf?
	JNZ	BRKLP		;yes, type ":" after each line feed..
	MVI	A,':'		;..when memory-save active.
	CALL	TYPE
	JMP	BRKLP

; write ram to disk

; determine # of records in file

RAMDISK	LHLD	HLSAVE		;get 'colon-save' file-end address and..
	MVI	M,EOFCHAR	;..put cp/m terminator there.  then..
	INX	H		;..lengthen thru one record,  making..
	LXI	D,127		;..sure file-bytes..
	DAD	D		;..aren't chopped.
WRTDSK	LXI	D,-(BOTTRAM)	;subtract by adding 2's complement to..
	DAD	D		;..'hlsave' --> total bytes in ram-file.
	MVI	B,7+1		;set to divide total by 128 and return..
	CALL	SHIFTLP		;..with # of records in hl-pair.
	LDA	WRT$FLG		;allow zero-length if..
	ORA	A		;..at least..
	JZ	NEXTWRT		;..one buffer full..
	XRA	A		;..has been written.
	STA	WRT$FLG

; write records to disk

	LXI	D,BOTTRAM
	LDAX	D		;don't save zero-length..
	CPI	EOFCHAR		;..file.  delete..
	JZ	ZEROMSG		;..filename from directory.
NEXTWRT	MVI	C,SETDMA
	CALL	BDOSRET
	PUSH	D
	LXI	D,FCB3
	MVI	C,WRITE
	CALL	BDOSRET
	POP	D
	XCHG			; (if you understand these..
	PUSH	D
	LXI	D,128		;..lines, consider..
	DAD	D
	POP	D		;..yourself..
	XCHG
	DCX	H		;..a cp/m assembly..
	MOV	A,H
	ORA	L		;..language programmer.)
	JNZ	NEXTWRT		;branch if not done
	RET

; zero-length file announcement and filename deletion

ZEROMSG CALL	ILPRT
	DB	CR,ESC,ETEOP,'---> Zero-length file deleted ',0
	MVI	B,20
	CALL	TIMER
	JMP	DELNEWF

; close file at fcb3 -- bdos call with all registers saved and restored

CLOSE3	LXI	D,FCB3
	MVI	C,CLOSE
BDOSRET	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
BDOSV	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; file transfer subroutine -- called with <ctrl-t> from terminal
; routine.  transfer cancelled while sending by using <ctrl-x>.
; choice of blind or protocol-send into receiving line-editor.  file
; may be transfered while another is being saved.

; transfer fcb set-up

TRANSFER LXI	H,FCB4		;hl-pair points to fcb..
	 CALL	INITFCB	 	;..to be intialized.

; process name of file (fn.ft) to transfer

GETFNFT	CALL	ILPRT
	DB	CR,LF,'Enter FILENAME to transfer, '
	DB	'<RETURN> to continue: ',0
	LXI	D,CMDBUF
	CALL	INBUF
	LDA	CMDBUF+2	;was file entered?
	CPI	' '
	JZ	TRANSL2

; set-up to transfer file bytes

	LXI	D,CMDBUF	;move filename to..
	LXI	H,FCB4		;..fcb4..
	CALL	CMDLINE		;..and..
	LXI	D,FCB4		;..open file..
	MVI	C,OPEN		;..for..
	CALL	BDOS		;..reading.
	INR	A		; 0ffh --> 0 if no file found
	JNZ	CONTIN0		;continue, file found.
TRANSL1 CALL	ILPRT
	DB	CR,LF,'++ Unable to find file ++',BELL,CR,LF,0

; bad entry announcement

TRANSL2 CALL	ILPRT
	DB	CR,LF,'T>ype filename again or <RETURN> '
	DB	'to Terminal: ',0
	CALL	RESPOND		;get keyboard response and display
	CPI	'T'
	JZ	GETFNFT		;enter filename/filetype again.  any..
	JMP	RETURN		;..other character returns to terminal loop.

; choice of blind-send or protocol-send

CONTIN0	CALL	ILPRT
	DB	CR,LF,'Delay between characters/lines sent?  (Y/N): ',0
	CALL	RESPOND
	CPI	'N'
	JZ	CONTIN
	XRA	A		;zero line-editor flag
	STA	LNEDFLG
CONTIN	CALL	ILPRT		;a fresh line before..
	DB	CR,LF,LF,0	;..reading file..
	LXI	D,TBUF		;..and away we go.
	MVI	C,SETDMA
	CALL	BDOS

; get 128-byte data record

READMR	LXI	D,FCB4
	MVI	C,READ		;read 128 bytes
	CALL	BDOS
	ORA	A		; eof?
	JZ	SENDMR		;no, branch.
RETURNS	CALL	ILPRT		;yes, show msg:
	DB	CR,LF,'---> Transfer completed',CR,LF,BELL,0
	JMP	RETURN

SENDMR	CALL	SEND80C
	CPI	EOFCHAR		; eof?
	JZ	RETURNS		;return if finished
	CPI	CAN		; (^x) cancellation?
	JNZ	READMR		;loop till 'eof' or <ctrl-x>
	CALL	ILPRT
	DB	CR,LF,'++ Transfer cancelled ++',CR,LF,0
RETURN	MVI	A,TRUE		;sequential transfer default condition
	STA	LNEDFLG
	XRA	A		;return with zero flag set
	RET			;xfer finished, continue loop thru 'term'.

; send 128-byte record

SEND80C	MVI	A,80H		;send 128 bytes
	STA	CHARCNT		;count characters
	LXI	H,TBUF		;points to cp/m 'tbuf'
SENPLHR	LDA	LNEDFLG		;is it line-editor prompted mode?
	ORA	A
	JZ	EDIT		;yes..
	MOV	A,M		;..no, straight blind-send mode.
	CALL	MODOUT
	RZ			;to 'sendmr' for finish
GETNEXT	CALL	STAT		;test for keypress
	JZ	SKIP12
	CALL	KEYIN
	CPI	CAN		; (^x) cancellation character
	RZ			;to readmr for cancel and exit
SKIP12	INX	H		;next character to send pointed to by..
	LDA	CHARCNT
	DCR	A		;..bumping hl-pair, count in charcnt.
	STA	CHARCNT
	JNZ	SENPLHR		;get next character
	RET			;to 'cpi eofchar' in 'sendmr' for 128 bytes

; blind-send to line-editor (dumb protocol)
; sends at 85 words per minute and delays at end-of-line

	 IF	DUMB
EDIT	MOV	A,M
	CPI	LF
	JZ	PROMPT
	CALL	MODOUT
	RZ
	LXI	B,375*MHZ	;delay..
CHRLOOP	DCX	B
	MOV	A,B		;..between..
	ORA	C
	JNZ	CHRLOOP		;..characters.
	JMP	GETNEXT		;get next to send

PROMPT	CALL	MODOUT		;send 'lf' to remote
	MVI	B,7		;delay at line-end after sending a 'cr'
	CALL	TIMER		; 100 msec in b-reg
	JMP	GETNEXT

; blind-send to remote (no protocol)

MODOUT	PUSH	PSW		;save send-character in a-reg 
	PUSH	H		;protect 'tbuf' pointer
	CALL	LISTST		;character for printer?
	POP	H
MODLP	CALL	OUTSTAT		;test if ready to send
	JNZ	MODLP		; (out at baudrate)
	POP	PSW		;character back into a-reg
	CALL	OUTCHAR		;char out modem
	CPI	EOFCHAR		;if (^z) don't send to..
	RZ			;..terminal, just return.  if..
	JMP	TYPE		;..not, print locally.
	 ENDIF			;dumb

; (experimental)
; smart-protocol send/receive to line-editor (receives echo before next
; send).  checks for bell near, and cursor return at, end-of-line.  waits
; for remote prompt(s) to be received before continuing send.

	 IF	NOT DUMB
EDIT	MOV	A,M		;char to send into a-reg
	CPI	CR		;end of line?
	JZ	WAITFOR		;yes, get delay, else..
	CALL	MODOUT2		;..send chararcter out modem.
	CPI	EOFCHAR		;if eof then..
	RZ			;..finish up.
	JMP	GETNEXT		;get another character to send

; wait for remote prompt(s) to be sent

WAITFOR	CALL	MODOUT2
	MVI	B,10		;wait window for bbs prompt(s)
	CALL	TIMER		; (100 msec timer)
	CALL	CRLF		; (crlf not received as echo)
	JMP	GETNEXT		;get another character

; smart-send/receive to/from remote (special protocol)

MODOUT2	CALL	OUTCHAR		;character out
	CPI	EOFCHAR		;eof?
	RZ			;yes, don't type.  ret & finish up.
MODLP2	CALL	INSTAT
	JNZ	MODLP2		;(in at baudrate)
	CALL	INCHAR		;get echo
	ANI	7FH		;strip parity
	RZ			;don't process null
	CALL	TYPE		;if not null, show locally.
 	CPI	BELL		;bell?  if yes, delay till remote..
	JZ	DELAY07		;..is able to receive next char else..
	RET			;..ret and send next character.

; delay sending after receiving bell (07H)

DELAY07	MVI	B,2		; 200 msec wait before sending next..
	CALL	TIMER		;..character after near-end-of-line bell
	RET			;to caller of modout2
	 ENDIF			;not dumb

; softkey routine outputs stored text by pressing the lead-in
; character followed by a single numeral, 0,1,2,3, etc.  see skone
; db fields before start of program for the command and message
; strings (alter them as desired).  <lead-in> d displays the fields
; locally while in terminal mode.

	 IF	SOFTKEY
SOFTCMD	SUI	30H		;ok, now convert ascii digit to binary.
	RLC			; *2 for table offset (0,1,2... --> 0,2,4...)
	LXI	H,SKTBL		;point to softkey table and.
	MOV	E,A		;..index down, factor in a-reg.
	MVI	D,0		;clear msb
	DAD	D		;add offset to table beginning address
	MOV	E,M		;get dw address in table
	INX	H		;fully fill de-pair
	MOV	D,M		;done, next..
	XCHG			;..point to desired db string in table.
KEYSEND	MOV	A,M		;put character in a-reg for sending
	ORA	A		;ck for null terminator
	RZ
	CALL	OUTCHAR		;send character to remote
	LXI	B,400*MHZ
MDMINLP	CALL	INSTAT		;test if echo character received
	JZ	GETCHR		;if not, delay..
	DCX	B		;..and..
	MOV	A,B		;..try..
	ORA	C		;..again..
	JNZ	MDMINLP		;..and again 'till timeout or char rcvd.
	RET			;ret to terminal loop

GETCHR	CALL	INCHAR		;character received in a-reg
	ANI	7FH		;strip parity
	JZ	NULSKIP		;don't process if null
	CALL	TYPE		;display locally
NULSKIP	INX	H		;get next character to be sent
	JMP	KEYSEND		;loop till terminator

; softkey dispatch table

SKTBL	DW	SKZERO		;address of db text strings
	DW	SKONE
	DW	SKTWO
	DW	SKTHREE
	DW	SKFOUR
	DW	SKFIVE
	DW	SKSIX
	DW	SKSEVEN
	DW	SKEIGHT
	DW	SKNINE		; 0 to 9 presently permitted
	 ENDIF			;softkey

; e c h o   m o d e   (resemble a computer)

TERM$ECHO CALL	CROSSCK		;comfirm option compatibility
ECHOLP	CALL	INSTAT
	JZ	LINECHR
	CALL	STAT
	JZ	ECHOLP
	CALL	KEYIN
	MOV	B,A		;save character
	LDA	CMDFLG		;ignore next (ctrl) char locally..
	ORA	A		;..if zero flag not set.
	MVI	A,0
	STA	CMDFLG		;clear for next time
	MOV	A,B		;restore character
	JNZ	ECHOCMD		;we are in command mode, check for command.
	LDA	CMDCHR		;get command character
	CMP	B
	JNZ	SW7		;not command character, so send it out.
	ORI	TRUE		;set command mode
	STA	CMDFLG
	JMP	ECHOLP		;go back to main echo loop

LINECHR	CALL	INCHAR
SW7	CPI	CR		;if cursor return..
	JNZ	SW7A
	CALL	OUTCHAR
	CALL	TYPE		;print locally
	MVI	A,LF		;..auto-output a linefeed.
SW7A	CALL	OUTCHAR
	CALL	TYPE
	JMP	ECHOLP		;loop for more

ECHOCMD	CALL	UCASE
	CPI	'E'		;exit to (re-enter) command mode
	JZ	MENU

	 IF	PMMI
	CPI	'B'		;same routines as in 'terminal mode'
	CZ	NEWBAUD
	JZ	ECHOLP
	 ENDIF			;pmmi

	JMP	SW7		;not a valid command, so send it

; s e n d

SENDFIL	 MVI	A,'C'		;always force checksum..
	 STA	CRCFLG		;..mode initially on send.
SENDFIL1 LDA	BATCHFLG	;check if multiple file..
	 ORA	A		;..(batch) mode is set.
	 JNZ	SENPLF
	 CALL	ILPRTQ
	 DB	CR,LF,'Ready to send -- batch mode',0
SENDFIL2 MVI	A,TRUE		;indicate 'batch' send mode
	 STA	SENDFLG
	 LDA	FSTFLG		;if first time thru..
	 ORA	A		;..scan the command line..
	 CNZ	TNMBUF		;..for multiple names.
	 CALL	SENDFN		;sends filename to receiver
	 JNC	SENPLF		;carry set means no more files
	 MVI	A,'B'		;stop batch..
	 STA	BATCHFLG	;..mode secondary option.
	 MVI	A,EOT		;final file transfer indication
	 CALL	SEND
	 JMP	DONE

SENPLF	CALL	CNREC		;get number of records
	CALL	OPENFIL
	MVI	E,90		;waiting time-out
	CALL	WAITNAK
SENDLP	CALL	CKABORT		; (manual abort?)
	CALL	RDRECD		;read a record
	JC	SENDEOF		;send 'eof' if done
	CALL	INCRRNO		;bump count
	MVI	A,1             ;initialize error count for 1st error
	STA	ERRCT
SENDRPT	CALL	CKABORT		;want to quit sending?
	CALL	SENDHDR		;send a header
	CALL	SENDREC		;send bytes of record
	LDA	CRCFLG
	ORA	A
	CZ	SENPLRC		;send phone line crc or..
	CNZ	SENPLKS		;..cksum.
	CALL	GETACK		;get the ack.  rets with carry..
	JC	SENDRPT		;..set if no ack received.
	JMP	SENDLP		;loop till 'eof'

SENDEOF	MVI	A,EOT
	CALL	SEND		;send an 'eot'
	CALL	GETACK
	JC	SENDEOF		;loop if no ack
	JMP	DONE		;to 'finish up' routine

; r e c e i v e

; initial entry routine

RCVFIL	XRA	A		;set initially..
	STA	CRCFLG		;..to 'crc' mode
RCVFIL1	LDA	BATCHFLG	;check if mult-file..
	ORA	A		;..(batch) mode.
	JNZ	RCVC3
	XRA	A		;flag --> 'batch' receive..
	STA	SENDFLG		;..for next file transfer.
	CALL	GETFN		;get filename
	JNC	RCVC2		;carry set means no more files
	MVI	A,'B'		;stop batch..
	STA	BATCHFLG	;..mode option.
	JMP	DONE		;finish

RCVC2	CALL	CKCPM2
	CALL	CKBAKUP
RCVC3	CALL	ERASFIL		;if file exists -- erase.  else use..
	JNZ	MENU		;..different filename, as desired.
	CALL	MAKEFIL
	LDA	BATCHFLG
	ORA	A
	JZ	RCVFST		;no msg if in 'batch' mode..
	CALL	ILPRTQ		;..but shows in 'quiet'.
	DB	CR,LF,'File open -- ready to receive',0
RCVFST	LDA	CRCFLG		;determine mode and..
	ORA	A
	JNZ	RCVFIL2		; (do 'checksum')
	CALL	ILPRTQ		;..if 'crc', say:
	DB	CR,LF,'CRC in effect',CR,LF,0
	MVI	A,CRC
	JMP	RCVCRCM		;store 'c' (or 'nak')

RCVFIL2	CALL	ILPRTQ		;else show this msg then..
	DB	CR,LF,'Checksum in effect',CR,LF,0
	MVI	A,NAK		;..store..
RCVCRCM	STA	ACKFLG		;..'nak'.

; main receive loop -- update record count, write, and close file

RCVLP	CALL	RCVRECD		;get a record
	JC	RCVEOT		;get 'eot'
	CALL	WRRECD		;write the record
	CALL	INCRRNO		;bump count
	MVI 	A,ACK
	STA	ACKFLG		;store 'ack'
	JMP	RCVLP		;loop till 'ack'

RCVEOT	CALL	WRBLOCK		;write last record
	CALL	SENDACK		;send 'ack'
	CALL	CLOSFIL		;close file
	JMP	DONE		;finished
	
; subroutines used by batch mode

; await 'nak' -- send 'ack'

SENDFN	CALL	ILPRT		;don't show in quiet mode
	DB	CR,LF,'Awaiting filename NAK',CR,LF,0
	MVI	E,90
	CALL	WAITNLP		; (don't show 'awaiting ready signal')
	MVI	A,ACK		;got nak, send ack.
	CALL	SEND
	LXI	H,FILECT
	DCR	M
	JM	NOMRNM
	LHLD	NBSAVE		;get filename..
	LXI	D,FCB		;..into fcb.
	MVI	B,12
	CALL	MOVE
	SHLD	NBSAVE
	CALL	SENDNM		;send it
	ORA	A		;clear carry
	RET

NOMRNM	MVI	A,EOT
	CALL	SEND
	STC
	RET

; send filename

SENDNM	PUSH	H
SENDNM1	MVI	D,11		;count chars in name
	MVI	C,0		;init checksum
	MOV	A,C
	STA	FTYCNT		;initialize filetype count
	LXI	H,FCB+1		;address name
NAMLPS	MOV	A,M		;send name
	ANI	7FH		;strip high order bit so cp/m 2..
	CALL	SEND		;..won't send r/o file designation.
	LDA	QFLG		;don't show filename..
	ORA	A		;..if in 'quiet' mode.
	MOV	A,M
	CNZ	FTYTST		;type locally filename characters
ACKLP	PUSH	B		;save cksum
	MVI	B,10		;wait 1 sec for receiver..
	CALL	RECV		;..to acknowledge..
	POP	B		;..getting letter.
	JC	SCKSER		;cksum error --> time-out on receive
	CPI	ACK
	JNZ	ACKLP
	INX	H		;bump for next character
	DCR	D
	JNZ	NAMLPS
	MVI	A,EOFCHAR 	;tell receiver end of name
	CALL	SEND
	CALL	CRLF		; (doesn't show in quiet mode)
	MOV	D,C		;save checksum
	MVI	B,10		; 1-sec time-out
	CALL	RECV		;get checksum..
	CMP	D		;..from receiver.
	JZ	NAMEOK
SCKSER	MVI	A,BDNMCH 	;bad name, tell receiver.
	CALL	SEND
	CALL	ILPRTQ
	DB	CR,LF,'++ Filename error ++',CR,LF,0
	MVI	E,90		;do handshaking over
	CALL	WAITNLP		;don't print 'awaiting filename nak' msg
	MVI	A,ACK
	CALL	SEND
	JMP	SENDNM1		;re-send filename

NAMEOK	MVI	A,OKNMCH 	;successful filename sent and received,..
	CALL	SEND		;..tell receiver.
	POP	H
	RET	

GETFN	LXI	H,FCB
	CALL	INITFCB+2 	;does not initialize drive
	CALL	ILPRTQ
	DB	CR,LF,'Ready to receive filename',CR,LF,0
GNAMELP	MVI	E,45		; 90-seconds for receiving 'ack'
	CALL	HSNAK		;get 'ack' or auto-abort
	CALL	GETNM		;get the name
	CPI	EOT		;if eot, then no more files.
	JZ	NOMRNMG
	ORA	A		;clear carry
	RET

NOMRNMG	STC
	RET

GETNM	PUSH	H
GETNM1	MVI	C,0		;initialize checksum
	MOV	A,C
	STA	FTYCNT		;initiate count for filetype
	LXI	H,FCB+1
NAMELPG	MVI	B,50
	CALL	RECV		;get char (5-sec time-out)
	JNC	GETNM3
	CALL	ILPRTQ
	DB	CR,LF,'Timeout receiving filename',CR,LF,0
	JMP	GCKSER

GETNM3	CPI	EOT		;if 'eot', then no more files.
	JZ	GNRET
	CPI	EOFCHAR		;got end of name
	JZ	ENDNAME
	MOV	M,A		;put name in fcb
	CALL	FTYTST		;show locally received filename
	PUSH	B		;save cksum
	MVI	A,ACK		; 'ack' getting letter
	CALL	SEND
	POP	B
	INX	H		;get next char
	MOV	A,L		;don't let noise...
	CPI	7FH		;..cause overflow..
	JZ	GCKSER		;..into program area.
	JMP	NAMELPG

; show locally filename sent/received

FTYTST	LDA	FTYCNT		;filetype counter
	INR	A
	STA	FTYCNT
	CPI	8+1		;into filetype yet?
	JZ	SPCTST		;go if so
ENDSPT	MOV	A,M
	CPI	' '		;test for space
	CNZ	TYPEQ		;type if not
	RET

SPCTST	MOV	A,M		; 'space' test
	CPI	' '		;test for space in first filetype byte
	RZ			;don't output period if space
	MVI	A,'.'
	CALL	TYPEQ
	JMP	ENDSPT		;output first filetype byte

; verify 'goodname' recevied after sent

ENDNAME	CALL	CRLF		; (not shown in quiet mode)
	MOV	A,C		;send checksum
	CALL	SEND
	MVI	B,10		; 1-sec time-out
	CALL	RECV	   	;checksum good?
	CPI	OKNMCH	   	;yes, if oknmch sent..
	JZ	GNRET	   	;..else do over.
GCKSER	LXI	H,FCB	   	;clear fcb (except drive) since it can be..
	CALL	INITFCB+2 	;..changed by too many characters.
	CALL	ILPRTQ
	DB	CR,LF,'++ Filename error ++',CR,LF,0
GCKSER1	MVI	E,45
	CALL	HSNAK		;do handshaking over
	JMP	GETNM1

GNRET	POP	H
	RET

; handshake 'nak'/'ack'

HSNAK	MVI	A,NAK		;send nak until receiving..
	CALL	SEND		;..'ack' or e-reg times out.
	CALL	CKABORT		; (manual abort?)
	MVI	B,20		;wait 2 seconds..
	CALL	RECV		;..in receive.
	CPI	ACK		;if ack, then..
	RZ			;..return.
	DCR	E		;time-out in e-reg
	JNZ	HSNAK		;loop 'till time-out and..
	JMP	ABORT		;..then abort.

; load 'namebuf' with filename(s) to send

TNMBUF	XRA	A		;call from 'sendfil' only once.
	STA	FSTFLG
	STA	FILECT
	CALL	SCANM
	LXI	H,NAMEBUF
	SHLD	NBSAVE		;save addr of 1st name
TNLP1	CALL	TRTOBUF
	LXI	H,FCB
	LXI	D,FCBBUF
	CALL	CMDLINE		;parse name to cp/m format
TNLP2	CALL	MFNAME		;search for names (* format)
	JC	NEXTNM
	LDA	FCB+10		;if cp/m 2 $sys file..
	ANI	80H		;..don't send.
	JNZ	TNLP2
	LHLD	NBSAVE		;get name
	LXI	D,FCB		;move it to fcb
	XCHG
	MVI	B,12
	CALL	MOVE
	XCHG
	SHLD	NBSAVE	 	;addr of next name
	LXI	H,FILECT 	;count files found
	INR	M
	JMP	TNLP2

NEXTNM	LXI	H,NAMECT 	;count names found
	DCR	M
	JNZ	TNLP1
	LXI	H,NAMEBUF 	;save start of buffer
	SHLD	NBSAVE
	LDA	FILECT
	CPI	64+1		;no more than 64 transfers
	RC
	MVI	A,64		;only x'fer first 64
	STA	FILECT
	RET

; scan cmdbuf, counts names, and puts "space" after last name

SCANM	PUSH	H
	LXI	H,NAMECT
	MVI	M,0
	LXI	H,CMDBUF+1 	;find end of cmd line..
	MOV	C,M		;..and put space there.
	MVI	B,0
	LXI	H,CMDBUF+2
	DAD	B
	MVI	M,' '		;space
	LXI	H,CMDBUF+1
	MOV	B,M
	INR	B
	INR	B
SCANLP1	INX	H
	DCR	B
	JZ	DNSCAN
	MOV	A,M
	CPI	' '
	JNZ	SCANLP1
SCANLP2	INX	H		;eat extra spaces
	DCR	B
	JZ	DNSCAN
	MOV	A,M
	CPI	' '
	JZ	SCANLP2
	SHLD	BGNMS		;save start of names in cmdbuf
	INR	B
	DCX	H
SCANLP3	INX	H
	DCR	B
	JZ	DNSCAN
	MOV	A,M
	CPI	' '
	JNZ	SCANLP3
	LDA	NAMECT		;counts names
	INR	A
	STA	NAMECT
SCANLP4	INX	H		;eat spaces
	DCR	B
	JZ	DNSCAN
	MOV	A,M
	CPI	' '
	JZ	SCANLP4
	JMP	SCANLP3

DNSCAN	MVI	M,' '		;space after last char
	POP	H
	RET

; place next name in buffer so cpmline may parse it

TRTOBUF	LHLD	BGNMS
	MVI	B,0
	LXI	D,FCBBUF+2
TBLP	MOV	A,M
	CPI	' '		;space
	JZ	TRBFEND
	STAX	D
	INX	H
	INX	D
	INR	B		;count chars in name
	JMP	TBLP

TRBFEND	INX	H
	MOV	A,M		;eat extra spaces
	CPI	' '
	JZ	TRBFEND
	SHLD	BGNMS
	LXI	H,FCBBUF+1 	;put # chars before name
	MOV	M,B
	RET

; $r/o and $sys files changed to 'bak'

CKCPM2	LXI	D,TBUF		;establish 'dma'
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB
	MVI	C,SRCHF		;search for file
	CALL	BDOS
	INR	A		; 0ffh --> 0 means no file found
	RZ
	CALL	GETADDR		;returns filename address in hl-pair
	DCX	H
	LXI	D,9
	DAD	D		;point to 'r/o' attribute byte
	MOV	A,M
	ANI	80H		;test msb
	JNZ	MKCHG		;if set, make change.
	INX	H		;check 'system' attribute byte
	MOV	A,M
	ANI	80H
	RZ			;not $sys or $r/o
	DCX	H
MKCHG	LXI	D,-8
	DAD	D		;point hl-pair to filename+1
	LXI	D,FCB+1		;move directory name to fcb..
	MVI	B,11		;..without changing drive.
	CALL	MOVE
	LXI	H,FCB+9		; $r/o attribute is..
	MOV	A,M
	ANI	7FH		;..stripped here and..
	MOV	M,A
	INX	H		;..$sys attribute is..
	MOV	A,M
	ANI	7FH		;..stripped here.
	MOV	M,A
	LXI	D,FCB
	MVI	C,30		;set new file attributes in directory
	CALL	BDOS
	JMP	PLANCHG

; check if backup required and change filetype to 'bak'

CKBAKUP	LDA	BAKUPBYTE
	ORA	A
	RZ
	MVI	C,SRCHF
	LXI	D,FCB
	CALL	BDOS
	INR	A		; 0ffh --> 0 means..
	RZ			;..file not found.
PLANCHG	LXI	H,FCB		;change name to type 'bak'
	LXI	D,FCB2
	MVI	B,9		;copy drive and filename (not filetype)
	CALL	MOVE
	LXI	H,FCB2+9	;start of filetype in fcb2
	MVI	M,'B'
	INX	H
	MVI	M,'A'
	INX	H
	MVI	M,'K'
	LXI	D,FCB2
	MVI	C,ERASE		;erase existing backup, if one.
	CALL	BDOS
	LXI	H,FCB2		;fcb2 'dr' field should..
	MVI	M,0		;..be 0 for rename.
	LXI	D,FCB
	MVI	C,REN		;rename the file
	JMP	BDOS		;ret to caller

; receive 'cp/m file' routines

; receive a record

RECVACK	MVI	A,ACK
	STA	ACKFLG		;store 'ack' first
RCVRECD MVI	A,1		;initialize error count for 1st error
	STA	ERRCT
RCVRPT	XRA	A		;clear receive..
	STA	ERRCDE		;..error code.
	CALL	CKABORT		;ck keyboard for abort request
	CALL	ILPRT
 	DB	CR,'Awaiting #',0
	PUSH	H		;save it
	LHLD	RECDNO		;get record number
	INX	H		;bump it
	CALL	DECOUT		;print record number in decimal
	CALL	ILPRT
	DB	' (', 0
	CALL	DHXOUT		; 16-bit hex conversion & output
	CALL	ILPRT
	DB	'H) ',0
	POP	H		;restore it
	LDA	ACKFLG		;send 'ack' or..
	CALL	SEND		;..'nak' now.

;---->	rcvsq:
;	if 'crc' is in effect, there is a 10-second timeout to first
;	'soh'.  rountine tries 'errcrc' times to let sender know system
;	is capable of receiving a crc check.  At the end of that time
;	a 'nak' is sent which tells sender to use checksum checking
;	instead of crc.  thus automatic compatability with systems
;	implementing crc (cyclic redundancy checking) is provided.

RCVSQ	MVI	B,100-10	; 10 (-1) second timeout
	CALL	RECV		;get line character
	JC	RCVSTOT		;indicate 'timeout' occurred
	CALL	RCVERR		;check for receive errors (fop) and report
	CPI	SOH		;a start of header?
	JZ	RCVSOH		;branch, if yes.
	ORA	A		;character a null?
	JZ	RCVSQ		; (disregard)
	CPI	CRC		;was it a 'crc' we sent?
	JZ	RCVSQ		; (disregard)
	CPI	NAK		;or a checksum 'nak'?
	JZ	RCVSQ		; (disregard)
	CPI	EOT		;or an end of text?
	STC			;if yes, done -- return..
	RZ			;..with carry set.
	MOV	B,A		;save received character..
	CALL	ILPRT
	DB	CR,LF,'++ ',0
	MOV	A,B
	CALL	HEXO		;..to display on console as hex value.
	CALL	ILPRT
	DB	'h received, not SOH - ',0
RCVPRN	CALL	SHOWERR		;display error count
RCVSERR	MVI	B,10		;wait up to 1 second..
	CALL	RECV		;..with no character received.
	JNC	RCVSERR		;loop until sender done
	CALL	CKABORT		;want to stop receiving now?
	LDA	CRCFLG		;get 'crc' flag
	ORA	A		; 'crc' in effect?
	MVI	A,NAK		;put 'nak' in accumulator
	JNZ	RCVSER1		;no, store the 'nak'.
	LDA	FIRSTME		;first soh..
	ORA	A		;..been received?
	MVI	A,NAK		;put 'nak' in accumulator
	JZ	RCVSER1		;yes, then store 'nak'.
	MVI	A,CRC		;tell sender 'crc' is in effect
RCVSER1 STA	ACKFLG		;store the 'nak' or 'crc' request
	LDA	ERRCT		;include this error..
	INR	A		;..in the error count.
	STA	ERRCT		;abort if at limit
	CPI	ERRLIM+1	; (started out with count at 1)
	JC	RCVRPT		;no, try again.
	JMP	ABORT		;auto-abort at error limit

; cancel file-receive and erase unfinished file

RCVSABT	LXI	SP,STACK	;start anew
	CALL	CLOSFIL		;save records received then..
	CALL	NOASK		;..delete the partial file.
	CALL	ILPRTQ
	DB	CR,LF,'Routine cancelled -- '
	DB	'Unfinished file deleted' ,CR,LF,LF,BELL,0
	JMP	DONETCA		;to (tc) 'transfer completed' routine

; get error count and show locally

SHOWERR	PUSH	H
	LHLD	ERRCT		;load 8-bit error count and..
	MVI	H,0		;..zero high byte, then..
	CALL	DECOUT		;..display in decimal.
	POP	H
	CALL	ILPRT
	DB	' ++',CR,LF,0	;add trailer and start newline
	RET

; time-out announcement -- routine switches from 'crc' to 'checksum' if
; 'errct' reaches 'errcrc' and 'firstme' is true

RCVSTOT	CALL	ILPRT
	DB	CR,LF,'++ Timeout ',0
	CALL	SHOWERR
	LDA	ERRCT
	CPI	ERRCRC		;number of tries for crc/checksum soh
	JC	RCVSERR
	LDA	FIRSTME
	ORA	A
	JZ	RCVSERR
	LDA	CRCFLG
	ORA	A
	JNZ	RCVSERR
	MVI	A,'C'		;show now in checksum mode
	STA	CRCFLG
	CALL	ILPRTQ
	DB	'Switching to Checksum mode',CR,LF,BELL,0
	JMP	RCVSERR

;---->	rcverr:
;	checks for framing, overrun, and parity (fop) errors.
;	  1. error code (errcde) was set in 'recv' routine.
;	  2. errcde = 0 for no errors, errcde <> 0 for errors.
;	  3. on an error, routine jumps to rcvderr for display.
;	     but if no error, simply rets to caller.

RCVERR	 MOV	B,A		;save received character and..
	 LDA	ERRCDE		;get receive error code
	 ORA	A		;is it zero?
	 JNZ	RCVDERR		;no, get receive error.
	 MOV	A,B		;..put it back here.
	 RET

;---->	rcvderr:  checks for receive error and displays appropriate error
;	message.  then goes to 'rcvprn' to show error count, purge line,
;	and send 'nak'.

RCVDERR	 POP	PSW		;balance stack from call
	 LDA	ERRCDE	 	;get receive error code
	 ANI	FE	 	;was there a framing error?
	 JZ	RCVDERR2 	;no, go check for overrun.
	 CALL	ILPRT		;show error type then..
	 DB	CR,LF,'++ Framing error ',0
	 JMP	RCVPRN  	;..print error number.

RCVDERR2 LDA	ERRCDE
	 ANI	OE	 	;was there an overrun?
	 JZ	RCVDERR3 	;no, go check for parity error.
	 CALL	ILPRT
	 DB	CR,LF,'++ Overrun error ',0
	 JMP	RCVPRN

RCVDERR3 LDA	ERRCDE
	 ANI	PE		;parity error?
	 JZ	RCVRPT		;no, get another character.
	 CALL	ILPRT
	 DB	CR,LF,'++ Parity error ',0
	 JMP	RCVPRN

; got soh -- get record # and its complement

RCVSOH	XRA	A
	STA	FIRSTME		;indicate first soh was recevied
	MVI	B,10		; 1-sec time-out
	CALL	RECV		;receive character routine
	JC	RCVSTOT 	;indicate time-out
	CALL	RCVERR		;check for receive (fop) error and report
	MOV	D,A		;save record # for..
	MVI	B,10
	CALL	RECV
	JC	RCVSTOT
	CALL	RCVERR
	CMA			;..comparsion with..		
	CMP	D		;..its complement.
	JZ	RCVDATA		;okay, get 128-byte record.
	CALL	ILPRT
	DB	CR,LF,'++ Invalid record # in header - ',0
	JMP	RCVPRN		;display error count

RCVDATA	MOV	A,D
	STA	RCVRNO
	MVI	A,1		;set to 'show' data if in..
	STA	DATAFLG		;..'view' mode.
	MVI	C,0
	CALL	CLRCRC		;clear crc counter
	LXI	H,TBUF
RCVCHR	MVI	B,10		; 1-sec time-out
	CALL	RECV		;receive character routine
	JC	RCVSTOT 	;indicate time-out
	CALL	RCVERR		;check for receive (fop) error
	MOV	M,A		;store rcvd char in ram
	INR	L		;loop for 128 bytes
	JNZ	RCVCHR
	XRA	A		;indicate don't 'show' if in..
	STA	DATAFLG		;..'view' mode.
	LDA	CRCFLG
	ORA	A
	JZ	RCVCRC
	MOV	D,C
	MVI	B,10
	CALL	RECV
	JC	RCVSTOT
	CALL	RCVERR
	CMP	D
	JNZ	RCVCERR		;indicate checksum error
CK$R$NM	LDA	RCVRNO		;compare record..
	MOV	B,A
	LDA	RECDNO
	CMP	B		;..numbers.
	JZ	RECVACK
	INR	A
	CMP	B
	JNZ	ABORT
	RET

RCVCRC	MVI	E,2		;nr of crc bytes
RCVCRC2	MVI	B,10
	CALL	RECV
	JC	RCVSTOT
	CALL	RCVERR
	DCR	E
	JNZ	RCVCRC2
	CALL	CHKCRC
	ORA	A
	JZ	CK$R$NM
	CALL	ILPRT
	DB	CR,LF,'++ CRC error ',0
	JMP	RCVPRN		;display error count

RCVCERR	CALL	ILPRT
	DB	CR,LF,'++ Checksum error ',0
	JMP	RCVPRN

; send 'cp/m file' routines

; send start-of-header, record #, and its complement

SENDHDR	CALL	ILPRT
	DB	CR,'Sending #',0
	PUSH	H
	LHLD	RECDNO		;get record number
	CALL	DECOUT		;display in decimal and..
	CALL	ILPRT
	DB	' (',0
	CALL	DHXOUT		;..in hexidecimal.
	CALL	ILPRT
	DB	'H) ',0
	POP	H
SENDHNM	MVI	A,SOH		;send soh..
	CALL	SEND
	LDA	RECDNO		;..record # and..
	CALL	SEND
	LDA	RECDNO
	CMA
	JMP	SEND		;..its complement.

; send-record loop

SENDREC	MVI	A,1		;ready to 'show' data if in..
	STA	DATAFLG		;..'view' mode.
	MVI	C,0
	CALL	CLRCRC
	LXI	H,TBUF		;point to characters to send
SENPL	MOV	A,M		;get one chararcter from ram
	CALL	SEND
	INR	L		;loop 'till 128 bytes..
	JNZ	SENPL		;..are sent.
	XRA	A		;stop possibility..
	STA	DATAFLG		;;..of 'viewing'.
	RET

; send (phone line) checksum

SENPLKS	MOV	A,C
	JMP	SEND

; send 2-byte 'crc'

SENPLRC	PUSH	H
	LHLD	CRCVAL
	MOV	A,H
	CALL	SEND
	MOV	A,L
	CALL	SEND
	POP	H
	XRA	A
	RET

; receive either 'acknowledge' or error character

GETACK	MVI	B,100		; 10-sec time-out
	CALL	RECVDG		;enter clearing noise char
	JC	GETATOT		;indicate timeout occurred
	CPI	ACK
	RZ			; 'ack' received -- return.
	MOV	B,A
	CALL	ILPRT
	DB	CR,LF,'++ ',0
	MOV	A,B
	CPI	NAK		;if 'nak'..
	JZ	PRTNAK		;..say so.
	CALL	HEXO		;else show hex value..
	CALL	ILPRT
	DB	'h',0		;..received instead of 'nak'.
	JMP	ACKERR0
PRTNAK	CALL	ILPRT
	DB	'NAK',0
ACKERR0	CALL	ILPRT
	DB	' received, not ACK - ',0

; acknowledge and keep track of errors (for send-file)

ACKERR	CALL	SHOWERR		;display error count and line tail
	LDA	ERRCT		;update error counter
	INR	A
	STA	ERRCT
	CPI	ERRLIM+1	;reached the error limit yet?
	RC			;if not, back to work.
	CALL	ERXIT
	DB	'---> File send cancelled','@'

; time-out message

GETATOT	CALL	ILPRT
	DB	CR,LF,'++ Timeout on ACK - ',0
	JMP	ACKERR

; check for request to abort

CKABORT	LDA	VSEEFLG		;abort permitted in 'view' and other..
	ORA	A
	JZ	CKABRT1
	LDA	QFLG
	ORA	A
	RZ			;..modes but not in quiet mode.
CKABRT1	CALL	STAT
	RZ
	CALL	KEYIN
	CPI	CAN
	RNZ			;if zero, abort.

; cancellation routines

ABORT	LXI	SP,STACK
ABORTL	MVI	B,10		; 1-second timeout to clear input here..
	CALL	RECV
	JNC	ABORTL
	MVI	A,CAN
	CALL	SEND
ABORTW	MVI	B,10		;..and here.
	CALL	RECV
	JNC	ABORTW		;loop
	MVI	A,' '
	CALL	SEND
	MVI	A,'B'	 	;turn multi-file mode..
	STA	BATCHFLG 	;..off so routine ends.
	MVI	A,TRUE   	;show abort..
	STA	ABORTFLG	;..was requested.
	LDA	OPTION		;receiving a file now?
	CPI	'R'
	JZ	RCVSABT		;if yes, cancel the unfinished file.
	CALL	ILPRT
	DB	CR,LF,'---> Routine cancelled',CR,LF,LF,BELL,0
	JMP	DONETCB

; increment record number

INCRRNO	PUSH	H
	LHLD	RECDNO		;get record number
	INX	H		;bump it
	SHLD	RECDNO		;store it
	MOV	A,L
	POP	H
	RET

; erase file routine with question

ERASFIL	LDA	BATCHFLG	;don't ask for erase..
	ORA	A	 	;..in multi-file mode..
	JZ	NOASK	 	;..just do it.
	LXI	D,FCB
	MVI	C,SRCHF
	CALL	BDOS
	INR	A		; 0ffh --> 0 if file not found
	RZ			;ok to create file
	CALL	ILPRT
	DB	CR,LF,'File exists - erase?  (Y/N): ',BELL,0
	CALL	RESPOND
	CPI	'Y'		;anything else..
	RNZ			;..rets to caller/cmd mode.
	CALL	CRLF
NOASK	LXI	D,FCB
	MVI	C,ERASE
	JMP	BDOS

; create a cp/m file

MAKEFIL	LXI	D,FCB
	MVI	C,MAKE
	CALL	BDOS
	INR	A
	RNZ
	CALL	ERXIT
	DB	'++ Unable to make file - directory '
	DB	'may be full ++','@'

; determine file record count and save in rcnt

CNREC	MVI	C,COMPSZ	;compute file size function
	LXI	D,FCB		;point to file control block
	CALL	BDOS
	LHLD	FCB+33		;get record count
	SHLD	RCNT		;store it
	LXI	H,0		;zero hl-pair
	SHLD	FCB+33		;reset random record in fcb
	RET

; open file and ready to send

OPENFIL	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
	INR	A
	JNZ	OPENOK
	CALL	ERXIT
	DB	'++ Unable to open file ++','@'

OPENOK	CALL	ILPRT
	DB	CR,LF,'File open: ',0
	LHLD	RCNT		;get record count
	CALL	DECOUT		;print decimal number of records
	CALL	ILPRT
	DB	' (',0
	CALL	DHXOUT		;print records in hex
	CALL	ILPRT
	DB	'H) records   (^X cancels)',CR,LF
	DB	'Send time: ',0
	LXI	H,BTABLE	;point to baud factor table
	MVI	D,0		;clear msb
	LDA	MSPEED		;load speed indicator
	MOV	E,A		;set up for table access
	DAD	D		;index to required factor
	MOV	A,M		;put factor in a-reg
	LHLD	RCNT		;get number of records
	CALL	DIVHLA		;divide hl-pair by value in a (rec/min)
	PUSH	H		;save remainder then..
	MVI	H,0		;..clear msb of hl-pair.
	CALL	DECOUT		;show minutes
	CALL	ILPRT
	DB	' minutes, ',0
	LXI	H,SECTBL	;divisor table for seconds calc
	MVI	D,0
	LDA	MSPEED		;speed factor
	MOV	E,A
	DAD	D		;index into table
	MOV	A,M		;get multiplier
	POP	H		;get remainder
	CALL	MULHA		;multiply contents of h-reg by a-reg
	CALL	SHIFTHL		;shift hl-pair four bits right
	MVI	H,0
	CALL	DECOUT		;show seconds
	CALL	ILPRT
	DB	' seconds at ',0
	LXI	H,SPTBL		;baudrate text table
	MVI	D,0
	LDA	MSPEED		;baudrate factor
	RLC			; *4 offset into..
	RLC			;..baudrate table.
	MOV	E,A		;put speed factor in de-pair
	DAD	D		;add to hl-pair and..
	CALL	TEXTOUT		;..show baudrate.
	CALL	ILPRT		;add tailer
	DB	' baud',CR,LF,0
	RET

; time-to-send and baudrate tables

BTABLE	DB	5,13,19,25,29,49
SECTBL	DB	192,74,51,38,33,20
SPTBL	DB	'110@','300@','450@','600@','710@','1200@'

; close cp/m file

CLOSFIL	LXI	D,FCB		;point to filename
	MVI	C,CLOSE
	CALL	BDOS
	INR	A		; 0ffh --> 00 if close not okay
	RNZ			;return if close successful
	MVI	A,'Q'		;reset quiet flag..
	STA	QFLG		;..and..
	JMP	ERXIT1		;..abort operation.
	
; update record read

RDRECD	LDA	RECINBF		;records in buffer
	DCR	A
	STA	RECINBF
	JM	RDBLOCK
	LHLD	RECPTR
	LXI	D,80H
	CALL	MOVE128
	SHLD	RECPTR		;buffer pointer
	RET

; buffer empty -- read in another block (128 records)

RDBLOCK	LDA	EOFLG
	CPI	1
	STC
	RZ
	MVI	C,0
	LXI	D,DBUF
RDRECLP	PUSH	B
	PUSH	D
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB
	MVI	C,READ
	CALL	BDOS
	POP	D
	POP	B
	ORA	A		;record read okay?
	JZ	RDRECOK		;yes
	DCR	A		; 'eof'?
	JZ	REOF		;yes
	CALL	ERXIT
	DB	'++ File read error ++','@'
RDRECOK	LXI	H,80H
	DAD	D
	XCHG
	INR	C
	MOV	A,C
	CPI	DBUFSIZ*8	;buffer size (128 128-byte records)
	JZ	RDBFULL		;read-buffer full?
	JMP	RDRECLP		;no, loop for another record.

REOF	MVI	A,1
	STA	EOFLG
	MOV	A,C

; buffer full or received 'eof'

RDBFULL	STA	RECINBF
	LXI	H,DBUF
	SHLD	RECPTR
	LXI	D,TBUF
	MVI	C,SETDMA
	CALL	BDOS
	JMP	RDRECD

; update record write

WRRECD	LHLD	RECPTR
	XCHG
	LXI	H,80H
	CALL	MOVE128
	XCHG
	SHLD	RECPTR
	LDA	RECINBF
	INR	A
	STA	RECINBF
	CPI	DBUFSIZ*8 	;buffer size
	RNZ			;ret if not full block

; write block to disk (128 records)

WRBLOCK	LDA	RECINBF
	ORA	A
	RZ
	MOV	C,A
	LXI	D,DBUF
DKWRLP	PUSH	H
	PUSH	D
	PUSH	B
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB
	MVI	C,WRITE
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	ORA	A
	JNZ	WRERR		;write error
	LXI	H,80H
	DAD	D
	XCHG
	DCR	C
	JNZ	DKWRLP
	XRA	A		;reset record..
	STA	RECINBF		;..counter.
	LXI	H,DBUF		;reset buffer..
	SHLD	RECPTR		;..pointer.
	RET

WRERR	MVI	C,CAN
	CALL	SEND
	CALL	ERXIT
	DB	'++ File write error ++','@'

; recv: receive a character.  time-out is in b, in tenth-seconds.
; entry via 'recvdg' deletes line-noise characters.  for example,
; having just sent a record, calling recvdg deletes a line noise
; induced character long before the ack/nak is received.

; time-out routine -- delete line-noise character -- check for abort

RECVDG	CALL	INCHAR
	CALL	INCHAR
RECV	PUSH	D
RECMSEC	LXI	D,113*MHZ	;makes b-reg tenth-seconds
	CALL	CKABORT
RECWLP	CALL	INSTAT 		;test if character received
	JZ	RECEIVE		;get character from line
	DCX	D
	MOV	A,D
	ORA	E
	JNZ 	RECWLP
	DCR	B		;timeout value
	JNZ 	RECMSEC
	POP 	D
	STC 			;carry means time-out occurred
	RET

; receive character from modem

RECEIVE	
	 IF	PMMI
	CALL	INCTRL	 	;get error-status byte
	ANI	ERRCDM   	;check for parity, overrun or framing..
	STA	ERRCDE	   	;..errors, save results.
	 ENDIF			;pmmi

MCHAR	CALL	INCHAR
	POP	D
	PUSH	PSW
	CALL	UPDCRC		;calculate crc value
	ADD	C		;update..
	MOV	C,A		;..checksum.
	LDA	RSEEFLG		;show data and error msg if zero'd
	ORA	A
	JZ	MONIN
	LDA	VSEEFLG		;suppress status messages..
	ORA	A		;..if zero'd, but view ascii text.
	JNZ	NOMONIN
	LDA	DATAFLG
	ORA	A
	JZ	NOMONIN
MONIN	POP	PSW
	PUSH	PSW
 	CALL	SHOW		;display character on crt
NOMONIN	POP	PSW
	ORA	A
	RET

; send character out thru modem

SENDACK	MVI	A,ACK		;send acknowledge
SEND	PUSH	PSW
	LDA	SSEEFLG		;show file as sent
	ORA	A
	JZ	MONOUT
	LDA	VSEEFLG		;view ascii file as sent but..
	ORA	A		;..without status messages.
	JNZ	NOMONOT
	LDA	DATAFLG
	ORA	A
	JZ	NOMONOT
MONOUT	POP	PSW
	PUSH	PSW
	CALL	SHOW
NOMONOT	POP	PSW
	PUSH	PSW
	CALL	UPDCRC		;calculate crc value
	ADD	C		;update..
	MOV	C,A		;..checksum.
SENDW	CALL	OUTSTAT		;test if ready to send
	JNZ	SENDW		;out at baudrate
	POP	PSW
	JMP	OUTCHAR		;send character

; waits for 1st received chararcter (time-out in e-reg) in send mode

WAITNAK	LDA	QFLG		;add 'crlf' and ready msg..
	ORA	A		;..if..
	JNZ	WTNAK1		;..in quiet mode.
	CALL	ILPRTQ		;print crlf
	DB	CR,LF,0
WTNAK1	CALL	ILPRTQ
	DB	'Awaiting ready signal ',0
WAITNLP	CALL	CKABORT
	MVI	B,10		; 1-sec time-out
	CALL	RECV
	CPI	NAK		;checksum (or name nak) or..
	JZ	WAITCK		; (show checksum msg, if not batch mode.)
	CPI	CRC		;..crc request?
	JZ	WAITCRC		;set crc flag and show msg
	DCR	E		;e-reg in seconds
	JNZ	WAITNLP		;loop 'till time-out then..
	JMP	ABORT		;..abort.

WAITCRC	CALL	ILPRT
	DB	'-- CRC request received',CR,LF,0
	XRA	A
	STA	CRCFLG
	RET

WAITCK	LDA	BATCHFLG	;don't show..
	ORA	A		;..if in batch mode.
	RZ
	CALL	ILPRT
	DB	'-- Checksum request received',CR,LF,0
	RET

; file transfer completed

DONE	LDA	BATCHFLG
	ORA	A
	JNZ	DONETC		;branch if wasn't batch mode

; prepare for next file transfer

	LDA	FCB	  	;save drive #
	STA	DISKNO
	LXI	H,FCB	  	;blank out file control block
	CALL	INITFCB
	LDA	DISKNO	  	;put drive number back
	STA	FCB
	LXI	H,RESTRN  	;restore record numbers..
	LXI	D,RECDNOB 	;..for new file transfer.
	MVI	B,RECDNOE-RECDNOB
	CALL	MOVE
	LDA	SENDFLG	  	;go to either send or..
	ORA	A	  	;..receive file, controlled by..
	JNZ	SENDFIL2  	;..the routine setting flag..
	JMP	RCVFIL1	  	;..in multi-file (batch) mode.

; end-of-transfer routine

DONETC	MVI	A,TRUE		;reset multi-file..
	STA	FSTFLG		;..transfer mode.
	CALL	ILPRTQ
	DB	CR,LF,'Transfer completed',CR,LF,BELL,0
DONETCA	EQU	$

	 IF	PMMI
	LDA	EXITFLG		;exit to cp/m with..
	ORA	A		;..disconnect and reboot?
	JZ	PEXIT		;yes
	LDA	DISCFLG		;disconnect when finished?
	ORA	A		;yes, if zero.  disconnect..
	JZ	DISCON1		;..and go to command line.
	 ENDIF			;pmmi

DONETCB	MVI	A,CRC
	STA	CRCFLG		;turn off 'crc' option
	MVI	A,'Q'		;reset the flag to normal
	STA	QFLG
	MVI	A,TRUE
	STA	FIRSTME		;set 'first-time' flag
	LDA	ABORTFLG	;came here from a timeout?
	ORA	A
	JNZ	MENU		;if yes, go to command mode.
	LDA	TERMFLG		;see if return to..
	ORA	A		;..terminal mode..
	JZ	TERM		;..after x'fer.
	JMP	MENU		;else, go to cmd line.

; c p m

; leave comm7 program

PREEXIT	
	 IF	PMMI
	LDA	LINEFLG		;..if telephone not connected.
	ORA	A
	JZ	EXIT
	CALL	ILPRT
	DB	CR,LF,LF,'Exit to CP/M with telephone line '
	DB	'connected?  (Y/N): ',0
	CALL	RESPOND
	CPI	'N'		;exit with line connected?
	JNZ	EXIT		;no, with line disconnected.  any..
PEXIT	CALL	DISCONN		;..other character simply exits to cp/m.
	 ENDIF			;pmmi

EXIT	LDA	O$USR		;restore original..
	CALL	SET$USR		;..user area and..
	LXI	D,TBUF		;..tidy up before..
	MVI	C,SETDMA
	CALL	BDOS		;..leaving comm7.
	CALL	STAT		;flush any character..
	MVI	C,RDCON		;..remaining..
	CNZ	BDOS		;..in bdos.
	CALL	CRLF		;exit to cp/m with a fresh line
	LDA	EXITFLG		;warm boot if 'e' secondary..
	ORA	A		;..option..
	JZ	WBOOT		;..requested.
	LDA	SAVCCP		;see if 'ccp' saved
	ORA	A
	JZ	WBOOT		;no, noisily warm boot.  else..
	LHLD	STACK		;..restore cp/m stack by..
	SPHL			;..hl/sp-pair swap then..
	RET			;..return quickly to cp/m 'ccp'.

	LINK	COMM723B	;chains to 'comm723b.asm' using lasm.com
