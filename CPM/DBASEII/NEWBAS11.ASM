*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*
*								    *
*			LEGAL STUFF UP FRONT			    *
*								    *
*	NEWBASE.ASM						    *
*								    *
*	1984, 1985 (c) Copyright by				    *
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
*	I also support the DBRUN, the dBASE II run-time		    *
*	package for a modest fee per installation.		    *
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
*
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
*	07/20/85 <-- Last update (Added equates for version 2.43*)
*		 NOTE:  There is a big difference between version
*		 2.43* (notice the *) and plain 2.43.
*
*	04/22/85 <-- Last update (Partial support of version 2.3B restored)
*		 Version 2.3B will NOT support full ZCPR operation.  You
*		 CAN specify a default drive where overlays will be found.
*				-Gene Head
*
*	03/20/85 <-- Last update (tried to fix all the ASM nesting problems)
*		 ASM.COM will not consistantly recognize nested conditionals!
*		 I tried to figure out all the logic to un-nest the nested
*		 conditionals.  Also added the ESCape key disable on all
*		 supported versions.  (VERSION 2.3B NO LONGER SUPPORTED)
*				-Gene Head
*
*	03/18/85 <-- Last update (added ESCape key disable option)
*		 Added ESCape disable option so that users may
*		 not abort a program file before it has time to
*		 SET ESCAPE OFF.  SET ESCAPE OFF should still be
*		 one of the first lines in your command file.
*				-Ryan Katri		 
*
*	03/17/85 <-- Last update (added Z-80 2.43 equates)
*		Fixed a problem that ASM was having when dealing
*		with a nested IF near ZCPRFIX that caused problems
*		only when ZCPR was set FALSE.
*		 		-Ryan Katri
*
*	02/20/85 <-- Last update (added 2.43 equates for Paul Foote)
*		 Skip-sign-on will no longer skip the copyright stuff.
*		 Ashton-Tate went to some lengths to make sure it stayed
*		 in place so I decided it must be pretty important to
*		 them.  However, the long list of threats and legal
*	         mumbo-jumbo can be skipped.
*				-Gene Head
*
*	10/25/84 <-- Last update (define the label delimiter character)
*		 Gary Knapp asked for this one to make labels more
*		 readable.  THIS_LABEL instead of the old THIS:LABEL
*				-Gene Head
*
*	09/21/84 <-- Last update (added PREDEFINED option)
*		 Force dBASE II to execute a pre-defined command file.
*				-Gene Head
*
*	08/10/84 <-- Last update (added equates for Z-80 version 2.41)
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
*	was not specified when DBASE.COM was executed.  Keeps
*       undesireables from the dot-prompt.
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
*	PEEK(337) will hold the last key pressed.
*
*   ESCAPE:
*         
*       Disables the ESCape (abort) function so that users may
*       not break out of a .CMD file.  The problem arises even
*       with SET ESCAPE OFF, because between the time that the
*       file is being loaded and ESCAPE is SET OFF, a user could
*       hit ESCape and dBASE would recognize it and respond
*       accordingly. The ESCAPE option is available for for all
*	supported versions.
*
*   ZCPR:
*
*       ZCPR compatibility allows execution from the A: drive if
*       the program can't be located on the default drive.
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
******* Note: For Vers. 2.43* the SAVE numbers are 84 or 85 ***********
*******************************************************************
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
*	INITIAL JUMP LIST
*	*****************
*
*	To help identify supported versions I have developed the 
*	following list of the jump instruction that must be found at
*	location 100H for each supported version.
*
*	Version		Jump instruction at location 100h
*	-------		---------------------------------
*
*	2.3B		JMP  4473
*	2.4		JMP  46C9
*	2.41		JMP  477A
*	2.41Z		JMP  467F
*	2.43		JMP  49B5	* <-- ABANDONED VERSION
*	2.43Z		JMP  5200	* <-- ABANDONED VERSION
*	2.43*		JMP  4C0F
*
*       If your version of DBASE.COM is not listed call me for help.
*
*
*  THE FOLLOWING ARE THE ONLY USER SELECTABLE OPTIONS IN THIS OVERLAY
*
*      Choose ONE AND ONLY ONE of the following versions to be
*	'TRUE'.  All others MUST be 'FALSE'.
*
VER23B	    EQU	  FALSE		;SET TO 'TRUE' IF RUNNING VERSION 2.3B
VER24	    EQU	  FALSE		;SET TO 'TRUE' IF RUNNING VERSION 2.4
VER241      EQU   FALSE		;SET TO 'TRUE' IF RUNNING VERSION 2.41
VER241Z	    EQU   FALSE		;SET TO 'TRUE' IF RUNNING Z-80 2.41
VER243	    EQU	  TRUE 		;SET TO 'TRUE' IF RUNNING VERSION 2.43*
*
*   SET THE FOLLOWING EQUATES TO TRUE OR FALSE FOR YOUR ENVIRONMENT
*
SKIPDATE    EQU	  TRUE 		;SET TO 'TRUE' TO SKIP DATE SET AT SIGN-ON
SKIPSIGNON  EQU	  TRUE  	;SET TO 'TRUE' TO SKIP SIGN-ON MESSAGE
SKIPOPT     EQU   TRUE		;SET TO 'TRUE' TO SKIP OPTIONS AT SIGN-ON
FORCE  	    EQU	  FALSE		;SET TO 'TRUE' TO FORCE A COMMAND FILE
KEYIN	    EQU	  TRUE		;SET TO 'TRUE' TO ALLOW KEY-IN FEATURE
ZCPR	    EQU	  FALSE   	;SET TO 'TRUE' IF RUNNING ZCPR OR LOOK-ALIKE
PREDEFINED  EQU   FALSE 	;SET TO 'TRUE' FOR PRE-DEFINED COMMAND FILE
ESCAPEOFF   EQU   FALSE 	;SET TO 'TRUE' TO DISABLE THE ESCape FUNCTION
DEFAULT     EQU	  'A'-40H 	;DEFAULT DRIVE IF RUNNING ZCPR
CDELIMIT    EQU	  ':'		; PUT YOUR FAVORITE DELIMIT CHARACTER HERE
*				; ie. STORE 9 TO THIS:ONE can be changed
*				;  to STORE 9 TO THIS_ONE by setting this
*				;  equate to '_'
*
* --->	* * *  NOTE:  If you set PREDEFINED to TRUE then you MUST
* --->	* * *	      put your command line at label COMMAND near the
* --->	* * *	      end of this overlay.  Currently 'MENU.CMD'
* 	
*   END OF USER SELECTED EQUATES.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

KEYPATCH	EQU	14AH	;PUT INKEY PATCH HERE FOR ALL VERSIONS
				;TO MAINTAIN TRANSPORTABILITY.  PEEK(337)
				;ON ANY NEWBASE INSTALLATION WILL NOW
				;RETURN THE LAST KEY PRESSED.
	IF	VER23B
*	DBASE II VERSION 2.3B  SIGN-ON DATE 22 FEB 1982
BEGIN	EQU	4473H		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	461AH		;SKIP DATE HOOK
SKIP2	EQU	46AFH		;SKIP DATE DESTINATION
DATEFIX	EQU	00FEH		;DATE FIX FOR RE-ENTRY
CONSIO	EQU	39F0H		;KEYIN HOOK
SAVE1	EQU	39DFH		;DIRECT BIOS HOOK
MESSAGE	EQU	46BBH		;FIRST BYTE OF SIGN-ON MESSAGE
MESS1	EQU	46E1H		;NEWBASE MESSAGE HOOK
FCB1	EQU	42F3H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4314H		;FCB2 FOR DBASEOVR.COM
BUFFERS	EQU	46C0H		;START OF BUFFERS
HELLO	EQU	47D0H		;HELLO MESSAGE
DELIMIT	EQU	2AE4H		;LOCATION OF DELIMIT CHARACTER
DISABLE	EQU	39AEH		;ZERO OUT FOR ESCAPE DISABLE (CPI 1BH)
NEWREC	EQU	4B00H		;ADDED RECORD FOR PREDEFINED OPTION
				;SHOULD BE THE SAME AS NEXT LOAD
				;WHEN DDT LOADS DBASE.COM
	ENDIF	;VER23B

	IF	VER24
*	DBASE II VERSION 2.4  SIGN-ON DATE APRIL 1, 1983

BEGIN	EQU	46C9H		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	4876H		;SKIP DATE HOOK
SKIP2	EQU	4892H		;SKIP DATE DESTINATION
DATEFIX	EQU	00FEH		;DATE FIX FOR RE-ENTRY
CONSIO	EQU	3A8AH		;KEYIN HOOK
SAVE1	EQU	4378H		;dBASE II CUBBY-HOLE
MESSAGE	EQU	495AH		;FIRST BYTE OF SIGN-ON MESSAGE
MESS1	EQU	46B5H		;NEWBASE MESSAGE HOOK
FCB1	EQU	4331H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4352H		;FCB2 FOR DBASEOVR.COM
XZCPR	EQU	3BA6H		;ZCPR HOOK
ZCPRRET	EQU	3BA9H		;JUMP-BACK LOCATION
BUFFERS	EQU	497EH		;START OF BUFFERS
HELLO	EQU	4AE1H		;HELLO MESSAGE
FREE	EQU	44C9H		;UN-USED PROGRAM SPACE
ENDCODE	EQU	44FFH		;END OF SAFE AREA
DELIMIT	EQU	2B3BH		;LABEL DELIMITER POSITION
DISABLE	EQU	3A47H		;ZERO OUT FOR ESCAPE DISABLE (CPI 1BH)
NEWREC	EQU	4D00H		;ADDED RECORD FOR PREDEFINED OPTION
				;SHOULD BE THE SAME AS NEXT LOAD
				;WHEN DDT LOADS DBASE.COM
	ENDIF	;VER24


	IF	VER241
*	DBASE II VERSION 2.41 SIGN-ON DATE FEBRUARY 1, 1984

BEGIN	EQU	477AH		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	4927H		;SKIP DATE HOOK
SKIP2	EQU	4943H		;SKIP DATE DESTINATION
DATEFIX	EQU	00FEH		;DATE FIX FOR RE-ENTRY
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
DISABLE	EQU	3AE2H		;ZERO OUT FOR ESCAPE DISABLE (CPI 1BH)
NEWREC	EQU	4D00H		;ADDED RECORD FOR PREDEFINED OPTION
				;SHOULD BE THE SAME AS NEXT LOAD
				;WHEN DDT LOADS DBASE.COM

	ENDIF	;VER241

	IF	VER241Z
*	Z-80 DBASE II VERSION 2.41  SIGN-ON DATE APRIL 1, 1983

BEGIN	EQU	467FH		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	482CH		;SKIP DATE HOOK
SKIP2	EQU	4904H		;SKIP DATE DESTINATION
DATEFIX	EQU	00FEH		;DATE FIX FOR RE-ENTRY
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
DISABLE	EQU	3A48H		;ZERO OUT FOR ESCAPE DISABLE (CPI 1BH)
NEWREC	EQU	4D00H		;ADDED RECORD FOR PREDEFINED OPTION
				;SHOULD BE THE SAME AS NEXT LOAD
				;WHEN DDT LOADS DBASE.COM

	ENDIF	;VER241Z

	IF	VER243
*	DBASE II VERSION 2.43* SIGN-ON DATE APRIL 30, 1985

BEGIN	EQU	4C0FH		;JUMP AROUND INSTALLED PARAMETERS
SKIP1	EQU	4DD6H		;SKIP DATE HOOK
SKIP2	EQU	4DF2H		;SKIP DATE DESTINATION
DATEFIX	EQU	4941H		;DATE FIX FOR RE-ENTRY
CONSIO	EQU	3F24H		;KEYIN HOOK
SAVE1	EQU	4867H		;dBASE II CUBBY-HOLE
MESSAGE	EQU	4EC8H		;FIRST BYTE OF SIGN-ON MESSAGE 1
MESS1	EQU	4F1BH		;NEWBASE MESSAGE HOOK
MESS2	EQU	5049H		;FIRST BYTE OF SIGN-ON MESSAGE 2
FCB1	EQU	4820H		;FCB1 FOR DBASEOVE.COM
FCB2	EQU	4841H		;FCB2 FOR DBASEOVR.COM
XZCPR	EQU	404DH		;ZCPR HOOK
ZCPRRET	EQU	4050H		;JUMP-BACK LOCATION
BUFFERS	EQU	4ECDH		;START OF BUFFERS
HELLO	EQU	5339H		;HELLO MESSAGE
FREE	EQU	4A0FH		;UN-USED PROGRAM SPACE
ENDCODE	EQU	4A7FH		;END OF SAFE AREA
DEFDRV	EQU	0165H		;DEFAULT DRIVE STORAGE
DELIMIT	EQU	2E36H		;LABEL DELIMITER POSITION
DISABLE	EQU	3ED9H		;ZERO OUT FOR ESCAPE DISABLE (CPI 1BH)
NEWREC	EQU	5480H		;ADDED RECORD FOR PREDEFINED OPTION
				;SHOULD BE THE SAME AS NEXT LOAD
				;WHEN DDT LOADS DBASE.COM

	ENDIF	;VER243*
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
	IF	CDELIMIT
	ORG	DELIMIT
	DB	CDELIMIT
	ENDIF

	IF	ESCAPEOFF
	ORG	DISABLE
	DB	0		;ZERO OUT BYTE 1 (FE=CPI INSTRUCTION)
	DB	0		;ZERO OUT BYTE 2 (1B=ASCII CODE FOR ESC)
	ENDIF	;ESCAPEOFF

*
*   Patch here if either SKIPDATE or COMMAND options are true.
*      Note COMMAND option has highest priority

	IF	SKIPDATE
	ORG	SKIP1
	LXI	H,0
	SHLD	DATEFIX
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

	IF VER243 AND SKIPSIGNON
	ORG	MESS2		;MORE TO SKIP THE SIGN-ON
	DB	0	
	ENDIF	;  AND SKIP SIGNON

*
*  patch for new KEYIN psudo-function
	IF	KEYIN
	ORG	CONSIO
	JMP	XKEYIN
	ENDIF	;KEYIN

	IF	KEYIN AND (VER241Z OR  VER23B)
	ORG	SAVE1		;Fix direct BIOS hook
	SHLD	XKEYIN+1
	ENDIF	;KEYIN AND (VER241Z OR  VER23B)

*
*    FIX THE BUFFERS
	ORG	BUFFERS

	IF	VER24 OR VER241 OR VER243 OR VER23B
	SBB	H	;BUMP BUFFER 1 POINTER
	ADC	D	;ADD OFFSET
	XRA	M	;ADJUST BY BUFFER 1 VALUE
	ENDIF	;VER24 OR VER241 OR VER243 OR VER23B

	IF	VER241Z
	ORA	H	;FIX BUFFER OFFSET IN Z-80 VERSION
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
	ENDIF	;NOT SKIPOPT

	IF	ZCPR AND NOT SKIPOPT
	DB	'ZCPR Compatible'
	ENDIF	;ZCPR AND NOT SKIPOPT

	IF	ZCPR AND KEYIN AND NOT SKIPOPT
	DB	' + '
	ENDIF	;ZCPR AND KEYIN AND NOT SKIPOPT

	IF	KEYIN AND NOT SKIPOPT
	DB	'KEYIN at --> 337'
	ENDIF	;KEYIN AND NOT SKIPOPT


	IF 	(KEYIN OR ZCPR) AND NOT SKIPOPT
	DB	0DH,0AH,0
	ENDIF	;(KEYIN OR ZCPR) AND NOT SKIPOPT

*  new, added code begins here and must end before 44FFH
*
	IF 	KEYIN
XKEYIN:	ORG	KEYPATCH
	ENDIF 	;KEYIN

 	IF	(VER24 OR VER241 OR VER243) AND KEYIN
 	STA	SAVE1		;SAVE FOR dBASE.COM
 	ENDIF	;(VER24 OR VER241 OR VER243) AND KEYIN

	IF	(VER241Z OR VER23B) AND KEYIN 
	CALL	0		;PATCHED BY Z-80 DBASE II
	ENDIF	;(VER241Z OR VER23B) AND KEYIN


	IF 	KEYIN
	STA	SAVE2		;SAVE FOR KEYIN
	RET
SAVE2	DS	1  		;KEYIN CUBBY-HOLE (decimal value)
	ENDIF	;KEYIN
*
	IF	ZCPR AND (NOT VER23B)
	ORG	XZCPR
	JMP	ZCPRFIX

	ORG	FREE
ZCPRFIX	CPI	FAILED
	JNZ	ZCPRRET		;FILE OPEN OK SO RETURN
	LXI	D,FCB1	
	MVI	A,DEFAULT	;SET UP FOR DEFAULT DRIVE
	STAX	D
	STA	FCB2
	ENDIF	;ZCPR AND (NOT VER23B)

	IF	(VER241 OR VER241Z OR VER243 ) AND ZCPR
	STA	DEFDRV		;DEFAULT DRIVE STORAGE
	ENDIF	;(VER241 OR VER241Z OR VER243 ) AND ZCPR

	IF	ZCPR AND (NOT VER23B)	
	MVI	C,OPEN
	CALL	BDOS		;TRY TO OPEN DBASEOVR.COM
	CPI	FAILED		; . .ON DEFAULT DRIVE
	JNZ	ZCPRRET		;GO BACK IF FOUND
	RET			;RETURN WITH ZERO SET IF
	ENDIF	;ZCPR

	IF	ZCPR AND VER23B
	ORG	FCB1
	DB	DEFAULT
	ORG	FCB2
	DB	DEFAULT
	ENDIF

BODYEND	EQU	$
*

	IF	PREDEFINED
	ORG	NEWREC
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
