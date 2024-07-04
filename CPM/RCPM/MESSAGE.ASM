;
; MESSAGE.ASM - ASCII message typing program for CP/M.
;
; Written 7/24/84 by Al Jewer and released in the public domain.
;
; Copyright (c) 1984 Al Jewer.
;
; THIS PROGRAM MUST NOT BE SOLD !!!!!!!!!!
;
; This file is intended to be used on CP/M systems to generate
; messages in response to typed commands. That is, suppose you
; run an RCPM system, and would like people to know that they
; can use TYPE instead of TYPESQ. This file can be edited to 
; contain a message such as: 
;      TYPESQ no longer needed.... use TYPE instead.
;
; The unique thing about this file is that it contains ONLY ASCII
; characters... that is, the assembled .COM file can be copied
; with, say, WORDSTAR in non-document mode, and the new message
; inserted starting on the second line, and terminated with a 
; dollar-sign character. The resultant file can then be run 
; directly, WITHOUT assembly or loading! 
; You only need a text editor to create a message file!
; 
; This is probably the wildest code I've ever written - if you
; can't follow it, don't worry! 
; Trust me, it works.
;
; Keep in mind that you really don't need the source code, just 
; the .COM file in order to create MESSAGE files.
;
	ORG	100H		; CP/M STARTING ADDRESS
;
START:	DAD H			;GET 0 IN THE L REGISTER
	DAD H
	DAD H
	DAD H
	DAD H	
	DAD H
	DAD H
	DAD H
	MOV H,L			;ZERO THE HI BYTE OF HL PAIR
	MOV D,L			;ZERO HI BYTE OF DE PAIR
	INR L			;GET A 1
	DAD H			;SHIFT LEFT 2
	DAD H
	INR L			;SHIFT IN ANOTHER 1
	DAD H
	INR L			;AND ANOTHER
	DAD H			;FINAL SHIFT GIVES US 16H IN L
	MOV A,L			;GET VALUE TO A
	CMA			;THIS GIVES US 0E9H IN A REGISTER 
				; (THIS IS A PCHL INSTRUCTION)
	MOV L,H			;RE-ZERO THE HL PAIR
	INR L			;GET A 1
	MOV B,L			;SAVE THE 1 IN THE B REGISTER
	DAD H			;GET A 5
	DAD H
	INR L
	MOV E,L			;SAVE THE 5 IN THE E REGISTER
	DCR L			;GET A 9
	DAD H
	INR L
	MOV C,L			;GET FUNCTION CODE (9) TO C REGISTER
	MOV H,B			;GET HI BYTE OF MESSAGE ADDRESS TO H
	MVI L,(ADDRESS AND 0FFH) ;POINT TO OUR PCHL ADDRESS (THIS WILL
				;BE AN OFFSET LARGER THAN 20H AND SMALLER
				;THAN 7FH, THEREFORE AN ASCII CODE
	MOV M,A			;MOVE PCHL INSTRUCTION TO RAM
	INR L			;POINT PAST PCHL TO START OF MESSAGE
	INR L			;ALSO PAST INITIAL CRLF
	INR L
	MOV A,L			;SWAP HL & DE (DE MUST POINT TO MESSAGE,
				;HL MUST POINT TO LOCATION 5)
	MOV B,H
	MOV L,E
	MOV H,D
	MOV D,B	
	MOV E,A
ADDRESS: DB 'X'			;THIS WILL BE CHANGED TO A PCHL
	DB 0DH, 0AH		;INITIAL CRLF
	DB 'This is where the message goes', 0DH, 0AH
	DB 'Make sure you end the message with a dollar-sign!', 0DH, 0AH
	DB '$'			;MESSAGE TERMINATOR
	DB 'Z'-40H		;ASCII END OF FILE
;
	END	START
