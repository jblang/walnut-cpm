
	* * * *	* * * *	* * * *	* * * *	* * * *	* * * *	* *
	*						  *
	*		   EDRIVE.ASM			  *
	*						  *
	*	   TERRY HAZEN,	 LOS GATOS, CA		  *
	*						  *
	*	  ADAPTED FROM MULTIDSK	VER 2.2		  *
	*  COPYRIGHT (C) 1984,1985 AMPRO COMPUTERS, INC.  *
	*						  *
	* * * *	* * * *	* * * *	* * * *	* * * *	* * * *	* *



; revision log:
;
;	8/18/85 Release Ver 2.0 (Adapted from MULTIDSK Ver 2.2)
;		Added support for command line specification of an
;		alternate drive to be used for the "E" drive.
;
;		(FOR BIOS VERSIONS GREATER THAN 3.0:
;		Added support for reading a 48tpi format in a 96tpi
;		drive, also for its commmand line specification.)
;
;
;	8/06/85 Release Ver 1.0 (Adapted from MULTIDSK Ver 1.0)
;
;-----------------------------------------------------------------------
;
; EDRIVE allows the "E" drive of the AMPRO series 100 computers to read
; and write a user-defined foreign 48tpi or 96tpi disk format.
;
; EDRIVE is most useful for formats which are not included in MULTIDSK
; and are used often enough to make the use of ESET awkward, or for
; MULTIDSK formats when the smaller size and faster operation of EDRIVE
; are assets.
;
; EDRIVE changes the TYPE byte, DPB, drive, and the skew table in the
; BIOS.  A total of 37 bytes are used (1 for TYPE byte, 15 for DPB,
; 1 for drive selected, 20 for skew table):
;
;	The FTYPE byte identifies the format as 48tpi or 96tpi.
;
;	The EDRIVE byte defines which drive will be used as the "E"
;	drive (A, B, C, or D).
;
;	The ETYPE byte defines whether you are reading a 48tpi format on
;	a 48tpi drive or a 96tpi drive.
;
;	The TYPE byte is a single byte which defines the particulars of
;	the foreign disk format:
;
;		bit 7......density: 0=single; 1=double
;		bit 6......double sided media if = 1
;		bit 5......double sided mode:
;				1 = continuous sector numbers (first
;				    sector on side one = last sector
;				    on side 0 + 1).
;				    both tracks are treated as a
;				    single track with twice as many
;				    sectors.
;				0 = same sectors on both sides
;				    (normal method)
;		bit 4......reserved
;		bits 3-2...00 = 1k allocation blocks
;			   01 = 2k allocation blocks
;			   10 = not used
;			   11 = not used
;		bits 1-0...00 = 128 byte sectors
;			   01 = 256 byte sectors
;			   10 = 512 byte sectors
;			   11 = 1024 byte sectors
;
;	The DPB (disk parameter block) is the standard Digital Research
;	DBP and can be learned by studying the CP/M 2 Alteration Guide
;	as supplied by Digital Research.  The disk parameter block tells
;	the system about how the data is arranged on the disk.	The DPB
;	has ten entries:
;
;		SPT	Sectors Per Track		(word)
;		BSH	Block SHift			(byte)
;		BLM	BLock Mask			(byte)
;		EXM	EXtent Mask			(byte)
;		DSM	Directory Size Minus one	(word)
;		DRM	DiRictory entries Minus one	(word)
;		AL0	directory group ALlocation 0	(byte)
;		AL1	directory group ALlocation 1	(byte)
;		CKS	ChecK Size			(word)
;		OFF	OFFset (# of system tracks)	(word)
;
;		(You may obtain the DPB and skew table information for
;		a foreign format by running DSKPRAM on that format.)
;
;	The drive byte defines the drive being used as the "E" drive.
;	It is changed by EDRIVE and is not user-entered data.
;
;	The skew table translates between logical and physical sector
;	numbers.  On some systems the sectors are not contiguously
;	arranged in order to improve access times.
;
;-----------------------------------------------------------------------
;
; Customizing EDRIVE for your foreign format:
;
;	Put the type of format you will use (48tpi or 96tpi) at FTYPE,
;	the drive you wish to use as the default "E" drive at EDRIVE,
;	the type of drive (48tpi or 96tpi) at ETYPE, your foreign format
;	type byte, DPB, and skew table at FORMAT, the name of your
;	foreign format in the message at SIGNOFF, and assemble.
;
;-----------------------------------------------------------------------
;
; Using EDRIVE:
;
;	In normal use, the format and drive selections you entered in
;	EDRIVE.ASM will be used as your "E" drive when the program
;	is run.  EDRIVE may be run from any drive except "E".  EDRIVE
;	may also be combined with other commands in a multiple ZCPR
;	command line in the normal manner:
;
;			A>edrive b4;dir e:
;
;
; Modifying Drive and Drive Type Selections on the Command Line:
;
;	You may also change the "E" drive and drive type selections by
;	placing the new drive letter and type on the command line
;	following the program name:
;
;	96tpi Formats:
;
;		Since a 96tpi format must be read in a 96tpi drive, only
;		the new drive letter (which must be a 96tpi drive)
;		needs to be specified on the command line:
;
;			A>edrive b
;
;
;	48tpi Formats (BIOS version less than 3.0):
;
;		BIOS versions less than 3.0 do not directly support
;		reading a 48tpi format in a 96tpi drive, so only the new
;		drive letter (which must be a 48tpi drive) needs to be
;		specified on the command line:
;
;			A>edrive c
;
;		(IF YOUR BIOS VERSION IS LESS THAN 3.0, and you want to
;		read a 48tpi format in a 96tpi drive, you must run
;		48TPI.COM prior to running EDRIVE.  48TPI makes your
;		96tpi "E" drive look like a 48tpi drive, with some
;		limitations.  See 48TPI.DOC)
;
;
;	48tpi Formats (BIOS versions 3.0 or greater):
;
;		EDRIVE supports READING your 48tpi format in a 96tpi
;		drive (writing a 48tpi format on a 96tpi drive is NOT
;		recommended.)
;
;		To modify your default "E" drive selection, add the new
;		drive letter to the command line following the program
;		name.  If the drive type of your new "E" drive is
;		different than the default type, add the number for the
;		new drive type after the drive letter (4 for 48tpi or
;		9 for 96tpi):
;
;		Examples:
;
;		If your default "E" drive is the 48tpi drive 'B' and you
;		wanted to make the 48tpi drive 'C' the new "E" drive,
;		you would type:
;
;			A>edrive c	or	A>edrive c4
;
;		and if you wanted to make the 96tpi drive 'D' the new "E"
;		drive, you would type:
;
;			A>edrive d9
;
;
;		If your default "E" drive is the 96tpi drive 'D' and you
;		wanted to make the 48tpi drive 'C' the new "E" drive,
;		you would type:
;
;			A>edrive c4
;
;
;		The default value for ETYPE that you entered in EDRIVE.ASM
;		file will always be used unless you specify a different
;		value on the command line.
;
;		Whenever you specify a 48tpi format in a 96tpi drive,
;		EDRIVE will remind you in the sign-off message.
;
;-----------------------------------------------------------------------

CR:	EQU	0DH		; carrige return
LF:	EQU	0AH		; line feed
	;
BDOS:	EQU	5
	;
	ORG	0100H		; base of tpa
BEGIN:	JMP	START		; leave room for copyright and format data
	;
	DB	' EDRIVE Vers 2.0, adapted by Terry Hazen'
	DB	' from MULTIDSK Vers 2.2, Copyright (c) 1984,1985'
	DB	' AMPRO Computers, Inc. '
	DB	1AH
	;
;=======================================================================;
;									;
; USER-ENTERED FOREIGN FORMAT DATA:					;
; ---------------------------------					;
;									;
; The following table contains the type byte, dpb, drive selected,	;
; and skew for your foreign format, and the sign-off message.		;
;									;
; Enter your data here...						;
;									;
;-----------------------------------------------------------------------;;
;									;;
; The use of 96tpi drives to READ 48tpi formats is supported only	;;
; with Bios versions 3.0 and above.  If your BIOS version is less	;;
; than 3.0, ignore FTYPE and ETYPE:					;;
;									;;
FTYPE:	DB	'4'		; foreign format type:			;;
;				;	('4':  it's a 48tpi format)	;;
;				;	('9':  it's a 96tpi format)	;;
;									;;
EDRIVE:	DB	'B'		; drive selected as "E" drive:		;;
;				;	('A','B','C',or'D')		;;
;									;;
ETYPE:	DB	'4'		; type of drive:			;;
;				;    48tpi format:			;;
;				;	is the selected drive 48tpi or	;;
;				;	96tpi?				;;
;				;	('4':  it's a 48tpi drive)	;;
;				;	('9':  it's a 96tpi drive)	;;
;				;					;;
;				;    96tpi format:			;;
;				;	ETYPE will be ignored.		;;
;-----------------------------------------------------------------------;;
;									;;
FORMAT:									;;
;									;;
;type byte								;;
	DB	0C7H		; MORROW MD3 DSDD 48tpi format		;;
;									;;
;dpb									;;
	DW	40		; spt					;;
	DB	4		; block shift				;;
	DB	15		; block mask				;;
	DB	1		; extent mask				;;
	DW	0C2H		; disk size-1				;;
	DW	0BFH		; # of directories-1			;;
	DB	0E0H		; allocation 0				;;
	DB	0		; allocation 1				;;
	DW	48		; dir check size			;;
	DW	2		; reserved tracks			;;
;									;;
;drive									;;
	DB	1		; this byte is changed by EDRIVE	;;
;				;    and is not user-entered		;;
;									;;
;skew table - must contain 20 bytes total				;;
	DB	1,4,2,5,3						;;
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0				;;
;									;;
;-----------------------------------------------------------------------;;
;									;
;the sign-off message:							;
;									;
SIGNOFF:								;
	DB	CR,LF							;
	DB	'Drive A is now a '					;
;-----------------------------------------------------------------------;;
;									;;
;      ...Enter the name of your foreign format here:			;;
;									;;
	DB	'MORROW MD3 DSDD 48tpi'					;;
;									;;
;-----------------------------------------------------------------------;;
	DB	CR,LF							;
	DB	'drive when you call it "E".'				;
	DB	CR,LF,'$'						;
;-----------------------------------------------------------------------;
;									;
; END OF USER-ENTERED DATA AREA...					;
;									;
;=======================================================================;
	;
	;
START:	LXI	H,0		; zero out h&l
	DAD	SP		; add sp to hl
	SHLD	OLDSP		; save it
	LXI	SP,STACK	; set up new stack
	;
	;
	;ckdrv loads the default drive and compares it
	;against the e drive, which isn't allowed.  prints
	;error message if true.
	;
CKDRV:	LDA	4		; get default drive
	CPI	4		; is it drive "e"?
	JZ	WRGDRV		; get ready to quit if it is
	;
	LHLD	01H
	MVI	L,74H
	MOV	A,M
	ANI	3FH		; mask off D-speed & D-step
	MOV	M,A
	;
	;
	;eaddr gets the location of eparm in the bios.
	;
EADDR:	LHLD	1		; get warm boot vector
	MVI	L,36H		; get edsk offset
	LXI	D,BIORET	; point to bios return point
	PUSH	D		; save d
	PCHL			; return with dpb addr
	;
	;
	;bioret returns with the bios location of eparm
	;and saves it for use later.
	;
BIORET:	DCX	H		; back up to type byte location
	SHLD	ADDR		; save location
	;
	;interrogate the command line for any characters
	;
	LXI	H,80H
	MOV	A,M
	INX	H
	ORA	A
	JZ	BIOS$VER
	MOV	B,A
	LXI	D,EDRIVE
	MVI	C,2
	;
NEXTCHR:
	MOV	A,M
	DCR	B
	INX	H
	JM	BIOS$VER
	CPI	' '
	JZ	NEXTCHR
	STAX	D
	INX	D
	DCR	C
	JZ	BIOS$VER
	JMP	NEXTCHR
	;
BIOS$VER:
	MVI	A,0		; clear bios version
	STA	LB$VERS
	CALL	GET$BIOS$VERS	; get bios version
	JMP	MAIN
	;
	;
GET$BIOS$VERS:
; Get bios version -- Brings the current BIOS jump tables (starting
;     at warm boot) to a local area for ease of utility access.  If
;     this BIOS is version 2.1 or greater, the secondary jump table
;     is brought in as well.
;
; Entry: none
; Exit:  Z  = bios < 2.1 (old bios)
;	 NZ = bios 2.1+  (fixed disk bios)
;	 All registers are modified
;
	LHLD	1		; Get start of bios jump table
	LXI	D,LB$BIOS$TBL	; Move bios to local storage
	LXI	B,LB$LEN	; .  (length of bios area)
	DB	0EDH,0B0H	; .  (move routine)
	MVI	A,0		; Test CP/M version
	CALL	LB$GETNXT	; Get next jump table
	STA	LB$VERS		; Save bios version
	INX	H		; See if HL is 0FFFFh
	MOV	A,H		; .
	ORA	L		; .
	RZ			; If so, then old version
	DCX	H		; Fix HL as it has the table addr
	LXI	D,LB$XTBL	; Move extra table to local storage
	LXI	B,LB$XLEN	; .  (length of extra table)
	DB	0EDH,0B0H	; .  (move routine)
	MVI	A,0FFH		; Set NZ to indicate bios
	ORA	A		; ... version 2.1+
	RET			; ... and return.


; * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;							*
;		Data area . . . 			*
;							*
; * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
; Replicated BIOS for ease of use . . .
;
LB$BIOS$TBL:
LB$WBOOT:	DB	0,0,0	; Warm boot
LB$CONST:	DB	0,0,0	; Console status
LB$CONIN:	DB	0,0,0	; Console input
LB$CONOUT:	DB	0,0,0	; Console output
LB$LISTOUT:	DB	0,0,0	; List output
LB$PUNCH:	DB	0,0,0	; Punch output
LB$READER:	DB	0,0,0	; Reader input
LB$HOMDSK:	DB	0,0,0	; Home disk (move to track 00)
LB$SELDSK:	DB	0,0,0	; Select disk drive
LB$SETTRK:	DB	0,0,0	; Select track number
LB$SETSEC:	DB	0,0,0	; Select sector number
LB$SETDMA:	DB	0,0,0	; Set DMA address
LB$DSKREAD:	DB	0,0,0	; Disk read
LB$DSKWRITE:	DB	0,0,0	; Disk write
LB$LISTST:	DB	0,0,0	; List status
LB$SECTRN:	DB	0,0,0	; Sector translate routine
;
; AMPRO-specific BIOS calls
;
LB$GETNXT:	DB	0,0,0	; Get bios ver & next tbl address
LB$GETEDSK:	DB	0,0,0	; Get pointer to E-disk storage
LB$IOINIT:	DB	0,0,0	; Set new I/O parameters
LB$SCSIDRV:	DB	0,0,0	; SCSI direct driver
;
LB$LEN:	EQU	$-LB$WBOOT	; Length of bios table
;
LB$XTBL:
LB$SWAP$DRV:	DB	0,0,0	; Swap two logical drives
LB$WINDRV:	DB	0,0,0	; Set/get win drive parameters
LB$PHYTAB:	DB	0,0,0	; Set/get phytab access
LB$GET$LDTE:	DB	0,0,0	; Get physical table entry address
LB$RESERVED:	DB	0,0,0	; Reserved entry
;
LB$XLEN:EQU	$-LB$XTBL	; Length of extra table
;
LB$VERS:	DB	0
	;
	;
MAIN:	LDA	EDRIVE		; get drive back
	STA	SIGNOFF+8	; store it in sign-off message
	SUI	'A'		;
	STA	FORMAT+16	; store it
	LHLD	ADDR		; get bios pointer back
	MVI	B,37		; number of bytes to move (1+15+1+20)
	LXI	D,FORMAT	; point to new dpb
	CALL	LOOP		; put into memory
	JMP	DONE		; done
	;
	;
	;wrgdrv loads the wrong drive error message, prints
	;it and exits to zcpr3.
	;
WRGDRV:	LXI	D,ERROR		; load error message
	CALL	OUTPUT		; bdos
	;
DONE:	LHLD	OLDSP		; get stack back
	SPHL			; put it in sp
	RET			; return to zcpr3
	;
	;
	;loop moves the type byte, dpb, drive,and
	;skew table to the location in the bios pointed to
	;by the hl registers. the bytes to be moved are pointed
	;to by the de registers and b contains the number
	;of bytes to be moved.
	;
LOOP:	LDA	FTYPE
	CPI	'4'		; 48tpi format?
	JNZ	SIGN		; no, print sign-off message
	;
D4896:	LDA	ETYPE
	CPI	'9'		; 96tpi drive?
	JNZ	SIGN		; no, print sign-off message
	LDA	LB$VERS		; yes, so get bios version
	SUI	1EH		; bios version > 3.0?
	JP	SETDST		; yes, set double-step
	;
	LXI	D,WRGBIOS	; no, 48/96 not supported,
	CALL	OUTPUT		;    so print error msg and quit
	JMP	DONE
	;
SETDST:	PUSH	H
	LHLD	1
	MVI	L,74H
	MOV	A,M
	ORI	40H
	MOV	M,A
	;
	PUSH	B
	PUSH	D
	LXI	D,SIGNOFF	; point to sign-off message
	CALL	OUTPUT		; print it
	LXI	D,MSG4896	; point to 48/96 message
	CALL	OUTPUT		; print it
	POP	D
	POP	B
	;
	POP	H
	JMP	LOOP2
	;
SIGN:	PUSH	B
	PUSH	D
	PUSH	H
	LXI	D,SIGNOFF	; point to sign-off message
	CALL	OUTPUT		; print it
	POP	H
	POP	D
	POP	B
	;
LOOP2:	LDAX	D		; put 1st byte into a
	MOV	M,A		; store it in bios
	INX	D		; roll up d
	INX	H		; roll up h
	DCR	B		; decrement b
	JNZ	LOOP2		; loop until done
	RET
	;
	;
	;output sends the message pointed to by de to the screen.
	;
OUTPUT:	MVI	C,9		; print string function
	CALL	5		; bdos
	RET			;
	;
WRGBIOS:
	DB	7,CR,LF
	DB	'+++ Your BIOS is not version 3.0 or greater, so reading '
	DB	CR,LF
	DB	'a 48tpi format in a 96tpi drive is not supported.'
	DB	CR,LF,'$'
	;
ERROR:	DB	7,CR,LF
	DB	'+++ Wrong drive selected.'
	DB	CR,LF
	DB	'EDRIVE can only be run from drive A, B, C, or D.'
	DB	CR,LF,'$'
	;
MSG4896:
	DB	CR,LF
	DB	'This is a 48tpi format in a 96tpi drive:'
	DB	CR,LF
	DB	'- Writing to this drive is not recommended!'
	DB	CR,LF,'$'
	;
ADDR:	DS	2		; "e" drive parms addr
	;
	;
	;
	DS	64		; 32 level stack
STACK:
	;
OLDSP:	DS	2		; room for old stack pointer
	;
	;
	;
	END	BEGIN
