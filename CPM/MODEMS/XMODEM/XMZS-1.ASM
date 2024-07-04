;.............................................................
;.............................................................
; XMZS-1.ASM - XMODEM81 PATCH FILE FOR THE Z80-SIO.  11/27/83
;.............................................................
;.............................................................
;
; Assembly instructions
;
;
;	B>DDT XMODEM81.COM
;	DDT VERS 2.2
;	NEXT  PC
;	1100 0100
;	-IXMZS-1.HEX		(note the 'I' command)
;	-R			('R' loads in the .HEX file)
;	NEXT  PC
;	1100 0000
;	-G0			(return to CP/M)
;	B>SAVE 17 XMODEM81.COM  (now have a modified .COM file)
;
; NOTE: Save 22 (rather than 17) if LOGCAL is TRUE and assembling with
;	MAC.COM and SEQIO22.LIB.
;.....................................................................
; This file along with XMODEMxx.ASM are the only two files necessary
; to set-up XMODEM for the Kaypro with a Hayes Smartmodem
;
; Set USECON equate to FALSE in XMODEMxx.ASM and insert appropriate
; CONOUT equate below.  See BYE-KPRO.INF for proper CONOUT for Kaypro
;
;                                           Steve Sanders
;                                    Tampa Bay Bandit Board RCP/M
;.....................................................................   
;.....................................................................
;
; 11/27/83  Updated to XMZS-1           - Steve Sanders
; 06/03/83  Created Z80SIO from EXT     - Al Krug
; 04/04/83  Updated to XMODEM74		- Irv Hoff
; 03/27/83  Updated to XMODEM73		- Irv Hoff
; 03/17/83  Updated to XMODEM72		- Irv Hoff
; 03/15/83  Updated to XMODEM71		- Irv Hoff
;
; 03/07/83  Added instructions on how to adapt this file to XMODEM70.COM.
;	    Standardized the format.  Added automatic MSPEED from "BYE"
;	    program.  Added CONOUT information.  Adapted from XM70PMMI.
;					- Irv Hoff
;
;.....................................................................
;
; Define True and False
;
TRUE:	  EQU	0FFH
FALSE:	  EQU	0
;
;.....................................................................
;
; Modem & Data Equates
;
MODDATP:  EQU	04H		;DATA IN PORT (04H for KAYPRO)
MODDATO:  EQU	MODDATP		;DATA OUT PORT
MODCTLP:  EQU	MODDATP+2	;CONTROL/STATUS PORT
MODSNDB:  EQU	4		;BIT TO TEST FOR SEND
MODSNDR:  EQU	4		;VALUE WHEN READY
MODRCVB:  EQU	1		;BIT TO TEST FOR RECEIVE
MODRCVR:  EQU	1		;VALUE WHEN READY
MODDCDB:  EQU	8		;CARRIER DETECT BIT
MODDCDA:  EQU	8		;VALUE WHEN ACTIVE
MODPARE:  EQU	10H		;VALUE FOR PARITY ERROR
MODOVRE:  EQU	20H		;VALUE FOR OVERRUN ERROR
MODFRME:  EQU	40H		;VALUE FOR FRAMING ERROR
MODRESI:  EQU   10H		;RESET EXTERNAL STATUS/INTERRUPTS
MODERES:  EQU   30H		;ERROR RESET
;
;
LSPEED:	  EQU	TRUE		;TRUE IF USING BY2-17KS OR ANY BYE2-xx
				;FALSE IF USING 'SPEED' MANUAL SELECTION
MSPEED:	  EQU	3CH		;LOCATION OF BAUD RATE FACTOR (SET BY
;				;'BYE')  SET LOCATION IN 'BYE' TO AGREE.
;				;3DH AND 3EH OFTEN USED BY NEWER VER-
;				;SIONS OF 'ZCPR'.
XSPEED:	  EQU	1		;SPEED FOR FILE TIME TRANSFER WITHOUT
;				;AUTO-SET.  USE ONE OF THE FOLLOWING:
;				;0=110 1=300 2=450 3=600 4=710 5=1200
BASE:	  EQU	100H		;START OF CP/M NORMAL PROGRAM AREA
;
;.......................................................................
;
; Jump table: The jump table must be in exactly the same sequence as the
; one in XMODEM.  Note the ORG of 103H - This jump table has no jump to
; 'BEGIN'.
;
;
	  ORG	BASE+3		;START AFTER 'JMP BEGIN'
;
CONOUT:   JMP	0EBFDH		;MUST BE 00000H IF NOT USED, SEE BELOW
				;currently set for a Kaypro-10 with CP/M 2.2D
PMINIT:	  JMP	MINIT		;INITIALIZATION ROUTINE (IF NEEDED)
PUNINIT:  JMP	UNINIT		;UNDO WHATEVER 'MINIT' DID (OR RETURN)
PSENDR:	  JMP	SENDR		;SEND CHARACTER (VIA POP PSW)
PCAROK:	  JMP	CAROK		;TEST FOR CARRIER
PMDIN:	  JMP	MDIN		;RECEIVE DATA BYTE
PGETCHR:  JMP	GETCHR		;GET CHARACTER FROM MODEM
PRCVRDY:  JMP	RCVRDY		;CHECK RECEIVE READY
PSNDRDY:  JMP	SNDRDY		;CHECK SEND READY
PSPEED:	  JMP	SPEED		;GET SPEED VALUE FOR FILE TRANSFER TIME
PEXTRA1:  JMP	EXTRA1		;EXTRA FOR CUSTOM ROUTINE
PEXTRA2:  JMP	EXTRA2		;EXTRA FOR CUSTOM ROUTINE
PEXTRA3:  JMP	EXTRA3		;EXTRA FOR CUSTOM ROUTINE
;
;......................................................................
;
; -- To Display the Record Count on the CRT During Program Transfers --
;	
;	This one addition requires some work on the part of the user.
; When "BYE" is added, CP/M is normally moved lower to accomodate the
; new program above CP/M.  Whenever BYE is called to enable the RCPM
; capability, it steals some of the addresses contained in the BIOS jump
; vector table.  In order to display on the CRT during program transfers
; you need to get into the BIOS console output routine directly, else
; what is being displayed also tries to go out the modem.  This is a big
; NO-NO at that time.  (This cannot be done automatically by XMODEM,
; since BYE has already taken the address we need to find, by the time
; XMODEM is automatically activated by the remote station.)
;......................................................................
;
; I was always impressed but lost when trying to follow the instructions
; that were previously here.  So to make this a simple process rather
; than a rediculous round and round affair, simply get a copy of TELL.COM
; and run it on your system.  Take the equate listed as  "CONSOLE OUT
; ROUTINE:"  and plug the value into CONOUT above.
;
;                                      Steve Sanders
;......................................................................
;
; ---> CAROK - check for presence of carrier.  RET with Z = carrier on
;
CAROK:
	MVI	A,MODRESI	;RESET EXTERNAL STATUS/INTERRUPTS
	OUT	MODCTLP
	IN	MODCTLP		;GET STATUS
	ANI	MODDCDB		;GET CARRIER DETECT BIT
	CPI	MODDCDA		;TEST BIT
	RET
;
;..........................................................
;
EXTRA1:	RET			;FOR LATER USE
EXTRA2:	RET			;FOR LATER USE
EXTRA3:	RET			;FOR LATER USE
;
;...........................................................
;
; ---> GETCHR - get a character, same as MDIN
; ---> MDIN - - get a character, same as GETCHR
;
GETCHR:
MDIN:
	IN	MODDATP		;GET CHARACTER FROM DATA IN PORT
	RET
;
;.......................................................................
;
MINIT:	RET			;NO INITIALIZATION REQUIRED
;
;.......................................................................
;
; ---> RCVRDY - check receive ready.  RET with Z = character available.
;	        Return with error code in A-reg.
;
RCVRDY:
	IN	MODCTLP		;GET MODEM STATUS
	PUSH	B		;SAVE SCRATCH REGISTER
	PUSH	PSW
	MVI	A,1+MODRESI	;SELECT READ REGISTER 1
	OUT	MODCTLP
	IN	MODCTLP		;READ THE ERROR STATUS
	ANI	MODFRME+MODOVRE+MODPARE
	MOV	B,A		;SAVE IT FOR A MOMENT
	MVI	A,MODERES
	OUT	MODCTLP		;DO AN ERROR RESET COMMAND
	POP	PSW		;NOW GET MODEM STATUS BACK
	ANI	MODRCVB		;ISOLATE READY BIT
	CPI	MODRCVR		;TEST IT
	MOV	A,B		;GET THE ERROR CODE CHAR. BACK
	POP	B
	RET
;
;....................................................................
;
; ---> SENDR - send character
;
SENDR:
	POP	PSW		;GET THE CHARACTER BACK
	OUT	MODDATO		;SEND IT TO THE MODEM OUTPUT
	RET
;
;....................................................................
;
; ---> SNDRDY - check if ready to send.
;
SNDRDY:
	IN	MODCTLP		;GET STATUS BYTE
	ANI	MODSNDB		;ISOLATE READY BIT
	CPI	MODSNDR		;READY TO SEND?
	RET
;
;....................................................................
;
; ---> SPEED - sets the time shown for program transfer.
;
SPEED:
	 IF	LSPEED
	LDA	MSPEED		;GET INDEX FOR BAUD RATE FROM 'BYE'
	 ENDIF
;
	 IF 	NOT LSPEED
	MVI	A,XSPEED	;GET INDEX FOR BAUD RATE FROM 'XSPEED'
	 ENDIF
;
	RET
;
;....................................................................
;
UNINIT:	RET			;NOT INITIALIZED, SO NO 'UN-INITIALIZE'
;
;....................................................................
;
	END
