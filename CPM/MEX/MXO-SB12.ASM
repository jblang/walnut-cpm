; MXO-SB12.ASM - Intertec Superbrain overlay file for MEX10.  09/25/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
;NOTE:
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baud rate, word length, parity,
; or stop bits for the main port. 
;
; Added a LISTST routine so the print buffer stuff would work.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 09/25/84 - Implemented NEWBD: vector		- D.D. Ferguson
; 07/07/84 - Revised Intertec Superbrain        - G.T. Hasul
; 05/23/84 - Converted to Intertec Superbrain   - F.E. Clayton
; 05/15/84 - Converted from MDM7xx to MEX10     - Sandy Berger
; 03/25/84 - Revised for use with MDM730        - Sandy Berger
; 11/11/83 - Renamed to M7MD-1.ASM, no changes  - Irv Hoff
; 07/21/83 - Renamed for use with MDM712        - Irv Hoff
; 07/01/83 - Revised for use with MDM711        - Irv Hoff
; 06/22/83 - Revised for use with MDM710        - Irv Hoff
; 06/22/83 - Altered MDM708DP for Morrow
;            Micro Decision computers using
;            an external modem                  - Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:           EQU     07H             ;bell
TAB:		EQU	09H		;tab
CR:             EQU     0DH             ;carriage return
ESC:            EQU     1BH             ;escape
LF:             EQU     0AH             ;linefeed
;
YES:            EQU     0FFH
NO:             EQU     0
;
PORT:           EQU     058H            ;Superbrain Main port
MODCTL1:        EQU     PORT+1          ;Modem status port
MODDATP:        EQU     PORT            ;Modem data port
MODCTL2:        EQU     PORT+1          ;Modem control port
MODRCVB:        EQU     02H             ;Modem receive bit
MODRCVR:        EQU     02H             ;Modem receive ready
MODSNDB:        EQU     01H             ;Modem send bit
MODSNDR:        EQU     01H             ;Modem send ready bit
;
; MEX service processor stuff
;
INMDM   EQU     255             ;get char from port to A, CY=no more in 100 ms
TIMER   EQU     254             ;delay 100ms * reg B
TMDINP  EQU     253             ;B=# secs to wait for char, cy=no char
CHEKCC  EQU     252             ;check for ^C from KBD, Z=presentŠSNDRDY  EQU     251             ;test for modem-send ready
RCVRDY  EQU     250             ;test for modem-receive ready
SNDCHR  EQU     249             ;send a character to the modem (after sndrdy)
RCVCHR  EQU     248             ;recv a char from modem (after rcvrdy)
LOOKUP  EQU     247             ;table search: see CMDTBL comments for info
PARSFN  EQU     246             ;parse filename from input stream
BDPARS  EQU     245             ;parse baud-rate from input stream
SBLANK  EQU     244             ;scan input stream to next non-blank
EVALA   EQU     243             ;evaluate numeric from input stream
LKAHED  EQU     242             ;get nxt char w/o removing from input
GNC     EQU     241             ;get char from input, cy=1 if none
ILP     EQU     240             ;inline print
DECOUT  EQU     239             ;decimal output
PRBAUD  EQU     238             ;print baud rate
;
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
                ORG     100H
;
                DS      3       ;(for  "JMP   START" instruction)
;
PMMIMODEM:      DB      NO      ;yes=PMMI S-100 Modem                   103H
SMARTMODEM:     DB      NO	;yes=HAYES Smartmodem, no=non-PMMI      104H
TOUCHPULSE:     DB      'T'     ;T=Touch, P=Pulse (Smartmodem-only)     105H
CLOCK:          DB      40      ;clock speed in MHz x10, 25.5 MHz max.  106H
                                ;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:         DB      1       ;0=110 1=300 2=450 3=600 4=710 5=1200   107H
                                ;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:         DB      5       ;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
                                ;default time to send character in ter-
                                ;minal mode file transfer for slow BBS.
CRDLY:          DB      5       ;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
                                ;default time for extra wait after CRLF
                                ;in terminal mode file transfer
NOOFCOL:        DB      5       ;number of DIR columns shown            10AH
SETUPTST:       DB      YES     ;yes=user-added Setup routine           10BH
SCRNTEST:       DB      YES	;Cursor control routine                 10CH
RETRY:          DB      YES     ;yes=ask user to reset error count      10DH
                                ;after 10 consecutive errors
                                ;no=abort after 10 consecutive errors
BAKUPBYTE:      DB      NO      ;yes=change any file same name to .BAK  10EH
CRCDFLT:        DB      YES     ;yes=default to CRC checking            10FH
TOGGLECRC:      DB      YES     ;yes=allow toggling of CRC to Checksum  110H
CONVRUB:        DB      NO      ;yes=convert rub to backspace           111H
TOGGLERUB:      DB      YES     ;yes=allow toggling of rub to bksp      112H
ADDLF:          DB      NO      ;no=no LF after CR to send file in      113H
                                ;terminal mode (added by remote echo)
TOGGLELF:       DB      YES     ;yes=allow toggling of LF after CR      114H
TRANLOGON:      DB      YES     ;yes=allow transmission of logon        115H
                                ;write logon sequence at location LOGON
SAVCCP:         DB      YES     ;yes=do not overwrite CCP               116H
LOCONEXTCHR:    DB      YES     ;yes=local command if EXTCHR precedes   117HŠ                                ;no=external command if EXTCHR precedes
TOGGLELOC:      DB      YES     ;yes=allow toggling of LOCONEXTCHR      118H
LSTTST:         DB      YES     ;no=using modem on printer port         119H
XOFFTST:        DB      YES     ;yes=checks for XOFF from remote while  11AH
                                ;sending a file in terminal mode
XONWAIT:        DB      NO      ;yes=wait for XON after CR while        11BH
                                ;sending a file in terminal mode
TOGXOFF:        DB      YES     ;yes=allow toggling of XOFF checking    11CH
IGNORCTL:       DB      NO      ;yes=CTL-chars above ^M not displayed   11DH
EXTRA1:         DB      0       ;for future expansion                   11EH
EXITCHR:        DB      'E'-40H ;^E = Exit to Main Menu                 11FH
BRKCHR:         DB      '@'-40H ;^@ = Send 50 ms. break tone            120H
NOCONNCT:       DB      'N'-40H ;^N = Disconnect from phone line        121H
LOGCHR:         DB      'L'-40H ;^L = Send logon                        122H
LSTCHR:         DB      'P'-40H ;^P = Toggle printer                    123H
UNSAVE:         DB      'R'-40H ;^R = Close input text buffer           124H
TRANCHR:        DB      'T'-40H ;^T = Transmit file to remote           125H
SAVECHR:        DB      'Y'-40H ;^Y = Open input text buffer            126H
EXTCHR:         DB      '^'-40H ;^^ = Send next character               127H
;
;
                DS      2               ;                               128H
;
IN$MODCTL1:     IN      MODCTL1 	;in modem control port          12AH
;		BIT	7,A		;check for DSR
		DB	0CBH,7FH
;
		RNZ			;return if found
		ORI	MODSNDR		;force send ready if DSR missing
		RET			;(prevents keyboard lock-up)
                DS      2
OUT$MODDATP:    OUT     MODDATP ! RET   ;out modem data port            134H
                DS      7
IN$MODDATP:     IN      MODDATP ! RET   ;in modem data port             13EH
                DS      7
ANI$MODRCVB:    ANI     MODRCVB ! RET   ;bit to test for receive ready
CPI$MODRCVR:    CPI     MODRCVR ! RET   ;value of receive bit when ready
ANI$MODSNDB:    ANI     MODSNDB ! RET   ;bit to test for send ready
CPI$MODSNDR:    CPI     MODSNDR ! RET   ;value of send bit when ready
                DS      12
;
LOGONPTR:       DW      LOGON           ;for user message. *obsolete*   160H
                DS      3               ;jump to dialing routine        162H
JMP$DISCONNT:   JMP     GOODBYE         ;disconnect the modem           165H
JMP$GOODBYE:    RET ! NOP ! NOP         ;called b-4 exit to cpm         168H
JMP$INITMOD:    JMP     INITMOD         ;initialization at cold start   16BH
JMP$NEWBAUD:    JMP	NEWBD		;sets baud associated w/phone # 16EH
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       171H
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       174H
JMP$SETUPR:     JMP     SETUPR          ;SET command (user routine)     177H
JMP$SPCLMENU:   DS      3		;*obsolete with mex*            17AH
JMP$SYSVER:     JMP     SYSVER          ;Overlay's voice in sign-on     17DH
JMP$BREAK:      JMP     SENDBRK         ;send a break                   180H
;
;Š; Do not change the following six lines.
;
JMP$ILPRT:      DS      3               ;                               183H
JMP$INBUF       DS      3               ;                               186H
JMP$INLNCOMP:   DS      3               ;                               189H
JMP$INMODEM     DS      3               ;                               18CH
JMP$NXTSCRN:    DS      3               ;                               18FH
JMP$TIMER:      DS      3               ;                               192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
; The SCRNTST option must be set "YES" for these to work.  
; Each routine must be exactly nine bytes long.
CLREOS:         CALL    ILPRT		;				194H
	        DB	ESC,'~k',0,0
                RET
;
CLRSCRN:        MVI     C,ILP		;				19DH
                CALL    MEX
                DB      0CH,0,0
                RET			;				1A5H
;
;-----------------------------------------------------------------
;
;           *** END OF FIXED FORMAT AREA ***
;
;-----------------------------------------------------------------
;
SYSVER:		CALL    ILPRT
                DB      'Version for Intertec Superbrain'
                DB      CR,LF,0
                RET
;
; CONOUT FRONT-END ROUTINE TO ELIMINATE RUBS
;
CONRTN:		MOV	A,C
		CPI	7FH		;SCREEN OUT RUBS
		RZ
CONEXIT:	JMP	OUTVEC		;OVERLAID WITH OUTVEC DATA
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;        end of your last routine should terminate by 0B00H if using the
;       Hayes Smartmodem or by address 0D00H otherwise.
;
;-----------------------------------------------------------------------
;
;
LOGON:    DB    0		;*obsolete*
;.....
;
;Š;=======================================================================
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computer.
;
SENDBRK:  MVI   A,1FH           ;SEND BREAK TONE
          JMP   GOODBYE1
;...
;
;
; This routine sends a 300 ms. break tone or sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI   A,15H           ;SEND BREAK, TURN OFF DTR
;
GOODBYE1: OUT   MODCTL1         ;SEND TO STATUS PORT
          MVI   B,3             ;WAIT 300 MS.
          MVI   C,TIMER
          CALL  MEX
          MVI   A,37H           ;NORMAL SEND/RECEIVE WITH DTR
          OUT   MODCTL1         ;SEND TO STATUS PORT
          RET
;.....
;
;Intertec initialization ....courtesy Ben Wert and m7sbc.asm
;
;BIOS CONTROL LOCATIONS
; /-----------------------VERIFY THESE LOCATIONS IN YOUR BIOS
; |                      |   |
; |                      |   |
; V                      V   V
BAUD		EQU	0EF00H		;BIOS MAIN + AUX BAUD RATE
MNMODE		EQU	0EF01H		;BIOS MAIN PORT MODE
;
;
;
;8251A CONTROL COMMANDS
RESET		EQU	37H
MODESET		EQU	40H
DTRSET		EQU	02H
;
BAUDTBL:	DB	0		;   50 BAUD	00H
		DB	0		;   75 BAUD	01H
		DB	0		;  110 BAUD	02H
		DB	0		;  134 BAUD	03H
		DB	0		;  150 BAUD	04H
		DB	1		;  300 BAUD	05H
		DB	3		;  600 BAUD	06H
		DB	5		; 1200 BAUD	07H
		DB	5		; 1800 BAUD	08H
		DB	5		; 2000 BAUD	09H
		DB	6		; 2400 BAUD	0AH
		DB	6		; 3600 BAUD	0BH
		DB	7		; 4800 BAUD	0CH
		DB	7		; 7200 BAUD	0DHŠ		DB	8		; 9600 BAUD	0EH
;
INITMOD:	LDA	BAUD		;ESTABLISH EXISTING BAUD RATE
		ANI	0F0H		;AND OUT AUX BAUD RATE
		RRC			;
		RRC			;GET TABLE INDEX
		RRC			;
		RRC			;
		LXI	H,BAUDTBL
		MOV	E,A
		MVI	D,0
		DAD	D
		MOV	A,M
		STA	MSPEED		;SET MEX BAUD CODE
;
; SET BAUD RATE AND PORT MODE
;
INITMOD1:	MVI	A,MODESET+DTRSET ;PREPARE FOR MODE CHANGE
		OUT	MODCTL1
		NOP ! NOP
		LDA	MNMODE		;USE MODE FROM BIOS
		OUT	MODCTL1
		NOP ! NOP
		MVI	A,RESET		;ENABLE USART
		OUT	MODCTL1	
		LDA	BAUD		;SET BAUD FROM BIOS
		OUT	60H		;BAUD RATE GENERATOR PORT
		NOP ! NOP
		IN	MODDATP		;CLEAN OUT I/P BUFFER
		RET
;
;.....
;
;
SETUPR:   MVI   C,SBLANK        ;ANY ARGUMENTS?
          CALL  MEX
          JC    SETSHO          ;IF NOT, GO DISPLAY BAUD
          LXI   D,CMDTBL
          MVI   C,LOOKUP
          CALL  MEX             ;PARSE ARGUMENT
          PUSH  H               ;SAVE ANY PARSED ARGUMENT ADRS ON STACK
          RNC                   ;IF WE HAVE ONE, RETURN TO IT
          POP   H               ;OOPS, INPUT NOT FOUND IN TABLE
SETERR:	  CALL  ILPRT           ;TELL USER INPUT NOT VALID
          DB    CR,LF,'++ Invalid Set Command - Use SET ? for help ++'
	  DB	CR,LF,0
          RET
;
CMDTBL:	  DB	'BAU','D'+80H
	  DW	SETBAUD
	  DB	'PRT','Y'+80H
	  DW	SETPRTY
	  DB	'WOR','D'+80H
	  DW	SETWORD
	  DB	'STO','P'+80HŠ	  DW	SETSTOP
	  DB	'?'+80H
	  DW	SETHELP
	  DB	0
;
SETSHO:	  CALL	PRTBAUD
	  CALL	PRTWORD
	  CALL	PRTPRTY
	  CALL	PRTSTOP
	  RET
;
SETBAUD:  MVI   C,BDPARS        ;ANY ARGUMENTS?
          CALL  MEX
          JC    SETERR          ;IF NOT, GO DISPLAY BAUD
          MOV	E,A		;CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTBL1	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH CODE
	  ORA	A		;DO WE SUPPORT THIS RATE
	  JZ	SETERR		;NO - EXIT
	  MOV	B,A
	  LDA	BAUD		;GET EXISTING BAUD
	  ANI   0FH
	  ORA	B		;OR IN NEW RATE
	  STA	BAUD
	  MOV	A,E		;SET MEX BAUD RATE
	  STA	MSPEED
	  CALL  INITMOD1	;SET BAUD AND MODE
PRTBAUD:  CALL	ILPRT
	  DB	'Baud Rate:',tab,0
	  LDA   MSPEED
	  MVI	C,PRBAUD
	  CALL  MEX
	  CALL	CRLF
	  RET	
BAUDTBL1: DB	20H,50H,0,60H,0		;110,300,450,600,710
	  DB	70H,0A0H,0C0H,0E0H,0	;1200,2400,4800,9600,19200
;
;
; NOTE: The NEWBD: vector as implemented here is just a repetition of
;       code found four lines under SETBAUD. It is repeated here to
;	allow removal of an extra CRLF when reporting the change in
;	baud rate.  The code can be removed and the label placed above
;	without loss of function.   DDF 09/25/84
;
NEWBD:	  MOV	E,A		;CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTBL1	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH CODE
	  ORA	A		;DO WE SUPPORT THIS RATE
	  JZ	SETERR		;NO - EXIT
	  MOV	B,A
	  LDA	BAUD		;GET EXISTING BAUD
	  ANI   0FH
	  ORA	B		;OR IN NEW RATE
	  STA	BAUD
	  MOV	A,E		;SET MEX BAUD RATE
	  STA	MSPEED
	  CALL  INITMOD1	;SET BAUD AND MODEŠ          LDA   MSPEED
	  MVI	C,PRBAUD
	  CALL  MEX
          CALL  ILPRT
          DB    tab,0
          RET	
;
;
SETPRTY:  LXI	D,PRTYTBL
	  CALL  TSRCH
	  JC	SETERR
	  LDA	MNMODE
	  ANI   0CFH
	  ORA   L
	  STA	MNMODE
	  CALL  INITMOD1
PRTPRTY:  CALL  ILPRT
	  DB	'Parity:',TAB,TAB,0
	  LDA	MNMODE
	  ANI   30H
	  RRC
	  RRC
	  RRC
	  RRC
	  ADD	A
	  MOV	E,A
	  MVI	D,0
	  LXI	H,PRTYTBL1
	  DAD	D
	  MOV	E,M
	  INX	H
	  MOV	D,M
	  MVI	C,PRINT
	  CALL	MEX
	  CALL	CRLF
 	  RET
PRTYTBL:  DB	'EVE','N'+80H
	  DW	30H
	  DB	'E'+80H
	  DW	30H
	  DB	'OD','D'+80H
	  DW	10H
	  DB	'O'+80H
	  DW	10H
	  DB	'NON','E'+80H
	  DW	0
	  DB	'N'+80H
	  DW	0
	  DB	0
PRTYTBL1: DW	PRTYN
	  DW	PRTYO
	  DW	PRTYN
	  DW	PRTYE
PRTYN:	  DB	'None','$'
PRTYO:	  DB	'Odd','$'ŠPRTYE:	  DB	'Even','$'
;
;
SETWORD:  LXI	D,WORDTBL
	  CALL  TSRCH
	  JC	SETERR
	  LDA	MNMODE
	  ANI   0F3H			;clear old word length
	  ORA   L			;set new word length
	  STA	MNMODE			;save new value in bios
	  CALL  INITMOD1		;initialize port
PRTWORD:  CALL  ILPRT			;print existing word length
	  DB	'Word Length:',TAB,0
	  LDA	MNMODE			;left justify word length bits
	  ANI   00CH
	  RRC
	  RRC
	  ADI	35H			;CONVERT TO ASCII + 5
	  MOV	E,A
	  MVI	C,CONOUT
	  CALL	MEX
	  CALL	ILPRT
	  DB	' bits',CR,LF,0
 	  RET
WORDTBL:  DB	'5'+80H
	  DW	0
	  DB	'6'+80H
	  DW	04H
	  DB	'7'+80H
	  DW	08H
	  DB	'8'+80H
	  DW	0CH
	  DB	0
;
;
SETSTOP:  LXI	D,STOPTBL
	  CALL  TSRCH
	  JC	SETERR
	  LDA	MNMODE
	  ANI   03FH			;CLEAR OUT OLD STOP BITS
	  ORA   L			;SET NEW STOP BITS
	  STA	MNMODE			;SAVE NEW STOP BITS
	  CALL  INITMOD1		;INITIALIZE BAUD AND PORT
PRTSTOP:  CALL  ILPRT
	  DB	'Stop Bits:',TAB,0
	  LDA	MNMODE
	  ANI   0C0H			;LEFT JUSTIFY STOP BITS
	  RLC
	  RLC
	  ADD	A			;COMPUTE TABLE OFSET
	  MOV	E,A
	  MVI	D,0
	  LXI	H,STOPTBL1
	  DAD	D			;COMPUTE ENTRY ADDRESS
	  MOV	E,MŠ	  INX	H
	  MOV	D,M			;DE = TABLE DATA
	  MVI	C,PRINT
	  CALL	MEX
	  MVI	C,ILP
	  CALL	CRLF
 	  RET
STOPTBL:  DB	'1'+80H
	  DW	40H
	  DB	'1.','5'+80H
	  DW	80H
	  DB	'2'+80H
	  DW	0C8H
	  DB	0
STOPTBL1: DW	STOP1
	  DW	STOP1 
	  DW	STOP15
	  DW	STOP2
STOP1	  DB	'1$'
STOP15	  DB	'1.5$'
STOP2	  DB	'2$'
;
SETHELP:  LXI	D,HLPMSG
	  MVI	C,PRINT
	  CALL	MEX
	  RET
;
HLPMSG:	  DB	CR,LF,'SET command, SUPERBRAIN version:',cr,lf
	  DB	CR,LF,'SET    (Shows current settings)'
	  DB	CR,LF,'SET ?'
	  DB	CR,LF,'SET BAUD 110 <or> 300 <or> 600 <or> 1200 ... 9600'
	  DB	CR,LF,'SET WORD 5 <or> 6 <or> 7 <or> 8'
	  DB	CR,LF,'SET PRTY Even <or> Odd <or> None'
	  DB	CR,LF,'SET STOP 1 <or> 1.5 <or> 2'
	  DB	CR,LF,'$'
;
CRLF:  	  CALL	ILPRT
	  DB	CR,LF,0
	  RET
;
; Compare next input-stream item to table @DE;
; CY=1 if not found else HL=matched data word
;
TSRCH:	  MVI	C,LOOKUP
	  JMP	MEX
;
ILPRT:	  MVI	C,ILP
	  JMP	MEX
;
; Test the status of the list device since Intertec never implemented this
; function into the BIOS.
;
LISTST:	  IN	41H		;GET AUX PORT STATUS
	  ANI	81H		;DSR + TxRDY
	  XRI	81H		;INSURE ALL ARE PRESENT TOGETHERŠ	  JNZ	LISTST1		;JUMP IF NOT READY
	  MVI	A,0FFH		;SET READY
	  RET
LISTST1:  XRA	A		;SET NOT READY
	  RET
;.....
;
;
;              (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;               
;
;
SPCLMENU: RET
;
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;                                0D00H (without Smartmodem).
;
;
;
; This is the patch file for MEX 1.0 -- you may edit this file to change
; various initial variables. Assemble with ASM or MAC, then use MLOAD
; to patch the changes into MEX:
;
;	ASM MEXPAT10.AAZ			;assemble the edited file
;	MLOAD NEWMEX.COM=MEX.OBJ,MEXPAT10	;patch MEX
;
; You may also pull this file into your modem overlay (be sure you in-
; clude the ORG statement below).
;
; The order of the patch variables supported here will not change from
; version to version (i.e., new items will be added on to the end).
;
;
	ORG	0D00H		;location of patch variables
;
LF	EQU	10		;define ASCII linefeed code
;
;
; The following line defines the MEX service call entry point, and
; is not meant to be changed by the user
;
MEX:	DS	3		;MEX service call processor
	DS	3		;reserved
	DS	1		;reserved
;
; The following line contains the initial free-memory pointer for
; MEX.  Sophisticated modem overlays requiring additional space may change
; this pointer (ie, move it higher), and thus "protect" an area of RAM.
;
MEMRY:	DS	2		;first free memory pointer
;Š; Following are the lowest-level vectors for console and list I/O used
; by MEX.  These normally point to routines that save the registers and
; vector to the appropriate BIOS routines.  Complex applications may
; need to intercept (or even replace) these routines.  If you do this,
; be sure to preserve DE, HL and BC.
;
STSVEC:	DS	2		;console status vector
INVEC:	DS	2		;console input vector
OUTVEC:	DS	2		;console output vector
LVEC:	DS	2		;list output vector
LSTVEC:	DW	LISTST		;list status vector
;
; The following line defines the location of the default MEX prompt.
; If you'd like to provide your own initial prompt, add a DW statement
; pointing to a prompt buffer structured as follows:
;
;		DB <max size of buffer>
;		DB <length of actual prompt>
;		DB <prompt string>
;
; <maxsize> and <length> may be equal (especially if you disable the
; ID command by setting CHGPMT, below to 0); the ID command will, if
; left enabled, be limited to the <max size> value.
;
PROMPT:	DS	2		;prompt location
	DS	1		;reserved
TYPLIN:	DB	22		;for TYPE command: # lines/screen
PAUSFL:	DB	1		;for TYPE cmd: 1=pause 0=no pause
SEPCHR:	DB	';'		;multiple command-line separator
;
; following five for SENDOUT command
;
SOWAIT:	DB	4		;# seconds waiting for a sendout echo
SOREPL:	DB	8		;# seconds waiting for initial reply
SOTRIG:	DB	'>'		;sendout trigger char from remote
CANCHR:	DB	'U'-64		;sendout char to cancel line to remote
SORTRY:	DB	6		;sendout # retries
;
;
HEXFLG:	DB	0		;hex/decimal mode
ESCCHR:	DB	05H		;terminal mode escape char (05H = HERE IS)
NOBELL:	DB	0		;set to 1 to disable bell
;
; Buffer variables.  See BUFFERS.DOC for setup information
;
PSIZE:	DB	2		;default=2k
ASIZE:	DB	255		;"big" capture buffer
XSIZE:	DB	16		;16K transfer buffer
NSIZE:	DB	1		;1k for 85 batch files
PRELEN:	DB	40		;maximum length of PREFIX string
SUFLEN:	DB	40		;maximum length of SUFFIX string
;
; Misc. stuff
;
CDOSFL:	DB	0		;non-zero for CDOSŠWTECHO:	DB	0		;non-zero sets "wait-for-echo"
KYSIZE:	DW	400		;size of keystring area, in bytes
CISFLG:	DB	1		;non-zero allows CIS file transfers
CISOK:	DB	1		;non zero allows STAT CIS ON or OFF
CHGPMT:	DB	1		;non-zero allows ID (prompt chg) command
ERRID:	DB	1		;non-zero prints ID msg in err msgs
;
; by setting the following DB to 0, you can disable the HELP
; command, freeing up space used by the help file index.
;
HELPOK:	DB	1		;non-zero allows HELP command
MEXDU:	DB	0		;user \/  alternate area for READ,LOAD,INI.MEX
	DB	0		;drive/\  & HELP.MEX (if SEARCH <>0)
DEBUG:	DB	0		;debugging in term-mode if non-zero
EXCLSY:	DB	1		;non-0 excludes $SYS from batchsend, dir
INIMEX:	DB	0		;non-zero runs INI.MEX (if present) at startup
RTIMER:	DB	1		;receiver wait: # seconds [Plouff patch]
PQSIZE:	DW	150		;size of the modem-port queue
PHSIZE:	DB	30		;phone library size (# entries)
SILENT:	DB	0FFH		;0=silence multi-line & READ cmd echo
ALERT:	DB	255		;alert-bell count on CALL complete
EXTEND:	DB	0		;non-zero: unknown commands goto READ processor
SPLIT:	DB	0		;non-zero: splits phonelib printout, shows baud
SEARCH:	DB	0		;search mode 0,1,2,3
;
; Following is the GLOBAL secondary options table.  To
; set an option to global, change its ASCII character to a 0.
;
RESTT:	DB	'BDLQRSTVX'
;
;
	END
