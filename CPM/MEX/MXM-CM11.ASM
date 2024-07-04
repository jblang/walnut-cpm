	TITLE	'MEX Cermetek Infomate 212a overlay V1.1'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; Cermetek overlay for MEX: revision 1.1
; Written 08/22/84 by Paul Traina with grateful thanks to Ronald G. Fowler
; Last revision: 08/24/84 (PST)
;
; This modules adapts MEX for the Cermetek Infomate 212a Intelligent Modem.
; The main function of this module is to provide dialing capability; the
; disconnect vector is ancillary.
;
;----------------------------------------------------------------
;
; 08/24/84	Updated for MEX version 1.1		-- Paul Traina
;
; 08/22/84	This is based upon original work by RGF.  I can take
;		no credit for the intelligence needed to make this module,
;		but if there is some blame for it malfunctioning, I'll take
;		that, because I was the one who performed the cut-job.
;							-- Paul Traina
;
;----------------------------------------------------------------
;
; This overlay will work with any modem overlay that terminates
; prior to 0900H
;
; System Constants
;
DIALV	EQU	0162H		; Location of DIAL vector in overlay
DISCV	EQU	0165H		; Location of DISCONNECT vector in overlay
DIALOC	EQU	0900H		; Dialing code goes here
MEX	EQU	0D00H		; "CALL MEX"
;
; Following are function codes for the MEX service call processor
;
INMDM	EQU	255		; Return char form MDM in A, CY=no chr in 100ms
TIMER	EQU	254		; Wait B*100ms
TMDINP	EQU	253		; B=# secs to wait for char, CY=no char
CHEKCC	EQU	252		; Check for ^C from kbd, Z=present
SNDRDY	EQU	251		; Test for modem-send ready
RCVRDY	EQU	250		; Test for modem-receive ready
SNDCHR	EQU	249		; Send a character to the modem (after SNDRDY)
RCVCHR	EQU	248		; Recv a char from modem (after RCVRDY)
ILP	EQU	240		; Inline print routine
;
CR	EQU	13		; Ascii carriage-return
LF	EQU	10		; Ascii line-feed
APPOS	EQU	027H		; Ascii appostrophe
;
	ORG	DIALV		; Overlay the dialing vector
	JMP	DIAL
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).	Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the Smartmodem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this condition)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;	5 - No ring detected (only for modems that can detect this condition)
;	6 - No dial tone (only for modems that can detect this condition)
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
	ORG	DIALOC
;
DIAL:	LHLD	DIALPT		; Fetch pointer
	CPI	254		; Start dial?
	JZ	STDIAL		; Jump if so
	CPI	255		; End dial?
	JZ	ENDIAL		; Jump if so
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	MOV	M,A		; Put char in buffer
	INX	H		; Advance pointer
	SHLD	DIALPT		; Stuff pointer
	RET			; All done
;
; Here on a start-dial sequence
;
STDIAL:	LXI	H,DIALBF	; Set up buffer pointer
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:	MVI	M,0		; Terminate buffer
	CALL	IMLRN		; Learn new baud rate
	LXI	H,IMDIAL	; Point to dialing string
	CALL	IMSEND		; Send it
	LXI	H,IMEND		; Point to terminal part of string
	CALL	IMSEND
	MVI	C,INMDM
	CALL	MEX		; Catch any output from the modem
;
; The following loop waits for a result from the modem (up to
; 60 seconds: You may change this value in the following line)
;
RESULT:	MVI	C,60		; <<== MAXIMUM TIME TO WAIT FOR RESULT
IMWLP:	PUSH	B
	MVI	B,1		; Check for a char, up to 1 sec wait
	MVI	C,TMDINP	; Do timed input
	CALL	MEX
	POP	B
	JNC	IMTEST		; Jump if modem had a char
	PUSH	B		; No, test for ^C from console
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	IMNEXT		; If not, jump
	CALL	DISCV		; Disconnect for 1 second if possible
	LXI	H,IMABRT	; Send abort string
	CALL	IMSEND
WTABRT:	MVI	C,INMDM		; Wait for any garbage
	CALL	MEX
	JNC	WTABRT
	MVI	A,3		; Return abort code
	RET
IMNEXT:	DCR	C		; No
	JNZ	IMWLP		; Continue
;
; One minute with no modem response
;
IMTIMO:	MVI	A,4		; Return with modem error
	RET
;
; Modem gave us a result, check it
;
IMTEST:	ANI	127		; Ignore any parity
	CALL	IMANAL		; Test the result
	JC	RESULT		; Go try again if unknown response
	MOV	A,B		; A=result
	PUSH	PSW		; Save it
IMTLP:	MVI	C,INMDM		; Eat any additional chars from modem
	CALL	MEX
	JNC	IMTLP		; Until 100ms of quiet time
	POP	PSW		; Return the code
	RET
;
IMANAL:	MVI	B,0		; Prep connect code		 B=0
	CPI	'A'		; Answer?
	RZ
	MVI	B,1		; Prep busy code		 B=1
	CPI	'B'		; Busy?
	RZ
	MVI	B,2		; Prep no connect message	 B=2
	CPI	'N'		; No answer?
	RZ
	MVI	B,4		; Prep error			 B=4
	CPI	'W'		; Wrong baud rate?
	RZ
	MVI	B,6		; Prep no dial tone		 B=6
	CPI	'X'		; No phone connected?
	RZ
;
	CPI	'V'		; Voice (which mex does not support)
	JNZ	WTCR		; Error
	PUSH	D		; Message
	PUSH	H
	MVI	C,ILP
	CALL	MEX
	DB	'VOICE ',0
	POP	H
	POP	D
;
; Unknown response, return carry to caller, do not flush unknown response
;
WTCR:	STC			; Set flag if so
	RET
;
; Utility routine, learn baud rate
;
IMLRN:	LXI	H,IMLERN
IMLRN1:	MVI	C,SNDRDY	; Wait for modem ready
	CALL	MEX
	JNZ	IMLRN1
	PUSH	H		; Wait 200ms
	MVI	B,2
	MVI	C,TIMER
	CALL	MEX
	POP	H
	MOV	A,M		; Fetch next character
	INX	H
	ORA	A		; End?
	RZ			; Done if so
	MOV	B,A		; No, position for sending
	MVI	C,SNDCHR	; Nope, send the character
	CALL	MEX
	JMP	IMLRN1
;
; Utility routine: send string to modem
;
IMSEND:	MVI	C,SNDRDY	; Wait for modem ready
	CALL	MEX
	JNZ	IMSEND
	MOV	A,M		; Fetch next character
	INX	H
	ORA	A		; End?
	RZ			; Done if so
	MOV	B,A		; No, position for sending
	MVI	C,SNDCHR	; Nope, send the character
	CALL	MEX
	JMP	IMSEND
;
; DATA AREA
;
IMDIAL:	DB	CR,'N'-40H,'N ~',CR,CR,CR ; Init to new attn character
	DB	'~U 1',CR,CR,CR	; Unlisten
	DB	'~D ',APPOS	; ~D 'num'^M
DIALBF:	DS	52		; 2* 24 char max,+cr+null+slop
DIALPT:	DS	2		; Dial position pointer
IMEND:	DB	APPOS,CR,0	; End part of dial string
IMABRT:	DB	'~',CR,'~',CR,CR,0 ; Abort string
IMLERN:	DB	'  XY',CR,0	; Learn baud rate
;
	END
