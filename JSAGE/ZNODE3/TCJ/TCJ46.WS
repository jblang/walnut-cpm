R65
TCJ46.WS

                      The ZMATE Text Editor

                            Jay Sage


   Although I have not yet finished the treatment of MEX, I amç
going to start a new subject this time: the ZMATE macro textç
editor.  During the past two months I have been working on aç
number of code patches to MEX-Plus to fix some problems and toç
add some new features that I wanted or needed.  That work is notç
complete, so I have decided to hold off on a MEX update untilç
next time.  As usual, I do have a few miscellaneous items toç
bring to your attention.


                         Pieces of Eight

   First, I would like to put in a plug for the "Pieces of Eight"ç
magazine (POE) from the Connecticut CP/M Users' Group (CCP/M). ç
CCP/M recently decided to begin addressing a national audienceç
and not just their local members.  Even if you cannot attendç
their meetings, the subscription to POE that your $15 annual duesç
brings you is alone worth the price.

   POE is a very nice complement to TCJ.  I don't think I willç
offend CCP/M by saying that their magazine is far less seriousç
than this one.  There is some solid technical content, but theç
emphasis is definitely on the human side of computing.  It isç
really fun to read, and not just by us computer nuts but by ourç
entire families as well.

   The July, 1990, issue has a feature article on the Trentonç
Computer Festival held in April.  On the cover is a picture takenç
there showing me, Bridger Mitchell, Al Hawley, and Cam Cotrill. ç
(In case you might be questioning my motives, their flattering meç
by putting my picture on the cover provided only a fraction ofç
the inspiration for this plug!)

   Inside are more pictures: Rob Friefeld (LSH, SALIAS), Carsonç
Wilson (ZDE, ZSDOS), Hal Bower (ZSDOS), Bruce Morgen (MEX+2Z andç
lots of program patches), Howard Goldstein (our alpha tester andç
bug catcher and fixer extraordinaire), and quite a few others. ç
As you can see, Trenton drew Z-Team members and enthusiasts fromç
all over the country!  If you want to learn more about theç
festival, sign up for POE.  Send dues to Tom Veile, 26 Slaterç
Ave., Norwich, CT 06360.


                    A Patch for The Word Plus


   Some time ago I published here a set of ARUNZ aliases forç
automating the use of The Word Plus spell checker.  Well, Richardç
Swift liked them just fine, but it then annoyed him that he stillç
had to hit a carriage return to get past TW's prompt aboutç
whether the configuration was correct.  He wanted TW to get rightç
to work.

   At first I didn't really see why he was making such a fussç
about such a little thing.  Then it began to eat at me, too. ç
This one little thing was standing in the way of completeç
automation.

   Well, it took a good bit of poking around in the TW.COM code,ç
but in the end it was quite easy to patch around this annoyingç
prompt.  First I located where the code that put up the promptç
began, and then I found where things picked up again after it.  Aç
simple jump instruction at the beginning to skip over it shouldç
do the trick, I thought.

   Unfortunately, it was not quite that simple.  As Bruce Morgenç
had described earlier in an issue of his NAOG newsletter, theç
programs in The Word Plus suite perform some simple internalç
checking to make sure the file is not corrupted and has loadedç
successfully.  Nice of those folks, but after I put in my patch,ç
the code looked corrupted.  I could have figured out the newç
checksum value and stuck it into the testing code, but it wasç
easier just to bypass the checking entirely.

   At first I put the changes into a patch file that would beç
overlaid onto the original code.  Then, however, I decided thatç
there was no real need to make the change permanently.  Whenç
running TW manually, one would probably want the prompt to appearç
so that one would have the option of changing the setup.  So, myç
solution was the old GET/POKE/GO technique introduced by Bruceç
Morgen (boy does that name keep coming up!).

   My original ARUNZ alias had a command of the form

	tw:tw <file> <dictionary>

I just replaced that by

	/TWPAT <file> <dictionary>

and wrote the new alias TWPAT with the command lines

	get 100 tw:tw.com	load TW.COM
	poke 103 c3 3b 01	patch to jump over code test
	poke 395 c3 2a 04	patch to jump over prompt
	go $*			run the patched code

Now I could invoke the patched TW whenever I wanted by using theç
command TWPAT instead.


                      The ZMATE Text Editor


   Now for the main topic of this column, the first in a seriesç
of articles on ZMATE.  This one will be just an introduction andç
will cover only its design philosophy and mode of operation. ç
Next time I will start to describe its language in detail.


Interpreters and Compilers

   A casual user would classify ZMATE as an application program,ç
and more precisely as a text editor or wordprocessor.  In itsç
soul, however, it is really a high-level programming language. ç
In some ways it is similar to the familiar BASIC interpreter.

   Like almost all the programming languages most people workç
with, BASIC is oriented toward numerical computation.  Forç
example, at the system prompt one can enter a command such as

	print ( n1 + n2 ) * n3

BASIC will then retrieve the values associated with the variablesç
N1, N2, and N3, substitute them into the mathematical expression,ç
evaluate the expression, and print the result to the screen.

   BASIC also allows one to write programs comprising a series ofç
numbered statements such as:

	100 n1 = 10
	110 n2 = 5
	120 n3 = 3
	130 print ( n1 + n2 ) * n3

When the immediate command "RUN" is entered, the entire sequenceç
of commands is carried out, and the number 45 appears on theç
screen.

   One could write a program to do the same thing using assemblyç
language, the native language of a computer.  However, a high≠
level language like BASIC makes it far easier to generate theç
required instructions.  This is especially true when we areç
dealing with floating point numbers, or when we are using arrayç
variables or advanced mathematical (trig and log) functions.

   When the BASIC interpreter we described above is told toç
"RUN", it processes the program statements one at a time.  Firstç
it analyzes a statement to determine the procedures required toç
perform the specified function.  Then it calls routines thatç
execute those procedures.  This means that when a BASIC statementç
appears in a loop, the analysis has to be repeated each time theç
statement is executed.

   A compiler provides an alternative approach.  The compiler canç
be thought of as an automatic assembly language program writer. ç
You write your program using the commands of the high-levelç
language, and then the compiler converts them into an assemblyç
language program for you.

   Some compilers generate actual assembly language source codeç
that you then have to assemble.  The PASCAL Z compiler, forç
example, worked this way.  This approach makes programç
development slower but allows you to fine-tune the code if you soç
desire.  Other compilers, such as Turbo Pascal, generate only theç
machine code (COM) files.  Some compilers, such as BDS C, followç
a two-step process, but the intermediate code is not standardç
assembly code.

   A compiler, as you might guess, has the advantage of executionç
speed, since the high-level language statements have to beç
analyzed and converted into machine code only once, even whenç
they are executed repeatedly in a loop.  Also, more complexç
programs that need more working memory can be accommodated, sinceç
the code that figures out how to process the high-level languageç
statements does not have to be in memory when the final programç
is run.

   On the other hand, an interpreter offers many advantages thatç
may make it well worth giving up some speed.  Programs are muchç
easier to develop with an interpreter for several reasons. ç
First, you can execute them immediately, without having to goç
through the extra step of compilation (and possibly assembly andç
linkage) before execution.  Second, the programs can be run lineç
by line, and you can watch what is happening and catch errorsç
more easily.

   There are also some things that an interpreter can do that aç
compiler generally cannot.  For example, suppose you are workingç
with an array variable (a variable that holds a collection ofç
values, not just a single value).  With a compiler, you wouldç
have to specify the size -- or at least a maximum size -- of theç
array at the time the program is compiled so that the compilerç
can allocate enough memory for it.  With an interpreter, this isç
not necessary.  It does not have to allocate the memory until theç
variable is first referenced.  As a result, it is quiteç
acceptable for its size to be determined by computationsç
performed earlier in the program.


ZMATE as Interpreter

   ZMATE is, in a way, like the BASIC interpreter, except thatç
its intrinsic high-level language functions (we will call theseç
'primitives') are aimed at text processing rather than numberç
processing.  Just as BASIC has some text-processing primitivesç
(e.g., string variables and functions), so ZMATE has someç
numerical functions, but it is the text-manipulation primitivesç
that are emphasized and richly developed.

   If your past experience has been confined to the usualç
programming languages -- BASIC, FORTRAN, PASCAL, C, etc. -- youç
probably have trouble picturing what a text-processing languageç
would look like.  Here are some examples to help convey theç
concept.

   While most variables in BASIC contain either single numbers orç
arrays of numbers, ZMATE has 'variables' called buffers thatç
contain pieces of text.  Primitives allow reading disk files intoç
these buffers or writing text from the buffers out to files.

   Each buffer has two pointers.  One is called the cursor.  Itç
is where most ZMATE primitives perform their operation.  Theç
other pointer is called a tag, and together with the cursor itç
defines a block of text for some block-operation primitives.

   A whole set of ZMATE primitives deals with cursor motion.  Theç
cursor can be moved forward and backward in the buffer by unitsç
of characters, words, paragraphs, or the whole buffer.  Forç
example, you can tell the cursor to back up by three words or goç
forward two paragraphs.

   This highlights the difference between a number-processing andç
a text processing language.  BASIC supports string variables thatç
can contain a line of text, but it does not know about words andç
paragraphs.  The user would have to write complex code to dealç
with these text concepts.  As a text-processing language, ZMATEç
provides the code for this as part of the language primitives.

   Other ZMATE primitives search for strings and compare stringsç
or characters.  Text can be inserted and deleted.  Blocks of textç
can be moved between buffers for cutting and pasting operations. ç
All the usual control primitives are provided to allow testing,ç
conditional operations, and looping.

   There are also special facilities for handling text formattingç
and text input from the keyboard.  Soft carriage returns can beç
placed into text automatically, and various kinds of indentationç
and margin control are provided.  These functions make it easy toç
write a wordprocessor in the ZMATE language.


How the ZMATE Language is Used

   In our examples above, we saw that a BASIC statement can beç
entered for immediate execution.  ZMATE, too, allows this.  Weç
also saw that BASIC programs containing a sequence of statementsç
can be prepared for later execution.  The same is true of ZMATE. ç
In fact, ZMATE can have a number of programs loaded and ready forç
execution at the same time, and one program can call another as aç
subroutine.

   ZMATE allows its language to be used in one other very specialç
way.  Programs that are permanently stored in the ZMATE COM fileç
can be bound to a key or sequence of keys.  Then when that keyç
sequence is typed at the keyboard, the program is automaticallyç
executed.  ZMATE commands executed this way are called "instantç
commands."

   As an example, suppose we write this little ZMATE program:

	100 put the tag where the cursor is now
	110 move the cursor forward one word
	120 delete the block (tag-to-cursor)
	130 stop

[I am using a BASIC-like pseudo-language for this example.  Theç
actual ZMATE language, which we will get into next time, is notç
at all like this.]  If we now bind this program to the '^T'ç
(control-T) key, we will have implemented the WordStar delete≠
word function.

   This should give you a sense now of how ZMATE can be used toç
implement a text editor or wordprocessor.  Although ZMATE comesç
with some standard programs and key bindings, you can change theç
standard programs, can attach your own new programs, and canç
change the key bindings.  Thus you have extensive control overç
the way ZMATE works and can add any functions you like to it.


The ZMATE Screen

   The normal appearance of the screen while ZMATE is running isç
shown in Fig. 1.  In fact, I captured this screen using the BGiiç
'screen' command while writing this article.  I have made a fewç
changes to adapt it to the TCJ format.  The real screen is theç
full width of the terminal, usually 80 characters, and the fullç
length, usually 24 lines.  I have reduced both of these sizes.

=================================================================
R70

/------------------------------------------------------------------\
| TCJ: TCJ:TCJ46.WS,TCJ:TCJ46.$$$   buf=T  arg=0      |col = 18    |
| INSERT MODE                                         |line= 204   |
| ----------------------------------------------------|free= 13454 |
|         100 put the tag where the cursor is now<                 |
|         110 move the cursor to the next word<                    |
|         120 delete the block (tag-to-cursor)<                    |
|         130 stop<                                                |
| <                                                                |
| [I am using a BASIC-like pseudo-language for this example.  The  |
| actual ZMATE language, which we will get to next time, is not at |
| all like this.]  If we now bind this program to the ^T key, we   |
| will have implemented the WordStar delete-word function.<        |
| <                                                                |
| <                                                                |
| The ZMATE Screen<                                                |
| <                                                                |
|    The normal appearance of the screen while ZMATE is running is |
| shown in Fig. 1.  In fact, I captured this screen using the BGii |
| 'screen' command while writing this article.  I have made a few  |
| changes to adapt it to the TCJ format.  The real screen is the   |
\------------------------------------------------------------------/
R65
Fig. 1.  This is a snapshot of the ZMATE screen approximately asç
it appeared while I was writing this column.

=================================================================

   All but the top three lines are used for the display of text. ç
In the original PMATE, only one buffer could be viewed.  Withç
ZMATE, Bridger Mitchell made it possible to look at two buffersç
or at two sections of one buffer at the same time.  By the way,ç
the '<' characters at the ends of some lines in Fig. 1 indicateç
hard carriage returns.  The other lines end with soft returns. ç
If one changes the margins, the text instantly readjusts.

   At the left of the top line, ZMATE shows the currently loggedç
directory, the file that is open for input, and the file that isç
open for output.  In this case, the output file is a temporaryç
file, TCJ:TCJ46.$$$.  When one closes the edit file, the inputç
file will be given a file type of BAK, while the temporary outputç
file name will be changed to the original input file name.

   In the center of the top line, two status variables areç
displayed.  The first tells us which buffer is currently beingç
edited (there are 12 of them); the second is a numerical valueç
returned by the last ZMATE command that was performed.  Thatç
value can convey information to the user or can be used forç
testing in a program.

   At the right edge of the screen, three other status variablesç
are displayed.  The position of the cursor is given as a columnç
and line number.  The third value tells how much free memory isç
available for additional text.

   The second line in Fig. 1 shows the mode status "INSERT MODE". ç
ZMATE can run in three modes: insert, overtype, and command.  Inç
command mode, the second line is where the user enters ZMATEç
program statements for immediate execution.  After a command isç
entered, it is executed by pressing the escape key (ESC).

   The most recently entered command remains on the command lineç
and can be executed again by pressing ESC again.  Other instantç
command functions can be executed in between.  This gives ZMATEç
wonderful power.  It is one of the things that the author ofç
Vedit -- which began, I believe, as a PMATE clone -- neverç
understood and is one of the reasons why I have always foundç
Vedit unacceptable as an editor.

   Here is an example of how this facility can be used.  Supposeç
we want to change a number of words to upper case.  Assuming thisç
is not already defined as a built-in editor function, we write aç
command line with code that changes all letters of the wordç
containing the cursor to upper case.  Then we press ESC, and theç
current word is converted.  Suppose the next word we want toç
convert is down two lines and over three words from where we areç
now.  Assuming WordStar-like bindings, we could pressç
"^X^X^F^F^F".  Then we can press ESC again to convert that word. ç
In a sense, ZMATE commands typed on the command line become boundç
temporarily as an instant command on the ESC key.

   In insert mode, we are effectively running a ZMATE programç
that asks the user to press keys, which are then inserted intoç
the text.  Overtype mode is the same except that the newç
characters replace the ones previously under the cursor.  In bothç
insert and overtype mode, instant commands operate just as inç
command mode.  That is, key sequence binding are still fully inç
effect.


Key Bindings

   This is a good time to make the role of key bindings moreç
explicit.  With ZMATE, one should think of no keys as producingç
direct input to the editor.  All keys have to be bound to someç
function if they are to have any effect at all.

   ZMATE has three sources for the functions that are bound toç
the keys.  One of these comprises functions that produce ASCIIç
characters.  Most people would take it for granted that pressingç
the 'A' key would produce an 'A', but this is not necessarily soç
in ZMATE.  This makes it quite easy to implement a non-standardç
keyboard layout, such as the Dvorak layout.

   The bindings, moreover, are not one-to-one.  You can have aç
number of different key sequences bound to the same function. ç
So, if you want to have two ESC keys, you can bind a secondç
keyboard key to the "produce-an-ESC-character" function as well. ç
And I want to emphasize that these bindings are of sequences ofç
one or more keys (up to some configurable maximum number) to anyç
single function.

   The key bindings are defined in a table with the followingç
structure.  Each entry, except the last, comprises a byte with aç
function number followed by the sequence of ASCII key codes boundç
to that function.  The sequences are all exactly the maximumç
length specified in the configuration.  If the defined sequenceç
is shorter than this, null bytes (value 0) are used as filler. ç
The end of the table is indicated by a value of FF hex in theç
function-number position.

   The character-producing functions have numbers from from 1 toç
127 inclusive.  I am not sure about function 0.  Putting a nullç
into text is generally not allowed, as null is used to separateç
the buffers.  If no explicit binding is specified for a singleç
ASCII character in the range 1 to 127, it is by default bound toç
the function that produces that character.  Thus the key sequenceç
'A' (a single press of the 'A' key) is bound to the "produce-an≠
A" function if it does not appear in the key binding table.

   This direct mapping of ASCII characters is not, as I saidç
above, required.  For example, I use the tilde and back≠
apostrophe as lead-in keys to other sequences (some people wouldç
call these keys 'meta' keys).  In order to be able to enter theseç
two characters easily into text, I bind the sequence "~~" (twoç
tildes in a row) to the "produce-a-tilde" function and "``" toç
the "produce-a-back-apostrophe" function.

   The second set of functions, numbered from 128 to 191, isç
implemented in ZMATE's internal code.  However, all but a few ofç
them are in fact performed by macro statements in the standardç
ZMATE language.  In PMATE there was no way to modify these; inç
ZMATE, they have been placed at the end of the code andç
referenced in a way that allows the overlay configuration patchç
to redefine these functions freely.

   By my count, of the 64 functions of this type, all but 12 areç
defined by macro program statements.  In some cases it is obviousç
why some are not.  For example, there is a function for setting aç
repeat count that applies to the next command entered.  There isç
also a function that aborts the execution of any macro.  Theseç
functions would not make sense in the macro language itself.

   For some functions it is not so clear why they are notç
implemented as macros.  For example, there is a function to popç
from the "garbage stack" the most recently deleted block of text. ç
This is something that cannot presently be done in the commandç
language, but I don't see why it couldn't or shouldn't be.

   Then there are several functions for which there exist macroç
commands that perform the function.  Switching to insert,ç
overtype, or command mode are examples.  I don't know why theyç
are implemented directly in code rather than in the macroç
language.

   The final set of functions is numbered from 192 to 254.  Aç
hexadecimal FF (255 decimal) is used to mark the end of theç
binding table, so this function number is not allowed.  Theseç
functions are associated with what is called the "permanent macroç
area" or PMA in ZMATE.

   The PMA is a text block that is permanently stored along withç
the ZMATE code and can be moved to and from editing buffers.  Itç
contains a series of macro definitions, each one introduced by aç
control-X character followed by the one-character name for theç
macro and then the program.  Functions 192 to 254 correspond toç
macros whose one-character name is 160 less than the functionç
number, i.e., from space (32) to caret (94).  Because the PMA canç
be edited from within ZMATE, these instant-command functions canç
be modified quite easily.  It might even be possible for one ofç
these macros to be modified by another macro!

   Permanent macros are not limited to the names that can beç
bound to key sequences.  The maximum number of permanent macrosç
would be 256 (0 to 255).  However, (1) the value 0 is notç
allowed, (2) upper-case and lower-case letters are equivalent,ç
and (3) not all characters with the high bit set are distinctç
from the same character without the high bit set (though some areç
different).  In all, by my count there are 160 possible permanentç
macro names, of which 63, as mentioned earlier, can be bound toç
keys.  The others can be invoked from the command line or fromç
other macros.

   Well, this completes the discussion of ZMATE for this time. ç
Next time I will present its command language in detail.
commands.

The Word
========

Patch developed for Swift to bypass the prompt.  See TWPAT.Z80 inç
TW:
directory.

Plug for POE magazine
=====================
                                                                             