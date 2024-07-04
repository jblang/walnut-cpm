                           Using BYE with NZCOÍ (c)
                                      or
                        The New Taming of an Old Shrew
                                by Lee McEwen
                             Socrates Z-Node #32
                        The Computer Journal, Issue 42
                          Reproduced with permission
                           of author and publisher

   Socrates¬ mù rcpm¬ wenô oî linå lasô December®  Evidently¬ thió waó morå oæ 
aî  evenô thaî iô seemeä aô thå time®  Why¿  É haä jusô boughô NZCOÍ thå  weeë 
before¬  withouô  anù  previouó  Ú  Systeí  experience¬  anä  gettinç  BYÅ  tï 
peacefullù  coexisô  witè  NZCOÍ waó supposeä tï bå hard®  Tï  bå  fair¬  minå 
wasn'ô  thå firsô rcpí tï ruî undeò NZCOM®  Boâ Deaî converteä Drexeì Hilì  tï 
NZCOÍ sometimå thå previouó summer¬ anä É aí surå therå werå others®  Buô  thå 
difference¬  I'í  told¬ waó thaô á totaì neophytå manageä tï  stumblå  iî  thå 
righô combinationó tï makå thingó work®  Thió seemeä tï interesô Jaù Sage¬ whï 
surelù ió morå accustomeä tï dealinç witè peoplå whï caî walë anä che÷ guí  aô 
thå samå time¡  Hå askeä må tï telì yoõ ho÷ É diä it.

   Beforå wå start¬ É shoulä mentioî onå thing®  Iô ió truå thaô yoõ can'ô ruî 
NZCOÍ  undeò BYE®  BYÅ ió aî RSØ anä protectó itselæ froí  beinç  overwritten®  
NZCOÍ ió á verù powerfuì loadeò thaô caî reconfigurå thå memorù map®  Iô lookó 
foò  sucè  programó aó BYÅ anä refuseó tï ruî wheî theù exist®  Buô  wå  don'ô 
neeä  tï ruî NZCOÍ whilå BYÅ ió running®  Wå ruî iô before“ wå ruî BYE¬ anä  wå 
changå  systemó witè ENÖ fileó ratheò thaî ZCM¬ usinç JetLDR®  Ouò  onlù  reaì 
restrictioî ió thaô wå cannoô changå thå memorù mağ whilå BYÅ ió active.

   Iî  thió  article¬ wå wilì seô uğ á Xeroø 16/¸ DEÍ-IÉ witè á  1°  meç  harä 
drive¬ whicè wå havå configureä witè threå logicaì driveó (Aº througè C:©  foò 
thå  harä drivå anä onå floppù aó drivå D:®  Herå ió á lisô oæ stepó  tï  takå 
whicè wå wilì discusó iî turn:

            Get NZCOM running first.
              RCP vs. Transient commands.
              Become familiar with ZCM files and how to edit them.
              Make your named directory files.
            Patch WHL.COM and NZCOM.COM
            Get BYE running next.
              Watch out! There some traps here.
              Z3BASE.LIB
    +-+-+-> Tweak it.
    | | |     Use MKZCM, NZCOM.COM and JETLDR.
    | | |     Current public DU:'s will reflect in the new .ZCM files.
    | | +-< Check SHOW, PATH and PUBLIC, and the BYE.PRN file.
    | |     Get your BBS software up and running.
    | +---< Make your aliases.
    |         My usual ones.
    |       Choose your transient commands carefully
    |         What stays on A0:
    |         What must be moved to A15:
    +-----< Check the system on line.Š              Watch for security.


GET NZCOM RUNNING FIRST.

   Whù  NZCOÍ  first¿  Iô ió youò operatinç system®  Imaginå tryinç tï  ruî  á 
prograí  withouô  havinç  CP/Í installeä oî youò computer®   BYÅ  ió  á  nastù 
prograí  iî  thaô  iô hookó itselæ verù deeplù intï thå  system®   Gettinç  iô 
runninç undeò thå wronç systeí ió á wastå oæ time.

   Wå wanô tï geô thå memorù configuratioî oæ NZCOÍ thaô yoõ wilì uså witè thå 
BBÓ  going®   Iæ yoõ neeä á certaiî sizeä TPÁ foò youò BBS¬ yoõ havå  tï  makå 
rooí  foò  iô  herå sincå wå can'ô changå thå memorù mağ lateò  whilå  BYÅ  ió  
running®  Placå MKZCM¬ SHOW¬ PATH¬ anä PUBLIÃ anä youò favoritå editoò oî A0:®  
Ruî MKZCÍ tï creatå youò 'oî linå system'®  Wå wilì bå makinç severaì versionó 
oæ thå system¬ buô theù musô alì havå thå samå memorù map.

   Wå  wilì  bå  settinç uğ threå systems®  Thå firsô ió thå onå  wå  wilì  bå 
lettinç  thå  calleró use®  Iô wilì havå significanô restrictionó seô  oî  it® 
Theî wå wilì seô uğ á systeí foò thå sysoğ whicè wilì allo÷ yoõ tï dï anythinç 
yoõ  likå  oî youò computer¬ buô wilì locë ouô thå floppù disë drive®  Whù  dï 
that¿   Whaô  iæ yoõ calì iî remotelù anä enteò á commanä sucè  aó  'FF§  thaô 
accesseó  thå floppy¬ buô yoõ forgoô tï leavå á disë iî thå drive¿ You'ä  hanç 
thå system®  Finally¬ we'lì makå onå lasô systeí thå samå aó thå sysop's¬  buô 
iô  wilì  leô yoõ aô thå floppy®  É founä iô easieò tï seô uğ  thå  restricteä 
systeí  firsô anä theî afteò thaô ió runninç properly¬ gï bacë anä seô uğ  thå 
sysoğ systems.

   É  installeä  aî NZCOÍ systeí withouô anù RCP®  Aó É implieä  iî  thå  leaä 
paragraph¬  mù  assemblù programminç experiencå ió lesó thaî  minimal®   Aó  á 
result¬  É trusô transienô commandó mucè morå thaî É dï anythinç permanenô  iî 
thå  operatinç  systeí itself®  Iæ á commanä doesn'ô behavå aó É  expected¬  É 
replacå it¬ oò geô iô ouô oæ harm'ó way®  Thå booë sayó thaô IOP'ó arå á topiã 
foò  advanceä  users®  Well¬ thaô diä that¡  É dumpeä theí aó  well®   É  theî 
increaseä thå numbeò oæ nameä directorieó allowed®  Anä witè that¬ É saveä  mù 
ne÷ system®  Uså thå namå 'USER§ tï savå thió configuration.

   MKZCÍ wilì savå twï files¬ eacè oæ whicè describeó thå configuratioî you'vå  
jusô  done®   USER.ZCÍ  ió oæ particulaò interesô tï uó aó  iô  describeó  thå  
targeô  systeí iî á texô filå whicè yoõ caî easilù edit®  Let'ó dï  thaô  now®   
Paù  particulaò attentioî tï MAXDRV¬ MAXUSR¬ QUIET¬ Z3WHL¬ DRVEC¬ PUBDRV¬  anä  
PUBUSR®  Loaä uğ youò editoò anä brinç uğ USER.ZCÍ iî noî-
document mode:

  EA06 CBIOS    0080 ENVTYP    E8F4 EXPATH    0005 EXPATHS   0000 RCP
  0000 RCPS     0000 IOP       0000 IOPS      E200 FCP       0005 FCPS
  E480 Z3NDIR   0023 Z3NDIRS   E900 Z3CL      00CB Z3CLS     E780 Z3ENV
  0002 Z3ENVS   E700 SHSTK     0004 SHSTKS    0020 SHSIZE    E880 Z3MSG
  E8D0 EXTFCB   E9D0 EXTSTK  ->0000 QUIET   ->E8FF Z3WHL     0004 SPEED
->0010 MAXDRV ->001F MAXUSR    0001 DUOK      0000 CRT       0000 PRT
  0050 COLS     0018 ROWS      0016 LINS    ->FFFF DRVEC     0000 SPAR1
  0050 PCOL     0042 PROW      003A PLIN      0001 FORM      0000 SPAR2Š  0000 SPAR3    0000 SPAR4     0000 SPAR5     CB00 CCP       0010 CCPS
  D300 DOS      001C DOSS      E100 BIO     ->0001 PUBDRV  ->0080 PUBUSR

   Thió  almosô describeó á Xeroø 16/¸ DEÍ-IÉ computer¬ buô iô ió wronç  abouô 
thå driveó wå have®  Noticå thaô MAXDRÖ ió 0010¬ anä DRVEÃ ió FFFF®  Theså twï 
valueó saù thaô wå havå 1¶ contiguouó driveó oî thå computer®  Thió ió noô thå 
case®   Thió systeí haó fouò drives¬ buô wå arå buildinç á systeí  foò  publiã 
use¬  anä  wå won'ô bå lettinç thå calleró aô ouò floppù drive®   Wå  neeä  tï 
changå MAXDRÖ tï 0003®  

   That'ó easù enough®  Buô whaô oæ thió DRVEC¿  Iô ió á biô mağ oæ thå  valiä 
drives¬ whicè letó NZCOÍ skiğ oveò anù drivå thaô ió noô present®  Yoõ caî uså 
thå followinç charô tï determinå thå valuå tï givå DRVEC®  Puô á onå oveò  anù 
drivå thaô yoõ havå oî thå system®  Adä uğ thå valueó foò eacè line¬ anä writå 
theí dowî iî hexadecimaì tï thå right® 

                 Weight Factor:
               8    4    2    1

               0    0    0    0    =    0---
               P    O    N    M

               0    0    0    0    =    -0--
               L    K    J    I

               0    0    0    0    =    --0-
               H    G    F    E

               0    1    1    1    =    ---7
               D    C    B    A
                                        0007

Change DRVEC to 0007.

   Wå  alsï wanô tï limiô thå highesô useò areá wå wilì leô thå  calleró  havå 
accesó  to®  Alì thå sensitivå commandó sucè aó ERÁ wilì bå uğ high®   É  havå 
minå seô aô 7®  Changå MAXUSÒ tï 0007.

   Thå QUIEÔ flaç telló thå systeí iæ iô shoulä reporô whaô iô ió doinç tï thå 
user®   Wå  wanô  thió foò ourselves¬ buô noô foò ouò callers®   Parô  oæ  ouò 
securitù ió thaô wå wilì bå usinç aliaseó tï loaä iî moduleó whicè wå wilì  bå 
givinç secreô names®  Iæ thå quieô flaç ió off¬ thå nameó wilì bå reporteä  aó 
theù load®  Sï seô QUIEÔ tï 0001.

   Takå  notå  oæ thå valuå yoõ havå foò Z3WHL®  Yoõ wilì wanô thió  lateò  oî 
wheî  wå geô tï BYÅ anä savå thió file.

   Buô  didn'ô wå forgeô PUBDRÖ anä PUBUSR¿  Theså refeò tï thå  publiã  drivå 
anä  useò  areaó thaô ZRDOÓ wilì recognize¬ anä arå á biô oæ á  bear®   Oî  mù 
system¬  É  havå A8º seô aó á publiã DUº wherå É puô WordStar®   Obviouslù  wå 
don'ô  wanô calleró usinç that¡  Buô everù timå É editeä thå USER.ZCÍ filå  tï 
saù  therå werå nï publiã DU's¬ thå nexô timå É loadeä thå system¬  they'ä  bå Šback¡   Thå tricë herå ió tï uså thå PUBLIÃ utilitù tï canceì anù publiã  DU'ó 
beforå yoõ loaä youò ne÷ system®  Dï thaô now.

    No÷  enteò 'NZCOÍ A0:USER.ZCM§ tï loaä thió system®  Bå surå  yoõ  includå 
thå prefiø A0:®   Ruî SHO× tï seå iæ wå havå thå valueó wå wanô foò thå driveó 
anä useò areas®  You'lì seå thió oî screeî 3®  Everythinç OK¿  Iæ not¬ theî gï 
bacë tï youò editoò anä changå USER.ZCÍ aó needed.

   Ruî  PATÈ tï seå iæ thå QUIEÔ flaç ió correct®  Iô won'ô telì yoõ  anythinç 
iæ  thå QUIEÔ flaç ió on®  Iæ iô telló yoõ whaô youò patè is¬ theî  thå  QUIEÔ 
flaç ió off®  That'ó noô good®  Again¬ loaä youò editor¬ anä fiø QUIET.

   Iæ  you'vå changeä anything¬ reloaä witè NZCOÍ anä checë  everythinç  agaiî 
witè  SHO× anä PATH®  Keeğ editing¬ reloading¬ anä checkinç untiì yoõ havå  iô 
thå waù yoõ wanô it.

   No÷  checë  foò PUBLIÃ DU's®  Yoõ shoulä havå none®  Iæ yoõ  dï  havå  any¬ 
cleaò theí now.

   Ruî  MKZCÍ  onå morå time®  Don'ô changå anything¬ jusô savå iô  undeò  thå 
samå  name®   Whù dï that¿  Remembeò thaô MKZCÍ createó twï  files¿   Thå  onå 
we'vå beeî workinç witè haó thå extensioî oæ 'ZCM'®  Iæ yoõ noticed¬ thå otheò 
filå  MKZCÍ saveä haä thå extensioî oæ 'ENV'®  Thió ió whaô we'vå  beeî  afteò 
alì thió timå becauså JetLDÒ caî handlå thió filå jusô fine.

   Checë  anä rechecë thaô thå systeí ió seô aó you'ä wanô foò opeî use®  Wheî 
yoõ arå happù witè thå users§ system¬ wå wilì gï oî tï makå thå sysoğ  system®  
Brinç uğ MKZCÍ again¬ buô thió timå savå thå resulô undeò á namå thaô onlù yoõ 
wilì  know®   Foò ouò discussion¬ wå wilì calì iô SYSOP®  Let'ó gï  bacë  witè 
youò editoò anä givå yoõ somå accesó oî youò owî computer!

   Changå MAXUSÒ tï thå maximuí useò areá yoõ have®  Thió ió usuallù 15®  Pulì 
thaô  DRVEÃ  charô ouô again®  Checë ofæ alì thå driveó yoõ  neeä  accesó  to¬  
except“  foò  floppù disks®  Theî seô QUIEÔ tï 0000®  Buô watcè out¡  Don'ô  dï 
anythinç thaô changeó thå sizå oæ thå system®  Savå thå results.

   Enteò 'NZCOÍ A0:SYSOP.ZCM§ tï loaä thió system®  Again¬ iô ió importanô  tï 
enteò thå A0:®  Ruî SHO× anä PATH®  Ió iô seô aó yoõ want¿  Iæ not¬ ediô agaiî 
anä reload.

   No÷  seô  anù publiã DU'ó yoõ want®  Afteò you'vå thoroughlù  verifieä  thå 
settings¬ ruî MKZCÍ tï creatå aî ENÖ oæ thió system®  Finally¬ creatå onå morå 
system¬ buô thió timå includå thå floppies®  Givå thió anotheò secreô name.

   Whaô  havå wå done¿  We'vå createä threå environmenô fileó thaô wå caî  uså 
oî-linå tï changå á caller'ó access®  Wå don'ô neeä thå ZCÍ fileó anù  longer¬ 
sï  yoõ caî eraså them®  Uså STAÔ oò DFÁ tï seô alì thå ENÖ fileó tï  $SYÓ  sï 
thaô useró wilì noô bå ablå tï seå theí witè thå DIÒ command.

   Thå  lasô  thinç tï dï beforå wå movå oî ió tï creatå thå  nameä  directorù 
files®  É uså thå samå nameó aó thå environmenô files®  Thå biç poinô herå  ió 
thaô eveî iæ á DUº ió ouô oæ rangå oæ thå environment¬ iæ iô haó á namå anä nï Špassword¬ á calleò caî movå there®  Yoõ caî givå passwordó tï directories¬ buô 
iô  ió simpleò jusô tï noô declarå theí iî thå firsô placå iæ yoõ  don'ô  wanô 
peoplå goinç there.

   [Notå  bù Jaù Sageº É takå á differenô approacè anä makå extensivå  uså  oæ 
nameä directorieó witè passwords®  Iî fact¬ thå nameä directorieó oî mù systeí 
arå thå samå foò useró anä sysops®  Alì É dï tï makå thå sysoğ systemó ió turî 
oî  thå wheeì byte¬ sincå wheî thió ió on¬ passwordó arå ignored¬ anä onå  haó 
freå accesó tï alì thå sysoğ directories.]


PATCÈ WHL.COÍ ANÄ NZCOM.COM

   Beforå  wå gï toï mucè further¬ yoõ neeä tï makå twï patches®  Makå  backuğ 
copieó  oæ  NZCOM.COM®  Iæ yoõ dumpeä thå RCĞ aó É did¬ yoõ neeä  á  transienô 
calleä  WHL32.COÍ  tï manipulatå youò wheeì byte¬ anä wå wilì  patcè  thió  aó 
well®  Iæ yoõ arå usinç thå RCP¬ youò systeí passworä ió iî there®  Biç  poinô 
herå ió tï dï thió afteò you'vå madå bacë-uğ copieó oæ whateveò yoõ arå  goinç 
tï patch®  Caî yoõ saù 'oops'?

   Uså  DÕ  (disë utility)¬ ZPATCH¬ oò whateveò yoõ arå comfortablå  witè  anä 
calì iî NZCOM.COM®  Searcè foò NZCPM®  Thió wilì bå iî thå FCÂ sectioî oæ  thå 
program®   Changå iô tï somethinç else®  Youò restrictionó arå thaô  yoõ  musô 
makå thió eighô characteró oò less¬ thaô yoõ musô paä iô ouô tï exactlù  eighô 
characteró  witè spaces¬ anä thaô yoõ musô uså capitaì letters®  Whaô yoõ  puô 
herå musô bå á secret.

   Now¬  whù diä wå dï this¿  NZCOÍ wilì makå á filå calleä NZCPM.COÍ  oî  thå 
disë iæ therå isn'ô alreadù one®  Thå purposå oæ thió filå ió tï allo÷ yoõ  tï 
dumğ thå NZCOÍ systeí anä gï intï straighô CP/M®  Iæ á useò doeó thió oî line¬ 
hå  wilì effectivelù turî youò BBÓ off®  Hå can'ô hurô anything¬ aó BYÅ  won'ô 
bå  ablå tï talë tï thå systeí anù longer¬ buô iô won'ô reseô wheî hå  finallù 
dropó carrier¬ either®  You'lì bå crasheä untiì yoõ reboot.

   Sï  wå  gavå NZCPÍ á secreô name®  Droğ ouô oæ NZCOÍ anä  reloaä  it®   Thå 
systeí wilì writå NZCPM.COÍ undeò thå namå yoõ jusô gavå it®  Eraså NZCPM.COM¬ 
anä uså STAÔ tï makå itó replacemenô á $SYÓ filå sï thaô nï onå buô yoõ  knowó 
itó name.

   [Notå  bù  Jaù  Sageº   Again¬ É caî suggesô  aî  alternativå  anä  simpleò 
approach®  Leavå NZCOM.COÍ aó iô is®  Ruî iô tï creatå thå filå NZCPM.COM¬ anä 
theî  copù  thaô filå tï á securå area®  Theî uså SALIAÓ tï  creatå  aî  aliaó 
calleä  NZCPÍ thaô haó thå scripô commandº "IÆ WH;DIR:NZCPM;FI"¬ wherå DIÒ  ió 
thå  directorù wherå yoõ puô thå reaì NZCPM.COM®  Thå presencå oæ  thió  aliaó 
wilì  inhibiô  NZCOÍ  froí creatinç á ne÷ NZCPÍ file¬ anä thå  aliaó  wilì  dï 
somethinç  onlù iî sysoğ modå (wheî thå wheeì bytå ió on)®  Iæ thå wheeì  bytå 
ió off¬ thå commanä wilì dï nothing®  Iæ thå wheeì ió on¬ theî thå reaì  NZCPÍ 
commanä wilì bå invoked.]

   Thå  otheò patcè wå havå tï makå ió thå wheeì password®  Iæ yoõ dumpeä  thå 
RCĞ  aó É suggested¬ theî yoõ wilì bå usinç WHL32.COM®  Patcè that®  Otherwiså 
yoõ  patcè  NZRCP.ZRÌ iî NZCOM.LBR®  Looë foò eitheò SYSTEÍ  oò  PASSWORD®   É Šforgeô  whaô iô sayó iî thå distributioî copy®  Changå iô tï  somethinç  else®  
Again¬ youò restrictionó arå eighô characters¬ paddeä witè spaces¬ iî  capitaì 
letters®   [Notå  addeä bù Jaù Sageº  Thió patcè yoõ absolutelù musô  do»  yoõ 
musô  noô  leavå  á  wheeì-settinç commanä oî  thå  systeí  witè  aî  unsecurå 
password®   Thå wheeì passworä ió noô determineä bù thå systeí buô ió seô  foò 
eacè  WHEEÌ prograí (e.g.¬ WHL3² oò thå RCĞ WHÌ command)®  Yoõ shoulä bå  ablå 
tï  finä  thå  passworä usinç á patchinç utilitù anä changå  iô  tï  somethinç 
secret®  Bå surå tï tesô iô beforå puttinç youò systeí oî thå air.]


GEÔ BYÅ RUNNINÇ NEXT

   No÷ comeó somå reaì fun®  Gettinç BYÅ runninç foò thå firsô timå ió  almosô 
guaranteeä tï takå fivå yearó ofæ youò lifå anä ió morå thaô wå caî tacklå  iî 
onå article®  É suggesô yoõ worë closelù witè á Ú-Nodå sysoğ foò assistancå aó 
yoõ  go®  Buô herå ió thå planº geô BYÅ runninç anù waù yoõ caî aô first¬  anä 
theî  gï bacë tï tweaë it®  É woulä suggesô yoõ renamå DIÒ tï thå namå oæ  thå 
BBÓ  yoõ  plaî tï ruî sï thaô iô wilì bå thå prograí ruî wheî  yoõ  tesô  BYE®  
Thió  eliminateó anù problemó yoõ maù havå witè youò BBÓ systeí aó  yoõ  debuç 
BYÅ itself.

   BYÅ ió á necessarù evil®  Iô hasn'ô beeî giveî á fulì rewritå iî abouô fivå 
years¬ anä itó agå ió showing®  Thå biggesô probleí ió thaô iô trieó tï bå alì 
thingó foò alì systems®  Alì É wanô froí BYÅ ió modeí redirection¬ á fe÷ extrá 
BDOÓ  calló tï handlå situationó thaô woulä onlù happeî undeò á remotå  systeí 
(sucè  aó timå oî linå anä carrieò test)¬ anä maybå á fe÷ neaô  functioî  keyó 
likå  "Who'ó  oî  line?"®   Whaô É don'ô wanô iô doinç  ió  messinç  witè  thå 
environment®   Wå havå aî operatinç systeí tï dï thaô foò  us®  Unfortunately¬ 
BYÅ insists¬ anä iô usuallù messeó thingó up®  Onå oæ theså dayó wå wilì  havå 
á  BYÅ  madå  foò  today'ó systems®  Untiì then¬ wå havå  tï  worë  witè  thió 
monster®  [Notå addeä bù Jaù Sageº  Seå mù columî iî TCÊ #4° foò á  discussioî 
oæ  whaô  BYÅ  does®  É seconä Lee'ó commentó abouô BYÅ anä  thå  neeä  foò  á 
replacemenô thaô ió appropriatå foò Ú-Systems.]

   É  uså QBYE¬ aó iô ió thå simplesô tï seô up®  QBYÅ ió baseä oî NUBYÅ  1.0± 
bù  Toí  Brady®   Toí  anä  Irö Hofæ haä  workeä  togetheò  foò  mosô  oæ  thå 
developmenô oæ BYÅ buô parteä companù jusô aó thå lasô generatioî camå out®  É 
woulä expecô whateveò findingó É havå witè QBYÅ yoõ wilì havå witè BYÅ 5.10.

   É noticeä somå verù odä happeningó aô thå OÓ leveì anä suspecteä á conflicô 
betweeî BYÅ anä NZCOM®  Therå werå twï symptomsº thå utilitieó thaô checë  thå 
DRVEÃ  seemeä  tï bå prettù solid¬ buô thoså thaô checkeä MAXDRÖ  werå  flaky®  
Foò  example¬ FÆ (Finä File© woulä noô reporô anù fileó founä oî  thå  highesô 
drive®  Iæ É seô thå systeí tï sysoğ accesó whilå á useò waó oî line¬ iô acteä 
strangelù oncå É woulä reseô bacë tï normaì access®  Thå onlù solutioî waó  tï 
allo÷ thå calleò tï havå wheeì privilegeó foò thå duratioî oæ thå call.

   Finally¬  É  pulleä SHO× dowî whilå á calleò waó oî linå tï  seå  whaô  waó 
goinç  on®   Iô  seemó  thaô BYÅ waó resettinç thå  MAXDRÖ  anä  MAXUSÒ  byteó 
erroneously®  Oî colä boot¬ iô waó givinç MAXDRÖ onå lesó drivå thaî  allowed¬ 
anä MAXUSÒ onå more®  Morå importantly¬ oncå anù ne÷ environmentó werå loaded¬ 
iô puô invaliä datá intï theså bytes.Š
   Thougè  É  haä  tolä BYÅ noô tï monitoò thå maximuí DUº  settings¬  iô  waó 
insistinç  oî doinç jusô that®  Worse¬ iô wasn'ô doinç iô right¡  Seå  Fig®  ± 
foò  thå CCĞ settingó iî thå BYÅ configuratioî filå aó useä oî  Socrates®   Bå 
awarå  thaô  ALÌ  systeí securitù witè theså settingó ió no÷  thå  purvie÷  oæ 
NZCOM®   BYÅ wilì noô monitoò anythinç foò you®  Carefullù tesô  youò  variouó 
environmenô settingó remotelù beforå leavinç thå systeí foò publiã calls®  Yoõ 
shoulä  looë througè thå PRÎ filå tï makå surå thå propeò addresseó arå  beinç 
assigned¬ sincå thå addresseó wilì diffeò froí systeí tï system.

   Yoõ  wilì noticå referencå tï aî includå filå nameä Z3BASE.LIB®   Yoõ  wilì 
havå  tï  generatå  sucè  á filå witè definitionó  foò  thå  modulå  addresseó 
referenceä iî BYE®  Fig® ² showó thå Z3BASE.LIÂ thaô É use®  Yoõ havå tï  ediô 
thió  witè  youò memorù configuratioî beforå yoõ assemblå BYE®  Noteó  iî  thå 
filå wilì explain.

   Sï  no÷  yoõ havå BYÅ running®  Gï oî-linå anä uså SHO× tï  makå  surå  thå 
systeí  haó  stayeä thå waù yoõ wanô iô to®  Uså JetLDÒ tï  loaä  thå  variouó 
environmentó wå madå uğ beforå anä uså SHO× tï verifù thaô MAXDRV¬ MAXUSR¬ anä 
DRVEÃ  havå  stayeä  correct®  Then¬ turî youò WHÌ oî anä ofæ  whilå  yoõ  trù 
wheeì-dependenô  commandó sucè aó ERA®  Thå systeí shoulä  responä  correctly®  
Iæ  yoõ  havå problems¬ yoõ neeä tï ediô eitheò youò Z3BASÅ oò BYÅ  agaiî  anä 
reassemble.

   Oncå yoõ havå gotteî thió far¬ yoõ arå readù tï instalì youò BBÓ  software®  
É  uså QBBÓ foò á couplå oæ reasons®  Iô holdó messageó froí  differenô  areaó 
completelù  apart¬  anä iô ió distributeä witè fulì sourcå code®   Iô  doesn'ô 
hurô  thaô QBBÓ ió almosô á snağ tï install®  Whaô ió takeî aó á  negativå  bù 
many¬ thaô iô ió writteî iî compileä BASIC¬ ió á pluó iî mù mind®  Whaô doeó á 
BBÓ prograí do¿  Basically¬ iô ió á texô filå readeò thaô haó tï bå capablå oæ 
findinç  messageó  quickly®  Otheò thaî that¬ anä thå messagå  editor¬  á  BBÓ 
prograí reallù isn'ô thaô involved®  É wilì puô QBBÓ uğ againsô PBBÓ anä HBBS¬ 
botè writteî iî 100¥ machinå code¬ iî á speeä tesô anù daù oæ thå week®  Also¬ 
modifyinç higè leveì languagå programó ió usuallù easier®  Buô whaô yoõ  choså 
ió uğ tï you.


MAKÅ UĞ YOUÒ ALIASES

   Aó É saiä earlier¬ parô oæ youò systeí securitù ió thaô thå nameó yoõ  givå  
youò  environmenô fileó musô bå á secret®  Thå onlù waù tï invokå theí witè  á 
calleò  oî linå ió tï blanë ouô thå modeí outpuô witè BYE'ó ESÃ-B¬ oò tï  loaä 
theí  througè aî alias®  É uså thå aliaó method®  Iæ yoõ haven'ô pickeä uğ  oî 
iô bù now¬ É don'ô trusô BYÅ fartheò thaî É caî thro÷ it....

   Herå  arå á couplå oæ examplå aliaseó É have®  Bù thå way¬ don'ô puô  theså 
intï  youò ALIAS.CMÄ file®  I'vå seeî variouó versionó oæ TYPÅ thaô leô  useró 
typå ouô á $SYÓ file¬ anä thaô woulä blo÷ thå secret!

Thió ió thå aliaó tï loaä thå normaì (secure© system®  Iô ió nameä NZUSER:

	A0:NZUSER    --> ldr a0:user.envŠ	                 ldr a0:user.ndr
	                 whl <wheel password> /s
	                 path a0 $$$$ a0
	                 whl r
	                 echo system load done

Now the alias to load the sysop system:

	A0:NZSYSOP   --> if ~wh
                   	   whl /s
	                 fi
                 	 if wh
                   	   ldr a0:sysop.ndr
                   	   ldr a0:sysop.env
                   	   path a0 $$$$ a15 A0
                   	   echo sysop system loaded
                 	 else
                   	   echo access denied
                 	 fi

Thió  aliaó  giveó thå useò á chancå tï seô thå wheeì iî caså iô ió  off¬  buô 
wilì aborô iæ hå can'ô geô iô set.

   Twï  questions®   First¬ whù dï wå loaä thå SYSOP.NDÒ beforå  wå  loaä  thå 
SYSOP.ENV¿   Remembeò  thå QUIEÔ flag¿  Iæ wå reverseä thå order¬  thå  systeí 
woulä reporô thå namå oæ ouò NDÒ filå tï thå user®  Second¬ whù dï wå loaä thå 
extendeä patè afteò wå loaä thå environment¿  Becauså iæ wå didn't¬ A15º woulä 
bå aî invaliä DU:¬ anä thå systeí woulä refuså tï allo÷ á patè tï it.

   Thå aliaó tï loaä thå floppù systeí ió thå samå aó thå sysoğ alias¬  excepô 
iô loadó thå floppù environment.

   Thå lasô oæ whaô É feeì arå thå essentiaì aliaseó ió calleä BYE®  Whù woulä 
É  dï  that¿   Again¬ É don'ô trusô thå reaì BYÅ  tï  handlå  systeí  securitù 
properly¬ sï É havå thió aliaó reseô thå environmenô througè thå NZUSEÒ beforå 
callinç thå reaì BYE®  Oæ course¬ renamå youò reaì BYÅ tï somethinç else¬  anä 
makå iô á $SYÓ file:

	A0:BYE       --> echo one moment please.
	                 nzuser
	                 echo thank you for calling.
	                 echo please call again.
	                 realbye $*


CHOOSE YOUR TRANSIENTS

   Yoõ arå verù closå tï goinç oî line®  Movå MKZCM¬ SHOW¬ STAT¬ youò  editor¬ 
anä  anythinç elså thaô allowó someonå tï fooì witè thå systeí uğ tï  á  safe¬ 
higè useò area®  Mosô oæ uó uså A15º foò this®  Seô alì thå ENÖ anä NDÒ  fileó 
tï  $SYÓ status¬ aó welì aó alì NZCOÍ fileó anä librarieó anä thå  aliaseó  wå 
madå up®  Noô onlù doeó thió keeğ peoplå froí tryinç thingó theù shouldn't¬ iô Šalsï keepó theí froí downloadinç them®  Whaô gooä doeó iô dï tï gï througè alì 
thió tï havå someonå downloaä youò NZCOM.LBÒ witè itó patcheä wheeì password?

   Timå  tï chooså youò transienô commands®  Yoõ wilì neeä somethinç foò  filå 
transfers®  É uså ZMD15° anä RZMP16®  Somethinç tï typå ouô texô files¿  É uså 
ZLT12®   Somethinç tï locë intï LBÒ anä ARÃ files¿  É havå LUX77B¬  LUSH¬  anä 
ZLUX26¬ nonå oæ whicè É aí reallù happù with®  Gottá worë witè ARÃ files¬ likå 
iô oò not¬ sï thaô meanó yoõ neeä UNARC16®  Don'ô forgeô LDIR¬ anä iî  today'ó 
world¬ ZIPDIR®  Doeó thaô abouô dï it?


LET'S GO SEE THE WORLD

   Iæ  you'vå gotteî thió far¬ you'rå readù tï starô takinç calls®  É  suggesô 
yoõ  starô bù callinç iô yourself¡  Thrasè it¬ basè it¬ trù tï breaë  it®   Iæ 
yoõ  can't¬  theî  iô  ió timå tï telì á fe÷  friends®   Givå  theí  thå  samå 
assignment®   Havå theí dï anythinç theù caî tï crasè thå system®  Iæ  someonå 
caî dï it¬ eventuallù theù will¬ anä iô mighô aó welì bå now¬ donå bù á frienä 
whï  wilì  telì  yoõ  ho÷  iô happened®   Leavå  thå  systeí  privatå  amongsô 
yourselveó  foò á couplå oæ weeks®  Iæ iô stilì workó aó iô shoulä afteò  thió 
time¬ gï public®  Wå wilì alì welcomå á ne÷ RCP/M.

Welcomå tï thå club¬ sysop!


-----------------------------------------------------------------------------

; ++ CCP Options ++
;
ZCPR2   EQU     no              ; Yes, if running ZCPR/ZCMD/NZCPR (1 or 2)
;
; NOTE: Requires MAC.COM to assemble if ZCPR3 is set YES.
;
ZCPR3   EQU     yes             ; Yes, if running ZCPR3
;
         IF     ZCPR3
        MACLIB  Z3BASE          ; Requires MAC to assemble
         ENDIF
;
; NZCPR/ZCMD/ZCPR all use bytes (at 3DH/3EH/3FH) to store the maximum
; drive, wheel status, and maximum user area.  QBBS pokes these values
; in QBYE which in turn maintains them in low memory bytes.
;
USEZCPR EQU     yes             ; (QBBS = NO, except w/NZCOM. Then, YES)
;                               ;
CHEKDU  EQU     no              ; Yes, if QBYE will monitor MAXDRIV/USER.
                                ;   If using ZCPR/ZCMD/NZCPR, set this NO,
                                ;   since they already do it (saves a lot of
                                ;   code, too).  In either case, QBYE will
                                ;   have the correct values in MAXDRIV/USER.

;Set this equate to your system's ENV address:ŠNZENV   EQU     0E780h          ; Required for use with NZCOM
                                ; this value will vary on each computer.
                                ; use SHOW to see where your ENV is.
WHEEL   EQU     NZENV+17Fh      ; Location of ZCPR's wheel flag
MAXDRIV EQU     NZENV+02Ch      ; ZCPR location of MAXDRIV byte
MAXUSER EQU     NZENV+02Dh      ; ZCPR location of MAXUSR byte
;

MAXDRV  EQU     'J'             ; Highest drive supported
                                ; NZCOM:  Put this to highest + 1 on system 
                           	; and let the OS control access.
MAXUSR  EQU     15              ; Highest user area
                                ; NZCOM:  Put this to highest on system and
                                ; let the OS control access.
;
; In all cases, set SYSDRV/USR, since the ^B function gives you these
; d/u areas when used to toggle off the user temporarily.
;
;NZCOM:  Set SYSDRV to one more than you really want.

SYSDRV  EQU     'J'             ;#Highest local drive supported
SYSUSR  EQU     15              ;#Highest local user area (0-15)
;
                         -------------------------

Figure 1.  This is a section of the BYE configuration file showing the
proper settings to use on an NZCOM system.

-----------------------------------------------------------------------------

;Z3BASE.LIB
;
;Last edited: 10 July 89, Lee McEwen
;
;Currently configured for use with:
;  Ampro LB, 64 MB / NZCOM
;  Maximum memory size for use on bbs under bye
;
false   equ     0
true    equ     not false
off     equ     0
on      equ     not off

base    equ     0

;The following values are taken from screen 1 of SHOW:

z3cl    EQU     0DD00H                  ;mcl, multiple command line
z3cls   EQU     203                     ; length of mcl in bytes
expath  EQU     0DCF4H                  ;path
expaths EQU     5                       ; number of path elements
shstk   EQU     0DB00H                  ;shl, shellŠshstks  EQU     4                       ; number of shell entries
shsize  EQU     32                      ; size of each shell entry
z3env   EQU     0DB80H                  ;env, z-system environment
z3envs  EQU     2                       ; size of env in records
z3msg   EQU     0DC80H                  ;msg, system message buffer
z3msgs  EQU     80                      ; size of msg in records
z3whl   EQU     0DCFFH                  ;whl, location of wheel byte
z3whls  EQU     1                       ; size of whl in bytes

                         -------------------------

Figure 2.  The part of the file Z3BASE.LIB needed for the assembly of BYE.

-----------------------------------------------------------------------------

About the author and his system:

   Leå  McEweî ió á managemenô analysô livinç iî centraì Ne÷ Jersey®   Hå  haó 
beeî  runninç publiã bulletiî boardó sincå 198µ buô onlù establisheä  á  CP/Í-
baseä  systeí  aô thå beginninç oæ 1989®  Withiî threå  months¬  Socrateó  haä 
gaineä  Ú-Nodå status®  Leå dedicateä Socrateó tï learning¬ whetheò iô bå  thå 
Ú-Systeí oò higè leveì languages®  Therå ió á messagå baså devoteä tï thå  ne÷ 
'C§  programmer®   Iî  addition¬  Socrateó  ió  thå  centraì  sitå  foò   QBBÓ 
development.

   Socrateó caî bå calleä aô (201© 75´-9067¬ aô uğ tï 240° bps®  Iô runó oî aî 
Amprï Littlå Boarä witè á 6´ meç drive®  Leå runó oî Cokå anä potatï chips.

=============================================================================

[This article was originally published in issue 42 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1990, 1991 Socrates Press and respective authors]
