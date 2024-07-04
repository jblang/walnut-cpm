;**************************************************
;
;                 BASICODE READ
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
;*************************************************

	ORG	100H
	CALL	PRINT
 DB CTRLZ,LF,LF,' ** CP/M BASICODE LEES '
 DB '**  RELEASE 1.0',CR,LF,LF,0
;
;
;*************************************************
;
;	Algemene opmerking:
;	Daar ook CP/M de registers van de Z80 niet
;	intact laat bij aanroepen naar het systeem,
;	is hier de regel aanhouden dat registers altijd
;	verpest worden door subroutines, tenzij anders
;	vermeld.
;
;------------- VERANDERLIJKE EQUATES ---------------
;
; 	In het algemeen zal men voor ieder type computer
;       een verantwoorde keus moeten maken uit de volgende
;	opties, alsmede hardware adressen in moeten vullen.
;
; ASSEMBLER SWITCH	  ALS HIJ 1 IS, BETEKENT HET DAT 
MEMMAP	EQU 1	; De Centronics poort is 'memory mapped'
DEBUG	EQU 0	; Debug instrukties meegeassembleerd
		;  Een langzame processor kan hier niet tegen!
FIG	EQU 0	; Een FIGFORTH blokken file wordt ingelezen,
		;  d.w.z. alle CR en LF's weg, alle regels
		;  worden aangevuld tot 64 characters.
OSBRN	EQU 1	; Speciaal voor OSBORNE: bank switching	

; HARDWARE EQUATES
CRIT	EQU	55	; Grens tussen lengte O of 1 bit
PAPORT	EQU	2902H	; Parallel port (memory mapped)
			; Hier moet het Centronics 'PRINTER READY'
			;  signaal op binnen komen.
SCREEN	EQU	0F000H	; Memory mapped video screen
;
;------------- VASTE EQUATES --------------------------------

BDOS	EQU	5H
DMA	EQU	80H
STX	EQU	02H
ETX	EQU	03H
LF	EQU	0AH
CR	EQU	0DH
CTRLZ	EQU	1AH	; CONTROL-Z
FCB	EQU	5CH	; Standaard file control block

;-------------------------------------------------

	JMP	STACK	

;
; ================================================
;

	IF	NOT OSBRN	; Normale situatie
	DS	20H		; Reserveer stack ruimte
	ENDIF

	IF	OSBRN	; Programma moet boven 4000H draaien
	ORG	4020H	; wegens of Osborne bankswitching
	ENDIF

STACK:	
	LXI	H,STACK
	SPHL

; - - - - - WACHT OP KEYBOARD - - - - - - - - - - - 

	CALL	PRINT
	DB	'START CASSETTE EN GEEF RETURN',CR,LF,0 
	MVI	C,1
	CALL	BDOS

;----------- LEZEN VAN CASSETTE --------------------
 
; - - - - - DISABLE INTERRUPTS - - - - - - - - - - 
;
;     DIT IS MISSCHIEN NIET VOOR ELK SYSTEEM VAN BELANG

	DI

; - - - - - INITIALISEREN  - - - - - - - - - - - - -  

	IF	OSBRN
	CALL	BANK2
	ENDIF

	LXI	H,BUFFER-1
	SHLD	LASTCH
;
;------- HAAL DE BYTES EEN VOOR EEN BINNEN ----------------
;
;     Op elk punt waar gelezen wordt kan de gebruiker
;      laten afbreken. Men komt dan in de error afhandeling
;      aan het eind van dit gedeelte (LABEL ERROR2)



REP1:	CALL	SYNCH		; Zoek volgende startbit
	CALL	BYTOBF	   	; Haal byte van cassette
				;  en plaats in buffer
	CALL	CALCHK	 	; Checksum bijwerken
	MOV	A,C		; Naar video ter controle
	STA	SCREEN

	CPI	ETX+80H		; ETX ->voorlaatste char
	JNZ	REP1		; Anders volgende byte

; - - - - CHECKSUM - - - - - - - - - - - - - - - 

	CALL	SYNCH
	CALL	BYTOBF	; Haal checksum van cassette
	LDA	CHKSUM	; Haal berekende checksum	
	CMP	C	; Moet gelijk zijn 
	JNZ	ELSE1	
	MVI	A,0FFH
	JMP	END2

ELSE1:	MVI	A,0
END2:	STA	OKAY
	JMP	END1

; - - - - -  ON ERROR GEDEELTE - - - - - - - - - - - 

ERROR2:	MVI	A,0	; Natuurlijk niet okay
	STA	OKAY	; want het inlezen werd onderbroken
			; door de gebruiker
	LHLD	LASTCH  ; Verzekerd van ETX
	INX	H	
	MVI	M,ETX 	
	SHLD	LASTCH

; - - - - - AFSLUITEN - - - - - - - - - - - - - - 

END1:	NOP

	IF	OSBRN	
	CALL	BANK1	; Bank terugschakelen
	ENDIF

	EI

	CALL	MESSGE  ; Hoe afgelopen?

;
;------- VERPLAATS VAN BUFFER NAAR SCHIJF --------------
;
;	In dit hele gedeelte wijst HL naar het te
;	verwerken byte in de buffer.
;
;- - - - - - INITIALISEREN - - - - - - - - 
;
	CALL 	OPEN
	LHLD	FRSTCH		; Skip rommel voor STX
	INX	H		; Skip ook nog over STX

; - - - - - LOOP OVER DMA BUFFERS - - - - - - - -
 
REP6:
	LXI	D,DMA
	MVI	B,80H	; Bytes per record

REP7:	CALL	COPCHR	; Byte naar DMA buffer
	JZ	OUT3	; Z: d.w.z. ETX gevonden
	DCR	B
	JNZ	REP7
	
	PUSH	H
	CALL	WRITE	; BUFFER VOL : SCHRIJVEN
	POP	H
	JMP	REP6

; - - - - - LAATSTE RECORD - - - - - - - - - - - 
;
;  Vul de laatste buffer met CTRLZ's op
 
OUT3:	DCX	D	; Overschrijf ETX
REP2:	MVI	A,CTRLZ
	STAX	D
	INX	D
	DCR	B
	JNZ	REP2

	CALL WRITE


;- - - - - - EINDE - - - - - - - - - - - - - - 
 
	CALL	CLOSE
	JMP	0	; Terug naar CP/M
	
;**************************************************
;
;     SUBROUTINE GEBIED
;
;**************************************************

; --------- BYTE NAAR DMA BUFFER -------------
; 
;	Verplaats een byte van input buffer naar DMA buffer.
;	Als Z, dan zijn we ETX tegengekomen.
;	Stelt HL ( 'van'-pointer) en DE ('naar'-pointer bij)
;	Behoudt het BC register (teller), tenzij bij FIG
;	 opvulakties.

COPCHR	MOV	A,M	; Copieer buffer naar DMA 
	INX	H
	ANI	7FH	; 7e BIT ERAF
	STAX	D
	INX	D
;	CPI	' '	; Controle char?
;	JNC	NORMAL
	CPI	LF
	JZ	NORMAL
	CPI	CR	; Enige toegestane controle character

	IF	FIG	; Bij FIGFORTH speciale opvul actie
	CZ	OPVUL
	ENDIF

	IF	NOT FIG
	JZ	CRLF
	JMP	NORMAL
CRLF:	DCX	H	; Frommel er een LF bij
	MVI	M,LF	; Wordt straks pas opgepikt!
	ENDIF

NORMAL:	CPI	ETX	; Z vlag betekent einde
	RET

;---------- OPVULLEN MET SPATIES -----------------
;
;	Alleen voor FIG FORTH files
;	Stelt HL,DE en BC bij (zie COPCHR)

	IF	FIG
OPVUL	MVI	A,020H	; Spatie
	DCX	D
	STAX	D	; Overschrijf CR,
	INX	D	;   die er al was.

REP9	MVI	A,20H	; Schrijf spaties
	STAX	D
	INX	D
	DCR	B
	MOV	B,A
	CPI	41H	; Tot 1e regel vol
	RZ
	CPI	01H	; Of 2e regel vol
	RZ
	JMP	REP9
	ENDIF

;---------- SYNCHRONISEREN ---------------------
; 
;	Wacht op 0-bit

SYNCH:	LXI	H,PAPORT
	CALL	BITPS
	MVI	A,CRIT/2	; HET GAAT HIER OM HALVE PERIODE
        CMP	E
	JNC	SYNCH
	CALL	BITPS		; OOK TWEEDE KEER LANG?
	MVI	A,CRIT/2
        CMP	E

	IF	DEBUG 
	MOV	A,E
	STA	SCREEN+3
	ENDIF

	JNC	SYNCH
	RET

; --------- VERWIJDER CHARACTERS -------------------- 
;
;	Verwijder alle char's, gelijk aan register C

REMOVE	LXI	D,FRSTCH
	LXI	H,FRSTCH

REP8:	LDAX	D		; COPIEER VAN D
	MOV	M,A		;   NAAR H

	CMP	C		
	JZ	END4		; INDIEN HET EEN FOUT CHAR IS
	INX	H		;  INCREMENTEER DAN H NIET

END4:	INX	D
	CPI	ETX
	JNZ	REP8

	DCX	H
	SHLD	LASTCH		; NIEUW EINDPUNT
	RET


; ------- HAAL BYTE OP -----------------------------
;
;	Haalt een byte op en plaats het in de buffer.
;	Uitvoer: C bevat het gelezen byte.
;	
BYTOBF:	MVI	C,80H		; Als dit bit weer tevoorschijn
				; komt zijn we klaar
DO1:	CALL	BITIN		; lees bit
	MOV	A,C		; Schuif bit in C erbij
	RAR
	MOV	C,A
	JNC	DO1	

	LHLD	LASTCH		; Plaats c in buffer
	INX	H
	MOV	M,C
	SHLD	LASTCH
	RET

; --------- HOUDT CHECKSUM BIJ ------------------- 
;
;	Invoer: C
;
CALCHK:	MOV	A,C	; In C zit het zojuist gelezen byte	
	CPI	STX+80H
	LDA	CHKSUM
 	JNZ	END3	; Als STX gelezen was 
	XRA	A	; initialisieer dan checksum opnieuw
	SHLD	FRSTCH	; en onthoud dit adres
END3:	XRA	C
	STA	CHKSUM
	RET

; ------------- SWITCH NAAR BANK 1 -------------  
;
;  Zie OSBORNE USER GUIDE 262 ( REV.12/15/82)


	IF	OSBRN
BANK1:	OUT	1
	MVI	A,1
	STA	0EF08H	
	RET

; ------------- SWITCH NAAR BANK 2 ------------------
;
;  Zie OSBORNE USER GUIDE 262 ( REV.12/15/82)

BANK2:	OUT	0
	MVI	A,0
	STA	0EF08H	
	RET
	ENDIF


; ------------- HAAL EEN BIT BINNEN -------------
;
; Bepaal de lengte van de positieve en negatieve 
;  fase.
; 1/1200 sec = 833.25 usec 
; Op de Osborne (4 Mhz) is dat 3333 cycles
; Bij overschrijding hiervan een sprong naar
; de foutafhandeling.
; BC blijft behouden door deze routine heen, C bevat
; immers het te lezen byte in opbouw

BITIN:	PUSH	B
	MVI	B,2	; 2 fasen voor '1-bit'
	
REP4:	CALL	BITPS	; Wacht 1e periode
	MOV	D,E	; Bewaar lengte eerste helft
	CALL	BITPS	; Wacht 2e periode
	MOV	A,E
	ADD	D	; Totale lengte

	IF	DEBUG
	STA	SCREEN+3
	ENDIF

	CPI	CRIT	;  0 of 1 bit?
	JNC	OUT2	; Uit de loop bij 1200 periode
	DCR	B
	JNZ	REP4
			; Anders: skip 2e golf
OUT2:	POP	B
	RET

; ----------- MEET LENGTE PERIODE -----------------
;
; HL wijst al naar de poort (bij memory mapped)
; Bij time-out wordt gekeken of er een toets ingedrukt is.
; Zo ja, dan breekt het inlezen af. 


	IF	MEMMAP
BITPS:	MOV	A,M	; Lees poort
	MVI	E,0	; Init teller

REP5:	INR	E	; Meet lengte
	JZ	OUT1	; Timeout
	CMP	M	; Veranderd?
	JZ	REP5	; Zo niet herhaal
	RET
	ENDIF

; - - - - HET VOLGENDE NIET GETEST - - - - - - - 

	IF	NOT MEMMAP 
BITPS:	IN	PAPORT	; Lees poort
	MOV	L,A	; Bewaar in L
	MVI	E,0	; Init teller

REP5:	INR	E	; Meet lengte
	JZ	OUT1	; Timeout
	IN	PAPORT
	CMP	L	; Veranderd?
	JZ	REP5	; Zo niet herhaal
	RET
	ENDIF

; - - - - - TIME OUT - - - - - - - - - -

OUT1:	
	IF	OSBRN
	CALL	BANK1
	ENDIF

	CALL	KBD	; Wil men afbreken?
	PUSH	PSW

	IF	OSBRN
	CALL	BANK2
	ENDIF

	POP	PSW
	JNZ	REP5 	; Zoniet toch doorgaan
	JMP	ERROR2


; ---------- PRINT DE TEKST VOLGENDE OP DE CALL ---------------

PRINT	POP	H	; Haal return address op
	MOV	A,M	; Haal een letter op
	INX	H
	ORA	A
	JZ	END5
	PUSH	H
	CALL	CRT
	JMP	PRINT
END5	PCHL		; RETURN

; ----------- HOE AFGELOPEN -----------------------

MESSGE:	CALL	PRINT
	DB	CR,LF,' DE CHECKSUM KLOPT ',0
	LDA	OKAY
	ANA	A
	RNZ
	CALL	PRINT
	DB	'NIET',0
	RET

;=================================================
;
;            INTERFACE MET CP/M
;            ------------------
;
;=================================================

; ---------------  FUNKTIE SCAN FOR CHAR -----------
;
;  Uitvoer : Z-vlag betekent toets ingedrukt
 
KBD	PUSH	H
	PUSH	D
	PUSH	B
	EI
	MVI	C,0BH	
	CALL	BDOS
	ANI	1	; TEST L.S. BIT
	CPI	1
	DI
	POP	B
	POP	D
	POP	H
	RET	

; ----------  FUNKTIE PRINT A CHAR ------------
   
CRT	MOV	E,A	; OUTPUTS 'A' IN ASCII
	MVI	C,2	
	CALL	BDOS	
	RET

               

; --------  FUNKTIE MAAK FILE ------------------- 
;
;	OPENT DE FILE MET NAAM OP FCB VOOR SCHRIJVEN
;
OPEN:	MVI	C,22
	LXI	D,FCB
	CALL	BDOS
	RET

; ------  FUNKTIE SCHRIJF RECORD  ---------------

;
;	SCHRIJF HET volgende RECORD 
;
WRITE:	MVI	C,21
	LXI	D,FCB
	CALL	BDOS
	RET

; --------  FUNKTIE SLUIT FILE  --------------
;
;	SLUIT HET SCHRIJVEN AF
;
CLOSE:	MVI	C,16
	LXI	D,FCB
	CALL	BDOS
	RET

;=================================================
;
;            START VAN BUFFER GEBIED
;            -----------------------
;
;=================================================

;
OKAY	DB	0	; BOOLEAN: BETEKENT
;			   - ER WAS STX
;			   - ER WAS ETX
;			   - DE CHECKSUM KLOPTE
FRSTCH	DW	0	; ADRES VAN EERSTE CHAR : STX
;			  ALS OKAY DUS STX
LASTCH	DW	0	; ADRES VAN LAATSTE CHAR : ETX
;			  ALS OKAY DUS ETX
CHKSUM	DB	0	; LOPENDE CHECKSUM
BUFFER:	DS	5000H
 