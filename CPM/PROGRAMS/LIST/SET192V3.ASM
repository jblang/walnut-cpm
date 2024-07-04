;*****************************************************************
;	TITLE:		SET192V3.ASM         
;
;	PURPOSE:	OKIDATA 192/193 PRINTER OPTIONS SELECTOR
;****************************************************************
;	Adapted from the following:             
;       TITLE:     	SET92.ASM
;	PURPOSE:	Set-Up for OKIDATA 92 Printer
;	AUTHOR:		J. A. GRONEK
;	COPYRIGHT:	UCS, inc.  1984
;	VERSION:	2.2    DATED:	AUGUST 22, 1984
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; SET192 revision 3.0                30 Apr 86   Jim Lill
; - added "end with <cr>" note, deleted "ctrl-C quits" note
; - added paper-out disable command (resets with "R" default)
; - moved "R" line and listed defaults on screen
; - deleted RESET to defaults from START, must force with a "R"
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; SET192 revision 2.0                28 Mar 86   Jim Lill
; - reformatted menu for additional commands
; - added commands for choice of Language Sets
; - changed commands to all letters to eliminate errors such
;   as hitting "6" for 6 LPI
; - changed method of handling lower case, now p/o INPUT sub-routine
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Updated for Okidata 192             9 Feb 86   Jim Lill                              
; From SET92.ASM, changing name and resetting rev. to 1.1
; Added:
; 1) Italics 
; 2) Enhanced Print
; 3) Left offset of 1/2 inch for improving print-outs that are
;    to be punched  
; 4) characters to "sample"                    
; 5) 1/2 speed printing
; 6) unidirectional printing
; 7) Changed DEFAULT concept. Now affects only the following:
;           - cancels print suppress
;           - cancels Emph. and Enh. mode
;           - cancels italicized print mode
;           - resets left margin to column 1
;           - returns to full speed printing
;           - returns to bidirectional printing
;   All others commands remain as last selected or power-up defaults
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Updated to version 2.3  09/05/84  Steve Sanders 
;
; added "L"inefeed command and
; "P"rint sample command and upper/lower
; case conversion for letter commands
;******************************************************************
;
	ORG	100H
;
        JMP   START          ;JUMP INTO PROGRAM
;
; ENVIRONMENTAL EQU'S
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
CLSCR   EQU   1AH	     ;CLEAR SCREEN CODE		
;.....
;
;
; DATA STRINGS TO CONTROL OKIDATA PRINTER
;
COMPR:  DB    29,0                   ;17.1 CPI        
NORM:   DB    30,0	             ;10 CPI
TWELV:	DB    28,0                   ;12 CPI         

DUBL:   DB    31,0                   ;DOUBLE WIDTH
COOR:   DB    ESC,'1',0              ;CORRESPONDENCE MODE
DATA:	DB    ESC,'0',0              ;DATA PROCESSING MODE
ITAL:   DB    ESC,'!','/',0          ;ITALIC MODE
EMPH:   DB    ESC,'T',0              ;EMPHASIZED PRINT      
ENHAN:  DB    ESC,'H',0              ;ENHANCED PRINT      
SIX:	DB    ESC,'6',0     	     ;6 LINES PER INCH		
EIGHT:  DB    ESC,'8',0              ;8 LINES PER INCH
LEFT:   DB    ESC,'%','C','061',0    ;1/2 INCH LEFT MARGIN OFFSET
HSPEED: DB    ESC,'<',0              ;1/2 SPEED PRINTING 
ONEWAY: DB    ESC,'-',0              ;ONE-WAY PRINTING
STDLAN:	DB    ESC,'!','0',0	     ;STANDARD LANG. SET
IBMLAN:	DB    ESC,'!',31H,0          ;IBM LANG. SET
ASCIIZ:	DB    ESC,'!',40H,0	     ;ASCII W/SLASH ZERO   
ASCII:	DB    ESC,'!',41H,0          ;ASCII W/O SLASH ZERO
papero: DB    ESC,'E','1',0          ;disable paper out
sample:	DB    cr,lf
	DB    'abcdefghijklmnopqrstuvwxyz 0123456789#$%',cr,lf
	DB    'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789#$%',cr,lf,0
line:	DB    lf,0
FINISH: DB    cr,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf,lf
	DB    lf,lf,lf,lf,lf,lf,'$'
DEFLT:  DB    17,CR,ESC,73,CR,ESC,37,67,'001',CR,ESC
        DB    62,CR,ESC,61,CR,ESC,33,42,esc,'E','0',0
;.....	
;
;
SOM:    DB    CR,LF,'OKIDATA'
        DB    tab,tab,tab,'       A = '
	DB    '10 CPI, Normal'
	DB    cr,lf,'192/193'
        DB    TAB,TAB,TAB,'       B = '
	DB    '12 CPI, Normal'
	DB    cr,lf,'Printer'
        DB    TAB,TAB,TAB,'       C = '
	DB    '17.1 CPI, Normal'
	DB    cr,lf,'Set-up'
        DB    TAB,TAB,TAB,'       D = '
	DB    'Double width Characters'
	DB    cr,lf,'Utility'
        DB    TAB,TAB,TAB,'       E = '
	DB    'Correspondence Mode'
	DB    cr,lf,'Version 3.0'
        DB    TAB,TAB,'       F = '
	DB    'Data Processing Mode'
	DB    cr,lf,'Jim Lill 4/86'
	DB    TAB,TAB,'       G = '
        DB    'Italicized Mode'
        DB    CR,LF,TAB,TAB,TAB,'       H = '
	DB    'Emphasized Print Mode'
	DB    CR,LF,TAB,TAB,TAB,'       J = '
	DB    'Enhanced Print Mode'
	DB    CR,LF,TAB,TAB,TAB,'       K = '
	DB    '6 Lines per inch'
        DB    cr,lf,TAB,TAB,'               L = '
	DB    '8 lines per inch'
	DB    cr,lf,'----------------------\        M = '
	DB    '1/2 Inch Left Margin Offset'
	DB    CR,LF,'- enables Printer      \       N = '
        DB    'One-Way Printing'
        DB    CR,LF,'- enables Full-Speed    \      P = '
	DB    '1/2-Speed (Quiet) Printing'
	DB    CR,LF,'- enables Bidirect. Prt. \     Q = '
	DB    'Standard Character Set'
        DB    cr,lf,'- cancels Enhanced        ===> R = '
	DB    'Reset to default parameters'
	DB    cr,lf,'- cancels Emphasized     /     S = '
	DB    'IBM Character Set'
	DB    cr,lf,'- cancels Italics       /      T = '
	DB    'ASCII with Slash Zero'
	DB    cr,lf,'upper/lower case okay  /       U = '
	DB    'ASCII w/o Slash Zero'
	DB    cr,lf,'----------------------/        V = '
        DB    'Disable Paper-Out Alarm'
	DB    cr,lf,tab,tab,'               W = '
	DB    'Linefeed Issued to Printer'
	DB    cr,lf,tab,tab,tab,'       X = '
	DB    'Print Sample'
        DB    cr,lf,lf,'String as many selections as you wish, end with <cr>, SELECT:'
        DB    '$'
;.....
;
;
START:  POP   H              ;RETURN ADDRESS TO 'CCP'
        SHLD  EXIT1+1        ;STORE
        LXI   SP,STACK       ;SET UP STACK
        LXI   D,SOM          ;SIGNON MESSAGE
        CALL  DSTRNG         ;SHOW ON THE CRT
;...
;
;
SELECT: CALL  INPUT          ;GET A CHAR.
;
        CPI   82             ;RESET TO DEFAULT PARAMETERS
        LXI   H,DEFLT
        JZ    PSTRNG
;
        CPI   65 
        LXI   H,NORM         ;10 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   66 
        LXI   H,TWELV        ;12 CPI, NORMAL
        JZ    PSTRNG

;
        CPI   67 
        LXI   H,COMPR        ;17.1 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   68 
        LXI   H,DUBL         ;DOUBLE WIDTH
        JZ    PSTRNG
;
        CPI   69 
        LXI   H,COOR         ;CORRESPONDENCE PRINT
        JZ    PSTRNG
;
        CPI   70 
        LXI   H,DATA         ;DATA PROC PRINT
        JZ    PSTRNG
;
    	CPI   71 
        LXI   H,ITAL	     ;Italics
        JZ    PSTRNG
;
        CPI   72  
        LXI   H,EMPH         ;EMPHASIZED PRINT
        JZ    PSTRNG
;
        CPI   74 	        
        LXI   H,ENHAN        ;ENHANCED PRINT
        JZ    PSTRNG
;
        CPI   75 
        LXI   H,SIX          ;6 LINES PER INCH
        JZ    PSTRNG
;
        CPI   76 
        LXI   H,EIGHT        ;8 LINES PER INCH
        JZ    PSTRNG
;
	cpi   77             ;LEFT MARGIN
	lxi   h,LEFT
	jz    PSTRNG
;
	CPI   80 
        LXI   H,HSPEED          ; HALF SPEED
        JZ    PSTRNG
;
	CPI   78
	LXI   H,ONEWAY	        ;ONE WAY PRINTING
        JZ    PSTRNG
;
	cpi   86
        lxi   h,papero		;paper-out disable
        jz    pstrng
;
	CPI   87 
	LXI   H,LINE            ;LINEFEED     
	JZ    PSTRNG
;
	cpi   88 		; print sample
	lxi   h,sample
	jz    PSTRNG
;
	CPI   81      
	LXI   H,STDLAN  	;STD CHAR SET
	JZ    PSTRNG
;
	CPI   83
	LXI   H,IBMLAN          ;IBM CHAR SET
	JZ    PSTRNG
;
	CPI   84
	LXI   H,ASCIIZ	        ;WITH SLASH ZERO
	JZ    PSTRNG	
;
	CPI   85
	LXI   H,ASCII           ;W/O SLASH
	JZ    PSTRNG
;
	JNZ    SELECT         ;IF NONE OF THESE, ASK AGAIN
;.....
;
;
;
EXIT:   LXI   D,FINISH       ;TURN UP SOME EXTRA LINES
        CALL  DSTRNG         ;DISPLAY ON THE CRT
;
EXIT1:  JMP   0              ;FILLED BY 'START' FOR RETURN TO 'CCP'
;.....
;
;
;
INPUT:  MVI   C,CONIN        ;KEYBOARD ROUTINE
        CALL  BDOS
        ANI   7FH            ;STRIP AWAY ANY PARITY
	CPI   90	     ;IS ENTRY LOWER CASE
	JC    NOT$LC         ;JUMP IF INPUT NOT LOWER CASE
	SBI   32             ;SUBTRACT 32 TO CONVERT LC TO UC
NOT$LC: CPI   CTLC           ;CONTROL-C?
        JZ    EXIT           ;IF YES, ALL FINISHED
        CPI   CR             ;CONTROL-M FOR RETURN?
        JZ    EXIT           ;IF YES, ALL FINISHED
        RET
;.....
;
;
DSTRNG: MVI   C,STRING       ;CONSOLE STRING ROUTINE
        JMP   BDOS           ;SEND TO THE CRT
;.....
;
;
PSTRNG: MOV   A,M            ;GET THE CHARACTER IN THE STRING
        ORA   A              ;SEE IF FINISHED YET
        JZ    SELECT         ;GET NEW ANSWER IF ZERO
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
	DS	20H            ;ALLOW ROOM FOR STACK
;
STACK	DS	0
;
	END
