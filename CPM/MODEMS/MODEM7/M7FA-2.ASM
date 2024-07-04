; M7FA-2.ASM Franklin ACE overlay file for MDM7xx.  07/12/84
;
; This overlay file enables Franklin ACE computers with the Dual
; Interface Card and external modem to use the MDM7xx phone modem program.
;
;************************************************************************
;*									*
;*		    TESTED <<ONLY>> UP TO MDM740			*
;*									*
;************************************************************************
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MDM7xx.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
; Use the "SET" command to change the baudrate when desired.  
;
;---------------------------------------------------------------------
;
;       TO USE: First edit this file filling in answers for your own
;               equipment.  Then assemble with ASM.COM or equivalent
;               assembler.  Then use DDT to overlay the the results
;               of this program to the original .COM file:
;
;               A>DDT MDM7xx.COM
;               DDT VERS 2.2
;               NEXT  PC
;               yy00 0100
;               -IM7FA-2.HEX            (note the "I" command)
;               -R                      ("R" loads in the .HEX file)
;               NEXT  PC
;               yy00 0000
;               -G0                     (return to CP/M)
;               A>SAVE 73 MDM7xx.COM    (now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 07/12/84 - Fixed bug causing program to	- Jim McAfee
;            crash on start-up; added and 
;	     changed some routines.  
;	     Works with MDM740.
; 05/12/84 - Removed all non-ACE code           - Pete Holsberg
; 10/24/84 - Added code for Franklin ACE Dual
;	     Interface Card                     - Dave Warker
; 08/08/83 - Renamed to work with MDM712
; 07/27/83 - Renamed to work with MDM712        - Irv Hoff
; 07/01/83 - Revised to work with MDM711        - Irv Hoff
; 06/22/83 - Revised to work with MDM710        - Irv Hoff
; 05/27/83 - Updated to work with MDM709        - Irv Hoff
; 05/15/83 - Revised to work with MDM708        - Irv Hoff
; 04/11/83 - Updated to work with MDM707        - Irv Hoff
; 04/04/83 - Updated to work with MDM706        - Irv Hoff
; 02/27/83 - Updated to work with MDM705        - Irv Hoff
; 02/12/83 - Used MDM703CF to make this file
;            for Apple computers using a var-
;            iety of serial interface cards
;            with external modem.               - Bruce Kargol
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:           EQU     07H     ;bell
CR:             EQU     0DH     ;carriage return
ESC:            EQU     1BH     ;escape
LF:             EQU     0AH     ;linefeed
;
YES:            EQU     0FFH
NO:             EQU     0
;
;
;
; *** FOR 2661 UART:
;
;EQUATES FOR MODE REGISTER 1
BRF	EQU	00000010B	;asynchronous mode
CHARL	EQU	00001100B	;8 bits
PARITY	EQU	00000000B	;no parity
STOPBIT EQU	01000000B	;1 stop bit

;EQUATES FOR MODE REGISTER 2
BAUDDIV EQU	00000110B	;300 baud
TXCRXC	EQU	00110000B	;internal clocks

;EQUATES FOR COMMAND REGISTER
OPMODE	EQU	00000000B	;normal operation
RTS	EQU	00100000B	;RTS logic true
RESETER EQU	00010000B	;reset error flags
NOBREAK EQU	00000000B	;no break
BREAKON EQU	00001000B	;send break
RXTXEN	EQU	00000101B	;enable transmitter and receiver
DTR	EQU	00000010B	;DTR logic true
;
;
ACEPROM		EQU	0C200H 	;base of slot code for serial port
MODDATP         EQU     0CE00H  ;data port of 2661-2 serial I/O chip
MODCTL1         EQU     0CE01H  ;status port 
MODREG 		EQU	0CE02H	;baud rate and char format port
CMDREG		EQU	0CE03H	;command port
;
MODRCVB         EQU     02H     ;bit to test for char received
MODRCVR         EQU     02H     ;  value when ready
MODSNDB         EQU     01H     ;bit to test for send
MODSNDR         EQU     01H     ;  value when ready
;
;
                ORG     100H
;
                DS      3       ;(for  "JMP   START" instruction)
;
PMMIMODEM:      DB      NO      ;yes=PMMI S-100 Modem                   103H
SMARTMODEM:     DB      YES     ;yes=HAYES Smartmodem, no=non-pmmi      104H
TOUCHPULSE:     DB      'T'     ;T=touch, P=pulse (Smartmodem-only)     105H
CLOCK:          DB      60      ;clock speed in MHz x10, 25.5 MHz max.  106H
                                ;20=2 MHz, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:         DB      1       ;0=110 1=300 2=450 3=600 4=710 5=1200   107H
                                ;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:         DB      5       ;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
                                ;default time to send character in ter-
                                ;minal mode file transfer for slow BBS.
CRDLY:          DB      5       ;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
                                ;default time for extra wait after CRLF
                                ;in terminal mode file transfer
NOOFCOL:        DB      5       ;number of DIR columns shown            10AH
SETUPTST:       DB      YES     ;yes=user-added Setup routine           10BH
SCRNTEST:       DB      YES     ;Cursor control routine                 10CH
ACKNAK:         DB      YES     ;yes=resend record after any non-ACK    10DH
                                ;no=resend only on valid NAK
BAKUPBYTE:      DB      NO      ;yes=change any file same name to .BAK  10EH
CRCDFLT:        DB      YES     ;yes=default to CRC checking            10FH
TOGGLECRC:      DB      YES     ;yes=allow toggling of CRC to Checksum  110H
CONVRUB:        DB      NO      ;yes=convert rub to backspace           111H
TOGGLERB:       DB      YES     ;yes=allow toggling of rub to bksp      112H
ADDLF:          DB      NO      ;no=no LF after CR to send file in      113H
                                ;terminal mode (added by remote echo)
TOGGLELF:       DB      YES     ;yes=allow toggling of LF after CR      114H
TRANLOGON:      DB      YES     ;yes=allow transmission of logon        115H
                                ;write logon sequence at location LOGON
SAVCCP:         DB      YES     ;yes=do not overwrite CCP               116H
LOCONEXTCHR:    DB      NO      ;yes=local command if EXTCHR precedes   117H
                                ;no=external command if EXTCHR precedes
TOGGLELOC:      DB      YES     ;yes=allow toggling of LOCONEXTCHR      118H
LSTTST:         DB      YES     ;yes=printer available on printer port  119H
XOFFTST:        DB      NO      ;yes=checks for XOFF from remote while  11AH
                                ;sending a file in terminal mode
XONWAIT:        DB      NO 	;yes=wait for XON after CR while        11BH
                                ;sending a file in terminal mode
TOGXOFF:        DB      YES     ;yes=allow toggling of XOFF checking    11CH
IGNORCTL:       DB      YES     ;yes=CTL-chars above ^M not displayed   11DH
EXTRA1:         DB      0       ;for future expansion                   11EH
EXTRA2:         DB      0       ;for future expansion                   11FH
;
;>>> NOTE: some of the following characters have been changed from
;	   what is reported in the menu of MDM7xx.  Use DU or EDFILE
;	   to change the menu to match.
;
BRKCHR:         DB      '@'-40H ;^B = Send 300 ms. break tone           120H
NOCONNCT:       DB      'N'-40H ;^N = Disconnect from the phone line    121H
LOGCHR:         DB      'O'-40H ;^L = Send logon                        122H
LSTCHR:         DB      'P'-40H ;^P = Toggle printer                    123H
UNSAVE:         DB      'R'-40H ;^R = Close input text buffer           124H
TRANCHR:        DB      'T'-40H ;^T = Transmit file to remote           125H
SAVECHR:        DB      'Y'-40H ;^Y = Open input text buffer            126H
EXTCHR:         DB      '^'-40H ;^^ = Send next character               127H
                DS      2       ;                               	128H
;
IN$MODCTL1:     PUSH	D		;in modem control port		12AH
		LXI	D,MODCTL1
		CALL	PEEK
		POP	D 
		RET   
                DS      1
;
OUT$MODDATP:    PUSH	D		;out modem data port            134H
                LXI	D,MODDATP
		CALL	POKE
		POP	D
		RET
		DS      1
;
IN$MODDATP:     PUSH	D		;in modem data port             13EH
		LXI	D,MODDATP
		CALL	PEEK
		POP	D
                RET      
		DS	1
;
ANI$MODRCVB:    ANI     MODRCVB ! RET   ;bit to test for receive ready  148H
CPI$MODRCVR:    CPI     MODRCVR ! RET   ;value of rcv. bit when ready   14BH
ANI$MODSNDB:    ANI     MODSNDB ! RET   ;bit to test for send ready     14EH
CPI$MODSNDR:    CPI     MODSNDR ! RET   ;value of send bit when ready   151H
                DS      12              ;PMMI only calls                154H
;
LOGONPTR:       DW      LOGON           ;for user message.              160H
                DS      6               ;                               162H
JMP$GOODBYE:    JMP     GOODBYE         ;                               168H
JMP$INITMOD:    JMP     INITMOD         ;go to user written routine     16BH
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       16EH
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       171H
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       174H
JMP$SETUPR:     JMP     SETUPR          ;                               177H
JMP$SPCLMENU:   JMP     SPCLMENU        ;                               17AH
JMP$SYSVER:     JMP     SYSVER          ;                               17DH
JMP$BREAK:      JMP     SENDBRK         ;                               180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:      DS      3               ;                               183H
JMP$INBUF:      DS      3               ;                               186H
JMP$INLNCOMP:   DS      3               ;                               189H
JMP$INMODEM:    DS      3               ;                               18CH
JMP$NXTSCRN:    DS      3               ;                               18FH
JMP$TIMER:      DS      3               ;                               192H
;
;
CLREOS:         CALL    JMP$ILPRT       ;                               195H
EOSCLR:         DB      1BH,59H,0,0,0   ;				198H
                RET                     ;                               19DH
;
CLRSCRN:        CALL    JMP$ILPRT       ;                               19EH
                DB      1BH,2AH,0,0,0   ;				1A1H
                RET                     ;                               1A6H
;
SYSVER:         CALL    JMP$ILPRT       ;                               1A7H
                DB      'Version for FRANKLIN ACE',CR,LF,0
                RET
;.....
;
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;        end of your last routine should terminate by 0400H (601 bytes
;        available after start of SYSVER) if using the Hayes Smartmodem
;        or by address 0C00H (2659 bytes) otherwise.
;
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:  DB      'Hello',CR,0
;
;
; You can add your own routine here to send a break tone to reset time-
; share computers, if desired.
;
SENDBRK:RET
;
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:RET
;
;------------------------------------------------------------------
;
RDBYTE	EQU	0FFE0H	;read a byte from the ACE accumulator
WRBYTE	EQU	0FFE3H	;write a byte to the ACE (register C)
RDWORD  EQU	0FFE6H	;read 2 bytes from DE
WRWORD	EQU	0FFE9H	;write 2 bytes to DE
;
PEEK1BYTE	EQU	6
POKE1BYTE	EQU	7
;
;
;-------------------------------------------------------------------
;
;Enable Dual Interface Card expansion memory
;
ENBEXP:	PUSH	D
	LXI	D,0CFFFH	;disable expansion mem
	CALL	PEEKX
	LXI	D,ACEPROM	;enable ours
	CALL	PEEKX
	POP	D
	RET
;
;---------------------------------------------------------------------
;PEEK at one byte
;
;ENTER with address in DE
;EXIT  with byte in A
;
PEEK:	CALL	ENBEXP
PEEKX:	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	RET
;
;------------------------------------------------------------
;POKE one byte
;
;ENTRY: DE = address
;EXIT:  A  = data
;
POKE:	PUSH	PSW
	CALL	ENBEXP
	POP	PSW
POKEX:	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	RET
;
;---------------------------------------------------------------
;
INITMOD:MVI	A,1		;set speed byte	(default to 300)
	STA	MSPEED
	DI
;
	MVI	A,BRF+CHARL+PARITY+STOPBIT
	LXI	D,MODREG 	;mode register 1
	CALL	POKE
BDDIV:	MVI	A,BAUDDIV
	ADI	TXCRXC
	LXI	D,MODREG 	;mode register 2 (cycles automatically)
	CALL	POKEX
;
	MVI	A,OPMODE+RTS+NOBREAK+RXTXEN+DTR
	LXI	D,CMDREG	;command register
	CALL	POKEX
;
	EI
	RET
;
;
;--------------------------------------------------------------------
;
; The following routine changes the baud rate for the ACE with the SET
; command.
;
SETUPR:   LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 600, 1200, 4800, 9600): ',0
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
	  CALL  JMP$INLNCOMP
	  DB	'4800',0
	  JNC	OK4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;all matches failed - tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:   MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:   MVI	A,8
	  LHLD	BD9600
;
LOADBD:   STA	INITMOD+1	;store speed to show transfer time 
	  MOV	A,L		;get least significant baud rate byte
	  STA	BDDIV+1 	;store in INITMOD
	  JMP	INITMOD 	;reset ACE 2661
;
;
; Table of baud rate parameters
;					       
BD300:	DB	06H
BD600:	DB	07H 
BD1200: DB	08H  
BD4800:	DB	0CH
BD9600: DB	0DH
;
BAUDBUF:DW    	10,0            ;TELLS CLEARBUF ROUTINE IT CAN..
        DS      10              ;..CLEAR NEXT 10 BYTES
;
;-----------------------------------------------------------------------
;
; The following routine can be used to display commands on the screen
; of interest to users of this equipment.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
; NOTE: MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;                               0C00H (without Smartmodem)
;
        END


