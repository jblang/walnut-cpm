                            NULU.DOC
                   Documentatioî foò NULU.COM
                         aó oæ 11/01/85
                           Versioî 1.5

NULU.COÍ anä NULU.DOÃ arå botè Copyrighô 198´ anä 1985¬ bù Martiî 
Murray¬  P.O®  Boø  35972¬  Dallas¬  TØ  75235®  Botè maù bå useä 
freelù  foò  non-commerciaì purposes¬  buô neitheò maù  bå  sold¬ 
includeä iî á packagå foò sale¬  oò useä aó aî incentivå tï  buy¬ 
bù   anù  person¬   organizatioî  oò  corporatioî  withouô  prioò 
arrangemenô   witè   thå   copyrighô   holder¬   Martiî   Murray®  
Furthermore¬ Martiî Murraù wilì beaò nï responsibilitù foò losseó 
resultinç  froí  thå  uså  oò  inabilitù  tï  uså  thió  program®  
NULU.COÍ  maù noô bå distributeä withouô NULU.DOC¬  noò  maù  thå 
copyrighô  messageó bå removeä froí eitheò filå noò causeä tï noô 
bå displayed.


                        ACKNOWLEDGEMENTS

Thió  prograí  woulä noô havå beeî possiblå werå iô noô  foò  thå 
eleganô worë oæ Garù P® Novosielské anä thoså otheró workinç witè 
thå LÕ librarù structure.

Additionally¬ É woulä likå tï thanë thå peoplå whï havå supporteä 
thå developmenô oæ NULÕ iî á varietù oæ ways¬ froí suggestionó tï 
financiaì   contributions®    Alì   commentó   (good¬   baä   anä 
disastrous© arå welcome®   Speciaì thankó tï Keitè W® Antclifæ oæ 
Mead¬  Washingtoî foò hió developmenô oæ NULUTERM.ASM¬  á patcheò 
overlay¬  anä tï Roî Fowleò oæ Nightowì Softwarå foò hió graciouó 
permissioî tï includå MLOAD23.COÍ iî thå NULÕ releaså library.

Honoró  foò  Couragå gï tï Dennió Recla¬  Norí Gregory¬  anä  Jií 
Switú  foò havinç thå gutó tï "risë everything¢ bù  testinç  NULÕ 
anä offerinç suggestionó anä pointinç ouô bugs.


                          INTRODUCTION

NULÕ ió á completå replacemenô foò LÕ anä LSWEEP®  Weighinç iî aô 
15k¬ iô includeó alì featureó oæ botè programó anä theî some®  Iô 
features:

	Twï operatioî modeó witè á fulì menõ foò each
        LÕ stylå CRÃ supporô anä verification
	Viewinç  anä  printinç  oæ membeò fileó anä  disë  files¬ 
               unsqueezinç wheî necessary
	Extractioî  oæ  membeò fileó witè aî optioî tï  unsqueezå 
               wherå appropriate
	Biggeò libraries¬  uğ tï 80° memberó oò morå dependinç oî        
               availablå memory
	Automatiã membeò sorting¬  alì memberó kepô sorteä aô alì 
               times
	Faster reorganization
	Enhanced error handlingŠ        Swapped disk handling
        Automatic self-verification
	Access to deleted members
        Access to read/only libraries
        Wildcard library processing
	Optional read/only patch
        CP/M Plus support
	General compatibility with LU and NSWEEP syntax
	Numerous user patches


            DIFFERENCES BETWEEN NULU 1.5 AND NULU 1.1

NULÕ  1.µ incorporateó severaì significanô changes¬  noô leasô oæ 
whicè arå thå buç fixes®  Versioî 1.± haä severaì bugs¬ includinç 
occasionaì impropeò extractioî oæ largå files¬  anä clobberinç oæ 
byteó iî directorù entrù membeò names®   Alì knowî bugó havå beeî 
addresseä aó oæ thå ne÷ release®  (Actually¬ thå extractioî "bug¢ 
waó  duå  tï  onå  oæ  thå  bugó  iî  CP/Í  thaô  effecô  unusuaì 
combinationó oæ direcô anä sequential filå access®   Iæ yoõ watcè 
carefully¬ yoõ wilì seå BDOÓ re-allocatå useä blockó oæ thå disk¬ 
iî descendinç order¬ nï less!)

Iæ  yoõ  attempô  tï  makå  changeó tï á  librarù  filå  thaô  ió 
logically read/only, NULU will display the message:

     Library is READ-ONLY.  Modify anyway? (y/n)

anä wilì waiô foò yoõ tï saù yeó oò no®   Iæ yoõ saù no¬ theî thå 
operatioî yoõ werå attemptinç wilì bå cancelled®  Iæ yoõ saù yes¬ 
yoõ wilì bå ablå tï makå changeó anä wheî yoõ closå thå  library¬ 
the file will be read/only once again.

Therå havå beeî other¬  morå visiblå changes®  Thå disë interfacå 
haó  beeî  expandeä sï thaô severaì commandó thaô useä  tï  applù 
onlù  tï librarù membeò files¬  caî no÷ alsï worë oî disë  files®  
Theså commandó include¬  -D¬  -P¬ -Ö anä á ne÷ command¬ -S¬ whicè 
performó  á  limiteä strinç search®   Foò example¬  tï  deletå  á 
library member the command is still:

     -d filespec

but you can also delete disk files with:

     -d du:filespec

wherå  thå  drive/useò  combinatioî informó  NULÕ  thaô  yoõ  arå 
talkinç abouô disë fileó insteaä oæ librarù members®   (Notå thaô 
thå  -Ú commanä haó beeî re-assigned.© Thió syntaø applieó tï thå 
otheò commandó listeä above¬ aó well.

Additionally¬  É havå madå aî efforô tï brinç NULÕ 1.µ furtheò iî 
linå   witè  LÕ  syntaø  anä  operation¬   especiallù  LU310.COM®  
Therefore¬  iî additioî tï otheò changes¬ thå useò wilì finä thaô 
thå  -Í commanä foò thå NULÕ Commanä Menõ haó beeî changeä tï  -È Šfoò Help.


                              NULU

Tï thå besô oæ mù knowledge¬  NULÕ wilì ruî oî anù systeí runninç 
CP/Í 2.ø oò higher¬  howeveò iô haó onlù beeî testeä bù må oî thå 
Osbornå ± anä thå Osbornå Executivå computers®   Iô ió writteî iî 
808° compatible¬ Z8° assembly language.

Á  completå  discussioî oæ thå naturå anä advantageó  oæ  librarù 
fileó ió beyonä thå scopå oæ mù endurance¬  howeveò á shorô recağ 
ió iî order.

Á  librarù  filå ió á singlå CP/Í filå whicè maintainó ± oò  morå 
smalleò  fileó  aó itó members®   Eacè filå ió writteî  intï  thå 
librarù anä recordeä iî thå librarù directory®   Afteò  that¬  iô 
maù bå accesseä foò viewing¬  printing¬  oò execution¬  oò maù bå 
extracteä  froí thå librarù tï assumå thå statuó oæ á stand-alonå 
filå oncå again.

Thå reasonó foò doinç thió arå many®   Foò one¬  undeò CP/Í  eacè 
filå  occupieó á minimuí amounô oæ disë space®   Thió amounô  caî 
rangå  froí 1ë tï 16k¬  dependinç oî thå system®   Eveî thougè  á 
filå  maù  onlù  bå ± bytå iî length¬  iô wilì stilì  occupù  thå 
minimuí  requireä  amount»  thå  resô oæ  thå  spacå  ió  wasted®  
Puttinç  theså fileó iî á librarù minimizeó thå possiblå wastå tï 
12· bytes.

Eacè filå alsï occupieó á directorù entry®   Oî mosô floppù  disë 
systems¬  thå maximuí numbeò oæ filå entrieó peò disë ió 64®   Bù 
includinç  á  filå  iî á librarù thå directorù spacå iô  useä  tï 
occupù ió freeä foò anotheò file.

Additionally¬  usinç  librarù  fileó caî simplifù thå procesó  oæ 
categorizatioî  bù  subsuminç severaì fileó oæ similaò  typeó  oò 
subjectó intï onå file.

However¬  therå arå alsï dangeró associateä witè usinç libraries®  
Thå maiî onå ió thaô iæ á librarù filå ió losô oò damaged¬ alì oæ 
thå membeò fileó arå losô aó well®   Thå solutioî tï thió probleí 
caî  bå  summeä  uğ iî onå  wordº  BACKUP®  NULÕ  probablù  isn'ô 
perfect¬ anä wå alì kno÷ thaô disë systemó aren't¬ sï backuğ youò 
importanô  libraries¬  please®  É  don'ô  wanô tï  heaò  anù  saä 
stories.

Almosô  aó  importanô  aó  backinç uğ librarieó  ió  thå  uså  oæ 
discretioî wheî decidinç whaô tï puô intï them®   Let'ó facå  it¬ 
iæ  á filå ió iî á librarù iô ió noô aó easù tï geô to®   Iæ  yoõ 
neeä tï geô tï á filå everù 1µ minutes¬  iô probablù shouldn'ô bå 
iî á librarù excepô aó á backuğ measure.


                  AÎ ASIDÅ CONCERNINÇ FILESPECS
ŠWheî  specifyinç  á  filespec¬  wildcardó  maù  bå  useä  freely¬ 
however¬  unlikå  mosô programs¬  NULÕ doesn'ô insisô thaô á  ".¢ 
separatå  thå  filenamå  froí thå  filetype®   Foò  example¬  thå 
filespeã  "**¢  meanó thå samå thinç aó "*.*¢ tï  NULU®   Oî  thå 
otheò hand¬  thå filespeã "FRED.TXT¢ shoulä bå typeä iî jusô likå 
that®   "FREDTXT¢ woulä makå NULÕ thinë thaô nï filetypå haä beeî 
specified®   Thå rulå ió simpleº uså á doô anù timå yoõ like¬ buô 
iô ió onlù strictlù necessarù wheî iô ió needeä foò clarity.

Wheî  specifyinç  á  drivå and/oò useò areá thå  syntaø  ió  verù 
liberal®    "A15:**¢  meanó  thå  samå  aó  "15/A:*.*"¬  aó  doeó 
"1A5:**"®   Thå  coloî ió absolutelù necessary®   Iæ á  differenô 
useò areá ió desireä foò thå defaulô drive¬  thå drivå  specifieò 
maù  bå  omitted¬  aó iî "15:**"¬  jusô aó thå useò areá  maù  bå 
omitteä aó iî "A:**".

Iæ  á  drive/useò  specificatioî  ió made¬  buô  nï  filespeã  ió 
indicated¬ á filespeã oæ ????????.??¿ ió generated®  Thereforå tï 
indicatå thå defaulô drive¬  currenô useò area¬ anä á filespeã oæ 
????????.???¬ jusô typå á coloî bù itselæ (e.g.¬ ":"© !


                         NULU OPERATION

Wheî  NULÕ loads¬  iô automaticallù verifieó itó owî  CRC®   Thió 
procesó  causeó á 2.µ seconä delaù oî mù 4mhú machine®   However¬ 
becauså oæ thå safetù thaô thió featurå affords¬  É hopå thaô yoõ 
wilì finä iô tï bå á reassurinç pause®   Notå thaô thå CRÃ ió noô 
affected by normal user patches.

NULÕ  maù bå invokeä witè oò withouô á commanä tail®   Á  commanä 
taiì caî consisô oæ anù combinatioî oæ valiä NULÕ operatoró uğ tï 
12¸  characteró  (thå limiô imposeä bù thå  CCP®   Oncå  NULÕ  ió 
running¬ commanä lineó caî bå aó lonç aó 25´ characters.)

Aó  iî LU¬  alì NULÕ commandó arå precedeä bù á dash®   Thió ió á 
copù oæ thå menõ foò thå commanä modå oæ operation:

          -A Add members            -B Brief toggle
          -C Close the library      -D Delete members/files
          -E Extract members        -F Filesweep mode
          -G Get filespec           -H Help
          -K Krunch library         -L List members
          -N Rename members         -O Open a library
          -P Print members/files    -Q Unsqueeze members
          -R Replace members        -S String search
          -T Replace/Add members    -U Drive/User change
          -V View members/files     -W Wildcard open
          -X Exit NULU              -Y Disk directory
          -< Redirect input         -> Redirect output

Commandó  maù  bå strunç together¬  eacè terminateä bù  á  space®  
Theù arå processeä lefô tï right®   Alì characteró arå  converteä 
tï uppeò case.
ŠThå  defaulô drive/useò areá arå displayeä alonç witè thå namå oæ 
thå  currenô commanä modå eacè timå thå consolå ió  prompteä  foò 
input.

Thå  commandó  wilì  bå explaineä iî ordeò  oæ  theiò  appearancå 
above®    Alì   itemó  iî  [squarå  bracketsİ  indicatå  optionaì 
parameters®  Thå  worä  "filename¢ referó tï aî unambiguouó  filå 
specification¬  whilå thå terí "filespec¢ referó tï á potentiallù 
ambiguouó  filå specification®   Filespeã parameteró encloseä  iî 
(parenthesis© indicatå referenceó tï deleteä membeò files®  Threå 
dotó ("..."© afteò á parameteò indicatå infinitå repetition.

Durinç thå executioî oæ mosô commandó whicè receivå aî  ambiguouó 
filespeã  aó  á  parameter¬  enterinç á ^Ã aô  thå  consolå  wilì 
interrupt the current process.


                            COMMANDS

-A       ADD MEMBERS
         Syntax: -a filespec[ filespec...]

         Uså  thió commanä tï adä fileó froí disë tï thå  currenô 
         library®   NULÕ wilì makå á serieó oæ passeó througè thå 
         directory¬  addinç  fileó aó iô goes¬  untiì thå lisô oæ 
         matchinç  fileó ió exhausted®   Iæ á  matchinç  filenamå 
         alreadù  existó aó aî activå membeò iî thå library¬  itó 
         namå wilì bå displayeä anä thå filå wilì noô bå added.

         Iî  alì filå additioî anä replacemenô operations¬  iæ  á 
         deleteä  entrù  oæ identicaì sizå caî bå  located¬  thaô 
         disë spacå anä directorù entrù wilì bå useä ratheò  thaî 
         allocatinç  ne÷ spacå foò thå file®   Thió meanó thaô iô 
         wilì  bå  necessarù tï reclaií wasteä  disë  spacå  lesó 
         often.

         An LU style CRC will be generated for each file added.

-B       BRIEF TOGGLE
         Syntax: -b

         Thió toggleó thå promptinç mode®  Thå releaså versioî oæ 
         NULÕ ió setuğ tï prinô thå fulì namå oæ thå currenô modå 
         foò  á prompt¬  aó iî "-Add members A0:>"®   Iæ BRIEÆ ió 
         turneä oî thå useò wilì simplù seå "-Á A0:>"®   NULÕ maù 
         bå  permanentlù patcheä tï defaulô tï BRIEÆ OÎ  oò  OFF®  
         Seå NULÕ MODIFICATION.

-C       CLOSE THE LIBRARY
         Syntax: -c

         Thió  commanä  closeó thå currenô library¬  writinç  itó 
         directorù  tï disë iæ anù changeó havå beeî madå tï  thå 
         directory®   Thå  librarù  directorù  ió  NEVEÒ  writteî 
         excepô wheî thå librarù ió closed¬  sï bå surå tï dï it®  Š         Iæ  yoõ forgeô tï dï sï anä removå thå disk¬  NULÕ  wilì 
         prompô  yoõ  foò  thå disë agaiî  anä  wilì  attempô  tï 
         recover.

         Somå  otheò operationó thaô causå thå currenô librarù tï 
         bå closeä are:
               -k, -o, -w, -x

-D       DELETE MEMBERS/FILES
         Syntax: -d filespec[ filespec (filespec)...]
         Syntax: -d du:filespec[ du:filespec...]

         Iæ thå drive/useò specificatioî ió included¬  thå DELETE 
         functioî  wilì  applù  tï fileó oî  disk¬  otherwiså  iô 
         applies to library member files.

         Membeò  fileó matchinç thå giveî filespeã wilì bå  giveî 
         deleteä statuó iî thå librarù directory¬ excepô wheî thå 
         filespeã  ió  encloseä iî  parenthesis®   Iî  thaô  caså 
         matchinç  deleteä  memberó wilì bå giveî activå  status®  
         Thaô is¬  theù wilì bå undeleted®   Iæ thå filenamå oæ á 
         matchinç deleteä membeò filå alreadù existó aó aî activå 
         member¬ thå filenamå wilì bå displayeä anä thå filå wilì 
         noô bå undeleted.

         Iæ  thå  membeò filå beinç deleteä haó á  sizå  oæ  zerï 
         sectors¬  itó  entrù  wilì bå entirelù REMOVEÄ froí  thå 
         library directory, thereby creating a new, free entry.

-E       EXTRACT MEMBERS
         Syntax: -e filespec[=newfilespec filespec du:filespec...]

         Uså  thió commanä tï extracô activå  membeò  files®   Iæ 
         extractioî tï thå currenô drive/useò areá ió desired¬ nï 
         furtheò syntaø ió necessary®  Tï indicatå anotheò drive¬ 
         however¬  á destinatioî drive/useò areá maù bå  includeä 
         in the source filespec.  Example:

         -e a5:**

         woulä  extracô alì activå memberó tï drivå A¬  useò areá 
         5®   Fileó  maù  bå  renameä aó welì  aó  redirecteä  bù 
         indicatinç  á filespeã alonç with¬  oò iî  placå  of¬  á 
         drivå  useò  specificatioî  followinç  aî  equaló  sign®  
         Examples:

         1.  -e *asm=*bak
         2.  -e *asm=5:*txt
         3.  -e fred.txt=sam.txt jane.inf=c8:girls.dbf

         Thå exampleó woulä producå thå followinç results:

         1®  Extracô alì fileó witè á typå oæ .ASÍ tï thå defaulô 
         drive/useò renaminç theí witè thå filetypå oæ .BAK.
         2®  Extracô alì fileó oæ typå .ASÍ tï useò areá µ oæ thå Š         defaulô drive¬ renaminç eacè witè thå .TXT filetype.
         3®   Extracô  thå  membeò filå FRED.TXÔ tï  thå  defaulô 
         drive/useò  undeò thå namå oæ SAM.TXT¬  anä extracô  thå 
         membeò filå JANE.INÆ tï useò areá ¸ oæ drivå Cº witè thå 
         filenamå GIRLS.DBF.

         Thå  twï  redirectioî  ruleó tï remembeò areº  1©  iæ  á 
         destinatioî  filespeã ió entereä iô cannoô bå  anù  lesó 
         ambiguouó thaî thå sourcå filespec¬ i.e.¬ "*asm=*bak¢ ió 
         valiä whilå "**=*bak¢ ió noô valid»  anä 2© anù filespeã 
         followinç  aî  equaló  sigî takeó  precedencå  oveò  anù 
         drive/useò  specificatioî iî thå sourcå filespec¬  i.e.¬ 
         "-å  6:*asm=*bak¢ woulä extracô alì membeò fileó tï  thå 
         currenô drive/user¬  renaminç them¬ anä woulä ignorå thå 
         "6:" specification.

         Durinç  extraction¬  á CRÃ ió generateä foò  eacè  file®  
         Afteò  thå destinatioî filå haó beeî closed¬  thå CRÃ sï 
         generateä ió compareä tï thå CRÃ foò thaô librarù membeò 
         thaô waó storeä iî thå librarù directory¬  iæ thaô valuå 
         waó  non-zero®   Iæ thå resultó arå  noô  identical¬  aî 
         erroò  messagå wilì bå displayeä beforå thå nexô  membeò 
         filå  oò  filespeã  wilì bå  processed®   Thå  erroneouó 
         destinatioî  filå wilì noô bå deleteä froí disë bù  NULÕ 
         aó á resulô oæ thió error.

-F       FILESWEEP MODE
         Syntax: -f

         Thió commanä placeó NULÕ iî itó seconä operationaì modeº 
         thå  filesweeğ  mode®   Thió  allowó thå  useò  tï  movå 
         througè thå directorù oæ activå membeò fileó aó iæ  theù 
         werå  individuaì fileó beinç examineä bù á prograí  likå 
         NSWEEP®    Thå  filesweeğ  mode'ó  commanä  lisô  ió  aó 
         follows:

         A Next member              B Previous member
         C Close library            D Delete member
         E Extract member           F Find member
         L Log new drive/user       M Mass operations
         O Open new library         P Print member
         Q Unsqueeze member         R Rename member
         T Tag member               U Untag member
         V View member              W Wildcard rename
         X Exit NULU                Y Disk directory
         Z NULU command mode        ? Help!

         Becauså oæ thå extremå similaritù betweeî theså commandó 
         anä  thå commandó oæ NULU'ó commanä mode¬  onlù á  shorô 
         descriptioî  oæ  eacè commanä wilì bå  giveî.

         Á  --  Advancå tï nexô member
                (spacebar¬  cr¬  oò  læ  wilì  producå  thå  samå 
                result)
         Â  --  Bacë uğ tï previouó memberŠ         Ã  --  Closå thå currenô library
         Ä  --  Deletå currenô membeò file
         Å  --  Extracô currenô membeò filå
                (prompô allowó redirection)
         F  --  Find first member matching input filespec
         Ì  --  Change drive/user defaults
                (returnó filå pointeò tï thå toğ oæ thå filå lisô 
                and untags all member files)
         M  --  Mass operations on all tagged files
                (allowó    Deletion¬     Extraction¬    Printing¬ 
                Unsqueezing¬ or Viewing)
         O  --  Open new library (closes the current library)
         Ğ  --  Dumpó thå currenô membeò filå tï LSTº
                (unsqueezeó iæ needed)
         Ñ  --  Extracô  currenô  membeò  file¬   unsqueezinç  iæ
                necessarù (prompô allowó redirection)
         R  --  Rename current member file
         T  --  Tag current member
         Õ  --  Untag current member
         Ö  --  Vie÷ currenô membeò filå (unsqueezeó iæ needed)
         ×  --  Wildcarä  renamå (promptó foò oldnamå & newname)
         X  --  Exit NULU (closes all files)
         Y  --  Get disk directory for default drive/user
                (returnó filå pointeò tï thå toğ oæ thå filå lisô 
                and untags all member files)
         Ú  --  Returî  tï NULÕ commanä  modå
                (currenô librarù remainó open)
         ?  --  Print the filesweep mode menu

         If¬  wheî  thå  filesweeğ modå ió entered¬  oò  afteò  á 
         librarù  haó  beeî  closed¬   therå  ió  noô  á  librarù 
         currentlù open¬ thå filesweeğ modå wilì prompô with:

         No library open.

         and will accept only the following commands:

         L,O,X,Y,Z,?

         Likewise¬  iæ á librarù ió opeî buô onlù haó á directorù 
         witè nï otheò activå members¬ thå message

         No member files.

         wilì bå printeä anä onlù thå commandó listeä above wilì 
         be accepted.

         Durinç filesweeğ operation¬  eacè filå wilì bå listeä iî 
         thå  ordeò iî whicè iô ió founä iî thå directory¬  alonç 
         witè thå sizå iî Ë thaô thå filå woulä occupù iæ iô werå 
         extracteä tï thå defaulô drive.

         Iæ  thå filesweeğ modå ió terminateä bù á returî tï  thå 
         NULÕ  commanä  mode¬  anù commandó thaô followeä thå  -Æ 
         commanä  oî  thå  previouó NULÕ  commanä  linå  wilì  bå Š         executed.

-G       GET FILESPEC
         Syntax: -g filespec

         NULÕ  wilì searcè foò thå filespeã indicated®   Iæ iô ió 
         found¬  processinç  continues®   Iæ  not¬  thå  useò  ió 
         prompteä  tï inserô thå disë containinç  thaô  filespec®  
         Thå  drivå ió theî reseô anä searcè again®   Thå prograí 
         wilì  prompô  foreveò  untiì  iô  receiveó  thå   propeò 
         filespeã  oò  untiì  á ^Ã ió entered¬  forcinç  NULÕ  tï 
         continuå withouô thå filespeã beinç found.

         Thió  commanä caî bå usefuì wheî attemptinç  tï  controì 
         NULÕ  througè  á submiô utilitù likå  DRI'ó  SUBMIT.COM®  
         For example, one might type:

         nulu -o a:asm -g b5:-work.005 -e b10: -g a0:-5.005 -x

         Afteò loading¬  NULÕ woulä opeî á librarù calleä ASM.LBÒ 
         oî  drivå Aº  iî thå currenô useò area®   Nexô iô  woulä 
         searcè  useò areá µ oæ drivå Bº  foò filespeã  -WORK.00µ 
         untiì  iô  waó  found®   Theî alì  activå  membeò  fileó 
         woulä  bå  extracteä  tï  useò  areá  1°  oæ  drivå  B:®  
         Finally¬ NULÕ woulä searcè useò areá ° oæ drivå Aº foò á 
         filespeã  calleä  -5.00µ untiì found®  Theî  NULÕ  woulä 
         terminate®  Noticå herå thaô thå ASM.LBÒ didn'ô havå  tï 
         bå  closeä  beforå  thå searcè foò  thå  finaì  filespeã 
         becauså   nï  changå  haä  beeî  madå  tï  thå   librarù 
         directory®   Iæ  á changå haä beeî made¬  afteò thå  ne÷ 
         filespeã haä beeî loaded¬  NULÕ woulä havå demandeä  thå 
         disë witè ASM.LBÒ bacë sï iô coulä updatå thå directory®  
         Thereforå   thå  GEÔ  operatioî  woulä  bå   effectivelù 
         negated.

-H       HELP
         Syntax: -h

         Print the command mode menu.

-K       KRUNCH LIBRARY
         Syntax: -k[ <number of entries to allow]

         Eveî  thougè alì memberó arå kepô iî alphabeticaì  ordeò 
         aô alì times¬ wheî á membeò ió deleteä thå disë spacå iô 
         occupieó  ió noô releaseä tï thå operatinç systeí  untiì 
         thå KRUNCÈ commanä ió executed®   KRUNCÈ consistó oæ thå 
         following steps:

         1®    Iæ  á filå oæ thå samå namå aó thå librarù alreadù 
         existó  iî thå defaulô drive/useò areá ANÄ  THE  LIBRARY 
         FILÅ  ORIGINATEÓ FROÍ Á DIFFERENÔ DRIVE/USER¬  á messagå 
         indicatinç  thaô thå filå existó wilì bå  displayeä  anä 
         thå KRUNCÈ commanä wilì bå skipped®  Yoõ musô deletå thå 
         offendinç  filå  oò  changå drive/useò areá  beforå  thå Š         KRUNCH can be effected.
         2®   Thå librarù ió closed.
         3®   Á ne÷ librarù calleä WORK-LBR.$$¤ ió openeä iî  thå 
         defaulô  drive/useò  areá  anä thå useò ió  prompteä  tï 
         inpuô thå numbeò oæ fileó thaô thå ne÷ librarù shoulä bå 
         ablå tï contain®   Iæ thå useò wantó jusô enougè entrieó 
         tï contaiî thå currentlù activå members¬ thå numbeò ± oò 
         anù  numbeò lesó thaî oò equaì tï thå currenô numbeò  oæ 
         activå  entrieó  maù  bå  entered®    Iæ  thå   optionaì 
         parameteò  listeä abovå ió entered¬  iô wilì bå useä  aó 
         thå  numbeò  oæ  entries®   (Thå KRUNCÈ procesó  maù  bå 
         aborteä  herå bù typinç RETURÎ oò 0®   Pleaså notå  thaô 
         thå  librarù  directorù  countó aó  aî  entrù  anä  wilì 
         automaticallù bå accounteä foò bù NULU.)
         4®    Oncå  WORK-LBR.$$¤ ió opened¬  thå  activå  membeò 
         fileó  froí  thå originaì librarù wilì bå copieä onå  bù 
         onå  intï  thå  ne÷ library®  Thå copù  routinå  useó  á 
         recursivå  procesó tï copù aó manù fileó aô onå timå  aó 
         possible®  Á CRÃ ió calculateä foò eacè membeò aó iô  ió 
         copied®   Iæ thió numbeò doeó noô matcè thå CRÃ recordeä 
         iî thå originaì librarù directory¬ thå message:

         CRC ERROR-Continue? (y/n)

         wilì appeaò afteò thå filenamå iî question®  Á replù  oæ 
         "N¢  wilì  resulô iî thå worë librarù beinç deleteä  anä 
         thå  originaì librarù beinç  re-opened®   Otherwiså  thå 
         newlù  generateä CRÃ foò thå filå wilì bå storeä iî  thå 
         directory of the new library.
         5®   Thå  olä  librarù ió deleteä  anä  WORK-LBR.$$¤  ió 
         renameä witè thå olä librarù name.

         Examples:
         1.  -k
         2.  -k <1
         3.  -u b5: -k <63
         4.  -u b5: -k <1 -u a0: -k <63

         The above examples would produce the following results:

         1®   Thå  librarù  woulä  bå  KRUNCHeä  tï  thå  defaulô 
         drive/useò  area®   Thå useò woulä bå prompteä tï  inpuô 
         the number of entries to allow.
         2®   Thå  librarù  woulä  bå  KRUNCHeä  tï  thå  defaulô 
         drive/useò  areá witè jusô enougè entrieó tï contaiî alì 
         currently active member files.
         3®   Thå defaulô drive/useò areá woulä bå changeä tï B5º 
         beforå  thå  KRUNCÈ begins®   Theî thå librarù woulä  bå 
         KRUNCHed¬ allowinç 6³ entries.
         4®   Thå defaulô drive/useò areá woulä bå changeä tï B5º 
         beforå  thå  KRUNCÈ begins®  Thå KRUNCÈ woulä  commence¬ 
         allowinç  onlù  enougè  entrieó tï  contaiî  alì  activå 
         members®   Thå drive/useò areá woulä bå changeä tï  A0:® 
         Theî  thå librarù woulä bå KRUNCHeä again¬  allowinç  6³ 
         entries.Š
-L       LIST MEMBERS
         Syntax: -l[ filespec]
         Syntax: -l[ (filespec)]

         Uså  thió  commanä tï lisô thå contentó oæ  thå  librarù 
         directory®   Eacè  membeò filenamå wilì printeä followeä 
         bù  thå startinç relativå sectoò numbeò iî  thå  librarù 
         file¬  thå sizå oæ thå membeò iî sectors¬  thå sizå iî Ë 
         thaô thå filå woulä occupù iæ iô werå tï bå extracteä tï 
         thå  defaulô drive/useò area¬  anä thå CRÃ foò thå file®  
         Finally¬  á recağ oæ thå sizå oæ alì membeò fileó listeä 
         ió printed¬ alonç witè thå numbeò oæ sectoró occupieä bù 
         deleteä files.

         Thå  parameteró listeä abovå caî bå useä tï controì  thå 
         selection of files for display.  Examples:

         1.  -l
         2.  -l **
         3.  -l (**)
         4.  -l *asm
         5.  -l (fred.txt)

         The above examples would produce the following results:

         1.  All active member files listed.
         2.  All active member files listed.
         3.  All deleted member files listed.
         4®  Alì  activå  membeò fileó  matchinç thå filespeã  oæ 
         ????????.ASM listed.
         5®   Alì  deleteä membeò fileó calleä  FRED.TXÔ  listed®  
         (Notå  thaô ió IÓ possiblå tï havå morå thaî onå deleteä 
         file with the same name.)

-N       RENAME MEMBERS
         Syntax: -n oldfilespec=newfilespec[...]
         Syntax: -n (oldfilespec)=newfilespec[...]

         Thió  commanä ió useä tï renamå activå oò deleteä membeò 
         files®    Wildcardó   arå  fullù  supported¬   buô   thå 
         newfilespeã   caî   bå  nï  lesó  ambiguouó   thaî   thå 
         oldfilespec®    Deleteä   memberó  maù  bå  renameä   bù 
         enclosinç   thå   oldfilespeã   ONLÙ   iî   parenthesis®  
         Examples:

         1.  -n *asm=*bak
         2.  -n (fred.txt)=sam.txt
         3.  -n **=**

         The above examples would produce the following results:

         1®    Alì   activå   memberó   matchinç   thå   filespeã 
         ????????.ASM would be renamed with a filetype of .BAK.
         2®   Thå firsô deleteä membeò filå calleä FRED.TXÔ woulä Š         bå renameä tï SAM.TXT®   Alì otheò memberó matchinç thaô 
         filespeã woulä bå listeä alonç witè á messagå indicatinç 
         that they could not be renamed.
         3®  Alì activå membeò fileó woulä bå listed¬ eacè witè á 
         messagå  indicatinç  thaô  theù  coulä  noô  bå  renameä 
         because the name already exists.


-O       OPEN A LIBRARY
         Syntax: -o filename[ <number of entries to allow]

         Witè   thå  exceptioî  oæ  thå  filesweeğ  Opeî  Librarù 
         command¬  thió  ió thå onlù methoä tï opeî oò  creatå  á 
         library®   NULÕ  wilì searcè foò thå filenamå indicated®  
         Iæ iô ió found¬  iô wilì bå openeä anä á messagå wilì bå 
         displayeä  indicatinç  thå  sizå oæ  thå  Datá  Transfeò 
         Buffer®   Thió  ió thå numbeò oæ sectoró iî memorù  thaô 
         NULÕ wilì havå tï uså iî extracting¬  addinç oò  copyinç 
         membeò files.

         Iæ thå filå ió noô found¬  thå useò wilì bå prompteä foò 
         thå  numbeò oæ entrieó tï allo÷ iî thå ne÷ library®   Iæ 
         thå optionaì parameteò abovå ió passed¬  thå numbeò wilì 
         bå useä tï determinå thå directorù sizå oæ thå  library®  
         Alì  directorieó caî contaiî somå multiplå oæ ´ entries®  
         Alì  numberó  inpuô wilì bå roundeä uğ  tï  thå  nearesô 
         multiplå  oæ  4®   Remembeò  thaô thå  directorù  itselæ 
         countó  aó  onå entrù anä thaô NULÕ  wilì  automaticallù 
         makå spacå foò it.

         The filename passed must be unambiguous.

         NOTE ON DIRECTORY SIZE:
         Dependinç oî availablå memory¬ librarieó witè aó manù aó 
         80°  entrieó (theoretically© caî bå opened®   Buô  watcè 
         thå Datá Buffeò Size¡   Iæ iô ió lesó thaî ¹ sectoró yoõ 
         wilì noô bå ablå tï unsqueezå anù files® Witè á useò TPÁ 
         oæ 58k¬  É havå beeî ablå tï opeî librarieó witè nï morå 
         thaî  58´ totaì memberó anä stilì bå lefô witè á  buffeò 
         oæ  ¹  sectors®   (Seå  -¼ commanä anä  ho÷  iô  affectó 
         librarù memory.)

-P       PRINT MEMBERS/FILES
         Syntax: -p filespec[ filespec (filespec)...]
         Syntax: -p du:filespec[ du:filespec...]

         Iæ thå drive/useò specificatioî ió included¬  thå  PRINÔ 
         functioî  wilì  applù  tï fileó oî  disk¬  otherwiså  iô 
         applieó tï librarù membeò files.

         Witè thió command¬  thå ascié contentó oæ fileó matchinç 
         thå  filespecó giveî wilì bå dumpeä tï thå lisô  device®  
         Iæ  thå  filå  ió  squeezed¬  NULÕ  wilì  unsqueezå  it®  
         Deleteä  librarù memberó maù bå listeä bù enclosinç  thå 
         appropriatå filespeã iî parenthesis.Š
-Q       UNSQUEEZE MEMBERS
         Syntax: -q filespec[=newfilespec filespec...]

         Thió commanä ió identicaì iî operatioî anä syntaø tï thå 
         EXTRACÔ command¬ excepô thaô iæ thå matchinç memberó arå 
         squeezed, they will be unsqueezed.

-R       REPLACE MEMBERS
         Syntax: -r filespec[ filespec...]

         Thió commanä ió identicaì iî operatioî anä syntaø tï thå 
         ADÄ command¬ excepô thaô matchinç fileó wilì bå addeä tï 
         thå  librarù ONLÙ iæ theù alreadù exisô iî thå  library®  
         They will be deleted, then the new files will be added.

-S       STRING SEARCH
         Syntax: -s filespec "string to search for"
         Syntax: -s du:filespec "string to search for"

         Iæ thå drive/useò specificatioî ió included¬  thå SEARCÈ 
         functioî  wilì  applù  tï fileó oî  disk¬  otherwiså  iô 
         applieó tï librarù membeò files.

         Thió  provideó á waù tï dï á SIMPLÅ searcè foò  á  giveî 
         strinç amonç á grouğ oæ files®  Iæ thå "strinç tï searcè 
         for¢ ió founä yoõ wilì bå notified®   Alì fileó searcheä 
         arå listed®   Thå individuaì linå oî whicè thå iteí  waó 
         matcheä  ió noô displayeä becauså thå matcè ió noô  madå 
         oî á linå basis®   Thaô is¬ yoõ maù searcè .COÍ fileó oò 
         squeezeä  .OVÒ  fileó jusô aó easilù aó  searchinç  texô 
         files®  However¬ thå implementatioî ió admittedlù ratheò 
         weaë aô thió poinô aó thingó likå controì characteró anä 
         tabó  arå  rippeä  ouô oæ thå commanä  linå  beforå  thå 
         searcè  functioî  eveî seeó thå command®   Enjoù iô  anä 
         I'll improve it later.

-T       REPLACE/ADD MEMBERS
         Syntax: -t

         Thió commanä ió á combinatioî oæ thå ADÄ anä thå REPLACÅ 
         commands®   Iæ  thå  fileó dï noô exisô iî thå  library¬ 
         theù  wilì bå added®   Iæ theù dï exist¬  theù  wilì  bå 
         replaced.

-U       DRIVE/USER CHANGE
         Syntax: -u new drive/user

         Uså  thió commanä tï changå thå defaulô drive/useò area®  
         A colon (":") must follow the drive/user spec.  Example:

         -u a5:

         would switch the default drive/user area to A5:.
Š-V       VIEW MEMBERS/FILES
         Syntax: -v filespec[ filespec (filespec)...]
         Syntax: -v du:filespec[ du:filespec...]

         Iæ  thå drive/useò specificatioî ió included¬  thå  VIE× 
         functioî  wilì  applù  tï fileó oî  disk¬  otherwiså  iô 
         applieó tï librarù membeò files.

         Thió  commanä wilì lisô thå ascié contentó oæ alì  fileó 
         matchinç  thå  giveî  filespeã tï  thå  consolå  device®  
         Deleteä  librarù  memberó maù bå indicateä bù  enclosinç 
         thå filespeã iî parenthesis®  Iæ thå fileó arå squeezed¬ 
         theù wilì bå unsqueezed®  Aô eacè page¬ NULÕ wilì accepô 
         onå  oæ thå followinç commands:

         1.  ^X to skip to the next matching file
         2.  ^C to abort further listing
         3.  L to list one line
         4.  CR, space, or LF to list another full page

         Aô  thå  enä  oæ eacè filå  thå  messagå

          "Presó RETURN¢

         wilì  bå  displayeä anä NULÕ wilì waiô foò  á  keystrokå 
         beforå movinç tï thå nexô matchinç file.

-W       WILDCARD OPEN
         Syntax: -w filespec commands to process

         For advanced users only.

         Thió  caî bå onå oæ thå mosô powerful¬  anä possiblù thå 
         mosô  dangerous¬  oæ alì NULÕ commands®   Iô allowó  thå 
         useò  tï specifù á grouğ oæ librarieó oî whicè tï leô  á 
         seô oæ commandó operate®  Á simplå example:

         -w a5:*lbr -l

         woulä opeî alì fileó founä oî drivå Á iî useò areá µ  aó 
         librarieó  anä  lisô thå contentó oæ each®   Thió  woulä 
         happeî  iî sequencå foò alì matchinç fileó iî thå  ordeò 
         iî  whicè theù werå founä iî thå directory®   Notå  thaô 
         thió  commanä  haó  thå samå effecô aó  thå  -Ï  commanä 
         excepô thaô iô processeó wildcarä librarù filespecó  anä 
         thaô  thå  user'ó  controì oveò eacè librarù  openeä  ió 
         limiteä tï thå singlå linå thaô invokeó thå -×  command®  
         Thaô  is¬  alì commandó applyinç tï eacè librarù  openeä 
         musô bå contained oî thå onå commanä line.

         Thå  advenô  oæ thió commanä ió thå reasoî thaô  certaiî 
         commandó  thaô useä tï bå restricteä tï NCÆ  redirectioî 
         fileó arå no÷ availablå aô thå commanä level®  Takå thió 
         example:
Š         -w *lbr -k <5 -p ** -l -' "hit enter for next file " -:

         Thaô  commanä  woulä  resulô iî thå followinç  foò  eacè 
         matching file:
         1)  The library would be KRUNCHed to 5 members.
         2)  All member files would be sent to LST:.
         3)  The library directory would be listed.
         4©  Thå prompt¬  "PRESÓ ENTEÒ FOÒ NEXÔ FILÅ ¢  woulä  bå 
         displayeä tï CON:
         5©  NULÕ woulä waiô foò thå useò tï presó RETURÎ  beforå 
         passinç controì bacë tï -× whicè woulä theî dï thå  samå 
         thing for the next library.

         Uså á loô oæ cautioî wheî usinç thió command®  Iô ió ne÷ 
         eveî tï me¬  buô É havå founä iô tï bå EXTREMELÙ useful®  
         I really like this one:

         -w *lbr -f

         whicè  allowó  må tï looë aô á loô oæ librarieó  througè 
         filesweep without having to know their names.

         I have tried something like this:

         -w *lbr -< command.ncf

         buô witè verù disappointinç results®   Iô doesn'ô  work®  
         É  wilì worë oî thaô foò nexô time¬  iæ therå ió á  nexô 
         time.

-X       EXIT NULU
         Syntax: -x

         Thió  commanä wilì seô á flaç indicatinç thaô  wheî  thå 
         currenô  NULÕ  commanä linå ió  exhausted¬  NULÕ  shoulä 
         terminate®  Buô thå commanä ió actuallù á toggle®  Iæ iô 
         ió  entereä  twicå  oî á linå thå effecô oæ  thå  seconä 
         issuancå  wilì  bå tï negatå thå first®   Notå thaô  thå 
         supporô   foò   commanä  chaininç  haó   beeî   removed®  
         Examples:

         1.  -x
         2.  -x -x

         The above examples would produce the following results:

         1®  Thå  terminatioî  flaç  wilì bå seô  anä  NULÕ  wilì 
         terminate when the current command line is exhausted.
         2®   Thå terminatioî flaç ió seô anä theî  reset®   NULÕ 
         doeó noô terminate.

-Y       DISK DIRECTORY
         Syntax: -y[ filespec]

         Thió  commanä  wilì prinô aî unsorteä directorù  oæ  thå Š         disë  indicateä bù thå parameteò passed¬  oò á  completå 
         directorù iæ nonå ió passed®  Thå scopå oæ thå directorù 
         maù  bå limiteä bù indicatinç thå appropriatå  ambiguouó 
         filespec®  Iæ thå dií oò reverså videï stringó havå beeî 
         defined¬  NULÕ wilì uså thaô characteristiã tï  indicatå 
         thaô  certaiî  filå  attributå  bitó  arå  seô  iî  eacè 
         filename.

-Z       ZAP DISK FILES
         Syntax: -z filespec

         Uså  thió  commanä  tï  deletå disë  fileó  whilå  stilì 
         runninç NULU®  Eacè filå matchinç thå ambiguouó filespeã 
         giveî  wilì  bå listeä anä deleted®   Librarieó  caî  bå 
         deleteä jusô aó easilù aó anù otheò typå oæ file¬  sï bå 
         careful®   Thå  onlù  protectioî  affordeä ió  thaô  thå 
         library currently open, if any, will never be deleted.

-<       REDIRECT INPUT
         Syntax: -< filename

         Thió  commanä  wilì  causå NULÕ  tï  opeî  thå  filenamå 
         indicateä  anä begiî acceptinç commandó froí iô  insteaä 
         oæ  receivinç theí froí thå console®   Thió typå oæ filå 
         is¬  iî effect¬ á NULÕ Commanä File®   Thå filetypå wilì 
         defaulô tï ".NCF¢ iæ nï filetypå ió specified® Syntaø oæ 
         thå commandó iî thió filå ió compatible iî everù waù  tï 
         thå  syntaø  useä iî normaì NULÕ  operation®  Additionaì 
         functionó havå beeî addeä tï facilitatå thå  developmenô 
         oæ  NCÆ  files®  Eacè commanä linå iî thå filå  musô  bå 
         terminateä  bù á CR,LF¬  anä wilì bå converteä tï  uppeò 
         caså  anä echoeä tï thå consolå beforå  processing®  Thå 
         lasô linå iî thå filå shoulä enä witè aô leasô twï CR,LÆ 
         combinations®   Afteò   alì   NCÆ  commandó  havå   beeî 
         processed¬  controì wilì bå returneä tï thå console® Anù 
         commandó appearinç afteò á "-<¢ commanä wilì bå ignored.

         Iæ anotheò "-<¢ commanä ió encountereä iî thå file¬  thå 
         currenô  commanä filå wilì bå suspendeä anä thå ne÷ filå 
         opened®   Wheî  thå commandó iî thaô ne÷ filå  havå  alì 
         beeî processed¬  controì wilì "return¢ tï thå filå  thaô 
         "called¢ thå ne÷ file®  Thió nestinç caî continuå tï thå 
         leveì  alloweä  bù  thå  numbeò  oæ  inpuô  fileó  patcè 
         describeä  iî  NULÕ  MODIFICATION®    (Iô  caî  actuallù 
         continuå  tï á mucè deepeò leveì iæ nï librarù ió  open¬ 
         but what's the point?  Hmmm... maybe a tutorial...)

         The filename passed must be unambiguous.

         Oæ  thå  followinç commands¬  theså arå valiä onlù  wheî 
         receiveä froí aî NCÆ fileº  -j¬  -z¬ -"®  Thå otheró maù 
         bå  useä  aô  anù timå buô arå  includeä  herå  anä  arå 
         omitteä  froí  thå  menõ becauså oæ  theiò  programmatiã 
         nature.
Š-----------------------------------------------------------------
-J       JUMP TO LINE
         Syntax: -j line number

         Uså  thió  commanä tï havå NULÕ  starô  readinç  commanä 
         lineó  froí  thå  currenô NCÆ filå aô  thå  linå  numbeò 
         indicated®  Thå example:

         -j 1

         woulä causå NULÕ tï starô readinç lineó froí thå currenô 
         NCÆ  filå  beginninç  aô  linå  numbeò  1®  Forwarä  anä 
         backwarä  referenceó arå allowed®   Á referencå tï  linå 
         numbeò  °  wilì  bå ignored®   Anù  referenceó  tï  non-
         existenô linå numberó wilì causå thå currenô NCÆ filå tï 
         terminate¬  therebù  returninç  tï thå nexô  higheò  NCÆ 
         level¬ oò tï thå commanä modå iæ thió ió thå highesô NCÆ 
         level.

         Notå thaô iæ yoõ adä oò deletå anù lineó iî aî NCÆ file¬ 
         thaô  wilì completelù fouì uğ anù jumğ commandó iî  thaô 
         file.  That's a bug, not a feature.

-Z       TOGGLE CONSOLE
         Syntax: -z

         Thió  command toggleó alì outpuô tï thå consolå  device®  
         Thaô  is¬  iæ thió commanä ió issueä once¬  alì  consolå 
         outpuô ió shuô down¬  witè thå exceptioî oæ thå  speciaì 
         commandó  listeä  below®   Issuå iô again¬  anä  consolå 
         output will be re-enabled.

-'       PRINT TEXT
         Syntax: -' "text to print"

         Uså thió commanä tï prinô texô tï thå console¬ nï matteò 
         whaô thå conditioî oæ thå consolå outpuô toggle® Texô tï 
         bå  printeä  musô bå encloseä iî  quotes®   Thå  openinç 
         quotå  MUSÔ  bå present¬  buô thå closinç quotå ió  onlù 
         necessary to delimit any following commands.

-"       PROMPT AND CHAIN TO PREVIOUS MODE
         Syntax: -mode to chain to -" "prompt" -failure mode

         Mù  methoä oæ syntaø diagramminç falló utterlù shorô  oæ 
         describinç thió command¬ É know®  Let'ó takå iô onå steğ 
         aô  á time®   Thió commanä allowó thå NULÕ programmeò tï 
         specifù thå modå tï whicè hå wisheó tï pasó á parameter¬ 
         prompô thå useò foò thaô parameter¬  anä tï alsï specifù 
         actionó tï bå takeî iæ nï responså ió receiveä froí  thå 
         user.  Now for an example...

         -y *lbr -o -" "open which library? " -j 65535

         The following result would be produced:Š         1®  Á directorù listinç oæ alì fileó witè á typå oæ .LBÒ 
         woulä  bå  listeä tï thå consolå devicå iæ  thå  consolå 
         were toggled on.
         2®  Thå OPEÎ LIBRARÙ modå woulä bå transparentlù entereä 
         just long enough for NULU to take note of it.
         3.  The console would be prompted with the message:

         (CR, LF)
         OPEN WHICH LIBRARY? 

         anä NULÕ woulä waiô foò thå useò tï enteò á linå oæ texô 
         NOÔ EXCEEDINÇ thå lengtè oæ thå prompt(!)®   Iæ thå useò 
         entereä anä RETURÎ bù itselæ oò á nulì line¬  thå prompô 
         woulä reappeaò oî thå nexô line®   Iæ thå useò entereä á 
         valiä line¬  thå firsô worä oî thaô linå (delimiteä bù á 
         space¬  tab¬  etc.©  woulä bå passeä tï thå OPEÎ LIBRARÙ 
         modå anä thå balancå oæ thå linå woulä bå ignored®   If¬ 
         oî thå otheò hand¬  thå useò entereä aî ESCAPÅ  followeä 
         bù  á  RETURÎ (1bh¬  0dh© thå commandó afteò thå  prompô 
         woulä  bå executeä anä controì woulä bå passeä  tï  linå 
         numbeò 65535¬ almosô surelù á non-existenô line¬ therebù 
         terminating the current NCF file.

         Somå  commandó whicè normallù accepô  parameteró  cannoô 
         receivå  parameteró  froí  thió modå  becauså  theù  arå 
         decodeä differently®  Theså include:

         -:, -;, -l, -n, -x, -y, ->

-:       WAIT FOR RETURN
         Syntax: -: -failure mode

         Thió  commanä  wilì  forcå NULÕ tï waiô foò  thå  RETURÎ 
         (0dh© characteò tï bå inpuô tï thå consolå device®  Iæ á 
         RETURÎ ió received¬ thå balancå oæ thå commanä linå wilì 
         bå ignored®   Iæ á ^Ã ió entered¬ thå remaininç commandó 
         on the line will be executed.

-;       COMMENT
         Syntax: -; comment about this kludge of a JCL

         Thió  commanä  wilì  causå  NULÕ  tï  ignorå  alì   texô 
         appearinç afteò thå commanä oî thå samå physicaì commanä 
         line.
-----------------------------------------------------------------

->       REDIRECT OUTPUT
         Syntax: -> filename
         Syntax: ->

         Witè thå firsô forí oæ thió command¬ NULÕ outpuô wilì bå 
         senô tï thå filenamå indicated®  Thå defaulô filetypå oæ 
         ".NOF¢  wilì bå useä iæ nï filetypå ió specified® Iæ thå 
         filå alreadù exists¬  iô wilì bå deleted®   Alì  speciaì 
         characteró thaô thå useò maù havå patcheä intï NULÕ (seå Š         below¬  NULÕ  MODIFICATION© wilì bå senô tï thå filå  aó 
         well¬ witè thå exceptioî oæ thå EOÆ character¬ 2¶ (1ah)®  
         Thå  onlù  outpuô noô echoeä tï thå filå wilì bå  outpuô 
         causeä  bù viewinç oò printinç á membeò file®   Eveî  iæ 
         thå  consolå  haó beeî turneä ofæ bù aî  NCÆ  file¬  alì 
         consolå outpuô wilì continuå tï bå senô tï thió file.

         The filename passed must be unambiguous.

         Undeò  thå  seconä  forí oæ thió  command¬  thå  currenô 
         outpuô file¬ iæ anù wilì bå closed®  Wheî NULÕ ió causeä 
         tï  terminate¬  thå currenô outpuô filå ió closeä  alonç 
         with the current library, if any.


                         ERROR HANDLING

NULÕ shoulä neveò crasè tï CP/Í anymore®   Wheî NULÕ signó on¬ iô 
redirectó  thå  warí booô BIOÓ vector¬  therebù  preventinç  NULÕ 
terminatioî  duå tï BDOÓ errors®   Undeò CP/Í Plus¬  iô goeó eveî 
further¬  shuttinç dowî thå consolå erroò messages¬ handlinç theí 
internally®    Therefore¬   iæ  NULÕ  attemptó  tï  perforí  somå 
operatioî  oî  á  drivå  wherå nï  disë  ió  mounted¬  onå  coulä 
reasonablù  expecô (oî á 2.² system© foò thå BIOÓ tï  issuå  somå 
erroò  message®   Thå useò theî hitó RETURÎ oò ^Ã anä NULÕ shoulä 
recover®   Iô maù thinë thaô thå disë waó full¬ wheî therå reallù 
wasn'ô  onå  therå aô all¬  buô iô shoulä stilì takå  thå  propeò 
course of action needed to recover.


                         ERROR MESSAGES

Most NULU error messages are of the form:

ERROR XX: Explanation

wherå  "XX¢  ió somå numbeò froí ° tï 25µ anä "Explanation¢ ió  á 
cluå aó tï thå naturå oæ thå error®  Eacè erroò messagå ió listeä 
below¬  alonç  witè aî explanation®   Suggestionó abouô  wayó  tï 
handlå thå error are given where appropriate.

ERROR 1: reading unwritten data
Problem:       Á  sectoò  requireä tï gaiî accesó tï  á  filå  ió 
               indicated by CP/M to be unwritten.
Solution:      Thå  librarù  directorù  oò  perhapó  thå  librarù 
               itselæ haó becomå trasheä aô somå point®  Deletinç 
               thå  entrù  anä KRUNCHinç wilì probablù rendeò  iô 
               harmless¬  buô  thå  safesô courså tï takå  ió  tï 
               obtaiî á fresè copù oæ thå library.

ERROR 2: disk full
Problem:       Thå  librarù disë becamå fulì durinç filå additioî 
               oò  KRUNCHinç  oò  thå  destinatioî  disë  oæ   aî 
               extractioî commanä becamå full.
Solution:      Iæ  thå  erroò  occurreä  durinç  KRUNCHing¬  NULÕ Š               shoulä havå recovereä bù itself¬ reopeninç thå olä 
               library®   Iæ iô diä noô recover¬ theî yoõ removeä 
               thå  originaì disë beforå thå KRUNCÈ waó  completå 
               oò á seriouó reaä erroò occurred.

               Iæ  thå erroò occuró durinç filå additioî  tï  thå 
               library¬  operatioî shoulä noô bå impaired¬ buô nï 
               fileó  thaô requireä additionaì disë spacå caî  bå 
               addeä  tï  thå  librarù untiì somå disë  spacå  ió 
               cleared®   Notå thaô deleteä entrieó caî stilì  bå 
               overwritteî  bù incominç fileó aó lonç aó thå filå 
               sizeó  match®   Thå incominç filå thaô causeä  thå 
               erroò wilì bå recordeä iî thå librarù directorù aó 
               á deleteä entry®  Iæ thå erroò occuró aó á  resulô 
               oæ  attemptinç tï replacå á member¬  thå  originaì 
               librarù  membeò shoulä bå unharmeä anä lefô aó  aî 
               activå member.

               Iæ  thå  erroò  occuró durinç filå  extractioî  oò 
               unsqueezinç   thå  destinatioî  filå  ió   deleteä 
               becauså iô ió aî incompletå file®   Extractioî caî 
               continue as before.

ERROR 4: reading unwritten data
               Seå  ERROÒ 1®   Thió ió thå samå excepô thaô  BDOÓ 
               mentioned that an entire extent was missing.

ERROR 5: can't make file
Problem:       Aî  attempô  waó madå tï creatå á filå oî  á  disë 
               with no free directory entries.

ERROR 10: media changed
Problem:       Yoõ  pulleä  thå diskettå ouô iî thå middlå  oæ  á 
               crucial operation.
Solutionº      Don'ô  dï that®   Iô ió probablù aî unrecoverablå 
               error.
ERROR 11: disk i/o error
Problem:       Yoõ  arå probablù runninç undeò CP/Í Pluó  iæ  yoõ 
               geô  thió  message®   Iô meanó thaô thå  operatinç 
               systeí detecteä á physicaì probleí witè youò  disë 
               and the read or write failed.
Solution:      Trù iô again®   É havå recovereä froí thió typå oæ 
               error by persistence.

ERROR 12: disk r/o
Problem:       Youò operatinç systeí probablù discovereä thaô yoõ 
               have a write-protect tab on your diskette.
Solution:      Remove it.

ERROR 14: bad drive
Problem:       Aî  invaliä drivå foò youò systeí waó choseî  (seå 
               below¬  NULÕ MODIFICATION© oò á letteò higheò thaî 
               "P" was indicated.
Solution:      Choose another drive or re-patch NULU.
ŠERROR 17: password error
Problem:       Yoõ  trieä  tï accesó á filå foò whicè á  passworä 
               waó  required®   NULÕ doeó noô supporô  accesó  tï 
               such files.

ERROR 18: file exists
Problem:       Yoõ  attempteä  tï KRUNCÈ á librarù froí onå  useò 
               areá intï á differenô onå iî whicè á filå witè thå 
               same name already resided.

ERROR 19: ambiguity error
Problem:       Thió meanó thaô yoõ entereä aî ambiguouó  filespeã 
               wherå  aî  unambiguouó filenamå waó  required¬  oò 
               thaô thå destinatioî filespeã iî aî extractioî  oò 
               unsqueezå  commanä  waó  lesó ambiguouó  thaî  thå 
               sourcå  filespec®  Seå  -Å   EXTRACÔ  MEMBERÓ  foò 
               complete details.

ERROR 70: file table full
Problem:       Yoõ attempteä tï opeî onå morå NCÆ filå thaî  youò 
               nesting patch supported.  See NULU MODIFICATION.

ERROR 74: checksum error
Problem:       Durinç  thå  unsqueezinç oæ á file¬  thå  internaì 
               checksuí  generateä  diä noô  matcè  thå  expliciô 
               checksuí  stateä  iî thå file'ó  squeezå  decodinç 
               table.
Solution:      Geô á ne÷ copù oæ thå membeò file®  Youró haó beeî 
               trashed somehow.

ERROR 75: CRC error
Problem:       Wheî eacè membeò filå ió addeä tï á library¬ á CRÃ 
               ió  createä  foò  iô  anä storeä  iî  thå  librarù 
               directory®   If¬  upoî extractioî oò  unsqueezing¬ 
               thå  CRÃ generateä aô THAÔ timå doeó noô matcè thå 
               originaì CRÃ iî thå directory¬ thaô meanó thaô thå 
               sectoró  whereiî thaô librarù entrù  resideó  havå 
               becomå corrupted®  Therå ió aî outsidå chancå thaô 
               thå  CRÃ entrù iî thå librarù directorù haó becomå 
               damageä  instead¬  howeveò  thaô  conditioî  woulä 
               probably also generate ERROR 107.

ERROR 77: not enough memory
Problem:       Aî  attempô  waó  madå tï opeî á  librarù  witè  á 
               directorù  toï  largå  tï bå  accounteä  foò  witè 
               available memory.
Solution:      Opeî  thå librarù oî á computeò witè á largeò  TPÁ 
               anä  reorganizå  iô  sï iô caî bå handleä  bù  thå 
               smaller system.

ERROR 78: user cancel
Problem:       Nï problem®   NULÕ ió simply lettinç thå useò kno÷ 
               whù   aî  operatioî  haó  beeî  cancelled®    Mosô 
               operationó  whicè worë oî ambiguouó filespecó  maù 
               bå  interrupteä  bù  enterinç á  ^Ã  durinç  theiò Š               operation®  (Yoõ  maù havå tï holä thå keù dowî  á 
               while.©    Thå   KRUNCÈ  operatioî   maù   bå   sï 
               interrupted as well.

ERROR 83: bad syntax
Problem:       Impropeò syntaø waó used tï attempô somå operation.

ERROR 85: file not found
Problem:       Thå  filespeã indicateä foò somå  operatioî  coulä 
               not be located.

ERROR 86: incompatible cp/m version
Problem:       Aî  attempô waó madå tï ruî NULÕ oî á systeí  witè 
               a CP/Í versioî numbeò oæ lesó thaî 2.0.

ERROR 100: bad library directory
Problem:       Thå  filå  specifieä  coulä noô  bå  openeä  aó  á 
               librarù  file®
Solution:      Thå  directorù coulä bå bad¬  buô mosô likelù  thå 
               filå  simplù isn'ô á library®   Checë iô ouô  witè 
               some disk editor like SPZ or EDFILE.

ERROR 107: library directory CRC error
Problem:       Thå  CRÃ  thaô waó calculateä anä storeä  foò  thå 
               directorù  thå lasô timå thå librarù waó  modifieä 
               doeó noô matcè thå directorù CRÃ calculateä aó thå 
               library is opened this time.
Solution:      Witè mosô libraries¬ thió erroò wilì bå valid®  Iî 
               thaô case¬ thå onlù remedù ió tï obtaiî á ne÷ copù 
               oæ thå library®  However¬ therå arå somå librarieó 
               thaô  werå createä witè LU¬  anä theî modifieä buô 
               neveò KRUNCHEÄ bù NULÕ 1.0®   Iî thaô case¬  iô ió 
               likelù  thaô thå old¬  originaì CRÃ storeä iî  thå 
               librarù  directorù  woulä  stilì  bå  there¬  eveî 
               thougè iô ió waù ouô oæ date®   Mù suggestioî  is¬ 
               wheî  yoõ  firsô geô NULÕ 1.5¬  gï througè alì  oæ 
               youò  .LBÒ  files¬  iæ  yoõ werå  usinç  NULÕ  1.° 
               previously¬  anä KRUNCÈ them®   Thió waù yoõ  wilì 
               kno÷ lateò oî thaô thå CRCó storeä iî eacè librarù 
               shoulä alì bå accurate.

ERROR 116: squeeze decode table error
Problem:       Á  filå haó á squeezå decodinç table¬  buô aô somå 
               poinô thå tablå ió trasheä oò perhapó ió  missing® 
Solution:      Nonå really»  geô á ne÷ copù oæ thå file®  Iæ youò 
               Datá Buffeò Sizå haó falleî belo÷ ¹ sectors¬  theî 
               thå  reasoî mighô bå thaô thå entirå decodå  tablå 
               could not be read into memory.

ERROR XX: undefined
Problem:       Unknown.
Solution:      Writå   dowî  alì  informatioî  presenteä  oî  thå 
               terminal®   Thå numbeò followinç thå worä ERROÒ ió 
               especiallù important®  Geô thå informatioî tï  me®  
               Mail it or call and I will try to help.Š

The most serious, non-recoverable error is:

     NULU CRC error

whicè  caî occuò wheî NULÕ 1.µ ió firsô loaded®   Thió meanó thaô 
NULÕ faileä tï matcè itó owî CRC®   Yoõ neeä tï geô á fresè copy®  
Or perhaps you have tried some patch not described below...?


                        NULU MODIFICATION

Patcheó arå listeä iî thå ordeò iî whicè theù appeaò iî NULU.COM®  
Eacè  patcè  ió  explaineä  anä thå  defaulô  valueó  arå  listeä 
immediatelù  nexô  tï  thå  patcè  address®   Alì  addresseó  arå 
absolutå hexadecimal.

Patch     Default             Explanation
00163h      50h               Numbeò  oæ  characteró  eacè   fulì 
                              videï   linå  caî   contain®    Noô 
                              necessarilù  thå samå aó thå numbeò 
                              you can see.
00164h      50h               Numbeò  oæ characteró visiblå oî  á 
                              line at any one time.
00167h      07h               Thió  bytå indicateó thå numbeò  oæ 
                              fileó  thaô NULÕ caî havå  opeî  aô 
                              anù  onå time®   Thå baså numbeò ió 
                              ´ anä shoulä neveò falì belo÷ that®  
                              Thå valuå oæ ³ haó beeî addeä tï iô 
                              tï  allo÷  ³ leveì nestinç  oæ  NCÆ 
                              files®    Iæ   thå  NCÆ  valuå   ió 
                              increaseä oò  decreased¬  identicaì 
                              changeó  shoulä  bå  madå  tï  thió 
                              byte.  (See Patch at 00220h.)
00168h   0010h                Thió   obscurå  worä  controló  thå 
                              numbeò  oæ relocatablå  taskó  thaô 
                              caî   bå  controlleä  bù  thå  NULÕ 
                              memorù     managemenô     routines®  
                              Becauså eacè filå ió á  relocatablå 
                              task¬  thå  samå modificationó  foò 
                              thå previouó bytå applù here®   Thå 
                              baså  valuå  oæ thió worä ió  000dè 
                              anä  shoulä neveò falì  belo÷  thaô 
                              point.  (See Patch at 00220h.)
0016ah     10h                Numbeò  oæ  contiguouslù   numbereä 
                              disë driveó iî youò system®  Iæ yoõ 
                              havå driveó Á anä B¬ seô thió valuå 
                              tï  2®   Iô  wilì prevenô yoõ  froí 
                              accessing an invalid drive.
0016bh     10h                Numbeò  oæ  contiguouó  useò  areaó 
                              thaô   NULÕ  wilì  bå  alloweä   tï 
                              access®   Undeò  normaì  CP/Í  2.2¬ 
                              Turbo-Doó  oò  á  ZCPÒ  system¬   É 
                              understanä thaô thió numbeò caî  bå Š                              aó higè aó 20h®   Foò CP/Í Pluó  oò 
                              mosô  systemó  thaô  uså  time/datå 
                              stampinç  thió  numbeò  shoulä  noô 
                              exceeä 10h.
0019ch    0005h               Thió  ió  thå addresó oæ  thå  BDOÓ 
                              vector®  Alì operatinç systeí calló 
                              gï  througè thió address®   Iæ  yoõ 
                              havå somå weird¬  non-standarä CP/Í 
                              implementatioî  yoõ caî patcè  thió 
                              to try to make NULU work with it.
0021ch      00h               Seô  tï  á non-zerï valuå  tï  makå 
                              NULÕ READ/ONLY®   Nï operatoró wilì 
                              bå  executeä thaô coulä changå  thå 
                              librarù oò disë directorieó iî  anù 
                              way.
0021dh      00h               LU.COÍ   waó   seô   uğ   tï   exiô 
                              automaticallù iæ á commanä taiì waó 
                              useä wheî LÕ waó invoked®  Witè thå 
                              releaså  versioî oæ NULU¬  iô takeó 
                              thå -Ø commanä tï exit®   Seô  thió 
                              bytå tï á 01è tï geô iô tï acô likå 
                              LÕ  iî thió respect®   Thaô is¬  iô 
                              wilì   automaticallù   exiô   afteò 
                              executinç thå passeä commanä  tail¬ 
                              iæ onå waó present.
0021eh      01h               Seô  tï  á 00è tï starô  NULÕ  witè 
                              BRIEÆ  modå  OÎ (lonç messageó  noô 
                              printed).
0021fh      01h               Seô  tï zerï tï prevenô useró  froí 
                              beinç  ablå  tï  ESC,REÔ  froí  thå 
                              PROMPÔ  ANÄ CHAIÎ TÏ PREVIOUÓ  MODÅ 
                              promptó iî NCÆ files®  (Bå surå  tï 
                              alsï  changå  thå valueó aô  00167è 
                              and 00168h.)
00220h      03h               Thió  bytå  indicateó  thå  nestinç 
                              leveì  alloweä  foò NCÆ  files®   É 
                              havå  nï ideá whaô thå uppeò  limiô 
                              is¬  buô  watcè  thaô  Datá  Buffeò 
                              Size!
00221h      '-Y *LBR -O',0    Startinç herå arå 3¹ byteó iî whicè 
                              anù  valiä  NULÕ operatoró  maù  bå 
                              stored®     Thió   linå   wilì   bå 
                              automaticallù executeä wheî NULÕ ió 
                              loaded¬   eveî  beforå  anù   otheò 
                              parameteró  passeä  oî thå  commanä 
                              line®  Thió mighô bå useä tï creatå 
                              á  versioî  oæ  NULÕ  that¬   afteò 
                              loading¬    setó   thå   drive/useò 
                              defaultó tï B0:¬  printó thå  menu¬ 
                              scanó  thå drivå foò librarù files¬ 
                              theî  switcheó tï thå opeî  librarù 
                              mode®  Thaô commanä linå woulä looë 
                              likå this:

                              -U B: -H -Y *LBR -OŠ
                              Noticå thaô alì characteró iî  thió 
                              linå  MUSÔ  bå  UPPEÒ  CASE®    Thå 
                              entirå linå MUSÔ bå terminateä bù á 
                              nulì  byte®    Onlù  3¹  byteó  arå 
                              availablå  foò  text...noô  á  bytå 
                              more®   Thå  40tè  bytå ió foò  thå 
                              null terminator.
0026fh      3ch               Thió  ió  thå numbeò oæ lineó  thaô 
                              NULÕ wilì prinô oî eacè pagå durinç 
                              membeò filå printing®   Changå thió 
                              valuå  iî accordancå witè thå  linå 
                              printeò  patcè  below®   Seô iô  tï 
                              zerï  tï  havå  NULÕ  ignorå   linå 
                              counts altogether.

Startinç aô 0024cè arå 5 datá areaó useä tï definå stringó needeä 
tï controì thå consolå attributes®  Eacè strinç ió precedeä bù an 
identificatioî  bytå  anä á bytå indicatinç  itó  activå  length®  
Theî µ byteó arå availablå foò thå actuaì definition®   Thereforå 
á  totaì  oæ · byteó ió consumeä foò  eacè  videï  control®   Thå 
attributeó are¬ iî order:
     DIM or REVERSE VIDEO ON   (DIM is preferred)
     DIM or REVERSE VIDEO OFF
     UNDERLINING ON
     UNDERLINING OFF
     CLEAR SCREEN

Each control becomes active as soon as it is patched in.

Likewise¬  therå  ió onå strinç defineä foò thå LSTº  devicå thaô 
wilì bå issueä immediatelù beforå printinç á file®   Iô beginó aô 
00271è anä haó thå samå formaô aó thå stringó above.



                           FINAL NOTES

Pleaså  reporô anù bugó oò problemó tï Martiî  Murray¬  P.O®  Boø 
35972¬  Dallas¬  Tø  7523µ oò calì (214© 351-6117¬  EVENINGÓ  ANÄ 
WEEKENDÓ ONLY®  Pleaså specifù thå versioî oæ NULÕ witè whicè yoõ 
arå  working®

Aó always¬  donationó wilì bå gratefullù accepted®  Iô tooë á loô 
oæ  worë tï producå NULÕ anä iæ yoõ enjoù iô anä iô benefitó you¬ 
don'ô hesitatå tï sho÷ youò appreciatioî witè á check¡   Noteº  É 
nï longeò worë foò SYSTEÍ SOLUTIONS¬  sï please¬  nï checkó  madå 
ouô  tï  them®   É aí no÷ workinç foò INOVA¬  á  companù  foundeä 
specificallù  tï supporô 8-biô computeró runninç CP/M®   Looë foò 
ne÷  anä  excitinç  retaiì  productó  froí  thaô  source®    (Thå 
preceedinç haó beeî aî officiaì plug.)
