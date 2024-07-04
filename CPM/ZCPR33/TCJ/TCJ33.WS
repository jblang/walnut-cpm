
                              The ZCPR Corner

                                TCJ Issue 33


     For my column this time I plan to cover two subjects, both of which I�
have dealt with somewhat at length in the past.  Nevertheless, there just�
seems to be a lot more to say on these subjects.  The first is ARUNZ; the�
second is shells in general, and the way WordStar 4 behaves (or rather�
misbehaves) in particular.

     I was quite surprised and pleased by the enthusiastic response to my�
detailed treatment of ARUNZ in issue 31.  Apparently, there were many, many�
people who were unaware of what ARUNZ was and who are now quite eager to put�
it to use.  There are two specific reasons for taking up the subject of�
ARUNZ here again so soon.

     First of all, I think that readers will benefit from a discussion of�
some additional concrete examples.  Since my own uses are the ones I know�
best, I plan to take the ALIAS.CMD file from my own system as an example and�
discuss a number of interesting scripts.  My first cut at doing that for�
this column came out much too long, so I will cover half of the file this�
time.  The other half will be covered in the next column.

     The second reason is that I have just gone through a major upgrade to�
ARUNZ.  It is now at version 0.9J.  Several aspects of its operation as�
described in my previous column have been changed, and quite a few new�
parameters have been added.

     The changes in ARUNZ were stimulated by two factors.  One is the two�
new dynamic Z Systems that will have been released by the time you read�
this: NZCOM for Z80 computers running CP/M 2.2 and Z3PLUS for Z80 computers�
running CP/M-Plus.  These two products represent a tremendous advance in the�
concept of an operating system, and everyone interested in experimenting�
with or using Z System -- even if he already has a manually installed ZCPR3�
running now -- should get the one that is appropriate to his computer.

     With these new Z System implementations, if your level of computer�
skill is high enough to run a wordprocessor or menu program, then you can�
have a Z System designed to your specifications in a matter of minutes.  You�
can change the design of your Z System at any time, even between�
applications.  As described later, ARUNZ now has some parameters to return�
addresses of system components so that aliases can work properly even when�
those system components move around, as they may do under these dynamic�
systems.


My New Computer System

     The second impetus came from my finally building for myself a state-of�
the-art computer!  For most of my work in the past I have used a BigBoard I�
with four 8" floppy disk drives and an SB180 with four 5" disk drives. �
Neither machine had a hard disk.

     The SB180, my main system for the past year and a half, had been�
sitting on the floor in the study.  The pc board was mounted in a makeshift�
chassis with two power supplies, just as I got it from someone who bought it�
at the Software Arts liquidation auction and after they had stripped out the�
disk drives (at $25 I could hardly complain!).  I added my own drives, which�
sat in the open air (for cooling among other reasons) in two separate drive�
cabinets elsewhere on the floor.  All in all not very pretty and not as�
functional as it could have been.

     The sad part of it is that during all this time I had everything needed�
to turn the SB180 into an enjoyable and productive system.  A high-speed 35�
Mb hard disk was collecting dust on a shelf; an attractive surplus Televideo�
PC-clone chassis adorned the work bench in the basement; the XBIOS software�
disks sat ignored in one of my many diskette boxes.

     Finally one weekend I decided that it would be more efficient in the�
long run to take some time off from my programming and writing work to�
reconstruct the system.  Indeed, it has been!  The SB180 is now attractively�
mounted in the Televideo chassis with one 96-tpi floppy and one 48-tpi�
floppy.  The hard disk is configured as four 8 Mb partitions and runs very�
nicely with the fast Adaptec 4000 controller.

     With the hardware upgraded, I then did the same to the software. �
Installing XBIOS on the SB180 took so little time that I really had to kick�
myself for not doing it sooner.  Richard Jacobson was quite right in his�
description of it in issue 31.  Thank you, Malcom Kemp, for a really nice�
product.

     Once I was fixing things up, I decided I should really do it up right,�
so I also purchased the ETS180IO+ board from Ken Taschner of Electronic�
Technical Services -- this despite the fact that a Micromint COMM180 board�
was also a part of my longstanding inventory of unused equipment.  I cannot�
compare the ETS board to the COMM180, never having used the latter, but I�
certainly am highly pleased with it.  XBIOS includes complete support for�
the ETS board, so configuring the system to make use of the extra ETS180IO+�
features, like the additional parallel and serial ports and the battery�
backed clock, was very easy.

     I have been so pleased with the new system that I even went out and�
bought a real computer table for it to sit on.  For the past years, the�
terminal's CRT unit had been sitting on one of those flimsy folding dining�
room utility tables, with a yellow-pages phone book under it to jack it up�
to the right height.  The keyboard sat on a second folding table, and the�
whole thing was always in imminent danger of toppling over.  What a pleasure�
it is to sit at the new system.

     While I'm waxing enthusiastic, let me mention one other thing I did to�
reduce the disarray in the study.  I bought four Wilson-Jones media drawers�
to house my vast collection of floppies.  These diskette cabinets resemble�
professional letter filing cabinets.  A drawer, which can hold more than 100�
floppies, pulls out on a full suspension track so that one can easily reach�
all the way to the back.  Since there is no top to flip open, units can be�
stacked on top of each other to save a great deal of table space.  Clips are�
provided to secure the units to their neighbors both horizontally and�
vertically.

     The only drawback to these disk drawers has been their cost.  Inmac and�
the other major commercial supply houses want more than $60 each!  But�
Lyben, which sends its catalogs out to many computer hobbyists, offers them�
for only $35.  Extra dividers, which I recommend, are just under $6 per�
package of five.  Lyben can be reached at 313-589-3440 (Michigan).  [Note�
added at last moment -- I am sorry to say that I just received the new Lyben�
catalog, and the price has now gone up to $45.  Although this is still a�
bargain when compared to other vendors' prices, I'm glad I put in my order�
when I did.]


                             ARUNZ VERSION 0.9J

     Now that I have had my chance to show my excitement over the new state�
of my computer and computer room, let's get on with the discussion of ARUNZ. �
First we will discuss the changes introduced since version 0.9G, both the�
old features that have changed and the new features that have been�
introduced.


Changes in Old Features
-----------------------

     Because, as noted in my last column, ZCPR34 can pass commands�
containing explicit file types or wildcard characters ('?' and '*'), the�
characters used to define special matching conditions in the alias names in�
ALIAS.CMD had to be changed.  The period, which had been used to indicate�
the beginning of optional characters in the alias name, has been replaced by�
the comma.  The question mark had been used to indicate a wild-character�
match in the alias name.  Since it can now be an actual character to be�
matched, the underscore has replaced it.

     Since the command verb can now include an explicit file type (not�
necessarily COM) and/or a directory prefix, several changes have been made�
to the parameters that parse the command verb.  In general, all of the�
command line tokens are now treated in the same way; all four token parsing�
parameters ('D', 'U', ':', and '.') now work with digits from 0 to 9 and not�
just 1 to 9.  Thus the command line

	C3:TEST>arunz b12:test.z80 commandtail

or, with ARUNZ running as the extended command processor (ECP), the command

	C3:TEST>b12:test.z80 commandtail

will have the following parameter values for token 0, the command verb:

	$D0	B
	$U0	12
	$:0	TEST
	$.0	Z80

THIS IS A SIGNIFICANT CHANGE.  PLEASE TAKE CAREFUL NOTE OF IT.  The�
parameters $D0 and $U0 no longer necessarily return the logged in drive and�
user.  For the standard configuration of ZCPR33 (and 34) a verb of the form�
B12:TEST cannot be passed to the extended command processor; the presence of�
an explicit directory specification results in the immediate invocation of�
the error handler (skipping the ECP) if the file cannot be found in the�
specified directory.  However, if a file type is included, the 'bad' command�
will be passed to the ECP.


New Features

     There are now three new parameters that do return information about the�
directory that was current (logged in) when ARUNZ was invoked.  These�
parameters are shown below with their meaning and the values they would have�
with the example command above:

      parameter              meaning			value
      ---------		     -------			-----
	$HD		Home Drive (D)			  C
	$HU		Home User (U)			  3
	$HB		Home Both (i.e., DU)		  C3

     There is also a new parameter to denote the entire command line,�
including both the command verb and the command tail.  Many people in the�
past confused "command line" with "command tail" and attempted to use the�
parameter $* for the former.  The new parameter is '$!'.  It is roughly�
equivalent to '$0 $*', but there is one important difference.  The latter�
parameter expression always includes a space after the command verb, even if�
there was no tail ('$*' was null).  This space caused problems with some�
commands.  For example, when the SLR assembler SLR180 is invoked with�
nothing after it, it enters interactive mode and allows the user to enter a�
series of assembly requests.  Unfortunately, the code is not smart enough to�
distinguish a completely nonexistent command tail from one with only spaces. �
When the command "SLR180_" is entered, where '_' represents a blank space,�
the assembler looks for a source file with a null name.  Not finding it, it�
returns with an error message.

     I used to deal with this problem by writing a complex alias of the�
form:

	SLR180	if nu $*;asm:slr180;else;asm:slr180 $*;fi

With the new parameter, all this complication can be avoided.  The script is�
simply:

	SLR180	asm:$!

If you are wondering why one would want an alias like this, just wait a�
while.  It will be explained later.

     There is also a whole set of new parameters that generate the addresses�
of almost all of the Z System modules.  This capability will become�
important with the dynamic Z Systems now being introduced (NZCOM and�
Z3PLUS).  With those systems, the addresses of the RCP, FCP, CCP, and so on�
can all change during system operation.  The new parameters permit one to�
make reference to the addresses of those modules even when they move around. �
My ALIAS.CMD file described below will have some examples of how these�
parameters are used.

     These parameters begin with $A ('A' for address) and are followed by an�
additional letter as follows:

	B	BIOS			L	MCL (command Line)
	C	CCP			M	MSG (message buffer)
	D	DOS			N	NDR
	E	ENV			P	PATH
	F	FCP			R	RCP
	I	IOP			S	STK (shell stack)
					X	XFCB (external FCB)

Amazingly enough, these names are all mnemonic except for the conflict over�
'M' between the multiple command line buffer (MCL) and message buffer (MSG). �
I resolved this by using 'L' (think of LINE) for the MCL.

     Finally, there is a new symbol that can be used to make a special kind�
of alias name specification in ALIAS.CMD.  If a name element begins with a�
'>', then only the file type of the command verb is used in the comparison. �
Without this feature one had to use very complex forms to recognize a file�
type.  For example, suppose you want to be able to enter the name of a�
library file as LBRNAME.LBR as a command and have VLU invoked on it.  The�
following script used to be required:

	?.LBR=??.LBR=???.LBR=????.LBR=?????.LBR=??????.LBR=
	  ???????.LBR=????????.LBR   vlu $0

Every possible number of characters in the library name had to be dealt with�
explicitly.  With the new symbol and the other ARUNZ09J features, one can�
define this script more simply as follows:

	>LBR	vlu $:0


Example ALIAS.CMD File

     Now that we have described the new resources available in ARUNZ09J, we�
will begin our look at part of the ALIAS.CMD file that I am using right now�
on the SB180.  It will be the second half of the file, because that part�
contains some items of immediate relevance.

     First some words of philosophy.  There are many ways in which Z System�
can be used effectively, and I am always amazed and impressed at the�
different styles developed by different users.  What I will now describe is�
my approach.  As they say, yours may differ!  In any case, I hope these�
comments will stimulate some good ideas, and, as always, I eagerly await�
your comments and suggestions.

     I am a strong believer in short search paths.  When I make a mistake in�
typing a command, I do not want to have to twiddle my thumbs while the�
command processor thrashes through a lot of directories searching for the�
nonexistent command.  I want the error handler to take care of it as quickly�
as possible.  As a result, the search path on my SB180 includes only one�
directory, A0, the RAM disk.  (With XBIOS, the RAM disk can be mapped to the�
A drive.)

     When I enter a command, it is searched for only in A0.  If it is not�
found there, then ARUNZ (renamed to CMDRUN.COM) is loaded from A0, and it�
looks for a script in ALIAS.CMD, also in A0.  If ARUNZ cannot resolve the�
command, then the error handler, EASE in my case, is invoked (you guessed�
it, also on A0).  Thus no directory other than the RAM disk is accessed�
except by an explicit directory reference generated either by an alias�
script or by a manually entered command.  Everything appears to operate�
instantaneously.


Aliases to Provide Explicit Directory Prefixes

     Obviously, I cannot keep all the COM files that I use in directory A0. �
In fact, with the tiny RAM disk on the SB180 (and allowing about 100K for a�
BGii swap file), there is barely enough room for CMDRUN.COM (ARUNZ),�
ALIAS.CMD, EASE.COM, EASE.VAR, IF.COM, ZF.COM (ZFILER), ZFILER.CMD,�
SAVSTAMP.COM, ZEX.COM, ZEX.RSX, and a few directory programs.  Fortunately,�
this is all that really needs to be there.

     So what do I do about all the other COM files that I want to use? �
There are two possibilities.  I could invoke them manually with explicit�
directory references, as in "B0:CRC FILESPEC", but this would clearly be a�
nuisance (and contrary to the spirit of Z System!).  The other alternative�
is to provide alias definitions in ALIAS.CMD for all the commands in other�
directories that I want to use.

     A second half of my ALIAS.CMD file is shown in Listing 1.  The group of�
aliases at the very end comprises several sets of definitions that do just�
what I have described for several of the directories on the hard disk.  As I�
use programs in other directories, I add them to the ALIAS.CMD file.

     These aliases are included at the end, by the way, so that other�
definitions can preempt them as desired.  If you look carefully, you will�
see some aliases defined here that are also defined earlier in the ALIAS.CMD�
file.  The earliest definition always takes precedence, because ARUNZ scans�
ALIAS.CMD from the beginning and stops as soon as it encounters a matching�
name specification.

     Directory B0, named SYS, contains most of my system utilities. �
Directory B1, named ASM, contains my assembly language utilities.  A few�
commonly used files are in other directories.  The aliases defined in these�
sections do nothing more than add an explicit directory prefix to the�
command entered.  For example, the script definition

	AFIND	b0:$!

would take my command line "AFIND TAIL..." and turn it into "B0:AFIND�
TAIL...".  Note how compact the definitions can be.  You do not need a�
separate line for each command.  Similar scripts could be constructed, by�
the way, for COM files kept in COMMAND.LBR and extracted and executed by LX. �
I do not use LX, so I have no examples to show.

     There are several fairly easy ways to automate the construction of�
these entries in the ALIAS.CMD file.  If you use PMATE or VEDIT as your text�
editor, you can write macros that will perform the entire process.  That is�
how I generated the aliases you see.  With the PMATE macro, I can easily�
repeat the process from time to time to make sure that all my COM files are�
represented by aliases.    So far I have run my PMATE macro on user areas 0,�
1, 2, 3, and 4 of hard disk partition B.

     Lacking these tools, you can run "SD *.COM /FX" to get a file DISK.DIR�
containing a horizontally sorted listing of all the COM files in a directory�
(without going to a lot of trouble, I do not get a sorted listing from�
PMATE).  Then use your favorite editor, whatever it is, to add carriage�
returns so that each file is on its own line and to delete all of the text�
after the file name (i.e., the dot, file type, and file size).  If there are�
any commands for which you want to have special aliases (we'll see some�
examples shortly), you may delete their names from the list (or you can�
leave them -- they do no harm).  Then close up the list, inserting equal�
signs and, when the line is wide enough, add the command script.  Finally,�
merge this with the rest of your ALIAS.CMD file.


Aliases for Special Command Redefinitions

     Just before the simple redefinition aliases there are six commands that�
have been separated out for special treatment.  Consider the first of them:

	ZP,ATCH		b0:zpatch $*

I find that my fingers have some difficulty typing the full ZPATCH�
correctly, and this alias permits me to enter simply ZP.  Note that in this�
case we cannot use "b0:$!" for the script because the alias name allows for�
forms other than an exact ZPATCH.  If the script used the $! parameter and�
the command was entered as ZP, then the expanded script would become "B0:ZP�
...", which would not work.

     The alias for crunching is similar in some respects but more elaborate. �
The letter combination CH must give me trouble, because I often type CRUNCH�
wrong, too, unless I work very carefully.  This alias not only lets me use�
the short form CR; it also allows the command to work with named�
directories.

	CR,UNCH	 	b0:crunch $d1$u1:$:1.$.1 $d2$u2:

By expanding the first and second parameters explicitly, named directory�
references can be converted to the DU: form that CRUNCH can deal with.

     The alias for DATSWEEP goes a little further than the other two insofar�
as alternative forms are concerned.

	DATSW,EEP=DS=SWEEP	b0:datsweep $*

It allows abbreviated forms as short as DATSW, but it additionally allows�
alternative nicknames for the command, such as DS or the more familiar�
SWEEP, which it replaces on my system.

     The next example in this section shows how a program that does not know�
about Z System file specifications at all can be made to work with them�
anyway.

	LDIR		$d1$u1:;b0:ldir $:1;$hb:

For LDIR I just started to use LDIR-B, which displays date stamp information�
about files in the library.  Unfortunately, it does not know about named�
directories; in fact, it does not even know anything about user numbers.  If�
he is true to form, Bruce Morgen, the Intrepid Patcher, will soon have a�
ZLDIR-B or an LDRZ-B that will accept full Z System file specs, and I will�
be able to retire this alias.

     At present, however, LDIR-B accepts only the standard CP/M syntax for�
files.  As a result, it is not enough simply to pick apart the token, as it�
would be if LDIR would accept the form DU:NAME.TYP.  Instead, the directory�
specified for the library is logged into, then the LDIR command is run on�
the library name, and finally the original directory is relogged.  This will�
work very nicely unless the user number specified is higher than 15 (and�
your Z33/Z34 is not configured for logging into high user numbers).

     The last two examples in this series illustrate still another way to�
make aliases lighten the typing burden.  With XBIOS, alternative versions of�
the operating system are described in model files.  These typically have a�
file type of MDL, but that type is not required or the default. �
Consequently, the SYSBLD system-defining utility and the XBOOT system�
loading utility must be given an explicit file type.  Since I always use MDL�
for the type, I created these aliases to add the file type for me so that I�
can enter the commands simply as "SYSBLD TEST" or "XBOOT BIGSYS".

	SYSBLD			b0:;b0:$0 $1.mdl;$hb:
	BOOT=XBOOT		b0:;b0:xboot $1.mdl

The XBOOT alias lets me save a little typing by omitting the leading 'X' if�
I wish.  The SYSBLD alias returns to the original directory when it is�
finished.  Since XBOOT coldboots a new operating system, any trailing�
commands are lost anyway.  The XBOOT command will soon support a warmboot�
mode, in which, like NZCOM and Z3PLUS, the new system is created without�
affecting the multiple command line, shell stack, or other loaded system�
modules that have not changed their address or size.  I might then add an�
alias REBOOT or WBOOT (warmboot) that will load a new system and return to�
the original directory.


Memory Display Aliases

     In my system development work I often have occasion to examine various�
parts of memory.  I might want to look at the beginning of the BIOS to check�
the hooks into an RSX (resident system extension), or I might want to see�
the contents of the ZCPR3 message buffer to see how some flags are being�
used.

     I used to have a set of aliases like these with explicit addresses in�
the script ("P FE00" to look at the ENV, for example).  This relieved my�
mind of the task of remembering the addresses where these modules were�
located in memory.  With the new dynamic systems, even a good memory will�
not suffice, since the modules can move around, and one can not easily be�
sure just where they are at any given time.

     By using the new parameters that I described earlier, the scripts�
always have the correct addresses.  [Actually, they can still be fooled if�
these parameters are used in multiple-command-line scripts that include the�
loading of a new dynamic system.  As I warned in my earlier article on�
ARUNZ, all parameters are expanded at the time the alias is invoked.  If the�
system is changed after that, the parameter values may no longer be correct�
when that part of the script actually runs.]


=============================================================================


 ; Memory display aliases

PBIOS=BIOS		p $ab
PCCP=CCP=CPR		p $ac
PDOS=DOS		p $ad
PENV=ENV		p $ae
PFCP=FCP		p $af
PIOP=IOP		p $ai
PMCL=MCL		p $al
PMSG=MSG		p $am
PNDR=NDR		p $an
PPATH			p $ap
PRCP=RCP		p $ar
PSHL=PSHELL=SHL=SHELL	p $as
PXFCB=XFCB=PFCB=FCB	p $ax

 ; Special equivalents

ZP,ATCH			b0:zpatch $*
CR,UNCH		 	b0:crunch $d1$u1:$:1.$.1 $d2$u2:
DATSW,EEP=DS=SWEEP	b0:datsweep $*
LDIR			$d1$u1:;b0:ldir $:1;$hb:
SYSBLD			b0:;b0:$0 $1.mdl;$hb:
XBOOT=BOOT		b0:;b0:xboot $1.mdl

 ; Complete set of direct equivalents

CMDRUN=LPUT=EDIT0=ERA=IF=REN=SD=SDD=XD=ZEX=ZF=VLU=W=ZPATCH=COPY=ECHO	b0:$!
FF=GOTO=JF=JETLDR87=NULU=PWD=SAVE=SP=UNCR=VTYPE=XDIR=AFIND=SALIAS=AREA	b0:$!
BD=CRUNCH=DFA=DIFF=DISKRST=DOSERR=DU=EDITNDR=ERRSET=HSH=ALIAS		b0:$!
LLF=LGET=LOADNDR=LPUT14=LT23=LUSH=LX=MOVE=MU3=PATH=PAUSE=PIP=PROT	b0:$!
PROTCCP=PUBLIC=PUTDS=Q=SAP=SAVENDR=SAVSTAMP=SFA=SHCTRL=SHOW=SQ=STAT	b0:$!
SUB=SYSGEN=UF=UNERASE=XSUB=DATE=DATSWEEP=MKDIR=SHSET=TPA=Z3INS=Z3LOC	b0:$!
ZRIP=ASSGN=BSX=FVCD=HDINIT=HDUTIL=MDINIT=MPTEST=SETDFLT=STARTHD4=SWX	b0:$!
SYSBLD=XSYSGEN=TIME=XBOOT0=XVERS=MCOPY=LZED=PUTBG=STARTHD=STARTHD1	b0:$!
STRTFULL=LDR=JETLDR=LHC=SSTAT=XBOOT=MAP=STARTBIG=LT=LDIR=QL=SETD=CRC	b0:$!
4ERA=4MU3=4REN=4SAVE=T4MAKE=DOSVER=DRO=LOGGED=SRO=SRW=LBREXT		b0:$!

SLR180+=SLRNK=SLRNK+=Z80ASM=DDT=DSDZ=FORM7=MAKESYM=MLOAD=SLRMAC=XIZ	b1:$!
ZAS=ZLINK=ZXLATE=SLR180=180FIG32=180FIG+=LNKFIG+=SLRIB=ZLIB=ZREF	b1:$!
ZZCNFG=LNKFIG=180FIG							b1:$!

BGSERIAL=LOADBG=STARTBG=BGPRINT=BGPRNCFG=DSCONFIG=Q=REMOVE=SECURE	b2:$!
SETBG=SPOOLER=DATSWEEP=SDD=SETTERM					b2:$!

INSTALL=MEX								b3:$!

WSCHANGE=WS=WINSTALL=MOVEPRN						b4:$!
Listing 1.  The second half of the ALIAS.CMD file from my SB180 with XBIOS,�
slightly shortened and rearranged.

=============================================================================

                       Shells and WordStar Release 4


     As I noted in an earlier column, WordStar Release 4 was a very exciting�
event for the CP/M world in general and the Z-System world in particular. �
It was the first major commercial program to recognize Z System and to make�
use of its features.  Unfortunately, the Z System code in WS4 was not�
adequately tested, and many errors, some quite serious, slipped through. �
Some of the most significant errors concern WS4's operation as a ZCPR3�
shell.

     Let's begin with a little background on the concept of a shell in ZCPR. �
Normally, during Z System operation the user is prompted for command line�
input.  This input may consist of a string of commands separated by�
semicolons.  When the entire sequence of commands has been completed and the�
command line buffer is again empty, the user would be prompted again for�
input.

     This prompting is performed by the ZCPR command processor, which,�
because it is limited in size to 2K, is correspondingly limited in its�
power.  Richard Conn, creator of ZCPR, had the brilliant idea of including a�
facility in ZCPR3 for, in effect, replacing -- or, perhaps better said,�
augmenting -- the command processor as a source of commands for the system. �
This is the shell facility.

     Under ZCPR3, when the command processor finds that there are no more�
commands in the command line buffer for it to perform, before it prompts the�
user for input, it first checks a memory buffer called the shell stack.  If�
it finds a command line there, it executes that command immediately, without�
prompting the user for input.  The program run in that way is called a�
shell, because it is like a shell around the command processor kernel.  The�
shell is what the user sees instead of the command processor, and the shell�
will normally get commands from the user and pass them to the command�
processor.  In effect, the outward appearance of the operating system can be�
changed completely when a shell is selected.

     A perfect example of a shell is the EASE history shell.  To the user it�
looks rather like the command processor.  But there are two very important�
differences.  First of all, the command line editing facilities are greatly�
augmented.  One can move the cursor left or right by characters, words, or�
commands; one can insert new characters or enter new characters on top of�
existing characters; characters or words can be deleted.  One has, in a way,�
a wordprocessor at one's disposal in creating the command line.

     The second feature is the ability to record and recall commands in a�
history file.  Many users find that they execute the same or similar�
commands repeatedly.  The history feature of EASE makes this very�
convenient.  These two command generation features require far too much code�
to include in the command processor itself, so it is very convenient to have�
the shell capability.

     Programs designed to run as shells have to include special code to�
distinguish when they have been invoked by the user and when they have been�
invoked by the command processor.  ZCPR3 makes this information available to�
such programs.  When invoked by the user, they simply write the appropriate�
command line into the shell stack so that the next time the command�
processor is ready for new input, the shell will be called on.  After that,�
the user sees only the shell.  Shells normally have a command that the user�
can enter to turn the shell off.

     ZCPR3 goes beyond having just a single shell; it has a stack of shells. �
A typical configuration allows four shell commands in the stack.  When the�
user invokes a command designed to run as a shell, it pushes its name onto�
the stack.  When the user cancels that shell, any shell that had been�
running previously comes back into force.  Only when the last shell command�
has been cancelled (popped from the shell stack) does the user see the�
command processor again.

     Let's look at some of the shells that are available under Z System.  We�
have already mentioned the EASE history shell.  There is also the HSH�
history shell, which offers similar capabilities.  It was written in C and�
cannot be updated to take advantage of innovations like type-3 and type-4�
commands.  I would say that EASE is the history shell of choice today.  This�
is especially true because EASE can do double service as an error handler as�
well, with the identical command line editing interface.

     Then there are the menu shells, programs that allow the user with just�
a few keystrokes to initiate desired command sequences.  They come in�
several flavors.  MENU stresses the on-screen menu of command choices�
associated with single keystrokes.  VFILER and ZFILER stress the on-screen�
display of the files on which commands will operate; the commands associated�
with keys are not normally visible.  Z/VFILER offer many internal file�
maintenance commands (copy, erase, rename, move, archive).  VMENU and�
FMANAGER are inbetween.  Both the files in the directory and the menu of�
possible commands are shown on the screen.


What Kind of Programs Should be Shells?

     Not all programs should be shells.  From a strict conceptual viewpoint,�
only programs that are intended to take over the command input function from�
the command processor on a semipermanent basis should be shells.  The�
history shells and the MENU and VMENU type shells clearly qualify.  One�
generally enters those environments for the long haul, not just for a quick�
command or two.

     ZFILER and VFILER are marginal from this viewpoint.  One generally�
enters them to perform some short-term file maintenance operations, after�
which one exits to resume normal operations.  It is rare, I believe, to�
reside inside ZFILER or VFILER for extended periods of time, though I am�
sure there are some users who do so.

     Many people (I believe mistakenly) try to set up as shells any program�
from which they would like to run other tasks and automatically return. �
This is the situation with WordStar.  No one will claim that the main�
function of WordStar is to generate command lines!  Clearly it is intended�
to be a file editor.  Why, then, was it made into a ZCPR3 shell in the first�
place?  I'm really not sure.

     WordStar's 'R' command really does not offer very much.  In neither the�
ZCPR nor the CP/M configuration does any information about the operating�
environment seem to be retained.  For example, one might expect on return to�
WordStar that the control-r function would be able to recall the most�
recently specified file name.  But this does not seem to be the case,�
although it could easily have been done.  In the ZCPR version, the name�
could be assigned to one of the four system file names in the environment�
descriptor; in the CP/M version it could be kept in the RSX code at the top�
of the TPA that enables WordStar to be reinvoked after a command is�
executed.

     The WordStar 'R' command does not save any time, either.  Essentially�
no part of WordStar remains in memory.  The user could just as well use the�
'X' command to leave WordStar, run whatever other programs he wished, and�
then reinvoke WS.  Nevertheless, I can understand why users would enjoy the�
convenience of a command like the 'R' command that automatically brings one�
back to WordStar.  Shells, however, are not the way to do this, at least not�
shells in the ZCPR3 sense.


ZCPR2-Style Shells

     In ZCPR2 Richard Conn had already implemented an earlier version of the�
shell concept which, interestingly enough, would be the appropriate way for�
WordStar and perhaps even ZFILER/VFILER to operate.  He did not have a shell�
stack, but he did have programs like MENU that, when they generated�
commands, always appended their own invocation to the end of the command�
line.  Thus if the menu command script associated with the 'W' key was "WS�
fn2", where fn2 represents system file name #2, then the actual command�
placed into the command line buffer would be "WS fn2;MENU".  In this way,�
after the user's command ran, the MENU program would come back.

     Let's compare how the two shell schemes would have worked with�
WordStar.  Suppose we want to edit the file MYTEXT.DOC and then copy it to�
our archive disk with the command "PPIP ARCHIVE:=MYTEXT.DOC".  We might have�
created the following alias script for such operations:

	WSWORK	ws $1;ppip archive:=$1

Then we just enter the command "WSWORK MYTEXT.DOC" when we want to work on the�
file and have it backed up automatically when we are done.

     Here is what WS4 does as a ZCPR3-type shell.  The command line starts out�
as:

	WSWORK MYTEXT.DOC

When the alias WSWORK is expanded the command line becomes:

	WS MYTEXT.DOC;PPIP ARCHIVE:=MYTEXT.DOC

When WordStar runs, it pushes its name onto the shell stack so that it will be�
invoked the next time the command line is empty.  Noting that the command line�
is not empty, it returns control to the command processor.  Then the PPIP�
command is executed, backing up our unmodified file (horrors!!!)  Finally the�
command line is empty and WS, as the current shell, starts running.  Since it�
was invoked as a shell, it prompts the user to press any key before it clears�
the screen to start editing.  By this time it has forgotten all about the file�
we designated and it presents us with the main menu.  All in all, a rather�
foolish and useless way to go about things.

     You might think that the problem would be solved if WS did not check for�
pending commands but went ahead immediately with its work.  Indeed, this would�
work fine until the 'R' command was used.  Then either the pending PPIP command�
would be lost (replaced by the command generated by the 'R' operation) or�
executed (if the 'R' command appended it to the command it generated).  In�
either case we have disaster!

     Now suppose WS4 had used the ZCPR2-style shell concept.  After the alias�
had been expanded, the "WS MYTEXT.DOC" command would run, and we would edit our�
file.  While in WS4, suppose we want to find where on our disks we have files�
with names starting with OLDTEXT.  We use the 'R' command to enter the command�
line "FF OLDTEXT".  The 'R' command would append ";WS" to the end the command�
we entered and insert it into the command line buffer before the current�
pointer, leaving the following string in the buffer:

	FF OLDTEXT;WS;PPIP ARCHIVE:=MYTEXT.DOC

After the FF command was finished, WordStar would be executed again.  Just what�
we wanted.

     In fact, under ZCPR3 WS could be much cleverer than this.  First of all,�
it could determine from the external file control block the name (and under Z33�
the directory) used to invoke WordStar in the first place.  There would be no�
need, as there is now, to configure WS to know its own name and to make sure�
that the directory with WS is on the command search path.  The 'R' command�
could have appended "B4:WSNEW" if WSNEW had been its name and it had been�
loaded from directory B4.

     There is one problem, however.  We would really like WS to wait before�
clearing the screen and obliterating the results of the FF command.  With the�
ZCPR3-type shell, WS can determine from a flag in the ZCPR3 message buffer�
whether it was invoked as a shell.  For the ZCPR2-style shell we would have to�
include an option on the command line.  WS could, for example, recognize the�
command form "WS /S" as a signal that WS was running as a shell.  It would then�
wait for a key to be pressed before resuming, just as under a ZCPR3-style�
shell.  Of course, you would not be able to specify an edit file with the name�
"/S" from the command line in this case, but that is not much of a sacrifice or�
restriction.

     We could continue to work this way as long as we liked.  Only when we�
finally exited WS with the 'X' command would the PPIP command run.  This, of�
course, is just the right way to operate!


ZCPR2 vs ZCPR3 Shell Tradeoffs

     Once I started thinking about the old ZCPR2-type shells, I began to wonder�
why one would ever want a ZCPR3-type shell.  At first I thought that Z2-style�
shells could not be nested, but that does not seem to be the case.  Suppose we�
run MENU and select the 'V' option to run VFILER.  The command line at that�
point would be

	VFILER;MENU /S

where we have assumed that a "/S" option is used to indicate invocation as a�
shell.  While in VFILER we might run a macro to crunch the file we are pointing�
to.  The macro could spawn the command line "CRUNCH FN.FT".  The command line�
buffer would then contain

	CRUNCH FN.FT;VFILER /S;MENU /S

After the crunch is complete, VFILER would be reentered.  On exit from VFILER�
with the 'X' command, MENU would start to run.  Thus nesting is not only�
possible with Z2-type shelling, it is not limited by a fixed number of elements�
in the shell stack as in ZCPR3 (the standard limit is 4).  Only the size of the�
command line buffer would set a limit.

     What disadvantages are there to the Z2-style shell?  Well, I'm afraid that�
I cannot come up with much in the way of substantial reasons.  The shell stack�
provides a very convenient place to keep status information for a program.  I�
do that in ZFILER so that it can remember option settings made with the 'O'�
command.  On the other hand, this information could be kept as additional flags�
on the command line, as with the "/S" option flag.  There is no reason why the�
information could not be stored even in binary format, except that the null�
byte (00 hex) would have to be avoided.

     If the 128 bytes currently set aside for the shell stack were added to the�
multiple command line buffer, the use of memory would be more efficient than it�
is now with Z3-style shells.  Z3 shells use shell stack memory in fixed blocks;�
with Z2 shells the space would be used only as needed.  I rarely have more than�
one shell running, which means that most of the time 96 bytes of shell stack�
space are totally wasted.  Of course, with the present setup of ZCPR3, the�
multiple command line buffer cannot be longer than 255 bytes, because the size�
value is stored in the environment descriptor as a byte rather than as a word. �
The command line pointer, however, is a full word, and so extension to longer�
command lines would be quite possible (I'll keep that in mind for Z35!).

     Following this line of reasoning, I am coming to the conclusion that only�
programs like history shells and true menu shells should be implemented as�
ZCPR3-style shells.  Other programs, like ZFILER and WordStar should use the�
ZCPR2 style.  If I am missing some important point here, I hope that readers�
will write in to enlighten me.


Forming a Synthesis

     So long as the command line buffer is fixed at its present length and so�
long as 128 bytes are set aside as a shell stack, one should make the best of�
the situation.  Rob Wood has come up with a fascinating concept that does just�
that.

     Rob was working on Steve Cohen's W (wildcard) shell.  He recognized that�
on many occasions one wants to perform a wildcarded operation followed by some�
additional commands (just as with the WordStar example followed by PPIP).  As a�
ZCPR3-type shell, W could not do this.  It always executed what it was supposed�
to do after the wild operation before the wild operation!

     Rob came up with a brilliant way to combine the ZCPR2 and ZCPR3 shell�
concepts.  When his version of W is invoked manually by the user, it pushes its�
name, as a good ZCPR3 shell does, onto the shell stack.  But it does not then�
return to the command processor to execute commands pending in the command�
line.  It starts running immediately, doing the thing it was asked to do and�
using the shell stack entry to maintain needed data.

     In the course of operation, however, it does one unusual thing.  After�
each command that it generates and passes to the command line buffer, it�
appends its own name, as a good ZCPR2 shell does.  This command serves as a�
separator between the shell-generated commands and those that were on the�
original command line after the W command.  After the shell-generated commands�
have run, W starts to run.  It checks the top of the shell stack, and if it�
finds its own name there, it says "Aha, I'm a shell," and proceeds to use the�
information in the shell stack to generate the next set of commands.  This�
process continues until W has no more work to do.  Then it pops its name off�
the shell stack and returns to the command processor.  The commands originally�
included after the W command are still there and now execute exactly as�
intended.  Beautiful!


WordStar Shell Bugs

     It is bad enough that WordStar's conceptual implementation as a shell is�
flawed.  On top of that, the shell code was not even written correctly.  The�
person who wrote the code (not MicroPro's fault, I would like to add) tried to�
take a short cut and flubbed it.  When a shell installs itself, it should�
always -- I repeat, always -- push itself onto the stack.  WordStar tries to�
take the following shortcut.  If it sees that the shell stack is currently�
empty, it just writes its name into the first entry, leaving the other entries�
as they were.

     When WordStar terminates, however, it pops the stack.  At this point�
whatever junk was in the second shell stack entry becomes the currently running�
shell.  The coding shortcut (which I would think took extra code rather than�
less code, but that is beside the point) assumed that if the current shell�
stack entry was null, all the others would be, too.  But this need not be the�
case at all.  And in many cases it has not in fact been the case, and very�
strange behavior has been observed with WordStar.  Some users have reported�
that WordStar works on their computers only if invoked from a shell!  That is�
because WordStar properly pushes itself onto the stack in that case.

     There are basically two strategies one can take for dealing with the shell�
problems in WordStar.  One is to fix the above problem and live with the other�
anomalies (just don't ever put commands after WS in a multiple command line). �
The other is to disable the shell feature entirely.

     To fix the bug described above, Rick Charnes wrote a program called�
SHELLINI to initialize the shell stack before using WordStar.  On bulletin�
boards in the past both Rick and I presented aliases that one can use to�
disable the shell stack while WS is running and to reenable it after WS has�
finished.  I will now describe patches that can be made directly to WordStar�
itself.  First I will explain what the patches do; later I will discuss how to�
install them.

     Listing 2 shows a patch I call WSSHLFIX that will fix the bug just�
described.  The code assumes that you do not already have any initialization or�
termination patches installed.  If you do, you will have to add the routines�
here to the ones you are already using.

     The patch works as follows.  When WS starts running, the initialization�
routine is called.  It extracts the shell stack address from the ENV descriptor�
and goes there to see if a shell command is on the stack.  If there is, no�
further action is required, since WS already works correctly in this case.  If,�
on the other hand, the first shell entry is null, then the routine calculates�
the address of the beginning of the second shell entry and places a zero byte�
there.  When this stack entry is popped later, it will be inactive.

     Listing 3 shows a patch I call WSSHLOFF that will completely disable the�
shell feature of ZCPR3 while WS is running.  It works as follows.  When WS�
starts running, the initialization routine is called.  It gets the number of�
shell stacks defined for the user's system in the ENV descriptor and saves it�
away in the termination code for later restoration.  Then it sets the value to�
0.  WordStar later checks this value to see if the shell feature is enabled in�
ZCPR3.  Since WordStar thinks that there is no shell facility, it operates the�
'R' command as it would under CP/M.  Later, on exit from WS, the termination�
routine restores the shell-stack-number so that normal shell operation will�
continue upon exit from WS.

     The easiest way to install these patches is to assemble them to HEX files�
and use the following MLOAD command (MLOAD is a very useful program available�
from remote access systems such as Z Nodes):

	MLOAD WS=WS.COM,WSSHLxxx

Substitute the name you use for your version of WordStar and the name of the�
patch you want to install.  That's it; you're all done.

     If you do not have MLOAD, you can install the patches using the patching�
feature in WSCHANGE.  From the main menu select item C (Computer), and from�
that menu select item F (Computer Patches).  From that menu, work through items�
C (initialization subroutine), D (un-initialization subroutine), and E (general�
patch area), installing the appropriate bytes listed in Table 1.


Summary

     We have covered a lot of material this time.  The issue of shells is a�
very tricky one, and I hope to hear from readers with their comments.  I would�
also enjoy learning about interesting ARUNZ aliases that you have created.


=============================================================================

; Program:	WSSHLFIX
; Author:	Jay Sage
; Date:		March 26, 1988

; This code is a configuration overlay to correct a problem in the shell
; handling code in WordStar Release 4.
;
; Problem:  WS takes a mistaken shortcut when installing its name on the shell
; stack.  If the stack is currently empty, it does not bother to push the
; entries up.  However, when it exits, it does pop the stack, at which point
; any garbage that had been in the stack becomes the active shell.  This patch
; makes sure that the second stack entry is null in that case.

;---- Addresses

initsub	equ	03bbh
exitsub	equ	03b3h
morpat	equ	045bh

;---- Patch code

	org	initsub		; Initialization subroutine patch

init:	jp	initpatch

;----

	org	morpat		; General patch area

initpatch:			; Initialization patch
	ld	hl,(109h)	; Get ENV address
	ld	de,1eh		; Offset to shell stack address
	add	hl,de		; Pointer th shell stack address in HL
	ld	e,(hl)		; Address to DE
	inc	hl
	ld	d,(hl)
	ld	a,(de)		; See if first entry is null
	or	a
	ret	nz		; If not, we have no problem
	inc	hl		; Advance to ENV pointer to
	inc	hl		; ..size of stack entry
	ld	l,(hl)		; Get size into HL
	ld	h,0
	add	hl,de		; Address of 2nd entry in HL
	ld	(hl),0		; Make sure that entry is null
	ret

	end

Listing 2.  Source code for a patch to fix the bug in the coding of shell
stack pushing and popping in WordStar Release 4.

=============================================================================

; Program:	WSSHLOFF
; Author:	Jay Sage
; Date:		March 26, 1988

; This code is a configuration overlay to correct a problem in the shell
; handling code in WordStar Release 4.
;
; Problem:  Because WordStar runs as a ZCPR3 shell, it is impossible to use
; WS in a multiple command line with commands intended to execute after WS is
; finished.  One can disable this by patching the ZCPR3 environment to show
; zero entries in the shell stack while WS is running.  This effectively
; disables WS4's shell capability.  Unfortunately, it means that the extended
; features of the 'R' command under ZCPR3 are also lost.

;---- Addresses

initsub	equ	03bbh
exitsub	equ	03beh
morpat	equ	045bh

;---- Patch code

	org	initsub		; Initialization subroutine

init:	jp	initpatch

;----

	org	exitsub		; Un-initialization subroutine

exit:	jp	exitpatch

;----

	org	morpat		; General patch area

initpatch:			; Initialization patch
	call	getshls		; Get pointer to shell stack number
	ld	a,(hl)		; Get number
	ld	(shstks),a	; Save it for later restoration
	ld	(hl),0		; Set it to zero to disable shells
	ret

exitpatch:			; Termination patch
	call	getshls		; Get pointer to shell stack number
shstks	equ	$+1		; Pointer for code modification
	ld	(hl),0		; Value supplied by INITPATCH code
	ret

getshls:
	ld	hl,(109h)	; Get ENV address
	ld	de,20h		; Offset to number of shell entries
	add	hl,de		; HL points to number of shell entries
	ret

	end


Listing 3.  Source code for a patch that disables the shell feature of
ZCPR3 while WordStar 4 is running and reenables it on exit.

=============================================================================

WSSHLFIX patch bytes:

  initialization subroutine:	C3 5B 04

  un-initialization subroutine:	00 00 C9  (should be this way already)

  general patch area:		2A 09 01 11 1E 00 19 5E 23 56 1A
				B7 C0 23 23 6E 26 00 19 36 00 C9


WSSHLOFF patch bytes

  initialization subroutine:	C3 5B 04

  un-initialization subroutine:	C3 65 04

  general patch area:		CD 6B 04 7E 32 69 04 36 00 C9 CD 6B
				04 36 00 C9 2A 09 01 11 20 00 19 C9


Table 1.  List of HEX bytes for installing either of the patches into
WordStar Release 4 to deal with the problems in the shell code.

                                                                          