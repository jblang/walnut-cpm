advcpm.b34	Advanced CP/M for TCJ #34

.h1	=	main heading
.h2	=	secondary heading
@I{...}	=	set in italics

                                Advanced CP/M
                        Extending the Operating System
                             Bù Bridger Mitchell
                        The Computer Journal, Issue 34
                          Reproduced with permission
                           of author and publisher



Sooner or later, the CP/M user bumps up hard against the limitations
of the operating system and wonders -- can something be done?  Yes,
CP/M can be enhanced at several levels.

.h2  Command Processor Extensions

A great deal of effort has been directed to improving the external,
command-processing part of CP/M.  The "command shell" is readily
replaced; it is the most immediately noticed component; and it
is can be extended by placing added code in files that
can be manipulated by the existing system.  Z3PLUS, NZ-COM, and ZCPR34
are the latest achievements at this level; they both replace the
command processor and provide well-defined resident buffers for
communication between successive tasks.  There have been a number of
other replacement command processors, such as CNIX, CONIX, and QPM.

.h2 BDOS and BIOS extensions

The next level of extension is adding new operating system functions
-- extra BDOS calls.  CP/M Plus provides a particularly convenient
method, called a Resident System Extension (RSX), for adding such
capabilities.  Under CP/M Plus, an RSX can be attached to a program
that need extended services and loaded automatically along with the
original program.  It is rather easy to modify existing BDOS
functions, for example, to keep statistics on the frequency with which
key files are accessed.  

More elaborate RSXs have been developed for CP/M Plus to
emulate the CP/M 2.2 BIOS file functions so that programs that make
direct BIOS calls can run under CP/M Plus by attaching the necessary
RSX but leaving the program itself unchanged.  The most complex CP/M
Plus RSX is the brand-new Z3PLUS system.  Within the single RSX are
the ZCPR34 command processor and program and RSX loader, the Z-System
buffers for named directories, resident commands, messages, command
line, file control block, and environment descriptor.

However, more basic changes to CP/M 2.2, such as adding time and
datestamping or redirection of console and printer services, are much
more difficult.  They are necessarily inner extensions to CP/M and
require intimate knowledge of the BDOS and BIOS.
ŠAnother area that frequently needs extension is an interface to the
hardware.  The original BIOS may provide for only a limited number of
disk formats.  Function keys that transmit escape sequences may
need to be timed and mapped into defined character strings.  Printers
could need character translation tables to generate control sequences
or foreign characters.  These system extensions are primarily BIOS
modifications.

The most extensive extension of CP/M 2.2, and the most complex piece
of software I have ever written, is BackGrounder ii.  It is installed
as an RSX that makes extensive modifications to selected BIOS and BDOS
functions, replaces the command processor, and adds virtual swapping
memory to the basic system.  The result is effectively @I(two) virtual
CP/M computers on one machine, with user-controlled ability to switch
between two running programs at any time, and to preserve the exact
screen display of each on most terminals.

.h2 RSXs for CP/M 2.2

An RSX is not necessarily the first, or the best, choice for adding
capability to a computer system.  The operating system can be extended
by rewriting the BIOS (provided the source code is still available!).
This is the most fundamental approach.  Specific to one computer, it
is permanent and totally non-portable.

The system can be extended for only a single application, as when a
program is run by first loading a debugger.  Quick and dirty,
this approach is sometimes useful for temporarily modifying
system behavior or pre-testing a more permanent approach.

A resident system extension is a versatile, intermediate
approach.  An RSX can be installed and left in place to extend
the system for as long as it is needed, then removed to restore
the original system and full memory.  If well designed, it can be
quite portable.   It can be used to add both BDOS and BIOS
features to the vanilla CP/M 2.2 system.  And several RSXs can be used
together to combine system power.

In this issue's column I discuss System Extensions that modify the
behavior of the BDOS and/or BIOS.  Because these services must
essentially be available at all times (whenever a BDOS or BIOS call is
made), the extension code must be _resident_.  This is unlike
extensions of the command processor, which can be reloaded from the
system tracks (or from a file) when a new command is ready for
processing.

I will limit the examples to extensions for the CP/M 2.2 operating
system (and its clones).  CP/M Plus already includes RSX capability for
BDOS (but not BIOS) extensions and it also includes provision for
character-device redirection (so that, for example, the printer output
can be diverted into a file).  The basic ideas, however, carry over to
CP/M Plus.  Indeed, I have used them effectively in implementing both
Z3PLUS and DosDisk on CP/M Plus computers.Š
.h2 No Free Lunch

Although smart coding and clever uses of the RSX concept can greatly
extend the vanilla CP/M system, there are limits imposed by a 64K
address space Z-80 operating system.  As I was preparing this column a
potential DosDisk customer called, hoping that DosDisk would let him
run Lotus 1-2-3 on his Z-80 computer with 8 inch disks!  I trust that
anyone who has read this far has somewhat more modest expectations.


.h1 The Conventional CP/M 2.2 System

In the remainder of this column I will describe how an RSX modifies
the conventional memory map and flow of control, using a standard RSX
header data structure.  We will then turn to a complete example.

In order to see how RSXs fit into the CP/M 2.2 system, let's first
review a few key points about a "vanilla" system.

The end of the TPA (transient program area), the memory available to
application programs, is specified by the address stored on page-zero
at location 0006.  Initially, that value is the address of the entry
to the BDOS, and a "call 5" instruction will jump directly to the
BDOS.  Beginning at the address whose value is stored at 0006, memory
is said to be "protected" -- it is not available to applications, and
data and code in that area should remain "resident" from one
application to the next.

The command processor is assembled or linked to be loaded in the top
2K of the TPA memory.  The command processor is not resident, and that
2K of memory is available to applications.  Therefore, on each
warm-boot -- a jump or call to 0000 -- the BIOS reads a fresh copy of
the command processor into high memory.  (It may also read in a fresh
copy of the BDOS, depending on the implementation in the BIOS.)

Figure 1 shows the essential flow of control.  The address at 0006 is
"bdos+6", the entry to the BDOS, and the TPA extends from 100h to
bdos+5.  A jump to 0000 vectors to "bios+3", which jumps to "bioswb",
the BIOS warm-boot routine.  That routine reloads the command
processor, installs fresh values of "bios+3" and "bdos+6" at 0001 and
0006, and then jumps to the command processor entry "ccp+3" to process
the next command.

.h1 The Standard RSX Header

In order to insert a resident extension into this scheme we must
deal with memory management, BDOS and BIOS calls, provide for
removal of the RSX when it is no longer needed, and anticipate
the loading of other RSXs while this one is active.

In addition to being intrinsically complex, implementing all of this
is tedious and error-prone.  Several years ago, to provide a standard
approach, I established a Plu*Perfect Systems RSX header -- a uniform
data structure at the beginning of every RSX -- to permit several RSXsŠto coexist peacefully.  And for this column I extended JetLDR to
recognize a relocatable RSX module in named-common ZRL relocatable
format and load it automatically.

The header (Figure 2) begins with three jumps to routines in the RSX
-- to the BDOS intercept routine "rsxstart", to the warm-boot
intercept routine "rsxwb", and to the removal routine "rsxremove".

Next come three addresses.  First, "rsxwba" is the address of the
(original) BIOS warmboot vector which is used to, hopefully,
correct the problems created by programs that erroneously change
the contents of 0001.  The second word is the "protect" address,
the lowest byte in the RSX that must be in protected memory. 
This is followed by the address of the nul-terminated ascii
name of the RSX.

Two jumps and a final word complete the header.  The chain of a
warm-boot (jump 0000) flows through "rsxnext", which points to
either the next-higher RSX, or to the command processor entry.
Similarly, the call BDOS chain flows through "next", which points
to either the next-higher RSX, or to the BDOS entry.   The final
item, "nextwb" holds the address from the BIOS warm-boot vector
at the time the RSX is loaded, so that it can be restored by the
remove routine.


---------------------------------------------------------------------
		 Figure 2.  Standard RSX Header

rsx:	jp	rsxstart	; BDOS intercept		;  00
	jp	rsxwb		; warm-boot intercept		; +03
	jp	rsxremove	; remove-rsx entry		; +06
rsxwba:	dw	$-$		; original 0001 value		; +09
rsxprot:dw	rsx		; lowest rsx address		; +0B
	dw	rsxname		; -> rsx name			; +0D
rsxnext:jp	$-$		; -> next wb or ccp entry	; +0F	
;
next:	jp	$-$		; -> next rsx or bdos		; +12
nextwb:	dw	$-$		; original bios+4 addr		; +15

---------------------------------------------------------------------

.h1 Adding an RSX to Memory

In order to add an RSX to a running system, we must arrange to

  - allocate sufficient memory for the RSX
  - deduct that memory from the available TPA, so that
    an application will not attempt to use the memory occupied by the RSX
  - prevent the BIOS from undoing the memory allocation at the next warm-boot

We will locate the RSX in high memory, immediately below the command
processor -- see Figure 3.  To do this, we change the value at 0006 toŠpoint to the first byte of the RSX, and arrange to have a jump
instruction there that (eventually) causes control to enter the BDOS
(this is the initial jump in the standard RSX header).  The TPA is now
reduced to the area 100h to "rsx1-1".

To keep the BIOS routine "bioswb" from undoing our handiwork by
resetting the value of 0006, we must either modify the "bioswb"
routine, get control back @I{after} that routine has completed, or
prevent it from executing.  Prevention is the only portable solution;
and it must be done intelligently.

.h2 The System Loadstone

The "obvious" method of bypassing the warm-boot routine is to change
the address at 0001 to point to a copy of the (modified) BIOS jump
table located in the RSX.  However, this would be fundamentally wrong,
because this is the @I{one} address in the CP/M system that must
remain fixed.  Why?  Consider what will happen when a second RSX is
being loaded.  It will be unable to locate the BIOS and therefore
cannot correctly intercept BIOS functions!

@I{The warm-boot address at 0001 should never be altered!}  It is
the one fixed point, the lodestone, of the entire CP/M system.
Instead, the warm-boot chain should be intercepted at the BIOS
vector (at bios+4) and redirected to the RSX from that point.

Unfortunately, this absolutely essential role of 0001 has apparently
not been widely understood.  Both Digital Research (in XSUB) -- the
designers of CP/M! -- and MicroPro (in the WordStar "R" command)
occasionally commit the error of changing 0001, and their mistakes
have been perpetuated by several public-domain programs as well.

Figure 3 shows a correctly modified warm-boot chain with the RSX
installed. At 0000, control continues to jump to the BIOS, where it is
@I(then) redirected to "rsx1+3" and then to the RSX's warm-boot
routine.  Eventually, control flows to the copy of the command
processor that is already in memory, bypassing the bios warmboot
routine and without reloading the command processor. We will cover the
details of the RSX warmboot routine in the example below.


.h2 A Second RSX

Adding a second RSX is similar to loading the first one (see
Figure 4) and involves splicing the new RSX into the BDOS and
warmboot chains.  Memory is allocated below the first RSX, 0006 is
redirected to the head of rsx2 where BDOS calls are intercepted
and eventually vectored to rsx1.  The warm-boot intercept at
bios+4 is redirected to rsx2+3, which eventually vectors to
rsx1's warmboot routine.

.h2 Removing an RSX

The standard RSX header includes an entry that is called to
remove the routine.  It deallocates the RSX's memory and removesŠitself from the BDOS and warm-boot chains.  It also removes
its BIOS intercepts, if any.  If there is more than one RSX in
memory, the lowest one must be removed first, to ensure that
the addresses (or data) that are restored are correct.  Each
RSX's remove routine first determines that it is, in fact, lowest
before executing the rest of the removal code.

The standard header anticipates that most RSXs will be self-removing,
provided that they are the bottom RSX when the remove entrypoint is
called.  However, some RSXs, such as DateStamper and DosDisk, make
extensive modifications to the BIOS and BDOS.  A good deal of
additional code and data would have to be resident in the RSX for
these RSX's to be self removing.  Therefore, these RSXs are removed
by their own customized loaders.  If the remove entrypoint is called
by any other program it will do nothing except to return the carry
flag clear, indicating that the RSX has not been removed.


.h1  OKDRIVES, or, Who's On Line?

This is the third Advanced CP/M column, and by now some readers
will have anticipated my penchant for turning to an actual
application to illustrate the technical subject at hand.  This
example grew out of a conversation with Ben Grey, who was seeking
a general-purpose method of limiting access to certain drives on
a remote system.

Many users have computers with a mix of actual and "missing"
logical drives.  For example, A: and B: might be floppies and M:
a ram disk.

How can an application program determine whether it should
attempt to use a particular drive?  Simply trying to select the
drive with a BDOS call is playing Russian roulette.  If the drive
is invalid, or doesn't exist, the BDOS will complain with an
error message and terminate the application with extreme
prejudice -- an abrupt warm-boot.

ZCPR34 allows the user to specify a vector of valid drives,
stored in the Z-System extended external environment at offset
34h.  The ZCPR34 command processor tests this vector before
attempting to log in a drive, and the same test can be made by an
application once it determines that it is indeed running in a
system with an extended external environment.  The extensions
are listed in my previous Advanced CP/M column.

Frequently, however, the programmer wants his application to run
smoothly on other CP/M systems that aren't (yet) running ZCPR34. 
And users occasionally need a method of taking an erratic drive
"off line" for maintenance. Is there a general, portable method
of (1) determining which drives are currently available? and (2)
making individual drives inaccessible?
ŠOKDRIVES in Figure 5 is one method of dealing with this
challenge.  It is a small RSX that maintains a vector of valid
drives and monitors all BIOS disk-select calls.  If a drive is
selected that is not in the vector, it returns a select error. 
Otherwise, it allows the BIOS to select the drive.  In order to
set and change the list of valid drives, the RSX adds one BDOS
function to the system. That function call serves the dual
purpose of setting the valid (and invalid) drives, and reporting
what the current setting is.

.h2 Structure of the RSX

OKDRIVES is written to be assembled into a ZRL (Z-ReLocatable)
file and loaded with JetLDR, which I also described in the
previous column.

The RSX is made up of the standard RSX header, custom code to perform
the operations on the valid-drives vector, and an initialization
section.  I have written the RSX in a quasi-modular fashion, so that
almost all of the tedious code to install and remove the RSX can be
copied in a few blocks and reused in any other RSX.

This RSX uses one extended BDOS function number -- 241.  When the
RSX has been installed and the BDOS is called with this function
number, it will set a new vector of valid drives (if DE is
non-zero), or report the current vector (when DE is zero).  For
example, to make drives A:, B: and D: valid, call the BDOS with C
= 241, DE = 11 = 1011b.  

The RSX must have a module name of the form "RSX...", so that
JetLDR can identify it.  Following that, the standard header
begins the code segment at label "rsx:".

Next come the unique data and code for this RSX, beginning with
its nul-terminated ascii name and the vector of valid drives. 
The static value of the vector is assembled with all drives
enabled.

The action begins at "rsxstart".  Every BDOS call is intercepted here
and tested for this RSX's function number.  Most of the time, it will
be some other function, and so control jumps to "next" -- and then on
to either an RSX immediately above this one, or the BDOS.  However,
when the function number is for this RSX, the routine proceeds to test
DE for zero and either load the valid-drives vector into HL, or set
the vector to the value in DE.  In either case, the RSX returns to the
caller.  

That's all there is to the added BDOS function.  But to make it work,
the RSX must also intercept the BIOS select-disk routine, at
"rsxseldsk".  The code checks the requested drive number against the
valid-drives vector, using a simple loop that does a 16-bit left shift
into the carry flag.  If the drive is not active, it returns the BIOS
select error (HL = 0).  Otherwise, it continues to the BIOSŠselect-disk routine.

.h2 Housekeeping Code

These two routines -- "rsxstart" and "rsxseldsk" -- do all of the
work; the rest is necessary housekeeping.  The initialization
code is needed only to verify conditions and set up the RSX, so
it is assembled, beginning at label "init" in the _INIT_ named-common
address space.  JetLDR will relocate this code into a working buffer
in low memory and execute it there; it takes up no space in the
resident system extension.  JetLDR relocates the code segment of the
RSX, allocating space for it immediately below the command processor
or the lowest RSX already in memory.  

Initialization involves verifying that the RSX can be correctly
loaded, linking the rsx into both the warm-boot and BDOS call
chains, and installing any additional BIOS intercepts needed for
this particular RSX.

The "initlp" code checks each RSX in memory, beginning with the
lowest, to see if an RSX with the same name is already in memory.
If so, it (indirectly) calls the routine "custom_twin".  This routine
can accept, or reject a duplicate RSX; for OKDRIVES a duplicate RSX
would be an error.

Provided no duplicate RSX has caused termination, the search eventually
reaches the end of the RSX warmboot chain.  If there is no RSX currently
in memory, then the "rsxnext" address is set to the ccp entry.
However, if one or more RSXs are already resident, the address is
set to the warmboot address in the header of the currently lowest RSX.

Next, the RSX's warmboot routine is linked into the BIOS's
warmboot chain, and the RSX's BDOS entry is linked into the
chain that begins on page-0 with the jump instruction at 0005.

The final initialization step is to call "custom_init".  For this
particular RSX, that code links the select-disk intercept
routine into the BIOS jump table.

Now, look back at the "rsxremove" routine.  It is in the code
segment, because the remove function must be resident within the
RSX.  It first calls "custom_remove", to take care of unlinking
the BIOS select-disk intercept.  Then it unlinks the warmboot
intercept and exits with the carry flag set to signal successful
removal of the RSX.

There is one more step to unlinking the RSX.  When the next
warm boot occurs, it will be processed by the RSX immediately
above this one, or, if there is none, by the BIOS.  In either
case, that routine will set a new "protect" address on page-zero at
0006.  Of course, this RSX must have an essentially similar
routine; it is at "rsxwb".  It first calls "fix0001", a
precaution that ensures the correctness of the pointer at 0001 toŠthe actual BIOS jump vector.

Next, it determines whether this RSX is, in fact, the lowest RSX
in memory;  it does this by checking the BIOS jump's address
against the RSX address.  Only if it is indeed the lowest does it
set the protect address on page-zero.  Finally, it jumps to the next
higher RSX, taking care to first load the current drive/user byte
into C, in case the next "rsx" is in fact the command processor.

The details of managing the two linked lists -- one pointing
upward to higher RSXs, the other pointing initially downward from
the BIOS and then to successively higher RSX's -- @I{are}
tedious, but necessary.  But now, with JetLDR, most of the
work can be avoided, and only the particular, custom elements
of an RSX need to be specially coded.

.h1  Extending System Extensions

As the wag said, "I like standards, because there are so many to
choose from!"  The Plu*Perfect Systems RSX header is just one way
to add resident extensions to CP/M 2.2.  But it is well tested,
provides for BIOS as well as BDOS system extensions, and takes
care to be compatible with other RSXs.

I have used these RSX structures in BackGrounder ii -- as well as
its spooler, printer redefinition module, and secure memory
allocator -- in DateStamper, and in DosDisk, achieving a high
degree of compatibility between them.  More recently, Carson
Wilson, Joe Wright and others have adopted the Plu*Perfect
Systems header structure to add such extensions as quad-density
disk drivers to a BIOS and resident conditional-execution
processing (IF.COM) to ZCPR34.

This experience shows that a uniform RSX header can, indeed,
allow diverse programs and applications to work together. 
Several older programs, including versions of BYE for remote
operation of a CP/M system, and ZEX for in-memory submit
processing could be revised to use this interface, so that
other RSXs could be run while those extensions are active.

In a CP/M 2.2 system that includes additional memory, it is
possible to make system extensions "resident" without subtracting
from scarce memory for applications.  Malcom Kemp has pioneered this
approach, called Banked System Extensions, by defining a similar BSX
header and providing loading/removal service in the XBIOS system
for the SB180 and SB180/FX computers.  I developed both a
banked-memory DateStamper and a DosDisk for this system.  In fact,
I am completing this column on an XBIOS system with banked
DateStamping and a DOS disk in drive C:, with no loss of TPA!

The next time you wish your computer had some missing capability,
consider whether it might be added as an RSX.  Those features may
already be available in products such as DosDisk, BackGrounder ii, orŠZ3PLUS.  If not, you may be able to code the routines yourself and bring
your system to new levels of performance and versatility.




Fig. 1  CONVENTIONAL MEMORY MAP

0000: jp bios+3 --->----------------------->----------------------------*
0005: jp bdos+6 --->*                             ccp+3:                *-> bios+3: jp bioswb
                    * --------------------->---------------> bdos+6:                 ...  
	                                                                    bioswb: ...
                                                                                    jp ccp+3
0100: tpa, to bdos+5


Fig 3.  MEMORY MAP WITH ONE RSX

                *-->------------------------>----------------------->---*
0000: jp bios+3-*         *-----------------<-----------------------<---+------------------<---*
0005: jp rsx1   ----------+> rsx1: jp entry1   *-> ccp+3:               *--> bios+3: jp rsx1+3-*
                          *--> +3: jp rsx1wb  /          *-> bdos+6:
0100: tpa, to rsx1-1               ...       /          /
                               +F: jp ccp+3-*          /
                            next1: jp bdos+6 ---------*
                           rsx1wb: ...
                                   jp rsx+F
                           entry1: ...
                                   jp next1





Fig. 4  MEMORY MAP WITH TWO RSXs

                *-->------------------------->---------------------------------------->---*
0000: jp bios+3 *         *------------------<----------------------------------------<---+------------------<---*
0005: jp rsx2   ----------+> rsx2: jp entry2     rsx1: jp entry1   *-> ccp+3:             *--> bios+3: jp rsx2+3-*
                          *--> +3: jp rsx2wb    *->+3: jp rsx1wb  /          *-> bdos+6:
0100: tpa, to rsx2-1               ...         /       ...       /          /      
                               +F: jp rsx1+3--*    +F: jp ccp+3-*          /
                            next2: jp rsx1      next1: jp bdos+6 ---------*
                           rsx2wb: ...         rsx1wb: ...
                                   jp rsx2+F            jp rsx1+F
                           entry2: ...         entry1: ...
                                   jp next2             jp next1




Here, the labels "ccp", "bios", and "bdos" refer to the base address of the corresponding CP/M operating systemŠsegment.  The entry to the bdos is at bdos+6; don't confuse it with the common equate for the page-zero
vector: "bdos equ 0005".


			Figure 5

title	okdrives.asm 6/25/88	(c) 1988 Bridger Mitchell
;
;
; This rsx sets the vector of valid drives allowed by the bios.
; If called with de == 0, it returns the current valid-drives vector.
;
; usage to set valid drives:
;
;	ld	c,DRIVEFN
;	ld	de,<vector>	; bit 0 = A:, ..., bit 15 = P:
;	call	5
;
; usage to determine currently-valid drives:
;
;	ld	c,DRIVEFN
;	ld	de,0000
;	call	5
;
;
; We need an extended bdos function number.
;
DRIVEFN	equ	241	; 0F1h
ABORT	equ	0ffh
;
;
; Name the REL image with "RSX" plus 0-3 characters of identification.
; In this case, we've used the rsx's bdos function number (241).

name	RSX241		;"RSX" required

;
; All of the code within the bracketed regions is the same for any rsx
; loaded by JetLDR.  It can be copied intact when creating a different rsx.

;
; *---------- Plu*Perfect Systems RSX Extended Header----------------*
;/								      \
;
; The rsx code goes in the CSEG (code segment).
;
CSEG

rsx:	jp	rsxstart					;  00
	jp	rsxwb						; +03
	jp	rsxremove					; +06
rsxwba:	dw	$-$						; +09Šrsxprot:dw	rsx						; +0B
	dw	rsxname						; +0D
rsxnext:jp	$-$		; -> next wb or ccp entry	; +0F	
;
next:	jp	$-$		; -> next rsx or bdos		; +12
nextwb:	dw	$-$						; +15
;\								     /
; *-----------------------------------------------------------------*
;
;
; The custom code for this rsx begins here.
;
;
rsxname:db	'OKDRIVES',0	  ; nul-terminated name of rsx.
;
vector:	dw	1111111111111111b ;  <-- set bits for valid drives
;               PONMLKJIHGFEDCBA  ;  <-- must be terminated by 'B' char.
;
;
; This RSX's bdos function.
;
; enter: c  =  DRIVEFN
;	 de == 0 to get current ok-drives vector
;        de != 0 to set the current vector to de
; return:
;	 hl = vector of ok drives
;
rsxstart:
	ld	a,c
	cp	DRIVEFN		; if not our function
	jr	nz,next		; .. on to the next rsx/bdos
	ld	a,e		; set vector?
	or	d
	jr	nz,set		; ..yes
get:	ld	hl,(vector)	; no, return the drive vector in hl
	ld	a,l		; return a != 0
	ret
;
set:	ex	de,hl
	set	0,l		; ensure drive A: always valid
	ld	(vector),hl	; save the new drive vector
	ld	a,l		; and return it in hl
	ret

;
; The bios seldsk intercept
;
; enter: c = requested drive
; exit:  hl == 0 if drive not allowed
;	 else continue to bios seldsk
;
rsxseldsk:Š	ld	hl,(vector)	; shift ok-drives vector left
	ld	a,16
	sub	c
rsxs1:	add	hl,hl
	dec	a
	jr	nz,rsxs1
	ld	hl,0000		; prime error return
	ret	nc		; NC if bit wasn't set
jseldsk:jp	$-$		; jmp to bios seldsk routine
;
;
; Restore this rsx's particular patches.
;
custom_remove:
	ld	hl,(jseldsk+1)	; restore bseldsk address
	ld	(bios+1ch),hl	; to bios jmp vector
	ret

;
; *----------------  Standard RSX Code  -----------------------------*
;/								      \
;
; The warm-boot intercept.
;
rsxwb:				.new
	call	fix0001		; ensure correct page 0
	ld	hl,(bios+4)	; does bios wb addr
	ld	de,rsx+3	; point at us?
	or	a
	sbc	hl,de
	jr	nz,rsxwb1	; no, we're not the bottom rsx
	ld	hl,(rsxprot)	; we are, set our protect address
	ld	(0006),hl
rsxwb1:	ld	bc,(0004h)	; get c = logged du for ccp
	jp	rsxnext		; in case we're top rsx
;
;
; The removal routine.
;
rsxremove:
	call	custom_remove	; do extra restoration for this rsx
;
	ld	hl,(nextwb)	; get saved original warmboot addr
        ld	(bios+4),hl	; and restore it to bios jmp vector
;
; When the caller terminates to a warmboot,
; the next module (or bios, if none), will correct 0006.
;
; Set CY flag to inform the removal tool that this routine
; has indeed taken action. (Some RSX's are not self-removing).
;
fix0001:ld	hl,(rsxwba)	; restore (0001) in case an errantŠ	ld	(0001h),hl	; application has tampered with it 
	scf			; set CY to signal success
	ret
;
;
; Before loading an RSX, JetLDR will first check for protected memory.
; If it detects that memory is protected by a non-RSX header (e.g. a debugger)
; it will cancel the load.  Otherwise, JetLDR will call any
; code in the _INIT_ named common, after the rsx module has been
; loaded and relocated.  This code will be located in non-protected
; memory, and takes no space in the RSX.
;
; Return parameter: A = 0 indicates a good installation
;		    A = ABORT = 0FFh = not installed
;
common	/_INIT_/
;
; Install the rsx.  This code is standard for all rsx's,
; except for:
;	custom_init
;	custom_twin
;
init:	ld	hl,(0006)	; hl = possible rsx, or bdos
	ld	c,0		; initialize count of rsx's
;
initlp:	push	hl		; stack (possible) rsx base address
	ld	de,09 		; if candidate is an rsx
	add	hl,de		; ..the wbaddr will be here
	ld	e,(hl)		; get address
	inc	hl
	ld	d,(hl)
	ld	hl,(0001)	; and compare
	or	a
	sbc	hl,de
	pop	hl
	jr	nz,inittop	; warmboot addr not there, stop looking
;
; we have an rsx in memory, is it our twin?
;
	inc	c		; count an rsx found
	push	hl
	call	ckname
	pop	hl
	jr	z,twin
;
	ld	de,0Fh+1	; that rsx was't a twin, check for more
	add	hl,de		; get addr of next rsx's wboot jmp
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	dec	hl		; back up to head of that next rsxŠ	dec	hl
	dec	hl
	jr	initlp		; now check that rsx
;
; we're at the top of the (possibly empty) rsx chain 
;
inittop:
	inc	c		; any rsx's found?
	dec	c
	ld	hl,ccp+3	; prepare to use ccp entry address
	jr	z,setnext	; ..no
;
	ld	hl,(0006)	; yes, use bottom rsx's address
;
setnext:
	ld	(rsxnext+1),hl	; save the next addr
				; in the rsx chain to bdos/ccp
;
; install the rsx into the running system
;
	ld	hl,(bios+4)	; save the bios's wb addr
	ld	(nextwb),hl	; in the header

	ld	hl,rsx+3	; point the bios wb jump
	ld	(bios+4),hl	; at the rsx wb vector

	ld	hl,bios+3	; store wb addr
	ld	(rsx+09),hl	; in rsx header word

	ld	hl,(0006)	; get addr of next rsx or bdos
	ld	(next+1),hl	; and install it

	ld	hl,rsx		; finally, protect the rsx
	ld	(0006),hl
;
	call	custom_init	; take care of extras 
	ret
;
ckname:	ld	de,0dh		; offset to candidate rsx name pointer
	add	hl,de
	ld	a,(hl)		; get address
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	de,rsxname	; compare to our name
ckname1:ld	a,(de)
	cp	(hl)
	ret	nz
	inc	(hl)		; candidate must be nul-terminated
	dec	(hl)
	jr	nz,ckname2
	or	a		; ..at our same byteŠ	ret
ckname2:inc	hl
	inc	de
	jr	ckname1
	
;
; Handle the case of a previously-loaded copy of this RSX.
;
twin:	call	custom_twin
	ret
;\								     /
; *-----------------------------------------------------------------*
;
; Custom initialization code goes here.
;
;
; Do the particular patches for this RSX.
; Note: this code is in the _INIT_ segment.

custom_init:
	ld	hl,(bios+1ch)	; get bseldsk address
	ld	(jseldsk+1),hl	; install it in rsx
;
	ld	hl,rsxseldsk	; divert bios jump
	ld	(bios+1ch),hl	; to the rsx
	ret
;
; This particular rsx should not be duplicated.
; A different rsx might wish to query the user here,
; print a warning, or whatever.
;
custom_twin:
	ld	a,ABORT
	ret
;

; Include identification info in the REL image.
; JetLDR will display the bytes up to the first NUL byte
; when the RSX is loaded.
;
;
common	/_ID_/
;
	db	'OKDRIVES: RSX prevents bios logins'
	db	13,10
	db	'Use BDOS function 241 (0F1h) to set de = drive vector',0

;
; Include whatever other named-commons are needed for this RSX.
; JetLDR will resolve these labels for us.
;
common	/_BIOS_/Šbios	equ	$
	
common	/_CCP_/
ccp	equ	$


	end	;okdrives.asm



[This article was originally published in issue 34 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1988, 1991 Socrates Press and respective authors]
