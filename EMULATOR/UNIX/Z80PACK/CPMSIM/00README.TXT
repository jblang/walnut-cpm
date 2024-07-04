	How to bring up CP/M 2.2 on the Z80-CPU simulation

The disk image (drivea.cpm in directory disks) contains only the programs
of the CP/M 2.2 distribution. There is no bootable CP/M kernel on the
system tracks, because this would violate the DRI license for CP/M 2.2.
So to bring up CP/M you need a System running generic CP/M 2.2, not a
special one like TRS80 from TANDY, with 1000H as memory base address!

Now first go to your CP/M machine and create a CP/M kernel with MOVCPM.
If you want to run the simulation on a UNIX with small memory model like
Coherent 3.x or Minix, generate a 32KB kernel, else generate a 64KB one.
Then you have to copy the generated kernel to your UNIX filesystem into
the directory srccpm and the filename cpmxx.com, where xx is the size of
the kernel. There are several ways to transfer the file to your UNIX system:

1. Connect both systems with a serial line and use kermit or umodem
   to transfer it.
2. Use one of the public domain or shareware programs, which can read
   CP/M disks on a DOS machine (example: disk22 can read ~120 CP/M
   formats)

Before you can write your CP/M kernel to the system tracks of the
disk image, you have to compile the Z80-crossassembler, which is needed
to assemble the BIOS and boot-loader. Change to directory z80asm
and type make. This should result to a executable file z80asm without
warnings or errors. Move the crossassembler to a directory contained
in your PATH variable, e.g. /usr/local/bin.
Now change back to srccpm and link the appropriate biosxx.asm to bios.asm
and the appropriate bootxx.asm to boot.asm. Please don't mix up
kernel, BIOS and boot of different sizes, always use all the 64KB
modules or the 32KB ones.
Type make to assemble the BIOS and boot loader, and to compile
several C programs.
Type cpmbin cpmxx.com, where cpmxx.com is the name of your generated
CP/M kernel. This should result in a file cpm.bin, which is needed
by sysgen. Now type sysgen, to write cpm.bin, bios.bin and boot.bin
onto the system tracks of the disk image.
If all this steps went without error messages, you can run cpmsim,
which should boot now CP/M from the disk image.

Move the image of the boot disk (disks/drivea.cpm) to a cool and
dry place, and hold magnetic fields, heat, fluids, kids and dogs
far away from it :-). To be seriously, make a backup, if you lose
drivea.cpm, you can't boot CP/M.

Usage of the C programs:

cpmbin:	to convert the CP/M kernel from the format that MOVCPM
	genrates, to MOSTEK binary format.
	input: cpmbin <filename>
	output: cpm.bin

sysgen:	to write the binaries onto the system tracks of the
	disk drive a image.
	input: cpm.bin, bios.bin, boot.bin
	output: bootable CP/M on system tracks of disks/drivea.cpm

format:	to create an empty disk image for the CP/M simulation.
	input: format <a | b | c | d>
	output: in directory disks files drivea.cpm, driveb.cpm,
		drivec.cpm and drived.cpm

receive:This is a process spawned by cpmsim. It reads from the named
	pipe auxout and writes all input from the pipe to the file,
	which is given as first argument. cpmsim spawns this process
	with the output filename auxiliary.cpm. Inside the simulator
	this pipe is connected to I/O-port 5, which is assigned
	to the CP/M device PUN:. So everything you write from CP/M
	to device PUN: goes into the file auxiliary.cpm on the
	UNIX host.

send:	This process is to send a file from the UNIX host to the
	simulator. Type send <filename> &, and then run cpmsim.
	The process writes all data from file into the named pipe
	auxin, which is also connected to I/O-port 5, which is
	assigned to the CP/M device RDR:. You may use this to
	transfer a file from the UNIX host to the simulator.
	Under CP/M type pip file=RDR: to read the data send from
	the process on the UNIX host.

If you use PIP to transfer files between the UNIX host and the
simulator, you can only use ASCII files, because pip uses cntl-z
for EOF! The easyest way to transfer a binary file from the UNIX
host to the simulator is to convert it to Intel hex format. This
may be converted back to a binary file under CP/M with the LOAD
command.
