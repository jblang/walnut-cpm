
; M7NM-6.ASM  Telephone number overlay file for MDM7xx - 02/11/84
;
; NOTE: Not for use with MDM7xx programs prior to MDM722.
;
; This file can be edited to make a new library of telephone numbers.
; Each entry must be 34 bytes long.  36 (A-Z and 0-9) telephone numbers
; are allowed.	Follow the format for the library entries already in the
; file.  (Be sure to use spaces, not tabs.)
;
; At least 1 period (.) must precede each phone number in the table.
;
; Room has been left if your phone system requires extra characters such
; as:  1-313-846-6127 rather than the 313-846-6127 used in some areas.
;
; This number list is of value even to those not using the PMMI auto-
; dialing system.  If "NUM" is typed while in the command mode, it will
; show the list of stored numbers you can manually dial.  (If the PMMI
; board is used, type "CAL" to initiate an auto-dialed call.  This also
; lists the telephone numbers but in a slightly different format.) "NUM"
; does not work for PMMI, and "CAL" does not work for non-PMMI.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use 'DDT' to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4800 0100
;		-IM7NM-6.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4800 0000
;		-G0			(return to CP/M)
;		A>SAVE 71 MDM7xx.COM	(now have a modified .COM file)
;
;
; NOTE: For those revising the main program, check the location of
;	   NUMBLIB to see if the ORG value used here is correct.  If
;	   not, change as needed.
;
;=======================================================================
;
; 02/04/84 - Updated for use with MDM722	- Bill Brehm
; 01/23/84 - Updated for use with MDM720	- Irv Hoff
; 01/22/84 - Updated for use with MDM719	- Keith Petersen
; 01/21/84 - Updated for use with MDM718	- Irv Hoff
; 01/12/84 - Updated for use with MDM717	- Steve Sanders
; 11/11/83 - Renamed to M7NM-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Updated for use with MDM712	- Irv Hoff
;	     Added 'MCI' and/or 'SPRINT'
;
;=======================================================================
;
;
YES:	EQU	0FFH
NO:	EQU	0
;
;
SHOWHEX:EQU	NO	;YES shows both HEX and DECIMAL on record count
;			;NO shows decimal count only (normally adequate)
XFRSIZ:	EQU	4	;file transfer buffer in Kbytes.  Do not make
			;any larger than BUFSIZ.  16k works fine on all
			;but slower systems.
;
;
	ORG	0E00H-50  ;so 'NUMLIB' starts on even page
;
;
;=======================================================================
;
; Long distance alternate dialing such as MCI, SPRINT, etc.  Must end
; with a '$', use as many commas (2 seconds delay, each) as needed to
; let the alternate dialing code return with a new dial tone.  Fill in
; any character (periods are fine) after the $ to keep number of columns
; to 24, i.e.,	'1234567,,,,12345,,$.....'   --   the first group is the
; MCI or SPRINT access number, the second group is the user number.  A
; small delay is usually required after the billing number also.
;
ALTDIAL1:DB	'xxxxxxx,,,,,,xxxxxxxx,,$'   ;accessed by a < character
;
ALTDIAL2:DB	'xxxxxxx,,,,,,xxxxxxxx,,$'   ;accessed by a > character
;
;=======================================================================
;
HEXSHOW:DB	SHOWHEX		;can easily change SHOWHEX via DDT
;
SAVSIZ:	DB	XFRSIZ*8	;can easily change buffer size for file
				;transfers with DDT for "NUMBLIB-1" ad-
				;dress.  Normally 4k (32 records or 4k).
;
;=======================================================================
;
; Phone number library table for auto-dialing.	Each number must be as
; long as"LIBLEN" (EQU at start of program).  Some areas require extra
; characters such as:	1-313-846-7127.  Room is left for those.  Use
; a (<) for alternate dialing system #1, and a (>) for alternate dialing
; System #2.  Either would preceed the actual number, for example:
;
;	DB    'A=Alan Alda..........<123-456-7890'    ;'A'
;
; -	-     -     -	  -	-     -     -	  -	-     -     -
;
; NOTE: At least one dot (.) MUST precede the actual phone number
;
;		'----5---10---15---20---25---30--34'
NUMBLIB:DB	'A=Bob Robesky.......1-209-227-2083'	;'A'
	DB	'B=Byron McKay.......1-415-965-4097'	;'B'
	DB	'C=Bruce Jorgens.....1-509-255-6324'	;'C'
	DB	'D=Phil Cary.........1-505-522-8856'	;'D'
	DB	'E=Bill Earnest......1-215-398-3937'	;'E'
	DB	'F=Chuck Forsberg....1-503-621-3193'	;'F'
	DB	'G=Ron Fowler........1-414-563-9932'	;'G'
	DB	'H=Charlie Hoffman...1-813-831-7276'    ;'H'
	DB	'I=Jack Kinn.........1-817-547-8890'	;'I'
	DB	'J=Walt Jung.........1-301-661-2175'	;'J'
	DB	'K=Sigi Kluger.......1-915-598-1668'	;'K'
	DB	'L=Thomas Loker......1-301-863-7165'	;'L'
	DB	'M=Wayne Masters.....1-408-378-7474'	;'M'
	DB	'N=Dick Mead.........1-213-799-1632'	;'N'
	DB	'O=Al Mehr...........1-408-238-9621'    ;'O'
	DB	'P=Pasadena RBBS.....1-213-577-9947'	;'P'
	DB	'Q=Mark Pulver.......1-312-789-0499'	;'Q'
	DB	'R=Bruce Ratoff......1-201-272-1874'	;'R'
	DB	'S=Ken Stritzel......1-201-584-9227'	;'S'
	DB	'T=TCBBS, Dearborn...1-313-846-6127'	;'T'
	DB	'U=AnaHUG RCPM.......1-714-774-7860'	;'U'
	DB	'V=Dave Austin.......1-707-257-6502'	;'V'
	DB	'W=Paul Bagdonovich..1-201-747-7301'	;'W'
	DB	'X=Kirk De Haan......1-408-296-5078'	;'X'
	DB	'Y=Byron Kantor......1-619-273-4354'	;'Y'
	DB	'Z=Chuck Metz........1-408-354-5934'	;'Z'
	DB	'0=Bill Parrott......1-913-682-3328'    ;'0'
	DB	'1=Larry Snyder......1-305-671-2330'	;'1'
	DB	'2=Alex Soya.........1-305-676-3573'	;'2'
	DB	'3=Tony Stanley......1-912-929-8728'	;'3'
	DB	'4=Ed Svoboda........1-408-732-9190'	;'4'
	DB	'5=Tampa Bay Bandit..1-813-937-3608'	;'5'
	DB	'6=Thousand Oaks.....1-805-492-5472'	;'6'
	DB	'7=Bill Wood.........1-619-256-3914'	;'7'
	DB	'8=Spare.............x-xxx-xxx-xxxx'	;'8'
	DB	'9=Spare.............x-xxx-xxx-xxxx'	;'9'
	DB	0					;end
;		'----5---10---15---20---25---30--34'
;.....
;
	  END
