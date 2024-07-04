Date: Wednesday, 2 December 1987  20:39-MST
From: Larry Armijo <COLSA@SIMTEL20.ARPA>
To:   INFO-CPM@SIMTEL20.ARPA
Re:   SIMTEL20 CPM DATABASE

The one-line descriptions contained in the files SIMCPM.ARK or
SIMCPM.IDX with format as described in SIMCPM.INF in the SIMTEL20
directory PD1:<CPM.FILEDOCS> are ideally suited for DBASE II.  To
construct a DBASE II database for the files, after the appropriate
structure has been entered via the CREATE command, the DBASE II
command APPEND FROM SIMCPM.IDX DELIMITED loads the database.

The full power of DBASE II is now available for searching through the
CPM archives on SIMTEL20.  Many thanks to Keith Petersen for making
this tool available.

Larry
