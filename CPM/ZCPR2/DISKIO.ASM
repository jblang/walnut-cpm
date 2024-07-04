*****************************************************************
*								*
*  SYSIO -- Standard Set of Redirectable I/O Drivers		*
*	for ARIES-1 with ZCPR2 and CHBIOSZ			*
*								*
*****************************************************************
FALSE	EQU	0
TRUE	EQU	NOT FALSE
stksiz	equ	200	;Limit of Caller's Stack
cr	equ	0dh	;<CR>

	MACLIB	CBIOSHDR

biosdma	equ	scratch	;Location of DMA Address

*****************************************************************
*								*
*  Disk Serial, MPU Serial, Quad I/O, and Modem Equates		*
*								*
*****************************************************************

;  Disk Serial -- Serial Channel on Disk Controller Board (DCE)
;    Baud Rate is set at 19,200 Baud in Hardware (DIP Switches)
ustat	equ	0E3F9H	;USART Status Address
ostat	equ	8	;Output Status Bit (TBE)
istat	equ	4	;Input Status Bit (RDA)

;  MPU Serial -- Serial Channel on CCS Z80 MPU Board (DCE)
mpubase	equ	20H	;Base address of 8250 on CCS Z80 MPU Board
mpudata	equ	mpubase		;Data I/O Registers
mpudll	equ	mpubase		;Divisor Latch Low
mpudlh	equ	mpubase+1	;Divisor Latch High
mpuier	equ	mpubase+1	;Interrupt Enable Register
mpulcr	equ	mpubase+3	;Line Control Register
mpupcr	equ	mpubase+4	;Peripheral Control Register
mpustat	equ	mpubase+5	;Line Status Register
mpupsr	equ	mpubase+6	;Peripheral Status Register

;  MPU Serial RDA and TBE
mpurda	equ	1	; Data Available Bit (RDA)
mputbe	equ	40h	; Transmit Buffer Empty Bit (TBE)

;  MPU Serial Baud Rate Values
bm00050	equ	2304	;    50   Baud
bm00075	equ	1536	;    75   Baud
bm00110	equ	1047	;   110   Baud
bm00134	equ	857	;   134.5 Baud
bm00150	equ	768	;   150   Baud
bm00300	equ	384	;   300   Baud
bm00600	equ	192	;   600   Baud
bm01200	equ	96	;  1200   Baud
bm01800	equ	64	;  1800   Baud
bm02000	equ	58	;  2000   Baud
bm02400	equ	48	;  2400   Baud
bm03600	equ	32	;  3600   Baud
bm04800	equ	24	;  4800   Baud
bm07200	equ	16	;  7200   Baud
bm09600	equ	12	;  9600   Baud
bm19200	equ	6	; 19200   Baud
bm38400	equ	3	; 38400   Baud
bm56000	equ	2	; 56000   Baud

;  MPU Serial Channel Baud Rate
mpbrate	equ	bm19200	; 19,200 Baud

;  Quad I/O Ports
qbase	equ	80h	; Base address of Quad RS-232 I/O Board
q0data	equ	qbase		; USART 0 Data Port (DTE)
q0stat	equ	qbase+1		; USART 0 Status Port
q1data	equ	qbase+2		; USART 1 Data Port (DTE)
q1stat	equ	qbase+3		; USART 1 Status Port
q2data	equ	qbase+4		; USART 2 Data Port (DTE)
q2stat	equ	qbase+5		; USART 2 Status Port
q3data	equ	qbase+6		; USART 3 Data Port (DCE)
q3stat	equ	qbase+7		; USART 3 Status Port
q0baud	equ	qbase+8		; USART 0 Baud Rate Port
q1baud	equ	qbase+9		; USART 1 Baud Rate Port
q2baud	equ	qbase+10	; USART 2 Baud Rate Port
q3baud	equ	qbase+11	; USART 3 Baud Rate Port

;  Quad I/O RDA and TBE
qrda	equ	2	; Read Data Available Bit (RDA)
qtbe	equ	1	; Transmit Buffer Empty Bit (TBE)

*************************************
*  Equate Values for PMMI as Modem  *
*************************************
*  Modem Ports (Special -- 300 or 600 Baud for PMMI)
*mods	equ	0E0H	; Modem Status Byte
*modd	equ	0E1H	; Modem Data Byte
*
*  Modem RDA and TBE
*mrda	equ	2	; Read Data Available Bit (RDA)
*mtbe	equ	1	; Transmit Buffer Empty Bit (TBE)
*************************************

;  Modem Ports set to QUAD I/O Port 2
mods	equ	q2stat	; Modem Status Port
modd	equ	q2data	; Modem Data Port

;  Modem RDA and TBE
mrda	equ	qrda
mtbe	equ	qtbe

;  Baud Rate Values
b00050	equ	0	;    50   Baud
b00075	equ	1	;    75   Baud
b00110	equ	2	;   110   Baud
b00134	equ	3	;   134.5 Baud
b00150	equ	4	;   150   Baud
b00300	equ	5	;   300   Baud
b00600	equ	6	;   600   Baud
b01200	equ	7	;  1200   Baud
b01800	equ	8	;  1800   Baud
b02000	equ	9	;  2000   Baud
b02400	equ	10	;  2400   Baud
b03600	equ	11	;  3600   Baud
b04800	equ	12	;  4800   Baud
b07200	equ	13	;  7200   Baud
b09600	equ	14	;  9600   Baud
b19200	equ	15	; 19200   Baud


*****************************************************************
*								*
*  Baud Rates for Quad I/O Devices				*
*								*
*****************************************************************

q0brate	equ	b09600	;  9600 Baud for Intersystem
q1brate	equ	b01200	;  1200 Baud for Clock
q2brate	equ	b00300	;   300 Baud for Smartmodem
q3brate	equ	b00300	;   300 Baud for Printer


*****************************************************************
*								*
*  Miscellaneous Constants					*
*								*
*****************************************************************
XON	equ	11h	;X-ON
XOFF	equ	13h	;X-OFF
djram	equ	0e400h	;Base of DJ RAM
djcin	equ	djram+3	;DJ Console Input
djcout	equ	djram+6	;DJ Console Output

*****************************************************************
*								*
* The following are the Z80 Macro Definitions which are used to	*
* define the Z80 Mnemonics used to implement the Z80 instruction*
* set extensions employed in CBIOSZ.				*
*								*
*****************************************************************
;
; MACROS TO PROVIDE Z80 EXTENSIONS
;   MACROS INCLUDE:
;
$-MACRO 		;FIRST TURN OFF THE EXPANSIONS
;
;	JR	- JUMP RELATIVE
;	JRC	- JUMP RELATIVE IF CARRY
;	JRNC	- JUMP RELATIVE IF NO CARRY
;	JRZ	- JUMP RELATIVE IF ZERO
;	JRNZ	- JUMP RELATIVE IF NO ZERO
;	DJNZ	- DECREMENT B AND JUMP RELATIVE IF NO ZERO
;	LDIR	- MOV @HL TO @DE FOR COUNT IN BC
;	LXXD	- LOAD DOUBLE REG DIRECT
;	SXXD	- STORE DOUBLE REG DIRECT
;
;
;
;	@GENDD MACRO USED FOR CHECKING AND GENERATING
;	8-BIT JUMP RELATIVE DISPLACEMENTS
;
@GENDD	MACRO	?DD	;;USED FOR CHECKING RANGE OF 8-BIT DISPLACEMENTS
	IF (?DD GT 7FH) AND (?DD LT 0FF80H)
	DB	100H	;Displacement Range Error on Jump Relative
	ELSE
	DB	?DD
	ENDIF
	ENDM
;
; Z80 MACRO EXTENSIONS
;
JR	MACRO	?N
	DB	18H
	@GENDD	?N-$-1
	ENDM
;
JRC	MACRO	?N
	DB	38H
	@GENDD	?N-$-1
	ENDM
;
JRNC	MACRO	?N
	DB	30H
	@GENDD	?N-$-1
	ENDM
;
JRZ	MACRO	?N
	DB	28H
	@GENDD	?N-$-1
	ENDM
;
JRNZ	MACRO	?N
	DB	20H
	@GENDD	?N-$-1
	ENDM
;
DJNZ	MACRO	?N
	DB	10H
	@GENDD	?N-$-1
	ENDM
;
LDIR	MACRO
	DB	0EDH,0B0H
	ENDM
;
LDED	MACRO	?N
	DB	0EDH,05BH
	DW	?N
	ENDM
;
LBCD	MACRO	?N
	DB	0EDH,4BH
	DW	?N
	ENDM
;
SDED	MACRO	?N
	DB	0EDH,53H
	DW	?N
	ENDM
;
SBCD	MACRO	?N
	DB	0EDH,43H
	DW	?N
	ENDM
;
; END OF Z80 MACRO EXTENSIONS
;


*****************************************************************
*								*
* Terminal driver routines. Iobyte is initialized by the cold	*
* boot routine, to modify, change the "intioby" equate.	The	*
* I/O routines that follow all work exactly the same way. Using	*
* iobyte, they obtain the address to jump to in order to execute*
* the desired function. There is a table with four entries for	*
* each of the possible assignments for each device. To modify	*
* the I/O routines for a different I/O configuration, just	*
* change the entries in the tables.				*
*								*
*****************************************************************

	org	iobase		;Base Address of I/O Drivers
offset	equ	100h-iobase	;Offset for load via DDT or ZSID

	jmp	status		;Internal Status Routine
	jmp	select		;Device Select Routine
	jmp	namer		;Device Name Routine

	jmp	tinit		;Initialize Terminal

	jmp	const		;Console Input Status
	jmp	conin		;Console Input Char
	jmp	conout		;Console Output Char

	jmp	list		;List Output Char

	jmp	punch		;Punch Output Char

	jmp	reader		;Reader Input Char

	jmp	listst		;List Output Status

	jmp	newio		;New I/O Driver Installation Routine

	jmp	copen		;Open CON: Disk File
	jmp	cclose		;Close CON: Disk File

	jmp	lopen		;Open LST: Disk File
	jmp	lclose		;Close LST: Disk File


*****************************************************************
*								*
*  I/O Driver Support Specification Tables			*
*								*
*****************************************************************

*
* Device Counts
*	First Byte is Number of Devices, 2nd Byte is Selected Device
*
cnttbl:
	db	5,(intioby AND 7)		;CON:
	db	2,(intioby AND 08h) SHR 3	;RDR:
	db	2,(intioby AND 10h) SHR 4	;PUN:
	db	6,(intioby AND 0E0h) SHR 5	;LST:

*
* Configuration Table
*	First Byte is Rotate Count, 2nd Byte is Mask
*
cfgtbl:
	db	0,111$1$1$000b	;No Rotate, Mask Out 3 LSB
	db	3,111$1$0$111b	;3 Rotates, Mask Out Bit 3
	db	4,111$0$1$111b	;4 Rotates, Mask Out Bit 4
	db	5,000$1$1$111b	;5 Rotates, Mask Out 3 MSB

*****************************************************************
*								*
* status: return information on devices supported by this	*
*	I/O Package.  On exit, HL points to a logical device	*
*	table which is structured as follows:			*
*		Device	Count Byte  Current Assignment Byte	*
*		------	----------  -----------------------	*
*		 CON:	     0			1		*
*		 RDR:	     2			3		*
*		 PUN:	     4			5		*
*		 LST:	     6			7		*
*								*
*	If error or no I/O support, return with Zero Flag Set.	*
*	Also, if no error, A=Driver Module Number		*
*								*
*****************************************************************
status:
	lxi	h,cnttbl	;point to table
	mvi	a,81H		;Module 1 (SYSIO) with Disk Output
	ora	a		;Set Flags
	ret


*****************************************************************
*								*
* select: select devices indicated by B and C.  B is the number	*
*	of the logical device, where CON:=0, RDR:=1, PUN:=2,	*
*	LST:=3, and C is the desired device (range 0 to dev-1).	*
*	Return with Zero Flag Set if Error.			*
*								*
*****************************************************************
ranger:
	lxi	h,cnttbl-2	;check for error
	inr	b	;range of 1 to 4
	mov	a,b	;Value in A
	cpi	5	;B out of range?
	jnc	rangerr
	push	b	;save params
rang:
	inx	h	;pt to next
	inx	h
	djnz	rang
	mov	b,m	;get count in b
	mov	a,c	;get selected device number
	cmp	b	;compare (C must be less than B)
	pop	b	;get params
	jrnc	rangerr	;range error if C >= B
rangok:
	mvi	a,0ffh	;OK
	ora	a	;set flags
	ret
rangerr:
	xra	a	;not OK
	ret
select:
	call	ranger	;check for range error
	rz		;abort if error
	inx	h	;pt to current entry number
	mov	m,c	;save selected number there
	lxi	h,cfgtbl-2	;pt to configuration table
sel2:
	inx	h	;Pt to Entry in Configuration Table
	inx	h
	djnz	sel2
	mov	b,m	;Get Rotate Count
	inx	h	;Pt to Select Mask
	mov	d,m	;Get Select Mask
	mov	a,b	;Any Rotation to do?
	ora	a
	jz	sel4
	mov	a,c	;Get Selected Number
sel3:
	rlc		;Rotate Left 1 Bit
	djnz	sel3
	mov	c,a	;Place Bit Pattern Back in C
sel4:
	lda	iobyte	;get I/O byte
	ana	d	;mask out old selection
	ora	c	;mask in new selection
	sta	iobyte	;put I/O byte
	jr	rangok	;range OK

*****************************************************************
*								*
* namer: return text string of physical device.  Logical device	*
*	number is in B and physical selection is in C.		*
*	HL is returned pointing to the first character of the	*
*	string.  The strings are structured to begin with a	*
*	device name followed by a space and then a description	*
*	string which is terminated by a binary 0.		*
*								*
*	Return with Zero Flag Set if error.			*
*								*
*****************************************************************
namer:
	call	ranger	;check for range error
	rz		;return if so
	lxi	h,namptbl-2	;pt to name ptr table
	call	namsel	;select ptr table entry
	mov	b,c	;physical selection number in B now
	inr	b	;Add 1 for Initial Increment
	call	namsel	;point to string
	jr	rangok	;return with HL pointing and range OK
;
;  Select entry B in table pted to by HL; this entry is itself a pointer,
;  and return with it in HL
;
namsel:
	inx	h	;pt to next entry
	inx	h
	djnz	namsel
	mov	a,m	;get low
	inx	h
	mov	h,m	;get high
	mov	l,a	;HL now points to entry
	ret

*****************************************************************
*								*
* const: get the status for the currently assigned console.	*
*	 The I/O Byte is used to select the device.		*
*								*
*****************************************************************
const:
	lxi	h,cstble	;Beginning of jump table
conmask:
	lxi	d,cfgtbl	;Pt to First Entry in Config Table
	jr	seldev		;Select correct jump

*****************************************************************
*								*
* conin: input a character from the currently assigned console.	*
*	 The I/O Byte is used to select the device.		*
*								*
*****************************************************************
conin:
	lxi	h,citble	;Beginning of character input table
	jr	conmask		;Get Console Mask

*****************************************************************
*								*
* conout: output the character in C to the currently assigned	*
*	  console.  The I/O Byte is used to select the device.	*
*								*
*****************************************************************
conout:
	lxi	h,cotble	;Beginning of the character out table
	jr	conmask		;Get Console Mask

*****************************************************************
*								*
* csreader: get the status of the currently assigned reader.	*
*	    The I/O Byte is used to select the device.		*
*								*
*****************************************************************
csreadr:
	lxi	h,csrtble	;Beginning of reader status table
rdrmask:
	lxi	d,cfgtbl+2	;Pt to 2nd Entry in Config Table
	jr	seldev

*****************************************************************
*								*
* reader: input a character from the currently assigned reader.	*
*	  The I/O Byte is used to select the device.		*
*								*
*****************************************************************
reader:
	lxi	h,rtble		;Beginning of reader input table
	jr	rdrmask		;Get the Mask and Go

*****************************************************************
*								*
* Entry at seldev will form an offset into the table pointed	*
* to by H&L and then pick up the address and jump there.	*
* The configuration of the physical device assignments is	*
* pointed to by D&E (cfgtbl entry).				*
*								*
*****************************************************************
seldev:
	push	b		;Save Possible Char in C
	ldax	d		;Get Rotate Count
	mov	b,a		;... in B
	inx	d		;Pt to Mask
	ldax	d		;Get Mask
	cma			;Flip Bits
	mov	c,a		;... in C
	lda	iobyte		;Get I/O Byte
	ana	c		;Mask Out Selection
	inr	b		;Increment Rotate Count
seld1:
	dcr	b		;Count down
	jrz	seld2
	rrc			;Rotate Right one Bit
	jr	seld1
seld2:
	rlc			;Double Number for Table Offset
	mvi	d,0		;Form offset
	mov	e,a
	dad	d		;Add offset
	mov	a,m		;Pick up low byte
	inx	h
	mov	h,m		;Pick up high byte
	mov	l,a		;Form address
	pop	b		;Get Possible Char in C
	pchl			;Go there !

*****************************************************************
*								*
* punch: output char in C to the currently assigned punch	*
*	 device.  The I/O Byte is used to select the device.	*
*								*
*****************************************************************
punch:
	lxi	h,ptble		;Beginning of punch table
	lxi	d,cfgtbl+4	;Get Mask
	jr	seldev		;Select Device and Go

*****************************************************************
*								*
* list: output char in C to the currently assigned list device.	*
*	The I/O Byte is used to select the device.		*
*								*
*****************************************************************
list:
	lxi	h,ltble		;Beginning of the list device routines
lstmask:
	lxi	d,cfgtbl+6	;Get Mask
	jr	seldev		;Select Device and Go

*****************************************************************
*								*
* Listst: get the output status of the currently assigned list	*
*	  device.  The I/O Byte is used to select the device.	*
*								*
*****************************************************************
listst:
	lxi	h,lstble	;Beginning of the list device status
	jr	lstmask		;Mask and Go

*****************************************************************
*								*
* If customizing I/O routines is being performed, the tables	*
* below should be modified to reflect the changes. All I/O	*
* devices are decoded out of iobyte and the jump is taken from	*
* the following tables.						*
*								*
*****************************************************************

*
* name text tables
*
namptbl:
	dw	conname-2	;CON:
	dw	rdrname-2	;RDR:
	dw	punname-2	;PUN:
	dw	lstname-2	;LST:

conname:
	dw	namtty	;TTY
	dw	namcrt	;CRT
	dw	namusr	;CRT and Modem in Parallel
	dw	namusr1	;CRT Input and CRT/Remote Computer Output
	dw	namdsk1	;CRT and Disk

lstname:
	dw	namtty	;TTY
	dw	namcrt	;CRT
	dw	namrem	;Remote Computer
	dw	nammod	;Modem
	dw	namdsk2	;TTY and Disk
	dw	namdsk3	;Disk

rdrname:
	dw	nammod	;Modem
	dw	namclk	;Clock

punname:
	dw	nammod	;Modem
	dw	namclk	;Clock

namdsk1:
	db	'CRTDISK Televideo 950 CRT with Disk File Output',0
namdsk2:
	db	'TTYDISK Model 43 Printing Terminal with Disk File Output',0
namdsk3:
	db	'DISK Disk File Output Only',0
namtty:
	db	'TTY Model 43 Printing Terminal',0
namcrt:
	db	'CRT Televideo 950 CRT',0
namusr:
	db	'CRTMOD Televideo 950 CRT and Modem in Parallel',0
namusr1:
	db	'CRTREM Televideo 950 CRT Input and CRT/Remote Output',0
namrem:
	db	'REMOTE Remote Computer',0
nammod:
	db	'MODEM DC Hayes Smartmodem',0
namclk:
	db	'CLOCK DC Hayes Chronograph',0

*
* console input table
*
citble:
	dw	citty		;Input from tty (000) 
	dw	cicrt		;Input from crt (001) 
	dw	ciusr		;Input from crt and modem (010) 
	dw	cicrt		;Input from crt (011)
	dw	cicrt		;Input from crt (100)

*
* console output table
*
cotble:
	dw	cotty		;Output to tty (000) 
	dw	cocrt		;Output to crt (001)
	dw	cousr		;Output to crt and modem (010)
	dw	cousr1		;Output to crt and remote system (011) 
	dw	codsk1		;Output to crt and disk file (100)

*
* list device table
*
ltble:
	dw	cotty		;Output to tty (000) 
	dw	cocrt		;Output to crt (001)
	dw	corem		;Output to remote system (010)
	dw	comod		;Output to modem (011)
	dw	codsk2		;Output to tty and disk file (100)
	dw	codsk3		;Output to disk file (101)

*
* punch device table
*

ptble:
	dw	comod		;Output to modem (0)
	dw	coclk		;Output to clock (1) 

*
* reader device table
*
rtble:
	dw	cimod		;Input from modem (0)
	dw	ciclk		;Input from clock (1)

*
* console status table
*
cstble:
	dw	cstty		;Status of tty (000)
	dw	cscrt		;Status from crt (001)
	dw	csusr		;Status from crt and modem (010)
	dw	cscrt		;Status from crt (011)
	dw	cscrt		;Status from crt (100)

*
* status from reader device
*
csrtble:
	dw	csmod		;Status from modem (0)
	dw	csclk		;Status from clock (1)

*
* Status from list device
*
lstble:
	dw	costty		;Status from tty (000)
	dw	coscrt		;Status from crt (001)
	dw	cosrem		;Status from remote system (010)
	dw	cosmod		;Status from modem (011)
	dw	costty		;Status from tty (100)
	dw	ready		;Status of disk file is always ready (101)


*****************************************************************
*								*
* Tinit can be modified for different I/O setups.		*
*								*
*****************************************************************
tinit:				;Initialize the terminal routine

;  Initialize I/O Byte
	mvi	a,intioby	;Initialize IOBYTE
	sta	iobyte

;  Initialize MPU Serial I/O Channel Characteristics and Baud Rate
	mvi	a,10$00$00$11b	;Access Divisor:
				;  10 -- Set divisor latch, clear break
				;  00 -- 0 parity bit, even parity (N/A)
				;  00 -- disable parity, 1 stop bit
				;  11 -- 8 Data Bits
	out	mpulcr		;To Line Control Register
	lxi	h,mpbrate	;HL = MPU Channel Baud Rate
	mov	a,l		;Set Low-Byte of Baud Rate
	out	mpudll		;To Divisor Latch Low
	mov	a,h		;Set High-Byte of Baud Rate
	out	mpudlh		;To Divisor Latch High
	mvi	a,00$00$01$11b	;Reset Divisor Access and Set Characteristics:
				;  00 -- Clear divisor latch, clear break
				;  00 -- 0 parity bit, even parity (N/A)
				;  01 -- disable parity, 2 stop bits
				;  11 -- 8 Data Bits
	out	mpulcr		;To Line Control Register
	xra	a		;A=0
	out	mpuier		;Disable All Interrupts in Interrupt Register
	out	mpustat		;Clear All Error Flags in Line Status Register
	mvi	a,0000$1111b	;3 Zeroes, No Loop, 1, Set RLSD, CTS, DSR
	out	mpupcr		;To Peripheral Control Register

;  Initialize Quad I/O Channel Characteristics
	mvi	a,10$11$01$11b	;General-Purpose Reset:
				;  10 -- 1 1/2 Stop Bits
				;  11 -- Even Parity, Enable Parity
				;  01 -- 6 Bits/Char
				;  11 -- 64x Baud Rate
	call	setquad		;Set All 4 Quad I/O Ports
	mvi	a,01$11$01$11b	;General-Purpose Reset:
				;  01 -- Disable Hunt, Internal Reset
				;  11 -- RTS High, Error Reset
				;  01 -- No Break, Enable RxRDY
				;  11 -- NOT DTR High, Enable TxEN
	call	setquad		;Set All 4 Quad I/O Ports
	mvi	a,11$00$11$10b	;Characteristics Set for All:
				;  11 -- 2 Stop Bits
				;  00 -- No Parity
				;  11 -- 8 Bits/Char
				;  10 -- 16x Baud Rate
	call	setquad		;Set All 4 Quad I/O Ports
	mvi	a,00$11$01$11b	;Characteristics Set for All:
				;  00 -- Disable Hunt, No Internal Reset
				;  11 -- RTS High, Error Reset
				;  01 -- No Break, Enable RxRDY
				;  11 -- NOT DTR High, Enable TxEN
	call	setquad		;Set All 4 Quad I/O Ports

;  Initialize Quad I/O Baud Rates
	mvi	a,q0brate	;Set USART 0 Baud Rate
	out	q0baud
	mvi	a,q1brate	;Set USART 1 Baud Rate
	out	q1baud
	mvi	a,q2brate	;Set USART 2 Baud Rate
	out	q2baud
	mvi	a,q3brate	;Set USART 3 Baud Rate
	out	q3baud

;  Clear Garbage Char from CRT
	call	cscrt		;Gobble up unwanted char
	ora	a		;A=0 if none
	cnz	cicrt		;Grab character
	ret

;  Set All Quad I/O Control Ports
setquad:
	out	q0stat		;USART 0
	out	q1stat		;USART 1
	out	q2stat		;USART 2
	out	q3stat		;USART 3
	xthl			;Long Delay
	xthl
	ret


*****************************************************************
*								*
*  NEWIO -- Set UC1: Device to the Device Drivers whose Jump	*
*	Table is Pointed to by HL				*
*								*
*  This Jump Table is structured as follows:			*
*	JMP ISTAT	<-- Input Status (0=No Char, 0FFH=Char)	*
*	JMP INPUT	<-- Input Character			*
*	JMP OUTPUT	<-- Output Character in C		*
*								*
*  The Base Address of this Jump Table (JBASE) is passed to	*
*	NEWIO in the HL Register Pair.				*
*								*
*****************************************************************
newio:
	shld	cstble+6	;Set UC1: Input Status
	lxi	d,3		;Prepare for offset to next jump
	dad	d		;HL points to next jump
	shld	citble+6	;Set UC1: Input Character
	dad	d		;HL points to next jump
	shld	cotble+6	;Set UC1: Output Character
	ret


*****************************************************************
*								*
*  Input Status, Input Character, and Output Character		*
*	Subroutines for CP/M					*
*								*
*****************************************************************
*								*
*  Input Status --						*
*	These routines return 0 in the A Register if no input	*
* data is available, 0FFH if input data is available.		*
*								*
*  Input Character --						*
*	These routines return the character (byte) in the A	*
* Register.  MSB is masked off.					*
*								*
*  Output Character --						*
*	These routines output the character (byte) in the C	*
* Register.							*
*								*
*****************************************************************

*****************************************************************
*								*
*  CRT Input Status, Input Character, and Output Character	*
*								*
*****************************************************************

cscrt	equ	$	;CRT Input Status
	lda	ustat	;Get Status
	cma		;Inverted Logic
	ani	istat	;Mask for input status and fall thru to 'STAT'
	jr	stat	;Set Flags

coscrt	equ	$	;CRT Output Status
	lda	ustat	;Get USART status
	cma		;Inverted Logic
	ani	ostat	;Mask for output status
	jr	stat	;Return

cicrt	equ	$	;CRT Input
	jmp	djcin	;Get char

cocrt	equ	$	;CRT Output
	jmp	djcout	;Put char

*****************************************************************
*								*
*  Modem Input Status, Input Character, and Output Character	*
*								*
*****************************************************************

csmod	equ	$	;Modem Input Status
	in	mods
	ani	mrda	;Data available?
	jr	stat

cosmod	equ	$	;Modem Output Status
	in	mods	;Get status
	ani	mtbe	;TBE?
	jr	stat

cimod	equ	$	;Modem Input Character
	call	csmod	;RDA? 
	jrz	cimod
	in	modd	;Get data
	ani	7fh	;Mask
	ret

comod	equ	$	;Modem Output
	call	cosmod	;TBE?
	jrz	comod
	mov	a,c	;Get char
	out	modd	;Put data
	ret

*****************************************************************
*								*
*  Clock Input Status, Input Character, and Output Character	*
*								*
*****************************************************************

csclk	equ	$	;TTY Input Status
	in	q1stat	;Get Status
	ani	qrda	;Data available?
	jr	stat

cosclk	equ	$	;TTY Output Status
	in	q1stat	;Get Status
	ani	qtbe	;TBE?
	jr	stat

ciclk	equ	$	;TTY Input Character
	call	csclk	;RDA?
	jrz	ciclk
	in	q1data	;Get data
	ani	7fh	;Mask
	ret

coclk	equ	$	;TTY Output Character
	call	cosclk	;TBE?
	jrz	coclk
	mov	a,c	;Get data
	out	q1data	;Put data
	ret

*****************************************************************
*								*
* This is a common return point to correctly set the return 	*
*    status flags; it is centrally located for the jump		*
*    relative instructions					*
*								*
*****************************************************************
stat:
	rz		;Nothing found
ready:
	mvi	a,0ffh	;Set A for negative status
	ret

*****************************************************************
*								*
*  TTY Input Status, Input Character, and Output Character	*
*								*
*****************************************************************

cstty	equ	$	;TTY Input Status
	in	q3stat	;Get Status
	ani	qrda	;Data available?
	jr	stat

costty	equ	$	;TTY Output Status
	in	q3stat	;Get Status
	ani	qtbe	;TBE?
	jr	stat

citty	equ	$	;TTY Input Character
	call	cstty	;RDA?
	jrz	citty
	in	q3data	;Get data
	ani	7fh	;Mask
	ret

cotty	equ	$	;TTY Output Character
	call	costty	;TBE?
	jrz	cotty
	mov	a,c	;Get data
	out	q3data	;Put data
	ret

*****************************************************************
*								*
*  Remote System Input Status, Input Character, and Output	*
*	Character						*
*								*
*****************************************************************

csrem	equ	$	;TTY Input Status
	in	q0stat	;Get Status
	ani	qrda	;Data available?
	jr	stat

cosrem	equ	$	;TTY Output Status
	in	q0stat	;Get Status
	ani	qtbe	;TBE?
	jr	stat

cirem	equ	$	;TTY Input Character
	call	csrem	;RDA?
	jrz	cirem
	in	q0data	;Get data
	ani	7fh	;Mask
	ret

corem	equ	$	;TTY Output Character
	call	coxoff	;Check for XOFF and process
	call	cosrem	;TBE?
	jrz	corem
	mov	a,c	;Get data
	out	q0data	;Put data
	ret
coxoff	equ	$	;Remote XOFF Check and Processing
	call	csrem	;Input Char from LST: Device?
	rz		;Zero if none
	call	cirem	;Get Char
	cpi	XOFF	;XOFF?
	rnz		;Return if not
	call	cirem	;Wait for Any Other Char
	ret

*****************************************************************
*								*
*  User-Defined (CRT and Modem) Input Status, Input Character,	*
*	and Output Character					*
*								*
*****************************************************************

csusr	equ	$	;User (CRT and Modem) Input Status
	call	cscrt	;Input from CRT?
	rnz		;Char found
	call	csmod	;Input from Modem?
	ret

cosusr	equ	cosmod	;Output status same as modem since modem is slower

ciusr	equ	$	;Modem/CRT Input Combination
	call	cscrt	;Input from CRT?
	jnz	cicrt	;Get char from CRT
	call	csmod	;Input from Modem?
	jnz	cimod	;Get char from Modem
	jr	ciusr	;Continue

cousr	equ	$	;Modem/CRT Output Combination
	call	comod	;Output to Modem
	jmp	cocrt	;Output to CRT

ciusr1	equ	$	;Modem/CRT Input w/CRT Output Combination
	call	ciusr	;Get char
	push	psw	;Save char in A
	mov	c,a	;Char in C
	call	cocrt	;Output to CRT
	pop	psw	;Restore char in A
	ret

cousr1	equ	$	;Remote System/CRT Output Combination
	call	corem	;Output to Remote System
	jmp	cocrt	;Output to CRT


*****************************************************************
*								*
*  Disk System Output Character					*
*	CODSK1 - CRT and Disk					*
*	CODSK2 - TTY and Disk					*
*								*
*****************************************************************

codsk1	equ	$	;CRT and Disk Output Character
	call	cocrt	;Send to CRT
	lxi	d,dsk1	;Disk 1 Parameters
	lda	clast	;Check last char for double <CR>
	cpi	cr
	jrz	codsk1a
	mov	a,c	;Set new last char
	sta	clast
	jr	codsk	;Output to Disk
codsk1a:
	mov	a,c	;Is this a <CR> also?
	cpi	cr
	rz
	sta	clast	;No, so set as new last and continue
	jr	codsk

codsk2	equ	$	;TTY and Disk Output Character
	call	cotty	;Send to TTY
	lxi	d,dsk2	;Disk 2 Parameters
	lda	tlast	;Check last char for double <CR>
	cpi	cr
	jrz	codsk2a
	mov	a,c	;Set new last char
	sta	tlast
	jr	codsk	;Output to Disk
codsk2a:
	mov	a,c	;Is this a <CR> also?
	cpi	cr
	rz
	sta	tlast	;No, so set as new last and continue
	jr	codsk

codsk3	equ	$	;Disk Output as Printer
	lxi	d,dsk2	;Disk 2 Parameters

codsk	equ	$	;Disk Output Character
	ldax	d	;Get Open Flag
	ora	a	;File Open?
	rz		;Done if Not
	lxi	h,0	;Save User Stack
	dad	sp
	shld	stack
	lxi	sp,stack	;Set Driver Stack
	push	b	;Save char in C
	push	d	;Save ptr to File Spec Block
	lxi	d,stksav	;Save User's Stack in case I'm in the BDOS
	lxi	b,stksiz	;Arbitrary
	ldir		;Copy
	pop	h	;Get HL as ptr to File Spec Block
	pop	b	;Get char in C
	push	h	;Save ptr to File Spec Block
	inx	h	;Pt to Buffer Address
	mov	e,m	;Get address
	inx	h
	mov	d,m
	xchg		;HL pts to next location
	mov	m,c	;Store Character
	inx	h	;Pt to following location
	xchg		;... in DE
	mov	m,d	;Store New Address
	dcx	h
	mov	m,e
	inx	h	;Pt to char count
	inx	h
	inr	m	;Increment char count
	mvi	a,128	;Buffer full?
	cmp	m	;It is if 128 characters are stored in it
	pop	h	;Get Ptr to File Spec Block
	jrnz	done	;Done if less than 128
	call	initfsb	;Init File Spec Block
	call	write	;Write Block to Disk
done:
	lhld	stack	;Restore User Stack
	sphl
	lxi	d,stksav	;Pt to User's Original Stack
	xchg		;HL is where user's stack once was
	lxi	b,stksiz	;Size of my Stack Save Area
	ldir		;Restore Original Stack
	ret
;
;  COPEN -- Open Console File for Output
;  LOPEN -- Open Printer File for Output
;
copen:
	lxi	d,fcb1	;Define Console File
	lxi	b,12	;12 bytes
	ldir		;Copy
	lxi	h,dsk1	;Pt to File Spec Block
	xra	a	;Set No Last Char
	sta	clast
	jr	open
lopen:
	lxi	d,fcb2	;Define Printer File
	lxi	b,12	;12 bytes
	ldir		;Copy
	lxi	h,dsk2	;Pt to File Spec Block
	xra	a	;Set No Last Char
	sta	tlast
;
;  Open Disk File for Output
;
open:
	push	h	;Save ptr to File Spec Block
	call	savud	;Save Current User and Disk as Home
	lda	disk	;Set Home Base User and Disk
	sta	hdisk
	lda	user
	sta	huser
	call	initfsb	;Init File Spec Block pted to by HL
	call	savenv	;Save Environment
	call	initfcb	;Clear FCB
	mvi	c,19	;Delete File
	push	d	;Save DE
	call	entry
	pop	d	;Get DE
	call	initfcb
	mvi	c,22	;Create File
	call	entry
	mvi	c,'M'	;Make error possible
	call	errchk	;Perform Error Check
	call	getenv	;Restore Environment
	pop	h	;Get Ptr to File Spec Block
	ret
;
;  Init File Spec Block pted to by HL
;	On input, HL pts to File Spec Block
;	On output, File Spec Block is initialized and HL pts to DMA Address
;
initfsb:
	mvi	m,0ffh	;Set File Open
	inx	h	;Skip Buffer Address
	mov	d,h	;DE=ptr to buffer address
	mov	e,l
	inx	h
	inx	h	;Pt to Byte Count
	mvi	m,0	;Init it to Zero
	inx	h	;Pt to DMA Address
	mov	a,m	;Set Buffer Address
	stax	d
	inx	h
	inx	d
	mov	a,m
	stax	d
	dcx	h	;Pt to DMA Address
	ret
;
;  Close Disk Files
;	CCLOSE -- CON file (DSK1)
;	LCLOSE -- LST file (DSK2)
;
cclose:
	lxi	h,dsk1	;Pt to File Spec Block
	jr	close
lclose:
	lxi	h,dsk2	;Pt to File Spec Block
close:
	push	h	;Save ptr
	inx	h	;Pt to Buffer Address
	mov	e,m	;Get it
	inx	h
	mov	d,m
	inx	h	;Pt to Byte Count
	mov	b,m	;Get it
	xchg		;HL pts to Buffer
close1:
	mvi	m,1AH	;EOF Char
	inx	h
	inr	b	;Buffer full?
	mvi	a,128	;Check
	cmp	b
	jrnz	close1
	pop	h	;Get ptr
	mvi	m,0	;Set Not Open
	inx	h	;Pt to DMA Address
	inx	h
	inx	h
	inx	h
	push	h	;Save ptr
	call	write	;Write Last Block
	pop	h	;Get ptr
	call	savenv	;Save User Environment
	mvi	c,16	;Close Disk File
	call	entry
	mvi	c,'C'	;Close error possible
	call	errchk	;Perform error check
	jmp	getenv	;Restore User Environment

;
;  Init FCB Pted to by DE and do not affect DE
;
initfcb:
	push	d	;Save Ptr
	xchg		;Ptr in HL
	mvi	m,0	;Clear Disk
	lxi	d,12	;Pt to EX Field
	dad	d
	mvi	b,24	;24 more bytes
ifcb:
	mvi	m,0	;Zero Fill
	inx	h	;Pt to Next
	djnz	ifcb
	pop	d	;Get Ptr
	ret

;
;  Write Block to File whose DMA Address is pointed to by HL
;
write:
	call	savenv	;Save Environment
	mvi	c,21	;Write Block
	call	entry
	mvi	c,'W'	;Write error possible
	call	errchk	;Perform error check
;
;  Get User Environment
;	This routine restores the User's User/Disk Flag and DMA Address
;
getenv:
	call	getud	;Reset User/Disk
	lhld	usrdma	;Reset User's DMA Address
	xchg
	mvi	c,26	;Set DMA
	call	entry
	ret
;
;  Save User Environment
;	This routine saves his DMA Address and User/Disk Flag
;	This routine sets the Disk I/O User/Disk Flag and DMA Address
;	   and returns with DE containing the address of the FCB
;	On input, HL pts to DMA Address entry in File Spec Block
;
savenv:
	call	savdma	;Save User's DMA Address
	call	savud	;Save Current User/Disk
	call	setfud	;Set User/Disk for Output File
	mov	e,m
	inx	h
	mov	d,m
	inx	h	;Pt to FCB
	push	h	;Save ptr
	mvi	c,26	;Set DMA
	call	entry
	pop	h	;Get ptr
	mov	e,m	;Get FCB Address in DE
	inx	h
	mov	d,m
	ret
;
;  Save Current User/Disk
;
savud:
	push	h	;Save Regs
	push	d
	push	b
	mvi	c,25	;Get Disk
	call	entry
	sta	disk
	mvi	c,32	;Get User
	mvi	e,0ffh
	call	entry
	sta	user
rexit:
	pop	b	;Restore Regs
	pop	d
	pop	h
	ret
;
;  Restore Current User/Disk
;
getud:
	push	h	;Save Regs
	push	d
	push	b
	lda	disk	;Select Disk
	mov	e,a
	mvi	c,14
	call	entry
	lda	user	;Select User
	mov	e,a
	mvi	c,32
	call	entry
	jr	rexit	;Exit and Restore Regs
;
;  Set User/Disk for File Output
;
setfud:
	push	h	;Save Regs
	push	d
	push	b
	lda	hdisk	;Select Home Disk
	mov	e,a
	mvi	c,14
	call	entry
	lda	huser	;Select Home User
	mov	e,a
	mvi	c,32
	call	entry
	jr	rexit	;Exit and Restore Regs
;
;  Save Current DMA Address
;
savdma:
	push	h
	lhld	biosdma	;Get Current DMA
	shld	usrdma	;Set User DMA
	pop	h
	ret
;
;  Check for A=0FFH and print error code in C if so
;
errchk:
	cpi	0ffh	;Error?
	rnz
err1:
	call	djcout	;Output Error Code
	mvi	c,7	;Ring Bell
	jmp	djcout
;
;  Buffers
;
dsk1:	db	0	;Not Open
	dw	dma1	;Buffer Address Set by Software
	db	0	;No Bytes Stored
	dw	dma1	;DMA Address
	dw	fcb1	;FCB Address

dsk2:	db	0	;Not Open
	dw	dma2	;Buffer Address Set by Software
	db	0	;No Bytes Stored
	dw	dma2	;DMA Address
	dw	fcb2	;FCB Address

	db	'End of SYSIO',0

	org	bufbase	;Scratch Area for Buffers

dma1:	ds	128	;DMA for Console
dma2:	ds	128	;DMA for Printer

disk:	ds	1	;Current Disk
user:	ds	1	;Current User
hdisk:	ds	1	;Home Disk
huser:	ds	1	;Home User
usrdma:	ds	2	;User DMA Address
fsbptr:	ds	2	;Ptr to File Spec Block
clast:	ds	1	;Last Char to CRT
tlast:	ds	1	;Last Char to PRT
fcb1:	ds	36	;CRT Disk Output FCB
fcb2:	ds	36	;TTY Disk Output FCB

	ds	100	;50-Element Local Stack
stack:	ds	2	;User Stack Ptr

stksav:	ds	stksiz	;User's Original Stack


	end
