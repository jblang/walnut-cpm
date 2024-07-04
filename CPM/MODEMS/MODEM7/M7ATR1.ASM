; M7ATR1.ASM -- ATR8000 overlay file for MDM7xx. 08/29/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the ATR8000 computers to MDM7xx.
;
; Much of the information contained here is not in the MDM7xx.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
;
;       TO USE: First edit this file filling in answers for your own
;               equipment.  Then assemble with MAC.COM or equivalent
;               assembler.  Then use DDT to overlay the the results
;               of this program to the original .COM file:
;
;               A>DDT MDM740.COM
;               DDT VERS 2.2
;               NEXT  PC
;               4A00 0100
;               -IM7ATR1.HEX            (note the "I" command)
;               -R                      ("R" loads in the .HEX file)
;               NEXT  PC
;               4A00 0000
;               -G0                     (return to CP/M)
;               A>SAVE 73 MDM7xx.COM    (now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
                MACLIB  Z80
BELL:           EQU     07H             ;bell
CR:             EQU     0DH             ;carriage return
ESC:            EQU     1BH             ;escape
LF:             EQU     0AH             ;linefeed
;
YES:            EQU     0FFH
NO:             EQU     0
;
;
PORT:           EQU     00H             ;This beast no serial ports
MODCTL1:        EQU     PORT            ;Modem control port
MODDATP:        EQU     PORT            ;Modem data port
MODCTL2:        EQU     PORT            ;Modem status port
MODRCVB:        EQU     01H             ;These bits are emulated by
MODRCVR:        EQU     01H             ; some really hoky code
MODSNDB:        EQU     02H             ;
MODSNDR:        EQU     02H             ;
;
                ORG     100H
;
;
; Change the clock speed to suit your system
;
                DS      3       ;(for  "JMP   START" instruction)
;
PMMIMODEM:      DB      NO      ;yes=PMMI S-100 Modem                   103H
SMARTMODEM:     DB      NO      ;yes=HAYES Smartmodem, no=non-PMMI      104H
TOUCHPULSE:     DB      'P'     ;T=touch, P=pulse (Smartmodem-only)     105H
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
SCRNTEST:       DB      YES     ;Cursor control routine                 10CH
ACKNAK:         DB      YES     ;yes=resend a record after any non-ACK  10DH
                                ;no=resend a record after a valid NAK
BAKUPBYTE:      DB      NO      ;yes=change any file same name to .BAK  10EH
CRCDFLT:        DB      YES     ;yes=default to CRC checking            10FH
TOGGLECRC:      DB      YES     ;yes=allow toggling of CRC to Checksum  110H
CONVBKSP:       DB      NO      ;yes=convert backspace to rub           111H
TOGGLEBK:       DB      YES     ;yes=allow toggling of bksp to rub      112H
ADDLF:          DB      NO      ;no=no LF after CR to send file in      113H
                                ;terminal mode (added by remote echo)
TOGGLELF:       DB      YES     ;yes=allow toggling of LF after CR      114H
TRANLOGON:      DB      NO      ;yes=allow transmission of logon        115H
                                ;write logon sequence at location LOGON
SAVCCP:         DB      NO      ;yes=do not overwrite CCP               116H
; SAVCCP must be NO. If it is YES, MDM7xx returns via a RET
; This causes me mucho grief since I modify the BIOS. If I do not
; restore the BIOS, all you know what breaks loose. JAM
LOCONEXTCHR:    DB      NO      ;yes=local command if EXTCHR precedes   117H
                                ;no=external command if EXTCHR precedes
TOGGLELOC:      DB      YES     ;yes=allow toggling of LOCONEXTCHR      118H
LSTTST:         DB      YES     ;yes=printer available on printer port  119H
XOFFTST:        DB      NO      ;yes=check for XOFF from remote while   11AH
                                ;sending a file in terminal mode
XONWAIT:        DB      NO      ;yes=wait for XON after CR while        11BH
                                ;sending a file in terminal mode
TOGXOFF:        DB      YES     ;yes=allow toggling of XOFF checking    11CH
IGNORCTL:       DB      NO      ;yes=CTL-chars above M not displayed    11DH
; I set IGNORCTL to NO since I use this program with an ascii to 3270
; SNA protocol converter which uses control characters to position
; the cursor on my screen.
EXTRA1:         DB      0       ;for future expansion                   11EH
EXTRA2:         DB      0       ;for future expansion                   11FH
BRKCHR:         DB      '@'-40H ;@ = Send a 300 ms. break tone          120H
NOCONNCT:       DB      'N'-40H ;N = Disconnect from the phone line     121H
LOGCHR:         DB      'L'-40H ;L = Send logon                         122H
LSTCHR:         DB      'P'-40H ;P = Toggle printer                     123H
UNSAVE:         DB      'R'-40H ;R = Close input text buffer            124H
TRANCHR:        DB      'T'-40H ;T = Transmit file to remote            125H
SAVECHR:        DB      'Y'-40H ;Y = Open input text buffer             126H
EXTCHR:         DB      '^'-40H ;^ = Send next character                127H
;
;
                DS      2               ;                               128H
IN$MODCTL1:     JMP     MSTAT           ;CHANNEL 0, RESET INTERRUPTS    12AH
                DS      7
;
OUT$MODDATP:    JMP     OTDATP          ;out modem data port 134H
                DS      7
IN$MODDATP:     JMP     INDATP          ;in modem data port             13EH
                DS      7
ANI$MODRCVB:    ANI     MODRCVB ! RET   ;bit to test for receive ready  148H
CPI$MODRCVR:    CPI     MODRCVR ! RET   ;value of receive bit when rdy  14BH
ANI$MODSNDB:    ANI     MODSNDB ! RET   ;bit to test for send ready     14EH
CPI$MODSNDR:    CPI     MODSNDR ! RET   ;value of send bit when ready   151H
                DS      6               ;                               154H
OUT$MODCTL1:    RET ! NOP ! NOP         ;out modem control port         15AH
OUT$MODCTL2:    RET ! NOP ! NOP         ;out modem status port          15DH
;
;
LOGONPTR:       DW      LOGON           ;for user message.              160H
                DS      6               ;                               162H
JMP$GOODBYE:    JMP     GOODBYE         ;                               168H
JMP$INITMOD:    JMP     IOINIT          ;go to user written routine     16BH
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       16EH
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       171H
                RET  !  NOP  !  NOP     ;(by-passes PMMI routine)       174H
JMP$SETUPR:     JMP     SETCMD          ;                               177H
JMP$SPCLMENU:   JMP     SPCLMENU        ;                               17AH
JMP$SYSVER:     JMP     SYSVER          ;                               17DH
JMP$BREAK:      JMP     SENDBRK         ;                               180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:      DS      3               ;                               183H
JMP$INBUF       DS      3               ;                               186H
JMP$INLNCOMP:   DS      3               ;                               189H
JMP$INMODEM     DS      3               ;                               18CH
JMP$NXTSCRN:    DS      3               ;                               18FH
JMP$TIMER:      DS      3               ;                               192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:         CALL    JMP$ILPRT       ;                               195H
                DB      1BH,59H,0,0,0   ; 198H
                RET                     ;                               19DH
;
CLRSCRN:        CALL    JMP$ILPRT       ;                               19EH
                DB      1AH,0,0,0,0     ;                               1A1H
                RET                     ;                               1A6H
;
;
SYSVER:         CALL    JMP$ILPRT       ;                               1A7H
                DB      'ATR8000 Version (Tested with TVI914D)',CR,LF
                DB      CR,LF,0
                RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;        end of your last routine should terminate by 0400H (601 bytes
;        available after start of SYSVER) if using the Hayes Smartmodem
;        or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:          DB      'This is an ATR8000 by SWP, Inc',CR,LF,0
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:  MVI   A,0
          OUT   SEROUT         ;SET SERIAL LATCH TO 0
          JMP   GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI   A,0
          OUT   SEROUT          ;SET SERIAL LATCH TO 0
GOODBYE1: MVI   B,3             ;WAIT FOR 300 MS.
          CALL  JMP$TIMER
          MVI   A,1             ; TURN ON IDLE
          OUT   SEROUT
          RET
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
;      ... OUTPUT CHARACTER TO MODEM FROM ACC ...
;
OTDATP  EQU     $
       JMP     OTDAT2
OTDAT2:PUSH    PSW
       PUSH    H
       LXI     H,OTDAT3
       SHLD    OTDATP+1         ;PATCH JUMP AT ENTRY TO THIS ROUTINE
       LXI     H,0
       SHLD    CPSNDR         ;PATCH XOR/RET AT START OF READY ROUTINE
       IN      TRKREG
       OUT     DATREG
       MVI     A,00010000B
       OUT     CMDREG         ;DUMMY SEEK TO MAKE 179X UNLOAD HEADS
       XRA     A
       OUT     LATCH           ;THEN TURN OFF ALL DRIVE CTL BITS
       POP     H
       POP     PSW
OTDAT3:PUSH    PSW
       PUSH    H
;jam   CALL    PCHECK          ;SET PARITY BIT AS SPECIFIED BY INIT
       STA     TXDATA
       DI
       LDA     DMODE
       OUT     CTC3
       LDA     DBAUD
       OUT     CTC3
       LXI     H,TXSTART
       SHLD    CTCVEC+6
       EI
       POP     H
       POP     PSW
       RET
;
;
;
CPSNDR:
       XRA     A               ;INDICATE ALWAYS READY TO SEND
       RET                     ;UNTIL OVERLAYED BY 2 NOPS LATER
       LDA     CTCVEC+6
       SUI     LOW TXWAIT
       RET                     ;ACC=0 IF MODEM TX NOT BUSY
;
;
;
;      ... INPUT CHARACTER FROM MODEM TO ACC ...
;
INDATP:
       PUSH    H
       LXI     H,FETCH
       LDA     STASH
       SUB     M
       JRZ     INDAT2        ;EXIT IF TRYING TO READ EMPTY FIFO
       MOV     A,M          ;LOAD A WITH FIFO OUTPUT POINTER
       INR     M            ;THEN BUMP POINTER MODULO 256
       LXI     H,FIFO
       MOV     L,A
       MOV     A,M          ;THEN LOAD ACC WITH CHARACTER
       LXI     H,PARAMS
;      BIT     1,M          ;TEST IF PARITY IS ENABLED
;      JRZ     INDAT2
;      RES     7,A             ;STRIP PARITY IF NEEDED
INDAT2:POP     H
       RET
;
;
;
CPRCVR:
       PUSH    H
       LXI     H,FETCH
       LDA     STASH
       SUB     M
       POP     H
       JRZ     CPRCV1
       XRA     A               ;ACC=0 IF CHARACTER AVAILABLE
       RET
;
CPRCV1:DCR     A
       RET                     ;ACC=255 IF NO CHARACTER
;
;
;
FLUSH:
       DI
       XRA     A
       STA     STASH
       STA     FETCH
       EI
       RET
;
;
;
;
PCHECK:
       LXI     H,PARAMS       ;PREPARE TO DERRIVE PARITY BIT FOR TX
       BIT     1,M
       RZ                      ;EXIT WITH A UNCHANGED IF PARITY OFF
       ANI     01111111B       ;ELSE CLEAR BIT 7 AND DETERMINE PARITY
       JPO     PCHK2
       SETB     7,A             ;MAKE BIT RIGHT FOR ODD PARITY
PCHK2: BIT     0,M
       RNZ                     ;EXIT IF ODD PARITY IS SELECTED
       XRI     10000000B       ;ELSE FILP BIT FOR EVEN PARITY
       RET
;
;
;
;
;
;      COLD START INITIALIZATION FOR MODEM7
;
IOINIT:
       LBCD    PARAMS
       CALL    COMMINIT
;
;      PATCH MONITOR DISKIO ENTRY POINT FOR SERIAL I/O REININT
;
       LHLD    MONITOR+15+1
       SHLD    DSKJMP+1
       LXI     H,DISKIO
       SHLD    MONITOR+15+1
;
;      PATCH CP/M WARMSTART VECTOR TO UNDO DISKIO PATCH
;
       LHLD    0001H
       INX     H
       MOV     E,M
       MVI     M,LOW GOBACK
       INX     H
       MOV     D,M
       MVI     M,HIGH GOBACK
       SDED    WARM            ;STORE FOR EVENTUAL EXIT FROM MODEM7
       RET
;
;
PARAMS:  DB    10100000B
       DB    52
;
;
;
COMMINIT:
       MOV     A,C
       ANI     00100000B       ;USE BIT 5 OF C AS CTC PRESCALE BIT
       ORI     10000111B
       STA     DMODE           ;STORE DATA BIT CONTROL BYTE
       ORI     00001000B
       STA     SMODE           ;STORE START BIT CONTROL BYTE
       DI
       OUT     CTC2            ;RESET CTC2 AND PROGRAM FOR MODE
       MOV     A,B             ;BAUDRATE MODULUS IS PASSED IN B
       STA     DBAUD           ;STORE NUMBER AS DATA BIT TIME CONST
       SRLR A
       STA     SBAUD           ;STORE 1/2 OF THAT FOR START BIT DELAY
       OUT     CTC2
       LXI     H,SBIT         ;VECTOR TO 'SBIT' TO INIT RECEIVE IRQ
       SHLD    CTCVEC+4
       LXI     H,CTCVEC+4
       LXI     D,STASH
       EXX                     ;SET POINTERS IN ALTERNATE HL AND DE
       XRA     A
       STA     STASH
       STA     FETCH           ;RESET FIFO ENTRY/EXIT POINTERS
       EI
       LXI     H,OTDAT2
       SHLD    OTDATP+1       ;SETUP SO XMIT WILL INITIALIZE ITSELF
       LXI     H,0C9AFH
       SHLD    CPSNDR         ;STUFF CODE FOR 'XOR A' AND 'RET'
       RET
;
;
;
;
GOBACK:
       LHLD    DSKJMP+1
       SHLD    MONITOR+15+1      ;REPAIR DISKIO ENTRY POINT PATCH
       LHLD    0001H
       INX     H
       LDED    WARM
       MOV     M,E
       INX     H
       MOV     M,D          ;REPAIR WARMSTART VECTOR IN BIOS
       DI
       MVI     A,00000011B
       OUT     CTC2            ;RESET CTC2 INTERRUPT
       EI
       JMP     0               ;JUMP TO WARMSTART AGAIN
;
;
WARM:  DW    0               ;ADDRESS OF BIOS WARMSTART RTN
;
;
;
;
DISKIO:
       LHLD    CTCVEC+6
       LXI     D,TXWAIT
       ORA     A
       DSBC    D
       JRC     DISKIO        ;LOOP TILL VECTOR => 'TXWAIT'
DSKJMP:CALL    0               ;CALL MONITOR DISK HANDLER
       LBCD    PARAMS
       CALL    COMMINIT        ;THEN RESTART THE MODEM INTERRUPTS
       RET
;
;
;
;
;
;
;
;
;
SELECT:
       LDX     L,2
       LDX     H,3
       CALL    PMSG            ;DISPLAY TITLE MESSAGE
       PUSHIX
       POP     H
       LXI     DE,6
       DAD     D               ;POINT TO START OF VALUES POINTERS
       LDX     E,0
       DAD     D
       DAD     D               ;INDEX TO POINTER(CURRENT_VAL)
       MOV     A,M
       INX     H
       MOV     H,M
       MOV     L,A
       CALL    PMSG            ;DISPLAY CURRENT VALUE MESSAGE
       CALL    CONIN           ;WAIT FOR RESPONSE
       CPI     CR
       JRZ     SELX            ;JUMP OUT OF LOOP IF <CR>
       INRX    0               ;INCREMENT CURRENT_VAL
       LDX     A,0
       CMPX    1               ;COMPARE TO MAXIMUM_VAL
       JRC     SEL2
       MVIX    0,0             ;RESET TO ZERO IF > MAX
SEL2:  CALL    JMP$ILPRT
       DB    CR,0            ;DO CARRIAGE RETURN WITHOUT LF
       JR      SELECT          ;OVERPRINT WITH NEW DISPLAY LINE
;
;
SELX:  CALL    JMP$ILPRT
       DB    CR,LF,0         ;DO LINEFEED AFTER ENTERING <CR>
       LDX     L,4
       LDX     H,5
       LDX     C,0
       MVI     B,0
       DAD     B               ;INDEX INTO TABLE OF INIT CONSTANTS
       MOV     A,M

       RET                     ;RETURN VALUE IN ACC
;
;
;
PMSG:
       MOV     A,M
       INX     H
       ORA     A
       RZ
       CALL    CONOUT
       JR      PMSG
;
;
CONIN  PUSH  B
       PUSH  D
       PUSH  H
       MVI   C,01H
       CALL  0005H
CONRET POP     H
       POP     D
       POP     B
       RET
CONOUT PUSH    B
       PUSH    D
       PUSH    H
       MVI     C,02H
       MOV     E,A
       CALL    0005H
       JR      CONRET
;
;
BAUDTAB:
       DB    1,10
       DW    BTITLE
       DW    BVARS
       DW    B110
       DW    B300
       DW    B450
       DW    B600
       DW    B710
       DW    B1200
       DW    B2400
       DW    B4800
       DW    B9600
       DW    B192
BTITLE:        DB    'BAUDRATE = ',0
B110   DB    ' 110',0
B300:  DB    ' 300',0
B450:  DB    ' 450',0
B600:  DB    ' 600',0
B710:  DB    ' 710',0
B1200: DB    '1200',0
B2400: DB    '2400',0
B4800: DB    '4800',0
B9600: DB    '9600',0
B192:  DB    '19.2',0
BVARS: DB    142
       DB    52
       DB    35
       DB    26
       DB    22
       DB    13
       DB    104
       DB    52
       DB    26
       DB    13
;
;
;
ZWASTE DS      (($ AND 0FF00H)+100H)-$
FIFO:  DS      256
;
;
;
;********************************************************
;*                                                     *
;*                                                     *
;********************************************************
;
;
;      .. I/O PORT EQUATES ..
;
SERIN  EQU     50H             ;RS232 SERIAL INPUT
SEROUT EQU     51H             ;RS232 SERIAL OUTPUT
CTC0   EQU     80H             ;ZILOG COUNTER/TIMER
CTC1   EQU     81H
CTC2   EQU     82H
CTC3   EQU     83H
CMDREG EQU     40H
TRKREG EQU     41H
DATREG EQU     43H
LATCH  EQU     30H
;
MONITOR        EQU     0F000H
CTCVEC EQU     0FF10H
;
;
;
;
;      ... INTERRUPT FOR SERIAL INPUT START BIT ...
;
SBIT:
       EXAF
       EXX
       MVI     A,10100111B
DMODE  EQU     $-1             ;CTC CNTRL WORD FOR DATA BIT INTERRUPT
       OUT     CTC2            ;START BAUDRATE INTERRUPT
       MVI     A,52
DBAUD  EQU     $-1             ;COUNT MODULUS FOR DATA BAUDRATE
       OUT     CTC2            ;PROGRAM BAUDRATE DIVIDE RATIO
       MVI     C,01111111B
       MVI     M,LOW DBIT
       EXAF
       EXX
       EI
       RETI
;
;
;
;      ... INTERRUPT FOR SERIAL INPUT DATA BITS ...
;
DBIT:
       EXAF
       EXX
       IN      SERIN           ;READ RS232 INPUT DATA PORT
       RAL
       RARR    C               ;CONVERT DATA STREAM INTO PARALLEL
       JRC     DBIT2           ;JUMP IF NOT LAST BIT IN WORD
       MOV     A,C
       STA     FIFO
STASH  EQU     $-2             ;FIFO INPUT POINTER STORED HERE
       MVI     M,LOW XBIT
DBIT2: EXAF
       EXX
       EI
       RETI                    ;TAKES 69 CYCLES (87 ON LAST BIT)
;
;
;
;
;      ... INTERRUPT FOR SERIAL INPUT STOP BIT ...
;
XBIT:
       EXAF
       EXX
       MVI     A,10101111B
SMODE  EQU     $-1             ;CTC MODE FOR START BIT INTERRUPT
       OUT     CTC2            ;ENABLE INTERRUPT FROM START BIT AGAIN
       MVI     A,52/2
SBAUD  EQU     $-1             ;MODULUS FOR 1/2 BAUD TIME
       OUT     CTC2
       LDAX    D       ;DE POINTS TO FIFO ENTRY POINTER
       INR     A
       CPI     LOW FIFO
FETCH  EQU     $-1             ;FIFO EXIT POINTER STORED HERE
       JRZ     XBIT2
       STAX    D               ;STORE UPDATED FIFO ENTRY POINTER
XBIT2: MVI     M,LOW SBIT
       EXAF
       EXX
       EI
       RETI
;
;
;
;
;      ... HIGH SPEED SERIAL TRANSMIT INTERRUPT ROUTINES ...
;
;
;
;
TXSTART:
       EXAF
       EXX
       XRA     A
       OUT     SEROUT
       MVI     B,0
TXDATA EQU     $-1             ;BYTE TO TRANSMIT STORED HERE
       MVI     A,LOW TXBIT1
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT1:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT2
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT2:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT3
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT3:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT4
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT4:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT5
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT5:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT6
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT6:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT7
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT7:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       RARR B
       MVI     A,LOW TXBIT8
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXBIT8:
       EXAF
       EXX
       MOV     A,B
       OUT     SEROUT
       MVI     A,LOW TXSTOP
       STA     CTCVEC+6
       EXAF
       EXX
       EI
       RETI
;
;
;
TXSTOP:
       EXAF
       MVI     A,1
       OUT     SEROUT
       MVI     A,LOW TXWAIT
       STA     CTCVEC+6
       EXAF
       EI
       RETI
;
;
;
TXWAIT:
       EXAF
       MVI     A,00000001B
       OUT     CTC3
       EXAF
       EI
       RETI
MSTAT:
       CALL  CPSNDR
       MVI   A,0
       JRNZ  NOSEND
       MVI   A,MODSNDB
NOSEND:
       PUSH  PSW
       CALL  CPRCVR
       CMA
       ANI   MODRCVB
NOREC:
       XTHL
       ORA   H
       POP   H
       RET
;
;      ... SET BAUDRATE/PARITY COMMAND FOR MODEM7 ...
;
SETCMD:
       CALL    JMP$ILPRT
       DB    CR,LF
       DB    'PRESS <CR> TO SELECT BAUD/PARITY SHOWN'
       DB    CR,LF
       DB    'OR ANY OTHER KEY TO DISPLAY NEXT VALUE'
       DB    CR,LF,LF,0
       LXIX    BAUDTAB
       CALL    SELECT
       PUSH    PSW             ;SAVE BAUDRATE DIVIDE CONSTANT
       LXIX    PARTAB
       CALL    SELECT
       POP     B
       MOV     C,A             ;B=CTC TIME CONST, C=CTC INIT BYTE
       LDA     BAUDTAB
       STA     MSPEED
       CPI     6
       JRNC    SETC2           ;JUMP IF BAUDRATE > 1200
       SETB     5,C             ;ELSE SELECT PRESCALE BY 256
SETC2: SBCD    PARAMS
       CALL    COMMINIT
       CALL    JMP$ILPRT
       DB    CR,LF,0
       RET                     ;LEAP BACK INTO MODEM7 KLUDGE
PARTAB:
       DB    0,3
       DW    PTITLE
       DW    PVARS
       DW    PNONE
       DW    PODD
       DW    PEVEN
PTITLE:        DB    '  PARITY = ',0
PNONE: DB    'NONE',0
PODD:  DB    ' ODD',0
PEVEN: DB    'EVEN',0
PVARS: DB    10000000B
       DB    10000011B
       DB    10000010B
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;                                0C00H (without Smartmodem)
;
ZZZLAST EQU  $
       END
