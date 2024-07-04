;
;   ZCMD   - Z80 CCP command processor program replacement
;   v2.8
; 07/22/86 - Tom Brady  Decibel RCP/M (PBBS)  (404) 288-6858
;
; The EQUates are currently set for use by an RCP/M -- you will want
;  verify the settings of those equates tagged with an asterisk (*)
;  beside the comment field for your particular system needs.
;
; NOTE:	 Read ZCMD.HIS for a complete history of updates.
;
;   ZCMD2 is ZCPR2.2.3 with special RCPM features for RCPM use.
;   ZCPR2 was originally written by Richard Conn.
;
; Extensive documentation on ZCPR2 and the utilities in the ZCPR2 system
;  can be found in the following manuals:
;
;		ZCPR2 Concepts Manual
;		ZCPR2 Installation Manual
;		ZCPR2 User's Guide
;		ZCPR2 Rationale
;
; ******** Structure Notes ********
;
; ZCMD2 is divided into a number of major sections.  The following is an
;   outline of these sections and the names of the major routines located
;   therein.
;
; Section	Function/Routines
; -------	-----------------
;
;   --		Opening Comments, Equates, and Macro Definitions
;
;    0		JMP Table into ZCMD2
;
;    1		Buffers
;
;    2		CCP Starting Modules
;			CCP	CCP1	CONT	RESTRT	RS1
;			CAPBUF	RSTCCP	RCCPNL	ERROR	PRNNF
;
;    3		Utilities
;			CRLF	CONOUT	CONIN	LCOUT	LSTOUT
;			PAGER	READF	READ	BDOSB	PRINTC
;			PRINT	PRIN1	GETDRV	DEFDMA	DMASET
;			RESET	BDOSJP	LOGIN	OPENF	OPEN
;			GRBDOS	CLOSE	SEARF	SEAR1	SEARN
;			SUBKIL	DELETE	GETUSR	SETUSR
;
;     4 	CCP Utilities
;			SETUD	UCASE	REDBUF	BREAK	SDELM
;			ADVAN	SBLANK	ADDAH	NUMBER	NUMERR
;			HEXNUM	DIRPTR	SLOGIN	DLOGIN	SCANLOG
;			SCANER	SCANX	SCANF	CMDSER
;
;     5 	CCP-Resident Commands and Functions
;     5A		DIR	DIRPR	PRFN	GETSBIT FILLQ
;     5B		ERA
;     5C		LIST
;     5D		TYPE
;     5E		SAVE	EXTEST
;     5F		REN
;     5G		JUMP
;     5H		GO
;     5I		COM	CALLPROG
;     5J		GET	MLOAD	PRNLE	PATH
;
;-----
;
;  The following equates may be used to customize this CCP for the user's
;  system and integration technique.  The following constants are provided:
;
;    REL    - YES if integration is to be done via MOVCPM
;	    - NO if integration is to be done via DDT and SYSGEN
;
;    CCPLOC - Beginning address of CCP; this value can be obtained by
;	      running the public domain utility PROBE.
;
;=====
;
; SPECIAL NOTE:  Look for and change the following lines for your system
;		 requirements.  This is the area that is stuffed with a 
;		 command for auto-execution upon cold boot.  As an example,
;		 upon cold boot, your computer would run SUBMIT.COM and 
;		 look in BOOT.SUB for instructions.  The character count 
;		 is 11.
;		 
; * EXAMPLE ONLY * LEAVE COMMENTED OUT * 
;
;CHRCNT: DB	11		; Number of valid chars in command line
;CMDLIN: DB	'SUBMIT BOOT'   ; Default (cold boot) command
;	 DB	0		; Command string terminator
;
;=====
;
NO	EQU	0
YES	EQU	NOT NO
;
; ************************************
; USER CONFIGURABLE EQUATES BEGIN HERE
; ************************************
;
REL	EQU	NO		; Yes, for MOVCPM integration
MAKESPR	EQU	NO		; Yes, for SPR generation
OZFLOP	EQU	NO		; Yes, if booting Ozzie-1 from floppy
				;   disk system tracks.	
				; No, if MAKESPR is YES (Read OZZIE-1.NOT)
;
	 IF	NOT MAKESPR
	 IF	REL
CCPLOC	EQU	0		; MOVCPM image
	 ENDIF
;
; If REL is NO, obtain the beginning address of your current CCP
;  using PROBE (or its equivalent), then merely set CCPLOC to that
;  value as as in the following line:
;
	 IF	(NOT OZFLOP) AND (NOT REL)
CCPLOC	EQU	0D800H		;*Fill in with BDLSLOC-supplied value
	 ENDIF
;
	 IF	OZFLOP AND (NOT REL)
CCPLOC	EQU	0D400H		; Ozzie-1 floppy disk default CCP
				;   location is here
	 ENDIF
;
; The following gives the required offset to load the CCP into the CP/M
;  SYSGEN image through DDT (the Roffset command).  Note that this value
;  conforms with the standard value presented in the CP/M reference manuals,
;  but it may not necessarily conform with the location of the CCP in your
;  CP/M system -- several systems (Morrow Designs, P&T, Heath ORG-0 and
;  others) have the CCP located at a non-standard address in the SYSGEN image.
;
	 IF	NOT REL
;;CCPR	EQU	980H-CCPLOC	; DDT load offset for normal systems
;;CCPR	EQU	1100H-CCPLOC	; DDT load offset for Morrow Designs
CCPR	EQU	0B00H-CCPLOC	; DDT load offset for Kaypro w/Advent Turbo Rom
	 ENDIF
;
; The following equate identifies the location of the BIOS.  This equate
;  assumes the standard sizes of 800H for ZCMD2 and 0E00H for BDOS and
;  does not need to be modified if the user is running a standard CP/M
;  configuration.
;
BIOS	EQU	CCPLOC+800H+0E00H ; Address of BIOS
	 ENDIF
;
; The following macros define the file types of the command object files
;  (.COM files under CP/M 2.2) to be loaded when a non-resident ZCMD2
;  command is given and of the indirect command files (SUB files under
;  CP/M 2.2) to be used to extract commands from when the indirect 
;  command facility is invoked.
;
COMTYP	 MACRO
	DB	'COM'		; File type of command file
	 ENDM
;
SUBTYP	 MACRO
	DB	'SUB'		; File type of indirect command file
	 ENDM
;
; The following flag enables or disables the ability of ZCMD2 to process
;  SUBMIT files (command files of the form $$$.SUB).  If SUBON is YES,
;  then ZCMD2 will process such files like CP/M's CCP normally does; if
;  SUBON is NO, ZCMD2 will not process such files (just ignores them).  In
;  such a case only indirect command file facilities like ZEX will work.
;
SUBON	EQU	yes		;*Yes, enable processing of $$$.SUB files.
				;   This is a large code eater so beware
 				;   of size.  It's a good one to set NO if
 				;   size >800H.
;
; The following flag allows ZCMD2 to accept commands like:  "A1:DIR".
;  If DRVPREFIX is YES, this form is accepted; if NO, this form is not
;  accepted.  This flag has the additional side effect of automatically
;  selecting files in the current disk/user if the command is of the form
;  "A3>CMND".  The DRVPFATT determines the attributes of selected
;  files if DRVPREFIX is YES.
;
DRVPREFIX EQU	NO		; YES to enable prefix.
;
; The following flag allows the user to select the attributes of the
;  files in the current disk/current user to be examined if the DRVPREFIX
;  flag YES.  The following values are defined:
;
;		DRVPFATT	Files Selected
;		    0		System
;		   80H		Directory
;		    1		Both System and Directory
;
DRVPFATT EQU	1		; Select both system and directory
;
; The following flag enables or disables the ability to switch user
;  areas.  If your BBS system pokes the maximum drive/user area available
;  areas.  If your BBS system pokes DRVMAX/USRMAX memory areas (see below)
;  with a user's maximum drive/user area access, set USERON to YES and you
;  will be just as secure as if you had set it to NO.
;
USERON	EQU	yes		; Enable user specification
SUPRES	EQU	no		; No to see A0> instead of A>
;
; The following equate specifies the address of the PATH to be followed
;  for the PATH command-search if the PATH is to be initialized by the BIOS
;  and set by the user via a PATH.COM program.  The value of PATH should
;  be the address of the PATH data area in memory.  If the internal PATH
;  provided by Z80CCP is to be used, then INTPATH should be equated to YES,
;  which selects the PATH defined by the IPATH MACRO and the SYSOP path
;  (WHEEL).
;  If the external PATH is to be used, then INTPATH should be equated to NO
;  and an equate value for the address of the PATH should be provided.
;
; A PATH is a series of byte-pairs, terminated by a binary 0.  The first
;  byte of each pair is the disk number (1-16 for disks A-P), and the second
;  byte of each pair is the user number (0-31).	The special character '$'
;  indicates the current user or current disk.  For example, the path
;  from current disk/current user to current disk/user 0 to disk A/user 0
;  is selected by the following sequence:
;
;		DB	'$$'	;current disk/user
;		DB	'$',0	;current disk/user 0
;		DB	1,0	;disk A/user 0
;		DB	0	;end of path
;
; NOTE:  If DRVPREFIX is YES, then current disk/user is automatically
;  searched, and including it in the command search path causes it to be
;  searched twice, wasting time (and space in the path).  Since many environs
;  will run with DRVPREFIX = YES, then a good command search path would not
;  include the current disk/user.
;
INTPATH	EQU	YES		; NO to use external ZCMD2 path
;
	 IF	INTPATH
IPATH	 MACRO
	DB	'$$'		; Current drive/user
	DB	'A'-'@',0	; Drive A, user 0.  Set as many pairs as
	 ENDM			;  you like, but leave off terminating 0.
				;  That last 0 is provided elsewhere.
;
; The following equates define the extra path to search if the Wheel
;  byte is ON, and INTPATH is YES.
;
SYSDRV	EQU	'A'-'@'		; Search this drive if WHEEL byte on
SYSUSR	EQU	15		; User area of SYSDRV to find Sysop's
				;   .COM files.
	 ENDIF
;
; This equate defines the base address of the external path
;
	 IF	NOT INTPATH	; External path selected
PATH	EQU	40H		; External ZCMD2 path at CBIOS buffer
				;   area
	 ENDIF			; NOT INTPATH
;
; The following equate causes ERA to confirm on the files to be erased
;  before it goes ahead and erases them.  If ERAOK is YES, then the user
;  will be prompted each time; if it is NO, then the user will not be
;  prompted.
;
ERAOK	EQU	yes		; YES for prompt
;
; If ERAOK is YES, the following equate adds a Verify option to the ERA
;  command which causes the user to be prompted only if the Verify option
;  letter, defined by ERDFLG, is given after the file name.  If ERAV is
;  NO then the user will be asked to verify only when ERDFLG is contained
;  in the command line; if ERAV is NO, the user will always be asked to
;  verify.
;
ERAV	EQU	YES		; Enable verify option
ERDFLG	EQU	'V'		; Set option letter
;
;
; If both BYCLOCK and BYTLOS are set NO (probably because you aren't
;  running NUBYE/BYE5), but you have a clock and want the [hh:mm] shown
;  before the drive/user prompt -- set CLOCK to YES.  You must also
;  edit the macro and clock reading code below for your system needs.
;
CLOCK	EQU	no		;*Yes, you have a clock, but aren't
				;  running NUBYE/BYE5 and want a clock
				;  display.
;
	 IF	CLOCK
;
; CKCLOK is used to check the clock's existence.  If it is turned off
;  (i.e. the clock is in your external modem, which is turned off) or
;  not present, it will skip putting the time in the prompt.  Also allows
;  easy assembly of ZCMD for machines in which the clock might be an
;  optional item to be added later (i.e. Kaypro's).  CKCLOK should 
;  initialize and check the real-time clock.  If it is present and
;  functioning, call TIME, else fall through without doing anything (just
;  displays the normal du> prompt).
;
; NOTE: Example code is for Kaypro internal clock
;
CKCLOK	 MACRO
	MVI	A,0FH		; Initialize PIO port to clock
	OUT	22H
	MVI	A,0CH		; Check 'clock initialized' flag set
	OUT	20H		;  by TIME.COM and CLOCK.BAS
	IN	24H		; Get flag value
	CPI	29H		; Initialized?
	CZ	TIME		; Yes, so print [hh:mm]
	 ENDM
;
; RDCLOK is used to read the clock.  Defined as a macro, it will be located
;  at TIME:, and should get the HH and MM in BCD, call ASCII (as in the
;  sample below) to set up the prompt and then jump to PRIN1 to print it
;  and return.  Modify this to fit your system requirements if CLOCK is YES.
;
; NOTE: Example code is for Kaypro internal clock
;
RDCLOK	 MACRO
	MVI	A,4		; Get hours register
	OUT	20H		; Set that into latch
	IN	24H		; Input BCD value into A
	ORA	A		; Midnight (0)?
	JRNZ	RDCLK1		; No, skip fix
	MVI	A,12H		; Load 12 (midnight)
RDCLK1:	CPI	13H		; PM (13-23 o'clock)?
	JRC	RDCLK2		; No, so print it else...
	SUI	12H		; Subtract 12 to make it 12-hour time
	DAA			; BCD adjustment of subtract
RDCLK2:	LXI	H,ANSHH		; Set pointer to HH in prompt memory
	CALL	ASCII		; And put HH into it in ASCII
	LDA	ANSHH		; Get tens of hours
	CPI	'0'		; Leading zero?
	JRNZ	RDCLK3		; No, so skip fix
	MVI	A,' '		; Fix with space
	STA	ANSHH		; Put it in message
RDCLK3:	MVI	A,3		; Get minutes register
	OUT	20H		; Set that into latch
	IN	24H		; Input BCD value to A
	LXI	H,ANSMM		; Set pointer to MM in prompt memory
	CALL	ASCII		; And put MM into it in ASCII
	MVI	A,16		; Set to R/O register
	OUT	20H		; Put in latch to protect clock on power-down
	LXI	H,TMSG
	JP	PRIN1		; And print it -- done.
	 ENDM
	 ENDIF			; CLOCK AND (NOT BYCLOCK) and (NOT BYTLOS) 
;
; NOTE: Either specify BYCLOCK and BYTLOS as NO, or one as YES and the 
;  other as NO -- but -- don't specify both as YES.
;
; The following equates (BYCLOCK/BYTLOS/SHOW) enable the appearance of
;  [hh:mm], [Left:nn] and [On:nn] before the drive/user prompt, if you
;  have a clock and are running NUBYE or BYE5.  A check is made to see
;  if NUBYE/BYE5 is running and skips the clock read if not.
;
BYCLOCK	EQU	NO		;*Yes, if NYBYE/BYE5 has a clock installed
 				;   and you want the [HH:MM] displayed before
 				;   the du>.
				;   PRIDRIV must be NO for this to work.
				;
BYTLOS	EQU	yes		;*Yes, if NUBYE/BYE5 has a clock installed
 				;   and you want the [Left:nn] displayed
 				;   before the du>, where nn will indicate
 				;   time-left-on-system.
SHOW	EQU	yes		;*Yes, if WHEEL is set, or user has
				;  unlimited time and you wish to show
				;  time-on-system as: '[On:nn]'.
				; NO, if you want to disable display when
				;  WHEEL is set or user has unlimited time.
;
; WARNING -- BYTLOS takes more code than BYCLOCK -- You may have to
;  set SUBON to NO in order to keep the size below 800H.
;
; If you set one of the three transient command equates from above 
;  (i.e. ERAON, SAVEON, OR RENON) to NO, this should keep you well within
;  the 800H limit... The CP/M utility NSWEEP provides you with all three
;  functions.  If you wish to keep these transient commands and use BYTLOS,
;  you will probably have to set SUBON to NO. [tmb]
;
; The MULTCMD equate enables the feature of having more than
;  one command on the same line, separated by a separation char
;  which is defined by the CMDSEP equate. 
;
;  If SUBON is YES, then MULTCMD must be NO - a bug for future fix...? 
;
MULTCMD	EQU	yes		;*Yes, allow multiple commands
CMDSEP	EQU	';'		; Command separator
;
; The following equate allows selection of using an internal or an ex-
; ternal command buffer.
;
EXCBUF	EQU	yes		; YES to use external command buffer
;
	 IF	MULTCMD	AND EXCBUF
CLBASE	EQU	0F093H		; Base address of buffer
BUFLEN	EQU	164		; 164 bytes in input buffer
	 ENDIF
;
; The following flags enable or disable various ZCMD2-resident commands.
;  The user may invoke these as desired, but should keep in mind the size
;  of the resulting ZCMD2 and make sure it does not exceed the required
;  limits.
;
DIRON	EQU	NO		; DIR
LTON	EQU	NO		; LIST, TYPE
GOON	EQU	NO		; GO
ERAON	EQU	yes		;*ERA  \    Can't have all 3 and stay <800H
SAVEON	EQU	yes		;*SAVE  --> (with BYTLOS and SUBON set YES)
RENON	EQU	yes		;*REN  /    Use NSWP to replace either/all.
GETON	EQU	NO		; GET
JUMPON	EQU	NO		; JUMP
; 
; When the WHEEL byte (low memory byte, normally located at 3EH) is
;  used, certain system functions can have restricted access (i.e.
;  ERA may only be used when the WHEEL is ON -- Sysop access).  If this
;  byte is not zero, then the command proceeds.	If it is zero, then the
;  command is not allowed to proceed and is exited with an error message.
;
WHEEL	EQU	YES		; Set YES for RCP/M use always and most
				;   all other applications
WHLADR	EQU	3EH		; Normal address of WHEEL byte
;
; The following set of equates make each of the indicated commands
;  selectable to respond to the WHEEL byte or not (i.e. if WERA is YES,
;  then the ERAse function works when the WHEEL byte is on/set as for
;  Sysop privileges.)
;
WERA	EQU	YES		; ERA only if/when WHEEL is on/set?
WREN	EQU	YES		; REN  "     "	     "	 "    "
WLT	EQU	YES		; TYPE "     "	     "	 "    "
WGO	EQU	YES		; GO   "     "	     "	 "    "
WSAVE	EQU	YES		; SAVE "     "	     "	 "    "
WGET	EQU	YES		; GET  "     "	     "	 "    "
WJUMP	EQU	YES		; JUMP "     "	     "	 "    "
WDU	EQU	NO		; DU:  "     "	     "	 "    "
;
PRIVDIR	EQU	NO		; No, for most everybody (especially RCP/M's)
				; If YES, do not allow users to access
				;    other's directories unless the
				;    WHEEL byte is on/set.  This disables
				;    DU's in the FCB, DRVPREFIX and also
				;    the printing of the current DU.
;
; The INTSTACK equate is used to specify if the stack is internal or
; external to ZCMD2.  Naturally, quite a bit of space is saved if the
; stack is placed external to ZCMD2.  If such is the case, the user
; should set the STKBASE equate to the beginning of the stack area
; (bottom of the stack).
;
; NOTE: THIS IS THE BOTTOM OF THE STACK, NOT THE TOP OF THE STACK.
;
; If INTSTACK is YES, the stack is internal to ZCMD2.  If INTSTACK is NO
; the stack is external to ZCMD2, and the base of the stack (bottom of
; the stack) is located at STKBASE.
;
INTSTACK EQU	no		; Enable or disable internal stack
;
	 IF	NOT INTSTACK
STKBASE	EQU	0F043H		; Address of bottom of external stack
STACK	EQU	STKBASE+4FH	; Address of top of stack
				; (stack size should be at least 48 bytes)
	 ENDIF
;
; *** Terminal and 'type' customization equates
;
NLINES	EQU	24		;*Number of lines on crt screen
WIDE	EQU	YES		; Yes for normal directory display
FENCE	EQU	'|'		;*Separation character between files
HBCON	EQU	NO		;*Yes, ok to send characters with Hi bit
				;   set (i.e. file attribute bits) to
				;   screen unchanged.
HBLST	EQU	NO		;*Yes, ok to send characters with Hi bit
				;   set to LST device unchanged.
PGDFLT	EQU	NO		; Yes, pauses at each screenful of output
PGDFLG	EQU	'P'		; For type command: page or not (dep on
				;   PGDFLT).  This flag reverses the
				;   default effect.
; other general equates
;
MAXDISK	EQU	16		;*Maximum number of drives
				; (i.e. 8 = drives A through H available)
USRMAX	EQU	3FH		; *** 3FH is recommended, if used *** 
				; Location of byte in memory containing
				;   number of highest allowable user
				;   code +1.  This is set to MAXUSR if BYE
				;   is not present, and after that it is con-
				;   trolled by system programs.  Then if
				;   USRMAX=0, MAXUSR cannot be dynamically
 				;   changed, and should be permanently set.
MAXUSR	EQU	15		; Maximum user number accessable (0-15)
				;
DRVMAX	EQU	3DH		; *** 03DH is reccomended, if used ***
				; Location of byte in memory containing
				;   maximum legal drive, this value is
				;   set to MAXDISK if BYE is not present
				;   After that controlled by system programs.
				;   If DRVMAX=0 then MAXDISK cannot be
				;   changed by external programs, and
				;   should be permanently set.
SYSFLG	EQU	'A'		; For dir command: list $SYS and $DIR
SOFLG	EQU	'S'		; For dir command: list $SYS files only
SPRMPT	EQU	'$'		; CCP prompt indicating submit command
NPROMPT	EQU	'>'		; CCP prompt when WHEEL byte is OFF
				;   NOTE: With ZEX, add +80H
WPROMPT	EQU	'}'		; CCP prompt if WHEEL byte is ON
				;   (Set to '>' if you want both the same)
				;   NOTE: With ZEX, add +80H
NUMBASE	EQU	'H'		; Switches from default to number base
SECTFLG	EQU	'S'		; Option character for save command
CURIND	EQU	'$'		; Symbol for current disk or user
COMMENT	EQU	';'		; Depicts comment lines
;
; CCP command name table - each table entry is composed of the 4-byte
; command and 2-byte address
;
NCHARS	EQU	4		; Number of chars/command
;
CTABLE	 MACRO
;
	 IF	DIRON
	DB	'ODIR'
	DW	DIR		; Directory display command
	 ENDIF
;
	 IF	LTON
	DB	'LIST'
	DW	LIST		; List file on printer command
	DB	'TYPE'
	DW	TYPE		; Type file on console command
	 ENDIF
;
	 IF	GOON
	DB	'GO  '
	DW	GO		; Execute current tpa command
	 ENDIF
;
	 IF	ERAON
	DB	'ERA '
	DW	ERA		; Erase files command
	 ENDIF
;
	 IF	SAVEON
	DB	'SAVE'
	DW	SAVE		; Save tpa command
	 ENDIF
;
	 IF	RENON
	DB	'REN '
	DW	REN		; Rename files command
	 ENDIF			; RENON
;
	 IF	GETON
	DB	'GET '
	DW	GET		; Load file into TPA command
	 ENDIF			; GETON
;
	 IF	JUMPON
	DB	'JUMP'
	DW	JUMP		; Jump to any memory location command
	 ENDIF
	 ENDM
;
; This equate determines if the ZCMD2 FCB is located internal to or ex-
; ternal to ZCMD2.  If EXTFCB is YES, FCBADR defines where it is found.
; Placing the ZCMD2 FCB external to ZCMD2, more space is left for other
; uses within ZCMD2.
;
EXTFCB	EQU	NO		; Allow external FCB
;
	 IF	EXTFCB
FCBADR	EQU	0EFD0H		; Address of external FCB
	 ENDIF
;
; CMDRUN - ZCMD2 Extended Command Processing Facility
;
; This equate enables the ZCMD2 CMDRUN facility.  If CMDRUN is YES, then
; another stage of command processing is invoked should ZCMD2 fail to
; find a COM file when the user gives a command.  This stage involves
; invoking the .COM file specified by CMDFCB and giving it the current
; command line as an argument.	In this way, if, say, M80 PROG2 fails as
; a command, a new command like LRUNZ M80 PROG2, SUB M80 PROG2, or ZEX
; M80 PROG2 may be processed.  If the new command fails, an appropriate
; error message is given.
;
; The ROOTONLY option causes ZCMD2 to only look at the Root (bottom of
; path) for the Extended Command Processor if it is set to YES.  If it
; is set to NO, the path is searched for the Extended Command Processor.
; The tradeoff here is that ROOTONLY = YES is less flexible but somewhat
; faster than ROOTONLY = NO.
;
CMDRUN	EQU	NO		; Enable the facility
;
	 IF	CMDRUN
ROOTONLY EQU	YES		; True if look at root only for extended
				;   command processor, NO if look along
				;   path
CMDFCB	 MACRO
	DB	0
	DB	'CMDRUN  '	; Name of program
	DB	'COM'		; File type
	 ENDM
	 ENDIF
;
; end of customization section
;-----
;
CR	EQU	0DH
LF	EQU	0AH
TAB	EQU	9
;
WBOOT	EQU	0		; CP/M warm boot address
UDFLAG	EQU	4		; User num in high nybble, disk in low
BDOS	EQU	5		; BDOS function call entry point
TFCB	EQU	5CH		; Default FCB buffer
TBUFF	EQU	80H		; Default disk I/O buffer
TPA	EQU	100H		; Base of TPA
;
; MACROS to provide Z80 extensions - MACROS include:
;
	$-MACRO			; First turn off the expansions
;
;	JR	- JUMP RELATIVE
;	JRC	- JUMP RELATIVE IF CARRY
;	JRNC	- JUMP RELATIVE IF NO CARRY
;	JRZ	- JUMP RELATIVE IF ZERO
;	JRNZ	- JUMP RELATIVE IF NO ZERO
;	DJNZ	- DECREMENT B AND JUMP RELATIVE IF NO ZERO
;	LDIR	- MOV @HL TO @DE FOR COUNT IN BC
;	LXXD	- LOAD DOUBLE REG DIRECT
;	SXXD	- STORE DOUBLE REG DIRECT
;
;	@GENDD macro used for checking and generating
;	       8-bit jump relative displacements.
;
@GENDD	 MACRO	?DD		; ; Checks range of 8-bit displacements
;
	 IF	(?DD GT	7FH) AND (?DD LT 0FF80H)
	DB	100H		; Displacement range error on jump rel.
	 ELSE
	DB	?DD
	 ENDIF			; ; Range error
	 ENDM			; ; MACRO
;
;-----
;
; Z80 macro extensions
;
JR	 MACRO	?N		; ; Jump relative
	DB	18H
	@GENDD	?N-$-1
	 ENDM
;
JRC	 MACRO	?N		; ; Jump relative on carry
	DB	38H
	@GENDD	?N-$-1
	 ENDM
;
JRNC	 MACRO	?N		; ; Jump relative on no carry
	DB	30H
	@GENDD	?N-$-1
	 ENDM
;
JRZ	 MACRO	?N		; ; Jump relative on zero
	DB	28H
	@GENDD	?N-$-1
	 ENDM
;
JRNZ	 MACRO	?N		; ; Jump relative on no zero
	DB	20H
	@GENDD	?N-$-1
	 ENDM
;
DJNZ	 MACRO	?N		; ; Decrement B and jump relative
	DB	10H
	@GENDD	?N-$-1
	 ENDM
;
LDIR	 MACRO			; ; LDIR
	DB	0EDH,0B0H
	 ENDM
;
LDED	 MACRO	?N		; ; Load DE direct
	DB	0EDH,5BH
	DW	?N
	 ENDM
;
LBCD	 MACRO	?N		; ; Load BC direct
	DB	0EDH,4BH
	DW	?N
	 ENDM
;
SDED	 MACRO	?N		; ; Store DE direct
	DB	0EDH,53H
	DW	?N
	 ENDM
;
SBCD	 MACRO	?N		; ; Store BC direct
	DB	0EDH,43H
	DW	?N
	 ENDM
;
; end of Z80 macro extensions
;-----
;
; **** Section 0 ****
;
; Entry point into ZCMD2
;
; IF MULTCMD (MULTIPLE COMMANDS ON ONE LINE) is NO:  If ZCMD2 is entered
; at location CCPLOC (at the JMP to CCP), then the default command in
; CMDLIN will be processed.  If ZCMD2 is entered at location CCPLOC+3
; (at the JMP to CCP1), then the default command in CMDLIN will NOT be
; processed.  NOTE:  Entry into ZCMD2 at CCPLOC is permitted, but in
; order for this to work, CMDLIN MUST be initialized to contain the
; command line (ending in 0) and the C-register MUST contain a valid
; user/disk flag (the most significant nybble contains the user number
; and the least significant nybble contains the disk number.  Some user
; programs (such as SYNONYM3) attempt to use the default command fa-
; cility.  Under the original CCP, it was necessary to initialize the
; pointer after the reserved space for the command buffer to point to
; the first byte of the command buffer.  The NXTCHR (NeXT CHaRacter
; pointer) is located to be compatable with such programs (if they de-
; termine the buffer length from the byte at BUFSIZ [CCPLOC + 6]), but
; under ZCMD2 this is no longer necessary.  ZCMD2 automatically initial-
; izes this buffer pointer in all cases if MULTCMD is not enabled.
;
; IF MULTCMD is YES: Entry at CCP or CCP1 has the same effect.	Multiple
; command processing will still continue.  Hence, if MULTCMD is NO, a
; user program need only load the buffer CMDLIN with the desired command
; line, terminated by a zero, in order to have this command line exe-
; cuted.  If MULTCMD is YES, a user program must load this buffer as be-
; fore, but he must also set the NXTCHR pointer to point to the first
; character of the command line.  NOTE:  ***** (BIG STAR) ***** Programs
; such as SYNONYM3 will fail if multiple commands are enabled, but this
; feature is so very useful that it is worth the sacrifice.  The ZCMD2
; utilities of STARTUP and MENU require multiple commands, and this
; feature also permits simple chaining of programs to be possible under
; the ZCMD2 environment.
;
	 IF	NOT MAKESPR
	ORG	CCPLOC
	 ENDIF
;
ENTRY:	 IF	NOT OZFLOP
	JMP	CCP		; Process potential default command
	 ENDIF
;
	 IF	OZFLOP
	JMP	BOOTJMP		; Used to properly set the Osborne CCP
				; if using ZCMD from the floppy disk system
				; tracks  the first two bytes must
				; be C3H, 5CH
	 ENDIF
;
	JMP	CCP1		; Do not process potential default cmd
;
;-----
;
; **** Section 1 ****
;
; Buffers et al - input command line and default command
;
; The command line to be executed is stored here.  This command line is
; generated in one of 3 ways:
;
;	(1) by the user entering it through the BDOS READLN function at
;		the DU> prompt [user input from keyboard]
;	(2) by the SUBMIT File Facility placing it there from a $$$.SUB
;		file
;	(3) by an external program or user placing the required command
;		into this buffer
;
; In all cases, the command line is placed into the buffer starting at
; CMDLIN.  This command line is terminated by a binary zero.  ZCMD2 then
; parses, interprets, and executes the command line.  Case is not signi-
; ficant in the command line.  ZCMD2 converts all lower-case letters to
; upper-case.  If MULTCMD is YES, then the user must set a pointer to
; the first character of the command line into the buffer NXTCHR.  If
; MULTCMD is NO, no action other than placing a zero-terminated command
; line into the buffer starting at CMDLIN is required on the part of the
; user.  For multiple commands, the command line buffer (CMDLIN) is lo-
; cated external to ZCMD2 so that it is not overlayed during warm boots;
; the same is YES for NXTCHR, the 2nd key buffer.  BUFSIZ and CHRCNT are
; not important and are provided so the BDOS READLN function can load
; CMDLIN directly and a user program can see how much space is available
; in CMDLIN for its text.
;
	 IF	MULTCMD	AND EXCBUF
NXTCHR	EQU	CLBASE		; Nxtchr stored externally (2 bytes)
BUFSIZ	EQU	NXTCHR+2	; Bufsiz stored externally (1 byte)
CHRCNT	EQU	BUFSIZ+1	; Chrcnt stored externally (1 byte)
CMDLIN	EQU	CHRCNT+1	; Cmdlin stored externally (long)
	 ENDIF
;
; These buffers are left internal to ZCMD2 so that the original CCP
; command line facility (as used by programs like SYNONYM3) can be left
; intact.
;
; **** NOTE: Change the two lines marked with an asterisk (*) in the
;      comment field for command execution on cold boot (i.e. system
;      resets).
;
	 IF	NOT EXCBUF
BUFLEN	EQU	80		    ; Maximum buffer length
BUFSIZ:	DB	BUFLEN		    ; Maximum buffer length
CHRCNT:	DB	0		    ;*Number of valid chars in command line
CMDLIN:	DB	'           '       ;*Default (cold boot) command
	DB	0		    ; Command string terminator
	DS	BUFLEN-($-CMDLIN)+1 ; Total is 'BUFLEN' bytes
NXTCHR:	DW	CMDLIN		    ; Pointer to command input buffer
	 ENDIF
;
; File type for command
;
COMMSG:	COMTYP			; Use macro
;
; Submit file control block
;
	 IF	SUBON
SUBFCB:	DB	1		; Disk name set to default to drive A:
	DB	'$$$'		; File name
	DB	'     '
	SUBTYP			; Use macro from ZCMDHDR.LIB
	DB	0		; Extent number
	DB	0		; S1
SUBFS2:	DS	1		; S2
SUBFRC:	DS	1		; Record count
	DS	16		; Disk group map
SUBFCR:	DS	1		; Current record number
	 ENDIF
;
; Command file control block
;
	 IF	EXTFCB
FCBDN	EQU	FCBADR		; Disk name
FCBFN	EQU	FCBDN+1		; File name
FCBFT	EQU	FCBFN+8		; File type
FCBDM	EQU	FCBFT+7		; Disk group map
FCBCR	EQU	FCBDM+16	; Current record number
	 ENDIF
;
	 IF	NOT EXTFCB
FCBDN:	DS	1		; Disk name
FCBFN:	DS	8		; File name
FCBFT:	DS	3		; File type
	DS	1		; Extent number
	DS	2		; S1 and S2
	DS	1		; Record count
FCBDM:	DS	16		; Disk group map
FCBCR:	DS	1		; Current record number
	 ENDIF
;
; Line count buffer
;
PAGCNT:	DB	NLINES-2	; Lines left on page
;
; CCP command name table - each table entry is composed of the four-byte
; command and two-byte address.
;
CMDTBL:	CTABLE			; Define command table via macro
;
NCMNDS	EQU	($-CMDTBL)/(NCHARS+2)
;
;-----
;
; **** Section 2 ****
;
; ZCMD2 starting points
;
; Now see if BYE is running
;
CCP:	LXI	SP,STACK	; Set the stack
	PUSH	B
	PUSH	D
	MVI	A,CR
	CALL	CONOUT		; This is required to make BYE's BDCHEK
	MVI	C,32		; Reset locations 6 and 7 after warmboot
	MVI	E,241
	CALL	BDOS		; Call BYE's BDOS
	POP	D
	POP	B
	CPI	77		; Running?
	JRZ	CCP2		; Yes, continue without setting defaults
;
	 IF	USRMAX
	MVI	A,MAXUSR+1	; Set USRMAX on cold boot
	STA	USRMAX
	 ENDIF
;
	 IF	DRVMAX
	MVI	A,MAXDISK-1	; Set DRVMAX on cold boot
	STA	DRVMAX
	 ENDIF
;
	 IF	USRMAX OR DRVMAX
	MVI	A,0FFH
	STA	WHLADR		; Set WHEEL
	 ENDIF
;
	JR	CCP2		; On to coldboot routine
;
; Start ZCMD2 and don't process default command stored if multiple com-
; mands are not allowed.  This is the warmboot entry.
;
CCP1:	 IF	NOT MULTCMD
	XRA	A		; For no default command
	STA	CMDLIN		; First char of buffer
	 ENDIF
;
; Start ZCMD2 and possibly process default command
;
; NOTE: BDOS returns 0FFH in A-register whenever it logs in a directory,
; if any file name contains a '$' in it.  This is now used as a clue to
; determine whether or not to do a search for submit file, in order to
; eliminate wasteful searches.
;
; Process default command if present (this is the cold boot entry).
;
CCP2:	LXI	SP,STACK	; Reset stack
;
	 IF	NOT MULTCMD
	LXI	H,CMDLIN	; Set ptr to beginning of command line
	SHLD	NXTCHR
	 ENDIF
;
	PUSH	B
	MOV	A,C		; C=user/disk number (see loc 4)
	RAR			; Extract user number
	RAR
	RAR
	RAR
	ANI	0FH
	STA	CURUSR		; Set user
	CALL	SETUSR
	CALL	RESET		; Reset disk system
;
	 IF	SUBON
	STA	RNGSUB		; Save submit clue from drive a:
	 ENDIF
;
	 IF	MAKESPR
BIOS	EQU	0		; So we don't get assembler errors <wm>
	PUSH	H
	LHLD	0000H+1		; Get BIOS vector
	LXI	B,3
	DAD	B		; Point to BIOS+6 (console status)
	SHLD	BIOCAL2+1
	DAD	B		; Point to BIOS+9 (console input)
	SHLD	BIOCAL1+1
	SHLD	BIOCAL3+1
	SHLD	BIOCAL4+1
	POP	H		; This was missing from v2.0  < wm >
	 ENDIF
;
	POP	B
	MOV	A,C		; C=user/disk number (see loc 4)
	ANI	0FH		; Extract current disk drive
	STA	CURDR		; Set it
	CALL	LOGIN		; Log in default disk
	CALL	SETUD		; Set user/disk flag
	CALL	DEFDMA		; Set default dma address
;
	 IF	SUBON
	LXI	D,SUBFCB	; Check for $$$.sub on current disk
;
RNGSUB	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; 2nd byte (immediate arg)
	ORA	A		; Set flags on clue
	CNZ	SEAR1
	STA	RNGSUB		; Set flag (0=no $$$.sub)
	 ENDIF
;
; Test for next command in continuous loop if multiple command line buf-
; fer is enabled.
;
	 IF	MULTCMD
CONT:
	 ENDIF
;
	LHLD	NXTCHR		; Point to next character to process
	MOV	A,M		; Get it
	CPI	3		; Restart if CTL-C
	JRZ	RESTRT
	ORA	A		; 0 if no command line present
	JRNZ	RS1
;
; Test for any default command before continuous loop entered if mul-
; tiple command line buffer is disabled.
;
	 IF	NOT MULTCMD
CONT:
	 ENDIF
;
; Ppompt user and input command line from him
;
RESTRT:	LXI	SP,STACK	; Reset stack
;
; The following code added to dynamically set INTPATH to extra search
; level if WHEEL is ON, and reset that level if Wheel is off.
;
	 IF	WHEEL AND INTPATH
	LDA	WHLADR		; Get wheel byte
	ORA	A
	MVI	A,0		; Reset search path if off
	JZ	$+5
	MVI	A,SYSDRV	; Set search drive if wheel on
	STA	WHLPTH		; Into the search path
	 ENDIF
;
; Print prompt: DU>
;
	CALL	CRLF		; Print prompt
;
	 IF	PRIVDIR		; If private directories
	LDA	WHLADR		; Don't print drive/user prompt
	ORA	A		; If wheel not enabled
	JRZ	RS000
	 ENDIF
;
	 IF	(BYCLOCK OR BYTLOS) AND (NOT CLOCK)
	MVI	C,32
	MVI	E,241
	CALL	BDOS
	CPI	77		; Is NUBYE/BYE5 running?
	CZ	TIME		; Yes, display time prompts
	 ENDIF
;
	 IF	CLOCK AND (NOT BYCLOCK) AND (NOT BYTLOS)
	CKCLOK			; Predefined macro for clock check 
	 ENDIF
;
	 IF	BYCLOCK OR BYTLOS OR CLOCK
	LDA	CURUSR
	CALL	SETUSR		; Fixes the submit function
	 ENDIF
;
	LDA	CURDR		; Current drive is part of prompt
	ADI	'A'		; Convert to ASCII A-P
	CALL	CONOUT
	LDA	CURUSR		; Get user number
;
	 IF	SUPRES
	ORA	A
	JRZ	RS000
	 ENDIF
;
	CPI	10		; User < 10?
	JRC	RS00
	SUI	10		; Subtract 10 from it
	PUSH	PSW		; Save it
	MVI	A,'1'		; Output 10's digit
	CALL	CONOUT
	POP	PSW
;
RS00:	ADI	'0'		; Output 1's digit (convert to ASCII)
	CALL	CONOUT
;
; Read input line from user or $$$.SUB
;
RS000:	LXI	H,CMDLIN	; Set pointer to first character
	SHLD	NXTCHR		; Pointer to next character to process
	MVI	M,0		; Zero out command line
	PUSH	H		; Save pointer
	CALL	REDBUF		; Input command line from user
	POP	H		; Get pointer
	MOV	A,M		; Check for comment line
	CPI	COMMENT		; Begins with comment character?
	JRZ	RESTRT		; Input another line if so
	ORA	A		; No input?
	JRZ	RESTRT
;
; Process input line - HL points to first letter of command
;
RS1:	LXI	SP,STACK	; Reset stack
;
	 IF	MULTCMD
	MOV	A,M		; Get first char of command
	CPI	CMDSEP		; Is it a command separator?
	JRNZ	RS2
	INX	H		; Skip it if it is
	SHLD	NXTCHR		; Set pointer back
	 ENDIF
;
; Set pointer fro multiple command line processing to first character of
; new command
;
RS2:	SHLD	CMDCH1		; Set pointer to first character
;
; Capitalize command line
;
CAPBUF:	MOV	A,M		; Capitalize command character
	CALL	UCASE
	MOV	M,A
	INX	H		; Point to next character
	ORA	A		; Eol?
	JRNZ	CAPBUF
	CALL	SCANER		; Parse command name from command line
	JRNZ	ERROR		; Error if command name contains a '?'
	LXI	D,RSTCCP	; Put return address of command
	PUSH	D		; On the stack
;
COLON	EQU	$+1		; Flag for in-the-code modification
	MVI	A,0		; Command of the form 'DU:command'?
	ORA	A		; 0=no
	JNZ	COM		; Process as com file if not
	CALL	CMDSER		; Scan for cpr-resident command
	JNZ	COM		; Not cpr-resident
	MOV	A,M		; Found it:  get low-order part
	INX	H		; Get high-order part
	MOV	H,M		; Store high
	MOV	L,A		; Store low
	PCHL			; Execute cpr routine
;
; Entry point for restarting CCP and logging in default drive
;
RSTCCP:	CALL	DLOGIN		; Log in current user/disk
;
; Entry point for restarting CCP without logging in default drive
;
RCCPNL:	CALL	SCANER		; Extract next token from command line
	LDA	FCBFN		; Get first char of token
	CPI	' '		; Any char?
	JZ	CONT		; Continue with next command if no error
;
; Invalie command - print it
;
ERROR:	CALL	CRLF		; New line
;
CURTOK	EQU	$+1		; Pointer for in-the-code modification
	LXI	H,0		; Pt to beginning of command line
;
ERR1:	MOV	A,M		; Get character
	CPI	' '+1		; Simple '?' if <sp> or less
	JRC	ERR2
	CALL	CONOUT		; Print command char
	INX	H		; Pt to next char
	JR	ERR1		; Continue
;
ERR2:	CALL	PRINT		; Show input error
	DB	' <-- Erro','r'+80H
;
ERR3:	CALL	DLOGIN		; Panic restore of default user/disk
;
	 IF	SUBON
	CALL	SUBKIL		; Terminate active $$$.SUB if any
	 ENDIF
;
	JMP	RESTRT		; Restart CCP
;
; No File Error Message
;
PRNNF:	CALL	PRINTC		; No file message
	DB	'No Fil','e'+80H
	RET
;
;-----
;
; * Section 3 ****
;
; I/O utilities
;
; Output character in A-register to CRT and don't change 'BC'
; Output <CRLF>
;
CRLF:	MVI	A,CR
	CALL	CONOUT
	MVI	A,LF
	JR	CONOUT
;
CONIN:	MVI	C,1		; Input character
	CALL	BDOS		; Get input character with ^S
	JMP	UCASE		; Capitalize
;
CONOUT:	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,2
;
	 IF	HBLST AND (NOT HBCON)
	ANI	7FH		; Wipe out Hi bit for CON, not LST
	 ENDIF
;
OUTPUT:	 IF	NOT (HBCON AND HBLST)
	ANI	7FH		; Wipe out Hi bit for CON and LST
	 ENDIF
;
	MOV	E,A
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
LCOUT:	PUSH	PSW		; Output character to CRT
;
PRFLG	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; 2nd byte (immediate argument)
	ORA	A		; 0=type
	JRZ	LC1
	POP	PSW		; Get character
;
; Output character in A-register to list device
;
LSTOUT:	PUSH	B		; Save regs
	PUSH	D
	PUSH	H
	MVI	C,5
;
	 IF	HBCON AND (NOT HBLST)
	ANI	7FH		; Wipe out Hi bit for LST but not CON
	 ENDIF
;
	JR	OUTPUT
;
LC1:	POP	PSW		; Get character
	PUSH	PSW
	CALL	CONOUT		; Output to CRT
	POP	PSW
	CPI	LF		; Check for paging
	RNZ
;
; Paging routines - PAGER counts down lines and pauses for direct input
; if count expires, PAGSET sets lines per page count.
;
PAGER:	PUSH	H
	LXI	H,PAGCNT	; Count down
	DCR	M
	JRNZ	PAGER1		; Jump if not end of page
	MVI	M,NLINES-2	; Refill counter
;
PGFLG	EQU	$+1		; Pointer to in-the-code buffer pgflg
	MVI	A,0		; 0 may be changed by pgflg equate
	CPI	PGDFLG		; Page default override option wanted?
;
	 IF	PGDFLT
	JRZ	PAGER1		; PGDFLG means no paging, please
	 ENDIF
;
	 IF	NOT PGDFLT
	JRNZ	PAGER1		; Pgdflg means please paginate
	 ENDIF
;
	PUSH	B		; Save registers
;
BIOCAL1:CALL	BIOS+9		; BIOS console input routine
	POP	B		; Get register
	CPI	'C'-'@'		; ^C
	JZ	RSTCCP		; Restart CCP
;
PAGER1:	POP	H		; Restore HL
	RET
;
; Read file block function
;
READF:	LXI	D,FCBDN		; Fall through to read
;
READ:	MVI	C,14H		; Fall through to BDOSB
;
; Call BDOS and save 'BC'
;
BDOSB:	PUSH	B
	CALL	BDOS
	POP	B
	ORA	A
	RET
;
; Print string (ending in character with MSB set) pointed to by return
; address - start with <CRLF>
;
PRINTC:	CALL	CRLF		; New line
;
PRINT:	XTHL			; Get ptointer to string
	CALL	PRIN1		; Print string
	XTHL			; Restore HL and return address
	RET
;
; Print string (ending in 0 or byte with MSB set) pointed to by 'HL'
;
PRIN1:	MOV	A,M		; Get next byte
	INX	H		; Point to next byte
	ORA	A		; End of string?
	RZ			; String terminated by binary 0
	PUSH	PSW		; Save flags
	ANI	7FH		; Mask out MSG
	CALL	CONOUT		; Print character
	POP	PSW		; Get flags
	RM			; String terminated by MSB set
	JR	PRIN1
;
; BDOS function routines
;
; Return number of current disk in 'A'
;
GETDRV:	MVI	C,19H
	JR	BDOSJP
;
; Set 80H as DMA address
;
DEFDMA:	LXI	D,TBUFF		; 80H=TBUFF
;
DMASET:	MVI	C,1AH
	JR	BDOSJP
;
RESET:	MVI	C,0DH
;
BDOSJP:	JMP	BDOS
;
LOGIN:	MOV	E,A
	MVI	C,0EH
	JR	BDOSJP		; Save some code space
;
OPENF:	XRA	A
	STA	FCBCR
	LXI	D,FCBDN		; Fall thrrough to OPEN
;
OPEN:	MVI	C,0FH		; Fall through to GRBDOS
;
GRBDOS:	CALL	BDOS
	INR	A		; Set zero flag for error return
	RET
;
CLOSE:	MVI	C,10H
	JR	GRBDOS
;
SEARF:	LXI	D,FCBDN		; Specify FCB
;
SEAR1:	MVI	C,11H
	JR	GRBDOS
;
SEARN:	MVI	C,12H
	JR	GRBDOS
;
; Check for submit file in execution and abort if so
;
	 IF	SUBON
SUBKIL:	LXI	H,RNGSUB	; Check for submit file in execution
	MOV	A,M
	ORA	A		; 0=no
	RZ
	MVI	M,0		; Abort submit file
	LXI	D,SUBFCB	; Delete $$$.SUB
	 ENDIF
;
DELETE:	MVI	C,13H
	JR	BDOSJP		; Save more space
;
; Get/set user number
;
GETUSR:	MVI	A,0FFH		; Get current user number
;
SETUSR:	MOV	E,A		; User number in 'E'
	MVI	C,20H		; Set user number to value in 'E'
	JR	BDOSJP		; More space saving
;
; end of BDOS Functions
;-----
;
; * Section 4 ****
;
; ZCMD2 utilities
;
; Set user/disk flag to current user and default disk
;
SETUD:	CALL	GETUSR		; Get number of current user
	ANI	0FH		; Mask sure 4 bits
	ADD	A		; Place it in high nybble
	ADD	A
	ADD	A
	ADD	A
	LXI	H,CURDR		; Mask in current drive number
	ORA	M		; Mask in
	STA	UDFLAG		; Set user/disk number
	RET
;
; Convert character in 'A' to upper-case
;
UCASE:	ANI	7FH		; Mask out MSB
	CPI	61H		; Lower-case 'A'
	RC
	CPI	7BH		; Greater than lower-case Z?
	RNC
	ANI	5FH		; Capitalize
	RET
;
; Input next command to CCP - This routine determines if a SUBMIT file
; is being processed and extracts the command line from it if so or from
;  the user's console
;
REDBUF:	 IF	SUBON
	LDA	RNGSUB		; Submit file currently in execution?
	ORA	A		; 0=no
	JRZ	RB1		; Get line from console if not
	LXI	D,SUBFCB	; Open $$$.SUB
	PUSH	D		; Save DE
	CALL	OPEN
	POP	D		; Restore DE
	JRZ	RB1		; Erase $$$.SUB if end of file
	LDA	SUBFRC		; Get value of last record in file
	DCR	A		; Pt to next to last record
	STA	SUBFCR		; New value of last record in $$$.SUB
	CALL	READ		; DE=SUBFCB
	JRNZ	RB1		; Abort $$$.SUB if error
	LXI	D,CHRCNT	; Copy last record (next submit cmnd)
	LXI	H,TBUFF		; From TBUFF
	LXI	B,BUFLEN	; Number of bytes
	LDIR
	LXI	H,SUBFS2	; Point to S2 of $$$.SUB FCB
	MVI	M,0		; Set S2 to zero
	INX	H		; Point to record count
	DCR	M		; Decrement record count of $$$.SUB
	LXI	D,SUBFCB	; Close $$$.SUB
	CALL	CLOSE
	JRZ	RB1		; Abort $$$.SUB if error
	MVI	A,SPRMPT	; Print submit prompt
	CALL	CONOUT
	LXI	H,CMDLIN	; Print command line from $$$.SUB
	CALL	PRIN1
	CALL	BREAK		; Check for abort (any char)
	RNZ			; If no ^C, return to caller and run
	CALL	SUBKIL		; Kill $$$.SUB if abort
	JMP	RESTRT		; Restart CCP
;
; Input command line from user console
;
RB1:	CALL	SUBKIL		; Erase $$$.sub if present
	 ENDIF
;
	MVI	A,':'
	CALL	CONOUT
;
	 IF	WHEEL
	LDA	WHLADR
	ORA	A		; WHEEL on?
	 ENDIF
;
	MVI	A,NPROMPT	; Normal prompt
;
	 IF	WHEEL
	JRZ	RB2		; No, show normal prompt
	MVI	A,WPROMPT	; ...else, show WHEEL prompt
	 ENDIF
;
RB2:	CALL	CONOUT
	MVI	C,0AH		; Read command line from user
	LXI	D,BUFSIZ
	CALL	BDOS
;
; Store zero at end of command line
;
	LXI	H,CHRCNT	; Point to character count
	MOV	A,M		; Get character count
	INX	H		; Pt to first character of command line
	CALL	ADDAH		; Pt to after last char of command line
	MVI	M,0		; Store ending zero
	RET
;
; Check for any character from user console, return with zero set if
; none.
;
BREAK:	PUSH	B		; Save registers
	PUSH	D
	PUSH	H
;
BIOCAL2:CALL	BIOS+6		; Console status check
	ORA	A		; Set flags
;
BIOCAL3:CNZ	BIOS+9		; Get input char with ^s processing
	CPI	'S'-'@'		; Pause if ^S
;
BIOCAL4:CZ	BIOS+9		; Get next character
	POP	H		; Restore registers
	POP	D
	POP	B
	CPI	'C'-'@'		; Check for abort
	RET
;
; Check to see if DE points to delimiter, if so return with zero flag
; set.
;
SDELM:	LDAX	D
	ORA	A		; 0=delimiter
	RZ
	CPI	' '+1		; Delim if <= <SP>
	JRC	ZERO
	CPI	'='		; '='=delimiter
	RZ
	CPI	5FH		; Underscore=delimiter
	RZ
	CPI	'.'		; '.'=delimiter
	RZ
	CPI	':'		; ':'=delimiter
	RZ
	CPI	','		; ','=delimiter
	RZ
	CPI	';'		; ';'=delimiter
	RZ
	CPI	'<'		; '<'=delimiter
	RZ
	CPI	'>'		; '>'=delimiter
;
	 IF	MULTCMD
	RZ
	CPI	CMDSEP		; Command separator
	 ENDIF
;
	RET
;
ZERO:	XRA	A		; Set zero flag
	RET
;
; Advance input pointer to first non-blank and fall through to SBLANK
;
ADVAN:	LDED	NXTCHR		; Point to next character
;
; Skip string pointed to by DE (string ends in 0 OR CMDSEP) until end of
; string or non-delimited encounterd (beginning of token).
;
SBLANK:	LDAX	D		; Get character
	ORA	A		; Zero?
	RZ
;
	 IF	MULTCMD
	CPI	CMDSEP		; Command separator?
	RZ
	 ENDIF
;
	CALL	SDELM		; Skip over delimiter
	RNZ
	INX	D		; Advance to next char
	JR	SBLANK
;
; Add A ro HL (HL=HL+A)
;
ADDAH:	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
;
; Extract decimal number from command line - return with value in A-reg.
; All registers may be affected.
;
NUMBER:	CALL	SCANER		; Parse number and place in fcbfn
	LXI	H,FCBFN+10	; Pt to end of token for conversion
	MVI	B,11		; 11 characters maximum
;
; Check for suffix for hexadecimal number
;
NUMS:	MOV	A,M		; Get character from end
	DCX	H		; Back up
	CPI	' '		; Space?
	JRNZ	NUMS1		; Check for suffix
	DJNZ	NUMS		; Count down
	JR	NUM0		; By default, process
;
NUMS1:	CPI	NUMBASE		; Check against base switch flag
	JRZ	HNUM0
;
; Process decimal number
;
NUM0:	LXI	H,FCBFN		; Point to beginning of token
;
NUM0A:	LXI	B,1100H		; C=accumulated value, b=char count
;				; (c=0, b=11)
NUM1:	MOV	A,M		; Get character
	CPI	' '		; Done if <SP>
	JRZ	NUM2
	CPI	':'		; Done if colon
	JRZ	NUM2
	INX	H		; Pt to next char
	SUI	'0'		; Convert to binary
	CPI	10		; Error if >= 10
	JRNC	NUMERR
	MOV	D,A		; Digit in d
	MOV	A,C		; New value = old value * 10
	RLC			; *2
	JRC	NUMERR
	RLC			; *4
	JRC	NUMERR
	RLC			; *8
	JRC	NUMERR
	ADD	C		; *9
	JRC	NUMERR
	ADD	C		; *10
	JRC	NUMERR
	ADD	D		; New value = old value * 10 + digit
	JRC	NUMERR		; Check for range error
	MOV	C,A		; Set new value
	DJNZ	NUM1		; Count down
;
; Return from number
;
NUM2:	MOV	A,C		; Get accumulated value
	RET
;
; Number error routine for space conservation
;
NUMERR:	JMP	ERROR		; Use error routine
;
; Extract hexadecimal number from command line - return with value in
; A-reg, all registers may be affected.
;
HEXNUM:	CALL	SCANER		; Parse number and place in FCBFN
;
HNUM0:	LXI	H,FCBFN		; Point to token for conversion
	LXI	D,0		; De=accumulated value
	MVI	B,11		; B=character
;
HNUM1:	MOV	A,M		; Get character
	CPI	' '		; Done?
	JRZ	HNUM3		; Return if so
	CPI	NUMBASE		; Done if numbase suffix
	JRZ	HNUM3
	SUI	'0'		; Convert to binary
	JRC	NUMERR		; Return and done if error
	CPI	10		; 0-9?
	JRC	HNUM2
	SUI	7		; A-F?
	CPI	10H		; Error?
	JRNC	NUMERR
;
HNUM2:	INX	H		; Point to next characer
	MOV	C,A		; Digit in 'C'
	MOV	A,D		; Get accumulated value
	RLC			; Exchange nybbles
	RLC
	RLC
	RLC
	ANI	0F0H		; Mask out low nybble
	MOV	D,A
	MOV	A,E		; Switch low-order nybbles
	RLC
	RLC
	RLC
	RLC
	MOV	E,A		; High nybble of e=new high of e
	ANI	0FH		; Get new low of d
	ORA	D		; Mask in high of d
	MOV	D,A		; New high byte in d
	MOV	A,E
	ANI	0F0H		; Mask out low of e
	ORA	C		; Mask in new low
	MOV	E,A		; New low byte in e
	DJNZ	HNUM1		; Count down
;
; Return from HEXNUM
;
HNUM3:	XCHG			; Returned value in hl
	MOV	A,L		; Low-order byte in a
	RET
;
; point to directory entry in TBUFF whose offset is specified by A and C
;
DIRPTR:	LXI	H,TBUFF		; Point to temporary buffer
	ADD	C		; Point to 1st byte of directory entry
	CALL	ADDAH		; Point to desired byte in dir entry
	MOV	A,M		; Get desired byte
	RET
;
; Check for specified drive and log it in
;
SLOGIN:	XRA	A		; A=0 for default disk
	STA	FCBDN		; Select default disk since user/disk
;
TEMPDR	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; 2nd byte (immediate arg) is tempdr
	ORA	A		; 0=current drive
	JRNZ	SLOG1
	LDA	CURDR		; Log in current drive
	INR	A		; Add 1 for next dcr
;
SLOG1:	DCR	A		; Adjust for proper disk number (a=0)
	CALL	LOGIN		; Log in new drive
;
TEMPUSR	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; 2nd byte is user to be selected
	JMP	SETUSR		; Log in new user
;
; Check for specified drive and log in default drive
;
DLOGIN:	DS	0
;
CURDR	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; Prep to log in current drive
	CALL	LOGIN		; Login current drive
;
CURUSR	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; Prep to log in current user number
	JMP	SETUSR		; Log in new user
;
; Routine to check for a wheel byte as non-zero, if wheel byte is zero,
; then abort (pop stack and return).
;
	 IF	WHEEL
WHLCHK:	LDA	WHLADR		; Get wheel byte
	ORA	A		; Zero?
	RNZ			; Ok if not
	JMP	ERROR		; Process as error
	 ENDIF
;
; Extract token from command line and place it into FCBDN, format FCBDN
; FCB if token resembles file name and type (filename.typ).  On input,
; MXTCHR points to character at which to start scan.  On output, NXTCHR
; points to character at which to continue and zero flag is reset if
; if '?' is in token
;
; Entry points:
;	SCANLOG - load token into first FCB and log in temp user/disk
;	SCANER	- load token into first FCB
;	SCANX	- load token into FCB pointed to by 'HL'
;
SCANLOG:CALL	SCANER		; Do scan
	PUSH	PSW		; Save flag
	CALL	SLOGIN		; Log in temporary user/disk
	POP	PSW		; Get flag
	RET
;
SCANER:	LXI	H,FCBDN		; Point to FCBDN
;
SCANX:	XRA	A		; A=0
	STA	TEMPDR		; Set temporary drive number to default
	MOV	M,A		; Set first byte of FCBDN
	STA	COLON		; Set no colon flag
	LDA	CURUSR		; Get current user
	STA	TEMPUSR		; Set tempusr
	CALL	ADVAN		; Skip to non-blank or end of line
	SDED	CURTOK		; Set ptr to non-blank or end of line
	MVI	B,11		; Prep for possible space fill
	JRZ	SCAN4		; Done if eol
;
; Scan token for DU: form, which means we have a user/disk specification
; DE points to next character in line, HL points ro FCBDN.
;
	PUSH	D		; Save pointer to first character
	CALL	SDELM		; Check for delimiter and get first char
	CPI	'A'		; In letter range?
	JRC	SCAN1
	CPI	'P'+1		; In letter range?
	JRC	SCAN1A
;
SCAN1:	CPI	'0'		; Check for digit range
	JRC	SCAN2
	CPI	'9'+1		; In digit range?
	JRNC	SCAN2
;
SCAN1A:	INX	D		; Pt to next char
	CALL	SDELM		; Check for delimiter, else digit
	JR	SCAN1
;
SCAN2:	POP	D		; Restore ptr to first char
	CPI	':'		; Was delimiter a colon?
	JRNZ	SCAN3		; Done if no colon
	STA	COLON		; Set colon found
;
	 IF	PRIVDIR
	CALL	WHLCHK		; Mod by PST to not allow ':' in FCB
	 ENDIF
;
; Scan for and extract user/disk info - on entry, HL point to FCBDN, DE
; points to first character and A-register contains the first character.
;
	LDAX	D		; Get first character
	CPI	'A'		; Convert possible drive spec to number
	JRC	SUD1		; If less than 'a', must be digit
;
; Set disk number (A=1)
;
	SUI	'A'-1
;
	 IF	DRVMAX
	PUSH	B		; Save 'BC'
	PUSH	PSW		; Save drive request
	LDA	DRVMAX		; Get maximum legal drive
	ADI	2		; Bump it two for the compare
	MOV	B,A		; Save maximum drive in 'B'
	POP	PSW		; Restore drive request
	CMP	B		; See if illegal drive
	POP	B		; Restore bc
	 ENDIF
;
	 IF	NOT DRVMAX
	CPI	MAXDISK+1	; Within range?
	 ENDIF
;
	JNC	ERROR		; Invalid disk number
	STA	TEMPDR		; Set temporary drive number
	MOV	M,A		; Set fcbdn
	INX	D		; Pt to next char
	LDAX	D		; See if it is a colon (:)
	CPI	':'
	JRZ	SUD2		; Done if no user number (it is a colon)
;
; Set user number
;
SUD1:	PUSH	H		; Save pointer to FCBDN
	XCHG			; Hl pts to first digit
	CALL	NUM0A		; Get number
	XCHG			; De pts to terminating colon
;
	 IF	USRMAX
	LXI	H,USRMAX
	CMP	M
	 ENDIF
;
	 IF	NOT USRMAX
	CPI	MAXUSR+1	; Within limit?
	 ENDIF
;
	POP	H		; Get pointer to FCBDN
	JNC	ERROR
;
	 IF	USERON
	STA	TEMPUSR		; Save user number
	 ENDIF
;
SUD2:	INX	D		; Point to character after colon
;
; Extract filename from possible FILENAME.TYP - DE points to next char-
; acter to process, HL points tao FCBDN.
;
SCAN3:	XRA	A		; A=0
	STA	QMCNT		; Init question mark count
	MVI	B,8		; Max of 8 chars in file name
	CALL	SCANF		; Fill FCB file name
;
; Extract file type from possible FILENAME.TYP
;
	MVI	B,3		; Prepare to extract type
	LDAX	D		; Get last char which stopped scan
	CPI	'.'		; Have a type if de) delimiter is a '.'
	JRNZ	SCAN4		; Fill file type bytes with <sp>
	INX	D		; Pt to char in command line after '.'
	CALL	SCANF		; Fill fcb file type
	JR	SCAN5		; Skip to next processing
;
SCAN4:	CALL	SCANF4		; Space fill
;
; Fill in EX, S1, S2, and RC with zeroes
;
SCAN5:	MVI	B,4		; 4 bytes
	XRA	A		; A=0
	CALL	SCANF5		; Fill with zeroes
;
; Scan complete -- DE points to delimiter byte after token
;
	SDED	NXTCHR
;
; Set zero flag to indicate presence of '?' in FILENAME.TYPE
;
QMCNT	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; Number of question marks
	ORA	A		; Set zero flag to indicate any '?'
	RET
;
; Scan token pointed to by DE for a max of B bytes; place it into file
; name field pointed to by HL; expand and interpret wild cards of '*'
; '?'; on exit, DE points to terminating delimiter.
;
SCANF:	CALL	SDELM		; Done if delimiter encountered
	JRZ	SCANF4
	INX	H		; Point to next byte in FCBDN
	CPI	'*'		; Is (DE) a wild card?
	JRNZ	SCANF1		; Continue if not
	MVI	M,'?'		; Place '?' in FCB
	CALL	SCQ		; Scanner count question marks
	JR	SCANF2
;
SCANF1:	MOV	M,A		; Store filename char in fcb
	INX	D		; Pt to next char in command line
	CPI	'?'		; Check for question mark (wild)
	CZ	SCQ		; Scanner count question marks
;
SCANF2:	DJNZ	SCANF		; Decrement char count until 8 elapsed
;
SCANF3:	CALL	SDELM		; 8 chars or more - skip until delimiter
	RZ			; Zero flag set if delimiter found
	INX	D		; Pt to next char in command line
	JR	SCANF3
;
; Fill memory pointed to by HL with spaces for B bytes
;
SCANF4:	MVI	A,' '		; Fill with spaces
;
SCANF5:	INX	H		; Point to next byte in FCB
	MOV	M,A		; Fill with byte in A-reg.
	DJNZ	SCANF5
	RET
;
; Increment question mark count for scanner - this routine increments
; the count of the number of question marks in the current FCB entry.
;
SCQ:	PUSH	H		; Save HL
	LXI	H,QMCNT		; Get count
	INR	M		; Increment
	POP	H		; Get HL
	RET
;
; CMDTBL (command table) scanner
;   On return, HL points to address of command if CCP-resident
;   On return, zero flag set means CCP-resident command
;
CMDSER:	LXI	H,CMDTBL	; Point to command table
	MVI	C,NCMNDS	; Set command counter
	MOV	A,C		; Check number of commands
	ORA	A		; If none, then abort
	JRZ	CMS5
;
CMS1:	LXI	D,FCBFN		; Point to stored command name
	MVI	B,NCHARS	; Number of chars/command (8 max)
;
CMS2:	LDAX	D		; Compare against table entry
	CMP	M
	JRNZ	CMS3		; No match
	INX	D		; Point to next character
	INX	H
	DJNZ	CMS2		; Count down
	LDAX	D		; Next char must be a space
	CPI	' '
	JRNZ	CMS4
	RET			; Command is CCP-resident
;
CMS3:	INX	H		; Skip to next command table entry
	DJNZ	CMS3
;
CMS4:	INX	H		; Skip address
	INX	H
	DCR	C		; Decrement table entry number
	JRNZ	CMS1
;
CMS5:	INR	C		; Clear zero flag
	RET			; Command is disk-resident
;
;-----
;
; **** section 5 ****
;
; CCP-resident commands
;
; Section:  5A
; Command:  DIR
; Function: To display a directory of the files on disk
; Forms:
;	DIR <AFN>	displays the DIR files
;	DIR <AFN> s	displays the SYS files
;	DIR <AFN> a	display both DIR and SYS files
;
;   NOTES:
;	the flag SYSFLG defines the letter used to display both DIR and
;		SYS files (A in the above forms section)
;	the flag SOFLG defines the letter used to display only the SYS
;		files (S in the above forms section)
;	the flag WIDE determines if the file names are spaced further
;		apart (wide=yes) for 80-col screens
;	the flag FENCE defines the character used to separate the file
;		names
;
	 IF	DIRON		; Dir enabled
DIR:	CALL	SCANLOG		; Extract possible D:FILENAME.TYP token
	LXI	H,FCBFN		; Make FCB wild (all '?') if no NAME.TYP
	MOV	A,M		; Get first chararacter of NAME.TYPE
	CPI	' '		; If space, all wild
	CZ	FILLQ
	CALL	ADVAN		; Look at next input char
	MVI	B,80H		; Prepare for dir-only selection
	JRZ	DIRDN		; There is no flag, so dir only
	MVI	B,1		; Set for both dir and sys files
	CPI	SYSFLG		; System and dir flag specifier?
	JRZ	GOTFLG		; Got system specifier
	CPI	SOFLG		; Sys only?
	JRNZ	DIRDN
	DCR	B		; B=0 for sys files only
;
GOTFLG:	INX	D		; Pt to char after flag
;
DIRDN:	SDED	NXTCHR		; Set pointer for next pass then drop
				;   DIRRPR to print directory and go
				;   restart CCP
	 ENDIF
;
; Directory print routine; on entry, B- reg is set as follows:
;	0 for only system files, 80H for only DIR files, 1 for both
;
	 IF	DIRON OR ERAON
DIRPR:	MOV	A,B		; Get flag
	STA	SYSTST		; Set system test flag
	MVI	E,0		; Set column counter to zero
	PUSH	D		; Save column counter (e)
	CALL	SEARF		; Search for specified file
	JRNZ	DIR3
	CALL	PRNNF		; Print no file msg; reg a not changed
	XRA	A		; Set zero flag
	POP	D		; Restore de
	RET
;
; Entry selection loop; on entry, A=offset from SEARF or SEARN
;
DIR3:	CALL	GETSBIT		; Get and test for type of files
	JRZ	DIR6
	POP	D		; Get entry count (=<CR> counter)
	MOV	A,E		; Add 1 to it
	INR	E
	PUSH	D		; Save it
	ANI	03H		; Output <CRLF> if 4 entries printed
	JRNZ	DIR4
	CALL	CRLF		; New line
	JR	DIR5
;
DIR4:	CALL	PRINT
;
	 IF	WIDE
	DB	'  '		; 2 spaces
	DB	FENCE		; Then fence char
	DB	' ',' '+80H	; Then 2 more spaces
	 ENDIF
;
	 IF	NOT WIDE
	DB	' '		; Space
	DB	FENCE		; Then fence char
	DB	' '+80H		; Then space
	 ENDIF
;
DIR5:	MVI	B,01H		; Pt to 1st byte of file name
	MOV	A,B		; A=offset
	CALL	DIRPTR		; Hl now pts to 1st byte of file name
	CALL	PRFN		; Print file name
;
DIR6:	CALL	BREAK		; Check for abort
	JRZ	DIR7
	CALL	SEARN		; Search for next file
	JRNZ	DIR3		; Continue if file found
;
DIR7:	POP	D		; Restore stack
	MVI	A,0FFH		; Set nz flag
	ORA	A
	RET
	 ENDIF
;
; Print file name pointed to by HL
;
PRFN:	MVI	B,8		; 8 chars
	CALL	PRFN1
	MVI	A,'.'		; Dot
	CALL	CONOUT
	MVI	B,3		; 3 chars
;
PRFN1:	MOV	A,M		; Get char
	INX	H		; Pt to next
	CALL	CONOUT		; Print char
	DCR	B		; Count down
	JRNZ	PRFN1
	RET
;
; After a search, return NZ set if desired type of file found, Z if not.
; This algorithm looks at the system bit of the located file.  This bit
; is set to 1 if the file is a system file and 0 if not a system file.
; The following exclusive or masks are applied to return Z or NZ as re-
; quired by the calling program:
;
;   System byte: x 0 0 0  0 0 0 0	after 80H mask, x=1 if SYS
;
;   SYS-only   : 0 0 0 0  0 0 0 0	XOR 0   = 0 if X=0   (or 80H if X=1)
;   DIR-only   : 1 0 0 0  0 0 0 0	XOR 80H = 80H if X=0 (or 0 if X=1)
;	both   : 0 0 0 0  0 0 0 1	XOR 1   = 81H or 1H  (or NZ for both)
;
GETSBIT:DCR	A		; Adjust to returned value
	RRC			; Convert number to offset into tbuff
	RRC
	RRC
	ANI	60H
	MOV	C,A		; Offset into TBUFF in c
	MVI	A,10		; Add 10 to point to SYS file attribute
	CALL	DIRPTR		; A=system byte
	ANI	80H		; Look at only system bit
;
SYSTST	EQU	$+1		; In-the-code variable
	XRI	0		; If SYSTST=0, sys only; if =80h, DIR
	RET			; NZ if ok, Z if not ok
;
; Fill FCB @HL with '?'
;
FILLQ:	MVI	B,11		; Number of characters in FN & FT
;
FQLP:	MVI	M,'?'		; Store '?'
	INX	H
	DJNZ	FQLP
	RET
;
; Section:  5B
; Command:  ERA
; Function: Erase files
; Forms:
;	ERA <AFN>	erase specified files and print their names
;	ERA <AFN> V	erase specified files and print their names,
;			  but ask for verification before erase is done
;   NOTES::
;	Several key flags affect this command:
;		ERAV  - if yes, the V- option is enabled, and the char-
;			  acter which turns it on (the V) is defined by
;			  ERDFLG.
;		ERACK - if yes, the ok? prompt is enabled
;			  If ERAO is NO, the verification feature is
;			    disabled regardless of what value ERAV has
;			  If ERAOK is yes, then:
;				If ERAV is yes, verification is request-
;				  ed only if the V-flag (actual letter
;				  defined by ERDFLG) is in the cmd line
;				If ERAV is NO, verification is always
;				   requested, and a V-flag in the com-
;				   mand line will cause an error message
;				   to be printed (v?) after the ERA is
;				   completed.
;
	 IF	ERAON
ERA:	 IF	WERA
	CALL	WHLCHK		; Check for it
	 ENDIF
;
	CALL	SCANLOG		; Parse file specification
;
	 IF	ERAV AND ERAOK
	CALL	ADVAN		; Get ERAFLG if it's there
	STA	ERAFLG		; Save it as a flag
	JRZ	ERA1		; Jump if input ended
	INX	D		; Put new buffer pointer
;
ERA1:	XCHG			; Put pointer into HL
	SHLD	NXTCHR		; Set pointer to byte for next command
	 ENDIF
;
	MVI	B,1		; Display all matching files
	CALL	DIRPR		; Print directory of erased files
	RZ			; Abort if no files
;
	 IF	ERAOK
	 IF	ERAV
ERAFLG	EQU	$+1		; Address of flag
	MVI	A,0		; 2nd byte is flag
	CPI	ERDFLG		; Is it a verify option?
	JRNZ	ERA2		; Skip prompt if it is not
	 ENDIF
;
	CALL	PRINTC
	DB	'OK to Erase','?'+80H
	CALL	CONIN		; Get reply
	CPI	'Y'		; Yes?
	RNZ			; Abort if not
	 ENDIF
;
ERA2:	LXI	D,FCBDN		; Delete file specified
	CALL	DELETE
	RET			; Reenter cpr
	 ENDIF
;
; Section:  5C
; Command:  LIST
; Function: Print out specified file on the lst device
; Fforms:
;	LIST <UFN>	print file (no paging)
;
; NOTES: The flags which apply to type do not take effect with list
;
	 IF	LTON
LIST:	MVI	A,0FFH		; Turn on printer flag
	JR	TYPE0
;
; Section:  5D
; Command:  TYPE
; Function: Print out specified file on the con: device
; Forms:
;	TYPE <UFN>	print file
;	TYPE <UFN> P	print file with paging flag
;
;   NOTES:
;	The flag PGDFLG defines the letter which toggles the paging
;		facility (P in the forms section above)
;	The flag PGDFLT determines if type is to page by default
;		(PGDFLT=YES if type pages by default); combined with
;		PGDFLG, the following events occur --
;			If PGDFLT = YES, PGDFLG turns off paging
;			If PGDFLT = NO, PGDFLG turns on paging
;
TYPE:	XRA	A		; Turn off printer flag
;
; Entry point for CCP list function (list)
;
TYPE0:	STA	PRFLG		; Set flag
;
	 IF	WLT
	CALL	WHLCHK		; Check wheel byte
	 ENDIF
;
	CALL	SCANLOG		; Extract FILENAME.TYP toden
	JNZ	ERROR		; Error if any question marks
	CALL	ADVAN		; Get pgdflg if it's there
	STA	PGFLG		; Save it as a flag
	JRZ	TYPE1		; Jump if input ended
	INX	D		; Put new buf pointer
;
TYPE1:	SDED	NXTCHR		; Set pointer for next command
	CALL	OPENF		; Open selected file
	JZ	ERROR		; Abort if error
	CALL	CRLF		; New line
	MVI	A,NLINES-1	; Set line count
	STA	PAGCNT
	LXI	B,80H		; Set character position and tab count
;
; Main loop for loading next block
;
TYPE2:	MOV	A,C		; Get character count
	CPI	80H
	JRC	TYPE3
	PUSH	H		; Read next block
	PUSH	B
	CALL	READF
	POP	B
	POP	H
	JRNZ	TYPE7		; Error?
	MVI	C,0		; Set character count
	LXI	H,TBUFF		; Poin to first character
;
; Main loop for printing character in TBUFF
;
TYPE3:	MOV	A,M		; Get next char
	ANI	7FH		; Mask out msb
	CPI	1AH		; End of file (^z)?
	RZ			; Restart cpr if so
;
; Output character to CRT or list device with tabulation
;
	CPI	CR		; Reset tab count?
	JRZ	TYPE4
	CPI	LF		; Reset tab count?
	JRZ	TYPE4
	CPI	TAB		; Tab?
	JRZ	TYPE5
;
; Output character and increment character count
;
	CALL	LCOUT		; Output char
	INR	B		; Increment tab count
	JR	TYPE6
;
; Output <CR> or <LF> and reset tab count
;
TYPE4:	CALL	LCOUT		; Output <CR> or <LF>
	MVI	B,0		; Reset tab counter
	JR	TYPE6
;
; Tabulate
;
TYPE5:	MVI	A,' '		; Space
	CALL	LCOUT
	INR	B		; Increment position count
	MOV	A,B
	ANI	7
	JRNZ	TYPE5
;
; Continue processing
;
TYPE6:	INR	C		; Increment char count
	INX	H		; Pt to next char
	CALL	BREAK		; Check for abort
	RZ			; Restart if so
	JR	TYPE2
;
TYPE7:	DCR	A		; No error?
	RZ			; Restart cpr
	JMP	ERROR
	 ENDIF
;
; Section:  5E
; Command:  SAVE
; Function: To save the contents of the TPA onto disk as a file
; Forms:
;	SAVE <number of pages> <UFN>
;		save specified number of pages (start at 100H)
;		from TPA into specified file; <number of pages> in DEC
;	SAVE <number of sectors> <UFN> s
;		like SAVE above, but numeric argument specifies number
;		of sectors rather than pages
;NOTES:
;	The MULTCMD flag (multiple commands allowed) expands the code
;		slightly, but is required to support multiple commands
;		 with SAVE
;	The SECTFLG defines the letter which indicates a sector count
;		(S in the forms section above)
;
	 IF	SAVEON
SAVE:	 IF	WSAVE
	CALL	WHLCHK		; Check for wheel byte
	 ENDIF
;
	CALL	NUMBER		; Extract number from command line
	MOV	L,A		; HL=page count
	MVI	H,0
	PUSH	H		; Save page count
	CALL	EXTEST		; Test for existence of file
	MVI	C,16H		; Bdos make file
	CALL	GRBDOS
	POP	H		; Get page count
	JRZ	SAVE3		; Error?
	XRA	A		; Set record count field
	STA	FCBCR
	CALL	ADVAN		; Look for 's' for sector option
	INX	D		; Pt to after 's' token
	CPI	SECTFLG
	JRZ	SAVE0
	DCX	D		; No 's' token, so back up
	DAD	H		; Double it for HL=record (128 bytes)
;
SAVE0:	SDED	NXTCHR		; Set pointer to bad token
	LXI	D,TPA		; Point to start of SAVE area (TPA)
;
SAVE1:	MOV	A,H		; Done with save?
	ORA	L		; HL=0 if so
	JRZ	SAVE2
	DCX	H		; Count down on record
	PUSH	H		; Save pointer to block to save
	LXI	H,128		; 128 bytes per record
	DAD	D		; Point to next record
	PUSH	H		; Save on stack
	CALL	DMASET		; Set DMA address for write (addr in DE)
	LXI	D,FCBDN		; Write record
	MVI	C,15H		; Bdos write record
	CALL	BDOSB		; Save bc
	POP	D		; Get ptr to next record in DE
	POP	H		; Get record count
	JRNZ	SAVE3		; Write error?
	JR	SAVE1		; Continue
;
SAVE2:	LXI	D,FCBDN		; Close saved file
	CALL	CLOSE
	INR	A		; Error?
	JRNZ	SAVE4
;
SAVE3:	CALL	PRNLE		; Print 'no space' error
;
SAVE4:	JMP	DEFDMA		; Set DMA to 80 and restart cpr
	 ENDIF
;
; Test file in FCB for existence, ask user to delete if so, and abort if
; he chooses not to.
;
	 IF	SAVEON OR RENON
EXTEST:	CALL	SCANLOG		; Extract file name and log in user/disk
	JNZ	ERROR		; '?' is not permitted
	CALL	SEARF		; Look for specified file
	LXI	D,FCBDN		; Point to file FCB
	RZ			; Ok if not found
	PUSH	D		; Save pointer to FCB
	CALL	PRINTC
	DB	'Erase',' '+80H
	LXI	H,FCBFN		; Point to file name field
	CALL	PRFN		; Print it
	MVI	A,'?'		; Print question
	CALL	CONOUT
	CALL	CONIN		; Get response
	POP	D		; Get ptr to fcb
	CPI	'Y'		; Key on yes
	JNZ	ERR3		; Restart as error if no
	PUSH	D		; Save ptr to fcb
	CALL	DELETE		; Delete file
	POP	D		; Get ptr to fcb
	RET
	 ENDIF
;
; Section:  5F
; Command:  REN
; Function: To change the name of an existing file
; Forms:
;	REN <new UFN>=<old UFN> perform function
;
	 IF	RENON
REN:	 IF	WREN
	CALL	WHLCHK		; Check for wheel byte
	 ENDIF
;
	CALL	EXTEST		; Test for file existence and return
	LDA	TEMPDR		; Save selected disk
	PUSH	PSW		; Save on stack
;
REN0:	LXI	H,FCBDN		; Save new file name
	LXI	D,FCBDM
	LXI	B,16		; 16 bytes
	LDIR
	CALL	ADVAN		; Advance to next character (non-delim)
	JRZ	REN4		; Error if none
;
; Perform rename function
;
REN1:	SDED	NXTCHR		; Save pointer to old file name
	CALL	SCANER		; Extract FILENAME.TYP token
	JRNZ	REN4		; Error if any '?'
	POP	PSW		; Get old default drive
	MOV	B,A		; Save it
	LXI	H,TEMPDR	; Compare it against selected drive
	MOV	A,M		; Default?
	ORA	A
	JRZ	REN2
	CMP	B		; Check for drive error
	JRNZ	REN4
;
REN2:	MOV	M,B
	XRA	A
	STA	FCBDN		; Set default drive
	LXI	D,FCBDN		; Rename file
	MVI	C,17H		; BDOS rename FCT
	CALL	GRBDOS
	RNZ
;
REN3:	CALL	PRNNF		; Print NO FILE message
;
REN4:	JMP	ERROR
	 ENDIF
;
RSTJMP:	JMP	RCCPNL		; Restart CCP
;
; Section:  5G
; Command:  JUMP
; Function: To call the program (subroutine) at the specified address
;	     without loading from disk
; Forms:
;	JMMP <adr>		call at <ADR>;<ADR> is in hex
;
	 IF	JUMPON
JUMP:	 IF	WJUMP
	CALL	WHLCHK		; Check for wheel byte
  	 ENDIF
;
	CALL	HEXNUM		; Get load address in HL
	JR	CALLPROG	; Perform call
	 ENDIF
;
; Section:  5H
; Command:  GO
; Function: To call the program in the TPA without loading from disk.
;		Same as JMP 100H, but much more convenient, especially
;		when used with parameters for programs like STAT.  Also,
;		can be allowed on remote-access systems.
; Form:
;	GO <parameters like for command>
;
	 IF	GOON
GO:	 IF	WGO
	CALL	WHLCHK		; Check for wheel byte
	 ENDIF
;
	LXI	H,TPA		; Always to TPA
	JR	CALLPROG	; Perform call
	 ENDIF
;
; Section:  5I
; Command:  COM file processing
; Function: To load the specified .COM file from disk and execute it
; Forms:    <command line>
; NOTES:    .COM files are processed as follows --
;		1. file name buffers are initialized and a preliminary
;			error check is done
;		2. MLOAD is used to search for the file along the path
;			and load it into the TPA
;		3. CALLPROG is used to set up the buffers to be used by
;			the transient (FCB at 5CH, FCB at 6CH, TBUFF at
;			80H) and run the program
;	The flag MULTCMD comes into play frequently here; it mainly
;		serves to save space if MULTCMD is NO and and enables
;		multiple commands on the same line if MULTCMD is YES.
;
COM:	LDA	FCBFN		; Any command?
	CPI	' '		; ' ' means command was 'D:' to switch
	JRNZ	COM1		; Must be transient or error
;
; Entry point to select user/disk
;
	 IF	WDU
	CALL	WHLCHK		; Check for wheel byte
	 ENDIF
;
	LDA	COLON		; Look for colon flag
	ORA	A		; If zero, just blank
	RZ			; Return to main routine
;
; Command is DU:, so log in user/disk
;
	LDA	TEMPUSR		; Get selected user
	CPI	10H		; Make sure 4 bits
	JNC	ERROR		; Range error?
	STA	CURUSR		; Set current user
	CALL	SLOGIN		; Log in user/disk as if temporarily
;
; Now, make login permanent
;
	LDA	TEMPDR		; Get selected drive
	ORA	A		; If 0 (default), no change
	JRZ	COM0
	DCR	A		; Adjust for log in
	STA	CURDR		; Set current drive
;
COM0:	JMP	SETUD		; Set current user/disk
;
; Process command
;
COM1:	LXI	D,FCBFT		; Point to file type
	LDAX	D		; Get first character of file type
	CPI	' '		; Must be blank, or error
	JNZ	ERROR
	LXI	H,COMMSG	; Place default file type (com) into fcb
	LXI	B,3		; 3 bytes
	LDIR
	LXI	H,TPA		; Set execution/load address
	PUSH	H		; Save for execution
;
	 IF	CMDRUN
	MVI	A,0FFH		; Use it if available
	 ENDIF
;
	CALL	MLOAD		; Load memory with file specified
	POP	H		; Get execution address
;
; Entry point for the execution of the loaded program; on entry to this
; routine, HL must contain the execution address of the program (subrou-
; tine) to execute.
;
CALLPROG:
	SHLD	EXECADR		; Perform in-line code modification
	CALL	SCANER		; Search command line for next token
	LXI	H,TEMPDR	; Save pointer to drive specification
	PUSH	H
	MOV	A,M		; Set drive specification
	STA	FCBDN
	LXI	H,FCBDN+10H	; Pt to 2nd file name
	CALL	SCANX		; Scan for it and load it into fcb+16
	POP	H		; Set up drive specs
	MOV	A,M
	STA	FCBDM
	XRA	A
	STA	FCBCR
	LXI	D,TFCB		; Copy to default FCB
	LXI	H,FCBDN		; From FCBDN
	LXI	B,33		; Set up default FCB
	LDIR
;
CMDCH1	EQU	$+1		; In-the-code buffer address of 1st char
	LXI	H,CMDLIN
;
CALLP1:	MOV	A,M		; Skip to end of 2nd file name
	ORA	A		; End of line?
	JRZ	CALLP2
;
	 IF	MULTCMD
	CPI	CMDSEP		; Command separator?
	JRZ	CALLP2
	 ENDIF
;
	CPI	' '		; End of token?
	JRZ	CALLP2
	INX	H
	JR	CALLP1
;
; Load command line into TBUFF
;
CALLP2:	MVI	B,0		; Set character count
	LXI	D,TBUFF+1	; Point to character position
;
CALLP3:	MOV	A,M		; Copy command line to TBUFF
	STAX	D
	ORA	A		; Done if zero
	JRZ	CALLP5
;
	 IF	MULTCMD
	CPI	CMDSEP		; Done if command separator
	JRZ	CALLP4
	 ENDIF
;
	INR	B		; Increment character count
	INX	H		; Point to next
	INX	D
	JR	CALLP3
;
	 IF	MULTCMD
CALLP4:	XRA	A		; Store ending zero
	STAX	D		; Instead of cmdsep
	 ENDIF
;
; Run loaded transient program
;
CALLP5:	 IF	MULTCMD
	SHLD	NXTCHR		; Save pointer to continue processing
	 ENDIF
;
	MOV	A,B		; Save character count
	STA	TBUFF
	CALL	CRLF		; New line
	CALL	DEFDMA		; Set DMA to 80
;
; Execution (call) of program (subroutine) occurs here
;
EXECADR	EQU	$+1		; Change address for in-line code mod.
	CALL	TPA		; Call transient
	CALL	DEFDMA		; Set DMA to 80 in case it was changed
	CALL	DLOGIN		; Login current user/disk
	JMP	CONT		; Restart CCP and continue command
;
; Section:  5J
; Command: GET
; Function: To load the specified file from disk to the specified
;		 address
; Forms:
;	GET <adr> <UFN> load the specified file at the specified page;
;	    <adr> is in hex
;
	 IF	GETON
GET:	 IF	WGET
	CALL	WHLCHK		; Check wheel byte
	 ENDIF
;
	CALL	HEXNUM		; Get load address in hl
	PUSH	H		; Save address
	CALL	SCANER		; Get file name
	POP	H		; Restore address
	JNZ	ERROR		; Must be unambiguous
;
;
; Fall through to MLOAD
;
	 IF	CMDRUN
	XRA	A		; No cmdrun if facility is there
	 ENDIF
	 ENDIF
;
;
; Memory load subroutine
;
; Load memory with the file whose name is specified in the command line.
; On input, HL contains starting address to load.  Exit points are a re-
; turn and log-in current user/disk if no error, a jmp to error if .COM
; file not found or a message and abort if memory full.
;
MLOAD:	 IF	CMDRUN
	STA	CRFLAG		; Save flag
	 ENDIF
;
	SHLD	LOADADR		; Set load address
;
; Reentry point for a non-standard CP/M modification.  The path command-
; search is implemented by this routine
;
MLA:	 IF	DRVPREFIX
	 IF	PRIVDIR
	LDA	WHLADR		; Don't allow prefixes unless
	ORA	A		; User is a wheel
	LXI	H,PATH
	JRZ	MLA0
	 ENDIF
;
	MVI	A,DRVPFATT	; Set flag per user spec for sys/non-sys
	STA	SYSTST		; Test flag in getsbit
	CALL	SLOGIN		; Look under temporary user/disk
	CALL	SEARF		; Look for file
;
MLARUN:	LXI	H,PATH		; Point to path for failure possibility
	JRNZ	MLA4		; Found it -- load it and run
	 ENDIF
;
	 IF	NOT DRVPREFIX
MLARUN:	LXI	H,PATH		; Point to path
	 ENDIF
;
MLA0:	MOV	A,M		; Get drive
	ORA	A		; 0=done=command not found
;
	 IF	CMDRUN
	JRNZ	NOCRUN		; Not ready for cmd run yet
;
CRFLAG	EQU	$+1		; Pointer for in-the-code modification
	MVI	A,0		; Check crflag
	ORA	A		; 0=no
	JZ	ERROR		; Process as error
;
	 IF	ROOTONLY
	PUSH	H
	 ENDIF
;
	XRA	A		; Do not reenter this code
	STA	CRFLAG		; Set zero for no entry
	LHLD	CMDCH1		; Get pointer to first char of command
	DCX	H		; Pt to char count
	MVI	M,' '		; Store leading space
	SHLD	CMDCH1		; Point to leading space as first char
	SHLD	NXTCHR		; Next char is first char of command
	LXI	H,CFCB		; Set cfcb as command
	LXI	D,FCBDN		; By copying it into fcbdn
	LXI	B,12		; Only 12 bytes required
	LDIR
;
	 IF	ROOTONLY
	JR	MLA3RT
	 ENDIF
;
	 IF	NOT ROOTONLY
	XRA	A		; A=0
	JR	MLARUN		; Now try the run
	 ENDIF
;
CFCB:	CMDFCB			; FCB defining initial command
;
NOCRUN:	 ENDIF			; CMDRUN
;
	 IF	NOT CMDRUN
	JZ	ERROR		; Transient load error -- file not found
	 ENDIF
;
; Look for command in directory pointed to by HL; drive in 'A:'
;
	CPI	CURIND		; Current drive specified?
	JRNZ	MLA1		; Skip default drive selection if so
	LDA	CURDR		; Get current drive
	INR	A		; Set a=1
;
MLA1:	STA	TEMPDR		; Select different drive if not current
	MVI	A,1		; Accept both SYS and DIR files
	STA	SYSTST		; Test flag is 1 for both
	INX	H		; Point to user number
	MOV	A,M		; Get user number
	INX	H		; Poin to next entry in path
	PUSH	H		; Save pointer
	ANI	7FH		; Mask out system bit
	CPI	CURIND		; Current user specified?
	JRNZ	MLA2		; Do not select current user if so
	LDA	CURUSR		; Get current user number
;
MLA2:	STA	TEMPUSR		; Set temporary user number
	CMA			; System bit is 0 if SYS-only
	ANI	80H
	JRNZ	MLA3		; Flag not set if system bit=0
	STA	SYSTST		; Flag is 0 for SYS-only, 1 for both
;
MLA3:	CALL	SLOGIN		; Log in path-specified user/disk
;
MLA3RT:	CALL	SEARF		; Look for file
	POP	H		; Get ptr to next path entry
	JRZ	MLA0		; Continue path search if search failed
				; Load if search succeeded
;
; File found -- perform system test and proceed if approved
;
MLA4:	PUSH	H		; Save pointer
	CALL	GETSBIT		; Check system bit
	POP	H		; Get pointer
	JRZ	MLA0		; Continue if no match
	CALL	OPENF		; Open file for input
;
LOADADR	EQU	$+1		; Memory load address (in-line code mod)
	LXI	H,TPA		; Set start address of memory load
;
MLA5:	 IF	NOT MAKESPR	; Can't reconcile the MVI if SPR
	MVI	A,ENTRY/256-1	; Get high-order adr of just below CCP
	 ENDIF
;
	 IF	MAKESPR		; Do different way
	PUSH	B
	LXI	B,ENTRY
	MOV	A,B		; Put high order address in A
	DCR	A		; Minus 1
	POP	B		; Restore B
	 ENDIF
;
	CMP	H		; Are we going to overwrite the CCP?
	JRC	PRNLE		; Error if so
	PUSH	H		; Save address of next sector
	XCHG			; In DE
	CALL	DMASET		; Set DMA address for load
	LXI	D,FCBDN		; Read next sector
	CALL	READ
	POP	H		; Get address of next sector
	JRNZ	MLA6		; Read error or EOF?
	LXI	D,128		; Move 128 bytes per sector
	DAD	D		; Point to next sector in HL
	JR	MLA5
;
MLA6:	DCR	A		; Load complete
	JZ	DLOGIN		; Ok if zero, else fall thru to prnle
;
; Load error
;
PRNLE:	CALL	PRINTC
	DB	'Ful','l'+80H
	CALL	DLOGIN		; Restore current user/disk
	JMP	RESTRT		; Restart zcmd
;
; The following routine will fetch HHMM from NUBYE/BYE5 (or your clock
;  if BYCLOCK/BYTLOS is NO and CLOCK is YES) and display it as [hh:mm]
;  in front of your du> prompt.
;
	 IF	BYCLOCK	AND (NOT BYTLOS) AND (NOT CLOCK)
TIME:	MVI	C,79
	CALL	BDOS		; Get BYE's RTC address
	MOV	A,M		; Get HH (it's in BCD)
	PUSH	H		; Save address
	LXI	H,ANSHH		; Storage location
	CALL	ASCII		; Convert and store ascii
	POP	H		; Get address back
	INX	H
	MOV	A,M		; Get MM, also in bcd
	LXI	H,ANSMM		; Storage location
	CALL	ASCII		; Convert and store ascii
	LXI	H,TMSG
	JMP	PRIN1		; And print it, return from prin1
	 ENDIF
;
	 IF	CLOCK AND (NOT BYCLOCK) AND (NOT BYTLOS)
TIME:	RDCLOK			; Predefined macro clock read code
	 ENDIF
;
	 IF	(BYCLOCK AND (NOT BYTLOS)) OR CLOCK
ASCII:	PUSH	PSW		; Save BCD pair
	RAR
	RAR
	RAR
	RAR
	ANI	0FH		; Get MSB of BCD pair
	ADI	'0'		; Make ASCII
	MOV	M,A		; Store it
	INX	H		; Point to next store location
	POP	PSW
	ANI	0FH		; Get LSB of BCD pair
	ADI	'0'		; Convert to ASCII
	MOV	M,A		; Store it
	RET
;
TMSG:	DB	'['
ANSHH:	DB	'00:'
ANSMM:	DB	'00] ',0
	 ENDIF
;
; The following routine will display [Left:nn] or [On:nn], depending
;  on your equate settings (BYTLOS and SHOW).  Normal users will be
;  shown their time-left-on-system (i.e. [Left:nn]), while those with
;  WHEEL privileges or unlimited time will be shown their time-on-system
;  (i.e. [On:nn]). 
;
	 IF	BYTLOS AND (NOT	BYCLOCK) AND (NOT CLOCK)
TIME:	MVI	C,79
	CALL	BDOS		; Get current time-on-system
	PUSH	PSW		; And save it
	MVI	C,81
	MVI	E,255		; Get maxtime allowed
	CALL	BDOS
	MOV	B,A		; Put it in B
	ORA	A
	JRZ	TIME1		; User has unlimited time
	LDA	WHLADR
	ORA	A
	JRNZ	TIME1		; Wheel byte is on
	POP	PSW		; TOS in A
	MOV	C,A		; Now in C
	MOV	A,B		; Maxtime in A
	SUB	C		; Maxtime-TOS=TLOS
	LXI	H,TLOS		; Storage area
	CALL	DEC8		; Convert/store to ascii
	LXI	H,TLOSM
	CALL	PRIN1		; Print first part
	LXI	H,TLOS2
	JMP	PRIN1		; And second part, exit from prin1
;
TIME1:	POP	PSW		; Get TOS for wheel or unlimited time users
;
	 IF	NOT SHOW
	RET
	 ENDIF
;
	 IF	SHOW
	LXI	H,TLOS1		; Storage area
	CALL	DEC8		; Convert/ store to ascii
	LXI	H,TLOSM1
	CALL	PRIN1		; Print first part [On:xx 
	LXI	H,TLOS2
	JMP	PRIN1		; second part, then exit from prin1	
	 ENDIF
;
TLOSM:	DB	'[Left:'
TLOS:	DB	'   ',0		; Buffer for tlos or tos
;
	 IF	SHOW
TLOSM1:	DB	'[On:'
TLOS1:	DB	'   ',0		; Buffer for tlos or tos
	 ENDIF
;
TLOS2:	DB	'] ',0
;
;-----
;
; DEC8 will convert an 8-bit binary number in a to three ASCII bytes.
; HL points to the MSB location where the ASCII bytes will be stored.
; Leading zeros are suppressed.
;
DEC8:	PUSH	PSW
	PUSH	H
	XRA	A
	MOV	M,A		; Clear destination
	INX	H
	MOV	M,A
	INX	H
	MOV	M,A
	POP	H
	POP	PSW
	PUSH	B
	PUSH	D
	MVI	E,0		; Leading zero flag
	MVI	D,100
;
DEC81:	MVI	C,'0'-1
;JDEB¦©d’”¤’†¦ª„ˆv@b``@Þä@b`”œ†ˆŠ†pdv@¦èÒØØ@V‚ˆˆˆRHœÒì@ÂÈÉDÒè@ÄÂÆÖž¬„X‚v@¤ÊÚÂÒÜÈÊäšž¬‚X†v@ŽÊè@b``^b`† ’'1'		; Zero?
	JNC	DEC84		; Yes
	MOV	A,E		; Check flag
	ORA	A		; Reset?
	MOV	A,C		; Restore byte
	JZ	DEC85		; Leading zeros are skipped
;
DEC84:	MOV	M,A		; Store it in buffer pointed at by HL
	INX	H		; Increment storage location
	MVI	E,0FFH		; Set zero flag
;
DEC85:	MOV	A,D
	SUI	90		; 100 to 10
	MOV	D,A
	MOV	A,B		; Remainder
	JNC	DEC81		; Do it again
	ADI	'0'		; Make ASCII
	MOV	M,A		; And store it
	POP	D
	POP	B
	RET
	 ENDIF			; BYTLOS AND NOT BYCLOCK
;
;-----
;
; Default path used for path command-search
;
	 IF	INTPATH
PATH:	IPATH			; Macro defined up front
;
	 IF	WHEEL
WHLPTH:	DB	0,SYSUSR	; Filled dynamically based on wheel byte
	 ENDIF
;
	DB	0		; Terminating 0 for last pair
	 ENDIF
;
; Stack area
;
	 IF	INTSTACK	; Internal stack
	DS	48		; Stack area
;
STACK	EQU	$		; Top of stack
	 ENDIF
;
; The following will cause an error message to appear if the size of
; ZCMD2 is over 2k bytes.
;
	 IF	NOT MAKESPR
	 IF	($ GT CCPLOC+800H)
ZCMDER1	EQU	NOVALU1		;    *** WARNING ***
ZCMDER2	EQU	NOVALU2		; ZCMD2 is larger than 2k
	 ENDIF
	 ENDIF
;
	END
