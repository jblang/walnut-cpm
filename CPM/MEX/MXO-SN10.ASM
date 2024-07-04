;	Title	'MEX overlay for the Sanyo MBC-1200/1250 Computer'
;
; 	This file adapts the Sanyo MBC-1200/1250 to the MEX modem program.
;
;	Created:    06/15/87    Last Modification:  06/15/87
;
;	NOTE:	Once you get this overlay into MEX, I heartily recommend
;		that you adjust the page size and clock speed in the running
;		program. To do the former, type 'STAT PAGE 33' and hit 
;		<ENTER> at the MEX:A0>> prompt. To do the latter, time 
;		a 60 second or so MEX 'SLEEP' command and adjust the 
;		clock speed with 'STAT CLOCK'. Once you've got it right,
;		use the 'CLONE' command to make a permanent version.  
;
; 	You will want to look this file over carefully. There are a number of
; 	options that you can use to configure the program to suit your taste.;
; 	Edit for your preferences, reassemble, and MLOAD the *.HEX file into
;	MEX as described in its documentation.
;____________________________________________________________________________
;
;	SOME GENERAL NOTES:
;
;	There are a variety of notes regarding how the overlay works, why it
;	is the way it is, what you can and can't do with it included here.
;
;	This overlay is intelligent regarding the SANYO 12## and stupid
;	regarding any specific modems. It has been debugged using a
;	SANYO 1250.
;
;	If you need to add code for your particular modem, likely spots for
;	its inclusion are after the 8215 chip mode initialization in the
;	NITMOD (initialize modem) routine and in the SET command handler
;	routine. You can get some general ideas from the Sanyo 1000 overlay
;	source by scanning for their SmartModem equate in IF clauses with
;	your editor and looking at what is done there. Most modem support
;	above and beyond initialization and SET command support seems more
;	appropriate in a separate overlay...
;
;	Relatively complete documentation of the 8251 usart used is included
;	in comments preceding the fixed format data area, along with equates
;	for the various mode word fields, etc. You can use this information
;	and the equates to adjust the operation of the overlay and to modify
;	any routines you want to...
;
;	If you wish to use this overlay with some SmartModem overlay, bear
;	in mind that it must end before that one starts.
;
;	The SET command implemented in this overlay gives relatively full
;	control of the 8251 usart used by the Sanyo 12##'s for RS232C
;	interface imlementation. More than you are likely to use. The modem
;	specific stuff is pretty much up to you. Code for a "SET DIAL"
;	command that sets the TPULSE flag byte (location 105H) used by
;	SmartModem overlays for TOUCH/PULSE dialing control was left in
;	IF clauses controlled by the DIALSET equate. This command does
;	nothing but set the flag one way or another. You need more code
;	to actually make it do something useful (such code might live in
;	a separate overlay source code fiel such as the one(s) for the
;	SmartModem), but it's there if you want it. Set the DIALSET equate
;	to YES if you do.
;
;	Further information on the SET command can be found near the code
;	actually implements it. Search for the string "SET COMMAND" and
;	you shall be rewarded...
;____________________________________________________________________________
;
;	BAUD RATE NOTES:
;
; 	Use the "SET" command to change the baudrate when desired.  It starts
; 	out at 1200 baud when the program is first called up.
;
; 	Only 300 & 1200 Baud are enabled. Due to the way the Sanyo 12##'s are
;	designed, anything else requires modifying the positions of baud rate
;	jumpers in the box.
;
;	*********************************************************************
;	NOTE:	Since the Sanyos basically control the baud rate thru
;		jumpering, it follows that there is a right way and a wrong
;		way for those jumpers to be set when using this program. It
;		just so happens that the default factory setting is 1200 baud
;		in the 8251 usart chip 16x mode, which is exactly what we want
;		here. This allows us to go to 64x mode and get 300 baud on
;		those unfortunate and unusual occasions when we want it.
;		Since the 8251 clock rate divisor modes are in multiples of
;		four, there is no way I know of to get both 2400 and 1200
;		baud out of the same jumper setting. You could wire in a
;		switch... Nonetheless, one of these days, if you still have
;           	this box when 4800 baud becomes the vogue, the code changes
;           	will be simplicity itself.
;	*********************************************************************
;____________________________________________________________________________
;
;	CREDIT WHERE CREDIT IS DUE DEPARTMENT:
;
;	This overlay file originated in the overlay for the SANYO 1000
;	called MXO-SY21.ASM, which in turn originated someplace else....
;
;	The hardware is different enough that quite a large portion of the
;	code here is either new or re-arranged to suit my quirky mentality.
;	Nonetheless, much has been retained, and never having done any code
;	of this variety before, my thanks to Bob Sandel, who wrote the
;	overlay for the 1000.
;
;____________________________________________________________________________
;
REV	EQU	10		; Overlay revision level
;
; 	Miscellaneous equates
;
YES	EQU	0FFH
NO	EQU	0
ALLBITS EQU	11111111B
;
;	ASCII character equates
;
BELL	EQU	07H		; Bell
TAB	EQU	09H		; Tab
LF	EQU	0AH		; Line feed
CR	EQU	0DH		; Carriage return
ESC	EQU	1BH		; Escape
;
; 	Note that all overlays may freely use memory up to 0CFFH.  If your
; 	overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM) or
; 	the MEX DATEC 212 overlay (MXO-DT10.ASM), the physical modem overlay
; 	should terminate by 0AFFH. Refer to the docs for any others.
;
TPA	EQU	0100H		; Transient Program Area
MEX	EQU	0D00H		; Address of the service processor
;
;	The following equate determines whether code is included to 
;	set the TPULSE dial flag that I must assume is used by some 
;	modem overlays. I have no use for it. You may.
;
DIALSET EQU	NO		; Include SET DIAL command?
;
PORT	EQU	0EDH		; Sanyo 8251 modem USART control port
MODCTL	EQU	PORT		; MODEM CONTROL PORT
MODDAT	EQU	PORT-1		; MODEM DATA PORT
;____________________________________________________________________________
;
;	SOME DOCUMENTATION ON THE 8251 USART USED IN THE SANYO(S)
;	and equates usable for controlling most of the stuff...
;____________________________________________________________________________
;
;	8251A chip mode word bit definitions
;
;	The initial data used to construct a mode word for the 8251
;	chip in default operation is located in the overlay data area
;	that follows the first fixed data area that is understood by MEX.
;	This area starts around address 01A7H and has a comment containing
;	the string "OVERLAY DATA AREA" if you want to scan for it...
;
;	+------+------+------+------+------+------+------+------+
;	| DB7  | DB6  | DB5  | DB4  | DB3  | DB2  | DB1  | DB0  |
;	+------+------+------+------+------+------+------+------+
;	| S2   | S1   | EP   | PEN  | L2   | L1   | B2   | B1   |
;	+------+------+------+------+------+------+------+------+
;	|      |      |      |      |      |      |      |
; 	|+-----+      |      |      |      |      |      |
;	||+-----------+      |      |      |      |      |
;	|||+-----------------+      |      |      |      |
;	||||+-----------------------+      |      |      |
;	|||||+-----------------------------+      |      |
;	||||||+-----------------------------------+      |
;	|||||||+-----------------------------------------+
;	||||||||
;	||||||||
;	|||||||+---------> 0    1    0    1
;	||||||+----------> 0    0    1    1
;	||||||       MODE: SYNC 1X   16X  64X
;	||||||
;	|||||+-----------> 0    1    0    1
;	||||+------------> 0    0    1    1
;	||||         CHAR: 5    6    7    8  (BITS)
;	||||
;	|||+-------------> PARITY: 1=ENABLE, 0=DISABLE
;	|||
;	||+--------------> PARITY: 1=EVEN,   0=ODD
;	||
;	|+---------------> 0    1    0    1
;	+----------------> 0    0    1    1
;		     STOP: N/A  1    1.5  2  (BITS)
;
;	Most of the above is self-explanatory. One comment on the MODE
;	settings 1x, 16, 64x. These are specifications that essentially
;	tell the usart chip, "the clock input you are getting is this
;	many times faster than it should be..." What this means is that
;	the 1, 16 or 64 that you specify is used by the chip to divide
;	the clock rate before using it. That is why using 16x as standard
;	for 1200 baud, we can goto 300 baud by switching to 64x, since:
;		 1200/300=4=64/16 or (1200*16)=(300*64)
;	Since I have no idea what or if the minimum usable clock rate is,
;	all bets are off if you rejumper your box and/or use 1x mode.
;	But by all means try it, if you need to...
;
;	Some mode equates:
;
;	Internal clock rate divisor
;
SYNC	EQU	00000000B	; SYNC MODE (NOT USED)
X01	EQU	00000001B	;   1X MODE (NOT USED)
X16	EQU	00000010B	;  16X MODE 1200 BAUD
X64	EQU	00000011B	;  64X MODE  300 BAUD
;
;	Character size
;
CHRLEN5 EQU	00000000B	; CHAR = 5 BITS
CHRLEN6 EQU	00000100B	; CHAR = 6 BITS
CHRLEN7 EQU	00001000B	; CHAR = 7 BITS
CHRLEN8 EQU	00001100B	; CHAR = 8 BITS
;
;	Parity enable/disable, even/odd
PTYENBL EQU	00010000B	; ENABLE
PTYDSBL EQU	00000000B	; DISABLE
PTYEVEN EQU	00100000B	; EVEN
PTYODD	EQU	00000000B	; ODD
;
;	Stop bit settings
;
STPB1	EQU	01000000B	; 1 STOP BIT
STPB1H	EQU	10000000B	; 1 1/2 STOP BITS
STPB2	EQU	11000000B	; 2 STOP BITS
;
;	8251A chip command word bit definitions
;	+------+------+------+------+------+------+------+------+
;	| DB7  | DB6  | DB5  | DB4  | DB3  | DB2  | DB1  | DB0  |
;	+------+------+------+------+------+------+------+------+
;	| EH   | IR   | RTS  | ER   | SBRK | RXE  | DTR  | TXEN |
;	+------+------+------+------+------+------+------+------+
;	|      |      |      |      |      |      |      |
; 	|+-----+      |      |      |      |      |      |
;	||+-----------+      |      |      |      |      |
;	|||+-----------------+      |      |      |      |
;	||||+-----------------------+      |      |      |
;	|||||+-----------------------------+      |      |
;	||||||+-----------------------------------+      |
;	|||||||+-----------------------------------------+
;	||||||||
;	||||||||
;	|||||||+---------> TRANSMIT: 1=ENABLE, 0=DISABLE
;	|||||||
;	||||||+----------> DATA TERMINAL READY:  1=FORCE (NOT DTR) TO ZERO
;	||||||
;	|||||+-----------> RECEIVE:  1=ENABLE, 0=DISABLE
;	|||||
;	||||+------------> SEND BREAK CHARACTER: 1=FORCE (TXD) TO ZERO
;	||||
;	|||+-------------> ERROR RESET: 	 1=RESET FLAGS PE, OE, FE
;	|||
;	||+--------------> REQUEST TO SEND:	 1=FORCE (NOT RTS) TO ZERO
;	||
;	|+---------------> INTERNAL RESET:	 1=GOTO MODESET MODE
;	|
;	+----------------> ENTER HUNT MODE:	 1=ENABLE SEARCH FOR SYNC CHRS
;						 (NO EFFECT IN ASYNC MODE)					
;	
;	NOTE: MUST PERFORM ERROR RESET WHENEVER RXE AND EH ARE PROGRAMMED.
;
;	Some command equates
;	
EH	EQU	10000000B	; ENTER  HUNT MODE
IR	EQU	01000000B	; INTERNAL RESET
RTS	EQU	00100000B	; REQUEST TO SEND
ER	EQU	00010000B	; ERROR RESET
SBRK	EQU	00001000B	; SEND BREAK CHARACTER 
RXE	EQU	00000100B	; RECEIVE ENABLE
DTR	EQU	00000010B	; DATA TERMINAL READY
TXEN	EQU	00000001B	; TRANSMIT ENABLE
;
;	8251A chip status word bit definitions
;	+-------+-------+-------+-------+-------+-------+-------+-------+
;	| DB7   | DB6   | DB5   | DB4   | DB3   | DB2   | DB1   | DB0   |
;	+-------+-------+-------+-------+-------+-------+-------+-------+
;	| DSR   | SYNDET| FE    | OE    | PE    |TXEMPTY| RXRDY | TXRDY |
;	+-------+-------+-------+-------+-------+-------+-------+-------+
;	|       |       |       |       |       |       |       |
; 	|+------+       |       |       |       |       |       |
;	||+-------------+       |       |       |       |       | 
;	|||+--------------------+       |       |       |       | 
;	||||+---------------------------+       |       |       |
;	|||||+----------------------------------+       |       |
;	||||||+-----------------------------------------+       |
;	|||||||+------------------------------------------------+
;	||||||||
;	||||||||
;	|||||||+---------> BIT HAS DIFFERENT MEANING FROM TXRDY OUTPUT PIN
;	|||||||		   BIT NOT CONDITIONED BY (NOT CTS) AND TXEN.
;	|||||||		       MEANS: DB BUFFER EMPTY
;	|||||||		   PIN IS CONDITIONED BY POTH OF THE ABOVE.
;	|||||||		       MEANS: DB BUFFER EMPTY * (CTS=0) * (TXEN=1)
;	|||||||
;	||||||+----------> SAME AS I/O PIN
;	||||||
;	|||||+-----------> SAME AS I/O PIN
;	|||||
;	||||+------------> PARITY ERROR: SET WHEN A PARITY ERROR IS DETECTED.
;	||||		   RESET BY COMMAND WORD ER BIT. DOESN'T INHIBIT 8251
;	||||
;	|||+-------------> OVERRUN ERROR: SET WHEN CPU DOESN'T READ A CHAR 
;	|||		   BEFORE NEXT IS AVAILABLE. RESET BY ER BIT OF
;	|||		   COMMAND WORD. DOESN'T INHIBIT 8251 OPERATION.
;	|||
;	||+--------------> FRAMING ERROR: SET WHEN VALID STOP BIT IS NOT 
;	||		   DETECTED AT THE END OF EVERY CHARACTER. RESET BY
;	||		   ER BIT OF COMMAND WORD. DOESN'T INHIBIT 8251.
;	||
;	|+---------------> SAME AS I/O PIN.
;	|
;	+----------------> DATA SET READY: INDICATES DSR IS AT ZERO 
;
;	Some status equates
;
DSR	EQU	10000000B	; DATA SET READY
SYNDET	EQU	01000000B	; 
FE	EQU	00100000B	; FRAMING ERROR
OE	EQU	00010000B	; OVERRUN ERROR 
PE	EQU	00001000B	; PARITY ERROR
TXEMPTY EQU	00000100B	; 
RXRDY	EQU	00000010B	; 
TXRDY	EQU	00000001B	; 
;
;	Various byte equate values constructed from the above follow..
;
RESET1	EQU	EH+RXE+DTR+TXEN	; Initialize UART
RESET2	EQU	IR		; Internal reset
CHIPSET EQU	RTS+RXE+DTR+TXEN ; DTR, RTS, RE, TE
DISCNT	EQU	ER+RXE+DTR+TXEN	; No DTR, RTS, RE, TE
;
;  Progammable Baud Rate factors (theoretical)        
;
NA	EQU	0FFH		; Value for baud rate not available
;
BD110	EQU	NA		; NO 110	BAUD RATE 0    
BD300	EQU	X64		; <300>     	BAUD RATE 1
BD450	EQU	NA		; NO 450    	BAUD RATE 2
BD600	EQU	NA		; NO 600    	BAUD RATE 3
BD710	EQU	NA		; NO 710    	BAUD RATE 4
BD1200	EQU	X16		; <1200>	BAUD RATE 5
BD2400	EQU	NA		; NO 2400   	BAUD RATE 6
BD4800	EQU	NA		; NO 4800   	BAUD RATE 7
BD9600	EQU	NA		; NO 9600   	BAUD RATE 8
BD19K	EQU	NA		; NO 19200  	BAUD RATE 9
;____________________________________________________________________________
;
; 	MEX service processor stuff ... MEX supports an overlay service
; 	processor, located at 0D00H (and maintained at this address from
; 	version to version).  If your overlay needs to call BDOS for any
; 	reason, it should call MEX instead; function calls below about
; 	240 are simply passed on to the BDOS (console and list I/O calls
; 	are specially handled to allow modem port queueing, which is why
; 	you should call MEX instead of BDOS).  MEX uses function calls
; 	above about 244 for special overlay services (described below).
;
; 	Some sophisticated overlays may need to do file I/O; if so, use
; 	the PARSFN MEX call with a pointer to the FCB in DE to parse out
; 	the name.  This FCB should support a spare byte immediately pre-
; 	ceeding the actual FCB (to contain user # information).  If you've
; 	used MEX-10 for input instead of BDOS-10 (or you're parsing part
; 	of a SET command line that's already been input), then MEX will
; 	take care of DU specs, and set up the FCB accordingly.  There-
; 	after all file I/O calls done through the MEX service processor
; 	will handle drive and user with no further effort necessary on
; 	the part of the programmer.
;
INMDM	EQU	255		; Get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		; Delay 100ms * reg B
TMDINP	EQU	253		; B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		; Check for ^C from KBD, Z=present
SNDRDY	EQU	251		; Test for modem-send ready
RCVRDY	EQU	250		; Test for modem-receive ready
SNDCHR	EQU	249		; Send a character to the modem (after sndrdy)
RCVCHR	EQU	248		; Recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		; Table search: see CMDTBL comments for info
PARSFN	EQU	246		; Parse filename from input stream
BDPARS	EQU	245		; Parse baud-rate from input stream
SBLANK	EQU	244		; Scan input stream to next non-blank
EVALA	EQU	243		; Evaluate numeric from input stream
LKAHED	EQU	242		; Get nxt char w/o removing from input
GNC	EQU	241		; Get char from input, cy=1 if none
ILP	EQU	240		; Inline print
DECOUT	EQU	239		; Decimal output
PRBAUD	EQU	238		; Print baud rate
;
CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10
;_____________________________________________________________________________
;
;	BEGIN FIXED FORMAT DATA AREA 
;	This data area is layed out in a format understood by MEX. 
;	Don't mess with the ordering of data here, as it is used to 
;	synchronize the operations of MEX with this and any other 
;	overlay(s) you may be using.
;
	ORG	TPA		; We begin
;
	DS	3		; MEX has a JMP START here
;
; 	The following variables are located at the beginning of the program
; 	to facilitate modification without the need of re-assembly. They will
; 	be moved in MEX 2.0.
;
PMODEM:	DB	NO		; Yes=PMMI modem   (not referenced by MEX)
SMODEM:	DB	NO		; Yes=Smartmodem   (not referenced by MEX)
TPULSE:	DB	'P'		; T=touch, P=pulse (not referenced by MEX)

;	NOTE:	This peculiar clock speed was set by timing the 
;		MEX 'SLEEP' command on my box. If yours is different,
;		just change it with 'STAT CLOCK' and 'CLONE' MEX.
CLOCK:	DB	47		; Clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	5		; Sets initial baud rate
				; 0=110	1=300  2=450  3=600  4=710
				; 5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		; Default time to send character in
				; Terminal mode file transfer (0-9)
				; 0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		; End-of-line delay after CRLF in terminal
				; Mode file transfer for slow BBS systems
				; 0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		; Number of directory columns
SETFL:	DB	YES		; Yes=user-defined SET command
SCRTST:	DB	YES		; Yes=if home cursor and clear screen
				; Routine at CLRSCRN
	DB	0		; Was once ACKNAK, now spare
BAKFLG:	DB	NO		; Yes=make .BAK file
CRCDFL:	DB	YES		; Yes=default to CRC checking
				; No=default to Checksum checking
TOGCRC:	DB	YES		; Yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		; Yes=convert backspace to rub
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub
ADDLF:	DB	NO		; No=no LF after CR to send file in
				; Terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR
TRNLOG:	DB	NO		; Yes=allow transmission of logon
				; Write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP
LOCNXT:	DB	NO		; Yes=local cmd if EXTCHR precedes
				; No=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		; Yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		; Yes=allow toggling of printer on/off
				; In terminal mode. Set to no if using
				; The printer port for the modem
XOFTST:	DB	NO		; Yes=allow testing of XOFF from remote
				; While sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after sending CR while
				; Transmitting a file in terminal mode	
TOGXOF:	DB	YES		; Yes=allow toggling of XOFF testing
IGNCTL:	DB	YES		; Yes=do not send control characters
				; Above CTL-M to CRT in terminal mode
				; No=send any incoming CTL-char to CRT
EXTRA1:	DB	0		; For future expansion
EXTRA2:	DB	0		; For future expansion
BRKCHR:	DB	'@'-40H		; ^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		; ^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		; ^L = Send logon
LSTCHR:	DB	'P'-40H		; ^P = Toggle printer
UNSVCH:	DB	'R'-40H		; ^R = Close input text buffer
TRNCHR:	DB	'T'-40H		; ^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		; ^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		; ^^ = Send next character
;
	DS	2		; Not used - only for PMMI routines
;
; 	Low-level modem I/O routines: this will be replaced with
; 	a jump table in MEX 2.0 (you can insert jumps here to longer
; 	routines if you'd like ... I'd recommend NOT putting part of
; 	a routine in this area, then jumping to the rest of the routine
; 	in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL:	IN	MODCTL		; In modem control port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed
;
OTDATA:	OUT	MODDAT		; Out modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed
;
INPORT:	IN	MODDAT		; In modem data port
	RET
	DB	0,0,0,0,0,0,0	; Spares if needed
;
; 	Bit-test routines.  These will be merged with the above
; 	routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI	RXRDY		; Bit to test for receive ready
	RET
;
TESTR:	CPI	RXRDY		; Value of receive bit when ready
	RET
;
MASKS:	ANI	TXRDY		; Bit to test for send ready
	RET
;
TESTS:	CPI	TXRDY		; Value of send bit when ready				
	RET
;
; 	Unused area: was once used for special PMMI functions.
; 	Now used only to retain compatibility with MDM overlays.
; 	You may use this area for any miscellaneous storage you'd
; 	like but the length of the area *must* be 12 bytes.
;
	DS	12
;
; 	Special modem function jump table: if your overlay cannot handle
; 	some of these, change the jump to "DS 3", so the code present in
; 	MEX will be retained.
;
LOGON:	DS	2		; Needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		; Dial digit in A (see info at PDIAL)
DISCV:	DS	3		; Disconnect the modem
GOODBV:	JMP	CPMEXT		; Called before exit to CP/M
INMODV:	JMP	NITMOD		; Initialization. Called at cold-start
NEWBDV:	JMP	SBAUD		; Set baud rate
NOPARV:	DS	3		; Set for no parity (called after transfer)
PARITV:	DS	3		; Set modem parity (called before transfer)
SETUPV:	JMP	SETCMD		; SET command
SPMENV:	DS	3		; Not used with MEX
VERSNV:	JMP	SYSVER		; Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		; Send a break
;
; 	The following jump vector provides the overlay with access to special
; 	routines in the main program (retained and supported in the main pro-
; 	gram for MDM overlay compatibility). These should not be modified by
; 	the overlay.
;
; 	Note that for MEX 2.0 compatibility, you should not try to use these
; 	routines, since this table will go away with MEX 2.0 (use the MEX
; 	service call processor instead).
;
ILPRTV:	DS	3		; Replace with MEX function 9
INBUFV:	DS	3		; Replace with MEX function 10
ILCMPV:	DS	3		; Replace with table lookup funct. 247
INMDMV:	DS	3		; Replace with MEX function 255
NXSCRV:	DS	3		; Not supported by MEX (returns w/no action)
TIMERV:	DS	3		; Replace with MEX function 254
;
; 	Clear/screen and clear/end-of-screen. Each routine must use the
; 	full 9 bytes alloted (may be padded with nulls).
;
; 	These routines (and other screen routines that MEX 2.0 will sup-
; 	port) will be accessed through a jump table in 2.0, and will be
; 	located in an area that won't tie the screen functions to the
; 	modem overlay (as the MDM format does).
;
CLREOS:	LXI	D,EOSMSG	; Null: no clear to end of screen
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG	; Clear screen, home cursor
	MVI	C,PRINT
	CALL	MEX
	RET
;
;	END OF FIXED FORMAT AREA 
;
;____________________________________________________________________________
;
;	BEGIN OVERLAY DATA AREA
;	
;	The following data areas are used by the overlay code for various
;	operations MEX calls on it to perform. The ordering is not important
;	except where noted in the comments. 
;
;	Some other data areas are scattered thruout the remainder of the file.
;	These are mostly tables referenced from discrete routines and are thus
;	most conveniently kept in the vicinity of those routines.
;	
;	Sign-on Message
;	You can use this as an "eye-catcher" when debugging or patching
;	this file. Marks the beginning of the overlay data area.
;
SOMESG:
	DB	'Sanyo MBC-1200/1250 computer 300/1200 BAUD Version '
	DB	REV/10+'0','.'
	DB	REV MOD 10+'0',CR,LF
	DB	'$'
;
; 	Strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	0,0,0,0,0,0,'$'	; Clear to end-of-screen (0 for pause)
CLSMSG:	DB	1AH,0,0,0,0,0,'$' ; Clear whole screen (0 for pause)
;
; 	Baud rate table
;
BTABL:	DB	BD110		; The byte called MSPEED is used to 
	DB	BD300		;  index into this table to find the 
	DB	BD450		;   current baud rate. For example, if 
	DB	BD600		;    MSPEED equals 5, then the baud rate
	DB	BD710		;     is 1200, since thatis the fifth entry 
	DB	BD1200		;      PAST the entry at BTABL. 
	DB	BD2400		; 	To reset the baud rate, simply 
	DB	BD4800		; 	 MSPEED to the offset of the desired
	DB	BD9600		; 	  baud and calling the SBAUD routine 
	DB	BD19K		; 	   suffices.
;
;	8251 mode bits, saved by bit group
;	The current values of the following bytes are or'ed together
;	to form an 8251 mode word and output to the chip in the MODESET
;	routine. Each byte represents certain bit positions in the mode 
;	word, and no attempt at error checking is made in the MODESET
;	routine. The CLKMOD byte represents the baud rate used (300 or 1200)
;	and is only updated thru use of the SBAUD routine, which chooses
;	from the baud rate table above based on the MSPEED byte. It will 
;	not update the baud if the value is bad. 
;
CLKMOD:	DB	X16		; Mode bits: CLOCK DIVISOR (X16=1200 baud)
CHRLEN:	DB	CHRLEN8		; Mode bits: CHARACTER LENGTH
PARITY:	DB	PTYDSBL		; Mode bits: PARITY
STOP:	DB	STPB1		; Mode bits: STOP BITS
;
;	END OVERLAY DATA AREA
;
;____________________________________________________________________________
;
;	BEGIN EXECUTABLE CODE
;
;	Carrier Show and Carrier Detect deleted.
;	No carrier detect capability.
;
CARRSH:	
CARRCK:	
;
; 	Exit routine --  called just before MEX exits to CP/M
;
CPMEXT:
;
;	DUMMY routine for calls that are not implemented.
;
DUMMY:	RET			; We don't need one
;____________________________________________________________________________
;
; 	Modem initialization.
;
NITMOD:	LDA	MSPEED		; Get current baud rate setting 
	CALL	SBAUD		; Set the baudrate
	RET
;
; 	Send-break routine
;
SBREAK:	MVI	A,SBRK+CHIPSET	; Break control byte
	OUT	MODCTL		; Output
	MVI	B,2		; Wait 200 ms
	MVI	C,TIMER		; MEX fcn code
	CALL	MEX		; Time out
	MVI	A,CHIPSET	; Reset break
	OUT	MODCTL		; Output
	RET			; Return to caller
;
; 	Set Baud Rate
;
; 	New baud-rate code in A.
; 	NOTE: this routine (ie, the one vectored through NEWBDV) should
; 	update MSPEED with the passed code, but ONLY if that rate is
; 	supported by the hardware.
;
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
;
;	The only baud rates supported are 300 and 1200.
;
SBAUD:	PUSH	H		; Don't alter anybody
	PUSH	D
	PUSH	B
	MOV	C,A		; Save baud rate code  
	MVI	B,0
	LXI	H,BTABL		; Get baudrate value
	DAD	B		; HL now contains address of baudrate number
	MOV	A,M		; A  now contains baudrate n
	CPI	NA		; See if baud rate valid
	STC			; Set for not valid
	JZ	NOTVAL		; Not valid: bypass setting it
;	
;	Baud rate ok so set it
;
	STA	CLKMOD		; Put new baud code in clock rate byte
	MOV	A,C		; Get baud rate code  (for MEX)
	STA	MSPEED		; Save baud rate code (for MEX)
	CALL	MODESET		; Call routine to tell 8251 about it
	XRA	A		; Clear carry flag
;
;	Return point for valid and not valid calls
;
NOTVAL:	POP	B		; Restore registers and return
	POP	D
	POP	H
	RET
;
;	This code sets the 8251 chip mode from the mode bytes.
;	Multiple bytes, each representing certain bit positions 
;	of the mode word are or'ed together here. MODESET is 
;	intended to be called from setup routines.
;
;	The accumulator is trashed, flags are arbitrary.
;
MODESET:
	PUSH	H		; HL is all we save here... 
	MVI	A,RESET1	; Insure out-of-mode state
	OUT	MODCTL		; Modem control port
	MVI	A,RESET1	; Do it again
	OUT	MODCTL		; For slight extra delay
	MVI	A,RESET2	; Then reset the USART 
	OUT	MODCTL		; Modem control port
	XTHL			; Delay -- must be in pairs
	XTHL			; Restore the glory that once was...
	LDA	CLKMOD		; Get 8251 clock mode
	LXI	H,CHRLEN	; Point at character length byte
	ORA	M		; Set bits
	LXI	H,PARITY	; Point at parity setting byte 
	ORA	M		; Set bits
	LXI	H,STOP		; Point at stop bit setting byte
	ORA	M		; Set bits
	OUT	MODCTL		; 8251 Mode now set
	MVI	A,CHIPSET	; Set chip for I/O
	OUT	MODCTL		; 8251 Command now set
	IN	MODDAT		; Clear data port
	POP	H		; Get it back...
	RET			; Return to caller
; 
; 	Sign-on message
; 
SYSVER:	
	CALL	CRLF		; Skip a line
	LXI	D,SOMESG	; Point to signon message
	MVI	C,PRINT		; MEX print string
	CALL	MEX		; Print message on term
	CALL	CRLF		; Skip a line
	CALL	SETSH2		; Show settings w/o scrn clr
;
; 	Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		; Fall into TYPE
;
; 	type char in A on console
;
TYPE:	PUSH	H		; Save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		; Align output character
	MVI	C,CONOUT	; Print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;____________________________________________________________________________
;
;	SET COMMAND NOTES (as implemented by this overlay):
;
;	SET STOPBIT <1/1.5/2>
;	SET CHARLEN <5/6/7/8>
;	SET BAUD    <1200/300>
;	SET PARITY  <EVEN/ODD/NONE>
;
;	Optional:
;	SET DIAL    <TOUCH/PULSE>
;____________________________________________________________________________
;
; 	SET COMMAND processor and data - the rest of this overlay is 
;	devoted to the implementation of the command and its options.
;	
; 	Control is passed here after MEX parses a SET command.
;
SETCMD:	CALL	CRLF		; For better readability
	MVI	C,SBLANK	; Any arguments?
	CALL	MEX
	JC	SETSHO		; If not, go print out values
	LXI	D,CMDTBL	; Parse command
	CALL	TSRCH		; From table
	PUSH	H		; Any address on stack
	RNC			; If we have one, execute it
	POP	H		; Nope, fix stack
SETERR:	LXI	D,SETEMS	; Print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; 	SET command table ... note that tables are constructed of command-
; 	name (terminated by high bit=1) followed by word-data-value returned
; 	in HL by MEX service processor LOOKUP.  Table must be terminated by
; 	a binary zero.
;
; 	Note that LOOKUP attempts to find the next item in the input stream
; 	in the table passed to it in HL ... if found, the table data item is
; 	returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H		; SET ?
	DW	STHELP
	DB	'BAU','D'+80H	; SET BAUD <300/1200>
	DW	STBAUD
	DB	'PARIT','Y'+80H	; SET PARITY <EVEN/ODD/NONE>
	DW	STPAR
	DB	'CHARLE','N'+80H ; SET CHARLEN <5/6/7/8>		
	DW	SETCLN
	DB	'STOPBI','T'+80H ; SET STOPBIT <1/1.5/2>
	DW	SETSB
;
	 IF	DIALSET		; (OPTIONAL)
	DB	'DIA','L'+80H	; SET DIAL <TOUCH/PULSE>
	DW	STDIAL
	 ENDIF
;

	DB	0		; <<=== table terminator
;
; 	SET <no-args>: print current statistics
;
SETSHO:	
	CALL	CLS		; Clear screen
SETSH2:
	LXI	H,SHOTBL	; Get table of SHOW subroutines
SETSLP:	MOV	E,M		; Get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		; End of table?
	ORA	E
	JZ	SETSHX		; Exit if so
	PUSH	H		; Save table pointer
	XCHG			; Adrs to HL
	CALL	GOHL		; Do it
	CALL	CRLF		; Print newline
	MVI	C,CHEKCC	; Check for console abort
	CALL	MEX
	POP	H		; It's done
	JNZ	SETSLP		; Continue if no abort
SETSHX:	CALL	CRLF		; Skip a line
	RET
;
GOHL:	PCHL
;
; 	table of SHOW subroutines
; 
SHOTBL:	DW	BDSHOW		; BAUD
	DW	PSHOW		; PARITY
	DW	CLSHOW		; CHARACTER LENGTH
	DW	SBSHOW		; STOP BIT(S)
;
	 IF	DIALSET		; (OPTIONAL)
	DW	DISHOW		; DIAL
	 ENDIF
;
	DW	0		; <<== table terminator
;
; 	SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; 	The help message
;
HLPMSG:	DB	CR,LF,'SET commands:',CR,LF
;
	DB	CR,LF,'SET BAUD 300 <or> 1200'
;
	DB	CR,LF,'SET PARITY EVEN <or> ODD <or> NONE'
;
	DB	CR,LF,'SET STOPBIT 1 <or> 1.5 <or> 2'
;
	DB	CR,LF,'SET CHARLEN 5 <or> 6 <or> 7 <or> 8'
; 
	 IF	DIALSET		; (OPTIONAL)
	DB	CR,LF,'SET DIAL <TOUCH> or <PULSE>'
	 ENDIF
;
	DB	CR,LF,LF,'$'
;
; 	SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	; Function code
	CALL	MEX		; Let MEX look up code
	JC	SETERR		; Invalid code
	CALL	SBAUD		; No, try to set it
	JC	SETERR		; Not-supported code
	JMP	SETSHO		; Review parameters
;
BDSHOW:	CALL	ILPRT		; Display baud
	DB	'Baud rate: ',0
	LDA	MSPEED
	MVI	C,PRBAUD	; Use MEX routine
	CALL	MEX
	RET
;
; 	SET PARITY processor
;	NOTE:	Since zero is one of the valid possible values for 
;		the parity bytes and the table scanning routines use
;		that as an end of table error marker, the bits of the
;		actual parity byte are "flipped" using an XOR previous
;		to searching the table for it, then flipped back before 
;		updating the parity byte. Thus the values in the table
;		are one's complements or "negative logic" relative to 
;		the byte saved as parity and used to set the 8251 chip.
;
STPAR:	LXI	D,PARTBL	; Lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	MOV	A,L		; Get parity code
	XRI	11111111B	; Flip the bits ... see note above
	STA	PARITY		; Store it 
	CALL	MODESET		; Set parity
	JMP	SETSHO		; Review parameters
;
PSHOW:	CALL	ILPRT		; Show parity
	DB	'Parity:    ',0
	LXI	H,PARFND	; Find proper message
	LDA	PARITY		; Get parity value
	XRI	11111111B	; Flip the bits ... see note above
	MOV	B,A		; Second copy for SHWSCN routine
	JMP	SHWSCN		; Goto show value scan routine
;
; 	PARITY argument table
;	Table format: starting at PARFND, each entry has the one byte
;		code followed by the name string terminating with a 
;		high bit set in the last character, followed by the
;		one byte code again. The last entry is followed by zero.
;	This odd format allows the table to be used for multiple purposes.
;
;	NOTE:	Since zero is one of the valid possible values for 
;		the parity bytes and the table scanning routines use
;		that as an end of table error marker, the bits of the
;		actual parity byte are "flipped" using an XOR previous
;		to searching the table for it, then flipped back before 
;		updating the parity byte. Thus the values in the table
;		are one's complements or "negative logic" relative to 
;		the byte saved as parity and used to set the 8251 chip.
;
TPEVEN	EQU	ALLBITS-(PTYEVEN+PTYENBL) ; EVEN PARITY ENABLED (INVERSE BITS)
TPODD	EQU	ALLBITS-(PTYODD+PTYENBL) ; ODD  PARITY ENABLED (INVERSE BITS)
TPNONE	EQU	ALLBITS-(PTYDSBL) ; PARITY DISABLED     (INVERSE BITS)
;
PARFND:	DB	TPEVEN
PARTBL:	DB	'EVE','N'+80H	; Even parity
	DB	TPEVEN,TPODD
	DB	'OD','D'+80H	; Odd  parity
	DB	TPODD,TPNONE
	DB	'NON','E'+80H	; No   parity
	DB	TPNONE,0
;
	DB	0		; <<== table terminator
;
; 	SET STOPBIT processor
;
SETSB:	LXI	D,SBTBL		; Lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	MOV	A,L		; Get stopbit code
	STA	STOP		; Store it 
	CALL	MODESET		; Set stopbit
	JMP	SETSHO		; Review parameters
;
SBSHOW:	CALL	ILPRT		; Show stopbit
	DB	'Stop bits: ',0
	LXI	H,SBFIND	; Find proper message
	LDA	STOP		; Get stopbit value
	MOV	B,A		; Second copy for SHWSCN routine
	JMP	SHWSCN		; Goto show value scan routine
;
; 	STOPBIT argument table
; 	Format of the table is identical to that of parity table
;	except that no "negative logic" is necessary or used.
;
SBFIND:	DB	STPB1
SBTBL:	DB	'1'+80H		; One stop bit
	DB	STPB1,STPB1H
	DB	'1.','5'+80H	; One and a half stop bits
	DB	STPB1H,STPB2
	DB	'2'+80H		; Two stop bits
	DB	STPB2,0
;
	DB	0		; <<== table terminator
;
; 	SET CHARLEN processor
;	NOTE:	Since zero is one of the valid possible values for 
;		the charlen bytes and the table scanning routines use
;		that as an end of table error marker, the bits of the
;		actual charlen byte are "flipped" using an XOR previous
;		to searching the table for it, then flipped back before 
;		updating the charlen byte. Thus the values in the table
;		are one's complements or "negative logic" relative to 
;		the byte saved as charlen and used to set the 8251 chip.
;
SETCLN:	LXI	D,CLNTBL	; Lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; If not found, error
	MOV	A,L		; Get charlen code
	XRI	11111111B	; Flip the bits ... see note above
	STA	CHRLEN		; Store it 
	CALL	MODESET		; Set stopbit
	JMP	SETSHO		; Review parameters
;
CLSHOW:	CALL	ILPRT		; Show charlen
	DB	'Char len:  ',0
	LXI	H,CLFIND	; Find proper message
	LDA	CHRLEN		; Get charlen value
	XRI	11111111B	; Flip the bits ... see note above
	MOV	B,A		; Second copy for SHWSCN routine
	JMP	SHWSCN		; Goto show value scan routine
;
; 	CHARLEN argument table
; 	Format of the table is identical to that of parity table
;
;	NOTE:	Since zero is one of the valid possible values for 
;		the charlen bytes and the table scanning routines use
;		that as an end of table error marker, the bits of the
;		actual charlen byte are "flipped" using an XOR previous
;		to searching the table for it, then flipped back before 
;		updating the charlen byte. Thus the values in the table
;		are one's complements or "negative logic" relative to 
;		the byte saved as charlen and used to set the 8251 chip.
;
TCLEN5	EQU	ALLBITS-(CHRLEN5) ; CHARACTER LENGTH = 5 (INVERSE BITS)
TCLEN6	EQU	ALLBITS-(CHRLEN6) ; CHARACTER LENGTH = 6 (INVERSE BITS)
TCLEN7	EQU	ALLBITS-(CHRLEN7) ; CHARACTER LENGTH = 7 (INVERSE BITS)
TCLEN8	EQU	ALLBITS-(CHRLEN8) ; CHARACTER LENGTH = 8 (INVERSE BITS)
;
CLFIND:	DB	TCLEN5
CLNTBL:	DB	'5'+80H		; 5 bits
	DB	TCLEN5,TCLEN6
	DB	'6'+80H		; 6 bits
	DB	TCLEN6,TCLEN7
	DB	'7'+80H		; 7 bits
	DB	TCLEN7,TCLEN8
	DB	'8'+80H		; 8 bits
	DB	TCLEN8,0
;
	DB	0		; <<== table terminator
;
	 IF	DIALSET
;
; 	SET DIAL processor
;
STDIAL:	LXI	D,DIATBL	; lookup next input item in table
	CALL	TSRCH		; search for parameter value
	JC	SETERR		; if not found, error
	STA	TPULSE		; store the dial command
	JMP	SETSHO		; review parameters
;
DISHOW:	CALL	ILPRT		; show dial mode
	DB	'Dial:      ',0
	LDA	TPULSE		; get dial byte
	CPI	'T'
	JZ	TTONE		; touch tone 
;
PDIAL:	CALL	ILPRT
	DB	'Pulse',0
	RET
;
TTONE:	CALL	ILPRT
	DB	'Touch Tone',0
	RET
;
; 	DIAL argument table
;
DIATBL:	DB	'TOUC','H'+80H	; touch tone
	DB	'T',0
	DB	'PULS','E'+80H	; pulse dial
	DB	'P',0
	DB	0		; <<=== table terminator
	 ENDIF
;
;	Show set value scan routine
;
SHWSCN:	MOV	A,M		; See if parity value matches
	ORA	A		; First see if zero
	JZ	SETERR		; Should never get here
	CMP	B		; Match?
	INX	H		; Point to first letter of message
	JZ	CDISP		; Matches, type message
FNDNXT:	MOV	A,M
	ORA	A		; See if end of last message
	INX	H
	JP	FNDNXT		; Not finished
	INX	H		; Increment past parity byte
	JMP	SHWSCN
;
;  	Print message ending with 80H bit set
;
CDISP:	MOV	A,M		; Get character to print
	INX	H		; Point to next character
	PUSH	PSW		; Save 80H bit
	ANI	7FH		; Strip 80H bit just in case
	CALL	TYPE
	POP	PSW
	ORA	A
;------	JP	M,CRLF		; Finished
	RM			; Finished
	JMP	CDISP
;
; 	Compare next input-stream item in table @DE; CY=1
; 	if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	; Get function code
	JMP	MEX		; Pass to MEX processor
;
; 	Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		; Get function code
	JMP	MEX		; Go do it
;
; 	End of Sanyo MBC-1200/1250 MEX modem overlay
;
;____________________________________________________________________________
;
	END

