
; I2OS-4.ASM  -  Osborne OS-1 overlay file  for IMP2  - 06/01/87
;
;			   6850  ACIA
;  NOTE:
;
;	This overlay will NOT work with the Osborne COMM-PAC modem or
;	CTS DATACOMM modem.  Both of these modems fit in the Osborne 1
;	left diskette storage pocket and connect to the 9 pin modem
;	socket.  These two modems are 300 bps only and do not have the
;	faster baud rates necessary to take advantage of the IMP2 pro-
;	gram.
;
;	The new 1K CRC protocol is not supported at 300 bps in IMP or
;	KMD.  KMD batch transfers with IMP and KMD are supported only
;	with 1K CRC protocol at 1200 and 2400 bps.
;
;	No real advantage is gained with using IMP at 300 bps.	Osborne
;	COMM-PAC and CTS DATACOM users should continue to use MDM740.
;
;-----------------------------------------------------------------------
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Many terminals will clear the screen with a CTL-Z.  If yours does, put
; a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first
; normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:
; (The ESC will automatically be typed with no CTL-character present.)
; If you don't know what your terminal uses, put a 0 at CLEAR: and IMP2
; will scroll up 24 blank lines to clear the CRT for things like MENU,
; looking at the function key table, typing CTL-Z in command mode, etc.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP2xx.COM,I2OS-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.		- Irv Hoff
; 05/27/86  * Re-edited NUEVO routines to correct assembly errors.
;	    * Re-edited documentation on hardware modifications.
;	    * Software selection for 2400 bps operation now available
;	      with Osborne ROM version 1.45.
;					- Roy Robinson
;					  FOG #4 RCP/M
;
; 10/27/85  * Modified for DTR control of modem.
;	    * Added NUEVO equate to provide software selection for 2400
;	      bps.			- Roy Robinson
;
; 06/27/85  Written for use with IMP2	- Irv Hoff
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; DOCUMENTATION FOR THIS IMP OVERLAY:
;
; SUMMARY:
;
; If you intend to use this overlay with none of the hardware modifica-
; tions described below, set the ROM145 and DTRMOD equates to NO.  Your
; version of IMP2 will have the following baud rate selections: 300 and
; 1200 bps.
;
; The NUEVO equate allows the use of a separate "piggy-back" 80 column
; video board with the optional baud rate generator installed.	This
; board is made by NUEVO Electronics Corporation.  You may contact NUEVO
; Electronics at the VOICE phone number (713) 341-6001.
;
; The DTRMOD equate allows hardware control of the external modem.  The
; DTR signal line can force the modem to hangup the telephone line.
;
; The ROM145 equate allows the use of a special ROM for supporting soft-
; ware selection of 300/1200/2400 bps with IMP2.
;
; ------------
; The NUEVO equate:
;
; If you have the NUEVO 80 column video board with the optional baud
; rate generator installed, set the NUEVO equate to YES.  You will have
; the following baud rate selections: 300, 1200, 2400, 4800, 9600 and
; 19200 bps.  Setting either the HS2400 or HS1200 equate to YES, along
; with the matching MSPEED value will configure IMP for 2400 or 1200
; bps respectively when the program is called up.
;
; If your NUEVO 80 column board does NOT have the optional baud rate
; generator, set the NEUVO equate to NO.  You will have the following
; baud rate selections: 300 and 1200 bps.
; Contact NUEVO if you wish to install the baud rate generator on your
; NUEVO 80 column board.
;
; Be sure the ROM145 equate is set to NO if the NUEVO equate is set YES.
;
;
; ------------
; The DTRMOD equate:
;
; If you install the DTR modification on your Osborne 1 main logic board
; set the DTRMOD equate to YES.  If you are using an UNMODIFIED main
; logic board, set the DTRMOD equate to NO.  The DTR modification gives
; the Osborne 1 the feature of forcing the modem to hang up the phone by
; dropping the 6850 ACIA RTS line.  This control line is then connected
; to the modem DTR input.
;
; The DTR modification is highly recommended if your modem does not
; accept the Hayes/Racal-Vadic modem software command format.
;
; If you do use the DTR modification, you will need to build a special
; RS-232 cable from your Osborne 1 serial port to your external modem.
; Your modem must support DTR line control and you must set the proper
; modem switch(es) or program the modem internal memory to monitor the
; DTR signal.
;
; Below is the RS-232 cable diagram for an external modem using DTR
; control and the Osborne OS-1:
;
;
;	  MODEM 		       OCC-1
;
;	 2    TXD		      3    TXD
;	 3    RXD		      2    RXD
;	 7    GND		      7    GND
;	20    DTR		      5    RTS (new function)
;
;
;
;		  INSTALLATION OF THE DTR MODIFICATION
;
; The main logic board is divided into zones which are identified on the
; component side of the board by LETTER co-ordinates found on the left
; edge of the board and by NUMBER co-ordinates found on the rear edge of
; the board i.e., the 6850 ACIA device is located in zone C5 and the
; MC1458 device is located in zone E3.	The NUMBER co-ordinates are also
; found near the center axis along the length of the main logic board.
; The front edge of the logic board has the printer connector, serial
; connector, and video controls mounted at this edge.
;
;
; A WORD OF CAUTION:
; If you are unsure how to identify IC devices and count device pin num-
; bers, find a friend who does, attend a user group meeting, or take
; your computer to a computer store/service center for further help.
; This advice ALSO applies if you do not have experience in good solder-
; ing techniques.  I have seen these expensive boards burned with traces
; and pads damaged by people using improper soldering irons.  These
; boards have been ruined by users using acid core solder instead of
; good quality electronic solder.  I have seen boards damaged by solder
; bridges and poorly laid out component installation.  Please, if you
; don't know what you are doing, find someone who does.  You may contact
; FOG, an international user group, if you have any questions about
; these modifications.	You may contact FOG by calling the VOICE number:
; (415) 755-2000 or by writing to:
;
;			FOG
;			P. O. BOX 3474,
;			Daly City, CA  94015-0474
;
;
;
;	OSBORNE 1 MAIN LOGIC BOARD TRACE CUTS:
;
;	On the main logic board - SOLDER SIDE:
;
; 1.	Cut the trace running from pin 5 to pin 6 on the inner row of
;	pads used to mount the RS-232 female serial connector at the
;	front edge of the main logic board.  Pins 5 and 6 are the only
;	ADJACENT pins with a trace connecting them.  Do not confuse this
;	trace with another trace which connects pins 6 and 8.  Pin 1 is
;	the pad with a wide ground trace.
;
;	On the main logic board - COMPONENT SIDE:
;
; 2.	Cut the trace from pin 5 of the 6850 ACIA device in zone C5 to
;	resistor R20 (10K ohm) in zone D5.
;
;	PART ADDITIONS:
;
;	On the main logic board SOLDER SIDE:
;
; 3.	Add a jumper wire from pin 1 of the MC1458 device in zone E3 to
;	pin 5 on the inner row of RS-232 serial port pads.  Pin 1 of the
;	serial port is the pad with a wide ground trace.
;
; 4.	Add a jumper wire from pin 3 of the MC1458 device in zone E3 to
;	pin 5 of the same MC1458 device in zone E3.
;
;	On the main logic board COMPONENT SIDE or SOLDER SIDE:
;
;	       (whichever side you feel is easier for mounting
;	       two 1/4 watt resistors)
;
; 5.	Mount a 10K ohm resistor from Vcc which is +5 volts (pin 14 of
;	the 74LS02 device in zone D2 is a good solder point) to pin 2 of
;	the MC1458 device in zone E3.
;
; 6.	Mount a 220  ohm resistor from pin 5 of the 6850 ACIA device in
;	zone C5 to pin 2 of the MC1458 device in zone E3.  Pin 2 of the
;	MC1458 device in zone E3 should now have two resistor leads
;	soldered to it.
;
;
; ------------
; The ROM145 equate:
;
; This equate uses a new Osborne 1 Monitor ROM, Version 1.45. This ROM
; allows 300/1200/2400 baud software selection for the 6850 ACIA.  The
; ROM is used with a hardware modification to the Osborne 1 main logic
; board.  The hardware modification involves installation of five jumper
; wires.
;
; The code in the new 1.45 ROM changes the 6821 control byte value for
; the video PIA register A. The CA2 Peripheral Control Line now becomes
; an output control line rather than an input status line.
;
; If the modification is installed you will be unable to use the Osborne
; COMM-PAC or CTS DATA-COMM modems.  The CA2 line was originally a modem
; input status line for these modems.  With the new ROM, the CA2 line is
; now an output control line used for selecting one of two clock fre-
; quencies input to the 6850 ACIA.
;
; If you have a single density Osborne 1 computer (ROM versions 1.3 and
; lower).  You cannot install this modification.  Contact FOG for fur-
; ther help.
;
; The new ROM 1.45 is available from FOG, a non-profit international
; computer user group.
;
; You may contact FOG by calling the VOICE number (415) 755-2000 or by
; writing to:
;
;		       FOG
;		       P. O. BOX 3474,
;		       Daly City, CA  94015-0474
;
;
; INSTALLATION OF ROM 1.45 MODIFICATION:
;
;	On the main logic board - COMPONENT SIDE:
;
; 1.	Replace the old ROM with the new ROM version 1.45.  This ROM is
;	found at location D12.	Note the orientation of pin 1 for the
;	ROM.
;
; 2.	Remove Jumper J1 located next to the 6850 ACIA device located
;	in zone C5.  There is a silkscreen notation "J1" adjacent to the
;	jumper.  This will expose two pins which we will refer to as the
;	Jumper J1 FRONT pin and the Jumper J1 REAR pin.
;
;	Jumper J1 FRONT pin is the pin toward the front edge of the main
;	logic board.  The front edge has the printer connectors and video
;	controls mounted at the edge.  Since we will be mounting jumpers
;	on the solder side of the main logic board, you will be able to
;	identify the Jumper J1 FRONT pin because this pin has a trace
;	leading to pin 7 of the 74LS161 device at zone C3 on the solder
;	side of the main logic board.
;	Jumper J1 REAR pin has no trace on the solder side of the board
;	and is located toward the rear edge of the main logic board.
;
;	On the main logic board - SOLDER SIDE
;
; 3.	Mount a jumper wire from pin 4 of the 74LS08 device in zone A5
;	to the REAR pin of Jumper J1. This REAR J1 pin is the pin which
;	is closer to the 74LS08 device.
;
; 4.	Mount a jumper wire from pin 5 of the 74LS08 device in zone A5
;	to pin 39 of the 6821 device found within zones C15, C16, C17,
;	and C18.  (The 6821 is a 40 pin device and occupies several
;	zones.)
;
; 5.	Mount a jumper wire from pin 6 of the 74LS08 device in zone A5
;	to pin 5 of the 74LS02 device in zone D2.
;
; 6.	Mount a jumper wire from pin 5 of the 74LS02 device in zone D2
;	to pin 6 of the same 74LS02 device in zone D2.	Pin 5 of the
;	74LS02 device in zone D2 now has two jumpers soldered to it.
;
; 7.	Mount a jumper wire from pin 4 of the 74LS02 device in zone D2
;	to the FRONT pin of Jumper J1.	This FRONT J1 pin is the pin
;	which is closer to the 74LS02 device.
;
;-----------------------------------------------------------------------
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;*    TAMPERING WITH YOUR MAIN LOGIC BOARD MAY VOID ANY WARRANTY
;     OR SERVICE AGREEMENTS ON YOUR COMPUTER.
;
;*    UNPLUG YOUR COMPUTER FROM THE AC OUTLET BEFORE DISASSEMBLING
;     THE COMPUTER.  USE COMMON SENSE.
;
;*    ALTHOUGH THE MODIFICATION HAS BEEN TESTED ON SEVERAL MAIN
;     LOGIC BOARDS HAVING DIFFERENT REVISION LEVELS, THE MODIFI-
;     CATION IS DONE AT YOUR OWN RISK.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
;	EQUATES FOR MODIFICATIONS TO STANDARD OZZIE MAIN LOGIC BOARD
;
DTRMOD	EQU	NO	; YES, if hardware mods have been installed on
			;   Osborne 1 main logic board to support DTR
			;   control of external modem.
			; NO, if you have an UNMODIFIED main logic
			;   board
			;   (see discussion above)
;
NUEVO	EQU	NO	; YES, if Nuevo 80 column upgrade WITH Baud Rate
			;   Generator option has been installed
			; NO, if you do not have a Nuevo 80 column up-
			;   grade or if your Nuevo 80 column upgrade
			;   DOES NOT have the Baud Rate Generator op-
			;   tion installed.  (See discussion above.)
;
ROM145	EQU	NO	; YES, if hardware mods have been installed on
			;   Osborne 1 main logic board to support 2400
			;   bps WITH ROM version 1.45.
			; NO, if the ROM monitor is NOT Version 1.45
			;   (see discussion above)
;
;
; Values shown are for the 6850 ACIA serial I/O device
;
PORT	EQU	2A00H	; OCC-1 base address
			; (memory mapped for data and status)
MDCTL1	EQU	PORT	; Modem control address (memory mapped i/o)
MDDATP	EQU	PORT+1	; Modem data address (memory mapped i/o)
MDRCV	EQU	01H	; Modem receive data register full (RDRF)
MDSND	EQU	02H	; Modem transmit data register empty (TDRE)
MDTXE	EQU	02H	; Modem transmit buffer empty (set to MDSND)
RMDRCV	EQU	0FEH	; Used with SSTAT routines
RMDSND	EQU	0FDH	; Used with SSTAT routines
;
;
; NOTE: The 6850 ACIA, "an early generation serial I/O chip", has
;	only one output status bit with the mask value: 02h.
;	This output status bit is defined as "Transmit Data Register
;	Empty"	and is roughly equivalent to the "Transmit Buffer
;	Empty" status bit found in modern I/O chips.  Most modern
;	I/O chips have an additional output status bit which is a
;	"Transmit Ready" status bit.  The 6850 ACIA does not have
;	this status bit.  Without this second status bit available,
;	the timing routines for the ASCII upload function in IMP2
;	which involve inter-character timing delay and end-of-line
;	timing delay do not work as efficiently.
;	For the Osborne 1 you will not have as effective a range of
;	timing delay values as on computers using more advanced I/O
;	chips .  You will have enough delay timing for most ASCII
;	upload applications.
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H ; ^[ = Escape
BELL	EQU	'G'-40H ; ^G = Bell character
LF	EQU	'J'-40H ; ^J = Linefeed
NEXTRY	EQU	'K'-40H ; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H ; ^M = Carriage return
CLEARSC EQU	'Z'-40H ; ^Z = Clears screen, command mode only
EOFCHAR EQU	'Z'-40H ; ^Z = End of file
;
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
;
;
	DS	3	; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:  DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:  DB	NO	; Yes=2400 bps highest speed			104H
HS1200:  DB	YES	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:  DB	NO	; Reserved for special modems			108H
RESVD2:  DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	1AH	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:  DB	4	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	4	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			;   default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:  DB	4	; Number of directory columns shown		10EH
TCHPUL:  DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:  DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=CTL-chars above ^M not displayed		113H
;.....
;
;
EXTCHR:  DB	'['-40H ; ESC = preceeds local control character	114H
EXITCHR: DB	'E'	; Exit character				115H
FILESND: DB	'F'	; Send file when in terminal mode		116H
NOCONCT: DB	'N'	; Disconnect from phone line			117H
LOGCHR:  DB	'L'	; Send logon					118H
LSTCHR:  DB	'P'	; Toggle printer				119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECHR: DB	'Y'	; Open input text buffer			11BH
CLEARS:  DB	'Z'	; Clears screen, terminal mode			11CH
BRKCHR:  DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; YES if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: JMP	OSTAT		;					11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  JMP	OSTAT		;					129H
	  DB	0,0,0,0,0,0,0	; Spares if needed			12CH
;
I$MDDATP: JMP	OSIN		;					133H
	  DB	0,0,0,0,0,0,0	; Spares if needed			136H
;
O$MDDATP: JMP	OSOUT		;					13DH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;.....
;
;
A$MDRCV:  ANI	MDRCV		;					147H
	  RET			;					149H
;
C$MDRCV:  CPI	MDRCV		;					14AH
	  RET			;					14CH
;
A$MDSND:  ANI	MDSND		;					14DH
	  RET			;					14FH
;
C$MDSND:  CPI	MDSND		;					150H
	  RET			;					152H
;
A$MDTXE:  ANI	MDTXE		;					153H
	  RET			;					155H
;
C$MDTXE:  CPI	MDTXE		;					156H
	  RET			;					158H
;.....
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:
	  JMP	RSTINT		;					159H
;.....
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE 	; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD 	; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;.....
;
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168H
J$STRNG1: DS	3		; 2400 bps "AT" string			16BH
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
;
J$CMDSPL: DS	3		; Allows entry of baudrate on CMD line	16EH
J$CRLF:   DS	3		; Turns up one new line on display	171H
J$DIAL:   DS	3		; Start of dialing routine		174H
J$DSCONT: DS	3		; Terminates modem use			177H
J$GOLST:  DS	3		; Printer routine, needed by Apple //e	17AH
J$ILPRT:  DS	3		; Prints an inline string, 0 to end	17DH
J$INBUF:  DS	3		; Stores a keybd string for comparison	180H
J$INLNCP: DS	3		; Inline "compare strings" routine	183H
J$INMDM:  DS	3		; Max .1 sec wait for modem character	186H
J$RCVRSP: DS	3		; For 3801 I/O use (TV-803)		189H
J$SNDCHR: DS	3		; Sends a character to the modem	18CH
J$SNDSTR: DS	3		; Sends a string to the modem, $ to end 18FH
J$TIMER:  DS	3		; .1 second timer (amount in 'B' reg.)	192H
J$BREAK:  JMP	SENDBRK 	; Break routine 			195H
J$NEW2:   DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:   DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:   JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:   JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:   DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT 	; Display the following line		1A7H
	DB	'Version for Osborne 1' 	;			1AAH
;
	 IF	NUEVO
	DB	' with Neuvo BRG option'
	 ENDIF			; NUEVO
;
	 IF	DTRMOD
	DB	' and DTR mod',CR,LF
	 ENDIF			; DTRMOD
;
	 IF	NOT	DTRMOD
	DB	' without DTR mod',CR,LF
	 ENDIF			; NOT DTRMOD
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
;	 available after start of SYSVER).
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; (special character-L).  You can put in several lines.  End with a 0.
;
LOGON:	DB	'Greetings from an Osborne 1 user',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sends a 300 ms break tone
;
SENDBRK:
	 IF	NOT DTRMOD
	RET
	 ENDIF			; NOT DTRMOD
;
	 IF	DTRMOD		; Stop any incoming characters
	MVI	C,77H		; Send break, RTS active,
	CALL	STBAUD		; Send to status port routine
	MVI	B,3		; Delay 300 ms. fora break tone
	CALL	J$TIMER
	JMP	GOODBYE1
	 ENDIF			; DTRMOD
;.....
;
;
; This routine sets the ACIA RTS output low for 300 ms. to disconnect
; the phone.  The RTS output from 6850 is connected to the DTR input of
; the modem.
; This routine drops DTR for 300 ms to disconnect the phone.
;
GOODBYE:
	 IF	NOT DTRMOD
	RET
	 ENDIF			; NOT DTRMOD
;
	 IF	DTRMOD
	MVI	C,77H		; Send break, RTS active,
	CALL	STBAUD		; Send to status port routine
	MVI	B,3		; Delay 300 ms. to hang up the phone
	CALL	J$TIMER
	MVI	C,57H		; Disable break and RTS to hang-up modem
	CALL	STBAUD		; Send to status port routine
	MVI	B,10		; Delay 1 second to hang up phone
	CALL	J$TIMER
;
GOODBYE1:
	LDA	BAUDRTE 	; RTS active, same baud rate
	MOV	C,A
	JMP	STBAUD		; Send to status port routine
	RET
	 ENDIF			; DTRMOD
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
;
	 IF ROM145 AND NOT NUEVO
B$SET:	JMP	BRATE		; Jump to relocated routine which se-
				;   lects high/low clock rate for ACIA
				;   TXD/RXD clock inputs.
	 ENDIF			; ROM145 AND NOT NUEVO
;
;.....
;
;
INITMOD:
	LHLD	0005H+1 	; Find start of bdos
	LXI	D,-0100H	; Go to first page ahead of bdos
	DAD	D		; HL now positioned one page below bdos
	PUSH	H		; Save the address
	LXI	D,BDJ		; Point to our routine to put there
	LXI	B,CDLEN+2	; Set length of code
	XCHG
	DB	0EDH,0B0H	; Z80 LDIR instruction
;
	LHLD	0005H+1 	; Get BDOSs address back once more
	POP	D		; Get starting address off the stack
	PUSH	D		; Put it back on the stack
	INX	D		; Point to address position
	XCHG			; Put into HL register pair
	MOV	M,E		; Store 'LSP' address
	INX	H		; Get 'LSP' location
	MOV	M,D		; Store 'MSP' address
	POP	H		; Get the address back once more
	SHLD	0005H+1 	; New address to protect from overwrite
;
	LXI	D,OSIN-BDJ	; Get OSICN length for relocation
	DAD	D		; Commute address of the OSIN routine
	SHLD	I$MDDATP+1	; Patch call for "GET CHARACTER" routine
;
	LXI	D,OSOUT-OSIN	; Get OSOUT length for relocation
	DAD	D		; Commute address of the OSOUT routine
	SHLD	O$MDDATP+1	; Patch call for "SEND CHARACTER" routine
;
	LXI	D,OSTAT-OSOUT	; Get OSTAT length for relocation
	DAD	D		; Commute address of OSTAT routine
	SHLD	I$MDCTL1+1	; Patch call for "GET I/O STATUS" routine
	SHLD	I$MDTXE+1	; Patch call for "TRANSMIT BUFFER EMPTY"
				; routine
;
	 IF	ROM145 AND NOT NUEVO
	LXI	D,BRATE-OSTAT	; Get BRATE length for relocation
	DAD	D		; Commute address of BRATE routine
	SHLD	B$SET+1 	; Patch call for "RX/TX CLOCK SELECT" routine
	 ENDIF			; ROM145 AND NOT NUEVO
;
;
;  Set-up program default baud rate, then finish with initialization
;
	LDA	MSPEED		; Get program default baud rate value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
;
	 IF	NUEVO OR ROM145
	CPI	6		; 2400 bps
	JZ	OK2400
	 ENDIF			; NUEVO OR ROM145
;
	JMP	STUPR1		; Else ask what is wanted
;
;.....
;
;
;-----------------------------------------------------------------------
;
RSTINT:
	JMP	0000H		; Osborne 1 likes this jump upon exit
;
;.....
;
;
;-----------------------------------------------------------------------
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1: CALL	J$ILPRT
;
	 IF	NOT NUEVO AND NOT ROM145
	DB	'Input Baud Rate (300, 1200): ',0
	 ENDIF			; NOT NUEVO AND NOT ROM145
;
	 IF	NUEVO AND NOT ROM145
	DB	'Input Baud Rate (300, 1200, 2400, 4800, 9600, 19200): ',0
	 ENDIF			; NUEVO AND NOT ROM145
;
	 IF	ROM145 AND NOT NUEVO
	DB	'Input Baud Rate (300, 1200, 2400): ',0
	 ENDIF			; ROM145 AND NOT NUEVO
;
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;
STUPR2: CALL	J$INLNCP	; Compare BAUDBUF+2 with chars. below
	DB	'300',0
	JNC	OK300		; Go if got match
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
;
	 IF	NUEVO OR ROM145
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	 ENDIF			; NUEVO OR ROM145
;
	 IF	NUEVO AND NOT ROM145
	CALL	J$INLNCP
	DB	'4800',0
	JNC	OK4800
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	 ENDIF			; NUEVO AND NOT ROM145
;
	CALL	J$ILPRT 	; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
;.....
;
;
	 IF	(NOT NUEVO AND NOT ROM145)
OK300:	MVI	A,1		; MSPEED 300 baud value
	 ENDIF			; (NOT NUEVO AND NOT ROM145)
;
	 IF	(NOT NUEVO AND NOT ROM145) AND DTRMOD
	MVI	C,16H		; X64 clock, 8 DB 1 SB, RTS active
	 ENDIF			; (NOT NUEVO AND NOT ROM145) AND DTRMOD
;
	 IF	(NOT NUEVO AND NOT ROM145) AND NOT DTRMOD
	MVI	C,56H		; X64 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; NOT NUEVO AND NOT ROM145 AND NOT DTRMOD
;
	 IF	(NOT NUEVO AND NOT ROM145)
	JMP	LOADBD		; Load ACIA control byte
;
OK1200: MVI	A,5		; MSPEED 1200 baud value
	 ENDIF			; (NOT NUEVO AND NOT ROM145)
;
	 IF	(NOT NUEVO AND NOT ROM145) AND DTRMOD
	MVI	C,15H		; X16 clock, 8 DB 1 SB, RTS active
	 ENDIF			; (NOT NUEVO AND NOT ROM145) AND DTRMOD
;
	 IF	(NOT NUEVO AND NOT ROM145) AND NOT DTRMOD
	MVI	C,55H		; X16 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; (NOT NUEVO AND NOT ROM145) AND NOT DTRMOD
;
	 IF	(NOT NUEVO AND NOT ROM145)
OK2400: 			; Needs to be here even if not supported
;
LOADBD: STA	MSPEED
	MOV	A,C		; Move ACIA control byte from C to A
	STA	BAUDRTE 	; Save ACIA control byte
	 ENDIF			; (NOT NUEVO AND NOT ROM145)
;
;....
;
;
	 IF	(ROM145 AND NOT NUEVO)
OK300:	MVI	A,1		; MSPEED 300 baud value
	 ENDIF			; (ROM145 AND NOT NUEVO)
;
	 IF	(ROM145 AND NOT NUEVO) AND DTRMOD
	MVI	C,16H		; X64 clock, 8 DB 1 SB, RTS active
	 ENDIF			; (ROM145 AND NOT NUEVO) AND DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO) AND NOT DTRMOD
	MVI	C,56H		; X64 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; (ROM145 AND NOT NUEVO) AND NOT DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO)
	MVI	B,3FH		; Get low baud parameter
	JMP	LOADBD		; Load ACIA control byte
;
OK1200: MVI	A,5		; MSPEED 1200 baud value
	 ENDIF			; (ROM145 AND NOT NUEVO)
;
	 IF	(ROM145 AND NOT NUEVO) AND DTRMOD
	MVI	C,15H		; X16 clock, 8 DB 1 SB, RTS active
	 ENDIF			; (ROM145 AND NOT NUEVO) AND DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO) AND NOT DTRMOD
	MVI	C,55H		; X16 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; (ROM145 AND NOT NUEVO) AND NOT DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO)
	MVI	B,3FH		; Get low baud parameter
	JMP	LOADBD		; Load ACIA control byte
;
OK2400: XRA	A		;
	STA	MANUAL		; Reset to maximum auto-speed for
	MVI	A,6		; 2400 bps auto-step down modems
	 ENDIF			; (ROM145 AND NOT NUEVO)
;
	 IF	(ROM145 AND NOT NUEVO) AND DTRMOD
	MVI	C,15H		; X16 clock, 8 DB 1 SB, RTS active
	 ENDIF			; (ROM145 AND NOT NUEVO) AND DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO) AND NOT DTRMOD
	MVI	C,55H		; X16 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; (ROM145 AND NOT NUEVO) AND NOT DTRMOD
;
	 IF	(ROM145 AND NOT NUEVO)
	MVI	B,37H		; Get high baud parameter
;
LOADBD: STA	MSPEED
	MOV	A,C
	STA	BAUDRTE
	CALL	B$SET		; Select high/low baud rate status bit
	 ENDIF			; (ROM145 AND NOT NUEVO)
;
;..
;
;
	 IF	(NUEVO AND NOT ROM145)
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	B,05H		; Get 300 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK1200: MVI	A,5		; MSPEED 1200 baud value
	MVI	B,07H		; Get 1200 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK2400: XRA	A		; Reset to maximum auto-speed for
	STA	MANUAL		; 2400 bps auto-step down modems
	MVI	A,6		; MSPEED 2400 baud value
	MVI	B,0AH		; Get 2400 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK4800: MVI	A,7		; MSPEED 4800 baud value
	MVI	B,0CH		; Get 4800 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK9600: MVI	A,8		; MSPEED 9600 baud value
	MVI	B,0EH		; Get 9600 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK19200:
	MVI	A,9		; MSPEED 19200 baud value
	MVI	B,0FH		; Get 19200 bps byte
;
LOADBD: STA	MSPEED		; Save MSPEED byte
	MOV	A,B		; Move baud rate byte from B to A
	OUT	6		; Send baud rate divisor to Nuevo baud
				; rate generator
	 ENDIF			; (NUEVO AND NOT ROM145)
;
	 IF	(NUEVO AND NOT ROM145) AND DTRMOD
	MVI	C,15H		; 16X clock, 8 DB 1 SB, RTS active
	 ENDIF			; (NUEVO AND NOT ROM145) AND DTRMOD
;
	 IF	(NUEVO AND NOT ROM145) AND NOT DTRMOD
	MVI	C,55H		; 16X clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; (NUEVO AND NOT ROM145) AND NOT DTRMOD
;
	 IF	(NUEVO AND NOT ROM145)
	MOV	A,C
	STA	BAUDRTE 	; Save ACIA control byte
	 ENDIF			; (NUEVO AND NOT ROM145)
;
;.....
;
;
STBAUD: PUSH	H
	CALL	OSET
	POP	H
	RET
;
;.....
;
;
OSET:	LHLD	1		; Get bios+3 address
	MVI	L,3CH		; Extended bios routine for baud rate select
	PCHL			; branch to it
;
;.....
;
;
BAUDBUF:DB	10,0
	DS	10
;
BAUDRTE:  DB	0	; RAM location for baud rate byte
SSTAT:	  DB	0	; RAM location serves as a secondary status register
			;   for 6850 ACIA status register.
			;   This RAM register is used because the  6850 ACIA
			;   clobbers its own internal status register
			;   (with regard to TBE and RDA status bits) when
			;   data is traveling in both directions via the
			;   serial port -- important for ascii text uploads.
;
;.....
;
;
; --- ROUTINES THAT ARE PLACED JUST UNDER BDOS AND OVERLAY THE CCP
;
BDJ:	JMP	$-$		; This gets patched to jump to bdos entry
;
OSIN:	LDA	SSTAT		; Update SSTAT location in RAM
	ANI	RMDRCV		; before inputing data
	STA	SSTAT
;
	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	LDA	MDDATP		; Get data input
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
	RET
;
;.....
;
;
OSOUT:	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	STA	MDDATP		; Send data output
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
;
	LDA	SSTAT		; Update SSTAT location in RAM
	ANI	RMDSND		; after outputing data
	STA	SSTAT
	RET
;
;.....
;
;
OSTAT:	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	LDA	MDCTL1		; Get status byte
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
;
	PUSH	B		; Update SSTAT location in RAM
	MOV	B,A		; using current ACIA status register
	LDA	SSTAT		; and earlier ACIA status register
	ORA	B
	STA	SSTAT
	POP	B
	RET
;
;.....
;
;
	 IF	(ROM145 AND NOT NUEVO)
BRATE:	DI			; disable interrupts
	OUT	0		; Switch to alternate bank
	MOV	A,B
	STA	2C01H		; Send data to 6821 control register
	MVI	A,0EAH		; Reset video horizontal offset and DD bit
	STA	0EF61H		; Update BIOS RAM location
	STA	2C00H		; Output data byte to 6821 PIA
	OUT	1		; Switch to main bank
	EI
	RET
	 ENDIF			; (ROM145 AND NOT NUEVO)
;
;.....
;
;
CDLEN	EQU	$-BDJ		; Length of code to relocate
;
;			       fini
;-----------------------------------------------------------------------
;
; NOTE:  Must terminate by 0400H
	END
