
; MXO-H811.ASM-- Heath/Zenith H89 overlay file for MEX. 05/23/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Heath/Zenith equip-
; ment with 8250 serial I/O.  Much of the information contained here is
; not in the main file.  If not using the Heath/Zenith H89/Z89 equipment
; some of the routines here will illustrate what you could do with your
; unit.
;
; Use the "SET" command to change baudrate when desired.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler. Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 07/27/84 - Added 9600 baud select		- Bucky Carr
; 05/23/84 - Corrected clear-screen error	- Biff Bueffel
; 05/19/84 - Converted for MEX10		- Biff Bueffel
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
MODDATP:	EQU	0D8H		;data port for H89
MODCTL1:	EQU	MODDATP+5	;status port for H89
MODRCVB:	EQU	1		;bit to test for received data
MODRCVR:	EQU	1		;modem receive ready
MODSNDB:	EQU	20H		;bit to test for ready to send
MODSNDR:	EQU	20H		;modem send ready bit
;
; MEX service processor stuff
;
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
;
PRINT	EQU	9		;BDOS print-string function
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
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
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
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
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
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
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
		DS	2		;Not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;Not used by MEX		17AH
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
JMP$TIMER	DS	3		;				192H
;
;
; The following clear the screen for the H19 or H89 terminal
;
CLREOS: 	LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for Heath/Zenith with 8250 I/O'
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0B00H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0D00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
SENDBRK:  MVI	A,40H		;SET BREAK TONE
	  OUT	MODDATP+3
	  JMP	GOODBYE1	;SEND A 300 MS. BREAK TONE
;.....
;
;
; This routine sends a 300 ms. break tgone and set DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  XRA	A
	  OUT	MODDATP+4	;SET DTR AND RTS LOW
	  MVI	A,40H		;SET BREAK TONE
	  OUT	MODDATP+3
;
GOODBYE1: MVI	B,3		;WAIT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX	
	  MVI	A,03H		;RESET TO NORMAL 8 BITS
	  OUT	MODDATP+3
	  MVI	A,01H
	  OUT	MODDATP+4	;RESET DTR HIGH
	  RET
;.....
;
;
; The following is used to initialize the H89 8250 I/O port
;
INITMOD:  MVI	A,5		;default transfer speed to 1200 baud
	  STA	MSPEED
	  DI			;turn off interrupts for init.
	  XRA	A
	  OUT	MODDATP+1	;interrupt enable register
	  MVI	A,80H		;insure out of mode to set baud rate
	  OUT	MODDATP+3	;line control register
	  OUT	MODDATP+3
;
LSPSPD:   MVI	A,60H		;default 'LSP' speed for 1200 baud
	  OUT	MODDATP		;register for 'LSP' speed if enabled
;
MSPSPD:   MVI	A,00H		;default 'MSP' speed for 1200 baud
	  OUT	MODDATP+1	;register for 'MSP' speed if enabled
;
	  MVI	A,03H		;8-level, 1 stop bit, no parity
	  OUT	MODDATP+3	;line control register
	  MVI	A,01H		;set 'DTR' for proper modem output level
	  OUT	MODDATP+4	;modem control register
	  EI			;restore interrupts to normal
	  RET
;.....
;
;
; The following routine changes the baud rate for the H89 with the SET
; command.
;
;
SETUPR:	  MVI	C,SBLANK	;Any arguments?
	  CALL	MEX
	  JC	TELL		;If not, go display baud
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;Tell user input not valid
	  DB	CR,LF,'300, 1200, or 9600 baud',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	0
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:   MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
LOADBD:   STA	INITMOD+1	;store speed to show transfer time
	  MOV	A,L		;get least significant baud rate byte
	  STA	LSPSPD+1	;store in INITMOD
	  MOV	A,H		;get most signifcant baud rate byte
	  STA	MSPSPD+1	;store in INITMOD
	  JMP	INITMOD		;reset H89 8250
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  CPI	8
	  JZ	OK9600
	  RET
;
;
; Table of baud rate parameters
;
BD300:	  DW	0180H
BD1200:	  DW	0060H
BD9600:   DW	000CH
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END
S