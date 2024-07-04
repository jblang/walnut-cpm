 TITLE	'MEX Overlay for Apple ][ / SSC / Smartmodem'
;
;  MXH-AP55.ASM
;
REV	EQU	55		; 3 May 1987
;
; This overlay is specific for the following hardware:
;
;	Apple ][ +/e  with PCPI Applicard
;	Apple Super Serial Card
;
; Important Note:
;	Rev 5.5 introduces the Interrupt/Buffer concept.  This requires
; the use of an Applicard driver, in this case RINGBUF.DVR.  Operation
; in this mode eliminates the infamous character loss on scroll problem
; up to 2400 baud. SET INTerrupt control has been added to this official
; release to allow bypassing the INT mode if the INT/Buffer is found to
; be buggy or as I found, I had two SuperSerial cards in, 1 with and 1 w/0
; interrupts and this was a problem. (By the way I used the 2nd card for
; a network I/O). In any event, it's handy have the set feature and the
; default can be CLONEed in.			   -Jim
;------------------------------------------------------------------
; REVISION HISTORY:
;------+---------+----------------+--------------------------------
; Rev. |  Date	 |     Author	  |	  Description
;------+---------+----------------+--------------------------------
; 5.5  | 3 May 87| Bob Sass/	  | - added support for RINGBUF.DVR
;      |	 |	Jim Lill  |   See note above, Tested with //e
;------+---------+----------------+--------------------------------
; 5.4  |16 Apr 87| Jim Lill	  | -speeded up calls to the Modem
;      |	 |		  |  Port by recoding PEEK and POKE and
;      |	 |		  |  changing CALLs to JMPs. Picked
;      |	 |		  |  up 19 bytes.
;------------------------------------------------------------------
; 5.3  |13 Dec 86| Jim Lill	  | -added SET WAIT code for use with
;      |	 |		  |  MXO-SM14 and cleaned up SET displays
;------+---------+----------------+--------------------------------
; 5.2  | 1 Nov 86| Jim Lill	  | -eliminated Modem specific section
;      |	 |		  |  requires use of Modem overlay
;      |	 |		  |  such as MXO-SM14 or MXM-2413
;      |	 |		  |  This seems to solve a timing problem
;      |	 |		  |  that occurred when loading 2413
;      |	 |		  |  over AP51
;------+---------+----------------+--------------------------------
; 5.1  | 5 Apr 86| Jim Lill	  | -changed CLSMSG and EOSMSG
;      |	 |		  | -added INITBAUD equate for setting
;      |	 |		  |  MSPEED and baud in INITPORT
;------+---------+----------------+--------------------------------
; 5.0  |1 Apr 86 | Jim Lill	  | created adaption, includes DCD
;      |	 |		  | and a spot for RNG detect.
;------+---------+----------------+--------------------------------
; IMPORTANT NOTE:
;    This overlay is based on MXO-AP50.ASM by Henry Middlebrook
;    Refer to it for additional info. The changes in this overlay
;    could be easily adapted to other Middlebrook work like AP34
;    To find changes, search for "MEXplus"
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

YES		EQU	0FFH
NO		EQU	0

;---------------------------------------------------------------------
; Options....

INITBAUD	EQU	5	;Initial Baud Rate
				; 0=110   5=1200
				; 1=300   6=2400
				;   450   7=4800
				; 3=610   8=9600
				; 4=710   9=19200
Z80XTAL		EQU	73	;set to Z80 CPU crystal MHz
				;times correction factor
				;e.g: 6Mhz * 12.16666= 73
WAIT		EQU	YES	;set to YES if you use the
				;SET WAIT command and MXO-SM14 etc
WAITSEC		EQU	45	;default wait time
;---------------------------------------------------------------------
BELL		EQU	07H	;bell
CR		EQU	0DH	;carriage return
ESC		EQU	1BH	;escape
LF		EQU	0AH	;linefeed
TAB		EQU	09H	;tab
;
;----------------------------------------------------------------------
;	Apple Super Serial Card equates
;	-------------------------------
;
SSCSLOT		EQU	2			;Slot of Super Serial Card
MODDATP		EQU	0C088H + (SSCSLOT*10H)	;data port of ACIA
MODSTAP		EQU	0C089H + (SSCSLOT*10H)	;status port of ACIA
MODCTLP		EQU	0C08BH + (SSCSLOT*10H)	;control port of ACIA
MODCMDP		EQU	0C08AH + (SSCSLOT*10H)	;command port of ACIA
;
;
RDBYTE		EQU	0FFE0H	;Read a Byte from Apple (A = BYTE)
WRBYTE		EQU	0FFE3H	;Write a Byte to Apple (C = BYTE)
RDWORD		EQU	0FFE6H	;Read 2 Bytes from Apple (DE = BYTES)
WRWORD		EQU	0FFE9H	;Write 2 Bytes to Apple (DE = BYTES)
RDNBYTS		EQU	0FFECH	;Read N Bytes (DE = COUNT, HL = BUFFER)
WRNBYTS		EQU	0FFEFH	;Write N Bytes (DE = COUNT, HL = BUFFER)
;
PEEK1BYTE	EQU	6	;Command to Peek 1 Byte in the Apple
POKE1BYTE	EQU	7	;Command to Poke 1 Byte to the Apple
;
; New DCD routine equate MEXplus
;
CTSMSK		EQU	00100000B	;mask to test for carrier
;
; Status bit equates for SSC serial port
;
MDSNDB		EQU	10H
MDSNDR		EQU	10H
MDRCVB		EQU	08H
MDRCVR		EQU	08H
;
; Equates for PSW (Parity, Stop Bit, Word Length) used by SSC ACIA
;  In these bytes the high nibble is the Word Length mask, the low
;  nibble is the Parity mask for the ACIA PSWFIX routine.
;
P8N1		EQU	010H	;8 NONE 1
P7E1		EQU	036H	;7 EVEN 1
P7O1		EQU	032H	;7 ODD 1
P7N1		EQU	030H	;7 NONE 1
;
BRKMSK		EQU	0CH	;mask byte for BREAK function
DISCB		EQU	0AH	;command byte for ACIA to drop DTR
;
;----------------------------------------------------------------------
;
;	MEX Service Processor Calls
;
MEX	EQU	0D00H	;address of the service processor
INMDM	EQU	255	;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254	;delay 100ms * reg B
TMDINP	EQU	253	;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252	;check for ^C from KBD, Z=present
SNDRDY	EQU	251	;test for modem-send ready
RCVRDY	EQU	250	;test for modem-receive ready
SNDCHR	EQU	249	;send a character to the modem (after sndrdy)
RCVCHR	EQU	248	;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247	;table search: see CMDTBL comments for info
PARSFN	EQU	246	;parse filename from input stream
BDPARS	EQU	245	;parse baud-rate from input stream
SBLANK	EQU	244	;scan input stream to next non-blank
EVALA	EQU	243	;evaluate numeric from input stream
LKAHED	EQU	242	;get nxt char w/o removing from input
GNC	EQU	241	;get char from input, cy=1 if none
ILP	EQU	240	;inline print
DECOUT	EQU	239	;decimal output
PRBAUD	EQU	238	;print baud rate
PRNTBL	EQU	237	;print command table in columns (HL=addr)
PRID	EQU	236	;print MEX ID string on console
;
CONOUT	EQU	2	;simulated BDOS function 2: console char out
PRINT	EQU	9	;simulated BDOS function 9: print string
INBUF	EQU	10	;input buffer, same structure as BDOS 10
;
;
;======================================================================
;
	ORG	100H	;we begin
;
; changed jumps for MEXplus
;
	DB	0C3H	;flags a LOADable file (for 8080)
	DS	2	;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	YES	;\ / These two locations are			103H
SMODEM:	DB	NO	;/ \ not referenced by MEX.			104H
TPULSE:	DB	'T'	;Tone/Pulse (used only in Smodem overlay)	105H
CLOCK:	DB	Z80XTAL	;CPU speed					106H
MSPEED:	DB	INITBAUD;sets display time for sending a file		107H
			;uses INITBAUD equate, changes during
			;use via PBAUD routine
BYTDLY:	DB	1	;default time to send character in		108H
			;terminal mode file transfer (0-9)
			;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	1	;end-of-line delay in terminal			109H
			;mode file transfer for slow BBS systems
			;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5	;number of directory columns			10AH
SETFL:	DB	YES	;yes=user-defined SET command			10BH
SCRTST:	DB	YES	;yes=if home cursor and clear screen		10CH
			;routine at CLRSCRN
	DB	0	;was once ACKNAK, now spare			10DH
BAKFLG:	DB	NO	;yes=make .BAK file				10EH
CRCDFL:	DB	YES	;yes=default to CRC checking			10FH
			;no=default to Checksum checking
TOGCRC:	DB	YES	;yes=allow toggling of Checksum to CRC		110H
CVTBS:	DB	NO	;yes=convert backspace to rub			111H
TOGLBK:	DB	YES	;yes=allow toggling of bksp to rub		112H
ADDLF:	DB	NO	;no=no LF after CR to send file in		113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR		114H
TRNLOG:	DB	NO	;yes=allow transmission of logon		115H
			;write logon sequence at location LOGON
SAVCCP:	DB	YES	;yes=do not overwrite CCP			116H
LOCNXT:	DB	NO	;yes=local cmd if EXTCHR precedes		117H
			;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES	;yes=allow toggling of LOCNXTCHR		118H
LSTTST:	DB	YES	;yes=allow toggling of printer on/off		119H
			;in terminal mode. Set to no if using
			;the printer port for the modem
XOFTST:	DB	YES	;yes=allow testing of XOFF from remote		11AH
			;while sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after sending CR while	11BH
			;transmitting a file in terminal mode
TOGXOF:	DB	YES	;yes=allow toggling of XOFF testing		11CH
IGNCTL:	DB	NO	;yes=do not send control characters		11DH
			;above CTL-M to CRT in terminal mode
			;no=send any incoming CTL-char to CRT
EXTRA1:	DB	WAITSEC	;passes wait time to modem overlay
EXTRA2:	DB	0	;for future expansion				11FH
BRKCHR:	DB	'@'-40H	;^@ = Send a 300 ms. break tone 		120H
NOCONN:	DB	'N'-40H	;^N = Disconnect from phone line		121H
LOGCHR:	DB	'L'-40H	;^L = Send logon				122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer				123H
UNSVCH:	DB	'R'-40H	;^R = Close input text buffer			124H
TRNCHR:	DB	'T'-40H	;^T = Transmit file to remote			125H
SAVCHR:	DB	'Y'-40H	;^Y = Open input text buffer			126H
EXTCHR:	DB	'^'-40H	;^^ = Send next character			127H
;
	DS	2	;unused in this overlay
;
; Jump table accessed by MEX to write/read serial port
;
IN$MODSTAP:	JMP	RD$MODSTAP	;read ACIA status port		12AH
		DS	7
OUT$MODDATP:	JMP	WR$MODDATP	;send character to ACIA 	134H
		DS	7
IN$MODDATP:	JMP	RD$MODDATP	;read character from ACIA	13EH
		DS	7
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
;---------------------------------------------------------------------------
; MEXplus changes:
;  - was unused area. >>> MUST total 12bytes <<<
;  - now used for the Ringing and Carrier Detect jumps
;
DCDTEST:	JMP	DCDVEC		;jump to carrier-detect routine 154H
RNGTEST:	JMP	RNGVEC		;jump to ring detect routine	157H
					;
		DS	6		;remainder of space
;
;---------------------------------------------------------------------------
;
LOGON:		DS	2		;not used by MEX		160H
DIALV:		DS	3		;used by Modem overlay		162H
DISCV:		JMP	DISCON		;drops DTR to hang-up fast!	165H
GOODBV:		JMP	GOODBYE		;called before exit to CPM	168H
INMODV:		JMP	INITPORT	;go to user written routine	16BH
NEWBDV:		JMP	PBAUD		;changes baud with phone #	16EH
NOPARV:		RET  !	NOP  !	NOP	;set modem for no-parity	171H
PARITV:		RET  !	NOP  !	NOP	;set modem parity		174H
SETUPV:		JMP	SETCMD		;				177H
SPMENV:		DS	3		;not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SENDBRK		;				180H
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:		DS	3	;replace with MEX function 9		183H
INBUFV:		DS	3	;replace with MEX functin 10		186H
ILCMPV:		DS	3	;replace with table lookup funct 247	189H
INMDMV:		DS	3	;replace with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX			18FH
TIMERV:		DS	3	;replace with MEX function 254		192H
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
;
CLREOS:		LXI	D,EOSMSG	;				195H
		MVI	C,PRINT
		CALL	MEX
		RET
;
CLS:		LXI	D,CLSMSG	;				19EH
		MVI	C,PRINT
		CALL	MEX
		RET
;
;		*** END OF FIXED FORMAT AREA ***
;--------------------------------------------------------------------------
; Make sure MEXplus has all of its' reserved area..
;
		ORG	0200H

;--------------------------------------------------------------------------
;		Overlay  Fixed	Messages  Area
;
; these codes changed to match PCPI CONFIGSV values for Televideo 950
;
;
EOSMSG:	DB	ESC,89,0,0,'$'		;clear to end of screen message
;
CLSMSG:	DB	ESC,42,0,0,'$'		;clear screen message
;
VERMSG:	DB	CR,LF,'MEX for Apple ][ / PCPI / SSC',CR,LF
	DB	' Version: ',REV/10+'0','.'
	DB	REV MOD	10+'0'
	DB	CR,LF,LF,'$'
	DB	0,'Overlay by Middlebrook/Lill',0,'$'
;
;----------------------------------------------------------------------
; These routines are specific to the Apple ][+ with Applicard.	The
; routines read modem hardware (Apple Super Serial Card ACIA) directly
; from the Applicard.
;
; Read the Command Port of ACIA
;
RD$MODCMDP:	PUSH	D
		LXI	D,MODCMDP
		JMP	PEEK
;
; Write to the Command Port of ACIA
;
WR$MODCMDP:	PUSH	D
		LXI	D,MODCMDP
		JMP	POKE
;
; Write to the Control Port of the ACIA
;
WR$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		JMP	POKE
;
; Read the Control Port of the ACIA
;
RD$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		JMP	PEEK

;.................................
;
; Read Data Port of ACIA
;

RD$MODDATP:
		LDA	INTFLG		;get the INT flag
		ORA	A		;test it
		JZ	NONINTDATP	;it not set jump to non-irq read
INTDATP:	PUSH	B		;
		MVI	C,0F1H		;Device 28 (read)
		CALL	WRBYTE
		CALL	RDBYTE
		POP	B
		RET

NONINTDATP:	PUSH	D		;non-irq read
		LXI	D,MODDATP
		JMP	PEEK
;.................................
;
; Read the Status Port of the ACIA
;
RD$MODSTAP:
		LDA	INTFLG		;see if in INT mode
		ORA	A		;
		JZ	NONINTSTAP	;if not use non-INT

INTSTAP:	PUSH	B		;INT method
		MVI	C,0F3H		;Device 28 (other)
		CALL	WRBYTE
		MVI	C,1
		CALL	WRBYTE
		CALL	RDBYTE
		POP	B
		RET

NONINTSTAP:	PUSH	D		;non-INT method
		LXI	D,MODSTAP
		JMP	PEEK
;...............................
;
; Write to the Serial Data Port of the ACIA
;
WR$MODDATP:	PUSH	D
		LXI	D,MODDATP
		JMP	POKE
;.............................
;
; Peek at 1 byte from Apple 6502 address space
; ENTRY: DE = Address in Apple
; EXIT: A = Data
;
PEEK:	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	POP	D
	RET
;
; Poke 1 byte to Apple 6502 address space
; ENTRY: DE = Address in Apple
; EXIT: A = Data
;
POKE:	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	POP	D
	RET
;
;----------------------------------------------------------------------
; The new stuff for MEXplus
;
; Data Carrier Detect Routine
;
DCDVEC:		CALL	RD$MODSTAP	;read SSC status port
		ANI	CTSMSK		;isolate carrier bit
		JNZ	NOCARR		;0=carrier detected
		CMA			;make it 0ffh
		RET			;
NOCARR:		XRA	A		;make it 0
		RET			;
;
; Ring Detect Routine
;
RNGVEC:		JMP	DCDVEC		;overlay doesn't know
;
;----------------------------------------------------------------------
;
; This routine sends a timed Break to modem from SSC card.
;
SENDBRK:CALL	RD$MODCMDP	;get current command status
	STA	CMDSV
	ORI	BRKMSK		;mask to make ACIA send BREAK
	CALL	WR$MODCMDP	;send command
	MVI	B,5
	MVI	C,TIMER		;wait 500 msecs
	CALL	MEX
	LDA	CMDSV		;get old command state
	JMP	WR$MODCMDP	;put it back
;
;.....

; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect when exiting to CPM.
;
GOODBYE:
	LDA	INTFLG		;get the INT flag
	ORA	A		;is it set?
	JZ	BYE		;jump if not
	CALL	INTOFF
BYE:	RET
;................................
;
;  Turn off 6502 interrupts.
;
INTOFF:	MVI	C,0F3H		;Device 28 (other)
	CALL	WRBYTE
	MVI	C,20
	CALL	WRBYTE
	CALL	RDBYTE
	RET
;.................................
;
;  Turn On 6502 Interrupts
;
INTON:	MVI	C,0F3H		;Device 28 (other)
	CALL	WRBYTE
	MVI	C,21
	CALL	WRBYTE
	CALL	RDBYTE
	RET
;.....
;
INITPORT:			;set up the default port conditions

; The following is used to initialize memory locations to eight data bits,
; no parity, one stop bit, and baud=INITBAUD

	LDA	INTFLG		;get the INT flag
	ORA	A		;test it
	JZ	SETIT		;go set-up for non-INT

	MVI	A,09H		;no parity, w/INT
	JMP	SETIT		;go do it

NONINT:	MVI	A,0BH		;no parity, w/o INT

SETIT:	STA	PARSV		;save it
	MVI	A,10H		;default 8 Data, 1 Stop Bits for ACIA
	STA	WRDSV		;save it
	MVI	A,INITBAUD	;set to initial baud equate
	JMP	PBAUD		;let PBAUD setup ACIA (PBAUD will call
				;CHNGPORT below to actually setup ACIA)
;..............................
;
; This is the secondary entry used by the overlay to set baud,
; parity, and stop bit parameters of ACIA.
;
CHNGPORT:
	LDA	INTFLG		;get the INT flag
	ORA	A		;test it
	JZ	NOTINT		;go do non-INT stuff
	CALL	INTON		;turn int on
	LDA	PARSV		;get current parity byte
	ORI	09H		;req'd for int
	JMP	DOIT		;go set up w/int
NOTINT:	CALL	INTOFF		;turn int off
	LDA	PARSV		;get current parity byte
	ORI	0BH		;w/o int
DOIT:	STA	CMDSV		;save byte for other uses
	CALL	WR$MODCMDP	;send to command port
	PUSH	H
	LXI	H,BAUDSV
	LDA	WRDSV
	ORA	M
	STA	CTLSV		;...and save for other uses
	POP	H
	JMP	WR$MODCTLP	;now send to control port
;
CMDSV:	DB	0		;temporary storage
CTLSV:	DB	0		;temporary storage
;
;.....
;
; This routine drops DTR to force modem to disconnect.	Does NOT do
; any initialization.
;
DISCON:	CALL	RD$MODCMDP	;get current command status
	STA	CMDSV		;save it
	MVI	A,DISCB		;get disconnect byte (drops DTR)
	CALL	WR$MODCMDP	;send to ACIA
	MVI	B,10
	MVI	C,TIMER		;wait 1 second
	CALL	MEX
	LDA	CMDSV		;get back command status
	CALL	WR$MODCMDP	;put it back in ACIA register
	MVI	B,10
	MVI	C,TIMER		;wait another second
	JMP	MEX
;.....
;
; This routine changes the modem baud rate with phone list entry
;
; Set baud-rate code in A (if supported by your modem overlay).  PMMI
; supports only five rates, which are validated here. NOTE: this routine
; (ie, the one vectored through NEWBDV) should update MSPEED with the
; passed code, but ONLY if that rate is supported by the hardware.
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	A,M		;fetch code
	ORA	A		;0 means unsupported code
	JZ	PBEXIT		;exit if so
	STA	BAUDSV		;good rate, save it for CHNGPORT
	CALL	CHNGPORT	;set baud (and PSW)
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
	JMP	PBEXIT + 1	;jump error flag set
PBEXIT:	STC			;set return error for STBAUD caller
	POP	B		;all done
	POP	D
	POP	H
	RET
;
; Table of baud rate parameters for supported rates
;
BAUDSV:	DB	0			;current baud byte
BAUDTB:	DB	03H,06H,0,07H,0		;110,300,450,610,710
	DB	08H,0AH,0CH,0EH,0FH	;1200,2400,4800,9600,19200
;.....
;
; Sign-on message
;
SYSVER:	LXI	D,VERMSG
	MVI	C,PRINT
	JMP	MEX
;.....
;
; Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		;align output character
	MVI	C,CONOUT	;print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
;----------------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile SET command
; -- if you prefer not to write a SET for your modem, you may delete the
; code from here to the END statement. Control is passed here after
; MEX parses a SET command.
;
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse command
	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	JMP	MEX
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.
;
; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'WP','S'+80H		;"set PSW"
	DW	STPSW
	DB	'TON','E'+80H		;'set TONE/PULSE byte to 'T'
	DW	STTONE
	DB	'PULS','E'+80H		;'set TONE/PULSE byte to 'P'
	DW	STPULSE
	DB	'WAI','T'+80H		;'set WAIT'
	DW	SETDLY
	DB	'IN','T'+80H		;'set INT'
	DW	SETINT
	DB	0			;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	LXI	H,SHOTBL	;get table of SHOW subroutines
SETSLP:	MOV	E,M		;get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		;end of table?
	ORA	E
	RZ			;exit if so
	PUSH	H		;save table pointer
	XCHG			;adrs to HL
	CALL	GOHL		;do it
	CALL	CRLF		;print newline
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
; Table of SHOW subroutines
;
SHOTBL:
	DW	BDSHOW		;displays current baud
	DW	PSWSHOW		;displays current PSW
	DW	TPSHOW		;displays current TPULSE byte (0105H)
	DW	DLYSHO		;displays current wait time
	DW	INTSHO		;displays current INT status
	DW	CRLF
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	CALL	CLS			;clear screen
	LXI	D,HLPMSG
	MVI	C,PRINT
	JMP	MEX
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET Commands available are:',CR,LF,LF
	DB	'SET BAUD  <110, 300, 600, 1200, 2400, 4800,'
	DB	' 9600, or 19200>',CR,LF
	DB	'SET WPS   <8N1, 7E1, 7O1, or 7N1> -- Word Length,'
	DB	' Parity, Stop Bits',CR,LF
	DB	'SET TONE  (Sets flag for TONE  dialing)',CR,LF
	DB	'SET PULSE (Sets flag for PULSE dialing)',CR,LF
IF WAIT
	DB	'SET WAIT "n" Seconds for Modem Result',CR,LF
ENDIF

	DB	'SET INTerrupts <ON> or <OFF>',CR,LF
	DB	CR,LF,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX
	JC	SETERR		;invalid code
	CALL	PBAUD		;try to set it
	JC	SETERR		;unsupported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'BAUD:',TAB,TAB,TAB,0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	JMP	MEX
;
; SET PSW processor
;
STPSW:	MVI	C,SBLANK
	CALL	MEX
	JC	SETERR		;SET PSW should have had argument
	LXI	D,PSWTBL	;look for PSW match in table
	CALL	TSRCH
	JC	SETERR		;not there, so report error
	CALL	FIXPSW		;routine to set PARSV and WRDSV
	CALL	CHNGPORT	;now fix ACIA registers
;
PSWSHOW:
	CALL	ILPRT
	DB	'(W)ord(P)arity(S)top:',TAB,0
	LDA	PSWSET
	CPI	P8N1
	JNZ	PSW1
	CALL	ILPRT
	DB	'8N1',0
	RET
PSW1:	CPI	P7E1
	JNZ	PSW2
	CALL	ILPRT
	DB	'7E1',0
	RET
PSW2:	CPI	P7O1
	JNZ	PSW3
	CALL	ILPRT
	DB	'7O1',0
	RET
PSW3:	CPI	P7N1
	JNZ	PSW4
	CALL	ILPRT
	DB	'7N1',0
	RET
PSW4:	CALL	ILPRT
	DB	'<< ERROR >>',0
	RET
;
;
PSWSET:	DB	010H		;storage and default (8N1)
PARSV:	DB	0BH		;storage and default (no parity)
WRDSV:	DB	010H		;storage and default (8 data, 1 stop bits)
;
FIXPSW:	MOV	A,L		;PSW byte from table
	STA	PSWSET		;save it
	ANI	0F0H		;mask for word length bits
	STA	WRDSV		;put in storage
	LDA	PSWSET		;get back PSW byte
	ANI	0FH		;mask for parity bits
	RLC			;first shift into upper nibble..
	RLC			;...away we go...
	RLC			;.....and go...
	RLC			;......and done
	ORI	0BH		;mask needed for ACIA command register
	STA	PARSV		;put in storage
	RET
;
PSWTBL:	DB	'8N','1'+80H
	DW	P8N1		;filled in with equ's
	DB	'7E','1'+80H
	DW	P7E1		; - ditto -
	DB	'7O','1'+80H
	DW	P7O1		; - ditto -
	DB	'7N','1'+80H
	DW	P7N1		; - ditto -
	DB	0		;<<==== table terminator
;
;.....
;
; These routines set TPULSE flag at 0105H to either 'T' or 'P' so that
; MODEM (specifically MXO-SM13.ASM) overlay will dial in TONE or PULSE
; mode.  The settings are mutually exclusive.
;
STTONE:	MVI	A,'T'		;get T flag
	STA	TPULSE		;put into proper place
	JMP	TPSHOW		;display dial mode
;
STPULSE:
	MVI	A,'P'		;get P flag
	STA	TPULSE
;
TPSHOW:	CALL	ILPRT
	DB	'DIAL:',TAB,TAB,TAB,0
	LDA	TPULSE
	CPI	'T'
	JNZ	TP1
	CALL	ILPRT
	DB	'Tone',0
	RET
TP1:	CPI	'P'
	JNZ	TP2
	CALL	ILPRT
	DB	'Pulse',0
	RET
TP2:	CALL	ILPRT
	DB	'<< ERROR >>',0
	RET
;
;-------------------------------------------------
; SET WAIT processor

IF WAIT

SETDLY:	MVI	C,EVALA
	CALL	MEX
	MOV	A,H
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	EXTRA1

DLYSHO:	CALL	ILPRT
	DB	'WAIT:',TAB,TAB,TAB,0
	LDA	EXTRA1
	MOV	L,A
	MVI	H,0
	MVI	C,DECOUT
	CALL	MEX
	CALL	ILPRT
	DB	' Seconds',0
	RET

ENDIF
;......
;
; SET INT Processor controls interrupt mode
;
SETINT:
	LXI	D,INTTBL	;point to argument table
	CALL	TSRCH		;look for match with allowed arguments
	JC	SETERR		;process error if found
	MOV	A,L		;
	STA	INTFLG		;

INTSHO:
	CALL	ILPRT		;show current status
	DB	'INTerrupt:',TAB,TAB,0
	LDA	INTFLG		;get current mode word
	ORA	A		;
	JNZ	INT		;skip if it is
	CALL	ILPRT		;
	DB	'OFF',0		;
	JMP	CHNGPORT	;
				;
INT:	CALL	ILPRT		;print it
	DB	'ON',0		;
	JMP	CHNGPORT	;
;
;INT argument table
;
INTTBL:	DB	'OF','F'+80H
	DB	0,0
	DB	'O','N'+80H
	DB	0FFH,0
	DB	0
;
INTFLG:	DB	no

;..............................
;
; Compare next input-stream item in table @DE; CY=1 if not found,
; else HL = matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
;
;	>>>>   End of MXH-APnn	 <<<<


