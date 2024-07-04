;	Title    'MEX overlay - TRS-80 MOD IV vers 3.2'	
;                      Montezuma Micro CP/M 2.2
;
;******************************************************************************
;	R E V I S I O N       H I S T O R Y
;******************************************************************************
;
; VERSION 3.2 09/15/86 - Bug Fixed.  When exiting MEX to CP/M, interrupts
;			 were not shut off properly and would cause the machine to go
;			 into never-never land. 
;				Fred LaForest
;
; VERSION 3.1 08/21/86 - Bug fixed.  If the input buffer was filled before it 
;			 could be emptied, the count of characters went past
;			 the configured maximum number of spaces in the buffer.
;				Fred LaForest
;
; VERSION 3.0 08/18/86 - Major revision level change.  I removed the auto
;			 answer code, it is modem dependent and belongs in a 
;			 modem overlay.  All smart modem code is gone.  The SET
;			 command code has been tightened up.  
;			 At higher speeds, the Mod 4 loses characters during
;			 screen scrolling.  Configurable code has been added to
;			 use interrupts to process UART input.  This eliminates
;			 almost all character dropouts during screen processing.
;				Fred LaForest
;				3235 Edgeworth
;				Ferndale, MI 48220
;				GENIE: FALAFOREST
;
;******************************************************************************
;
; VERSION 2.1 08/06/86 - Correct modem control to properly handle changes
;			 in word length, parity, and stop bits.  Changes
;			 to these parameters by the SET command were never
;			 communicated to the UART.
;				Fred LaForest
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
; MEX TRS-80 MOD IV OVERLAY VERSION 1.0: Written 09/10/84 by Ed Richter 
; 
; This file was derived from the MDM7xx overlay M7R4-5.ASM, and the 
; file MXOPM10.ASM. It is a MEX overlay for use with the TRS-80 MOD
; IV, and an external modem. It has a SET command that supports 300
; though 9600 baud.
;
;******************************************************************************

REV:	EQU	32		;MEX Overlay revision number
;
CR:	EQU	0DH		;carriage return
LF:	EQU	0AH		;linefeed
ONV:	EQU	0FH		;reverse video on
INV:	EQU	0EH		;reverse video off
TPA:	EQU	0100H		;start of program
TAB:	EQU	09H	
YES:	EQU	0FFH		;true
NO:	EQU	0		;not true

;******************************************************************************
;
;	UART equates and port equates
;
;******************************************************************************
;
;	***********  Important NOTICE  ***********
;
;	The following equate, MMINTR, is set to YES if you want input
;	characters from the UART to be captured by the TRS-80 Mod 4 interrupt
;	circuitry.  This virtually eliminates all lost characters during 
;	screen scrolling.  This means you can tell any RCPM or BBS that you 
;	don't need ANY nulls (0).  
;
;	A BIG assumption is that you are a MOD 4 using Montezuma Micro CP/M
;	implementation.  The initialization code searchs through the BIOS for
;	the TWO places which disable interrupts and really don't need this type
;	of protection.  They are th keyboard handler and the video screen memory
;	handler.  They only switch out RAM between F800h and FFFFh.  This does
;	NOT overlap any user program in TPA.  
;
;	The technique used to find the two BIOS locations can be modified for
;	other machines or CP/M implementations.
;
;	NOTE!!!;  If you DO NOT want to use interrupt processing, set MMINTR to
;	NO.  This will revert this overlay to the older port polling method
;	which is used in older overlays for the Mod 4.
;
;
MMINTR		EQU	YES	;Set YES if you are using Montezuma Micro CP/M
;				;AND you wish to use interrupt input processing
;				;Set NO if you DO NOT want interrupt processing
;				;and want the older port polling method
;
;	TRS 80 Communications port information
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
;	UART Control Bit Configuration
;
U$WORD:		EQU	060h	;Word length mask 
U$WRD5:		EQU	000H	;Word length of 5 bits
U$WRD6:		EQU	040H	;Word length of 6 bits
U$WRD7:		EQU	020H	;Word length of 7 bits
U$WRD8:		EQU	060H	;Word length of 8 bits
U$PART:		EQU	088H	;Parity control mask
U$PREV:		EQU	080H	;Parity EVEN
U$PROD:		EQU	000H	;Parity ODD
U$PROF:		EQU	008H	;Parity OFF
U$PRON:		EQU	000h	;Parity ON
U$STOP:		EQU	010H	;Stop bits mask
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
DEFCTB:		EQU	U$PROF+U$WRD8+U$STP1+U$DTRO+U$XMIT+U$RTSO
DFBAUD:		EQU	6	;0=110 1=300 2=450 3=600 4=710 5=1200	
				;6=2400 7=4800 8=9600 9=19200 default
CTSMSK:		EQU	020H		;carrier detect mask
ISOCD:		EQU	0DFH		;port ready mask
PRPORT:		EQU	0F8H		;printer port
PRSTAT:		EQU	0F0H		;printer ready mask
BRKMSK:		EQU	0FFH-U$XMIT	;send break
DTRMSK:		EQU	0FFH-U$DTR-U$RTS ;drop dtr

;******************************************************************************
;
;	MEX SERVICE PROCESSOR STUFF
;
;******************************************************************************
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

;******************************************************************************
;
;	Place the printer test routine address here
;
;******************************************************************************

		ORG	0D11H	;install printer ready test
		DW	PRTSTS

;******************************************************************************
; 
;	Low address MEX flags and configuration constants go here
;
;******************************************************************************

		ORG	TPA
;
		DS	3	;(for  "JMP   START" instruction)
PMODEM:		DS	1	;Not used by MEX			103H
SMODEM:		DS	1	;Not used by MEX
TPULSE:		DS	1	;Not used by MEX 			105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
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
		IF	NOT MMINTR	;If not interupt driven
INPORT:		IN	MODDAT  ! RET	;in modem data port
		ENDIF
		IF	MMINTR		;If interrupts are used
INPORT:		JMP	INT$GET		;Get a char from buffer
		ENDIF		
		DS	7
MASKR:		ANI	MDRCVB	! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR	! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB	! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR	! RET	;value of send bit when ready	151H
		DS	12		;unused by MEX
LOGON:		DS	2		;for user message		160H
DIALV:		DS	3		;autodial rtn jump		162H
DISCV:		JMP	DISCON		;disconnect rtn			165H

		IF	NOT MMINTR
GOODBV:		DS	3		;not needed			168H
		ENDIF
		IF	MMINTR		;Interrupt processing
GOODBV:		JMP	INT$BYE		;Restore system vectors		168H
		ENDIF

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

;******************************************************************************
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
;******************************************************************************

CLREOS:		LXI	D,EOSMSG	;clear to end of screen         195H
		CALL	MPRINT		;				198H
		RET			;				19DH
;
CLS:		LXI	D,CLSMSG	;clear sreen			19EH
		CALL	MPRINT		;				1A1H
		RET			;				1A6H
	
;
SYSVER:		LXI	D,SOMESG	;print the sys version msg	1A7H
		CALL	MPRINT		
;
;	Print out a message telling of carrier status
;
CARRSH		LXI	D,NOMESG	;no carrier present msg
		CALL	CARRCK
		CNZ	MPRINT		;print if no carrier
		LXI	D,CARMSG	;carrier present
		CALL	MPRINT		;say so and continue
		RET

;******************************************************************************
;
;	UART controling and accessing routines
;
;******************************************************************************
;
;	This area resets the SIO-UART DTR reinitializes all control parameters
;
NITMOD:	  	MVI	A,1
	  	OUT	PORT		;reset the USART to
	  	LDA	CURURT		;Get the current UART parameters
	  	OUT	MODCT1
		LDA	MSPEED		;Get startup baud rate
		CALL	PBAUD		;Set up baud rate generator
		IF	MMINTR		;Are we interrupt processing?
		CALL	INT$SET		;Yes, Set up needed vectors
		ENDIF
		RET

;
;	Send a break tone to reset some time-share computers.
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
;	Routine to return status of the modem port
;
STATSND:	IN	MODCT1		;in modem contol port
		PUSH 	B		;just in case
		ANI	ISOCD		;isolate status and clear CD bit
		IF	MMINTR
		ANI	0FFH-MDRCVB	;Clear any receive status
		ENDIF
		MOV	B,A		;save status
		IF	MMINTR
		CALL	INT$TST		;Test for input
		ORA	B		;Include other bits
		MOV	B,A		;Save in B
		ENDIF
		IN 	PORT		;get CD bit
		ANI	CTSMSK		;isolate CD bit
		ORA	B		;merge CD with status
		POP	B		;restore B
		RET

;
;	Determine the carrier detect status  0=CARRIER
;
CARRCK:		IN	PORT		;get carrier bit
		ANI	CTSMSK
		RET

;
;	This routine will hang up the phone by dropping DTR.
;
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

;******************************************************************************
;	
;	Baud rate set routine 
;
;	A = MEX baud rate code
;
;******************************************************************************
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
BAUDTB:		DB	0,055H,0,0,0		 ;110,300,450,610,710
		DB	077H,0AAH,0CCH,0EEH,0FFH ;1200,2400,4800,9600,19200

;******************************************************************************
;
;	Test for printer ready
;
;******************************************************************************
PRTSTS:	  	IN	PRPORT		;get printer status
	  	ANI	PRSTAT		;isolate it
	  	XRI	030H		;invert it
		JZ	PRTSTS1		;return if not ready A=00
	  	MVI	A,01H		;get "A" ready to zero  
PRTSTS1:	DCR	A		;A = 0 not ready
		RET			;A = FF ready

;******************************************************************************
;
;	Sets the communications parameters via the SET command
;
;******************************************************************************
SETCMD:		MVI	C,SBLANK	;any arguments
		CALL	MEX
		JC	SETSHO		;if not print out values
;
;	First determine the parameter they wish to change
;
		LXI	D,CMDTBL	;parse commands
		CALL	TSRCH		;from table
		JC	SETERR		;Word was not found
		MOV	A,H		;Get MS table address byte
		ORA	A		;Test for zero
		JZ	SETTBL		;Go Get next parameter
		PCHL			;Jump to special routine
;
;	All table look up errors come here
;
SETERR:	  	LXI	D,SETEMS	;no then print error
	  	CALL	MPRINT
	  	RET

SETEMS:	  	DB	CR,LF,'SET command error',CR,LF,LF,'$'

;
;	This routine will field parameter changes for WORD, PARITY and STOP BITS
;
SETTBL:		LXI	D,STTABL	;Get address of table
		DAD	D		;HL -> next parameter input table
		XCHG			;DE -> the table now
		CALL	TSRCH		;from table
		JC	SETERR		;Word was not found
		LDA	CURURT		;Get current UART parameters
		ANA	L		;Mask out bit under review
		ORA	H		;Set new bits
		STA	CURURT		;Store new parameters
		OUT	MODCT1		;Tell UART of the changes
		RET			;Return to MEX

;
;	Set the baud rate from the set command
;
STBAUD:		LXI	D,STBDTB	;Get the legal choices table
		CALL	TSRCH		;Search the table
		JC	SETERR		;When in doubt, do without
		MOV	A,L		;Get the MEX speed code
		STA	MSPEED		;Inform MEX of speed change
		MOV	A,H		;Get UART code
		OUT	BAUDRP		;Tell the UART baud rate generator
		RET			;Return to MEX

;
;	Print out a helpful description of the SET command
;
STHELP:		LXI	D,SOMESG	;Get Overlay version message
		CALL	MPRINT		;Print the version
		LXI	D,HLPMSG	;Get address of SET command
		CALL	MPRINT
		RET			;Return to MEX

;
;	Show the settings of the current parameters
;
SETSHO:		CALL	CLS		;clear screen
		CALL	SYSVER		;Print version and carrier status

		LXI	D,BAUDMSG	;Print baud rate message
		CALL	MPRINT		;Print it
		LDA	MSPEED		;get MSPEED to determine present
		MVI	C,PRBAUD	;baud rate
		CALL	MEX

		LXI	D,STOPMSG	;Insert Stop bits message
		CALL	MPRINT
		LDA	CURURT		;Get UART settings
		ANI	U$STP2		;How many bits
		MVI	A,'1'		;Assume 1 bit
		JZ	STSHS1		;Jump if so
		MVI	A,'2'		;Must be 2
STSHS1:		CALL	TYPE		;Tell operator

		LXI	D,WLMSG		;Start word length message
		CALL	MPRINT
		LDA	CURURT		;Get UART settings
		ANI	U$WORD		;Isolate byte length
		MVI	C,'5'		;5 bits?
		JZ	STSHLG		;Yes
		MVI	C,'6'
		CPI	U$WRD6		;6 bits?
		JZ	STSHLG
		MVI	C,'7'		;7 bits?
		CPI	U$WRD7
		JZ	STSHLG
		MVI	C,'8'		;Must be 8 bits then
STSHLG:		MOV	A,C		;Put char into A
		CALL	TYPE		;Output to the screen

		LXI	D,PARMSG	;Start parity message
		CALL	MPRINT
		LDA	CURURT		;Get UART settings
		ANI	U$PART		;Isolate parity info
		LXI	D,POFMSG	;Assume off
		CPI	U$PROF		;Off?
		JZ	STSHPT		;Yes
		LXI	D,EVEMSG	;Even parity?
		CPI	U$PREV
		JZ	STSHPT		;Yes
		LXI	D,ODDMSG	;Must be ODD
STSHPT:		CALL	MPRINT

		RET	

;******************************************************************************
;
;	MEX service routine front ends
;
;******************************************************************************
 
TSRCH:    	MVI	C,LOOKUP	;Table lookup routine
	  	JMP	MEX
;
MPRINT:		MVI	C,PRINT		;MEX print function
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


		IF	MMINTR		;Gen if interrupts wanted

;******************************************************************************
;
;	I N T E R R U P T	P R O C E S S I N G
;
;******************************************************************************
;
;	Search the BIOS for the interrupt disable in the video handler
;	and the keyboard handler.  Replace the DI with NOP and note their
;	addresses.  Replace the 38H vector with a jump to our interrupt
;	handling routine.
;
INT$SET:	LHLD	0001H		;Get start address of BIOS
		LXI	B,0B00H		;Max search size of BIOS
		LXI	D,INT$NOP	;Table to save BIOS addresses

IS$LP1:		MVI	A,0F3H		;Code for 'DI'
		DB	0EDH,0B1H	;CPIR, look for DI
		JNZ	IS$SDN		;Search is done

IS$TST:		PUSH	H		;Save regs
		PUSH	D
		PUSH	B
		LXI	D,I$STR		;Get remainder of code string
		MVI	B,4		;Compare next four bytes
IS$LP2:		LDAX	D		;Get byte from string
		INX	D		;Bump ptr
		CMP	M		;Compare to BIOS bytes
		INX	H
		JNZ	IS$LE2		;Not the same
		DB	10H,(IS$LP2-$-1) AND 0FFH ;DJNZ IS$LP2
IS$LE2:		POP	B		;Restore regs
		POP	D
		POP	H
		JNZ	IS$LP1		;Jump if not found

		DCX	H		;We found a DI!
		XRA	A
		MOV	M,A		;Put NOP where DI was
		XCHG
		MOV	M,E		;Put DI address into table
		INX	H
		MOV	M,D
		INX	H
		XCHG
		INX	H		;Restore HL
		JMP	IS$LP1		;Look for more 'DI's
 		
IS$SDN:		XRA	A		;Clear A
		STAX	D		;Clear the last entr
		INX	D
		STAX	D
		LHLD	INT$NOP		;Test for any 'DI's found
		MOV	A,H
		ORA	L
		JZ	IS$NONE		;No DI strings found, error!
;
;	Set up all vectors
;
		LDA	0038H		;Get old vector contents
		LHLD	0039H
		STA	INT$VCT		;Save it for later
		SHLD	INT$VCT+1
		MVI	A,0C3H		;Form a JMP instruction
		LXI	H,INT$RTN	; to the interrupt service routine
		STA	0038H		;Store new vector
		SHLD	0039H

		LXI	H,INT$BUF	;HL -> start of buffer
		SHLD	INT$INP		;Set up pointers
		SHLD	INT$OUTP	;into the buffer
		XRA	A		;Clear A regs
		STA	INT$CNT		;Count of chars in buffer
;
;	Set up interrupt hardware and GO
;
		MVI	A,020H		;Interrupt on UART data input ready
		OUT	0E0H		;Set up interrupt mask
		RET			;Return to the caller

IS$NONE:	LXI	D,I$NODI	;Print error message
		CALL	MPRINT
		JMP	0000H		;Return to CP/M

;
;	I N T $ B Y E    ---   Restore all vectors and return
;
INT$BYE:	DI			;Disable interrupts
		LXI	H,INT$NOP	;Point to DI address table
IB$LP1:		MOV	E,M		;Load an address
		INX	H
		MOV	D,M
		INX	H
		MOV	A,D		;Test for end of table
		ORA	E
		JZ	IB$VCT		;Exit when DI's replaced
		LDA	INT$BYE		;Get a DI
		STAX	D		;Store it
		JMP	IB$LP1		;Loop for the next one
	
IB$VCT:		LDA	INT$VCT		;Get old 38H vector data
		LHLD	INT$VCT+1
		STA	0038H		;Restore data
		SHLD	0039H

		XRA	A		;Clear A reg
		OUT	0E0H		;Disallow all interrupts
		RET			;Return to caller

;
;	I N T $ R T N    ----  Interrupt service routine
;
INT$RTN:	PUSH	PSW		;Save flags
		IN	MODCT1		;Get UART flags
		ANI	MDRCVR		;Isolate data ready bit
		CPI	MDRCVB		;Anythin' ther?
		JNZ	IR$RET		;No, return

		IN	MODDAT		;Get the data byte
		PUSH	H		;Save another reg
		LHLD	INT$INP		;Get our ptr
		MOV	M,A		;Save the data byte
		CALL	INT$BMP		;Bump the ptr	
		SHLD	INT$INP		;Save ptr

		LDA	INT$CNT		;Increment count
		INR	A		;Add one to the count
		CPI	INTSIZ+1	;Max saved chars?
		JC	IR$SVCT		;No, Save new count
		LHLD	INT$OUTP	;Get the output pointer
		CALL	INT$BMP		;Bump it ahead of the input ptr
		SHLD	INT$OUTP
		MVI	A,INTSIZ	;Reload max size 
IR$SVCT:	STA	INT$CNT		;Save updated count
		POP	H		;Restore H
 
IR$RET:		IN	0E0H		;Read int status reg
		POP	PSW
		EI			;Reenable interrupts
		DB	0EDH,04DH	;RETI

;
;	I N T $ T S T	---	Test buffer for pending data
;
INT$TST:	DI			;Disable interrupts
		LDA	INT$CNT		;Get the count
		ORA	A		;Test for zero
		EI			;Enable interrupts
		RZ			;Return if no data
		MVI	A,MDRCVR	;Get data ready bit
		RET			;Return

;
;	I N T $ G E T	 ---	Get a data byte from the buffer
;
INT$GET:	DI			;Disable interrupts
		LDA	INT$CNT		;Get byte count
		ORA	A		;Test for anything
		JZ	IG$RET		;Nothing, return
		DCR	A		;Subtract one
		STA	INT$CNT		;Update count
		PUSH	H		;Save HL reg
		PUSH	B		;And BC
		LHLD	INT$OUTP	;Get buffer ptr
		MOV	B,M		;Load a byte from the buffer
		CALL	INT$BMP		;Bump the pointer
		SHLD	INT$OUTP	;Save updated ptr
		MOV	A,B		;Get data byte again
		POP	B		;Restore regs
		POP	H

IG$RET:		EI			;Enable interupts
		RET			;Return to caller 			

;
;	Routine to bump the buffer pointer and reset it to the buffer 
;	start if we overrun the end
;
INT$BMP:	INX	H		;Bump ptr
		MOV	A,L		;Get LS byte
		CPI	(INT$BUF+INTSIZ) AND 0FFH ;Buffer end?
		RNZ			;No, return with the ptr as is
		LXI	H,INT$BUF	;Get buffer stat addr
		RET			;Return the reset ptr

;
;	Interrupt Routine Data, Pointer, and Buffer area
;
I$NODI:		DB	'Non standard BIOS -- Cannot continue',CR,LF,'$'  

I$STR:		DB	03EH,08EH,0D3H,084H ;MVI A,8EH   OUT 84H
 
INT$VCT:	DS	3		;Old 38H vector data
INT$NOP:	DS	2*5		;Up to 5 DI's

INTSIZ:		EQU	200		;Buffer up to 200 characters
INT$CNT:	DB	0		;Count of bytes in buffer
INT$INP:	DW	INT$BUF		;Interrput service rtn ptr
INT$OUTP:	DW	INT$BUF		;MEX buffer ptr
INT$BUF:	DS	INTSIZ		;Pending data buffer

		ENDIF



;******************************************************************************
;
;	Message and data area
;
;******************************************************************************

CURURT:	DB	DEFCTB		;Current UART configuration bits

BAUDMSG:DB	CR,LF,'Baud Rate:	$'
STOPMSG:DB	CR,LF,'Stop bits:	$'
WLMSG:	DB	CR,LF,'Word length:	$'
PARMSG:	DB	CR,LF,'Parity:		$'

POFMSG:	DB	'off$',CR,LF
ODDMSG:	DB	'on and odd$',CR,LF
EVEMSG:	DB	'on and even$',CR,LF

CLSMSG:	DB	CR,LF,1AH,'$'
EOSMSG:	DB	CR,LF,19H,'$'

SOMESG:	DB	'TRS Mod 4 CP/M 2.2 overlay V'
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	IF	MMINTR
	DB	' (Interrupt Driven)'
	ENDIF
	DB	CR,LF,'$'

NOMESG:	DB	ONV,'no $'
CARMSG:	DB	ONV,'carrier present',INV,CR,LF,'$'

;***************************************************************************
;
;	MEX legal command tables
;
;***************************************************************************

CMDTBL:	DB	'?'+80H		;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H	;"set baud ?'
	DW	STBAUD
	DB	'WOR','D'+80H	;set word length
	DW	STWORD-STTABL
	DB	'PARIT','Y'+80H ;set parity
	DW	STPAR-STTABL
	DB	'STO','P'+80H	;set stop bits
	DW	STSTOP-STTABL
	DB	0	

;
;	UART data format parameters
;
STTABL:				;Start of UART control parameters

STSTOP:	DB	'1'+80h		;Legal stop bits settings
	DB	0FFH-U$STOP,U$STP1
	DB	'2'+80h		;2 bits
	DB	0FFH-U$STOP,U$STP2
	DB	0

STPAR:	DB	'OD','D'+80h	;Odd parity and ON
	DB	0FFH-U$PART,U$PROD+U$PRON
	DB	'EVE','N'+80h	;Even parity and ON
	DB	0FFH-U$PART,U$PREV+U$PRON
	DB	'OF','F'+80h	;Parity OFF
	DB	0FFH-U$PART,U$PROF
	DB	0

STWORD:	DB	'5'+80h		;5 Bits per byte
	DB	0FFH-U$WORD,U$WRD5
	DB	'6'+80h		;6 Bits per byte
	DB	0FFH-U$WORD,U$WRD6
	DB	'7'+80h		;7 Bits per byte
	DB	0FFH-U$WORD,U$WRD7
	DB	'8'+80h		;8 Bits per byte
	DB	0FFH-U$WORD,U$WRD8
	DB	0

;
;	Legal baud settings table
;
STBDTB:	DB	'30','0'+80H	;300 Baud
	DB	1,055H		;MEX speed,UART baud speed
	DB	'120','0'+80H	;1200 Baud
	DB	5,077H
	DB	'240','0'+80H	;2400 Baud
	DB	6,0AAH
	DB	'480','0'+80H	;4800 Baud
	DB	7,0CCH
	DB	'960','0'+80H	;9600 Baud
	DB	8,0EEH
	DB	'1920','0'+80H	;19200 Baud
	DB	9,0FFH
	DB	0

;
;	Help menu for SET command
;
HLPMSG:	DB	CR,LF,'SET BAUD 300 <or> 1200 <or> 2400 <or> 4800 <or> 9600'
	DB	CR,LF,'SET PARITY OFF <or> ODD <or> EVEN'
	DB	CR,LF,'SET WORD 5 <or> 6 <or> 7 <or> 8'
	DB	CR,LF,'SET STOP 1 <or> 2'
	DB	CR,LF,'$'		
;
;-----------------------------------------------------------------------------
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem or Anchor)
;-----------------------------------------------------------------------------
; End of TRS-80 MOD IV  MEX modem overlay
;
;******************************************************************************

 	END	;
S-80 MOD IV  MEX modem overlay