TCJ #42

                            The Z-System Corner

                                  Jay Sage


     A number of newer TCJ readers have commented that with this column theyç
feel that they are coming into the middle of a very involved discussion thatç
is hard to catch on to.  Of course, one answer to that problem is for newç
TCJ readers to purchase back issues.  I have been writing this columnç
regularly since issue #25, and I am quite sure that all those back issuesç
are still available.  That solution notwithstanding, it is probably not aç
bad idea to stand back every so often and try to comprehend a largerç
picture.  That is one of the tasks I will undertake this time.

     Detailed technical content will not be forsaken entirely, however,ç
since I regard that as the primary purpose of my column.  At this point, Iç
suspect that I am too much of a Z-System expert to talk about very manyç
topics at a level that is appropriate for beginners.  To serve their needs,ç
I have been very actively soliciting articles from other authors.  In thisç
issue, for example, we have the first of the columns I promised a couple ofç
issues back on how to set up a remote access system (aka bulletin boardç
system) under the NZCOM auto-install version of Z-System.  Lee McEwen (akaç
Chris McEwen) has done a lovely job with that assignment.

     The technical discussion this time will focus on some issues that aroseç
in trying to install ZSDOS or ZDDOS on an SB180 computer with the XBIOSç
enhanced operating system.  Before you say "But I don't have an SB180," letç
me assure you that the techniques have more general applicability.  Theç
specific XBIOS problem is one that has come up often and has been the sourceç
of considerable frustration to XBIOS users.  [They are in good company, byç
the way.  Just as I was finishing this article, I got a call from Bridgerç
Mitchell about this very subject!]  I am only sorry that it took me so longç
to get around to working on it.  Gene Pizzetta, a fellow Bostonian, was theç
squeaky wheel that finally got my attention, and he has contributed a numberç
of his own ideas to the solution.


Announcements

     Before we get down to business, I have, as usual, a few announcementsç
to make.  First I would like to remind readers once again about Billç
Tishey's superb collection of help files for the hundreds of Z-Systemç
programs now available.  Bill can now generate diskettes in many formatsç
besides Apple (using his son's Commodore 128), and he is willing to fillç
your diskettes with the files for only $10.  My column in issue #36 gave theç
following procedure to follow: (1) send enough formatted diskettes (plainlyç
labeled with the format) to hold at least 1000K bytes (up from 800K backç
then); (2) use a reusable disk mailer or enclose a mailer suitable forç
returning the diskettes to you; and (3) enclose a return address label,ç
return postage, and the $10 copying fee.  Bill's address is 8335 Dubbsç
Drive, Severn, MD 21144.  If you prefer (or if you need 96-tpi, 8" SSSD, orç
NorthStar hard-sector formats), you can send the diskettes to me as well.

     Second, I would like to make a special point of calling your attentionç
to the GEnie RoundTable discussions that take place every Wednesday at 10pmç
Eastern time.  The first such session of each month is devoted to Z-System,ç
and I am the moderator, so this is your chance for a real-time dialogue withç
me.  Go to page "685;2" on GEnie and enter "Room 2".

     There are several changes to report in the roster of Z-Nodes. ç
Regrettably, Bob Paddock's node #38 in Franklin, PA, has gone off the air. ç
To offset that loss, however, node #73 in the St. Louis, MO, area has começ
back to life after being down for several years.  Sysop George Allen and co-sysop Walt Stumper would be happy to hear from you at 314-821-1078 (PC-Pursuit MOSLO/24).  The equipment is currently a Xerox 820-II with a 10 Megç
drive, but the sysops hope to expand soon to a 30+ Meg Ampro.

     On the Z-Node front, I am also sorry to report that Z-Node Centralç
(Lillipute) was downed by hardware failures on both computers!  They haveç
been off the air for a couple of months already as I write this, and sysopç
Richard Jacobson has just faced the truth: that it will not be coming back. ç
Ladera Z-Node (#2) in Los Angeles will take over as Z-Node Central.  Chicagoç
area callers looking for Z support should check out the Antelope Freewayç
system run by ZDOS-coauthor Carson Wilson for CFOG (Chicago area FOG).  Thisç
is one of a small number of remote access systems running under the Z3PLUSç
flavor of Z-System.  The phone number is 312-764-5152 (PC-Pursuit ILCHI/24). ç
We expect that its 'System One' will soon be a Z-Node ('System Two' supportsç
MS-DOS).

     Finally, there have been some very significant developments with BDS C. ç
Leor Zolman completed some major additions to the Z version (BDS Z), and theç
final release has just gone out as I write this column in mid October. ç
Programs generated by BDS Z now have a full Z-System header and can beç
linked as type-3 programs to load and run at an arbitrary address.  ZDOSç
coauthor Cam Cotrill has already released a substantial amount of BDS Z codeç
for performing the functions in the SYSLIB, VLIB, and Z3LIB assembly-language libraries that are not already built into BDS Z.

     Leor has now turned over all of the marketing and some of theç
development responsibility for BDS C to me.  Recognizing that the $90 priceç
tag of the full package, however reasonable for what one gets, is anç
impediment to new users who want to experiment with C, we have prepared aç
low cost introductory package that (1) includes only one version of the codeç
(either standard CP/M or Z-System), (2) contains only the essential files,ç
and (3) comes with an abridged version of the manual (and without the fancyç
BD Software binder).  This package will be offered for only $60.  Otherç
parts of the full package can be added later: $25 for the second version ofç
the compiler, $25 for the support materials (RED editor, CDB debugger, andç
the parts of the manual covering them), or $40 for both at once.  If theç
whole package is ordered at once, it comes complete with an attractiveç
binder (also available with the introductory package for $5 extra).

     It should be noted that BDS Z generates programs that run perfectlyç
well under standard CP/M.  Naturally, they will not recognize Z-Systemç
features like named directories, but they will accept the now standard DU:ç
extended drive/user syntax instead of the older U/D: format of standard BDSç
C.  The only disadvantage of using BDS Z rather than BDS C on a standardç
CP/M system is that the programs carry Z-System overhead (about 800 bytes)ç
that don't provide them with any functionality.


               What is a Microcomputer Operating System For?

     The basic function of an operating system is to make one's life --ç
one's computing life, that is -- simpler.  When microcomputers first cameç
out, the biggest burden was dealing with the hardware.  It was no fun forç
the computer user and programmer (largely synonymous in those days) to haveç
to deal over and over with the intricacies of the physical operation of theç
hardware, such as getting characters to and from the terminal or paper tapeç
reader/punch, not to mention the dauntingly more complex task of managingç
data on a magnetic tape or floppy diskette drive.

     Gary Kildall's CP/M operating system provided a solution -- and a veryç
good one (by and large) in my opinion -- to those problems.  It did so byç
implementing a standardized and modular interface that handled the basicç
device communication tasks.  CP/M, which stood (I believe) for "Controlç
Program for Microcomputers," was the master program that one got running onç
the computer right after power up.  It would then allow one to load and runç
other programs, with control always returning to the CP/M master programç
after each user program finished.

     Besides accepting and interpreting commands issued by the computerç
operator, an operating system like CP/M also provides resident code (alwaysç
ready in memory) for performing certain functions that application programsç
will often want to use.  The simpler functions are things like sending aç
character to the terminal screen; the more complex ones include fetchingç
from or writing to a floppy diskette the information associated with aç
logical entity known as a file.

     With these functions implemented in the operating system code,ç
application programs are easier to write and do not have to include the sameç
code over and over.  More importantly, they can run on a variety of hardwareç
platforms, since the details of the physical hardware are handled by theç
operating system code, and the program can deal with things at a logicalç
level.


Logical vs. Physical

     Perhaps this is a good time for a brief aside on this matter of logicalç
versus physical.  We use the adjective "physical" when we are talking aboutç
things that are actually in the hardware.  In the case of a floppy disk, forç
example, the physical items are the bits of data stored as magnetizationç
patterns.  These bits are grouped into sectors, and the sectors into tracks. ç
In the case of a terminal screen, the physical items are the patterns ofç
illuminated dots that we recognize as letters, numbers, and other symbols.

     On the other hand, we use the adjective "logical" to describe thoseç
things which are essentially the creation of our minds (and programs).  Forç
example, there is no such physical thing as a "file."  No matter how youç
examine a diskette, you will never find a file on it (as such); you willç
find only sectors and tracks.  It is our choice to organize the data on theç
disk in a way that associates groups of such sectors with a file names andç
to store the file names in a particular group of sectors on the disk.


Modularity

     CP/M is modular in the sense that it divides up the functions of theç
operating system into separate packages.  One part is called the BIOS (basicç
input/output system).  This part, which lives at the very top of the memoryç
address space, deals directly with the hardware.  It reads and writesç
physical sectors from and to a diskette; it determines whether or not a keyç
has been pressed on the keyboard and, if so, which key; and it sendsç
characters to the screen.  The BIOS is the only part of CP/M that isç
different for each hardware implementation of a CP/M computer.

     The second CP/M module is called the BDOS (basic disk operatingç
system).  It deals with logical constructs.  We have already spoken ofç
files.  When a file is referred to, the BDOS figures out which physicalç
tracks and sectors contain the data for that file.  Another logicalç
construct is lines of text.  The BDOS has a function to send a complete lineç
of text to the screen (as opposed to the BIOS, which can send only a singleç
character), and it has another function to get a complete line of text fromç
the user, allowing a limited amount of editing.  These functions make itç
much easier for the application programmer to write his or her program.

     The last CP/M module is called the CCP (console command processor).  Itç
gets a command typed by the user at the console and takes the appropriateç
action to carry out that command.  Some commands, such as DIR or ERA, areç
implemented directly in the CCP code.  Others require that a COM file beç
loaded from diskette and executed.


Command Processing Under CP/M

     For the most part, CP/M accomplishes the functions it was designed toç
perform in admirable fashion.  However, it was so concerned with solving theç
hardware interface problem (the programmer interface) that it devotedç
relatively little attention to the user interface.  To be fair, it was bornç
in the days when 16K of memory cost about $500 (in 1970s dollars, no less)ç
and occupied an entire S-100 card (bigger by far than a whole SB180FXç
computer with 512K).  Today we might not think that 64K is very much (someç
say that OS/2 feels dreadfully cramped in less than 3 Megs!), but it makes aç
lot of things possible that 48K (or even less) would not allow.

     CP/M's command processor did little more than the minimum it wasç
required to do, namely to run a few resident commands and to load externalç
commands from disk.  It did not provide many services to make the operator'sç
life easier.  You had to specify rather exactly the command you wantedç
performed; no leeway was allowed.  And if you made a mistake, CP/M did notç
try to help; it just shrugged its shoulders and emitted a question mark.


The Niceties of Z-System

     The Z-System has evolved over a period of nearly a decade now, but itsç
goal from the very beginning has always been to make it easier and moreç
convenient to operate the computer.  My ideal is to have the computer doç
everything that it possibly can do for the user and leave to the user onlyç
those tasks that no computer could possibly figure out on its own.  Theç
command processor improvements I have introduced and the utilities I haveç
written have all been directed toward that goal.  I will now run through aç
short summary of Z-System features and try to indicate how they make theç
operator's life easier.  This list is adapted from my book, "The ZCPR33ç
User's Guide."


User Area Access

     CP/M introduced the concept of disk "user" areas, which allowed theç
operating system to group files into separate logical directoriesç
(physically the files are all stored in the same directory, but they areç
tagged to indicate the user area).  Unfortunately, CP/M provided noç
practical way to access files across user areas, which made them almostç
useless.

     Back in the days when disks held only about 100K, there wasn't muchç
need for this kind of organization, but today floppy diskettes commonly haveç
a capacity between 350K and 1.3 Meg.  Hard disks with many tens of megabytesç
are also inexpensive and common.  Under these circumstances, a singleç
logical drive can hold hundreds or even thousands of files, and some way toç
organize them becomes essential.

     Z-System makes it very easy and convenient to organize your files basedç
on user numbers.  Where CP/M allowed only a drive prefix to a file nameç
(D:NAME.TYP), Z-System allows drive and/or user number prefixesç
(DU:NAME.TYP) so that files in other user areas as well as other drives canç
be referenced directly.  In addition, Z-System allows meaningful namesç
(similar to DOS subdirectory names) to be assigned to drive/user areas. ç
This provides an interface that is far more suitable to the way people thinkç
and remember.  With the DU: form, the operator has to think about theç
hardware (something he or she should not have to do, remember?); with namedç
directories, the operator thinks in terms of function (TEXT: for text files,ç
BDSC: for the C compiler, DBASE: for database files, and so on).


Terminal Independence and the Environment

     While some would argue that the DOS hardware and software standardsç
established by IBM's market dominance have resulted in an enforcedç
mediocrity, there is no doubt that having a single environment in which toç
operate makes life much easier for applications programmers.  Programs forç
DOS generally work right out of the box on any IBM compatible computer. ç
Configuration is required only for fine-tuning.

     CP/M, on the other hand, was designed to allow programs to run on anç
extremely wide variety of hardware.  In those days, "personal" computer tookç
on a different meaning -- each person designed and built his own hardware. ç
CP/M could be made to work with all of them, but elaborate configurationç
procedures were generally required, especially to match programs to theç
particular terminal used.  To this day, we still have to deal with thisç
hardware diversity.

     What CP/M could have but failed to provide was a means for conveying toç
application programs information about the operating environment.  Z-Systemç
has several modules that afford such communication.  An area called theç
environment descriptor (ENV) contains information about the systemç
configuration.  Another system area called the message buffer (MSG) storesç
information that one program can leave for another program that runs laterç
to read.

     Part of the ENV is a section called the TCAP or Terminal-CAPabilityç
descriptor.  The TCAP allows a program running under Z-System to determineç
the type of terminal in use and to adapt to the control codes it uses forç
special video operations.  The ENV has information about the size of theç
screen and the printer's page.  It also contains such information as the CPUç
clock speed and which disk drives are available (why allow attempts to logç
into drive C: if there is no drive C: -- it often just hangs the computer). ç
The Z-System supports many optional operating system features contained inç
optional modules, and the ENV contains information about these modules also.

     The ENV and TCAP not only relieve the user of the nuisance ofç
installing programs; they also make it very easy to change the installation. ç
Suppose, for example, you want to print some files in 132-column modeç
instead of the usual 80-column mode.  Under CP/M you might very likely haveç
to get out a configuration program to redefine the printer setup.  With a Z≠
System print utility, you would simply change the mode on your printer, runç
CPSET (console/printer set) to select the 132-column printer definition, andç
run the same print program as before.


Command Processing Enhancements

     Under CP/M, you have to specify where the COM file to be run is locatedç
(otherwise the current drive is assumed).  This is a perfect example ofç
something that a computer can easily be smart enough to do for you, and Z≠
System does.  As with modern versions of DOS (which took many years to catchç
on to this Z-System feature), you specify a list of directory areas that theç
operating system will scan for a requested COM file.  If you wish (as youç
might when you know that your COM file is not on the search path), you canç
specify a directory using either the DU: prefix or the named directory DIR:ç
prefix, and you are thus not limited to the current user area or the path.

     With Z-System one is also no longer limited to issuing commands one atç
a time (DOS has been even slower to catch on to this).  A single line ofç
command input can contain a whole sequence of commands.  As a result, you doç
not have to interrupt your thinking to wait for one command to finish beforeç
you can specify the second and subsequent steps in a process.  You can workç
out a strategy for what you want to accomplish and issue all the commands atç
once, before you forget or get confused.

     Many oft-repeated computational tasks involve sequences of commandsç
(e.g., editing, assembling, linking, running; or editing, spell checking,ç
printing).  In such cases, the Z-System alias facility (similar in some waysç
to SUBMIT but far more flexible) can be used to define a new command name,ç
which, when invoked, performs the entire sequence.  This saves the user aç
lot of typing but more importantly eliminates the need to remember exactlyç
what the sequence is.  Basically, you solve the problem once and put theç
solution into an alias script.  From then on, the computer is smart enoughç
to take care of the complex details for you.  I have given many examples ofç
this in past columns.


Conditional Command Execution

     There is only so much one can accomplish on a computer (or in life)ç
without making decisions.  Have you ever seen a programming language with noç
ability to perform tests and act in different ways depending on the results? ç
Flow control (IF/ELSE/ENDIF) is unique to the Z-System command processor. ç
Other operating systems that offer flow control at all limit it to operationç
inside a batch or script language.

     A special set of Z-System commands can test a wide range of conditions,ç
and the command processor will use the results of the tests to decide whichç
subsequent commands will be performed and which will be skipped.  Thisç
allows the Z-System to respond in a remarkably flexible and intelligent way. ç
The solution to a complex computing task, one that requires on-the-spotç
decision-making, can be worked out once and embedded in an alias command. ç
Then you won't have to tax your brain the next time you need to perform thisç
task, and novice users will be able to do things on your computer that wouldç
have been beyond their own ability to figure out.


Command Processor Shells

     If you do not want to deal with the operating system at the commandç
level or if you want to have a command processor with different features,ç
the Z-System shell facility allows you to install substitute user interfacesç
of your own choice at will.  They can even be nested within each other.

     Shells come in two common varieties: menu shells and history shells. ç
The menu interfaces allow the user to pick tasks with single keystrokes andç
have the shell program generate the complex sequences of commands requiredç
to perform those tasks.  The menu system shields the user from complexity,ç
saves typing, and greatly reduces the chance of error.

     History shells are enhanced command processors that remember yourç
commands and allow you to recall and edit previous command lines.  I wishç
the Apollo Domain minicomputer system I use at work (not to mention my DOSç
computer) had a history shell one quarter as nice as Z-System's LSH or EASE. ç
They work like powerful wordprocessors on your command history, allowingç
searching and extensive editing.


What If You Make a Mistake

     This is one of the other areas in which most operating systems behaveç
in an abominably primitive manner.  When you issue a command that cannot beç
performed, they just issue an error message and then dump you back to squareç
one.  Often you are not even told what sort of error occurred (considerç
DOS's wonderfully helpful "bad command" message).

     The Z-System behaves in a civilized manner under these circumstances. ç
When an error occurs, the command processor turns the bad command line overç
to a user-specified error handler.  The most sophisticated error handlersç
allow the operator to edit the command and thus recover easily from typingç
mistakes.  In a multiple command sequence, if subsequent commands wereç
allowed to run after an earlier command failed, there could be disastrousç
repercussions, and an error handler is indispensible.

     The system environment even contains an error type, which the errorç
handler can use to give you more specific information about what went wrong. ç
It may be the familiar error of a COM file that could not be found, butç
there are many other possible causes for the difficulty.  A file that youç
specified as an argument might not have been found (e.g., "TYPE FILENAM"ç
when you meant "TYPE FILENAME"), or you may have specified an ambiguous fileç
name to a program that cannot accept one (e.g., "TYPE *.DOC").


System Security

     Like minicomputer and mainframe operating systems, the Z-System is aç
secure operating system.  This means that it has mechanisms for limitingç
what any particular user can do or get access to.  Dangerous commands (suchç
as erasing, copying, or renaming files) can be disabled when ordinary usersç
are operating the system but enabled when a privileged user is at work. ç
Areas of your disk can be restricted from access for storage of confidentialç
or other sensitive information.  These security features come in very handyç
in the implementation of a remote access system or bulletin board (see Leeç
McEwen's article in this issue).  There is no need for additional securityç
to be provided by the remote interface program (BYE).  The Z-System alreadyç
includes a full suite of programs for regulating and controlling systemç
security.


Summary

     To sum it up, the goal of the Z-System is to provide an operatingç
system that can be tailored extensively to user preferences and that can beç
made to handle on its own and automatically as many computational details asç
it can, leaving the user free to concentrate solely on those aspects ofç
computer operation that require human intelligence.

                           Faking Out The System

     For the technical part of this column, I would like to talk brieflyç
about some techniques for adding extensions to a Z-System that it was notç
designed to accept.  The need for this trick arose in connection with theç
installation of ZSDOS and ZDDOS (and their clock drivers) on an SB180ç
computer with the XBIOS enhanced BIOS, but it can be useful in otherç
situations as well.

     XBIOS is a very nice and flexible system.  One of its main features isç
that it keeps much of the BIOS in an alternate memory bank, leaving a muchç
larger TPA (transient program area) for application programs than did theç
standard BIOS from MicroMint.  The configuration and loading process,ç
however, is somewhat unconventional (a forerunner in some ways to the NZCOMç
and Z3PLUS techniques).

     The XBIOS system is loaded not from system tracks on the disk but fromç
a file.  This file is generated by a special utility program called SYSBLDç
(SYStem BuiLD) that allows one to define in a rather flexible way theç
configuration of one's personal Z-System, including the names of the CCP andç
DOS files to be used.  Those component files, however, must be available inç
REL format, and the new Z-System DOS components are supplied in ZRL formatç
only (because they have hooks to other parts of the system that can beç
resolved only by that format).


Changing Systems Using JetLDR

     JetLDR is a lovely little utility written by Bridger Mitchell thatç
knows how to load almost any module in a Z operating system.  It is muchç
faster and more careful than its predecessors, LDR and LLDR, and it is notç
limited to the non-code Z modules -- such as the NDR (named directoryç
register) -- or to code modules preassembled for a fixed system -- such asç
an RCP (resident command package) module FIXED.RCP.  It can load codeç
modules assembled in ZRL format to whatever address that module occupies inç
the current system and with all the hooks to other Z-System modulesç
generated at load time.  Thus MYRCP.ZRL, assembled once, can be used in anyç
system configuration that allocates enough room for an RCP of that size.

     Most remarkably, JetLDR can load even main operating system modules:ç
CCP, DOS, or BIOS.  Special adjunct configuration files (CFG) are used toç
help it in some of these specialized tasks (a little more about that later). ç
JetLDR's internal help screen is reproduced in Fig. 1 so you can see theç
whole list of modules it can handle.  It is available from the usual Zç
suppliers for $20.

     So, the obvious solution to the problem of getting ZSDOS or ZDDOSç
running under XBIOS is first to generate and boot a standard ZRDOS systemç
(ZRDOS.REL comes with the SB180) and then to replace ZRDOS with, say, ZDDOSç
using the JetLDR command:

	JETLDR ZDDOS.ZRL

ZSDOS can be loaded just as easily.  On my system I have ARUNZ aliases thatç
swap DOSs in a jiffy this way in case I want to perform some experiments.


There's The Rub

     Now comes the problem.  It's very nice that we now have ZDDOS or ZSDOSç
loaded and running, but if we want to take advantage of its wonderful timeç
and date features, we must find a way to load its clock and (for ZSDOS)ç
stamping module, too.  The ZDOS utility SETUPZST makes it very easy toç
create the required loader, LDTIM.COM; the problem is: where can LDTIM putç
the driver code?  [Aside: For those who own it, I am told that theç
DateStamper BSX module will work with ZSDOS, but I have not tried thisç
myself.  It requires no memory to load.]

     In an NZCOM system, the MKZCM system definition utility allows one toç
specify a "user buffer" area in memory, and this is just perfect for theç
clock/stamp module.  ZDOS even has special facilities for taking advantageç
of this buffer.  LDTIM can automatically determine the location of thatç
buffer and install the drivers there, and a special patch to NZCOM (includedç
with the ZDOS package) gives NZCOM the ability to reconnect the driversç
automatically after a new DOS is loaded.

     XBIOS's SYSBLD utility, unfortunately, does not support such a userç
buffer (this is true even in the 1.2 version that is able to load ZRLç
files).  There is a way to trick the system into making some room for extraç
memory modules.  This is to assign the extra memory space needed to one ofç
the standard modules, such as the RCP.  For example, if you use an RCP ofç
the usual 2K (16 record) size and need one page (two records) of memory forç
a ZDDOS clock driver, you simply specify an 18-record RCP space.  Then, whenç
SETUPZST asks you for the address to which the clock driver should beç
loaded, you give it the starting address of the last page of this RCP space.

     Once these steps have been followed, ZDDOS should be running with dateç
stamping.  ZSDOS could be installed similarly except that even more extraç
space would have to be allocated to the RCP.  Although what I have describedç
so far will get the system running, there is some danger that an oversizeç
RCP could be loaded by accident and overwrite the clock driver.  To preventç
this, the ENV module should be patched to indicate that only the actual 16ç
records (10H) are available.

     For those who do not face the problem of installing ZDOS on an XBIOS≠
equipped SB180, there are other uses of this kind of trick.  For people whoç
do not have the necessary tools (e.g., MOVCPM) to move the BIOS down to makeç
room for special drivers (such as RAM disk drivers and special I/O boards),ç
this same trick can be applied to open up protected-memory space for them. ç
Other people may find it useful for quick experiments with special driversç
before going to the trouble of moving the operating system around.

     There is one final refinement I would like to mention.  It is somethingç
I learned from Gene Pizzetta, who took my general recommendations above andç
worked out the details (see his file, ZD-XB11.LBR, available on many Z≠
Nodes).  I have usually used either the IOP or RCP modules for this trick,ç
but Gene recommended using the NDR instead.  The reason for this is that theç
IOP, RCP, and FCP get allocated in 128-byte chunks, while the NDR getsç
allocated in much smaller 18-byte chunks, the space required for one name. ç
If your clock driver takes, for example, 270 bytes (10EH), you would have toç
allocate three extra records, because the driver is a tiny bit over twoç
records.  If you steal space from an NDR, you can add just two records, butç
reduce the number of names in the NDR by 1.


Changing Command Processors

     Generating a new CCP using JetLDR is a little trickier than changingç
the DOS.  JetLDR could, as it does with a DOS or BIOS module, load the newç
CCP into its operating position in memory, but this would be of questionableç
value, since the CCP would survive only until the next warmboot.  So,ç
instead, when processing a CCP ZRL module, JetLDR normally writes theç
resulting absolute-code CCP to a file ZCCP.CCP (in the root directory, Iç
believe).

     This is where CFG files come into play.  They are special code modulesç
that JetLDR uses to perform special processing (see the file JLTOOLS.LBR onç
Z-Nodes for more detailed information).  For example, CCPCFG.ZRL is one thatç
tells JetLDR how to deposit the absolute CCP code that it generates directlyç
into the XBIOS ram image of the CCP in banked memory (from which it isç
loaded on each warm boot).  A similar CFG file could be written to tellç
JetLDR how to install the new CCP onto the system tracks of the currentç
drive-A disk, but so far no one has done this.  I would be happy to provideç
the CCPCFG module to XBIOS owners who would like it or to others who wouldç
like to use it as a model for writing other CFG files (send me a formattedç
disk with your copy of JetLDR, return mailer, etc.).

-----------------------------------------------------------------------------

JetLDR for Z-Systems (ZCPR3), Version 1.00
Copyright (c) 1988 Bridger Mitchell

Syntax:
   JetLDR  [du:][library][.lbr]  member1.typ  member2.typ  ...
  or
   JetLDR  [du:]file1.typ  [du:]file2.typ  [du:]file3.typ ...

  ENV - environment                FCP - flow commands
  IOP - input/output               RCP - resident commands
  NDR - named directories          Z3T - terminal capabilities
  ZRL or REL - module in SLR or MS-relocatable (REL) format
      with member name: RCP, FCP, IOP, CCP, CP3, DOS, DO3, BIO, CFG or BSX

Notes:
  If first file is a library, extract remaining files from it.
  An ENV file must be the first loaded.
  Preceed special modules (DOS, RSX, BSX, ...) with appropriate CFG file.

Use Path: YES   Root Only: NO   Scan Current: YES   Explicit Directory: A0:

                         -------------------------

Figure 1.  This is the internal help screen displayed by the command
"JETLDR //".  It shows how flexible a package loader JetLDR is.

-----------------------------------------------------------------------------

                             