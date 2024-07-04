
                Z-System Corner -- Issue 54

                 Tenth Anniversary of ZCPR

                          Jay Sage


   On February 2, 1992, just about the time you are reading
this column, it will be exactly ten years since the first
version of ZCPR was released.  I have been involved with it
one way or another most of that time, and I think it is
amazing how vibrant the activity in the field still is.

   Our editor, Chris McEwen, had hoped that we could make
this issue a special celebration of ZCPR with contributions
from some of the original developers, most notably Richard
Conn.  I exchanged email with Richard several times about
this, but he never picked up on it.  Since of all those
still active in the Z community I may be the one who goes
back the farthest, it is perhaps fitting that I take on the
task.


Announcement

   Before I start on that, I do have one important
announcement to make.  I would like to call your attention
to the new Sage Microsystems East ad in this issue.  You
will notice that there have been quite a number of
significant price reductions.  We hope that by lowering the
entry price to Z-System from $70 to $49 we will encourage
more people who still do not use Z-System to try it out.


The History of ZCPR

   Much of the material in this column comes from the
introductory chapter of my book, the "ZCPR33 User Guide." 
When Echelon made my revision of ZCPR3 the official product
release in 1987, naturally they wanted a manual to go with
it.  Besides including all the necessary technical
information, such as what the new command processor did and
how it should be installed, I also included two other items
that were of great importance to me: a statement of what I
was trying to achieve with ZCPR33 and the history that led
up to it.  Here in TCJ I often talk about the goals of Z-
System; this time I will review some of the history.


                           ZCPR1

   "Don't you know about ZCPR!"  I remember very well being
greeted with that exclamation from one of the veteran club
members when, as a neophyte computer user, I attended a CP/M
computer club meeting.  He could not believe that someone
would still be using standard CP/M.  I soon felt the same
way and still do today!

   The ZCPR he was referring to was what we would now call
ZCPR1.  ZCPR, which stood for "Z80 Command Processor
Replacement," was the work of a group of computer hobbyists
who called themselves "The CCP Group."  They were Frank
Wancho, Keith Petersen, Ron Fowler, Charlie Strom, Bob
Mathias, and Richard Conn.  Richard, as we will see, was the
main force behind the effort.

   Ron Fowler is well known as the author of the MEX
telecommunications program, which I still use and enjoy
immensely.  Keith Petersen wrote a simplified version of
Ward Christensen's CBBS, the original computerized bulletin
board system.  Keith's program was called MINICBBS; my own
customized version of it runs to this day on my Z-Node.  It
is, to be sure, outmoded, but it gives me a sense of
connection with history that I still treasure.

   Keith Petersen was for a long time a sysop of one of the
finest BBS systems in the country, Royal Oak.  Though it
branched out to MS-DOS software, it never neglected CP/M. 
It was, perhaps, unique in that callers to Royal Oak found
themselves immediately at the operating system prompt. 
There was no request for a name or password.  If you wanted
to use MINICBBS, you had to invoke it yourself.

   Frank Wancho is involved in the administration of the
SIMTEL20 computer at the White Sands Missile Range.  This
machine houses a huge archive of CP/M programs (and many
others).  Keith is on contract to SIMTEL20 to help maintain
the collections.  I continue to see both their names. 
Frank, via email, gave me some of the information on the
birth of ZCPR.

   Sometime around 1981 Richard Conn sparked the group's
enthusiasm over rewriting the CP/M console command
processor, or CCP, to take advantage of the more efficient
and elegant opcodes of the new Zilog Z80 microprocessor. 
The people in the CCP Group were not in physical proximity. 
I believe that they maintained contact, as we do today, via
electronic mail.  Frank Wancho provided the computer access
that made that contact possible.

   With some space opened up in the CCP, the programmers
were able to add a number of convenient new features.  The
most important new concept was that of a search path for COM
files.  With CP/M version 2, Digital Research had introduced
user numbers, but the way they were implemented made them
virtually worthless, because there was no way from one user
area to run or access files in another user area.  ZCPR,
with its ability to automatically search drive A/user 0,
overcame this problem and opened up the possibility of
putting the new user areas to effective use.

   Also introduced with ZCPR was the GO command, which
permitted the most recently executed transient program to be
run again without having to reload it from disk.  That was a
real a boon in those days of slow floppy drives.  Many small
-- but very useful and helpful -- improvements were made in
the resident commands.  For example, in CP/M, when a REN or
SAVE command specified a destination file that already
existed, the command would simply abort.  The user would
then have to erase the old file manually and start over
again.  With ZCPR, the REN and SAVE commands made life
easier by asking the user if the old file should be
overwritten.

   The original ZCPR was released to the public on a disk
published by SIG/M (Special Interest Group/Microcomputers),
the public-domain software distribution arm of the Amateur
Computer Club of New Jersey.  The disk was volume 54, dated
February 2, 1982.  Interestingly enough, this is volume 54
of The Computer Journal!

   Several additional refinements were made to ZCPR by other
programmers, leading to a train of development known as
NZCPR (New ZCPR).  Version 1.6 of NZCPR was released on
SIG/M volume 77 at the end of October, 1982.  This branch
eventually reached version NZCPR21, a version never
published in disk form but distributed over the remote
access computer system network.

   Jim Byram, of the Boston Computer Society CP/M Group,
produced a privately distributed version of NZCPR using only
Intel 8080 code, which showed that efficient coding, and not
simply the use of the new Z80 opcodes, was a major factor in
improving the command processor.  Jim, by the way, may be
the one who made the remark to me that I quoted earlier.  I
eventually became the leader of that group, which merged
with several others and ultimately became the Zi/Tel Group,
of which I am now the CP/M director and the bulletin board
sysop.  That group supports CP/M, Z-System, and MS-DOS.


                           ZCPR2

   While ZCPR1 was a significant improvement over CP/M, it
was not a revolutionary advance.  Richard Conn, however, had
a vision of a truly advanced operating system, and he
continued the development.  On February 14, 1983, almost
exactly one year after ZCPR1 appeared, ZCPR2 was released in
a set of ten SIG/M volumes (98-107), an unprecedented and
monumental contribution of public-domain software.

   ZCPR2 made a very significant conceptual advance: it used
memory buffers in protected memory above the BIOS to hold
new operating system modules.  The command line, which had
always resided in the command processor, was put in one of
these buffers so that it would not be destroyed by warm
boots, during which a fresh copy of the command processor is
loaded from disk.  In that way multiple commands on a line
could be implemented.

   The command search path was also placed in one of these
buffers instead of hard-coding it into the command
processor.  In this way the search path could be changed by
the user at any time.  The concept of named directories was
also introduced, using still another memory buffer to store
the index of names.

   Many of the utilities that we are familiar with in ZCPR3
first appeared with ZCPR2.  These include ZEX, WHEEL, HELP,
PATH, PWD, MKDIR, and MENU.  A rudimentary shell concept was
used in MENU.  When this program placed a command into the
multiple command line buffer, it would always add its own
name at the end of the command sequence so that control
would eventually return to MENU.  This worked fine for
single levels of shells.  Extended command processing was
also introduced with ZCPR2.

   The ZCPR2 documentation, alone, ran to more than half a
megabyte!  It included a concepts manual, an installation
manual, a users guide, and a rationale manual (I guess Rick
felt he had to prove he wasn't crazy in doing all this
wonderful stuff).

   Shortly after the initial ZCPR2 SIG/M release, an upgrade
to version 2.3 was published in volume 108.  Up to this
point ZCPR2 still followed in the tradition of ZCPR1 and
used Zilog opcodes.  The features of ZCPR2 were now so
exciting, however, that owners of computers based on Intel's
8080 and 8085 microprocessors wanted to have them, too. 
Charlie Strom, a member of the original CCP Group and well-
known later as the sysop of the Compuserve CP/M Special
Interest Group, converted the command processor code and
some of the key utilities to Intel-compatible code and
released the result in SIG/M volume 122.  At the time,
believe it or not, I was using at work an Intel MDS-800
microprocessor development system, the computer for which
Gary Kildall, then at Intel, invented CP/M, and I remember
very well bringing up this 8080 version of ZCPR2.  It was
marvelous!


                           ZCPR3

   But ZCPR2 was by no means the end of the evolution.  On
Bastille day, July 14, 1984, not quite a year and a half
after ZCPR2, Richard Conn offered ZCPR version 3 in the form
of another nine volumes of SIG/M disks (184 to 192).  At
this point more than 10% of all the software ever released
by SIG/M had come from one contributor -- Richard Conn!

   One time when I was talking with Richard, I must have
expressed my amazement at the incredible amount of software
he had written and released to the public.  I was equally
impressed by Richard's response.  He said that the code that
others had offered to the public had taught him and helped
him so much that he felt a tremendous obligation to
contribute what he could to the community.  He certainly did
that!  And that same spirit still pervades the 8-bit
community.

   ZCPR3 brought both significant new concepts and major
refinements.  Three of the innovations were flow control,
error handling, and the message buffer.

   Flow control made it possible to achieve a vastly higher
degree of automated operation, since the command processor
was no longer dependent on the user for all command
decisions but could now make wide-ranging decisions on its
own.  The message buffer made possible communication between
the command processor and programs and between successively
run programs.

   Error handlers made it possible for improperly entered
commands to be corrected, an important facility to have in
connection with multiple commands on a line.  Having to
retype a single command after a mistake had been bad enough;
having to retype a whole, long string of commands because of
a single mistake seriously discouraged one from making use
of the multiple command facility.

   ZCPR3, by the way, unlike it predecessors, was written so
that it could be assembled to either Intel or Zilog opcodes. 
In the former case, the code was considerably longer and
fewer features could be included, but it would work on an
8080 or 8085 computer.


                           ZCPR31

   The chain of refinements to ZCPR3 that led to version 3.3
started in March, 1985, when I produced a private,
experimental version of ZCPR3 called ZCPR31 for use on my Z-
Node.  It was modified so that the command processor would
get the values for maximum drive and user from the
environment descriptor (more on this later).

   This was my first close look at operating system code,
something that had always frightened me, as I am sure it has
many others.  There is a mystique about those words,
"operating system," that makes one think that only the most
advanced programmers could possibly understand the code.  In
fact, I discovered that the code did not look much different
from that in ordinary utility programs.  To my amazement, I
was able to make changes that worked and improved the CCP. 
The most significant advances occurred in August, 1985, when
three further major enhancements were introduced.

   First, the code was changed to prevent the infinite loop
that Z30 experienced when the specified error handler could
not be found (perhaps because the path was changed or the
error handler renamed).  In that situation, a command error
would invoke the error handler.  When the error handler
could not be found, that constituted another error that
caused the error handler to be invoked, and so on until one
pressed the reset button or turned off the power.

   Second, the code was modified so that it could determine
the addresses of the RCP, FCP, and NDR modules from the
environment and respond to dynamic changes in these
addresses.

   Finally, additions were made to the code that allowed an
extended command processor to return control to the command
processor if it also could not resolve the command.  The
command processor would then invoke the error handler.  Now
the extended command processor really was a full-fledged
extension of the CCP, and a ZCPR3 system could take
advantage of both extended command processing and error
handling.  The same mechanism also made it possible for
ordinary programs to initiate error handling.

   In January, 1986, the first steps were taken to fix
serious bugs in the way the minimum path and root path were
computed.  The fix, however, had errors of its own, and it
was not until June, 1986, that Howard Goldstein finally
implemented a complete and proper solution.

   The next major set of advances came in March, 1986, when
Al Hawley, sysop of Z-Node #2 and now a familiar TCJ author,
introduced several new concepts.  One was a new way to
implement wheel-protected commands (commands that can be
executed only by specially authorized users).  In Z30 wheel
protection had to be hard coded into the command processor
(and RCP), and when one of the restricted commands was
invoked with the wheel off, an error message resulted.  Al
introduced the idea of setting the high bit of the first
character of a command to signal that the command was off-
limits to non-wheel users.

   This concept had several important advantages.  First,
the code was shorter.  Second, the new code automatically
made the same technique apply to commands in other modules
(RCP and FCP), so that wheel-checking code could be
eliminated from those modules.  Third, when the wheel byte
was off, wheel-protected commands instead of displaying an
error message simply vanished as far as the command
processor was concerned.  In this way, transient programs or
aliases with the same name as the resident command could
automatically step in and provide whatever action the system
implementer desired.

   Al Hawley also introduced two concepts that made dealing
with secure systems easier.  He made it possible for the
command processor to determine dynamically whether or not to
recognize the DU form of directory reference in response to
the setting of the DUOK flag in the environment, and he
allowed the option of bypassing password checking when the
wheel byte was set.  These features made it possible for a
sysop or system implementer to live comfortably with a
secure system (though they did not make life any easier for
the restricted user).

   The last major advance that occurred in the development
of ZCPR31 resulted from a conversation I had with Bruce
Morgen in July, 1986.  We were discussing the annoying way
that ZEX functioned under shells, with the shell program
being reloaded for each command line, only to realize that
ZEX was running.  It would then feed the next command line
from ZEX to the multiple command line buffer.  I conceived a
small change in the code that made this problem vanish in a
flash.


                           ZCPR33

   At the very end of January, 1987, I got a call from
Echelon.  Richard Conn had decided to discontinue his
involvement with ZCPR3, and Echelon asked if I would be
willing to write the official ZCPR version 3.3 release based
on the experimental ZCPR31.  I agreed.  During the months of
February, March, and April of 1987 an enormous amount of
additional development took place, the results of which are
described in detail in the "ZCPR33 User Guide."  Only some
key concepts will be mentioned here.

   Once again, the decision was made no longer to make any
attempt to support 8080/8085 computers.  The code was
written using Zilog mnemonics, and extensive use was made of
Z80-specific instructions, including relative jumps, block
moves, block searches, direct word transfers to register
pairs other than HL, 16-bit subtractions, and the alternate
register set.  This approach has continued to the current
ZCPR34.  To my knowledge, no one has even tried to make an
8080 version; there just are not many of those machines
still in operation.

   One of the nicest features introduced with ZCPR33 was the
automatic installation of programs.  Until this point,
before a ZCPR-aware program could be used, it had to be "installed" for the specific system configuration.  If one
forgot to do this, the program would likely behave in
bizarre ways, and this was a very common source of
difficulty for new and experienced users alike.

   In ZCPR2 installation was a very elaborate procedure in
which a large block of code had to be patched using the
special GENINS utility.  With ZCPR3 the information about
the system configuration was placed in a memory buffer
(called the environment or ENV) where all programs could
access it.  More importantly, the system configuration could
be changed without reinstalling all the programs.  Now
installation amounted only to patching the ENV address into
the program.

   As soon as I heard that Richard Conn had figured out a
way to eliminate this annoying installation step, the
solution became obvious to me as well.  Since the command
processor already loads a program from disk, and since it
already knows the ENV address, why couldn't it install the
address directly into the memory image of the program? 
That's just what it does.

   One truly revolutionary concept was introduced with
ZCPR33.  Until that time, all CP/M transient programs were
loaded to and ran at a standard address, 100H.  With CP/M
there was no reason to do otherwise, but with ZCPR3 there
was.  From the time of ZCPR1, I had become quite accustomed
to using the GO command to rerun the previous program.  To
my puzzlement, GO sometimes produced bizarre results under
ZCPR3.

   Under CP/M, programs get loaded only when the user
instructs the system to run them.  Under ZCPR3, however,
there are quite a few programs that are loaded and executed
automatically by the command processor.  These include
extended command processors, error handlers, shells, and
transient (COM) versions of otherwise resident commands,
such as ERA or REN.  Sometimes, using the GO command
resulted in rerunning these programs instead of the last
program the user specified.

   One day as I was working on the ZCPR33 code, I noticed
that a trivial change would allow the command processor to
load a file to an address other than 100H.  This, I
realized, could overcome the problems with the GO command. 
User programs could be loaded, as usual, to 100H, but
programs invoked automatically by the command processor
could be loaded to a higher address, such as 8000H.  User
programs in low memory would not be overwritten, and the GO
command would still be able to rerun them.

   One more group of major innovations was introduced with
ZCPR33.  ZCPR30 provided a number of security features that
made it particularly suitable for use on a remote access
system (BBS).  The so-called wheel byte could be used to
control access to both resident and transient programs. 
Dynamically changeable limits on the range of drives and
user numbers and named directories with passwords could keep
callers out of certain disk areas.

   This security made it possible to allow remote users to
run a system directly from the command line prompt, in sharp
contrast to MS-DOS remote systems, where a user who gets to
the command prompt has free reign to access or destroy any
part of the system.

   The security system under ZCPR30, while fully effective,
however, could be an unnecessary nuisance.  For example,
there could be situations where a user could access a
directory area by name, because it had no password, but not
by drive/user value, because they exceeded the allowed
range.  Under ZCPR33, if a directory is accessible by name,
then it could also be accessed by drive/user.


                          ZCPR34

   The current state of the art of the ZCPR command
processor is version 3.4.  It was first released some time
around March of 1988 along with NZCOM and Z3PLUS and was
described in issue 32 of TCJ.  Relative to Z33 it was an
evolutionary advance, a refinement; there were no radical
new ideas, as there had been in Z33.  Nevertheless, the
changes were significant and useful.  There have been
several minor revisions since the original release.

   One change introduced with ZCPR34 was an extended
environment descriptor.  We removed some information that
had proved to be of little use and added new information. 
The most important addition was a drive vector word.  The
ENV always had a max-drive byte that specified the highest
letter drive available on the system.  However, this was not
adequate for systems that had drives that were not
contiguous, such a A:, B:, and E:.  The new drive vector
tells exactly which drives are available for use at any
time.

   The new ENV also contains the addresses of the CCP, BDOS,
and BIOS and the sizes of the first two.  This is to prepare
us for some future enhancements in which we will not
necessarily adhere to the standard component sizes that were
specified in the original CP/M.  Hal Bower and Cam Cotrill,
as part of the development of a new banked version of ZSDOS
(which is nearing release), have been experimenting with a
CCP that is larger than the usual 2K and a banked DOS that
will be significantly smaller than the standard 3.5K.

   I mentioned earlier that ZCPR33 had rationalized the
implementation of directory security so that any area
accessible by name would also be accessible by drive/user,
even if the drive or user exceeded the limit set in the
environment.  With ZCPR34 the symmetry was completed.  Now
if there is a password-protected directory that could be
accessed freely using the DU: format, then its password will
be ignored.  Now there will never be directory areas that
can be accessed in one way but not the other.

   The extended command processor interface was liberalized
so that commands that would formerly have been considered
illegal and processed immediately as errors, such as those
with wildcard characters ('?' or '*') or with an explicit
file type, can be passed to the ECP.  For example, the
ALIAS.CMD file that defines aliases for the ARUNZ extended
command processor can now have an entry for the command '?'
that invokes the program HELP.

   The most significant advance in ZCPR34 was support for
what we now call a type-4 program.  Type-3 programs, as we
described earlier, are loaded and run at an address other
than 100H, but the address is still fixed at the time the
program is compiled.  It was clear to me at the time I wrote
Z33 that it would be ideal if the load/run address of a
program could be determined dynamically (that is, at the
time it is loaded by the CCP).  However, I opted for the
very simple code that sufficed for handling the type-3
program.

   Joe Wright was not satisfied with that compromise and
soon wrote an initial implementation of a type-4 program,
which would relocate the code automatically to the top of
free memory.  With a lot of cooperation between us, we honed
the approach to the point where it functioned very nicely
and did not add much code to the command processor.

   The secret to this lay in Joe's use of what is called a
PRL (page relocatable) program for the executable file.  The
details of this are described in TCJ issue 32.  The standard
PRL file begins with two 128-byte header records, and I
suggested placing the code required to calculate the proper
load address and the code to perform the address relocation
in these header records rather than in the command processor
itself.  Joe found a brilliant way to implement this.

   Not only did this approach keep the CCP code shorter, it
also made the whole type-4 program more flexible by making
it independent of the command processor.  My next TCJ column
will introduce the first examples of alternative versions of
the type-4 loader routines that are placed in the PRL
header.  These new headers can be installed by the user in
any existing type-4 program to change the way the program
relocates itself.  This is another example of the beauty of
the modular approach that has been one of the hallmarks of
ZCPR.

   My next column will also introduce the latest revision of
ZCPR34, version 3.4E.  Howard Goldstein prepared this
version by integrating a number of ideas, most notably a
small change in the type-4 loader code to make it even more
flexible than it was originally.

   So, after ten years, an eternity in the computer
industry, ZCPR -- the concept Richard Conn initiated -- is
still developing and still challenging the creativity of
users and programmers alike.  As always, these developments
arise from the cooperation of a large community of people
willing and eager to share ideas.
                                                                                               