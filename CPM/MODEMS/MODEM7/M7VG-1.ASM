; M7VG-1.ASM -- Vector Graphic overlay file for MDM7xx 
; 01/08/84
;
; This overlay will assemble to operate MDM7xx with a Vector 3 or 4 
; with an external modem driven by the Vector's RS-232 modem port.  You will 
; want to look this file over carefully. There  are a number of options 
; that you can use to configure the program to suit your taste.  Much of 
; the information contained here is not in the main file.
;
; The source can be modified from the syntax of the ASM assembler that comes 
; with most CP/M systems to that of the ZSM assembler that comes with 
; Vector CP/M systems in four steps:
;
;  -globally replace all occurrences of the character $ (dollar sign) with
;   the character _ (underscore)
;
;  -globally replace all occurrences of the string DB<HT>' (DB followed 
;   by an ASCII HT (09h,^I) followed by a single quote) with DT<HT>' 
;   (ZSM requires the psuedo-op DT for strings of >1 character)
;
;  -globally replace all occurrences of IF<HT>NOT VECTOR4 with 
;   IFF<HT>VECTOR4 and all IF<HT>VECTOR4 with IFT<HT>VECTOR4
;
;  -delete the last line in the file (ZSM doesn't need an END pseudo-op)
;
; On a Vector 4, the program will come up running at 1200 baud, which can 
; be changed using the "SET" command or by changing the equates before 
; assembling.  On a Vector 3, the program will come up at whatever baud 
; rate has been set by the hardware switches.
;
; It is currently set up for a Vector 4.  To assemble for a Vector 3, change
; the VECTOR4 equate to NO and the clock and baud bytes appropriately. 
; The Vector 4 appears to scroll the screen just slowly enough to cause
; a couple of missed characters at the start of each line when operating at
; 1200 baud.  This can be fixed by using whatever command the system you
; are communicating with accepts to tell it to insert a short delay between 
; lines as it transmits.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;       TO USE: First edit this file filling in answers for your own
;               equipment.  Then assemble with ASM.COM or equivalent
;               assembler.  Then use DDT to overlay the the results
;               of this program to the original .COM file:
;
;               A>DDT MDM7xx.COM
;               DDT VERS 2.2
;               NEXT  PC
;               4300 0100
;               -IM7VG-1.HEX            (note the "I" command)
;               -R                      ("R" loads in the .HEX file)
;               NEXT  PC
;               4300 0000
;               -G0                     (return to CP/M)
;               A>SAVE 66 MDM7xx.COM    (now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 01/08/84 - Modified for Vector 3 and 4 	- Ross Alford
;						  ...duke!ecsvax!alford
; 11/10/83 - Modified for Vector 4 computers	- Loren Cook
; 07/27/83 - Renamed to work with MDM712       	- Irv Hoff
; 07/01/83 - Revised to work with MDM711       	- Irv Hoff
; 06/22/83 - Revised to work with MDM710       	- Irv Hoff
; 05/25/83 - Updated to work with MDM709       	- Irv Hoff
; 05/15/83 - Revised to work with MDM708       	- Irv Hoff
; 04/11/83 - Updated to work with MDM707       	- Irv Hoff
; 04/04/83 - Updated to work with MDM706       	- Irv Hoff
; 02/27/83 - Updated to work with MDM705       	- Irv Hoff
; 02/17/83 - Modified MDM703CF for Datapoint
;            1560 computers using an exter-
;            nal modem                          	- Irv Hoff
;
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
PORT:           EQU     04H             ;Vector Graphic modem data port
MODCTL1:        EQU     PORT+1          ;Modem status port
MODCTL2:        EQU     PORT+1          ;Modem control port
MODDATP:        EQU     PORT            ;Modem data port
;
VECTOR4		EQU	YES		;assemble for Vector 4
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;

PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem			104H
TONEPULSE:	DB 	'T'	;T=tone, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	51	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	0	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	0	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
;
; baud change routine available for Vector 4
;
		IF	VECTOR4	
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
		ENDIF
;
; no baud change for Vector 3
;
		IF	NOT VECTOR4
SETUPTST:	DB	NO	;no=no user-added Setup routine		10BH
		ENDIF
;
SCRNTEST:	DB	YES	;cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after a non-ACK	10DH
				;no=resend a record only after NAK
BAKKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	NO	;yes=default to CRC checking		10FH
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
XOFFTST:	DB	YES	;yes=chcks for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
;
BRKCHR		DB 	'B'-40H	;Send a 300 ms. break tone		120H
NOCONNCT:	DB 	'N'-40H	;^N = Disconnect from phone line	121H
LOGCHR:		DB 	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB 	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB 	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB 	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB 	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB 	'\'-40H	;^\ = Send next character		127H
;
                DS      2               ;                               128H
;
IN$MODCTL1:     IN      MODCTL1         ;in modem control port          12AH
		RET
                DS      7
OUT$MODDATP:    OUT     MODDATP 	;out modem data port            134H
		RET
                DS      7
IN$MODDATP:     IN      MODDATP 	;in modem data port             13EH
		RET
                DS      31
;
LOGONPTR:       DW      LOGON           ;for user message.              160H
                DS      6               ;                               162H
JMP$GOODBYE:    JMP     GOODBYE         ;                               168H
JMP$INITMOD:    JMP     INITMOD         ;go to user written routine     16BH
                RET  			;(by-passes PMMI routine)       16EH
		NOP
		NOP
                RET			;(by-passes PMMI routine)       171H
		NOP
		NOP
                RET			;(by-passes PMMI routine)       174H
		NOP
		NOP
JMP$SETUPR:     JMP     SETUPR          ;                               177H
JMP$SPCLMENU:   JMP     SPCLMENU        ;                               17AH
JMP$SYSVER:     JMP     SYSVER          ;                               17DH
JMP$BREAK:      JMP     SENDBRK         ;                               180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:      DS      3               ;                               183H
JMP$INBUF       DS      3               ;                               186H
JMP$INLNCOMP:   DS      3               ;                               189H
JMP$INMODEM     DS      3               ;                               18CH
JMP$NXTSCRN:    DS      3               ;                               18FH
JMP$TIMER:      DS      3               ;                               192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	; 				195H
		DB	010H,0,0,0,0	;Vector clr to end of scrn	198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	04H,0,0,0,0	;Vector clear screen   		1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
;
		IF	VECTOR4
		DB	'Version for Vector 4 '	
		ENDIF
;
		IF	NOT VECTOR4
		DB	'Version for Vector 3 '
		ENDIF
;
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
LOGON:		DB	'This is a Vector computer',CR,LF,0
;
;=======================================================================
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:	MVI	A,1FH
		JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:	MVI	A,15H		;Send break, turn off DTR
;
GOODBYE1:	OUT	MODCTL1		;Send to status port
	  	MVI	B,3		;Delay about 300 ms
	  	CALL	JMP$TIMER
	  	MVI	A,07H		;Normal send/receive with DTR
	  	OUT	MODCTL1		;Send to status port
	  	RET
;
;------------------------------------------------------------------------
; initialization routines
;
; just initialize the 8251 USART on a Vector 3
;
		IF	NOT VECTOR4
INITMOD:  	MVI   	A,40H		;internal 8251 reset
          	OUT   	MODCTL1
	  	MVI   	A,4EH		;8data, 1 stop, no parity, 16X baud
	  	OUT   	MODCTL1
          	MVI   	A,07H           ;normal command start
          	OUT   	MODCTL1
          	RET
		ENDIF			;vector 3 initialization
;
; Set baud rate and initialize 8251 if Vector 4
;
		IF	VECTOR4
;
; Vector 4 specific equates for initialization.
;
	
CTCCMD:		EQU	13H		;8253 Timer control/status port
CTC1:		EQU	11H		;Timer (1) port 011H
LSBAUD:	  	EQU	68H		;Default 1200 baud(LSB)
MSBAUD:	  	EQU	00H		;Default 1200 baud(MSB)
;
;
; Vector 4 initialization -- sets CTC timer for baudrate in/out.
;.....
INITMOD:  	MVI	A,5		;Default transfer time to 1200 baud
	  	STA	MSPEED
;
INITMOD1: 	MVI	A,76H		;Select Timer (1)
	  	OUT	CTCCMD
;
LSBD:	  	MVI	A,LSBAUD	;Send LSB of baud rate
	  	OUT	CTC1  
;
MSBD:	  	MVI	A,MSBAUD	;Send MSB of baud rate
	  	OUT	CTC1
;
; set up USART with data format
;
		MVI   	A,40H		;internal 8251 reset
          	OUT   	MODCTL1
	  	MVI   	A,4EH		;8data, 1 stop, no parity, 16X baud
	  	OUT   	MODCTL1
          	MVI   	A,07H           ;normal command start
          	OUT   	MODCTL1
          	RET
		ENDIF			;conditional Vector 4 initialization
;
;------------------------------------------------------------------------
; setup routines
;
; if Vector 3, no user setup routine
;
		IF	NOT VECTOR4
SETUPR:		RET
		ENDIF
;
; if Vector 4, setup routine for baud rate
;
		IF	VECTOR4
SETUPR:	  	LXI	D,BAUDBUF	;Point to new input buffer
	  	CALL	JMP$ILPRT
	  	DB	'Input Baud Rate (300, 600, 1200, 2400, '
	  	DB	'4800, 9600): '
		DB	0
	  	CALL	JMP$INBUF
	  	LXI	D,BAUDBUF+2
	  	CALL	JMP$INLNCOMP	;Compare BAUDBUF+2 with chars below
	  	DB	'300'
		DB	0
	  	JNC	OK300		;Go if got match
	  	CALL	JMP$INLNCOMP
	  	DB	'600'
		DB	0
	  	JNC	OK600
	  	CALL	JMP$INLNCOMP
	  	DB	'1200'
		DB	0
	  	JNC	OK1200
	  	CALL	JMP$INLNCOMP
	  	DB	'2400'
		DB 	0
	  	JNC	OK2400
	  	CALL	JMP$INLNCOMP
	  	DB	'4800'
		DB	0
	  	JNC	OK4800
	  	CALL	JMP$INLNCOMP
	  	DB	'9600'
		DB 	0
	  	JNC	OK9600
	  	CALL	JMP$ILPRT	;All matches failed, tell operator
	  	DB	'++ Incorrect entry ++'
		DB	CR,LF,BELL,0
	  	JMP	SETUPR		;Try again
;
OK300:	  	MVI	A,1		;MSPEED 300 baud value
	  	LHLD	BD300		;Get 300 baud parameters in 'HL'
	  	JMP	LOADBD		;Go load them
;
OK600:    	MVI	A,3
	  	LHLD  	BD600
	  	JMP	LOADBD
;
OK1200:	  	MVI	A,5
	  	LHLD	BD1200
	  	JMP   	LOADBD
;
OK2400:	  	MVI	A,6
	  	LHLD	BD2400
	  	JMP	LOADBD
;
OK4800:	  	MVI	A,7
	  	LHLD  	BD4800
	  	JMP	LOADBD
;
OK9600:	  	MVI	A,8
	  	LHLD	BD9600
	  	JMP	LOADBD
;
LOADBD:	  	STA	INITMOD+1	;Change time-to-send to match baudrate
	  	MOV	A,L		;Get least significant baudrate byte
	  	STA	LSBD+1		;Store in INITMOD
	  	MOV	A,H		;Get most significant baudrate byte
	  	STA	MSBD+1		;Store in INITMOD
	  	JMP	INITMOD		;Reinitialize to new baudrate, then done
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  	DW	01A1H		;  300 Baud
BD600:	  	DW	00D0H		;  600 Baud
BD1200:	  	DW	0068H		; 1200 Baud
BD2400:	  	DW	0034H		; 2400 Baud
BD4800:	  	DW	001AH		; 4800 Baud
BD9600:	  	DW	000DH		; 9600 Baud
;
BAUDBUF:  	DB	10,0
	  	DS	10
		ENDIF			;Vector 4 SET routine for baud rate
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;		
;
; These routines can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;		
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;                                0BC0H (without Smartmodem)
;
	  END
