REM  ---Change this---
REM Set CDROM to the CDROM drive letter that the disk is in (don't forget
REM the ':'!)
set cdrom=n:
REM  ---Change this---

REM  ---Change this---
REM Set OUTPUT to the FULL target path for your DIR files
set output=n:\_bbs\pcb
REM  ---Change this---

set in_type=pcb

REM  I set this globally, in ..\all.bat
REM  To run this one batch file, change it here also.
if .%in_type% == . goto not_set
goto set
:not_set
set in_type=opus
:set

rem you shouldn't have to change anything below this.

echo y | del %output%\*.*
del dir.lst
del logfile
del ..\logfile
del dlpath.lst

rem this produces the index files for each directory
%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit

rem this produces the dir.lst file
%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit2

rem this produces the dlpath.lst file
%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit3

rem this produces the global index file
%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit4
