                               Z-System CorneÚ (c)
                                 by Jay Sage
                        The Computer Journal, Issue 35
                          Reproduced with permission
                           of author and publisher

     My column about shells and WordStar Release 4 (WS4) in TCJ issue #33ç
prompted more than the usual level of commentary.  There were extensiveç
discussions on Z-Node-Central and the Lillipute Z-Node (the official TCJç
bulletin board), and several messages reached me over the ARPA network.  Notç
all of the comments were favorable, but I was nevertheless happy to receiveç
them.  They helped further clarify my thinking on the very important subjectç
of shells and have spurred me on to prove my points by actually convertingç
WS4 to a ZCPR2-style shell!  After a bit of follow-up discussion, I willç
describe how this conversion was accomplished.


                                Corrections

     There were some things I said in the previous column that wereç
factually wrong, and before I do anything else I wish to correct them.

     First, I stated that the Z-System code in WS4 was written by someoneç
other than MicroPro.  I was wrong.  David McCord, who was vice president atç
Echelon at the time WS4 was developed, sent me a message with the facts ofç
this matter.  Echelon, through staff like David and through publishedç
materials, educated Peter Mireau of MicroPro on the facilities andç
philosophy of Z-System.  Peter did all the actual programming, so the codingç
mistakes were his fault, not Echelon's or David's.

     From a broader perspective, however, as I stated in the previousç
column, the real culprit was inadequate testing.  Bugs in the code wouldç
have been discovered and conceptual issues clarified had more people in theç
Z community been involved as beta testers.  There are so many differentç
styles of using Z-System that it takes a number of testers to uncoverç
problems.  Within days after copies of WS4 were delivered to users of my Z≠
Node, I started getting questions about strange behavior exhibited by WS4,ç
behavior that turned out to result from its operation as a shell.

     A second mistake in the earlier column was my implication that WS4 doesç
not get its own name from the ZCPR3 external file control block (XFCB).  Iç
no longer remember what made me think that this was the case, but Davidç
McCord assured me (and I have now verified for myself) that WS4 does,ç
indeed, get its name from the XFCB when it sets up the shell stack entry.

     Finally, one reader reported to me that my WSSHLOFF routine (the oneç
that completely disables shells while WS4 is running and reenables them whenç
WS4 terminated) crashed his system.  Unfortunately, a large number ofç
misprints crept into the listings in going from my disk file to the printedç
pages.  Most of the typos were obvious, but one was compounded by a doubleç
error.  In the WSSHLOFF listing, the value for EXITSUB was printed as 03BVh. ç
The 'V' was obviously a mistake, and clever readers looked at the similarçälisting for WSSHLFIX, where the value was given as 03B3h.  This,ç
regrettably, looks correct but was also a typo.  The proper value is 03BEh. ç
We hope that Art Carlson will make sure that the listings in this column areç
transcribed accurately (so that all the mistakes will be mine!).


                             More WS4 Comments

     While on the subject of WS4, I would like to add a few further commentsç
about how it works.  Not surprisingly (considering when it was developed),ç
in creating its shell stack entry WS4 does not make use of the facilityç
introduced with ZCPR version 3.3 that allows a program to determine from theç
XFCB not only its name but also the directory from which it was actuallyç
loaded (the user number is at offset 13 and the drive, with A=1, at offsetç
14).

     As a result, in order for WS4 to be reinvoked as a shell, the commandç
search path must include the directory in which WS4 is located.  I mentionç
this here as a reminder and suggestion to authors of new or updated shellsç
and error handlers that they use this Z33 facility to avoid the requirementç
that the program be on the path and to speed up loading of the program (byç
eliminating any search for it).  My WordStar conversion described later addsç
this feature.

     With WS4 it is generally necessary that the command search path includeç
WS4's directory for an additional reason.  I learned the hard way that whenç
WS4 runs under Z-System, it pays no attention to the drive and user numberç
that WSCHANGE specified as the location for the overlay files; it only usesç
the search path to try to locate them.

     This is a problem for me because, as I have explained at length inç
previous columns, I put only my small RAM disk on the path and use ARUNZç
aliases to invoke all programs except the very few that fit on the RAM disk. ç
With this approach, there is no way to get WS4 to find its overlay files. ç
The conversion addresses this problem also.


                           ZCPR2 vs. ZCPR3 Shells

     I would not like to take up again one of the subjects raised in issueç
#33: ZCPR2-style versus ZCPR3-style shells.

     First an aside.  Shells seem to be a surprisingly emotional issue.  Iç
thought my earlier column presented a fairly carefully and calmly reasonedç
discussion of some aspects of shells, including their pros and their cons. ç
Some readers, however, took great offense at my even questioning the currentç
method of implementing shells or of what some people are trying to do withç
them.

     One reader went so far as to suggest that I had no business commentingç
on the subject when, by my own admission, there are a number of shells thatç
I have never used.  Besides the fact that this is hardly a reasonedçäargument, I would like to make sure that the following facts about shellsç
are fully appreciated.

     ZCPR3-style shells are a facility of the command processor.  Withoutç
special code in the CPR, there would be no such shells.  As the author ofç
the two latest versions of the ZCPR command processor, I think I can speakç
with some authority (though certainly not with infallibility) on theç
subject, since in writing that code I had to consider the issue of shellsç
rather carefully from a rigorous theoretical viewpoint.

     ZCPR2-style shells, quite the contrary, are not a facility of theç
command processor; they are a facility of the individual shell programs. ç
Their functioning depends only on the operation of the multiple command lineç
facility.  The command processor does not treat a Z2 shell command anyç
differently than it treats any other command.  This is really the key to theç
difference between the two shell implementations.

     In the previous column I stated: "...I am coming to the conclusion thatç
only programs like history shells...should be implemented as ZCPR3-styleç
shells.  Other programs, like ZFILER and WordStar should use the ZCPR2ç
style."  I then invited readers to enlighten me if I was missing someç
important point.  I got some responses to this invitation, but no one yetç
has offered me any evidence that I had missed any important point.

     One reader reiterated essentially the same difference between Z2 and Z3ç
shells that I attempted to demonstrate with my example in which WordStar wasç
invoked in a multiple command line.  Apparently the point bears repeating.

     This reader presented the point using a command line like theç
following:

		ZFILER;ECHO TESTING

Under ZCPR2, ZFILER would run and present its file display to the user.  Ifç
the user generated a command line "CMDLINE" as the result of a macro or inç
response to the prompt after the 'Z' command, a Z2-shell version of ZFILERç
would build the command sequence "CMDLINE;ZFILER" and insert it into theç
multiple command line buffer just before the next command to be executed. ç
This would give:

		CMDLINE;ZFILER;ECHO TESTING

The user's command line would run, and then ZFILER would be invoked again. ç
Only on termination of ZFILER would the last command, "ECHO TESTING", beç
performed.

     A Z3 shell would respond to the same command line from the user inç
quite a different way.  As before, ZFILER would be invoked first.  It wouldç
determine from the Z3 message buffer that it had been invoked manually andç
would respond by pushing its own name onto the shell stack.  Then it wouldç
terminate.  The command processor would then proceed to run "ECHO TESTING". ç
Only after that, once the command line was empty, would ZFILER be reloaded,çäthis time as a shell.  Recognizing its shell status, it would now displayç
its screen of file names and do its real work.

     The reader who submitted this example, if I understood him correctly,ç
viewed the Z3 behavior as correct and the Z2 behavior as wrong.  If you areç
an experienced Z-System user, you will probably recognize in this reader aç
fellow expert (and, indeed, he is).  He is so used to ZCPR3 that he noç
longer notices that it is the behavior of the Z3 shell that is trulyç
bizarre!

     Consider the following two command lines:

	(1) ZFILER;ECHO TESTING
	(2) ECHO TESTING;ZFILER

We have already analyzed the first one; the second one can safely be left asç
an exercise for the reader.  We will simply state the answer that underç
ZCPR3 they will accomplish exactly the same thing!  This is hardly a resultç
that conforms to intuition, and I still remember in my early days as a Z≠
Node sysop trying to explain to quite a few users why the second command onç
a VFILER command line executes first!

     Under ZCPR2 the result is just what one would expect.  In the firstç
case, ZFILER runs first, and ECHO runs only after the user terminates ZFILERç
using its 'X' command.  In the second case, ECHO runs first and ZFILERç
second.  In other words, with Z2 shells, commands are executed in the orderç
they are entered, a notion that does not require long experience and greatç
expertise to understand and get used to!  And it gives the user a greaterç
measure of control.


                           Mixed Z2 and Z3 Shells

     The same reader submitted another interesting example that illustratesç
the confusing behavior that can arise when Z2 and Z3 shells are mixed.  Hereç
we assume that WordStar has been implemented as a Z2 shell and ZFILER as aç
Z3 shell.  Suppose we use the 'R' command of WordStar to enter the commandç
"ZFILER".  WS4, as a Z2 shell, would generate the command line

		ZFILER;WS

ZFILER, as a Z3 shell, would install itself on the shell stack and proceedç
to execute "WS".  ZFILER would not run in its file maintenance mode untilç
after we terminated WordStar.

     This is, admittedly, probably not what one intended, since we mostç
likely entered the ZFILER command with the intention of doing some fileç
maintenance before returning to WordStar.  On the other hand, it isç
certainly no more bizarre than what we saw in our earlier example.

     If both WS4 and ZFILER were Z3 shells, then the invocation of ZFILERç
from the WS4 'R' command would cause it to become the active shell (the oneçäon the top of the shell stack).  The WS4 shell would be pushed down in theç
shell stack, and ZFILER would take control.  With a little thought, however,ç
you will see that the same is also true if both ZFILER and WS4 are Z2ç
shells!

     The strange behavior with the mixed shells in the above example arisesç
in part because ZFILER was not really being used as a shell in the Z3 sense,ç
namely, as a replacement for the command processor's command-line inputç
routine.  It was intended as a file maintenance utility.

     Suppose we had entered the command "EASE" (the Z3-type history shell)ç
instead of "ZFILER" from our Z2 version of WordStar.  This would establishç
EASE as the current shell and return to WordStar.  That behavior would notç
seem strange, because in this case we would be thinking of our EASE commandç
as establishing the shell to be used in place of the command processor theç
next time the command processor needed a new command line.  So long asç
WordStar is running, there is no need for EASE to do anything.  We expect itç
to take effect only after we are finished using WordStar.


                   Nested Z2 Shells and Recursive Aliases

     Although I had once thought that the Z3 shell stack was required inç
order to nest shells, I showed in the earlier column that this is not theç
case. Z2-style shells can, in fact, be nested more flexibly.  There is noç
predetermined limit to the nesting depth or to the amount of informationç
that can be passed with each shell command line.  The only limit is imposedç
by the length of the multiple command line buffer, just as with the nestingç
of aliases.

     With the standard shell stack configuration of 4 32-byte entries, if aç
shell command uses only 16 bytes, 16 bytes are wasted.  On the other hand,ç
if a shell command needs 48 bytes to hold its information, it cannot run atç
all under this configuration (NZ-COM can come to the rescue by allowing theç
shell stack configuration to be changed on the fly).  With Z2 shells, theseç
problems go away.  In 64 bytes of command line, one can have two 32-byteç
shell commands or a combination of one 16-byte shell command and one 48-byteç
shell command (or five 12-byte shell commands).

     I did overlook one point when I described putting data for the shellsç
on the command line.  In the Z3 shell stack, one can include, after theç
shell command's terminating null, any binary data that one wishes.  Thus 256ç
values are possible for each extra byte in the shell stack entry.

     In order to carry shell data on the command line, several additionalç
constraints apply.  First, the command processor strips the high bits offç
all characters in the command line, so only 128 values are available toç
start with.  Secondly, the null character cannot be used because the commandç
processor would interpret this as the end of the command line (that leavesç
127 values).  Finally, letters are converted to upper case, thereby makingç
the characters from 'a' to 'z' inaccessible (scratch another 26).  Thisç
leaves only 101 possible values out of the original 256.  Moreover, extraçächaracters are required as flags to signal the program to consider itself asç
having been invoked as a shell (a service provided in ZCPR3 by a flag in theç
message buffer).  All of these things reduce the efficiency with which theç
space in the command line buffer can be used compared to the space in theç
shell stack.

     One reader pointed out that recursive aliases cannot be used withç
Z2-type shells.  This is true...but only if one is using the pseudo≠
recursive alias that I invented.  This kind of alias accomplishes a crudeç
approximation to recursion by discarding any pending commands in the commandç
line buffer.  This will, indeed, discard any shell reinvocation commands. ç
However, if one uses the logically sound and rigorous recursive aliasç
technique invented by Dreas Nielsen (see my column in issue #28), there isç
no problem.  It sometimes pays to do things right!

     In fact, it seems to me that the Z2 shell is, in essence, a recursiveç
alias, a program that keeps invoking itself.  And this is just what most (ifç
not all) Z3 shells actually do.  I am still awaiting an example of somethingç
(good) that a Z3 shell can do that cannot be done in some equivalent wayç
with a Z2 shell or recursive alias.


                        The Real Difference Between
                              Z2 and Z3 Shells

     After much reflection, I think I have finally put my finger on theç
fundamental distinction between Z2 and Z3 shells.  It derives from the factsç
I alluded to earlier: that the Z3 shell is a true creature of the commandç
processor and the Z2 shell is not.

     Here is an example that will illustrate the point.  Suppose the historyç
shell EASE were implemented as a Z2-style shell and that while it isç
running, we issue the command "DIR".  EASE will insert into the command lineç
a sequence like the following:

		DIR;EASE

DIR will run, and then EASE will be reinvoked.  Looks fine!  But now supposeç
the user enters the command "IF EXIST FN.FT".  EASE will then generate theç
command line

		IF EXIST FN.FT;EASE

If the file FN.FT exists, this will again work just fine, but suppose theç
file does not exist.  Then the system will enter a false flow state, and theç
EASE command (and perhaps other commands pending in the command line afterç
it) will be flushed by the command processor.  The shell function will beç
lost, and any other pending commands will be processed in an unintended way.

     For a Z2 shell to function properly in general, all command linesç
inserted by it must result in the same flow state at the end of the commandç
line as at the beginning.  With a MENU shell it could be possible for theçäsystem designer to guarantee this, since he can control which commands areç
generated by the shell.  With a history type shell it would be nearlyç
impossible to ensure that this condition would always be met.

     The critical feature of shell processing under ZCPR3 is that flowç
processing is suspended during the operation of shells.  This allows them toç
run, as they must, even after the user has passed a command that leaves theç
system in a false flow state.  The ZCPR33 Users Guide goes into some detailç
on this matter, and had I remembered better what I wrote there, it would notç
have taken me this long to come to the essence of the Z2-vs.-Z3 shell issue.

     Some users of ZCPR33 have modified the way the command processor dealsç
with flow control in shell processing.  No one has yet convinced me of theç
value of this (the risks are undeniable).  It still seems to me that Z2-typeç
shells and recursive aliases can accomplish the same thing, but in aç
logically sound way.

     I have extended an invitation to Dreas Nielsen to write a series ofç
columns for TCJ explaining his very powerful shell programs.  Since he isç
also one of the people who has made this modification to the CPR, perhaps heç
will also present the other side of this story and explain why it isç
necessary or desirable to treat shells the way he does.


                        Remaking WordStar Release 4

     When I first received my copy of WordStar 4 and encountered problems ç
with the way it handled shells, I fired up the DSD debugger and tried to ç
figure out how to fix it.  After a considerable amount of rummaging about inç
the code (and especially trying to figure out what was going on insideç
WS.OVR), I gave up.  Later I tried again...and failed again.  In the courseç
of preparing this column, I decided to have one more go at it, and this time ç
things started to click.

     The patches I will describe here are preliminary and have not yet been ç
extensively tested.  In fact, as I write this, I am the only one who hasç
used them, and you know what I said above about the dangers of a testç
program that does not involve a variety of Z-System users.  So, you areç
hereby recruited, if you are willing, to join the test program.

     Since I may very well have made some mistakes, and since there areç
further changes that people may want to make (let's hear your suggestions),ç
I will not only give the results; I will describe the process by which theseç
patches have been developed.


                             Cracking the Code

     The first step toward changing the code was figuring out how the virginç
WordStar was doing what it did.  In particular, I wanted to locate routinesç
related to Z-System functions, so the first thing I tried was searching forç
all references to address 109h, which contains the address of the Z-Systemçäenvironment (ENV).  Any WS4 feature that made use of a Z-System facilityç
would have to get information from the ENV.

     As best I recall, this did not turn up many references and did notç
particularly help (though it was a good idea, and that's why I mention it). ç
In the end, I just started tracing the code from the beginning, figuringç
that WS4 would have to determine fairly early whether it was running underç
Z-System or standard CP/M.  This turned out to be correct, and very soon Iç
came to the key Z routine, at address 0AA4h in WS.COM.  This routine returnsç
the address and size of a Z-System module specified by an offset passed inç
the E register.

     Having discovered this routine, I used DSD to find all references to itç
in WS.COM and WS.OVR.  They occur with the following values of E:

	E =  9h		the command search path (PATH)
	E = 15h		the named directory register (NDR)
	E = 18h		the multiple command line buffer (MCL)
	E = 1Eh		the shell stack (SHL)
	E = 22h		the message buffer (MSG)
	E = 24h		the external file control block (XFCB)


                         Setting up the Shell Stack

     The block of code beginning around address 3CBFh in WS.OVR makesç
references to MCL, XFCB, and SHL.  I guessed correctly that this had to beç
the code where WS4 sets up its shell stack entry.  (This block of code, byç
the way, is where the shell-pushing mistake occurs for the case where theç
shell stack is currently empty.)

     The patch for this part of WS.OVR (see Listing 1) modifies this code. ç
First of all, since WS4 is going to operate as a Z2-type shell, we do notç
want it to do anything with the shell stack.  It is easy to disable the codeç
by simply skipping over it, but one has to watch out for subtleties. ç
Indeed, in order for the 'R' command to use the MCL and not chain using theç
greatly inferior CP/M method, WS4 has to think that the shell entry wasç
established successfully.

     I noticed that a flag was being set into address 2200h, and I surmisedç
that it is used by WS4 to show that it is running under Z-System.  In theç
patch, I set this flag even though the shell stack entry is not being setç
up.  I have not examined all references to this flag, and there is a chanceç
that there are additional, more complex effects.  If any problems appearç
with the patched version of WordStar, this flag might be involved.  For theç
initial attempt at fixing WS4, I just took the easiest course of action, andç
so far it appears to have worked.

     It seemed foolish to waste space in WS.OVR by doing nothing more thanç
setting the flag and jumping to where the original code resumed (60AAh). ç
Instead, I have used the space to compute the command line necessary toç
reinvoke WordStar.  The code gets not only the name by which WordStar wasçäinvoked but also the drive and user number from which it was loaded.  Aç
command line of the form ";DUU:WSNAME" is generated.

     There is one extra step in this part of the patch.  When running as aç
Z3 shell, WS4 knows from the command status flag in the message buffer whenç
it was invoked as a shell so it can put up the press-any-key message beforeç
clearing the screen and resuming operation.  As a Z2 shell, WS4 cannot useç
this facility.  Instead, a signal has to be included in the command tail. ç
For reasons that I will not go into in full detail, I chose for this signalç
a comma at the very end of the tail.  Very briefly, the comma is a handyç
character because it is not parsed into the default file control blocks,ç
where a program could confuse it with a file name.

     The final reinvocation command line, with its terminating null, takesç
the form

		;DUU:WSNAME ,<0>

Since I could not be sure that this section of overlay code would persist inç
memory until the command would be used, I store it at the top of the WS4'sç
user patch area (MORPAT).


                 The Initialization and Termination Patches

     Having made the above modification, we must make two others in order toç
remain consistent.  First, we must modify the WS4 initialization code inç
which it determines whether or not it was invoked as a shell.  This is theç
patch at address 1A2Fh in WS.COM.  The patch calculates the address of theç
last character passed in the command tail and checks to see if it was aç
comma.  If not, it proceeds with normal operation of the program.

     If there is a comma, the shell-wait message must be displayed until theç
user presses a key.  But one must also remove the comma from the commandç
tail to ensure that WordStar not think it has been passed a file name.  Atç
present I do this by replacing the comma with a space.  This is notç
rigorous, but it seems to work, since WS4 is apparently not confused by aç
tail consisting only of spaces (unfortunately, a number of programs are).

     Since WS4 no longer pushes its name onto the shell stack, we must alsoç
prevent it from popping the shell stack when it terminates.  This is theç
patch at address 13CEh in WS.COM.  This is the easiest patch of all, sinceç
we simply have to skip some code.  As an additional benefit, this frees upç
about 40 bytes of space that we use for some of our other patch code.


                           Fixing the 'R' Command

     Now we come to the main item in this set of patches -- the code thatç
makes the 'R' command work as a ZCPR2-type shell.  The new code here is muchç
more complex than what it replaces, and we can only fit part of it at theç
original location 67B2h in WS.OVR.  We put what we can there and continueçäwith the rest in the MORPAT area in WS.COM.

     The basic strategy is to take the command line entered by the user inç
response to the 'R' command prompt, append the WS reinvocation commandç
(including its semicolon separator), and append any remaining command lineç
pending in the multiple command line buffer (if there is one, it will beginç
with a semicolon also).  If there is enough room for the result in the MCL,ç
then it is moved there and chained to.  If not, a warning message isç
displayed on the screen until a key is pressed, and the user command isç
ignored.

     To implement this strategy, I chose the simplest method I could thinkç
of.  Since the 'R' command operates from the WordStar no-file menu, theç
entire WS edit buffer is available as a scratch area.  I picked an arbitraryç
address of A000h for a buffer in which to build the new command line. ç
Again, rigorous code calculate the address.  My code is a quick-and-dirtyç
solution.


                         Finding the Overlay Files

     As I noted earlier, with my style of operation, WS4 had trouble findingç
its overlays.  To solve that problem, the patch includes an optional sectionç
to install an internal search path for the overlay files.  This patch isç
installed at address 0F5Fh in WS.COM, where it replaces a call for theç
location of the Z-System path with a call to a routine that returns theç
address and size of an internal path.  In Listing 1 the internal path hasç
the single element B4:, the directory in which I keep my WordStar programç
files.  You can put any values you want here.


                           Installing the Patches

     It is not possible to install the patches in WS.OVR using MLOAD or aç
debugger, because the OVR file is too large to load entirely into memory. ç
ZPATCH, on the other hand, can handle the job splendidly.  ZPATCH assumes anç
offset of 0000 for a file of type OVR, while the addresses in the listingç
are those shown when the file (as much as can fit) is read into memory underç
a debugger.  To make things consistent, you should use the ZPATCH 'O'ç
command to set the offset to 100.  

     Key in the new data carefully, checking from time to time that theç
address is still correct.  Also, be careful not to go beyond a recordç
boundary while in ZPATCH.  It wraps from the end of the record back to theç
beginning of that record without warning (this really gave me grief until Iç
caught on to the problem).  When you get to the end of the current record,ç
write it out (^W), advance to the next record (>), and reenter edit modeç
(E).  Then you can resume entering data.

     The attached listing was made with a specially configured version ofç
the SLR Z80ASM assembler.  Normally, I have it display addresses in logicalç
order for easier interpretation.  For hand keying of a patch, however, it isçäfar more convenient to have the bytes of a word in physical order.  Justç
watch out when reading the displayed symbol values.  They, too, are storedç
in byte-reversed format.

     It is possible to use MLOAD to install just the patches for WS.COM. ç
Simply delete the parts of WSPAT.Z80 that refer to patches in WS.OVR andç
assemble the remaining code to a HEX file.

     Enjoy playing with (and using) this different (improved) version ofç
WordStar 4, and let me know what you think and what further suggestions youç
have.

[This article was originally published in issue 35 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1988, 1991 Socrates Press and respective authors]
