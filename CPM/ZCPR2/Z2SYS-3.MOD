.fo SOFTWARE UPGRADES to SYSLIB and ZCPR2              Page #

              SOFTWARE UPGRADES to SYSLIB and ZCPR2
                          30 April 1983

                               by
                          Richard Conn

                        New TEMPLATE.MAC
                       New ZCPR2 Utilities
            Modified GENINS to Include New Utilities
          Modified Help Files to Document New Utilities
                      COMPARE.HLP Corrected

1.0  Baselines

     Thå  followinç baselinå softwarå ió establisheä bù thió  up
grade:

          COMMENT   PAGE   PHELP   SAK   PRINT3
New Vers: GENINS    TEMPLATE


2.0  Associated Upgrade Documentation

     Z2ALT.HLĞ  haó beeî modifieä tï documenô thå ne÷  utilities®  
An error has been corrected in COMPARE.HLP.


3.0  Files Affected by this Upgrade

     The following files are provided with this upgrade:

          COMMENT.COM    COMMENT.MAC
          GENINS.COM     GENINS.MAC
          PAGE.COM       PAGE.MAC
          PHELP.COM      PHELP.MAC
          PRINT3.COM     PRINT3.MAC
          SAK.COM        SAK.MAC
                         TEMPLATE.MAC

          Z2ALT.HLP      COMPARE.HLP


     These files have the following CRC values:

    1 File: COMPARE .HLP -- Size:     7K -- CRC: A4 C0
    2 File: PHELP   .COM -- Size:     8K -- CRC: 0A ED
    3 File: PHELP   .MAC -- Size:    29K -- CRC: D7 B0
    4 File: Z2ALT   .HLP -- Size:    28K -- CRC: AD 4E

    1 File: COMMENT .COM -- Size:     1K -- CRC: 88 40
    2 File: COMMENT .MAC -- Size:     6K -- CRC: 51 99
    3 File: GENINS  .COM -- Size:    14K -- CRC: A3 81
    4 File: GENINS  .MAC -- Size:    46K -- CRC: 08 8C
    5 File: PAGE    .COM -- Size:     8K -- CRC: 43 78
    6 File: PAGE    .MAC -- Size:    27K -- CRC: 68 F4
    7 File: PRINT3  .COM -- Size:     8K -- CRC: 19 02
    8 File: PRINT3  .MAC -- Size:    29K -- CRC: 27 12
    9 File: SAK     .COM -- Size:     2K -- CRC: 29 61
   10 File: SAK     .MAC -- Size:     8K -- CRC: 0E D0
   11 File: TEMPLATE.MAC -- Size:    18K -- CRC: 0B 3C


4.0  Reasons for Changes to Programs and Files

     Ne÷  utilitieó havå beeî addeä tï thå ZCPR² System®   GENINÓ 
haó beeî modifieä tï instalì PAGE¬ PHELP¬ anä PRINT3®  Thå otheró 
can be installed by the previous version of GENINS.

     The design of TEMPLATE has been enhanced.

5.0  Impact on ZCPR2

     Nï impacô ió expecteä oî anù oæ thå ZCPR² utilities¬  excepô 
foò GENINS®  Nï otheò changeó arå issued.

6.0  New Documentation

     Thå  followinç  ió provideä aó additionaì  documentatioî  tï 
supplemenô  thå ZCPR² Manuals®   Ne÷ manualó wilì bå prepareä  aô 
somå time¬ buô nï changeó tï existinç manualó arå anticipateä foò 
severaì  months®   Thå followinç documentatioî ió extracteä  froí 
Z2ALT.HLP (new version).


6.1  The PAGE Command

     Thå  PAGÅ commanä ió useä tï lisô fileó oî thå console®   Iô 
offeró á fe÷ advantageó oveò TYPÅ iî thaô PAGÅ knowó thå widtè oæ 
thå screeî anä handleó wraparounä (whicè ió á biç complainô  witè 
TYPÅ  wheî  tryinç  tï  pagå througè "wide¢  listingó  likå  thaô 
produceä bù thå assemblers)®   PAGÅ alsï acceptó á filå lisô  anä 
supports named directories.

     PAGE is invoked by a command line of the following form:

          PAGE dir:f1.typ,dir:f2.typ,... o...

wherå  "dir:fn.typ¢ ió aî ambiguouó filå speã (wilä cardó maù  bå 
used©  witè  á DIÒ prefiø (nameä directorieó oò DÕ forí  allowed© 
and "o" is one or more of the following options:

          0-9  Set Character Print Speed (0=fastest=default)

          I    Inspect Files
                    The user is allowed to approve each file to
                    bå printeä beforå thå printinç begins» 
                    default is NO Inspection

          L    Toggle Line Numbering
                    Each line may be numbered; default is NO Line
                    Numbers

          P    Toggle Screen Paging
                    Turî ofæ thå facilitù oæ pausinç oncå á
                    screen is filled; default is Paging Enabled

          Snn  Skip to Specified Page
                    Skip to indicated page (size of page on
                    printer) before beginning; default is NO Skip

     Thå Speeä optioî oæ thå PAGÅ commanä shoulä bå discusseä  iî 
somewhaô  morå detail®   Whilå á filå ió beinç pageä tï thå user¬ 
thå  useò caî strikå onå oæ thå digitó tï varù thå speeä  oæ  thå 
outpuô dynamically®  ° ió thå fastest¬ ¹ ió thå slowest®  Iî thió 
way¬  thå  useò caî easilù scaî á filå bù runninç PAGÅ witè thå Ğ 
optioî  (sï  iô  doeó noô stoğ wheî thå  screeî  ió  filled©  anä 
strikinç  á digiô froí timå tï timå tï speeä uğ oveò sectionó  hå 
isn't interested in and slow down for sections he is.

     Whilå  thå  outpuô  ió beinç directeä tï  thå  screen¬  PAGÅ 
supportó  thå followinç single-characteò commandó tï  changå  thå 
output display in one way or another:

          0 to 9 - change speed (0=slowest, 9=fastest)

          P or p - toggle pause when screen fills
                    (the user can dynamically turn on and off
                     the ability to delay when a screen fills)Š
          ^X     - skip to next file

          ^C     - abort to operating system

          ^S     - pause output; any key will resume, and all
                    of these commands (except ^S) will work

     PAGÅ ió constantlù acceptinç useò input¬  anä theså commandó 
arå iî effecô alì oæ thå time®   Thió includeó thå timå wheî PAGÅ 
haó  pauseä afteò fillinç thå screeî (itó default)¬  sï thå  useò 
caî  turî  ofæ  paginç  oò varù thå speeä aô  thió  time¬  iæ  sï 
desired®  Anù otheò characteò wilì bå ignored.

6.2  The PRINT Command

     Thå  PRINÔ  commanä  ió useä tï prinô á  filå  oî  thå  LSTº 
device¬  likå LISÔ does¬  buô offeró manù morå options®   Iô wilì 
prinô  á heading¬  pagå thå file¬  numbeò thå pages¬  numbeò  thå 
lines¬  placå á date/timå stamğ oî thå output¬  puô thå filå namå 
oî thå output¬ anä others.

     The PRINT command is of the following form:

          PRINT dir:f1.typ,dir:f2.typ,... o...

wherå  "dir:fn.typ¢  ió aî ambigouó filå namå witè á  DIÒ  prefiø 
(supportinç  thå DÕ forí oò á nameä directory© anä "o¢ ió onå  oò 
morå oæ thå following:

          E - Exact Print (Expand Tabs, Form Feed, No Line or
               Page Numbers, No Heading)

          F - Toggle default of file name display on page header
               (defaulô ió ON¬ so Æ turnó ofæ name display)

          H<delim>text<delim> - Define Heading text to appear
               at the top of each page

          I - Inspect Files (allow user to select files before
               printing begins)

          L - Enable numbering of each line

          M - Disable Multiple Run Flag
               (if multiple run is ON, then no "Set Top of Form"
                message appears for each file and PRINT moves
                from one file to another unattended); default is
               with Multiple Run ON

          N - Disable numbering of each page

          Sn - Start printing on page n

Š
          T - Toggle date/time stamp in the header of each page
               (a TIME subroutine must be assembled into PRINT
                to enable the date/time stamp feature)

     Thå  specifiã  featureó  oæ  thå  printeò  arå  seô  bù  thå 
installeò  witè  GENINS®   Sucè featureó includå  thå  numbeò  oæ 
physicaì lineó oî á page¬  thå numbeò oæ lineó oæ texô oî á page¬ 
anä thå widtè oæ á linå iî characters.

     Thå date/timå stamğ featurå ió verù  machine-dependent¬  anä 
PRINÔ haó tï bå reassembleä tï supporô it.

     While PRINT is running, the following commands work:

          ^C   Abort and return to operating system

          ^X   Skip to top of next page and skip to next file

6.3  The PHELP Command

     Thå  PHELĞ commanä ió á speciaì versioî oæ PRINÔ designeä tï 
prinô Helğ (HLP© files®   PHELĞ knowó abouô thå structurå oæ Helğ 
Files¬  anä iô useó thió informatioî tï prinô theí iî á preferreä 
format®  Iæ iô ió dealinç witè aî indexeä Helğ File¬ PHELĞ printó 
thå  indeø oî thå firsô pagå anä thå bodù startinç oî thå  seconä 
page®   PHELĞ  alwayó  skipó  tï thå toğ oæ á ne÷  pagå  wheî  iô 
encounteró aî informatioî section®   Iô outputó á ne÷ linå wheî á 
forí  feeä characteò (useä bù HELĞ tï breaë screeî displays)¬  aó 
opposed to causing a page eject.

     The PHELP command is of the following form:

          PHELP dir:f1.typ,dir:f2.typ,... o...

wherå  "dir:fn.typ¢  ió aî ambigouó filå namå witè á  DIÒ  prefiø 
(supportinç  thå DÕ forí oò á nameä directory© anä "o¢ ió onå  oò 
morå oæ thå following:

          H<delim>text<delim> - Define Heading text to appear
               at the top of each page

          I - Inspect Files (allow user to select files before
               printing begins)

          L - Enable numbering of each line

          Sn - Start printing on page n

          T - Toggle date/time stamp in the header of each page
               (a TIME subroutine must be assembled into PRINT
                to enable the date/time stamp feature)

     Aó  witè PRINT¬  ^Ã abortó thå printouô anä ^Ø skipó tï  thå 
next file after issuing a form feed.Š
6.4  The SAK Command

     SAË  (Strikå  Anù Key© waó designeä tï providå  somå  simplå 
utilitù functions¬  onå oæ whicè ió associateä witè thå  Multiplå 
Commanä Linå featurå oæ ZCPR2®  Iô waó designeä foò thå followinç 
purposes:

          1.  to allow the user to program a wait in a multiple
               command line until he instructs the system to
               continue

          2.  to allow the user to abort a multiple command line

          3.  to allow the user to program an interruptable delay
               in the execution of a multiple command line

          4.  to provide a simple alarm for the user

     The SAK command line is:

          SAK o...

where "o" is zero or more of the following options:

          A    -- DO NOT Allow the User to Abort the MCL
          B    -- Ring Bell
          Pnn  -- Pause nn seconds and continue if no response

     Witè NÏ options¬  SAË waitó foò useò input¬  anä iæ thå useò 
strikeó  á  ^C¬  theî  thå multiplå commanä linå ió  aborteä  anä 
control is returned to the user.

     SAË ió particularlù usefuì iæ thå useò wisheó tï interjecô á 
delaù  iî  á  multiplå commanä linå  generateä  bù  á  Menu®   Aî 
applicatioî  whicè É founä usefuì waó tï displaù thå timå tï  thå 
user¬  calì hió attentioî tï iô (viá ECHO)¬ givå hií á delaù (viá 
SAK), and then invoke dBASE II with an initializing command file.


6.5  The COMMENT Command

     COMMENÔ ió á simplå routinå whicè allowó thå useò tï typå aó 
manù  lineó  aó hå wisheó withouô theí beinç processeä bù  ZCPR2®  
It has no arguments.

     COMMENT has two main applications in the ZCPR2 environment:

          1.  when the console displays are being recorded,
               COMMENT allows the user to easily type notes
               to the future reader without having to begin
               lines with a semicolon (;); all of these lines
               are clearly shown to be comments since they begin
               with the prompt "COMMENT>"
Š
          2®  wheî consolå I/Ï ió redirecteä tï twï differenô
               users, such as CRT and MODEM I/O in parallel,
               then COMMENT may be used to provide a simple
               mechanism for them to communicate; both users
               can type to each other without having any effect
               on the system (such as command processing)

     COMMENÔ  ió aborteä bù strikinç á ^Ã aó thå firsô  characteò 
oæ á line®  Backspacå anä Deletå botè servå tï echï aó Backspace¬ 
space, backspace, and ^X and ^U both erase the current line.

     Iæ  COMMENÔ ió tï bå useä tï chaô betweeî twï users¬  iô  ió 
recommendeä thaô aî over/ouô protocoì bå employeä (aó recommendeä 
witè thå UNIØ WRITÅ program)®   Thå firsô useò types¬  and¬  wheî 
finished¬  terminateó  witè thå letteò "o¢ foò over®   Thå seconä 
useò  typeó anä signaló completioî thå samå way®   Completioî  oæ 
thå  conversatioî  maù bå signalleä bù "o+o¢ foò  oveò  anä  out®  
Example:

COMMENT> Hi, Charlie, how's it going? o
COMMENT> Hi, Rick, fine ... and you? o
COMMENT> Fine, Charlie
COMMENT> Here is how I use XDIR -- let me do the typing
COMMENT> from now on ... just watch, and I'll reenter COMMENT
COMMENT> when done ... here goes o+o


