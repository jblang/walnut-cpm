.fo SOFTWARE UPGRADES to SYSLIB and ZCPR2              Page #

              SOFTWARE UPGRADES to SYSLIB and ZCPR2
                          22 June 1983

                               by
                          Richard Conn

                 Corrected SDIR Module in SYSLIB
            New SEPRINT and SEPSTR Modules in SYSLIB
        SVERSION in SYSLIB Updated to Reflect Version 2.7
                      New SYSTEST2 Program
                     New SYSLIB, Version 2.7
                      ECHO Utility Modified
                    SYSLIB.HLP File Modified

1.0  Baselines

     Thå  followinç baselinå softwarå ió establisheä bù thió  up
grade:

          SYSLIB Version 2.7
               Error in SDIR Module Corrected
               SEPRINT and SEPSTR Modules Added
               SYSTEST2 Updated
               Online Documentation (SYSLIB.HLP) Updated
          ECHO Version 1.2


2.0  Associated Upgrade Documentation

     SYSLIB.HLĞ  haó  beeî  modifieä tï describå thå  EPRINÔ  anä 
EPSTR routines.


3.0  Files Affected by this Upgrade

     The following files are provided with this upgrade:

    1 File: ECHO    .COM -- Size:     4K -- CRC: FF 9A
    2 File: ECHO    .MAC -- Size:     8K -- CRC: CD CC
    3 File: SDIR    .MAC -- Size:    32K -- CRC: 66 4C
    4 File: SEPRINT .MAC -- Size:     4K -- CRC: 2A 31
    5 File: SEPSTR  .MAC -- Size:     4K -- CRC: 68 B3
    6 File: SVERSION.MAC -- Size:     4K -- CRC: 19 AA
    7 File: SYSLIB  .HLP -- Size:    16K -- CRC: DF D5
    8 File: SYSLIB  .REL -- Size:    16K -- CRC: 1C 54
    9 File: SYSTEST2.MAC -- Size:     4K -- CRC: 9E 05



4.0  Reasons for Changes to Programs and Files

     Á buç waó detecteä anä correcteä iî thå SDIÒ  module®   Thió 
buç waó iî thå DIRLOAÄ routine.

     Á  neeä  waó realizeä foò Exacô Prinô capabilitù iî  SYSLIB®  
Thå  routineó  PRINT¬   LPRINT¬  PSTR¬  anä  LPSTÒ  performeä  aî 
interpretatioî oî controì characters¬  printinç theså  characteró 
aó  two-characteò sequenceó oæ thå forí "^c"®   EPRINÔ anä  EPSTÒ 
havå beeî addeä tï SYSLIB¬  and¬  asidå froí expandinç tabs¬ theù 
perforí  nï  otheò  translatioî oî controì characteró  outpuô  bù 
them®   Consequently¬  theù  caî  bå useä tï  issuå  commandó  tï 
intelligenô   terminaló   anä  thå  likå  whicè  requirå   escapå 
sequences.

     Thå  onlinå  documentatioî  iî  SYSLIB.HLĞ  waó  updateä  tï 
describå EPRINÔ anä EPSTR®   Documentatioî iî thå SYSLIÂ  manualó 
wilì bå updateä aô á lateò time.

     Thå  SYSTEST²  prograí waó expandeä tï allo÷  morå  completå 
testinç oæ thå DIRÆ anä DIRFÓ routineó iî SYSLIB.

     Thå  ECHÏ commanä waó changeä tï uså EPSTÒ sï thaô ECHÏ  caî 
no÷  bå useä tï senä commandó tï thå CRÔ controì commands®   Thió 
extendó itó utilitù bù permittinç iô tï bå useä tï initializå thå 
CRÔ oî STARTUĞ oò iî SÔ applications.

5.0  Impact on ZCPR2

     Nï impacô ió expecteä oî anù oæ thå ZCPR² utilities¬  excepô 
foò ECHO®  Nï otheò changeó arå issued.

6.0  New Documentation

     Thå SYSLIB.HLĞ filå anä thió MOÄ filå arå tï providå interií 
documentation until the new SYSLIB manuals are released.

