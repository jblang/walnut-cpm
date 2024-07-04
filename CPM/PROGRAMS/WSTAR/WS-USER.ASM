;
;******************************************************************************
;
	title	'WS-USER -- Patch for Wordstar Overlay Files'
;
;		(New, shorter version, (shrunk it so my other,
;		 printer status patch would fit with this one
;		 in the MORPAT area), added values for WS v3.3)
;
;					 -- Kim Levitt  11/13/84
;
;******************************************************************************
;
;	WS.COM can be made to work with ZCPR/ZCPR2/ZCPR3/etc.	 04/17/84
;
;  You know how irritating the @@@@'s get when you try to open a file in a 
; user area that does not have the *.OVR files present ?????  I had been 
; pipping everything to a given user area to edit and then back again. ARRGH.
; To make a long story short, a few hours with DDT revealed several key areas
; within WS.COM that should interest a true hacker. Seems as how the FCB for
; WSOVLY1.OVR is at 364Dh, WSMSGS.OVR is at 3784h, the only BDOS entry vector
; is at 1823h and finally, the area between 02E0h and 035Bh inclusive is a 
; safe patch area. Well, well well....... A real simple kludge of mushware will
; set a default drive and user area every time WS.COM looks for an *.OVR file
; and then set it back again after the DOS operation. The infernal thing can 
; find the *.OVR files from any drive and user area A dream come true and
; it is really painless......
;
;//////////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;
;		Copyright (c) 1984 .... Oak Brook Design 
;   
;	  		     All rights reserved.
;
;	Permission  is  hereby  granted  to copy and distribute this
;	program  for  any  non-commercial  purpose. Any use of this
;	material  for  commercial  advantage  without  prior written
;	consent of John P Sojak acting on behalf of Oak Brook Design 
;	is prohibited. 
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;//////////////////////////////////////////////////////////////////////////////
;
;	You MUST examine your Wordstar under SID or DCON to verify several
;	locations within the memory image.... > denotes a console input
;	(You can use ZSID or DDT also, of course... -- KL)
;
;>	A0>DCON
;
;	--- dcon banner and some other gook ---
;
;>	#F100 5000 00		; clear the ram out
;>	#IWS.COM		; set up for read
;>	#R	
;
;>	#P0000			; set a break at warmboot 
;>	#G100
;
; 	--- you will get the usual WS menu.... Just eXit with 'X'
;
;	01 PASS 0000
;	 -Z-E- A=00 B=1800 D=0006 H=3441 S=3443 P=0000	
;	 ----- A'=00 B'=00 D'0000 H'0000 X=0000 Y=0000 JMP XXXX
;	*XXXX
;
;>	#D3780 3790
;	3780: 00 00 00 00 03 57 53 47 53 20 20 4F 56 52 .....WSMSGS  OVR
;	3790: 00	   \	
;		             there it is... 
;				
;					          here it is..
;>	#D3640 3660				/   
;	3640: 00 00 00 00 00 00 00 00 00 00 00 00 57 53 ..............WS
;	3650: 4F 56 4C 59 31 20 4F 56 52 00 00 00 00 00 OVLY1 OVR.......
;	3660: 00 . 	
;
;
;>	#L1820
;	1820   	INX  	H
;	1821	PUSH 	D	
;	1822	PUSH	H
;	1823	CALL	0005	--- here is the DOS entry @ 1823h  
;	1826	POP	H
;	1827	POP	D
;	1829	XTHL
;	182A	RET
;
;>	#-P		; clear the pass point at warmboot
;>	#G0		; and exit to CCP
;
;	A0>
;
;	Now you can assemble the file, I used Mac. M80 / L80 has a problem with
;	extranious 00 between the two ORGs. Dont use it. 
;
;	Use the same procedure to load WS.COM into memory again but this time,
;	dont set any pass point at 0000. Set up for the read with IWSUSER.HEX
;	and then do a R to overlay the hex file. Exit to the CCP and then
;	
;	A0>SAVE 64 WS-TEST.COM
;	(Note: For 3.3 versions, use 69 usually, could be more if your
;	version has been customized with code in the secondary user
;	patch space PGBMEM.)
;
;	Thats it..... WS  will, or should now, work with all user areas and 
;	drives.
;
;****************************************************************************
;
;	NOTE: WS v3.3 values I found in CP/M-80 version:
;
;		FILE/ADDRESS	FCB ADDR
;		============    ========
;		WSMSGS.OVR	3769H
;		WSOVLY1.OVR	3630H
;		CALL BDOS	1835H
;		PATCH AREA	02CBH	(check for previous patches first)
;
;				-- Kim Levitt
;				   (MBBS HQ RCP/M (213) 653-6398)
;
;****************************************************************************
;
; (Always 0005, this is entry point for BDOS function calls)
;
bdos		equ	0005	;BDOS function caller
;
;==============================================================================
;
; The WSMSGS.OVR fcb address:
;
msgfcb		equ	3784h	;(use 3769h for v3.3)
;
;==============================================================================
;
; The WSOVLY1.OVR fcb address:
;
ovrfcb		equ	364Dh	;(use 3630h for v3.3)
;
;==============================================================================
;
; The original BDOS vector call address:
;
bdosvec		equ	1823h	;(use 1835 for v3.3)
;
;==============================================================================
;
; The user patch space where patch code gets loaded:
;
morpat		equ	02E0h	;(use 02CB for v3.3)
;
;	(This value is the MORPAT value obtained from WS.COM)
;
moroff		equ	0	;(normally zero if virgin WS.COM)
;
;	(This value may have to be adjusted if you have a custom patch
;	already in the MORPAT area. If you have the printer status
;	check routine as listed in WSPAT-33.DQC, for instance, and the
;	patch for that starts at MORPAT then this patch would have to
;	start at MORPAT+11h, so you'd have to set MOROFF equ 11h)
;
moron		equ	not moroff	;(dummy equate, used for user)
;
;==============================================================================
;
; Set these to your desired default drive and user for the *.OVR files
;
ovruser		equ	15	; User area...  0-31
ovrdrv		equ	01	; Drive Spec... A:-> 01, B:-> 02 etc
;
;******************************************************************************
;
;		the patch gets called here
;
;******************************************************************************
;
		org	bdosvec	; remove the existing DOS hook
;
;	intercept the call to DOS before actual entry ... 
;
		call	morpat+moroff
;
;******************************************************************************
;
;		the patch gets loaded here
;
;******************************************************************************
;
		org	morpat	; patch area is here
;
;	check BDOS function and FCB address
;
		push	b		; save function code (c)
		mov	a,c		; check it
		cpi	15		; open file?
		jz	chkit
		cpi	16		; close?
		jz	chkit
		cpi	17		; search first?
		jz	chkit
		cpi	18		; search next?
		jz	chkit
		cpi	20		; read next?
		jz	chkit
		cpi	33		; read random?
		jz	chkit
;
;	pass the call on without further hassle, its not for us
;
passit:		pop	b		; restore stack
		jmp	bdos		; and return
;
;******************************************************************************
;
;	check <de> for the two OVR fcb addresses, set <cy> if not found
;
;
chkit:		mvi	a,(LOW msgfcb)	;  fcb for WSMSGS.OVR 
		cmp	e
		jnz	nogood
		mvi	a,(HIGH msgfcb)
		cmp	d
		jz	good
;		
nogood:		mvi	a,(LOW ovrfcb)	;  fcb for WSOVLY1.OVR 
		cmp	e
		jnz	passit
		mvi	a,(HIGH ovrfcb)
		cmp	d
		jnz	passit
;
;	found one of the FCB's... set the user and drive 
;
good:		push	d		; save FCB
;
		xchg			; put FCB in HL
		mvi	a,ovrdrv	; find the overlays on this drive
		mov	m,a		; (stuff in FCB)
;
		mvi	c,32		; get the current user number
		mvi	e,0FFh
		call	bdos
		sta	user		; save it
;
		mvi	c,32		
		mvi	e,ovruser	; find the overlays in this user
		call	bdos
;
		pop	d		; original fcb addr
		pop	b		; original function code
;
		call	bdos		; finally we get there...
;
		push	b		; save bc
		push	psw		; save the result flags for later
;
		mvi	c,32		; set the old user... maybe funnies
		lda	user
		mov	e,a
		call	bdos
;
		pop	psw		; get error flags
		pop	b		; restore c
;
		ret			; back to Wordstar
;
user:		db	(HIGH moron)	; (non-zero to mark end)
;
		end
;
