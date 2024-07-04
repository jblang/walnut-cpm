
        .ARK   for files archived (same as MS-DOS "ARC").
        .LBR   for library files.
        .?Q?   for squeezed files (middle letter is a Q).
        .?Z?   for crunched files (middle letter is a Z).

     A library is a group of files collected together into one file in
such a way that the individual files may be recovered intact.  A library
file can be identified by the "LBR" as the extent of the file name.  LU
(Library Utility) is a CP/M utility used to maintain libraries of files.
LU does not perform any compression.  Because of this, most people will
squeeze or crunch files before adding them to a library if they want to
save space.  If you want to remove the component files (members) from a
LBR file, you should have a copy of LU310.COM, NULU152A.COM, or other
LBR extractor utility.  (LU and NULU are 8080/8085/Z80 compatible.)

     Recently, popular CP/M Public Domain software files and information
files are being distributed using ARCHIVE files.  Archive files are
similar to library (LBR) files, in that they take a logical group of
files and put them together in a single file.  The main difference, is
that the members of the "ARC" or "ARK" file are automatically
compressed.  The compression algorithm chosen is one of three which will
produce the smallest file.

     Archive files have been available to the MS-DOS and PC-DOS areas,
but, and been made useful in the CP/M environment with the introduction
of the "UNARC" program.  The current version is 1.6, and is available
with extensive documentation, and two executable COM files, a 8080/8085
version and a Z80 version.  The Z80 version takes advantage of the
expanded Z80 (and equivalent) instruction set for speed and size, and
therefore is machine dependent.  There is also a modification overlay to
adapt the program to non-standard CP/M 2.2 and 3.0 operating systems,
such as CP/M68k and CP/M emulators.  Programs are available on many
machines to process "ARC" files, the Atari ST, systems running the UNIX,
systems running MS-DOS, and CP/M.

     ARK11.COM is the CP/M utility available to make an "ARK" file.
Archive files may also be made in the MS-DOS/PC-DOS or UNIX environment.
(ARKs made on other systems may produce different results as the CP/M
ARK program -- UNARC16 is able to extract and decompress these files.)
To avoid confusion on RCP/Ms that support both MS-DOS and CP/M callers,
Archive files have a file extension of "ARK" for CP/M software and
information files.

     Some files in the SIMTEL20 CP/M software libraries have been
compressed, using one of the standard public domain utilities, to
minimize download time and to save storage space.

     Files that have been compressed can be identified by the filetype
(the last 3 letters of a filename after the ".") that signifies the
compression.  These are:

        .?Q?   for Squeezed files (middle letter is a Q).
        .?Z?   for Crunched files (middle letter is a Z).

     USQ120.COM is used to unsqueeze, or expand files that have a "Q" as
the middle letter of the filetype.  Such files have been squeezed, or
compressed with SQ111.COM or similar utility.  These programs use
Huffman Encoding to reduce the size of the target file.  Depending on
the distribution of data in a file it can be reduced in size by 30% to
60% by squeezing it.  If you download a file with a filetype indicating
that it is squeezed, you will need USQ120.COM to expand it before you
can use it.  There are other programs available, written in different
languages and take advantage of special hardware, but USQ120 is
8080/8085/Z80 compatible.

     Other utilities are available that have the unsqueeze coding
imbedded and function with squeezed or unsqueezed files.  There are
programs that perform file maintenance functions (NSWP), bi-directional
display utilities (BISHOW), and string search programs, (FYNDE and
FINDU).  This method of compressing files has been used for some time
now and programs to uncompress the files are available to several micro
processors and main frame computers.

     CRUNCH uses the Lempel-Ziv-Welch (LZW) techniques to compress
files. These "crunched" files are identified with a "Z" as the second
character of file type.  This method is fast and offers compression
ratios around 55%.  Highest compression is achieved with graphics data,
values of 90% are typical, followed by text, with 50%, and COM files and
other binary file of around 20%.  See CRUNCH24.LBR for the Z80 CRUNCH
and UNCRunch programs.  See FCRNCH11.LBR for the 8080/8085 and V20
CRUNCH and UNCRunch programs.

     Since this method of compression is relatively new, there are only
a few utilities available that processes crunched files are "typer"
utilities such as TYPELZW, TYPEQZ, LT, and QL which also type members of
libraries and squeezed files.  If running a 8080/8085 processor, check
the documentation to determine if the utility will only process files on
systems using the Z80 processor.  PD1:<MSDOS.COMPRESS>UNCR233.ARC contains
a program to uncrunch files in the MS-DOS/PC-DOS environment.

     MicroSoft BASIC programs are always saved as ASCII files.  (Saved
with the ",A" operand.)  They may than be squeezed or crunched.  This
has been done to allow them to be converted for use with other BASIC
compilers without the need to convert them with MBASIC first.

     Some executable files have a file extension of "OBJ".  These are
really "COM" files that have been renamed to "OBJ" to avoid execution on
RCP/M systems.  Rename them back to "COM" for use them as commands on
your system.


     Below is a list of utilities in the CP/M software libraries that
work with the above mentioned files.  For the current version, check the
directory.

ARK11.ARK         ARK maker for Z80 systems
FCRNCH11.COM      Uncruncher for 8080/8085 systems
UNARC16.COM       Unarcer for Z80 processors
UNARCA16.COM      Unarcer for 8080/8085 CP/M systems
UNCR24.COM        Uncruncher for Z80 processors
USQ120.COM        Unsqueezer for all CP/M systems
NULU152A.COM      Library maintenance utility

Keith Petersen
Maintainer of the MSDOS, MISC and CP/M archives at SIMTEL20 [192.88.110.20]
Internet: w8sdz@TACOM-EMH1.Army.Mil     or       w8sdz@Vela.ACS.Oakland.Edu
Uucp: uunet!umich!vela!w8sdz                          BITNET: w8sdz@OAKLAND
