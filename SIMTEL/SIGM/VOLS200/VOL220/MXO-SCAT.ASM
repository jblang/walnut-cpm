;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; SmartCat overlay for MEX: revision 1.0
; Written 05/15/84 by Curt Arnold
; Borrows heavily from 
; Smartmodem overlay for MEX: revision 1.0
; Written 04/16/84 by Ronald G. Fowler
;
; Last revision: 05/15/84 (CWA)
;
; This modules adapts MEX for the Novation SmartCat.
; The main function of this module is to provide dialing capability;
; the disconnect vector and break vector are ancillary.
; You may use this module as a model to develop dialing routines
; for non-standard modems (e.g., the Racal-Vadic).  The only
; pertinent entry point is the DIAL routine; you'll find entry
; specs for that below.
;
; There are two equates that you might want to change in this
; module.  One is the DISC equate below -- if left on, MEX will
; use the SmartCat's disconnect code.  If you prefer to
; provide your own in your overlay's DISCV vector (e.g.,
; by dropping DTR), then set DISC to FALSE and re-assemble.
; (If you don't understand this, then play it safe, and
; leave the equate set as it is).  The other is the BREAK equate
; -- if left on, MEX will use the SmartCat break code.

;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
FALSE   EQU     0
TRUE    EQU     NOT FALSE
CMDCHR  EQU     '%'             ;DEFAULT SMARTCAT COMMAND CHARACTER
;
;
DISC    EQU     TRUE            ;<<== CHANGE TO FALSE IF YOU DISC. WITH DTR
BREAK   EQU     TRUE            ;<<== CHANGE TO FALSE IF YOU BREAK WITH DTR
;
; SYSTEM CONSTANTS
;
TPULSE  EQU     0105H           ;TONE/PULSE FLAG IN MODEM OVERLAY
DIALV   EQU     0162H           ;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV   EQU     0165H           ;LOCATION OF DISCONNECT VECTOR IN OVERLAY
BREAKV  EQU     0180H           ;LOCATION OF BREAK VECTOR IN OVERLAY
DIALOC  EQU     0B00H           ;DIALING CODE GOES HERE
MEX     EQU     0D00H           ;"CALL MEX"
;
; FOLLOWING ARE FUNCTION CODES FOR THE MEX SERVICE CALL PROCESSOR
;
INMDM   EQU     255             ;RETURN CHAR FROM MDM IN A, CY=NO CHR IN 100MS
TIMER   EQU     254
TMDINP  EQU     253             ;B=# SECS TO WAIT FOR CHAR, CY=NO CHAR
CHEKCC  EQU     252             ;CHECK FOR ^C FROM KBD, Z=PRESENT
SNDRDY  EQU     251             ;TEST FOR MODEM-SEND READY
RCVRDY  EQU     250             ;TEST FOR MODEM-RECEIVE READY
SNDCHR  EQU     249             ;SEND A CHARACTER TO THE MODEM (AFTER SNDRDY)
RCVCHR  EQU     248             ;RECV A CHAR FROM MODEM (AFTER RCVRDY)
;
CR      EQU     13
LF      EQU     10
;
;
;
        ORG     DIALV           ;OVERLAY THE DIALING VECTOR
        JMP     DIAL
;       
        IF      DISC            ;IF PROVIDING DISCONNECT CODE
        ORG     DISCV           ;OVERLAY THE VECTOR
        JMP     DISCON
        ENDIF
;
        IF      BREAK           ;IF PROVIDING BREAK CODE
        ORG     BREAKV
        JMP     SENDBK
        ENDIF

;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the SmartCat).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the SmartCat, allow special non-numeric characters in the
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
        ORG     DIALOC
;
DIAL:   LHLD    DIALPT          ;FETCH POINTER
        CPI     254             ;START DIAL?
        JZ      STDIAL          ;JUMP IF SO
        CPI     255             ;END DIAL?
        JZ      ENDIAL          ;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
        MOV     M,A             ;PUT CHAR IN BUFFER
        INX     H               ;ADVANCE POINTER
        SHLD    DIALPT          ;STUFF PNTR
        RET                     ;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL: LXI     H,DIALBF        ;SET UP BUFFER POINTER
        SHLD    DIALPT
        RET
;
; Here on an end-dial sequence
;
ENDIAL: MVI     M,CR            ;STUFF END-OF-LINE INTO BUFFER
        INX     H               ;FOLLOWED BY TERMINATOR
        MVI     M,0
        LDA     TPULSE          ;GET OVERLAY'S TOUCH-TONE FLAG
        CPI     'T'
        MVI     A,' '
        JZ      DOTONE
        MVI     A,'I'           ;LOAD A WITH CHAR TO SET PULSE
DOTONE  STA     SCDIAL+3        ;PUT INTO STRING
        LXI     H,SCDIAL        ;POINT TO DIALING STRING
        CALL    SCSEND          ;SEND IT
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE)
;
RESULT: MVI     C,60            ;<<== MAXIMUM TIME TO WAIT FOR RESULT
SCWLP:  PUSH    B
        MVI     B,1             ;CHECK FOR A CHAR, UP TO 1 SEC WAIT
        MVI     C,TMDINP        ;DO TIMED INPUT
        CALL    MEX
        JC      NOCHAR          ;SKIP AROUND IF NO CHAR.
        ANI     7FH             ;STRIP HIGH BIT
        CALL    SCTEST          ;CHECK CHAR
        MOV     A,B             ;MOVE RETURN CODE TO A
        JC      NOCHAR          ;NO CODE YET
        PUSH    PSW             ;PUSH OUR GOOD RESULT
DRAIN:  MVI     C,INMDM         ;DRAIN ANY OTHER CHARACTERS 
        CALL    MEX
        JNC     DRAIN
        POP     PSW     
        POP     B
        RET                     ;RETURN TO MEX
NOCHAR: MVI     C,CHEKCC        ;CHECK FOR CTRL-C
        CALL    MEX
        POP     B
        JNZ     SCNEXT          ;IF NOT, JUMP
        MVI     B,18H
        MVI     C,SNDCHR
        CALL    MEX             ;SEND CTRL-X
        MVI     A,3             ;RETURN ABORT CODE
        RET
SCNEXT: DCR     C               ;NO
        JNZ     SCWLP           ;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SCTIMO: MVI     A,2             ;RETURN TIMEOUT CODE
        RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SCTEST: PUSH    PSW             ;PUSH CURRENT CHAR
        LDA     LCHAR
        CPI     CMDCHR
        JZ      SCANAL
        POP     PSW
        STA     LCHAR
        STC                     ;SET CARRY FLAG
        RET
SCANAL: POP     PSW
        STA     LCHAR
        MVI     B,0             ;PREP CONNECT CODE
        CPI     'C'             ;"CONNECT"?
        RZ
        CPI     '4'             ;NUMERIC VERSION OF "CONNECT"
        RZ
        INR     B               ;PREP BUSY CODE B=1
        CPI     'B'
        RZ
        CPI     '0'             ;NUMERIC VERSION OF "BUSY"
        RZ
        INR     B               ;PREP NO CONNECT MSG B=2
        CPI     'N'             ;N=NO ANS OR NO DIAL
        RZ
        CPI     '2'             ;NUMERIC VERSION OF "NO ANS"
        RZ
        CPI     '3'             ;NUMERIC VERSION OF "NO DIAL"
        RZ
        MVI     B,4             ;PREP MODEM ERROR
        CPI     'A'             ;A = ABORT
        RZ
;
; UNKNOWN RESPONSE, RETURN CARRY TO CALLER.
;
        STC
        RET
LCHAR   DB      0H      ;LAST CHAR PROCESSED
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING SMARTCat
; CODES. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
;
        IF      DISC
;
DISCON: LXI     H,SCDISC        ;SEND '%H'
        CALL    SCSEND
        RET
;
SCDISC: DB      CMDCHR,'H',CR,0
;
        ENDIF
        IF      BREAK
;
SENDBK  LXI     H,SCBRK         ;SEND '%B'
        CALL    SCSEND
        RET
;
SCBRK:  DB      CMDCHR,'B 2',CR,0
;
        ENDIF
;
; SMARTCat UTILITY ROUTINE: SEND STRING TO MODEM
;
SCSEND: MVI     C,SNDRDY        ;WAIT FOR MODEM READY
        CALL    MEX
        ORA     A
        JZ      SCSEND
        MOV     A,M             ;FETCH NEXT CHARACTER
        INX     H
        ORA     A               ;END?
        RZ                      ;DONE IF SO
        PUSH    H
        MOV     B,A             ;NO, POSITION FOR SENDING
        MVI     C,SNDCHR        ;NOPE, SEND THE CHARACTER
        CALL    MEX
        MVI     C,INMDM         ;CLEAR ANY STUFF FROM MODEM
        CALL    MEX
        POP     H
        JMP     SCSEND
;
; DATA AREA
;
SCDIAL: DB      CMDCHR,'D  '
DIALBF: DS      52              ;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT: DS      2               ;DIAL POSITION POINTER
;
        END

