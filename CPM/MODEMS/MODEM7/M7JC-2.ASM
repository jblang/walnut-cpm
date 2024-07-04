; M7JC-2.ASM Apple/J-Cat overlay file for MDM727.  03/10/84
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; This file is a patch of  M7AP-1.ASM overlay designed to
; allow auto-dialing through a Novation J-Cat modem.
; 
; The equates and patches in this file are set up for the combination
; of an Apple Super Serial Card in slot 2, with a Novation J-Cat modem.
; The J-cat is 300-baud only, so I have eliminated the routine for
; changing baud rate that was in the original.
;
; In order to dial with the J-Cat, the modem's OHK line (pin 7 on the
; modem's card-edge connector; blue unconnected line in the DB25 
; connector provided with the modem) must be connected to the Apple's
; AN(1) annunciator (pin 14 on the game I/O socket). {Actually, it
; could be connected to one of the other annunciator ports, if the
; "onhook" and "offhook" equates below are changed to refer to that
; annunciator.}
;			-- David W. Walker 71076,411
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  
; This overlay file enables Apple II computers with the Apple Super
; Serial card and external modem to use the MDM727 phone modem program.
; It also supports the following Apple modem configurations:
;
;	a) CCS 7710 serial interface and external modem
;	b) SSM serial interface and external modem
;	c) Apple communications interface and external modem
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MDM727.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM727.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4900 0100
;		-IM7JC-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4900 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM727.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 03/10/84 - Addresses for MDM727		- D. W. Walker
; 02/19/84 - Addresses for MDM724   		- D. W. Walker
; 10/04/83 - J-Cat dialing routines added	- D. W. Walker
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
; 02/12/83 - Used MDM703CF to make this file
;	     for Apple computers using a var-
;	     iety of serial interface cards
;	     with external modem.		- Bruce Kargol
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H	;bell
CR:		EQU	0DH	;carriage return
ESC:		EQU	1BH	;escape
LF:		EQU	0AH	;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
CCS:		EQU	NO	;YES for CCS 7710
COMCARD:	EQU	NO	;YES for Apple comcard
SSC:		EQU	YES	;YES for Super Serial Card
SSM:		EQU	NO	;YES for SSM serial card
;
		 IF	CCS
MODDATP:	EQU	0E0A1H	;data port of CCS 7710
MODCTL1:	EQU	0E0A0H	;status port of CCS 7710
	 	 ENDIF		;endif CCS
;
		 IF	COMCARD
MODDATP:	EQU	0E0AFH	;data port of Comcard
MODCTL1:	EQU	0E0AEH	;status port of Comcard
		 ENDIF		;endif Comcard
;
		 IF	SSM
MODDATP:	EQU	0E0A5H	;data port of SSM
MODCTL1:	EQU	0E0A4H	;status port of SSM
		 ENDIF		;endif SSM
;
		 IF	SSC
MODDATP:	EQU	0E0A8H	;data port of Apple Super Serial Card 
MODCTL1:	EQU	0E0A9H	;modem status port of Super Serial Card
COMMAND: 	EQU     0E0AAH	;SSC command register
MODBDP:		EQU	0E0ABH	;SSC ACIA control register
;
MODRCVB:	EQU	08H     ;bit to test for received data
MODRCVR:	EQU	08H     ;modem receive ready
MODSNDB:	EQU	10H	;bit to test for ready to send
MODSNDR:	EQU	10H	;modem send ready bit
DTR     	EQU     0BH     ;dtr,xmit on(rts low),irq disabled
		 ENDIF		;endif SSC
;
;
; Apple status bit equates for CCS, Comcard and SSM
;
		 IF	NOT SSC
MODSNDB:	EQU	02H	;bit to test for send
MODSNDR:	EQU	02H	;value when ready
MODRCVB:	EQU	01H	;bit to test for receive
MODRCVR:	EQU	01H	;value when ready
		 ENDIF		;not SSC
;
;  Equates for routines in the body of MDM727.COM, needed to make
;  the J-Cat auto-dialing routines work with the PMMI routines in
;  MDM727:
;
;
DIAL15:		EQU	05DFH
DIALAGN:	EQU	05FBH
CONMADE:	EQU	06A9H
DIALA2:		EQU	0725H
DIALBGN:	EQU	07A9H
DISCONNT:	EQU	0820H
WAIT:		EQU	09BEH
FNKCHR:		EQU	12C9H
RESTART:	EQU	141FH
INITADR:	EQU	1484H
RETURN:		EQU	196EH
GOLIST:		EQU	2033H
BREAK:		EQU	2098H
TYPE:		EQU	2B71H	 
;
; Values for Novation J-Cat using Ann(1) as offhook line
;
ONHOOK		EQU	0E05AH
OFFHOOK		EQU	0E05BH
;
;
		ORG	100H
;
;
; Change the clock speed to match your equipment
;
		DS	3	;(for  "JMP   START" instruction)
;
; J-Cat dialing routines patched over PMMI routines {DWW 10-04-83}
; IF J-Cat OHK line is not connected, set both PMMIMODEM and
; SMARTMODEM to NO
;
PMMIMODEM:	DB	YES	;yes=J-Cat auto-dial enabled 		103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-pmmi	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	3	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	NO	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in'	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO 	;yes=do not overwrite CCP		116H
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
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'\'-40H	;^\ = Send next character		127H
		DS	2		;				128H
;
IN$MODCTL1:	LDA	MODCTL1 ! RET	;in modem control port	     	12AH
		DS	6
OUT$MODDATP:	STA	MODDATP ! RET	;out modem data port		134H
		DS	6
IN$MODDATP:	LDA	MODDATP ! RET	;in modem data port		13EH
		DS	6		;spares if needed
;
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
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
;
CLREOS:		CALL	JMP$ILPRT	;				195H
EOSCLR:		DB	esc,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	esc,'*',0,0,0	;				1A1H
		RET			;				1A6H
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Apple II with J-Cat modem'
		DB	CR,LF,0
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
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
; 
LOGON:		DB	'Logon message here',0
;
; The following is used to initialize the Apple SSC on execution of the
; program.
;
INITMOD:  mvi	a,1			;default transfer time to 300
	  sta	mspeed
	  mvi	a,DTR
	  sta	COMMAND
	  lda	MODBDP			;current baudrate from moddll
          ani   0f0h			;zero the last 4 bits
;
initmod1: ori   06h			;get default baudrate (300)
	  ani	9fh			;set 8 data bits
	  ani	7fh			;set 1 stop bit
	  sta	MODBDP			;store default baudrate
	  ret
;.....
;
SETUPR:   jmp	initmod
;
; J-Cat is 300 baud only -- no need to change
;
;.....
;
; send break through SSC -- 233 msec space
;
SENDBRK:
	lda	COMMAND	 
	push	psw	; save register content
	ori	0ch	; set bits 2,3
	sta	COMMAND ; break line
	push	b
	lxi	b,233	; wait 233 msec
	call	delay
	pop	b
	pop	psw	; get original register
	sta	COMMAND ; restore it
	ret
;
GOODBYE:
	sta	ONHOOK
	push	b
	lxi	b,25	;on hook for 25 msec
	call	delay
	pop	b
	sta	OFFHOOK
	push	b
	lxi	b,20	;off hook for 20 msec
	call	delay
	pop	b
	sta	ONHOOK	;final disconnect
	RET
;
; wait for the number of millisecs in B,C

delay:	push	d	;save d,e
	inr	b	;bump b for later dcr
;
delay1	mvi	e,126	;delay count for 1 millisec (Apple Z80 clock=2.041mhz)

delay2	dcr	e	;count
	jnz	delay2	;  down

	dcr	c	;more millisecs?
	jnz	delay1	;  yes
	dcr	b	;no - more in hi byte?
	jnz	delay1	;  yes
	pop	d	;  no,	restore d,e
	ret
;
;-----------------------------------------------------------------------
;
; The following routine can be used to display commands on the screen
; of interest to users of this equipment.  
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
;-----------------------------------------------------------------------
;
; J-Cat Dialing Routines
;
; Wait for carrier
;
	org	DIAL15
		 
	mvi	d,20h	; mask for carrier detected bit
	mvi	c,96h	; limit time waiting for carrier
	call	WAIT
	jnc	CONMADE
	call	hangup
	jmp	DIALAGN

; Dial a digit

	org	DIALA2+8

pulse:	push	b
	sta	ONHOOK
	lxi	b,61	;pulse
	call	delay
	sta	OFFHOOK
	lxi	b,39	;delay between pulses
	call	delay
	pop	b
	dcr	c	;any more pulses?
	jnz	pulse	;yes, do them
	lxi	b,300	;300-millisec delay between digits
	call	delay
	ret

; Wait 2 seconds for dial tone

	org	DIALBGN+5	 

	mvi	a,dtr
	sta	MODCTL1	; enable modem
	sta	offhook	; connect phone
	lxi	b,2000
	call	delay
	ora	a	; clear carry
	ret

; Hang up phone

	org	DISCONNT

hangup:	jmp goodbye
	
; Check for carrier

	org	WAIT+5
	lda	MODCTL1 ;get modem status
			  
; Patch out PMMI-specific routines, etc.
	
	org	RESTART+20H
	cnz	SETUPR		; original calls address not used here

	org	RETURN+23H
	call	JMP$INITMOD	; J-Cat needs re-init after dialing

	org	BREAK
	jmp	JMP$BREAK	; don't use PMMI break routine

; The Microsoft CP/M BIOS implementation always returns FALSE
; for the status of the LST: device, so the MDM727 printer output
; routine never sends anything to the printer.  To repair that, the
; simplest patch is to skip over the LST: status test in MDM727.
; That requires a printer fast enough to keep up with the screen
; output.  At 300 baud, that may be feasible:

	org GOLIST+4
	nop			; patch out return if LST: not ready

; Another cure, if your printer card can deliver a status byte, would
; be to patch in a status test (returning zero if printer not ready,
; non-zero if printer can accept a character) in some unused space
; and patch a CALL to that routine at GOLIST.  That requires yet another
; patch, because the INITADR routine in MDM727 automatically patches a
; call to the BIOS LISTST routine at GOLIST.  Here's an example, for a
; Videx PSIO card (serial port) in slot 1:

	org	0D00H	; unused space
PRNTST:	lda	0E099H	; PSIO status port
	ani	10H	; check bit 4
	ret		; carry set = ready

	org	INITADR+15h
	NOP
	NOP
	NOP

	org	GOLIST
	call	PRNTST
	ora	a	; duplicate original code
	rz

	END
