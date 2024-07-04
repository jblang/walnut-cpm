
; M7H8-2-1.ASM -- Heath/Zenith H8/H89 overlay file for MDM7xx.COM
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Heath/Zenith equip-
; ment with 2651/2661 PCI serial I/O. Much of the information contained
; here is not in the main file.   If not using the Heath  H8,  H89 with
; 2651, or 2661 PCI I/O, but with the 8250 serial I/O, then use M7H8-1.
; ASM overlay.   If not using Heath/Zenith equipment,  some of the rou-
; tines here will illustrate what you could do with your equipment.
;
;
; Use the "SET" command to change baudrate when desired.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7H8-2-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;
;	NOTE!:  Be sure to check the NEXT address above with what you get
;		when you load MDM7xx.COM with DDT.   If the two addresses
;		differ, you need to adjust the number of  'PAGES' to SAVE
;		by the amount of the differance.   If the address you get
;		is larger, then add the differance to the number of pages
;		to SAVE.  If it is smaller, then subtract the differance.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 13-MAY-86  - Revised to work with H8 / H89  2651/2661 PCI USART   - WEA
; 06-APR-86  - Updated to work with H8 2651 I/O. Renamed M7H8-2.ASM - WEA
; 11/11/83 - Renamed to M7H8-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Revised to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/17/83 - Revised to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
; 02/17/83 - Updated to work with MDM704	- Irv Hoff
; 02/07/83 - Updated to work with MDM703	- Irv Hoff
; 01/27/83 - Updated to work with MDM702	- Irv Hoff
; 01/10/83 - Updated to work with MDM701	- Irv Hoff
; 10/03/82 - First version of this file
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
; Change the value at MODDATP if it does not match what you are using.
;
MODDATP:	EQU	340Q		;data port for H8 2651 PCI
MODCTL1:	EQU	MODDATP+1	;status port for H8 2651/2661 PCI
MODRCVB:	EQU	2H		;bit to test for Receiver Ready
MODRCVR:	EQU	2H		;Receive Holding Reg. Has DATA
MODSNDB:	EQU	1H		;Bit to Test for Transmiter Ready.
MODSNDR:	EQU	1H		;TxRDY bit TRUE
MODEREG:	EQU	MODDATP+2	;2651 Mode Regs. 1&2 Port Address
CMDREG:		EQU	MODDATP+3	;2651 Command Reg. Port Address
;
;
		ORG	100H
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	NO	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'K'-40H	;^K = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; The following clear the screen for the H19 or H89 terminal
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'J',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'E',0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Heath H8/H89 with 2651/2661'
		DB	CR,LF,'PCI - USART I/O - Rel 2.1'
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'70225,1220',CR,LF,0
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
SENDBRK:  MVI	A,2FH		;SET BREAK TONE
	  OUT	CMDREG
	  JMP	GOODBYE1	;SEND A 300 MS. BREAK TONE
;.....
;
;
; This routine sends a 300 ms. break tone and set DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,0DH		;SET BREAK TONE, AND
	  OUT	CMDREG		;RESET 'DTR' AND 'RTS' NOT TRUE
;
GOODBYE1: MVI	B,3		;WAIT 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,27H		;RESET BREAK TO NORMAL, AND
	  OUT	CMDREG		;SET 'DTR', AND 'RTS' TRUE
	  RET
;.....
;
;
; The following is used to initialize the H8 2651/2661 MODEM I/O port
; at 340Q.
;
INITMOD:  MVI	A,1		;default transfer speed to 300 baud
	  STA	MSPEED
	  DI			;turn off interrupts for init.
	  MVI	A,4EH		;16x Baud Rate Factor, 8 Data Bits,
				;No Parity, 1 Stop Bit.
	  OUT	MODEREG		;Set up Mode Reg. 1.
LSPSPD:	  MVI	A,35H		;default to 300 baud, Internal clocks.
	  OUT	MODEREG		;Set up Mode Reg. 2.
;
	  MVI	A,27H		;Set 'DTR', 'RTS', RxEN, and TxEN True.
	  OUT	CMDREG		;Set up Modem Port Command Register.
	  EI			;restore interrupts to normal
	  RET
;.....
;
;
; The following routine changes the baud rate for the H8 with the SET
; command.
;
SETUPR:	  LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 600, 1200, 2400, 4800, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'2400',0
	  JNC	OK2400
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  JNC	OK4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;NO MATCH - tell operator
	  DB	'++ INCORRECT ENTRY ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1		;MSPEED Baud Rate Value
	  LXI	H,BD300		;Point to Baud Rate Parameter's Table Add.
	  JMP	LOADBD		;Go Store It.
;
OK600:	  MVI	A,3
	  LXI	H,BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LXI	H,BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LXI	H,BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LXI	H,BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LXI	H,BD9600
;
LOADBD:	  STA	INITMOD+1	;store speed to show transfer time
	  MOV	A,M		;Get Baud Rate Byte From Table.
	  STA	LSPSPD+1	;store in INITMOD
	  JMP	INITMOD		;reset-up H8 2651 Mode Registers.
;
;
; Table of baud rate parameters
;
BD300:	  DB	35H
BD600:	  DB	36H
BD1200:	  DB	37H
BD2400:	  DB	3AH
BD4800:	  DB	3CH
BD9600:	  DB	3EH
;
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; This routine can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
-------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartm