;********************************* EPSNLINK.ASM
;        EPSON FILINK FOR CP/M SYSTEMS        *
;**********************************************
;
;                    12/23/84
;
; EPSNLINK (EPSLNK.ASM ON COMPUSERVE) is a communications
; program for CP/M machines that allows them to communicate
; with the EPSON PX-8 GENEVA using it's built-in program
; FILINK.COM permitting file transfer between machines
; using the ROM program in the GENEVA thereby always having
; available on board the GENEVA a means of communications
; without using valuable ram for a separate program.  It
; presents the same options in the same manner as FILINK
; making the human interface to each machine the same.
; Provisions are made in this source code to change the
; baud rate of the CP/M machine on entry to those of the
; GENEVA and to re-establish a default baud rate on exit.
; This requires software control of the baud rate on the
; CP/M machine which in this code requires the output of
; several bytes to several different ports.  Since my 'BIG'
; CP/M machine has a DCE serial port I use the 724 cable
; between the GENEVA and a switch box which is connected
; to the CP/M port.  If your CP/M thinks it is 'DATA
; TERMINAL EQUIPMENT' (DTE) use the 725 cable.
;    The program can be assembled using DRI's standard
; ASM.COM.  A knowledge of your machines ports & ready
; masks is required.  The I/O routines are at the beginning
; of the code ala XMODEM.  Any one who has configured one
; of the XMODEM programs should have no problem...novices
; will need some help.
;                              Community Business Systems
;                              Jim Dorsey (75765,317)
;
; 12/23/84...CONVERTED FROM Z80 TO 8080 MNEMONICS.
; 12/22/84...MOVE PORT I/O TO PROGRAM FRONT FOR
;            USER PATCHING IF NO ACCESS TO SOURCE CODE.
; 12/20/84...RENAME SYMBOLS.
; 10/20/84...INITIAL ASSY.
;
	.ORG	0100H
;
	JP	START
;
;**********************************************
;
; ASCII EQUATES
;
STX	.EQUAL	02
ETX	.EQUAL	03
EOT	.EQUAL	04
ENQ	.EQUAL	05
BELL	.EQUAL	07
BS	.EQUAL	08
TAB	.EQUAL	09
LF	.EQUAL	0AH
CR	.EQUAL	0DH
XOFF	.EQUAL	13H
EOF	.EQUAL	1AH
ESC	.EQUAL	1BH
RUB	.EQUAL	7FH
TRUE	.EQUAL	0FFFFH
FALSE	.EQUAL	TRUE+01
;
; CP/M COMMANDS
;
DIRCON	.EQUAL	06
DRESET	.EQUAL	13
SELDRV	.EQUAL	14
OPNFIL	.EQUAL	15
CLSFIL	.EQUAL	16
SCHFIL	.EQUAL	17
SCHNXT	.EQUAL	18
DELFIL	.EQUAL	19
REDNXT	.EQUAL	20
WRTNXT	.EQUAL	21
MAKFIL	.EQUAL	22
RENFIL	.EQUAL	23
SETDMA	.EQUAL	26
;
; CP/M ADDRESSES
;
BOOT	.EQUAL	0000
CURDSK	.EQUAL	0004
BDOS	.EQUAL	0005
FCB	.EQUAL	005CH
DBUF	.EQUAL	0080H
TPA	.EQUAL	0100H
;
; PROGRAM DEPENDENT EQUATES
;
WAITIM	.EQUAL	5000		;TIME TO WAIT FOR OTHER CHAR
MAXDRV	.EQUAL	'C'		;MAX DRIVE ON SYSTEM
;
;----------------------------------------------
;
; MODEM PORT EQUATES
;
MSTATP	.EQUAL	06H		;MODEM STATUS PORT
MDMTBE	.EQUAL	04H		;MODEM SEND BIT MASK (TBE)
SNDRDY	.EQUAL	00H		;MODEM SEND READY
				;00/MDMTBE=RDYHI/RDYLO
MDMRDA	.EQUAL	01H		;MODEM RECEIVE BIT MASK (RDA)
RECRDY	.EQUAL	00H		;MODEM RECEIVE READY
				;00/MDMRDA=RDYHI/RDYLO
MIDATA	.EQUAL	04H		;MODEM DATA IN PORT
MODATA	.EQUAL	04H		;MODEM DATA OUT PORT
;
;**********************************************
;
; MODEM PORT I/O ROUTINES
;
; RETURN 00/NZ = MODEM INPUT NOT/READY
;
MDMIST:	IN	A,(MSTATP)	;GET STATUS BYTE
	AND	MDMRDA		;GET STATUS BIT
	XOR	RECRDY		;TEST...RECEIVE DATA AVAILABLE?
	LD	A,00		;SET NO
	RET	Z 		;NO
	DEC	A		;SET NZ...
	RET			;YES
;
;----------------------------------------------
;
; GET MODEM CHAR
;
GTMCHR:	IN	A,(MIDATA)
	RET	
;
;----------------------------------------------
;
; RETURN 00/NZ = MODEM OUTPUT PORT NOT/READY
;
MDMOST:	IN	A,(MSTATP)	;GET STATUS BYTE
	AND	MDMTBE		;GET STATUS BIT
	XOR	SNDRDY		;TEST...TRANSMIT BUF EMPTY?
	LD	A,00		;SET NO
	RET	Z 		;NO
	DEC	A		;SET NZ...
	RET			;YES
;
;----------------------------------------------
;
; SEND CHR IN <E> TO MODEM
;
MDMOUT:	LD	A,E
	OUT	(MODATA),A
	RET	
;
;**********************************************
;
; AUTOMATIC BAUD RATE SET PROCEDURE & TABLE
;
; If your system supports software baud rate
; control EPSNLINK can set the system baud rate to
; match the GENEVA's baud rate at run time and
; reset the host system to it's normal setting
; when it terminates.  In this system the normal
; baud is 1200 for a printer and the GENEVA is
; set for 9600.  Look at 'IF DOBAUD' for the
; manner in which the program uses the following
; table.  Also change the 'BITMS1' & 'BITMS2'
; messages to reflect the bauds that you use.
;
DOBAUD	.EQUAL	FALSE	;IF BAUD SET ACTIVE
;
; BAUD RATE STRINGS
;
;B###:	DEFB	BYTE COUNT,PORT1,BYTE1,PORT2,BYTE2,etc
;
B110:	.BYTE	04,084H,001H,085H,001H,000H,000H
B300:	.BYTE	04,084H,001H,085H,004H,000H,000H
B1200:	.BYTE	04,084H,001H,085H,008H,000H,000H	;2 STPBITS
B2400:	.BYTE	04,084H,001H,085H,010H,000H,000H
B4800:	.BYTE	04,084H,001H,085H,020H,000H,000H
B9600:	.BYTE	04,084H,011H,085H,088H,000H,000H	;1 STPBIT
B19200:	.BYTE	04,084H,011H,085H,010H,000H,000H
;
BAUD1	.EQUAL	B9600		;START BAUD
BAUD2	.EQUAL	B1200		;END BAUD
;
;**********************************************
:START1
;
; NOTE: The following code intercepts the CP/M
; boot vector at 0000H to trap any '^C's for
; an orderly exit after resetting the original
; baud rate.  If the host machine detects '^C's
; and reboots from ROM as does the GENEVA a more
; complex boot intercept is required.  I have
; code that will intercept a warm start in the
; GENEVA which can give a clue for doing it in
; other ROM based CP/M systems.  If you are running
; standard RAM based CP/M the following code should
; be ok.
;
;
;**********************************************


START:  LD     C,6             ;INIT PORT
        LD     A,(L03D1)       ;BYTE COUNT
        LD     B,A
        LD     HL,L03D2	        ;03D2H
;
; 8080 EMULATOR FOR Z80 OTIR INSTRUCTION
;
OTIR:   LD     A,C
        LD     (PORT+1),A      ;MODIFY PGM
;
; LOOP & OUTPUT
;
OUTLOP: LD     A,(HL)
        INC     HL
PORT:   OUT     (00),A          ;MODIFIED ABOVE TO PORT ADDR
        DEC     B
        JP      Z,OUTLOP          ;NO
        JP      P,START1          ;NOW START PROGRAM


;
; KAYPRO PORT INIT BYTES
;
L03D1:  .BYTE	09H             ;# BYTES TO OUTPUT
;
L03D2:  .BYTE	00011000B       ;RESET
        .BYTE	04H             ;REGISTER 04
        .BYTE	01000111B       ;X16 CLOCK, 1 STOP BIT, EVEN PARITY
        .BYTE	01H             ;REGISTER 01
        .BYTE	00000000B       ;FOR SAFETY, RESET IT (?)
        .BYTE	03H             ;REGISTER 03
        .BYTE	10000001B       ;7 BIT, READ ENABLE
        .BYTE	05H             ;REGISTER 05
        .BYTE	00101000B       ;7 BIT, TRANSMIT ENABLE
;
; OLD START LOCATION

START1
:	LD	HL,(BOOT+01)	;GET BOOT ADDR
	INC	HL
	LD	(BOTADR+01),HL	;SAVE IT
	LD	BC,EXIT		;EXIT ADDR
	LD	E,(HL)		;GET BOOT VECTOR...
	LD	(HL),C		;STO EXIT VECTOR...
	INC	HL
	LD	D,(HL)		;TO TRAP '^C'S
	LD	(HL),B
	EX	DE,HL		;GET VECTOR
	LD	(BOTVEC+01),HL	;SAVE IT
	LD	SP,STACK
;
; RESTART ON ESC
;
RESTRT:	LD	DE,HELLO	;'FILINK (c) Copyright 1983'
	CALL	PRTDE		;PRINT DE->'$'
	LD	B,05		;TIME TO WAIT
	LD	C,0FFH		;WAIT FOR CONS INP
	CALL	CKOTHR		;DO TIME OUT
	.IFNZ	DOBAUD
	 LD	DE,STATMS	;'The RS-232C status is :'
	 CALL	PRTDE		;PRINT DE->'$'
	 LD	DE,BITMS1	;'bit rate =...'
	 CALL	PRTDE		;PRINT DE->'$'
	 LD	HL,BAUD1	;POINT TO START BAUD STRING
	 LD	A,(HL)		;GET LGT
	 OR	A		;CLR CRY
	 RRCA			;LGT/2
	 LD	B,A
	 INC	HL
	 JP	C,OPTLOP		;ODD # NO GOOD
	 JP	Z,OPTLOP		;NO STRING
	 CALL	OUTI		;LOOP & SET BAUD
	.ENDIF	
;
; LOOP FOR NEXT OPERATION
;
OPTLOP:	LD	SP,STACK
	LD	DE,HLPMS1	;0,0,'Press  ESC to restart,'
	CALL	PRTDE		;PRINT DE->'$'
	LD	DE,SRMSG	;'Send or Receive  (S/R) ? $'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP FOR VALID OPTION
;
BADOPT:	CALL	GETCON		;LD <A> & <E> WITH CONSOLE INP
	CALL	MAKEUC		;MAKE <A> UC
	LD	(USROPT),A	;USER OPTION: S/R
	CP	'S'		;SEND?
	JP	NZ,CHKRCV		;NO
	CALL	DCONIO		;PRINT <E> TO CONS
	CALL	GFNSND		;GET FILENAME(S) & SEND
	JP	GETOPT		;DONE A SEND, GET C/X
;
;----------------------------------------------
;
; NOT S(end)
;
CHKRCV:	CP	'R'		;RECEIVE?
	JP	NZ,BADOPT		;NO, GET 'S'/'R'
	CALL	DCONIO		;YES, PRINT <E> TO CONS
	CALL	GFNRCV		;RECEIVE FILES
;
; LOOP FOR 'X' (EXIT)/'C' (CONTINUE)
;
GETOPT:	CALL	GETCON		;LD <A> & <E> WITH CONSOLE INP
	CALL	MAKEUC		;MAKE <A> UC
	CP	'C'
	JP	NZ,CHKXIT
	CALL	DCONIO		;PRINT <E> TO CONS
	JP	OPTLOP		;LOOP FOR NEXT OPERATION
;
;----------------------------------------------
;
; NOT 'C'ontinue...CHECK FOR EXIT
;
CHKXIT:	CP	'X'		;EXIT?
	JP	NZ,GETOPT		;NO, WAIT FOR 'X'/'C'
	CALL	DCONIO		;PRINT <E> TO CONS
	JP	CLCXIT		;CLEAR CONS INP & QUIT
;
;**********************************************
;
; SEND FILE(S)
;
GFNSND:	CALL	GETFNT		;GET REQ FN.T & PARSE INTO SYSFCB
	CALL	CRLF		;PRINT CRLF
	LD	C,SCHFIL
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	CP	04		;FILE FOUND?
	JP	C,FILFND		;YES
	LD	DE,NFILMS	;'  File not found$'
	CALL	PRTDE		;PRINT DE->'$'
	JP	GFNSND		;LOOK AGAIN
;
;----------------------------------------------
;
; FOUND 1ST FILE...STORE LIST OF FN.T'S TO SEND
;
FILFND:	LD	HL,FLNLST	;FILENAME LIST BUFFER
	LD	(FLNPTR),HL	;FILENAME LIST POINTER
;
; LOOP FOR NEXT FILE & ADD TO LIST
;
FILOOP:	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A		;PNT TO ENTRY...
	LD	C,A
	LD	B,00
	LD	HL,DBUF+01	;PNT TO DIR REC START
	ADD	HL,BC		;WITH HL
	PUSH	HL
	EX	DE,HL
	LD	HL,(FLNPTR)     ;PNT TO NEXT STO POSN
	EX	DE,HL
	POP	HL
	LD	BC,0011
	CALL	LDIR		;STORE NAME
	PUSH	HL
	EX	DE,HL
	LD	(FLNPTR),HL	;NEXT STORAGE POSN
	EX	DE,HL
	POP	HL
	LD	A,(FILCNT)	;EXT COUNT
	INC	A		;+01
	LD	(FILCNT),A	;EXTENT COUNT
	CP	65		;DONE 64?
	JP	NC,DONALL		;YES, DONE PRINT '#T$' & CLOSE FILES
	LD	C,SCHNXT	;NO
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	CP	04		;FOUND FILE
	JP	C,FILOOP		;YES, STORE NEXT
	LD	HL,FLNLST	;RE-INIT...
	LD	(FLNPTR),HL	;FILENAME LIST POINTER
	LD	B,10		;TIME TO WAIT
	LD	C,'R'		;CHECK FOR 'S'END...(RCR RDY)
	CALL	CKOTHR		;WAIT/TIME OUT
	OR	A		;RECEIVER READY?
	JP	NZ,SENDAG		;YES, SEND 'G'
	LD	DE,RNRMSG	;'Receiver is not ready.',0,'$'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP & SEND 'R'eady & WAIT FOR 'S'end
;
GETSOK:	LD	E,'R'
	CALL	SENDE		;SEND CHAR IN <E>	('R'EADY-->)
	CALL	CHKABT
	CALL	MDMIST		;GET OTHER'S INPUT STATUS
	JP	Z,GETSOK		;OTHER NOT READY
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	('S'END <--)
	CP	'S'		;OK TO SEND?
	JP	NZ,GETSOK		;NO
;
; RECEIVER READY...SEND 'G'ood
;
SENDAG:	LD	E,'G'
	CALL	SENDE		;SEND CHAR IN <E>	('G'OOD-->)
;
; LOOP FOR NEXT FILE TO SEND
;
SNDLOP:	LD	HL,(FLNPTR)	;FILENAME LIST POINTER
	LD	DE,FCB+01
	LD	BC,0011
	CALL	LDIR		;GET NEXT FILENAME
	LD	(FLNPTR),HL	;FILENAME LIST POINTER
	CALL	CLRFCB		;CLR SYS FCB 'ex' -> 'nc'
	LD	C,OPNFIL	;OPEN SEND FCB
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	INC	A		;FOUND IT?
	LD	DE,CRMSG
	JP	Z,CLFILS		;NO, DONE
;
; CURRENT FN.T OPEN...SEND 'eot'
;
SNDEOT:	CALL	CHKABT		;QUIT IF TOO LONG
	LD	E,EOT		;GET 'eot'...FILENAME NEXT
	CALL	SENDE		;SEND CHAR IN <E>	(EOT -->)
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(08/'X' <--)
	CP	08		;SEND FILENAME?
	JP	NZ,SNDEOT		;NO, SEND 'eot'
	CALL	CRLF		;YES, PRINT CRLF
	LD	HL,FCB+01
	LD	B,11
;
; LOOP, SEND FN.TYP & PRINT TO CONSOLE
;
SNDFNT:	LD	E,(HL)
	CALL	SENDE		;SEND CHAR IN <E>	(FN.T -->)
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(FN.T <--)
	CP	E		;SAME?
	JP	NZ,SAYWHA		;NO, PRINT '?'
	LD	A,E		;GET CHAR
	AND	7FH		;STRIP PARITY
	LD	E,A		;GET CHAR
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	A,B
	CP	04		;4 CHARS LEFT?
	JP	NZ,DONPRD		;NO
	LD	E,'.'		;YES, PRINT '.' TO CONS
	CALL	DCONIO		;PRINT <E> TO CONS
;
; ANY '.' PRINTED TO CONS
;
DONPRD:	INC	HL
	DEC	B
	JP	NZ,SNDFNT		;NOT 11 CHARS, NOT DONE
	LD	E,ENQ		;END OF FN SEND 'enq'
	CALL	SENDE		;SEND CHAR IN <E>	(ENQ -->)
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(09  <--)
	CP	09		;09...READY FOR FILE?
	JP	NZ,SNDEOT		;NO...RESEND FN.T
	JP	PRTSND		;YES, SEND FILE
;
;----------------------------------------------
;
; BAD FILENAME CHAR ECHOED BACK
;
SAYWHA:	LD	E,'?'
	CALL	DCONIO		;PRINT <E> TO CONS
	JP	SNDEOT		;RESEND FN.T
;
;----------------------------------------------
;
; PRINT 'SENDING' & SEND
;
PRTSND:	LD	DE,SNDMSG	;'   Sending $'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP FOR NEXT SECTOR TO SEND
;
SNXTSC:	LD	C,SETDMA
	LD	DE,DBUF
	CALL	BDOS
	LD	C,REDNXT
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	OR	A		;OK READ?
	JP	NZ,DONSND		;NO, DONE
;
; LOOP & SEND 'stx' & SAME BLOCK
;
SNDSTX:	LD	E,STX
	CALL	SENDE		;SEND CHAR IN <E>	(STX -->)
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	('N'/'P'ROCEED <--)
	CP	'P'		;'P'ROCEED?
	JP	NZ,SNDSTX		;NO
	LD	E,'.'		;YES
	CALL	DCONIO		;TELL CONSOLE
	LD	HL,DBUF
	LD	C,00		;INIT CHKSUM
	LD	B,128		;BYTE COUNT
;
; LOOP & SEND 128 BYTES
;
SNDBLK:	LD	E,(HL)		;GET CHAR
	CALL	SENDE		;SEND CHAR IN <E>	(BLOCK -->)
	LD	A,E		;GET CHAR
	XOR	C		;TO CHKSUM
	LD	C,A		;RESTO CHKSUM
	INC	HL		;BUMP PNTR
	DEC	B
	JP	NZ,SNDBLK		;NOT 128 YET
	LD	E,C		;GET CHKSUM
	CALL	SENDE		;SEND CHAR IN <E>	(CHKSUM -->)
;
; LOOP & WAIT FOR 'B'/'G'
;
GODBAD:	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	('B'/'G' <--)
	CP	'B'		;'B'AD?
	JP	Z,SNDSTX		;YES, RESEND 'stx' & SAME BLOCK
	CP	'G'		;NO, 'G'OOD?
	JP	Z,SNXTSC		;YES, GET NEXT SECTOR
	JP	GODBAD		;WAIT SOME MORE
;
;----------------------------------------------
;
; END OF FILE
;
DONSND:	LD	E,ETX		;'etx'...END OF FILE
	CALL	SENDE		;SEND CHAR IN <E>	(ETX -->)
	CALL	FILCLS		;CLOSE FILE
	JP	NZ,SENDOK		;OK CLOSE
;
; BAD CLOSE...LOOP FOR CONS CHAR
;
SNDNOK:	LD	E,0FFH
	CALL	DCONIO		;GET CONS INP
	OR	A		;ANY CHAR?
	JP	Z,SNDNOK		;NO
;
; CURRENT FILE CLOSED
;
SENDOK:	LD	HL,FILCNT	;FILE COUNT
	DEC	(HL)		;DONE?
	JP	NZ,SNDLOP		;NO
	LD	E,XOFF		;YES, 'xoff'...DONE
	CALL	SENDE		;SEND CHAR IN <E>	(XOFF -->)
	CALL	CRLF		;PRINT CRLF
	LD	DE,DONMSG	;'Done',00,EXIT OR CONTINUE'
	CALL	PRTDE		;PRINT DE->'$'
	RET	
;
;**********************************************
;
; RECEIVE FILE(S)
;
GFNRCV:	CALL	GETFNT		;GET REQ FN.T & PARSE INTO SYSFCB
	CALL	CRLF		;PRINT CRLF
	LD	C,DRESET
	CALL	BDOS		;RESET SYSTEM
	LD	C,SELDRV
	LD	HL,CURDSK
	LD	E,(HL)
	CALL	BDOS		;SELECT CCP DRIVE
	LD	HL,FCB		;PNT TO REQUESTED FN.T
	LD	DE,CURFNT	;PLACE TO STORE IT
	LD	BC,0012
	CALL	LDIR		;GET REQ FN.T FCB TO CURFNT
	LD	A,(FNTOUS)	;00/NZ=USE SENT/REQ FN.T
	LD	(ENTFLG),A	;CUR FN.T TO USE FLAG
	LD	B,10		;TIME TO WAIT
	LD	C,00		;WAIT FOR 'R' (SNDR RDY) FROM OTHER
	CALL	CKOTHR		;WAIT/TIME OUT
	OR	A		;SENDER READY?
	JP	NZ,SNDSND		;YES
	LD	DE,SNDRMS	;'Sender $'
	CALL	PRTDE		;PRINT DE->'$'
	LD	DE,NRDYMS	;'is not ready.',0,'$'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP FOR 'R'eady FROM SENDER
;
GETRDY:	CALL	MDMIST		;GET OTHER'S INPUT STATUS
	JP	Z,GETRDY		;PORT NOT READY
	CALL	CHKABT
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	('R'EADY <--)
	CP	'R'		;'R'EADY?
	JP	NZ,GETRDY		;NO
;
; SENDER READY...SEND 'S'end TO SENDER
;
SNDSND:	LD	E,'S'
	CALL	SENDE		;SEND CHAR IN <E>	('S'END -->)
;
; LOOP FOR 'G' FROM SENDER
;
GTGOOD:	CALL	CHKABT
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	('G'OOD <--)
	CP	'G'
	JP	NZ,GTGOOD
;
; LOOP FOR NEXT FILE RECEIVE
;
GTFLOP:	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(XOFF/EOT <--)
	CP	XOFF		;'xoff'...END OF XFRS?
	JP	NZ,GTAFIL		;NO
	CALL	CRLF		;YES, PRINT CRLF
	LD	DE,DONMSG	;'Done',00,EXIT OR CONTINUE'
	CALL	PRTDE		;PRINT DE->'$'
	RET			;DONE RECEIVE SESSION
;
;----------------------------------------------
;
; READY TO RECEIVE (NEXT) FILE...SET UP SYSTEM FCB
;
GTAFIL:	LD	DE,FCB		;SYSTEM FCB
	LD	HL,CURFNT	;PNT TO REQ FN.T
	LD	BC,0012
	CALL	LDIR		;GET IT TO SYSFCB
	PUSH	AF		;SAVE CHAR
	LD	A,(ENTFLG)	;CUR FN.T TO USE FLAG
	LD	(FNTOUS),A	;00/NZ=USE SENT/REQ FN.T
	POP	AF
	CP	EOT		;'eot'?
	JP	Z,FNNEXT		;YES, GET SNDRS FCB TO SNDFCB
	LD	E,A		;NO, GET CHAR (?)
	CALL	DCONIO		;PRINT <E> TO CONS
;
; BAD FN...SEND 'X'
;
BADFLN:	LD	E,'X'
	CALL	SENDE		;SEND CHAR IN <E>	(X -->)
	JP	GTFLOP		;RESTART FILE TRANSFER
;
;----------------------------------------------
;
; GOT 'eot'...FN.T NEXT
;
FNNEXT:	LD	E,08		;SEND 08...RDY FOR FN.T
	CALL	SENDE		;SEND CHAR IN <E>	(08 -->)
	LD	HL,SNDFCB+01	;SENDERS FILENAME FCB
	LD	B,11		;MAX FN.T CHARS
;
; LOOP & GET FN.T FROM SENDER TO SNDFCB
;
FNLOOP:	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(FN.T <--)
	CP	' '		;VALID FN.T CHAR?
	JP	C,BADFLN		;NO
	LD	(HL),A		;YES, SAVE IT
	LD	E,A		;& ECHO
	CALL	SENDE		;SEND CHAR IN <E>	(FN.T -->)
	INC	HL
	DEC	B
	JP	NZ,FNLOOP		;NOT 11 CHARS YET
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(ENQ <--)
	CP	ENQ		;'enq',  END FN?
	JP	NZ,BADFLN		;NO
;
; GOT SENDERS FN.T & 'enq' MOVE IT TO SYSFCB IF USING SND NAME
;
MOVFCB:	LD	DE,FCB+01	;DESTINATION
	LD	HL,SNDFCB+01	;SENDERS FILENAME FCB
	LD	B,11
;
; LOOP & STO FN
;
STOFN:	LD	A,(FNTOUS)	;00/NZ=USE SENT/REQ FN.T
	OR	A		;USE SENDERS FN.T?
	JP	Z,STOFN1		;YES
	LD	A,(DE)
	CP	'?'		;WILD CARD?
	JP	NZ,STOFN2		;NO
;
; STORE SENDERS FN.T IN SYSTEM FCB
;
STOFN1:	LD	A,(HL)		;SENDERS FN.T CHR
	LD	(DE),A		;TO SYSTEM FCB
;
; SENDERS FN.T CHAR STORED IF USING HIS FN.T
;
STOFN2:	INC	DE		;BUMP PUT PNTR
	INC	HL		;& GET PNTR
	DEC	B
	JP	NZ,STOFN		;NOT 11 CHARS YET
	CALL	CRLF		;PRINT CRLF
	LD	HL,SNDFCB+01	;SENDERS FILENAME FCB
	CALL	PRTFNT		;PRINT FN TO CONSOLE
	LD	A,(FNTOUS)	;00/NZ=USE SENT/REQ FN.T
	OR	A		;USING SENDERS FN.T?
	JP	Z,PRTARW		;YES, PRINT ARROW & IT'S NAME
	LD	HL,FCB+11	;NO...
	LD	B,03		;'TYP' LENGTH
	CALL	FILSPC		;FILL ANY EMBEDDED SPACES
	LD	B,08		;'FILENAME' LENGTH
	CALL	FILSPC		;FILL ANY EMBEDDED SPACES
	JP	PRTARW		;PRINT ' ==> '
;
;----------------------------------------------
;
; FILL ANY EMBEDDED FN.T SPACES WITH '$'S
;
FILSPC:	LD	A,(HL)
	DEC	HL
	CP	' '		;AT SPACE?
	JP	NZ,NOTSPC		;NO, SOLID
	DEC	B		;END OF FN/T?
	JP	NZ,FILSPC		;NO
	RET			;YES
;
;----------------------------------------------
;
; END STRING AT SOLID
;
ENDSTR:	LD	A,(HL)
	DEC	HL
	CP	' '		;EMBEDDED SPACE?
	JP	NZ,NOTSPC		;NO
	INC	HL		;YES, PNT BACK TO IT
	LD	(HL),'$'	;FILL IT
	DEC	HL		;GO ON TO NEXT
;
; ANY EMBEDDED SPACE FILLED WITH '$'
;
NOTSPC:	DEC	B		;END OF FN/T?
	JP	NZ,ENDSTR		;NO
	RET			;YES, DONE
;
;----------------------------------------------
;
; PRINT ' ==> ' & RECEIVE FN.T
;
PRTARW:	LD	DE,ARWMSG	;'  ==>  $'
	CALL	PRTDE		;PRINT DE->'$'
	LD	HL,FCB+01	;PNT TO RECEIVE FILE NAME
	CALL	PRTFNT		;PRINT FN TO CONSOLE
	CALL	CLRFCB		;CLR SYS FCB 'ex' -> 'nc'
	XOR	A		;SET NO OVERWRITE
	LD	(OVWFLG),A	;00/NZ=NO OVERWRITE
	LD	C,SCHFIL
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	INC	A		;FOUND IT?
	JP	Z,NEWFIL		;NO
	LD	DE,OVWMSG	;YES, 'Overwrite (Y/N) ?  $'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP FOR FILENAME OVERWRITE OK
;
ASKOVW:	CALL	GETCON		;LD <A> & <E> WITH CONSOLE INP
	CALL	MAKEUC		;MAKE <A> UC
	CP	'N'
	JP	NZ,CKOWOK		;NO
	CALL	DCONIO		;PRINT <E> TO CONS
	CALL	GETFNT		;GET REQ FN.T & PARSE INTO SYSFCB
	JP	MOVFCB
;
;**********************************************
;
; CHECK FOR OVERWRITE
;
CKOWOK:	CP	'Y'		;OVERWRITE?
	JP	NZ,ASKOVW		;NO
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	HL,OVWFLG	;00/NZ=NO OVERWRITE
	LD	(HL),01		;SET OVERWRITE OK
	LD	DE,SPCMSG	;'           $'
	CALL	PRTDE		;PRINT DE->'$'
;
; ANY OVERWRITE QUESTION TAKEN CARE OF OR NO FILE TO OVERWRITE
;
NEWFIL:	LD	HL,FCB+09	;PNT TO 'TYP'
	LD	DE,SNDFCB+09	;SENDERS FILENAME FCB
	LD	B,03
;
; LOOP & STORE RECEIVE TYPE IN SNDFCB 'TYP' LOC
;     AND SET SYSTEM FCB TO FILENAME.$$$
;
FILTYP:	LD	A,(HL)		;GET ORIG TYPE
	LD	(HL),'$'	;MAKE TYPE = TEMP
	LD	(DE),A		;SAVE ORIG TYPE
	INC	HL
	INC	DE		;BUMP
	DEC	B
	JP	NZ,FILTYP
	CALL	FILDEL		;DELETE ANY TEMP FILE @ FCB
	LD	C,MAKFIL	;MAKE FN.$$$
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	INC	A
	LD	DE,DIRFMS	;'  Directory full$'
	JP	Z,PRTCLS		;DE->$, CLOSE & WAIT TO CNT
	LD	A,0FFH
	LD	(MORFLG),A	;00/NZ=NO/MORE FILES
	LD	E,09		;SAY 'READY FOR FILE'
	CALL	SENDE		;SEND CHAR IN <E>	(09 -->)
	LD	DE,RCVMSG	;'    Receiving $'
	CALL	PRTDE		;PRINT DE->'$'
;
; LOOP FOR BLOCKS
;
GETBLK:	LD	HL,DBUF		;PLACE TO GET BLOCK
	LD	C,00		;INIT CHKSUM
	LD	D,128		;BLOCK LGT
;
; LOOP FOR 'stx'S & GET BLOCKS
;
GETSTX:	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(STX/ETX <--)
	CP	STX		;'stx'...ANOTHER BLOCK?
	JP	Z,SNDPCD		;YES, SEND 'P' TO SENDER
	CP	ETX		;'etx'...EOF?
	JP	Z,GOTETX		;YES
	LD	E,'N'
	CALL	SENDE		;SEND CHAR IN <E>	('N' -->)
	JP	GETSTX		;WAIT FOR 'stx'
;
;----------------------------------------------
;
; SEND 'P'roceed TO SENDER
;
SNDPCD:	LD	E,'P'		;P(ROCEED)
	CALL	SENDE		;SEND CHAR IN <E>	('P'ROCEED -->)
;
; LOOP & GET 128 BYTES
;
GTABLK:	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(BLOCK <--)
	LD	(HL),A		;STO CHAR
	XOR	C		;TO CHKSUM
	LD	C,A		;RESTO IT
	INC	HL		;PNTR
	DEC	D		;DONE 128?
	JP	NZ,GTABLK		;NO
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER	(CHKSUM <--)
	XOR	C		;CKSUM OK
	JP	Z,CKSMOK		;YES
	LD	E,'B'		;NO
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	E,'B'
	CALL	SENDE		;SEND CHAR IN <E>	('B'AD -->)
	JP	GETBLK
;
;----------------------------------------------
;
; LOOP FOR NEXT RECEIVE SECTOR
;
CKSMOK:	LD	E,'.'
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	C,SETDMA
	LD	DE,DBUF
	CALL	BDOS
	LD	C,WRTNXT	;WRITE BLOCK TO DISK
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	OR	A		;OK WRITE?
	JP	Z,SNDGOD		;YES
	CALL	FILCLS		;NO, CLOSE FILE
	XOR	A
	LD	(MORFLG),A	;00/NZ=NO/MORE FILES
	LD	DE,DSKFMS	;'  Disk full$'
	JP	PRTCLS		;DE->$, CLOSE & WAIT TO CNT
;
;**********************************************
;
; GOT OK WRITE
;
SNDGOD:	LD	E,'G'		;SEND 'G'OOD
	CALL	SENDE		;SEND CHAR IN <E>	('G'OOD -->)
	JP	GETBLK
;
;**********************************************
;
; GOT 'etx'...EOF
;
GOTETX:	CALL	FILCLS		;CLOSE FILE
	JP	NZ,CLOSOK		;OK CLOSE
;
; LOOP FOR CONSOLE CHAR
;
GTCNCH:	CALL	CHKABT		;CHECK CONS FOR ABORT
	LD	E,0FFH
	CALL	DCONIO		;GET CONS CHAR
	OR	A		;ANY CHAR?
	JP	Z,GTCNCH		;NO
;
; OK CLOSE/GOT RESPONSE TO 'CLOSE ERROR'
;
CLOSOK:	LD	HL,FCB		;RECEIVE FN.$$$
	LD	DE,SNDFCB	;SENDERS FILENAME FCB
	LD	BC,0009
	CALL	LDIR
	XOR	A
	LD	(SNDFCB+12),A	;CLEAR EXTENT AND...
	LD	(SNDFCB+15),A	;RECORD COUNT
	LD	A,(OVWFLG)	;00/NZ=NO/OVERWRITE
	OR	A		;OVER WRITE?
	JP	Z,DELOK		;NO, RENAME TO FN @ SNDFCB
	LD	C,DELFIL	;YES
	LD	DE,SNDFCB
	CALL	BDOS		;DELETE SENDERS FN.T
	CP	0FFH		;OK DELETE?
	JP	NZ,DELOK		;YES
	LD	DE,DELMSG	;'  Delete error$'
	JP	PRTRST		;PRINT DE->$ & RESTART
;
;**********************************************
;
; OK TO RENAME TO FN @ SNDFCB
;
DELOK:	LD	HL,SNDFCB	;RECEIVE (SENDERS) FN.T FCB
	LD	DE,FCB+16
	LD	BC,0016
	CALL	LDIR		;TO SYSFCB+16 FOR RENAME
	LD	C,RENFIL	;FN.$$$ -> FN.TYP
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	INC	A
	JP	Z,RNMERR		;RENAME ERROR...RESTART
	XOR	A		;SET NO MORE
	LD	(MORFLG),A	;00/NZ=NO/MORE FILES
	JP	GTFLOP		;RESTART FILE XFR FOR NEXT FILE
;
;**********************************************
;
; RENAME ERROR...RESTART
;
RNMERR:	LD	DE,RENMSG	;'  Rename error$'
;
; PRINT DE->$ & RESTART
;
PRTRST:	CALL	PRTDE		;PRINT DE->'$'
	CALL	CRLF		;PRINT CRLF
	CALL	FILDEL		;DELETE FILE @ FCB
	XOR	A
	LD	(MORFLG),A	;00/NZ=NO/MORE FILES
	JP	OPTLOP		;RESTART
;
;**********************************************
;
; PRINT FN TO CONSOLE
;
PRTFNT:	LD	B,11		;MAX CHARS
;
; LOOP & PRINT NAME
;
PRTFLN:	LD	A,(HL)		;GET CHAR
	AND	7FH		;STRIP PARITY
	LD	E,A		;GET CHAR
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	A,B
	CP	04		;AT TYPE?
	JP	NZ,PTFLN1		;NO
	LD	E,'.'		;YES, PRINT '.'
	CALL	DCONIO		;PRINT <E> TO CONS
PTFLN1:	INC	HL
	DEC	B
	JP	NZ,PRTFLN
	RET	
;
;**********************************************
;
; LD <A> & <E> WITH CONSOLE INP
;
GETCON:	LD	E,0FFH
	CALL	DCONIO		;GET CONS CHAR
	OR	A		;ANY CONSOLE CHAR?
	JP	Z,GETCON		;NO, LD <A> & <E> WITH CONSOLE INP
	CP	'C'-40H		;ABORT?
	LD	DE,ABTMSG	;'  Aborted $'
	JP	Z,PRTQIT		;YES, PRINT DE->$ & QUIT
	CP	ESC
	LD	E,A		;STO IN <E>
	RET	NZ 		;NOT ESC
	CALL	CRLF		;PRINT CRLF
	JP	RESTRT		;RESTART
;
;**********************************************
;
; CLEAR SYSTEM FCB 'ex' -> 'nc'
;
CLRFCB:	LD	HL,FCB+12
	LD	DE,FCB+13
	LD	(HL),00
	LD	BC,0023
	CALL	LDIR
	RET	
;
;**********************************************
;
; CLOSE FILE, 00/NZ = BAD/OK CLOSE
;
FILCLS:	LD	C,CLSFIL
	CALL	DOBDOS		;DO BDOS CALL IN <C> DE=FCB
	INC	A		;OK CLOSE?
	RET	NZ 		;YES
	LD	DE,CLSMSG	;'  Close error$'
	CALL	PRTDE		;PRINT DE->'$'
	XOR	A
	RET	
;
;**********************************************
;
; DELETE FILE @ FCB
;
FILDEL:	LD	C,DELFIL
;
; DO BDOS CALL IN <C> DE=FCB
;
DOBDOS:	LD	DE,FCB
;
; DO BDOS CALL IN <C>
;
DBDOS1:	PUSH	DE
	PUSH	HL
	CALL	BDOS
	POP	HL
	POP	DE
	RET	
;
;**********************************************
;
; DIRECT CONSOLE I/O
;
DCONIO:	PUSH	BC
	LD	C,DIRCON
	CALL	DBDOS1		;DO BDOS CALL IN <C>
	POP	BC
	RET	
;
;**********************************************
;
; PRINT DE->'$' WITH CR'S AT 00'S
;
PRTDE:	LD	A,(DE)
	CP	'$'
	RET	Z 
	OR	A		;TIME FOR CR?
	PUSH	DE
	LD	E,A		;GET CHAR
	PUSH	AF		;SAVE IT
	CALL	NZ,DCONIO		;PRINT <E> TO CONS
	POP	AF
	CALL	Z,CRLF		;PRINT CRLF
	POP	DE
	INC	DE
	JP	PRTDE
;
;**********************************************
;
; PRINT CRLF
;
CRLF:	PUSH	AF
	LD	E,CR
	CALL	DCONIO		;PRINT <E> TO CONS
	LD	E,LF
	CALL	DCONIO		;PRINT <E> TO CONS
	POP	AF
	RET	
;
;**********************************************
;
; DONE...CRLF & CLOSE FILES
;
DONALL:	LD	DE,CRMSG
	JP	CLFILS		;DONE...CLOSE FILES
;
;**********************************************
;
; WAIT FOR CHR FRM OTHER
;
GTOTHR:	CALL	MDMIST		;GET MODEM INPUT STAT
	JP	NZ,GTMCHR		;DATA AVAILABLE GET IT
	CALL	CHKABT		;SEE IF QUIT
	JP	GTOTHR		;NOTHING THERE
;
;**********************************************
;
; SEND CHAR IN <E>
;
SENDE:	PUSH	DE		;CHAR TO SEND
	LD	DE,WAITIM	;TIME TO WAIT
;
; LOOP & WAIT FOR CHAR
;
WAITCH:	CALL	CHKABT		;CHECK CONS FOR ABORT
	CALL	MDMOST		;RETURN MODEM OUTPUT STATUS
	JP	NZ,SNDCHR		;PORT IS READY
	DEC	DE		;PORT NOT READY...
	LD	A,D
	OR	E		;TIME UP?
	JP	NZ,WAITCH		;NO
	LD	DE,PNRMSG	;'RS-232C is not ready.',0,'$'
	CALL	PRTDE		;PRINT DE->'$'
;
; WAIT FOR OUTOK
;
OTOKLP:	CALL	MDMOST		;RETURN MODEM OUTPUT STATUS
	JP	NZ,SNDCHR
	CALL	CHKABT		;CHECK CONS FOR ABORT
	JP	OTOKLP
;
;----------------------------------------------
;
; MODEM OUT READY, RECOVER CHR & SEND TO MODEM
;
SNDCHR:	POP	DE		;CHR IN <E>
	JP	MDMOUT		;SEND IT
;
;**********************************************
;
; PRINT DE->$, CLOSE FILES & WAIT TO CONTINUE
;
PRTCLS:	CALL	PRTDE		;PRINT DE->'$'
	LD	A,(MORFLG)	;00/NZ=NO/MORE FILES
	OR	A
	CALL	NZ,FILCLS		;CLOSE FILE
	XOR	A
	LD	(MORFLG),A	;00/NZ=NO/MORE FILES
	LD	DE,HLPMS1	;0,0,'Press  ESC to restart,'
	CALL	PRTDE		;PRINT DE->'$'
	LD	E,'.'
	CALL	DCONIO		;PRINT <E> TO CONS
;
; WAIT FOR CONSOLE INPUT
;
CONWAT:	CALL	GETCON		;LD <A> & <E> WITH CONSOLE INP
	JP	CONWAT
;
;**********************************************
;
; GET REQUESTED FILENAME & PARSE INTO SYSFCB
;
GETFNT:	LD	DE,ENTRMS	;'Enter file name    $'
	CALL	PRTDE		;PRINT DE->'$'
	LD	HL,FLNLST	;FILENAME LIST BUFFER
	LD	DE,FLNLST+01	;TO BE USED FOR INPUT
	LD	(HL),00
	LD	BC,0014
	CALL	LDIR		;CLEAR LOCAL FCB
	LD	HL,FCB
	LD	DE,FCB+01
	LD	(HL),' '
	LD	BC,0011
	CALL	LDIR		;CLEAR SYSTEM FCB FN.T
	XOR	A
	LD	(FCB+12),A	;CLR EX...
	LD	(FCB+15),A	;RC
	LD	(FCB+32),A	;& NR
	LD	BC,0000		;INIT <C>=CHAR COUNT
;
; LOOP FOR FILENAME CHARS
;
GTFNT1:	LD	HL,FLNLST	;FILENAME LIST BUFFER
	CALL	GETCON		;LD <A> & <E> WITH CONSOLE INP
	CP	CR		;END OF INPUT?
	JP	Z,ENDINP		;YES
	CP	BS		;ERASE?
	JP	Z,GOTBS		;YES
	CP	RUB		;ERASE?
	JP	NZ,NORUB		;NO
	LD	E,BS
;
; GOT BS/RUB...ERASE
;
GOTBS:	LD	A,C		;GET COUNT
	OR	A		;0 CHARS?
	JP	Z,GTFNT1		;YES
	DEC	C		;NO, DEC COUNT
	ADD	HL,BC		;PNT TO CHAR
	LD	(HL),00		;KILL IT
	CP	14		;14 CHARS
	JP	Z,CHRIGN		;YES, ERASE CHAR
	CALL	DCONIO		;NO, PRINT <E> TO CONS
;
; OVER 14 CHARS IGNORED
;
CHRIGN:	LD	DE,BSMSG	;' ',BS,'$'
	CALL	PRTDE		;PRINT DE->'$'
	JP	GTFNT1		;GET NEXT
;
;----------------------------------------------
;
; NOT A BS
;
NORUB:	CP	' '+01		;VALID CHAR?
	JP	C,GTFNT1		;NO, GET ANOTHER
	LD	A,C		;GET COUNT
	CP	14		;14 CHARS?
	JP	NZ,GETMOR		;NO
	DEC	C		;YES, DEC COUNT
;
; NOT 14 CHARS
;
GETMOR:	CALL	PTUSTO		;GET CONS CHR, UC & STO @ HL+<C>
	LD	A,C		;GET COUNT
	CP	14		;14 CHARS?
	JP	NZ,GTFNT1		;NO, GET NEXT
	LD	E,BS		;YES, BS ONE
	CALL	DCONIO		;PRINT <E> TO CONS
	JP	GTFNT1		;GET NEXT
;
;----------------------------------------------
;
; GOT REQUESTED FN.T TO FLNLST...PARSE INTO SYSTEM FCB
;
ENDINP:	LD	A,(FLNLST+01)	;GET 2ND CHAR
	CP	':'		;DRIVE?
	LD	A,'A'-01
	JP	NZ,NODRIV		;NO
	LD	A,(HL)		;YES, GET IT
	INC	HL
	INC	HL		;TO FILENAME
	LD	A,(FLNLST)	;GET DRIVE
	CP	'A'-01		;<'A'
	JP	Z,SELERR		;DRIVE SELECT ERROR
;
; <A>=00/DRV=DEFAULT/DRIVE
;
NODRIV:	SUB	'A'-01		;OK DRIVE?
	JP	C,SELERR		;NO, DRIVE SELECT ERROR
	CP	MAXDRV-'A'+01	;> MAX DRIVE?
	JP	NC,SELERR		;YES, DRIVE SELECT ERROR
	LD	(FCB),A		;STO DRIVE
	LD	B,08		;FN LENGTH
	LD	DE,FCB+01
	LD	A,(HL)
	CP	'0'		;<#?
	JP	C,OKCHAR		;YES
	CP	'9'+01		;#?
	JP	C,BDSPEC		;YES, BAD FILE DESC
;
; LOOP FOR 8 FILENAME CHARS
;
OKCHAR:	LD	A,(HL)		;GET FN.T CHAR
	CP	'*'		;WILD CARD?
	JP	Z,PUT8QS		;PUT 8 '?'S
	CP	'.'		;END OF FN?
	JP	NZ,NOTFNE		;NO
	LD	A,B		;YES
	CP	08		;8 CHARS LEFT?
	JP	Z,BDSPEC		;YES, BAD FILE DESC
	JP	DOTYPE		;DONE FILENAME...TO TYP
;
;----------------------------------------------
;
; CHECK FOR END OF STRING
;
NOTFNE:	OR	A		;NULL...END?
	JP	NZ,NONULL		;NO
	LD	A,B		;FN LGT
	CP	08		;STILL 8 CHARS LEFT?
	JP	NZ,DONFNT		;NO, DONE FN
	LD	A,(USROPT)	;YES, USER OPTION: S/R
	CP	'S'		;NO FILENAME...SEND?
	JP	Z,NFNINP		;YES, 'NO FILENAME SPECIFIED'
	JP	DONFNT		;DONE
;
;----------------------------------------------
;
; NOT NULL, STO CHAR
;
NONULL:	LD	(DE),A		;STO IN SYSFCB
	INC	DE		;PUT PNTR
	INC	HL		;GET PNTR
	DEC	B
	JP	NZ,OKCHAR		;NOT 8 CHARS YET
;
; LOOP TO NULL/'.'
;
FNDNUL:	LD	A,(HL)
	OR	A		;NULL?
	JP	Z,DONFNT		;YES, DONE
	CP	'.'		;END OF FN?
	JP	Z,DOTYPE		;GOT TO TYPE
	JP	BDSPEC		;BAD FILE DESC
;
;----------------------------------------------
;
; GOT '*'
;
PUT8QS:	PUSH	BC		;FN/TYP COUNT
;
; LOOP & INSERT '?'S
;
DOQLOP:	LD	A,'?'
	LD	(DE),A
	INC	DE
	DEC	B
	JP	NZ,DOQLOP
	POP	BC		;FN.TP BAL
	DEC	B
;
; LOOP TO END OF FN
;
EFNLOP:	INC	HL
	LD	A,(HL)
	CP	'.'		;END OF FN?
	JP	Z,DOTYPE		;YES
	OR	A		;NULL?
	JP	Z,DONFNT		;YES, DONE
	DEC	B
	JP	NZ,EFNLOP
	INC	HL
	JP	FNDNUL		;GET TO NULL/'.'
;
;----------------------------------------------
;
; END OF FN (.)
;
DOTYPE:	INC	HL
	LD	B,03		;MAX TYP CHARS
	LD	DE,0065H
;
; LOOP FOR 3 TYP CHARS
;
DOTYP1:	LD	A,(HL)
	LD	C,A
	AND	80H		;GET BIT 7
	JP	Z,NTSPCL		;NOT SPECIAL
	LD	A,B
	CP	01		;'Y' BYTE?
	JP	NZ,BDSPEC		;NO, SYSTEM FILE...BAD FILE DESC
;
; NOT SYSTEM FILE
;
NTSPCL:	LD	A,C
	CP	'.'
	JP	Z,BDSPEC		;BAD FILE DESC
	CP	'*'
	JP	Z,DOTPQS		;FILL 'TYP' WITH '?'S
	OR	A		;NULL?
	JP	Z,DONFNT		;YES, DONE
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JP	NZ,DOTYP1		;LOOP FOR 3 CHARS
	JP	DONTYP		;FINISHED TYPE
;
;----------------------------------------------
;
; FILL 'TYP' WITH '?'S
;
DOTPQS:	PUSH	BC
;
; LOOP & FILL TYP WITH '?'S
;
DTPQS1:	LD	A,'?'
	LD	(DE),A
	INC	DE
	DEC	B
	JP	NZ,DTPQS1		;LOOP FOR 3 CHRS BALANCE
	POP	BC
;
; LOOP & FINISH FN.TYP
;
FINTYP:	INC	HL
	DEC	B
	JP	NZ,FINTYP
;
; END OF 'TYP'
;
DONTYP:	LD	A,(HL)		;GET LAST
	OR	A		;END WITH NULL?
	JP	NZ,BDSPEC		;NO, BAD FILE DESC
;
; END OF FN.TYP...RETURN
;
DONFNT:	LD	A,(FCB+01)	;GET 1ST CHAR
	SUB	20H		;-20H=00/NZ=USE SENT/REQ FN.T
	LD	(FNTOUS),A	;00/NZ=USE SENT/REQ FN.T
	XOR	A		;INIT...
	LD	(FILCNT),A	;FILE COUNT
	RET	
;
;----------------------------------------------
;
; NO FILENAME SPECIFIED
;
NFNINP:	LD	DE,NNAMSG	;'  No file name specified$'
	JP	PRTERR		;PRINT ERR MSG @ DE
;
;----------------------------------------------
;
; DRIVE SELECT ERROR
;
SELERR:	LD	DE,DSELMS	;'  Drive select error$'
	JP	PRTERR		;PRINT ERR MSG @ DE
;
;----------------------------------------------
; 
; BAD FILE DESC
;
BDSPEC:	LD	DE,BDFLMS	;'  Bad file descriptor$'
;
; PRINT ERROR MSG @ DE AND REGET A FN.T FROM CONSOLE
;
PRTERR:	CALL	PRTDE		;PRINT DE->'$'
	JP	GETFNT		;GET REQ FN.T & PARSE INTO SYSFCB
;
;**********************************************
;
; GET CONS CHAR, MAKE UC & STO @ HL+<C>
;
PTUSTO:	CALL	DCONIO		;GET CONS CHAR
	LD	A,E		;GET CHAR
	CALL	MAKEUC		;MAKE <A> UC
	ADD	HL,BC
	LD	(HL),A
	INC	C
	RET	
;
;**********************************************
;
; MAKE <A> UC
;
MAKEUC:	CP	'a'
	RET	C 
	CP	'z'+01
	RET	NC 
	AND	5FH
	RET	
;
;**********************************************
;
; C=00/FF/'R'=CHK FOR 'R'/CONS INPT/'S' IN <B> COUNTS
;
CKOTHR:	PUSH	DE
	PUSH	HL
;
; LOOP IF OTHER NOT READY
;
CKOTH1:	CALL	CHKABT		;CHECK CONS FOR ABORT
	DEC	B		;MAX WAIT?
	LD	A,B		;SET Z IF YES
	JP	NZ,CKOTH2		;NO
	JP	CKOTH6		;Z, RETURN OTHER NOT READY
;
;----------------------------------------------
;
; WAIT NOT UP
;
CKOTH2:	LD	A,C
	CP	0FFH		;CHECK CONSOLE?
	JP	NZ,CKOTH3		;NO
	LD	E,0FFH		;YES
	PUSH	BC
	CALL	DCONIO		;GET CONS CHAR
	POP	BC
	OR	A		;ANY CONS INPUT?
	JP	Z,CKOTH1		;NO, RELOOP
	JP	CKOTH5		;SET OTHER READY
;
;----------------------------------------------
;
; NOT CONSOLE CHECK
;
CKOTH3:	OR	A		;CHECK FOR 'S'END?
	JP	Z,CKOTH4		;NO
	LD	E,'R'		;YES
	CALL	SENDE		;SEND CHAR IN <E>
	CALL	MDMIST		;INPUT FROM OTHER?
	JP	Z,CKOTH1		;NO
	CALL	GTOTHR		;YES, WAIT FOR CHR FRM OTHER
	CP	'S'		;'S'END?
	JP	NZ,CKOTH1		;NO
	JP	CKOTH5		;SET OTHER READY
;
;----------------------------------------------
;
; RECEIVING...CHK FOR 'R' FROM OTHER 
;
CKOTH4:	CALL	MDMIST		;GET OTHER'S INPUT STATUS
	JP	Z,CKOTH1		;NOT READY
	CALL	GTOTHR		;WAIT FOR CHR FRM OTHER
	CP	'R'
	JP	NZ,CKOTH1		;NOT READY
;
; SET OTHER IS READY
;
CKOTH5:	LD	A,0FFH
;
; RETURN OTHER NOT READY
;
CKOTH6:	POP	HL
	POP	DE
	RET	
;
;**********************************************
;
; CLEAR ANY PENDING CONSOLE INPUT CHARS
;
CLRCIN:	LD	E,0FFH
	CALL	DCONIO		;GET CONS CHAR
	OR	A
	JP	NZ,CLRCIN
	RET	
;
;**********************************************
;
; CHECK CONS FOR ABORT
;
CHKABT:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,0FFH
	CALL	DCONIO		;DIRECT CONSOLE I/O
	CP	'C'-40H
	JP	Z,EXIT		;ABORT...SAY SO & CLOSE FILES
	POP	HL
	POP	DE
	POP	BC
	CP	ESC		;RESTART?
	JP	Z,RESTRT		;YES
	RET	
;
;----------------------------------------------
;
; ABORT...SAY SO & CLOSE FILES
;
EXIT:	CALL	CLRCIN		;CLEAR ANY CONS INP CHARS
	LD	DE,ABTMSG	;'  Aborted $'
;
; DONE SEND...CLOSE FILES
;
CLFILS:	PUSH	DE
	LD	A,(MORFLG)	;00/NZ=NO/MORE FILES
	OR	A
	JP	Z,SNTALL		;DONE ALL
	CALL	FILCLS		;CLOSE FILE
	LD	A,(USROPT)	;USER OPTION: S/R
	CP	'R'
	CALL	Z,FILDEL		;BAD CLOSE...DELETE FILE @ FCB
;
; SENT ALL FILES
;
SNTALL:	POP	DE
;
;**********************************************
;
; PRINT DE->$ & QUIT
;
PRTQIT:	CALL	PRTDE		;PRINT DE->'$'
	CALL	CLRCIN		;CLR ANY CONS INP CHARS
	LD	B,02		;TIME TO WAIT
	LD	C,0FFH		;WAIT FOR CONSOLE
	CALL	CKOTHR		;WAIT/TIME OUT
;
; CLEAR CONS INPUT & QUIT
;
CLCXIT:	CALL	CLRCIN		;CLR ANY CONS INP CHARS
	.IFNZ	DOBAUD
	 LD	DE,STATMS	;0,0,'The RS-232C status is :$'
	 CALL	PRTDE		;PRINT DE->'$'
	 LD	DE,BITMS2	;' bit rate = 1200'
	 CALL	PRTDE		;PRINT DE->'$'
	 LD	HL,BAUD2	;POINT TO END BAUD STRING
	 LD	A,(HL)		;GET LGT
	 OR	A		;CLR CRY
	 RRCA			;LGT/2
	 LD	B,A
	 INC	HL
	 JP	C,DONBD2		;ODD # NO GOOD
	 JP	Z,DONBD2		;NO STRING
	 CALL	OUTI		;LOOP & SET BAUD
	.ENDIF	
BOTADR:	LD	HL,0000		;GET BOOT ADDR
BOTVEC:	LD	DE,0000		;BOOT VECTOR
	LD	(HL),E
	INC	HL
	LD	(HL),D		;RESTORE IT
DONBD2:	JP	BOOT
;
;**********************************************
;
; 8080-Z80 SUPPORT ROUTINES
;
; DO Z80 'LDIR'
;
LDIR:	PUSH	AF
;
; LOOP & TRANSFER
;
LDIR1:	LD	A,C
	OR	B
	JP	Z,POPRET
	LD	A,(HL)
	LD	(DE),A
	DEC	BC
	INC	DE
	INC	HL
	JP	LDIR1
;
; DONE, RECOVER AF
;
POPRET:	POP	AF
	RET	
;
;----------------------------------------------
;
; DO Z80 'OUTI'
;
OUTI:	PUSH	AF
;
OUTI1:	LD	A,(HL)		;GET PORT ADDRESS
	LD	(OUTPRT),A	;STORE IT
	INC	HL		;TO COMMAND BYTE
	LD	A,(HL)		;GET IT
OUTPRT	.EQUAL	$+1		;PORT LOCATION
	OUT	(00),A		;SEND IT
	INC	HL		;NEXT PORT ADDR
	DEC	B		;DONE ALL?
	JP	NZ,OUTI1		;NO
	POP	AF
	RET	
;
;**********************************************
;
; MESSAGES
;
HELLO:	.BYTE	00,'EPSNLINK by Community Business Systems'
	.BYTE	' 12/23/84',00
	.BYTE	'A file transfer program to communicate with'
	.BYTE	' the EPSON PX-8 and QX-10$'
;
	.IFNZ	DOBAUD
STATMS:	 .BYTE	0,0,'The RS-232C status is :$'
;
BITMS1:	 .BYTE	' bit rate = 9600'
	 .BYTE	'  data bits = 8'
	 .BYTE	'  stop bits = 1$'
;
BITMS2:	 .BYTE	' bit rate = 1200'
	 .BYTE	'  data bits = 8'
	 .BYTE	'  stop bits = 2',0,'$'
	.ENDIF	
;
HLPMS1:	.BYTE	0,0,'Press  ESC to restart,'
	.BYTE	' or CTRL/C to exit from EPSNLINK$'
SRMSG:	.BYTE	0,'Send or Receive  (S/R) ? $'
SNDRMS:	.BYTE	0,'Sender $'
RNRMSG:	.BYTE	0,'Receiver '
NRDYMS:	.BYTE	'is not ready.',0,'$'
ENTRMS:	.BYTE	0,'Enter file name    $'
DONMSG:	.BYTE	'Done',00,'eXit or Continue'
	.BYTE	' (X/C) ? $'
NNAMSG:	.BYTE	0,'  No file name specified$'
NFILMS:	.BYTE	'  File not found$'
SNDMSG:	.BYTE	'       Sending $'
ABTMSG:	.BYTE	0,0,'  Aborted $'
DIRFMS:	.BYTE	0,'  Directory full$'
SPCMSG:	.BYTE	'           $'
RCVMSG:	.BYTE	'    Receiving $'
ARWMSG:	.BYTE	'  ==>  $'
OVWMSG:	.BYTE	0,'Overwrite (Y/N) ?  $'
DSKFMS:	.BYTE	0,'  Disk full$'
RENMSG:	.BYTE	0,'  Rename error$'
DELMSG:	.BYTE	0,'  Delete error$'
CLSMSG:	.BYTE	0,'  Close error$'
DSELMS:	.BYTE	0,'  Drive select error$'
BDFLMS:	.BYTE	0,'  Bad file descriptor$'
PNRMSG:	.BYTE	0,'RS-232C is not ready.',0,'$'
BSMSG:	.BYTE	' ',BS,'$'
CRMSG:	.BYTE	0,'$'
FNTOUS:	.BYTE	00		;00/NZ=USE SENT/REQ FN.T
ENTFLG:	.BYTE	00		;CUR FN.T TO USE FLAG
USROPT:	.BYTE	00		;USER OPTION: S/R
MORFLG:	.BYTE	00		;00/NZ=NO/MORE FILES
OVWFLG:	.BYTE	00		;00/NZ=NO/OVERWRITE
FILCNT:	.BYTE	00		;# OF FILES TO SEND
FLNPTR:	.WORD	FLNLST		;FILENAME LIST POINTER
;
STACK	.EQUAL	(($+100H)/100H*100H)+64
;
CURFNT	.EQUAL	STACK		;'DRFILENAMTYP'...REQ FN.T
;
SNDFCB	.EQUAL	CURFNT+12	;SENDERS FN.T FCB
;
FLNLST	.EQUAL	SNDFCB+36	;LIST OF FILENAMES TO SEND
				;& FN.T INPUT BUFFER
;
	.END
MSG:	.BYTE	0,0,'  Aborted $'
DIRFMS:	.BYTE	0,'  Directory full$'
SPCMSG:	.BYTE	'           $'
RCVMSG:	