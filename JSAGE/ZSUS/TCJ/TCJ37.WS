                               Z-System CorneÚ (c)
                                 by Jay Sage
                        The Computer Journal, Issue 37
                          Reproduced with permission
                           of author and publisher

   The main topic for this column will be the second installment of theç
discussion of ZFILER, the Z-System filer shell (Yes, I'm going to fool youç
all by actually doing as I promised last time!).  As usual, there areç
several other items I would like to discuss briefly first.  The originalç
list included the following: (1) a Z-Node update; (2) a hint on patchingç
those hardware-specific utilities provided by computer manufacturers thatç
don't work right under NZ-COM so that they will work; (3) my views on theç
appropriate way for Z-System programs to be coded for compatibility withç
various stages of evolution of ZCPR3; (4) an update on making PRL filesç
without a PRL-capable linker; and (5) a suggestion to programmers for how toç
deal with bad-directory-specification errors under Z-System.  As usual,ç
including all this material put TCJ's ink supply at risk, and I had roomç
only for the first two items.  Now that I have finished the article and amç
coming back to hone this section, I also have to add that I did not haveç
room to complete the ZFILER discussion; the topics of customization andç
configuration will have to wait until another time.


                               Z-Node Update

   As I mentioned in a previous issue, I have been hard at work trying toç
survey the Z-Node remote access systems (RASs) and to revitalize theç
network.  It was Echelon's creation of that network that first got meç
started as a Z-System activist, and I continue to feel that it is the singleç
most important source of mutual support for users and developers of the Z≠
System.

   My list of currently active nodes is reproduced in Listing 1.  I haveç
added three new columns to Echelon's original format.  The one on the farç
right shows the last date on which operation of the system was verified. ç
The column to its left indicates for nodes accessible by PC-Pursuit the codeç
for the outdial city and the highest bit rate supported for that city.

   At this point I have at least attempted (usually several times) to callç
every North American Z-Node on Echelon's old list.  Where contact was made,ç
I requested that the sysops register with Z Systems Associates, and the onesç
who have done so are designated by an "R" in the leftmost column.  For thisç
listing I have retained a number of systems that seemed still to beç
interested in the Z-System but have not yet registered.  However, if I doç
not hear from them, they will be dropped from the next list.  So, if you useç
one of those nodes (or one of the nodes I have already dropped), please letç
the sysop know that you want him to continue as a Z-Node, and suggest thatç
he delay no longer in registering.  Once we have all the sysops' names andç
addresses, we can start to think about things like a software distributionç
chain to make it easier for the nodes to stay current with Z-System softwareç
developments.  Many of the boards I called had only very old versions ofçäprograms.

   I would like to extend a special welcome to several new Z-Nodes, and Iç
look forward to doing this in each column as more new nodes come on line. ç
Bob Dean has for some time run the excellent Drexel Hill NorthStar system inç
Drexel Hill, Pennsylvania, just outside Philadelphia.  When I saw what anç
enthusiastic Z-System supporter he was, I asked Bob if he would like toç
become a Z-Node.  He was delighted and has joined the network as node numberç
6.  Ted Harmon in Minneapolis has been working for some time at getting hisç
node (#80) up, and I hope that he will be in regular operation by the timeç
you read this.  So far I have not succeeded in connecting with his node.

   Bob Cooper in Ventura, California, is the newest node (#81), and fromç
many voice conversations with him during the past couple of months I knowç
how enthusiastic Bob is.  His node is no in full scale operation.  Sinceç
newly commissioned systems generally have fewer callers than establishedç
systems, their sysops would, I am sure, especially appreciate your calls.


                        Patching Programs for NZ-COM

   As I described in an earlier column, NZ-COM creates a Z-Systemç
automatically from the host CP/M-2.2 system by setting up a virtual systemç
underneath the original one and forwarding calls presented to the virtualç
BIOS (basic input/output system, the hardware-specific portion of theç
operating system code) to the "real" BIOS except for warm boots, which areç
intercepted to prevent a reloading of the host CP/M system.  This produces aç
software environment that is indistinguishable from a manually installed Z≠
System, and all programs that adhere to CP/M or Z-System standards shouldç
run perfectly.

   There is, however, a class of programs that generally do not follow thoseç
rules.  These are most often utilities supplied by the manufacturer of theç
computer to perform special operations, such as configuration of theç
hardware.  They usually make assumptions about the internals of theç
operating system code -- in most cases, the BIOS -- under which they areç
running.  (Regrettably, they usually take no steps to verify that theç
environment is what they expect -- see Bridger Mitchell's column in TCJç
#36.)

   Programs of this type generally do not run correctly under NZ-COM, justç
as they would not run correctly if the user rewrote his or her BIOS withoutç
taking into account the assumptions the manufacturer made as to the locationç
of certain data structures in the BIOS.  (This same problem is less likelyç
to occur, I believe, in a Z3PLUS Z-System running under CP/M-Plus, becauseç
Z3PLUS operates as an RSX, which was a fully defined system facility underç
CP/M-Plus.  Manufacturers' configuration utilities are more likely toç
understand RSXs and operate correctly under them.)

   There are two approaches to dealing with this challenge.  In many casesç
the configuration utilities are used only when the system is initially setç
up (and the newly configured system is then stored on the system tracks ofçäthe boot disk).  In other cases the configuration utilities are used onlyç
when the system is cold booted (i.e., powered up).  These situations pose noç
problem, since the hardware utilities can be run under standard CP/M beforeç
the NZCOM command is issued to invoke the Z-System.

   In some cases, however, the configuration utilities are needed on a moreç
regular basis.  Utilities for setting baud rates, screen attributes, orç
printer characteristics may fall into this class.  These situations canç
present a considerable nuisance to the computer user, who easily becomes soç
accustomed to the facilities of Z-System that he or she nearly loses theç
ability to operate under vanilla CP/M.  I can suggest two possible solutionsç
here.

   One approach is to put the configuration utility in a directory that isç
not on the path (or to give it a new name) and invoke it indirectly by wayç
of an alias.  The alias would initiate a SUBMIT batch operation, asç
described in the NZ-COM manual, that would first remove the NZ-COM systemç
using the NZCPM command, then run the configuration utility under vanillaç
CP/M, and finally reload the standard NZ-COM system.  (If you are veryç
clever, you can probably make an ARUNZ alias figure out which of severalç
standard versions of NZ-COM is running and automatically reload it.)  Thisç
approach will give the appearance of successful operation under NZ-COM of aç
utility that actually cannot run under it.  The main penalty is the extraç
time it takes to exit from and return to the NZ-COM system.  There is also aç
problem if you have loaded a module (RCP, FCP, NDR, etc.) that is not theç
one in your standard configuration.  It will be lost.

   The second approach is to make the utility work properly under NZ-COM. ç
In many cases I have been able to accomplish this without the source codeç
for the utility by using the technique described below.  But be forewarned;ç
the technique will not always work.

   Most of these BIOS-specific utilities determine the address of the dataç
structures to be modified by adding an offset to the BIOS warm boot entryç
point whose address is obtained from the warm boot vector (jump instruction)ç
stored at address 0000H in a CP/M system.  Usually the instruction LDç
HL,(0001) is used to load the address into the HL register.  The problem isç
that under NZ-COM this vector points to the NZ-COM virtual BIOS, and offsetsç
from it generally fall right in the middle of one of the Z-System modules. ç
Not only does the utility fail to make the desired change to the machine'sç
real BIOS; it even corrupts some other code, resulting in behavior thatç
ranges from unpredictably bizarre to instantly catastrophic.

   The simplest corrective patch consists of replacing the LD HL,(0001)ç
indirect load instruction with a LD HL,WBOOT direct load instruction, whereç
WBOOT is the actual warm boot entry point address of the real BIOS.  Thisç
kind of patch is performed by using some utility to scan the utility's codeç
for occurrences of the three-byte sequence 2A (load HL indirect immediate),ç
01, 00 (the immediate address 0001H).  ZPATCH is a natural candidate forç
performing the search, but it unfortunately uses 00 as its string terminatorç
and thus cannot search for a zero byte.  Perhaps Steve Cohen will eliminateç
this minor shortcoming in a future version of ZPATCH (hint, hint -- I knowçäyou're reading this column, Steve).

   The next step is to replace the 2A byte with 21, the direct load opcode. ç
The other two bytes, 01 and 00, are replaced by the BIOS address that youç
have determined previously (perhaps by looking at the contents of memoryç
location 0001H while running normal CP/M).  The low byte is entered first inç
place of the 01 (it will always be 03).  The second byte will be a someç
relatively large number, almost always with a first hex character of D, E,ç
or F.

   Blindly replacing sequences as described above does have its risks. ç
Without careful inspection you cannot be sure that the sequences are beingç
used to perform the assumed function.  If you are an experienced coder, youç
can use a disassembler (such as the one built into debuggers like DDT andç
DDTZ) to examine the code.  The LD HL,(0001) should be followed fairly soonç
by an ADD HL,DE or ADD HL,BC to add the offset to the BIOS structure to beç
modified.  There is also always the possibility that the utility gets theç
address it needs in some other way (for example, LD A,(0002) will get theç
page address of the BIOS).

   The procedure I just described "hardwires" the utility to a BIOS at aç
specific address.  This is fine until you someday set up a new CP/M hostç
system with a different BIOS starting address or until you give thisç
modified version to a friend with a different BIOS.  By then you will haveç
forgotten all about these patches and will be pulling your hair out tryingç
to figure out why the utility that worked perfectly before is nowç
misbehaving.  By then you will also have forgotten exactly what was patchedç
and will not know how to fix the utility.

   A more sophisticated patch will allow the program to work with a BIOS atç
any address.  This approach follows Bridger Mitchell's philosophy of "knowç
your environment."  The patch checks to see if it is running under NZ-COMç
and makes the changes only when it is.

   Source code for this patch, which can be applied using the MLOAD utility,ç
is given in Listing 2.  There are several pieces of information that youç
will have to determine in advance and enter into the patch code.  I have putç
all that information at the front of the patch using macros whereç
appropriate.  If you do not have a macro assembler, you can always put theç
material directly into the code where the macros are called instead.

   First, as before, you have to determine all the addresses at whichç
indirect loads from address 0001 have to be changed to direct loads.  Theseç
values have to be placed in the patch address table in the patch code. ç
Since the patch will be added to the end of the existing utility code, youç
will also have to determine that address.  You can calculate this from theç
file size of the COM file in records as displayed either by STAT or by SDç
with the "C" option.  Alternatively, you can read the COM file into aç
debugger and note the next free address it reports.  This address must beç
entered as the value of the symbol PATCHADDR.

   Most of the utility programs I have patched this way start at 100H with açäjump to the actual working code.  The destination address of that jump mustç
be determined and entered as the value of the symbol STARTADDR.  If theç
utility does not begin with a jump, then you will have to examine the codeç
at 100H and determine the instructions that occupy the first three or moreç
bytes.  These instructions should be entered into the REPLACED macro in theç
patch.  The address of the next instruction after the ones replaced shouldç
be entered as the value for STARTADDR.

   Once you have put all the necessary data into the UTILPAT.Z80 sourceç
code, it should be assembled to a HEX file.  Then the patch can be added toç
UTIL.COM to make NEWUTIL.COM by using the following command:

		MLOAD NEWUTIL=UTIL.COM,UTILPAT

Be sure to save the original program, and test the new version carefully. ç
One additional word of caution.  Some utilities cannot be expected to workç
under NZ-COM no matter what you do.  For example, a utility that takes theç
running CP/M system and writes it to the system tracks will fail becauseç
under NZ-COM the only part of the CP/M system that is still present is theç
BIOS.  For the same reason, programs that try to patch the BDOS will fail.


                           ZFILER, Installment 2
                           =====================

   Last time we covered most of the built-in functions and had left theç
macro commands for this time.  One built-in function was also deferred, theç
option command "O", and we will take up that subject first.


                             The Option Command

   When the option command letter "O" is pressed, a special options screenç
is displayed.  Eleven operating characteristics can be changed from a menuç
with the following appearance (approximately):

	A. single replace query		Y
	B. group replace query		Y
	C. archive replace query	N
	D. verify query			Y
	E. verify default		Y
	F. suppress SYS files		Y
	G. sort by file name		N
	H. set copied file attributes	Y
	I. use dest file attributes	Y
	J. archive destination		Y
	K. search path for CMD file	N

We will explain the meaning of each of these options in a moment.  First aç
few words about the mechanics.  While the options menu is displayed,ç
pressing the index letter at the left will cause the setting of theç
corresponding option to be toggled, and the new state will be shown in theçäcolumn at the right.  The listing above shows the initial state of theç
options in my personal version of ZFILER.  When you are finished togglingç
options, just press carriage return to return to the main ZFILER menu. ç
These option settings are stored in the ZFILER shell stack entry and willç
thus continue in effect through all ZFILER operations until the command "X"ç
is used to terminate the shell.

   The first three options concern how ZFILER responds when copying (orç
moving) files and a file of the same name already exists in the destinationç
directory.  Item A applies when individual files are copied (commands "C"ç
and "M"); item B applies when a group copy is performed (commands "GC" andç
"GM"); and item C applies when performing an archiving operation (commandç
"GA").  If the option is "YES", then ZFILER will prompt one before existingç
files are erased and give one the chance to cancel the operation for thatç
file, leaving the existing file intact.  If the option is toggled to "NO",ç
then existing files will be overwritten without even a message.

   The next two options affect the verification of the copied file in theç
destination directory.  Item D determines whether or not the user will beç
asked about verification.  If this option is set to "N", then the state ofç
option E will determine whether or not verification is performed on fileç
copies.  If this option is set to "Y", then before each copy, move, groupç
copy, or group move, ZFILER will put up the prompt "Verify (Y/N)?".

   The next two options affect the way files are displayed on the screen. ç
If item F is set to "Y", then files with the "system" or SYS attribute willç
be suppressed, that is, not included among the selected files on whichç
ZFILER acts.  This is a reasonable choice for this option, since the mostç
common use of the SYS attribute is to make the files disappear fromç
consideration during file maintenance and display operations.  Item G on theç
options menu determines whether files are sorted first by name and then byç
type or vice versa.  Changing this option is presently equivalent to the "A"ç
command from the main ZFILER command menu.

   The next three options concern how file attributes are treated when filesç
are copied.  One possibility is to create new files with a clean slate ofç
attributes (that is, all attributes reset: not read-only, not SYS, notç
archived).  This is what will happen when option H is set to "N" (but noteç
option J, which may override this).  When the attributes of the destinationç
file are to be set, they can be set in two possible ways.  If a file of theç
same name existed in the destination directory, then its file attributesç
could be used for the copy that replaces it.  This is what will be done ifç
option I is set to "Y".  If option I is set to "N" or if there was noç
matching file in the destination directory, then the attributes will be setç
to match those of the source file.

   Option J can set a special override for the archive or ARC attribute.  Ifç
the option is set to "N", then the ARC attribute is treated just like theç
other attributes according to options H and I.  If option J is set to YES,ç
then the destination file always has its ARC attribute set.

   There was at one time a great deal of controversy over the way the ARCçäattribute is handled under ZFILER.  At one time it was always reset, so thatç
the destination file would be marked as not backed up.  Another school ofç
thought asserted that, on the contrary, the file was backed up, since thereç
was a copy of it on the source disk from which the file was copied.  Thatç
latter argument made considerable sense in the case of copying files from aç
master disk to a RAM disk before a work session.  Here it was certainlyç
important to start with all files marked with the ARC attribute so that oneç
could easily tell at the end of the session which files had been modified soç
that they could be copied back to the permanent storage medium.

   All in all, I never understood this controversy.  Both approaches clearlyç
have merit, and since ZFILER supports both, I saw no reason for all theç
argument.  In a future version of ZFILER, I think I would like to add a flagç
word that would indicate which drives should automatically set the ARC flagç
when the J option is set to YES.  That way, the option could be made toç
apply to RAM drives only.

   The final item on the option menu, option K, determines how the macroç
command file ZFILER.CMD (see discussion below) will be located.  There areç
two choices.  If option K is set to YES, then ZFILER will look for it firstç
in the currently displayed directory and then along the entire ZCPR3 searchç
path.  This option is useful if one wants to have different macro commandç
files that apply to specific directory areas.  Alternatively, if option K isç
set to NO, then ZFILER locates the CMD file without using the path. ç
Depending on how ZFILER is configured (this will be discussed another time),ç
the file will be sought either in the root directory of the path (the lastç
directory specified on the search path) or in a specific drive/user areaç
coded into ZF.COM.  This alternative results in faster operation, especially if the specified directory resides on a RAM disk.

   The options controlled by the option menu can also be permanently changedç
in the ZFILER program file using a patching utility like ZPATCH.  In theç
first page of the file, you will see the ascii string "OPT:".  The elevenç
bytes following this string contain the startup values for the elevenç
options.  Patch a byte to 00 for NO or FF for YES.


                               ZFILER Macros

   Although ZFILER can accomplish many tasks using its built-in functions,ç
its real power comes from the macro facility, which allows it to be extendedç
to include any functions that can be performed using combinations of otherç
programs.  This is where ZFILER really makes use of its power as a shell. ç
First I will describe how the macro facility is used, and then I willç
describe how the user defines the macro functions.  As with the built-inç
functions, macro functions can operate either on single files or on groupsç
of files.  The single-file macro facility is well developed and was alreadyç
present in nearly the same form in VFILER; the group macro facility is newç
with ZFILER and has not been fully developed yet.


Invoking Macros
ä   One way to initiate a macro operation on the pointed-to file is to pressç
the macro invocation key, which is normally the escape key.  A prompt ofç
"Macro:" will appear after the normal ZFILER command prompt.  At this pointç
you have several choices.  If you know the key corresponding to the macroç
you want to run, then you can simply press that key.  ZFILER will thenç
construct a command line and pass it on to the command processor forç
execution.  If ZFILER is configured for instant macro operation (itç
generally is), then macros associated with the number keys "0" through "9"ç
can be initiated without the macro invocation key; the number key enteredç
alone at the main ZFILER command prompt will generate the macro function.

   If you press the macro invocation key a second time, a user-created helpç
screen will be displayed.  This screen generally lists the available macroç
functions.  You can now press the key for the desired function, or you canç
press carriage return to cancel the macro operation and return to the mainç
ZFILER menu.  The help menu screen will also be displayed if you press theç
"#" key.  This is a holdover from VFILER and arises in part because of theç
structure of the file in which the macros are defined (more on thisç
shortly).

   Group macros are invoked in a similar way from the group function commandç
line.  After you have tagged a group of files, press the "G" key to enterç
group mode.  The prompt will list only the built-in group functions, but ifç
you press the macro invocation key, you can proceed as described above forç
single-file macro operations, except that the macro function will beç
performed on each of the tagged files.

   The group macro facility works a little differently than the single-fileç
macro facility.  Since the command line would generally not be long enoughç
to contain the commands for all the tagged files, the group macro facilityç
works by writing out a batch file for processing by ZEX or SUBMIT.  In thisç
way there is virtually no limit to the number of files on which group macrosç
can operate.

   There are many configurable options (described below) that are associatedç
with the group macro operation.  These include the name of the ZEX or SUBç
batch file, the directory to which it is written, and the command line thatç
ZFILER generates to initiate the batch operation.  The NZ-COM version ofç
ZFILER uses a file called ZFILER.ZEX and the command line "ZEX ZFILER".  Theç
Z3PLUS version, under which ZEX will not run, uses a file called ZFILER.SUBç
and a command line of "SUBMIT ZFILER".

   Since macros (and the main menu "Z" function) work by passing commands toç
the command processor, file tags will be lost in the process, and whenç
ZFILER resumes operation, it starts afresh.  In a future version of ZFILER,ç
I hope to preserve the tag information by having it optionally written to aç
temporary file (the shell stack entry is far too small) and read back inç
when ZFILER resumes.


Defining Macros -- The CMD File
ä   Now let's learn how to define the macro functions we want.  As Iç
indicated earlier, the macros are defined in a file called ZFILER.CMD (theç
ZFILER ComManD file).  In the version of ZFILER distributed with NZ-COM andç
Z3PLUS, the CMD file is searched for in the root directory of the ZCPR3ç
command search path.  As described earlier, the option menu allows theç
entire path to be used.  There are also some additional configurable optionsç
that will be discussed another time.  You must be sure to put yourç
ZFILER.CMD file in the appropriate directory.  If the file cannot beç
located, you will still get the macro prompt, but, after you have specifiedç
a macro key, the error message "ZFILER.CMD NOT Found" will be displayed.

   The ZFILER.CMD file is an ordinary text file that you can create with anyç
editor or wordprocessor that can make plain ascii files (WordStar inç
nondocument mode, for example).  The CMD file has two parts.  The first partç
contains the macro command definitions; the second contains the help screenç
(described earlier).

   In the first part of the CMD file, each line defines a macro.  Theç
character in the first column is the key associated with that definitionç
(case does not matter).  Macros can be associated with the 10 number keys,ç
26 letter keys, and all printable special characters except for "#"ç
(explained below).  The space character and all control characters are notç
allowed.  Owing to an oversight, the rubout character can be associated withç
a macro!

   After the character that names the macro there can be any number ofç
blanks (including zero).  If the first non-blank character is "!", then theç
"strike any key" (shell-wait) prompt will appear before ZFILER puts up theç
file display after a macro command is run.  This should be used whenever theç
macro will leave information on the screen that you will want to read. ç
After the "!" there can again be any number of spaces.  Any remaining textç
on the line is taken as the script for the macro command.

   The second part of the CMD file starts when a "#" character is found inç
the first column (hence the exclusion of that character as a macro name). ç
Once that character appears, all remaining text, including text on the line,ç
will be used as the help screen.  Since ZFILER will add some information toç
the display (the name of the pointed-to file and a prompt), you willç
generally want to keep the help screen to no more than 20 lines, includingç
an extra blank line at the end for spacing.  With some experimentation youç
will get the hang of designing this screen.


Macro Scripts

   ZFILER macro scripts are similar to those in ARUNZ and in the other menuç
shells (MENU, VMENU, FMANAGER) in that parameter expressions can appear. ç
The critical parameters -- the ones that implement functions that cannot beç
achieved any other way -- are those that convey information about theç
directory currently displayed by ZFILER and about the pointed-to file. ç
Parameters consist of a "$" character followed by one of the charactersç
listed below.ä
	User prompt parameters

		'	User input prompt
		"	User input prompt

	Parameters for directories
	  - currently displayed directory
		C	DIR form
		D	Drive letter
		U	User number
	  - home directory (from which ZFILER was invoked)
		H	DU form
		R	Home DIR

	Parameters for pointed-to file

		P	Full information (DU:FN.FT)
		F	File name (FN.FT)
		N	File name only
		T	File type only

	Special parameters

		!	GO substitution indicator
		$	The dollar character


   The parameters are listed in a special order above, and we will explainç
that later.  First we will just present the meaning for each parameter.

   The parameter expressions $" and $' are used to display a prompt messageç
to the user and to read in a response string.  Single and double quotes areç
equivalent.  Once the prompt parameter has been detected, all subsequentç
characters up to one of the quote characters are displayed as the userç
prompt.  Thus, if I am not mistaken, there is presently no way to put eitherç
quote character into the prompt.  The end of the line or the end of the fileç
will also terminate the prompt.

   No special character interpretation is performed while expanding theç
prompt.  If you want to make fancy screens, you can include escape sequencesç
and some control characters (obviously carriage return won't work).  In theç
future, ZFILER should be enhanced to provide a means to generate all controlç
characters, to allow special characters to invoke screen functions based onç
the current terminal definition, and to expand directory and file parametersç
in the prompt.

   Now for the directory parameters.  Parameters C, D, and U returnç
information about the currently displayed directory, while H and R returnç
information about the home directory, the one from which ZFILER wasç
originally invoked.  PLEASE NOTE: macros always operate from the homeç
directory.  The reason for this is that ZFILER can display directories withçäuser numbers higher than 15 even when it is not possible to log into theseç
areas.  If you want to operate in the displayed directory, then your scriptç
must include an explicit directory-change command of the form "$D$U:" at theç
beginning (or "$C:" if your system requires the use of named directories)ç
and a command of the form "$H:" (or "$R:") at the end.

   One special note about the parameters that return directory names.  Ifç
the directory has no name, then the string "NONAME" is returned.  This willç
presumably not match any actual name and will lead, one hopes, to a benignç
error condition.  These parameters are included only for systems that do notç
allow directories to be indicated using the DU form (I hope that few if anyç
systems are set up this way).

   Now we come to the four file name parameters.  They allow us to generateç
easily the complete file specification or any part of it.  Note that "$F" isç
not quite the same as "$N.$T".  The latter always contains a dot; the formerç
does not if the file has no file type.

   Finally, we have two special parameters.  "$$" is included to allow aç
dollar sign character to be entered into the script.  "$!" is a controlç
parameter that is used only when a group macro is executed.  If it is placedç
immediately before a token (string of contiguous characters), then thatç
token will be replaced by the string "GO" on all but the first expansion ofç
the script.  This allows group macro scripts to operate faster by avoidingç
repetitive loading of a COM file.  It must be used with great care andç
consideration, however, for reasons that I will not go into here.


Rules for Script Expansion

   ZFILER follows a specific sequence of steps when expanding a script, oneç
that gives it a special feature that, I would guess, few users are aware of. ç
The first step in the expansion is to process only the user-input promptç
parameters, substituting for the prompt whatever the user entered inç
response.  This results in a modified script that is then processed by theç
second step in the expansion.  Because the expansion is handled this way,ç
the user input ^Scan include ZFILER script parameters^S!  Thus the script canç
be used to write a script.  You will see an example of this later.

   The second step in the expansion is to substitute values for theç
directory parameters, which are a kind of constant.  They do not change as aç
function of the pointed-to file.  Finally, in a third step, the remainingç
parameters are expanded.  For group macros, this final step in the expansionç
is repeated for each of the tagged files.  The file parameters are expandedç
differently for each file, and, starting with the second tagged file, theç
"$!" parameter causes "GO" substitution.


Macro Examples

   Listing 3 shows an example of a ZFILER.CMD file, one designed toç
illustrate some techniques of macro writing.  While writing this article, Içädiscovered that one can include blank lines as shown to make the CMD fileç
easier to read.  The help screen part of the listing is taken from myç
personal script file (which, I have to confess, I have not really workedç
very hard at).  The macro definition part of the listing includes only a fewç
of the definitions.

   The macro "Q" is included to illustrate a very simple, but useful, typeç
of macro.  It invokes the very powerful file typing program QL (quick look)ç
on the pointed-to file.  This is handy when you want more powerful viewingç
capability than that offered by the built-in "V" command.  QL can handleç
crunched files and libraries, and it can display text or hex forward orç
backward.

   Macro "U" uncompresses a file.  It illustrates a more complex script thatç
involves flow control and parameters that extract individual components ofç
the pointed-to file name.  It tests the file type to see if the middleç
letter is "Q" or "Z".  In the former case, it unsqueezes the file; in theç
latter, it uncrunches it.  The uncompressed file it put into the sourceç
file's directory.

   Macros S, K, and B illustrate the use of input prompting.  The first oneç
allows the user to specify the file attributes to be set.  Note that theç
prompt includes a helpful reminder of the syntax required by SFA.

   Macro K crunches files to a user-specified destination.  It alsoç
illustrates how one logs into the currently displayed directory.  I do thisç
here so that a null answer to the prompt (i.e., just a carriage return) willç
result in the crunched files being placed in the currently displayedç
directory rather than in the home directory, as would otherwise be the caseç
(since that is where the macro runs from, remember).  As a result, however,ç
this macro will not operate properly in user areas above 15 under BGii orç
versions of the command processor that do not allow logging into high userç
areas.

   Macro B performs a slightly more complex function.  It not onlyç
compresses the pointed-to file to a specified destination directory, but itç
then marks the source file as having been backed up.  A combination of theç
group archive built-in command (to tag files that need backing up) and aç
group macro B (to perform the backup) gives the ZFILER user a way to back upç
files in crunched form on the backup disk.

   Macro M is included to show that a ZFILER macro, when it needs to doç
something more complex than it is capable of doing all by itself, can passç
the task to an ARUNZ alias.  The MOVE alias first determines whether theç
source and destination are on the same drive.  In that case, MOVE.COM isç
used to perform the move.  Otherwise, the source file is copied to theç
destination and then deleted.  What we have, therefore, is a MOVE commandç
that frees the user of the responsibility of worrying about which drives areç
involved -- another example of how Z-System can free you from considerationsç
that need not concern you, that do not require human intelligence to decide.

   The final three macro examples are execution macros.  Macro X causes theçäpointed-to file to be executed.  A more sophisticated version might check toç
make sure that the file type is COM.  I opted for the flexibility ofç
pointing, for example, to PROGRAM.Z80 and having PROGRAM.COM run.  If thereç
is no COM file with a matching name, the error handler will take care ofç
things.  You will note the leading colon before the "$n" parameter.  Itç
makes sure that the current directory is searched even if it is not on theç
path.  Prompted input is used to allow a command tail to be included.

   The Z macro performs a user-specified function on the pointed-to file. ç
Two separate user prompts allow both the command and a command tail to beç
given.  For example, if you wanted to squeeze the file to A0:, you wouldç
enter "SQ" in response to the first prompt and "A0:" in response to theç
second.

   The 0 macro illustrates how the response to a prompt can be used as aç
ZFILER script.  This macro takes care of all those functions we forgot toç
include in ZFILER.CMD.  The whole macro is just prompted input, and whateverç
we answer will be run as a script.  I use this function so often that I putç
it on a number key so that it can be invoked with a single key rather thanç
the usual pair.  Also, as you may have noticed, I include in the macro helpç
screen a list of the parameters that can be used.

   The only real limitation of this macro-to-write-a-macro approach is thatç
prompted input cannot be included in the response.  As I write this,ç
however, it occurs to me that this limitation could be overcome byç
recursively parsing the prompt parameters until none remain, and only thenç
going on to the subsequent macro expansion steps.

   Well, I was going to discuss patching and configuring ZFILER, but thisç
article is already too long, so that will just have to wait for anotherç
time.  I hope that this article will help you get more out of ZFILER.  Seeç
you in the next issue!

[This article was originally published in issue 37 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]
