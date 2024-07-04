
; M7SY-3.ASM   - SANYO MBC-1000 computer overlay file for MDM722+.  2/17/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; This file adapts the Sanyo MBC-1000 computer to the modem program.
; 
;
;  THIS MODIFICATION MAKES USE OF TIMER 2 ON THE 8253 TIMER IC (IC4)
;  OF THE SERIAL I/O BOARD OF THE SANYO MBC-1000.
;
;  To use this program, the serial I/O board must be modified as follows:
;
;  1. Cut etch from IC18 Pin 1 to JP2 Pin 8.
;  2. Install jumper from IC18 Pin 1 to IC4 Pin 18.
;  3. Install jumper from IC4 Pin 17 to JP2 Pin 8.
;  4. Install jumper from IC4 Pin 16 to IC4 Pin 14.
;  5. Move jumper strap to JP2 Pin 8 for programmable baud rate, other
;     pins (1-7) can still be used for standard baud rate selections.
;  6. Hardware modification is now complete.
;
;  *** THIS VERSION SETS UP THE USART FOR 8 BITS, NO PARITY, 1 STOP BIT ***
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.  Because of tem- 
; perature and component variations, you mave have to alter the timing
; parameters in OK300 and OK1200, plus or minus 1 or 2 numbers, if CRC
; errors occur to frequently during transmission and reception.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 02/17/84 - Renamed  M7SY-3.ASM with improvements on 3 bugs. (1) Use
;            MDM722 or later to eliminate the problems with Contol X when
;            dialing.  (2) Altered the parameter for 300 baud set for 0240h
;            to 0241h to eliminate overwhelming CRC errors during Send.
;            (3) Irv Hoff et al take note.  For some reason, the Sanyo's
;            lock up after a connect.  When the message "hit any key to
;            stop the bell" occurs, there is a subsequent CALL STAT and
;            CALL KEYIN that gets the Sanyo's in a tight loop.  Change
;            the CALL STAT to a JMP RETURN (goes directly to the Terminal
;            mode without waiting for a keystroke) to avoid the problem
;            while waiting for someone more astute than me to fix the bug.
;            I even tried patching in my specific BIOS addresses in a num-   
;            ber of places, figuring the problem was in INITADR--but to no
;            avail.
;
;               Bob Sandel  Canton, MI (leave msg with TCBBS 1-313-846-6127
;                         or Keith Peterson's Royal Oak CP/M 1-313-759-6569 )
;
;
; 02/01/84 - Blended MDM711SN w the top of MDM719.ASM
;          - Made Default Baud Rate 1200; Added back LOADBD to update MSPEED
;	   - ^P back on at LSTTST;changed LOGON back to ^L;set TOUCHPULSE
;	   - back to P=Pulse;added cosmetic remarks;BUFSIZ=XFRSIZ=16K
;          -     Bob Sandel    Canton, MI                             
;
; 08/01/83 - Altered MDM711NE for the Sanyo MBC-1000
;	     computer using an external modem	- Dave Hardy
;
; 07/01/83 - Revised for use with MDM711	- Irv Hoff
; 06/22/83 - Revised for use with MDM710	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
VERSION:  EQU	719	;MDM719 (01/22/84)  --	CP/M MODEM PROGRAM
;
;       COPYRIGHTED 1984 BY IRV HOFF (TO DETER COMMERCIAL USE)
;
; THIS TELEPHONE MODEM PROGRAM USES THE CHRISTENSEN PROTOCOL.  IT HAS
; BOTH CHECKSUM AND 'CRC' CAPABILITY FOR ERROR-DETECTION. IT SUPPORTS
; DIALING AND AUTO-REDIALING FOR THE S-100 PMMI, HAYES SMARTMODEM 300
; AND 1200 AND U.S. ROBOTICS MODEMS.  IT SUPPORTS UP TO TWO ALTERNATE
; DIALING SYSTEMS SUCH AS 'MCI', 'SPRINT', ETC.  IT IS COPYRIGHTED TO
; DETER COMMERCIALISM.  IT MAY BE USED FOR NON-PROFIT PURPOSES OR CAN
; BE ALTERED OR UPDATED IF AGAIN RELEASED TO THE PUBLIC DOMAIN.
;
; OTHER EXTERNAL MODEMS MAY BE READILY USED, ALTHOUGH  MANUAL DIALING
; MAY BE NECESARY.  OVERLAYS HAVE BEEN MADE ALLOWING RAPID ADAPTATION
; TO VARIOUS COMPUTERS.  THE PROGRAM CONFORMS READILY TO NUMEROUS I/O
; DEVICES INCLUDING THE 2661, 8250, 8251, Z80-SIO, ETC.
;
; NOTE:  Current version (722+)is 71 sectors long.  Use this figure with
;	 DDT, etc. to merge the appropriate overlay, regardless of what
;	 the overlay may call for (such as 66 sectors for overlays made
;	 during MDM712 era or 69 sectors during the MDM 719 era. )  
;
;NOTE:   M7NM-6.ASM (or later if applicable) must be used with
;	 this version.  That has the 'SAVSIZ' byte just prior
;	 to the 'NUMBLIB:' phone number library.
;
;***********************************************************************
; If you improve or modify this program please attempt to upload to TCBBS
; Dearborn, MI (313) 846-6127.  If there is insufficient disk space,
; leave a message on MINICBBS there.
;
;
; 02/01/84  *******   WARNING Some Bugs remain TO USE ANCHOR XII  *******
;	    Still having trouble with CAL (lockup after connect); Can receive
;           at 300 & 1200 but can only send at 1200 baud.  Control X does
;           does not really terminate dial.  ATDP, manual dial, works fine!!
;           If you work it out (leave msg w TCBBS 1-313-846-6127) Bob Sandel
;
; 01/22/84  Fixed Irv's error in GETACK routine which prevented the
;  MDM719   robust improvement (added by Bob Plouffe) from working.
;	    Changed ACKNAK to NO so default will require valid NAK
;	    rather than non-ACK.  This is part of the robust improvements,
;	    NOT because of any special ArpaNet requirement.  Changed
;	    SHOWHEX to true for distribution version so users would have
;	    HEX and DECIMAL reporting while transferring files (most users
;	    have told me they prefer to see both).  Changed PMMI dialing
;	    pulse default to 10pps which most exchanges will accept.
;	    (This can be set to other pulse rates in the user overlay).
;				- Keith Petersen, W8SDZ
;
;***********************************************************************
;
;   GENERAL INTEREST:  When transferring files modem-to-modem, the batch
;   mode is extremely useful.  It allows automatic transmission of nu-
;   merous files while the operator at the receiving end does virtually
;   nothing.  It can be used for single files or with wildcards.  With
;   normal single program transfer, the receiving end switches from CRC
;   to checksum in one minute and times out completely in 100 seconds.
;   (In batch mode it times out in 3 minutes for receive.)  This offers
;   ample opportunity to transfer programs between individuals.
;
;***********************************************************************
;
; 01/21/84  NUMBLIB now automatically starts on even page.  0D00H for
;  MDM718   this version.  Made the buffer size for file transfer inde-
;	    pendent from the buffer size for ASCII capture to disk.  It
;	    had been 16k both since MODEM770.  The file transfer size is
;	    now set to 4k for default.  Most systems can easily use 16k
;	    but some very slow ones may need 8k or 4k.  Set via XFRSIZ.
;	    (May be set with DDT by changing byte just prior to start of
;	    NUMLIB, which is 0CFFH in this case.)  Now recognizes single
;	    digit result codes for auto-dial modems.  Added code for the
;	    new Anchor modems which recognize busy signals and can start
;	    a redial immediately.  Thanks for ideas from Wayne Masters,
;	    Ron Fowler, Fred Viles and others.		- Irv Hoff
;
; 07/27/83  Added two alternate dialing routines such as MCI and SPRINT.
;  MDM712   Fixed "disk space remaining" to read correctly with CP/M+.
;					- Irv Hoff
;
; 07/01/83  Changed TERM to allow use of the printer port for modem use.
;  MDM711				- Irv Hoff
;
; 06/22/83  MAJOR CHANGE:  Added autodialing and automatic continuous
;  MDM710		   redialing for Hayes Smartmodem 300 or 1200,
;			   U.S. Robotics in addition to the PMMI modem
;			   for S-100 computers.		- Irv Hoff
;
; 01/01/83  First version.  Can be assembled with ASM.COM.  (Previously
;  MDM700   it was necessary to have the MODEM7.LIB file and use MAC.COM
;	    to assemble the program.)  Selected MDM700 as a new program
;
;***********************************************************************
;
PORT:	  EQU	0A4H	;  Sanyo MBC-1000 Serial Port   
;
MODCTL1:  EQU	PORT+1  ;modem STATUS port
MODCTL2:  EQU	PORT+1  ;CHANGED FOR SANYO CONTROL PORT
MODDATP:  EQU	PORT  	;modem data port
CTIMER:   EQU   0A3H    ;8253 baud rate counter/timer
;
MODRCVB:  EQU	02H	;modem receive bit (DAV)
MODRCVR:  EQU	02H	;modem receive ready
MODSNDB:  EQU	01H	;modem send bit
MODSNDR:  EQU	01H	;modem send ready bit
;
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;		     SPECIAL EQUATES FOR PMMI
;
BAUDRP:	  EQU	PORT+2	;modem baud rate port
BRKMSK:	  EQU	0FBH	;mask to set break
EVPARMSK: EQU	20H	;mask to set even parity
NOPARMSK: EQU	10H	;mask to reset to no parity
ODPARMSK: EQU	0CFH	;mask to set odd parity
;
ANSWMOD:  EQU	1EH	;answer mode
ORIGMOD:  EQU	1DH	;originate mode
WAITCTS:  EQU	150	;number of seconds (x5) to wait for the
			;computer to answer after PMMI auto-dial
			;100=20 sec, 150=30 sec, 255=51 sec.
			;any number 0-255 acceptable
;
;		  (END OF SPECIAL PMMI EQUATES)
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;
YES:	EQU	0FFH
NO:	EQU	0
;
;
BUFSIZ:	EQU	16	;buffer size in Kbytes for ASCII capture to disk
			;(16k is one file extent)
XFRSIZ: EQU	16      ;file transfer buffer in Kbytes.  Do not make
			;any larger than BUFSIZ.  16k works fine on all
			;but very slowest systems
;
BDNMCH:	EQU	75H	;bad name match
ERRLIM:	EQU	10	;maximum allowable consecutive errors
ERRCRC:	EQU	6	;CRC tries, then switches to CHECKSUM
LIBLEN:	EQU	34	;length of each phone library entry
;
SHOWHEX:EQU	YES	;yes, show hex record count - no, do not show
;
RUB:	EQU	7FH	;rub
CRC:	EQU	'C'	;requests 'CRC' instead of 'CKSUM'
ESC:	EQU	'['-40H	;^[ = escape
SOH:	EQU	'A'-40H	;^A = start of header
EOT:	EQU	'D'-40H	;^D = end of text
EXITCHR:EQU	'E'-40H	;^E = exit character
ACK:	EQU	'F'-40H	;^F = acknowledge
OKNMCH:	EQU	'F'-40H	;^F = ok name match
BELL:	EQU	'G'-40H	;^G = bell character
BKSP:	EQU	'H'-40H	;^H = backspace
LF:	EQU	'J'-40H	;^J = linefeed
CR:	EQU	'M'-40H	;^M = carriage return
XON:	EQU	'Q'-40H	;^Q = XON character
XOFF:	EQU	'S'-40H	;^S = XOFF character
NAK:	EQU	'U'-40H	;^U = not acknowledge
CANCEL	EQU	'X'-40H	;^X = cancel send or receive
EOFCHAR:EQU	'Z'-40H	;^Z = end of file
;
;
	ORG	0100H
;
;
        DS      3        ; for JUMP     START  instruction
;
;
; THESE ROUTINES AND EQUATES ARE AT THE BEGINNING OF THE PROGRAM SO
; THEY CAN BE PATCHED BY A MONITOR OR OVERLAY FILE WITHOUT RE-ASSEMBLING
; THE PROGRAM.
;
PMMIMODEM:  DB	NO 	;yes=PMMI modem, no=non-PMMI modem
SMARTMODEM: DB	YES     ;yes=HAYES Smartmodem or Anchor Automation Mark XII
TOUCHPULSE: DB	'P'	;T=touch, P=pulse (Smartmodem-only)
;
CLOCK:	   DB	40	;clock speed x .1, up to 25.5 mhz.
			;2 MHz=20, 3.68 MH=37, 4 MHz=40, etc.
MSPEED:	   DB	5	;sets display time for sending a file
			;0=110	1=300  2=450  3=600  4=710
			;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	   DB	5	;default time to send character in
			;terminal mode file transfer (0-9)
			;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	   DB	5	;end-of-line delay after CRLF in terminal
			;mode file transfer for slow BBS systems
			;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
NOOFCOL:   DB	4	;number of directory columns   was 5
SETUPTST:  DB	YES     ;yes=non-PMMI setup routine
SCRNTEST:  DB	YES	;yes=if home cursor and clear screen
			;routine at CLRSCRN
ACKNAK:	   DB   YES     ;yes=resend a record after any non-ACK
			;no=resend a record after a valid NAK (robust)
BAKUPBYTE: DB	NO	;yes=make .BAK file
CRCDFLT:   DB	YES	;yes=default to CRC checking
			;no=default to Checksum checking
TOGGLECRC: DB	YES	;yes=allow toggling of Checksum to CRC
CONVBKSP:  DB	NO	;yes=convert backspace to rub
TOGGLEBK:  DB	YES 	;yes=allow toggling of bksp to rub
ADDLF:	   DB	NO	;no=no LF after CR to send file in
			;terminal mode (added by remote echo)
TOGGLELF:  DB	YES	;yes=allow toggling of LF after CR
TRANLOGON: DB	YES     ;yes=allow transmission of logon
			;write logon sequence at location LOGON
SAVCCP:	   DB	YES	;yes=do not overwrite CCP
LOCNXTCHR: DB	NO	;yes=local cmd if EXTCHR precedes
			;no=not local cmd if EXTCHR precedes
TOGGLELOC: DB	YES	;yes=allow toggling of LOCNXTCHR
LSTTST:	   DB	YES	;yes=allow toggling of printer on/off
			;in terminal mode. Set to no if using
			;the printer port for the modem
XOFFTST:   DB	YES	;yes=allow testing of XOFF from remote
			;while sending a file in terminal mode
XONWAIT:   DB	NO	;yes=wait for XON after sending CR while
			;transmitting a file in terminal mode	
TOGXOFF:   DB	YES	;yes=allow toggling of XOFF testing
IGNORCTL:  DB	YES     ;yes=do not send control characters
			;above CTL-M to CRT in terminal mode
			;no=send any incoming CTL-char to CRT
EXTRA1:	   DB	0	;for future expansion
EXTRA2:	   DB	0	;for future expansion
BRKCHR:	   DB	'@'-40H	;^@ = Send a 300 ms. break tone
NOCONNCT:  DB	'N'-40H	;^N = Disconnect from phone line
LOGCHR:	   DB	'L'-40H	;^L = Send logon
LSTCHR:	   DB	'P'-40H	;^P = Toggle printer
UNSAVECHR: DB	'R'-40H	;^R = Close input text buffer
TRANCHR:   DB	'T'-40H ;^T = Transmit file to remote
SAVECHR:   DB	'Y'-40H	;^Y = Open input text buffer
EXTCHR:	   DB	'^'-40H	;^^ = Send next character
;
;
; Equates used only by PMMI routines grouped together here.
;
PULSERATE: DB	250	;125=20pps dialing, 250=10pps
CHGBAUD:   DB	'B'-40H	;^B = Used with PMMIMODEM in terminal
			;mode to change baud rate on fly
;
;
; Handles in/out ports for data and status
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port
		DS	7            	;spares if needed for non-PMMI
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data port
		DS      7       	;spares if needed for non=PMMI
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port
                DS      7        	;spares if needed for non-PMMI
;
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when ready
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready
;
;
;====================== SPECIAL PMMI PORTS =============================
;
IN$BAUDRP:	IN	BAUDRP	 ! RET	;in baudrate port
OUT$BAUDRP:	OUT	BAUDRP	 ! RET	;out baudrate port
OUT$MODCTL1:	OUT	MODCTL1	 ! RET	;out modem control port #1
OUT$MODCTL2:	OUT	MODCTL2  ! RET	;out modem control port #2
;
;================== END OF SPECIAL PMMI PORTS ==========================
;
;
LOGONPTR:	DW	LOGON
JMP$DIAL:	DS      3
JMP$DISCONNT:	DS      3   
JMP$GOODBYE:	JMP	GOODBYE
JMP$INITMOD:	JMP	INITMOD
                RET ! NOP ! NOP  
                RET ! NOP ! NOP
                RET ! NOP ! NOP
JMP$SETUPR:	JMP	SETUPR
JMP$SPCLMENU:	JMP	SPCLMENU
JMP$SYSVER:	JMP	SYSVER
JMP$BREAK	JMP	SENDBRK
;
;
; NEXT SIX LINES SHOULD NOT BE CHANGED BY USER OVERLAY AS THESE GO TO
; SPECIFIC LOCATIONS IN THE MAIN PROGRAM, NOT IN THE OVERLAY.
;
JMP$ILPRT:      DS      3    
JMP$INBUF:	DS      3    
JMP$INLNCOMP:	DS      3        
JMP$INMODEM:	DS      3      
JMP$NXTSCRN:	DS      3       
JMP$TIMER:	DS      3     
;
;
; Clear sequences are for Televideo, Lear Siegler, etc.  Change to match
; your terminal.  (Heath uses ESC 4AH for clear to end of screen, ESC 45H
; to clear screen.  Lear Siegler and others use ESC 79H for clear to end
; of screen and ESC 3AH to clear screen.)  Room allowed for four bytes.
; (Last zero needed for stopping the string display.  Any extra 0's just
; act as NOP's.)
;
CLREOS:	CALL	JMP$ILPRT       ;was ILPRT
	DB	0,0,0,0,0	;dave hardy had 059h,0,0,0,0
	RET
;.....
;
;
CLRSCRN:CALL	JMP$ILPRT      ; was ILPRT
	DB	1AH,0,0,0,0    ; was 1eh,59h,59h,00 in dave hardy version
	RET
;.....
;
;
;======================= SIGN-ON MESSAGE ==============================	
;
; Send version number and date
;
SYSVER: CALL    JMP$ILPRT      ; was LDA
	DB	'       Sanyo MBC-1000 & Anchor Mark XII modem  1200 Baud'
	DB	CR,LF,cr,lf,cr,lf
	db	'MDM722.COM--------M7SY-2.HEX-------M7NM-6RS.HEX'
	db	cr,lf,cr,lf  ;I use above to track patches: customize at will
	db	0		;end of message flag
	RET
;.....
;
SYSVER1:JMP      SYSVER
;.....
;
;
;==================== LOGON MESSAGE (IF ANY) ===========================
;
; Insert your logon message here.  End with a 0 (for"CALL ILPRT").
; PMMIusers have 59 bytes available, non-PMMI users have approximately
; 2K bytes available as they can overwrite all the following PMMI rou-
; tines if they wish.  This method allows the external overlays to have
; plenty of room.  It keeps the phone number library at a fixed location.
;
LOGON:	DB      'Your Name?',CR,LF
	DB	0		;to terminate the logon message
;.....
;
;=========== ANCHOR MARK XII INITIALIZATION ADDED =====================
;
; Insert your initialization routine here if needed.  Can replace the
; following special PMMI area to set speed and auto-dial.  Over 950
; bytes are available for this purpose.  (End your routine with a RET.)
;
;
;=======================================================================
;
; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.
;
SENDBRK:  MVI	A,1FH		;SEND A BREAK TONE
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modesm such as the Bell 212A, etc.	
;
GOODBYE:  MVI	A,08H		;SEND BREAK, TURN OFF DTR
;
GOODBYE1: OUT	MODCTL1		;SEND TO STATUS PORT
	  MVI	B,3		;WAIT 300 MS.
	  CALL 	JMP$TIMER
	  MVI	A,37H		;NORMAL SEND/RECEIVE WITH DTR
	  OUT	MODCTL1		;SEND TO STATUS PORT
	  RET
;.....
;
;
; Sanyo MBC-1000 initialization -- sets the 8251A for 8 bits, 1 stop bit,
; no parity, 1200 Baud (was 300 baud)
;
INITMOD:  MVI	A,5		;TRANSFER TIME FOR 1200 Baud (was 1=300 BAUD)
	  STA	MSPEED	
          MVI	A,96H		;Set up counter/timer to be baud rate clock
	  OUT	CTIMER
          LDA	V1
	  OUT	CTIMER-1
	  MVI	A,087H		;INSURE OUT OF MODE state
	  OUT	MODCTL1		;MODEM STATUS PORT
	  out   modctl1         ;slight extra delay
	  MVI	A,40H		;INITIALIZE USART
	  OUT	MODCTL1		;MODEM STATUS PORT
	  LDA	V2
	  ADI	4CH		;8 DATA BITS, 1 STOP, NO PARITY
	  OUT	MODCTL1		;MODEM STATUS PORT
	  MVI	A,17H		;DTR, RCV, XMT, ERROR RST:hardy had 27h w RTS
	  OUT	MODCTL1		;MODEM STATUS PORT
	  IN	PORT		;CLEAR DATA PORT
	  RET
;
V1	DB	010H            ;COUNTER VALUE(dflt = 1200; was 040h=300 baud)
V2	DB	2		;CLOCK DIVISOR  2 works from 150 to 1200 baud
;.....
;========== NON-PMMI SETUP (SPEED CHANGE, ETC.) IF ANY ==============
;
; Insert your speed change and/or auto-dialing routines here.
; Over 950 bytes are available (INCLUDING INITMOD, above).
; End your routine with a RET.
;
;
SETUPR:	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200): ',0         ;, 1800, 2400): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
;	  CALL	JMP$INLNCOMP	;killed these lines so only 300/1200 plays
;	  DB	'1800',0
;	  JNC	OK1800
;	  CALL	JMP$INLNCOMP
;	  DB	'2400',0
;	  JNC	OK2400
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, TELL OPERATOR
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	LXI	H,0241H		;V1=41h   V2=02h   ******* WARNING ******
                                ;
                                ;V1 was 40h  minor adjustment of the value
                                ;of V1 may be required because of individual
                                ;crystal, component or temperature variations.
	SHLD	V1		;SAVE PARAMETERS FOR 300 BAUD
        MVI	A,1		;MSPEED 300 BAUD VALUE
        JMP	LOADBD          ;jump to load: Dave you forgot this !!
;
OK1200:	LXI	H,0210H		;V1=10h   V2=02h  See Warning in OK300
	SHLD	V1
	MVI	A,5
	JMP     LOADBD
;
;        killed the followings lines to restrict baud set to 300 & 1200
;
;OK1800:	LXI	H,01A0H	;V1=A0h   V2=01h
;	SHLD	V1
;	MVI	A,6
;	JMP	loadbd 
;
;OK2400:	LXI	H,0180H	;V1=80h   V2=01h
;	SHLD	V1
;	MVI	A,6
;	JMP	loadbd 
;
LOADBD: STA     INITMOD+1	;change time-to-send to match baudrate
        JMP     INITMOD         ;reset MSPEED TO NEW BAUDRATE
; 
;
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;		
;
; These routines can be used for your equipment.  End with RET.  If
; using the Hayes Smartmodem this is unavailable without a special ad-
; dress change.
;
SPCLMENU: RET
;		
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
;
 	END		; ************************************************
