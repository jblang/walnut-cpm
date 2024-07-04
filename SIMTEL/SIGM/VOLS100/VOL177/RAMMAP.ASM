;
;                              RAMMAP.ASM
;
;       Simple program to display key memory locations for CP/M 2.2
;
;                            David L. Ransen
;                               03/25/83
;
;       Adapted from Jack Dennon, in "CP/M Revealed," Hayden 1982.
;
;
;
        ORG     100H
BDOS    EQU     5
GETVER  EQU     12
CONIN   EQU     1
CONOUT  EQU     2
PRSTR   EQU     9
CR      EQU     0DH
LF      EQU     0AH
ESC     EQU     1BH
;
START:  LXI     H,0
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STACK
;
MMP1:   SHLD    MMPA
;
        LHLD    6               ; GET BDOS ENTRY ADDRESS
        SHLD    BDOSE
        LXI     B,-806H         ; COMPUTE CCP BASE ADDRESS
        DAD     B
        SHLD    CCPFWA
;
        DCX     H
        SHLD    TPALWA          ; COMPUTE TPA LAST WORD ADDRESS
        INX     H
;
        LXI     B,800H          ; COMPUTE BDOS FIRST WORD ADDRESS
        DAD     B
        SHLD    BDFWA
        LXI     B,6             ; COMPUTE BDOS ENTRY POINT
        DAD     B
        SHLD    BDOSE
;
        LXI     B,0
MMPA:   EQU     $-2
        DAD     B
        SHLD    CBFWA           ; CBIOS FIRST WORD ADDRESS
;
        LXI     B,3             ; CBIOS WARM BOOT ENTRY POINT
        DAD     B
        SHLD    WRMBT
;
;       DISPLAY MEMORY LOCATIONS
;
        LXI     D,CLRSC
        CALL    PRMSG           ; CLEAR SCREEN (CURRENTLY FOR H/Z-19)
;
        LXI     D,MMPB          ; PRINT DASHES
        CALL    PRMSG
        LXI     D,MMPC          ; PRINT CONSTANTS
        CALL    PRMSG
;
        LXI     H,0
TPALWA: EQU     $-2             ; DISPLAY TPA LWA
        CALL    DHW
        LXI     D,MMPD
        CALL    PRMSG
;
        LXI     H,0
CCPFWA: EQU     $-2             ;DISPLAY CCP FWA
        CALL    DHW
        LXI     D,MMPE
        CALL    PRMSG
;
        LXI     H,0
BDFWA:  EQU     $-2             ; DISPLAY BDOS FWA
        CALL    DHW
        LXI     D,MMPF
        CALL    PRMSG
;
        LXI     H,0
BDOSE:  EQU     $-2             ; DISPLAY BDOS ENTRY POINT
        CALL    DHW
        LXI     D,MMPG
        CALL    PRMSG
;
        LXI     H,0             ; DISPLAY CBIOS FWA
CBFWA:  EQU     $-2
        CALL    DHW
        LXI     D,MMPH
        CALL    PRMSG
;
        LXI     H,0
WRMBT:  EQU     $-2             ; DISPLAY WARMBOOT ENTRY POINT
        CALL    DHW
        LXI     D,MMPI
        CALL    PRMSG
;
        LXI     D,MMPB          ; MORE DASHES
        CALL    PRMSG
        LHLD    OLDSP
        SPHL
        RET
;
;
CLRSC:  DB      ESC,'E'        ; FOR H/Z-19
        DB      CR,LF,LF,'     CP/M 2.2 Key Memory Locations      ',CR,LF,LF,'$'
MMPB:   DB      '----------------------------------------',CR,LF,LF,'$'
MMPC:   DB      '0000  warm boot vector',CR,LF
        DB      '0005  BDOS vector',CR,LF
        DB      '005C  default FCB',CR,LF
        DB      '0080  CP/M record buffer',CR,LF
        DB      '0100  base (FWA) of TPA',CR,LF,'$'
MMPD:   DB      '  Last  Word Address of TPA',CR,LF,'$'
MMPE:   DB      '  CCP   base (FWA)',CR,LF,'$'
MMPF:   DB      '  BDOS  base (FWA)',CR,LF,'$'
MMPG:   DB      '  BDOS  entry point',CR,LF,'$'
MMPH:   DB      '  CBIOS base (FWA)',CR,LF,'$'
MMPI:   DB      '  CBIOS warm boot entry point',CR,LF,'$'
;
;       DHW -- DISPLAY HEX WORD
;              ENTRY: HL = WORD TO BE DISPLAYED
;
DHW:    PUSH    H
        MOV     A,H             ; DISPLAY HIGH BYTE
        CALL    DHB
        POP     H
        MOV     A,L             ; DISPLAY LOW BYTE
;
;       DHB --  DISPLAY HEX BYTE
;               DISPLAY 2 HEX DIGITS
;               ENTRY: A = BYTE TO BE DISPLAYED
;
DHB:    PUSH    PSW
        RRC !  RRC !  RRC ! RRC !
        CALL    DHD
        POP     PSW
;
;       DHD --  DISPLAY HEX DIGIT
;               ENTRY: A, LOW 4 BITS = DIGIT
;
DHD:    ANI     0FH
        CPI     10
        JNC     DHD1            ; IF NOT ASCII 0 THRU 9
;
        ADI     '0'
        JMP     DCH
;
DHD1:   ADI     'A'-10          ; CREATE "A, B, C, D, E, OR F"
;
;       DCH --  DISPLAY ONE CHARACTER
;               ENTRY: A = ASCII CHAR
;
DCH:    MOV     E,A
        MVI     C,CONOUT
        CALL    BDOS
        RET
;
;       FCC --  FILTER OUT CONTROL CODES
;               ENTRY: A = ASCII CODE
;               EXIT:  B = ASCII CHAR
;                      A = UP-ARROW IF CONTROL CODE
;                        = OR BLANK IF NOT
;
FCC:    CPI     20H
        JNC     FCC1            ; IF NOT A CONTROL CODE
;
        ADI     40H             ; MUST BE A CONTROL CODE
        MOV     B,A
        MVI     A,5EH           ; UP-ARROW
        RET
FCC1:   MOV     B,A
        MVI     A,20H
        RET
;
PRMSG:  MVI     C,PRSTR
        CALL    BDOS
        RET
;
RCC:    MVI     C,CONIN
        CALL    BDOS
        RET
;
OLDSP:  DS      2
        DS      34
STACK:
        END

  A,20H
        RET
;
PRMSG:  MVI     C,PRSTR
        CALL    BDOS
        RET
;
RCC:    MVI     C,CONIN
        C