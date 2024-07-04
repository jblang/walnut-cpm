; M7P1-1.ASM MODEM7 OVERLAY (MDM712 and later) FOR PMC MICROMATE 101
;   Beta test version 1
;
; History:
;
; 01/13/84 Revised per M7GP-1.ASM -- the General purpose overlay file
;          for MDM7xx dated 11/11/83 and name changed for MDM716
;          Bill Wells, University of California, Berkeley CA.
; 11/01/83 IN$MODDATP modified to output 00H then 10H per page 75
;          of the MicroMate User's Guide (instead of only 10H)
;          Bill Wells, University of California, Berkeley CA.
; 10/31/83 BSD Unix communication defaults set by Bill Wells, UCB
;          Bill Wells, University of California, Berkeley CA.
;		XOFFTST = YES      (Unix ports use XON/XOFF)
;               CRCDFLT = NO       (umodem & tmodem do not have CRC)
;               IGNORCTL = NO      (so vi, more, & tset work)
; 10/09/83 Modified for MDM712 by Jim Warner, UCSC
;          BAUDMATCH routine changed to query user about setting of
;          the IGNORCTL. SET$BAUDRATE, AACCOR, and YES$CNTRL added.
; 10/02/83 Modified for MDM712 by Greg Small and Bill Wells,
;          University of California, Berkeley CA.
; 07/02/83 Patches (MDM709PM.ASM) for MDM709
;          SETLPR, BAUDMATCH, MSPEED$INIT, BIOSPB, BIOSPB1 added.
;          Jim Warner - University of California, Santa Cruz.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Notes by Jim Warner:
;
;  The baud rate stuff in this adaptation is a little strange.
;  The initial BAUD rate is whatever it was when the program was
;  entered.  The hardware is read to determine what that is and
;  MSPEED is changed to agree with it.  A request for a new BAUD
;  rate is translated in Digital Research's official BAUD rate
;  code and poked into a data structure called the Device Table.
;  Finally, the hardware gets poked to agree with the table by
;  calling the BIOS routine responsible for intializing devices.
;
;  We'll need to see the CP/M 3 System System Guide to find out
;  if this is done right.
;
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
;		assembler. Use SID to overlay the results of this
;		program on the original .COM file:
;
;		A>save			(this is for CP/M 3)
;
;		A>sid mdm7xx.com
;		CP/M 3 SID - Version 3.0
;		NEXT MSZE  PC  END
;		4580 4580 0100 D9FF
;		#rm7p1-1.hex		(note the "r" command)
;		NEXT MSZE  PC  END
;		040B 4580 0100 D9FF
;		#G0			(return to CP/M)
;
;		CP/M 3 SAVE - Version 3.0
;		Enter file (type RETURN to exit): mdm7p1.com
;		Beginning hex address: 0100
;		Ending hex address: 457F	(MSZE - 1)
;
;		A>
;
; NEXT, MSZE, PC, END, and Ending hex addresses shown are for MDM716
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; M7GP-1.ASM 11/11/83:
; 
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; PMC Micromate Model 101 dependant stuff from MDM712PM.ASM - 10/09/83
; Patches for overlaying distribution version  of MDM712 for use with
; the PMC-101.  Jim Warner - Univ of Cal Santa Cruz.
;
PORT:		EQU	89H	;PMC SERIAL MODEM PORT
MODCTL1:	EQU	PORT+2	;Modem control port			     gts
MODCTL2:	EQU	PORT+2	;Modem control port			     gts
MODDATP:	EQU	PORT	;Modem data port
MODRCVB:	EQU	01H	;Your bit to test for receive
MODRCVR:	EQU	01H	;Your value when receive ready.
MODSNDB:	EQU	04H	;Your bit to test for send.
MODSNDR:	EQU	04H	;Your value when xmitter available.
;
P$BAUD		EQU	93H	;Upper nibble = TERMNL
P$GETBAUD	EQU	95H	;Lower nibble = MODEM
;
; M7GP-1.ASM 11/11/83:
; Change the following information to match your equipment
;
; PORT:		EQU	0C0H
; MODCTL1:	EQU	PORT		;MODEM CONTROL PORT
; MODDATP:	EQU	PORT+1		;MODEM DATA IN PORT
; MODDATO:	EQU	PORT+1		;MODEM DATA OUT PORT
; MODDCDB:	EQU	4		;CARRIER DETECT BIT
; MODDCDA:	EQU	0		;VALUE WHEN ACTIVE
; BAUDRP:		EQU	PORT+2		;BAUD RATE PORT
; MODCTL2:	EQU	PORT+3		;2ND MODEM CONTROL PORT
; MODRCVB:	EQU	2		;BIT TO TEST FOR RECEIVE
; MODRCVR:	EQU	2		;VALUE WHEN READY
; MODSNDB:	EQU	1		;BIT TO TEST FOR SEND
; MODSNDR:	EQU	1		;VALUE WHEN READY
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; M7GP-1.ASM 11/11/83 with Unix communication defaults, Bill Wells:
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
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
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH jw
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	NO	;yes=default to CRC checking		10FH wcw
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
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH wcw
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH wcw
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
;
		DS	2		;				128H
;
; M7GP-1.ASM 11/11/83:
; IN$MODCTL1:	IN	MODCTL1 !; RET	;in modem control port		12AH
;		DS	7
;
; M712PM.ASM 10/09/83 by Jim Warner, modified by Bill Wells 11/01/83
IN$MODCTL1:	XRA	A		;Output 00H to command port	12AH wcw
		OUT	MODCTL1         ;                               12BH wcw
		MVI	A,10H		;Output 10H to command port     12DH jw
		OUT	MODCTL1         ;                               12FH jw
		IN	MODCTL1		;Get status bits.               131H jw
		RET                     ;                               133H
;
; M7GP-1.ASM 11/11/83:
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7               ;                               137H
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7               ;                               141H
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
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
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	0,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	0,0,0,0,0	;				1A1H
		RET			;				1A6H
	
;
; M712PM.ASM 10/09/83 by Jim Warner, modified by Bill Wells 01/13/84
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Modem 7 for PMC Micromate Model 101 - '
		DB	'UC Beta Test Version 1 - 01/14/84'
		DB	CR,LF,0
		LXI	D,LOGON
		MVI	C,9
		CALL	5
		CALL	MSPEED$INIT
		RET
;.....
;
; M7GP-1.ASM 11/11/83:
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
; M712PM.ASM 10/09/83 by Jim Warner
LOGON:		DB	'Do not use this program to filch'
		DB	' copyrighted software.',CR,LF,0,'$'
;.....
; M7GP-1.ASM 11/11/83:
;
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
INITMOD: 	RET
;
SETUPR:		;Allow baud rate change w SET cmd
		LXI	D,BAUDBUF
		CALL	JMP$ILPRT
		DB	'Input baud rate (110, 300, 600, 1200)',CR,LF
		DB	'                (2400,4800,9600,19200):',0
		CALL	JMP$INBUF
		LXI	D,BAUDBUF+2
		CALL	JMP$INLNCOMP	;Compare BAUDBUF+2 w char's
		DB	'110',0
		MVI	L,3		;Code from MODEBAUD.LIB
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'300',0
		MVI	L,6
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'600',0
		MVI	L,7
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'1200',0
		MVI	L,8
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'2400',0
		MVI	L,10
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'4800',0
		MVI	L,12
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'9600',0
		MVI	L,14
		JNC	BAUDMATCH
;
		CALL	JMP$INLNCOMP
		DB	'19200',0
		MVI	L,15
		JC	SETUPR
;
BAUDMATCH:	CALL	SET$BAUDRATE
		CALL	MSPEED$INIT
		CALL	AACCOR		;Allow all Control Char on Recv?
		RET			; (* SETUP *)
;
SET$BAUDRATE:	PUSH	H		;Save baud code
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
		RET
;
; M712PM.ASM 10/09/83 by Jim Warner, modified by Bill Wells 01/13/84
AACCOR:		CALL	JMP$ILPRT
		DB	'Allow ALL control characters on receive?',CR,LF
		DB	'Answer "Y" to permit control of local',CR,LF
		DB	'  console from remote system.',CR,LF
		DB	'Answer "Y" to use vi on Unix (Y/N): ',0
		LXI	D,BAUDBUF
		CALL	JMP$INBUF
		LXI	D,BAUDBUF+2
		LDAX	D	; Force input to upper case for compare
		ANI	5FH	; Added by Gregg Small UCB 1/13/84
		STAX	D	;
		CALL	JMP$INLNCOMP
		DB	'Y',0
		MVI	A,0FFH
		JC	YES$CNTRL
		INR	A
YES$CNTRL:	STA	IGNORCTL
		RET
;
; M712PM.ASM 10/09/83 by Jim Warner
MSPEED$INIT:	IN	P$GETBAUD	;Read serial speeds.
		ANI	0FH		;Mask to modem port speed.
		MOV	L,A
		MVI	H,0
		LXI	D,STABLE
		DAD	D
		MOV	A,M		;Get local speed code
		STA	MSPEED		; and tell MDM712.
		RET 
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
;This table is used to translate baud rate values as read from
; the hardware latch into their more restrictive MODEM712
; equivalents.
;
;		   MDM712 BAUD				  hardware BAUD 
;		    rate code				    rate code
STABLE		DB	0	;Really 50 baud, use 110	0
		DB	0	;Really 75 baud, use 110	1
		DB	0	;110 baud			2
		DB	0	;Really 134.5 baud, use 110	3
		DB	0	;Really 150 baud, use 110	4
		DB	1	;300 baud			5
		DB	3	;600 baud			6
		DB	5	;1200 baud			7
		DB	5	;Really 1800 baud, use 1200	8
		DB	6	;Really 2000 baud, use 2400	9
		DB	6	;2400 baud			A
		DB	6	;Really 3600 baud, use 2400	B
		DB	7	;4800 baud			C
		DB	7	;Really 7200 baud, use 4800	D
		DB	8	;9600 baud			E
		DB	9	;19.2k				F
;
SPCLMENU:	RET
;.....
;
;	
;
BAUDBUF:	DB	10,0
		DS	10
;-----------------------------------------------------------------------
; M7GP-1.ASM 11/11/83:

;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
;
