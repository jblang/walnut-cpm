set cdrom=n:
set output=n:\_bbs\wc30

set in_type=pcb

REM  I set this globally, in ..\all.bat
REM  To run this one batch file, change it here also.
if .%in_type% == . goto not_set
goto set
:not_set
set in_type=opus
:set

del logfile
del %output%\allfiles.txt

%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit2
%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit
