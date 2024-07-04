; MXO-R+10.ASM -- Tandy TRS-80 Mod 4 under Digital Research's CP/M Plus.  
;			Overlay file for MEX -- 06/11/84
;
; This file is based on the M7R4-1 overlay for the Montezuma Micro 
; CP/M 2.2. It is heavily based on the Tandy Radio Shack Model I with
; Omicron CP/M 'Mapper' originally by Phil Becker and is credited as 
; such. 
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Tandy Model 4 computer to the modem program.
; Much of the information contained here is not in the main file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baud rate.  The program 
; starts out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Assemble with ASM, MAC or equivalent
;		assembler.  Then use MLOAD to overlay the results
;		of this program to the original .COM file:
;
;	A>MLOAD MEX.COM=MEX10.COM,MXO-R+10.HEX
;	A>
;	
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/11/84 - Modified for MEX10			- Len Moskowitz
; 02/02/84 - Modified to MDM724 with CP/M+      - Richard Press, M.D.
; 11/26/83 - Modified for the TRS80 Mod 4	- Steven J. Davidson, M.D.
;						& Richard Press, M.D.
; 08/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/25/83 - Adapted for TRS-80 (zero ORG CP/M)	- Phil Becker
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/25/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - First version of this file		- Irv Hoff
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
PORT:		EQU	0EAH		;TRS80 Mod 4 Modem Status Port
MODCT1:		EQU	PORT		;Modem status port
MODCT2:		EQU	PORT		;Modem control port
MODDAT:		EQU	PORT+1		;Modem data port
MDDCDB:		EQU	20H		;carrier detect bit
MDDCDA:		EQU	20H		;value when active
BAUDRP:		EQU	PORT-1		;Baud rate port
MDRCVB:		EQU	80H		;Recv. Ready Mask bit
MDRCVR:		EQU	80H		; -value when ready
MDSNDB:		EQU	40H		;xmit. ready mask bit
MDSNDR:		EQU	40H		; -value when ready
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
;
		ORG	100H
;
;
		DS	3	;(for  "JMP   START" instruction)
PMODEM:		DB	NO	;not used by MEX 			103H
SMODEM:		DB	NO	;not used by MEX			104H
TPULSE:		DB	'T'	;T=tone, P=Pulse(Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.8 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	3	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;cursor control routine 		10CH
		DB	YES	;spare
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
				;no=default to Checksum checking
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	YES	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:		DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:		DB	YES	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	19H
XOFTST:		DB	YES	;yes=chcks for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'B'-40H	;Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:		DB	'T'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'Y'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'R'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'K'-40H	;^K = Send next character		127H
;
PRATE:		DS	2	;PMMI equates (see PMMI overlay)	128H
;
INCTL1:		IN	MODCT1	 	;in modem control port		12AH
		PUSH	B
		ANI	0DFH
		MOV	B,A		;save status
		JMP	CTLPT2		;continue
		DS	1
;
OTDATA:		OUT	MODDAT ! RET	;out modem data port		134H
;
;
; CONTINUE STATUS READ
;
CTLPT2:		IN	0E8H		;read CD port
		ANI	20H		;isolate CD
		ORA	B		;merge status
		POP	B
		RET
;
INPORT:		IN	MODDAT ! RET	;in modem data port		13EH
		DS	7
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H

TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;not used by MEX		156H
;
LOGON:		DS	2		;not used by MEX		160H
DIALV:		DS	3		;dials digit (not implemented)	162H
DISCV:		DS	3		;disconnects modem (not impl.)	165H
GOODBV:		JMP	GOODBYE		;called before exit to CP/M	168H
INMODV:		JMP	INITMOD		;Called at cold start		16BH
NEWBDV:		DS	3		;not implemented		16EH
NOPARV:		DS	3		;not implemented		171H
PARITV:		DS	3		;not implemented		174H
SETUPV:		JMP	SETUPR		;SET command			177H
SPMENV:		DS	3		;not used with MEX		17AH
VERSNV:		JMP	SYSVER		;overlay's voice in sign-on	17DH
BREAKV:		JMP	SENDBRK		;send a break			180H
;
;
; These six lines are an artifact of MDMXXX. They are not used with MEX
;
ILPRTV:		DS	3	;replace with MEX function 9		183H
INBUFV:		DS	3	;replace with MEX function 10		186H
ILCMPV:		DS	3	;replace with table lookup funct. 247	189H
INMDMV:		DS	3	;replace with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX			18FH
TIMERV:		DS	3	;replace with MEX function 254		192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		MVI	C,ILP		;				195H
		CALL	MEX		; 				197H
		DB	01BH,04AH,0	;				19AH
		RET			;				19DH
;
CLRSCRN:	MVI	C,ILP		;				19EH
		CALL	MEX		;				1A0H
		DB	01BH,045H,0	;				1A3H
		RET			;				1A6H
;
;
;	End of the fixed format area
;
;
SYSVER:		MVI	C,ILP		;
		CALL	MEX		;
		DB	'*** Version for Tandy TRS80 Mod 4 ***'	
                DB      CR,LF
 		DB	'***  with Tandy/DRI CP/M Plus   ***'
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
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:
	MVI	A,0E8H		; 8 bit words, 1 stop bit, no parity,
	JMP	GOODBYE1	; DTR & RTS disabled, *BREAK bit SET*
;
;.....
;
; The Goodbye routine is the last routine run before exiting to CP/M.
; If you share the serial port between the modem and some other device,
; you can use Goodbye to change the characteristics of the port.
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:
;
	MVI	A,0EBH			;send break, turn off DTR
;
GOODBYE1:
;
	OUT	MODCT1		;send to status port
	MVI	B,3		;delay about 300 ms.
	MVI	C,TIMER
	CALL	MEX
	MVI	A,0ECH		;normal send/receive with DTR
	OUT	MODCT1		;send to status port
	RET
;
;
; TRS80 Mod 4 initialization -- sets CTC timer 0 for baudrate in/out.
;
; TRS80 Mod 4 specific equates for initialization.
;
CTCCMD:	  EQU	0E8H		;Master Reset, UART cntrl. register
CTC0:	  EQU	0E9H		;BR19411 Timer control Timer 0 (port A)
IB300	  EQU	55H		;Default 300 baud
;
INITMOD:  MVI	A,1		;Reset UART and enable it
	  OUT	CTCCMD		
;
	  MVI	A,0ECH		;8 bits, no parity, 1 stop bit, enable DTR
	  OUT	MODCT1		;				and RTS
;
LSBD:	  MVI	A,IB300
	  OUT	CTC0  
;
INITMOD1: MVI	A,1		;default transfer time to 300 baud
	  STA	MSPEED
	  RET
;
;.....
;
;
SETUPR:	  MVI	C,SBLANK	;any parameters?
	  CALL  MEX
	  JC    TELL		;if not, go display current baud rate
	  LXI	D,CMDTBL	;use MEX LOOKUP function to get a jump
	  MVI	C,LOOKUP	; vector if the parameter is valid
	  CALL	MEX		;parse parameter to SET
	  PUSH	H		;MEX LOOKUP returns with the address of the
				; baud rate change routine in HL.  Save it 
				; on the stack.
	  RNC			;return to the baud rate change routine
	  POP	H		;oops, the parameter to SET was not in our
				; table. 
	  MVI	C,ILP		;
	  CALL	MEX		;tell the user that the baud rate he asked
				; for is illegal
	  DB	CR,LF,'Only 300, 600, 1200, 4800, 9600, and 19200 allowed in'
	  DB	'SET command',CR,LF,0
	  RET
;
; SET command table - this table is used by the MEX LOOKUP routine.  Note
;	that the first part of each entry is the string we match against.
;	Its last character must have its MSBit set.  The second part of
;	the entry is the value we want returned in HL.  This is a painless
;	way to do a string comparison and branch function. 
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'60','0'+80H
	  DW	OK600
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'480','0'+80H
	  DW	OK4800
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	'1920','0'+80H
	  DW	OK19200
;
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;print current baud rate
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in 'HL'
	  JMP	LOADBD		;go load them
;
OK600:    MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP   LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
OK19200:  MVI	A,9
	  LHLD	BD19200		;fall thru.....
;
LOADBD:	  STA	INITMOD1+1	;change time-to-send to match baudrate
	  MOV	A,L		;get baudrate byte
	  STA	LSBD+1		;store in INITMOD
	  JMP	LSBD		;reinitialize to new baudrate, then done
	  RET		
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	DB	55H		;  300 baud
BD600:	DB	66H		;  600 baud
BD1200:	DB	77H		; 1200 baud
BD4800:	DB	0CCH		; 4800 baud
BD9600:	DB	0EEH		; 9600 baud
BD19200:
;
	DB	0FFH		;19200 baud
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;
;	Your overlays may use memory up to 0CFFH, unless you are
;	using the MEX Smartmodem overlay (MXO-SMxx.ASM).  Then
;	you have only up to 0AFFH.
;
;=======================================================================
;
	  END
