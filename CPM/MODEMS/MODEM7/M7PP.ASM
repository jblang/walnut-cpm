; M7PP.ASM -- Pied  Piper Overlay file for MEX/MDM7xx.  84/05/22

; This overlay allows for either use of the DUAL Serial Card or the
; Serial/Modem Card. Port A's are interrupt driven while the Port B
; on the Dual card and the modem of the modem/serial card are not.
;
; The interrupts and Buffering allow the RS-232 ports to communicate
; error free up to 9600 baud (the 8251 only goes to 9600).

mainver equ	2		; version 2 supports MEX overlay
vers	equ	1
year  	equ	84
month 	equ	06
day   	equ	15

TRUE	EQU	0FFh
FALSE   EQU	00

MEXOVL	EQU	false		; <---- TRUE IF USED WITH MEX
				;     FALSE IF USED WITH MDM7?0

;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7PP.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)

;       With MEX:
;
;		MLOAD MEX.COM=MEX??.COM,MXO-PP21

; = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = -

; History as a MEX overlay

; 15/06/84 - Finally got interrupt/buffering working error free at 9600, RCL
; 06/06/84 - VER 2.0 - Converted MDM overlay to be MEX/MDM compatible, RCL

; History as a MDM Overlay

; 30/05/84 - Added queue buffering for interrupt routine, Robert Lansdale
; 22/05/84 - Added interrupt routines to USART A          Robert Lansdale
; 09/05/84 - Converted M7GP-1.ASM to M7PP-1.ASM           Robert Lansdale
; 11/11/83 - Renamed to M7GP-1.ASM, no changes	 	  Irv Hoff
; 07/27/83 - Renamed to work with MDM712	 	  Irv Hoff
; 07/01/83 - Revised to work with MDM711	 	  Irv Hoff
; 07/01/83 - Revised to work with MDM710	 	  Irv Hoff
; 05/27/83 - Updated to work with MDM709	 	  Irv Hoff
; 05/15/83 - Revised to work with MDM708	 	  Irv Hoff
; 04/11/83 - Updated to work with MDM707	 	  Irv Hoff
; 04/04/83 - First version of this file		 	  Irv Hoff
;
; = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = -

	IF 	MEXOVL

; MEX service processor stuff

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

PRINT	EQU	9		;BDOS/MEX print-string function call

	ENDIF			;MEXOVL

BELL	EQU	07H		;bell
CR	EQU	0DH		;carriage return
ESC	EQU	1BH		;escape
LF	EQU	0AH		;linefeed

YES	EQU	0FFH
NO	EQU	0

	org	0100h

		DS	3	;for 3 byte jump instruction

PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	no	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES 	;Cursor control routine 		10CH
ACKNAK:		DB	no 	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	NO	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
					;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	no	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
		DS	2		;				128H
;
; The following table is over written by the SETBAUD routine upon initialization
; and is only here for address reference.

IN$MODCTL1:	IN	29H		; CONTROL PORT
		RET
		DS	7
otdata:		OUT	28H		; OUTPUT TO DATA PORT   
		RET
		DS	7
inport:		JMP	PORTAI		; INPUT FROM DATA PORT
		DS	7
maskr:		JMP	ANIRCB		; RCV READY MASK
testr:		JMP	CPIRCR		; RCV READY VALUE
masks:		JMP	ANISNB		; XMIT READY MASK
tests:		JMP	CPISNR		; XMIT READY VALUE

		DS	6

OUT$MODCTL1:	RET			;out modem control port #2	15AH
		DS	2
OUT$MODCTL2:	RET			;out modem control port #1	15DH
		DS	2

LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	3		;DIALV: not done here (maybe MXO-SM)162H
DISCV:		JMP	DISCON		;disconnect
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		NOP			; New Baud Rate			16EH
		NOP
		RET
		NOP  
		NOP			; Set no Parity			171H
		RET  
		NOP  
		NOP			; Set Parity			174H
		RET
	
JMP$SETUPR:	JMP	SETUPR		; following not used by MEX:	177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	sysver		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H

; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).

JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H

; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).

		IF	MEXOVL

CLREOS:		LXI	D,EOSMSG	;				195H
		MVI	C,PRINT
		CALL	MEX
		RET
;
CLRSCRN:	LXI	D,CLSMSG	;				19EH
		MVI	C,PRINT
		CALL	MEX
		RET

EOSMSG:		DB	07EH,018H,'$'
CLSMSG:		DB	07EH,01CH,'$'

	  	ENDIF

		IF 	NOT MEXOVL

CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	07EH,018H,0,0,0 ;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	07EH,01CH,0,0,0 ;				1A1H
		RET			;				1A6H
	
		ENDIF			; if NOT MEXOVL

SYSVER:		RET			; version number is provided by SETBAUD

SENDBRK:	RET

; Disconnect the modem

; if on onboard modem, bring onhook. Presently not configured for any
; particular type of modem. Future release may have this patched.

DISCON:	RET

; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	0

; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.

GOODBYE:CALL	FIXUP		; return interrupt vector to original condition
	RET

; Before exiting or entering SETUP, call FIXUP to install the original
; modem/DUAL serial card interrupt vector at FB0CH

FIXUP:	LDA	PORTID
	CPI	1
	RZ
	CPI	3
	RZ
	LHLD	INTSAVE			; reset interrupt vector
	SHLD	0FB0CH
	RET

; The following is called by the SET command

SETUPR:	CALL	SETBAUD
	RET

; Before doing any modem I/O, the following routine is called to
; initialize any modem related parameters - such as baud rate or
; which port is to be used in modeming.

INITMOD: CALL	SETBAUD
	 RET

; Routines specific to the Pied Piper's modem and serial card. The following
; code initializes these cards with info given by the user - such as baud
; rate,etc. Before MDM is started, Port A or port B may be selected. To
; re-select the baud rate, the program must be restarted.


PRTSTR  EQU     9       	; BDOS PRINT STRING
DIRIO   EQU     6       	; DIRECT CONSOLE I/O
INPUT   EQU     0FFH    	; DIRECT CONSOLE INPUT

AZERO   EQU     '0'-1     	; first ascii code that is LT zero
ASIX    EQU     '9'+1     	; FIRST ASCII CODE THAT IS GT NINE
BKSPACE EQU     8       	; BACKSPACE CODE

DECOFF  EQU     '0'     	; OFFSET TO CHANGE TO DECIMAL
NOTFOUND EQU    0FFH    	; INPUT ERROR, BAUDRATE NOT FOUND

TCNT    EQU     0B7H    	; TIMER CONTROL
PORT1   EQU     3BH     	; TIMER CONTROL PORT
CTR2   	EQU     3AH     	; COUNTER TWO
CTR1	EQU	39H		; COUNTER ONE
CTR0	EQU	38H		; COUNTER ZERO

COMMU	EQU	0FAF6H		; BIT 7 - 4 = 0101 -- MODEM CARD
				; BIT 7 - 4 = 1010 -- SERIAL CARD

SETBAUD:LXI	D,IDMSG			; PRINT OUT SIGNON MESSAGE
	MVI	C,PRTSTR
	CALL	BDOS
	LDA	COMMU			; CHECK IF SYSTEM HAS EXPANSION
	ANI	0F0H			; CARD CONFIGURED
	XRI	0F0H			; NOT ALLOW IF NOT
	JNZ	SYSCNF
	LXI	D,ERMSG
	MVI	C,PRTSTR
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	PSW
	JMP	0
SYSCNF:
         LXI	D,PORT              	; ASK FOR PORT TO USE
         MVI	C,PRTSTR
         CALL   BDOS

GETPOR:  MVI    C,DIRIO              	; DIRECT CONSOLE I/O
         MVI	E,INPUT              	; INPUT
         CALL   0005h

         ORA    A                     	; IF NO INPUT THEN GET ANOTHER INPUT
         JZ	GETPOR
	 ANI	07FH		      	; RES 7,A
	 CPI	3
	 JZ	0
	 ANI	05FH		      	; CHANGE TO UPPER CASE
	 CPI	'A'
	 JC	GETPOR			; ask again if char < A
         CPI     'E'
         JNC	GETPOR            	; GET ANOTHER INPUT if not A-D
ECOPOR:
         PUSH   PSW	                ; SAVE INPUT

         MOV	E,A                  	; ECHO INPUT STRING
         MVI	C,DIRIO              	; USE DIRECT CONSOLE I/O
         CALL   BDOS

         MVI	E,BKSPACE            	; BACKSPACE
         MVI	C,DIRIO              	; USING DIRECT CONSOLE I/O
         CALL   BDOS

        POP    PSW              	; GET SAVED INPUT
	SUI	'A'
	STA	PORTID			; SAVE PORT ID
	LDA	COMMU			; CHECK IF SERIAL CARD
	ANI	0F0H
	CPI	050H
	JNZ	GETBAU1			; ASK FOR BAUD RATE IF SERIAL CARD
	LDA	PORTID			; MODEM CARD, CHECK IF PORT B
	CPI	1
	JZ	INIVEC			; SKIP BAUD RATE SINCE 300 FIXED
	CPI	3
	JZ	GETBAU2			; Port B of Dual Serial is not 
					; interrupt driven, so skip

; ++++++++ install the new interrupt vectors for RS-232 USART A's +++++++++

GETBAU1:LHLD	0FB0CH		; save old interrupt vector for GOODBYE
	SHLD	INTSAVE
	LXI	H,INTR			; address of interrupt routine
	SHLD	0FB0CH			; and initialize the new interrupt vector
GETBAU2:MVI	A,0
	STA	buflen			; indicate no char waiting in queue

GETBAU:
         LXI	D,MESS              	; DISPLAY MESSAGE
         MVI	C,PRTSTR
         CALL   BDOS

READIN:  MVI	C,DIRIO              	; DIRECT CONSOLE I/O
         MVI	E,INPUT              	; INPUT
         CALL   BDOS

         ORA    A                    	; IF NO INPUT THEN GET ANOTHER INPUT
         JZ	READIN
	 ANI	07FH		     	; RES 7,A
	 CPI	3
	 JZ	0			; return if control C pressed
         CPI     AZERO                	; IF LESS THAN OR EQUAL TO ZERO
         JC     READIN             	; GET ANOTHER INPUT
         CPI     ASIX                 	; IF GREATER THAN NINE
         JNC     READIN            	; GET ANOTHER INPUT

         PUSH   PSW                   	; SAVE INPUT

         MOV	E,A                  	; ECHO INPUT STRING
         MVI	C,DIRIO              	; USE DIRECT CONSOLE I/O
         CALL   BDOS

         MVI    E,BKSPACE            	; BACKSPACE
         MVI    C,DIRIO              	; USING DIRECT CONSOLE I/O
         CALL   BDOS

         POP    PSW                   	; GET SAVED INPUT
         SUI    DECOFF               	; CHANGE TO DECIMAL 
         LXI	H,BDRATE             	; GET ADDRESS THAT STORES BAUDRATE BY
	 DB	0CBH		     	; Z80 'SLA A' instruction
	 DB	027H		     	; Multiplt input by two
         MOV	E,A                  	; STORE IN REG. E
         MVI	D,0                  	; CLEAR REG. D
         DAD	D                    	; GET ADDRESS FOR CORRECT BAUDRATE

         MOV     E,M	            	; GET REQUIRED BAUDRATE
         INX     H                  	; GET BAUDRATE IN REG. PAIRS DE
         MOV     D,M
;
;	IF SERIAL CARD AND PORT A - INIT CTR 1 AND CTR 0
;	IF SERIAL CARD AND PORT B - INIT CTR 2
;	IF MODEM CARD AND PORT A - INIT CTR0

	LDA	PORTID			; GET PORT SELECTED
	CPI	00
	JZ	OK
	CPI	2
	JNZ	SETB

OK:	MVI	A,00110111B           	; SELECT COUNTER 0
	OUT    PORT1               	; SEND TO CONTROL PORT

        MOV     A,E                   	; GET BAUDRATE AND SEND TO COUNTER
        OUT    CTR0
        MOV     A,D
        OUT    CTR0

CONT:	LDA	COMMU			; CHECK IF MODEM CARD
	ANI	0F0H
	CPI	050H			; SKIP  AND SET UP VECTORS
	JZ	INIVEC
	MVI	A,01110111B		; SELECT COUNTER 1
	OUT	PORT1
	MOV	A,E
	OUT	CTR1
	MOV	A,D
	OUT	CTR1
	JMP	INIVEC
SETB:
	MVI	A,10110111B		; SELECT COUNTER 2
	OUT	PORT1
	MOV	A,E
	OUT	CTR2
	MOV	A,D
	OUT	CTR2
;
;	SET UP INSTAT, OUTSTA, INDATA, OUTDAT VECTORS
;
INIVEC:	LXI	H,PORTBV		; POINT TO PORT B VECTORS
	LDA	PORTID
	CPI	3
	JZ	SETVEC			; DUAL B not interrupt driven
	CPI	1
	JZ	SETVEC			; Select Onboard Modem port
	LXI	H,PORTAV		; POINT TO PORT A VECTORS
SETVEC:	LXI	D,IN$MODCTL1
	LXI	B,42
	DB	0EDH			; Z80 LDIR instruction
	DB	0B0H
	
MDMIRT:  LXI	D,CRLF              	; DISPLAY CRLF
         MVI	C,PRTSTR
         CALL   BDOS

	 IF	MEXOVL
	 LXI	D,CRLF
	 MVI	C,PRTSTR
	 CALL	BDOS
	 ENDIF

	 mvi	a,0
	 sta	new
	 sta	old
	 sta	buflen
	 RET

BDOS:	IF	MEXOVL
	JMP	MEX
	ENDIF

	IF 	NOT MEXOVL
	JMP	0005h 
	ENDIF


; RS-232 USART interrupt routine (Port B's have no interrupts)

INTR:    di			; stop USART from interrupting us!
	 DB	0EDH		; LD (STKSAV),SP
	 DB	073H
	 dw	stksav
	 lxi	sp,stack
         push	psw
	 push	d
	 push	h
	 lda	buflen		; how many characters are in the queue?
	 cpi	length		; is buffer full?
	 jnz	notdone
	 call	input1		; clear the RxRDY interrupt line
	 jmp	rtn

notdone: inr	a		; add another character to the queue
	 sta	buflen
	 lxi	h,buffer

	 lda	new		; get current position
	 mov	e,a
	 mvi	d,0
	 inr	a
	 cpi	length		; are we at end of the queue?
	 jnz	nol
	 mvi	a,0
nol:	 sta	new		; store away for next retreival
	 dad	d
	 call	input1
	 mov	m,a
rtn:	 pop	h
	 pop	d
	 pop	psw
	 DB	0EDH
	 DB	07BH
	 DW	STKSAV
         ei			; and let USART B interrupt us some more
         ret    

input1:	 lda	portid
	 cpi	3		; is port Dual Serial Port board Port B?
	 jnz	inprta		; no, go input normally
	 in	02ah		; get serial Port B input
	 ret

inprta:	 IN	028H		; get data from RS-232 USART
	 ret

;    ----------- PORT A I/O ROUTINES --------------

ANISNB:	RET

CPISNR:	LDA	PORTID
	CPI	3
	JNZ	IN29
	IN	02BH			; get serial Port B input
	JP	CHECK

IN29:	IN	29H

CHECK:	ANI	01
	CPI	01
	RET

ANIRCB:	RET

CPIRCR:	LDA	buflen
	CPI	0		; is data waiting?
	jz	yes0
	mvi	a,0		; ret with zero set
	ora	a
	ret
yes0:	mvi	a,0ffh		; ret with zero not set
	ora	a
	ret

PORTAI:	push	h
	push	d
	lda	buflen
	cpi	0
	jz	nochar
	lxi	h,buflen	; *** Because the INTR routine is running in
	db	035h		; INC (HL) - the background we must dec the
				; buffer count in one instruction to prevent
				; the intr routine from inc. the buffer counter
				; while we are accessing buflen.

	lda	old		; get old position within the queue
	mov	e,a
	mvi	d,0
	lxi	h,buffer
	dad	d
	inr	a
	cpi	length
	jnz	nol2
	mvi	a,0
nol2:	sta	old
	mov	a,m
	pop	d
	pop	h 
	ret

nochar: mvi	a,0
	ret

;     ------- End of PORT A SERIAL Routines --------------

; 300 baud modem I/O jumps (or Dual Card's Port B Serial RS-232 Port B)

PORTBV:	IN	02BH		; CONTROL PORT
	RET
	DS	7
	OUT	2AH		; OUTPUT TO DATA PORT
	RET
	DS	7
	IN	2AH		; INPUT FROM DATA PORT
	RET
	DS	7
	ANI	02		; RCV READY MASK
	RET
	CPI	02		; RCV READY VALUE
	RET
	ANI	01		; XMIT READY MASK
	RET
	CPI	01		; XMIT READY VALUE
	RET

; Serial I/O jumps

PORTAV:	IN	29H		; CONTROL PORT
	RET
	DS	7
	OUT	28H		; OUTPUT TO DATA PORT   ***** not for DUAL B
	RET
	DS	7
	JMP	PORTAI		; INPUT FROM DATA PORT
	DS	7
	JMP	ANIRCB		; RCV READY MASK
	JMP	CPIRCR		; RCV READY VALUE
	JMP	ANISNB		; XMIT READY MASK
	JMP	CPISNR		; XMIT READY VALUE

IDMSG:	DB	CR,LF
	DB	'Installed for STM Pied Piper  (Beta Rel. '
	db	mainver+'0',' vers ',vers/10+'0','.',vers mod 10+'0'
	db	' - ',month/10+'0',month mod 10+'0','/',day/10+'0'
	db	day mod 10 +'0','/',year/10+'0'
	db	year mod 10 +'0',')'
	db '$' 

ERMSG:	DB	CR,LF,LF
	DB	'No expansion card configured on current system,'
	DB	CR,LF,'please run CONFIG.COM release 2.02 or later.'
	db 	'$' 

PORT:	DB	CR,LF,LF
	DB	'Select Port to use:...',cr,lf,LF
	DB	'   A. Interrupt driven Serial Port A of Modem Card.',cr,lf
	DB	'   B. 300 Baud Modem of Modem Card..',cr,lf
	DB	'   C. Interrupt driven Port A of Dual Serial Card..',cr,lf
	DB	'   D. Port B of Dual Serial Card..',cr,lf,lf
        DB     	'Enter selection: '
	db 	'$' 

MESS:	DB	 CR,lF,LF
        DB     'Baud rate selection:...'
	DB	CR,LF
        DB     	CR,LF,'   0.   110 BAUD..'
	DB	CR,LF,'   1.   150 BAUD..'
        DB     	CR,LF,'   2.   300 BAUD..'
	DB	CR,LF,'   3.   450 BAUD..'
	DB	CR,LF,'   4.   600 BAUD..'
        DB     	CR,LF,'   5.  1200 BAUD..'
        DB     	CR,LF,'   6.  2400 BAUD..'
        DB     	CR,LF,'   7.  4800 BAUD..'
        DB     	CR,LF,'   8.  7200 BAUD..'
        DB     	CR,LF,'   9.  9600 BAUD..'
        DB     	CR,LF,LF,'Enter selection: '
	db 	'$' 

CRLF:		DB	CR,LF
		db 	'$' 

; To select the baudrate, BCD = 2,000,000/16/baudrate

; PLACE TO STORE BAUDRATE

BDRATE: DW	01136H			; 110 baud
	DW	0833H			; 150 baud
	DW     	0417H                   ; 300  baud
	DW	0278H			; 450  baud  
	DW	0208H			; 600  baud
        DW     	0104H			; 1200 baud
        DW     	0052H			; 2400 baud
        DW     	0026H			; 4800 baud
	DW	0017H			; 7200 baud
        DW     	0013H			; 9600 baud

portid:	db	00		; which port the user has picked (0-3)

intsave:dw	0000		; old interrupt vector storage

stksav:	dw	0000		; interrupt routine stack save storage

new:	db	00		; next location for input character

old:	db	00		; next location to get character FROM
 
buflen:	db	00		; # of characters presently in the queue

length	equ	0FEH		; length of the interrupt buffer

buffer:	ds	length		; 10 character interrupt character buffer

	ds	60H		; stack space (could be 20, but who cares really?)

stack	equ	$-1

SPCLMENU:  RET

; NOTE:  MUST TERMINATE PRIOR TO 0B00H  to be used with smartmodem.

	 END

