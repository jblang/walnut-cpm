rem %1 == input directory name

%cdrom%\_bbs\printh %cdrom% " #a CDROM, #d.  Walnut Creek CDROM.\n" > %cdrom%%1\files.bbs
%cdrom%\_bbs\printh %cdrom% " #*-+30#a#d]\n" >> %cdrom%%1\files.bbs

%cdrom%\_bbs\get_area other 1 %1 < \_bbs\dirs.txt >> %cdrom%%1\files.bbs
echo  path: %1 >> %cdrom%%1\files.bbs

%cdrom%\_bbs\printh %cdrom% " #*-+30#a#d]\n" >> %cdrom%%1\files.bbs

cd %cdrom%%1
%cdrom%\_bbs\c %in_type% opus %cdrom%%1 %cdrom%files.bbs
del %cdrom%descript.ion
%cdrom%\_bbs\c %in_type% 4dos %cdrom%%1 %cdrom%descript.ion
cd %cdrom%\_bbs\opus

