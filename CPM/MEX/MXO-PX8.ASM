	Title	'MEX overlay for Epson PX-8 version 1.0'
;
;
; (delete above title line if not assembling with MAC)
;
;
REV	EQU	10		;overlay revision level
;
; MEX overlay for Epson PX-8 with MFU, Direct Connect modem, or
; external modem. Support is provided for an external dialing overlay
; such as MXO-SM. For details see MXO-PX8.DOC.
;
; Written 3/10/85 by David B. Kozinn
;
;	Copyright (C) 1985 by David B. Kozinn 
; 
; This program (in source or object code form) may be copied and distributed
; for non-commercial purposes. Sale of this program is forbidden without
; written consent of the author.
;
; The author can be contacted on CompuServe [76703,565] via Easyplex, or
; (preferably) in CP-MIG (PCS-47) or EpsOnline (PCS-19). 
;
; PLEASE READ THE FOLLOWING IF YOU INTEND TO MODIFY THIS OVERLAY:
; ---------------------------------------------------------------
; Much of the commentary has been removed in order to save space. For
; complete documentation of how an overlay is structured, see the original
; overlay, MXO-PM.ASM, written by Ron Fowler. Please be sure to read the
; comments in that overlay if you intend to change this one.
;
;	Version	Date	Changes
;	------- -------	------- 
;	  1.0	850310	First general release version	
;------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	(NOT NO) AND 0FFH
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
BELL	EQU	7
ESC	EQU	01BH
CUROFF	EQU	032H
CURON	EQU	033H
XON	EQU	011H
XOFF	EQU	013H
;
; PX-8 port definitions
;
MCTLR2	EQU	002H		;Misc control signals (output)
CCR	EQU	00DH		;8251 command port
DCRREG	EQU	084H		;Modem tone dialer control port (output)
OCR	EQU	085H		;Modem control register (output)
STR	EQU	086H		;Modem status register (input)
OMR	EQU	087H		;Modem port setup (output)
;
; PX-8 Special locations (see code for use)
;
WBLOC	EQU	0EC03H		;BIOS call Warm Boot location
DRSDAT	EQU	0F00FH		;Default RS-232 data
CTLR1	EQU	0F0B0H		;CTLR1 register value
CTLR2	EQU	0F0B2H		;CTLR2 register value
RSMODE	EQU	0F6D0H		;8251 Mode byte location
RSCMD	EQU	0F6D1H		;8251 Command byte location
RSOPN	EQU	0F2C8H		;RS-232 open flag (00=Open)
SLVFLG	EQU	0F358H		;Slave cpu (6301) flag
INTBUF	EQU	0FB90H		;Internal rs232 buffer
INTBUFL	EQU	0160H		;Internal buffer length
;
;  bit definitions
;
MDMINIT	EQU	089H		;8251 initialization string
BRKBIT	EQU	008H		;8251 bit to turn break on
MDRCVB	EQU	001H		;modem receive bits
MDRCVR	EQU	001H		;modem recieve ready
MDSNDB	EQU	002H		;modem send bits
MDSNDR	EQU	002H		;modem recieve ready
USEINT	EQU	020H		;set to 0, send this to CTLR2 to use int.
DCD	EQU	008H		;Use with RSIOX CTLIN
;
;  bit definitions for OCR
;
OHC	EQU	001H		;off hook
HSC	EQU	002H		;handset control
MON	EQU	004H		;enable speaker
TXC	EQU	008H		;transmit carrier
ANS	EQU	010H		;Answer mode 
TEST	EQU	020H		;Test function
PWR	EQU	040H		;Modem Power
CCT	EQU	080H		;connect to phone lne
;
;  bit definitions for STR
;
BDS	EQU	001H		;Bell Detect Signal. 0 if ringing
CTSMSK	EQU	004H		;Clear to send. (carrier det) =0 if clear
MII	EQU	080H		;Modem Installation Indicator 0=installed
;
;	
; Special BIOS call locations
;
CONIN	EQU	WBLOC+006H	;Direct console input
CONOUT	EQU	WBLOC+009H	;Direct console output
RSOPEN	EQU	WBLOC+039H	;Open RS-232 port
RSCLOSE	EQU	WBLOC+03CH	;Close RS-232  port
RSINST	EQU	WBLOC+03FH	;Check for input
RSOUTST	EQU	WBLOC+042H	;Check for output
RSIN	EQU	WBLOC+045H	;Get a character
RSOUT	EQU	WBLOC+048H	;Send a character
RSIOX	EQU	WBLOC+051H	;Special RS-232 calls
SLAVE	EQU	WBLOC+072H	;Use slave CPU
;
; Equates for use with RSIOX
;
OPNIOX	EQU	010H		;Open using RSIOX
CLSIOX	EQU	020H		;Close using RSIOX
INSTS	EQU	030H		;Check for data in recieve buffer
CTLIN	EQU	070H		;Check carrier & DSR
;
; Mex locations
;
QUEUE	EQU	00D51H		;Queued I/O variable
MODE	EQU	00D54H		;Terminal mode byte (01 = in terminal mode)
SMART	EQU	00B00H		;Entry point for smart modem overlay
;
; Other equates
;
WTCTS	EQU	150		;How long to wait for carrier. 150=30 seconds
;
; MEX service processor stuff 
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
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
	ORG	SMART		;Put code in in case he calls smartmodem
	CPI	255		;without installing the overlay first
	RNZ			;Only do it once, at the end
	CALL	ILPRT
	DB	'** You have not installed a dialing overlay **'
	DB	BELL,CR,LF,0
	XRA	A		;Set zero flag
	MVI	A,3		;Tell him dialing has been aborted
	RET

	ORG	QUEUE		;Set to Queued I/O flag location
	DB	0		;Don't allow queued I/O (it interferes
				;with the stuff we're doing)

	ORG	TPA		;we begin
;
;
	DS	3		;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	NO		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	20		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	0		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	0		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP
LOCNXT:	DB	NO		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	DB	YES		;yes=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of XOFF testing
IGNCTL:	DB	NO		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
; The next two are for PMMI, we don't use them, but they have to hang
; around anyway.
;
	DB	250
	DB	0
;
; Low-level modem I/O routines
;
INCTL1:	JMP	MODSTAT		;in modem control port
	DB	0,0,0,0,0,0,0	;spares
;
OTDATA:	JMP	MODOUT		;out modem data port
	DB	0,0,0,0,0,0,0	;spares
;
INPORT:	JMP	MODIN		;in modem data port
	DB	0,0,0,0,0,0,0	;spares
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
;
; Unused area: was once used for special PMMI functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.
;
	DS	12
;
; Special modem function table
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	JMP	PDIAL		;dial digit in A (see info at PDIAL)
DISCV:	JMP	PDISC		;disconnect the modem
GOODBV:	DS	3		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	DS	3		;set modem for no-parity
PARITV:	DS	3		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK		;send a break
;
; Entry points here are for compatibility with MDM7. They will be gone
; in MEX 2.0, so avoid using them.
;
ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;
CLS:	LXI	D,CLSMSG		;null unless patched
	MVI	C,PRINT
	CALL	MEX
	RET
;
;------------------------------------------------------------
;
;	*** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
; Modem initialization. First make sure that the dialing overlay
; address is correct (some overlays ORG the dial vector and stick a
; JMP B00 there.) We have to make sure that we get control first.
; Also, store away the current value in the DISCV address, because it
; might be the address of the dialing overlay disconnect vector. We'll
; use this to disconnect along with the regular disconnect code if an
; external modem is being used. Then, set up the default communications
; parameters. Then, if the port is already open, just return, else set 
; up to use the built-in modem.
;
NITMOD:	LXI	H,PDIAL		;Get address of our dialing routine
	SHLD	DIALV+1		;Store it as the address to jump to
	LHLD	DISCV+1		;Get address of disconnect vector
	SHLD	SMDISCV+1	;Save it in case it's needed
	LXI	B,PDISC		;Get our disconnect routine address
	XRA	A		;Clear carry flag
	DB	0EDH,042H	;SBC HL,BC If zero, then the same
	JZ	NIT0		;Don't do anything special
	DCR	A		;Get 0FFH to store
	STA	GOTDISC		;Indicate that we've got external disc
	LXI	H,PDISC		;Get the address of our disconnect routine
	SHLD	DISCV+1		;Store it in the proper place
NIT0:	LXI	H,DRSDAT	;Get default rs232 data
	LXI	D,BAUDRATE
	LXI	B,4
	DB	0EDH,0B0H	;LDIR
	LDA	BAUDRATE	;Find out what baud we're set to
	LXI	H,BAUDTBL
	MVI	B,0
NIT1:	CMP	M		;Do we match this table entry?
	JZ	NIT2		;Yes
	INX	H
	INR	B
	JMP	NIT1
NIT2:	MOV	A,B		;Store the table entry locally
	STA	MDMSPD
	CALL	SMSPEED		;Set modem speed for time for xfer
	LDA	RSOPN		;See if the port is already open
	ORA	A
	RZ			;Don't do anything if so
	CALL	RSOPEN		;Turn the port on
	CALL	PWRON		;Try to turn the modem on
	IN	STR		;Read status register
	ANI	MII		;Is modem installed?
	JNZ	OPENIT		;No, open the RS-232 port normally
	CALL	STPORT		;Set up to use the direct connect
	LDA	OCRVAL		;Turn off modem power to conserve
	ANI	(NOT PWR) AND 0FFH
	STA	OCRVAL
	OUT	OCR
	MVI	A,0FFH		;Indicate we're using the internal modem
	STA	MDMTYPE
	RET
OPENIT:	CALL	RSCLOSE		;Close the port to clean things up
	CALL	RSOPEN		;Open it up for the regular port
	RET

;
;  send-break routine
;
PBREAK:	LDA	RSCMD		;Get the current command for the 8251
	ORI	BRKBIT		;turn break on
	OUT	CCR		;Send it to the 8251
	MVI	B,3		;Wait 300 ms.
	MVI	C,TIMER
	CALL	MEX
	LDA	RSCMD		;Restore the 8251 to normal
	OUT	CCR
	RET
;
; disconnect the modem
;
PDISC:	LDA	MDMTYPE		;See if we're using an external modem
	ORA	A		;This will be zero if so
	JNZ	PDISC0		;If not, don't worry about it
	LDA	GOTDISC		;See if we had an external routine
	ORA	A		;This will be non-zero if so
	JNZ	SMDISCV		;Call it if it's there
PDISC0:	CALL	RSCLOSE
	LDA	OCRVAL		;get current modem control values
	ANI	0FFH-(CCT+TXC+OHC)	;On-hook, carrier off,disconnect
	OUT	OCR		;send it
	ANI	(NOT PWR) AND 0FFH	;now turn power off too
	OUT	OCR
	STA	OCRVAL		;Save this as current mod. ctl. value
	CALL	RESPORT		;Reset to use internal
	CALL	SPKROFF		;Turn the speaker off
	CALL	RSOPEN
	RET
;
; External dialing routine disconnect code is called through here.
;
SMDISCV:JMP	PDISC		;<-----This may be modified
;
;
;------------------------------------------------------------
;
;		DIALING ROUTINES 
;	
;
; The DIGITS table is a translation for digit to register value for
; all of the possible legal digits. Not many people will likely have
; use for A-D, since they are kind of hard to dial on a normal phone,
; but since the modem supports them, I've included them here. If you do
; want to use A-D, be sure to specify them as UPPER CASE or they'll be
; treated as they were one of the non-special characters. The modem
; also understands that a comma (,) means to wait for n seconds before
; continuing (for compatability with various intelligent modems.) Any other
; values (such as -, (, or ) ) are ignored. (Values have been OR'd with
; the tone-on bit already.)
;
DIGITS:	DB	1DH,10H,11H,12H	; 0, 1, 2, 3
	DB	14H,15H,16H,18H	; 4, 5, 6, 7
	DB	19H,1AH		; 8, 9
SPLAT:	DB	1CH		; *
CRUNCH:	DB	1EH		; #
CHARS:	DB	13H,17H,1BH,1FH	;A, B, C, D
;
PDIAL:	MOV	B,A		;Save the digit
	LDA	MDMTYPE		;See if we're using an external modem
	ORA	A
	MOV	A,B		;Restore the digit
	JZ	SMART		;If so, jump to the Hayes routines
	CPI	254		;start-dial?
	JZ	STDIAL
	CPI	255		;end-dial
	JZ	ENDIAL
	CPI	','		;smartmodem pause command
	JNZ	CKDIG		;if not pause, continue
	LDA	COMDLY		;delay n seconds
	MOV	B,A
	ADD	A		; x 2
	ADD	A		; x 4
	ADD	A		; x 8
	ADD	B		; x 9
	ADD	B		; x 10
	MOV	B,A
	MVI	C,TIMER
	CALL	MEX
	RET
;
CKDIG:	CPI	'9'+1		;digits are 0-9
	JNC	CKALFA		;too big...check if it's A-D
	SUI	'0'
	JC	CKSPEC		;too small....check if it's * or #
	LXI	H,DIGITS	;get start of digits table
	JMP	DIALIT
;
CKALFA:	CPI	'D'+1		;legal alpha are A-D
	RNC			;too big, ignore it
	SUI	'A'
	RC			;too small
	LXI	H,CHARS		;get start of character table
	JMP	DIALIT
;
CKSPEC:	LXI	H,SPLAT		;Check for specials
	CPI	('*'-'0') AND 0FFH	;..is it *?
	JZ	DIALIT1		;Yup, go dial
	INX	H		;point to CRUNCH
	CPI	('#'-'0') AND 0FFH	;..is it #?
	RNZ			;No, forget it
	JMP	DIALIT1		;Yup, go dial
	
;
; First get the value to send to the tone control register. At DIALIT,
; HL contains the proper table, and A contains the offset into that table.
;
DIALIT:	MVI	B,0
	MOV	C,A		;Get offset into BC
	DAD	B		;Get real byte location into HL
;
DIALIT1:MOV	A,M		;Get value to dial into A
	OUT	DCRREG		;Start sending the tone
	MVI	B,1		;Send it for 100ms (which is kinda long
	MVI	C,TIMER		;but it's easier than coding my own timing
	CALL	MEX		;routine.)
	XRA	A
	OUT	DCRREG		;Turn tone off
	MVI	B,1		;Wait for 100ms for the inter-digit delay
	MVI	C,TIMER
	CALL	MEX
	RET
;
; Start-dial sequence: Go thru normal init sequence, assuming that
; the guy is not trying to dial while connected. (This should 
; disconnect him anyway.
;

STDIAL:	CALL	PDISC		;Disconnect
	LDA	OCRVAL		;Turn on monitor soon
	ORI	MON
	STA	OCRVAL
	CALL	RESPORT		;I don't know why, but I gotta do this
	CALL	PWRON		;Init modem and ports
	CALL	SPKRON		;turn power to speaker on
	LDA	OCRVAL		;Get current value for OCR
	ANI	(NOT ANS) AND 0FFH	;Set originate mode
	STA	OCRVAL
	OUT	OCR
OFFHK:	LDA	OCRVAL		;Have to reload 'cause we're called directly
	ORI	CCT		;Connect to phone
	OUT	OCR
	ORI	OHC		;go off hook
	OUT	OCR
	STA	OCRVAL
	MVI	B,20		;Wait 2 seconds for dial tone
	MVI	C,TIMER
	CALL	MEX
	RET			;dialing init done
;
; End-dial sequence: Watch to see if CTS goes on within 30 seconds. If
; so, turn on carrier, turn speaker off, and connect to the line.
;
ENDIAL:	LDA	OCRVAL		;Turn on carrier
	ORI	TXC
	OUT	OCR
	STA	OCRVAL
	CALL	STPORT
	MVI	E,WTCTS		;# of ms * 5 to wait
LP1:	MVI	B,2		;200 ms.
	MVI	C,TIMER
	CALL	MEX
	IN	STR		;Check modem status register
	ANI	CTSMSK		;See if we've got carrier yet
	JZ	GOTCAR		;If it's zero, then we've got carrier
	MVI	C,CHEKCC	;Not yet, see if he hit ctl-c
	CALL	MEX
	MVI	A,3		;Get ready to return code
	JZ	NOCAR		;Yup, return
	DCR	E		;Nope, count down
	JNZ	LP1		;Keep going if more time
	MVI	A,2		;Set code in A to 2 (no answer)
NOCAR:	PUSH	PSW		;Save the return code
	CALL	PDISC		;Hang up
	POP	PSW		;Get the return code back
	RET
;
; GOTCAR - Come here to go on-line, we've got a carrier from remote
;
GOTCAR:	CALL	SPKROFF		;Turn the speaker off
	XRA	A		;Report that we got carrier
	RET
;
;	<end of PX-8 dialing routines>
;------------------------------------------------------------
;
PBAUD:	RET			;use SET COMM for this
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
	RET
;
SOMESG:	DB	'Epson PX-8 overlay V'
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	'$'
;
; input from the status port. Since the PX-8 has 2 status ports, and
; we can't tell why we're being call (for input or output), we have to
; kludge here. We'll call both in & out status, and fake a 1 byte status
; word. See the MOD??? bytes for the values. Also, we check here to see
; if carrier has been lost (only if we were using the modem.) If so, then
; we'll disconnect from the phone line, reset the port, and tell the user.
;
; NOTE: It was observed that there was really no need for output status,
;	so these routines always return "ready to output". However, the
;	basic code structure to support both input and output status has
;	been left in should it ever be necessary.
;
; Automatic X-ON/X-OFF flow control is also done from this point.
;
MODSTAT:
	PUSH	B		;push all registers (except A)
	PUSH	D
	PUSH	H
	LDA	CTLR2		;See if we're using an MFU
	ANI	USEINT
	JNZ	MDSTAT1		;If not, forget about it
	IN	STR		;Else check modem status register
	ANI	CTSMSK
	JZ	MDSTAT1		;Everything Ok if it's there
	CALL	PDISC		;Otherwise hang up
	CALL	ILPRT		;and say something about it
	DB	CR,LF,'** Carrier Lost **',BELL,CR,LF,0
MDSTAT1:LDA	MODE		;Get terminal mode
	CPI	1		;01 means in terminal mode
	JNZ	MDSTAT4		;If not, then don't worry about it
MDSTAT2:MVI	B,INSTS		;Check for characters in input buffer
	LXI	H,WIPEOUT	;Here's where to put the returned info
	CALL	RSIOX
	JNZ	MDSTAT2		;Wait until we get good status
	XRA	A		;Clear carry
	LXI	H,264		;3/4 full buffer
	DB	0EDH,042H	;SBC HL,BC
	JNC	MDSTAT3		;Continue if < 264 chars in buffer
	LDA	PENDXOFF	;is there an XOFF outstanding already?
	ORA	A		;It'll be 0 if not
	JNZ	MDSTAT4		;If so, then just go ahead
	MVI	C,XOFF		;Send out an XOFF
	CALL	RSOUT
	XRA	A
	DCR	A
	STA	PENDXOFF	;Indicate a pending XOFF
	JMP	MDSTAT4		;Continue
MDSTAT3:MVI	B,INSTS		;Check input again, this time we're
	LXI	H,WIPEOUT	;seeing if it's time to send an XON
	CALL	RSIOX
	JNZ	MDSTAT3
	XRA	A
	LXI	H,50
	DB	0EDH,042H	;SBC HL,BC
	JC	MDSTAT4		;Don't send XON until < 50 chars in buffer
	LDA	PENDXOFF	;Ok, we've got < 50, did we send an XOFF?
	ORA	A
	JZ	MDSTAT4		;No, so don't do anything
	MVI	C,XON
	CALL	RSOUT		;Send the XON
	XRA	A
	STA	PENDXOFF
MDSTAT4:CALL	RSINST		;Now get status
	ANI	MDRCVB		;Mask off what we don't care about
	ORI	MDSNDB		;Always say that output is ready
POPEM:	
	POP	H
	POP	D
	POP	B
	RET
;
; Get a character
;
MODIN:	
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	B,INSTS
	LXI	H,STATBLK
	CALL	RSIOX		;Make sure there is really data so we
	ORA	A		;don't ever hang waiting
	JZ	MODIN1
	CALL	RSIN
MODIN1:	POP	H
	POP	D
	POP	B
	RET
;
; Send a character
;
MODOUT:	
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A
	CALL	RSOUT
	POP	H
	POP	D
	POP	B
	RET
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	C,A		;align output character
	CALL	CONOUT
	POP	B
	POP	D
	POP	H
	RET
;
; SETPORT - set up to use internal modem
;
STPORT:	LDA	CTLR2		;Get current port info
	ANI	(NOT USEINT) AND 0FFH	;Use internal modem
SPORT:	STA	CTLR2
	OUT	MCTLR2
	RET
;
; RESPORT - set up to use external modem
;
RESPORT:LDA	CTLR2		;Get current port info
	ORI	USEINT		;Use external modem
	JMP	SPORT		;Store & send to modem
;
; PWRON - Turn power on to the modem (& some other initialization stuff)
;
PWRON: 	MVI	A,MDMINIT	;Initialize the 7508
	OUT	OMR
	LDA	OCRVAL		;Get current parameters
	ORI	PWR		;Turn the power on
	OUT	OCR
	STA	OCRVAL		;Save the parameters
	MVI	B,1		;Wait a while to let things settle
	MVI	C,TIMER
	CALL	MEX
	RET
;
; SPKRON - Turn the speaker on
;
SPKRON:	MVI	A,0FFH
	STA	SLVFLG
	LXI	D,SLVPRAM1
	CALL	SLAVE
	RET
;
; SPKROFF - Turn speaker off
;
SPKROFF:LDA	OCRVAL		;Get current params
	ANI	(NOT MON) AND 0FFH	;We're not monitoring anymore
	OUT	OCR
	STA	OCRVAL
	MVI	A,0FFH
	STA	SLVFLG
	LXI	D,SLVPRAM2
	CALL	SLAVE
	RET
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
; PLACECUR - Place cursor at row/col specified by BC. 
;
PLACECUR:
	PUSH	PSW
	MOV	A,B
	ADI	01FH		;Add in offset
	STA	ROW
	MOV	A,C
	ADI	01FH		;Add in offset
	STA	COL
	CALL	ILPRT
	DB	ESC,'='
ROW:	DS	1
COL	DS	1
	DB	0
	POP	PSW
	RET
;
; Keyin - get a character into A
;
KEYIN:	PUSH	B
	PUSH	D
	PUSH	H
	CALL	CONIN			;Direct console input
	POP	H
	POP	D
	POP	B
	RET
;
; UCASE - Convert character in A to uppercase
;
UCASE:	CPI	'a'
	RC			;Return if not lower case
	CPI	'z'+1
	RNC			;Return if > lower case z
	ANI	05FH		;Else change to upper case
	RET
;
; SMSPEED - Set time to transfer speed
;
SMSPEED:LDA	MDMSPD		;Get locally stored speed value
	MOV	C,A		;Put in lower half of BC
	MVI	B,0		;Zap upper half of BC
	LXI	H,XSPDTBL	;Get address of xfer speed table
	DAD	B		;Get address of time for xfer byte
	MOV	A,M		;Get the value
	STA	MSPEED		;Store it
	RET
;
; Data area
;
;
; XSPDTBL - transfer speed table. The number in parenthesis is the value
;	    given to MEX. This differs from the actual baud rate in some
;	    cases due to the baud rates available on the PX-8.
;
XSPDTBL:DB	0		;Unused
	DB	0		;110 Baud	(110)
	DB	0		;150 Baud	(110)
	DB	1		;300 Baud	(300)
	DB	3		;800 Baud	(600)
	DB	5		;1200 Baud	(1200)
	DB	6		;2400 Baud	(2400)
	DB	7		;4800 Baud	(4800)
	DB	8		;9600 Baud	(9600)
	DB	9		;19200 Baud	(19200)
EOSMSG:	DB	ESC,'Y','$'	;clear to end-of-screen
CLSMSG:	DB	ESC,'*','$'	;clear whole screen
OCRVAL:	DB	0		;OCR register value
MDMTYPE:DB	0		;modem type, 0FFH=external, 0=internal
GOTDISC:DB	0		;got external disconnect routine, FF=Yes
MDMSPD:	DS	1		;current port speed
COMDLY:	DB	2		;#secs to wait for , in dial string
PENDXOFF:
	DB	0		;0FFH if XOFF pending, 0 otherwise
STATBLK:DS	9		;Returned info from RSIOX INSTS call
;
; The following group of data items are for using the slave CPU. 
; DO NOT ADD OR REMOVE ANYTHING IN THIS AREA!!!
;---------------Start of slave CPU data------------------
SLVPRAM1:
	DW	ONSNDCMD
	DW	ONSNDLEN
	DW	ONRETVAL
	DW	ONRETLEN
ONSNDCMD:
	DB	072H,080H
ONSNDLEN:
	DB	2
ONRETVAL:
	DB	1
ONRETLEN:
	DB	1
SLVPRAM2:
	DW	OFFSDCMD
	DW	OFFSDLEN
	DW	OFFRTVAL
	DW	OFFRTLEN
OFFSDCMD:
	DB	072H,0
OFFSDLEN:
	DB	2
OFFRTVAL:
	DB	1
OFFRTLEN:
	DB	1
;
;-----------------End of Slave CPU data----------------------
;
;
;------------------------------------------------------------
;
;
; Control is passed here after MEX parses a SET command.
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
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'OFFHOO','K'+80H	;"set offhook"
	DW	SETOFF
	DB	'COM','M'+80H		;"set comm"
	DW	SETCOMM
	DB	'DELA','Y'+80H		;"set delay"
	DW	SETDLY
;
	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	CALL	CARRSH		;show carrier present/not present
	LXI	H,SHOTBL	;get table of SHOW subroutines
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
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
; table of SHOW subroutines
;
SHOTBL:	DW	SHHOOK
;	DW	SHSTAT
	DW	SHDLY
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET command, PX-8 version:',CR,LF,LF
	DB	CR,LF,'SET COMM     set/display comm parameters'
	DB	CR,LF,'SET DELAY n  set delay for comma in dial string'
	DB	CR,LF,'             to n seconds'
	DB	CR,LF,'SET OFFHOOK  go offhook'
	DB	CR,LF,'$'
;
; Show carrier status
;
CARRSH:	CALL	CARRCK			;check for it
	LXI	D,NOMESG		;tell about carrier
	MVI	C,PRINT
	CZ	MEX			;print the "NO" if no carrier
	LXI	D,CARMSG		;print "carrier present"
	MVI	C,PRINT
	CALL	MEX
	RET
;
NOMESG:	DB	'no $'
CARMSG:	DB	'carrier present',CR,LF,'$'
;
; check the PX-8 for carrier-present (Z=no)
;
CARRCK:	MVI	B,CTLIN		;get status byte
	CALL	RSIOX
	ANI	DCD		;Check for carrier detect
	RET

;
; Set OFFHOOK processor
;
SETOFF:	CALL	PDISC		;Disconnect if anything was there
	CALL	PWRON		;Fire up the modem
	CALL	OFFHK
SHHOOK:	CALL	ILPRT
	DB	'Modem is ',0
	LDA	OCRVAL
	ANI	OHC
	JZ	SHONHK
	CALL	ILPRT
	DB	'off-hook',CR,LF,0
	RET
SHONHK:	CALL	ILPRT
	DB	'on-hook',CR,LF,0
	RET
;
; Set delay for comma
;
SETDLY:	MVI	C,EVALA		;Get the number
	CALL	MEX
	MOV	A,H		;Validate
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	COMDLY		;Store new rate

;
; Show dialing delay
;
SHDLY:	CALL	ILPRT
	DB	'Delay time for dialing:',0
	LDA	COMDLY
	MOV	L,A
	MVI	H,0
	MVI	C,DECOUT
	CALL	MEX
	CALL	ILPRT
	DB	' seconds',CR,LF,0
	RET
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; SET COMM routines - With thanks to Mike Hoffman and Christopher Rhodes
; 		      of Epson. These are from EPPXMDM3.MAC
;
SETCOMM:CALL	CLS		;Clear the screen
	LXI	D,MENU
	MVI	C,PRINT
	CALL	MEX		;Display the setup menu

; DISPLAY CURRENT VALUES ON SETUP SCREEN
	CALL	DBAUD
	CALL	DDBITS
	CALL	DPARITY
	CALL	DSTP
	CALL	DMODEM

; GET USERS RESPONSE AND SET PARAMITERS
SETUP0:	CALL	KEYIN
	CALL	UCASE
	CPI	ESC
	JZ	SETUP
	CPI	'9'+1		;GREATER THAN BAUD SELECTION
	JNC	SDBITS		;CHECK FOR DATA BITS
	CPI	'1'		;LESS THAN 1?
	JC	SETUP0		;GET ANOTHER RESPONSE
	ANI	0FH
	MOV	E,A
	MVI	A,10
	SUB	E
	STA	MDMSPD
	MOV	C,A
	MVI	B,0
	LXI	H,BAUDTBL
	DAD	B
	MOV	A,M
	STA	BAUDRATE
	CALL	DBAUD
	JMP	SETUP0
SDBITS:	CPI	'B'+1		;GREATER THAN DATA BITS
	JNC	SPARITY		;CHECK FOR PARITY
	CPI	'A'		;LESS THAN 'A'
	JC	SETUP0		;GET ANOTHER RESPONSE
	SUI	3FH		;MAKE 2 OR 3
	STA	DBITS
	CALL	DDBITS
	JMP	SETUP0
SPARITY:CPI	'E'+1		;GREATER THAN PARITY
	JNC	SSTOP		;CHECK FOR STOP BITS
	SUI	'C'
SPAR1:	STA	PARBITS
	CALL	DPARITY
	JMP	SETUP0
SSTOP:	CPI	'G'+1		;GREATER THAN STOP BITS
	JNC	SMOD		;CHECK FOR MODEM
	SUI	'F'-1
	CPI	1
	JZ	SSTOP1
	ADI	2
SSTOP1:	STA	STP
	CALL	DSTP
	JMP	SETUP0
SMOD:	CPI	'I'+1		;GREATER THAN BAUD
	JNC	SETUP0		;BAD SELECTION GET ANOTHER RESPONSE
	SUI	'H'
	JZ	SMOD1
	CALL	PWRON		;Try to turn the modem on
	IN	STR		;Read status register
	ANI	MII		;Is modem installed?
	JNZ	SMOD2
	MVI	A,0FFH
SMOD1:	STA	MDMTYPE
	CALL	DMODEM
	JMP	SETUP0
SMOD2:	MVI	A,BELL
	CALL	TYPE
SMOD3:	LXI	B,0201H
	CALL	PLACECUR
	CALL	ILPRT
 	DB	TAB,'*** NO MODEM ***',0
	XRA	A
	STA	MDMTYPE
	CALL	DMODEM
	JMP	SETUP0
;
; Display baud rate
;
DBAUD:	LXI	B,30DH
	CALL	PLACECUR
	LXI	H,BAUDSPD
	MVI	D,0
	LDA	MDMSPD		;get baud rate code
	CPI	0FFH
	RZ			;unknown baud rate
	MOV	E,A		;x1
	ADD	A		;x2
	ADD	A		;x4
	ADD	E		;x5
	ADD	E
	MOV	E,A
	DAD	D		;point to correct rate
	XCHG
	MVI	C,PRINT
	CALL	MEX
	CALL	ILPRT
	DB	' bps ',CR,LF,0
	RET	

;
; Display data bits
;
DDBITS:	LXI	B,50DH
	CALL	PLACECUR
	LDA	DBITS
	CPI	2
	MVI	A,'7'
	JZ	DDBITS1
	MVI	A,'8'
DDBITS1:CALL	TYPE
	RET
;
; Display parity
;
DPARITY:LXI	B,60DH
	CALL	PLACECUR
	LDA	PARBITS
	ORA	A
	JNZ	DPAR1
	CALL	ILPRT
	DB	'none',0
	RET
DPAR1:	CPI	1
	JNZ	DPAR2
	CALL	ILPRT
	DB	'odd ',0
	RET
DPAR2:	CALL	ILPRT
	DB	'even',0
	RET
;
; Display stop bits
;
DSTP:	LXI	B,70DH
	CALL	PLACECUR
	LDA	STP
	CPI	1
	MVI	A,'1'
	JZ	DSTP1
	MVI	A,'2'
DSTP1:	CALL	TYPE
	RET
;
; Display modem type
;
DMODEM:	LXI	B,80DH
	CALL	PLACECUR
	LDA	MDMTYPE
	ORA	A
	JNZ	DMODEM1
	CALL	ILPRT
	DB	'external',0
	RET
DMODEM1:CALL	ILPRT
	DB	'internal',0
	RET

SETUP:	CALL	STPORT		;Set up for internal mode just in case
	CALL	SMSPEED		;Set time to xfer speed
	LDA	MDMTYPE		;See what kind of modem we're using
	INR	A		;If FF, then it's internal
	JZ	SETUP1		;yep, it's internal
	CALL	RESPORT		;Using external, do setup
SETUP1:	LXI	H,PARAMS
	LXI	D,WIPEOUT
	LXI	B,9
	DB	0EDH,0B0H	;LDIR
	MVI	B,CLSIOX
	CALL	RSIOX		; close port first
	MVI	B,OPNIOX
	LXI	H,WIPEOUT
	CALL	RSIOX		; open with new parameters
	CALL	CLS
	CALL	ILPRT
	DB	ESC,CURON
 	DB	CR,LF,LF,LF
 	DB	TAB,'Communication initialization completed.',CR,LF,0
	RET

BAUDSPD: DB	'50   $110  $150  $300  $600  $'
	 DB	'1200 $2400 $4800 $9600 $19200$'
BAUDTBL:	
	DB	0FFH	; 50   baud not supported
	DB	2	; 110  baud
	DB	4	; 150  baud
	DB	6	; 300  baud
	DB	8	; 600  baud
	DB	0AH	; 1200 baud
	DB	0CH	; 2400 baud
	DB	0DH	; 4800 baud
	DB	0EH	; 9600 baud
	DB	0FH	; 19.2 baud

MENU:	DB	ESC,CUROFF
 DB	'    Select alphanumeric or ESC to return.',CR,LF,LF
 DB	'bit rate  :           1=19200    2=9600     3=4800     4=2400'
 DB	'     5=1200',CR,LF
 DB	'                      6=600      7=300      8=150      9=110',CR,LF
 DB	'data bits :           A=7        B=8',CR,LF
 DB	'parity    :           C=none     D=odd      E=even',CR,LF
 DB	'stop bits :           F=1        G=2',CR,LF
 DB	'modem type:           H=external I=internal$'

PARAMS:	
	DW	INTBUF
	DW	INTBUFL
BAUDRATE:
	DS	1
DBITS:
	DS	1
PARBITS:
	DS	1
STP:
	DS	1
SPECIAL:
	DB	0FFH	;Not XON/XOFF, not SI/SO, DTR on, RTS on

WIPEOUT:DS	9	; this area gets overwritten by BIOS call
COPYRITE:
	DB	'Copyright (C) 1985 by David B. Kozinn'
;
;------------------------------------------------------------
;
; End of PX-8 MEX modem overlay
;
;------------------------------------------------------------
;
	END
