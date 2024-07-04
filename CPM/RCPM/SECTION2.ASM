; SECTION2: This program changes the user number on an RCP/M system in which 
;  the USER command has been removed (or renamed)
;  (The program is named SECTION@ because my origional section program was
;     a 4k disaster written in C (Moral: never send a high-level language to
;     do a low-level job). The name (Hopefully) won't confilict with other, 
;     similar programs)
;
;  By Nick Holland, 1-8-85, released to Public Domain 8-24.
;       ^
;       | <- Sysop of East Detroit Heath/Zenith BBS (313-772-0417 evenings only)
;
; PURPOSE: I origionaly wrote this program to make my bulletin board more 
;  useable. My board had files for CP/M, MS-DOS, CP/M-86, BASIC, Pascal, etc
;  all jumbled into two winchester partitions. Clearly, it was not very easy 
;  to find those files that interested the caller. At this time, I had renamed 
;  the USER command, so that only user 0 (for the general public) and user 15
;  (for my maintainence) were in use. I had tried a USER program, but the 
;  concept of user levels seemed to escape many of my MS-DOS users, who I tried 
;  to serve, not to mention that it can be hard to remember what is on what 
;  user level. What I needed was a program that was quick and easy to use, but 
;  ALSO would present a menu to the caller, telling him what was where, if 
;  neccessary. This is my solution to the problem. Typing in SECTION alone 
;  gives a menu, telling the user where he is, and where he can go from there.
;  Typing SECTION x, where 'x' is a decimal number, changes to the desired 
;  section number, returning the caller to RCP/M, without a warm boot making
;  the program quick in operation, even on floppy based systems. 
;
; MODIFICATION: I have much reason to believe that many people will want to 
;  change this program to suit their individual needs. I am distributing this
;  primarily to give other sysops ideas, and a possible base to work with. 
;   Ideas for expansion/extension:
;    1) More than 10 sections (0-9): I like the one key response to the menu, so
;       I did not incorporate that many sections into this program. The other
;       reason I did not do this my self is that I use the higher user levels 
;       for files that are uploaded. Each section has it's own upload area, so
;       I can sort out the files easier (is SD.OBJ for MS-DOS or CP/M?)
;    2) Change drive and user number: Perhaps not a bad idea if you suport 
;       machines that are not commonly used with more than one drive 
;       (Commadore, Apple...), since the caller may forget to check other 
;       drives.
;    3) Mneomics for sections instead of numbers: Some people like 'em, I don't
;       not. My twisted mind remembers single digits better than whole "words". 
;       When I use the SYSOP BBS, I have difficulty remembering if the section
;       name is RCP/M or RPCM, COMM or COM, etc. Numbers also make it easier to
;       check all areas for new files (Start at section 0 and work up) Numbers
;       are also better if the user can not type or spell (like me).
;
;
;     OPERATION:
;     ==========
;
;  A>SECTION        {displays menu, prompts for section.}
;  A>SECTION 3      {Changes to section 3, no other display}
;  A>SECTION <garbage> {Displays menu, like with no parameters **}
;          (** If there is a valid section number within the garbage, it is 
;                recognized, and used)
;
;  1/8/84    -N. Holland
;
        
BDOS:   EQU     0005H   ; BDOS call address
CONIN:  EQU     01H     ; BDOS Console in
CONOUT: EQU     02H     ; BDOS Console out
PRINTS: EQU     09H     ; BDOS PRINT STRING
USERNO: EQU     20H     ; BDOS Get/Set user #

LF      EQU     0AH     ; Line Feed
CR      EQU     0DH     ; Carrage Return
MAX     EQU     5       ; MAXIMUM user level

        ORG     100H
        NOP             ; This forces a 00h byte somewere in the program's 
                        ; search for a section number (that is how it quits 
                        ; looking). I know, it should not be necessary, but 
                        ; I am a little paranoid. (Also good for hacked CCP's)
        LXI     H,0080H ; This location has # of bytes entered after prog. name
LOOP1:  MOV     A,M     ; Get byte in command line
        ORA     A       ; Set flags
        JZ      MENU    ; No characters after command
        CALL    CHECK   ; Is it a good section?
        RNZ             ; If good (A <> 0), return to CP/M 
        INX     H       ; point to next byte
        JMP     LOOP1   ; check it...

; If program end up here, either no valid section number character was found, 
;  or there was no command tail. In either event, display the main menu.
; Whatever was on the command line (if anything), was not a valid SECTION #
;   so display menu
;
MENU:   MVI     C,PRINTS        
        LXI     D,DMENU ; point to begining part of menu.
        CALL    BDOS    ; Display menu.

        MVI     C, USERNO ; Tell the caller where he currently is (completing 
        MVI     E, 0FFH ;                                          the menu)
        CALL    BDOS    ; get user number
        ADI     '0'     ; make it an ASCII character
        MVI     C, CONOUT
        MOV     E, A    ; move it to A
        CALL    BDOS    ; Show it to the caller

PROMPT: MVI     C,PRINTS ; Prompt user to enter SECTION number
        LXI     D,DPROMPT
        CALL    BDOS    ; Display prompt message.

        MVI     C,CONIN
        CALL    BDOS    ; Get user's response
        CALL    CHECK   ; See if good SECTION number
        JZ      PROMPT  ; Bad Section number, so re-PROMPT user.

        RET             ; RETURN TO CP/M

; CHECK: Tests the ASCII character in register A. If in the range of '0' to
;   'MAX', changes to that user level, and returns FFh in A. If not valid, 
;   returns 00h in A, and takes no other action. May alter all registers.
;
CHECK:  SUI     '0'     ; If carry here, then A is too small
        JC      ERREXIT ; Exit with error
        CPI     MAX+1   ; If no carry, then A too big
        JNC     ERREXIT 

; The value in A is a valid user number, so change user number, and exit
; showing success.
; To change user levels, there are three ways to do it:
;  1) BDOS call: Lasts untill first warm boot.
;  2) Change byte at 0004h (drive/user): Takes effect only after Warm Boot
;  3) Do both of the above: Makes change last, but eliminates the wait for the 
;      Warm Boot. That is what I do in this program

        MOV     B,A     ; hide desired user level in B.
        LDA     0004H   ; Get drive/user byte
        ANI     0FH     ; Strip current user #, leave drive number.
        MOV     C,A     ; stash drive # in C
        MOV     A,B     ; restore user # (in form 0000uuuu)
        RLC             ; (000uuuu0)
        RLC             ; (00uuuu00)
        RLC             ; (0uuuu000)
        RLC             ; (uuuu0000): the desired position
        ADD     C       ; (uuuudddd): Re-created drive/user byte
        MVI     C,USERNO 
        MOV     E,B     ; Get the user number again
        CALL    BDOS    ; change user # through BDOS call also,
        ORI     0FFH    ; and return OK code
        RET
ERREXIT: XRA    A       ; Set A=0, and set zero flag.
        RET

; Text for menus, prompts: You will almost certainly wish to change this.

DMENU:  DB CR, LF, LF
        DB '         Available Sections:', CR, LF, LF
        DB '   0) Bulletin Board, General Interest', CR, LF
        DB '   1) CP/M-80 related files', CR, LF
        DB '   2) CP/M-86 files', CR, LF
        DB '   3) Generic MS-DOS files', CR, LF
        DB '   4) IBM & compatable files', CR, LF
        DB '   5) General High-level Language stuff', CR, LF, LF ; skip line
        DB ' Currently in Section $'

DPROMPT:
        DB CR, LF, LF, LF, ' Enter desired Section Number (0 - 5) ->$'

 
        END

                                                                 