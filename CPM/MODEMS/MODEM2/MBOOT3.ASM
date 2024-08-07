;
; MBOOT.ASM ver 3.0
; (revised 5 Nov 80)
;
;MODEM BOOT PROGRAM by Keith Petersen, W8SDZ.
;Thanks to John Taylor for idea of incorporating
;simple terminal routine.  Based on MODEM.ASM V2.0,
;by Ward Christensen with enhancements from MODEM527.
;
;CP/M - CP/M file transfer program (receive-only)
;
;This program is intended for use as a way to
;initially transfer MODEM.COM or MODEM.ASM to
;a new user.  It may be used with almost any
;modem (see equates).  If PMMI or D.C. Hayes modem
;is used, then uses 'ORIGINATE' mode, 300 baud.
;
;A simple terminal routine at start of program allows
;user to communicate with a remote system prior to
;receiving a file to make it possible to down-load
;a file without intervention on the part of the host
;system's operator.
;
;COMMANDS:  MBOOT FILENAME.FILETYPE
; or  MBOOT A:FILENAME.FILETYPE
; or  MBOOT B:FILENAME.FILETYPE
;
;The program will operate as a dumb terminal until
;an 'ESC' key is typed (ctrl-[).  It then branches
;to the receive routine.  The user may also exit
;to CP/M without opening the receive file by typing
;ctrl-E from the terminal.  The values for the escape
;and exit keys may be changed in accordance with the
;needs of the user - some keyboards do not have the
;'ESC' key and/or provision for control characters.
;See equates.
;
;NOTE: Comments for the source code and tabs have been
;removed to make this file easier to transport from one
;system to another.  (KBP)
;
FALSE EQU 0
TRUE  EQU NOT FALSE
;
STDCPM EQU TRUE  ;TRUE, IS STANDARD CP/M
ALTCPM EQU FALSE ;TRUE, IS ALTERNATE CP/M FOR H8 OR TRS80
;
 IF STDCPM
BASE EQU 0
 ENDIF
;
 IF ALTCPM
BASE EQU 4200H
 ENDIF
;
EXITCHR EQU 05H ;CTL-E TO EXIT TERM MODE TO CP/M
ESC     EQU 1BH ;ESCAPE TO EXIT TERM MODE TO FILE RCVE
;
FASTCLK EQU FALSE ;TRUE FOR 4 MHZ CLOCK
;
PMMI EQU TRUE  ;TRUE, IS PMMI MODEM
DCH  EQU FALSE ;TRUE, IS D.C. HAYES MODEM
;
;IF YOU ARE USING AN EXTERNAL MODEM (NOT S-100 PLUG-IN)
;CHANGE THESE EQUATES FOR YOUR MODEM PORT REQUIREMENTS
;
INITREQ EQU FALSE ;TRUE, IF MODEM PORT INIT. REQ'D
INITC1  EQU 0AAH ;1ST INIT CHAR TO CTL PORT FOR USART
INITC2  EQU 40H  ;2ND  "
INITC3  EQU 4EH  ;3RD  "
INITC4  EQU 37H  ;4TH  "
;
 IF NOT PMMI AND NOT DCH
MODCTLP EQU 02H ;PUT YOUR MODEM CONTROL PORT HERE
MODSNDB EQU 80H ;YOUR BIT TO TEST FOR SEND
MODSNDR EQU 80H ;YOUR VALUE WHEN READY
MODRCVB EQU 40H ;YOUR BIT TO TEST FOR RECEIVE
MODRCVR EQU 40H ;YOUR VALUE WHEN READY
MODDATP EQU 03H ;YOUR MODEM DATA PORT
 ENDIF  ;END OF EXTERNAL MODEM EQUATES
;
 IF PMMI
MODCTLP EQU 0C0H
MODSNDB EQU 1
MODSNDR EQU 1
MODRCVB EQU 2
MODRCVR EQU 2
MODDATP EQU 0C1H
BAUDRP  EQU 0C2H
MODCTL2 EQU 0C3H
ORIGMOD EQU 1DH
ANSWMOD EQU 1EH
 ENDIF
;
 IF DCH
MODCTLP EQU 82H
MODSNDB EQU 2
MODSNDR EQU 2
MODRCVB EQU 1
MODRCVR EQU 1
MODDATP EQU 80H
MODCTL2 EQU 81H
ORIGMOD EQU 87H
ANSWMOD EQU 83H
 ENDIF
;
ERRLIM EQU 10
;
SOH EQU 1
EOT EQU 4
ACK EQU 6
NAK EQU 15H
CAN EQU 18H
LF  EQU 10
CR  EQU 13
; 
BDOS EQU BASE+5
FCB  EQU BASE+5CH
;
 ORG BASE+100H
;
 LXI H,0
 DAD SP
 SHLD STACK
 LXI SP,STACK
 CALL INITADR
 CALL ILPRT
 DB 'MBOOT as of '
 DB '11/5/80',CR,LF,0
 LDA FCB+1
 CPI ' '
 JNZ TERMI
 CALL ILPRT
 DB '++NO FILE NAME SPECIFIED++',CR,LF,0
 JMP EXIT
;
TERMI CALL INITMOD
 IN MODDATP
 IN MODDATP
 CALL ILPRT
 DB CR,LF,'TERMINAL MODE',CR,LF
 DB 'CTL-E exits to CP/M, ESC starts file transfer'
 DB CR,LF,0
;
TERM CALL STAT
 JZ TERML
 CALL KEYIN
 CPI EXITCHR
 JZ EXIT
 CPI ESC
 JZ RCVFIL
 OUT MODDATP
;
 IF NOT DCH
TERML IN MODCTLP
 ENDIF
;
 IF DCH
TERML IN MODCTL2
 ENDIF
;
 ANI MODRCVB
 CPI MODRCVR
 JNZ TERM
 IN MODDATP
 ANI 7FH
 CALL TYPE
 JMP TERM
;
RCVFIL CALL ERASFIL
 CALL MAKEFIL
 CALL ILPRT
 DB 'FILE OPEN, READY TO RECEIVE',CR,LF,0
;
RCVLP CALL RCVSECT
 JC RCVEOT
 CALL WRSECT
 CALL INCRSNO
 CALL SENDACK
 JMP RCVLP
;
RCVEOT CALL WRBLOCK
 CALL SENDACK
 CALL CLOSFIL
 CALL ERXIT
 DB CR,LF,'TRANSFER COMPLETE$' 
;
RCVSECT XRA A
 STA ERRCT
;
RCVRPT MVI B,10
 CALL RECV
 JC RCVSERR
 CPI SOH
 JZ RCVSOH
 ORA A
 JZ RCVRPT
 CPI EOT
 STC
 RZ
;
RCVSERR MVI B,1
 CALL RECV
 JNC RCVSERR
 MVI A,NAK
 CALL SEND
 LDA ERRCT
 INR A
 STA ERRCT
 CPI ERRLIM
 JC RCVRPT
;
RCVSABT CALL CLOSFIL
 CALL ERXIT
 DB '++UNABLE TO RECEIVE BLOCK'
 DB CR,LF,'++ABORTING++$'
;
RCVSOH MVI B,1
 CALL RECV
 JC RCVSERR
 MOV D,A
 MVI B,1
 CALL RECV
 JC RCVSERR
 CMA
 CMP D
 JZ RCVDATA
 JMP RCVSERR
;
RCVDATA MOV A,D
 STA RCVSNO
 MVI C,0
 LXI H,BASE+80H
;
RCVCHR MVI B,1
 CALL RECV
 JC RCVSERR
 MOV M,A
 INR L
 JNZ RCVCHR
 MOV D,C
 MVI B,1
 CALL RECV
 JC RCVSERR
 CMP D
 JNZ RCVSERR
 LDA RCVSNO
 MOV B,A
 LDA SECTNO
 CMP B
 JZ RECVACK
 INR A
 CMP B
 JNZ ABORT
 RET
;
RECVACK CALL SENDACK
 JMP RCVSECT
;
SENDACK MVI A,ACK
;
SEND PUSH PSW
 ADD C
 MOV C,A
;
 IF NOT DCH
SENDW IN MODCTLP
 ENDIF
;
 IF DCH
SENDW IN MODCTL2
 ENDIF
;
 ANI MODSNDB
 CPI MODSNDR
 JNZ SENDW
 POP PSW
 OUT MODDATP
 RET
;
ABORT LXI SP,STACK
;
ABORTL MVI B,1
 CALL RECV
 JNC ABORTL
 MVI A,CAN
 CALL SEND
;
ABORTW MVI B,1
 CALL RECV
 JNC ABORTW
 MVI A,' '
 CALL SEND
 CALL ERXIT
 DB 'MBOOT PROGRAM CANCELLED$'
;
INCRSNO LDA SECTNO
 INR A
 STA SECTNO
 RET
;
ERASFIL LXI D,FCB
 MVI C,17
 CALL BDOS
 INR A
 RZ
 CALL ILPRT
 DB '++FILE EXISTS, TYPE Y TO ERASE: ',0
 CALL KEYIN
 PUSH PSW
 CALL TYPE
 CALL CRLF
 POP PSW
 ANI 5FH
 CPI 'Y'
 JNZ MXIT
 LXI D,FCB
 MVI C,19
 JMP BDOS
;
MAKEFIL LXI D,FCB
 MVI C,22
 CALL BDOS
 INR A
 RNZ
 CALL ERXIT
 DB '++ERROR - CAN''T MAKE FILE',CR,LF
 DB '++DIRECTORY MUST BE FULL$'
;
CLOSFIL LXI D,FCB
 MVI C,16
 CALL BDOS
 INR A
 RNZ
 CALL ERXIT
 DB '++CAN''T CLOSE FILE$'
;
WRSECT LHLD SECPTR
 XCHG
 LXI H,BASE+80H
 CALL MOVE128
 XCHG
 SHLD SECPTR
 LDA SECINBF
 INR A
 STA SECINBF
 CPI 16
 RNZ
;
WRBLOCK LDA SECINBF
 ORA A
 RZ
 MOV C,A
 LXI D,DBUF
;
DKWRLP PUSH H
 PUSH D
 PUSH B
 MVI C,26
 CALL BDOS
 LXI D,FCB
 MVI C,21
 CALL BDOS
 POP B
 POP D
 POP H
 ORA A
 JNZ WRERR
 LXI H,80H
 DAD D
 XCHG
 DCR C
 JNZ DKWRLP
 XRA A
 STA SECINBF
 LXI H,DBUF
 SHLD SECPTR
;
RSDMA LXI D,BASE+80H
 MVI C,26
 JMP BDOS
;
WRERR CALL RSDMA
 CALL ILPRT
 DB '++ERROR WRITING FILE',CR,LF,0
 JMP ABORT
;
RECV PUSH D
;
 IF FASTCLK
 MOV A,B
 ADD A
 MOV B,A
 ENDIF
;
MSEC LXI D,50000
;
 IF NOT DCH
MWTI IN MODCTLP
 ENDIF
;
 IF DCH
MWTI IN MODCTL2
 ENDIF
;
 ANI MODRCVB
 CPI MODRCVR
 JZ MCHAR
 DCR E
 JNZ MWTI
 DCR D
 JNZ MWTI
 DCR B
 JNZ MSEC
 POP D
 STC
 RET
;
MCHAR IN MODDATP
 POP D
 PUSH PSW
 ADD C
 MOV C,A
 POP PSW
 ORA A
 RET
;
INITADR LHLD BASE+1
 LXI D,3
 DAD D
 SHLD VSTAT+1
 DAD D
 SHLD VKEYIN+1
 DAD D
 SHLD VTYPE+1
 RET
;
INITMOD EQU $
;
 IF INITREQ 
 MVI A,INITC1
 OUT MODCTLP
 NOP ! NOP ! NOP
 NOP ! NOP
 MVI A,INITC2
 OUT MODCTLP
 NOP ! NOP ! NOP
 NOP ! NOP
 MVI A,INITC3
 OUT MODCTLP
 NOP ! NOP ! NOP
 NOP ! NOP
 MVI A,INITC4
 OUT MODCTLP
 NOP ! NOP ! NOP
 NOP ! NOP
 ENDIF
;
 IF PMMI
 MVI A,52
 OUT BAUDRP
 MVI A,7FH
 OUT MODCTL2
 ENDIF
;
 IF DCH
 MVI A,16H
 OUT MODCTL2
 ENDIF
;
 IF PMMI OR DCH
;
 LXI H,4000
;
OFFDLY DCR L
 JNZ OFFDLY
 DCR H
 JNZ OFFDLY
 MVI A,ORIGMOD 
 OUT MODCTLP
 ENDIF
;
 RET  ;<--THIS RET MUST BE HERE
;
CRLF MVI A,CR
 CALL TYPE
 MVI A,LF
;
TYPE PUSH PSW
 PUSH B
 PUSH D
 PUSH H
 MOV C,A
VTYPE CALL $-$
 POP H
 POP D
 POP B
 POP PSW
 RET
;
STAT PUSH B
 PUSH D
 PUSH H
VSTAT CALL $-$
 POP H
 POP D
 POP B
 ORA A
 RET
;
KEYIN PUSH B
 PUSH D
 PUSH H
VKEYIN CALL $-$
 POP H
 POP D
 POP B
 ANI 7FH
 RET
;
ILPRT XTHL
;
ILPLP MOV A,M
 ORA A
 JZ ILPRET
 CALL TYPE
 INX H
 JMP ILPLP
;
ILPRET XTHL
 RET
;
ERXIT POP D
 MVI C,9
 CALL BDOS
;
MXIT CALL ILPRT
 DB CR,LF,'DON''T FORGET TO DISCONNECT MODEM'
 DB CR,LF,0
;
EXIT LHLD STACK
 SPHL
 RET
;
MOVE128 MVI B,128
;
MOVE MOV A,M
 STAX D
 INX H
 INX D
 DCR B
 JNZ MOVE
 RET
;
RCVSNO DB 0
SECTNO DB 0
ERRCT DB 0
EOFLG DB 0
SECPTR DW DBUF
SECINBF DB 0
 DS 60
STACK DS 2
DBUF EQU $
;
 END
