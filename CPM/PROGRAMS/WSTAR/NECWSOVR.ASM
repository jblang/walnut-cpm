; This is an overlay for WordStar 3.0 running on a
;  NEC PC-8001A with a NEC PC-8023A-C dot matrix printer.
;
; Written by   : Ferd S. Brundick
; Net address  : fsbrn@brl-voc.arpa
; Date written : 26 January 1984
; Modification :  4 April 1984
; Refinements  : 29 August 1984
;
;  1. The opening WordStar display has been changed to read:
;
;   NEC Color WordStar
;   NEC PC-8023A-C Printer
;   No communications protocol	<-- this line left unchanged
;   Light print version		-or-	Enhanced print version
;
;    "Color" and "Light" appear in Cyan, all else is Yellow.
;
;  2. The CRT is put into color mode with the Special Function labels
;      ON.  Since this robs the display of one line, the screen length
;      is changed to 24.  The screen width has been reduced to 79.
;
;  3. The normal color is Cyan (5).  The highlight color is Yellow (6).
;
;  4. All delay times have been reduced. 
;
;  5. The default help setting has been lowered and the help level
;      message will be displayed.
;
;  6. The name of the program has been changed to:
;
;	WS.COM  for light    print version
;	WSE.COM	for enhanced print version
;
;  7. The following remapping of WordStar control keys has been made:
;
;      DEL replaced with ^H  ( delete char left )
;     ^QDEL changed to ^Q^H  ( delete to beginning of line )
;      ^H  replaced with ^B  ( move cursor left )
;      ^B  replaced with ^^  ( reform paragraph )
;
;     The DEL key is no longer used, but the keyboard doesn't have
;      one anyway.  (^_ works the same as ^H or the original DEL)
;     You may want to change the file WSMSGS.OVR to reflect the new
;      key definitions.  I used the public domain disk utility DU.
;
;  8. The following printer characteristics have been defined:
;
;	Overstrike method is CR
;	Bold printing uses 3 strikes
;	Alternate character width (^A) is Elite (12-pitch)
;	Normal    character width (^N) is Pica  (10-pitch)
;	Underscore character is 080H which is a graphics char.
;
;  9. The ribbon change sequence is defined for underlining.
;      The first use of ^Y turns on 9th-dot underlining, and
;      the second use of ^Y turns it off.
;
;     NOTE: underlining may be performed by 2 methods:
;	     1. WordStar's ^S will overprint certain characters
;		 (see manual for details) with the graphics
;		 underscore character.  This looks slightly better
;		 than the ASCII underscore character.
;	     2. The printer's continuous underline mode may be
;		 used with ^Y.  This looks very good, but under-
;		 lining will continue between words and from line
;		 to line, even in the left margin.  Be Careful!!
;
; 10. Super- and sub-scripts are supported.  The ROLUP and ROLDOW
;      sequences are far too short for the 8023, so the "sequences"
;      have been defined as 8-bit characters (M-^ [0DEH] and M-v [0F6H]).
;      The subroutine LISEND has been rewritten to call PRINTC in the
;      MORPAT area.  When WordStar sends a character to LISEND to
;      be printed, PRINTC checks if it is ROLUPCH or ROLDOWCH.  If
;      it is, then the proper sequence is sent to the printer, else
;      the current character is simply printed.  It would be very easy
;      to modify PRINTC to recognize other characters as well.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *   NOTE: the use of super- or sub-scripts (^T and ^V) will put the	*
; *	     printer in incremental mode instead of logic-seeking mode.	*
; *	     The character ^R may be used to restore logic-seeking	*
; *	     (bidirectional) mode, but there is a hitch.  When the	*
; *	     printer switches to l-s mode, the current partial line	*
; *	     is lost (the printer manual does not mention this).	*
; *	     This means if a line starts with ^R, the text will begin	*
; *	     flush with the left edge of the paper; ie, the left margin	*
; *	     will be lost.  There are 2 ways to avoid this:		*
; *		1. if you have an entirely blank line, put the ^R on it	*
; *		2. put the ^R on a line by itself, then overprint the	*
; *		    next line like this:				*
; *			This is the end of a paragraph.<CR>		*
; *			control-P control-R control-P <CR>		*
; *			This is the first line of a new paragraph....	*
; *	     Of course, you can ignore this explanation if you promise	*
; *	     never to use super- or sub-scripts.			*
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
; 11. Greek and mathematical symbols and half-height superscript chars
;      (do not confuse this with ^T and ^V) may be printed.  User function
;      three (^E) acts as a toggle character turning "Greek mode" on
;      and off.  Any character in the set '!' thru '_' will be replaced
;      AT PRINT TIME by a char in the Greek/superscript/math set;
;      characters which are not in the set will print normally.
;      This routine is based on an article on page 70 of the July 83
;      issue of Microsystems magazine.  The Greek chars are in "Greek
;      alphabetical order"; there are 24 lower case Greek letters
;      followed by 4 upper case Greek letters.
;      To see how the character remapping is currently defined, create
;      and print a file containing the following lines:
;	^E					begin Greek mode
;	!"#$%&'()*+,-./0123456789:;<=>?@	math and superscripts
;	ABCDEFGHIJKLMNOPQRSTUVWX		Greek lower case
;	YZ[\					Greek upper case
;	]^_					math chars
;	^E					end Greek mode
;
; 12. The following user functions have been defined:
;
;	USR1 (^Q) -- line spacing is 8 lines per inch
;	USR2 (^W) -- line spacing is 6 lines per inch
;	USR3 (^E) -- toggle Greek mode
;	USR4 (^R) -- turn on logic-seeking (bidirectional) mode
;
; 13. The printer initialization sequence performs the following:
;
;	Set pitch to 10 cpi (Pica)
;	Set line spacing to 6 lpi
;	Turn on alphanumeric output
;	Turn on logic-seeking mode
;	Turn underlining off
;	Turn enhanced printing off (or on, depending on version)
;	Move print head to left margin (send a CR)
;
; 14. The printer de-initialization sequence restores the printer
;      to normal settings in case any changes have been made.  The
;      standard settings are the same as in note 12 above, but with
;      enhanced printing turned off.
;
; 15. The following miscellaneous codes are defined:
;
;	CSwtch = 0  (CP/M LST device is used)
;	HavBsy = 0  (Printer has no "busy flag")
;
; * * * * * * * * * * * * * * * * * * *
; *	HOW TO INSTALL THIS PATCH     *
; * * * * * * * * * * * * * * * * * * *
;
; 1. Install WordStar by running INSTALL.COM on WSU.COM as described
;     in section 3 of the WordStar Installation Manual.
;    For the equipment assumed by this patch, choose terminal "K"
;     (Soroc IQ-120), printer type "C" (teletype that can backspace),
;     communication protocol "N" (none), and driver "L" (CP/M LST:
;     device).
; 2. Make a backup copy of WS.COM in case the patch doesn't work.
; 3. Modify this patch file for your particular system.
; 4. Assemble patch file with ASM or MAC.
; 5. Use DDT or SID to write the patch file on top of WordStar:
;
;	A>DDT WS.COM		invoke DDT with WordStar binary
;	DDT VERS 2.2
;	NEXT  PC
;	4000 0100
;	-INECWSOVR.HEX		prepare to read overlay
;	-R			read it
;	NEXT  PC
;	4000 0100		size has not changed
;	-G0			exit from DDT
;	A>SAVE 63 WS.COM	save new WordStar binary
;
; 6. Run new version of WordStar on a test file and make sure the new
:     features work.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
; *** system equates ***
;
TRUE	EQU	0FFH
FALSE	EQU	NOT TRUE
BDOS	EQU	0005H
LISTF	EQU	5	;BDOS function 5
SHOWSTR EQU	9	;BDOS function 9
;
; *****************************************
; ***					***
; ***  SET FLAG FOR LIGHT PRINT VERSION ***
; ***					***
; *****************************************
;
LIGHT	EQU	TRUE	;Set equ FALSE for enhanced print
;
; *** character equates ***
;
CTRL$B	EQU	'B' - 40H
CTRL$H  EQU	'H' - 40H
CTRL$Q	EQU	'Q' - 40H
LF	EQU	0AH		;Line Feed
CR	EQU	0DH		;Carriage Return
ESC	EQU	1BH		;Escape
EOS	EQU	'$'		;End Of String character
EOC	EQU	'Y' - 40H	;End Of Control sequence char
;
; *** WordStar special character equates ***
;
FORM$PARA   EQU	'^' - 40H	;Reformat paragraph
GRK$TOGGLE  EQU	']' - 40H	;Greek char set toggle char
ROLUPCH     EQU	'^' + 80H	;Reverse half-line code char
ROLDOWCH    EQU	'v' + 80H	;Forward half-line code char
;
; *** WordStar patch point equates ***
;
; USER1 area
;
DISLINE1  EQU	018FH	;Address of first line of opening display
DISLINE2  EQU	01B3H	;Address of second line
DISLINE3  EQU	01D7H	;Address of third line (unused)
DISLINE4  EQU	01FBH	;Address of fourth line
SCRNHT	EQU	0248H	;Address of screen height
SCRNWD	EQU	0249H	;Address of screen width
IVON	EQU	0284H	;Address of inverse on
IVOFF	EQU	028BH	;Address of inverse off
INISUB	EQU	02A4H	;Address of initialization sbr
UNISUB	EQU	02A7H	;Address of un-initialization sbr
DELCUS	EQU	02AEH	;Address of cursor movement delay
DELMIS	EQU	02AFH	;Address of special function delay
DEL1	EQU	02CFH	;Address of short delay
DEL2	EQU	02D0H	;Address of medium-short delay
DEL3	EQU	02D1H	;Address of medium-long delay
DEL4	EQU	02D2H	;Address of long delay
DEL5	EQU	02D3H	;Address of horizontal scroll refresh delay
MORPAT	EQU	02E0H	;Start of user patch area
;
; USER 2 area
;
ITHELP	EQU	0360H	;Address of initial help setting flag
NITHLF	EQU	0361H	;Address of maximum help flag
FNWSCM	EQU	03E7H	;Address of name of WS program
BSPADR	EQU	0499H	;Address of "backspace char"
DELADR	EQU	0529H	;Address of "delete char left"
DBLADR	EQU	0539H	;Address of "delete to beginning of line"
PARADR	EQU	054DH	;Address of "reformat paragraph"
;
; USER3 area
;
;	No changes made in USER3 area
;
; USER4 area
;
POSMTH	EQU	0690H	;Address of printer overstrike method
BLDSTR	EQU	0691H	;Address of number of strikes for bold
PALT	EQU	06B5H	;Address of alternate char width sequence
PSTD	EQU	06BAH	;Address of standard char width sequence
ROLUP	EQU	06BFH	;Address of reverse half-line sequence
ROLDOW	EQU	06C4H	;Address of forward half-line sequence
USR1	EQU	06C9H	;Address of user-defined function 1
USR2	EQU	06CEH	;Address of user-defined function 2
USR3	EQU	06D3H	;Address of user-defined function 3
USR4	EQU	06D8H	;Address of user-defined function 4
RIBBON	EQU	06DDH	;Address of ribbon change
RIBOFF	EQU	06E2H	;Address of normal ribbon
PSINIT	EQU	06E7H	;Address of printer initialization string
PSFINI	EQU	06F8H	;Address of printer de-initialization string
ULCHR	EQU	070CH	;Address of underscore character
CSWTCH	EQU	0717H	;Address of "where to send output char"
HAVBSY	EQU	0718H	;Address of "does printer have a busy test?"
LISEND	EQU	071DH	;Address of character to list device sbr
ALTPRTR EQU	0728H	;Address of alternate printer drivers
;
; USER1 area
;
; *** Install new opening display ***
;
	ORG	DISLINE1
	DB	' NEC '
	DB	'C' + 80H	;Set MSB for Cyan display
	DB	'o' + 80H
	DB	'l' + 80H
	DB	'o' + 80H
	DB	'r' + 80H
	DB	' WordStar'
	DB	'               '	;15 blanks
	DB	0FH, 0
;
	ORG	DISLINE2
	DB	' NEC PC-8023A-C Printer'
	DB	'           '		;11 blanks
	DB	0FH, 0
;
	ORG	DISLINE4
	DB	' '
	IF	LIGHT		;Install light print header
	DB	'L' + 80H	;Set MSB for Cyan display
	DB	'i' + 80H
	DB	'g' + 80H
	DB	'h' + 80H
	DB	't' + 80H
	DB	' print version'
	DB	'              '	;14 blanks
	ENDIF
;
	IF	NOT LIGHT	;Install enhanced print header
	DB	'E' + 80H	;Set MSB for Cyan display
	DB	'n' + 80H
	DB	'h' + 80H
	DB	'a' + 80H
	DB	'n' + 80H
	DB	'c' + 80H
	DB	'e' + 80H
	DB	'd' + 80H
	DB	' print version'
	DB	'           '		;11 blanks
	ENDIF
;
	DB	0FH, 0
;
; *** Change screen dimensions ***
;
	ORG	SCRNHT
	DB	24	;Screen height
;
	ORG	SCRNWD
	DB	79	;Screen width
;
; *** Define inverse on/off sequences ***
;
	ORG	IVON
	DB	4		;Length of sequence
	DB	ESC, 'C6', EOC	;Color 6 (Yellow)
;
	ORG	IVOFF
	DB	4		;Length of sequence
	DB	ESC, 'C5', EOC	;Color 5 (Cyan)
;
; *** Install jump vectors to init/un-init sbrs ***
;
	ORG	INISUB
	JMP	INIT$TERM
;
	ORG	UNISUB
	JMP	DENIT$TERM
;
; *** Change delay times ***
;
	ORG	DELCUS
	DB	1
;
	ORG	DELMIS
	DB	1
;
	ORG	DEL1
	DB	2
;
	ORG	DEL2
	DB	4
;
	ORG	DEL3
	DB	8
;
	ORG	DEL4
	DB	16
;
	ORG	DEL5
	DB	4
;
; *** Install custom user routines ***
;
	ORG	MORPAT		;Start of user patch area
;
; *** Initialize/de-initialize CRT ***
;
INIT$TERM:
	LXI	D,INIT$CRT	;Load start of sequence
	JMP	STR$OUT		;and display it
;
DENIT$TERM:
	LXI	D,DENIT$CRT	;Load start of sequence
;
STR$OUT:
	MVI	C,SHOWSTR	;Display string on console
	JMP	BDOS
;
; *** Install custom character print routine ***
;
PRINTC:
	MOV	C,A		;Save character
	CPI	ROLUPCH		;Check for reverse half-line code char
	JZ	MOVE$UP
	CPI	ROLDOWCH	;Check for forward half-line code char
	JZ	MOVE$DOWN
	CPI	GRK$TOGGLE	;Check for Greek toggle char
	LDA	GRK$FLAG	;Get Greek flag
	JZ	SET$GREEK	;Set/reset Greek flag
	ANA	A		;Is Greek flag set ??
	JZ	PUT$CHAR	;Print normal character
	LXI	H,GREEK$TABLE	;Load base of Greek table
	MOV	A,C		;Restore character
	CPI	'_' + 1		;Last char in alternate set + 1
	JNC	PUT$CHAR	;Print normal character
	SUI	'!'		;First char in alternate set
	JC	PUT$CHAR	;Print normal character
	ADD	L		;Calculate address of Greek char
	MOV	L,A		;Set address of char
	MOV	C,M		;Get Greek character
;
PUT$CHAR:
	MOV	E,C		;Print character
	MVI	C,LISTF
	JMP	BDOS
;
MOVE$UP:
	MVI	B,13		;13 characters in sequence
	LXI	H,UP$SEQ	;Load start address into HL
	JMP	PRT$STR		;Print string
;
MOVE$DOWN:
	MVI	B,9		;9 characters in sequence
	LXI	H,DOWN$SEQ	;Load start address into HL
;
PRT$STR:
	MOV	E,M		;Load character into E
	MVI	C,LISTF		;and print it
	INX	H		;Advance to next char
	PUSH	H		;Save registers
	PUSH	B
	CALL	BDOS		;Print character
	POP	B		;Restore registers
	POP	H
	DCR	B		;Decrement counter
	JNZ	PRT$STR		;Print next char
	RET
;
SET$GREEK:
	CMA			;00H <==> FFH
	STA	GRK$FLAG	;Set or reset flag
	RET
;
INIT$CRT:
	DB	ESC, 'V0,24,1,1', EOC	;24 lines, color mode
	DB	ESC, 'C6', EOC		;Color 6 (Yellow)
	DB	EOS
;
DENIT$CRT:
	DB	ESC, 'V,25', EOC	;25 lines, color mode
	DB	ESC, 'C5', EOC		;Color 5 (Cyan)
	DB	ESC, '*'		;Clear screen
	DB	EOS
;
; USER2 area
;
; *** Define new default help values ***
;
	ORG	ITHELP		;Initial help level
	DB	2
;
	ORG	NITHLF		;Initial help flag
	DB	0		;Display maximum help message
;
; *** Change name of WS program ***
;
	ORG	FNWSCM		;WordStar program name
	IF	LIGHT
	DB	'WS      COM'	;Name for light    print version
	ENDIF
	IF	NOT LIGHT
	DB	'WSE     COM'	;Name for enhanced print version
	ENDIF
;
; *** Redefine control keys ***
;
	ORG	BSPADR		;Backspace (non-destructive)
	DB	CTRL$B
;
	ORG	DELADR		;Delete char left (destructive BSP)
	DB	CTRL$H
;
	ORG	DBLADR		;Delete to beginning of line
	DB	CTRL$Q, CTRL$H
;
	ORG	PARADR		;Reformat paragraph
	DB	FORM$PARA
;
; USER3 area
;
;	No changes made in USER3 area
;
; USER4 area
;
; *** Printer characteristics ***
;
; *** Define overstrike method code ***
;
	ORG	POSMTH		;Overstrike method is CR
	DB	0FFH
;
; *** Set BOLD print repetition count ***
;
	ORG	BLDSTR		;Number of strikes for bold
	DB	3
;
; *** Define character width sequences ***
;
	ORG	PALT		;Alternate char width (12 pitch)
	DB	2		;Length of sequence
	DB	ESC, 'E'	;Elite
;
	ORG	PSTD		;Standard char width (10 pitch)
	DB	2		;Length of sequence
	DB	ESC, 'N'	;Normal
;
; *** Define reverse and forward half-line sequences ***
;
	ORG	ROLUP		;Reverse half-line
	DB	1		;Length of sequence
	DB	ROLUPCH		;Coded char (see LISEND)
;
	ORG	ROLDOW		;Reverse half-line
	DB	1		;Length of sequence
	DB	ROLDOWCH	;Coded char (see LISEND)
;
; *** User-defined functions ***
;
	ORG	USR1		;Function 1 (^Q)
	DB	2		;Length of sequence
	DB	ESC, 'B'	;8 lines per inch
;
	ORG	USR2		;Function 2 (^W)
	DB	2		;Length of sequence
	DB	ESC, 'A'	;6 lines per inch
;
	ORG	USR3		;Function 3 (^E)
	DB	1		;Length of sequence
	DB	GRK$TOGGLE	;Alternate character set
;
	ORG	USR4		;Function 4 (^R)
	DB	2		;Length of sequence
	DB	ESC, ']'	;Logic seeking mode
;
; *** Ribbon change sequences used for 9-th dot underlining ***
;
	ORG	RIBBON		;Alternate ribbon color
	DB	2		;Length of sequence
	DB	ESC, 'X'	;Underline On
;
	ORG	RIBOFF		;Normal ribbon color
	DB	2		;Length of sequence
	DB	ESC, 'Y'	;Underline Off
;
; *** Printer initialization/de-initialization sequences ***
;
	ORG	PSINIT
	DB	13		;Length of sequence
	DB	ESC, 'N'	;10 chars per inch
	DB	ESC, 'A'	;6 lines per inch
	DB	ESC, '$'	;Alphanumeric output
	DB	ESC, ']'	;Logic-seeking mode
	DB	ESC, 'Y'	;Underline off
	IF	LIGHT
	DB	ESC, '"'	;Enhanced print off
	ENDIF
	IF	NOT LIGHT
	DB	ESC, '!'	;Enhanced print on
	ENDIF
	DB	CR		;Move print head to left
;
	ORG	PSFINI
	DB	13		;Length of sequence
	DB	ESC, 'N'	;10 chars per inch
	DB	ESC, 'A'	;6 lines per inch
	DB	ESC, '$'	;Alphanumeric output
	DB	ESC, ']'	;Logic-seeking mode
	DB	ESC, 'Y'	;Underline off
	DB	ESC, '"'	;Enhanced print off
	DB	CR		;Move print head to left
;
; *** Define underscore character ***
;
	ORG	ULCHR
	DB	80H		;Graphics underscore
;
; *** Define "where to send output" code ***
;
	ORG	CSWTCH
	DB	0		;CP/M list device
;
; *** Define "printer has no busy flag" code ***
;
	ORG	HAVBSY
	DB	0		;No flag
;
; *** Install LISEND patch to check for special character ***
;
	ORG	LISEND
	CALL	PRINTC
	ORA	A		;Clear CY flag
	RET
;
; *** Install user strings over alternate printer drivers ***
;
	ORG	ALTPRTR
;
UP$SEQ:
	DB	ESC, '['	;Incremental mode
	DB	ESC, 'r'	;Line feed direction is Reverse
	DB	ESC, 'T09'	;Line spacing = 9/144
	DB	LF		;Perform reverse line feed
	DB	ESC, 'f'	;Line feed direction is Forward
	DB	ESC, 'A'	;6 lines per inch
;
DOWN$SEQ:
	DB	ESC, '['	;Incremental mode
	DB	ESC, 'T09'	;Line spacing = 9/144
	DB	LF		;Perform forward line feed
	DB	ESC, 'A'	;6 lines per inch
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *   NOTE: address of all bytes in list must have same high-order byte *
; *	     so that 8-bit addition may be used to compute address.     *
; *	    be careful if you move this table				*
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
GREEK$TABLE:
	DB	0EDH,0ECH,0D9H,0D0H,0A8H,0AFH,0A6H,0ADH
	DB	0AEH,0A3H,0ACH,0CDH,0CEH,0A2H,0A5H,0DCH
	DB	0C7H,0CCH,0B1H,0B3H,0B4H,0B5H,0D4H,0D5H
	DB	0D6H,0A7H,0A9H,0A4H,0D2H,0A1H,0AAH,0ABH
	DB	0C0H,0C3H,0B2H,0BDH,0B6H,0DDH,0C5H,0C6H
	DB	0D7H,0BEH,0DEH,0DFH,0C1H,0C4H,0BCH,0CAH
	DB	0B7H,0B8H,0CFH,0C9H,0D8H,0DAH,0B9H,0BAH
	DB	0C2H,0BFH,0BBH,0D1H,0B0H,0CBH,0C8H
;
GRK$FLAG:
	DB	0		;00H => off  FFH => on
;
; ********************************************
; ***					   ***
; ***  GRK$FLAG *MUST* BE LESS THAN 0783H  ***
; ***					   ***
; ********************************************
;
	END
