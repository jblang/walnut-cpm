The Z-System Corner
TCJ Issue 38
Jay Sage


   True, February is a short month, but somehow I don't think that explainsç
why the beginning of February (the due date for this column) came quickerç
than usual.  It is probably a good thing that I have convinced severalç
others to start contributing regular columns to TCJ.  That way, Art Carlsonç
may be busy enough not to notice that the deadline passed without my column. ç
Because it is late and because we now have quite a few prolific writersç
joining the TCJ ranks, I'm going to keep my column shorter than usual thisç
time (I know I have said that before, but this time I think it really willç
be true).

   For this issue I will be catching up on some correspondence, informingç
you of the imminent release of the first high level language for Z-Systemç
programming, bringing you up to date on Z-Node developments (there is a newç
Z-Node Central), and beginning a discussion of issues related to bringing upç
a remote access system (so that more of you might decide to set up a Z≠
Node).


                                  Letters

   Despite our requests for letters with your comments and suggestions, weç
don't get very many.  Recently, however, Art forwarded to me two lengthy andç
thoughtful letters from James Ott.  I would like to begin by addressing someç
of his comments and questions.


The ZCPR33 Programmer's Reference Manual

   First, Mr. Ott asked about the "Programmer's Reference Manual" to which Iç
made reference in my ZCPR33 User's Guide.  Well, the truth is that afterç
writing the user's guide, I really didn't have energy left for another majorç
manual.  Instead, I started to release programming notes one at a time asç
files on the Z-Nodes.  Even at that, I only got to three of them.  The filesç
have names of the form Z33PNOTE.###, where "###" is a sequence number.  Noteç
001 deals with the command status flag in the message buffer and theç
extensions in its use introduced with ZCPR33.  Note 002 discusses properç
coding techniques for shells under ZCPR33 and later.  The third note coversç
the parsing of files by the Z33 and Z34 command processors.  I am tempted toç
reproduce some of that material here, but then I would surely fail in myç
resolve to keep this column to a reasonable length.  So you will just haveç
to look for them at the Z-Node in your neighborhood.  If it is not there,ç
see if the sysop will get a copy from Z-Node #3.


Shells and ZEX

   Mr. Ott continued: "The User's Guide mentions an addition to shell codingç
necessary to ensure the shell pushes its name onto the shell stack when itç
is called by ZEX."  I think there is some misunderstanding here.  It wasç
under previous versions of ZCPR3 that special code was required in shells toç
deal with ZEX (and it never had to do with pushing anything onto the shellç
stack).  Under Z33 and later, this code can (and, to make the programsç
smaller, should) be removed.  It has now been quite some time since theç
release of ZCPR33, and I think that most shells are now coded in the moreç
efficient way.

   As we have discussed in previous columns, a shell command comes into playç
when the command line buffer becomes empty.  In that case, if there is aç
command on the shell stack, the command processor invokes that commandç
instead of asking the user for the next command line.  In this way, theç
shell takes over the function of the command processor.

   ZEX's function is similar to that of SUBMIT and XSUB together.  Whileç
SUBMIT stores its script data in a disk file, ZEX keeps it in memory.  Thisç
enables ZEX to run much faster, but it reduces the memory available toç
programs.  A simple SUBMIT script feeds a series of commands to the commandç
processor, thus doing under CP/M what the multiple command line of ZCPRç
does.  SUBMIT can be useful even under ZCPR, however, because it can supplyç
a longer string of commands than could fit into the command line buffer.

   XSUB running under SUBMIT allows characters in the script to be fed notç
only to the command processor but also to programs as they run.  This isç
what is called input/output (I/O) redirection.  In this case it is inputç
redirection; the operating system is made to take its characters not fromç
its normal source -- the keyboard -- but from a disk file (SUBMIT) or aç
memory buffer (ZEX).  This is both extraordinarily useful andç
extraordinarily tricky.  Long ago I promised to discuss this subject atç
length in this column, but I have never gotten around to it.  Bridgerç
Mitchell, Joe Wright, and I are now engaged in a joint project to perform aç
major upgrading of ZEX, and I am sure it will be the subject of TCJ columnsç
by one or more of us.

     The ZCPR33 command processor observes the following hierarchy forç
acquiring new commands, where step 1 has the highest priority and step 5 theç
lowest.  The way this hierarchy functions is described in more detail in theç
ZCPR33 User's Guide.

    1.	Commands pending in the multiple command line buffer
    2.	Commands from a ZEX script
    3.	Commands from a SUBMIT script
    4.	A shell command
    5.	User input

   Under ZCPR30, ZEX did not appear explicitly in this hierarchy; it cameç
into play only by virtue of its ability to redirect input at step 5.  Thisç
posed a serious problem when a ZEX command was issued under a shell.    ç
Although the user intended the script to be performed as commands, the shellç
would take it as input to the shell instead.  To avoid this, rather lengthyç
code had to be included in every shell to see if ZEX was running and, if so,ç
to feed its input directly to the multiple command line buffer.  Thisç
resulted in completely useless loads of the shell code for each line of theç
ZEX script.  Execution was so slow and annoying that for all practicalç
purposes ZEX scripts could not be run under shells.

   The ZCPR33 command processor was redesigned to deal with ZEX explicitlyç
just as ZCPR30 always did with SUBMIT.  ZEX was placed above SUBMIT in theç
hierarchy so that ZEX scripts would function like arbitrarily long commandç
lines and could be invoked from SUBMIT scripts.


The New Libraries

   Mr. Ott had several questions about the assembly-language libraries thatç
support the Z-System.  I will not comment extensively here, but I would likeç
to announce that new versions of the libraries, which have been in use by aç
number of us for many months already, will soon be made available to theç
public.  I had expected them to be a commercial product, but, for severalç
reasons, it now appears that the code will be made available at no charge. ç
Only the manual, which will be quite a large book, will be sold.  This isç
good news.

   One of Mr. Ott's suggestions was that the Z3LIB routine called PRGLOAD,ç
which is used for chaining from one program to another, be updated to allowç
for type-3 programs.  This probably could be done without a great deal ofç
difficulty, but I am not sure that it is worth the trouble.  What aboutç
type-4 programs?  Loading them is much more complex because of the need toç
compute the relocation to a run-time address.  It seems to me that a betterç
way for programs to chain to other programs is via the multiple command lineç
buffer.  If anyone can suggest any advantages of a direct load, I would beç
interested in hearing them.


The Command Line Tail

   One of the mistakes in ZCPR30 was its failure to check for command lineç
tails that would not fit in the buffer from 80H to FFH.  CP/M had no problemç
with this because the whole command line was not long enough to allow thisç
to occur.  With a 200-or-more-character command line buffer, there isç
nothing to stop a user from entering a command with a tail longer than 128ç
bytes.  Under Z30 this caused a catastrophe, because the tail was copiedç
into the buffer after the program was loaded, and then the tail couldç
overwrite the beginning of the code.  Z33 and later monitor the length ofç
the tail and stop copying before this can happen.

   With type-3 programs that load at addresses higher than 100H, longerç
tails could be copied without damaging the code, and Mr. Ott requested thatç
this be implemented in future versions of the command processor.  I thinkç
this would be a very bad idea.  One of the reasons for using type-3 programsç
is so that any code residing at 100H can be run again later using the GOç
command.  If the type-3 program's tail overwrote the TPA, then trouble wouldç
occur when the GO command was executed.

   Moreover, there is absolutely no need for such a feature.  If a programç
wants to support a tail longer than 126 bytes (it doesn't even have to be aç
type-3 program), it can simply read its arguments not from the buffer at 80Hç
but directly from the multiple command line buffer.  As an aside, I haveç
thought of making the command processor not convert the command line bufferç
to upper case.  Then programs could process lower case input directly (as inç
MS-DOS) without the special symbols to indicate case shifts as in the ECHOç
and IF INPUT commands.  The command tail buffer at 80H must be converted toç
upper case for compatibility with CP/M programs, which assume that that willç
be done.  Besides the fact that there might be a significant code penaltyç
(the command tail buffer and the command file control block would both haveç
to be individually case shifted), I worry that there may be a number of Z≠
System programs that either rely on the command line being in upper case or,ç
worse, convert it to upper case.  I'd be interested in hearing any opinionsç
on this topic.


Still More on Z3 vs. Z2 Shells

   Mr. Ott sent me a lengthy letter with some interesting examples of theç
use of the shell stack.  I think his is the first response I have receivedç
that pointed out an aspect of the shell stack that I had not previouslyç
appreciated.

   I don't think about shell command lines with more than one command, soç
the following distinction never occurred to me.  One can think of the shellç
stack as containing not just, say, four commands but rather four groups ofç
commands.  The shell stack not only holds these commands; it also providesç
the mechanism for grouping them, for providing parentheses, if you will. ç
The Z2 approach to shelling would have a very hard time doing this.  Forç
example, if the first element on the shell stack contains the command lineç
"CMD1A;CMD1B" and the next lower element the line "CMD2A;CMD2B;CMD2C", theç
equivalent Z2 situation would have the command line

	CMD1A;CMD1B;CMD2A;CMD2B;CMD2C

The SHCTRL POP command removes an entire Z3 shell entry, containingç
possible multiple commands.  How could we implement this function with aç
Z2-style shell?  Even if each command were marked with a "/s" token, oneç
could still not tell which ones were grouped with which.  There might be aç
solution to this problem, but the Z3 shell approach certainly handles itç
nicely.

   Mr. Ott's letter included a very interesting application example.  I'veç
made a few changes that, I hope, do not harm its essence.  When the computerç
is booted, the STARTUP alias loads the command sequence "FIRSTSH;MENU",ç
where FIRSTSH is a special utility that places the following commandç
sequence onto the shell stack:

	PARK;VID RST.MSG;STOP

When this sequence runs, it will park the heads on the disk drive, display aç
message to shut off the computer, and run a program called STOP that locksç
the machine.  Of course, this multiple-command shell could easily beç
replaced by an alias SHUTDOWN.

   This termination shell does not run immediately because of the commandç
MENU following it in the command sequence.  This loads a second shell ontoç
the shell stack.  The user then lives inside the MENU shell for some time. ç
At some point, the user may make a selection that generates the command "CDç
WORK:".  This would log into the WORK: directory and issue an automatic STç
command there.  The ST alias might have the script

	LDR WORK.NDR;SHCTRL POP;ZFILER

This would install a new set of named directories, pop MENU off the shellç
stack, and replace it with the ZFILER shell.  The user could then do someç
work using ZFILER.  From ZFILER, a macro command might make another shellç
change by popping the shell stack and installing another shell.

   The above process would continue until the user made an exit selection. ç
This would pop the shell stack without installing a new shell.  As a result,ç
that first line we put on the shell stack would become active, forcing theç
computer to be shut down in an orderly, preplanned way.  Of course, thisç
approach is not totally foolproof if the user has access to the power switchç
or power cord.  But it certainly helps.

   Mr. Ott worried that this example could not be achieved using a Z2 shellç
system.  I think it could, though not with quite the same ease and elegance. ç
The STARTUP alias would contain the line

	MENU;SHUTDOWN

When MENU ran, it would substitute for itself in the command line theç
desired command line plus its own reinvocation command with the flag "/S" toç
mark it as a shell.  Thus the command line would become

	USERCMD;MENU /S;SHUTDOWN

For the user command CD WORK:, the command buffer would evolve as follows:

	CD WORK:;MENU /S;SHUTDOWN
	ST;MENU /S;SHUTDOWN
	LDR WORK.NDR;SHCTRL POP;ZFILER;MENU /S;SHUTDOWN

When the SHCTRL command ran, it would scan the command line for the nextç
shell command as marked by the "/S" flag and remove it from the commandç
line.  This would leave one with

	ZFILER;SHUTDOWN

When ZFILER generates a macro command, the command buffer would have

	MACROCMD;ZFILER /S;SHUTDOWN

This would continue until one cancelled the shell.  Then the SHUTDOWN aliasç
would run.

   Mr. Ott was concerned that the command line would grow longer and longerç
as old shell commands piled up.  Indeed, this would happen if there were noç
'popping' mechanism.  The "/S" marker I proposed in my previous columns isç
critical here, since without it there would be no way to tell which commandç
to pop.  This approach, I think, would fail with aliases as shell commands. ç
The Z3-type shell really helps us in this case.


                  High-Level-Language Support for Z-System

   I have some especially exciting news about the first high level languageç
specially designed for Z-System.  In late January, I got a phone call fromç
Leor Zolman, author of BDS C.  He was interested in bringing out a newç
version of his C compiler for the modern 8-bit market.  After someç
consultation with me on what was needed to support Z-System, Leor went toç
work on the run-time code, and in less than two weeks he had a version readyç
for beta testing

   He came over to my house to demonstrate the result, and I was amazed toç
see how easily one could write a utility, complete with named-directoryç
support, even including password protection.  A little fine-tuning is stillç
needed, but I am already excited about the impact that the availability ofç
this quality high level language will have on Z-System development. ç
Marketing details have not been worked out at this point, but you can expectç
the new BDS C to be available at an attractive price through Z Systemsç
Associates (ZSA) channels (Plu*Perfect Systems, Sage Microsystems East, Z≠
Nodes, and Z-Plan user groups).


                           The New Z-Node Central

   Ron Bardarson, who had operated Z-Node Central after David McCord retiredç
as the sysop, decided to change the focus of his system and his nodeç
designation from Z-Node to X-Node.  This was to indicate its experimentalç
nature and its focus on software and systems development rather than on theç
distribution of Z-System software.  Its number remains 408-432-0821 (CASJOç
on PC-Pursuit).

   To maintain a center of support for Z-System users and for Z-Node sysops,ç
we have established a new Z-Node Central.  Richard Jacobson, whose Lilliputeç
Z-Node in Chicago has long been, in my opinion, the premier Z-Node in theç
country, has agreed to take on this new role.  He will continue to use theç
delightfully ironic Gulliverian name (at over 100 Mbytes, his is the leastç
Lilliputian of the Z-Nodes), but his node number now drops from 15 to 1.

   This new function is added to several special services that Lilliputeç
already provides.  It is the official bulletin board and remote accessç
system for both the North American One Eighty Group (NAOG) and TCJ.  Theç
full system, comprising two independent computers, is available on aç
subscription basis.  All users who provide registration information will getç
15 minutes per day of free access.  Unlimited access to both computersç
(within reason) is available at a rate of $25 for six months or $40 for aç
full year.  TCJ subscribers and NAOG members get free access to limitedç
areas and can upgrade to full subscriber privileges at $5 less than theç
standard rates.  Z-Node sysops will have free access to the full system. ç
The phone numbers are 312-649-1730 and 312-664-1730, accessible via theç
ILCHI outdial of PC-Pursuit.


                       System Security Under Z-System

   As part of my plan to build up the network of Z-Nodes, I would like toç
begin a series on issues related to setting up a remote access system (RAS)ç
using Z-System.  Many people do not realize it, but NZCOM and Z3PLUS (theç
automatic Z-Systems for CP/M-2 and CP/M-Plus, respectively) create systemsç
with the full security capability necessary for a RAS.  It just takes a fewç
simple operations to engage it.

   These issues have been brought to my attention recently because I haveç
been in the process of setting up a second remote access system at my house. ç
This one is for the BOSKUG group of the Boston Computer Society.  It will beç
a two-line system running on a very powerful 16 MHz Kaypro 286 computer withç
multitasking software.  For all this power, however, I was struck by theç
tremendous complexity of setting up a remote system on such a computer, allç
because of the lack of a secure operating system.

   With MS-DOS, a remote system absolutely cannot allow a caller to gainç
direct access to the operating system command prompt, because once he hasç
that access, there is no way to limit what he can do.  It made me realizeç
how fortunate we are with Z-System to have an operating system with enoughç
security to permit callers on a remote system to run the system more or lessç
as if they were sitting at the keyboard of their personal machine.  Theyç
don't have to have an elaborate apparatus standing between them and theç
system.

   There are two main aspects of that security.  One is the wheel byte. ç
This system flag is tested by many Z-System programs to determine whetherç
certain operations should be permitted or denied.  Commands for doing thingsç
like erasing, renaming, or copying files typically require that wheel statusç
be in force.  Other commands will allow some operations to non-wheel usersç
but deny other operations.  For example, some directory programs allowç
writing an image of the directory to disk or to the printer.  These optionsç
are (or should be) restricted to 'wheel' users.  The wheel byte itself isç
set and cleared by special commands, such as the WHL command of the RCP. ç
Obviously, a password must be entered correctly before WHL will set theç
wheel byte.

   The second and more complex security feature in Z-System concerns theç
facilities for limiting the disk areas which a user can access.  Many usersç
are unaware of these features, and even those who are aware of them often doç
not understand them fully and clearly.  I will cover the major points here.

   With version 3.3 of ZCPR, I introduced extensive and significant changesç
in the way directory references and security are handled.  These changesç
made understanding security more complex for the system implementor but muchç
easier and less intrusive for the user.

   ZCPR3 supports two basic forms of directory reference, the disk/user orç
DU form and the named directory or DIR form.  We will assume that the readerç
is already somewhat familiar with the basic concepts.  The DU form is nativeç
to CP/M, which knows about disk drives from 'A' to 'P' and user numbers fromç
0 to 31 (though there are restrictions on user numbers above 15).  The DUç
form of directory reference is basically physical in nature.  Drive lettersç
are associated with real physical devices, and the files in all user areasç
associated with a given drive letter are stored on the same physical device. ç
One can think of this directory structure as spanning a flat, two≠
dimensional space (in contrast to the hierarchical tree-structuredç
directories of Unix or MS-DOS).

   While the DU directories are basically physical, named directories areç
purely logical constructs.  The named directory register (NDR) module in aç
Z-System contains a mapping of directory names to drive/user values.  Theç
user can load different sets of directory associations at different times. ç
Thus, unlike the static (fixed in time) directory structure of Unix and MS≠
DOS, the directory structure of Z-System can be dynamic (changing in time).

   When the DIR form is used, the command processor or a Z-System programç
looks for the name in the NDR and substitutes the drive and user values. ç
Only drive/user values are used in the actual file references processed byç
the disk operating system (DOS).  Named directories provide two differentç
and important functions.  One is convenience.  It is much easier to rememberç
that one's assembly language tools are in ASM and one's wordprocessing filesç
in TEXT than it is to remember that the directories are A7 and B13.  Theç
second purpose of named directories is to provide security.

   Access to directory areas in a Z-System is controlled in both the DU andç
DIR domains.  Under Z30 these two control mechanisms were completelyç
independent; under Z33 and later, as we shall see, they are very closelyç
coupled.  The limits in the DU domain are set by values in the environmentç
descriptor (ENV) called max-drive and max-user.  They define a rectangularç
area of allowed directories in the flat directory space, with drive valuesç
ranging from 'A' to the drive specified by max-drive and user numbersç
ranging from 0 to the number specified by max-user.  The smallest spaceç
still includes the boot directory A0.

   Named directories offer a more flexible means of controlling access toç
areas on a system.  The user can access a named directory even if it refersç
to a DU area that is beyond the bounds defined above.  Each directory nameç
can have an optional password associated with it.  Whenever a reference isç
made to such a directory, the password is (should be) asked for and accessç
granted only if it is entered correctly.

   There are a number of important exceptions to the two security limitsç
described above.  One concerns the command search path specified in the Z≠
System PATH module.  No restrictions whatever are imposed on the DU areasç
specified there.  If the user was able to place a directory into the path,ç
then it will always be scanned as necessary by the command processor, evenç
if it would no longer be explicitly accessible.

   Another general exception occurs for the standard (but optional)ç
configuration of the command processor called WPASS.  With this option, whenç
the wheel byte is set, directory passwords are ignored.  The user can thenç
freely make reference to any directories either within the specified DUç
range or associated with a named directory (with or without a password).

   Versions of the command processor since Z33 also make the assumption thatç
if a user is in a given directory at the present time he must have had theç
authority to get there.  Therefore, the command processor will always acceptç
any reference to the currently logged directory, even if the DU is out ofç
range and it has no unprotected directory name.

   Another set of exceptions relates to the interplay of the DU and DIRç
limits.  Recent versions of the command process act on the principle that ifç
reference to a directory in one form (DU or DIR) would be allowed thenç
references using the alternative form should be equally allowed.  Forç
example, suppose that the max DU limit is set to B3 and that directory C4ç
has the name DIRNAME with no password.  Z30 would have refused to accept aç
reference to C4:, even though it would have no complaints about DIRNAME:. ç
Under Z34, either would work.  Conversely, if directory area A3 in theç
example had a directory name PRIVATE with password SECRET, Z30 would allow aç
reference to A3: but would insist on correct password entry if the referenceç
was made as PRIVATE:.  Again, Z34 always checks the alternate form ofç
reference, and if either meets the security restrictions, then both areç
accepted.

   The standard version of Z-System created by NZCOM or Z3PLUS has the maxç
DU limit set to P31.  Thus all directories are allowed using the DU format. ç
As a result, even when named directories with passwords are created, theyç
are accepted freely.  In order to create a secure system, the values of max≠
drive and max-user must be reduced.  Also, since password checking isç
bypassed when the wheel byte is set, the wheel byte must be cleared beforeç
the security limits imposed by directory passwords will take effect.  Onceç
those two changes have been made, your NZCOM/Z3PLUS system is ready to serveç
as a remote access system.

                                                           