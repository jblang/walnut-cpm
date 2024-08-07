 ORG 103H
 XEQ 103H
SIN EQU 0C01FH    SOL INPUT
SOU EQU 0C019H    SOL OUTPUT
STAK EQU 0CBFFH   STACK IN SCRATCHPAD RAM
 LXI SP,STAK
 COPY NPTDEFS     PTDOS SYSTEM CALLS
 CALL 0C0D5H      CLEAR SCREEN
 CALL MSGI        ASK FOR INPUT FILENAME
 LXI H,IBUFI
IMF CALL SIN      PUT IT IN BUFFER FOR PSCAN
 JZ IMF
 MOV M,A
 CPI 0DH
 PUSH PSW
 MOV B,A
 CNZ OUTR       ECHO TO SCREEN IF NOT C/R
 POP PSW
 INX H
 JNZ IMF
 CALL MSGO     ASK FOR OUTPUT FILENAME
 LXI H,IBUFO
OMF CALL SIN   TO BUFFER
 JZ OMF
 MOV M,A
 CPI 0DH
 PUSH PSW
 MOV B,A
 CNZ OUTR
 POP PSW
 INX H
 JNZ OMF
PI MVI A,PSOP+40H  OPEN INPUT FILE
 LXI H,IBUFI       NAME IS IN IBUFI
 LXI D,OBUFI       OUTPUT BUFFER FOR PSCAN
 CALL PSCAN
 JC ERR            CARRY IS ERROR, ALWAYS
 JZ ERR            HERE, SO IS ZERO
 MOV A,E
 CPI 0FFH          0FFH IN E IS ERROR
 JZ ERR
 STA IFN           GOT FILE NUMBER, STORE IT
PO MVI A,PSCO+40H  DO SAME FOR OUTPUT FILE
 LXI H,IBUFO       CREATE IF IT DOESN'T EXIST
 LXI D,OBUFO
 CALL PSCAN
 JC ERR
 JZ ERR
 MOV A,E
 CPI 0FFH
 JZ ERR
 STA OFN
 LXI H,0
 SHLD TEMP1    COUNTER FOR INPUT FILE BUFFER
 LXI H,04C0H
 SHLD TEMP2    COUNTER FOR OUTPUT FILE BUFFER
 LXI H,OFB
 SHLD TEMP5    START OF OUTPUT FILE BUFFER
 MVI A,1
 STA  TEMP6    EOF FLAG
START LHLD  TEMP1
 XRA A         SEE IF COUNTER IS ZERO
 CMP H
 JNZ STAR2
 CMP L
 JZ  BEGIN         EMPTY?, READ IN MORE & RESET COUNTER
STAR2 LHLD  TEMP4  TEMP4 IS INPUT BUFFER POINTER
 MOV A,M
 STA TEMP3
 CALL WOBUF   PUT CHARACTER IN OUTPUT FILE BUFFER
CONT  LHLD  TEMP4  INCREMENT INPUT FILE BUFFER POINTER
 INX H
 SHLD TEMP4
 LHLD  TEMP1  DECREMENT INPUT BUFFER COUNTER
 DCX H
 SHLD TEMP1
 LDA TEMP3  PUT CHARACTER IN A
 CPI 0DH    CR? THEN ADD LINEFEED
 CZ LFINS
 JMP START
LFINS MVI A,0AH   ADD LINEFEED
 CALL WOBU2
 RET
BEGIN LDA TEMP6  EOF?
 CPI 0
 JZ FINISH  IF SO, ADD A CTL Z, ENDFILE THE OUTPUT FILE,
;           CLOSE FILES, AND RETURN TO SYS
 PUSH H    READ INPUT FILE INTO BUFFER
 PUSH B         RESET COUNTER
 PUSH D
 PUSH PSW
 LXI B,04C0H
 LXI D,IFB
 MVI L,1
 LDA IFN
 CALL SYS
 DB DRDOP      DELIMITED READ
 JMP RERR         ERROR RETURN
NRET PUSH B       NORMAL RETURN FROM READ
 POP H        B HAD BYTES LEFT IN BUFFER, NOW H HAS IT
 SHLD TEMP1   STORE IT
 LXI H,TEMP1  HL POINTS TO BYTES LEFT
 MVI A,0C0H   DOUBLE PRECISION SUBTRACTION OF
 SUB M        BYTES LEFT FROM SIZE OF BUFFER
 MOV C,A     (4C0H)
 INX H
 MVI A,04
 SBB M
 MOV B,A
 PUSH B      B HAS BYTES READ
 POP H       NOW H HAS IT
 SHLD TEMP1  NOW IN TEMP1
 LXI H,IFB
 SHLD TEMP4
 POP PSW
 POP D
 POP B
 POP H
 JMP START
RERR CPI 18H  IN CASE THERE IS NO EOF MARK
 JZ EFSET     (A WILL CONTAIN 18H IF EOF)
 JMP ERR1
EFSET XRA A   RESET EOF FLAG
 STA TEMP6
 JMP NRET
WOBUF LDA TEMP3     GET CHARACTER
WOBU2 LHLD  TEMP5   H POINTS TO OUTPUT FILE BUFFER
 MOV M,A            PUT IT THERE
 LHLD  TEMP2        TEMP2 IS COUNTER
 DCX H              BUFFER FULL?
 SHLD TEMP2
 XRA A
 CMP H
 JNZ RES
 CMP L
 JZ WRT             IF SO, WRITE TO DISK
RES   LHLD TEMP5    INCREMENT COUNTER
 INX H
 SHLD TEMP5         STORE IT
 RET                OTHERWISE GET ANOTHER CHARACTER
WRT1 XRA A          RESET EOF FLAG
 STA TEMP6
WRT LDA OFN         DELIMITED WRITE TO DISK
 LXI B,04C0H
 LXI D,OFB
 MVI L,1
 CALL SYS
 DB DWROP
 JMP ERR1
W2 LXI H,04C0H  RESET COUNTER
 SHLD TEMP2
 LXI H,OFB    RESET POINTER
 SHLD TEMP5
 RET
FINISH MVI A,1AH ADD CP/M END OF FILE
 CALL WOBU2
 MVI A,1     THIS PUTS 1 AT THE END FOR DELIMITED WRITE
 CALL WOBU2
 CALL WRT    REST OF OUTPUT BUFFER TO DISK
 LDA OFN
 LXI B,1
 MVI D,128
 CALL SYS
 DB SPAOP
 JMP ERR
 LDA OFN  ENDFILE ROUTINE
 CALL SYS
 DB EOFOP
 JMP ERR
EN MVI A,255  CLOSE ALL OPEN FILES
 CALL SYS
 DB CAOP
 JMP ERR
 CALL SYS  RETURN TO PTDOS
 DB RESOP
MSGI LXI H,MSI
MSGI1 MOV A,M
 CPI 0FFH
 RZ
 MOV B,A
 CALL OUTR
 INX H
 JMP MSGI1
MSGO LXI H,MSO
 JMP MSGI1
MSI ASC 'ENTER INPUT FILE NAME - C/R'
 DB 0DH
 DB 0AH
 DB 0FFH
MSO DB 0DH
 DB 0AH
 ASC 'ENTER OUTPUT FILE NAME - C/R'
 DB 0DH
 DB 0AH
 DB 0FFH
OUTR PUSH H
 PUSH D
 PUSH B
 PUSH PSW
 CALL SOU
 POP PSW
 POP B
 POP D
 POP H
 RET
ERR1 MOV E,A
ERR LXI H,EM
 MOV M,E
 MVI A,84H
 CALL UTIL
 DB UXOP
 JMP ERR
 DB -1
EM DS 1
 JMP EN
TEMP1 DS 2
TEMP2 DS 2
TEMP3 DS 1
TEMP4 DS 2
TEMP5 DS 2
TEMP6 DS 2
IFN DS 1
OFN DS 1
IBUFI DS 10
IBUFO DS 10
OBUFI DS 20
 DB 0AEH
 DW 04C0H
 DB 0
OBUFO DS 20
IFB DS 04C0H
OFB DS 04C0H
 END
