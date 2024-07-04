;	title	'MEX Smartmodem 2400 / USR 2400 Overlay V2.6'
;
; MXM-2416.ASM:  Smartmodem 2400 overlay for MEX: revision 2.6.
;
; This is a modem overlay for the MEX communication program.  It
; supports 2400 baud auto-stepdown, and works with the Hayes 2400
; and US Robotics Courier.  Probably others as well.
;
; (SmarTEAM 2400 added in rev 1.9)
;
; This overlay is based on revisions to MXM-SM15 made by George
; Sipe (who developed the fallback technique, and the checksum
; concept for modem response) and Paul Traina (who added Courier
; 2400 support).
;
; See additional notes after update history, below.
;
;==========================================================================
;
; Update history (please use MXM-2401, MXM-2402, etc when revising).
;	 Note to updaters: please do NOT use mixed upper-case opcodes
;	 and operands with lower case comments.  Someone (I don't know
;	 who, nor, for the love 'a Mike, WHY) loves to go through
;	 source code and intermix case on EACH line!;		(rgf)
;
; To the anonymous idiot who released MXM-2412: the above is not a request,
; it's a *requirement*, stated politely, but a requirement nonetheless.  I
; did not ask for and will not accept an explanation of why you re-formatted
; this overlay.
;
; I can't track changes to the program when you modify every single line;
; since I couldn't track your changes AND since you didn't identify your-
; self, the -2412 release is UNAUTHORIZED, and unacceptable.  Thus,
; MXM-2413 is essentially a re-release of MXM-2411.
;
; When you write your own programs, format 'em any damned way you please.
; If you modify mine, do it my way or keep your hands off.
;
;					--Ron Fowler (10/12/86)
;
; 11/22/86: MXM-2416 (rev 2.6) -- Keith Petersen: Made SSET response
;	    strings shorter so overlay would fit into available space
;	    when verbose response was true.
; 11/08/86: MXM-2415 (rev 2.5) -- Jim Lill: Tested FAST with SmarTEAM, works
;	    although the time to send the dial speed string each time seems
;	    longer than the time saved. Changed the SSET displays to gain a
;	    few bytes so DISC could be TRUE. Otherwise, overlays overuns
;	    0D00H limit. >>NOTE<<, this overlay may not assemble depending on
;	    how equates are set. Space VERY limited.
; 11/01/86: MXM-2414 (rev 2.4) -- Howard Goldstein: Rearranged code below
;				  NOAUTO: to permit correct assembly
;				  for Hayes.  Fixed "fast" option:
;				  Was sending dial speed digits to
;				  modem in reverse order.
; 10/12/86: MXM-2413 (rev 2.3) -- Ron Fowler: Shortened update log (which had
;				  grown to occupy a substantial part of the
;				  size of the source file).  Re-issued around
;				  MXM-2412, as described above.
; 07/13/86: MXM-2411 (rev 2.1) -- Jim Lill
; 07/10/86: MXM-2410 (rev 2.0) -- Jim Lill
; 07/09/86: MXM-2409 (rev 1.9) -- Jim Lill
; 07/04/86: MXM-2408 (rev 1.8) -- Lee D. Rimar
; 06/26/86: MXM-2407 (rev 1.7) -- Jim Lill [GEnie: JIMLILL], Jeff Laing
; 03/02/86: MXM-2406 (rev 1.6) -- Tim Farley
; 10/06/85: MXM-2405 (rev 1.5) -- Arun Baheti
; 08/23/85: MXM-2404 (rev 1.4) -- Nixy Kuttemperoor
; 08/21/85: MXM-2403 (rev 1.3) -- Kim Levitt
; 08/20/85: MXM-2402 (rev 1.2) -- Arun Baheti
; 08/16/85: MXM-2401 (rev 1.1) -- Kim Levitt
;
; 07/29/85: MXM-2400 (rev 1.0) released. (incorporated work done by
;	    George Sipe and Paul Traina)	--Ron Fowler
;
;------------------------------------------------------------
;
; This overlay takes advantage of the capability of many 2400-baud
; (and perhaps some 1200 baud) modems to "fall back" when a call is
; made to a modem at a rate less than the highest rate supported by
; the calling modem.  The MEXBD equate (below) determines the highest
; baudrate supported by the modem (6 for 2400, 5 for 1200), and makes
; all calls at that baudrate.  If the remote modem answers at a lower
; rate, this overlay will switch to the lower rate. (You can turn
; this feature on or off with the SSET AUTO ON and SSET AUTO OFF com-
; mands, respectively.)
;
;
; If you set the USR24 equate, MEX will automatically use the Courier's
; adaptive dialing feature, and will always enable the modem's busy
; detector (which increases the frequency of "hits" when using re-
; peated dialing to a busy number). The USR24 equate also enables VOICE
; answer detection (if you've ever repeatedly used MEX to dial a wrong
; number, then discovered your error and felt bad for the poor guy on
; the other end, you should use this option) Also, you can set SHOWRNG
; TRUE and this overlay will print "RING" each time the distant end rings.
;
; Another feature for those of you using touch tone dialing on the USR
; is the ability to determine how fast to dial digits. This doesn't seem
; like much, but when you are autodialing a busy system, miliseconds can
; add up.
;
; If you use the USR24 or HAYES equates, you may want to customize the
; modem dial string prefix at the label SMDIAL.
;
;==========================================================================
;
; EXCEPTION TO AUTO BAUD STEPDOWN
;
; The exception is when you are currently set at a baud rate less than
; 1200bd since neither the smartmodem or the courier will step down
; below 1200bd, in which case the call is made at the current baud rate.
; If your modem is unlike the smartmodem or the courier and will stepdown
; to lower baud rates then change the LBAUD equate below to the lowest
; rate which your modem will step down to.
;
;------------------------------------------------------------
;
; This module adapts MEX for the DC Hayes Smartmodem (as well
; as many others -- including US Robotics -- that use a similar
; command language).  The main function of this module is to pro-
; vide dialing capability; the disconnect vector is ancillary.
; You may use this module as a model to develop dialing routines
; for non-standard modems (e.g., the Racal-Vadic).  The only
; pertinent entry point is the DIAL routine; you'll find entry
; specs for that below.
;
; The only conditional you might want to change in this module is
; the DISC equate below -- if left on, MEX will use the
; Smartmodem's disconnect code.  If you prefer to provide your own
; in your overlay's DISCV vector (e.g., by dropping DTR), then set
; DISC to FALSE and re-assemble.  (If you don't understand this,
; then play it safe, and leave the equate set as it is).  NOTE:
; Note that MexPlus supports both "hardware" (DTR) AND "software"
; (Smartmodem) disconnection: always set DISC to TRUE for MexPlus.
;
false	equ	0
true	equ	not false
;
crfl	equ	true		;set true for SM13 style flush (see 1.7 notes)
spkdef	equ	1		;set 1 for spkr ON as default,	 0=OFF
abfdef	equ	1		;set 1 for autobaud fallback ON, 0=OFF
spabrt	equ	true		;set true if only space bar should abort
				;current dial.	If false, any key except ^C.
fast	equ	false		;set true for fast dialing on USR or SmarTEAM
dspeed	equ	40		;milliseconds for each digit if fast equ yes
				;My phone system will take 38, but 40 should
				;be safe for any phone system (50min for Team)
wait	equ	60		;maximum time to wait for result. 45 secs good
				;unless your using MCI etc then try 60 (60max)
hayes	equ	false		;set to true if using a Hayes Smartmodem 2400
usr24	equ	true 		;set to true if using a US Robotics 2400 modem
team	equ	false		;set to true if using a SmarTEAM 2400 modem
showrng	equ	true		;set true to type RING every time remote rings
maxbd	equ	6		;maximum baudrate: 1=300, 3=600, 5=1200, 6=2400
lbaud	equ	5		;minimum stepdown baud
wordres	equ	true 		;true = interpret word ("verbose") result codes
numres	equ	false		;true = interpret numeric result codes
disc	equ	true		;<<== change to false if you disc. with DTR
				;always set true for MEXPLUS
;
; NOTE: 	This overlay converted for MEXPLUS compatiblility
;		and 8086 translation 2/20/85 by Al Jewer.
;
yes	equ	0ffh		;this is for 8086 translator - do not change
no	equ	0
i8080	equ	yes		;define processor type
i8086	equ	no
tpulsv	equ	0105h		;tone/pulse flag in modem overlay
mspeed	equ	0107h		;mspeed location in modem overlay
ndiscv	equ	015fh		;new (MexPlus) smart modem disconnect here
dialv	equ	0162h		;location of dial vector in overlay
discv	equ	0165h		;location of hardware disconnect vector
newbdv	equ	016eh		;location of the set baud vector
dialoc	equ	0b00h		;dialing code goes here
mexloc	equ	0d00h		;"CALL MEX" here
smtabl	equ	0d55h		;Smartmodem init, de-init and sset vectors
;
; Standard control code equates
;
lf	equ	'J'-'@'		;linefeed
cr	equ	'M'-'@'		;carriage return
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00h (and maintained at this address from
; version to version).	If your overlay needs to call bdos for any
; reason, it should call MEX instead;  function calls below about
; 240 are simply passed on to the bdos (console and list i/o calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of bdos).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file i/o;	if so, use
; the parsfn MEX call with a pointer to the fcb in de to parse out
; the name.  This fcb should support a spare byte immediately pre-
; ceeding the actual fcb (to contain user # information).  If you've
; used mex-10 for input instead of bdos-10 (or you're parsing part
; of a set command line that's already been input), then MEX will
; take care of du specs, and set up the fcb accordingly.  There-
; after all file i/o calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
;
inmdm	equ	255		;get char from port to a, cy=no more in 100 ms
timer	equ	254		;delay 100ms * reg b
tmdinp	equ	253		;B=# secs to wait for char, cy=no char
chekcc	equ	252		;check for ^c from kbd, z=present
sndrdy	equ	251		;test for modem-send ready
rcvrdy	equ	250		;test for modem-receive ready
sndchr	equ	249		;send a character to the modem (after sndrdy)
rcvchr	equ	248		;recv a char from modem (after rcvrdy)
lookup	equ	247		;table search: see cmdtbl comments for info
parsfn	equ	246		;parse filename from input stream
bdpars	equ	245		;parse baud-rate from input stream
sblank	equ	244		;scan input stream to next non-blank
evala	equ	243		;evaluate numeric from input stream
lkahed	equ	242		;get nxt char w/o removing from input
gnc	equ	241		;get char from input, cy=1 if none
ilp	equ	240		;inline print
decout	equ	239		;decimal output
prbaud	equ	238		;print baud rate
prntbl	equ	237		;print table
prid	equ	236		;print [mex] id
onoff	equ	235		;parse on/off fm input strm a=0 or 1 (c=err)
				;doesn't seem to be in mex 1.12?
;
kbdin	equ	1		;keyboard input
conout	equ	2		;simulated bdos function 2: console char out
dconio	equ	6		;direct console i/o: passed through to bdos
dconin	equ	yes		;flag in E register for input on func 6
print	equ	9		;simulated bdos function 9: print string
inbuf	equ	10		;input buffer, same structure as bdos 10
kstat	equ	11		;keyboard status
;
; ***** Code starts here *****
;
;
; NOTE: 	This file contains control characters used by our
;		8080-8086 translator, XLAT.  These are in the form
;		of "\" characters inserted as the first character
;		of the comment field.  Please do not change or
;		delete these, so that future versions of this
;		overlay will directly convert to 8086 operation.
;		Thanks - Al Jewer.
;
; For MEXPLUS, the first byte of the overlay MUST contain a "jump"
; opcode.  The is a 0C3H for 8080 and an 0E9H for 8086.  MEXPLUS
; checks this byte before it loads the overlay, to make sure you
; don't load the wrong type of overlay.  This byte will not affect
; pre-MEXPLUS versions.
;
; Also, MEXPLUS contains a new vector at 15FH which is the smart-
; modem disconnect vector (now separate from the hardware vector at
; 165H).  The hardware vector typically toggles the DTR line to
; cause a hangup, while the smart-modem vector sends the hangup
; string to the modem.	MEXPLUS will ignore the vector at 165H in
; this overlay.
;
	org	100h		;base of tpa
;
if i8080
	db	0c3h		;define 8080 overlay
endif			;I8080
;
if i8086
	db	0e9h		;8086 flag
endif			;I8086
;
	org	tpulsv
	db	'T'		;touchtone flag
			;use 'T' for tone, 'P' for pulse or ' ' if USR
			;and you wish "adaptive" dialing.
;
if disc				;if providing disconnect code
	org	ndiscv		;Smartmodem disconnect vector (MexPlus)
	jmp	discon
endif
if not disc			;if not providing disconnect code
	org	ndiscv		;fix sm25..sm24 had no org here
	ret			;for MEXPLUS, in case somebody screws up....
endif				;disc
;
	org	dialv		;overlay the dialing vector
	jmp	dial
;
if disc				;if providing disconnect code
	org	discv		;overlay the vector (mex 1.1x)
	jmp	discon
endif				;disc
;
	org	dialoc
;
; The following is a "signature" word that identifies this overlay (for
; multiple-modem selection based on processor number in a TurboDOS sys-
; tem).  If you use this overlay to develop a non-autobaud overlay for
; a different modem, either move this block to the end of the program,
; or contact NightOwl Software (414-563-4013) for assignment of a dif-
; ferent signature ID).
;
	dw	3746		;signature of MXM-2400.
abdflg:	db	abfdef		;auto baud rate on/off flag
mbaud:	db	maxbd		;maximum baudrate
spkflg:	db	spkdef		;monitor speaker on/off flag
;
if usr24 and numres and	(not fast)
smdial:	db	'ATX6V0Q0M'	;combined all init codes
msmark:	db	'3D'		;with dial command
tpmark:	db	' ',0
endif
;
if usr24 and numres and	fast
inimsg:	db	'ATX6V0Q0S11='
	db	dspeed/10+'0',(dspeed mod 10)+'0'
	db	cr,0
smdial:db	'ATM'
msmark:	db	'3D'
tpmark:	db	' ',0
endif
;
if usr24 and wordres and (not fast)
smdial:	db	'ATX6V1Q0M'	;combined all init codes
msmark:	db	'3D'		;with dial command
tpmark:	db	' ',0
endif
;
if usr24 and wordres and fast
inimsg:	db	'ATX6V1Q0S11='
	db	dspeed/10+'0',(dspeed mod 10)+'0'
	db	cr,0
smdial:	db	'ATM'
msmark:	db	'3D'
tpmark:	db	' ',0
endif
;
if hayes and numres
smdial:	db	'ATX4V0M'
msmark:	db	'0Q0&C0D'
tpmark:	db	' ',0
endif
;
if hayes and wordres
smdial:	db	'ATX4V1M'
msmark:	db	'3Q0&D2D'
tpmark:	db	' ',0
endif
;
if team	and numres and (not fast)
smdial:	db	'ATX4V0M'
msmark:	db	'0Q0&C0D'
tpmark:	db	' ',0
endif
;
if team	and numres and fast		;added in 2.1
inimsg:	db	'ATX4V0Q0&C0S11='
	db	dspeed/10+'0',(dspeed mod 10)+'0'
	db	cr,0
smdial:db	'ATM'
msmark:	db	'0D'
tpmark:	db	' ',0
endif
;
if team	and wordres and	(not fast)
smdial:	db	'ATX4V1M'
msmark:	db	'0Q0&C0D'
tpmark:	db	' ',0
endif
;
if team	and wordres and	fast		;added in 2.1
inimsg:	db	'ATX4V1Q0&C0S11='
	db	dspeed/10+'0',(dspeed mod 10)+'0'
	db	cr,0
smdial:	db	'ATM'
msmark:	db	'0D'
tpmark:	db	' ',0
endif
;
if not (usr24 or hayes or team)
smdial:	db	'ATM'
msmark:	db	'3D'
tpmark:	db	'T',0		;Smartmodem dial string
endif
;
;------------------------------------------------------------
;
; This is the DIAL routine called by MEX to dial a digit.  The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial
; sequence) and 255 (end-dial sequence).  Mex will always call DIAL
; with 254 in the accumulator prior to dialing a number.  Mex will
; also call dial with 255 in A as an indication that dialing is
; complete.  Thus, the overlay may use these values to "block" the
; number, holding it in a buffer until it is completely assembled
; (in fact, that's the scheme employed here for the Smartmodem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the
; digits, and will send each to the DIAL routine un-inspected (some
; modems, like the Smartmodem, allow special non-numeric characters
; in the phone number, and MEX may make no assumptions about
; these).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting
; for carrier at the distant end.  The overlay should monitor the
; keyboard during this wait (using the MEX keystat service call),
; and return an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;	5 - No ring detected (only for modems that can detect this condition)
;	6 - No dial tone (only for modems that can detect this condition)
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine,
; but instead use either the overlay timer vector, or the INMDMV
; (timed 100 ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must
; return the above code after an end-dial sequence
;
;
dial:	cpi	255		;end dial?
	jz	endial		;\jump if so
	cpi	254		;start dial?
	jnz	smchr		;go send to modem if not
	lda	mspeed		;get present baud rate
	cpi	lbaud		;see if below min. stepdown
	jc	dial2		;if so no autobaud
	lda	abdflg		;get autobaud rate flag
	ora	a		;set psw
	lda	mbaud		;get maximum baud rate
	cnz	newbdv		;set it if autobaud rate flag <> 0
dial2:	lda	tpulsv		;get overlay's touch-tone flag
	sta	tpmark		;put into string
	lda	spkflg		;check monitor speaker flag
	ora	a
	mvi	a,'3'
	jnz	spkon		;if on, use M3 mode
	mvi	a,'0'
spkon:	sta	msmark
;
if fast	and (usr24 or team)	;need to separate init command
	lxi	h,inimsg	;point to init command
	call	smstr		;send it
	call	flush		;flush modem response
	call	flush		;
endif	;fast and (usr24 or team)
;
	lxi	h,smdial	;point to dialing string
	jmp	smstr		;send it
;
; Here on an end-dial sequence
;
endial:	mvi	a,cr		;send end-of-line to the modem
	call	smchr
	call	flush		;flush any pending modem output
;
; The following loop waits for a result from the modem (up to 60
; seconds:  you may change this value in the following line).  Note
; that the Smartmodem has an internal 30 second timeout for a
; carrier on the other end.  You can change by playing with the S7
; variable (i.e. send the smartmodem "AT S7=20" to lower the 30
; second wait to 20 seconds).
;
	mvi	e,wait		;<<== maximum time to wait for result
smwlt:	mvi	d,0		;clear response checksum
smwlp:	lxi	b,1*256+tmdinp	;b=1 second, C=tmdinp func code
	call	mex
	jnc	smlog		;\jump if modem had a char
	mvi	c,kstat		;check for keypress
	call	mex
	ora	a
	jz	smnext		;\jump if no keypress
	mvi	e,dconin
	mvi	c,dconio	;get key hit, with no echo
	call	mex
	cpi	'C'-40h		;is ^C?
	jnz	nocc		;\jump if not
	mvi	a,3		;prep return code
	jmp	abcom		;\finish in common code
nocc:
;
	if	spabrt
	cpi	' '		;space bar?
	jnz	smnext		;\ignore all others
	endif
;
	mvi	a,2		;prep return code
abcom:	push	psw		;\save return code
	lxi	b,cr*256+sndchr	;b=cr, c=sndchr func code
	call	mex
	pop	psw		;\return abort code
	ret
smnext:	dcr	e		;no
	jnz	smwlp		;\continue
;
; wait (equ) seconds with no modem response (or no connection)
;
	mvi	a,2		;return timeout code
	ret
;
; modem gave us a result, check for end and save it
;
smlog:	ani	7fh		;ignore any parity
	cpi	' '		;see if end of message
	jc	smrslt		;\jump when control character
	add	d		;add to checksum
	mov	d,a		;save response checksum
	jmp	smwlp		;\continue
;
; result code completely presented
;
smrslt:	mov	a,d		;get result checksum
	ora	a		;see if accumulated yet
	jz	smwlp		;\continue if no result yet
	call	flush		;flush any pending modem output
	lxi	h,rctab-2	;get pointer to result table
smrlp:	inx	h		;\advance to next entry
	inx	h		;\
	mov	a,m		;get table entry
	inx	h		;\bump to response
	cpi	0ffh		;check for end of table
	jnz	smok		;\jump if not
	mvi	a,4		;else return error reported by modem
	ret
smok:	cmp	d		;check for match with checksum
	jnz	smrlp		;\loop if no match
	lda	abdflg		;got a match.  Get autobaud rate flag
	ora	a		;set z on flag
	jz	noauto		;\jump if not auto-baud mode
	mov	a,m		;get newbdv-code
	cpi	0FFH		;null?
	cnz	newbdv		;set it if not
noauto:	inx	h		;\bump over newbdv-code
	mov	a,m		;get MEX response code
	 if	not (usr24 or team)
	ret			;don't try to interpret extended codes
	 endif
;
	 if	usr24 or team
	cpi	8
	jz	ring		;\say phone is ringing
	cpi	7		;say we found a human
	rnz			;\r3\otherwise it's a normal mex code
	 endif
;
;
if usr24			;Courier can do voice
voice:	call	ilprt		;whoops, we have ourselves a human.
	db	'VOICE ',0	;print a warning
	mvi	a,3		;return with abort so doesn't repeat..
r3:	ret
endif
;
if (usr24 or team) and showrng	;Courier and SmarTEAM do ring detect
ring:	call	ilprt		;just print nice ring message,
	db	'RING ',0	;it's not an error, just phone ringing..
	jmp	smwlt		;go to main loop
endif
;
if (usr24 or team) and not showrng
ring:	jmp	smwlt		;\just clear the checksum and continue
endif
;
; The following table is used to interpret the calculated result code
; checksum which is reported by the modem (and excludes all control
; characters).	For numeric responses, the checksum is the same as
; the numeric response (in most cases).  For word responses, the
; checksum is as listed in the table.  The table format consists of
; triplets:  result-checksum, newbdv-code, MEX-response.  Note that
; with this scheme, "CONNECT 0600" and "CONNECT 2400" appear the
; same, further "RING" and "0" ("OK") appear the same.	These
; should not normally cause any difficulties however.
;
rctab:
if	wordres
	db	09ah,0ffh,4	;"OK" - error reported by modem
	db	00ah,1,0	;"CONNECT" - carrier detected
	db	030h,0ffh,4	;"RING" - error reported by modem
	db	0c5h,0ffh,2	;"NO CARRIER" - no answer
	db	08ah,0ffh,4	;"ERROR" - error reported by modem
	db	0edh,5,0	;"CONNECT 1200" - carrier detected
	db	00dh,0ffh,6	;"NO DIALTONE" - error reported by modem
	db	043h,0ffh,1	;"BUSY" - far end busy
	db	08dh,0ffh,2	;"NO ANSWER" - no answer
	db	0f0h,6,0	;"CONNECT 2400" - carrier detected
endif				;wordres
;
if wordres and usr24
	db	076h,0ffh,7	;"VOICE" - mex doesn't support...we do
endif
;
if wordres and (usr24 or team)
	db	00eh,0ffh,8	;"RINGING" - mex doesn't support..we do
endif
;
if numres
	db	'1',  1,0	;"CONNECT" - carrier detected
	db	'2',255,4	;"RING" - error reported by modem
	db	'3',255,2	;"NO CARRIER" - no answer
	db	'4',255,4	;"ERROR" - error reported by modem
	db	'5',  5,0	;"CONNECT 1200" - carrier detected
	db	'6',255,6	;"NO DIALTONE" - error reported by modem
	db	'7',255,1	;"BUSY" - far end busy
	db	'8',255,2	;"NO ANSWER" - no answer
	db	'9',  3,0	;"CONNECT 0600" - carrier detected
	db	'1'+'0',  6,0	;"CONNECT 2400" - carrier detected
endif
;
if numres and usr24
x	db	'1'+'2',255,7	;"VOICE" - say there is a voice
endif
;
if numres and (usr24 or	team)
	db	'1'+'1',255,8	;"RINGING" - remote modem ringing
endif				;numres
;
;
	db	0ffh		;end of table
;
; Following routine disconnects the modem using Smartmodem
; codes.  All registers are available for this function.
; Nothing returned to caller.
;
if disc
discon:	mvi	b,20
	mvi	c,timer		;wait 2 seconds
	call	mex
	lxi	h,smatn		;send '+++'
	call	smstr
	mvi	b,20		;wait 2 more seconds
	mvi	c,timer
	call	mex
	lxi	h,smdisc	;send 'ath'
	call	smstr
	mvi	b,1		;wait 1 second
	mvi	c,timer
	jmp	mex
;
smatn:	db	'+++',0		;Smartmodem attention string
smdisc:	db	'ATH',cr,0	;Smartmodem hang-up string
;
endif				;disc
;
; Smartmodem utility routine:  send string to modem
;
smstr:	mov	a,m		;fetch next character
	inx	h		;\
	ora	a		;end?
	rz			;\r1\done if so
	call	smchr		;otherwise send the character
	jmp	smstr		;\
;
; Smartmodem utility routine:  send character to modem
;
smchr:	push	psw		;save character
smrdy:	mvi	c,sndrdy	;wait for modem ready
	call	mex
	jnz	smrdy		;\
	pop	psw		;restore character
	mov	b,a		;position for sending
	mvi	c,sndchr	;send the character
	jmp	mex
;
; Smartmodem utility routine:  flush pending modem output
;
flush:	mvi	c,inmdm		;catch any output from the modem
	call	mex
;
if  crfl
	jc	r1		;jump if no input
	cpi	lf		;got some, waiting for <cr>
	jnz	flush		;eat characters until getting one
endif
;
if not crfl
	jnc	flush		;\loop until no more characters
endif
;
r1:	ret
;
; This routine performs the MEX inline print function.
;
ilprt:	mvi	c,ilp
	jmp	mex
;
;----------------------------------------------------------------
;
; Next is the SSET command processor.
;
sset:	mvi	c,sblank	;Any arguments?
	call	mex
	jc	telall		;\tell current status if not
	lxi	d,cmdtbl	;point command table
	mvi	c,lookup	;see if command found
	call	mex
	jc	seterr		;\complain if not
	pchl			;else go to service routine
;
seterr:	call	ilprt		;print error message
	db	'SSET: AFB ON/OFF - SPKR ON/OFF',cr,lf,0
	ret
;
; This is the SSET command table.
;
cmdtbl:	db	'AF','B'+80h	;Autobaud mode on/off
	dw	setbd
	db	'SPK','R'+80h	;monitor speaker on/off
	dw	setspk
	db	0		;Table terminator
;
; Set message on/off processor.
;
setspk:	lxi	h,spkblk	;pointer for spkr on/off
	jmp	boole		;set on/off or show
;
telall:
	call	setspk		;show speaker on/off
;
setbd:	lxi	h,abdblk	;load pointer
;
; Boolean SSET common code.
;
boole:	mov	e,m		;fetch address of boolean
	inx	h		;\
	mov	d,m
	inx	h		;\HL addresses text
	push	d		;save it
	push	h		;save that pointer
	mvi	c,sblank	;any arguments?
	call	mex
	jc	tell		;\jump if not
	mvi	c,onoff		;parse on/off from input stream
	call	mex
	pop	d		;recall msg pointer
	pop	h		;boolean's adrs
	jc	seterr		;\complain if not on or off
	push	h		;resave
	push	d
	mov	m,a		;update boolean
tell:	pop	d		;none, query only
	mvi	c,print		;print message
	call	mex
	pop	h		;boolean location
	mov	a,m
	ora	a		;is it off?
	jz	izoff		;\jump if so
	call	ilprt		;else print 'on'
	db	'N',cr,lf,0
	ret
izoff:	call	ilprt		;print 'off'
	db	'FF',cr,lf,0
	ret
;
abdblk:	dw	abdflg
	db	'AFB O$'
;
spkblk:	dw	spkflg
	db	'SPKR O$'
;
justrt:	ret
;
; The following statement insures that we don't exceed our boundary.
; It's IFed around 8080 (with ";|") because the brain-damaged 8086
; (Microsoft) assembler forces a type on all variables; since '$' is
; an address and 0CFFH is a constant, MASM will refuse to assemble the
; statement. Someone at Microsoft should be strung up by his fingernails
; and baked in the late afternoon sun for forcing such ridiculous con-
; straints on ASSEMBLY language programmers!; (I imagine there's some
; way around this stupidty, but I have neither the time nor the in-
; clination to go digging through the MASM documentation to find it).
;
endmxm:		;this method works with ASM since "$" & "GT" don't work
;
gap	equ	0CFFH-ENDMXM
oops	equ	(gap AND 8000H)	SHR 15
;
	 if	i8080 and oops				;|
	 lda	undef	;error: overlay area past 0D00H ;|
	 endif						;|
;
	org	mexloc		;"CALL MEX"
mex:
;
	org	smtabl		;table of smart modem vectors here
	dw	justrt		;Smartmodem init
	dw	sset		;SSET command
	dw	justrt		;Smartmodem exit
;
;
	end
