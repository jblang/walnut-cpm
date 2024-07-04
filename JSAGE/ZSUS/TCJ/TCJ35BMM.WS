TCJ #35
_words in italics_
.h1  main headings
.h2  secondary headings


                                Advanced CP/M
                            ZSDOS and File Systems
                             Bù Bridger Mitchell
                        The Computer Journal, Issue 35
                          Reproduced with permission
                           of author and publisher


.h1 DAWN OF A NEW DOS

Think of it as CP/M 4.0 -- an all-new, feature-packed,
high-performance BDOS replacement for all Z80 computers running CP/M
2.2, ZRDOS, or other compatible dos's.

ZSDOS is its final name -- the cooperative product of Hal Bower, Cam
Cotrill, and Carson Wilson that fuses their initially separate
efforts.  The result is explosive: improved disk function performance,
file datestamping with no reduction in program memory, files
automatically accessible from other directories, and elimination of
some notorious CP/M bugs.  Benefitting from Ten Brugge's P2DOS and
Carson's first forays into Z80DOS, the finely-tuned final product is
fully compatible with BackGrounder ii, NZ-COM and ZCPR34.  And the
authors' thorough, extensive testing means highest quality; we are
unlikely to ever see a ZSDOS 2.2, or 1.9!

ZSDOS is, foremost, an up-to-date DOS.  It fully supports the
established DateStamper standard, and comes with preassembled
relocatable clock routines from the Plu*Perfect Systems library to
read virtually all of the popular (and many obscure) clocks.  And it
breaks new ground, adding BDOS functions to get and set file
datestamps as well as to get and set the system realtime clock.  In
addition to Plu*Perfect's PUTDS, SDD, and DATSWEEP utilities, it is
shipped with some nifty new tools that display files sorted by date
and that automatically copy datestamps.  Best of all, perhaps, is that
the "trim" version of ZSDOS includes datestamping within the BDOS with
no loss of TPA memory (except possibly for BIOS space to hold a clock
routine)!

The "full-up" ZSDOS version adds internal path-searching to the BDOS,
enabling _programs_ to do what until now only the ZCPR command processor has
been able to achieve when loading a command -- scan a path of
directories to locate a needed file.  To do this, it places the
datestamping code in a separate small, relocatable module somewhere --
in or above the user's BIOS, in NZCOM's user buffer area, or in a
resident system extension.

Both versions of ZSDOS provide English-language error messages
complete with the name of the associated file, if one.  Error
reporting is configurable, so that a program can field any errorŠitself, if it chooses.  Other significant features include
noticeably faster warmboots and disk resets on hard-disk machines.

The development team has made upgrading an existing CP/M or ZRDOS
system a snap -- menu-driven installation and configuration utilities
do all the work.  And the documentation is top-notch.

I'm enthusiastic!  ZSDOS boosts CP/M 2.2 computing to a new level of
performance, increases reliability, and makes datestamping available
to every Z80 computer.  If you are a CP/M 2.2 or ZRDOS user, you will
benefit most by upgrading to ZSDOS without delay.  It's
available from Plu*Perfect Systems.

.h1 BackGrounder ii Update

BackGrounder ii, as many readers of Jay Sage's column know, is a
task-switching operating system system extension of CP/M 2.2, ZSDOS,
and ZRDOS.  Simply put, it allows you to switch back and forth between
virtually any two applications programs, literally in mid-sentence!
One reviewer described it as windows for CP/M, other users refer to it
a super-Sidekick (it provides a calculator, notepad, screendump and
background printing).

As TCJ rolls off the press I expect to have BackGrounder ii updated to
full compatibility with ZCPR version 3.4.  This will become the
standard version, and currently licensed users can order
an update from Plu*Perfect Systems.




.h1 FILE SYSTEMS

The main topic for this issue's Advanced CP/M column is file systems.
Operating systems separate the organization and maintenance of a _file
system_ from the storage and retrieval of data on physical media.
Files are most often stored on magnetic disks, and the portion of the
CP/M operating system responsible for the file system is indeed called
the basic _disk_ operating system (BDOS).

In contrast, the lower-level tasks of actually writing data to, and
reading them from, the physical disk is delegated to a _disk driver_,
code that is part of the BIOS -- the basic input/output system that
must know the particulars of the specific hardware of the host
computer.

The separation of file system functions and hardware-specific
functions is fundamental to the design of any major operating system,
and it has far-reaching implications.

First, it makes it possible to use the same programs on different
computers, with different physical disk drives, provided that they run
the same operating system.
ŠSecond, by keeping the logical organization of a "disk" and its
physical realization in separate layers of the operating system, we
can use a wide variety of storage media with the same file system.  A
ram "disk", after all, doesn't spin at 300 rpm, and a cassette tape or
local area network is hardly a conventional disk, either.  Yet, to a
program and the BDOS, a file is a file is a file.

Third, with some extensions of the operating system, it is possible to
mount a _different_ file system on the same computer.  For example,
some FORTH operating systems run on top of CP/M and provide access to
both FORTH file screens and CP/M files.  In a different way, DosDisk
provides direct, transparent program access to MSDOS files in a CP/M
environment.


.h1 FORMAT PROLIFERATION

The earliest CP/M computers had only a single format, the single-sided
single-density 8" IBM "standard", and no provision for anything else.
Then, as a few higher-performance and higher-capacity formats were
introduced, they were hard-coded into the BIOS.  Each new format
required re-coding and reassembly of a new system.

Today, CP/M suffers from a surfeit of physical floppy disk formats.
It seems that every manufacturer felt impelled to put his own label on
yet another non-compatible format, to the point where we have well
over 100 different ways of storing the same file on one 5 1/4" disk!
This has also created something of an identity crisis, because it is
not always possible to unambiguously determine a disk's format by
magnetically reading the data on it.

The most modern BIOSes rise above this morass with flexibility and a
degree of intelligence.  They are able to identify a set of "native"
formats, and automatically adapt themselves to the disk in each drive.
In addition, they allow an external utility to set a drive to a
"foreign" format, one that the BIOS cannot identify from its built-in
data, but is known to the utility.

One such BIOS is the Advent TurboRom, written by Plu*Perfect Systems
for the family of Kaypro computers.  It automatically identifies 11
formats (Kaypro, Advent, Osborne, Ampro, Xerox, etc.).  A companion
program, MULTICPY (sold separately), allow TurboRom-equipped Kaypros
to format disks in foreign formats, and to make exact copies of entire
disks in those formats.  And the TURBOSET utility allow the user to
specify some 90 foreign formats, making nearly every 5 1/4" MFM-coded
soft-sector format disk directly usable on a Kaypro computer.

MULTICPY and TURBOSET use a database (in dBase II format) of physical
and logical disk formats.  Because the database is extensible, new
formats can be added.  At Plu*Perfect Systems we use MULTICPY to
produce distribution disks in many popular formats.  If you have
an unusual one, and can supply the physical and logical disk
parameters and a sample disk, we can probably add it.Š
If your BIOS isn't this up-to-date, it is possible to temporarily
replace its disk driver functions with a special application program
long enough to copy files to or from a foreign format disk.  Such a
program must be written for your specific computer's hardware.  Two
popular utilities of this sort are UniForm (MicroSolutions) and Media
Master (Intersecting Concepts).

You will find a cross-format tool is essential if you need to exchange
data on a format not supported by your computer.  The TURBOSET
approach is the most flexible.  It lets you use the foreign format
disk with any regular CP/M program, just like your native-format
disks.  With the other tools you load the format-conversion utility,
copy the needed file(s) to or from your native-format disk, remove the
utility, and then run your regular programs.

There are a host of challenges that confront the programmer who seeks
to upgrade his or her BIOS to this modern level of performance, and
perhaps we can explore them in another column.  In the remainder of
this issue, however, we will have our hands full covering the file
system and its implementation in the CP/M BDOS.


.h1 FILE STRUCTURE

Every file structure has two key properties -- a method of naming
files, and a method of allocating space for storing data.

Each file has a unique name within the filename space on the disk.
(In CP/M, the filename space is a user number; in MSDOS and UNIX it is
a subdirectory).  With the name are usually a set of file attributes
that may control permissions on access to the file, and perhaps
datestamps as well.

Storage of data for the file is allocated in blocks -- chunks of 128
or more bytes of data.  With each filename the file system associates
an ordered list of blocks, and a total length of the file.

The file system must maintain this information in an orderly fashion
for each file on the disk.  To do so, it uses a _directory_ of
filenames, a _free list_ of unused data blocks, and an _allocated
list_ of blocks in use by the files.

The directory contains (at least) one entry for each filename.  The
entry will usually include permissions or attributes that control
access to the file itself, and perhaps the datestamps for the file.
And it will include some type of link to the file's data blocks.

The free list is some type of data structure that indicates which data
blocks on the disk are not in use and can be allocated for writing
data.  On a fresh disk it will include all blocks of the disk not
reserved for the directory, the boot code, or other operating system
purposes.  As a file is written, blocks are transferred from the freeŠlist to the allocated list and assigned to the file.

.h2 The Allocated List

I haven't said anything yet about how the directory and allocated
list are actually stored.  Those are key choices made by the
designer of the operating system, and it's instructive to
see how they can differ.

In MSDOS, the list of blocks is encoded in a file allocation table
(FAT).  The FAT has an entry for each data block (called a cluster in
MSDOS) on the disk.  An entry indicates that the block is unallocated
(and is thus part of the free list), is allocated to a file, or
is otherwise reserved.

The FAT is encoded in a way that allows it to serve two functions --
it records the allocated and free blocks, and it shows which blocks are
associated with which files.  Blocks that are allocated to one file
form a _linked list_.  Each entry in the FAT is a pointer to the next
block in that file's list, and the last entry is a special end-of-list
mark.

The MSDOS directory entry includes only a pointer to the _first_ block
of the file.  The rest of the blocks are obtained by following the
linked list in the FAT.  The FAT itself is stored on the disk, and the
MSDOS system keeps a copy of it in working system memory.  Thus,
there are two separate data structures on an MSDOS disk -- the FAT
(which is actually stored in duplicate) and the directory.

CP/M takes a different approach -- it includes the storage information
as well as the filename information in the directory entry.  Each
directory entry contains a set of data block numbers and there is no file
allocation table.  To obtain the data blocks for a CP/M file, the
system finds the first directory entry and reads off the block
numbers.

Where is CP/M's free list?  It is implicit in the directory.  When a
disk is logged in, the CP/M BDOS reads through the directory of a disk
and keeps track of each data block that is allocated to a file.  It
encodes this information in an _allocation bitmap_ for the disk,
setting one bit for each block that is in use.  The bits that are not
set then represent the free blocks.

The UNIX system uses aspects of each approach.  Each UNIX directory
entry includes the filename and an _i-node_ number; this is much like
MS-DOS.  An i-node is a list of the first 10 (512-byte) data blocks of
a file, plus links to indirect lists of additional blocks.  Directly
including the list of the first 10 blocks in the i-node (a bit like
including the block numbers in the first CP/M directory entry) allows
UNIX to rapidly retrieve smaller files and yet use linked lists to
extend files to very large sizes.

.h2 How Much Space Left?
ŠOne perennial disaster with many early CP/M programs, famous and
obscure alike, was writing a file to an almost-full disk, running out
of space during the operation, and having the program quit with the
precious data lost forever.  Of course, a well-written program
wouldn't quit when a BDOS error occurs; it would clean up its
incomplete file, allow the user to change disks, reset the disk
system, and re-write the file.

But a really well-crafted program wouldn't even attempt to write to
the almost-full disk.  Instead, before writing, it would determine
whether there is enough space left on the disk to hold the file.

To do this, the program must obtain the total number of free blocks.
This is a natural function for the disk operating system to perform,
and in CP/M Plus there is a system call for this purpose (46).  But it
wouldn't fit into the space on the system tracks of the original 8"
CP/M 2.2 systems, and so the BDOS includes another system call (27) to
return the address of the drive's bitmap, and programs must count up
the free blocks themselves.

Figure 1 show the Z80 routine, get_freek, that returns the number of
unallocated kilobytes of space on the currently logged drive.  It is
portable -- it works under CP/M 2.2, CP/M Plus and even for an MS-DOS
disk when running DosDisk.  The code includes contributions from Jay
Sage, Joe Wright, and others, and is used, in a slightly varied form,
in the SP (space) command in Z3PLUS and NZ-COM.

The routine first determines which version of CP/M is running.
If the system is CP/M Plus, the BDOS will do all of the work.  In
fact, it's necessary to let it do the work, because in most CP/M Plus
systems the allocation bitmap will be stored in a different memory bank
and therefore not readily accessible to the program.  (If the routine
did attempt to use the bitmap address, it would add up bits of
whatever program or data happen to be in that part of the main memory,
resulting in an incorrect value).

CP/M Plus function 46 returns the space remaining on the disk as a
24-bit number in the first three bytes of the dma, in units of
128-byte records.  So, to use this function, get_freek first sets the
dma address to the temporary buffer at 80h and calls function 46.  The
divide-by-8 code then converts this to kilobyte units.

If the routine is running under CP/M 2.2, it first calls function 31
to get several disk parameters for the logged-in drive -- the
block-shift factor, the extent mask, and the maximum number of blocks
on the drive.  Next, it calls function 27 to get the address of the
bitmap (allocation vector).  The code at label "cntfree" then counts the
number of unset bits in the bitmap, accumulating the count in register
DE.

Since each block represents some multiple of 1K (1024 = 2**10 bytes),
the code at label "free2k" multiplies the free block count by the sizeŠof one data block.  The block shift factor is the base-2 logarithm of
the number of 128-byte records per data block.  In other words, it is
the exponent in this equation:

	block size in records = 2 ** block-shift-factor

If the block size is 1K (8 records), the block shift factor is 3
(i.e., 8 = 2**3), and the number of free blocks is already in 1K
units.  Otherwise, we multiply by the number of K in one block; this
calculation is simply a 16-bit left shift that results from doubling
HL (blkshf-3) times.


.h1 A CLOSER LOOK AT THE CP/M FILE STRUCTURE

One CP/M directory entry contains the following components:

	user number - a logical partition of the volume (disk)
	file name
	file attributes
	directory entry number
	size of (the portion of) file indexed by this entry
	the data block numbers for this entry

A single directory entry can hold either 16 8-bit data block numbers,
or 8 16-bit directory numbers.  A CP/M data block can be 1K, 2K, 4K,
or 16K bytes (the blocking factor is part of the disk format
specification), and the large blocks require 16-bit numbers.  So a
single directory entry may refer to a maximum of from 16*1K to 8*16K =
128K bytes of data, depending on the blocking factor for the disk.

Clearly, a file might be larger than the number of bytes that can be
recorded in a single directory entry.  To handle this case, CP/M
creates _additional_ directory entries to hold additional data block
numbers.  These entries have the same filename, user number and
attributes as the initial entry, but they have unique directory entry
numbers.  (Contrast this with MS-DOS, which has just one directory
entry, but a longer linked list of FAT clusters for a large file.)

.h2 Reading a file.

The actual numbering of CP/M directory entries is somewhat torturous, and
so we will discuss it later.  First, let's get a grip on the details.
Assume we already have a large file and consider first what
the operating system does when an application program is reading the file.

First, the program calls the BDOS to open the file named in the
indicated file control block (fcb).  The CP/M BDOS searches for the
initial directory entry, finds it, and stores the entry data,
including the data block numbers, in the user's fcb.

Next, the program repeatedly calls the BDOS to read the file
sequentially from the beginning.  The (CP/M 2.2) BDOS gets the first
data block number from the fcb, converts that value to track andŠsector numbers, and calls the BIOS to read one 128-byte record.  Next,
it increments the sector number (adjusting for reaching the end of a
track) and calls the BIOS again, repeating for the number of records
in a data block (8 in a 1K block, etc.).  It then gets the second data
block number from the fcb, converts to track/sector, and reads another
set of records.

Eventually (after processing 8 or 16 blocks) all of the first
directory entry's data blocks have been used, and the BDOS must search
for and read in the next directory entry.  (At this point, on a
physical disk the movement of the disk heads back to the directory
track can often be heard; this extra motion significantly slows down
access to large CP/M files.)  The BDOS then repeats the process of
computing track/sector numbers and calling the BIOS to read records.


.h2 Writing a file.

Writing a file involves reversing these steps, with a few key
additions, because disk space must be allocated.  Let's assume
our program is writing a new file.

First, the program calls the BDOS to create the file
with the name stored in the fcb.  The BDOS searches the directory
for an empty (unused) directory entry.  It then writes the
new filename into that entry, with zeros for block numbers.

Now consider what the BDOS must do as the program sequentially writes
the file. First, the BDOS must find a free data block on the disk.  To
do this it consults its free list for the disk (the allocation bit
map) and assigns one block to the new file.  It marks that block as
used and puts the block number into the file control block.  Now that
the block number known, the next steps are much like reading -- the
BDOS translates from block number to track/sector numbers and calls
the BIOS to write 128-byte records, until a block is full.  Then, when
a new block is needed, the BDOS gets the next free block from the free
list, and repeats the process.

Eventually, the file control block is filled up with 8 or 16 data
block numbers, and the BDOS must make a second directory entry.  But
before doing so, it "closes" the initial entry by writing the file
control block values to that directory entry on the disk.  Then, it
searches for another empty entry, creates the second directory entry
for the file (with the same name, but a different entry number), and
finally resumes the process of allocating a data block and writing
records.

At last, when the entire file has been written, the program calls the
BDOS to close the file.  Just as it did for the "internal" close of
the initial directory entry, the BDOS writes the data block numbers in
the file control block to the final directory entry on disk.

If an error occurs during the process of writing the file, you may seeŠsome residue of the incomplete process.  Quickie Quiz: Explain how
each of the following might result:

1. Filename in directory, file is shown as 0K.
2. Filename in directory, file is shown as 16K (or 32K or ...),
   but the end of the file is missing.





.h1 INTERNALS OF THE DIRECTORY ENTRY.

Now we turn to the nitty-grity, and it is unavoidably confusing!  It's
also essential if you intend to really understand CP/M files.

The CP/M directory structure is like a tree house that grew as the
kids got bigger.  First it was a simple platform (for CP/M 1.4 files).
Rooms got rebuilt to handle larger files and larger disks, and the
file control block got extended to provide random access (CP/M 2.2).
And small passageways were crammed with filesize, datestamps, and
passwords (CP/M 3).

Some of the confusion is simply terminological.  One directory entry
is 32 bytes of data. Sometimes it is also called a physical directory
extent -- "physical" because it refers to actual bytes on the disk.
Whenever you see this topic discussed, read carefully -- I suggest you
translate all references from "physical extents" to "directory entries",
and reserve the term "extents" exclusively for "logical extents,"
which we will examine soon.

The directory entry has several fields, shown in Figure 2.  The
information is densly packed.  You can look at an actual sector, which
contains 4 directory entries, with the DU (or DU3) utility, or by
running the following bit of code under a debugger and then displaying
the default buffer at 0080h.

	ld	c,11
	ld	de,5C
	ld	a,3F
	ld	(de),a
	call	5
	rst	38

Byte 0 of a directory entry (labeled "u") is the file's user number.
A value of E5 hex indicates that the entry is unused.  Otherwise, it
can have a value of 0 to 31 in CP/M 2.2.  In CP/M Plus user numbers
are restricted to 0 to 15, and higher numbers indicate special
datestamp, password, and volume label entries.

Bytes 1-8 are the filename and bytes 9-11 the filetype.  They must be
uppercase, 7-bit letters, numbers, or a few other symbols. Each of the
11 high (eighth) bits of the filename and filetype are fileŠattributes.  Attributes 5-11 are reserved for the system to designate
files are read-only, archived, and so forth.

The next four bytes encode the entry number and the length of the
file.  They will get our full attention in a moment.

Bytes 16-31 (10h-1Fh) are where the data block numbers are stored.
These are either 16 1-byte values, or 8 2-byte values, depending on
the disk format.  If there are no more than 255 (FF hex) block numbers
on a disk (for example, on a single-sided single density disk), it's
possible to use 1-byte values.  Otherwise, 2-byte values are needed.


.h2 The directory entry number.

Now, had the tree house been built in one day, the directory number
would be a 16-bit word. Instead, we have to climb through some tangled
vines.  So, hold on!

The CP/M file system has two fundamental units of measurement:

	1 record = 128 bytes
	1 logical extent = 128 records = 16K bytes

Records and logical extents are numbered sequentially, beginning with
0.

Now consider a 17K file, with copies on several types of disks.
Things might look like this.

On Disk #1, 16K of data blocks fill up one directory entry.  Then one
entry corresponds to one logical extent.  The 17K file will have
2 logical extents, and 2 directory entries.

On Disk #2, 32K of data blocks fill up one directory entry.  (How
might this occur?  Suppose a block is 4K, and block numbers are 2-byte
values. 8*4K = 32K.)  Now, one entry can hold two logical extents.
The 17K file will have 2 logical extents, but only one directory
entry.

CP/M keeps track of logical extents with the EXtent byte, which
can hold 0 to 31 (0 to 1F hex). After 31, it must again be 0.

Why, you may well ask, does CP/M not allow more than 32 extent values
in this field?  Well, the tree house architect wasn't that farsighted.
In the directory search functions, the BDOS uses a '?' character to
indicate a "wild-card" search.  When a '?' appears in the EXtent byte
of an fcb, the BDOS will match any extent number.  And since the '?'
byte is 3F hex = 00111111 binary, only 5 bits are available to number
logical extents!

If five bits were indeed all that is available, CP/M files would be
restricted to a maximum size of 32*block size.  To allow larger files,Šthe tree house added the S2 byte.  It holds the "overflow" from the
EXtent byte.  Each unit of S2 thus represents 32 logical extents, and
the the S2 byte can take a value from 0 to 3F hex.

The full logical extent number is, therefore obtained by combining
the EXtent byte and the S2 byte as follows:

	log_ext = (EXT & 1Fh) + ((S2 & 3Fh) << 5)

(I use the c language operators: '&' is bitwise and, '<<' is shift-left).

Note well that the high-order bits must really be masked; while the
directory entry is active in the fcb, the BDOS uses the higher bits of
the EXTent and S2 bytes for internal BDOS flags.

Now, what is the directory entry number (the "physical extent")?  It is
the logical extent number, divided by the number of logical extents
per directory entry.  And that depends on the format, information that
is _not_ in the directory, but in the BIOS's data structure for the
drive -- the disk parameter block (dpb).

	entry_no = log_ext / extents_per_entry

The _extent mask_ byte in the dpb encodes the number of logical
extents per directory entry.  Its value is

	extent_mask = 2 ** extents_per_entry - 1

A strange, but handy, representation, because it gives the number of
times to right-shift the log_ext value to calculate the directory
entry number.  And, simultaneously, it is a bitmask that, applied to
the EXTent byte, yields the number of logical extents within
the current directory entry that are in use.

	entry_no = log_ext >> extent_mask

	         = ((EXT & 1fh) >> extmask) + ((s2 & 1fh) << (5 - extmask))


.h1 FAST FILESIZE COMPUTATIONS.

How big is a file?  What is its size in records, or equivalently, what
is the record number of the file?  It is the record count in the last
directory entry (the number of records in the final logical extent),
plus the size, in records, of all prior extents.  Since the RC byte
may be 80 hex, we must mask it.  The formula is:

	recno = log_ext << 7 + (RC & 7Fh)

Before considering practical answers to that question, let's consider
how large a record number can ever be.  The record count is 7 bits, the
EXtent byte is 5 bits, and the S2 byte can be 6 bits, a total of 18
bits.  The largest possible record number is therefore 2**18.  SinceŠthere are 8 = 2*3 records in 1 kilobyte, the maximum filesize is 2**15
K = 32 MB, a large file indeed!

This is the limit under CP/M Plus and ZSDOS.  Regular CP/M 2.2, however, 
limited the record number to a 16-bit quantity (with the largest S2 value
being 0F hex), and thus a maximum filesize of 4 MB.  And I'm afraid
most CP/M application programs expect that limit not to be exceeded.

We can determine a file's size in several ways.  BDOS function 35 will
return the filesize in the random record number field of the fcb.
This is the easiest method; the BDOS does all of the tedious
arithmetic, and the random record number field is 3 bytes, so it will
hold a full 18-bit record number, should we ever have a file so huge.
But it's slow, because the BDOS must search the directory from the
beginning each time it is called.

A second method is to have the program read the complete directory,
storing the directory entries for the file as it goes, and then
find the last one.  This is no faster for a single file, but it is
a clear winner if the program is reading the complete directory anyway
(in order to display it, for example).  In this case, the file size
calculation is made after the entries are stored and sorted by entry
number (as well as alphabetically, perhaps).

.h2 A single file's size

Often enough, a program needs a file's size as an adjunct to other
file operations.  In this situation, the file can first be opened, or
searched-for, and then its size quickly computed from the directory
entry data.  Figure 3 shows the routine, get_filesize, to perform this
service.

If the file has only one directory entry, all of the information
needed to calculate its size in records is available in the EXtent,
S2, and RecordCount bytes returned in the fcb by an open call, or in
the dma buffer by a search-first call.  The routine first checks that
that the fcb information is, indeed, for entry number 0.  It then
determines that there are no others by checking the record count,
because if it is 80h (128), the entry is full, and there may be
another one.

If all of these tests get passed, it calculates:

	records = RecordCount + 128 * number of prior logical extents

Otherwise, it calls the BDOS, which returns the number of records in
the random-record number field of the fcb.

The get_filesize routine returns the filesize as a 3-byte value in the
A, H, and L registers.  Except for very large files, A will be zero,
and the filesize can be used as the 16-bit value in the HL register pair.

Š.h2 A list of file sizes

What if you need to get the sizes of several files?  If your routine
has a lot of memory available to hold a large list of directory
entries you can process them in a single batch.  But in some
applications memory must be conserved.  The routine might be just a
small part of a large program that need memory for other functions.
Or perhaps it is a component of a Z-System resident command processor
that wants to keep the TPA intact for the next GO command.

The most basic directory routine looks like this:

	set fcb to a wildcard mask
	set dma to a buffer
	search-first
	  if not found, quit
loop:	if entry number is 0, display entry at offset in buffer
	search-next
	  if found, loop

How can we add the fast filesize calculation to this routine?  Here's
the sketch of the approach I used in the DIRectory command built into
BackGrounder ii , and also later in JetFind.  That command must be
able to run when a regular program has been suspended, without
molesting that program's memory.  This is the special challenge.

We plan to modify the "loop" line to be:

	if directory-entry is not full, calculate filesize from entry.
	else use BDOS function 35.

Hmmm.  Initially, this looks like it would be ok.  In fact, we're in
trouble as soon as it's necessary to use the BDOS filesize function,
because that call will change the BDOS's internal directory pointers
and mess up the next search-next call.  This requires some discussion.

The BDOS search-first/search-next functions are unlike any other file
functions, in that they are logically a single function that is called
repeatedly at two entry points.  This operation says, in effect: Find
the first entry in the directory matching the supplied fcb and return
it in the dma buffer.  Thereafter, when entered at the search-next
point, continue the search for the next matching entry.

The BDOS uses internal pointers to keep track of both the fcb and
where it is in the directory search, and it presumes that there will be
no intervening file operations except more search-next calls.

But, with some cleverness, we can get modify our routine further to
get around this complication.  After making the BDOS 35 call, we do a
search-first call for entry 0 of that file.  This resets the internal
pointers to the spot where the previous search had last matched.
Then, we search-next for the next entry.
ŠThe routine now looks like this:

	set fcb to a wildcard mask
	set dma to a buffer
	search-first
	  if not found, quit
loop:	If directory-entry is not full, calculate filesize from entry.
	Else
		call BDOS function 35
		set fcb to last-found entry
		search-first
	search-next
	  if found, loop

.h1 What's next?

File systems are a big topic, we're out of space, and coding the
little directory routine must be left as "an exercise for the reader."

I appreciate your comments and welcome suggestions for future columns.
Topics I have in mind include stack and interrupt management and
environmentally-aware programming.  What else would you like to see?
Drop me a line at Plu*Perfect!



		   Figure 1.  Free Space on a Disk
	           _______________________________


bdos	equ	5
tbuff	equ	0080h


; Enter:	a  = drive (0=A:, ..., 15=P:)
; Exit:		hl = free space on drive, in Kilobytes
;
get_freek:
	ld	(spacedrv),a	; save drive
	ld	e,a
	ld	c,14		; BDOS select disk function
	call	bdos
;
; check for CP/M Plus
;
	ld	c,12		; get bdos version
	call	bdos		; if not cp/m 3 system
	cp	30h
	jr	c,dparams	; ..jump to calculate from alv
;
; calculate free space for CP/M Plus
;
	ld	de,tbuff	; set default dmaŠ	ld	c,26
	call	bdos
	ld	c,46		; get disk freespace
	ld	a,(spacedrv)
	ld	e,a		; ..on this drive
	call	bdos
;
; Disk space is returned by CPM+ at dma for 3 bytes.
;
	ld	hl,(tbuff)	; Low to L, Mid to H
	ld	a,(tbuff+2)	; High to A
	ld	b,3		; Divide by 8 (SHR 3)
;
; Shift everything right into HL (64 MB max reportable)
;
div:	or	a		; Clear carry
	rra			; High
	rr	h		; Mid
	rr	l		; Low
	djnz	div
	ret			; hl = space free in Kbytes

;
; For CP/M 2 use this method:
;
dparams:
	ld	c,31		; BDOS get disk parameters function
	call	bdos
	inc	hl		; point to block shift-factor byte
	inc	hl
	ld	a,(hl)		; Get value and
	ld	(blkshf),a	; ..save it
	inc	hl		; point to max data block number
	inc	hl
	ld	a,(hl)
	ld	(extmsk),a	; save it 
	inc	hl
	ld	e,(hl)		; Get (word) value into DE
	inc	hl
	ld	d,(hl)
	inc	de		; Add 1 for max number of blocks

; Compute amount of free space left on disk

dfree:	ld	c,27		; BDOS get allocation vector function
	push	de		; Save BLKMAX value
	call	bdos		; Get allocation vector into 
	ld	b,h		; ..BC
	ld	c,l
	pop	hl		; Restore BLKMAX value to HL
	ld	de,0		; Inititialize count of free blocks
Š; At this point we have
;	BC = allocation vector address
;	DE = free block count
;	HL = number of data blocks on disk

cntfree:
	push	bc		; Save allocation map ptr
	ld	a,(bc)		; Get bit pattern of allocation byte
	ld	b,8		; Set to process 8 blocks
;
cnt2:	rla			; Rotate allocated block bit into carry flag
	jr	c,cnt3		; If set (bit=1), block is allocated
	inc	de		; If not set, block is not allocated, so
				; ..increment free block count
;
cnt3:	ld	c,a		; Save remaining allocation bits in C
	dec	hl		; Count down number of blocks on disk
	ld	a,l		; if down to zero
	or	h
	jr	z,cnt4		; ..branch
	ld	a,c		; Get back current allocation bit pattern
	djnz	cnt2		; Loop through 8 bits
	pop	bc		; Get ptr to allocation vector
	inc	bc		; Point to next allocation byte
	jr	cntfree		; Process next allocation byte

cnt4:	pop	bc		; clear stack
	ex	de,hl		; Free block count to HL
;
	ld	a,(blkshf)	; Get block shift factor
	sub	3		; Convert to log2 of K per block
	ret	z		; Done if 1K per block

; Convert for data blocks of more than 1K each

free2k:	add	hl,hl
	dec	a
	jr	nz,free2k
	ret			; HL = amount of free space on disk in K
;
spacedrv:ds	1
blkshf:	ds	1
extmsk:	ds	1




		  Figure 2 . A CP/M Directory Entry
                  _________________________________


            + user number           +----EXtent byteŠ           /                       / +---S1 byte
          /                       / / +--S2 byte
         /     filename   type   / / / + record count
        / --------------- ----- / / / /
00     u f i l e n a m  e t y p x 1 2 r
10     - - - - - - - -  - - - - - - - -  data blocks





		Figure 3.  Calculate a Single Filesize
	        ______________________________________

;
; Enter:	de -> fcb (36 bytes), freshly opened or
;		      copied from search-first buffer
;		extmsk contains extent mask for file's drive
;
; Exit:		a,hl = 24-bit file size value in 128-byte records
;
get_filesize:
	ld	hl,12		; point to EXtent byte
	add	hl,de
	ld	a,(extmsk)	; if not directory entry #0
	cpl
	and	(hl)
	jr	nz,g_rd		; ..call bdos
	ld	b,(hl)		; save logical extent #
	inc	hl		; point to S2
	inc	hl
	ld	a,(hl)		; or if overflow into S2
	and	7fh		; (not directory entry #0)
	jr	nz,g_rd		; ..call bdos
	inc	hl		; or if Record Count
	ld	a,(hl)
	cp	80h		; ..is full
	jr	z,g_rd		; ..call bdos
;
; calculate filesize from fcb data
;
	ld	l,a		; hl = rec. cnt. of last log. extent 
	inc	b
	ld	de,80h		; + 80h = size of each prior log. extent
	ld	h,d		; h = 0
	jr	g_dj
g_lp:	add	hl,de
g_dj:	djnz	g_lp
	xor	a		; clear high bits
	ret
;
; call bdos to calculate filesizeŠ;
g_rd:	push	de		; save fcb ptr
	ld	c,35		; call bdos for filesize 
	call	bdos
	pop	de
	ld	hl,33		; point to random record #
	add	hl,de
	ld	e,(hl)		; get it
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)		; high bits to A
	ex	de,hl		; low 16 bits in HL
	ret
;-------------

[This article was originally published in issue 35 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1988, 1991 Socrates Press and respective authors]
