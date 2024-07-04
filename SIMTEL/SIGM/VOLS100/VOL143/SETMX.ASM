; SETMX v1.0     EPSON MX-80 PRINTER UTILITY       10/10/82
;
;                            by
;                       IRVIN M. HOFF
;                LOS ALTOS HILLS, CA  94022
;
;
;     This program sets the EPSON MX-80 printer to various
;     configurations such as:
;
;                   10 CPI or 16.5 CPI
;                   Normal or Double Strike
;                   6 or 8 vertical lines per inch
;                   Emphasized print
;
;     There are numerous other selections that could be added.
;     This program should give you the background to include
;     other options, if desired, yourself.  These seemed the
;     most important.
;
;
;
;     COMMAND CHARACTERS FOR THE EPSON PRINTER:
;
;        17         CTL-Q       Enable printer to receive data
;        27,'0'     ESC 0       8 vertical lines per inch
;        27,'2'     ESC 2       6 vertical lines per inch (Normal)
;        27,'E'     ESC E       Emphasized print
;        27,'F'     ESC F       Non-emphasized print      (Normal)
;        27,'G'     ESC G       Double-strike print
;        27,'H'     ESC H       Single-strike print       (Normal)
;        27,14      ESC CTL-N   Double-width print on
;        27,20      ESC CTL-T   Double-width print off    (Normal)
;  15 or 27,15      ESC CTL-O   16.5 Characters per inch  (Compressed)
;  18 or 27,18      ESC CTL-R   10 characters per inch    (Normal)
;
; +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +
;
;
	ORG	100H
;
;
        JMP   START          ;JUMP INTO PROGRAM
;
;
; GENERAL EQU'S
;
BDOS    EQU   5              ;SYSTEM CALL ENTRY POINT
CONIN   EQU   1              ;GET KEYBOARD CHARACTER
CR      EQU   0DH            ;CONTROL-M FOR CARRIAGE RETURN
CONOUT  EQU   2              ;CRT OUTPUT ROUTINE
CTLC    EQU   3              ;CONTROL-C TO TERMINATE
ESC     EQU   1BH            ;ESCAPE CHARACTER
LF      EQU   0AH            ;CONTROL-J FOR LINE FEED
LIST    EQU   5              ;LIST DEVICE OUTPUT
STRING  EQU   9              ;PRINT STRING ON CONSOLE
TAB     EQU   09H            ;CONTROL-I FOR HORIZONTAOL TAB
;.....
;
;
; DATA STRINGS TO CONTROL EPSON PRINTER
;
CD:     DB    15,ESC,'F',ESC,'G',ESC,'2',0    ;16.5 CPI, DOUBLE STRIKE
CN:     DB    15,ESC,'F',ESC,'H',ESC,'2',0    ;16.5 CPI, NORMAL
DEFLT:  DB    17,18,ESC,'F',ESC,'H',ESC,'2',0 ;DEFAULT PARAMETERS
EMPH:   DB    ESC,'E',0                       ;EMPHASIZED
UCD:    DB    18,ESC,'F',ESC,'G',ESC,'2',0    ;10 CPI, DOUBLE STRIKE
UCN:    DB    18,ESC,'F',ESC,'H',ESC,'2',0    ;10 CPI, NORMAL
EIGHT:  DB    ESC,'0',0                       ;8 LINES PER INCH
TURNUP: DB    CR,LF,'$'
;.....
;
;
; SIGN-ON MESSAGE
;
SOM:    DB    CR,LF,LF,LF,LF,LF,LF,LF
        DB    TAB,TAB,'MX-80 Printer options v1.0 10/11/82'
        DB    CR,LF,LF,TAB,TAB,'0 = Reset to default parameters'
        DB    CR,LF,LF,TAB,TAB,'1 = 10   CPI, Normal'
        DB    CR,LF,TAB,TAB,'2 = 10   CPI, Double Strike'
        DB    CR,LF,TAB,TAB,'3 = 16.5 CPI, Normal'
        DB    CR,LF,TAB,TAB,'4 = 16.5 CPI, Double Strike'
        DB    CR,LF,LF,TAB,TAB,'5 = Emphasized'
        DB    CR,LF,TAB,TAB,'8 = vertical lines per inch'
        DB    CR,LF,LF,LF,LF,LF,LF,TAB,'Select: '
        DB    '$'
;.....
;
;
;**********************************************************************;
;                                                                      ;
;                     PROGRAM STARTS HERE                              ;
;                                                                      ;
;**********************************************************************;
;
;
START:  POP   H              ;RETURN ADDRESS TO 'CCP'
        SHLD  EXIT1+1        ;STORE
        LXI   SP,STACK       ;SET UP STACK
        LXI   D,SOM          ;SIGNON MESSAGE
        CALL  DSTRNG         ;SHOW ON THE CRT
        LXI   H,DEFLT        ;SET THE PRINTER TO NORMAL CONDITIONS
        JMP   PSTRNG
;...
;
;
SELECT: CALL  INPUT          ;GET A CHAR.
;
        CPI   '0'            ;RESET TO DEFAULT PARAMETERS
        LXI   H,DEFLT
        JZ    PSTRNG
;
        CPI   '1'
        LXI   H,UCN          ;10 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   '2'
        LXI   H,UCD          ;10 CPI, DOUBLE STRIKE
        JZ    PSTRNG
;
        CPI   '3'
        LXI   H,CN           ;16.5 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   '4'
        LXI   H,CD           ;16.5 CPI, DOUBLE STRIKE
        JZ    PSTRNG
;
        CPI   '5'
        LXI   H,EMPH         ;EMPHASIZED
        JZ    PSTRNG
;
        CPI   '8'
        LXI   H,EIGHT        ;GO TO 8 VERTICAL LINES PER INCH
        JZ    PSTRNG
;
        JMP   SELECT         ;IF NONE OF THESE, ASK AGAIN
;.....
;
;
;======================================================================;
;                                                                      ;
;                     ROUTINES START HERE                              ;
;                                                                      ;
;======================================================================;
;
;
EXIT:   LXI   D,TURNUP       ;TURN UP SOME EXTRA LINES
        CALL  DSTRNG         ;DISPLAY ON THE CRT
;
EXIT1:  JMP   0              ;FILLED BY 'START' FOR RETURN TO 'CCP'
;.....
;
;
; GET A KEYBOARD CHARACTER
;
INPUT:  MVI   C,CONIN        ;KEYBOARD ROUTINE
        CALL  BDOS
        ANI   7FH            ;STRIP AWAY ANY PARITY
        CPI   CTLC           ;CONTROL-C?
        JZ    EXIT           ;IF YES, ALL FINISHED
        CPI   CR             ;CONTROL-M FOR RETURN?
        JZ    EXIT           ;IF YES, ALL FINISHED
        RET
;.....
;
;
; DISPLAY A STRING ON THE CRT
;
DSTRNG: MVI   C,STRING       ;CONSOLE STRING ROUTINE
        JMP   BDOS           ;SEND TO THE CRT
;.....
;
;
; PRINT A STRING OF CHARS. ON THE EPSON MX-80
;
PSTRNG: MOV   A,M            ;GET THE CHARACTER IN THE STRING
        ORA   A              ;SEE IF FINISHED YET
        JZ    SELECT         ;GET ANOTHER ANSWER IF FINISHED
;
        PUSH  H              ;SAVE THE ADDRESS IN THE STRING
        MVI   C,LIST         ;PRINTER ROUTINE
        MOV   E,A            ;PUT THE CHAR. INTO 'E' REG.
        CALL  BDOS           ;SEND TO THE PRINTER
        POP   H              ;BACK TO THE STRING ADDRESS
        INX   H              ;NEXT LOCATION
        JMP   PSTRNG         ;DO THE NEXT ONE
;.....
;
;
;	STACK AREA
;
	DS	20H            ;ALLOW SPACE FOR STACK
;
STACK	DS	0
;
	END
