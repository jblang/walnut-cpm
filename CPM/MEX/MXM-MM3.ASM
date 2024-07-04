; MXM-MM3.ASM
;
REV     EQU     30              ;overlay revision level
;
; MEX Micromodem II/IIe overlay for the APPLE II/II+/IIe;
;       written 09/04/84 by Joe Patterson (70235,460)
;               adapted from
;
; MEX Apple Super Serial Card / Novation J-Cat overlay
;       written 05/18/84 by D. W. Walker
;       ALS bank-switching adapted from
;       an overlay by James M. Scardelis
;
; Revn: 1.0  04 Sept 84 -- Modified MXO-AP.21 to produce this
;                           overlay.
;       2.0  09 SEPT 84 -- ADDED TOUCH-TONE DIALING FOR THE
;                          MICROMODEM IIE (ONLY)
;                       -- RENAMED TO MXMM-2.ASM FROM MXO-MM10.ASM
;                       -- ADDED CONTROL PORT 3 JUMP FOR THE
;                          SOFTCARD (COULD NOT USE MMIIE ON 
;                          SOFTCARD OTHERWISE);
;       3.0  05 Nov  84 -- ADDED "SET ANSWER" COMMAND TO ENABLE
;                          MICROMODEM TO AUTO-ANSWER
;                       -- ADDED SUPPORT FOR THE PCPI APPLICARD
;
;
; This overlay is for the MEX--- series of modem programs. It is
;   adapted from MXO-AP.21 to work with the APPLE II and the
;   Hayes Micromodem II and IIe with either the ALS CP/M CARD
;   or the Microsoft Softcard. Data format is 8 bits, no parity,
;   1 stop bit. If you have the Micromodem IIe then answer YES
;   to --BOTH-- equates MM and MM2e to turn the speaker on when
;   dialing and off when connected. If you have the Micromodem II
;   then you must --NOT-- answer yes to the MM2e equate as the
;   program will probably bomb out if you do.
;
; Revision 2.0 now supports touch-tone dialing on the Micromodem
;   IIe (ONLY) if you answer YES to the MM2E equate. When using
;   touch-tone, the comma (,) feature is supported. Inserting a
;   comma in the number being dialed, causes a 2 second delay for
;   each one used. For example, 555-12,34 causes dialing to pause
;   for 2 seconds between digits 2 and 3. This is especially useful
;   when waiting for an outside line or a second dial tone. Multiple
;   commas can be used.
;
; Revision 3.0 now supports Auto-Answer with the Micromodem (II or IIe).
;  Using the SET ANSWER command, will put the Micromodem directly in
;  answer mode. At this point, the modem is waiting for the phone to
;  ring. When it does ring the modem will answer and listen for a 
;  carrier from the other end. If no carrier is detected within 15
;  seconds, the it will hang up and wait for another call. If a
;  carrier is detected, you will be put back in the MEX command
;  mode. To drop into terminal mode after the modem has detected a
;  carrier type SET ANSWER;T. The Auto-Answer mode is quite useful for
;  unattended operation. Using the READ command, you can put the modem
;  in Auto-Answer mode and when a connection is made the rest of the
;  commands in the READ file are executed.
;
; This revision (3.0) also supports the PCPI APPLICARD. All features
;  of the Micromodem are available.
;
; I have tested this overlay and it seems to work ok, but, if
;   anyone finds any let me know and I will try to correct them
;   as soon as possible.
;
;
; The SET WAIT command adjusts the time that the dialing
;   routines will wait for a connection (carrier), from
;   0 to 25 seconds.
; 
; NOTE: Most of the comments from Ron Fowler's MXO-PM10.ASM
;   have been omitted here to save space.  A copy of that file
;   will be very helpful in understanding what's going on here. 
;
;------------------------------------------------------------
;
; Misc equates
;
NO      EQU     0
YES     EQU     0FFH
TPA     EQU     100H
CR      EQU     13
LF      EQU     10
BELL    EQU     7
TAB     EQU     9
ESC     EQU     27
;         
MM      EQU     YES     ;YES FOR HAYES MICROMODEM II
MM2E    EQU     NO      ;YES FOR MM2E ONLY (FOR TOUCH-TONE & SPEAKER)
                        ;MUST BE NO IF YOU HAVE THE MICROMODEM II
SFTCRD  EQU     YES     ;YES for Microsoft Softcard } choose
ALSCRD  EQU     NO      ;YES for ALS CP/M+ card     } one only
APPCRD  EQU     NO      ;YES FOR PCPI APPLICARD     }
; 
        IF SFTCRD
POFF    EQU     2000H   ;Softcard address offset
RATE    EQU     20
        ENDIF
;
; IF YOU ARE USING THE APPLICARD BE SURE TO CHANGE THE RATE EQUATE
; TO REFLECT YOUR CARD'S SPEED. EX. 60=6MHZ, 40=4MHZ.
;
        IF ALSCRD OR APPCRD
POFF    EQU     0
RATE    EQU     60
        ENDIF
;
        IF      MM
SLOT    EQU     20H             ;SLOT FOR MICROMODEM X 10
PORT    EQU     0C086H+POFF+SLOT  ;BASE CTL/STAT PORT FOR MM
MODDAT  EQU     PORT+1          ;MM DATA PORT
MODSTT  EQU     PORT            ;MM STATUS PORT
MODCTL  EQU     PORT            ;MM CTL PORT 1
BAUDRP  EQU     PORT-1          ;MM CTL PORT 2
MODCTL3:EQU     PORT-3          ;MM2e CONTROL PORT 3
;
;
MDRCVB  EQU     01H     ;MM RECIEVE BIT
MDRCVR  EQU     01H     ;MM RECIEVE READY BIT
MDSNDB  EQU     02H     ;MM SEND BIT
MDSNDR  EQU     02H     ;MM SEND READY BIT
;
DTR     EQU     8FH             ;TRANS ENABLE, ORIG., 300 BAUD
OFFHK   EQU     80H             ;OFF-HOOK
ONHK    EQU     0               ;ON-HOOK
SPKRON  EQU     00100000B       ;MMIIe SPEAKER ON
SPKROFF EQU     00000000B       ;MMIIe SPEAKER OFF
;
CTSMSK  EQU     00000000B         ;MASK TO TEST FOR CARRIER
BRKMSK  EQU     60H               ;MASK TO SET BREAK
ONHOOK  EQU     0C085H+POFF+SLOT  ;ADDRESS FOR ONHOOK SET
OFFHOOK EQU     ONHOOK            ;OFFHOOK ADDRESS
        ENDIF   ;MM
;
;
;
; MEX service processor stuff ... See MXO-PM10.ASM
;
MEX     EQU     0D00H           ;address of the service processor
INMDM   EQU     255             ;get char from port to A, CY=no more in 100 ms
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
;
CONOUT  EQU     2               ;simulated BDOS function 2: console char out
PRINT   EQU     9               ;simulated BDOS function 9: print string
INBUF   EQU     10              ;input buffer, same structure as BDOS 10
;
        ORG     TPA             ;we begin
;
;
        DS      3               ;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM: DB      YES             ;yes=PMMI modem \ / These 2 locations are not
SMODEM: DB      NO              ;yes=Smartmodem / \ referenced by MEX
TPULSE: DB      'P'             ;T=touch, P=pulse (not referenced by MEX)
CLOCK:  DB      RATE            ;clock speed x .1, up to 25.5 mhz.
MSPEED: DB      1               ;sets display time for sending a file
                                ;0=110  1=300  2=450  3=600  4=710
                                ;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY: DB      5               ;default time to send character in
                                ;terminal mode file transfer (0-9)
                                ;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:  DB      3               ;end-of-line delay after CRLF in terminal
                                ;mode file transfer for slow BBS systems
                                ;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS: DB      5               ;number of directory columns
SETFL:  DB      YES             ;yes=user-defined SET command
SCRTST: DB      YES             ;yes=if home cursor and clear screen
                                ;routine at CLRSCRN
        DB      0               ;was once ACKNAK, now spare
BAKFLG: DB      NO              ;yes=make .BAK file
CRCDFL: DB      YES             ;yes=default to CRC checking
                                ;no=default to Checksum checking
TOGCRC: DB      YES             ;yes=allow toggling of Checksum to CRC
CVTBS:  DB      NO              ;yes=convert backspace to rub
TOGLBK: DB      YES             ;yes=allow toggling of bksp to rub
ADDLF:  DB      NO              ;no=no LF after CR to send file in
                                ;terminal mode (added by remote echo)
TOGLF:  DB      YES             ;yes=allow toggling of LF after CR
TRNLOG: DB      NO              ;yes=allow transmission of logon
                                ;write logon sequence at location LOGON
SAVCCP: DB      YES             ;yes=do not overwrite CCP
LOCNXT: DB      NO              ;yes=local cmd if EXTCHR precedes
                                ;no=not local cmd if EXTCHR precedes
TOGLOC: DB      YES             ;yes=allow toggling of LOCNXTCHR
LSTTST: DB      YES             ;yes=allow toggling of printer on/off
                                ;in terminal mode. Set to no if using
                                ;the printer port for the modem
XOFTST: DB      NO              ;yes=allow testing of XOFF from remote
                                ;while sending a file in terminal mode
XONWT:  DB      NO              ;yes=wait for XON after sending CR while
                                ;transmitting a file in terminal mode   
TOGXOF: DB      YES             ;yes=allow toggling of XOFF testing
IGNCTL: DB      YES             ;yes=do not send control characters
                                ;above CTL-M to CRT in terminal mode
                                ;no=send any incoming CTL-char to CRT
EXTRA1: DB      0               ;for future expansion
EXTRA2: DB      0               ;for future expansion
BRKCHR: DB      '@'-40H         ;^@ = Send a 300 ms. break tone
NOCONN: DB      'N'-40H         ;^N = Disconnect from phone line
LOGCHR: DB      'L'-40H         ;^L = Send logon
LSTCHR: DB      'P'-40H         ;^P = Toggle printer
UNSVCH: DB      'R'-40H         ;^R = Close input text buffer
TRNCHR: DB      'T'-40H         ;^T = Transmit file to remote
SAVCHR: DB      'Y'-40H         ;^Y = Open input text buffer
EXTCHR: DB      '^'-40H         ;^^ = Send next character
;
        DS      2
;
INCTL1: CALL    XSTTIN          ;in modem status port
        RET
        DB      0,0,0,0,0,0     ;spares if needed
;                   
OTDATA: CALL    XDATOUT         ;out modem data port
        RET
        DB      0,0,0,0,0,0     ;spares if needed
;
INPORT: CALL    XDATIN          ;in modem data port
        RET
        DB      0,0,0,0,0,0     ;spares if needed
;
MASKR:  ANI MDRCVB ! RET        ;bit to test for receive ready
TESTR:  CPI MDRCVR ! RET        ;value of receive bit when ready
MASKS:  ANI MDSNDB ! RET        ;bit to test for send ready
TESTS:  CPI MDSNDR ! RET        ;value of send bit when ready
;
;
        DS      12
;
;
LOGON:  DS      2               ;needed for MDM compat, not ref'd by MEX
DIALV:  JMP     PDIAL           ;dial digit in A (see info at PDIAL)
DISCV:  JMP     PDISC           ;disconnect the modem
GOODBV: JMP     DUMMY           ;called before exit to CP/M
INMODV: JMP     NITMOD          ;initialization. Called at cold-start
NEWBDV: JMP     PBAUD           ;set baud rate
NOPARV: DS      3               ;set modem for no-parity
PARITV: DS      3               ;set modem parity
SETUPV: JMP     SETCMD          ;SET cmd: jump to a RET if you don't write SET
SPMENV: DS      3               ;not used with MEX
VERSNV: JMP     SYSVER          ;Overlay's voice in the sign-on message
BREAKV: JMP     PBREAK          ;send a break
;
;
ILPRTV: DS      3               ;replace with MEX function 9
INBUFV: DS      3               ;replace with MEX function 10
ILCMPV: DS      3               ;replace with table lookup funct. 247
INMDMV: DS      3               ;replace with MEX function 255
NXSCRV: DS      3               ;not supported by MEX (returns w/no action)
TIMERV: DS      3               ;replace with MEX function 254
;
CLREOS: LXI     D,EOSMSG
        MVI     C,PRINT
        CALL    MEX
        RET
;
CLS:    LXI     D,CLSMSG
        MVI     C,PRINT
        CALL    MEX
        RET
;
;------------------------------------------------------------
;
;       *** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
; MICROMODEM AND ALS CARD INITIALIZATION
;
NITMOD: 
        IF ALSCRD
        LHLD    1               ;get WBOOT vector
        LXI     D,60H           ;offset for 32 entries
        DAD     D               ;BIOS "read Apple address"
        SHLD    AR0+1           ;patch read vector
        INX     H
        INX     H
        INX     H               ;BIOS "write Apple address"
        SHLD    AW0+1           ;patch write vector
        ENDIF
 
;
        IF      MM
        MVI     A,03H
        CALL    XCTLOUT         ;RESET MICROMODEM
        MVI     A,15H           ;8 DATA BITS 1 STOP NO PARITY
        CALL    XCTLOUT
        RET
        ENDIF   ;MM
;
; Micromodem send-break routine
;
PBREAK: CALL    XCTLIN          ;get control register
        PUSH    PSW             ;save it
        ORI     BRKMSK          ;set break bits
        CALL    XCTLOUT         ;break line
        PUSH    B
        LXI     B,233           ;wait 233 msec
        CALL    DELAY
        POP     B
        POP     PSW
        CALL    XCTLOUT         ;restore control register 
        RET
;
; disconnect the Micromodem (and turn off MMIIe speaker)
;
PDISC:  PUSH    B
;
        IF      MM2E
        MVI     A,SPKROFF
        CALL    XCTL3           ;SPEAKER OFF
        ENDIF                   ;MM2E
;
        MVI     A,ONHK
        CALL    XONHOOK         ;hang up
        LXI     B,25            ;for 25 msec
        CALL    DELAY
        MVI     A,OFFHK
        CALL    XOFFHK          ;pick up again
        LXI     B,20            ;for 20 msec
        CALL    DELAY
        MVI     A,ONHK
        CALL    XONHOOK         ;hang up for good
        POP     B
        RET
;
; wait for BC milliseconds
;
DELAY:  PUSH    D
        INR     B
DELAY1: LXI     D,3*RATE        ;count for 1 msec
DELAY2: DCX     D               ;..may need some tweaking
        MOV     A,E
        ORA     D
        JNZ     DELAY2          ;delay 1 msec
        DCR     C
        JNZ     DELAY1          ;delay another
        DCR     B
        JNZ     DELAY1
        POP     D               ;done, restore DE
        RET
;
; exit routine
;
DUMMY:  RET                     ;we don't need one
;
;
;------------------------------------------------------------
;
;   MICROMODEM DIALING ROUTINES (PULSE AND TOUCH-TONE)
;
;------------------------------------------------------------
;
PDIAL:  CPI     254             ;start-dial?
        JZ      STDIAL
        CPI     255             ;end-dial
        JZ      ENDIAL
;
        CPI     ','             ;SEE IF DIGIT IS ','
        JZ      DIALCM          ;YES
        CPI     '9'+1           ;digits are 0-9
        RNC                     ;too big...
        SUI     '0'
        RC                      ;too small....
        JNZ     DIALIT          ;just right...
        MVI     A,10            ;convert zero to 10 pulses
;
; Pulse phone "digit" times
;
        IF      NOT MM2E
DIALIT: MOV     E,A             ;save the digit
        PUSH    B
DIGLP:  MVI     A,ONHK
        CALL    XONHOOK
        LXI     B,65            ;for 65 msec
        CALL    DELAY
        MVI     A,OFFHK
        CALL    XOFFHK          ;connect line
        LXI     B,42            ;for 42 msec
        CALL    DELAY
        DCR     E               ;pulse again?
        JNZ     DIGLP           ;yes, do it
        MVI     B,3             ;300 MSEC BETWEEN DIGITS
        MVI     C,TIMER
        CALL    MEX
        POP     B               ;no, exit
        RET
        ENDIF                   ;MM
;
;
        IF      MM2E
DIALIT: ADI     30H             ;ADD 30H TO DIGIT TO KEEP SPEAKER -
        PUSH    B               ;ON AND SEND TONE
DIGLP:  CALL    XCTL3           ;SEND DIGIT
        LXI     B,120           ;NUMBER OF MSEC FOR EACH TONE
        CALL    DELAY
        MVI     A,20H           ;TURN OFF TONE
        CALL    XCTL3
        MVI     B,1             ;100 MSEC BTWEEN DIGITS
        MVI     C,TIMER
        CALL    MEX
        POP     B
        RET
        ENDIF                   ;ENDIF MM2E
;
;
; THIS ROUTINE CONVERTS THE COMMA (,) TO IT'S MICROMODEM DECIMAL
;   EQUIVALENT. THE COMMA CAUSES A TWO (2) SECOND DELAY IN
;   DIALING BETWEEN ANY 2 DIGITS.
;
;
DIALCM: MVI     B,20            ;DIGIT IS COMMA - SO WAIT 2 SEC.
        MVI     C,TIMER
        CALL    MEX
        RET
;
;
; END OF SPECIAL DIALING CONVERSION ROUTINE
;
;
; Start-dial sequence: connect, wait for dial-tone
;
STDIAL: CALL    ILPRT
        DB      'Wait...',0
        MVI     B,25            ;wait 2.5 sec
        MVI     C,TIMER
        CALL    MEX
        MVI     A,DTR           ;enable modem
        CALL    XBDOUT
        ;
        IF      MM2E
        MVI     A,SPKRON
        CALL    XCTL3           ;TURN ON MMIIE SPEAKER
        ENDIF                   ;MM2E
        ;
        MVI     A,OFFHK
        CALL    XOFFHK          ;connect phone
        MVI     B,20            ;wait 2 sec
        MVI     C,TIMER
        CALL    MEX             ;for dial tone
        ORA     A
        RET
;
; End-dial sequence
;
ENDIAL: MVI     E,150           ;SET WAIT TIME TO 15 SEC.
        MVI     A,8DH           ;ENABLE MODEM (OFF-HOOK,ORIG.,300 BD)
        CALL    XBDOUT
WAITTM  EQU     $-1             ;patch with SET WAIT command
        CALL    WAIT
        ORA     A               ;successfully connected?
        PUSH    PSW             ;save the error code
        JNZ     NOTCNK          ;no, disconnect
        MVI     A,DTR
        CALL    XBDOUT          ;RE-ENABLE MODEM
        ;
        IF      MM2E
        MVI     A,SPKROFF       ;MMIIE SPEAKER OFF
        CALL    XCTL3
        ENDIF                   ;MM2E
        ;
        JMP     DIALXIT 
NOTCNK: CALL    PDISC           ;shut down the modem
DIALXIT:POP     PSW
        RET
;
; Time-out routine.  Must be called with mask in D reg.
; and number of seconds (times 10) in E reg.
;
WAIT:   MVI     B,1             ;100 ms
        MVI     C,TIMER 
        CALL    MEX
        CALL    XDATIN          ;READ DATA PORT (SET-UP CARR. DET.)
        CALL    XSTTIN          ;IS CARRIER LOST SINCE LAST DATA READ?
        ANI     4               ;4=NO CARRIER, 0=CARRIER
        RZ                      ;active low, so return on 0
        MVI     C,CHEKCC        ;not yet, check for console-abort
        CALL    MEX             ;abort?
        MVI     A,3             ;set error code 3 if abort active
        STC
        RZ                      ;return if aborted
        DCR     E               ;nope, downcount
        JNZ     WAIT
        DCR     A               ;set error=2 (timed out); cy already set
        RET
 
;------------------------------------------------------------
;       END OF MICROMODEM DIALING ROUTINES
;------------------------------------------------------------
;
; Only 300 baud is supported for the Micromodem
;
;
        IF      MM
PBAUD:  RET
        ENDIF   ;MM
;
;
; Control is passed here after MEX parses a SET command.
;
SETCMD: MVI     C,SBLANK        ;any arguments?
        CALL    MEX
        JC      SETSHO          ;if not, go print out values
        LXI     D,CMDTBL        ;parse command
        CALL    TSRCH           ;from table
        PUSH    H               ;any address on stack
        RNC                     ;if we have one, execute it
        POP     H               ;nope, fix stack
SETERR: LXI     D,SETEMS        ;print error
        MVI     C,PRINT
        CALL    MEX
        RET
;
SETEMS: DB      CR,LF,BELL,'SET command error',CR,LF,'$'
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
CMDTBL: DB      '?'+80H                 ;"set ?"
        DW      STHELP
        DB      'BAU','D'+80H           ;"set baud"
        DW      STBAUD
        DB      'WAI','T'+80H           ;"set wait time"
        DW      STWAIT
        DB      'ANSWE','R'+80H         ;"set answer"
        DW      ANSWER
        DB      0               ;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO: CALL    CARRSH          ;show carrier present/not present
        LXI     H,SHOTBL        ;get table of SHOW subroutines
SETSLP: MOV     E,M             ;get table address
        INX     H
        MOV     D,M
        INX     H
        MOV     A,D             ;end of table?
        ORA     E
        RZ                      ;exit if so
        PUSH    H               ;save table pointer
        XCHG                    ;adrs to HL
        CALL    GOHL            ;do it
        CALL    CRLF            ;print newline
        MVI     C,CHEKCC        ;check for console abort
        CALL    MEX
        POP     H               ;it's done
        JNZ     SETSLP          ;continue if no abort
        RET
;
GOHL:   PCHL
;
; table of SHOW subroutines
;
SHOTBL: DW      BDSHOW
        DW      WTSHOW
        DW      0               ;<<== table terminator
;
; SET ?  processor
;
STHELP: LXI     D,HLPMSG
        MVI     C,PRINT
        CALL    MEX
        RET
;
; The help message
;
HLPMSG: DB      CR,LF,'SET command, MICROMODEM II/IIE version:',CR,LF
        DB      CR,LF,TAB,'Set Answer - <use CTL-C to abort>'
        DB      CR,LF,TAB,'Only 300 baud supported'
        DB      CR,LF,TAB,'Set Wait 0..25 seconds'
        DB      CR,LF,'$'
;
; SET BAUD processor
;
STBAUD: MVI     C,BDPARS        ;function code
        CALL    MEX             ;let MEX look up code
        JC      SETERR          ;invalid code
        CALL    PBAUD           ;no, try to set it
        JC      SETERR          ;not-supported code
BDSHOW: CALL    ILPRT           ;display baud
        DB      'Baud rate: ',TAB,0
        LDA     MSPEED
        MVI     C,PRBAUD        ;use MEX routine
        CALL    MEX
        RET           
;
; SET ANSWER processor
;
ANSWER: CALL    ILPRT
        DB      CR,LF,'Micromodem awaiting call........',0
ANSWER1:MVI     A,09H           ;get ready to answer phone
        CALL    XBDOUT
ANSWER2:MVI     C,CHEKCC        ;check for console abort
        CALL    MEX
        RZ                      ;return if aborted
        CALL    XBDIN           ;see if phone is ringing
        ANI     80H
        JNZ     ANSWER2         ;it isn't so, continue to listen
        CALL    ILPRT           ;print "modem answering"
        DB      BELL,CR,LF,'Micromodem answering.......',0
        MVI     A,8BH           ;go off-hook and send answer tone
        CALL    XBDOUT
        MVI     E,150           ;wait 15s for carrier on other end
PICKUP: MVI     B,1             ;100ms
        MVI     C,TIMER
        CALL    MEX
        CALL    XDATIN          ;dummy data read
        CALL    XSTTIN          ;is there a tone on the other end ?
        ANI     4
        JZ      CDET            ;jump to "cdet" if carrier detected
        MVI     C,CHEKCC        ;check for console abort
        CALL    MEX
        RZ                      ;if abort
        DCR     E               ;nope, countdown
        JNZ     PICKUP
        CALL    ILPRT           ;print "no carrier"
        DB      CR,LF,'No carrier - waiting for another call.....',0
        JMP     ANSWER1         ;continue waiting for a call
CDET:   CALL    ILPRT
        DB      BELL,CR,LF,'Carrier detected......',0
        RET
;
;
; SET WAIT processor
;
STWAIT: MVI     C,EVALA         ;get new time from input
        CALL    MEX
        MOV     A,H             ;check for valid input
        ORA     A
        JNZ     SETERR
        MOV     A,L
        CPI     26
        JNC     SETERR          ;25 is maximum wait
        RLC                     ;x 2
        MOV     C,A
        RLC                     ;x 4
        RLC                     ;x 8
        ADD     C               ;x 10
        STA     WAITTM
WTSHOW: CALL    ILPRT
        DB      'Wait time: ',TAB,0
        MVI     A,0             ;clear HL
        MOV     L,A
        MOV     H,A
        LDA     WAITTM
SBLOOP: SUI     10              ;div. by 10
        JC      WTDSP
        INR     L
        JMP     SBLOOP
WTDSP:  MVI     C,DECOUT
        CALL    MEX
        CALL    ILPRT
        DB      ' seconds',CR,LF,0
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:  MVI     C,LOOKUP        ;get function code
        JMP     MEX             ;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:  MVI     C,ILP           ;get function code
        JMP     MEX             ;go do it

;
; Sign-on message
;
SYSVER: CALL    NITMOD
        LXI     D,SOMESG
        MVI     C,PRINT
        CALL    MEX
CARRSH: LXI     D,NOMESG                ;tell about carrier
        CALL    CARRCK                  ;check for it
        MVI     C,PRINT
        CNZ     MEX                     ;print the "NO" if no carrier
        LXI     D,CARMSG                ;print "carrier present"
        MVI     C,PRINT
        CALL    MEX
        RET
;
;
        IF      SFTCRD
SOMESG: DB      'Apple II w/Microsoft Softcard',CR,LF
        ENDIF   ;SFTCRD
;
;
        IF      ALSCRD
SOMESG: DB      'Apple II w/ALS CP/M 3.0 Card',CR,LF
        ENDIF   ;ALSCRD
;
        IF      APPCRD
SOMESG: DB      'Apple II w/PCPI Applicard',CR,LF
        ENDIF   ;APPCRD
;
        IF      MM2E
        DB      'and Hayes Micromodem IIe',CR,LF,'$'
        ENDIF   ;MM2E
;
        IF NOT  MM2E
        DB      'and Hayes Micromodem II',CR,LF,'$'
        ENDIF   ;NOT MM2E
NOMESG: DB      'no $'
CARMSG: DB      'carrier present',CR,LF,'$'
;
; CHECK THE MICROMODEM FOR CARRIER PRESENT (NZ=NO)
;
CARRCK: CALL    XDATIN
        CALL    XSTTIN
        ANI     4
        RET
;
; Newline on console
;
CRLF:   MVI     A,CR
        CALL    TYPE
        MVI     A,LF            ;fall into TYPE
;
; type char in A on console
;
TYPE:   PUSH    H               ;save 'em
        PUSH    D
        PUSH    B
        MOV     E,A             ;align output character
        MVI     C,CONOUT        ;print via MEX
        CALL    MEX
        POP     B
        POP     D
        POP     H
        RET                        
;
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG: DB      ESC,'Y$'        ;clear to end-of-screen
CLSMSG: DB      ESC,'*$'        ;clear whole screen

;-------------------------------------------------------
; Apple I/O 
;-------------------------------------------------------

        IF      SFTCRD

XDATOUT STA     MODDAT ! RET
XCTLOUT STA     MODCTL ! RET
XBDOUT  STA     BAUDRP ! RET
XONHOOK STA     ONHOOK ! RET
XOFFHK  STA     OFFHOOK ! RET
XCTL3   STA     MODCTL3 ! RET

XSTTIN  LDA     MODSTT ! RET
XDATIN  LDA     MODDAT ! RET
XCTLIN  LDA     MODCTL ! RET
XBDIN   LDA     BAUDRP ! RET

        ENDIF   

        IF ALSCRD
;
; ALS card routines require assembly with MAC
; (supplied with the ALS CP/M card)
; 
PUT     MACRO   ADDR
        PUSH    H
        LXI     H,ADDR
        JMP     APWRT
        ENDM
           
XDATOUT PUT     MODDAT
XCTLOUT PUT     MODCTL
XBDOUT  PUT     BAUDRP
XONHOOK PUT     ONHOOK
XOFFHK  PUT     OFFHOOK
XCTL3   PUT     MODCTL3

APWRT:  PUSH    D
        PUSH    B
AW0:    CALL    $-$     ; patch vector here
        POP     B
        POP     D
        POP     H
        RET

GET     MACRO   ADDR
        PUSH    H
        LXI     H,ADDR
        JMP     APRD
        ENDM

XSTTIN  GET     MODSTT
XDATIN  GET     MODDAT
XCTLIN  GET     MODCTL
XBDIN   GET     BAUDRP

APRD:   PUSH    D
        PUSH    B
AR0:    CALL    $-$     ; patch vector here
        POP     B
        POP     D
        POP     H
        RET

        ENDIF
;
; PCPI Applicard I/O routines
;
        IF      APPCRD
;
RDBYTE: EQU     0FFE0H          ;read 1 byte from apple (A=byte)
WRBYTE: EQU     0FFE3H          ;write 1 byte to apple (C=byte)
RDWORD: EQU     0FFE6H          ;read 2 bytes from apple (DE=word)
WRWORD: EQU     0FFE9H          ;write 2 bytes to apple (DE=word)
PEEK:   EQU     6               ;command
POKE:   EQU     7               ;command
;
XDATOUT:PUSH    D
        LXI     D,MODDAT
        JMP     APWRT
;
XCTLOUT:PUSH    D
        LXI     D,MODCTL
        JMP     APWRT
;
XBDOUT: PUSH    D
        LXI     D,BAUDRP
        JMP     APWRT
;
XONHOOK:PUSH    D
        LXI     D,ONHOOK
        JMP     APWRT
;
XOFFHK: PUSH    D
        LXI     D,OFFHOOK
        JMP     APWRT
;
XCTL3:  PUSH    D
        LXI     D,MODCTL3
;
APWRT:  PUSH    B
        MOV     B,A
        MVI     C,POKE
        CALL    WRBYTE
        CALL    WRWORD
        MOV     C,B
        CALL    WRBYTE
        POP     B
        POP     D
        RET
;
XSTTIN: PUSH    D
        LXI     D,MODSTT
        JMP     APRD
;
XDATIN: PUSH    D
        LXI     D,MODDAT
        JMP     APRD
;
XCTLIN: PUSH    D
        LXI     D,MODCTL
        JMP     APRD
;
XBDIN:  PUSH    D
        LXI     D,BAUDRP
;
APRD:   PUSH    B
        MVI     C,PEEK
        CALL    WRBYTE
        CALL    WRWORD
        CALL    RDBYTE
        POP     B
        POP     D
        RET
;
        ENDIF                   ;Applicard
;
;------------------------------------------------------------
;
        END
