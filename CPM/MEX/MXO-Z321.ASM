; MEX ZEUS 3 OVERLAY VERSION 2.1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  MXO-Z321.ASM   This is an OSM Zeus 3 overlay for Modem Executive.
;			(author: Philp LaViscount of RAM (404/768-6136))
;	
;	Updated to add Break key simulation in terminal mode.
;		It should be noted that the same program should
;		function perfectly well for OSM Zeus 4 and 3X hardware,
;		with the exception that the clocks are all set by
;		hardware (no CTC's) hence Baud rates cannot be altered
;		dynamically.  [8/2/84 by PLV]
;
;	This second version includes some cleanups and a working interface
;		to MXO-SM11.ASM by R.G. Fowler (including Mark Pulver's
;		fix for extended numeric return codes). [8/1/84 by PLV]
;		Note: for some unknown reason, module only worked when
;		created in 2 steps-
;		MLOAD21 Z3MEX2.COM=MEX10.COM,MXO-Z320.HEX
;		MLOAD21 Z3MEX20.COM=Z3MEX2.COM,MXO-SM12.HEX
;		Also note that the values assembled in will need to be
;		changed for specific situations (e.g. user who wants
;		to allow control chars for terminal emulation), in 
;		order to prevent confusion arising from lost ini.mex
;		files or lost clones.....
;
;	This is the first version of an overlay for the recently introduced
;		MEX program (version 1.0) designed for the Zeus-3.  Since
;		it is derived entirely from the 2.0 version of the Kaypro 2
;		overlay by B. Grier, the entire comments of the KP20
;		version are preserved here. The modifications at this point 
;		consist solely of changes to port addresses and command 
;		strings which are device specific. [6/4/84 by PLV]
;
;     	This is an almost complete rewrite of the Kaypro overlay. Modem 
;	Executive provides more overlay space, so I have taken the opportunity
;	to make the code more modular and more structured.  This should
;       make future maintaince easier.  I despised digging through the old
;	"spaghetti" code to make changes or enhancements.
;
;	Several structural changes have been made.  First, I implemented
;	PDISC, which permits disconneting from a modem by dropping DTR.
;	Of course, you have to have a modem that responds to DTR for this
;	to be of much use, but if you do, it is very much faster than 
;       waiting for the "+++", etc., needed to close out a Hayes
;	Smartmodem. See the PDISC module below, and the Smartmodem overlay
;	for instructions on how to implement.
;
;	Second, MSPEED is now the total control point for modem	speed. 
;	In the old version, contrary to some expectations, the value of
;	MSPEED set in the EQU's would not come up on intitalization.
;	Now it should. In general, to change baudrate now, just change
;	MSPEED and call NITMOD. Or use PBAUD.
;
;	Third, I have put all baudrate/sio initialization constants
;	into a separate data table. This makes them eaiser to find
;	and modify, as well as lets initialization go smoother (a
;	loop is used). Having the separate i/o data table will also
;	make it easier to add fetaures such as the capability to change
;	bits/character or parity conditions.  Your module need only
;	change the values in the table and call NITMOD.
;
;	Fourth, I have brought the baudrate/sio initialization into
;	agreement with Kaypro standards which specify the sio to be 
;	disabled via 'channel reset' while baudrate is changed.  I have
;	never had any problem with the old code, but since it is being
;	redone, why not do it right?
;
;						Brown Grier
;						312/690-0359
;						5/30/84
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
;
; Port Definitions
;
;PORT	EQU	004H		;Kaypro base port (data or status)[plv:v1.0]
;
;	Zeus-3 uses the user serial printer port for modem connect[plv:v1.0]
;
;	All following values taken from MUSE System Manager Reference Manual
;		(OSM Doc: 10002, copyright 1983) pp. 2-19,2-20; values
;		presumed valid for MUSE v4.01 and v4.50           [plv:v1.0]
MODCT1	EQU	03H		;modem control port               [plv:v1.0]
MODDAT	EQU	02H		;modem data port                  [plv:v1.0]
MODCT2	EQU	MODCT1		;modem status port                [plv:v1.0]
BAUDRP	EQU	61H   		;modem baud rate port             [plv:v1.0]
;
; Bit definitions
;
MDRCVB	EQU	01H		;modem receive bit      
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
;
; KAYPRO bits per second (baudrate) factors
;
BAUD50	EQU	00H		;50 bps
BAUD75	EQU	01H		;75 bps
BAUD11	EQU	02H		;110 bps
BAUD13	EQU	03H		;134.5 bps  (used with some IBM printers)
BAUD15	EQU	04H		;150 bps
BAUD30	EQU	05H		;300 bps
BAUD60	EQU	06H		;600 bps
BAUD12	EQU	07H		;1200 bps
BAUD18	EQU	08H		;1800 bps
BAUD20	EQU	09H		;2000 bps
BAUD24	EQU	0AH		;2400 bps
BAUD36	EQU	0BH		;3600 bps
BAUD48	EQU	0CH		;4800 bps
BAUD72	EQU	0DH		;7200 bps
BAUD96	EQU	0EH		;9600 bps
BAUD19	EQU	0FH		;19,200 bps
;
;
;SIO register equates
;
SIOW0 	EQU	00H		;sio write register 0
SIOW1 	EQU	01H		;sio write register 1
SIOW2 	EQU	02H		;sio write register 2
SIOW3 	EQU	03H		;sio write register 3
SIOW4 	EQU	04H		;sio write register 4
SIOW5 	EQU	05H		;sio write register 5
SIOR0 	EQU	00H		;sio read register 0
SIOR1 	EQU	01H		;sio read register 1
SIOR2 	EQU	02H		;sio read register 2
;
;
MEX  	EQU     0D00H		;addresó oæ thå servicå processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
;
	ORG	TPA		;we begin
;
;
	DS	3		;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	NO 		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz. [plv:v1.0]
MSPEED:	DB	5		;sets speed for sending a file
				;1=300, 5=1200, 8=9600 
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	NO;YES		;yes=user-defined SET command	[plv:v1.0]
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	YES	 	;yes=make .BAK file		[plv:v1.0]
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP
LOCNXT:	DB	NO		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	DB	YES;NO		;yes=allow testing of XOFF from remote [plv:v1.0]
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of XOFF testing
IGNCTL:	DB	YES;NO		;yes=do not send control characters [plv:v1.0]
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = Send a 500 ms. break tone [plv:v2.1]
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
; Equates used only by PMMI routines grouped together here.
;
PRATE:	DB	0		;not used for Kaypro
	DB	0		;not used
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:	MVI	A,10H		;reset interrupts
	OUT	MODCT1
	IN	MODCT1		;in modem control port
	RET
	DB	0,0,0        	;spares if needed 
;
OTDATA:	OUT	MODDAT		;out modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed 
;
INPORT:	IN	MODDAT		;in modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed 
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
;
; Unused area: was once used for special PMMI functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.
;
	DS	12
;
; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.  Thus, if your modem can't dial, change the
; JMP PDIAL at DIALV to DS 3, and MEX will print a "not-implemented"
; diagnostic for any commands that require dialing.
;
; DIALV  dials the digit in A. See the comments at PDIAL for specs.
;
; DISCV  disconnects the modem
;
; GOODBV is called just before MEX exits to CP/M.  If your overlay
;        requires some exit cleanup, do it here.
;
; INMODV is called when MEX starts up; use INMODV to initialize the modem.
;
; NEWBDV is used for phone-number baud rates and is called with a baud-rate
;        code in the A register, value as follows:
;
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
;
;        If your overlay supports the passed baud rate, it should store the
;	 value passed in A at MSPEED (107H), and set the requested rate. If
;	 the value passed is not supported, you should simply return (with-
;	 out modifying MSPEED) -or- optionally request a baud-rate from the
;	 user interactively.
;
; NOPARV is called at the end of each file transfer; your overlay may simply
;	 return here, or you may want to restore parity if you set no-parity
;	 in the following vector (this is the case with the PMMI overlay).
;	 
; PARITV is called at the start of each file transfer; your overlay may simply
;	 return here, or you may want to enable parity detection (this is the
;	 case with the PMMI overlay).
;
; SETUPV is the user-defined command ... to use this routine to build your own
;	 MEX command, set the variable SETFL (117H) non-zero, and add your SET
;	 code.  You can use the routine presented in the PMMI overlay as a 
;	 guide for parsing, table lookup, etc.
;
; SPMENU is provided only for MDM compatibility, and is not used by MEX 1.0 for
;	 any purpose (it will be gone in MEX 2).
;
; VERSNV is called immediately after MEX prints its sign-on message at cold
;	 startup -- use this to identify your overlay in the sign-on message
;	 (include overlay version number in the line).
; BREAKV is provided for sending a BREAK (<ESC>-B in terminal mode).  If your
;	 modem doesn't support BREAK, or you don't care to code a BREAK rou-
;	 tine, you may simply execute a RET instruction.
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	DS      3		;dial digit in A (see info at PDIAL)
DISCV:	DS	3	;JMP	PDISC	;disconnect the modem 	[plv:v1.0]
;			Handled by Smartmodem overlay...[plv:v2.0]
GOODBV:	RET  ! NOP ! NOP	;called before exit to CP/M
INMODV:	JMP 	NITMOD	;initialization. Called at cold-start [plv:v1.0]
NEWBDV:	DS	3	;JMP	PBAUD		;set baud rate  [plv:v1.0]
NOPARV:	DS      3		;set modem for no-parity
PARITV:	DS      3 		;set modem parity
SETUPV:	RET  ! NOP ! NOP	;JMP SETCMD ;SET cmd: jump to a RET if you don't write SET  [plv:v1.0]
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
;BREAKV:	DS	3	;JMP	PBREAK	;send a break  [plv:v1.0]
BREAKV:	JMP	PBREAK		;send a break returned [plv:v2.1]
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;
CLS:	LXI	D,CLSMSG		;null unless patched
	MVI	C,PRINT
	CALL	MEX
	RET
;
;------------------------------------------------------------
;
;	*** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
;	*** START OF PROGRAM MODULES ***
;
;------------------------------------------------------------
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PBREAK   This module sends a 500 ms break signal. [plv:v2.1]
;
; MODULES CALLED:  MEX SERVICE PROCESSOR
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PBREAK:	MVI     A,SIOW5			;address sio register 5
	OUT	MODCT1
	LDA	REG5			;get current status
	ORI	00010000B		;set break bit "on"
	OUT	MODCT1			;start break
;
	MVI	B,5			;500 ms delay [plv:v2.1]
	MVI	C,TIMER	
	CALL	MEX
;
	MVI	A,SIOW5			;address sio register 5
	OUT	MODCT1
	LDA	REG5			;get current status
	OUT	MODCT1			;end break
;
	RET	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PDISC  This module disconnects a modem by dropping DTR. 
;
;  MODULES CALLED:  MEX SERVICE PROCESSOR
;
;     NOTICE   For this routine to be useful you must:
;		1.  Have a modem capable of sensing DTR and have this
;                   feature enabled. For example, a Hayes Smartmodem
;		    with Switch 1 up.
;		2.  Set the parameter DISC in the Smartmodem overlay
;		    to FALSE.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PDISC:	MVI	A,SIOW5			;address sio register 5
	OUT 	MODCT1
	LDA	REG5			;get current status
	ANI	01111111B		;set DTR bit "off"
	OUT	MODCT1			;turn DTR off
;
	MVI	B,2			;200 ms delay
	MVI	C,TIMER
	CALL	MEX
;
	MVI	A,SIOW5 		;address sio register 5
	OUT	MODCT1
	LDA	REG5			;get current status
	OUT	MODCT1			;turn DTR on
;
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  NITMOD  This module reads MSPEED to determine baudrate, puts the
;          corresponding Kaypro bps factor in the initialization table,
;          and calls SETSIO to set baudrate and initialize the sio.
;
;  MODULES CALLED:  SETSIO
;
;  NOTE:   No error checking is done for illegal values of MSPEED.
;	   Validation is done in PBAUD and SETCMD.  If you put an
;	   unrecognized value in the MSPEED EQU, the default is
;	   1200 bps. Currently regognized values are 1, 5, and 8
;	   (300, 1200, and 9600 bps, respectively).
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
NITMOD:	LDA	MSPEED		;get current speed code
;
;--> following code (MSPEED value STA) commented out for V1.0) [plv:v1.0]
;	CPI	01H		;current speed code 300 bps?
;	JNZ	N001		;no, check next code
;	MVI	A,BAUD30	;yes, get corresponding Kaypro bps factor
;	STA	BRATE		;save factor in current status table
;	JMP	END01
;
;N001:	CPI	05H		;1200 bps?
;	JNZ	N002		;no, check next code
;	MVI	A,BAUD12	;yes, get Kaypro bps factor
;	STA	BRATE		;make it current
;	JMP	END01
;
;N002:	CPI	08H		;9600 bps?
;	JNZ	N003		;no, check next code
;	MVI	A,BAUD96	;yes, get Kaypro bps factor
;	STA	BRATE		;make it current
;	JMP	END01
;
;N003:	DS	0		;dummy place holder
;
END01:	CALL	SETSIO		;initialize bps and sio
;
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  SETSIO  This module initializes the baudrate and sio.
;
;  TABLES USED:  INITAB
;          
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
SETSIO:	LXI	H,INITAB		;get addr of init table
	MOV	B,M			;get # pairs to send
;
IOLP:	INX	H			;address next byte in table
	MOV	C,M			;port to sent to
	INX	H			;address next byte in table
	MOV	A,M			;value to sent to that port
	DB	0EDH,079H		;hex for  OUT    (C),A
	DCR	B			;decrement # pairs
	JNZ	IOLP
;
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PBAUD  This module accepts an MSPEED type bps code, and if legitimate,
;         implements the new baudrate. If the code is not a recognized
;         value, no action is taken.
;
;  ENTRY CONDITIONS:  An MSPEED type value in Register A.
;
;  MODULES CALLED:  NITMOD
;
;  NOTE: 1.  Only codes of 1 (300 bps) and 5 (1200 bps) are currently
;            recognized. These correspond to the two most popular modem
;            speeds. 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PBAUD:	CPI	1		;code for 300 bps?
	JNZ	N101		;no, check next possibility
	STA	MSPEED		;yes, save new value
	CALL	NITMOD		;implement new speed
	JMP	ENDPB
;
N101:	CPI	5		;1200 bps?
	JNZ	N102		;no, check next possibility
	STA	MSPEED		;yes, save new value
	CALL	NITMOD		;implement new speed
	JMP	ENDPB
;
N102:	DS	0		;dummy place holder for more values
;
ENDPB:	RET
;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SYSVER  This module displays the Kaypro version message at sign-on.
;
;  MODULES CALLED:  MEX SERVICE PROCESSOR
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
SYSVER:	LXI	D,SYMESG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	This module contains strings to:
;
;	1. clear-to-end-of-screen
;	2. clear-screen
;	3. identify version as for Kaypro
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
EOSMSG:	DB	18H,59H,0,0,'$'	;clear to end-of-screen		;[plv:v2.0]
CLSMSG:	DB	1AH,0,0,0,'$'	;clear whole screen
SYMESG: DB	'Version 2.1 for OSM Zeus-3/4/3x {plv}',CR,LF,'$' ;[plv:v2.1]
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  SETCMD  This module processes, via the SET command, user requests 
;	   relative to baudrate.
;
;	   Syntax is as follows:
;
;		SET		<display current baudrate>
;		SET 300		<sets 300 bps>
;		SET 1200	<sets 1200 bps>
;		SET 9600	<sets 9600 bps>
;		SET XXXX	<any other command yields a list of
;				 above 3 valid baudrates>
;
;  MODULES CALLED:  NITMOD, MEX SERVICE PROCESSOR
;
;  TABLES USED:  CMDTBL
;
;  PSEUDOCODE:
;
; 1.	Invoke MEX command line parser
; 2.	CASE   'no argument in command line'
;	     display current bps value
; 3.	CASE	'valid argument'
;	     save new code in MSPEED
;	     invoke new baudrate
; 4.	CASE 	'invalid argument'
;	     display menu of valid arguemnts
; 5.	RETURN
;	     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;<1>
SETCMD:	MVI	C,SBLANK	;invoke MEX parser for "no argument"
	CALL	MEX
	JNC	N210		;if not, go check for valid argument
;
;<2>
	MVI	C,ILP		;yes, no argument: print current bps
	CALL	MEX
	DB	CR,LF,'Baud rate is now: ',0
	LDA	MSPEED		;set up for call to MEX function that
	MVI	C,PRBAUD	;prints baudrate
	CALL	MEX
	JMP	END200	
;
N210:	LXI	D,CMDTBL	;table of possible commands
	MVI     C,LOOKUP	;see if command in table
	CALL	MEX
	JC	N220		;not in table, go print speeds supported
;
;<3>
	MOV	A,L		;match, get mspeed code returned in L
	STA	MSPEED		;save new speed code
	CALL	NITMOD		;implement new speed
	JMP	END200
;
;<4>
N220:	MVI	C,ILP		; print speeds supported
	CALL	MEX
	DB	CR,LF,'Only 300, 1200, 9600 supported',CR,LF,0
;
;<5>
END200:	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  CMDTBL  This is the command table searched by SETCMD.
;
;	The table is constructed by the command name (terminated by high
;	bit = 1), followed by a word data value returned in HL by the
;	MEX service processor LOOKUP.  Table must be terminated by a
;	binary zero.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
CMDTBL:	DB	'30','0'+80H
	DW	01H				;mspeed code for 300 bps
	DB	'120','0'+80H
	DW	05H				;mspeed code for 1200 bps
	DB	'960','0'+80H
	DW	08H				;mspeed code for 9600 bps
	DB	0
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INITAB   This is the table of io initialization values used by SETSIO.
;
;	The table is in pairs of values. The first byte of each pair
;	is the port #, and the second byte is the value to send to 
;	that port. The first entry in the table is the table length
;	in pairs.
;
;  NOTES: 1. SIO registers should be initialized in the order:
;		0, 2, 4, 3, 5, 1.
;	  2. Baudrate generator initialized with sio disabled via
;            'channel reset' command.
;	  3. (I have violated note 2 without apparent problems, but
;             why not do it by the book?)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
INITAB:	DB	(INIEND-INITAB)/2		;table length in data pairs
;--> the following table commented out and replaced with OSM's [plv:v1.0]
;	recommended values:                                    [plv:v1.0]
;	DB	MODCT1
;	DB	00011000B			;channel reset
;	DB	BAUDRP
;BRATE:	DB	BAUD12				;default to 1200
;	DB	MODCT1
;	DB	SIOW4
;	DB	MODCT1
;REG4:	DB	044H				;x16, 1 stop, no parity
;	DB	MODCT1
;	DB	SIOW3
;	DB	MODCT1
;REG3:	DB	0C1H				;8 bit, rx enable
;	DB	MODCT1
;	DB	SIOW5
;	DB	MODCT1
;REG5:	DB	0EAH				;dtr, 8 bit, tx enable, rts
;
	DB	MODCT1				;user printer port ctl [plv:v1.0]
	DB	18H	;CMD3: Channel Reset
	DB	MODCT1
	DB	14H	;CMD2+PTR4 (Reset External/Status Interrupts+Point WR4
	DB	MODCT1
	DB	4CH	;WR4: No Parity, 2 stop bits, Data Rate*16=Clock Rate
	DB	MODCT1
	DB	03H	;PTR3
	DB	MODCT1
	DB	0E1H	;WR3: Rx 8 bits, Auto Enables, Rx enable
	DB	MODCT1
	DB	05H	;PTR5
	DB	MODCT1
REG5:	DB	0EAH	;WR5: DTR, Tx 8 bits, Tx enable, RTS <label prevents syntax errs>
	DB	MODCT1
	DB	11H	;CMD2+PTR1
	DB	MODCT1
	DB	00H	;WR1: Disable Interrupts
;--> The following added to set default baud rate to 1200     [plv:v1.0]
	DB	BAUDRP	;Printer CTC control port
	DB	45H
	DB	BAUDRP
	DB	68H
;--> End of v1.0 mods (per OSM reqs)              [plv:v1.0]
INIEND:	DS	0				;define end of table
;
;
;--------------------------------------------------------------------
;
;	End of Zeus-3 MEX overlay			[plv:v1.0]
;
;--------------------------------------------------------------------
;
	END
