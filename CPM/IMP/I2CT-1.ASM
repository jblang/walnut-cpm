;***************************************************************************
;*									   *
;*  I2CT-1.ASM - Cromemco TUART overlay for IMP - 12/27/86		   *
;*									   *
;*			    USES TMS 5501 I/O				   *
;*									   *
;*  You will want to look this file over carefully. There are a number of  *
;*  options that you can use to configure the program to suit your taste.  *
;*  This file adapts systems with the Cromemco TUART to IMP.		   *
;*									   *
;*  Edit this file for your preferences then follow the "TO USE:" example  *
;*  shown below.							   *
;*									   *
;*  Many terminals will clear the screen with a CTL-Z.	If yours does, put *
;*  a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first *
;*  normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:  *
;*  (The ESC will automatically be typed with no CTL-character present.)   *
;*  If you don't know what your terminal uses, put a 0 at CLEAR: and IMP   *
;*  will scroll up 24 blank lines to clear the CRT for things like MENU,   *
;*  looking at the function key table, typing CTL-Z in command mode, etc.  *
;*									   *
;*  Use the "SET" command to change the baudrate when desired.	The value  *
;*  at MSPEED controls the baudrate when the program is first called up.   *
;*									   *
;*	TO USE: First edit this file filling in answers for your own	   *
;*		equipment.  Then assemble with ASM.COM or equivalent	   *
;*		assembler.  Then use MLOAD to merge into the main file:    *
;*									   *
;*		MLOAD IMP.COM=IMP.COM,I2CT-x.HEX			   *
;*									   *
;*  =	=   =	=   =	=   =	=   =	=   =	=   =	=   =	=   =	=  *
;*									   *
;*  12/27/87 - Adapted from I2NH-2		- Mark D. Pickerill	   *
;*  10/27/85 - Minor changes			- Irv Hoff		   *
;*  09/03/85 - Written to work with IMP 	- Irv Hoff		   *
;*									   *
;*  =	=   =	=   =	=   =	=   =	=   =	=   =	=   =	=   =	=  *
;*									   *
;***************************************************************************
				;
YES:	EQU	0FFH		; Value for yes
NO:	EQU	0		; Value for no
				;
				; Values shown are for a TMS 5501
				;
PORT:	EQU	30H		; Your base port (data or status)
MDDATP:	EQU	PORT+1		; Modem data port
BDR:	EQU	PORT		; Baud rate port
MDCTL1:	EQU	PORT		; Status port
MSKP:	EQU	PORT+3		; Interrupt mask port
MDRCV:	EQU	40H		; Modem receive ready (dav)
MDSND:	EQU	80H		; Modem send ready bit	(TBE)
MDTXE:	EQU	80H		; Modem send buffer empty, holding buffer empty
MDRSET:	EQU	09H		; Resets uart for additional commands
MASK:	EQU	0		; No interrupts from device
				;
;-----------------------------------------------------------------------
				;
ESC:	EQU	'['-40H		; ^[ = escape
BELL:	EQU	'G'-40H		; ^g = bell character
LF:	EQU	'J'-40H		; ^j = linefeed
NEXTRY:	EQU	'K'-40H		; ^k = try next phone number, abort this try
CR:	EQU	'M'-40H		; ^m = carriage return
CLEARSC:EQU	'Z'-40H		; ^z = clears screen, command mode only
EOFCHAR:EQU	'Z'-40H		; ^z = end of file
				;
;-----------------------------------------------------------------------
				;
	ORG	0100H		; Start of tpa
	DS	3		; Skip the data area below
				;
;***************************************************************************
;*									   *
;*  These routines and equates are at the beginning of the program so	   *
;*  they can be patched by a monitor or overlay file without re-assembling *
;*  the program.							   *
;*									   *
;***************************************************************************
				;
MSPEED:	DB	5		; 0=110 1=300 2=450 3=600 4=710 5=1200		103h
				; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	DB	NO		; Yes=2400 bps highest speed			104h
HS1200:	DB	YES		; Yes=1200 bps highest speed			105h
RACAL:	DB	NO		; Yes=racal-vadic 1200v or 2400v or 2400pa	106h
PROMODM:DB	NO		; Yes=prometheus promodem 1200 bps		107h
RESVD1:	DB	NO		; Reserved for special modems			108h
RESVD2:	DB	NO		; Reserved for special modems			109h
				;
CLEAR:	DB	'E'		; Clear screen character (esc not needed)	10ah
CLOCK:	DB	20		; Clock speed in mhz x10, 25.5 mhz max. 	10bh
				; 20=2 mhh, 37=3.68 mhz, 40=4 mhz, etc.
BYTDLY:	DB	1		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10ch
				; Default time to send character in ter-
				; Minal mode file transfer for slow bbs
CRDLY:	DB	1		; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10dh
				; Default time for extra wait after crlf
				; In terminal mode file transfer
NOFCOL:	DB	5		; Number of directory columns shown		10eh
TCHPUL:	DB	'T'		; T=tone, p=pulse (hayes 2400 modems)		10fh
				;
ADDLFD:	DB	NO		; Yes=add lf after cr to send file in terminal	110h
				; Mode (normally added by remote echo)
CONVRUB:DB	YES		; Yes=convert rub to backspace			111h
CRCDFLT:DB	YES		; Yes=default to crc checking			112h
IGNRCTL:DB	NO		; Yes=ctl-chars above ^m not displayed		113h
				;
EXTCHR:	DB	'['-40H		; Esc = preceeds local control character	114h
EXITCHR:DB	'E'		; Exit character				115h
FILESND:DB	'F'		; Send file when in terminal mode		116h
NOCONCT:DB	'N'		; Disconnect from phone line			117h
LOGCHR:	DB	'L'		; Send logon					118h
LSTCHR:	DB	'P'		; Toggle printer				119h
UNSAVCH:DB	'R'		; Close input text buffer			11ah
SAVECHR:DB	'Y'		; Open input text buffer			11bh
CLEARS:	DB	'Z'		; Clears screen, terminal mode			11ch
SPARE1:	DB	0		; For future development			11dh
NODTR:	DB	YES		; Yes if no dtr and need +++ to disconnect	11eh
				;
;***************************************************************************
;*									   *
;*		Handles in/out ports for data and status		   *
;*									   *
;***************************************************************************
				;
I$MDCTL1:			;
	IN	MDCTL1		; 11fh
	RET			; In modem control port 		121h
	DB	0,0,0,0,0,0,0	; Spares if needed			122h
				;
I$MDTXE:IN	MDCTL1		; (needed for sio or dart register 1	129h
	RET			; 12bh
	DB	0,0,0,0,0,0,0	; 12ch
				;
I$MDDATP:			;
	IN	MDDATP		; 133h
	RET			; 135h
	DB	0,0,0,0,0,0,0	; Spares if needed			136h
				;
O$MDDATP:			;
	OUT	MDDATP		; 13dh
	RET			; Out modem data port			13fh
	DB	0,0,0,0,0,0,0	; Spares if needed			140h
				;
A$MDRCV:ANI	MDRCV		; 147h
	RET			; 149h
				;
C$MDRCV:CPI	MDRCV		; 14ah
	RET			; 14ch
				;
A$MDSND:ANI	MDSND		; 14dh
	RET			; 14fh
				;
C$MDSND:CPI	MDSND		; 150h
	RET			; 152h
				;
A$MDTXE:ANI	MDTXE		; 153h
	RET			; 155h
				;
C$MDTXE:CPI	MDTXE		; 156h
	RET			; 158h
				;
;***************************************************************************
;*									   *
;*  Special exit vector, used by some computers to reset interrupt vectors *
;*									   *
;***************************************************************************
				;
J$EXITVEC:			;
	RET			; 159h
	DB	0,0		; 15ah
				;
				; Jump vectors needed by each overlay
				;
J$GOODBYE:			;
	JMP	GOODBYE		; Disconnects modem by dropping dtr	15ch
J$INITMOD:			;
	JMP	INITMOD		; Initializes modem, autosets baudrate	15fh
J$STUPR:JMP	STUPR		; Set routine to change baudrate	162h
J$SYSVR:JMP	SYSVR		; Signon message			165h
				;
;***************************************************************************
;*									   *
;*  "AT" command strings, can be replaced in individual overlay if needed  *
;*									   *
;***************************************************************************
				;
J$STRNGA: DS	3		; 1200 bps "AT" string			168h
J$STRNG1: DS	3		; 2400 bps "AT" string			16bh
				;
;***************************************************************************
;*									   *
;*  Next fourteen lines should not be changed by user overlay as these go  *
;*  to specific locations in the main program, not in the overlay.	   *
;*									   *
;***************************************************************************
				;
J$CMDSPL:			;
	DS	3		; Allows entry of baudrate on cmd line	16eh
J$CRLF:	DS	3		; Turns up one new line on display	171h
J$DIAL:	DS	3		; Start of dialing routine		174h
J$DSCONT:			;
	DS	3		; Terminates modem use			177h
J$GOLST:DS	3		; Printer routine, needed by apple //e	17ah
J$ILPRT:DS	3		; Prints an inline string, 0 to end	17dh
J$INBUF:DS	3		; Stores a keybd string for comparison	180h
J$INLNCP:			;
	DS	3		; Inline "compare strings" routine	183h
J$INMDM:DS	3		; Max .1 sec wait for modem character	186h
J$RCVRSP:			;
	DS	3		; For 3801 i/o use (tv-803)		189h
J$SNDCHR:			;
	DS	3		; Sends a character to the modem	18ch
J$SNDSTR:			;
	DS	3		; Sends a string to the modem, $ to end 18fh
J$TIMER:DS	3		; 1 second timer (amount in 'b' reg.)	192h
J$NEW1:	DB	0,0,0		; For future needs			195h
J$NEW2:	DB	0,0,0		; For future needs			198h
				;
				; For 2400 bps auto-stepdown units
				;
MANUAL:	DB	0		; For manual selection flag		19bh
				;
J$300:	JMP	OK300		; Sets baudrate to 300 baud		19ch
J$1200:	JMP	OK1200		; Sets baudrate to 1200 bps		19fh
J$2400:	JMP	OK2400		; Sets baudrate to 2400 bps		1a2h
				;
LOGPTR:	DW	LOGON		; Pointer to display logon message	1a5h
SYSVR:	CALL	J$ILPRT		; Display the following line		1a7h
	DB	'Version for Cromemco TUART modem port 30H' ; 1aah
	DB	CR,LF,0		;
	RET			; Go home
				;
;***************************************************************************
;*									   *
;*  NOTE:  You can change the SYSVER message to be longer or shorter.	   *
;*  The end of your last routine should terminate by 0400H (601 bytes	   *
;*  available after start of SYSVER).					   *
;*									   *
;*-------------------------------------------------------------------------*
;*									   *
;*  You can put in a message at this location which can be called up with  *
;*  (special character-L).  You can put in several lines.  End with a 0.   *
;*									   *
;***************************************************************************
				;
LOGON:	DB	'S-100 Forever...' ; Logon message
	DB	CR,LF,0		;
				;
;***************************************************************************
;*									   *
;*	This routine normally sets DTR low for 300 ms to disconnect the    *
;*	phone.	As the TUART does not support DTR, this routine is deleted *
;*	from this overlay and NODTR is set true.  If your TUART has been   *
;*	modified to control DTR (using the spare 1488/1489 sections),	   *
;*	patch the below routine accordingly.				   *
;*									   *
;***************************************************************************
				;
GOODBYE:			;
	MVI	B,'S'-40H	; X-off to stop host if needed
	CALL	J$SNDCHR	;
	MVI	B,1		; Wait a moment to let it react
	CALL	J$TIMER		;
				;
				; Command to set dtr low goes here
				;
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER		;
				;
				; Command to set dtr high goes here
				;
	RET			; Go home
				;
				; Sets tms 5501 to 8 bits, no parity, 1 stop
				;
INITMOD:			;
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300		;
	CPI	5		; 1200 bps
	JZ	OK1200		;
	CPI	6		; 2400 bps
	JZ	OK2400		;
				;
	JMP	STUPR1		; Else ask what is wanted
				;
STUPR:	CALL	J$CMDSPL	; Gives us cmdbuf+6
	JNC	STUPR2		;
				;
STUPR1:	LDA	HS2400		; 2400 baud?
	ORA	A		; Force flags
	JZ	STUPR1A		; No
	CALL	J$ILPRT		;
	DB	'Input Baud Rate (300, 1200, 2400): ',0
	JMP	AROUND		; Around next
STUPR1A:CALL	J$ILPRT		;
	DB	'Input Baud Rate (300, 1200): ',0
AROUND:	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF		;
	CALL	J$CRLF		;
	LXI	D,BAUDBUF+2	;
				;
STUPR2:	CALL	J$INLNCP	; Compare baudbuf+2 with chars. below
	DB	'300',0		; 300 baud
	JNC	OK300		; Go if got match
	CALL	J$INLNCP	;
	DB	'1200',0	; 1200 baud
	JNC	OK1200		;
	CALL	J$INLNCP	;
	DB	'2400',0	; 2400 baud
	JNC	OK2400		;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0 ; Screwup
	JMP	STUPR1		; Try again
				;
OK300:	MVI	A,1		; Mspeed 300 baud value
	MVI	B,BD300		; Get 300 baud parameters in b
	JMP	LOADBD		; Go load them
				;
OK1200:	MVI	A,5		; Mspeed 1200 baud value
	MVI	B,BD1200	; Get 1200 baud parms in b
	JMP	LOADBD		; Go do it
				;
				;
OK2400:	LDA	HS2400		; 2400 baud supported?
	ORA	A		; Force flags
	JZ	OK1200		; No
	MVI	A,6		; Mspeed 2400 baud value
	MVI	B,BD2400	; Get 2400 baud parms in b
	JMP	LOADBD		; Go do it
				;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
				;
;***************************************************************************
;*									   *
;*	INIT:  This routine initializes 1 chanel of the Cromemco TUART.    *
;*	Accepts: Baud rate in B   Returns: Nothing.  Clobbers: Nothing.    *
;*	Calls:	Nothing.						   *
;*									   *
;***************************************************************************
				;
INIT:	PUSH	PSW		; Save acc
	MVI	A,MDRSET	; Get command
	OUT	PORT+2		; Device reset
				;
	MVI	A,MASK		; Get interrupt mask
	OUT	MSKP		; Mask set
				;
	MOV	A,B		; Get baud rate
	OUT	BDR		; Rate set
	POP	PSW		; Restore acc
	RET			; Go home
				;
				; Table of baudrate parameters
				;
BD300:	EQU	84H		; 300 baud
BD1200:	EQU	88H		; 1200 baud
BD2400:	EQU	90H		; 2400 baud
				;
BAUDBUF:DB	10,0,0,0,0,0	;
	DB	0,0,0,0,0,0	;
				;
				; Note: must terminate by 0400h
				;
	END			; End

