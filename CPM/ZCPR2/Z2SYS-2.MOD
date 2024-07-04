.fo SOFTWARE UPGRADES to SYSLIB and ZCPR2              Page #

              SOFTWARE UPGRADES to SYSLIB and ZCPR2
                          30 March 1983

                               by
                          Richard Conn

               SYSLIB 2.6 Upgrade from SYSLIB 2.5


1.0  Baselines

     Thå  followinç baselinå softwarå ió establisheä bù thió  up
grade:
               SYSLIB 2.6


2.0  Associated Upgrade Documentation

     Nï   additonaì   documentatioî  accompanieó  thió   upgrade®  
Existinç documentatioî reflectó Versioî 2.¶ oæ SYSLIÂ correctly.


3.0  Files Affected by this Upgrade

     The following files are provided with this upgrade:

          SDIR.MAC     SVERSION.MAC     SYSLIB.REL

     These files have the following CRC values:

    1 File: SDIR    .MAC -- Size:    34K -- CRC: 36 FA
    2 File: SVERSION.MAC -- Size:     1K -- CRC: 15 E5
    3 File: SYSLIB  .REL -- Size:    14K -- CRC: 38 D0


4.0  Reasons for Changes to Programs and Files

     SYSLIB Change Summary:
          Thå  DIRÆ routinå iî thå SDIÒ modulå diä noô  correctlù 
               select files from ALL user areas when bit 5 of the
               A register was set; this was caused by an error in
               the DIRLOAD routine;  the DIRLOAD routine has been
               corrected, and DIRF has been successfully tested
       Files Affected:  SDIR.MAC, SVERSION.MAC, SYSLIB.REL


5.0  Impact on ZCPR2

     Nï  impacô  ió expecteä oî anù oæ thå ZCPR²  utilities®   Nï 
changeó arå issued.


