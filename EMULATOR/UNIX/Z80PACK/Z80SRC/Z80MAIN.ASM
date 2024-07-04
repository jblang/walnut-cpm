	TITLE   'Hauptprogramm fuer Z80-Disassembler'

;==========================================================================
;       Testprogramm fuer Z80-Disassembler
;==========================================================================

	LD      SP,STACK        ; Stack fuer Simulator initialisieren
	LD      HL,Z80OPS       ; Startadresse fuer Disassembler
	LD      (DADR),HL       ; in DADR ablegen
LOOP:
	CALL    DISSCR          ; einen Bildschirm disassemblieren
	HALT                    ; Simulation anhalten
	JP      LOOP            ; naechster Durchlauf

PRTSTR:                         ; Null-terminierten String ausgeben
	LD      A,(HL)          ; naechstes Zeichen -> A
	OR      A               ; 0 ?
	RET     Z               ; ja, fertig
	OUT     (0),A           ; nein, ausgeben
	INC     HL              ; Pointer auf String erhoehen
	JP      PRTSTR          ; naechstes Zeichen bearbeiten

	INCLUDE z80dis.asm
	INCLUDE z80ops.asm

	DEFS	100H
STACK:
	END
