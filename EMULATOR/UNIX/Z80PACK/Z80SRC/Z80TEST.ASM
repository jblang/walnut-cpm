;       Testprogramm fuer Z80-Assembler und Z80-Simulator
;
;       Copyright (C) 1989 by Udo Munk
;
	JR      $JR01           ;JR-Befehle testen
	HALT
$JR01:  SCF
	JR      C,$JR02
	HALT
$JR02:  CCF
	JR      NC,$JR03
	HALT
$JR03:  XOR     A
	JR      Z,$JR04
	HALT
$JR04:  INC     A
	JR      NZ,$JR05
	HALT
$JR05:  LD      B,0
	XOR     A
$JR06:
	INC     A
	DJNZ    $JR06
	JR      Z,$JR07
	HALT
$JR07:
	OR      A
	JR      Z,$JR08
	HALT
$JR08:
$NEXT01:                        ;JP-Befehle testen
	JP      $JP01
	HALT
$JP01:  LD      HL,$JP02
	JP      (HL)
	HALT
$JP02:  LD      IX,$JP03
	JP      (IX)
	HALT
$JP03:  LD      IY,$JP04
	JP      (IY)
	HALT
$JP04:  SCF
	JP      C,$JP05
	HALT
$JP05:  CCF
	JP      NC,$JP06
	HALT
$JP06:  XOR     A
	JP      Z,$JP07
	HALT
$JP07:  INC     A
	JP      NZ,$JP08
	HALT
$JP08:  JP      PO,$JP09
	HALT
$JP09:  INC     A
	INC     A
	AND     3
	JP      PE,$JP10
	HALT
$JP10:  JP      P,$JP11
	HALT
$JP11:  SUB     8
	JP      M,$JP12
	HALT
$JP12:
$NEXT02:                        ;CALL und RET-Befehle testen
	LD      SP,STACK
	CALL    UP1
	HALT
	SCF
	CALL    C,UP2
	HALT
	CCF
	CALL    NC,UP3
	HALT
	XOR     A
	CALL    Z,UP4
	HALT
	INC     A
	CALL    NZ,UP5
	HALT
	CALL    PO,UP6
	HALT
	INC     A
	INC     A
	AND     3
	CALL    PE,UP7
	HALT
	CALL    P,UP8
	HALT
	SUB     8
	CALL    M,UP9
	HALT
$NEXT03:                         ;8-Bit Ladebefehle testen
	LD      A,10
	LD      B,A
	LD      C,B
	LD      D,C
	LD      E,D
	LD      H,E
	LD      L,H
	SUB     L
	JR      Z,$LD01
	HALT
$LD01:  LD      A,B
	CP      10
	JR      Z,$LD02
	HALT
$LD02:  LD      A,C
	CP      10
	JR      Z,$LD03
	HALT
$LD03:  LD      A,D
	CP      10
	JR      Z,$LD04
	HALT
$LD04:  LD      A,E
	CP      10
	JR      Z,$LD05
	HALT
$LD05:  LD      A,H
	CP      10
	JR      Z,$LD06
	HALT
$LD06:  LD      A,L
	CP      10
	JR      Z,$LD07
	HALT
$LD07:  LD      BC,BYTE1
	LD      DE,BYTE2
	LD      HL,BYTE3
	LD      A,1
	LD      (BC),A
	INC     A
	LD      (DE),A
	INC     A
	LD      (HL),A
	LD      A,(BC)
	LD      B,A
	LD      A,(DE)
	LD      C,A
	LD      A,(HL)
	ADD     A,B
	ADD     A,C
	CP      6
	JR      Z,$LD08
	HALT
$LD08:  LD      A,1
	LD      B,2
	LD      C,3
	LD      D,4
	LD      E,5
	LD      H,6
	LD      L,7
	ADD     A,B
	ADD     A,C
	ADD     A,D
	ADD     A,E
	ADD     A,H
	ADD     A,L
	CP      28
	JR      Z,$LD09
	HALT
$LD09:  LD      HL,BYTE3
	LD      A,(HL)
	CP      3
	JR      Z,$LD10
	HALT
$LD10:  LD      B,(HL)
	CP      B
	JR      Z,$LD11
	HALT
$LD11:  LD      C,(HL)
	CP      C
	JR      Z,$LD12
	HALT
$LD12:  LD      D,(HL)
	CP      D
	JR      Z,$LD13
	HALT
$LD13:  LD      E,(HL)
	CP      E
	JR      Z,$LD14
	HALT
$LD14:  LD      H,(HL)
	CP      H
	JR      Z,$LD15
	HALT
$LD15:  LD      HL,BYTE3
	LD      L,(HL)
	CP      L
	JR      Z,$LD16
	HALT
$LD16:  LD      A,0D3H
	LD      (BYTE1),A
	XOR     A
	LD      A,(BYTE1)
	CP      0D3H
	JR      Z,$LD17
	HALT
$LD17:  LD      IX,TAB1
	LD      B,TAB1_END-TAB1
	LD      C,0
$LD18:  LD      A,(IX+0)
	CP      C
	JR      Z,$LD19
	HALT
$LD19:  INC     C
	INC     IX
	DJNZ    $LD18
$LD20:  LD      IY,TAB1
	LD      B,TAB1_END-TAB1
	LD      C,0
$LD21:  LD      A,(IY+0)
	CP      C
	JR      Z,$LD22
	HALT
$LD22:  INC     C
	INC     IY
	DJNZ    $LD21
$LD23:  LD      IX,TAB1_END
	LD      B,TAB1_END-TAB1
	LD      A,(TAB1_END-1)
	LD      C,A
$LD24:  LD      A,(IX+-1)
	CP      C
	JR      Z,$LD25
	HALT
$LD25:  DEC     C
	DEC     IX
	DJNZ    $LD24
$LD26:  LD      IY,TAB1_END
	LD      B,TAB1_END-TAB1
	LD      A,(TAB1_END-1)
	LD      C,A
$LD27:  LD      A,(IY+-1)
	CP      C
	JR      Z,$LD28
	HALT
$LD28:  DEC     C
	DEC     IY
	DJNZ    $LD27
$LD29:  LD      HL,1234H
	PUSH    HL
	LD      IX,WORD1
	LD      (IX+0),L
	LD      (IX+1),H
	LD      DE,(WORD1)
	OR      A
	SBC     HL,DE
	JR      Z,$LD30
	HALT
$LD30:  LD      C,(IX+0)
	LD      B,(IX+1)
	POP     HL
	OR      A
	SBC     HL,BC
	JR      Z,$LD31
	HALT
$LD31:
$NEXT04:                        ;16-Bit Ladebefehle testen
	LD      BC,1234H
	LD      (WORD1),BC
	LD      HL,(WORD1)
	OR      A
	SBC     HL,BC
	JR      Z,$LDW01
	HALT
$LDW01: LD      DE,4321H
	LD      (WORD1),DE
	LD      HL,(WORD1)
	OR      A
	SBC     HL,DE
	JR      Z,$LDW02
	HALT
$LDW02: LD      HL,5678H
	LD      (WORD1),HL
	LD      BC,(WORD1)
	OR      A
	SBC     HL,BC
	JR      Z,$LDW03
	HALT
$LDW03: LD      IX,3456H
	PUSH    IX
	POP     DE
	LD      (WORD1),IX
	LD      IY,(WORD1)
	PUSH    IY
	POP     HL
	OR      A
	SBC     HL,DE
	JR      Z,$LDW04
	HALT
$LDW04: LD      IY,4567H
	PUSH    IY
	POP     BC
	LD      (WORD1),IY
	LD      IX,(WORD1)
	PUSH    IX
	POP     HL
	OR      A
	SBC     HL,BC
	JR      Z,$LDW05
	HALT
$LDW05: LD      (WORD1),SP
	LD      HL,(WORD1)
	LD      DE,STACK
	OR      A
	SBC     HL,DE
	JR      Z,$LDW06
	HALT
$LDW06: LD      BC,1122H
	PUSH    BC
	LD      HL,$LDW07
	EX      (SP),HL
	RET
	HALT
$LDW07: LD      BC,1122H
	OR      A
	SBC     HL,BC
	JR      Z,$LDW07A
	HALT
$LDW07A:
	PUSH    BC
	LD      IX,$LDW08
	EX      (SP),IX
	RET
	HALT
$LDW08: LD      BC,1122H
	PUSH    IX
	POP     HL
	OR      A
	SBC     HL,BC
	JR      Z,$LDW08A
	HALT
$LDW08A:
	PUSH    BC
	LD      IY,$LDW09
	EX      (SP),IY
	RET
	HALT
$LDW09: LD      BC,1122H
	PUSH    IY
	POP     HL
	OR      A
	SBC     HL,BC
	JR      Z,$LDW09A
	HALT
$LDW09A:
$NEXT05:                        ;8-Bit Arithmetik testen
	LD      A,20H
	LD      B,20H
	ADD     A,B
	JR      NC,$AR01
	HALT
$AR01:  JR      NZ,$AR02
	HALT
$AR02:  JP      P,$AR03
	HALT
$AR03:  JP      PO,$AR04
	HALT
$AR04:  OR      A
	ADC     A,B
	ADC     A,B
	JR      NC,$AR05
	HALT
$AR05:  JR      NZ,$AR06
	HALT
$AR06:  JP      M,$AR07
	HALT
$AR07:  JP      PE,$AR08
	HALT
$AR08:  ADC     A,B
	JR      NC,$AR09
	HALT
$AR09:  JR      NZ,$AR10
	HALT
$AR10:  JP      M,$AR11
	HALT
$AR11:  JP      PO,$AR12
	HALT
$AR12:  LD      B,60H
	ADD     A,B
	JR      C,$AR13
	HALT
$AR13:  JR      Z,$AR14
	HALT
$AR14:  JP      P,$AR15
	HALT
$AR15:  JP      PO,$AR16
	HALT
$AR16:  LD      IX,BYTE1
	LD      (IX+0),0
	LD      B,10
$AR17:  INC     (IX+0)
	DJNZ    $AR17
	LD      A,(IX+0)
	CP      10
	JR      Z,$AR18
	HALT
$AR18:  LD      A,80H
	ADD     A,A
	JR      C,$AR19
	HALT
$AR19:  JR      Z,$AR20
	HALT
$AR20:
$NEXT06:                        ;16-Bit Arithmetik testen
	LD      SP,STACK-10
	LD      IX,0
	ADD     IX,SP
	LD      HL,0
	ADD     HL,SP
	PUSH    IX
	POP     BC
	OR      A
	SBC     HL,BC
	JR      Z,$ARW01
	HALT
$ARW01: LD      SP,0
	LD      BC,1
	LD      DE,1
	LD      IY,1
	ADD     IY,IY
	ADD     IY,BC
	ADD     IY,DE
	DEC     IY
	DEC     IY
	DEC     IY
	DEC     IY
	PUSH    IY
	POP     HL
	LD      A,H
	OR      L
	JR      Z,$ARW02
	HALT
$ARW02:
	LD      HL,TEXT         ; Test erfolgreich beendet,
	LD      B,TEND-TEXT     ; TEXT aufs Terminal ausgeben
	LD      C,0             ; (Port 0 ist Terminal Output)
	OTIR
	HALT                    ; und CPU anhalten
;
	EJECT
;
;       Die folgenden Unterprogramme testen die CALL und RET Befehle.
;       Durch Erhoehen der Return-Adresse auf dem Stack um 1 werden
;       die HALT-Befehle nach den CALL-Befehlen uebersprungen, wenn
;       alles richtig funktioniert.
;
UP1:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET
	HALT
;
UP2:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     C
	HALT
;
UP3:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     NC
	HALT
;
UP4:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     Z
	HALT
;
UP5:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     NZ
	HALT
;
UP6:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     PO
	HALT
;
UP7:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     PE
	HALT
;
UP8:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     P
	HALT
;
UP9:
	EX      (SP),HL
	INC     HL
	EX      (SP),HL
	RET     M
	HALT
;
	EJECT
;
;       Initialisierte Daten
;
TAB1:   DEFB    00H,01H,02H,03H,04H,05H,06H,07H
	DEFB    08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
	DEFB    10H,11H,12H,13H,14H,15H,16H,17H
	DEFB    18H,19H,1AH,1BH,1CH,1DH,1EH,1FH
TAB1_END:

TEXT:
	DEFM    'Testprogramm erfolgreich beendet'
	DEFB    10
TEND:
;
;       Nicht initialisierte Daten
;
BYTE1:  DEFS    1
BYTE2:  DEFS    1
BYTE3:  DEFS    1
;
WORD1:  DEFS    2
;
	DEFS	100
STACK:
;
	END
