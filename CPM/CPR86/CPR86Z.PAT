Dennis Vallianos
[70406,1163]
Lindenhurst, NY


CPR860 is a fine addition to CP/M-86, offering a much more
sophisticated user interface than DRI's stock system.  I found
it worked as advertised on the Zenith-100 series, but because
the program was not specifically developed for the Z-100, the
ability to run 8 bit COM files was lost.  The following patches
to CPR860 & several of Zenith's bios modules will correct this
problem.

NOTE: My system is presently running with 192K of RAM & that's
the only memory size I've tested this with.  You may or may not
have problems with less memory.


Starting with CPR860.BIN perform the following patches with
DDT86:

DDT86
rCPR860.BIN

Patch using the S command as follows:

ADDRESS   ORIG       Z100
639	   A0         CD
63A 	   38         DF
63B	   07         02

wCPR860.CMD

The above patch tells CPR how to find the PATHNDLR code in the
bios.

Similarly patch OVL0.BIN:
rOVL0.BIN

Patch using the S command as follows:

ADDRESS   ORIG       Z100
D26	   DF	      DD
D31	   04         0C
D38	   06	      0E
D43	   04	      0C
D49	   06	      0E
D6B	   DF	      DD
DDC	   DF	      DD
DEA	   04	      0C
DF2	   06	      0E
F0C	   DF	      DD
F16	   DF	      DD

wOVERLAY.CMD
^C
The above patch changes the interrupt location used by ZIP to
store the vector normally stored at INT 224.  The change is
required because as supplied, OVL0.BIN will write over INT DFh,
which is used on Zenith systems to enter the bios when trying to
run a COM file.

The files are now able to work with the Zenith bios, except for
a number of addresses the bios knows of in the original CCP.
These addresses will be different when CPR860 is installed over
CPM.SYS.  You will have to educate the bios by editing two of
its files to change these addresses & then reassemble.

Locate the following code in BIOS86.A86:
	ORG	CPMCCP+0939H
DFTDRV	RB	0		;DEFAULT DRIVE

Change the +0939H to +0736H & save the modified file.


The following changes have to be made in PATHNDLR.LIB:

1. Find the following code section & comment it out with ';'
at the beginning of each line (leave the PATCH02: label alone).

PATCH02:
;	IF	R8085
;	LEA	DI,COMFCB+9
;	LEA	SI,COMTYPE
;	MOV	CX,3
;	CLD
;	REP	MOVSB
;	CALL	OPENC
;	JNZ	PATCH02A
;	ENDIF
;	CALL	RESETDISK
;	JMP	JPCOMER

CPR86 has already done this work for you, as well as checking
the required drives/user areas on the search path for both CMD &
COM files!  If it gets this far, CPR has already switched to the
correct du & opened the COM file.

2. Toward the end of the module, a number of locations in the
CCP (soon CPR) are defined.  You must redefine each ORG
statement as follows:

NAME		ORIG ORG	NEW ORG
LOADERR:	06DCH		0539H
GOUSER:		0738H		0620H
COMFCB		0827H		085BH

The first two locations show PATHNDLR where to renter CPR86,
depending on whether or not it was able to successfully load the
COM file.  The last address is used elsewhere in the bios, but
defined here.  Save the modified file & reassemble a new bios &
then a new CPM.SYS, as follows:

[NOTE: IF USING 5" DISKS, YOU'LL HAVE TO WATCH YOUR SPACE WHILE
DOING THIS.]

ASM86 BIOS86 $PZ SZ
PIP CPMX.H86=CPM.H86,BIOS86.H86[v
GENCMD CPMX 8080 CODE[A40]
REN CPM.SYS=CPMX.CMD

At this point you should switch over to the instructions in
CPR860's INSTL0.DOC to complete the merging of CPR860.CMD into
CPM.SYS.				05/25/84
