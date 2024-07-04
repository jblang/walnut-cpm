; M7QX-3.ASM -- Epson QX-10 overlay file for VALDOCS 1.1X  06/06/84
;
;		Overlay file for MDM730 (and later), Epson QX-10, and the
;		D.C. Hayes Smartmodem 300 or 1200, US Robotics modems, the
;		Anchor Automation Signalman Mark XII, Prometheus, or similiar
;		modems which use the DC Hayes Smartmodem protocols.  It is
;	 	designed to be used with a .SYS extent as a VALDOCS applica-
;		tion from the <M>enu of Applications, <R>un specific program,
;		or <E>xit to TPM options.  It will also run under TPM-II
;		without VALDOCS (using a .SYS or .COM extent) or under
;		CP/M A2.21 or B2.20 if given a .COM file extent.  It
; 		incorporates the special SET menu advantages of Bruce
;		Ratoff's ATXMODEM, plus it offers the ability to toggle
;		on or off the 7th bit mask. This permits the use of QX-10
;		graphics when desired, but retains the ability to use this
;		same program on mainframes such as Compuserve.  This overlay
;		is specifically tailored to MDM730 and makes direct calls to
;		addresses in the main program.  You must change these addresses
;		to use this overlay with a later MDM7XX series program.
;		For standardization among the four operating systems used on
;		the QX-10, I have chosen ^B for the sendbreak character,
;		and ^Z to transmit control characters above ^M to the remote.
;
;******************************************************************************
;
; NOTE:  All improvements to this overlay intended for distribution must be
; compatible with VALDOCS.  Send all updates to either the Technical RCPM/RBBS
; (313)846-6127, or CompuServe CP/MIG (PCS-47), Area XA0 along with a message
; addressed to the SYSOP.  They, in turn, will make official release.  If you
; wish to discuss the overlay, leave a message for Chris Hopkins, 71026,1407 on
; CompuServe's EpsOnLine SIG (PCS-19), or EMAIL.
;
;******************************************************************************
;
; Switch settings for the D.C. Hayes Smartmodem and Smartmodem 1200 are:
;
;	SW1	SW2	SW3	SW4	SW5	SW6	SW7	SW8
;	UP	ANY	ANY	ANY	ANY	UP	ANY*	DN
;
;   These settings are compatible with those used in VALDOCS MAIL to prevent
;   unnecessary changing of settings.  This program resets switches 2 thru 5
;   by software, so their physical settings have no effect.
;
;   *Depends on type of telephone jack used.
;.....
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file, filling in answers for your own
;		preferences.  Assemble with ASM.COM or equivalent
;		assembler to obtain a file named M7QX-3.HEX.  Then
;               use DDT to overlay the HEX file on the original .COM file:
;
;		A>DDT MDM730.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7QX-3.HEX    	(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;               A>SAVE 73 QXMDM3.SYS   (now have a modified .SYS file)
;					(can also make a .COM file now)
; 
;    =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 06/06/84 - Renamed to M7QX-3.ASM and added addresses for MDM740.ASM. 
; 	   - Added BYEBYE messages for CP/M, TPM and VALDOCS. 
; 	   - Corrected error in hardware initiation that forgot to tell the
;	     QX-10 baudrate timer the speed in use according to the CMOS. 
;	   - Corrected timing problem in VALDOCS during ^T text transfer. 
; 	   - Corrected GOODBYE and SENDBRK to reset to parameters that were in
;	     use before the break.  Previously, it always reset to 8 bit words,
;	     1 stop bit and no parity. 
; 	   - Corrected timing problems for VALDOCS by placing CLOCKSET routine
;	     at START.  Previously, timing set did not occur until INITMOD.
;							-Chris Hopkins 
; 04/15/84 - Removed macros to allow assembly using ASM.COM, and revised to
;	     work with MDM730. 
; 	   - Added cursor control routines for signon. 
; 	   - Added toggle in SET command to allow selection of QX-10 graphics
;	     for use in the terminal mode.  Subsequent selection of 7-bit
;	     words or 8-bit words with the 7th bit masked cancels the
;	     graphics selection. - Chris Hopkins
; 03/11/84 - Renamed to M7QX-2.ASM and revised to work with MDM727.  
; 	   - Added subroutines to provide [ Using TPM ], [ Using CP/M ] and
;	     [ Using VALDOCS ] statements following signon message. - CH 
; 01/22/84 - Revised M712QS.ASM to fit MDM718-720, renamed overlay to
;            M7QX-1.ASM to conform to new format. 
; 	   - Added sendbreak routine and revised signon - Chris Hopkins
; 10/13/83 - Checks for CP/M or TPM to prevent crashing CP/M
;	     with TPM backdoor calls. - BRR
; 10/11/83 - Detects presence of SYSINIT and uses its interrupt-driven
;            serial routines if present. - BRR
; 10/10/83 - Stop bits, parity, word size in SETUPR - BRR
; 08/14/83 - Cosmetic changes only for MDM712	- Bruce Ratoff
; 07/26/83 - QX-10 version created from GP file - Bruce Ratoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 07/01/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
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
;------------------------------------------------------------------------------
; The following equates are addresses in the main program of MDM730.COM.  If
; this overlay is adapted to a later version, these may have to be changed.
;
PMMIMENU:	EQU	09EDH		;addr of SPCLMENU in basic program 
					;available as extra patch area.
					;For MDM730 use 09EDH
					;For MDM740 use 0A78H
					;Must match byte of basic program.
;
START:		EQU	13CAH		;addr of START in basic program.
 					;For MDM730-740 use 13CAH
;
SPEED4:		EQU	1A7EH		;addr of SPEED4 in basic program.
					;For MDM730-740 use 1A7EH
;
TERML:		EQU	1F01H		;addr of TERML in basic program.
					;Use 1F01 for MDM730-740
;
GRAFMASK:	EQU	TERML+10	;addr of 7th bit mask in TERML
;
BYEBYE:		EQU	404DH		;addr of BYEBYE in basic program.
					;For MDM730-740 use 404DH
;
;------------------------------------------------------------------------------
; The following information is specific to the Epson QX-10.
;
PORT:		EQU	011H		;QX-10 base port
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data in port
MODDATO:	EQU	PORT		;Modem data out port
TPORTS:		EQU	007H		;Baud rate setup port
TPORTC:		EQU	006H		;Baud rate counter port
MODRCVB:	EQU	1		;Bit to test for receive
MODRCVR:	EQU	1		;Value when ready
MODSNDB:	EQU	4		;Bit to test for send
MODSNDR:	EQU	4		;Value when ready
CRAM:		EQU	35		;CMOS RAM baud rate storage
MOSADR:		EQU	3DH		;CMOS RAM address port
MOSDAT:		EQU	3CH		;CMOS RAM data port
;
		ORG	100H
;.....
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem, no=non-PMMI	103H
AUTODIAL:	DB	YES	;yes=HAYES Smartmodem or lookalike	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;When booting up, the program will set  107H
				;this flag to match the QX-10's current
				;CMOS baud rate.
BYTDLY:		DB	5	;0=0 delay, 1=10ms, 5=50ms - 9=90ms     108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay, 1=100ms, 5=500ms - 9=900ms  109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added SETUP routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
RETRY:		DB	YES	;yes=reset the error limit to try again 10DH
				;no=abort after 10 consecutive errors
				;(ARPANET users should select yes)
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	NO	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling of rub to backspace	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES 	;yes=allow transmission of logon	115H
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
IGNORCTL:	DB	NO 	;yes=CTL-chars above ^M not displayed	11DH
TPMFLG:		DB	NO	;set by the program, always no here	11EH
VALFLG:		DB	NO	;set by the program, always no here	11FH
BRKCHR:		DB	'B'-40H	;^B = Send 300 ms. break tone		120H
				;(CP/M A & B don't permit CONTROL-@)
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'Z'-40H	;^Z = Send next character		127H
				;(CP/M A doesn't permit CONTROL-^ while
				;..CP/M B requires SHIFT CONTROL-^ to get
				;..the character, so we standardized with this)
		DS	2	;					128H
;.....
; Handles in/out ports for data and status:
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port	     	12AH
					;INITMOD makes this a jump to SYSI$STAT
					;when run under VALDOCS
		DS	7		;spares
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
					;INITMOD makes this a jump to SYSI$OUT
					;when run under VALDOCS
		DS	7		;spares
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
					;INITMOD makes this a jump to SYSI$IN
					;when run under VALDOCS
		DS	7		;spares
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;bypasses PMMI routines		156H
;
OUT$MODCTL1:	RET	! NOP 	! NOP	;out modem control port #1	15AH
OUT$MODCTL2:	RET 	! NOP 	! NOP	;out modem control port #2	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	3		;do not change			162H
JMP$DISCONNT:	RET	! NOP	! NOP	;not needed with QX-10/Smartmdm 165H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET 	! NOP 	! NOP	;(by-passes PMMI routine)	16EH
		RET 	! NOP 	! NOP	;(by-passes PMMI routine)	171H
		RET 	! NOP 	! NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;INITMOD makes this a		180H
					;jump to SYSI$BREAK when run 
					;under VALDOCS
; Do not change the following six lines.  They go to specific locations in the 
; main program, not the overlay.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;.....
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010CH (above).  Room allowed for four bytes.  Last zero
; needed for stopping the string display.  Any extra zeros just act as NOPs.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,059H,0,0,0	;Hex code for ESC Y		198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	01AH,0,0,0,0	;Hex for Control Z		1A1H
		RET			;				1A6H
;.....
; NOTE:  You can change the SYSVER and LOGON messages to be longer or
;        shorter.  The following overlay routines must terminate before 0400H.
;
SYSVER:		CALL	CPMMODE		;Set CP/M emulation mode	1A7H   
		CALL	CLRSCRN		;
		CALL	JMP$ILPRT	;
		DB	ESC,3DH,2AH,3DH,'WELCOME TO QX-MODEM'
		DB	ESC,3DH,2CH,3DH,'For the Epson QX-10'
		DB	ESC,3DH,2EH,3FH,0
		RET
;.....
; You can put a message at this location which will be called up with
; CTL-L if TRANLOGON has been set TRUE.  In this overlay version, approximately
; 8 bytes are available for LOGON message.  A common usage of this feature is
; 'FIRSTNAME;LASTNAME;PASSWORD' separated by semi-colons for use in signing
; on to remote bulletin boards with only one keystroke.  The logon capability
; has lost much of its importance with the addition of function keys to the 
; program.  The length of this overlay has left little room for the logon
; sequence.  End with a 0.
;
LOGON:		DB	'Hello',CR,LF,0
;.....
; Sets DTR low for 300ms
;
GOODBYE:	MVI	A,5		;point to register 5
		OUT	MODCTL1		
		LDA	TXBYT		;fetch the most recent TXBYT sent
		ANI	7FH		;set the DTR bit low
;
GOODBYE1:	OUT	MODCTL1		;send it
		MVI	B,3		;delay 300ms
		CALL	JMP$TIMER
		MVI	A,5		;point to register 5
		OUT	MODCTL1
		LDA	TXBYT		;restore previous condition by sending
		OUT	MODCTL1		;..the original TXBYT
		RET
;.....
; This is a continuation of BYEBYE from end of overlay.
;
BYEBYE1:	RZ			;if CP/M, back to main program
		LDA	VALFLG		;if not CP/M, is it VALDOCS?
		ORA	A
		CZ	TPMMSG		;no? then print TPM
		CNZ	VALMSG		;if yes, then VALDOCS
		RET			;back to main program
;.....
; The following SENDBRK routine sends a break tone to reset some time-share
; computers, such as BRS After Dark and Dialog's Knowledge Index.  However, it
; will usually cause an immediate disconnect when on line with an RBBS/RCPM
; system.  This routine is automatically replaced by SYSI$BREAK if run under
; VALDOCS.
;
SENDBRK:        MVI    	A,5		;point to register 5
                OUT    	MODCTL1
                LDA    	TXBYT  		;get TXBYT currently in use  	
		ORI	10H		;turn sendbreak bit on
	        JMP     GOODBYE1
;.....
; This routine shuttles from TPM to CP/M 
;
CPMMODE:	LXI	D,0CCCCH	;Put request for CP/M in D reg
BDOSMODE:	MVI	C,12
		JMP	5
;......
; This routine sets the CLOCK equate for computations at the very beginning of
; the main program.
;
CLOCKSET:	LXI	H,0		;Set HL to 0 since these three bytes
					;were stolen from main program START
					;subroutine
		CALL	CPMMODE		;get system version
		MOV	A,E
		CPI	'T'		;is this CP/M?
		RNZ			;if CP/M, quit here
		MVI	A,YES		;store flag saying TPM in use
		STA	TPMFLG
		LXI	D,0		
		CALL	BACKDOOR	;if VALDOCS SYSINIT module is not
					;loaded, returns 0FFH in A register
		INR	A
		RZ			;If no SYSINIT, quit here
		MVI	A,YES		;tell flag that VALDOCS is loaded
		STA	VALFLG
		MVI	A,2		;Replace clock value with this to
		STA	CLOCK		;..reduce apparent speed for overhead
					;..calls if using VALDOCS
		RET
;.....
; This routine checks to see what system the program is running under.  It
; announces it at signon and, if VALDOCS SYSINIT module is loaded, it rewrites
; code to direct the use of backdoor subroutines needed by VALDOCS.  
;
INITMOD:	CALL 	JMP$ILPRT
		DB	'[ Using ',0
		LDA 	TPMFLG		;is this CP/M or TPM?
		ORA	A
		PUSH	PSW
		CZ	CPMMSG		;if CP/M, go get message
		POP	PSW
		JZ	NOSYSINIT	;..and go back to work
		LDA	VALFLG		;we're this far, must be TPM or VALDOCS
		ORA	A		;which is it?
		PUSH	PSW
		CZ	TPMMSG		;if TPM, go get message
		POP	PSW
		JZ	NOSYSINIT	;..and then skip ahead
		CALL	VALMSG		;now this far, must be VALDOCS
		MVI	A,0C3H		;Mod modem I/O to use BACKDOOR routines
		STA	IN$MODCTL1
		STA	OUT$MODDATP
		STA	IN$MODDATP
		LXI	H,SYSI$STAT
		SHLD	IN$MODCTL1+1
		LXI	H,SYSI$OUT
		SHLD	OUT$MODDATP+1
		LXI	H,SYSI$IN
		SHLD	IN$MODDATP+1
		LXI	H,SYSI$BREAK
		SHLD	JMP$BREAK+1
		MVI	A,2
		STA	ANI$MODSNDB+1
		STA	CPI$MODSNDR+1
		MVI	A,11H		;load op code for LXI D and then store
		STA	SPEED4		;..speed to insure correct...
		LXI	H,1275		;..timing is used under VALDOCS...
		SHLD	SPEED4+1	;..for ^T text transfers
		MVI	A,0		;put NOP to fill
		STA	SPEED4+3
		LXI	D,4FFH		;Re-enable BACKDOOR interrupt stuff
		CALL	BACKDOOR
;.....
; If SYSINIT was not loaded, program comes here to see if carrier is present
; (DCD active), and then reset the modem if not. 
;	
NOSYSINIT:	CALL	JMP$ILPRT	;send cursor to bottom of page
		DB	ESC,3DH,36H,20H,0
		MVI 	A,CRAM		;point to QX-10 CMOS baud rate address
		DI			;disable interrupts
		OUT	MOSADR		;
		IN	MOSDAT		;get CMOS status byte
		EI			;enable interrupts
		ANI	0FH		;set flags & strip off all but baudrate
		CPI	3		;operating at 300 baud?
		JNZ 	TEST1200	;if not, see if 1200
		LXI	H,CSPDTBL+12	;if 300, point to that speed in table
NOSYSINIT1:	MOV	E,M		;load baudrate into D-E
		INX	H		
		MOV	D,M
		XCHG			;now put it in H-L
		CALL	FINDRATE	;tell the timer and set MSPEED flag
NOSYSINIT2:	CALL	SIOINIT		;send out default SIO initialization
		CALL 	IN$MODCTL1	;look at status of DCD
		ANI	8		;is connection active?
		RNZ			;if yes, initialization already done
		LXI	H,MDMRESET
		CALL	SEND		;Reset the modem
		RET
;.....
; If baudrate set on CMOS was not 300, program comes here to see if it is 1200
; baud.  If not, a prompt is called to allow user to set either 300 or 1200.
; The Smartmodem can only be addressed at those two speeds.
;
TEST1200:	CPI	5		;is it 1200 baud?
		PUSH	PSW		;save the flags
		CNZ	AGAIN		;if not, means we weren't at 300 or
					;1200, so get a SET prompt to fix.
		POP	PSW		;bring flags back
		JNZ	NOSYSINIT2	;continue with new speed from prompt
		LXI	H,CSPDTBL+20	;was 1200, so point to 1200 in table
		JMP 	NOSYSINIT1	;back to work
;.....
; This series of bytes initialize the Smartmodem, and are taken from the
; owner's manual.
;
MDMRESET:	DB	'ATE1M1Q0V1S0=0S11=55',CR,0
					;E1=set switch 4, echo on in local cmd
					;M1=speaker on til carrier detect
					;Q0=set switch 3, result codes sent
					;V1=set switch 2, word result codes
					;S0=0=set switch 5, mdm will not answer
					;S11=55=touchtone dial speed
					;CR,0=send it. Must end with a zero
;
CPMMSG:		CALL	JMP$ILPRT
		DB	'CP/M ]',0
		RET
;
TPMMSG:		CALL	JMP$ILPRT
		DB	'TPM ]',0
		RET
;
VALMSG:		CALL 	JMP$ILPRT
		DB	'VALDOCS ]',0
		RET
;.....
; This subroutine is used in place of SENDBRK when running under VALDOCS
;
SYSI$BREAK:	PUSH	D
		LXI	D,07FFH		;send break  
		CALL	BACKDOOR
		MVI	B,3		;wait 300ms
		CALL 	JMP$TIMER
		LXI	D,0700H 	;turn sendbreak off
		CALL	BACKDOOR
		POP 	D
		RET
;.....
; This subroutine is called in place of IN MODCTL1 when running under VALDOCS
;
SYSI$STAT:	PUSH	D
		MVI	D,3		;Get SYSINIT serial port status byte
					;and return it in the A register
		CALL	BACKDOOR
		POP	D
		RET
;
;.....
; This subroutine is called in place of OUT MODDATP when running under VALDOCS
;
SYSI$OUT:	PUSH	D
		PUSH	PSW
		MOV	E,A		;get char to send from A and move to E
		MVI	D,2		;send it
		CALL	BACKDOOR
		POP	PSW
		POP	D
		RET
;
;......
; This subroutine is called in place of IN MODDATP when running under VALDOCS
;
SYSI$IN:	PUSH	D
		MVI	D,1		;receive a character, put it in A
		CALL	BACKDOOR
		POP	D
		RET
;.....
; This back door subroutine (BDS03) provides support for the B side of
; the 7201 MPSCC, otherwise known as the "serial port", when using VALDOCS.  
;
BACKDOOR:	PUSH	H		;Save unused registers
		PUSH	B
		PUSH	D		;Save BACKDOOR call arguments
		LXI	D,0AAAAH	;Set TPM mode
		CALL	BDOSMODE
		POP	D		;Get back BACKDOOR arguments
		LXI	B,(3 SHL 8)+40	;Function codes for BACKDOOR serial
					;routines, 3 (BDS03) in the B reg
					;and 40 in the C reg.
		CALL	5		;Call TPM
		PUSH	PSW		;Save result of BACKDOOR call
		CALL	CPMMODE		;Go back into CP/M mode
		POP	PSW		;Restore BACKDOOR result
		POP	B		;Restore registers
		POP	H
		RET
;.....
; Sends out the serial I/O initialization
;
SIOINIT:	PUSH	H
		MVI	C,MODCTL1	;modem control port
		MVI	B,MINLEN	;length of modem init table
		LXI	H,MINTBL	;point to init table
		DB	0EDH,0B3H	;sneak in Z80 op code to OTIR the init
					;table
		POP	H
		RET
;.....
; Modem initialization table.  Default settings: 8 bit words, no parity, 1 stop
; bit, transmit and receive enabled.
;
MINTBL:		DB	4		;point to register 4
PARBYT:		DB	44H		;the parity byte
		DB	3		;point to register 3
RXBYT:		DB	0C1H		;the receive byte 
		DB	5		;point to register 5
TXBYT:		DB	0EAH		;the transmit byte
MINLEN:		EQU	$-MINTBL
;
EVNPAR:		LXI	B,0FC03H
SETPAR:		LDA	PARBYT
		ANA	B
		ORA	C
		STA	PARBYT
SETPXX:		CALL	SIOINIT	
		JMP	GDLUP		;go back for another parameter
;
ODDPAR:		LXI	B,0FC01H
		JMP	SETPAR
;
NOPAR:		LXI	B,0FC00H
		JMP	SETPAR
;
ONESTOP:	LXI	B,0F304H
		JMP	SETPAR
;
TWOSTOP:	LXI	B,0F30CH
		JMP	SETPAR
;
BIT7:		MVI	A,7FH		;load mask in A
		STA	GRAFMASK	;store it in main program TERML routine
		MVI	A,41H
		STA	RXBYT
		MVI	A,0AAH
BIT7XX:		STA	TXBYT
		JMP	SETPXX
;
GRAFON:		MVI	A,0FFH		;load mask in A
		STA	GRAFMASK	;store it at TERML, lets 7th bit pass
		JMP	BIT8
;
GRAFOFF:	MVI	A,7FH		;load mask in A
		STA	GRAFMASK	;store it at TERML, stops 7th bit
BIT8:		MVI	A,0C1H		
		STA	RXBYT
		MVI	A,0EAH
		JMP	BIT7XX
;.....
; Make modem's speed flag match QX-10's
;
SETMSPEED:	MVI	A,CRAM		;point to baudrate address
		DI			;stop interrupts
		OUT	MOSADR		
		IN	MOSDAT		;get status byte
		EI			;ok to interrupt now
		ANI	0FH		;strip all but baudrate, set flags
		LXI	H,MSPDTBL	;load HL with table address
		ADD	L		;make the conversion
		MOV	L,A		;
		JNC	SETMSPD2	;carry? if not, jump
		INR	H		;if yes, increment MSB of pointer
;
SETMSPD2:	MOV	A,M		;move table value to register A
		STA	MSPEED		;store it at MSPEED
		RET
;
;.....
; This table gives MSPEED values for QX-10 CMOS baud rate values.
; Note that lower rates do not match and approximations are used.
;
MSPDTBL:	DB	0,0,0,1,3,5,6,7,8,2
;
TBLADR:		DW	0
;
;******************************************************************************
;          NOTE: All above overlay routines must end before 0400H
;******************************************************************************
;
		ORG	PMMIMENU	;pop over to second patch area
					;(overlays PMMI special menu)
;.....
; Clock speed table.  This gives the timer chip divisors for each baud rate.
; Must be in same order as MSPDTBL.
;
CSPDTBL:	DW	110,1135 	; 0
		DW	135,924	 	; 1
		DW	150,832	 	; 2
		DW	300,416	 	; 3
		DW	600,208	 	; 4
		DW	1200,104 	; 5
		DW	2400,52	 	; 6
		DW	4800,26	 	; 7
		DW	9600,13	 	; 8
		DW	450,277	 	; 9
;
NXTARG:		CALL	SCNTOB
		RC
;
SCNNB:		LDAX	D
		CPI	' '
		RNZ
		INX	D
		DCR	B
		JNZ	SCNNB
		STC
		RET
;
SCNTOB:		LDAX	D
		CPI	' '
		RZ
		RC
		INX	D
		DCR	B
		JNZ	SCNTOB
		STC
		RET

;
KEYBUF:		DB	10
		DB	0,0,0,0,0,0
		DB	0,0,0,0,0,0
;..... 
; Send a string to the Smartmodem
;
SEND:		MOV	A,M		;Get a character
		INX	H
		ORA	A		;End of the string?
		RZ
		MOV	C,A		;No, send it
		CALL	PUT
		CALL	JMP$INMODEM	;Eat echo
		JMP	SEND
;
PUT:		CALL	IN$MODCTL1	;Get modem status
		CALL	ANI$MODSNDB	;Test send bits
		CALL	CPI$MODSNDR
		JNZ	PUT
		MOV	A,C
		JMP	OUT$MODDATP
;.....
; The following routine changes the baud rate, parity and word length for
; the QX-10 from the SET menu.
;
SETUPR:		LDAX	D		;Look at passed-in byte count
		CPI	5		;Enuf for possible baud rate?
		JC	AGAIN		;No, prompt for one
		MOV	B,A		;Save byte count
		INX	D		;Point to first byte
		CALL	NXTARG		;Skip to next argument
		MOV	A,B
		JNC	SETUP1
;
AGAIN:		CALL	JMP$ILPRT
		DB	'Enter Baud Rate and/or Options: ',0
		LXI	D,KEYBUF
		CALL	JMP$INBUF	;read baud rate from console
		LXI	D,KEYBUF+1
		LDAX	D
		INX	D
;
SETUP1:		MOV	L,A		;Force null at end of buffer
		MVI	H,0		
		DAD	D
		MVI	M,0
		LXI	H,0
;
GDLUP:		LDAX	D
		INX	D
		ORA	A
		JZ	GDONE
		CPI	' '		;Ignore spaces
		JZ	GDLUP
		SUI	'0'		;Try for digit
		JC	BADRATE
		CPI	10
		JNC	BADRATE
		MOV	B,H
		MOV	C,L
		DAD	H
		DAD	H
		DAD	B
		DAD	H
		MVI	B,0
		MOV	C,A
		DAD	B
		JMP	GDLUP
;
BADRATE:	ADI	'0'		;Fix bias from conversion routine
		CPI	'E'		;Check option letters for
		JZ	EVNPAR		;Even parity
		CPI	'O'
		JZ	ODDPAR		;Odd parity
		CPI	'N'
		JZ	NOPAR		;No parity
		CPI	'S'
		JZ	ONESTOP		;One stop bit
		CPI	'T'
		JZ	TWOSTOP		;Two stop bits
		CPI	'A'
		JZ	BIT7		;ASCII mode (7 data bits)
		CPI	'B'
		JZ	GRAFOFF		;Binary mode (8 data bits) with 7th bit
					;masked
		CPI	'G'
		JZ	GRAFON		;8 data bits, but with no masking to
					;permit use of QX-10 graphics in
					;terminal mode
		CALL	JMP$ILPRT	;Anything else gets error
		DB	CR,LF,'[ Invalid rate ]',CR,LF,0
		JMP	AGAIN
;
GDONE:		MOV	A,H
		ORA	L
		JZ	QUIT
;.....
; Enter here with baud rate in HL to set baud rate of timer.
;
FINDRATE:	PUSH	H		;save baud rate
		LXI	H,CSPDTBL	;load table address
		SHLD	TBLADR		;store it there
		POP	H		;get baud back
		LXI	B,0A00H		
;
CLP:		PUSH	H
		LHLD	TBLADR		;get address back
		MOV	E,M		;move value to E
		INX	H		;advance pointer
		MOV	D,M		;other half in D
		INX	H
		XTHL			
		XCHG			;switch
		ORA	A		;prepare for true subtract by clearing
		DB	0EDH,52H	;sneak in Z80 op code to SBC HL,DE
		XCHG			;switch again
		XTHL
		JZ	DOIT
		INX	H
		INX	H
		SHLD	TBLADR
		POP	H
		INR	C
		DCR	B
		JNZ	CLP
		JMP	BADRATE
;
DOIT:		POP	D		
		MVI	A,0B6H
		OUT	TPORTS
		MOV	A,M
		INX	H
		OUT	TPORTC
		MOV	A,M
		OUT	TPORTC
		CALL	IN$MODDATP
		CALL	IN$MODDATP
		MVI	A,CRAM
		DI			;Disable interrupts
		OUT	MOSADR
		MOV	A,C
		OUT	MOSDAT
		EI			;Enable interrupts
;
QUIT:		JMP	SETMSPEED
;.....
; This special menu is unavailable without putting the actual address of
; SPCLMENU (in the basic program) in the overlay above at the PMMIMENU equate.
;
SPCLMENU:	CALL	JMP$NXTSCRN
		CALL	JMP$ILPRT
		DB	'        Additional SET options for QX-10',cr,lf,lf
		DB	'  Parity:',cr,lf
		DB	'    E - Even',cr,lf
		DB	'    O - Odd',cr,lf
		DB	'    N - None',cr,lf,lf
		DB	'  Stop bits:',cr,lf
		DB	'    S - Single (1)',cr,lf
		DB	'    T - Two    (2)',cr,lf,lf
		DB	'  Data bits (word length):',cr,lf
		DB	'    A - ASCII mode (7 data bits)',cr,lf
		DB	'    B - Binary mode (8 data bits)',cr,lf
		DB	'    G - Graphics mode (8 data bits, no masking)'
		DB	CR,LF,LF
		DB	'  Examples:',cr,lf
		DB	'	SET 300ETA',cr,lf
		DB	'	SET B',cr,lf
		DB	'	SET NSG 1200',cr,lf
		DB	0
		RET
;
;******************************************************************************
;    NOTE:  THE ABOVE MUST TERMINATE PRIOR TO 0CBB FOR MDM730 THRU MDM740.
;******************************************************************************
;
;.....
; This routine modifies the basic program to call CLOCKSET before timing rates
; are computed.  The overlayed bytes (LXI H,0) are placed at the beginning
; of CLOCKSET.
;	
		ORG	START
		CALL	CLOCKSET
;.....
; This subroutine overlays BYEBYE of basic program to add capability of send-
; ing correct signoff messages as program exits through BYE command.
;     
	        ORG	BYEBYE+20
		DB	CR,LF,'[ Exit to ',0
		LDA	TPMFLG		;is this CP/M or TPM?
		ORA	A
		CZ	CPMMSG		;if CP/M, go get message
		CALL	BYEBYE1		;go continue this
;
		END	
;