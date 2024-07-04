Walnut Creek CDROM BBS readme

Opus
--------------------------------------------------------------------------
The \_bbs\opus directory contains the tools that created the
files.bbs file in each subdirectory.  These should be usable with
Remote Access / TubFile / Opus / QuickBbs / Superbbs.

Maximus
--------------------------------------------------------------------------
\_bbs\maxtool contains a utility to copy the files.bbs files to one
directory on your hard disk and create the hcdareas.ctl file that
points to the index files.  A prebuilt control file is in this
directory.  Thanks to Koos van den Hout.

PC Board
--------------------------------------------------------------------------
The \_bbs\pcbtool directory contains the tools used to create the
\_bbs\pcb dir??? files.  It also has a utility to create the global
index file.  Please make backups on your configuration.

RBBS
--------------------------------------------------------------------------
The \_bbs\rbbstool directory has some tools and hints for installing
the cdrom on a RBBS board.  The file listings are in \_bbs\rbbs.
Thanks to Bruce Jackson.

Spitfire
--------------------------------------------------------------------------
The \_bbs\sftool directory has some tools and hints for installing
the cdrom on a spitfire BBS.  The file listings are in \_bbs\sf.

Wildcat
--------------------------------------------------------------------------
\_bbs\wc30 contains a setup program for wildcat, version 3.55.  this
is the commercial version, not the shareware version.  This works
with versions up to and including 3.90.

ALL
--------------------------------------------------------------------------
If you want to show me what your bbs requires for a directory area
display similar to the rbbs display, please send me the exact
specifications.

I produced these with the program "makemenu" in \_bbs\menu.  This
produces a double column listing of the area descriptions based on
\_bbs\dirs.txt.  There are three versions of the directory menu, a
plain version (dir.dir), a IBM high-bit version (dirg.dir), and an
ANSI color version (dirc.dir).

--------------------------------------------------------------------------
A lot of these programs use DOS redirection.  This allows a program
that prints to "standard out" to `redirect' its output to a file or
another program.  If it sends it to another program it goes through a
`pipe'.  For example,

makemenu > out

sends the output of the makemenu program into a file called out.

If I wanted to sort the output of the makemenu command and display it
to the screen, I'd type

makemenu | sort

If I wanted to sort it and sent it to a file, I'd type

makemenu | sort > out

Most of the batch files use redirection.  My utilites write to
standard out so they can be redirected to a file or piped through
another program accepts standard in as input.

-------------------------------------------------------------------------- 

If you set the disc up for your board with features or enhancements
that aren't on the disc, please ftp me a copy to cdrom.com or
snail-mail me a copy and I'll credit your account toward future
purchases.

I'm not a sysop.  I have tried to create file index files that will
be useful for sysops.  Feedback is appreciated.  Prebuilt BBS
configuration files are greatly appreciated.


-jack                          1 800 786 9907
Walnut Creek CDROM            +1 510 674 0783
1547 Palos Verdes, Ste 260    +1 510 674 0821 (fax)
Walnut Creek  CA  94596       velte@cdrom.com (internet)
USA      
