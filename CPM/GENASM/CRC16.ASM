        TITLE   CRC16 - Cyclic Redundancy Checksum
;******************************************************************************
;*                                                                            *
;*                                                                            *
;*                         Improved CRC16 Routine                             *
;*                                                                            *
;*                                                                            *
;*      This routine performs CRC16 cyclic redundancy checksum calculations.  *
;*  It makes use of an idea given in the IEEE Micro publication by Aram       *
;*  Perez, and represents a considerable improvement over some of the         *
;*  methods used previously.  It receives a 16-bit CRC in BC and              *
;*  the next data byte in E.  It returns the updated CRC in BC.               *
;*                                                                            *
;*      The first step is to XOR the data byte into the right half of the     *
;*  the CRC.  Let the result of this be denoted by:                           *
;*                                                                            *
;*                   a b c d e f g h i j k l m n o p                          *
;*                                                                            *
;*  After the eight CRC16 steps, with the x^16+x^15+x^2+1 polynomial, this    *
;*  should become:                                                            *
;*                                                                            *
;*                   X i j k l m n o p 0 0 0 0 0 0 X                          *
;*                   + + + + + + + + + + + + + + + +                          *
;*                   0 X i j k l m n o p 0 0 0 0 0 0                          *
;*                   + + + + + + + + + + + + + + + +                          *
;*                   0 0 0 0 0 0 0 0 a b c d e f g h                          *
;*                                                                            *
;*  where X represents the parity of the 8 bits i,j,k,l,m,n,o,p, and          *
;*  where + represents the XOR of the respective columns.  The code below     *
;*  carries out this process directly, making use of the 8080's parity flag   *
;*  for finding X.  [Note that since the routine uses this parity flag        *
;*  after an XRA instruction, the routine will work properly even on a        *
;*  Z80 microprocessor.]                                                      *
;*                                                                            *
;******************************************************************************
;*                                                                            *
;*      Entry:                                                                *
;*      BC = old CRC16                                                        *
;*      E = next data byte                                                    *
;*                                                                            *
;*      CALL    CRC16                                                         *
;*                                                                            *
;*      Exit:                                                                 *
;*      BC = new CRC16                                                        *
;*      A, D, & E also affected                                               *
;*                                                                            *
;*                                                                            *
;*****************************************  R. Stafford - Aug. 9, 1983 ********
;
        RSECT   ROM
        INTERN  CRC16

CRC16:  EQU     $
; Assume the current 16 bit CRC is in BC and the next data byte in E.
        MOV     A,E
        XRA     C       ;A now has [i j k l m n o p] & parity flag has X
        MOV     C,B     ;Put [a b c d e f g h] in C
        MOV     D,A     ;Put [i j k l m n o p] in D
        JPE     CRCJ    ;The parity flag has X (even on a Z80)
        XRI     2       ;XOR X into A in bit 1
CRCJ    XRA     D       ;A now has [0 0 0 0 0 0 X 0]
        MOV     E,A     ;Now E = [0 0 0 0 0 0 X 0]
        RAR
        RAR             ;Move X into carry flag
        MOV     A,D     ;Put [i j k l m n o p] back into A
        RAR
        MOV     D,A     ;Shift it to [X i j k l m n o] in D
        MOV     A,E     ;Get [0 0 0 0 0 0 X 0] from E
        RAR             ;This sets carry to zero
        MOV     E,A     ;Put [p 0 0 0 0 0 0 X] back into E
        MOV     A,D     ;Now proceed with yet another shift
        RAR             ;Get [0 X i j k l m n] in A
        MOV     B,A     ;Save it in B
        MOV     A,E     ;Then get [p 0 0 0 0 0 0 X]
        RAR             ;Shift it to [o p 0 0 0 0 0 0]
        XRA     E       ;Then XOR in [p 0 0 0 0 0 0 X]
        XRA     C       ;Finally XOR in [a b c d e f g h]
        MOV     C,A     ;Establish this as the low byte of new CRC
        MOV     A,D     ;Now get [X i j k l m n o]
        XRA     B       ;XOR it with [0 X i j k l m n]
        MOV     B,A     ;This constitutes the upper byte of new CRC
        RET             ;Return with updated CRC in BC

; End of CRC16
