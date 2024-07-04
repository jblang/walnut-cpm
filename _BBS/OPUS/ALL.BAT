set cdrom=n:

REM  I set this globally, in ..\all.bat
REM  To run this one batch file, change it here also.
if .%in_type% == . goto not_set
goto set
:not_set
rem set in_type=opus
set in_type=pcb
:set

%cdrom%\_bbs\each_dir 1    \_bbs\dirs.txt   doit
