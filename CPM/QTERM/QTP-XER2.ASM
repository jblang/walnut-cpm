; QTERM Version 4.x Patch Area
; Code as adapted from QTERM.COM from QTERM33A.LBR posted by David Goodenough
;  to BOSKUG RCP/M circa 12/27/88, and QTERM Vers. 4.x patch listing 8-Feb-89.

; D. Presberg dissasembled this with Z8E, 21-Jan-89.  Code labels taken from
;  D. Goodenough "qterm.z" example circa 8-Feb-89.

; This edit is for Kaypro-II and -4 ('83 version without graphics).  Kaypro
;  (and Xerox BB-I) use an SIO chip, port A, with a separate baud rate
;  generator:  status port at 04, data port at 06, baud rate port at 0.
;  15-Feb-89, D. Presberg, BCS/BOSKUG.

; D. Goodenough added break, dtr and mode stuff  2-23-89

; Modified for Xerox 820-II, 16/8. Clears screen at start, at end, and re-
;  sets alternate video at end; all terminal capabilities supported.
;  By Tim Carney 17-Apr-89.

sioc	equ	6		; sio control port
siod	equ	4		; sio data port

yes	equ	0ffh		; true value
no	equ	0		; false value

	org	110h
modist:	in	a,(sioc)	;get modem input status  (Kaypro status port)
	and	01h		; (result to Z:   no inp. character available
	ret			;   is 0 at bit-0 (low order) ===>   Z==1    )

	org	120h
modin:	in	a,(siod)	;read modem input character (Kaypro data port)
	ret

	org	130h
modost:	in	a,(sioc)	;get modem output status  (Kaypro status port)
	and	04h		; (result to Z:  bit-2 ... see above)
	ret

	org	140h
modout:	out	(siod),a	;write modem output char. (Kaypro data port)
	ret

	org	150h
sbreak:	ld	a,(setf)	;start "break"
	or	a		;do we have valid data in r3,r4,r5
	ret	z		;no - don't do it
	jp	exmlp		; start break takes a bit extra, see below
	
	org	160h
ebreak:	ld	a,(setf)	;end "break"
	or	a
	ret	z		; don't do it unless r3, r4, r5 are valid
	ld	hl,r5
	res	4,(hl)
	jp	sioout

	org	170h
dtroff:	ld	a,(setf)	;drop DTR
	or	a
	ret	z		; don't do it unless r3, r4, r5 are valid
	ld	hl,r5
	res	7,(hl)
	jp	sioout

	org	180h
dtron:	ld	a,(setf)	;raise DTR
	or	a
	ret	z		; don't do it unless r3, r4, r5 are valid
	ld	hl,r5
	set	7,(hl)
	jp	sioout

	org	190h
setbd:	out	(00h),a		;set baud rate (value in A) (Kaypro baud
	ret			;rate port)

; The Baud Rate Table has entries from 38400 baud down to 300 baud.
;   There are 2 bytes per entry.  The second byte determines if the entry is
;   enabled or disabled (ffh=enabled; 00=disabled).  The first byte is passed
;   as the A value to the setbd subroutine.

; Kaypro-II/4 has advertised values for rates up to 19200.  Not all available
;   low speeds are used by QTERM, however.

	org	1a0h
baudtb:

b38400:	defb	0,no		;  38400 baud
b19200:	defb	0fh,yes		;  19200
b9600:	defb	0eh,yes		;   9600
b4800:	defb	0ch,yes		;   4800
b2400:	defb	0ah,yes		;   2400
b1200:	defb	07h,yes		;   1200
b600:	defb	06h,yes		;    600
b300:	defb	05h,yes		;    300 baud
; (Kaypro goes down to 150, 134.5, 110, 75, and 50 baud, but QTERM doesn't.)

	org	1b0h
setmod:	ld	(setf),a	; flag we've done a set
	ld	c,a		; save byte in c
	ld	hl,r3		; look at byte for wr3
	res	7,(hl)		; turn off ms bit (Rx # bits / char)
	add	a,a		; move bit from 6 to 7 in a
	and	80h		; mask off the rest
	or	(hl)		; or in the remainder
	jp	finmod		; have to finish this elsewhere

; Communication Mode Table.  Single byte values for 12 combinations of
;    number-of-bits(7/8), parity(none/even/odd), number-of-stop-bits(1/2).

	org	1c0h
modetb:

n17:	defb	10000000b	;080h, 7n1
n18:	defb	11000000b	;0c0h, 8n1
n27:	defb	10001000b	;088h, 7n2
n28:	defb	11001000b	;0c8h, 8n2
e17:	defb	10000011b	;083h, 7e1
e18:	defb	11000011b	;0c3h, 8e1
e27:	defb	10001011b	;08bh, 7e2
e28:	defb	11001011b	;0cbh, 8e2
o17:	defb	10000001b	;081h, 7o1
o18:	defb	11000001b	;0c8h, 8o1
o27:	defb	10001001b	;089h, 7o2
o28:	defb	11001001b	;0c9h, 8o2

	org	1cch
smlbuf:	defb	no	; set this 'yes' if you run out of ram - this feature
			; is not yet implemented, but in time (i.e. V4.1)
			; it will be. QTERM is a real memory hog - it needs
			; well in excess of 48K TPA. If you have a full blown
			; Z-system with oodles of RSX additions, you may
			; run out of space. By setting this true, you can get
			; QTERM to shrink some buffers and fit itself into
			; about 42K, the price paid is somewhat more
			; frequent disk access when reading and writing files.

	org	1cdh
xfersz:	defb	8	;number of K to read/write during file xfers
			;Must be 1 / 2 / 4 / 8.  Best left as 8 unless
			;  disk is verrrrry slow.  Drop to smaller value
			;  if too many timeouts occur during "protocol"
			;  file transfers (xmodem or kermit).

	org	1ceh
speed:	defb	4	;cpu speed (Mhz; use 3 for 2.5, 4 for Xerox).
			; (5Mhz Assumes Advent speedup kit in Kaypro.)

	org	1cfh
escape:	defb	1bh	;escape character (1ch=^\  Control-Backslash)
			;use 1bh (^[=ESC) for Xerox.
	org	1d0h
signon:			;signon message
	defb	'(Xerox 16/8 1984) '
	defb	0

	org	1f0h
clrs:	defb	1ah	;clear screen string (Control-Z)
	defb	0

scrout	equ	109h	;(a routine to print to CON: the
			;   character in C)
decout	equ	10ch	;(a routine to print to CON: a decimal value
			;   in HL.  Is available for VT100 and the like.)

	org	200h
moveto:	push	hl	;move cursor to position in HL (Row,Col)
	ld	c,1bh	; lead-in with Esc (the ASCII one; not QTERM's)
	call	scrout
	ld	c,'='	; 2nd lead-in is '='
	call	scrout
	pop	hl
	push	hl
	ld	a,h	; row value (top row is 0.)
	call	poff	; add offset and send it to screen
	pop	hl
	ld	a,l	; col value (leftmost col is 0.)
poff:	add	a,' '	; (adds 20h)
	ld	c,a
	jp	scrout	; (scrout returns from 'moveto's call)

; Terminal Capability Bits.  The eight bits stand for each of the following
;   strings.   They count from 01h=bright to 80h=clear-to-end-of-screen.

b_brit	equ	00000001b	; 0: bright (1.)	-- NOT mandatory
b_dim	equ	00000010b	; 1: dim    (2.)	-- NOT mandatory
b_dlln	equ	00000100b	; 2: delete line (4.)	-- important
b_inln	equ	00001000b	; 3: insert line (8.)	-- important
b_dlch	equ	00010000b	; 4: delete character (16.)-- unused by QTERM
b_inch	equ	00100000b	; 5: insert character (32.)-- NOT mandatory
b_clel	equ	01000000b	; 6: clear to end-of-line(64.) -- important
b_cles	equ	10000000b	; 7: clear to end-of-screen(128.)-- important

	org	22fh
tcbits:	defb	0ffh		; capability bits- all functions supported
				; by Xerox.

; (Kaypro-II/4, non-graphics version, cannot do in-place insertion or deletion
;   of single characters:  it can only overwrite characters at the current
;   cursor position and move the cursor non-destructively, etc..  It can
;   do in-place insertion and deletion of lines, and its clear-to-end-of-
;   -screen and -line leaves the cursor as-is.  It also has clear-screen-and-
;   -home-the-cursor: see clrs, above.  It, of course, has no graphical screen
;   attributes, such as bright and dim.)

	org	230h
brites:	defb	27		;bright string (none for '83 Kaypro)
	defb	40		;Xerox ESC-(, alternate video disable
	defb	0		;code.

	org	238h
dims:	defb	27		;dim string    (none for '83 Kaypro)
	defb	41		;Xerox ESC-) ESC-8 (enable alternate
	defb	27		;video,set to dim characters).
	defb	56
	defb	0



	org	240h
dlstr:	defb	1bh	;delete line
	defb	'R'
	defb	0

	org	248h
ilstr:	defb	1bh	;insert line
	defb	'E'
	defb	0

	org	250h
dcstr:	defb	27	;delete character (none for '83 Kaypro)
	defb	'W'	;Xerox ESC-W del character string.
	defb	0

	org	258h
icstr:	defb	27	;insert character (none for '83 Kaypro)
	defb	'Q'	;Xerox ESC-Q ins character string.
	defb	0


	org	260h
ceol:	defb	18h	;clear to end of line (Control-X)
	defb	0

	org	268h
ceos:	defb	17	;clear to end-of-screen (Control-W)
	defb	0	;Xerox uses CTRL-Q


; Entry and Exit hooks.  These are provided to perform custom initialisation
; on startup and on exit from QTERM.  They are invoked before any use is made
; of the screen or the port hardware.

	org	270h
entry:	jp	do_ent		; entry hook (270h .. 272h)



	org	273h		; exit hook  (273h .. 275h)	
exit:	jp	do_exit         ; Exit routine-Xerox 820-II, 16/8.

; Extra patch area if needed.  276h .. 2ffh

	org	276h
patcha: 

do_ent:	ld	c,26		;Send clear screen and home cursor
	call	scrout		;to console...
	jp	start

start:	ld	a,(b1200)	; entry hook (from 270h)
	call	setbd		;   Kaypro-II/4 setup for 1200 baud
	ld	a,(n18)		; and 8n1 communications mode.
	call	setmod
	ret

exmlp:	ld	a,1		; wait till transmitter is really finished
	out	(siod),a
	in	a,(siod)
	rra
	jr	nc,exmlp	; loop till buffer empty
	ld	hl,r5
	set	4,(hl)		; now go set the break bit.

sioout:	ld	hl,siodat
	ld	bc,6 * 256 + sioc
	otir
	ret

finmod:	ld	(hl),a		; and save it back
	inc	hl
	inc	hl		; point hl at r4
	ld	a,(hl)
	and	0f4h		; mask out bits we don't want
	ld	b,a		; save in b
	ld	a,c		; get set byte back
	and	0bh		; get bits out of set byte that we want
	or	b		; or in the other bits
	ld	(hl),a		; and save it back
	inc	hl
	inc	hl		; point hl at r5
	ld	a,c
	and	40h		; get the bit we want from c
	res	6,(hl)		; clear the bit in r5
	or	(hl)
	ld	(hl),a		; put new composite value back
	jp	sioout		; go send the values

siodat:	defb	3
r3:	defb	11000001b	; value for wr3 (0c1h)
	defb	4
r4:	defb	01000100b	; value for wr4 (044h)
	defb	5
r5:	defb	11101010b	; value for wr5 (0e5h)

setf:	defb	0		; flag if we've done a set mode command

	org 	02c5h
do_exit:
	ld	c,26		; Xerox specific.Clear screen, home cursor
	call	scrout
	ld	c,27		; Change alternate video mode to inverse.
	call	scrout		; (52 or 54=blink, 53=graphics, 55=inverse	
	ld	c,55		; 56=dim).
	call	scrout
	ret

	end
