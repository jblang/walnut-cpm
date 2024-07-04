;**************************************************
;
;		  PROGRAMMA BCWRIT
;		  ================
;
;    Schrijft een CP/M tekstfile naar cassette volgens
;    het BASICODE protocol.
;    De naam wordt opgegeven in de aanroep.
;
;**************************************************
;
;  DIT OPENBAAR PROGRAMMA MAG GECOPIEERD EN GEDISTRIBUEERD
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

	ORG	100H
	CALL	PRINT
 DB CTRLZ,LF,LF,' ** CP/M BASICODE WRITE '
 DB '**  RELEASE 1.0',CR,LF,LF,0		;	;B
;
;*************************************************
;
;	Algemene opmerking:
;	Daar ook CP/M de registers van de Z80 niet
;	intact laat bij aanroepen naar het systeem,
;	is hier de regel aanhouden dat registers altijd
;	verpest worden door subroutines.
;	Uitzonderingen: de snelheidsgevoelige schrijf-
;	routines behouden het HL register.
;	Dit zijn : PAUSE,BEEPV,SE1200,SE2400 en HLFPER.
;	Hiervan behouden de laatste 3 ook het DE register.
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
FIG	EQU 0	; Een FIGFORTH blokken file wordt geschreven,
		;  d.w.z. na elke 64 characters wordt 
		;  automatisch een CR gegenereerd,
		;  die niet in de invoer stond.
OSBRN	EQU 1	; Speciaal voor OSBORNE: bank switching	

; HARDWARE EQUATES
PAPORT	EQU	2900H	; Parallel port (memory mapped)
SCREEN	EQU	0F000H	; Memory mapped video screen
DEL12	EQU	98	; Delay loop voor '0' bit (4 MHz)
DEL24	EQU	48	; Delay loop voor '1' bit (4 MHz)

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

	JMP	STACK	

;
; ================================================
;

	IF	NOT OSBRN	; Normale situatie
	DS	20H		; Reserveer stackruimte
	ENDIF

	IF	OSBRN	; Programma moet boven 4000H draaien
	ORG	4020H	; wegens Osborne bankswitching
	ENDIF

STACK:	
	LXI	H,STACK
	SPHL


;---------- VERPLAATS VAN SCHIJF NAAR BUFFER --------------

; - - - - - INITIALISEREN - - - - - - - - - - - - - - - - - 


	CALL 	OPEN

	IF	DEBUG
	ADI	30H
	CALL	CRT
	CALL	PRINT
	DB	' : WAS DE STATUS NA OPENEN',CR,LF,0
	ENDIF

	LXI	H,BUFFER	; Eerste letter:'STX'
	MVI	M,STX
	INX	H

; - - - - - LUS OVER RECORDS - - - - - - - - - - - - 
 
REP2:	SHLD	CURDMA	; Bewaar het huidige DMA adres

	MOV	D,H	; Zet het DMA adres
	MOV	E,L
	CALL	SETDMA

	CALL 	READ	; Lees een buffer in

	STA	STATUS	; Bewaar foutmelding
	IF	DEBUG
	ADI	30H
	CALL	CRT
	CALL	PRINT
	DB	' : WAS DE STATUS NA LEZEN',CR,LF,0
	ENDIF

	LHLD	CURDMA	; Bereidt volgende buffer
	LXI	D,80H	;   adres voor
	DAD	D	
	
	IF	FIG	; Alleen bij FIG files
	CALL	INSCR	;  zet er cr's tussen
	ENDIF

	LDA	STATUS
	CPI	0	; TEST STATUS
	JZ	REP2
	MVI	M,CTRLZ ; Voor het geval...
 
; - - - - - AFSLUITING INLEES GEDEELTE  - - - - - -
 

	IF	DEBUG
	ADI	30H
	CALL	CRT
	CALL	PRINT
	DB	' : WAS DE STATUS NA LEZEN',CR,LF,0
	ENDIF

	CALL	CLOSE

;------------ OMWERKEN TEKST IN BUFFER -------------------
;
; WAARSCHUWING: Dit is systeem afhankelijk
;
; - - - - - VERWIJDEREN LINEFEED - - - - - - - - - -

	MVI	C,LF	
	CALL	REMOVE	

; - - - - - EINDE OPZOEKEN - - - - - - - - - - - - -
;
;    Einde is CTRL-Z. Alle tekst files onder CP/M 
;      WORDEN AFGESLOTEN MET CTRL-Z (ANDERE NIET)

	LXI	H,BUFFER
REP4:	INX	H
	MOV	A,M
	CPI	CTRLZ
	JZ	OUT1
	JMP	REP4

OUT1:	NOP
	MVI	M,ETX

; - - - - - BEREKEN CHECKSUM - - - - - - - - - - -
;
; Zet meteen ook de achtste biiten op

	LXI	H,BUFFER
	MVI	A,0		; Initialiseer checksum 
	STA	CHKSUM
		
REP8:	MOV	A,M
	ORI	80H		; Zet achtste bit
	MOV	M,A		

	LDA	CHKSUM		; Werk checksum bij
	XRA	M
	STA	CHKSUM

	MOV	A,M		; Zijn we all bij laatste
	INX	H		;  byte (=ETX)?
	CPI	80H+ETX
	JNZ	REP8	

	LDA	CHKSUM
	MOV	M,A

; - - - - - VERDELING IN BLOKKEN - - - - - - - - - - - - 
;
;   Ten behoeve van wegschrijven van buffers volgt
;    een seconde blank na elke 16 regels. Om dit te markeren
;    wordt elke 16e 'CR' in een 0 veranderd. 
;    De buffer wordt afgesloten met 2 nullen.
;  
	LXI	H,BUFFER-1
	MVI	B,16		; Teller voor CR's
		
REP1:	INX	H
	MOV	A,M	
	CPI	80H+ETX		; Einde buffer?
	JZ	OUT2	
	CPI	CR		; CR?
	JNZ	REP1
	
	DCR	B		; Tel de CR's
	JNZ	REP1

	MVI	M,0		; Verander 16e CR in 0
	MVI	B,16
	JMP	REP1

; - - - - -  SCHRIJF 2 AFSLUITENDE NULLEN - - - - - - - - -

OUT2:	INX	H		; Sla checksum over
	INX	H
	MVI	M,0
	INX	H
	MVI	M,0

;--------------- SCHRIJVEN NAAR CASSETTE ----------------

; - - - - - WACHT OP KEYBOARD - - - - - - - - - - - 

	CALL	PRINT
	DB	'START CASSETTE EN GEEF RETURN',CR,LF,0 
	MVI	C,1
	CALL	BDOS


; - - - - - DISABLE INTERRUPTS - - - - - - - - - - - 
;
;     DIT IS MISSCHIEN NIET VOOR ELK SYSTEEM VAN BELANG


	DI
	
	IF	OSBRN	
	CALL	BANK2
	ENDIF

; - - - - - HEADER - - - - - - - - - - - - -

	CALL	BEEP 		;   piepen.

; - - - - - WEGSCHRIJVEN VAN DE TEKST - - - - - - -
;
; Voor het wegschrijven ziet de file er als volgt uit:
; - telkens 15 regels gevolgd door CR
; _ elke 16e regel gevolgd door ASCII 0
; - na het laatste blok van 16 regels (of minder) :
;	 ETX en checksum
;

	LXI	H,BUFFER

REP5:	MOV	D,M
	MOV	A,D
	STA	SCREEN		; Zet teken ook op video
	ANA	A		; clear carry (carry=startbit)
;
	MVI	E,11		; # bits (inclusief start/stop)
REP6:	CNC	SE1200		; Zend 0-bit
	CC	SE2400		;   of 1-bit
	
	STC			; Wordt stopbit

	MOV	A,D		; Rotate D
	RAR
	MOV	D,A

	DCR	E
	JNZ	REP6		; Zo 11 keer

	INX	H	; Inspecteer volgende byte
	MOV	A,M	
	ANA	A	; Als het ASCII 0 is,
	CZ	PAUSE	;  pauzeer dan 1 sec
	JNZ	REP5	; PAUSE zet Z vlag bij einde.

; - - - - - TRAILER - - - - - - - - - - - - - -


	CALL	BEEP 		;   piepen.

;- - - - - - - - KLAAR BOODSCHAP - - - - - - - - 

	IF	OSBRN
	CALL	BANK1		; Anders komen we in de monitor!
	ENDIF
	EI
	CALL	PRINT
	DB	'KLAAR',0
	JMP	0

;**************************************************
;
;     subroutine gebied
;
;**************************************************

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

;-------------- PAUSE --------------------------
;
; Er staat een ASSCII nul in de buffer
; D.w.z. er moet nu 1 sec pauze komen.
; Geeft terug Z, Z betekent: einde van buffer
; Dit ziet PAUSE aan de 2e nul.

PAUSE:	INX	H	; 2e nul erachter?
	MOV	A,M
	ANA	A
	DCX	H	; Zet HL terug

	RZ		; Geef terug Z=einde

	LXI	D,1200	; 1 sec 
	CALL	BEEPV	;   piepen
	MVI	A,CR	; Overschrijf de 0 die
	MOV	M,A	;   nu niet meer nodig is.
	ANA	A	; Strijk de Z vlag
	RET	

 
; ------------- PIEPEN -------------------------
;
;	BEEP geeft de normale 5 sec. piep.
;	Voor BEEPV wordt het aantal perioden van de
;	2400 Hz piep opgegeven in het DE register.

	IF	NOT DEBUG
BEEP:	LXI	D,6000
	ENDIF

	IF	DEBUG		; Bij debuggen :
BEEP:	LXI	D,24000		;   piep 20 sec  
	ENDIF

BEEPV:	CALL	SE2400		; 2400 HZ Puls
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	BEEPV
	RET	

; ------------- 1200 HZ GOLF --------------------- 
;
;    1200 Hz gedurende 1/1200 sec. ( Behoudt DE en HL)
;    Zendt een 0-bit 	

SE1200:	MVI	A,0
	MVI	B,DEL12		; Delay tijd behorende
	CALL	HLFPER		;  bij 1200 Hz
	MVI	B,DEL12
	JP	HLFPER		

; ------------- 2400 HZ GOLF --------------------- 
;
;    2400 Hz gedurende 1/1200 sec. ( Behoudt DE en HL)
;    Zendt een 1-bit 	

SE2400: MVI	A,0
	MVI	B,DEL24		; Delaù tijä behorendå 
	CALL	HLFPER		;  bij 2400 Hz
	MVI	B,DEL24
	CALL	HLFPER
	MVI	B,DEL24
	CALL	HLFPER
	MVI	B,DEL24
	CALL	HLFPER
	RET

; -----------  SCHRIJF EEN HALVE PERIODE ---------------
;
;	De duur van de halve periode in reg B
;	De delay tijd is 32+14*(B-1))*T
;	waarbij T de cyclus tijd is (OSBORNE: .25 us)

	IF 	MEMMAP
HLFPER:	STA	PAPORT		;  naar memory mapped poort
	ENDIF

	IF 	NOT MEMMAP
HLFPER:	OUT	PAPORT		;  naar output poort
	ENDIF

DELAY:	DCR	B		;  delay
	JNZ	DELAY
	XRI	0FH		; KLAP OM
	RET

; --------- INVOEGEN VAN CARRIAGE RETURNS -------------- 
;
;    Per ingelezen sector worden 2 CR ingevoegd 
;    Alleen FIG FORTH!!

	IF	FIG
INSCR:	LHLD	CURDMA		
	MOV	D,H
	MOV	E,L
	DCX	D		; Wijst nu naar laatste char
	INX	H	
	INX	H
	CALL	ONELIN
	CALL	ONELIN
	RETURN

ONELIN:	MVI	M,CR		; CR invoeren	
	DCX	H

	MOV	B,40H		; Copieer 64 char
REP9:	LDAX	D		;  van D
	MOV	M,A		;  naar H
	DCX	H
	DCX	D
	DCR	B
	JNZ	REP9
	RET
	ENDIF

; --------- VERWIJDER CHARACTER ------------------- 

REMOVE:	LXI	D,BUFFER
	LXI	H,BUFFER

REP7:	LDAX	D		; Copieer van D
	MOV	M,A		;   naar H
	CMP	C		; Overschrijf straks
	JZ	END1		;  indien het een fout character was
	INX	H
END1:	INX	D
	CPI	ETX
	JNZ	REP7

	LDAX	D		; Copieer checksum
	MOV	M,A

	RET

; --------- PRINT AN INLINE STRING -------------------

PRINT	POP	H	; Haal return address op
	MOV	A,M	; Haal karakter op
	INX	H
	PUSH	H	

	ORA	A	; Tot ASCII 0
	RZ		; Return adres wijst nu na
;			;  de char's! 

	CALL	CRT	; Naar het scherm
	JMP	PRINT


;=================================================
;
;            INTERFACING WITH CP/M
;            ---------------------
;
;=================================================

; ---------------  FUNKTIE SCAN FOR CHAR ---------------
; 
; Z betekent toets ingedrukt
;
KEYBRD:
	IF	OSBRN
	CALL	BANK1
	ENDIF
	PUSH	H
	PUSH	B
	MVI	C,0BH	
	CALL	BDOS
	POP	B
	POP	H
	IF	OSBRN
	CALL	BANK2
	ENDIF
	XRA	A	; zet 'Z' flag naargelang 'A'
	RET	

; -------------  FUNKTIE PRINT A CHAR ------------------
   
CRT	MOV	E,A	; Outputs 'A' in ASCII
	MVI	C,2	
	CALL	BDOS	
	RET



; -----------  FUNKTIE OPEN FILE ------------------------ 
;
;	Opent de file met naam op FCB voor lezen
;
OPEN:	MVI	C,15
	LXI	D,FCB
	CALL	BDOS
	CPI	0FFH
	JZ	ERROR1
	RET

ERROR1:	CALL	PRINT
	DB	' NIET AANWEZIG',0
	JP	0
 
; -----------  FUNKTIE SLUIT FILE  --------------------
;
;	Sluit het lezen af
;
CLOSE:	MVI	C,16
	LXI	D,FCB
	CALL	BDOS
	RET

; -----------  FUNKTIE LEES RECORD  -------------------
;
;	Lees het volgende record 
;
READ:	MVI	C,20
	LXI	D,FCB
	CALL	BDOS
	RET

; -----------  FUNKTIE ZET HET DMA ADRES ---------------
;
;	Vul het DMA adres in 
;
SETDMA:	MVI	C,26
	CALL	BDOS
	RET


;**************************************************
;
;	 BUFFER GEBIED
;	 =============
;
;**************************************************

CHKSUM	DB	0	; Checksum (berekend)
STATUS	DB	0	; Status na lezen
CURDMA	DW	0	; Huidige DMA adres

BUFFER:	DS	5000H
