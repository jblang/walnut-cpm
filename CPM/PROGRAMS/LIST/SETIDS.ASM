; SETIDS v1.4	IDS MICROPRISM PRINTER UTILITY	4/7/84
;
; PREPARED BY R. BLOOM AND E. BOYD,
; BASED ON SETMX by IRVIN M. HOFF
;
; This program sets the IDS MICROPRISM printer to various
; configurations such as:
;
;	10 CPI or 16.5 CPI
;	Normal or Double Strike
;	6 or 8 vertical lines per inch
;	Emphasized print
;
; ===========================================================
;
	ORG	100H
;
;
	JMP	START		;JUMP INTO PROGRAM
;
; GENERAL EQU'S
;
BDOS	EQU	5		;SYSTEM CALL ENTRY POINT
CONIN	EQU	1		;GET KEYBOARD CHARACTER
CR	EQU	0DH		;CONTROL-M FOR CARRIAGE RETURN
CONOUT  EQU	2		;CRT OUTPUT ROUTINE
CTLC	EQU	3		;CONTROL-C TO TERMINATE
ESC	EQU	1BH		;ESCAPE CHARACTER
LF	EQU	0AH		;CONTROL-J FOR LINE FEED
LIST	EQU	5		;LIST DEVICE OUTPUT
STRING  EQU	9		;PRINT STRING ON CONSOLE
;
; DATA STRINGS TO CONTROL IDS PRINTER
;
DEFLT:	DB	11H,2,1BH,'R2$',1EH,1BH,'B8$',6H,5H,0
			;Printer on, Normal size chars, Draft Quality,
			;12 Pitch, 6 lines/inch, Fixed Pitch chars,
			;No right Justification.

DUBL:	DB	1,0	;Double Width Characters
NORM:	DB	2,0	;Normal size chars
JUST:	DB	4,0	;Fully Justified
NONJ:	DB	5,0	;Right Justification Off
FXED:	DB	6,0	;Fixed Pitch
PORP:	DB	10H,0	;Proportional Pitch
PRIN:	DB	11H,0	;Print all Characters (printer on)
NONP:	DB	13H,0	;Ignore all Character (printer off)
TENP:	DB	1DH,0	;Ten Pitch
TWELP:	DB	1EH,0	;Twelve Pitch
SIXTP:	DB	1FH,0	;16.8 Pitch
GRAPH:	DB	3,2,0	;Toggle graphics
NLQ:	DB	1BH,'R1$',0	;Near Letter Quality
DRAF:	DB	1BH,'R2$',0	;Draft Quality
SIXL:	DB	1BH,'B8$',0	;6 lines per inch
EIGHL:	DB	1BH,'B6$',0	;8 lines per inch
TENL:	DB	1BH,'B5$',0	;10 lines per inch
TWELL:	DB	1BH,'B4$',0	;12 lines per inch
TURNUP:	DB	CR,LF,'$'
;
; SIGN-ON MESSAGE
;
SOM:	DB	CR,LF,LF,LF,LF,LF,LF,LF
	DB	CR,LF,'IDS Microprism Printer Options v1.4  4/7/84'
	DB	CR,LF,LF,'0 --> Reset to all default parameters	(*Defaults)'
	DB	CR,LF,LF,'1 --> Normal Sized Characters*     A --> 10 Pitch'
	DB	CR,LF,'2 --> Double Sized Characters      B --> 12 Pitch*'
	DB	CR,LF,'                                   C --> 16.8 Pitch'
	DB	CR,LF,'3 --> Near Letter Quality'
	DB	CR,LF,'4 --> Draft Quality Print*         D --> Print received chars*'
	DB	CR,LF,'                                   E --> Ignore received chars'
	DB	CR,LF,'5 --> Fixed Character Spacing*'
	DB	CR,LF,'6 --> Proportionally Spacing       F --> 6 Lines per inch*'
	DB	CR,LF,'                                   G --> 8 Lines per inch'
	DB	CR,LF,'7 --> Non-Justified Print*         H --> 10 Lines per inch'
	DB	CR,LF,'8 --> Fully Justified Print        I --> 12 Lines per inch'
	DB	CR,LF,LF,'9 --> Toggle Graphics Mode         M --> Set Margins'
	DB	CR,LF,LF,LF,LF,LF,'Enter Option --> '
	DB	'$'
;
; SET VARIOUS MARGINS
;
MRST	DB	1BH,'J0,960$',1BH,'L,408,408,$',0	;RESET TO DEFAULTS
;
RM75	DB	1BH,'J0,900$',0	;7.5 INCH RIGHT MARGIN
RM7	DB	1BH,'J0,840$',0	;7 INCH RIGHT MARGIN
RM65	DB	1BH,'J0,780$',0	;6.5 INCH RIGHT MARGIN
RM6 	DB	1BH,'J0,720$',0	;6 INCH RIGHT MARGIN
RM55	DB	1BH,'J0,660$',0	;5.5 INCH RIGHT MARGIN
;
LM05	DB	1BH,'J60$',0	;0.5 INCH LEFT MARGIN
LM1	DB	1BH,'J120$',0	;1 INCH LEFT MARGIN
LM15	DB	1BH,'J180$',0	;1.5 INCH LEFT MARGIN
LM2	DB	1BH,'J240$',0	;2 INCH LEFT MARGIN
LM25	DB	1BH,'J300$',0	;2.5 INCH LEFT MARGIN
;
TBM0:	DB	1BH,'L,408,408,$',0	;No page break (top and bottom margins)
TBM05:	DB	1BH,'L,408,384,$',0	;.5 inch top + bottom margins
TBM1:	DB	1BH,'L,408,360,$',0	;1 inch top + bottom margins
TBM15:	DB	1BH,'L,408,336,$',0	;1.5 inch top + bottom margins
TBM2:	DB	1BH,'L,408,312,$',0	;2 inch top + bottom margins
;
; set margins menu
;
SMRGN:	DB	CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF
	DB	CR,LF,'IDS Microprism Printer Margins Options v1.4a  4/7/84'
	DB	CR,LF,LF,'0 --> Reset to margins (LM=0 RM=Max, TM=0, BM=0)'
	DB	CR,LF,LF,'Left Margins           Right Margins (resets LM to 0)'  
	DB	CR,LF,'1 --> .5 Inch          A --> 7.5 Inch'
	DB	CR,LF,'2 --> 1 Inch           B --> 7 Inch'
	DB	CR,LF,'3 --> 1.5 Inch         C --> 6.5 Inch'
	DB	CR,LF,'4 --> 2 Inch           D --> 6 Inch'
	DB	CR,LF,'5 --> 2.5 Inch         E --> 5.5 Inch'
	DB	CR,LF,LF,'Page Break (top + bottom margins)'
	DB	CR,LF,'H --> None             J --> 1 Inch'
	DB	CR,LF,'                       K --> 1.5 Inch'
	DB	CR,LF,'I --> .5 Inch          L --> 2 Inch'
	DB	CR,LF,LF,'O --> Back to Options menu.'
	DB	CR,LF,LF,LF,LF,LF,'Enter Margin Option --> '
	DB	'$'
;
;**********************************************************************
;
;			PROGRAM STARTS HERE
;
;**********************************************************************
;
START:	POP	H		;RETURN ADDRESS TO 'CCP'
	SHLD	EXIT1+1		;STORE
	LXI	SP,STACK	;SET UP STACK
REST:	LXI	D,SOM		;SIGNON MESSAGE
	CALL	DSTRNG		;SHOW ON THE CRT
				;comment the following 2 lines if you don't
				;want printer reset to non-entered defaults
;	LXI	H,DEFLT		;SET THE PRINTER TO NORMAL CONDITIONS
;	JMP	PSTRNG
;
SELECT:	CALL	INPUT	;GET A CHAR.
;
	CPI	'0'		;RESET TO DEFAULT PARAMETERS
	LXI	H,DEFLT
	JZ	PSTRNG
;
	CPI	'1'
	LXI	H,NORM		;NORMAL sized characters
	JZ	PSTRNG
;
	CPI	'2'
	LXI	H,DUBL		;Double sized characters
	JZ	PSTRNG
;
	CPI	'3'
	LXI	H,NLQ		;near letter quality font
	JZ	PSTRNG
;
	CPI	'4'
	LXI	H,DRAF		;draft high speed font
	JZ	PSTRNG
;
	CPI	'5'
	LXI	H,FXED		;fixed character size
	JZ	PSTRNG
;
	CPI	'6'
	LXI	H,PORP		;proportionally spaced characters
	JZ	PSTRNG
;
	CPI	'7'
	LXI	H,NONJ		;no justification
	JZ	PSTRNG
;
	CPI	'8'
	LXI	H,JUST		;fully justified to margins
	JZ	PSTRNG
;
	CPI	'9'
	LXI	H,GRAPH		;toggle graphics
	JZ	PSTRNG
;
	CPI	'A'
	LXI	H,TENP		;10 chars/inch
	JZ	PSTRNG
;
	CPI	'B'
	LXI	H,TWELP		;12 chars/inch
	JZ	PSTRNG
;
	CPI	'C'
	LXI	H,SIXTP		;16.8 chars/inch
	JZ	PSTRNG				
;
	CPI	'D'
	LXI	H,PRIN		;print all received chars
	JZ	PSTRNG
;
	CPI	'E'
	LXI	H,NONP		;ignore received chars
	JZ	PSTRNG
;
	CPI	'F'
	LXI	H,SIXL		;6 lines/inch
	JZ	PSTRNG
;
	CPI	'G'
	LXI	H,EIGHL		;8 lines/inch
	JZ	PSTRNG
;
	CPI	'H'
	LXI	H,TENL		;10lines/inch
	JZ	PSTRNG
;
	CPI	'I'
	LXI	H,TWELL		;12lines/inch
	JZ	PSTRNG
;
	CPI	'M'
	JZ	MSET		;jump to margin setter
;
	JMP	SELECT	;IF NONE OF THESE, ASK AGAIN
;
;----------------------
; margin setter
;---------------------
;
MSET:	LXI	D,SMRGN		;SIGNON MESSAGE
	CALL	DSTRNG		;SHOW ON THE CRT
;
MSLCT:	CALL	INPUT	;GET A CHAR.
;
	CPI	'0'		;RESET TO DEFAULT PARAMETERS
	LXI	H,MRST
	JZ	MSTRNG
;
	CPI	'1'		;0.5 INCH LM
	LXI	H,LM05
	JZ	MSTRNG
;
	CPI	'2'		;1 LM
	LXI	H,LM1
	JZ	MSTRNG
;
	CPI	'3'		;1.5 LM
	LXI	H,LM15
	JZ	MSTRNG
;
	CPI	'4'		;2 LM
	LXI	H,LM2
	JZ	MSTRNG
;
	CPI	'5'		;2.5 LM
	LXI	H,LM25
	JZ	MSTRNG
;
	CPI	'O'		;JUMP BACK TO OPTIONS
	JZ	REST
;
	CPI	'A'		;7.5 INCH RM
	LXI	H,RM75
	JZ	MSTRNG
;
	CPI	'B'		;7 RM
	LXI	H,RM7
	JZ	MSTRNG
;
	CPI	'C'		;6.5 RM
	LXI	H,RM65
	JZ	MSTRNG
;
	CPI	'D'		;6 RM
	LXI	H,RM6
	JZ	MSTRNG
;
	CPI	'E'		;5.5 RM
	LXI	H,RM55
	JZ	MSTRNG
;
	CPI	'H'		;0 TM+BM
	LXI	H,TBM0
	JZ	MSTRNG
;
	CPI	'I'		;0.5 TM+BM
	LXI	H,TBM05
	JZ	MSTRNG
;
	CPI	'J'		;1 TM+BM
	LXI	H,TBM1
	JZ	MSTRNG
;
	CPI	'K'		;1.5 TM+BM
	LXI	H,TBM15
	JZ	MSTRNG
;
	CPI	'L'		;2 TM+BM
	LXI	H,TBM2
	JZ	MSTRNG
;
	JMP	MSLCT	;IF NONE OF THESE, ASK AGAIN
;
;======================================================================
;
;			ROUTINES START HERE
;
;======================================================================
;
EXIT:	LXI	D,TURNUP	;TURN UP SOME EXTRA LINES
	CALL	DSTRNG	;DISPLAY ON THE CRT
;
EXIT1:	JMP	0		;FILLED BY 'START' FOR RETURN TO 'CCP'
;
; GET A KEYBOARD CHARACTER
;
INPUT:	MVI	C,CONIN	;KEYBOARD ROUTINE
	CALL	BDOS
	ANI	7FH	;STRIP AWAY ANY PARITY
	CPI	CTLC	;CONTROL-C?
	JZ	EXIT	;IF YES, ALL FINISHED
	CPI	CR	;CONTROL-M FOR RETURN?
	JZ	EXIT	;IF YES, ALL FINISHED
			;NOW MAKE ALL CAPS
	CPI	61H	;"a" or greater?
	RC		;if not, ret with char
	CPI	7BH	;"{" or greater?
	RNC		;if so, ret with char
	SUI	20H	;if lc, subtract offset
	RET
;
; DISPLAY A STRING ON THE CRT
;
DSTRNG:	MVI	C,STRING	;CONSOLE STRING ROUTINE
	JMP	BDOS	;SEND TO THE CRT
;
; PRINT A STRING OF CHARS
;
PSTRNG:	MOV	A,M	;GET THE CHARACTER IN THE STRING
	ORA	A	;SEE IF FINISHED YET
	JZ	SELECT	;GET ANOTHER ANSWER IF FINISHED
;
	PUSH	H	;SAVE THE ADDRESS IN THE STRING
	MVI	C,LIST	;PRINTER ROUTINE
	MOV	E,A	;PUT THE CHAR. INTO 'E' REG.
	CALL	BDOS	;SEND TO THE PRINTER
	POP	H	;BACK TO THE STRING ADDRESS
	INX	H	;NEXT LOCATION
	JMP	PSTRNG	;DO THE NEXT ONE
;
; PRINT A STRING TO RESET MARGIN
;
MSTRNG:	MOV	A,M	;GET THE CHARACTER IN THE STRING
	ORA	A	;SEE IF FINISHED YET
	JZ	MSLCT	;GET ANOTHER ANSWER IF FINISHED
;
	PUSH	H	;SAVE THE ADDRESS IN THE STRING
	MVI	C,LIST	;PRINTER ROUTINE
	MOV	E,A	;PUT THE CHAR. INTO 'E' REG.
	CALL	BDOS	;SEND TO THE PRINTER
	POP	H	;BACK TO THE STRING ADDRESS
	INX	H	;NEXT LOCATION
	JMP	MSTRNG	;DO THE NEXT ONE
;

;	STACK AREA
;
	DS	20H		;ALLOW SPACE FOR STACK
;
STACK	DS	0
;
	END
