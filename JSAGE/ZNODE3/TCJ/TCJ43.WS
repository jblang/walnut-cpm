TCJ #43

                            The Z-System Corner

                                  Jay Sage


   This time my column is going to be quite short.  In response to myç
requests, a number of authors have submitted some very interesting articles,ç
but there has not been enough space to print them.  I want to make sure thatç
those articles are not delayed further.  One of them is on the superb LSHç
history shell by Rob Friefeld, who has contributed quite a number ofç
excellent Z-System programs (SALIAS, VCOMP, and BCOMP, to name a few).  Youç
should not miss that article.

   After working first with the original Z-System history shell (HSH byç
Michael Rubenstein) and then with EASE by Paul Pomerleau, it occurred to meç
that it would be even nicer to have a full-screen history shell.  What Iç
envisioned was bringing the full resources of a wordprocessor to bear on theç
command transcript, so that commands could be easily viewed, modified,ç
reordered, and regrouped.  If the history file were a standard ASCII file,ç
then one could massage the file with a standard editor or even prepareç
'history' scripts in advance for special purposes.

   After seeing the splendid full-screen work Rob Friefeld had done in hisç
SALIAS (Screen ALIAS editor), I asked him if he would take on the task ofç
writing such a history shell.  He did, and he has done a splendid job.  Iç
would, therefore, like to publicly take credit for that all-importantç
management skill of asking the right person to do a job!


                          Software Update Service

   While Echelon was still in business marketing the Z-System, they offeredç
a very nice product called SUS or Software Update Service.  People who haveç
modems and a nearby Z-Node or RCP/M system generally do not have muchç
trouble picking up the latest releases of public-domain Z-System and generalç
CP/M software.  However, for those who do not have modems or for whom theç
nearest Z-Node is an expensive long-distance call, obtaining a full set ofç
Z-System tools or keeping up with new releases is much more difficult.    ç
The Echelon SUS was designed to solve that problem by making the materialç
available on diskette by mail.  It was a disk subscription service, andç
roughly every month subscribers would get a diskette full of public-domainç
software.

   I am happy to announce that SUS is coming back, thanks to the urging andç
energy of Chris McEwen, sysop of the Socrates Z-Node (#32), in Plainfield,ç
NJ.  Chris and Bill Tishey, together with Sage Microsystems East, will beç
offering an even more extensive service than Echelon's.  Bill Tishey, asç
most of you know, has for some time been maintaining a complete catalog ofç
Z-System programs (ZFILESnn.LST) and a compendium of HLP files covering allç
of them.  At frequent intervals, Bill releases an update LBR with all theç
new help files.  Now, in addition to that service, Bill will be puttingç
together diskettes with the software as well as the documentation.

   This means that you will be able to purchase diskettes with the completeç
set of Z-System programs and/or subscribe to a monthly update service.  Billç
and Chris will be handling most of the diskette production; SME will handleç
the orders and bookkeeping and will produce diskettes in the few formatsç
that Chris and Bill cannot handle (8" IBM SSSD, NorthStar hard-sector, andç
Amstrad 3").

   We have not yet worked out all the pricing details for all the options,ç
but by the time you are reading this column, we will have flyers availableç
with all the information.  Just drop me a letter or postcard, or leave aç
message for me in any of the ways indicated in the sidebar to this column,ç
and I will get a flyer to you.  To give you some idea of what we are talkingç
about, a 6-month SUS subscription to a US address will probably be $48 ($8ç
per disk) and a year's subscription $72 ($6 per diskette).  As you can see,ç
we are trying to keep the price very low.  We really want all of you to beç
able to get and use all these wonderful programs.


                          Fully Customizing NZCOM

   My technical topic for this time will be about designing fully customizedç
NZCOM Z-Systems.  I have always been satisfied with the systems that can beç
produced so easily using the MKZCM (MaKe nZCoM) menu-driven utility, and soç
I never really delved into this area very much.  About a week or so ago,ç
however, Dave Goodman brought the problem to me.  He has a NorthStar Horizonç
with an add-on hard disk, and the operating system has a ROM stuck somewhereç
in the middle of the address space.  That left some disjoint blocks of freeç
memory, and Dave really wanted to make use of all the space.  I told him myç
standard answer to that problem.

   In section 5 (especially subsection 5.2.3) of the NZCOM manual, I pointç
out that the NZCOM system is defined by a descriptor file and that this fileç
(with type ZCM) is a pure ASCII file that can be edited with one's favoriteç
text editor.  The manual recommends that everyone make certain changes soç
that the descriptor will properly reflect the user's hardware environment,ç
such as the disk drives available and the characteristics of the system'sç
printer and terminal.

   I did not actually come out and say it explicitly, but there is anç
implication that other values in the ZCM file can also be changed.  Theç
truth is, I believe, that I avoided this subject in part because I was notç
entirely sure which values could and which values could not be changed.  Myç
suggestion to Dave Goodman was that he experiment with designing a customç
memory map for his system, edit the values into the ZCM file, and see whatç
happened when he tried to load it.

   Dave's report back to me, now confirmed by my own experiments on myç
Televideo 803H, indicated that ALL values can be changed.  The onlyç
requirement is that the values provide a memory map with no modulesç
overlapping.  When you use MKZCM to design the system, it takes over theç
responsibility for generating a valid memory map; if you do the designç
yourself, you better be careful.

A Helpful Utility

   This suggests a very nice utility program that some thoughtful soul couldç
contribute to the community.  This utility (let's call it ZMAP) might do aç
number of helpful things.  First, it could display, perhaps in someç
graphical or semi-graphical way, the memory map of a Z-System, the oneç
actually running or one specified in the form of a ZCM or ENV file (andç
maybe even the Z3PLUS descriptor file of type Z3P).  Present utilities, suchç
as SHOW (ZSHOW) and Z3LOC, list the module addresses in a fixed order, notç
in order of increasing memory address.  Thus they are not very helpful inç
determining if there are gaps or overlaps in the map.  Ideally, ZMAP wouldç
flag any such defects or potential defects in the map so that they could beç
corrected before they cause harm.

   The final item on my wishlist -- and this might better be implemented inç
a second, independent program (ZDESIGN perhaps) -- would be a general Z≠
System designer, along the lines of MKZCM but without its restrictions.  Oneç
would be able to specify the order of all the modules in memory and theirç
sizes.  Given the highest memory address available, the program would thenç
figure out and display the memory map.  One should be able easily to alterç
the order of the modules, and one should be able to override specificç
addresses to create gaps if necessary (but not to force overlaps).  Once theç
desired system has been designed, the program should write out a ZCM or ENVç
file for it.  Such a program is a good candidate for implementation with aç
high level language such as BDS Z or Turbo Pascal.  And it sure would haveç
helped me with the experiments that I am about to describe (several mistakesç
resulted in crashes).

My Experiments

   Fig. 1 shows a printout of the standard NZCOM.ZCM file on my Televideoç
803H.  It has already been customized in several ways using MKZCM.  First,ç
it allocates a 4-record VBIOS.  I use a version that fixes the 803's fauxç
pas of clobbering the index registers during BIOS calls and implements aç
check of the Z-System drive vector for BIOS disk-select calls as describedç
in a previous column.  It also has room for a 20-record RCP, which allows meç
to use a full-featured RCP with Carson Wilson and Rob Friefeld's residentç
history shell, CLED (see RCPZRL11.LBR on Z-Nodes).

-----------------------------------------------------------------------------

E606 CBIOS	0080 ENVTYP	E3F4 EXPATH	0005 EXPATHS	D300 RCP
0014 RCPS	0000 IOP	0000 IOPS	DD00 FCP	0005 FCPS
DF80 Z3NDIR	0023 Z3NDIRS	E400 Z3CL	00CB Z3CLS	E280 Z3ENV
0002 Z3ENVS	E200 SHSTK	0004 SHSTKS	0020 SHSIZE	E380 Z3MSG
E3D0 EXTFCB	E4D0 EXTSTK	0000 QUIET	E3FF Z3WHL	0004 SPEED
0010 MAXDRV	001F MAXUSR	0001 DUOK	0000 CRT	0000 PRT
0050 COLS	0018 ROWS	0016 LINS	FFFF DRVEC	0000 SPAR1
0050 PCOL	0042 PROW	003A PLIN	0001 FORM	0000 SPAR2
0000 SPAR3	0000 SPAR4	0000 SPAR5	BB00 CCP	0010 CCPS
C300 DOS	001C DOSS	D100 BIO	0000 PUBDRV	0000 PUBUSR

Figure 1.  The ZCM descriptor file for the normal NZCOM system I use on myç
Televideo 803H computer.

-----------------------------------------------------------------------------

   I decided to be cautious, especially after one of my new system designsç
caused the system to hang, and I made a series of systems, each differentç
from the previous one in a relatively small way.  I am not going to show youç
all the steps along the way but will go right to the most radicallyç
different version.  See Fig. 2.  If you look carefully, I think you willç
find that only the command line buffer (Z3CL) is still in the same place asç
it was in the original system (but it is bigger now).

-----------------------------------------------------------------------------

E606 CBIOS	0080 ENVTYP	E3F4 EXPATH	0005 EXPATHS	D700 RCP
0014 RCPS	0000 IOP	0000 IOPS	D480 FCP	0005 FCPS
D200 Z3NDIR	0023 Z3NDIRS	E400 Z3CL	00FB Z3CLS	E180 Z3ENV
0002 Z3ENVS	E100 SHSTK	0004 SHSTKS	0020 SHSIZE	E280 Z3MSG
E2D0 EXTFCB	E300 EXTSTK	0000 QUIET	E2FF Z3WHL	0004 SPEED
0010 MAXDRV	001F MAXUSR	0001 DUOK	0000 CRT	0000 PRT
0050 COLS	0018 ROWS	0016 LINS	000F DRVEC	0000 SPAR1
0050 PCOL	0042 PROW	003A PLIN	0001 FORM	0000 SPAR2
0000 SPAR3	0000 SPAR4	0000 SPAR5	BA00 CCP	0010 CCPS
C200 DOS	001C DOSS	D000 BIO	0000 PUBDRV	0000 PUBUSR

Figure 2.  A radically reconfigured NZCOM system produced by manuallyç
editing the ZCM file.

-----------------------------------------------------------------------------

   Perhaps you are wondering why I didn't make the most dramaticç
demonstration possible by changing absolutely every address (and perhapsç
size, too).  Well, there was an extra constraint that I was exploring withç
this system.  I am running ZDDOS, and I have specified that the clock driverç
be loaded into the so-called user buffer.  I have even applied the NZCOMç
patch (NZCOMPAT.HEX) that comes with the ZSDOS/ZDDOS package so that whenç
new system configurations are loaded, the clock driver will be reconnectedç
to the DOS automatically without the need for running LDTIM again.

   If you know a lot about Z-System, you will know that there is no suchç
thing as a user buffer!  The user buffer is a special creature of NZCOM; itç
is not defined in the Z-System environment descripter (or -- look closely --ç
in the ZCM file).  How, then, does one determine where this special gap inç
the memory map of an NZCOM system is located?  That is exactly what Iç
wondered myself.  I could have called ZDOS authors Cam Cotrill or Hal Bowerç
and asked them how they infer its location, but I decided to experimentç
instead.  What I found after various trials and errors was that the NZCOMç
patch seemed to be happy and able to find the LDTIM clock module so long asç
the command line buffer stayed in the same place.  Apparently, theç
assumption is made that the user buffer is the memory from 100H above theç
start of the command line buffer up to the real CBIOS (E400 to E5FF in myç
case).

   I did not perform exhaustive tests of this hypothesis.  Let us just sayç
that it is not terribly prudent to try to make use of a 'user buffer' with aç
fully customized system.  It would be wiser to design the system with a gapç
below the CBIOS for the clock driver and to create a version of LDTIM withç
an explicit load address.  The NZCOMPAT patch should be omitted from NZCOMç
if such custom systems are going to be used.

A Few Bugs

   There were a few bugs in NZCOM that surfaced during this testing thatç
suggest that NZCOM.COM was not quite designed to work rigorously and toç
handle the most general system loading situations.  Sometimes I found thatç
NDR modules became empty, and the command search path was rarely preservedç
with these systems.  Code-containing modules, such as the FCP, RCP, DOS, andç
so on, cannot be moved from one address to another.  If their startingç
address changes, the code must be reloaded fresh from the ZRL file.  On theç
other hand, modules that contain data, such as the NDR, shell stack, path,ç
message buffer, and so on, can and should be moved to any new address, soç
long as there is room for the old contents in the new home.  NZCOM sometimesç
failed to do this.  Maybe now that I have uncovered these small problems, Iç
can pass the information on to Joe Wright, and he can fix up the code toç
handle these situations.
                                                                            