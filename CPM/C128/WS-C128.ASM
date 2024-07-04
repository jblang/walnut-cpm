;
; WS.MAC  --  Overlay for WordStar Release 4 on the Commodore 128
;
; This is an overlay for WS.COM that will allow you to use all the
; video attributes to show printer codes on the screen of a color
; monitor.  The overlay provides for the following attributes:
;	Normal text			bright video
;	Strike-out (^PX)		alternate color
;	Error messages			blink
;	Marked block (^KB, ^KK)		reverse video
;	Underlined text (^PS)		underlined
;	Subscripts (^PV)		alternate color
;	Superscripts (^PT)		alternate color
;	Boldface text (^PB and ^PD)	dim video
;	Italic text (^PY)		alternate color
;
; This particular selection will allow for all the various printer
; codes to appear differently and it combination (e.g, boldfaced
; italic text will be in dim alternate color).  Italic, Strike-out,
; Superscripts, and Subscripts all appear in the same alternate 
; color because two colors cannot be displayed simultaneously and
; these codes are less commonly used.
;
; A few other changes are made to WS.COM by this overlay:
;	The delete character will be display by the standard Commodore
;		CP/M delete character, instead of DEL.
;	The BRITE label is set so WordStar displays normal text in 
;		brite video, instead of dim (which doesn't look too
;		good on a color monitor).
;	Various delays have been changed to MicroPro's recommendations
;		for a 2-megahertz CPU.
;
; Before using this overlay, you MUST change the colors at the labels
; ColOn and ColOff to suit the colors you will be using.  You should
; just use the name of the colors as listed in the equates below.
; Color names beginning with 'd' indicate a dark color, e.g., 'dred' means
; dark red.  ColOn is for the color you will use to highlight the 
; alternate color modes listed above.  ColOff is the color you use for
; normal text.  If you don't change them, your alternate color will be
; cyan and your normal text will be in yellow.
;
; After you've selected the colors, assemble the overlay with MAC:
;	A>MAC WS-C128
; Then use MLOAD or SID to overlay your WS.COM:
;	A>MLOAD NEWWS.COM=OLDWS.COM,WS-C128.HEX
; After you've tested it, rename NEWWS.COM to WS.COM and put it on your
; WordStar disk.  Enjoy!
;
;	Gene Pizzetta
;	481 Revere Street
;	Revere, MA  02151
;	Voice (617) 284-0891
;	Compuserve 72060,505
;	QuantumLink GeneP
;
;
String	equ	0283h		; WS string out routine
esc	equ	1Bh
cr	equ	0Dh
lf	equ	0Ah
;
black	equ	20h		; these equates use physical color numbers
white	equ	21h		; ..rather than logical color numbers.
dred	equ	22h		; ..Ordinarily it's best to use logical
cyan	equ	23h		; ..color numbers, but they aren't affected
purple	equ	24h		; ..by the 'dim' escape sequence.  So, in
dgreen	equ	25h		; ..this case, physical colors are best.
dblue	equ	26h
yellow	equ	27h
dpurple	equ	28h
dyellow	equ	29h
red	equ	2Ah
dcyan	equ	2Bh
mgray	equ	2Ch
green	equ	2Dh
blue	equ	2Eh
gray	equ	2Fh
;
;
; Delete Display String
;
; The following string indicates to WordStar how to display a delete
; character (hex 7F) on the screen while editing.  On terminals that
; interpret the delete character code into a displayable character, it
; is recommended that DELSTR be translated into the delete code itself
; (length of 1, then 7Fh).  All characters in the string must display.
;
	org	0326h
;
DELSTR:	db	1,7Fh		; Commodore displays it ...
;
;
; The following string is used at sign-on to describe the type
; of terminal being used by WordStar.  Up to 40 bytes are available
; for the string, including its null terminator.
;
	org	0342h
;
CRTID:	db	'Commodore 128  --  CP/M Plus',cr,lf,0
;
;
; Video attributes are used in various places on the WordStar display.
; (for complete information see PATCH.LST on your WordStar disk.)
; The VIDATT subroutine is used to change video attributes on the screen.
; This subroutine is called only when a video attribute changes.
;
	org	03C1h		; org at VIDATT
;
VIDATT:	mov	a,c
	xra	b
	ani	00001111b	; any change in the 'G' codes?
	jz	VIDA0		; (no)
	lxi	h,AttOff	; yes, turn them all off
	call	String
	lxi	h,RevOn		; is it a marked block?
	mov	a,c
	ani	00000100b
	cnz	String
	lxi	h,BliOn		; is it an error message?
	mov	a,c
	ani	00000010b
	cnz	String
	lxi	h,UndOn		; is it underlined text?
	mov	a,c
	ani	00001000b
	cnz	String
VIDA0:	mov	a,c		; strike-out, italic, super-, subscript?
	ani	10110001b
	jz	VIDA1
	lxi	h,ColOn		; change to the alternate color
	call	String
	jmp	VIDA2
VIDA1:	lxi	h,ColOff	; change to normal color
	call	String
VIDA2:	lxi	h,DimOn		; do we have bold or doublestrike?
	mov	a,c		; (dim must be last attribute selected)
	ani	01000000b
	jz	String		; yes, go dim
	lxi	h,DimOff
	jmp	String		; no, go bright
;
AttOff:	db	3,esc,'G0'
RevOn:	db	3,esc,'G4'
BliOn:	db	3,esc,'G2'
UndOn:	db	3,esc,'G3'
DimOff:	db	2,esc,'('
DimOn:	db	2,esc,')'
ColOff:	db	4,esc,esc,esc,yellow	; this sets normal text color
ColOn:	db	4,esc,esc,esc,cyan	; this sets alternate color
;
;
; Normally the status line, text and directories are displayed in
; dim intensity so that bold and doublestruck text can be shown in
; high intensity.  Setting BRITE to OFFh reverses the usage of
; bright and dim for the status line, text, and directories; normally
; zero.
;
	org	0441h
;
BRITE:	db	0FFh		; 0 = text dim, 0FFh = text bright
;
;
; Delays -- Each delay is approximately the number of milliseconds
; on a 4-Mhz Z80 processor, about twice as long on a 2-Mhz 8080.
;
	org	0444h
;
DXOFF:	dw	1000		; time-out for terminal (was 2000)
DLONG:	dw	1000		; long delays (was 2000)
DMED:	dw	500		; medium delays (was 1000)
DSHORT:	dw	100		; short delays (was 200)
UPDLY:	dw	100		; update delay (was 200)
DDISK:	dw	500		; disk access delay (no change)
DFAST:	dw	25		; delay when fast typing (was 50)
;
	end
