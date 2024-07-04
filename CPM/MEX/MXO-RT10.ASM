	TITLE	'MEX RACAL-VADIC VA3451 AUTO DIAL - V1.0'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; MXO-RT10.ASM  Original release 6/13/84
;
; Racal Vadic VA3451 overlay for MEX: revision 1.0
;  Written 13 June 1984 by Dave Mabry
;  Adapted using information and excerpts from Ron Fowler's
;   overlay for the PMMI modem.
;
; Please leave any bug reports or requests on TCBBS in Dearborn,
;  Michigan (313-846-6127) or Royal Oak RCPM (313-759-6569)
;  or call me at 313-956-5703 (voice).        mabry
;
; Note that unlike the Hayes modem, the Racal Vadic does not
;  have an ascii command that will cause a disconnect.  Therefore
;  for that feature of MEX to work properly, your normal overlay
;  for your machine must be able to toggle DTR in the DISCV routine.
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
; Note: For the disconnect to work properly, you MUST have DISCV
;	implemented in your normal machine overlay.  This file
;	is overlayed in addition to your overlay.
;	Also, your overlay MUST have the entry point NEWBDV that
;	allows this program to set the baud rate by passing a
;	single byte parameter in the A register.
;	See Ron Fowler's overlay for the GodBout S-100 board for
;	examples of these routines.
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;
; SYSTEM CONSTANTS
;
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165H		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
DIALOC	EQU	0B00H		;DIALING CODE GOES HERE
;
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately pre-
; ceeding the actual FCB (to contain user # information).  If you've
; used MEX-10 for input instead of BDOS-10 (or you're parsing part
; of a SET command line that's already been input), then MEX will
; take care of DU specs, and set up the FCB accordingly.  There-
; after all file I/O calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
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
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
MSPEED	EQU	107H		; Variable in hardware overlay
NEWBDV	EQU	16EH		; Entry in overlay to set baud rate
;
;
CR	EQU	13
LF	EQU	10
;
;
	ORG	DIALV		;OVERLAY THE DIALING VECTOR
	JMP	DIAL
;	
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the Racal Vadic).
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
DIAL:	LHLD	DIALPT		;FETCH POINTER
	CPI	254		;START DIAL?
	JZ	STDIAL		;JUMP IF SO
	CPI	255		;END DIAL?
	JZ	ENDIAL		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	MOV	M,A		;PUT CHAR IN BUFFER
	INX	H		;ADVANCE POINTER
	SHLD	DIALPT		;STUFF PNTR
	RET			;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL:	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:
	MVI	M,0		; Terminate phone number string
	XRA	A
	STA	BDFLAG		; Zero BDFLAG
	LDA	MSPEED		; Get baud rate set by MEX
	CPI	5		; 1200 baud ???
	JZ	CLEAR		; Nothing to do if 1200 baud
	STA	BDSAVE		; Save baud rate locally
	MVI	A,TRUE		; Else, set flag
	STA	BDFLAG
	MVI	A,1		; If not 1200 baud then set 300
	CALL	NEWBDV		;  baud for dialing
CLEAR:
	MVI	C,INMDM		; Clean out the data buffer in usart
	CALL	MEX
	JNC	CLEAR		; Get all available
	LXI	H,WAKEUP	; Get modem's attention
	CALL	RVSEND
	CALL	STWAIT		; After "HELLO..."
	LXI	H,DCMD		; Send "dial" command to modem
	CALL	RVSEND
	CALL	SENDCR		; Terminate dial command
	LXI	H,DIALBF	; Point to number
	CALL	RVSEND		; Send it to modem
	CALL	SENDCR		; Send <cr> to terminate phone number
	LXI	H,CRMSG		; Second <cr> to initiate dialing
	CALL	RVSEND
;
; Here starts the main loop waiting for messages from the modem
;  and interpreting them.  Some are just passed to the console
;  and others trigger a specific action.
;
DLOOP:
	LXI	H,RESPBF	; Point to response buffer
	MVI	C,255		; Long wait here
	CALL	CATCHR		; Catch response from modem
	ORA	A		; Zero return code ?
	JNZ	RETRN		; No, return error code
	MOV	A,B		; Get character count from CATCHR
	ORA	A		; Hope it isn't zero
	JZ	DLOOP		; If it is, then ignore this response
	LXI	H,RESPBF	; Point to string from modem
	LXI	D,RSPTBL	; Point to valid response table
	CALL	COMPR		; Find out which response we got
	MOV	A,B		; Get return value
	CPI	255		; No response match
	JNZ	DIAL05
ERRET:
	MVI	A,2		; Timed out waiting for answer
	JMP	IDLE		; Disconnect and return error code
DIAL05:
	CPI	2		; Failed call ?
	JZ	ERRET		; Error return
	CPI	1		; Dialing message ?
	JNZ	DIAL10
	MVI	C,ILP
	CALL	MEX
	DB	'Dialing...',0
	JMP	DLOOP
DIAL10:
	CPI	3		; On line ?
	JNZ	ERRET
	XRA	A		; Return on line code to MEX
RETRN:
	PUSH	PSW		; Save return code
RET03:
	LDA	BDFLAG		; See if we have to reset baud rate
	ORA	A
	JZ	RET05		; Return if no
	LDA	BDSAVE		; Get saved rate code
	CALL	NEWBDV		; Set old baud again
RET05:
	POP	PSW		; Get return code
	RET

IDLE:
;
; Forces modem into idle state by sending "idle" command and
;  then toggling DTR using the user's DISCV entry.
; Preserves any return code that may be in register A.
;
	PUSH	PSW		; Preserve any return code
	CALL	DISCV		; Make sure modem disconnects
	LXI	H,IDLCMD	; Send idle command
	CALL	RVSEND
	JMP	RET03

SENDCR:
;
; Sends a carriage return character to the modem and waits for a
;  line feed character to be returned.
;
	LXI	H,CRMSG		; Send <cr> to modem
	CALL	RVSEND

; Note: execution falls through to LFWAIT
;
; Waits til the character from the modem is a line feed
; Returns the same codes as CATCHR.
;
LFWAIT:
	MVI	C,10		; Up to one second for <lf>
	LXI	H,RESPBF
	JMP	CATCHR		; Use CATCHR to wait for <lf>

STWAIT:
	MVI	C,INMDM		; Get one character from modem
	CALL	MEX
	JC	STWAIT		; If time out, wait
	CPI	'*'		; Is it the "*" prompt ?
	JNZ	STWAIT
	RET


; Table of valid responses from modem
RSPTBL:
	DB	'HE',0		; "hello..."
	DB	'DI',0		; "dialing..."
	DB	'FA',0		; "failed call"
	DB	'ON',0		; "on line"
	DB	0		; Table terminator


COMPR:
; Compares a string of characters in memory to a table of
;  strings.  Each entry of the table must be terminated by
;  a zero byte, and the table must be terminated by another
;  zero byte.
; Inputs:  HL points to the string to look for
;	   DE points to the table
; Output:  B contains the number of the table entry that
;	     matches the string, and a 255 if no entry matched.
;
	MVI	B,0		; Init index
CMPR05:
	MVI	C,2		; Number of characters to try to match
CMPR10:
	LDAX	D		; Fetch char from table
	CMP	M		; Same as char in string ?
	JNZ	CMPR15		; Jump if not this entry in table
	INX	H		; Else, point to next char in string
	INX	D		;  and next char in table entry
	DCR	C		; Decrement counter of characters
	JNZ	CMPR10		; Go check next char
	RET			; B contains the index of match
CMPR15:
	INR	B		; Increment index
CMPR20:
	INX	D		; Next char in table
	LDAX	D		; Get next char from table
	ORA	A		; Is it last char in that entry ?
	JNZ	CMPR20		; No, keep looking
	INX	D		; Yes, then point to first char of next one
	LDAX	D		; Now check for end of table
	ORA	A		; Zero delimits table
	JNZ	CMPR05		; Go check this table entry
	MVI	B,255		; No match return code
	RET


CATCHR:
;
; Catch response from modem.
; Input:  HL pointing to buffer for characters from modem
;	  C  delay allowed before timeout (multiples of 100ms)
; Output: Buffer contains the string received from modem with
;	   any control characters filtered out.
;	  C  count of characters received before <cr>
;	  A  error code:  0 ==> normal return
;			  2 ==> time out occurred
;			  3 ==> user typed ^C
;
	MVI	B,0		; Character counter
	MOV	A,B		; Initialize space flag
	STA	SPFLAG
CRLOOP:
	MOV	D,C		; Initialize count down timer
CRL05:
	PUSH	B		; Save character counter
	PUSH	D		; Save time out count down
	PUSH	H		; Save buffer pointer
	MVI	C,CHEKCC	; See if user typed ^C
	CALL	MEX
	JZ	UABORT		; If yes, jump to user abort code
	MVI	C,INMDM		; Else, continue
	CALL	MEX		; Get char in 1ms if available
	POP	H		; Restore working registers
	POP	D
	POP	B
	JC	NOCHAR		; If no char in 1ms, handle it
	ANI	7FH		; Mask any parity bit
	CPI	LF		; End of line from modem ?
	JZ	EOL		; If <lf> then end of line
	CPI	' '		; End of "DIALING:  "
	JZ	CRSPC		; Handle space character
	JC	CRLOOP		; Ignore control characters
	CPI	'z'+1		; Nothing above lower case alpha's
	JNC	CRLOOP
	MOV	M,A		; Here we have a valid character
	INX	H		;  so save it and bump pointer
	INR	B		; Increment character counter also
	JMP	CRLOOP		; Go get the next one

;
; Handle no character from modem in 1ms
;
NOCHAR:
	DCR	D		; Decrement time out counter
	JNZ	CRL05		; If not to zero, wait some more
	MOV	C,B		; Else, return with what we have now
	MVI	A,2		; Time-out error code
	RET
;
; End of line from modem
;
EOL:
	MOV	C,B		; Character count
	XRA	A		; Return zero
	RET
;
; Handle space character, two in a row means the end of the
;  modem response "DIALING:  ".
;
CRSPC:
	LDA	SPFLAG		; Get space flag
	ORA	A
	JNZ	EOL		; This must be the second one in a row
	CMA			; Otherwise, set the flag, it is the
	STA	SPFLAG		;  first one, flag it
	JMP	CRLOOP		; Loop for more characters
;
; User abort from ^C
;
UABORT:
	CALL	IDLE		; Force disconnect
	POP	H		; Since these are still on the stack
	POP	D
	POP	B
	MOV	C,B		; Count of characters up to now
	MVI	A,3		; User abort code
	RET

;
; Sends a string of characters pointed to by HL terminated by zero
;
RVSEND:
	PUSH	H		; Save memory pointer
RV05:
	MVI	C,SNDRDY	; Get modem send status
	CALL	MEX
	JNZ	RV05		; Wait for modem ready
	MVI	B,1		; Wait 1ms for modem software uart
	MVI	C,TIMER
	CALL	MEX
	POP	H		; Restore pointer
	MOV	A,M		; Get character
	INX	H		; Point to next character
	ORA	A		; Is this the terminator ?
	RZ			; If yes, done
	MOV	B,A		; Pass character in B
	MVI	C,SNDCHR	; Let MEX send to modem
	CALL	MEX
	JMP	RVSEND

;
; DATA AREA
;
WAKEUP:	DB	'E'-40H,CR,0	; String to wake up modem
IDLCMD:	DB	'I',CR,0	; Idle command
DCMD:	DB	'D',0		; Dial command to modem
CRMSG:	DB	CR,0		; Note, this is end of DCMD
SPFLAG:	DS	1		; Space flag for catch response routine
BDFLAG:	DS	1		; True for 450 or 600 baud
BDSAVE:	DS	1		; Save for MSPEED code for 450 or 600
RESPBF:	DS	20		; Response from modem
DIALBF:	DS	30		; Phone number buffer
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
