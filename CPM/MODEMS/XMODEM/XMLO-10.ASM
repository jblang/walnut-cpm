
; XMLO-10.ASM - XMODEMxx overlay file for the Lobo Max-80 computer  06/15/84
;
; This file adapts XMODEMxx to the Lobo Max-80 computer.  To use, edit
; any options desired into XMODEMxx.ASM, then assemble (can use ASM.COM)
; and load to get XMODEMxx.COM.  Then edit this file as needed (check
; the CONOUT routine if you want to locally see file transfer time and
; the record count while programs are being sent or insure that USECON
; on ByeII or BYE3 is set YES.)  Then assemble (can use ASM.COM) and
; merge the .HEX file with XMODEMxx.COM by using MLOAD (part of the
; MEX modem program distribution and available separately from most
; RCP/M's):
;
;   MLOAD XMODEM.COM=XMODEMxx.COM,XMLO-10.HEX
;
; This will create XMODEM.COM, the ready-to-use program.
;
;=======================================================================
;
; 06/15/84  Rewritten and renamed	- Peter N. Glaskowsky
; 01/01/84  Updated to XMODEM84		- Irv Hoff
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
;=======================================================================
; 
; Define True and False
;
YES:	  EQU	0FFH
NO:	  EQU	0
;
;=======================================================================
;
; Modem & Data Equates
;
MODDATP:  EQU	0F7E4H		;data in port for kaypro computers
MODCTLP:  EQU	MODDATP+1	;control/status port
MODSNDB:  EQU	04H		;bit to test for send
MODSNDR:  EQU	04H		;value when ready
MODRCVB:  EQU	01H		;bit to test for receive
MODRCVR:  EQU	01H		;value when ready
MODDCDB:  EQU	08H		;carrier detect bit
MODDCDA:  EQU	08H		;value when active
MODPARE:  EQU	10H		;value for parity error
MODOVRE:  EQU	20H		;value for overrun error
MODFRME:  EQU	40H		;value for framing error
MODRESI:  EQU   10H		;reset external status/interrupts
MODERES:  EQU   30H		;error reset
;
;
LSPEED:	  EQU	YES		;true if using by2-17ks or any bye2-xx
				;false if using 'SPEED' manual selection
MSPEED:	  EQU	3CH		;location of baud rate factor (set by
;				;'BYE')  SET LOCATION IN 'BYE' TO AGREE.
;				;3DH AND 3EH OFTEN USED BY NEWER VER-
;				;SIONS OF 'ZCPR'.
XSPEED:	  EQU	5		;speed for file time transfer without
;				;AUTO-SET.  USE ONE OF THE FOLLOWING:
;				;0=110 1=300 2=450 3=600 4=710 5=1200
BASE:	  EQU	100H		;start of cp/m normal program area
;
;=======================================================================
;
; Jump table: The jump table must be in exactly the same sequence as the
; one in XMODEM.
;
	  ORG	BASE+3		;start after 'JMP BEGIN'
;
CONOUT:   JMP	0C7AEH		;must be 00000h if not used, see below
				;shown for Max-80 with NZCPR V2.1
PMINIT:	  JMP	MINIT		;initialization routine (if needed)
PUNINIT:  JMP	UNINIT		;undo whatever 'MINIT' did (or return)
PSENDR:	  JMP	SENDR		;send character (via pop psw)
PCAROK:	  JMP	CAROK		;test for carrier
PMDIN:	  JMP	MDIN		;receive data byte
PGETCHR:  JMP	GETCHR		;get character from modem
PRCVRDY:  JMP	RCVRDY		;check receive ready
PSNDRDY:  JMP	SNDRDY		;check send ready
PSPEED:	  JMP	SPEED		;get speed value for file transfer time
PEXTRA1:  JMP	EXTRA1		;extra for custom routine
PEXTRA2:  JMP	EXTRA2		;extra for custom routine
PEXTRA3:  JMP	EXTRA3		;extra for custom routine
;
;=======================================================================
;
; -- To Display the Record Count on the CRT During Program Transfers --
;
;	The CRTOUT routine below may be used if you know the ports used
; by your CRT for status and data.  (Cannot be used with memory mapped
; displays.)  If using the CRTOUT routine, skip rest of this discussion.
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
;
;	So with the disk containing BYE, but prior to activating BYE, do
; this:
;		1) Cold reboot to move CP/M (and BIOS) to the new area
;		    needed when BYE is activated on the same disk.
;		2) Use DDT and dump the area from 0000H to 0002H.  This
;                   gives the warm reboot address in BIOS.
;		3) Add 9 Bytes to that address to get your console out-
;		     put jump vector.
;		4) Pick off the address contained in the jump vector and
;		     install that in "CONOUT", below.  Example of one
;		     system in use:
;
;			FIRST, COLD REBOOT WITH DISK CONTAINING "BYE"
;
;	  0000  C3 03 E0    (location of warm reboot on disk with BYE
;
;			PRIOR TO ACTIVATING BYE BUT ON SAME DISK
;
;	  E003  C3 E9 E0    (BIOS warm reboot jump vector on this disk)
;	  E006  C3 00 E9    (BIOS get console status routine)
;	  E009  C3 B7 E1    (BIOS console input routine)
;	  E00C  C3 D4 E1    (BIOS console output routine)
;
;		The address we need is thus E1D4.  Put that below, in
;		our example it would be:    CONOUT   JMP   0E1D4H
;
;
;	CONOUT:	  JMP	00000H	;If you wish to show the record count
;				;during program transfer, fill in this
;				;address at 'CONOUT' above.
;
;					- Irv Hoff
;
;=======================================================================
;
; ---> CAROK - check for presence of carrier.  RET with Z = carrier on
;
CAROK:
	MVI	A,MODRESI	;reset external status/interrupts
	STA	MODCTLP
	LDA	MODCTLP		;get status
	ANI	MODDCDB		;get carrier detect bit
	CPI	MODDCDA		;test bit
	RET
;
;=======================================================================
;
EXTRA1:	RET			;for later use
EXTRA2:	RET			;for later use
EXTRA3:	RET			;for later use
;
;=======================================================================
;
; ---> GETCHR - get a character, same as MDIN
; ---> MDIN - - get a character, same as GETCHR
;
GETCHR:
MDIN:	LDA	MODDATP		;get character from data in port
	RET
;
;=======================================================================
;
MINIT:	RET			;no initialization required
;
;=======================================================================
;
; ---> RCVRDY - check receive ready.  RET with Z = character available.
;	        Return with error code in A-reg.
;
RCVRDY:	LDA	MODCTLP		;get modem status
	PUSH	B		;save scratch register
	PUSH	PSW
	MVI	A,1+MODRESI	;select read register 1
	STA	MODCTLP
	LDA	MODCTLP		;read the error status
	ANI	MODFRME+MODOVRE+MODPARE
	MOV	B,A		;save it for a moment
	MVI	A,MODERES
	STA	MODCTLP		;do an error reset command
	POP	PSW		;now get modem status back
	ANI	MODRCVB		;isolate ready bit
	CPI	MODRCVR		;test it
	MOV	A,B		;get the error code char. back
	POP	B
	RET
;
;=======================================================================
;
; ---> SENDR - send character
;
SENDR:	POP	PSW		;get the character back
	STA	MODDATP		;send it to the modem output
	RET
;
;=======================================================================
;
; ---> SNDRDY - check if ready to send.
;
SNDRDY:	LDA	MODCTLP		;get status byte
	ANI	MODSNDB		;isolate ready bit
	CPI	MODSNDR		;ready to send?
	RET
;
;=======================================================================
;
; ---> SPEED - sets the time shown for program transfer.
;
SPEED:	EQU	$
;
	 IF	LSPEED
	LDA	MSPEED		;get index for baud rate from 'BYE'
	 ENDIF
;
	 IF 	NOT LSPEED
	MVI	A,XSPEED	;get index for baud rate from 'XSPEED'
	 ENDIF
;
	RET
;
;=======================================================================
;
UNINIT:	RET			;not initialized, so no 'UN-INITIALIZE'
;
;=======================================================================
;
	END
