[Note by Jay Sage:  I am always actively recruiting new columnists for TCJ. �
Rick Charnes, whose excellent articles are now appearing in every issue, was�
my first success.  With this issue I would like to introduce the second, Lee�
Hart.  Lee has been carrying forward the development of Poor Person�
Software's Write-Hand-Man, the 8-bit "SideKick".  That kind of program, like�
BGii, cannot tolerate wasteful coding, and in this, the first of two�
articles, Lee shares with us some of his tricks.]


                         PROGRAMMING FOR PERFORMANCE
                                by Lee A. Hart
                        The Computer Journal, Issue 39
                          Reproduced with permission
                           of author and publisher




   Over the years, the ancient masters of the software arts have �
meticulously crafted the tools of structured programming.  They have�
eloquently preached the virtues to body and soul that come from writing�
clean, healthy code, free from the evils of self-modifying code or the�
dreaded GOTO.

   Many programmers have seen the light.  They write exclusively in�
structured high-level languages, and avoid BASIC as if it carried AIDS. �
Assembly language is just that unreadable stuff the compiler generates as an�
intermediate step before linking.  Memory and processor speed are viewed as�
infinite resources.  Who cares if it takes 100K for a pop-up calculator�
program?  And if it's not fast enough, use turbo mode, or a 386.

   But a REAL pocket calculator doesn't have a 16-bit processor, or 100K of�
RAM; it typically runs a primitive 4-bit CPU at 1 MHz or less, with perhaps�
2K of memory.  Yet it can out-perform a PC clone having 10 times the speed�
and memory!

   How can this be?  Special hardware?  Tricky instruction sets?  On the�
contrary; CPU registers and instructions have instead been removed to cut�
cost.  No; the surprising performance comes from clever, efficient�
programming with an extreme attention to detail.  Such techniques are�
essential to the success of every high-volume micro-based product.  But they�
aren't widely known and so are rarely applied to general-purpose�
microcomputers. 

   Suppose your micro doesn't provide the luxury of unlimited (or even�
adequate) resources.  Your program absolutely has to fit in a certain space,�
such as a ROM.  You're stuck with a slow CPU but must handle a hardware�
device with particularly severe timing requirements.  Your C compiler just�
turned out a program that misses the mark by a megabyte.  Don't give up!�
I'll show you some techniques that are particularly effective at "running�
light without overbyte," as Dr. Dobbs used to say.
�   I'll demonstrate these techniques with the Z80.  With over 30 million�
sold last year alone, it remains the number-one-selling micro and is widely�
used in cost-effective designs when performance counts.  However, the�
principles used apply to almost any microcomputer.

In the beginning

   Novice Z80 programmers soon spot peculiarities in the instruction set;�
arcane rules restrict data movement between registers.  For instance, the�
stack pointer can be loaded but not examined.  Flags are not set�
automatically and must be explicitly updated by a math or logical�
instruction.  The carry flag can be set or inverted but not reset.  Of the�
six flags, only four can be tested by jumps and calls (and only two by�
relative jumps). 

   These limitations are no accident.  They represent an artful compromise�
between cost, complexity, performance, and compatibility with the earlier�
8080 instruction set.  To get the most out of any micro, you must discover�
how its designer expected you to use the architecture.  Get "inside" his�
head; become part of the machine.
 
   The Z80 is register-oriented; it manipulates data in registers�
efficiently but deals rather clumsily with memory.  Registers are�
specialized, with each having an intended purpose.  Here are some rules I've�
found useful:

    A = Accumulator: first choice for 8-bit data; best selection of �
load/store instructions; source and destination for most math, logical, and�
comparisons.

    HL = High/Low address: first choice for 16-bit data/addresses; source�
and destination for 16-bit math; second choice for 8-bit data; pointer when�
one math/logical/compare operand is in memory; source address for block�
operations.

    DE = DEstination: second choice for 16-bit data/addresses; third choice�
for 8-bit data; destination address for block operations.

    BC = Byte Counter: third choice for 16-bit data/addresses; I/O port�
addreses; 8/16 bit counter for loops and block operations.  

    F = Flag byte (6 bits used): updated by math/logical/compare �
instructions; Zero, Carry, Sign, and Parity tested by conditional jumps,�
calls, or returns; Zero and Carry by relative jumps; block operations use�
Parity; bit tests use Zero; shifts use Carry; only decimal adjust tests�
Half-carry and Add/Subtract flags.

    A',BC',DE',F',HL' = twins of A, BC, DE, F, HL; can be quickly swapped�
with main set; use for frequently used variables, fast interrupt handlers,�
task switching.

    R = Refresh counter for dynamic RAM: also counts instructions for��diagnostics, debuggers, copy-protection schemes; pseudorandom number�
generator; interrupt detection.

    I = Interrupt vector: page address for interrupts in mode 2; otherwise,�
an extra 8-bit register that updates flags when read.

    IX,IY = Index registers X and Y: Two 16-bit registers, used like HL as�
an indirect memory pointer, except instructions can include a relative�
offset.

    SP = Stack Pointer: 16-bit memory pointer for LIFO (last-in first-out)�
stack to hold interrupt and subroutine return address, pushed/popped�
register data; stack-oriented data structures.

   Naturally, some instructions get used a lot more than others.  But �
frequency-of-use studies reveal that many programs NEVER use large portions�
of the instruction set.  Sometimes there are good reasons, like sticking to�
8080 opcodes so your code runs on an 8080/8085/V20 etc.  More often the�
programmer is simply unfamiliar with the entire instruction set, and so�
restricts himself to what he knows.

   This is fine for noncritical uses but suicidal when performance counts.�
It's like running a racehorse with a gag in its throat.  Take some time to�
go over the entire instruction set, one by one.  Devise an example for each�
instruction that puts it to good use.  I only know of nine turkeys with no�
use besides "trick" NOPs (can you find them?).

   Here's a routine that might be written by a rather inept programmer (or�
an unusually efficient compiler).  It outputs a string of characters ending�
in 0 to the console.  It generally follows good programming practices; it's�
well structured, has clearly-defined entry and exit points, and carefully�
saves and restores all registers used.

        ...
	ld	de,string	; point to message
	call	outstr		; output it
	...

outstr:	push	af		; save registers
	push	bc
	push	de
	push	hl
	ld	a,(de)		; get next character
	cp	0		; compare it to 0
	jp	z,outend	; if not last char,
	push	de		; ..save registers
	ld	e,a
	ld	c,conout	; output character to console
	call	bdos
	pop	de		; restore registers
	inc	de		; advance to next
	jp	outstr		; repeat until done�outend:	pop	hl		; else 0 is last char
	pop	de
	pop	bc		; restore registers
	pop	af
	ret			; return
 
string:	db	'message'	; display our message
	db	0		; end of string marker

   Now let's see how it can be improved.  First, note that over half the�
instructions are PUSHes or POPs.  This is the consequence of saving every�
register before use, a common compiler strategy.  Though safe and simple,�
it's the single worst performance-killer I know.

   The alternative is to push/pop only as necessary.  This is easier said�
than done; miss one, and you've got a nasty bug to find.  A good strategy�
helps.  I initially define my routines to minimize the registers used; only�
push/pop as needed within the routine itself; and restore nothing on exit. �
In OUTSTR, this eliminates all but the PUSH DE/POP DE around the CALL BDOS.

   This shifts the save/restore burden to the calling routine.  Since the�
caller also follows the rule of minimal register usage and push/pops only as�
necessary, it will probably not push/pop as many registers; thus we have�
increased speed by eliminating redundant push/pops.  We have also made it�
explicitly clear which registers a caller really needs preserved.

   Now I move the remaining push/pops to the called routines to save memory. �
If every caller saves a particular register, it obviously should be�
saved/restored by the subroutine itself.  If two or more callers save it,�
speed is the deciding factor; preserve that register in the subroutine if�
the extra overhead is not a problem for callers that don't need that�
register preserved.

   Push/pops are sloooww; at 21 to 29 T-states per pair, they make wonderful�
low-byte time killers.  If possible, either use, or save to, a register that�
isn't killed by the called routine.  In our example, try IX or IY instead of�
DE; the index registers aren't trashed by the BDOS call (except, see Jay�
Sage's column.  Ed).  This saves 5 T-states/loop but adds 2 bytes (see�
why?).  The instruction EX DE,HL (8 T-states per pair) is often useful, but�
not here; the BIOS eats both HL and DE.  The ultimate speed demon is a fast-n-drastic pair of EXX instructions to replace the PUSH DE/POP DE.  They save�
13 T-states with no size increase, and even preserve BC so we don't have to�
reload it for every loop.

Comparisons

   A CP 0 instruction was used to test for 0, an obvious choice.  But it�
takes 2 bytes and 7 T-states to execute.  The Z80's Zero flag makes the�
special case of testing for zero easy; all we have to do is update the flags�
to match the byte loaded.  This is most easily done with an OR A�
instruction, which takes only 1 byte and 4 T-states.  You'll find this trick�
often in Z80 code.
�   Note that OR A has no effect on A; we just used it to update the flags�
because it's smaller and faster than CP 0.  This illustrates a basic�
principle of assembly languages; the side effects of an instruction are�
often more important than the main effect.  Here are some other not-so-obvious instructions:

     and  a     ; update flags and clear Carry
     xor  a     ; set A=0, update flags, P/V flag=1
     sub  a     ; same, but P/V flag=0
     sbc  a,a   ; set all bits in A to Carry (00 or FF)
     add  a,a   ; A*2, or shift A left & set lsb=0
     add  hl,hl ; HL*2, or shift HL left & set lsb=0
     adc  hl,hl ; shift HL left & lsb=Carry
     sbc  hl,hl ; set all bits in HL to Carry (0000 or FFFF)
     ld   hl,0  ; \_load SP into HL so it can be examined
     add  hl,sp ; /

   Using DE as the string pointer is a weak choice.  It forces us to load�
the character into A, then move it to E.  If we use HL, IX, or IY instead,�
we can load E directly and save a byte.  But this makes it harder to test�
for 0.

   An INC E, DEC E updates the Z flag without changing E.  Or mark the end�
of the string with 80h, and use BIT 7,E to test for end.  Both are as�
efficient as the OR A trick but don't need A.  If you are REALLY desperate,�
add 1 to every byte in the string, so a single DEC E restores the character�
and sets the Z flag; kinky, but short and fast. 

Jumps

   This example used 3-byte absolute jump instructions.  We can save memory�
by using the Z80's 2-byte relative jumps instead; each use saves a byte. �
Since jumps are among the most common instructions, this adds up fast.

   Relative jumps have a limited range, so it pays to arrange your code�
carefully to maximize their use.  I've found that about half the jumps in a�
well structured program can be relative.  When most of the jumps are out of�
range, it's often a sign of structural weaknesses, "spaghetti-code" or�
excessively complex subroutines. 

   How about execution speed?  An absolute jump always takes 10 T-states; a�
relative jump takes 12 to jump, or 7 to continue.  So if speed counts, use�
absolute jumps when the branch is normally taken, and relative jumps when it�
is not.  In the example, this means changing the JP Z,OUTEND to JR Z,OUTEND�
but keeping the JP at the end. 

   But wait a minute!  The JR Z,OUTEND merely jumps to the RET at the end of�
the subroutine.  It would be more efficient still to replace it with RET Z,�
a 1-byte conditional return that is only 5 T-states if the return is not�
taken.  This illustrates another difference between assembler and high-level�
languages; entry and exit points are often not at the beginning and end of a�
routine.
�   We can speed up unconditional jumps within a loop.  On entry, load HL�
with the start address of the loop, and replace JP LABEL by JP (HL).  It�
takes 1 byte and 4 T-states, saving 6 T-states per loop.  This scheme costs�
us a byte (+3 to set HL; -2 for JP (HL)).  But if used more than once in the�
routine, we save 2 bytes per occurrence.  If HL is unavailable (as is the�
case here; the BDOS trashes it), IX or IY can be used instead.  However, the�
JP (IX) and JP (IY) instructions take 2 bytes and 8 T-states, making the �
savings marginal.

   Can we do better yet?  Yes, if we carefully rethink the structure of our�
program.  Notice it has two jump instructions per loop; yet only one test is�
performed (test for 0).  This is a hint that one conditional jump should be�
all we need.  Think of the instructions in the loop as links in a chain.�
Rotate the chain to put the test-for-0 link at the bottom, and LD C,CONOUT�
on top (which we'll label OUTNXT).  The JP OUTSTR is now unnecessary, and�
can be removed.  JP NZ,OUTNXT performs the test and loops until 0 (remember,�
absolute for speed, relative for size).  The entry point is still OUTSTR,�
though (horrors!) it's now in the middle of the routine.

   We've also made a subtle change in the logic.  Presumably we wouldn't�
call OUTSTR unless there was at least one character to output.  But what�
would happen if we did?

   Another way is to use DJNZ to close the loop.  Make the first byte of the�
string its length (1-256).  Load this value into B as part of the�
initialization.  The resulting program takes 34 T-states per loop (not�
counting the CALL). 

   STILL faster?  OK, you twisted my arm.  If you're absolutely sure the�
string won't cross a page boundary, you can use INC L instead of INC HL to�
save 2 T-states.  The 8-bit INC/DEC instructions are faster than their�
16-bit counterparts, but should only be used if you're positive the address�
will never require a carry.  This brings us to 32 T-states/loop, which is�
the best I can do within this routine itself.  Or can you do better?

        ...
        ld     hl,string           ; point to message
        call   outstr              ; output it
        ...

outstr: ld     b,(hl)              ; get length of message
        ld     c,conout            ; output to console
        ld     e,(hl)              ; get 1st char
outnxt: exx                        ; save registers,
        call   bdos                ;   output char,
        exx                        ;   and restore
        inc    hl                  ; advance to next
        ld     e,(hl)              ; get next character
        djnz   z,outnxt            ; loop until end
        ret
 
string: db     strend - strbeg     ; message length�strbeg:	db     'message'           ; message itself
strend:

Parameter Passing

   In the above example, parameters were passed to the subroutine via�
registers (string address in HL).  This is fast and easy, but each call to�
OUTSTR takes 6 bytes.  Now let's look at methods that save memory at the�
expense of speed.

   Parameters can be passed to a subroutine as "data" bytes immediately�
following the CALL.  Let's define the two bytes after CALL OUTSTR as the�
address of the string.  The following code then picks up this pointer,�
saving us a byte per call.  The penalty is in making OUTSTR 4 bytes longer�
and 38 T-states/loop slower; thus it doesn't pay until we use it 5 or more�
times.

        ...
        call   outstr              ; output message
        dw     string              ; beginning here
        ...

outstr: pop    hl                  ; get pointer to "DW STRING"
        ld     e,(hl)              ;   E=low byte of string addr
        inc    hl
        ld     d,(hl)              ;   D=high byte of string addr            
        inc    hl                  ; skip over "DW STRING" & push
        push   hl                  ;   corrected return address

outnxt: ld     a,(de)              ; get next character
        or     a                   ; if 0,
        ret    z                   ;   all done, return
        push   de
        ld     e,a
        ld     c,conout            ; output character to console
        call   bdos        
        pop    de
        inc    de                  ; advance to next
        jr     outnxt

   We also had to rethink our choice of registers.  If we tried to use HL or�
IX as the string pointer, OUTSTR would have been larger and slower (try it�
yourself).  This demonstrates the consequences of inappropriate register�
choices.

   The more parameters that must be passed, the more efficient this�
technique becomes.  A further refinement is to put the string itself�
immediately after CALL.  This saves an additional two bytes per call, and�
shortens OUTSTR by 6 bytes.   

        ...
        call   outstr              ; output message�        db     'message',0         ; which immediately follows
        ...

outstr: pop    de                  ; get pointer to message
        ld     a,(de)              ; get next character
        inc    de                  ; advance to next
        push   de                  ; & save as return address
        or     a                   ; if char=0, all done
        ret    z                   ;   pointer is return addr
        ld     e,a
        ld     c,conout            ; else output char to console
        call   bdos        
        jr     outstr              ;   & repeat
 
Constants and Variables

   Constants and variables are part of every program.  Constants are usually�
embedded within the program itself, as "immediate" bytes.  Variables on the�
other hand are usually separated, grouped into a common region perhaps at�
the end of the program.  This makes sense for programs in ROM, where the�
variables obviously must be stored elsewhere.  But it is not a requirement�
for programs in RAM.

   If your program executes from RAM, performance can be improved by�
treating variables as in-line constants; storage for the variable is in the�
last byte (or two) of an immediate instruction.  For example, here is a�
routine that creates a new stack, toggles a variable FLAG between two�
states, and then restores the original stack:

toggle: ld     (stack),sp          ; save old stack pointer 
        ld     sp,mystack          ; setup my stack
        ld     a,(flag)            ; get Yes/No flag
        cp     'Y'                 ; if "Y",     
        ld     a,'N'               ;    set it to "N"
        jr     z,setno             ; else "N",
        ld     a,'Y'               ;    set it to "Y"
setno:  ld     (flag),a            ; save new state
        ld     sp,(stack)          ; restore stack pointer
        ret

stack:  dw     0                   ; old stack pointer
flag:   db     'Y'                 ; value of flag

   The LD A,(FLAG) instruction takes 13 T-states and 4 bytes of RAM (3 for�
the instruction, 1 to store FLAG).  It can be replaced by LD A,'Y' where 'Y'�
is the initial value of the variable FLAG, the 2nd byte of the instruction.�
Speed and memory are improved 2:1, to 7 T-states and 2 bytes respectively.

   It works for 16-bit variables as well.  Replace LD SP,(STACK) with LD�
SP,0 where 0 is a placeholder for the 2-byte variable STACK.  This saves 3�
bytes and 10 T-states.
�toggle: ld     (stack+1),sp        ; save old stack pointer 
        ld     sp,mystack          ; setup my stack
flag:   ld     a,'Y'               ; get Y/N flag (byte 2=var)
        cp     'Y'                 ; if "Y",     
        ld     a,'N'               ;    set it to "N"
        jr     z,setno             ; else "N",
        ld     a,'Y'               ;    set it to "Y"
setno:  ld     (flag+1),a          ; save new state
stack:  ld     sp,0                ; restore stack (byte 2,3=var)
        ret

   There is another advantage to this technique -- versatility.  Any�
immediate-mode instruction can have variable data; loads, math, compares,�
logical, even jumps and calls.  Try changing our first example so a variable�
OUTDEV selects the output device; console or printer.  Now see how simple it�
is if OUTDEV is the 2nd byte of the LD C,CONOUT instruction.

   It even creates new instructions.  For instance, the Z80's indexed �
instructions don't allow a variable offset.  This makes it awkward to load�
the "n"th byte of a table, where we would like LD A,(IX+b) where "b" is a�
variable.  But it can be done if the variable offset is stored in the last�
byte of the indexed instruction itself. 

   Storing variables in the address field of a jump or call instruction can�
do some weird and wonderful things.  There is no faster way to perform a�
conditional branch based on a variable.  But remember you are treading on�
the thin ice of self-modifying code; debugging and relocation become much�
more difficult, and you must insure that the variable NEVER has an�
unexpected value.  Also, in microprocessors with instruction caches (fast�
memory containing copies of the contents of regular memory), there can be�
problems if the cache data are not updated.

   I put a LABEL at each instruction with an immediate variable, then use�
LABEL+1 for all references to it.  This serves as a reminder that something�
odd is going on.  Be sure to document what you're doing, or you'll drive�
some poor soul (probably yourself) batty.


Exclusive OR

   The XOR operator is a powerful tool for manipulating data.  Since�
anything XOR'd with itself is 0, use XOR A instead of LD A,0.  To toggle a�
variable between two values, XOR it with the difference between the two�
values.  Our last example can be performed much more efficiently by:

toggle: ld     (stack+1),sp        ; save old stack pointer 
        ld     sp,mystack          ; setup my stack
flag:   ld     a,'Y'               ; get Y/N flag (byte 2=var)
        xor    'Y'-'N'             ; toggle "Y" <-> "N"
        ld     (flag+1),a          ; save new state
stack:  ld     sp,0                ; restore stack (byte 2,3=var)
        ret�
   XOR eliminated the jump, for a 2:1 improvement in size and speed.  This�
illustrates a generally useful rule.  Almost any permutation can be�
performed faster, without jumps, by XOR and the other math and logical�
operators.  Consider the following routine to convert the ASCII character in�
A to uppercase: it's both shorter and faster than the traditional method�
using jumps.

convert: ld    b,a            ; save a copy of the char in B
         sub   'a'            ; if char is lowercase (a thru z),
         cp    'z'-'a'+1      ;   then carry=1, else carry=0
         sbc   a,a            ;   fill A with carry
         and   'a'-'A'        ;   difference between upper/lower
         xor   b              ;   convert to uppercase

Data Compaction

   Programs frequently include large blocks of text, data tables, and other�
non-program data.  Careful organization of such information can produce�
large savings in memory and speed of execution.

   ASCII is a 7-bit code.  The 8th bit of each byte is either unused or just�
marks the end of a string.  You can bit-pack 8 characters into 7 bytes with�
a suitable routine.  If upper case alone is sufficient, 6 bits are enough.�
For dedicated applications, don't overlook older but more memory-efficient�
codes like Baudot (5 bits), EBCD (4 bits), or even International Morse (2-10�
bits, with frequent characters the shortest).

   If your text is destined for a CRT or printer, it may be heavy on control�
characters and ESC sequences.  I've found the following algorithm useful.�
Bytes whose msb=0 are normal ASCII characters: output as-is.  Printable�
characters whose msb=1 are preceeded by ESC, so "A"+80h=C1h sends "ESC A".�
Control codes whose msb=1 are a "repeat" prefix to output the next byte�
between 2 and 32 times.  For example, linefeed+80h=8Ah repeats the next�
character 11 times.  The value 80h, which otherwise would be "repeat once",�
is reserved as the marker for the end of the string. 

   Programs can be compacted, too.  One technique is to write your program�
in an intermediate language (IL) better suited to the task at hand.  It�
might be a high-level language, the instruction set of another CPU, or a�
unique creation specifically for the job at hand.  The rest of your program�
is then an interpreter to execute this language.  Tom Pittman's Tiny BASIC�
is an excellent example of this technique.  His intermediate language�
implemented BASIC in just 384 bytes; the IL interpreter in turn took about�
2K.

Another approach is threaded code, made popular by the FORTH language.  A�
tight, well-structured program will probably use lots of CALLs.  At the�
highest levels, the code may in fact be nothing but long sequences of CALLs:

main:   call  getname
        call  openfile�        call  readfile
        call  expandtabs
        call  writefile
        call  closefile
        ret
     
   Every 3rd byte is a CALL; large programs will have 1000s of them.  So�
let's eliminate the CALL opcodes, making our program just a list of�
addresses:

main:   ld    (stack),sp ; save stack pointer
        ld    sp,first   ; point it to first address in the list
        ret              ; and go execute it
first:  dw    openfile
        dw    readfile
        dw    expandtabs
        dw    writefile
        dw    closefile
        dw    return     ; end of list

return: ld    sp,(stack) ; restore stack pointer
        ret              ; and return (to MAIN's caller)

The stack pointer is pointed to the address of the first subroutine in the�
list to execute.  RET then loads this address into the program counter and�
advances the stack pointer to the next address.  Since each subroutine also�
ends with a RET, it automatically jumps directly to the next routine in the�
list to be executed.  This is called directly threaded code. 

   RETURN is always the last subroutine in a list.  It restores the stack�
pointer and returns to the caller of MAIN. 

   Directly threaded code can cut program size up to 30%, while actually�
increasing execution speed.  However, it has some rather drastic�
limitations.  During execution of the machine-code subroutines in the�
address list, the Z80's one and only stack pointer is tied up as an address�
pointer.  That means the stack can't be used; no interrupts, calls, pushes,�
or pops are allowed without first switching to a local stack.
 
   The solution to this is called indirectly threaded code, made famous (or�
infamous) by the FORTH language.  Rather than have each subroutine directly�
chain into the next, they are linked by a tiny interpreter, called NEXT:

main:   call  next
        dw    openfile
        dw    readfile
        dw    expandtabs
        dw    writefile
        dw    closefile
        dw    return     ; end of list

next:   pop   ix         ; make IX our next-subroutine pointer�next1:  ld    hl,next1   ; push address so RET comes back here
        push  hl
        ld    l,(ix+0)   ; get address to "call"
        inc   ix         ;    low byte
        ld    h,(ix+0)   ;    high byte
        inc   ix         ; point IX to addr for next time
        jp    (hl)       ; call address

return: pop   hl         ; end of list; discard NEXT addr
        ret              ; and return to MAIN's caller

   Now IX is our pointer into the address list; it points to the next�
subroutine to be executed.  Subroutines can use the stack normally within,�
but must preserve IX and can't pass parameters in HL.  When they exit via�
RET, it returns them to NEXT1.

   Though the example executes the address list as straight-line code,�
subroutines can be written to perform jumps and calls via IX as well.  NEXT�
can provide special handling for commonly-used routines as well; words with�
the high byte=0 could jump IX by a relative offset if A=0.  If there are�
less than 256 subroutines, each address can be replaced by a single byte,�
which NEXT converts into an address via a lookup table. 

   Indirectly threaded code can reduce size up to 2:1 in return for a�
similar loss in execution speed.  The decrease in program size is often�
remarkable. I learned this in 1975 designing a sound-level dosimeter.  This�
cigarette-pack sized gadget rode around in a shirt pocket all day, logging�
the noise a person was exposed to.  It then did various statistical�
computations to report the high, low, mean, and RMS noise levels versus�
time.

   In those dark ages, a BIG memory chip was 256x4.  Cost, power, and size�
forced us into an RCA 1802 CMOS microprocessor, with just 512 bytes of�
program memory (bytes, not K!).  Try as we might, we couldn't do it.  In�
desperation, we tried Charlie Moore's FORTH.  Incredibly, it bettered even�
our heavily optimized code by 30%! 

   Of course, very little of FORTH itself wound up in the final product; it�
just showed us the way.  Once you know HOW it's done, you can apply the same�
techniques to any assembly-language program without becoming a born-again�
FORTH zealot.


Shortcuts

   Here are some "quickies" that didn't fit in elsewhere.  Keep in mind what�
is actually in all the registers as you program.  Do you really need to�
clear carry, or is it already cleared as the result of a previous operation? �
Before you load a register, are you sure it's necessary?  Perhaps it's�
already there, or sitting in another register.

   Many routines return "leftovers" that can be very useful, such as HL, DE,��and BC=0 after a block move.  Perhaps an INC or DEC will produce the value�
you want.  Variables can be grouped so you needn't reload the entire address�
for each.  If the high byte of a register is correct, just load the lower�
half.

   Keep an index register pointed to your frequently-used variables.  This�
makes them easier to access (up to 256 bytes) and opens the door to memory-�
(rather than register-) oriented manipulations.  The indexed instructions�
are slower and less memory-efficient, but the versatility sometimes makes up�
for it (store an immediate byte to memory, load/save to memory from�
registers other than A, etc.).

   The Z80's bit test/set/reset instructions add considerable versatility if�
you define your flags as bits rather than bytes.  Bit flags can be accessed�
in any register, or even directly in memory, without loading them into a�
register.

   If the last two instructions of a subroutine are CALL FOO and RET, you�
could just as well end with JP FOO and let FOO do the return for you.  If�
the entry point of FOO is at the top, even the JP is unnecessary; you can�
locate FOO immediately after and "fall in" to it.

   If you have a large number of jumps to a particular label (like the start�
of your MAIN program), it may be more efficient to push the address of MAIN�
onto the stack at the top of the routine.  Each JP MAIN can then be replaced�
by a 1-byte RET.
 
   SKIP instructions are a short, fast way to jump a fixed distance.  The�
Z80 has no skips, but you can simulate a 1- or 2-byte skip with a 2- or�
3-byte do-nothing instruction: JR or JP on a condition that is never true,�
for instance.  If the flags aren't in a known state, load to an unused�
register.  For example:

clear1:   ld   a,1       ; clear 1 byte
          db   21h       ;   skip next two bytes (21h = ld hl,nn)
clear80:  ld   a,80      ; clear 80 bytes (and "nn" for ld hl,nn)
          db   26h       ;   skip next byte (26h = ld h,n)
clear256: xor  a         ; clear 256 bytes (and "n" for ld h,n)

clear:    ld   b,a       ; clear #bytes in A to zero
          ld   hl,buffer ;   beginning at buffer
loop:     ld   (hl),0
          inc  hl
          djnz loop
          ret

   The stack pointer is the Z80's only auto-increment/decrement register. �
This makes it uniquely suitable for fast block operations.  For instance,�
the fastest way to clear a block of RAM is to make it the stack and push the�
desired data.  At 11 T-states per 2 bytes, it is 3 times faster than two LDD �
instructions.  Remember to disable interrupts or to allow for them; if an�
interrupt routine pushes onto the stack while you are using it for this��special purpose, the results may not be what you intended.  

   That is all for this time.  Next time we will continue the discussion�
with a look at the interplay between software and hardware.

[This article was originally published in issue 39 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]
