Art:  This TOTALLY REPLACES the disk I mailed 2 days ago.  Bridger. 12/29/88

TCJ #37
_words in italics_
.h1  main headings
.h2  secondary headings

			    Advanced CP/M

		      Raw and Cooked Console I/O


			   Bridger Mitchell

{usual sidebar on Bridger}


.h1 ZSDOS News

The brand-new CP/M disk operating system -- ZSDOS -- that I announced
in this column last fall is meeting an enthusiastic reception.  At
that time I wrote that the quality of the design and testing that have
gone into this project means we are unlikely to see a long series of
revision numbers to fix bugs.  But I didn't mean to imply that a major
upgrade, ZSDOS 2.0, might never appear!  Indeed, I should have gone on
to say that we may expect further contributions from the design team.

In the first of a multi-part article in this issue of TCJ, two of the
ZSDOS authors -- Hal Bower and Cameron Cotrill -- take you behind the
scenes of the many innovations in the new DOS.  And several of you
have asked about porting ZSDOS to banked-memory (HD64180, Z80)
systems.  Well, early discussions are afoot to set specifications for
a banked-memory version with well-defined memory-management services.

Meanwhile Carson Wilson, the third member of the team, has been avidly
turning out system utilities with nifty new features and is at work on
a Z-System version of a popular public-domain memory-based editor.

If you haven't already ordered it, ZSDOS is available from Plu*Perfect
Systems and Sage Microsystems East.

.h1 Feedback Loop

With the demise of yet another magazine (Profiles) that provided some
coverage of CP/M topics, TCJ takes on greater prominence as a
continuing source of high-quality CP/M information.  Art Carlson and
we regular columnists need your feedback and suggestions to keep
expanding and broadening TCJ's material.

I've appreciated the cards and BBS messages several of you have sent.
They indicate that you find these columns worthwhile, although not
always fully digestible in one sitting!  I will continue to focus on
more advanced technical topics relating to the CP/M operating system,
aiming to get the core concepts and details into print.  I fully
expect readers to extend, expand, revise and critique these pieces --
that's how our hobby progresses!

I'd especially like to receive suggestions for topics for future
columns.  One early candidate is methods to make the Z-System external
environment address available to applications that have not been coded
as a Z-System tool, including compiler-generated .COM files.

I'd also welcome information about adding 3.5" and high-density 1.2MB
5.25" drives to CP/M systems.  I've recently customized
DosDisk for an OEM to handle the AT-style 1.2MB floppy disk format.
The DosDisk software could be similary extended to handle the 3.5"
MS-DOS format, but in order for this to be usable the BIOS must talk
to the drive.  Some of you have doubtless done this, or at least
thought it through.  It would make a nice TCJ article!


.h1 Unit-Record Input/Output
 
A processor is isolated and quite useless until it can talk to the
"outside world".  Input and output are essential -- they supply the
processor with data and enable it to report results.  Memory chips
provide the fastest i/o.  After that come hard disks, floppy disks,
magnetic tape, and serial channels at decreasing data rates. 

In TCJ #35 we covered file systems.  Input and output to files is done
in blocks (physical sectors) of many bytes, and file storage devices
(floppy disks, hard disks, tape drives, ram disks) are sometimes
called block-devices.

Our interest in this column is input/output to/from _character_
devices -- devices that normally supply or accept one byte at a
time, such as a terminal, printer or modem.  Single-byte devices
are sometimes called unit-record devices; they can be thought of
as special block devices with a record length of one.

For many purposes it's useful to think of the computer's software
environment as a series of rings.  At the outer ring are the
application programs.  Just inside are the high-level languages,
and inside that is the operating system.  Its outermost layer is
the BDOS, providing a standardized, hardware-independent set of
high-level services for access to the file structure and bundled
input/output services to various devices. 

The next ring is the BIOS, providing all of the primitive
input/output services needed by the BDOS.  It is the border land
between a standard system and the specific computer.  At the BIOS
jump table the interface is completely standardized, but within
the BIOS the system designer must program down to bare metal,
coding routines that know the precise conditions of the hardware
-- disk drive, video display, printer handshaking conditions.

In general, applications will be more portable and easier to write if
they confine their operating system access to the outer ring -- BDOS
calls.  Yet there are good reasons for using BIOS calls in some
applications, those that require highest performance or services
unavailable from the BDOS.  And in a few cases, an application must
forego portability and itself directly access the hardware, because no
BIOS service is available; for example, to read a video terminal's
screen or use a modem port.

The CP/M 2.2 BIOS provides character-device services for the
basic device needed to command the system (the console),
an auxiliary device, and a printer.  These services are:

	CONSTAT		Console Input Status
	CONIN		Console Input
	CONOUT		Console Output

	READER		Auxiliary Input
	PUNCH		Auxiliary Output

	LISTSTAT	Printer Output Status
	LIST		Printer Output

Each input or output service returns or sends a single byte.  For
input, the routine waits until a byte is ready before it returns; for
output, it waits until the device can accept the byte.

Strangely, only one BIOS input device and one output device has a
status call function available to an application.   The BDOS or
an application can determine, by calling CONSTAT, whether a
character is waiting in the input (a key has been pressed). 
Similarly, it can call LISTSTAT to see whether the printer is
idle and can accept a character.

But there is no portable way, in CP/M 2.2, to determine whether the
console device is ready to _accept_ a character.  All you can do
is call CONOUT to send the character and wait, hoping that the
device will eventually be ready.  This might seem all right (how
would you run a CP/M system if you couldn't see its console
output?).   But, consider an application that wants to keep the
processor running at full efficiency (perhaps a video game, or just
a smart display utility).   It would like to send a character to
the console only when it knows that it will be processed immediately.

Internally, however, the BIOS must have a routine to determine
the input and output status of every device.  In order to obtain
a valid byte of input it must not access the physical device (a
parallel port, an asynchronous receiver chip) until the device
signals, by some type of status report, that a byte is ready.
And similarly, the BIOS must not output a byte to a physical
device (video ram, serial tranmsitter chip, parallel port) until
the device signals that its buffer is empty and ready to recieve
a byte. 



.h1 Cooked Input

The BDOS provides standardized services to applications, hiding
some of the tedious details of communicating with the input and
output devices.  For the console device the BDOS provides
_cooked_ (processed) input and output services, sparing the
programmer the overhead of including this code in almost
every application.  For applications needing raw console input and
output, the BDOS also provides a raw (uncooked) function #6.

In CP/M 2.2, console single-character input function (#1) provides:
	
	. echo to console output
	. flow control
	. abort control
	. tab expansion

In addition, the console line-input function (#10) provides
limited line-editing and printer controls:

	. delete last-character (backspace)
	. cancel line (^X or ^U)
	. retype line (^R)
	. list device output control

(Other function #10 editing controls -- delete and echo, and end
physical line -- existed to serve paper-output teletypes.  BDOS
patches and replacements such as ZSDOS have eliminated them.)

Both the console single-character output function (#2) and the
string output function (#9) provide:

	. flow control

.h2 Flow Control and Lookahead

Flow control is the process of starting and stopping the flow of
bytes over an input/output channel.  Our concern here is the
control of bytes to the console device.  

The BDOS is designed so that the user can "freeze" a screen of
messages by typing a Control-S -- the standard XOFF character. 
Output will resume by typing Control-Q -- the standard XON
character.  Actually, output resumes when any other character
(except Control-C -- the abort character) is typed, but it's a
good habit to use Control-Q to keep your fingers conditioned for
systems, such as unix, that use the standard control characters.

In order for flow control to work, the application must print its
messages using BDOS functions #2 and #9.

Flow control requires something that many -- including compiler
authors and BDOS hackers -- have found astonishing:  the BDOS
console-output functions must call the BIOS console _input_
functions in order to perform a _lookahead_ function.  After all,
how else could the BDOS know that the user had typed a Control-S
to suspend output?

It works like this.  Before the BDOS sends a character to the
console, it checks the console input status.  If no key has been
pressed, the character is sent.

But suppose a key has been typed.  In this case the BDOS calls
the BIOS console input function to get the character.  From this
moment on, the character is no longer in the BIOS.  The BDOS then tests
whether the character is a Control-S.  If it is, the BDOS waits
for the _next_ keypress and only then sends the output character. 
If it is _not_ Control-S (or Control-C, discussed below) the BDOS
saves the character (say 'A') in a one-character buffer and sends the
output character.

If the next operation is to print another character on the console,
the BDOS test for flow control will become ineffective.  The BDOS has
only the one-character buffer, which is now full (it's holding the
'A'), so it cannot check the next keypress for Control-S; if it did,
and the character were anything else, it would have to throw away one
of the input characters.

The lookahead function might perhaps have been better implemented by
providing a "peek" subfunction to the BIOS CONIN -- return but retain
the pending next character.

The key result is that the next console input character is moved from
the BIOS into the BDOS one-character buffer as a result of any BDOS
function #2 or #9 output.  As a consequence, any application that uses
the _BIOS_ to obtain console input will sometimes "lose" a typed
character, only to have it emerge when the BDOS is next used for input
(function #1 or #10)!


.h2 Coping with missing characters

The simplest rule I can give you for coping with missing
characters is to  keep all console input/output at _one_ level of
the operating system -- all BDOS or all BIOS -- within a single
application.  For example, don't mix BDOS line input (function
#10) and BIOS CONIN.

It's fairly common for applications to use the BIOS functions for
console i/o, in order to speed up output and to get every possible
keyboard character.  The Z3LIB and VLIB routines used in many Z-System
utilities do so.  At the start of such an application you may need to
check the BDOS, using function #11, to see if a fast keypress has
already been sucked into the BDOS one-character buffer.  If it returns
non-zero, you can get the character with function #1 (but that will
echo).  In order to use function #6 successfully to get the character
without echo, you need to have installed the Plu*Perfect Systems patch
(described later).

Jay Sage has used the following method of obtaining input (a
named-directory password) from BDOS function #10 with echoing shut
off.  First, save the first byte of the BIOS CONOUT jump vector (it
should be the JP opcode) and replace it with a RET opcode.  Next, call
BDOS function #10.  When the BDOS calls the BIOS CONOUT to echo the
character, the BIOS will return at once.  Then, immediately following
the BDOS call, restore the first byte of the BIOS CONOUT jump.  (Note
that he follows the sound principle of saving and restoring the
environment, by saving and restoring the byte in the BIOS "jump
vector".  he doesn't simply assume it is a JP.  It's possible that
other code -- perhaps in an RSX -- has already patched this location.)

This trick is handy, but should be used only where no other solution
is available.  In Jay's case, there was insufficient room in the Z34
command processor to collect a password with function #6.  The
difficulty with this approach is that during the time that the BIOS
CONOUT is patched out it is possible that other processes would be
generating console output.  What other processes could there be in
CP/M?  If BackGrounder ii is loaded, a press of the <SUSPEND> key
would temporarily suspend the current task and prompt for user input,
but the prompt would be invisible!  Or an interrupt-driven task could
generate a screen message that would be lost.



.h2 Abort Control

A Control-C will cause the BDOS to abort the current application,
jumping directly to 0000, when it is:

	. the _first_ character typed after a Control-S
	  has halted output from function #2 or #9.	

	. the _first_ character typed to line-input
	  (function #10)

The abort control feature of the CP/M 2.2 BDOS is a mixed
blessing at best.  It gives the user a handy way to kill a job
that is scrolling unwanted output to the screen.  But it limits
the use of edited BDOS line input to applications that can
tolerate abrupt termination if the user happens to hit Control-C.
As a result, most well-written applications must incorporate
their own line editor in order to retain control to avoid being
cancelled with unclosed files, open modem connections, or whatever.
 

.h1 Cooked Output

In addition to flow control, which is a feature of cooked console
input that controls the flow of output, the BDOS alters the raw
output to the console by special processing of tabs and by
creating a parallel stream of output for the printer.

.h2 Tab expansion

The BDOS expands the horizontal tab character (09h) to the number
of spaces required to reach the next logical tab stop (every
eight characters).  To do this it keeps a current-column count
for all output to functions #2 and #10, resetting it to 0 on each
carriage return.

This is a handy cooked-output service.  But to work successfully,
all output on the line must go through these BDOS functions. 
Avoid mixing BDOS and BIOS console output on the same line.

.h2  Echoing to the Printer

The BDOS maintains a flag that, when set, causes function #2 and
#9 output to be echoed to the BIOS list device as well as the
console output.  The flag is toggled when a Control-P is typed
to function #10 -- the line-input function.

Control-P is very handy for getting a quick, selective printed
record of some console output.  It can also mysteriously freeze
your system when the printer is not ready.  When your computer locks
up, make a habit of checking the attached external devices (printer,
modem) before you resign yourself to pressing the reset button!



.h1 The Case of the Missing Character

If you've used a number of CP/M systems, you've probably had the
puzzling and quite annoying experience of occasionally "losing"
one character you have typed when running a program, only to have
it pop up unexpectedly much later, perhaps at the next command
prompt.  It's a difficult bug to reproduce, and occurs only on
some systems.  This spooky gremlin is so perplexing that a user
can begin to believe his computer is truly haunted!

Has CP/M been visited by the supernatural?  Probably not.  We've
already seen how mixing BDOS and BIOS console functions can cause
an input character to become stuck in the BDOS one-character
buffer when subsequent input is obtained by BIOS calls.

Several years ago, Derek McKay, my partner at Plu*Perfect
Systems, spotted another cause of missing characters -- a bug in
Digital Research's original design of the CP/M 2.2 BDOS that used
faulty logic in the handling of "raw" console input with BDOS
function #6.  Moreover, Derek developed a Z80 patch that corrects
the problem and fits in the original BDOS space.  This is an important
improvement, because without it there is no totally reliable way
to mix cooked BDOS console i/o with any type of raw i/o, either
BIOS or BDOS.

We included the patch in the CP/M Enhancements that Plu*Perfect
originally published for Kaypro systems.  More recently, the
authors of ZSDOS have incorporated the same logic into their
excellent new DOS.  So, on these systems, the missing character
doesn't manifest itself.

.h2 Raw Console Input

To understand how a character can disappear, and then reappear,
we first need to examine the BDOS's raw console input function.

BDOS function #6 was intended to provide absolutely raw console
input and output functions accessible by a BDOS call, with no
input flow control and no output processing.  An application would
use this function, for example, when it wanted to get a character
without necessarily echoing it to the terminal. 

DRI attempted to squeeze input, input status, and output into a
single BDOS function (probably to save 8080 code space) and in
doing so somewhat limited the usefulness of this service.  To use
function #6, set C=6 and

	E= 0FFh		to get a character, if ready
	E= 0FEh		to get console input status
	(E=0FDh		to wait for a character)
	E= 0...0FCh	to output the value in E to the console

When used for input, function #6 returns a 1-byte value in A.  If
A is 0, no character is waiting; a non-zero value is the input
character.  Thus it is impossible to enter a nul character
(Control-@ on most keyboards) when function #6 is used.  (This
defect is significant for editors, which must therefore use
BIOS functions for console i/o.)

When used for output, function #6 is limited to values 0h to 0FCh.
Usually ok, this restriction makes some 8-bit coded graphics
characters unprintable on a few terminals.  (The subfunction code 0FDh
is used by CP/M Plus and ZSDOS to wait for the next character and
return it.)

But the real bug in function #6 is its internal check for input
status.  The original BDOS code (figure 1) calls the BIOS CONSTAT
routine to determine if a character is waiting.  This is fine,
except that another BDOS function may have called the lookahead
routine to test for flow control and left the tested character in
the lookahead buffer.  When that situation exists, function #6
will return A=0 (no character waiting) until a key is typed, and
then return the next typed character, not the one last typed and
still in the buffer!

Meanwhile, the tested character continues to sit in the buffer. 
Eventually, someone -- either the application program or the
command processor -- will call a BDOS function that does check
the lookahead buffer before returning a character.  It will find
the character still there, and return the missing character!

.h2 Code

Figure 2 contains the replacement routine.  It calls a new
"ckstat" routine to determine input status.  The new routine just
fits into the space made available by rewriting the "lkahead"
routine just above it in z80 code.

Note the exact logic of the ckstat routine.  By clever coding it
returns two flag values -- nonzero and carry not set when the next
character should be obtained from the BDOS and nonzero and carry
set when the next character should be obtained from the BIOS.

With this new routine, the lkahead routine can determine from
calling ckstat whether to call the BIOS CONIN.

.h2 Patching your BDOS

If you are running the original CP/M 2.2 BDOS you can upgrade it
with the function #6 patch.  Using a debugger, first check that
the original 8080 code is exactly as shown in the figures.  Then
assemble just the patch code with the BDOS equate set to the base
value for your system, and output a hex file.

The hardest part is getting the patch installed in your system.
You can load it with a debugger, and then check memory to see that
it is installed.  But if your system reloads the BDOS on a warm
boot, the patch will be gone when the next program runs.  If
that's the case, you will need get the patch into the SYSGEN.COM
image of the BDOS.

Load SYSGEN.COM with a debugger.  On most systems, the BDOS image
begins at 1200h.  Compare the bytes there and in the running BDOS
in high memory and then compare the bytes at the patch locations
in the image (by adding 1200h to the addresses in the figures
here) and in high memory.  If all matches up, load the hex patch
into the high BDOS, compare again, and then move just the patched
bytes of the two upgraded routines to their corresponding
location in the overlay:
	
	MBDOS+0123,BDOS+0141,1200+0123
	MBDOS+02D4,BDOS+02EC,1200+02D4

Then save the appropriage number of pages of the modified XSYSGEN.COM.
Run XSYSGEN and place the system on the boot tracks of a scratch
disk.  Boot the disk, test the system for normal operation, and
then with a debugger check the high BDOS to see that the patches
are indeed in place.

Note that this patch will not work with ZRDOS or other replacement
BDOSes.  It may be possible to write a functionally equivalent
ZRDOS patch, if you can find enough free space in a BDOS that is
already in Z80 code.



     Figure 1.  Corrected CP/M 2.2 BDOS Function #6 Routine
     ------------------------------------------------------

Authors: Derek McKay, Bridger Mitchell (Plu*Perfect Systems)

  0000	bdos	   equ	0000h		; base of CP/M 2.2 BDOS
  00B7	  abort	   equ	bdos+00B7h	; "jp 0000"
  00FB	  getchar  equ	bdos+00FBh	; get next console input char.
  0301	  setretval equ	bdos+0301h	; set return value in A
  030A	  charbuf  equ	bdos+030Ah	; 1-character input buffer
  0D91	  exit	   equ	bdos+0D91h	; BDOS exit routine

  0E00	bios	   equ	bdos+0e00h	; base of BIOS
  0E06	  constat  equ	bios+6		; console status
  0E09	  conin	   equ	bios+9		; console input
  0E0C	  conout   equ	bios+0Ch	; console output	

; -- original (8080) Direct Console I/O Routine --
;    malfuncting code marked with "***"

  02D4		org	bdos  + 2D4h	

  02D4	79	fn6:	ld	a,c
  02D5	3C		inc	a
  02D6	CA 02E0		jp	z,fn6in
  02D9	3C		inc	a
  02DA	CA 0E06	fn6s:	jp	z,constat	; ***
  02DD	C3 0E0C		jp	conout
  02E0	CD 0E06	fn6in:	call	constat		; ***
  02E3	B7		or	a,a
  02E4	CA 0D91		jp	z,exit
  02E7	CD 0E09		call	conin		; ***
  02EA	C3 0301		jp	setretval

; -- corrected (z80) routine --

  02D4		org	bdos  + 2D4h	
		;
  02D4	79	fn6:	ld	a,c		; if c == FF
  02D5	3C		inc	a
  02D6	28 08		jr	z,fn6in		; ..get character
  02D8	3C		inc	a		; if c == FE
  02D9	CA 0137		jp	z,ckstat	; ..get input status
						;   of buffer & bios
  02DC	C3 0E0C		jp	conout		; ..else output char
		fn6in:	call	ckstat		; check both buffer
						;   and bios
  02DF	CA 0D91		jp	z,exit		; ..no char waiting,
						;   return 0 status
  02E2	CD 00FB		call	getchar		; get char from buffer
						;   or bios
  02E5	18 1A		jr	setretval	; and return it
		;


	     Figure 2.  Console Look-Ahead Routines
	     --------------------------------------


; -- original (8080) console input look-ahead routine --

  0123		org	bdos + 0123h

  0123	3A 030A	lkahead:ld	a,(charbuf)
  0126	B7		or	a,a
  0127	C2 0145		jp	nz,return1
  012A	CD 0E06		call	constat
  012D	E6 01		and	1b
  012F	C8		ret	z
  0130	CD 0E09		call	conin
  0133	FE 13		cp	'S'-'@'
  0135	C2 0142		jp	nz,savechar
  0138	CD 0E09		call	conin
  013B	FE 03		cp	'C'-'@'
  013D	CA 0000		jp	z,0000
  0140	AF		xor	a,a
  0141	C9		ret

  0142	32 030A	savechar:ld	(charbuf),a	; save input char
						; in buffer
  0145	3E 01	return1:ld	a,1		; return a non-zero
  0147	C9		ret			; character

; -- shorter replacement (z80) routine --

  0123		org	bdos + 0123h

  0123	CD 0137	lkahead:call	ckstat		; if no char waiting
  0126	C8		ret	z		; ..return
  0127	DC 0E09		call	c,conin		; if no char in buffer,
						;   call bios
  012A	FE 13		cp	'S'-'@'		; if not ^S
  012C	20 14		jr	nz,savechar	; ..return the char
  012E	CD 0E09		call	conin		; ^S, so get next char
  0131	FE 03		cp	'C'-'@'		; if ^C
  0133	28 82		jr	z,abort		; ..abort
  0135	AF		xor	a,a		; else return false
  0136	C9		ret			;    status	

; new check-console-status (z80) routine

  0137	3A 030A	ckstat:	ld	a,(charbuf)	; if buffered char waiting
  013A	B7		or	a,a		; ..clear CY and return NZ
  013B	C0		ret	nz
  013C	CD 0E06		call	constat		; else check bios for a char
  013F	B7		or	a,a		; if char waiting there
  0140	0F		rrca			; ..set CY and set NZ
  0141	C9		ret

; resume original (8080) code at 0142h

