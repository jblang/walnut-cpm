                               Z-System CorneÚ (c)
                                 by Jay Sage
                        The Computer Journal, Issue 36
                          Reproduced with permission
                           of author and publisher


     I wonder if the approach of a TCJ deadline will ever find me with noç
pressing commitments to interfere with my writing this column.  That isç
always my dream, but the prospects of its happening get dimmer by the month. ç
My schedule just keeps getting worse and worse.  This time I was not evenç
able to start the column until after the deadline had passed.  As a result,ç
it will surely be shorter than usual, and it will probably not haveç
benefited from my usual multiple rewrites and the careful scrutiny of Howardç
Goldstein, on whom I have relied in the past not only to check my code butç
to check my writing as well.  He is remarkably good at both jobs!

     As has become the pattern for my columns, before I turn to the mainç
technical subject, which will be a discussion of some of the capabilities ofç
the ZFILER shell, I would like, to talk about a few nontechnical issues.


                            Z Systems Associates


     It may have taken the retirement of Frank Gaude' and the demise ofç
Echelon (at least as a force in the Z community) to make me realize just howç
much work Frank must have been doing, and I can now understand why he was soç
burned out in the end.  The reason why I now appreciate his efforts in a wayç
that was impossible before is that I have been in the process these last fewç
months of setting up a new company -- Z Systems Associates or ZSA -- toç
serve as a central marketing organization for Z-System and related products.

     Frank's retirement probably could not have come at a worse time for us. ç
With NZ-COM and Z3PLUS we finally had Z-Systems that did not require aç
programmer's mentality and programmer's abilities to be able to set up andç
use.  We were also no longer limited to CP/M-2.2 computers.  Our potentialç
market had now become the literally millions of people with CP/M computersç
of any kind, including especially the Commodore 128s and Amstrads runningç
CP/M-Plus and the CP/M-2.2 ADAMs.  We have never had any contact with thoseç
communities in the past, and it is going to take a lot of work to developç
those contacts now.

     The community of CP/M-2.2 hobbyists will, of course, be our marketingç
front line.  To that end, we have established two plans, one involving theç
Z-Node remote access computer systems and the other, the hundreds ofç
computer clubs around the world.

The Z-Node Plan

     Echelon had a nice plan that recognized the important role Z-Nodeç
sysops play in disseminating information about the Z-System and in providingçäsupport to those who use it.  It allowed Z-Nodes to act as dealers forç
Echelon's products and thus to gain some compensation for their efforts.  Zç
Systems Associates has started a similar plan.  I will not go into theç
details here, but if you are a Z-Node sysop and have not heard from me,ç
please drop me a line at the address in the Sage Microsystems East ad.

     Unfortunately, we do not have a list of the names and addresses of theç
Z-Node sysops.  Somewhere along the way that information got lost and wasç
never passed on from Echelon.  So, a couple of weeks ago I sat down at myç
computer on a Saturday afternoon and started to call all the Z-Nodes in theç
United States and Canada.  I did not count how many numbers were listed inç
Echelon's last ZNODES.LST file, but there must have been well over 50.  Atç
first I tried to figure out which ones were accessible by PC-Pursuit, butç
the task was monumental enough without having to put up with the perpetuallyç
busy PCP circuits.  My phone bill came a few days ago, and it was amazing toç
see the number of pages of calls.  Since each call was rather short,ç
however, the bill was surprisingly low.

     Although I started making the calls in the afternoon, I kept at it wellç
into the night.  At a point when I could hardly keep my eyes open, Iç
connected to a system out West and, as a new user, went through theç
procedure of identifying the city and state from which I was calling.  Theç
system then greeted me very nicely and reported that the time was 1:05 am. ç
Amazing, I thought!  That was just what my watch showed here in Boston. ç
This was the first system I had ever called that was so sophisticated thatç
it actually adjusted the time display to the caller's time zone.  Well, itç
wasn't until the next morning that I realized that the battery in my wristç
watch was failing and that the watch had jumped back three hours.  It hadç
really been 4 am!  No wonder I felt so tired.

     The whole experience of calling the Z-Nodes was rather disheartening. ç
I discovered that many Z-Nodes had long ago gone off the air.  The numbersç
of the more recently departed were answered with messages from the phoneç
company reporting that they were no longer in service.  Those long gone wereç
answered by actual people, who usually had had that number for over a year. ç
Considering that when my watch said 11 pm, it may actually have been as lateç
as 2 am, it is amazing how civil all of these people were to me.  Yes, theyç
admitted, they did get an awful lot of calls with no one on the other end. ç
I explained why this was happening, that they were being called by aç
computer, and I promised to try to get their numbers removed from the lists.

     Several Z-Nodes had become private systems, and I was prompted for aç
password without any signon message at all or just a brief, "private system,ç
enter password."  A few systems, as one would expect, had gone over to MS-DOS.  All in all, no more than half the nodes on the list appear still to beç
active.

     In view of this situation, I would like to encourage the establishmentç
of new nodes.  Some of the nodes on Echelon's list, I learned, actuallyç
never went into operation because the sysop was unable to get Z-Systemç
running on his computer.  With NZ-COM and Z3PLUS this will be much less of aç
problem.  If you think you might be interested in setting up a Z-Node orç
converting your present system to one, please give me a call or drop me açänote in the mail.

The Z-Plan for Computer Clubs

     Computer clubs are probably the single most effective and valuableç
source of support to computer users.  To promote membership in clubs and atç
the same time to encourage more people to take advantage of the new Z-Systemç
software, we have established a plan whereby clubs can purchase the programsç
at a discount.  It is their option how that discount is distributed.  It canç
be passed on entirely to the club members, or the club can keep at leastç
part of it to support its activities.

     The Z-Plan project was initiated by Tony Parker, who serves as aç
marketing representative for ZSA.  He uploaded a file to many bulletinç
boards describing the plan, and you may be able to find it on a system nearç
you.  ZSA had not yet been formed at that time, and the file instructs clubsç
to send the necessary registration forms to Alpha Systems.  Alpha Systemsç
has agreed that ZSA should take over responsibility for the administrationç
of this plan.

     A revised version of the Z-Plan file should be on systems by the timeç
you read this column, but if you already sent information to Alpha instead,ç
it would be a good idea to send another copy to ZSA (again, see the Sageç
Microsystems ad for the address).  More importantly, if you belong to a clubç
that has not registered, have them write to me requesting a description ofç
the plan and registration forms.


                          My New Amstrad Computer


     One of the computers on which Z-System now runs and one which exists inç
very large numbers, especially in Europe, is the Amstrad.   This CP/M-Plusç
machine -- once sold in the US by Sears, Roebuck -- uses a very unusual 3"ç
diskette (unique might be a better word for it).  We were afraid that weç
would not be able to produce Z3PLUS diskettes for this machine, so I boughtç
one second hand (just what I needed, another computer!).  Since it appearedç
that we really had to have the machine, I probably paid a good bit more thanç
it would otherwise be worth, but I must say that it has been a very pleasantç
surprise.  (On the other hand, paying close to $400 for a hundred diskettesç
was a most unpleasant surprise.)

     I expected the Amstrad to be little more than a toy.  Instead, I haveç
found it to be a very capable machine and an excellent platform on which toç
run Z-System.  The main reason for this is its very nice RAM disk.  Myç
PCW8512 (it started life as a PCW8256, but it was upgraded) has a total ofç
512K of RAM, about 350K of which is available as a RAM drive.  With ARUNZ,ç
EASE, ZFILER, all their support files, and a few other critical files on theç
RAM drive, the Z-System really zips along.

     The native (non-CP/M) mode has also proved to be quite useful.  Theç
Amstrad was largely promoted as a stand-alone wordprocessor, and itsçäLocascript wordprocessing software is actually rather nice.  Like Macintoshç
software, it is very easy to use, and my 12-year-old son has really taken toç
it in a way he never did to my super-sophisticated PMATE editor.  Theç
keyboard is set up specially for the software, and the computer includes anç
integral printer.

     That printer is, in fact, rather interesting in its own right.  To keepç
the cost down, Amstrad buys just a raw printer mechanism, and they supplyç
the software drivers to emulate an Epson FX80 in the host machine.  Theç
printer is pitifully slow, but I actually use it myself now for quickç
letters because the Amstrad is so much faster to set up than my fancyç
systems.  The printer even loads single sheets of paper automatically, andç
that's more than my (at one time) $3000 Diablo HyType-II printer can do.  Ifç
you have an Amstrad computer or know of someone who does, I would be happyç
to help them get started on Z-System.


                          Special Acknowledgments


     Before we go on to ZFILER.  I would like to acknowledge publicly someç
very special recent contributions to the development of Z-System.

     David Johnson of Sunnyvale, CA, took my ZCPR34 source code and mustç
have gone over it not only with a fine-toothed comb but with an electronç
microscope.  In programming, I always give top priority to writing code thatç
has good features and runs reliably.  Code compactness is secondary.  Thus,ç
I am never surprised when I learn that one of my routines can be improvedç
slightly.  Nevertheless, I would never have believed that the Z34 code couldç
reduced by close to a hundred bytes, but David Johnson did just that!  Evenç
Joe Wright, who is deservedly acclaimed for his coding skill, had only takenç
out 10 or 20 bytes, and he was especially impressed by David's achievements. ç
With all the new space available, I can now start to think about more newç
features!

     The second person whose contribution I want to acknowledge is Billç
Tishey of Severn, MD.  Bill has proven something I have been trying to getç
across for a long time: that you do not have to be a programmer toç
contribute in a significant way to Z-System.  Bill has sytematicallyç
compiled the documentation for the complete collection of Z-System programsç
in a set of help files that runs (uncompressed) to more than a megabyte!  Heç
has grouped the help files into libraries with names of the form
Z3HELP-n.LBR, where 'n' is the first letter of the command name.  
Z3HELP-A.LBR, for example, contains 21 files covering ARUNZ, AFIND, ALIAS,ç
and many other commands.  To my mind, this contribution is at least asç
valuable as those of program authors because it makes the programsç
accessible to the user.

  The complete set of files is posted on my Z-Node #3 and will graduallyç
make its way around the world (slowly probably, because of their size).  Inç
view of the exceptional value of Bill Tishey's help system, Sageç
Microsystems East will make it available on diskette for only $10 (SME'sçäusual copying charge is $15 to $20 per diskette).  Here are the rules.  Youç
have to send (1) preformatted diskettes clearly marked with the exact formatç
and sufficient to hold 800K of files; (2) a disk mailer for returning theç
diskettes (unless the one you sent the disks in is reusable); (3) returnç
postage; and (4) a return address sticker.  We can accept 8" SSSD IBMç
standard format (including 'flippy' diskettes) and most 5" soft-sectoredç
formats (anything on the menus of Uniform or Media Master on either theç
SB180 or an IBM AT).  Bill, himself, has an Apple and (I just spoke withç
him) is willing to make the same offer for diskettes in that format.  Hisç
address is 8335 Dubbs Drive, Severn, MD 21144.


                     ZFILER, The Point-and-Shoot Shell

     Now let's turn to the technical subject for this issue, the ZFILERç
shell.  Having written about shells so much in the past few columns, I amç
tempted to jump right into the thick of the subject.  However, judging fromç
the number of new subscriptions that SME alone takes each month, TCJ mustç
have lots of new readers with each issue.  Therefore, I will begin at theç
beginning.  Since time and energy are in short supply, however, I will notç
attempt to provide the same comprehensive documentation that I did forç
ARUNZ.  Instead, I will concentrate on the basics, on the one hand, and onç
some of the special features that many users may overlook, on the other.

Z-System Shells

     A Z-System shell is a program that takes over the user-input functionç
of the command processor.  The way this works is that the Z-Systemç
environment includes a special area in memory called the shell stack whereç
shell command lines can be kept.  Whenever the ZCPR3 command processor isç
finished processing all the commands that have been passed to it in theç
command line buffer (another special area in memory), it checks the shellç
stack.  Only if no command line is present there does the command processorç
itself prompt the user for the next command line.  If there is an entry inç
the shell stack, then that command line is run instead, and the user noç
longer sees the command processor directly.

     Some shells, like the EASE history shell, while making a big change inç
how the system is actually running, make relatively little change in how itç
appears to run.  A command prompt is still presented, and one entersç
commands more or less as usual.  The difference is that one has a moreç
capable editor at one's disposal, and the commands are saved to a historyç
file from which they can be recalled, edited, and run again.  As we shallç
see, the ZFILER shell presents the user with a dramatically different userç
interface.

What is ZFILER For?

     Historically, ZFILER is a descendant in the line of file maintenanceç
utilities like SWEEP and NSWP (hence the "filer" part of the name).  Fileç
maintenance is generally concerned with copying files, looking at theirç
contents, renaming them, erasing them, and so on.  ZFILER provides all theseçäfunctions and more.

     ZFILER's immediate parent was VFILER, where the "V" stood for video. ç
The TCAP facility in Z-System makes it easy for programs to take advantageç
of the full-screen capabilities of whatever video display terminal happensç
to be in use at any time.  In contrast to applications under CP/M, Z-Systemç
programs need not be configured to match the terminal.  It was, therefore,ç
natural to build a file maintenance program in which the files are displayedç
graphically on the screen.  When I decided to explore some new directionsç
with VFILER, to avoid confusion I gave the program the new name ZFILER, forç
Z-System Filer.

     The file maintenance tasks described above would not require a shell. ç
Making the program a shell, however, allows it to go beyond the functionsç
included in the program's own code.  Because a shell can pass command linesç
to the operating system, ZFILER can perform any operation that the computerç
is capable of.  Like a menu system, however, it helps the user by generatingç
the commands automatically at the touch of a key.

     When ZFILER is running, the screen is filled with an alphabetizedç
display of the files in a specified directory, and there is a pointer thatç
the user can manipulate using cursor control keys.  If we had a mouse toç
move the pointer, it would be a little like having a Macintosh.  Actually,ç
it would be a lot more.  It would be like having a mouse with fifty buttons! ç
Once the pointer has been positioned on a file, pressing a key (or two orç
three) causes any of a great number of functions to be invoked to act on that file.  We will describe how this works in more detail shortly.

Invoking ZFILER

     Since ZFILER performs full-screen operations, a proper Z-Systemç
terminal descriptor (TCAP) must have been loaded.  If you have not doneç
that, or if you have selected a terminal that does not support all theç
functions ZFILER needs, then ZFILER will give you an error message.  Theç
TCAP, unfortunately, does not include information about whether dim orç
reverse video is used by the terminal, and since these two modes forç
highlighting regions on the screen are so different, ZFILER is madeç
available in separate versions for each.

     There is also an option to have either four or five columns of fileç
names in the display.  Personally, I prefer the four-column version, whichç
gives an uncluttered screen with plenty of restful white space and a veryç
distinct, easy-to-spot pointer.  Others think it is more important to beç
able to see the maximum number of files on each screen and prefer the five-column display.

     Then there is the issue of support for time and date stamping of files. ç
ZFILER contains the code for preserving the time stamps when files areç
copied.  So as not to inflict the overhead of this code on those who haveç
not implemented DateStamper (though they should do that!), ZFILER is alsoç
provided in versions with and without the DateStamper code.

     If we supported all combinations of the above choices, there would beç
eight different versions of ZFILER.  Typically, the distribution libraryçäcontains four or five of the combinations.  For example, a five-column fileç
display is not particularly compatible with reverse video highlighting,ç
because the reverse video of tagged files runs into the reverse-videoç
pointer.

     When you get ZFILER, you have to choose which version you prefer,ç
extract it for the distribution library, and give it a working name (some ofç
the early Z-System shells had to have a specific name, but you can giveç
ZFILER any name you like).  I prefer the name ZF, since it is very quick andç
easy to type, and I will use that name in all the examples that follow.

     The general syntax for invoking ZFILER is

		ZF filespec

where "filespec" is a standard Z-System ambiguous file specification (thatç
is, it may contain the wildcard characters "?" and "*").  The filespecç
selects the directory area and the files from that area to be included inç
the screen display.

     Various parts of the filespec can be omitted.  If no filespec is givenç
at all, then "*.*" for the currently logged directory is assumed. ç
Similarly, if only a directory is specified (e.g., B: or 3: or B3: orç
WORK:), then all the files ("*.*") in that directory are displayed.  If aç
file name/type is included, then it will serve as a mask on the files to beç
displayed.  Thus "ZF WORK:*.DOC" will show only files of type DOC in theç
directory WORK:.

     The directory and file mask can both be changed from inside ZFILER asç
well using the "L" or LOG command.  I bring this up now because there is aç
confusing difference in the way the "L" command works.  VFILER originallyç
allowed one to change only the directory and not the file mask from insideç
the program.  To save the user the trouble of typing the colon after aç
directory, its inclusion was made optional.  Since users became soç
accustomed to this shorthand, it was carried over into ZFILER.  Because ofç
this, if you want to change only the file mask, you must remember to precedeç
it with a colon.  Otherwise your mask will be taken as the name of aç
directory (which generally results in an error message).

     One brief aside for programmer types.  ZFILER can be loaded from anyç
directory.  One of the special features of Z-System since version 3.3 of theç
command processor allows a program to find out both its own name and theç
directory from which it was actually loaded, perhaps as the result of a pathç
search.  ZFILER builds the shell stack entry to invoke ZFILER under itsç
current name from the directory in which it is actually located.  Thisç
sometimes makes it run faster, and it allows ZFILER to be invoked from aç
directory that is not on the search path.

The ZFILER Display

     The main ZFILER display contains three parts.  At the top of the screenç
there is a message line.  In the version of ZFILER that is current at theçätime I am writing this column (version 1.0L), this line contains, from leftç
to right, the following information: (1) the directory that has beenç
selected, in both DU and DIR (named directory) format; (2) the indicatorç
"[PUBLIC]" if that directory is a ZRDOS public directory (if you don't knowç
what this is, just ignore it); (3) the current time of day if DateStamper orç
one of the new DOSs (ZSDOS or ZDDOS) is running; (4) the program's officialç
name and version; (5) the text string "Current File:"; and (6) the name ofç
the file currently being pointed to (this changes as the pointer is moved).

     At the bottom of the screen is a command prompt of the form

		Command? (/=Help, X=Quit):

The cursor (don't confuse this with the file pointer) is positioned afterç
this command prompt to indicate that ZFILER is waiting for you to press aç
key.

     The center 20 lines of the screen show the selected files.  Theç
character string "-->" (only "->" in the five-column display) floats betweenç
the rows of file names and designates the so-called "pointed-to" file.  Manyç
of the ZFILER commands automatically operate on this file.

     What we have described so far is the main ZFILER screen, but it is notç
the only one.  As the command prompt suggests, pressing the slash characterç
(or "?" if you prefer) brings up a help screen that summarizes the built-inç
commands of ZFILER.  This help screen replaces the file display but leavesç
the status line at the top and the command line at the bottom, except thatç
"/=Help" changes to "/=Files".  As you might, therefore, guess, pressingç
slash again will take you back to the file display screen.

     I do not know if anyone makes use of this feature, but all ZFILERç
command operations can be invoked from the help screen.  Although you cannotç
see the file pointer, you can manipulate it in the usual way, and you canç
tell what file you are pointing to from the name displayed at the upperç
right on the status line.

ZFILER Commands

     I am not going to attempt to describe all of ZFILER's commands, but Iç
will try to list most of them.  Basically, the commands fall into severalç
classes.

     One classification reflects where the code for the command resides. ç
There are two categories:

	A. Built-In Commands
	B. Macro Commands

Class A includes the functions for which the code is part of ZFILER.  Macroç
commands are like aliases in that they generate command lines that areç
passed to the command processor for execution.  These commands make ZFILER aç
shell.  In this column I will discuss only the built-in commands, and I willçätake up the more complex subject of macro commands next time.

     A second classification depends on what the command acts on.  Threeç
categories describe the object of the commands:

	1. the pointed-to file
	2. a group of tagged files
	3. neither of the above

We will begin the discussion with commands of class A3, resident commandsç
that do not perform any action on the files.

Pointer Commands

     Class A3 includes the commands that move the file pointer.  These areç
shown on the help screen, and I will not list them here.  One can move theç
pointer to the next file on the screen or to the previous one (withç
wraparound); up, down, left, or right (with wraparound); to the first orç
last file on the current screen; or to the very first or very last file ofç
those selected by the file mask.  One can advance to the next screen ofç
files or to the previous screen.  Obviously, some of these functions will beç
redundant in some cases, such as when all the selected files can fit on oneç
screen (think what happens when there is exactly one file selected).

     ZFILER learns from the TCAP the control characters sent by any specialç
cursor keys on the keyboard (provided they send a single control characterç
and provided the TCAP has been set up correctly), and it makes them generateç
the up, down, left, and right functions.  If the cursor keys generateç
control codes normally used for another function, then that function will beç
lost (the cursor keys take precedence).  That can cause problems.  Oneç
solution is to eliminate the definition of the cursor keys in the TCAP andç
simply use the default WordStar diamond keys for those functions. ç
Alternatively, one can patch ZFILER to use different keys for its ownç
functions, but this is not straightforward to do, and I will not describe itç
here.

     The "J" (Jump) command allows you to jump to a file that you name. ç
This is very handy when there are many files in the display or when the fileç
you want is not on the current screen.  Press the "J" key, and you will beç
prompted for a file name.  You do not have to enter the exact name.  ZFILERç
automatically converts what you type into a wildcard filespec, and it findsç
the first file that matches.  For example, if you enter only "Z" followed byç
a return, this is equivalent to "Z*.*", and ZFILER will move the pointer toç
the first file that starts with a "Z".  Similarly, if you enter ".D", ZFILERç
will move to the first file with a file type that starts with "D".

     The "J" function is very handy; however, there is more.  Many peopleç
are not aware that you may press control-J to repeat the same search andç
find the next matching file.  The search will wrap around from the end ofç
the files back to the beginning.  This function is not listed on the helpç
screen because I could not find room for it.
äOther Non-File Commands

     Some other commands that do not act on files are: X, L, A, S, E, H, Z,ç
and O.  "X", as the command prompt reminds you, is used to exit from ZFILER. ç
Besides terminating the current execution of the program, it also removesç
ZFILER's entry in the shell stack (if it did not, you would just reenter itç
right away).

     We already spoke about the "L" (Log) command earlier.  The "A"ç
(Alphabetize or Arrange or Alpha sort) toggles the way in which the filesç
are sorted, namely alphabetically by the file name or by the file type.      ç
The "S" (Status) command prompts you for a disk drive letter and then tellsç
you the amount of space remaining on that disk.

     The "E" command (refresh scrEEn -- I know that's stretching things, butç
"R" was already used) redraws the screen.  You might think that this wouldç
never be needed, but there are two circumstances in which it comes in veryç
handy.  One is when ZFILER is being used on a remote system.  It is trueç
that very few RASs make ZFILER available, but I do on Z-Node #3.  If you getç
some line noise, the screen can become garbled.  Then the "E" key can beç
used to draw a fresh screen.

     The other circumstance in which the "E" command saves the day is withç
Backgrounder-ii if you do not have a screen driver (I don't for my Conceptç
108 terminal -- never got around to writing one, partly because all theç
programs I use frequently have a redraw key like this one).  I simply defineç
a BGii key macro specifying "E" as the "redraw" key, save the keyç
definitions to ZFILER.BG, and attach that definition to ZF.COM.  Thenç
whenever I swap tasks back into ZFILER, BGii simulates my pressing the "E"ç
key, and the screen is redrawn.  This often gives a faster screen refreshç
than one gets with a full-fledged screen driver.

     The "H" (Help) command generates a macro command to invoke the Z-Systemç
HELP facility.  To tell the truth, I have not used this and don't evenç
remember precisely what it does.  I would have to look at the source code.

     The "Z" (Z-system) command prompts you for a command, and whatever youç
enter is passed on to the Z-System multiple command line buffer forç
execution.  When that command line is complete, ZFILER is reinvokedç
automatically.

     When you use the "Z" command, you will normally be logged into theç
directory that is currently displayed.  However, this will not always beç
possible.  ZFILER allows you to select directories with user numbers from 0ç
to 31.  Unless you are using a version of ZCPR33 or ZCPR34 with the HIGHUSERç
option enabled, you cannot log into user areas above 15.  In that caseç
ZFILER will put you in the directory your were in when you invoked ZFILER. ç
In any case, the command prompt will indicate the directory from which yourç
command line will be executed.

     Since commands you run using the "Z" function may put some informationç
on the screen that you would not want ZFILER to obliterate immediately,çäthere is a flag set that signals ZFILER to prompt you and to wait for you toç
press a key before putting up its display.  Here is a tip for advancedç
users.  If you enter your command line with one or more leading spaces, thisç
shell-wait flag will not be set, and ZFILER will return without your havingç
to press a key.  The leading spaces are stripped from the command lineç
before it is passed to the command processor.  This means that you cannotç
use a leading space to force invocation of the extended command processorç
(ECP); you have to use the slash prefix instead.  A space and a slash willç
force invocation of the ECP and will disable the shell-wait flag.

     The final command in class A3 is the "O" (Options) command.  It is aç
complex topic, and I will leave it for next time.  If you can't wait untilç
then, experiment with it.  It should not be able to do any harm to yourç
system.

Single-File Built-In Functions

     Now let's discuss the commands in class A1, the built-in commands thatç
act on the pointed-to file.  These are invoked by pressing one of theç
following keys, whose meaning is indicated in parentheses: C (Copy), Mç
(Move), D (Delete), R (Rename), V (View), P (Print), F (File size), T (Tag),ç
and U (Untag).  Some of these are self-explanatory, and I will not discussç
them.

     The "C" command copies a file to another directory under the same name;ç
it does not allow one to give a new name for the destination file (however,ç
you can do that with a macro command).  The "M" command does not really moveç
a file; it copies the file and then, if the copy was successful, deletes theç
original file.  It is really a combination of "C" and "D".  Moving a fileç
this way is inefficient if the destination directory is on the same drive asç
the source file.  A macro command that invokes an ARUNZ alias can get aroundç
this limitation (and almost all other ZFILER limitations).

     The tag and untag commands are used to select a group of files on whichç
operations can be performed.  Tagged files are indicated in two ways.  Aç
special character ("#") is placed after the file name in the display, and,ç
if the terminal supports video highlighting, the file is highlighted.

     Two related commands are W (Wild tag) and Y (Yank back?).  "W" allowsç
you to tag or untag groups of files designated by an ambiguous file spec. ç
After tagged files are operated on by the built-in group commands describedç
below, the tag marker "#" is changed to "'" (a soft tag).  The "Y" commandç
changes the soft tags back into hard tags so that further group operationsç
can be performed on those files.

Built-In Group Commands

     Group commands are initiated by pressing the "G" (Group) key.  Theç
command prompt at the bottom of the screen changes to

	Command? (/=Help, X=Quit)  Group: (A,C,D,F,M,P,R,T,U,V)
äFor now we will consider only the built-in group functions (class A2) andç
will take up group macro commands (class B2) next time.

     Except for the four functions described below, the letters invoke theç
same action as the individual command corresponding to that letter, but theç
function is performed on all the tagged files.  We will not discuss thoseç
further.  Note in particular that the keys "A" and "R", however, have aç
group function that is completely different from the individual function.

     The "U" and "T" group functions do not act on the tagged files; theyç
change the tagging.  The former untags all files; the latter tags them all.

     The "R" group function is another one that does not, strictly speaking,ç
act on the tagged files.  It reverses the tags, tagging the files that hadç
been untagged and untagging the ones that had been tagged.  This can be veryç
handy in several circumstances.  For example, you might want to copy all theç
files except two.  It is easier to tag those two and then to reverse theç
tags.  As another example, you might want to copy some of the displayedç
files to one diskette and the others to a second diskette.  I do thisç
frequently.  I begin by tagging the ones to go to the first diskette.  Thenç
I group copy ("GC") them to the destination diskette.  Next, I yank back theç
tags using the "Y" command and then reverse the tags with "GR".  Now I canç
group copy the rest to the second diskette.

     The "A" (Archive) group command is very handy for automating backups. ç
When it is entered, the tags are removed from any tagged file whose archiveç
flag is set.  As a result, only files that have been modified since the flagç
was last set will remain tagged.  In addition, the "A" group commandç
automatically initiates a group copy operation but with one special feature. ç
After the file has been copied successfully, the archive flag on the sourceç
file is set to indicate that the file has been backed up.

     Under later versions of VFILER, the group "A" command automaticallyç
tagged all unarchived files; under ZFILER it untags the archived ones.  Thisç
difference is very important.  With VFILER, you were forced to back up allç
the files selected by the VFILER file mask.  Under ZFILER you can select theç
files that will be candidates for backing up.  If you want the achieve theç
same function as under VFILER, just tag all the files first with "GT" andç
then archive them with "GA".  On the other hand, if you want to exlude BAKç
files from the backup, you can "GT" all files, untag the "*.BAK" files usingç
the "W" command, and then use the "GA" command.

     After you enter the command "GA", you will be prompted for aç
destination directory.  You do not have to supply one!  If you simply enterç
a carriage return, the copy operation will be skipped, and you will be leftç
with tags on the files that need to be backed up.  You can then use a macroç
function to back them up in a specialized way, such as crunchingç
(compressing) them to the backup disk (instead of copying them as they are)ç
or putting them into a library on the backup diskette.  Next time we willç
discuss the macro techniques required to do this.

[This article was originally published in issue 36 of The Computer Journal,äP.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1989, 1991 Socrates Press and respective authors]
