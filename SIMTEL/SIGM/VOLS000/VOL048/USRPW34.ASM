;
;	USERPW.ASM  version 3.4   11/03/81
;	  By Dave Hardy
;
;
;    USERPW is used to replace the 'USER' command in a remote
;    CP/M system, which is usually removed to restrict users
;    to the lower user areas. USERPW will allow password access
;    to any group of user areas via any number of passwords
;    that are specified in an external file called PWFILE.
;    An option is also available that allows only a single
;    built-in password to be used, as in the original version.
;    Public access is available to all user areas with values less
;    than MAXUSER (set below), and USERPW will also allow password
;    access to the 'restricted' user areas.  If the caller
;    types only the filename, with no user number on the command
;    tail, the program will tell the caller what user number he
;    is in and give instructions.
;
;   If the PWFILE option is selected, then the entered password will
;    be compared with a disk-resident file called PWFILE kept in a
;    user area specified by the PWUSR equate.  PWFILE contains one
;    password on each line, followed by all of that passwords allowed
;    user areas, all items separated by commas.  The last line of the
;    file must contain a '$' to indicate the end-of-file.
;
;PWFILE STRUCTURE IS:	PASSWORD1,X,Y<cr><lf>	<--X and Y are USER #'s
;			PASSWORD2,Y<cr><lf>
;			etc....
;			$			<--this must be here
;
;  Modification history:
;
;11/03/81 Removed BACKSPACE and DELETE code to prevent nightmare
;	  bug that allowed remote callers to backspace over code 
;	  and cause PWFILE to be printed as part of "INCORRECT"
;	  error messages.
;	  By Dave Hardy
;
;08/24/81 Cleaned up file, made compatible with MAC/ASM, made lower
;	  case trap conditional (since some PW's might want them,
;	  or numbers, etc.), changed PW error jump to eliminate
;	  reloading PWFILE, corrected errors in BADPW routine,
;	  and separated GOCCP code to avoid confusion.
;	  By Dave Hardy
;
;08/23/81 Added multiple tries at PW, Trap for lower case,
;         cleaned up code and added many needed C/R's & L/F's.
;         By Jim C., Larkspur, Ca. RCPM (415) 461-7726
;
;08/19/81 Added equates for use with the GOCCP program.
;         By Larry Shipinski
;
;08/18/81 Moved PWFILE loader CALL so that PWFILE will be loaded 
;	  before asking for PW, to eliminate the noticeable delay
;	  before warm-boot, cleaned up code, and added comments.
;	  By Dave Hardy
;
;08/11/81 Added RANGE conditional to allow PW access to a range of
;	  user areas.  For example, if the range is from 1 to 4, then
;	  once a user has logged into any user area within the range,
;	  he may log into any other user areas within the range without
;	  having to re-enter the password.  This is similar to the
;	  LOGONCE option, but allows any range of user numbers to be
;	  selected, while the range of LOGONCE includes all non-zero
;	  user areas.  In addition, RANGE can only be used if the
;	  PWFILE conditional is selected, and LOGONCE can only be
;	  used if the PWFILE conditional is NOT selected.
;	  By Dave Hardy
;
;08/09/81 Added PWFILE conditional to allow multiple passwords to be
;	  readfrom a file, so that separate PW's can be used for
;	  different user areas.  The number of PW's will be limited
;	  only by the amount of available memory in the TPA.
;	  The file of passwords can be kept in any user area,
;	  and can be created with any editor.  Multiple user areas
;	  are available to each password.  The format of the PWFILE
;	  is defined at the beginning of this file.
;	  By Dave Hardy
;
;08/03/81 Changed console input routines to DIRECT I/O so that
;	  password will not be echoed.  This should make the
;	  program's function a bit more secure by making it more
;	  difficult to see what password has been typed.
;	  By Dave Hardy
;
;07/12/81 Added TELUSR routines to inform caller of current user
;	  number and how to use program.  Changed version number
;	  to 2.1 instead of 3.0, because I'm still working on a
;	  major revision of USERPW to be released as version 3.0.
;	  By Dave Hardy
;
;05/23/81 Added LOGONCE option so that program will not ask for PW
;	  if user is already in password-accessible user area.
;	  By Dave Hardy
;
;  Define miscellaneous values:
DFCB	EQU	5CH	;Default File Control Block address
SETUSR	EQU	32	;BDOS Set User function
PRNSTR	EQU	9	;BDOS Print String function
OPEN	EQU	15	;BDOS Open File function
STDMA	EQU	26	;BDOS Set DMA Address function
READ	EQU	20	;BDOS Read Sequential function
CONOUT	EQU	2	;BDOS Print Character function
DIRIO	EQU	6	;BDOS Direct Console I/O function
INPUT	EQU	0FFH	;Value passed to DIRIO to do console input
BDOS	EQU	5	;CP/M's BDOS jump
USERDR	EQU	4	;CP/M's USER/DRIVE select byte
WBOOT	EQU	0	;CP/M's warm-boot address
CR	EQU	0DH	;ASCII carriage-return
LF	EQU	0AH	;ASCII line-feed
;
;  Define TRUE and FALSE:
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;
;  Set the following equates as desired:
;
MAXUSER EQU	0	;Set to highest PUBLIC user area desired
ABSUSER	EQU	15	;Set to highest PW ACCESS user area desired
MAXTRYS	EQU	03	;Max # of PW attempts before exit to CP/M
PWFILE	EQU	TRUE	;True, if PW's from file instead of built-in
PWUSR	EQU	21	;User area where PWFILE is to be kept
PWDRV	EQU	1	;Drive where PWFILE is kept (1=A, 2=B, etc.)
TRAPLC	EQU	FALSE	;True, if want to only use upper-case PW's
RANGE	EQU	TRUE	;True, if no ask for PW when within ranges
HRANGE	EQU	4	;High-end value of "no ask" range
LRANGE	EQU	1	;Low-end value of "no-ask" range
LOGONCE	EQU	FALSE	;True, if desire log-in only from user 0
			;SHOULD BE FALSE if PWFILE is used
;
;
;  The following code is for use with the GOCCP program, which
;  is a CCP substitute.  If you are not using GOCCP, then setting
;  GOCCP to TRUE will cause unpredictable results.  NOTE that this
;  option requires that you set the label CCP equal to the address
;  of the CCP in your system.  This address can be determined most
;  easily by using the STATUS or BDLOC programs.
;
GOCCP	EQU	FALSE	;True, if using the GOCCP program
	IF	GOCCP
CCP	EQU	3400H		;Set to start of CCP in your system
REQUSR	EQU	CCP+7FEH	;Store requested USER number in CCP
	ENDIF
;
;
;
	ORG	100H
;
	XRA	A		;Initialize first pass flag
	STA	FLAG		;Set First pass flag
;
	LXI	H,DFCB+1 ;Point to specified USER # in command line
	MVI	E,0	;Initialize user number accumulator
	MOV	A,M	;Check that there is something in command line
	CPI	20H
	JZ	TELUSR	;Nothing?  then tell user number and give help
;
NUMLUP	MOV	A,M	;Get first character
	INX	H	;Point to next location in command line
	SUI	'0'	;Remove ASCII bias
	JC	NUMDONE	;Exit with specified user number in E
	CPI	10	;Check for illegal number (>9)
	JNC	NUMDONE	;Stop if illegal character found
	MOV	D,A	;Get specified user number
	MOV	A,E	; into A register
	ADD	A
	ADD	A
	ADD	E
	ADD	A
	ADD	D
	MOV	E,A	;Save accumulation
	JMP	NUMLUP	;Loop back for next character
;
TELUSR	LXI	D,TUMSG	;Tell the user what user number he's in
	MVI	C,PRNSTR
	CALL	BDOS
	LDA	USERDR	;Get current USER number
	RRC
	RRC
	RRC
	RRC
	ANI	0FH
	CPI	0AH
	JC	LT10
	PUSH	PSW	;Save user number
	MVI	E,'1'	;If user # is 10-16, then print leading '1'
	MVI	C,CONOUT	;This routine won't work
	CALL	BDOS		;if your CCP allows more than 19 user areas.
	POP	PSW	;Restore user number
	SUI	0AH
LT10	ADI	30H	;Print user number
	MOV	E,A
	MVI	C,CONOUT
	CALL	BDOS
	MVI	E,'.'	;Get a period
	MVI	C,CONOUT
	CALL	BDOS	;Make cosmetic
;
	CALL	ERRXIT	;Print rest of message, then exit to CP/M
	DB	CR,LF,'To change user areas, type user number '
	DB	'on command line.',CR,LF
	DB	'For example, type: USER 3   to enter'
	DB	' user area 3.',CR,LF,'$'
;
NUMDONE	MOV	A,E	;Get requested user number
	STA	REQUSR	;Save for later, if needed
	ORA	A
	RM		;Exit if illegal user number
	CPI	ABSUSER+1
	JNC	NOBODY	;Illegal user area request
	CPI	MAXUSER+1
	JNC	SOME	;Password user area request
CHANGE	RLC		;Move to upper nibble
 	RLC
 	RLC
 	RLC
	MOV	B,A	;Save requested user number
	LDA	USERDR	;Get current user/drive number
	ANI	0FH	;Trim off old user number
	ORA	B	;Add new user number
	STA	USERDR	;Set new user number
	LDA	REQUSR
	MOV	E,A
	MVI	C,SETUSR ;Set user number with BDOS call, too.
	JMP	BDOS	 ;  then exit
;
;
;  REQUEST FOR RESTRICTED USER AREA, SO ASK FOR PASSWORD
;
SOME	EQU	$
;
	IF	LOGONCE	;then see if user has already logged in
	LDA	USERDR	;Get USER NUMBER/DRIVE
	ANI	0F0H
	RLC
	RLC
	RLC
	RLC
	MVI	B,MAXUSER+1
	CMP	B
	JNC	GOTPW	;If in non-public user area, PW was already
			; given so don't ask again
	ENDIF
;
	IF	PWFILE AND RANGE	;Then check for already in RANGE
	LDA	USERDR			;Get USER/DRIVE number
	ANI	0F0H
	RLC
	RLC
	RLC
	RLC
	MVI	B,HRANGE+1		;See if above RANGE
	CMP	B
	JNC	PRANGE			;Jump if above RANGE
	MVI	B,LRANGE		;See if below RANGE
	CMP	B
	JC	PRANGE			;Jump if below RANGE
	LDA	REQUSR	;Now see if requested user# is in RANGE
	MVI	B,HRANGE+1		;See if above RANGE
	CMP	B
	JNC	PRANGE			;Jump if above RANGE
	MVI	B,LRANGE		;See if below RANGE
	CMP	B
	JC	PRANGE			;Jump if below RANGE
	JMP	GOTPW	;If already in RANGE, and new user # is also in
	ENDIF		; RANGE, then don't ask for PW
;
PRANGE	EQU	$
;
	IF	PWFILE
	CALL	LODPWF	;Load the file of PW's
	ENDIF
;
PR2	LDA	FLAG	;Get # of passes
	ORA	A	;First pass?
	JZ	NOCRLF	;If yes, then no CRLF needed
	LXI	D,CRLF	;Else print a CRLF to put next PW on a new line
	MVI	C,PRNSTR
	CALL	BDOS	;Print CRLF
NOCRLF	LXI	D,MSG	;Ask for password
	MVI	C,PRNSTR
	CALL	BDOS
;
	LXI	H,CONBUF	;Reset console buffer pointer
	MVI	C,10H		;Allow 16 characters maximum
TRYAGN	PUSH	B
	PUSH	H
	MVI	C,06H	;Direct console I/O
	MVI	E,0FFH	;Console input
	CALL	BDOS	;Get password, 1 character at a time
	POP	H
	POP	B
	ORA	A	;Wait for input
	JZ	TRYAGN
;
	IF	TRAPLC
	CPI	060H	;Lower Case?
	JC	NOTLC	;No, Skip.
	ANI	05FH	;Strip L/C.
	ENDIF
;
NOTLC	CPI	0DH	;Carriage return?
	JZ	CHKPW	;If yes, then check for match
	MOV	M,A	;Put character into buffer
	INX	H	;Increment pointer
	DCR	C	;See if 16 characters entered
	MOV	A,C
	ORA	A
	JNZ	TRYAGN		;If less than 16 characters entered,
				;then continue...
;
	IF	NOT PWFILE	;Then check built-in PW
CHKPW	LXI	H,CONBUF	;Check for match with password
	LXI	D,PASSWD	;Point DE and HL to buffers
NEXT	LDAX	D
	CPI	'$'		;When '$' found, then passwords match,
	JZ	GOTPW		;  so jump
	CMP	M		;Else check for character match
	JNZ	BADPW		;Jump if wrong password given
	INX	H		;Check next character for match
	INX	D
	JMP	NEXT
	ENDIF
;
	IF	PWFILE		;Then check list of PW's in PWFILE
CHKPW	LHLD	LASTPW
	XCHG			;Make DE point to first PW in file
	JMP	FRSTPW		; Then check for match
DONXPW	CALL	GETNXPW		;Returns with DE==>PW or '$' in PWFILE
FRSTPW	LDAX	D		;If DE==>'$' then done, no match
	CPI	'$'		
	JZ	BADPW		;Jump if wrong PW given
	LXI	H,CONBUF	;Point HL to entered password
NEXT	LDAX	D
	CMP	M		;Else check for character match
	JNZ	DONXPW		;If no match, then try next PW
	INX	H		;Else try next character for match
	INX	D
	LDAX	D
	CPI	','		;If ',' found, then passwords may match
	JNZ	NEXT		; If not found, then continue,
	MOV	A,M		;Else check that both PW's are all read
	CPI	0
	JZ	CHKUSR		;If both completely read, then match, so jump
	JMP	DONXPW		;Else try next PW in PWFILE list
;
GETNXPW	LHLD	LASTPW		;Get pointer to last PW checked
NXCH	MOV	A,M
	CPI	0DH		;Scan for carriage return
	JZ	GOTCR		;When CR found, then point to next PW
	CPI	'$'		;Check for '$' here just in case...
	JZ	NOMORE		;If '$' found, then no more PW's
	INX	H
	JMP	NXCH
;
GOTCR	INX	H		;Skip over LF
	INX	H		;And point to next PW
	SHLD	LASTPW		;Save pointer to current PW
NOMORE	XCHG			;MAKE DE==>PW or '$'
	RET			;Then return to calling routine
;
CHKUSR	XCHG		;Make HL==>first user number in PWFILE line
	INX	H
NXNUM	MVI	E,0	;Initialize USER number accumulator
NUMLUP2	MOV	A,M	;Get first character
	INX	H	;Point to next location in command line
	SUI	'0'	;Remove ASCII bias
	JC	CMPUSR	;Exit with specified user number in A
	CPI	10	;Check for illegal number (>9)
	JNC	CMPUSR	;Stop if illegal character found
	MOV	D,A	;Get specified user number
	MOV	A,E	; into A register
	ADD	A
	ADD	A
	ADD	E
	ADD	A
	ADD	D
	MOV	E,A	;Save accumulation
	JMP	NUMLUP2	;Loop back for next character
;
CMPUSR	DCX	H	;Back up pointer (NUMLUP2 advanced 1 too many)
	LDA	REQUSR	;Compare allowable user# to the requested one.
	CMP	E
	JZ	GOTPW	;Jump if they match, change user #, then exit
	MOV	A,M	;Check for CR, which means no more user areas
	CPI	0DH	;Jump if no more, and say "denied"
	JZ	NOBODY2
	INX	H	;Skip over ',' and point to next user number
	MOV	A,M	;Check for CR, which means no more user areas
	CPI	0DH	;Jump if no more, and say "denied"
	JZ	NOBODY2
	JMP	NXNUM	;Try next user number in PWFILE line
	ENDIF
;
GOTPW	LDA	REQUSR		;Get back requested user number
	JMP	CHANGE		;Change user number and exit
;
BADPW	MVI	C,PRNSTR	;Print "BAD PASSWORD" message
	LXI	D,BADMSG
	CALL	BDOS
;
	IF	PWFILE	;Then initialize CONBUF and PW pointer
	CALL	INIT		
	ENDIF
;
	IF	NOT PWFILE	;Then just initialize CONBUF
	LXI	H,CONBUF
	MVI	C,17
NXIN	MVI	M,0
	INX	H
	DCR	C
	JNZ	NXIN
	ENDIF
;
	LDA	FLAG		;Get # of trys flag
	INR	A		;Increment # of trys.
	STA	FLAG
	CPI	MAXTRYS		;See if max guesses...
	JC	PR2		;If more tries allowed, then jump
;
NOBODY2	LXI	D,CRLF	;Print 'NO ACCESS' msg on new line, then exit to CP/M
	MVI	C,PRNSTR
	CALL	BDOS
;
NOBODY	CALL	ERRXIT	;Print 'NO ACCESS' message, then exit to CP/M
	DB	'Sorry, that user area is not available.','$'
;
;	Routine to load the password file
	IF	PWFILE
LODPWF	MVI	E,PWUSR
	MVI	C,SETUSR
	CALL	BDOS	;Set to whatever user number that PWFILE is in
	MVI	A,PWDRV	;Initialize FCB for selected drive
	STA	LOCFCB
	LXI	H,LOCFCB+12
	MVI	B,21
ZLOOP	MVI	M,0
	INX	H
	DCR	B
	JNZ	ZLOOP
	MVI	C,OPEN	;Open the file
	LXI	D,LOCFCB
	CALL	BDOS
	INR	A
	JZ	ABORT	;If A has 0 then no file, so abort
;
;	Now load the file
;
	LHLD	6	;Check for attempt to load past top of memory
	LXI	D,-80H
	DAD	D
	PUSH	H	;Save top of memory for later checks
;
	LXI	D,PWBUF-80H	;Point to file load area-80H
	LXI	B,0	;Initialize record counter
	PUSH	B	; and save it
	PUSH	D	;Save load address, too
GLOOP	POP	D	;Get last load address
	LXI	H,80H	;Point HL to next address to read to
	DAD	D
	POP	B	;Increment the record counter
;
;	Check for attempt to load past top-of-memory
;
	POP	D	;Get -(TOP-OF-MEMORY)
	PUSH	D	;Save again for next time
;
	MOV	A,E	;Subtract: (TOP) - (ADRS)
	SUB	L
	MOV	A,D	;Look at carry to see if out of memory
	SBB	H
;
	JNC	SIZEOK	;Jump if enough room
	CALL	ERRXIT	; Else print message and abort
	DB	'+++DATA AREA TOO SMALL FOR PWFILE','$'
;
SIZEOK	INX	B	;Continue loading...
	PUSH	B
	PUSH	H	;Save load address
	XCHG
	MVI	C,STDMA ;Set DMA address for next read
	CALL	BDOS
	LXI	D,LOCFCB ;Then read the next sector
	MVI	C,READ
	CALL	BDOS
	ORA	A
	JZ	GLOOP	;If A=0 then more to read
	POP	B
	POP	B	;Restore record counter
	POP	H
	MOV	A,B
	ORA	C
	JZ	ABORT	;If 0 then nothing read, so abort
	LXI	D,80H	;Else, reset DMA address
	MVI	C,STDMA
	CALL	BDOS
INIT	LXI	H,CONBUF	;Initialize console input buffer
	MVI	C,17
NXINIT	MVI	M,0
	INX	H
	DCR	C
	JNZ	NXINIT
	LXI	H,PWBUF
	SHLD	LASTPW	;Save pointer to first PW in file
	RET		; and return
;
ABORT	CALL	ERRXIT
	DB	'+++CANNOT FIND PW FILE, ACCESS DENIED','$'
	ENDIF
;
ERRXIT	POP	D
	MVI	C,PRNSTR
	CALL	BDOS	;PRINT THE ABORT MSG, THEN EXIT
	JMP	WBOOT
;
;
;  Some miscellaneous messages:
;
MSG	DB	'PW=','$'	;Msg to ask user for pw
;
BADMSG	DB	'+++INCORRECT','$'
;
TUMSG	DB	'You are in USER area $'	;First part of help msg.
;
CRLF	DB	CR,LF,'$'	;Printed to start a new line
;
;
	IF	NOT GOCCP
REQUSR	DB	00H	;Temporary storage area for user area number
	ENDIF
;
FLAG	DB	0	;Counter for multiple PW attempts
;
;  CONSOLE INPUT BUFFER, USED FOR PASSWORD INPUT
;
CONBUF	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		;Up to 16 characters for password
;
	IF	NOT PWFILE
;  PASSWORD TO ALLOW 'RESTRICTED USER AREA' ACCESS GOES HERE
PASSWD	DB	'PASSWORD','$'	;Must be followed by '$'
	ENDIF
;
	IF	PWFILE
LOCFCB	DB	0	;Drive is filled in here
	DB	'PWFILE     '	;Name of file that contains PW's
	DS	40H	;Some more room+ for PWFILE
;
LASTPW	DW	0000H	;Pointer to current PW in PWFILE
;
PWBUF	EQU	$	;Rest of TPA is available for PWFILE
	ENDIF
;
;
	END
