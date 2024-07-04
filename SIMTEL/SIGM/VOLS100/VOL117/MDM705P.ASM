	TITLE	'MDM705 (02/27/83)  --  CP/M MODEM PROGRAM'
;
; THIS PROGRAM  ORIGINATED  IN 1977.  WRITTEN  BY WARD CHRISTENSEN, IT
; HAS SINCE UNDERGONE  EXTENSIVE REVISIONS.  SO MANY PEOPLE HAVE ADDED
; USEFUL FEATURES IT WOULD  BE DIFFICULT TO LIST THEM ALL.  OTHER VER-
; SIONS OF THE  ORIGINAL PROGRAM  HAVE BEEN MADE, THIS ONE CATERING TO
; THOSE USING THE 'PMMI' AUTO-DIALING S-100 MODEM.  THOSE HAVING OTHER
; MODEMS CAN READILY USE IT, LOSING ONLY THE AUTO-DIALING FEATURE.  BE
; CAREFUL TO SET THE PORTS AND OTHER OPTIONS CORRECTLY.  OVERLAYS HAVE
; BEEN MADE ALLOWING RAPID ADAPTATION TO COMPUTERS NOT USING THE S-100
; BUS.  IT CONFORMS READILY TO NORMAL UARTS AND OTHER I/O DEVICES SUCH
; AS THE 2661, 8250, 8251, ETC.
;
;   NOTE:  If upgrading this program, please add modest comments that
;	   describe the changes and the date they were made.  Then send
;	   to TCBBS in Dearborn (313) 846-6127.
;
;   GENERAL INTEREST:  When transferring files modem-to-modem, the batch
;   mode is extremely useful.  It not only speeds things up, but there
;   is no timeout at the receiving end while the other person prepares
;   to send.  With normal single program transfer, the receiving end
;   switches to checksum in one minute and times out completely in 100
;   seconds.  This offers ample opportunity to transfer programs between
;   individuals.  Remember the batch mode can be used for single files
;   or with wildcards.  Many outstanding optional features have been
;   added by various people throughout its development.  Our thanks to
;   all those who have - and will - contribute.
;					- Irv Hoff, W6FFC
;
;***********************************************************************
;
; 830326:0825
;	    Delay between dialled numbers increased from 2 to 8 units
;  MDM705P  for use with old 416-48x-xxxx exchange that gets lost if
;           one dials too fast.
;	    Various magic numbers in Break and Dialler routines replaced
;	    with appropriate equates (mods NOT marked).
;           Option PAR added for the PMMI-only section to toggle the
;	    terminal mode between 8 bits no parity (default) and 7 bits
;           even parity as required by dear old primitive IBM front end.
;					- Greg Louis
;
; 02/27/83  'V' mode corrected.  When CTL-B is used to change Baudrate
;	    on-the-fly, the Baudrate remains the same when going to-from
;  MDM705   the "T" mode now.  (Previously it would often ignore CTL-B
;	    entirely if the "T" mode had been selected with no Baudrate
;	    included, leading to notices regarding "flakey operation".)
;	    Thanks to Frank Gaude'.  Deleted some superfluous coding.
;	    Fixed quiet mode timing for suitable use with "BYE", etc.
;					- Irv Hoff
;
; 02/13/83  1. 'D' option (if PMMI) auto-disconnects the phone line at
;		  the end of a transfer if included in command.  (Pre-
;		  viously said "Press return to disconnect").
;  MDM704   2. Added an 'X' option that auto-disconnects at the end of
;		  a transfer and jumps to 'BYEBYE' which reboots back to
;		  CP/M.  Does a cold boot if CLDBOOT has been entered.
;	    3. Fixed the "quiet mode" so that only those messages which
;		  can interfere with the BYE protocol are suppressed.
;					- R. L. Plouffe	
;
; 02/07/83  Reworked the "quiet" mode (used in conjunction with "BYE" on
;           some occasions for batch mode, etc.)  Protection added for
;  MDM703   quiet mode to insure returning to command prompt after file
;           transfer even if "T" was inadvertently selected.  Added nor-
;	    mal method of changing user area as well as with LOG.  Other
;	    modest changes.  Thanks to Frank Gaude' for suggestions and
;	    testing.			- Irv Hoff
;
; 01/27/83  Rstores original drive and user area when returning to CP/M.
;	    Reorganized the PMMI dialing section, fixing several long-
;  MDM702   standing bugs in the auto-redialing system.  Also can now
;	    (finally) auto-redial off the menu command line, including
;	    ringback numbers.  Number of dialing attempts now displayed.
;	    Added triple protection against inadvertently erasing all
;	    files on a disk with improper use of "*" or "?" wildcards.
;	    Batch mode rejected except when using "S" or "R".  If send-
;	    ing a file in "T" mode (via CTL-T), line feeds are displayed
;	    but not sent.  Line delays are triggered from CR characters.
;					- Irv Hoff
;
; 01/10/83  Added some of the features in the current COMM 7.13 version.
;	    It is now simple to abort while in send or receive.  Clock
;  MDM701   speeds up to 25.5 MHz may be used, in 0.1 MHz increments.
;	    Several glitches fixed.  Particular thanks to Frank Gaude'
;	    for permission to adapt some of his routines, plus his help
;	    and continued interest.	- Irv Hoff
;
; 01/01/83  First version.  This is similar to MODEM 7.98 but with the
;	    macro library now integral in the program.  It assembles via
;  MDM700   ASM or MAC as well as with other popular assemblers.   Those
;	    contributing heavily to recent development leading to MODEM
;	    7.98 were Bruce Ratoff, Paul Kelley, Frank Gaude', Mark Pul-
;	    ver, Bob Plouffe and myself.  Many others have made large
;	    contributions in previous years.  MDM700 was selected as a
;	    name to commence a new series of version numbers.  This also
;	    can readily be placed on data bank systems that limit file
;	    names to a total of 6 characters.
;					- Irv Hoff
;
;***********************************************************************
;
;
TRUE		EQU	0FFH
FALSE		EQU	0
;
;
DBUFSIZ:	EQU	16	;buffer size for file transfer in Kbytes
;
ERRCRC:		EQU	6	;number of times to try CRC mode..
				;..before switching to CHECKSUM
;
; PMMI EQUATES  (The first 8 lines are also of particular interest to
; non-PMMI users.)
;
PORT:		EQU	0C0H	;*PMMI base address (0C0H is typical)
;
MODCTLP:	EQU	PORT	;modem control port
MODDATP:	EQU	PORT+1	;*modem data port
BAUDRP:		EQU	PORT+2	;modem baud rate port
MODCTL2:	EQU	PORT+3	;modem 2nd control port
MODRCVB:	EQU	02H	;modem receive bit (DAV)
MODRCVR:	EQU	02H	;modem receive ready
MODSNDB:	EQU	01H	;modem send bit (transmit buffer empty)
MODSNDR:	EQU	01H	;modem send ready bit
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
NOPARMSK:	EQU	10H	;mask to reset to no parity
EVPARMSK:	EQU	20H	;mask to set even parity
ODPARMSK:	EQU	0CFH	;mask to set odd parity
BRKMSK:		EQU	0FBH	;mask to set break
ERRCDMSK:	EQU	38H	;mask to block all bits but error codes
FRMER:		EQU	20H     ;mask for framing error
ORUNER:		EQU	10H	;mask for overrun error
PARER:		EQU	08H	;mask for parity error
;
ANSWMOD:	EQU	1EH	;answer mode
ORIGMOD:	EQU	1DH	;originate mode
ORIG7E		EQU	29H	;orig mode, 7 bits, even parity
BDNMCH:		EQU	75H	;bad name match
LIBLEN:		EQU	34	;length of each phone library entry
RUB:		EQU	7FH	;rub
WAITCTS:	EQU	100	;number of seconds (x5) to wait for the
				;computer to answer after PMMI auto-dial
				;100=20 sec, 150=30 sec, 255=51 sec.
				;any number 0-255 acceptable
CRC:		EQU	'C'	;requests 'CRC' instead of 'CKSUM'
ESC:		EQU	'['-40H	;^[ = escape
SOH:		EQU	'A'-40H	;^A = start of header
EOT:		EQU	'D'-40H	;^D = end of text
ACK:		EQU	'F'-40H	;^F = acknowledge
OKNMCH:		EQU	'F'-40H	;^F = ok name match
BELL:		EQU	'G'-40H	;^G = bell character
BKSP:		EQU	'H'-40H	;^H = backspace
LF:		EQU	'J'-40H	;^J = linefeed
CR:		EQU	'M'-40H	;^M = carriage return
XON:		EQU	'Q'-40H	;^Q = XON character
XOFF:		EQU	'S'-40H	;^S = XOFF character
NAK:		EQU	'U'-40H	;^U = not acknowledge
CAN:		EQU	'X'-40H	;^X = cancel send or receive
EOFCHAR:	EQU	'Z'-40H	;^Z = end of file
;
BOTTRAM		SET	LAST+100H AND 0FF00H
;
;
		ORG	0100H
;
;
		JMP	START	;skip the data area below
;
; THESE ROUTINES AND EQUATES ARE AT THE BEGINNING OF THE PROGRAM SO
; THEY CAN BE PATCHED BY A MONITOR OR OVERLAY FILE WITHOUT RE-ASSEMBLING
; THE PROGRAM.
;
PMMIBYTE:	DB	TRUE	;*true=PMMI modem, false=non-PMMI modem
;
CLOCK:		DB	40	;*clock speed x10, up to 25.5 mhz.
				;2 MHz=20, 3.68 MH=37, 4 MHz=40, etc.
MSPEED:		DB	1	;*sets display time for sending a file
				;0=110  1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600
BYTDLY:		DB	5	;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:		DB	5	;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
NOOFCOL:	DB	5	;number of directory columns
SETUPTST:	DB	FALSE	;true=non-PMMI setup routine
SCRNTEST:	DB	TRUE	;*true=if home cursor and clear screen
				;routine at CLRSCRN
BAKUPBYTE:	DB	FALSE	;true=make .BAK file
CKSUMDFLT:	DB	FALSE	;true=default to Checksum checking
				;*false=default to CRC checking
TOGGLECRC:	DB	TRUE	;true=allow toggling of Checksum to CRC
CONVBKSP:	DB	FALSE	;true=convert backspace to rub
TOGGLEBK:	DB	TRUE	;true=allow toggling of bksp to rub
ADDLF:		DB	FALSE	;true=add LF after CR
TOGGLELF:	DB	TRUE	;true=allow toggling of LF after CR
TRANLOGON:	DB	FALSE	;true=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:		DB	TRUE	;true=do not overwrite CCP
LOCONEXTCHR:	DB	FALSE	;true=local cmd if EXTCHR precedes
				;false=not local cmd if EXTCHR precedes
TOGGLELOC:	DB	TRUE	;true=allow toggling of LOCONEXTCHR
LSTTST:		DB	TRUE	;*true=allow toggling of printer on/off
				;in terminal mode. Set to false if your
				;printer can't keep up with the modem
XOFFTST:	DB	FALSE	;true=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWAIT:	DB	FALSE	;true=wait for XON aftersending CR while
				;transmitting a file in terminal mode	
TOGXOFF:	DB	TRUE	;true=allow toggling of XOFF testing
EXITCHR:	DB	'E'-40H	;^E = Exit without disconnect
LOGCHR:		DB	'O'-40H	;^O = Send logon
LSTCHR:		DB	'P'-40H	;^P = Toggle printer
UNSAVECHR:	DB	'R'-40H	;^R = Close input text buffer
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer
EXTCHR:		DB	'^'-40H	;^^ = Send next character
;
;
; Equates used only by PMMI routines grouped together here.
;
PULSERATE:	DB	250	;125 for 20pps, 250 for 10pps on PMMI
				;not used if PMMI FALSE
CLDBOOT:	DW	00000H	;warm reboot address - put your own
				;address for a cold reboot if preferred
BRKCHR:		DB	'@'-40H	;^@ = Transmit "BREAK" with PMMI
CHGBAUD:	DB	'B'-40H	;^B = Used with PMMI in terminal
				; mode to change baud rate on fly
DISCCHR:	DB	'D'-40H	;^D = PMMI Disconnect
;
;
IN$MODCTLP:	IN	MODCTLP ! RET	;in modem control port
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when ready
;
;
; THE FOLLOWING ARE TYPICALLY USED ONLY BY PMMI
;
IN$BAUDRP:	IN	BAUDRP   ! RET	;in baudrate port
OUT$BAUDRP:	OUT	BAUDRP   ! RET	;out baudrate port
OUT$MODCTL2:	OUT	MODCTL2  ! RET	;out modem control port #2
OUT$MODCTLP:	OUT	MODCTLP		;out modem control port
		STA	UARTCTLB ! RET	;and store control byte
;
LOGONPTR:	DW	LOGON
JMP$INITMOD:	JMP	INITMOD
JMP$SETUPR:	JMP	SETUPR
;
; MOD(BGL) FOR PARITY SWITCH DURING CONVERSATIONAL TRANSMISSION
PARTY:		DB	ORIGMOD
PARTOG:		DB	ORIGMOD+ORIG7E
;
; Clear sequences are for Televideo, Lear Siegler, etc.  Change to match
; your terminal.  (Heath uses ESC 4AH for clear to end of screen, ESC 45H
; to clear screen.  Lear Siegler and others use ESC 79H for clear to end
; of screen and ESC 3AH to clear screen.)  Room allowed for four bytes.
; (Last zero needed for stopping the string display.  Any extra 0's just
; act as NOP's.)
;
CLREOS:		CALL	ILPRT
		DB	'O'-40H,0,0,0,0
		RET
;.....
;
;
CLRSCRN:	CALL	ILPRT
		DB	'L'-40H,0,0,0,0
		RET
;.....
;
;
; NEXT FIVE LINES SHOULD NOT BE CHANGED BY USER OVERLAY
;
JMP$ILPRT:	JMP	ILPRT
JMP$INLNCOMP:	JMP	INLNCOMP
JMP$INBUF:	JMP	INBUF
JMP$SYSVER:	JMP	SYSVER
JMP$DIAL:	JMP	DIAL
JMP$DISCONNT:	JMP	DISCONNT
;
;	
; Send version number and date
;
SYSVER:	  LDA	PMMIBYTE	;USING THE PMMI S-100 MODEM?
	  ORA	A
	  JZ	SYSVER1		;GO IF NOT
	  CALL	ILPRT
	  DB	'Version for PMMI S-100 modem starting at port: ',0
	  LDA	IN$MODCTLP+1
	  CALL	HEXO		;PUT IN PMMI CONTROL PORT NUMBER
	  CALL	ILPRT
	  DB	'H',CR,LF,0
	  RET
;.....
;
;
SYSVER1:  CALL	ILPRT		;IF NOT USING THE PMMI S-100 BOARD
	  DB	'Version for Non-PMMI modem',CR,LF,0
	  RET
;.....
;
;
; INSERT YOUR LOGON HERE.  CAN BE ANY LENGTH DESIRED.  MUST END WITH 0.
;
LOGON:	  DB	0
;
;
; INSERT YOUR INITIALIZATION ROUTINE HERE IF NEEDED.  CAN REPLACE THE
; FOLLOWING SECTION WHICH IS PRESENTLY USED FOR THE PMMI BOARD.
;
INITMOD:
;
;
; SETS THE BAUD RATE FOR THE PMMI BOARD (IF ONE IS SPECIFIED)
;
SETBAUD:  LDA	PMMIBYTE
	  ORA	A
	  RZ			;IF NOT PMMI S-100 BOARD, IGNORE REST
;
	  LDA	ANSWFLG		;IF 'O' OR 'A' NOT REQUESTED AND
	  ORA	A		;   BAUDRATE NOT SPECIFIED, RETURNS
	  JZ	FIXBAUD		;   WITH CURRENT MODE AND RATE
	  LDA	ORIGFLG		;IF OPTION REQUESTED, A BLANK FORCES 300
	  ORA	A		;   BAUD AS DOES A NULL FROM NEWBAUD
	  RNZ			;NO CHANGE IF NEITHER 'O' OR 'A' SHOWN
;
FIXBAUD:  CALL	GETBAUD
	  MOV	B,A		;SAVE THE BAUD RATE VALUE
	  CALL	OUT$BAUDRP	;SET THE PMMI BOARD TO THAT BAUDRATE
	  CALL	CHGMSPD		;GET THE 'MSPEED' VALUE
	  MOV	A,C		;IT COMES BACK IN THE 'C' REG.
	  STA	MSPEED		;SET THE CORRECT 'MSPEED'
	  MOV	A,B		;GET THE BAUD RATE VALUE BACK
	  CPI	52
	  MVI	A,5FH		;DTR (FILTER FOR OVER 300 BAUD)
	  JC	GT300		;YES, GREATER THAN
	  MVI	A,7FH		;DTR (FILTER FOR 300 AND LESS BAUD)
;
GT300:	  CALL	OUT$MODCTL2
	  STA	MODCTLB		;SAVE MODEM CONTROL BYTE
	  LDA	UARTFLG		;UART CONROL BYTE FOR 'A' OR 'O'
	  ORA	A
; MOD(BGL)***
	  LDA	PARTY		;GET ORIGINATE MODE
	  JZ	OFFHOOK		;EXIT IF 'O' SET
	  MVI	A,ANSWMOD
;
OFFHOOK:  LXI	H,7500
;
OFFDLY:   DCR	L
	  JNZ	OFFDLY
	  DCR	H
	  JNZ	OFFDLY
	  CALL	OUT$MODCTLP
	  RET
;.....
;
;
;-----------------------------------------------------------------------
;
; Phone number library table for PMMI auto-dialing.  Each number must be
; as long as "LIBLEN" (EQU at start of program).  Some areas require ex-
; tra characters such as:   1-313-846-7127.  Room is left for those.
;
;		'----5---10---15---20---25---30--34'
NUMBLIB:  DB	'A=Amrad...............703-734-1387'	;'A'
	  DB	'B=                                '	;'B'
	  DB	'C=CBBS Pasadena.......213-799-1632'	;'C'
	  DB	'D=PMMI................703-379-0303'	;'D'
	  DB	'E=Edward Huang........415-595-0541'	;'E'
	  DB	'F=                                '	;'F'
	  DB	'G=Gasnet NASA.........301-344-9156'	;'G'
	  DB	'H=Dave Hardy..........313-846-6127'	;'H'
	  DB	'I=Wayne Hammerly......301-953-3753'	;'I'
	  DB	'J=RBBS Pasadena.......213-356-1034'	;'J'
	  DB	'K=Bob Kuhman..........408-732-2433'	;'K'
	  DB	'L=Program Store.......202-337-4694'	;'L'
	  DB	'M=Dick Mead...........213-799-1632'	;'M'
	  DB	'N=Mtn/View PICONET....415-965-4097'	;'N'
	  DB	'O=Bob Plouffe.........703-524-2549'	;'O'
	  DB	'P=Keith Petersen.....313-759-6569R'	;'P'
	  DB	'Q=Bruce Ratoff........201-272-1874'	;'Q'
	  DB	'R=Mark Pulver.........312-789-0499'	;'R'
	  DB	'S=Paul Traina.........408-867-1243'	;'S'
	  DB	'T=TCBBS, Dearborn.....313-846-7127'	;'T'
	  DB	'U=                                '	;'U'
	  DB	'V=                                '	;'V'
	  DB	'W=Ward Christensen....312-545-8086'	;'W'
	  DB	'X=                                '	;'X'
	  DB	'Y=                                '	;'Y'
	  DB	'Z=                                '	;'Z'
	  DB	0					;end
;		'----5---10---15---20---25---30--34'
;.....
;
;
;***********************************************************************
;
; P - R - O - G - R - A - M    S - T - A - R - T - S    H - E - R - E
;
;***********************************************************************
;
;
START:	  POP	H		;GET THE STACK RETURN TO CCP
	  SHLD	EXIT1+1		;ENABLES RETURN TO CCP
	  LXI	SP,STACK	;START LOCAL STACK
	  CALL	ILPRT
	  DB	CR,LF,'MDM705 - 02/27/83',CR,LF,0
	  CALL	INITADR		;INITIALIZE ADDRESSES
	  CALL	JMP$SYSVER	;GIVE CONFIGURATION MESSAGE
	  CALL	GETUSER		;GET CURRENT USER NUMBER
	  STA	OLDUSER
	  MVI	A,TRUE		;0FFH
	  STA	NFILFLG		;RESET THE NO FILE FLAG TO SHOW NO FILE
	  CMA			;0
	  STA	ORIGMOD		;SET INITIALLY FOR ORIGINATE MODE
	  STA	SAVEFLG
	  LDA	FCB+1		;IS THERE A COMMAND TAIL?
	  STA	OPTION
	  CPI	' '
	  JNZ	START0		;IF YES, DIGEST IT
	  SUB	A
	  STA	EXITFLG		;ELSE SAY WE WANT MENU
	  JMP	START1
;
START0:	  LXI	H,80H		;SIMULATE COMMAND LINE INPUT FROM MENU
	  MOV	B,M		;SAVE CHAR COUNT
;
STARTA:	  INX	H
	  MOV	A,M		;SKIP OVER LEADING SPACES IN COMMAND TAIL
	  CPI	' '
	  JNZ	STARTB
	  DCR	B
	  JMP	STARTA
;
STARTB:	  MOV	A,B
	  STA	CMDBUF+1	;STORE COMMAND CHAR COUNT - LGNG SPACES
	  INR	B		;MOVE 1 EXTRA BYTE (SHOULD BE A NULL)
	  LXI	D,CMDBUF+2
	  CALL	MOVE
	  CALL	SETFCB		;DIGEST COMMAND LINE AND OPTIONS
;
START1:	  LDA	UARTFLG
	  ORA	A
	  MVI	A,ANSWMOD
	  STA	UARTCTLB
	  JNZ	RESTART
;MOD(BGL)***
	  LDA	PARTY
	  STA	UARTCTLB
;
RESTART:  LXI	SP,STACK	;MAKE SURE WE HAVE A CLEAN STACK
	  LXI	D,CMDBUF+1	;MAY BE USEFUL WHERE WE ARE GOING
	  LDA	OPTION		;GET MAIN OPTION
	  MOV	B,A		;SAVE IT
	  LDA	PMMIBYTE	;PMMI?
	  ORA	A		;SET FLAGS
	  MOV	A,B		;GET OPTION BACK
	  JZ	S1		;NOT PMMI
	  CPI	'C'		;CALL (DIAL) FUNCTION?
	  JZ	JMP$DIAL	;YES, GO TO IT
	  CPI	'D'		;DISCONNECT?
	  JZ	DISCON1		;YES, DISCONNECT & GO MENU
;
S1:	  CPI	' '		;NO OPTION SPEC'D?
	  JZ	MENU		;TRUE, GO MENU
	  CPI	'H'		;MENU ASKED FOR?
	  JZ	MENU2		;YES, GO MENU2
	  CALL	JMP$INITMOD
	  CALL	MOVEFCB
	  CALL	IN$MODDATP 	;GOBBLE UP GARBAGE..
	  CALL	IN$MODDATP 	;..CHARACTERS ON LINE
	  XRA	A
	  STA	ECHOFLG		;RESET ECHO FLAG
	  STA	LOCFLG		;RESET LOCAL FLAG
	  LDA	OPTION		;PROCESS MAIN OPTION
	  CPI	'E'		;ECHO MODE?
	  JNZ	NOECH		;JUMP IF NOT
	  MVI	A,TRUE		;SET ECHO TO TRUE
	  STA	ECHOFLG
	  JMP	DSKSAVE
;
NOECH:	  CPI	'L'		;LOCAL ECHO MODE
	  JNZ	NOLOC
	  MVI	A,TRUE
	  STA	LOCFLG
	  JMP	DSKSAVE
;
NOLOC:	  CPI	'T'		;TERMINAL MODE?
	  JZ	DSKSAVE		;YES
	  CPI	'S'		;SEND A FILE?
	  JZ	SENDFIL		;YES
	  CPI	'R'		;RECEIVE A FILE?
	  JZ	RCVFIL		;YES
	  CALL	NTVLDMSG	;SAY NOT A VALID OPTION
	  JMP	MENU		;NO VALID OPTION SPEC'D, GO MENU
;
;
; Revised terminal routine allowing memory save.  First checks for bad
; options, to prevent wiping out the disk with accidental memory save.
;
DSKSAVE:  LDA	BATCHFLG	;BATCH FLAG SET?
	  ORA	A
	  JNZ	DSKSAVE1
	  XRA	A
	  STA	BATCHFLG
	  JMP	NOTVLD		;IF YES, ERROR FOR "E", "L" OR "T"
;
DSKSAVE1: LDA	FCB+1		;FIRST CHARACTER OF FILENAME (IF ANY)
	  CPI	' '		;FILE SPECIFIED?
	  JNZ	GOODNM		;YES, GOOD NAME
	  MVI	A,TRUE		;0FFH
	  STA	NFILFLG
	  CMA
	  STA	SAVEFLG
	  JMP	TERM
;...
;
;
GOODNM:	  CALL	ERASFIL
	  CALL	MOVE2
	  LXI	D,FCB3
	  MVI	C,MAKE
	  CALL	BDOS
	  LXI	D,FCB3
	  MVI	C,OPEN
	  CALL	BDOS
	  LXI	H,BOTTRAM
	  SHLD	HLSAVE
	  XRA	A
	  STA	NFILFLG		;SHOW NOW SAVING TO MEMORY FOR DISK FILE
	  STA	LISTMOR		;STOP ANY BUFFERED PRINTER OUTPUT
;
TERM:	  LDA	UARTFLG
	  STA	ORIGSAV
	  ORA	A
	  MVI	A,ANSWMOD
	  JNZ	TERM1
;MOD(BGL)***
	  LDA	PARTY		;GET DEFAULT PARITY
;
TERM1:	  STA	UARTCTLB
;
TERM2:	  LDA	LISTMOR		;ANY BUFFERED PRINTER OUTPUT?
	  ORA	A
	  CNZ	GOLIST		;GO IF SO
	  CALL	STAT		;KEYPRESS?
	  JZ	TERML		;NO, CHECK LINE
	  CALL	KEYIN		;GET CHAR FROM KBD
	  CPI	' '
	  JNC	NOTOG		;GO IF NOT CONTROL CHARACTER
	  MOV	B,A		;SAVE
 	  CPI	BKSP		;TEST FOR BACKSPACE
	  JNZ	NOBKSP
	  LDA	CONVBKSP	;CONVERT BACKSPACE TO RUB?
	  ORA	A
	  JZ	NOBKSP		;GO IF NO CONVERSION
	  MVI	A,RUB
	  JMP	NOTOG
;...
;
;
NOBKSP:	  LDA	EXACFLG
	  ORA	A		;EXACT?
	  MVI	A,0
	  STA	EXACFLG		;CLR FOR NEXT TIME
	  JZ	NTEXAFLG	;GO OF EXAFLG FALSE
	  LDA	LOCONEXTCHR
	  ORA	A		;SHOULD WE SEND ON EXAFLG?
	  MOV	A,B
	  JZ	NOTOG		;YES, IF LOCONEXTCHR FALSE
	  LDA	EXTCHR		;WE WANT TO SEND EXTCHR IN ANY CASE
	  CMP	B
	  MOV	A,B
	  JZ	NOTOG		;SEND IF EXTCHR
	  JMP	LOCCHK		;OTHERWISE DO LOCAL STUFF
;...
;
;
NTEXAFLG: LDA	EXTCHR		;TREAT NEXT CHARACTER IN SPECIAL WAY?
	  CMP	B
	  JZ	EXTFLG		;YES, SET EXAFLG FOR NEXT CHAR
	  LDA	LOCONEXTCHR
	  ORA	A		;SHOULD WE SEND IF NOT EXAFLG
	  MOV	A,B
	  JNZ	NOTOG		;YES, IF LOCONEXTCHR TRUE
;
LOCCHK:	  LDA	EXITCHR		;RETURN TO MENU?
	  CMP	B
	  JZ	EXITMEN		;YES, RETURN TO MENU
	  LDA	TRANCHR		;OUTPUT TEXT FILE TO REMOTE?
	  CMP	B
	  CZ	TRANSFER	;SEND-A-FILE (BLIND SEND)
	  JZ	TERM2		;LOOP
	  LDA	TRANLOGON
	  ORA	A
	  JZ	SKPLOGON
	  LDA	LOGCHR		;SEND LOGON?
	  CMP	B
	  JZ	SENDLOG
;
SKPLOGON: LDA	LSTTST		;GOING TO USE THE EXTERNAL PRINTER?
	  ORA	A
	  JZ	NOLST		;IF NOT, SKIP THIS AREA
	  LDA	LSTCHR		;GET THE PRINTER CONTROL-CHARACTER
	  CMP	B		;DID WE JUST ASK FOR PRINTER CONTROL?
	  JNZ	NOLST		;IF NOT, EXIT
	  LDA	LISTFLG		;OTHERWISE RESET THE PRINTER TOGGLE
	  CMA
	  STA	LISTFLG		;AND STORE
	  CALL	CRLF		
	  CALL	CRLF
	  CALL	LSTMSG		;TELL IF PRINTER IS ON OR OFF NOW
	  CALL	CRLF
	  JMP	TERML		;BACK TO THE TERMINAL MODE AGAIN
;.....
;
;
NOLST:	  LDA	PMMIBYTE	;USING A PMMI BOARD?
	  ORA	A
	  JZ	S2		;IF NOT, SKIP THE NEXT FEW LINES
	  LDA	DISCCHR		;PMMI DISCONNECT?
	  CMP	B
	  JZ	DISCON1		;YES, DISCONNECT & RETURN TO MENU
	  LDA	BRKCHR		;PMMI BREAK?
	  CMP	B
	  JZ	BREAK
	  LDA	CHGBAUD		;PMMI CHANGE BAUD?
	  CMP	B
	  PUSH	PSW
	  PUSH	H
	  CZ	NEWBAUD
  	  POP	H
	  POP	PSW
	  JZ	TERML
;...
;
;
S2:	  LDA	UNSAVECHR	;CLOSE INPUT BUFFER?
	  CMP	B
	  JZ	S2A		;IF YES, DISABLE COPY
	  LDA	SAVECHR		;OPEN INPUT BUFFER?
	  CMP	B
	  MOV	A,B		;RESTORE CHARACTER TYPED
	  JNZ	NOTOG
	  LDA	NFILFLG		;DO NOT ALLOW SAVE IF..
	  CPI	TRUE		;..THIS FLAG IS SET.
	  JZ	TERML
	  MVI	A,TRUE		;0FFH -- ALLOW COPY INTO FILE
	  JMP	S2B
;
S2A:	  MVI	A,FALSE		;0 -- STOP COPY INTO FILE
;
S2B:	  STA	SAVEFLG
	  CALL	BUFMSG
	  JMP	TERML
;.....
;
;	
;***********************************************************************
;
; SEND A CP/M FILE
;
;***********************************************************************
;
;
SENDFIL:  MVI	A,TRUE		;ALWAYS FORCE CHECKSUM MODE..
	  STA	CRCFLAG		;..INITIALLY ON SEND
;
SENDFIL1: CALL	PARITY		;SET PARITY IF REQUESTED
	  LDA	BATCHFLG	;CHECK IF MULTIPLE FILE..
	  ORA	A		;..MODE IS SET.
	  JNZ	SENDC1
	  MVI	A,TRUE		;INDICATE SEND FOR BATCH MODE
	  STA	SENDFLG
	  LDA	FSTFLG		;IF FIRST TIME THRU..
	  ORA	A		;..SCAN THE COMMAND LINE..
	  CNZ	TNMBUF		;..FOR MULTIPLE NAMES.
	  CALL	SENDFN		;SENDS FILE NAME TO RECEIVER
	  JNC	SENDC2		;CARRY SET MEANS NO MORE FILES.
	  MVI	A,'B'		;STOP BATCH..
	  STA	BATCHFLG  	;..MODE OPTION.
	  MVI	A,EOT		;FINAL XFER END
	  CALL	SEND
	  JMP	DONE
;.....
;
;
SENDC1:	  LDA	FCB+1
	  CPI	' '
	  JZ	BLKFILE
;
SENDC2:	  CALL	CNREC		;GET NUMBER OF RECORDS
	  CALL	OPENFIL
	  MVI	E,100
	  CALL	WAITNAK
;
SENDLP:	  CALL	CKABORT		;WANT TO TERMINATE WHLE SENDING FILE?
	  CALL	RDRECD
	  JC	SENDEOF
	  CALL	INCRRNO
	  MVI	A,1
	  STA	ERRCT
;
SENDRPT:  CALL	CKABORT		;WANT TO TERMINATE WHILE SENDING FILE?
	  CALL	SENDHDR
	  CALL	SENDREC
	  LDA	CRCFLAG
	  ORA	A
	  CZ	SENDCRC
	  CNZ	SENDCKS
	  CALL	GETACK
	  JC	SENDRPT
	  JMP	SENDLP
;.....
;
;
SENDEOF:  MVI	A,EOT
	  CALL	SEND
	  CALL	GETACK
	  JC	SENDEOF
	  JMP	DONE
;.....
;
;
;***********************************************************************
;
; RECEIVE A FILE
;
;***********************************************************************
;
;
RCVFIL:	  LDA	CKSUMDFLT	;GET MODE REQUESTED BY OPERATOR
	  STA	CRCFLAG		;STORE IT
;
RCVFIL1:  CALL	PARITY		;SET PARITY IF REQUESTED
	  LDA	BATCHFLG	;USING BATCH TRANSFER?
	  ORA	A
	  JNZ	RCVC1		;IF NOT, EXIT
	  MVI	A,FALSE		;FLAG WHERE TO RETURN..
	  STA	SENDFLG		;..FOR NEXT FILE TRANS.
	  CALL	GETFN		;GET THE FILE NAME.
	  JNC	RCVC2		;CARRY SET MEANS NO MORE FILES.
	  MVI	A,'B'		;STOP BATCH..
	  STA	BATCHFLG	;..MODE OPTION.
	  JMP	DONE
;...
;
;
RCVC1:	  LDA	FCB+1		;MAKE SURE FILE IS NAMED
	  CPI	' '
	  JZ	BLKFILE
	  JMP	RCVC3
;...
;
;
RCVC2:	  CALL	CKCPM2
	  CALL	CKBAKUP
;
RCVC3:	  CALL	ERASFIL
	  CALL	MAKEFIL
	  LDA	BATCHFLG	;USING BATCH TRANSFER?
	  ORA	A
	  JZ	RCVC4		;IF YES, DO NOT PRINT MESSAGE
	  CALL	ILPRT
	  DB	'File open, ready to receive',0
;
RCVC4:    LDA	CRCFLAG		;USING CRC MODE?
	  PUSH	PSW		;SAVE THE FLAG'S VALUE
	  ORA	A
	  JZ	RCVC5		;IF YES, EXIT
	  CALL	ILPRT		;OTHERWISE IN CHECKSUM MODE
	  DB	CR,LF,'CHECKSUM in effect',CR,LF,0
	  JMP	RCVC6
;...
;
;
RCVC5:	  CALL	ILPRT
	  DB	CR,LF,'CRC in effect',CR,LF,0
	  LDA	QFLG		;IN QUIET MODE NOW?
	  ORA	A
	  CZ	CRLF		;AN EXTRA CRLF FOR QUIET MODE
	  
;
RCVC6:	  POP	PSW		;GET THE FLAG'S VALUE BACK
	  ORA	A		;IN CRC MODE?
	  MVI	A,CRC
	  JZ	RCVC7		;IF YES, EXIT
	  MVI	A,NAK		;NAK FOR CHECKSUM MODE
;
RCVC7:	  CALL	SEND		;NOW SEND THE 'CRC' (OR 'NAK')
;
RCVLP:	  CALL	RCVRECD
	  JC	RCVEOT
	  CALL	WRRECD
	  CALL	INCRRNO
	  CALL	SENDACK
	  JMP	RCVLP
;.....
;
;
RCVEOT:	  CALL	WRBLOCK
	  CALL	SENDACK
	  CALL	CLOSFIL
	  JMP	DONE
;.....
;
;
;***********************************************************************
;
; FILE TRANSFER ROUTINE - CALLED WITH CONTROL-T FROM TERMINAL ROUTINE.
; TRANSFER MAY BE CANCELLED WHILE SENDING BY USING CONTROL-X.
;
;***********************************************************************
;
TRANSFER: PUSH	H
	  PUSH	D
	  PUSH	B
	  PUSH	PSW
	  LXI	H,FCB4
	  CALL	INITFCB		;INITIALIZES FCBS POINTED..
	  LXI	H,FCB+16	;..TO BY HL REG.
	  CALL	INITFCB
;
;
; GET NAME OF FILE TO SEND IN "T" (TERMINAL) MODE
;
GET:	  CALL	ILPRT
	  DB	CR,LF,'File name to send?   (RET to quit): ',0
	  LXI	D,CMDBUF
	  CALL	INBUF
	  LDA	CMDBUF+2	;WAS FILE ENTERED?
	  CPI	' '
	  JZ	TRANSL2
	  LXI	D,CMDBUF
	  LXI	H,FCB4
	  CALL	CMDLINE
	  LXI	D,FCB4
	  MVI	C,OPEN
	  CALL	BDOS
	  CPI	0FFH		;RETURN WITH 0FFH MEANS
	  JZ	TRANSL1		;FILE DOES NOT EXIST
;
;
; CHOICE OF NORMAL SPEED OR DELAYS BETWEEN CHARACTERS / LINES
;
	  CALL	ILPRT
	  DB	'Want to include time delays? (Y/N): ',0
	  CALL	KBDCHR
	  CPI	'N'		;IF 'N' SEND NORMAL SPEED
	  JZ	GET1
	  XRA	A		;OTHERWISE USE CHARACTER / LINE DELAYS
;
GET1:	  STA	DLYFLG		;STORE THE DECISION
	  CALL	CRLF	
	  LXI	D,80H
	  MVI	C,SETDMA
	  CALL	BDOS
;
;
; GET 128-BYTE RECORD
;
READMR:	  LXI	D,FCB4
	  MVI	C,READ
	  CALL	BDOS
	  CPI	1		;END OF FILE
	  JZ	RETURNS
	  CPI	2		;BAD READ
	  JZ	RETURNU
;
	  CALL	SEND80C		;SEND ONE 128-CHAR RECORD
;
	  CPI	EOFCHAR		;END OF FILE - OMIT IF OBJECT..
	  JZ	RETURNS		;..CODE IS TO BE SENT.
	  CPI	CAN		;CANCELLATION?
	  JNZ	READMR
;
TRANCAN:  CALL	ILPRT
	  DB	CR,LF,LF,'++ Transfer cancelled ++',CR,LF,BELL,0
;
RETURN:	  POP	PSW
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
RETURNS:  CALL	ILPRT
	  DB	CR,LF,'[Transfer completed]',CR,LF,BELL,0
	  JMP	RETURN
;.....
;
;
RETURNU:  CALL	ILPRT
	  DB	CR,LF,'++ File transfer unsuccessful ++',CR,LF,BELL,0
	  JMP	RETURN
;.....
;
;
TRANSL1:  CALL	ILPRT
	  DB	CR,LF,'++ No file with that name ++',CR,LF,0
;
TRANSL2:  CALL	ILPRT
	  DB	CR,LF,'"R" - return to modem',CR,LF
	  DB	'"A" - re-enter a name: ',BELL,0
	  CALL	KBDCHR
	  CPI	CR
	  JZ	TRANSL2
	  CALL	CRLF
	  CPI	'A'
	  JZ	GET		;GET A FILE NAME AND START OVER
	  CPI	'R'
	  JNZ	TRANSL2
	  JMP	RETURN		;IF AN 'R', ALL DONE
;.....
;
;
; SEND ONE 128-BYTE RCORD
;
SEND80C:  MVI	B,80H
	  LXI	H,80H
;
SENDCH1:  PUSH	D
	  CALL	SPEED		;0-90 MS. DELAY BETWEEN CHARACTERS
	  POP	D
	  MOV	A,M
	  CPI	LF		;LF CHAR?
	  JZ	SKIP22
	  CALL	MODOUT		;SEND THE CHARACTER TO MODEM
	  CPI	EOFCHAR
	  RZ
	  CALL	STAT		;TEST TO SEE IF
	  ORA	A		;CANCELLATION REQUESTED
	  JZ	SKIP12
	  CALL	KEYIN
	  CPI	CAN
	  RZ
;
SKIP12:	  INX	H
	  DCR	B
	  JNZ	SENDCH1
	  RET
;...
;
;
SKIP22:	  CALL	TYPE		;SHOW LF ON CRT, DO NOT SEND TO MODEM
	  JMP	SKIP12		;GET NEXT CHAR
;...
;
;
; Send the character to the output
;
MODOUT:	  PUSH	PSW
;
MODOUTL:  LDA	XOFFTST
	  ORA	A
	  CNZ	TXOFF	
	  CALL	SENDRDY
	  JNZ	MODOUTL
	  POP	PSW
	  CALL	OUT$MODDATP	;SEND CHARACTER TO MODEM
	  CALL	TYPE		;SEND CHARACTER TO CRT
	  CPI	CR		;WAS IT AN END OF LINE?
	  RNZ			;IF YES, GIVE A HEFTY DELAY
;
;
; Delay to allow slow BBS systems (most use BASIC) to enter the line.
; Choice of 0-9 for about 100 ms. each, maximum of 900 ms.
;
MODOUTN:  LDA	XONWAIT		;WAIT FOR XON AFTER CR ?
	  ORA	A
	  JNZ	WAITXON		;IF YES, HANDLE SEPARATELY
	  MVI	D,10
;
MODOUTT:  PUSH	D
	  CALL	SPEED1		;10 MS DELAY
	  POP	D
	  DCR	D
	  JNZ	MODOUTT		;10 LOOPS FOR 100 MS.
	  RET
;.....
;
;
; Add from 0 to 90 ms. delay between characters for slow (most use
; BASIC) bulletin board systems.  Also used to add 0-900 ms. delay
; between lines.
;
SPEED:	  LDA	BYTDLY		;GET DELAY BETWEEN CHARACTERS (0-9)
	  JMP	SPEED1+3	;1=10 MS, 5=50 MS, 9=90 MS, ETC.
;
SPEED1:	  LDA	CRDLY		;GET DELAY AFTER CRLF (0-9)
	  ORA	A		;100 MS, 5=500 MS, 9=900 MS, ETC.
	  RZ			;IF NO DELAY NEEDED, RETURN
	  MOV	C,A		;STORE NUMBER REQUESTED IN C-REG.
	  LDA	DLYFLG		;WANT ANY DELAYS THIS FILE?
	  ORA	A
	  RNZ			;IF NOT, SKIP THIS SECTION
;
SPEED2:	  CALL	SPEED3		;OUTER LOOP
	  DCR	C
	  JNZ	SPEED2
	  RET			;DONE WHENEVER THE C-REG. IS ZERO
;...
;
;
SPEED3:	  PUSH	H
	  LXI	H,14		;10 MILLISECONDS
	  LDA	XOFFTST
	  ORA	A
	  JZ	SPEED4
;
	  LXI	H,10		;7 MILLISECONDS  FOR XOFF TESTING
	  LDA	ECHOFLG
	  ORA	A
	  JZ	SPEED4
;
	  LDA	LOCFLG		;7 MILLISECONDS (SAME AS ECHOFLG)
	  ORA	A
	  JZ	SPEED4
;
	  LXI	H,75		;5 MILLISECONDS FOR REMOTE ECHO
;
SPEED4:	  CALL	FIXCNT		;MULTIPLY DELAY BY CLOCK SPEED
	  PUSH	H
	  POP	D		;GET THE HL-COUNT INTO DE PAIR
	  POP	H		;PUT STACK BACK TO NORMAL
;	
SPEED5:	  DCX	D		;INNER LOOP
	  LDA	XOFFTST
	  ORA	A
	  CNZ	TXOFF
	  MOV	A,E
	  ORA	D
	  JNZ	SPEED5
	  RET
;...
;
;
TXOFF:	  CALL	RCVREADY
	  RNZ
	  CALL	IN$MODDATP
	  ANI	7FH
	  CPI	XOFF
	  CZ	WAITXON
	  RET
;.....
;
;
WAITXON:  CALL	RCVREADY
	  JNZ	WAITXON
	  CALL	IN$MODDATP
	  ANI	7FH
	  CPI	XON
	  RZ
;
WTXON2:	  CALL	STAT		;TEST TO SEE IF REQUESTING CANCELLATION
	  ORA	A
	  JZ	WAITXON
	  CALL	KEYIN		;CAN ABORT IF THE X-ON NEVER COMES
	  CPI	CAN
	  JNZ	WAITXON
	  RZ
;.....
;
;
;***********************************************************************
;
; SUBROUTINES 
;
;***********************************************************************
;
SENDFN:	  CALL	ILPRT
	  DB	'Awaiting name NAK',CR,LF,0
	  MVI	E,100
	  CALL	WAITNLP
	  MVI	A,ACK		;GOT NAK, SEND ACK
	  CALL	SEND
	  LXI	H,FILECT
	  DCR	M
	  JM	NOMRNM
	  LHLD	NBSAVE		;GET FILE NAME..
	  LXI	D,FCB		;..IN FCB
	  MVI	B,12
	  CALL	MOVE
	  SHLD	NBSAVE
	  CALL	SENDNM		;SEND IT
	  ORA	A		;CLEAR CARRY
	  RET
;.....
;
;
NOMRNM:	  MVI	A,EOT
	  CALL	SEND
	  STC
	  RET
;.....
;
;
SENDNM:	  PUSH	H
;
SENDNM1:  MVI	D,11		;COUNT CHARS IN NAME
	  MVI	C,0		;INIT CHECKSUM
	  MOV	A,C
	  STA	FTYCNT		;INITIATE FILE TYPE COUNT
	  LXI	H,FCB+1		;ADDRESS NAME
;
NAMLPS:	  LDA	QFLG		;IN QUIET MODE NOW?
	  ORA	A
	  JNZ	SKPMON		;IF NOT, EXIT
	  LDA	NSEEFLG		;SET FLAG FOR NO SEND TO MODEM
;
SKPMON:   MOV	A,M		;SEND NAME
	  ANI	7FH		;STRIP HIGH ORDER BIT SO CP/M 2..
	  CALL	SEND		;..WON'T SEND R/O FILE DESIGNATION.
	  MVI	A,TRUE
	  STA	NSEEFLG
	  LDA	QFLG
	  ORA	A
	  MOV	A,M
	  CNZ	FTYTST		;TYPE CHARACTER ETC.
;
ACKLP:	  PUSH	B		;SAVE CKSUM
	  MVI	B,1		;WAIT FOR RECEIVER..
	  CALL	RECV		;..TO ACKNOWLEDGE..
	  POP	B		;..GETTING LETTER.
	  JC	SCKSER
	  CPI	ACK
	  JNZ	ACKLP
	  INX	H		;NEXT CHAR
	  DCR	D
	  JNZ	NAMLPS
	  MVI	A,EOFCHAR	;TELL RECEIVER END OF NAME
	  CALL	SEND
	  LDA	QFLG
	  ORA	A
	  CNZ	CRLF
	  MOV	D,C		;SAVE CHECKSUM
	  MVI	B,1
	  CALL	RECV		;GET CHECKSUM..
	  CMP	D		;..FROM RECEIVER.
	  JZ	NAMEOK
;
SCKSER:	  MVI	A,BDNMCH	;BAD NAME-TELL RECEIVER
	  CALL	SEND
	  CALL	ILPRT
	  DB	CR,LF,'++ CHECKSUM error ++',CR,LF,0
	  MVI	E,100	;DO HANDSHAKING OVER
	  CALL	WAITNLP		;DON'T PRINT "AWAITING NAK" MSG
	  MVI	A,ACK
	  CALL	SEND
	  JMP	SENDNM1
;.....
;
;
NAMEOK:	  MVI	A,OKNMCH	;GOOD NAME-TELL RECEIVER
	  CALL	SEND
	  POP	H
	  RET	
;.....
;
;
GETFN:	  LXI	H,FCB
	  CALL	INITFCB+2	;DOES NOT INITIALIZE DRIVE
	  CALL	ILPRT
	  DB	'Awaiting FILENAME',CR,LF,0
;
GNAMELP:  CALL	HSNAK
	  JC	GNAMELP
	  CALL	GETNM		;GET THE NAME
	  CPI	EOT		;IF EOT, THEN NO MORE FILES
	  JZ	NOMRNMG
	  ORA	A		;CLEAR CARRY
	  RET
;.....
;
;
NOMRNMG:  STC
	  RET
;.....
;
;
GETNM:	  PUSH	H
;
GETNM1:	  MVI	C,0		;INIT CHECKSUM
	  MOV	A,C
	  STA	FTYCNT		;INITIATE COUNT FOR FILE TYPE
	  LXI	H,FCB+1
;
NAMELPG:  MVI	B,5		;WAIT AWHILE FOR FILE NAME
	  CALL	RECV		;GET CHAR
	  JNC	GETNM2
	  CALL	ILPRT
	  DB	CR,LF,'Time out receiving FILENAME',CR,LF,0
	  JMP	GCKSER
;.....
;
;
GETNM2:	  CPI	EOT		;IF EOT, THEN NO MORE FILES
	  JZ	GNRET
	  CPI	EOFCHAR		;GOT END OF NAME
	  JZ	ENDNAME
	  MOV	M,A		;PUT NAME IN FCB
	  CALL	FTYTST
	  PUSH	B		;SAVE CKSUM
	  MVI	A,ACK		;ACK GETTING LETTERS
	  CALL	SEND
	  POP	B
	  INX	H		;GET NEXT CHAR
	  MOV	A,L		;DON'T LET NOISE...
	  CPI	7FH		;..CAUSE OVERFLOW..
	  JZ	GCKSER		;..INTO PROGRAM AREA.
	  JMP	NAMELPG
;.....
;
;
FTYTST:	  LDA	FTYCNT
	  INR	A
	  STA	FTYCNT
	  CPI	9		;ARE WE AT THE FILE TYPE?
	  JZ	SPCTST		;GO IF SO
;
ENDSPT:	  MOV	A,M
	  CPI	' '		;TEST FOR SPACE
	  CNZ	TYPE		;TYPE IF NOT
	  RET
;.....
;
;
SPCTST:	  MOV	A,M
	  CPI	' '		;TEST FOR SPACE IN FIRST FILE TYPE BYTE
	  RZ			;DON'T OUTPUT PERIOD IF SPACE
	  MVI	A,'.'	
	  CALL	TYPE
	  JMP	ENDSPT		;OUTPUT FIRST FILE TYPE BYTE
;.....
;
;
ENDNAME:  LDA	QFLG
	  ORA	A
	  CNZ	CRLF
	  MOV	A,C		;SEND CHECKSUM
	  CALL	SEND
	  MVI	B,1
	  CALL	RECV		;CHECKSUM GOOD?
	  CPI	OKNMCH		;YES IF OKNMCH SENT..
	  JZ	GNRET		;..ELSE DO OVER.
;
GCKSER:	  LXI	H,FCB		;CLEAR FCB (EXCEPT DRIVE)..
	  CALL	INITFCB+2	;..SINCE IT MIGHT BE DAMAGED..
	  CALL	ILPRT
	  DB	CR,LF,'++ CHECKSUM error ++',CR,LF,0
;
GCKSER1:  CALL	HSNAK		;DO HANDSHAKING OVER
	  JC	GCKSER1
	  JMP	GETNM1
;...
;
;
GNRET:	  POP	H
	  RET
;.....
;
;
HSNAK:	  MVI	A,NAK		;SEND NAK UNTIL..
	  CALL	SEND		;..RECEIVING ACK.
	  CALL	CKABORT		;DON'T GET HUNG UP HERE
	  MVI	B,2		;WAIT 2 SECONDS..
	  CALL	RECV		;..IN RECEIVE.
	  CPI	ACK		;IF ACK,RETURN WITH..
	  RZ			;..CARRY CLEAR.
	  STC
	  RET
;.....
;
;
TNMBUF:	  MVI	A,FALSE		;CALL FROM SENDFIL ONLY ONCE.
	  STA	FSTFLG
	  STA	FILECT
	  CALL	SCAN
	  LXI	H,NAMEBUF
	  SHLD	NBSAVE		;SAVE ADDR OF 1ST NAME
;
TNLP1:	  CALL	TRTOBUF
	  LXI	H,FCB
	  LXI	D,FCBBUF
	  CALL	CMDLINE		;PARSE NAME TO CP/M FORMAT
;
TNLP2:	  CALL	MFNAME		;SEARCH FOR NAMES (* FORMAT)
	  JC	NEXTNM
	  LDA	FCB+10		;IF CP/M 2 $SYS FILE..
	  ANI	80H		;..DON'T SEND
	  JNZ	TNLP2
	  LHLD	NBSAVE		;GET NAME
	  LXI	D,FCB		;MOVE IT TO FCB
	  XCHG
	  MVI	B,12
	  CALL	MOVE
	  XCHG
	  SHLD	NBSAVE		;ADDR OF NEXT NAME
	  LXI	H,FILECT	;COUNT FILES FOUND
	  INR	M
	  JMP	TNLP2
;.....
;
;
NEXTNM:	  LXI	H,NAMECT	;COUNT NAMES FOUND
	  DCR	M
	  JNZ	TNLP1
	  LXI	H,NAMEBUF	;SAVE START OF BUFFER
	  SHLD	NBSAVE
	  LDA	FILECT
	  CPI	64+1		;NO MORE THAN 64 TRANSFERS
	  RC
	  MVI	A,64		;ONLY X'FER FIRST 64
	  STA	FILECT
	  RET
;.....
;
;
BUFMSG:	  CALL	ILPRT
	  DB	CR,LF,'** Memory buffer ',0
	  LDA	SAVEFLG
	  ORA	A
	  JZ	BUFMSG2
	  CALL	ILPRT
	  DB	'open **',CR,LF,':',BELL,0
	  RET
;.....
;
;
BUFMSG2:  CALL	ILPRT
	  DB	'closed **',CR,LF,BELL,0
	  RET
;.....
;
;
EXITMEN:  CALL	CRLF
	  CALL	CLREOS		;CLEAR LINE TO CLEAN UP ANY MESS
	  JMP	MENU0
;.....
;
;
SENDRDY:  CALL	IN$MODCTLP
	  CALL	ANI$MODSNDB
	  JMP	CPI$MODSNDR
;.....
;
;
SENDLF:	  CALL	SENDRDY
	  JNZ	NOLFYET		;GO IF NOT READY FOR OUTPUT YET
	  MVI	A,LF
	  JMP	NOTOG		;SEND LF
;.....
;
;
NOLFYET:  CALL	EXITTEST
	  JNC	EXITMEN		;GO IF SO, SO DON'T GET HUNG UP
	  JMP	SENDLF		;ELSE KEEP TRYING TO SEND LF
;.....
;
;
SENDLOG:  PUSH	H
	  LHLD	LOGONPTR	;HL POINTS TO START OF LOGON MESSAGE
;
LOGLP:	  CALL	SENDRDY
	  JNZ	NOSENLOG	;GO IF NOT READY
	  MOV	A,M		;GET LOGON BYTE
	  INX	H
	  CPI	0		;IS IT THE END?
	  JZ	ENDLOG		;GO IF SO
	  CALL	OUT$MODDATP
	  JMP	LOGLP
;...
;
;
NOSENLOG: CALL	EXITTEST	;TEST SO DON'T GET HUNG UP
	  JNC	EXITLOG		;GO IF OPERATOR WANTS EXIT
	  JMP	LOGLP
;...
;
;
ENDLOG:	  POP	H
	  JMP	TERML
;.....
;
;
EXITLOG:  POP	H
	  JMP	EXITMEN
;.....
;
;
EXITTEST: CALL	STAT		;KEYPRESS?
	  JZ	NOKEY
	  CALL	KEYIN	
	  MOV	B,A
	  LDA	EXITCHR		;SEE IF OPERATOR WANTS EXIT
	  CMP	B
	  JNZ	NOKEY		;GO IF WRONG KEY		
	  STC
	  CMC			;RESET FOR EXIT
	  RET
;.....
;
;
NOKEY:	  STC			;SET FOR NO KEY OR WRONG KEY
	  RET
;.....
;
;
EXTFLG:	MVI	A,TRUE
	STA	EXACFLG
	JMP	TERML
;.....
;
;
RCVREADY: CALL	IN$MODCTLP
	  CALL	ANI$MODRCVB
	  JMP	CPI$MODRCVR
;.....
;
;
LSTMSG:	  LDA	LISTFLG		;SEE IF PRINTER SHOULD BE ON OR OFF
	  ORA	A
	  JZ	LSTMSG2
	  CALL	ILPRT
	  DB	'Printer is on',CR,LF,0
	  RET
;.....
;
;

LSTMSG2:  CALL	ILPRT
	  DB	'Printer is off',CR,LF,0
	  RET
;.....
;
;
NOTOG:	  CALL	OUT$MODDATP
	  MOV	B,A
	  LDA	LOCFLG
	  ORA	A
	  JNZ	LTYPE
	  LDA	ECHOFLG
	  ORA	A
	  JZ	CHKCR
;
LTYPE:	  MOV	A,B
	  CALL	TYPE
	  CALL	CHKSAVE		;TO STORE LOCAL IF BUFFER OPEN
	  CALL	CHKPRNT
;
CHKCR:	  MVI	A,CR
	  CMP	B
	  JNZ	TERML
	  LDA	ADDLF
	  ORA	A
	  JZ	TERML
	  JMP	SENDLF
;.....
;
;
;
TERML:	  CALL	RCVREADY	;TEST FOR RECEIVED CHARACTER
	  JNZ	TERM2
	  CALL	IN$MODDATP
	  ANI	7FH		;STRIP PARITY
	  JZ	TERM2		
;
GIVLF:	  CALL	TYPE
	  MOV	B,A
	  CALL	CHKSAVE
	  CALL	CHKPRNT
	  LDA	ECHOFLG
	  ORA	A
	  JZ	NOECHO
	  MOV	A,B
	  CALL	OUT$MODDATP
;
NOECHO:	  MVI	A,CR
	  CMP	B
	  JNZ	TERM2
	  LDA	ADDLF
	  JZ	TERM2
	  LDA	ECHOFLG
	  ORA	A
	  JNZ	SENDLF
	  MVI	A,LF
	  JMP	GIVLF
;
CHKSAVE:  LDA	SAVEFLG
	  ORA	A
	  RZ
	  MOV	M,B
	  INX	H
	  SHLD	HLSAVE		;MENU COMMAND DESTROYS HL-REG..
	  MVI	A,LF
	  CMP	B
	  JNZ	NOCOLON		;..TYPE ":" AFTER EACH LINE FEED..
	  MVI	A,':'		;..WHEN MEMORY SAVE ACTIVE.
	  CALL	TYPE
;
NOCOLON:  CALL	GETMAX
	  CMP	H
	  PUSH	B
	  CZ	INTDSKSV
	  POP	B
	  RET
;.....
;
;
GETMAX:	  LDA	SAVCCP
	  ORA	A
	  LDA	7
	  JZ	SUB1
	  SBI	8		;..PAGE BELOW CCP ..
;				;..ORA BDOS HAS BEEN..
SUB1:	  DCR	A		;..REACHED AND DISKSAVE IS NEEDED
	  RET
;.....
;
;
CHKPRNT:  LDA	LISTFLG		;OUT TO PRINTER?
	  ORA	A
	  RZ			;RETURN IF NOT
	  LDA	NFILFLG		;IS BUFFER USED FOR FILE?
	  ORA	A		;IF YES DON'T BUFFER PRINTER, HOWEVER..
	  CALL	GETMAX		;..CHARACTERS WILL BE LOST IF PRINTER
	  LHLD	HLSAVE1		;..SLOWER THAN MODEM	
	  CMP	H		;ARE WE THERE?
	  JNZ	NOTMAX		;GO IF NOT
	  LXI	H,BOTTRAM	;FLUSH BUFFER
	  SHLD	HLSAVE1
	  SHLD	HLSAVE2
;
NOTMAX:	  MOV	M,B		;SAVE CHARACTER IN BUFFER
	  INX	H		;INCREMENT END OF BUFFER
	  SHLD	HLSAVE1
	  MVI	A,TRUE		;SET FLAG FOR PRINTER OUTPUT
	  STA	LISTMOR
	  RET
;.....
;
;
NOBUFF:	  CALL	LSTSTAT	
	  ORA	A
	  RZ			;RETURN IF PRINTER NOT READY
	  MOV	C,B		;ELSE PRINT CHARACTER
	  JMP	LISTER
;
GOLIST:	  CALL	LSTSTAT
	  ORA	A
	  RZ			;RETURN IF PRINTER NOT READY
	  LHLD	HLSAVE2		;GET LOCATION OF NEXT CHARACTER TO PRINT
	  MOV	C,M		;GET CHARACTER
	  INX	H		;INCREMENT POINTER
	  SHLD	HLSAVE2
	  CALL	CMPBUFF		;CHECK FOR END OF BUFFER
	  JMP	LISTER		;PRINT
;
;
; ROUTINE CHECKS FOR END OF BUFFER, RESETS BUFFER IF SO AND STOPS THE
; PRINTER OUTPUT
;
CMPBUFF:  LHLD	HLSAVE2
	  XCHG
	  LHLD	HLSAVE1
	  MOV	A,L
	  SUB	E
	  MOV	L,A
	  MOV	A,H
	  SBB	D
	  ORA	L
	  RNZ
	  LXI	H,BOTTRAM
	  SHLD	HLSAVE1
	  SHLD	HLSAVE2
	  XRA	A
	  STA	LISTMOR
	  RET
;.....
;
;
INTDSKSV: MVI	A,XOFF		;SEND A CTL-S TO STOP..
	  CALL	OUT$MODDATP	;..REMOTE COMPUTER OUTPUT.
	  MVI	D,0		;D IS THE BUFFER COUNT
	  CALL	INMODEM		;GET LAST BYTES SENT..
	  STA	LASTBYT1	;..AFTER CTL-S.
	  CALL	INMODEM		;ADD MORE CALLS TO INMODEM..
	  STA	LASTBYT2	;..AND STA LASTBYT# IF YOU ARE..
	  PUSH	D
	  CALL	NUMREC1		;GET NUMBER OF RECORDS TO PUT ON DISK
	  CALL	WRTDSK		;WRITE THE RECORDS
	  POP	D
	  LXI	H,BOTTRAM
	  INR	D
	  DCR	D		;TEST BUFFER COUNT FOR ZERO
	  JZ	CTLQ
	  LDA	LASTBYT1	;GET THE LAST BYTES THAT WERE..
	  MOV	M,A		;..SAVED AND PUT THEM IN..
	  INX	H		;..BOTTRAM.
	  CALL	TYPE
	  DCR	D
	  JZ	CTLQ
	  LDA	LASTBYT2
	  MOV	M,A
	  INX	H
	  CALL	TYPE
;
CTLQ:	  MVI	A,XON		;SEND START CHARACTER..
	  JMP	OUT$MODDATP	;..TO REMOTE COMPUTER.
;.....
;
;
BREAK:	  PUSH	D		;SAVE IT
	  LXI	D,0		;ZERO IT
	  LDA	MODCTLB		;GET THE LAST MODEM CONTROL BYTE
	  ANI	BRKMSK		;SET THE TRANSMIT BREAK BIT LOW
	  CALL	OUT$MODCTL2 	;SEND IT TO THE MODEM
	  PUSH	H
	  LXI	H,48		;100 MS. BREAK
	  CALL	FIXCNT
	  PUSH	H
	  POP	B
	  POP	H
;
BRK1:	  CALL	TIMERL
	  JZ	BRK2		;IF TIME IS UP RESET BREAK
	  CPI	0		;CHECK FOR NULLS
	  JZ	BRK1		;DON'T PROCESS THEM
	  ANI	7FH		;STRIP PARITY
	  CALL	TYPE
	  PUSH	PSW
	  LDA	SAVEFLG
	  CPI	FALSE
	  JZ	NOSAVEB
	  POP	PSW
	  MOV	M,A
	  INX	H
	  SHLD	HLSAVE		;MENU COMMAND DESTROYS HL-REG..
;				;..GET	HL WHEN ENTERING VIA 'NOL' CMD.
COLONB:   CPI	LF
	  JNZ	BRK1		;..TYPE ":" AFTER EACH LINE FEED..
	  MVI	A,':'		;..WHEN MEMORY SAVE ACTIVE.
	  CALL	TYPE
	  JMP	BRK1
;...
;
;
NOSAVEB:  POP	PSW		;RESTORE IT
	  JMP	BRK1
;...
;
;
BRK2:	  LDA	MODCTLB		;GET MODEM CONTROL BYTE
	  CALL	OUT$MODCTL2
	  POP	D
	  LHLD	HLSAVE		;LAST ADDRESS WRITTEN IF DATA BEING SAVED
	  LDA	SAVCCP
	  ORA	A
	  JZ	SUB2
	  LDA	7		;CHECK TO SEE IF..
	  SBI	8		;..PAGE BELOW CCP ..
	  JMP	SUB2A
;...
;
;
SUB2:	  LDA	7
;
SUB2A:	  DCR	A		;..OR BDOS HAS BEEN ..
	  CMP	H		;..REACHED AND DISKSAVE IS NEEDED.
	  JNZ	TERM2		;NO PROBLEM - GO BACK TO NORMAL ROUTINE
	  CALL	ILPRT
	  DB	CR,LF,'Memory-save buffer full',CR,LF,BELL,0
	  JMP	TERM2
;.....
;
;
; THIS SUBROUTINE WILL LOOP UNTIL THE MODEM RECEIVES A CHARACTER OR 100
; MILLISECONDS.  IF A CHARACTER IS RECEIVED, A FLAG IS SET TO STORE THE
; CHARACTER.  A MAXIMUM OF TWO CHARACTERS ARE STORED, BUT MORE MAY BE
; STORED IF DESIRED (SEE COMMENT IN "INTDSKSV" ABOVE).
;
INMODEM:  PUSH	H
	  LXI	H,48		;100 MILLISECONDS
	  CALL	FIXCNT
	  PUSH	H
	  POP	B
	  POP	H
;
TIMERL:	  CALL	RCVREADY
	  JZ	GETBYTE
	  DCX	B
	  MOV	A,B
	  ORA	C
	  JNZ	TIMERL
	  RET
;.....
;
;
GETBYTE:
	  CALL	IN$MODDATP
	  INR	D
	  RET
;.....
;
;
NUMRECS:
	  MVI	M,EOFCHAR
	  INX	H
	  LXI	D,127
	  DAD	D
;
NUMREC1:  LXI	D,-(BOTTRAM)
	  DAD	D
	  MOV	A,L		;DIVIDE HL BY 128..
	  ORA	A
	  RAL			;..TO GET THE..
	  MOV	L,H		;..NUMBER OF RECORDS
	  MVI	H,0
	  PUSH	PSW
	  DAD	H
	  POP	PSW
	  MVI	A,0
	  ADC	L
	  MOV	L,A		;RETURNS WITH NUMBER OF..
	  RET			;..128 BYTE RECORDS IN HL.
;.....
;
;
; WRITE TO DISK BUT FIRST CHECK TO SEE IF ANYTHING TO WRITE.  IF NOT,
; CLOSE THE EMPTY FILE.
;
WRTDSK:	  LXI	D,BOTTRAM	;GET FIRST CHARACTER
	  LDAX	D		;GET THE CHARACTER AT START OF BUFFER
	  CPI	EOFCHAR		;END OF FILE CHARACTER?
	  JZ	NOWRITE		;DO NOT WRITE IF NO DATA TO STORE
	  MOV	A,H		;MAKE SURE THERE IS SOMETHING TO STORE
	  ORA	L
	  JZ	NOWRITE		;DO NOT WRITE IF NO DATA TO STORE
;
NEXTWRT:  MVI	C,SETDMA
	  CALL	BDOSRT
	  PUSH	D
	  LXI	D,FCB3
	  MVI	C,WRITE
	  CALL	BDOSRT
	  POP	D
	  XCHG
	  PUSH	D
	  LXI	D,128
	  DAD	D
	  POP	D
	  XCHG
	  DCX	H
	  MOV	A,H
	  ORA	L
	  JNZ	NEXTWRT
	  RET
;.....
;
;
; IF NO DATA TO STORE ON DISK, CLOSE THE EMPTY FILE AND ERASE IT
;
NOWRITE:  CALL  CLOSFIL		;CLOSE THE EMPTY FILE
	  CALL	NOASK		;ERASE THE EMPTY FILE
	  CALL	ILPRT
	  DB	'++ Nothing to save, erasing the file ++'
	  DB    CR,LF,BELL,0
	  JMP	DONETCA		;RESET ANY FLAGS, RETURN TO MENU
;.....
;
;
CLOSE3:	  LXI	D,FCB3
	  MVI	C,CLOSE
	  JMP	BDOS
;.....
;
;
BDOSRT:	  PUSH	B
	  PUSH	D
	  PUSH	H
	  PUSH	PSW
	  CALL	BDOS
	  POP	PSW
	  POP	H
	  POP	D
	  POP	B
	  RET
;
MOVE2:	  LXI	H,FCB3
	  CALL	INITFCB
	  LXI	H,FCB
	  LXI	D,FCB3
	  MVI	B,12
	  JMP	MOVE
;.....
;
;
INITFCB:  MVI	M,0		;ENTRY AT +2 WILL LEAVE DRIVE NO. INTACT
	  INX	H		;WILL INITIALIZE AN FCB..
	  MVI	B,11		;..POINTED TO BY HL-REG. FILLS 1ST POS
;
LOOP10:	  MVI	M,' '		;..WITH 0, NEXT 11 WITH..
	  INX	H		;..WITH BLANKS, AND LAST..
	  DCR	B		;..21 WITH NULLS.
	  JNZ	LOOP10
	  MVI	B,21
;
LOOP11:	  MVI	M,0
	  INX	H
	  DCR	B
	  JNZ	LOOP11
	  RET
;.....
;
;
; SCANS CMDBUF COUNTING NAMES AND PUTTING DELIMITER (SPACE) AFTER LAST
; NAME
;
SCAN:	  PUSH	H
	  LXI	H,NAMECT
	  MVI	M,0
	  LXI	H,CMDBUF+1	;FIND END OF CMD LINE..
	  MOV	C,M		;..AND PUT SPACE THERE.
	  MVI	B,0
	  LXI	H,CMDBUF+2
	  DAD	B
	  MVI	M,' '
	  LXI	H,CMDBUF+1
	  MOV	B,M
	  INR	B
	  INR	B
;
SCANLP1:  INX	H
	  DCR	B
	  JZ	DNSCAN
	  MOV	A,M
	  CPI	' '
	  JNZ	SCANLP1
;
SCANLP2:  INX	H		;EAT EXTRA SPACES
	  DCR	B
	  JZ	DNSCAN
	  MOV	A,M
	  CPI	' '
	  JZ	SCANLP2
	  SHLD	BGNMS		;SAVE START OF NAMES IN CMDBUF
	  INR	B
	  DCX	H
;
SCANLP3:  INX	H
	  DCR	B
	  JZ	DNSCAN
	  MOV	A,M
	  CPI	' '
	  JNZ	SCANLP3
	  LDA	NAMECT		;COUNTS NAMES
	  INR	A
	  STA	NAMECT
;
SCANLP4:  INX	H		;EAT SPACES
	  DCR	B
	  JZ	DNSCAN
	  MOV	A,M
	  CPI	' '
	  JZ	SCANLP4
	  JMP	SCANLP3
;.....
;
;
DNSCAN:	  MVI	M,' '		;SPACE AFTER LAST CHAR
	  POP	H
	  RET
;.....
;
;
; PLACES NEXT NAME IN BUFFER SO 'CMDLINE' MAY PARSE IT
;
TRTOBUF:  LHLD	BGNMS
	  MVI	B,0
	  LXI	D,FCBBUF+2
;
TBLP:	  MOV	A,M
	  CPI	' '
	  JZ	TRBFEND
	  STAX	D
	  INX	H
	  INX	D
	  INR	B		;COUNT CHARS IN NAME
	  JMP	TBLP
;.....
;
;
TRBFEND:  INX	H
	  MOV	A,M		;EAT EXTRA SPACES
	  CPI	' '
	  JZ	TRBFEND
	  SHLD	BGNMS
	  LXI	H,FCBBUF+1	;PUT # CHARS BEFORE NAME
	  MOV	M,B
	  RET
;.....
;
;
; IN CP/M V.2, IF FILE IS R/O OR SYS, IT IS CHANGED TO 'BAK'.
;
CKCPM2:	  MVI	C,CPMVER	;BDOS 12 -- VERSION NUMBER -- CP/M 2.2?
	  CALL	BDOS
	  ORA	A	
	  RZ
	  MVI	C,SETDMA
	  LXI	D,80H
	  CALL	BDOS
	  MVI	C,SRCHF
	  LXI	D,FCB
	  CALL	BDOS
	  CPI	0FFH
	  RZ
;
	  ADD	A
	  ADD	A
	  ADD	A
	  ADD	A		;..32 TO FIND..
	  ADD	A		;..NAME IN DMA.
	  LXI	H,80H
	  ADD	L
	  MOV	L,A		;'HL' POINTS TO DIRECTORY NAME
	  LXI	D,9
	  DAD	D		;POINT TO R/O ATTRIBUTE BYTE
	  MOV	A,M
	  ANI	80H		;TEST MOST SIGNIFICANT BYTE
	  JNZ	MKCHG		;IF SET, MAKE CHANGE
	  INX	H		;CHECK SYSTEM ATTRIBUTE BYTE
	  MOV	A,M
	  ANI	80H
	  RZ			;NOT $SYS OR $R/O ATTRIBUTE
	  DCX	H
;
MKCHG:	  LXI	D,-8
	  DAD	D		;POINT HL TO FILENAME + 1
	  LXI	D,FCB+1		;MOVE DIRECTORY NAME TO FCB..
	  MVI	B,11		;..WITHOUT CHANGING DRIVE.
	  CALL	MOVE
	  LXI	H,FCB+9		;R/O ATTRIBUTE
	  MOV	A,M
	  ANI	7FH		;STRIP R/O ATTRIBUTE
	  MOV	M,A
	  INX	H		;SYSTEM ATTRIBUTE
	  MOV	A,M
	  ANI	7FH
	  MOV	M,A
	  LXI	D,FCB
	  MVI	C,30		;SET NEW ATTRIBUTES IN DIRECTORY
	  CALL	BDOS
;
;
; CALLED BY CKBAKUP BELOW, RETURN DONE HERE THROUGH BDOS JUMP
;
PLANCHG:  LXI	H,FCB		;CHANGE NAME TO TYPE "BAK"
	  LXI	D,FCB2
	  MVI	B,9		;MOVE DRIVE AND NAME (NOT TYPE)
	  CALL	MOVE
	  LXI	H,75H		;START OF TYPE IN FCB2
	  MVI	M,'B'
	  INX	H
	  MVI	M,'A'
	  INX	H
	  MVI	M,'K'
	  LXI	D,FCB2
	  MVI	C,ERASE		;ERASE ANY PREV BACKUPS
	  CALL	BDOS
	  LXI	H,FCB2		;FCB2 DR FIELD SHOULD..
	  MVI	M,0		;..0 FOR RENAME.
	  LXI	D,FCB
	  MVI	C,23		;RENAME
	  JMP	BDOS
;.....
;
;
CKBAKUP:  LDA	BAKUPBYTE
	  ORA	A
	  RZ
	  MVI	C,SRCHF
	  LXI	D,FCB
	  CALL	BDOS
	  INR	A
	  RZ			;FILE NOT FOUND
	  JMP	PLANCHG		;IN "CKCPM2" - RET DONE THERE
;.....
;
;
;***********************************************************************
;
; RECEIVE A RECORD FROM SENDING STATION
;
;***********************************************************************
;
;
RCVRECD:  MVI	A,1
	  STA	ERRCT
	  XRA	A
	  STA	ONERR
;
RCVRPT:	  XRA	A		;ZERO ACCUM
	  STA	ERRCDE		;CLEAR RECEIVE ERROR CODE
	  
	  CALL	CKABORT		;WANT TO STOP RECEIVING FILE?
	  LDA	QFLG
	  ORA	A
	  JZ	RCVSQ
	  CALL	ILPRT
	  DB	CR,'Awaiting # ',0
	  PUSH	H		;SAVE IT
	  LHLD	RECDNO		;GET RECORD NUMBER
	  INX	H		;BUMP IT
	  CALL	DECOUT		;PRINT RECORD NUMBER IN DECIMAL
	  CALL	ILPRT
	  DB	' (', 0
	  CALL	DHXOUT		;16-BIT HEX CONVERSION AND OUTPUT
	  CALL	ILPRT
	  DB	'H) ',0
	  MOV	A,L		;ONLY LOW BYTE USED BY PROGRAM
	  POP	H		;RESTORE IT
;
;
; If CRC is in effect, there is a 10-second timeout to the first SOH.
; It then tries several more times to let the sender know the system is
; capable of receiving a CRC check.  At the end of that time a NAK is
; sent which tells the sender to use CHECKSUM checking instead of CRC.
; This allows automatic compatability with systems implementing CRC -
; (Cyclic Redundancy Checking).
;
; During this time incoming CRC and NAK characters are ignored as these
; may be the ones we are sending at each timeout, coming back from the
; full duplex system.
;
RCVSQ:	  MVI	B,10-1		;10-SECOND WAIT FOR 'SOH' OR 'EOT' CHAR.
	  CALL	RECV		;..(EXTRA 1 SECOND FROM RCVSERR)
	  JC	RCVSTOT		;SEND TIMEOUT MSG IF NO CHAR. IN 10 SEC.
	  CALL	RCVERR		;SEE IF IT WAS AN I/O ERROR
	  CPI	SOH		;GET A START OF HEADER?
	  JZ	RCVSOH
	  ORA	A
	  JZ	RCVSQ
	  CPI	CRC		;IGNORE OUR OWN 'CRC' CHAR. IF ANY
	  JZ	RCVSQ		;DO NOT COUNT THIS AS A TIMEOUT
	  CPI	NAK		;IGNORE OUR OWN 'NAK' CHAR. IF ANY
	  JZ	RCVSQ		;DO NOT COUNT THIS AS A TIMEOUT
	  CPI	EOT
	  STC
	  RZ
;
	  MOV	B,A
	  LDA	BATCHFLG	;USING BATCH MODE NOW?
	  ORA	A
	  JNZ	RCVSQ1		;IF NOT, EXIT
	  LDA	ONERR		;THIS THE FIRST ERROR THIS TRANSFER?
	  ORA	A
	  JNZ	RCVSQ1		;IF NOT, HANDLE NORMALLY^
	  STA	ERRCT		;RESET THE ERROR COUT TO EXCLUDE THIS
	  CMA			;IF YES, IGNORE THIS ERROR
	  STA	ONERR		;SET THE FLAG
	  JMP	RCVSERR	
;
RCVSQ1:   CALL	RCVQERR		;SEE IF QUIET MODE
;
RCVSQ2:	  MOV	A,B
	  CALL	CRLF
	  CALL	HEXO
	  CALL	ILPRT
	  DB	'H received not SOH - ',0
;
RCVPRN:	  CALL	SHOWERR		;DISPLAY ERROR COUNT
;
RCVSERR:  MVI	B,1		;1 SECOND WAIT AFTER ANY CHAR. IS SENT..
	  CALL	RECV		;..TO INSURE SENDER IS WAITING TO COPY
	  JNC	RCVSERR 	;IF STILL SENDING, IGNORE ALL CHARS.
	  CALL	CKABORT		;WANT TO STOP RECEIVING NOW?
	  LDA	CRCFLAG		;GET 'CRC' FLAG
	  ORA	A		;'CRC' IN EFFECT?
	  MVI	A,NAK		;PUT 'NAK' IN ACCUM
	  JNZ	RCVSER1		;NO, SEND THE 'NAK'
	  LDA	FIRSTME 	;GET FIRST TIME SWITCH
	  ORA	A		;HAS FIRST SOH BEEN RECEIVED?
	  MVI	A,NAK
	  JZ	RCVSER1		;YES, THEN SEND 'NAK'
	  MVI	A,CRC		;TELL SENDER 'CRC' IS IN EFFECT
;
RCVSER1:  CALL	SEND		;SEND THE 'NAK' OR 'CRC' REQUEST
	  LDA	ERRCT		;INCREMENT THE  ERROR COUNT
	  INR	A
	  STA	ERRCT
	  CPI	10+1		;IF 10 ALREADY, ABORT
	  JC	RCVRPT		;IF LESS THAN 10, KEEP GOING
	  JMP	ABORT
;.....
;
;
RCVQERR:  LDA	QFLG		;SEE IF QUIET MODE NOW
	  ORA	A
	  RNZ			;IF NOT, PROCEED NORMALLY
	  POP	H		;RESET STACK FOR 'CALL'
	  JMP	RCVSERR
;.....
;
;
RCVSABT:  LXI	SP,STACK	;RESET THE STACK JUST IN CASE
	  CALL	CLOSFIL		;CLOSE THE PARTIAL FILE
	  CALL	NOASK		;DELETE PARTIAL FILE
	  CALL	ILPRT
	  DB	CR,LF,LF
	  DB	'++ RECEIVED FILE CANCELLED ++',CR,LF,BELL
	  DB	'++ UNFINISHED FILE DELETED ++',CR,LF,0
	  JMP	DONETCA
;.....
;
;
; TIMEOUT ROUTINE EACH 10 SECONDS OF NO 'SOH' (START-OF-HEADER)
;
RCVSTOT:  MVI	A,TRUE
	  STA	ONERR
	  LDA	QFLG
	  ORA	A
	  JZ	RCVSTOT1
	  CALL	ILPRT
	  DB	CR,LF,'++ Timeout ',0
	  CALL	SHOWERR		;DISPLAY THE CURRENT ERROR COUNT
;
;
; ROUTINE WILL SWITCH FROM CRC TO CHECKSUM IF ERCNT REACHES ERRCRC AND
; CURRENTLY IN CRC MODE.
;
RCVSTOT1: LDA	ERRCT		;GET THE ERROR COUNT
	  CPI	ERRCRC		;SEE IF LESS THAN CRC-ERROR TRY LIMIT
	  JC	RCVSTOT2	;IF YES, KEEP TRYING
	  LDA	FIRSTME		;OTHERWISE SEE IF WE ALREADY GOT A SOH
	  ORA	A
	  JZ	RCVSTOT2	;IF YES, DON'T SWITCH TO CHECKSUM
	  LDA	CRCFLAG		;IF NOT, SEE IF ALREADY IN CHECKSUM
	  ORA	A
	  JNZ	RCVSTOT2
	  MVI	A,TRUE		;SHOW IN CHECKSUM NOW
	  STA	CRCFLAG		;CHANGE FROM CRC TO CHECKSUM
	  STA	CKSUMDFLT	;OPTION FLAG NOW SHOWS CHECKSUM...
	  CALL	ILPRT		;...FOR FUTURE FILES
	  DB	'++ Switching to CHECKSUM mode ++',CR,LF,BELL,0
;
RCVSTOT2: JMP	RCVSERR		;INCREMENT ERROR COUNT
;.....
;
;
; GET THE ERROR COUNT AND DISPLAY ON CRT
;
SHOWERR:  PUSH	H		;SAVE THE CURRENT ADDRESS
	  LHLD	ERRCT		;GET THE CURRENT ERROR NUMBER
	  MVI	H,0		;ONLY A 8-BIT NUMBER, NOW IN 'L' REG.
	  CALL	DECOUT		;DISPLAY THE ERROR IN DECIMAL
	  POP	H		;RESTORE THE CURRENT ADDRESS
	  CALL	ILPRT
	  DB	' ++',CR,LF,0	;FINISH THE ERROR MESSAGE
	  RET
;.....
;
;
;---->	RCVERR:
;
; Checks for framing, overrun, and parity errors.  Parity errors cannot
; be detected unless the parity option has been selected.
;    1. Error code (ERRCDE) was set in RECV routine.
;    2. ERRCDE=0 for no errors, ERRCDE<>0 for errors.
;    3. If there is an error, routine returns with carry flag set.
;
RCVERR:	  PUSH	PSW		;SAVE CHARACTER RECEIVED
	  LDA	ERRCDE		;CHECK FOR ANY RECEIVE ERROR
	  ORA	A
	  JNZ	RCVDERR		;IF AN ERROR GO SHOW WHICH ERROR IT IS
	  POP	PSW		;IF NO ERROR, GET RECEIVED CHAR. BACK
	  RET
;...
;
;
;----> RCVDERR:  Checks for a receive error and displays an appropriate
;                error message.  Then goes to RCVSERR to purge the line
;                and send a NAK.
;
RCVDERR:  STA	ONERR
	  POP	PSW		;CLEAR STACK OF "PUSH PSW" IN 'RCVERR'
	  POP	PSW		;CLEAR STACK OF "CALL  RCVERR"
	  CALL	RCVQERR		;SEE IF QUIET MODE
	  LDA	ERRCDE		;GET RECEIVE ERR CODE
	  ANI	FRMER		;WAS THERE A FRAMING ERROR?
	  JZ	RCVDERR1	;NO, GO CHECK FOR OVERRUN
	  CALL	ILPRT
	  DB	CR,LF,'++ Framing error ',0
	  JMP	RCVPRN		;PRINT # OF ERROR
;
RCVDERR1: LDA	ERRCDE		;GET RECEIVE ERR CODE
	  ANI	ORUNER		;WAS THERE AN OVERRUN
	  JZ	RCVDERR2	;NO, GO CHECK FOR PARITY ERROR
	  CALL	ILPRT
	  DB	CR,LF,'++ Overrun error ',0
	  JMP	RCVPRN		;PRINT # OF ERROR
;
RCVDERR2: LDA	ERRCDE		;GET RECEIVE ERR CODE
	  ANI	PARER		;WAS THERE A PARITY ERROR?
	  JZ	RCVRPT		;NO, GO PURGE LINE
	  CALL	ILPRT
	  DB	CR,LF,'++ Parity error ',0
	  JMP	RCVPRN		;PRINT # OF ERROR
;.....
;
;
; GOT SOH - GET BLOCK #, BLOCK # COMPLEMENTED
;
RCVSOH:	  XRA	A		;ZERO ACCUM
	  STA	FIRSTME 	;INDICATE FIRST SOH RECV'D
	  MVI	B,1		;1-SECOND DELAY
	  CALL	RECV		;GET RECORD
	  JC	RCVSTOT 	;GOT TIMEOUT
	  CALL	RCVERR		;CHECK FOR RECEIVE ERROR
	  MOV	D,A
	  MVI	B,1
	  CALL	RECV
	  JC	RCVSTOT
	  CALL	RCVERR		;CHECK FOR RECEIVE ERROR
	  CMA
	  CMP	D
	  JZ	RCVDATA
	  CALL	RCVQERR
	  CALL	ILPRT
	  DB	CR,LF,'++  Bad sector # in header',0
	  JMP	RCVPRN
;.....
;
;
RCVDATA:  MOV	A,D
	  STA	RCVRNO
	  MVI	A,1
	  STA	DATAFLG
	  MVI	C,0
	  CALL	CLRCRC		;CLEAR CRC COUNTER
	  LXI	H,80H
;
RCVCHR:	  MVI	B,1
	  CALL	RECV
	  JC	RCVSTOT
	  CALL	RCVERR		;CHECK FOR RECEIVE ERROR
	  MOV	M,A
	  INR	L
	  JNZ	RCVCHR
	  XRA	A 
	  STA	DATAFLG
	  LDA	CRCFLAG		;IN 'CRC' MODE?
	  ORA	A
	  JZ	RCVCRC		;IF YES, EXIT
	  MOV	D,C
	  MVI	B,1
	  CALL	RECV
	  JC	RCVSTOT
	  CALL	RCVERR		;CHECK FOR RECEIVE ERROR
	  CMP	D
	  JNZ	RCVCERR
;
CHKSNUM:  LDA	RCVRNO
	  MOV	B,A
	  LDA	RECDNO
	  CMP	B
	  JZ	RECVACK
	  INR	A
	  CMP	B
	  JNZ	ABORT
	  RET
;.....
;
;
RCVCRC:   MVI	E,2		;NUMBER OF CRC BYTES
;
RCVCRC1:  MVI	B,1
	  CALL	RECV
	  JC	RCVSTOT
	  CALL	RCVERR		;SEE IF ANY RECEIVE ERRORS
	  DCR	E
	  JNZ	RCVCRC1
	  CALL	CHKCRC		;CHECK 'CRC' BYTES OF RECEIVED MESSAGE
	  ORA	A
	  JZ	CHKSNUM		;IF OK, EXIT
	  CALL	RCVQERR		;SEE IF QUIET MODE
	  CALL	ILPRT		;IF NOT, SHOW ERROR MESSAGE
	  DB	CR,LF,'++ CRC error ',0
	  JMP	RCVPRN		;SHOW ERROR NUMBER
;.....
;
;
RCVCERR:  CALL	RCVQERR		;SEE IF QUIET MODE
	  CALL	ILPRT		;IF NOT, SHOW ERROR MESSAGE
	  DB	CR,LF,'++ CHECKSUM error ++ ',0
	  JMP	RCVPRN		;SHOW ERROR NUMBER
;.....  
;
;
RECVACK:  CALL	SENDACK
	  JMP	RCVRECD
;.....
;
;
SENDACK:  MVI	A,ACK
	  CALL	SEND
	  RET
;.....
;
;
SENDHDR:  LDA	QFLG
	  ORA   A
	  JZ	SENDHNM
  	  CALL	ILPRT
	  DB	CR,'Sending # ',0
	  PUSH	H		;STORE CURRENT ADDRESS
	  LHLD	RECDNO		;GET RECORD NUMBER
	  CALL	DECOUT		;PRINT IT IN DECIMAL
	  CALL	ILPRT
	  DB	' (',0
	  CALL	DHXOUT		;16 BIT HEX CONVERSION & OUTPUT
	  CALL	ILPRT
	  DB	'H) ',0
	  POP	H		;RESTORE CURRENT ADDRESS
;
SENDHNM:  MVI	A,SOH		;SEND 'SOH' CHARACTER TO THE OUTPUT
	  CALL	SEND
	  LDA	RECDNO		;SEND RECORD NUMBER TO THE OUTPUT
	  CALL	SEND
	  LDA	RECDNO
	  CMA			;COMPLEMENT THE RECORD NUMBER
	  JMP	SEND		;SEND THIS VALUE TO THE OUTPUT
;.....
;
;
SENDREC:  MVI	A,1
	  STA	DATAFLG
	  MVI	C,0
	  CALL	CLRCRC
	  LXI	H,80H
;
SENDC:	  MOV	A,M
	  CALL	SEND
	  INR	L
	  JNZ	SENDC
	  XRA	A
	  STA	DATAFLG
	  RET
;.....
;
;
SENDCKS:  MOV	A,C
	  JMP	SEND
;.....
;
;
SENDCRC:  CALL	FINCRC
	  MOV	A,D
	  CALL	SEND
	  MOV	A,E
	  CALL	SEND
	  XRA	A
	  RET
;.....
;
;
GETACK:	  MVI	B,10		;10-SECONDS MAXIMUM WAIT TIME
	  CALL	RECVDG
	  JC	GETATOT
	  CPI	ACK
	  RZ			;ALL DONE IF 'ACK' CHARACTER RECEIVED
	  MOV	B,A		;OTHERWISE SHOW WHAT THE CHARACTER WAS
	  LDA	QFLG
	  ORA	A
	  JZ	ACKERR
	  MOV	A,B
	  CALL	CRLF
	  CPI	NAK		;IS IT A NAK?
	  JZ	GETACK1		;SHOW 'NAK' IN THAT CASE
	  CALL	HEXO
	  CALL	ILPRT
	  DB	'H',0
	  JMP	GETACK2
;
GETACK1:  CALL	ILPRT
	  DB	'NAK',0	
;
GETACK2:  CALL	ILPRT		;PRINT THE ERROR MESSAGE
	  DB	' received not ACK - ',0
	  CALL	SHOWERR		;SHOW THE ERROR NUMBER
;
ACKERR:	  LDA	ERRCT		;INCREMENT THE ERROR COUNT
	  INR	A
	  STA	ERRCT
	  CPI	10+1		;SEE IF AT THE LIMIT OF 10 ERRORS YET	
	  RC			;IF NOT, RETURN
	  CALL	ERXIT
	  DB	CR,LF,'++ SEND-FILE CANCELLED ++','$'
;.....
;
;
; TIME-OUT MESSAGE ON ACK
;
GETATOT:  CALL	ILPRT
	  DB	CR,LF,'TIMEOUT on ACK',CR,LF,0
	  JMP	ACKERR
;.....
;
;
CKABORT:  LDA	QFLG
	  ORA	A
	  RZ
	  CALL	STAT
	  RZ
	  CALL	KEYIN
	  CPI	CAN
	  RNZ
;
;
; ABORTS SEND OR RECEIVE ROUTINES AND RETURNS TO COMMAND LINE
;
ABORT:	  LXI	SP,STACK
;
ABORTL:	  MVI	B,1		;1-SECOND DELAY TO CLEAR INPUT
	  CALL	RECV
	  JNC	ABORTL
	  MVI	A,CAN		;SHOW YOU ARE CANCELLING
	  CALL	SEND
;
ABORTW:	  MVI	B,1		;1-SECOND DELAY TO CLEAR INPUT
	  CALL	RECV
	  JNC	ABORTW
	  MVI	A,' '
	  CALL	SEND
	  MVI	A,'B'   	;TURN MULTI-FILE MODE..
	  STA	BATCHFLG  	;..OFF SO ROUTINE ENDS.
	  MVI	A,TRUE
	  STA	ABORTFLG	;SHOWS AN ABORT WAS MADE
	  STA	NFILFLG		;STOP COPY INTO CRT
	  LDA	OPTION		;RECEIVING A FILE NOW?
	  CPI	'R'
	  JZ	RCVSABT		;IF YES, CANCEL THE UNFINISHED FILE
	  CALL	ILPRT
 	  DB	CR,LF,LF,'++ FILE CANCELLED ++',CR,LF,BELL,0
	  JMP	DONETCA
;.....
;
;
INCRRNO:  PUSH	H
	  LHLD	RECDNO		;GET RECORD NUMBER
	  INX	H		;BUMP IT
	  SHLD	RECDNO		;STORE IT
	  MOV	A,L
	  POP	H
	  RET
;.....
;
;
; First check for any wild cards and disallow, just to be safe.  Do not
; want a group of files being accidently erased.
;
ERASFIL:  LXI	H,FCB		;FILE NAME IS STORED HERE
	  MVI	B,11		;MAXIMUM OF 11 CHARS FOR FILENAME.EXT
;
ERASFIL1: INX	H		;NEXT LOCATION IN FILE NAME
	  MOV	A,M		;GET THE CHAR.
	  CPI	'?'		;CHECK FOR ANY WILD CARD CHARS.
	  JZ	ERRORW		;ERROR IF ONE IS FOUND
	  DCR	B		;NUMBER OF TRIES LEFT
	  JNZ	ERASFIL1	;IF NOT ZERO, KEEP CHECKING
	  LDA	BATCHFLG	;DON'T ASK FOR ERASE..
	  ORA	A		;..IN MULTI-FILE MODE,..
	  JZ	NOASK		;..JUST DO IT.
	  LXI	D,FCB
	  MVI	C,SRCHF
	  CALL	BDOS
	  INR	A
	  RZ			;FILE ERASED OK, RETURN
	  CALL	ILPRT		;OTHERWISE MAKE SURE IT'S OK
	  DB	'File exists - erase?  (Y/N): ',BELL,0
	  CALL	KBDCHR
	  CPI	'Y'
	  JNZ	MENU		;IF NOT A 'Y' DO NOT ERASE
	  CALL	CRLF		;OTHERWISE ERASE THE FILE
;
NOASK:	  LXI	D,FCB
	  MVI	C,ERASE
	  JMP	BDOS
;.....
;
;
ERRORW:   POP	H		;RESTORE STACK FROM "CALL ERASFIL"
	  CALL	ILPRT
	  DB	'++ NO WILDCARDS ALLOWED FOR TEXT FILES ++'
	  DB	CR,LF,BELL,0
	  JMP	MENU
;.....
;
;
BLKFILE:  CALL	ILPRT		;ROUTINE IF NO FILE IS NAMED FOR
;				;"SEND" OR "RECEIVE"
	  DB	'++ NO FILE SPECIFIED ++',CR,LF,BELL,0
	  JMP	MENU
;.....
;
;
MAKEFIL:  LXI	D,FCB
	  MVI	C,MAKE
	  CALL	BDOS
	  INR	A
	  RNZ
	  CALL	ERXIT
	  DB	'++ ERROR -- Can''t open file ++',CR,LF
	  DB	'++ Directory is likely full ++','$'
;
CNREC:	  MVI	C,FILSIZ	;COMPUTE FILE SIZE FUNCTION IN CP/M 2.x
	  LXI	D,FCB		;POINT TO FILE CONTROL BLOCK
	  CALL	BDOS
	  LHLD	FCB+33		;GET RECORD COUNT
	  SHLD	RCNT		;STORE IT
	  LXI	H,0		;ZERO 'HL'
	  SHLD	FCB+33		;RESET RANDOM RECORD IN FCB
	  RET
;
;.....
;
;
OPENFIL:  XRA	A
	  STA	FCBEXT
	  LXI	D,FCB
	  MVI	C,OPEN
	  CALL	BDOS
	  INR	A
	  JNZ	SENDTIME	;SEND TRANSFER TIME, # OF RECORDS, ETC.
	  CALL	ERXIT		;FILE DID NOT OPEN
	  DB	'++ FILE NOT FOUND ++','$'
;
;.....
;
;

CLOSFIL:  LXI	D,FCB
	  MVI	C,CLOSE
	  CALL	BDOS
	  INR	A
	  RNZ
	  CALL	ERXIT
	  DB	CR,LF,'++ UNABLE TO CLOSE FILE ++','$'
;.....
;
;
; UPDATE RECORD READ
;
RDRECD:	  LDA	RECINBF
	  DCR	A
	  STA	RECINBF
	  JM	RDBLOCK
	  LHLD	RECPTR
	  LXI	D,80H
	  CALL	MOVE128
	  SHLD	RECPTR
	  RET
;.....
;
;
; BUFFER EMPTY SO READ IN ANOTHER BLOCK (UP TO 16K OR 128 RECORDS)
;
RDBLOCK:  LDA	EOFLG
	  CPI	1
	  STC
	  RZ
	  MVI	C,0
	  LXI	D,DBUF
;
RDRECLP:  PUSH	B
	  PUSH	D
	  MVI	C,SETDMA
	  CALL	BDOS
	  LXI	D,FCB
	  MVI	C,READ
	  CALL	BDOS
	  POP	D
	  POP	B
	  ORA	A
	  JZ	RDRECOK
	  DCR	A
	  JZ	REOF
	  CALL	ERXIT
	  DB	'++ FILE READ ERROR ++','$'
;
RDRECOK:  LXI	H,80H
	  DAD	D
	  XCHG
	  INR	C
	  MOV	A,C
	  CPI	DBUFSIZ*8	;BUFFER SIZE IN 128 BYTE RECORDS
	  JZ	RDBFULL
	  JMP	RDRECLP
;...
;
;
REOF:	  MVI	A,1
	  STA	EOFLG
	  MOV	A,C
;
;
; BUFFER FULL OR RECEIVED EOF
;
RDBFULL:  STA	RECINBF
	  LXI	H,DBUF
	  SHLD	RECPTR
	  LXI	D,80H
	  MVI	C,SETDMA
	  CALL	BDOS
	  JMP	RDRECD
;.....
;
;
; WRITE A RECORD
;
WRRECD:	  LHLD	RECPTR
	  XCHG
	  LXI	H,80H
	  CALL	MOVE128
	  XCHG
	  SHLD	RECPTR
	  LDA	RECINBF
	  INR	A
	  STA	RECINBF
	  CPI	DBUFSIZ*8 	;BUFFER SIZE IN 128 BYTE RECORDS
	  RNZ
;
;
; WRITE A 16K BLOCK TO DISK (128 RECORDS)
;
WRBLOCK:  LDA	RECINBF
	  ORA	A
	  RZ
	  MOV	C,A
	  LXI	D,DBUF
;
DKWRLP:	  PUSH	H
	  PUSH	D
	  PUSH	B
	  MVI	C,SETDMA
	  CALL	BDOS
	  LXI	D,FCB
	  MVI	C,WRITE
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  ORA	A
	  JNZ	WRERR
	  LXI	H,80H
	  DAD	D
	  XCHG
	  DCR	C
	  JNZ	DKWRLP
	  XRA	A
	  STA	RECINBF
	  LXI	H,DBUF
	  SHLD	RECPTR
	  RET
;.....
;
;
; ERROR WHILE WRITING A RECORD, SHOW WHY IT IS ABORTING
;
WRERR:	  MVI	C,CAN
	  CALL	SEND
	  CALL	ERXIT
	  DB	CR,LF,'++ FILE WRITE ERROR ++','$'
;.....
;
;
;----> RECV: Receive a character
;
; Timeout time is in B, in seconds.  Entry via 'RECVDG' deletes garbage
; characters on the line.  For example, having just sent a sector,
; calling RECVDG will delete any line noise induced characters LONG
; before the ACK/NAK would be received.
;
RECVDG:	  CALL	IN$MODDATP
	  CALL	IN$MODDATP
;
RECV:	  PUSH	D		;SAVE ANY CURRENT VALUES
	  MOV	A,B		;MULTIPLY 'B' BY 4 FOR EXTRA DELAY
	  RAL
	  RAL
	  MOV	B,A
;
MSEC:	  CALL	CKABORT		;WANT TO INTENTIONALLY ABORT?
	  PUSH	H
	  LXI	H,175		;MASTER DELAY FACTOR
	  CALL	FIXCNT
	  PUSH	H		;SAVE THE DELAY VALUE NOW IN 'HL'
	  POP	D		;GET IT BACK, BUT IN 'DE'
	  POP	H		;RESTORE THE STACK TO NORMAL
;
MWTI:	  CALL	RCVREADY	;INPUT HAVE A CHARACTER READY?
	  JZ	MCHAR		;IF YES, EXIT
	  DCR	E
	  JNZ	MWTI
	  DCR	D
	  JNZ	MWTI
	  DCR	B		;NUMBER OF SECONDS WANTED
	  JNZ	MSEC		;IF NOT ZERO, DO 1-SECOND LOOP AGAIN
	  POP	D		;RESTORE ORIGINAL VALUES
	  STC			;NO CHARACTER SO SET CARRY BIT
	  RET
;.....
;
;
MCHAR:	  LDA	PMMIBYTE	;USING A PMMI MODEM?
	  ORA	A
	  JZ	MCHAR1		;IF NOT, SKIP THE FOLLOWING LINES
	  CALL	IN$MODCTLP  	;GET ERROR-STATUS BYTE
	  ANI	ERRCDMSK    	;MASK OUT ALL EXCEPT ERROR BITS (3-5)
	  STA	ERRCDE      	;SAVE THE ERROR CODE
;
MCHAR1:	  CALL	IN$MODDATP
	  POP	D		;RESTORE ORIGINAL VALUES
	  PUSH	PSW
	  CALL	UPDCRC		;CALCULATE CRC
	  ADD	C	
	  MOV	C,A
	  LDA	RSEEFLG
	  ORA	A
	  JZ	MONIN
	  LDA	VSEEFLG
	  ORA	A
	  JNZ	NOMONIN
	  LDA	DATAFLG
	  ORA	A
	  JZ	NOMONIN
;
MONIN:	  POP	PSW
	  PUSH	PSW
	  CALL	SHOW
;
NOMONIN:  POP	PSW
	  ORA	A
	  RET
;.....
;
;
; SEND A CHARACTER TO THE MODEM
;
SEND:	  PUSH	PSW
	  LDA	NSEEFLG
	  ORA	A
	  JZ	MONOUT
	  LDA	SSEEFLG
	  ORA	A
	  JZ	MONOUT
	  LDA	VSEEFLG
	  ORA	A
	  JNZ	NOMONOT
	  LDA	DATAFLG
	  ORA	A
	  JZ	NOMONOT
;
MONOUT:	  POP	PSW
	  PUSH	PSW
	  CALL	SHOW
;
NOMONOT:  POP	PSW
	  PUSH	PSW
	  CALL	UPDCRC		;CALCULATE CRC
	  ADD	C
	  MOV	C,A
	  LDA	NSEEFLG		;NOT SENDING TO MODEM?
	  ORA	A
	  JZ	SENDW1		;IF YES, EXIT
;
SENDW:	  CALL	SENDRDY
	  JNZ	SENDW
	  POP	PSW
	  JMP	OUT$MODDATP
;
SENDW1:	  POP	PSW		;RESTORE STACK
	  RET
;.....
;
;
; WAITS FOR THE FIRST CHARACTER RECEIVED WHILE WAITING TO SEND A FILE.
; IF A CHARACTER IS NOT RECEIVED IN ONE SECOND, IT LOOPS AGAIN UNTIL A
; CHAR IS RECEIVED OR IT TIMES OUT.  THE COUNT IS SET FOR 100 SECONDS
; BEFORE TIMEOUT.  THIS GIVES ENOUGH THE RECEIVING STATION AMPLE TIME
; TO NAME A FILE, ETC.
;
WAITNAK:  CALL	ILPRT
	  DB	'Awaiting CRC request',CR,LF,0
;
WAITNLP:  CALL	CKABORT
	  MVI	B,1
	  CALL	RECV
	  CPI	CAN		;WANT TO QUIT?
	  JZ	ABORT
	  CPI	CRC		;CRC REQUEST?
	  JZ	WAITCRC		;YES, GO SET CRC FLAG
	  CPI	NAK
	  RZ
	  DCR	E
	  JNZ	WAITNLP
	  JMP	ABORT
;...
;
;
WAITCRC:  CALL	ILPRTQ
	  DB	'CRC request received',CR,LF,0
	  XRA	A
	  STA	CRCFLAG		;MAKE SURE IN 'CRC' MODE THEN
	  RET
;.....
;
;
;--->PARITY: Routine to setup PMMI for odd/even parity.
;
PARITY:	  LDA	PMMIBYTE	;IS MODEM A PMMI?
	  ORA	A		;SET FLAGS
	  RZ			;NO, RETURN
;MOD(BGL)***
	  LDA	PARTY		;CURRENTLY 8/NONE?
	  CPI	ORIGMOD		;IF NOT, IGNORE
	  RNZ
	  LDA	OPARITY		;GET ODD PARITY REQUEST BYTE
	  ORA	A		;SET FLAGS
	  JNZ	EVENPAR		;IF NOT ODD SEE IF IT IS EVEN
	  LDA	UARTCTLB	;GET UART/MODEM CONTROL BYTE
	  ANI	ODPARMSK
	  JMP	PARITY1
;...
;
;
EVENPAR:  LDA	EPARITY 	;GET EVEN PARITY REQUEST BYTE
	  ORA	A         	;SET FLAGS
	  RNZ               	;IF EVEN PARITY NOT SPECIFIED RETURN
	  LDA	UARTCTLB  	;GET UART/MODEM CONTROL BYTE
	  ANI	ODPARMSK  	;SET FOR PARITY
	  ORI	EVPARMSK  	;NOW SET FOR EVEN PARITY
;
PARITY1:  JMP	OUT$MODCTLP	;SEND TO PMMI -
;				;WHEN OUT$MODCTLP DOES RET IT
;.....				;WILL GO BACK TO CALLING ROUTINE
;
;
NOPARIT:  LDA	PMMIBYTE
	  ORA	A
	  RZ
	  LDA	UARTCTLB	;GET UART/MODEM CONTROL BYTE
	  ORI	NOPARMSK	;RESET PARITY BIT ON PMMI
	  JMP	OUT$MODCTLP
;.....
;
;MOD(BGL)***
TOGLPAR:  LXI	H,PARTOG
	  MOV	A,M
	  DCX	H
	  SUB	M
	  MOV	M,A
	  STA	UARTCTLB
	  CALL	OUT$MODCTLP
	  JMP	XPRT
;.....
;
;
INITADR:  LHLD	1		;BIOS WARM REBOOT JUMP VECTOR
	  LXI	D,3
	  DAD	D
	  SHLD	VSTAT+1		;BIOS CONSOLE STATUS JUMP VECTOR
	  DAD	D
	  SHLD	VKEYIN+1	;BIOS CONSOLE KEYBOARD JUMP VECTOR
	  DAD	D
	  SHLD	VTYPE+1		;BIOS CONSOLE CRT JUMP VECTOR
	  DAD	D
	  SHLD	VLIST+1		;BIOS LIST DEVICE JUMP VECTOR
	  LXI	D,30
	  DAD	D
	  SHLD	VLSTAT+1	;BIOS LIST DEVICE STATUS JUMP VECTOR
	  LDA	PMMIBYTE
	  ORA	A
	  RZ			;SKIP THE REST IF NOT PMMI
	  LDA	IN$MODCTLP+1
	  STA	OUT$MODCTLP+1
	  INR	A
	  STA	OUT$MODDATP+1
	  STA	IN$MODDATP+1
	  INR	A
	  STA	IN$BAUDRP+1
	  STA	OUT$BAUDRP+1
	  INR	A
	  STA	OUT$MODCTL2+1
	  RET
;.....
;
;
; CHECK OPTIONS, PUT 0 IN APPROPRIATE PLACES IN OPTION TABLE IF OPTION
; SELECTED
;
PROCOPT:  LXI	D,FCB+1
 	  LDAX	D
	  STA	OPTION
;
OPTLP:	  INX	D
	  LDAX	D
	  CPI	' '
	  JZ	ENDOPT
	  LXI	H,OPTBL
	  MVI	B,OPTBE-OPTBL
;
OPTCK:	  CMP	M
	  JNZ	OPTNO
	  CPI	'O'
	  JNZ	OPTCK1
	  XRA	A
	  STA	UARTFLG
	  JMP	OPTCK2
;...
;
;
OPTCK1:	  CPI	'A'
	  JNZ	OPTCK2
	  MVI	A,TRUE
	  STA	UARTFLG
;
OPTCK2:	  MVI	M,0
	  JMP	OPTLP
;...
;
;
OPTNO:	  INX	H
	  DCR	B
	  JNZ	OPTCK
	  CALL	NTVLDMSG
	  POP	PSW		;PRESERVE STACK
	  JMP	MENU
;
ENDOPT:	  LDA	VSEEFLG
	  ORA	A
	  RNZ
	  STA	QFLG		;QUITE MODE FOR DATA ITEMS
	  RET
;.....
;
;
DONE: 	  LDA	BATCHFLG	;IN BATCH MODE?
	  ORA	A
	  JNZ	DONETC		;EXIT IF NOT
	  LDA	QFLG
	  ORA	A
	  JZ	NMSTRNS
	  MVI	B,12		;ZERO OUT FTRNMSG
	  LXI	H,FTRNMSG
	  MVI	A,0
;
ZEROLP:	  MOV	M,A
	  INX	H
	  DCR	B
	  JNZ	ZEROLP
	  MVI	B,12		;PUT FILE NAME IN FTRNMSG
	  LXI	H,FCB+1		
	  LXI	D,FTRNMSG
;
LOADMSG:  MVI	A,4		;START OF FILE TYPE?
	  CMP	B
	  JZ	PERIOD		;PUT IN PERIOD IF SO
	  MOV	A,M	
	  CPI	' '		;DON'T PUT IN SPACE
	  JZ	SKPSP	
	  STAX	D		;STORE IN FTRNMSG
	  INX	D
;
SKPSP:	  INX	H
	  DCR	B
	  MOV	A,B
	  ORA	A		;END OF FILE NAME?
	  JZ	FTRNMSG0	;DISPLAY FILE NAME
	  JMP	LOADMSG		;LOOP FOR ANOTHER CHARACTER
;.....
;
;
PERIOD:	  MOV	A,M
	  CPI	' '		;IS FILE TYPE EMPTY?
	  JZ	FTRNMSG0	;GO IF SO
	  MVI	A,'.'		;ELSE PUT PERIOD IN MESSAGE
	  STAX	D
	  INX	D
	  DCR	B
	  JMP	LOADMSG
;.....
;
;
FTRNMSG0: CALL	ILPRT
	  DB	CR,LF
;
FTRNMSG:  DS	12
	  DB	0
	  CALL	ILPRT
	  DB	' Transferred',CR,LF,LF,BELL,0
;
NMSTRNS:  LDA	FCB		;SAVE DRIVE NO.
	  STA	DISKNO
	  LXI	H,FCB		;BLANK OUT FILE CONTROL BLOCKS
	  CALL	INITFCB
	  LDA	DISKNO		;PUT DRIVE NUMBER BACK
	  STA	FCB
	  LXI	H,RESTSN	;RESTORE RECORD NUMBERS..
	  LXI	D,RECDNOB	;..FOR NEW FILE TRANSFER.
	  MVI	B,RECDNOE-RECDNOB ;ROUTINE ALSO DONE IN MENU.
	  CALL	MOVE
	  CALL	IN$MODDATP
	  CALL	IN$MODDATP
	  LDA	SENDFLG		;GOES TO EITHER SEND OR..
	  ORA	A		;..RECEIVE FILE, DEPENDING..
	  JNZ	SENDFIL1	;..UPON WHICH ROUTINE SET..
	  JMP	RCVFIL1		;..THE FLAG IN MULTI-FILE MODE.
;.....
;
;
DONETC:	  CALL	CKABORT		;SLIGHT DELAY FOR NEXT MESSAGE
	  CALL	ILPRT
	  DB	CR,LF,'[Transfer Completed]',CR,LF,BELL,0
;
DONETCA:  LDA	XITFLG		;SPECIAL 'X' FLAG SET?
	  ORA	A
	  JZ	BYEBYE		;IF YES, DISCONNECT AND REBOOT
	  LDA	DISCFLG		;NORMAL 'D' FLAG SET?
	  ORA	A
	  JZ	DONETCC		;IF YES, DISCONNECT, GET NEXT COMMAND
;
DONETCB:  CALL	NOPARIT		;RESET TO NO PARITY
	  MVI	A,CRC
	  STA	CRCFLAG		;TURNS OFF CRC OPTION
	  MVI	A,TRUE
	  STA	FIRSTME		;SET FIRST-TIME FLAG
	  STA	FSTFLG		;RESET MULTIFILE TRANS
	  STA	NFILFLG		;..USED IN TERMINAL ROUTINE.
	  CMA
	  STA	SAVEFLG		;STOP MEMORY SAVE IN TERM ROUTINE.
	  STA	LISTMOR		;STOP ANY BUFFERED OUTPUT TO PRINTER
	  LXI	H,BOTTRAM	;RESET PRINTER BUFFER POINTERS
	  SHLD	HLSAVE1
	  SHLD	HLSAVE2	
	  LXI	H,QFLG		;IN QUIET MODE?
	  MOV	A,M
	  ORA	A
	  MVI	M,'Q'		;RESET THE FLAG TO NORMAL
	  JZ	MENU		;IF YES, GO BACK TO COMMAND LINE
	  LDA	ABORTFLG	;COME HERE FROM A TIMEOUT?
	  ORA	A
	  JNZ	MENU		;IF YES, GO TO COMMANDE MODE
	  LDA	TERMFLG		;SEE IF RETURN TO..
	  ORA	A		;..TERMINAL MODE..
	  JNZ	MENU		;..AFTER X'FER.
	  CALL	CRLF
	  JMP	TERM
;.....
;
;
DONETCC:  CALL	ILPRT
	  DB	CR,LF,'<< DISCONNECTED >>',CR,LF,0
	  CALL	JMP$DISCONNT	;HANG-UP THE PMMI
	  JMP	MENU		;BACK TO COMMAND LINE
;.....
;
;
MOVEFCB:  LXI	H,FCB+16
	  LXI	D,FCB
	  MVI	B,16
	  CALL	MOVE
	  XRA	A
	  STA	FCBSNO
	  STA	FCBEXT
	  RET
;.....
;
;
SHOW:	  CPI	LF
	  JZ	CTYPE
	  CPI	CR
	  JZ	CTYPE
	  CPI	9
	  JZ	CTYPE
	  CPI	' '
	  JC	SHOWHEX
	  CPI	7FH
	  JC	CTYPE
;
SHOWHEX:  PUSH	PSW
	  MVI	A,'('
	  CALL	CTYPE
	  POP	PSW
	  CALL	HEXO
	  MVI	A,')'
	  JMP	CTYPE
;.....
;
;
CTYPE:	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MOV	E,A
	  MVI	C,WRCON
	  CALL	BDOS
	  POP	H
	  POP	D
	  POP	B
	  RET
;.....
;
;
CRLF:	  PUSH	PSW
	  MVI	A,CR
	  CALL	TYPE
	  MVI	A,LF
	  CALL	TYPE
	  POP	PSW
	  RET
;.....
;
;
STAT:	  PUSH	B
	  PUSH	D
	  PUSH	H
;
VSTAT:	  CALL	$-$		;BIOS CONSTAT ADDRESS, FILLED IN..
	  POP	H		;..BY INITADR ROUTINE
	  POP	D
	  POP	B
	  ORA	A
	  RET
;.....
;
;
KEYIN:	  PUSH	B
	  PUSH	D
	  PUSH	H
;
VKEYIN:	  CALL	$-$		;BIOS CONIN ADDRESS, FILLED IN..
	  POP	H		;..BY INITADR ROUTINE
	  POP	D
	  POP	B
	  RET
;.....
;
;
LISTER:	  PUSH	B
	  PUSH	D
	  PUSH	H
;
VLIST:	  CALL	$-$		;BIOS LIST OUT ADDRESS, FILLED IN..
	  POP	H		;..BY INITADR ROUTINE
	  POP	D
	  POP	B
	  RET
;.....
;
;
LSTSTAT:  PUSH	B
	  PUSH  D
	  PUSH	H
;
VLSTAT:	  CALL	$-$		;BIOS LIST DEVICE STATUS ADDRESS,..
	  POP	H		;..FILLED IN BY INITADR ROUTINE
	  POP	D
	  POP	B
	  RET
;.....
;
;
TYPE:	  PUSH	PSW
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MOV	C,A
;
VTYPE:	  CALL	$-$		;BIOS CONOUT ADDRESS, FILLED IN..
	  POP	H		;..BY INITADR ROUTINE
	  POP	D
	  POP	B
	  POP	PSW
	  RET
;.....
;
; GET A CHARACTER FROM THE KEYBOARD, CONVERT TO UPPER CASE IF NEEDED,
; AND SHOW ON CRT
;
KBDCHR:	  CALL	KEYIN		;GET A KEYBOARD CHARACTER
	  CALL	UCASE		;CONVERT TO UPPER CASE IF NEEDED
	  CALL	TYPE		;SHOW ON CRT
	  RET
;.....
;
;
UCASE:	  CPI	61H		;CHANGES LOWER CASE CHARACTER..
	  RC			;..IN A-REG TO UPPER CASE.
	  CPI	7AH+1		;SEE IF MORE THAN SMALL 'Z'
	  RNC
	  ANI	5FH
	  RET
;.....
;
;
DECOUT:	  PUSH	PSW
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  LXI	B,-10
	  LXI	D,-1
;
DECOU2:	  DAD	B
	  INX	D
	  JC	DECOU2
	  LXI	B,10
	  DAD	B
	  XCHG
	  MOV	A,H
	  ORA	L
	  CNZ	DECOUT
	  MOV	A,E
	  ADI	'0'
	  CALL	CTYPE
	  POP	H
	  POP	D
	  POP	B
	  POP	PSW
	  RET
;.....
;
;
;---->	DHXOUT: - DOUBLE PRECISION HEX OUTPUT ROUTINE.
;
DHXOUT:	  PUSH	H
	  PUSH	PSW
	  MOV	A,H		;GET MS BYTE
	  CALL	HEXO		;OUTPUT HIGH ORDER BYTE
	  MOV	A,L		;GET LS BYTE
	  CALL	HEXO		;OUTPUT LOW ORDER BYTE
	  POP	PSW
	  POP	H
	  RET
;.....
;
;
; PRINTS A HEX VALUE IN 'A' ON THE CRT
;
HEXO:	  PUSH	PSW
	  RAR
	  RAR
	  RAR
	  RAR
	  CALL	NIBBL
	  POP	PSW
;
NIBBL:	  ANI	0FH
	  CPI	10
	  JC	ISNUM
	  ADI	7
;
ISNUM:	  ADI	'0'		;ADD IN ASCII BIAS
	  JMP	CTYPE
;.....
;
;
; DISPLAYS THE CONTROL-CHARACTERS SHOWN IN THE MENU
;
SHFTYPE:  PUSH	PSW
	  CALL	ILPRT
	  DB	'CTL-',0
	  POP	PSW
	  ADI	40H		;CONVERT BINARY TO ASCII CHARS.
	  CALL	TYPE		;SHOW ON THE CRT
	  JMP	ILPRT
;.....
;
;
; WRITE A STRING OF CHARACTERS
;
ILPRT:	  XTHL
;
ILPRT1:	  MOV	A,M		;GET THE CHARACTER
	  ORA	A		;SEE IF A "0" FOR END OF STRING
	  JZ	ILPRT2		;IF YES, ALL DONE
	  CALL  CTYPE		;SHOW ON CRT
	  INX	H		;GET THE NEXT LOCATION IN THE STRING	
	  JMP	ILPRT1
;
ILPRT2:	  XTHL			;RESTORE THE ADDRESS
	  RET
;.....
;
;
; WRITE A STRING OF CHARACTERS UNLESS IN QUIET MODE
;
ILPRTQ:	  XTHL
;
ILPRTQ1:  MOV	A,M		;GET THE CHARACTER
	  ORA	A		;SEE IF A "0" FOR END OF STRING
	  JZ	ILPRTQ2		;IF YES, ALL DONE
	  LDA	QFLG
	  ORA	A
	  MOV	A,M
	  CNZ	CTYPE		;SHOW ON CRT IF NOT IN QUITE MODE
	  INX	H		;GET THE NEXT LOCATION IN THE STRING	
	  JMP	ILPRTQ1
;
ILPRTQ2:  XTHL			;RESTORE THE ADDRESS
	  RET
;.....
;
;
PRTMSG:	  MVI	C,PRINT		;PRINT THE STRING
	  JMP	BDOS
;.....
;
;
; DISPLAYS ERROR STATEMENT THEN RETURNS TO COMMAND MODE
;
ERXIT:	  POP	D
	  CALL	PRTMSG
	  MVI	A,BELL
	  CALL	TYPE
	  CALL	CRLF
	  MVI	A,TRUE
	  STA	ABORTFLG	;SHOWS AN UNINTENTIONAL ABORT
	  LDA	BATCHFLG	;IN BATCH MODE?
	  ORA	A
	  JNZ	DONETCB		;IF NOT, EXIT
	  JMP	ABORT		;ABORT OTHER COMPUTER
;.....
;
;
; EXITS DIRECTLY TO CP/M, WITH NO REBOOT UNLESS YOU ALLOW POSSIBLE
; OVERWRITING OF CCP.
;
EXIT:	  LDA	OLDUSER		;GET ORIGINAL USER NUMBER BACK
	  MOV	E,A
	  CALL	SETUSER
	  LXI	D,80H		;RESTORE ORIGINAL BUFFER AREA
	  MVI	C,SETDMA
	  CALL	BDOS
	  LDA	SAVCCP		;WAS CCP LEFT INTACT?
	  ORA	A
	  JZ	0000H		;IF NOT, WARM REBOOT JUST IN CASE
;
EXIT1:	  JMP	$-$		;OVERWRITTEN WITH CCP RETURN BY "START"
;.....
;
;
MOVE128:  MVI	B,128
;
MOVE:	  MOV	A,M
	  STAX	D
	  INX	H
	  INX	D
	  DCR	B
	  JNZ	MOVE
	  RET
;.....
;
;
; INITIALIZES CP/M FILE CONTROL BLOCKS AT 5CH AND 6CH
;
SETFCB:	  LXI	D,CMDBUF
	  LXI	H,FCB
	  CALL	CMDLINE
	  CALL	PROCOPT
	  LDA	FCB+1		;CHECK ON THE PRIMARY OPTION
	  CPI	'E'		;RETURN IF ECHO OPTION
	  RZ
	  CPI	'H'		;RETURN IF HELP OPTION
	  RZ
	  CPI	'L'		;RETURN IF LOCAL ECHO OPTION
	  RZ
	  MOV	B,A
	  LDA	PMMIBYTE
	  ORA	A
	  MOV	A,B
	  JZ	S4
	  CPI	'C'
	  RZ
;
S4:	  CPI	'T'
	  JZ	TERMSEL
	  CPI	'S'
	  JZ	CKFILE
	  CPI	'R'
	  JNZ	BDOPT
	  LDA	BATCHFLG	;IF MULT FILE MODE, THEN..
	  ORA	A		;..RECV OPT DOES NOT NEED..
	  RZ			;..NAME.
	  JMP	CKFILE
;.....
;
;
BDOPT:	  CALL	ILPRT
	  DB	CR,LF,'++ Bad Option ++',CR,LF,LF,0
	  JMP	REENT
;.....
;
;
CKFILE:   LDA	FCB+17		;IF OPTION THAT NEEDS FILE NAME,..
	  CPI	' '		;..THEN CHECK TO SEE IF NAME..
	  RNZ			;..EXISTS. IF NOT..
;
REENT:	  CALL	ILPRT		;..DO EVERYTHING OVER.
	  DB	'++ Enter primary option plus file name ++'
	  DB	CR,LF,BELL,0
	  POP	H		;RESET STACK FROM 'CALL SETFCB'
	  JMP	MENU		;ABORT TO COMMAND LINE
;.....
;
;
TERMSEL:  LDA	FCB+17
	  CPI	' '
	  JNZ	SAVAGN
	  MVI	A,FALSE
	  STA	SAVEFLG
	  MVI	A,TRUE
	  STA	NFILFLG
	  RET
;.....
;
;
SAVAGN:	  MVI	A,FALSE
	  STA	NFILFLG
	  RET
;.....
;
;	
; CHANGE BAUDRATE ON-THE-FLY WITH CTL-B (WHILE IN TERMINAL MODE)
;
NEWBAUD:  LDA	PMMIBYTE
	  ORA	A
	  RZ
	  CALL	ILPRT
	  DB	CR,LF,'Enter new Baudrate: ',0
	  LXI	H,FCB+9
	  MVI	M,0		;DEFAULTS TO 300 BAUD IF NO ANSWER TYPED
;
NEWBAUD1: CALL	KEYIN		;GET THE BAUD RATE
	  CPI	CR		;CARRIAGE RET FINISHES BAUD RATE ENTRY
	  JNZ	CONNEWB		;GOES TO THE ESTABLISHED ROUTINE	
	  CALL	CRLF		;PROGRAM IS DONE THERE.
	  JMP	FIXBAUD		;GO CHANGE THE BAUD RATE
;.....
;
;
CONNEWB:  CPI	'0'		;NUMERALS ARE 0-9
	  JC	NEWBAUD1
	  CPI	'9'+1
	  JNC	NEWBAUD1	;IF NOT A NUMERAL, IGNORE, ASK AGAIN
	  MOV	M,A		;STORE ANSWER STARTING AT FCB+9
	  CALL	TYPE		;SHOW THE NUMERAL ON THE CRT
	  INX	H		;NEXT STORAGE LOCATION IN FCB
	  JMP	NEWBAUD1	;GET THE NEXT NUMERAL
;.....
;
;
; ADJUSTS LOOP COUNTERS FOR THE SELECTED CLOCK SPEED
;
FIXCNT:	  LDA	CLOCK		;GET THE USER'S CLOCK SPEED
	  PUSH	D
	  PUSH	H
	  POP	D
;
CNTMUL:	  DAD	D
	  DCR	A
	  JNZ	CNTMUL
	  POP	D		;RETURN WITH ANSWER IN 'HL'
	  RET
;.....
;
;  
;=======================================================================
;
; LOADS A COMMAND LINE ADDRESSED BY DE REGISTERS (MAX # CHARACTERS IN
; LINE IN DE, NUMBER OF CHARS IN LINE IN DE+1, LINE STARTS IN DE+2) INTO
; FCB ADDRESSED BY HL REGISTERS.  THE FCB SHOULD BE AT LEAST 33 BYTES IN
; LENGTH.  THE COMMAND LINE BUFFER MUST HAVE A MAXIMUM LENGTH  AT LEAST
; ONE MORE THAN THE GREATEST NUMBER OF CHARACTERS THAT WILL BE NEEDED.

CMDLINE:  PUSH	PSW
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  CALL	INITIAL		;FILLS FCBS WITH BLANKS AND NULLS
	  XCHG			;GET START OF COMMAND LINE IN HL.
	  INX	H		;ADDRESS # BYTES IN CMD LINE.
	  MOV	E,M		;LOAD DE PAIR WITH # BYTES.
	  MVI	D,0
	  INX	H
	  DAD	D		;POINT TO BYTE AFTER LAST CHAR..
	  MVI	M,CR		;..IN CMD LINE AND STORE DELIMITER.
	  POP	H		;RESTORE HL AND DE.
	  POP	D
	  PUSH	D
	  PUSH	H
	  INX	D		;ADDRESS START OF COMMAND.
	  INX	D
	  CALL	DRIVE
;
NAME1:	  MVI	C,8		;TRANSFER FIRST FILENAME TO FCB.
	  CALL	TRANS
	  CPI	CR
	  JZ	DONEL
	  CPI	' '		;IF SPACE, THEN START OF..
	  JZ	NAME2		;..SECOND FILENAME.
;
TYPE1:	  POP	H		;FILETYPE MUST BE AFTER..
	  PUSH	H		;..EIGHTH BYTE OF NAME.
	  LXI	B,9
	  DAD	B
	  MVI	C,3		;TRANSFER TYPE OF FIRST FILE
	  CALL	TRANS
	  CPI	CR
	  JZ	DONEL
;
NAME2:	  LDAX	D		;EAT MULTIPLE SPACES..
	  CPI	' '		;..BETWEEN NAMES.
	  JNZ	NAME2C
	  INX	D
	  JMP	NAME2
;
NAME2C:	  POP	H		;SECOND NAME STARTS IN 16TH BYTE.
	  PUSH	H		;POINT HL TO THIS BYTE.
	  LXI	B,16
	  DAD	B
	  CALL	DRIVE
	  MVI	C,8
	  CALL	TRANS
	  CPI	CR
	  JZ	DONEL
;
TYPE2:	  POP	H		;SECOND TYPE STARTS IN 25TH BYTE.
	  PUSH	H
	  LXI	B,25
	  DAD	B
	  MVI	C,3
	  CALL	TRANS
;
DONEL:	  POP	H
	  PUSH	H
	  INX	H		;POINT TO 1ST CHAR OF 1ST NAME IN FCB..
	  CALL	SCANL		;CHECK FOR * (AMBIGUOUS NAMES).
	  POP	H
	  PUSH	H
	  LXI	B,17		;..TO 1ST CHAR OF SECOND NAME IN FCB.
	  DAD	B
	  CALL	SCANL
	  POP	H
	  POP	D
	  POP	B
	  POP	PSW
	  RET
;.....
;
;
; SUBROUTINES FOR CMDLINE SECTION
;
INITIAL:  PUSH	H	;INITIALIZES FCB WITH 1 NULL (FOR FIRST DRIVE)..
	  PUSH	B	;..11 BLANKS, 4 NULLS, 1 NULL (FOR 2ND DRIVE)..
	  MVI	M,0	;..11 BLANKS, AND 4 NULLS.
	  INX	H
	  MVI	B,11
	  MVI	A,' '
	  CALL	INITFILL
	  MVI	B,5
	  XRA	A
	  CALL	INITFILL
	  MVI	B,11
	  MVI	A,' '
	  CALL	INITFILL
	  MVI	B,4
	  XRA	A
	  CALL	INITFILL
	  POP	B
	  POP	H
	  RET
;.....
;
;
INITFILL: MOV	M,A
	  INX	H
	  DCR	B
	  JNZ	INITFILL
	  RET
;.....
;
;
DRIVE:	  INX	D		;CHECK 2ND BYTE OF FILENAME.  IF IT..
	  LDAX	D		;..IS A ":", THEN DRIVE WAS SPECIFIED..
	  DCX	D
	  CPI	':'
	  JNZ	DEFDR		;..ELSE ZERO FOR DEFAULT DRIVE ..
	  LDAX	D		;..('INIT' PUT ZERO)
	  ANI	5FH
	  SUI	40H		;CALCULATE DRIVE (A=1, B=2,...)..
	  MOV	M,A		;..AND PLACE IT IN FCB.
	  INX	D		;ADDRESS FIRST BYTE OF..
	  INX	D		;..IN CMD LINE,..
;
DEFDR:	  INX	H		;..AND NAME FIELD IN FCB.
	  RET
;.....
;
;
TRANS:	  LDAX	D		;TRANSFER FROM CMD LINE TO FCB..
	  INX	D		;..UP TO NUMBER OF CHARS SPECIFIED..
	  CPI	CR		;..BY C-REG. KEEP SCANNING FIELD..
	  RZ			;..WITHOUT TRANSFER UNTIL A DELIMITING..
;
	  CPI	'.'		;..FIELD CHAR SUCH AS '.', BLANK, OR..
	  RZ			;..C/R (FOR END OF CMD LINE).
	  CPI	' '
	  RZ
	  DCR	C
	  JM	TRANS		;ONCE C-REG IS LESS THAN ZERO, KEEP..
	  MOV	M,A		;..READING CMD LINE BUT DO NOT..
	  INX	H		;..TRANSFER TO FCB.
	  JMP	TRANS
;...
;
;
SCANL:	  MVI	B,8		;SCAN FILE NAME ADDRESSED BY HL.
;
TSTNAM:	  MOV	A,M
	  CPI	'*'		;IF '*' FOUND, FILL IN REST OF FIELD..
	  JZ	FILL1		;..WITH '?' FOR AMBIGUOUS NAME.
	  INX	H
	  DCR	B
	  JNZ	TSTNAM
	  JMP	TSTTYP
;...
;
;
FILL1:	  CALL	FILL
;
TSTTYP:	  MVI	B,3		;SCAN AND FILL TYPE FIELD FOR NAME..
;
TSTTYPL:  MOV	A,M		;..SPECIFIED ABOVE.
	  CPI	'*'
	  JZ	FILL2
;
	  INX	H
	  DCR	B
	  JNZ	TSTTYPL
	  RET
;.....
;
;
FILL2:	  CALL	FILL
	  RET
;.....
;
;
FILL:	  MVI	M,'?'		;ROUTINE TRANSFERS '?'.
	  INX	H
	  DCR	B
	  JNZ	FILL
	  RET

;=======================================================================
;
; LISTS DIRECTORY AND GIVES FREE SPACE REMAINING ON THE REQUESTED DRIVE.
;
;
; Disk system reset - currently bypassed, if you wish this feature, put
;	  JMP DIRLIST2 instead of JMP DIRLIST3 in the eighth line.  The
;	  current disk (plus the A: drive) will then reset each DIR re-
;	  quest.  You can also reset the disk with the LOG command when
;	  when inserting a different one.  This saves a reset each time
;	  DIR might be requested.
;
DIRLIST:  MVI	C,CURDSK	;CURRENT DEFAULT DISK, 25.
	  CALL	BDOS
	  PUSH	PSW		;SAVE DEFAULT DISK LETTER
	  ADI	41H		;MAKE IT ASCII AND..
	  STA	DRNAME		;..STORE HERE AND..
	  STA	DEFDRV		;..HERE.
;
DIRLIST1: JMP	DIRLIST3
;
DIRLIST2: MVI	C,RESET		;13 RESET DISK SYSTEM (RESETDK)
	  CALL	BDOS
;
DIRLIST3: POP	PSW		;GET DEFAULT LETTER BACK AND..
	  MOV	E,A		;..PUT FOR SELECT.
	  MVI	C,SELDSK	;SELECT DISK AGAIN AS DEFAULT (SELDK)
	  CALL	BDOS
;
;
; Directory list routine
;
	  LXI	D,CMDBUF	;PUT COMMAND LINE IN FCB..
	  LXI	H,FCB		;..ADDRESSED BY HL-REG..
	  CALL	CMDLINE		;..AND THEN...
	  LXI	H,FCB4
	  CALL	INITFCB
	  LDA	FCB2		;GET DRIVE NUMBER
	  STA	FCB4
	  LDA	FCB2+1
	  CPI	' '		;IF A SPACE (BLANK) GET ALL NAMES
	  PUSH	PSW
	  CZ	QSTMARK
	  POP	PSW
	  CNZ	MOVNAME		;ELSE MOVE NAME INTO FCB
	  CALL	DRIVEL
	  LXI	D,80H
	  MVI	C,SETDMA
	  CALL	BDOS
	  LDA	NOOFCOL		;NUMBER OF COLUMNS INTO REG-A
	  STA	NAMECT		;CRLF AFTER "NOOFCOL" NUMBER OF COLUMNS
	  LXI	D,FCB4
	  MVI	C,SRCHF		;DO FIRST SEARCH
  	  CALL	BDOS
	  INR	A		;FFH --> 0 IF NO FILE(S) FOUND
	  JNZ	DIRLOOP
	  CALL	ILPRT
	  DB	'++ FILE NOT FOUND ++',0
	  JMP	STORAGE		;STILL SHOW STORAGE ON DEFAULT DRIVE
;
DIRLOOP:  CALL	GETADD
	  INX	H		;POINT TO FIRST LETTER OF FILENAME
	  LXI	D,PRTNAME
	  LXI	B,8
	  CALL	MOVER
	  INX	D
	  LXI	B,3
	  CALL	MOVER
	  CALL	ILPRT
;
PRTNAME:  DB	'        ','.','   ',0   ; 8 SPACES, PERIOD, 3 SPACES
;
NEXTSR:	  LXI	D,FCB4
	  MVI	C,SRCHN		;DO NEXT SEARCH
	  CALL	BDOS
	  INR	A		;IF 0FFH --> 0 THEN..
	  JZ	STORAGE		;..DIRECTORY-READ FINISHED.
	  PUSH	PSW
	  PUSH	D
	  PUSH	H
	  LDA	NAMECT
	  DCR	A
	  STA	NAMECT		;NAME COUNT UPDATED
	  ORA	A
	  CZ	CRLF		;TERMINATE LINE OF FILE NAMES
	  JNZ	FENCE
	  LDA	NOOFCOL		;RESTART COLUMNS-PER-LINE COUNT
	  STA	NAMECT
	  JMP	NOFENCE		;FENCE NOT NEEDED
;
FENCE:	  CALL	ILPRT
	  DB	' : ',0		;FENCE IF NOT AT END OF LINE OR..
;				;..LAST FILENAME
NOFENCE:  POP	H
	  POP	D
	  POP	PSW
	  JMP	DIRLOOP
;.....
;
;
; DETERMINE STORAGE REMAINING ON DEFAULT DRIVE
;
STORAGE:  CALL	CRLF
	  MVI	C,DSKPAR	;CURRENT DISK PARAMETER BLOCK
	  CALL	BDOS
	  INX	H
	  INX	H
	  MOV	A,M		;GET BLOCK SHIFT FACTOR
	  STA	BSHIFTF
	  INX	H		;BUMP TO BLOCK MASK
	  MOV	A,M		;GET IT
	  STA	BMASK
	  INX	H
	  INX	H
	  MOV	E,M		;GET MAX BLOCK NUMBER
	  INX	H
	  MOV	D,M
	  XCHG
	  SHLD	BMAX		;PUT IT AWAY
	  MVI	C,DSKALL	;ADDRESS OF CP/M ALLOCATION VECTOR
	  CALL	BDOS
	  XCHG			;GET ITS LENGTH
	  LHLD	BMAX
	  INX	H
	  LXI	B,0		;INITIALIZE BLOCK COUNT TO ZERO
;
GSPBYT:	  PUSH	D		;SAVE ALLOCATION ADDRESS
	  LDAX	D
	  MVI	E,8		;SET TO PROCESS 8 BLOCKS
;
GSPLUP:	  RAL			;TEST BIT
	  JC	NOTFRE
	  INX	B
;
NOTFRE:	  MOV	D,A		;SAVE BITS
	  DCX	H
	  MOV	A,L
	  ORA	H
	  JZ	ENDALC		;QUIT IF OUT OF BLOCKS
	  MOV	A,D		;RESTORE BITS
	  DCR	E		;COUNT DOWN 8 BITS
	  JNZ	GSPLUP		;DO ANOTHER BIT
	  POP	D		;BUMP TO NEXT COUNT..
	  INX	D		;..OF ALLOCATION VECTOR.
	  JMP	GSPBYT		;PROCESS IT
;
ENDALC:	  POP	D		;CLEAR ALLOC VECTOR POINTER FROM STACK
	  MOV	L,C		;COPY BLOCK TO HL
	  MOV	H,B
	  LDA	BSHIFTF		;GET BLOCK SHIFT FACTOR
	  SUI	3		;CONVERT FROM RECORDS TO THOUSANDS (K)
	  JZ	PRTFREE		;SKIP SHIFTS IF 1K BLOCKS
;
FREKLP:	  DAD	H		;MULTIPLY BLOCKS BY K PER BLOCK
	  DCR	A
	  JNZ	FREKLP
;
PRTFREE:  CALL 	DECOUT		;(# OF FREE K BYTES IN HL)
	  LXI	D,FREEMSG
	  CALL	PRTMSG
	  CALL	GETUSER		;GET USER NUMBER
	  MVI	H,0
	  MOV	L,A
	  CALL	DECOUT		;PRINT USER NUMBER
	  LXI	D,DEFUSR
	  JMP	PRTMSG
;.....
;
;
; SUBROUTINES FOR DIRLIST SECTION
;
QSTMARK:  MVI	A,'?'		;IF BLANK IN FCB, PUT IN 11 ?'S.
	  MVI	B,11
	  LXI	H,FCB4+1
;
QSTLP:	  MOV	M,A
	  INX	H
	  DCR	B
	  JNZ	QSTLP
	  RET
;.....
;
;
MOVNAME:  LXI	H,FCB2+1
	  LXI	D,FCB4+1
	  LXI	B,11
	  CALL	MOVER
	  RET
;.....
;
;
GETADD:	  DCR	A		;UN-DO THE INR ABOVE
	  ADD	A		;TIMES 32
	  ADD	A
	  ADD	A
	  ADD	A
	  ADD	A
	  ADI	80H		;ADD DMA (CMDBUF) OFFSET
	  MOV	L,A
	  MVI	H,0
	  RET
;.....
;
;
DRIVEL:	  LDA	FCB4		;IF NO DRIVE, USE
	  ORA	A		;DEFAULT DRIVE IN DRNAME.
	  JZ	PRNTHD
	  ADI	40H		;MAKE 1=A, 2=B, ETC., AND..
	  STA	DRNAME		;..OVERWRITE DEFAULT STORED BELOW.
;
PRNTHD:	  CALL	ILPRT
	  DB	'Drive '
;
DRNAME:	  DB	' ',CR,LF,0
	  RET
;.....
;
;
; INITIALIZED STORAGE
;
FREEMSG:  DB 	'k Bytes free on default drive '
DEFDRV:	  DB	' $'
DEFUSR:	  DB	':',CR,LF,'$'
;
;
; UNINITIALIZED STORAGE
;
BMAX:	  DS	2		;HIGHEST BLOCK NUMBER ON DRIVE
BMASK:	  DS	1		;REC/BLK - 1
BSHIFTF:  DS	1		;NUMBER OF SHIFTS TO MULTIPLY BY REC/BLK
;.....
;
;
;=======================================================================
;
; DUPLICATES 'READ BUFFER' ROUTINE SAME AS CP/M FUNCTION 10, BUT DOES
; NOT USE CTL-C (REASON FOR THE ROUTINE).  DOES ALLOW CONTROLS U, R, E
; AND H (BACKSPACE).  OUTPUTS BELL IF THE INPUT IS GREATER THAN THE
; BUFFER.
;
INBUF:	  PUSH	PSW
	  PUSH	H
	  PUSH	B 
	  PUSH	D		;DE REGISTERS MUST BE PUSHED LAST
;
INBUFA:	  CALL	CLEARBUF	;CLEAR THE BUFFER AREA
	  POP	D		;GET ADDRESS OF BUFFER ON RETRIES
	  PUSH	D		;RESTORE STACK
	  XRA	A
	  INX	D		;ADDRESS COUNT FIELD
	  STAX	D		;INITIALIZE WITH A ZERO IN COUNT BYTE
	  INX	D
	  XCHG			;ADDRESS FIRST BUFFER BYTE WITH HL
;
INBUFB:	  CALL	KEYIN		;(WAITS FOR CHAR)
	  CALL	UCASE		;..DITTO.
	  CPI	CR		;IS IT <RETURN> (ENTER COMMAND)?
	  JZ	INBUFR		;IF SO, THEN RETURN.
	  CPI	7FH		;IS IT A DELETE?
	  JZ	DELETE
	  CPI	8		;CTR-H BACKSPACES..
	  JZ	DELETE		;..OVER DELETED CHAR.
	  CPI	'U'-40H		;IS IT A CTL-U?
	  JZ	INBUFO		;OUTPUT #, CR, LF, AND START OVER
	  CPI	'R'-40H		;CTL-R RETYPES LINE
	  JZ	RETYPE
	  CPI	'E'-40H		;CTL-E OUTPUTS A CRLF
	  JZ	PCRLF
	  CPI	' '		;NO CONTROL CHARACTERS OTHER..
	  JC	INBUFB		;..THAN ABOVE ALLOWED.
	  MOV	B,A		;SAVE INPUTTED CHARACTER
	  XCHG			;SAVE HL IN DE
	  POP	H		;GET ADDRESS OF BUFFER IN HL
	  PUSH	H		;RESTORE STACK
	  INX	H		;ADDRESS COUNT BYTE
	  INR	M		;INCREASE COUNT BYTE
	  DCX	H		;ADDRESS MAXIMUM
	  MOV	A,M		;PUT MAXIMUM IN A
	  INX	H		;ADDRESS COUNT
	  CMP	M		;COMPARE COUNT TO MAXIMUM
	  JC	ALERTL		;IF MAXIMUM, RING BELL AND WAIT FOR CR.
	  XCHG			;RESTORE BUFFER POINTER TO HL
	  MOV	M,B		;PUT INPUTTED CHARACTER IN BUFFER
	  MOV	A,B		;OUTPUT IT
	  CALL	TYPE
	  INX	H		;BUMP POINTER
	  JMP	INBUFB		;GET NEXT CHARACTER
;...
;
;
DELETE:	  XCHG			;SAVE BUFFER POINTER IN DE
	  POP	H		;ADDRESS BEGINNING OF BUFFER
	  PUSH	H		;RESTORE STACK
	  INX	H		;ADDRESS COUNT FIELD
	  MOV	B,A		;SAVE DELETE CHAR, 7FH OR 08H.
	  MOV	A,M
	  SUI	1		;DECREASE COUNT
	  MOV	M,A
	  JC	NODEL		;DON'T DELETE PAST BEGINING OF BUFFER
	  XCHG			;RESTORE BUFFER POINTER TO HL
	  DCX	H		;POINT TO LAST BYTE INPUTTED
	  MOV	A,B		;GET BACK 7FH OR 08H
	  MOV	B,M		;GET CHARACTER BEING DELETED
	  MVI	M,' '		;RESTORE BLANK
	  CPI	8
	  JZ	BKSPC
	  CPI	7FH
	  JZ	BKSPC0
	  JMP	INBUFB		;GET NEXT CHARACTER
;.....
;
;
NODEL:	  INR	M		;DON'T LEAVE COUNT NEGATIVE
	  XCHG			;RESTORE POINTER TO HL
	  JMP	INBUFB
;.....
;
;
BKSPC0:	  MVI	A,08H
;
BKSPC:	  CALL	TYPE		;TRUE ERASE IF 08H
	  MVI	A,' '
	  CALL	TYPE
	  MVI	A,8
	  CALL	TYPE
	  JMP	INBUFB
;.....
;
;
INBUFO:	  MVI	A,'#'		;ANNOUNCES THE LINE HAS BEEN REMOVED
	  CALL	TYPE
	  CALL	CRLF
	  JMP	INBUFA
;.....
;
;
RETYPE:	  POP	D
	  PUSH	D
	  INX	D		;POINT TO CURRENT NUMBER..
	  LDAX	D		;..OF CHARACTERS.
	  MOV	B,A
	  MVI	A,'#'
	  CALL	TYPE
	  CALL	CRLF
	  MOV	A,B		;TEST IF ZERO INPUT
	  ORA	A
	  JZ	INBUFB
;...
;
;
CTLRLP:	  INX	D
	  LDAX	D
	  CALL	TYPE
	  DCR	B
	  JNZ	CTLRLP
	  JMP	INBUFB
;.....
;
;	
ALERTL:	  MVI	A,BELL		;ALARM FOR FULL BUFFER
	  CALL	TYPE
	  DCR	M
	  XCHG
	  JMP	INBUFB
;.....
;
;
PCRLF:	  CALL	CRLF
	  JMP	INBUFB
;.....
;
;
INBUFR:	  CALL	CRLF		;1ST NEW LINE AFTER A COMMAND CHARACTER
	  POP	D
	  POP	B
	  POP	H
	  POP	PSW
	  RET
;.....
;
;
CLEARBUF: POP	D		;ACCOUNTS FOR CALL
	  POP	H		;ADDRESS BUFFER IN HL
	  PUSH	H		;RESTORE..
	  PUSH	D		;..STACK
	  MOV	B,M		;SAVE MAXIMUM IN B
	  INX	H		;POINT TO FIRST..
	  INX	H		;..BUFFER BYTE.
	  MVI	A,' '
;
CLEARL:	  MOV	M,A
	  INX	H
	  DCR	B
	  JNZ	CLEARL
	  RET
;.....
;
;
;=======================================================================
;
; IN-LINE COMPARE.  COMPARES STRING ADDRESSED BY DE-REG TO STRING AFTER
; CALL (ENDS WITH ZERO).  RETURN WITH CARRY SET MEANS STRINGS NOT THE
; SAME.  ALL REGISTERS EXCEPT A-REG ARE UNAFFECTED.
;
INLNCOMP: XTHL			;POINT HL TO 1ST CHAR.
	  PUSH	D
;
ILCOMPL:  MOV	A,M		;HL POINTS TO IN-LINE STRING.
	  ORA	A		;END OF STRING IF ZERO.
	  JZ	SAME
	  LDAX	D
	  CMP	M
	  JNZ	NOTSAME
	  INX	H
	  INX	D
	  JMP	ILCOMPL
;...
;
;
NOTSAME:  XRA	A		;IF NOT SAME, FINISH THRU..
;
NSLP:	  INX	H		;..STRING SO RETURN WILL..
	  CMP	M		;..GO TO INSTRUCTION AFTER..
	  JNZ	NSLP		;..STRING AND NOT REMAINDER OF STRING.
	  STC
;
SAME:	  POP	D
	  INX	H		;AVOIDS A NOP INSTRUCTION..
	  XTHL			;..WHEN RETURNING.
	  RET
;.....
;
;
;=======================================================================
;
; MULTI-FILE ACCESS SUBROUTINE.  ALLOWS PROCESSING OF MULTIPLE FILES
; (I.E., *.ASM) FROM DISK.  BUILDS THE CORRECT NAME IN THE FCB EACH TIME
; IT IS CALLED.  THE COMMAND IS USED IN PROGRAMS TO PROCESS SINGLE OR 
; MULTIPLE FILES.  THE FCB IS SET UP WITH THE NEXT NAME, READY TO DO
; NORMAL PROCESSING (OPEN, READ, ETC.) WHEN ROUTINE IS CALLED.  CARRY IS
; SET IF NO MORE NAMES ARE FOUND.
                
MFNAME:	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MVI	C,SETDMA
	  LXI	D,80H
	  CALL	BDOS
	  POP	H
	  POP	D
	  POP	B
	  XRA	A
	  STA	FCBEXT
	  LDA	MFFLG1
	  ORA	A
	  JNZ	MFNAME1
	  MVI	A,1
	  STA	MFFLG1
	  LXI	H,FCB
	  LXI	D,MFNAME5
	  LXI	B,12
	  CALL	MOVER
	  LDA	FCB
	  STA	MFNAME6		;SAVE DISK IN CURR FCB
 	  LXI	H,MFNAME5
	  LXI	D,FCB
	  LXI	B,12
 	  CALL	MOVER
 	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MVI	C,SRCHF
	  LXI	D,FCB
	  CALL	BDOS
	  POP	H
	  POP	D
	  POP	B
	  JMP	MFNAME2
;...
;
;
MFNAME1:  LXI	H,MFNAME6
	  LXI	D,FCB
	  LXI	B,12
	  CALL	MOVER
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MVI	C,SRCHF
	  LXI	D,FCB
	  CALL	BDOS
	  POP	H
	  POP	D
	  POP	B
	  LXI	H,MFNAME5
	  LXI	D,FCB
	  LXI	B,12
	  CALL	MOVER
	  PUSH	B
	  PUSH	D
	  PUSH	H
	  MVI	C,SRCHN
	  LXI	D,FCB
	  CALL	BDOS
	  POP	H
	  POP	D
	  POP	B
;
MFNAME2:  INR	A
	  STC
	  JNZ	MFNAME3
	  STA	MFFLG1
	  RET
;.....
;
; 	
MFNAME3:  DCR	A
	  ANI	3
	  ADD	A
	  ADD	A
	  ADD	A
	  ADD	A
	  ADD	A
	  ADI	81H
	  MOV	L,A
	  MVI	H,0
	  PUSH	H		;SAVE NAME POINTER
	  LXI	D,MFNAME6+1
	  LXI	B,11
	  CALL	MOVER
	  POP	H
	  LXI	D,FCB+1
	  LXI	B,11
	  CALL	MOVER
	  XRA	A
	  STA	FCBEXT
	  STA	FCBRNO
	  RET
;.....
;
;
MOVER:	  MVI	A,2
	  INR	A
	  JPE	MFNAME4
	  DB	0EDH,0B0H	;Z-80 'LDIR' INSTUCTION
	  RET
;.....
;
;	
MFNAME4:  MOV	A,M		;USED IF AN 8080 CPU IS ACTIVE
	  STAX	D
	  INX	H
	  INX	D
	  DCX	B
	  MOV	A,B
	  ORA	C
	  JNZ	MFNAME4
	  RET
;.....
;
;
;=======================================================================
;
; SHOWS BAUD RATES SET FOR 'TIME TO SEND' FILE TRANSFER.
;
PRTBAUD:  LXI	H,BAUDSPD
	  MVI	D,0
	  LDA	MSPEED		;GET BAUD RATE CODE
	  MOV	E,A		;X1
	  ADD	A		;X2
	  ADD	A		;X4
	  ADD	E		;X5
	  MOV	E,A
	  DAD	D		;POINT TO CORRECT RATE
	  XCHG
	  MVI	C,PRINT
	  CALL	BDOS
	  CALL	ILPRT
	  DB	' baud',CR,LF,0
	  RET
;.....
;
;
BAUDSPD	  DB	'110$',0,'300$',0,'450$',0,'600$',0,'710$',0
	  DB	'1200$','2400$','4800$','9600$'
;.....
;
;
;=======================================================================
;
; SHOWS THE TIME TO TRANSFER A FILE AT VARIOUS BAUD RATES.  (110-9600)
;
SENDTIME: CALL	ILPRT	        ;PRINT FOLLOWING MESSAGE:
	  DB	'File open: ',0
	  LHLD	RCNT		;GET RECORD COUNT.
	  CALL	DECOUT		;PRINT DECIMAL NUMBER OF RECORDS
	  CALL	ILPRT
	  DB	' (',0
	  CALL	DHXOUT		;NOW PRINT SIZE IN HEX.
	  CALL	ILPRT
	  DB	'H) records',CR,LF
	  DB	'Send time: ',0
	  LDA	MSPEED		;GET THE SPEED INDICATOR
	  MVI	D,0
	  MOV	E,A		;SET UP FOR TABLE ACCESS
	  LXI	H,BTABLE	;POINT TO BAUD FACTOR TABLE
	  DAD	D		;INDEX TO PROPER FACTOR
	  DAD	D		;FACTOR IN DE
	  MOV	E,M
	  INX	H
	  MOV	D,M
	  LHLD	RCNT		;GET # OF RECORDS
	  CALL	DVHLDE		;DIVIDE 'HL' BY VALUE IN DE (RECORDS/MIN)
	  PUSH	H
	  MOV	L,C
	  MOV	H,B
	  CALL	DECOUT		;PRINT THE MINUTES PORTION
	  CALL	ILPRT
	  DB	' mins, ',0
	  LXI	H,RECDBL	;POINT TO DIVISORS FOR SECONDS
	  LXI	D,0		;   CALCULATION
	  LDA	MSPEED		;GET INDEX FOR BAUD RATE
	  MOV	E,A
	  DAD	D		;INDEX INTO TABLE
	  MOV	A,M		;GET MULTIPLIER
	  POP	H		;GET REMAINDER
	  CALL	MULHLA		;MULTIPLY THE 'HL' X 'A'
	  CALL	SHFTHL
	  CALL	SHFTHL
	  CALL	SHFTHL
	  CALL	SHFTHL	
	  MVI	H,0
	  CALL	DECOUT		;PRINT THE SECONDS PORTION
	  CALL	ILPRT
	  DB	' secs at ',0
	  CALL	PRTBAUD
	  CALL	ILPRT
          DB	'To cancel: use CTL-X',CR,LF,0
	  RET
;.....
;
;
BTABLE:	DW	5,13,19,25,29,48,96,192,384,0	;RECORDS/MIN FOR..
RECDBL:	DB	192,74,51,38,33,20,11,5,3,0	;..110-9600 BAUD
;
;	
;---->  DVHLDE: DIVIDES 'HL' BY VALUE IN 'DE',
;	UPON EXIT: 'BC'=QUOTIENT,'L'=REMAINDER
;
DVHLDE:	  PUSH	D		; SAVE DIVISOR
	  MOV	A,E
	  CMA			; NEGATE DIVISOR
	  MOV	E,A
	  MOV	A,D
	  CMA
	  MOV	D,A
	  INX	D		; DE IS NOW TWOS COMPLEMENTED
	  LXI	B,0		; INIT QUOTIENT
;
DIVL1:	  DAD	D		; SUBTRACT DIVISOR FROM DIVIDEND
	  INX	B		; BUMP QUOTIENT
	  JC	DIVL1		; LOOP TILL SIGN CHANGES
	  DCX	B		; ADJUST QUOTIENT
	  POP	D		; RETRIEVE DIVISOR
	  DAD	D		; ADJUST REMAINDER
	  RET
;.....
;
;
;---->  MULHLA:  MULTIPLY THE VALUE IN 'HL' BY THE VALUE IN 'A'
;		 RETURN WITH ANSWER IN 'HL'
;
MULHLA:	  XCHG			; MULTIPLICAND TO DE
	  LXI	H,0		; INIT PRODUCT
	  INR	A		; ADJUST MULTIPLIER FOR ZERO TEST
;
MULLP:	  DCR	A
	  RZ
;
	  DAD	D
	  JMP	MULLP
;.....
;
;
;  SHIFT 'HL' REGISTER PAIR ONE BIT TO THE RIGHT
;
SHFTHL:	  MOV	A,L
	  RAR
	  MOV	L,A
	  ORA	A		;CLEAR THE CARRY
	  MOV	A,H
	  RAR
	  MOV	H,A
	  RNC
	  MVI	A,80H
	  ORA	L
	  MOV	L,A
	  RET
;.....
;
;
;=======================================================================
;
;		PMMI BAUD RATE INITIALZATION
;
;=======================================================================
;
GETBAUD:  LDA	FCB+9		;GET 1ST DIGIT OF REQUESTED BAUDRATE
	  CPI	' '		;IF A SPACE RETURN WITH 300 BAUD
	  MVI	A,52
	  RZ
	  LDA	FCB+9
	  ORA	A		;IF A NULL RETURN WITH 300 BAUD
	  MVI	A,52
	  RZ
	  LXI	D,FCB+9
	  LXI	H,0
;
DECLP:	  LDAX	D
	  INX	D
	  CPI	' '
	  JZ	DECLP
	  CPI	'0'		;NUMERALS ARE 0-9
	  JC	BADRATE
	  CPI	'9'+1
	  JNC	BADRATE
	  SUI	'0'
	  MOV	B,H
	  MOV	C,L
	  DAD	H
	  DAD	H
	  DAD	B
	  DAD	H
	  ADD	L
	  MOV	L,A
	  JNZ	DIGNC
	  INR	H
;
DIGNC:	  MOV	A,E
	  CPI	FCB+12
	  JNZ	DECLP
	  MOV	A,H
	  CMA
	  MOV	D,A
 	  MOV	A,L
	  CMA
	  MOV	E,A
	  INX	D
	  LXI	H,15625		;250000/16
	  LXI	B,-1
;
DIVLP:	  INX	B
	  DAD	D
	  JC 	DIVLP
	  MOV	A,B
	  ORA	A
	  MOV	A,C
	  RZ
;
BADRATE:  CALL	ERXIT
	  DB	'++ INVALID BAUDRATE ++$'
;...
;
;
CHGMSPD:  MVI	C,0		;CHANGES PMMI MSPEED FOR 110-1200 BAUD
	  CPI	100		;<300 BAUD
	  RNC
	  INR	C		;C=1 FOR 300 BAUD
	  CPI	40		;<450 BAUD
	  RNC
	  INR	C		;C=2 FOR 450 BAUD
	  CPI	30		;<600 BAUD
	  RNC
	  INR	C		;C=3 FOR 600 BAUD
	  CPI	24		;<710 BAUD
	  RNC
	  INR	C		;C=4 FOR 710 BAUD
	  RET
;.....
;
;
; The non-PMMI setup routines can go here.  The following is a starting
; point.  Several hundreds of bytes are available.
;
SETUPR:	  RET
;.....
;
;
;=======================================================================
;
;	PMMI DIALING ROUTINES
;
;=======================================================================
;
; Dialing routines taken (and greatly modified) from PMMI manual.
;
; Modem control command words
;
CLEAR:	  EQU	3FH		;IDLE MODE
MAKEM:	  EQU	1		;TELE LINE MAKE (OFF HOOK)
BRKM:	  EQU	0		;TELE LINE ON HOOK (BREAK DURING DIALING)
DTMSK:	  EQU	1		;DIAL TONE MASK
RBLMT:	  EQU	35		;7 SECONDS TO WAIT TIL NO-RING-HEARD MSG
RBWAIT:	  EQU	50		;5 SECOND DELAY BEFORE REDIALING NUMBER
TMPUL:	  EQU	80H		;TIMER PULSES MASK BIT
TRATE:	  EQU	250		;VALUE FOR 0.1 SECOND
;.....
;
; Dialing routine
;
DIAL:	  LDA	PMMIBYTE	;USING A PMMI MODEM?
	  ORA	A
	  RZ			;IF NOT, SKIP AUTO-DIALING ROUTINE
;
	  XRA	A
	  STA	CRFLAG		;ZERO THE CONTINUOUS DIAL FLAG
	  STA	RINGBKFL	;ZERO THE RINGBACK FLAG
	  LXI	H,0
	  SHLD	DIALCT		;ZERO THE DIAL COUNT
	  LXI	H,CMDBUF+1	;POINT TO THE NUMBER OF CHARACTERS IN..
	  MOV	A,M		;..THE BUFFER, THEN GET THE NUMBER
	  CPI	3+1		;ANYTHING TYPED AFTER "CAL"?
	  JC	DIAL1		;IF NOT, GO THROUGH LIBRARY ROUTINE
;
;
; If there were only 3 characters, then "CAL<RET>" was typed -- the user
; obviously expecting to get a phone number (or letter) from the library
; file.  If 4 or more, a number (or letter) was typed in from the menu
; command line, so move the characters down 4 to compensate.  Needed for
; auto-redialing of menu command line entries.
;
	  MOV	C,A		;PUT INTO THE 'C' REG.
	  MVI	B,0		;WILL MOVE ORIGINAL NUMBER DOWN 4
	  SUI	4		;ELIMINATE THE "CAL " PORTION
	  MOV	M,A		;STORE NEW COUNT AT CMDBUF+1
	  INX	H		;CMDBUF+2 (FIRST CHAR. OF STRING)
	  XCHG			;'DE' NOW HAS CMDBUF+2
	  LXI	H,CMDBUF+6	;POINT TO NUMBER (OR LETTER) TO DIAL
	  CALL	MOVER		;MOVE THE GROUP DOWN 4 PLACES
	  JMP	DIAL4		;CHECK IF LIBRARY NUMBER, THEN DIAL
;...
;
;
; Comes here if no phone number was manually entered after "CAL" and if
; no phone library letter was entered.  Displays the phone number library
; then asks for an entry.
;
DIAL1:	  MVI	C,13		;NUMBER OF LINES TO MOVE
	  LXI	H,NUMBLIB	;START OF PHONE NUMBER LIBRARY
	  LXI	D,DBUF		;BUFFER ADDRESS TO STORE THEM TEMPORARILY
	  CALL	NEWLINE		;START WITH CRLF
	  STAX	D		;+LF
	  INX	D		;AND BUMP IT
;
DIAL2:	  MVI	B,LIBLEN	;NUMBER OF BYTES TO MOVE
	  CALL	MOVE		;MOVE TO BUFFER
	  CALL	SPACES		;2 ENTRIES + 3 SPACES = 71 CHARACTERS
	  MVI	B,LIBLEN
	  CALL	MOVE
	  CALL	NEWLINE
	  DCR	C		;ONE LESS LINE TO PRINT
	  JNZ	DIAL2		;IF NOT ZERO, PRINT ANOTHER
;
DIAL3:	  MVI	A,'$'		;BDOS PRINT ROUTINE TERMINATE CHARACTER
	  STAX	D		;STORE IN BUFFER
	  CALL	CLRTST
	  MVI	C,PRINT
	  LXI	D,DBUF		;PRINT THE LIBRARY ON THE CRT
	  CALL	BDOS
	  CALL	ILPRT		;ASK WHICH ONE IS WANTED
	  DB	CR,LF,'Enter number or library letter - <CR> '
	  DB	'when finished,',CR,LF
	  DB	'CTL-X cancels while dialing: ',0
	  LXI	D,CMDBUF
	  CALL	INBUF
;
; You now have either a library letter or a manually entered phone num-
; ber.  These either came from the menu command line or from the library
; command line.  Next we see if a letter, if so, get the corresponding
; line with phone number from the library.  If a number we ignore the
; library look-up.  (Ringback numbers must end with letter 'R'.)
;
DIAL4:	  LXI	H,CMDBUF+1	;NUBER OF CHARACTERS IN BUFFER
	  MOV	A,M
	  ORA	A		;NULL MEAND <CR> WAS TYPED
	  JZ	DIALEXIT	;ABORT DIALING, RETURN TO MENU
	  INX	H		;FIRST TYPED CHAR OF NUMBER TO DIAL
	  CALL	DIALBGN		;DISCONNECT, RECONNECT, WAIT FOR TONE
	  JC	DIALEXIT	;IF NO DIALTONE, PONDER NEXT MOVE
	  MVI	B,'A'		;FIRST LETTER OF ALPHABET
	  MVI	E,0		;COUNTS NUMBER OF LETTERS TO MATCH
	  MVI	C,26		;NUMBER OF LETTERS IN ALPHABET
	  MOV	A,M		;GET CHAR BUFFER
;
DIAL5:	  CMP	B		;NUMBER FROM TABLE?
	  JZ	DIAL6
	  INR	B		;MAKE NEXT LETTER (A-Z)
	  INR	E		;COUNT UP
	  DCR	C		;COUNT DOWN
	  JZ	DIAL9		;WAS NOT A-Z SO EXIT
	  JMP	DIAL5		;LOOP
;
;
; Now have a match between the requested letter and one in the library
; 'E' holds the decimal equivalent (1-26) of the letter (A-Z).
;
DIAL6:	  LXI	H,NUMBLIB	;PHONE NUMBER LIBRARY
	  LXI	B,LIBLEN	;LENGTH OF LIBRARY ENTRY
	  MOV	A,E		;NUMBER OF TIMES TO LIBRARY LENGTH TO HL
	  ORA	A		;SET FLAGS
	  JZ	DIAL8
;
DIAL7:	  MOV	A,M		;GET FIRST CHAR OF SELECTED LIB ENTRY
	  ORA	A		;SET FLAGS
	  JZ	DIALBAD		;SEND BAD LIBRARY MSG AND ABORT
	  DAD	B		;INCREMENT 'HL' BY LIBRARY LENGTH
	  DCR	E		;COUNTDOWN
	  JNZ	DIAL7		;NOT THERE YET, LOOP
;
;
; Now have the line in the phone number library matching the requested
; letter so store that line starting at 'CMDBUF+1'
;
DIAL8:	  MVI	B,LIBLEN	;NUMBER OF CHARACTERS TO GET FROM TABLE
	  LXI	D,CMDBUF+1	;POINT TO BUFFER
	  XCHG			;'HL' POINTS TO CMDBUF+1
	  MOV	M,B		;LENGTH OF EACH TABLE ENTRY
	  XCHG			;RESTORE THE REGISTERS
	  INX	D		;POINT TO FIRST CHAR POSITION IN BUFFER
	  CALL	MOVE		;MOVE THE TABLE ENTRY TO THE BUFFER
;
;
; Now have the full line including phone number in 'CMDBUF' area.
;
DIAL9:	  LXI	H,CMDBUF+1
	  MOV	E,M		;NUMBER OF CHARS IN BUFF
	  INX	H		;POINT TO 1ST CHAR. TO DIAL
;
DIAL10:	  MOV	A,M		;GET FIRST NUMBER FROM THE BUFFER
	  ORA	A		;SET FLAGS
	  JZ	DIALBAD		;BUM NUMBER IF A NULL
;
;
; Dial a digit, check keyboard for abort
;
	  CALL	DIALA		;SHOW THE STRING, DIAL THE NUMBER
;
	  CALL	STAT		;KEYPRESS?
	  ORA	A		;SET FLAGS
	  CNZ	KEYIN		;YES, GO GET IT
	  CPI	CAN		;CTL-X?
	  JZ	DIALEXIT	;YES, ABORT
	  INX	H		;BUMP POINTER
	  PUSH	D		;SAVE DE
	  PUSH	H		;SAVE HL
	  MVI	B,1		;WAIT 0.1 SECOND (ONE TIMER INTERVAL)
	  CALL	TIMER
	  POP	H		;RESTORE HL
	  POP	D		;RESTORE DE	
	  DCR	E		;ONE LESS CHARACTER TO GO
	  JNZ	DIAL10		;IF NOT DONE, LOOP
;
;
; Show the number of dial attempts
;
	  CALL	ILPRT
	  DB	'  try #',0
	  LHLD	DIALCT		;INCREMENT THE DIAL COUNT
	  INX	H
	  SHLD	DIALCT
	  CALL	DECOUT		;SHOW NUMBER OF ATTEMPTS SO FAR
;
;
; Dialing is all done
;
	  CALL	CRLF
	  MVI	A,07FH		;TURN ON 'DTR'
	  CALL	OUT$MODCTL2	;TIMER RATE?
	  MVI	B,1		;0.1 SECOND PER INTERVAL
	  CALL	TIMER		;WAIT FOR MODEM TO TURN ON 'DTR'
;MOD(BGL)***
	  LDA	PARTY		;DEFAULT PARITY SET, NORMALLY
				;..1 STOP BIT, NO PARITY, 8 DATA
				;..BITS, NO DISCON. AFTER 17 SEC
	  CALL	OUT$MODCTLP
	  MVI	D,4		;CLEAR TO SEND MASK
	  MVI	C,WAITCTS	;WAIT TIME FOR CTS..
	  CALL	WAIT		;..(30 SECONDS, CAN SET 'WAITCTS' FOR
;                               ;..UP TO 51 SECONDS FOR EUROPEAN USE)
;
; If connection made, go get options for starting communications
;
	  JNC	CONMADE		;CONNECTION MADE
;
;
; Connection not made, see if a redial is desired
;
	  CALL	DISCONNT	;HANG-UP SO WE CAN REDIAL IF DESIRED
;
DIALAGN:  LDA	CRFLAG		;CONTINUOUS REDIAL FLAG
	  ORA	A
	  JNZ	DIALAGN1	;IF ALREADY SET, GO DIAL AGAIN
	  CALL	ILPRT		;IF NOT, SEE IF SHOULD REDIAL AGAIN
	  DB	CR,LF,'No answer after time-out.  Redial? '
	  DB	'(Y/N/C): ',BELL,0
	  CALL	KBDCHR
	  CALL	CRLF		;NEW LINE
	  CPI	'N'		;REDIAL?
	  JZ	MENU		;NO, GO MENU
	  CPI	'Y'		;REDIAL?
	  JZ	DIALAGN1	;YES, REDIAL
	  CPI	'C'		;CONTINUOUS REDIAL?
	  JNZ	DIALAGN		;INVALID RESPONSE, ASK AGAIN
	  MVI	A,TRUE		;SET TRUE
	  STA	CRFLAG		;CONTINUOUS REDIAL FLAG
;
DIALAGN1: MVI	B,RBWAIT	;5 SECONDS WAIT FOR PMMI RESET (OR BUSY)
	  CALL	TIMER		;OR BUSY TONE MAY BE SENSED AS DIALTONE
	  LDA	RINGBKFL	;RINGBACK FLAG SET?
	  ORA	A
	  JZ	DIAL4		;IF NOT, GO REDIAL A NORMAL NUMBER
	  STA	CMDBUF+1	;RESTORE ORIGINAL VALUE INCLUDING THE 'R'
	  JMP	DIAL4		;REDIAL ENTRY POINT
;.....
;
;
; Connection has been made
;
CONMADE:  CALL	ILPRT
	  DB	CR,LF,'Connection established - Select options: '
	  DB	BELL,0
;
CONMAD1:  CALL	STAT		;KEYPRESS?
	  ORA	A		;SET FLAGS
	  JNZ	GETCMD		;KEY PRESSED, GO GET OPTIONS
	  MVI	A,BELL
	  CALL	TYPE		;RING BELL
	  LXI	B,2000H
;
CONMAD2:  DCR	C
	  JNZ	CONMAD2		;KILL SOME TIME FOR TERMINAL..
	  DCR	B		;..PROCESS THE BELL
	  JNZ	CONMAD2
	  JMP	CONMAD1		;LOOP UNTIL CONNECTED
;.....
;
;
; Automatic dialing routine, prints the number being dialed
;
DIALA:	  CALL	TYPE		;PRINT WHATEVER CHARACTER, DASHES, ETC.
	  CPI	'R'		;COULD IT BE A RINGBACK CHARACTER?
	  JNZ	DIALA1		;IF NOT, PROBABLY A NUMBER SO EXIT
	  PUSH	PSW		;SAVE ACCUMULATOR & FLAGS
	  MOV	A,E		;GET THE CHARACTER COUNT.  IS THIS "R"..
	  CPI	1		;..THE LAST CHARACTER IN THE STRING?
	  JZ	RINGBK		;YES, MUST BE RINGBACK CHAR, DO RINGBACK
	  POP	PSW		;EVERYTHING BACK AS IT WAS
;
DIALA1:   CPI	'0'		;DIGITS ARE 0-9
	  RC			;EXIT LESS THAN ASCII '0'
	  CPI	'9'+1
	  RNC			;EXIT IF MORE THAN ASCII '9'
	  SUI	'0'		;STRIP ASCII -- COULD ALSO DO 'ANI 0FH'
	  JNZ	DIALA2
	  MVI	A,10		;CONVERT ZERO TO 10 PULSES
;
DIALA2:	  MOV	C,A
	  LDA	PULSERATE	;CONTAINS VALUE FOR DIAL SPEED
	  CALL	OUT$BAUDRP
;
DIALA3:	  CALL	IN$BAUDRP
	  ANI	TMPUL
	  JNZ	DIALA3
;
DIALA4:	  CALL	IN$BAUDRP
	  ANI	TMPUL
	  JZ	DIALA4
;
DIALA5:	  MVI	A,MAKEM
	  CALL	OUT$MODCTLP
;
DIALA6:	  CALL	IN$BAUDRP
	  ANI	TMPUL
	  JNZ	DIALA6
	  MVI	A,BRKM
	  CALL	OUT$MODCTLP
;
DIALA7:	  CALL	IN$BAUDRP
	  ANI	TMPUL
	  JZ	DIALA7
	  DCR	C
	  JNZ	DIALA5
	  MVI	A,MAKEM
	  CALL	OUT$MODCTLP
;MOD(BGL)***
	  MVI	B,8		;0.1 SECOND PER TIMER INTERVAL
	  JMP	TIMER		;RETURN TO CALLER
;.....
;
;
; Print bad library number message and abort if a null is encountered.
;
DIALBAD:  CALL	ILPRT
	  DB	CR,LF,'++ Bad library number called ++',CR,LF,0
;
DIALEXIT: CALL	DISCONNT	;ABORT ROUTINE
	  CALL	CRLF
	  JMP	MENU
;.....
;
;
; Disconnect from the line, reconnect and wait for the dialtone.
;
DIALBGN:  CALL	DISCONNT
	  CALL	ILPRT
	  DB	CR,LF,'Waiting for dial tone',CR,LF,0
	  MVI	A,MAKEM		;MAKE MAKE (OFF-HOOK)
	  CALL	OUT$MODCTLP	;DO IT
	  MVI	D,DTMSK		;DIAL TONE MASK
	  MVI	C,50		;WAITS UP TO 10 SEC. FOR DIAL TONE
	  CALL	WAIT		;WAIT FOR DIAL TONE
;
;
; Wait subroutine will return with carry set if unable to get dialtone.
; If carry is not set, the dialtone was received.
;
	  RNC			;IF DIAL TONE WITHIN 10 SECONDS
	  CALL	ILPRT		;ELSE, MESSAGE AND RETURN WITH CARRY SET
	  DB	CR,LF,'++ NO DIAL TONE ++',CR,LF,0
	  CALL	DISCONNT
	  STC			;SET THE CARRY BIT (NO DIALTONE)
	  RET
;.....
;
;
DISCONNT: XRA	A		;0
	  CALL	OUT$MODCTL2 	;CLEAR DAV, ESD, ETC
	  CALL	OUT$MODCTLP 	;HANG-UP
	  PUSH	B
	  MVI	B,8		;WAIT FOR PMMI TO DISCONNECT (0.8 SEC)
	  CALL	TIMER		;0.1 SECOND PER TIMER INTERVAL
	  POP	B
	  RET
;.....
;
;
HANGUP:   MVI	A,CLEAR
	  CALL	OUT$MODCTL2
	  MVI	A,0
	  CALL	OUT$MODCTLP
	  RET
;.....
;
;
; Handles the special ringback numbers.  Dials, lets it ring only once,
; hangs up and then redials.
;
RINGBK:	  POP	PSW		;TO GET IT OFF THE STACK
	  LDA	CMDBUF+1	;GET THE NUMBER OF CHARS. IN THE BUFFER
	  STA	RINGBKFL	;STORE ORIGINAL NUMBER INCLUDING THE 'R'
	  SUI	1		;SUBTRACT 1 TO AVOID THE RINGBACK CHAR
	  STA	CMDBUF+1	;STORE THE NEW VALUE
	  MVI	D,DTMSK		;LOAD TONE DETECT MASK
	  MVI	C,RBLMT		;WAITS UP TO 7 SECONDS FOR A RING
	  CALL	WAIT
	  JC	RBTIME		;JUMP IF NO RING DETECTED
	  MVI	B,25		;GOT A RING, WAIT 2.5 SEC
	  CALL	TIMER
	  CALL	IN$BAUDRP	;IS TONE STILL PRESENT?
	  ANA	D
	  JZ	DIALAGN		;YES, MUST BE BUSY
;.....
;
;
; Hang up, redial and listen for dial tone
;
RNGBK1:	  CALL	HANGUP		;HANG UP THE PHONE
	  MVI	B,RBWAIT	;WAIT 5 SECONDS BEFORE REDIALING..
	  CALL	TIMER		;..FOR LINE TO CLEAR, ETC.
	  CALL	DIALBGN		;DISCONNECT, RECONNECT, WAIT FOR TONE
	  JNC	DIAL9		;GO REDIAL NUMBER
	  JMP	DIALAGN		;NO DIAL TONE HEARD
;.....
;
;
RBTIME:	  CALL	CRLF
	  JMP	RNGBK1		;HANGUP, REDIAL, & LISTEN FOR CARRIER
;.....
;
;
; PMMI timer routine.  Waits 0.1 seconds for each unit in 'B' reg.
;
TIMER:	  MVI	A,TRATE    	;TRATE 250, VALUE FOR .1 SEC INTERVAL
	  CALL	OUT$BAUDRP 	;'B' CONTAINS NUMBER OF .1 SEC INTERVALS
;
TIMER1:   CALL	IN$BAUDRP  	;TO COUNT
	  ANI	TMPUL
	  JZ	TIMER1      	;WAIT FOR TIMER TO GO HIGH
;
TIMER2:	  CALL	IN$BAUDRP
	  ANI	TMPUL
	  JNZ	TIMER2      	;WAIT FOR TIMER TO GO LOW
	  DCR	B
	  JNZ	TIMER1
	  RET
;.....
;
;
; Time-out routine.  Must be called with mask in 'D' reg. for input at
; relative port 2 and number of seconds (times 10) in 'C' reg.
;
WAIT:	  MVI	B,2	
	  CALL	TIMER		;WAIT FOR TIMER TO GO HIGH THEN LOW
	  CALL	IN$BAUDRP	;PMMIADDR+2 (MODEM STATUS PORT)
	  ANA	D		;(CTS or DIALTONE MASK)
	  RZ			;ACTIVE LOW, SO RETURN ON 0
	  PUSH	B		;SAVE..
	  PUSH	D		;..ACTIVE REG'S
	  CALL	STAT		;KEYPRESS?
	  ORA	A		;SET FLAGS
	  CNZ	KEYIN		;YES, GET CHAR
	  CPI	CAN		;CTL-X TO INTENTIONALLY ABORT?
	  JZ	WAIT1		;YES, DISCONNECT, JMP TO MENU
	  POP	D		;RESTORE..
	  POP	B		;..REGS
	  DCR	C		;COUNT-DOWN
	  JNZ	WAIT
	  STC			;SET CARRY TO INDICATE MASK NOT SET
	  RET
;.....
;
;
WAIT1:	  POP	D		;RESET..
	  POP	B		;..STACK
	  JMP	DISCON1		;DISCONNECT
;.....
;
;
;		(END OF PMMI DIALING ROUTINE)
;
;=======================================================================
;***********************************************************************
;*								       *
;*   CRCSUBS (Cyclic Redundancy Code Subroutines) version 1.20 8080    *
;*   Mnemonics							       *
;*								       *
;*     These subroutines will compute and check a true 16-bit Cyclic   *
;*   Redundancy Code for a message of arbitrary length.		       *
;*								       *
;*     The use of this scheme will guarantee detection of all single   *
;*   and double bit errors, all errors with an odd number of error     *
;*   bits, all burst errors of length 16 or less, 99.997% of all 17-   *
;*   bit error bursts and 99.998% of all possible longer error bursts. *
;*   (Ref: Computer Networks, Andrew S. Tanenbaum, Prentiss-Hall 1981) *
;*								       *
;*	This program may be freely reproduced for non-profit use.      *
;*	Copyrighted 1981, Carpenter Associates, Bloomfield Hills, MI   *
;*								       *
;***********************************************************************
;
;
;	ENTRY	CLRCRC,UPDCRC,FINCRC,CHKCRC
;
CLRCRC:	  PUSH	H		;RESET CRC ACCUMULATOR FOR A NEW MESSAGE
	  LXI	H,0
	  SHLD	CRCVAL
	  POP	H
	  RET
;.....
;
;
UPDCRC:	  PUSH	PSW		;UPDATE CRC ACCUMULATOR USING BYTE IN 'A'
	  PUSH	B
	  PUSH	H
	  MVI	B,8
	  MOV	C,A
	  LHLD	CRCVAL
;
UPDLOOP:  MOV	A,C
	  RLC
	  MOV	C,A
	  MOV	A,L
	  RAL
	  MOV	L,A
	  MOV	A,H
	  RAL
	  MOV	H,A
	  JNC	SKIPIT
	  MOV	A,H		;THE GENERATOR IS X^16 + X^12 + X^5 + 1
	  XRI	10H		;  AS RECOMMENDED BY CCITT.
	  MOV	H,A		;  AN ALTERNATE GENERATOR WHICH IS OFTEN
	  MOV	A,L		;  USED IN SYNCHRONQOUS TRANSMISSION
	  XRI	21H		;  PROTOCOLS IS X^16 + X^15 + X^2 + 1.
	  MOV	L,A		;  THIS MAY BE USED BY SUBSTITUTING
;
SKIPIT:	  DCR	B		;  XOR 80H FOR XOR 10H, AND XOR 05H FOR
	  JNZ	UPDLOOP		;  21H IN THE ADJACENT CODE.
	  SHLD	CRCVAL
	  POP	H
	  POP	B
	  POP	PSW
	  RET
;.....
;
;
FINCRC:	  PUSH	PSW		;FINISH CRC CALCULATIONS FOR OUTPUT MSG
	  XRA	A
	  CALL	UPDCRC
	  CALL	UPDCRC
	  PUSH	H
	  LHLD	CRCVAL
	  MOV	D,H
	  MOV	E,L
	  POP	H
	  POP	PSW
	  RET
;.....
;
;
CHKCRC:	  PUSH	H		;CHECK CRC BYTES OF RECEIVED MESSAGE
	  LHLD	CRCVAL
	  MOV	A,H
	  ORA	L
	  POP	H
	  RZ
	  MVI	A,0FFH
	  RET
;.....
;
;
;***********************************************************************
;
;                             MENU
;
;***********************************************************************
;
;
MENU0:	  LDA	NFILFLG
	  ORA	A
	  JNZ	MENU		;GO IF NO FILE ACTIVE
	  CALL	ILPRT		;ELSE PRINT MESSAGE
	  DB	CR,LF
	  DB	'** There may be text in the memory buffer.  It will **'
	  DB	CR,LF
	  DB	'** be lost unless the NOL or WRT commands are used. **'
	  DB	CR,LF,BELL,0
	  JMP	MENU1
;
MENU:	  XRA	A
	  STA	ABORTFLG	;NULL THE FLAG
	  LDA	EXITFLG
	  ORA	A
	  JNZ	EXIT		;IF SET, EXIT
;
MENU1:	  LXI	H,RESTSN	;RESTORE RECORD NUMBERS..
	  LXI	D,RECDNOB 	;..FOR NEW FILE TRANSFER.
	  MVI	B,RECDNOE-RECDNOB
	  CALL	MOVE
	  LXI	H,RESTROPT	;RESTORE OPTION TABLE
	  LXI	D,OPTBL
	  MVI	B,OPTBE-OPTBL
	  CALL	MOVE
	  XRA	A
	  STA	MFFLG1		;RESET MFACCESS ROUTINE..
	  CMA			;..AND MULTI TRANS IN CASE..
	  STA	FSTFLG		;..OF ABORT.
	  JMP	XPRT
;.....
;
;
; *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
;
;			 THE COMMAND MENU
;
; *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
;
MENU2:	  CALL	CLRTST
	  CALL	ILPRT
	  DB	'                  Single Letter Commands',CR,LF,LF
	  DB	' ?  - Display current settings',CR,LF
	  DB	' H  - Display this information',CR,LF
	  DB	' E  - Terminal mode with echo',CR,LF
	  DB	' L  - Terminal mode with local echo',CR,LF
	  DB	' T  - Terminal mode',CR,LF
	  DB	'         For copying text to disk use T (or E or L) '
	  DB	'FILENAME.TYP',CR,LF
	  DB	'         Start or Stop toggles described on subsequent '
	  DB	'screen.',CR,LF,LF
	  DB	' R  - Receive CP/M file using Christensen Protocol'
	  DB	CR,LF
	  DB	' S  - Send CP/M file using Christensen Protocol',CR,LF 
	  DB	'         Command: R (or S) FILENAME.TYP',CR,LF,LF
	  DB	'         R and S can use the following subcommands:'
	  DB	CR,LF
	  DB	'            B  - Bulk transfer using wildcards '
	  DB	'(e.g., *.*)',CR,LF
	  DB	'            Q  - Quiet mode (no messages to console)'
	  DB	CR,LF
	  DB	'            T  - Return to terminal mode after '
	  DB	'transfer',CR,LF
	  DB	'            V  - View bytes transferred on console'
	  DB	CR,LF,LF
	  DB	'      The single letter commands may also be used on '
	  DB	'the',CR,LF
	  DB	'      command line when the program is initially '
	  DB	'executed.',CR,LF,LF,0
;
	  CALL	NXTSCRN
;
	  LDA	PMMIBYTE
	  ORA	A
	  JZ	THREELTR	;IF NOT PMMI, SKIP THIS SPECIAL PAGE
	  CALL	ILPRT
	  DB	'            Additional Subcommands for PMMI Modem'
	  DB	CR,LF,LF
	  DB	'  Modem control:',CR,LF
	  DB	'    A - Answer tone for send or receive',CR,LF
	  DB	'    O - Originate tone for send or receive',CR,LF
	  DB	'    D - Disconnect from the phone line',CR,LF
	  DB	'    X - Disconnect, then reboot to CP/M',CR,LF,LF
	  DB	'  Parity option:',CR,LF
	  DB	'    1 - Set and check for odd parity',CR,LF
	  DB	'    0 - Set and check for even parity',CR,LF
	  DB	'           Both ends must be capable of these options'
	  DB	CR,LF
	  DB	'           which are available only in R and S modes.'
	  DB	CR,LF
	  DB	'           The parity checking will be part of the'
	  DB	CR,LF
	  DB	'           file transfer protocol.',CR,LF,LF
	  DB	'  Speed Options:',CR,LF
	  DB	'        After entering your primary and secondary '
	  DB	'options,',CR,LF
	  DB	'        you can set the modem speed by placing a '
	  DB	' "." after',CR,LF
	  DB	'        the options followed by the speed e.g., '
	  DB	'300, 1200.',CR,LF,LF
	  DB	'        EXAMPLE:  SBOT.600 will set the modem for '
 	  DB	'600 baud',CR,LF,LF,0
;
	  CALL	NXTSCRN
;
THREELTR: CALL	ILPRT
	  DB	'                Three Letter Commands',CR,LF
	  DB	'CPM - Exit from this program to CP/M',CR,LF
	  DB	'DIR - List directory and space free (may specify '
	  DB	'drive)',CR,LF
	  DB	'ERA - Erase file (may specify drive)',CR,LF
	  DB	'LOG - Change default drive/user no. (specify '
	  DB	'drive/user)',CR,LF
	  DB	'      and reset disks.  e.g. LOG A0: or LOG B:  '
	  DB	'(user # unchanged)',CR,LF
	  DB	'SPD - Set speed of file output in terminal mode'
	  DB	CR,LF,0
;
	  CALL	SORPTST
	  JNZ	NOTIME
	  CALL	ILPRT
	  DB	'TIM - Select Baud rate for "time-to-send" msg.',CR,LF,0
;
NOTIME:	  LDA	TOGGLECRC
	  ORA	A
	  JZ	NOTOGCRC
	  CALL	ILPRT
	  DB	'TCC - Toggle CRC/Checksum mode on receive',CR,LF,0
;
NOTOGCRC: LDA	TOGGLEBK
	  ORA	A
	  JZ	NOTOGBK
	  CALL	ILPRT
	  DB	'TBR - Toggle backspace to rubout conversion',CR,LF,0
;
NOTOGBK:  LDA	TOGGLELOC
	  ORA	A
	  JZ	NOTOGLOC
	  CALL	ILPRT
	  DB	'TLC - Toggle  1) local command immediate',CR,LF
	  DB	'              2) local command after ',0
	  LDA	EXTCHR
	  CALL	SHFTYPE
	  DB	CR,LF,0
;
NOTOGLOC: LDA	TOGGLELF
	  ORA	A
	  JZ	NOTOGLF
	  CALL	ILPRT
	  DB	'TLF - Toggle send linefeed after carriage return '
 	  DB	'in "T" mode',CR,LF,0
;
NOTOGLF:  LDA	TOGXOFF
	  ORA	A
	  JZ	NOTOGXOF
	  CALL	ILPRT
	  DB	'TXO - Toggle XOFF testing in terminal mode '
	  DB	'file output',CR,LF,0
;
NOTOGXOF: LDA	PMMIBYTE
	  ORA	A
	  JNZ	NONUM
	  CALL	ILPRT
	  DB	'NUM - List remote systems',CR,LF,0
	  LDA	SETUPTST
	  ORA	A
	  JZ	NOPMMI
	  CALL	ILPRT
	  DB	'SET - Set communication ports',CR,LF,0
;
NONUM:	  CALL	ILPRT
	  DB	'PAR - Toggle 8 bits no par/7 bits even par',CR,LF
	  DB	'BYE - Disconnect, then reboot to CP/M',CR,LF
	  DB	'CAL - Dial number',CR,LF
	  DB	'DSC - Disconnect from the phone line',CR,LF,0
;
NOPMMI:	  CALL	ILPRT
	  DB	CR,LF,'          The following are terminal text '
	  DB	'buffer commands:',CR,LF,0
;
SKIPLF:	  CALL	ILPRT
	
	  DB	'DEL - Delete memory buffer and file',CR,LF
	  DB	'NOL - Return to terminal mode - no loss of data '
	  DB	'in buffer',CR,LF
	  DB	'WRT - Write memory buffer to disk file',CR,LF,LF,0
	  CALL	NXTSCRN
;
	  CALL	ILPRT
	  DB	'      Local Commands while in Terminal Mode'
	  DB	CR,LF,LF,0
	  LDA	EXITCHR
	  CALL	SHFTYPE
	  DB	'  - Exit to command mode',CR,LF,0
;
	  LDA     PMMIBYTE
	  ORA     A
	  JZ      S5A
;
	  LDA	DISCCHR
	  CALL	SHFTYPE
	  DB	'  - Disconnect from the phone line',CR,LF,0
	  LDA	BRKCHR
	  CALL	SHFTYPE
	  DB	'  - Send break',CR,LF,0
	  LDA	CHGBAUD
	  CALL	SHFTYPE
	  DB	'  - Change baud rate',CR,LF,0
;
S5A:	  LDA	TRANLOGON
	  ORA	A
	  JZ	NOTRNLOG
	  LDA	LOGCHR
	  CALL	SHFTYPE
	  DB	'  - Send log-on message',CR,LF,0
;
NOTRNLOG: LDA	LSTTST
	  ORA	A
	  JZ	NOLST2
	  LDA	LSTCHR
	  CALL	SHFTYPE
	  DB	'  - Toggle printer',CR,LF,0
;
NOLST2:   MVI	A,LF
	  CALL	TYPE
	  LDA	SAVECHR
	  CALL	SHFTYPE
	  DB	'  - Start copy into buffer',CR,LF,0
	  LDA	UNSAVECHR
  	  CALL	SHFTYPE
	  DB	'  - Stop copy into buffer',CR,LF,LF
	  DB	'             Start & Stop may be toggled as often as '
 	  DB	'desired.',CR,LF
	  DB	'             A ":" at start of line indicates buffer '
	  DB	'is copying.',CR,LF
	  DB	'             XOFF automatically used to stop input '
	  DB	'when writing',CR,LF
	  DB	'                full buffer to disk, XON sent to '
	  DB	'resume.',CR,LF,LF,0
	  LDA	TRANCHR
	  CALL	SHFTYPE
	  DB	'  - Transfer ASCII file to remote',CR,LF,LF,0
	  LDA	LOCONEXTCHR
	  ORA	A
	  LDA	EXTCHR
	  JNZ	REMDFLT
	  CALL	SHFTYPE
	  DB	'  - Send local control character to remote'
	  DB	CR,LF,LF,0
	  JMP	XPRT
;
REMDFLT:  CALL	SHFTYPE
	  DB	'  - Next character will be used for local control'
	  DB	CR,LF,0
;
XPRT:	  CALL	CRLF		;TURN UP A BLANK LINE TO LOOK NICE
	  LDA	NFILFLG		;HAVE A FILE OPEN FOR TEXT MODE COPY?
	  ORA	A
	  JNZ	XPRT1		;IF NOT, EXIT
	  CALL	GETSPC		;OTHERWISE SHOW REMAINING SPACE 
	  CALL	ILPRT
	  DB	' Bytes of buffer free',CR,LF,0
;
XPRT1:	  MVI	C,CURDSK	;CURRENT DISK FUNCTION
	  CALL	BDOS
	  ADI	'A'		;MAKE ASCII
	  CALL	TYPE
;
	  CALL	GETUSER		;GET CURRENT USER NUMBER
	  ORA	A
	  JZ	XPRT2		;SKIP IF USER 0
	  MVI	H,0
	  MOV	L,A
	  CALL	DECOUT		;SHOW USER CURRENT USER AREA
;
XPRT2:	  MVI	A,'>'
	  CALL	TYPE
	  MVI	A,' '
	  CALL	TYPE
	  CALL	ILPRT
	  DB	'COMMAND (H for Help): ',0
;
GETCMD:	  LXI	D,CMDBUF	;ENTER COMMAND
	  CALL	INBUF
	  LDA	CMDBUF+3
	  CPI	':'		;SEE IF REQUEST FOR NEW DRIVER/USER
	  JZ	SETDRV
	  LXI	D,CMDBUF+2	;POINT TO COMMAND
	  CALL	INLNCOMP
	  DB	'CPM',0
	  JNC	EXIT
	  CALL	CRLF		;(1ST CR,LF AT "INBUFR")
	  CALL	INLNCOMP
	  DB	'LOG',0
	  JNC	LOGNEW
	  CALL	INLNCOMP
	  DB	'DIR',0
	  JNC	DIR
	  CALL	INLNCOMP
	  DB	'ERA',0
	  JNC	ERASEF
	  CALL	INLNCOMP
	  DB	'?',0
	  JNC	CURPAR
	  CALL	INLNCOMP
	  DB	'SPD',0
	  JNC	SETSPD
	  CALL	INLNCOMP
	  DB	'TIM',0
	  JNC	SETTIM
	  CALL	INLNCOMP
	  DB	'TCC',0
	  JNC	TOGCRC
	  CALL	INLNCOMP
	  DB	'TBR',0
	  JNC	TOGBKSP
	  CALL	INLNCOMP
	  DB	'TLC',0
	  JNC	TOGLOC
	  CALL	INLNCOMP
	  DB	'TLF',0
	  JNC	TOGLF
	  CALL	INLNCOMP
	  DB	'TXO',0
	  JNC	TOGTXOFF
	  LDA	PMMIBYTE 
	  ORA	A
	  JNZ	NONUM2
	  CALL	INLNCOMP
	  DB	'NUM',0
	  JNC	NUMPRN
;
NONUM2:	  LDA	SETUPTST
	  ORA	A
	  JZ	NOSETUP
	  CALL	INLNCOMP
	  DB	'SET',0
	  JNC	SETUPENT
;
NOSETUP: CALL	INLNCOMP
	  DB	'NOL',0
	  JC	NXTOPT1		;CARRY SET = NO MATCH
	  LDA	NFILFLG
	  ORA	A
	  JNZ	NOFILOPN	;GO TELL OPERATOR IF NO FILE OPEN
	  LDA	ORIGSAV
	  STA	ORIGFLG
	  CALL	BUFMSG
	  LHLD	HLSAVE		;RETURN TO TERMINAL..
	  JMP	TERM		;..MODE WITH SAVE OPTION..
;.....				;..IF PREVIOUSLY ENABLED.
;
;
NXTOPT1:  CALL	INLNCOMP
	  DB	'WRT',0
	  JNC	WRTFIL
	  CALL	INLNCOMP
	  DB	'DEL',0
	  JNC	NEWFILE
	  CALL	INLNCOMP
	  DB	'BYE',0
	  JNC	BYEBYE
	  LDA	PMMIBYTE
	  ORA	A
	  JZ	S6
;MOD(BGL)***
	  CALL	INLNCOMP
	  DB	'PAR',0
	  JNC	TOGLPAR
	  CALL	INLNCOMP	;'DE' SET FROM 1ST INLNCOMP CALL
	  DB	'DSC',0
	  JNC	DISCON1
	  CALL	INLNCOMP
	  DB	'CAL',0
	  JC	S6
	  MVI	A,' '		;FOOL THE SYSTEM
	  STA	CMDBUF+4	;..CMDBUF SO THAT IT..
	  JMP	DOOPT		;..LOOKS AT OPTION FOR DIAL
;
S6:	  PUSH	H
	  LDA	CMDBUF+2
	  LXI	H,COMPLIST
	  CALL	COMPARE		;COMPARES LIST POINTED TO BY HL..
	  POP	H		;..TO CHAR IN A-REG.
	  JC	NOTVLD		;CARRY SET = NO MATCH
;
DOOPT:	  PUSH	H		;LOAD ORIGINAL FCB WITH TRANSFER..
	  CALL	SETFCB		;..CMDS AND GO TO BEGINNING OF..
	  POP	H		;..PROGRAM. WILL FOLLOW SAME LOGIC..
	  JMP	RESTART		;..AS IF PROGRAM WERE CALLED WITH..
;.....				;..CP/M COMMAND LINE.
;
;
NOTVLD:	  CALL	NTVLDMSG
	  JMP	XPRT
;
;
NTVLDMSG: CALL	ILPRT
	  DB	'++ Invalid command ++',CR,LF,BELL,0
	  RET
;.....
;
;
BYEBYE:	  CALL	ILPRT
	  DB	'<< Goodbye...back to CP/M >>',CR,LF,0
	  XRA	A
	  CALL	OUT$MODCTLP
	  CALL	OUT$MODCTL2
	  LDA	OLDUSER		;GET ORIGINAL USER NUMBER
	  MVI	E,A
	  CALL	SETUSER
	  LHLD	CLDBOOT
	  PCHL			;DO A COLD REBOOT, DONE
;.....
;
;
DIR:	  MVI	C,CURDSK
	  CALL	BDOS
	  STA	DISKSAV
	  CALL	DIRLIST
	  LDA	DISKSAV
 	  MOV	E,A
	  MVI	C,SELDSK
	  CALL	BDOS
	  JMP	XPRT
;.....
;
;
DISCON1:  CALL	JMP$DISCONNT
	  CALL	ILPRT
	  DB	CR,LF,'<< Disconnected >>',CR,LF,BELL,0
	  JMP	EXITMEN
;.....

;
ERASEF:	  LXI	D,CMDBUF	;PUT CMD LINE INTO FCB AT 'HL'
	  LXI	H,FCB
	  CALL	CMDLINE
	  CALL	MOVEFCB		;MOVE FCB+16 TO FCB
	  LDA	FCB+1
	  CPI	' '
	  JZ	NOTVLD		;GO IF NO FILE SPECIFIED
	  LXI	D,FCB
	  MVI	C,SRCHF
	  CALL	BDOS
	  INR	A		;0 IF FILE NOT FOUND
	  JNZ	ERAFILE 	;OK, GO ERASE
	  CALL	ILPRT
	  DB	'++ File not found ++',CR,LF,BELL,0
	  JMP	XPRT
;.....
;
;
ERAFILE:  LXI	D,FCB
	  MVI	C,ERASE
	  CALL	BDOS
	  CALL	ILPRT
	  DB	'File erased',CR,LF,0
	  JMP	XPRT
;.....
;
;
LOGNEW:	  LDA	NFILFLG
	  ORA	A
	  JZ	NORESET
	  LDA	CMDBUF+6	;ANY DISK DRIVE SPECIFIED?
	  CPI	' '
	  JNZ	LOGNEW1		;IF NOT A BLANK, EXIT
	  CALL	GETDISK		;IF NOT, USE CURRENT DRIVE
	  ADI	'A'		;TO COMPENSATE FOR NEXT LINE
;
LOGNEW1:  SUI	'A'
	  CPI	15+1		;FOR DRIVES 0-15
	  JNC	NOTVLD		;IF MORE THAN 15, DISPLAY ERROR MESSAGE
	  STA	DISKSAV		;STORE REQUESTED DRIVE
	  CALL	GETUSER		;PICK UP CURRENT USER NUMBER
	  MOV	B,A		;SAVE IT
	  LDA	CMDBUF+7	;GET NEW USER NUMBER
	  CALL	CHRCHK		;CHECK THE CHAR.
	  CALL	FINDUSER
	  LDA	CMDBUF+8	;GET 2ND DIGIT
	  CALL	CHRCHK		;CHECK THE CHAR.
	  CALL	FINDUSER+2
;
LOGNEW2:  CALL	SAVEUSER	
	  MVI	C,RESET
	  CALL	BDOS
	  LDA	DISKSAV
	  MOV	E,A
	  MVI	C,SELDSK
	  CALL	BDOS
	  LDA	SAVUSR
	  MOV	E,A
	  CALL	SETUSER	
	  JMP	XPRT
;.....
;
;
CHRCHK:	  CPI	' '
	  JZ	CHRCHK1
	  CPI	':'		;IN CASE OF A: OR A1: OR A11:  (ETC.)
	  RNZ
;
CHRCHK1:  POP	PSW		;RESET THE 'CALL' ON THE STACK
	  JMP	LOGNEW2
;.....
;
;
FINDUSER: MVI	B,0		;ZERO THE 'B' REG. FOR 1ST TIME THROUGH
	  CALL	NUMCHK		;IF NEITHER, SEE IF A VALID NUMBER
	  MOV	C,A		;SAVE
	  MOV	A,B		;GET SAVE FIRST DIGIT
	  ADD	A		;X2
	  ADD	A		;X4
	  ADD	A		;X8
	  ADD	B		;X9
	  ADD	B		;X10
	  ADD	C
	  MOV	B,A		;SAVE
	  RET
;.....
;
;
SAVEUSER: MOV	A,B
	  CPI	15+1		;USER NUMBERS ARE 0-15
	  JNC	NOTVLD
	  STA	SAVUSR
	  RET
;.....
;	
;
NUMGET:	  LXI	D,CMDBUF
	  CALL	INBUF
	  LDA	CMDBUF+2	;GET NUMBER
	  CPI	' '
	  RZ
;
NUMCHK:	  SUI	'0'		;REMOVE ASCII BIAS
	  CPI	9+1
	  RC			;OK IF 9 OR LESS
	  POP	H		;REMOVE 1ST CALL FROM THE STACK
	  POP	H		;REMOVE 2ND CALL FROM THE STACK	
	  JMP	NOTVLD
;
GETUSER:  MVI	E,0FFH		;GET CURRENT USER
;
SETUSER:  MVI	C,USER		;SET UP BDOS CALL
	  JMP	BDOS
;.....
;
;
GETDISK:  MVI	C,CURDSK	;GET CURRENT DRIVE
	  JMP	BDOS
;.....
;
;
NORESET:  CALL	ILPRT
	  DB	'++      Terminal mode file open      ++',CR,LF
	  DB	'++ Use WRT or DEL before LOG command ++',CR,LF
	  DB	CR,LF,BELL,0
	  XRA	A
	  JMP	XPRT
;.....
;
;
SETSPD:	  CALL	ILPRT
	  DB	'Delay between chars. (0-9): ',0
;
NOKEYS:	  CALL	STAT
	  JZ	NOKEYS
	  CALL	KEYIN
	  CALL	TYPE
	  CALL	SAVEA
	  SUI	'0'
	  CPI	10
	  JNC	NOTVLD
	  STA	BYTDLY
;
	  CALL	ILPRT
	  DB	'Delay at end of line (0-9): ',0
;
NOKEYS1:  CALL	STAT
	  JZ	NOKEYS1
	  CALL	KEYIN
	  CALL	TYPE
	  CALL	SAVEA
	  SUI	'0'
	  CPI	10
	  JNC	NOTVLD
	  STA	CRDLY
;
SPDMSG:	  CALL	ILPRT
	  DB	CR,LF,'Char. delay (terminal file mode) is:  ',0
	  LDA	BYTDLY
	  MOV	B,A
	  MOV	A,B
	  PUSH	H
	  MOV	L,A
	  MVI	H,0
	  CALL	DECOUT
	  POP	H
	  CALL	ILPRT
	  DB	'0 ms. per character',CR,LF
	  DB	'Line  delay (terminal file mode) is: ',0
	  LDA	CRDLY
	  MOV	B,A
	  PUSH	H
	  MOV	L,A
	  MVI	H,0
	  CALL	DECOUT
	  POP	H
	  CALL	ILPRT
	  DB	'00 ms. per character',CR,LF,0
	  JMP	XPRT
;......
;
;
SAVEA:	  PUSH	PSW
	  CALL	ILPRT
	  DB	CR,LF,0
	  POP	PSW
	  RET
;.....
;
;
SETDRV:	  LDA	CMDBUF+2	;GET THE DISK DRIVE
	  SUI	'A'		;CONVERT TO BINARY VALUE
	  CPI	15+1		;FOR DRIVES 0-15
	  JNC	NOTVLD
	  MOV	E,A
	  MVI	C,SELDSK	;SELECT REQUESTED DRIVE
	  CALL	BDOS
	  LDA	CMDBUF+5	;GET USER NUMBER, IF ANY
	  CPI	' '		;KEEP CURRENT USER AREA?
	  JZ	XPRT
	  SUI	'0'		;CONVERT TO BINARY VALUE
	  CPI	1		;IF A '1', COULD BE UNITS OR TENS
	  JNZ	SETDRV1		;IF NOT, NUMBERS STOP AT 15 SO EXIT
	  LDA	CMDBUF+6	;CHECK FOR A 2ND DIGIT
	  CPI	'0'
	  JC	SETDRV2		;IF LESS, NOT A VALID NUMBER, IGNORE
	  SUI	'0'-10		;LEAVE THE '10' IN AS TWO DIGITS USED
;
SETDRV1:  CPI	15+1		;USER AREAS ARE 0-15
	  JNC	NOTVLD
	  MOV	E,A
	  CALL	SETUSER
	  JMP	XPRT		;BACK TO WORK
;
SETDRV2:  MVI	A,1
	  JMP	SETDRV1
;.....
;
;
SETTIM:   CALL	SORPTST
	  JNZ	NOTVLD
	  CALL	ILPRT
	  DB	'Use 0-8 to give baud rate for ''S'' mode '
	  DB	'time-to-send message,',CR,LF
	  DB	'where 0=110, 1=300, 2=450, 3=600, 4=710, 5=1200, '
	  DB	'6=2400, ',CR,LF,'7=4800 AND 8=9600 Baud.'
	  DB	CR,LF,LF,'Enter value: ',0
	  CALL	NUMGET
	  CPI	8+1		;ONLY LOOKING FOR 1-8 ANSWERS
	  JNC	NOTVLD
	  STA	MSPEED
	  CALL	SETTIM2
	  JMP	XPRT
;.....
;
;
SETTIM2:  CALL	SORPTST
	  JNZ	SETTIM3
	  CALL	ILPRT
	  DB	'Rate for the S mode time-to-send message is set to ',0
	  JMP	SETTIM4
;...
;
;
SETTIM3:  CALL	ILPRT
	  DB	'Modem speed is ',0
;
SETTIM4:  JMP	PRTBAUD
;.....
;
;
SORPTST:  LDA	SETUPTST
	  MOV	B,A
	  LDA	PMMIBYTE
	  ORA	B
	  RET
;.....
;
;
TOGCRC:	  LDA	TOGGLECRC
	  ORA	A
	  JZ	NOTVLD
	  LDA	CKSUMDFLT
	  CMA
	  STA	CKSUMDFLT
	  CALL	TOGCRC1
	  JMP	XPRT
;.....
;
;
TOGCRC1:  ORA	A
	  JNZ	CHEKMSG
	  CALL	ILPRT
	  DB	'CRC mode set',CR,LF,0
	  RET
;.....
;
;
CHEKMSG:  CALL	ILPRT
	  DB	'CHECKSUM mode set',CR,LF,0
	  RET
;.....
;
;
TOGBKSP:  LDA	TOGGLEBK
	  ORA	A
	  JZ	NOTVLD
	  LDA	CONVBKSP
	  CMA
	  STA	CONVBKSP
	  CALL	TOGBKSP2
	  JMP	XPRT
;.....
;
;
TOGBKSP2: LDA	CONVBKSP
	  ORA	A
	  JZ	NORUBMSG
	  CALL	ILPRT
	  DB	'Backspace is rub',CR,LF,0
	  RET
;.....
;
;
NORUBMSG: CALL	ILPRT
	  DB	'Backspace is backspace',CR,LF,0
	  RET
;.....
;
;
TOGLOC:	  LDA	TOGGLELOC
	  ORA	A
	  JZ	NOTVLD
	  LDA	LOCONEXTCHR
	  CMA
	  STA	LOCONEXTCHR
	  CALL	TOGLOC2
	  JMP	XPRT
;.....
;
;
TOGLOC2:  CALL	ILPRT
	  DB	'Use ',0
	  LDA	LOCONEXTCHR
	  ORA	A
	  LDA	EXTCHR
	  JZ	LOCMSG
	  CALL	SHFTYPE
	  DB	' before local command',CR,LF,0
	  RET
;.....
;
;
LOCMSG:   CALL	SHFTYPE
	  DB	' to send local command to remote',CR,LF,0
	  RET
;.....
;
;
TOGLF:	  LDA	TOGGLELF
	  ORA	A
	  JZ	NOTVLD
	  LDA	ADDLF
	  CMA
	  STA	ADDLF
	  CALL	TOGLF2
	  JMP	XPRT
;.....
;
;
TOGLF2:	  CALL	ILPRT
	  DB	'Linefeed ',0
	  LDA	ADDLF
	  ORA	A
	  JNZ	LFMSG
	  CALL	ILPRT
	  DB	'NOT ',0
;
LFMSG:	  CALL	ILPRT
	  DB	'sent after <CR>',CR,LF,0
	  RET
;.....
;
;
TOGTXOFF: LDA	TOGXOFF
	  ORA	A
	  JZ	NOTVLD
	  CALL	ILPRT
	  DB	'Use XOFF testing? (Y/N): ',0
	  CALL	GETANS
	  JC	NOCHG3
	  STA	XOFFTST
;
NOCHG3:	  CALL	XOFFMSG
	  CALL	ILPRT
	  DB	CR,LF,'Use XON waiting after <CR> (Y/N): ',0
	  CALL	GETANS
	  JC	NOCHG4
	  STA	XONWAIT
;
NOCHG4:	  CALL	XONMSG
	  LDA	XONWAIT
	  ORA	A
	  JZ	XPRT
	  CMA
	  STA	XOFFTST		;DON'T ALLOW BOTH
	  CALL	ILPRT
	  DB	'Therefore ',0
	  CALL	XOFFMSG
	  JMP	XPRT
;.....
;
;
GETANS:   LXI	D,CMDBUF
	  CALL	INBUF
	  LDA	CMDBUF+2 	;GET ANSWER
	  CPI	' '
	  CMC
	  RZ
	  MOV	B,A
	  CPI	'N'
	  MVI	A,FALSE
	  RZ
	  MOV	A,B
	  CPI	'Y'
	  MVI	A,TRUE
	  RZ
	  POP	PSW		;PRESERVE STACK
	  JMP	NOTVLD
;.....
;
;
XOFFMSG:  CALL	ILPRT
	  DB	'XOFF testing ',0
	  LDA	XOFFTST
	  ORA	A
	  JNZ	XOTSTON
	  CALL	ILPRT
	  DB	'NOT ',0
;
XOTSTON:  CALL	ILPRT
	  DB	'used',0
;
XONMSG3:  CALL	ILPRT
	  DB	' in terminal mode file output',CR,LF,0
	  RET
;.....
;
;
XONMSG:	  CALL	ILPRT
	  DB	'XON ',0
	  LDA	XONWAIT
	  ORA	A
	  JNZ	XONMSG2
	  CALL	ILPRT
	  DB	'NOT ',0
;
XONMSG2:  CALL	ILPRT
	  DB	'automatically tested after <CR>',0
	  JMP	XONMSG3
;...
;
;
SETUPENT: LDA	SETUPTST
	  ORA	A
	  JZ	NOTVLD
	  LXI	D,CMDBUF+1
	  CALL	JMP$SETUPR
	  JMP	XPRT
;.....
;
;
NEWFILE:  LDA	NFILFLG
	  ORA	A
	  JNZ	NOFILOPN	
	  LDA	FCB3+1		;CHECK THAT FILE WAS REQUESTED
	  CPI	' '
	  JZ	NOFILOPN	;IF NO FILE, DON'T ERASE
	  LXI	D,FCB3
	  MVI	C,ERASE
	  CALL	BDOSRT
	  MVI	A,TRUE		;DO NOT ALLOW TERMINAL..
	  STA	NFILFLG		;..SAVE SINCE NO FILE..
	  CMA			;..SPECIFIED.
	  STA	SAVEFLG
	  LXI	H,FCB3
	  CALL	INITFCB
	  LXI	H,BOTTRAM
	  SHLD	HLSAVE
	  JMP	XPRT
;.....
;
;
WRTFIL:
	  LDA	NFILFLG
	  CPI	TRUE
	  JZ	NOFILOPN
	  LDA	FCB3+1		;CHECK THAT FILE WAS REQUESTED
	  CPI	' '
	  JZ	NOFILOPN
	  LHLD	HLSAVE		;START OF MEMORY BUFFER
	  CALL	NUMRECS		;DISK WRITE ROUTINE AS USED IN
	  CALL	WRTDSK		;   THE 'INTDSKSV' ROUTINE
	  CALL	CLOSE3
	  MVI	A,TRUE
	  STA	NFILFLG		;SHOW NO FILE OPEN NOW
	  CMA
	  STA	SAVEFLG
	  LXI	H,FCB3
	  CALL	INITFCB		;BLANK OUT FCB TO WRITTEN FILE
	  LXI	H,BOTTRAM	;   CAN'T BE ERASED
	  SHLD	HLSAVE		;RESET TO BUFFER START FOR NEXT TIME
	  JMP	XPRT
;.....
;
;
NOFILOPN: CALL	ILPRT
	  DB	'++ No File Open ++',CR,LF,BELL,0
	  JMP	XPRT
;.....
;
;
;THIS ROUTINE DISPLAYS THE PHONE NUMBERS IN THE LIBRARY
;
NUMPRN:	  PUSH	H
	  CALL	CLRTST
	  CALL	ILPRT
	  DB	'           Library of Phone Numbers of Remote Systems'
	  DB	0
	  MVI	C,13		;NUMBER OF LINES TO MOVE
	  LXI	H,NUMBLIB	;ADDRESS OF SOURCE MEMORY
	  LXI	D,DBUF		;ADDRESS OF TARGET MEMORY
	  CALL	NEWLINE		;START WITH CRLF
	  STAX	D		;+LF
	  INX	D		;AND BUMP IT
;
NUMPRN1:  INX	H		;SKIP PMMI DIALING LETTER
	  INX	H		;AND EQUAL SIGN
	  MVI	B,LIBLEN-2	;NUMBER OF BYTES TO MOVE
	  CALL	MOVE		;MOVE TO BUFFER
	  CALL	SPACES		;2 ENTRIES + 3 SPACES = 63 CHARACTERS
	  INX	H
	  INX	H
	  MVI	B,LIBLEN-2
	  CALL	MOVE
	  CALL	NEWLINE
	  DCR	C		;NUMBER OF LINES TO PRINT
	  JZ	NUMPRN2
	  JMP	NUMPRN1
;.....
;
;
NEWLINE:  MVI	A,CR		;PUTS CR-LF AT MEMORY POINTED BY 'DE'
	  STAX	D		;STORE IT
	  MVI	A,LF		;LF
	  INX	D		;BUMP POINTER
	  STAX	D		;STORE LF
	  INX	D		;BUMP POINTER
	  RET
;.....
;
;
SPACES:	  MVI	A,' '		;SPACE
	  STAX	D
	  INX	D		;1
	  STAX	D
	  INX	D		;2
	  STAX	D
	  INX	D		;3
	  RET
;.....
;
;
NUMPRN2:  MVI	A,'$'
	  STAX	D
	  MVI	C,PRINT
	  LXI	D,DBUF		;POINT TO TABLE OF NUMBERS TO PRINT
	  CALL	BDOS
	  CALL	CRLF
	  CALL	CRLF
	  POP	H
	  JMP	XPRT
;......
;
;
COMPARE:  MOV	B,M		;COMPARES A-REG WITH LIST..
;
COMPLP:	  INX	H		;..ADDRESSED BY HL. FIRST ELEMENT..
	  CMP	M		;..OF LIST MUST BE NUMBER OF ELEMENTS..
	  JZ	VALID		;..BEING COMPARED. RETURNS WITH..
	  DCR	B		;..CARRY SET IF A-REG DOES NOT..
	  JNZ	COMPLP		;.. CONTAIN AN ELEMENT IN LIST.
	  STC
;
VALID:	  RET
;.....
;
;
NXTSCRN:  CALL  ILPRT
	  DB	'HIT any KEY to CONTINUE',0
;
NOKEY1:	  CALL	STAT		;GET KEYBOARD STATUS
	  JZ	NOKEY1		;KEEP LOOPING UNTIL KEYPRESS
	  CALL	KEYIN		;GOBBLE UP KEYPRESS
	  CPI	'C'-40H		;CONTROL-C TO ABORT?
	  JNZ	CLRTST
	  POP	H		;CLEAR STACK OF RETURN ADDRESS
	  CALL	CRLF		;TURN UP A BLANK LINE
	  JMP	XPRT
;.....
;
;
CLRTST:	  LDA	SCRNTEST
	  ORA	A
	  JNZ	CLRSCRN
;.....
;
;
LOTSALF:  MVI	A,CR
	  CALL	TYPE
	  MVI	B,12
	  MVI	A,LF
;
LFLOOP:	  CALL	TYPE
	  DCR	B
	  JNZ	LFLOOP
	  RET
;.....
;
;
CURPAR:	  CALL	CLRTST
	  CALL	ILPRT
	  DB	'                Current Settings',CR,LF,LF,0
	  LDA	CKSUMDFLT	;SEE IF SET FOR 'CRC' OR 'CHECKSUM'
	  CALL	TOGCRC1
	  LDA	LSTTST
	  ORA	A
	  JZ	NOLST3
	  CALL	LSTMSG
;
NOLST3:	  CALL	SETTIM2
	  CALL	TOGBKSP2
	  CALL	TOGLF2
	  CALL	TOGLOC2
	  CALL	ILPRT
	  DB	'Terminal mode file buffer is ',0
	  LDA	NFILFLG
	  ORA	A
	  JZ	ACTIVE
	  CALL	ILPRT
	  DB	'in',0
;
ACTIVE:	  CALL	ILPRT
	  DB	'active',CR,LF,'Unused portion of buffer is ',0
	  CALL	GETSPC
	  CALL	ILPRT
	  DB	' bytes',CR,LF,0
	  CALL	XOFFMSG
	  CALL	XONMSG
	  CALL	SPDMSG
	  CALL	CRLF
	  CALL	CRLF
	  CALL	CRLF
	  JMP	XPRT
;.....
;
;
GETSPC:	  CALL	GETMAX
	  MOV	B,A
	  LHLD	HLSAVE
	  STC
	  CMC
	  MVI	A,0
	  SBB	L
	  MOV	L,A
	  MOV	A,B
	  SBB	H
	  MOV	H,A
	  CALL	DECOUT
	  RET
;.....
;
;
COMPLIST: DB	 6, 'S', 'R', 'T', 'E', 'H', 'L'
;.....
;
;
;***********************************************************************
;
;       D - A - T - A    A - R - E - A
;
;***********************************************************************
;
;
; OPTION TABLE
;
OPTBL:	  EQU	$
ANSWFLG:  DB	'A'
BATCHFLG: DB	'B'	;SET TO 'B' BY MENU. DOES NOT ALLOW MULTI-FILE
DISCFLG:  DB	'D'
LOCCHFLG: DB	'L'
ORIGFLG:  DB	'O'
QFLG:	  DB	'Q'
RSEEFLG:  DB	'R'
SSEEFLG:  DB	'S'
TERMFLG:  DB	'T'
VSEEFLG:  DB	'V'
XITFLG:	  DB	'X'		
EPARITY:  DB	'0'	;EVEN PARITY SUB-OPTION (ONLY IN S OR R MODE)
OPARITY:  DB	'1'	;ODD PARITY SUB-OPTION  (ONLY IN S OR R MODE)
OPTBE:	  EQU	$	;..TRANSFER WHEN PROGRAM INITIALLY CALLED.
;
;
; The following must be in the same order as the table above:
;
RESTROPT: DB	'A','B','D','L','O','Q','R','S','T','V','X','0','1'
;
;
; THE NEXT 13 BYTES EQUAL THE NUMBER OF BYTES BETWEEN RECDNOB AND
; RECDNOE
;
RESTSN:   DB	0,0,0,0,0,0
	  DW	DBUF
	  DB	0,0,0,0,0
;
RECDNOB   EQU	$	;START OF TABLE MARKER
RCVRNO:   DB	0	;\
RECDNO:   DB	0,0	; \
ERRCT:    DB	0	;  \
ERRCDE:   DB	0	;   \
EOFLG:    DB	0	;    \	13 BYTES BETWEEN TABLE MARKERS
RECPTR:   DW	DBUF	;    /
RECINBF:  DB	0	;   /
MAXEXT:   DB	0	;  /
RCNT:     DB	0,0 	; /
DATAFLG:  DB	0	;/
RECDNOE   EQU	$	;END OF TABLE MARKER
;
CRCVAL:	  DW	0
DIALCT:	  DW	0
HLSAVE:	  DW	BOTTRAM
HLSAVE1:  DW	BOTTRAM
HLSAVE2:  DW	BOTTRAM	
;
ABORTFLG: DB	0
CRCFLAG:  DB	TRUE
CRFLAG:	  DB	0	;CONTINUOUS REDIAL FLAG	
DLYFLG:	  DB	0
ECHOFLG:  DB	FALSE
EXACFLG:  DB	0
EXITFLG:  DB	TRUE
FIRSTME:  DB	TRUE	;FIRST SOH RECEIVED SET FLAG TO ZERO
FSTFLG:	  DB	TRUE
LASTBYT1: DB	0
LASTBYT2: DB	0
LISTFLG:  DB	FALSE
LISTMOR:  DB	FALSE	
LOCFLG:	  DB	FALSE
MFFLG1:	  DB	0	;1ST TIME SWITCH
MODCTLB:  DB	07FH
NFILFLG:  DB	FALSE	;ALLOWS WRITE TO MEMORY IN TERMINAL MODE
NSEEFLG:  DB	TRUE	;FALSE TO SEE FILE NAME IN QUIET MODE
ONERR:    DB	0
OPTION:	  DB	0
RINGBKFL: DB	0
SAVEFLG:  DB	FALSE
UARTCTLB: DB	ORIGMOD	;FOR ORIGINATE MODE
UARTFLG:  DB	FALSE	;FOR ORIGINATE MODE
CMDBUF:	  DB	80H,0	;COMMAND BUFFER, TWO PAGES PLUS ONE BYTE
;
	  DS	80H
BGNMS:	  DS	2
DISKNO:	  DS	1
DISKSAV:  DS	1
FILECT:	  DS	1
FTYCNT:	  DS	1
NAMECT:	  DS	1
NBSAVE:	  DS	2
OLDUSER:  DS	1
ORIGSAV:  DS	1
SENDFLG:  DS	1
SAVUSR:	  DS	1
          DS	100	;STACK DEPTH
STACK:	  DS	0
;
FCB3:	  DS	33
FCB4:	  DS	33
FCBBUF:	  DS	15
MFNAME5:  DS	12	;REQUESTED NAME
MFNAME6:  DS	12	;CURRENT NAME
DBUF	  EQU	$	
NAMEBUF	  EQU	DBUF+(DBUFSIZ*1024)	;BUFFER FOR NAMES IN BATCH MODE.
;.....
;
;
; BDOS EQUATES
;
RDCON:	  EQU	1
WRCON:	  EQU	2
LSTOUT:	  EQU	5
PRINT:	  EQU	9
RDBUF:	  EQU	10
CONST:	  EQU	11
CPMVER:	  EQU	12
RESET:	  EQU	13
SELDSK:	  EQU	14
OPEN:	  EQU	15
CLOSE:	  EQU	16
SRCHF:	  EQU	17
SRCHN:	  EQU	18
ERASE:	  EQU	19
READ:	  EQU	20
WRITE:	  EQU	21
MAKE:	  EQU	22
REN:	  EQU	23
CURDSK:	  EQU	25
SETDMA:	  EQU	26
DSKALL:	  EQU	27
DSKPAR:	  EQU	31
USER:	  EQU	32
FILSIZ:	  EQU	35
BDOS:	  EQU	0005H
REIPL:	  EQU	0
FCB:	  EQU	5CH
FCBEXT:	  EQU	FCB+12
FCBSNO:	  EQU	FCB+32
FCBRNO:	  EQU	FCB+32
FCB2:	  EQU	6CH
;
LAST	  END	100H
                                                                                                                          