                                  TCJ40

> [Note to Art Carlson and others reading this file: The lines
> beginning with a control-F are formatting commands for my PMATE text
> editor.  They should be dropped from the text after the text has
> been reformatted for publication.  PMATE handles formatting in a
> WordStar-compatible way except for hyphens at line breaks (they
> have their high bit set, just as soft returns do).  For readers of
> this file who want to print it, running the text through one of the
> high bit filters should fix those lines up.]

R76;set right margin to 76


   For some time I have been planning to discuss issues connected withç
setting up a remote access system (RAS), such as a Z-Node.  There is still aç
great need for new nodes, and I think there are quite a few people toyingç
with the idea of setting one up; they just aren't sure they know how to doç
it.

   In fact, I am going to take up only a very small part of this questionç
here -- and not even the part that would really help someone implement aç
system.  After thinking about it, I realized that I am not the best personç
to talk about the procedures.  I may not even be a good person.  In fact,ç
I'm not even sure that I know any longer how to do it!

   To solve this problem, I am going to try to take the approach I have beenç
taking more and more recently -- recruit someone else to write a TCJç
article.  Specifically, I hope to get the sysop(s) of one or more of theç
newer nodes to document the procedures they went through.  After all, theyç
are the real experts on the subject.  My discussion here will instead coverç
only theoretical issues.  I hope that even those who have no interest inç
setting up their own RAS will find such a discussion interesting.

   As usual, before I get to the main technical topic, I have a number ofç
other matters to cover first.  Here is my list for this issue: Z-Nodeç
update, Z-Helpers, GEnie, and BDS C.


                               Z-Node Update

   It has been three issues since the last update on the Z-Node roster, andç
there have been quite a few changes.  The complete list is reproduced inç
Listing 1.  Many inactive nodes have been dropped, and four new nodes haveç
been added.

   Chris McEwen's Socrates board in New Jersey is now Z-Node #32.  Theç
system is running under NZCOM on a Xerox 16/8 computer.  Besides offeringç
general support to the 8-bit community, Chris is a special resource forç
owners of Xerox computers.  Unfortunately, the recent changes in the Newarkç
outdial of PC-Pursuit have cut ZN32 off from a lot of its regular callers. ç
As a result, Chris has switched to an alternative low-cost data transferç
service called StarLink.

   Briefly, StarLink provides much wider geographical access and fullç
support for 2400 bps connections without the packet-switching delaysç
encountered on PCP.  It is more expensive than PCP at higher monthly usageç
rates but cheaper at lower usage levels.  In the future we want to includeç
in the Z-Node roster the StarLink addresses as well as PCP outdials.  I'dç
appreciate it if anyone with such information would could get it to me usingç
any of the methods indicated in the sidebar to my column.

   The NYOUG (New York Osborne User Group) Fog #15 node (sysop Livingstonç
Hinckley) has become a Z-Node as well, with the same number 15.  The systemç
is running on an Osborne Executive (CP/M-Plus) with the Z3PLUS version of Z-System.  It is, thus, the first Z-Node -- though, I believe, not the firstç
RAS -- to run under Z3PLUS.  The board supports data rates up to 9600 bpsç
using a USR Courier HST modem.

   Dave Trainor in Cincinnati, Ohio, has signed up as Z-Node #7.  His NZCOM-based system has many of the Z-System tools, such as VLU and VFILER,ç
available for use on-line.

   Greg Miner established a new frontier for Z-System as he became Z-Nodeç
#11 in Port Williams, Nova Scotia.  Greg is fairly new to the Z-System butç
has already made a significant contribution as a programmer.  He realizedç
that on properly aliased Z-Systems, a "DIR *.COM" command does not reallyç
indicate to the user the commands that are available.  So, he wrote ADIRç
(Alias DIRectory).  It examines the ALIAS.CMD file, figures out the names ofç
all the ARUNZ aliases (allowing for the multiply named scripts), andç
displays a sorted listing of them.  A very fine program!

   Finally, Ludo VanHemelryck, with assistance from Michael Broschat, willç
be setting up a new Z-Node in Seattle to replace Norm Gregory's system,ç
which has gone over to MS-DOS.  Recently, while on a business trip toç
Portland, Oregon, I had the pleasure of meeting Ludo and Michael (frankly, Iç
was rather flattered that they were willing to drive all the way down fromç
Seattle), and I think they will do a lot to boost Z-System interest in theç
Seattle area.


============================================================================
R85;set right margin to 85

Listing 1.  Z-Node List

                              Z-Node List #53
                     Sorted by State/Area Code/Exchange


Revised Z-Node list as of May 30, 1989.  An "R" in the left column
indicates a node that has registered with Z Systems Associates.  Report any
changes or corrections to Z-Node Central (#1) or to Jay Sage at Z-Node #3 in
Boston (or by mail to 1435 Centre St., Newton Centre, MA 02159-2469).


  NODE      SYSOP         CITY        STATE  ZIP    RAS Phone      PCP     Verified

Z-Node Central
--------------

R   1 Richard Jacobson  Chicago         IL  60606  312/649-1730  ILCHI/24  05/20/89
R   1 Richard Jacobson  Chicago         IL  60606  312/664-17330 ILCHI/24  05/20/89

Satellite Z-Nodes:
------------------

R   2 Al Hawley         Los Angeles     CA  90056  213/670-9465  CALAN/24  05/20/89
R   9 Roger Warren      San Diego       CA  92109  619/270-3148  CASDI/24  02/01/89
R  66 Dave Vanhorn      Costa Mesa      CA  92696  714/546-5407  CASAN/12  10/30/88
R  81 Robert Cooper     Lancaster       CA  93535  805/949-6404            12/29/88
R  36 Richard Mead      Pasadena        CA  91105  818/799-1632            11/01/88

R  17 Bill Biersdorf	Tampa		FL  33618  813-961-5747  FLTAM/24   (down)
      (node 17 expected to be up beginning of summer)

R   3 Jay Sage          Newton Centre   MA  02159  617/965-7259  MABOS/24  05/20/89

R  32 Chris McEwen	Plainfield	NJ  07080  201-754-9067  NJNEW/24  05/20/89

R  15 Liv Hinckley	Manhattan	NY  10129  212-489-7370  NYNYO/24  05/20/89

R   7 Dave Trainor	Cincinnati	OH  45236  513-791-0401            05/20/89

R  33 Jim Sands         Enid            OK  73703  405/237-9282		   11/01/88
R  58 Kent R. Mason     Oklahoma City   OK  73107  405/943-8638

R   4 Ken Jones         Salem           OR  97305  503/370-7655            09/15/88
   60 Bob Peddicord     Selma           OR  97538  503/597-2852            11/01/88
R   8 Ben Grey          Portland        OR  97229  503/644-4621  ORPOR/12  05/20/89

R   6 Robert Dean       Drexel Hill     PA  19026  215-623-4040  PAPHI/24  05/20/89
R  38 Robert Paddock    Franklin        PA  16323  814/437-5647            11/01/88

R  77 Pat Price         Austin          TX  78745  512/444-8691            10/31/88
R  45 Robert K. Reid    Houston         TX  77088  713/937-8886  TXHOU/24  05/20/89

   10 Ludo VanHemelryck	Seattle		WA  (new node being set up)
R  78 Gar K. Nelson     Olympia         WA  98502  206/943-4842            09/10/88

R  65 Barron McIntire   Cheyenne        WY  82007  307/638-1917            12/12/88

R   5 Christian Poirier Montreal Quebec   H1G 5G5 CANADA  514/324-9031     12/10/88
R  40 Terry Smythe  Winnipeg    Manitoba  R3N 0T2 CANADA  204/832-4593     11/01/88

R  62 Lindsay Allen  Perth, Western AUSTRALIA 6153       61-9-450-0200     12/21/88
   50 Mark Little    Alice Springs, N.T. AUSTRALIA 5750  61-089-528-852

R76;set right margin back to 76
============================================================================


                                 Z-Helpers

   In the early days, getting ZCPR3 installed on a computer was a veryç
arcane process, beyond the capability of most potential users.  Echelon hadç
the wisdom to compile a list of people all over the country (actually aroundç
the world) who were willing to help other users get through the process. ç
These people were called Z-Helpers.

   Today, thanks to NZCOM and Z3PLUS, getting the Z-System installed is veryç
easy.  It's even easy to get started using it, since it can be run just likeç
CP/M.  Taking full advantage of its capabilities, however, is another story. ç
With a richness of function comparable to that of Unix, the Z-System can beç
daunting, but when one remains ignorant of its capabilities, one misses outç
on a lot of its utility and fun.

   In looking over the Z-Helper list that is posted on the Z-Nodes andç
included with the NZCOM and Z3PLUS packages, I realized that this list hasç
not been updated for many, many years, and most of its information isç
obsolete.  It's high time that the list be rebuilt!

   My plan is to discard the current list and start over, keeping only theç
few people I know to be active still.  I would like to expand that listç
greatly.  If you feel that you could be of some assistance to new Z-Systemç
users, please send me a post card or short note with the followingç
information: name and address, voice phone number and hours, EMAILç
addresses, if any (BBSs, GEnie, Compuserve, ARPAnet, BITNET, etc.), specialç
areas of expertise, if any (specific computers, Z3PLUS).  Remember, you doç
not have to be a Z-System know-it-all -- none of us is.  Willingness andç
eagerness to help are the most important qualifications of a Z-Helper, andç
by working with others, you will end up learning a lot yourself.


                           GEnie CP/M Roundtable

   Some of you may have noticed the change in the sidebar to my articleç
listing a GEnie mailbox for me (JAY.SAGE).  GEnie has been making aç
determined effort to provide support to the CP/M community.  Theç
indefatigable Keith Petersen is the main force behind it, and he recruitedç
me several months ago to join the staff as a sysop specializing in the ZCPR3ç
and Z-System areas.

   A system like GEnie offers a significant advantage over individual Z-Nodes: universal connection.  With the Z-Nodes, if you want to leave me aç
message, you have to call one of the Z-Nodes that I call into regularly, andç
then you have to call around again to see if and where I might have left aç
response.  Systems like GEnie and Compuserve offer central communicationç
points readily accessible from most places in the US and Canada (and withç
worldwide access developing rapidly -- Japan is on-line already).

   One of the activities on GEnie is called a real-time conference (RTC), inç
which users can communicate interactively.  These conferences are held onç
many subjects.  The CP/M RTC takes place every Wednesday evening at 10 pmç
eastern time, with the first Wednesday session of each month generally ledç
by me and earmarked for Z-System discussion.  So, if you have questions orç
suggestions that you would like to discuss with me and other Z-System users,ç
please consider joining us on the GEnie RTC.  If you don't already belong toç
GEnie, check BBS systems near you for information on a special GEnie signupç
offering that gives you $20 of free connect time as a new registrant.



                                BDS C Update

   A couple of issues back I announced that a special Z-System version ofç
BDS C would soon be available, and a number of people have been asking meç
about its status.  The standard CP/M version 1.60 of BDS C has beenç
available about a year already, and a working Z-System version is now beingç
sold.  We will probably eventually make a few more changes (such as addingç
support for type-3 program generation).  In that case, everyone who orderedç
the earlier version will be offered an update at a price not to exceed theç
cost of media and shipping.

   Some people have criticized the $90 price, comparing it to Turbo Pascal,ç
which sells for only $60.  What they don't realize is how much more one getsç
with BDS C for the extra $30.  Listing 2 shows the contents of the four DSDDç
diskettes in the release, comprising well over 100 files and more than aç
megabyte of material!

   First there are the core COM files you would expect: the compilerç
(CC.COM), the code generator (CC2.COM), the linker (CLINK.COM), and aç
librarian (CLIB.COM).  CC, CC2, and CLINK come in both standard CP/M and Z-System versions, with separate run-time packages.

   Then there is the stuff that almost no one gives you -- the source code. ç
True, you don't get the source for the core items, but you do get sourceç
code for everything else.  Assembly-language source is included for the run-time package, and C source is provided for the collection of standardç
libraries.  Some of the items are provided only in C source code; you haveç
to compile them to produce COM files configured for your system and tastes. ç
This includes two assemblers -- one that uses Intel mnemonics (CASM) and oneç
that uses Zilog mnemonics (ZCASM) -- and a symbolic debugger (CDB).  Andç
while you don't get the source for CLINK, you do get the source for anotherç
linker, L2, that has even more capability (such as handling code that won'tç
all fit in memory at one time).

   RED, an editor with special hooks into the C error listing, is alsoç
provided, again in source form.  You also get a number of sample programs,ç
ranging from simple ones like CP (copy files) to an implementation of theç
MODEM7 file-transfer protocol (CMODEM.C).  [P.S. If you absolutely andç
irresistibly crave the assembly-language source code to the BDS C coreç
components (for personal use, not resale, of course), they can be purchasedç
as an extra option for $200.]

   Support is another important issue.  Who supports Turbo Pascal?  The sameç
people who when asked about Turbo Modula 2 vigorously deny that they everç
offered such a product at all!  [Alpha Systems, unfortunately, acquired onlyç
the right to sell Turbo Pascal; Borland did not give them the source codeç
and does not allow them to maintain it.]  With BDS C, the situation is quiteç
the opposite.  On page 1 of the BDS C manual, at the top of the page, authorç
Leor Zolman's personal phone number is listed, and he not only invites youç
to call him, day or evening, he actually is happy when you do!

   In short, BDS C is a remarkable product from a remarkable programmer.


============================================================================

Listing 2.  Files that comprise the four DSDD diskettes in the Z version ofç
BDS C (directories captured using the BGii SCREEN command).

XD III  Version 1.2	  Standard BDS C, Version 1.60
Filename.Typ Size K RS  Filename.Typ Size K RS  Filename.Typ Size K RS
-------- --- ------ --  -------- --- ------ --  -------- --- ------ --
CCC     .ASM     34     NOBOOT  .C        2     DEFF2B  .CSM     24
BUILD   .C        6     RM      .C        2     DEFF2C  .CSM      8
CASM    .C       24     STDLIB1 .C        8     WILDEXP .CZ       6
CCONFIG .C       12     STDLIB2 .C        8     CDBUPDAT.DOC      6
CCONFIG2.C        8     STDLIB3 .C        6     FILES   .DOC      4
CDB     .C        6     TAIL    .C        2     CCONFIG .H        2
CHARIO  .C        4     UCASE   .C        2     CDB     .H        4
CLOAD   .C        4     C       .CCC      2     CDB1    .H        2
CMODEM  .C       12     CC      .COM     16     CMODEM  .H        2
CMODEM2 .C        8     CC2     .COM     18     DIO     .H        2
CP      .C        6     CDB     .COM     16     HARDWARE.H        4
DATE    .C        4     CLIB    .COM      6     STDIO   .H        2
DI      .C        4     CLINK   .COM      6     BDS     .LIB      6
DIO     .C       10     DEFF    .CRL     12     READ    .ME       4
L2      .C       26     DEFF2   .CRL      6     C       .SUB      2
LPR     .C        4     DEFF2A  .CSM     20     CASM    .SUB      2
     F  1:  --   48 Files Using   384K (   18K Left)

XD III  Version 1.2	  Standard BDS C, Version 1.60
Filename.Typ Size K RS  Filename.Typ Size K RS  Filename.Typ Size K RS
-------- --- ------ --  -------- --- ------ --  -------- --- ------ --
ATBREAK .C        4     RED3    .C       26     BCD2    .CSM     24
BMATH   .C       22     RED4    .C       20     DASM    .CSM      2
BREAK   .C        4     RED5    .C        4     BUGS    .DOC      2
CDB2    .C        2     RED6    .C        2     CRCK    .DOC      2
CDBCONFG.C        6     RED7    .C        4     BDSCIO  .H        4
COMMAND .C        6     RED8    .C       14     CDB2    .H        4
DEMO1   .C        2     RED9    .C        2     MCONFIG .H        2
LMATH   .C        2     TARGET  .C        4     RED     .H        6
LONG    .C        4     TSTINV  .C        2     RED1    .H        2
PARSE   .C       12     UTIL    .C        2     REDBUF  .H        4
PRINT   .C       10     CRCK    .COM      2     RED-READ.ME       4
RED10   .C       14     RCONFIG .COM     24     CDB2    .OVL     20
RED11   .C       18     CRCKLIST.CRC      4     CRED    .SUB      2
RED12   .C       16     BCD     .CRL     16     L2RED   .SUB      2
RED13   .C        6     DASM    .CRL      2     LRED    .SUB      2
RED14   .C        6     DEFF15  .CRL     10     NULL    .SYM      0
RED2    .C       14     BCD1    .CSM      8
     F  2:  --   50 Files Using   376K (   18K Left)

XD III  Version 1.2	  Special Z-System Files
Filename.Typ Size K RS  Filename.Typ Size K RS  Filename.Typ Size K RS
-------- --- ------ --  -------- --- ------ --  -------- --- ------ --
-BDSZ   .         0     CC2     .COM     18     DEFF2A  .CSM     20
CCC     .ASM     50     CCONFIG .COM     20     DEFF2B  .CSM     24
CP      .C        6     CLINK   .COM      6     ZUTIL   .CSM      2
DI      .C        4     TAIL    .COM      6     STDIO   .H        2
ECH     .C        2     DEFF    .CRL     12     BDS     .LIB      8
TAIL    .C        2     DEFF2   .CRL      6     READ    .ME      18
WILDEXP .C        8     DEFF3   .CRL      4     CASM    .SUB      2
C       .CCC      4     TAIL    .CRL      2     NDEFF2  .SUB      2
CC      .COM     16
     F  1:  --   25 Files Using   244K (  420K Left)

XD III  Version 1.2	  Zilog-Mnemonic Version of Assembler
Filename.Typ Size K RS  Filename.Typ Size K RS  Filename.Typ Size K RS
-------- --- ------ --  -------- --- ------ --  -------- --- ------ --
-ZCASM  .         0     ZCASM   .DOC      8     READ    .ME       2
ZCASM   .C       24     --READ--.ME       2     ZCASM   .SUB      2
ZCASM   .COM     18
     F  2:  --    7 Files Using    56K (  420K Left)

============================================================================


                           Remote Access Systems

   I had hoped by now to have gone through the process of completelyç
revamping the RAS software on my Z-Node.  It has been many years since Iç
designed that system, and I really do not remember all the details of what Iç
went through.  Being the sort I am, I made a great number of customç
modifications to all the programs, and, as a result, I have been stuck usingç
old versions of everything.  I use a derivative of BYE503 when the latestç
version is BYE520; I run a modified KMD09 when KMD has not only advanced toç
a much higher version number but has really been superceded by Robertç
Kramer's excellent ZMD.  Admittedly, I already incorporated a number of theç
improvements that these versions offer; nevertheless, my node is quiteç
outmoded.

   With the TCJ column as an excuse to look into all these new developments,ç
I thought I would be able to modernize Z-Node #3 and be able to tell you howç
to go about creating a new Z-Node in the easiest possible way.  Alas, asç
usual, I have been too busy with other things.  As I said earlier, I hope toç
get one or more of the new Z-Node sysops to contribute articles to TCJ onç
this subject.

   Since I can't give a prescription for creating a standard remote accessç
system (RAS) using the current software, I will instead discuss some of theç
basic concepts behind a remote access system and the ways in which Z-Systemç
facilities can be used to advantage.  The standard RAS software is designedç
to work under standard CP/M and is far less efficient than it could be.

I/O Redirection

   Once you have a secure Z-System running, as we described last time, theç
next step is to make it possible for the system to be operated via theç
modem.  The standard software that does this is called BYE, and it tracesç
its roots all the way back to the work of Keith Petersen and others from theç
days of Ward Christensen's first remote CP/M (or RCPM) system in the lateç
1970s.

   A great deal of development has occurred since that time, and BYE nowç
provides a rich array of services.  Its essential function, however, is toç
provide redirection of the console input/output functions.  Program input isç
allowed to come not only from the local keyboard but also from the modem;ç
program output is sent not only to the local screen but also to the modem. ç
In this way, either the local operator or the person connected via the modemç
can operate the computer.  With a secure Z-System, this alone would beç
enough for a rudimentary RAS.

   BYE works by installing itself as an RSX, or resident system extension,ç
generally just below the command processor.  It patches the data in page 0ç
of memory (this is where programs find out how to request services from theç
operating system) and in the actual BIOS.  These patches do two things. ç
They protect BYE so that a warmboot will not result in its removal fromç
memory, and they allow BYE to intercept software calls to the BIOS and DOSç
from any running programs.  BYE can then substitute its own additional orç
special functions.

   In a Z-System, the extended character I/O functions of BYE could properlyç
be implemented using an IOP (Input/Output Package).  The IOP is aç
generalization of the concept from early CP/M of the so-called IOBYTE, whichç
was controlled by the STAT command and used to select from a fixed set ofç
I/O devices (up to four possibilities in the case of the console).  Richardç
Conn conceived of the IOP module as a way to handle just the kind of I/Oç
operations needed for a RAS, and his book, "ZCPR3, The Manual," has someç
examples of this.  Alternatively, the BIOS functions could be implementedç
directly in an NZCOM VBIOS (virtual BIOS), which could be loaded as needed.

   Consider the case where the console is an external terminal connected toç
an RS232 serial port.  The standard BIOS CONOUT (console output) functionç
takes the character in register C and sends it to that serial port.  For aç
remote system, the BIOS would send the character first to the terminal'sç
serial port and then to the modem's serial port.

   Similarly, the standard BIOS CONST (console status) function checks theç
terminal's serial port to see if a character has been received.  If so, itç
returns with a nonzero value in register A; otherwise it returns a zeroç
value.  For a remote system, the CONST routine would check both serial portsç
and return a nonzero value if either one has a character ready.  CONINç
(console input) would poll the two serial ports alternately until it got aç
character from one or the other of them.

   Conceptually, this is really all pretty straightforward.  The biggestç
problem is that the code depends on the specific computer hardware, so noç
universal routines can be supplied.  The BYE program has been cleverlyç
designed, like an operating system, with the hardware-specific codeç
separated from the hardware-independent code.  As a result, customizedç
versions of BYE can be assembled easily by putting source code inserts forç
one's specific hardware at designated places in the master file.  There areç
two collections of inserts, one for many computer types and one for manyç
types of real-time clocks (more about this later).

   There are also some fine points about how the console redirection isç
handled.  BYE, of course, knows the difference between the local console andç
the modem and can treat them differently where appropriate.  For example,ç
since modems commonly produce certain noise characters that rarely appear inç
intended input (such as the left curly brace), these can be filtered outç
(i.e., ignored).  Also, some special functions can be assigned to localç
control codes.  For example, pressing control-N at the local console willç
immediately end the callers session (used when the sysop doesn't like what aç
user is doing); on the other hand, control-U removes any connect time limit,ç
and control-A allows special access by turning on the wheel byte (togglingç
it, actually).

   The screen output can likewise be handled differently.  Pressing control-W locally causes a local display of the current caller's name.  Something Iç
added to my version of BYE was a filter that prevents escape sequences fromç
going to the local console.  I allow (encourage) users to take advantage on-line of virtually all Z-System capabilities, including the full-screenç
utilities like ZFILER, ZMANAGER, and VLU.  When I first started to do this,ç
I found that the escape sequences going to the users' terminals sometimesç
did very bad things to my own terminal (the smartest terminals, like theç
Wyse and Televideo models, have the worst problems; they have sequences --ç
that cannot be disabled -- that lock out the keyboard!).  I simply borrowedç
the code used in BYE for the incoming-character filter.

Modem Initialization and Call Detection

   The first real complication we have to face is that the actions describedç
above make sense only after the local modem is in communication with aç
remote modem.  Consequently, BYE has traditionally been given the additionalç
task of initializing the modem and monitoring it for an incoming call.  Aç
'smart modem' (one that processes the Hayes "AT" commands and returns theç
Hayes result codes) is generally assumed, though BYE apparently will workç
with other modems to some extent.

   The standard procedure today for answering calls (unless it has changedç
again since my BYE503) is not, as one might have expected, to set the modemç
to auto-answer mode.  There are some subtle reasons why this is lessç
desirable.  Instead, BYE monitors the modem port for an output string fromç
the modem indicating that it has detected a ring signal.  This string willç
be "RING" if the modem is in verbose mode or "2" if it is in terse mode. ç
BYE then sends the command "ATA" to the modem so that it will answer theç
call.  Then BYE waits for another string that indicates the data rate of theç
connection; in terse mode these are "1" for 300 bps, "5" for 1200 bps, "10"ç
for 2400 bps, and other values for higher speed or error-correcting modems. ç
Finally, the serial port is synchronized to the modem's data rate.

   If no connect indication is received within a prescribed time, BYEç
recycles the modem to make it ready for another call.  Once a connection hasç
been established, BYE generally displays a welcome message, and it may askç
for a password.  Then it loads an initial program, typically the bulletinç
board program.

   The functions we just described do not really have to be handled in BYEç
at all, and TPA could be saved (remember, the BYE code remains resident inç
high memory at all times) if they were performed by a transient program. ç
With a Z-System there is also no need for BYE itself to load a program fileç
into memory.  All it has to do is place a command line into the multipleç
command line buffer.  This requires much less code and is faster and moreç
flexible.  Moreover, the full power of the command processor is available toç
locate and load the program code.  Resident, type-3, and type-4 programs canç
be used.  I modified my BYE to load the simple command line STARTRAS, which,ç
as you probably guessed, is an alias (it can be an ARUNZ alias, in fact). ç
This makes it very easy to make changes and experiment.

Carrier Monitoring

   There is one further function of BYE that cannot easily be performedç
anywhere else.  That is monitoring the carrier-detect line for a loss ofç
connection.  After all, a caller might hang up or become disconnected at anyç
time.  Some special clean-up functions must then be performed.  Theç
currently running program must be aborted, any system maintenance functionsç
performed (such as updating the database of caller information), and theç
modem must be reset and readied for another call.  Without going into anyç
detail, I do want to point out that terminating a running program can beç
tricky, especially if file I/O is in progress.

   Besides detecting when a user disconnects, either voluntarily orç
accidentally, BYE can also enforce a time limit on the caller.  For many ofç
its timing functions, BYE requires a real-time clock.  As I mentionedç
earlier, there is a library of clock inserts that can be installed in theç
BYE source before it is assembled.

   This completes the discussion for this issue.  So far we have touched onç
the BIOS and modem-control functions of BYE; next time I plan to take up theç
DOS services that BYE provides.

                       