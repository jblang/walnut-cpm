rem %1 == disc directory
rem %2 == file name

%cdrom%\_bbs\printh %cdrom% "#a CDROM, #d. Walnut Creek CDROM.\n" > %output%\sffiles.%2
%cdrom%\_bbs\printh %cdrom% "#*-+29#a#d]\n" >> %output%\sffiles.%2
%cdrom%\_bbs\get_area other 0 %1 < %cdrom%\_bbs\dirs.txt >> %output%\sffiles.%2
echo path: %1 >> %output%\sffiles.%2
%cdrom%\_bbs\printh  %cdrom% % "#*-+40#a#d]" >> %output%\sffiles.%2
echo Name             Size    Date    Description  >> %output%\sffiles.%2
%cdrom%\_bbs\printh  %cdrom%  "------------     ----    ----    #*--4#a#d]\n" >> %output%\sffiles.%2
%cdrom%\_bbs\c %in_type% spitfire %cdrom%%1 %output%\sffiles.%2
