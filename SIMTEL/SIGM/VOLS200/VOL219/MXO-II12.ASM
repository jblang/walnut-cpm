;  MXO-II12.ASM-- InterSysytems VIO and H-Z19/29/49 file for MEX.  06/08/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the InterSystems VIO with
; the 2651 PCI and the H-Z19.  Much of the information contained here is
; not in the main file.  If you're not using the above named equipment,
; some of the routines here may give you some hints for your MEX patch.
;
; Use the "SET" command to change baud rate when desired.
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
; 06/08/84 - Changed to MEX labels MXO-II12.ASM - Len Moskowitz
; 06/04/84 - Changed to VIO/Z19 - MXO-II11.ASM  - Len Moskowitz
; 05/23/84 - Corrected clear-screen error	- Biff Bueffel
; 05/19/84 - Converted for MEX10 - MXO-H811.ASM	- Biff Bueffel
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
; VIO base address and port offsets. Set PORT to either PORTA or PORTB
;
VIOBASE		EQU	0		;set this to the base address of
					; your VIO board
PORTA		EQU	0		;serial port A is at base+0
PORTB		EQU	4		;serial port B is at base+4
PORT		EQU	VIOBASE+PORTB	;We use serial port B for the modem	
;
;
MODDAT:		EQU	PORT		;data port for VIO
MODCT1:		EQU	PORT+1		;status port for VIO
MDRCVB:		EQU	02		;bit to test for received data
MDRCVR:		EQU	02		;modem receive ready
MDSNDB:		EQU	01		;bit to test for ready to send
MDSNDR:		EQU	01		;modem send ready bit
;
; MEX service processor stuff.  Use instead of BDOS calls.  More detail
; in PM overlay.
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNNDRDY	EQU	251		;test for modem-send ready
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
PMODEM:		DB	NO	;not used by MEX			103H
SMODEM:		DB	NO	;not used by MEX			104H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal modNe file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DB	YES	;spare
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
				;no=default to Checksum checking
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES;	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	NO	;yes=printer available on printer port	119H
XOFTST:		DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
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
;
PRATE:		DS	2	;PMMI equates (see PMMI overlay)	128H
;
INCTL1:		IN	MODCT1 		;in modem control port		12AH
		RET
		DS	7		;spares
OTDATA:		OUT	MODDAT 		;out modem data port		134H
		RET
		DS	7
INPORT:		IN	MODDAT		;in modem data port		13EH
		RET
		DS	7
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;unused				154H
;
;
		DS	2		;Not used by MEX		160H
DIALV		DS	3		;Dials digit (not implemented)	162H
DISCV		DS	3		;Disconnects modem (not impl.)	165H
GOODBV:		JMP	GOODBYE		;called before exit to CP/M	168H
INMODV:		JMP	INITMOD		;go to user written routine	16BH
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
NOPARV:		DS	3		;set modem for no-parity	171H
PARITV:		DS	3		;set modem parity		174H
SETUPV:		JMP	SETCMD		;overlay implemented function	177H
SPMENV:		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;overlay's voice in sign-on	17DH
BREAKV:		DS	3		;send break (not implemented)	180H
;
;
; These six lines are an artifact of MDMXXX.  They are not used with MEX.
;
ILPRTV:		DS	3	;replace with MEX function 9		183H
INBUFV:		DS	3	;replace with MEX function 10		186H
ILCMPV:		DS	3	;replace with table lookup funct. 247	189H
INMDMV:		DS	3	;replace with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX 			18FH
TIMERV:		DS	3	;replace with MEX function 254		192H
;
;
; The following clears the screen for the H19/29/49 terminal.
; Each of the two routines must be exactly 9 bytes long.
;
CLREOS:		LXI	D,EOSMSG
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
;  End of the fixed format area.
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for InterSystems VIO and Z19/29/49'
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
; This routine can be used to make any necessary changes before exiting
; back to CP/M.  If you share a VIO port between a printer and a modem,
; you can use this routine to change the baud rate and other port 
; characteristics back to what the printer requires.
;
GOODBYE:  RET
;.....
;
;
; The following is used to initialize the VIO 2651 Modem I/O port
;
INITMOD:  MVI	A,1		;default transfer speed to 300 baud
	  STA	MSPEED
	  MVI	A,04EH		;Mode Register 1 word - 
				; 1 stop bit, no parity, 8 bits, Async * 16
	  OUT	PORT+2		;2651 mode port address
MODREG2:  MVI	A,35H		;Mode Register 2 word -
				; internal clocks, 300 Baud
	  OUT	PORT+2		;2651 mode port address
	  MVI	A,27H		;Command Register word - 
				; normal operation, RTS* forced low, reset
				; error normal, force break normal, receive
				; control enabled, DTR* forced low, transmit
				; control enabled
	  OUT	PORT+3		;2651 command port address
	  RET
;.....
;
;
; The following routine changes the baud rate for the VIO with the SET
; command.
;
;
SETCMD:	  MVI	C,SBLANK	;Any arguments?
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
	  DB	CR,LF,'Only 300 or 1200 allowed on SET command',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'120','0'+80H
	  DW	OK1200
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
	  LXI	H,BD300		;get pointer to 300 baud parameter in HL
	  JMP	LOADBD		;go load them
;
OK1200:	  MVI	A,5		;MSPEED 1200 baud value
	  LXI	H,BD1200	;get pointer to 1200 baud parameter in HL
;
LOADBD:	  STA	INITMOD+1	;store speed to show transfer time
	  MOV	A,M		;get mode register 2 word for new baud rate
	  STA	MODREG2+1	;store in INITMOD
	  JMP	INITMOD		;reinitialize VIO 2651
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  RET
;
;
; Table of baud rate parameters
;
BD300:	  DB	35H
BD1200:	  DB	37H
;
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END
;
