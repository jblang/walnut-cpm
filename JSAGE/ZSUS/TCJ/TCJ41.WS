                               Z-System CorneÚ (c)
                                 by Jay Sage
                        The Computer Journal, Issue 41
                          Reproduced with permission
                           of author and publisher


   By the time you read this, summer vacation will probably be just a fondç
memory for you, but it is August as I write this, and I have just returnedç
from three weeks in Israel.  This was a total vacation.  I didn't touch orç
even think about computers the whole time I was away, except at the very endç
when my mind started to refocus on the responsibilities that awaited me atç
home, including this TCJ column.  It was so nice to get "computerç
compulsion" out of my system that I have not been all that eager to get backç
immediately to my old routine...but I know it will happen soon enough.

   Having not thought about computing for a month, I had to work to recallç
the things I was excited about before I left and planned to discuss in thisç
issue.  Fortunately, I left myself some notes.  One item was theç
continuation of the BYE discussion, this time covering the extended DOSç
functions implemented in BYE.  The truth is I have neither the energy norç
the time to take up that subject now.  Instead, I am going to come back onceç
again to my favorite subject: aliases and ARUNZ.

   I think ARUNZ is the one thing that keeps me hooked on Z-System and notç
eager to follow after the MS-DOS crowd.  Although I have looked hard, I haveç
not found anything with the combined simplicity and power of ARUNZ for MS≠
DOS.  The mainframe batch processing language REXX, which has been ported byç
Mansfield Software to DOS machines, is far more powerful, and some day Iç
hope to port a greatly simplified version to Z-System.  The DOS version ofç
REXX, you see, takes over 200K of memory while it is running!  That oftenç
does not leave enough memory, even on a 640K machine, for applicationç
programs to run.  I think I actually have more problems running out of TPAç
on my Compaq 386 than I do on my SB180!

   Anyway, for this column I am going to begin with a very brief report on aç
rather dramatic change in the works for ARUNZ and the Z-System as a whole. ç
Then I am going to describe two ARUNZ applications that I recently developedç
for my own use.  I think they illustrate some interesting generalç
principles, and you may even find them useful as they are.


                     The Extended Multiple Command Line

   Most people who use ARUNZ aliases -- or even standard aliases -- soonerç
or later run into a situation where the command line overflows and the wholeç
process comes to a crashing halt (well, not really a crash, but a suddenç
stoppage).  The standard Z-System configuration supports a multiple commandç
line buffer (MCL) that can accommodate 203 characters.  The largest sizeç
possible is 255 characters.  Either way, there comes a time when aliases areç
invoked from command lines that already contain additional commands, and theç
combined command line is too long to fit in the MCL.  People like RickçäCharnes would have this happen constantly if they did not adopt a strategyç
to avoid the problem (more about that in one of our examples later).

   I have long been intrigued by the possibility of having a much longerç
command line.  The command processor (CPR) has always used a word-sizeç
(16-bit) pointer into the command line, and so, without any change in theç
ZCPR34 code, the CPR could handle a command line as big as the address spaceç
of the Z80.

   To verify this, I performed a simple experiment.  I configured a Z-Systemç
with free memory after the MCL, and then, using the memory utility programç
MU3, I manually filled in the command line with a very long multiple commandç
line sequence terminated, as required, by a null character (binary zero). ç
Sure enough, after exiting from MU3, the huge command line ran without aç
hitch.

   The next step was to write a special new version of ARUNZ that could beç
configured to recognize an oversized MCL.  Richard Conn set up theç
environment descriptor (ENV) with a one-byte value for the length of theç
command line that the MCL buffer could contain.  Thus there is presently noç
way to support an extended MCL (XMCL) in a system-invariant way, that is, inç
a way that allows programs to determine at run time how big the MCL is.  Weç
are working on that problem right now, and, by the time you are readingç
this, there will almost certainly be a new ENV type defined (81H) that usesç
one of the remaining spare bytes in the type-80H ENV to report the size ofç
XMCL to programs smart enough to check for it.

   The original, single-byte MCL size value in the ENV has to remain as isç
and contain a value no larger (by definition) than 255 (0FFH).  That valueç
is used by the command processor when new user input is being requested. ç
There is no way for the CPR to allow users to type in command lines longerç
than 255 characters without adding a vast amount of code to perform theç
line-input function now so conveniently and efficiently provided by the DOS. ç
A shell could be written that included such code, but I really can't imagineç
anyone typing in such long command lines.  If they do, it probably showsç
that they are not making proper use of aliases.

   I have decided to use only one of the spare ENV bytes for the XMCL sizeç
and to let that value represent the size -- in paragraphs -- of the totalç
MCL memory buffer allocated, including the five bytes used by the addressç
pointer, size bytes, and terminating null.  The term 'paragraph' as a unitç
of memory is not often used in the Z80 world.  I believe it was introducedç
with the 8086 processor, where the segment registers represent addressesç
that are shifted four bits right.  Each unit in the segment register is,ç
therefore, 16 bytes and is called a paragraph.  With this system, the XMCLç
buffer can be as large as 255 * 16 = 4080, which allows command lines withç
up to 4075 characters.  Rich Charnes, do you think you can live with thatç
without cramping your style too much?!

   Most people will not want to allocate that much memory to the operatingç
system, and I would never have considered this step before the new dynamicç
versions of Z-System were available.  While I might be willing to allocateçä1K to the XMCL most of the time, I certainly would want to be able toç
reclaim that memory when I need it.  I'm not sure whether NZCOM or Z3PLUSç
can be cajoled into handling this kind of flexibility yet; new versions mayç
be needed at some time in the future.

   I put the new version of ARUNZ out for beta test, and it worked justç
fine, and one could write very long alias scripts.  Rick Charnes, however,ç
quickly identified a problem.  Suppose a conventional alias appeared in theç
command sequence.  After expanding itself and constructing the new commandç
line, the alias would find that, as far as it knew, there was not enoughç
room for it in the MCL.  In a nutshell, the hard part with going to the XMCLç
is that it is not enough to have an advanced ARUNZ; all programs thatç
operate on the MCL must be upgraded.  We hope to have new versions of theç
library routines in Z3LIB that perform these functions.  Then, if we areç
lucky, most of the utility programs can be upgraded simply by relinking. ç
I'm sure it won't be quite that easy, of course!


                                A MEX Alias

   For those who are not familiar with it, MEX (Modem EXecutive) is anç
advanced telecommunications program written by Ron Fowler of NightOwlç
Software.  Early versions were released for free to the public (up toç
version 1.14), while the most advanced versions (called MEX-Plus) areç
commercial products.  I use version 1.65, and some of the specifics in myç
example apply to that version.  I am pretty sure that the technique Iç
describe can be applied to the free version as well.

   Rather than being a telecommunications program, MEX should probably beç
considered a telecommunications programming language.  It supports a veryç
wide range of internal commands for managing telecommunications tasks, andç
it even has a script language for automating complex sequences ofç
operations.

   The MEX command line allows multiple commands to be entered just as in Z≠
System, and a MEX command allows the user to define the command separator. ç
Although I depend on aliases to generate complex Z-System commands and MEXç
script files to automate complex MEX command sequences, I still frequentlyç
make use of simple, manually entered multiple commands.

   Being accustomed as I am to entering Z-System commands separated byç
semicolons, I naturally set up my version of MEX to use the semicolon as itsç
separator, too.  Now I can comfortably work in both environments.  However,ç
I also frequently like to invoke MEX with some initial commands, which MEXç
allows one to include in the command tail.  Here's a simple example.

	B11:TEMP>mex read mnp on

This command invokes MEX and tells it to run the script file MNP.MEX withç
the parameter "ON".  This script causes a string to be sent to my modemç
which engages the MNP error correcting mode (yes, when I purchased my mostç
recent modem -- replacing a USR Password -- I decided to spend the extraçämoney for MNP, although at the time there weren't many systems thatç
supported it; now I'm glad I did).

   That command line works fine.  But often I want to do more, and so Iç
always wanted to enter something like:

	B11:TEMP>mex read mnp on;call zitel

This would start out by doing what the first example did but would thenç
continue by placing a call to the ZITEL BBS.  [If you can keep a secret,ç
I'll tell you that the ZITEL BBS is the MS-DOS system that I run for theç
ZI/TEL Group of the Boston Computer Society.  ZI/TEL comes from the lettersç
in Zilog and Intel, and it symbolizes the fact that we support the two mainç
operating systems run on chips from those companies: CP/M and MS-DOS.  Theç
BBS machine, a Kaypro 286/16, is sitting in the other room (you don't thinkç
I'd allow it in the same room with the Z-Node, do you?), and it has an HSTç
9600 bps modem with MNP error correction.  If you want to contact me there,ç
by the way, the number is 617-965-7046.]

   An on-the-ball reader already realized that the above command will notç
work, because the semicolon separator before the CALL command, which Iç
intended as the MEX separator, will be interpreted by the CPR as itsç
separator, and it will terminate the MEX command.  What can we do aboutç
this?

   Some compromise here is inescapable, and I was willing to accept -- fromç
the CPR command line only -- a MEX separator other than semicolon.  Thus theç
following form would be acceptable

	B11:TEMP>mex read mnp on!call zitel

with an exclamation point as the separator as in CP/M-Plus.  But for years Iç
could not figure out how to accomplish this.

   At first I thought there was a very simple solution.  When MEX starts up,ç
it can be set up to automatically run an initialization script file INI.MEX. ç
So, I created a version of MEX (the MEX "CLONE" command makes it easy toç
create new versions) that used "!" as the separator, and I created anç
INI.MEX file with the command

	STAT SEP ";"

Thus, as soon as MEX was running, the separator would be set back to aç
semicolon.  Unfortunately, to my chagrin, I learned that MEX invokes theç
INI.MEX script only when no commands are included on the command line.  Withç
the ZITEL command line shown earlier, MEX would be left with the exclamationç
point as the separator.

   Here is what I thought of next (at least momentarily).  Rename MEX.COM toç
MEX!.COM and set up a MEX alias in ALIAS.CMD with the definition

	MEX	mex:mex! $*!stat sep ";"ä
The idea here is that the user's MEX commands from the command lineç
(separated by "!") will be passed in by the $* parameter and will have theç
STAT command added.  Thus our earlier example will turn into the commandç
line

	B11:TEMP>mex:mex! read mnp on!call zitel!stat sep ";"

   This, of course, fails for the same reason that I could not just enterç
commands with semicolons in the first place.  The trick to get around thisç
is to use a command that for some reason Ron Fowler does not document in theç
MEX manual: POKE.  It works like the Z-System command of the same name andç
places a byte of data into a specified memory address.

   I knew the value I wanted to poke: 3BH, the hex value for the semicolonç
character.  The question was, where should it go?  To find out, I took aç
version of MEX set up with semicolon as the separator and the version withç
exclamation point as the separator and ran the utility DIFF on them (inç
verbose mode to show all the differences).  Then I looked for the placeç
where the former has a semicolon and the latter an exclamation point.  Forç
MEX-Plus this turned out to be 0D18H so that the MEX poke command would be

	POKE $0D18 $3B

Note that MEX uses a dollar sign to designate hex numbers.  The alias nowç
read

	MEX	mex:mex! $*!poke $$0d18 $$3b

Observe that a double dollar sign is needed to get a single dollar signç
character into a command.  A lot of people forget this and end up withç
scripts that don't do what they're supposed to.

   I tested this, and it works splendidly -- but with one possible 'gotcha'. ç
The commands passed to MEX must not invoke any script files that depend onç
the command separator being a semicolon (because it will be exclamationç
point until the final poke command runs); nor may the read files change theç
command separator (because the rest of the command sequence still assumes itç
is the exclamation point).  For this reason, it is prudent to write allç
script files with only one command per line so that no separator is needed. ç
I haven't been doing this, but I will from now on!

   One final word on the script.  I actually did not do this exactly as Iç
have described.  Instead, I left my MEX.COM set up with the semicolonç
separator, and I created a distinct ARUNZ alias called MEX! so that I wouldç
be reminded of the separator.  This alias script reads

	MEX!	get 100 mex:mex.com;poke d18 "!;go $*!poke $$0d18 $$3b

This uses the famous poke&go technique originated by Bruce Morgen.  MEX.COMç
is loaded into memory by the GET command, and then the Z-System POKE commandç
sets "!" as the command separator.  Then the modified loaded code is run byçäthe GO command.  The rest is as described previously.


                            A Spell-Check Alias

   I try to remember to put all my writing through The Word Plus spellingç
checker that came with WordStar Release 4 so that as many typos as possibleç
will be caught.  The procedure for doing that on a Z-System is a bitç
complicated because the text file is generally not in the same user area asç
the spelling check program.  While writing my last TCJ column, I finally gotç
fed up with the complexity and automated the whole process using a set ofç
aliases.

   I wanted to support the following syntax:

		C1:TCJ>spell filename.typ dictname

If just the file name was given, the alias would prompt for the name of theç
special dictionary to use, and if not even a file name was given, then theç
alias would prompt for both names.  A special version of the command,ç
ZSPELL, would take only the file name and would automatically use ZSYSTEM asç
the name of the special dictionary (it knows about mnemonics like ZCPR, MCL,ç
and RCP, and about all those special words like debugger, relocatable, andç
modem).  We'll describe the general alias set first.  In listing theç
aliases, we will write them in multiline format for easy reading;in theç
ALIAS.CMD file the scripts have to be on a single line (though I hope thatç
will change soon).

   The user-interface alias, SPELL, deals only with the matter of how manyç
parameters the user has provided.  It reads as follows:

	SPELL
		if nu $1;
		  /TW0;
		else;
		  if nu $2;
		    /TW1 $1;
		  else;
		    /TW2 $1 $2;
		  fi;
		fi

If no parameters at all are provided (IF NULL $1), then the secondary scriptç
TW0 is run.  The leading slash signals ZCPR34 that the command should beç
directed immediately to the extended command processor.  If a firstç
parameter but no second parameter is present (IF NULL $2), then theç
secondary script TW1 is run.  Finally, if both parameter are provided, thenç
script TW2 is run.

   The script TW1 includes a prompt only for the name of the specialç
dictionary file:
ä	TW1
		$"Name of special dictionary: "
		/TW2 $1 $'e1

The first token in any user response to the first prompt ($'E1 -- whenç
working with ARUNZ you should have a printout of the parameter DOC file) isç
used along with the file name that was already given, and both are passed toç
TW2.

   The script TW0 includes prompts for both the file name and the specialç
dictionary:

	TW0
		$"Name of file to check: "
		$"Name of special dictionary: "
		if ~nu $'e1
		  /TW2 $'e1 $'e2
		fi

The first tokens in the responses to the prompts are passed to script TW2. ç
If no file is specified for checking, the alias simply terminates.

   Before we look at TW2, which does the real work, let me ask a rhetoricalç
question: why do we break this process up into so many separate aliases. ç
There are two main reasons.  The first is that the command line buffer would overflow if all these smaller scripts were merged into a single big script. ç
The extended MCL we discussed earlier could overcome this problem, but forç
another reason we would still have to use separate aliases.

   As I have discussed in past columns, ARUNZ cannot know at the time itç
expands a script what the results of conditional tests will be later whenç
the IF commands are run.  Thus ARUNZ must process all user input promptsç
that appear in the script.  This would mean asking for a file name andç
special dictionary even when the names were given on the command line.  Theç
solution to this problem is to put the prompts in separate scripts that getç
invoked only when the information requested in those prompts is actuallyç
needed.

   Now let's look at the script TW2.

	TW2
		path /d=tw:;
		$td1$tu1:;
		tw:tw $tf1 $tn2.cmp;
		path /d=;
		/twend $tn2;
		$hb:

This is simpler than what you expected, no?  Well, there is still a lot ofç
work imbedded in the subroutine script TWEND, which we will cover later. ç
Here we broke up the script solely to prevent MCL overflow.

   The first command makes use of the ZSDOS file search path (see theçäarticles by Hal Bower and Cam Cotrill on ZSDOS in TCJ issues 37 and 38). ç
Although there was an attempt to update WordStar Release 4 to include someç
Z-System support, no such attempt was made with The Word Plus spell checker. ç
In general, the file to be spell-checked will be in one directory and Theç
Word files in another directory.  The main program TW.COM could be locatedç
by the command processor using its search path, but TW.COM needs a number ofç
auxiliary files, such as the dictionary files.  How can the system be madeç
to find all of these files at the same time.  ZSDOS provides the answer.

   I have replaced the standard Z-System PATH command with the ZSDOS utilityç
ZPATH (renamed to PATH).  The first command in TW2 defines the DOS searchç
path to include the directory TW:, which is where I keep all the files thatç
are part of The Word Plus spell-checking package.  Once that directory is onç
the DOS path, all files in it will more-or-less appear to be in the currentç
directory.  Very handy!  If you use ZDDOS, the search path is not available. ç
I will not show it here, but you can accomplish the same thing using onlyç
public files.  It's just not quite as neat and straightforward.  I amç
willing to pay the small memory penalty to get the nice extra features ofç
ZSDOS over ZDDOS.

   The second command logs us into the directory where the file to beç
checked resides.  If we did not include a DIR: prefix, we were alreadyç
there, but the extra command does not hurt, and it is nice to know that aç
directory can be specified explicitly (in either DU: or DIR: form) for theç
file to be checked.  There could be a problem if the file is in a user areaç
above 15, since you may not be able to log into that area.  My configurationç
of Z34 allows this, but when I run BGii I lose this feature (and I sure missç
it).  If you can't log into those areas, then you should not keep filesç
there that you want to spell-check.

   The third line actually runs the spell checker (you knew that had toç
happen some time!).  Notice that even if the user specified a file type forç
the special dictionary, type CMP is used.  Only the name ($TN2) without theç
type is taken from the user.  As the master program TW.COM is run, it willç
find its component program files (e.g., SPELL.COM, LOOKUP.COM, MARKFIX.COM)ç
and the various dictionaries in the TW: directory thanks to ZSDOS, and itç
will find the text file in the current directory.  As it works through theç
text, if there are any questionable words, it will write out a fileç
ERRWORDS.TXT to the current directory.  If any words are added to theç
special or UPDATE dictionaries, then the modified dictionaries will be readç
from TW: but written out to the current directory.  You must understandç
these facts in order to understand the rest of the script.

   Once the spell-checking is complete, the ZSDOS path is set back to nullç
(unless I have a special need to have the DOS perform a search, I leave itç
this way to avoid surprises).  Then the ending script TWEND is run, andç
finally the original directory ($HB:) is restored as the current directory.

   Now let's look at TWEND.  As it is invoked, the name of the specialç
dictionary is passed to it.  TWEND's job is to clean up scratch files and toç
take care of any updated dictionaries.  It reads
ä	TWEND
		if ex errwords.txt;
		  era errwords.txt;
		fi;
		/dupd $1;
		/dupd updict

For efficiency and to prevent MCL overflow, the dictionary updating isç
performed by yet another subroutine script, DUPD.  It gets called twice,ç
once with the special dictionary (if any) and once with the updateç
dictionary.  It reads as follows:

	DUPD
		if ex $tn1.cmp;
		  mcopy tw:=$tn1.cmp /ex;
		fi

If an updated version of the specified dictionary exists in the currentç
directory, then it is copied to the TW: directory, overwriting any existingç
file of that name (MCOPY option E).  The source file is then erased (MCOPYç
option X).  Oh yes, I almost forgot; the MCOPY here is my renamed version ofç
the COPY program supplied with ZSDOS.

   That is it except for showing you the special ZSPELL version of theç
alias.  Notice that I make the "ELL" part of the command optional byç
inserting the comma in front of that part of the alias name.  I also allowç
the script to be invoked under the name ZTW.  The main SPELL script actuallyç
has the name "TW=SP,ELL" on my system.  Since TW: is not on my commandç
search path, the command "TW" will invoke the ARUNZ script unless I am inç
the TW: directory at the time.

	ZTW=ZSP,ELL
		if nu $1;
		  /ZTW1;
		else;
		  /TW2 $1 zsystem.cmp;
		fi

	ZTW1
		$"Name fo file to check: "
		if ~nu $'e1
		  /TW2 $'e1 zsystem.cmp
		fi

I hope you find these alias examples useful and instructive.  That's all forç
this time.  See you again in two months.

[This article was originally published in issue 41 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]ä