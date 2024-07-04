
;---------------------------------------------------------------------
;
;	TITLE:
;	EZ.ASM (EASY)	version 1.00 as of 08/16/83
;
;	AUTHOR:
;	Robert C. Kuhman
;	Sysop of the "Cro'sNest" RCP/M - RBBS.
;
;	COPYRIGHT STATUS:
;	Copyright (c)1983 by the author, all rights reserved.
;	Released to the PUBLIC DOMAIN for non-profit use only.
;
;	DESCRIPTION:
;	This program  uses the  CP/M  autoload  feature to rapidly
;	execute any "COM" program through the use of "abbreviated"
;	command  files  which cause autoloading of those programs,
;	plus execution of any pre-selected options. ("EZ" has been
;	designed to execute "COM's" that are used frequently,  and
;	which require lengthy strings of options and intructions.)
;
;
;	EXAMPLES:
;	1)	Assemble EZ.ASM, then rename it to "D.COM"  for use
;		instead of one of these  much  longer  commands,...
;
;	    a) A0>DIR *.* $U0AD	(SD-XX.COM Super Directory program)
;	    b) A0>DIR D:*.AQM $A (Search drive D for all AQM files)
;	    c) A0>DIR B:EZ.ASM $A            (Search for this file)
;
;	2)	How about using EWF.COM (ED Work File) instead  of:
;
;	    a) A0>ED B:WF.ASM          (Load work file for editing)
;	    b) A0>ED FILE.TXT                 (Edit any other file)
;
;	3)	Perhaps,... TYPGR.COM  to type  a  group  of files:
;
;	    a) A0>TYPE THIS.ASM THAT.HLP OTHER.TXT    (TYPE-17.COM)
;	    b) A0>TYPE THIS.AQM THAT.HQP OTHER.TQT (SQUEEZED FILES)
;
;	4)	Even  simplify use of MAC to assemble this  program
;		with: MACWF.COM                  (MAC Working File)
;
;           a) A0>MAC B:WF $PZSZ        (MAC assemble Working File)
;	    b) A0>ASM B:EZ.BBX          (ASM assemble this EZ file)
;
;	and...  LDWF.COM                        (Load Working File)
;
;	    a) A0>LOAD B:WF			     (Working File)	
;	    b) A0>LOAD B:EZ				       (EZ)
;
;	     etc.
;
;	USAGE:
;	EZ.COM (renamed to suit the requirement) will allow 
;	the  user  to  greatly  abbreviate his command line
;	inputs  by  setting  up  one or more "EZ" programs.
;	Once renamed (something like "D.COM" for instance),
;	EZ will then load any  lengthy command line so that
;	the CCP (or ZCPR)  can act upon it.  This result is
;	obtained  by  "fooling"  CP/M  into "thinking" that
;	the user typed in the entire command line. It's EZ!
;	e.g.	A0>D <return> ...Might load "DIR *.* $U0AD"
;	The called program must of course, also be present.
;	If EZ is to be used with standard CP/M, the EZ file
;	MUST  reside  on  AND  be executed from the default
;	disk drive.  The "default" drive is the drive named
;	in the CCP's prompt "A>".  Use ZCPR to execute "EZ"
;	from any drive.  The author recommends use of ZCPR.
;
;	Examples:	CP/M --->	A>EZ    [CR]
;			ZCPR --->	D0>B:EZ [CR]
;
;	Note: [CR] = "Carriage Return"
;
;	ADVANTAGES:
;	There  are probably more uses for this technique  than those
;	which have occured to me.  Let me point out some of the most
;	obvious features.
;
;	1) Commands  up  to maximum length of the CP/M command buffer
;	   can  be  executed  with a one character command.  This, in
;	   effect emulates the power of programmed "soft-keys"  found
;	   on the best, most expensive terminals.
;
;	2) Repeated entry into an editor to modify a textfile becomes
;	   a much less tedious task, as  does  assembly  and loading.
;
;	3) It is faster than a  SUBMIT file for such processing,  but
;	   note  that  the  "calling"  programs generated from EZ.ASM
;	   may be used  with SUBMIT.
;
;	4) Program  does  not create any extra files during execution
;	   like  the  $$$.SUB  temporary file (no disk space wasted).
;
;	5) Each EZ.COM "calling" program runs very fast and is small.
;	   It  executes invisibly in the sense that it loads  itself,
;	   and then the called program (plus all options) as if  ONLY
;	   the called program and options had been executed.
;
;	6) For those using a standard CP/M version, drive  specifiers
;	   can  be  included into each EZ "calling" program - thereby 
;	   avoiding the common errors "NO FILE",and "FILE NOT FOUND".
;
;	7) In instances where disk space is limited there may be some
;	   special advantage in placing only the 1-2K "calling" files
;	   onto a work disk. These then execute  some larger programs
;	   on another drive.  The remaining space is  thus  conserved
;	   for allocation to the subject file which  is  being  acted
;	   upon by the larger program.
;
;	BE FOREWARNED:
;	There are some  minor  problems to  be aware of before
;	attempting to  use  EZ.  Firstly,  there are some CP/M
;	implementations  which  cause  the  autoload  function
;	to disable itself once it has  been  used to load CP/M
;	and a full function BIOS from  a CPMXX.COM file. Next,
;	those same CP/M versions are likely to cause the drive
;	and user to be reset to "A>".  Repeating, if EZ is run
;	under an unmodified CP/M (standard CCP),  the  program
;	MUST reside on AND be executed from the  default  disk
;	drive.  Use of ZCPR will solve all of these  problems,
;	if they exist.
;
;	OTHER USES:
;	This program may also be used with MBASIC to autoload
;	both  MBASIC  and  a  saved  'BAS' file (assuming the
;	user  does  not  have  BASCOM  for compilation). This
;	technique can be especially useful for  RCP/M  Sysops
;	who may wish to load a LOGIN.BAS or RBBS.BAS program.
;
;	CREDITS:
;	Based in part, on an idea from Tim Gary, Los Altos, CA.
;
;	ASSEMBLY:
;	Assemble with ASM.COM or MAC.COM (One Z80 instruction
;	can be used, and it is included as a "DB" statement).
;
;---------------------------------------------------------------------
;
TRUE:	EQU	-1
FALSE:	EQU	NOT TRUE
;
;	USER DEFINED EQUATES
;
Z80CPU:	EQU	TRUE		;TRUE IF Z80 CPU CARD, ELSE FALSE
;
ZCPR:	EQU	TRUE		;TRUE IF USING ZCPR, ELSE FALSE
;
CPMBAS:	EQU	0000H		;CP/M BASE ADDRESS
;
;	END USER DEFINED EQUATES
;
	ORG	CPMBAS+100H	;CP/M EXECUTION ADDRESS
	JMP	START
;
;	THE COMMAND LINE TO EXECUTE IS THE NEXT "DB" DEFINITION.
;	IT MAY EQUAL CP/M'S COMMAND BUFFER IN LENGTH.
;
CMD:	EQU	$			;MARKER, DO NOT REMOVE
;
	DB	'A:MAC B:EZ $PZSZ'	;<--- COMMAND LINE
;
;	OTHER EXAMPLES,...
;
;	DB	'A:ASM B:EZ.BBX		;ASSEMBLE THIS FILE
;	DB	'A:LOAD B:EZ'		;LOAD THIS FILE.HEX
;	DB	'A:DIR *.* $U0AD'	;RCPM DIRECTORY PROGRAM
;	DB	'A:MBASIC LOGIN'	;RCPM LOGIN.BAS & MBASIC LOAD
;	DB	'A:MBASIC RBBS'		;RCPM RBBS.BAS & MBASIC LOAD
;
	DB	0			;DO NOT REMOVE
ENDCMD:	EQU	$			;MARKER, DO NOT REMOVE
;
;	ASSEMBLE COPYRIGHT INTO HEX FILE FOR LOAD
;
CYRGHT:	DB	'COPYRIGHT (C)1983 ROBERT KUHMAN'
;
;	MAIN PROGRAM
;
START:	LHLD	1		;GET WBOOT ADDR
	MOV	A,H		;GET HI ADDR
	SUI	16H		;SUBTRACT 1600H
	MOV	H,A		;HL HAS CCP ADDRESS+3
	SHLD	CCP3		;STORE CCP ADDRESS+3
;
	INX	H		;CCP + 4
	INX	H		;CCP + 5
	INX	H		;CCP + 6
	INX	H		;CCP + 7
;
	MVI	A,ENDCMD-CMD-1	;LENGTH OF COMMAND LINE
	MOV	M,A		;PUT IT AT CCP + 7
;
	INX	H		;CCP + 8
	XCHG			;DE HAS CCP + 8 DESTINATION
	LXI	H,CMD		;HL HAS COMMAND LINE ADDR
	LXI	B,ENDCMD-CMD	;BC HAS NUMBER BYTES TO MOVE
;
	 IF	Z80CPU		;Z80 CPU AVAILABLE
	DB	0EDH,0B0H	;Z80 LDIR INSTRUCTION HERE
	 ENDIF			;Z80
;
	 IF	NOT Z80CPU	;EMULATE LDIR INSTRUCTION FOR 8080 CPU
MOVE:	MOV	A,M		;MOVE BYTE
	STAX	D		;MOVE IT TO ADDRESS IN DE
	INX	H		;INCREMENT TO NEXT BYTE
	INX	D		;INCREMENT TO NEXT DESTINATION
	DCX	B		;SUBTRACT ONE OFF OF COUNT IN BC
	MOV	A,C		;CHECK IF DONE
	ORA	B		;OR B ONTO C IF RESULT ZERO, DONE
	JNZ	MOVE 		;GET ANOTHER BYTE TO MOVE
	 ENDIF			;END OF LDIR EMULATION
;
	 IF	ZCPR		;USING ZCPR?
	LDA	04H		;GET PRESENT USER/DRIVE
	 ENDIF			;ZCPR
;
	 IF	NOT ZCPR	;STD CP/M
	MVI	A,00H		;DRIVE A> USER 0
	 ENDIF			;STD CP/M
;
	MOV	C,A		;MOVE A INTO C
	LHLD	CCP3		;GET CCP ADDRESS + 3
	DCX	H		;DECREMENT DOWN TO CCP BASE
	DCX	H
	DCX	H		;HL HAS CCP BASE
	PCHL			;JUMP THERE
;
CCP3:	DS	2
;
;	END OF PROGRAM
;
