TCJ38BMM  2/28/89

ART: PLEASE print BOTH titles!

			    Advanced CP/M

		    Batch Processing and a New ZEX

			   Bridger Mitchell
[usual sidebar on Bridger]


.h1 More Environmental Programming

Two columns ago I went out on a limb and suggested a number of
guidelines for environmentally-sensitive programming -- how to write
programs that were aware of their host computer's environment, took
care to avoid damaging the system, and allowed you to exploit advanced
features if they were supported.  A number of you have continued the
discussion by mail and on the Z-Nodes.  There are several areas for
further fruitful exploration.  I'll touch on one or two this time,
and I imagine we can look forward to further exchanges.

Lee Hart asks if there are ways to detect other CPU's (in addition to
the HD64180/Z180 and Z280) that support the Z80 instruction set,
including the Ferranti, SGS and NEC chips.  It would be useful for some
programs to know, for example, that they are running on a pc.  If you
can shed some light on this, please do!

.h2 Preserving the Z80 Registers

I (and others) have argued that an environmentally-conscious BIOS will
preserve any non-8080 registers that it uses, and restore their values
before returning from any BIOS call.  Al Hawley and other CP/M
veterans recalled that Zilog's early data sheets for the Z80 suggested
using the alternate registers to switch contexts in servicing an
interrupt.

In an embedded application, using the alternate registers in a service
routine is entirely appropriate and efficient, because the
designer knows exactly what tasks will use which registers.  But it's
another matter altogether to use the registers (without preserving
them) in an operating system, which is intended to run an _arbitrary_
task that may very well itself actively use the same registers.

Unfortunately, several BIOSes were written along the Zilog guidelines,
and some authors used the register-swap instructions to save a few
bytes.  As a result, erratic bugs continue to pop up.  Recently, a few
users have encountered them when installing ZSDOS, which itself
preserves and uses the index registers.

Cam Cotrill has come up with a portable "fix" for part of this
defect.  It takes the form of a special NZ-COM BIOS segment that saves
all of the Z80 registers before every BIOS call and then restores them
just before returning.  Because NZ-COM allows the user to load a
customized BIOS module -- in additon to command-processor,
named-directory, and other segments -- and to adjust its size, it is
possible to provide such a band-aid without knowing anything about the
hardware features of the BIOS itself!  You can find this file in
ZSNZBI12.LBR on one of the major Z-Nodes.

As ingenious as this solution is, it would be better still if it were
unneeded.  And while it handles the BIOS that consumes registers in
normal services, it cannot rectify the BIOS service routine that
consumes a register for handling interrupts.  If you're writing a new
BIOS, or have the source to your existing system, take care to
preserve the index and alternate registers!

.h2 Interrupts

How should the environmentally-conscious programmer deal with
interrupts?  First, a portable program can't use Z80 or 8080/8085
interrupts, because it can't readily determine the availability of
interrupt vectors for its own use, and the possible conflicts that
could exist with other interrupts used by the system.  Therefore,
programming interrupt-service routines falls in the province of
writing hardware-specific BIOS extensions.

The relevant general-purpose guidelines must be limited to
procedures for disabling and enabling interrupts.  It's rarely
necessary to turn off interrupts, and the rule is: keep it short!
Interrupts must be disabled whenever your code leaves the system in a
state in which an arbitrary interrupt-service routine cannot execute
correctly.  Keep the stack pointer and system addresses clearly in
mind.

Why would you ever use SP for anything but a stack, anyway?  Well,
it's sometimes a handy way to load a table of word into registers.
Repeatedly pushing a constant can be the fastest method of
initializing a segment of memory.  And several issues ago I described
a code-relocation algorithm that used a similar trick to fetch,
relocate, and store successive words of code in PRL format.

Interrupts should be disabled (with a DI instruction) just before
changing the stack pointer to use it for data operations, and
re-enabled (EI) as the instruction that immediately follows restoring
the stack pointer to a valid stack.  If you don't turn off interrupts,
and an interrupt occurs, then when the cpu catches the interrupt it
will push the current program counter value onto your "stack",
clobbering part of your data area.

In some applications it's necessary to change the BIOS or page 0
vectors.  It's remotely possible that an interrupt service routine
would use one of these vectors (but only if the BIOS is re-entrant).
So, a fastidious guideline would use a DI before any multi-instruction
code that changes a vector.

This code:

	ld (vector_address),de

is _atomic_ -- it changes everything necessary in a single executable
instruction, one that cannot itself be interrupted.  However, using
several instructions to storing the low and high bytes of the address,
for example:

	ld	hl,vector_address
	di
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ei

is not atomic. While that sequence of instructions is executing, the
state of the system BIOS vector is not well defined.  Without the DI
instruction, if an interrupt occurs, its service routine could get an
invalid address.

I have used the DI/EI instructions without apparent problems.  But
when I wrote BackGrounder ii I wanted to ensure wide portability, and
I worried about a BIOS that did _not_ use interrupts and might
behave strangely if they were suddenly enabled.  This might seem
paranoid, and it's probably the case that a number of other programs
would not run on such a system.  But I was recalling an early
experience of trying to boot an 8085-based S-100 Compupro system in
which the interrupt lines had been left floating.  When the first EI
was executed in the cold-boot code, one of the devices triggered an
interrupt, before the BIOS's service routine had been installed.

The routines in Figure 1 can be called in place of inline DI and EI
instructions to disable interrupts and conditionally re-enable them.
As far as I have been able to determine, this test of the Z80's
interrupt status works correctly.  However, I have heard reports that
some "Z80" cpu's do not report this status correctly.  I would welcome
any reliable information on this point.

	      Figure 1. Disable and Re-enable Interrupts
;
; Save interrupt status and disable interrupts
;
disable_int:
	push	af		; save registers
	push	bc
	ld	a,i		; get interrupt status to A
	push	af
	pop	bc		; and into C
	ld	a,c		; and save it
	ld	(intflag),a
	pop	bc
	pop	af
	di			; disable non-maskable interrupts
	ret
;
; If interrupts were previously enabled, 
; re-enable them.
;
enable_int:
	push	af		; save register
	ld	a,(intflag)	; if interrupts
	bit	2,a		; .. were previously enabled
	jr	z,1$
	ei			; ..re-enable them
1$:	pop	af
	ret

	

.h1 Batch Processing

Batch processing is running a sequence of commands by submitting a
single command to the operating system.  In the good old days, the
computer operator submitted programs, on 80-column punched cards, to a
desk-sized card reader.  Programs were batched together by stacking
the card decks in a long metal tray.  You (or the operator) lugged the
tray across the room, crossing your fingers that you didn't trip and
spill everything on the floor.  Eventually, your job ran and after a
seemingly endless wait, the printer disgorged interminible pages of
digits, and you went back to debugging yet another core dump.  Then
the cycle repeated....

CP/M's standard batch processor is the SUBMIT utility.  It takes a
file of command lines, stored in a file of type SUB, and writes them
to a temporary file.  The command processor detects this file and gets
its commands from it, a line at a time, until it has completed the
batch.  Then it once again gets its commands from the keyboard.

A submit file, or script, called TEST.SUB might look like this:

	cmd1 command_tail1
	cmd2
	cmd3 command_tail3

Your command

	SUBMIT TEST

would then cause the three commands to run in sequence.

This basic system works well for programs that require only
command-line parameters for their input.  But when a program, say
CMD1.COM, needs console input, the process stops in its tracks and
waits for the user to type in the input.  Many times this is just what
you want to occur -- the user needs to make a real-time decision, and
enter data or a response.  Often, however, we want the _program input_
to also be automated, so that it can be provided from the same script,
and the entire batch of jobs will run to completition unattended.

Digital Research, the authors of CP/M, attempted to provide this
capability with the XSUB utility.  But it was an early attempt to
write an RSX (resident system extension), it was buggy, and it proved
incompatible with any other RSX.

A major step forward was the development of utilities that combined
SUBMIT and XSUB processing, kept the script in memory inside the RSX
for faster performance, and supplied a line editor so that short
scripts could be typed in on-the-fly when needed.  EX.COM was one.
Another was the In Memory Submit capability included in Morrow
computers stored the script in banked memory on their CP/M computers.

.h2 ZEX

For the Z-System the batch processor has been ZEX -- the Z-System
EXecutive input processor.  It evolved from EX, and has grown like
topsy, with significant contributions from Rick Conn, Joe Wright, Jay
Sage and others.  These increasingly elaborate versions provided for
greater control over input, the ability to print messages while the
script was running, simple looping, testing of command flow control,
etc.

Yet ZEX never quite seemed housebroken, and the tireless Rick Charnes
was always coming up with some new batch process that he couldn't
quite get ZEX to perform.  Moreover, there was no ZEX for Z3PLUS
systems.  And the hieroglyphics required to write a ZEX script always
required relearning just when you needed a quick, automated process.

These warts, and conversations with Joe Wright and Jay Sage, the most
recent revisors of ZEX, finally led me to take a fundamental look at
this utility.  Although the code contained many notable advances, this
was truly a "topsy" program, something that had been bandaged and
remodeled many times.  So, in discussions with Jay, I decided that we
need to rethink our objectives and design the program from the outside
in.  This issue's column focuses on that design, leaving its
implementation for another time.

.h2 What Should ZEX Be?

The easy part was how it should run.  The new ZEX should run on both
CP/M 2.2 and CP/M Plus systems.  It should be compatible with existing
RSX's.  It should be able to load and use RSX's as part of a script.
And, perhaps, it should be able to invoke a second ZEX script.

These requirements would give us a single batch processor for all
Z-Systems, and scripts that could be used on both CP/M 2.2 and CP/M
Plus machines without change.  A script could be executed while an
RSX, such as BackGrounder ii or DosDisk, is already in memory.  If
needed, the script could load an RSX, for example one to filter
printer output.

Preliminary goals for the script language seemed straightforward.  The
language should allow a standard SUBMIT script to run identically.  It
should use English-like directives, provide convenient, easily
readable comments, and clearly distinguish between input for the
command processor, input for programs, and messages and directives.
Programs should run identically when the same commands appear in a
script, or are typed in at the console.

This is starting to sound like the textbook-prescribed top-down design
exercise.  As any real programmer knows, that would be a fairy tale,
because it seems that all of us just _have to_ write some code, if
only to check out an idea.

Well, writing code before the design is completed can indeed be
productive -- the key thing is to avoid getting emeshed in the thicket
of small details before the major skeleton of the project, and
possible alternatives, have been sketched and evaluated.  So, while
drafting and redrafting these preliminary specifications, I also found
myself experimenting experimenting with the parsing code, rewriting,
modularizing and consolidating several existing ZEX versions, and
developing and testing the CP/M Plus interface.

What follows, then, is a still-in-process description of the evolving
new ZEX, version 4.0.  Your comments and suggestions will be welcome
and will surely improve it.  I expect ZEX to continue to evolve -- it
will be easier to add features to the code now that it is more
modular.  What will require effort is the systematic thought and
testing of extensions to the language, to avoid unintended side
effects and anomalous cases.


.h1 The ZEX Script

ZEX is the Z-System batch-processing language.  ZEX.COM is the
system tool that implements it.  Its purpose is to automate complex
and repetitive tasks that require running a series of programs or
entering keyboard input.

A ZEX _script_ is a text (ascii) file, or series of text lines entered
interactively when ZEX is run.  The script file is conventionally
given the filetype .ZEX, or sometimes .SUB, for convenience in
identifying scripts in a directory.

A script typically consists of a series of _commands_ and their
_command-tails_ that form the input to the ZCPR command processor.  In
this form the script is equivalent to a CP/M SUBMIT script.  In
addition, the script may contain _data_ for programs that would
otherwise be entered from the console keyboard.  This feature is
similar to, but more advanced than, the CP/M XSUB.

In addition, the ZEX script may contain a number of ZEX _directives_
that provide for console messages, waiting for a keypress, ringing
the bell, testing command flow control, and so forth.

ZEX explicitly distinguishes between _command-processor_ input
and _program_ input.  Normally, ZEX gets all command-line input from
the _script_ and all program input from the _console_.  (This is
exactly what SUBMIT does; a SUBMIT script will run identically under
ZEX.)  But the input sources can be switched by directives.  For
example, all program input can also be obtained from the script, so
that the complete script will run unattended from start to finish.

In reading this, keep clearly in mind the difference between a script
file, typed input, and console output.  A file is a stream of bytes,
broken into lines by a _pair_ of bytes: <CR> followed by <LF>.
Similarly, when a line of text is output to the screen, it ends with a
<CR> (which moves the cursor to the first column of the current line),
and a <LF> (which moves it down one line).  However, when a line is
entered from the keyboard it is terminated by a <CR> only.  Thus,
in a script you should designate the end of a line of program _input_
with a |CR|.  For a multi-line message to the screen, terminate each
message line with |CRLF|.

.h1 The ZEX Language

The ZEX script consists of lines of ascii text, each terminated by a
<CR><LF> pair.  (Create the script with a text editor in ascii
(non-document) mode, or just type it into ZEX when prompted.)  A
number of reserved words, called _directives_, control the various
features.  Each directive begins and ends with the verticule character
'|'.  The directives may be entered in upper, lower, or mixed case; we
use uppercase here to make them stand out.  All script input that is
to be sent to a program begins with a '<' character in the first
column; all other lines are sent to the command processor or, when
specifically directed, are messages sent directly to the console
output.

.h2 Command-processor input:

 - is any line of the script that doesn't begin with '<'
 - is case-independent.
 - spaces and tabs at the beginning of a line are ignored
 - is <CR><LF> sensitive.  The end of a script line is the end of
   one command line.  Use the |JOIN| directive at the end of a script
   line to continue the same command line on a second script line.
   (The <LF> is always discarded).
 - use "|NUL| " or |SPACE| to insert a space preceeding a command, or
   after a command and before a comment.
 - begin each command (or set of multiple commands, separated by
   semicolons) on a new script line, optionally preceeded or followed by
   whitespace.
 - all whitespace immediately preceding a |JOIN|, and all characters
   on the line following |JOIN| are discarded.

.h2 Program input:

 - is normally obtained from the console.
 - begin each line of program input with a '<' in the first column.
 - input is case-sensitive.
 - data from the script ignores the <CR><LF> at the end of
   a script line.  A single line of program input may spread over
   several script lines.
 - use |CR| to supply a carriage-return.
 - use |LF| for linefeed and |CRLF| for carriage-return-linefeed.
 - if the program requests more input than is supplied in the script,
   the remaining input is obtained from the console
 - use |WATCHFOR string| to take further input from the console, until
   the program sends "string" to the console output, then resume
   input from the script


.h2 Both:

 - use |SAY| to begin text to be printed on the console.
 - use |END SAY| to terminate that text
 - use |UNTIL ~| to take further input from the console,
   until a keyboard ~ is entered.  The '~' character may be any
   character; pick one that won't be needed in entering console input.
 - use |UNTIL| to take further input from the console,
   until a keyboard <CR> is entered.

.h2 Comments

A double semicolon ";;" designates the beginning of a comment.  The
two semicolons, any immediately-preceding whitespace, and all text up to
the end of that line of script are ignored.

A left brace '{ in the first column designates the beginning of a
comment field; all text, on any number of lines, is ignored up to the
first right brace '}'.


.h2 Other Directives

Within a directive, a SPACE character is optional.  Thus, |IF TRUE|
and |IFTRUE| have the identical effect.

|IF TRUE|	begin conditional script; do if command flow state is true
|END IF|	end conditional script
|IF FALSE|	begin conditional script; do if command flow state is false
|RING|		ring console bell
|WAIT|		wait until a <CR> is pressed
|AGAIN|		repeat the entire ZEX script
|ABORT|		terminate the script if the flow state is true
|QUIET ON|	turn on the ZCPR quiet flag
|QUIET OFF|	turn off the ZCPR quiet flag
|CCPCMD ON|	turn on ZCPR (CCP) command prompt
|CCPCMD OFF|	turn off ZCPR (CCP) command prompt
|ZEXCMD ON|	turn on ZEX command prompt
|ZEXCMD OFF|	turn off ZEX command prompt
|NUL|		use to make following whitespace significant
||		same as |NUL|
|SPACE|		one space character


.h2 Parameters

ZEX (like SUBMIT) provides for formal parameters designated $0 $1 ...
$9.  When ZEX is started with a command line such as:

	A> ZEX SCRIPT1 ARG1 ARG2 ARG3

then ZEX reads and compiles the SCRIPT1.ZEX file.  In the script,
any "$0" will be replaced by "SCRIPT1", any "$1" is replaced by
the "first" argument "ARG1", etc.

The script may define "default parameters" for the values $1 ... $9.
To do so, enter the three characters "^$n" followed (with no space) by
the nth default parameter.  When ZEX encounters a formal parameter in
the script, it substitutes the command-line parameter, if there was one
on the command line, and otherwise the corresponding default
parameter, if it was defined.

Alternatively, you can define default parameters by entering
"|n=param|", where 'n' is '1' to '9' and "param" is the default string
(containing no whitespace).

.h2 Control characters

You enter a control character into the script by entering a caret '^'
followed by the control-character letter/symbol.  For example, "^A"
will enter a Control-A (01 hex).  Control-characters may be entered in
upper or lower case.

.h2 Quotation

ZEX uses a number of characters in special ways: dollar-sign, caret,
verticule, left and right curley braces, less-than sign, semicolon,
(space, and carriage-return).  Sometimes we might want to include
these characters as ordinary input, or as output in a screen message.
For this, ZEX uses '$' as the _quotation character_.  (This is also
called the _escape_ character, because it allows one to escape from
the meaning reserved for a special character.)  "Quotation" means that
the next character is to be taken literally; I use this term to avoid
confusion with the control code 1B hex generated by the _escape key_.

If '$' is followed by any character other than the digits from '0' to
'9', that character is taken literally.  Thus, if we want a caret in
the text and not a control character, we use '$^'.  If we want a '<'
in the first column of a line that is for the command processor and
not for program input, then we use '$<' there instead.  And don't
forget that if we want a '$' in our script, we must use '$$'.  There
are some cases, like '$a', where the '$' is not necessary, but it can
always be used.
 
To pass a ZEX directive to a program, or the command processor, use
the quotation character with the verticule.  For example, to echo the
string "|RING|", the zex script should be:

		echo $|RING$|

.h2 Some examples

Figure 2 provides several examples of how the new script language
should work.  You will note a number of differences from the current
dialect used, for example, in Rick Charnes' article in this issue.
And, no doubt, further improvements will emerge from your suggestions
and the actual implementation of the new batch processor.


		    Figure 2.  ZEX Script Examples


ZEX SCRIPT		INPUT SOURCE/EXECUTION SEQUENCE

cmd1	;;comment	The CCP receives "cmd1<cr>".  The spaces before
		        the comment are stripped, and the <cr> at the
			end of the line is passed to the CCP.
			The cmd1 program gets its input from the console.

cmd2 |UNTIL|		The CCP receives "cmd2 " and then gets additional
			input from the console, including a <cr>.
			The cmd2 program gets its input from the console.
|SAY|ccp msg|ENDSAY|cmd3
			When the CCP prompts for the next command,
			"ccp msg" is printed on the console.  The CCP
			then receives "cmd3<cr>"
<text			The cmd3 program gets "textmore text<cr>new
<more text|CR|		line of text"
<new line of text	If the program requests more input, it comes from
			the console.

cmd4 cmd4tail		The CCP receives "cmd4 cmd4tail<cr>"
<|UNTIL~|		The cmd4 program receives console input until
<text			the user types a '~'.  Then the program receives
			"text"
			If the program requests more input, it comes
			from the console.  If the program doesn't use all
			of the input, it is discarded.

cmd5 |UNTIL~| tail	The CCP receives "cmd5 " and then gets additional
			input from the console, until the user types '~'.
			The CCP then receives " tail<cr>".
			The program receives input from the console.

|UNTIL|			The CCP receives a command line of input from the console.
			The program receives input from the console.

|UNTIL|			The CCP receives a command line of input from the console.
<|SAY|message|ENDSAY|	When the program first calls for console input,
<text			"message" is printed on the console.  Then the
			program receives "text".
			Additional program input is received from the console.


cmd6			The CCP gets "cmd6<cr>"
<|WATCHFORstring|	The cmd6 program gets input from the console, until
<|SAY|message|ENDSAY|	the characters "string" appear at the console output.
<text			Then "message" appears on the console output, and
			the program gets "text".  Further input comes
			from the console.
			If "string" never appears, all of this is
			discarded.

alias1			The CCP gets "alias1<cr>".  That program, a Z-System
			alias, puts "cmd1;cmd2" into the multiple
			command line buffer.  The CCP then obtains "cmd1" from mcl
<|UNTIL~|		The cmd1 program gets any input from the
<cmd2text		console.  If a '~' is typed, it gets "cmd2text".
			If cmd1 does not request console input, or if
			no '~' is typed, cmd1 finishes and the CCP then
			obtains "cmd2" from mcl.  Assume this case.
			The cmd2 program obtains input from the
			console, until a '~' is typed.  Then it gets
			"cmd2text".  Further input comes from the console
cmd3			The CCP gets "cmd3<cr>".
<text			The cmd3 program gets "text".  Further input
			comes from the console.


