; NEW05.ASM - Displays KMD.LOG in reverse order - 05/04/86
;
;			    NEW.ASM
;			       by
;			  Irvin M. Hoff
;	     copyrighted for use with public domain
;			 (17 July 1985)
;
	ASEG			; For M80 and RMAC, ignore if using MAC
;
;
; This program is really two-in-one.  It is for use with RCPM systems
; having a KMD.LOG of all file transfers created by the KMD file pgm.
;
;    Program 1 = shows the KMD.LOG in reverse order, newest first
;    Program 2 = shows only uploads in reverse, ignoring downloads
;
;=======================================================================
;		              Revisions
;
; 05/10/86  Sorry for another release, but an error came up when the
;    v06    file got to big.  Now it will be able to read up to
;           65000, 128 byte records.  I tested it on at 130+k file and
;           it work fine.
;	                       Joubert Berger
;
; 05/04/86  Rewrote the entire read file section so it would read the
;    v05    the file backwards.  Now, there is no more wait while it
;           reads the entire file into memory.  On most RCPM's, users
;           only read the first few enteries anyway, so why bother
;           reading the entire file.  This was quit anoying.  So now it
;           will read the file one line at a time, backwards, and display
;           it like it is supposed to.  At the lable FILE: put in whatever
;	    your up/download log file is called.
;
;           It struck me that one could use this program to read the
;           CALLER file of BBS systems.  This has come in handy many times
;           when I wanted to see who has called latley, and not have to
;           use TYPE or WS.  I renamed it to CALL.COM and changed the file
;	    name at the lable FILE: to whatever my BBS caller file was called.
;	    I set all options to zero and it worked great....
;						Joubert Bergere
;						Atlanta Kaypro MBBS
;						(404) 923-258 [300/1200]
;
; 08/20/85  Redated for use with KMD04	- Irv Hoff
; 07/17/85  Original version for KMDxx	- Irv Hoff
;
;=======================================================================
;
; SHOWAL set to 0 - gives Program 1
; ---------------------------------
; When the SHOWAL option is set to "0", all files in the KMD.LOG are
; shown in reverse order.  This is particularly useful to SYSOPs to see
; who has most recently uploaded/downloaded any files and what they are.
; It can be placed in A15: with other private .COM files or A0: for all
; to use, if desired.  Call this program ALL.COM for easy reference.
;
; SHOWAL set to 1, gives Program 2
; --------------------------------
; This program displays the "R" (new files) entries entered by KMD.COM
; into the KMD.LOG file, in inverse order.  It replaces the WHATSNEW
; files used in the past for RCPM systems.  (If the wheel byte is set
; for the SYSOP's use, it includes any "P" private uploads.  These are
; shown with an "*" after the drive/user number.)  This program is de-
; signed to work with KMD.COM.	It may need to be customized slightly,
; depending on how your LASTCALR file is arranged.  It goes in the A0:
; area and can be called from any drive/user area.  It is essentially
; self-maintaining, which makes it quite different from WHATSNEW pro-
; grams previously used (made via D-29), etc.  It is 1k long and fully
; secure.  (Change equates below if your KMD.LOG isn't in A14: area.)
;
;	NOTE:  You can use DDT to set the following byte:
;
;		0103H 00 program 1, shows all file transfers
;		      01 program 2, uploads only, for NEW.
;
;		Then  A>SAVE 5 NEW.COM
;
;		Suggestion:  Make one of each, call one ALL.COM
;		ahd put it on A15: for easy use by the SYSOP and
;		the other NEW.COM and put on A0: for all to use.
;
;-----------------------------------------------------------------------
;
; INFO:
; ----
;	A companion program currently called KMDEL automatically
;	deletes all downloaded files from KMD.LOG, keeping the
;	uploads for NEW.  This minimimizes the length of the KMD.LOG
;	file, since "most" of the lines are for downloads.  The com-
;	bination of NEW and KMDEL make the entire new file display
;	almost fully self-maintaining.
;
;-----------------------------------------------------------------------
;
; OPTIONS:
; -------
;    SHOWAL  0 = Shows all files in the KMD.LOG in reverse manner
;		    Makes this into a second program, see below
;	     1 = Allows options above to work normally
;
;    OPTION  0 = No header, shows "R" lines of KMD.LOG "as is".
;	     1 = Header, uses example 1 below  (OxGate 001 system)
;	     2 = Header, uses example 2 below  (Potpourri system)
;
;    HEADER  0 = No header, regardless of option below
;	     1 = use header selected by option below
;
;---------------
;
; Example 0:  (no header, no changes, before and after the same.  Picks
;	      out the "R" lines from the KMD.LOG and displays in re-
;	      verse order (newest uploads, first).
;
;---------------
;
; Example 1:  OxGate 001
;
;		(before)
;
; R6 02:22 B00>M7DATA-1LBR		26k Irv Hoff 08/20/85
;
;		(after)
;
; D/U	 Filename   Size   Speed    Uploaded by
;
; B00: M7DATA-1.LBR  26k  1200 bps  Irv Hoff 08/20/85
;
;---------------
;
; Example 2:  Potpourri
;
;		(before)
;
; R6 02:22 B00>M7DATA-1LBR		26k 08/20/85 16:44 Irv Hoff
;
;		(after)
;
; D/U	 Filename   Size   Speed      Date    Time   Uploaded by
;
; B00: M7DATA-1.LBR  26k  1200 bps  08/20/85  16:44  Irv Hoff
;
;-----------------------------------------------------------------------
;
; Features:
; ---------
;	1) Should be placed in A0: so any user can call the program
;	2) Should be renamed to NEW.COM at that time
;	3) Automatically remembers current drive/user area
;	4) Jumps to A14: to read the KMD.LOG file, with full security
;	5) Opens the KMD.LOG file, if empty says "NO NEW FILES"
;	6) Copies each line starting with "R" into a one-line buffer
;	7) Customizes that line, if OPTION 1 or 2 is selected
;	8) Stores the line in a memory buffer
;	9) When all lines are read, displays them in inverse order,
;		thus showing most recent files first.
;      10) CTL-C, CTL-K, CTL-X, C, K, X, c, k, x all will abort after
;		finishing the current line.
;      11) Can be called from any drive/user area
;      12) Returns to original drive/user area from which it was called
;
; The SYSOP can readily customize this program to suit his preferences.
; The area around HEAD: would be the sections to customize if
; selection 1 or 2 is not sufficient.
;					- Notes by Irv Hoff W6FFC
;
;-----------------------------------------------------------------------
;
; 07/17/85  First version based on my WHATSNEW, version 03.
;					- Irv Hoff
;
;-----------------------------------------------------------------------
;
; User choices
;
SHOWAL	EQU	1		; 0=all file transfers, 1=uploads only
OPTION	EQU	2		; Must be 0, 1 or 2 (see above)
HEADER	EQU	1		; 0=no header, regardless of option
;
DRIVE	EQU	'A'		; KMD.LOG stored here in your system
USER	EQU	14		; KMD.LOG stored here in your system
;
WHEEL	EQU	003EH		; Location of wheel byte for RCPM use
;-----------------------------------------------------------------------
;
; Equates
;
CR	EQU	0DH		; Carriage return
EOF	EQU	1AH		; End of file - ^Z
LF	EQU	0AH		; Line feed
TBUF	EQU	0080H		; Default buffer address
;
;-----------------------------------------------------------------------
;
; BDOS equates
;
BDOS	EQU	0005H		; CP/M BDOS entry address
RDCON	EQU	1		; Get character from console
WRCON	EQU	2		; Write character to console
PRINT	EQU	9		; Print string (DE) until '$'
CONST	EQU	11		; Get console status function
SELDSK	EQU	14		; Select requested disk drive
OPEN	EQU	15		; Open disk file
CLOSE	EQU	16		; Close disk file
READ	EQU	33		; Read random file
STDMA	EQU	26		; Set DMA address
SETUSR	EQU	32		; Set user area on disk
;
;-----------------------------------------------------------------------
;
; Program starts here
;
;
	ORG	100H
;
	JMP	START
;
;
SHOL:	DB	SHOWAL		; Shows complete KMD.LOG in reverse
OPTN:	DB	OPTION		; Simple selection without assembling
HDR:	DB	HEADER		; Selects header option
;
;
START:	LXI	H,0
	DAD	SP		; Get 'CCP' stack
	SHLD	STACK		; Save it for exit
	LXI	SP,STACK	; Set stack pointer
;
	LDA	0004H		; Get current drive/user
	STA	DRUSER		; Store
;
;
; Set drive/user to the KMD.LOG area listed above
;
	MVI	E,USER		; Set user to KMD.LOG area
	MVI	C,SETUSR
	CALL	BDOS
;
	MVI	A,DRIVE		; Set drive to KMD.LOG area
	SUI	41H
	MOV	E,A
	MVI	C,SELDSK
	CALL	BDOS
;
;
; Open source file
;
	CALL	ILPRT
	DB	CR,LF,0
	LXI	D,FILE
	MVI	C,OPEN
	CALL	BDOS
	INR	A		; Check for no open
	JZ	NONE		; No file, exit
;
	CALL	ILPRT
	DB	'NEW Type ^S to pause, ^C, ^X or ^K to abort'
	DB	CR,LF,LF,0
;
	LXI	D,FILE
	MVI	C,35		; Determine end-of-file
	CALL	BDOS
	LXI	D,BUFFER+81	; Stick a CR so it will get by the first time
	MVI	A,CR
	STAX	D		; Save it now
	DCR	E
	CALL	HEAD
;
READX:	PUSH	D
	LXI	H,RECORD	; Decrement record counter
	MOV	E,M		; Get 16 bit number into DE
	INX	H
	MOV	D,M
	DCX	D		; Now that we have the number, decrement
	MOV	M,D		; And now store it again
	DCX	H
	MOV	M,E
	MOV	A,E		; Now lets see if we are at the end
	CPI	0FFH		; First check high #
	JNZ	READLP		; Ok, go on - else,, check low number
	MOV	A,D
	CPI	0FFH		; One past zero, so we can get the last record
	JZ	TDONE		; We are at the end, so now finished with job
;
;
; Read sector from source file
;
READLP: LXI	D,TBUF		; Set the DMA for our read
	MVI	C,STDMA
 	CALL	BDOS		; And do it now
;
	LXI	D,FILE		; Now read the record
	MVI	C,READ
	CALL	BDOS
	POP	D		; Restore register
;
	ORA	A		; Read ok?
	JZ	GOAHEAD		; Yes, procede
	CALL	EXIT
	DB	CR,LF,'++ SOURCE FILE READ ERROR ++','$'
;
GOAHEAD:LXI	H,TBUF+127	; Set up end of buffer
	MVI	B,128		; The buffer will be filed up backwards
ONEMORE:MOV	A,M		; Get character
	ANI	7FH
	CPI	LF		; Check for end of line -- LF is our marker
	JZ	WRDISK		;  that we will use to determine each line
	CPI	7FH
	JZ	NEXTONE
	CPI	1AH		; Check for CTRL-Z, end-of-file marker
	JZ	NEXTONE
	XCHG
	MOV	M,A		; Store character in our working buffer
	XCHG
	DCR	E		; Decrement counters (DE=work buffer)
NEXTONE:DCR	L		;              (HL=DMA)
	DCR	B		;              (B=Counter for number of char.)
	JZ	READX		; If zero, go read another record
	JMP	ONEMORE
;
; Write sector to output file (with buffering)
;
WRDISK:	DCR	B		; Decrement our counter
	PUSH	PSW		; As well as the flags
	DCR	L		; Decrement our DMA buffer
	PUSH	H		; Save it
	PUSH	B		; Save counter
	XCHG			; HL will now be our working buffer
	MOV	M,A		; Go save CR
	LDA	SHOL		; Check options
	ORA	A
	JZ	WRDLOP		; If show all, go show all now
	INR	L		; If not, go see if it is a uploaded file
	MOV	A,M
	STA	STORE2		; Store this away for later
	DCR	L
	CPI	'S'		; Was this a "Send" file
	JZ	SENDX		; Yes, so go on
	CPI	'L'		; A "Library" file
	JZ	SENDX		; Yes, so go on
	LDA	WHEEL		; Check wheel for private files
	ORA	A
	JNZ	WRDLOP		; Ok, cheeck if it was a private file
	LDA	STORE2
	CPI	'P'		; It was Private, and wheel was not set, 
	JZ	SENDX		; So goodbye
;
WRDLOP:	MOV	A,M		; Get byte from read buffer
	MOV	B,A		; Save the character for now
	CPI	CR
	JZ	SENDLF		; Go send a CR and start all over again
	CPI	LF		; If LF then just send it to output
	JZ	SEND
;
; Will show entire KMD.LOG in reverse if requested
;
 	LDA	SHOL		; Check to see if show entire file
	ORA	A
	JZ	SEND
	LDA	COLUMN		; See if in first column
	ORA	A
	JNZ	WRDL3		; If not, exit
	INR	A
	STA	COLUMN		; Won't be in first column any longer
;
;
; Shows "P" entries only if wheel byte is set for SYSOP's use
;
	MOV	A,B		; Get the character back
	CPI	'P'		; This line a private upload?
	JNZ	WRDL1		; If not, exit
	LDA	WHEEL
	ORA	A
	JZ	WRD2		; "P" lines not shown without wheel byte
	STA	PRIVT		; To distinguish "P" lines when shown
	STA	STORE		; Just in case it is
	JMP	WRDL4
;
WRDL1:	CPI	'S'
	JNZ	WRDL11
	XRA	A
	STA	STORE
	STA	COLUMN
	JMP	SENDX
;
WRDL11:	CPI	'R'		; This a "received file"?
	STA	STORE		; Set the flag just in case
	JZ	WRDL4		; If 'R', keep the flag set
;
WRD2:	XRA	A
	STA	STORE		; Otherwise reset flag to zero
;
WRDL3:	LDA	STORE		; Storing into memory?
	ORA	A
	JZ	NEXT		; If not, exit
;
WRDL4:	LDA	COLUMN		; Increment the column counter
	INR	A
	STA	COLUMN
;
;
; The following retains original format of KMD "R" lines
;
	LDA	OPTN		; Get option
	ORA	A
	JZ	SEND		; If not customizing, exit
	LDA	COLUMN		; Get the column count back
	CPI	3		; User's modem speed is in column 2
	JNZ	WR1		; If not column 2, continue
	MOV	A,B		; Otherwise get the character
	STA	STORE		; Store it for conversion to baud rate
	JMP	NEXT		; Do not print the "MSPEED" number
;
WR1:	CPI	11
	JC	NEXT		; Skip everything through column 9
	CPI	14
	JC	SEND		; Print everything through column 12
	JNZ	WR4
	LDA	PRIVT		; Going to distinguish a "P" line?
	ORA	A
	JZ	WR2
	XRA	A
	STA	PRIVT
	MVI	B,'*'
	CALL	SEND1
	JMP	WR3

;
WR2:	MVI	B,':'		; Stick in a colon after column 12
	CALL	SEND1
;
WR3:	MVI	B,' '		; Send a space
	JMP	SEND
;
WR4:	CPI	22		; Print through column 20
	JC	SEND
	JNZ	WR5
	CALL	SEND1		; Send character in colum 21
	MVI	B,'.'		; Add a period after the file name
	JMP	SEND
;
WR5:	CPI	27
	JC	SEND		; Print file type and some spaces
	CPI	39
	JC	NEXT		; Ignore the "big gap"
	CPI	43
	JC	SEND		; Print the file size
	JZ	WR6
;
;
; Customizes area after the file size
;
	LDA	OPTN
	CPI	1
	JZ	SEND		; If option 2, exit
	LDA	COLUMN		; Get the column count back again
	JMP	WR7		; If not column 42, continue
;
WR6:	CALL	SEND1		; Print first space
	CALL	SEND1		; Add two extras
	CALL	BAUD		; Print the baud rate and two spaces
	JMP	NEXT
;
WR7:	CPI	52
	JC	SEND		; Print the date
	JNZ	WR8
	CALL	SEND1		; Print first space after date
	JMP	SEND		; Add a space
;
WR8:	CPI	58
	JC	SEND		; Print the time program was sent
	JNZ	SEND		; If not column 57, continue
	CALL	SEND1		; Print the first space
	CALL	SEND1		; Add two spaces
	JMP	NEXT		; Continue with rest of line (name)
;
SEND:	PUSH	H		; Keep buffer address
	MOV	A,B		; Get the character back
	CALL	OUTCHR
	POP	H		; Get input buffer address back
;
NEXT:	INR	L		; Done with sector?
	JMP	WRDLOP		; No, get another byte
;...
;
;
SEND1:	PUSH	H		; Keep buffer address
	MOV	A,B		; Get the character back
	CALL	OUTCHR
	POP	H		; Get input buffer address back
	RET
;.....
;
;
SENDLF:	XRA	A
	STA	COLUMN		; Othewise in column 0 now
	CALL	ABORT		; Want to quit already?
;
SENDL1:	LDA	COUNT
	INR	A		; Just to get a positive value
	STA	COUNT		; Have at least one line to show
	CALL	ILPRT
	DB	CR,0
SENDX:	XRA	A		; Now restore everything so 
	STA	COLUMN		; We can get on with our business
	LXI	D,BUFFER+80
	POP	B
	POP	H
	POP	PSW
	JZ	READX		; If we out of character in DMA buffer, 
	JMP	ONEMORE		;  go read  a sector
;.....
;
;
;-----------------------------------------------------------------------
;
;			  SUBROUTINES
;
;-----------------------------------------------------------------------
;
; Aborts the display when requested, but only at end of line
;
ABORT:	PUSH	H		; Save the TBUF address
	PUSH	D
	PUSH	B
	MVI	C,CONST		; Check to see if key pressed
	CALL	BDOS
	ORA	A
	JZ	ABORT3		; If no key pressed, then continue
	MVI	C,RDCON		; If key pressed, then check for abort
	ANI	7FH		; Remove parity, insure upper-case
	CALL	BDOS
	CPI	'S'-40H		; CTL-S to pause?
	JNZ	ABORT1		; If not, exit
	MVI	C,RDCON		; Otherwise wait for another character
	CALL	BDOS
	ANI	7FH		; Remove parity, insure upper-case
;
ABORT1:	CPI	'C'-40H		; Is it CTL-C?
	JZ	ABORT2
	CPI	'K'-40H		; Is it CTL-K?
	JZ	ABORT2		; If no, then continue
	CPI	'X'-40H		; Is it CTL-X?
	JZ	ABORT2
	ANI	5FH		; Convert to upper-case
	CPI	'C'
	JZ	ABORT2
	CPI	'K'
	JZ	ABORT2
	CPI	'X'
	JNZ	ABORT3
;
ABORT2:	POP	B		; Reset the stack
	POP	D
	POP	H
	POP	H		; Clear "CALL ABORT" from stack
	CALL	EXIT		; If yes, then print abort message
	DB	CR,LF,LF,'++ ABORTED ++','$'
;
ABORT3:	POP	B
	POP	D
	POP	H
	RET
;.....
;
;
; Shows the received baud rate
;
BAUD:	LDA	STORE
	CPI	'0'
	JZ	B110
	CPI	'1'
	JZ	B300
	CPI	'5'
	JZ	B1200
	CPI	'6'
	JZ	B2400
	MVI	B,' '
	CALL	SEND1
	CALL	SEND1
	CALL	SEND1
	CALL	SEND1
	JMP	BFIN2
;...
;
;
B110:	MVI	B,' '
	CALL	SEND1
	MVI	B,'1'
	CALL	SEND1
	MVI	B,'1'
	CALL	SEND1
	JMP	BFIN1
;
B300:	MVI	B,' '
	CALL	SEND1
	MVI	B,'3'
	JMP	BFINSH
;
B1200:	MVI	B,'1'
	CALL	SEND1
	MVI	B,'2'
	JMP	BFINSH
;
B2400:	MVI	B,'2'
	CALL	SEND1
	MVI	B,'4'
;
BFINSH:	CALL	SEND1
	MVI	B,'0'
	CALL	SEND1
;
BFIN1:	MVI	B,'0'
	CALL	SEND1
;
BFIN2:	MVI	B,' '
	CALL	SEND1
	MVI	B,'b'
	CALL	SEND1
	MVI	B,'p'
	CALL	SEND1
	MVI	B,'s'
	CALL	SEND1
	MVI	B,' '
	CALL	SEND1
	MVI	B,' '
	JMP	SEND1
;.....
;
;
; Print message then exit to CP/M
;
EXIT:	POP	D		; Get message address
	MVI	C,PRINT		; Print message
	CALL	BDOS
	CALL	ILPRT		; Print CRLF before quitting
	DB	CR,LF,0
;
	LDA	DRUSER		; Get original drive/user area back
	RAR
	RAR
	RAR
	RAR
	ANI	0FH		; Just look at the user area
	MOV	E,A
	MVI	C,SETUSR	; Restore original user area
	CALL	BDOS
;
	LDA	DRUSER		; Get the original drive/user back
	ANI	0FH		; Just look at the drive for now
	MOV	E,A
	MVI	C,SELDSK	; Restore original drive
	CALL	BDOS
;
	LHLD	STACK
	SPHL
	RET
;.....
;
;
; Inline print routine - prints string pointed to by stack until a zero
; is found.  Returns to caller at the next address after the zero ter-
; minator.
;
ILPRT:	XTHL			; Save HL, get message address
;
ILPLP:	MOV	A,M		; Get the character
	CALL	TYPE		; Show on the CRT
	INX	H		; Next character location
	MOV	A,M		; Get the character
	ORA	A		; If Zero, all done
	JNZ	ILPLP		; Else keep going
	XTHL			; Restore HL, ret address
	RET			; Return past the end of the message
;.....
;
;
; Output a character to the new file buffer - first, see if there is
; room in the buffer for this character.
;
OUTCHR:	PUSH	PSW		; Store the character for now
	CALL	TYPE
	POP	PSW
	RET
;.....
;
;
; Transfer is done - close destination file
;
TDONE:	MVI	C,CLOSE
	LXI	D,FILE
	CALL	BDOS
TDONE2:	CALL	EXIT
	DB	CR,LF,LF,CR,'[End of listing]','$'
;.....
;
;
;  Show the header at the beginning
;
HEAD:	LDA	HDR		; Using a header?
	ORA	A
	RZ			; If not skip header
	LDA	SHOL		; Showing entire KMD.LOG?
	ORA	A
	RZ			; If yes, don't bother with header
;
;
; Customizes header
;
	LDA	OPTN
	ORA	A
	RZ
	CALL	ILPRT
	DB	CR,'D/U    Filename   Size   Speed    ',0
	LDA	OPTN
	CPI	1
	JZ	TDONE1
	CALL	ILPRT
	DB	'  Date    Time   Uploaded by',0
	RET
;
TDONE1:	CALL	ILPRT
	DB	'Uploaded by  Date',0
	RET
;.....
;
;
; Send character in A register to console
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A		; Character to 'E' for CP/M
	MVI	C,WRCON		; Write to console
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
NONE:	CALL	EXIT
	DB	CR,'++ NO NEW FILES ++','$'
;
;
; 'Declare' output file
;
FILE:	DB	0
	DB	'LOG     SYS'
	DB	0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
RECORD:	DB	0,0,0
;
COLUMN:	DB	0		; Column of KMD.LOG line
COUNT:	DB	0
DRUSER:	DB	0		; Original drive/user, for return
LENGTH:	DB	0		; Maximum length of useable memory
PRIVT:	DB	0		; Distinguishes "P" lines if shown
STORE:	DB	0
STORE2:	DB	0
;
	DS	100		; Room for 50-level stack
;
;
; Set write buffer to even page boundry
;
;
BUFFER	DS	81		; Write buffer starts here
STACK	EQU	BUFFER-2
;
;
	END	START
; Set