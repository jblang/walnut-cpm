                                 WSSCRIPT.PAT
                                 ------------
                        Wordstar Super/Subscript Patch
                        for recent Dot Matrix Printers

                                E.Meyer - 7/87


     Wordstar is a fine program, but an old one that dates from the days of 
simple printers; unfortunately, it's often a challenge to get it installed to 
take advantage of all the neat features of recent printers.  One problem is 
that there just aren't enough installable codes; the other is that not all of 
them are fully generic, like the ^Y toggle and the User Codes ^Q/W/E/R.  For 
example, you can install ^A and ^N for any codes you want; but since they're 
"really" intended for alternate pitch, Wordstar will ignore ^N if it wasn't 
preceded by ^A.
     Similarly, ^S is supposed to underline -- but it does it by overstriking 
an underline character, whereas many modern printers have a nicer continuous 
underline that should be used instead, and overstriking will foul up with 
proportional spacing.  (Often the ^Y toggle is sacrificed for this purpose... 
but then, what about italics? color?)

     THE PRESENT PROBLEM relates to super/subscripts.  Wordstar thinks these 
are done by moving the paper down and up (printing up and down), respectively, 
so it has two installable code areas, ROLUP and ROLDOW.  It assumes that the 
ROLUP sequence will start a superscript OR end a subscript, and ROLDOW vice 
versa.  This works with some dot matrix printers, like Okidatas, which have a 
symmetric code sequence that must have been designed with just this in mind.  
But my new printer, and presumably other Epson compatibles, use:
              ESC S 0 - superscript on
              ESC S 1 - subscript on
              ESC T   - either script off!!
After spending a few minutes imagining appropriate punishments for whoever 
designed this, I found that I could go ahead and put in ESC S 0 as ROLUP and 
ESC T as ROLDOW, and superscripts (^T) would work fine... but I'd have to 
avoid subscripts (^V).  This was unacceptable, so I got to work with a 
debugger and figured out a patch to get around it.

                       PATCHING WS.COM AND WSOVLY1.OVR

     The following information gives addresses for Wordstar 3.3.  For versions 
2.26-3.0, WS.COM has MORPAT at 02E0, and ROLUP/DOW at 06BF and 06CF, instead. 
I don't know where the relevant code in the overlay is; you'll have to find 
it, as I did, by searching for the ROLUP/DOW addresses.
     This patch changes the printing code in WSOVLY1.OVR to make the existing 
ROLUP and ROLDOW the codes for beginning superscript and subscript, respec- 
tively; and it creates a new pair of codes in the MORPAT area to function as 
UNROLUP and UNROLDOW.  I found room for these at 02D3 and 02D8; if you already 
have code in the MORPAT area you may have to put them someplace else.
     Use DDT, SID, EDFILE, DU, or your favorite patching utility.

STEP 1.  Install ROLUP, ROLDOW in WS.COM.

     ROLUP    06C5  03   ;this is "ESC S 0" for superscript
              06C6  1B
              06C7  53
              06C8  30

     ROLDOW   06CA  03   ;this is "ESC S 1" for subscript
              06CB  1B
              06CC  53
              06CD  31

STEP 2.  Add "UNROLUP, UNROLDOW" to WS.COM.

   UNROLUP    02D3   00   --->  02      ;this is "ESC T"...
              02D4   00         1B      ;use whatever you need
              02D5   00         54

   UNROLDOW   02D8   00   --->  02      ;for me, this is the same
              02D9   00         1B
              02DA   00         54

STEP 3.  Change print code in WSOVLY1.OVR.

              73FF   LXI  B,06CA  --->  LXI  B,02D3
              7402   LXI  D,06C5
              7405   LXI  H,3AB4
              7408   CPI  14
              740A   JZ   42BD
              740D   PUSH D       --->  MVI  C,D8    ;change 02D3 to 02D8
              740E   MOV  D,B
              740F   MOV  E,C     --->  MVI  E,CA    ;change 06C5 to 06CA
              7410   POP  B
              7411   LXI  H,3AB5
              7414   CPI  16
              7416   JZ   42BD


     Obviously I can't guarantee that you won't have trouble, but I have found 
the patch to work.  You may want to remove it if you ever reinstall Wordstar 
for a different printer, especially a daisy wheel that may be using ROLUP/DOW 
for other things as well.


       ----- Eric Meyer, 427 N. Washington, Bloomington, IN 47401 -----
