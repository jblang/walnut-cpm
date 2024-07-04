; QTO-HP1C.ASM - QTERM Overlay for Hewlett-Packard HP-125 Computer
;
; Author: Mike Freeman 17-Apr-89
; 301 N.E. 107th Street; Vancouver, Wa 98685; (206)574-8221
;
; See QTERM.PAT for documentation of QTERM's patch area
;
; I claim no copyright on this overlay; as a road-sign in Oklahoma
; once said:  "No Speed Limit -- Do Your Damnedest"
;
; The program QTERM is Copyright 1989 by DPG (David Goodenough)
;
; Revised 04/19-89 to save/restore all Z80 registers (including IX and IY)
; during BDOS calls; Ymodem Batch transfers now work -- Mike Freeman
; Revised 04/25/89 to home cursor/clear screen upon QTERM entry/exit
; Also made Z80-specific code more obvious by commenting in Zilog instructions
; -- Mike Freeman --
; Revised 04/26/89 to map/unmap RDR/PUN last to avoid escape sequences
; showing up/not being interpreted properly after QTERM exits if the HP-125
; has been placed in Remote Mode -- Mike Freeman
; Revised 04/28/89 to trim screen-clearing code at startup/exit -- Mike Freeman
;
;This overlay adapts QTERM.COM from QTERMxxx.LBR to run on the Hewlett-Packard
;HP-125 Series 100 Business Computer running a HP-modified CP/M Version 2.2
;operating system.  This overlay is a full QTERM implementation except that:
;(1) Break is not implemented (a Break can be sent from the Keyboard only);
;(2) The DTR-manipulation/modem hangup routines are not implemented; (3) The
;routine to change Baud-rate is not implemented (this is changed from the
;Keyboard's Configuration Menu); (4) Stop-bit manipulation is not implemented
;(HP gives the user no way to do this) and (5) changing of parity is not
;implemented (this is also changed from the Configuration Menu).  The Hp-125
;consists of 2 Z80 processors: one is the CPU and the other handles terminal
;I/O.  HP does not allow the user to access the Z80 I/O ports directly.
;However, HP does provide the CP/M Reader and Punch BDOS calls along with
;a "subfunction" call (passed in BC) to get Reader status.  When properly
;mapped, the Reader takes input from Datacomm Port 1 and the Punch sends output
;to Datacomm Port 1.  All data is in the form 8N1 and special provisions must
;be made to insure that all 8 bits of data are sent/received by DAtacomm 1.
;(Datacomm 2, the Printer Port, can only accommodate 7-bit data).  Device
;mapping of Reader/Punch to Datacomm Port 1 is accomplished by sending a series
;of escape sequences to the HP-125's Console (rather than using the IO byte).
;
;To assemble QTO-HP1C.ASM using ASM:
;A>ASM QTO-HP1C

;To produce the modified QTERM.COM ready for use with the HP-125 using MLOAD:
;A>MLOAD QTO-HP1=QTERM.COM,QTO-HP1C.HEX
;
;
; Parameters
;
HAYES	EQU	000H		;Nonzero means HAYES-style hang-up string
;
;BDOS equates
;
BOOT	EQU	0		;CP/M Warm-start
RDR	EQU	3		; Reader input
PUN	EQU	4		; Punch output
BDOS	EQU	5		; BDOS entry
DCONIO	EQU	6		;Direct Console I/O
PRT	EQU	9		; Print "$"-terminated string to Console
;
;Special HP subfunctions
;
RDRSTS	EQU	70FFH		; Get Reader status (A nonzero if char ready)
BITS8	EQU	73FFH		; Set Datacomm 1 to pass 8-bit data
BITS7	EQU	74FFH		; Set Datacomm 1 to allow only 7-bit data
JVT	EQU	7EFFH		; Jump-vector (BIOS routine address) transfer
;
;Ascii equates
;
ESC	EQU	1BH		; <ESC>
;
;Routine addresses
;
CONOUT	EQU	0109H		; Character in C to Console
DECOUT	EQU	010CH		; Number in HL to Console in decimal
;
	ORG	0110H		; Overlay starts here
;
;Get modem (Reader) status
;
	PUSH	B		;Protect BC
	LXI	B,RDRSTS	; Set subfunction call to
	CALL	ENTRY		; Get Reader status
	POP	B		;Restore registers
	RET			; And return
	DS	120H-$ AND 0FFH
;
;Get modem character into A
;
	PUSH	B		;Save BC
	MVI	C,RDR		; Set function call to
	CALL	ENTRY		;Get character
	POP	B		;Restore BC
	RET			;and return
	DS	130H-$ AND 0FFH
;
;Get Punch status (always true)
;
	XRA	A		;Set Z
	INR	A		;Clear Z
	RET			; And return
	DS	140H-$ AND 0FFH
;
;Send character in A to Punch
;
	PUSH	PSW		;Save registers
	PUSH	B		;...
	PUSH	D		;...
	MOV	E,A		; Put character in E
	MVI	C,PUN		; Set function call to
	CALL	ENTRY		;Send character
	POP	D		;Restore registers
	POP	B		;...
	POP	PSW		;...
	RET			;and return
	DS	150H-$ AND 0FFH
;
;Set Break (not implemented)
;
	RET			; ...
	DS	160H-$ AND 0FFH
;
;Clear break (not implemented)
;
	RET			; ...
	DS	170H-$ AND 0FFH
;
;Kill DTR routines/modem hang-up string (not implemented)
IF HAYES
;
	RET			;Modem hangup string follows
	DB	10,0FEH,'+++',0FEH,'ATH0',0DH
;
ENDIF ; HAYES
;
IF NOT HAYES
;
;
	DB	0,0C9H		; ...
;
ENDIF ;NOT HAYES
;
	DS	180H-$ AND 0FFH
;
;Restore DTR (not implemented)
;
	RET			; ...
	DS	190H-$ AND 0FFH
;
;Baud-rate setting routine (not implemented
;
	RET			; ...
	DS	1B0H-$ AND 0FFH
;
;Set Parity/Stop-bits (not implemented)
;
	RET			; ...
	DS	1CCH-$ AND 0FFH
;
	DS	1		;Reserved for future use
;
	DS	1		; Transfer size
;
	DB	4		; Processor speed in mHz
;
	DB	'\'-40H		; Escape character
;
	DB	'HP-125 Series 100',0 ; Sign-on id
	DS	1F0H-$ AND 0FFH
;
HOMCLR:	DB	ESC,'H',ESC,'J',0 ; Home cursor/clear screen
	DS	200H-$ AND 0FFH
;
;MOVETO - Place cursor in row/column H/L
;
MOVETO:	PUSH	H		; Save row/column
	MVI	C,ESC		; Send cursor leadin
	CALL	CONOUT		; ...
	MVI	C,'&'		; ...
	CALL	CONOUT		; ...
	MVI	C,'A'+20H	; ...
	CALL	CONOUT		; ...
	POP	H		; Get row/column
	PUSH	H		; Save again
	MOV	L,H		; Get row
	MVI	H,0		; Make 16-bit integer
	CALL	DECOUT		; Type in decimal to Console
	MVI	C,'R'+20H	; Say it was a row
	CALL	CONOUT		; ...
	POP	H		; Get row/column
	MVI	H,0		; Isolate column as 16-bit integer
	CALL	DECOUT		; Type in decimal
	MVI	C,'C'		; Terminate sequence - column
	JMP	CONOUT		; And return
	DS	22FH-$ AND 0FFH
;
	DB	0FFH		; Terminal capabilities (all)
;
	DB	ESC,'&@',0,0,0,0,0 ; Enhancement off
	DB	ESC,'&F',0,0,0,0,0 ; Enhancement on
	DB	ESC,'M',0,0,0,0,0,0 ; Delete line
	DB	ESC,'L',0,0,0,0,0,0 ; Insert line
	DB	ESC,'P',0,0,0,0,0,0 ; Delete character
	DB	ESC,'R',20H,ESC,'Q',08H,0,0 ; Insert character
	DB	ESC,'K',0,0,0,0,0,0 ; Clear to end-of-line
	DB	ESC,'J',0,0,0,0,0,0 ; Clear to end-of-screen
;
;
	JMP	INIT		; Initialization
	JMP	FINISH		; Termination
;
;Initialization code
;
INIT:	LXI	D,JBUF		; Point to dispatch vector address arg block
	LXI	B,JVT		; Set subfunction call to
	CALL	BDOS		; Get Reader input routine address
	LHLD	JBUF+3		; Remember this address
	SHLD	READ8+1		; For 8-bit Reader routine
	LXI	H,READ8		; Put this address in BIOS dispatch table
	LXI	B,BITS8		; Set up to set 8-bit passthru
				; And fall into common code
;
COMCOD:	PUSH	B		; Save passthru function code
	SHLD	JBUF+3		; Put BIOS dispatch address in arg block
	MVI	A,1		; Say we want to write into dispatch table
	STA	JBUF+1		; ...
	LXI	D,JBUF		; Point to jump vector argument block
	LXI	B,JVT		; Set subfunction call to
	CALL	BDOS		; Write routine address into dispatch table
	LXI	H,HOMCLR	;Start/end with a clean screen
	MVI	B,4		;4 characters in the escape sequence
COMCO0:	MOV	E,M		;Get character from escape sequence
	INX	H		;Increment pointer
	MVI	C,DCONIO	;Send character directly to the Console
	CALL	ENTRY		;...
;	DJNZ	COMCO0		;Get all characters
	DB	10H,COMCO0-$-1 AND 0FFH;...
	POP	B		; Get passthru code
	CALL	BDOS		;Set Passthru
	LXI	D,MAPSEQ	; Send mapping escape sequences
	MVI	C,PRT		; To the Console
	JMP	BDOS		; To do/undo Reader/Datacomm Port 1 mappings
				;and return
;
;Final (exit) code
;
FINISH:	LHLD	READ8+1		; Point to real Reader input address
	LXI	B,BITS7		; Set for 7-bit terminal passthru
	MVI	A,'9'		; Set to turn off Datacomm mappings
	STA	MAPSEQ+8	; ...
	STA	MAPSEQ+19	; ...
;	JR	COMCOD		; And branch to common code
	DB	18H,COMCOD-$-1 AND 0FFH;...
;
;Routine to read 8-bit data from Datacomm Port 1
;
READ8:	CALL	$-$		; Read data
	MOV	A,B		; Get 8-bit data
	RET			; And return
;
;Put BIOS routine address vector block here
;
JBUF:	DB	7,0,0C3H,0,0	; ...
;
;Escape sequence string to map Reader/Punch to Datacomm Port 1
;
MAPSEQ:	DB	ESC,'&i0s25d2M'	; Map Datacomm 1 to Reader
	DB	ESC,'&i10s16d2M$' ; And Punch to Datacomm 1
;
;ENTRY - Save/restore registers BC-IY and call BDOS
;
ENTRY:	PUSH	B		;Save registers
	PUSH	D		;...
	PUSH	H		;...
	DB	0DDH,0E5H	;PUSH IX
	DB	0FDH,0E5H	;PUSH IY
	CALL	BDOS		;Do BDOS call
	DB	0FDH,0E1H	;Restore registers - POP IY
	DB	0DDH,0E1H	;POP IX
	POP	H		;...
	POP	D		;...
	POP	B		;...
	RET			;and return
;
	END			; End of overlay
                                  