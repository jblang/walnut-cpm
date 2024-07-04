;----------------------------------------------------------
;
;BSTAM Driver for the Morrow Decision I or MULTI/IO board
;      ( This routine will work with BSTAM through V4.6)
;      written by: Robert E. A. Adams, WA9ZMO   25-Dec-82
;
;	NOTE: To locate the GROUP address use DDT to see
;	the second and third bytes of CONIN. In my system
;	it was '3A E3' or '0E33AH'.
;
;----------------------------------------------------------
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
INITIAL EQU	TRUE    ;TRUE FOR PORT/BAUD INITIALIZATION
			;FALSE IF NO INITILIALIZATION REQ'D
;----------------------------------------------------------
;
BEGIN	ORG	103H 
INITIL  JMP     INITIU  ;UART INITIALIZATION ENTRY POINT
INSPORT JMP     INSPRU  ;STATUS PORT READ    ENTRY POINT
ERRSET  JMP     ERRSTU  ;UART ERROR RESET    ENTRY POINT
INPORT  JMP     INPRTU  ;READ DATA PORT      ENTRY POINT
OUTPORT JMP     OUTPRU  ;WRITE DATA PORT     ENTRY POINT
DUART	JMP	DUARTU	;DUMMY ROUTINE
DUARTU	EQU	$
	RET		;DO A RETURN HERE UNLESS YOU WISH
			;TO ADD AN ADDITIONAL ROUTINE
;
;----------------------------------------------------------
GROUP	EQU	0E33AH	;YOU WILL HAVE TO CHECK YOUR BIOS
			;FOR YOUR VALUE
DEVICE	EQU	2	;SERIAL PORT P2 SPECIFIED HERE
PORT	EQU	48H	;ADDRESS OF DECISION & MULTI/IO
;
;----------------------------------------------------------
;
PREPARE EQU     $
        PUSH    H       ;THIS ROUTINE INFORMS THE PIC
        PUSH    PSW     ;AS TO WHICH 8250 PORT YOU ARE
        LDA     GROUP   ;ABOUT TO I/O... IT MUST BE
        ORI     DEVICE  ;CALLED EACH TIME YOU DO AN 'IN'
        OUT     PORT+7  ;OR AN 'OUT'
        POP     PSW     ;
        POP     H       ;
        RET     ;RETURN TO THE ROUTINE
;
;----------------------------------------------------------
;PORT INITIALIZATION ROUTINE
;
INITIU  EQU     $
	CALL	SIGNON

	IF	INITIAL
;
;BAUD RATE DIVISORS FOR 8250'S
;
B110	EQU	1047
B300    EQU     384
B600    EQU     192
B1200   EQU     96
B2400   EQU     48
B4800   EQU     24
B9600   EQU     12
;
        PUSH H ! PUSH D ! PUSH B
        LXI     H,B300 ;GET BAUD RATE
        LDA     GROUP
        ORI     DEVICE
        OUT     PORT+7
        MVI     A,83H
        OUT     PORT+3
        MOV     A,L
        OUT     PORT+0
        MOV     A,H
        OUT     PORT+1
        MVI     A,3
        OUT     PORT+3
        OUT     PORT+4
        POP B  ! POP D  ! POP  H
        ENDIF   ;INITIAL
;
        RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
;       STATUS INPUT ROUTINE
;
INSPRU  EQU     $
        CALL	PREPARE ;INFORM THE PIC
        IN      PORT+5  
        ANI     21H
	PUSH	B
	RLC
	MOV	B,A
	RLC
	RLC
	ORA	B
	POP	B
	ANI	3
	ORI	4
        RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
;ERROR RESET ROUTINE
;
ERRSTU  EQU     $
        CALL    PREPARE ;INFORM THE PIC
        RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
;INPUT ROUTINE
;
INPRTU  EQU     $
        CALL    PREPARE ;INFORM THE PIC
        IN      PORT+0  ;GET DATA FROM PORT
        RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
;OUTPUT ROUTINE
;
OUTPRU  EQU     $
        CALL    PREPARE ;INFORM THE PIC
        OUT     PORT+0  ;SEND DATA TO REMOTE CPU
        RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
MESSGE:	DB	13,10,10
	DB	'Version for Morrow Decision or Multi/IO'
        DB      13,10
	DB	'Serial Port P2  25-Dec-82 by Robb Adams'
        DB      13,10,7,'$'
;
SIGNON:	PUSH B ! PUSH D ! PUSH H
	LXI	D,MESSGE
	MVI	C,9
	CALL	0005    ;ANOUNCE VERSION TO USER
	POP  H ! POP  D ! POP  B
	RET     ;RETURN TO BSTAM
;
;----------------------------------------------------------
	END	BEGIN
