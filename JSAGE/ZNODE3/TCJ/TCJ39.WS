                          Column for TCJ Issue #39

                                  Jay Sage


   For this issue I will discuss some unique new capabilities made possibleç
by NZCOM that have already proved their value and that I hope will beç
exploited to a much greater extent in the future.  I originally had severalç
other issues on my agenda, but Lee A. Hart sent me such an interestingç
article that I wanted to leave plenty of room for it.


                      System Enhancements Using NZCOM

   I'm afraid that many people think of NZCOM as just a way for unskilledç
users to get Z-System running on their computers.  It's true that NZCOMç
accomplishes that, but, as I have asserted often before, NZCOM does muchç
more than that.  It offers possibilities that a manually installed Z-Systemç
cannot achieve.  I would like to describe one of them here and will do soç
first in the context of a problem that arose with the new ZSDOS and ZDDOSç
disk operating systems on some computers.

   Because CP/M was created originally for the 8080 microprocessor, a numberç
of BIOS implementors (the BIOS, or Basic Input/Output System, is theç
hardware-dependent part of CP/M) felt that they could make free use of theç
additional registers introduced with the Z80 chip.  These registers includedç
two index registers, called IX and IY, and a duplicate set of the standardç
registers denoted with primes on the names (e.g., B' or HL').

   This was perhaps excusable at the time, but it is poor programmingç
practice for an operating system to change anything other than what isç
explicitly indicated in the specifications.  Most BIOS writers who have usedç
the Zilog registers have been careful to restore the original values beforeç
exit from the BIOS routines.  Unfortunately, a few BIOSes fail to do that. ç
Among them are the following: Epson QX10, Zorba, Televideo 803 and TPC-1,ç
Oneac On, and the Osborne Executive.  The Bondwell is on the suspect list,ç
and there are probably others we don't know about yet.

   The (mis)use of these registers poses no problem for programs written toç
run on the 8080, but today we are rapidly moving beyond the limitations ofç
the 8080 and making extensive use of the Z80 registers to pack more powerç
into operating system components and application programs.  Today, the Z≠
System, true to its name, is intended to run only on the Z80 or upwardlyç
compatible processors like the HD64180, Z180, or Z280.

   Several users who purchased ZDOS (that is ZSDOS and ZDDOS) found that itç
would not work properly on their computers.  An investigation turned up theç
fact that the BIOSes in those computers were modifying the index registers. ç
This also explained why those same users had been experiencing strangeç
problems with JetLDR, Bridger Mitchell's superb Z-System module loader.  Itç
also explained some mysterious problems I was having with a number ofç
programs (for example, EDITNDR) on my Televideo 803!  The question was whatç
to do about the problem.

   In the ancient days, when computers always came with the source to theirç
BIOS and their owners were always intimately familiar with the proceduresç
for rebuilding their operating systems, the solution would have been toç
rewrite the BIOS with the proper PUSH IX and POP IX instructions to preserveç
the index register values.  But what could we do today for nonprogrammersç
and those without BIOS source code?  NZCOM provided the answer quite nicely!

   As I explained in a column long ago, NZCOM works by creating what I callç
a virtual BIOS (I'll call it VBIOS) lower in memory in order to open upç
space for the Z-System modules between it and the real BIOS (often calledç
the custom BIOS or CBIOS).  The source for this virtual BIOS is available. ç
Except for the warmboot code and some minor complications for IOPç
(input/output processor) support, the standard NZCOM VBIOS module justç
vectors calls that come to it up to the real BIOS.

   But no one says this is all it is allowed to do.  ZDOS authors Camç
Cotrill and Hal Bower found it quite easy to surround the vectors with codeç
to save and restore registers.  First they released ZSNZBI11.LBR, whichç
contained the source and ZRL file (loadable by NZCOM) for a VBIOS thatç
preserved the IX and IY registers for all disk function calls.  Later theyç
discovered that some of the machines changed the index registers even forç
console I/O function calls, and others changed the alternate registers. ç
They then wrote ZSNZBI12.LBR, whose VBIOS preserves all the registers forç
all BIOS functions.

   Instead of having the virtual BIOS routines jump directly to the realç
BIOS, they jump to an intermediate entry point.  For example, the list≠
status vector in the jump table has a JP ILSTST (intermediate list status),ç
and the code at ILSTST is

	ILSTST: LD      A,45
	        JR      DOBIOS

The offset for the BIOS function is placed in the A register and thenç
control is transferred to a general BIOS-calling routine shown in Table 1ç
that implements the register protection.  The routine JPHL referenced thereç
contains only the code line JP (HL), which vectors the CPU off to the BIOSç
with a return to the DOBIOS code.

-----------------------------------------------------------------------------

DOBIOS: LD      HL,CBIOS	; Start with address of real BIOS 
        ADD     A,L		; Add offset in A (never a
        LD      L,A             ; ..carry since on page boundary)
        EXX                     ; Swap to alternate registers
        LD      (HLP),HL	; Save them all in memory
        LD      (DEP),DE
        LD      (BCP),BC
        LD      (IXREG),IX	; Save index registers, too
        LD      (IYREG),IY
        EXX			; Back to regular registers
        EX      AF,AF'          ; Swap to alternate PSW
        PUSH    AF		; Save it on stack
        EX      AF,AF'		; Back to original PSW
        CALL    JPHL            ; Actually call the BIOS!
        EXX			; Restore alternate and index
        LD      HL,(HLP)	; ..registers
        LD      DE,(DEP)
        LD      BC,(BCP)
        LD      IX,(IXREG)
        EX      AF,AF'		; Alternate PSW, too
        POP     AF
        EX      AF,AF'
        RET

; Register save area

BCP:    DEFS    2               ; BC'
DEP:    DEFS    2               ; DE'
HLP:    DEFS    2               ; HL'
IXREG:  DEFS    2               ; IX
IYREG:  DEFS    2               ; IY

        END

Table 1.  Code from ZSNZBI12.Z80 that preserves all index and alternateç
registers across BIOS calls in NZCOM.

-----------------------------------------------------------------------------

   To use this replacement VBIOS, you have to run MKZCM and create an NZCOMç
system with 4 records allocated for the BIOS instead of the standard 2. ç
Because the BIOS must start on a page rather than just a record boundary,ç
MKZCM will sometimes make automatic adjustments to the BIOS size. ç
Therefore, you should specify changes in MKZCM starting with the higher≠
numbered modules; the adjustment in the BIOS allocation should be made last. ç
If an attempt to enter a value of 4 results in MKZCM using 5, then you couldç
go back (if you don't like wasting memory) and make one of the other modulesç
(such as the NDR) one record larger and then respecify a 4-record BIOS.

   There are many other ways that NZCOM can be used to introduce systemç
enhancements without having to make changes in the real BIOS.  As anç
example, we will show how to add support for the drive vector in environmentç
descriptors of type 80H and above (implemented with NZCOM and Z3PLUS).  Theç
drive vector is a 16-bit value stored as a word beginning at offset 34H inç
the environment descriptor.  It specifies which disk drives are actuallyç
implemented on a system.  The lowest order bit in the word is for drive Aç
and the highest for drive P.  A zero in a bit position indicates that theç
corresponding drive is not available.  For example, on my SB180 the bytes atç
addresses ENV+34H and ENV+35H were 7FH and 00H, respectively.  Thus the wordç
value is 007FH or 0000,0000,0111,1111 binary, indicating that I had drivesç
A, B, C, D, E, F, and G. When the hard disk E partition developed a problemç
that made it unusable, I changed the 7FH value to 6FH, thereby disablingç
drive E.  You can display the drive vector using menu selection 3 in theç
SHOW program (ZSHOW for Z3PLUS).

   The ZCPR34 command processor knows about the drive vector and will notç
allow command references to unsupported drives.  But what about programsç
that you run?  Unfortunately, the BIOS generally knows only which drives areç
potentially implemented, and it may try to access a nonexistent drive.  Whenç
'smart' BIOSes encounter this problem, they often prompt the user as to whatç
to do next.  This is fine if you are sitting at the console and can takeç
appropriate action to recover, but if the system is being run remotely,ç
there is generally no way for the remote user to recover.  In fact, becauseç
the 'smart' BIOS uses direct hardware calls to display the "Abort, Retry,ç
Ignore?" message rather than calls through the BIOS vector table, the remoteç
user does not even see the message and just thinks the system has crashed. ç
My Z-Node got hung once that way when I forgot to put a diskette back into aç
floppy drive.  A caller attempted to access it, and when I got home, theç
BIOS was dutifully beeping at me and waiting for me to tell it what to do.

   My first stab at writing a VBIOS that observes the drive vectorç
restrictions is shown in Table 2.  Now that I have read Lee Hart's column, Iç
am sure that this code can be made shorter, faster, or both!  But I willç
leave that as an exercise for the reader.  (I already see one place where Iç
could save a byte.)

   The listing assumes you are starting with the ZSNZBIO described earlier. ç
Just add the extra equate for DRVEC under the /_ENV_/ common block andç
replace the simple ISELDK (intermediate select disk) code with the slightlyç
more complex version shown in the Table.  I put this on my Televideo, andç
the results were most pleasant.  Now when I attempt to access a nonexistentç
drive, the system does not force a direct-CBIOS warmboot that drops me outç
of NZCOM.

-----------------------------------------------------------------------------


; Add DRVEC definition in the ENV common

	COMMON	/_ENV_/
Z3ENV:
DRVEC	EQU	Z3ENV+34H	; Drive vector
CCP	EQU	Z3ENV+3FH
DOS	EQU	Z3ENV+42H

; Modify ISELDK as follows and place it after the DOBIOS code and before
; the data area for register storage.

ISELDK:	LD	HL,(DRVEC)	; Get drive vector
	LD	A,16		; Subtract requested drive
	SUB	C		; .. from 16
	LD	B,A		; .. and put into B
ISELDK1:
	ADD	HL,HL		; Move bits left into carry
	DJNZ	ISELDK1		; Loop 16-<drive> times
	LD	HL,0		; BIOS return code for invalid drive
	RET	NC		; Return if drive vector bit not set
	LD	A,27		; Otherwise, use CBIOS function
	JR	DOBIOS		; .. at offset 27

Table 2.  Code added to virtual BIOS to support the environment drive vectorç
at the BIOS level.

-----------------------------------------------------------------------------

   These two examples of system enhancements by no means exhaust theç
possibilities.  One can implement all kinds of additional features andç
drivers right in the NZCOM VBIOS.  Joe Wright suggested early during NZCOMç
development that one should create an absolutely stripped down CBIOS, oneç
that contains only the functions that are absolutely necessary to get theç
system running and then implement all the bells and whistles in the VBIOS. ç
These extra features would include things like RAM-disk drivers, keyboardç
type-ahead buffers, logical drive swapping facilities, and disk errorç
recovery management routines.  With this strategy, one can actually achieveç
a larger TPA with an NZCOM system than one had under the standard CP/Mç
system, since the CBIOS can be made smaller and the fancy features droppedç
when a larger TPA is more important.

   For example, the "Abort, Retry, Ignore" message should be implemented inç
the VBIOS, with the CBIOS returning from disk errors with standard errorç
codes.  With the normal VBIOS, the error will simply be passed back to theç
DOS, which will report the error in its usual way ("BDOS ERROR on..." in theç
case of the Digital Research BDOS).  A more elaborate VBIOS can detect theç
error, report it to the user, and allow the operation to be retried.  Whenç
the system is running in remote mode, either the simpler VBIOS can be usedç
or the prompt can be vectored properly through the jump table so that theç
remote user will be able to deal with the problem.

   Similarly, one should be able to handle the swapping of logical driveç
names in the VBIOS.  There are a couple of pitfalls to watch out for,ç
however.  If you change logical names, you better make sure that the diskç
system is reset, probably both before and after the swap.  You also betterç
make sure that NZCOM can still find its CCP file, which is normally kept inç
directory A15:.  If you swap the A drive without providing a copy of thisç
CCP in the new A drive, you'll be in serious trouble.  Of course, theç
swapping would be handled by a utility program, and it would worry aboutç
these requirements.  The VBIOS would simply have the code for translatingç
references to a logical drive value in register C into a possibly differentç
physical drive value.

   I hope that this short discussion has given some of you ideas forç
imaginative applications of the new capability offered by the NZCOM virtualç
BIOS.  If so, I would love to hear about them and to see sample code.

                                                                                