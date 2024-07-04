;**************************************************
;
;		BASICODE TEST
;
;  DIT OPENBAAR PROGRAMMA MAG GECOPIEERD EN GEDISTRIBEERD
;  WORDEN,  MITS INHOUDENDE DE VOLGENDE COPYRIGHT NOTICE
;
;   "         DIT PROGRAMMA
;     BETREFFENDE EEN IMPLEMENTATIE VAN DE
;		NOS BASICODE
;
;   IS TER BESCHIKKING GESTELD DOOR DE
;	HOBBY COMPUTER CLUB (HOLLAND)      "
;
;
;  NOS 	P.O. 1200 	1200BE HILVERSUM	(HOBBYSCOOP)
;  HCC  P.O. 149	2250AC VOORSCHOTEN	(CP/M gg)
;
;   Implementatie:
;		Albert van der Horst
;	t.b.v.  FORTH gebruikersgroep (HCC)
;
;**************************************************
;
;  Test een bandje geschreven volgens het
;         BASICODE protocol
;  De sterretjes die op het scherm verschijnen,
;  moeten zo goed mogelijk onder elkaar komen.
;  Dit programma is waarschijnlijk niet goed aan 
;  te passen wanneer er geen memory mapped video is.
;
;**************************************************
;
;	Algemene opmerking:
;	Daar ook CP/M de registers van de Z80 niet
;	intact laat bij aanroepen naar het systeem,
;	is hier de regel aanhouden dat registers altijd
;	verpest worden door subroutines, tenzij anders
;	vermeld.
;
;*************************************************

;------------- VERANDERLIJKE EQUATES ---------------
;
; 	In het algemeen zal men voor ieder type computer
;       een verantwoorde keus moeten maken uit de volgende
;	opties, alsmede hardware adressen in moeten vullen.
;
; ASSEMBLER SWITCH	  ALS HIJ 1 IS, BETEKENT HET DAT 
MEMMAP	EQU 1	; De Centronics poort is 'memory mapped'
OSBRN	EQU 1	; Speciaal voor OSBORNE: bank switching	

; HARDWARE EQUATES
PAPORT	EQU	2900H	; Parallel port (memory mapped)
SCREEN	EQU	0F000H	; Memory mapped video screen
DEL12	EQU	90	; Delay loop voor '0' bit (4 MHz)
DEL24	EQU	44	; Delay loop voor '1' bit (4 MHz)

;
;------------- VASTE EQUATES --------------------------------

BDOS	EQU	5H
DMA	EQU	80H
STX	EQU	02H
ETX	EQU	03H
LF	EQU	0AH
CR	EQU	0DH
CTRLZ	EQU	1AH	; Control-Z
FCB	EQU	5CH	; Standaard file control block

;-------------------------------------------------

	ORG	100H
	CALL	PRINT
 DB CTRLZ,LF,LF,LF,LF,LF,' ** CPM BASICODE TEST '
 DB '**  RELEASE 1.0',CR,LF,LF,0

	JMP	STACK	

;
; ================================================
;

	IF	NOT OSBRN	; Normale situatie
	DS	20H		; Reserveer stack ruimte
	ENDIF

	IF	OSBRN	; Programma moet boven 4000H draaien
	ORG	4020H	; wegens Osborne bankswitching
	ENDIF

STACK:	
	LXI	H,STACK	; Initialiseer stack
	SPHL

	IF	OSBRN
        CALL	BANK2
   	ENDIF

; - - - - - INITIALISATIE - - - - - - - - - - - - 
;
;     Tellers gaan mis bij interrupts

	DI 

; - - - - - TESTEN VAN INPUT SIGNAAL - - - - - - 

	LXI	H,PAPORT+2
REP1:	CALL	BITPS
	JZ	OUT1	; Z: Timeout
;
; - - - - - BEREKEN NIEUW ADRES OP VIDEO PAG - - - - - -

	ANI	40H	; 0 of 1 fase ingangssignaal?
	RAL
	RAL
	RAL
	ADI	0F0H	; kies uit 1e of 3e regel
	MOV	D,A

; - - - - - WIS OUDE STERRETJE - - - - - - - - - -

	MVI	A,' '
	STAX	B

; - - - - - ZET NIEUW STERRETJE - - - - - - - - - 

	MOV	A,E		; deel E door 2
	RAR
	MOV	E,A

	MOV	C,E
	MOV	B,D
	MVI	A,'*'
	STAX	B
	JMP	REP1

; - - - - - AFBREKEN? - - - - - - - - - - - - 
; 
;    ( OSBORNE :Schakel even terug naar de andere bank
;    Kijk of er een toets is ingedrukt,
;    dan ophouden.
 
OUT1:	
	IF	OSBRN
	CALL	BANK1
	ENDIF

	CALL	KBD
	PUSH	PSW

	IF	OSBRN
	CALL	BANK2
	ENDIF

	POP	PSW
	JNC	REP1
	CALL	BANK1
	JMP	0	; STOP

;**************************************************
;
;     subroutine gebied
;
;**************************************************
;
;--------------  SWITCH NAAR BANK 2 -------------
;	
;  Zie OSBORNE User Guide 262 ( REV.12/15/82)
;  interrupts zijn al disabled!
;  En moeten dat blijven !
                 
	IF	OSBRN
BANK2:	OUT	0
	MVI	A,0
	STA	0EF08H	
	RET

; -------------  SWITCH NAAR BANK 1 -------------  
;
;  Zie BANK2

BANK1:	OUT	1
	MVI	A,1
	STA	0EF08H	
	RET
	ENDIF


; - - - - - -  MEET LENGTE PERIODE - - - - - 
;
; Normaal ca. 23 perioden (1) of 46 (0) 
; Geeft gemeten lengte terug in E
; HL wijst al naar de poort
; Z bij return wijst op time-out
;
BITPS:	MOV	A,M	; Lees poort
	MVI	E,0	; Init teller

REP5:	INR	E	; Meet lengte
	RZ		; Timeout
	CMP	M	; Veranderd?
	JZ	REP5	; Zo niet herhaal
	RET

; - - - - - - PRINT AN INLINE STRING - - - - - - - - - -

PRINT	POP	H	; HAAL RETURN ADDRESS OP
	MOV	A,M	; GET CHARACTER
	INX	H
	ORA	A
	JZ	END5
	PUSH	H
	CALL	CRT
	JMP	PRINT
END5	PCHL		; RETURN


;=================================================
;
;            INTERFACING WITH CP/M
;            ---------------------
;
;=================================================

;----------------  FUNKTIE SCAN FOR CHAR ----------------
;
KBD	PUSH	H
	PUSH	B
	EI
	MVI	C,0BH	; Als de carry op staat is er een 
	CALL	BDOS	;  toets ingedrukt
	ANI	1
	JZ	NOCHAR
	MVI	C,1
	CALL	BDOS
	STC
	JMP	RETURN
NOCHAR	XRA	A	; Clear carry
RETURN	POP	B
	POP	H
	DI
	RET	

;   zero flag : geen character ingetoetst

KEYBRD	PUSH	H
	PUSH	B
	MVI	C,0BH	
	CALL	BDOS
	ANI	1
	POP	B
	POP	H
	RET	

; -------------  FUNKTIE PRINT A CHAR ------------- - 
   
CRT	MOV	E,A	; OUTPUTS 'A' IN ASCII
	MVI	C,2	
	CALL	BDOS	
	RET



