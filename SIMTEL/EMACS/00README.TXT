To: mit-eddie!gatech!mailrus!uunet!ssiny!gnohmon@bloom-beacon.MIT.EDU
cc: ssiny!gnohmon@uunet.uu.net
Subject: z80 emacs (*finally*)

(Forward this wherever you choose; I'd suggest comp.os.cpm at very
least, and maybe comp.emacs to amuse people...)

You will now find, for anonymous ftp from SIPB.MIT.EDU, the Ralph
Betza <ssiny!gnohmon@uunet> Z80 Emacs implementation, release 0.1.
Sorry it has taken so long to get it up for ftp, but it's there now.

% ftp sipb.mit.edu
...
230 Guest login ok, access restrictions apply.
ftp> cd pub/z80/emacs
250 CWD command successful.
ftp> dir
200 PORT command successful.
150 Opening data connection for /bin/ls (ascii mode) (0 bytes).
total 736
-rw-r--r--  1 3382     395         93073 Mar 11 11:09 bin.tar.Z
-rw-r--r--  1 3382     395        178816 Mar 11 11:09 bindist.lbr
-rw-r--r--  1 3382     395         86013 Mar 11 11:09 src.tar.Z
-rw-r--r--  1 3382     395        185728 Mar 11 11:10 srcdist.lbr
-rw-r--r--  1 3382     395         87936 Mar 11 11:10 zmaxb01.lzr
-rw-r--r--  1 3382     395         89728 Mar 11 11:11 zmaxs01.lzr
226 Transfer complete.
409 bytes received in 0.41 seconds (0.97 Kbytes/s)

Remember to set "binary" mode when doing the ftp (and when downloading
to your z80 system, ultimately.) 
	Binary distribution:
	zmaxb01.lzr is a Crunched LBR library.
	bindist.lbr is an uncrunched copy of zmaxb01.lzr.
	bin.tar.Z is a compressed tar file of the contents of bindist.lbr.

	Sources:
	zmaxs01.lzr is a Crunched LBR library.
	srcdist.lbr is an uncrunched copy of zmaxs01.lzr.
	src.tar.Z is a compressed tar file of the contents of srcdist.lbr.

				_Mark_ <eichin@athena.mit.edu>
				MIT Student Information Processing Board
