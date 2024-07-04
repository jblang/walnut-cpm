; WHEEL.ASM  -	Password access for ZCPR/ZCMD systems  -  05/20/86
;
;		  copyrighted by Irv Hoff W6FFC
;
;
	ASEG			; For M80 and RMAC ignore error with MAC
;
; This program permits the SYSOP to activate the WHEEL byte.  This kicks
; in the drives and user areas set for the Sysop in place of those set
; for the remote user.
;
; There are several ways to change these allocations:
;
;	1) Using ZCMD or ZCPR without BYE5 for remote use
;	2) Using ZCMD or ZCPR with BYE5 for remote use
;	3) Using ZCMD or ZCPR with/without BYE5 with external flow path
;
; All of these cases are covered.  In the case of an external flow path
; be sure to set the EXTPATH equate below.
;
; This program is placed in A0: so the Sysop can request it without the
; WHEEL byte being activated.  Since any user could do the same, several
; levels of security are included:
;
;	1) Go to the 'special attention' area below and:
;		a) add your own password at PSSWD (use only upper-case)
;		b) select remote user's max drive/user
;		c) select Sysop's max drive/user
;		d) select external path (if used in ZCMD or ZCPR)
;
;	2) Assemble and load to get WHEEL.COM
;	3) Rename program for additional security, instead of WHEEL.COM
;	4) Place on A0: and 'hide' with STAT.COM as a .SYS file
;
;		A0>STAT	IRV.COM	$SYS	; (So the name can't be seen)
;
;	5) Assuming for the example "HOFF" was chosen for a password:
;
;		A0>IRV HOFF	; To enable the wheel byte mode
;		A0>IRV -	; Resets for remote user, types msg.
;		A0>IRV
;		   Password:	; Requests password, which is not
;				; displayed so nobody can see what you
;				; are using
;
;-----------------------------------------------------------------------
;
; IRV.COM would be the first level of security.  Hiding it as a system
; file on A0: prevents others from knowing the initial program's name.
; HOFF in this case would be the second level of security.  Even if you
; type:  A0>IRV <ret> when some remote user is watching, and they see
; the request for a password, they will not see your answer.  If it is
; wrong, it wipes out the 'Password: ' and replaces it with the name of
; the program with a '?' as though CP/M doesn't know what you are asking
; for and there is no such program - another mild form of security.
;
; If some twit does attempt to find your initial password (name of pgm)
; and uses the correct name (IRV in this case), it resets for remote
; user (without displaying any message) and then shows IRV? indicating
; no such file exists.	(It really does, but this is an additional level
; of security to discourage twits.)
;
; SUMMARY:
; =======
;	There may be other programs existing with similar features but
;	none I ran across have as much security as this program, which
;	is why I wrote it.  I use it with ZCMD2x, BYE5 and KMD on two
;	different systems, one having a BBS and one without.  This is
;	also useful for giving friends access to your system when you
;	do not have a BBS that automatically asks their name and kicks
;	them in as a Sysop.  The primary use though, is so the Sysop
;	can kick in his own capability whenever he wishes, perhaps on
;	some occasion a particular user is on his system and the Sysop
;	needs more capability than the remote user is normally given.
;
;					- Notes by Irv Hoff
	ORG	0100H
;
	JMP	START
;
;
;=======================================================================
;		(start of special attention area)
;
; NOTE: Set the following four values for your system's normal use:
;
RDRIVE	EQU	2		; Number of drives available to user
RUSER	EQU	12		; # of highest area for remote users
SDRIVE	EQU	2		; Number of drives available to SYSOP
SUSER	EQU	15		; # of highest area for SYSOP (0-15)
;.....
;
;
; Put your password here, end it with a '0', can be 15 characters or
; less, not including the 0.
;
PSSWRD:	DB	'PASS'		; Up to 15 characters, end with 0 below
	DB	0
;
;
; If using an external path, set the following equate YES and check the
; address of the external path in the line following that, usually 40h.
;
EXTPATH	EQU	0		; 0 = NO, 1 = YES		
PATHADR	EQU	40H		; Change if needed
;
;		(end of special attention items)
;=======================================================================
;
; Tells the SYSOP the WHEEL byte is now activated
;
WHLMSG:	DB	0DH,0AH,'   WHEEL is on',0DH,0AH,'$'
WHLOFF:	DB	0DH,0AH,'   WHEEL is off',0DH,0AH,'$'
;.....
;
;
; Equates
;
BDOS	EQU	0005H		; BDOS location
CR	EQU	0DH		; Carriage return character
DIRCON	EQU	0006H		; Direct console call
LF	EQU	0AH		; Line feed character
FCB	EQU	005CH		; File control block
DRVMAX	EQU	003DH		; Location of MAXDRV byte
PRINT	EQU	09H		; BDOS print a string
USRMAX	EQU	003FH		; Location of MAXUSER byte
WHEEL	EQU	003EH		; Location of wheel byte
WRCON	EQU	02H		; Display a character on CRT
;
;
START:	LDA	FCB+1		; See what we are supposed to do
	CPI	' '
	JZ	ASKFOR		; Nothing typed, ignore request
	CPI	'-'		; Disable wheel mode
	JZ	DISABLE
;
CHECK:	LXI	H,FCB+1		; Set up all the pointers
	LXI	D,PSSWRD	; Location of password buffer
;
CHECK1:	LDAX	D		; Actual password in 'A' register
	ORA	A
	JZ	OK		; If zero, checks ok
	CMP	M		; Characters match?
	JNZ	ABORT		; No check, exit with no changes
	INX	H		; Address of next password address
	INX	D		; Address of next password typed entry
	JMP	CHECK1		; If not zero, check another character
;
OK:	JMP	ENABLE
;
;
;-----------------------------------------------------------------------
;			  subroutines
;-----------------------------------------------------------------------
;
; Aborts if a person happens to type to correct filename, reprints the
; name to throw him off, then resets the system for a remote user, as an
; added level of security.
;
ABORT:	MVI	C,PRINT
	LXI	D,ABTCLR
	CALL	BDOS
;
	LDA	0002H		; MSP of BIOS address
	SUI	22
	MOV	H,A
	MVI	L,8		; Index into buffer
;
ABORT1:	MOV	A,M		; Get the character there
	ORA	A		; See if finished
	JZ	ABORT2
	CPI	' '
	JZ	ABORT2
	CALL	SHOW
	INX	H		; Next location
	JMP	ABORT1
;
ABORT2:	MVI	A,'?'
	CALL	SHOW
	MVI	A,LF
	CALL	SHOW
;
ABORT3:	JMP	DISAB0		; Go disable the drives
;...
;
;
ABTCLR:	DB	CR,'                ',CR,'$' ; wipes out 'Password: '
;.....
;
;
; Asks for a password if none was given, allows typing so nobody can
; see what it is.  (Just the local typist.)
;
ASKFOR:	MVI	C,PRINT
	LXI	D,ASKPAS
	CALL	BDOS
	LXI	D,FCB+1		; Location to put password for compare
;
ASK1:	PUSH	D
	MVI	C,6		; Direct console I/O
	MVI	E,0FFH		; Ask for character
	CALL	BDOS
	POP	D		; Get the address back
	ORA	A
	JZ	ASK1
;
	CPI	'a'		; Make sure character is upper case
	JC	ASK2
	CPI	'z'+1
	JNC	ASK2
	ANI	5FH		; Change to upper-case
;
ASK2:	CPI	CR
	JZ	CHECK
	STAX	D
	INX	D
	JMP	ASK1
;...
;
;
ASKPAS:	DB	'   Password is: ','$'
;.....
;
;
; Change the external path from Sysop to remote or vice versa
;
CHANGE:	MVI	C,7
;
CHANG1:	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	DCR	C
	JNZ	CHANG1
	RET
;.....
;
;
; See if BYE5 is active
;
CKBYE:	MVI	C,32
	MVI	E,0F1H
	CALL	BDOS
	CPI	4DH
	RET
;.....
;
;
; Intentional disable shows the WHEEL is off, then resets the system
; for a normal remote user again.
;
DISABLE:MVI	C,PRINT		; WHEEL "OFF" message
	LXI	D,WHLOFF
	CALL	BDOS
;
DISAB0:	XRA	A		; Turn the WHEEL byte off
	STA	WHEEL
	CALL	CKBYE		; See if BYE5 is active
	JNZ	DISAB1		; If yes exit
;...
;
;
; BYE5 is in use, so set things through it.  First get the BYE5 address
; and then increment into the program to the location of max user (+12_
; and max drive (+13).
;
	CALL	SETBYE
;
; Now have the max user address
;
	LDA	RUSER+1
	MOV	M,A
	INX	H		; Address of max drive
	LDA	RDRIVE
	MOV	M,A
;
;
; No BYE5 in use, assume ZCMD or ZCPR is setting max drive and max user.
;
DISAB1:	MVI	A,RUSER+1	; Sysop maximum user area
	STA	USRMAX
	MVI	A,RDRIVE-1	; Sysop number of drives
	STA	DRVMAX
	STA	DRVMAX
;
	 IF	EXTPATH
	LXI	D,RPATH		; Remote user external path, prevents
	LXI	H,PATHADR	;   his using A15:
	CALL	CHANGE
	 ENDIF			; EXTPATH
;
	JMP	EXIT
;.....
;
;
; Set the WHEEL, max user, max drive but first check to see if BYE is
; active and handle accordingly.
;
ENABLE:	MVI	A,0FFH		; Turn the WHEEL byte on
	STA	WHEEL
;
	MVI	C,PRINT		; WHEEL in use message
	LXI	D,WHLMSG
	CALL	BDOS
	CALL	CKBYE		; See if BYE5 is active
	JNZ	ENAB1		; Exit if BYE5 is in use
;
;
; BYE5 is in use, so set things through it.  First get the BYE5 address
; and then increment into the program to the location of max user (+12_
; and max drive (+13).
;
	CALL	SETBYE
;
; Now have the max user address
;
	LDA	SUSER+1
	MOV	M,A
	INX	H		; Address of max drive
	LDA	SDRIVE
	MOV	M,A
;
;
; No BYE5 in use, assume ZCMD or ZCPR is setting max drive and max user.
;
ENAB1:	MVI	A,SUSER+1	; Sysop maximum user area
	STA	USRMAX
	MVI	A,SDRIVE-1	; Sysop number of drives
	STA	DRVMAX
;
	 IF	EXTPATH
	LXI	D,SPATH		; Sysop external path (includes user 15)
	LXI	H,PATHADR
	CALL	CHANGE
	 ENDIF			; EXTPATH
;...
;
;
EXIT:	RET			; Jump back to original address
;.....
;
;
; Remote user's external path flow - WHEEL off - if any paths are added,
; alter the value at CHANGE: above.
;
RPATH:	DB	'$','$'		; Current drive, user area
	DB	1,0		; 'A' drive, 0 user area
	DB	0,0		; Skips additional checks
	DB	0		; Finished
;.....
;
;
; Sysop's external path flow - WHEEL off - if any paths are added,
; alter the value at CHANGE: above.
;
SPATH:	DB	'$','$'		; Current drive, user area
	DB	1,0		; 'A' drive, 0 user area
	DB	1,15		; 'A' drive, 15 user area
	DB	0		; Finished
;.....
;
;
SETBYE:	LHLD	0000H+1		; Warm boot vector address
	DCX	H		; MSP of cold boot vector
	MOV	D,M		; Put into 'D' register
	DCX	H		; LSP of cold boot vector
	MOV	E,M		; Put into the 'E' register
;
; Now have the BYE5 MCBOOT location, add 6 to find max user location.
;
	LXI	H,6
	DAD	D		; Add to MCBOOT location
	RET
;.....
;
;
SHOW:	PUSH	H
	MOV	E,A
	MVI	C,WRCON
	CALL	BDOS
	POP	H
	RET
;.....
;
;
	END
