;	title	'BISHOW v3.01 - buffered bidirectional file scroll utility'
;
; Ver 3.01, 15 Jan 84, Frans van Duinen, Toronto, Ont
;	- made unsqueeze message optional
;	- added library capability
;	- fixed bug in conditional assembly of CLRSCR
;
; Ver 2.09, 7 Jan 84, Frans van Duinen, Toronto, Ont
;	- Modified USQ routines for higher speed (+10%) and
;	 less memory usage.
;	- made USQ code optional through conditional assembly
;	- fixed a bug introduced with 2.08 and SHORT=TRUE 
;	  (resulted from ASM's inability to nest IF/ENDIF) 
;	- fixed a bug  that reset FCBEX after open, whenever
;	  sector 0 was read, (this resulted in BDOS assuming that
;	  the current extent, whose allocation group nos were still
;	  in the FCB, was the correct one. 
;	- Changed exit to clear screen only on Q or ^C exit,
;	  to leave any messages visible
;	- Made wait after clear screen a cond assembly option
;
; Ver 2.08, 2 Jan 84, Frans van Duinen, Toronto, Ont
;	- added squeezed file capability
;	- added sidewise scrolling on ^I, ^L, steps of 8
;	- Osborne support for cursor keys, clr scr & scr size
;	- Changed FILBAK rtn to recognize top of file
;	- Set up flag to avoid unnecessary re-reading of
;	  top of file 
;
;	The unsqueeze code was lifted from the USQ base code
;	by Dave Rand (Edmonton, Alberta) as adapted for LTYPE1
;	by S.Kluger (El Paso,Texas)
;	The code was lifted to allow continued use of ASM.COM 
;
; Ver 1.07, 1 Aug 83, Ted H. Emigh  ...!unc!tucc!emigh
;	- added screen width specification
;	- added screen definition commands (see notes below)
;
; Ver 1.06, 2 Jul 83, Chuck Forsberg
;	- added commands for more, mince, vi familiarity.
;	  Bad cmd gives help
;
; Ver 1.051, 26 June 83, Dick Mead
;	- added "?" for help on commands.
;
; Ver 1.05, 31 May 83, Bruce Ratoff
;	- added 'N' (next line) and 'P' (previous line) cmds
;	- decreased buffer from 8k to 4k (8k takes too long)
;
; Ver 1.04, 15 May 83, Keith Petersen, W8SDZ
;	- fixed bug which caused display past end-of-file
;		and added bogus eof in case none at file end
;	- added strip of high-order bit in line count routine
;	- added exit clear of any left-over keyboard character
;
; Ver 1.03, 11 May 83, Keith Petersen, W8SDZ
;	- fixed to allow assembly with ASM.COM
;	- fixed screen clear bug when crossing read boundries
;	- added strip for high-order bit in character before
;		printing (needed for WordStar files)
;	- improved stack routines
;	- fixed bug in console input routine
;	- removed Z80 dependant code (now works on 8080 too)
;
; Ver 1.02, 06 May 83, Lucien Pan, Toronto, Canada
; 	- fixed some minor bugs
; 	- returns to ccp w/o warm boot
; 	- filters form-feeds (useful in .PRN files)
; 	- scrolls foward/backwards by same number of lines
; 	- disable/enable cursor during scroll for H-19
;
; Ver 1.01, 30 Mar 83 - added BDOS function  6.  W.F.Mcgee
;
; Ver 1.00, 23 Aug 82 Phil Cary, 748 Kenilworth Parkway, Baton
; Rouge, LA  70808
;
; BISHOW is a  buffered,  bidirectional  version  of  SHOW.ASM
; which first appeared in Interface Age, November, 1981.  That
; program  could  only  scroll  forward  in  a  file, and read
; sectors from disk one at a time as they  were  sent  to  the
; console.   I  used SHOW frequently to take a quick look at a
; file without loading a  big  text  editor,  and  to  examine
; another  file  with the RUN command while in Wordstar.  TYPE
; does not work since it is not a file that Wordstar can  load
; and run.
;
; It was annoying when I went past the point I was looking for
; in a file with SHOW, and could not go backwards.  Thus, this
; bidirectional  version  which  uses  random access reads. In
; addition, buffering was added so that  the  number  of  disk
; reads  would  be  reduced,  and  moving  back and forth in a
; moderate sized file would be speeded up.  There is  a  trade
; off between the size of the buffer and the length of time it
; takes to refill the buffer which should be set to the user's
; preference.
;
; There are several customizing items in this program.  One is 
; the equate "maxsec" which sets the buffer size.   Another is 
; the  string  in the subroutine "clrscr" just after  the  org 
; statement.   This should be changed to erase the screen  and 
; home  the cursor for the user's terminal.   The program,  as 
; written,  requires a terminal with an erase screen and  home 
; cursor  function.   Some  terminals  do not allow  the  80th 
; column  to be filled without going to the  next  line.   For 
; this reason, the screen width ("maxchr") initially is set to 
; 79.   The screen sizes can be changed using the "S" (screen) 
; command.  The parameters that can be changed are the maximum 
; column  displayed ("maxchr"),  the minimum column  displayed 
; (allowing  you  to "window" the output),  and the number  of 
; lines ("scroln").   A zero for the maximum column  displayed 
; will  give and unlimited screen width.   The maximum  column 
; displayed  and  the number of lines can be set when  calling 
; BISHOW,  e.g.,  "BISHOW file.nam 79 24" will give 79 columns 
; and 24 lines,  and "BISHOW file.nam 79" will give 79 columns 
; with the default number of lines.  The last customizing item 
; is the "short" equate.   If this is chosen, the multiplicity 
; of command forms is not allowed (see the beginning to change 
; the  commands  used),  and certain messages  are  shortened.  
; This will allow BISHOW to fit into a 1K area.  If "short" is 
; false, the program is slightly over 1K.  Finally, direct I/O 
; to the console is used to avoid echoing the commands to  the 
; console as the CP/M write console function does.
;
; Just  a  small contribution to the public domain software as
; partial payment for the many fine and  educational  programs
; the system has given me.  Phil Cary.
;
;Define version number for help message
VERS	EQU	3		;Note current use in DB constrains VERS & 
REVS	EQU	10		; REVS to be one and two digits respectively
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
HEATH	EQU	FALSE		;assemble for H-19 terminal
OSBORNE	EQU	TRUE		;assemble for Osborne I
SHORT	EQU	FALSE		;set to true if you want the short version
				;which is less than 1K
				;Requires also that SQUEEZE is set false
SQUEEZE	EQU	TRUE		;Generate code to handle squeezed files 
NOWAIT	EQU	TRUE		;Do not wait after clear screen
SILENT	EQU	TRUE		;No "unsqueezing text" msg
LIBRARY	EQU	TRUE		;Optional handling of library type files
;
;	Operational equates
;
MAXSEC	EQU	32		;number of sectors in buffer
SQSIGN	EQU	0FF76H		;Signature for SQ files
LBSIGN	EQU	2000H		;Signature for library files
DLE	EQU	090H		;Char flag for run compression (SQ)
;
	IF	NOT OSBORNE
SCROLN	EQU	24		;number of lines per scroll
MAXCHR	EQU	79		;number of characters per line
ARWLFT	EQU	08H		;Cursor left key (backspace)
ARWRT	EQU	09H		;Cursor right key (tab)
	ENDIF
;
	IF	OSBORNE
SCROLN	EQU	24		;number of lines per scroll
MAXCHR	EQU	51		;number of characters per line
ARWLFT	EQU	08H		;Cursor left key (backspace)
ARWUP	EQU	0BH		;Cursor up key (vert tab)
ARWRT	EQU	0CH		;Cursor right key (formfeed)
	ENDIF

;
BASE	EQU	0		;standard zero base CP/M
;
;	BDOS functions
;
CONOUT	EQU	2		;console write
OPEN	EQU	15		;open file
CLOSE	EQU	16		;close file
READR	EQU	33		;read file random access
STDMA	EQU	26		;set dma address
;
;	Page zero equates
;
WBOOT	EQU	BASE		;warm boot entry point
BDOS	EQU	WBOOT+5		;BDOS entry point
FCB	EQU	WBOOT+5CH	;default fcb drive number
CMDTAIL	EQU	WBOOT+80H	;location of command tail
FCBFN	EQU	FCB+1		;start of filename
FCBFT	EQU	FCB+9		;start of filetype
FCBEX	EQU	FCB+12		;current extent number
FCBCRR	EQU	FCB+33		;current record number, random access
TPA	EQU	WBOOT+100H	;transient program area
;
;	ASCII equates
;
ENDMSG	EQU	0		;null
BELL	EQU	7		;bell
BS	EQU	8		;Backspace
TAB	EQU	9		;tab
LF	EQU	0AH		;line feed
CR	EQU	0DH		;carriage return
EOF	EQU	1AH		;end of file
ESC	EQU	1BH		;escape
SPACE	EQU	20H		;space
;
; Equates for the short version
;
; Any invalid command gives help
; in addition to quit, ^C ends the program
; Be sure to change the help2 printout
;
NXTPAG	EQU	SPACE		;next page
BACK	EQU	'B'		;scroll backward
NEXT	EQU	CR		;next line
PREV	EQU	'-'		;previous line
SCREEN	EQU	'S'		;set screen parameters
QUIT	EQU	'Q'		;exit bishow
FIRST	EQU	'1'		;first page
;
	ORG	TPA
;
	JMP	START		;skip over next subroutine
;
CLRSCR:
	CALL	CDISP		;command to erase screen and home cursor
;
	IF	NOT (HEATH OR OSBORNE)
	DB	ESC,'+',ENDMSG	;put your screen clear string here
	ENDIF
;
	IF	HEATH
	DB	ESC,'E',ENDMSG	;__for H/Z-19 terminal. change as required
	ENDIF
;
	IF	OSBORNE
	DB	1AH,ENDMSG	;__for Osborne (& Televideo?)
	ENDIF
;
	IF	NOT NOWAIT
;
WAIT:	MVI	B,0		;waste time (may or may not be necessary)
;
WAIT1:	XTHL			;good time gobbeler!
	XTHL
	DCR	B
	JNZ	WAIT1
;
	ENDIF
;
	RET			;return from clrscr
HELP2:
	CALL	CDISP
	DB	CR,LF,'Commands:',CR,LF
;
	IF	NOT SHORT
	DB	'^F,F,^V,sp=next page, ^B,B=back page, '
	DB	'^H=left, ^L=rite'
	DB	CR,LF
	DB	'CR,+,N=next line, '
	DB	'-,P=back line, 1=1st line, ^C,Q=exit',CR,LF,ENDMSG
	ENDIF
;
	IF	SHORT
	DB	'sp=next page, B=back page',CR,LF
	DB	'CR=next line, '
	DB	'-=back line, 1=1st line, ^C,Q=exit',CR,LF,ENDMSG
	ENDIF
;
	JMP	GETCMD
;
START:	LXI	H,0		;get ccp's stack
	DAD	SP
	SHLD	STACK		;save old stack for later
	LXI	SP,STACK	;set new stack
	LXI	H,CMDTAIL	;point to command tail
	MOV	B,M		;get number of char in tail
	INX	H		;point to first character
	INR	B
;
	CALL	EATSP		;Step to next non-bl in input
	JZ	OPENF		;no more characters
;
	CALL	FILNAM		;Skip file name, returns <B>=0 or <A>=20H
	JZ	OPENF		;only file name in tail
;
;			Check if there is a member name
;
	CALL	EATSP		;Step to next non-bl in input
	JZ	OPENF		;no more characters
	CPI	'9'+1		;Numeric?
	JNC	MEMB		;No -
	CPI	'0'
	JNC	NUMBER		;Yes - must be width & heigth
;			Have member name (at FCB+11H)
MEMB:
	STA	MEMNAM		;No - have member name
	PUSH	H		;Posn in command line 
	PUSH	B		;# of chars remaining
	LXI	H,FCB+11H	;Source
	LXI	D,MEMFCB+1	;Destination
	MVI	B,11		;Move name + type
	CALL	MOVE 
;				add LBR suffix if required
	LXI	H,FCB+9		;Is there a suffix
	MOV	A,M
	CPI	SPACE
	JNZ	NUMBR2		;Yes - leave
	MVI	M,'L'
	INX	H
	MVI	M,'B'
	INX	H
	MVI	M,'R'
NUMBR2:
	POP	B
	POP	H
	CALL	FILNAM		;Skip member name, returns <B>=0 or <A>=20H
	JZ	OPENF		;end
;
;			Handle screen width & height
NUMBER:
	LXI	D,CHRMAX	;point to chr/line
	CALL	GETNBR		;get number of characters/line
	JC	HELP		;invalid number
	LXI	D,LINMAX	;point to number of lines
	CNZ	GETNBR		;call only if characters still in
				;__command tail
	JC	HELP		;invalid number
;
OPENF:	CALL	OPNFIL		;open file in default fcb
;
	IF	SQUEEZE
;
	CALL	CHKSQ		;Check for squeezed, init if
;				;Returns first word in file in <HL>
;
	ENDIF
;
	IF	LIBRARY
;
	CALL	CLRSCR		;erase the screen
	CALL	FILBF0		;fill the disk buffer with start of file
	CALL	CHKLB		;Check for library file
	JMP	WRTFW0		;Buffer contains top sectors
;
	ENDIF	
;
WRTFWD:
	CALL	CLRSCR		;erase the screen
	CALL	FILBF0		;fill the disk buffer with start of file
WRTFW0:
	LXI	H,DSKBUF	;point to beginning of buffer
;
WRTFW1:
	MOV	A,M		;get a character
	CPI	EOF		;see if eof
	JZ	GETCMD		;yes, wait for command
	INX	H		;bump pointer
	ANI	7FH		;strip high bit
	CPI	'L'-40H		;filter form-feeds
	JZ	FILTER		;__commonly found in .PRN files
	CALL	CO1		;put it on console
	CPI	CR		;see if end of line
	JZ	FWDCNT		;yes, adjust line count
;
WRTFW2:	LXI	D,ENDBUF	;get end of buffer address
	CALL	cmphlde		;Is HL> gt DE> (end of buff)
;				; Note test is LT now, not NE (v1.81)
	JC	WRTFW1		;continue with next character
	CALL	FILBUF		;fill the disk buffer with next sectors
	JMP	WRTFW0		;start over
;
HELP:	CALL	CDISP
	DB	'BISHOW version '
	DB	(VERS MOD 10)+'0','.'
	DB	REVS/10+'0',(REVS MOD 10)+'0',CR,LF
	DB	'Usage: d:bishow d:fn.ft '
;
	IF	LIBRARY
;
	DB	'[member] '
;
	ENDIF
; 
	DB	'[cols [lines]]',CR,LF
	DB	ENDMSG
	JMP	EXIT1
;
FILTER:	PUSH	PSW		;save status
	MVI	A,'^'		;print '^' in front
	CALL	CO1		;__of control character
	POP	PSW		;restore status
	ADI	40H		;mask into displayable char
	CALL	CO1		;display filtered control char
;
FWDCNT:	LDA	LINCNT		;get number of lines displayed
	INR	A		;bump it
	STA	LINCNT		;__and store it
	MOV	D,A		;save lincnt
	LDA	LINMAX		;get max number of line
	CMP	D		;compare with line count
	JNZ	WRTFW2		;if not there, continue, else get command
	XRA	A		;zero the
	STA	LINCNT		;__line count
;
GETCMD:	PUSH	H
	PUSH	D
	PUSH	B
;
	IF	HEATH
	CALL	CDISP
	DB	ESC,'x5',ENDMSG	;disable cursor
	ENDIF
;
GETCM1:	CALL	GETIN		;Get input char if any
	ORA	A		;loop till char avail
	JZ	GETCM1
	POP	B
	POP	D
	POP	H
	CPI	'a'		;change command to
	JC	GETCM2		;__upper case
	CPI	'z'+1
	JNC	GETCM2
	XRI	20H		;is lower case, make upper case
;
GETCM2:
	IF	NOT SHORT
	CPI	'1'		; 1 means goto 1st line
	JZ	WRTTOP		;Test if top in buffer
	CPI	'?'		;help request
	JZ	HELP2
	CPI	' '		;more use space
	JZ	WRTFW1
	CPI	'F'		;scroll forward?
	JZ	WRTFW1		;br if yes
	CPI	'F'-40H		;vi uses ^F
	JZ	WRTFW1
	CPI	'V'-40H		;mince uses ^V
	JZ	WRTFW1
	CPI	'B'		;scroll backward?
	JZ	WRTBAK
	CPI	'B'-40H		;vi uses ^B
	JZ	WRTBAK
	CPI	'N'		;scroll next line?
	JZ	WRTNXT
	CPI	'+'
	JZ	WRTNXT
	CPI	CR		;scroll next line?
	JZ	WRTNXT
	CPI	LF
	JZ	WRTNXT
	CPI	'P'		;scroll prev line?
	JZ	WRTPRV
;
	ENDIF
	IF	OSBORNE AND NOT SHORT
;
	CPI	ARWUP		;Cursor up?
	JZ	WRTPRV
;
	ENDIF
	IF	NOT SHORT
;
	CPI	'-'
	JZ	WRTPRV
	CPI	'C'-40H		;must be exit
	JZ	EXITCL		;return control to CCP if yes or
	CPI	'Q'		;more use q for quit
	JZ	EXITCL
	CPI	'S'		;set screen parameters
	JZ	SETSCR
	CPI	ARWLFT		;Cursor left?
	JZ	ADJMM
	CPI	ARWRT		;Cursor right?
	JZ	ADJMM
	JMP	HELP2		;else give a hint
	ENDIF
;
	IF	SHORT
	CPI	FIRST		; 1 means goto 1st line
	JZ	WRTTOP
	CPI	NXTPAG		;scroll forward?
	JZ	WRTFW1		;br if yes
	CPI	BACK		;scroll backward?
	JZ	WRTBAK
	CPI	NEXT		;scroll next line?
	JZ	WRTNXT
	CPI	PREV		;scroll prev line?
	JZ	WRTPRV
	CPI	'C'-40H		;must be exit
	JZ	EXITCL		;return control to CCP if yes or
	CPI	QUIT		;alternative quit
	JZ	EXITCL
	CPI	SCREEN		;set screen parameters
	JZ	SETSCR
	JMP	HELP2		;else give a hint
	ENDIF
;
;			Go to top of file
WRTTOP:
	LDA	TOPBUF		;Get top in buffer flag
	ORA	A
	JNZ	WRTFWD		;No - the hard way
	CALL	CLRSCR		;erase the screen
WRTTO1:
	XRA	A
	STA	LINCNT		;Clear lines put so far
	JMP	WRTFW0		;Buffer contains top sectors
;
;			Write one more line
WRTNXT:	LDA	LINMAX
	DCR	A		;fool wrtfw1 to only write one line
	STA	LINCNT
	JMP	WRTFW1
;			Back up one line
WRTPRV:	LDA	LINMAX		;back up one screen + 1 line
	INR	A
	JMP	WRTBK0
;			Back up full screen
WRTBAK:	LDA	LINMAX		;get screen line count
	ADD	A		;__multiply by 2
;
WRTBK0:	INR	A		;__and add 1
	STA	LINCNT		;__to backup to previous page
	CALL	CLRSCR		;clear the screen
;
WRTBK1:	LXI	D,DSKBUF	;get address of start of buffer start
	CALL	cmphlde		;Is HL> LT DE> (start of buff)
;				; Note test is LT now, not NE (v1.81)
	JC	FILBAK		;Go refill buffer
;
WRTBK2:	MOV	A,M		;get a character
	ANI	7FH		;strip high bit
	DCX	H		;decrement buffer
	CPI	CR		;see if end of line
	JZ	BAKCNT		;__or form-feed
	CPI	'L'-40H		;__and adjust line count if so
	JNZ	WRTBK1		;else, loop if not
;
BAKCNT:	LDA	LINCNT		;else, get number of lines to move back
	DCR	A		;__and decrement it
	STA	LINCNT		;__store it
	JNZ	WRTBK1		;__and loop if not there
	INX	H		;else bump pointer
	INX	H		;__to account for dcx
	JMP	WRTFW1		;and go write a screen
;
FILBAK:
;			Test for top of file
	LDA	TOPBUF		;Get top in buffer flag
	ORA	A
	JZ	WRTTO1		;Yes - start of file in buffer
;			Start of file not in buffer, step back
	LHLD	SECCNT		;Get no of sectors last read
	LXI	D,MAXSEC	;get the buffer size
	DAD	D		;add them
	XCHG			;__and put them in DE
	LDA	FCBCRR		;subtract low order byte 
	SUB	E		;__from current record count
	STA	FCBCRR		;__and store in current record count
	LDA	FCBCRR+1	;same with high order byte
	SBB	D		;__but with borrow
	JM	WRTFWD		;if beyond beginning of file, start over
	STA	FCBCRR+1	;else, store high order byte
	CALL	FILBUF		;fill the buffer
	LXI	H,ENDBUF	;__and point to end of buffer
	CALL	CLRSCR		;clear the screen
	JMP	WRTBK2		;continue moving back in file
;
;			Fill buffer with top of file 
FILBF0:
	XRA	A		;get a 0
	STA	LINCNT		;store in line count
	STA	CHRCNT		;store in character count
;				Do not reset the current extent!!!
;				BDOS will switch extents only if the no
;				specified ( <FCBEX> ) does NOT agree with
;				the wanted no <FCBCRR>. 
	STA	FCBCRR		;Reset to sector zero
;
	IF	NOT LIBRARY
;
	STA	FCBCRR+1	;
	STA	FCBCRR+2	;__and clear the overflow
;
	ENDIF
;
	IF	LIBRARY
;
	LHLD	SCZERO		;Set to sector zero for file/member
	SHLD	FCBCRR
;
	ENDIF
;
;			;Fill buffer from spec'd sector
FILBUF:
	MVI	B,MAXSEC	;number of sectors to resd
FILB1S:
;
	IF	LIBRARY
;
	LHLD	SCZERO		;Get top sector for member
	XCHG 
	LHLD	FCBCRR		;Is this top of file?
	CALL	cmphlde		;This it? (<A>=0 if equal)
;
	ENDIF
	IF	NOT LIBRARY	
	LHLD	FCBCRR		;Is this top of file?
	MOV	A,H
	ORA	L
;
	ENDIF
;
	STA	TOPBUF		;Set top of file in buffer flag
	LXI	D,DSKBUF	;load start of disk buffer
	LXI	H,0		;zero out the
	SHLD	SECCNT		;__number of sectors in buffer
;				; Z - top, NZ - not top 
	IF	SQUEEZE
	LDA	SQFLG		;Is this a squeezed file
	ORA	A
	JNZ	FILSQ		;Yes -
	ENDIF
;
FILBU1:
	PUSH	H		;save all
	PUSH	D		;__registers from
	PUSH	B		;__BDOS clobber
	MVI 	C,STDMA		;set dma to
	CALL	BDOS		;__disk buffer
;
	LXI	D,FCB		;set up to read
	MVI	C,READR		;__a record
	CALL	BDOS		;do it
	ORA	A		;read OK?
	LHLD	FCBCRR		;get current record number
	INX	H		;__bump it
	SHLD	FCBCRR		;__and save it
	LHLD	SECCNT		;get sectors in buffer
	INX	H		;bump it
	SHLD	SECCNT		;store it
	POP	B
	POP	D
	POP	H
	JNZ	RDERR		;no, last sector read
;
	IF	LIBRARY
;
	PUSH	D		;Save sector buffer pointer
	LHLD	FCBCRR		;get current record number
	XCHG
	LHLD	SCLAST		;& get last sector for member (or FFFF)
	CALL	cmphlde		;Are we within member 
	POP	D
	JC	RDERR		;no, last sector read
;
	ENDIF
;
	DCR	B		;decrement it
	RZ			;if done return
	LXI	H,128		;else, add 128 to
	DAD	D		;__dma address
	XCHG			;put it in de
	JMP	FILBU1		;read another sector
;
	IF	SQUEEZE
;
;			Fill buffer from squeezed file
;			This rtn handles mapping from unsq sector #
;			to sector, byte & bit in sq stream
;			on input FCBCRR contains wanted sector no,
;			( no allowance made for sectors # over 65535)
;			<B> contains no of sectors wanted
;			DE> buffer where sectors wanted,
;			 ignored in this version, always full DSKBUF
FILSQ:
	LHLD	FCBCRR		;Get # for 1st sector wanted
	XCHG
	PUSH	D		;Save to restore after unsq
	LHLD	NXTSEC		; & 1st sector after buffered ones  
	CALL	cmphlde		;Consecutive?
	JZ	USQNXT		;Yes - fine
	JNC	USQBAK		;No - lower
;			;Next sect after latest but not consec
	CALL	CDISP
	DB	CR,LF,'Program failure, non-contiguous sectors requested'
	DB	CR,LF,'from unsqueeze rtn',CR,LF,0
	JMP	EXIT		;Should never happen
USQBAK:			;Going backward
;
	ENDIF
	IF	SQUEEZE AND LIBRARY
;
	LHLD	SCZERO		;Get 1st sector for member
	CALL	cmphlde		;All the way back to start?
;
	ENDIF
	IF	SQUEEZE AND NOT LIBRARY
;
	MOV	A,D		;All the way?
	ORA	E
;
	ENDIF
	IF	SQUEEZE
;
	JNZ	USQNO1		;No - MUST be prev!!!
	LXI	H,SQMAP+2+8	;Yes - reset SQMAP index to #3
	SHLD	SQMAP
USQNO1:
	LHLD	SQMAP		;Get index into mapping table
	LXI	D,-8		;Step back from next, past current to prev
	DAD	D
	SHLD	SQMAP		; & save updated index for next
	MOV	E,M		;Get SQ sector no
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M		;Get byte offset
	INX	H
	MOV	A,M		; & bit offset
	STA	bitlft
	XRA	A
	STA	rcnt		;No runs in progress
;				(assumption)
	STA	SQBYT+1		;Set offset 1st data byte
	MOV	A,C
	STA	SQBYT		;For now offset within sector only
	LHLD	SQBSC1		;Get no of first SQ sector now in buffer
	XCHG			;<HL> wanted 1st sector, <DE> actual 1st
	CALL	cmphlde		;Is 1st buffer sector low/equal 1st data sect?
	JNC	USQ1OK		;Yes - first wanted sector SQ in buffer
;				 Max header 1035 bytes + file name)
;			Force reload of SQ buffer
	SHLD	NXTSQS		;No - 1st data sector b/4 1st buffer sect
;				 (note is probab not sector 0
;				 because of header, eg decoding tree)
	MVI	A,1		;Set rewind with I/O
	STA	SQREWD		;Set rewind flag
;				 SQBYT contains offset of 1st data byte
	XRA	A
	STA	SQEOF		;Reset end of file on SQ
;				Leave current extent alone. This is how
;				BDOS knows how to switch extents. It checks
;				if the current extent no agrees with
;				the wanted record.
	STA	FCBCRR+2	; & count overflow, should not be necessary
	MOV	D,A
	JMP	USQNX1		;Go adj buffer pointer
;				(NOP since <DE>=0
;			;SQ text still in buffer
USQ1OK:
;				<DE> # of 1st sector in SQ buf
;				<HL> # of wanted SQ sector 
;				(Max 100H SQ sectors in buffer)
	MOV	A,L
	SUB	E
	RAR			;Convert to pages (100H)
;				 Know Cy=0 in
;				 leaves Cy if odd no of sects
	MOV	D,A
	MVI	A,0		;Do not disturb Cy
	RAR			;Pu carry (now 80H or 00H) 
USQNX1:
	MOV	E,A
	LHLD	SQBYT		;Get offset of 1st data byte in wanted sect
	DAD	D		; --> offset in buffer
	LXI	D,SQBUF
	DAD	D		;Convert to absolute addr
	SHLD	inbufs		;& set as next byte to unsqueeze
;
USQNXT:			;Next sector consecutive
	LHLD	NXTSQS		;Get no of next SQ sector 
;				(in case read reqd)
	SHLD	FCBCRR
;			Build mapping table entry
	LHLD	inbufs		;Calc offset in buffer
	LXI	D,-SQBUF
	DAD	D
	MOV	C,L		;Keep offset within sector
	LDA	bitlft		;Get bit offset
	MOV	B,A
	ORA	A		;On byte boundary?
	MOV	A,C
	JNZ	NOTBBY		;No -
	INR	A		;Yes - no adj reqd
NOTBBY:
	ANI	7FH		;Ensure sector relative
	DAD	H		;Convert to sector no
	ORA	A		;Is next byte at start of sect?
	JNZ	SECTOK
	DCR	H		;Yes - step back one sector
SECTOK:
	DCR	A
	ANI	7FH		;& adj byte index
	MOV	E,H
	MVI	D,0
	LHLD	SQBSC1		;# of 1st sector in buffer
	DAD	D
	XCHG			;<D> absolute SQ sector no
	LHLD	SQMAP		;Get index
	MOV	M,E		;Save abs SQ sector no
	INX	H
	MOV	M,D
	INX	H
	MOV	M,A		;Save sector relative byte offset
	INX	H
	MOV	M,B		;Save bitlft
	INX	H
	SHLD	SQMAP		;Save new index
;
	ENDIF
	IF	SQUEEZE AND NOT SILENT
;
	CALL	CDISP		;Show msg where is
	DB	'>>> Unsqueezing text <<<',ENDMSG
;				Corrupts display if aft CR but b/4 LF
;
	ENDIF
;
;
	CALL	filusq		;Fill unsq buffer
;				returns NZ on EOF
;				SQEOF set as well then
;
	IF	SQUEEZE AND NOT SILENT
;
	CALL	CDISP		;Remove msg just displayed, assumes
;				 BS works across start of line if reqd
	DB	BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS
	DB	BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS
	DB	'                        '
	DB	BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS
	DB	BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,BS,0
;
	ENDIF
	IF	SQUEEZE
;
	LHLD	FCBCRR		;Get no of next SQ sector
	SHLD	NXTSQS
	LHLD	nxtadr		;Calc # of unsq sectors in buf
	LXI	D,-DSKBUF	;(as neg no)
	DAD	D		;Calc length
	DAD	H		; & convert to sectors in <H>
	MOV	L,H
	MVI	H,0
	SHLD	SECCNT		;Save # of sectors in DSKBUF
	POP	D		;Get FCBCRR as passed by calling rtn
	DAD	D		; & calc new one
	SHLD	FCBCRR
	SHLD	NXTSEC
	RET
;
	ENDIF
;
;
;We only get here if end of file
;
RDERR:	MVI	A,EOF		;get bogus eof
	STAX	D		;save at buffer end in case no eof in file
	XRA	A		;get a zero to direct to start of buffer
	RET			;__on ret
;
OPNFIL:	LDA	FCBFN		;point to first letter of filename
	CPI	' '		;anything there?
	JZ	HELP		;no, give help message
	XRA	A		;get a 0
	STA	FCBEX		;zero current extent
;				MUST open file on extent zero
	LXI	D,FCB		;file name in default fcb
	MVI	C,OPEN		;set up to open
	CALL	BDOS		;do it
	INR	A		;open OK?
	RNZ			;yes
	CALL	CDISP		;else, give error msg and quit
	DB	'file not found ',ENDMSG
	JMP	EXIT1		;leave msg on screen on exit
;
GETNBR:	MOV	A,M		;get first digit
	INX	H
	DCR	B		;b=number of characters left in buffer
	RZ			;no digit
	CPI	SPACE
	JZ	GETNBR		;wait until next non-space
	PUSH	D		;save location to save number
	MVI	D,0		;initialize number
;
GNUM1:	SUI	30H		;change ASCII to number
	JC	INVNUM		;not a number
	CPI	10
	CMC
	JC	INVNUM		;not a number
	PUSH	PSW		;save number
	MOV	A,D		;multiply old number by 10
	ADD	A		;*2
	ADD	A		;*4
	ADD	A		;*8
	ADD	D		;*9
	ADD	D		;*10
	MOV	D,A
	POP	PSW		;restore new digit
	ADD	D
	MOV	D,A
	MOV	A,M		;get next digit
	INX	H
	DCR	B
	JZ	ENDNUM		;end of number
	CPI	SPACE
	JNZ	GNUM1
;
ENDNUM:	MOV	A,D		;save number
	DCR	A		;correct number for co routines
	XCHG			;set to restore save location
	POP	H		;restore save location
	MOV	M,A		;save digit
	XCHG			;put buffer location where it belongs
	MOV	A,B		;see if any characters left in buffer
	ORA	A		;zero if no characters in buffer
	RET
;
INVNUM:	POP	D		;correct stack
	RET
;
ASCIIN:	MVI	B,100		;divide by 100, then change
	CALL	DIVIDE		;__digit to ASCII and store at hl
	MVI	B,10		;divide by 10, then change
	CALL	DIVIDE		;__digit to ASCII and store at hl+1
	MVI	B,30H		;change ones place number
	ADD	B		;__to ASCII and store at hl+2
	MOV	M,A
;
	IF	NOT (SHORT AND HEATH)
	DCX	H		;delete leading zeroes
	DCX	H		;__in the number
	MVI	C,SPACE		;__and replace with spaces
	MOV	A,B
	CMP	M		;check first digit for '0'
	JNZ	CDISP		;not zero
	MOV	M,C		;replace with space
	INX	H
	CMP	M		;check second digit for '0'
	JNZ	CDISP		;not zero
	MOV	M,C		;replace with space
	ENDIF
;
CDISP:	XTHL			;exchange top of stack and HL
;
CDIS1:	MOV	A,M		;HL now pointing to db message
	ORA	A		;see if 0 at end of message
	INX	H
	JZ	CDIS2		;yes, restore stack and return
	CALL	CO		;no, print the character
	JMP	CDIS1		;__and loop
;
CDIS2:	XTHL			;get return address on top of stack
	RET			;__and return
;
CO:	PUSH	B		;Save the registers
	PUSH	D		;__from bdos
	PUSH	H		;__clobber
CO2:	PUSH	PSW
	MOV	E,A		;set up character
	MVI	C,CONOUT	;__to send to console
	CALL	BDOS		;do it
	POP	PSW
CO5:	POP	H		;restore
	POP	D		;__the registers
	POP	B
	RET
;
CO1:	PUSH	B		;Save the registers
	PUSH	D
	PUSH	H
	MOV	E,A
	LXI	H,CHRCNT	;Get address of character count
	CPI	CR		;see if end of line
	JZ	ENDLIN		;update line information
	CPI	LF		;ignore linefeed
	JZ	CO2
	LDA	CHRMAX		;get maximum characters per line
	CMP	M		;see if too many char
	JC	CO5		;don't print character
	MOV	A,E		;restore and print character
	CPI	TAB		;fix chrcnt for tabs
	JZ	TABFIX
	INR	M		;increment character count
	LDA	CHRMIN		;see if up to minimum display yet
	CMP	M
	MOV	A,E		;restore character
	JNC	CO5		;do not display character
	JMP	CO2		;finally, display character
;
ENDLIN:	MVI	M,0		;reset character count
	JMP	CO2		;print cr
;
TABFIX:	MVI	A,08H		;fix chrcnt for tabs
	ADD	M		;increment to next 8-count
	ANI	0F8H		;make into multiple of 8
;
TAB2:	SUB	M		;get number of space to go
	MOV	B,A
;
TAB1:	MVI	A,SPACE		;expand tab
	CALL	CO1
	DCR	B
	JNZ	TAB1		;still more spaces
	JMP	CO5		;exit routine
;
SETSCR:	PUSH	H
	PUSH	D
	PUSH	B
;
GETMAX:	LDA	CHRMAX		;get maximum number of characters
	INR	A
	LXI	H,HUNS
	CALL	ASCIIN		;put ASCII number in message		
;
	IF	NOT SHORT
	DB	CR,LF,'Maximum Column: '
	ENDIF
;
	IF	SHORT
	DB	CR,LF,'Max Column: '
	ENDIF
;
HUNS:	DB	30H
	DB	30H
	DB	30H
	DB	' New? ',ENDMSG
	CALL	GETINP		;read input from console
	LXI	D,CHRMAX	;set new chrmax in memory
	CALL	GETNBR
	JC	GETMAX		;if error, repeat last message
;
GETMIN:	LDA	CHRMIN		;get minimum character display
	INR	A
	LXI	H,HUN
	CALL	ASCIIN		;put ASCII number in message		
;
	IF	NOT SHORT
	DB	LF,'Minimum Column: '
	ENDIF
;
	IF	SHORT
	DB	LF,'Min Column: '
	ENDIF
;
HUN:	DB	30H
	DB	30H
	DB	30H
	DB	' New? ',ENDMSG
	CALL	GETINP		;read input from console
	LXI	D,CHRMIN	;set new chrmax in memory
	CALL	GETNBR
	JC	GETMIN		;if error, repeat last message
;
GETLIN:	LDA	LINMAX		;get number of lines per display
	LXI	H,HUND
	CALL	ASCIIN		;put ASCII number in message		
	DB	LF,'Lines Displayed: '
;
HUND:	DB	30H
	DB	30H
	DB	30H
	DB	' New? ',ENDMSG
	CALL	GETINP		;read input from console
	LXI	D,LINMAX	;set new chrmax in memory
	CALL	GETNBR
	JC	GETLIN		;if error, repeat last message
 	POP	B
	POP	D
	POP	H
;
WRTSAM:	LDA	LINMAX		;write the same screen
	JMP	WRTBK0
;
;
GETINP:	MVI	A,5		;get set to read new maximum column
	STA	CMDTAIL
	MVI	C,0AH
	LXI	D,CMDTAIL
	CALL	BDOS		;get maximum column
	LXI	H,CMDTAIL+1	;now, change to ASCII
	MOV	B,M
	INX	H
	INR	B
	RET			;return with input in buffer
;
	IF	NOT SHORT
;			Adjust char min/max on cursor left/rt
ADJMM:
	PUSH	H
	CPI	ARWLFT		;Move left (decrease)?
				; set flag
	LDA	CHRMAX		;What is last char on line t/b displ
	MOV	H,A
	LDA	CHRMIN		; & 1st char to display
	MVI	L,8		;Scroll by 8
	JZ	ADJMMD		;Yes - adjust down
	ADD	L		;No - increase min, no limit
	PUSH	PSW
	MOV	A,L
	ADD	H		; & max
	JMP	ADJMMS
ADJMMD:
	SUB	L		;Display more to the left
	PUSH	PSW
	MOV	A,H
	SUB	L
ADJMMS:
	MOV	H,A		;<H> max
	POP	PSW		;<A> min
	CMP	H		;Wrap, (max< min)
	JNC	ADJMMX		;Yes - leave unchanged
	STA	CHRMIN
	MOV	A,H
	STA	CHRMAX
ADJMMX:
	POP	H
	JMP	WRTSAM		;Go write same screen
;
	ENDIF
; 
DIVIDE:	MVI	C,'0'-1		;extract dividend of a div c
;
DIV1:	INR	C		;__and store in location pointed
	SUB	B		;__to by hl
	JNC	DIV1
	ADD	B
	MOV	M,C		;save ASCII digit
	INX	H		;bump pointer to next location
	RET
;
EXITCL:
;			Clear screen only on reg exit
	CALL	CLRSCR		;clear the screen
;
EXIT:
	CALL	GETIN		;__get any waiting characters
	CALL	GETIN		; and any possible second char
;
	IF	HEATH
	CALL	CDISP		;re-enable cursor
	DB	ESC,'y5',ENDMSG
	ENDIF
;
	LXI	D,FCB		;close file
	MVI	C,CLOSE		;--in case this is MP/M
	CALL	BDOS
;
EXIT1:
	LHLD	STACK		;get old stack
	SPHL
	RET			;return to CCP
;
	IF	LIBRARY
;
;			Check for Library file
;
CHKLB:
	xra	a
	sta	memfcb
	sta	lbflg		;Clear library flag
	LHLD	DSKBUF		;Get 1st word in file
	lxi	d,lbsign	;Get expected value
	call	cmphlde
	jz	islb
;			Not library
	lda	memnam		;Was member specified
	ora	a
	rz			;No - ok
	call	CDISP
	db	cr,lf,'File is not a library',cr,lf,0
	jmp	EXIT		;Get out to leave msg visible
;			Is library
islb:
	mvi	a,1
	sta	LBFLG		;Yes - set library flag
	LXI	H,DSKBUF+14	;Set to dir size (in sectors)
	mov	a,m		;Assume <255 entries
	RAL
	RAL			;Convert # sectors to # entries
	DCR	A		;Less 1 for file descriptor
	sta	dirsiz		;directory size in entries
	mov	b,a		;Save no of entries for loop
;			If no member specified show directory,
;			else find the member
	LDA	MEMNAM		;Do we have member name on command line?
	ORA	A
	JNZ	NODISP		;Yes
	CALL	CDISP		;Note protects <B>
	DB	CR,LF,'Library file, containing:',CR,LF,LF,0
NODISP:
	LXI	H,DSKBUF+20H	;Set 1st member entry
;			Loop through directory entries
dirlp:
	push	b		;Save no of entries remaining
	MOV	A,M		;Get entry status
	ORA	A		;Deleted?
	JNZ	nyet		;Yes - skp to next
	LDA	MEMNAM		;Do we have member name on command line?
	ORA	A
	JZ	DISPM		;No - display all member names
;			See if wanted member
	mvi	b,12		;Length of names + 00H in front
	lxi	d,memfcb
	call	cpstr		;Compare names
	jz	found
	jmp	nyet
;			Display rather than look for
DISPM:
	mvi	b,11		;Length of names
	push	h
	inx	h		;Step to actual name
DSPMLP:
	mov	a,m
	call	CO		;Display one char
	inx	h
	dcr	b		;Reduce count remaining
	jz	nmend		;end of name
;
	ENDIF
	IF	LIBRARY AND NOT OSBORNE
;				(Bypass for Ozzys narrow screen)
	mov	a,b
	cpi	3		;only 3 more?
	jnz	DSPMLP		;No -
	mvi	a,'.'		;Yes - put out dot
	call	CO
;
	ENDIF
	IF	LIBRARY 
	jmp	DSPMLP		;Go for next char
;
;			;Displayed full name
nmend:
;				In later versions multiple across
	lxi	h,namexc	;Max no of names across sofar
	mov	a,m
	inx	h		;Step to names across sofar
	inr	m		;Count current
	cmp	m		;Over max?
	jnc	notmax		;not yet
	mvi	m,0		;Yes - reset
	call	CDISP
	DB	CR,LF,0
	jmp	nyet1
notmax:
	call	CDISP
;
	ENDIF
	IF	LIBRARY AND NOT OSBORNE
;				(Bypass for Ozzys narrow screen)
	DB	' '
;
	ENDIF
	IF	LIBRARY
;
	DB	'| ',0
nyet1:
	POP	H		;Reset to start of this entry
;			
nyet:
	lxi	b,20h		;Length of each entry
	dad	b		;Step to next
	pop	b		;Get entry count (remaining)
	dcr	b
	jnz	dirlp		;More members
	LDA	MEMNAM		;Do we have member name on command line?
	ORA	A
	JZ	EXIT		;No - just get out after dsp directory
;				in future may ask what member to display
	call	CDISP
	db	cr,lf
	db	'Member file not found in LBR directory',cr,lf,0
	jmp	EXIT
;
;			Found the member name
;
found:
	pop	b		;Clear stack
	lxi	d,12
	dad	d
	push	h		;save pointer for now,
	inx	h		;point to size
	inx	h
	mov	a,m		;get low byte
	inx	h
	mov	h,m
	mov	l,a
	ora	h		;if a=0 then file is 0k
	jz	nullen		;go complain
	xthl			;get pointer back, save size
	mov	a,m		;get file address
	inx	h
	mov	h,m
	mov	l,a
	SHLD	SCZERO		;Save as first file sector
	POP	D		; & get size back
	DAD	D		;Convert to last sector no (inclusive)
	SHLD	SCLAST
;
	ENDIF
	IF	LIBRARY AND SQUEEZE
; 
	LDA	SQFLG		;Get SQ flag in case of double squeeze
	ORA	A
	JZ	NOLBSQ		;Ok, library itself not squeezed
	CALL	CDISP
	DB	CR,LF,'Cannot display member in squeezed library',CR,LF,0
	JMP	EXIT
NOLBSQ:
	CALL	CHKSQ		;Check if  member squeezed
;
	ENDIF
	IF	LIBRARY
;
	CALL	FILBF0		;Refill buffer, now for member
;				 (FILBUF handles member offset in library)
	ret
;
;			;Member is empty
nullen:
	CALL	CDISP
	DB	CR,LF,'Member is empty',CR,LF,0
	JMP	EXIT
;
	ENDIF
;
;			Get input if any
GETIN:
	MVI	C,6		;direct console I/O
	MVI	E,0FFH		;__set up for input
	JMP	BDOS		;Get char, exit via BDOS
;
;			Compare strings HL> to DE> over <B> 
;			<DE> and <B> are changed, <HL> kept 	
cpstr:
	push	h
cp$lp:
	ldax	d
	cmp	m
	jnz	cp$ex		;No match
	inx	d
	inx	h
	dcr	b
	jnz	cp$lp
cp$ex:
	pop	h
	ret

;
;			Compare <HL> to <DE>
;			 Z - equal; C - <HL> less than <DE> 
;			 if equal returns <A>=0
cmphlde:
	mov	a,h
	sub	d
	rnz
	mov	a,l
	sub	e
	ret
;
;			Skip blanks in input
;
EATSP:	MOV	A,M		;get character if there is one
	INX	H
	DCR	B		;b=number of characters left
	RZ			;no more characters
	CPI	SPACE		;ignore spaces
	JZ	EATSP
	DCX	H		;Step back to 1st non-blank
	INR	B
	ORA	A		;Force NZ
	RET
;
;			Skip name in input
;
FILNAM:	MOV	A,M		;get characters in file name
	INX	H
	DCR	B		;b=number of characters left
	RZ			;only file name in tail
	CPI	SPACE		;wait for next space
	JNZ	FILNAM
	ORA	A		;Force NZ
	RET			;Blank
;
;			Move from HL> to DE> over <B>
;
MOVE:
	MOV	A,M
	STAX	D
	INX	H		;Step to next source
	INX	D		; & destination
	DCR	B		;Reduce count (00=256)
	JNZ	MOVE
	RET
;
;
	IF	SQUEEZE
*******************************************************
* USQ support code				      *
* 10/12/83 by Dave Rand				      *
*******************************************************
;
;			Check for SQ file, init tree if so
CHKSQ:
;			Initialize
	xra	a
	mov	l,a
	mov	h,l		;clear <hl>
	STA	SQFLG		;Make sure not set as squeezed yet 
	sta	SQEOF		; end of file on SQ
	sta	SQREWD		;Clear "rewinding" SQ file 
	sta	bitlft		;force init char read
	sta	rcnt		;and zero repeats
	sta	FCBCRR+2	; and overflow
	shld	numvals		;Clear # nodes
;
	ENDIF
	IF	SQUEEZE AND LIBRARY
;
	LHLD	SCZERO		;Get 1st sector for member
	SHLD	NXTSEC		;& save as next sector
;
	ENDIF
	IF	SQUEEZE
;
	shld	FCBCRR		;Clear next record
;
	lxi	h,SQBUF		;Set to input (squeezed) buffer 
	shld	inbufs
	shld	inbufu
	lxi	d,128
	dad	d
	shld	SQBUFE		;Force exit on full buff aft 1 sect
;				 causes the SQ buffer to contain
;				 sectors 1+ only (not zero),
;				 normally fine since sector 0 contains only
;				 header info. Sector 0 will be reread
;				 if contains data and needed  
;			Read and validate signature word
	call	getw		;Read  1st word in file
	lxi	d,sqsign	;Get expected value
	call	cmphlde
	rnz
	mvi	a,1
	STA	SQFLG		;Yes - set flag
	lhld	0006		;Get top of memory
	lxi	d,sqbuf+100H*128 ;Limit buffer to max 100H
	call	cmphlde		; sectors (FILBUF uses 8 bit count <B>)
	JC	toplow		;use top
	xchg			;use limit 
toplow:
	shld	SQBUFE		;& store as full address 
	call	namlp		;Skip past name
	call	usqtbl		;Validate & load decoding tree
	jz	oak		;tree ok
	call	CDISP
	db	cr,lf,'Invalid decode tree size',cr,lf,0
	jmp	EXIT
oak:
	lxi	h,SQMAP+2	;Point to 1st entry 
	shld	SQMAP		;Set to 1at entry in SQ mapper
	ret
;
;			Read & save checksum
rdchks:
	call	getw		;get cksum, and store
	shld	filchks
	ret
;			Read & skip name
namlp:	call	getc		;Loop to skip name
	jnz	erext		;I/O error or unexpected EOF
	ora	a
	jnz	namlp		;Not yet end of name
	ret
;
;			Load decoding tree
;			This version uses 1 byte abslute node indices
;			(1-ffH) and is thus limited to 255 nodes and 255
;			characters represented in the squeezed file.
;			(All different characters present in the original
;			file as well as any added through run encoding.
;			Runs of 3 or more consecutive identical characters
;			are encoded as char, DLE, count, where count
;			is a one byte field 00 - FFH) 
;
usqtbl:
 	call	getw		;Get no of nodes
	mov	a,h
	ora	l
	jz	nzexit		;Null tree
	shld	numvals
	mov	a,h		;Max 257, 256 char & spec eof
;				in this version allow for only 256
;				diff codes, every ASCII and non-ASCII
;				char would have to be present, or
;				run repeat counts 128-255 (every one)
	ora	a		;H/o byte should be zero
	jnz	nzexit
	lxi	d,SQTREE	;Set to decoding tree
nodelp:	shld	nxtadr		;Save no of nodes
	mov	a,h
	ora	l
	rz			;Done all nodes
	call	cvnode		;get node, falg byte in <H>,
;				 index/char in <L>
	push	h
	call	cvnode		;get second child/char
	pop	b
	mov	a,b
	ral			;Shift flags to 8, 4 posns 
	ora	h		;Combine in 1st child flags 
	xchg			;HL> SQTREE, <A>,<C>,<E> node 
	mov	m,a		;Store flags in table
	inx	h
	mov	m,c
	inx	h
	mov	m,e
	inx	h
	xchg			;DE> SQTREE
	lhld	nxtadr		;Nodes remaining
	dcx	h
	jmp	nodelp
;			Get encoded node
;			Our nodes contain 3 bytes:
;			- flag byte,
;			- left child index/char
;			- right child index/char
;			Nodes on input are 4 bytes,
;			with each half containing
;			an index (1-100h) or character,
;			where characters are encoded as
;			negative values -(char+1)
;			Eof is encoded as -(100h+1)
cvnode:
	push	d
	call	getw		;Get word, chld ptr or char
	pop	d
	mov	a,h
	ora	a
	rz			;Child index, <H>=0,<L>=index
	mov	a,l
	cma
	mov	l,a		;convert char to reg form
	mov	a,h		;get h/o byte again
	cma
	inr	a		;Conv to 1 if char, 2 if EOF
	mov	h,a
	cpi	1		;Was that reg char?
	rz			;Yes - complete
	adi	3		;No convert EOF flag to 0100
	mov	h,a
	ret

;			Exit with NZ flag
nzexit:
	mvi	a,2		;tree error
	ora	a		;Set NZ flag
	ret

;
;
;			Fill output buffer (unsqueezed char)
;
filusq:
	lda	SQREWD		;Rewinding SQ input?
	ora	a
	jz	norewd		;No
;			Reload SQ buffer
	lhld	inbufs
	push	h		;getrf resets
	call	getrf		;Yes - reload buffer & get 1st 8 bits
	pop	h
	shld	inbufs		;Set to first data byte to use
badj:
	mov	c,a
	lda	bitlft		;Get preset 1st wanted bit no
	mov	c,a
	mvi	a,8
	sub	b		; Calc adjmt reqd  
badjlp:
	dcr	a
	jz	badjfn		; bit adjust finished
	mov	b,a
	mov	a,c
	rrc
	mov	c,a
	mov	a,b
	jmp	badjlp
badjfn:
	sta	bitbuf
	xra	a
	sta	SQREWD		; & clear rewind flag
norewd:
	lxi	h,DSKBUF	;reset buffer pointer
	xra	a
buflp:
	shld	nxtadr		;Save as next byte in buffer
	rnz			;End of file (NZ flag)
;				 as set by GETNXT rtn below
	lxi	d,SQTREE	;Get end of input
	call	cmphlde		;buffer full (de < hl - not full)
	jnc	full		;buffer is full
	call	getnxt		;Get next decoded char
				;No checksum taken
	lhld	nxtadr		;Next out buffer posn
	mov	m,a		;Store char returned, may be EOF char
	inx	h
	jmp	buflp
;
full:
	xra	a		;Ensure Z
	ret			;Return on full buffer
;
;
;			Get next decoded character
;
getnxt:	lda	rcnt		;see if in the middle of
	ora	a		;repeat sequence...
	jz	norpt
	dcr	a		;Yes - reduce repeat remaining 
	sta	rcnt
	lda	last		;Get latest char again
	cmp	a
	ret			;Return with Z for ok
norpt:	call	decode
	rnz			;EOF? <A>=1AH
	cpi	dle		;Run encoding flag?
	jnz	norun
;			Handle DLE
	call	decode		;get count
	rnz			;EOF? (is really error after DLE)
	ora	a
	jnz	run		;Non-zero, real run 
	mvi	a,dle		;dle is encoded as dle,0
	cmp	a
	ret
;			;Run encoding found
run:	dcr	a		;Allow for char already retnd
	dcr	a		; & this one
	sta	rcnt		;Keep count yet to be retd
	lda	last		;return second time
	cmp	a
	ret
;			;Normal char, no run active 
norun:	sta	last		;This may be the start
	cmp	a
	ret
;
;
;			Read bits and decode to char
;			 note this version uses 3 bytes per node
;			 not 4.
;			 The first byte in each node is a flag byte
;			  .... x... - left node contains EOF marker
;			  .... .x.. - right node contains EOF marker
;			  .... ..x. - left node contains char
;			  .... ...x - right node contains char
;
decode:	lxi	d,0		;Set to node zero in table
	lda	bitbuf		;Get bits from bit buffer
	mov	c,a
bitlp:	lda	bitlft		;Any bits remaining? 
	ora	a
	jnz	nxtbit		;Yes - go use
	push	d
	call	getc		;No - replenish bit buffer
	jnz	badr		;Unexpected eof
	pop	d
	mov	c,a
	mvi	a,8		;Set as 8 bits inbuffer 
nxtbit:	dcr	a
	sta	bitlft		;Save no of bit remaining 
	lxi	h,SQTREE	;Set to node 0, left child ptr
	dad	d
	dad	d
	dad	d		;Add in node no (4 bytes/node)
	mov	b,m		;Get flag byte
	inx	h		;Step to left child pointer
	mov	a,c		;Get input bits 
	rrc			;Shuffle LOW-ORDER bit to Carry
	mov	c,a
	mov	a,b		;Get flag byte 
	jnc	getn3		;Zero input bit,leave at left
	inx	h		;add 1 to point to right child pointer
	add	b		;Normalize wanted flags to .... x.x.
getn3:
	mov	e,m		;Pick up child or char
;				<D> should always remain zero 
	ani	1010B		;Mask unwanted bits
	jz	bitlp		;Reg child pointer
;			Got to char or eof
	ani	1000B		;End of file marker?
	jnz	goteof		;Yes - get out with eof
	mov	a,c
	sta	bitbuf		;Save bit buffer
	mov	a,e		;Get decoded char (neg)
	ret
;
;			Exit on reg eof
goteof:
	mvi	a,eof
	ora	a
	ret
;
;			;Get input word (lo/hi, unencoded)
getw:	call	getc
	jnz	badr		;Unexpected eof
	push	psw
	call	getc
	jnz	badr		;Unexpected eof
	mov	h,a
	pop	psw
	mov	l,a
	ret
;
erext:
badr:	call	CDISP
	db	cr,lf,'Unexpected EOF',cr,lf,0
	jmp	EXIT
;
;			Get single (unencoded) char
getc:	lhld	inbufu
	xchg
	lhld	inbufs
	call	cmphlde		;End of input buffer?
	jz	getrf		;Yes
getc1:
	mov	a,m		;No get next byte
	inx	h
	shld	inbufs		;Save addr of next byte
	cmp	a
	ret
;
;			Refill input buffer
;
getrf:
	lda	SQEOF		;Is there anything else?
	ora	a
	jz	getok
	call	CDISP
	db	cr,lf,'Read past EOF on SQ file',cr,lf,0
	jmp	EXIT
getok:
	lhld	SECCNT		;Save sector count (decoded buffer only)
	push	h
	lxi	h,SQBUF		;Set input buffer as empty,
	shld	inbufs		;_and start of buffer
	xchg			;DE> buffer, next sector locn
	lhld	SQBUFE		;End of input buffer
	shld	inbufu		;Assume no end of file for now
	mov	a,l
	sub	e
	mov	l,a
	mov	a,h
	sbb	d		;Calc buffer size
	mov	h,a
	dad	h		;Convert to no of sectors
	mov	b,h		;No of sectors to read
;				# sectors limited to 100 max (<B>=0)
	lhld	FCBCRR		;No of 1st sector to read
	shld	SQBSC1
	call	FILBU1		;Read sector into SQBUF
;				<B> no of sectors not read if eof
;				HL> 128
;				DE> last sector read, or after if eof
	lhld	FCBCRR		;Get next SQ sector no
	shld	NXTSQS
	mov	a,b		;Did we fill buffer?
	ora	a
	jz	getrf2		;yes - no eof
	xchg			;Eof, adjust buffer end marker
	shld	inbufu		;Mark end of buffer used
	sta	SQEOF		;& flag eof
;
;			Input buffer re-filled
getrf2:
	pop	h
	shld	SECCNT		;Restore sector count (decoded buffer only)
	lhld	inbufu		;Get end of buffer
	xchg
	lhld	inbufs		;Get start of buffer
	call	cmphlde		;Something there?
	jc	getc1		;Yes - go for char
	jmp	erext		;No - read past eof or empty file
;
;end of baseline USQ code
;
otbufe:	dw	0		;End of decoded char buffer
inbufs:	dw	0		;Start of input buffer
inbufu:	dw	0		;End of used part input buffer
SQBUFE:	dw	0		;End of input buffer
;
nxtadr:	dw	DSKBUF		;Next byte in output buffer 
				; also used when loading tree
bitlft:	ds	1		;No of bits left in bit buffer
rcnt:	ds	1		;Run count remaining (DLE)
filchks:ds	2		;Checksum read from file
last:	ds	1		;Last reg char decoded
bitbuf:	ds	1		;Latest 8 bits (encoded) from input file
numvals:ds	2		;No of nodes in encodng tree
;
	ENDIF
;
;	Memory allocation
;
SECCNT:	DW	0		;number of sectors read into buffer
LINMAX:	DB	SCROLN		;number of to write lines on console
CHRMAX:	DB	MAXCHR-1	;number of characters to display per line
CHRMIN:	DB	0		;character to start displaying on line
CHRCNT:	DS	1		;character number in line
LINCNT:	DS	1		;line number on write or move back in buffer
TOPBUF:	DB	0		;Top of file is now in buffer
;				 Z - yes, NZ - no
;
	IF	SQUEEZE
;
NXTSEC:	DW	0		;Next (unsqueezed) sector not yet in BSKBUF
;				 set (and used) only by FILSQ
SQFLG:	DB	0		;File is squeezed
SQEOF:	DB	0		;End of file on squeezed file
SQREWD:	DB	0		;Flag the SQ input file is being re-read
;				 buffer refill rtn (getrf) to set inbufs
;				 as per offset in SQBYT, and pre-load
;				 bit buffer. Bit buffer to be adj
;				 as per Bitlft
SQBYT:	DW	0		;Offset of first data byte in SQ buffer
SQBSC1:	DW	0		;No of 1st sector in SQ buffer
NXTSQS:	DW	0		;No of last sector in SQ buffer
;
	ENDIF
;
;
	IF	LIBRARY
namexc:	db	(MAXCHR/11)-1	;No of directory names across display
	db	0		;No of names so far
dirsiz:	db	0		;# of members possible in directory
memnam	db	0		;Member name specified on command line
SCZERO:	DW	0		;First sector for member
SCLAST:	DW	0FFFFH		;Last sector for member (included in member)
;				 SCZERO and SCLAST are relative in file
LBFLG:	DB	0		;File is a library file
memfcb:	ds	12		;Name of member file
;
	ENDIF
	DS	60		;stack area
STACK:	DS	2		;old stack saved here
DSKBUF:	EQU	$		;disk buffer area above the program
;
ENDBUF	EQU	DSKBUF+MAXSEC*128
;
	IF	SQUEEZE
;
SQTREE	EQU	ENDBUF		;Space for SQ decoding tree
SQMAP	EQU	SQTREE+256*3
;				Space for SQ buffer mapping table
;				contains sq sect #, sq byte & bit offset
;				for every time DSKBUF was filled
;				1st entry contains index to latest mapping
;				triplet
;				To handle run compr straddling buffer end,
;				should also store rcnt & last 
SQBUF	EQU	SQMAP+100*4	;(allows for 100 8k buffers)
;				Input (squeezed) buffer
;				Runs up to top of free mem 
	ENDIF
;
	END	TPA
