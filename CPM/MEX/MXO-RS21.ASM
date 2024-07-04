;   Title    'MEX overlay for the TRS-80 MOD IV version 2.1'	
;                      Montezuma Micro CP/M 2.2
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; MEX TRS-80 MOD IV OVERLAY VERSION 1.0: Written 09/10/84 by Ed Richter 
;
; VERSION 2.1 08/06/86 - Correct modem control to properly handle changes
;			 in word length, parity, and stop bits.  Changes
;			 to these parameters by the SET command were never
;			 communicated to the UART.
;
; VERSION 2.0 10/06/85 - Change to the printer status routine.  Now
;			 checks all four possible printer states.
;			 Ver.114 changed ^C address from AUTO ANSWER.
;			 Added code at STANS to find the correct 
;			 address.
;					        Ed Richter 
;						71455,1133
; VERSION 1.9 09/12/85 - Minor change to eliminate some un-necessay
;			 code when using the AUTO ANSWER mode. See
;			 NOMXOSM.
;						Ed Richter
; VERSION 1.8 05/05/85 - Included the changes from the file 
;			 MXO-RS17.FIX. The baud rate detect now works.
;						Ed Richter
; VERSION 1.7 01/25/85 - ^C in "auto-answer now aborts to CPM, not
;			 MEX.(sorry bout that one) Added code to
;			 determine baud rate in "auto-answer".
;			 Changed "NITMOD" to default  to the baud 
;			 rate selected by "MSPEED"     
;						Ed Richter
; VERSION 1.6 01/21/85 - A system reset seems a little drastic
;                        so added code for a ^C abort to auto
; 			 answer. Also added "number of rings" 
;			 equate.
;						 Ed Richter
; VERSION 1.5 11/17/84 - Added SET ANSWER ON command
;			 (For Hayes-compatible modems
;			  only...see NOTE below.)
;						Thom Foulks
; VERSION 1.3 10/10/84 - Fixed bug in the Printer ready test
;                                                 Ed Richter
; VERSION 1.2 09/18/84 - Added the comments to 1.1 and changed the
;			 configuration of the SET message that is
;			 output to the console
;						   Ed Richter 
; VERSION 1.1 09/16/84 - Added code to fully control the SIO USART
;		         via the SET command. This overlay now 
;			 supports-- SET BAUD -- SET PARITY --
;			 SET STOP BITS -- SET WORD LENGTH --
;                                                   Ed Richter
; 
; This file was derived from the MDM7xx overlay M7R4-5.ASM, and the 
; file MXOPM10.ASM. It is a MEX overlay for use with the TRS-80 MOD
; IV, and an external modem. It has a SET command that supports 300
; though 9600 baud.
;
; The SMARTMODEM, and compatibles will answer the phone at the
; incoming caller's baud rate .This makes it necessary to insure
; that the SIO-USART is configured to the same speed. This progam
; will answer the phone at the MSPEED baud rate. If it cannot
; read characters at that speed it will start at 110 baud (BAUD vector 
; set to 0), check for a CR, LF, or ^C. If it is unable to read a
; character at that speed it will increment the baud rate to 1200
; (the - CPI '6' - in the TSTBAUD routine), and retry at each step.
; To change the upper limit (1200) change the  CPI '6' to the MSPEED
; value +1. ie., CPI '10' for 19200.
;
; NOTE: This overlay must be used in congunction with MXO-SM11.ASM
; for full modem control.  The SET ANSWER command will place MEX
; into an auto-answer mode which may be exited prior to execution
; with a ^C - CONTROL C -  it's intended for use with a READ file
; similar to Bruce Morgen's WELCOME3 or WELCOME4.
;                                      - Thom Foulks
;
; Rev 19 Note: If you are using a SMARTMODEM and MXO-SMxx.ASM, the
; SMSEND and DISCON routines in this overlay can be deleted. Use
; matching one's in MXOSMxx.ASM  by deleting the END statement
; for this overlay, and appending the SMARTMODEM overlay to this one.
; Assemble both as 1 file and load the resulting HEX file to MEX.COM
;					- Ed Richter 
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
REV:	 	EQU	21
;
CR:		EQU	0DH	;carriage return
LF:		EQU	0AH	;linefeed
ONV:		EQU	0FH	;reverse video on
INV:		EQU	0EH	;reverse video off
TPA:		EQU	0100H	;start of program
TAB:		EQU	09H	
YES:		EQU	0FFH	;true
NO:		EQU	0	;not true
RING:		EQU	'2'	;number of rings for auto-answer
;
NOMXOSM:	EQU	YES	;NO =  MXO-SMxx.ASM appended to this file. 
;
; NOTE..If you are using the DISC equate in MXO-SMxx.ASM set to NO for
;       disconnect with DTR, then this equate must be set to YES.
;       This equate, if used, will save the space used for the DTR 
;	DISCON, and the SMSEND routines used in this overlay.  
;
; Change the following information to match your equipment.
; PORT should be set to the base port address for the RS-232 port.
;
PORT:		EQU	0E8H	;master reset port   
MODCT1:		EQU	PORT+2	;modem control port
MODDAT:		EQU	PORT+3	;modem data in port
MODCT2:		EQU	PORT+2	;not used mod iv
BAUDRP:		EQU	PORT+1	;baud rate port
MDRCVB:		EQU	080H	;bit to test for receive
MDRCVR:		EQU	080H	;value when ready
MDSNDB:		EQU	040H	;bit to test for send
MDSNDR:		EQU	040H	;value when ready

;
; UART Control Bit Configuration
;
U$WRD5:		EQU	000H	;Word length of 5 bits
U$WRD6:		EQU	040H	;Word length of 6 bits
U$WRD7:		EQU	020H	;Word length of 7 bits
U$WRD8:		EQU	060H	;Word length of 8 bits
U$PRON:		EQU	000H	;Parity ON
U$PROF:		EQU	008H	;Parity OFF
U$PREV:		EQU	080H	;Parity EVEN
U$PROD:		EQU	000H	;Parity ODD
U$STP1:		EQU	000H	;Stop bits 1
U$STP2:		EQU	010H	;Stop bits 2
U$XMIT:		EQU	004H	;Set to enable transmit
U$RTS:		EQU	002H	;Set for RTS
U$RTSO:		EQU	000H	;Clear to turn on RTS
U$DTR:		EQU	001H	;Set for DTR off
U$DTRO:		EQU	000H	;Clear to turn on DTR
;
;	Default UART configurations and bit masks
;
DEFCTB:		EQU	U$PROF+U$PREV+U$WRD8+U$STP1+U$DTRO+U$XMIT+U$RTSO
DFBAUD:		EQU	6	;0=110 1=300 2=450 3=600 4=710 5=1200	
				;6=2400 7=4800 8=9600 9=19200 default
DFBAUD:		EQU	6		;Default start speed (6=2400)
CTSMSK:		EQU	020H		;carrier detect mask
ISOCD:		EQU	0DFH		;port ready mask
PRPORT:		EQU	0F8H		;printer port
PRSTAT:		EQU	0F0H		;printer ready mask
BRKMSK:		EQU	0FFH-U$XMIT	;send break
DTRMSK:		EQU	0FFH-U$DTR-U$RTS ;drop dtr

;
;MEX SERVICE PROCESSOR STUFF
;
MEX:		EQU	0D00H	;address of the service processor
INMDM:		EQU	255	;get char from port,CY=no more in 100ms
TIMER:		EQU	254	;delay 100 ms * reg b
TMDINP:		EQU	253	;b=# secs to wait for char,CY=no char
CHEKCC:		EQU	252	;check for ^C from kbd, Z=present
SNDRDY:		EQU	251	;test for modem-send ready
RCVRDY:		EQU	250	;test for modem-receive ready
SNDCHR:		EQU	249	;send to modem (after SNDRDY)
RCVCHR:		EQU	248	;recv a char from modem after (RCVRDY)
LOOKUP:		EQU	247	;table search: see CMDTBL for info 
PARSFN:		EQU	246	;parse filename from input stream 
BDPARS:		EQU	245	;parse baud-rate from input stream
SBLANK:		EQU	244	;scan input stream to next non-blank
EVALA:		EQU	243	;evaluate numeric from input stream
LKAHED:		EQU	242	;get nxt char w/o removing from input
GNC:		EQU	241	;get char from input, CY=1 if none
ILP:		EQU	240	;inline print
DECOUT:		EQU	239	;decimal output
PRBAUD:		EQU	238	;print baud rate
CONOUT:		EQU	2	;simulated BDOS funct 2:CONSOLE OUT
PRINT:		EQU	9	;simulated BDOS funct 9: PRINT STRING
INBUF:		EQU	10	;input buffer, same as BDOS FUNCT 10
;
		ORG	0D11H	;install printer ready test
		DW	PRTSTS
; 
		ORG	TPA
;
;
		DS	3	;(for  "JMP   START" instruction)
PMODEM:		DB	NO	;Not used by MEX			103H
SMODEM:		DB	NO	;Not used by MEX
TPULSE:		DB	'T'	;Not used by MEX 			105H
CLOCK:		DB	50	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	DFBAUD	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	0	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	0	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	4	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DS	1	;reserved (old ACKNAK flag)		10DH
BAKFLG:		DB	YES     ;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
XOFTST:		DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	YES	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'K'-40H	;^K = Send 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40h	;^^ = Send next character		127H
		DS	2
INCTL1:		JMP     STATSND	;go to "get status" 			12AH
		DS	7
OTDATA:		OUT	MODDAT  ! RET	;out modem data port		134H
		DS	7
INPORT:		IN	MODDAT  ! RET	;in modem data port
		DS	7
MASKR:		ANI	MDRCVB	! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR	! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB	! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR	! RET	;value of send bit when ready	151H
		DS	12		;unused by MEX
LOGON:		DS	2		;for user message		160H
DIALV:		DS	3		;autodial rtn jump		162H
DISCV:		JMP	DISCON		;disconnect rtn
GOODBV:		DS	3		;not needed			168H
INMODV:		JMP	NITMOD		;go to user written routine	16BH
NEWBDV:		JMP	PBAUD		;set new baud-rate   		16EH
NOPARV:		DS	3		;(by-pass PMMI routine)		171H
PARITV:		DS	3		;(by-pass PMMI routine)		174H
SETUPV:		JMP	SETCMD		;initialize USART and modem	177H
SPMENV:		DS	3		;not used with MEX		17AH
VERSNV:		JMP	SYSVER		;print header msg		17DH
BREAKV:		JMP	PBREAK		;send header			180H
; Do not change the following six lines.
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
ILCMPV:		DS	3		;				189H
INMDMV:		DS	3		;				18CH
NXSCRV:		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		LXI	D,EOSMSG	;clear to end of screen         195H
		MVI	C,PRINT		;from cursor
		CALL	MEX		;				198H
		RET			;				19DH
;
CLS:		LXI	D,CLSMSG	;clear sreen			19EH
		MVI	C,PRINT
		CALL	MEX		;				1A1H
		RET			;				1A6H
	
;
SYSVER:		LXI	D,SOMESG	;print the sys version msg	1A7H
		MVI	C,PRINT
		CALL	MEX		
		CALL	CRLF		
;
CARRSH		LXI	D,NOMESG	;no carrier present msg
		CALL	CARRCK
		MVI	C,PRINT
		CNZ	MEX		;print if no carrier
		LXI	D,CARMSG	;carrier present
		MVI	C,PRINT
		CALL	MEX		;say so and continue
		RET
;
; Send a break tone to reset some time-share computers.
;
PBREAK:		LDA	CURURT		;Get modem control bits
		ANI	BRKMSK		;send break
		OUT	MODCT1
	  	MVI	B,3		
	  	MVI	C,TIMER
	  	CALL	MEX		;delay 300 msec
		LDA	CURURT		;Get current bits
	  	OUT	MODCT1
 		RET
;
; Routine to return status of the modem port
;
STATSND:	IN	MODCT1		;in modem contol port
		PUSH 	B		;just in case
		ANI	ISOCD		;isolate status and clear CD bit
		MOV	B,A		;save status
		IN 	PORT		;get CD bit
		ANI	CTSMSK		;isolate CD bit
		ORA	B		;merge CD with status
		POP	B		;restore B
		RET
;
; This routine will hang up the phone by dropping DTR.
;*****************************************************************************
;---THIS CODE IS USED IF NOMXOSM = YES, AND THE MXO-SMxx.ASM OVERLAY
;---IS SET FOR DISCONNECT WITH DTR, OR A SMARTMODEM IS NOT USED
;*****************************************************************************
;
		IF	NOMXOSM
DISCON:	  	LDA	CURURT		;Get current modem bits
		ANI	BRKMSK
		ORI	U$DTR+U$RTS	;Shut off DTR
          	OUT	MODCT1		;send cmd
	  	MVI	B,5		
	  	MVI	C,TIMER
	  	CALL	MEX		;delay 500 msec
		LDA	CURURT		;Get current bits
	  	OUT	MODCT1
	  	RET
		ENDIF			;NOMXOSM = YES
;
;
; This area resets the SIO-UART DTR reinitializes all control parameters
;
NITMOD:	  	MVI	A,1
	  	OUT	PORT		;reset the USART to
SETURT:	  	LDA	CURURT		;8,no,1,DTR, and RTS
	  	OUT	MODCT1
		LXI	H,MSPEED
		MOV	A,M		;initalize to MSPEED baud rate
		CALL	PBAUD		;get baud rate
	  	RET			;also change the value of MSPEED
;
;  Sets the modem speed via the SET COMMAND.
;
SETCMD:		MVI	C,SBLANK	;any arguments
		CALL	MEX
		JC	SETSHO		;if not print out values
		LXI	D,CMDTBL	;parse commands
		CALL	TSRCH		;from table
		PUSH	H		;address on stack
		RNC			;if yes then execute it
		POP	H		;no fix stack
SETERR:	  	LXI	D,SETEMS	;no then print error
	  	MVI 	C,PRINT
	  	CALL	MEX
	  	RET
CMDTBL:		DB	'?'+80H		;"set ?"
		DW	STHELP
		DB	'BAU','D'+80H	;"set baud ?'
		DW	STBAUD
		DB	'WOR','D'+80H	;set word length
		DW	STWORD
		DB	'PARIT','Y'+80H ;set parity
		DW	STPAR
		DB	'STO','P'+80H	;set stop bits
		DW	STSTOP
                DB   	'ANSWE','R'+80H ;set auto-answer on
		DW	STANS
		DB	0	
SETSHO:		CALL	CLS		;clear screen
		CALL	SETURT		;Set up UART control
		CALL	CARRSH		;carrier present
		LXI	H,SHOTBL	;show subroutines table
SETSLP: 	MOV	E,M		;get table address
		INX	H
		MOV	D,M
		INX	H
		MOV	A,D		;end of table
		ORA	E
		RZ			;exit if yes
		PUSH	H		;save table pointer
		XCHG			;addrs to HL
		CALL	GOHL		;do it
		CALL	CRLF		;print newline
		MVI	C,CHEKCC	;check for console abort
		CALL	MEX		
		POP	H		;its done
		JNZ	SETSLP		;continue if no abort
		RET
GOHL:		PCHL
SHOTBL:		DW	BDSHOW		;table
		DW	PARSHOW
		DW	WLSHOW
		DW	STSHOW
		DW	0
STHELP:		LXI	D,HLPMSG	;print help message
		MVI	C,PRINT
		CALL	MEX
		RET
STBAUD:		MVI	C,BDPARS	;MEX find baud rate		
		CALL	MEX
		JC 	SETERR		;none then exit
		CALL    PBAUD		;valid baud rate then set it
		JC 	SETERR		;exit if not supported by overlay
BDSHOW:		CALL	ILPRT
		DB	'Baud Rate:',TAB,' ',0
		LDA	MSPEED		;get MSPEED to determine present
		MVI	C,PRBAUD	;baud rate
		CALL	MEX
		RET	
STPAR:		LXI	D,PARTBL	;find parity function requested
		CALL	TSRCH
		PUSH	H
		RNC			;execute it
		POP	H
		JMP	SETERR		;not valid then say so 				
STWORD:		LXI	D,WLTBL		;find word length function requested
		CALL	TSRCH
		PUSH	H
		RNC			;execute it
		POP	H
		JMP	SETERR		;not valid then say so
STSTOP:		LXI	D,STTBL		;find how many stop bits 
		CALL	TSRCH
		PUSH	H
		RNC			;execute it
		POP	H
		JMP	SETERR		;not valid then say so 
STANS:          CALL	CLS		;clear the screen
		PUSH    H		;save H
		LXI	H,ANSON		;get the set command
		CALL	SMSEND		;send it
		POP	H
		CALL	CRLF		;get ready for msg
		CALL	CRLF
		LXI	D,ANSMSG	;and tell us about it
		MVI	C,PRINT
		CALL	MEX
		LHLD	0101H		;pointer to start 
		LXI	D,005		;offset to SP address
		DAD	D		;for ^C abort
		MOV	A,M		;get 1st byte
		STA	BOOT+1		;store it
		INX 	H		;next address
		MOV 	A,M		;get 2nd byte
		STA	BOOT+2		;store it
WAITCD:		CALL	INPORT		;to  clear garbage
		CALL	CARRCK		;check for carrier
		JZ	TSTBAUD		;yes - go check baud rate...
		MVI	C,CHEKCC	;no check for ^C
		CALL	MEX
		JNZ	WAITCD		;no carrier, no ^C so try again
BOOT:		LHLD	0000		;^C -load CPM return address from
					;stack pointer storage 
		SPHL			;put it in the stack pointer
		RET			;and go to CPM
TSTBAUD:	CALL	INPORT		;get byte from modem
		CPI	CR		;if CR			
		RZ			;baud rate is good go to MEX
		CPI	LF		;if LF
		RZ			;baud rate is good go to MEX
		CPI	'C'-40H 	;if ^C
		RZ			;baud rate is good go to MEX
		PUSH	H
		PUSH	B
		PUSH	D
		LXI	H,BAUD		;get baud rate start byte
		MOV	A,M		;get it out of memory	
		MOV	C,A		;set it up to operate on it
		INR	C		;add 1 to it
		MOV	M,C		;and put it back in start byte
		CALL	PBAUD		;go set baud rate and MSPEED
		CPI	7		;have we tried 2400 baud
		JNZ	TSTBAUD		;no then we're not done
		XRA	A		;yes then get ready for retry
		STA	BAUD		;by setting baud back to 110
		POP	D
		POP	B
		POP	H
		JMP	WAITCD		;we didn't find a good baud rate
					;so keep trying until - 1. get a
					;good baud rate  2. get a ^C, or
					;3. hangup causes carrier loss.
;
HLPMSG:	DB	CR,LF,'SET command, TRS MOD 4 version '
	db	REV/10+'0'
	DB	'.'
	DB	REV MOD 10 + '0',CR,LF
	DB	CR,LF,'SET BAUD 300 <or> 1200 <or> 2400 <or> 4800 <or> 9600'
	DB	CR,LF,'SET PARITY ON <or> OFF <or> ODD <or> EVEN'
	DB	CR,LF,'SET WORD 5 <or> 6 <or> 7 <or> 8'
	DB	CR,LF,'SET STOP 1 <or> 2'
        DB	CR,LF,'SET ANSWER <on> '
	DB	CR,LF,'$'		
SETEMS:	  	DB	CR,LF,'SET command error',CR,LF,LF,'$'
TSRCH:    	MVI	C,LOOKUP
	  	JMP	MEX
;
ILPRT:		MVI	C,ILP		;MEX print function
		JMP	MEX
;
CRLF:		MVI	A,CR		;newline on console
		CALL	TYPE
		MVI	A,LF
TYPE:		PUSH	H		;save em
		PUSH	D
		PUSH	B
		MOV	E,A
		MVI	C,CONOUT	;align output char
		CALL	MEX		;print via mex
		POP	B		;restore em
		POP	D
		POP	H
		RET		
;
; Test for printer ready
;
PRTSTS:	  	IN	PRPORT		;get printer status
	  	ANI	PRSTAT		;isolate it
	  	XRI	030H		;invert it
		JZ	PRTSTS1		;return if not ready A=00
	  	MVI	A,01H		;get "A" ready to zero  
PRTSTS1:	DCR	A		;A = 0 not ready
		RET			;A = FF ready
; Carrier detect  0=CARRIER
;
CARRCK:		IN	PORT		;get carrier bit
		ANI	CTSMSK
		RET
;	
; Baud rate set routine 
;
PBAUD:	  	PUSH	H		;save everybody
	  	PUSH	B
	  	PUSH	D
		MOV	E,A		;get speed
		MVI	D,0		;zero the other half of reg pair
		LXI	H,BAUDTB	;get baud rate table address
		DAD	D		;add speed offset
		MOV	A,M		;get baud rate  
		ORA	A		;0=not valid baud rate
		JZ	PBEXIT		;not valid baud rate then exit
		OUT	BAUDRP		;good baud rate then set it
		MOV	A,E		;get speed 
		STA	MSPEED		;set speed
		JMP	PBEXIT1		;return 
PBEXIT:		STC
PBEXIT1:	POP	B		;no carrier or incorrect baud rate
	  	POP	D
	  	POP   	H
	  	RET
;
BAUDTB:		DB	0,055H,0,0,0		;110,300,450,610,710
		DB	077H,0AAH,0CCH,0EEH,0	;1200,2400,4800,9600,19200
;
STTBL:		DB	'1'+80H		;stop bit tabe
		DW	STONE		;set one bit
		DB	'2'+80H
		DW	STTWO		;set two bits
		DB	0
;
PARTBL:		DB	'O','N'+80H	;parity table
		DW	STON		;enable parity
		DB	'OF','F'+80H
		DW	STOFF		;disable parity
		DB	'EVE','N'+80H
		DW	STEVE		;even parity
		DB	'OD','D'+80H
		DW	STODD		;odd parity	
		DB	0
;
WLTBL:		DB	'5'+80H		;word length table
		DW	STFIVE		;5 bit length
		DB	'6'+80H
		DW	STSIX		;6 bit length
		DB	'7'+80H
		DW	STSEV		;7 bit length
		DB	'8'+80H
		DW	STATE		;8 bit length
		DB	0
;
STFIVE:		LDA	CURURT		;get current port info
		ANI	09FH		;change to 5 bits
		STA	CURURT		;put back new port info
		MVI	A,'5'		;set 5 bit flag
STFIVE1:	STA	WLTEL	
		CALL	SETURT		;Tell UART of change
		CALL	CARRCK		;carrier present
		RZ			;yep then continue
		CALL	TYPE		;position cursor
		CALL	WLSHOW		;nope show word length
		RET
STSIX:		LDA	CURURT		;get current port info 
		ORI	U$WRD6		;set six bits	
		ANI	0DFH
		STA	CURURT		;put new 
		MVI	A,'6'		;set six bit flag
		JMP	STFIVE1
STSEV:		LDA	CURURT		;get current port info
		ORI	U$WRD7		;set seven bits
		ANI	0BFH
		STA	CURURT		;put back new port info
		MVI	A,'7'		;set 7 bit flag			
		JMP	STFIVE1
STATE:		LDA	CURURT		;get current port info
		ORI	U$WRD8		;set eight bit
		STA	CURURT		;put back new port info
		MVI	A,'8'		;set 8 bit flag
		JMP	STFIVE1
;
STON:		LDA	CURURT		;get current port info
		ANI	0F7H		;set parity on
      		STA	CURURT		;put back new port info
		MVI	A,YES
STON1:		STA	PARTEL		;set parity on flag
		CALL	SETURT		;Tell UART of change
		CALL	CARRCK		;carrier present
		RZ			;yep then continue
		CALL	TYPE		;position cursor
		CALL	PARSHOW		;nope then show parity info 
		RET
STOFF:		LDA	CURURT		;get curent port info
		ORI	008H		;set parity off
		STA	CURURT		;put back new port info
		MVI	A,NO		;set no parity flag
		JMP	STON1	
STODD:		LDA	CURURT		;get current port info
		ANI	07FH		;set parity odd
		STA	CURURT		;put back new port info
		MVI	A,YES		;set parity odd flag
STODD1:		STA	PARTEL1
		CALL	SETURT		;Tell UART of change
		CALL	CARRCK		;carrier present
		RZ			;yep then return
		CALL	TYPE		;position cursor
		CALL	PARSHOW		;nope show parity info
		RET
STEVE:		LDA	CURURT		;get current port info
		ORI	080H		;set even parity
		STA	CURURT		;put back new port info
		MVI	A,NO		;set even parity flag
		JMP	STODD1
STONE:		LDA	CURURT		;get current port info
		ANI	0EFH		;set one stop bit 
		STA	CURURT		;put back new port info
		MVI	A,YES		;set one stop bit flag
STONE1:		STA	STTEL		
		CALL	SETURT		;Tell UART of change
		CALL	CARRCK		;carrier present
		RZ			;yep then continue
		CALL	STSHOW		;nope show stop bit info 
		RET
STTWO:		LDA	CURURT		;get current port info
		ORI	010H		;set two stop bits
		STA	CURURT		;put back new port info
		MVI	A,NO		;set two stop bit flag
		JMP	STONE1			
;
PARSHOW:	LXI	D,PARMSG	;get parity message
		MVI	C,PRINT		;print it
		CALL	MEX
		LXI	D,PONMSG	;get set for parity on
		MVI	C,PRINT
		LDA	PARTEL		;get flag
		CPI	YES 		;is it on
		JZ	PARSHOW1	;yes then say so
		LXI	D,POFMSG	;no then get parity off message
		MVI	C,PRINT		;print it
		CALL	MEX
		RET
PARSHOW1:	CALL	MEX
		LXI	D,ODDMSG	;get parity odd message
		MVI	C,PRINT
		LDA	PARTEL1		;get odd parity flag
		CPI	YES		;is it odd
		JNZ  	PARSHOW2	;nope get even message
		CALL	MEX		;yes then say so 
		RET
PARSHOW2:	LXI	D,EVEMSG	;get even parity message
		MVI	C,PRINT		
		CALL	MEX		;print it
		RET
;
WLSHOW:		LXI	D,WLMSG		;get word length message
		MVI	C,PRINT
		CALL	MEX		;print it
		LXI	D,FIVEMSG	;load five bit message
		MVI	C,PRINT	
		LDA	WLTEL		;get word length flag 
		CPI	'5'		;is it five
		JNZ     SIX		;nope try six
		CALL	MEX		;yes then show it
		RET
SIX:		LXI	D,SIXMSG	;load six bit message
		MVI	C,PRINT
		CPI	'6'		;is it six
		JNZ	SEV		;nope try seven
		CALL	MEX		;yep then show it
		RET
SEV:		LXI	D,SEVMSG	;load seven bit message
		MVI	C,PRINT
		CPI	'7'		;is it seven
		JNZ	ATE		;nope try eight
		CALL	MEX		;yep then show it
		RET
ATE:		LXI	D,ATEMSG	;load eight bit message
		MVI	C,PRINT
		CALL	MEX		;print it
		RET
;
STSHOW:		LXI	D,STOPMSG	;get stop bit message
		MVI	C,PRINT		;print it
		CALL	MEX
		LXI	D,STOPMSG1	;get stop bit 1 message
		MVI	C,PRINT
		LDA	STTEL		;is it 1 bit
		CPI	YES
		JNZ	STSHOW1		;nope try two
		CALL	MEX		;yep then show it 
		RET
STSHOW1:	LXI	D,STOPMSG2	;get stop bit 2 message
		MVI	C,PRINT
		CALL	MEX		;print it
		RET
;
; Message area
;
BAUD:		DB	DFBAUD		;2400 baud
CURURT:		DB	DEFCTB		;Current UART configuration bits
PARTEL:		DB	NO		;yes=parity, no=no parity
PARTEL1:	DB	NO		;yes=odd parity, no=even
WLTEL:		DB	'8'		;5=5 bits,6=6 bits, etc.
STTEL:		DB	YES		;yes=1 stop, no=2 stop 
STOPMSG:	DB	'Number of stop bits is $'
STOPMSG1:	DB	'1$'
STOPMSG2:	DB	'2$'		
WLMSG:		DB	'Word length is $'
FIVEMSG:	DB	'5 bits$'
SIXMSG:		DB	'6 bits$'
SEVMSG:		DB	'7 bits$'
ATEMSG:		DB	'8 bits$'  	
PARMSG:		DB	'Parity is: $'
PONMSG:		DB	'on and $'
POFMSG:		DB	'off$'
ODDMSG:		DB	'odd$'
EVEMSG:		DB	'even$'
CLSMSG:	  	DB	CR,LF,1AH,'$'
EOSMSG:	  	DB	CR,LF,19H,'$'
SOMESG:	  	DB	'TRS Mod 4 CP/M 2.2 overlay V'
	  	DB	REV/10+'0'
	  	DB	'.'
	  	DB	REV MOD 10+'0','$'
NOMESG:		DB	ONV,'no $'
CARMSG:		DB	ONV,'carrier present',INV,CR,LF,'$'
ANSON:		DB	'ATZS0=',RING,CR,0   ;turn on auto answer
ANSMSG:		DB	'Auto answer mode now turned on. '
		DB	'[Use ^C to return to CPM]'
		DB	CR,LF,'$'
;
;****************************************************************************
;--THIS ROUTINE IS USED IF NOMXOSM = YES, AND THE MXO-SMxx.ASM FILE IS
;--APPENDED TO THIS ONE.
;****************************************************************************
;
		IF	NOMXOSM
SMSEND:		MVI	C,SNDRDY	;Routine extracted from MXO-SMxx.ASM
		CALL	MEX		;to be used only if MXO-RS.ASM and
		JNZ	SMSEND		;MXO-SMxx.ASM are assembled and loaded
		MOV	A,M		;as two seperate files.
		INX	H
		ORA	A
		RZ
		MOV	B,A
		MVI	C,SNDCHR
		CALL	MEX
		JMP	SMSEND
		ENDIF		
;
;-----------------------------------------------------------------------------
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem or Anchor)
;-----------------------------------------------------------------------------
; End of TRS-80 MOD IV  MEX modem overlay
;
;******************************************************************************
 	END	;Comment out this line to use with MXMSMxx.ASM and NOMXOSM=NO
;******************************************************************************
 line to use with MXMSMxx.ASM and NOMXOSM=NO
;*****************************************************