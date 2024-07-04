
[Note from Jay Sage:  When I met Terry Pinto in Portland in May, he told me 
about the technique he had developed to overcome the 88 Mbyte limit on the 
Ampro Little Board he uses to run his remote access computer system.  My 
immediate response was, "Please write it up for TCJ!"  And here it is.]


                                86 YOUR 88!
                Discard the 88Mb limit on your Ampro LB Z80

                               by Terry Pinto


     That old saying that "Necessity Is The Mother Of Invention" certainly 
holds true.  After purchasing my Ampro, I noticed that I was limited to a 
maximum of 88Mb of hard disk space.  My feelings then were, WHO CARES!  How 
could I ever fill that much space!  I found a good price on a Priam V150 
60Mb RLL certified hard disk and added it to the system.  Well, you guessed 
it.  It certainly didn't take long to fill up the disk.  I run a BBS, 
Access Programming RAS, and my users were slowly eating away any free disk 
space I had.  The time had come to enlarge the system.  The problem was 
that I couldn't justify the expense of expanding to an 88Mb drive just to 
gain the additional space, and the extra 20Mb was a small addition that 
would disappear rapidly.  The only solution was to engineer a way to 
utilize the fact that the Adaptec 4070 controller I used could support two 
hard disk drives.  I purchased a copy of the source code to the Ampro BIOS 
and set to work writing HDS v1.00 (Hard Disk Select).

     Before explaining how HDS works, a brief description of Ampro's drive 
table is in order.  This table contains the information necessary to relate 
the logical drives to the physical drives on the system and to select the 
driver routine needed for each logical drive.  The table is arranged in 16 
groups of 4 bytes each for logical drives A-P.  The information in byte 2 
is used to select the physical drive on the controller (see Tables 1 and 
4).  Setting bits 7, 6, and 5 to a value of 000 will select physical drive 
0 on the controller while a value of 001 will select physical drive 1.

     Provided that both drives are physically compatible (for example, the 
same make and model) and are partitioned identically, simply changing bit 5 
in byte 2 from 0 to 1 for a given logical drive (partition) will cause the 
system to access (read/write) the drive set up as SCSI drive 1 in place of 
the drive set up as SCSI drive 0.  As you can see, the fact that both 
drives are partitioned the same is VERY IMPORTANT!  The only thing I 
attempt to do with HDS is to tell the controller to use the other hard 
disk.  HDS gives you double the disk space without the loss of any 
additional TPA.

----------------------------------------------------------------------

Drive A   01 00 C6 00    Floppy Drives A-D
Drive B   01 11 C6 00    
Drive C   01 22 86 00    
Drive D   01 33 86 00    
Drive E   02 44 00 FF    Foreign Format Drive E
Drive F   03 50 0A 01    Hard Disk Drives F-P
Drive G   03 60 0A 01    
Drive H   03 70 0A 01
Drive I   03 80 0A 01
           |  |  |  |
           |  |  |  +--- SCSI Address
           |  |  +------ Drive Type Identifier
           |  +--------- Physical Offset and Drive Unit Number
           +------------ Disk Drive ID  0 = Not Installed

Table 1.  Physical Driver Table

----------------------------------------------------------------------

          00 = Reserved for errors
          01 = Floppy Drive
          02 = Foreign Format Drive
          03 = Hard Disk Drive
          04 = Currently Undefined
          05 = Currently Undefined
          06 = Currently Undefined
          07 = RAM Disk (N/Systems)

Table 2.  Values of the Disk Driver ID (byte 0)

----------------------------------------------------------------------
          
          Bits 7654 Offset to base 0-F

          Bits 3210 Physical device address to be passed to the 
                    respective driver.
               
                    (For floppies, this is the drive unit#.  For 
                    hard disks, these are reserved.)

Table 3.  Physical offset from start of disk parameter headers
          and the drive unit number (byte 1).

----------------------------------------------------------------------
     Floppy Usage:
               Bit: 76543210
     Density        X         0=Single 1=Double
     Sides           X        0=Single 1=Double
     Sector#'s        X       0=Same 1=Contiguous
     Track Cnt         X      0=Down 1=Down Front - Up Back
     Alloc Unit         XX    00=1k  01=2k  10=4k  11=8k
     Sector Size          XX  00=128 01=256 10=512 11=1024

     Hard Disk Usage:
               Bit: 76543210
     LUN            XXX       Logical unit number (0-7)
     Reserved          X
     Alloc Unit         XX    00=1k  01=2k  10=4k  11=8k
     Sector Size          XX  00=128 01=256 10=512 11=1024

Table 4.  Drive Type Identifier (byte 2).

----------------------------------------------------------------------

               Bit: 76543210
     SCSI address 0        X  This  is  the  actual  bit  pattern 
     SCSI address 1       X   supplied  during  the  SCSI  select 
     SCSI address 2      X    routine.   No   internal    address 
     SCSI address 3     X     translation or bit scaling is done.
     SCSI address 4    X        
     SCSI address 5   X         
     SCSI address 6  X          
     SCSI address 7 X           

Table 5. SCSI bus address for hard disks (byte 3).

----------------------------------------------------------------------

                              Hard Disk Select

     The Ampro BIOS can be set up to accommodate hard disk space up to 
88Mb. This is due to the fact that a CP/M system can address sixteen 
drives, A-P, of up to a maximum of 8Mb of space each.  Ampro defines drives 
A-D as floppy drives and drive E as the foreign format floppy.  These 
allocations are predefined and cannot be changed, although by using the 
SWAP utility they can be moved around.  For the purposes of this article, 
we will assume that the original drive mapping is intact and that you have 
not used SWAP to redefine the drive parameter tables.  In fact, the use of 
SWAP is not restricted, and you may feel free to swap your drives at will 
either before or after running HDS.

     With five drives being predefined, this leaves us eleven drives of 8Mb 
each, which gives us 88Mb of space.  This will leave a TPA of about 56k.  
If you have elected to size your system to allow 88Mb of space, you may use 
HDS to 'mount' any eleven drives available to the system.  What this means 
is that although you may have 22 logical drives attached to the system, you 
may only define eleven of them as currently active.  This action is 
referred to as 'mounting' the drive.  HDS will allow you to select any 
eleven drives available and make them active on the system.  You may select 
an individual logical drive, a group of logical drives, or an entire 
physical drive.  HDS will accept options passed on the command line 
describing what actions you want to take.

Syntax:  HDS [n|d]  (one option allowed - global select has priority)
              n=logical drive number (global select)
              d=list of drives to select

     When HDS selects a drive from the appropriate hard disk, it toggles
the selection. To reset the drive, you must either reselect the drive, or
do a global select to drive 0. You should either select a global option
or a set of individual drives. If both options are specified, the global
select will occur.

Examples:  HDS fghi  selects drives F,G,H and I from HD 1
           HDS bij   (the drives do not need to be consecutive)
           HDS c     selects drive C from HD 1
           HDS 0     global select to HD 0 (reset).
           HDS       shows map of system

     In the first example above, HDS will attach drives F,G,H and I from 
logical drive 1 to the system replacing their counterparts on drive 0. The 
drives do not have to be contiguous, as the second example shows. In this 
example, drives B, I, and J are attached, replacing their counterparts on 
drive 0.  In the third example, just drive C is exchanged.  In the fourth 
example, a global select is issued to select all drives on logical hard 
disk 0.  This can be used as a quick method of reseting the system. The 
last example, HDS is run without a command line argument. This causes the
system to display a map of the available drives on the system and how they
are selected.

     HDS will monitor both the QUIET flag and the WHEEL byte in order to 
control the display features and to provide system security.  The use of 
the global select function requires that the wheel byte be set, if selected 
during assembly. If the wheel byte is not set, the user is given an illegal 
function error and control is returned to the operating system.  To give 
you a higher level of security, I have provided a bitmap of the drives on 
the system. Setting any of the drives in this bitmap will secure the drive 
and will require that the wheel byte be set to mount that drive.

                         ABCDEFGH IJKLMNOP
Example:  DRVMAP:   DB   01000000 00000000b

     In the example above, drive B has been set as secure.  This means that 
if the wheel byte is not set, the user could not issue a command of 'HDS 
B'. Attempting it would generate the illegal function error and return the 
user to the operating system.

     For use on a remote access system, I've tied the display functions of 
HDS to the QUIET flag.  When the quiet flag is on, no screen output is 
generated during the selection of drives.  This will enable you to include 
HDS in an alias and have it totally transparent to the user.  With the 
QUIET flag off, a signon message will appear each time you run HDS.  The 
same is true for the display function of HDS.  If you call HDS without a 
command line option, it will give you a map of what drives are selected and 
from which physical drive.  Table 6 shows an example of a typical run of 
HDS.
----------------------------------------------------------------------

A0:BASE>HDS
Hard Disk Select v1.03 (c) 05/17/89
Written by Terry Pinto
ZCPR v33   ZRDOS v19   Ampro BIOS v38   PHYTAB D072H
(Type 3 - Loaded at 8000H)
Selected Drives

A - Floppy Drive
B - Floppy Drive
C - Floppy Drive (not installed)
D - Floppy Drive (not installed)
E - Foreign Format Drive
F - Drive 0
G - Drive 0
H - Drive 0
I - Drive 0
J - Drive 0
K - Drive 0
L - Drive 0
M - Drive 0
N - RAM Disk
O - Does Not Exist
P - Does Not Exist

Table 6.  Example of screen display after running HDS.

----------------------------------------------------------------------

     You can see from the output that HDS reads the parameter table to 
determine if a drive is on the system and, if so, what kind of drive it is.  
Notice that all four floppy drives are always defined by Ampro but that on 
this system drives C and D are 'not installed'.  The foreign format floppy 
is drive E and is used for the reading/writing of disks formatted for other 
systems.  The display shows that hard disk drives F-M are defined and are 
currently the drives residing on the hard disk defined on your system as 
being physical drive 0.  Drive N is defined as a RAM Disk (N/Systems) and 
drives O and P do not exist on the system.

     If you select drives FGH and I, you get the output shown in Table 7. 
Notice that the drive identifier for drives F,G,H and I now show that these 
drives are currently attached from the hard disk defined on your system as 
physical drive 1.

----------------------------------------------------------------------

A0:BASE>HDS FGHI
Hard Disk Select v1.03 (c) 05/17/89
Written by Terry Pinto
ZCPR v33   ZRDOS v19   Ampro BIOS v38   PHYTAB D072H
(Type 3 - Loaded at 8000H)
Selected Drives

A - Floppy Drive
B - Floppy Drive
C - Floppy Drive (not installed)
D - Floppy Drive (not installed)
E - Foreign Format Drive
F - Drive 1
G - Drive 1
H - Drive 1
I - Drive 1
J - Drive 0
K - Drive 0
L - Drive 0
M - Drive 0
N - RAM Disk
O - Does Not Exist
P - Does Not Exist

Table 7.  Example of screen display after running HDS a second time.

----------------------------------------------------------------------

     After the selection of the requested drives, it is necessary for HDS 
to perform a disk reset to log in the newly defined drives.  To accomplish 
this, HDS must know what type of DOS you are using.  A check is done to 
determine if you are running vanilla CP/M 2.2, ZRDOS, or ZSDOS.  In either 
case, an appropriate disk reset is called upon to log in the new drives. 
During the check process, HDS also determines if you are running a vanilla 
CP/M or a ZCPR3 system and gets the version number.  This is necessary to 
enable HDS to find the physical tables in your BIOS.  The type of system 
you are running will be displayed during the signon if the QUIET flag is 
off. For now, HDS only detects Z33, Z34, and CP/M operating systems.  
Future versions may include detection of CP/M plus.  

Online examples from Access Programming...

     To enable an easier way for the remote user to use HDS, I've placed
the following alias' in my ALIAS.CMD file. (The case switching symbols
have been eliminated to make the alias a little easier to read).

HDSEL echo;The Following Hard Disk Selections are Available;echo;echo
      AMPRO;echo;MSDOS;echo;ZCPR;echo;SYSTEM;if wh;echo;EXTEND;fi;echo
AMPRO  echo;Loading AMPRO Drivers - Please Wait...;hds 0;hds c
MSDOS  echo;Loading MSDOS Drivers - Please Wait...;hds 0;hds dfghi
ZCPR   echo;Loading ZCPR Drivers - Please Wait...;hds 0
SYSTEM echo;Loading SYSTEM Drivers - Please Wait...;hds 0
EXTEND echo;Loading EXTENDED Drivers - Please Wait...;hds 1

The HDSEL command will display the following selections:

A0:RCPM>HDSEL

The Following Hard Disk Selections are Available

AMPRO
MSDOS
ZCPR
SYSTEM
EXTEND

A0:RCPM>

This give my users an online guide to what is available. Running AMPRO
will attatch drive C from HD 1. This is where all the Ampro specific
file are located on my system. MSDOS will load drives D, F, G, H and I
from HD 1 and allow the users to access the MSDOS programs stored there.
ZCPR and SYSTEM actually perform the same function for now. ZCPR will
grant access to the ZCPR specific files on HD 0. The SYSTEM command will
serve as a system reset. I've made BYE an alias on my system allowing me
to include the command 'HDS 0' in the signoff module. This effectively 
resets my system for the next caller. This allows me to maintain a 
default status so that each new caller will enter the operating system
with the same drives attatched. The EXTEND command selects all drives 
from HD 1 to the system. Much of my commercial software is kept here so
I've set HDS to require that the wheel byte be set to do a global select
to drive 1. I've also set up drive B as a secure drive. This is done by
setting the corresponding bit in the drive bitmap to 1. If HDS detects
the security bit on any drive passed on the command line, access will be
denied.

                            ACKNOWLEDGEMENTS

     Many hours of research have gone into the development of HDS. Release
of this software would not have been possible without the information that
was obtained from the source code of version 3.8 of the Ampro BIOS. Much 
of the information describing the bit selections necessary for HDS were 
quoted directly from the source code listing.

If you would like a copy of HDS or have any questions about the software
or its operation, please contact:

Terry Pinto
Access Programming RAS
14385 SW Walker Rd. B3
Beaverton, OR  97006

(503) 646-4937  6:00pm-10:00pm PST
(503) 644-0900  300/1200/2400 8N1
PCP ORPOR  StarLink 9164/222 (local exchange)
