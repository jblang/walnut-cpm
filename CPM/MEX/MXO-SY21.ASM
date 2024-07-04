;	Title	'MEX overlay for the Sanyo MBC-1000 Computer'
;
;
; This file adapts the Sanyo MBC-1000 computer to the MEX modem program.
; 
;
REV	EQU	21		;overlay revision level
;
; 09/15/84: Revision 2.1  A major revision.  Added features of SET SPKR,
;    SET WAIT, and SET DIAL, and disable auto-answer.  All the routines 
;    were borrowed from MXM-US13.ASM but with great difficulty and much
;    alteration.  Added conditional assembly for smartmodem (SMMODEM) &
;    ANCHOR, added DELAY to slow modem commands where the Anchor can 
;    catch them, and fixed a revision 2.0 bug where the SET status would
;    lose the current baudrate info.  This revision tested with an Anchor
;    Mark XII Smartmodem until all works.  Other smartmodems may require
;    revision of delays and timing constants.  Sanyo does not make pin 8
;    of the RS-232C connector available so the DCD (Data Carrier Detect)
;    cannot be sensed and the Carrier Check and Carrier Show (CARRCK and
;    CARRSH) portions were eliminated. Altered the SET status display to
;    suit my taste and always provide status with help commands. Other
;    modems are cautioned that their unique portions are essentially
;    untested.  Tested with MX-SM13A & MEX111.       ((Bob Sandel))     
;
; 08/09/84: Revision 2.0  Combined MXO-SY11 and M7SY-3.ASM
;    Added variables PTIMER, PBAUD, SQWV2 & N8251. Cleaned up some minor bugs
;    in the OR routine for the 8251 output & insured out of mode state always
;    occurs in SBAUD.  Added comments where changes were made.   (Bob Sandel)
;
;--------------------------------------------------------------------
;
;  THIS MODIFICATION MAKES USE OF TIMER 2 OF THE 8253 PROGRAMMABLE
;  INTERVAL TIMER (IC4) ON THE SERIAL I/O BOARD OF THE SANYO MBC-1000.
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
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.;
; Edit for your preferences then follow the "TO USE:" example shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.  Because of tem- 
; perature and component variations, you mave have to alter the timing
; parameters BD110-BD19K, plus or minus 1 or 2 numbers, if CRC errors 
; occur frequently during transmission and reception.
;
; Only 300 & 1200 Baud are enabled; info for other baudrates is located
; in table form above INITBD. For full capability, N8251 would have to
; be implemented via a second lookup table.
;
;
; _______________________________________________________________________
;
; Note that all overlays may freely use memory up to 0CFFH.  If your
; overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM) or
; the MEX DATEC 212 overlay (MXO-DT10.ASM), the physical modem overlay
; should terminate by 0AFFH.
;
; The SET command allows the user to change the baud rates, and the
; parity.  The parity options are: No parity (NONE); Even parity (EVEN);
; Even parity with 8 data bits (EVEN8); Odd parity (ODD); and Odd parity
; with 8 data bits (ODD8).  EVEN8 and ODD8 are for special purposes and
; will most likely never be used.
;_______________________________________________________________________
;
; Misc equates
;
YES     EQU	0FFH
NO      EQU	0
NA      EQU	0FFH		;Value for baud rate not available
;
SMMODEM EQU     YES             ;Yes=Smartmodem
ANCHOR  EQU     YES             ;Anchor has no speaker or programmable wait
                                ;No=Hayes, U.S. Robotics  
BELL    EQU	07H		;bell
TAB     EQU	09H             ;tab
LF      EQU	0AH		;line feed
CR      EQU	0DH		;carriage return
ESC     EQU	1BH		;escape
TPA     EQU     0100H           ;Transient Program Area
MEX     EQU     0D00H           ;Address of the service processor 
;
;
; The following information was altered for the Sanyo MBC-1000
;
PORT:   EQU     0A5H	;Sanyo 8251 modem USART control port
PTIMER  EQU     0A3H    ;8253 programmable interval timer control
PBAUD   EQU     0A2H    ;8253 data port (square wave, n/2+n/2)
;
MODCTL:	EQU	PORT	;MODEM CONTROL PORT
MODDAT:	EQU	PORT-1	;MODEM DATA PORT
;
MDRCVB: EQU     00000010B       ;bit to test for RECEIVE
MDRCVR: EQU     00000010B       ;value when READY
MDSNDB: EQU     00000001B       ;bit to test for SEND
MDSNDR: EQU     00000001B       ;value when READY
EVEN    EQU     01111000B       ;EVEN parity, 7 data bits
EVEN8   EQU     01111100B       ;EVEN parity, 8 data bits
ODD     EQU     01011000B       ; ODD parity, 7 data bits
ODD8    EQU     01011100B       ; ODD parity, 8 data bits
NONE    EQU     01001100B       ;  no parity, 8 data bits = NONE
;
;
SQWV2   EQU     10010110B      ;Configures 8253 Timer-2 for square waves
N8251   EQU     00000010B      ;See 8251 lookup table below (150-1200 baud)
;
;  Progammable Baud Rate factors (theoretical)        
;
;  Minor adjustment of 8253 n +1,-1 may be required    8253      8251 
;                                                      ----      ----
BD110:          EQU     NA              ;NO 110    |    2C        03
BD300:          EQU     041H            ; <300>    |    40        02
BD450:          EQU     NA              ;NO 450    |    2B        02	
BD600:          EQU     NA              ;NO 600    |    20        02
BD710:          EQU     NA              ;NO 710    |    1B        02
BD1200:         EQU     010H            ;<1200>    |    10        02
BD2400:         EQU     NA              ;NO 2400   |    80        01
BD4800:         EQU     NA              ;NO 4800   |    40        01
BD9600:         EQU     NA              ;NO 9600   |    20        01 
BD19K:          EQU     NA              ;NO 19200  |    10        01
;
;
INITBD:		EQU	5		;Initial baud rate (1200)
;
; Control bytes
;
RESET1  EQU     10000111B               ;Initialize UART
RESET2  EQU     01000000B               ;Internal reset
CHIPSET EQU     00100111B               ;DTR, RTS, RE, TE
DISCNT  EQU     00010111B               ;no DTR, RTS, RE, TE
;
BREAK   EQU     CHIPSET OR 8H   ;BREAK character
;
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately pre-
; ceeding the actual FCB (to contain user # information).  If you've
; used MEX-10 for input instead of BDOS-10 (or you're parsing part
; of a SET command line that's already been input), then MEX will
; take care of DU specs, and set up the FCB accordingly.  There-
; after all file I/O calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
;
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
	ORG	TPA		;we begin
;
;
	DS	3		;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM: DB	NO              ;yes=PMMI modem \ / These 2 locations are not
SMODEM: DB	SMMODEM         ;yes=Smartmodem / \ referenced by MEX
TPULSE: DB      'P'             ;T=touch, P=pulse (not referenced by MEX)
CLOCK:  DB      40              ;clock speed x .1, up to 25.5 mhz.
MSPEED: DB      INITBD          ;sets initial baud rate
                                ;0=110	1=300  2=450  3=600  4=710
                                ;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY: DB	5		;default time to send character in
                                ;terminal mode file transfer (0-9)
                                ;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:  DB	5		;end-of-line delay after CRLF in terminal
                                ;mode file transfer for slow BBS systems
                                ;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS: DB	5		;number of directory columns
SETFL:  DB	YES		;yes=user-defined SET command
SCRTST: DB	YES		;yes=if home cursor and clear screen
                                ;routine at CLRSCRN
        DB	0		;was once ACKNAK, now spare
BAKFLG: DB	NO		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
                                ;no=default to Checksum checking
TOGCRC: DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:  DB	NO		;yes=convert backspace to rub
TOGLBK: DB	YES		;yes=allow toggling of bksp to rub
ADDLF:  DB	NO		;no=no LF after CR to send file in
                                ;terminal mode (added by remote echo)
TOGLF:  DB	YES		;yes=allow toggling of LF after CR
TRNLOG: DB	NO		;yes=allow transmission of logon
                                ;write logon sequence at location LOGON
SAVCCP: DB	YES		;yes=do not overwrite CCP
LOCNXT: DB	NO		;yes=local cmd if EXTCHR precedes
                                ;no=not local cmd if EXTCHR precedes
TOGLOC: DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST: DB	YES		;yes=allow toggling of printer on/off
                                ;in terminal mode. Set to no if using
                                ;the printer port for the modem
XOFTST: DB	NO		;yes=allow testing of XOFF from remote
                                ;while sending a file in terminal mode
XONWT:  DB	NO		;yes=wait for XON after sending CR while
                                ;transmitting a file in terminal mode	
TOGXOF: DB	YES		;yes=allow toggling of XOFF testing
IGNCTL: DB	YES		;yes=do not send control characters
                                ;above CTL-M to CRT in terminal mode
                                ;no=send any incoming CTL-char to CRT
EXTRA1: DB	0		;for future expansion
EXTRA2: DB	0		;for future expansion
BRKCHR: DB	'@'-40H		;^@ = Send a 300 ms. break tone
NOCONN: DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR: DB	'L'-40H		;^L = Send logon
LSTCHR: DB	'P'-40H		;^P = Toggle printer
UNSVCH: DB	'R'-40H		;^R = Close input text buffer
TRNCHR: DB	'T'-40H		;^T = Transmit file to remote
SAVCHR: DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR: DB	'^'-40H		;^^ = Send next character
;
; Equates used only by PMMI routines grouped together here.
;
	DS	2		;not used
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL:	IN	MODCTL		;in modem control port
	RET
	DB	0,0,0,0,0,0,0	;spares if needed
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
; MEX will be retained.
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	DS	3		;dial digit in A (see info at PDIAL)
DISCV:	DS	3		;disconnect the modem
GOODBV: JMP	DUMMY		;called before exit to CP/M
INMODV: JMP	NITMOD		;initialization. Called at cold-start
NEWBDV: JMP	SBAUD		;set baud rate
NOPARV: DS	3		;set for no parity (called after transfer)
PARITV: DS	3		;set modem parity (called before transfer)
SETUPV: JMP	SETCMD		;SET command
SPMENV: DS	3		;not used with MEX
VERSNV: JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV: JMP	SBREAK		;send a break
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
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	0,0,0,0,0,0,'$'		;clear to end-of-screen (0 for pause)
CLSMSG:	DB	1AH,0,0,0,0,0,'$'	;clear whole screen (0 for pause)
;
; Modem initialization.
;
NITMOD: MVI     A,SQWV2         ;Initialize 8253 chip so counter 2 becomes
        OUT     PTIMER          ;baud rate programmable clock (square wave)
        LDA	MSPEED
        CALL	SBAUD		;set the baudrate
 ;
   IF SMMODEM                   ;if smartmodem, send start-up cmd(s)
INITSM:
        LXI     H,INISTR        ;point to initialization string
SENDLP: MVI     C,SNDRDY        ;MEX service function # 251                         
        CALL    MEX             ;test for modem-send-ready
        JNZ     SENDLP          ;loop if not ready
        MOV     A,M             ;get character
        INX     H               ;increment to next character address
        CPI     '$'             ;end-of-string ?
        JZ      INITEX          ;Yes, exit
        MOV     B,A             ;No, put character in B
        MVI     C,SNDCHR        ;MEX service function # 249
        CALL    MEX             ;let MEX output character to modem
        CALL    DELAY           ;needed for Anchor: others ???
        JMP     SENDLP          ;loop 'til end-of message
;
INITEX: MVI     B,5             ;wait 0.5 sec for modem to say "OK"
        MVI     C,TIMER         ;MEX service function # 254
        CALL    MEX             ;kill time
;
   ENDIF                        ;Smartmodem
; 
       RET
;
DELAY:  MVI	B,1             ;now set for 100 milliseconds
        MVI     C,TIMER         ;play with values until modem works
        CALL	MEX
        RET          
;
; You may define an intialization string in INISTR to set up smartmodem
; in any configuration desired. String must end with a '$'
;
;
; Command string sent to modem after I/O initialization
;
  IF SMMODEM
;
INISTR:
        DB      'ATV0',CR       ; Disable verbose mode
        DB	'ATS0=0',CR	; Disable auto-answer
   ENDIF                        ; Smartmodem 
;
   IF SMMODEM AND NOT ANCHOR    ; Pls check that your modem supports 
	DB	'ATX1',CR	; Send extended result codes
SPBYTE:	DB	'ATM1',CR	; Speaker on 'til connect
WABYTE:	DB	'ATS7=30',CR	; Wait 30 seconds for carrier
   ENDIF                        ; END of smartmodem AND not Anchor
;
   IF SMMODEM                   ; continuation after Anchor part	
        DB	'ATV1',CR	; Set verbose result codes
        DB      '$'             ; end-of-string :Must be here 
;
   ENDIF                        ;Smartmodem 
;
        RET
;
; Send-break routine
;
SBREAK: MVI     A,BREAK
        OUT     MODCTL
        MVI     B,2             ;wait 200 ms
        MVI     C,TIMER
        CALL    MEX
        MVI     A,CHIPSET       ;reset break
        OUT     MODCTL
        RET
;
; Exit routine --  called just before MEX exits to CP/M
;
DUMMY:	RET			;we don't need one
;
;
; Set Baud Rate
;
; New baud-rate code in A.
; NOTE: this routine (ie, the one vectored through NEWBDV) should
; update MSPEED with the passed code, but ONLY if that rate is
; supported by the hardware.
;
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
;
SBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	C,A		;save baud rate code  
	MVI	B,0
	LXI	H,BTABL		;Get baudrate value
	DAD	B               ;HL now contains address of baudrate number
	MOV	A,M             ;A  now contains baudrate n
	CPI	NA		;See if baud rate valid
	STC			;set for not valid
	JZ	NOTVAL		;not valid
;
                                ;Set hardware/software implemented baudrate
	OUT     PBAUD           ;8253 now set
;
	MVI     A,RESET1        ;Insure out-of-mode state
	OUT     MODCTL          ;Modem status port
	MVI     A,RESET1        ;Do it again
        OUT     MODCTL          ;For slight extra delay
	MVI	A,RESET2        ;Then reset the USART 
	OUT	MODCTL          ;Modem status port
	XTHL			;delay -- must be in pairs
	XTHL
        MVI     A,N8251         ;This factor works for the range 150-1200 baud
	LXI	H,PARITY        ;A contains baudrate factor
        ORA     M               ;OR parity and data length w baudrate factor	
	OUT	MODCTL          ;8251 Mode now set
	MOV     A,C		; get baud rate code
	STA	MSPEED		;save baud rate code
	MVI	A,CHIPSET	;set chip for I/O
	OUT	MODCTL          ;8251 Command now set
	IN      MODDAT          ;Clear data port
	XRA	A		;clear carry flag
NOTVAL:	POP	B
	POP	D
	POP	H
	RET
;
; Parity control byte location
;
PARITY:	DB	NONE
;
; Baud rate table
;
BTABL:	DB	BD110
	DB	BD300
	DB	BD450
	DB	BD600
	DB	BD710
	DB	BD1200
	DB	BD2400
	DB	BD4800
	DB	BD9600
	DB	BD19K
; 
; Sign-on message
; 
SYSVER:	
        LXI     D,SOMESG	; Point to signon message
        MVI     C,PRINT         ; MEX print string
        CALL    MEX		; Print message on term
;
CARRSH:				; Carrier Show & Carrier Detect deleted
CARRCK: RET                     ; No carrier detect capability
;
;
SOMESG:
	DB	'Sanyo MBC-1000 programmable baudrate version '
        DB	REV/10+'0','.'
	DB	REV MOD 10+'0',CR,LF,'$'
;
;
; Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		;align output character
	MVI	C,CONOUT	;print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	CALL    CRLF            ;for better readability
        MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse command
	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.
;
; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'PARIT','Y'+80H		;"set parity"
	DW	STPAR
;
   IF NOT ANCHOR                ; Anchor has no speaker or prog. wait
	DB	'SPK','R'+80H	; "set spkr"
	DW	STSPKR
	DB	'WAI','T'+80H	; "set wait"
        DW	STWAIT
   ENDIF                        ;not Anchor modem
;
	DB	'DIA','L'+80H	; "set dial"
	DW	STDIAL
;

	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	
	LXI	H,SHOTBL	;get table of SHOW subroutines
SETSLP:	MOV	E,M		;get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		;end of table?
	ORA	E
	JZ      sthelp          ;exit with help menu if so
	PUSH	H		;save table pointer
	XCHG			;adrs to HL
	CALL	GOHL		;do it
	CALL	CRLF		;print newline
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
;
; table of SHOW subroutines
; 
SHOTBL:	DW	BDSHOW
	DW	PSHOW
  IF NOT ANCHOR                 ;Anchor has no speaker or prog. wait
	DW	SPSHOW
  	DW	WASHOW
  ENDIF                         ;not Anchor
	DW	DISHOW
	DW	0		; <<== table terminator
;
;
; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET commands:',CR,LF
;
	DB	CR,LF,'SET BAUD 300 <or> 1200'
;
	DB	CR,LF,'SET PARITY EVEN[8] <or> ODD[8] <or> NONE'
; 
   IF NOT ANCHOR                 ; Anchor has no speaker or prog.wait
;
        DB	CR,LF,'SET SPKR <OFF> or <ON> or <DEBUG>'
        DB	CR,LF,'SET WAIT <30> or <60> or <90>'
   ENDIF                         ; not Anchor	
;
	DB	CR,LF,'SET DIAL <TOUCH> or <PULSE>'
;
	DB	CR,LF,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	SBAUD		;no, try to set it
	JC	SETERR		;not-supported code
        JMP     SETSHO          ;review parameters
;
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate: ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
        CALL    CRLF
	RET
;
; SET PARITY processor
;
STPAR:	LXI	D,PARTBL	;lookup next input item in table
	CALL	TSRCH
	JC	SETERR          ;if not found, error
	MOV	A,L             ;get parity code
	STA	PARITY		;store it 
	LDA	MSPEED		;get baud rate code 
	CALL	SBAUD           ;set parity
        JMP     SETSHO          ;review parameters
;
PSHOW:	CALL	ILPRT           ;show parity
	DB	'Parity:    ',0
	LXI	H,PARFND        ;find proper message
	LDA	PARITY          ;get parity value
	MOV	B,A
FNDP:	MOV	A,M             ;see if parity value matches
	ORA	A               ;first see if zero
	JZ	SETERR          ;should never get here
	CMP	B               ;match?
	INX	H               ;point to first letter of message
	JZ	CDISP           ;matches, type message
FNDNXT:	MOV	A,M
	ORA	A		;see if end of last message
	INX	H
	JP	FNDNXT		;not finished
	INX	H		;increment past parity byte
	JMP	FNDP
;
; PARITY argument table
; Format of the table is:  Starting at PARTBL, the name is
; given (ending with 80H bit set), then the one byte code
; for setting that parity.  The next byte duplicates the
; NEXT parity code (used in PSHOW).  The byte at PARFND
; duplicates the first parity code.
;
PARFND:	DB	EVEN
PARTBL:	DB	'EVE','N'+80H	;even parity, 7 data bits
	DB	EVEN,EVEN8
	DB	'EVEN','8'+80H	;even parity, 8 data bits
	DB	EVEN8,ODD
	DB	'OD','D'+80H	; odd parity, 7 data bits
	DB	ODD,ODD8
	DB	'ODD','8'+80H	; odd parity, 8 data bits
	DB	ODD8,NONE
	DB	'NON','E'+80H	;  no parity, 8 data bits
	DB	NONE,0
;
	DB	0		;<<== table terminator
;
;
;
   IF NOT ANCHOR                ; Anchor does not have speaker
;
; SET SPKR processor
;
STSPKR:	LXI	D,SPKTBL	; lookup next input item in table
	CALL	TSRCH
	JC	SETERR		; if not found, error
	STA	SPBYTE+1	; store the spkr command
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
SPSHOW:	CALL	ILPRT		; show spkr mode
	DB	'Speaker:   ' ,0
	LDA	SPBYTE+1	; get spkr byte
	CPI	'1'
	JZ	SPONPT		; spkr on part-time
	CPI	'2'
	JZ	SPON		; spkr on continuously
;
SPOFF:	CALL	ILPRT
	DB	'OFF',0
	RET
;
SPONPT:	CALL	ILPRT
	DB	'ON until connect',0
	RET
;
SPON:	CALL	ILPRT
	DB	'ON always',0
	RET
;
SPKTBL:	DB	'OF','F'+80H	; set spkr off
	DB	'0',0
	DB	'O','N'+80H	; set spkr on 'til connect	
	DB	'1',0
	DB	'DEBU','G'+80H	; set spkr on continuously
	DB	'2',0
 	DB	0		; <<=== table terminator
;
;
;
; SET WAIT processor
;
STWAIT:	LXI	D,WAITBL	; lookup next input item in table
	CALL	TSRCH           ; search for parameter value
	JC	SETERR		; if not found, error
	STA	WABYTE+5	; store the wait msb value
	MVI	A,'0'		; fake lsbyte
	STA	WABYTE+6	; store the wait lsb value
	CALL	NITMOD		; (re)initialize modem
	JMP	SETSHO		; review parameters
;
WASHOW:	CALL	ILPRT
	DB	'Wait:      ',0
	LDA	WABYTE+5
	CALL	TYPE		; show msb
	LDA	WABYTE+6
	CALL	TYPE		; show lsb
	CALL	ILPRT
	DB	' seconds for carrier',0
	RET
;
WAITBL:	DB	'3','0'+80H	; "set wait 30"
	DB	'3',0
	DB	'6','0'+80H	; "set wait 60"
	DB	'6',0
	DB	'9','0'+80H	; "set wait 90"
	DB	'9',0
	DB	0		; <<=== table terminator
;
   ENDIF                        ;not Anchor
;
;
;
; SET DIAL processor
;
STDIAL:	LXI	D,DIATBL	; lookup next input item in table
	CALL	TSRCH           ; search for parameter value
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
; DIAL argument table
;
DIATBL:	DB	'TOUC','H'+80H	; touch tone
	DB	'T',0
	DB	'PULS','E'+80H	; pulse dial
	DB	'P',0
	DB	0		; <<=== table terminator
; 
;
;
;  Print message ending with 80H bit set
;
CDISP:	MOV	A,M		;get character to print
	INX	H		;point to next character
	PUSH	PSW		;save 80H bit
	ANI	7FH		;strip 80H bit just in case
	CALL	TYPE
	POP	PSW
	ORA	A
	JM	CRLF		;finished
	JMP	CDISP
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
;
;------------------------------------------------------------
;
; End of Sanyo MBC-1000 MEX modem overlay
;
;------------------------------------------------------------
;
	END