CP/U - Control Program for Unix-like systems
Written by D'Arcy J.M. Cain
UUCP: darcy@druid

This is a quick overview of my CP/M emulator for Unix.  I apologize if
it isn't completely up to date as the program is still evolving.

The system decodes most of the Z80 instruction set.  Mostly the I/O is
not implemented.  Whenever the PC is >= 0xfec0 it executes a return no
matter what is in RAM at that location.  Before calling the routine for
each instruction I look at the PC and end the program if it is zero or
perform a BDOS function if it is 0xfec0 or BIOS if it is >= 0xff00.  Since
the emulator ignores the contents of memory as far as instruction decoding
is concerned, The system has the interesting property of being able to use
all of memory except the first 0x100 bytes for user programs by putting the
stack at 0xfffe.  In fact the default stack when a program is run is set
to 0xfff0.

I use Unix commands to simulate some CP/M commands such as DIR, REN, TYPE
and handle things such as SAVE internally.  I use the Unix file system for
drives.  The user defines Unix directories to CP/M drive mappings.  This
allows CP/M to use the same file system.  Only lower case names are useable
however and of course most CP/M programs will expect 8.3 style names.  If
a CP/M filename ends in a period it is stripped.

The ED command translates to a call to whatever environment variable EDITOR
points to.

There is a '!' command to do Unix commands from within CP/U.

Programs that use IN and OUT opcodes will fail.  All I/O must go through
the BDOS or the BIOS.  The user can set up the following devices:  Screen
(CON out), keyboard (CON in), RDR, PUN and LST.  The default for screen
and keyboard is stdout and stdin.  The user can set up Unix files for any
of these devices.  The file of course can be an actual file, a device or even
a pipe to a command, even another CP/M command that has the keyboard reading
from the same pipe.

Mostly I tried for speed except where speedup would depend on the program
running on a specific processor.  The main part of the decoding module is
a 256 entry switch table with sub-switches for the Z80 extensions.

There are two extra programs built from the sources for testing purposes.
tcpm simply runs some code giving debug output.  This is for gross testing
of things like byte order etc.  The other program is dcpm and this allows
debugging of real CP/M programs.  A separate program is created for this
purpose to prevent code bloat in the real run time.

It's not quite finished yet but I am running simple programs with it now.
What would be nice would be some sort of test suite.  Anyone know of any?
There is the start of a test suite included.

As for copyright, if you use it say where you got it and send me any fixes
or enhancements if you feel like it.  It's free and you get what you pay
for.  Don't blame me if it breaks anything or doesn't do what you expect.
(In case it isn't obvious I am not a lia^H^Hawyer.)

D'Arcy J.M. Cain
UUCP: darcy@druid

