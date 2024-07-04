[Note by Jay Sage:  I am always actively recruiting new columnists for TCJ. ç
Rick Charnes, whose excellent articles are now appearing in every issue, wasç
my first success.  With this issue I would like to introduce the second, Leeç
Hart.  Lee has been carrying forward the development of Poor Personç
Software's Write-Hand-Man, the 8-bit "SideKick".  That kind of program, likeç
BGii, cannot tolerate wasteful coding, and in this, the first of twoç
articles, Lee shares with us some of his tricks.]


                         PROGRAMMING FOR PERFORMANCE
                                by Lee A. Hart
                        The Computer Journal, Issue 39
                          Reproduced with permission
                           of author and publisher




   Over the years, the ancient masters of the software arts have ç
meticulously crafted the tools of structured programming.  They haveç
eloquently preached the virtues to body and soul that come from writingç
clean, healthy code, free from the evils of self-modifying code or theç
dreaded GOTO.

   Many programmers have seen the light.  They write exclusively inç
structured high-level languages, and avoid BASIC as if it carried AIDS. ç
Assembly language is just that unreadable stuff the compiler generates as anç
intermediate step before linking.  Memory and processor speed are viewed asç
infinite resources.  Who cares if it takes 100K for a pop-up calculatorç
program?  And if it's not fast enough, use turbo mode, or a 386.

   But a REAL pocket calculator doesn't have a 16-bit processor, or 100K ofç
RAM; it typically runs a primitive 4-bit CPU at 1 MHz or less, with perhapsç
2K of memory.  Yet it can out-perform a PC clone having 10 times the speedç
and memory!

   How can this be?  Special hardware?  Tricky instruction sets?  On theç
contrary; CPU registers and instructions have instead been removed to cutç
cost.  No; the surprising performance comes from clever, efficientç
programming with an extreme attention to detail.  Such techniques areç
essential to the success of every high-volume micro-based product.  But theyç
aren't widely known and so are rarely applied to general-purposeç
microcomputers. 

   Suppose your micro doesn't provide the luxury of unlimited (or evenç
adequate) resources.  Your program absolutely has to fit in a certain space,ç
such as a ROM.  You're stuck with a slow CPU but must handle a hardwareç
device with particularly severe timing requirements.  Your C compiler justç
turned out a program that misses the mark by a megabyte.  Don't give up!ç
I'll show you some techniques that are particularly effective at "runningç
light without overbyte," as Dr. Dobbs used to say.
ä   I'll demonstrate these techniques with the Z80.  With over 30 millionç
sold last year alone, it remains the number-one-selling micro and is widelyç
used in cost-effective designs when performance counts.  However, theç
principles used apply to almost any microcomputer.

In the beginning

   Novice Z80 programmers soon spot peculiarities in the instruction set;ç
arcane rules restrict data movement between registers.  For instance, theç
stack pointer can be loaded but not examined.  Flags are not setç
automatically and must be explicitly updated by a math or logicalç
instruction.  The carry flag can be set or inverted but not reset.  Of theç
six flags, only four can be tested by jumps and calls (and only two byç
relative jumps). 

   These limitations are no accident.  They represent an artful compromiseç
between cost, complexity, performance, and compatibility with the earlierç
8080 instruction set.  To get the most out of any micro, you must discoverç
how its designer expected you to use the architecture.  Get "inside" hisç
head; become part of the machine.
 
   The Z80 is register-oriented; it manipulates data in registersç
efficiently but deals rather clumsily with memory.  Registers areç
specialized, with each having an intended purpose.  Here are some rules I'veç
found useful:

    A = Accumulator: first choice for 8-bit data; best selection of ç
load/store instructions; source and destination for most math, logical, andç
comparisons.

    HL = High/Low address: first choice for 16-bit data/addresses; sourceç
and destination for 16-bit math; second choice for 8-bit data; pointer whenç
one math/logical/compare operand is in memory; source address for blockç
operations.

    DE = DEstination: second choice for 16-bit data/addresses; third choiceç
for 8-bit data; destination address for block operations.

    BC = Byte Counter: third choice for 16-bit data/addresses; I/O portç
addreses; 8/16 bit counter for loops and block operations.  

    F = Flag byte (6 bits used): updated by math/logical/compare ç
instructions; Zero, Carry, Sign, and Parity tested by conditional jumps,ç
calls, or returns; Zero and Carry by relative jumps; block operations useç
Parity; bit tests use Zero; shifts use Carry; only decimal adjust testsç
Half-carry and Add/Subtract flags.

    A',BC',DE',F',HL' = twins of A, BC, DE, F, HL; can be quickly swappedç
with main set; use for frequently used variables, fast interrupt handlers,ç
task switching.

    R = Refresh counter for dynamic RAM: also counts instructions forçädiagnostics, debuggers, copy-protection schemes; pseudorandom numberç
generator; interrupt detection.

    I = Interrupt vector: page address for interrupts in mode 2; otherwise,ç
an extra 8-bit register that updates flags when read.

    IX,IY = Index registers X and Y: Two 16-bit registers, used like HL asç
an indirect memory pointer, except instructions can include a relativeç
offset.

    SP = Stack Pointer: 16-bit memory pointer for LIFO (last-in first-out)ç
stack to hold interrupt and subroutine return address, pushed/poppedç
register data; stack-oriented data structures.

   Naturally, some instructions get used a lot more than others.  But ç
frequency-of-use studies reveal that many programs NEVER use large portionsç
of the instruction set.  Sometimes there are good reasons, like sticking toç
8080 opcodes so your code runs on an 8080/8085/V20 etc.  More often theç
programmer is simply unfamiliar with the entire instruction set, and soç
restricts himself to what he knows.

   This is fine for noncritical uses but suicidal when performance counts.ç
It's like running a racehorse with a gag in its throat.  Take some time toç
go over the entire instruction set, one by one.  Devise an example for eachç
instruction that puts it to good use.  I only know of nine turkeys with noç
use besides "trick" NOPs (can you find them?).

   Here's a routine that might be written by a rather inept programmer (orç
an unusually efficient compiler).  It outputs a string of characters endingç
in 0 to the console.  It generally follows good programming practices; it'sç
well structured, has clearly-defined entry and exit points, and carefullyç
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
	jp	outstr		; repeat until doneäoutend:	pop	hl		; else 0 is last char
	pop	de
	pop	bc		; restore registers
	pop	af
	ret			; return
 
string:	db	'message'	; display our message
	db	0		; end of string marker

   Now let's see how it can be improved.  First, note that over half theç
instructions are PUSHes or POPs.  This is the consequence of saving everyç
register before use, a common compiler strategy.  Though safe and simple,ç
it's the single worst performance-killer I know.

   The alternative is to push/pop only as necessary.  This is easier saidç
than done; miss one, and you've got a nasty bug to find.  A good strategyç
helps.  I initially define my routines to minimize the registers used; onlyç
push/pop as needed within the routine itself; and restore nothing on exit. ç
In OUTSTR, this eliminates all but the PUSH DE/POP DE around the CALL BDOS.

   This shifts the save/restore burden to the calling routine.  Since theç
caller also follows the rule of minimal register usage and push/pops only asç
necessary, it will probably not push/pop as many registers; thus we haveç
increased speed by eliminating redundant push/pops.  We have also made itç
explicitly clear which registers a caller really needs preserved.

   Now I move the remaining push/pops to the called routines to save memory. ç
If every caller saves a particular register, it obviously should beç
saved/restored by the subroutine itself.  If two or more callers save it,ç
speed is the deciding factor; preserve that register in the subroutine ifç
the extra overhead is not a problem for callers that don't need thatç
register preserved.

   Push/pops are sloooww; at 21 to 29 T-states per pair, they make wonderfulç
low-byte time killers.  If possible, either use, or save to, a register thatç
isn't killed by the called routine.  In our example, try IX or IY instead ofç
DE; the index registers aren't trashed by the BDOS call (except, see Jayç
Sage's column.  Ed).  This saves 5 T-states/loop but adds 2 bytes (seeç
why?).  The instruction EX DE,HL (8 T-states per pair) is often useful, butç
not here; the BIOS eats both HL and DE.  The ultimate speed demon is a fast-n-drastic pair of EXX instructions to replace the PUSH DE/POP DE.  They saveç
13 T-states with no size increase, and even preserve BC so we don't have toç
reload it for every loop.

Comparisons

   A CP 0 instruction was used to test for 0, an obvious choice.  But itç
takes 2 bytes and 7 T-states to execute.  The Z80's Zero flag makes theç
special case of testing for zero easy; all we have to do is update the flagsç
to match the byte loaded.  This is most easily done with an OR Aç
instruction, which takes only 1 byte and 4 T-states.  You'll find this trickç
often in Z80 code.
ä   Note that OR A has no effect on A; we just used it to update the flagsç
because it's smaller and faster than CP 0.  This illustrates a basicç
principle of assembly languages; the side effects of an instruction areç
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

   Using DE as the string pointer is a weak choice.  It forces us to loadç
the character into A, then move it to E.  If we use HL, IX, or IY instead,ç
we can load E directly and save a byte.  But this makes it harder to testç
for 0.

   An INC E, DEC E updates the Z flag without changing E.  Or mark the endç
of the string with 80h, and use BIT 7,E to test for end.  Both are asç
efficient as the OR A trick but don't need A.  If you are REALLY desperate,ç
add 1 to every byte in the string, so a single DEC E restores the characterç
and sets the Z flag; kinky, but short and fast. 

Jumps

   This example used 3-byte absolute jump instructions.  We can save memoryç
by using the Z80's 2-byte relative jumps instead; each use saves a byte. ç
Since jumps are among the most common instructions, this adds up fast.

   Relative jumps have a limited range, so it pays to arrange your codeç
carefully to maximize their use.  I've found that about half the jumps in aç
well structured program can be relative.  When most of the jumps are out ofç
range, it's often a sign of structural weaknesses, "spaghetti-code" orç
excessively complex subroutines. 

   How about execution speed?  An absolute jump always takes 10 T-states; aç
relative jump takes 12 to jump, or 7 to continue.  So if speed counts, useç
absolute jumps when the branch is normally taken, and relative jumps when itç
is not.  In the example, this means changing the JP Z,OUTEND to JR Z,OUTENDç
but keeping the JP at the end. 

   But wait a minute!  The JR Z,OUTEND merely jumps to the RET at the end ofç
the subroutine.  It would be more efficient still to replace it with RET Z,ç
a 1-byte conditional return that is only 5 T-states if the return is notç
taken.  This illustrates another difference between assembler and high-levelç
languages; entry and exit points are often not at the beginning and end of aç
routine.
ä   We can speed up unconditional jumps within a loop.  On entry, load HLç
with the start address of the loop, and replace JP LABEL by JP (HL).  Itç
takes 1 byte and 4 T-states, saving 6 T-states per loop.  This scheme costsç
us a byte (+3 to set HL; -2 for JP (HL)).  But if used more than once in theç
routine, we save 2 bytes per occurrence.  If HL is unavailable (as is theç
case here; the BDOS trashes it), IX or IY can be used instead.  However, theç
JP (IX) and JP (IY) instructions take 2 bytes and 8 T-states, making the ç
savings marginal.

   Can we do better yet?  Yes, if we carefully rethink the structure of ourç
program.  Notice it has two jump instructions per loop; yet only one test isç
performed (test for 0).  This is a hint that one conditional jump should beç
all we need.  Think of the instructions in the loop as links in a chain.ç
Rotate the chain to put the test-for-0 link at the bottom, and LD C,CONOUTç
on top (which we'll label OUTNXT).  The JP OUTSTR is now unnecessary, andç
can be removed.  JP NZ,OUTNXT performs the test and loops until 0 (remember,ç
absolute for speed, relative for size).  The entry point is still OUTSTR,ç
though (horrors!) it's now in the middle of the routine.

   We've also made a subtle change in the logic.  Presumably we wouldn'tç
call OUTSTR unless there was at least one character to output.  But whatç
would happen if we did?

   Another way is to use DJNZ to close the loop.  Make the first byte of theç
string its length (1-256).  Load this value into B as part of theç
initialization.  The resulting program takes 34 T-states per loop (notç
counting the CALL). 

   STILL faster?  OK, you twisted my arm.  If you're absolutely sure theç
string won't cross a page boundary, you can use INC L instead of INC HL toç
save 2 T-states.  The 8-bit INC/DEC instructions are faster than theirç
16-bit counterparts, but should only be used if you're positive the addressç
will never require a carry.  This brings us to 32 T-states/loop, which isç
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
 
string: db     strend - strbeg     ; message lengthästrbeg:	db     'message'           ; message itself
strend:

Parameter Passing

   In the above example, parameters were passed to the subroutine viaç
registers (string address in HL).  This is fast and easy, but each call toç
OUTSTR takes 6 bytes.  Now let's look at methods that save memory at theç
expense of speed.

   Parameters can be passed to a subroutine as "data" bytes immediatelyç
following the CALL.  Let's define the two bytes after CALL OUTSTR as theç
address of the string.  The following code then picks up this pointer,ç
saving us a byte per call.  The penalty is in making OUTSTR 4 bytes longerç
and 38 T-states/loop slower; thus it doesn't pay until we use it 5 or moreç
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

   We also had to rethink our choice of registers.  If we tried to use HL orç
IX as the string pointer, OUTSTR would have been larger and slower (try itç
yourself).  This demonstrates the consequences of inappropriate registerç
choices.

   The more parameters that must be passed, the more efficient thisç
technique becomes.  A further refinement is to put the string itselfç
immediately after CALL.  This saves an additional two bytes per call, andç
shortens OUTSTR by 6 bytes.   

        ...
        call   outstr              ; output messageä        db     'message',0         ; which immediately follows
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

   Constants and variables are part of every program.  Constants are usuallyç
embedded within the program itself, as "immediate" bytes.  Variables on theç
other hand are usually separated, grouped into a common region perhaps atç
the end of the program.  This makes sense for programs in ROM, where theç
variables obviously must be stored elsewhere.  But it is not a requirementç
for programs in RAM.

   If your program executes from RAM, performance can be improved byç
treating variables as in-line constants; storage for the variable is in theç
last byte (or two) of an immediate instruction.  For example, here is aç
routine that creates a new stack, toggles a variable FLAG between twoç
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

   The LD A,(FLAG) instruction takes 13 T-states and 4 bytes of RAM (3 forç
the instruction, 1 to store FLAG).  It can be replaced by LD A,'Y' where 'Y'ç
is the initial value of the variable FLAG, the 2nd byte of the instruction.ç
Speed and memory are improved 2:1, to 7 T-states and 2 bytes respectively.

   It works for 16-bit variables as well.  Replace LD SP,(STACK) with LDç
SP,0 where 0 is a placeholder for the 2-byte variable STACK.  This saves 3ç
bytes and 10 T-states.
ätoggle: ld     (stack+1),sp        ; save old stack pointer 
        ld     sp,mystack          ; setup my stack
flag:   ld     a,'Y'               ; get Y/N flag (byte 2=var)
        cp     'Y'                 ; if "Y",     
        ld     a,'N'               ;    set it to "N"
        jr     z,setno             ; else "N",
        ld     a,'Y'               ;    set it to "Y"
setno:  ld     (flag+1),a          ; save new state
stack:  ld     sp,0                ; restore stack (byte 2,3=var)
        ret

   There is another advantage to this technique -- versatility.  Anyç
immediate-mode instruction can have variable data; loads, math, compares,ç
logical, even jumps and calls.  Try changing our first example so a variableç
OUTDEV selects the output device; console or printer.  Now see how simple itç
is if OUTDEV is the 2nd byte of the LD C,CONOUT instruction.

   It even creates new instructions.  For instance, the Z80's indexed ç
instructions don't allow a variable offset.  This makes it awkward to loadç
the "n"th byte of a table, where we would like LD A,(IX+b) where "b" is aç
variable.  But it can be done if the variable offset is stored in the lastç
byte of the indexed instruction itself. 

   Storing variables in the address field of a jump or call instruction canç
do some weird and wonderful things.  There is no faster way to perform aç
conditional branch based on a variable.  But remember you are treading onç
the thin ice of self-modifying code; debugging and relocation become muchç
more difficult, and you must insure that the variable NEVER has anç
unexpected value.  Also, in microprocessors with instruction caches (fastç
memory containing copies of the contents of regular memory), there can beç
problems if the cache data are not updated.

   I put a LABEL at each instruction with an immediate variable, then useç
LABEL+1 for all references to it.  This serves as a reminder that somethingç
odd is going on.  Be sure to document what you're doing, or you'll driveç
some poor soul (probably yourself) batty.


Exclusive OR

   The XOR operator is a powerful tool for manipulating data.  Sinceç
anything XOR'd with itself is 0, use XOR A instead of LD A,0.  To toggle aç
variable between two values, XOR it with the difference between the twoç
values.  Our last example can be performed much more efficiently by:

toggle: ld     (stack+1),sp        ; save old stack pointer 
        ld     sp,mystack          ; setup my stack
flag:   ld     a,'Y'               ; get Y/N flag (byte 2=var)
        xor    'Y'-'N'             ; toggle "Y" <-> "N"
        ld     (flag+1),a          ; save new state
stack:  ld     sp,0                ; restore stack (byte 2,3=var)
        retä
   XOR eliminated the jump, for a 2:1 improvement in size and speed.  Thisç
illustrates a generally useful rule.  Almost any permutation can beç
performed faster, without jumps, by XOR and the other math and logicalç
operators.  Consider the following routine to convert the ASCII character inç
A to uppercase: it's both shorter and faster than the traditional methodç
using jumps.

convert: ld    b,a            ; save a copy of the char in B
         sub   'a'            ; if char is lowercase (a thru z),
         cp    'z'-'a'+1      ;   then carry=1, else carry=0
         sbc   a,a            ;   fill A with carry
         and   'a'-'A'        ;   difference between upper/lower
         xor   b              ;   convert to uppercase

Data Compaction

   Programs frequently include large blocks of text, data tables, and otherç
non-program data.  Careful organization of such information can produceç
large savings in memory and speed of execution.

   ASCII is a 7-bit code.  The 8th bit of each byte is either unused or justç
marks the end of a string.  You can bit-pack 8 characters into 7 bytes withç
a suitable routine.  If upper case alone is sufficient, 6 bits are enough.ç
For dedicated applications, don't overlook older but more memory-efficientç
codes like Baudot (5 bits), EBCD (4 bits), or even International Morse (2-10ç
bits, with frequent characters the shortest).

   If your text is destined for a CRT or printer, it may be heavy on controlç
characters and ESC sequences.  I've found the following algorithm useful.ç
Bytes whose msb=0 are normal ASCII characters: output as-is.  Printableç
characters whose msb=1 are preceeded by ESC, so "A"+80h=C1h sends "ESC A".ç
Control codes whose msb=1 are a "repeat" prefix to output the next byteç
between 2 and 32 times.  For example, linefeed+80h=8Ah repeats the nextç
character 11 times.  The value 80h, which otherwise would be "repeat once",ç
is reserved as the marker for the end of the string. 

   Programs can be compacted, too.  One technique is to write your programç
in an intermediate language (IL) better suited to the task at hand.  Itç
might be a high-level language, the instruction set of another CPU, or aç
unique creation specifically for the job at hand.  The rest of your programç
is then an interpreter to execute this language.  Tom Pittman's Tiny BASICç
is an excellent example of this technique.  His intermediate languageç
implemented BASIC in just 384 bytes; the IL interpreter in turn took aboutç
2K.

Another approach is threaded code, made popular by the FORTH language.  Aç
tight, well-structured program will probably use lots of CALLs.  At theç
highest levels, the code may in fact be nothing but long sequences of CALLs:

main:   call  getname
        call  openfileä        call  readfile
        call  expandtabs
        call  writefile
        call  closefile
        ret
     
   Every 3rd byte is a CALL; large programs will have 1000s of them.  Soç
let's eliminate the CALL opcodes, making our program just a list ofç
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

The stack pointer is pointed to the address of the first subroutine in theç
list to execute.  RET then loads this address into the program counter andç
advances the stack pointer to the next address.  Since each subroutine alsoç
ends with a RET, it automatically jumps directly to the next routine in theç
list to be executed.  This is called directly threaded code. 

   RETURN is always the last subroutine in a list.  It restores the stackç
pointer and returns to the caller of MAIN. 

   Directly threaded code can cut program size up to 30%, while actuallyç
increasing execution speed.  However, it has some rather drasticç
limitations.  During execution of the machine-code subroutines in theç
address list, the Z80's one and only stack pointer is tied up as an addressç
pointer.  That means the stack can't be used; no interrupts, calls, pushes,ç
or pops are allowed without first switching to a local stack.
 
   The solution to this is called indirectly threaded code, made famous (orç
infamous) by the FORTH language.  Rather than have each subroutine directlyç
chain into the next, they are linked by a tiny interpreter, called NEXT:

main:   call  next
        dw    openfile
        dw    readfile
        dw    expandtabs
        dw    writefile
        dw    closefile
        dw    return     ; end of list

next:   pop   ix         ; make IX our next-subroutine pointeränext1:  ld    hl,next1   ; push address so RET comes back here
        push  hl
        ld    l,(ix+0)   ; get address to "call"
        inc   ix         ;    low byte
        ld    h,(ix+0)   ;    high byte
        inc   ix         ; point IX to addr for next time
        jp    (hl)       ; call address

return: pop   hl         ; end of list; discard NEXT addr
        ret              ; and return to MAIN's caller

   Now IX is our pointer into the address list; it points to the nextç
subroutine to be executed.  Subroutines can use the stack normally within,ç
but must preserve IX and can't pass parameters in HL.  When they exit viaç
RET, it returns them to NEXT1.

   Though the example executes the address list as straight-line code,ç
subroutines can be written to perform jumps and calls via IX as well.  NEXTç
can provide special handling for commonly-used routines as well; words withç
the high byte=0 could jump IX by a relative offset if A=0.  If there areç
less than 256 subroutines, each address can be replaced by a single byte,ç
which NEXT converts into an address via a lookup table. 

   Indirectly threaded code can reduce size up to 2:1 in return for aç
similar loss in execution speed.  The decrease in program size is oftenç
remarkable. I learned this in 1975 designing a sound-level dosimeter.  Thisç
cigarette-pack sized gadget rode around in a shirt pocket all day, loggingç
the noise a person was exposed to.  It then did various statisticalç
computations to report the high, low, mean, and RMS noise levels versusç
time.

   In those dark ages, a BIG memory chip was 256x4.  Cost, power, and sizeç
forced us into an RCA 1802 CMOS microprocessor, with just 512 bytes ofç
program memory (bytes, not K!).  Try as we might, we couldn't do it.  Inç
desperation, we tried Charlie Moore's FORTH.  Incredibly, it bettered evenç
our heavily optimized code by 30%! 

   Of course, very little of FORTH itself wound up in the final product; itç
just showed us the way.  Once you know HOW it's done, you can apply the sameç
techniques to any assembly-language program without becoming a born-againç
FORTH zealot.


Shortcuts

   Here are some "quickies" that didn't fit in elsewhere.  Keep in mind whatç
is actually in all the registers as you program.  Do you really need toç
clear carry, or is it already cleared as the result of a previous operation? ç
Before you load a register, are you sure it's necessary?  Perhaps it'sç
already there, or sitting in another register.

   Many routines return "leftovers" that can be very useful, such as HL, DE,çäand BC=0 after a block move.  Perhaps an INC or DEC will produce the valueç
you want.  Variables can be grouped so you needn't reload the entire addressç
for each.  If the high byte of a register is correct, just load the lowerç
half.

   Keep an index register pointed to your frequently-used variables.  Thisç
makes them easier to access (up to 256 bytes) and opens the door to memory-ç
(rather than register-) oriented manipulations.  The indexed instructionsç
are slower and less memory-efficient, but the versatility sometimes makes upç
for it (store an immediate byte to memory, load/save to memory fromç
registers other than A, etc.).

   The Z80's bit test/set/reset instructions add considerable versatility ifç
you define your flags as bits rather than bytes.  Bit flags can be accessedç
in any register, or even directly in memory, without loading them into aç
register.

   If the last two instructions of a subroutine are CALL FOO and RET, youç
could just as well end with JP FOO and let FOO do the return for you.  Ifç
the entry point of FOO is at the top, even the JP is unnecessary; you canç
locate FOO immediately after and "fall in" to it.

   If you have a large number of jumps to a particular label (like the startç
of your MAIN program), it may be more efficient to push the address of MAINç
onto the stack at the top of the routine.  Each JP MAIN can then be replacedç
by a 1-byte RET.
 
   SKIP instructions are a short, fast way to jump a fixed distance.  Theç
Z80 has no skips, but you can simulate a 1- or 2-byte skip with a 2- orç
3-byte do-nothing instruction: JR or JP on a condition that is never true,ç
for instance.  If the flags aren't in a known state, load to an unusedç
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

   The stack pointer is the Z80's only auto-increment/decrement register. ç
This makes it uniquely suitable for fast block operations.  For instance,ç
the fastest way to clear a block of RAM is to make it the stack and push theç
desired data.  At 11 T-states per 2 bytes, it is 3 times faster than two LDD ç
instructions.  Remember to disable interrupts or to allow for them; if anç
interrupt routine pushes onto the stack while you are using it for thisçäspecial purpose, the results may not be what you intended.  

   That is all for this time.  Next time we will continue the discussionç
with a look at the interplay between software and hardware.

[This article was originally published in issue 39 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]
