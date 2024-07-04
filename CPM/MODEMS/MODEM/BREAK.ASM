	;
	;	Subroutine to send BREAK pulse
	;	using a 8251 UART
	;
	;	Destroys registers A, HL
	;
	;	Labels:
	;
	;	SIOSPT - UART status port
	;	TIME   - BREAK pulse timer
	;	BREAK  - Call address
	;	BREAK1   
	;

	SIOSPT	EQU	______

	;
	;	Serial status port
	;
	;

	TIME	EQU	01EFFH

	;
	;	used to time BREAK pulse
	;
	;	For 2 MHZ try 01EFFH
	;	For 4 MHZ try 01000H
	;

BREAK	MVI	A,03FH

	;
	;Sets UART as follows:
	;
	;BIT	description
	;
	; 0	Transmit enable true (1)
	; 1	Data terminal ready true (1)
	; 2	Receive enable true (1)
	; 3	Set BREAK pulse (1)
	; 4	Error reset true (1)
	; 5 	Request to send true (1)
	; 6	Internal reset false (0)
	; 7	Sync search mode (not used)(0)
	;

	OUT	SIOSPT	;Write to UART
	LXI	H,TIME	;Load timer
BREAK1	DCX	H	;decrement HL pair
	MOV	A,H		
	CPI	0
	JNZ	BREAK1	;Not done yet
	MOV	A,L
	CPI	0
	JNZ	BREAK1	;Still not done
	MVI	A,037H	;Clear BREAK pulse
	OUT	SIOSPT	;Write to UART
	RET
