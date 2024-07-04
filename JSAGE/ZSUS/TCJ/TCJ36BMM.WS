.h1 = main heading
.h2 = subheading
italics are delimited by matching underscores

                                Advanced CP/M
                          Environmental Programming
                               Bridger Mitchell
                        The Computer Journal, Issue 36
                          Reproduced with permission
                           of author and publisher

.h1 BackGrounder ii Update

BackGrounder ii is like no other CP/M program -- it simply feels
different.  A touch of the "suspend" key and you pop into the
background command processor, a touch of a user-defined macro key and
you can switch to a second program, literally in mid-sentence.  The
built-in calculator, notepad, screen-dump, and cut-and-paste function
turn out to be extremely handy desk accessories, especially because
results on one screen can be exported to another task.  But the magic
of it all -- black magic, perhaps -- is the feeling that comes over
you when you first experience the screen flashing back, cursor in
place, with _no_ trace of having been away!

BGii and the Z-System stand as twin pinnacles of advanced CP/M
operating systems.  At a conceptual level, they are orthogonal.  By
providing memory buffers for the command processor and applications
and supporting conditional execution, ZCPR 3.4 allows tasks to
_communicate sequentially_.  By making the BDOS and command-processor
recursive, BackGrounder ii creates two-way _communication between
simultaneous tasks_, under user control.  When combined -- BGii
running in a ZCPR 3.4 system -- they elevate 8-bit computing into another
dimension.  The results are awesome.

Bringing BGii fully up-to-date to support the latest ZCPR version 3.4
has been a largely enjoyable task.  I had put it off more than once,
wanting to finish up DosDisk and then Z3PLUS.

When I finally returned to the BGii code I was pleasantly surprised to
uncover several new coding shortcuts.  They enabled me to squeeze in
almost all of the "Z34" features and add some new conveniences,
including enabling the user to rename the built-in BGii commands.
Expert testing by Cam Cotrill and Jay Sage greatly firmed up several
soft spots.  It's now the production version and licensed users can
order an update at low cost.


.h1		    Environmental Programming

A customer of long-standing called the other night, as I was drafting this
column.  He enthused about BackGrounder ii, but then noted that "it
sometimes finds bugs in _other_ programs!"

Alas, bugs are always with us, even when we think we've got our own
code pretty solid!  This column is going to be about writing code that
is respectful of the environment in which it is running.ŠThe sage (Sage?) advice collected here, and culled from the
programming experience of many old hands, surely won't eliminate bugs.
But it will greatly increase the chances of your programs living more
harmoniously with a wide variety of CP/M systems.


.h2  Make a good start

The command processor starts your program by _calling_ it. This means
that you can speed up the flow of jobs by _returning_ to the CCP when
your program terminates, instead of causing a warm boot that reloads
the CCP.  To do this, you must _save the stack pointer_ and stay clear
of the CCP in the 2K of memory just below the BDOS.

_Use a local stack_ for all but the simplest programs.  The command
processor's stack may not be deep enough for your functions, BIOS
calls, and interrupts.  And that stack could be in the TPA, part of
the CCP that may be overwritten by your program or data.

.h2 Know the Territory

A shockingly large number of programs assume that they will always be
run only in the environment for which they were written.  Drop them
into a different world and they almost always injure their host.
So, please, join the environmentalists and take the responsible
programmer's oath: _Do No Harm!_ Survey the territory before plunging
ahead, and pose these questions:

Is our host a Z80?  An HD64180?  A Z280?  That determines which opcodes can
we safely use.
 
Is our host running CP/M Plus? or ZSDOS?  What system calls are available?
Is DateStamper running?

Is one of the drives set to MS-DOS format under DosDisk?  If so, we
must not make assumptions about internal data in the file control
blocks on that drive or about the structure of the disk directory.

Is the host running a Z-System?  With an extended environment?  If so,
we should allow for possible non-standard sized BDOS and CCP modules
and get their addresses from the environment.  If it is _not_ a
Z-System, we must avoid any references to Z-environment parameters;
if we are a Z-tool, put out a short message of requirements and quit.

Finally, if we should need to know, can we determine what BIOS and type of
machine our host is?

Figure 1 is a routine called TERRITORY that does these checks.
It should be called at the very beginning of a program.  If the host
system has a Z-System command processor (ZCPR 3.3 or later, or
BackGrounder ii) the program will begin with the HL register
containing the address of the Z-System external environment.

TERRITORY first checks for a Z80-compatible processor, and then usesŠobscure differences in register operations to identify HD64180 and
Z280 processors.  The system addresses (BIOS, BDOS, and CCP) are
determined from a Z-System extended external environment, if there is
one, so that non-standard BDOS and CCP modules can be used correctly.

The BIOS check demonstrates how to detect an NZ-COM system and find
the address of the original CBIOS.  Several systems have bios-specific
references to such things as function-key tables, foreign disk
parameter blocks, and extended BIOS functions that cannot be located
from the address at 0001h when NZ-COM is running.

You can use the flags and addresses established by TERRITORY for your
own requirements.  You might also want to make a version of it into a
simple diagnostic tool that prints out messages identifying exactly
what the host system consists of.


.h2 Identify yourself

Unless yours should be a silent program, announce yourself to the
user with an appropriate message that includes a version number.
All programs change, get updated, and gain features.  You and other
users need to be able to identify which model they're driving.
Most Z-System tools use a standard format, which is well worth
adopting for other programs:

   A>PROGNAME Vers. 1.5 -- terse functional description

If you are the silent type, include sufficient version identification
in the data area so that a debugger can be used to inspect the
program.  Alternatively, include the information in a help screen.
Z-System tools use the standard "double-slash" command line to request
help, another worthwhile convention:

  A>PROGNAME //



.h2 Protect the Environment

_Save the current drive and user number_, so you can restore them on exit.

Explicitly _allocate memory_ and check to prevent overflowing the
available transient program area.  The TPA is always the memory from
100h to the value that is stored at 0006, less 1 byte.

If there are no RSX's in memory, that value is the entry address of
the BDOS and is the target of the jump instruction at 0005.  This is
the most common case; in CP/M 2.2 the CCP will occupy 6 + 800 hex
bytes below that.  But if an RSX has been loaded, its address
will be at 0006. In that case the CCP will already be protected, and
you can use all of the TPA and still return to the CCP. 

So, if no RSX is loaded, if you intend to return to the CCP, and if youŠare not running under CP/M Plus, allow 2K of space below the BDOS.
Figure 2 gives a routine that makes this calculation.  It calculates
the largest usable memory that will still preserve the CCP and returns
the address of the first byte beyond that.

Applications have the right to have their register values treated
systematically when they call on the operating system for services.
CP/M is an 8080-based operating system, and from the beginning it put
programmers on notice that it would not preserve the user's registers.
That was logical, as the OS needed most of them for returning values.

The introduction of the Z80 and subsequent 8080-compatible CPUs led to
more compact and more efficient BIOSes.  Unfortunately, more than one
BIOS writer began using the additional _Z80 registers_ without
preserving their values for the user.  The consequences have been
erratic havoc -- programs test out flawlessly on a variety of systems,
then fail to start, or die mysteriously on another machine.

The environmentally-conscious rule here is: if your code will become
part of the operating system -- the BDOS, BIOS or an RSX extension --
save and restore all Z80 registers you use.  Why?  Simply because it's
a far greater burden on an application to preserve IX, IY, AF', BC',
DE', and HL' in order to run on an arbitrary system, than it is for
the system programmer to protect exactly those registers he needs to
use.

The extreme case of environmental wantonness is a rom-based-based BIOS
for the early Osborne Executive, which used alternate Z80 registers
for an interrupt service routine, without preserving them!  A moment's
thought should persuade you that there is _no way_ an application
could _ever_ use those registers and run on that machine.  Was the
system designer so naive as to think that only 8080-code would ever be
run on an Executive?


.h2  Expect the Worst

_Test for all disk errors_.  Proceeding after one error (a full disk,
a non-existent file, ...) can wreak disaster.

_Have a recovery strategy_.  Tell the user enough about the problem
that he can alter the environment and try again.  Give him a
choice (insert a disk, restart the program, exit, ...).
 

.h2 Limit the Damage

Before writing a file, check the disk space remaining.  If there isn't
enough room, give the user the chance to delete something, or to insert a
new disk.

If a write error occurs, try to close the file to save as much data as
possible.  Offer the user a second chance, by changing disks or
drives.  Clean up file fragments after recovering.Š
Before printing, test to see if the printer is ready.  If it isn't,
ask the user to make it ready before retesting.  Otherwise, if you
start sending characters, the computer will hang and you can't inform
the user what's wrong.  A short routine to do this, derived from
BackGrounder ii, is shown in Figure 3.  It's important to send a test
character (a carriage return) in order to actually test the _printer_
itself, because a serial printer channel will normally have a UART
with a one-character buffer.  If the UART's buffer is empty, it will
report that _it_ is ready to receive a character, even if the printer
isn't.


.h2 Don't take shortcuts

The TERRITORY routine doesn't check for Z-Systems earlier than ZCPR
version 3.3 (which supplies the external environment address in HL
when it calls each program).  It can be extended to do so by searching
memory for the "Z3ENV" string and verifying that the self-reference
address indeed points to the environment area being examined.

Note that if the string is found, but the address test fails, the
search must be continued; it's quite possible to have more than one
"Z3ENV" string in memory.  Jay Sage tells me there is a group of
programs that, regrettably, take a shortcut and stop searching on the
first match.  They fail to run on his system because it includes,
quite appropriately, a directory named "Z3ENV".

The new Z3PLUS and NZ-COM systems have exposed shoddy programming
practices, bugs that have been hibernating in widely used utilities.
A common one results from the faulty assumption that the Z-System
external environment address began on a memory page (xx00 hex).
When this happens to be the case, then:

	ld	l,offset

is a shorter route pointing to an environment parameter than:

	ld	de,offset
	add	hl,de

But when it's not, the path leads over the cliff.



.h2 Clean up

_Use a common exit_ point.  This makes it easier to ensure that
nothing is overlooked as your program grows to include new branches.

_Close open files_ and _delete temporaries_. 

_Restore the default drive and user_.
ŠIf you've used full-screen terminal features, _leave a clean screen
below the cursor_.  For some applications you may want to clear the
entire screen.  In other cases, having the final lines of data remain
allows the user to make use of the information when she or he enters
the next command; in that case, put the cursor on the bottom line and
send a newline.

Finally, if you have not overwritten the CCP, restore the stack and
return.  Otherwise warmboot.


I certainly don't follow these guidelines slavishly, though I do
pay them regard before releasing any software for wide testing. 
My own temporary programs, run in a known test environment, are
often rude, slap-dash pasteups to get the job of the moment done
rapidly. But I guard against giving them out to others.  It's no
favor to pass on code that may explode a friend's system at some
unsuspecting moment.  Which leads me to recall ...


.h1		   A Tale of Too-hasty Design

Some months ago a well-known programmer, author of CP/M several
BIOSes, gave me a copy of the BIOS to a particular new computer. 
I was developing customized operating-system code for this
box, and had a similar machine for the debugging and testing
cycle.  I had re-assembled the BIOS, made several rounds of
modifications that were converging to a stable new system running
on my box when, poof, I exited from a program and the system
went to lunch.  It wouldn't reboot, even from power up.

A systems programmer learns (from bitter experiences!) to sit
quietly, write down everything he can remember, and think long
and hard before he touchs anything besides a pencil. Some clues
to the crash may remain behind, on disk or in memory (although in
this case memory was fully reset).  In this case, the A: drive
had been a ram disk with uninterruptible power, so I assumed that
its system tracks had somehow been damaged.

I decided to make a systematic tour of the A: disk drive by booting up
from a floppy system, and looking at different tracks with DU.  (Yes,
I try always to have a couple of bootable systems stored away on
floppies for that black day that a hard-disk or ramdisk goes bad.  You
should too.)  Sure enough, I found what appeared to be file data in
the directory tracks.  More investigation disclosed that the following
tracks, which should have been the directory, had also been corrupted.
I took a deep breath, made a mental note to write down what I could
still remember of what I had typed in during the last two hours of
iterations since backing up the experimental system code.  I continued
checking the disk.  Suddenly, several tracks later, the disk appeared normal.

What could cause such systematic damage?  Hypotheses poured forth,
only to be discarded.  Finally, I saw the glimmer of a pattern.ŠThe start of the ram disk -- the start of banked memory --contained
data related to the data at the very end of the disk.  Wraparound!
The BIOS had literally gone off the deep end of the ram disk and
started writing on the front, clobbering the system, the
directory, and the first files after that.  As soon as a warmboot
was attempted, the system loaded the corrupted system track and
was dead.

A hot theory.  But where was the bug?  I consulted with the
author, and then he remembered --  he'd given me the _large_
ramdisk version of the BIOS.  With less ram installed on my
box the addressing had wrapped around.

I wasn't pleased to learn he'd overlooked putting in a _runtime_
check for the amount of memory the system possessed.  A simple
test to make, yet because it was omitted, I now had several hours
of reconstructing and testing files ahead of me.

This bug was in hibernation, waiting to byte just when a large
disk filled up.  Only extreme testing is likely to have disclosed
it before it zapped a directory on a customer's machine.  We were
lucky it happened when it did.  Yet it could have been prevented,
by systematic design.  Environmentally conscious programming
would have done it.


.h1			Identifying the BIOS

How can a program determine who its host is?  What hardware is
available?  Digital Research (DRI) had no BDOS function to return a
version number in CP/M 1.4 and never did introduce one for identifying
the BIOS.  I have no idea why DRI failed to anticipate this question;
a BIOS call to return version information seems now the obvious way to
do things.  And MSDOS is no better.

Anyway, we are stuck with CP/M's warts; there is no _portable_ BIOS
call that will identify an Ampro from a Kaypro from an S-100 box.
Even if _a particular_ manufacturer had the vision to include this
entry point, it's catch-22.  We can't safely use the call until we know
that it's available!

The best approach is to identify the BIOS by reading memory bytes in
the BIOS.  Every BIOS should include a unique signature and version
information.  The signature can be an ascii string, such as "PPS" (in
the Advent/Plu*Perfect TurboRom BIOS) or "XBIOS" (in the XBIOS for
SB180's), at a known offset from the start of the BIOS.  Once the
program has identified the type of BIOS, it knows it can make an
extended BIOS call, if one has been provided, to obtain additional
information.  The XBIOS system, for example, provides information on
the available hardware devices and their corresponding ascii names in
the system.

The TERRITORY routine includes a ck_bios routine to identify KayproŠsystems with a TurboRom BIOS and systems running NZ-COM.  Other checks
can be added to identify other particular systems.

Unfortunately, a number of BIOS's were written by people who
apparently never thought others might write software for their very
computer!  In these cases, the safest approach is to tell the user in
a message that the type of BIOS cannot be determined, and ask him to
confirm or enter the model manually before proceeding.


;   Figure 1.  Determine characteristics of CP/M host's environment
;   _______________________________________________________________


bdos	equ	5

; Call this routine immediately.
; Enter with HL = value from command processor.
;
TERRITORY:
;
; Test for z80-compatible cpu.
;
	sub	a		; sets even parity in 8080
	jp	po,ck_180
	ld	c,9		; announce Z80 requirement
	ld	de,notz80msg
	call	bdos
	rst	0		; ..and exit to warmboot
;
; Test for HD64180/Z180
;
ck_180:
	ld	bc,101h		; prepare to multipy B=1 x C=1
	db	0EDh,04Ch	; MLT BC opcode
	dec	b		; if Z80, B will be unchanged 
	jr	z,ck_280	;
	ld	a,c		; 180 leaves 16-bit result (1) in BC
	ld	(z180flag),a
;
; Test for Z280

ck_280:	ld	a,10		; Z280 doesn't use refresh register
	ld	r,a		; load it
	ld	c,a		; save it
	ld	b,a		; cause some refreshes
loop:	djnz	loop
	ld	a,r		; if value hasn't changed
	cp	c
	jr	nz,ck_rest
	ld	(z280flag),a	; ..it's a 280
;Šck_rest:
	push	hl		; save possible env address from ccp
	call	ck_dos		; check type of BDOS
	pop	hl
	call	ck_z3		; check for Z-System
	call	ck_dosdisk	; check for DosDisk
	call	ck_bios		; check type of BIOS
	call	ck_bg		; check for BackGrounder ii
	ret

;
;
; Check for BDOS version 
;
ck_dos:	ld	c,12		; get CP/M version number
	ld	e,'D'		; with DateStamper id request
	call	bdos
	cp	30h
	jr	c,ck_ds
	ld	(cpm3flag),a	; set flag if CP/M 3
	ret
;
; Check for DateStamper
;
ck_ds:
	cp	22h
	jr	nz,ck_xdos	; .. not CP/M 2.2
	ld	a,h
	cp	'D'
	jr	nz,ck_xdos	; ..no DateStamper
	ld	(dsflag),a	; set flag
	ld	(dsclock),de	; and save clock pointer
;
; Check extended dos version
;
ck_xdos:ld	c,48		; use extended version number call
	call	bdos
	ld	(dosvers),hl	; save version number and type
	ret

;
; Check for Z-System.
; Enter with HL = value from command processor.  If ZCPR 3.3
; or BackGrounder ii, HL -> external environment
;
;
ck_z3:	push	hl		; save possible ENV address
	inc	hl		; Offset to 'Z3ENV'
	inc	hl
	inc	hl
	ld	b,Z3ENVLEN
	ld	de,z3envsigŠ	call	match
	pop	de		; recover de = ENV address
	jr	nz,set_std
	ld	hl,1Bh		; Offset to self-reference address
	add	hl,de
	ld	a,(hl)		; Check low byte
	cp	e
	jr	nz,set_std
	inc	hl
	ld	a,(hl)		; Check high byte
	cp	d
	jr	nz,set_std
;
	ld	(zsysflag),a	; set flag
	ld	(z3env),de	; save environment address
	ld	hl,08h		; get env. type
	add	hl,de
	ld	a,(hl)
	and	80h		; test for extended type (>= 80h)
	ld	(extenvflag),a	; and save result
	jr	z,set_std
;
; Set system addresses for a Z-System with an extended environment

	ld	hl,45h		; -> bios address in environment
	call	addderef
	ld	(biosbase),hl
	ld	hl,42h
	call	addderef
	ld	(bdosbase),hl
	ld	hl,3Fh
	call	addderef
	ld	(ccpbase),hl
	ret

;
; Set system addresses for a standard system.
;
set_std:
	ld	hl,(0001h)
	ld	l,0
	ld	(biosbase),hl
	ld	de,-0E00h
	add	hl,de
	ld	(bdosbase),hl
	ld	de,-800h
	add	hl,de
	ld	(ccpbase),hl
	ld	a,(cpm3flag)	; if not CP/M Plus
	or	a,a		; ..all done
	ret	z
;Š	ld	c,49		; for CP/M Plus, w/o extended environment...
	ld	de,getscbpb	; get system control block address
	call	bdos
	ld	l,98h		; offset to address of resident bdos
	call	deref		; dereference pointer
	ld	l,0
	ld	(bdosbase),hl
	ld	hl,100h
	ld	(ccpbase),hl
	ret
;
addderef:
	add	hl,de		; offset pointer by DE
deref:	ld	a,(hl)		; dereference HL pointer
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
;
match:	ld	a,(de)		; match B bytes at DE, HL
	cp	(hl)
	inc	hl
	inc	de
	ret	nz
	djnz	match
	ret

ck_dosdisk:
	ld	c,113		; get DosDisk id
	call	bdos
	cp	0FDh
	ret	nz		; ..if not DosDisk, quit
	ld	(dosdiskflag),hl; set flag (L) and drive with MS-DOS format (H)
	ret


ck_bios:
	ld	hl,(0001h)	; -> normal CBIOS warmboot address
	ld	l,90		; -> NZ-COM id in NZ-COM pseudobios
	ld	de,nzname	; if NZ-COM id is exactly there
	ld	b,NZNAMELEN
	call	match
	jr	nz,ck_turbo
	ld	hl,(z3env)	; ..get CBIOS (page) addr from
	inc	hl		; ..z3env+2
	inc	hl
	ld	h,(hl)		; ..get page
	ld	l,0
	ld	(biosbase),hl	; ..and save correct ptr to CBIOS
;
; Check for Kaypro TurboRom
;Šck_turbo:
	ld	hl,0FFF8h	; -> location of TurboRom signature
	ld	b,TURBOSIGLEN
	ld	de,turbosig
	call	match
	ret	nz
	ld	(turboromflag),a; set flag
	ret

;
; Check for BackGrounder ii
;
ck_bg::	ld	hl,(bdosbase)	; -> location of BGii signature
	push	hl
	ld	de,-800h+5Bh	; in BGii CCP
	add	hl,de
	ld	b,BGSIGLEN
	ld	de,bgsig
	call	match
	pop	hl
	ret	nz
	ld	(bgflag),a	; set flag
	ld	de,-800h+1	; -> BGii ccp entry +1
	call	addderef	; get that address
	dec	hl		; BGii task flag is 1 byte lower
	ld	(bgtaskptr),hl	; save ptr to task flag
	ret
;
notz80msg:
	db	'Not Z80.$'
getscbpb:
	db	3Ah		; return address of scb
	db	0		; "get" code
;
; Z-System environment signature
;
z3envsig:
	db	'Z3ENV'
z3envlen equ $-z3envsig
;
; NZ-COM's  signature in the pseudo-bios, at offset 90.
;
nzname:	db	'NZ-COM'
nznamelen equ $ - nzname
;
; BackGrounder ii's signature

bgsig:	db	'BGii'
bgsiglen equ	$ - bgsig
;
; Kaypro TurboRom signature, at FFF8h
;Šturbosig:db	'PPS'
turbosiglen equ $ - turbosig
;
;
; System flags (any NZ value means TRUE)
;
z180flag:	db	0	; HD64180/Z180 cpu
z280flag:	db	0	; Z280 cpu
cpm3flag:	db	0	; CP/M Plus
dsflag:		db	0	; DateStamper
zsysflag:	db	0	; Z-System (ZCPR 3.3 or later)
extenvflag:	db	0	; extended Z-System environment
bgflag:		db	0	; BackGrounder ii
turboromflag:	db	0	; Advent/Plu*Perfect Turborom
;
dosvers:	db	0	; } a pair  version number (hex)
dostype:	db	0	; }         'S' = ZSDOS, 'D' = ZDDOS, 0 = ZRDOS
dosdiskflag:	db	0	; } a pair  DosDisk
dosdrive:	db	0	; }	    MS-DOS format drive
bgtaskptr:	dw	0	; BGii internal flag pointer: bit 1 set = upper task
;
; System Addresses
;
z3env:		dw	0	; Z-System external environment
biosbase:	dw	0	; BIOS
bdosbase:	dw	0	; BDOS
ccpbase:	dw	0	; CCP
dsclock:	dw	0	; DateStamper clock




;     Figure 2.  Find Top of Usable Memory that Preserves the CCP
;     ____________________________________________________________


; Return HL = top of usable memory + 1
;
top_of_mem:
	ld	hl,(0006)	; load protect address
	ld	a,(cpm3flag)	; if CPM Plus
	or	a		; 
	ret	nz		; ..return it
	push	hl		; for CP/M 2.2
	ld	de,(ccpbase)	; if protect address is below CCP
	sbc	hl,de
	pop	hl
	ret	c		; .. return it
	ex	de,hl		; else return CCP address
	ret

Š
;		   Figure 3.  A Printer-Ready Test
;                  _______________________________

; Return: NZ if printer is ready
;
test_list:
	call	b_lstat		; if printer is busy
	ret	z		; ..return
	ld	c,0dh		; send carriage-return
	call	b_list		; ..to flush UART buffer
	call	wait		; allow printer to process it
				; and re-test status
b_lstat:ld	de,2dh-3	; call BIOS list-status entry
	call	bcall
	or	a,a
	ret
;
b_list:	ld	de,0fh-3	; call BIOS list entry
bcall:	ld	hl,(0001)
	add	hl,de
	jp	(hl)


wait:
;	...			; any 10-20 mS routine
	ret


[This article was originally published in issue 36 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]
