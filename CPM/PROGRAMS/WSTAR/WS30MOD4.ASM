;**********************************************************************
;	WS30MOD4.ASM -- VERSION  - 3.00 For Epson RX-80 or MX-80F/T
;       BY RAYMOND E DIXON  JACKSONVILLE, FL  778-4048
;	TO MEMORY MAP MODEL 4/4P TRS-80 M-M CPM 2.31 - 2.22
;
; This program will modify all 12 arrow keys plus clear and break keys
; to match WS and return them back to cpm when you exit WS leaveing the
;  shifted  keys as WS keys.
; 
;             FOR WS 3.3 USE WS33MOD4.ASM
; Assemble with asm.com and overlay with Mload.com
;  This program is free to anyone who wishes to use it, all I ask is
; to leave my header in the file. Thanks !  
;**********************************************************************
; 	ASCII control code equates - to be used in defining patches.
;**********************************************************************
TRUE	EQU	1
FALSE	EQU	NOT TRUE	
;
CTRLA 	EQU	01H	;Start of Heading	;CONTROL A
CTRLB	EQU	02H	;Start of Text		;CONTROL B
CTRLC	EQU	03H	;CTRLC KEY		;CONTROL C
CTRLD	EQU	04H	;End of Transmission	;CONTROL D
CTRLE	EQU	05H	;Enquiry		;CONTROL E
CTRLF	EQU	06H	;Acknowledge		;CONTROL F
CTRLG	EQU	07H	;Bell			;CONTROL G
CTRLH	EQU	08H	;Backspace		;CONTROL H
CTRLI	EQU	09H	;Horizontal Tab		;CONTROL I
CTRLJ	EQU	0AH	;Line Feed		;CONTROL J
CTRLK	EQU	0BH	;Vertical Tab		;CONTROL K
CTRLL	EQU	0CH	;Form Feed		;CONTROL L
CTRLM	EQU	0DH	;Carriage Return	;CONTROL M
CTRLN	EQU	0EH	;REVERSE VIDEO OFF	;CONTROL N
CTRLO	EQU	0FH	;REVERSE VIDEO ON	;CONTROL O
CTRLP	EQU	10H	;Date Link Escape	;CONTROL P
CTRLQ	EQU	11H	;(X-ON)			;CONTROL Q
CTRLR	EQU	12H	;Device Control 2	;CONTROL R
CTRLS	EQU	13H	;(X-OFF)		;CONTROL S
CTRLT	EQU	14H	;Device Control 4	;CONTROL T
CTRLU	EQU	15H	;CLEAR EOL           	;CONTROL U
CTRLV	EQU	16H	;TOGGEL REVERSE VIDEO	;CONTROL V
CTRLW	EQU	17H	;End of Transmission 	;CONTROL W
CTRLX	EQU	18H	;Cancel			;CONTROL X
CTRLY	EQU	19H	;CLEAR EOS    		;CONTROL Y
CTRLZ	EQU	1AH	;CLEAR SCREEN		;CONTROL Z
ESC 	EQU    	1BH	;Escape			;CONTROL [
INSLIN	EQU	1CH	;INSERT LINE AT CURSOR	;CONTROL \
DELLIN	EQU	1DH	;DELETE LINE AT CURSOR 	;CONTROL ]
HOME	EQU	1EH	;HOME CURSOR     	;CONTROL ^
US	EQU	1FH	;Unit Separator		;CONTROL _
DELETE	EQU	7FH	;DELETE KEY
;___________________________________________________________________
;	LOGO PATCH AREA
;
	ORG	190H
	DB	'Memory  Mapped TRS-80 4/4p       ';Limit to 33 characters
;
	ORG	1B4H
	DB	'Epson MX-80F/T Printer           ';Limit to 33 characters
;
;	TERMINAL PATCH AREA
;
	ORG	248h	;origin of WordStar terminal patch area
HITE	DB	24	;24 lines on screen .
WID	DB 	80	;80 characters per line
;
	ORG	264H
UCRPOS	DB	0,0,0C9h	;Not used if terminal emulated
;
	ORG	2A4H
INISUB	JMP	ITERM   	;routine - set arrow keys.
UNISUB	JMP	XTERM		;routine - reset arrow keys.
USELST	DB	0FFH		;Enable character in last position. 
	DB	0,0,0		;Reserved bytes for expansion
DELCUS	DB	0		;Delay after cursor set
DELMIS	DB	0		;Delay after other functions
;
; The following section contains the primary code which implements
; memory map switching in mod 4/4p.  Be careful when modifying this
; section.
;
MEMAPV	DB	0FFH		;Use memory-mapped video
MEMADR	DW	0F800H		;MOD 4/4P Screen location
HIBIV	DB	0FFh		;Use underline for highlight
HIBCUR	DB	0FFh		;cursor set on self
CRBLIV	DB	0FFh		;blink cursor on self
;
	ORG	2BAH
UCNSTA	DB	0,0,0C9h	;no special console status from BIOS
UCONI	DB	0,0,0C9h	;no special console input
UCONO	DB	0,0,0C9h	;no special console output
;
;	SWITCH IN MEMORY MAPPED VIDEO 
	ORG	02C3H	
SWIN	DB	03EH	;LD	A,8EH
	DB	08EH	;OUT (84),A
	DB	0D3H	;RET
	DB	084H
	DB	0C9H
;
;	SWITCH OUT MEMORY MAPPED VIDEO
	ORG	02C9H
SWOUT	DB	03EH
	DB	08FH
	DB	0D3H
	DB	084H
	DB	0C9H
;
	ORG	2CFH
DEL1	DB	9	;SHORT DELAY	
DEL2	DB	3	;MEDIUM DELAY	
DEL3	DB	3 	;delay before help menus appear .
DEL4	DB	3	;delay after signon screen .
DEL5	DB	0	;delay after keystroke
	ORG	2DCH
DEFDSK	DB	1 ;1=A:,2=B:,3=C:,,12=M: TEST DRIVE FOR OVERLAYS
SCRLSZ	DB	22 ;LINES DISPLAYED ON CRT
;___________________________________________________________________
;	SPECIAL ROUTINES FOR model 4/4p trs - 80
;	Note that these routines use addresses within BIOS.  
	ORG	02E0h	;MORPAT (SPACE FOR USER TO 35B)
;	Routine -- clear screen, set arrow keys for Wordstar.
ITERM	MVI	C,26		;clear screen 
	CALL	CONOUT		
;
	DB	21H,21H,03H 	 ;LD	HL,KEYDE1	 ;set arrow keys
	DB	22H,33H,03H 	 ;LD	(KEYDEF),HL	 ; to Wordstar
	DB	18H,0DH	    	 ;JR	START

XTERM	MVI	C,26
	CALL	CONOUT
	DB	21H,35H,03H;XTERM:LD	HL,KEYDE2   	;set arrow keys
	DB	22H,33H,03H	 ;LD	(KEYDEF),HL 	;  to CP/M
	DB	18H,00H    	 ;JR	START

;
	DB	2AH,01H,00H;START:LD	HL,(0001H)   
	DB	01H,30H,00H      ;LD	BC,0030H     
	DB	09H              ;ADD	HL,BC
	DB      01H,10H,00H      ;LD	BC,0010H   
	DB      09H              ;ADD	HL,BC
	DB      5EH              ;LD	E,(HL)
	DB      23H              ;INC	HL
	DB      56H              ;LD	D,(HL)
	DB      21H,13H,00H      ;LD	HL,0013H     
	DB      19H              ;ADD	HL,DE
	DB    	0EBH        	 ;EX    DE,HL   
	DB	2AH,33H,03H	 ;LD	HL,(KEYDEF)
	DB	3EH,03H		 ;LD	A,03
	DB	01H,11H,00H	 ;LD	BC,0011H 
	DB	0EBH		 ;EX	DE,HL
	DB	09H		 ;ADD	HL,BC
	DB	0EBH		 ;EX	DE,HL
	DB	0EH,06H		 ;LD	C,6
	DB	0EDH,0B0H	 ;LDIR
	DB	13H		 ;INC	DE
	DB	3DH		 ;DEC	A
	DB	20H,0F2H	 ;JR	NZ,L025E
	DB	0C9H		 ;RET
;
; KEYDE1 IS THE KEY DEFINITION ON ENTERING WS
;
KEYDE1:	;UNSHIFTED KEYS
	DB	ESC	;CLEAR
	DB	CTRLC	;BREAK
	DB	CTRLE	;UP  
	DB	CTRLX	;DOWN
	DB	CTRLS	;LEFT
	DB	CTRLD	;RIGHT
	;
; SHIFTED KEYS
	;
	DB	CTRLX
	DB	CTRLC
	DB	CTRLR
	DB	CTRLC
	DB	CTRLA
	DB	CTRLF
	;
; CONTROL KEYS
	;
	DB	DELETE
	DB	CTRLC
	DB	CTRLK
	DB	CTRLJ
	DB	CTRLH
	DB	CTRLI
KEYDEF:	DW	0000H
;
; KEYDE2 IS THE KEY DEFINITION ON EXIT TO CPM
;
KEYDE2:	;UNSHIFTED KEYS
	DB	ESC	;CLEAR
	DB	CTRLC	;BREAK
	DB	CTRLK	;UP  
	DB	CTRLJ	;DOWN
	DB	CTRLH	;LEFT
	DB	CTRLI	;RIGHT
	;
; SHIFTED KEYS
	;
	DB	DELETE
	DB	CTRLC
	DB	CTRLE
	DB	CTRLX
	DB	CTRLS
	DB	CTRLD
	;
; CONTROL KEYS
	;
	DB	DELETE
	DB	CTRLC
	DB	CTRLK
	DB	CTRLJ
	DB	CTRLH
	DB	CTRLI
;
;	Output to console routine
;
CONOUT	LHLD	1		;fetch BIOS address
	MVI	L,0CH		;offset for console output routine
	PCHL			;jump to it
	RET
;
; *********  END AT 35BH, AS 035CH AND ABOVE ARE USED BY WORDSTAR **********
;
; 	PROGRAM OPTION PATCH SECTION
;
ON	EQU	0FFH
OFF	EQU	000H
;
	ORG	360H
ITHELP	DB	0		;initial help level: 0,1,2, or 3 (^JHn)
NITHLF	DB	ON		;
ITITOG	DB	OFF		;Insert mode flag (^V)
ITDSDR	DB	ON		;Directory display flag (^KF)
	ORG	366H
INITPF	DB	08		;Line height (in 1/48's)
	DB	66		;Paper length (in lines) (.PLn)
	DW	528 		;Paper length (in 1/48's) 
	DB	08		;Line height repeated here
	DB	03		;Top margin (in lines) (.MTn)
	DW	24  		;Top margin (in 1/48's)
	DB	08		;Line height repeated again
	DB	02		;Heading margin (in lines) (.HMn)
	DW	16  		;Heading margin (in 1/48's)
	DB	08		;Line height repeated again
	DB	08		;Bottom margin (in lines) (.MBn)
	DW	64  		;Bottom margin (in 1/48's)
	DB	08 		;Line height repeated again
	DB	02		;Footing margin (in lines) (.FMn)
	DW	16  		;Footing margin (in 1/48's)
	DB	08 		;Line height repeated again
	DB	0 		;Must be 0 for standard char width
	DB	12 		;Standard char width (1/120's)(12=10char/inch)
	DB	10 		;Alternate char width (1/120's)(10=12/inch)
	DB	08		;Page offset in characters (.POn)
INITLM	DB	1-1 		;Left margin minus 1
INITRM	DB	52-1		;Right margin minus 1
INITSR	DB	3 		;Superscript roll (in 1/48's) 
	ORG	385H
INITWF	DB	ON		;Word wrap flag (^OW)
	DB	ON		;Justification flag (^OJ)
	DB	ON		;Variable tabs flag (^OV)
	DB	OFF		;Soft hyphen entry flag (^OE)
	DB	OFF		;Hyphen help flag (^OH)
	DB	ON		;Print control display flag (^OD)
	DB	ON		;Ruler display flag (^OT)
	DB	ON		;Dynamic page break flag
	DB	ON		;Page break display flag (^OP)
	DB	1		;Line spacing: 1-5 (.LS)
	ORG	391H
NONDOC	DB	OFF		;Enter WS in Non-document mode 
DECCHR	DB	'.'		;Decimal tab character 
	ORG	394H
DOTCHR	DB	'.'		;DOT command character
	ORG	396H
DOTSON	DB	ON		;Enable dynamic DOT command interpretation
	ORG	399H
HZONE	DB	4		;Hyphenation (3=shorter words, 5=longer words)
	ORG	3CAH		;change defaults in print command
PODBLK	DB	OFF		;Disk file output from Print flag
	DB	OFF		;Use forms feeds during print
	DB	OFF		;Suppress page format during print
	DB	OFF		;Pause between pages during print
	ORG	3D3H
ITPOPN	DB	OFF		;Omit page numbers during print
	DB	ON		;Micro justify flag
	DB	ON		;Bidirectional print flag
	ORG	3D8H
RVELIM	DB	','		;Delimiter character in data file
	ORG	3DBH
VARCH1	DB	'&'		;Variable start
VARCH2	DB	'&'		;Variable end
	ORG	422H		
AUTOBS	DB	0		;Automatic backspace 
;___________________________________________________________________
;
;   PRINTER PATCH SECTION
;
;	This section will be different for each printer.  Most 
;	parameters will consist of a character count, followed 
;	by a string of ASCII characters.
;
;       Make sure to leave the same number of bytes defined
;       as were previously defined for each parameter,
;       by adding or deleting trailing zeroes as needed.
;
	ORG	691H
BLDSTR	DB	3		;Number of strikes for boldface
DBLSTR	DB	2		;Number of strikes for doublestrike
	ORG	696H
PSCRLF	DB	2,0DH,0AH 	;Advance to next line sequence
	DB	0,0,0,0,0,0,0,0	
PSCR	DB	1,0DH,0,0,0,0,0	;Return carriage for overprint
PSHALF	DB	0,0,0,0,0,0,0	;Half line feed sequence
PBACKS	DB	1,08H,0,0,0,0	;Backspace character sequence
PALT	DB	1,0FH,0,0,0	;Alternate pitch (^PA) - 
PSTD	DB	1,12H,0,0,0	;Standard pitch (^PN) - 
ROLUP	DB	03,ESC,53H,0,0	;Superscript character sequence
ROLDOW	DB	03,ESC,53H,1,0	;Supscript character sequence
USR1	DB	2,ESC,'E',0,0	;User sequence 1 (^PQ) - Emphasized print on
USR2	DB	2,ESC,'F',0,0	;User sequence 2 (^PW) - Emphasized print off
USR3	DB	1,0EH,0,0,0	;User sequence 3 (^PE) - Double width on
USR4	DB	1,14H,0,0,0	;User sequence 4 (^PR) - Double width off
RIBBON	DB	2,ESC,'4',0,0	;Alternate ribbon (^PY) - Italics on
RIBOFF	DB	2,ESC,'5',0,0	;Standard ribbon (^PY) - Italics off
PSINIT	DB	02,ESC,40H,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
PSFINI	DB	02H,ESC,40H,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0	
	ORG	70BH
SOCHR	DB	'\'		;Character used for strikeout
ULCHR	DB	'_'		;Character used for underlining
;
	END
 