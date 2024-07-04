        PAGE  80,132
TITLE   Twenty Files - A dBASE III Plus Callable Module

        ; by James Troutman (JT)
        ; Version 1.00

COMMENT *
   This is the assembly language source code for a module that can be
   LOADed and CALLed in dBASE III Plus.  It requires DOS 3.xx or greater.
   When assembled (with MASM) it should be LINKed and converted to a binary
   (.BIN) file with EXE2BIN.  It uses what is currently an undocumented
   feature of DOS -- namely the ability to move the file handle table and
   increase its length to allow more than the default 20 open files.
   However, since dBASE itself imposes a limit of 20 files, it does not
   make sense to increase the handle table to more than 25 entries.  This
   allows DOS to have its 5 (STDIN, STDOUT, STDERR, STDAUX, and STDPRN) and
   still leave room for 20 active files in dBASE.

   [Actually, the dBASE programmers were clever enough to close the STDAUX
   device (no one uses it, anyway) and use its freed handle for the dBASE
   overlay file.]

   A problem with an earlier test version of this module has been fixed.
   It no longer makes any difference how many times the module is LOADed or
   CALLed -- the expanded handle table is no longer stored within the
   module's memory, but in an unused (I hope!) area of dBASE's Program
   Segment Prefix.  Although I have tested this, PLEASE use it
   with caution, and please let me know of any problems (or successes!)
   that you have with it.

   SYNTAX:
           LOAD Twenty
           CALL Twenty

   ... and get ready to open your 20 files!

   Good Luck!
   James Troutman (JT)
   CompuServe PPN 74746,1567

   P.S. See the May, 1986 issue of Dr. Dobbs Journal, pp 107-108 for more
   information about how and why this program works.  If I get ambitious, I
   will upload a version with a .DOC file that will explain some of the
   theory of why it works.

*

DosInt        EQU  21h   ; the standard DOS interrupt number
Unused        EQU  0FFh  ; used by DOD to mark a handle as unused
OurLength     EQU  25    ; the length of OUR table
DefLength     EQU  20    ; the length of THEIR table

; Macro definitions

GetDosVersion Macro
        MOV   AH,30h
        INT   DosInt
        EndM

; found these next two macros on the IBM SIG; nifty!

Save    Macro   R1,R2,R3,R4,R5,R6,R7,R8,R9,R10
        Irp     Rx,<R1,R2,R3,R4,R5,R6,R7,R8,R9,R10>
        IfNb    <Rx>    ;If this parm not blank
        PUSH    Rx      ;Save the register
        EndIf           ;End IfNb
        EndM            ;End Irp

Restore Macro
        Irp     Rx,<R10,R9,R8,R7,R6,R5,R4,R3,R2,R1>
        IfNb    <Rx>    ;If this parm not blank
        POP     Rx      ;Pop the register
        EndIf           ;End IfNb
        EndM            ;End Irp
        EndM            ;End of Restore macro
        EndM            ;End of Save Macro

; the actual code starts here

Cseg   SEGMENT PARA PUBLIC 'CODE'
       ASSUME CS:Cseg,DS:Dseg,ES:Dseg,SS:Nothing

Twenty  PROC   FAR
        ORG    0

        Save    AX,BX,CX,DI,SI,DS,ES   ; not necessary, but a good habit

        GetDosVersion     ; Twenty will ONLY work with DOS 3.xx

        CMP     AL,3
        JB      Finished   ; return if it's not DOS 3 or greater
        MOV     AH,62h  ; get the PSP of the active process (i.e., dBASE)
        INT     DosInt
        MOV     ES,BX   ; and point our DS and ES at it
        MOV     DS,BX
        CMP     HndlTblSize,20 ; see if the current handle table has
        JNE     Finished       ; exactly 20 entries; if not, exit.
                               ; The assumption is that, if there are
                               ; not exactly 20 entries, someone (maybe us!)
                               ; has already tinkered with the table

        CMP     HndlTblOffs,OFFSET DefHndlTbl ; if table is at a different
        JNE     Finished       ; offset, let it be

        CMP     HndlTblSeg, BX ; and if the Handle Table has
        JNE     Finished       ; already been moved to another segment,
                               ; we don't want to tinker with it

        MOV     AL,Unused    ; fill our new handle table (at OurHndlTbl)
        MOV     CX,OurLength ; with closed (0FFh) handles
        LEA     DI,OurHndlTbl
        CLD
REP     STOSB

        MOV     CX,DefLength ; now move the contents of the old table into the new
        LEA     DI,OurHndlTbl
        LEA     SI,DefHndlTbl
REP     MOVSB
        MOV     AX,OurLength   ; now tell DOS that our new table can have 25 entries
        MOV     HndlTblSize,AX
        LEA     AX,OurHndlTbl  ; and what the offset of our new table is
        MOV     HndlTblOffs,AX

Finished:
        Restore
        RET              ; return to dBASE

Twenty  EndP
Cseg    EndS

COMMENT *
  Our DS and ES registers will be set to point to the Program Segment Prefix
  of dBASE.  All the locations that they will reference are defined below
*

Dseg    Segment Para Public 'DATA'

        ORG   018h
DefHndlTbl  Label  Byte     ; where the handle table is by default

        ORG   032h
HndlTblSize  Label  Word    ; size of the handle table

        ORG   034h
HndlTblOffs  Label  Word    ; offset of the handle table

        ORG   036h
HndlTblSeg   Label  Word    ; segment of the handle table

        ORG   05Ch
OurHndlTbl   Label Byte    ; normally the first File Control Block in dBASE's PSP
                           ; currently unused by dBASE
Dseg    EndS

        End     TWENTY

