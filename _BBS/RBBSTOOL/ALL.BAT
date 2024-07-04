rem this is where the actual files live
set cdrom=n:
rem this is where you want your index files (full path, with drive)
set output=n:\_bbs\rbbs

set in_type=pcb


REM  I set this globally, in ..\all.bat
REM  To run this one batch file, change it here also.
if .%in_type% == . goto not_set
goto set
:not_set
set in_type=opus
:set

del logfile
del ..\logfile
echo y | del %output%\*.*


%cdrom%\_bbs\each_dir 1    \_bbs\dirs.txt   doit2

type header1 > %output%\all.dir
%cdrom%\_bbs\each_dir 1    \_bbs\dirs.txt   doit3

type makefidx.1 > makefidx.cfg
%cdrom%\_bbs\each_dir 1    \_bbs\dirs.txt   doit4
type makefidx.2 >> makefidx.cfg

call makeffs
