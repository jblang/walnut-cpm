Thousand Oaks, CA, 02-08-86


These two disks contain a collection of files specifically for the
TurboDOS operating system.  Unless one sneaked by me, I'm the sole author
of all programs, except for some runtime support by Rick Conn (I used
SYSLIB extensively).  Some of the programs are incomplete.

NOTE:
All (c) Copyright notices appearing anywhere in these programs are to be
disregarded.  I no longer have the time or energy to support them in any
way and am hereby placing everything in the Public Domain.  Permission is
hereby granted to REMOVE the copyright notices reading "(c) 19.. ESKAY" or
"(c) 19.. S. Kluger" whenever so desired.  If you make any changes and
redistribute them, all I want is a bit of credit in the code.  Price lists
and requests for money are also to be disregarded.  I am simply too busy
to remove all that stuff myself.

Here is a brief rundown of all files without .DOC.  Please note the following
conditions under which source files can be made usable:
1. I use Rick Conn's SYSLIB version 3.0 extensively.  Just about every 8 bit
   program won't run without it.
2. I also use some homebrew REL files which may not be on here.  If a program
   insists on an unresolved external, look on a previously released SIG/M
   utilities disk with the missing files, or call your friendly neighborhood
   Remote CP/M system.
3. Nothing has ever been tested reliably on any version of TurboDOS prior
   to 1.41, so if it works, you're lucky.  Most programs will run fine
   under 1.42 and up.
4. Many files are squeezed (FILENAME.?Q?)... Find an unsqueezer to make
   then usable.
5. Some files are in libraries (.LBR).  LU version 3.10 will work fine, but
   I don't trust NULU in a non-CP/M environment.
6. Source to NSWPT is not available.
7. All .MAC files for use with M80.  All ASM files for RMAC.  Use of
   Digital Research LINK-80 highly recommended over Microsoft L80!!!


Ok, now to the undocumented files:

ATTREM.*	part of REMDRV.*
BINDEC.A	a binary-to-decimal converter routine (24 bit)
BREAKO.MAC	breaks .O files into individual modules
CBTOD.AQM	CB80 date/time patch
DELALL.MQC	delete all .$$$, .BAK and -PRINT-?.* on drive
DPINST.*	install program for DIRPAT
MASTER
DO FILLB
EMUL.*		NEC V20/V30 8080 emulator. Definitely runs only
		with TurboDOS!
FREE.MAC	display free disk space on all drives
HEXDEC.A	16 bit binary-to-decimal converter
HXDC24.MQC	24 bit binary-to-decimal converter
MENU.*		not quite finished
PD.MAC		display number of used dir entries on disk
RS*.*		reserializer. ideal for distributing OS-extensions
		which must be serialized.
RTDS*.LBR	Remote TurboDos System.  A remote access package.
SUSPEND.*	++
TCHECK.MAC	++ (unfinished)
TL*.*		++ (some unfinished)
TS*.*		++ (unfinished)
UNDATE.REL	ASCII-to-julian date converter
WHO.MAC		++ (unfinished)
WILDEX.MAC	wildcard expansion module
WSPAT.ASM	a wordstar patch

++
The (++) symbol flags files belonging to the UNFINISHED "tShell" system;
a logon/security package designed to outperform all other such packages
currently available for TurboDOS.  Unfortunately, I'll be unable to
continue, so maybe someone else may pick it up, but please leave it in
the Public Domain.

Since I can no longer support any of the programs on the two disks, please
do not use the following address to ask me questions about them:

S. Kluger
271 Rolling Oaks Dr #271
Thousand Oaks  CA 91360
