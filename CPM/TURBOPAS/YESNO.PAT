The following patches will cause TURBO.COM to either always include compiler
error messages or never include compiler error messages - automatically.  No
more answering the same prompt in the same way you always do.  I recommend
always including error messages.  Note that the first one is for the PC-DOS
implementation and the second one is only for the generic MS-DOS implementation
of Turbo Pascal version 2.00B.

                           - PC-DOS Implementation -
     If the master from which the *COPY* you are patching was *COPIED* is
     labeled MS DOS, IBM-PC then implement the following patch in TURBO.COM:

At Location   |   Change From   |   To
-------------------------------------------
              |                 |
   29CE       |      E8         |   E9
              |                 |
   29CF       |      E3         |   1C
              |                 |
   29D0       |      D7         |   00
              |                 |
   29ED       |      E8         |   E9
              |                 |
   29EE       |      F5         |   05  To ALWAYS include error messages or...
              |                 |   08  To NEVER include error messages.
              |                 |
   29EF       |      02         |   00


                       - Generic MS-DOS Implementation -
     If the master from which the *COPY* you are patching was *COPIED* is
     labeled MS Compatible, then implement the following patch in TURBO.COM:

At Location   |   Change From   |   To
-------------------------------------------
              |                 |
   2716       |      E8         |   E9
              |                 |
   2717       |      0C         |   1C
              |                 |
   2718       |      DB         |   00
              |                 |
   2735       |      E8         |   E9
              |                 |
   2736       |      F5         |   05  To ALWAYS include error messages or...
              |                 |   08  To NEVER include error messages.
              |                 |
   2737       |      02         |   00


Those who are novices when it comes to using DEBUG, might find file DEBUG.HLP
in DL0 interesting.
