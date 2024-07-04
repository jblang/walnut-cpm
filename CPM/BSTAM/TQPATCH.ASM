;
; 	TQPATCH.ASM as of 4/1/80
;	by Keith Petersen, W8SDZ
;
; This file will generate patches for BSTAM TRANSMIT.COM ver 4.3
; to make it totally silent so it can be used on a remote
; CP/M system.
;
	ORG	0103H	;DISABLE INITIALIZATION
	RET ! NOP ! NOP
;
	ORG	0350H
	DB	0DH,0AH,'BSTAM rev 4.3 Transmit'
	DB	0DH,0AH,'READY'
	DB	0DH,0AH,'$'

	ORG	03A7H
	NOP ! NOP ! NOP
;
	ORG	03DDH
	NOP ! NOP ! NOP
;
	ORG	0508H
	NOP ! NOP ! NOP
;
	ORG	07E6H
	NOP ! NOP ! NOP
;
	ORG	0813H
	NOP ! NOP ! NOP
;
	ORG	0841H
	NOP ! NOP ! NOP
;
	ORG	086BH
	NOP ! NOP ! NOP
;
	ORG	089BH
	NOP ! NOP ! NOP
;
	ORG	08CAH
	NOP ! NOP ! NOP
;
	ORG	08FAH
	NOP ! NOP ! NOP
;
	ORG	0925H
	NOP ! NOP ! NOP
;
	ORG	0936H	;CONREADY CALL
	XRA A ! NOP ! NOP
;
	ORG	093DH	;CONIN CALL
	XRA A ! NOP ! NOP
;
	ORG	097CH
	NOP ! NOP ! NOP
;
	ORG	0CB1H
	NOP ! NOP ! NOP
;
	ORG	0CF8H
	NOP ! NOP ! NOP
;
	ORG	0D8AH
	NOP ! NOP ! NOP
;
	ORG	0DB1H
	NOP ! NOP ! NOP
;
	ORG	0E5FH
	NOP ! NOP ! NOP
;
	ORG	0ED8H
	NOP ! NOP ! NOP
;
	ORG	0FC1H
	NOP ! NOP ! NOP
;
	ORG	1090H
	NOP ! NOP ! NOP
;
	ORG	111BH
	NOP ! NOP ! NOP
;
	ORG	1153H
	NOP ! NOP ! NOP
;
	ORG	11CFH
	NOP ! NOP ! NOP
;
	ORG	1225H
	NOP ! NOP ! NOP
;
	ORG	126FH
	NOP ! NOP ! NOP
;
	ORG	12A4H
	NOP ! NOP ! NOP
;
	END
