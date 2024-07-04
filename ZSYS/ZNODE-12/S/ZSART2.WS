..No justification
..No multiple spaces, use TAB chars (^P^I)
..Bolding with ^P^B, Italics with ^P^Y

ZSDOS, Anatomy of an Operating System, Part II

                               by
Harold F. Bower, Major, US Army Signal Corps; BSEE, MSCIS, Ham ç
(WA5JAY), avid homebuilder (starting with 8008 running SCELBAL).
                               and
Cameron W. Cotrill, Vice President, Advanced Multiware Systems; ç
specialist in "impossible" real-time hardware and software ç
systems.


In the first part of this article, we presented the philosophy ç
and the features of ZSDOS (Z-System Disk Operating System). In ç
this portion, we will summarize the performance of ZSDOS, share a ç
few of the tricks we used to shoehorn all these features into 7 ç
bytes, and give a few programming examples showing how to use ç
some of the new features of ZSDOS and ZDDOS.

ZSDOS Performance.

Measuring the performance improvements of ZSDOS is a complicated ç
matter. During development, an entire suite of tests was run on ç
ZS/ZDDOS in various configurations in an attempt to validate the ç
design tradeoffs. The most revealing tests of BDOS differences ç
turned out to be a series of assemblies done under control of a ç
command script. This should be no surprise as assemblies are by ç
nature disk intensive. 

To reduce the perception that our results are "tailored" or ç
skewed in favor of a particular system or configuration, ç
different processor chips (Z80 and HD64180), different BIOSes ç
(MicroMint, XBIOS, Ampro), and different media (RAM disk, Hard ç
Disk and Floppy disk) were used in the timed runs. Since the ç
results were most affected by the media, results are shown in the ç
categories of RAM, Hard Disk and Floppy Disk performance. No form ç
of file date stamping was done since ZSDOS would have a distinct ç
advantage in this field.

Three sets of hardware were used in these analyses in an attempt ç
to minimize the effect of any unique processes in a given system ç
from skewing the results. The first system (System 1 in the ç
timing runs) was a "stock" MicroMint SB-180 operating at a 6.144 ç
MHz clock speed. System 2 was an Ampro Little Board 1A with a Z80 ç
running at 4.0 MHz, and System 3 was a homebrew Z-180 system ç
designed to be compatible with the SB-180 operating at 9.216 MHz. ç
Complete information on each system in the Appendix.


OPERATING  SYSTEMS.

CP/M 2.2. Gary Kildall and Digital Research developed this ç
operating system for 8-bit processors in an evolutionary process ç
on early 8080-based computers. A subsequent product, CP/M Plus ç
(also known as CP/M 3) is still in limited use, but has not çägained the wide acceptance of the earlier release. CP/M 2.2 is ç
coded in 8080 assembly language and is a non-banked, non-ç
reentrant single-user, single tasking operating system.

ZRDOS 1.9. Echelon Incorporated released many versions of this ç
CP/M 2.2-compatible operating system over the past several years. ç
It is coded in Z80 assembly language and will therefore not ç
execute on 8080 processors. Some additional features were added, ç
such as one-level reentrancy under user control, and return of ç
the current DMA address. Later versions (after 1.5) include ç
enhanced support for hard disk media by not rebuilding the ç
allocation bit map on a disk relog command. Version 1.9 added ç
larger disk and file sizes. Like CP/M, it is single-user and ç
single-tasking.

ZSDOS. This is the topic of this article, with details and ç
descriptions of features contained in Part I. ZSDOS is coded in ç
Z80  assembly language and is also a single-user,  single-tasking ç
operating system capable of single-level reentrancy.

Since this report was an aimed at formalizing an evaluation of ç
the performance characteristics of ZSDOS, a number of different ç
variants to the above operating systems were initially timed. ç
Because the performance of these systems was very similar to ç
others in the test, their comparative results are simply ç
summarized below.

CP/M 2.2 with Plu*Perfect Systems' PUBlic patch. Only minor ç
differences in performance from the basic CP/M 2.2 were noted, so ç
results of the patched system were not included in the final ç
results.

ZRDOS 1.2. The performance of ZRDOS 1.2 was very close to CP/M ç
2.2, being a couple of percent slower in the majority of cases. ç
It was therefore not included in the final timing analyses.

ZRDOS 1.7. Timing tests indicate no significant performance ç
differences between ZRDOS 1.7 and 1.9.

ZDDOS. Since ZSDOS and ZDDOS are largely the same code and since ç
comparative timings between them show less than a 1% difference, ç
only times for ZSDOS will be presented. 


BASIC  IO SYSTEMS (BIOSes).

MICRO MINT, SB-180. While MicroMint currently ships Version 3.2 ç
with their systems, a slightly modified version of 2.7 was used ç
in these timings on the SB-180. The changes included independent ç
step rates for floppy drives, different floppy formats and fixing ç
of eight-inch drivers as well as a slight amount of optimization. ç
Little performance difference from the standard BIOS should be ç
noticed. A 54k system size was used. The BIOS uses programmed IO ç
on most peripherals with DMA functions of the 64180 processor ç
used for Floppy and RAM disk data movement.ä
XBIOS, SB-180. XSystems' XBIOS version 1.1 is an extremely ç
powerful and flexible banked system with excellent tools and ç
interfaces. Malcom Kemp has concentrated on providing functions ç
in this release, and has deferred optimization to future ç
releases. XBIOS fully supports the ETS180 IO+ board, allows ç
complete configuration of peripherals, and provides a larger TPA ç
since only a small kernel resides in the primary memory area. ç
Most of the BIOS code resides in an alternate memory bank. XBIOS ç
installs the largest possible TPA when used which was 57.5k for ç
these tests. XBIOS was installed with three buffers for disk IO.

AMPRO, Little Board-1A. A stock version of the Ampro version 3.8 ç
BIOS assembled with no ZCPR support was used for testing. A ç
system size of 59k was chosen to provide support for 5 hard disk ç
partitions spread over two physical drives. NZCOM was then loaded ç
to provide Z-System support. The Ampro BIOS is strictly a polled ç
system and uses no interrupts or DMA.


EVALUATION  PROCEDURES.

Since the goal of evaluating performance was to heavily exercise ç
BDOS functions, a set of fourteen assembly modules, thirteen of ç
which were 2-4k in size, and one of 6k were assembled to produce ç
Microsoft REL files. To restrict external influences, no file ç
date stamping was used, and many ZSDOS features such as Public ç
and Path were disabled. On the other hand, to provide a semi-ç
realistic setting, ZEX.COM and the executable assemblers were ç
placed in a different Drive/User with the ZCPR search path set to ç
locate the files on the second directory scan. SLR's SLR180 ç
assembler was used on system 2, while tests on systems 1 and 3 ç
used Z80ASM+. Assembly was done under the control of a memory-ç
based SUBMIT utility (ZEX Version 3.1A) script file. Times were ç
measured from the carriage return terminating the command ç
invoking the ZEX file to display of the "Done" message after ç
assembly of the last file. After each run, the .REL files ç
produced by the assembly were erased so that the same disk space ç
could be used in the next run. No other files were added or ç
deleted to any media during the timing runs. At least three runs ç
were performed for each configuration, and the results averaged. ç
Timing was manually performed with a stopwatch.

Due to the radical differences in access times for different ç
media, three categories of times were considered; RAM disk, Hard ç
Disk, and Floppy disk. If you think you know how each system ç
fared, read on - there may be a twist or two in the plot. 

RAM DISK. The Ampro has no RAM disk, so timings in this category ç
reflect only the SB180. The SB180 computer is equipped with 256k ç
of memory. The standard MicroMint BIOS divides this into a 64k ç
main memory area and a 192k RAM disk. With XBIOS as tested here, ç
64k is allocated for the main memory, 24k for the banked portion ç
of XBIOS, buffers and banked system extensions. The remaining ç
space is available for a RAM disk. RAM disks on the SB180 use çäbuilt-in DMA capabilities of the HD64180 processor to move ç
"sectors" of data rather than the slower block move instructions ç
used by Z80 systems.

Exiting a program via the Warm Boot vector in CP/M relogs the A ç
drive. To minimize time penalties imposed by this, a Hard disk ç
partition was defined as the A drive. Needed programs as well as ç
the assembly modules were placed on the RAM disk (M:), with ç
ZEX.COM and Z80ASM+.COM placed in User 15 and the sources files ç
in User 0. The search path for this phase was: Drive M, User 0 to ç
Drive M, User 15.

Since the RAM disk is defined as a non-removable media in the ç
Disk Parameter Block, the "Rapid Relog" feature of ZSDOS and ç
ZRDOS was expected to produce much shorter execution times than ç
CP/M for this series of measurements. As can be seen from the ç
results, this was indeed the case. The raw timings in seconds ç
with percentage changes from the shortest time are:

		ZSDOS		 ZRDOS 1.9	 CP/M 2.2
	    +------------------------------------------------+
 BIOS 2.7   | 17.0 (---)	17.1 (+4%)	36.4 (+114%) |
 XBIOS 1.1  | 14.2 (---)	14.5 (+2%)	34.5 (+144%) |
	    +------------------------------------------------+

The effects of the Rapid Relog feature were borne out, with ZSDOS ç
being a couple of percent faster. Disabling the Rapid Relog ç
feature of ZSDOS produced nearly identical results to CP/M, so ç
most of the additional time for that system may be attributed to ç
rebuilding the disk allocation bit maps for Drives A and M on ç
each warm boot.


HARD DISK.

Three systems, 6.144 MHz SB-180 (System 1), 4.0 MHz Ampro Little ç
Board-1A (System 2), 9.216 MHz Z-180 Homebrew SB-180 (System 3), ç
were used to gather information for this phase. This latter ç
system was added to demonstrate performance on a heavily loaded ç
system.

	          ZSDOS		  ZRDOS 1.9	  CP/M 2.2
	     +------------------------------------------------+
 1-BIOS 2.7  | 0:54.7 (---)	1:16.6 (+40%)	1:34.7 (+73%) |
 1-XBIOS 1.1 | 0:52.2 (---)	1:15.4 (+44%)	1:33.4 (+79%) |
 2-AMPRO     | 1:55   (---)	2:44   (+43%)	3:15   (+70%) |
 3-BIOS 2.7  | 1:07.7 (---)	1:40.6 (+49%)	1:50.2 (+63%) |
 3-XBIOS 1.1 | 1:29.5 (---)	2:06.4 (+41%)	2:11.3 (+47%) |
	     +------------------------------------------------+

As in the previous RAM Disk results, the results of ZSDOS with ç
"Rapid Relog" disabled and CP/M were nearly the same confirming ç
that rebuilding the allocation bit maps on a disk relog is the ç
principle cause for the increased CP/M times.
äAll reported times were made with a path which forced a search of ç
the current directory before locating executable files on the ç
second path element. As an experiment, the path on the Ampro ç
system was changed to go directly to A2:, eliminating the current ç
directory scan. All DOSes showed an identical 10 second speedup, ç
indicating directory scan time for all DOSes was the same.

A further point to note is the effect of multiple disk buffers on ç
performance. For system 1, the number of buffers was adequate to ç
retain directory information which improved performance over the ç
single-buffer Micromint BIOS by 1-5%. In system 3, the buffering ç
was inadequate to retain necessary information, so the multiple ç
buffers were of no benefit.


FLOPPY DISK.

Examination of system performance on a Floppy Disk system was ç
tailored to duplicate, as closely as possible, a hypothetical ç
operating configuration using multiple drives with non-trivial ç
search path along differing Drives and User area lines.

Since all three primary operating systems of interest to this ç
analysis (ZSDOS, CP/M 2.2 and ZRDOS 1.9) rebuild removable-media ç
disk allocation maps on a relog, there was no need to explicitly ç
disable the "Rapid Relog" feature of ZSDOS for this portion of ç
the study. Results are:

		ZSDOS		 ZRDOS 1.9	  CP/M 2.2
	      +----------------------------------------------+
 BIOS 2.3     | 2:18.7 (+2%)	2:22.4 (+5%)	2:16.0 (---) |
 XBIOS 1.0    | 2:29.5 (+0.5%)	2:32.7 (+3%)	2:29.0 (---) |
 AMPRO        | 2:26   (+1%)	2:28   (+2%)	2:25   (---) |
	      +----------------------------------------------+

Since all of the operating systems are functionally identical in a ç
Floppy Disk configuration, we did not expect large differences in ç
measured times. We were therefore not surprised with variations ç
over a spread of only five percent. While we strove to make ZSDOS ç
as efficient as possible, CP/M was still the champ on floppy ç
systems by a nose.

As a final comparison test between the three DOSes, the amount of ç
time WordStar 4 took to ^QC and ^QR through the 92k ZSDOS source ç
file was measured under all three DOSes. All timings were within ç
1%, indicating that read/write to open file times were similar.


PERFORMANCE CONCLUSIONS.

ZSDOS offers significant improvements in system performance on ç
CP/M 2.2 compatible Z80-compatible computer systems with fixed ç
media even under the restricted test conditions which disabled ç
some of the most powerful features of ZSDOS. Even more impressive ç
results may be obtained in a "tuned" installation with such çäfeatures as Public files, and proper selection of the DOS search ç
path (improvements of 9% on a hard disk system are typical).

The other major conclusion that can be drawn from this effort is ç
that the selection of a BIOS tailored to the requirements is ç
crucial to achieving optimum performance. The multiple buffering ç
capability of XBIOS offers speed increases in systems where an ç
adequate number of buffers exists, but degrades floppy-based and ç
heavily loaded hard disk performance.

During the data gathering for this report, an anomaly was noted ç
with respect to CP/M Plus (or P2DOS) stamps. System #1 was ç
initialized for P2DOS stamps on the disk holding data files to ç
quantify the differences. In all cases ZSDOS was affected less ç
than one percent, yet ZRDOS increased to seven percent longer ç
than ZSDOS on RAM disk, 20% longer on floppy and 144% longer on ç
hard disk. CP/M 2.2 was similarly affected, but to a lesser ç
degree, increasing times over ZSDOS to 115% on RAM disk, ten ç
percent on floppy and 140% on hard disk. While neither ZRDOS nor ç
CP/M 2.2 can manipulate this type of stamp, merely using a disk ç
which is so prepared will result in slower processing.


HOW WE DID IT.

During the year or so that we pursued our independent paths in ç
modifying H.A.J. Ten Brugge's excellent P2DOS alternative to CP/M ç
2.2's BDOS, our approaches were somewhat diverse. While Cam's ç
approach was directed at perfecting features, Hal's effort was ç
directed at streamlining the code to create a "speed demon" ç
operating system, and Carson concentrated on enhancing embedded ç
Date Stamping. In mid-1987, Bridger Mitchell was instrumental in ç
getting us to pool our resources and collaborate in a joint ç
venture. The results have been more than worth it. In Part I, we ç
described the functional enhancements and standards embodied in ç
ZSDOS, and have just shown the performance improvements compared ç
to CP/M 2.2 and ZRDOS 1.9. In our efforts to foster better code ç
for our 8-bit systems, we would now like to describe how the task ç
of adding features and decreasing execution time was accomplished ç
without increasing the Operating System memory requirements.

The topic of code optimization is a controversial one. In the ç
early days of computers, programmers were saddled with small ç
memory space and slow processors, so every effort was made to ç
optimize programs for speed and size. As memory became cheaper ç
and processors emerged with ever increasing clock speeds, ç
programming techniques became lost to all but a few. This same ç
path of evolution has also been followed in the Personal Computer ç
field.

To demonstrate this point, first compare the 3.5 kbyte CP/M 2.2 ç
BDOS and the 1 kbyte Plu*Perfect DateStamper to the functionally ç
superior 3.5k ZDDOS. Next, compare the 3.5 kbyte size of CP/M 2.2 ç
and ZSDOS to the 16 kbyte size of the functionally similar MS-DOS ç
2.1. To carry the point further, contrast the almost 16 kbyte çäCOMMAND.COM to the 7 kbyte size of a more capable ZCPR3 Command ç
Processor with a full environment. Some of this bloat is ç
understandable with the change in processor chips. On the other ç
hand, the more powerful instructions of 16-bit 808x processors ç
should have counteracted a good portion of this code bloat.

In line with the size comparisons, execution speeds also suffer ç
with the larger code. Friends and co-workers who are used to ç
working with PCs and clones operating at 4.77 and 8 MHz clock ç
rates are constantly amazed at the speed of even a lowly 4 MHz ç
ZSDOS system, and dazzled at the 6 and 9 MHz Hitachi 64180 ç
systems running the same software! While much of this is ç
subjective, quite a bit is due to the fact that the "smaller" 8-ç
bit code has been hand-coded and optimized, whereas the PC arena ç
is devoting more of its energy to coding in high-level languages. ç
This makes sense under certain circumstances (e.g. during ç
development and for long-term maintainability), but it most ç
certainly does NOT make sense for operating systems where size ç
and speed are of the essence.

Since all of our efforts have been directed at the Zilog Z80 and ç
compatible family of microprocessors (including Hitachi's 64180 ç
and National's NSC800), the optimization steps covered here apply ç
directly only to these. Having stated that, we also need to point ç
out that many of the basic concepts will still apply to other ç
processors, although details may differ.

No matter what processor is used, the goals of faster program ç
execution and smaller memory size are in conflict. Smaller memory ç
size normally means using each section of code as many times as ç
possible - typically by using many subroutines. Faster code ç
execution often means avoiding as many subroutine calls as ç
possible. In every program undergoing optimization, the ç
conflicting size and speed requirements must be balanced. This ç
balance can be highly subjective. In ZSDOS, code size was the ç
primary concern though significant effort was given to making the ç
smaller code run as fast as possible. 

Now for the minutiae. If you are not a programmer, or are ç
interested only in how to use ZSDOS, you might want to skip to ç
PROGRAMMING FOR ZSDOS. For the diehards - here it is!

One of the first techniques we used in optimizing code was to ç
examine all JUMP instructions. The basic instruction is three ç
bytes long and executes in 10 clock cycles on a Z80. These ç
absolute jumps may be unconditional (JP addr), or conditional (JP ç
C,addr) based on the contents of the Carry, Zero or ç
Parity/Overflow flags. The Z80 also features a two-byte Relative ç
jump (JR) which also may be absolute (JR addr), or conditional ç
(JR C,addr) based on the Carry or Zero flags. The relative jump ç
is only two bytes long and may branch only to addresses within ç
the range of +127 to -128 bytes of the jump instruction. While it ç
is relatively easy to blindly change all jump instructions within ç
range to Relative jumps, the careful programmer will also note ç
that the Relative jump may carry a time penalty. The absolute çärelative jump, and conditional jumps where the condition is ç
satisfied (the jump is taken) require 12 clock cycles compared to ç
the long jump consuming only 10 cycles regardless of condition. ç
On the other hand, conditional relative jumps need only 7 cycles ç
if the condition is false. This type of optimization was one of ç
the first used in our efforts to enhance P2DOS.

The next simple optimizing technique we used was to make maximum ç
use of the Decrement-B and Jump Relative if Not Zero (DJNZ) ç
instruction. This two-byte sequence executes in 8 or 13 clock ç
cycles (B=0 and B<>0 respectively) for an absolute time and code ç
saving over separate decrement/jump sequences. In some of our ç
work on ZSDOS, using this instruction required redefining ç
register usage to free up the B register for use as a counter.

Another simple optimizing step was examining the use of the IX ç
register. IX holds the argument passed to DOS in the DE register ç
(typically a file control block pointer). Despite having this ç
value available all the time, there were a significant number of ç
cases when faster and/or shorter code was produced by moving the ç
pointer into HL. This was normally the case when the same offset ç
within the FCB was accessed two or more times in succession.

The final "simple" optimization technique we used was to examine ç
all PUSHes and POPs to the stack and delete any found to be ç
unnecessary. While this sounds simple, it is quite a chore in a ç
complex program such as ZSDOS where CALLs call other CALLs which ç
call still other CALLs, etc. Each path must be examined to insure ç
that the registers are, in fact, not altered or needed.

After the above "simple" optimizations were performed, A series ç
of what we term "moderate" optimization steps were undertaken. ç
One of these involved examining all series of sequential checks ç
on a byte (such as the input command character scanner) and ç
structure the check sequences to optimize performance based on ç
clock cycle counting mentioned above, and estimated frequency of ç
access for various commands. In the case of the command ç
dispatcher, this technique resulted in extremely fast command ç
parsing implemented with minimum code.

Sequential bit shifts and rotates are another area where more ç
analysis is required before final code can be written. Sixteen-ç
bit shifts, and 8-bit shifts in registers other than the ç
accumulator are areas where gains can be achieved. The usual ç
method of using a subroutine which loads all bytes to the ç
accumulator for shifts and rotates fares poorly if only one or ç
two bit shifts are needed. While most of these cases had been ç
removed from the P2DOS code by the original author, the ç
replacement inline code still suffered from some inefficiencies. ç
A two-bit shift right (division by 4) of the 16-bit HL register ç
pair in the STDIR routine using the code:

	SRL	H	; Divide by 2
	RR	L
	SRL	H	; Divide by 4ä	RR	L

proved optimum. Using a two-iteration loop with the DJNZ ç
instruction around a single SRL H, RR L sequence would have ç
produced the same 8-byte code length, but at a penalty of 21 ç
clock cycles. A call to a subroutine would have fared even worse ç
with a 27 clock cycle CALL/RET penalty, and four bytes of ç
overhead. On the other hand, three-bit shifts of the HL ç
register pair occurred in a number of routines. These were ç
consolidated into a single callable routine that uses the B ç
register as a counter in an iterative loop with the sequence:

SHRHL3:	LD	B,3
SHRHLB:	SRL	H
	RR	L
	DJNZ	SHRHLB
	RET

While the replacement code added overhead, it saved 3-5 bytes  of ç
code  (depending on entry point) which were sorely needed to  add ç
additional features. ZSDOS calls this routine from three places, ç
while  ZDDOS calls it from five. The difference is due to  ZSDOS ç
"unrolling" the loop in time critical routines.

Shifts to the left were occasionally handled a little more ç
efficiently by using the 16-bit ADD instructions of the HL ç
register pair to perform bit shifts. An example of this appeared ç
in the CALST routine. In this case, the DE register pair was ç
rotated one bit to the left with sequential RL E, RL D ç
instructions, with the Carry bit shifted into the HL register ç
pair. Where the original code used the sequence: RL L, RL H to ç
shift the bit into the HL pair, a two byte code savings was ç
achieved with the single two-byte ADC HL,HL instruction.

Another area where considerable code and time savings were ç
realized was in the consolidation of routines into "straight-ç
line" code. While this seems to be an anathema to structured ç
programmers, it is often a must to obtain the performance ç
improvements which we sought from our efforts. As a first step, ç
all routines ending in Jump instructions were examined. Target ç
addresses were then checked to insure that no other routine "fell ç
through" to them. If it was in fact a "stand-alone" routine, it ç
was moved to the end of the first routine so that the Jump could ç
be deleted. An example of this is where the INITDR routine was ç
moved to follow SELDK directly saving the two-byte relative jump ç
and 12 clock cycles. Other cases involving long jumps saved three ç
bytes and 10 clock cycles. A minor variation in relocation of ç
code is to group functions to bring them within range of relative ç
jumps thereby saving one byte at the expense of two clock cycles. ç
This minor penalty in time often outweighed the value of a single ç
byte of code in our efforts.

A variant on this concept involved examining sequences of code ç
for duplicity, and combining identical sequences into new ç
routines which "fall through" to the destination. This was amply çäused to define a new routine:

SRCT15:	LD	A,15
	CALL	SEARCH

This sequence was placed immediately before the TSTFCT routine, ç
and replaced three occurrences of:

	LD	A,15
	CALL	SEARCH
	CALL	TSTFCT

with a single CALL to SRCT15. The overall effect of this one ç
change was a savings of 10 bytes of code and 24 clock cycles for ç
each of the three sequences replaced.

Detailed examination of code also produced unexpected savings by ç
merely defining new labels. As an example, the last three ç
instructions of the routine OPENEX were:

	LD	A,0FFH
	LD	(PEXIT),A
	RET

This sequence occurred two other times in the original code, and ç
three times in the latest version of ZSDOS. The last two ç
instructions were repeated in many locations, so one location was ç
selected (centrally located to take advantage of relative jumps), ç
with other instances accessing it with a call or jump to the new ç
label, SAVEA. Setting the value to 0FFH in OPENEX was labeled as ç
SETCFF, and the other two occurrences jumping to this location. ç
While a small time penalty was incurred in jumping to this common ç
code, the three byte savings was again needed to add features.

Our code "walk-throughs" and optimization efforts did not stop ç
with the original code, but continued with every test version. ç
First, we discovered a common "shell" of instructions around the ç
DELETE, CSTAT, and RENAME functions and combined them with a net ç
savings of 12 bytes. Later, a trick used in public-domain inline ç
print routines to pass addresses on the processor's stack was ç
used to recover five bytes of code by replacing three sequences ç
of:

	LD	HL,(address)
	JR	COMCOD

with three 3-byte CALL COMCOD instructions. The trick involved in ç
this change was to place the CALLs immediately in front of the ç
routines whose addresses were to be passed to COMCOD. When ç
executed, the CALL placed the routine address on the stack. A ç
one-byte POP HL instruction at the beginning of COMCOD completed ç
the change by placing the address in the desired HL register. ç
Still later, the internal code in the COMCOD routine was again ç
optimized to remove several memory references. This saved another ç
four bytes.ä
Cameron's rewrite of the Console IO routines demonstrated another ç
technique of reducing code size with very little overhead. The ç
majority of affected code involved different DOS commands, yet ç
exited through common code with absolute jumps. By PUSHing the ç
exit address on the stack prior to jumping to the routines, a ç
simple RETurn instruction sufficed to direct execution through ç
the exit code saving two bytes per occurrence. The four bytes ç
required to set the return address meant that the code size ç
break-even point occurred at two instances. Since far more cases ç
than that were involved, a significant code size reduction was ç
realized. For DOS function calls, the time penalty incurred was ç
21 clock cycles, however, that was not considered significant ç
when dealing with the normal serial IO devices used in console ç
functions.

A final noteworthy trick was added by Cameron which neither of us ç
had ever seen documented in the Z80 world. It used the sixteen-ç
bit load instruction into the IX register (a four byte ç
instruction) to "fall through" successive 16-bit loads to the ç
primary registers. In this fashion, the sequence:

CMND27:	LD	HL,(ALV)
	JR	SAVHL

CMND24:	LD	HL,(LOGIN)
	JR	SAVHL

CMND31:	LD	HL,(IXP)
	JR	SAVHL

CMND47:	LD	HL,(DMA)
SAVHL:	LD	(PEXIT),HL
	RET

was replaced by a more efficient (in code size) construct. The ç
bytes, as coded, are on the left, with the instructions seen by ç
CMND27 shown on the right:

CMND27:	LD	HL,(ALV)	CMND27: LD	HL,(ALV)
	DEFB	0DDH			LD	IX,(LOGIN)
CMND24:	LD	HL,(LOGIN)
	DEFB	0DDH			LD	IX,(IXP)
CMND31:	LD	HL,(IXP)
	DEFB	0DDH			LD	IX,(DMA)
CMND47:	LD	HL,(DMA)
SAVHL:	LD	(PEXIT),HL		LD	(PEXIT),HL
	RET				RET

This code works because the IX register is not used in the ç
remainder of the exit code, and the entry IX value is restored ç
upon returns from ZSDOS functions. Each cascaded value saves one ç
byte of code, but adds additional clock cycles to the execution ç
time. Where the original code required a constant 28 clock cycles ç
before arriving at the SAVHL routine, the new code execution time çäis different for each entry point. In this example, the time (in ç
clock cycles) required for each entry point to arrive at SAVHL ç
is:

	CMND47	- 16 cycles
	CMND31	- 20 + 16 = 36
	CMND24	- 20 + 20 + 16 = 56
	CMND27	- 20 + 20 + 20 + 16 = 76

At this point, an analysis of probable calling frequency was done ç
to order the calls so that the most frequently used functions ç
would incur the least penalty. The ordering shown here was judged ç
to be the optimum sequence.

In a similar manner, eight-bit loads of the A register were ç
consolidated at the beginning of the SEARCH routine. Our analyses ç
of the code showed that SEARCH was called several times with ç
values of 12 and 15 in the A register. Loading of these values ç
was relocated to the beginning of SEARCH, then consolidated with ç
another single-byte DEFB prefix. The resultant code as entered, ç
and as seen by SEAR12 is:

SEAR12:	LD	A,12		SEAR12:	LD	A,12
	DEFB	21H			LD	HL,0F3EH
SEAR15:	LD	A,15
SEARCH:	...			SEARCH:	...

Instead of posing a time penalty as the LD IX,nn trick described ç
above, this case saved one byte over a relative jump and two ç
clock cycles (JR = 12 cycles, LD HL,nn = 10 cycles). As above, ç
this worked because the HL register contents were "don't care" ç
upon entry to the SEARCH routine.

These techniques are very powerful when code size is at a ç
premium. Any sequence of code that loads a register or register ç
pair then jumps or calls a common routine is a candidate for this ç
technique. You need a register pair to throw away, but this is ç
usually easy to find. 

The final case of optimization is the most difficult, and ç
involved complete logic redesigns. This area is so specific and ç
lengthy that it will not be covered here. As so often stated in ç
textbooks, it is "left as an exercise for the reader" to examine ç
the original P2DOS source and identify areas which can be ç
redesigned. Much logic redesign was required as a part of the ç
added ZSDOS and ZDDOS features, though the effort didn't stop ç
there.

Just as important as what we did to gain speed and reduce size is ç
what we didn't do. P2DOS originally used some self modifying code ç
in the error printing routine. We decided from the outset that we ç
would avoid this practice (tempting though it is..) in order to ç
produce code that could be ROMed and/or run on the Z280 in ç
protected mode. This decision cost us several bytes of code, but ç
allowed us to accomplish our goals.ä
PROGRAMMING FOR ZSDOS.

ZSDOS places a few restrictions on systems which do not exist in ç
other CP/M compatible operating systems. The most significant is ç
that the BIOS MUST NOT DISTURB THE IX REGISTER. So far, the Epson ç
QX-10 and Zorba computers have been identified as having BIOSes ç
that corrupt this register. With NZCOM, we have developed a ç
"protective" NZBIOS (look for ZSNZBI12.LBR on most Z-Nodes) that ç
shields the Z80 registers from ill-behaved BIOSes, but operation ç
without NZCOM on such systems will require that the BIOS be re-ç
written.

On this topic, we would like to propose that all programmers ç
observe register usage more closely. The Z80 alternate and index ç
registers belong to APPLICATION programs, and must be preserved ç
by all operating system components. On the other hand, the "I" ç
and "R" registers, as well as all new 64180 and Z280 registers ç
(with the exception of the Z280's SSP) belong to the BIOS since ç
they are hardware specific and directly I/O related. The Z280 SSP ç
should be reserved for BDOS use.

Before trying to access any of the expanded ZSDOS features ç
discussed in the last issue, you should first insure that the ç
program is in fact executing under ZSDOS. This is a two-step ç
procedure involving a call to check for CP/M 2.2, then a call to ç
the ZSDOS Return Version function. By checking in this manner, ç
your program will be able to identify CP/M 1, 2 and 3 (aka Plus) ç
as well as ZSDOS, ZDDOS and ZRDOS. Code to accomplish this task ç
is:
	LD	C,12		; Return CP/M Version
	CALL	0005		; ..via BDOS
	CP	30H		; Is it CP/M Plus?
	JR	NC,ISCPM3	; ..jump if so
	CP	20H		; Is it CP/M 1.x?
	JR	C,ISCPM1	; ..jump if so w/version # in A
	CP	22H		; Is it CP/M 2.2?
	JR	NZ,BADVER	; ..jump to unknown 2.x version
	LD	C,48		; Now make the extended call
	CALL	0005		; ..via BDOS
	LD	A,H		; Check the DOS type first
	CP	'D'		; Is it ZDDOS?
	JR	Z,ISZD		; ..jump if so, Ver # in L
	CP	'S'		; Is it ZSDOS?
	JR	Z,ISZS		; ..jump if so, Ver # in L
	OR	A		; Is it ZRDOS?
	JR	Z,ISZR		; ..jump if so, Ver # in L
	...			; Else can't identify, do error

Bridger Mitchell's Advanced CP/M column in TCJ #36 also provides ç
sample code to perform this function. A slight variation on the ç
above sequence is used in utilities provided with ZSDOS to enable ç
them to work under a variety of different operating systems. We ç
propose that this technique be used for any future Disk Operating ç
systems by returning a different unique character in the "H" çäregister.

Many programs in the past have relied on unpublished locations ç
within the BDOS to alter the performance or functionality of the ç
system. With ZSDOS, we provide published "standard" ways to ç
dynamically tailor DOS parameters. The most important way of ç
accomplishing this is with a set of configuration bits, or flags. ç
To accommodate future expansion, a word value of sixteen bits is ç
defined with only the lower seven used in the current 1.0 ç
release. The Flag bits used in ZSDOS 1.0 are:

	D D D D D D D D
	7 6 5 4 3 2 1 0
	 \ \ \ \ \ \ \ \_Public File Access
	  \ \ \ \ \ \ \__Public/Path Write
	   \ \ \ \ \ \___Read-Only Disk
	    \ \ \ \ \____Fast Fixed Disk Relog
	     \ \ \ \_____Disk Change Warning
	      \ \ \______BDOS Search Path	*
	       \ \_______Path w/o SYS Attribute	*
	        \________(Reserved)

The cited function is activated by setting the respective bit to ç
a "1", and disabled by clearing the bit to a "0". Since ZDDOS has ç
no search path capability, the features marked with an asterisk ç
pertain only to the full ZSDOS configuration, and are "don't ç
care" bits in ZDDOS. The bits will be returned as the lower byte ç
in the 16-bit word field in the "L" register. Code for returning ç
them is:

	LD	C,100		; Get the FLAGS bits
	CALL	0005		; ..with DOS call
	...			; "L" has present 7 bits

Likewise, the flags may be set from applications programs with ç
Function 101 as:

	LD	DE,(FLAGS)	; 1.0 only recognizes byte in E
	LD	C,101		; Now set flags in ZSDOS
	CALL	0005		; ..with DOS call
	...			; New settings are now effective

Date and Time capabilities are just as easily accessed. The 6-ç
byte Clock data may be retrieved to a specified buffer with DOS ç
Function 98 as:

	LD	DE,TIMEAD	; Address of 6-byte buffer
	LD	C,98
	CALL	0005		; Read Clock from DOS
	INC	A		; Any Errors? (FF --> 0)
	JR	Z,ERROR		; ..jump if error (no clock?)
	...			; Else use the retrieved time
TIMEAD:	DEFB	0,0,0,0,0,0	; Initialized Null DateSpec

With the File Date Stamping capabilities of ZSDOS, we developed a çäsingle standardized way of accessing individual file stamps. ç
Function 102 will copy the set of stamps for a specified file to ç
the current DMA address, while 103 will set the stamps for the ç
specified file to the values at the current DMA address. Since ç
all supported stamping methods (currently DateStamper(tm) and the ç
CP/M Plus compatible P2DOS) feature the same format at the ZSDOS ç
level, no user conversions are needed. Indeed, using special ç
stamp drivers provided with the ZSDOS package, either stamp type ç
may be read with both being written by Function 103 if the ç
destination disk has been so prepared. A sample of code used to ç
copy stamp data from one file to another is:

	LD	DE,DSBUF	; Point to 15-byte stamp buffer
	LD	C,26		; ..and set the DMA address
	CALL	0005
	LD	DE,SRCFCB	; Source FCB (User set already)
	LD	C,102		; Get the source's Stamps
	CALL	0005
	...			; Set User to destination?
	LD	DE,DSTFCB	; Destination FCB
	LD	C,103		; Write Stamps from DMA buffer
	CALL	0005		; ..to Dest file
	...


FINAL THOUGHTS.

ZSDOS was a labor of love. Though we didn't really start out to ç
create such a significant step forward in 2.2 compatible BDOSes, ç
it turned out that way. It is our hope that the ideas presented ç
in ZSDOS will form the basis for the next generation of BDOS ç
replacements. If nothing else, we hope that ZSDOS stimulates the ç
Z80 compatible community to address the issues of standards for ç
datestamping, enhanced error handling, and global file access.

The next step for an improved operating system will be to break ç
the 64k barrier. Joe Wright and Jay Sage's efforts in dynamic ç
system configuration with NZCOM are very useful, but fail to ç
address the fundamental problem - we need to use the banked ç
memory featured in most newer systems. Furthermore, this must be ç
done in a way that allows existing applications to run properly. ç
This means (unlike CP/M Plus) a BDOS that lets BIOS deblock, a ç
BIOS jump table that is directly callable from all banks, system ç
vectors at the normal locations, etc. This also means ç
establishing standards for bank sizes and addresses, hardware and ç
processor independence, and finally universal DOS level and BIOS ç
level interfaces to banked memory. Other standards that will be ç
needed by the next generation of OS's include banked RSX ç
standards (though Bridger Mitchell and Malcom Kemp seem to have ç
this nailed down), banked device driver standards, and expanded ç
TCAPS and ENV definitions (aren't these properly BIOS structures ç
folks?). Now is the time to come together, speak up on these ç
matters, carefully weigh all alternatives, and make our wishes ç
known.
äAlso, we urge the community to support those doing active ç
development for our systems by purchasing legal copies of the ç
software you use. This will allow and encourage development of ç
things like a new, better, and faster banked systems with all the ç
goodies we really want. We applaud the efforts of MicroPro in ç
developing and releasing WordStar 4 for CP/M systems, and ç
encourage other vendors to update their CP/M offerings in the ç
fields of Database Management systems and Spreadsheets for the ç
new generation of systems. Further, let's agree to agree on what ç
we really want. In this manner, we can all concentrate our ç
efforts on applications programs, not rewriting BDOS. In short, ç
let's work together to create a computing environment that will ç
turn the big blue clones green with envy.

In conclusion, what started as independent "labors of love" to ç
produce a better operating system rapidly became identical ç
obsessions as we reverted to counting clock cycles and bytes. We ç
are satisfied with the results, and hope that others will benefit ç
from our work and produce smaller, faster and more full-featured ç
programs to help make our lives easier (and keep from emptying ç
our wallets with requirements for constant upgrades). Finally, we ç
must thank H.A.J. Ten Brugge for beginning this entire episode by ç
releasing P2DOS. Without his efforts, none of us (Cam, Hal and ç
Carson) would have been tempted into the area of operating system ç
authorship, and would have left it to "others" to determine what ç
we need in our respective systems.

APPENDIX: The hardware used in these analyses is:

System #1: MicroMint SB-180.

 Processor:	HD64180 operating at 6.144 MHz clock rate with
		No memory wait states and 2 IO wait states.
 Console:	Serial Console connected to ACSI port 1 at 19.2
		kbps, Interrupt-driven buffered keyboard input.
 Interfaces:	ETS180 IO+ providing SCSI interface and RTC.
 CCP:		ZCPR 3.3 with full environment.
 BIOS:		MicroMint 2.7 modified / XSystems XBIOS 1.1.
 Search Path:	$$:, A15: (Current Drive & User, then A15:)
 Hard Disk:	Syquest SQ-306R 5 Megabyte removeable-media,
		Interleave of 3, 12 microsecond buffered seek,
		Adaptec 4010 controller.
		A: 1576k of 2552k free, 94 files, 68 in User 15.
		B: 2432k of 2568k Free, 17 files, 16 in User 1.
 Floppy Disks:	A: NEC 80-track DSDD, 4 mS step, 4 mS Head Load,
		16k of 782k free, 93 files, 68 in User 15.
		C: Shugart SA465 80-track DSDD, 6mS step, 736k of
		782k Free, 17 files in User 1.

System #2: Ampro Little Board 1A.

 Processor:	Z80A operating at 4.0 MHz.
 Console:	Serial Console connected to DART port 1 at 9600
		baud, hardware handshake enabled.
 Interfaces:	SCSI daughter board with NCR 5830 driving 1610-4çä		controller.
 CCP:		ZCPR 3.4 with full environment.
 BIOS:		Ampro V3.8/NZCOM.
 Search Path:	$$:, A2:, A0: (Current Drive & User, then A2, A0:)
 Hard Disks:	Seagate ST-225 20 Megabyte, interleave of 2,
		200 microsecond buffered seek, Shugart 1610-4
		controller. A Shugart 5Mb full height drive was
		also connected to the controller, but was not
		used in the test.
		A: 2744k of 8160k free, 425 files, 77 in User 2.
		C: 984k of 4192k free, 258 files, 32 in User 3.
 Floppy Drives:	A: Teac 55F 80 track DSDD, 6 mS step, 10k of
		782k free, 74 files.
		B: Teac 55F 80 track DSDD, 6 mS step, 736k of
		782k free, 17 files in User 0.

System #3: Homebrew SB-180 compatible.

 Processor:	Z-180 operating at 9.216 MHz clock rate with
		No memory wait states and 3 IO wait states.
 Console:	Serial Console connected to ACSI port 1 at 19.2
		kbps, Interrupt-driven buffered keyboard input.
 Interfaces:	ETS180 IO+ providing SCSI interface and RTC.
 CCP:		ZCPR 3.0 with full environment.
 BIOS:		MicroMint 2.7 modified / XSystems XBIOS 1.1.
 Search Path:	A15: (ZCPR 3.0 searches current, then A15:)
 Hard Disk:	Shugart SA-712 10 Megabyte, Interleave of 1,
		12 microsecond buffered seek, Shugart 1610-3
		controller.
		A: 324k of 2552k free, 179 files, 101 in User 15.
		D: 252k of 2792k Free, 438 files, 16 in User 5.
