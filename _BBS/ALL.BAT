set in_type=pcb

cd menu
call menu.bat
cd ..

cd PCBTOOL
call all.bat
cd ..
cd OPUS
call all.bat
cd ..
cd RBBSTOOL
call all.bat
cd ..
cd SFTOOL
call all.bat
cd ..
cd WC30
call all.bat
cd ..
cd MAXTOOL
call all.bat

cd \
ncd /r
mv \ncdtree\treeinfo.ncd \
rd \ncdtree

pause

cd \
0del /s
rm /f *.bak  logfile foo.* out

global rd tmp
global rd temp
