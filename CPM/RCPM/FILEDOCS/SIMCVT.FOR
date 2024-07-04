C  SIMCVT.FOR
C
C  We do not have a BASIC complier on our VAX 8700. I found it
C  very time comsuming to download SIMIBM.ARC to PC, run
C  SIMCVT.BAS, upload SIMIBM.LST to VAX and print it. Therefore,
C  I piece together a FORTRAN program which does the same thing
C  as SIMCVT.BAS.
C
C  Please perform the following steps *BEFORE* running this program.
C
C   1. Use EDT to change ' (single quote) to '' (two single quotes)
C      in file SIMIBM.IDX.
C      EDT command:  s/'/''/ 1:50000 /notype
C   2. Use EDT to change " (double quote) to ' (single quote)
C      in files SIMIBM.IDX.
C      EDT command:  s/"/'/ 1:50000 /notype
C
C  Please direct any questions or comments to me. I hope you find
C  this program helpful.
C
C  Dustin Fu
C  Computer Operator
C  Academic Computing Services
C  University of Texas at Arlington
C  Bitnet: c015fdh@utarlg
C  THEnet: UTARLG::C015FDH
C  Internet: c015fdh@utarlg.arl.utexas.edu
C
      PROGRAM IDX2LST
      INTEGER   LGTH2, BITS2, DT2, REV2
      CHARACTER FS1*4, DIR1*20
      CHARACTER FS2*4, DIR2*20, FLNM2*12, DESCR2*46
      CHARACTER DT*9, STYLE*1
C
      FS1 = ' '
      DIR1 = ' '
C
      OPEN(UNIT=1,FILE='SIMIBM.IDX',STATUS='OLD')
      OPEN(UNIT=2,FILE='SIMIBM.LST',STATUS='NEW')
C
      CALL DATE(DT)
      WRITE(2,*) 'WSMR-SIMTEL20.ARMY.MIL PUBLIC DOMAIN LISTING AS OF '
     +           ,DT
      WRITE(2,*) ' '
      WRITE(2,*) 'NOTE: Type B is Binary, Type A is ASCII'
C
111   READ(1,*,END=999) FS2,DIR2,FLNM2,REV2,LGTH2,BITS2,DT2,DESCR2
C
      IF ((FS1 .NE. FS2) .OR. (DIR1 .NE. DIR2)) THEN
         WRITE(2,*) ' '
         WRITE(2,*) 'Directory ', FS2, DIR2
         WRITE(2,*) ' Filename   Type Length   Date    Description'
         WRITE(2,*) '=============================================='
         IF (BITS2 .EQ. 8) THEN
             STYLE = 'B'
         ELSE
             STYLE = 'A'
         ENDIF
         WRITE(2,1001) FLNM2, STYLE, LGTH2, DT2, DESCR2
         FS1 = FS2
         DIR1 = DIR2
      ELSE
         IF (BITS2 .EQ. 8) THEN
             STYLE = 'B'
         ELSE
             STYLE = 'A'
         ENDIF
         WRITE(2,1001) FLNM2, STYLE, LGTH2, DT2, DESCR2
         FS1 = FS2
         DIR1 = DIR2
      ENDIF
      GOTO 111
1001  FORMAT(1X, A, 2X, A, I8, I8, 2X, A)
999   CLOSE(UNIT=1)
      CLOSE(UNIT=2)
      STOP
      END
