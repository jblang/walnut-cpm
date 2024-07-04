	TITLE	'MEX CONCORD DATA SYSTEMS 224 ARQ/AD OVERLAY V1.2'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; MXM-CQ12.ASM  Current version 3 Sep 85
;
; Concord Data Systems 224 ARQ/AD modem overlay for MEX v1.1x
;  Written 7 Feb 85 by Dave Mabry
;  Adapted using information and excerps from Ron Fowler's
;   overlay for the PMMI modem.
;
; Please leave any bug reports or requests on TCBBS in Dearborn,
;  Michigan (313-846-6127) or Royal Oak RCPM (313-759-6569)
;  or call me at 313-956-5703 (voice).        mabry
;
; Updates:
;  MXM-CQ10.ASM
;   2/7/85...Original release.
;  MXM-CQ11.ASM
;   6/29/85...Modified for MEX V1.3x
;  MXM-CQ12.ASM
;   9/3/85...Made generic for MEX and MEX Plus.  Use MXPLUS equate for
;	     different versions.
;
; Note that unlike the Hayes modem, the Concord does not
;  have an ascii command that will cause a disconnect.  Therefore
;  for that feature of MEX to work properly, your normal overlay
;  for your machine must be able to toggle DTR in the DISCV routine.
; Note also that the modem must be set for 2400 bps to the eia (rs232)
;  interface back to your computer.  It will adjust automatically for
;  dial-up systems that do not support 2400 bps by communicating to
;  the remote system as 1200 bps, but still communicate to your computer
;  at 2400 bps.
;
; This overlay will work with any other overlays that terminate
; prior to 0B00H.
;
VERS	EQU	12		; Version number
FALSE	EQU	0
TRUE	EQU	0FFH
MXPLUS	EQU	TRUE		; True for MEX Plus, False for MEX
;
;
; SYSTEM CONSTANTS
;
NDISCV	EQU	015FH		; Modem disc routine
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165H		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
DIALOC	EQU	0B00H		;DIALING CODE GOES HERE
SMTABL	EQU	0D55H		; Smart modem INIT, DE-INIT, SSET ovlys
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
PRNTBL	EQU	237		;print MEX format table (HL)
PRID	EQU	236		;print MEX ID string on console
ONOFF	EQU	235		;parse on/off from input stream (a=0 or 1,
				; cy=error)
;
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
;
CR	EQU	0DH
LF	EQU	0AH
ESC	EQU	1BH
;
;
MSPEED	EQU	107H		; Modem speed byte
B1200	EQU	5		; Byte for 1200 baud
B2400	EQU	6		; Byte for 2400 baud
NEWBDV	EQU	16EH		; Entry point for new baud routine
;
;
	IF	MXPLUS

	ORG	100H		; TPA
	DB	0C3H		; Flag overlay

	ORG	NDISCV
	RET

	ENDIF

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
; scheme employed here).
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
;	5 - No ring reported by modem
;	6 - No dial tone reported by modem
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
;
CLEAR:
	MVI	C,INMDM		; Clear out the data buffer in USART
	CALL	MEX
	JNC	CLEAR		; Get them all
	MVI	A,B2400		; Assume modem is at 2400 bps
	CALL	NEWBDV		;  so set computer
	LXI	H,WAKEUP	; Get modem's attention
	CALL	CDSEND
	MVI	C,5		; ~.5 second wait
	CALL	CATCHR		; Catch response from modem
	ORA	A		; Check response
	JZ	AROUND		; If there was a response, then modem
				;  and system were at same baud rate
	CPI	3		; User typed ^C ?
	JNZ	ERRET		; If no, then modem error
	RET			; Otherwise, return with user abort code
AROUND:
	LXI	H,DCMD		; Send "dial" command and # to modem
	CALL	CDSEND
	CALL	SENDCR		; Send <cr> to terminate phone number
;
; Here starts the main loop waiting for messages from the modem
;  and interpreting them.  Some are just passed to the console
;  and others trigger a specific action.
;
DLOOP:
	MVI	C,255		; Long wait here
	CALL	CATCHR		; Catch response from modem
	ORA	A		; Zero return code ?
	JNZ	IDLE		; No, disconnect and return error code
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
	MVI	A,4		; Error return to MEX
	JMP	IDLE		; Disconnect and return error code
DIAL05:
	CPI	3		; OK ?
	JZ	DLOOP		; Ignore this one
	ORA	A		; Need to know if 0 ==> connected
	RZ			; Only this code can return w/o disconnecting
	CPI	7		; If <= 6 then let it return to MEX
	JC	IDLE
	JNZ	DIAL10		; If not 7 (7 = voice)
	MVI	A,1
	JMP	IDLE		; Return BUSY code to MEX
DIAL10:
	CPI	8		; Call fail ?
	JZ	ERRET		; Return modem error code
	CPI	13		; Between 9 and 12 (inclusive) ?
	JNC	DLOOP		; Ignore 13 and above (13 = dial tone)
; At this point the match code from COMPR is between 9 and 12 inclusive.
;  Use this number as an offset into a table of messages, print the
;  appropriate message and continue to loop.
	SUI	9		; Now between 0 and 3
	RLC			; *2
	RLC			; *4
	RLC			; *8
	MVI	B,0
	MOV	C,A		; BC contain offset
	LXI	H,MSGS		; Point to messages table
	DAD	B		; Index into it
	XCHG			; Pointer to message into DE
	MVI	C,9		; Let mex to string print
	CALL	MEX
	LXI	D,COMSP		; Print ", "
	MVI	C,9
	CALL	MEX
	JMP	DLOOP		; And continue to loop


;
IDLE:
;
; Forces modem into idle state by sending "idle" command and
;  then toggling DTR using the user's DISCV entry.
; Preserves any return code that may be in register A.
;
	PUSH	PSW		; Preserve any return code
	LXI	H,IDLCMD	; Send abort character to modem
	CALL	CDSEND
	CALL	DISCV		; Make sure modem disconnects
	POP	PSW		; Retrieve return code
	RET

SENDCR:
;
; Sends a carriage return character to the modem.
;
	LXI	H,CRMSG		; Send <cr> to modem
	JMP	CDSEND


; Table of valid responses from modem
RSPTBL:
	DB	'IN',0		; Initiating
	DB	'BSY',0		; Busy
	DB	'NOA',0		; No answer
	DB	'OK',0		; Signon
	DB	'NOT',0		; No answer tone
	DB	'NOR',0		; No ring
	DB	'NDT',0		; No dial tone
	DB	'VDT',0		; Voice detected
	DB	'CFL',0		; Call failed
	DB	'DG',0		; Dialing
	DB	'RG',0		; Ringing
	DB	'AT',0		; Answer tone
	DB	'AR',0		; Answer
	DB	'DT',0		; Dial tone
	DB	0		; Table terminator

; Table of messages for some of the entries in the above table.
;  Each entry must be exactly eight characters including the "$".
MSGS:
	DB	'dialing$'
	DB	'ringing$'
	DB	'anstone$'
	DB	'answer$ '

COMSP:
	DB	', $'		; To delimit messages

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
CMPR02:
	PUSH	H		; Save pointer to string in question
CMPR05:
	LDAX	D		; Fetch char from table
	ORA	A		; Is it end of table entry ?
	JNZ	CMPR10		; Not end of entry
	POP	H
	RET			; Return with match code in B
CMPR10:
	CMP	M		; Same as char in string ?
	JNZ	CMPR15		; Jump if not this entry in table
	INX	H		; Else, point to next char in string
	INX	D		;  and next char in table entry
	JMP	CMPR05		; Check next char
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
	POP	H		; Point to original string again
	JNZ	CMPR02		; Go check next table entry
	MVI	B,255		; No match return code
	RET


CATCHR:
;
; Catch response from modem.
; Input:  C  delay allowed before timeout (multiples of 100ms)
; Output: Buffer (RESPBF) contains the string received from modem with
;	   any control characters filtered out.
;	  C  count of characters received before <cr>
;	  A  error code:  0 ==> normal return
;			  2 ==> time out occurred
;			  3 ==> user typed ^C
;
	LXI	H,RESPBF
	PUSH	H
	MVI	B,BUFLEN	; Length of character buffer
CRL10:
	MVI	M,0		; Fill buffer with zeros
	INX	H
	DCR	B
	JNZ	CRL10
	POP	H		; Get original pointer
	MVI	B,0		; Character counter
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
	CPI	CR		; End of line from modem ?
	JZ	EOL		; If <cr> then end of line
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
CDSEND:
	MVI	C,SNDRDY	; Get modem send status
	CALL	MEX
	JNZ	CDSEND		; Wait for modem ready
	MOV	A,M		; Get character
	INX	H		; Point to next character
	ORA	A		; Is this the terminator ?
	RZ			; If yes, done
	MOV	B,A		; Pass character in B
	MVI	C,SNDCHR	; Let MEX send to modem
	CALL	MEX
	JMP	CDSEND

;
NOTIMP:
	MVI	C,ILP
	CALL	MEX
	DB	'Not implemented'
	DB	' (CDS ARQ v'
	DB	(VERS / 10) + '0', '.', (VERS MOD 10) + '0'
	DB	')',CR,LF,0
JUSTRT:
	RET

;
; DATA AREA
;
; Wakeup string to put modem into "interactive DTE" mode
WAKEUP:	DB	CR,CR,'B',CR,0 ; String to wake up modem
IDLCMD:	DB	ESC,0		; Idle command
CRMSG:	DB	CR,0

DCMD:	DB	'DM'		; Dial command to modem
DIALBF:	DS	30		; Phone number buffer

BUFLEN	EQU	8		; Length of response buffer
RESPBF:	DS	BUFLEN		; Response from modem
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	ORG	SMTABL

	DW	JUSTRT		; Initialization
	DW	NOTIMP		; SSET
	DW	JUSTRT		; De-initialization

	END
