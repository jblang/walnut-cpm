; M7R1-3.ASM -- Overlay for Radio Shack TRS-80 Model I equipped with
;		Omikron Mapper I or similar modification which allows
;		operation with ram-base-0 CP/M.
;
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: After editing, assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the resulting
;		.HEX file on the MDM7xx.COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7R1-3.HEX		(Note the "I" command.)
;		-R			("R" loads in the .HEX file.)
;		NEXT  PC
;		4A00 0000
;		-G0			(Return to CP/M.)
;		A>SAVE 73 MDM7xx.COM	(You now have a modified .COM file.)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 03/21/84 - Modified for Radio Shack Model I.		- Dave Towson
; 11/11/83 - General purpose overlay file for MDM7xx.   - Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
CR:		EQU	0DH	;Carriage return
LF:		EQU	0AH	;Linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
NUMLIB:		EQU	0E00H	;Address of telephone number library.
				;CHECK THIS - may have changed.
XFRSIZ:		EQU	4	;Buffer size in Kbytes for Christensen
				;protocol receive-to-disk.  Must not be
				;greater than 16.
SHOWHEX		EQU	YES	;Yes = show hexadecimal record numbers
				;in addition to decimal during protocol
				;file transfer.  No = don't show hex.
;
RESETP:		EQU	0E8H	;Reset port for RS-232.
BAUDP:		EQU	0E9H	;Data-rate port for RS-232.
CONTROLP:	EQU	0EAH	;Status/control port for RS-232.
DATAP:		EQU	0EBH	;Data port for RS-232.
SENDMASK:	EQU	40H	;Bit to test for transmit-buffer-empty.
SENDRDY:	EQU	40H	;Value when ready.
RECVMASK:	EQU	80H	;Bit to test for received-data-available.
RECVRDY:	EQU	80H	;Value when ready.
BRKMASK:	EQU	0FBH	;And-mask to turn on break.
DISCONMASK:	EQU	03H	;Or-mask to turn off DTR and RTS.
;
		ORG	100H
;
;
; Change the clock speed if you have installed a clock modification.
;
		DS	3	;For  "JMP   START" instruction.
;
PMMIMODEM:	DB	NO	;Yes = PMMI S100 modem.			103H
SMARTMODEM:	DB	NO	;Yes = HAYES Smartmodem.		104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem only).	105H
CLOCK:		DB	18	;Clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200.
				;Default data-rate used for time-to-
				;send calculations.
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms.  108H
				;Default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;Default time for extra wait after CRLF
				;in terminal mode file transfer.
NOOFCOL:	DB	4	;Number of DIR columns shown.		10AH
SETUPTST:	DB	YES	;Yes = user-added setup routine.	10BH
SCRNTEST:	DB	YES	;Clear screen routine installed.	10CH
NORETRY:	DB	NO	;Yes = aborts after ERRLIM consecutive  10DH
				;timeouts.  No = reset the error limit
				;to allow more attempts.  Called ACKNAK,
				;and used for a different purpose in
				;earlier overlays.
BAKUPBYTE:	DB	NO	;Yes = change any file having same	10EH
				;name to .BAK
CRCDFLT:	DB	YES 	;Yes = default to CRC checking.		10FH
TOGGLECRC:	DB	YES	;Yes = allow toggling of CRC to 	110H
				;checksum.
CONVBKSP:	DB	NO	;Yes = convert backspace to rubout.	111H
TOGGLEBK:	DB	YES	;Yes = allow toggling of bksp to rub.	112H
ADDLF:		DB	NO	;No = no LF after CR when sending file	113H
				;in terminal mode (added by remote).
TOGGLELF:	DB	YES	;Yes = allow toggling of LF after CR.	114H
TRANLOGON:	DB	NO 	;Yes = allow transmission of logon.	115H
				;Put logon sequence at location LOGON.
SAVCCP:		DB	YES	;Yes = do not overwrite CCP.		116H
LOCONEXTCHR:	DB	NO	;Yes = local cmd if EXTCHR precedes.	117H
				;No = transmitted to remote computer if
				;preceded by EXTCHR.
TOGGLELOC:	DB	YES	;Yes = allow toggling of LOCONEXTCHR.	118H
LSTTST:		DB	YES	;Yes = printer available on printer	119H
				;port.
XOFFTST:	DB	NO	;Yes = checks for XOFF from remote	11AH
				;while sending a file in terminal mode.
XONWAIT:	DB	NO	;Yes = wait for XON after CR while	11BH
				;sending a file in terminal mode.
TOGXOFF:	DB	YES	;Yes = allow toggling of XOFF checking.	11CH
IGNORCTL:	DB	NO 	;Yes = CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;For future expansion.			11EH
EXTRA2:		DB	0	;For future expansion.			11FH
BRKCHR:		DB	'B'-40H	;^B = Send 300 ms. break tone.		120H
NOCONNCT:	DB	'D'-40H	;^D = Disconnect from the phone line.	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon.			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer.			123H
UNSAVE:		DB	'C'-40H	;^C = Close input text buffer.		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote.		125H
SAVECHR:	DB	'O'-40H	;^O = Open input text buffer.		126H
EXTCHR:		DB	'N'-40H	;^N = Send next character.		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	CONTROLP ! RET	;Get RS-232 status.		12AH
		DB	0,0,0,0,0,0,0	;Do not delete these.
;
OUT$MODDATP:	OUT	DATAP	! RET	;Send a character to the RS-232	134H
		DB	0,0,0,0,0,0,0	;Do not delete these.          	
;
IN$MODDATP:  	IN	DATAP	! RET	;Get a character from RS-232.	13EH
		DB	0,0,0,0,0,0,0	;Do not delete these.          	
;
ANI$MODRCVB:	ANI	RECVMASK ! RET	;Mask for rcvd-char-ready bit.	148H
CPI$MODRCVR:	CPI	RECVRDY ! RET	;Test for rcvd-char-ready.	14BH
ANI$MODSNDB:	ANI	SENDMASK ! RET	;Mask for ready-to-send bit.	14EH
CPI$MODSNDR:	CPI	SENDRDY ! RET	;Test for ready-to-send.		151H
		DS	6		;				154H
;
		DS	6		;				15AH
;
LOGONPTR:	DW	LOGON		;For user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	TRSINIT		;Go to user written routine.	16BH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	16EH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETBAUD		;				177H
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
CLREOS:		CALL	JMP$ILPRT	;Clear from cursor to EOS.	195H
		DB	1FH,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;Home cursor and clear screen.	19EH
		DB	1CH,1FH,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;Display version name.		1A7H
		DB	'Version for TRS-80 Model I '			
		DB	'with Omikron Mapper I'				
		DB	CR,LF,0		;							
		RET			;				
;.....
;
;
; You can put in a message at this location which can be called up with
; CTL-L if TRANLOGON has been set to YES.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	'Put logon message here.',CR,LF,0
;
;.....
;
;
; Routine to send a break-tone of approximately 300 ms duration.
;
SENDBRK:	PUSH	B		;Save all double registers.
		PUSH	D		;
		PUSH	H		;
		LDA	CONTROLB	;Get current RS-232 control byte.
		ANI	BRKMASK		;Change bit to turn on break.		
		OUT	CONTROLP	;Send new byte to control port.
		MVI	B,3		;Set count for timer.
		CALL	JMP$TIMER	;Wait 300 milliseconds.		
		LDA	CONTROLB	;Restore original control byte		
		OUT	CONTROLP	;to turn off break.
		POP	H		;Restore double registers.
		POP	D		;
		POP	B		;
		RET			;
;
;
;.....
;
;
; Routine to disconnect modem from telephone line by setting both DTR and
; RTS to the "off" state.  Send a BREAK (in terminal mode) to reconnect.
; CHECK THIS - control logic for your modem may be different.
;
GOODBYE:	LDA	CONTROLB	;Get current RS-232 control byte.
		ORI	DISCONMASK	;Change bits to turn off DTR and RTS.
		OUT	CONTROLP	;Send new byte to control port.
		RET			;
;
;
;.....
;
;
; RS-232 initialization routine for TRS-80 Model I.
;
TRSINIT:	OUT	RESETP		;Reset UART (data in A register is
					;insignificant).
		MVI	A,55H		;Value for 300 baud.
					;Use 77H for 1200 baud.
		OUT	BAUDP		;Set RS-232 data-rate.
;
; NOTE:  Be sure to set the default value at entry "MSPEED:"
;        to agree with the above data-rate.
;
		MVI	A,0ECH		;Set RS-232 for 8-bit word,
					;no parity, and
		OUT	CONTROLP	;DTR and RTS on.
		STA	CONTROLB	;Save the RS-232 control byte.
		RET			;
;
;
;.....
;
;
CONTROLB:	DB	0		;RS-232 control byte save.
;
;
;.....
;
;
; Routine to change data-rate with the SET command.
;
SETBAUD:	PUSH	B		;Save all double registers.
		PUSH	D		;
		PUSH	H		;
;
AGAIN:		LXI	D,BAUDBUF	;Point to input buffer.
		CALL	JMP$ILPRT	;Display message.
		DB	'Input Baud Rate (300, 1200): ',0
		CALL	JMP$INBUF	;Get response.
		LXI	D,BAUDBUF+2	;Set pointer.
		CALL	JMP$INLNCOMP	;Compare BAUDBUF+2 with
					;valid responses below.
		DB	'300',0		;300 baud.
		MVI	A,1		;Value for MSPEED.
		MVI	C,55H		;Value for data-rate.
		JNC	OK		;Jump if match.
;
		CALL	JMP$INLNCOMP	;Else, try next valid response.
		DB	'1200',0	;1200 baud.
		MVI	A,5		;Value for MSPEED.
		MVI	C,77H		;Value for data-rate.
		JNC	OK		;Jump if match.
		CALL	JMP$ILPRT	;Else, bad input.
					;Display message.
		DB	'++ INCORRECT ENTRY ++',CR,LF,0
		JMP	AGAIN		;Try again.
;
;
;.....
;
;
OK:		STA	MSPEED		;Set value for file-send-time
					;computations.
		MOV	A,C		;
		OUT	BAUDP		;Set RS-232 data-rate.
		POP	H		;Restore double registers.
		POP	D		;
		POP	B		;
		RET			;
;
;
;.....
;
;
BAUDBUF:	DB	10,0		;Keyboard input buffer.
		DS	10
;
;
;.....
;
;
SPCLMENU:	  RET
;
;
;.....
;
;
; Routine to determine whether hexadecimal record numbers are displayed
; during protocol file transfer, and size of buffer used.
;
		ORG	NUMLIB-2
;
HEXSHOW:	DB	SHOWHEX		;Set hex display.
SAVSIZ:		DB	XFRSIZ*8	;Set buffer size.
;
;
;.....
;
;
		END
;
;
;.....
