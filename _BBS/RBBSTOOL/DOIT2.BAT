rem %1 == disc directory
%cdrom%\_bbs\printh %cdrom% "#a.  #d.  Walnut Creek CDROM.\n"  > %output%\%2.dir

%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> %output%\%2.dir
%cdrom%\_bbs\get_area other 0 %1 < %cdrom%\_bbs\dirs.txt >> %output%\%2.dir
echo path: %1  >> %output%\%2.dir
echo Name             Size    Date    Description >> %output%\%2.dir
%cdrom%\_bbs\printh  %cdrom% "------------     ----    ----    #*--8#a#d]\n" >> %output%\%2.dir

%cdrom%\_bbs\c %in_type% rbbs %cdrom%%1 %output%\%2.dir
