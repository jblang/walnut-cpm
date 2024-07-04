Odd/Even: Two sided printing with WordStar and NewWord
     by Randy Brook, 13742 41st Av. NE, Seattle, WA 98125
Version 1.1     11/3/85

This file explains how to modify WordStar versions 3.0 and 3.3 
(CP/M) and NewWord version 2.x (CP/M) to print double sided 
documents on continuous form paper.  Great for long documents.  
Credit for the basic coding idea goes to Chuck Somerville.

These patches assume you are using the CP/M list device for sending 
output to your printer.  This is the norm for standard printer 
installations available through WordStar's and NewWord's 
installation menus.  If you are using a custom printer driver, you 
will need to adapt these patches to fit your driver.

The principle of the patches is very simple.  Characters directed to 
the printer are intercepted by the new code.  A "flag" byte 
determines whether the character will then be sent on to the 
printer.  When the flag is 00h, no characters are printed.  When 
it's 01h, they are printed.  When a form feed is intercepted, the 
flag byte is toggled (i.e. from 00h to 01h or vice versa).  Thus, 
two version of the main program (*.COM) are necessary.  In one the 
flag starts at 00h; in the other it starts at 01h.  When printing, 
the "Use form feeds?" question must always be answered yes.

Assuming your disk has the room, you can put both modified program 
versions on the same disk.  You will only need one set of the 
overlays.  The modified programs will function  normally in all 
respects (except printing), and you can use either for creating or 
editing documents.  [One minor variation:  If you use the "R"un 
command, the "Press any key to return to WordStar/NewWord" feature 
will misfunction.  It looks for the .COM file as it was named when 
you installed the program (eg. WS.COM, NW.COM).]

To use the modified programs, run the odd .COM file, print pages 
1,3,5, etc., turn over the continuous form paper, and run the even 
document.  Restart the program for each document, to ensure that you 
reinitialize the flag byte properly.  REMEMBER:  You must "Use form 
feeds - Yes" when printing.

I recommend a trial run for practice.  I found with NewWord, for 
example, that I get an extra blank page (form feed sent to printer) 
when I start printing the even pages, so I have to adjust by 
starting my odd print after rolling an extra blank page through my 
printer.  With WordStar, I get an extra page with both odd and even.

Note that this patch runs faster with NewWord than with WordStar.  
This is because WordStar's printer driver is just plain slow.  For 
example, it cannot keep up with my printer (200 cps), while NewWord 
even works with the HP laser jet.  Similarly, WordStar is much 
slower than NewWord in skipping over the non-printing pages.

                             DIRECTIONS

1.  Use a disk with NewWord or WordStar on it.  You will need the 
overlay files to test your results, but you will not need the 
WordStar or NewWord Install program.  You will also need DDT.COM.

2.  Load the .COM with DDT. 

         NW                 WS 3.0                   WS 3.3
        ----                ------                   ------
     A>DDT NW.COM        A>DDT WS.COM             A>DDT WS.COM
     DDT VERS 2.2        DDT VERS 2.2             DDT VERS 2.2
     NEXT PC             NEXT PC                  NEXT PC
     3500 0100           3F00 0100                4600 0100

I'll save you a little arithmetic:  NewWord is 52 "pages," WordStar 
3.0 is 62, and WordStar 3.3 is 69.  

********************  NEWWORD VERSION 2.X  ***********************

     (User listings for "Version 2", tested with version 2.16)

3.  Verify that the area chosen for the patch is unused and that the 
print/noprint flag will start at 00h:

     -S0431
     0431 00   .    (you type the period to end this function)

If you see anything other than the "00", you will probably have to 
relocate the patch (see Technical note to paragraph 5 below).

4.  Assemble a jump instruction in the place NewWord checks for 
special printer routines.  NOTE: The parentheticals aren't typed.  

     -A056D         (assemble the jump patch in subroutine)
                    (   ULOSTO in the User Area Listing)
     056D JMP  0432 (go to the special printer routines)
     0570           (hit RETURN to end this assembly)          

5.  The special printer routine:

     -A0432         (start point of new code, at start of)
                    (  MORPAT in the User Area Listing)
     0432 MOV  E,A  (char in E register for BDOS call)
     0433 CPI  0C   (is char a form feed?)
     0435 LDA  0431 (load the print/noprint flag)  
     0438 JNZ  0440 (char not a form feed, skip next step)
     043B XRI  01   (is form feed, toggle print/noprint flag)
     043D STA  0431 (put flag back)
     0440 ORA  A    (check if "print" or "noprint")
     0441 RZ        ("0" flag is noprint, return from subroutine)
     0442 MVI  C,05 (flag was print, BDOS print function #5)
     0444 CALL 0005 (call for print driver)
     0447 RET       (return from subroutine)
     0448           (hit RETURN to end this assembly)
       
Technical note:  I have placed this routine at the beginning of the 
MORPAT area, since it is generally unused.  There are 64 bytes 
available in MORPAT.  The new code uses only 23 bytes, and can 
easily be relocated elsewhere in MORPAT (or in CRTPAT, which also 
allows 64 bytes) if necessary to find other unused space.

6.  Leave DDT and save the modified NewWord:

     -G0            (exits to CP/M)
     A>SAVE 52 NWEVEN.COM   

You now have a new NewWord .COM file, just for printing even 
numbered pages.  

7.  Create a NewWord file for printing odd numbered pages.  First 
repeat step 2, this time loading the modified file:

     A>DDT NWEVEN.COM

Now repeat step 3, but this time set the print/no print flag to 
start at 01h:

     -S0431
     0431 00   01   (change this flag to 1)
     0432 *    .    (ignore whatever appears at the *)
                    (   the period ends this function)
     
Finally, repeat step 6, saving the new file:

     -G0            (exits to CP/M)
     A>SAVE 52 NWODD.COM   

****************************  WORDSTAR  **************************

3.  Verify that the area chosen for the patch is unused and that the 
print/noprint flag will start at 00h:

     -S0320
     0320 00   .    (you type the period to end this function)

If you see anything other than the "00", you will probably have to 
relocate the patch (see Technical note to paragraph 5 below).

4.  Now assemble a jump instruction in the place WordStar sends a 
character to the printer.  NOTE: The parentheticals aren't typed.  

  WS 3.0           WS3.3                  Explanation
-------------    ------------- -------------------------------
-A071D           -A071C        (assemble the jump patch at)
                               (   LISEND in User Area Listing)
071D JMP 0321    071C JMP 0321 (go to special printer routine)
0720             071F          (hit RETURN to end this assembly)          




5.  The special printer routine ["*" means same as for WS 3.0]:

  WS 3.0           WS 3.3        Explanation
-------------    ------------- ------------------------------------
-A0321           *             (start point of new code, near top)
                               ( of MORPAT in User Area Listing)
0321 MOV E,A     *             (char in E register for BDOS call)
0322 CPI 0C      *             (is char a form feed?)
0324 LDA 0320    *             (load the print/noprint flag)  
0327 JNZ 032F    *             (char not form feed, skip next step)
032A XRI 01      *             (is form feed, toggle print/noprint)
032C STA 0320    *             (put flag back)
032F ORA A       *             (check if "print" or "noprint")
0330 JZ  0723    0330 JZ  0722 (flag is noprint, ret. for next char)
0333 MVI C,05    *             (flag was print, BDOS function #5)
0335 JMP 0720    0335 JMP 071F (back to print driver)
0338             *             (hit RETURN to end this assembly)

Technical note:  I have placed this routine near the end of the 
MORPAT area, past the point likely to be taken up by custom screen 
drivers (eg. memory mapping routines).  There are 128 bytes 
available in MORPAT, starting at 02E0h (WS 3.0) or 02CBh (WS 3.3).  
The new code uses only 24 bytes, and can easily be relocated 
elsewhere in MORPAT if necessary to find unused space.

6.  Leave DDT and save the modified WordStar:

     -G0            (exits to CP/M)
     A>SAVE ** WS-ODD.COM  
** Use 62 for WS 3.0 or 69 for WS 3.3.

You now have a new WordStar, just for printing odd numbered pages.  

7.  Create a WordStar file for printing odd numbered pages.  First 
repeat step 2, this time loading the modified file:

     A>DDT WS-ODD.COM

Now repeat step 3.  This time start the print/noprint flag at 01h:

     -S0320
     0320 00   01  (change this flag to 1)
     0321 *    .   (ignore whatever appears at the *)
                   (   the period ends this function)
     
Finally, repeat step 6, saving the new file:

     -G0            (exits to CP/M)
     A>SAVE ** WS-EVEN.COM
** = 62 for WS 3.0, 69 for WS 3.3.
