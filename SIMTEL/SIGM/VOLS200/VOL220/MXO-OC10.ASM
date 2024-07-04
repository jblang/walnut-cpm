; MXO-CP10.ASM - Overlay for Osborne01 with the COMM-PAC Modem 06/23/84
;		   Auto-dialing supported.
;
REV:	EQU	10
;
;	This overlay will work with MEX
;
;
; You will want to look this file over carefully.  There are a number of
; options that can be used to configure the program to suit your taste.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up, but remember, the
; COMM-PAC only works at 300 baud.  
;
; Please report any problems by leaving a message on the Houston Bay Area
; RCP/M  1-713-488-5619 --- John Riehl
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file:
;
;		A>MLOAD NEWMEX.COM=MEX10.COM,MXO-OC10.HEX
;
; 		You now have modified .COM file.
;
;=========================================================================
;
; 06/23/84   Original derived from M7OSCP-4.ASM & MXO-PM11.ASM
; Vers. 1.0
;							- John Riehl	
;=========================================================================
;
YES:	EQU	0FFH
NO:	EQU	0
TPA:	EQU	100H
CR:	EQU	0DH
LF:	EQU	0AH
TAB:	EQU	9
ESC:	EQU	1BH	
;
;  Osborne01 port definitions
;
PORT:	EQU	2A00H
MODCT1:	EQU	PORT	;status register for RS232
MODDAT:	EQU	PORT+1  ;data resister for RS232
MDRCVB:	EQU	1	;bit to test for received data
MDRCVR:	EQU	1	;modem receive ready when high
MDSNDB:	EQU	2	;bit to test for ready to send
MDSNDR:	EQU	2	;modem send ready when high
DCDMSK:	EQU	4	;modem carrier on when low
;
MCBON:	EQU	40H	;mask to turn on MCB 
MCBOFF:	EQU	0BFH	;mask to turn off MCB
;
ORIGMD:	EQU	56H
WTCTS:	EQU	150	;number of seconds (x5) to wait for the
			;computer to answer after COMM-PAC auto-dial
			;100=20 sec, 150=30 sec, 255=51 sec.
			;any number 0-255 acceptable
RBWAIT:	EQU	50	;5 second delay before redialing COMM-PAC
;
;
; MEX service processor stuff
;
MEX:	EQU	0D00H	;address of the service processor
INMDM:	EQU	255	;get char from port to A, CY=no more in 100 ms
TIMER:	EQU	254	;delay 100ms * reg B
TMDINP:	EQU	253	;B=# secs to wait for char, cy=no char
CHEKCC:	EQU	252	;check for ^C from KBD, Z=present
SNDRDY:	EQU	251	;test for modem-send ready
RCVRDY:	EQU	250	;test for modem-receive ready
SNDCHR:	EQU	249	;send a character to the modem (after sndrdy)
RCVCHR:	EQU	248	;recv a char from modem (after rcvrdy)
LOOKUP:	EQU	247	;table search: see CMDTBL comments for info
PARSFN:	EQU	246	;parse filename from input stream
BDPARS:	EQU	245	;parse baud-rate from input stream
SBLANK:	EQU	244	;scan input stream to next non-blank
EVALA:	EQU	243	;evaluate numeric from input stream
LKAHED:	EQU	242	;get nxt char w/o removing from input
GNC:	EQU	241	;get char from input, cy=1 if none
ILP:	EQU	240	;inline print
DECOUT:	EQU	239	;decimal output
PRBAUD:	EQU	238	;print baud rate
;
BDOS:	EQU	5
;
CONOUT:	EQU	2	;simulated BDOS function 2: console char out
PRINT:	EQU	9	;simulated BDOS function 9: print string
INBUF:	EQU	10	;input buffer, same structure as BDOS 10
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Š;
	ORG	TPA
;
	DS	6	;(for  "JMP   START" instruction)
CLOCK:	DB	40	;clock speed (must 40 for Osborne01	106H
MSPEED:	DB	1	; 1=300 5=1200				107H
BYTDLY:	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
			;default time to send character in ter-
			;minal mode file transfer for slow BBS.
CRDLY:	DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
			;default time for extra wait after CRLF
			;in terminal mode file transfer
COLUMS:	DB	3	;number of DIR columns shown		10AH
SETFL:	DB	YES	;yes=user-added Setup routine		10BH
SCRTST:	DB	YES	;cursor control routine 		10CH
	DB	0	;spare					10DH
BAKFLG:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES	;yes=default to CRC checking		10FH
TOGCRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO	;yes=convert backspace to rub		111H
TOGLBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO	;no=no LF after CR to send file in	113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:	DB	NO	;yes=allow transmission of logon	115H
			;write logon sequence at location LOGON
NOSAVE:	DB	NO	;DO NOT CHANGE, MUST BE 'NO' FOR OS-1	116H
LOCNXT:	DB	NO	;yes=local command if EXTCHR precedes	117H
			;no=external command if EXTCHR precedes
TOGLOC:	DB	YES	;yes=allow toggling of LOCNXT	118H
LSTTST:	DB	YES	;yes=printer available on printer port	119H
XOFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
			;sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after CR while	11BH
			;sending a file in terminal mode
TOGXOF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0	;For future expansion			11EH
EXTRA2:	DB	0	;for future expansion			11FH
CARRIER:DB	'V'-40H	;^V = Turn on carrier			120H
NOCONN:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H	;^L = Send logon			122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:	DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:	DB	ESC	;ESC= Send next character		127H
;
	DS	2	;NOT USED
;
INCTL1:	CALL	OSTAT	! RET	;get the I/O status		12AH
OTCTL1:	CALL	OSET	! RET	;setup I/O			12EH
		DS	2Š;
OTDATA:	CALL	OSOUT	! RET	;send a character to the I/O	134H
		DS	6
;
INPORT:	CALL	OSIN	! RET	;get a character from the I/O	13EH
		DS	6
;
MASKR:	ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:	CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:	ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:	CPI	MDSNDR ! RET	;value of send bit when ready	151H
;
	DS	14	;UNUSED AREA				154H
;
DIALV:	JMP	PDIAL	;dial digit in A			162H
DISCV:	JMP	PDISC	;disconnect the modem			165H
GOODBV:	RET ! NOP ! NOP	;called before exit to CP/M		168H
INMODV:	JMP	NITMOD	;initialization called by cold start	16BH
	RET ! NOP ! NOP	;(by-passes PMMI routine)		16EH
	RET ! NOP ! NOP	;(by-passes PMMI routine)		171H
	RET ! NOP ! NOP	;(by-passes PMMI routine)		174H
SETUPV:	JMP	SETCMD	;					177H
	DS	3	;not used by mex			17AH
VERSNV:	JMP	SYSVER	;overlays voice in sign-on msg		17DH
BREAKV:	JMP	PCNCT	;Turn on carrier			180H
;
;
; Do not change the following six lines.
;
ILPRTV:	DS	3		;				183H
INBUFV:	DS	3		;				186H
ILCMPV:	DS	3		;				189H
INMDMV:	DS	3		;				18CH
NXSCRV:	DS	3		;				18FH
TIMERV:	DS	3		;				192H
;
;
; Clear/screen and clear/end-of-screen.
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
;	*** END OF FIXED FORMAT AREA ***Š;
;------------------------------------------------------------
;
; Osborne & Modem initialization.
;
NITMOD:	LHLD	BDOS+1		;FIND START OF BDOS
	LXI	D,-0100H	;GO TO FIRST PAGE AHEAD OF BDOS
	DAD	D		;HL NOW POSITIONED ONE PAGE BELOW BDOS
	PUSH	H		;SAVE THE ADDRESS
	LXI	D,BDJ		;POINT TO OUR ROUTINE TO PUT THERE
	LXI	B,CDLEN+2	;SET LENGTH OF CODE
	XCHG
	DB	0EDH,0B0H	;Z80 LDIR
;
	LHLD	BDOS+1		;GET BDOS ADDRESS BACK ONCE MORE
	POP	D		;GET THE STARTING ADDRESS OFF STACK
	PUSH	D		;PUT IT BACK ON THE STACK
	INX	D		;POINT TO ADDRESS POSITION
	XCHG			;PUT INTO 'HL'
	MOV	M,E		;STORE 'LSP' ADDRESS
	INX	H		;GET 'LSP' LOCATION
	MOV	M,D		;STORE 'MSP' ADDRESS
	POP	H		;GET THE ADDRESS BACK ONCE MORE
	SHLD	BDOS+1		;NEW ADDRESS TO PROTECT FOR OVERWRITE
;
	LXI	D,OSIN-BDJ	;GET THE LENGTH OF ROUTINE TO MOVE
	DAD	D		;COMUTE ADDRESS OF THE 'OSIN' ROUTINE
	SHLD	INPORT+1	;PATCH CALL FOR "GET CHAR." ROUTINE
	LXI	D,OSOUT-OSIN
	DAD	D
	SHLD	OTDATA+1	;PATCH CALL FOR "SEND CHAR." ROUTINE
	LXI	D,OSTAT-OSOUT
	DAD	D
	SHLD	INCTL1+1	;PATCH CALL FOR "GET STATUS" ROUTINE
	LXI	D,OSET-OSTAT
	DAD	D
	SHLD	OTCTL1+1	;PATCH JMP FOR "SEND ACIA CTL" ROUTINE
;
	MVI	A,1		;MSPEED 300 baud value
	STA	MSPEED
;
;
; SET THE INITIAL BAUD RATE TO 300
;
	MVI	A,56H		;FOR 300 BAUD
SETUPR1:STA	UCTLB
;
MODCTL2:PUSH	B
	MVI	C,3
CNT:	MVI	B,6BHŠ	LDA	UCTLB
	ORI	MCBON
	CALL	OTCTL
	CALL	DELAY
	MVI	B,6BH
	LDA	UCTLB
	ANI	MCBOFF
	CALL	OTCTL
	CALL	DELAY
	DCR	C
	JNZ	CNT
	MVI	B,6BH
	LDA	UCTLB
	ORI	MCBON
	CALL	OTCTL
	CALL	DELAY
	MVI	B,6BH
	MVI	A,3
	CALL	OTCTL
	CALL	DELAY
	LDA	UCTLB
	ORI	MCBON
	CALL	OTCTL
	POP	B
	RET
;
OTCTL:	PUSH	H
	CALL	OTCTL1
	POP	H
	XRA	A	;CLEAR CARRY
	RET
;.....
;
DELAY:	DCR	B
	JNZ	DELAY
	RET
;
; disconnect the modem
;
PDISC:	LDA	UCTLB
	ORI	MCBON
	CALL	OTCTL
	PUSH	B
	MVI	B,20		;wait for COMM-PAC to disconnect (1 sec)
	MVI	C,TIMER		;0.1 second per timer interval
	CALL	MEX
	POP	B
	RET
;
;------------------------------------------------------------
;
; --- ROUTINES THAT GET PLACED JUST UNDER 'BDOS' OVERLAYING 'CCP'
;
BDJ:	JMP	$-$		;THIS GETS PATCHED TO JUMP TO BDOS ENTRY
;
OSIN:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODDAT		;GET DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;.....
;
;
OSOUT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITDH TO ALTERNATE PAGE
	STA	MODDAT		;SEND DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;.....
;
;
OSTAT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODCT1		;GET STATUS BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET
;.....
;
;
OSET:	DI
	OUT	0
	STA	MODCT1
	OUT	1
	EI
	RET
;.....
;
CDLEN:	EQU	$-BDJ		;LENGTH OF CODE TO COPY
;
;
;=======================================================================
;
;		   	COMM-PAC DIALINÇ ROUTINES
;
;=======================================================================
;
PDIAL:	CPI	254		;start-dial?Š	JZ	STDIAL
	CPI	255		;end-dial
	JZ	ENDIAL
	CPI	','		;smartmodem pause command
	JNZ	CKDIG		;if not pause, continue
	MVI	B,10		;delay 1 second
	MVI	C,TIMER
	CALL	MEX
	RET
;
CKDIG:	CPI	'9'+1		;digits are 0-9
	RNC			;too big...
	SUI	'0'
	RC			;too small....
	JNZ	NOTZERO		;just right...
	MVI	A,10		;convert zero to 10 pulses
NOTZERO:MOV	C,A
;
; Send the digit to the modem.   Wait 200 ms. inter-digit.
;
DIALIT:	PUSH	B
	CALL	PULSE
	CALL	BDELAY
	POP	B
	DCR	C
	JNZ	DIALIT
	LDA	INTERD
	MOV	B,A		;get inter-digit delay
	MVI	C,TIMER
	CALL	MEX
	RET
;
BDELAY: PUSH	PSW
	PUSH	B
	MVI	B,40
	MVI	C,0
	MOV	A,B
BIGAGN:	CALL	BDELAY1
	POP	B
	POP	PSW
	RET
;
BDELAY1:MOV	B,A
	CALL	DELAY
	DCR	C
	JNZ	BDELAY1
	RET
;
; Disconnect from the line, reconnect and wait for the dialtone.
;
STDIAL:	CALL	PDISC
	CALL	PCNCT
	MVI	D,DCDMSK
	MVI	E,5
	CALL	WAITŠ	RET
;.....
;
; End-dial sequence
;
ENDIAL:	CALL	ENDIT		;close out dialing
	ORA	A		;successfully connected?
	RZ			;exit now if so
	PUSH	PSW		;nope, save the error code
	CALL	PDISC		;shut down the modem
	POP	PSW
	RET
;
ENDIT:	CALL	OFF		;go off-hook
	MVI	D,DCDMSK
	MVI	E,WTCTS		;wait up to 30 seconds
	CALL	WAIT
	RNC			;return A=0 if good
	CPI	3		;keyboard abort?
	RZ			;if so return it
	MVI	A,2		;nope, convert error to "no answer"
	RET
;
;	<end of COMM-PAC dialing routines>
;------------------------------------------------------------
;
; go off-hook
;
OFF:	CALL	PCNCT		;turn on DTR
	MVI	B,1		;wait 100 ms
	MVI	C,TIMER
	CALL	MEX
	RET
;
; Time-out routine.
;
WAIT:	MVI	B,2		;200 ms
	MVI	C,TIMER		;wait for timer to go high then low
	CALL	MEX
	CALL	CARRCK		;do we have a carrier
	ANA	D
	RZ			;active low, so return on 0
	MVI	C,CHEKCC	;not yet, check for console-abort
	CALL	MEX		;abort?
	MVI	A,3		;set error code 3 if abort active
	STC
	RZ			;return if aborted
	DCR	E		;nope, downcount
	JNZ	WAIT
	INR	A		;set error=4 (modem error); cy already set
	RET
;
;
; Set baud-rate code in A
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	DŠ	PUSH	B
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	A,M		;fetch code
	ORA	A		;0? (means unsupported code)
	STC			;return error for STBAUD caller
	JZ	PBEXIT		;exit if so
	CALL	SETUPR1		;good rate, set it
	STA	BAUDSV		;save it
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
PBEXIT:	POP	B		;all done
	POP	D
	POP	H
	RET
;
; table of baud rate divisors for supported rates
;
BAUDTB:	DB	0,56H,0,0,0	;110,300,450,610,710
	DB	55H,0,0,0,0	;1200,2400,4800,9600,19200
;
;======================= SIGN-ON MESSAGE ==============================	
;
SYSVER:	CALL	NITMOD			;relocate i/o
	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
CARRSH:	LXI	D,NOMESG		;tell about carrier
	CALL	CARRCK			;check for it
	ANI	DCDMSK
	MVI	C,PRINT
	CNZ	MEX			;print the "NO" if no carrier
	LXI	D,CARMSG		;print "carrier present"
	MVI	C,PRINT
	CALL	MEX
	RET
;
SOMESG:	DB	' Osborne COMM-PAC modem V. '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	': $'
;
NOMESG:	DB	'no $'
CARMSG:	DB	'carrier present',CR,LF,'$'
;
;.....
;
PULSE:  LDA	UCTLB
	ORI	MCBON
	CALL	OTCTL
	CALL	BDELAY
;
PCNCT:  LDA	UCTLB
	ANI	MCBOFF
	CALL	OTCTL
	RET
;
;.....
;Š; check the COMM-PAC for carrier-present (NZ=no)
;
CARRCK:	CALL	INCTL1		;get status byte
	PUSH	PSW
	ANI	DCDMSK
	CNZ	INPORT
	POP	PSW
	RET
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
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG:	DB	CR,LF,'$'	;clear to end-of-screen
CLSMSG:	DB	1AH,CR,LF,'$'	;clear whole screen
;
; Data area
;
ERRFLG:	DB	0		;connection error code
UCTLB:	DB	ORIGMD		;uart-control byte image
BAUDSV:	DB	ORIGMD		;current baud rate (dflt 300)
MODCTB:	DB	07FH		;modem control byte
INTERD:	DB	10		;inter-digit delay in 100's of ms
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command -- if you prefer not to write a SET for your
; modem, you may delete the code from here to the END statement.
;
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse commandŠ	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;......
;
; SET command table 
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'ID','G'+80H		;"set id"
	DW	SETIDG
	DB	'OFFHOO','K'+80H	;"set offhook"
	DW	OFF
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
	CALL	CRLF		;print newline
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
SHOTBL:	DW	BDSHOW
	DW	SHOIDG
	DW	0		;<<== table terminator
;Š; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET command, COMM-PAC version:',CR,LF,LF
	DB	CR,LF,'SET BAUD 300 <or> 1200'
	DB	CR,LF,'SET OFFHOOK	   ... go offhook'
	DB	CR,LF,'SET IDG <value>     ... interdig. delay in 100''s msec'
	DB	CR,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;not-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;.......
;
; SET IDIG command processor
;
SETIDG:	MVI	C,EVALA
	CALL	MEX		;get numeric
	MOV	A,H		;validate
	ORA	A
	JNZ	SETERR
	MOV	A,L
	STA	INTERD		;set new rate
SHOIDG:	CALL	ILPRT
	DB	'Inter-digit time:',0
	LDA	INTERD		;get value
	MOV	L,A		;move delay to HL
	MVI	H,0
	MVI	C,DECOUT	;print it
	CALL	MEX
	CALL	ILPRT
	DB	'00 ms',0
	RET
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processorŠ;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
;------------------------------------------------------------
;
; End of MEX COMM-PAC modem overlay
;
;------------------------------------------------------------
;
	END
