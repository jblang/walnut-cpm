TCJ #44

                            The Z-System Corner

                                  Jay Sage


   For this issue (and the next) I am going to indulge myself and writeç
about about something that I enjoy, even though, strictly speaking, it hasç
nothing to do with Z-System.  This subject is MEX-Plus, the most advancedç
telecommunications package available for CP/M computers.  I suppose I couldç
argue that there is a philosophical or spiritual connection, since MEX-Plusç
allows the user do for telecommunications many of the same things that Z≠
System allows one to do with the operating system, namely automate.  Inç
particular, I will be describing MEX-Plus's scripting capabilities, whichç
are similar in some ways to alias and ARUNZ scripts in Z-System.

   I had been hoping that a regular MEX column would develop here in TCJ,ç
but that hasn't happened.  Two of the people who might have gotten it going,ç
Bruce Morgen and Rick Charnes, are now employed in the MS-DOS industry, and,ç
after programming all day professionally, they don't seem to have as muchç
energy left for hobby computing as they used to.  Recently, Davidç
Goodenough, author of the QTERM telecommunications package, came over to myç
house and got QTERM running on my SB180 with its Wyse 50 terminal.  I amç
enormously impressed with what David has accomplished with this program; itç
is rapidly developing many of the capabilities of MEX-Plus.  I can envisionç
much discussion in the future of both MEX-Plus and QTERM scripts.  You canç
also expect an article or two about QTERM.

   For this column I will give an overview of MEX's command structure, andç
next time I will describe in detail my suite of scripts for using PC-Pursuitç
as an example of what can be done using those commands.  (I originallyç
planned to cover both in one article, but after finishing the description ofç
the commands, I was already at my limit.)  Along the way I will try to pointç
out some of the bugs and idiosyncrasies that users have discovered in MEXç
commands and suggest means to get around them.  I hope that my examples willç
help give others ideas about how to make better use of MEX-Plus.  Althoughç
regrettably I have had very few takers in the past, I again extend anç
invitation to readers to send me suggestions and examples for scripts.


                         Overview of MEX Commands


   The original CP/M telecommunication program MODEM7 and its derivatives,ç
such as IMP, operate in two modes: terminal mode and command mode.  Terminalç
mode is used for talking to the remote system, while command mode is used toç
control the local system.  These programs have a relatively small set ofç
commands falling principally into two classes: those required for fileç
transfers and those related to the setup of the program.

   In MEX-Plus the arsenal of commands is extended enormously, and anythingç
that could be done from terminal mode can be done from command mode as well. ç
(You would not want to run an interactive session this way, but it could beç
done.)  There are so many commands that, though I will mention almost all ofç
them, I will not be able to explain them all in detail.  Rather, I hope toç
give you a general picture of the kinds of tools one has to work with inç
MEX-Plus.  I will take up the commands in groups.


Setup Commands
--------------

   Most of MEX's configuration is controlled by three commands: STAT, SET,ç
and TSET.  The STAT command works with more than 50 different options!  Allç
of them can display information about how the system is configured, and allç
but a few also allow the configuration to be changed.  The MEX STATç
parameters fall into four classes: switches, characters, values, andç
miscellaneous.

   Switches have values of ON or OFF.  One example is FILTER, which controlsç
whether MEX will filter from the incoming modem stream any controlç
characters other than tab, backspace, carriage return, and linefeed.  If oneç
wants to perform full screen operations, this filter must be off. ç
Otherwise, the escape characters that initiate a screen control sequenceç
will be swallowed by MEX.

   Character STAT parameters take a single ASCII character as their value. ç
An example is SEP, the multiple command separator (like Z-System, MEX-Plusç
allows multiple commands on a line).  Value parameters take on numericalç
values.  For example, PAGE sets the number of lines in a page on the screen,ç
and CLOCK is set to the clock speed of your microprocessor chip so thatç
timing delays will come out right.  The miscellaneous STAT parameters mostlyç
control the display of groups of information.  "STAT ?" lists all the STATç
parameters; "STAT VAL" shows the value parameters.

   The SET command controls the modem setup.  It is used for setting theç
baud rate, word length, number of stop bits, and parity mode.  The TSETç
command was one I never used until working on this article.  It controlsç
special features related to the terminal (what is does depends on theç
terminal you are using).  With my Wyse 50, a TSET parameter can force allç
characters to be displayed in upper case characters or in highlighted videoç
(that should give you some idea of why I have never used this command).


Operating System Commands
-------------------------

   Another group of commands deals with the interface to the operatingç
system.

   Naturally, there has to be a way to get out of MEX and back to theç
operating system prompt.  Have you ever been trapped inside a program, notç
knowing how to exit?  Well, MEX author Ron Fowler must have had such aç
harrowing experience, because he has six (count 'em!) commands for gettingç
out: BYE, EXIT, QUIT, CPM, DOS, and SYSTEM.  SYSTEM must come from BASIC,ç
which is the only CP/M program I ever became trapped inside.  MEX-Plus isç
available in an MS-DOS version as well, and that is where the exit commandç
DOS comes from.  As a CP/M diehard, I take great pleasure, as you canç
imagine, in exiting from my DOS version using the command CPM (it doesn'tç
help -- I'm still in MS-DOS after I exit).

   There are commands for doing operating system chores: DIR, REN, ERA (or,ç
following MS-DOS, DEL), TYPE, and LOG (change drive/user).  Some of theseç
commands not only perform their functions; they also return information forç
use in a script file.  DIR, for example, sets a special variable to theç
number of matching files found, and thus can be used to determine whether aç
particular file exists or not.

   There are the commands KEY for associating strings with any ASCII key onç
the keyboard and PHONE for entering phone numbers into a dialing library. ç
The key definitions and phone number library can be stored in disk filesç
with the respective extensions KEY and PHN.  The commands SAVE and LOADç
write the data to and read the data from the files.

   MEX-Plus has a facility, via the INSTALL command, to load optional extraç
code modules.  One such module (the REMOTE module) allows MEX-Plus to beç
operated as a remote access system.  I have used this with both direct wireç
and modem connections between machines.  The former is handy when twoç
machines are connected by a cable, as it relieves one of the need to runç
back and forth between the two keyboards to issue file transfer commands.  Iç
sometimes leave my system at work in remote mode so that I can call it fromç
home to pick up a file that I forgot to take with me.  Other optionalç
modules support emulation of various terminals, including the VT100.

   The TERM and TERMA commands open a file to record the incoming characterç
stream from the modem.  TERM creates a new file, while TERMA appends the newç
text to an existing file.  The terminal mode commands T, L, and E describedç
below can also take an optional 'A' suffix and capture file name.  In thoseç
cases, once the capture file has been opened, MEX is put into terminal mode. ç
The TERM and TERMA commands leave MEX in command mode for further scriptç
processing.  The VIEW command allows the contents of the capture file to beç
reviewed while online, thereby affording some scroll-back capability (thatç
is, a way to see text that has already scrolled off the screen).  WRT closesç
the capture file (saves it) when you are done; DEL discards it.

   The ALT command specifies an alternate drive/user area (in addition toç
the currently logged one) where MEX can search automatically for filesç
(e.g., scripts, phone directory, etc.).  The SEARCH command tells MEX how toç
go about searching for files, such as whether to search the alternate areaç
before or after the logged area.

   As you can probably guess already, it is not easy to remember all theseç
commands and the syntax they require.  That is where the HELP command comesç
in handy.  It accesses an extensive HLP file (over 70K).  There is also theç
wonderful CLONE command, which creates a new version of MEX (i.e., a new COMç
file) with the current configuration embedded -- after the STAT, SET, TSET,ç
and other commands have been used to change parameters to one's liking.


Telephone Interface Commands
----------------------------

   MEX-Plus has two phone-dialing commands, CALL and DIAL.  Both acceptç
lists of either literal telephone numbers or names from the phone library. ç
Numbers and names may be mixed.  Numbers in the library may have associatedç
baud rates, which will be selected automatically when that number is dialed. ç
An optional parameter specifies the number of times to try connecting to theç
numbers before giving up, and the commands return a value to indicate whichç
number, if any, was reached.  Here is an example:

                CALL LADERA 617-965-7259 #3

This will alternately called the Ladera Z-Node (whose number is in theç
library) and my Z-Node up to three times before giving up.  The commandsç
differ in that CALL puts one in terminal mode after a successful connection,ç
while DIAL leaves one in command mode for further script processing.

   There is also a way to get out of a connection.  DSC will tell the modemç
to drop the connection.  It can be configured (using a STAT command, ofç
course) to use either the DTR (data terminal ready) hardware control line orç
the Hayes AT hangup command.


Terminal Commands
-----------------

   There are three commands for entering terminal mode.  The command Tç
(terminal) sets up a full-duplex terminal mode.  Characters typed at theç
keyboard are sent to the modem; characters received from the modem are sentç
to the screen.  If you are to see what you are typing, the remote systemç
must echo back the characters it receives from you.  Most microcomputer BBSç
systems do that.

   The L (local echo) command sets up a half-duplex terminal mode.  Theç
difference is that the characters that you type are not only sent to theç
modem for transmission to the remote system; they are also echoed locally. ç
This mode would be used with systems like GEnie that do not normally echoç
the characters they receive from you.

   Finally, the E (echo) command sets you up as if you were a remote host. ç
Every character you receive is then echoed back to the modem.  If two peopleç
running MEX call each other (or two machines are hooked up by cable as Iç
mentioned earlier), either both should be in L mode, or one should be in Tç
mode and the other in E mode.  I prefer the latter, since seeing theç
characters on the screen of the machine in T mode assures that theç
connection is working.  I leave it as an exercise to the reader to figureç
out what will happen if both machines are in E mode.  (Hint: feel free toç
experiment; you can get out of the infinite loop by exiting from terminalç
mode; you don't have to reboot.)


File Transfer Commands
----------------------

   Files are sent to the other computer using the S command, and receivedç
from the other computer using the R command.  MEX-Plus supports three fileç
transfer protocols: KERMIT, XMODEM, and YMODEM.  The default protocol is setç
with the PROTO command.  The protocol can also be specified explicitly usingç
a prefix (K, M, or Y) to the S or R command.

   The commands will also accept any of several suffixes as well.  Theç
suffix B indicates a batch-mode transfer.  The K suffix with the S commandç
indicates that the file should be sent in blocks of 1K bytes instead of theç
standard 128 bytes.  If you append T, L, or E, you will return to theç
corresponding terminal mode after the transfer is completed.  The D and Xç
suffixes will tell MEX to disconnect from the remote system after theç
transfer is finished; with D you will return to MEX, while with X you willç
exit MEX as well.  Here is an example.

                YSBKX FILE1 FILE2 FILE3

This will send the three files using YMODEM batch with 1K blocks, hang upç
the phone, and exit from MEX.

   Transactions with a host in the KERMIT server mode are supported with aç
number of special commands (KGET, KPUT, KBYE, KLOG, KFIN).


Video Commands
--------------

   These are the commands that Rick Charnes loves so!  There are commandsç
for cursor addressing (@), beginning and ending the use of up to four videoç
attributes (START and END), displaying special line-drawing graphicsç
characters (DRAW), and creating lines and boxes (HLINE, VLINE, BOX).  Theç
screen can be cleared (CLS).  It can also be turned on and off (SCREEN) soç
you can control what output is seen and what is not.


Variables
---------

   It is hard to do very sophisticated processing without variables.  MEX≠
Plus offers variables of two types: numerical and string.  The former areç
16-bit integers (i.e., numbers from 0 to 65535); the latter are strings ofç
up to 32 characters.

   There are 26 numerical user variables designated by a percent signç
followed by a letter (case does not matter, e.g., %a or %S).  There are sixç
string variables designated by the letters A through F.  I've never run outç
of numerical variables, but I sure wish there were more string variables.

   There are also two special numerical variables called VALUE and STACK. ç
The former is used to hold the value returned from a number of MEX commandsç
(DIR and DIAL/CALL were mentioned earlier).  STACK is a more long-livedç
variable that can be exchanged in various ways with VALUE (the commandsç
PUSH, POP, and XCHG).  I think these are left over from earlier versions ofç
MEX that did not offer the 26 user variables.  There is little reason to useç
STACK any more.  There are three special operations (ADD, SUB, and XOR) thatç
can be performed on the VALUE variable.  I've never found any use for these,ç
either.

   MEX can evaluate arithmetic expressions consisting of combinations ofç
literal numbers, numerical variables, and arithmetic operators (+-*/).  Hereç
is an example that returns the least significant byte of the two-byteç
variable %V:

                %V - 256 * ( %V / 256 )

Numbers can be entered in hexadecimal format by prefixing the number with aç
dollar sign ($100 is 256).

   The value of an expression is assigned to a variable by the equalç
operator (=) as in %B=%A+3.  NOTE: in most places in MEX-Plus, extra spacesç
may be included in command expressions.  However, there are unfortunately aç
number of bugs in MEX-Plus, and some rear their heads in this area. ç
Therefore, I recommend that extra spaces be omitted in working scripts (asç
opposed to fully commented reference versions, where extra spaces might beç
included to improve readability).

   Literal string expressions are composed by surrounding text with double≠
quote characters (").  The MEX manual says that values are assigned toç
string variables using the STORE command as in:

             STORE "this is a test" TO A.

Experiment shows that the following simpler, undocumented syntax also works:ç
A="test".  Here I know from bitter experience that there should be no extraç
spaces around the equal sign.  It often works, but not always.  Mostç
commands that accept quoted literal strings will also accept stringç
variables (e.g., B=A or COMP A "yes").

   Command line parameters are also available to scripts; they are passed inç
the form of variables represented by the numbers 1 through 9 surrounded byç
curly braces.  These variables can always act as strings.  If they express aç
number, they can also be used as numerical expressions.  Thus, we might haveç
A="{1}" or %A={1}.  The latter expression will produce an error if the firstç
command line token does not represent a number.

   If the script invocation command line does not have a token referenced byç
an expression of the form {1}, {2}, etc., the script will bomb with an errorç
message.  The expression {n:default) allows a default value to be used forç
parameter 'n' if none is given on the command line.  This default value canç
be null, as in {1:}.

   String variables can, like the command line tokens, be represented inç
expressions by curly braces around the letter (e.g., {B}).  In such a case,ç
the value of the expression is the string of characters alone, and doubleç
quote characters must surround the expression in most situations.  There areç
exceptions.  The SAY and SENDOUT commands (described in the next section)ç
can be used directly with a variable, as in SAY A.  The following twoç
commands are equivalent:

                SAY "Variable A has the value: ",A,"/n"
                SAY "Variable A has the value: {A}/n"

   The curly-brace expressions can be used to concatenate text, as in

                A="{B} and {C}"

Expressions of this type are not documented and work only in script files;ç
they will not work if entered directly at the MEX command prompt.  Similarç
expressions can also be used to finesse variables into commands thatç
normally do not take them.  Here are some examples:

                set baud {b}       (where, say, B="1200")
                set baud {c}00     (where, say, C="24")
                goto {1}           (where, say, token 1 is LOOP)
                {a}                (where, say, A="set baud 1200")

   I have not figured out how to split a string variable into parts (such asç
words).  I also had never been able to figure out a way to convert aç
numerical variable into a string.  I still can't do it directly (things likeç
B={%B} do not work), but the script in Fig. 1 does it indirectly (inventionsç
like this are part of the fun of writing this column).  You may not be ableç
to fully understand that script until you have read through the rest of theç
command descriptions.

-----------------------------------------------------------------------------

B=""                    initialize to null string
%y=%b                   set up scratch variable %y

LABEL LOOP              loop
%x=%y-10*(%y/10)        get the lowest digit ( %y MOD 10 )
if %x=0 B="0{B}"        preconcatenate the appropriate digit
if %x=1 B="1{B}"
if %x=2 B="2{B}"
if %x=3 B="3{B}"
if %x=4 B="4{B}"
if %x=5 B="5{B}"
if %x=6 B="6{B}"
if %x=7 B="7{B}"
if %x=8 B="8{B}"
if %x=9 B="9{B}"
%y=%y/10                divide number by 10
if %y>0 GOTO LOOP       continue until number is reduced to 0

Figure 1.  Commented listing of a script that will convert the numericalç
variable %B into string form in string variable B, from which it can be usedç
in various commands, such as: SET BAUD {B}.  This code could be made into aç
subroutine by adding the command PROC NUM2STR at the beginning and ENDP atç
the end.  If you try this script, do not enter the comments, of course.

-----------------------------------------------------------------------------


Input/Output Commands
---------------------

   Programs generally are not terribly useful if there is no way to get dataç
in or out.  Here is what MEX-Plus offers.

   The SAY command allows one to send characters to the screen.  It acceptsç
arguments of literal strings, string variables, and numerical expressions,ç
as in

                SAY "The sum is",%A+%B,"/n"

There are special character codes, such as "/n" (newline) or "/r" (return). ç
Combined with the video commands mentioned earlier, the SAY command canç
produce some pretty fancy displays.

   There is also the undocumented PRINT command that does almost exactlyç
what SAY does, except that it does not need quotation marks around theç
literal text and does not interpret any special expressions.  To PRINT,ç
everything is a pure string.  There are, thus, a couple of things PRINT canç
do that SAY cannot.  Here are some examples:

                PRINT Please enter "Hello" at the prompt.
		PRINT Use the expression {1} for a token.

In the first case, PRINT allows one to send a double quote character to theç
screen.  In the second case, a string that would be a variable expressionç
can be displayed.

   The SENDOUT command is used to send literal text or the contents ofç
string variables to the modem.  The PREFIX and SUFFIX commands can be usedç
to define strings that are automatically sent before and after theç
designated text to save one the trouble of having to include certainç
characters (such as, perhaps, a carriage return and linefeed) explicitlyç
with each string.  Longer, fixed strings can be sent using the TRANSMITç
command, which sends the contents of a file just as if you were typing it inç
terminal mode.  A pair of delay constants controls the speed with which thisç
"automatic typist" performs.

   The INPUT command allows interactive entry of the value for a numericalç
variable; ACCEPT does the same thing for a string variable.  The TIME andç
DATE commands allow one to access a real-time clock.  Besides displaying theç
information on the screen, the commands are supposed to put theç
corresponding data into the VALUE variable.  There is a bug here, and theç
time value is used by both commands.  There appears to be no way toç
determine the date from within a script.  The PEEK and POKE commands allowç
one to look at and modify memory for the ultimate in hacking from a script! ç
(That probably means that there would be a way to find the date if oneç
really needed it badly.  It also means that the complete Z-Systemç
environment can be accessed.)


Flow Control Commands
---------------------

   Like Z-System, MEX-Plus has flow control commands to allow a script toç
perform tests and to act differently depending on the results.  There is theç
standard set of flow commands IF, ELSE, and ENDIF.  They support 8 levels ofç
nesting (just like Z-System).  Here is an example:

                IF %B=1200
                  B="1200"
                ELSE
                  B="2400"
                ENDIF

   Additionally, there is a single-line IF command.  It is distinguishedç
from the multiple-line IF by a command (a 'then' clause) that is part of theç
IF statement.  Here is an example:

                IF %B=2400 B="2400";SAY "2400 bps";GOTO CONTINUE

With the single-line IF, when the test fails, the entire line is ignored. ç
Please note that had there been a semicolon after the "IF %B=2400", thenç
this would have been a multiple-line IF (albeit with several of its 'lines'ç
on one line).

   The single-line IF command comes in especially handy, because it isç
generally awkward to perform a GOTO jump out of an IF/ELSE/ENDIF block. ç
Although the manual warns against it, there is (I'm pretty sure) no harm perç
se in doing it.  It is just that you have to make sure that the ENDIF is notç
skipped lest you get nested deeper and deeper.  As with Z-System, you haveç
to make sure the IFs get terminated; unfortunately, this is not so easy,ç
because, unlike Z-System, MEX-Plus has no XIF or ZIF command.  Here is aç
very convoluted example of a way in which it could be done:

                if %b
                  say "TRUE/n"
                  goto cont
                endif
                .
                say "FALSE/n"
                goto done
                .
                label cont
                endif
                .
                label done
                say "Now we are done/n"

   There is also a SKIPIF command.  If its test is true, then the nextç
command is skipped.  Note well that while the IF command may skip an entireç
line of commands, SKIPIF skips only one command, no matter how many commandsç
may appear on the same line.


Numerical Tests
---------------

   Flow control would not be very useful without ways to test things.  Firstç
we will consider tests on numbers.

   Test results are expressed numerically, with 0 representing false andç
non-zero (usually 1) representing true.  You can see this for yourself byç
entering the command "SAY 1<2" or "SAY 1>2".  The following logicalç
operators can be used for comparisons: equals (=), not equals (<>), lessç
than (<), less than or equal to (<= or =<), greater than (>), or greaterç
than or equal to (>= or =>).  Note that the MEX manual has a misprint in oneç
place and gives the not-equal-to operator as '!'.  That is incorrect andç
will not work.

   Although comparison tests return a numerical value, those values for someç
reason cannot be used in arithmetic expressions.  In other words, you can'tç
have (%A>%B)*(%A<%C).  As far as I can tell, this means that you cannotç
perform compound tests, such as "IF %A>%B AND %A<%C".  Performing suchç
compound tests is made more difficult by the fact that the 'then' clause ofç
a single-line IF cannot be another IF.  If you won't be using GOTO, nestedç
multi-line IF commands will do the trick.  Otherwise, you might have toç
resort to some explicit arithmetic as in the following:

                %z=1
                if %a<=%b then %z=0
                if %a>=%c then %z=0  
                if %z then ....

We started out assuming TRUE (%z=1).  Then if either condition was false, weç
set %z to false.

   Before we leave this topic (I know we've been here a long time), I haveç
to mention that MEX has a bug that causes it to issue fallacious but veryç
annoying error reports when comparison operations are performed withç
numerical variables having particular values.  I have carried out a numberç
of experiments to try to determine the exact circumstances under which thisç
problem occurs, but so far I cannot fathom a pattern.  The trouble oftenç
appears, however, with comparisons to standard data rate values, such asç
300.  To get around the problem, I sometimes divide the variable by 100,ç
compare it to 3, 12, or 24, and then multiply it by 100 to restore itsç
original value.  What a pain!


String Tests
------------

   Strings are compared using the COMP command.  It accepts two strings,ç
each of which can be either a literal string or a string variable.  Theç
result of the comparison is returned in the VALUE variable, which can thenç
be tested for a value of 0 or 1.  The STAT CASE setting determines whetherç
the comparison will be case sensitive or not.  There is a bug with the COMPç
command; it will not give the answer 1 (true) when both strings are nullç
(""), though it will work if only one string is null.  If you want to see ifç
a command line token was given, you can use the following tests:

                COMP "{1:} " " "
                COMP "{1:}X" "X"

An extra character (space or 'X') is concatenated to the string representedç
by {1:}.  You might also use

                COMP "{1:null}" "null"

Here, the first parameter cannot be null.  If token 1 is not given, theç
default value "null" will be used instead.  Of course, if the user entersç
"null", the same result will be obtained.  The two earlier examples are,ç
thus, more robust.

   There is one oddball command that I don't know where to put: SLEEP.  Itç
is sort of a flow control command, so I'll stick it here.  It just tells theç
system to go to sleep (pause) for a designated time interval.


Program Control Commands
------------------------

   MEX-Plus supports several script program structures.  The main unit of aç
script program is a script file, which has a file extension of MEX.  It canç
be invoked as a main program by the READ command.  It can also be invoked asç
a subprogram by the DO command, which allows scripts to be nested.  I do notç
know how deep this nesting can be, but I just tested it to five levels.  Theç
STOP command is used to exit from a READ or DO command.  In the former case,ç
control returns to the MEX program (possibly in terminal mode); in theç
latter, control returns to the script that called the current script.  Aç
script also terminates automatically at the end-of-file.  The STOP commandç
unfortunately displays an annoying message about the script being aborted. ç
To exit gracefully, it is better to put a label at the end (e.g., LABEL END)ç
and to exit using GOTO END.

   A READ command may be given inside a script.  In this case, control isç
transferred to the new script, which overwrites the old script in memory. ç
With the DO command, the new script lines are read into memory along withç
the currently running script.

   I always enjoy writing these columns because I end up asking some newç
questions and learning some new answers.  Just now, to see how MEX works, Iç
was examining the memory image after a MEX script file ran.  First, Iç
learned that the script text is stored backwards in memory starting fromç
near the top.  I verified that after each DO is finished, the memory isç
reclaimed and is available for use by another subroutine script.  I alsoç
discovered that the entire script file, including all comments, is read intoç
memory.

   We can draw some important conclusions from these observations about howç
complex scripts should be implemented.  First, there are several advantagesç
to using versions of script files from which comments have been stripped. ç
The files will, of course, load faster, and there will also be more room inç
memory for such things as file transfer buffers.  Many MEX users have runç
into problems of insufficient memory while running complex scripts.  Second,ç
it is a good idea to chain from one script to another rather than buildingç
everything into a single script.  In my PC-Pursuit script, I chain to a veryç
small script just after the remote system has been reached and the script isç
about to put me into terminal mode.

   Structure is permitted within an individual script file as well in theç
form of internal subroutines.  Subroutines begin with a PROC (procedure)ç
command and end with an ENDP (end-procedure) command.  They are invoked byç
the GOSUB command.  Again, I do not know how deeply they may be nested, butç
I just tested them to 9 levels.

   Script files may also contain unstructured program groupings (thatç
anathema to modern structured programming).  The LABEL command allows anyç
point in the script to be given a name, and the GOTO command allows a branchç
to that point.  The manual indicates that the name may have up to 16ç
alphabetic characters and warns that the line with the LABEL command may notç
have any other commands on the line.  I know that I have run afoul of thatç
restriction in the past, but, oddly enough, in my testing now I was totallyç
unable to generate a problem.  I tried everything I could think of: anç
immediate semicolon, a semicolon after a space or a tab, tabs after theç
semicolon.  They all worked just fine (how could MEX tell that this was justç
a test?).

   The manual is clearly wrong when it says that only alphabetic charactersç
can be used.  I assumed that it really meant alphanumeric, but in myç
experiments I learned that absolutely any characters can be used, includingç
spaces!  Here are the rules that emerged from my testing.  First, all spacesç
and tabs after the LABEL command are ignored.  That point marks theç
beginning of the name.  Next one starts from the end of the line or theç
command separator character and strips all tabs and spaces backward.  Thatç
point marks the end of the name.  What is between those marks is taken asç
the label.  For example, one can have a label of "ENTRY 1" (with theç
embedded space and with or without the quote characters, in fact).  Mindç
you, I am not by any means suggesting that you use such labels.  As Iç
mentioned before, I have not always found MEX to behave exactly the way itç
did in these experiments.  If anyone can figure this out more precisely, Iç
would really like to hear about it.

   The other thing I learned from these experiments is that MEX always scansç
for a label from the beginning of the script.  This means that if you useç
the same label a second time, the second occurrence will never be found.


                            One Script Example

   I just don't feel right about presenting all this information about MEX≠
Plus commands without showing at least one real-life example.  Figure 2ç
shows the final script in my PC-Pursuit script suite.  Once I haveç
successfully connected to the outdial city and reached the remote systemç
there, I chain to this script.  Let's look at it line by line.

   The first line begins with a period, so it is a comment.  I alwaysç
include a title line and often add some description of the function of theç
script and the parameters it takes.

   The real work of the script begins at line 3.  In many parts of theç
script, I do not want the output from commands to show on the screen.  Now Iç
do, so I issue the "SCREEN ON" command.  I'd also like to start with a cleanç
screen, so I issue CLS, too.

   In line 5, the script tells the user the name of the system that has beenç
reached (that was previously stored in string variable F) and at what baudç
rate (previously stored in string variable B).  Then the script drops oneç
into terminal mode, where one can work interactively as long as one likes.

   When terminal mode is exited (by pressing <ESC> E), the script resumes atç
the label LOOP.  Line 9 prompts the user to enter a command.  If the userç
enters "M", then the main menu script is run, allowing one to call anotherç
system in another or the same city.  Line 10 accepts the answer from theç
user and places it into string variable A.

   In line 11, the user's answer is compared to the string "M".  If it wasç
"M", then the variable VALUE will have the value 1 (true), and line 12 willç
cause the script to chain to the script file PCPMENU.MEX.  If the userç
entered anything other than "M", then execution will continue at line 13,ç
where the user's command is executed.  When that command has completed,ç
control will return to line 14, which branches back to label LOOP and aç
prompt for another command.

   The user's command can be just about anything.  For example, if it isç
"T", then MEX will enter terminal mode for more interactive work.  The oneç
restriction I have found, is that only a single command can be entered.  Aç
multiple command line, with commands separated by semicolons (or whateverç
the designated SEP character is), does not work for reasons I do not yetç
understand.  Maybe I will have figured it out (or one of you will have) byç
next time, when I will cover the real guts of the PC-Pursuit script.

-----------------------------------------------------------------------------

01  .. PCPCONN SCRIPT -- Connected to Destination System
02  
03  screen on
04  cls
05  say "Connected to ",F," at ",B,"00 bps/n/n"
06  t
07  
08  LABEL LOOP
09  say "/nEnter single MEX command (or M for menu): "
10  accept A
11  comp A "M"
12  if value=1 READ PCPMENU
13  {A}
14  GOTO LOOP

Figure 2.  This is the final script in my PC-Pursuit suite.  Just afterç
connecting to a remote system, I chain to this script to free up as muchç
memory as possible for other uses, such as capture buffers and/or fileç
transfer buffers.  Line numbers have been added for reference purposes inç
the text.

              