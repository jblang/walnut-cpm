TCJ Issue #40

                        PROGRAMMING FOR PERFORMANCE
                                  PART 2

                               by Lee A. Hart


                             Know The Hardware

   Truly efficient software has an intimate, almost incestuous relationshipç
with its hardware.  They merge so thoroughly as to become inseparable;ç
neither makes any sense without the other.

   This requires that you, the programmer, must TOTALLY understand theç
hardware.  I cannot stress this point too strongly.  The strengths andç
weaknesses of the hardware influence program structure at every level, notç
just the low-level drivers.  A system with weak disk I/O will be slow andç
unresponsive if your program relies on overlays.  A shallow keyboard bufferç
requires frequent checks to avoid missing keys.  The characteristics of the ç
console device determines your whole approach to data displays.  If you tryç
to hide from these limitations in a high-level language, your program willç
work as if it were written in BASIC 101.  Let's consider some actual caseç
histories of what can be gained by paying attention to the hardware.

CASE #1

   A customer needed a faster way to transfer data between two computers. ç
He had been using a serial port at 9600 baud but complained that it was tooç
slow and tied up the computer's serial port.  Hardware mods were ruled out.

   After study, I found that each computer had unused handshake lines in itsç
RS-232 port.  A special "Y" cable was built to cross-connect two of theseç
lines, providing one bit of serial I/O in each direction.  A "software UART"ç
program was then written to transfer data between the two machines.  Thisç
worked to about 30K  bits per second before timing dither (due toç
interrupts, memory refresh, etc.) caused errors.

   The serial port's UART could be programmed to generate an interrupt whenç
the handshake line went low.  Therefore, an interrupt-driven protocol withç
handshaking was devised.  A '0' was sent by pulling the output low until theç
other computer echoed the low on its output.  A '1' was sent by pulsing theç
output low and immediately back high and waiting until the other systemç
echoed it.  The data rate increased to over 100K bits per second, andç
transfers were now unaffected by disk I/O, keyboard activity, etc.

CASE 2

   The firmware for a CRT terminal was to be upgraded to run 38400 bits perç
second without handshaking.  Now, 38400 bps is fast, only 260 microsecondsç
per character (about 75 instructions for a 3 MHz Z80).

   The slowest routines need the most attention.  For example, clear-lineç
was accomplished by moving the stack pointer to the end of the line andç
executing 36 PUSH HL instructions.  The interrupt handler needed a 4-levelç
stack, so the last 8 bytes were cleared normally.  Clear-screen used 25ç
iterations of clear-line.

   This still isn't fast enough to complete every ESC sequence before theç
next one is received.  This calls for an interrupt-driven system.  Eachç
character received generates an interrupt.  The interrupt handler pushes theç
character into one end of a FIFO (First-In-First-Out) buffer in memory.  Theç
main program pops characters out the other end and processes them.  The FIFOç
fills while we process slow commands like clear-screen and empties back outç
during fast commands.

   But what if some idiot sends a long string of slow commands (like 100ç
clear-screens in a row)?  The FIFO would eventually overflow, and data wouldç
be lost.  I prevented this with "look-ahead" logic.  When the interruptç
handler spots a clear-screen command, it sets a flag so MAIN expects it. ç
MAIN can then ignore unnecessary commands (no sense altering a screen that'sç
about to be cleared). 

   Scrolling is one of the most difficult actions.  The obvious algorithm isç
to block move lines 2-24 up 1, then clear line 24.  But that's what IBM didç
on the PC, and we all know how well that worked.  So examine the 6845 CRTç
controller.  The Start-Address register holds the address of the firstç
character on the screen, the one displayed in the top left corner.  If weç
add 80 to it, line 2 instantly becomes the top line, and we've scrolled theç
whole screen up a line.  All that remains is to clear the 80 bytes that ç
form the new 24th line, for which we have a fast routine.

   Each scroll moves the start address up another 80 bytes.  This obviouslyç
can't go on indefinitely, so the original program spent a great deal of timeç
checking for overflow outside its 2K block of screen RAM (F800-FFFF).  Forç
instance, the old code read:

     ld   (hl),a    ; put character on screen
     inc  hl        ; advance to next
     ld   a,h       ; get new address
     or   0F8h      ; if overflow to 0000,
     ld   h,a       ;   force it to F800-FFFF

   But is this really necessary?  The schematic revealed that the 2K RAM wasç
partially decoded and actually occupied 16K in the Z80's address spaceç
(C000-FFFF).  It's far easier to insure that an address lies within thisç
range:

     ld   (hl),a    ; put character on screen
     res  6,h       ; insure we don't wrap to 0000
     inc  hl        ; advance to next

CASE #3

   Fast Disk I/O.  Way back in 8 B.C. (eight years Before Clones) I had anç
S-100 system.  Its 8080 CPU blazed along at 1.843 MHz, through 32K of RAMç
spread over half a dozen furnace boards.  Two Shugart SA-801R single-sidedç
8" drives provided disk storage, with CP/M 1.4 tying it all together.  Thatç
old war horse and I fought many battles together, until it finally died theç
Death-of-1000-Intermittents.

   Many of its "features" I'd rather forget, but it had one outstandingç
attribute: the fastest floppies I've ever seen.  Warm boots were done beforeç
your fingers were off the keys; Wordstar loaded in under a second; PIPç
copied files at 10K bytes/sec.  All without a fast CPU, DMA, vectoredç
interrupts, or even a disk controller IC.  The "controller" was just a bunchç
of TTL chips implementing a parallel port, an 8-bit shift register, and aç
CRC checkcode generator.  The real work was done by the CPU, byte-bangingç
out the IBM 3740 SD/DD format in software.

   How good was it?  An 8" disk spins at 360 rpm, or 6 revs/sec.  Each trackç
held 6.5K (26 double-density sectors of 256 bytes each).  That makes theç
theoretical maximum transfer rate 6.5K x 6 = 39K bytes/sec.  It actuallyç
achieved 50% of this, or 20K bytes/sec.

   Few modern micros come anywhere near this level of performance.  Theç
Kaypro I wrote this article on creeps through the disk at 4K/sec.  My PCç
clone is closer, at 12K/sec.  The problem is that the CPU spends most of itsç
time in wait loops; waiting for the drive motor to start, for the head toç
load, for an index hole, for a certain sector to come around on the disk.ç
The capabilities of fast CPUs, elaborate interrupt systems, DMA, and fancyç
disk controllers are thrown away by crude software.

   The CPU has better things to do.  If the disk isn't ready when an ç
application program needs it, the BIOS should start the task, save the dataç
in a buffer, and set up an interrupt to finish the task later when the diskç
is REALLY ready.  The time lost to wait loops is thus reclaimed to run yourç
application programs.

   That's how my antique worked.  The BIOS maintained a track buffer in RAM.ç
The first read from a particular track moved the head to the desired trackç
and read the whole thing into the buffer.  Further reads from that trackç
simply came from RAM, taking virtually no time at all.

   Similarly, writes to a sector on the current track just put data in theç
buffer and marked it as changed.  The actual write was performed later, whenç
a new track was selected for read/write, or just before the drive timed outç
from a lack of disk activity.

   Physical track reads/writes were fast as well.  The key was to simplyç
begin wherever the head was.  After seeking to the desired track, it readç
the ID# of each sector encountered and transferred it to/from the appropriateç
place in the RAM buffer.  No need to find the index hole, wait for aç
particular sector ID#, or worry about interleave; one revolution got it all.

   Such a system must be implemented carefully.  CP/M does not expectç
delayed error messages, which can produce some odd results.  For instance, aç
BDOS read error might be reported when the real cause was a write error inç
flushing the previous track buffer to disk.  Also, modern drives do not haveç
door locks to prevent disk removal if unwritten data remains in the trackç
buffer.

   The main factor limiting my S-100 system's performance was the slow CPUç
and lack of DMA.  A double-density 8" disk has a peak data transfer rate ofç
500K bits/sec, which only allows 16 microseconds between bytes. Thisç
required polled I/O where the CPU was 100% devoted to the disk during actualç
reads/writes.

   5-1/4" disks have a slower maximum transfer rate, but modern hardware hasç
advantages that can make up for it.  A normal 5-1/4" disk spins at 300 rpm,ç
or 5 rev/sec. Assuming 9 sectors of 512 bytes per track, the maximumç
transfer rate is 22.5K bytes/sec.  The peak data rate is 250K bits/sec, orç
32 microseconds per byte. This is slow enough for a 4 MHz Z80 to (barely)ç
handle it on an interrupt basis.  Here's an interrupt handler to read 256ç
bytes from a disk controller chip at 32 microseconds max. per byte:

T-states
   23                       ; time to finish longest instruction
   13                       ; Z80 interrupt mode 0 or 1 response
   11 int:  push af         ; save registers used
   11       in   a,(data)   ; read data byte from disk controller
   13 next: ld   (buffer),a ; store it in buffer (a variable)
   13       ld   a,(next+1) ; get buffer address
    4       inc  a          ;   increment
   13       ld   (next+1),a ;   save for next time
    7       jr   nz,done    ; if end of page, done
   10       pop  af         ;   else restore registers
   10       ret             ;   and return
  ----
  128 T-states max = 32 microseconds with a 4 MHz Z80

   But this routine barely squeaks by. It can't use interrupt mode 2 (whichç
adds 6 T-states to the response time) or signal Z80 peripherals that theç
interrupt is complete with an RETI (which adds 4 T-states).  It's limited toç
a 256-byte sector.  Worse, some disk controller chips need processing timeç
of their own.  The popular Western Digital FD179x series only allows 27.5ç
microseconds for each byte.

   So we have to get clever again.  The following example reads pairs ofç
bytes, the first on an interrupt and the second by polled I/O.  Thisç
improves performance to allow interrupt mode 2, larger sector sizes, and theç
slow response time of a FD179x chip:

T-states
   23                       ; time to finish longest instruction
   19                       ; Z80 interrupt mode 2 response time
   11 int:  push af         ; save A and flags
   11       in   a,(data)   ; read 1st byte from disk controller
   11       push hl         ; save HL
   10 next: ld   hl,buffer  ; get buffer address (a variable)
    7       ld   (hl),a     ; store byte in buffer
    6       inc  hl         ; advance buffer pointer
    6       inc  hl         ;   for next interrupt
   16       ld   (next+1),hl;   & store it
    6       dec  hl         ;   point to current address
11+11 check:in   a,(status) ; check disk controller status
 4+ 4       rra             ; if not busy (bit 0=1),
 7+ 7       jr   nc,done    ;   then we're done
 4+ 4       rra             ; if next byte not ready (bit 1=0),
12+ 7       jr   nc,check   ;   then loop until it is
   11       in   a,(data)   ; get 2nd byte from disk controller
    7       ld   (hl),a     ;   & store it in buffer
   10       pop  hl         ; restore registers
   10       pop  af
   14       reti            ; return
  ----
  188 or 226 T-states (for 1 or 2 passes through status loop)

   This routine reads bytes from the controller chip within 17.75ç
microseconds worst-case.  Interrupt overhead averages 80% for a 4 MHz Z80,ç
leaving 20% for the main program execution.  The peculiar way ofç
incrementing the address pointer minimizes the worst-case delay from anç
interrupt or status flag change until the byte is read.  We want to maximizeç
the chance that the second character is ready the first time the status isç
checked.

   Why improve your disk system?  Because, as a practical matter, there'sç
more to be gained by improving it than any other change you could make. ç
It's disk I/O that sets the pace, not CPU speed or memory size.  Usersç
almost never wait on CPU speed; it's the disk that keeps you twiddling yourç
thumbs with the keyboard ignored, the screen frozen, and the disk driveç
emitting Bronx cheers.  Put a Commodore 64's tinkertoy disk system on an AT≠
clone, and you'd have high-priced junk that only a masochist would use.ç
Conversely, the AT's DMA-based disk I/O would transform a C64 into a fire≠
breathing dragon that would eat its competition alive.


                                 Algorithms

   When a hardware engineer sits down to design a circuit, he doesn't beginç
with a blank sheet of paper.  He has a vast library of textbooks, dataç
sheets, and catalogs of standard circuits to choose from.  Most of the taskç
is simply connecting off-the-shelf components into one of these standardç
configurations, modifying them as necessary to satisfy any uniqueç
requirements.

   Algorithms are to programmers what IC chips are to hardware designers.ç
Just as the engineer builds a library of standard parts and circuits, everyç
programmer must continually build his own algorithm collection.  Whetherç
it's a shoebox full of magazine clippings or a carefully indexed series ofç
notebooks, start NOW.

   Programming textbooks tend to concentrate on traditional computer ç
algorithms for floating-point math, transcendental functions, and sortingç
routines.  The old standby is Knuth's "The Art of Programming".  Hamming'sç
"Numerical Methods for Scientists and Engineers" explains the basics ofç
iterative calculations.  "Digital Computation and Numerical Methods" byç
Southworth and Deeleeuw provides detailed flowcharts and sample code asç
well.

   Magazines are a great source and tend to be more down-to-earth and closerç
to the state of the art.  Read carefully!  Good algorithms may be expressedç
in BASIC listings, assembly code for some obscure processor, pocketç
calculator key sequences, and even disguised as circuit diagrams.ç
Professional journals like EDN or Computer Design are often better than theç
popular magazines, which have pretty much abandoned education in favor ofç
marketing.  Especially check out back issues.  The cruder the hardware, theç
trickier the algorithms had to be to make up for it.

   Manufacturers' technical literature is a gold mine. Get the ç
manufacturers' own manuals, not some boiled-down paperback from theç
bookstore.  They won't be models of clarity but are full of hidden gold.ç
Read everything, hardware and software manuals, data sheets, applicationç
notes, etc.

   User groups are the traditional source of solutions to specific ç
problems.  Even better, they provide actual implementations in printedç
listings, on disk, or even by modem.

   Don't waste time reinventing the wheel.  Learn from others what works,ç
and what doesn't.  Some of the best (and worst) algorithms I know were foundç
by disassembling existing programs.  And once you find a good algorithm,ç
recycle it.  That clever sort routine for an antique 8008 may be theç
foundation of the fastest '386 sort yet!


                                 Conclusion

   These techniques are not new; in fact old-timers will recognize many ofç
them from the early days of computing when hardware limitations were moreç
severe.  However, they have fallen into disuse.  A whole generation ofç
programmers has been taught that such techniques have no place in modernç
structured programming.

   The theory goes something like this: Programs written in a high-levelç
language are faster and easier to write, debug, document, and maintain.ç
Memory and speed are viewed as infinite resources, so the performance lossç
is unimportant.  Programs should be totally generic; it is the compiler's orç
run-time library's job to worry about the hardware interface.

   These rules make sense in a mainframe environment, where the hardwareç
resources are truly awesome, and teams of programmers spend years working onç
one application.  But they impose severe penalties on a microcomputerç
system.  The user must pay for the programmer's luxuries with higherç
hardware cost and lackluster performance.

   It's easy to forget that "microcomputer" literally means "one millionthç
of a computer".  Microprocessors make abysmally bad CPUs.  Build a computerç
with one, and you'll wind up needing $5000 worth of memory and peripheralsç
to support a $5 CPU chip.

   But micros make superlative controllers.  That's what they were designedç
for, and what they do best.  A single microcomputer can replace dozens ofç
boards and hundreds of ICs with as little as a single chip.  That's why 90%ç
of all microprocessors go into non-computer uses: calculators, auto emissionç
controls, home entertainment equipment, industrial controls, and the like.ç
Of 30 million Z80s sold last year, fewer than 1 million went into computers.

   Programming a controller is different than a computer.  Most applicationsç
demand real-time multi-tasking capabilities, and there is never enough speedç
or memory.  Inputs and outputs are physical hardware devices, not abstractç
data structures, so the code must inevitably be hardware-dependent. ç
Computer languages are just not cut out for this sort of thing.

   The question is not, "How do I write a computer program to handle thisç
data?"  Instead, you should ask yourself, "How must I manipulate thisç
hardware to do the job?"  The techniques in this article may be out of placeç
in the bureaucracy of a large computer but are right at home in the wild≠
west world of a microcomputer.

   Lest you think this has nothing to do with a "real" computer like your PCç
clone, consider this.  Instead of a '286 with 1 meg of memory, suppose itç
contained ten Z80 controller boards, each with 64K of memory and a fastç
network to tie them together.  Each Z80 handles a different device:ç
keyboard, screen, printer, modem, and one for each disk.  The rest are freeç
to run application programs, several at a time!

   Suppose you're doing word processing on this system.  The keyboard doesç
spelling correction on data entry.  The screen Z80 displays your text inç
bit-mapped fonts to match the printer's Z80, which is simultaneouslyç
printing a file.  The Z80 running the word processor itself suffers noç
annoying pauses or hesitation, since disk I/O is handled instantaneously viaç
each drive's Z80 track buffer.  Meanwhile, the modem's Z80 is downloading aç
file while another assembles a program.  Pop-up utilities are ready andç
waiting in still other Z80s in case they're needed.

   Such a system would clearly have half the hardware cost of a PC, yetç
would outperform it by a wide margin.  True multi-tasking becomes child'sç
play with multiple processors.  More processors can be readily added forç
even higher performance, or removed to save cost (or continue operationç
while waiting for a replacement).

   If the computer scientists really want to further the micro-revolution,ç
they should stop trying to force antiquated mainframe languages onto microsç
and concentrate on developing tools to maximize the use of micros as theyç
are!
                           