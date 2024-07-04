; This is a patch to Morrow MicroDecision 64K CP/M 2.2 - Rev 1.5
; This patch redefines the LST: device as the auxilary port of the
; terminal attached to the system.  This allows the otherwise 
; impossible feat of getting a hardcopy of a communications
; session (at least for those with earlier MDs) and removes the need
; to swap cables everytime you want to switch to use your modem.
;
; This patch is written as a COM file that will overwrite the space
; used by the LSTOUT routine.
;
; The patch consists of altering three BIOS routines.
; 1- The CONOUT routine is intercepted.  If the last use of the terminal
; was as the LST: device, an escape sequence is sent switching the output
; back to the screen.
; 2- The LSTOUT routine is replaced.  If the last use of the terminal was
; as the CON: device, an escape sequence is sent switching the output
; to the auxilary port.
; 3- The LSTSTATUS routine is replaced by the CONSTATUS routine.
;
; It appears that the auxilary port speed must be higher than the main
; port speed for this to work.
;
; If the system is reset while the unit is printing, the terminal will think 
; that everything coming down the line is still for the printer.  You should
; either power the terminal down and up or write something to the LST: device
; to get the terminal in the proper mode.
;
; This patch should be easily alterable to work with the other terminals
; supplied with the MicroDecision.  Replacing BUFON and BUFOFF with the
; appropriate sequences. (It is currently set up for the FREEDOM 100) 
;
; This patch should be easily alterable to work with other versions and memory
; sizes of Morrow CP/M.  The addresses JMPTBL,SCONOUT, and SLSTOUT should be
; the only things needing change.
;
; This patch was written by Curt Arnold on 12/31/83 and was placed in the
; public domain with the intent that it be freely distributed.
;
; The author realizes that this patch could be made prettier and smarter
; and encourages anyone who would like to to do so.  The author can offer
; little support because he does not own a Morrow.  (It was done as a
; favor for a friend)
;
; Hope you find this little patch useful and/or educational.
;
; By the way, this patch appears to be very tight.  Only one or two
; bytes remain for modifications.
;
; Equates
ESC     EQU  1BH
SCONOUT EQU  0F348H          ;address of the original CONOUT routine.
SLSTOUT EQU  0F442H          ;address of the original LSTOUT routine.
JUMPTB  EQU  0F200H          ;location of the BIOS jump table.
;OFFSET   EQU  0000H ;you may want to test the routines before
                     ;you put them over your BIOS.
        ORG  100H
;
; Routine to patch BIOS.
;
; Move code up to its new home.
;
       LXI   B,ENDBYT-LSTOUT ;load BC with the # of bytes to move.
       LXI   D,LSTOUT+OFFSET ;load DE with the destination (old LSTOUT)
       LXI   H,LSTOUT        ;load HL with the source
       DB    0EDH,0B0H       ;LDIR (Overlay the old LSTOUT)
; Patch the jump table to use new code.
       LXI   H,CONOUT+OFFSET ;replace the jump to the old CONOUT with
       SHLD  JUMPTB+0DH      ;a jump to the new CONOUT.
       LXI   H,LSTOUT+OFFSET ;replace the jump to the old LSTOUT with
       SHLD  JUMPTB+10H      ;a jump to the new LSTOUT.
       LHLD  JUMPTB+07H      ;Load HL with the address of CONSTATUS.
       SHLD  JUMPTB+2EH      ;Replace the jump to LSTSTATUS with a jump
                             ;to CONSTATUS.
; Warm boot.
       JMP   JUMPTB+03H      ;WARM START
;
; PATCH TESTING ROUTINE
;
       LXI   H,STRING
FRED   MOV   A,M
       ORA   A
       JZ    ENDTST
       MOV   C,A
       PUSH  H 
       CALL  CONOUT
       CALL  LSTOUT
       POP   H
       INX   H
       JMP   FRED
ENDTST JMP   0000H
STRING DB    'THIS IS A TEST',0
;
;New BIOS routines
;
; LSTOUT - New LSTOUT
; Check TOGGLE to see if last use of terminal was a LST:
; If TOGGLE is non-zero, send byte to original CONOUT.
; If TOGGLE is zero, set toggle non-zero, send sequence to turn Buffer
; print on and send byte to original CONOUT.
LSTOUT LDA   TOGGLE+OFFSET ;Check TOGGLE  
       ORA   A              
       JNZ   SCONOUT       ;If TOGGLE is NZ, then jump to original CONOUT
       DCR   A              
       STA   TOGGLE+OFFSET ;Set TOGGLE non zero. 
       LXI   H,BUFON+OFFSET       ;address of buffer print on string.
       CALL  SNDSEQ+OFFSET        ;Send the sequence
       JMP   SCONOUT      ;send original byte to CONOUT
;
; CONOUT - New CONOUT, very similar to LSTOUT, but with polarity changed.
;
CONOUT LDA  TOGGLE+OFFSET ;Check toggle
       ORA  A
       JZ   SCONOUT       ;If toggle is Z, then jump to original CONOUT
       XRA  A
       STA  TOGGLE+OFFSET ;set toggle zero
       LXI   H,BUFOFF+OFFSET   ;address of buffer print off string.
       CALL  SNDSEQ+OFFSET     ;send sequence
       JMP  SCONOUT        ;send original byte to CONOUT
; Send a sequence of bytes terminated with a ZERO to the original CONOUT
SNDSEQ PUSH  B             ;routine needs to save C
SNDLP  MOV   A,M           ;load A with (HL)
       ORA   A
       POP   B             ;pop BC just in case it returns
       RZ                  ;return if sequence finished
       PUSH  B             ;push BC to keep stack even
       MOV   C,A           ;move A to C 
       PUSH  H             ;protect HL
       CALL  SCONOUT       ;call original CONOUT
       POP   H             ;get HL back
       INX   H             ;increment HL
       JMP   SNDLP+OFFSET
TOGGLE  DB   00H
;BUFON   DB   '<',0      These are nice for testing.
;BUFOFF  DB   '>',0
BUFON   DB   ESC,'`',0  ;buffer print on (you may want to enable handshaking)
BUFOFF  DB   ESC,'a',0  ;buffer print off (and disable it here)
ENDBYT  DB   00H
OFFSET  EQU  SLSTOUT-LSTOUT
