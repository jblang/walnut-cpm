
; ED409.ASM		ED409.ASM dated 1984 September

; This file is an overlay to EDFILE.COM which provides modifications.
; Since EDFILE is a particularly popular public domain program and
; since more fixes and modifications are sure to follow, this patch
; will be referred to by its date...4 for 1984 and 09 for September.

; This patch by Clint Lew
; South Bay Technical Support Group RCP/M (213) 970-9238

; This patch corrects two small bugs in the current version.
; The first bug limited the size of the file to which direct jumps
; could be made.  In the original version, for files greater than 
; about 8000H, the "dump relative address" or "A" command would not
; consistently jump directly to all addresses. (Actually the address
; jump limit was dependent upon the file size).
; The second bug was a minor problem in that a jump to an address
; which happened to be on a sector boundary would send you to the
; block before the desired block.



	ORG	0528H
	PUSH	H	;selected address
	LHLD	27C3H	;address offset
	CALL	2A3AH	;subtract offset from address
	LXI	D,7
	CALL	29DCH	;divide by 128 to get record number
	XCHG
	LHLD	27BCH	;LOF record number
	XCHG
	MOV	A,D
	CMP	H	;compare most significant byte
	JC	0357H	;selected record greater than LOF
	JNZ	NEWREC	;less than LOF
	MOV	A,E
	CMP	L	;compare least significant byte
	JZ	0357H	;selected record equals LOF
	JC	0357H	;greater than LOF record
NEWREC:	SHLD	27CAH	;store valid record number
	JMP	0562H	;continue
	END


;*************************************************************
;    General usage instructions for using ASM overlays 
;*************************************************************

;               I N S T R U C T I O N S
;
;
; First, edit this file to your preferences using any editor.
; Wordstar in non-document mode works very well for this.
;
; Second, assemble this file using Digital Research's CP/M
; assembler ASM.COM.  For the file ED409.ASM,  enter ASM ED409.
;
; Lastly, use DDT to overlay the results of this EDOVR program 
; onto EDFILE.COM.  The procedure for this overlay follows:
;
;		A>DDT EDFILE.COM
;		DDT VERS 2.2
;		NEXT  PC
;		2C00 0100		(size varies with version)
;		-IED409.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		2C80 0000
;		-G0			(return to CP/M)
;		A>SAVE 44 EDFILE.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
