Date: Monday, 10 September 1984  15:38-MDT
From: Ron Fowler <RFOWLER>
To:   Keith Petersen <W8SDZ>
Re:   Assembler Files

Speaking of handy things for assemblers, if any of you use M80, you
may be interested in a 'quickie' patch I worked out.

Typically, I debug one module at a time in a large program, and while
I prefer to keep the EXTRN and PUBLIC statements limited to only the
symbols that are actually referenced, during the module's debug phase,
it's often handy to have all of its labels public.

I used to run through and change all the colons to double colons
(M80's 'simple' way to make a  public).  I got tired of this, and went
rambline through M80 and came up with a patch that sets both the
'defined' bit and the 'public' bit whenever M80 sees a colon in its
input stream.  Thus, I keep two M80's handy, M80.COM for 'normal'
operation, and M80G.COM, when I want everything public.

This patch applies only to M80 version 3.44: change location 03A4H
from 20H to 60H.

Hope someone else finds this useful.				--Ron
