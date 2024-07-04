FILE:    TPWARMST.PAT
VERSION: 1.00
AUTHOR:  Ralph Iden

The following patches for Turbo Pascal versions 1.00, 2.00, and 3.01
modify your program so that it doesn't automatically perform a warm
boot at the conclusion of the program.

RCP/M and BBS programs can eliminate the needless reloading of CP/M
thus saving a little (in some cases, a great deal) of time.

The principal used is as follows:  Instead of a jump to the CP/M warm
start vector (0000h), we make the program execute a return which
means, I guess, a return to the CCP (Console Command Processor).  In
order to successfuly accomplish this, we must squirrel a copy of
the stack pointer as it existed before the Pascal program was run.

<WARNING: AS I WAS WRITING THIS, A THOUGHT CAME INTO MY HEAD.  IF BY
 EXECUTING A RETURN, WE ARE JUMPING TO THE CCP, WE MUST INSURE THAT
 IT ISN'T OVERWRITTEN OR THE SYSTEM WILL CRASH.  YOU SHOULD PROBABLY
 SET THE TOP OF MEMORY OF THE PROGRAM TO BE SOMEWHAT LESS (2K???)
 THAN THE BEGINNING OF BDOS (ADDRESS LOCATED AT 0006H).  THIS WAY,
 THE PASCAL PROGRAM WON'T CLOBBER THE CCP AND IT WILL STILL BE
 THERE WHEN WE ARE READY TO RETURN.>

Whenever you modify a program for a soft warmstart, note the contents
of 0101 and 0102.  Move these values to 010B and 010C respectfully.
If you change the starting address of your Pascal program, these values
will not be as shown below.

------------------------------------------------------------------------

VERSION 1.00

   Address          Old                        New
   -------  --------------------   --------------------------
    0100:   C3 76 1D   jp  start    C3 06 01     jp  savstk
    0103:   (No change)             (No change)
    0106:   (Copyright message)     ED 73 0D 01  ld  (010D),sp
                                    C3 76 1D     jp  start
     Original stack storage -->     00 00        dw  0000
    010F:                           ED 7B 0D 01  ld  sp,(010D)
     (Return to CP/M via CCP)       C9           ret              


    1D72:   2A DF 00   ld hl,(00DF) C3 0F 01     jp rststk
            E9         jp (hl)

    00DF contains the address to jump
    to at program end and is set to
    0000H by the Pascal runtime.


------------------------------------------------------------------------

VERSION 2.00

   Address          Old                        New
   -------  --------------------   --------------------------
    0100:   C3 C9 1F   jp  start    C3 06 01     jp  savstk
    0103:   (No change)             (No change)
    0106:   (Copyright message)     ED 73 0D 01  ld  (010D),sp
                                    C3 C9 1F     jp  start
     Original stack storage -->     00 00        dw  0000
    010F:                           ED 7B 0D 01  ld  sp,(010D)
     (Return to CP/M via CCP)       C9           ret


    1FC5:   2A DF 00   ld hl,(00DF) C3 0F 01     jp rststk
            E9         jp (hl)

    00DF contains the address to jump
    to at program end and is set to
    0000H by the Pascal runtime.


------------------------------------------------------------------------

VERSION 3.01

   Address          Old                        New
   -------  --------------------   --------------------------
    0100:   C3 E3 20   jp  start    C3 06 01     jp  savstk
    0103:   (No change)             (No change)
    0106:   (Copyright message)     ED 73 0D 01  ld  (010D),sp
                                    C3 E3 20     jp  start
     Original stack storage -->     00 00        dw  0000
    010F:                           ED 7B 0D 01  ld  sp,(010D)
     (Return to CP/M via CCP)       C9           ret


    20DC:   C3 00 00   jp warmstart C3 0F 01     jp rststk

------------------------------------------------------------------------
