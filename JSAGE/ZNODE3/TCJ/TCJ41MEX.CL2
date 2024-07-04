From: Roger Bond
Subj: ARUNZ Alias for MEX v1.14 Command Line Separator
Vers: 2
Date: April 28, 1990

Thanks to Biff Bueffel, below is a "revised" alias for MEX v1.14.  I did 
not know that MEX v1.14 had an undocumented (?) POKE command.  POKE did 
not show up in MEX's "?" display or MEX's "HELP ?" display.  Anyways, 
thanks to Biff for encouraging me to "try again."  Jay Sage noted that 
he believes "that the POKE command is not really documented in the 
MEX-Plus manual either.  I guess the author didn't want people to know 
about it!"  Please read TCJ41.WS for Jay Sage's complete discussion 
on sending multiple commands from ZCPR3 to MEX (specifically, MEX v1.65, 
aka MEXPLUS).

Thanks to Biff's advice, the aliases presented in this file for MEX 
v1.14 really do not differ from the ones provided by Jay for MEXPLUS -- 
the address to poke is even the same!!!!  So as to not make these 
efforts a complete redundant waste of time (Biff's insight as to MEX 
v1.14 does make these efforts a case of redundancy -- oh well, so it 
goes -- but so as to not leave things hanging, this second file is 
submitted to Z-System community anyways), the only real "difference" is 
the addition of MEX2Z which was originally added to my previous effort 
to supplement Jay's always insightful and useful works of genius.  MEX2Z 
allows you to send a command to the ZCPR3 command line after exiting 
from MEX.  So you can both send multiple commands from ZCPR3 to MEX and 
send multiple commands from MEX to ZCPR3 (where you go back to MEX if 
you try the latter).  MEX2Z.COM is from MEX2Z10.LBR.  For MEXPLUS users, 
get MEX+2Z11 from MEX+2Z11.LBR and in the aliases below substitute 
MEX+2Z11 in for MEX2Z.

Use the first alias below if you do NOT patch MEX v1.14 with "!" as the 
command line separator:

MEX       get 100 mex114.com;poke d18 21;go $*!poke $$0d18 $$3b;mex2z

Use the second alias below if you do patch MEX v1.14 with "!" as the 
command line separator:

MEX       mex114 $*!poke $$0d18 $$3b;mex2z

To use the second alias, you have to patch MEX v1.14 using the commands 
STAT SEP "!"   and   CLONE MEX114.COM  while in MEX.

Note that in the above two aliases that you need a double "$" (i.e., 
"$$") after the MEX "!" command line separator so that ARUNZ will 
correctly pass a single "$" to MEX.

Biff noted that he uses the command POKE $3700 $00 $00 ("POKE $$3700 
$$00 $$00" for the ARUNZ ALIAS.CMD script) in his copy of MEX v1.14.  I 
only found part of a MEX error message at the 3700h address in my copy 
of MEX v1.14.  Nonetheless, you may wish to experiment with your copy of 
MEX v1.14 to find the correct address where you are supposed to poke if 
the address of 0D18h or 3700h do not work for you.  You may want to use 
ZPATCH and that program's search command to find the correct address -- 
look for ";" which should be in a sector where ">" is a few bytes after 
";".  It should be the first ";" you find in MEX v1.14 (at least it is 
in my copy).  Use MEX's command of STAT SEP to check if the command line 
separator is what you want it to be.

------
From: Roger Bond
Subj: ARUNZ Alias for MEX v1.14 Command Line Separator
Date: April 21, 1990

This is an alias for the ALIAS.CMD file.  It assumes you are using MEX 
v1.14, named MEX114.COM, and the program MEX2Z.COM.  The latter program 
allows you to send a command to the ZCPR3 command line after exiting 
from MEX.  This alias is submitted as a supplement to Jay Sage's 
TCJ41.WS column where he describes how to send multiple commands to the 
MEX system prompt.  ZCPR3 users will readily see how you have to change 
the MEX command line separator, albeit temporarily, so as to not cause 
conflict with the ZCPR3 command line, i.e., the multiple commands 
intended for MEX may instead be sent to ZCPR3 if not for the change.  
Please read TCJ41.WS for Jay Sage's more complete discussion on this 
conflict and his solution for MEX v1.65 (aka, MEXPLUS).  MEX v1.65 has 
the poke command.  MEX v1.14 does not have the poke command, hence the 
alias solution humbly submitted in this text file.

Use the first alias below if you do NOT patch MEX v1.14 with "!" as the 
command line separator:

MEX	get 100 mex114.com;poke d18 21;go $*!read sep;lx mex2z

Use the second alias below if you do patch MEX v1.14 with "!" as the 
command line separator:

MEX	mex114 $*!read sep;lx mex2z

To use the second alias, you have to patch MEX v1.14 using the commands  
STAT SEP "!"   and   CLONE MEX114.COM  while in MEX.  (Note that an 
alternative to "!" as the command line separator is the "^" caret 
character as used by 4DOS in the MS-DOS world.  Personally, I prefer 
Jay's selection of "!".)

Make a text file named SEP.MEX containing only the single line at bottom 
of this text file below.  Make sure you do NOT hit a carriage return at 
the end of the line, i.e., the file ends directly at the end of the line 
below.  For instance, if you are using VDE, do the following command: 
^QC^QS^KB^QS^KK^KWsep.mex<CR>^KU

stat sep ";"