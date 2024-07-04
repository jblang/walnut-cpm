;MXO-VT10.ASM - Overlay file for MEXxx
;
REV     EQU     11      ;V 1.0	
;
;This  overlay file supports the DEC Micro VT180 running  CP/M  or 
;Bernie Eiben's implementation of ZCPR2.
;
;We use the COMM Port of the VT180.   Baud rates are set from the 
;VT100 keyboard and stored in the VT100's nonvolatile RAM.   There 
;is  no  need for  a  "special"  baud-rate routine.    Since   the 
;COMM port is referred to RDR:  and PUN:,  we use MEX calls (which 
;in turn calls the BDOS).
;
;To test for COMM status, we use IObyte redirection in conjunction 
;with direct BIOS CONSTAT call.
;
;This  technique,  although  slower  than direct handling  of  the 
;hardware,  takes advantage of the BIOS routines already built in, 
;thereby making our code smaller.
;
;***********************************************************************
;
; 6-JUN-1985   Fixed problem with INDP routine that prevented
;	       SENDOUT from working (Ron Fowler)
;
;  5-Jun-1984   Adapted from M7VT-2.ASM by Bernie Eiben.  Removed 
;   Rev 1.0     the  Rainbow conditionals.   This  overlay  won't 
; Stuart Fuller work  on a Rainbow in file transfer mode  without 
;               some bit twiddling on the 8088 side.  Added tests 
;               for   running   under  ZCPR2  and   bit   twiddle 
;               accordingly.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:           EQU     07H             ;bell
CR:             EQU     0DH             ;carriage return
ESC:            EQU     1BH             ;escape
LF:             EQU     0AH             ;linefeed
;
TRUE:           EQU     0FFH
FALSE:          EQU     0
YES:            EQU     0FFH
NO:             EQU     0
;
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
;       Miscellanea for VT180
;
IOBYTE  EQU     3               ; for I/O redirection
BATIO   EQU     56H             ;
AALOAD  EQU     0EA39H          ; ZCPR2 Bios sub-version
CALOAD  EQU     AALOAD + 1      ; Safety check location
LODNUM  EQU     28              ; Current version - should be in AALOAD
CLDNUM  EQU     NOT LODNUM AND 0FFH     ; This should be in CALOAD
CRTCB   EQU     0EA3BH          ; CRT control block addr - flags are at +1
PTRCB   EQU     0EA59H          ; Likewise for PTR
QMRCVFL EQU     01H     ; Mask to allow me to send XON/XOFF
QMXOFFD EQU     02H     ; Mask indicating I sent an XOFF
QMXMTFL EQU     04H     ; Mask to allow other end to stop me
QMSUSP  EQU     08H     ; Mask indicating I got an XOFF
QMARROW EQU     10H     ; Mask for arrow xlate bit
QMBIT7  EQU     20H     ; Mask for "use only 7 bits"
QMCCFLS EQU     40H     ; Mask for "flush buffer if 2 ^C's seen"
QM1STCC EQU     80H     ; Mask for "first ^C seen"
;
BELL    EQU     7               ;bell
TAB     EQU     9
CR      EQU     13              ;carriage return
LF      EQU     10              ;linefeed
ESC     EQU     1BH             ;escape
YES     EQU     0FFH
NO      EQU     0
;
DAV     EQU     0FFH            ;bit(s) to test for ready
TBMT    EQU     0FFH            ;
;
        ORG     100H
;
; Change the clock speed to suit your system
;
        DS      3               ;(for  "JMP   START" instruction)

        DB      NO              ;yes=PMMI S-100 Modem                   103H
        DB      YES              ;yes=HAYES Smartmodem, no=non-PMMI      104H
        DB      'T'             ;T=touch, P=pulse (Smartmodem-only)     105H
CLOCK:  DB      40              ;clock speed in MHz x10, 25.5 MHz max.  106H
                                ;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: DB      5               ;0=110 1=300 2=450 3=600 4=710 5=1200   107H
                                ;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: DB      5               ;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
                                ;default time to send character in ter-
                                ;minal mode file transfer for slow BBS.
CRDLY:  DB      5               ;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
                                ;default time for extra wait after CRLF
                                ;in terminal mode file transfer
COLUMS: DB      5               ;number of DIR columns shown            10AH
SETFLG: DB      NO              ;yes=user-added Setup routine           10BH
SCRTST: DB      YES             ;Cursor control routine                 10CH
        DB      YES             ;yes=resend a record after any non-ACK  10DH
                                ;no=resend a record after a valid-NAK
BAKFLG: DB      YES             ;yes=change any file same name to .BAK  10EH
CRCDFL: DB      YES             ;yes=default to CRC checking            10FH
TOGCRC: DB      YES             ;yes=allow toggling of CRC to Checksum  110H
CVTBS:  DB      NO              ;yes=convert backspace to rub           111H
TOGLBK: DB      YES             ;yes=allow toggling of bksp to rub      112H
ADDLF:  DB      NO              ;no=no LF after CR to send file in      113H
                                ;terminal mode (added by remote echo)
TOGLF:  DB      YES             ;yes=allow toggling of LF after CR      114H
        DB      YES             ;yes=allow transmission of logon        115H
                                ;write logon sequence at location LOGON
SAVCCP: DB      YES             ;yes=do not overwrite CCP               116H
        DB      NO              ;yes=local command if EXTCHR precedes   117H
                                ;no=external command if EXTCHR precedes
        DB      YES             ;yes=allow toggling of LOCONEXTCHR      118H
LSTTST: DB      YES             ;yes=printer available on printer port  119H
XOFTST: DB      NO              ;yes=checks for XOFF from remote while  11AH
                                ;sending a file in terminal mode
XONWT:  DB      NO              ;yes=wait for XON after CR while        11BH
                                ;sending a file in terminal mode
TOGXOF: DB      YES             ;yes=allow toggling of XOFF checking    11CH
IGNCTL: DB      NO              ;yes=CTL-chars above ^M not displayed   11DH
EXTRA1: DB      0               ;for future expansion                   11EH
EXITCHR DB      'E'-40H         ;^E = Exit to main menu                 11FH
BRKCHR: DB      '@'-40H         ;^@ = Send 300 ms. break tone           120H
NOCONN: DB      'N'-40H         ;^N = Disconnect from the phone line    121H
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
        DS      14              ;                                       156H
;
;
DIALV:  DS      3               ;DIALV not done here (maybe MXO-SM)     162H
DISCV:  DS      3               ;DISCV likewise
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
; This routine will wait until one becomes available.
;
INDP:	CALL	INSP
	ORA	A
	JZ	INDPNR		;if no char, go return last	
	PUSH    B               ;save...
        PUSH    D               ;...the...
        PUSH    H               ;...regesters.
        MVI     C,READER        ;use the BDOS function
        CALL    MEX             ;go
        POP     H               ;restore...
        POP     D               ;...the...
        POP     B               ;...registers.
	STA	LASTCH		;always save most recent char
        RET
INDPNR:	LDA	LASTCH		;return old char
	RET
;
; The Check for characters at COMM Port using I/O redirection
;
INSP:   PUSH    B
        PUSH    D
        PUSH    H               ; save the environment
        LDA     IOBYTE          ; Including the IOByte
        STA     SAVEIO          ;
        MVI     A,BATIO         ; change I/O byte
        STA     IOBYTE
        CALL    BCONST          ; call BIOS direct - see INITMOD
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
        RET
;
BCONST: JMP     $-$             ; address "filled in" by above code
;
SBREAK: RET
;
GOODBY: LDA     ZCPR2
        ORA     A
        RZ                      ; If running CP/M, then just return
        LDA     CRTSAV          ; Else, we gotta put things back again.
        STA     CRTCB+1
        LDA     PTRSAV
        STA     PTRCB+1
        RET
;
SETCMD: RET
;
SYSVER: PUSH    B
        PUSH    D
        PUSH    H
        LXI     D,DECMSG
        MVI     C,PRINT
        CALL    MEX
; Gotta do the check for ZCPR2 here, SYSVER gets called before INMODV
        MVI     A,NO            ; zero A
        STA     ZCPR2           ; assume CP/M
        LDA     AALOAD          ; get "load number" from BIOS
        CPI     LODNUM          ; and see if it's right
        JNZ     NOTZCP          ; nope, go
        LDA     CALOAD          ; next check its complement
        CPI     CLDNUM
        JNZ     NOTZCP
        MVI     A,YES           ; must be ZCPR2
        STA     ZCPR2
        LXI     H,CRTCB+1       ; get CRT's flag byte
        MOV     A,M
        STA     CRTSAV          ; save it
        ANI     0FFH XOR QMARROW        ; and zap the arrow xlate flag
        MOV     M,A
        LXI     H,PTRCB+1       ; do the same for the PTR
        MOV     A,M
        STA     PTRSAV
        MVI     M,QMRCVFL       ; keep only RCVFLOW bit
; Finished with check for ZCPR2
NOTZCP: LDA     ZCPR2
        ORA     A
        JZ      SYSVE1
        LXI     D,ZCPMSG
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
CRTSAV: DB      0               ; Save the CRT flags from ZCPR2's Bios
PTRSAV: DB      0               ; Likewise for the PTR flags
ZCPR2:  DB      0               ; Indicates running ZCPR2
;
;       Various text messages
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
        DB      'DEC VT180'
        DB      '  Overlay V'
        DB      REV/10+'0'
        DB      '.'
        DB      REV MOD 10+'0'
        DB      '$'
;
ZCPMSG: DB      ' running ZCPR2.','$'
CRLF:   DB      CR,LF,'$'
;
CLSMSG: DB      ESC,'[2J',ESC,'[H','$'
EOSMSG: DB      ESC,'[0J','$'
;
;
OVREND: EQU     $               ; See if it'll fit
        IF OVREND / 0B00H
        +++ VT180 OVERLAY TOO LARGE - OVREND >= 0B00H +++
        ENDIF
;
LASTCH:	DB	0
;
          END
;

                                                                                                                   