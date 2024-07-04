Date: Monday, 31 July 1989  09:56-MDT
From: Joe St Sauver <JOE@oregon.uoregon.edu>
To:   w8sdz@wsmr-simtel20.army.mil
Re:   An Alternative to SIMCVT.BAS

I found SIMCVT.BAS rather frustrating since I do most of my SIMTEL20 FTP work
from a VAX, and found it irritating to have to download SIMIBM.IDX to a PC,
run SIMCVT.BAS, re-upload SIMIBM.LST and then print the sucker from the VAX.

Therefore I hacked a little piece of code to munge the SIMIBM.IDX file on
our VAX using SPSSx. It has been tested on SPSSx 3.1 under VAX/VMS 5.0-2 and
seems to run fine.

Joe St Sauver (JOE@OREGON.UOREGON.EDU or JOE@OREGON)
Statistical Programmer and Consultant
University of Oregon Computing Center

--- cut here ------------------------------------------------------------------

COMMENT SIMCVT.SPS: TRANSFORM THE SIMIBM.IDX FILE FROM SIMTEL20 INTO A
COMMENT             READABLE FORM, AND CALL IT SIMIBM.LST.
DATA LIST FILE='SIMIBM.IDX' FREE / FS (a4) DIR (a24) FLNM (a14) REV * 
 LENGTH * BITS * DT * DESCR (A50)

STRING LFS(a24),LDIR(a24)
COMPUTE LFS = LAG(FS,1)
COMPUTE LDIR = LAG(DIR,1)

DO IF ($CASENUM=1) 
WRITE OUTFILE='SIMIBM.LST' / 
  "WSMR-SIMTEL20.ARMY.MIL PUBLIC DOMAIN LISTING AS OF ", $DATE, //,
  "NOTE: Type B is Binary; Type A is ASCII"
END IF

DO IF ((FS NE LFS) OR (DIR NE LDIR))
WRITE OUTFILE='SIMIBM.LST' /
  " " /
  "Directory ",FS, DIR /
  "Filename      Type Length Date   Description", /,
  "========================================",
  "========================================"
END IF

STRING BITA (A1)
RECODE BITS (8='B')(ELSE='A') INTO BITA
WRITE OUTFILE='SIMIBM.LST' / FLNM (A14), " ", BITA (A1), " ", LENGTH (F8.0), 
  " ", DT (F6.0), " ", DESCR (A50)
EXECUTE

-- cut here -------------------------------------------------------------------
