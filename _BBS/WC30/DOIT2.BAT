cd %1
del wildcat.txt
\_bbs\c %in_type% wildcat %cdrom%%1 wildcat.txt
if not errorlevel 1 goto ok
echo error in %1 >> \_bbs\logfile
:ok
cd \_bbs\wc30

