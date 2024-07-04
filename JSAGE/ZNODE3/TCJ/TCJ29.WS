
                              The ZCPR3 Corner

                                  Jay Sage



     One of the problems with writing a column for a magazine that onlyç
appears every two months or so is that so many things can happen betweenç
when one column is written and the next one is published.  (Of course, thereç
would be other, insurmountable problems if I had to turn out these columnsç
every month, so I am not complaining.)  At the end of the last article, Iç
mentioned that ZCPR33 would probably be out by the time that issue appeared. ç
Indeed, that was true.  What I did not write, because no public announcementç
had been made yet, was that I had joined the Echelon team and would be theç
author of that version.  So I am now wearing two hats, one as ZSIG softwareç
librarian and one as the Echelon team member in charge of command processorç
development.  Richard Conn has gone off to do more esoteric things.  Inç
recognition of this change, I have broadened the title of this column.



                              ZCPR Version 3.3


     Since ZCPR33, or Z33 as I will call it for short, is too exciting aç
subject to pass up, I will say a few words about it before continuing theç
discussion we began last time of techniques for customizing Z-COM.  I willç
not say too much, however, since a lot of effort already went into preparingç
the 60-page "ZCPR33 User Guide."  It has all the details and is availableç
from either Echelon or Sage Microsystems East for $15 plus shipping ($3 fromç
SME).  Since the code, as in the past, is still available free of charge forç
personal, noncommercial use, sale of the manual is the only way other thanç
OEM sales that we get any compensation for the enormous amount of effortç
that went into Z33.  I will talk this time only about the design goals forç
Z33, and perhaps in future columns I will talk about some of the newç
features and capabilities.

Design Goals
------------

     In developing Z33, I tried to achieve five things (the number keepsç
growing every time it think about it).  (1) I have tried to maintain a veryç
high level of compatibility; (2) I have tried to increase flexibility,ç
control, and speed; (3) I have tried to make the code rigorous and reliable;ç
(4) I have tried to make more information about the internal state of theç
command processor accessible to user programs; and (5) I have tried to makeç
the code readable and educational.

     To the greatest extent reasonable, I have maintained compatibilityç
between Z30 and Z33.  No change need be made to any part of the operatingç
system other than the command processor; the Z33 command processor, as Iç
hinted at in the last column, can simply be dropped in wherever the oldç
command processor was, either on the system tracks of the boot disk or inç
the appropriate places in a Z-COM system.  No changes need be made in theç
memory allocations, and the officially released system modules that workedç
with Z30 will work with Z33 as well, though new, more powerful RCP and FCPç
modules were released with Z33 (the 'H' command in the unofficialç
experimental RCP145, because it made direct references to internal addressesç
in the CPR, will not work).  All application programs and almost all utilityç
programs will work unchanged with Z33.  New utility programs have beenç
written to take advantage of some of the new features in Z33.

     Many features of ZCPR3 -- such as automatic path searching for COMç
files, extended command processing, and error handling -- are veryç
convenient but can significantly slow system response.  With Z33, the userç
is given greater control over these features from the command line so thatç
unnecessary operations can be bypassed to save disk activity and time.  Noç
longer does the path automatically include the current directory first.  Theç
user can now, at his option, omit the current directory or include it in anyç
position in the path.  This has a dramatic effect on system speed.  Aç
command entered with a leading slash ("/") is handled directly by theç
extended command processor without wasting time searching the path for a COMç
file.  For systems that take increasing advantage of ARUNZ or other extendedç
command processing, speed is, again, greatly improved.  Programs with whatç
is called a type-3 environment are automatically loaded and executed atç
addresses other than 100H.  By loading error handlers, shells, and extendedç
command processors high in memory, user programs at 100H are left intact andç
can be reinvoked using the GO command.

     The code in Z33 was almost totally rewritten, taking only the basicç
functions from Z30.  Quite a few bugs, some very serious, were corrected,ç
and new algorithms were used for many of the functions.  A great deal ofç
effort was devoted to making the code rigorous.  No longer can a commandç
tail longer than 128 bytes overwrite the program code and crash the system. ç
No longer can command lines in SUBMIT files write beyond the end of theç
command line buffer.  The root path and minimum path features now workç
correctly, so that duplicated elements in the search path do not have to beç
searched more than once.  Extended command processing functions reliably andç
in combination with error handling.

     The Z33 command processor makes much more information available aboutç
its operation.  In Z30, only COM files that could not be found would invokeç
error handling.  Z33 traps many different kinds of errors, and it can reportç
the nature of the error to the user.  Some examples are TPA overflow, diskç
full, bad numerical expression, incorrect password, bad directoryç
specification, or ambiguous file specification.  Z33 even makes it possibleç
for user programs and routines in the resident command package to invokeç
error handling and to report the type of error.  When Z30 parsed a fileç
expression that specified an invalid directory, it simply substituted theç
current directory, but the program had no way to tell that this had beenç
done.  Z33 sets a flag to indicate the error.  With Z33, a program can tellç
where on the search path it was actually found.  This can be valuable forç
shells and error handlers that install themselves into the system.  They canç
operate faster if they know where they are located.

     Finally, the source code has been completely reorganized and veryç
extensively commented.  I did this not only to make it easier for me toç
maintain it but also so that others could read it to learn how the commandç
processor works.  One of the main reasons why many of us hobbyists remainç
involved in the 8-bit world is that a Z80 can be comprehended fairly easilyç
and can thus be used to learn deeply about the operation of a computer.  Z33ç
is designed to contribute to this.




                        Advanced Z-COM Customization


     In our discussion last time we described what Z-COM is and how itç
works, and we presented a number of techniques for carrying out simpleç
modifications that did not alter the basic structure of the Z-COM system. ç
This time we will examine some much more far-reaching modifications,ç
including those that involve changing the way Z-COM operates.  The goal isç
to develop techniques that will permit us to use the basic principles behindç
Z-COM to build arbitrary systems of our choice.  I do want to warn you: aç
good part of this discussion will be at an advanced technical level.  Even Iç
feel rather mentally exhausted after going through the process of developingç
it and writing it down.  If any one section is getting too technical forç
you, please do not give up completely.  Skip ahead to each new section andç
read the introductory philosophical comments.  There is material there thatç
I would really like everyone to see.


When Z-COM Will Not Work
------------------------

     Before launching into the heavy code patching, I would like to cover aç
topic that probably should have been included last time: why Z-COM will notç
work in all systems or will not work fully.

     There are two circumstances that I have experienced in which Z-COMç
interferes with the proper operation of a system.  One class of difficultiesç
arises when the system uses utilities that make modifications to theç
operating system image in memory.  Such utilities always invite disaster,ç
but they are nevertheless quite common (partly because they are so useful). ç
If the utilities calculate the addresses to change from the BIOS warmbootç
address at location 0001, then there will be trouble, because that addressç
points to the virtual BIOS set up by Z-COM and not to the real BIOS.

     The Ampro BIOS, for example, has a number of special structures inç
defined locations with respect to the beginning of the BIOS.  Some of these,ç
for example, support the various configuration options.  Since these optionsç
are rarely changed except when the system is first assembled or when newç
hardware is added, one can overcome any problem by running the utilitiesç
when Z-COM is not in operation.  Other BIOS structures are used to defineç
the alternative disk formats.  These one might want to change during aç
session at the computer.  Although it is inconvenient, one could again exitç
from Z-COM using ZCX, change the disk format, and then reenter Z-COM.  Ofç
course, a conventionally installed ZCPR system is available for the Ampro soç
that Z-COM is not necessary.  However, a number of other computers runningç
standard CP/M 2.2 use similar techniques and have similar utilities.

     The second class of difficulties arises when the BIOS warmboot codeç
performs some indispensable function.  Remember that when Z-COM is running,ç
the warm boot is intercepted, and the warmboot code in the original BIOSç
does not run.  My BigBoard I with the double-density upgrade automaticallyç
selects from a large number of disk formats.  One simply puts the disketteç
with the new format into the drive and presses control-c.  The warmboot codeç
in the BIOS includes code for determining the format of the diskette.  Whenç
Z-COM is running, I often experience problems when I try to log in a newç
drive for the first time or when I try changing disk formats.  The troubleç
seems to have to do with the way the BIOS keeps track of what drives areç
logged in, and by using disk resets or control-c's from Z-COM, I can oftenç
get the system to work.  But clearly there can be problems when the BIOSç
warmboot code is completely by-passed.


More Named Directories
----------------------

     To get our feet wet again with Z-COM patching, let's start with aç
relatively simple but very practical example.  The most frequent request Iç
get from users of Z-COM, especially those using it to make a remote accessç
system, is for a way to increase the number of named directories.

     To refresh our memories, I have reproduced in Fig. 1 the memory map ofç
our unmodified Z-COM system.  Those of you who are really sharp (or haveç
photographic memories or are cheating by actually looking at the last issue)ç
will notice that this is not exactly the same as the map presented last timeç
as Fig. 2.  The reason for this is that I recently was offered a deal that Iç
simply could not refuse on a hard-disk Televideo 803H system (everyç
household needs four complete computer systems, no?).  Since I cannot bearç
to operate a computer without Z-System, I immediately implemented Z-COM onç
it and have been using it as the testbed for the techniques described here. ç
It's BIOS is obviously even less compact than the one on my BigBoard andç
starts 200H lower in memory.  I hope this address switch does not confuseç
you too much, but since your system probably does not match mine anyway, youç
have to get used to translating addresses.  The addresses in the ZC.COMç
image, of course, do not change.


-----------------------------------------------------------------------------

System Component		ZC.COM Address		System Address
----------------		--------------		--------------

  CPR				  0200 - 09FF		  BA00 - C1FF
  ZRDOS				  0A00 - 17FF		  C200 - EFFF
  Virtual BIOS			  1800 - 19FF		  D000 - D1FF
  Named Directory Register	  1A00 - 1AFF		  D200 - D2FF
  Shell Stack			  1B00 - 1B7F		  D300 - D47F
  Z3 Message Buffer		  1B80 - 1BCF		  D380 - D4CF
  External FCB			  1BD0 - 1BF3		  D3D0 - D4F3
  PATH				  1BF4 - 1BFE		  D3F4 - D4FE
  Wheel Byte			  1BFF - 1BFF		  D3FF - D4FF
  Environment Descriptor	  1C00 - 1C7F		  D400 - D47F
  TCAP				  1C80 - 1CFF		  D480 - D4FF
  Multiple Command Line		  1D00 - 1DCF		  D500 - D5CF
  External Stack		  1DD0 - 1DFF		  D5D0 - D5FF
  Resident Command Package	  1E00 - 25FF		  D600 - DDFF
  Flow Control Package		  2600 - 27FF		  DE00 - DFFF
  I/O Package			  2800 - 2DFF		  E000 - E5FF

Fig. 1.  Addresses of system components in the ZC.COM file and in theç
example system for which it was generated (Televideo 803H).

-----------------------------------------------------------------------------

     Now, if we want to have room for more directory names, we have to findç
a way to allocate more memory to the NDR module.  Where can we steal someç
memory?  Unfortunately, the memory cannot be taken from either of theç
neighbors of the NDR.  The virtual BIOS and shell stack are indispensable. ç
That means that we will have to move the NDR or something else from itsç
present position.  The best target for our memory raid is that hulkingç
6-page, 1.5K IOP that often goes unused, especially on remote accessç
systems.  We will cut it down to 3 pages and use the top 3 pages for our newç
NDR, which will have a capacity for 42 names [ (3 * 256 - 1 ) div 18 = 42 ]. ç
The resulting memory map is shown in Fig. 2.

-----------------------------------------------------------------------------

System Component		ZC.COM Address		System Address
----------------		--------------		--------------

  CPR				  0200 - 09FF		  BA00 - C1FF
  ZRDOS				  0A00 - 17FF		  C200 - EFFF
  Virtual BIOS			  1800 - 19FF		  D000 - D1FF
  ( unused space )		  1A00 - 1AFF		  D200 - D2FF
  Shell Stack			  1B00 - 1B7F		  D300 - D47F
  Z3 Message Buffer		  1B80 - 1BCF		  D380 - D4CF
  External FCB			  1BD0 - 1BF3		  D3D0 - D4F3
  PATH				  1BF4 - 1BFE		  D3F4 - D4FE
  Wheel Byte			  1BFF - 1BFF		  D3FF - D4FF
  Environment Descriptor	  1C00 - 1C7F		  D400 - D47F
  TCAP				  1C80 - 1CFF		  D480 - D4FF
  Multiple Command Line		  1D00 - 1DCF		  D500 - D5CF
  External Stack		  1DD0 - 1DFF		  D5D0 - D5FF
  Resident Command Package	  1E00 - 25FF		  D600 - DDFF
  Flow Control Package		  2600 - 27FF		  DE00 - DFFF
  I/O Package			  2800 - 2AFF		  E000 - E2FF
  Named Directory Register	  2B00 - 2DFF		  E300 - E5FF

Fig. 2.  Addresses of system components in the ZC.COM file and in the targetç
system as modified to support 42 named directories.

-----------------------------------------------------------------------------

     To implement this change in our Z-COM file we have to change only theç
ENV and CPR modules.  The ENV has to know about the new memory map, and theç
CPR code has to know where the NDR module is located.  Although the NDRç
module will be placed in a new location in the ZC.COM file, the NDR data areç
position-independent, so the module itself need not be changed (though weç
will presumably be adding many new names).  The FCP and RCP are still in theç
same place doing the same thing.

     One of the new features of Z33, by the way, is the ability to determineç
the locations of the NDR, FCP, and RCP from the environment descriptor. ç
Thus if we are using ZCPR33 with this feature enabled, no change in the CPRç
code is required.

     Only three changes in the Z3BASE.LIB file are required to reflect theç
new memory map.  These are the definitions for the symbols IOPS (the numberç
of 128-byte records allocated to the IOP), Z3NDIR (the address of the NDR),ç
and Z3NDIRS (the number of names in the NDR).  These changes are as follows:

              symbol       old expression      new expression
              ------       --------------      --------------

              IOPS            12 (0CH)             6 (06H)

              Z3NDIR        z3env - 200H         z3env + 0E00H
                                             or   iop + 300H

              Z3NDIRS         18 (12H)            42 (2AH)

     The new SYS.ENV file can be made either by assembling SYSENV.ASM withç
the modified Z3BASE.LIB, or it can be done by patching (either to the imageç
imbedded in ZC.COM or to the standalone ENV file).  I didn't have a copy ofç
SYSENV handy, so I have been using ZPATCH (which is much more fun anyway). ç
I find that I am constantly in need of the addresses of various items in theç
environment descriptor, so to make them easier to find, I took my copies ofç
Richard Conn's "ZCPR3, The Manual" and put a 3M Post-It (one of thoseç
wonderful little yellow semi-stick note sheets) on page 300 where the SYSENVç
module is described.  Then I wrote the offsets shown in Fig. 3 into theç
margin next to the symbols.  It was thus very easy to determine that theç
addresses to patch in the ZC.COM image are 1C11H (IOPS), 1C15H (Z3NDIR), andç
1C17H (Z3NDIRS).

-----------------------------------------------------------------------------

		offset		SYSENV code line
		------		----------------

		  09		dw	expath
		  0B		db	expaths

		  0C		dw	rcp
		  0E		db	rcps

		  0F		dw	iop
		  11		db	iops

		  12		dw	fcp
		  14		db	fcps

		  15		dw	z3ndir
		  17		db	z3ndirs

		  18		dw	z3cl
		  1A		db	z3cls

		  1B		dw	z3env
		  1D		db	z3envs

		  1E		dw	shstk
		  20		db	shstks
		  21		db	shsize

		  22		dw	z3msg

		  24		dw	extfcb

		  26		dw	extstk

		  28		db	[quiet flag -- no symbol]

		  29		dw	z3whl

		  2B		db	[cpu speed -- no symbol]

		  2C		db	[max drive (A=1) -- no symbol]
		  2D		db	[max user]

Fig. 3.  Offsets to various symbols and information in SYSENV.ASM, theç
environment descriptor module (see "ZCPR3, The Manual" p. 300ff).

-----------------------------------------------------------------------------

     The next steps were to assemble up a new version of the commandç
processor, create the desired NDR file, and then put all the pieces into theç
ZC.COM file as described last time.  While I was at it, I decided that itç
would be nice if this new version could co-exist on the system with theç
previous version, in case I ever wanted the full IOP space back temporarily. ç
To achieve this, I made two additional changes in the image and saved it toç
a file called ZC1.COM instead of ZC.COM.  These two changes were to the nameç
of the startup alias and the name of the CPR file to be loaded from A15 byç
the warmboot code.

     The startup command is stored in the multiple command line buffer,ç
whose image begins at 1D00H.  The standard ZC.COM has the following dataç
there for my Televideo 803H with its real MCL at D500H:

	<04> <D5> <CC> <04> S T R T <00>

The first two bytes are a pointer to the address D504, where the nextç
command (in this case the only command) to be executed is stored.  They doç
not have to be changed.  The third byte, CCH, is the maximum number ofç
characters that the command line can contain.  It should not have to beç
changed, but in fact the value is wrong.  Fortunately, this mistake can onlyç
cause trouble in highly exceptional circumstances, but while we are at it weç
can put in the correct value of CBH = 203.  The value of the symbol Z3CLS inç
Z3BASE.LIB should also be changed.  The correct value is the maximum numberç
of actual characters in the command line.  As can be seen above, there areç
four bytes before the command string and one byte (the terminating null)ç
after it.  Hence the proper value for Z3CLS is five less than the totalç
amount of memory allocated to the multiple command line buffer module.

     The fourth byte is the number of text characters in the command line. ç
This value is never used by the operating system, but the DOS line inputç
function writes the count to that position, so we have to provide space forç
it.  If you put a wrong value there, it will not make any difference, atç
least not for the operations performed here.  I have heard that there was atç
least one utility program that used this value for some purpose.  I do notç
recommend this practice, since some command-line-generator programs, Iç
believe, and do not update the value after they produce their command lines. ç
I am also not sure whether or not the Z3LIB routines APPCL and PUTCL updateç
the character count.

     To make ZC1.COM use a startup alias called START1 (6 characters), weç
would change the MCL buffer to

	<04> <D5> <CB> <06> S T A R T 1 <00>

This can be done either with ZPATCH or a debugger.  If there is a lot ofç
garbage in the rest of the command line buffer, you can fill it with zerosç
out through address 1DCFh to make things look neater.

     The file control block for the ZC.CP command processor image that isç
loaded from directory A15 starts at address 1944H.  By changing the spaceç
character at address 1947H from 20H to 31H ('1' ASCII), the CPR image ZC1.CPç
will be loaded instead.  You can also change the message at address 1901H toç
reflect the name of the CPR image file.  There is room to squeeze two extraç
characters into that message, one by eliminating the leading space and oneç
by omitting the ending period.  After you're done with these changes, don'tç
forget to put the CPR image file ZC1.CP in A15.

     It seems wasteful with this configuration to leave unused the block ofç
memory where the NDR used to be.  When I implemented this version, I movedç
the multiple command line buffer there so that I could increase its sizeç
from 208 to a full 256.  One might not enter such long commands by hand, butç
aliases and other command line generators occasionally overflow the 203ç
character limit in the usual configuration.  For ZCPR34 I am consideringç
some techniques for extending the length to a two-byte value so that theç
command line can be as large as one would like.  I will not describe theç
extra changes required to move the command line buffer, since the nextç
example will cover that and more.


Completely Revamping the Memory Model
-------------------------------------

     We will now consider how we go about completely revamping the memoryç
model, including moving the IOP.  Moving any module except for the IOP canç
be accomplished using a straightforward extension of what we have alreadyç
described.  The IOP poses some special problems that we will now deal with.

     Before turning to that subject, I would like to make some generalç
comments about the memory allocation in a ZCPR3 system.  With a fixed systemç
-- that is, any particular system that one will use at all times -- it doesç
not really matter how the modules are distributed in memory, just so long asç
they all fit somewhere.

     As soon as one wants to be able to change from one system configurationç
to another, not all memory models are as good as others.  I first noticedç
this when I wanted to run both Z3-DOT-COM and Z-COM on my system.  I usuallyç
used Z3-DOT-COM because it left a larger TPA, but occasionally I wanted toç
make use of the IOP for redirecting console output to a disk file.  At thatç
point I discovered that Joe Wright's choice of memory models was a poor one. ç
By adding the IOP at the top in Z-COM rather than at the bottom, theç
environment descriptor moved down to a lower address, and that meant that Iç
either had to have two sets of utility programs or had to reinstall all theç
utilities every time I changed from one system to the other.  This providedç
a powerful incentive to discover methods for modifying the memory maps.  Ofç
course, with ZCPR33 and its automatic installation of utilities, this is noç
longer a concern.

     Even with ZCPR33 there are compelling reasons to choose some memoryç
configurations over others.  The addresses of most system components areç
hard-coded into even the ZCPR33 command processor.  However, as we mentionedç
earlier, the addresses of the largest memory buffers -- the NDR, FCP, andç
RCP -- can determined dynamically from the environment descriptor in memory. ç
As a result, if these buffers are placed adjacent to one another, the singleç
block of memory allocated to the set of them can be reconfigured simply byç
loading a new environment descriptor.  Since the command processor does notç
directly refer to the IOP, the IOP can also be included at the bottom ofç
this single buffer space.  The tradeoffs that become possible areç
illustrated in Fig. 4, where a single memory block of 4.25K (the standardç
amount in Z-COM for these modules) is allocated in two different ways.

-----------------------------------------------------------------------------

   total space          standard configuration    alternate configuration

       ---                   ---                       ---
        |                     |   NDR (2)               |
        |                    ---                        |   NDR (6)
        |                     |   FCP (4)               |
        |                     |                        ---
        |    all             ---                        |
        |  buffers            |                         |   FCP (7)
        |   4.25K             |                         |
        | 34 records          |                        ---
        |                     |   RCP (16)              |
        |                     |                         |
        |                     |                         |
        |                     |                         |
        |                     |                         |   RCP (20)
        |                    ---                        |
        |                     |                         |
        |                     |                         |
        |                     |   IOP (12)              |
        |                     |                         |
        |                     |                        ---
        |                     |                         |   IOP (1)
       ---                   ---                       ---

Fig. 4.  One illustration of how a single block of memory can be dynamicallyç
allocated among the IOP, RCP, FCP, and NDR buffers in a ZCPR33 system.

-----------------------------------------------------------------------------

     In the alternative memory map in Fig. 4 the IOP buffer has been shrunkç
to a single record, a space just large enough to hold the dummy IOP that Z-COM comes with (we can't shrink it to zero without changing the VBIOS).  Theç
extra 11 records of memory are then distributed to the other modules.  Theç
NDR increases to 6 records, enough for 42 named directories.  The FCP picksç
up 3 more records.  At 7 records, it has enough space to implement a veryç
large number of resident test options.  The remaining 4 records go to theç
RCP, which can probably now include all options in Z33RCP.

    Suppose the standard configuration is described by SYS.ENV and uses theç
modules SYS.NDR, SYS.FCP, and SYS.RCP, and that the alternativeç
configuration is described by ALT.ENV with modules ALT.NDR, ALT.FCP, andç
ALT.RCP.  Then we would change from the standard to the alternateç
configuration by entering the command

		LDR ALT.ENV,ALT.NDR,ALT.FCP,ALT.RCP

Note that it is essential that the ENV module be listed, and thereforeç
loaded, first.  If it is not, LDR will not know the correct addresses forç
the other modules.  Similarly, to change back to the standard configuration,ç
one would use the command

		LDR SYS.ENV,SYS.NDR,SYS.FCP,SYS.RCP

If one were switching back, for example, to use the NuKey IOP to provideç
keyboard macro capability, the line could read

		LDR SYS.ENV,SYS.NDR,SYS.FCP,SYS.RCP,NUKEY.IOP

In this way one can make much more flexible use of system resources.  Oneç
might choose to reduce the size of the overall buffer space to only 35ç
records, keeping only the IOP stub in the standard configuration.  Then whenç
an IOP like IOR (I/O recorder) or BPRINT (print spooler) is needed, the RCPç
and/or FCP would be contracted temporarily.  Either one or both could evenç
be eliminated (reduced to zero size).  Aliases can be used to automate theç
process of switching configurations.


Moving the IOP
--------------

     We will now build a Z-COM system of the form described above.  Theç
memory map for the new configuration is shown in Fig. 5.  Since the ENVç
(including TCAP) is a fixture in any system, I would have preferred to putç
it in the invariant position at the very top of memory.  However, ZRDOS hasç
to know where the ENV is in order to support wheel-locking of files.  If youç
have purchased ZRDOS separately, you can generate a version to run at anyç
address and to reference an ENV at any address.  If you only have Z-COM,ç
however, you do not have this freedom.  Therefore, I have left theç
environment where it was.

-----------------------------------------------------------------------------

System Component		ZC.COM Address		System Address
----------------		--------------		--------------

operating system modules

  CPR				  0200 - 09FF		  BA00 - C1FF
  ZRDOS				  0A00 - 17FF		  C200 - EFFF
  Virtual BIOS			  1800 - 19FF		  D000 - D1FF

large, variable buffers

  I/O Package			  1A00 - 1FFF		  D200 - D7FF
  Resident Command Package	  2000 - 25FF		  D800 - DFFF
  Flow Control Package		  2800 - 27FF		  E000 - E1FF
  Named Directory Register	  2A00 - 1AFF		  E200 - E2FF

third page of buffers

  Shell Stack			  2B00 - 1B7F		  E300 - E47F
  Z3 Message Buffer		  2B80 - 1BCF		  E380 - E4CF
  External FCB			  2BD0 - 1BF3		  E3D0 - E4F3
  PATH				  2BF4 - 1BFE		  E3F4 - E4FE
  Wheel Byte			  2BFF - 1BFF		  E3FF - E3FF

second page of buffers

  Environment Descriptor	  2C00 - 1C7F		  E400 - E47F
  TCAP				  2C80 - 2DFF		  E480 - E4FF

top page of buffers

  Multiple Command Line		  2D00 - 1DCF		  E500 - E5CF
  External Stack		  2DD0 - 1DFF		  E5D0 - E5FF

Fig. 5. Memory map for a system designed for dynamic buffer reallocationç
under ZCPR33.

-----------------------------------------------------------------------------

     The first step, as usual, in making a new configuration is to prepare aç
new Z3BASE.LIB file.  The important addresses in that file are shown in Fig.ç
6.  I have considered each page of memory to be a unit.  The bottom of theç
page is referenced to the real BIOS address, and the other modules in theç
page are referenced to the base module for that page.  Of course, you canç
express these addresses in many other equivalent ways, and you may wellç
prefer to do it differently.  In any case, with Z3BASE.LIB in hand, you canç
assemble up the CPR, RCP, FCP, and ENV modules (or you can make the latterç
by patching).

-----------------------------------------------------------------------------

	; Z3BASE.LIB

		rbios	equ	0e600h

	; First page under BIOS

		z3cl	equ	rbios - 100h
		z3cls	equ	203
		extstk	equ	z3cl + 0d0h

	; Second page under BIOS

		z3env	equ	rbios - 200h
		z3envs	equ	2

	; Third page under BIOS

		shstk	equ	rbios - 300h
		shstks	equ	4
		shsize	equ	32
		z3msg	equ	shstk + 080h
		extfcb	equ	shstk + 0d0h
		expath	equ	shstk + 0f4h
		expaths	equ	5
		z3whl	equ	shstk + 0ffh

	; Variable modules

		z3ndirs	equ	14
		z3ndir	equ	rbios - 0400h
		fcps	equ	4
		fcp	equ	z3ndir - fcps*80h
		rcps	equ	16
		rcp	equ	fcp - rcps*80h
		iops	equ	12
		iop	equ	rcp - iops*80h

	; Operating system components

		vbios	equ	iop - 0200h
		dos	equ	vbios - 0e00h
		ccp	equ	dos - 0800h

Fig. 6.  Address equates for the Z3BASE.LIB file corresponding to the memoryç
configuration shown in Fig. 5.

-----------------------------------------------------------------------------

     We would be able to implement this configuration without any problemç
using the techniques we have already seen were it not for the IOP module. ç
The IOP is really an extension of the BIOS, and the problem is that theç
virtual BIOS has vectors (jump instructions) going to the IOP.  When the Z-COM system is built by the loader program ZCLD.COM, the addresses areç
calculated based on the assumed relative positions of the VBIOS and IOP. ç
Since we are now going to change the spacing between them, we will have toç
perform some patching on the VBIOS module.

     The table of jump vectors in the virtual BIOS is shown in Fig. 7. ç
There are two jumps (warm and cold boot) that are internal to the VBIOS, 7ç
jumps to addresses in the IOP (6 in one group and one extra), and 10 jumpsç
to the real BIOS.  Only the jumps to the IOP have to be changed.

-----------------------------------------------------------------------------

	(00)	VBIOS:	JP	VBIOS + 67H	; coldboot
	(03)		JP	VBIOS + 67H	; warmboot

	(06)		JP	IOP + 0CH	; console status
	(09)		JP	IOP + 0FH	; console input
	(0C)		JP	IOP + 12H	; console out
	(0F)		JP	IOP + 15H	; list out
	(12)		JP	IOP + 18H	; punch out
	(15)		JP	IOP + 1BH	; reader in

	(18)		JP	BIOS + 18H	; home disk
	(1B)		JP	BIOS + 1BH	; select disk
	(1E)		JP	BIOS + 1EH	; set track
	(21)		JP	BIOS + 21H	; set sector
	(24)		JP	BIOS + 24H	; set DMA
	(27)		JP	BIOS + 27H	; read sector
	(2A)		JP	BIOS + 2AH	; write sector

	(2D)		JP	IOP + 1EH	; list status

	(30)		JP	BIOS + 30H	; sector translation

Fig. 7.  Structure of the jump table in the virtual BIOS.

-----------------------------------------------------------------------------

     You should begin by making a copy of ZC1.COM, which we generatedç
earlier, giving it the name ZC2.COM.  Then determine the absolute address ofç
the IOP in your system.  Next, go into ZC2.COM with ZPATCH or with aç
debugger and change the addresses.  For my Televideo 803H system the IOP hadç
been at E000H and is now at D200H.  I would look for the seven jumps of theç
form "C3 ?? E0" and change them to "C3 ?? D2".

     We also have to make some changes to the code in the dummy IOP.  It hasç
a total of 16 jump instructions, 7 of which refer to the real BIOS and 9 ofç
which refer to internal addresses.  The former need not be changed, but,ç
since we are changing the address at which the IOP will execute, we have toç
change the latter addresses.  The source code for the dummy IOP is shown inç
Fig. 8.

-----------------------------------------------------------------------------

	(00)	IOP:	JP	IOP + 3DH	; status
	(03)		JP	IOP + 3DH	; device select
	(06)		JP	IOP + 3DH	; device name
	(09)		JP	IOP + 3DH	; initialization

	(0C)		JP	BIOS + 06H	; console status
	(0F)		JP	BIOS + 09H	; console input
	(12)		JP	BIOS + 0CH	; console output
	(15)		JP	BIOS + 0FH	; list output
	(18)		JP	BIOS + 12H	; punch output
	(15)		JP	BIOS + 15H	; reader input
	(18)		JP	BIOS + 2DH	; list status

	(1B)		JP	IOP + 3DG	; new I/O routine
	(1E)		JP	IOP + 3DH
	(21)		JP	IOP + 3DH
	(24)		JP	IOP + 3DH
	(27)		JP	IOP + 3DH

	(30)		DB	'Z3IOPDUMMY   '	; ID string
	(3D)		XOR	A		; set zero value and flag
	(3E)		RET			; return

Fig. 8.  Source code for the dummy IOP in Z-COM.  All the internal routinesç
simply return with the zero flag set, while the substantive functions areç
vectored off to the real BIOS.

-----------------------------------------------------------------------------

     The garbage that appears from address IOP+3FH to the end of the IOP atç
IOP+5FFH can be filled with zeros to make things look neater.  Then the 9ç
internal vectors have to be modified in the same way those in the BIOS wereç
to point to the new address of the IOP.  Finally, the reconfigured IOP hasç
to be moved from its present position at 2800H to its new place in ZC2.COMç
at 1A00H.

     While we are in the debugger doing that, we can also change (1) theç
file control block to load the command processor image ZC2.CP (and also theç
'not found' message) and (2) the multiple command line buffer to run START2. ç
This initial multiple command line must also be moved from its old addressç
at 1D00H to its new position at 2D00H.  Make sure that the second byte inç
the command line buffer points to the page where the real multiple commandç
line buffer will be.

     You should then fill all the other buffers with zeros.  The CPR, RCP,ç
FCP, and ENV modules can be loaded into the image.  Then the initial pathç
should be set up at address 2BF4H, and the wheel byte at address 2BFFHç
should be set to FFH if you want it on.  Finally, if you want an errorç
handler to be loaded when Z-COM is booted, then patch in the error commandç
line (for example, "A0:Z33VERR<0>") at Z3MSG+10H  (2B90H in ZC2.COM).

     If everything has gone right, and I have not left something out orç
written something wrong, you should be ready to test it out.  Don't forgetç
to put the command processor image files in A15.  I know I keep harping onç
this, but while working on this article, I forgot to do that on oneç
occasion, and there are now a few dents in the table from my fist!


A Minimum System
----------------

     If you ever meet me and feel like having a little fun at my expense,ç
just casually make some comment like, "Oh, yeah, I hear ZCPR3 has some niceç
features but that it uses up much too much memory."  It is a subject thatç
has become a sore point for me lately and one that is almost guaranteed toç
provoke me.  To be honest, however, the persistance of this false impressionç
is to a large degree the result of poor education on our part.  No one everç
talks about minimum ZCPR3 systems; we only describe full-blown ones.

     It is true that a full-blown ZCPR3 system uses quite a bit of memory. ç
Z-COM takes 1600H = 5.5K bytes of memory out of your TPA, a pretty heftyç
chunk.  I like the features that this big Z-System gives me, and for theç
kind of work I do, the smaller TPA almost never causes any problem.  For me,ç
the benefits far outweigh the cost.

     For some people, however, especially those working with voraciousç
memory hogs like database managers and C compilers, this is not the case. ç
(It seems to me that someone like Steve Russell of SLR should write a good,ç
virtual-memory C compiler like his virtual-memory assemblers to prevent thisç
problem.)  But the real answer is that a ZCPR3 system does not have to haveç
every feature implemented.  As with most things in this world, the 20/80ç
rule applies: for less than 20% of the cost, you can buy more than 80% ofç
the features.  If we eliminate all the variable buffers in the last example,ç
we end up with a system that uses only 5 pages (1.25K) of memory, a veryç
modest amount.  The same system installed in the conventional way, with noç
space required for the virtual BIOS of Z-COM, would take only 0.75K awayç
from the TPA, yet all of the following features would still be there:

	automatic command search path
	flexible access to user areas
	multiple commands on a line
	aliases
	shells (including history shell and filer shells)
	extended command processing (including ARUNZ command generator)
	powerful error handlers (with command editing)
	terminal-independent operation (TCAP)
	flexible program loading (type-3 environment)
	interprogram communication

The only things missing are named directories and flow control.  Some simpleç
flow-control-like features could be implemented even without the FCP.  Withç
all the security features and named-directory support removed from theç
command processor, there is room for many more CPR-resident commands, andç
the ones that won't fit can be implemented as virtual residents using theç
new type-3 environment.  In summary, a very powerful system can be builtç
with a very small cost in TPA.

     To prove this point (and because it will be useful on those rareç
occasions when I run my database manager), I decided to develop a version ofç
Z-COM that would have only the three pages of core modules.  The memory mapç
is shown in Fig. 9.  It differs in two fundamental ways from all the otherç
maps we have seen: (1) it is shorter and (2) the real VBIOS and ZRDOS run atç
different addresses than usual.  These differences will require some newç
techniques, and we will cover them shortly.

-----------------------------------------------------------------------------

System Component		ZC.COM Address		System Address
----------------		--------------		--------------

  CPR				  0200 - 09FF		  CB00 - D1FF
  ZRDOS				  0A00 - 17FF		  D300 - E0FF
  Virtual BIOS			  1800 - 19FF		  E100 - E2FF
  Shell Stack			  1A00 - 1A7F		  E300 - E47F
  Z3 Message Buffer		  1A80 - 1ACF		  E380 - E4CF
  External FCB			  1AD0 - 1AF3		  E3D0 - E4F3
  PATH				  1AF4 - 1AFE		  E3F4 - E4FE
  Wheel Byte			  1AFF - 1AFF		  E3FF - E4FF
  Environment Descriptor	  1B00 - 1B7F		  E400 - E47F
  TCAP				  1B80 - 1BFF		  E480 - E4FF
  Multiple Command Line		  1C00 - 1CCF		  E500 - E5CF
  External Stack		  1CD0 - 1CFF		  E5D0 - E5FF

Fig. 9.  Addresses of system components in the ZC3.COM file and in theç
target system for a minimum configuration with no IOP, RCP, FCP, or NDR. ç
The file is 2E00H - 1D00H = 1100H = 4.25K shorter than the other versions.

-----------------------------------------------------------------------------

     First we have to make Z3BASE.LIB, the equates for which are shown inç
Fig. 10.  The only subtle change is in the way the VBIOS address is defined. ç
Make sure you do not define it in terms of any of the modules whoseç
addresses have been set to zero to disable them or you will get extremelyç
strange results.

-----------------------------------------------------------------------------

	; Z3BASE.LIB

		rbios	equ	0e600h

	; First page under BIOS

		z3cl	equ	rbios - 100h
		z3cls	equ	203
		extstk	equ	z3cl + 0d0h

	; Second page under BIOS

		z3env	equ	rbios - 200h
		z3envs	equ	2

	; Third page under BIOS

		shstk	equ	rbios - 300h
		shstks	equ	4
		shsize	equ	32
		z3msg	equ	shstk + 080h
		extfcb	equ	shstk + 0d0h
		expath	equ	shstk + 0f4h
		expaths	equ	5
		z3whl	equ	shstk + 0ffh

	; Variable modules -- all disabled

		z3ndirs	equ	0
		z3ndir	equ	0
		fcps	equ	0
		fcp	equ	0
		rcps	equ	0
		rcp	equ	0
		iops	equ	0
		iop	equ	0

	; Operating system components

		vbios	equ	shstk - 0200h
		dos	equ	vbios - 0e00h
		ccp	equ	dos - 0800h

Fig. 10.  The Z3BASE.LIB equates for a minimum system that takes only 0.75Kç
for the ZCPR3 buffers and 0.5K for the virtual BIOS required for automaticç
installation.

-----------------------------------------------------------------------------

     The basic procedure for creating this system is very much like what weç
have done before.  We edit the Z3BASE.LIB file and assemble up the CPR andç
ENV modules (or make the latter by patching).  There are no FCP, NDR, or IOPç
modules to worry about.  We set up the path, the wheel, and the errorç
handler; we change the VBIOS file control block to load ZC3.CP for the CPRç
image file and change the 'not found' message to match; and we put in theç
ENV and CPR modules.

     Now we have to face the new complications that arise because of theç
change in size of the file.  First we will take up the simpler problem --ç
changing the loader code in the first page of the file.  It normally copiesç
2C00H bytes (from 200H to 2E00H) up to the run-time location in memory.  Nowç
the image part of the file is only 1B00H bytes long.  If you follow throughç
the loader code in a debugger, you should not have too much difficultlyç
figuring out what is going on.  The hardest parts to trace through are theç
places where the code prints out in-line strings.  You will typically see aç
call instruction followed by very strange code.  That strange code is theç
text to be printed.  That coding technique is very convenient for theç
programmer (and I use it all the time), but it makes disassembly and single-stepping in a debugger much more difficult.  When you encounter code likeç
this, you have to use the dump ('D') display to locate the null (binary 0)ç
that marks the end of the string.  Then you can continue running using theç
command "G,addr", where 'addr' is the address just after the null.

     Anyway, at address 181H you will find the key instruction: LDç
B.C.,2C00H.  This must simply be changed to LD B.C.,1B00H.  That's all thereç
is to it -- as far as the loader code is concerned.  You might wonder why weç
don't have to change the starting address for the load, since it is not theç
same as before.  The answer is that Z-COM derives it from the initial jumpç
instruction in the CPR image.  My first versions of Z33 used a relativeç
jump, and I had to put the absolute jump back after one of my beta-testersç
pointed out that it would not work with Z-COM.

     Now we have to face two much more difficult problems: both the VBIOSç
and the ZRDOS modules have to be relocated to a new address.  How can weç
possibly do this without source code?  Well, if you purchased a separateç
copy of ZRDOS, you have a file with a name like ZRDINS.COM with which youç
can create a binary image of ZRDOS that will run at any address and with anyç
ENV address.  But what if you don't have it?  And what about the VBIOS part? ç
The latter could conceivably be disassembled, since the code is not veryç
long or very complex, but there is a better way, one that makes use of theç
built-in capabilities of the auto-install package.

     If you had two computers with different BIOS entry addresses, you couldç
perform a standard installation of Z-COM on each system.  By taking the twoç
ZC.COM files and subtracting them in a debugger, you could derive theç
relocation map.  Now the question is how we can make two ZC.COMs using aç
single computer.

     If you examine the beginning of the code in ZCLD.COM, you will see thatç
ZCLD keys its system generation to the address of the BIOS warmboot vectorç
at address 0001, and that is what we will base our strategy on.  We willç
fool ZCLD into making us two versions of ZC.COM one page apart that we canç
subtract.

     With my standard Z-COM system running on the Televideo 803H, the CPR isç
at BA00H and the virtual BIOS at D000H.  Thus the vector at address 0001ç
points to D003H.  By entering the following commands, we can make the BIOSç
look as though it were at B900:

	POKE B903 C3 03 D0	; Set up JP D003H at address B903H
	POKE 2 B9		; Change bios vector from D003 to B903

Of course, you must use addresses appropriate to your system.  Any addressç
below the CPR but above the memory used by ZCLD should work.

     With this patch in place, everything will be fine so long as we do notç
try to run a program that does direct BIOS calls based on the address atç
0001.  (If we do? -- the system will simply go up in flames!)  In caseç
you're worried, the next warmboot will delete our patch and restore thingsç
to normal.

     Fortunately, ZCLD does not mind being fooled this way.  All in all, theç
following sequence of commands will result in two files, ZCB8.COM andç
ZCB9.COM.

	POKE B903 CE 03 D0;POKE 2 B9;ZCLD;REN ZCB9.COM=ZC.COM
	POKE B803 CE 03 D0;POKE 2 B8;ZCLD;REN ZCB8.COM=ZC.COM

We can then load both files into a debugger using the commands

	IZCB8.COM		; set file to ZCB8.COM
	R			; read in at 100H (100H-2DFFH)
	IZCB9.COM		; set file to ZCB9.COM
	R3000			; read in at 3100H (3100H-5DFFH)

     Now from right in the debugger we can assemble a little program atç
3000H to subtract the ZRDOS and VBIOS images in memory block 0A00H-19FFHç
from the images in memory block 3A00H-49ffH to give us the relocation map weç
need.  Here is how the entry of the assembly code proceeds:

	-A3000
	3000  LD DE,3A00	; set up pointers to two files
	3003  LD HL,A00
	3006  LD B.C.,1000	; number of bytes to subtract
	3009  LD A,(DE)		; get byte from higher image
	300A  SUB (HL)		; subtract byte from lower image
	300B  LD (DE),A		; put result (0 or 1) back
	300C  INC HL		; increment the pointers
	300D  INC DE
	300E  DEC B.C.		; check count
	300F  LD A,B
	3010  OR C
	3011  JR NZ,3009	; loop through 1000H bytes
	3013

Enter the command "G3000,3013" to run this routine with a breakpoint atç
3013.  If you look at memory from 3A00H TO 49FFH you will see a pattern ofç
1s and 0s.  This is the relocation map.  It indicates which bytes must beç
changed to shift the execution address of the code.

     Now we have to relocate the ZRDOS to run at D300H and the VBIOS to runç
at E100H instead of the values 9400H and A200H as they are in the image inç
ZCB8.COM (determined by inspection with a debugger).  Thus we have to add anç
offset of 3FH (E1-A2) to all bytes where the relocation map has a one in it. ç
So we assemble up another little program at 3000H as follows:

	-A3000
	3000  LD HL,3A00	; point to relocation byte
	3003  LD DE,1A00	; point to ZRDOS/VBIOS we are creating
	3006  LD B.C.,1000	; number of bytes to cover
	3009  LD A,(DE)		; get current value of byte
	300A  BIT 0,(HL)	; see if relocation map has a 1 in it
	300C  JR Z,3011		; if not, skip the offset addition
	300E  ADD A,3F		; add the offset
	3010  LD (DE),A		; put back the corrected byte
	3011  INC HL		; increment the pointers
	3012  INC DE
	3013  DEC B.C.		; check the count
	3014  LD A,B
	3015  OR C
	3016  JR NZ,3009	; loop through 1000h bytes
	3018

Run this program with "G3000,3018" and you will have a ZRDOS and VBIOS thatç
will run at the required address.  Put them in a safe place temporarilyç
while you load in ZC3.COM and then move them into the proper place in theç
image.  This completes the generation of the minimum system except for oneç
step described a little later.

     Although all that work with the debugger took quite a lot of space toç
describe, it is really not that difficult to do.  I particularly wanted toç
show it to you because it is a technique that is useful in many otherç
circumstances as well (like using MOVCPM to relocate your system in one-pageç
rather than 1K increments).  Now, however, I will show you a much easier wayç
to accomplish the same thing in the case of Z-COM.

     If you load ZCLD.COM into the debugger and trace through the code withç
the 'L' command, you will see how it works.  Before one gets to the mainç
code, there are two places where checks are made.  One is to see if theç
command was invoked as "ZCLD //" to request the built-in help screen.  Theç
second test is to make sure that you are not trying to run ZCLD from insideç
a running Z-COM system.  We could drop out of Z-COM after making the changesç
I am about to describe, but why put up with that trouble.  The code isç
testing for the presence of the letter 'Z' in the copyright notice insideç
the VBIOS at offset 42H.  At address 249H there is a "JP NZ,29D" instructionç
that takes one to the system-building code if no 'Z' is detected.  If weç
change this to an unconditional jump, we will effectively disable the test.

     At 29DH, the code loads the address of the BIOS with the instructionç
"LD HL,(1)".  We know that we want the system to be generated at an addressç
1100H higher than it would be normally because of all the modules weç
removed.  Since the normal BIOS address was E600H, we want ZCLD to see aç
value of F700H.  To accomplish this, we assemble in the instruction "LDç
HL,F700", a direct load instead of an indirect load to HL.  We can then saveç
away this modified version as ZCLD1.COM.  When we run it, it very nicelyç
produces a system with a ZRDOS and VBIOS at just the addresses we wanted.

     There is one other change I have forgotten to mention.  The jumps inç
the VBIOS that go to the IOP have to be replaced by jumps to the real BIOSç
at the very same offset as in the VBIOS.  Thus the jump at offset 06, whichç
was "JP IOP+0CH", would become "JP BIOS+06H".


Switching from One Version to Another
-------------------------------------

     What if we are running one of our versions of Z-COM and want to changeç
to another one.  We can always run the ZCX command to get back to CP/M andç
then load the new Z-COM system.  This seems unnecessarily tedious.  Whyç
can't we just run ZC2.COM from the ZC1 system?  The answer is that Joeç
Wright did not want us to do this.  Of course, he was thinking in terms ofç
only single configurations, and then there would be no reason to run ZC.COMç
when Z-COM was already running.  So, he put in some code to protect us fromç
this mistake.

     Now we want to do that very thing!  How can we disable the safety code? ç
Very simply.  It is based on the same check we described with the ZCLDç
program.  It looks for a 'Z' at byte 42H of the BIOS or VBIOS.  If it is aç
VBIOS, the 'Z' will be there; if it is a real BIOS, it would be veryç
unlikely that a 'Z' would be there.  We could go into the code itself as Iç
described with ZCLD and disable the test.  Alternatively, we could doç
something much simpler (and reversible): go into the VBIOS and remove theç
'Z' by changing it to something else.  A third possibility, one Iç
implemented for the fun of it, is to write a little utility program thatç
finds that byte of the BIOS.  If it is not a 'Z', it simply returns; if itç
is a 'Z', it sets it to zero.  Then the next ZCx can load over it.  If theç
utility is not run, then the system cannot be overlaid.

     I will suggest one last modification to Z-COM to enhance it evenç
further.  That is a change to allow alternative versions of Z-COM to beç
loaded without interrupting the flow of commands.  Thus your memory-hungry Cç
compiler would be invoked with an alias the reads something like:

	RUNC zc3;c $*;zc2

This alias would load the minimum Z-COM system to give the C compiler theç
most room to work, and then once the compilation was finished it wouldç
reload the full Z-COM configuration.  I did this with my Z3-DOT-COM/Z-COMç
combination.  The I/O Recorder IOP was invoked using an alias.  The aliasç
would first check to see which Z-System was running (that is what I put theç
$M parameter into ARUNZ for).  If it was Z3-DOT-COM, then alias would loadç
Z-COM before proceeding to load the IOP.  I will not go through the methodç
for accomplishing this, but I will give you a hint.  You have to change theç
loader code in the first page of ZCx.COM so that the multiple command lineç
buffer and some other system information is not overwritten by the load.


Plans for Next Time
-------------------

    Whew!  That was quite a session of heavy technical material.  I don'tç
know yet exactly what I will do next time, but I certainly I will find aç
less technical subject.  You need a rest, and I need a rest.  If you haveç
any questions or suggestions, please write or call.  See the ad for Sageç
Microsystems East for the address and phone numbers.
                                                                                                                  