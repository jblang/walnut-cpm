;
; MXO-MR10.ASM - Morrow Micro Decision MD-11 overlay file for MEX
;                or MDM712.
; 6/28/84
;
;  (Adapted from M712MD.ASM, originally for Morrow MD-2 & MD-3)
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts either modem program to the Morrow MD-11 computer.
; (It is not for use with the Morrow MD-2 or MD-3 computers.)
; While this computer has a number of serial ports, one is used for the
; terminal and the another for the printer/modem.  To use this
; overlay, you must use the CP/M program "SETUP" to set the printer/
; modem port to 1200 baud.  (This is usually done automatically upon
; a boot.)  Configure the internal jumpers to make the port a DTE
; type of device (page D-16 in my MD-11 User's Guide) for use with
; modems.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.  If you exit
; the program while at 300 baud, re-boot the Morrow before proceeding
; in order to reprogram the Zilog DART to the correct clock ratio.
; (The SET command alters the DART clock divide ratio, not the
; clock frequency itself).  Exiting the program when set to 1200
; baud causes no such concern. (This advice only applies to usage
; of the SET command).
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program on the original MDM712.COM file (or
;               follow the instructions with MEX to overlay MEX10.COM).
;
;		For MDM712:
;
;		A>SAVE
;		A>DDT MDM712.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4300 0100
;		-IMXO-MR10.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(that's a zero: return to CP/M)
;
;		CP/M 3 SAVE - Version 3.0
;		Enter file (type RETURN to exit): MODEM7.COM
;		Beginning hex address 0100
;		Ending hex address    4300
;		A>
;
;		You now have MODEM7.COM (or MEX.COM) for use on the
;		Morrow MD-11.
;	
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/28/84 - Further revisions & renamed for MEX- Steve Reyer
; 05/28/84 - Revised for use on Morrow MD-11    - Steve Reyer
; 07/21/83 - Renamed for use with MDM712	- Irv Hoff
; 07/01/83 - Revised for use with MDM711	- Irv Hoff
; 06/22/83 - Revised for use with MDM710	- Irv Hoff
; 06/22/83 - Altered MDM708DP for Morrow
;	     Micro Decision computers using
;	     an external modem			- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
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
PORT:		EQU	62H		;Morrow MD-11 prt/modem port
MODCTL1:	EQU	PORT+1		;Modem status port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem control port
;
; The following was added by Reyer to define the Zilog DART
;
MODSNDB:	EQU	04H		;bit to test for send 
MODSNDR		EQU	04H		;value when ready     
MODRCVB		EQU	01H		;bit to test for recv 
MODRCVR		EQU	01H		;value when ready     
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;


PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=Touch, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
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
LSTTST:		DB	YES	;no=using modem on printer port		119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from phone line	121H
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
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port	     	12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7		;
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;Reyer: These lines were
CPI$MODRCVR:	CPI	MODRCVR	! RET	;added to make it similar to
ANI$MODSNDB:	ANI	MODSNDB	! RET	;similar overlays where the
CPI$MODSNDR	CPI	MODSNDR	! RET	;UART flags needed testing
		DS	12		;
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	16EH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
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
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
; The SCRNTST option must be set "YES" for these to work.  These are now
; set for the Morrow MDT-60 terminal.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'*',0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Morrow MD-11 hard-disk computer'
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
; CTL-O if TRANLOGON has been set YES.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	  DB	'This is a Morrow MD-11 computer',CR,LF,0
;.....
;
;
;=======================================================================
; Extensive changes from the original Morrow overlay, M712MD.ASM
; have been made below by Reyer to accomodate the MD-11 and its
; Zilog DART (Dual UART).  Notation such as "REG. 5" refers to
; write-registers in the Zilog DART.
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,05H		;SELECT REG. 5
	  OUT	MODCTL1
	  MVI	A,0FAH		;SEND BREAK ONLY
	  OUT	MODCTL1
	  JMP	GOODBYE1	;GO TO WAIT
;...
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,05H		;REG. 5
	  OUT	MODCTL1
	  MVI	A,7AH		;DTR OFF AND BREAK SENT
	  OUT	MODCTL1
GOODBYE1: MVI	B,3		;300 MS.
	  CALL	JMP$TIMER
	  MVI	A,05H		;REG. 5
	  OUT	MODCTL1
	  MVI	A,0EAH		;DTR ON, NO BREAK
	  OUT	MODCTL1
	  RET
;
;
;
;.....
;
;
; No initialization other than using SETUP (if needed) from
; CP/M is required.  The following is part of the SET
; command code.  (see OK300, OK1200, LOADBD, below).
;
INITMOD:  MVI	A,5		;TRANSFER TIME FOR 1200 BAUD
	  STA	MSPEED	
	  MVI	A,04H		;SELECT REG. 4
	  OUT	MODCTL1
INITMOD1: MVI	A,44H		;DEFAULT TO /16 FOR 1200 BAUD
	  OUT	MODCTL1
	  IN	PORT		;CLEAR DATA PORT
	  RET
;.....
;
;
SETUPR:	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, TELL OPERATOR
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  MVI	B,0C4H		;DIVIDE BY 64 FOR 300 BAUD
	  JMP	LOADBD		;GO LOAD THEM
;
OK1200:	  MVI	A,5
	  MVI	B,44H		;DIVIDE BY 16 FOR 1200 BAUD
;
;
LOADBD:	  STA	INITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,B		;GET BAUDRATE BYTE
	  STA	INITMOD1+1	;STORE IN INITMOD
	  JMP	INITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;		
;
; These routines can be used for your equipment, be sure to end with RET
;
SPCLMENU: RET
;		
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem).
;
	  END
;
                                                               