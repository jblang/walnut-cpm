
; M7NH.ASM NorthStar Horizon with HSIO-4 overlay for MDM7xx - 11/11/83
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MDM7xx "SET" command to change the baudrate when desired.  It
; starts out at 300 baud when the program is first called up.
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
;		4300 0100
;		-IM7NH-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7NH-1.ASM, no changes	- Irv Hoff
; 09/11/83 - Changed M712HZ.ASM TO M712NS.ASM	- Robert Lehman
;						- Irv Hoff
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
PORT:		EQU	10H		;Port A on HSIO-4
BAUDRP:		EQU	PORT
MODDATP:	EQU	PORT+2		;data port for N*HOR
MODCTL1:	EQU	PORT+3		;status port for N*HOR
MODRCVB:	EQU	2		;bit to test for received data
MODRCVR:	EQU	2		;modem receive ready
MODSNDB:	EQU	1		;bit to test for ready to send
MODSNDR:	EQU	1		;modem send ready bit
;
;
; The HSIO-4 board uses the 8251
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
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
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
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
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		125H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		126H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	31
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
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,079H,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1AH,0,0,0,0	;clear entire screen		1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for NorthStar Horizon / HSIO-4 Port A'
		DB	CR,LF,0
		DB	RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes available) otherwise.
;
;-----------------------------------------------------------------------
;
; YOU CAN PUT IN A MESSAGE AT THIS LOCATION WHICH CAN BE CALLED UP WITH
; CTL-O IF TRANLOGON HAS BEEN SET YES.	YOU CAN PUT IN SEVERAL LINES IF
; DESIRED.  END WITH A 0.
;
LOGON:	  DB	'Hello from a NorthStar Horizon computer',CR,LF,0
;.....
;	
;
; THIS ROUTINE ALLOWS A 300 MS. BREAK TONE TO BE SEND TO RESET SOME
; TIME-SHARE COMPUTERS.
;
SENDBRK:  MVI	A,08H		;send a break tone for 300 ms.
	  JMP	GOODBYE1
;.....
;
;
; THIS ROUTINE SENDS A 300 MS. BREAK TONE AND SETS DTR LOW FOR THE SAME
; LENGTH OF TIME TO DISCONNECT SOME MODEMS SUCH AS THE BELL 212A, ETC.
;
GOODBYE:  MVI	A,0AH		;set break, dtr low
;
GOODBYE1: OUT	MODCTL1		;put command register out of mode
	  IN	MODCTL1		;make sure it is now clear
	  IN	MODCTL1		;try once more
	  MVI	B,3		;delay for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,37H		;reset rts, flags, dtr low, enable r/t
	  OUT	MODCTL1		;send to command register
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET
;.....
;
;
; THE FOLLOWING ARE USED IN SETTING UP THE HSIO-4 I/O PORT A.
;
INITMOD:  MVI	A,1		;default transfer time to 300 baud
	  STA	MSPEED
	  XRA	A		;set rts, flags, dtr, disable r/t
	  OUT	MODCTL1		;put command register out of mode
	  IN	MODCTL1		;make sure it is now clear
	  IN	MODCTL1		;try once more
	  MVI	A,0AAH
	  OUT	MODCTL1
	  MVI	A,40H
	  OUT	MODCTL1
	  MVI	A,4EH		;1 stop, no parity, 8 bits, 16x asynch
	  OUT	MODCTL1		;send to mode register 1
;
INITMOD1: MVI	A,06H		;start with 300 baud, internal 4 clock
	  OUT	BAUDRP		;send to baud rate port
	  MVI	A,37H		;reset rts, flags, dtr low, enable r/t
	  OUT	MODCTL1		;send to command register
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET
;.....
;
;
; THE FOLLOWING CHANGES THE BAUD RATE WITH THE SET COMMAND.
;
SETUPR:	  LXI	D,BAUDBUF
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (110, 300, 1200, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP
	  DB	'110',0
	  JNC	OK110
	  CALL	JMP$INLNCOMP	;compare baudbuf+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;all matches failed, ask again
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK110:	  MVI	A,0		;mspeed 110 baud value
	  LHLD	BD110		;get 110 baud parameters in 'HL'
	  JMP	LOADBD		;go load them
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:	  STA	INITMOD+1
	  MOV	A,L		;get least significant baud rate byte
	  STA	INITMOD1+1	;store in initmod1
	  JMP	INITMOD		;reset n*hor hsio-4 port a
;.....
;
;
; TABLE OF BAUDRATE PARAMETERS FOR HSIO-4 BOARD I/O
;
BD110:	  DW	0007H
BD300:	  DW	0006H
BD1200:	  DW	0004H
BD9600:	  DW	0001H
;
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; THE FOLLOWING ROUTINE COULD BE USED TO DISPLAY SELECTIONS OF INTEREST
; TO OWNERS OF THIS COMPUTER.  IF USING THE HAYES SMARTMODEM THIS IS
; UNAVAILABLE WITHOUT A SPECIAL CHANGE.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (WITH SMARTMODEM)
;				 0C00H (WITHOUT SMARTMODEM)
;
	  END
;
110		;get 110 baud parameters in 'HL'
	  JMP	LOADBD		;go load them
;
OK300:	  MVI	A,1
	 