; MXO-MD30.ASM - Morrow Designs Micro Decision 3 (MD3) Overlay File 
; version 3.0 for MEX 1.14
; 1/17/87 by Carson Wilson. This file is for MD3's with Rev. 2 boards only. 
;
; You may edit this file to change various initial variables. Assemble
; with ASM or MAC, then use MLOAD to patch the changes into MEX:
;
;	ASM mxo-md30.aaz			;assemble the edited file
;	MLOAD newmex.com=mex114.obj,mxo-md30	;patch mex
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Morrow Micro Decision computer to the MEX pro-
; gram. While this computer has two serial ports, one is used for the
; CRT/keyboard and the other for the printer. Connect the modem in place of 
; the printer.
;
; The "SET" command may now be used to change the baudrate, parity, data 
; bits, and stopbits. For help, type "SET ?" from the MEX prompt. For current
; settings, type "SET". 
; Defaults are 1200 baud, 8 data bits, no parity, 1 stopbit.
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 01/17/87 - Completely revamped file, made it MD3 specific. Removed extra
;	     code, added ability to set stop bits, parity, and data bits,
;            changed the default baud rate to 1200 bps, changed some options,
;	     added latest options to end of file, altered the initializing
;	     routine to run with the MD3, changed clear screen and clear to 
;	     end of screen to work with MT-70 terminal. Renamed file to 
;	     MXO-MD30.ASM for M(icro) D(ecision) version 3.0 - Carson Wilson
;
; 05/15/84 - converted from mdm7xx to mex10     - sandy berger
; 03/25/84 - revised for use with mdm730        - sandy berger
; 11/11/83 - renamed to m7md-1.asm, no changes	- irv hoff
; 07/21/83 - renamed for use with mdm712	- irv hoff
; 07/01/83 - revised for use with mdm711	- irv hoff
; 06/22/83 - revised for use with mdm710	- irv hoff
; 06/22/83 - altered mdm708dp for morrow
;	     micro decision computers using
;	     an external modem			- irv hoff
; 05/28/84 - altered for model md-3a            - alan bierbaum
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Following line must be BIOS address of CONOUT.
;
conout	equ	0e4cbh	; This value now set for a 60k ZCPR3 installation 
			; for the MD3. If you use the standard Morrow 64k 
			; CP/M operating system with BIOS rev 3.1, you 
			; should change it to 0f4cbh.
;
bell	equ	07h	; bell
cr	equ	0dh	; carriage return
esc	equ	1bh	; escape
lf	equ	0ah	; linefeed
tab	equ	9	; tab
;
yes	equ	0ffh
no	equ	0
;
;------- MD3-Specific Port Addresses ------
;
s2data	equ	0feh	; Morrow MD3 serial printer/modem port
s2stat	equ	0ffh	; modem status port
modrcvb	equ	02h	; modem receive bit
modsndb	equ	01h	; modem send bit
ctcsel	equ	0f3h	; channel select port for CTC
ch2div	equ	0f2h	; port for setting baud rate of 2nd serial port
;
;------- MEX Built-in Routines --------
;
inmdm	equ	255	; get char from port to a, cy=no more in 100 ms
timer	equ	254	; delay 100ms * reg b
tmdinp	equ	253	; b=# secs to wait for char, cy=no char
chekcc	equ	252	; check for ^C from kbd, z=present
sndrdy	equ	251	; test for modem-send ready
rcvrdy	equ	250	; test for modem-receive ready
sndchr	equ	249	; send a character to the modem (after sndrdy)
rcvchr	equ	248	; recv a char from modem (after rcvrdy)
lookup	equ	247	; set cmd table search: see cmdtbl comments
parsfn	equ	246	; parse filename from input stream
bdpars	equ	245	; parse baud-rate from input stream
sblank	equ	244	; scan input stream to next non-blank
evala	equ	243	; evaluate numeric from input stream
lkahed	equ	242	; get nxt char w/o removing from input
gnc	equ	241	; get char from input, cy=1 if none
ilp	equ	240	; inline print
decout	equ	239	; decimal output
prbaud	equ	238	; print baud rate
prntbl	equ	237	; print table
prid	equ	236	; print [MEX] id
onoff	equ	235	; parse on/off fm input strm a=0 or 1 (c=err)
print	equ	9	; simulated bdos function 9: print string
inbuf	equ	10	; input buffer, same structure as bdos 10
kstat	equ	11	; get keyboard status
kbdin	equ	01	; keyboard input
dconio	equ	6	; bdos direct console i/o function #
dconin	equ	0ffh	; bdos dconio flag for input
;
;------------------------------------------------------------
;	Actual start of MEX
;
		org	100h
;
		ds	3	;(for  "jmp   start" instruction)
;
pmmimodem:	db	no	;yes=pmmi s-100 modem			103h
smartmodem:	db	no	;yes=hayes smartmodem, no=non-pmmi	104h
touchpulse:	db	'T'	;T=touch, P=pulse (smartmodem-only)	105h
clock:		db	40	;clock speed in mhz x10, 25.5 mhz max.	106h
				;20=2 mhh, 37=3.68 mhz, 40=4 mhz, etc.
mspeed:		db	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107h
				;6=2400 7=4800 8=9600 9=19200 default
bytdly:		db	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108h
				;default time to send character in ter-
				;minal mode file transfer for slow bbs.
crdly:		db	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109h
				;default time for extra wait after crlf
				;in terminal mode file transfer
noofcol:	db	5	;number of dir columns shown		10ah
setuptst:	db	yes	;yes=user-added setup routine		10bh
scrntest:	db	yes	;cursor control routine 		10ch
retry:		db	yes	;yes=ask user to reset error count	10dh
				;after 10 consecutive errors
				;no=abort after 10 consecutive errors
bakupbyte:	db	no	;yes=change any file same name to .bak	10eh
crcdflt:	db	yes	;yes=default to crc checking		10fh
togglecrc:	db	yes	;yes=allow toggling of crc to checksum	110h
convrub:	db	no	;yes=convert backspace to rub 		111h
togglerub:	db	yes	;yes=allow toggling of bksp to rub	112h
addlf:		db	no	;no=no lf after cr to send file in	113h
				;terminal mode (added by remote echo)
togglelf:	db	yes	;yes=allow toggling of lf after cr	114h
tranlogon:	db	no	;yes=allow transmission of logon	115h
				;write logon sequence at location logon
savccp:		db	yes	;yes=do not overwrite ccp		116h
loconextchr:	db	yes	;yes=local command if extchr precedes	117h
				;no=external command if extchr precedes
toggleloc:	db	yes	;yes=allow toggling of loconextchr	118h
lsttst:		db	yes	;no=using modem on printer port		119h

; NOTE - if either of the next two are "yes", then MEX will NOT
; ask for delays when sending a file in terminal mode.
xofftst:	db	no	;yes=checks for xoff from remote while	11ah
				;sending a file in terminal mode
xonwait:	db	no	;yes=wait for xon after cr while	11bh
				;sending a file in terminal mode
;
togxoff:	db	yes	;yes=allow toggling of xoff checking	11ch
ignorctl:	db	no	;yes=ctl-chars above ^m not displayed	11dh
extra1:		db	0	;for future expansion			11eh
extra2:		db	0	;for future expansion			11fh
brkchr:		db	'\'-40h	;^\ = send 50 ms. break tone		120h
noconnct:	db	'N'-40h	;^N = disconnect from phone line	121h
logchr:		db	'L'-40h	;^L = send logon			122h
lstchr:		db	'P'-40h	;^P = toggle printer			123h
unsave:		db	'R'-40h	;^R = close input text buffer		124h
tranchr:	db	'T'-40h ;^T = transmit file to remote		125h
savechr:	db	'Y'-40h	;^Y = open input text buffer		126h
extchr:		db	']'-40h	;^] = send next character		127h
;
		ds	2		;				128h
;
in$s2stat:	in	s2stat ! ret	;in modem control port		12ah
		ds	7
out$s2data:	out	s2data ! ret	;out modem data port		134h
		ds	7
in$s2data:	in	s2data ! ret	;in modem data port		13eh
		ds	7
ani$modrcvb:	ani	modrcvb ! ret	;bit to test for receive ready
cpi$modrcvb:	cpi	modrcvb ! ret	;value of receive bit when ready
ani$modsndb:	ani	modsndb ! ret	;bit to test for send ready
cpi$modsndb:	cpi	modsndb ! ret	;value of send bit when ready
		ds	12
;
logonptr:	dw	logon		;for user message.		160h
		ds	3		;				162h
jmp$disconnt:	jmp	goodbye		;				165h
jmp$goodbye:	ret ! nop ! nop		;				168h
jmp$initmod:	jmp	initmod		;go to user written routine	16bh
jmp$newbaud:	jmp	newbaud		;sets baud rate associated with#16eh
		ret  !	nop  !	nop	;(by-passes pmmi routine)	171h
		ret  !	nop  !	nop	;(by-passes pmmi routine)	174h
jmp$setpro:	jmp	setpro		;process SET commands		177h
jmp$spclmenu:	jmp	spclmenu	;				17ah
jmp$sysver:	jmp	sysver		;				17dh
jmp$break:	jmp	sendbrk		;				180h
;
; do not change the following six lines.
;
jmp$ilprt:	ds	3		;				183h
jmp$inbuf	ds	3		;				186h
jmp$inlncomp:	ds	3		;				189h
jmp$inmodem	ds	3		;				18ch
jmp$nxtscrn:	ds	3		;				18fh
jmp$timer:	ds	3		;				192h
;
; Clear sequences -- clreos is clear to end of screen, clrscrn is clear
; entire screen. Last entry must be 0.  Any other 0's act as nop's.
; The scrntst option must be set "yes" for these to work.  These are now
; set for the Morrow MT-70 terminal.
;
clreos:	mvi	c,ilp		; clear to end of screen routine 
	call	mex
	db	esc,'Y',0	; fill out to required 9 bytes
	ret
;
clrscrn:mvi	c,ilp		; clear whole screen routine
	call	mex
	db	1ah,0,0		; fill out to required 9 bytes	
	ret
;
;------------------------------------------------------------
; End of fixed area.  Above here, be very careful of changing
; the length of things.  Below here, total length just needs
; to be under 0B00, to leave room for external modem overlay.
;------------------------------------------------------------
logon:	db	'logon goes here',cr,0
;
milp:	mvi	c,ilp		; mex inline print string
	jmp	mex
;
crlf:	call	milp		; print return and linefeed
	db	cr,lf,0
	ret
;
sysver:	call	milp
	db	'*** Morrow Designs MD3 Version 3.0 ***',cr,lf,0
	ret
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
sendbrk:mvi	a,1fh		;send break tone
	jmp	goodbye1
;
; This routine sends a 300 ms. break tone and sets dtr low for the same
; length of time to disconnect some modems such as the Bell 212a, etc.
;
goodbye:
	mvi	a,15h		;send break, turn off DTR
;
goodbye1:
	out	s2stat		;send to status port
	mvi	b,3		;wait 300 ms.
	mvi	c,timer
	call	mex
	mvi	a,27h		;normal send/receive with dtr
	out	s2stat		;send to status port
	ret
;
initmod:mvi	a,087h		;ensure out of mode
	out	s2stat		;modem status port
	out	s2stat		;slight extra delay
	mvi	a,40h		; initialize usart for mode word
	out	s2stat		; modem status port
	lda	modereg		; load current defaults
	out	s2stat		; allows cloning with different
				; data bits, stop bits, & parity
	lda	cmdreg		; use command word to reset 
				; xmt, dtr, rcv, and rts 
	out	s2stat		;modem status port
	in	s2data		;clear data port
	call	loadbd		; set baud rate - allows cloning
	ret
;
;============== SETPRO - Process SET Commands ========================
;
; 	Main SET Command Table
;
cmdtbl:	db	'BAU','D'+80h
	dw	setbaud
	db	'PARIT','Y'+80h
	dw	setpar
	db	'LENGT','H'+80h
	dw	setlen
	db	'STOPBIT','S'+80h
	dw	setstp
	db	'?'+80h			; SET help
	dw	sethelp
	db	0
;
setpro:	mvi	c,sblank	;any arguments?
	call	mex
	jc	tell		;if not, go display current settings
	lxi	d,cmdtbl
	mvi	c,lookup
	call	mex		;parse argument
	push	h		;save any parsed argument adrs on stack
	rnc			;if we have one, return to it
	pop	h		; command not found in table
				; so fall thru to print error msg.
;
seterr:	lda	errid		; print MEX id with error msgs?
	ora	a
	jz	noid		; no
	mvi	c,prid		; print mex id
	call	mex
noid:	call	milp
	db	bell,'++ SET error'	; ring bell, if on
	db	' ++',cr,lf,0
	ret
;
tell:	call	shbaud		; display current settings
	call	shprty
	call	shbits
	call	shstop
	ret 
;
; "SET ?" processor
;
sethelp:
	call	milp
	db	'BAUD <n>',tab,'300 or 1200',cr,lf
	db	'LENGTH <n>',tab,'7 or 8',cr,lf
	db	'PARITY <mode>',tab,'NONE, EVEN or ODD',cr,lf
	db	'STOPBITS <n>',tab,'1 or 2',cr,lf,0
	ret
;
; ---------- modem registers -------------- 
; These registers are used to set the 8251 UART for the Morrow's 
; second serial port. For an excellent explanation of this process, 
; see Ed Berne's article "How to Modify Output Ports," in Morrow
; Owners' Review vol. 1, #4, October 1984, pp. 44-5.
;
modereg:db	01101110b	; Contains the default "mode word" for 
				; output to the 8251 UART. 
				; 01101110b = no parity, 8 databits,
				; 1 stopbit. This register changes with 
				; calls to SET routines.

cmdreg:	db	00100111b	; Contains the "command word" for output
				; to 8251 UART. 
;
; MODEOFF and MODEON are used to set parity, stopbits, and databits 
; by turning off or on the bits specified in register b. The most recent
; combination is temporarily stored in modereg.  

; MODEON - turn on bit(s) on modem mode register.
; On entry, reg. b has ones in positions to turn on
 
modeon:	push	psw
	mvi	a,40h	; tell 8251 that the next byte will be a 
	out	s2stat	; "mode word"
	lda	modereg	; get the mode register
	ora	b	; add the bits which are on in b to a
	sta	modereg	; save the result back in modereg
	out	s2stat	; send modereg to UART
	lda	cmdreg
	out	s2stat	; reset the UART
	pop	psw
	ret
; 
; MODEOFF - turn off bit(s) on modem mode register.
; On entry, reg. b has ones in positions to turn off.
;
modeoff:push	psw
	mvi	a,40h	; tell 8251 that the next byte will be a 
	out	s2stat	; "mode word"
	mov	a,b	; get bits to turn off in a
	cma		; reverse off to on, on to off
	mov	b,a	; and store the result back in b
	lda	modereg	; get the "mode register"
	ana	b	; turn off all bits in a which are off in b
	sta	modereg	; save the result back in modereg
	out	s2stat	; send modereg to UART
	lda	cmdreg
	out	s2stat	; reset the UART
	pop	psw
	ret
;
;------------ Set Baud Rate -------------
;
;	Set Baud Command Table
;
baudtbl:db	'30','0'+80h
	dw	set300
	db	'120','0'+80h
	dw	set1200
	db	0
;
setbaud:mvi	c,sblank	;any arguments?
	call	mex	
	jc	shbaud		;if not, go display baud
	lxi	d,baudtbl
	mvi	c,lookup
	call	mex		;parse argument
	push	h		;save any parsed argument adrs on stack
	rnc			;if we have one, return to it
	pop	h		;input not found in table
	jmp	seterr
;
set300:	mvi	a,1		;mspeed 300 baud value
	jmp	savebd
;
set1200:mvi	a,5		; mspeed 1200 baud value
;	
savebd:	sta	mspeed		; change time-to-send to match baudrate
	call	loadbd		; and load and show baud separately so that
	jmp	shbaud		; baud rate won't show at startup
;
loadbd:	mvi	a,0beh		;select ctc channel 2
	out	ctcsel
	lxi	d,417		;load divisor for 300 baud
	lda	mspeed		;flag: 1=300, 5=1200 baud
	dcr	a		
	jz	loadit		;if it was 1, set 300
	lxi	d,104		;else load divisor for 1200 baud
loadit:	mov	a,e
	out	ch2div		;set baud rate using rate port
	mov	a,d
	out	ch2div
	ora	a
	ret
;
shbaud:	call	milp		; display current baud rate
	db	'BAUD RATE',tab,0
	lda	mspeed
	mvi	c,prbaud
	call	mex
	call	crlf
	ret
;
newbaud:cpi	1
	jz	set300
	cpi	5
	jz	set1200
	ret
;
;-------- Set Parity --------------
;
;	Set Parity Command Table
;
partbl:	db	'NON','E'+80h
	dw	soff
	db	'EVE','N'+80h
	dw	seven
	db	'OD','D'+80h
	dw	sodd
	db	0		; <<== end of parity table
;
setpar:	mvi	c,sblank	; set parity - any arguments?
	call	mex
	jc	shprty		;if not, go display parity
	lxi	d,partbl
	mvi	c,lookup
	call	mex		; parse argument
	push	h		; save any parsed argument adrs on stack
	rnc			; if we have one, return to it
	pop	h		; input not found in table
	jmp	seterr
;
soff:	mvi	b,10h		;set parity to off
	call	modeoff
	jmp	shprty
sodd:	mvi	b,10h		;set parity to odd 
	call	modeon
	mvi	b,20h
	call	modeoff
	jmp	shprty
seven:	mvi	b,10h		;set parity to even
	call	modeon
	mvi	b,20h
	call	modeon	
				; and fall thru to shprty
;
; Show Parity Selected.
;
shprty:	call	milp		; display parity
	db	'PARITY',tab,tab,0
	lda	modereg
	ani	030h		; extract bits 4,5
	cpi	010h		; if bits 4,5 = 1,0 then parity odd
	jnz	shprt1
	call	milp
	db	'ODD',cr,lf,0
	ret
;
shprt1: cpi	30h		; if bits 4,5 = 1,1 then parity even
	jnz	shprt2		; else parity off
	call	milp
	db	'EVEN',cr,lf,0
	ret
;
shprt2:	call	milp
	db	'NONE',cr,lf,0
	ret
;
;--------- Set Length ---------------
;
;	Set Length Command Table
;
lentbl:	db	'7'+80h		; "set length 7"
	dw	set7
	db	'8'+80h		; "set length 8"
	dw	set8
	db	0		; <<== end of data-bits table
;
setlen:	mvi	c,sblank	;any arguments?
	call	mex
	jc	shbits		;if not, go display databits
	lxi	d,lentbl
	mvi	c,lookup
	call	mex		;parse argument
	push	h		;save any parsed argument adrs on stack
	rnc			;if we have one, return to it
	pop	h		;input not found in table
	jmp	seterr
;
set7:  	mvi	b,04h		;set to 7 
	call	modeoff
	jmp	shbits
set8:	mvi	b,04h		;set to 8
	call	modeon
;				and fall through to shbits
;
; Show Current Bits per Character
;
shbits:	call	milp
	db	'LENGTH',tab,tab,0
	lda	modereg
	ani	0ch		; extract bits 2, 3 for examination
	ora	a		; if bits 2,3 = 0,0 then 5 bpc
	jnz	shbts1		; nope, go try others.
	call	milp
	db	'5',0
	jmp	shbtsx
;
shbts1:	cpi	04h		; test bits 2, 3 = 1, 0
	jnz	shbts2		; if not, go try others.
	call	milp		; if so, 6 bits.
	db	'6',0
	jmp	shbtsx
;
shbts2:	cpi	08h		; test bits 2, 3 = 0, 1
	jnz	shbts3		; if not, must be 8 bits
	call	milp		; yup, 7 bits
	db	'7',0
	jmp	shbtsx
;
shbts3:	call	milp		; 8 bits per char
	db	'8',0
;
shbtsx:	call	milp
	db	' bits',cr,lf,0
	ret
;
;------- Set Stop Bits ----------------
;	
;	Set Stop Bits Command Table
;
stptbl:	db	'1'+80h		; "set stopbits 1"
	dw	stop01
	db	'2'+80h		; "set stopbits 2"
	dw	stop02
	db	0		; <<== end of stop-bits table
;
setstp:	mvi	c,sblank	; set stopbits - any arguments?
	call	mex
	jc	shstop		; if not, go display stopbits
	lxi	d,stptbl
	mvi	c,lookup
	call	mex		; parse argument
	push	h		; save any parsed argument adrs on stack
	rnc			; if we have one, return to it
	pop	h		; input not found in table
	jmp	seterr
; 
stop01:	mvi	b,80h		; set to 1
	call	modeoff
	jmp	shstop
;
stop02:	mvi	b,80h		; set to 2
	call	modeon
;
; Show Current Stop Bits
;
shstop:	call	milp		; display stop-bits
	db	'STOPBITS',tab,0
	lda	modereg
	ani	0c0h		; extract bits 6, 7 for examination
	cpi	040h		; if 6 on, 7 off, one stop
	jnz	shst15		; no, go check for 1.5 or 2
	call	milp
	db	'1',0
	jmp	shstxt
shst15:	cpi	080h		; if 7 on, 6 off, 1.5 stops
	jnz	shst20		; nope, go do 2.
	call	milp
	db	'1.5',0
	jmp	shstxt
shst20:	call	milp		; must be 2 stop bits
	db	'2',0
shstxt:	call	crlf
	ret
;
;	     (end of initmod and setup routines)
;=======================================================================
;
; These routines can be used for your equipment, be sure to end with ret
;
spclmenu: ret
;
; Special mex code for Morrow BIOS to not trap certain escape sequences.
; The address of the following line must be substituted at location
; outvec for certain terminals to work properly with
; certain hosts. If you replace the address then all control
; codes sent to the terminal will have their high order bit set so that
; the Morrow will send them through properly and not trap them.
;
slbtyp:	mov	a,c
	cpi	20h
	jp	slbt2		; in Z80 opcode, that's
				; "jp	p,stbt2" (jump if sign flag set) 
	ori	80h
slbt2:	mov	c,a
	jmp	conout		; value from top of this file
;
; Special initial prompt for the Morrow MT-70 terminal 
; (may be changed with the ID command)
;
myprom:	db	28		; Max. size of buffer
	db 	10		; Length of actual prompt
	db 	1BH,'G4MEX:'	; Prompt string displays
	db	1BH,'G0'	; in reverse video with Morrow MT-70
				; terminal.
;
;=======================================================================
;
; NOTE:  Must terminate prior to 0b00h (with smartmodem)
;				 0d00h (without smartmodem).
;
; The order of the patch variables supported here will not change from
; version to version (i.e., new items will be added on to the end).
;
	org	0d00h		;location of patch variables
;
lf	equ	10		;define ASCII linefeed code
;
;
; The following line defines the mex service call entry point, and
; is not meant to be changed by the user
;
mex:	ds	3		;mex service call processor
	ds	3		;reserved
	ds	1		;reserved
;
; The following line contains the initial free-memory pointer for
; mex.  Sophisticated modem overlays requiring additional space may change
; this pointer (ie, move it higher), and thus "protect" an area of ram.
;
memry:	ds	2		;first free memory pointer
;
; Following are the lowest-level vectors for console and list i/o used
; by mex.  These normally point to routines that save the registers and
; vector to the appropriate bios routines.  Complex applications may
; need to intercept (or even replace) these routines.  If you do this,
; be sure to preserve de, hl and bc.
;
stsvec:	ds	2		;console status vector
invec:	ds	2		;console input vector
outvec:	dw	slbtyp		;console output vector
lvec:	ds	2		;list output vector
lstvec:	ds	2		;list status vector
;
; The following line defines the location of the default mex prompt.
; If you'd like to provide your own initial prompt, add a dw statement
; pointing to a prompt buffer structured as follows:
;
;		db <max size of buffer>
;		db <length of actual prompt>
;		db <prompt string>
;
; <maxsize> and <length> may be equal (especially if you disable the
; id command by setting chgpmt, below to 0); the id command will, if
; left enabled, be limited to the <max size> value.
;
prompt:	dw	myprom		;prompt location
	ds	1		;reserved
typlin:	db	22		;for type command: # lines/screen
pausfl:	db	1		;for type cmd: 1=pause 0=no pause
sepchr:	db	','		;multiple command-line separator
				;changed from ';', which conflicts with
				;ZCPR's MCL separator 
;
; Following five for SENDOUT command
;
sowait:	db	4		;# seconds waiting for a sendout echo
sorepl:	db	8		;# seconds waiting for initial reply
sotrig:	db	'@'-64		;sendout trigger char from remote
canchr:	db	'X'-64		;sendout char to cancel line to remote
sortry:	db	2		;sendout # retries
;
hexflg:	db	0		;hex/decimal mode
escchr:	db	'T'-64		;terminal mode escape char 		d1fh
nobell:	db	0		;set to 0ffh to disable bell, 0 = bell	d20h
;
; Buffer variables.  see buffers.doc for setup information
;
psize:	db	2		;default=2k				d21h
asize:	db	255		;"big" capture buffer			d22h
xsize:	db	16		;16k transfer buffer. 			d23h
nsize:	db	1		;1k for 85 batch files			d24h
prelen:	db	40		;maximum length of prefix string	d25h
suflen:	db	40		;maximum length of suffix string
;
; Misc. stuff
;
cdosfl:	db	0		;non-zero for cdos
wtecho:	db	1		;non-zero sets "wait-for-echo"
kysize:	dw	400		;size of keystring area, in bytes
cisflg:	db	1		;non-zero allows cis file transfers
cisok:	db	1		;non zero allows stat cis on or off
chgpmt:	db	1		;non-zero allows id (prompt chg) command
errid:	db	1		;non-zero prints id msg in err msgs
;
; By setting the following db to 0, you can disable the help
; command, freeing up space used by the help file index.
;
helpok:	db	1		;non-zero allows help command
mexdu:	db	0		;user \/  alternate area for read,load,ini.mex
	db	0		;drive/\  & help.mex (if search <>0)
debug:	db	0		;debugging in term-mode if non-zero
exclsy:	db	1		;non-0 excludes $sys from batchsend, dir
inimex:	db	0		;non-zero runs ini.mex (if present) at startup
rtimer:	db	1		;receiver wait: # seconds [plouff patch]
pqsize:	dw	150		;size of the modem-port queue
phsize:	db	30		;phone library size (# entries)
silent:	db	0		;0=silence multi-line & read cmd echo
alert:	db	255		;alert-bell count on call complete
extend:	db	1		;non-zero: unknown commands goto read processor
split:	db	1		;non-zero: splits phonelib printout, shows baud
search:	db	0		;search mode 0,1,2,3
;
; Following is the global secondary options table.  To
; set an option to global, change its ascii character to a 0.
;
restt:	db	'ABDELQRSTVX'
	ds	8		;room for option expansion
;
; added on release 1.10:
;
queue:	db	1		;1=allow queueing, 0=no
timbas:	dw	208		;timing constant 
mode:	db	0		;mode of modem i/o
sminit:	ds	2		;smartmodem init routine adrs
ssetv:	ds	2		;sset command: defaulted off
smexit:	ds	2		;smartmodem exit routine adrs
	ds	4		;internal to mex
sodflg:	db	0		;1=tie sendout to time delay if no wtecho
autosv:	db	1		;0=initial term mode, save off
tabflg:	db	0ffh		;non-zero=expand tabs within mex
;
;
	end
lay if no wtecho
autosv:	db	1		;0=initial term mode, save off
tabflg:	db	0