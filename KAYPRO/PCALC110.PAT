        PATCHING PERFECT CALC v1.10 FOR KAYPROs WITH GRAPHICS MONITORS
                                       by
                                   Bob Stein
                                     3-3-88

Perfect Calc was bundled with many of the earlier Kaypros, before the advent
of the monitor capable of displaying reverse video.  Many of the original
owners of Kaypro IIs went on to 4s and 10s, yet continued to use Perfect Calc.
Unfortunately, there was no way to utilize the reverse video because Kaypro
disabled the terminal-configuration routine in the version of PCCONFIG.COM
that they supplied.

However, it is possible to patch Perfect Calc to display the axes in reverse
video, and to make the cursor (cell marker) a reverse video block instead of
<   >, using DDT.  Be sure that you have a backup copy of PC.OVL, which is the
file that must be patched, just in case!

Since this patch will work only with version 1.10 of Perfect Calc, check the
version you are using by loading PC; note the version number in the sign-on
message which appears before the cells are displayed.  If it is not VERS 1.10,
stop and forget the whole thing!

To start, put your Perfect Calc program disk in drive A and a disk containing
DDT.COM in drive B.  Log onto drive A and perform the following steps:

     You Enter           Computer Displays      Remarks
     ---------           -----------------      -------
     B:DDT PC.OVL<cr>    DDT VERS 2.2
                         NEXT PC
                         8600 0100
                         -                      - is the DDT prompt
     S844A<cr>           844A 00
     1B<cr>              844B 00
     42<cr>              844C 00
     30<cr>              844D 00
     1B<cr>              844E 00
     42<cr>              844F 00
     31<cr>              8450 00
     <cr>                8451 00
     <cr>                8452 00
     <cr>                8453 00
     <cr>                8454 00
     1B<cr>              8455 00
     43<cr>              8456 00
     30<cr>              8457 00
     1B<cr>              8458 00
     43<cr>              8459 00
     31<cr>              845A 00
     .<cr>               -                      Type a period and <cr>
     Ctrl-C              Warm Boot
                         A> or A0>
     SAVE 133 PC.OVL     Delete File?
     Y                   A> or A0>

If you have followed the preceding instructions to the letter, the next time
you use Perfect Calc you will have the cell axes and a block cursor in
half-intensity reverse video.
