This is a quick overview of my CP/M emulator for Unix.  I apologize if
it isn't completely up to date as the program is still evolving.

The system decodes most of the Z80 instruction set.  mostly the I/O is
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
allows CP/M to use the same file system as the Unix but does force CP/M
conventions on the file names such as upper case, must have 1 and only 1
period, etc.  It is easy to handle though since one can always link files
as necessary, even from CP/M since I also include a '!' command to do Unix
commands from within CP/M.

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

It's not quite finished yet but I am running simple programs with it now.
What would be nice would be some sort of test suite.  Anyone know of any?

As for copyright, if you use it say where you got it and send me any fixes
or enhancements if you feel like it.  It's free and you get what you pay
for.  Don't blame me if it breaks anything or doesn't do what you expect.
(In case it isn't obvious I am not a lia^H^Hawyer.)

D'Arcy J.M. Cain
UUCP: darcy@druid

