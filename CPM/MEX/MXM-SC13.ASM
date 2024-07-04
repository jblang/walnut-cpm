        TITLE   'MEXPLUS overlay for SwitchCom Canadiana 212A modem V 1.3'

; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)

; SwitchCom Canadiana 212A overlay for MEXPLUS: revision 1.3 86/12/01

; This module adapts MEX or MEXPLUS for the SwitchCom Canadiana 212A
; modem.  Made by:  SwitchCom Manufacturing Inc
;                   100-10 Amber St., Markham, Ontario, Canada
;                   L3R 3A2                     Tel:  416-475-0296

; This overlay will work with any port overlay that terminates
; prior to 0B00H and will work with either MEX or MEXPLUS.

; 86/12/26  V1.3 - moved modem initialization code to front of
;                  dial code and added flag to make sure that
;                  modem is only initialized once
;                                                      - Ian Cottrell

; 86/06/01  V1.2 - added 'space bar return busy' code (thanks
;                  to Al Jewer).  This code allows the user to
;                  push the space bar if he knows that the
;                  called number is busy.  If he is dialing
;                  a series of numbers, MEX will advance to the
;                  next one.
;                                                       - Ian Cottrell

; 86/01/18  V1.1 - filter all but numerals from dial routine,
;                  tightened code, made compatible with MEXPLUS
;                                                       - Ian Cottrell

; 85/03/06  V1.0 - Written - based on MXO-SM11.ASM
;                                                       - Ian Cottrell
;                                                         Sysop
;                                                         Info Centre BBS
;                                                         Ottawa, Ont
;                                                         Canada
;                                                         613-952-2289

FALSE   EQU     0
TRUE    EQU     NOT FALSE


DISC    EQU     TRUE            ; <<== change to FALSE if you disc. with DTR
                                ;      always true for MEX 1.2 or greater
 
; System constants

NDISCV  EQU     015FH           ; New smart modem disconnect here
DIALV   EQU     0162H           ; Location of dial vector in port overlay
DISCV   EQU     0165H           ; Location of disconnect vector in port overlay
DIALOC  EQU     0B00H           ; Dialing code goes here
MEX     EQU     0D00H           ; "CALL MEX"
SMTABL: EQU     0D55H           ; Smart modem init, SSET, de-init

; The following are function codes for the MEX Service Processor

INMDM   EQU     255             ; Return char from mdm in A, CY=no char in 100ms
TIMER   EQU     254             ; Delay 100ms * reg B
TMDINP  EQU     253             ; B=# secs to wait for char, CY=no char
CHEKCC  EQU     252             ; Check for ^C from kbd, Z=present
SNDRDY  EQU     251             ; Test for modem send ready
RCVRDY  EQU     250             ; Test for modem receive ready
SNDCHR  EQU     249             ; Send a character to the modem (after SNDRDY)
RCVCHR  EQU     248             ; Recv a character from the modem (after RCVRDY)
ILP     EQU     240             ; Inline print
KSTAT   EQU     11              ; Keyboard status
KBDIN   EQU     01              ; Keyboard input


CR      EQU     13
LF      EQU     10
CTRLQ   EQU     'Q'-40H


        ORG     100H

        DB      0C3H            ; We're an 8080/Z-80 overlay

        ORG     DIALV           ; Overlay the dialing vector

        JMP     DIAL
 
         IF     DISC            ; If providing disconnect code,
        ORG     NDISCV          ;   overlay the vector

        JMP     DISCON
         ENDIF                  ; DISC

; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (that's the scheme
; employed here ).

; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the digits,
; and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these.
; The Canadiana does not allow non-numberic characters, so they are
; filtered out by the overlay).

; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:

;       0 - Carrier detected, connection established
;       1 - Far end busy (only for modems that can detect this condition)
;       2 - No answer (or timed out waiting for modem response)
;       3 - Keyboard abort (^C only: all others should be ignored)
;       4 - Error reported by modem

; <No other codes should be returned after an end-dial sequence>

; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.

; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence

        ORG     DIALOC

; First, check to see if modem has been initialized.  If not,
; initialize Canadiana by setting for numeric responses and
; turning off the echo.

DIAL:   PUSH    PSW             ; Save number
        LDA     INITFL          ; Get initialization flag
        ORA     A               ; Test
        JNZ     DIAL1           ; If done, skip init code
        LXI     H,ECHO          ; Else,point to message to set echo
        CALL    SCSEND          ; Send it to modem
ELOOP:  MVI     C,INMDM         ; Wait for response from modem
        CALL    MEX
        JNC     ELOOP           ; Get it all
        LXI     H,VERBOSE       ; Point to message to set verbose
        CALL    SCSEND          ; Send it to modem
VLOOP:  MVI     C,INMDM         ; Wait for response
        CALL    MEX
        JNC     VLOOP
        MVI     A,0FFH          ; Set initialization flag
        STA     INITFL

DIAL1:  POP     PSW             ; Restore number
        LHLD    DIALPT          ; Fetch pointer
        CPI     254             ; Start dial?
        JZ      STDIAL          ; Jump if so
        CPI     255             ; End dial?
        JZ      ENDIAL          ; Jump if so

; Not start or end sequence, must be a digit to be sent to the modem

        CPI     '0'             ; Only allow numbers
        RC                      ; If not a number, just ignore it
        CPI     '9'+1
        RNC
        MOV     M,A             ; Must be a number, so put it in buffer
        INX     H               ; Advance pointer
        SHLD    DIALPT          ; Stuff pointer
        RET                     ; All done

; Here on a start-dial sequence

STDIAL: LXI     H,DIALBF        ; Set up buffer pointer
        SHLD    DIALPT
        RET

; Here on an end-dial sequence

ENDIAL: MVI     M,CR            ; Stuff end-of-line into buffer
        INX     H               ;   followed by terminator
        MVI     M,0
        LXI     H,SCDIAL        ; Point to dialing string
        CALL    SCSEND          ; Send it
WAITSC: MVI     C,INMDM
        CALL    MEX             ; Catch any output from the modem
        JNC     WAITSC          ; Loop until no more characters

; The following loop waits for a result from the modem (up to
; 60 seconds; you may change this value in the following line).
; Note that the Canadiana has an internal 30 second timeout while
; waiting for a carrier on the other end.

RESULT: MVI     C,60            ; <<== Maximum time to wait for result (in secs)
SCWLP:  PUSH    B
        MVI     B,1             ; Check for a char, up to 1 sec wait
        MVI     C,TMDINP        ; Do timed input
        CALL    MEX
        POP     B
        JNC     SCTEST          ; If modem had a character, jump
        PUSH    B               ; Else, test for character from console
        MVI     C,KSTAT         ; Check for keypress
        CALL    MEX
        ORA     A
        POP     B
        JZ      SCNEXT          ; Jump if no keypress
        PUSH    B               ; Else, get character from keyboard
        MVI     C,KBDIN
        CALL    MEX
        POP     B
        CPI     'C'-40H         ; CTL-C?
        JNZ     SPTST           ; If not, go test for space
        MVI     A,3             ; Else, get abort code
SCOFF:  PUSH    PSW             ; Save it
        MVI     B,CR            ; Shut down the modem
        MVI     C,SNDCHR
        CALL    MEX
        POP     PSW             ; Restore return code
        RET

SPTST:  CPI     ' '             ; Space?
        JNZ     SCNEXT          ; If not, round the loop again
        MVI     A,1             ; Else, get busy code
        JP      SCOFF           ; Now go shut down modem

SCNEXT: DCR     C               ; Decrement counter
        JNZ     SCWLP           ; Continue if not done

; One minute with no modem response (or no connection)

SCTIMO: MVI     A,2             ; Timed out, so return timeout code
        RET

; Modem gave us a result, check it

SCTEST: ANI     7FH             ; Ignore any parity
        CALL    SCANAL          ; Test the result
        JC      RESULT          ; Go try again if unknown response
        MOV     A,B             ; A=result
        PUSH    PSW             ; Save it
SCTLP:  MVI     C,INMDM         ; Eat any additional chars from Candaiana
        CALL    MEX
        JNC     SCTLP           ; Until 100ms of quiet time
        POP     PSW             ; Return the code
        RET

SCANAL: MVI     B,0             ; Prep connect code
        CPI     '2'             ; 2=connect
        RZ
        INR     B               ; Prep busy cond; B=1
        INR     B               ; Prep no connect msg; B=2
        CPI     '3'             ; 3=no connect (from Canadiana)
        RZ

; Unknown response, return carry to caller.  But first,
; flush the unknown response line from the modem.

WTLF:   CPI     1               ; 'Dialing'?
        STC
        RZ                      ; End if so
        MVI     C,INMDM         ; No - get next char
        CALL    MEX
        JNC     WTLF            ; Unless busy, loop
        RET

; Following routine disconnects the modem using Canadiana
; codes.  All registers are available for this function.
; Nothing is returned to caller.

        IF      DISC

DISCON: MVI     B,20
        MVI     C,TIMER         ; Wait 2 seconds
        CALL    MEX
        LXI     H,SCATN         ; Send 3 Ctrl-Q's
        CALL    SCSEND
        PUSH    B
        MVI     B,5
DISCLP: MVI     C,TMDINP        ; Wait for response from modem
        CALL    MEX
        JNC     DISCLP          ; Wait til all done
        POP     B
        LXI     H,ECHRES        ; Reset echo
        CALL    SCSEND
ECHLP:  MVI     C,INMDM         ; Wait for next response
        CALL    MEX
        JNC     ECHLP
        LXI     H,VERRES        ; Reset verbose
        CALL    SCSEND
        XRA     A		; Clear the init flag in case
	STA	INITFL          ;  we want to dial again
        RET

SCATN:  DB      CTRLQ,CTRLQ,CTRLQ,CR,LF,0       ; Disconnect
ECHRES: DB      'E=1',CR,LF,0                   ; Turn echo back on
VERRES: DB      'V=2',CR,LF,0                   ; Turn verbose back on
        ENDIF

;Canadiana Utility routing:  send string to modem

SCSEND: MVI     C,SNDRDY        ; Wait for modem ready
        CALL    MEX
        JNZ     SCSEND
        MOV     A,M             ; Fetch next character
        INX     H
        ORA     A               ; End?
        RZ                      ; Done if so
        MOV     B,A             ; No, position for sending
        MVI     C,SNDCHR        ; Send the character
        CALL    MEX
        JMP     SCSEND

; Data area

SCDIAL: DB      'D'
DIALBF: DS      52              ; 2 * 24 char max, + CR + NULL + slop
DIALPT: DS      2               ; Dial position pointer
VERBOSE:DB      'V=1',CR,LF,0   ; Set for numeric responses from modem
ECHO:   DB      'E=0',CR,LF,0   ; Turn echo off
INITFL: DB      0               ; Storage for init flag
                                ; must be 0 to start

NOTIMP: MVI     C,ILP
        CALL    MEX
        DB      CR,LF,'Not Implemented',CR,LF,0
JUSTRT: RET



        ORG     SMTABL          ; Table of smart modem vectors here

        DS      2
        DW      NOTIMP          ; SSET command (not implemented)
        DW      JUSTRT          ; Smart modem exit (do nothing)

        END
