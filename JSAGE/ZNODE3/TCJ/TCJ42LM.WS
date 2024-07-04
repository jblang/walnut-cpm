About the author and his system:

   Lee McEwen is a management analyst living in central New Jersey.  He hasç
been running public bulletin boards since 1985 but only established a CP/M≠
based system at the beginning of 1989.  Within three months, Socrates hadç
gained Z-Node status.  Lee dedicated Socrates to learning, whether it be the ç
Z-System or high level languages.  There is a message base devoted to theç
new 'C' programmer.  In addition, Socrates is the central site for QBBS ç
development.

   Socrates can be called at (201) 754-9067, at up to 2400 bps.  It runs onç
an Ampro Little Board with a 64 meg drive.  Lee runs on Coke and potatoç
chips.

=============================================================================

                            Using BYE with NZCOM
                                     or
                       The New Taming of an Old Shrew

                               by Lee McEwen
                            Socrates Z-Node #32

   Socrates, my rcpm, went on line last December.  Evidently, this was moreç
of an event than it seemed at the time.  Why?  I had just bought NZCOM theç
week before, without any previous Z System experience, and getting BYE to ç
peacefully coexist with NZCOM was supposed to be hard.  To be fair, mine ç
wasn't the first rcpm to run under NZCOM.  Bob Dean converted Drexel Hill to ç
NZCOM sometime the previous summer, and I am sure there were others.  Butç
the difference, I'm told, was that a total neophyte managed to stumble inç
the right combinations to make things work.  This seemed to interest Jayç
Sage, who surely is more accustomed to dealing with people who can walk andç
chew gum at the same time!  He asked me to tell you how I did it.

   Before we start, I should mention one thing.  It is true that you can'tç
run NZCOM under BYE.  BYE is an RSX and protects itself from beingç
overwritten.  NZCOM is a very powerful loader that can reconfigure theç
memory map.  It looks for such programs as BYE and refuses to run when theyç
exist.  But we don't need to run NZCOM while BYE is running.  We run itç
before we run BYE, and we change systems with ENV files rather than ZCM,ç
using JetLDR.  Our only real restriction is that we cannot change the memoryç
map while BYE is active.

   In this article, we will set up a Xerox 16/8 DEM-II with a 10 meg hardç
drive, which we have configured with three logical drives (A: through C:)ç
for the hard drive and one floppy as drive D:.  Here is a list of steps toç
take which we will discuss in turn:

            Get NZCOM running first.
              RCP vs. Transient commands.
              Become familiar with ZCM files and how to edit them.
              Make your named directory files.
            Patch WHL.COM and NZCOM.COM
            Get BYE running next.
              Watch out! There some traps here.
              Z3BASE.LIB
    +-+-+-> Tweak it.
    | | |     Use MKZCM, NZCOM.COM and JETLDR.
    | | |     Current public DU:'s will reflect in the new .ZCM files.
    | | +-< Check SHOW, PATH and PUBLIC, and the BYE.PRN file.
    | |     Get your BBS software up and running.
    | +---< Make your aliases.
    |         My usual ones.
    |       Choose your transient commands carefully
    |         What stays on A0:
    |         What must be moved to A15:
    +-----< Check the system on line.
              Watch for security.


GET NZCOM RUNNING FIRST.

   Why NZCOM first?  It is your operating system.  Imagine trying to run aç
program without having CP/M installed on your computer.  BYE is a nastyç
program in that it hooks itself very deeply into the system.  Getting itç
running under the wrong system is a waste of time.

   We want to get the memory configuration of NZCOM that you will use withç
the BBS going.  If you need a certain sized TPA for your BBS, you have toç
make room for it here since we can't change the memory map later while BYEç
is  running.  Place MKZCM, SHOW, PATH, and PUBLIC and your favorite editorç
on A0:.  Run MKZCM to create your 'on line system'.  We will be makingç
several versions of the system, but they must all have the same memory map.

   We will be setting up three systems.  The first is the one we will beç
letting the callers use.  It will have significant restrictions set on it. ç
Then we will set up a system for the sysop which will allow you to doç
anything you like on your computer, but will lock out the floppy disk drive. ç
Why do that?  What if you call in remotely and enter a command such as 'FF'ç
that accesses the floppy, but you forgot to leave a disk in the drive? ç
You'd hang the system.  Finally, we'll make one last system the same as theç
sysop's, but it will let you at the floppy.  I found it easier to set up theç
restricted system first and then after that is running properly, go back andç
set up the sysop systems.

   I installed an NZCOM system without any RCP.  As I implied in the lead ç
paragraph, my assembly programming experience is less than minimal.  As a ç
result, I trust transient commands much more than I do anything permanent in ç
the operating system itself.  If a command doesn't behave as I expected, I ç
replace it, or get it out of harm's way.  The book says that IOP's are aç
topic for advanced users.  Well, that did that!  I dumped them as well.  Iç
then increased the number of named directories allowed.  And with that, Iç
saved my new system.  Use the name 'USER' to save this configuration.

   MKZCM will save two files, each of which describes the configurationç
you've  just done.  USER.ZCM is of particular interest to us as it describesç
the  target system in a text file which you can easily edit.  Let's do thatç
now.   Pay particular attention to MAXDRV, MAXUSR, QUIET, Z3WHL, DRVEC,ç
PUBDRV, and  PUBUSR.  Load up your editor and bring up USER.ZCM in non≠
document mode:

  EA06 CBIOS    0080 ENVTYP    E8F4 EXPATH    0005 EXPATHS   0000 RCP
  0000 RCPS     0000 IOP       0000 IOPS      E200 FCP       0005 FCPS
  E480 Z3NDIR   0023 Z3NDIRS   E900 Z3CL      00CB Z3CLS     E780 Z3ENV
  0002 Z3ENVS   E700 SHSTK     0004 SHSTKS    0020 SHSIZE    E880 Z3MSG
  E8D0 EXTFCB   E9D0 EXTSTK  ->0000 QUIET   ->E8FF Z3WHL     0004 SPEEDç
->0010 MAXDRV ->001F MAXUSR    0001 DUOK      0000 CRT       0000 PRT
  0050 COLS     0018 ROWS      0016 LINS    ->FFFF DRVEC     0000 SPAR1
  0050 PCOL     0042 PROW      003A PLIN      0001 FORM      0000 SPAR2
  0000 SPAR3    0000 SPAR4     0000 SPAR5     CB00 CCP       0010 CCPS
  D300 DOS      001C DOSS      E100 BIO     ->0001 PUBDRV  ->0080 PUBUSR

   This almost describes a Xerox 16/8 DEM-II computer, but it is wrong aboutç
the drives we have.  Notice that MAXDRV is 0010, and DRVEC is FFFF.  Theseç
two values say that we have 16 contiguous drives on the computer.  This isç
not the case.  This system has four drives, but we are building a system forç
public use, and we won't be letting the callers at our floppy drive.  Weç
need to change MAXDRV to 0003.  

   That's easy enough.  But what of this DRVEC?  It is a bit map of theç
valid drives, which lets NZCOM skip over any drive that is not present.  Youç
can use the following chart to determine the value to give DRVEC.  Put a oneç
over any drive that you have on the system.  Add up the values for eachç
line, and write them down in hexadecimal to the right. 

                 Weight Factor:
               8    4    2    1

               0    0    0    0    =    0---
               P    O    N    M

               0    0    0    0    =    -0--
               L    K    J    I

               0    0    0    0    =    --0-
               H    G    F    E

               0    1    1    1    =    ---7
               D    C    B    A
                                        0007

Change DRVEC to 0007.

   We also want to limit the highest user area we will let the callers have ç
access to.  All the sensitive commands such as ERA will be up high.  I have ç
mine set at 7.  Change MAXUSR to 0007.

   The QUIET flag tells the system if it should report what it is doing toç
the user.  We want this for ourselves, but not for our callers.  Part of our ç
security is that we will be using aliases to load in modules which we willç
be giving secret names.  If the quiet flag is off, the names will beç
reported as they load.  So set QUIET to 0001.

   Take note of the value you have for Z3WHL.  You will want this later onç
when  we get to BYE and save this file.

   But didn't we forget PUBDRV and PUBUSR?  These refer to the public driveç
and user areas that ZRDOS will recognize, and are a bit of a bear.  On myç
system, I have A8: set as a public DU: where I put WordStar.  Obviously weç
don't want callers using that!  But every time I edited the USER.ZCM file toç
say there were no public DU's, the next time I loaded the system, they'd beç
back!  The trick here is to use the PUBLIC utility to cancel any public DU'sç
before you load your new system.  Do that now.

    Now enter 'NZCOM A0:USER.ZCM' to load this system.  Be sure you includeç
the prefix A0:.   Run SHOW to see if we have the values we want for theç
drives and user areas.  You'll see this on screen 3.  Everything OK?  Ifç
not, then go back to your editor and change USER.ZCM as needed.

   Run PATH to see if the QUIET flag is correct.  It won't tell you anythingç
if the QUIET flag is on.  If it tells you what your path is, then the QUIETç
flag is off.  That's not good.  Again, load your editor, and fix QUIET.

   If you've changed anything, reload with NZCOM and check everything againç
with SHOW and PATH.  Keep editing, reloading, and checking until you have itç
the way you want it.

   Now check for PUBLIC DU's.  You should have none.  If you do have any,ç
clear them now.

   Run MKZCM one more time.  Don't change anything, just save it under theç
same name.  Why do that?  Remember that MKZCM creates two files?  The oneç
we've been working with has the extension of 'ZCM'.  If you noticed, theç
other file MKZCM saved had the extension of 'ENV'.  This is what we've beenç
after all this time because JetLDR can handle this file just fine.

   Check and recheck that the system is set as you'd want for open use. ç
When you are happy with the users' system, we will go on to make the sysopç
system.  Bring up MKZCM again, but this time save the result under a nameç
that only you will know.  For our discussion, we will call it SYSOP.  Let'sç
go back with your editor and give you some access on your own computer!

   Change MAXUSR to the maximum user area you have.  This is usually 15. ç
Pull that DRVEC chart out again.  Check off all the drives you need accessç
to,  except for floppy disks.  Then set QUIET to 0000.  But watch out! ç
Don't do anything that changes the size of the system.  Save the results.

   Enter 'NZCOM A0:SYSOP.ZCM' to load this system.  Again, it is importantç
to enter the A0:.  Run SHOW and PATH.  Is it set as you want?  If not, editç
again and reload.

   Now set any public DU's you want.  After you've thoroughly verified the ç
settings, run MKZCM to create an ENV of this system.  Finally, create oneç
more system, but this time include the floppies.  Give this another secretç
name.

   What have we done?  We've created three environment files that we can useç
on-line to change a caller's access.  We don't need the ZCM files anyç
longer, so you can erase them.  Use STAT or DFA to set all the ENV files toç
$SYS so that users will not be able to see them with the DIR command.

   The last thing to do before we move on is to create the named directory ç
files.  I use the same names as the environment files.  The big point hereç
is that even if a DU: is out of range of the environment, if it has a nameç
and no password, a caller can move there.  You can give passwords toç
directories, but it is simpler just to not declare them in the first placeç
if you don't want people going there.

   [Note by Jay Sage: I take a different approach and make extensive use ofç
named directories with passwords.  In fact, the named directories on myç
system are the same for users and sysops.  All I do to make the sysopç
systems is turn on the wheel byte, since when this is on, passwords areç
ignored, and one has free access to all the sysop directories.]


PATCH WHL.COM AND NZCOM.COM

   Before we go too much further, you need to make two patches.  Make backup ç
copies of NZCOM.COM.  If you dumped the RCP as I did, you need a transient ç
called WHL32.COM to manipulate your wheel byte, and we will patch this as well.  If you are using the RCP, your system password is in there.  Bigç
point here is to do this after you've made back-up copies of whatever youç
are going to patch.  Can you say 'oops'?

   Use DU (disk utility), ZPATCH, or whatever you are comfortable with andç
call in NZCOM.COM.  Search for NZCPM.  This will be in the FCB section ofç
the program.  Change it to something else.  Your restrictions are that youç
must make this eight characters or less, that you must pad it out to exactlyç
eight characters with spaces, and that you must use capital letters.  Whatç
you put here must be a secret.

   Now, why did we do this?  NZCOM will make a file called NZCPM.COM on theç
disk if there isn't already one.  The purpose of this file is to allow youç
to dump the NZCOM system and go into straight CP/M.  If a user does this onç
line, he will effectively turn your BBS off.  He can't hurt anything, as BYEç
won't be able to talk to the system any longer, but it won't reset when heç
finally drops carrier, either.  You'll be crashed until you reboot.

   So we gave NZCPM a secret name.  Drop out of NZCOM and reload it.  Theç
system will write NZCPM.COM under the name you just gave it.  Eraseç
NZCPM.COM, and use STAT to make its replacement a $SYS file so that no oneç
but you knows its name.

   [Note by Jay Sage:  Again, I can suggest an alternative and simplerç
approach.  Leave NZCOM.COM as it is.  Run it to create the file NZCPM.COM,ç
and then copy that file to a secure area.  Then use SALIAS to create anç
alias called NZCPM that has the script command: "IF WH;DIR:NZCPM;FI", whereç
DIR is the directory where you put the real NZCPM.COM.  The presence of thisç
alias will inhibit NZCOM from creating a new NZCPM file, and the alias willç
do something only in sysop mode (when the wheel byte is on).  If the wheelç
byte is off, the command will do nothing.  If the wheel is on, then the realç
NZCPM command will be invoked.]

   The other patch we have to make is the wheel password.  If you dumped theç
RCP as I suggested, then you will be using WHL32.COM.  Patch that. ç
Otherwise you patch NZRCP.ZRL in NZCOM.LBR.  Look for either SYSTEM orç
PASSWORD.  I forget what it says in the distribution copy.  Change it toç
something else.  Again, your restrictions are eight characters, padded withç
spaces, in capital letters.  [Note added by Jay Sage:  This patch youç
absolutely must do; you must not leave a wheel-setting command on the systemç
with an unsecure password.  The wheel password is not determined by theç
system but is set for each WHEEL program (e.g., WHL32 or the RCP WHLç
command).  You should be able to find the password using a patching utilityç
and change it to something secret.  Be sure to test it before putting yourç
system on the air.]


GET BYE RUNNING NEXT

   Now comes some real fun.  Getting BYE running for the first time isç
almost guaranteed to take five years off your life and is more that we canç
tackle in one article.  I suggest you work closely with a Z-Node sysop forç
assistance as you go.  But here is the plan: get BYE running any way you canç
at first, and then go back to tweak it.  I would suggest you rename DIR toç
the name of the BBS you plan to run so that it will be the program run whenç
you test BYE.  This eliminates any problems you may have with your BBSç
system as you debug BYE itself.

   BYE is a necessary evil.  It hasn't been given a full rewrite in aboutç
five years, and its age is showing.  The biggest problem is that it tries toç
be all things for all systems.  All I want from BYE is modem redirection, aç
few extra BDOS calls to handle situations that would only happen under aç
remote system (such as time on line and carrier test), and maybe a few neatç
function keys like "Who's on line?".  What I don't want it doing is messingç
with the environment.  We have an operating system to do that for us. ç
Unfortunately, BYE insists, and it usually messes things up.  One of theseç
days we will have a BYE made for today's systems.  Until then, we have toç
work with this monster.  [Note added by Jay Sage:  See my column in TCJ #40ç
for a discussion of what BYE does.  I second Lee's comments about BYE andç
the need for a replacement that is appropriate for Z-Systems.]

   I use QBYE, as it is the simplest to set up.  QBYE is based on NUBYE 1.01ç
by Tom Brady.  Tom and Irv Hoff had worked together for most of theç
development of BYE but parted company just as the last generation came out. ç
I would expect whatever findings I have with QBYE you will have with BYEç
5.10.

   I noticed some very odd happenings at the OS level and suspected aç
conflict between BYE and NZCOM.  There were two symptoms: the utilities thatç
check the DRVEC seemed to be pretty solid, but those that checked MAXDRVç
were flaky.  For example, FF (Find File) would not report any files found onç
the highest drive.  If I set the system to sysop access while a user was onç
line, it acted strangely once I would reset back to normal access.  The onlyç
solution was to allow the caller to have wheel privileges for the durationç
of the call.

   Finally, I pulled SHOW down while a caller was on line to see what wasç
going on.  It seems that BYE was resetting the MAXDRV and MAXUSR bytesç
erroneously.  On cold boot, it was giving MAXDRV one less drive thanç
allowed, and MAXUSR one more.  More importantly, once any new environmentsç
were loaded, it put invalid data into these bytes.

   Though I had told BYE not to monitor the maximum DU: settings, it was ç
insisting on doing just that.  Worse, it wasn't doing it right!  See Fig. 1ç
for the CCP settings in the BYE configuration file as used on Socrates.  Beç
aware that ALL system security with these settings is now the purview ofç
NZCOM.  BYE will not monitor anything for you.  Carefully test your variousç
environment settings remotely before leaving the system for public calls. ç
You should look through the PRN file to make sure the proper addresses areç
being assigned, since the addresses will differ from system to system.

   You will notice reference to an include file named Z3BASE.LIB.  You willç
have to generate such a file with definitions for the module addressesç
referenced in BYE.  Fig. 2 shows the Z3BASE.LIB that I use.  You have toç
edit this with your memory configuration before you assemble BYE.  Notes inç
the file will explain.

   So now you have BYE running.  Go on-line and use SHOW to make sure theç
system has stayed the way you want it to.  Use JetLDR to load the various ç
environments we made up before and use SHOW to verify that MAXDRV, MAXUSR,ç
and DRVEC have stayed correct.  Then, turn your WHL on and off while you try ç
wheel-dependent commands such as ERA.  The system should respond correctly.  ç
If you have problems, you need to edit either your Z3BASE or BYE again and ç
reassemble.

   Once you have gotten this far, you are ready to install your BBSç
software.  I use QBBS for a couple of reasons.  It holds messages fromç
different areas completely apart, and it is distributed with full sourceç
code.  It doesn't hurt that QBBS is almost a snap to install.  What is takenç
as a negative by many, that it is written in compiled BASIC, is a plus in myç
mind.  What does a BBS program do?  Basically, it is a text file reader thatç
has to be capable of finding messages quickly.  Other than that, and theç
message editor, a BBS program really isn't that involved.  I will put QBBSç
up against PBBS and HBBS, both written in 100% machine code, in a speed testç
any day of the week.  Also, modifying high level language programs isç
usually easier.  But what you chose is up to you.


MAKE UP YOUR ALIASES

   As I said earlier, part of your system security is that the names youç
give  your environment files must be a secret.  The only way to invoke themç
with a caller on line is to blank out the modem output with BYE's ESC-B, orç
to load them through an alias.  I use the alias method.  If you haven'tç
picked up on it by now, I don't trust BYE farther than I can throw it....

   Here are a couple of example aliases I have.  By the way, don't put theseç
into your ALIAS.CMD file.  I've seen various versions of TYPE that let usersç
type out a $SYS file, and that would blow the secret!

This is the alias to load the normal (secure) system.  It is named NZUSER:

	A0:NZUSER    --> ldr a0:user.env
	                 ldr a0:user.ndr
	                 whl <wheel password> /s
	                 path a0 $$$$ a0
	                 whl r
	                 echo system load done

Now the alias to load the sysop system:

	A0:NZSYSOP   --> if ~wh
                   	   whl /s
	                 fi
                 	 if wh
                   	   ldr a0:sysop.ndr
                   	   ldr a0:sysop.env
                   	   path a0 $$$$ a15 A0
                   	   echo sysop system loaded
                 	 else
                   	   echo access denied
                 	 fi

This alias gives the user a chance to set the wheel in case it is off, butç
will abort if he can't get it set.

   Two questions.  First, why do we load the SYSOP.NDR before we load theç
SYSOP.ENV?  Remember the QUIET flag?  If we reversed the order, the systemç
would report the name of our NDR file to the user.  Second, why do we loadç
the extended path after we load the environment?  Because if we didn't, A15:ç
would be an invalid DU:, and the system would refuse to allow a path to it.

   The alias to load the floppy system is the same as the sysop alias,ç
except it loads the floppy environment.

   The last of what I feel are the essential aliases is called BYE.  Whyç
would I do that?  Again, I don't trust the real BYE to handle systemç
security properly, so I have this alias reset the environment through theç
NZUSER before calling the real BYE.  Of course, rename your real BYE toç
something else, and make it a $SYS file:

	A0:BYE       --> echo one moment please.
	                 nzuser
	                 echo thank you for calling.
	                 echo please call again.
	                 realbye $*


CHOOSE YOUR TRANSIENTS

   You are very close to going on line.  Move MKZCM, SHOW, STAT, yourç
editor, and anything else that allows someone to fool with the system up toç
a safe, high user area.  Most of us use A15: for this.  Set all the ENV andç
NDR files to $SYS status, as well as all NZCOM files and libraries and theç
aliases we made up.  Not only does this keep people from trying things theyç
shouldn't, it also keeps them from downloading them.  What good does it doç
to go through all this to have someone download your NZCOM.LBR with itsç
patched wheel password?

   Time to choose your transient commands.  You will need something for file ç
transfers.  I use ZMD150 and RZMP16.  Something to type out text files?  Iç
use ZLT12.  Something to lock into LBR and ARC files?  I have LUX77B, LUSH,ç
and ZLUX26, none of which I am really happy with.  Gotta work with ARCç
files, like it or not, so that means you need UNARC16.  Don't forget LDIR,ç
and in today's world, ZIPDIR.  Does that about do it?


LET'S GO SEE THE WORLD

   If you've gotten this far, you're ready to start taking calls.  I suggestç
you start by calling it yourself!  Thrash it, bash it, try to break it.  Ifç
you can't, then it is time to tell a few friends.  Give them the sameç
assignment.  Have them do anything they can to crash the system.  If someoneç
can do it, eventually they will, and it might as well be now, done by aç
friend who will tell you how it happened.  Leave the system private amongstç
yourselves for a couple of weeks.  If it still works as it should after thisç
time, go public.  We will all welcome a new RCP/M.

Welcome to the club, sysop!


-----------------------------------------------------------------------------

; ++ CCP Options ++
;
ZCPR2   EQU     no              ; Yes, if running ZCPR/ZCMD/NZCPR (1 or 2)
;
; NOTE: Requires MAC.COM to assemble if ZCPR3 is set YES.
;
ZCPR3   EQU     yes             ; Yes, if running ZCPR3
;
         IF     ZCPR3
        MACLIB  Z3BASE          ; Requires MAC to assemble
         ENDIF
;
; NZCPR/ZCMD/ZCPR all use bytes (at 3DH/3EH/3FH) to store the maximum
; drive, wheel status, and maximum user area.  QBBS pokes these values
; in QBYE which in turn maintains them in low memory bytes.
;
USEZCPR EQU     yes             ; (QBBS = NO, except w/NZCOM. Then, YES)
;                               ;
CHEKDU  EQU     no              ; Yes, if QBYE will monitor MAXDRIV/USER.
                                ;   If using ZCPR/ZCMD/NZCPR, set this NO,
                                ;   since they already do it (saves a lot of
                                ;   code, too).  In either case, QBYE will
                                ;   have the correct values in MAXDRIV/USER.

;Set this equate to your system's ENV address:
NZENV   EQU     0E780h          ; Required for use with NZCOM
                                ; this value will vary on each computer.
                                ; use SHOW to see where your ENV is.
WHEEL   EQU     NZENV+17Fh      ; Location of ZCPR's wheel flag
MAXDRIV EQU     NZENV+02Ch      ; ZCPR location of MAXDRIV byte
MAXUSER EQU     NZENV+02Dh      ; ZCPR location of MAXUSR byte
;

MAXDRV  EQU     'J'             ; Highest drive supported
                                ; NZCOM:  Put this to highest + 1 on system 
                           	; and let the OS control access.
MAXUSR  EQU     15              ; Highest user area
                                ; NZCOM:  Put this to highest on system and
                                ; let the OS control access.
;
; In all cases, set SYSDRV/USR, since the ^B function gives you these
; d/u areas when used to toggle off the user temporarily.
;
;NZCOM:  Set SYSDRV to one more than you really want.

SYSDRV  EQU     'J'             ;#Highest local drive supported
SYSUSR  EQU     15              ;#Highest local user area (0-15)
;
                         -------------------------

Figure 1.  This is a section of the BYE configuration file showing theç
proper settings to use on an NZCOM system.

-----------------------------------------------------------------------------

;Z3BASE.LIB
;
;Last edited: 10 July 89, Lee McEwen
;
;Currently configured for use with:
;  Ampro LB, 64 MB / NZCOM
;  Maximum memory size for use on bbs under bye
;
false   equ     0
true    equ     not false
off     equ     0
on      equ     not off

base    equ     0

;The following values are taken from screen 1 of SHOW:

z3cl    EQU     0DD00H                  ;mcl, multiple command line
z3cls   EQU     203                     ; length of mcl in bytes
expath  EQU     0DCF4H                  ;path
expaths EQU     5                       ; number of path elements
shstk   EQU     0DB00H                  ;shl, shell
shstks  EQU     4                       ; number of shell entries
shsize  EQU     32                      ; size of each shell entry
z3env   EQU     0DB80H                  ;env, z-system environment
z3envs  EQU     2                       ; size of env in records
z3msg   EQU     0DC80H                  ;msg, system message buffer
z3msgs  EQU     80                      ; size of msg in records
z3whl   EQU     0DCFFH                  ;whl, location of wheel byte
z3whls  EQU     1                       ; size of whl in bytes

                         -------------------------

Figure 2.  The part of the file Z3BASE.LIB needed for the assembly of BYE.

-----------------------------------------------------------------------------
            