; MXO-EP30.ASM -- Epson QX-10 overlay for MEX112.COM  10/06/84
;
; J. L. Bewley
;
; This file is an assembly source code overlay for use with
; Ron Fowler's MEX112.COM "Modem Executive" communications
; program.  (This overlay will work equally well with MEX110
; and MEX111.)  This overlay adapts the MEX program for
; use on the Epson QX-10 computer.  Several notable improvements
; over the older MXO-EP12.ASM overlay are present.  Most noticeably,
; the "SET" command has been expanded to allow setting the data
; word length (5, 6, 7, or 8 bits), parity (odd, even, off),
; stop bits (1, 1.5, or 2), turning the Hayes Smartmodem (tm)
; speaker on/off, setting the carrier detect time (15, 30, 45, or
; 60 seconds), setting the Baud rate (110, 300, 600, 1200, 2400,
; 4800, or 9600 bps), setting the modem mode (originate/answer),
; and setting the method of dialing (pulse/tone).  These features
; can be set only on the Hayes Smartmodem or truly compatible
; "compatibles."  I have only tested this overlay with the Hayes
; Smartmodem.  It should be noted by Epson QX-10 owners that
; this overlay will NOT work with the internal Comrex CR-103
; modem.  This overlay INCLUDES the Hayes modem overlay, revision
; level 1.1.
;
; Revision 3.0
; October 6, 1984
; James L. Bewley  (Jim)
; VP, Mile High Epson User's Group
; Denver, Colorado
;
; I can be reached at the TBBS HQ BBS system at (303) 690-4566
; (300/1200 bps., 24-hrs., Colorado)
;
; For this overlay to work properly, the DIP switches behind
; the front panel on the Hayes should be set as follows:
;
; Switch:
;   #1   #2   #3   #4   #5   #6   #7   #8
;   UP   UP   DN   UP   DN   UP   DN   DN
;
; In general, these switch settings are compatible with Valdocs.
;
;
; I want it made clear that the majority of the work done in this
; overlay was done by Norm Saunders, Smith-Quinn, and Mark Pulver
; whose collective efforts resulted in the MXO-KP30 overlay for
; the Kaypro computers.  I was so impressed with the final product
; of these folks' work that I took the liberty of modifying their
; Kaypro overlay for use on the Epson QX-10.  Mostly I just had
; to change a few equates and defaults at the beginning of the
; program and write a small bit of 8080 assembly code to handle
; the NEC 7201 Multi-Protocol Serial Controller chip used in
; the Epson QX-10.  This involved changing the baud rate tables
; from one-byte entries to two and modifying the indexing and
; loading code to accept these two-byte entries.  Norm Saunders
; indicates in his notes that he is accessible on the 
; Laurel SuperSystem at 301-953-3753.  In the comments in this
; overlay you will often see references to the "SIO" chip.  While
; the Epson QX-10 uses the NEC 7201 MPSC chip instead of the
; Zilog SIO chip, the "Serial Input/Output" comments are still
; appropriate.  Enjoy.   -- Jim Bewley
;
;
; It should be noted that this program initializes the Hayes
; modem to 1200 bps.  If you are using the Hayes 300 modem just
; load this program, type "SET BAUD 300", and then CLONE this
; setup back to disk.  You will then have a 300 baud version.
;
; To use this overlay with MEX112, first look at the equate tables
; and change any defaults you desire.  It should be acceptable for
; most folks just as it is.  Then, using ASM.COM, assemble this
; overlay to "MXO-EP30.HEX".  Finally, form your working copy of
; MEX (called MEX112QX.COM below) with MLOAD21 as follows:
;
;     MLOAD21 MEX112QX.COM=MEX112.COM,MXO-EP30.HEX
;
; Note the absence of the Smartmodem overlay.  This program,
; by necessity, includes the Smartmodem overlay.
;
;
;
;
REV		EQU	30		;overlay revision level
;
;======================================================================
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
;
;	Epson QX-10 port definitions
;
PORT		EQU	011H		;Base serial input/output port
MODCTL		EQU	PORT+2		;Modem control port
MODDAT		EQU	PORT		;Modem data port
;
;	Epson QX-10 bit definitions
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
		ORG	TPA
;
		DS	3	;(for  "JMP   START" instruction)
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly.  They will
; be moved in MEX 2.0.
;
SMODEM:		DW	TRUE	;true=HAYES modem, false=non-dialing	103H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=19200 default display
				;time for sending a file
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
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
TOGLBK:		DB	NO	;yes=allow toggling of bksp to rub	112H
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
XOFTST:		DB	NO	;yes=chks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
		DS	8	;not used by MEX			120H
;
		DS	2		;location for PMMI variables	128H
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
GOODBV:		RET ! NOP ! NOP		;dummied out for Hayes modem	168H
		ENDIF
;
INMODV:		JMP	NITMOD		;UART initialization		16BH
NEWBDV:		JMP	PBAUD		;Reset baud rate from library	16EH
NOPARV:		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
PARITV:		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETCMD		;Kaypro SET command		177H
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
INSTAT:		MVI	A,10H		;channel 0, reset interrupts.	
		OUT	MODCTL		;
		IN	MODCTL		;get the status bits
		RET			;
OUTDAT:		OUT	MODDAT		;out modem data port
		RET			;
INDAT:		IN	MODDAT		;in modem data port
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
		DB	CR,LF,'Version for Epson QX-10 Computer',CR,LF
		DB	'With HAYES external Smartmodem',CR,LF
		DB	'Revision:  JLB-'
		DB	REV/10+'0'
		DB	'.'
		DB	REV MOD 10 + '0'
		DB	CR,LF,CR,LF
		DB	'Type SET for Set-Command Syntax',CR,LF
		DB	'(Set syntax by N. L. Saunders)'
		DB	CR,LF,CR,LF,0
		RET
;
;	Send BREAK function
;
BREAK:		MVI	A,5		;select SIO register 5
		OUT	MODCTL
		MVI	A,0FAH		;send BREAK tone
;
	IF NOT SMODEM
		JMP	GDBY1
;
;	Set DTR low for 300ms (disconnects some modems)
;
GDBY:		MVI	A,5		;select SIO write-register 5
		OUT	MODCTL		;
		LDA	REG5		;get the register 5 control byte
		ANI	07FH		;reset bit 7 (pulls DTR low)
	ENDIF
;
GDBY1:		OUT	MODCTL
		MVI	B,3		;Delay 300 ms.
		MVI	C,TIMER
		CALL	MEX
		MVI	A,5
		OUT	MODCTL
		LDA	REG5		;Restore to normal
		OUT	MODCTL
		RET
;
;	Epson QX-10 Initialization Routines
;
NITMOD:		CALL	NITSIO		;initialize the SIO
		CALL	NTBAUD		;initialize the baud rate
;
	IF SMODEM
		CALL	NITMDM		;initialize the Hayes
	ENDIF
;
		RET			;
;
;	Initialize the NEC-7201 MPSC chip
;
NITSIO:		MVI	A,00H		;Select reg. 0
		OUT	MODCTL
		LDA	REG0		;Command byte
		OUT	MODCTL
		MVI	A,04H		;Select reg. 4
		OUT	MODCTL
		LDA	REG4		;Receive/transmit control byte
		OUT	MODCTL
		MVI	A,03H		;Select reg. 3
		OUT	MODCTL
		LDA	REG3		;Receiver logic byte
		OUT	MODCTL
		MVI	A,05H		;Select reg. 5
		OUT	MODCTL
		LDA	REG5		;Transmitter logic byte
		OUT	MODCTL
		RET
;
;	Initialize the baudrate generator
;
NTBAUD:		LDA	MSPEED		;get the speed code
		CALL	PBAUD		;go set it
		RET
;
;	Initialize the modem, if it's a Hayes-type
;
	IF SMODEM
NITMDM:		CALL	CRLF		;
		CALL	ILPRT		;
		DB	'Initializing modem:',CR,LF,0
		CALL	STSPK1		;
		CALL	CRLF		;
		CALL	STDL30		;initial delay = 30 secs.
		CALL	CRLF		;
		CALL	STMOD1		;
		CALL	CRLF		;
		CALL	SHDIAL		;
		CALL	CRLF		;
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
;	Epson QX-10 SET command processor
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
HLPMSG:		DB	CR,LF,'SET command - Epson QX-10 version:',CR,LF,LF
		DB	CR,LF,'SET BAUD 110 <or> 300 <or> 600 <or> 1200 <or>'
		DB	CR,LF,'        2400 <or> 4800 <or> 9600'
		DB	CR,LF,'SET PARITY OFF <or> EVEN <or> ODD'
		DB	CR,LF,'SET STOPBITS 1 <or> 1.5 <or> 2'
		DB	CR,LF,'SET LENGTH 5 <or> 6 <or> 7 <or> 8'
;
	IF SMODEM
		DB	CR,LF,'SET MONITOR ON <or> OFF'
		DB	CR,LF,'SET DELAY 15 <or> 30 <or> 45 <or> 60'
		DB	CR,LF,'SET MODE ORIG <or> ANSWER'
		DB	CR,LF,'SET DIAL PULSE <or> TONE'
	ENDIF
;
		DB	CR,LF,'SET ?  (show current settings)'
		DB	CR,LF,CR,LF,'$'
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
		RLC			;mult. MSPEED * 2 for Epson index
		MOV	E,A		;put MSPEED in DE
		MVI	D,0		;
		LXI	H,BDTBL2	;offset into the table
		DAD	D		;
		MOV	A,M		;get the baud-generator code
		ORA	A		;zero code is unsupported
		STC			;set carry in case it's unsupported
		JZ	PBAUD1		;if unsupported, then exit
		PUSH	PSW		;code is okay, set it!
		MOV	A,M		;get low byte
		OUT	06H		;send it
		INX	H		;increment index pointer
		MOV	A,M		;get high byte
		OUT	06H		;send it
		POP	PSW		;
		MOV	A,E		;get MSPEED code back
		RRC			;restore correct MSPEED value
		STA	MSPEED		;save it
		ORA	A		;return, no errors
PBAUD1:		POP	B		;
		POP	D		;
		POP	H		;
		RET			;
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
	IF SMODEM
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
		RET
;
; Here on an end-dial sequence
;
ENDIAL:		MVI	M,CR		;stuff end-of-line into buffer
		INX	H		;followed by terminator
		MVI	M,0
		LDA	TPULSE		;get overlay's touch-tone flag
		STA	SMDIAL+3	;put into string
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
SMANAL:		MVI	B,0		;prep connect code
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
DISCON:		MVI	B,20
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
EOSMSG:		DB	01BH,059H,0,0,0,'$'	;clear to end-of-screen
CLSMSG:		DB	01AH,0,0,0,0,'$'	;CLS, Home Cursor
;
; Default UART parameters in the following table
;
REG0:		DB	00011000B	;Reset channel A
REG3:		DB	11000001B	;Enable receive at 8 bits/char
REG4:		DB	01000100B	;No parity, 1 stop bit, clock X16
REG5:		DB	11101010B	;Enable transmit at 8 bits/char
;
SETEMS:		DB	CR,LF,'SET command error',BELL,CR,LF,CR,LF,'$'
;
	IF SMODEM
MONMSG:		DB	'ATM1',CR,0
NDELAY:		DB	30		;delay-time in seconds
DL15MS:		DB	'ATS7=15',CR,0
DL30MS:		DB	'ATS7=30',CR,0
DL45MS:		DB	'ATS7=45',CR,0
DL60MS:		DB	'ATS7=60',CR,0
MODMSG:		DB	'ATS0=0',CR,0
SMATN:		DB	'+++',0
SMDISC:		DB	'ATH',CR,0
SMDIAL:		DB	'ATDT '
DIALBF:		DS	52		;2* 24 char max, + CR + NULL + slop
DIALPT:		DS	2		;dial position pointer
     ENDIF
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
;
	IF SMODEM
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
BDTBL:		DB	'11','0'+80H	;"set baud 110"
		DW	0000H		;
		DB	'30','0'+80H	;"set baud 300"
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
BDTBL2:		DW	0240H		;110 baud
		DW	01A0H		;300 baud
		DW	0000H		;450 baud (not supported)
		DW	00D0H		;600 baud
		DW	0000H		;710 baud (not supported)
		DW	0068H		;1200 baud
		DW	0034H		;2400 baud
		DW	001AH		;4800 baud
		DW	000DH		;9600 baud
		DW	0000H		;19200 baud (not supported)
;
;	Table of SHOW subroutine addresses
;
SHOTBL:		DW	SHBAUD		;show baud rate
		DW	SHPRTY		;show parity setting
		DW	SHSTOP		;show no. of stop bits
		DW	SHBITS		;show bits/character
;
	IF SMODEM
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
		DB	0		;<<== End of stop-bits table
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
	IF SMODEM
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



