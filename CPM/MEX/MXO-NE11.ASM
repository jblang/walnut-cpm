; MXO-NE11.ASM - NEC PC-8001A OVERLAY FILE FOR MEX10. 25 MAY 1984
;
REV	EQU	11			;overlay revision level
;
; This file adapts the NEC PC-8001A/Smartmodem 1200 to the MEX modem program.  
; You must use Chan 1 RS232 port and set the port internally for 1200 baud. 
; This overlay converts to MEX and no longer fits all features of MDMxx as
; rewritten.
;
; TO USE:  Edit this overlay file as you prefer - then assemble it.
;        	ASM MXO-NE10			;use ASM
;          Patch MEX with the resulting hex file using MLOAD.
;               MLOAD YOURNAME.COM=MEX10.COM,MXO-NE11
;          Patch YOURNAME with the Smartmodem hex file if needed.
;	        MLOAD YOURNAME.COM=YOURNAME.COM,MXO-SM1x
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 05/25/84 - Converted from MDM7xx to MEX10     - David Poskie
; 11/11/83 - Renamed to M7NE-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed for use with MDM712	- Irv Hoff
; 07/01/83 - Revised for use with MDM711	- Irv Hoff
; 06/22/83 - Revised for use with MDM710	- Irv Hoff
; 06/22/83 - Altered for use with MDM710	- Irv Hoff
; 06/22/83 - Altered MDM708DP for the NEC 8001
;	     computer using an external modem	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
TAB:		EQU	09H		;horizontal tab
TPA:		EQU	100H		;start of RAM
;
YES:		EQU	0FFH
NO:		EQU	0
;
PORT:		EQU	0C0H		;NEC PC-8001 serial port
MODCTL1:	EQU	PORT+1		;Modem status port
MODCTL2:	EQU	PORT+1		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODRCVB:	EQU	02H		;Modem receive bit
MODRCVR:	EQU	02H		;Modem receive ready bit
MODSNDB:	EQU	01H		;Modem send bit
MODSNDR:	EQU	01H		;Modem send ready bit		
;
; MEX service call processor equates
;
MEX		EQU	0D00H		;MEX service call processor address
INMDM		EQU	255		;get char from port to A,
					;CY=no more in 100ms
TIMER		EQU	254		;delay 100ms * reg B
TMDINP		EQU	253		;B=# secs to wait for char,cy=no char
CHEKCC		EQU	252		;check for ^C frm kybd,Z=present
SNDRDY		EQU	251		;test modem-send ready
RCVRDY		EQU	250		;test modem-receive ready
SNDCHR		EQU	249		;send char to modem (after SNDRDY)
RCVCHR		EQU	248		;rcv a char from modem (after RCVRDY)
LOOKUP		EQU	247		;table search (see CMDTBL comments)
PARSFN		EQU	246		;parse filename from input stream
BDPARS		EQU	245		;parse baud-rate from input stream
SBLANK		EQU	244		;scan input stream to next non-blank
EVALA		EQU	243		;evaluate numeric from input stream
LKAHED		EQU	242		;get next char w/o removing from input
GNC		EQU	241		;get char from input,cy=1 if none
ILP		EQU	240		;inline print
DECOUT		EQU	239		;decimal output
PRBAUD		EQU	238		;print baud-rate
;	
CONOUT		EQU	2		;simulated BDOS function 2:con char out
PRINT		EQU     9		;simulated BDOS function 9:print string
INBUF	        EQU	10		;input buffer,same structure as BDOS 10
;
		ORG	TPA	;here we go
;
		DS	3	;(for  "JMP   START" instruction)
;
PMODEM:		DB	NO	;yes=PMMI S-100 Modem			103H
SMODEM:		DB	YES	;yes=HAYES Smartmodem			104H
TPULSE:		DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz *10, 25.5 MHz max.	106H
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BB's
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default extra wait after CRLF in terminal
				; mode file transfer for slow BB's
COLUMS		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-defined SET Command		10BH
SCRTEST:	DB	YES	;cursor control routine 		10CH
RETRY:          DB      YES     ;reset error count after 10 consec.errors
BAKFLG:		DB	NO	;yes=change any file same name to .BAK  10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBK:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLLF:		DB	YES	;yes=allow toggling LF after CR		114H
TRNLOG:		DB	YES	;yes=allow logon transmission 		115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:  	DB	YES	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling LOCONEXTCHR		118H
LSTTST:		DB	NO	;no=using modem on printer port	        119H
XOFTST:		DB	YES	;yes=chcks for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWT:  	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
		DS	2       ;not used by MEX			128H
;
;low level modem I/O routines.
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port
		DS	7
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data port
		DS	7		
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port
 		DS	7
ANI$MODRCVB	ANI	MODRCVB ! RET	;test bit for receive ready
ANI$MODRCVR	CPI	MODRCVR ! RET	;receive bit value when ready
ANI$MODSNDB	ANI	MODSNDB ! RET	;test bit for send ready
ANI$MODSNDR	CPI	MODSNDR ! RET	;send bit value when ready
		DS      12
;
LOGON		DS	2		;req for MDM compat, not ref by MEX
DIALV:		DS	3
DISCV:		JMP	DISCON
GOODBYV:	JMP	GOODBY		;called before exit to CP/M
INMODV:		JMP	NITMOD		;cold-st user-written routine   16BH
NEWBAUDV:	JMP	NEWBAUD		;sets baud-rate 
		RET	! NOP ! NOP	;bypasses PMMI routine
		RET	! NOP ! NOP	;bypasses PMMI routine
SETUPV:		JMP	SETCMD		;SET command			177H
SPMENV:		DS	3		;not used with MEX		17AH
VERSNV:		JMP	VERSN 		;shows overlay version in sign-on 
BREAKV:		JMP	SBREAK		;send a break			180H
;
;  NOTE: For MEX compatibility, don't use these next 6 routines.  
;  Use the MEX service call processor routines instead.
;  Do not change the following six routines.
;                                     vv REPLACE WITH: vv  
ILPRTV:		DS	3		;MEX funct 9			183H
INBUFV:		DS	3		;MEX funct 10			186H
INCMPV:		DS	3		;table lookup funct 247		189H
INMDMV:		DS	3		;MEX funct 255			18CH
NXSCRV:		DS	3		;not supported (returns NOP)	18FH
TIMERV:		DS	3		;MEX funct 254			192H
;
CLREOS:		MVI	C,ILP
		CALL	MEX
		DB	ESC,59H,0,0,0
		RET
;
CLS:		MVI	C,ILP
		CALL    MEX
		DB      1EH,ESC,59H,0,0
		RET
;
;  end of fixed area
;.....
;
VERSN:		MVI	C,ILP
		CALL	MEX
		DB 	'NEC PC-8001A <+> SMARTMODEM 1200 '
		DB	REV/10+'0'
		DB	'.'
		DB	REV MOD 10+'0'
		DB	CR,LF,0
		RET
;		
;-----------------------------------------------------------------------
;
; NOTE:  You can change the VERSN message to be longer or shorter.  The
;	 point is to be done with this overlay by 0B00H if using a 
;	 Smartmodem or by 0D00H otherwise.
;
;=======================================================================
;
; This routine allows sending a 300 ms. break tone to reset some
; time-share computers.
;
SBREAK:	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,1FH		;send a break tone 
	  JMP	GOODBY1
;.....
;
; This routine sets DTR low and sends a 300 ms. break tone 
; to disconnect some modems (e.g. Bell 212A)	
;
DISCON:	  MVI   A,5
	  OUT   MODCTL1		;send break
	  MVI	A,15H		;turn off DTR

GOODBY1:  OUT	MODCTL1		;send to status port 
	  MVI	B,3		;wait 300 ms
	  MVI   C,TIMER
	  CALL  MEX
GOODBY:   MVI   A,5
	  OUT   MODCTL1
	  MVI	A,07H		;normal send/receive with DTR
	  OUT	MODCTL1		;send to status port
	  RET
;.....
;
; NEC PC-8001 initialization -- sets the 8251A for 8 bits, 1 stop pulse,
; DTR high.   Requires dip switche be set internally to 1200 baud then
; divides by 64 for 300, or by 16 for 1200 baud via "SET" command.  Set
; now to default at 1200 baud.
;
NITMOD:   MVI	A,5		;1200 baud transfer time
	  STA	MSPEED	
	  MVI	A,087H		;insure out of mode 
	  OUT	MODCTL1		;modem status port 
	  OUT	MODCTL1		;slight delay
	  MVI	A,4EH		;initialize USART
	  OUT	MODCTL1		
;
NITMOD1: MVI	A,4EH		;default - divide by 16 for 1200 baud
	  OUT	MODCTL1		;modem status port
	  MVI	A,17H		;DTR, RCV, XMT, ERROR reset
	  OUT	MODCTL1		
	  IN	PORT		;clear data port
	  RET
;.....
;
SETCMD	  MVI   C,SBLANK	;any argument?
	  CALL  MEX
	  JC    TELL		;if not, display baud-rate
	  LXI   D,CMDTBL
	  MVI   C,LOOKUP 
	  CALL  MEX		;parse argument
	  PUSH  H      		;save any parsed argument adr on stack
	  RNC                   ;if argument, return to it
          POP   H		;OOPS, argument not found in table
SETERR:	  MVI   C,ILP           ;inline print
	  CALL  MEX 		;say input not valid
	  DB	CR,LF,'++ Invalid SET Command ++',CR,LF,BELL,0
	  RET
;
CMDTBL:   DB	'30','0'+80H
	  DW    OK300
	  DB	'120','0'+80H
	  DW    OK1200
	  DB	0
;
TELL:	  MVI	C,ILP
	  CALL  MEX		;print current baud-rate
          DB    CR,LF,'Baud-rate is now: ',0
	  LDA	MSPEED
	  MVI   C,PRBAUD
	  CALL  MEX
	  RET
;		
OK300:	  MVI	A,1		
	  MVI	B,4FH		;divide by 64 for 300 baud
	  JMP	LOADBD		;go load it
;
OK1200:	  MVI	A,5
	  MVI	B,4EH		;divide by 16 for 1200 baud
;
;
LOADBD:	  STA	NITMOD+1	;change time-to-send to match baud-rate
	  MOV	A,B		;get baud-rate byte
	  STA   NITMOD1+1	;store in NITMOD
	  JMP	NITMOD		;reinitialize to new baud-rate and done
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
NEWBAUD:  CPI   1
	  JZ    OK300
	  CPI   5
	  JZ    OK1200
	  RET   
;.....
;	       (END OF NITMOD AND SETUP ROUTINES)
;=======================================================================
;
;
; NOTE:  ABOVE WHEN ASSEMBLED MUST TERMINATE BEFORE 0B00H WITH A 
;	 SMARTMODEM & BEFORE 0D00H WITHOUT.
;
;=======================================================================
;
 	END
;
