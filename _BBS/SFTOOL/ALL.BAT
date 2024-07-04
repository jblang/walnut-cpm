set cdrom=n:
set output=n:\_bbs\sf

rem you shouldn't need to change anything below this.

REM  I set this globally, in ..\all.bat
REM  To run this one batch file, change it here also.
if .%in_type% == . goto not_set
goto set
:not_set
rem set in_type=opus
set in_type=pcb
:set

echo y | del %output%\*.*

%cdrom%\_bbs\each_dir 1    %cdrom%\_bbs\dirs.txt   doit
