RE:BRADFORD.COM

	This font program for the Epson and Gemini printers is more
than worth the $15.00 the author asks (for the manual).  You will
realize the full capabilities of the program only with the help of
the manual.  The .COM file that is supplied free in the library is
slightly out of date.  The following patches can be used to update
your .COM file if you are going to use this program.  The changes
work on my Kaypro 4-84 and my Xerox 820 with Gemini and Epson dot-m
printers.  Use Patch, DU, or whatever to make changes.

(The address is the actual address of the program when in memory,
 starting at TPA=0100.)


NOTE:  This patch was modified to change the data at 4807 from
       00 to 0A to correct menu format. -Richard Mack- 3/22/86

ADDRESS	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
-------------------------------------------------------
 4800			     0A 0A 0A 0A 1B 3D 34 2F 31
 4810	3D 54 79 70 65 77 72 69 74 65 72 20 32 3D 4D 6F
 4820	64 65 72 6E 20 33 3D 56 61 6E 69 6C 6C 61 20 34
 4830	3D 4E 6F 73 74 61 6C 67 69 63
 4840			     00 0A 1B 3D 35 2F 35 3D 44
 4850	72 61 66 74 20 36 3D 49 74 61 6C 69 63 20 37 3D
 4860	43 6F 6D 70 75 74 65 72 20 38 3D 55 70 70 65 72
 4870	63 61 73 65


Above are the changes you should make to the 142nd record of the
.COM file.  Blanks are unchanged bytes.

ADDRESS	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
-------------------------------------------------------
 4980
 4990
 49A0
 49B0
 49C0
 49D0			  XX
 49E0		   (originally a 20)
 49F0


The above change is made in the 145th record of the .COM file.
Your choices to enter here are: 41, 42, 43, and 44.  This
corresponds to A, B, C, and D, which are your choices of printer
from the selection menu.  Once you get this program running, you
don't change printers, so there is no need to keep answering the
question everytime you use the program.

		---Ed Pierce---
		   14 Mar 86
