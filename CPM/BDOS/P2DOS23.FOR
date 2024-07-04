Date: Wednesday, 17 February 1988  12:28-EST
From: Donald C. Kirkpatrick
Re:   P2DOS23 - CP/M BDOS replacement

In SUPRBDOS Benjamin Ho modified P2DOS to eliminate the need for most
ctl-C's, but in doing so, he made the new BDOS disk error routine
tables incompatible with both CP/M 2.2 and P2DOS.  This incompati-
bility was completely unnecessary.  He also renamed the BDOS
replacement which doesn't make sense either.

I have modified his SUPRBDOS to re-establish full compatibility yet
retain his improvements. I have also added some assembly-time
options. You will find below an excerpt from the assembly listing
describing more fully these changes.

This library (crunched with CRUNCH24 and created with NULU) replaces
P2DOS21.ARK, SUPRBDOS.ARK, and SUPRBDOS.BWR.

Don Kirkpatrick

503-629-1236 (work)
503-649-4078 (home)
uucp: !tektronix!dadla!donk
