From: Eldridge.es at PARC-MAXC.ARPA
To:   info-cpm at brl.ARPA
Re:   L80 patch to avoid disk reset
Date: Thu, 8 Mar 84 12:33 PST

The linker "L80.COM" from Microsoft behaves in way that can be annoying.
L80 does a disk reset and relogs the disk every time it accesses a new
.REL file.  This was done so that .REL files from several disks could be
linked simply by inserting the proper disk before entering the name of
the .REL file.  All the relogging avoided the dreaded BDOS ERROR: R/O
that comes from indiscriminately swapping disks.

If you never swap disks, then this behavior just increases the link
time.  This relogging becomes very time consuming when you have a hard
disk with a large directory since CP/M must regenerate the allocation
map every time it resets the disk.  The following patch will eliminate
the unnecessary relogging.

This patch is for Link-80 3.44 09-Dec-81.

A>REN L80.BAK=L80.COM

A>DDT L80.BAK
DDT VERS 2.2
NEXT   PC
2B00  0100

-L2CC
02CC	MVI	C,19
02CE	CALL	0005
02D1	PUSH	PSW
02D2	MVI	C,0D
02D4	CALL	0005
02D7	POP	PSW
02D8	MOV	E,A
02D9	MVI	C,0E
02DB	CALL	0005
02DE	XRA	A

-A2CE
02CE	JMP	02DE
02D1	.

-S395
0395	20	31
0396	20	.

-^C

A>SAVE 42 L80.COM

The patch causes a jump around the disk relogging calls.  The version
number is also changed to 3.441.

If you have been linking files on a hard disk you will be pleased by the
marked increase in speed.  I have not had any problems linking files
using the patched version of L80.  Remember that you cannot swap disks
while you are running the modified version of L80.

George (Eldridge.es@PARC-MAXC.ARPA)
