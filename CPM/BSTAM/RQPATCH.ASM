;
; 	RQPATCH.ASM as of 4/1/80
;	by Keith Petersen, W8SDZ
;
; This file will generate patches for BSTAM RECEIVE.COM ver 4.3
; to make it totally silent so it can be used on a remote
; CP/M system.
;
	ORG	0103H	;DISABLE INITIALIZATION
	RET ! NOP ! NOP
;
	ORG	0350H
	DB	0DH,0AH,'BSTAM rev 4.3 Receive'
	DB	0DH,0AH,'READY'
	DB	0DH,0AH,'$'

	ORG	03A6H
	NOP ! NOP ! NOP
;
	ORG	03DBH
	NOP ! NOP ! NOP
;
	ORG	045FH
	NOP ! NOP ! NOP
;
	ORG	049FH
	NOP ! NOP ! NOP
;
	ORG	04CFH
	NOP ! NOP ! NOP
;
	ORG	0505H
	NOP ! NOP ! NOP
;
	ORG	056AH
	NOP ! NOP ! NOP
;
	ORG	05BEH
	NOP ! NOP ! NOP
;
	ORG	08DBH
	NOP ! NOP ! NOP
;
	ORG	0908H
	NOP ! NOP ! NOP
;
	ORG	0936H
	NOP ! NOP ! NOP
;
	ORG	0960H
	NOP ! NOP ! NOP
;
	ORG	0990H
	NOP ! NOP ! NOP
;
	ORG	09BFH
	NOP ! NOP ! NOP
;
	ORG	09EFH
	NOP ! NOP ! NOP
;
	ORG	0A1AH
	NOP ! NOP ! NOP
;
	ORG	0A2BH	;CONREADY CALL
	XRA A ! NOP ! NOP
;
	ORG	0A32H	;CONIN CALL
	XRA A ! NOP ! NOP
;
	ORG	0A71H
	NOP ! NOP ! NOP
;
	ORG	0D53H
	NOP ! NOP ! NOP
;
	ORG	0DA5H
	NOP ! NOP ! NOP
;
	ORG	0E42H
	NOP ! NOP ! NOP
;
	ORG	0E9EH
	NOP ! NOP ! NOP
;
	ORG	0FBEH
	NOP ! NOP ! NOP
;
	ORG	104DH
	NOP ! NOP ! NOP
;
	ORG	10B0H
	NOP ! NOP ! NOP
;
	ORG	1127H
	NOP ! NOP ! NOP
;
	ORG	1190H
	NOP ! NOP ! NOP
;
	ORG	1208H
	NOP ! NOP ! NOP
;
	ORG	123BH
	NOP ! NOP ! NOP
;
	ORG	12D9H
	NOP ! NOP ! NOP
;
	ORG	130EH
	NOP ! NOP ! NOP
;
	END
