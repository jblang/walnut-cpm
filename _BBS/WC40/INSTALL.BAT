@echo       Which cdrom drive letter?  If this is not right, this install
@echo       will NOT work.   (You need the ':' after the letter, also.)
set cdrom=e:
@echo       What is your data directory name?
@echo       (The default is 'data', which I also use.)
set datadir=data
@echo       If these aren't right, ^c and edit this file using a text editor.
pause
rem ---------------- below shouldn't need edited -----------------
if not exist %cdrom%\_bbs\wc30\install1.exe goto error
if not exist %cdrom%\_bbs\wc30\install2.exe goto error
@echo Making backup files.
copy %datadir%\allfiles.dat %datadir%\allfiles.da2
copy %datadir%\allfiles.ix  %datadir%\allfiles.ix2
copy filearea.dat filearea.da2
copy makewild.dat makewild.da2
copy confdesc.dat confdesc.da2
copy confdesc.ix confdesc.ix2
copy confdesc.ux confdesc.ux2
%cdrom%\_bbs\wc30\install1
if errorlevel 1 goto restore
makewild
%cdrom%\_bbs\wc30\install2
del $$temp$$
if errorlevel 1 goto restore
@echo Check the file areas with makewild.  (Just to see what happened.)
pause
makewild
@echo The install program created a batch file called 'install3'.
@echo You can change wcfiles options by editing this file.
@echo Then execute the batch file by typeing 'install3'.
@echo When you are done, you can check wcfile.log to see exactly what wcfile
@echo thinks happened.
goto end

:error
@echo I don't think you have the right cdrom drive letter where my cdrom is
@echo located.  I couldn't find my install program on the ''%cdrom%'' drive
@echo you said was your cdrom.  Edit this file and put the right cdrom drive
@echo letter in.
goto end

:restore
@echo  Error exit -- restoring original datafiles
copy filearea.dat filearea.err
copy filearea.da2 filearea.dat
copy makewild.dat makewild.err
copy makewild.da2 makewild.dat
copy confdesc.dat confdesc.err
copy confdesc.da2 confdesc.dat
copy confdesc.ix2 confdesc.ix
copy confdesc.ux2 confdesc.ux

:end
