rem %1 == disc directory
if exist %cdrom%%1\00-index.txt goto ok
echo no such file: %cdrom%%1\00-index.txt >> logfile
goto end
:ok
if exist %output%\dir%2 goto bad
goto ok2
:bad
echo duplicate output file: %output%\dir%2 >> logfile
goto end
:ok2

%cdrom%\_bbs\printh %cdrom% "#a.  #d.  Walnut Creek CDROM.\n"  > %output%\dir%2
%cdrom%\_bbs\get_area other 0 %1 < %cdrom%\_bbs\dirs.txt >> %output%\dir%2
echo path: %1 >> %output%\dir%2
%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> %output%\dir%2
%cdrom%\_bbs\printh %cdrom% "Name           Size      Date    Description\n" >> %output%\dir%2
%cdrom%\_bbs\printh  %cdrom% "============ ========  ========  #*=-8#a#d]\n" >> %output%\dir%2

%cdrom%\_bbs\c %in_type% pcb %cdrom%%1 %output%\dir%2
:end
