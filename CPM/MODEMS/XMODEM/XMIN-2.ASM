
; XMIN-1.ASM XMODEMxx PATCH FILE FOR INTERFACER-4 SERIAL BOARD 11/17/83
;
; This file adapts XMODEMxx to the CompuPro Interfacer 4 serial board.
; (Also the Interfacer 3 board). To use, first edit any options desired
; into XMODEMxx.ASM, then assemble (you can use ASM.COM) and load to get
; XMODEMxx.COM.  Then edit this file as needed (check the CONOUT routine
; if you want to locally see file transfer time and the record count
; while programs are being sent).  Then assemble (you can use ASM.COM)
; and merge via DDT or SID:
;
;	B>DDT XMODEMxx.COM
;	DDT VERS 2.2
;	NEXT  PC
;	1180 0100
;	-IXMIN-1.HEX		(note the 'I' command)
;	-R			('R' loads in the .HEX file)
;	NEXT  PC
;	1180 0000
;	-G0			(return to CP/M)
;	B>SAVE 16 XMODEMxx.COM  (now have a modified .COM file)
;
; NOTE: Save 21 (rather than 16) if LOGCAL is YES
;
;=======================================================================
;
; 12/27/83 - Added USEDCD, some text		- Paul Train
; 05/14/83 - Added instructions, formated	- Irv Hoff
; 03/07/83 - Written				- Paul Traina
;
;=======================================================================
;
; NOTE:  The 2651 is sort of brain damaged (as are several different I/O
;	 chips.  There is a problem if you have a modem that sends result
;	 codes to the computer.  (Examples:  Hayes Smartmodems, Cermetek
;	 Infomate 212a, Robotics).  If the DCD line is low, the 2651 will
;	 ignore any incoming data from the modem.  In BYE, this causes
;	 no problem, but if you desire to use MDM7 or YAM or COMM7 you
;	 cannot receive any result codes until carrier is actually pre-
;	 sent.  For a long time we used to flip a switch (it was switch
;	 #6 on the Smartmodem) to force DCD true, but I have a better
;	 method.  I tie DCD high, so the 2651 thinks that the carrier is
;	 there and doesn't shutdown.  This leaves the problem of sensing
;	 carrier, so I run pin 8 [DCD] from the modem to pin 6 (or pin
;	 20) [DSR] of the serial port.  Then all that is needed is for
;	 you to change the software to sense DSR for carrier instead of
;	 DCD.  I have been using this method for 6 months now and it 
;	 works >>beautifully<<.  If you wish to use this method of sen-
;	 sing DCD by really checking DSR, then set "USEDCD" to no, else
;	 set "USEDCD" to yes and you can operate the old way.
;					- Paul Traina
;
;=======================================================================
; 
YES:	 EQU	0FFH
NO:	 EQU	0
;
USEDCD:	 EQU	NO		;no, check DSR instead of DCD
;
MODDATP: EQU	10H		;data in port
MODDATO: EQU	MODDATP		;data out port
MODCTLP: EQU	MODDATP+1	;control/status port
MODCTL2: EQU	MODDATP+1	;second control/status port
MODUPRT: EQU	MODDATP+7	;chip select port
MODUSER: EQU	6		;modem I/O on inter-3 board		
MODSNDB: EQU	1		;bit to test for send
MODSNDR: EQU	1		;value when ready
MODRCVB: EQU	2		;bit to test for receive
MODRCVR: EQU	2		;value when ready
;
	  IF	USEDCD		;if using DCD
MODDCDB: EQU	80h		;carrier detect bit (DCD line from 2651)
MODDCDA: EQU	80h		;value when active
	  ENDIF
;
	  IF	NOT USEDCD
MODDCDB: EQU	80h		;carrier detect bit (DSR line from 2651)
MODDCDA: EQU	80h		;value when active
	  ENDIF
;
LSPEED:	 EQU	YES		;yes if using 'BYE' with speed selection
				;no if using 'SPEED' manual selection
MSPEED:	 EQU	3CH		;location of baud rate factor (set by
				;'BYE')  set location in 'BYE' to agree.
				;3dh and 3eh often used by newer ver-
				;sions of 'ZCPR'.
XSPEED:	 EQU	1		;speed for file time transfer without
				;auto-set.  use one of the following:
				;0=110 1=300 2=450 3=600 4=710 5=1200
BASE:	 EQU	100H		;start of CP/M normal program area
;
;-------------------------------------------------------------------
;
; Jump table: The jump table must be in exactly the same sequence as the
; one in XMODEM.  Note the ORG of 103H - This jump table has no jump to
; 'BEGIN'.

;
	 ORG	BASE+3		;start after 'JMP BEGIN'
;
CONOUT:	 JMP	00000H		;must be 00000H if not used, see below
PMINIT:	 JMP	MINIT		;initialization routine (if needed)
PUNINIT: JMP	UNINIT		;undo whatever 'MINIT' did (or return)
PSENDR:	 JMP	SENDR		;send character (via pop psw)
PCAROK:	 JMP	CAROK		;test for carrier
PMDIN:	 JMP	MDIN		;receive data byte
PGETCHR: JMP	GETCHR		;get character from modem
PRCVRDY: JMP	RCVRDY		;check receive ready
PSNDRDY: JMP	SNDRDY		;check send ready
PSPEED:	 JMP	SPEED		;get speed value for file transfer time
PEXTRA1: JMP	EXTRA1		;extra for custom routine
PEXTRA2: JMP	EXTRA2		;extra for custom routine
PEXTRA3: JMP	EXTRA3		;extra for custom routine
;
;=======================================================================
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
;		our example it would be:    CONOUT   DW   0E1D4H
;
;
;	CONOUT:	  DW	00000H	;If you wish to show the record count
;				;during program transfer, fill in this
;				;address at 'CONOUT' above.
;
;					- Irv Hoff
;
;=======================================================================
;
; ---> CAROK - check for presence of carrier.  RET with Z = carrier on
;
CAROK:	MVI	A,MODUSER	;select proper chip
	OUT	MODUPRT
	IN	MODCTLP		;get status
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
MDIN:	MVI	A,MODUSER	;select proper chip
	OUT	MODUPRT
	MVI	A,MODDATP
	IN	MODDATP		;get character from data in port
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
RCVRDY:	MVI	A,MODUSER	;select proper chip
	OUT	MODUPRT
	IN	MODCTLP		;get modem status
	ANI	MODRCVB		;isolate ready bit
	CPI	MODRCVR		;test it
	RET
;
;=======================================================================
;
; ---> SENDR -- send character (comes here via a "JZ SENDR" so no stack
;		problems with the "POP PSW" in this routine.
;
SENDR:	MVI	A,MODUSER	;select proper chip
	OUT	MODUPRT
	POP	PSW		;get the character back
	OUT	MODDATO		;send it to the modem output
	RET
;
;=======================================================================
;
; ---> SNDRDY - check if ready to send.
;
SNDRDY:	MVI	A,MODUSER	;select proper chip
	OUT	MODUPRT
	IN	MODCTLP		;get status byte
	ANI	MODSNDB		;isolate ready bit
	XRI	MODSNDR		;ready to send?
	RET
;
;=======================================================================
;
; ---> SPEED - sets the time shown for program transfer.
;
SPEED:	 IF	LSPEED
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
;
	END