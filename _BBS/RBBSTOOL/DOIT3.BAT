%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> %output%\all.dir
..\get_area other 0 %1 < \_bbs\dirs.txt >> %output%\all.dir
echo path: %1 >> %output%\all.dir
%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> %output%\all.dir
echo Name             Size    Date    Description >> %output%\all.dir
%cdrom%\_bbs\printh  %cdrom% "------------     ----    ----    #*--8#a#d]\n" >> %output%\all.dir
%cdrom%\_bbs\c %in_type% rbbs %cdrom%%1 %output%\all.dir



