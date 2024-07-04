 TITLE '92A OKIDATA PRINTER UTILITY          27 APRIL 83'
;
;	USE ASM OR MAC TO ASSEMBLE 
;	FROM SETOK HAVE SOME FUN
;     COMMAND CHARACTERS FOR THE OKIDATA PRINTER:
;
; GENERAL EQU'S
;
BDOS	EQU	5	;SYSTEM CALL ENTRY POINT
CONIN	EQU	1	;GET KEYBOARD CHARACTER
CR	EQU	0DH	;CONTROL-M FOR CARRIAGE RETURN
CONOUT	EQU	2	;CRT OUTPUT ROUTINE
CTLC	EQU	3	;CONTROL-C TO TERMINATE
ESC	EQU	1BH	;ESCAPE CHARACTER
LF	EQU	0AH	;CONTROL-J FOR LINE FEED
LIST	EQU	5	;LIST DEVICE OUTPUT
STRING	EQU   	9	;PRINT STRING ON CONSOLE
TAB	EQU	09H	;CONTROL-I FOR HORIZONTAOL TAB
CLEAR	EQU	1AH	;CLEAR SCREEN COMMAND
;
	ORG	100H
;
        JMP   START          ;JUMP INTO PROGRAM
;
; DATA STRINGS TO CONTROL OKIDATA 92A PRINTER
;
CPI5:	DB	30,31,0			;5 CPI   DOUBLE PRINT 
CPI6:	DB	28,31,ESC,'6',0		;6 CPI   DOUBLE PRINT       
CPI8:	DB	29,31,ESC,'6',0		;8.5 CPI DOUBLE PRINT 	
PRTSEL:	DB	17,ESC,'0'		;SELECT PRINTER	
CPI10:	DB	30,ESC,'6',0		;10 CPI, NORMAL
CPI12:	DB	28,ESC,'6',0		;12 CPI, NORMAL
CPI17:	DB	29,ESC,'6',0       	;17 CPI, NORMAL
CORA:	DB	ESC,'1',0		;CORESPONDENCE PRINT
DATAP:	DB	ESC,'0',0		;DATA PROCESSING PRINT
LPI6:	DB	ESC,'6',0		;6 LINES PER INCH		
LPI8:	DB	ESC,'8',0		;8 LINES PER INCH
TURNUP: DB	CR,LF,'$'
;
;
; SIGN-ON MESSAGE
;
SOM:	DB	1AH,LF,LF,LF,LF,LF,LF
	DB	TAB,'OKIDATA 92A Printer options '
	DB	TAB,'27 April 83 HT',LF,LF
	DB	CR,TAB,'STRING AS MANY NUMBERS AS YOU LIKE',LF
	DB	CR,TAB,TAB,'BEFORE YOU HIT A C/R',LF
	DB	CR,LF,TAB,TAB,'0 = DEFALT TO 10 CPI'
	DB	CR,LF,TAB,TAB,'1 = 5 CPI   Double Size '
	DB	CR,LF,TAB,TAB,'2 = 6 CPI   Double Size '
	DB	CR,LF,TAB,TAB,'3 = 8.5 CPI Double Size '
	DB	CR,LF,TAB,TAB,'4 = 10 CPI, Normal'           
	DB	CR,LF,TAB,TAB,'5 = 12 CPI, Normal'           
	DB	CR,LF,TAB,TAB,'6 = 17 CPI, Normal'           
	DB	CR,LF,TAB,TAB,'7 = Correspondence Print'
	DB	CR,LF,TAB,TAB,'8 = Data Processing Print'
	DB	CR,LF,TAB,TAB,'9 = 6 Vertical lines per inch'
	DB	CR,LF,TAB,TAB,'A = 8 Vertical lines per inch'
	DB	CR,LF,LF,LF,LF,TAB,'Select: '
        DB	'$'                
;
START:
	LXI	SP,STACK	;SET UP STACK
        LXI	D,SOM		;SIGNON MESSAGE
	CALL	DSTRNG		;SHOW ON THE CRT
	LXI	H,PRTSEL	;SET THE PRINTER TO NORMAL CONDITIONS
	JMP	PSTRNG
;
SELECT:	CALL	INPUT		;GET A CHAR.
;
	CPI	'0'		;RESET TO DEFAULT PARAMETERS
	LXI	H,PRTSEL	;TURN PRINTER ON and 10 CPI
	JZ	PSTRNG
;
	CPI	'1'
	LXI	H,CPI5		; 5 CPI DOUBLE PRINT 
	JZ	PSTRNG                               
;                                                    
	CPI	'2'                                  
	LXI	H,CPI6		; 6 CPI DOUBLE PRINT 
	JZ	PSTRNG                               
;                                                    
	CPI	'3'                                  
	LXI	H,CPI8		; 8.5 CPDOUBLE PRINT 
	JZ	PSTRNG                    
;                                         
	CPI	'4'		          
	LXI	H,CPI10		; 10 CPI, NORMAL
	JZ	PSTRNG                    
;                                         
	CPI	'5'                       
	LXI	H,CPI12		; 12 CPI, NORMAL
	JZ	PSTRNG
;
	CPI	'6'
	LXI	H,CPI17		; 17 CPI, NORMAL
	JZ	PSTRNG
;
	CPI	'7'
	LXI	H,CORA		; CORRESPONDENCE PRINT
	JZ	PSTRNG
;
	CPI	'8'
	LXI	H,DATAP		; DATA PROCESSING PRINT
	JZ	PSTRNG
;
	CPI	'9'
	LXI	H,LPI6		; 6 VERTICAL LINES PER INCH
	JZ	PSTRNG
;
	CPI	'A'
	LXI	H,LPI8		; 8 VERTICAL LINES PER INCH
	JZ	PSTRNG
;
	JMP	SELECT		;IF NONE OF THESE, ASK AGAIN
;                                                                      ;
;                     ROUTINES START HERE                              ;
;
EXIT:   LXI   D,TURNUP       ;TURN UP SOME EXTRA LINES
        CALL  DSTRNG         ;DISPLAY ON THE CRT
;
EXIT1:  JMP   0              ;FILLED BY 'START' FOR RETURN TO 'CCP'
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
;
; DISPLAY A STRING ON THE CRT
;
DSTRNG: MVI   C,STRING       ;CONSOLE STRING ROUTINE
        JMP   BDOS           ;SEND TO THE CRT
;
; PRINT A STRING OF CHARS. ON THE OKIDATA 92A
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
;
;
;	STACK AREA
;
	DS	20H            ;ALLOW ROOM FOR STACK
;
STACK	DS	0
;
	END
