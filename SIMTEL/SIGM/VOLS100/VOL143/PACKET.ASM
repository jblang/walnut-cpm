
TITLE 'PACKET TRANSMISSION / RECEPTION PROGRAM'
;       11-8-80
; LAST MODIFIED 4-12-81
;
;WRITTEN BY DALE A. HEATHERINGTON, WA4DSY
;       3126 FLAMINGO DR.
;       DECATUR, GA     30033
; tel:  404-292-1499
;
;***************************************************************
;This program has not been perfected and probably has a few bugs
;in it.  It is for the 2.2 version of CP/M only.  At this time
;(4-19-81) it has been used by only 2 stations in the Atlanta Ga.
;area so I have no idea what will happen when several stations
;get into a "pile up" .  The program could become confused.  There
;are several fields in the packet which have no function now and
;may be changed later.  There are some packet types which have not
;been implemented ie: FS (file seperator).  Also beware of comments
;;which don't match the code..... 

;Consider this version (1.8) to be in PUBLIC DOMAIN for non-commercial
;use and distribution. This might not be true for future versions.

;********************************************************************
;THIS PROGRAM MUST BE ASSEMBLED WITH THE 
;CP/M RELOACATING MACRO ASSEMBLER (RMAC) AND THE
;MACRO LIBRARY "SEQIO.LIB" MUST BE AVALABLE.
;NOTE: SEQIO.LIB WILL NOT WORK WITH RMAC UNLESS
;MODIFICATIONS ARE MADE.

        MACLIB  SEQIO2          ;MODIFIED SEQIO.LIB

        VERSION EQU     '1'
        PTVER   EQU     '8'             ;VERSION 1.8


        ON      EQU     1
        OFF     EQU     0
;
;--------------------------------------------------------;
;
;                PACKET LAYOUT
;
;  BYTE #       BYTES           DESCRIPTION
;       1       4               LEADER FF,7FH,1FH,7
;       5       1               SOH             START OF HEADER 
;       6       2               TOTAL LENGTH OF MESSAGE (STARTING AT CRC)
;       8       2               CRC BYTES (LOW BYTE FIRST)
;       10      6               DESTINATION CALL SIGN
;       16      1               DESTINATION PHYSICAL LOCATION CODE
;       17      1               DESTINATION REPEATER # (0 = DIRECT)
;       18      6               SOURCE CALL SIGN
;       24      1               SOURCE PHYSICAL LOCATION CODE
;       25      1               SOURCE REPEATER # (0= DIRECT)
;       26      1               PACKET TYPE (ENQ,ACK,NAK,FS,DTA,FRQ,EOT)
;       27      12              PACKET NAME (CP/M FILE NAME)
;       39      2               PACKET NUMBER ( 0..65535 )
;       41      0..1024         DATA BYTES
;
;NOTES:  CRC IS CRC-16 REVERSE  X^16+X^14+X+1 (SAME AS CLINK 3.0)
;
; THE PACKET NAME CONFORMS TO CP/M FILE CONTROL BLOCK FORMAT
; THE FIRST CHARACTER IS THE DRIVE INDICATOR (0=DEFAULT DRIVE)
; THE NEXT 8 ARE THE FILE NAME PADDED WITH TRAILING BLANKS.
; THE LAST 3 ARE THE FILE TYPE
;
; ALL PACKETS TYPES EXCEPT DATA HAVE A PACKET NUMBER OF ZERO.
; DATA PACKETS START WITH PACKET NUMBER 1 AND ARE TRANSMITTED
; IN SEQUENCE.
;
; FOUR RETRYS ARE ALLOWED IF PACKETS ARE "NAK'ED"
;
;       PACKET TYPES
;
;       ENQ     REQUEST TO ESTABLISH COMMUNICATION AND SEND A FILE
;       FRQ     REQUEST A FILE
;       FNF     FILE NOT FOUND
;       DTA     PACKET CONTAINS DATA
;       EOT     END OF TRANSMISSION
;       FS      FILE SEPERATOR
;       ACK     ACKNOWLEDGE RECEIVING PACKET
;       NAK     DID NOT RECEIVE PACKET
;       NAV     RECEIVED ENQ BUT NOT AVALABLE TO RECV. DATA     
;
;---------------------------------------------------------------------;



        SYN     EQU     255
        DTA     EQU     0
        SOH     EQU     1

        FRQ     EQU     3
        EOT     EQU     4
        ENQ     EQU     5
        ACK     EQU     6
        FNF     EQU     7
        NAV     EQU     8
        NAK     EQU     15H
        FS      EQU     1CH


        NULL    EQU     0
        CR      EQU     0DH
        LF      EQU     0AH
        BDOS    EQU     5
        FCB     EQU     5CH
        CPMBOOT EQU     0

        CRCPLY  EQU     8005H
        HDRLEN  SET     TDATA-TCRC      ;HEADER LENGTH
                                        ; CRC TO DATA

;ENTRY LOCATIONS IN THIS MODULE

        PUBLIC  RECVIT
        PUBLIC  SENDIT

;EXTERNAL ENTRY LOCATIONS
        EXTRN   CPUCLK          ;CPU CLOCK RATE IN MHZ
        EXTRN   INITX           ;INITIALIZE FOR XMITTING
        EXTRN   INIRX           ;INITIALIZE FOR RECEIVING
        EXTRN   SENDCHR         ;SEND A BYTE (IN REG. C )
        EXTRN   RECVCHR         ;GET A BYTE (IN REG. A)
        EXTRN   RXSTAT          ;RETURN NON ZERO IF BYTE READY
        EXTRN   RFON            ;KEY TRANSMITTER
        EXTRN   RFOFF           ;UNKEY TRANSMITTER
        EXTRN   CKCD            ;RETURN NON ZERO IF CARRIER
        EXTRN   TONEON          ;AUDIO SUBCARRIER ON
        EXTRN   TONEOFF         ;AUDIO SUBCARRIER OFF
        EXTRN   WAIT1           ;WAIT 1 MILLISECOND
        EXTRN   MYCALL          ;USERS CALL SIGN
        EXTRN   MYLOC           ;USERS LOCATION CODE
        EXTRN   QUIT            ;PATH BACK TO CP/M

;--------------------------------------------------------
;HERE ARE SOME STRING CONSTANTS

WHO$R$U: DB     '????????????'          ;12 QUESTION MARKS

NOFN:   DB      0,'           '         ;0+11 BLANKS (A BLANK FILE NAME)

DIRFILE:DB      0,'DIR        '         ;SPECIAL CASE FOR DIRECTORY

SYNCS:  DB      0FFH,07FH,01FH,7,SOH    ;PREAMBLE FOR PACKETS

;----------------------------------------------------------
;CODE STARTS HERE

INIBUFFR:                               ;INITIALIZE TX BUFFER LEADER
        LXI     H,SYNCS
        LXI     D,TBUFFR
        MVI     B,5
        CALL    MOVE
        RET     

CLEARBUF:                               ;CLEARS RECEIVE BUFFER HEADER
        MVI     B,RDATA-RBUFFR          ;LENGTH OF HEADER
        LXI     H,RBUFFR                ;RECEIVE HEADER
        LXI     D,RBUFFR+1
        JMP     MOVE                    ;CLEAR RECEIVE HEADER
        

;THIS IS THE FILE TRANSMITTING ROUTINE


SENDIT: MVI     A,0
        STA     ID$INH          ;DONT INHIBIT NEXT CW ID
SENDIT2:CALL    INIBUFFR
        LXI     H,MYCALL
        MVI     B,6
        CALL    PRNMEM          ;PRINT OUR CALL SIGN
        CALL    PRINT
        DB      ' PACKET TRANSMISSION PROGRAM VER. ',VERSION,'.',PTVER,CR
        CALL    PRINT
        DB      'CPU CLOCK(MHZ) = @'
        LDA     CPUCLK
        ADI     30H
        MOV     C,A
        CALL    CONOUT          ;PRINT CPU CLOCK CONSTANT
        CALL    CRLF
        LXI     H,HDRLEN        ;GET LENGTH OF ENQ PACKET
        SHLD    TLEN            ;PUT IT IN BUFFER
        MVI     A,ENQ
        STA     TPTYPE          ;PUT PACKET TYPE IN BUFFER
        LXI     H,FCB+17                ;GET DESTINATION CALL SIGN
        LXI     D,TDSTCAL
        MVI     B,6
        CALL    MOVE
        MVI     A,4             ;GET LOCATION CODE
        STA     TDSTLOC
        MVI     A,0             ;NON REPEATER
        STA     TDSTRPT
        LXI     H,MYCALL        ;GET OUR CALL SIGN
        LXI     D,TSRCCAL
        MVI     B,6
        CALL    MOVE            ;PUT IT IN XMIT BUFFER
        LDA     MYLOC           ;GET OUR LOCATION CODE
        STA     TSRCLOC         ;PUT IT IN BUFFER
        MVI     A,0
        STA     TSRCRPT         ;REPEATER # IS ZERO

        LXI     H,FCB           ;GET FILE NAME
        LXI     D,TTITLE
        MVI     B,12
        CALL    MOVE            ;PUT IT IN BUFFER
        SUB     A
        STA     TTITLE          ;DESTINATE IT TO DEFAULT DRIVE
        LXI     H,0
        SHLD    TPACNUM         ;ZERO THE PACKET NUMBER

        LXI     H,TTITLE+1      ;SEE IF DIRECTORY REQUEST "DIR"
        LXI     D,DIRFILE+1
        MVI     B,11
        CALL    COMPARE$
        JNZ     REALFILE        ;JUMP IF NOT DIRECTORY REQUEST
        MVI     A,255
        STA     DIRFLAG         ;SET DIRECTORY FLAG
        CALL    OPEN$DIR        ;SET UP DIRECTORY ROUTINE
        JMP     FIRSTID         ;START SENDING



REALFILE:
        MVI     A,0
        STA     DIRFLAG         ;CLEAR DIRECTORY FLAG

        FILE    SETFILE,CHECK,,1,,
        DIRECT  CHECK           ;SEE IF THE FILE IS THERE

        JNZ     GOTIT           ;JUMP IF WE FOUND IT
        CALL    PRINT
        DB      'FILE NOT FOUND',CR
        MVI     A,1             ;RETURN A=1 IF NOT FOUND
        ORA     A
        RET

GOTIT:  FILE    INFILE,SOURCE,,1,,1024,INBUFFER

FIRSTID:                
        CALL    CWID            ;ID IN (YUK) MORSE CODE FOR FCC
        CALL    SENDPAC         ;SEND THE BUFFER CONTENTS (ENQ PACKET)
        JZ      OK2SEND
        CALL    NORPLY          ;SAY HE'S NOT HOME
        RET                     ;QUIT

OK2SEND:LXI     H,1             ;SET PACKET NUMBER TO 1
        SHLD    TPACNUM
TXLP:
        LXI     H,1024          ;MAX DATA LENGTH
        SHLD    DATACNT
        LXI     H,TDATA         ;POINTER TO XMIT DATA BUFFER
        SHLD    DATAPTR
        LXI     H,HDRLEN        ;RESET LENGTH FIELD
        SHLD    TLEN

FILBUF:
        LDA     DIRFLAG
        ORA     A               ;DIRECTORY OR FILE??
        JZ      FLB1            ;JMP IF FILE
                                ;ELSE...
        CALL    GETABYTE        ;GET A BYTE FROM DIRECTORY
        JMP     FLB2

FLB1:   GET     SOURCE          ;GET A BYTE FROM SOURCE FILE

FLB2:   JZ      DONE
        LHLD    DATAPTR
        MOV     M,A             ;PUT IT IN BUFFER
        INX     H               ;ADVANCE POINTER
        SHLD    DATAPTR         ;SAVE IT
        LHLD    TLEN
        INX     H               ;ADVANCE LENGTH FIELD
        SHLD    TLEN
        LHLD    DATACNT
        DCX     H
        SHLD    DATACNT
        MOV     A,L
        ORA     H               ;SEE IF WE DID 1024 BYTES
        JNZ     FILBUF
        MVI     A,DTA
        STA     TPTYPE          ;PACKET TYPE IS DATA
        CALL    SENDPAC         ;NOW TRANSMIT THE PACKET
        JNZ     ERRR
        LHLD    TPACNUM
        INX     H
        SHLD    TPACNUM         ;COUNT THE PACKET
        MOV     A,L
        DCR     A
        ANI     7               ;ID IN CW EVERY 8TH PACKET
        CZ      CWID
        JMP     TXLP            ;GO BACK TO DO ANOTHER PACKET

DONE:
        LHLD    TLEN            ;SEE IF LENGTH IS ZERO
        LXI     D,-HDRLEN
        DAD     D
        MOV     A,L
        ORA     H
        JZ      SNDEOT          ;IF ZERO LENGTH JUST DO EOT

        MVI     A,DTA           ;ELSE SEND SHORT DATA PACKET
        STA     TPTYPE
        CALL    SENDPAC
        JNZ     ERRR            ;QUIT IF BAD OR NO RESPONSE

SNDEOT: MVI     A,EOT
SND2:   STA     TPTYPE
        LXI     H,HDRLEN        ;
        SHLD    TLEN            ;SET LENGTH
        LXI     H,0             ;CONTROL PACKETS HAVE NUMBER 0
        SHLD    TPACNUM
        CALL    SENDPAC         ;SEND LAST PACKET
        PUSH    PSW
        CALL    CWID            ;LET FCC KNOW WHO WE ARE
        POP     PSW
        JNZ     ERRR
        CALL    PRINT
        DB      'ALL PACKETS SENT',CR
        XRA     A               ;RETURN ZERO IF OK
        RET


ERRR:   CALL    PRINT
        DB      'TRANSMISSION ABORTED',7,CR
        MVI     A,255
        ORA     A
        RET                     ;RETURN NON ZERO IF ERROR



;THIS IS THE FILE REQUEST ROUTINE
;COME HERE IF PACKET IS REQUESTING A FILE FROM US.
;
FLREQ:  CALL    CWID            ;ID IN CRUDE MORSE CODE
        MVI     A,ACK
        STA     TPTYPE
        CALL    SENDAPAC        ;ACK HIS FILE REQUEST
        LXI     H,RSRCCAL       ;GET HIS CALL SIGN
        LXI     D,FCB+17
        MVI     B,6
        CALL    MOVE            ;MOVE IT TO FCB
        MVI     A,1
        STA     ID$INH          ;INHIBIT NEXT CW ID
        CALL    SENDIT2         ;SEND THE FILE IF WE HAVE IT
        RZ                      ;QUIT NOW IF FILE WAS SENT
        CPI     1               ;SEE IF THE FILE WAS NOT IN DIR
        RNZ                     ;RETURN IF JUST BAD SIGNALS
        MVI     A,FNF           ;ELSE SEND FILE NOT FOUND PACKET
        STA     TPTYPE
        LXI     H,HDRLEN
        SHLD    TLEN            ;INIT HEADER LENGTH
        LXI     H,0
        SHLD    TPACNUM         ;SET PACKET NUMBER TO ZERO
        CALL    SENDAPAC        ;SEND THE FNF PACKET
        CALL    CWID
        XRA     A
        RET                     ;ALL DONE




;THIS SENDS A FILE REQUEST PACKET TO THE OTHER GUY IF
;WE WANTED TO GET A FILE FROM HIM.
;
SENDFRQ:
        LXI     H,HDRLEN
        SHLD    TLEN
        MVI     A,FRQ
        STA     TPTYPE
        LXI     H,MYCALL
        LXI     D,TSRCCAL
        MVI     B,6             ;SET UP SOURCE CALL
        CALL    MOVE
        LXI     H,FCB+17        ;GET DESTINATION CALL
        LXI     D,TDSTCAL
        MVI     B,6
        CALL    MOVE
        MVI     A,0
        STA     TSRCRPT
        MVI     A,14H           ;DEST. LOCATION CODE
        STA     TDSTLOC
        LDA     MYLOC
        STA     TSRCLOC
        LXI     H,FCB
        LXI     D,TTITLE        ;GET FILE NAME
        MVI     B,12
        CALL    MOVE
        LXI     H,0
        SHLD    TPACNUM         ;CLEAR PACKET NUMBER
        CALL    CWID
        CALL    SENDPAC         ;SEND FRQ PACKET AND GET REPLY
        RET                     ;RETURN ZERO WITH PACKET TYPE IN ACC

;-------------------------------------------------------------------

;       TITLE 'DIRECTORY LISTER'
;THIS IS A SELF CONTAINED SUBROUTINE WHICH WILL
;RETURN THE CP/M DIRECTORY A BYTE AT A TIME BY 
;CALLING "GETABYTE".
;THE ZERO FLAG WILL BE SET AFTER THE LAST BYTE
;IS RETURNED.
;THE SUBROUTINE MUST BE INITIALIZED BY 
;CALLING "OPEN$DIR" FIRST.

        SETDMA  EQU     26
        SEARCH  EQU     17
SEARCH$NEXT     EQU     18
GET$ALLOC       EQU     27
GET$DPBLK       EQU     31



DIRFCB: DB      0       ;DR
        DB      '???????????',0
        DS      20
PWR10:  DW      -1000
        DW      -100
        DW      -10
        DW      -1

        DSEG                            ;DATA SEGMENT

N1:     DS      0
SWITCH: DS      1
KLEFT:  DS      2                       ;K BYTES LEFT ON DISK
ENCNT:  DS      1
COUNTER:DS      1
DPBADR: DS      2                       ;ADDRESS OF DISK PARAMETER BLOCK
POINTER:DS      2
ENTBUF: DS      16                      ;BUFFER FOR 1 DIR. ENTRY

BUFFER: DS      128

;-------------------------------------------------------------
        CSEG                    ;CODE SEGMENT



;RETURNS HL POINTING TO NEXT DIRECTORY ENTRY

;A=ZERO IF OK OR 255 IF NO MORE ENTRYS

GET$ENTRY:
        LDA     SWITCH
        ORA     A
        JZ      SNXT            ;DO SEARCH NEXT IF ZERO
        MVI     C,SETDMA
        LXI     D,BUFFER
        CALL    BDOS            ;SET UP DIRECTORY BUFFER
        LXI     D,DIRFCB
        MVI     C,SEARCH        ;SEARCH FOR FIRST ENTRY
        CALL    BDOS
        JMP     GE2

SNXT:   LXI     D,DIRFCB
        MVI     C,SEARCH$NEXT
        CALL    BDOS            ;SEARCH FOR NEXT ENTRY

GE2:    CPI     255             ;DONE?
        RZ
        ADD     A               ;MPY BY 32
        ADD     A
        ADD     A
        ADD     A
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,BUFFER
        DAD     D
        XRA     A
        STA     SWITCH          ;CLEAR THE SWITCH
        RET                     ;A=0  HL->ENTRY

;-------------------------------------------------------------

OPEN$DIR:                       ;INITIALIZE DIRECTORY LISTER
        MVI     A,255
        STA     SWITCH
        MVI     A,4             ;INIT ENTRY COUNTER
        STA     ENCNT
        MVI     A,1
        STA     COUNTER
        LXI     H,ENTBUF
        SHLD    POINTER

;AT NO EXTRA CHARGE WE NOW GIVE YOU THE NUMBER OF K BYTES
;LEFT ON THE DISK... RETURNED IN HL

        MVI     C,GET$DPBLK     ;GET DISK PRAM. BLOCK ADDRESS
        CALL    BDOS
        SHLD    DPBADR          ;SAVE IT
        LXI     D,5
        DAD     D               ;POINT TO DISK CAPACITY
        MOV     E,M             ;GET IT
        INX     H
        MOV     D,M
        PUSH    D               ;SAVE IT
        MVI     C,GET$ALLOC
        CALL    BDOS            ;GET ADDRESS OF ALLOCATION MAP
        POP     B
        PUSH    B               ;GET AND SAVE DISK CAPACITY
        LXI     D,0             ; BLOCK COUNTER
CNTK:   MOV     A,M             ;GET 8 ALLOCATION UNIT BITS
        PUSH    H               ;SAVE POINTER
        MVI     L,8
        MOV     H,A             ;BITS OF ALLOCATION TO H
CBITS:  MOV     A,H
        ADD     A               ;SHIFT OVER A BIT
        MOV     H,A
        JNC     ZEROB
        INX     D               ;COUNT THE ONE'S
ZEROB:  DCX     B               ;COUNT A BLOCK
        MOV     A,C
        ORA     B
        JZ      NOMORE
        DCR     L               ;COUNT BITS
        JNZ     CBITS           ;LOOP 8 TIMES
        POP     H               ;GET POINTER BACK
        INX     H
        JMP     CNTK            ;LOOP 

NOMORE: POP     H
        MOV     A,E             ;TWOS COMPLIMENT BLOCKS USED
        CMA
        MOV     E,A
        MOV     A,D
        CMA
        MOV     D,A
        INX     D
        POP     H               ;GET MAX DISK CAPACITY
        DAD     D               ;ADD THE -KBYTES USED
        INX     H               ;CORRECTION
        PUSH    H               ;PUSH BLOCKS USED ON STACK
        LHLD    DPBADR          ;GET ADDRESS OF DISK PARAMETER BLOCK
        LXI     D,2
        DAD     D               ;POINT TO BLOCK SHIFT FACTOR
        MOV     A,M             ;GET IT
        SUI     3               ;REMOVE BIAS
        POP     H               ;GET BLOCKS LEFT
KLOOP:  ORA     A               ;TEST FOR ZERO
        JZ      KDONE
        DAD     H               ;SHIFT HL
        DCR     A
        JMP     KLOOP   
KDONE:  SHLD    KLEFT           ;SAVE THE NUMBER
        RET

;-------------------------------------------------------------

GETABYTE:                       ;GET 1 CHARACTER OF DIRECTORY

        LXI     H,COUNTER
        DCR     M
        JZ      ANOTHER
        LHLD    POINTER
        MOV     A,M
        INX     H
        SHLD    POINTER
        ORA     A               ;RETURN NON ZERO IF NOT DONE
        RET

ANOTHER:
        LXI     H,ENTBUF        ;CLEAR ENTRY BUFFER POINTER
        SHLD    POINTER
        CALL    GET$ENTRY
        CPI     255
        JZ      PUTK            ;DONE, SAY HOW MANY BYTES LEFT NOW
        MVI     B,8
        LXI     D,ENTBUF
AN1:    INX     H
        MOV     A,M             ;MOVE FILE NAME TO BUFFER
        STAX    D
        INX     D
        DCR     B
        JNZ     AN1
        MVI     A,' '
        MVI     B,4
AN2:    STAX    D
        INX     D
        INX     H
        MOV     A,M
        DCR     B
        JNZ     AN2
        XCHG
        LDA     ENCNT           ;GET ENTRY COUNT
        DCR     A
        JNZ     AN3             ;END OF LINE IF ZERO
        CALL    EOL
        JMP     GETABYTE
AN3:    STA     ENCNT
        MVI     M,' '           ;ELSE PUT UP FENCE
        INX     H
        MVI     M,':'
        INX     H
        MVI     M,' '
        MVI     A,16
        STA     COUNTER
        JMP     GETABYTE

EOL:    MVI     M,0DH
        INX     H
        MVI     M,0AH
        INX     H
        MVI     A,15
        STA     COUNTER
        MVI     A,4
        STA     ENCNT
        RET


PUTK:
        LXI     H,ENTBUF        ;PUTS "XXXX K LEFT" IN BUFF
        CALL    EOL
        SHLD    POINTER
        LHLD    KLEFT
        CALL    DECONV          ;CONVERT K TO DECIMAL & PUT IN BUFFER
        LHLD    POINTER
        LXI     D,KMSG
        MVI     B,11
PKLP:   LDAX    D               ;PUT IN " K LEFT <CR> <LF>"
        MOV     M,A
        INX     D
        INX     H
        DCR     B
        JNZ     PKLP
        LXI     H,ENTBUF
        SHLD    POINTER
        MVI     A,17
        STA     COUNTER
        JMP     GETABYTE

KMSG:   DB      ' K LEFT',0DH,0AH,0
                

                
;--------------------------------------------------------------
;CONVERT NUMBER IN HL TO DECIMAL STRING AND PUT IN BUFFER
;USING "POINTER"

DECONV:
        SHLD    N1
        LXI     H,PWR10
DECV0:  MOV     E,M
        INX     H
        MOV     D,M             ;GET POWER OF 10
        INX     H
        PUSH    H
        LHLD    N1
        MVI     C,'0'
DECV1:  DAD     D               ;SUB POWER OF 10 FROM N1
        JNC     DECV2
        INR     C
        JMP     DECV1           ;LOOP TIL IT GOES NEG.
DECV2:  MOV     A,E
        CMA
        MOV     E,A             ;TWOS COMPLIMENT
        MOV     A,D
        CMA
        MOV     D,A
        INX     D
        DAD     D               ;RESTORE TO +
        SHLD    N1
        LHLD    POINTER
        MOV     M,C             ;OUTPUT DIGIT TO BUFFER
        INX     H
        SHLD    POINTER
        POP     H
        MVI     A,1
        CMP     E               ;DONE YET?
        JNZ     DECV0
        RET



;END OF DIRECTORY LISTER


;--------------------------------------------------------------------
;
;THIS IS THE FILE RECEIVE ROUTINE
;
;
RECVIT:
        MVI     A,0
        STA     ID$INH          ;DONT INHIBIT NEXT CW ID
        CALL    INIBUFFR
        LXI     H,MYCALL
        MVI     B,6
        CALL    PRNMEM          ;PRINT OUR CALL SIGN
        CALL    PRINT
        DB      ' PACKET RECEPTION PROGRAM VER. ',VERSION,'.',PTVER,CR
        CALL    PRINT
        DB      'CPU CLOCK(MHZ)= @'
        LDA     CPUCLK
        ADI     30H
        MOV     C,A
        CALL    CONOUT
        CALL    CRLF
        LDA     80H             ;SEE IF FILE NAME WAS ENTERED
        ORA     A
        JZ      RCV0            ;JUMP IF NORMAL RECEIVE

        CALL    SENDFRQ         ;DO FILE REQUEST IF LENGTH NON ZERO     
        RNZ                     ;RETURN IF BAD 
        CPI     ACK             ;SEE IF HE HAD THE FILE
        RNZ                     ;RETURN AND QUIT IF NOT
        MVI     A,1
        STA     ID$INH          ;ALL OK, INHIBIT NEXT CW ID

RCV0:   LXI     H,HDRLEN        ;INIT THE TRANSMIT HEADER
        SHLD    TLEN
        MVI     A,ACK
        STA     TPTYPE          ;BE OPTIMISTIC

        LXI     H,MYCALL
        LXI     D,TSRCCAL       ;PUT IN OUR CALL
        MVI     B,6
        CALL    MOVE

        LDA     MYLOC           ;GET LOCATION CODE
        STA     TSRCLOC
        MVI     A,0
        STA     TSRCRPT         ;WE ARE NOT A REPEATER (YET)
        STA     TDSTLOC         ;CLEAR THE DEST. LOC. CODE

        LXI     H,WHO$R$U       ;INIT. THE DEST. CALL WITH ??????
        LXI     D,TDSTCAL
        MVI     B,6
        CALL    MOVE

        LXI     H,NOFN          ;CLEAR THE FILE NAME FIELD
        LXI     D,TTITLE
        MVI     B,12
        CALL    MOVE

        CALL    PRINT
        DB      'WAITING FOR ENQ PACKET',CR

        LXI     H,0
        SHLD    80H             ;CLEAR CP/M DEFAULT BUFFER
        SHLD    TPACNUM         ;CLEAR PACKET NUMBER
        LXI     D,0             ;ZERO TELLS IT TO WAIT FOREVER
        CALL    RECVPAC         ;GET A PACKET
        JNZ     RECVIT          ;JUMP IF BAD
        CPI     FRQ             ;REQUEST FOR FILE?
        JZ      RCV1            ;YES, THEN JUMP
        CPI     ENQ
        JNZ     RECVIT          ;JUMP IF NOT ENQ
RCV1:   LXI     H,RSRCCAL       ;POINT TO SOURCE CALL SIGN
        LXI     D,TDSTCAL       ;MOVE IT TO DESTINATION
        MVI     B,6
        CALL    MOVE
        CALL    CKCALL          ;SEE IF PACKET IS FOR US
        JNZ     RECVIT          ;NO, GO BACK
        
        LXI     H,RTITLE        ;GET FILE NAME TO FCB
        LXI     D,FCB
        MVI     B,12
        CALL    MOVE
        LDA     RPTYPE          ;CHECK PACKET TYPE AGAIN
        CPI     FRQ             ;FILE REQUEST?
        JNZ     RXD3            ;YUP, PROCESS THAT INSTEAD
        CALL    FLREQ
        LXI     H,80H           ;POINT TO CP/M DEFAULT BUFFER
        MVI     M,0             ;CLEAR LENGTH BYTE
        JMP     RECVIT          ;AND GO BACK AND WAIT FOR ENQ

RXD3:   FILE    OUTFILE,TEMP,,1,$$$,1024,OUTBUFFER  ;OPEN THE TEMP. FILE
        FILE    SETFILE,DEST,,1,,               ;SET UP FOR REAL FILE

        LXI     H,1             ;INIT THE SEQUENCE NUMBER
        SHLD    SEQNUM          ;FOR THE FIRST PACKET

RXDLP2: CALL    CWID            ;WASTE TIME WITH PRIMITIVE MORSE CODE
                
RXDLP1: MVI     A,ACK           ;NOW DO MODERN ASCII STUFF
        STA     TPTYPE
        CALL    SENDAPAC        ;SEND ACK PACK

RECVDATA:
        LXI     D,15000         ;SET FOR 15 SEC TIMEOUT
        CALL    RECVPAC         ;GO GET A PACKET
        JNZ     BADPAC
        CPI     FS              ;FS NOT REALLY IMPLIMENTED YET
        JZ      CLOSEIT         ;BUT CLOSE  FILE ANYWAY
        CPI     EOT
        JZ      CLOSEIT
        CPI     ENQ
        JZ      RXDLP1          ;ACK THE EXTRA ENQ
        CPI     DTA             ;DATA?
        RNZ

        LHLD    RLEN            ;CHECK FOR ZERO LENGTH
        LXI     D,-HDRLEN
        DAD     D
        MOV     A,L
        ORA     H
        JZ      RXDLP1          ;DISCARD ZERO LENGTH DATA PACKET

        LHLD    SEQNUM          ;CHECK FOR DUPLICATE PACKET
        LDA     RPACNUM 
        CMP     L
        JNZ     DISCARD         ;DISCARD IF OUT OF SEQUENCE
        LDA     RPACNUM+1
        CMP     H
        JNZ     DISCARD
        INX     H               ;COUNT THIS PACKET
        SHLD    SEQNUM          ;UPDATE SEQUENCE NUMBER
        LXI     D,-HDRLEN
        LHLD    RLEN            ;GET LENGTH
        DAD     D               ;DATA LENGTH=TOTAL-HEADER
        SHLD    DATACNT         ;SAVE DATA COUNT
        LXI     H,RDATA         ;DATA BUFFER POINTER
        SHLD    DATAPTR         ;SAVE IT
RXDLP:  LHLD    DATAPTR
        MOV     A,M             ;PUT BUFFER CONTENTS ON DISK
        INX     H
        SHLD    DATAPTR
        PUT     TEMP            ;WRITE TO TEMPORARY FILE
        LHLD    DATACNT
        DCX     H
        SHLD    DATACNT         ;COUNT BYTES
        MOV     A,L
        ORA     H
        JNZ     RXDLP           ;LOOP TILL ZERO
        LDA     SEQNUM          ;GET LOW BYTE OF SEQUENCE NUMBER
        ANI     7
        JZ      RXDLP2          ;DO CW ID EVERY 8TH ACK
        JMP     RXDLP1          ;SEND ACK AND DO IT AGAIN

DISCARD: CALL   PRINT
        DB      'EXTRA PACKET DISCARDED',CR
        JMP     RXDLP1


CLOSEIT:
        FINIS   TEMP
        ERASE   DEST
        RENAME  DEST,TEMP
        MVI     A,ACK
        STA     TPTYPE          ;SEND FINAL ACK
        CALL    SENDAPAC
        CALL    CWID            ;FINAL CW ID
        CALL    PRINT
        DB      'FILE RECEIVED',CR
        LXI     H,80H
        MVI     M,0
        JMP     RECVIT          ;GO WAIT FOR ENQ AGAIN


BADPAC: FINIS   TEMP
        ERASE   TEMP
        CALL    PRINT
        DB      'TOO MANY ERRORS, RECEPTION ABORTED',7,CR
        LXI     H,80H
        MVI     M,0
        JMP     RECVIT

                

;WAIT FOR A SYNC STREAM FOLOWED BY SOH 
;"TIME" HAS TIMEOUT VALUE IN MS
;"TIME"= ZERO MEANS WAIT FOREVER
;
WAITSOH:
        CALL    RFOFF           ;BE SURE WE DONT TRANSMIT
        CALL    INIRX           ;INIT MODEM FOR RECEIVE
        LHLD    TIME
        SHLD    TEMPTIME        ;GET TIMEOUT VALUE
WSOH3:  CALL    CKCRLC          ;CHECK FOR CONTROL C
        CALL    COUNTDOWN       ;DO TIMEOUT TEST
        RZ                      ;RETURN ZERO IF TIMEOUT
        CALL    RXSTAT          ;CHECK FOR A CHARACTER
        ORA     A
        JZ      WSOH3           ;LOOP BACK IF WE DONT HAVE ONE

        LXI     H,LEADBB+1      ;LEADIN BUFFER END POINTER
        LXI     D,LEADBB        ;LEADIN START POINTER
        MVI     B,4             ;NUMBER OF BYTES TO SHIFT
        CALL    MOVE            ;SHIFT BYTES OVER

        LXI     D,1             ;1 MS TIMEOUT (CHAR. THERE ALREADY)
        CALL    RECVCHR         ;GET THE CHARACTER
        STA     LEADBE          ;STORE AT END OF BUFFER
        LXI     H,LEADBB        ;ADDRESS OF UNKNOWN STRING
        LXI     D,SYNCS         ;THIS IS WHAT WERE LOOKING FOR
        MVI     B,5             ;WE WANT TO CHECK 5 CHARACTERS
        CALL    COMPARE$        ;NOW COMPARE SYNCS WITH UNKNOWN
        JNZ     WSOH3           ;NO MATCH, LOOP BACK
        MVI     A,SOH           ;RETURN WITH SOH MEANS WE GOT IT
        RET




COUNTDOWN:
        LHLD    TEMPTIME        ;GET TIMEOUT VALUE
        MOV     A,L
        ORA     H               ;PRETEST FOR ZERO
        JZ      NEVERMIND       ;ZERO MEANS WAIT FOREVER
        DCX     H               ;COUNT 1 MS
        SHLD    TEMPTIME        ;SAVE NEW VALUE
        CALL    WAIT1           ;WAIT 1 MS
        MOV     A,L
        ORA     H
        RET                     ;RET ZERO IF TIMED OUT

NEVERMIND:
        MVI     A,255
        ORA     A
        RET                     ;PRETEND WE DIDN'T TIMEOUT

        

;CHECKS CONSOLE FOR CONTROL C TO ABORT

CKCRLC: CALL    CONST           ;CHECK CONSOLE
        ORA     A
        RZ
        CALL    CONIN           ;GET CONSOLE CHAR
        CPI     3               ;CONTROL C?
        RNZ
        JMP     QUIT
;---------------------------------------------------------
;
;RECEIVES 1 PACKET OF ANY TYPE TO ANY DESTINATION
;ENTER WITH DE CONTAINING THE TIMEOUT VALUE IN MILLISECONDS.
;IF DE=0 THE TIMEOUT IS FOREVER
;IT WILL TRY 4 TIMES TO HEAR THE PACKET BEFORE GIVING UP.
;RETURNS WITH PACKET TYPE IN REG. A WITH ZERO FLAG SET.
;RETURNS NON-ZERO IF ERROR.
;
RECVPAC:
        XCHG
        SHLD    TIME            ;SET TIMEOUT VALUE
        MVI     A,4             ;SET RETRY COUNTER
        STA     RETRYS
RP1:    CALL    RECVAPAC        ;GET 1 PACKET
        JNZ     RP4             ;JUMP IF ERROR
        XRA     A
        LDA     RPTYPE          ;A HAS PACKET TYPE
        RET                     ;EXIT

RP4:
        LDA     RETRYS          ;COUNT THE RETRYS
        DCR     A
        STA     RETRYS
        JNZ     RP3
        INR     A
        RET                     ;RETURN NON ZERO IF ERROR

RP3:    CALL    CKCALL          ;SEE IF IT WAS FOR US
        JNZ     RP1             ;DONT NAK IF NOT FOR US
        MVI     A,NAK
        STA     TPTYPE
        CALL    SENDAPAC        ;SEND NAK PAC
        JMP     RP1             ;GO BACK AND TRY AGAIN




;GETS 1 PACKET (NO RETRYS, SEE RECVPAC ABOVE)
;RETURNS ZERO FLAG SET WITH PACKET TYPE IN REG. A
;IF NO ERRORS
;"TIME" HAS TIMEOUT VALUE... 0=FOREVER


RECVAPAC:
        CALL    CLEARBUF        ;CLEAR RECEIVE HEADER
        CALL    WAITSOH         ;WAIT FOR NEW LEADER
        CPI     SOH
        JNZ     TOOLONG         ;MUST BE TIMEOUT IF NO SOH
        LXI     H,HDRLEN+2      ;TOTAL LENGTH OF HEADER
        SHLD    RLEN            ;INITIAL LENGTH
        LXI     H,RCRC          ;SET UP BUFFER POINTER
        SHLD    DATAPTR
        LXI     D,100           ;100 MS TIMEOUT
        CALL    RECVCHR         ;TRY TO GET A CHAR
        JC      TOOLONG
        STA     RLEN            ;GET LOW LENGTH BYTE
        CALL    RECVCHR
        JC      TOOLONG
        STA     RLEN+1          ;HIGH LENGTH BYTE
        LHLD    RLEN            ;GET COUNT
        SHLD    DATACNT         ;SAVE IT
        CPI     5               ;SEE IF LENGTH TOO BIG
        JNC     TOOBIG
RCVLP:  CALL    RECVCHR         ;START GETTING REST OF DATA NOW
        JC      TOOLONG
        LHLD    DATAPTR
        MOV     M,A             ;PUT A BYTE IN PACKET BUFFER
        INX     H
        SHLD    DATAPTR
        LHLD    DATACNT         ;COUNT THE BYTES
        DCX     H
        SHLD    DATACNT
        MOV     A,L
        ORA     H
        JNZ     RCVLP           ;LOOP FOR MORE BYTES
        CALL    RXCRC           ;CHECK RECEIVED CRC
        JNZ     CRCERR          ;JUMP IF ERROR
        CALL    PRNRXHEADER     ;PRINT WHAT WE RECEIVED
        LDA     RPTYPE          ;GET PACKET TYPE
        CMP     A               ;SET ZERO FLAG
        RET

CRCERR: CALL    PRINT
        DB      '** CRC ERROR **',7,CR
        XRA     A
        INR     A
        RET                     ;RETURN NON ZERO DUE TO ERROR


                                
;COME HERE AFTER TIMEOUT ERROR
;
TOOLONG:
        CALL    PRINT
        DB      '** TIMEOUT ERROR **',7,CR
        XRA     A
        INR     A               ;RETURN NON ZERO
        RET


TOOBIG:
        CALL    PRINT
        DB      '** PACKET TOO BIG FOR BUFFER **',7,CR
        XRA     A
        INR     A
        RET

;
;
;
;
;----------------------------------------------------------
;THIS IS THE PACKET TRANSMISSION SECTION

;SEND 1 PACKET AND WAIT FOR REPLY
;AND DO IT UP TO 4 TIMES IF IT GETS A NAK BACK
;OR A TIMEOUT

SENDPAC:MVI     A,4             ;RETRY COUNTER
        STA     RETRYS
AGAIN:  CALL    SENDAPAC        ;SEND THE PACKET
        CALL    INIRX           ;SET UP FOR RECEIVE
        LXI     H,23000         ;23 SEC TIMEOUT
        SHLD    TIME
        CALL    RECVAPAC        ;GET REPLY PACKET
        JNZ     SNDP1           ;ERROR IF NON ZERO
        CPI     NAK
        JZ      SNDP1           ;TRY AGAIN IF NAK
        CMP     A               ;SET ZERO FLAG
        RET                     ;RETURN PACKET TYPE IN ACC
SNDP1:  LDA     RETRYS
        DCR     A
        STA     RETRYS
        JZ      SP2
        CALL    PRINT
        DB      'RETRANSMITTING',CR
        JMP     AGAIN           ;TRY AGAIN

SP2:    MVI     A,1             ;1=ERROR
        ORA     A
        RET
;
;
;THIS SENDS 1 PACKET
;
SENDAPAC:
        CALL    INITX           ;SET UP FOR TRANSMIT
        LXI     D,3000          ;3 SEC WAIT AFTER KEYDOWN
        CALL    RFON            ;KEY TRANSMITTER
        CALL    TXCRC           ;COMPUTE TRANSMIT CRC
        CALL    PRNTXHEADER     ;TELL USER WHAT WERE SENDING
        LHLD    TLEN            ;GET PACKET LENGTH
        INX     H
        INX     H
        INX     H
        INX     H
        INX     H               ;ADD 7 FOR LEADER AND LENGTH BYTES
        INX     H
        INX     H
        XCHG                    ;TRUE LENGTH IN DE
        LXI     H,TBUFFR        ;POINT TO START OF BUFFER
SP1:    MOV     C,M             ;GET A BYTE
        CALL    SENDCHR         ;SEND IT
        CALL    CKCRLC          ;ABORT IF CONTROL C TYPED
        INX     H
        DCX     D
        MOV     A,E
        ORA     D
        JNZ     SP1             ;LOOP TIL ALL BYTES SENT
        LXI     D,100
        CALL    DELAY           ;100 MS TRAILER
        CALL    RFOFF           ;KILL TRANSMITTER
        RET

;
;
;
;---------------------------------------------------
;THIS MESS PRINTS THE HEADER INFORMATION TO THE CONSOLE
;FOR PACKETS TO BE SENT OR PACKETS WHICH HAVE BEEN RECEIVED.

PRNTXHEADER:
        LXI     H,TBUFFR
        LXI     D,BUFFR
        MVI     B,TDATA-TBUFFR
        CALL    MOVE                    ;GET TRANSMIT HEADER

        CALL    PRINT
        DB      'TX-@'
        CALL    PRINFO
        RET

PRNRXHEADER:
        LXI     H,RBUFFR
        LXI     D,BUFFR
        MVI     B,RDATA-RBUFFR
        CALL    MOVE                    ;GET RECEIVER HEADER
        CALL    PRINT
        DB      'RX-@'
;
PRINFO: 
        LHLD    LEN
        CALL    BXDEC                   ;PRINT LENGTH
        CALL    PRINT
        DB      ' BYTES #@'
        LHLD    PACNUM
        CALL    BXDEC                   ;PRINT PACKET NUMBER
        CALL    PRINT
        DB      ' @'
        LXI     H,SRCCAL
        MVI     B,6
        CALL    PRNMEM                  ;PRINT SOURCE CALL
        CALL    PRINT
        DB      ' -> @'
        LXI     H,DSTCAL
        MVI     B,6
        CALL    PRNMEM                  ;PRINT DESTINATION CALL
        CALL    PRINT
        DB      ', @'
        LXI     H,STITLE+1
        MVI     B,11
        CALL    PRNMEM                  ;PRINT FILE NAME
        CALL    PRINT
        DB      ' = @'
        CALL    PRTYPE
        JMP     CRLF
        

PRTYPE: LDA     PTYPE
        CPI     DTA
        JZ      TPDTA
        CPI     ENQ
        JZ      TPENQ
        CPI     ACK
        JZ      TPACK
        CPI     NAK
        JZ      TPNAK
        CPI     FS
        JZ      TPFS
        CPI     EOT
        JZ      TPEOT
        CPI     FRQ
        JZ      TPFRQ
        CPI     FNF
        JZ      TPFNF
        CALL    PRINT
        DB      'UNKNOWN @'
        RET

TPDTA:  CALL    PRINT
        DB      'DATA @'
        RET

TPENQ:  CALL    PRINT
        DB      'ENQ @'
        RET

TPACK:  CALL    PRINT
        DB      'ACK @'
        RET

TPNAK:  CALL    PRINT
        DB      'NAK @'
        RET

TPFS:   CALL    PRINT
        DB      'FS @'
        RET

TPEOT:  CALL    PRINT
        DB      'EOT @'
        RET
TPFRQ:  CALL    PRINT
        DB      'FRQ @'
        RET

TPDRQ:  CALL    PRINT
        DB      'DRQ @'
        RET

TPFNF:  CALL    PRINT
        DB      'FNF @'
        RET

;-----------------------------------------------------


CRLF:   CALL    PRINT
        DB      CR
        RET


;COMPARES 2 STRINGS
;POINTED TO BY HL & DE (B HAS LENGTH)
;RETURNS ZERO FLAG SET IF EQUAL
;
COMPARE$:
        LDAX    D
        CMP     M
        RNZ
        INX     H
        INX     D
        DCR     B
        JNZ     COMPARE$
        XRA     A
        RET

;CHECKS THE RECEIVED CALL SIGN AGAINST OUR OWN
;RETURNS ZERO IF MATCHED.

CKCALL: LXI     H,MYCALL
        LXI     D,RDSTCAL
        MVI     B,6
        JMP     COMPARE$


;
;PRINTS A STRING IN MEMORY POINTED TO BY HL
;B HAS LENGTH.

PRNMEM: MOV     C,M
        CALL    CONOUT
        INX     H
        DCR     B
        JNZ     PRNMEM
        RET


;
;SENDS A CHARACTER IN REG C TO CONSOLE
;

CONOUT: PUSH    PSW
        PUSH    B
        PUSH    D
        PUSH    H
        MOV     E,C
        MVI     C,2
        CALL    BDOS
        POP     H
        POP     D
        POP     B
        POP     PSW
        RET

;CHECK CONSOLE STATUS
;RETURN A=ZERO IF NO KEY PRESSED
;
CONST:  PUSH    B
        PUSH    D
        PUSH    H
        MVI     C,11            ;CP/M CONSOLE STATUS CODE
        CALL    BDOS
        POP     H
        POP     D
        POP     B
        RET                     ;A=FF IF KEY PRESSED
;
;
;GETS A CHARACTER FROM CONSOLE
;A=CHAR.
;
CONIN:  PUSH    B
        PUSH    D
        PUSH    H
        MVI     C,1             ;READ CONSOLE CPM COMMAND
        CALL    BDOS
        POP     H
        POP     D
        POP     B
        RET                     ;A=CHAR
;
;
;PRINT A STRING POINTED TO BY THE CONTENTS OF THE
;TOP OF STACK. <CR> OR @ TERMINATES THE STRING.

PRINT:  XTHL
        PUSH    PSW
        PUSH    B
PRN1:   MOV     A,M
        INX     H
        CPI     '@'
        JZ      PRN2
        MOV     C,A
        CALL    CONOUT
        CPI     CR
        JNZ     PRN1
        CALL    PRINT
        DB      LF,'@'
PRN2:   POP     B
        POP     PSW
        XTHL
        RET


;CONVERTS BINARY NUMBER IN HL TO DECIMAL ASCII
;AND SENDS IT TO CONSOLE

BXDEC:  SHLD    N               ;SAVE NUMBER
        LXI     H,P10TAB        ;POINT TO POWER OF 10 TABLE
BX0:    MOV     E,M
        INX     H
        MOV     D,M             ;POWER OF 10
        INX     H
        PUSH    H
        LHLD    N
        MVI     C,'0'
BX1:    DAD     D               ;SUBTRACT POWER OF TEN
        JNC     BX2
        INR     C
        JMP     BX1             ;LOOP TILL IT GOES NEG.
BX2:    MOV     A,E
        CMA                     ;TWOS COMPLIMENT
        MOV     E,A
        MOV     A,D
        CMA
        MOV     D,A
        INX     D
        DAD     D               ;RESTORE TO +
        SHLD    N               ;SAVE IT
        CALL    CONOUT
        POP     H
        MVI     A,1
        CMP     E               ;SEE IF WE ARE DONE
        JNZ     BX0             ;NO, DO AGAIN
        RET
;
;
P10TAB: DW      -10000
        DW      -1000
        DW      -100
        DW      -10
        DW      -1

;
;
        

;THIS TELLS THE USER THAT THERE WAS NO RESPONSE

NORPLY: LXI     D,NOTHOME+2
        LXI     H,TDSTCAL
        MVI     B,6
        CALL    MOVE
        LXI     D,NOTHOME
        MVI     C,9
        CALL    BDOS
        RET

NOTHOME:
        DB      CR,LF,'       DOES NOT RESPOND',CR,LF,'$'

;GENERAL PURPOSE MEMORY TO MEMORY MOVE SUBROUTINE
;ENTER WITH HL POINTING TO SOURCE, DE POINTING TO
;DESTINATION AND B HAS THE LENGTH (0..255, 0=256 BYTES)
        
MOVE:   MOV     A,M
        STAX    D
        INX     H
        INX     D
        DCR     B
        JNZ     MOVE
        RET
;
;ENTER THIS DELAY ROUTINE WITH DE CONTAINING
;THE DELAY VALUE IN MILLISECONDS.

DELAY:  CALL    WAIT1           ;WAIT 1MS * DE
        DCX     D
        MOV     A,E
        ORA     D
        JNZ     DELAY
        RET


;THIS COMPUTES THE CRC FOR TRANSMISSION

TXCRC:  LXI     H,0
        SHLD    CRCREG          ;CLEAR CRC
        LDA     TLEN
        MOV     C,A
        CALL    CALCRC          ;COMPUTE CRC FOR LENGTH FIELD
        LDA     TLEN+1
        MOV     B,A             ;BC HAS LENGTH NOW
        CALL    CALCRC
        LXI     H,TDSTCAL       ;SKIP OVER CRC FIELD
        DCX     B
        DCX     B               ;ADJUST LENGTH
TXCRC1: MOV     A,M             ;GET A BYTE FROM BUFFER
        CALL    CALCRC          ;COMPUTE CRC ON IT
        INX     H               ;ADVANCE BUFFER POINTER
        DCX     B               ;COUNT THE BYTES
        MOV     A,C
        ORA     B
        JNZ     TXCRC1          ;LOOP UNTIL COUNTER IS ZERO
        LHLD    CRCREG          ;GET COMPLETE CRC
        SHLD    TCRC            ;PUT IT IN THE BUFFER
        RET

;COMPUTE CRC ON RECEIVE BUFFER CONTENTS
;RETURNS A=0 IF OK

RXCRC:  LHLD    RLEN            ;GET LENGTH
        MOV     C,L
        MOV     B,H             ;BC IS COUNTER
        LXI     H,0
        SHLD    CRCREG          ;CLEAR CRC
        MOV     A,C             ;COMPUTE CRC ON LENGTH WORD
        CALL    CALCRC
        MOV     A,B
        CALL    CALCRC
        LXI     H,RDSTCAL       ;HL POINT TO BUFFER & SKIP CRC FIELD
        DCX     B
        DCX     B               ;ADJUST COUNT
RXCRC1: MOV     A,M             ;GET A BYTE
        CALL    CALCRC          ;DO CRC CALC.
        INX     H
        DCX     B
        MOV     A,C
        ORA     B
        JNZ     RXCRC1          ;LOOP UNTIL DONE
        LHLD    CRCREG          ;GET COMPLETE CRC
        XCHG                    ;TO DE
        LHLD    RCRC            ;GET RECEIVED CRC
        MOV     A,E
        SUB     L
        RNZ                     ;RETURN NON ZERO IF BAD CRC
        MOV     A,D
        SUB     H
        RET

;
;THIS COMPUTES THE CRC FROM VALUES IN REGISTER A AND
;MEMORY LOCATION "CRCREG".

CALCRC: PUSH    B
        PUSH    H
        MOV     B,A             ;SAVE BYTE
        MVI     C,8             ;BIT COUNTER
CALC1:  ANI     80H             ;KEEP MSB
        LHLD    CRCREG          ;GET CRC
        XRA     H
        MOV     H,A             ;XOR CRC INTO DATA
        DAD     H               ;SHIFT CRC LEFT
        JNC     CALC2
        MOV     A,H
        XRI     CRCPLY SHR 8    ; HL = HL XOR CRC POLYNOMIAL
        MOV     H,A
        MOV     A,L
        XRI     CRCPLY AND 255
        MOV     L,A
CALC2:  SHLD    CRCREG          ;SAVE RESULT
        DCR     C
        JZ      CALC3
        MOV     A,B             ;GET DATA
        ADD     A               ;SHIFT IT LEFT 1 BIT
        MOV     B,A
        JMP     CALC1           ;DO IT AGAIN
CALC3:  POP     H
        POP     B
        RET
;
;------------------------------------------------------------;
;
;THIS IS A CW ID SUBROUTINE PACKAGE


;HERE IS THE ASCII TO CW TRANSLATE TABLE

ASCII$CW:
        DB      5+10010000B             ; / -..-.
        DB      5+11111000B             ;ZERO
        DB      5+01111000B     ;1
        DB      5+00111000B     ;2
        DB      5+00011000B     ;3
        DB      5+00001000B     ;4
        DB      5+00000000B     ;5
        DB      5+10000000B     ;6
        DB      5+11000000B     ;7
        DB      5+11100000B     ;8
        DB      5+11110000B     ;9
        DB      0               ;:  NOT USED
        DB      0               ; ; NOT USED
        DB      0               ; < NOT USED
        DB      0               ; = NOT USED
        DB      0               ; > NOT USED
        DB      0               ; ? NOT USED
        DB      0               ; @ NOT USED
        DB      2+01000000B     ; A  .-
        DB      4+10000000B     ;B -...
        DB      4+10100000B     ; C -.-.
        DB      3+10000000B     ; D -..
        DB      1+00000000B     ; E .
        DB      4+00100000B     ; F ..-.
        DB      3+11000000B     ;G --.
        DB      4+00000000B     ;H
        DB      2+00000000B     ; I ..
        DB      4+01110000B     ; J .---
        DB      3+10100000B     ; K -.-
        DB      4+01000000B     ; L .-..
        DB      2+11000000B     ; M --
        DB      2+10000000B     ; N -.
        DB      3+11100000B     ; O ---
        DB      4+01100000B     ; P .--.
        DB      4+11010000B     ; Q --.-
        DB      3+01000000B     ; R .-.
        DB      3+00000000B     ; S ...
        DB      1+10000000B     ; T -
        DB      3+00100000B     ; U ..-
        DB      4+00010000B     ; V ...-
        DB      3+01100000B     ; W .--
        DB      4+10010000B     ; X -..-
        DB      4+10110000B     ; Y -.--
        DB      4+11000000B     ; Z --..



        ;THIS IS THE END OF THE TABLE


ID$STRING:      DS      20      ;RESERVE 20 BYTES FOR ID STRING
DE$STR:         DB      ' DE '

CWID:
        LXI     H,ID$INH        ;ID INHIBIT FLAG
        MOV     A,M
        MVI     M,0             ;CLEAR IT
        ORA     A               ;TEST IT
        RNZ                     ;DONT ID THIS TIME IF TRUE
        LXI     H,TDSTCAL       ;GET DESTINATION CALL
        LXI     D,ID$STRING
        MVI     B,6
        CALL    MOVE

        LXI     H,DE$STR        ;POINT TO "DE" STRING
        MVI     B,4
        CALL    MOVE

        LXI     H,MYCALL        ;PUT OUR CALL IN
        MVI     B,6
        CALL    MOVE
        XCHG
        MVI     M,' '           ;TRAILING SPACE
        INX     H
        MVI     M,0             ;NULL TERMINATES STRING

        CALL    INITX           ;INIT. FOR TRANSMITTING
        CALL    TONEOFF
        LXI     D,200           ;DELAY 200 MS AFTER KEY DOWN
        CALL    RFON            ;KEY TRANSMITTER

        LXI     H,ID$STRING
CWID1:  MOV     A,M             ;GET A ASCII CHAR.
        ORA     A               ;NULL?
        JZ      RFOFF           ;QUIT IF NULL
        CPI     '0'
        JC      CWID2           ;IGNORE INVALID CHAR
        PUSH    H
        MOV     C,A
        CALL    SEND$CW$CHAR    ;CONVERT TO CW AND SEND
        POP     H
CWID2:  INX     H
        JMP     CWID1           ;LOOP TILL DONE



SEND$CW$CHAR:
        PUSH    B
        CALL    TONEOFF
        MVI     C,2
        CALL    DELAYX          ;WAIT 2 DOT TIMES
        POP     B               ;GET ASCII CHARACTER BACK
        LXI     H,ASCII$CW-2FH  ;POINT TO CONVERSION TABLE
        MOV     A,C
        CPI     20H             ;TEST FOR SPACE
        JNZ     CW1
        MVI     C,7             ;7 DOT TIMES FOR SPACE
        JMP     DELAYX
CW1:    MVI     B,0
        DAD     B               ;INDEX INTO TABLE
        MOV     A,M             ;GET CW CODE
        ANI     7               ;KEEP COUNT
        RZ                      ;RETURN IF ZERO COUNT
        MOV     B,A             ;PUT COUNT IN REG. B
        MOV     A,M             ;GET CODE AGAIN
CW2:    ADD     A               ;SHIFT MSB INTO CARRY
        MVI     E,1             ;ASSUME A DOT
        JNC     CW3             ;JUMP IF DOT
        MVI     E,3             ;ELSE SET FOR DASH
CW3:    PUSH    B               ;SAVE COUNT
        PUSH    PSW             ;SAVE CODE
        CALL    TONEON          ;TURN ON TONE
        MOV     C,E             ;GET TIME
        CALL    DELAYX
        CALL    TONEOFF         ; TONE OFF
        MVI     C,1
        CALL    DELAYX          ;WAIT 1 DOT TIME
        POP     PSW             ;RESTORE CODE
        POP     B               ;RESTORE COUNT
        DCR     B               ;COUNT DOWN
        JNZ     CW2             ;LOOP TILL FINISHED
        RET

;THIS TIMES 1 DIT.

DELAYX: MOV     A,C
        ORA     A
        RZ
        PUSH    B
        PUSH    D
DLY1:   LXI     D,50            ;50 MS DELAY
        CALL    DELAY
        DCR     C
        JNZ     DLY1
        POP     D
        POP     B
        RET

;END OF CW ID ROUTINES
;--------------------------------------------------------;
;
;
        DSEG                    ;BEGIN DATA SEGMENT

;
;THIS IS THE VARIABLE STORAGE AREA




CRCREG: DS      2               ;USED BY CRC ROUTINE
N:      DS      2               ;USED BY BXDEC ROUTINE
DATAPTR:DS      2
DATACNT:DS      2
RETRYS: DS      1               ;RETRY COUNTER
SEQNUM: DS      2               ;LOCAL COUNT OF RECEIVED PACKETS
DIRFLAG:DS      1               ;1=DIRECTORY 0=NORMAL FILE
ID$INH: DS      1               ;1=INHIBIT NEXT ID
LEADBB: DS      4               ;LEADER BUFFER BEGINNING
LEADBE: DS      1               ;LEADER BUFFER END
TIME:   DS      2               ;USED FOR TIMEOUTS
TEMPTIME: DS    2

;SCRATCH PAD PACKET HEADER

BUFFR:  DS      5               ;LEADER
LEN:    DS      2               ;TOTAL LENGTH OF MESSAGE
CRC:    DS      2               ;CRC BYTES
DSTCAL: DS      6               ;DESTINATION CALL SIGN
DSTLOC: DS      1               ;DESTINATION LOCATION CODE
DSTRPT: DS      1               ;DESTINATION REPEATER (0=DIRECT)
SRCCAL: DS      6               ;SOURCE CALL SIGN
SRCLOC: DS      1               ;SOURCE LOCATION CODE
SRCRPT: DS      1               ;SOURCE REPEATER (0=DIRECT)
PTYPE:  DS      1               ; PACKET TYPE
STITLE: DS      12              ;NAME OF PACKET GROUP (CP/M FILE NAME)
PACNUM: DS      2               ;PACKET NUMBER

;TRANSMIT PACKET BUFFER

TBUFFR: DS      5               ;LEADER
TLEN:   DS      2               ;TOTAL LENGTH OF MESSAGE
TCRC:   DS      2               ;CRC BYTES
TDSTCAL:DS      6               ;DESTINATION CALL SIGN
TDSTLOC:DS      1               ;DESTINATION LOCATION CODE
TDSTRPT:DS      1               ;DESTINATION REPEATER (0=DIRECT)
TSRCCAL:DS      6               ;SOURCE CALL SIGN
TSRCLOC:DS      1               ;SOURCE LOCATION CODE
TSRCRPT:DS      1               ;SOURCE REPEATER (0=DIRECT)
TPTYPE: DS      1               ; PACKET TYPE
TTITLE: DS      12              ;NAME OF PACKET GROUP (CP/M FILE NAME)
TPACNUM:DS      2               ;PACKET NUMBER
TDATA:  DS      1024            ;THIS IS THE DATA


;RECEIVE PACKET BUFFER
;
RBUFFR: DS      5               ;LEADER
RLEN:   DS      2               ;LENGTH OF RECEIVED PACKET
RCRC:   DS      2               ;RECEIVED CRC BYTES
RDSTCAL:DS      6               ;DESTINATION CALL SIGN
RDSTLOC:DS      1               ;DESTINATION LOCATION CODE
RDSTRPT:DS      1               ;DESTINATION REPEATER (0=DIRECT)
RSRCCAL:DS      6               ;SOURCE CALL SIGN
RSCRLOC:DS      1               ;SOURCE LOCATION CODE
RSCRRPT:DS      1               ;SOURCE REPEATER (0=DIRECT)
RPTYPE: DS      1               ;PACKET  TYPE
RTITLE: DS      12              ;NAME OF PACKET GROUP (FILE NAME)
RPACNUM:DS      2               ;PACKET NUMBER
RDATA:  DS      1024            ;RECEIVED DATA
;
;
;
;
INBUFFER:       DS      1024    ;FILE READ BUFFER
OUTBUFFER:      DS      1024    ;FILE OUTPUT BUFFER

        END
