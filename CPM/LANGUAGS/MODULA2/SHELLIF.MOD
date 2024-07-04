;
; MODIFICATION TO ZCPR3 CP TO ALLOW IF/ELSE STATEMENTS INSIDE A SHELL CMD
;
;	If you are a heavy user of aliases and arunz alias.cmd
;	files which contain flow control statements, and you
;	also use the SHSET FNAME1;FNAME2;CMD sequence to create
;	shells from non-shell programs; you have probably had
;	problems if FNAME2 or FNAME2 were aliases which contained
;	flow control statements.
;
;	The source of the difficulty is in the following section
;	of ZCPR3 CP code. The code was originally included so that
;	a false flow control state would not prevent re-entry to
;	a shell. However, if you are willing to allow that to occur;
;	the modification shown below will greatly increase the
;	flexibility of the ZCPR3 system by allowing flow control
;	statements to be included inside a shell command.  I have
;	been using this modification for several months (along with
;	CMD11.COM) and have had no problems introduced by doing so.
;
;	Just insert the conditional assembly statements as shown, into
;	the ZCPR3 CP source code, assemble, & link.  The code below
;	is from ZCPR3 ver 3.0, but it shouldn't be to difficult to
;	find the proper place to modify if you are using the latest
;	release.
;				Royce Shofner....4/15/87



RS3:
	LD	(NXTCHR),HL	;SET PTR TO FIRST CHAR OF NEW COMMAND LINE
	LD	(CURCMD),HL	;SAVE PTR TO COMMAND LINE FOR ERROR RETURN
;
; PARSE COMMAND LINE PTED TO BY HL
;
	CALL	PARSER		;PARSE ENTIRE COMMAND LINE
;***************************************************************
;
; CHECK FOR SHELL INVOCATION AND RUN IT IF SO
;
;	THIS IS THE CODE WHICH PREVENTS FLOW CONTROL PROCESSING
;	FROM WITHIN A (FNAME1;FNAME2;CMD) SEQUENCE WHERE FNAME1,
;	FNAME2 ARE ALIASES CONTAINING FLOW CONTROL STATEMENTS
;	IF SHELLIF IS DECLARED TRUE, THIS SECTION OF CODE IS NOT
;	INCLUDED IN THE ZCPR3 COMMAND PROCESSOR, & FLOW CONTROL
;	STATEMENTS MAY BE INCLUDED INSIDE A SHELL COMMAND
;
;	THE SHELLIF EQUATE MAY BE LOCATED INSIDE THE ZCPR3 CP
;	AS IS SHOWN HERE, OR IT MAY BE PLACED INSIDE Z3HDR.LIB
;	SOMEWHERE IN THE FLOW CONTROL DEFINITION AREA

SHELLIF	EQU	TRUE		;ALLOWS IF PROCESSING FROM SHELL

	IF	Z3MSG NE 0
	IF	NOT SHELLIF
	LD	A,(Z3MSG+3)		;GET COMMAND STATUS
	CP	1			;SHELL?
	JP	Z,RS4
	ENDIF		;SHELLIF
	ENDIF		;Z3MSG NE 0
;***************************************************************
;
; IF IFON AND FCP AVAILABLE, TRY TO RUN FROM FCP
;
	IF	IFON AND [FCP NE 0]
	LD	HL,FCP+5		;PT TO COMMAND TABLE
	CALL	CMDSCAN		;SCAN TABLE
	JP	Z,CALLP		;RUN IF FOUND (NO LEADING CRLF)
	ENDIF		;IFON AND (FCP NE 0)
;
; IF IFON, THEN CHECK FOR RUNNING IF AND FLUSH COMMAND LINE IF ENABLED
;
	IF	IFON
	LD	HL,Z3MSG+1	;PT TO IF BYTE
	LD	A,(HL)		;GET IT
	OR	A		;SEE IF ANY IF
	JR	Z,RS4		;CONTINUE IF NOT
	INC	HL		;PT TO IF ACTIVE BYTE
	AND	(HL)		;SEE IF CURRENT IF IS ACTIVE
	JR	Z,RS1		;SKIP IF NOT
	ENDIF		;IFON
RS4:
