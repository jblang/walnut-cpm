;MXO-II13.ASM-- InterSysytems VIO and H-Z19/29/49 file for MEX.  06/02/85
;
; This is a MEX overlay used to configure MEX for a specific hardware set-up.
; This file places particular emphasis on using the InterSystems VIO with
; the 2651 PCI and the H-Z19.  Much of the information contained here is
; not in the main file.  If you're not using the above named equipment,
; some of the routines here may give you some hints for your MEX patch.
;
; Use the "SET" command to change baud rate when desired.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler. Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 06/02/85 - Added J-Cat dial/hangup routines   - Len Moskowitz
; 06/08/84 - Changed to MEX labels MXO-II12.ASM - Len Moskowitz
; 06/04/84 - Changed to VIO/Z19 - MXO-II11.ASM  - Len Moskowitz
; 05/23/84 - Corrected clear-screen error	- Biff Bueffel
; 05/19/84 - Converted for MEX10 - MXO-H811.ASM	- Biff Bueffel
; 11/11/83 - Renamed to M7H8-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Revised to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/17/83 - Revised to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
; 02/17/83 - Updated to work with MDM704	- Irv Hoff
; 02/07/83 - Updated to work with MDM703	- Irv Hoff
; 01/27/83 - Updated to work with MDM702	- Irv Hoff
; 01/10/83 - Updated to work with MDM701	- Irv Hoff
; 10/03/82 - First version of this file
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
; VIO base address and port offsets. Set PORT to either PORTA or PORTB
;
VIOBASE		EQU	0		;set this to the base address of
					; your VIO board
PORTA		EQU	0		;serial port A is at base+0
PORTB		EQU	4		;serial port B is at base+4
PORT		EQU	VIOBASE+PORTB	;We use serial port B for the modem	
;
;
MODDAT:		EQU	PORT		;data port for VIO
MODCT1:		EQU	PORT+1		;status port for VIO
MDRCVB:		EQU	02		;bit to test for received data
MDRCVR:		EQU	02		;modem receive ready
MDSNDB:		EQU	01		;bit to test for ready to send
MDSNDR:		EQU	01		;modem send ready bit
;
; MEX service processor stuff.  Use instead of BDOS calls.  More detail
; in PM overlay.
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
PRINT	EQU	9		;BDOS print-string function

;
; modem control equates
;

offonhookport	equ	08h	;I/O port used to command OHK signal
onhook  	equ	0feh	;mask used reset OHK to 0. All bits set to 1
				; except the bit that controls OHK
offhook 	equ	01h	;mask used to set OHK to 1
milliconstant	equ	165	;delay constant for millisecond delay loop.
				; correct for 4 megaHertz Z80A.  halve it
				; for 2 megaHertz cpu or adjust per your
				; cpu requirements.  a good way to check how
				; accurate it is, is to set the three second 
				; delay, after the phone is taken off hook, 
				; to 60 seconds and time it carefully, and then
				; adjust this constant.
cardetectport	equ	05h	;I/O port used to read CAR signal
carriermask	equ	80h	;mask used to check carrier detect bit. if this
				; bit is a zero, the carrier was detected.
length		equ	25	;the maximum number of digits allowed in a 
				; phone number plus a null
portdefault	equ	00h	;you might use a port that controls other
				; things too. since we don't want to disturb
				; them, store the default setting for the port,
				; with OHK set to zero, here
dialtonewait	equ	3	;number of seconds we wait for a dial tone
carrierwait	equ	15	;number of seconds we wait for a carrier

;	This section has logicals.

true		equ	0ffh		;true
false		equ	0		;false


;
		ORG	100H
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMODEM:		DB	NO	;not used by MEX			103H
SMODEM:		DB	NO	;not used by MEX			104H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal modNe file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFL:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DB	YES	;spare
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
				;no=default to Checksum checking
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES;	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCNXT:		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGLOC:		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	NO	;yes=printer available on printer port	119H
XOFTST:		DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
PRATE:		DS	2	;PMMI equates (see PMMI overlay)	128H
;
INCTL1:		IN	MODCT1 		;in modem control port		12AH
		RET
		DS	7		;spares
OTDATA:		OUT	MODDAT 		;out modem data port		134H
		RET
		DS	7
INPORT:		IN	MODDAT		;in modem data port		13EH
		RET
		DS	7
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	12		;unused				154H
;
;
		DS	2		;Not used by MEX		160H
DIALV		JMP	DIAL		;Dials digit 			162H
DISCV		JMP	HANGUP		;Disconnects modem 		165H
GOODBV:		JMP	GOODBYE		;called before exit to CP/M	168H
INMODV:		JMP	INITMOD		;go to user written routine	16BH
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
NOPARV:		DS	3		;set modem for no-parity	171H
PARITV:		DS	3		;set modem parity		174H
SETUPV:		JMP	SETCMD		;overlay implemented function	177H
SPMENV:		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;overlay's voice in sign-on	17DH
BREAKV:		DS	3		;send break (not implemented)	180H
;
;
; These six lines are an artifact of MDMXXX.  They are not used with MEX.
;
ILPRTV:		DS	3	;replace with MEX function 9		183H
INBUFV:		DS	3	;replace with MEX function 10		186H
ILCMPV:		DS	3	;replace with table lookup funct. 247	189H
INMDMV:		DS	3	;replace with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX 			18FH
TIMERV:		DS	3	;replace with MEX function 254		192H
;
;
; The following clears the screen for the H19/29/49 terminal.
; Each of the two routines must be exactly 9 bytes long.
;
CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
;  End of the fixed format area.
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for InterSystems VIO and Z19/29/49'
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0B00H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0D00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; This routine can be used to make any necessary changes before exiting
; back to CP/M.  If you share a VIO port between a printer and a modem,
; you can use this routine to change the baud rate and other port 
; characteristics back to what the printer requires.
;
GOODBYE:  RET
;.....
;
;
; The following is used to initialize the VIO 2651 Modem I/O port
;
INITMOD:  call  clrscrn		;added 6/2/85
	  MVI	A,1		;default transfer speed to 300 baud
	  STA	MSPEED
	  MVI	A,04EH		;Mode Register 1 word - 
				; 1 stop bit, no parity, 8 bits, Async * 16
	  OUT	PORT+2		;2651 mode port address
MODREG2:  MVI	A,35H		;Mode Register 2 word -
				; internal clocks, 300 Baud
	  OUT	PORT+2		;2651 mode port address
	  MVI	A,27H		;Command Register word - 
				; normal operation, RTS* forced low, reset
				; error normal, force break normal, receive
				; control enabled, DTR* forced low, transmit
				; control enabled
	  OUT	PORT+3		;2651 command port address
	  RET
;.....
;
;
; The following routine changes the baud rate for the VIO with the SET
; command.
;
;
SETCMD:	  MVI	C,SBLANK	;Any arguments?
	  CALL	MEX
	  JC	TELL		;If not, go display baud
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;Tell user input not valid
	  DB	CR,LF,'Only 300 or 1200 allowed on SET command',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	0
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LXI	H,BD300		;get pointer to 300 baud parameter in HL
	  JMP	LOADBD		;go load them
;
OK1200:	  MVI	A,5		;MSPEED 1200 baud value
	  LXI	H,BD1200	;get pointer to 1200 baud parameter in HL
;
LOADBD:	  STA	INITMOD+1	;store speed to show transfer time
	  MOV	A,M		;get mode register 2 word for new baud rate
	  STA	MODREG2+1	;store in INITMOD
	  JMP	INITMOD		;reinitialize VIO 2651
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  RET
;
;
; Table of baud rate parameters
;
BD300:	  DB	35H
BD1200:	  DB	37H
;
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;
;*******
; DIAL *
;*******
;
; This routine dials the Novation J-Cat.  Mex starts the dial routine
; by calling this subroutine with a 254 (FE hex) in register A.  Each time 
; it is called again A has the next digit of the telephone number.  We
; store the numbers at "number" until the entire number is sent.
; Mex signals that it has sent the entire number by calling this subroutine 
; with a 255 (FF hex) in A.  Once the entire number has been received
; we take the phone off-hook, wait for a dial tone, and dial the number.
; if after 15 seconds we don't detect a carrier, we return to mex with a 2
; in A.  If a carrier is detected, we return with a 0 in A.  If he pressed
; control-c during the dial, we return immediately with a 3 in A.

dial:	cpi	0feh		;see if MEX wants to start a call
	jnz	dial0		;jump if not
	mvi	a,true		;set the entry-in-progress flag
	sta	entryinprogressflag	
	lxi	h,number	;initialize the pointer to the phone number
	shld	numpointer
	ret
dial0:	cpi	0ffh		;see if it's the end-dial code
	jz	dial0a		;jump if it is
				;otherwise A must hold one digit of the phone
				; number
	mov	e,a		;store the value Mex passed us via A in E
	lda	entryinprogressflag	;check and see if it's legal to be
	cpi	true		; here by seeing if the flag is set.
	jz	dial00a		;jump if we're legal
	mvi	c,ilp		;we're not legal. tell him that we've received
	call	mex		; a digit before a start-dial code
	db	'We''ve got a problem.  I received a digit before getting'
	db	cr,lf,'a "Start-dial" code (254).',0
	mvi	a,3		;make it look like a control-c abort to MEX
	ret
dial00a:mov	a,e		;get the digit back in A
	cpi	'9' + 1		;make sure it's between 0 and 9
	rnc			;return if it's too big
	sui	'0'
	rc			;return if it's too big
	adi	'0'		;restore it if it's ok
	call	getnumber	;get the next digit in the phone number from 
				; MEX
	ret
dial0a:	lda	entryinprogressflag	;see if we've received a "start-call"
	cpi	true 
	jz	dial0b		;jump if we are in the middle of a call
	mvi	c,ilp		;tell him that we received an end-dial	code
	call	mex		; before a start-dial code
	db	'We''ve got a problem.  I received an "End-dial" code (255)'
	db	cr,lf,'before getting a "Start-dial" code (254).',0
	mvi	a,3		;make it look like a control-c abort to MEX
	ret
dial0b:	mvi	a,0		;mark the end of the number
	call	getnumber	;store a null at the end of the number
	lda	false
	sta	entryinprogressflag	;reset the flag
	mvi	a,portdefault	;get the default setting for the port we use
	ori	offhook		; to control OHK and set OHK to 1
	out	offonhookport	;take the phone off hook
	mvi	c,ilp		;tell him we're waiting 3 seconds
	call	mex
	db	cr,lf,'Waiting for a dial tone...',0
	mvi	d,dialtonewait
dial0c:	lxi	b,1000		;wait 3 seconds for a dial tone
        call    delay
	call	keycheck	;see if a key was pressed
	dcr	d		;decrement the wait counter
	jnz	dial0c		;jump if we haven't waited long enough
	mvi	c,ilp
	call	mex		;tell him we're starting to dial
	db	cr,lf,'Dialing...',0
	lxi	h,number	;point to the number he just typed
	mov	a,m		;load it into A and check if it's zero
dial1	ora	a		;set the flags. Z set to 1 means A is a zero.
	jz	done		;jump if we finished dialing
	sui	'0'		;otherwise, subtract out the ASCII offset
	jnz	dial1a		;check if it's zero. jump if it's not
	mvi	a,10		;it was zero, so convert it to ten
dial1a	mov	e,a		;keep the digit we're dialing in E
dial2	mvi	a,portdefault	;get the default setting for the port
	ani	onhook		;set OHK to 0 for 60 milliseconds
	out	offonhookport
	lxi	b,60
	call	delay
	mvi	a,portdefault	;get the default setting again
	ori	offhook		;set OHK to 1 for 40 milliseconds
	out	offonhookport
	lxi	b,40
	call	delay
	dcr	e		;decrement E. if E is zero go on to next digit
	jnz	dial2		;jump if it's not zero yet
	lxi	b,900		;it was zero, so wait for 700 to 900 
	call	delay		; milliseconds before we dial the next digit
	call	keycheck	;see if a key was pressed
	inx	h		;get the next digit
	mov	a,m		;put it in A
	jmp	dial1		;jump back to the zero check
done	mvi	c,ilp
	call	mex		;print a crlf
	db	cr,lf,0
	mvi	d,carrierwait	;wait for a carrier "carrierwait" seconds
done1	lxi	b,1000		;wait 1 second for a carrier
	call	delay
	call	carriercheck	;see if we connected with a modem
	jnz	yescarrier	;jump if we connected
	call	keycheck	;see if a key was pressed
	dcr	d
	jnz	done1		;jump if we haven't waited long enough
	call	hangup		;hangup the phone 
	mvi	a,2		;tell MEX we didn't detect a carrier
	ret

yescarrier:mvi	a,0		;tell MEX we detected a carrier
	ret


number:	ds	length
entryinprogressflag db	0
numpointer	ds	2

;
;************
; GETNUMBER *
;************
;	Getnumber gets the telephone number we will dial from the user.
;	C holds the maximum number of characters to be accepted.

getnumber:lhld	numpointer		;get the pointer to the next position
					; to be loaded into the number storage
					; location
	mov	m,a			;move the number MEX sent us to 
					; storage
	inx	h			;increment the pointer to the storage
	shld	numpointer		;save it

;
;***************
; CARRIERCHECK *
;***************
;
; 	Check if we have a carrier.  Return with the zero flag set if not.
;

carriercheck: 	in	cardetectport	;check if a carrier was detected
	ani	carriermask	;mask off the "carrier detect" bit
	ret

;
;***********
; KEYCHECK *
;***********
;	See if he pressed control-c.  If yes, zero flag is set.

keycheck:push	d		;save DE
	push	h		;save HL
	mvi	c,chekcc	;see if control-c was pressed
	call	mex
	pop	h		;restore HL
	pop	d		;restore DE
	rnz	
	call	hangup
	mvi	a,3		;tell MEX we were aborted form the keyboard
	pop	h		;pop the normal return address and throw it
				; away
	ret			;return to MEX instead

;
;*********
; HANGUP *
;*********
;	Hangup puts the phone on hook in the strange way the J-Cat requires
;	to avoid going into self-test.

hangup:	mvi	a,portdefault	;get the default settings again
        ani     onhook		;put the phone on hook (hang up) for 25 msec.
        out     offonhookport
        lxi     b,25
        call    delay
        mvi	a,portdefault	;get the default setting again
        ori     offhook		;take the phone off hook for 20 milliseconds
        out     offonhookport
        lxi     b,20
        call    delay
        mvi	a,portdefault	;get the default setting again
        ani     onhook		;put it on hook again for good this time
        out     offonhookport
	ret


;
;********
; DELAY *
;********
;	Delay is a  delay loop that last BC milliseconds.  Doesn't touch
;	DE and HL.

delay:	push	d		;save DE and HL
	push	h
	inr	b		;Set B to 1 higher, since we decrement it
				; later before we test it
delay1	lxi	d,milliconstant	;load DE with the delay constant
delay2	dcx	d		;inner loop until DE goes to zero
	mov	a,e
	ora	d
	jnz	delay2
	dcr	c		;middle loop until C goes to zero
	jnz	delay1
	dcr	b		;outer loop until B goes to zero too
	jnz	delay1
	pop	h		;restore HL and DE
	pop	d
	ret			; and return

;------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END
;
