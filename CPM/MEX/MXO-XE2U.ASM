;     Title  'MEX Overlay for the XEROX 820-II Computer Version 2.0'
;
;
REV     EQU     20              ;overlay revision level
;  
;  MEX Overlay for XEROX 820-II  and XEROX 820-I Computers with 
;  external modems. The following table
;  outlines the SET command options:
;
;                                          Available for
;       SET Command                           
;
;       DELAY <n> (seconds)                     YES
;       BAUD <rate>                             YES
;       ORIG (originate mode)                   YES
;       ANSWER  (mode)                          YES
;       TONE (dialing)                          YES
;       PULSE (dialing)                         YES
;       MONITOR (speaker on)                    YES
;       QUIET (speaker off)                     YES
;       PARITY (Odd, Even, None)                YES
;       STOPBITS (1, 1.5, 2)                    YES
;       LENGTH (5, 6, 7, or 8)                  YES
;       
;
;............
;
;  This overlay includes the smartmodem dialing routine from
;  MXO-SM10.ASM by Ron Fowler which has been slightly modified
;  to allow programmable delay for answer.  (Note that this is
;  different from the "ATS7=nn".).  Also, see the note at the
;  ANS: label for the answer mode with the internal modem.
;
;  This overlay is intended to be fully compatible with the
;  MEX structure and should be readily upward compatible with
;  the predicted MEX 2.0.
;
;  Calling conventions for the various overlay entry points
;  are detailed more fully in the PMMI overlay (MXO-PMxx.ASM,
;  where xx=revision number).
;
;  History:
;
;  05/30/85     Added equates for 300/1200/ or USR2400 to initialize the
;		modem properly and take advantage of all available codes
;		from the different modems. Added auto baud set for 1200
;		baud fall-back when using a USR2400. Ade equates for 
;		ANCHOR 1200 for it's special ideocyncracies. 
;						Russ Pencin
;
;  05/28/85     Added the NOPAR and PARITY Mex calls. A few minor cleanups.
;                                                     Ron Carter
;  05/14/85     Appropriated all of the code from the MXO-KP28 overlay.
;               Removed code pertaining to internal modems. Added code
;               to support the U.S. Robotics Courier 2400 extended responce
;               messages ( enabled by equate). This overlay will work on
;               both 820-I and 820-II                 Russ Pencin TDC
;
;  Credits:
;
;  All of the individuals who perfected the KP28 overlay.
;  M7KP-1 overlay structure by Irv Hoff
;  Smartmodem dialing routine by Ron Fowler
;
;  Bug Reports:
;
;  Would appreciate a note of any problems be left on the
;  THE Dallas Connection RCP/M (214) 238-1016 (300/1200/2400)
;
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
TAB     EQU     9
;
;  PLEASE SET ONLY ONE OF THE FOLLOWING THREE EQUATES TO YES !
;
USR2400 EQU     NO            ;Yes, if using A U.S.Robotics 2400
B1200   EQU	NO 	       ;Yes, if using a Hayes 1200 compatible
B300    EQU     NO             ;Yes, if using a Hayes 300 compatible
ANCHOR  EQU     YES	       ;Yes, if using an Anchor XII modem
;
    IF ANCHOR
DIALAB  EQU     041H            ;special Anchor Modem Dial Abort
    ENDIF
;
    IF NOT ANCHOR
DIALAB  EQU     CR              ;Hayes and USR use CR to abort dial
    ENDIF
;
;
; XEROX 820-II port definitions
;
EXPORT  EQU     04H             ;base external port
EXTCT1  EQU     EXPORT+2        ;external modem status port
EXTDAT  EQU     EXPORT          ;external modem data port
BAUDRP  EQU     00H             ;external modem baud rate port
;
; XEROX 820-II bit definitions
;
MDRCVB  EQU     01H             ;modem receive bit (DAV)
MDRCVR  EQU     01H             ;modem receive ready
MDSNDB  EQU     04H             ;modem send bit
MDSNDR  EQU     04H             ;modem send ready bit
;
; MEX Service Processor
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
CONOUT  EQU     2               ;simulated BDOS function 2: console char out
PRINT   EQU     9               ;simulated BDOS function 9: print string
INBUF   EQU     10              ;input buffer, same structure as BDOS 10
;
;
;
        ORG     TPA             ;we begin
;
        DS      3               ;MEX has a JMP START here
;
        DS      2               ;not used by MEX
TPULSE: DB      'T'             ;T=touch, P=pulse (Used by this overlay)
CLOCK:  DB      40              ;clock speed x .1, up to 25.5 mhz.
;
   IF B300
MSPEED: DB      1               ;sets display time for sending a file
   ENDIF                        ;0=110  1=300  2=450  3=600  4=710             	               		;5=1200 6=2400 7=4800 8=9600 9=19200
;
   IF B1200 OR ANCHOR
MSPEED: DB      5		;SET 1200 BAUD
   ENDIF         
;
   IF USR2400
MSPEED: DB      6		;SET 2400 BAUD
   ENDIF
;
BYTDLY: DB      9               ;default time to send character in
                                ;terminal mode file transfer (0-9)
                                ;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:  DB      9               ;end-of-line delay after CRLF in terminal
                                ;mode file transfer for slow BBS systems
                                ;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS: DB      4               ;number of directory columns
SETFL:  DB      YES             ;yes=user-defined SET command
SCRTST: DB      YES             ;yes=if home cursor and clear screen
                                ;routine at CLRSCRN
        DB      0               ;was once ACKNAK, now spare
BAKFLG: DB      YES             ;yes=make .BAK file
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
XOFTST: DB      YES             ;yes=allow testing of XOFF from remote
                                ;while sending a file in terminal mode
XONWT:  DB      NO              ;yes=wait for XON after sending CR while
                                ;transmitting a file in terminal mode   
TOGXOF: DB      YES             ;yes=allow toggling of XOFF testing
IGNCTL: DB      NO              ;yes=do not send control characters
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
        DS      2               ;not used
;
; Low-level modem I/O routines.
;
INCTL1: JMP     INC             ;in modem control port
        DB      0,0,0,0,0,0,0   ;spares if needed for non-PMMI
;
OTDATA: JMP     OUTD            ;out modem data port
        DB      0,0,0,0,0,0,0   ;spares if needed for non=PMMI
;
INPORT: JMP     IND             ;in modem data port
        DB      0,0,0,0,0,0,0   ;spares if needed for non-PMMI
;
; Bit-test routines. 
;
MASKR:  ANI MDRCVB ! RET        ;bit to test for receive ready
TESTR:  CPI MDRCVR ! RET        ;value of receive bit when ready
MASKS:  ANI MDSNDB ! RET        ;bit to test for send ready
TESTS:  CPI MDSNDR ! RET        ;value of send bit when ready
;
        DS      12
;
LOGON:  DS      2               ;needed for MDM compat, not ref'd by MEX
DIALV:  JMP     DIAL
DISCV:  JMP     DISCON
GOODBV: JMP     GOODBYE         ;called before exit to CP/M
INMODV: JMP     NITMOD          ;initialization. Called at cold-start
NEWBDV: JMP     PBAUD           ;set baud rate
NOPARV: JMP     NOPAR           ;set modem for no-parity
PARITV: JMP     PARITY          ;set modem parity
SETUPV: JMP     SETCMD          ;SET cmd: jump to a RET if you don't write SET
SPMENV: DS      3               ;not used with MEX
VERSNV: JMP     SYSVER          ;Overlay's voice in the sign-on message
BREAKV: JMP     SBREAK          ;send a break
;
; MDM calls supported in MEX 1.0 but not recommended for use.
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
; end of fixed area
;
;------------------------------------------------------------
;
; Low level modem routine area
;
INC:    MVI     A,10H
        OUT     EXTCT1
        IN      EXTCT1
        RET
;
IND:    IN      EXTDAT
        ANI     07FH
MASK    EQU     $-1
        RET
;
OUTD:   OUT     EXTDAT
        RET
;
; Print out the overlay version
;
SYSVER:   CALL  MILP
          DB    CR,LF
          DB    1AH,1BH,')XEROX 820-II or -I with extended Set-up.'
          DB    CR,LF,'Communicating '
 ;
   IF USR2400
          DB    '@2400 baud----- Version '
      ENDIF
;
    IF B1200 OR ANCHOR
          DB    '@1200 baud----- Version '
      ENDIF
;
    IF B300
          DB    '@300 baud------ Version '
    ENDIF
;
          DB    REV/10+'0'
          DB    '.'
          DB    REV MOD 10+'0'
          DB    1BH,'(',CR,LF
;
    IF USR2400
          DB    'Configured for U.S.Robotics Courier 2400',CR,LF
    ENDIF
;
    IF B1200
          DB    'Configured for Hayes compatible 1200 baud modem',CR,LF
    ENDIF
;
    IF B300
	  DB    'Configured for Hayes compatible 300 baud modem',CR,LF
    ENDIF
;
    IF ANCHOR
          DB	'Configured for Anchor Signalman Mark XII',CR,LF
    ENDIF
;
          DB    0
          RET
;
; Break, disconnect and goodbye routines
;
;
SBREAK:   MVI   A,5
          OUT   EXTCT1
          LDA   REG5
          ORI   10H             ;SEND A BREAK TONE              
          JMP   GOODBYE1
;
    IF NOT ANCHOR
DISCON:   MVI   A,5
          OUT   EXTCT1          ;SEND TO THE STATUS PORT
          LDA   REG5
          ANI   68H             ;TURN OFF DTR
    ENDIF
;
    IF ANCHOR
DISCON:   MVI	B,20	
	  MVI	C,TIMER		;wait 2 seconds
	  CALL	MEX
	  LXI	H,SMATN		;send '+++'
	  CALL	SMSEND
	  MVI	B,40            ;wait 4 more seconds (Anchor is slow)
	  MVI	C,TIMER
	  CALL	MEX
	  LXI	H,SMDISC	;send 'ATH'
	  CALL	SMSEND
	  MVI	B,1		;wait 1 second
	  MVI	C,TIMER
	  CALL	MEX
	  RET
    ENDIF
;
;
GOODBYE1: OUT   EXTCT1
          MVI   B,3             ;DELAY 300 MS.
          MVI   C,TIMER
          CALL  MEX
GOODBYE:  MVI   A,5
          OUT   EXTCT1
          LDA   REG5            ;RESTORE TO NORMAL
          OUT   EXTCT1
          RET
;
; Initialize RS-232 port,  default modes.
;
NITMOD:   CALL  INC             ;SEE IF MODEM IS CONNECTED, I.E., RETURNING
          ANI   08H             ;   TO ACTIVE MODEM FROM CPM
          RNZ                   ;SKIP IF CONNECTED
          CALL  NITSIO          ;INITIALIZE EXTERNAL RS-232 PORT
;
NITMOD2:  LDA   DFBAUD          ;SET DEFAULT BAUD RATE
          OUT   BAUDRP          ;SEND TO BAUD GENERATOR
          LDA   MONFLG          ;GET MONITOR DEFAULT
          ORA   A
          MVI   A,'0'           ;SPEAKER OFF
          JZ    NITMOD4
          MVI   A,'1'           ;SPEAKER ON
NITMOD4:  STA   SMINIT+3        ;PUT IT IN SMINIT STRING
          LDA   ANSFLG          ;GET MODE DEFAULT
          ORA   A
          MVI   A,'0'           ;ORIGINATE
          JZ    NITMOD5
          MVI   A,'1'           ;ANSWER
NITMOD5:  STA   SMINIT+8        ;PUT IT IN SMINIT STRING
          LXI   H,SMINIT
SINIT:    CALL  SMSEND          ;SEND THE INIT STRING
SMTLP1:   MVI   C,INMDM         ;WAIT FOR MODEM RESPONSE
          CALL  MEX
          JNC   SMTLP1          ;EAT EVERYTHING UNTIL SILENCE FOR
          RET                   ; 100 MSEC
;
;       Initialize the Zilog SIO chip
;
NITSIO:   MVI   A,00H           ;Select reg. 0
          OUT   EXTCT1
          LDA   REG0            ;Command byte
          OUT   EXTCT1
          MVI   A,04H           ;Select reg. 4
          OUT   EXTCT1
          LDA   REG4            ;Receive/transmit control byte
          OUT   EXTCT1
          MVI   A,03H           ;Select reg. 3
          OUT   EXTCT1
          LDA   REG3            ;Receiver logic byte
          OUT   EXTCT1
          MVI   A,05H           ;Select reg. 5
          OUT   EXTCT1
          LDA   REG5            ;Transmitter logic byte
          OUT   EXTCT1
          RET
;
; Set to mask parity from input
;
NOPAR:    MVI   A,07FH
          STA   MASK
          RET
;
; Set to not mask parity from input
;
PARITY:   MVI   A,0FFH
          STA   MASK
          RET
;
; Set command processor
;
SETCMD:   MVI   C,SBLANK        ;ANY ARGUMENTS?
          CALL  MEX
          JC    SETSHO          ;IF NOT, DISPLAY DEFAULT(S)
          LXI   D,ECMDTBL
SETCMD1:  MVI   C,LOOKUP
          CALL  MEX             ;PARSE THE ARGUMENT
          PUSH  H               ;SAVE ANY PARSED ARGUMENTS ON STACK
          RNC                   ;IF WE HAVE ONE, RETURN TO IT
          POP   H               ;OOPS, INPUT NOT FOUND IN TABLE
SETERR:   LXI   D,SETEMS
          MVI   C,PRINT
          CALL  MEX
          RET
SETEMS:   DB    CR,LF,07H,'SET command error',CR,LF,'$'
;
; Argument table
;
ECMDTBL:  DB    '?'+80H                 ; HELP
          DW    SETHELP
          DB    'ORI','G'+80H           ; ORIGINATE MODE
          DW    ORIG
          DB    'ANSWE','R'+80H         ; ANSWER MODE
          DW    ANS
          DB    'TON','E'+80H           ; TONE DIALING
          DW    STTONE
          DB    'PULS','E'+80H          ; PULSE DIALING
          DW    STPULSE
          DB    'MONITO','R'+80H        ; MONITOR ON
          DW    MONIT
          DB    'QUIE','T'+80H          ; MONITOR OFF
          DW    QUIET
          DB    'BAU','D'+80H           ; SET BAUD
          DW    STBAUD
          DB    'DELA','Y'+80H          ; SET DELAY
          DW    DELAY
          DB    'PARIT','Y'+80H         ; SET PARITY
          DW    STPRTY
          DB    'STOPBIT','S'+80H       ; SET STOPBITS
          DW    STSTOP
          DB    'LENGT','H'+80H         ; SET LENGTH
          DW    STBITS
          DB    0                       ;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:   CALL  MILP
          DB    CR,LF
          DB    1AH,'Current SET values:',CR,LF,0
          CALL  CRLF
          CALL  MODEMSH
          CALL  CRLF
          CALL  MDSHOW
          CALL  CRLF
          CALL  TPSHOW
          CALL  CRLF
          CALL  BDSHOW
          CALL  CRLF
          CALL  DLSHOW
          CALL  CRLF
          CALL  CRLF
          CALL  SHPRTY
          CALL  CRLF
          CALL  SHSTOP
          CALL  CRLF
          CALL  SHBITS
          CALL  CRLF
          CALL  MONSHO
          CALL  CRLF
          CALL  CRLF
          RET
;
; "SET ?" processor
;
SETHELP:  CALL  MILP
          DB    1AH,CR,LF,'SET ORIG      - Originate Mode'
          DB    CR,LF,'SET ANSWER    - Answer Mode'
          DB    CR,LF,'SET TONE      - Use Tone Dialing'
          DB    CR,LF,'SET PULSE     - Use Pulse Dialing'
          DB    CR,LF,'SET DELAY     - <N> seconds to wait for answer'
          DB    CR,LF,'SET QUIET     - Disable Speaker'
          DB    CR,LF,'SET MONITOR   - Enable Speaker'
          DB    CR,LF,'SET PARITY    - OFF <or> EVEN <or> ODD'
          DB    CR,LF,'SET STOPBITS  - 1 <or> 1.5 <or> 2'
          DB    CR,LF,'SET LENGTH    - 5 <or> 6 <or> 7 <or> 8'
          DB    CR,LF,'SET BAUD      - 110, 300, 600, 1200, 2400, '
          DB    '4800, 9600, 19200'
          DB    CR,LF,CR,LF,0
          RET
;
; "SET MODEM" processor
;
EXTM:     EQU   $
MODEMSH:  CALL  MILP
          DB    'External Modem',0
          RET
;
; "SET BAUD" processor
;
STBAUD:   MVI   C,BDPARS        ;FUNCTION CODE: PARSE A BAUDRATE
          CALL  MEX             ;LET MEX LOOK UP CODE
          JC    SETERR          ;JUMP IF INVALID CODE
          CALL  PBAUD           ;NO, TRY TO SET IT
          JC    SETERR          ;IF NOT ONE OF OURS, BOMB OUT
BDSHOW:   LDA   MSPEED          ;GET CURRENT BAUD RATE
          MVI   C,PRBAUD        ;LET MEX PRINT IT
          CALL  MEX
          RET 
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported.
;
PBAUD:    PUSH  H               ;DON'T ALTER ANYBODY
          PUSH  D
          PUSH  B
          MOV   E,A             ;MSPEED CODE TO DE
          MVI   D,0
          LXI   H,BAUDTB        ;OFFSET INTO TABLE
          DAD   D
          MOV   A,M             ;FETCH CODE
          ORA   A               ;0 MEANS UNSUPPORTED CODE
          STC                   ;PREP CARRY IN CASE UNSUPPORTED
          JZ    PBEXIT          ;EXIT IF BAD
          PUSH  PSW             ;NO, SET THE RATE
          MVI   A,47H
          OUT   BAUDRP
          POP   PSW
          OUT   BAUDRP
          STA   DFBAUD          ;SAVE CURRENT RATE
          MOV   A,E             ;GET MSPEED CODE BACK
          STA   MSPEED          ;SET IT
          ORA   A               ;RETURN NO ERRORS
PBEXIT:   POP   B
          POP   D
          POP   H
          RET
;
BAUDTB:	  DB	02H		;110
	  DB	05H		;300
	  DB	0		;450 (not supported)
	  DB	06H		;600
	  DB	0		;710 (not supported)
	  DB	07H		;1200
	  DB	0AH		;2400
	  DB	0CH		;4800
	  DB	0EH		;9600
	  DB	0FH		;19200 
;
SET12:	  PUSH  PSW
	  PUSH	H		;DON'T ALTER ANYBODY
	  PUSH	D
	  PUSH 	B
	  MVI	A,47H
	  OUT	BAUDRP
          MVI   A,07H	  
	  OUT	BAUDRP
	  STA	DFBAUD		;SAVE CURRENT RATE
	  MVI	A,05H		;GET MSPEED CODE BACK
	  STA	MSPEED		;SET IT
	  ORA	A		;RETURN NO ERRORS
	  POP	B
	  POP	D
	  POP	H
	  POP   PSW
	  RET
;
; Set mode processor
;
ORIG:     XRA   A
          STA   ANSFLG          ;SET ORIG FLAG
          LXI   H,SMO           ;SEND OUT ATS0=0
          CALL  SINIT
          JMP   MDSHOW
ANS:      MVI   A,0FFH
          STA   ANSFLG          ;SET ANS FLAG
          LXI   H,SMA           ;SEND OUT ATS0=1
          CALL  SINIT
;
;
MDSHOW:   LDA   ANSFLG
          ORA   A
          JZ    MDORIG
MDSHW1:   CALL  MILP
          DB    'Answer mode',0
          RET
MDORIG:   CALL  MILP
          DB    'Originate mode',0
          RET
SMO:      DB    'ATS0=0',CR,0
SMA:      DB    'ATS0=1',CR,0
;
; Monitor control processor
;
QUIET:    XRA   A
          STA   MONFLG
          LXI   H,SMQT
          CALL  SINIT
          JMP   MONSHO
MONIT:    MVI   A,0FFH
          STA   MONFLG
          LXI   H,SMMON
          CALL  SINIT
MONSHO:   LDA   MONFLG
          ORA   A
          JZ    MONOFF
          CALL  MILP
          DB    'Monitor Speaker: On',0
          RET
MONOFF:   CALL  MILP
          DB    'Monitor Speaker: Off',0
          RET
SMQT:     DB    'ATM0',CR,0
SMMON:    DB    'ATM1',CR,0
;
; Set dial processor
;
STTONE:   MVI   B,'T'
          JMP   SDIAL1
STPULSE:  MVI   B,'P'
SDIAL1:   LDA   TPULSE
          CPI   B
          JZ    TPSHOW
          MOV   A,B
          STA   TPULSE
TPSHOW:   LDA   TPULSE
          CPI   'T'
          JZ    TPTONE
          CALL  MILP
          DB    'Pulse Dialing',0
          RET
TPTONE:   CALL  MILP
          DB    'Tone Dialing',0          
          RET
;
; Set delay processor
;
DELAY:    MVI   C,EVALA
          CALL  MEX
          MOV   A,H
          ORA   A
          JNZ   SETERR
          MOV   A,L
          STA   NDELAY
DLSHOW:   CALL  MILP
          DB    'Answer Delay is ',0
          LDA   NDELAY
          MOV   L,A
          MVI   H,0
          MVI   C,DECOUT
          CALL  MEX
          CALL  MILP
          DB    ' seconds',0
          RET
;
;       SET PARITY command: reset transmit/receive parity
;
;               Parity is controlled by bits 0 and 1 of
;               the byte sent to the SIO write-register
;               4 as follows:
;
;                  Parity       Bit 1      Bit 0
;                    Off          -          0
;                    Odd          0          1
;                    Even         1          1
;
STPRTY:   MVI   C,SBLANK        ;check for parity code
          CALL  MEX             ;
          JC    SETERR          ;if none, print error
          LXI   D,PARTBL        ;check for proper syntax
          MVI   C,LOOKUP
          CALL  MEX
          PUSH  H               ;match found, go do it!
          RNC                   ;
          POP   H               ;no match: fix stack and
          JMP   SETERR          ;  print error
;
PROFF:    LDA   REG4            ;get register 4 byte
          ANI   0FEH            ;reset bit 0
          JMP   PARTB1          ;
PREVEN:   LDA   REG4            ;
          ORI   003H            ;set bits 0 & 1
          JMP   PARTB1          ;
PRODD:    LDA   REG4            ;
          ORI   001H            ;set bit 0
          ANI   0FDH            ;reset bit 1
PARTB1:   STA   REG4            ;
          CALL  NITSIO          ;re-initialize the USART
          CALL  SHPRTY          ;print the result
          RET                   ;
SHPRTY:   CALL  MILP            ;display parity
          DB    'Parity:  ',TAB,' ',0
          LDA   REG4            ;
          ANI   001H            ;test bit 0
          CPI   0               ;if bit0=0 then parity off
          JNZ   SHPRT1          ;
          CALL  MILP            ;
          DB    'Off',0         ;
          RET
SHPRT1:   LDA   REG4            ;
          ANI   002H            ;test bit 1
          CPI   0               ;if bit1=0 then parity odd
          JNZ   SHPRT2          ;
          CALL  MILP            ;
          DB    'Odd',0         ;
          RET                   ;
SHPRT2:   CALL  MILP            ;
          DB    'Even',0        ;
          RET
;
;       SET PARITY command table
;
PARTBL:   DB    'OF','F'+80H    ;"set parity off"
          DW    PROFF
          DB    'EVE','N'+80H   ;"set parity even"
          DW    PREVEN
          DB    'OD','D'+80H    ;"set parity odd"
          DW    PRODD
          DB    0               ;<<== end of parity table
;
;       SET STOPBITS command: reset number of stop bits
;
;               The number of stop bits is controlled by bits
;               2 and 3 of the byte sent to the SIO write-
;               register 4, as follows:
;
;                   Stop bits      Bit 3        Bit 2
;                       1            0            1
;                      1.5           1            0
;                       2            1            1
;
;
STSTOP:   MVI   C,SBLANK        ;check for stop bits
          CALL  MEX             ;
          JC    SETERR          ;if none, print error
          LXI   D,STPTBL        ;check for proper syntax
          MVI   C,LOOKUP
          CALL  MEX             ;
          PUSH  H               ;match found, go do it!
          RNC                   ;
          POP   H               ;no match: fix stack and
          JMP   SETERR          ;  print error
;
STOP01:   LDA   REG4            ;get register 4 byte
          ANI   0F7H            ;reset bit 3
          ORI   004H            ;set bit 2
          JMP   STSTP1          ;
STOP02:   LDA   REG4            ;
          ORI   00CH            ;set bits 2 and 3
          JMP   STSTP1          ;
STOP15:   LDA   REG4            ;
          ORI   008H            ;set bit 3
          ANI   0F8H            ;reset bit 2
STSTP1:   STA   REG4            ;
          CALL  NITSIO          ;
          CALL  SHSTOP          ;print the result
          RET
SHSTOP:   CALL  MILP            ;display stop-bits
          DB    'Stop bits:',TAB,' ',0
          LDA   REG4            ;
          ANI   004H            ;test bit 2
          CPI   0               ;if bit2=0 then 1.5
          JNZ   SHSTP1          ;
          CALL  MILP            ;
          DB    '1.5',0         ;
          RET
SHSTP1:   LDA   REG4            ;
          ANI   008H            ;test bit 3
          CPI   0               ;if bit3=0 then 1
          JNZ   SHSTP2          ;
          CALL  MILP            ;
          DB    '1',0           ;
          RET
SHSTP2:   CALL  MILP            ;
          DB    '2',0           ;
          RET
;
;       SET STOPBITS command table
;
STPTBL:   DB    '1'+80H         ;"set stop 1"
          DW    STOP01
          DB    '2'+80H         ;"set stop 2"
          DW    STOP02
          DB    '1.','5'+80H    ;"set stop 1.5"
          DW    STOP15
          DB    0               ;<<== End of stop-bits table
;
;       SET LENGTH command: set bits per character
;
;               The number of bits per character is controlled for
;               the receiver circuit by bits 6 and 7 of the byte
;               sent to the SIO write-register 3 and for the trans-
;               mitter circuit by bits 5 and 6 of the byte sent to
;               the SIO write-register 5.  The assumption has been
;               made here that both transmission and reception will
;               be carried on at the same number of bits per charac-
;               ter.  The bit configurations are shown for register
;               3 only, but are the same for register 5:
;
;                   BPC         Bit 7           Bit 6
;                    5            0               0
;                    6            1               0
;                    7            0               1
;                    8            1               1
;
STBITS:   MVI   C,SBLANK        ;check for bits/char
          CALL  MEX             ;
          JC    SETERR          ;if none, print error
          LXI   D,BITTBL        ;check for proper syntax
          MVI   C,LOOKUP
          CALL  MEX
          PUSH  H               ;match found, go do it!
          RNC                   ;
          POP   H               ;no match: fix stack and
          JMP   SETERR          ;  print error
;
BIT5:     LDA   REG3            ;
          ANI   0BFH            ;reset bit 6
          ANI   07FH            ;reset bit 7
          STA   REG3            ;
          LDA   REG5            ;
          ANI   0DFH            ;reset bit 5
          ANI   0BFH            ;reset bit 6
          JMP   STBTS1          ;
BIT6:     LDA   REG3            ;
          ANI   0BFH            ;reset bit 6
          ORI   080H            ;set bit 7
          STA   REG3            ;
          LDA   REG5            ;
          ANI   0DFH            ;reset bit 5
          ORI   040H            ;set bit 6
          JMP   STBTS1          ;
BIT7:     LDA   REG3            ;
          ORI   040H            ;set bit 6
          ANI   07FH            ;reset bit 7
          STA   REG3            ;
          LDA   REG5            ;
          ORI   020H            ;set bit 5
          ANI   0BFH            ;reset bit 6
          JMP   STBTS1          ;
BIT8:     LDA   REG3            ;
          ORI   040H            ;set bit 6
          ORI   080H            ;set bit 7
          STA   REG3            ;
          LDA   REG5            ;
          ORI   020H            ;set bit 5
          ORI   040H            ;set bit 6
STBTS1:   STA   REG5            ;
          CALL  NITSIO          ;
          CALL  SHBITS          ;print the result
          RET
SHBITS:   CALL  MILP            ;display bits/char
          DB    'Bits/char:',TAB,' ',0
          LDA   REG5            ;
          ANI   040H            ;test bit 6
          CPI   0               ;if bit6=0 then 6 bpc
          JNZ   SHBTS2          ;
          LDA   REG5            ;
          ANI   020H            ;test bit 5
          CPI   0               ;if bit5=0 then 5 bpc
          JNZ   SHBTS1          ;
          CALL  MILP            ;
          DB    '5',0           ;
          RET                   ;
SHBTS1:   CALL  MILP            ;
          DB    '7',0           ;
          RET                   ;
SHBTS2:   LDA   REG5            ;
          ANI   020H            ;test bit 5
          CPI   0               ;if bit5=0 then 6 bpc
          JNZ   SHBTS3          ;
          CALL  MILP            ;
          DB    '6',0           ;
          RET                   ;
SHBTS3:   CALL  MILP            ;
          DB    '8',0           ;
          RET
;
;       SET LENGTH command table
;
BITTBL:   DB    '5'+80H         ;"set bits 5"
          DW    BIT5
          DB    '6'+80H         ;"set bits 6"
          DW    BIT6
          DB    '7'+80H         ;"set bits 7"
          DW    BIT7
          DB    '8'+80H         ;"set bits 8"
          DW    BIT8
          DB    0               ;<<== end of bpc table
;
;       
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;       0 - Carrier detected, connection established
;       1 - Far end busy (only for modems that can detect this condition)
;       2 - No answer (or timed out waiting for modem response)
;       3 - Keyboard abort (^C only: all others should be ignored)
;       4 - Error reported by modem
;       5 - No ring reported by modem
;       6 - No dial tone reported by modem
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
; Dialing routine
;
;
DIAL:     LHLD  DIALPT          ;FETCH POINTER
          CPI   254             ;START DIAL?
          JZ    STDIAL1         ;JUMP IF SO
          CPI   255             ;END DIAL?
          JZ    ENDIAL1         ;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
          MOV   M,A             ;PUT CHAR IN BUFFER
          INX   H               ;ADVANCE POINTER
          SHLD  DIALPT          ;STUFF PNTR
          RET                   ;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL1:  LXI   H,DIALBF        ;SET UP BUFFER POINTER
          SHLD  DIALPT
          RET
;
; Here on an end-dial sequence
;
ENDIAL1:  MVI   M,CR            ;STUFF END-OF-LINE INTO BUFFER
          INX   H               ;FOLLOWED BY TERMINATOR
          MVI   M,0
          LDA   TPULSE          ;GET OVERLAY'S TOUCH-TONE FLAG
          STA   SMDIAL+3        ;PUT INTO STRING
          LXI   H,SMDIAL        ;POINT TO DIALING STRING
          CALL  SMSEND          ;SEND IT
WAITSM:   MVI   C,INMDM
          CALL  MEX             ;CATCH ANY OUTPUT FROM THE MODEM
          JNC   WAITSM          ;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM.
;
RESULT:   LDA   NDELAY          ;GET DELAY COUNT
          MOV   C,A
SMWLP:    PUSH  B
          MVI   B,1             ;CHECK FOR A CHAR, UP TO 1 SEC WAIT
          MVI   C,TMDINP        ;DO TIMED INPUT
          CALL  MEX
          POP   B
          JNC   SMTEST          ;JUMP IF MODEM HAD A CHAR
          PUSH  B               ;NO, TEST FOR CONTROL-C FROM CONSOLE
          MVI   C,CHEKCC
          CALL  MEX
          POP   B
          JNZ   SMNEXT          ;IF NOT, JUMP
          CALL  SMDMOFF         ;YES, SHUT DOWN THE MODEM
          MVI   A,3             ;RETURN ABORT CODE
          RET
SMNEXT:   DCR   C               ;NO
          JNZ   SMWLP           ;CONTINUE
;
; NO MODEM RESPONSE WITHIN THE TIME SPECIFIED IN SET DELAY COMMAND
;
SMTIMO:   CALL  SMDMOFF
          MVI   A,2             ;RETURN TIMEOUT CODE
          RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:   ANI   7FH             ;IGNORE ANY PARITY
          CALL  SMANAL          ;TEST THE RESULT
          JC    RESULT          ;GO TRY AGAIN IF UNKNOWN RESPONSE
          MOV   A,B             ;A=RESULT 
          PUSH  PSW             ;SAVE IT
SMTLP:    MVI   C,INMDM         ;EAT ANY ADDITIONAL CHARS FROM SMARTMODEM
          CALL  MEX
          JNC   SMTLP           ;UNTIL 100MS OF QUIET TIME
          POP   PSW             ;RETURN THE CODE
          RET
;
SMANAL:	  MVI	B,0		;PREP CONNECT CODE
	  CPI	'C'		;"CONNECT"?
	  RZ
    IF USR2400 OR B1200 OR ANCHOR
	  CPI	'1'		;NUMERIC VERSION OF "CONNECT"
	  RZ
	  CPI	'5'		;NUMERIC VERSION OF "CONNECT 1200"
	  JZ    SET12		;Insure that Baud gets set to 1200
    ENDIF
	  INR	B		;PREP BUSY CODE B=1
	  CPI	'B'
	  RZ
     IF  USR2400 OR ANCHOR
	  CPI  '7'
	  RZ
     ENDIF
	  INR	B		;PREP NO CONNECT MSG B=2
	  CPI	'N'		;N=NO CONNECT
	  RZ
    IF USR2400 OR B1200 OR ANCHOR
	  CPI	'3'		;NUMERIC VERSION OF "NO CONNECT"
	  RZ
    ENDIF
	  MVI	B,4		;PREP MODEM ERROR
	  CPI	'E'		;E=ERROR
	  RZ
    IF USR2400 OR B1200 OR ANCHOR 
	  CPI	'4'		;NUMERIC VERSION OF "ERROR"
	  RZ
    ENDIF
    IF USR2400
	  MVI	B,6
	  CPI	'6'             ;No Dial Tone Detected
	  RZ
    ENDIF
;	
;
; UNKNOWN RESPONSE, RETURN CARRY TO CALLER. BUT FIRST,
; FLUSH THE UNKNOWN RESPONSE LINE FROM THE MODEM.
;
WTLF:	  CPI	LF		;LINEFEED?
          STC
          RZ                    ;END IF SO
          MVI   C,INMDM         ;NO. GET NEXT CHAR
          CALL  MEX
          JNC   WTLF            ;UNLESS BUSY, LOOP
          RET
;
; Utility sub-routines
;
SMSEND:   MVI   C,SNDRDY        ;WAIT FOR MODEM READY
          CALL  MEX
          JNZ   SMSEND
          MOV   A,M             ;FETCH NEXT CHARACTER
          INX   H
          ORA   A               ;END?
          RZ                    ;DONE IF SO
          MOV   B,A             ;NO, POSITION FOR SENDING
          MVI   C,SNDCHR        ;NOPE, SEND THE CHARACTER
          CALL  MEX
          JMP   SMSEND
;
SMDMOFF:  MVI   B,DIALAB
          MVI   C,SNDCHR
          CALL  MEX
          MVI   B,10
          CALL  MTIME
;
    IF ANCHOR
	  RET
    ENDIF
;
    IF NOT ANCHOR    
          JMP   DISCON          ;MAKE SURE IT IS OFF
    ENDIF
;
MILP:     MVI   C,ILP
          JMP   MEX
          RET
;
MTIME:    MVI   C,TIMER
          JMP   MEX
          RET

COMMA:    CALL  MILP
          DB    ', ',0
          RET
;
CRLF:     CALL  MILP
          DB    CR,LF,0
          RET
;
;
;==========================================================================
;                            Data Area
;==========================================================================
;
; Default UART parameters 
;
REG0:     DB    00011000B       ;RESET CHANNEL A
REG3:     DB    11000001B       ;ENABLE RECEIVE AT 8 BITS/CHAR
REG4:     DB    01000100B       ;NO PARITY, 1 STOP BIT, CLOCK X16
REG5:     DB    11101010B       ;ENABLE TRANSMIT AT 8 BITS/CHAR
;
; Miscellaneous Default Data
;
SMDIAL:   DB    'ATDT '
DIALBF:   DS    52              ;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:   DS    2               ;DIAL POSITION POINTER
EOSMSG:   DB    17H,'$'         ;CLEAR TO END-OF-SCREEN
CLSMSG:   DB    1AH,'$'         ;CLEAR WHOLE SCREEN
DIGIT     DB    0               ;SAVE DIALED DIGIT
MSPDSV:   DB    0               ;SAVE EXTERNAL MODEM MSPEED
;
  IF B300
DFBAUD:   DB    05              ;5: 300, 6: 600, 7: 1200, 0EH: 9600
  ENDIF
;
  IF B1200 OR ANCHOR
DFBAUD:   DB    07             ;1200 BAUD
  ENDIF
;
  IF USR2400
DFBAUD:   DB    0AH             ;2400 BAUD
  ENDIF
;
    IF ANCHOR
MONFLG:   DB    00H		;No monitor in ANCHOR
SMATN:    DB	'+++',0		;ANCHOR uses Smartmodem codes for disconnect
SMDISC:	  DB	'ATH',CR,0
    ENDIF
;
    IF NOT ANCHOR
MONFLG:   DB    0FFH            ;0: MONITOR OFF - 0FFH: MONITOR ON
    ENDIF
;
ANSFLG:   DB    0               ;0: ORIGINATE   - 0FFH: ANS
NDELAY:   DB    30              ;NO. SECONDS FOR ANSWER
;
    IF USR2400
SMINIT:   DB    'ATM1 S0=0 S7=60 X4 V0 Q0',CR,0 ;Lot's of extended codes
    ENDIF
;
    IF B1200 OR ANCHOR
SMINIT:   DB    'ATM1 S0=0 S7=60 X1 V0 Q0',CR,0  ;Some extended codes
    ENDIF
;
    IF B300
SMINIT:   DB    'ATM1 S0=0 S7=60',CR,0  ;CAN'T USE EXTENDED COMMANDS
    ENDIF
          END
                                                                                                                   
