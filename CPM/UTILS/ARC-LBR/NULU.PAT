  How to patch NULU 1.5 to make it start up more quickly
            by Jon Saxton, 30th April 1987.
 
When NULU loads the first thing it does is an internal CRC
calculation to check its own integrity.  The idea is to make
sure the program was loaded correctly and/or that it had not
been corrupted on the disk.  This is a most admirable idea
and it protects you against the unforseen and unpredictable
consequences of executing a bad copy of the program.
 
Unfortunately, the checking takes time (about 2 seconds) and
that can become annoying after a while.  If your impatience
exceeds your concern for safety then you can risk changing
the jump instruction at the start of the program from
        JP      0146h
to
        JP      01A2h
to bypass the checking.  Of course if you do that you will
be completely at variance with the intentions of the author
but then none of your other programs does an internal check
and you're not paranoid about those, are you?
