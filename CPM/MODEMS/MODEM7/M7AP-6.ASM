
; M7AP-6.ASM - Apple overlay file for MDM740 - 08/08/84
;
; This overlay intended to be upward compatible with the M7AP-2 overlay
; for the Apple ][ and an external modem.  The major difference is the
; addition of code to allow the use of the MDM7xx program with the ALS
; CP/M Card using CP/M 3.0 or the PCPI Applicard under CP/M 2.2.  This
; also supports the ASL Dispatcher.
;
; This overlay file enables Apple II computers with the Apple Super Ser-
; ial card and external modem to use the MDM7xx phone modem program.  It
; also supports the following Apple modem configurations:
;
;	a) CCS 7710 serial interface and external modem
;	b) SSM serial interface and external modem
;	c) Apple communications interface and external modem
;	d) Mountain Hardware CPS Multifunction card and external modem
;	e) Prometheus Versacard with software baud select and ext. modem
;	f) ALS Dispatcher serial interface.
;
;	(note:	When using the ALS Dispatcher at 1200 baud, you must
;	       enable hardware interrupts.)
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MDM7xx.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
; Use the "SET" command to change the baudrate when desired.
;
; To use SET with the Prometheus Versacard a small hardware mod must be
; made, since the Versacard only supports baud rate selection via DIP
; switches. This Mod will allow the Versacard to be switched between 300
; and 1200 baud via software.  A wire should be attached from Pin #12 on
; U16 (IC marked 8126) on the Versacard into Annunciator #3 (Pin #12) on
; the Apple game port.	This will allow switch #4 on s2 of the Versacard
; to be toggled by setting or clearing annunciator #3.	The default baud
; rate is set at MSPEED below either (300 or 1200).  This method could
; be extended to all other Versacard baud rates and by using Annunciators
; 0,1,2 but 300 and 1200 are really needed for a modem program.  The DIP
; switches on the Versacard should be set as follows:
;
;      On switch bank #2:
;			s2 - ON
;			s3 - OFF
;			s4 - OFF
;			s5 - OFF
;
;=======================================================================
;
; TO USE:  First edit this file filling in answers for your own equip-
;	   ment.  Also edit the phone number library, M7NM-6.ASM, if the
;	   phone directory is desired.	Optionally, M7LIB.COM may be
;	   used to change phone numbers later.	Assemble these files
;	   with ASM.COM or equivalent assembler.
;
;
;==================== ASSEMBLY WITH CP/M 2.2 ===========================
;
;		A>DDT MDM740.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7AP-6.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4580 0000
;	      * -IM7NM-6.HEX		(get the optional phone library)
;	      * -R
;	      * NEXT  PC
;	      * 4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM740.COM	(now have a modified .COM file)
;
;	      * optional
;
;====================== ASSEMBLY WITH CP/M 3.0 =========================
;
;		Use SID to overlay the results of these program(s) to
;		the original .COM file:
;
;		A>SAVE			(load the CP/M 3.0 SAVE transient)
;					(note no messages)
;		A>SID MDM740.COM	(load the original .COM file)
;		CP/M 3 SID - Version 3.0
;		NEXT MSZE  PC  END
;		aaaa bbbb 0100 xxxx	(xxxx depends on your sys)
;		#RM7AP-6.HEX		(load overlay, note "R" command)
;		NEXT MSZE  PC  END
;		xxxx aaaa 0100 xxxx	(xxxx's are insignificant)
;	      * #RM7NM-6.HEX		(get the optional phone # overlay)
;	      * NEXT MSZE  PC  END
;	      * xxxx aaaa 0100 xxxx
;		#G0			(exit SID)
;
;		CP/M 3 SAVE - Version 3.0
;		Enter file: MDM7.COM	(name new file)
;		Start hex address 100	(from PC above)
;		Ending hex address 457F (MSZE - 1)
;
;		A>			(now have a modified .COM file)
;
;	      * This step is optional
;
;=======================================================================
;
; 08/08/84  Set GOLIST and CMDBUF equates properly for MDM740 and moved
;	    to front of program.  Rewrote SETUPR area so program can be
;	    assembled properly with ASM.COM	- Irv Hoff
; 06/10/84  Fixed error introduced in SSC baud rate initialization rou-
;	    tine for PCPI card.  This error only occurred when assembled
;	    for the SSC with ALSCARD set YES.	- Mark Howard
; 06/01/84  Changed to work with MDM740 - Robert Flagg
; 04/25/84  Revised and renamed to M7AP-5.ASM	- Richard Berg
; 02/24/84  Revised and renamed to M7AP-4.ASM.	Added PCPI Applicard
;	    support.  Added optional modification to SET command and
;	    corrected CCS coding to provide software baudrate control.
; 01/14/84  Revised and renamed to M7AP+3.ASM.	Added ALS CP/M Card and
;	    dispatcher. 			- Mark Howard
; 12/26/83  Added Versacard support with software baudrate selection.
;	    Revised to allow easy serial cared relocation.  Made SYSVER
;	    software baud selection. Revised	
; 11/11/83  Renamed to M7AP-1.ASM, no changes	- Irv Hoff
; 10/07/83  Added CPS card support		- Wally Hubbard
; 07/27/83  Renamed to work with MDM712 	- Irv Hoff
; 07/01/83  Revised to work with MDM711 	- Irv Hoff
; 06/22/83  Revised to work with MDM710 	- Irv Hoff
; 05/27/83  Updated to work with MDM709 	- Irv Hoff
; 05/15/83  Revised to work with MDM708 	- Irv Hoff
; 04/11/83  Updated to work with MDM707 	- Irv Hoff
; 04/04/83  Updated to work with MDM706 	- Irv Hoff
; 02/27/83  Updated to work with MDM705 	- Irv Hoff
; 02/12/83  Used MDM703CF to make this file for Apple computers using a
;	    variety of serial interface cards with external modem.
;						- Bruce Kargol
;	     for Apple computers using a var-
;	     iety of serial interface cards
;	     with external modem.		- Bruce Kargol
;
;=======================================================================
;
YES:	EQU	0FFH
NO:	EQU	0
;
;	*********************************************************
;	*		    C A U T I O N			*
;	* GOLIST: and CMDBUF: will different addresses depend-	*
;	* ing on the version of MDM7xx you are currently using. *
;	*********************************************************
;
GOLIST:	EQU	2049H	;MDM740.COM location of GOLIST:
CMDBUF:	EQU	49A7H	;MDM740.COM location of CMDBUF:
;
;
BELL:	EQU	07H	;bell
CR:	EQU	0DH	;carriage return
ESC:	EQU	1BH	;escape
LF:	EQU	0AH	;linefeed
;
;
;====================== CUSTOMIZATION EQUATES ==========================
;
SLOT:	EQU	2	;slot of serial interface
;
ALSCARD:  EQU	NO	;YES if using ALS CP/M Card
APPLICARD:EQU	NO	;if using PCPI Applicard
CPM2CARD: EQU	YES	;YES if Softcard
;
;
CCS:	EQU	NO	;YES for CCS 7710
VERSA:	EQU	NO	;YES for Prometheus Versacard
COMCARD:EQU	NO	;YES for Apple Comcard
SSC:	EQU	YES	;YES for Super Serial Card
SSM:	EQU	NO	;YES for SSM serial card
CPS:	EQU	NO	;YES for CPS card
ALSDSP:	EQU	NO	;YES for ALS Dispatcher
;
SETMOD:	EQU	YES	;if YES, make sure CMDBUF: points to MDM7xx loc.
;
;=======================================================================
;
SLOTOFF:EQU	16*SLOT	;serial card slot offset
;
	 IF	ALSCARD	OR APPLICARD
MAPOFF:	EQU	0			;no memory remapping for either
	 ENDIF				;ALSCARD
;
	 IF	CPM2CARD
MAPOFF:	EQU	2000H			;Microsoft strikes again
	 ENDIF				;CPM2CARD
;
	 IF	VERSA
AN3SET:	EQU	0C05FH+MAPOFF		;set annunciator #3
AN3CLR:	EQU	0C05EH+MAPOFF		;clear	  "
	 ENDIF				;VERSA
;
	 IF	CCS
MODDATP:EQU	0C081H+SLOTOFF+MAPOFF	;data port of CCS 7710
MODCTL1:EQU	0C080H+SLOTOFF+MAPOFF	;status port of CCS 7710
	 ENDIF				;CCS OR ALSDSP
;
	 IF	COMCARD	OR VERSA OR ALSDSP
MODDATP:EQU	0C08FH+SLOTOFF+MAPOFF	;data port of Comcard
MODCTL1:EQU	0C08EH+SLOTOFF+MAPOFF	;status port of Comcard
	 ENDIF				;COMCARD OR VERSA OR ALSDSP
;
	 IF	SSM
MODDATP:EQU	0C085H+SLOTOFF+MAPOFF	;data port of SSM
MODCTL1:EQU	0C084H+SLOTOFF+MAPOFF	;status port of SSM
	 ENDIF				;SSM
;
	 IF	SSC
MODDATP:EQU	0C088H+SLOTOFF+MAPOFF	;data port of Apple SSC
MODCTL1:EQU	0C089H+SLOTOFF+MAPOFF	;modem status port of SSC
MODRCVB:EQU	08H			;bit to test for received data
MODRCVR:EQU	08H			;modem receive ready
MODSNDB:EQU	10H			;bit to test for ready to send
MODSNDR:EQU	10H			;modem send ready bit
	 ENDIF				;SSC
;
;
; (Any slot with any CPS function assigned to it may be used.)
;
	 IF	CPS
MODCR:	EQU	0C0FEH+SLOT*100H+MAPOFF	;control port of CPS card
MODDATP:EQU	0C0FAH+SLOT*100H+MAPOFF	;data port of CPS card
MODCTL1:EQU	0C0FBH+SLOT*100H+MAPOFF	;status port of CPS card
MODCPST:EQU	0C0F9H+SLOT*100H+MAPOFF	;printer status port
MODCPRT:EQU	0C0FDH+SLOT*100H+MAPOFF	;printer data port
MODRCVB:EQU	02H			;bit to test for receive
MODRCVR:EQU	02H			;value when ready
MODSNDB:EQU	01H			;bit to test for send
MODSNDR:EQU	01H			;value when ready
	 ENDIF				;CPS
;
;
; Apple status bit equates for CCS, Comcard, Versacard, Dispatcher, and
; SSM
;
	 IF	NOT SSC	AND NOT	CPS
MODSNDB:EQU	02H			;bit to test for send
MODSNDR:EQU	02H			;value when ready
MODRCVB:EQU	01H			;bit to test for receive
MODRCVR:EQU	01H			;value when ready
	 ENDIF				;NOT SSC AND NOT CPS
;
;
; We have software control over the Super Serial, CPS & CCS cards and
; Versacard; if hardware mod is made, so SETUPRTST is YES for those
; cards cards, below.
;
;
;=======================================================================
;
		ORG	100H
;
; Change the clock speed to match your equipment.  The Microsoft Soft-
; card operates at 2 MHz.  The Applicard operates at either 4 or 6 MHz
; depending on which card you purchased.  The ALS Card operates at 2
; MHz.
;
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
AUTODIAL:	DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHz, 37=3.68 MHz, 40=4 MHz, etc.
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
RETRY:		DB	YES	;yes=reset the error limit to try again 10DH
				;no=abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of rub to backspace 112H
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
BRKCHR:		DB	'B'-40H	;^B = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'W'-40H	;^W = Send next character		127H
		DS	2		;				128H
;
IN$MODCTL1:	JMP	LDACTL1		;in modem control port		12AH
		DS	7
OUT$MODDATP:	JMP	STADATP		;out modem data port		134H
		DS	7
IN$MODDATP:	JMP	LDADATP		;in modem data port		13EH
		DS	7		;spares if needed
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
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
CLREOS:		CALL	JMP$ILPRT	;				195H
EOSCLR:		DB	'K'-40H,0,0,0,0	;Apple ][/e 80 col		198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	'L'-40H,0,0,0,0	;Apple ][/e 80 col		1A1H
		RET			;				1A6H
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Apple ][ and '
;
	 IF CPM2CARD
	DB	'CP/M 2.2 Card'
	 ENDIF
;
	 IF APPLICARD
	DB	'Applicard'
	 ENDIF
;
	 IF ALSCARD
	DB	'ALS CP/M Card'
	 ENDIF
;
	DB	CR,LF
;
	 IF VERSA
	DB	'Versacard'
	 ENDIF
;
	 IF SSC
	DB	'Super Serial Card'
	 ENDIF
;
	 IF COMCARD
	DB	'Comcard'
	 ENDIF
;
	 IF CPS
	DB	'CPS card - serial function'
	 ENDIF
;
	 IF CCS
	DB	'CCS 7710 Card'
	 ENDIF
;
	 IF ALSDSP
	DB	'ALS Dispatcher'
	 ENDIF
;
	 IF SSM
	DB	'SSM Serial Interface'
	 ENDIF
;
	DB	' in slot ',SLOT+30H,CR,LF
	DB	0
	RET
;.....
;
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;
; You can put in a message at this location which can be called up with
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	DB	'Hello there from an Apple user',CR,0
;
;
; You can add your own routine here to send a break tone to reset time-
; share computers, if desired.
;
	 IF NOT	CPS
SENDBRK:RET
	 ENDIF			;NOT CPS
;
	 IF CPS
SENDBRK:MVI	A,80H		;open the command register
	CALL	STAMDCR		;by storing 80H in MODCR
	MVI	A,3FH		;send a break by storing
	CALL	STACTL1		;3F in	MODCTL1
	XRA	A		;close the command register
	JMP	STAMDCR		;by storing 00H in MODCR
	 ENDIF			;CPS
;.....
;
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:RET
;.....
;
;
INITMOD:EQU	$
;
	 IF	ALSCARD
	LHLD	1		;initialize our local jumps to the BIOS
	LXI	D,60H
	DAD	D
	SHLD	APREAD+1
	INX	H
	INX	H
	INX	H
	SHLD	APWRITE+1
	 ENDIF			;ALSCARD
;.....
;
;
; The following address is used to set data bits, parity, stop bits and
; baud rate on the Super Serial Card.
;
	 IF SSC
MODDLL:	EQU	0C08BH+SLOTOFF+MAPOFF	;SSC ACIA control register
;
;
; Control over number of data bits, parity and number of stop bits
; (through MSB300:) has not been implemented.  These must be set using
; the slide switches on the Super Serial Card.
;
; The following is used to initialize the Apple SSC on execution of the
; program.  Change it to initialize the modem port on your micro if you
; wish.  It initializes to 300 baud.
;
INITBR:	MVI	A,1		;default transfer time to 300
	STA	MSPEED
	CALL	LDAMODL		;current baudrate from MODDLL
	ANI	0F0H		;zero the last 4 bits
;
INITMOD1:
	ORI	06H		;get default baudrate (300)
	CALL	STAMODL		;store default baudrate
	 ENDIF			;SSC
;.....
;
;
; The following may be used to initialize the Mountain Hardware CPS
; Multifunction Card for eight bits, no parity, one stop bit, and
; 300 baud.  This does not alter the CPS defaults outside of MDM7xx.
;
	 IF CPS
INITBR:	MVI	A,1		;set MSPEED at 1 (=300 baud)
	STA	MSPEED
	MVI	A,80H		;open the command register
	CALL	STAMDCR		;by storing 80H in MODCR
	MVI	A,37H		;initialize the serial chip
	CALL	STACTL1		;by storing 37H in MODCTL1
	MVI	A,4EH		;set 1 stop bit, no parity
	CALL	STADATP		;by storing $4E in MODDATP
;
INITMOD1:
	MVI	A,35H		;set baud rate at 300 by storing
	CALL	STADATP		;35H in MODDATP (same address - the two 
				;registers cycle with each write)
	XRA	A		;close the command register
	CALL	STAMDCR		;by storing 00 in MODCR
;
;
; The MDM740.COM routine that checks to see if the printer is ready does
; not work with the CPS card.  This routine changes it.  Check to make
; sure the original code sequence CALL 0000H, ORA A, RZ, is located at
; GOLIST.  A new routine to send the character to the printer is also
; provided, to eliminate the need for the CPS patches.
;
	LXI	H,PRCHECK	;store the address of the
	SHLD	GOLIST+1	;PRCHECK routine at GOLIST+1
	LXI	H,PRINTCHAR	;store the address of the
	SHLD	GOLIST+15	;PRINTCHAR routine
	 ENDIF			;CPS
;.....
;
;
; The following routine initializes the Versacard to the default baud
; rate which is set at MSPEED above.  If MSPEED is set to something
; other than 300 or 1200 this routine does not alter the annunciator
; settings.
;
	 IF VERSA
INITBR:	LDA	MSPEED		;set annunciators to known state
	CPI	1		;is it 300 ?
	JZ	OK300
	CPI	5		;is it 1200 ?
	JZ	OK1200
	 ENDIF			;VERSA
;
	RET			;RET is for INITMOD
;.....
;
;
; Substitute routines for status checks and printing:
;
	 IF	CPS
PRCHECK:CALL	LDACPST		 ;read the status port
	ANI	040H		 ;mask off unused bits
	RET
;.....
;
;
PRINTCHAR:
	MOV	A,C		;move char to A
	JMP	STACPRT		;send it to the printer
	 ENDIF			;CPS
;
	 IF	CCS
INITBR:	MVI	A,5		;set default speed to 1200 baud
	STA	MSPEED		;
INITMOD1:
	MVI	A,00010101B	;set 8 data, 1 stop bit, 1200 baud
				;use 00010110B for 300 baud-
				;make sure card switches are set for
				;1200 bps!
	CALL	STACTL1		;CCS ACAI control register
	RET
	 ENDIF			;CCS
;.....
;
;
	 IF NOT	SSC AND	NOT CPS	AND NOT	VERSA AND NOT CCS
SETUPR:	RET			;routine to change baud rates, if needed
	 ENDIF			;NOT SSC AND NOT CPS AND NOT VERSA
;.....
;
;
; Changes the modem baud rate with SET command.
;
	 IF SSC	OR CPS OR VERSA	OR CCS
SETUPR:	 IF	SETMOD
	LXI	D,CMDBUF+6	;point to loc of speed in command buffer
	CALL	JMP$INLNCOMP	;when command is of form SET 300, etc
	DB	'300',0
	JNC	OK300
	CALL	JMP$INLNCOMP
	DB	'600',0
	JNC	OK600
	CALL	JMP$INLNCOMP
	DB	'1200',0
	JNC	OK1200
				;fall thru if speed is not properly
				;indicated in SET command
	 ENDIF			;SETMOD
	 ENDIF			;SSC OR CPS OR VERSA OR CCS
;	
	 IF SSC	OR CPS OR VERSA	OR CCS
	LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	CALL	JMP$ILPRT
;
	 IF	NOT CCS
	DB	'Input Baud Rate (300,600,1200): ',0
	 ENDIF			;NOT CCS
	 ENDIF			;SSC OR CPS OR VERSA OR CCS
;
	 IF SSC	OR CPS OR VERSA	OR CCS
	 IF	CCS
	DB	'Input Baud Rate (300,1200): ',0
	ENDIF			;CCS
	 ENDIF			;SSC OR CPS OR VERSA OR CCS
;
	 IF SSC	OR CPS OR VERSA	OR CCS
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
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	SETUPR		;try again
	 ENDIF			;SSC OR CPS OR VERSA OR CCS
;
	 IF	SSC OR CCS OR CPS
OK300:	MVI	A,1		;MSPEED 300 baud value
	LHLD	BD300		;get 300 baud parameters in HL
	JMP	LOADBD		;go load them
;
OK600:	MVI	A,3
	LHLD	BD600
	JMP	LOADBD
;
OK1200:	MVI	A,5
	LHLD	BD1200
;
LOADBD:	STA	INITBR+1
	MOV	A,L		;get baud rate byte
	STA	INITMOD1+1	;store in INITMOD
	JMP	INITBR		;reset ACIA baud rate
	 ENDIF			;SSC OR CCS OR CPS
;
	 IF VERSA
OK300:	CALL	LDAAN3C		;clear Annunciator #3 for 300 baud
	MVI	A,1		;set MSPEED..
	STA	MSPEED		;..for 300 baud
	RET
;
OK600:	CALL	JMP$ILPRT
	DB	'300 or 1200 baud only on Versacard',CR,LF,0
	RET
;
OK1200:	CALL	LDAAN3S		;set Annunciator #3 for 1200 baud
	MVI	A,5		;set MSPEED..
	STA	MSPEED		;..for 1200 baud
	RET
	 ENDIF			;VERSACARD
;
;
; Table of baud rate parameters
;
	 IF SSC
BD300:	DW	0006H
BD600:	DW	0007H
BD1200:	DW	0008H
	 ENDIF			;SSC
;
	 IF CPS
BD300:	DW	0035H
BD600:	DW	0036H
BD1200:	DW	0037H
	 ENDIF			;CPS
;
	 IF	CCS
BD300:	DW	0016H
BD1200:	DW	0015H
	 ENDIF			;CCS
;
BAUDBUF:DW	10,0		;tells CLEARBUF routine it can clear..
	DS	10		;..out the next 10 bytes
;
;============================= APPLE I/O ===============================
;
	 IF	CPM2CARD
STACTL1:STA	MODCTL1	! RET
STADATP:STA	MODDATP	! RET
LDACTL1:LDA	MODCTL1	! RET
LDADATP:LDA	MODDATP	! RET
	 ENDIF			;CPMCARD
;
	 IF	CPM2CARD AND CPS
STACPRT:STA	MODCPRT	! RET
STAMDCR:STA	MODCR	! RET
LDACPST:LDA	MODCPST	! RET
	 ENDIF			;CPM2CARD AND CPS
;
	 IF	CPM2CARD AND SSC
LDAMODL:LDA	MODDLL	! RET
STAMODL:STA	MODDLL	! RET
	 ENDIF			;CPM2CARD AND SSC
;
	 IF	CPM2CARD AND VERSA
LDAAN3C:LDA	AN3CLR	! RET
LDAAN3S:LDA	AN3SET	! RET
	 ENDIF			;CPM2CARD AND VERSA
;
	 IF	ALSCARD	AND SSC
STAMODL:PUSH	H
	LXI	H,MODDLL
	JMP	APWRT
	 ENDIF			;ALSCARD AND SSC
;
	 IF ALSCARD
STACTL1:PUSH	H
	LXI	H,MODCTL1
	JMP	APWRT
;
STADATP:PUSH	H
	LXI	H,MODDATP
;
APWRT:	PUSH	D
	PUSH	B
	CALL	APWRITE
	POP	B
	POP	D
	POP	H
	RET
	 ENDIF			;ALSCARD
;
	 IF ALSCARD AND	SSC
LDAMODL:PUSH	H
	LXI	H,MODDLL
	JMP	APRD
	 ENDIF			;ALSCARD AND SSC
;
	 IF	ALSCARD
LDACTL1:PUSH	H
	LXI	H,MODCTL1
	JMP	APRD
;
LDADATP:PUSH	H
	LXI	H,MODDATP
;
APRD:	PUSH	D
	PUSH	B
	CALL	APREAD
	POP	B
	POP	D
	POP	H
	RET
;
;
; These are the jump locations to the ALS BIOS
;
APREAD:	JMP	$-$
APWRITE:JMP	$-$
	 ENDIF			;ALSCARD
;
	 IF	ALSCARD	AND CPS
STACPRT:PUSH	H
	LXI	H,MODCPRT
	JMP	APWRT
;
STAMDCR:PUSH	H
	LXI	H,MODCR
	JMP	APWRT
;
LDACPST:PUSH	H
	LXI	H,MODCPST
	JMP	APRD
	 ENDIF			;ALSCARD AND CPS
;
	 IF	ALSCARD	AND SSC
LDAMODL:PUSH	H
	LXI	H,MODDLL
	JMP	APRD
;
STAMODL:PUSH	H
	LXI	H,MODDLL
	JMP	APWRT
	 ENDIF			;ALSCARD AND SSC
;
	 IF	ALSCARD	AND VERSA
LDAAN3C:PUSH	H
	LXI	H,AN3CLR
	JMP	APRD
;
LDAAN3S:PUSH	H
	LXI	H,AN3SET
	JMP	APRD
	 ENDIF			;ALSCARD AND VERSA
;
	 IF	APPLICARD	;
RDBYTE:	EQU	0FFE0H		;READ 1 BYTE FROM APPLE (A = BYTE)
WRBYTE:	EQU	0FFE3H		;WRITE 1 BYTE TO APPLE (C = BYTE)
RDWORD:	EQU	0FFE6H		;READ 2 BYTES FROM APPLE (DE = WORD)
WRWORD:	EQU	0FFE9H		;WRITE 2 BYTES TO APPLE (DE = WORD)
PEEK1BYTE:EQU	6		;COMMAND
POKE1BYTE:EQU	7		;COMMAND
;
STACTL1:PUSH	D
	LXI	D,MODCTL1
	JMP	APWRT	
;
STADATP:PUSH	D
	LXI	D,MODDATP
;
APWRT:	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	POP	D
	RET
;
LDACTL1:PUSH	D
	LXI	D,MODCTL1
	JMP	APRD
;
LDADATP:PUSH	D
	LXI	D,MODDATP
;
APRD:	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	POP	D
	RET
	 ENDIF			;APPLICARD
;
	 IF	APPLICARD AND CPS
STACPRT:PUSH	D
	LXI	D,MODCPRT
	JMP	APWRT
;
STAMDCR:PUSH	D
	LXI	D,MODCR
	JMP	APWRT
;
LDACPST:PUSH	D
	LXI	D,MODCPST
	JMP	APRD
	 ENDIF			;APPLICARD AND CPS
;
	 IF APPLICARD AND SSC
LDAMODL:PUSH	D
	LXI	D,MODDLL
	JMP	APRD
;
STAMODL:PUSH	D
	LXI	D,MODDLL
	JMP	APWRT
	 ENDIF			;APPLICARD AND SSC
;
	 IF APPLICARD AND VERSA
LDAAN3C:PUSH	D
	LXI	H,AN3CLR
	JMP	APRD
;
LDAAN3S:PUSH	D
	LXI	H,AN3SET
	JMP	APRD
	 ENDIF			;APPLICARD AND VERSA
;
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
;
; NOTE: MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				0C00H (without Smartmodem)
;
	END
