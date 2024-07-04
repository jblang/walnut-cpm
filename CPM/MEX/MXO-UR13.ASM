          Title     'MEX overlay for the U.S. Robotics (S-100) 1.3'
;
;
;
REV       EQU       13                  ;overlay revision level
;
; MEX OVERLAY VERSION 1.3: mods by Jesse Eaton on 10/14/84
;                                Cleaned up break to prevent garbage after brk.
;                                Fixed bug in parity logic.  The call to
;                                PARITV: restores parity mode in SIO to its
;                                value prior to a call to NOPARV:.
;                                Call to NOPARV: is transparent to SET cmd.
;         NOTE: If parity is incorrect it can cause no response to initial
;               NAK for R mode file transfers resulting in timeouts.
;               Incorrect parity can also cause incorrect header # error.
;               Normally parity = none should be specified.
;
; MEX OVERLAY VERSION 1.2: mods by Jesse Eaton on 10/11/84
;                                corrected error when dialing from library
;                                 with auto baud setting.
;                                corrected bugs in SET command and expanded it's
;                                 functionality to include auto answer tone and
;                                 answer on ring #. 
;                                SET now allows parity bit setting.
;                                SET now also allows setting full/half duplex.
;         NOTE: The manual answer logic via "ATA" command and parity setting
;               from outside the SET command may need additional work.
;               Also note that you can add the S10 register in INITMSG:
;               IF your ROM chip set supports it.  Older versions did not.
;               My USR S-100 modem is connected on a line with "call waiting"
;               and will drop carrier if an incoming call generates the
;               call waiting beep tone.  I got a newer ROM (U3 A7.9) and tried
;               to keep the carrier on by setting S10=255.  It did not help
;               me but it might help you on a different phone system. Older
;               ROM versions will not generate a response (0-5 or Verbose) if
;               any unrecognized "AT" commands sush as "ATH" or "S10" are
;               are issued to the modem.  You can test them in Terminal mode.
;               Unknown commands are merely ignored instead of hanging the
;               modem with newer proms.
;
;         REQUEST: If you can shed light on any of the above comments or
;                    this overlay in general I can be contacted via Arpanet
;                    mail.  My address is Eaton.HFED @ HI-MULTICS.
;
;
; MEX OVERLAY VERSION 1.1: mods to break routine 10/10/84 by Jesse Eaton
;                                added help ? msg to SET command
;
; MEX OVERLAY VERSION 1.0: written 04/27/84 by Ron Fowler
; U.S.Robotics Version 1.0: written 08/11/84 by Ray Broz & Mike Smith
;
; This overlay is a combination of Ron's PMMI and Smart Modem Overlays
; with the required changes to make it work with the U.S. Robotics S-100
; autodial modem.
; 
;------------------------------------------------------------
;
; Misc equates
;
NO        EQU       0
YES       EQU       NOT NO
TPA       EQU       100H
NULL      EQU       0
CR        EQU       0DH
LF        EQU       0AH
TAB       EQU       09H
BELL      EQU       07H

MAXWAIT EQU         60                  ;maximum time to wait for connection
CLRSCN    EQU       YES                 ;set yes to use clear screen commands
ANSRNG    EQU       '3'                 ;SET RING default 1-9 (answer on ring #)
S10       EQU       YES                 ;S10 can be used with newer model modems
                                        ;see note above. (older ROM versions will
                                        ;hang if this register is used)
;
; US Robotics port definitions
;
PORT      EQU       30H                 ;US Robotics base port 
MDMCOM    EQU       PORT+1              ;modem command port
MDMMOD    EQU       PORT+1              ;modem mode port
MDMSTS    EQU       PORT+1              ;modem status port
MDMDAT    EQU       PORT                ;modem data port
;
; US Robotics bit definitions
;
MDRCVB    EQU       00000010B ;modem receive bit 
MDRCVR    EQU       00000010B ;modem receive ready bit 
MDSNDB    EQU       00000001B ;modem send bit 
MDSNDR    EQU       00000001B ;modem send ready bit 
OPARIT    EQU       00010000B ;odd-parity bits
EPARIT    EQU       00110000B ;even-parity bits
NPARIT    EQU       00000000B ;no-parity bits
;
; US Robotics masks (v1.2 je)
; 
XMITRDY   EQU       00000001B ;mask for transmit ready
BRKMSK    EQU       00001000B ;mask to set break
PARMSK    EQU       11001111B ;mask to remove parity bits
BDMSKL    EQU       01111100B ;mask for baudrate bits in mode (v1.2 je)
BDMSKH    EQU       11011111B ;mask for baudrate bits in command
CARMSK    EQU       10000000B ;carrier present mask         
INMODE    EQU       01001110B ;initial mode word
INCOMM    EQU       00110111B ;initial command word
;
;         
; Modem control command words
;
CLEAR     EQU       'Z'                 ;idle mode
ANMODE    EQU       'A'                 ;answer mode
ORIGMD    EQU       'Z'                 ;originate mode
RESET     EQU       40H                 ;usart reset
;
;
; MEX service processor stuff 
;
MEX       EQU       0D00H               ;address of the service processor
INMDM     EQU       255                 ;get char from port to A
TIMER     EQU       254                 ;delay 100ms * reg B
TMDINP    EQU       253                 ;B=# secs to wait for char
CHEKCC    EQU       252                 ;check for ^C from KBD
SNDRDY    EQU       251                 ;test for modem-send ready
RCVRDY    EQU       250                 ;test for modem-receive ready
SNDCHR    EQU       249                 ;send a character to the modem 
RCVCHR    EQU       248                 ;recv a char from modem 
LOOKUP    EQU       247                 ;table search
PARSFN    EQU       246                 ;parse filename from input stream
BDPARS    EQU       245                 ;parse baud-rate from input stream
SBLANK    EQU       244                 ;scan input stream to next non-blank
EVALA     EQU       243                 ;evaluate numeric from input stream
LKAHED    EQU       242                 ;get nxt char w/o removing from input
GNC       EQU       241                 ;get char from input
ILP       EQU       240                 ;inline print
DECOUT    EQU       239                 ;decimal output
PRBAUD    EQU       238                 ;print baud rate
;
;
CONOUT    EQU       2                   ;simulated BDOS function 2
PRINT     EQU       9                   ;simulated BDOS function 9
INBUF     EQU       10                  ;simulated BDOS function 10
;
          ORG       TPA                 ;we begin
;
;
          DS        3                   ;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
; The PMMI DB's are REQUIRED to maintain compatabilty with MEX.
;
PMODEM:   DB        NO                  ;yes=PMMI modem \ / These 2 locations are 
SMODEM:   DB        YES                 ;yes=Smartmodem / \ not referenced by MEX
TPULSE:   DB        'T'                 ;T=touch, P=pulse (not referenced by MEX)
CLOCK:    DB        40                  ;clock speed x .1, up to 25.5 mhz.
MSPEED:   DB        5                   ;sets display time for sending a file
                                        ;0=110    1=300  2=450  3=600  4=710
                                        ;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:   DB        5                   ;default time to send character in
                                        ;terminal mode file transfer (0-9)
                                        ;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:    DB        5                   ;end-of-line delay after CRLF in terminal
                                        ;mode file transfer for slow BBS systems
                                        ;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:   DB        5                   ;number of directory columns
SETFL:    DB        YES                 ;yes=user-defined SET command
SCRTST:   DB        NO                  ;yes=if home cursor and clear screen
                                        ;routine at CLRSCRN
          DB        0                   ;spare
BAKFLG:   DB        YES                 ;yes=make .BAK file
CRCDFL:   DB        NO                  ;yes=default to CRC checking
                                        ;no=default to Checksum checking
TOGCRC:   DB        YES                 ;yes=allow toggling of Checksum to CRC
CVTBS:    DB        NO                  ;yes=convert backspace to rub
TOGLBK:   DB        YES                 ;yes=allow toggling of bksp to rub
ADDLF:    DB        NO                  ;no=no LF after CR to send file in
                                        ;terminal mode (added by remote echo)
TOGLF:    DB        YES                 ;yes=allow toggling of LF after CR
TRNLOG:   DB        NO                  ;yes=allow transmission of logon
                                        ;write logon sequence at location LOGON
SAVCCP:   DB        YES                 ;yes=do not overwrite CCP
LOCNXT:   DB        NO                  ;yes=local cmd if EXTCHR precedes
                                        ;no=not local cmd if EXTCHR precedes
TOGLOC:   DB        YES                 ;yes=allow toggling of LOCNXTCHR
LSTTST:   DB        YES                 ;yes=allow toggling of printer on/off
                                        ;in terminal mode. Set to no if using
                                        ;the printer port for the modem
XOFTST:   DB        NO                  ;yes=allow testing of XOFF from remote
                                        ;while sending a file in terminal mode
XONWT:    DB        NO                  ;yes=wait for XON after sending CR while
                                        ;transmitting a file in terminal mode   
TOGXOF:   DB        YES                 ;yes=allow toggling of XOFF testing
IGNCTL:   DB        YES                 ;yes=do not send control characters
                                        ;above CTL-M to CRT in terminal mode
                                        ;no=send any incoming CTL-char to CRT
EXTRA1:   DB        0                   ;for future expansion
EXTRA2:   DB        0                   ;for future expansion
BRKCHR:   DB        '@'-40H             ;^@ = Send a 300 ms. break tone
NOCONN:   DB        'N'-40H             ;^N = Disconnect from phone line
LOGCHR:   DB        'L'-40H             ;^L = Send logon
LSTCHR:   DB        'P'-40H             ;^P = Toggle printer
UNSVCH:   DB        'R'-40H             ;^R = Close input text buffer
TRNCHR:   DB        'T'-40H             ;^T = Transmit file to remote
SAVCHR:   DB        'Y'-40H             ;^Y = Open input text buffer
EXTCHR:   DB        '^'-40H             ;^^ = Send next character
;
; Equates used only by PMMI routines grouped together here.
;
PRATE:    DB        250
          DB        0
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:   IN        MDMSTS              ;in modem control port
          RET
          DB        0,0,0,0,0,0,0       ;spares if needed 
;
OTDATA:   OUT       MDMDAT              ;out modem data port
          RET
          DB        0,0,0,0,0,0,0       ;spares if needed 
;
INPORT:   IN        MDMDAT              ;in modem data port
          RET
          DB        0,0,0,0,0,0,0       ;spares if needed 
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:    ANI MDRCVB ! RET    ;bit to test for receive ready
TESTR:    CPI MDRCVR ! RET    ;value of receive bit when ready
MASKS:    ANI MDSNDB ! RET    ;bit to test for send ready
TESTS:    CPI MDSNDR ! RET    ;value of send bit when ready
;
;
; Unused area: was once used for special PMMI functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.
;
          DS        12
;
; Special modem function jump table: 
;
LOGON:    DS        2                   ;needed for MDM compatability
DIALV:    JMP       PDIAL               ;dial digit in A 
DISCV:    JMP       PDISC               ;disconnect the modem
GOODBV:   JMP       DUMMY               ;called before exit to CP/M
INMODV:   JMP       DUMMY               ;initialization
NEWBDV:   JMP       PBAUD               ;set baud rate
NOPARV:   JMP       NOPAR               ;set modem for no-parity
                                        ;this call is transparent to SET cmd (je)
PARITV:   JMP       PARITY              ;set modem parity
                                        ;to value prior to nopar call (je)
SETUPV:   JMP       SETCMD              ;SET cmd:
SPMENV:   DS        3                   ;not used with MEX
VERSNV:   JMP       SYSVER              ;sign-on message
BREAKV:   JMP       PBREAK              ;send a break
;
; For MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:   DS        3                   ;replace with MEX function 9 (WHAT IS THIS?)
INBUFV:   DS        3                   ;replace with MEX function 10 (AND THIS?)
ILCMPV:   DS        3                   ;replace with MEX function 247
INMDMV:   DS        3                   ;replace with MEX function 255
NXSCRV:   DS        3                   ;not supported by MEX 
TIMERV:   DS        3                   ;replace with MEX function 254
;
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
CLREOS:   LXI       D,EOSMSG            ;clear to end of screen
          MVI       C,PRINT
          CALL      MEX
          RET
;
;
CLS:      LXI       D,CLSMSG            ;clear screen
          MVI       C,PRINT
          CALL      MEX
          RET
;
; strings to clear-to-end-of-screen, and clear-screen (VISUAL 55/VT52)

EOSMSG:   DB        1BH,'k','$'         ;clear to end-of-screen (je)
CLSMSG:   DB        1BH,'v','$'         ;clear whole screen (je)

;
;
; Modem initialization.  
;
NOAT:     MVI       A,0FFH                        ;set for 8251 initialization only
          STA       ONLYSIO                       ;"AT" commands are not sent
          CALL      CURRNT
          XRA       A                             ;reset onlysio
          STA       ONLYSIO
          RET
          
NITMOD:   LXI       H,COMMND            ;
          MVI       M,INMODE            ;store modem setup                      
          INX       H                             ;for future reference
          MVI       M,INCOMM

CURRNT:   MVI       A,NULL                        ;entry point to resend
          OUT       MDMMOD                        ;modem command and mode
          OUT       MDMCOM                        ;words    
          OUT       MDMMOD                        ;clear command register
          MVI       A,RESET
          OUT       MDMCOM                        ;reset usart
          LDA       COMMND                        ;current modem mode word
          OUT       MDMMOD
          LDA       COMMND+1            ;current modem command word
          OUT       MDMCOM
          LDA       ONLYSIO                       ;get sio only flag
                                                  ;this flag was created because a full
                                                  ;modem init causes interferrence with
                                                  ;automatic dialing from library with
                                                  ;baud rate specified. ONLYSIO is set
                                                  ;and reset in baud and par routine 
          ORA       A                             ;complete modem init=0
          RNZ                                     ;sio only=ff (baud or parity change)
          LXI       H,INITMSG           ;send modem initialization string
          CALL      SMSEND    
          RET
;
; US Robotics send-break routine (v1.3 je)
;
PBREAK:   LDA       COMMND+1  ;get 2nd modem control byte
          ORI       1FH                 ;set break bit (don't change speed)     
          OUT       MDMCOM              ;send it to modem
          MVI       B,3
          MVI       C,TIMER
          CALL      MEX                 ;wait for 300 ms.
          CALL      NOAT                ;reset sio to orig values
          RET
;
; The following code disconnects a call in progress.
; The US Robotics hangs itself up, and returns to
; command state.
;
PDISC:    MVI       B,12
          MVI       C,TIMER             ;wait 1.2 seconds
          CALL      MEX
          LXI       H,USESC             ;send '+++'
          CALL      SMSEND
          MVI       B,12                ;wait 1.2 seconds
          MVI       C,TIMER
          CALL      MEX
          RET
;
USESC     DB        '+++',0             ;disconnect from line
;
;
; exit routine
;
DUMMY:    RET                           ;we don't need one
;
;
; This is the DIAL routine called by MEX to dial a digit. 
; 
;  The following status codes are returned in the A register
;
;         0 - Carrier detected, connection established
;         1 - Far end busy (only for modems that can detect this condition)
;         2 - No answer (or timed out waiting for modem response)
;         3 - Keyboard abort (^C only: all others should be ignored)
;         4 - Error reported by modem
;
; <No other codes should be returned after an end-dial sequence>
;
;
PDIAL:    LHLD      DIALPT              ;FETCH POINTER
          CPI       254                 ;START DIAL?
          JZ        STDIAL              ;JUMP IF SO
          CPI       255                 ;END DIAL?
          JZ        ENDIAL              ;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
          MOV       M,A                 ;PUT CHAR IN BUFFER
          INX       H                   ;ADVANCE POINTER
          SHLD      DIALPT              ;STUFF PNTR
          RET                           ;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL:   LXI       H,DIALBF  ;SET UP BUFFER POINTER
          SHLD      DIALPT
          RET
;
; Here on an end-dial sequence
;
ENDIAL:   MVI       M,CR                ;STUFF END-OF-LINE INTO BUFFER
          INX       H                   ;FOLLOWED BY TERMINATOR
          MVI       M,0
          LDA       TPULSE              ;GET OVERLAY'S TOUCH-TONE FLAG
          STA       SMDIAL+3  ;PUT INTO STRING
          LXI       H,SMDIAL  ;POINT TO DIALING STRING
          CALL      SMSEND              ;SEND IT
          MVI       C,INMDM
          CALL      MEX                 ;CATCH ANY OUTPUT FROM THE MODEM
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM FOR UP TO
; 60 SECONDS: YOU MAY CHANGE THE EQUATE VALUE FOR THE FOLLOWING LINE
; "MODE ANS" WILL (TEMP) SET IT TO 20 SECONDS DUE TO THE MODEM'S RESTRICTION
;
RESULT:   MVI       C,MAXWAIT ;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:    PUSH      B
          MVI       B,1                 ;CHECK FOR A CHAR, UP TO 1 SEC WAIT
          MVI       C,TMDINP  ;DO TIMED INPUT
          CALL      MEX
          POP       B
          JNC       SMTEST              ;JUMP IF MODEM HAD A CHAR
          PUSH      B                   ;NO, TEST FOR CONTROL-C FROM CONSOLE
          MVI       C,CHEKCC
          CALL      MEX
          POP       B
          JNZ       SMNEXT              ;IF NOT, JUMP
          MVI       B,CR                ;YES, SHUT DOWN THE MODEM
          MVI       C,SNDCHR
          CALL      MEX
          MVI       A,3                 ;RETURN ABORT CODE
          RET
SMNEXT:   DCR       C                   ;NO
          JNZ       SMWLP               ;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO:   MVI       A,2                 ;RETURN TIMEOUT CODE
          RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:   ANI       7FH                 ;IGNORE ANY PARITY
          CALL      SMANAL              ;TEST THE RESULT
          JC        RESULT              ;GO TRY AGAIN IF UNKNOWN RESPONSE
          MOV       A,B                 ;A=RESULT 
          PUSH      PSW                 ;SAVE IT
SMTLP:    MVI       C,INMDM             ;EAT ANY ADDITIONAL CHARS FROM SMARTMODEM
          CALL      MEX
          JNC       SMTLP               ;UNTIL 100MS OF QUIET TIME
          POP       PSW                 ;RETURN THE CODE
          RET
;
SMANAL:   STA       ANSBD               ;store baud rate for "MODE ANS" (v1.3 je) 
          MVI       B,0                 ;prep connect code
          CPI       '1'                 ;numeric version of "CONNECT"
          RZ
          CPI       '5'                 ;numeric version of "CONNECT 1200"
          RZ
          INR       B                   ;US Robotics can't do busy
          INR       B                   ;prep no connect code B=2
          CPI       '3'                 ;numeric version of "NO CONNECT"
          RZ
          INR       B                   ;we already checked for ^C
          INR       B                   ;prep modem error B=4
          CPI       '4'                 ;numeric version of "ERROR"
          RZ

ANSBD:    DB        0                   ;1=300, 5=1200 baud for "MODE ANS" (v1.3 je)

;
; UNKNOWN RESPONSE, RETURN CARRY TO CALLER. BUT FIRST,
; FLUSH THE UNKNOWN RESPONSE LINE FROM THE MODEM.
;
WTLF:     CPI       LF                  ;LINEFEED?
          STC
          RZ                            ;END IF SO
          MVI       C,INMDM             ;NO. GET NEXT CHAR
          CALL      MEX
          JNC       WTLF                ;UNLESS BUSY, LOOP
          RET
;
; SMARTMODEM UTILITY ROUTINE: SEND STRING TO MODEM
;
SMSEND:   MVI       C,SNDRDY  ;WAIT FOR MODEM READY
          CALL      MEX
          JNZ       SMSEND
          MOV       A,M                 ;FETCH NEXT CHARACTER
          INX       H
          ORA       A                   ;END?
          RZ                            ;DONE IF SO
          MOV       B,A                 ;NO, POSITION FOR SENDING
          MVI       C,SNDCHR  ;NOPE, SEND THE CHARACTER
          CALL      MEX
          JMP       SMSEND
;
; DATA AREA
;

INITMSG:DB          'AT'                ;modem attention (carrier must be off)
          DB        'V'                 ;verbosity
          DB        '0'                 ;verbose=1, terse=0
          DB        'X'                 ;extended result to be sent?
          DB        '1'                 ;yes=1 (0-5), no=0 (0-4)
;
; *** DO NOT CHANGE THE ABOVE SETTINGS
;
          DB        'M'                 ;monitor speaker
SPKFLG:   DB        '1'                 ;on=2, until carrier=1, off=0
          DB        'F'                 ;duplex
DUPFLG: DB          '1'                 ;full=1, half=0
          DB        'S0='               ;answer on ring
ONRING:   DB        '0'                 ;#=1-9 (usr max=255), no ans=0
                                        ;modified by ANSRNG equate
                                        ;SET ORIG resets this byte to '0'
          DB        'S7='               ;carrier wait time
TIMFLG:   DB        '15'                ;15, 20, 30 or 60 seconds

          IF        S10                 ;use only with newer modems ***********
          DB        'S10=255' ;(see change notes)
          ENDIF     ;S10                ;used to determine carrier dropout time

          DB        CR                  ;usr command mode terminator
          DB        0                   ;initmsg stopper

ANSNOW:   DB        'ATA',CR,0          ;enter answer mode (send ans tone)
                                        ;(wait for carrier from orig modem)

SMDIAL:   DB        'ATD'               ;dial attention
          DB        'T'                 ;tone=T, pulse=P, ","=2 sec delay (in dialbf)
DIALBF:   DS        52                  ;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:   DS        2                   ;DIAL POSITION POINTER
;
; Set baud-rate code in A . US Robotics supports only four rates, 
; which are validated here. 
;
PBAUD:    PUSH      H                   ;don't alter anybody
          PUSH      D
          PUSH      B
          MOV       E,A                 ;code to DE
          MVI       D,0
          LXI       H,BAUDTB  ;offset into table
          DAD       D
          MOV       A,M                 ;fetch code
          ORA       A                   ;0? (means unsupported code)
          STC                           ;return error for STBAUD caller
          JZ        PBEXIT              ;exit if so
          MOV       B,A
          LXI       H,MSPEED
          MOV       M,E
          LXI       H,BAUDCD
          DAD       D
          MOV       C,M
          LXI       H,COMMND
          MOV       A,M
          ANI       BDMSKL              ;modified 110 baud for 2 stop bits (v1.2 je)
          ORA       B
          MOV       M,A
          INX       H
          MOV       A,M
          ANI       BDMSKH
          ORA       C
          MOV       M,A
          CALL      NOAT                ;init 8251 sio only
PBEXIT:   POP       B                   ;all done
          POP       D
          POP       H
          RET
;
; table of baud rate divisors for supported rates
; modified 110 for 2 stop bits.  (v1.2 je)
;
BAUDTB:   DB        83H,3,0,2,0                   ;110,300,450,610,710 (v1.2 je)
          DB        2,0,0,0,0           ;1200,2400,4800,9600,19200
BAUDCD: DB          0,20H,0,0,0
          DB        20H,0,0,0,0
;
; Sign-on message
;

SYSVER:   CALL      NITMOD              ;init modem with defaults
          LXI       D,SOMESG
          MVI       C,PRINT
          CALL      MEX
CARRSH:   CALL      CRLF
          LXI       D,NOMESG
          CALL      CARRCK
          MVI       C,PRINT
          CNZ       MEX
          LXI       D,CARMSG
          MVI       C,PRINT
          CALL      MEX
          RET
;
SOMESG:   DB        'U.S. Robotics (S-100) overlay V. '
          DB        REV/10+'0'
          DB        '.'
          DB        REV MOD 10+'0'
          DB        ':',CR,LF,'$'
;
NOMESG:   DB        'NO $'
CARMSG:   DB        'CARRIER PRESENT',CR,LF,LF,'$'
;
;   Check US Robotics for carrier present  (Z=yes)
;
CARRCK:   IN        MDMSTS
          CMA
          ANI       CARMSK
          RET
;
; Newline on console
;
CRLF:     MVI       A,CR
          CALL      TYPE
          MVI       A,LF                ;fall into TYPE
;
; type char in A on console
;
TYPE:     PUSH      H                   ;save 'em
          PUSH      D
          PUSH      B
          MOV       E,A                 ;align output character
          MVI       C,CONOUT  ;print via MEX
          CALL      MEX
          POP       B
          POP       D
          POP       H
          RET
;
; Data area
;
ERRFLG:    DB       0                   ;connection error code
COMMND:    DS       2                   ;current modem status storage
ORGFLG:    DB       '0'                 ;initiate to "normal"(originate) 
                                        ;'0'=orig,'1'-'9'=ring,ffh='ATA'
ONLYSIO: DB         0                   ;ff=don't send "AT" commands to modem
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command (v1.2 je) 
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:   MVI       C,SBLANK  ;any arguments?
          CALL      MEX
          JC        SETSHO              ;if not, go print out values
          LXI       D,CMDTBL  ;parse command
          CALL      TSRCH               ;from table
          PUSH      H                   ;any address on stack
          RNC                           ;if we have one, execute it
          POP       H                   ;nope, fix stack
SETERR:   LXI       D,SETEMS  ;print error
          MVI       C,PRINT
          CALL      MEX
          RET
;
; SET with parameters is not allowed if carrier is present (v1.2 je)
;

SETNOK:
          IF        CLRSCN              ;clear screen cmds
          CALL      CLS
          ENDIF     ;CLRSCN

          LXI       D,SETNOM  ;set not allowed with carrier present
          MVI       C,PRINT
          CALL      MEX
          MVI       A,0FFH              ;prevent clearing screen at setsho
          STA       NOCLR
          CALL      SETSHO              ;display current parameters
          XRA       A                   ;reset flag
          STA       NOCLR
          RET

NOCLR:    DB        0                   ;prevents clearing screen in setsho if=ff

SETNOM:   DB        CR,LF,'The requested SET command is not allowed',CR,LF
          DB        'when a carrier is present.  The connection',CR,LF
          DB        'must be broken first.',CR,LF,LF,'$'

;
SETEMS:   DB        CR,LF,'SET command error',CR,LF,'$'
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
CMDTBL:   DB        '?'+80H                       ;"set ?"
          DW        STHELP
          DB        'BAU','D'+80H                 ;"set baud"
          DW        STBAUD
          DB        'MOD','E'+80H                 ;"set mode"
          DW        STMODE
          DB        'SPEA','K'+80H                ;"set speaker on/off"
          DW        STSPKR
          DB        'WAI','T'+80H                 ;"set time"
          DW        STTIME
          DB        'PA','R'+80H                  ;"set parity"
          DW        STPAR
          DB        'DUPL','X'+80H                ;"set full/half duplex"
          DW        STDUP     
;
          DB        0                   ;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:
          IF        CLRSCN              ;clear screen cmds
          LDA       NOCLR               ;see if we already have an err msg on screen
          ORA       A
          JNZ       STSHO               ;yes, don't clear screen
          CALL      CLS                 ;clear screen
          ENDIF     ;CLRSCN

STSHO:    CALL      CARRSH              ;show carrier present/not present
          LXI       H,SHOTBL  ;get table of SHOW subroutines
SETSLP:   MOV       E,M                 ;get table address
          INX       H
          MOV       D,M
          INX       H
          MOV       A,D                 ;end of table?
          ORA       E
          RZ                            ;exit if so
          PUSH      H                   ;save table pointer
          XCHG                          ;adrs to HL
          CALL      GOHL                ;do it
          CALL      CRLF                ;print newline
          MVI       C,CHEKCC  ;check for console abort
          CALL      MEX
          POP       H                   ;it's done
          JNZ       SETSLP              ;continue if no abort
          RET
;
GOHL:     PCHL
;
; table of SHOW subroutines
;
SHOTBL:   DW        BDSHOW              ;baud rate
          DW        MDSHOW              ;mode
          DW        SPSHOW              ;speaker
          DW        TMSHOW              ;wait time
          DW        PSHOW               ;parity
          DW        DSHOW               ;duplex
          DW        HLSHOW              ;v1.1 je
          DW        0                   ;<<== table terminator
;
; SET ?  processor
;
STHELP:
          IF        CLRSCN              ;clear screen
          CALL      CLS
          ENDIF     ;CLRSCN

          LDA       RINGNO              ;get number of rings
          STA       HLRING              ;set it in help message
          LXI       D,HLPMSG
          MVI       C,PRINT
          CALL      MEX
          RET
;
; Display SET ? message (v1.1 je)
;
HLSHOW:   LXI       D,HLQMSG
          MVI       C,PRINT
          CALL      MEX
          RET

HLQMSG:   DB        CR,LF,'Type SET ? for help.',CR,LF,'$'

;
; The help message
;
HLPMSG:
          IF        NOT CLRSCN
          DB        CR,LF
          ENDIF     ;NOT CLRSCN

          DB        'SET COMMAND (recommended defaults first)  '
          DB        '"U.S. ROBOTICS VERSION"',CR
          DB        LF,LF,'SET BAUD  1200   (1200 baud + 1 stop bit)'
          DB        CR,LF,'          600    (600 baud + 1 stop bit)'
          DB        CR,LF,'          300    (300 baud + 1 stop bit)'
          DB        CR,LF,'          110    (110 baud + 2 stop bits)'
          DB        CR,LF,'SET MODE  ORIG   (orignate mode) *'
          DB        CR,LF,'          ANS    (answer tone sent immediately) *'
          DB        CR,LF,'          RING   (answer on ring #'
HLRING:   DB        '3'
          DB        ') *'
          DB        CR,LF,'SET SPEAK TEMP   (speaker on until carrier) *'
          DB        CR,LF,'          ON     (speaker always on) *'
          DB        CR,LF,'          OFF    (speaker always off) *'
          DB        CR,LF,'SET WAIT  15     (15 seconds) *'
          DB        CR,LF,'          20     (20 seconds) *'
          DB        CR,LF,'          30     (30 seconds) *'
          DB        CR,LF,'          60     (60 seconds) *'
          DB        CR,LF,'SET PAR   NO     (no parity + 8 data bits)'
          DB        CR,LF,'          ODD    (odd parity + 7 data bits)'
          DB        CR,LF,'          EVEN   (even parity + 7 data bits)'
          DB        CR,LF,'SET DUPLX FULL   (full duplex) *'          
          DB        CR,LF,'          HALF   (half duplex) *',CR,LF
          DB        CR,LF,'* = CARRIER CANNOT BE PRESENT FOR THESE COMMANDS'
          DB        CR,LF,'$'
;
; SET BAUD processor (v1.2 je)
; carrier may be on or off
;
STBAUD:   MVI       C,BDPARS  ;function code
          CALL      MEX                 ;let MEX look up code
          JC        SETERR              ;invalid code?
          CALL      PBAUD               ;no, try to set it
          JC        SETERR              ;not-supported code
BDSHOW:   CALL      ILPRT               ;display baud
          DB        'BAUD RATE:   ',0
          LDA       MSPEED
          MVI       C,PRBAUD  ;use MEX routine
          CALL      MEX
          RET
;
; SET MODE processor (v1.2 je)
; carrier must be off
;
STMODE:   CALL      CARRCK              ;is carrier present?
          JZ        SETNOK              ;z=yes, SET MODE not allowed with carrier
          LXI       D,MODTBL  ;lookup next input item in table
          CALL      TSRCH
          JC        SETERR              ;if not found, error
          MOV       A,L                 ;L='0' orig, L=ff ans, L='1'-'9' ring #
          STA       ORGFLG
          CPI       '0'                 ;orgflg contains ascii 0-9 or ffh
          JZ        MDORIG              ;originate
          JM        MDANS               ;answer
MDRING:   LDA       RINGNO              ;get ring # to answer on
          STA       ONRING              ;store in modem init string
          STA       RINGNB              ;store in display string
          CALL      CURRNT              ;send modem init string
          JMP       MDSHOW              ;display mode
MDORIG:   MVI       A,'0'               ;set for no ans in init string
          STA       ONRING
          CALL      CURRNT              ;send modem init string
MDSHOW:   CALL      ILPRT               ;show mode
          DB        'MODE:        ',0
          LDA       ORGFLG              ;orig='0', ans=ff, ring='1'-'9'
          CPI       '0'                 ;orgflg contains ascii 0-9 or ffh
          JZ        ORIGP               ;display orig
          CALL      ILPRT
          DB        'Answer on Ring #'
RINGNB:   DB        '3'                 ;default is 3 rings
          DB        0                   ;stopper
          RET
ORIGP:    CALL      ILPRT
          DB        'Originate'
          DB        0
          RET
;
; This routine is used primarily for remote ends which have
; originate only modems without autodialing. You must issue
; the "ATA" command before the carrier is detected from remote.
; It is temporary in nature and will revert to RING or ORIGINATE
; the next time an "AT" command other than "ATA" is sent to the
; modem, depending on mode prior to last "ATA".
;         NOTE: THE BAUD RATE MAY CHANGE UPON CONNECTION (v1.3 je)
;
MDANS:    CALL      ILPRT               ;answer mode
          DB        'MODE:        '
          DB        'Sending Answer Tone "Now"',CR,LF
          DB        '             '
          DB        'Remote Modem must send Originate',CR,LF
          DB        '             '
          DB        'tone within '
MDTIME:   DB        '15'                          ;modifying S7 in modem had no effect
                                                  ;on the "ATA" cmd so I removed the
                                                  ;logic to change this value (je)
          DB        ' seconds!',CR,LF
          DB        '             '
          DB        'Originator Determines Baud Rate.'
          DB        CR,LF,0

          LXI       H,ANSNOW  ;send answer tone now
          CALL      SMSEND              ;send "ATA" to modem
;
; This logic reset the orgflg back to orig or ring since the
; manual answer mode is a one shot operation.
; Then the result of the ANS command is reported and baud rate
; switching is done if required. (v1.3 je)
;
          LDA       ONRING              ;get init string rings
          STA       ORGFLG              ;set orgflg to orig or ring (not ans)
          MVI       A,20                ;set max time for connection
          STA       RESULT+1
          CALL      RESULT              ;wait for modem response
          PUSH      PSW                 ;save return code
          MVI       A,MAXWAIT ;reset to max of 60 sec
          STA       RESULT+1
          POP       PSW                 ;retrieve return code
          CPI       0                   ;connection?
          JZ        ACNCT               ;yes
          CPI       2                   ;timeout?
          JZ        ANCNCT              ;yes
          CPI       3                   ;ctl-c abort?
          JZ        KABORT              ;yes
          CALL      ILPRT               ;modem reported error
          DB        CR,LF,BELL
          DB        'USR Modem Returned "FAILED" Status',CR,LF,LF,0
          RET
ACNCT:    LDA       ANSBD               ;get connected baud rate
          SBI       30H                 ;convert from dec to hex
          STA       MSPEED              ;set speed byte
          CPI       1                   ;300 baud?
          JNZ       A1200               ;no, must be 1200
          CALL      ILPRT
          DB        CR,LF,BELL,'300',0
          JMP       ACOM
A1200:    CALL      ILPRT
          DB        CR,LF,BELL,'1200',0
ACOM:     CALL      ILPRT
          DB        ' BAUD CONNECTION DETECTED',CR,LF
          DB        'You may enter Terminal (T/L/E) Mode.',CR,LF,LF,0
          CALL      PBAUD               ;change baud rate in sio
          RET
ANCNCT:   CALL      ILPRT               ;no connection
          DB        CR,LF,BELL,'TIMEOUT -'
          DB        ' No Orignate Tone Received.',CR,LF,LF,0
          RET
KABORT:   CALL      ILPRT               ;ctl-c abort by user
          DB        CR,LF,'ABORTED',CR,LF,LF,0
          RET

;
; MODE argument table
;
MODTBL:   DB        'ORI','G'+80H       ;"set mode orig"
          DB        '0',0
          DB        'AN','S'+80H        ;"set mode ans"
          DB        0FFH,0
          DB        'RIN','G'+80H       ;"answer on ring #"
RINGNO:   DB        ANSRNG              ;default is set for you taste at equate
          DB        0
;
          DB        0                   ;<<=== table terminator
;
; The speaker on the US Robotics board can get annoying
; so we included this routine to turn it off. If you
; are truly masochistic you can turn it on all the time.
; Carrier must be off.
;
STSPKR:   CALL      CARRCK              ;check for carrier
          JZ        SETNOK              ;z=yes, command not allowed
          LXI       D,SPKTBL  ;lookup next input item in table
          CALL      TSRCH
          JC        SETERR              ;if not found, error
          MOV       A,L
          STA       SPKFLG
          CALL      CURRNT              ;send init buff
SPSHOW:   CALL      ILPRT               ;show speaker setting
          DB        'SPEAKER:     ',0
          LDA       SPKFLG
          CPI       '0'
          JZ        SDOFF
          CPI       '2'
          JZ        SDON
          CALL      ILPRT
          DB        'On Until Carrier Detected',0
          RET
SDOFF:    CALL      ILPRT
          DB        'Always Off',0
          RET
SDON:     CALL      ILPRT
          DB        'Always On',0       
          RET
;
; SPEAKER argument table
;
SPKTBL:   DB        'OF','F'+80H                  ;"set sound off"
          DB        '0',0
          DB        'O','N'+80H                   ;"set sound on"
          DB        '1',0
          DB        'TEM','P'+80H                 ;"set sound on until carrier"
          DB        '2',0     
;
          DB        0                   ;<<=== table terminator
;
;
;  The US Robotics allows for soft setting of the time to
;  wait for answer from the other end. It can be anywhere
;  in the range of 0 to 255 seconds. We have arbitrarily
;  chosen 15, 20, 30 and 60 seconds... If you don't like 
;  these times... change them.
;  Carrier must be off.
;  
STTIME:   CALL      CARRCK              ;is carrier on?
          JZ        SETNOK              ;z=yes, SET WAIT not allowed if carrier
          LXI       D,TIMETBL ;lookup next input item in table
          CALL      TSRCH
          JC        SETERR              ;if not found, error
          SHLD      TIMFLG
          CALL      CURRNT              ;send modem init string
TMSHOW:   CALL      ILPRT               ;show time setting
          DB        'WAIT TIME:   ',0
          LDA       TIMFLG
          CPI       '1'
          JZ        TM15
          CPI       '2'
          JZ        TM20
          CPI       '3'
          JZ        TM30
          CALL      ILPRT
          DB        '60 Seconds',0
          RET
TM30:     CALL      ILPRT
          DB        '30 Seconds',0
          RET
TM20:     CALL      ILPRT
          DB        '20 Seconds',0      
          RET
TM15:     CALL      ILPRT
          DB        '15 Seconds',0
          RET
;
; TIME argument table
;
TIMETBL:  DB        '1','5'+80H         ;"set time 15"
          DB        '15'
          DB        '2','0'+80H                   ;"set time 20"
          DB        '20'
          DB        '3','0'+80H                   ;"set time 30"
          DB        '30'      
          DB        '6','0'+80H                   ;"set time 60"
          DB        '60'
;
          DB        0                   ;<<=== table terminator

;
; Parity setting logic.  Even and Odd parity setting requires
; 7 data bits.  No parity requires 8 data bits. The number
; of stop bits is determined by baud rate.
; As of version 1.2 I don't know if there is outside entry other
; than through the SET command.  If there is a need to come in
; externally entry can be made at PARITY: and NOPAR:.
; An assumption is being made at the PARITY: entry. (see comments there)
; Carrier may be on or off.
;
; CAUTION: NO PARITY MUST BE SPECIFIED IF OBJECT FILES ARE TO BE TRANSFERRED
;
STPAR:    LXI       D,PARTBL  ;lookup next input item in table
          CALL      TSRCH
          JC        SETERR              ;if not found, error
          MOV       A,L
          STA       PARFLG
          CPI       '0'
          JZ        NONE8               ;no parity
          CPI       '1'
          JZ        ODD7                ;odd parity
EVEN7:    LDA       COMMND              ;get mode byte
          ORI       38H                 ;send even parity with 7 data bits
          ANI       0FBH
          JMP       PARCOM              ;go to common routine
NONE8:    LDA       COMMND              ;get mode byte      
          ORI       0CH                 ;send no parity with 8 data bits
          ANI       0CFH
          JMP       PARCOM              ;go to common routine
ODD7:     LDA       COMMND              ;get mode byte
          ORI       18H                 ;send odd parity with 7 data bits
          ANI       0DBH
PARCOM:   STA       COMMND              ;resave mode byte
          CALL      NOAT                ;init of 8251 only
PSHOW:    CALL      ILPRT               ;show parity setting
          DB        'PARITY:      ',0
          LDA       PARFLG
          CPI       '0'
          JZ        PARNO
          CPI       '1'
          JZ        PARODD
PAREVN:   CALL      ILPRT
          DB        'Even',0
          RET
PARNO:    CALL      ILPRT
          DB        'None',0
          RET
PARODD:   CALL      ILPRT
          DB        'Odd',0
          RET

;
; Set parity to its original value after call to nopar (v1.3 je)
; Called by MEX (transparent to SET cmd)
;
PARITY:   CALL      NOAT                ;init sio only (no AT cmd)
          RET
;
; MEX calls this routine to set modem for no parity.
; This is transparent to the SET command (v1.3 je)
;
NOPAR:    LDA       COMMND              ;get current parity setting
          PUSH      PSW                 ;save it
          ANI       PARMSK              ;clear parity enable bit
          ORI       NPARIT              ;set for no parity
          STA       COMMND              ;this is temporary in sio until set parity
                                        ;changes it to its previous value (je)
          CALL      NOAT                ;init sio only (no AT cmd)
          POP       PSW                 ;get original sio mode byte
          LXI       H,COMMND  ;hl = mode byte upon return
          MOV       M,A                 ;restore mode byte
          RET

PARFLG:   DB        '0'                 ;default to no parity

;
; PARITY argument table
;
PARTBL:   DB        'NON','E'+80H                 ;"set no parity"
          DB        '0',0
          DB        'OD','D'+80H                  ;"set odd parity"
          DB        '1',0
          DB        'EVE','N'+80H                 ;"set even parity"
          DB        '2',0     
;
          DB        0                   ;<<=== table terminator
;
; Full or Half Duplex setting (v1.2 je)
; Normally Full duplex is all that is required but in
; case there is a need to change it you can.
; Carrier must not be present.
;
STDUP:    CALL      CARRCK              ;check for carrier present
          JZ        SETNOK              ;z=yes, SET DUPLX is not allowe
          LXI       D,DUPTBL  ;lookup next input item in table
          CALL      TSRCH
          JC        SETERR              ;if not found, error
          MOV       A,L
          STA       DUPFLG
          CALL      CURRNT              ;send init buff including "AT" cmd
DSHOW:    CALL      ILPRT               ;show duplex setting
          DB        'DUPLEX:      ',0
          LDA       DUPFLG
          CPI       '0'
          JZ        HDPLX               ;half duplex
          CALL      ILPRT
          DB        'Full',0
          RET
HDPLX:    CALL      ILPRT
          DB        'Half',0
          RET
;
; DUPLEX argument table
;
DUPTBL:   DB        'FUL','L'+80H                 ;"set full duplex"
          DB        '1',0
          DB        'HAL','F'+80H                 ;"set half duplex"
          DB        '0',0
;
          DB        0                   ;<<=== table terminator
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:    MVI       C,LOOKUP  ;get function code
          JMP       MEX                 ;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:    MVI       C,ILP               ;get function code
          JMP       MEX                 ;go do it
;
;
          END
                                                                                 