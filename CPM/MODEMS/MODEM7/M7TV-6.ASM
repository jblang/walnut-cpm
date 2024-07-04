
; M7TV-5.ASM -- TeleVideo TS-802/803 overlay file for MDM7xx.  08/15/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the modem port on the TeleVideo TS-802 or the TS-803
; to the modem program.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;       NOTE:  If using a TS-803, the RCVREADY equate must be set to
;	       the value of the same label in the body of MDM7.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
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
;		-IM7TV-4.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 09/08/84  Fixed 2nd trivial 803 error - Tim Chiaretto
; 08/15/84  Fixed a trivial 803 error   - Irv Hoff
; 08/08/84  Fixed for 802/803 both, with
;	    information from M7TVI-3	- Irv Hoff
; 11/11/83  Renamed to M7TV-1.ASM	- Irv Hoff
; 07/27/83  Renamed to work with MDM711	- Irv Hoff
; 07/01/83  Revised to work with MDM711	- Irv Hoff
; 06/22/83  Revised to work with MDM711	- Irv Hoff
; 05/27/83  Updated to work with MDM709	- Irv Hoff
; 05/15/83  Revised to work with MDM708	- Irv Hoff
; 04/27/83  Revised to work with TV802	- Irv Hoff
; 02/17/83  Modified MDM703CF for Datapoint
;	    1560 computers using an external
;	    modem			- Irv Hoff
;
;=======================================================================
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
; Select one of the following two choices for your computer
;
TV802:		EQU	NO
TV803:		EQU	YES
;
;
; The following address must be obtained from the body of the main pro-
; gram, if using a TV803.  Value is immaterial if using a TV802.
;
RCVREADY:	EQU	1E41H		;location of label in MDM740
;
;=======================================================================
;
; Normal equates
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
;
; Special equates for Televideo computers
;
		 IF	TV802
PORT:		EQU	20H		;TeleVideo ST-802 data port
BAUDRP:		EQU	08H		;CTC port for baud rate
MODCTL1:	EQU	PORT+2		;modem control port
MODCTL2:	EQU	PORT+2		;modem control port
MODDATP:	EQU	PORT		;modem data port
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
MODRCVB:	EQU	1		;bit to test for receive ready
MODRCVR:	EQU	1		;value when ready
MODSNDB:	EQU	4		;bit to test for send ready
MODSNDR:	EQU	4		;value when ready
		 ENDIF			;TV802
;
		 IF	TV803
PORT:		EQU	2FH		;TeleVideo ST-803 data port
BAUDRP:		EQU	2BH		;CTC port for baud rate
MODCTL1:	EQU	PORT-2		;modem control port for input
MODCTL2:	EQU	PORT-1		;modem control port for output
MODDATP:	EQU	PORT		;modem data port
MODRCVB:	EQU	80H		;bit to test for receive ready
MODRCVR:	EQU	80H		;value when ready
MODSNDB:	EQU	80H		;bit to test for send ready
MODSNDR:	EQU	80H		;value when ready
		 ENDIF			;TV803
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
AUTODIAL:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
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
RETRY:		DB	NO	;yes=reset the error limit to try again	10DH
				;no=abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling of rub to backspace	112H
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
XOFFTST:	DB	NO	;yes=check for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^L = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^N = Send logon			122H
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
;
		 IF	TV802
		DS	7
		 ENDIF			;TV802
;
		 IF	TV803
IN$MODCTL2:	IN	MODCTL2 ! RET	;out modem control port		15AH
	 	DS	4
		 ENDIF			;TV803
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rec. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH	
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
;
		 IF	TV802
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
		 ENDIF			;TV802
;
		 IF	TV803
		DS	10		;				154H
		RET			;				15EH
		RET			;				15FH
		 ENDIF			;TV803
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		 IF	TV802
		DS	6
JMP$GOODBYE:	JMP	GOODBYE		;				168H
		 ENDIF			;TV802
;
		 IF	TV803
		DS	9
		 ENDIF			;TV803
;
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
; Do not change the following six lines
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,79H,0,0,0	;ESC y - clear to end of screen	198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,2AH,0,0,0	;ESC * clear CRT, home cursor	11AH
		RET			;				1A6H			
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for TeleVideo TS-80'
;
		 IF	TV802
		DB	'2, modem port 20H'
		 ENDIF			;TV802
;
		 IF	TV803
		DB	'3, modem port 2FH'
		 ENDIF			;TV803
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
; CTL-O if TRANLOGON has been set YES.	You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	DB	'Greetings from a TeleVideo user',CR,LF,0
;
;=======================================================================
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:
	 IF	TV802
	MVI	A,5
	OUT	MODCTL1
	MVI	A,0F8H		;send a break tone
	JMP	GOODBYE1
	 ENDIF			;TV802
;
	 IF	TV803
	RET
	 ENDIF			;TV803
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
; 
GOODBYE:
	 IF	TV802
	MVI	A,5
	OUT	MODCTL1		;send to the status port
	MVI	A,068H		;turn off dtr, send break
;
GOODBYE1:
	OUT	MODCTL1	
	MVI	B,3		;wait 300 ms.
	CALL	JMP$TIMER
	MVI	A,5
	OUT	MODCTL1
	MVI	A,0E8H		;restore to normal, 8 bits, dtr on, etc.
	OUT	MODCTL1
	 ENDIF			;TV802
;
	RET
;.....
;
;
; televideo ts-802 baud rate change.  sets ctc at port 08h for baudrate
; in/out.
;
	 IF	TV802
INITMOD:MVI	A,0		;select reg.
	OUT	MODCTL1		;send to the status port
	MVI	A,18H		;reset the z8sio chip
	OUT	MODCTL1		;send to the status port
	MVI	A,4		;select reg.
	OUT	MODCTL1		;send to the status port
	MVI	A,44H		;16x, 1-stop, no parity
	OUT	MODCTL1		;send to the status port
	MVI	A,3		;select reg.
	OUT	MODCTL1		;send to the status port
	MVI	A,0C1H		;enable receive section
	OUT	MODCTL1		;send to the status port
	MVI	A,5		;select reg.
	OUT	MODCTL1		;send to the status port
	MVI	A,0EAH		;dtr, rts, 8-bits, enable send section
	OUT	MODCTL1		;send to the status port
;
INITMOD1:
	MVI	A,1		;default transfer time to 300 baud
	STA	MSPEED
	MVI	A,47H
	OUT	BAUDRP
;
INITMOD2:
	MVI	A,80H		;default to 300 baud
	OUT	BAUDRP
	RET
	 ENDIF			;TV802
;
	 IF	TV803
INITMOD:RET
;
INITMOD1:
	MVI	A,1		;default transfer time to 300 baud
	STA	MSPEED
;
INITMOD2:
	MVI	A,20H		;default to 300 baud
	OUT	BAUDRP
	RET
	 ENDIF			;TV803
;.....
;
;
SETUPR:	LXI	D,BAUDBUF	;point to new input buffer
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 450, 600, 1200, 9600): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare baudbuf+2 with characters below
	DB	'300',0
	JNC	OK300		;go if got match
	CALL	JMP$INLNCOMP
	DB	'450',0
	JNC	OK450
	CALL	JMP$INLNCOMP
	DB	'600',0
	JNC	OK600
	CALL	JMP$INLNCOMP
	DB	'1200',0
	JNC	OK1200
	CALL	JMP$INLNCOMP
	DB	'9600',0
	JNC	OK9600
	CALL	JMP$ILPRT	;all matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	SETUPR		;try again
;
OK300:	MVI	A,1		;mspeed 300 baud value
	LHLD	BD300		;get 300 baud parameters in 'HL'
	JMP	LOADBD		;go load them
;
OK450:	MVI	A,2
	LHLD	BD450
	JMP	LOADBD
;
OK600:	MVI	A,3
	LHLD	BD600
	JMP	LOADBD
;
OK1200:	MVI	A,5
	LHLD	BD1200
	JMP	LOADBD
;
OK9600:	MVI	A,8
	LHLD	BD9600
;
LOADBD:	STA	INITMOD1+1	;change time-to-send to match baudrate
	MOV	A,L		;get baudrate byte
	STA	INITMOD2+1	;store in initmod
	JMP	INITMOD1	;reinitialize to new baudrate, then done
;
;
; table of baudrate parameters
;
	 IF	TV802
BD300:	DW	0080H		;38400/300  converted to hex value
BD450:	DW	0055H		;38400/450  converted to hex value
BD600:	DW	0040H		;38400/600  converted to hex value
BD1200:	DW	0020H		;38400/1200 converted to hex value
BD9600:	DW	0004H		;38400/9600 converted to hex value
	 ENDIF			;TV802
;
	 IF	TV803
BD300:	DW	0020H		;9600/300  converted to hex value
BD450:	DW	0016H		;9600/450  converted to hex value
BD600:	DW	0010H		;9600/600  converted to hex value
BD1200:	DW	0008H		;9600/1200 converted to hex value
BD9600:	DW	0001H		;9600/9600 converted to hex value
	 ENDIF			;TV803
;
BAUDBUF:DB	10,0
	DS	10
;
;	       (end of initmod and setup routines)
;-----------------------------------------------------------------------
;
; these routines can be used for your equipment, be sure to end with ret
; if using the hayes smartmodem this is unavailable without a special
; address change.
;
SPCLMENU:RET
;
; NOTE:  Must terminate prior to 0400H
;
;
;-----------------------------------------------------------------------
;
; This overwrites the first line of the RCVREADY routine in the body of
; the main program, in order to check IN$MODCTL2 rather than IM$MODCLT1.
;
	  IF	TV803
	 ORG	RCVREADY
	 CALL	IN$MODCTL2
	  ENDIF			;TV803
;
;-----------------------------------------------------------------------
;
	 END
;
