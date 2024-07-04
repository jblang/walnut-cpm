; MEXP1-1.ASM - MEX OVERLAY FOR PMC MICROMATE 101
;   Version 1.0
;
; History:
;
; 84/11/02 Created from M7P1-1.ASM
;	   Ian Cottrell, Dept Energy, Mines and Resources, Ottawa, Canada
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;	/////////////////////////////////////////
;	/					/
;	/	- - W A R N I N G - -		/
;	/					/
;	/    This code uses CP/M 3 dependent	/
;	/    stuff.				/
;	/					/
;	/////////////////////////////////////////
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Use the "SET" command to change the baudrate when desired. 
;
;	To use:	First edit this file, filling in answers for your own
;		equipment. Then assemble with MAC.COM or equivalent
;		assembler. Use MLOAD21 to overlay the results of this
;		program on the original .COM file:
;
;		MLOAD21 MEX.COM=MEX112.COM,MXO-P1-1.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; PMC Micromate Model 101 dependant stuff 
;
PORT:		EQU	89H	;PMC SERIAL MODEM PORT
MODCTL1:	EQU	PORT+2	;Modem control port		     gts
MODCTL2:	EQU	PORT+2	;Modem control port		     gts
MODDATP:	EQU	PORT	;Modem data port
MODRCVB:	EQU	01H	;Your bit to test for receive
MODRCVR:	EQU	01H	;Your value when receive ready.
MODSNDB:	EQU	04H	;Your bit to test for send.
MODSNDR:	EQU	04H	;Your value when xmitter available.
;
P$BAUD		EQU	93H	;Upper nibble = TERMNL
P$GETBAUD	EQU	95H	;Lower nibble = MODEM
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; MEX Service Processor
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
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
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
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH jw
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH wcw
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	NO	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH wcw
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH wcw
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'D'-40H	;^D = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
; IN$MODCTL1:	IN	MODCTL1 	;in modem control port		12AH
;		RET	
;		DS	7
;
IN$MODCTL1:	XRA	A		;Output 00H to command port	12AH wcw
		OUT	MODCTL1         ;                               12BH wcw
		MVI	A,10H		;Output 10H to command port     12DH jw
		OUT	MODCTL1         ;                               12FH jw
		IN	MODCTL1		;Get status bits.               131H jw
		RET                     ;                               133H
;
OUT$MODDATP:	OUT	MODDATP 	;out modem data port		134H
		RET	
		DS	7               ;                               137H
IN$MODDATP:	IN	MODDATP 	;in modem data port		13EH
		RET	
		DS	7               ;                               141H
ANI$MODRCVB:	ANI	MODRCVB		;bit to test for receive ready	148H
		RET	

CPI$MODRCVR:	CPI	MODRCVR		;value of rcv. bit when ready	14BH
		RET
ANI$MODSNDB:	ANI	MODSNDB		;bit to test for send ready	14EH
		RET
CPI$MODSNDR:	CPI	MODSNDR		;value of send bit when ready	151H
		RET	
		DS	6		;				154H
;
OUT$MODCTL1:	OUT	MODCTL1		;out modem control port #2	15AH
		RET
OUT$MODCTL2:	OUT	MODCTL2		;out modem control port #1	15DH
		RET
;
		DS	2		;not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;change baud rate
		RET			;(by-passes PMMI routine)	171H
		NOP
		NOP
		RET			;(by-passes PMMI routine)	174H
		NOP
		NOP
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;not used by MEX		17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER	DS	3		;				192H
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
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
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'Version for PMC Micromate Model 101 - '
		DB	CR,LF
		DB	'With external Hayes Smartmodem 1200'
		DB	CR,LF,0
		RET
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; Add your own routine here to send a break tone to reset some time-sharing
; computers, if desired.
; 
SENDBRK:	RET
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM (M7DP-1.ASM) which is
;    using this feature.
;
GOODBYE:	RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET. You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:MVI	L,8			;set baud rate to 1200
	CALL	BAUDMCH
	MVI	A,5
	STA	MSPEED			;set MSPEED to match
	RET
;
;Allow baud rate change w SET cmd
SETUPR:	MVI	C,SBLANK		;any arguments
	CALL	MEX
	JC	TELL			;if not, go display baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX			;parse argument
	PUSH	H			;save any arg addrs on stack
	RNC				;if we have one, return to it
	POP	H			;oops, input not found in table
	MVI	C,ILP
	CALL	MEX			;tell user input not valid
	DB	'++ Incorrect Entry ++',CR,LF,BELL,0
	RET

CMDTBL:	DB	'30','0'+80H
	DW	OK300
	DB	'60','0'+80H
	DW	OK600
	DB	'120','0'+80H
	DW	OK1200
	DB	'240','0'+80H
	DW	OK2400
	DB	'480','0'+80H
	DW	OK4800
	DB	'960','0'+80H
	DW	OK9600
	DB	'1920','0'+80H
	DW	OK1920
;
TELL	MVI	C,ILP
	CALL	MEX			;print current baud rate
	DB	CR,LF,'Baud rate is now: ',0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX
	RET

OK300:	MVI	A,1			;MSPEED 300 baud value
	LHLD	BD300			;300 baud value in 'HL'
	JMP	BAUDMCH			;go do it

OK600:	MVI	A,3
	LHLD	BD600
	JMP	BAUDMCH

OK1200:	MVI	A,5
	LHLD	BD1200
	JMP	BAUDMCH

OK2400:	MVI	A,6
	LHLD	BD2400
	JMP	BAUDMCH

OK4800:	MVI	A,7
	LHLD	BD4800
	JMP	BAUDMCH

OK9600:	MVI	A,8
	LHLD	BD9600
	JMP	BAUDMCH

OK1920:	MVI	A,9
	LHLD	BD1920
	JMP	BAUDMCH

BAUDMCH:PUSH	PSW		;save MSPEED value
	PUSH	H		;Save baud code
	MVI	C,32H		;Function: direct bios call.
	LXI	D,BIOSPB	;BIOS parameter block
	CALL	5
	LXI	D,8+7		;Index to BAUD rate in 2nd
	DAD	D		; entry. (i.e. MODEM)
	POP	D		;Get new code back.
	MOV	A,M		;Best not to change high
	ANI	0F0H		; nibble, whatever it is.
	ORA	E		;Put new code in table.
	MOV	M,A
;
	MVI	C,32H		;Function: direct bios call.
	LXI	D,BIOSPB1	;Initialize device means to
	CALL	5		; set BAUD rate to PMC.
	POP	PSW		;restore MSPEED value
	STA	MSPEED		;set it
	RET

NEWBAUD:CPI	1
	JZ	OK300
	CPI	3
	JZ	OK600
	CPI	5
	JZ	OK1200
	CPI	6
	JZ	OK2400
	CPI	7
	JZ	OK4800
	CPI	8
	JZ	OK9600
	CPI	9
	JZ	OK1920
	RET
;
; Table of Baud Rate Parameters
;
BD300	DW	0006H
BD600	DW	0007H
BD1200	DW	0008H
BD2400	DW	000AH
BD4800	DW	000CH
BD9600	DW	000EH
BD1920	DW	000FH
;
BIOSPB		DB	20	;BIOS fcn: return devtbl address
		DB	0	;A-reg contents
		DW	0	;BC-reg contents
		DW	0	;DE-reg contents
		DW	0	;HL-reg contents
;
BIOSPB1		DB	21	;BIOS fcn: initialize device in c-reg
		DB	0	;A-reg contents
		DB	1	;C-reg=1 for MODEM
		DB	0	;B-reg
		DW	0	;DE-reg
		DW	0	;HL-reg
;
SPCLMENU:	RET
;.....
;
;	
;
BAUDBUF:	DB	10,0
		DS	10

EOSMSG:	DB	23,0,0,0,0,'$'	;clear to eos for Cybernex XL-87
CLSMSG:	DB	24,0,0,0,0,'$'	;clear screen for Cybernex XL-87

;-----------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;.....
;
	  END
;
