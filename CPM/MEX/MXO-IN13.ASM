; MXO-IN13.ASM -- INTEL 8251 I/O mapped overlay for MEX10-12. 12/31/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Intel 8251 I/O chip.
; Much of the information contained here is not in the main file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MEX "SET" command to change the baudrate when desired.  When
; the program is first called up the baud rate is set to 300.  The
; initial baud rate can be changed by setting to the desired baud rate
; and "CLONEing".
;
; The baud rate switch for the modem port must be set to 1200 baud, even
; if the port will only be used at 300 baud.
;
; 	TO USE: First edit this file filling in answers for your own
; 		equipment.  Then assemble with ASM.COM or equivalent
; 		assembler.  Then use MLOAD to overlay the the results
; 		of this program to the original .COM file.
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 12/31/84 - Adapted for Intel 8251 from	- David Miles
; 	     MXO-HZ13				
; 05/22/84 - Rewritten for MEX10		- Biff Bueffel
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Revised to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; MEX service processor stuff
;
MEX	EQU	0D00H		; address of the service processor
INMDM	EQU	255		; get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		; delay 100ms * reg B
TMDINP	EQU	253		; B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		; check for ^C from KBD, Z=present
SNDRDY	EQU	251		; test for modem-send ready
RCVRDY	EQU	250		; test for modem-receive ready
SNDCHR	EQU	249		; send a character to the modem (after sndrdy)
RCVCHR	EQU	248		; recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		; table search: see CMDTBL comments for info
PARSFN	EQU	246		; parse filename from input stream
BDPARS	EQU	245		; parse baud-rate from input stream
SBLANK	EQU	244		; scan input stream to next non-blank
EVALA	EQU	243		; evaluate numeric from input stream
LKAHED	EQU	242		; get nxt char w/o removing from input
GNC	EQU	241		; get char from input, cy=1 if none
ILP	EQU	240		; inline print
DECOUT	EQU	239		; decimal output
PRBAUD	EQU	238		; print baud rate
;
PRINT	EQU	9		; MEX/BDOS print-string function call
;
BELL	EQU	07H		; bell
CR	EQU	0DH		; carriage return
ESC	EQU	1BH		; escape
LF	EQU	0AH		; linefeed
;
YES	EQU	0FFH
NO	EQU	0
;
;
MODDATP	EQU	12H		; data port for 8251
MODCTL1	EQU	MODDATP+1	; status port for 8251
MODRCVB	EQU	2		; bit to test for received data
MODRCVR	EQU	2		; modem receive ready
MODSNDB	EQU	1		; bit to test for ready to send
MODSNDR	EQU	1		; modem send ready bit
;
		ORG	100H
;
		DS	3	; (for  "JMP   START" instruction)
;
PMMIMODEM:  	DB	NO	; yes=PMMI S-100 Modem			103H
SMARTMODEM: 	DB	NO	; yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE: 	DB	'T'	; T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	; clock speed in MHz x10, 25.5 MHz max.	106H
				; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200	107H
				; 6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				; default time to send character in ter-
				; minal mode file transfer for slow BBS.
CRDLY:		DB	5	; 0=0 delay 1=100 ms 5=500 ms 9=900 ms  109H
				; default time for extra wait after CRLF
				; in terminal mode file transfer
NOOFCOL:    	DB	5	; number of DIR columns shown		10AH
SETUPTST:   	DB	YES	; yes=user-added Setup routine		10BH
SCRNTEST:   	DB	YES	; Cursor control routine		10CH
ACKNAK:		DB	YES	; yes=resend a record after any non-ACK	10DH
				; no=resend a record after a valid NAK
BAKUPBYTE:  	DB	NO	; yes=change any file same name to .BAK	10EH
CRCDFLT:    	DB	YES	; yes=default to CRC checking		10FH
TOGGLECRC:  	DB	YES	; yes=allow toggling of CRC to Checksum	110H
CONVBKSP:   	DB	NO	; yes=convert backspace to rub		111H
TOGGLEBK:   	DB	NO	; yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	; no=no LF after CR to send file in	113H
				; terminal mode (added by remote echo)
TOGGLELF:   	DB	YES	; yes=allow toggling of LF after CR	114H
TRANLOGON:  	DB	NO	; yes=allow transmission of logon	115H
				; write logon sequence at location LOGON
SAVCCP:		DB	YES	; yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	; yes=local command if EXTCHR precedes	117H
				; no=external command if EXTCHR precedes
TOGGLELOC:  	DB	YES	; yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	; yes=printer available on printer port	119H
XOFFTST:    	DB	NO	; yes=checks for XOFF from remote while	11AH
				; sending a file in terminal mode
XONWAIT:    	DB	NO	; yes=wait for XON after CR while	11BH
				; sending a file in terminal mode
TOGXOFF:    	DB	YES	; yes=allow toggling of XOFF checking	11CH
IGNORCTL:   	DB	YES	; yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	; for future expansion			11EH
EXTRA2:		DB	0	; for future expansion			11FH
BRKCHR:		DB	'@'-40H	; ^@ = Send a 300 ms. break tone		120H
NOCONNCT:   	DB	'N'-40H	; ^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	; ^L = Send logon			122H
LSTCHR:		DB	'P'-40H	; ^P = Toggle printer			123H
UNSAVE:     	DB	'R'-40H	; ^R = Close input text buffer		124H
TRANCHR:    	DB	'T'-40H ; ^T = Transmit file to remote		125H
SAVECHR:    	DB	'Y'-40H	; ^Y = Open input text buffer		125H
EXTCHR:		DB	'^'-40H	; ^^ = Send next character		126H
;
		DS	2	;	 				128H
;
IN$MODCTL1: 	IN	MODCTL1 ! RET	; in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	; out modem data port		134H
		DS	7
IN$MODDATP: 	IN	MODDATP ! RET	; in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI     MODRCVB ! RET   ; bit to test rec ready
CPI$MODRCVR:	CPI     MODRCVR ! RET   ; value when ready
ANI$MODSNDB:	ANI     MODSNDB ! RET   ; bit to test snd ready
CPI$MODSNDR:	CPI     MODSNDR ! RET   ; value when ready
		DS	12
;
		DS	2		; for user message.		160H
		DS	6		; 				162H
JMP$GOODBYE:	JMP	GOODBYE		; 				168H
JMP$INITMOD:	JMP	INITMOD		; go to user written routine	16BH
JMP$NEWBAUD	JMP	NEWBAUD		; Reset baudrate			16EH
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		; 				177H
		DS	3		; 				17AH
JMP$SYSVER:	JMP	SYSVER		; 				17DH
JMP$BREAK:	JMP	SENDBRK		; 				180H
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		; 				183H
JMP$INBUF	DS	3		; 				186H
JMP$INLNCOMP:	DS	3		; 				189H
JMP$INMODEM	DS	3		; 				18CH
JMP$NXTSCRN:	DS	3		; 				18FH
JMP$TIMER:	DS	3		; 				192H
; .....
;
;
CLREOS:	 LXI	D,EOSMSG
	 MVI	C,PRINT
	 CALL	MEX
	 RET
;
CLRSCRN: LXI	D,CLSMSG
	 MVI	C,PRINT
	 CALL	MEX
	 RET
;
EOSMSG:	 DB	'$'
CLSMSG:	 DB	'$'
;.....
;
;
SYSVER:	MVI	C,ILP
	CALL	MEX
	DB	'Version for 8251 I/O port'
	DB	CR,LF,0
	RET
; .....
;
;
; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.
;
SENDBRK: RET
; .....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE: RET
; .....
;
;
; The following is used in setting up the 8251 I/O port.
;
INITMOD: LDA	MSPEED		; initialize port using old rate code
;
NEWBAUD: CPI	1		; 300 baud code?
	 LXI	H,CTL300	; load pointer to 300 baud ctl byte
	 JZ	SETBAUD		; do it to it.
	 CPI	5		; check for 1200 baud
	 LXI	H,CTL1200
	 RNZ			; return now if none of above
;
SETBAUD: STA	MSPEED		; save new baud rate
	 MVI	A,0AAH		; dummy command
	 OUT	MODCTL1		; send to port to get attention
	 NOP !	NOP		; wait for slow ports
	 MVI	A,40H		; reset command
	 OUT	MODCTL1
	 NOP !	NOP
	 MOV	A,M		; get command byte
	 OUT	MODCTL1
	 NOP !	NOP
	 MVI	A,37H		; reset RTS, ERR, DTR. enable XMT and REC
	 OUT	MODCTL1
	 NOP !	NOP
	 IN	MODDATP		; wake up port
;
TELL:	 MVI	C,ILP
	 CALL	MEX		; Print current baud rate
	 DB	CR,LF,'Baud rate is now: ',0
	 LDA	MSPEED
	 MVI	C,PRBAUD
	 CALL	MEX
	 MVI	C,ILP
	 CALL	MEX
	 DB	CR,LF,0
	 XRA	A
	 RET
;
; The following changes the baud rate with the SET command.
;
SETUPR:	 MVI	C,SBLANK	; Any arguments?
	 CALL	MEX
	 JC	TELL		; If not, go display baud
	 LXI	D,CMDTBL
	 MVI	C,LOOKUP
	 CALL	MEX		; Parse argument
	 MOV	A,L		; put baud code in accum
	 JNC	NEWBAUD		; set baud if argument good
	 MVI	C,ILP		; Tell user input not valid
	 CALL	MEX
	 DB	CR,LF,'Only 300 and 1200 allowed on SET command',CR,LF,0
	 RET
;
CMDTBL:	 DB	'30','0'+80H
	 DW	0001		; 300 baud code
	 DB	'120','0'+80H
	 DW	0005		; 1200 baud code
	 DB	0
;
; TABLE OF BAUDRATE PARAMETERS FOR 8251
;
CTL300:	 DB	0CFH		; control byte for 300 baud
CTL1200: DB	0CEH		; control byte for 1200 baud
;
BAUDBUF: DB	10,0
	 DS	10
;.....
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	 END
;
