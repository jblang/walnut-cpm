%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> \00-index.txt
..\get_area other 0 %1 < \_bbs\dirs.txt >> \00-index.txt
echo path: %1 >> \00-index.txt
%cdrom%\_bbs\printh %cdrom% "#*-+25#a#d]\n" >> \00-index.txt
echo Name             Size    Date    Description >> \00-index.txt
%cdrom%\_bbs\printh  %cdrom% "------------     ----    ----    #*--8#a#d]\n" >> \00-index.txt
%cdrom%\_bbs\c %in_type% pcb %cdrom%%1 \00-index.txt



