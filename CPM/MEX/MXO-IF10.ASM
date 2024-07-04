	Title	'MEX overlay for 6850 + SMDM VERSION 1.0'

REV	EQU	10		;overlay revision level

;  MEX  SMDM + 6850 OVERLAY VERSION 1.0:  written 5/20/84 by JOHN ROHNER

; This is a MEX overlay file for the SMART modem AND 6850 UART.
; THIS OVERLAY WWRITTEN FOR INFORMER COMPUTERS OR ANY 6850 UART.
; You can use it as a model for designing your own modem overlay (or 
; you can use any existing MDM7 overlay, if available).

; Misc equates

NO	EQU	0
YES	EQU	NOT NO
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9

; UART port definitions
;	Set base port for 6850 UART

PORT	EQU	02H		;UART base port (data or status)

;  modem control/status	register

MOCTLP	EQU	PORT		; modem	control	port
MODCT1	EQU	PORT		;modem control port

SPORT	EQU	PORT		; modem	status port
MODCT2	EQU	PORT		;modem status port
BAUDRP	EQU	PORT		;modem baud rate port

;  modem data register

DPORT	EQU	PORT+1		;  modem data port
MODDAT	EQU	PORT+1		;modem data port

; UART bit definitions

MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	02H		;modem send bit
MDSNDR	EQU	02H		;modem send ready bit

;  modem control bits

MOCTLI	EQU	16H		; UART initial setting
MOBDM	EQU	03H		; baud rate bits (/16,/64)
MOBD30	EQU	02H		; 300 baud rate	(/64)
MOBD12	EQU	01H		; 1200 baud rate (/16)
MOBRKM	EQU	60H		; send break bits
MONBRK	EQU	00H		; no break
MOSBRK	EQU	60H		; send break

;  modem status	bits

MODSRB	EQU	00H		; data set ready bit (nonexistent)
MORCVB	EQU	01H		; modem	recieve	bit
MOSNDB	EQU	02H		; modem	send bit
MODCDB	EQU	04H		; data-carrier-detect bit
MOCTSB	EQU	08H		; clear-to-send	bit
MOFERB	EQU	10H		; framing error	bit
MOOVRB	EQU	20H		; data overrun error bit
MOPERB	EQU	40H		; parity error bit
MOSTSB	EQU	07FH		; main status 
MOSTSI	EQU	MORCVB OR MOSNDB ; inversion

;MEX SUBROUTINE CALL VECTORS

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

	DS	3		;MEX has a JMP START here

; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.

PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	25		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		;sets display time for sending a file
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
BAKFLG:	DB	YES		;yes=make .BAK file
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

; Equates used only by 6850 routines grouped together here.

CTLSTS:	DB	MOCTLI		;CURRENT UART STATUS WORD
	DB	0		;not used

; Low-level modem I/O routines: (you can insert jumps here to longer
; routines if you'd like ... 

INCTL1:	IN	SPORT		;in modem control port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI

OTDATA:	OUT	DPORT 		;out modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI

INPORT:	IN	DPORT 		;in modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI

; Bit-test routines.  

MASKR:	ANI MORCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MOSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready

; Unused area: used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.

	DS	12

; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.  

LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX

DIALV:	DS	3		;dial digit in A (see info at PDIAL)
DISCV:	DS 	3		;disconnect the modem
GOODBV:	DS	3		;called before exit to CP/M
INMODV:	JMP	MDINIT		;initialization. Called at cold-start
NEWBDV:	JMP	NEWBAUD		;set baud rate
NOPARV:	DS 	3		;set modem for no-parity
PARITV:	DS	3		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	DS	3		;send a break

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

CLREOS:
	MVI	C,ILP
	CALL	MEX
	DB	'L'-40H,0
	RET
	NOP

CLS:
	MVI	C,ILP
	CALL	MEX
	DB	'L'-40H,0
	RET

SYSVER:	MVI	C,ILP
	CALL	MEX
	DB	'INFORMER IV VERSION W/SM'
	DB	CR,LF,0

;	*** END OF FIXED FORMAT AREA ***


MDINIT: RET

NEWBAUD:
	CPI	1
	JZ	SET300
	CPI	5
	JZ	SET1200
	RET

;SET BAUD RATE 300 OR 1200 NO OTHERS SUPPORTED

;   set	1200 baud

SET1200	LDA	CTLSTS		; get present control register value
	ANI	NOT MOBDM	; clear	away baud bits
	ORI	MOBD12		; add 1200 baud	setting
	STA	CTLSTS		; save last control register
	OUT	SPORT		;SEND IT
	MVI	A,5		;RESET MSPEED 
	JMP	SETBEND

;  set 300 baud

SET300	LDA	CTLSTS		; get present control register value
	ANI	NOT MOBDM	; clear	away baud bits
	ORI	MOBD30		; add 300 baud setting
	STA	CTLSTS		; save last control register
	OUT	SPORT		;SEND IT
	MVI	A,1
SETBEND:
	STA	MSPEED		;RESET MSPEED INDICATOR

	IF SMODEM
	LXI	H,ATMSG		;LET SMARTMODEM KNOW
	CALL	SMSEND
	MVI 	B,20   		;TWO second delay needed by Smartmodem
	MVI	C,TIMER		;SET TIMER
	CALL	MEX		;WAIT
	ENDIF		;SMARTMODEM

	RET

	IF SMODEM
ATMSG	DB	'AT',CR,0
	ENDIF		;SMODEM

;THIS IS AN EXAMPLE OF THE POWER AVAILABLE USING SET
; THIS EXAMPLE: SET (GIVES  CURRENT BAUD RATE) SET 300 OR 
;	SET 1200 SETS BAUD RATE TO 300 OR 1200
;	SET INIT INITIALIZES THE SMARTMODEM (TO RESET THE BYE SET)

SETCMD:
	MVI	C,SBLANK	;ANY ARGUMENTS?
	CALL	MEX
	JC	TELL		;NO DISPLAY BAUD RATE
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;FIND COMMAND
	PUSH	H
	RNC			;GOTO COMMAND
	POP	H		;NO SUCH COMMAND
	MVI	C,ILP		;AVAILABLE
	CALL	MEX		;INFORM USER OF SAME
	DB	CR,LF,'NO COMMAND AVAILABLE',CR,LF,0
	RET

CMDTBL:
	DB	'30','0'+80H
	DW	SET300
	DB	'120','0'+80H
	DW	SET1200

	IF   SMODEM
	DB	'INI','T'+80H
	DW	SMINIT
	ENDIF

	DB	0

TELL:
	MVI	C,ILP
	CALL 	MEX		;DISPLAY BAUD RATE
	DB	CR,LF,'BAUD RATE CURRENTLY IS:  ',0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX
	RET	

	IF SMODEM
SMINIT:
	MVI	A,MOBDM		;Reset 6850 
	OUT	SPORT
	MVI	A,MOCTLI	;RESET TO 300 BAUD DTR ON
	OUT	SPORT
	STA	CTLSTS		; save last control register
	MVI	A,5		;TELL MSPEED ABOUT IT
	STA	MSPEED
	LXI	H,RSTMSG	; RESET MESSAGE 
	CALL	SMSEND		;No Delay - RESET
	MVI 	B,20   		;TWO second delay needed by Smartmodem
	MVI	C,TIMER		;SET TIMER
	CALL	MEX		;WAIT
	LXI	H,MINIT		;INITIALIZATION MESSAGE
	CALL	SMSEND		;Set Smartmodem for next call
	JMP	TELL		;Return

; SMARTMODEM UTILITY ROUTINE: SEND STRING TO MODEM

SMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	SMSEND

; DATA AREA
RSTMSG:	DB	'AT Z',CR,0	;Do smartmodem default reset
MINIT:	DB	'AT Q0 E1 M1 X1 S7=30',CR,0
	ENDIF

	END
