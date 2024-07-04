     In my last column I said that I would discuss the progress I have been�
making with a new version of ZEX, the memory-based batch processor for�
ZCPR3.  As frequently happens, however, another subject has come up and�
preempted my attention.  I thought I would still get to ZEX later in this�
column, but the column is already by far the longest I have written.  So ZEX�
and other matters planned for this time will have to wait.  For ZEX that is�
not a bad thing, since I still have a lot of work to do on it, and by two�
months from now there should be considerably more progress.


                         L'Affaire ARUNZ: J'Accuse


     Not too long ago in a message on Z-Node Central, David McCord -- sysop�
of the board and vice president of Echelon -- leveled a serious accusation�
against me: that I have failed to provide proper documentation for my ARUNZ�
program.  I immediately decided to mount a vigorous defense against this�
scurrilous charge using all the means at my disposal, including the awesome�
power of the press (i.e., this column in The Computer Journal).

     Unfortunately, I find my defense hampered by a small technicality. �
True, many other people, faced with this very same impediment, have�
seemingly not been discouraged in the slightest from proceeding aggressively�
with their defense.  However, I lack the character required to accomplish�
this.  What is this technicality?  It is the fact that the charge is true.


                              Excuses, Excuses

     An effective defense being out of the question, perhaps I can at least�
offer some lame excuses.

     First of all, it is not as true as it seems (if truth has degrees) that�
I have provided no documentation.  There is a help file, ARUNZ.HLP, that at�
this very moment resides, as it has for years, in the HELP: directory on my�
Z-Node RAS (remote access system).  Way back when ARUNZ was first made�
available to the user community, Bob Frazier was kind enough to prepare this�
help file for me, and it was included in the LBR file that I put up on my Z-Node.  As a series of upgraded versions appeared, I began to omit the help�
file to avoid duplication and keep the new LBR files as small as possible. �
After a while, of course, the original library that did include the help�
file was removed from RASs.  Hence the impression that there is no�
documentation.  Of course, by now that help file is rather obsolete anyway.

     If you are observant, you may have caught in the previous paragraph the�
deliberate circumlocution "made available to the user community".  Why did I�
avoid the shorter and more natural expression "released"?  Because ARUNZ has�
still to this day (more than two years -- or is it three now -- after its�
first 'availability'), not actually been released.  Why?  Because I still�
have not finished it.  It is still in what I consider to be an incomplete,�
albeit quite usable, state.  A few more tweaks, a couple of additional�
features, a little cleaning up of the source code, a detailed DOC file . . .�
and it should be ready for a full, official release.

     ARUNZ is, regrettably, not my only program that persists in this state. �
It is simply the oldest one.  ZFILER and NZEX (new ZEX) suffer similarly. �
One might even say that this has become habitual with me.  What happens, of�
course, is that I don't find the time to code that one little crucial�
additional feature before some other pressing issue diverts my attention. �
And by the time I do get back to it, I have thought of still another feature�
that just has to be included before the program should be released.

     One solution would be not to make the programs available until they are�
really complete.  There are two reasons why I have rejected this approach. �
First of all, though not complete to my satisfaction, the programs are in�
quite usable condition.  It would be a shame if only I -- and perhaps a�
small group of beta testers -- had been able to take advantage of the power�
of ARUNZ during these two or three years.

     The second problem with holding the programs back is that a lot of the�
development occurs as the result of suggestions from other users, who often�
have applications for the program that I never thought of and would never�
think of.  In a sense, I have chosen to enlist the aid of the entire user�
community not only in the testing process but also in the program�
development process.  And I think we have both benefited from this�
arrangement.

     The procedure I have developed for keeping track of these 'released'�
test versions is to append a letter to the normal version number.  As I�
compose this column, ARUNZ stands at version 0.9G, ZFILER stands at 1.0H,�
and NZEX stands at 1.0D.  When final versions are released, I will drop the�
letter suffixes (except for NZEX, which will become ZEX version 4.0).

     The usability of the programs is probably the fundamental factor that�
keeps them in their incomplete state.  When one of them has some serious�
deficiency or or simply begs for an exciting new feature, it gets my�
attention.  Once it is working reasonably well, however, I can ignore it and�
devote my attention to other things that badly need fixing.  That is how I�
recently got started on NZEX.


                               Making Amends

     Since excuses, no matter how excusing, do not solve a problem, I will�
take advantage of this column to make amends for the poor state of the ARUNZ�
documentation by providing that documentation right here and now.  I hope it�
will lead more people to make more complete and effective use of ARUNZ,�
which for me has been the single most powerful utility program on my�
computers.

     To understand ARUNZ one must first understand the concept of the ZCPR�
alias, and to understand aliases one must understand the multiple command�
line facility.  I have written some things about these subjects in earlier�
columns, notably in issues #27 and #28, but I will start more or less from�
the beginning here.


                           Multiple Command Lines

     One of the most powerful features of ZCPR3 is its ability to accept�
more than one command at a time and to process these commands sequentially. �
Quoting from my column in TCJ issue #27:  The multiple command capability of�
Z System ... is important not so much because it allows the user to enter a�
whole sequence of commands manually but rather because it allows other�
programs to do so automatically.

     Obviously, in order to process multiple commands, the list of commands�
(at least the unexecuted ones) must be stored in some secure place while�
earlier ones are being carried out.  In the case of ZCPR3, there is a�
dedicated area, called the multiple command line (MCL) buffer, located in�
the operating system part of memory.  It stores the command line together�
with a pointer (a memory address) to the next command to be executed.  Every�
time the ZCPR3 command processor returns to power, it uses the value of the�
pointer to determine where to resume processing the command line.  Only when�
the end of the command line is reached does the command processor seek new�
command line input.

     Storing multiple commands in memory is not the only possibility. �
Another secure place to keep them is in a disk file.  This is in some ways�
what the SUBMIT facility does using the file $$$.SUB.  The main drawback to�
this approach is the speed penalty associated with the disk accesses�
required to write and read this file.  There is also always the possibility�
of running out of room on the disk or of the diskette with the $$$.SUB file�
being removed from the drive.  Using a memory buffer is faster and more�
reliable.

     Digital Research's most advanced version of CP/M, called CP/M-Plus,�
also provides for multiple command line entry, but it does it in a rather�
different, and I think less powerful, way.  When a multiple command line is�
entered by the user, the system builds what is called a resident system�
extension (RSX), a special block of code that extends the operating system�
below its normal lower limit.  This RSX holds any pending commands.  But�
since it is not always present and is not at a fixed, known location in�
memory, there is no straightforward way for programs to manipulate multiple�
command lines.  On the other hand, this method does provide a bigger TPA�
when only single commands are entered.

     In a ZCPR3 system, the MCL has a fixed size and is in a fixed location. �
Moreover, a ZCPR3 program can find out where the MCL is located by looking�
up the information about it in the ZCPR3 environment descriptor (ENV),�
another block of operating-system memory containing a rather complete index�
to the features of the particular ZCPR3 system.  The location of the ENV is�
the one key fact that is conveyed to all ZCPR3 programs.  Prior to ZCPR�
version 3.3, the address of the ENV had to be installed into each program�
manually by the user before the program could be used; with ZCPR33 this�
installation is performed automatically by the command processor as the�
program is run.


                             The Alias Program

     One of Richard Conn's brilliant concepts in designing ZCPR3 was the�
utility program he called ALIAS, whose function is to create COM files that,�
in turn, build multiple command lines and insert them into the MCL buffer. �
When ALIAS is run, it prompts the user for (1) the name of the alias file to�
create and (2) a prototype command line, nowadays called a script.  When the�
resulting COM file is run, it takes the script, uses the information in it�
to construct a complete command line, and then places that command line into�
the MCL buffer so that the commands it contains will be run.

     The simplest script would be nothing more than a completely formed�
command line.  For example, if we wanted to have a command (COM file) that�
would display the amount of free space on each of drives A, B, and C, we�
could make an alias SPACE.COM containing the script

	SP A:;SP B:;SP C:

We assume here that our RCP (resident command package) includes the SP�
(space) command.

     Such a script can have only a single purpose.  Much more powerful�
capability is provided when the script can contain parameter expressions�
that are filled in at the time the command is run.  The aliases produced by�
ALIAS.COM support a number of parameter expressions, including the $1, $2,�
... $9 parameters familiar from the SUBMIT facility.  An alias called�
ASMLINK with a script containing the following command sequence

	SLR180 $1
	IF ~ER
	SLRNK /A:100,$1/N,$1,VLIB/S,Z3LIB/S,SYSLIB/S,/E
	FI

can then be used to assemble and (if there were no errors in assembly) link�
any program.  The expression $1 is replaced by the first token on the�
invoking command line after the name of the alias.  A token, we should note,�
is a contiguous string of characters delimited (separated) by a space or tab�
character.  Thus with the command

	ASMLINK MYPROG

the string "MYPROG" will be substituted for each of the three occurrences of�
the expression "$1" in the script to form the command line.  Any commands in�
the MCL after the alias command are appended to the expanded script.


                            The Advent of ARUNZ

     One day it suddenly struck me that Conn-style aliases are extremely�
inefficient with disk space.  Each one contains, of course, the prototype�
command line (the script), which is unique and essential to each alias, but�
which is at most about 200 characters long and often much less (17 and 67 in�
the two examples above, if I counted right).  But each one also contains a�
complete copy of the script interpreter and command line manipulation code,�
about 1K bytes long, which is exactly the same in each alias.  Why not, I�
thought, separate these two functions, putting all the scripts into a�
single, ordinary text file (ALIAS.CMD) and the alias processing code in�
another, separate file (ARUNZ for Alias-RUN-Zcpr)?

     Because there is only a single copy of the ARUNZ code in the system�
rather than a copy of it with each alias, I felt that I could afford to�
expand the code to include many additional features, in particular much more�
extensive parameter expansion capability.  These features will be described�
later.


                             The ALIAS.CMD File

     Let's begin by looking at the structure of the ALIAS.CMD file.  First,�
we should make it clear that ALIAS.CMD is a plain, ordinary text file that�
you create using your favorite text editor or word processor (in non�
document mode).

     Each physical line in the file contains a separate alias definition. �
At present there is no provision for allowing definitions to run over to�
additional lines, so for long scripts your editor has to be able to handle�
documents with a right margin of more than 200 characters.  As I sit here�
composing this column, it occurs to me that a nice solution to this problem�
might be to allow the ALIAS.CMD file to be created by a word processor in�
document mode and to have WordStar-style soft carriage returns be�
interpreted by ARUNZ.COM as line-continuation characters.  I will experiment�
with that possibility after I finish this column, and if it works there may�
be an ARUNZ version 0.9H by the time you are reading this.

     Each alias definition line contains two parts.  The first part, the�
name field, defines the name or names by which the alias will be recognized,�
and the second part, the script field, contains the script associated with�
that name or those names.

     The name field must start in the very leftmost column (no leading�
spaces), and the two fields are separated by a space or tab character.  Thus�
ALIAS.CMD might have the following general appearance:

	FIRST-NAME-FIELD	first script
	NEXT-NAME-FIELD		next script
	...			...
	LAST-NAME-FIELD		last script

For ease of reading, I follow the convention of putting the alias name field�
in upper case and the script strings in lower case, but you can use any�
convention (or no convention) you like, since ARUNZ does not generally care�
about case (the sole exception will be described later).

     To make the ALIAS.CMD file easier to read, you can include comment and�
formatting lines.  Blank lines are ignored and can be used to separate�
groups of related alias definitions.  Also, any line that begins with a�
space (no name field) will never match an alias name and will thus have the�
effect of a comment line.  You can use this to put titles in front of groups�
of definitions.

     To tell the truth, I always wanted to be able to format the ALIAS.CMD�
file as I just described, but I never got around to adding the code to allow�
it.  As I was sitting here writing just now, I suddenly decided to see what�
would happen if the ALIAS.CMD file contained such lines.  With BGii in�
operation, a quick '\s' from the keyboard took me to the alternate task, and�
I gave it a whirl.  Imagine my surprise and delight to discover that the�
formatting already works!  No new code is required.


The Name Field in ALIAS.CMD

     The name field can contain a simple name, like SPACE or ASMLINK, but�
more complex and flexible forms are also supported.  First of all, the name�
field can consist of any number of individual name elements connected by an�
equal sign (with no intervening spaces, since a space would mark the end of�
the name field).  Thus a line in ALIAS.CMD might have the following�
appearance:

	NAME1=NAME2=NAME3	script string

     Secondly, each name element can represent multiple names.  There are�
three characters that have special meanings in a name element.  The first is�
a question mark ('?').  As with CP/M file names, a question mark matches any�
character, including a blank space.  Thus the alias name DIR? will match any�
of the following commands: DIR, DIRS, DIRR, and so on.

     The second special character is currently the period ('.').  For�
reasons that I will not go into here (having to do with a new feature under�
consideration for ZCPR34), I may change this to another character (perhaps�
the asterisk), so check the update documentation with any version of ARUNZ�
beyond 0.9G.  The period does not match any character, but it signals the�
comparison routine in ARUNZ that any characters after the period are�
optional.  If characters are present in the command name, they must match�
those in the alias name, but the characters do not have to be present.  For�
example, the alias name field

	FIND.FILE=FILE.FIND

will match any of the following commands (and quite a few others as well):�
FIND, FINDF, FINDFILE, FILE, FILEF, FILEFIND.  It will not, however, match�
FILES or FINDSTR or FINDFILES.

     I have never had any occasion to make use of the capability, but the�
two special characters can be combined in a single name element.  Thus�
FIND.FI?E matches FINDFILE and FINDFIRE but not FINDSTR, and ?DIR.R matches�
SDIR, SDIRR, XDIR, and XDIRR (but not DIR).  I think you can see that the�
special characters allow for very compact expressions covering many names.

     The third special character is the colon (':').  If any name element�
begins with a colon, then it will match any alias name whatsoever.  This is�
called the default alias, the alias to be run if no other match is found. �
Since ARUNZ scans through the ALIAS.CMD file from top to bottom searching�
for a matching name, if the default name is used at all, it makes sense only�
as the last alias in the file, since no alias definitions in lines below it�
can ever be invoked.  Note that letters after the colon have no�
significance; you may include them if you wish as a kind of comment.

     One possible use for the default alias would be a line like the�
following at the end of the ALIAS.CMD file:

	:DEFAULT echo alias $0 not found in alias.cmd

If no specific matching alias is found, this default alias will report that�
fact to the user as a kind of error message.  I do not recommend using the�
default alias in this way, however, because it will interfere with ZCPR33's�
normal invocation of the error handler when ARUNZ has been set up as the�
extended command processor (ECP) and a bad command is entered.

     There is one use of the default alias that can augment the extended�
command processing power of ZCPR33.  When ARUNZ has been set up as the ECP�
and a command is found neither as a system command, nor COM file, nor ARUNZ�
alias, one might want to try running the command from COMMAND.LBR using the�
LX program.  This is a kind of chained ECP operation.  ARUNZ is the first�
ECP; LX is the second.  This can be accomplished, using version 1.6 or later�
of LX, by adding the following line at the end of the ALIAS.CMD file:

	:ECP-CHAIN lx / $0 $*

The meaning of the parameters $0 and $* will be explained later.  With this�
default alias, if a command cannot be resolved by a specific ARUNZ alias,�
then an LX command line will be generated to search for a COM file with the�
name of the command in COMMAND.LBR.  The special parameter '/' as the first�
command line parameter to LX tells LX, when it cannot resolve the command�
either, to pass to the ZCPR3 error handler only the user command line (i.e.,�
to omit the "LX / " part of the command).

     This might be a good time to note that ARUNZ alias names are not�
limited to only eight characters or to the characters allowed in disk file�
names.  For example, you have a perfect right to define an alias with the�
name FINDFILES (nine letters) and to invoke it with the command ARUNZ�
FINDFILES.  If ARUNZ has been set up as your extended command processor (see�
my book "The ZCPR33 User Guide" for a discussion of ECPs), then when you�
enter the command FINDFILES, the command processor will first look for a�
disk file FINDFILE.COM, since it truncates the command name to eight�
characters.  If this file is not found, the command processor will then, in�
effect, run ARUNZ FINDFILES, including all nine characters.  I have not�
thought of any uses for aliases with control characters in their names, but�
you can define such aliases if you wish.

     Another fine point to be noted is that both leading blank spaces and an�
initial colon are stripped from the command name before scanning for a�
matching alias name.  It is obvious that if leading blanks were not�
stripped, a leading blank would prevent any match from being found.  The�
colon is stripped so that a command entered as ":VERB" will match an alias�
name of 'VERB' without the colon.  If a directory specification is included�
before the colon, it will not be stripped.  When the BADDUECP option is�
enabled in the configuration of ZCPR33, this allows illegal directory�
specifications to be passed to ARUNZ for processing.


The Script Field in ALIAS.CMD

     The script field in the ALIAS.CMD file contains the prototype command�
line to be generated in response to a matching alias name.  The script�
contains three kinds of items:

	(1) characters that are to be put into the command
	    line directly
	(2) parameter expressions that ARUNZ is to evaluate
	    and convert to characters in the command line
	(3) directives to ARUNZ to perform special operations

     There is nothing that has to be said about the first class of�
characters.  They comprise any characters not covered by the other two sets. �
The simple example of the SPACE alias, which would appear in ALIAS.CMD as

	SPACE sp a:;sp b:;sp c:

has only direct characters.  There are no special directives and no�
parameters to evaluate.


ARUNZ Parameters

     ARUNZ supports a very rich set of parameter expressions, which we will�
now describe.  As rich as the set is, there are still important parameters�
that still need to be added.  Some of these will be mentioned later in the�
discussion.  First let's see what we can already do.

     Parameters begin with either a caret ('^') or a dollar sign ('$').  The�
former is quite simple; it is used to signal a control character.  The ASCII�
representation of the character following the caret is logically ANDed with�
1FH, and the result is placed into the command line.  Of course, control�
characters other than carriage return and line feed can equally well be�
placed directly into the script.

     At present there is no trap to prevent generating a null character�
(caret-space will do this: space is 20H, and 20H & 1FH = 00H).  If this is�
used, the resulting null will effectively terminate the command line.  Any�
characters that come after the null character will be ignored by the command�
processor.  This could conceivably be useful for deliberately cancelling�
pending commands in a command line, but I have never used it.  In fact, I�
was surprised to find that I did not have a trap for it.  On thinking about�
it now, however, it seems best to continue to allow it.  Just "user beware!"�
when it comes to employing it.

     Parameters introduced by a dollar sign provide much more varied,�
interesting, and powerful capabilities.  The special ARUNZ directives are�
also introduced by a dollar sign.  A complete list of the characters that�
can follow the dollar sign, grouped by function, is given below.  Detailed�
discussion of each will follow.

	$ ^
	* -
	digit (0..9)
	D U : .
	F N T
	" '
	R M
	I Z


Character Parameters

     The parameters '$' and '^' are provided to allow the two parameter�
lead-in characters to be entered into the command line text.  Many users,�
present company unhappily included, have made the mistake of trying to enter�
a dollar sign directly into the alias script.  If this is done, the dollar�
sign is (mis)interpreted as a parameter lead-in character.  You must put�
'$$' in the script to get a single dollar sign in the command line.

     The worst example I have seen (and committed) of this kind of error is�
in a command like "PATH A0 $$ A0".  This looks perfectly reasonable and does�
not produce any kind of error message when it runs (as "PATH A0 $0 A0"�
would, for example, when $0 got expanded to 'PATH').  Unfortunately, it runs�
as "PATH A0 $ A0", where the single dollar sign now means current�
drive/user-0 (this is perhaps a flaw in the way the PATH works, but that is�
the way it is).  The proper form of the script is

	PATH A0 $$$$ A0

where each pair of dollar signs turns into a single dollar sign.


Complete Command-Tail Parameters

     The parameters '*' and '-' refer to entire sections of the command line�
tail.  The asterisk represents the entire tail exactly as the user entered�
it.  The parameter expression $-n, where 'n' is a number from 0 to 9,�
represents the command tail less the first 'n' tokens (a token was defined�
earlier).  The parameter $-0 has the same meaning as $*.

     Many users have confused 'command line tail' with 'command line'.  The�
two are not the same.  A command line consists of the command name (the�
'verb') and the tail.  Thus the command line tail is the command line less�
the first token.  Perhaps some examples will help.  Suppose the command line�
is

	command token1 token2 token3 token4

Then

	$*   =	"token1 token2 token3 token4"
	$-2  =  "token3 token4"
	$-4  =  ""

Note that $-4 is the null string; that is, $-4 will be replaced by no�
characters at all.

     Also note that there is no leading space in the string assigned to $*. �
ALIAS.COM (and the earliest version of ARUNZ, I believe) had a bug in this�
respect in that it did include the leading space in the command line tail,�
since that is how the tail is stored by the command processor in the buffer�
beginning at memory address 0080H.  The script "find $*" when invoked with�
the tail "string" then became "find  string" with two spaces between "find"�
and "string".  In such a case, Irv Hoff's FIND program failed to work as�
expected, probably because it was looking for " string" with a leading�
space.


Complete Token Parameters

     The digit parameters '0' through '9' represent the corresponding token�
in the command line that is being parsed.  In the example command line above�
the digit parameters have the following values:

	$0  =  "command"
	$1  =  "token 1"
	$5  =  ""

Except for the '0' parameter, these parameters are familiar from the CP/M�
SUBMIT facility.  The expression $0 is an extension used to represent the�
command verb itself.  Just think of the tokens on the command line as being�
numbered in the usual computer fashion starting with zero instead of one.  A�
token that is absent from the command line returns a null string (no�
characters) as with $5 in the above example.

     As just mentioned, many users confuse the command line tail and the�
command line.  If you want only the tail, use the parameter $*.  If you want�
to represent the entire command line, use the expression "$0 $*".  Most�
often it is the command line tail that is to be passed to a command, and the�
ALIAS.CMD line will read something like

	ALIAS realverb $*

This is a direct implementation of the common meaning of 'alias' as another�
name for something.  When ALIAS is invoked, we simply want to substitute�
'realverb' for it while leaving the command tail as it was.

     There are other occasions, however, as with the LX default alias�
example given earlier, where the entire command line must be passed.  There�
are still other occasions, such as in the first default alias example above,�
where only the name of the verb used is needed.  Because a given script in�
ALIAS.CMD can correspond to many possible alias names, it is important to�
have a parameter that will return the name that was actually used in any�
particular instance.


Token Parsing Parameters

     There are many instances in which it is extremely useful to be able to�
break any token down into its constituents.  The parameters  'D', 'U', ':',�
and '.' do this.  They assume that the token is in the form of a file�
specification, which may have (1) a directory specification using either a�
named directory or a drive and/or user number; and/or (2) a file name;�
and/or (3) a file type.  Each of the four parameters above is followed by a�
number from 1 to 9 to designate the token to parse ('D' and 'U' can also�
have a 0).  After discussing each one individually, we will give some�
examples.

     The parameter 'D' returns the drive specified or implied in the�
designated token.  If there is no directory specification or if only a user�
number is given, then $Dn returns the default (logged) drive at the time�
ARUNZ constructs the command line.

     WARNING -- NOTE WELL: this is not necessarily the drive that will be�
logged in at the time when that part of the command actually executes!! �
This, too, has been the source of grief in the use of ARUNZ.  ARUNZ has no�
infallible way to know what directory will be logged in when some future�
command runs; it only knows what directory is the default directory at the�
time ARUNZ itself is running.

     The 'U' parameter is similar in all respects to 'D', and the same�
warning applies.  The parameters $D0 and $U0 can also be used.  They always�
return the default drive and user at the time ARUNZ interprets the script.

     The parameter ':' represents the file name part of the token, while the�
parameter '.' represents the file type part of the token.  One way to�
remember the characters for these two parameters is to think that colon�
stands for the part of the token after a colon and period stands for the�
part of the token after a period.  Admittedly, 'N' for name and 'T' for type�
would have been more sensible, but as we shall see shortly, these are�
already used for something else.

     Generally speaking, the entire token can be represented as

	$Dn$Un:$:n.$.n

where 'n' is a digit.

     Let us consider some examples.  Suppose the following command is�
entered at the prompt:

	B1:WORK>command root:fn1.ft1 c:fn2 2:.ft3

and that COMMAND.COM is not found, so that the command is passed on to ARUNZ�
and the extended command processor.  Also assume that the ROOT directory is�
A15.  Then here are the values of the parameters for the four tokens in the�
command:

	$D0 = "B"	$U0 = "1"	$0  = "COMMAND"

	$1  = "ROOT:FN1.FT1"
	$D1 = "A"	$U1 = "15"	$:1 = "FN1"	$.1 = "FT1"

	$2  = "C:FN2"
	$D2 = "C"	$U2 = "1"	$:2 = "FN2"	$.2 = ""

	$3  = "2:.FT3"
	$D3 = "B"	$U3 = "2"	$:3 = ""	$.3 = "FT3"

Note the value of the following parametric expression:

	$D1$U1:$:1.$.1  =  "A15:FN1.FN2"

You can see that the 'D' and 'U' parameters can be used to convert a named�
directory into its drive/user form.


System File Name Parameters

     The ZCPR3 ENV contains four system file names, each with a name and a�
type.  These file names, numbered 0..3, are used by various programs,�
especially shells.  VFILER and ZFILER, for example, keep the name of the�
file currently pointed to in system file name 1.  These file names can also�
be read and set using the utility program SETFILE.

     The parameters 'F', 'N', and 'T' followed by a digit from 0 to 3�
return, respectively, the entire filename (name.typ), file name, and file�
type of the specified system file.


User Input Parameters

     The single and double quote parameters are used for prompted user�
input.  The forms of the parameter expressions are

	$"prompt"   or   $'prompt'

When the parameter $" or $' has been detected, any characters in the script�
up to the matching parameter character or the end of the script line are�
echoed as a prompt to the user's screen.  These characters are echoed�
exactly as they appear in the script; no conversion to upper case is�
performed.  The prompt string for the double quote parameter can contain�
single-quote characters, and the prompt string for the single quote�
parameter can contain double-quote characters.  There is, at present, no way�
to include the type of quote character used as the parameter in the prompt�
string.

     After the prompt has been output to the console, ARUNZ reads in a line�
of input from the console (user input).  At this point there is a subtle but�
important distinction between the two user input parameters.  The single�
quote form takes the entire text string entered from the console and places�
it in the command line.  In particular, this input may contain semicolons,�
allowing the user to enter multiple commands.  The double quote form ignores�
a semicolon and any text thereafter.  This is intended for secure systems,�
where it prevents the user, when prompted for a program option, from�
slipping in complete additional commands.

     One pitfall to which many users have succumbed is the failure to�
appreciate that the user input parameters perform their function at the time�
that ARUNZ is running and interpreting the script, not when the program in�
the command line is running.  Consider the alias definition

	ERAFILE dir $1;era $"File name to erase: "

The intention here is to first display a list of the files that match the�
first command line token and then to allow the user to enter the one to be�
erased.  This is not what will happen.  ARUNZ will put up the prompt "File�
name to erase: " at the time the command line is being built, i.e., before�
DIR is run.  The prompt will come before the directory display.

     The way around this problem is to use two ARUNZ aliases as follows:

	ERAFILE		dir $1;/eraprompt
	ERAPROMPT	era $"File name to erase: "

Now when ERAFILE is run, it will display the directory and then run the�
command "/ERAPROMPT".  The slash here is a ZCPR33 feature that indicates�
that the command should be sent directly to the extended command processor. �
This saves the time that would otherwise be wasted searching for a file�
named ERAPROMPT.COM (actually, ERAPROMP.COM, since the ninth character will�
be truncated from the name).  If you are not running ZCPR33 (but you should�
be!!) or are running BGii, use a space instead.  This will work with both�
ZCPR33 and BGii and will have no effect in ZCPR30.  I am using the slash in�
the examples because a space is hard to see in print.  When ERAPROMPT runs�
and the user is prompted for the name, the directory listing will already be�
on the screen.

     Whenever console input is requested by any program, one must keep in�
mind the possibility that ZEX will be running and consider the question of�
whether the input request should be satisfied from the ZEX script or by�
direct user input.  ARUNZ is configured, in the absence of a specific�
directive to the contrary, to turn ZEX input redirection off during ARUNZ�
prompted input.  Thus, even if ZEX is running at the time ARUNZ is invoked,�
the user input parameters will request live user input.

     If you do want ZEX to be able to provide the response to ARUNZ prompted�
input automatically from the ZEX script, then you must include the ARUNZ�
directive $I ('I' for input redirection) before the $" or $' parameter.  The�
$I directive is effective only for the next user input operation.  After�
each prompted user input operation, the default for ZEX input redirection is�
turned off.  The $I directive need not immediately precede the $" or $' but�
there must be a separate $I for each input requested.


Register and Memory Parameters

     Two parameters are provided for referencing values of the ZCPR3 user�
registers and the contents of any memory location in the system.

     By Richard Conn's original specification, there were ten user registers�
numbered from 0 to 9.  However, the block of memory in which those ten�
registers fall is actually 32 bytes long.  Conn designated the last 16 bytes�
of this block as 'user definable registers', but he and others later used�
them in programs such as Term3 and Z-Msg.  As a result, one has to be very�
careful in making use of them.  The last 6 bytes of the first half of the�
block were defined as 'reserved bytes'.  Various uses have been made of them�
as well.

     The ARUNZ parameter 'R' can reference any of the first 16 bytes using�
the form $Rn, where 'n' is a hexadecimal digit.  The decimal digits�
reference the true user registers, and the additional digits 'A' through 'F'�
reference the reserved bytes.  In the current version of ARUNZ, the value is�
returned as a two character hexadecimal value.  However, I would like to�
provide in the future a way to return the value in either decimal or�
hexadecimal form.  A complication with the decimal form is the need to�
indicate the format: one character, two characters with leading zeros, three�
characters with leading zeros, or the number of characters required for the�
particular value with no leading zeros.

     One of the uses I envisioned for this parameter, though I have never�
actually used it this way, is for automatic sequential numbering of files. �
Thus a script might include the string "copy $:1$r3.$.1=$1;reg p3".  This�
would copy the working file given by token 1 to a new file with the hex�
value of register 3 appended to the file name.  For a file name of PROG.Z80�
this might be PROG03.Z80.  Then the value of register 3 would be incremented�
so that the next file name in sequence (PROG04.Z80) would be used the next�
time the alias was invoked.

     The parameter 'M' is used in the form $Mnnnn, where 'nnnn' is a�
precisely four-digit hexadecimal address value.  The parameter returns the�
two character hexadecimal value of the byte at the specified memory address. �
I use this on my RAS to determine if the system is running in local mode. �
The BDOS page at address 0007H has a different value when BYE is running. �
There might be a script of the form

	if eq $m0007 c6;....;else;echo not allowed in remote mode;fi

The commands represented by the ellipsis "...." will run only if in local�
mode (BDOS apparently located at page C6H).


ARUNZ Directives

     There are presently two ARUNZ directives.  We already discussed one of�
them, 'I', under the user input parameters.  The other one is 'Z'.

     Ordinarily, once ARUNZ has interpreted the alias script and evaluated�
the parameters, it appends to the resulting command line any commands in the�
multiple command line buffer that have not already been executed.  This is�
usually what one wants.  There is one possible exception.

     As I discussed in issues #27 and #28 of The Computer Journal, one�
sometimes wants an alias to invoke itself or other aliases recursively. �
This can sometimes lead to problems with the build up of unwanted pending�
commands that eventually causes the command line to overflow the buffer�
space allowed for it.  In such a case one might want only the current�
expanded script command line to be placed in the MCL, with any pending�
commands dropped.  A $Z directive anywhere in the script will cause ARUNZ to�
do this.  Note that the directive is not a toggle; multiple uses has the�
same effect as a singe use.  Remember, however, that Dreas Nielsen's alias�
recursion technique, described in issue #28 and in examples below, is�
generally preferable to the technique using $Z.


                       Applications for ARUNZ Aliases

     In this section I will use a number of sample scripts to illustrate�
various ways in which one can make use of the power of ARUNZ aliases.  I'm�
sure there are many I have not thought of, and I invite you to send me your�
suggestions and examples.  In all cases I will be assuming that ARUNZ is the�
extended command processor (typically renamed to CMDRUN.COM).

     In general, one can identify the following classes of alias�
applications:

	(1) providing synonyms for commands
	(2) trapping and/or correcting command errors
	(3) automating complex operations into single commands

Within the last category fall two special subclasses:

	(a) performing 'get, poke, & go' operations
	(b) providing special functions like recursion and repetition


Command Synonyms

     The most basic use of aliases is to provide alternative names for
commands.  Here are some examples from my personal ALIAS.CMD file.

     For displaying the directory of a library file, I now use the program�
LLF.  However, after years of using LDIR, both before LLF was released and�
still on most remote access systems, I prefer to use that name and have�
renamed LLF.COM to LDIR.COM.  Sometimes, however, I forget or want to be�
sure I am running LLF and enter the command LLF explicitly.  Then I am saved�
by the alias line

	LLF ldir $*

Similarly, I have recently begun to use LBREXT instead of LGET.  LGET is�
easier to type, and I am used to it, so I have the alias

	LGET lbrext $*

LBREXT is so new that I did not want to rename it to LGET, since I might too�
easily forget which program the disk file really is.  I know I never have�
the old LDIR.COM around any more.  In both of these examples, the alias�
simply substitutes a different verb in the command line; the tail is left�
unchanged.

     Before the advent of ZCPR33, when path searching always included the�
current directory, I would speed up the disk searching in these cases by�
including an explicit directory reference with the script.  Thus the two�
commands above might be

	LLF   a0:ldir $*
	LGET  a0:lbrext $*

This way the command processor would go straight to A0 no matter where I was�
logged in at the time.

     With ZCPR33 one can bypass the path search for commands that one knows�
are in ALIAS.CMD by entering the command with a leading space or slash�
(assuming the usual configuration of ZCPR33).  Sometimes I might try to�
outfox the system and, thinking LBREXT is the alias name, enter the command�
as '/LBREXT ...'.  So that this will work, I extend the alias lines to

	LLF=LDIR     a0:ldir $*
	LGET=LBREXT  a0:lbrext $*

The command is an alias for itself!!  Odd, but useful.  It is a good idea if�
you do this, however, to be absolutely sure to include an explicit directory�
prefix before the command name in the script.  If you don't, the following�
situation can arise.  Suppose the alias line reads

	TEST test $*

but for some reason TEST.COM is not on the disk (or at least not on the�
search path).  Now you enter the command TEST.  The command cannot be found�
as a COM file, so the command processor sends it to ARUNZ.  ARUNZ proceeds�
to regenerate the same command, which again cannot be found, and so on until�
you press the little red button or pull the plug.  Not always to complete�
catastrophe, but definitely a nuisance.  With ZCPR33, if the command has an�
explicit directory prefix, control is passed directly to the error handler�
if the COM file cannot be found in the specified directory.  It figures that�
if you go to the trouble of specifying the directory, you must mean to look�
there only.

     Another use for synonyms is to allow a short-form entry of commands. �
Here are two examples:

	SLR.180  asm:slr180 $*
	ED.IT    sys:edit $*

     Synonyms are especially helpful on a remote access system or on any�
system that will be used by people who are not familiar with it or expert in�
its use.  Consider, for example, the task of finding out if a certain file�
is somewhere on the system and where.  Some systems use FINDF, the original�
ZCPR3 program for this purpose; others use one of the standard CP/M programs�
(WIS or WHEREIS); and others have begun to use the new, enhanced ZSIG�
program called FF.  This can be very confusing to new users or to users who�
call many different systems.  The solution is to provide aliases for all the�
alternatives.  Suppose FF is the real program in use.  Then the following�
line in ALIAS.CMD will allow all the forms to be used equally:

	FINDF=WIS=WHEREIS ff $*

In fact, while I am at it, I usually throw in a few other forms that someone�
might try and that are sufficiently unambiguous that one can guess with some�
confidence that this is the function the user intended:

	FIND.FILE=FILE.FIND=WIS=WHERE.IS=FF a0:ff $*

Note that this single alias, which occupies only 46 bytes in ALIAS.CMD�
(including the CRLF at the end of the line), responds to 8 commonly used�
commands for finding files on a system.  Thus the cost is a mere 6 bytes per�
command!!


Trapping and Correcting Command Errors

     Aliases can be used to trap commands that would be errors and either�
convert them into equivalent valid commands or provide some warning message�
to the user.

     It is generally not desirable to have a very long search path, because�
every time a command is entered erroneously, the entire path has to be�
searched before the extended command processor will be brought into play. �
On my SB180 with its RAM disk, I sometimes want the path to include only�
M0:, the RAM disk directory.  The RAM disk, of course, cannot contain all of�
the COM files I use.  For COM files that reside on the floppy disk, I can�
include an alias.

     For example, MEX.COM and all its associated files take up a lot of disk�
space, and I keep them in a directory called MEX on my floppy drive B.  The�
ALIAS.CMD file can have the line

	MEX mex:mex $*

Without this alias I would have to remember to enter MEX:MEX manually.  If I�
forgot, I would get the error handler and then have to edit the line to�
include the MEX: prefix.  The 16-byte entry above in the ALIAS.CMD file�
saves me all this trouble.

     Every computer user probably has some commands whose names he�
habitually mistypes (switching 'g' and 'q' for example or reversing two�
letters).  My fingers seem to prefer 'CRUNHC' to 'CRUNCH', so I have the�
following alias line:

	CR.UNHC crunch $*

Note that while I am at it, I allow the shorter form CR as well.  My fingers�
like that even better.

     On a remote access system there are many situations where correcting�
common mistakes can be handy.  Richard Jacobson (Mr. Lillipute, sysop of the�
RAS that now serves TCJ subscribers) calls my Z-Node quite often.  Either he�
has a Wyse keyboard with very bad bounce (as he claims) or he is a lousy�
typist (and refuses to admit it).  When he wants to display a directory, his�
command is more likely to come out DDIR or DIRR than it is to come out�
correctly as DIR.  So I added those two forms to my existing alias which�
allowed XD and XDIR (and /DIR); it now reads:

	XD.IR=DDIR=DIR.R a0:dir $*

Compensating for Richard's keyboard stutter takes up only seven extra bytes�
on my disk, not a very big sacrifice to make for a friend!

     Another example, one that is more than just a synonym for a mistyped�
command, is an alias that comes into play when a command becomes�
unavailable, perhaps because of a change in security level.  The RCP may,�
for example, have an ERA command that is only available when the wheel byte�
is set.  When the wheel byte is off, ZCPR33 will ignore the command in the�
RCP and forward an ERA command to the extended command processor or error�
handler (assuming there is no ERA.COM).  You might want to trap the error�
before the error handler gets it using an alias such as

	ERA echo e%>rasing of files not allowed

When the wheel byte is set, the ERA command will execute normally (unless�
entered with a leading space or slash).  When the wheel byte is off, the�
user will get the message "Erasing of files not allowed", which, unlike the�
invocation of an error handler, makes the situation perfectly clear.

     It is obviously very hard for users to remember the DU forms for�
directories on a remote system, and that is one reason why named directories�
are provided.  But even names are not always easy to remember precisely.�
Aliases can help by providing alternative names for logging into�
directories, provided ZCPR33 has been assembled with the BADDUECP option�
enabled so that invalid directory-change references are passed on to the�
extended command processor.

     Suppose you have a directory called Z3SHELLS.  One might easily forget�
the exact name and think that it is Z3SHELL or SHELLS or SHELL.  The�
following line in ALIAS.CMD

	Z3SHELL:=SHELL:=SHELLS: z3shells:

would take care of all of these possibilities.  Note, however, that it will�
not help a reference like "DIR SHELL:".  [If you wanted this to be accepted,�
you would have to go to considerable trouble.  You might be able to go into�
the NDR (named directory register) and tack onto the end an entry for a�
directory named SHELL associated with the same drive and user as Z3SHELLS. �
All existing NDR editors will not allow a DU area to have more than one�
name, so you would have to use a debugger or patcher.  If anyone tries this,�
let me know if it works.]

     I occasionally slip up and omit the colon on the end of a directory�
change command (and users on my Z-Node do it surprisingly often).  It is�
very easy for ARUNZ to pick this up as well and add the colon for you.  Just�
include the following alias line:

	Z3SHELL=Z3SHELLS=SHELL=SHELLS z3shells:

All of these aliases can be combined into the single script:

	Z3SHELL.:=Z3SHELLS=SHELL.:=SHELL.S: z3shells:

Seven forms are covered by an entry of only 47 bytes, a cost of less than 7�
bytes each.  Note that the name element Z3SHELLS, unlike the other three�
name elements, does not allow an optional colon.  If it were included and�
for some reason there were no directory with the name Z3SHELLS, you could�
get into an infinite loop.

     On my Z-Node I provide a complete set of aliases for all possible�
directories so that any legal directory can be entered with or without�
colons and using either the DIR or the DU form.  Thus, if Z3SHELLS is B4,�
the script above would be:

	Z3SHELL.:=Z3SHELLS=SHELL.:=SHELL.S:=B4.: z3shells:

     Before ZCPR33 came along and provided this service itself, I would�
allow callers to use the DU form to log into unpassworded named directories�
beyond the max-drive/max-user limits by including aliases of the above form. �
If the maximum user area were 3 in the above example, the commands "B4:" and�
"B4" would still have worked (even under ZCPR30) because ARUNZ mapped them�
into a DIR form of reference.  Although this is no longer necessary with�
ZCPR33, a complete alias line like the one above covers all bases. The user�
can even enter any of the commands with a leading space or slash and they�
will still work.

     Finally, I provide on the Z-Node a catch-all directory change alias to�
pick up directory change commands that don't even come close to something�
legal.  At the end of ALIAS.CMD (i.e., after all the other directory-change�
aliases described above, so that they get the first shot at matching), I�
include the line

	?:=??:=???:=????:=?????:=??????:=???????:=????????: echo
	  d%>irectory %<$0%> is not an allowed directory.  %<t%>he^m^j
	  valid directories are:;pwd

Thus when the user enters the command "BADDIR:", he get the PWD display of�
the system's allowed directories prefixed by the message

	Directory BADDIR: is not an allowed directory.  The
	valid directories are:

[Note the use of Z33RCP's advanced ECHO command with case shifting ('%< to�
switch to upper case and '%>' to switch to lower case) and control character�
inclusion (caret followed by the character).]


Automating Complexity

     Complexity is a relative term, and in my old age (also relative) I�
enjoy the luxury of letting my computer perform as much labor on my behalf�
as it possibly can.  We already saw how ARUNZ aliases can provide short�
forms for commands (CR for CRUNCH).  It can also allow one to completely�
omit commands.

     At work I have been maintaining a phone directory in a file called�
PHONE.DIR.  I got tired of invoking my PMATE text editor using the command�
"EDIT A0:PHONE.DIR", so I added the following line to ALIAS.CMD:

	PHONE edit a0:phone.dir

Now I just type PHONE and, bingo, I'm in the editor ready to add a new name. �
Similarly, I used to look up numbers for people using JETFIND as follows:

	JF -gi smith|jones a0:phone.dir

This would give me, from any directory, a paginated listing of lines in�
PHONE.DIR containing either "smith" or "jones" (ignoring case).  My poor�
tired fingers ache just thinking about all that typing.  Now I have the�
alias line

	#=CALL=NUM.BER jf -gi $1 a0:phone.dir

Now a simple " # smith" puts Smith's number up on my clean CRT screen in a�
jiffy.

     Here is another frequent command that causes severe finger cramps.  You�
want to find all the files in the current directory that have a type�
starting with 'D'.  You have to type "XD *.D*".  Wouldn't it be nice to have�
a directory program that automatically wildcarded the file specification. �
While I was fixing up FINDF to make my new FF, I built that feature into the�
code.  I've been too busy or too lazy to do the same for XD, so instead I�
added the alias line

	D xd $d1$u1:$:1*.$.1* $-1

This is a little hard to decipher at a glance because of all the dots and�
colons and asterisks.  But here's how it works.  Suppose we are in B4: and�
enter "D .D /AA" (the option /AA means to include SYS and DIR type files). �
The parameters in the alias have the following values:

	$D1 = "B"    $U1 = "4"		current drive and user, since
					none given explicitly

	$:1 = ""			no file name given

	$.1 = "D"			file type in first parameter

	$-1 = "/AA"			the tail less the first token ".D"

The command is thus translated by ARUNZ into

	XD B4:*.D* /AA

     Sometimes it can be nice to allow a command that takes a number of�
alternative options to run with only the option entered on the command line. �
I have a read file for MEX that provides automated, menu-based operation on�
PC-PURSUIT.  I could invoke it as "MEX PCP".  Instead, I have the alias

	PCP  mex pcp

I also do this with the KMD file transfer commands on my Z-Node, where I�
define the following aliases:

	S	kmd s $*
	SK	kmd sk $*
	SB	kmd sb $*
	SBK	kmd sbk $*
	SP	kmd sp $*
	SPK	kmd spk $*
	R	kmd r $*
	RP	kmd rp $*
	RB	kmd rb
	RP	kmd rp $*
	L	kmd l $*
	LK	kmd lk $*

This way the user can skip typing "KMD".  Actually, these aliases each�
contain numerous other synonyms as well.  The 'S' alias, for example,�
includes "SEND", "DOWN", and "DOWNLOAD" as well.  The cost in terms of disk�
space to add all these aliases is so small that I let my enthusiasm and�
imagination run wild.  Note, however, that with the above aliases defined,�
the RCP should not have the 'R' (reset) and 'SP' (space) commands, since�
they will take precedence over the alias.  I changed the names of these�
commands to 'RES' and 'SPAC'.  The remote user has no reason to use them�
anyway.

     There are, of course, many really complicated sequences of commands�
(editing, assembling, and linking files, for example) that can very nicely�
be performed by aliases.  Those are fairly obvious, and I have described�
quite a few in previous columns.  I won't give any more examples here, but I�
will describe two special applications where ARUNZ aliases cut down a�
complex process to simple proportions.  The first is automation of the get�
poke-go technique pioneered by Bruce Morgen.


Automated GET-POKE-GO

     Here the alias does more than just save typing -- it remembers the�
addresses that have to be poked, something you probably can't do.  I will�
illustrate it with an intriguing example that is sort of recursive.

     Suppose ARUNZ is the extended command processor, has been renamed�
CMDRUN.COM, and is set to get its ALIAS.CMD file from the root directory. �
Next, suppose you also want to be able to invoke it manually and have it, in�
that case, look for its ALIAS.CMD file along the entire path, including the�
current directory.  Suppose, furthermore, that CMDRUN.COM is a type-3�
program that loads and runs at address 8000H.

     By inspecting CMDRUN.COM, we find that we have to poke a 0 at offset�
1CH (address 801CH) to turn off the ROOT configuration option and an FFH at�
offset 24H (address 8024H) to turn on the SCANCUR option.  If we are to make�
manual invocations using the alias name 'RUN', we can put the following line�
in the ALIAS.CMD file in the root directory, where the unpoked CMDRUN.COM�
will find it:

	RUN get 8000 cmdrun.com;poke 801c 0;poke 8024 ff;jump 8000 $*

I particularly chose this example because it illustrates the slightly more�
advanced version of GET-POKE-GO called GET-POKE-JUMP.  One word of caution. �
This technique will only work under ZCPR33.  BGii version 1.13 is very close�
to ZCPR33, but it still handles the JUMP command the way ZCPR30 did, and it�
cannot use JUMP when a command tail is processed.

     I will now describe two very special operations that can be performed�
very nicely with ARUNZ aliases: recursion and repetition.


Special Recursion Aliases

     The following pair of aliases (more or less) that implement Dreas�
Nielsen's recursion technique were described in my column in issue 28.  They�
allow one to execute a single command recursively.  With each cycle the user�
will be asked if he wants to continue.  So long as the answer is yes, the�
command will be executed repeatedly.  Upon a negative reply, the recursive�
sequence will terminate, and any pending commands will execute.

     The alias that the user invokes can be called "REC.URSE" so that it can�
be invoked with a simple 'REC'.  It contains the following sequence of�
commands:

	if nu $1
	  echo;echo %<  s%>yntax: %<$0 cmdname [parameters]^j
	else
	  /recurse2 $*
	fi

If invoked without at least a command name, this alias echoes a syntax�
message to the screen.  Otherwise it invokes the second alias RECURSE2.  The�
leading slash speeds things up by signaling the ZCPR33 command processor�
that it should go directly to the extended command processor.  If you are�
using BackGrounder-ii (version 1.13), the slash should be replaced by a�
space (the alias will then work with BGii or Z33).  If you are using ZCPR30,�
don't use either; a space won't do you any good, and a slash will cause the�
command to fail.

     The alias that does the real recursion (RECURSE2) has the following�
sequence of commands:

	fi
	$*
	if in r%>un %<"$*" %>again?
	  /$0 $*

If the user answers the 'run again' query affirmatively, RECURSE2 will be�
invoked again.  By using '$0' instead of 'RECURSE2' the script will work�
even if we later change its name.


Special REPEAT Alias

     Here is a simple special alias that will allow a command that takes a�
single argument (token) to be repeated over a whole list of arguments�
separated by spaces (not commas).  The name of the alias is "REP.EAT" so�
that it can be invoked with a brief 'REP'.  The script contains the�
following commands:

	$zxif
	if ~nu $2
	  echo $1 $2
	  $1 $2
	fi
	if ~nu $3
	  /$0 $1 $-2
	fi

The '$z' in the first line declares the alias to be in recursive mode (any�
pending commands in the multiple command line buffer are dropped when this�
alias executes), and 'xif' clears the flow state.  Invoked as

	REPEAT CMDNAME ARG1 ARG2 ARG3

for example, interpretation of the script the first time through results in�
the following commands:

	xif
	if ~nu arg1
	  echo cmdname arg1
	  cmdname arg1
	fi
	if ~nu arg2
	  /repeat cmdname arg2 arg3
	fi

The command line generated ("CMDNAME ARG1") is first echoed to the screen so�
the user knows what is going on, and then it is run.  Since there is a�
second argument, the alias is reinvoked as "REPEAT CMDNAME ARG2 ARG3".  Note�
that the first argument has been stripped away.  After "CMDNAME ARG2" has�
also been run and stripped from the command, the interpreted command string�
will be:

	xif
	if ~nu arg3
	  echo cmdname arg3
	  cmdname arg3
	fi
	if ~nu
	 /repeat cmdname
	fi

This time the null test in the second IF clause will fail, and the cycle of�
commands will come to an end.

     This form of the REPEAT alias suffers from the problems Dreas Nielsen�
pointed out (it wipes out any commands following it on the original command�
line).  A rigorous version can be made (adapting Dreas's technique) by�
making two aliases as follows:

   REP.EAT
	if nu $2
	  echo;echo %<  s%>yntax: %<$0 aliasname arg1 arg2 ...^j
	else
	  /repeat2 $*
	fi

   REPEAT2
	fi
	$1 $2
	if ~nu $3
	  /$0 $1 $-2

If there is not at least one argument after the name of the command, a�
syntax message is given.  Otherwise a series of operations using REPEAT2�
begins in which the command is executed on the first argument, and then�
REPEAT2 is reinvoked with the same command name but with one argument�
stripped from the list of arguments.  Note that the parameter $-2 is used. �
The first parameter (the command verb) is given explicitly as $1.  "$-2"�
strips away the verb and the argument that has already been processed.  The�
expression "$1 $-2" allows one to strip out the second token.  Similarly,�
"$1 $2 $-3" would strip out the third token.  "$1 $-3" would strip out the�
second and third tokens, leaving the first one intact and moving the�
remaining tokens down by two.

                             Configuring ARUNZ

     There are several configuration options that allow the user to tailor�
the way ARUNZ operates.  The COM file is designed to make it easy to patch�
in new values for most of the options using a program like ZPATCH.


Execution Address for ARUNZ

     ARUNZ is written as a type-3 ZCPR33 program.  In other words, it can�
automatically be loaded to and execute at an address other than 100H.  In�
this way, its invocation as an extended command processor can leave most of�
the TPA (transient program area) unaffected by its operation.  In the LBR�
file posted on RASs there are generally two versions of ARUNZ, one designed�
to run at 100H (and usable in ZCPR30 systems) and one designed to run at�
8000H.  Sometimes there are also REL files that the user can link with the�
ZCPR libraries to run at any desired address.


Display Control

     There are two bytes just after the standard ZCPR3 header at offset 0DH�
in the COM file (just before the string "REG") that control the display of�
messages to the user during operation of ARUNZ.  The first byte applies when�
ARUNZ has been invoked under ZCPR33 as an extended command processor; the�
second applies to manual invocation (or any use under ZCPR30).

     Each bit of these two bytes could control one display feature.  At�
present, only six of the bits are used.  Setting a bit causes the message�
associated with the bit to be displayed; resetting the bit supresses the�
display of the corresponding message.

     The least significant bit (bit 0) affects the program signon message. �
The usual setting is 'off' for ECP invocations and 'on' for manual�
invocations.  Bit 1 affects the display of a message of the form 

	Running alias "XXX"

This message is normally displayed only for manual invocations of ARUNZ.

     Bit 2 controls the display of the "ALIAS.CMD file not found" message. �
This message should generally be enabled, since it will not appear unless�
something has unexpectedly gone wrong, and you might as well know about it.

     Bit 3 controls the display of a message of the form

	Alias "XXX" not found

This message is normally turned on for manual invocations only.  When the�
alias is not found by ARUNZ operating as a ZCPR33 ECP, control is turned�
over to the error handler, and there is no need for such a message.  The�
message can alternatively be generated, in whatever form the user desires,�
using a default alias as described earlier.  In that case, however, the�
message will appear for ECP as well as manual invocations.

     Bits 4 and 5 apply only when ARUNZ has been invoked as an extended�
command processor, and they were included as a debugging aid while I was�
first developing ARUNZ.  Both are normally turned off.  If bit 4 is set,�
ARUNZ will display the message "extended command processor error" if it�
could not process the alias during an ECP invocation.  Bit 5 controls a�
message of the form "shell invocation error".  It is possible (though very�
tricky and not recommended) for an alias to serve as a shell.  If ARUNZ�
fails to find an alias when invoked as a shell processor, then this message�
will be displayed if bit 5 is set.


Locating the ALIAS.CMD File

     There are several possibilities for how ARUNZ is to go about locating�
the ALIAS.CMD file.  There are four configuration blocks near the beginning�
of the ARUNZ.COM file; they are marked by text strings "PATH", "ROOT",�
"SCANCUR", and "DU".  If the byte after "PATH" is a zero, then ARUNZ will�
look in the specific drive and user areas indicated by the two bytes�
following the string "DU".  The first byte is for the drive and has a value�
of 0 for drive A, 1 for B, and so on.  The second byte has the user number�
(00H to 1FH).

     If the byte after the string "PATH" is not zero, then some form of path�
search will be performed depending on the settings of the bytes after the�
strings "ROOT" and "SCANCUR".  If the byte after "ROOT" is zero, then the�
entire ZCPR3 path will be searched.  If the byte after "SCANCUR" is nonzero,�
then the currently logged drive and user will be included at the beginning�
of the path.  If the byte after "ROOT" is nonzero, then only the root�
directory (last directory specified in the path) will be searched, and the�
byte after "SCANCUR" is ignored.

     My general recommendation is to use either the root of the path or a�
specified DU, especially when ARUNZ is being used as the extended command�
processor.  It can take a great deal of time to search the entire path�
including the current directory.  With ARUNZ as the ECP this will be done�
every time you make a typing mistake in the entry of a command name, and the�
extra disk accesses can get quite tedious and annoying.


Use Register for Path Control

     There is an alternative way to control the path searching options that�
can give one the best of all possible worlds.  After the string "REG" one�
can patch in a value of a user register, the value of which will be used to�
specify the path search options PATH, ROOT, and SCANCUR instead of the fixed�
configuration bytes described above.

     Any one of the full set of 32 ZCPR3 registers can be specified for this�
function by patching in a value from 00H to 1FH.  If any other value is�
used, the fixed configuration bytes will be used.  If a valid register is�
specified, its contents are interpreted as follows:

	bit 0		PATH flag (0 = use fixed DU; 1 = use path)
	bit 1		ROOT flag (0 = use entire path; 1 = use root only)
	bit 2		SCANCUR flag (0 = use path only; 1 = include
				current DU)

By changing the value stored in the specified register, one can change the�
way ARUNZ looks for the ALIAS.CMD file dynamically depending on the�
circumstances.


                            Plans for the Future

     I don't have much writing stamina left, but I would like to finish with�
a few comments about developments I would still like to see in ARUNZ.  A few�
were mentioned in the main text above.  There is a need for some additional�
parameters, such as register values in various decimal formats.  One also�
needs more flexible access to the directory specification part of a token. �
The present parameters only allow extracting a DU reference, and they don't�
allow any way to tell if an explicit directory is specified.  There should�
be a parameter that returns whatever DU or DIR string (including the colon)�
is present.  If none is present, the parameter should return a null string.

     One of the things hampering the additional of more parameters is the�
arcane form they presently take.  I would like to find a much more rational�
system (and if you have any suggestions, I would love to hear them).  I am�
thinking of something like $S for system file, followed by 'F', 'N', or 'T'�
and then a number 0..3.  Thus $ST2 would read Systemfile-Type-2.  Command�
line tokens might be $T followed by 'D', 'U', 'P', 'F', 'N', or 'T' and then�
a digit 0..9 or 1..9.  The 'P' option (path) would be the DU or DIR prefix,�
if any, including the colon.  Problem: what letter do I use for the named�
directory or the path without the colon?  The logical choices 'N' and 'D'�
are already used.  Maybe I have to go to four letters: $T for token,�
followed by 'D' for directory part or 'F' for file part.  The 'D' could be�
followed by various letters (again, I am not sure what to use for all of�
them) to indicate:

	1) the equivalent drive or default if none specified
	2) the equivalent drive or null string if none specified
	3) the same two possibilities for the user number
	4) the equivalent or given named directory (but what if the
	   directory has no name)
	5) the whole directory prefix as given either including or not
	   including the colon

Similarly, the 'F' option could be followed by a letter to indicate the�
whole filename, the name only, or the type only.  As you can see, it is not�
easy to identify all the things one might need and find a rational way to�
express them all.

     It would be nice to have prompted input where the user's input could be�
used in more than one place in the command line.  User input would have to�
be assigned to temporary parameters ($U1, $U2, and so on).  Perhaps there�
should be the possibility of specifying default values for command line�
tokens when they are not actually given on the command line (as in ZEX).  It�
might also be useful to be able to pull apart a token that is a list of�
items separated by commas.

     ARUNZ could use better error reporting for badly formed scripts.  At�
present one just gets a message that there was an error in the script, but�
there is no indication of what or where the error was.  Ideally, the�
interpreted line should be echoed to the screen with a pointer to the�
offending symbol (NZEX has this).

     There should be an option to have ARUNZ vector control to the ZCPR3�
error handler whenever it cannot resolve the alias or when there is a defect�
in the script.  At present, chaining to the error handler only occurs when�
ARUNZ has been invoked as an ECP.

     An intriguing possibility is to allow alias name elements to be regular�
expressions in the Unix (or JetFind) sense.  Then one could give an alias�
name like "[XS]DIR" to match either XDIR or SDIR.  Perhaps there could be a�
correspondence established between non-unique expressions and a parameter�
symbol in the script.  Then all my KMD aliases might be simpler:

	S[P]*[K]*  kmd s$x1$x2 $*

The name would read as follows: 'S' followed by zero or more occurrences of�
'P' followed by zero or more occurrences of 'K'.  The parameter $X1, for�
example, would be the first regular expression, i.e., the 'P' if present or�
null if not.  This is fun to think about, but I am not at all sure that it�
would really be worth the trouble to use or to code for.  Any comments.

     It would also be nice to provide Dreas Nielsen's RESOLVE facility�
directly in ARUNZ aliases.  These would use the percent character ('%') as a�
lead-in.  Any symbol enclosed in percent signs would be interpreted as a�
shell variable name, and its value from the shell file would be substituted�
for it in the command line.  The parameter '$%' would be used to enter a�
real percent character.


                                 Next Time

     As usual, I have written much more than planned but not covered all the�
subjects planned.  I really wanted to discuss shells in more detail,�
particularly after the fiasco with the way WordStar 4 behaves by trying to�
be a shell when it should not be.  That will have to wait for next time, I�
am afraid.  Also by next time I should be ready to at least begin the�
discussion of ZEX.
 