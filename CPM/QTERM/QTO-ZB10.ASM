; QTO-ZB10.ASM - QTERM Overlay for Telcon Zorba Computer
;
; 04/12/89 - Created this overlay - Mike Freeman
;
; See QTERM.PAT for documentation of QTERM's patch area
;
; This overlay is a full implementation of QTERM for the Telcon Industries Inc.
; Zorba computer except that (a) 38.4 KBaud is not supporte  and
; (b) the terminal capabilities of Character Insertion and Character
; Deletion are absent.  This does not, however, affect either VT100-
; emulation or the <esc> W Window mode of operation.
; Communication is accomplished through Port A (the Communications Port).
;
; This overlay may be assembled by ASM, LASM or equivalent:
; A>ASM QTO-ZB10.AAZ
; and may be loaded over QTERM.COM with MLOAD:
; A>MLOAD QTERM.COM,QTO-ZB10.HEX
; to produce QTERM.COM adapted for the Zorba.
;
;**NOTE** as written, this overlay initializes the Zorba to start in 8N1 mode
; at 1200 Baud.  Change the parameters at INIT: to set a different 
; initialization configuration.
;
; The program QTERM is Copyright 1989 by DPG (David Goodenough).
; It may be found in the latest release of QTERMxxx.lbr (where xxx = version)
;
; I make no claim of copyright to this overlay.  As a road-sign in Oklahoma
; used to say, "No Speed Limit -- Do Your Damnedest"
; -- Mike Freeman; 301 N.E. 107th Street; Vancouver, Wa 98685;
; (206)574-8221
;
; Parameters
;
HAYES	EQU	000H		;Nonzero means use "+++ATH0" to hang up modem
;
; Symbols
;
BOOT	EQU	00H		;CP/M Warm-boot vector
BDOS	EQU	05H		;BDOS entry
;
;Port addresses
;
BRPORT	EQU	00H		;8254-2 Baud Rate Generator Timer for Port A
COMMND	EQU	03H		;8254-2 Timer Control Port
MDDATP	EQU	20H		;Modem Data Port (A)
MDCTL1	EQU	21H		;Modem Status (Port A)
;
;Modem status bits
;
MDSND	EQU	1		;Output Send Ready bit
MDRCV	EQU	2		;Receive (Input) Ready bit
;
;Port commands
;
MDMODE	EQU	82H	; Insures 8251 is out of mode with DTR high
MDRSET	EQU	42H	; Resets USART for additional commands
MDSET1	EQU	4EH	; 1 stop bit, no parity, 8 bits, 16x
MDSET2	EQU	0CEH	; 2 stop bits, no parity, 8 bits, 16x
MDCOM	EQU	17H	; Reset error flags, RCV, DTR, TX ready
;;
;Values for 8254-2 baud rate timer generator
;
BD300	EQU	1667		; 300 bps
BD600	EQU	833		;600 bps
BD1200	EQU	417		; 1200 bps
BD2400	EQU	208		; 2400 bps
BD4800	EQU	104		;4800 bps
BD9600	EQU	52		; 9600 bps
BD19200	EQU	26		;19200 bps
;
;Routine addresses
;
CONOUT	EQU	109H		;Output character in C to Console
DECOUT	EQU	10CH		;Output number in HL in decimal to Console
;
	ORG	110H		;Overlay starts here - Get Port input status
;
	IN	MDCTL1		;Check port status
	ANI	MDRCV		;Check for receive-ready
	RET			;and return
	DS	120H-$ AND 0FFH
;
;Get character from port
;
	IN	MDDATP		;Get character from port
	RET			;and return
	DS	130H-$ AND 0FFH
;
;Check output ready status
;
	IN	MDCTL1		;Get port status
	ANI	MDSND		;Check for output-ready
	RET			;and return
	DS	140H-$ AND 0FFH
;
;Send character to output
;
	OUT	MDDATP		;Send character in A to port
	RET			;and return
	DS	150H-$ AND 0FFH
;
;Start Break
;
	MVI	A,3FH		;DTR-normal, break on
	OUT	MDCTL1		;...
	RET			;Return
	DS	160H-$ AND 0FFH
;
;Clear Break
;
	MVI	A,37H		;DTR-normal, send-receive normal
	OUT	MDCTL1		;...
	RET			;Return
	DS	170H-$ AND 0FFH
;
;Drop DTR
;
IF NOT HAYES
;
	MVI	A,3DH		;Drop DTR
	OUT	MDCTL1		;Drop DTR
	RET			;Return
	DS	180H-$ AND 0FFH
;
;Raise DTR
;
	MVI	A,37H		;DTR, send, receive normal
	OUT	MDCTL1		;...
	RET			;Return
	DS	190H-$ AND 0FFH
;
ENDIF ;NOT HAYES
;
IF HAYES
;
	RET			;Use hangup string
	DB	10,0FEH,'+++',0FEH,'ATH0',0DH;Hang up string
	DS	190H-$ AND 0FFH
;
ENDIF ;HAYES
;
;Set baud rate
;
	JMP	LOADBD		;Load baud rate
	DS	1A0H-$ AND 0FFH
;
;Baud rate index table
;
BDTABL:	DB	0,0		;38 KBaud (not implemented)
	DB	1,0FFH		;19.2 KBaud
	DB	2,0FFH		;9600 Baud
	DB	3,0FFH		;4800 baud
	DB	4,0ffh		;2400 baud
	DB	5,0FFH		;1200 Baud
	DB	6,0ffh		;600 baud
	DB	7,0FFH		;300 Baud
;
	JMP	STUART		;1B0H - Set word-width, parity, stop-bits, x16
	DS	1C0H-$ AND 0FFH
;
;Table of parity/bits/stopbits
;
	DB	4AH		;7N1
	DB	4EH		;8N1
	DB	0CAH		;7N2
	DB	0CEH		;8N2
	DB	7AH		;7E1
	DB	7EH		;8E1
	DB	0FAH		;7E2
	DB	0FEH		;8E2
	DB	5AH		;7O1
	DB	5EH		;8O1
	DB	0DAH		;7O2
	DB	0DEH		;8O2
;
	DS	1		;1CCH - Reserved
;
	DS	1		;1CDH - Transfer buffer size
;
	DB	4		;1CEH - Clock speed
;
	DB	']'-40H		;1CFH - Escape character
;
;1D0H - Signon message
	DB	'Telcon Zorba',0 ;...
	DS	1F0H-$ AND 0FFH
;
;Clear screen
;
	DB	1BH,'H',1BH,'E',0
	DS	200H-$ AND 0FFH
;
;MOVETO - Cursor positioning
;
MOVETO:	PUSH	H		;Save coordinates
	MVI	C,1BH		;Transmit <esc>
	CALL	CONOUT		;...
	MVI	C,'Y'		;Cursor follows
	CALL	CONOUT		;...
	POP	H		;Get row/column
	PUSH	H		;Save again
	MOV	A,H		;Get row
	CALL	CUROUT		;Type it
	POP	H		;Get row/column again
	MOV	A,L		;Get row
CUROUT:	ADI	20H		;Make ASCII character
	MOV	C,A		;Put in C
	JMP	CONOUT		;and Output to Console
	DS	22FH-$ AND 0FFH
;
;Terminal capability mask
;
	DB	0CFH		;Everything except char deletion/insertion
;
	DB	1BH,71H,0,0,0,0,0,0;Alternate video off
	DB	1BH,70H,0,0,0,0,0,0;Alternate video on
	DB	1BH,'M',0,0,0,0,0,0;Delete line
	DB	1BH,'L',0,0,0,0,0,0;Insert line
	DB	0,0,0,0,0,0,0,0	;No delete character
	DB	0,0,0,0,0,0,0,0	;or insert character
	DB	1BH,'K',0,0,0,0,0,0;Clear to end-of-line
	DB	1BH,'J',0,0,0,0,0,0;Clear to end-of-screen
;
;
	JMP	INIT		;Jump to initialization code
	RET			;No termination is needed
	NOP			;...
	NOP			;...
;
;INIT - Initialization routine
;
INIT:	MVI	A,MDSET1	;Set 1 stop-bit, no parity, 8-bit, x16
	CALL	STUART		;...
	MVI	A,5		;Set initial speed to 1200 Baud
				;and fall into load baud-rate routine
;
;LOADBD - Load Baud rate
;
LOADBD:	DCR	A		;Make index zero-offset
	RLC		;times 2
	LXI	H,BDTBL1	;Point to real Baud-rate table
	MOV	E,A		;Put offset into DE
	MVI	D,0		;...
	DAD	D		;Compute address of correct Baud rate
LOADB0:	MVI	A,36H		;Set square wave
	OUT	COMMND		;...
	MOV	A,M		;Get LSB of Baud rate
	OUT	BRPORT		;Send to generator
	INX	H		;Point to MSB
	MOV	A,M		;Get it
	OUT	BRPORT		;Send to Baud rate generator
	RET			;and return
;
BDTBL1:				;Zorba Baud-rate table
	DW	BD19200,BD9600,BD4800,BD2400,BD1200,BD600,BD300
;
;STUART - Set UART (Word-width, Stop-bits, Parity, x16) - Parameter in A
;
STUART:	PUSH	PSW		;Save settings
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251A for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	POP	PSW		;Get parameters
	OUT	MDCTL1		;Set stop-bits, parity, word-width, x16
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDCOM		; Error reset, RCV, DTR, TX ready
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	RET			;Return
;
	END			;End of overlay
