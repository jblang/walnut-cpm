;		KAYPRO LISTST BIOS PATCH
;			(KPPATCH.ASM)
;
;	The Kaypro IV has a bug in the BIOS function 14, LISTST.
; This bug causes the print buffer function in MDM7nn not to work
; properly. 
;	According to the DRI Alteration Guide, this function is
; supposed to return a value of 0FFH in register A if the printer
; is available, and 00 if it is busy. The Kaypro BIOS (which in
; turn calls the ROM) does not return the zero in A, but it does
; return with the zero FLAG set. This can be fixed by the BIOS
; patch which follows:
;
;
BIOS	EQU	0FA00H	; Beginning of BIOS jump vectors
LISTST	EQU	BIOS + 165H
;
BIOS14	EQU	BIOS + 3*14 + 3
;
	ORG	BIOS14	; Put jump to patch here
	JMP	PATCH
;
SPARE	EQU	BIOS - 18	; Hole for patch
;
	ORG	SPARE
PATCH:	CALL	LISTST	; Call the ROM
	RNZ		; OK except when zero
	XRA	A	; Clear accumulator
	RET		; And return
	END
;
;
; 	Since the bug is in the BIOS, the patch requires
; generating a new version and placing it in the system
; tracks of your disk. To accomplish this, take the
; following steps:
;
; (1) Assemble the code above using ASM or MAC. The
; output will be KPPATCH.HEX. Note that this file has all
; text commented out, so it should assemble without
; editing.
;
; (2) Use SYSGEN to get a copy of CP/M in memory.
; To do this, insert a disk containing both SYSGEN
; and DDT into drive A. Then type:
;
;	SYSGEN
;
; When SYSGEN prompts with
;
; SOURCE DRIVE NAME (OR RETURN TO SKIP),
;
; respond with an  A. This will cause SYSGEN to
; generate a copy of the system tracks in low RAM.
;
; (3) When SYSGEN prompts for the destination drive,
; answer with a RETURN to reboot. The CP/M copy will
; remain in RAM.
; 
; (4) Save the copy of CP/M to disk by typing:
;
;	SAVE 36 CPM.COM
;
; (5) Type the following commands exactly as they
; appear:
;
;	DDT CPM.COM
;	IKPPATCH.HEX
;	R2580
;
; This causes DDT to load CPM.COM, then overlay it
; with the patches. The "2580" is the offset required
; to compensate for the fact that we are using a copy
; moved to low RAM. Just to be sure, type:
;
;	L1FAD
; and
;	L1F65
;
; You should see JMP F9EE at the first address, and
; the short subroutine at the second.
;
; (6) Exit DDT with G0 (that's a zero!) or ^C.
; The patched copy will remain in RAM.
;
; (7) Now run SYSGEN again. This time, respond to the
; first prompt with a RETURN (the system is already
; in RAM). At the second prompt, you can either respond
; with an "A", which will load the system onto the
; system tracks of the same disk, or "B" to load it onto
; any disk you desire to put in drive B.
;
; Note that you can continue to write the patched system
; onto as many disks as you like, simply by responding
; to the prompt appropriately. DO NOT type ^C when you
; insert a new disk!
;
; Note also that you can do this for existing disks. The
; contents of the directory or files on the disk will not
; be affected. Obviously, you might want to try this with
; a test disk, to make sure you get it right, before
; inserting the one with your PhD dissertation on it.
;
; If you experience any difficulties, please send me
; EMAIL at 72325,1327.
;
; Jack Crenshaw
