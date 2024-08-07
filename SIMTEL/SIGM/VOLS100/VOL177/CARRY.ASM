;	   CARRY.ASM ver 1.2
;	   (revised 6/24/81)
;	by Keith Petersen, W8SDZ
;
;This program runs up in high RAM.  It gets there
;by being moved there when CARRY <program name>
;is typed.
;
;The program in high RAM does the following:
;
;Loads and executes a .COM file named in command line,
;but first waits for the user to change disks.
;Arguements after requested .COM file name are passed
;to the executed program, thus making it possible to
;run ED or Wordmaster.
;
;Why this is useful: Users of single-drive systems
;may not have room for ED, WM, ASM, LOAD, or other
;such programs on their "work" disk.  This program
;makes it possible to change disks, get the editor
;assembler or loader, then change disks again.  CARRY
;must be on the same disk with the COM file it is to
;get.
;
;Command:  CARRY ED MYFILE.ASM
;	(gets ED.COM to edit MYFILE.ASM)
;
;Fixes/updates (in reverse order to minimize reading time):
;
;06/24/81 Added more documentation about ENDMARK. (KBP)
;
;NOTE: If you add improvements or otherwise update
;this program, please modem a copy of the new file
;to "TECHNICAL CBBS" in Dearborn, Michigan - phone
;313-846-6127 (110, 300, 450 or 600 baud).  Use the
;filename CARRYXX.NEW where XX is the new version nr.
;------------------------------------------------
;
;A marker has been placed at the end of this file to
;deliberately print an error message during assembly
;in order to determine the actual ending address of
;the program.  The error message will not affect the
;assembly.  Make sure you have free memory available
;up to the address shown.
;
;Change the following equate to an area in your
;high memory where this program may patch itself in.
;This may be below BDOS, provided that sufficient
;space is available below CARRY to load the requested
;COM file.
;
DEST	EQU	0FA00H	;RUNNING LOCATION OF CODE
;
;------------------------------------------------
;
BASE	EQU	0	;PUT 4200H HERE FOR ALTERNATE CP/M
;
PRINT	EQU	9
OPEN	EQU	15
STDMA	EQU	26
BDOS	EQU	BASE+5
FCB	EQU	BASE+5CH 
FCBEXT	EQU	FCB+12
FCB2	EQU	BASE+6CH
;
CR	EQU	0DH
LF	EQU	0AH
;
	ORG	BASE+100H
;
;Move the program up to high RAM and jump to it.
;
MOVEUP:	LXI	B,PEND-START+1		;NUMBER OF BYTES TO MOVE
	LXI	H,DEST+PEND-START+1	;END OF MOVED CODE
	LXI	D,SOURCE+PEND-START	;END OF SOURCE CODE
;
MVLP:	LDAX	D	;GET BYTE
	DCX	H	;BUMP POINTERS
	MOV	M,A	;NEW HOME
	DCX	D
	DCX	B	;BUMP BYTE COUNT
	MOV	A,B	;CHECK IF ZERO
	ORA	C
	JNZ	MVLP	;IF NOT, DO SOME MORE
	PCHL		;JUMP TO "START"
;
SOURCE	EQU	$	;BOUNDARY MEMORY MARKER
;
OFFSET	EQU	DEST-SOURCE	;RELOC AMOUNT
;-----------------------------------------------;
;	The following code gets moved		;
;	to high RAM located at "DEST",		;
;	    where it is executed.		;
;-----------------------------------------------;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XX   C A U T I O N :  If modifying anything 	XX
;XX 	in this program from here on: 		XX
;XX  	A-L-L labels must be of the form:	XX
;XX	LABEL	EQU	$+OFFSET		XX
;XX	in order that the relocation to high	XX
;XX	RAM work successfully.  Forgetting to	XX
;XX	specify '$+OFFSET' will cause the pro-	XX
;XX	gram to JMP into whatever is currently	XX
;XX	in low memory, with unpredictable	XX
;XX	results.  Be careful....		XX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;
START	EQU	$+OFFSET
	LXI	SP,STACK ;SET UP LOCAL STACK POINTER
;Move requested file name to our FCB
	LXI	H,FCB	;SOURCE
	LXI	D,MYFCB	;DESTINATION
	MVI	B,9	;LENGTH
	CALL	MOVE	;MOVE THE NAME
;Move arguement to default FCB
	LXI	H,FCB2	;SOURCE
	LXI	D,FCB	;DESTINATION
	MVI	B,13	;LENGTH
	CALL	MOVE	;MOVE THE NAME
;Clear FCB2 and initialize our FCB
	MVI	A,' '
	STA	FCB2+1
	XRA	A
	STA	FCB2
	STA	FCBEXT
	STA	MYFCB+32
;Set DMA address to 80H
	LXI	D,BASE+80H
	MVI	C,STDMA
	CALL	BDOS
;Open the file
	LXI	D,MYFCB
	MVI	C,OPEN
	CALL	BDOS
;Did it exist?
	INR	A	;A=> 0 MEANS "NO"
	JZ	BYERR	;NO FILE, EXIT ERROR MSG
;
OPENOK	EQU	$+OFFSET
	LXI	D,BASE+100H	;POINT TO TPA
;
READLP	EQU	$+OFFSET
	PUSH	D	;SAVE BUFFER ADDRESS
	PUSH	B
	PUSH	H
	MVI	C,STDMA
	CALL	BDOS
;Read a sector
	LXI	D,MYFCB
	MVI	C,20	;READ
	CALL	BDOS
	POP	H
	POP	B
	ORA	A	;OK?
	JNZ	EOF	;NOT OK, MUST BE EOF
	POP	D	;GET DMA ADDR
	LXI	H,80H	;LENGTH OF 1 SECT.
	DAD	D	;CALC NEXT BUFF ADDR
	XCHG		;PUT IT BACK IN DE
	JMP	READLP	;LOOP
;
;Got return code on read, see if error or EOF
;
EOF	EQU	$+OFFSET
	POP	D	;DELETE STACKED BUFFER ADDR
;A has return code from read
	DCR	A	;EOF?
	JZ	RSDMA	;YES, EXIT
;
;Read error - exit with message
BYERR	EQU	$+OFFSET
	CALL	ERXIT	;PRINT:
	DB	CR,LF,'++DISK READ ERROR or FILE NOT FOUND++',CR,LF,'$'
;
;Exit with error message
ERXIT	EQU	$+OFFSET
	POP	D
	MVI	C,9	;PRINT ERROR MESSAGE
	CALL	BDOS
;
ERXIT2	EQU	$+OFFSET
	XRA	A
	STA	BASE+4	;SET DRIVE A:, USER 0
	JMP	BASE
;
;Reset DMA address to normal
RSDMA	EQU	$+OFFSET
	LXI	D,BASE+80H
	MVI	C,STDMA
	CALL	BDOS
;
REASK	EQU	$+OFFSET
	LXI	D,RDYMSG
	MVI	C,9	;PRINT READY MESSAGE
	CALL	BDOS
	MVI	C,1	;GET CONSOLE CHAR.
	CALL	BDOS
	CPI	'C'-40H	;CTL-C?
	JZ	ERXIT2	;YES, EXIT
	CPI	CR	;CARRIAGE RETURN?
	JNZ	REASK
;
	MVI	C,13	;RESET DISK SYSTEM
	CALL	BDOS
;
;Leave warm boot address on stack, them execute file
	LXI	H,BASE+0
	PUSH	H
	JMP	BASE+100H	;EXECUTE PROGRAM
;
;Move (HL) to (DE), length in (B)
;
MOVE	EQU	$+OFFSET
	MOV	A,M	;GET A BYTE
	STAX	D	;PUT AT NEW HOME
	INX	D	;BUMP POINTERS
	INX	H
	DCR	B	;DEC BYTE COUNT
	JNZ	MOVE	;IF MORE, DO IT
	RET		;IF NOT,RETURN
;
RDYMSG	EQU	$+OFFSET
	DB	CR,LF,'CHANGE DISKS THEN PRESS RETURN '
	DB	'TO CONTINUE (CTL-C ABORTS) > $'
;
MYFCB	EQU	$+OFFSET
	DB	0,'        COM',0
;
PEND	EQU	$+OFFSET ;END OF RELOCATED CODE
;
	DS	20	;ROOM FOR OUR FCB
	DS	40	;ROOM FOR OUR STACK
STACK	EQU	$+OFFSET ;LOCAL STACK
;
ENDMARK	EQU	$+OFFSET ;! IGNORE ERROR. THIS MARKS END OF PGM
;
	END
