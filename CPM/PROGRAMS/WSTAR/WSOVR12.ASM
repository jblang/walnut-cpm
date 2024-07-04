;--------------------------------------------------------------------
; WSOVR.ASM    revision 1.2		Jim Lill	10/03/86
;
; Speed Up Patches for Wordstar 3.3
;
; WSOVR is a slightly different approach to Wordstar patching.	It
; uses ideas from WSFAST24 etc except it does not do the Kaypro,
; drive or printer patches.  It does allow patching back to the
; normal values and tailoring of individual values.  In particular
; DEL3 requires different values for different systems. On floppy
; or even rigid systems you might want to delay the help menus
; that you get after hitting a control key (eg ^K). On ramdisk or
; cache systems where the menus are virtually instantaneous and don't
; really slow down editing, you might want "instant help" so you'd
; set the time shorter. It uses the overlay approach via MLOAD
; rather than using DDT. Using it is straight forward....
;
;		- use WS to set values etc in this source
;		- ASM WSOVR
;		- MLOAD WS.COM=WS.COM,WSOVR (or whatever name you use)
;
; LEGAL notes......
;   this overlay will remove your serial number, replacing it with
; the words "Speed-Up Version" or "Normal Version".  Use it only
; on your own legal Wordstar. It is NOT intended to "deserialize"
; illegal copies!; (now optional on rev 1.1)
;
; References: WSFAST16.LBR
;	      WSFAST24.LBR
;	       WSPATCH.TBL
;	       WSBIBLE.DOC
;
; v 1.1 Tested on:  PCPI Applicard (Apple CP/M)
;
; rev 1.0
;   - created original file		--- Jim Lill  9/18/86
; rev 1.1
;   - made elimination of configuration info optional
;   - made s/n overwrite optional
;   - added file renaming (see patch area 5)
;   - added terminal esc seq. for faster edit. INSLIN etc.
; rev 1.2
;   - fixed missing ENDIF on LINSTR (oops!;)
;   - added ability to change default disc 
;   - added ability to change Configuration Block
;   - changed delay values to Hex
;--------------------------------------------------------------------
				;
YES	EQU	0FFH
NO	EQU	NOT YES
				;
				;
;================== START OF USER DEFINED VALUES ===================
				;
DEFDSK	EQU	01H		;set for default drive, A:= 01H
				;eliminates doing a reinstall
				;
PATCH	EQU	YES		;yes for speed-up version
				;no for normal version
				;doesn't patch s/n back in!
				;
NOSN:	EQU	YES		;yes = speed-up or normal in place of S/N
				;no = leave s/n alone
				;
RENAME	EQU	NO		;yes= change name of WS files
				;no= leave alone
				;
CONFIG	EQU	YES		;yes= change data in configuration block
				;     that shows at signon. See patch area 8
				;no= leave alone
				;
LINSTR	EQU    	NO		;yes to add line insert, line delete etc
				;no leave alone. See patch area 1 below...
				;NOT required for Apple (set to NO)
				;
				;Normal
				;Value	       Description
				;------------------------------------
DEL3	EQU	15H		; 19H	delay before help menus. 64 for floppy
				;	systems. 15 for Ramdisk systems
DEL4	EQU	00H		; 64H	time for msg displays, copyright etc.
DEL5	EQU	00H		; 09H	delay until screen refresh
DELCUS	EQU	01H		; 10H	delay after cursor positioning
DELMIS	EQU	01H		; 05H	delay after misc other functions
				;
NOPRO	EQU	YES		;bypass MicroPro opening screen
NOLEG	EQU	YES		;skip legalese
NOCON	EQU	NO		;skip legalese and configuration info
				;
;=== END OF USER DEFINED VALUES (except for filenames and term. seq) ===
				;
	ORG	0170H		;patch area 0
				;
IF PATCH AND NOSN		;sub for s/n
	DB	'Speed-Up Version '
ENDIF
				;
IF NOT PATCH AND NOSN
	DB	' Normal Version  '
ENDIF
				;
;----------------------------------------------------------------------
;    The following patch area contains space for you to add the sequences
; that your terminal requires for Erase to End of Line, Delete Line and
; Insert Line.	This patch is already part of WS that is supplied
; specifically for Apples.
;    The following information is from WSBIBLE.....
;
;LINDEL  257  DELETE LINE			^Y  ## 00 00 00 00 00 00
;		       <try 02,1B,52 on 83 KayPros to
;			get smoother scroll down, ^QW>
;LININS  25E  INSERT LINE			^N  ## 00 00 00 00 00 00 00 00
;		      <try 02,1B,45 on 83 KayPros to get
;		       smoother scroll up
;
; ## (above) leading data byte (DB) in a string which tells how
; many bytes of data follow.

IF LINSTR
					;
	ORG	0250H			;patch area 1
ERAEOL	DB	02H,1BH,54H,0,0		;string to erase to end of line
	ORG	0257H
LINDEL	DB	02H,1BH,52H,0,0		;string to delete line
	ORG	025EH
LININS	DB	02H,1BH,45H,0,0		;string to insert line
					;
ENDIF
;----------------------------------------------------------------------
	ORG	02B1H			;patch area 2
					;
IF PATCH
	DB	DEL3,DEL4,DEL5		;speed up
ENDIF
					;
IF NOT PATCH
	DB	25,64,09		;normal values
ENDIF
					;
;----------------------------------------------------------------------
	ORG	28EH			;patch area 3
					;
IF PATCH
	DB	DELCUS,DELMIS		;speed-up
ENDIF
					;
IF NOT PATCH
	DB	10,05			;normal values
ENDIF
					;
;-----------------------------------------------------------------------
	ORG	3CF1H			;patch area 4
IF NOPRO AND PATCH
	JMP	3CFDH			;no logo
ENDIF
					;
IF NOT PATCH
	DB	21H,0fH,41H		;make normal
ENDIF
;-----------------------------------------------------------------------
IF NOLEG AND PATCH
	ORG	3F1DH			;patch area 5A
	DB	00H			;only skip legal
ENDIF
					;
IF NOCON AND PATCH
	ORG	3D0FH			;patch area 5B
	JMP	3D27H			;skip legal and conf. info
ENDIF
					;
IF NOT PATCH
	ORG	3D0FH
	DB	21H,1CH,3FH		;make normal again
	ORG	3F1DH
	DB	20H
ENDIF
					;
;-------------------------------------------------------------------------
IF RENAME

	ORG	0400H			;patch area 6
	DB	0
	DB	'WS      COM'		;name of WS.COM
	DB	0
	DB	'WSMSGS  OVR'		;name of WSMSGS.OVR
	DB	0
	DB	'WSOVLY1 OVR'		;name of WSOVLY1.OVR
	DB	0
	DB	'MAILMRGEOVR'		;name of MAILMRGE.OVR
ENDIF
;------------------------------------------------------------------------
	ORG	02B9H			;patch area 7
	DB	DEFDSK			;this always gets patched
;------------------------------------------------------------------------
IF CONFIG		;
	  		;	 |<<center 34 characters on this line		
	ORG	018AH	;	 |			 patch area 8A
	DB	'           Apple  //e             '	;terminal id
	ORG	01AEH	;	 |			 patch area 8B
	DB	'         Standard Printer         '	;printer id
	ORG	01D2H	;    	 |			 patch area 8C
	DB	'    LST Device      No Protocol   '    ;printer protocol
	ORG	01F6H	;     	 |			 patch area 8D
	DB	'      Configured 3 Oct 1986       '	;port driver
			;	 |<<center line, maintain length 
ENDIF
					;
					;
	END.
