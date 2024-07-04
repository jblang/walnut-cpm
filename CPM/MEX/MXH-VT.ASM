; Title - Overlay file for MEXxx
;
REV     EQU     35	;V 3.5 
;
;
;This  Overlay  File  supports  the DEC Micro VT180 with CP/M.
;
;We  use the COMM-Port of the Micro's.  Baud-rates are "parallel"
;to the console Baud-rates - no need for  a  "special"  baud-rate
;routine.   Since  the COMM-port is I/O-wise Reader/Punch, we use
;the BDOS calls.
;
;To  test  for  COMM-status  ,  we  use  I/O  byte redirection in
;conjunction with direct BIOS-CONSTAT call.
;
;This  technique  although  a  little  bit slower than direct I/O
;using  Interrupt  on  INPUT  is  general  enough  to  be  system
;independent.
;
;       - B. Eiben DEC Large System Marketing Marlboro Mass
;
; And more or less bios version independant.--Bill Pechter
;
;***********************************************************************
;
;  5-Jun-1984   Adapted from M7VT-2.ASM by Bernie Eiben.  
;   Rev 1.0     
;  Stu Fuller
;
; 17-Mar-86	Version 3.4 removed ZCPR2/3 bit manipulation.  That will
; Bill Pechter	now be done by poke commands in Mex/Mexplus Ini.Mex.
; 
; 22-Aug-86     Version 3.5 test to fix sendout.  Added test for status
; Bill Pechter	and RETJNK to avoid hanging.
;______________________________________________________________________________
;
;			ZCPR2			ZCPR3		ZCPR3 with RCP
;______________________________________________________________________________
;
; change contents 	EA3CH			EAFEH		E240H
; at this address
; to 64H from 74H to
; disable wordstar
; ^x^s cursor key
; translation.
;______________________________________________________________________________
;
; change contents	EA60H			EB1CH		E31CH
; at this address to 
; 01 from 05H to
; disable the 
; automatic xoff-xon
; transmission.
;
;------------------------------------------------------------------------------
;
;bios code looks like this--example using ZCPR3 without RCP
;
;  	  Port#		Port control 	  data
;			block    
;
;contents:  41H		74H		  00
;address   eafdH	eafeH		  eaff
;
; QMRCVFL EQU     01H     ; Mask to allow me to send XON/XOFF
; QMXOFFD EQU     02H     ; Mask indicating I sent an XOFF
; QMXMTFL EQU     04H     ; Mask to allow other end to stop me
; QMSUSP  EQU     08H     ; Mask indicating I got an XOFF
; QMARROW EQU     10H     ; Mask for arrow xlate bit
; QMBIT7  EQU     20H     ; Mask for "use only 7 bits"
; QMCCFLS EQU     40H     ; Mask for "flush buffer if 2 ^C's seen"
; QM1STCC EQU     80H     ; Mask for "first ^C seen"
;
;NOTE:  DO NOT poke any bits with CP/M80 (STANDARD DEC DISTRIBUTION) or
;	MultiSystem 180 (by Ken Heyda)...poking of random bits would
;	be disasterous.
;
;****************************************************************************
;
;
TRUE:           EQU     0FFH
FALSE:          EQU     0
YES:            EQU     0FFH
NO:             EQU     0
;
BELL	EQU     07H             ;bell
TAB	EQU     9
CR	EQU     13              ;carriage return
LF	EQU     10              ;linefeed
ESC	EQU     1BH             ;escape
;
;
;
I8080	equ	yes
I8086	equ 	no
CPM	equ 	yes
PCDOS	equ 	no
;
;
;
;	SET ONE (and only one) OF EACH SET OF THE FOLLOWING CONDITIONALS
;	DEPENDING ON VERSION OF SOFTWARE and CPU TYPE
;
;
;		Mex Type
;
MEXONE 		EQU FALSE	; version 1.10 through 1.14
MEXTWO 		EQU TRUE 	; version 1.24 through 1.63 (MexPlus)
;
;

;
DAV     EQU     0FFH            ;bit(s) to test for ready
TBMT    EQU     0FFH            ;
;*****************************************************************************; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
; The Check for characters at COMM-Port using I/O redirection
;
IOBYTE  EQU     3               ; some definitions
;
;
DEFIO	EQU	95H		;
BATIO   EQU     56H             ;
;
; MEX service processor stuff
;
MEX     EQU     0D00H           ;address of the service processor
INMDM   EQU     255             ;get char from port to A, CY=none in 100 ms
TIMER   EQU     254             ;delay 100ms * reg B
TMDINP  EQU     253             ;B=# secs to wait for char, cy=no char
CHEKCC  EQU     252             ;check for ^C from KBD, Z=present
SNDRDY  EQU     251             ;test for modem-send ready
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
PUNCH:  EQU     4               ;BDOS/MEX punch function
READER: EQU     3               ;BDOS/MEX reader function
PRINT   EQU     9               ;BDOS/MEX print-string function call
;
;
;
ORG	100H
;
IF MEXTWO
;
;  LINE BELOW ADDED FOR MEX V1.24 TO MAKE LOADABLE OVERLAY
;
DB	0C3H	
;
;
;
;
        DS      2               ;(for  "JMP   START" instruction)
ENDIF;MEXTWO
;
IF MEXONE
;
	DS	3
;
;
ENDIF;MEXONE
;
; Change the clock speed to suit your system
;
PMMIMODEM:  DB  NO              ;yes=PMMI S-100 Modem                   103H
SMARTMODEM: DB  YES		;yes=HAYES Smartmodem, no=non-PMMI      104H
TONE    DB      'P'             ;T=touch, P=pulse (Smartmodem-only)     105H
CLOCK:  DB      40              ;clock speed in MHz x10, 25.5 MHz max.  106H
                                ;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: DB      5               ;0=110 1=300 2=450 3=600 4=710 5=1200   107H
                                ;6=2400 7=4800 8=9600 9=19200 default
				;set to 300 baud...
BYTDLY: DB      5               ;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
                                ;default time to send character in ter-
                                ;minal mode file transfer for slow BBS.
CRDLY:  DB      5               ;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
                                ;default time for extra wait after CRLF
                                ;in terminal mode file transfer
COLUMS: DB      5               ;number of DIR columns shown            10AH
SETFLG: DB      YES             ;yes=user-added Setup routine           10BH
SCRTST: DB      YES             ;Cursor control routine                 10CH
ACKNAK: DB      YES             ;yes=resend a record after any non-ACK  10DH
                                ;no=resend a record after a valid-NAK
BAKFLG: DB      YES             ;yes=change any file same name to .BAK  10EH
CRCDFL: DB      YES             ;yes=default to CRC checking            10FH
TOGCRC: DB      YES             ;yes=allow toggling of CRC to Checksum  110H
CVTBS:  DB      NO              ;yes=convert backspace to rub           111H
TOGLBK: DB      YES             ;yes=allow toggling of bksp to rub      112H
ADDLF:  DB      NO              ;no=no LF after CR to send file in      113H
                                ;terminal mode (added by remote echo)
TOGLF:  DB      YES             ;yes=allow toggling of LF after CR      114H
TRANLOGON:  DB 	YES             ;yes=allow transmission of logon        115H
                                ;write logon sequence at location LOGON
SAVCCP: DB      YES             ;yes=do not overwrite CCP               116H
LOCONEXTCHR: DB NO              ;yes=local command if EXTCHR precedes   117H
                                ;no=external command if EXTCHR precedes
TOGGLELOC:      DB      YES             ;yes=allow toggling of LOCONEXTCHR      118H
LSTTST: DB      YES             ;yes=printer available on printer port  119H
XOFTST: DB      NO              ;yes=checks for XOFF from remote while  11AH
                                ;sending a file in terminal mode
XONWT:  DB      NO              ;yes=wait for XON after CR while        11BH
                                ;sending a file in terminal mode
TOGXOF: DB      YES             ;yes=allow toggling of XOFF checking    11CH
IGNCTL: DB      NO              ;yes=CTL-chars above ^M not displayed   11DH
EXTRA1: DB      0               ;for future expansion                   11EH
EXITCHR DB      'E'-40H         ;^E = Exit to main menu                 11FH
BRKCHR:	DB	'B'-40H		;^B = Send 300 ms. break tone		120H
NOCONN:	DB	'N'-40H		;^N = Disconnect from the phone line	121H
LOGCHR: DB      'L'-40H         ;^L = Send logon                        122H
LSTCHR: DB      'P'-40H         ;^P = Toggle printer                    123H
UNSAVE: DB      'R'-40H         ;^R = Close input text buffer           124H
TRNCHR: DB      'T'-40H         ;^T = Transmit file to remote           125H
SAVCHR: DB      'Y'-40H         ;^Y = Open input text buffer            126H
EXTCHR: DB      '^'-40H         ;^^ = Send next character               127H
        DS      2               ;unused by MEX                          128H
;
INCTL1: JMP     INSP            ;go input status port                   12AH
        DS      7
;
OTDATA: JMP     OUTDP           ;go output data port                    134H
        DS      7
;
INPORT: JMP     INDP            ;go input data port                     13EH
        DS      7
;
MASKR:  ANI     DAV     ! RET   ;bit to test for receive ready          148H
TESTR:  CPI     DAV     ! RET   ;value of rcv. bit when ready           14BH
; Note: most overlays will use ANI TBMT at MASKS.
; However, we don't bother with it here.  TESTS: will always return ready
MASKS:  MVI     A,TBMT  ! RET   ;bit to test for send ready             14EH
TESTS:  CPI     TBMT    ! RET   ;value of send bit when ready           151H
;
;
;
IF MEXTWO
;
DCDTST:	JMP DCDVEC		;DATA CARIER DETECT 			154H
RNGDET:	JMP RNGVEC		;RING DETECT VECTOR			157H
DS	5
ENDIF;MEXTWO
;
;
IF MEXONE
;
DS	11
ENDIF;MEXONE
;
DIALV:  DS      3               ;DIALV not done here (maybe MXO-SM)     162H
SMDISC: DS      3               ; smartmodem overlay DISCV likewise 
				; (dumb modem...now we do discon below)
DISCV:  JMP	DISCON		;here's where we goto on DSC cmd.
GOODBV: JMP     GOODBY          ;                                       168H
INMODV: JMP     NITMOD          ;go to user written routine             16BH
        RET ! NOP ! NOP         ;NEWBDV                                 16EH
        RET ! NOP ! NOP         ;NOPARV                                 171H
        RET ! NOP ! NOP         ;PARITV                                 174H
SETUPV: JMP     SETCMD          ;                                       177H
        DS      3               ;not used by MEX                        17AH
VERSNV: JMP     SYSVER          ;                                       17DH
BREAKV: JMP     SBREAK          ;                                       180H
;
; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).
;
ILPRTV: DS      3               ;                                       183H
INBUFV  DS      3               ;                                       186H
ILCMPV: DS      3               ;                                       189H
INMDMV: DS      3               ;                                       18CH
        DS      3               ;                                       18FH
TIMERV  DS      3               ;                                       192H
;
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRTEST to YES at 010AH (above).
;
;
CLREOS:         LXI     D,EOSMSG        ;                               195H
                MVI     C,PRINT
                CALL    MEX
                RET
;
CLS:            LXI     D,CLSMSG        ;                               19EH
                MVI     C,PRINT
                CALL    MEX
                RET
;
;       End of fixed areas
;
;.....

;
; LINE BELOW ADDED FOR MEX V1.24 
;
IF MEXTWO
;
ORG 200H	
;
;
ENDIF;MEXTWO
;
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Actual baud rate from [7mSet-up B[m ',0
	  MVI	C,ILP
	  CALL	MEX
	  DB	CR,LF,'Apparent Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
;
; Modem I/O primitive
;
; Subroutine to output a character to the modem.
; This routine does it's own status checking.
;
OUTDP:  PUSH    B               ;save...
        PUSH    D               ;...the...
        PUSH    H               ;...registers.
        MOV     E,A             ;move output byte into E
        MVI     C,PUNCH         ;use the BDOS function
        CALL    MEX             ;go
        POP     H               ;restore...  
        POP     D               ;...the...
        POP     B               ;...registers.
        RET
;.....
;
;
; Subroutine to input a character from the modem.
; This routine will not wait until one becomes available.
;
INDP:   CALL INSP
	JZ RETJNK
	PUSH    B               ;save...
        PUSH    D               ;...the...
        PUSH    H               ;...regesters.
        MVI     C,READER        ;use the BDOS function
        CALL    MEX             ;go
        POP     H               ;restore...
        POP     D               ;...the...
        POP     B               ;...registers.
        RET
;
;
RETJNK: MVI A,0			;Return junk if not ready
	RET			; so we don't hang
;
;
; The Check for characters at COMM Port using I/O redirection
;
INSP:   PUSH    B
        PUSH    D
        PUSH    H               ; save the environment
        MVI     A,BATIO         ; change I/O byte
        STA     IOBYTE
        CALL    BCONST          ; call BIOS direct - see NITMOD
        PUSH    A
        LDA     SAVEIO          ; change I/O byte back
        STA     IOBYTE
        POP     A
        POP     H               ; restore environment
        POP     D
        POP     B
        RET

;               
NITMOD: LHLD    1               ; Get BIOS Jump-table adress
        LXI     D,3
        DAD     D               ; CONSTAT routine in BIOS
        SHLD    BCONST+1        ; modify our "routine"
        LDA     IOBYTE          ; Save I/O byte
        STA     SAVEIO          ;
;
;
SETCMD:	  MVI	C,SBLANK	;Any arguments?
	  CALL	MEX
	  JC	TELL		;If not, go display baud
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;Tell user input not valid
	  DB	'++(Only 110,300,600,1200,2400,9600,19200 supported)++',CR,LF,0 
	  RET
;
CMDTBL:	  DB	'11','0'+80H
	  DW	OK110
	  ;
	  DB	'30','0'+80H
	  DW	OK300
	  ;
	  DB	'60','0'+80H
	  DW	OK600
	  ;
	  DB	'120','0'+80H
	  DW	OK1200
	  ;
	  DB	'240','0'+80H
	  DW	OK2400
	  ;						
	  DB	'480','0'+80H
	  DW	OK4800
	  ;
	  DB	'960','0'+80H
	  DW	OK9600
	  ;
	  DB	'1920','0'+80H
	  DW	OK19200
	  ;
	  DB	0
;
;
;
;
OK110	  MVI	A,0
	  JMP 	LOADBD
;
OK300:	  MVI	A,1
	  JMP   LOADBD
;
OK600	  MVI	A,3
	  JMP 	LOADBD
;
OK1200:	  MVI	A,5
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  JMP	LOADBD
;
OK19200:  MVI	A,9
;
LOADBD:	 STA MSPEED
	 RET	 		; area for code to set actual baud rate
				; if overlay can be hacked to use
				; programmable port such as general purpose
				; port
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	7
	  JZ	OK4800
	  CPI	8
	  JZ	OK9600
	  CPI	9
	  JZ	OK19200
	  RET
;
;
BCONST: JMP     $-$             ; address "filled in" by above code
;
;
IF MEXTWO
;
;
DCDVEC:	MVI	A,0FEH		; RETURN 0FFH IF CARRIER
				; RETURN 0 NO CARRIER
				; RETURN 0FFE IF OVERLAY DOESN'T KNOW
		RET

RNGVEC: MVI	A,0FEH		; RETURN 0FFH IF CARRIER
				; RETURN 0 NO CARRIER
				; RETURN 0FFE IF OVERLAY DOESN'T KNOW
	RET
;
;
ENDIF;MEXTWO
;
SBREAK:
;pbausl EQU     90H     ;The Baud-Rate register.
prntst  EQU     49H     ;Printer
;prndat EQU     48H
contst  EQU     41H     ;Console
;condat EQU     40H
gentst  EQU     51H     ;General port.
;gendat EQU     50H
comtst  EQU     59H     ;COMM-Port
;comdat EQU     58H
;output EQU     01H     ;Output ready bit.
;input  EQU     02H     ;Input ready bit.
comctl  equ     59h             ;VT180 communications port
crtctl  equ     41h             ;VT180 crt port
;VT180 serial port command bits
txe     equ     1               ;transmit enable
dtr     equ     2               ;dtr on
rxe     equ     4               ;rx enable
sndbrk  equ     0Ah		;dtr and break...
rerr    equ     10h             ;reset error
rts     equ     20h             ;RTS on
reset   equ     40h             ;port reset
NODTR	EQU	14H
;
;send break to comm port
;
        lxi     h,38500         ;250 ms(?)
        mvi     a,comctl        ;Get address of selected port
        mov     c,a             ;Into C
        mvi     a,sndbrk
;       OUT     C,A             ;Want to send to port addressed by C
        db      0EDH,079H       ;Op code for above instruction
sndbrk1:dcx     h               ;timing loop...
        mov     a,l
        ora     h
        jnz     sndbrk1          ;...until over
        mvi     a,comctl        ;Get the address for the port
        mov     c,a             ;Into C
        mvi     a,txe+dtr+rxe+rerr+rts  ;enable tr/rc, dtr, reset error
;       out     c,a             ;Z-80 only instruction
        db      0EDH,079H       ;Op code for above instruction
        out     contst          ;reset ports
        ret

;
; DISCONNECT ROUTINE
;
DISCON:	lxi     h,38500         ;250 ms(?)
        mvi     a,comctl        ;Get address of selected port
        mov     c,a             ;Into C
        mvi     a,NODTR
;       OUT     C,A             ;Want to send to port addressed by C
        db      0EDH,079H       ;Op code for above instruction
DISCON1:dcx     h               ;timing loop...
        mov     a,l
        ora     h
        jnz     DISCON1          ;...until over
        mvi     a,comctl        ;Get the address for the port
        mov     c,a             ;Into C
        mvi     a,txe+dtr+rxe+rerr+rts  ;enable tr/rc, dtr, reset error
;       out     c,a             ;Z-80 only instruction
        db      0EDH,079H       ;Op code for above instruction
        out     contst          ;reset ports
	RET		
;
;
;
GOODBY:	RET 
;
;
SYSVER: PUSH    B
        PUSH    D
        PUSH    H
        LXI     D,DECMSG
        MVI     C,PRINT
        CALL    MEX
SYSVE1: LXI     D,CRLF
        MVI     C,PRINT
        CALL    MEX
        POP     H
        POP     D
        POP     B
        RET
;
;       Miscellaneous storage
;
SAVEIO: DB      0               ; Save the original IObyte here
;
;       Various text messages
CLSMSG: DB      ESC,'[2J',ESC,'[H','$'
EOSMSG: DB      ESC,'[0J','$'
;
XSO     EQU     14                      ;"shift out" character
XSI     EQU     15                      ;"shift in" character
;
DECMSG: DB      'Version for: ',ESC,'[7m',ESC,')0'
        DB      'd',XSO,'x',XSI
        DB      'i',XSO,'x',XSI
        DB      'g',XSO,'x',XSI
        DB      'i',XSO,'x',XSI
        DB      't',XSO,'x',XSI
        DB      'a',XSO,'x',XSI
        DB      'l',ESC,'[m '
	DB	'Robin--VT180'
	DB      '  Overlay V'
        DB      REV/10+'0'
        DB      '.'
        DB      REV MOD 10+'0'
        DB      '$'
;
CRLF:   DB      CR,LF,'$'
;
;
;
OVREND: EQU     $               ; See if it'll fit
        IF OVREND / 0B00H
        +++ VT180 OVERLAY TOO LARGE - OVREND >= 0B00H +++
        ENDIF
;
;
	END


