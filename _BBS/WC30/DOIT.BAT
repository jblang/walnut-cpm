rem %1 == disc directory
rem %3 == file name
if exist %cdrom%%1\00-index.txt goto ok
echo no such file: %cdrom%%1\00-index.txt >> logfile
goto end
:ok
%cdrom%\_bbs\c %in_type% wildcat %cdrom%%1 %output%\allfiles.txt
:end
