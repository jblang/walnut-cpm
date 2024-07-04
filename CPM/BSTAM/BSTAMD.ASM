 
 
 
;HP125 DRIVER ROUTINE FOR BSTAM PROGRAM
 
;  USING DATACOMM PORT #1;
;  HP 125 TERMINAL DATACOM #1 SHOULD BE SET UP AS FOLLOWS --
 
;    Remote To: Port 1

;    BaudRate 1200 (or less)    Parity NONE (0)
 
;    Straps   xy                Hndsk etx
 
 
;  DATACOM PORT #2 DOES NOT ALLOW 8 BIT COMMUNICATION AND CAN THEREFORE
;  NOT BE USED FOR BSTAM.
 
BEGIN    ORG   103H
INITIL   JMP   INITIU         ;UART/USART INITIALIZATION ENTRY POINT
INSPORT  JMP   INSPRU         ;STATUS PORT READ ENTRY POINT
ERRSET   JMP   ERRSTU         ;UART/USART ERROR RESET ENTRY POINT
INPORT   JMP   INPRTU         ;READ DATA PORT ENTRY POINT
OUTPORT  JMP   OUTPRU         ;WRITE DATA PORT ENTRY POINT
;
ESC      EQU   27       ; CONTROL ESCAPE
;
;
INITIU   EQU   $
;
         CALL  SIGNON   ; SEND SIGNON MESSAGE AND MAP DC PORT TO
;                       ; PUNCH AND READER.
         LXI   B,73FFH  ; GET HPDOS 8 BIT DATACOM MODE FUNCTION
         CALL  5        ; SET 8 BIT DATACOM MODE
         RET            ; RETURN TO BSTAM
;
;
;
;
INSPRU   EQU   $
;
         LXI   B,70FFH  ; SET FOR HPDOS READER STATUS FUNCTION
         CALL  5        ; GO GET READER STATUS
         ORA   A        ; IS A BYTE READY?
         MVI   A,5      ; DEFAULT TO YES
         RZ             ; RETURN IN HPDOS READER STATIS IS 0
;
         MVI   A,7      ; SET STATUS TO NO CHARACTER
         RET            ; RETURN TO CALLING PROGRAM
;
;
;
ERRSTU   EQU   $
;
         RET
;
;
;
INPRTU   EQU   $
;                     THIS IS THE READ DATA ROUTINE.
;                     BEFORE THIS ROUTINE IS ENTERED THE 02 BIT OF
;                     STATUS READ ROUTINE MUST HAVE BEEN SET.
;                     DO NOT CLEAR THE 80 BIT FROM THE DATA INPUT PORT.
;                     RETURN WITH REGISTER A LOADED WITH INPUT DATA.
;
;
;
         CALL  0E215H   ; GO PERFORM A DIRECT BIOS READER INPUT CALL
         MOV   A,B      ; PLACE THE 8 BIT INPUT INTO THE A REGISTER
         RET            ; GO BACK TO BSTAM
;
;
;
OUTPRU   EQU   $
;                     THIS IS THE WRITE DATA PORT ROUTINE.
;                     BEFORE THIS ROUTINE IS ENTERED THE 04 BIT AND 01
;                     BIT OF STATUS READ MUST BE SET.
;                     DO NOT CLEAR THE 80 BIT FROM THE DATA OUTPUT PORT.
;                     REGISTER A CONTAINS THE OUTPUT DATA.
;
         MOV   C,A      ; GET THE OUTPUT CHARACTER
         CALL  0E212H   ; PERFORM A DIRECT BIOS PUNCH OUTPUT CALL
         RET            ; RETURN TO BSTAM
;
;
;
MESSAGE: DB    0DH,0AH,0DH,0AH
         DB    'HP 125 Revision Q1.0',0DH,0AH
;
;        ESCAPE SEQUENCE TO MAP DATACOMM PORT #1 TO PUNCH AND READER
;
;
;
        DB    ESC,'&i0s25d2M',ESC,'&i10s16d2M$'
;
;
SIGNON:  PUSH  B
         PUSH  D
         PUSH  H
         LXI   D,MESSAGE
         MVI   C,9
         CALL  5         ;ANNOUNCE VERSION TO USER
         POP   H
         POP   D
         POP   B
         RET
;
         END
