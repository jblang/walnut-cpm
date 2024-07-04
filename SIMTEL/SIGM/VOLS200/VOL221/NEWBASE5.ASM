*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*
*								    *
*			LEGAL STUFF UP FRONT			    *
*								    *
*	NEWBASE.ASM						    *
*								    *
*	1984 (c) Copyright by					    *
*	Gene Head						    *
*	2860 NW Skyline Drive					    *
*	Corvallis, Oregon  97330    (503)  758-0279		    *
*								    *
*	All rights reserved.					    *
*								    *
*	Released for non-commercial, private use only.		    *
*	Released for no-profit use only.  If you make any money	    *
*	using this overlay or use it in your business I expect	    *
*	fair compensation to be mailed to the address above.	    *
*								    *
*								    *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*

*
*
   * * * * * * * * * *    E D I T O R I A L    * * * * * * * * * * * *
   *	This overlay is intended for the use of licensed users of    *
   *	dBASE II only.   If you 'own' a copy of dBASE II that you    *
   *	did not purchase or receive legitimately you are a thief,    *
   *	it is that simple.   Stealing software will only drive up    *
   *	prices for legal users  and dry up the sources of quality    *
   *	software products.					     *
   * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*
***********************************************************************
*
*		PROGRAM DOCUMENTATION STUFF STARTS HERE
*
*       PROGRAM NAME -->  NEWBASEx.ASM
   
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*	
*	10/25/84 <-- Last update (define the label delimiter character)
*		 Gary Knapp asked for this one to make labels more
*		 readable.  THIS_LABEL instead of the old THIS:LABEL
*				-Gene Head
*
*	09/21/84 <-- Last update (Added PREDEFINED option)
*		 Force dBASE II to execute a pre-defined command file.
*				-Gene Head
*
*	08/10/84 <-- Last update (Added equates for Z-80 dBASE II)
*		 Re-ordered these updates to reflect most recent first.
*				-Ryan Katri
*
*	07/25/84 <-- Last update  (added version 2.41 equates)
*		Removed ELSE conditionals so this can be assembled
*		with ASM and added version 2.41 equates.
*		(Also added assembly error messages)
*				-Gene Head				
*
*	07/23/84 <-- Last update  (force command file execution)
*		Some folks want to keep un-trained users from the
*		dot-prompt.  This patch will do a warm boot if a
*		valid command file was not specified when DBASE.COM
*		was executed.
*				-Gene Head
*
*	07/18/84 <-- Last update  (skip date option installed)
*		Some folks have time and date functions available
*		and do a date and time set as part of an initiali-
*		zation command so want to skip the ENTER DATE stuff.
*				-Gene Head
*
*	06/20/84 <-- Last update
*		Some folks want to skip the sign-on messages.
*				-Gene Head
*
*	05/25/84 <-- Last update
*		Some folks run ZCPR or a ZCPR look-alike and would
*		like dBASE II to run from drive A: regardless of the
*		default drive it was executed from.
*				-Gene Head
*
*	05/01/84 <-- Last update
*		Moved the KEYIN cubby hole from low memory in
*		the screen defination area to high memory
*		so that INSTALL.COM does not disturb it.
*				-Gene Head
*
*	04/01/84 <-- Last update
*		Some folks need a way to exit a long or forever
*		DO WHILE loop from a keyboard command.  (Like the
*		INKEY$ function found in most BASIC's)
*				-Gene Head
*
*	If you happen to transport any of these features to the
*	MS-DOS version of dBASE II please let me know how you did it.
*
*       I'm also interested in supporting 2.3 and earlier versions.
*	If you have an earlier version and want this modification
*	installed please contact me at the above address or phone.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   SKIPDATE:
*
*	SKIPDATE will skip the ENTER DATE question at sign-on.
*
*   SKIPSIGNON:
*
*	SKIPSIGNON will skip all the sign-on stuff and go directly
*	to the dot-prompt.  (To skip the sign-off message simply
*			     SET CONSOLE OFF just prior to the
*			     QUIT or QUIT TO command.
*
*   SKIPOPT:
*
*	SKIPOPT option allows a list of selected options to be
*	displayed at sign-on.
*
*   FORCE:
*
*	FORCE option forces a warm boot if a valid command file
*	was not specified when DBASE.COM was executed.
*
*   PREDEFINED:
*
*	PREDEFINED option forces dBASE II to execute a pre-defined
*	command file.  This simulates an auto-start mode without
*	a submit file AND prevents command level operation.
*
*   KEYIN:
*
*	The KEYIN option will allow you to PEEK at the last key
*	press at the keyboard.  Useful for aborting DO WHILE loops.
*
*	PEEK(ddddd) will hold the last key pressed.
*
*
*   ZCPR:
*
*       ZCPR compatibility allows execution from the A: drive if
*       the program can't be located on the default drive.
*
*
*	NOTE:  This fixes only the access to the DBASEOVR.COM
*	       file and NOT the DBASEMSG.TXT file.  If you use
*	       the on-line HELP command the DBASEMSG.TXT file
*	       must be on the default drive.
*
*
*     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*     *	BE SURE YOU HAVE A BACK-UP COPY OF DBASE.COM BEFORE YOU *
*     *	           ATTEMPT TO USE THIS OVERLAY			*
*     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*  	 Simply SET the proper equates, assemble this file then
*   	 integrate it using the following DDT commands:
*
*	A>DDT DBASE.COM
*	DDT VERS 2.2
*	NEXT  PC
*	4D00 0100
*	-INEWBASE.HEX
*	-R
*	NEXT  PC
*	4D00 0000
*	-G0
*	A>SAVE 76 DBASE.COM   OR  SAVE 77 DBASE.COM if you install
*				  a forced, predefined command file
*
*
*     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*     *	BE SURE YOU HAVE A BACK-UP COPY OF DBASE.COM BEFORE YOU *
*     *	           ATTEMPT TO USE THIS OVERLAY			*
*     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
*		PROGRAM STUFF STARTS HERE
*
TRUE	EQU	0FFH		;'YES'
FALSE	EQU	NOT TRUE	;'NO'
*
*
*  THE FOLLOWING ARE THE ONLY USER SELECTABLE OPTIONS IN THIS OVERLAY
*
*      Choose ONE AND ONLY ONE of the following versions to be
*	'TRUE'.  All others MUST be 'FALSE'.
*   
VER24	    EQU	  FALSE		;SET TO 'TRUE' IF RUNNING VERSION 2.4
VER241      EQU   TRUE		;SET TO 'TRUE' IF RUNNING VERSION 2.41
VER241Z	    EQU   FALSE		;SET TO 'TRUE' IF RUNNING Z-80 2.41
*
*   SET THE FOLLOWING EQUATES TO TRUE OR FALSE FOR YOUR ENVIRONMENT
*
SKIPDATE    EQU	  FALSE		;SET TO 'TRUE' TO SKIP DATE SET AT SIGN-ON
SKIPSIGNON  EQU	  FALSE      	;SET TO 'TRUE' TO SKIP SIGN-ON MESSAGE
SKIPOPT     EQU   FALSE		;SET TO 'TRUE' TO SKIP OPTIONS AT SIGN-ON
FORCE  	    EQU	  FALSE		;SET TO 'TRUE' TO FORCE A COMMAND FILE
KEYIN	    EQU	  TRUE		;SET TO 'TRUE' TO ALLOW KEY-IN FEATURE
ZCPR	    EQU	  TRUE		;SET TO 'TRUE' IF RUNNING ZCPR OR LOOK-ALIKE
PREDEFINED  EQU   FALSE		;SET TO 'TRUE' FOR PRE-DEFINED COMMAND FILE
DEFAULT     EQU	  'A'-40H	;DEFAULT DRIVE IF RUNNING ZCPR
CDELIMIT    EQU	  '_'		;PUT A ZERO HERE TO KEEP LABEL DELIMITER
*				; AS ':' OTHERWISE PUT IN YOUR CHARACTER
*				; ie. STORE 1 TO THIS:ONE can be changed
*				;  to STORE 1 TO THIS_ONE by setting this
*				;  equate to '_' 
*
* --->	* * *  NOTE:  If you set PREDEFINED to TRUE then you MUST
* --->	* * *	      put your command line at label COMMAND near the
* --->	* * *	      end of this overlay.  Currently 'MENU.CMD'
* 	
*   END OF USER SELECTED EQUATES.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


	IF	VER24
*	DBASE II VERSION 2.4  SIGN-ON DATE APRIL 1, 1983

BEGIN	EQU	46C9H		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	4876H		;SKIP DATE HOOK
SKIP2	EQU	4892H		;SKIP DATE DESTINATION
CONSIO	EQU	3A8AH		;KEYIN HOOK
SAVE1	EQU	4378H		;dBASE II CUBBY-HOLE
MESSAGE	EQU	495AH		;FIRST BYTE OF SIGN-ON MESSAGE
MESS1	EQU	499FH		;NEWBASE MESSAGE HOOK
FCB1	EQU	4331H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4352H		;FCB2 FOR DBASEOVR.COM
XZCPR	EQU	3BA6H		;ZCPR HOOK
ZCPRRET	EQU	3BA9H		;JUMP-BACK LOCATION
BUFFERS	EQU	497EH		;START OF BUFFERS
HELLO	EQU	4AE1H		;HELLO MESSAGE
FREE	EQU	44C9H		;UN-USED PROGRAM SPACE
ENDCODE	EQU	44FFH		;END OF SAFE AREA
DELIMIT	EQU	2B3BH		;LABEL DELIMITER POSITION
	ENDIF	;VER24


	IF	VER241
*	DBASE II VERSION 2.41 SIGN-ON DATE FEBRUARY 1, 1984

BEGIN	EQU	477AH		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	4927H		;SKIP DATE HOOK
SKIP2	EQU	4943H		;SKIP DATE DESTINATION
CONSIO	EQU	3B25H		;KEYIN HOOK
SAVE1	EQU	4429H		;dBASE II CUBBY-HOLE
MESSAGE	EQU	4A0BH		;FIRST BYTE OF SIGN-ON MESSAGE
MESS1	EQU	4A58H		;NEWBASE MESSAGE HOOK
FCB1	EQU	43E2H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4403H		;FCB2 FOR DBASEOVR.COM
XZCPR	EQU	3C49H		;ZCPR HOOK
ZCPRRET	EQU	3C4CH		;JUMP-BACK LOCATION
BUFFERS	EQU	4A37H		;START OF BUFFERS
HELLO	EQU	4B77H		;HELLO MESSAGE
FREE	EQU	457AH		;UN-USED PROGRAM SPACE
ENDCODE	EQU	46FFH		;END OF SAFE AREA
DEFDRV	EQU	0165H		;DEFAULT DRIVE STORAGE
DELIMIT	EQU	2B99H		;LABEL DELIMITER POSITION

	ENDIF	;VER241

	IF	VER241Z
*	Z-80 DBASE II VERSION 2.41  SIGN-ON DATE APRIL 1, 1983

BEGIN	EQU	467FH		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	482CH		;SKIP DATE HOOK
SKIP2	EQU	4904H		;SKIP DATE DESTINATION
CONSIO	EQU	3A75H		;KEYIN HOOK
SAVE1	EQU	3A64H		;DIRECT BIOS HOOK
MESSAGE	EQU	4910H		;FIRST BYTE OF SIGN-ON MESSAGE
MESS1	EQU	495DH		;NEWBASE MESSAGE HOOK
FCB1	EQU	42E7H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4308H		;FCB2 FOR DBASEOVR.COM
XZCPR	EQU	3B90H		;ZCPR HOOK
ZCPRRET	EQU	3B93H		;JUMP-BACK LOCATION
BUFFERS	EQU	493CH		;START OF BUFFERS
HELLO	EQU	4A7CH		;HELLO MESSAGE
FREE	EQU	4480H		;UN-USED PROGRAM SPACE
ENDCODE	EQU	44FFH		;END OF SAFE AREA
DEFDRV	EQU	0165H		;DEFAULT DRIVE STORAGE
DELIMIT	EQU	2B25H		;LABEL DELIMITER POSITION
	ENDIF	;VER241Z


*
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*
WBOOT	EQU	0		;WARM BOOT 
BDOS	EQU	5		;BDOS ENTRY
OPEN	EQU	0FH		;OPEN FILE FUNCTION
FAILED	EQU	0FFH		;DISK I-O FAILED
*
*
*   Patch here if either SKIPDATE or COMMAND options are true.
*      Note COMMAND option has highest priority

	IF	CDELIMIT
	ORG	DELIMIT
	DB	CDELIMIT
	ENDIF

	IF	SKIPDATE
	ORG	SKIP1
	JMP	SKIP2		;. . .  BYPASS DATE STUFF AT SIGN-ON
	ENDIF	;SKIPDATE
*					OR
	IF	FORCE
	ORG	SKIP1
	JMP	WBOOT		;. . .  FORCE A COMMAND FILE
	ENDIF	;FORCE
*
	IF	PREDEFINED
	ORG	100H
	JMP	CLINE
	ENDIF	;PREDEFINED
*
	IF	SKIPSIGNON
	ORG	MESSAGE
	DB	0		;CANCEL SIGN ON MESSAGE
	ORG	MESS1
	LXI	H,HELLO		;NEWBASE OPTIONS MESSAGE
	ENDIF	;SKIPSIGNON
*
*  patch for new KEYIN psudo-function
	IF	KEYIN
	ORG	CONSIO
	JMP	XKEYIN

	IF	VER241Z
	ORG	SAVE1		;Fix direct BIOS hook
	SHLD	XKEYIN+1
	ENDIF	;VER241Z

	ENDIF	;KEYIN
*
*  patch for ZCPR compatibility
	IF	ZCPR
*
	ORG	XZCPR
	JMP	ZCPRFIX
	ENDIF	;ZCPR
*
*    FIX THE BUFFERS
	ORG	BUFFERS

	IF	NOT VER241Z
	SBB	H	;BUMP BUFFER 1 POINTER
	ADC	D	;ADD OFFSET
	XRA	M	;ADJUST BY BUFFER 1 VALUE
	ENDIF	;NOT VER241Z

	IF	VER241Z
	ORA	H	;FIX BUFFER OFFSET IN Z-90 VERSION
	MOV	E,M
	ENDIF	;VER241Z

	ADD	H	;  ...  BUMP AGAIN
	ADD	D	;  ...  AND AGAIN
	ANA	M	;NOW DO BUFFER 2
	ADC	D	
	DB	40H,40H
*
	IF	SKIPOPT
	ORG	HELLO
	DB	0
	ENDIF	;SKIPOPT

	IF	NOT SKIPOPT
	ORG	HELLO
	DB	0DH,0AH,0AH
	IF	ZCPR
	DB	'ZCPR Compatible'
	IF	ZCPR AND KEYIN
	DB	' + '
	ENDIF	;ZCPR AND KEYIN
	ENDIF	;ZCPR
	IF	KEYIN
	DB	'KEYIN at --> '

	IF	VER24
	DB	'17616'		;KEYIN LOCATION FOR 2.4
	ENDIF  	;VER24

	IF	VER241
	DB	'17793'		;KEYIN LOCATION FOR 2.41
	ENDIF	;VER241

	IF	VER241Z
	DB	'17543'		;KEYIN LOCATION FOR 2.41 Z-80
	ENDIF	;VER241Z

	ENDIF	;KEYIN
	DB	0DH,0AH

	ENDIF	;NOT SKIPOPT

*  new, added code begins here and must end before 44FFH
	ORG	FREE
*
	IF 	KEYIN
XKEYIN:	
	IF	NOT VER241Z
	STA	SAVE1		;SAVE FOR dBASE.COM
	ENDIF	;NOT VER241Z

	IF	VER241Z
	CALL	0		;PATCHED BY Z-80 DBASE II
	ENDIF	;VER241Z

	STA	SAVE2		;SAVE FOR KEYIN
	RET
SAVE2	DS	1  		;KEYIN CUBBY-HOLE (decimal value)
	ENDIF	;KEYIN
*
	IF	ZCPR
ZCPRFIX	CPI	FAILED
	JNZ	ZCPRRET		;FILE OPEN OK SO RETURN
	LXI	D,FCB1	
	MVI	A,DEFAULT	;SET UP FOR DEFAULT DRIVE
	STAX	D
	STA	FCB2

	IF	VER241 OR VER241Z
	STA	DEFDRV		;DEFAULT DRIVE STORAGE
	ENDIF	;VER241 OR VER241Z

	MVI	C,OPEN
	CALL	BDOS		;TRY TO OPEN DBASEOVR.COM
	CPI	FAILED		; . .ON DEFAULT DRIVE
	JNZ	ZCPRRET		;GO BACK IF FOUND
	RET			;RETURN WITH ZERO SET IF
	ENDIF	;ZCPR
BODYEND	EQU	$
*

	IF	PREDEFINED
	ORG	4D00H
CLINE	LXI	H,COMMAND	;POINT TO PRE-DEFINED COMMAND LINE
	LXI	D,80H		;DEFAULT COMMAND LINE BUFFER
	MOV	B,M		;LENGTH OF COMMAND LINE
CLINE1	MOV	A,M		
	STAX	D		;MOVE IT TO BUFFER AS THO IT
	INX	H		;...IT HAD BEEN ENTERED FROM
	INX	D		;......THE KEYBOARD
	DCR	B
	JM	CLINE2
	JMP	CLINE1

CLINE2	LXI	H,5CH
	LXI	D,XFCB
	MVI	B,12
CLINE3	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	B
	JNZ	CLINE3
	JMP	BEGIN

*
*   Try to keep the command line short as there isn't much room left
*   if all the options are installed.
*
COMMAND	DB	CMDEND-COMMAND
	DB	'MENU.CMD'	;<-- PUT COMMAND LINE HERE IN SINGLE
				;    . . .  JUST AS YOU WOULD TYPE IT.
CMDEND	EQU	$

XFCB:	DB	'@'-40H		;<-- DRIVE   '@' FOR DEFAULT DRIVE
	DB	'MENU    CMD'   ;<-- MUST BE 11 CHARACTERS EXACTLY
				;<-- LIKE  'MYFILE  CMD'  NO PERIOD
				;<-- JUST FILENAME OF EXACTLY EIGHT
				;<-- CHARACTERS FOLLOWED BY THREE FILE
				;<-- TYPE CHARACTERS.
	ENDIF	;PREDEFINED
