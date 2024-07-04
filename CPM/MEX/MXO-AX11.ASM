;==========================================================================
;
;                               MXO-AX10.ASM
;
;   This file is an extended and upgraded version of the MEX overlay
;   MXO-KP30.ASM designed for use with MEX10.COM, the Modem EXecutive
;   communications program and the Actrix computer.  
;
;   To use:  Check carefully through the following equates and defines
;   to make sure the various options are set to your particular in-
;   stallation requirements and personal tastes.  This file may be
;   modified with any word processor such as ED or WordStar.  Once all
;   desired modifications have been entered, the .ASM file must be
;   assembled to a .HEX file using ASM, LINKASM, or the MAC assembler.
;   Use the MLOAD program distributed with MEX10 to generate a working
;   copy of MEX as follows:
;
;              MLOAD MEXNEW.COM=MEX10.COM,MXO-KP30.HEX
;
;
REV		EQU	11		;overlay revision level
;
;==========================================================================
;
;     Ver AX1.1		Added capability to use NEW 300+ internal modem
;			board that will operate at 300/1200 baud.
;
;     Ver AX1.0		Converted from the KayPro II overlay to Axtrix
;			computer. Designed to use either port J5 or J6
;			for external modem. Has either Hayes SmartModem 
;			or Ven-Tel modem protocols for dialling. 
;			Modified 03/09/84 by Bill Rink
;
;     Ver KP3.0		Combined the primarily modem-oriented commands
;			from the Smith-Quinn MXO-KP25 with the SIO-
;			oriented commands from the Saunders MXO-KP14
;			overlay -- 7/23/84 (Norm Saunders)
;
;     Ver KP1.4		Tightened the code a bit more and added the
;			code to automatically print the revision number
;			from the variable REV -- 6/26/84 (Norm Saunders)
;
;     Ver KP1.3		Fixed a bug in the SHDLY subroutine and added
;			code for automatic initialization of the
;			modem if it's a Hayes.  Also added Mark Pulver's
;			fix to the Hayes SMANAL subroutine -- 6/2/84
;			(Norm Saunders)
;
;     Ver KP1.2           Fixed a minor bug in the 'set bits' command,
;   			tightened up the code in the 'set baud' command,
;			and incorporated Ver 1.1 of the Hayes Smart-
;			modem overlay -- 5/24/84 (Norm Saunders)
;
;     Ver KP1.1		Implemented the PBAUD; vector, added an expanded
;			SET command, and incorporated the Hayes Smart-
;			modem overlay with conditional assembly commands
;			-- 5/19/84 (Norm Saunders)
;
;     Ver KP1.0		Translated M7KP-1.ASM to conform to the mnemonics
; 			and service processor calls of MEX10 -- 5/7/84
;			(Norm Saunders)
;
;==========================================================================
;
;	Miscellaneous equates
;
BELL		EQU	07H		;bell
CR		EQU	0DH		;carriage return
ESC		EQU	1BH		;escape
LF		EQU	0AH		;linefeed
TAB		EQU	09H		;tab
NO		EQU	0		;
YES		EQU	0FFH		;
FALSE		EQU	0		;
TRUE		EQU	NOT FALSE	;
TPA		EQU	0100H		;
MEXLOC		EQU	0D00H		;start of MEX service processor
BDOS		EQU	05H		;BDOS call
;
;	Actrix port definitions
;
PORT1		EQU	040H		;Base serial input/output port J5
MODCTL1		EQU	PORT1+2		;Modem control port
MODDAT1		EQU	PORT1		;Modem data port
BAUD1		EQU	5		;SET BUAD RATE FOR PORT J5
;
PORT2		EQU	041H		;Base serial input/output port J6
MODCTL2		EQU	PORT2+2		;Modem control port
MODDAT2		EQU	PORT2		;Modem data port
BAUD2		EQU	6		;SET BUAD RATE FOR PORT J6
;
;	Actrix bit definitions
;
MDRCVB		EQU	01H		;Your bit to test for receive
MDRCVR		EQU	01H		;Your value when receive ready
MDSNDB		EQU	04H		;Your bit to test for send
MDSNDR		EQU	04H		;Your value when send ready		
;
;	MEX service processor functions
;
MEX	EQU	MEXLOC		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, CY=no char
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
GNC	EQU	241		;get char from input, CY=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
;	Smart Modem Definition Flags
;
HAYES	EQU	FALSE		;set if a Hayes smartmodem is used
VENTEL	EQU	TRUE		;set if Ven-Tel smartmodem is used
;
		ORG	TPA
;
		DS	3	;(for  "JMP   START" instruction)
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly.  They will
; be moved in MEX 2.0.
;
SMODEM:		DW	TRUE	;true= smartmodem, false=non-dialing	103H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=19200 default display
				;time for sending a file
BYTDLY:		DB	1	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	9	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added SET command		10BH
SCRTST:		DB	YES	;yes=user-added cursor control routine 	10CH
		DB	0	;spare (replaces ACKNAK)		10DH
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
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
TOGLOC:		DB	YES	;yes=allow toggling of LOCNXT		118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFTST:		DB	NO	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
;
CTLPORT		DB	MODCTL2	; init for J6 port			120H
DATPORT		DB	MODDAT2	;					121H
BAUDPT		DB	BAUD2	;					122H
INTERN		DB	NO	; set modem to external use		123
		DS	6
;
;	Low-level modem I/O routines
;
INCTRL:		JMP	INSTAT		;read USART status		12AH
		DS	7		;
OTDATA:		JMP	OUTDAT		;out modem data port		134H
		DS	7		;
INPORT:		JMP	INDAT		;in modem data port		13EH
		DS	7		;
;
;	Bit-test routines
;
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of receive bit when rdy	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;
;
;	MEX10 vector to overlay-provided functions
;
LOGON:		DS	2		;not implemented in MEX		160H
;
		IF  NOT SMODEM
DIALV:		DS	3		;dummied out for non-dialing	162H
DISCV:		DS	3		;modems				165H
GOODBV:		JMP	GDBY		;disconnect 212-type modems	168H
		ENDIF
;
		IF SMODEM
DIALV:		JMP	DIAL		;Hayes dialing routine		162H
DISCV:		JMP	DISCON		;Hayes disconnect routine	165H
GOODBV:		JMP	GDBY		;				168H
		ENDIF
;
INMODV:		JMP	NITMOD		;UART initialization		16BH
NEWBDV:		JMP	PBAUD		;Reset baud rate from library	16EH
NOPARV:		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
PARITV:		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETCMD		;Actrix SET command		177H
SPMENV:		DS	3		;not implemented in MEX		17AH
VERSNV:		JMP	SYSVER		;print signon message		17DH
BREAKV:		JMP	BREAK		;send a break tone		180H
;
; The following jump vector provides the overlay with access to special
; routines in MEX10 provided to maintain compatibility with MDM7 over-
; lays.  It is recommended that these routines be avoided as they will
; disappear in future versions of MEX.
;
ILPRTV:		DS	3	;replaced with MEX function 9		183H
INBUFV:		DS	3	;replaced with MEX function 10		186H
ILCMPV:		DS	3	;replaced with table lookup fnc 247	189H
INMDMV:		DS	3	;replaced with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX			18FH
TIMERV:		DS	3	;replaced with MEX function 254		192H
;
;	Clear-screen and clear-to-end-of-screen functions
;
SCRN1:		JMP	CLREOS	;clear to end of screen			195H
		DS	6	;					198H
;
SCRN2:		JMP	CLS	;clear screen, home cursor		19EH
		DS	6	;					1A1H
;
;---------------------------------------------------------------------------
;
;	*** End of fixed format area ***
;
;---------------------------------------------------------------------------
;
;	Modem I/O routines
;
INSTAT:		PUSH	B
		LDA	CTLPORT
		MOV	C,A
		MVI	A,10H		;channel 0, reset interrupts.	
		DB	0EDH,79H	;OUT	MODCTL
		DB	0EDH,78H	;IN	MODCTL, get the status bits
		POP	B
		RET			;
OUTDAT:		PUSH	B 
		MOV	B,A		;SAVE OUTPUT CHAR
		LDA	DATPORT
		MOV	C,A
		MOV	A,B		;RETURN
		DB	0EDH,79H	;OUT	MODDAT, out modem data port
		POP	B 
		RET			;
INDAT:		PUSH	B 
		LDA	DATPORT
		MOV	C,A
		DB	0EDH,78H	;IN	MODDAT,	in modem data port
		POP	B 
		RET			;
;
;	Screen-handling routines
;
CLREOS:		LXI	D,EOSMSG	;
		MVI	C,PRINT		;
		CALL	MEX		;
		RET			;
;
CLS:		LXI	D,CLSMSG	;
		MVI	C,PRINT		;
		CALL	MEX		;
		RET			;
;
;	Print system version message
;
SYSVER:		CALL	ILPRT		;
		DB	CR,LF,'Custom Actrix Overlay -- Ver. '
		DB	REV/10+'0'
		DB	'.'
		DB	REV MOD 10 + '0'
		DB	CR,LF
		DB	'(type SET for Set Command syntax)',CR,LF,LF,0
		RET
;
;	Put Internal Modem OFFHOOK
OFFHK:		LDA	MSPEED
		CPI	1
		JZ	OFF300
		MVI	A,0B0H
		JMP	OFFMDM
OFF300:		MVI	A,0BAH
OFFMDM:		CALL	CTLOUT
		LDA	CTLPORT
		MOV	C,A
		MVI	A,5		;select SIO write-register 5
		DB	0EDH,79H	;OUT MODCTL		;
		LDA	REG5		;get the register 5 control byte
		ORI	80H		;set bit 7 (pulls DTR high)
		JMP	GDBY1

;
;	Send BREAK function
;
BREAK:		LDA	CTLPORT
		MOV	C,A
		MVI	A,5		;select SIO register 5
		DB	0EDH,79H	;OUT MODCTL
		LDA	REG5		;get the register 5 control byte
		ORI	010H		;set bit 4 (sends a break signal)
;
		JMP	GDBY1
;
;	Set DTR low for 300ms (disconnects some modems)
;
GDBY:		LDA	INTERN
		ORA	A
		JZ	GDBY1
		LDA	CTLPORT
		MOV	C,A
		MVI	A,5		;select SIO write-register 5
		DB	0EDH,79H	;OUT MODCTL		;
		LDA	REG5		;get the register 5 control byte
		ANI	07FH		;reset bit 7 (pulls DTR low)

;
GDBY1:		DB	0EDH,79H	;OUT MODCTL
		MVI	B,3		;Delay 300 ms.
		MVI	C,TIMER
		CALL	MEX
		LDA	INTERN
		ORA	A
		JNZ	GDBY2
		LDA	CTLPORT
		MOV	C,A
		MVI	A,5
		DB	0EDH,79H	;OUT MODCTL
		LDA	REG5		;Restore to normal
		DB	0EDH,79H	;OUT MODCTL
GDBY2:		RET
;
;	Actrix initialization routines
;
NITMOD:		CALL	NTBAUD		;initialize the baud rate
;
	IF SMODEM
		CALL	NITMDM		;initialize the smartmodem
	ENDIF
;
		RET			;
;
;	Initialize the Zilog SIO chip
;
NITSIO:		LDA	CTLPORT
		MOV	C,A
		MVI	A,00H		;Select reg. 0
		DB	0EDH,79H	;OUT MODCTL
		LDA	REG0		;Command byte
		DB	0EDH,79H	;OUT MODCTL
		MVI	A,04H		;Select reg. 4
		DB	0EDH,79H	;OUT MODCTL
		LDA	REG4		;Receive/transmit control byte
		ANI	3FH		;reset bit 7 and 6
		ORI	40H		;set bit 6
		MOV	B,A		;save reg. 4
		LDA	MSPEED		;get modem speed
		CPI	1		;300 BAUD
		MOV	A,B		;restore A
		JNZ	NITCTL
		ORI	0C0H		;set bit 7 and 6
NITCTL:		STA	REG4
		DB	0EDH,79H	;OUT MODCTL
		MVI	A,03H		;Select reg. 3
		DB	0EDH,79H	;OUT MODCTL
		LDA	REG3		;Receiver logic byte
		DB	0EDH,79H	;OUT MODCTL
		MVI	A,05H		;Select reg. 5
		DB	0EDH,79H	;OUT MODCTL
		LDA	INTERN
		ORA	A
		LDA	REG5		;Transmitter logic byte
		JNZ	NITEXT
		ORI	80H
NITEXT:		DB	0EDH,79H	;OUT MODCTL
		RET
;
;	Wait for Dial Tone (Internal Modem)
;
WAITON:	MVI	B,10			;WAIT 1 SEC FOR TONE
	MVI	C,TIMER
	CALL	MEX
	LDA	10H
	OUT	43H
	IN	43H
	ANI	20H			;GOT A DIAL TONE?
	RET	
;
;	Control Bits out to Internal Modem
;
CTLOUT:	OUT	30H
	IN	21H
	ORI	20H			;STROBE DATE OUT
	OUT	21H
	ANI	0DFH
	OUT	21H
	RET
;
;	Initialize the baudrate generator
;
NTBAUD:		LDA	MSPEED		;get the speed code
		CALL	PBAUD		;go set it
		RET
;
;	Initialize the modem
;
	IF SMODEM
NITMDM:		CALL	SHPORT
	IF HAYES
		CALL	STSPK1		;
		CALL	CRLF		;
		CALL	STDL15		;
		CALL	CRLF		;
		CALL	STMOD1		;
		CALL	CRLF		;
		CALL	SHDIAL		;
		CALL	CRLF		;
	ENDIF
		CALL	SHBAUD		;
		CALL	CRLF		;
		RET			;
;
;	Send a string to the modem
;
MDMSET:		CALL	SMSEND		;send a string to the modem
NITMD1:		MVI	C,INMDM		;eat all feedback from the modem
		CALL	MEX		;
		JNC	NITMD1		;
		RET			;
	ENDIF
;
;	Actrix SET command processor
;
SETCMD:		MVI	C,SBLANK	;check for SET arguments
		CALL	MEX		;
		JC	SETHLP		;if none, print help message
		LXI	D,CMDTBL	;parse the command
		CALL	TSRCH		;
		PUSH	H		;put returned address on stack
		RNC			;go there if table match found
		POP	H		;if no match, fix the stack and
SETERR:		LXI	D,SETEMS	;print an error message
		MVI	C,PRINT		;
		CALL	MEX		;
		RET			;
;
;	SET <no arguments>: print help message
;
SETHLP:		LXI	D,HLPMSG	;
		MVI	C,PRINT		;
		CALL	MEX		;
		RET			;
;
HLPMSG:		DB	CR,LF,'SET command - Actrix version:',CR,LF,LF
		DB	CR,LF,'SET BAUD <300> <600> <1200> <2400>'
		DB	' <4800> <9600>'
		DB	CR,LF,'SET PARITY <OFF> <EVEN> <ODD>'
		DB	CR,LF,'SET STOPBITS <1> <1.5> <2>'
		DB	CR,LF,'SET LENGTH <5> <6> <7> <8>'
		DB	CR,LF,'SET PORT <J5> <J6>'
		DB	CR,LF,'SET MODEM <EXT> <INT>'
;
	IF HAYES
		DB	CR,LF,'SET MONITOR ON <or> OFF'
		DB	CR,LF,'SET DELAY 15 <or> 30 <or> 45 <or> 60'
		DB	CR,LF,'SET MODE ORIG <or> ANSWER'
		DB	CR,LF,'SET DIAL PULSE <or> TONE'
	ENDIF
;
		DB	CR,LF,LF,'SET ?  (show current settings)'
		DB	CR,LF,'$'
;
;	SET BAUD command: reset the baudrate generator
;
STBAUD:		MVI	C,SBLANK	;check for baudrate
		CALL	MEX		;
		JC	SETERR		;if none, print error message
		LXI	D,BDTBL		;check for acceptable rate
		CALL	TSRCH		;
		JC	SETERR		;if no match, print error
		MOV	A,L		;get file speed parameter
		CALL	PBAUD		;set the baudrate
		CALL	SHBAUD		;show the baud rate
		JMP	CRLF
SHBAUD:		CALL	ILPRT		;display current baudrate
		DB	'Baud rate:',TAB,' ',0
		LDA	MSPEED
		MVI	C,PRBAUD
		JMP	MEX
;
;	Set the baud rate from the MSPEED code in reg. A
;	CY set if the specified rate is unsupported
;
PBAUD:		PUSH	H		;save all the registers
		PUSH	D		;
		PUSH	B		;
		PUSH	PSW		;
		MVI	E,1BH		;send ESCAPE code to monitor
		MVI	C,6		;do a direct conout
		CALL	BDOS		;
		MVI	E,0F0H		;send SET BAUD RATE code to monitor
		MVI	C,6		;do a direct conout
		CALL	BDOS		;
		LDA	BAUDPT		;GET CURRENT BUAD PORT
		MOV	E,A		;OUTPUT TO PROPER PORT
		MVI	C,6		;do a direct conout
		CALL	BDOS		;
		POP	PSW		;restore Areg
		MOV	E,A		;put MSPEED in DE
		MVI	D,0		;
		LXI	H,BDTBL2	;offset into the table
		DAD	D		;
		MOV	A,M		;get the baud-generator code
		ORA	A		; test for zero value
		JZ	PBAUD2		; EXIT if so
		PUSH	D		; SAVE E
		MOV	E,A		;output the baud rate
		MVI	C,6		;do a direct conout
		CALL	BDOS		;
		POP	D		;
		MOV	A,E		;get MSPEED code back
		STA	MSPEED		;save it
		ORA	A		;return, no errors
PBAUD1:
		POP	B		;
		POP	D		;
		POP	H		;
		CALL	NITSIO		;reset SIO
		RET			;

PBAUD2:		MVI	A,28H		;put out a standard baud rate
		MOV	E,A		;output the baud rate
		MVI	C,6		;do a direct conout
		CALL	BDOS		;
		CTC			; If Error
		JP	PBAUD1
;
;	SET ? command: show all current settings
;
STSHOW:		CALL	CRLF		;
		LXI	H,SHOTBL	;get table of SHOW routines
STSHW1:		MOV	E,M		;get address of a routine
		INX	H		;
		MOV	D,M		;
		INX	H		;
		MOV	A,D 		;
		ORA	E		;end of table?
		RZ			;if yes, we're done
		PUSH	H		;save the table pointer
		XCHG			;put address in HL
		CALL	GOHL		;go do it!
		CALL	CRLF		;print newline
		MVI	C,CHEKCC	;console abort?
		CALL	MEX		;
		POP	H		;
		JNZ	STSHW1		;if no abort then continue
		RET			;
;
GOHL:		PCHL			;
;
;	SET PARITY command: reset transmit/receive parity
;
;		Parity is controlled by bits 0 and 1 of
;		the byte sent to the SIO write-register
;		4 as follows:
;
;		   Parity	Bit 1	   Bit 0
;	             Off          -          0
;	 	     Odd	  0	     1
;		     Even	  1	     1
;
STPRTY:		MVI	C,SBLANK	;check for parity code
		CALL	MEX		;
		JC	SETERR		;if none, print error
		LXI	D,PARTBL	;check for proper syntax
		CALL	TSRCH		;
		PUSH	H		;match found, go do it!
		RNC			;
		POP	H		;no match: fix stack and
		JMP	SETERR		;  print error
;
PROFF:		LDA	REG4		;get register 4 byte
		ANI	0FEH		;reset bit 0
		JMP	PARTB1		;
PREVEN:		LDA	REG4		;
		ORI	003H		;set bits 0 & 1
		JMP	PARTB1		;
PRODD:		LDA	REG4		;
		ORI	001H		;set bit 0
		ANI	0FDH		;reset bit 1
PARTB1:		STA	REG4		;
		CALL	NITSIO		;re-initialize the USART
		CALL	SHPRTY		;print the result
		JMP	CRLF		;
SHPRTY:		CALL	ILPRT		;display parity
		DB	'Parity:  ',TAB,' ',0
		LDA	REG4		;
		ANI	001H		;test bit 0
		CPI	0		;if bit0=0 then parity off
		JNZ	SHPRT1		;
		CALL	ILPRT		;
		DB	'Off',0		;
		RET
SHPRT1:		LDA	REG4		;
		ANI	002H		;test bit 1
		CPI	0		;if bit1=0 then parity odd
		JNZ	SHPRT2		;
		CALL	ILPRT		;
		DB	'Odd',0		;
		RET			;
SHPRT2:		CALL	ILPRT		;
		DB	'Even',0	;
		RET
;
;	SET STOPBITS command: reset number of stop bits
;
;		The number of stop bits is controlled by bits
;		2 and 3 of the byte sent to the SIO write-
;		register 4, as follows:
;
;		    Stop bits	   Bit 3	Bit 2
;			1	     0            1
;		       1.5	     1		  0
;			2	     1		  1
;
;
STSTOP:		MVI	C,SBLANK	;check for stop bits
		CALL	MEX		;
		JC	SETERR		;if none, print error
		LXI	D,STPTBL	;check for proper syntax
		CALL	TSRCH		;
		PUSH	H		;match found, go do it!
		RNC			;
		POP	H		;no match: fix stack and
		JMP	SETERR		;  print error
;
STOP01:		LDA	REG4		;get register 4 byte
		ANI	0F7H		;reset bit 3
		ORI	004H		;set bit 2
		JMP	STSTP1		;
STOP02:		LDA	REG4		;
		ORI	00CH		;set bits 2 and 3
		JMP	STSTP1		;
STOP15:		LDA	REG4		;
		ORI	008H		;set bit 3
		ANI	0F8H		;reset bit 2
STSTP1:		STA	REG4		;
		CALL	NITSIO		;
		CALL	SHSTOP		;print the result
		JMP	CRLF		;
SHSTOP:		CALL	ILPRT		;display stop-bits
		DB	'Stop bits:',TAB,' ',0
		LDA	REG4		;
		ANI	004H		;test bit 2
		CPI	0		;if bit2=0 then 1.5
		JNZ	SHSTP1		;
		CALL	ILPRT		;
		DB	'1.5',0		;
		RET
SHSTP1:		LDA	REG4		;
		ANI	008H		;test bit 3
		CPI	0		;if bit3=0 then 1
		JNZ	SHSTP2		;
		CALL	ILPRT		;
		DB	'1',0		;
		RET
SHSTP2:		CALL	ILPRT		;
		DB	'2',0		;
		RET
;
;	SET LENGTH command: set bits per character
;
;		The number of bits per character is controlled for
;		the receiver circuit by bits 6 and 7 of the byte
;		sent to the SIO write-register 3 and for the trans-
;		mitter circuit by bits 5 and 6 of the byte sent to
;		the SIO write-register 5.  The assumption has been
;		made here that both transmission and reception will
;		be carried on at the same number of bits per charac-
;		ter.  The bit configurations are shown for register
;		3 only, but are the same for register 5:
;
;		    BPC		Bit 7		Bit 6
;		     5		  0		  0
;		     6		  1   		  0
;		     7		  0		  1
;		     8		  1		  1
;
STBITS:		MVI	C,SBLANK	;check for bits/char
		CALL	MEX		;
		JC	SETERR		;if none, print error
		LXI	D,BITTBL	;check for proper syntax
		CALL	TSRCH		;
		PUSH	H		;match found, go do it!
		RNC			;
		POP	H		;no match: fix stack and
		JMP	SETERR		;  print error
;
BIT5:		LDA	REG3		;
		ANI	0BFH		;reset bit 6
		ANI	07FH		;reset bit 7
		STA	REG3		;
		LDA	REG5		;
		ANI	0DFH		;reset bit 5
		ANI	0BFH		;reset bit 6
		JMP	STBTS1		;
BIT6:		LDA	REG3		;
		ANI	0BFH		;reset bit 6
		ORI	080H		;set bit 7
		STA	REG3		;
		LDA	REG5		;
		ANI	0DFH		;reset bit 5
		ORI	040H		;set bit 6
		JMP	STBTS1		;
BIT7:		LDA	REG3		;
		ORI	040H		;set bit 6
		ANI	07FH		;reset bit 7
		STA	REG3		;
		LDA	REG5		;
		ORI	020H		;set bit 5
		ANI	0BFH		;reset bit 6
		JMP	STBTS1		;
BIT8:		LDA	REG3		;
		ORI	040H		;set bit 6
		ORI	080H		;set bit 7
		STA	REG3		;
		LDA	REG5		;
		ORI	020H		;set bit 5
		ORI	040H		;set bit 6
STBTS1:		STA	REG5		;
		CALL	NITSIO		;
		CALL	SHBITS		;print the result
		JMP	CRLF
SHBITS:		CALL	ILPRT		;display bits/char
		DB	'Bits/char:',TAB,' ',0
		LDA	REG5		;
		ANI	040H		;test bit 6
		CPI	0		;if bit6=0 then 6 bpc
		JNZ	SHBTS2		;
		LDA	REG5		;
		ANI	020H		;test bit 5
		CPI	0		;if bit5=0 then 5 bpc
		JNZ	SHBTS1		;
		CALL	ILPRT		;
		DB	'5',0		;
		RET			;
SHBTS1:		CALL	ILPRT		;
		DB	'7',0		;
		RET			;
SHBTS2:		LDA	REG5		;
		ANI	020H		;test bit 5
		CPI	0		;if bit5=0 then 6 bpc
		JNZ	SHBTS3		;
		CALL	ILPRT		;
		DB	'6',0		;
		RET			;
SHBTS3:		CALL	ILPRT		;
		DB	'8',0		;
		RET
;
;	Set Port Address for Modem
;

STPORT:		MVI	C,SBLANK	;check for parity code
		CALL	MEX		;
		JC	SETERR		;if none, print error
		LXI	D,PORTBL	;check for proper syntax
		CALL	TSRCH		;
		PUSH	H		;match found, go do it!
		RNC			;
		POP	H		;no match: fix stack and
		JMP	SETERR		;  print error
;
PORTJ5:		MVI	A,MODCTL1
		STA	CTLPORT		;DEFINE CONTROL PORT
		MVI	A,MODDAT1	;
		STA	DATPORT		;DEFINE DATA PORT
		MVI	A,BAUD1		;
		STA	BAUDPT		;DEFINE BAUD PORT
		JMP	SPORT		;
PORTJ6:		MVI	A,MODCTL2
		STA	CTLPORT		;DEFINE CONTROL PORT
		MVI	A,MODDAT2	;
		STA	DATPORT		;DEFINE DATA PORT
		MVI	A,BAUD2		;
		STA	BAUDPT		;DEFINE BAUD PORT
SPORT:		CALL	NTBAUD
		CALL	NITSIO
SHPORT:		CALL	CRLF		;
		CALL	ILPRT		;
		DB	'Initializing modem for port J',0
		LDA	BAUDPT		;get the port number
		CPI	5
		JNZ	SHPJ6
		MVI	A,'5'
		JMP	SHPOUT
SHPJ6:		CPI	6
		JNZ	SHPU
		MVI	A,'6'
		JMP	SHPOUT
SHPU:		MVI	A,'?'
SHPOUT:		CALL	TYPE
		LDA	INTERN
		ORA	A
		JZ	SHEXT
		CALL	ILPRT
		DB	CR,LF,'USING Internal 300/1200 Modem',0
		JMP	SHEXIT
SHEXT:		CALL	ILPRT
		DB	CR,LF,'USING External Modem',0
SHEXIT:		CALL	ILPRT
		DB	CR,LF,LF,0
		RET
;
STMDM:		MVI	C,SBLANK	;check for parity code
		CALL	MEX		;
		JC	SETERR		;if none, print error
		LXI	D,MDMTBL	;check for proper syntax
		CALL	TSRCH		;
		PUSH	H		;match found, go do it!
		RNC			;
		POP	H		;no match: fix stack and
		JMP	SETERR		;  print error
;
EXTMDM:		XRA	A
		JMP	SETINT	
INTMDM:		MVI	A,0FFH
SETINT:		STA	INTERN
		JMP	SHPORT


;
	IF HAYES
;
;	SET MONITOR command: turn Hayes speaker on and off
;			     to monitor dialing
;
STSPKR:		MVI	C,SBLANK	;
		CALL	MEX		;
		JC	SETERR		;
		LXI	D,MONTBL	;
		CALL	TSRCH		;
		JC	SETERR		;
		MOV	A,L		;
		ADI	'0'		;
		STA	MONMSG+3	;
STSPK1:		LXI	H,MONMSG	;
		CALL	MDMSET		;
SHSPKR:		CALL	ILPRT		;
		DB	'Modem monitor:',TAB,' ',0
		LDA	MONMSG+3	;
		CPI	0+'0'		;if monflg=0 then speaker is off
		JNZ	SHSPK1		;
		CALL	ILPRT		;
		DB	'Off',0		;
		RET			;
SHSPK1:		CALL	ILPRT		;
		DB	'On',0		;
		RET			;
;
;	SET DELAY command: set wait-time for 'no answer'
;
STDLY:		MVI	C,SBLANK	;check for delay parameter
		CALL	MEX		;
		JC	SETERR		;
		LXI	D,DLYTBL	;
		CALL	TSRCH		;
		PUSH	H		;
		RNC			;
		POP	H		;
		JMP	SETERR		;
STDL15:		LXI	H,DL15MS	;delay 15 seconds
		CALL	MDMSET		;
		MVI	A,15		;
		STA	NDELAY		;
		JMP	SHDLY		;
STDL30:		LXI	H,DL30MS	;
		CALL	MDMSET		;
		MVI	A,30		;
		STA	NDELAY		;
		JMP	SHDLY		;
STDL45:		LXI	H,DL45MS	;
		CALL	MDMSET		;
		MVI	A,45		;
		STA	NDELAY		;
		JMP	SHDLY		;
STDL60:		LXI	H,DL60MS	;
		CALL	MDMSET		;
		MVI	A,60		;
		STA	NDELAY		;
SHDLY:		CALL	ILPRT		;
		DB	'Modem delay:',TAB,' ',0
		LDA	NDELAY		;
		CPI	15		;
		JNZ	SHDLY1		;
		CALL	ILPRT		;
		DB	'15 seconds',0
		RET
SHDLY1:		CPI	30		;
		JNZ	SHDLY2		;
		CALL	ILPRT		;
		DB	'30 seconds',0
		RET
SHDLY2:		CPI	45		;
		JNZ	SHDLY3		;
		CALL	ILPRT		;
		DB	'45 seconds',0
		RET
SHDLY3:		CALL	ILPRT		;
		DB	'60 seconds',0
		RET			;
;
;	SET MODE command (answer or originate)
;
STMODE:		MVI	C,SBLANK	;
		CALL	MEX		;
		JC	SETERR		;
		LXI	D,MODTBL	;
		CALL	TSRCH		;
		JC	SETERR		;
		MOV	A,L		;
		ADI	'0'		;
		STA	MODMSG+5	;
STMOD1:		LXI	H,MODMSG	;
		CALL	MDMSET		;
SHMODE:		CALL	ILPRT		;
		DB	'Mode:   ',TAB,' ',0
		LDA	MODMSG+5	;
		CPI	0+'0'		;if zero, then originate mode
		JNZ	SHMOD1		;
		CALL	ILPRT		;
		DB	'Originate',0	;
		RET			;
SHMOD1:		CALL	ILPRT		;
		DB	'Answer',0	;
		RET			;
;
;	SET DIAL command (touch or pulse)
; 
SETDIA:		MVI	C,SBLANK	;
		CALL	MEX		;
		JC	SETERR		;
		LXI	D,DIALTB	;
		CALL	TSRCH		;
		JC	SETERR		;
		MOV	A,L		;
		STA	TPULSE		;
SHDIAL:		CALL	ILPRT		;
		DB	'Phone type:',TAB,' ',0
		LDA	TPULSE		;
		CPI	'T'		;
		JNZ	SHDIL1		;
		CALL	ILPRT		;
		DB	'Touchtone',0
		RET			;
SHDIL1:		CALL	ILPRT		;
		DB	'Pulse-dial',0	;
		RET			;
	ENDIF
;
; Newline on console
;
CRLF:		MVI	A,CR
		CALL	TYPE
		MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:		PUSH	H		;save 'em
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
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:		MVI	C,LOOKUP	;get function code
		JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:		MVI	C,ILP		;get function code
		JMP	MEX		;go do it
;
	IF SMODEM
;
;	Hayes Smartmodem 1200 dialling routines
;
DIAL:		LHLD	DIALPT		;Fetch pointer
		CPI	254		;Start dial?
		JZ	STDIAL		;jump if so
		CPI	255		;end dial?
		JZ	ENDIAL		;jump if so
;
; Not start or end sequence, must be a digit to be sent to the modem
;
		MOV	M,A		;put char in buffer
		INX	H		;advance pointer
		SHLD	DIALPT		;stuff pntr
		RET			;all done
;
; Here on a start-dial sequence
;
STDIAL:		LXI	H,DIALBF	;set up buffer pointer
		SHLD	DIALPT
		LDA	INTERN		; USING INTERNAL MODEM?
		JZ	STDRET		; NOPE
		CALL	OFFHK
STDRET:		RET
;
; Here on an end-dial sequence
;
ENDIAL:		MVI	M,CR		;stuff end-of-line into buffer
		INX	H		;followed by terminator
	IF VENTEL
		LDA	INTERN
		ORA	A
		JNZ	ENDL		;DON'T NEED THIS FOR INTERNAL
		MVI	M,'>'		;end bufffered command string
		INX	H		;
	ENDIF
ENDL:		MVI	M,0
	IF HAYES
		LDA	TPULSE		;get overlay's touch-tone flag
		STA	SMDIAL+3	;put into string
	ENDIF
		LXI	H,SMDIAL	;point to dialing string
		CALL	SMSEND		;send it
WAITSM:		MVI	C,INMDM
		CALL	MEX		;catch any output from the modem
		JNC	WAITSM		;loop until no more characters
;
; The following loop waits for a result from the modem (up to
; 60 seconds: you may change this value in the following line)
;
RESULT:		MVI	C,60		;<<== maximum time to wait for result
SMWLP:		PUSH	B
		MVI	B,1		;check for a char, up to 1 sec wait
		MVI	C,TMDINP	;do timed input
		CALL	MEX
		POP	B
		JNC	SMTEST		;jump if modem had a char
		PUSH	B		;no, test for control-c from console
		MVI	C,CHEKCC
		CALL	MEX
		POP	B
		JNZ	SMNEXT		;if not, jump
		MVI	B,CR		;yes, shut down the modem
		MVI	C,SNDCHR
		CALL	MEX
		MVI	A,3		;return abort code
		RET
SMNEXT:		DCR	C		;no
		JNZ	SMWLP		;continue
;
; One minute with no modem response (or no connection)
;
SMTIMO:		MVI	A,2		;return timeout code
		RET
;
; Modem gave us a result, check it
;
SMTEST:		ANI	7FH		;ignore any parity
		CALL	SMANAL		;test the result
		JC	RESULT		;go try again if unknown response
		MOV	A,B		;a=result 
		PUSH	PSW		;save it
SMTLP:		MVI	C,INMDM		;eat any additional chars from smartmodem
		CALL	MEX
		JNC	SMTLP		;until 100ms of quiet time
		POP	PSW		;return the code
		RET
;
SMANAL:
	IF HAYES
		MVI	B,0		;prep connect code
		CPI	'C'		;"connect"?
		RZ
		CPI	'1'		;numeric version of "connect"
		RZ
		CPI	'5'		;or "connect 1200"
		RZ
		INR	B		;prep busy code B=1
		CPI	'B'
		RZ
		INR	B		;prep no connect msg B=2
		CPI	'N'		;n=no connect
		RZ
		CPI	'3'		;numeric version of "no connect"
		RZ
		MVI	B,4		;prep modem error
		CPI	'E'		;e=error
		RZ
		CPI	'4'		;numeric version of "error"
		RZ
	ENDIF

	IF VENTEL
		MVI	B,0		;prep connect code
		CPI	'O'		;"connect"?
		RZ
		INR	B		;prep busy code B=1
		CPI	'B'
		RZ
		INR	B		;prep no connect msg B=2
		CPI	'N'		;n=no connect
		RZ
		MVI	B,4		;prep modem error
		CPI	'D'		;e=error
		RZ
	ENDIF

;
; Unknown response, return carry to caller. But first,
; flush the unknown response line from the modem.
;
WTLF:		CPI	LF		;linefeed?
		STC
		RZ			;end if so
		MVI	C,INMDM		;no. get next char
		CALL	MEX
		JNC	WTLF		;unless busy, loop
		RET
;
; Following routine disconnects the modem using smartmodem
; codes. All registers are available for this function.
; Nothing returned to caller.
;
;
DISCON:
	IF HAYES
		MVI	B,20
		MVI	C,TIMER		;wait 2 seconds
		CALL	MEX
		LXI	H,SMATN		;send '+++'
		CALL	SMSEND
		MVI	B,20		;wait 2 more seconds
		MVI	C,TIMER
		CALL	MEX
		LXI	H,SMDISC	;send 'ATH'
		CALL	SMSEND
		MVI	B,1		;wait 1 second
		MVI	C,TIMER
		CALL	MEX
	ENDIF
		RET
;
; Smartmodem utility routine: send string to modem
;
SMSEND:		MVI	C,SNDRDY	;wait for modem ready
		CALL	MEX
		JNZ	SMSEND
		MOV	A,M		;fetch next character
		INX	H
		ORA	A		;end?
		RZ			;done if so
		MOV	B,A		;no, position for sending
		MVI	C,SNDCHR	;nope, send the character
		CALL	MEX
		JMP	SMSEND
;
	ENDIF
;
;	Data area
;
EOSMSG:		DB	1BH,'Y$'		;clear-to-end-of-screen
CLSMSG:		DB	1BH,'*$'		;clear-screen-home-cursor
;
; Default UART parameters in the following table
;
REG0:		DB	00011000B	;Reset channel A
REG3:		DB	11000001B	;Enable receive at 8 bits/char
REG4:		DB	01000100B	;No parity, 1 stop bit, clock X16
REG5:		DB	01101010B	;Enable transmit at 8 bits/char
;
SETEMS:		DB	CR,LF,'SET command error',CR,LF,'$'
;
	IF HAYES
MONMSG:		DB	'ATM0',CR,0
NDELAY:		DB	15		;delay-time in seconds
DL15MS:		DB	'ATS7=15',CR,0
DL30MS:		DB	'ATS7=30',CR,0
DL45MS:		DB	'ATS7=45',CR,0
DL60MS:		DB	'ATS7=60',CR,0
MODMSG:		DB	'ATS0=0',CR,0
SMATN:		DB	'+++',0
SMDISC:		DB	'ATH',CR,0
SMDIAL:		DB	'ATDT '
	ENDIF

	IF	VENTEL
SMDIAL:		DB	'<K'
	ENDIF

DIALBF:		DS	52		;2* 24 char max, + CR + NULL + slop
DIALPT:		DS	2		;dial position pointer

;
;
;
;	SET command -- master command table
;
CMDTBL:		DB	'?'+80H		;"set ?"
		DW	STSHOW		;
		DB	'BAU','D'+80H	;"set baud"
		DW	STBAUD		;
		DB	'PARIT','Y'+80H	;"set parity"
		DW	STPRTY		;
		DB	'STOPBIT','S'+80H	;"set stopbits"
		DW	STSTOP		;
		DB	'LENGT','H'+80H	;"set length"
		DW	STBITS		;
		DB	'POR','T'+80H	;"set port for modem"
		DW	STPORT
		DB	'MODE','M'+80H	;set modem as internal or external
		DW	STMDM
;
	IF HAYES
		DB	'MONITO','R'+80H;"set monitor"
		DW	STSPKR
		DB	'DELA','Y'+80H	;"set delay"
		DW	STDLY
		DB	'MOD','E'+80H	;"set mode"
		DW	STMODE
		DB	'DIA','L'+80H	;"set dial"
		DW	SETDIA
	ENDIF
;
		DB	0		;<<== end of CMDTBL
;
;	SET BAUD command table
;
BDTBL:		DB	'30','0'+80H	;"set baud 300"
		DW	0001H		;
		DB	'60','0'+80H	;"set baud 600"
		DW	0003H		;
		DB	'120','0'+80H	;"set baud 1200"
		DW	0005H		;
		DB	'240','0'+80H	;"set baud 2400"
		DW	0006H		;
		DB	'480','0'+80H	;"set baud 4800"
		DW	0007H		;
		DB	'960','0'+80H	;"set baud 9600"
		DW	0008H		;
		DB	0		;<<== end of baudrate table
;
;	PBAUD baudrate generator lookup table
;
BDTBL2:		DB	0H		;110 baud (not supported)
		DB	28H		;300 baud
		DB	0		;450 baud (not supported)
		DB	4FH		;600 baud
		DB	0		;710 baud (not supported)
		DB	28H		;1200 baud
		DB	14H		;2400 baud
		DB	0AH		;4800 baud
		DB	5H		;9600 baud
		DB	0H		;19200 baud (not supported)
;
;	Table of SHOW subroutine addresses
;
SHOTBL:		DW	SHBAUD		;show baud rate
		DW	SHPRTY		;show parity setting
		DW	SHSTOP		;show no. of stop bits
		DW	SHBITS		;show bits/character
		DW	SHPORT		;show port address
;
	IF HAYES
		DW	SHSPKR		;show modem speaker status
		DW	SHDLY		;show hangup delay
		DW	SHMODE		;show answer or originate
		DW	SHDIAL		;show pulse or tone
	ENDIF
;
		DW	0		;<<== end of show address list
;
;	SET PARITY command table
;
PARTBL:		DB	'OF','F'+80H	;"set parity off"
		DW	PROFF
		DB	'EVE','N'+80H	;"set parity even"
		DW	PREVEN
		DB	'OD','D'+80H	;"set parity odd"
		DW	PRODD
		DB	0		;<<== end of parity table
;
;	SET STOPBITS command table
;
STPTBL:		DB	'1'+80H		;"set stop 1"
		DW	STOP01
		DB	'2'+80H		;"set stop 2"
		DW	STOP02
		DB	'1.','5'+80H	;"set stop 1.5"
		DW	STOP15
		DB	0		;<<== End of table
;
;	SET PORT command table
;
PORTBL:		DB	'J','5'+80H	;"set J5"
		DW	PORTJ5
		DB	'J','6'+80H	;"set J6"
		DW	PORTJ6
		DB	0		;<<== End of stop-bits table
;
MDMTBL:		DB	'EX','T'+80H	;"EXTERANL MODEM"
		DW	EXTMDM
		DB	'IN','T'+80H	;"INTERNAL MODEM"
		DW	INTMDM
		DB	0		;<<== End of table

;
;	SET LENGTH command table
;
BITTBL:		DB	'5'+80H		;"set bits 5"
		DW	BIT5
		DB	'6'+80H		;"set bits 6"
		DW	BIT6
		DB	'7'+80H		;"set bits 7"
		DW	BIT7
		DB	'8'+80H		;"set bits 8"
		DW	BIT8
		DB	0		;<<== end of bpc table
;
	IF HAYES
;
;	SET MONITOR command table
;
MONTBL:		DB	'O','N'+80H	;"set monitor on"
		DW	0001H
		DB	'OF','F'+80H	;"set monitor off"
		DW	0000H
		DB	0		;<<== end of monitor table
;
;	SET DELAY command table
;
DLYTBL:		DB	'1','5'+80H	;"set delay 15"
		DW	STDL15
		DB	'3','0'+80H	;"set delay 30"
		DW	STDL30
		DB	'4','5'+80H	;"set delay 45"
		DW	STDL45
		DB	'6','0'+80H	;"set delay 60"
		DW	STDL60
		DB	0		;<<== end of delay table
;
;	SET MODE command table
;
MODTBL:		DB	'ORI','G'+80H	;"set mode orig"
		DW	0000H
		DB	'ANSWE','R'+80H	;"set mode answer"
		DW	0001H
		DB	0		;<<== end of mode table
;
;	SET DIAL command table
;
DIALTB:		DB	'TON','E'+80H	;"set dial tone"
		DW	0054H
		DB	'PULS','E'+80H	;"set dial pulse"
		DW	0050H
		DB	0		;<<== end of dial table
	ENDIF
;
	END



;
BITTBL:		DB	'5'+80H		;"set bits 5"
		DW	BIT5
		DB	'6'+80H		;"set bits 6"
		DW	BIT6
		DB	'7'+80H		;"set bits 7"
		DW	B