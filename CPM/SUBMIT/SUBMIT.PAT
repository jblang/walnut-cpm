Date: Friday, 1 February 1985
From: Gene Bloch
To:   All
Re:   Patching submit.com to work from any drive

This patch allows SUBMIT to run from other than A: drive.  The current
SUBMIT creates its work file, $$$.SUB, on the default drive, then
looks for it on A:.  The patch causes the work file to be made on A:.
That way, the search works better.

Using DDT, change location 5BBh of SUBMIT.COM from 0 to 1.  That's it.
As a check, note that locations 5BCh to 5C6h contain "$$$     COM".

Look up the syntax of FCBs to see the rationale for the change (exercise
for the reader :-).

If you have a good library (personal or public), check out Microsystems,
Jul/Aug 1982 p 60.  There are a lot of patches listed there, for PIP, ASM,
MOVCPM, et al.
-- 
Gene E. Bloch (...!nsc!voder!gino)
