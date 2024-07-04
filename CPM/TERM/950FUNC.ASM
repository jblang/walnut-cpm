;
; Written by:
;                         Kirk De Haan
;                        2595 Flory Dr.
;                      San Jose,Ca.  95121
;
;
;
;
;
;
; 950FUNC.ASM - PROGRAMS THE FUNCTION KEYS ON TELEVIDEO EQUIPMENT,
;               INCLUDING THE FOLLOWING:
;
;                      TS-800A
;                      TS-802
;                      TS-802H
;                      ALL TERMINALS
;
;
; This program will load the function keys of any of the above 
; listed terminals and systems. All that is neccesary is to add
; the escape code that you desire. All escape codes listed in the
; user manuals will work with no problem. 
;
;                                 Kirk De Haan
;
;
;
; Equates
;
BDOS	EQU	0005H	;BDOS ENTRY
PSTRING	EQU	09H	;PRINT STRING
ESC	EQU	1BH	;ESCAPE
CR	EQU	0DH	;CARRIAGE RETURN
LF	EQU	0AH	;LINE FEED
CNTLY	EQU	19H	;^Y
CNTLP	EQU	10H	;^P
CNTLC	EQU	03H	;^C
;
;
	ORG	0100H
;
;
START	MVI	C,PSTRING
	LXI	D,MSG
	CALL	BDOS
	RET
;
;
;
MSG	EQU	$
;
;
; Insert your particular escape code here. Put it in the form
; of DB just as if you were inserting an actual message. This 
; data will be sent to the terminal the same as any ASCII string.
; The following is an example of the escape code sequence for
; loading the function keys.
;
; 	DB	ESC,'|11TEST',CR,CNTLY
;
; This will program key F1 to print TEST (with carriage return) locally
; and to the system processor.
; Refer to your users manual for a complete list of codes. 
;
;
;                      ON SCREEN LABELS
;
;
; If you wish to incorporate labels for your function keys insert
; the 'labels' in place of XXXXX in the code below. This code will
; setup the user line and line 24. Line 24 will be locked out, 
; therefore it will reduce your terminal to 23 x 80. If you do not
; want the labels simply insert ';' in column 1.
;
;
;                          UNSHIFTED
;
;
	DB	ESC,'f',ESC,'G4'
	DB	' '
	DB	'XXXXX'	;F1
	DB	'  '
	DB	'XXXXX'	;F2
	DB	'  '
	DB	'XXXXX'	;F3
	DB	'  '
	DB	'XXXXX'	;F4
	DB	'  '
	DB	'XXXXX' ;F5
	DB	'  '
	DB	'XXXXX' ;F6
	DB	'  '
	DB	'XXXXX'	;F7
	DB	'  '
	DB	'XXXXX' ;F8
	DB	'  '
	DB	'XXXXX' ;F9
	DB	'  '
	DB	'XXXXX' ;F10
	DB	'  '
	DB	'XXXXX'	;F11
	DB	CR
	DB	ESC,'g'
;
;
;                           SHIFTED
;
;
	DB	ESC,'=7 ',ESC,'G<'
	DB	' '
	DB	'XXXXX' ;F1
	DB	'  '
	DB	'XXXXX' ;F2
	DB	'  '
	DB	'XXXXX'	;F3
	DB	'  '
	DB	'XXXXX'	;F4
	DB	'  '
	DB	'XXXXX'	;F5
	DB	'  '
	DB	'XXXXX'	;F6
	DB	'  '
	DB	'XXXXX'	;F7
	DB	'  '
	DB	'XXXXX'	;F8
	DB	'  '
	DB	'XXXXX'	;F9
	DB	'  '
	DB	'XXXXX' ;F10
	DB	'  '
	DB	'XXXXX' ;F11
	DB	ESC,'!1'
;
;
;
; The next bytes clear the screen of the garbage printed and
; indicate the end of the string. DO NOT REMOVE IT!!
;
	DB	ESC,'*$'	
;
;
	END	0100H
