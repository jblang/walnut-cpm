	
*************************************************************************
*									*
*  FK.ASM   Version 2.1		Function Key programmer			*
*  2 August 1984							*
*									*
*  by: Charlie Hoffman							*
*									*
*  modifications by Joe Griffith					*
*  16 August 1984							*
*  - Added parameter passing so that multiple sets of commands could	*
*    be programmed into the function keys				*
*  - Changed output routine to use BDOS function 2 to enable $		*
*  - Reformatted program to make room for 16 function key entries	*
*  - Set F16 to 'F' for use with resident command package		*
*									*
*     The purpose of this program is to provide initialization for	*
* the WYSE 50 HOST MESSAGE LINE and to program the FUNCTION KEYS as	*
* well as the FUNCTION KEY LINE.  IT also sets the atributes of these	*
* lines as well as the LOCAL MESSAGE FIELD to dim.			*
*									*
*************************************************************************

; -- Equates --

bdos	equ	5		;CP/M BDOS jump address
tpa	equ	100h		;CP/M transient program area address
conout	equ	2		;CP/M bdos print character function
param	equ	80h		;location of parameter from command line
numsets	equ	5		;total number of function key sets 

cr	equ	0Dh		;carriage return
lf	equ	0Ah		;line feed
bell	equ	7		;ascii bell
esc	equ	1Bh		;escape
del	equ	7Fh		;delete

;------------------------------------------------------------------

	org	tpa		;standard CP/M location

start:	lxi	h,0		;save CP/M's stack by adding it
	dad	sp		;to the stack pointer and
	shld	cpmstk		;storing it in a safe place
	lxi	sp,stack+100	;to generate a new stack for use
				;by this program

;------------------------------------------------------------------

	mvi	a,numsets+1	;store the total number of sets in
	sta	sets		;a convenient place (inc'd for logic)c

;------------------------------------------------------------------ 

	lxi	h,msg0		;get address of initialization msg
	call	print		;send it

;-----------------------------------------------------------------

	lda	param		;get size of parameter
	ora	a		;check the flag and see if there even
	jz	default		;is a parameter
	dcr	a		;get size of parameter
	jz	default		;must have been a space only

which:	lda	sets		;get number of sets left to check
	dcr	a		;countdown for real number
	jz	error		;parameter is not a legal one
	sta	sets		;store remaining number of sets
	add	a		;multiply by 2 for wordoffset
	mov	e,a		;put offset in e for pointer
	mvi	d,0		;zero out the rest of the pointer
	lxi	h,setbl		;get address of table
  	dad	d		;add the offset to it.
	mov	e,m		;move low order byte of setname
	inx	h		;bumb the pointer for the high order byte
	mov	d,m		;DE now points to correct name. 
	xchg			;put it all in the 'M' pointer
	lxi	b,param+2	;get address of first char of parameter

compar:	ldax	b		;get character of parameter
	ora	a		;check for end of parameter and 
	jz	match		;if match then go for it, else
	mov	e,m		;get character of setname
	cmp	e		;do they match?
	jnz	which		;no, then try next set
	inx	h		;else bump the pointers
	inx	b		;to the next character
	jmp	compar		;and try again

match:	lda	sets		;get number of set that matched
	add	a		;multiply it by two
	mov	e,a		;store it as the offset in the DE
	mvi	d,0		;register
	lxi	h,msgtbl	;get the address of the message table
	dad	d		;add the offset and we're ready to print
	mov	e,m		;move low order byte of message address
	inx	h		;bump the pointer for the high byte
	mov	d,m		;get the other half of the address
	xchg			;put the address of the message in HL

cont:	call	print


theend:	lhld	cpmstk		;get the old stack back
	sphl			;switch it into the stack pointer
	ret			;return to CP/M

;-----------------------------------------------------------------------

print:	push	h		;and save it.
	mov	a,m		;get the next character
	ani	80h		;check for most significant bit set
	jnz	print1		;if so then you are done
	mov	e,m		;else get ready to print it
	mvi	c,conout	;load bdos function
	call	bdos		;print the message
	pop	h		;restore message pointer
	inx	h		;move to next character and
	jmp	print		;repeat

print1	pop	h		;fix the stack
	ret

;-------------------------------------------------------------------

default	lxi	h,msg1		;get address of standard message
	jmp	cont

;-------------------------------------------------------------------

error:	lxi	h,errmsg	;get address of error message
	jmp	cont		;print it and done

errmsg:	db	'Invalid Parameter'
	db	80h

;------------------------------------------------------------------

setbl:	dw	0		;dummy address
	dw	set1
	dw	set2
	dw	set3
	dw	set4
	dw	set5		;etc for more sets

;-------------------------------------------------------------------

msgtbl:	dw	0		;dummy address
	dw	msg1
	dw	msg2
	dw	msg3
	dw	msg4
	dw	msg5		;etc for more sets

;-------------------------------------------------------------------

cpmstk:	dw	0		;storage of CP/M stack
sets:	ds	1		;storage of number of sets in system

;-------------------------------------------------------------------

msg0:	DB	ESC,'A1p',CR		;SET FUNCTION KEY LINE TO DIM
	DB	ESC,'A2p',CR		;SET LOCAL MESSAGE LINE TO DIM
	DB	ESC,'A3p',CR		;SET HOST MESSAGE LINE TO DIM

	DB	ESC,'F'			;ENTERS MESSAGE INTO THE HOST
;	DB	'ZCPR3 version  1.0 '	;MESSAGE FIELD 
;	DB	'dated July 20',2CH,' 1984'
	DB	CR,LF,80h

;--------------------------------------------------------------------

set1:	db	'SYS',0			;name of first set

msg1:	db	ESC,'z01=MBASIC',CR	;label for 1
	db	ESC,'z@MBASIC',CR,DEL	;code for 1

	db	ESC,'z12=MEX',CR	;label for 2
	db	ESC,'zAMEX',CR,DEL	;code for 2

	db	ESC,'z23=NS',CR		;label for 3
	db	ESC,'zBNS',CR,DEL	;code for 3

	db	ESC,'z34=SYSTEM',CR	;label for 4
	db	ESC,'zCSYSTEM',CR,DEL	;code for 4

	db	ESC,'z45=WS',CR		;label for 5
	db	ESC,'zDWS',CR,DEL	;code for 5

	db	ESC,'z56=SD $A',CR	;label for 6
	db	ESC,'zESD $A',CR,DEL	;code for 6

	db	ESC,'z67=$PZ SZ',CR	;label for 7
	db	ESC,'zF $PZ SZ',CR,DEL	;code for 7

	db	ESC,'z78=*.*',CR	;Label for 8
	db	ESC,'zG*.*',CR,DEL	;code for 8

	db	ESC,'zH',0Ah,'1',DEL	;code for 9
	db	ESC,'zI',0Ah,'2',DEL	;code for 10
	db	ESC,'zJ',0Ah,'3',DEL	;code for 11
	db	ESC,'zK',0Ah,'E',DEL	;code for 12
	db	ESC,'zL',0Ah,'S',DEL	;code for 13
	db	ESC,'zM',0Ah,'U',DEL	;code for 14
	db	ESC,'zN',0Ah,'T',DEL	;code for 15
	db	ESC,'zOF',CR,DEL	;code for 16

	db	80h			;end of the line (1)

;--------------------------------------------------------------------

set2:	db	'WS',0			;name of second set

msg2:	db	ESC,'z01=Begin',CR	;lable for 1
	db	ESC,'z@',0Bh,'B',DEL	;code for 1

	db	ESC,'z12=End',CR	;lable for 2
	db	ESC,'zA',0Bh,'K',DEL	;code for 2

	db	ESC,'z23=Move',CR	;lable for 3
	db	ESC,'zB',0Bh,'V',DEL	;code for 3

	db	ESC,'z34=Hide',CR	;label for 4
	db	ESC,'zC',0Bh,'H',DEL	;code for 4

	db	ESC,'z45=      ',CR	;label for 5
	db	ESC,'zD',DEL		;code for 5

	db	ESC,'z56=      ',CR	;label for 6
	db	ESC,'zE',DEL		;code for 6

	db	ESC,'z67=      ',CR	;label for 7
	db	ESC,'zF',DEL		;code for 7

	db	ESC,'z78=      ',CR	;label for 8
	db	ESC,'zG',DEL		;code for 8

	db	ESC,'zH',DEL		;code for 9
	db	ESC,'zI',DEL		;code for 10
	db	ESC,'zJ',DEL		;code for 11
	db	ESC,'zK',DEL		;code for 12
	db	ESC,'zL',DEL		;code for 13
	db	ESC,'zM',DEL		;code for 14
	db	ESC,'zN',DEL		;code for 15
	db	ESC,'zO',DEL		;code for 16

	db	80h			;end of the line (2)

;--------------------------------------------------------------------

set3:	db	'NAME3',0		;name of third set

msg3:	db	ESC,'z01=THREE',CR	;label for 1
	db	ESC,'z@THREE',CR,DEL	;code for 1

	db	80h

;-------------------------------------------------------------------

set4:	db	'NAME4',0		;name of fourth set

msg4:	db	ESC,'z01=FOUR',CR	;label for 1
	db	ESC,'z@FOUR',CR,DEL	;code for 1

	db	80h

;--------------------------------------------------------------------

set5:	db	'//',0			;name of fifth set

msg5:	db	'Wyse-50 Function Key Initialization',CR,LF,CR,LF
	db	'Format:  FK          no parameters defaults to set 1.',CR,LF
	db	'         FK WS       uses set labeled "WS".',CR,LF
	db	'         FK #o6S     invalid parameter prints error msg.',CR,LF
	db	'         FK //       prints this message.',CR,LF

	db	80h

;---------------------------------------------------------------------

stack:	ds	100		;memory is cheap

	end

;**********************************************************************

