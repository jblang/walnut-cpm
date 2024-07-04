;
;
;
;
REV     EQU     10              ;overlay revision level
;
; MEX STARPLEX OVERLAY VERSION 1.0: written 07/16/84 by Bill Meahan
;                                                       1951 S. Globe
;                                                       Westland, MI 48185
; I can also be contacted through MICROLINK-820 at:
;                 (313)487-0070 (24 hrs 300/1200 baud)
;
;
; This is a MEX overlay file for the National Semiconductor STARPLEX.
; Derived from the PMMI overlay by Ronald G. Fowler.
;
; This overlay should also work (except for the serial printer support) with
; systems based on the following single-board computers:
;                Intel          National
;                SBC80/20       BLC80/204
;                SBC80/20-4     BLC80/24
;                SBC80/24       BLC80/316
;                SBC80/30
;
; Intel development systems may have different addresses for the ports, but
; use the same arrangement of 8253 baud rate generators and 8251 USART's so
; this overlay should be EASILY adaptible to those systems as well.
;
;------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES     EQU     0FFH  
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
XON     EQU     011H
XOFF    EQU     013H
;
; STARPLEX port definitions  (serial port 1)
;
PORT    EQU     0ECH            ;STARPLEX base port (data or status)
MODCT1  EQU     PORT+1          ;modem control port
MODDAT  EQU     PORT            ;modem data port
MODCT2  EQU     PORT+1          ;modem status port
BAUDRP  EQU     0DDH            ;modem baud rate port
BAUDMD  EQU     0DFH            ;modem baud rate mode control port
;
; STARPLEX bit definitions
;
MDRCVB	EQU	02H		;modem receive bit (DAV)
MDRCVR	EQU	02H		;modem receive ready
MDSNDB	EQU	01H		;modem send bit
MDSNDR	EQU	01H		;modem send ready bit
;
; 
CTSMSK	EQU	4		;mask for CTS bit
BRKMSK  EQU     8               ;mask to set break
PARMSK	EQU	0CFH		;mask to remove parity bits
OPARIT  EQU     10H             ;odd-parity bits
EPARIT  EQU     30H             ;even-parity bits
NPARIT  EQU     00H             ;no-parity bits
PARTST  EQU     10H             ;mask to test parity enabled bit
EVNTST  EQU     20H             ;mask to test even parity bit
MODEMK  EQU     06EH            ;mode mask
MODEGO  EQU     027H            ;default control command
RSTCTL  EQU     040H            ;reset USART command
BITS7   EQU     08H             ;mask for 7 bit characters
BITS8   EQU     0CH             ;mask for 8 bit characters
BITS8T  EQU     04H             ;mask to test for 8 bit characters
STBIT1  EQU     040H            ;mask to set 1 stop bit
STBI15  EQU     080H            ;mask to set 1.5 stop bits   
STBIT2  EQU     0C0H            ;mask to set 2 stop bits
;
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately pre-
; ceeding the actual FCB (to contain user # information).  If you've
; used MEX-10 for input instead of BDOS-10 (or you're parsing part
; of a SET command line that's already been input), then MEX will
; take care of DU specs, and set up the FCB accordingly.  There-
; after all file I/O calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
;
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
	ORG	TPA		;we begin
;
;
	DS	3		;MEX has a JMP START here
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
STRPLX: DB      YES             ;yes=STARPLEX modem \ / These 2 locations are not
SMODEM: DB      NO              ;yes=Smartmodem     / \ referenced by MEX
        DB      0               ;spare
CLOCK:  DB      38              ;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST: DB      YES             ;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP
LOCNXT:	DB	NO		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	DB	NO		;yes=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of XOFF testing
IGNCTL:	DB	NO		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
; Equates used only by STARPLEX routines grouped together here.
;
        DB      0               ;not used
	DB	0		;not used
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
INCTL1:	IN	MODCT1		;in modem control port
	RET
        DB      0,0,0,0,0,0,0   ;spares if needed for non-STARPLEX
;
OTDATA:	OUT	MODDAT		;out modem data port
	RET
        DB      0,0,0,0,0,0,0   ;spares if needed for non=STARPLEX
;
INPORT:	IN	MODDAT		;in modem data port
	RET
        DB      0,0,0,0,0,0,0   ;spares if needed for non-STARPLEX
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
;
; Unused area: was once used for special STARPLEX functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *must* be 12 bytes.
;
	DS	12
;
; Special modem function jump table: 
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:  DS      3               ;dial digit in A (see info at PDIAL)
DISCV:  DS      3               ;disconnect the modem
GOODBV:	JMP	DUMMY		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV: JMP     DUMMY           ;set modem for no-parity
PARITV: JMP     DUMMY           ;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	PBREAK		;send a break
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
;
CLS:	LXI	D,CLSMSG		;null unless patched
	MVI	C,PRINT
	CALL	MEX
	RET
;
;------------------------------------------------------------
;
;       *** END OF FIXED FORMAT AREA ***
;
;------------------------------------------------------------
;
; Modem initialization.
;
NITMOD:    
        MVI     A,1             ;default to 300 baud on start-up
        CALL    PBAUD
        LDA     MODMOD          ;default mode command in A
ALTINI:                         ;alternate entry point for mode change routines
        PUSH    PSW             ;save mode command on stack
        XRA     A               ;force 8251 USART to look for reset command
        OUT     MODCT2
        OUT     MODCT2
        OUT     MODCT2
        MVI     A,RSTCTL        ;reset USART
        OUT     MODCT2
        POP     PSW             ;retreive mode command
        STA     MODMOD          ;save copy for future use
        OUT     MODCT2          ;set USART mode
        MVI     A,MODEGO        ;enable transmitter and receiver
        OUT     MODCT2
        RET
;
; STARPLEX send-break routine
;
PBREAK: LDA     MODCTB          ;get the last modem control byte
        ORI     BRKMSK          ;set the transmit break bit low
	OUT	MODCT2		;send it to the modem
        LXI     B,02FEH         ;B=2, C=254 
        CALL    MEX             ;send a space tone for 200 ms.
	LDA	MODCTB		;get the last modem control byte
	OUT	MODCT2		;restore to normal
;
; exit routine
;
DUMMY:	RET			;we don't need one
;
;
;
; Set baud-rate code in A 
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
        STA     MSPEED
        ADD     A               ;double value to get word address
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
        MOV     C,M             ;fetch code
        INX     H
        MOV     B,M
        MVI     A,076H
        OUT     BAUDMD          ;control counter
        MOV     A,C
        OUT     BAUDRP
        MOV     A,B
        OUT     BAUDRP          ;good rate, set it
PBEXIT: POP     B               ;all done
	POP	D
	POP	H
	RET
;
; table of baud rate divisors for supported rates
;
BAUDTB: DW      1048,384,256,192,162    ;110,300,450,610,710
        DW      96,48,24,12,6           ;1200,2400,4800,9600,19200
;
; Sign-on message
;
SYSVER:	LXI	D,SOMESG
	MVI	C,PRINT
	CALL	MEX
        RET
;
SOMESG: DB      'STARPLEX overlay By Bill Meahan V. '
        DB      REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	': $'
;
;
;
;
; Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		;align output character
	MVI	C,CONOUT	;print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
; strings to clear-to-end-of-screen, and clear-screen
;
EOSMSG: DB      09BH,'$'        ;clear to end-of-screen
CLSMSG: DB      09AH,'$'        ;clear whole screen
;
; Data area
;
ERRFLG:	DB	0		;connection error code
MODMOD  DB      MODEMK          ;uart-control byte image
BAUDSV: DB      01              ;current baud rate (dflt 300)
MODCTB: DB      MODEGO          ;modem control byte
;
;------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile
; SET command -- 
;
;
; Control is passed here after MEX parses a SET command.
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse command
	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.
;
; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
        DB      'PARIT','Y'+80H         ;"set parity"
        DW      SETPAR
        DB      'BIT','S'+80H           ;"set bits"
        DW      SETBIT
        DB      'STO','P'+80H           ;"set stop"
        DW      SETSTO
;
	DB	0		;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO: 
	LXI	H,SHOTBL	;get table of SHOW subroutines
SETSLP:	MOV	E,M		;get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		;end of table?
	ORA	E
	RZ			;exit if so
	PUSH	H		;save table pointer
	XCHG			;adrs to HL
	CALL	GOHL		;do it
	CALL	CRLF		;print newline
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
; table of SHOW subroutines
;
SHOTBL:	DW	BDSHOW
        DW      PARSHO
        DW      BITSHO
        DW      STOSHO
        DW      0               ;<<== table terminator
;
; SET ?  processor
;
STHELP:	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG: DB      CR,LF,'SET command, STARPLEX version:',CR,LF,LF
        DB      CR,LF,'SET BAUD 150 <or> 300 <or> 600 <or> 1200 <or> 2400'
        DB      CR,LF,'    <or> 4800 <or> 9600'
        DB      CR,LF,'SET PARITY ODD <or> EVEN <or> OFF'
        DB      CR,LF,'SET BITS 7 <or> 8'
        DB      CR,LF,'SET STOP 1 <or> 1.5 <or> 2'
        DB      CR,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX		;let MEX look up code
	JC	SETERR		;invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;not-supported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
; SET PARITY processor
;
SETPAR:
        LXI     D,PARTBL        ;point to argument table
        CALL    TSRCH           ;look for match with allowed arguments
        JC      SETERR          ;process error if found
        LDA     MODMOD          ;get current mode byte
        ANI     PARMSK          ;mask away current parity bits
        ORA     L               ;add new parity bits
        CALL    ALTINI
PARSHO:
        CALL    ILPRT           ;show current status
        DB      'Parity:',TAB,' ',0
        LDA     MODMOD          ;get current mode word
        ANI     PARTST          ;test for parity enabled
        JNZ     PAR             ;skip if it is
        CALL    ILPRT
        DB      'Off',0
        RET
PAR:
        LDA     MODMOD
        ANI     EVNTST          ;test mode byte for even parity
        JNZ     PAREVN          ;skip if it is
        CALL    ILPRT
        DB      'Odd',0
        RET
PAREVN:
        CALL    ILPRT
        DB      'Even',0
        RET
;
;PARITY argument table
;
PARTBL: DB      'OD','D'+80H
        DB      OPARIT,0
        DB      'EVE','N'+80H
        DB      EPARIT,0
        DB      'OF','F'+80H
        DB      NPARIT,0
        DB      0
;
;SET BITS processor
;
SETBIT:
        LXI     D,BITTBL        ;point to argument table
        CALL    TSRCH           ;look for match with allowed arguments
        JC      SETERR          ;process error if found
        LDA     MODMOD          ;get current mode command
        ANI     (NOT BITS8) AND 255     ;mask away current bits
        ORA     L               ;set new bits
        CALL    ALTINI          ;change mode
BITSHO:
        CALL    ILPRT           ;show current status
        DB      'Bits:',TAB,' ',0
        LDA     MODMOD          ;get current mode word
        ANI     BITS8           ;test for number of bits
        JZ      SETERR
        ANI     BITS8T           
        JNZ     B8              ;skip if it is
        CALL    ILPRT
        DB      '7',0
        RET
B8:
        CALL    ILPRT
        DB      '8',0
        RET
;
;BITS argument table
;
BITTBL: DB      '8'+80H
        DB      BITS8,0
        DB      '7'+80H
        DB      BITS7,0
        DB      0
;
;SET STOP processor
;
SETSTO:
        LXI     D,STPTBL        ;point to argument table
        CALL    TSRCH           ;look for match with allowed arguments
        JC      SETERR          ;process error if found
        LDA     MODMOD          ;get current mode command
        ANI     (NOT STBIT2) AND 255     ;mask away current bits
        ORA     L               ;set new bits
        CALL    ALTINI          ;change mode
STOSHO:
        CALL    ILPRT           ;show current status
        DB      'Stop Bits:',TAB,' ',0
        LDA     MODMOD          ;get current mode word
        ANI     STBIT2          ;test for number of bits
        JZ      SETERR
        RLC
        RLC
        ADD     A               ;form word table index
        LXI     H,STJTBL        ;get address of jump table
        ADD     L               ;point to address of proper routine
        MOV     L,A
        MVI     A,0
        ADC     H
        MOV     H,A
        MOV     A,M             ;get address of proper routine
        INX     H
        MOV     H,M
        MOV     L,A
        PCHL                    ;branch to proper routine
PRT1:
        CALL    ILPRT
        DB      '1',0
        RET
PRT2:
        CALL    ILPRT
        DB      '2',0
        RET
PRT15:
        CALL    ILPRT
        DB      '1.5',0
        RET
;
STJTBL:                         ;jump table for stop bit show routines
        DW      SETERR
        DW      PRT1
        DW      PRT15
        DW      PRT2
;
;STOP argument table
;
STPTBL: DB      '1'+80H
        DB      STBIT1,0
        DB      '1.','5'+80H
        DB      STBI15,0
        DB      '2'+80H
        DB      STBIT2,0
        DB      0
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;------------------------------------------------------------------------------
;
;The following routines are provided to support a printer
;on the second serial port of the STARPLEX II which is not
;supported (except for USART initialization at 1200 baud)
;by the STARPLEX CP/M BIOS. The routine here also implements
;XON-XOFF support which is provided by many printers.
;(e.g. LA100, TI820, etc.)
;
;At my installation, there is no need to change baud rates, parity, etc
;but if you need to do so, just duplicate the appropriate routines
;from the SET command. I'd suggest then using SET PRINTER BAUD or equal
;to go to the proper routines. The baud rate counter for port 2 is 
;counter 2 of the 8253 rather than counter 1. (Code 0B6H instead of 076H
;in PBAUD). Port addresses shown below.
;
;You do not need anything from here to the END statement UNLESS you DO want
;to support a serial printer on port 2 of a STARPLEX II. For systems other
;than STARPLEX II, (i.e. one built upon one of the SBC or BLC series boards)
;delete this stuff!
;
PTRSTP  EQU     0EFH            ;USART status port address
PTRDTP  EQU     0EEH            ;  "    data   "    "
PTROKP  EQU     001H            ;mask for transmit busy status bit
PTRINC  EQU     002H            ;mask for receiver ready status bit
;
OKPRNT: DB      0FFH            ;OK to PRiNT flag. OK=0FFH Hold=0
;
PTRTST:                         ;printer  status routine
        PUSH    B               ;save b-c registers for MEX
        IN      PTRSTP          ;get USART status
        MOV     B,A             ;save a copy in b register
        ANI     PTRINC          ;character in?
        JZ      TSTPST          ;just skip and test status if not
        IN      PTRDTP          ;get character
        CPI     XON             ;XON character
        JNZ     ISXOFF          ;skip if not
        MVI     A,0FFH          ;set OK flag
        STA     OKPRNT
        JMP     PSTTST          ;skip to status test
ISXOFF: CPI     XOFF            ;XOFF character?
        JNZ     TSTPST          ;skip to status test if not (ignore)
        XRA     A               ;reset flag
        STA     OKPRNT
        JMP     PSEXIT          ;then exit- a is already zero indicating hold
TSTPST:  
        LDA     OKPRNT          ;get hold flag
PSTTST:  
        ORA     A               ;test for hold
        JZ      PSEXIT          ;exit if OK flag false (0)
        MOV     A,B             ;test actual USART transmitter status
        ANI     PTROKP
        JZ      PSEXIT          ;exit if not ready
        MVI     A,0FFH          ;MEX wants to see an FF if ok to print
PSEXIT: POP     B               ;restore saved registers
        RET                     ;return to MEX
;
PTROUT: OUT     PTRDTP          ;shove character out to printer
        RET
;
;
; Patches to MEX for STARPLEX system. (primarily adds vectors for serial
;                                      printer support)
;
	ORG	0D00H		;location of patch variables
;
;
;
; The following line defines the MEX service call entry point, and
; is not meant to be changed by the user
;
        DS      3               ;MEX service call processor
        DS      3               ;reserved
        DS      1               ;reserved
;
; The following line contains the initial free-memory pointer for
; MEX.  Sophisticated modem overlays requiring additional space may change
; this pointer (ie, move it higher), and thus "protect" an area of RAM.
;
        DS      2               ;first free memory pointer
;
; Following are the lowest-level vectors for console and list I/O used
; by MEX.  These normally point to routines that save the registers and
; vector to the appropriate BIOS routines.  Complex applications may
; need to intercept (or even replace) these routines.  If you do this,
; be sure to preserve DE, HL and BC.
;
        DS      2               ;console status vector
        DS      2               ;console input vector
        DS      2               ;console output vector
        DW      PTROUT          ;list output vector  (points to local routine)
        DW      PTRTST          ;list status vector  (points to local routine)
;
; The following line defines the location of the default MEX prompt.
; If you'd like to provide your own initial prompt, add a DW statement
; pointing to a prompt buffer structured as follows:
;
;		DB <max size of buffer>
;		DB <length of actual prompt>
;		DB <prompt string>
;
; <maxsize> and <length> may be equal (especially if you disable the
; ID command by setting CHGPMT, below to 0); the ID command will, if
; left enabled, be limited to the <max size> value.
;
        DS      2               ;prompt location
        DS      1               ;reserved
        DB      24              ;for TYPE command: # lines/screen
        DB      1               ;for TYPE cmd: 1=pause 0=no pause
        DB      ';'             ;multiple command-line separator
;
; following five for SENDOUT command
;
        DB      4               ;# seconds waiting for a sendout echo
        DB      8               ;# seconds waiting for initial reply
        DB      '>'             ;sendout trigger char from remote
        DB      'U'-64          ;sendout char to cancel line to remote
        DB      6               ;sendout # retries
;
;
        DB      0               ;hex/decimal mode
        DB      01BH            ;terminal mode escape char (01BH = ESC)
        DB      0               ;set to 1 to disable bell
;
; Buffer variables.  See BUFFERS.DOC for setup information
;
        DB      2               ;default=2k
        DB      255             ;"big" capture buffer
        DB      16              ;16K transfer buffer
        DB      1               ;1k for 85 batch files
        DB      40              ;maximum length of PREFIX string
        DB      40              ;maximum length of SUFFIX string
;
; Misc. stuff
;
        DB      0               ;non-zero for CDOS
        DB      0               ;non-zero sets "wait-for-echo"
        DW      400             ;size of keystring area, in bytes
        DB      1               ;non-zero allows CIS file transfers
        DB      1               ;non zero allows STAT CIS ON or OFF
        DB      1               ;non-zero allows ID (prompt chg) command
        DB      1               ;non-zero prints ID msg in err msgs
;
; by setting the following DB to 0, you can disable the HELP
; command, freeing up space used by the help file index.
;
        DB      1               ;non-zero allows HELP command
        DB      0               ;user \/  alternate area for READ,LOAD,INI.MEX
	DB	0		;drive/\  & HELP.MEX (if SEARCH <>0)
        DB      0               ;debugging in term-mode if non-zero
        DB      1               ;non-0 excludes $SYS from batchsend, dir
        DB      0               ;non-zero runs INI.MEX (if present) at startup
        DB      1               ;receiver wait: # seconds [Plouff patch]
        DW      150             ;size of the modem-port queue
        DB      30              ;phone library size (# entries)
        DB      0FFH            ;0=silence multi-line & READ cmd echo
        DB      255             ;alert-bell count on CALL complete
        DB      0               ;non-zero: unknown commands goto READ processor
        DB      0               ;non-zero: splits phonelib printout, shows baud
        DB      0               ;search mode 0,1,2,3
;
; Following is the GLOBAL secondary options table.  To
; set an option to global, change its ASCII character to a 0.
;
        DB      'BDLQRSTVX'
;
;
;
;------------------------------------------------------------
;
; End of STARPLEX MEX modem overlay and patches
;
;------------------------------------------------------------
;
        END
