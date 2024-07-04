                               Z-System Corneò (c)
                                 by Jay Sage
                        The Computer Journal, Issue 46
                          Reproduced with permission
                           of author and publisher

                            Thå ZMATÅ Texô Editor


   Althougè É havå noô yeô finisheä thå treatmenô oæ MEX¬ É aí goinç tï  starô 
á  ne÷  subjecô thió timeº thå ZMATÅ macrï texô editor®  Durinç thå  pasô  twï 
monthó É havå beeî workinç oî á numbeò oæ codå patcheó tï MEØ-Pluó tï fiø somå 
problemó  anä tï adä somå ne÷ featureó thaô É wanteä oò needed®  Thaô worë  ió 
noô  complete¬ sï É havå decideä tï holä ofæ oî á MEØ updatå untiì nexô  time®  
Aó usual¬ É dï havå á fe÷ miscellaneouó itemó tï brinç tï youò attention.


                               Pieceó oæ Eight

   First¬  É  woulä likå tï puô iî á pluç foò thå "Pieceó oæ  Eight¢  magazinå 
(POE©  froí thå Connecticuô CP/Í Users§ Grouğ (CCP/M)® CCP/Í recentlù  decideä 
tï  begiî  addressinç á nationaì audiencå anä noô jusô  theiò  locaì  members®  
Eveî  iæ yoõ cannoô attenä theiò meetings¬ thå subscriptioî tï POÅ  thaô  youò 
$1µ annuaì dueó bringó yoõ ió alonå wortè thå price.

   POÅ ió á verù nicå complemenô tï TCJ®  É don'ô thinë É wilì offenä CCP/Í bù 
sayinç  thaô theiò magazinå ió faò lesó seriouó thaî thió one®  Therå ió  somå 
soliä  technicaì content¬ buô thå emphasió ió definitelù oî thå humaî sidå  oæ 
computing®  Iô ió reallù fuî tï read¬ anä noô jusô bù uó computeò nutó buô  bù 
ouò entirå familieó aó well.

   Thå  July¬  1990¬  issuå  haó á featurå articlå  oî  thå  Trentoî  Computeò 
Festivaì  helä  iî April®  Oî thå coveò ió á picturå takeî therå  showinç  me¬ 
Bridgeò  Mitchell¬  Aì  Hawley¬  anä  Caí  Cotrill®  (Iî  caså  yoõ  mighô  bå 
questioninç mù motives¬ theiò flatterinç må bù puttinç mù picturå oî thå coveò 
provideä onlù á fractioî oæ thå inspiratioî foò thió plug!)

   Insidå  arå morå picturesº Roâ Friefelä (LSH¬ SALIAS)¬ Carsoî Wilsoî  (ZDE¬ 
ZSDOS)¬ Haì Boweò (ZSDOS)¬ Brucå Morgeî (MEX+2Ú anä lotó oæ prograí  patches)¬ 
Howarä Goldsteiî (ouò alphá testeò anä buç catcheò anä fixeò  extraordinaire)¬ 
anä  quitå  á  fe÷ others® Aó yoõ caî see¬ Trentoî  dre÷  Ú-Teaí  memberó  anä 
enthusiastó  froí alì oveò thå country¡  Iæ yoõ wanô tï learî morå  abouô  thå 
festival¬  sigî uğ foò POE®  Senä dueó tï Toí Veile¬ 2¶ Slateò Ave.¬  Norwich¬ 
CÔ 06360.


                          Á Patcè foò Thå Worä Plus


   Somå  timå agï É publisheä herå á seô oæ ARUNÚ aliaseó foò  automatinç  thå 
uså oæ Thå Worä Pluó spelì checker®  Well¬ Richarä Swifô likeä theí jusô fine¬ 
buô iô theî annoyeä hií thaô hå stilì haä tï hiô á carriagå returî tï geô pasô ŠTW'ó prompô abouô whetheò thå configuratioî waó correct®  Hå wanteä T× tï  geô 
righô tï work.

   Aô  firsô  É didn'ô reallù seå whù hå waó makinç sucè á fusó abouô  sucè  á 
littlå  thing®   Theî iô begaî tï eaô aô me¬ too® Thió onå  littlå  thinç  waó 
standinç iî thå waù oæ completå automation.

   Well¬  iô tooë á gooä biô oæ pokinç arounä iî thå TW.COÍ code¬ buô  iî  thå 
enä  iô waó quitå easù tï patcè arounä thió annoyinç prompt®  Firsô É  locateä 
wherå  thå  codå thaô puô uğ thå prompô began¬ anä theî É founä  wherå  thingó 
pickeä uğ agaiî afteò it®  Á simplå jumğ instructioî aô thå beginninç tï  skiğ 
oveò iô shoulä dï thå trick¬ É thought.

   Unfortunately¬ iô waó noô quitå thaô simple®  Aó Brucå Morgeî haä describeä 
earlieò  iî  aî issuå oæ hió NAOÇ newsletter¬ thå programó iî  Thå  Worä  Pluó 
suitå  perforí  somå  simplå internaì checkinç tï makå surå thå  filå  ió  noô 
corrupteä  anä haó loadeä successfully®  Nicå oæ thoså folks¬ buô afteò É  puô 
iî  mù  patch¬ thå codå lookeä corrupted®  É coulä havå figureä  ouô  thå  ne÷ 
checksuí  valuå anä stucë iô intï thå testinç code¬ buô iô waó easieò jusô  tï 
bypasó thå checkinç entirely.

   Aô  firsô É puô thå changeó intï á patcè filå thaô woulä bå  overlaiä  ontï 
thå  originaì code®  Then¬ however¬ É decideä thaô therå waó nï reaì  neeä  tï 
makå  thå  changå permanently®  Wheî runninç T× manually¬ onå  woulä  probablù 
wanô  thå prompô tï appeaò sï thaô onå woulä havå thå optioî oæ  changinç  thå 
setup®  So¬ mù solutioî waó thå olä GET/POKE/GÏ techniquå introduceä bù  Brucå 
Morgeî (boù doeó thaô namå keeğ cominç up!).

   Mù originaì ARUNÚ aliaó haä á commanä oæ thå form

	tw:t÷ <file¾ <dictionary>

É jusô replaceä thaô by

	/TWPAÔ <file¾ <dictionary>

anä wrotå thå ne÷ aliaó TWPAÔ witè thå commanä lines

	geô 10° tw:tw.coí	loaä TW.COM
	pokå 10³ c³ 3â 0±	patcè tï jumğ oveò codå test
	pokå 39µ c³ 2á 0´	patcè tï jumğ oveò prompt
	gï $ª			ruî thå patcheä code

No÷ É coulä invokå thå patcheä T× wheneveò É wanteä bù usinç thå commanä TWPAÔ 
instead.


                            The ZMATE Text Editor


   No÷ foò thå maiî topiã oæ thió column¬ thå firsô iî á serieó oæ articleó oî 
ZMATE®   Thió onå wilì bå jusô aî introductioî anä wilì coveò onlù itó  desigî Šphilosophù  anä  modå  oæ operation® Nexô timå É wilì starô  tï  describå  itó 
languagå iî detail.


Interpreteró anä Compilers

   Á  casuaì  useò woulä classifù ZMATÅ aó aî applicatioî  program¬  anä  morå 
preciselù  aó  á texô editoò oò wordprocessor®  Iî itó soul¬  however¬  iô  ió 
reallù  á higè-leveì programminç language® Iî somå wayó iô ió similaò  tï  thå 
familiaò BASIÃ interpreter.

   Likå  almosô alì thå programminç languageó mosô peoplå worë with¬ BASIÃ  ió 
orienteä towarä numericaì computation®  Foò example¬ aô thå systeí prompô  onå 
caî enteò á commanä sucè as

	prinô ¨ n± « n² © ª n3

BASIÃ wilì theî retrievå thå valueó associateä witè thå variableó N1¬ N2¬  anä 
N3¬ substitutå theí intï thå mathematicaì expression¬ evaluatå thå expression¬ 
anä prinô thå resulô tï thå screen.

   BASIÃ  alsï  allowó onå tï writå programó comprisinç á serieó  oæ  numbereä 
statementó sucè as:

	10° n± ½ 10
	11° n² ½ 5
	12° n³ ½ 3
	13° prinô ¨ n± « n² © ª n3

Wheî  thå immediatå commanä "RUN¢ ió entered¬ thå entirå sequencå oæ  commandó 
ió carrieä out¬ anä thå numbeò 4µ appearó oî thå screen.

   Onå coulä writå á prograí tï dï thå samå thinç usinç assemblù language¬ thå 
nativå languagå oæ á computer®  However¬ á higè-
leveì  languagå  likå  BASIÃ  makeó iô faò easieò  tï  generatå  thå  requireä 
instructions®  Thió ió especiallù truå wheî wå arå dealinç witè floatinç poinô 
numbers¬  oò wheî wå arå usinç arraù variableó oò advanceä mathematicaì  (triç 
anä log© functions.

   Wheî  thå  BASIÃ  interpreteò  wå describeä abovå  ió  tolä  tï  "RUN"¬  iô 
processeó thå prograí statementó onå aô á time®  Firsô iô analyzeó á statemenô 
tï determinå thå procedureó requireä tï perforí thå specifieä function®   Theî 
iô calló routineó thaô executå thoså procedures®  Thió meanó thaô wheî á BASIÃ 
statemenô  appearó  iî á loop¬ thå analysió haó tï bå repeateä eacè  timå  thå 
statemenô ió executed.

   Á  compileò provideó aî alternativå approach®  Thå compileò caî bå  thoughô 
oæ  aó aî automatiã assemblù languagå prograí writer® Yoõ writå  youò  prograí 
usinç thå commandó oæ thå higè-leveì language¬ anä theî thå compileò  convertó 
theí intï aî assemblù languagå prograí foò you.

   Somå compileró generatå actuaì assemblù languagå sourcå codå thaô yoõ  theî Šhavå tï assemble®  Thå PASCAÌ Ú compiler¬ foò example¬ workeä thió way®   Thió 
approacè makeó prograí developmenô sloweò buô allowó yoõ tï finå-tunå thå codå 
iæ  yoõ sï desire®  Otheò compilers¬ sucè aó Turbï Pascal¬ generatå  onlù  thå 
machinå  codå (COM© files®  Somå compilers¬ sucè aó BDÓ C¬ follo÷  á  twï-steğ 
process¬ buô thå intermediatå codå ió noô standarä assemblù code.

   Á compiler¬ aó yoõ mighô guess¬ haó thå advantagå oæ executioî speed¬ sincå 
thå  higè-leveì  languagå statementó havå tï bå analyzeä  anä  converteä  intï 
machinå  codå  onlù once¬ eveî wheî theù arå executeä repeatedlù  iî  á  loop®  
Also¬ morå compleø programó thaô neeä morå workinç memorù caî bå accommodated¬ 
sincå  thå  codå  thaô  figureó ouô ho÷ tï  procesó  thå  higè-leveì  languagå 
statementó doeó noô havå tï bå iî memorù wheî thå finaì prograí ió run.

   Oî  thå otheò hand¬ aî interpreteò offeró manù advantageó thaô maù makå  iô 
welì wortè givinç uğ somå speed®  Programó arå mucè easieò tï develoğ witè  aî 
interpreteò  foò  severaì reasons® First¬ yoõ caî  executå  theí  immediately¬ 
withouô  havinç  tï  gï througè thå extrá steğ oæ  compilatioî  (anä  possiblù 
assemblù anä linkage© beforå execution®  Second¬ thå programó caî bå ruî  linå 
bù line¬ anä yoõ caî watcè whaô ió happeninç anä catcè erroró morå easily.

   Therå  arå  alsï  somå thingó thaô aî interpreteò caî dï  thaô  á  compileò 
generallù cannot®  Foò example¬ supposå yoõ arå workinç witè aî arraù variablå 
(á variablå thaô holdó á collectioî oæ values¬ noô jusô á singlå value)®  Witè 
á compiler¬ yoõ woulä havå tï specifù thå sizå ­­ oò aô leasô á maximuí sizå -
­  oæ thå arraù aô thå timå thå prograí ió compileä sï thaô thå  compileò  caî 
allocatå  enougè memorù foò it®  Witè aî interpreter¬ thió ió  noô  necessary®  
Iô  doeó  noô  havå  tï  allocatå thå  memorù  untiì  thå  variablå  ió  firsô 
referenced®  Aó á result¬ iô ió quitå acceptablå foò itó sizå tï bå determineä 
bù computationó performeä earlieò iî thå program.


ZMATÅ aó Interpreter

   ZMATÅ  is¬ iî á way¬ likå thå BASIÃ interpreter¬ excepô thaô itó  intrinsiã 
higè-leveì  languagå functionó (wå wilì calì theså 'primitives'© arå aimeä  aô 
texô  processinç ratheò thaî numbeò processing®  Jusô aó BASIÃ haó somå  texô-
processinç  primitiveó  (e.g.¬ strinç variableó anä functions)¬ sï  ZMATÅ  haó 
somå numericaì functions¬ buô iô ió thå texô-manipulatioî primitiveó thaô  arå 
emphasizeä anä richlù developed.

   Iæ  youò  pasô  experiencå  haó beeî  confineä  tï  thå  usuaì  programminç 
languageó  ­­  BASIC¬ FORTRAN¬ PASCAL¬ C¬ etc® ­­ yoõ  probablù  havå  troublå 
picturinç  whaô  á texô-processinç languagå woulä looë like®   Herå  arå  somå 
exampleó tï helğ conveù thå concept.

   Whilå  mosô variableó iî BASIÃ contaiî eitheò singlå numberó oò  arrayó  oæ 
numbers¬  ZMATÅ  haó 'variables§ calleä bufferó thaô contaiî pieceó  oæ  text®  
Primitiveó  allo÷ readinç disë fileó intï theså bufferó oò writinç  texô  froí 
thå bufferó ouô tï files.

   Eacè buffeò haó twï pointers®  Onå ió calleä thå cursor®  Iô ió wherå  mosô 
ZMATÅ primitiveó perforí theiò operation®  Thå otheò pointeò ió calleä á  tag¬ Šanä  togetheò  witè  thå cursoò iô defineó á blocë oæ  texô  foò  somå  blocë-
operatioî primitives.

   Á  wholå seô oæ ZMATÅ primitiveó dealó witè cursoò motion®  Thå cursoò  caî 
bå  moveä  forwarä anä backwarä iî thå buffeò bù unitó oæ  characters¬  words¬ 
paragraphs¬ oò thå wholå buffer®  Foò example¬ yoõ caî telì thå cursoò tï bacë 
uğ bù threå wordó oò gï forwarä twï paragraphs.

   Thió  highlightó  thå  differencå betweeî á numbeò-processinç  anä  á  texô 
processinç language®  BASIÃ supportó strinç variableó thaô caî contaiî á  linå 
oæ text¬ buô iô doeó noô kno÷ abouô wordó anä paragraphs®  Thå useò woulä havå 
tï writå compleø codå tï deaì witè theså texô concepts®  Aó á  texô-processinç 
language¬ ZMATÅ provideó thå codå foò thió aó parô oæ thå languagå primitives.

   Otheò   ZMATÅ  primitiveó  searcè  foò  stringó  anä  comparå  stringó   oò 
characters®   Texô caî bå inserteä anä deleted®  Blockó oæ texô caî  bå  moveä 
betweeî  bufferó  foò cuttinç anä pastinç operations® Alì  thå  usuaì  controì 
primitiveó arå provideä tï allo÷ testing¬ conditionaì operations¬ anä looping.

   Therå  arå  alsï speciaì facilitieó foò handlinç texô formattinç  anä  texô 
inpuô  froí  thå  keyboard®  Sofô carriagå returnó caî  bå  placeä  intï  texô 
automatically¬  anä  variouó  kindó  oæ indentatioî  anä  margiî  controì  arå 
provided®  Theså functionó makå iô easù tï writå á wordprocessoò iî thå  ZMATÅ 
language.


Ho÷ thå ZMATÅ Languagå ió Used

   Iî  ouò  exampleó above¬ wå sa÷ thaô á BASIÃ statemenô caî bå  entereä  foò 
immediatå  execution®   ZMATE¬  too¬  allowó this®  Wå  alsï  sa÷  thaô  BASIÃ 
programó  containinç  á  sequencå  oæ statementó caî  bå  prepareä  foò  lateò 
execution®   Thå  samå ió truå oæ ZMATE® Iî fact¬ ZMATÅ caî havå á  numbeò  oæ 
programó loadeä anä readù foò executioî aô thå samå time¬ anä onå prograí  caî 
calì anotheò aó á subroutine.

   ZMATÅ  allowó  itó  languagå  tï bå useä iî onå  otheò  verù  speciaì  way®  
Programó  thaô arå permanentlù storeä iî thå ZMATÅ COÍ filå caî bå bounä tï  á 
keù  oò  sequencå  oæ  keys®  Theî wheî thaô keù  sequencå  ió  typeä  aô  thå 
keyboard¬ thå prograí ió automaticallù executed®  ZMATÅ commandó executeä thió 
waù arå calleä "instanô commands."

   Aó aî example¬ supposå wå writå thió littlå ZMATÅ program:

	10° puô thå taç wherå thå cursoò ió now
	11° movå thå cursoò forwarä onå word
	12° deletå thå blocë (taç-tï-cursor)
	13° stop

[É  aí usinç á BASIÃ-likå pseudï-languagå foò thió example®  Thå actuaì  ZMATÅ 
language¬  whicè wå wilì geô intï nexô time¬ ió noô aô alì likå this.İ  Iæ  wå 
no÷  binä thió prograí tï thå '^T§ (controì-T© key¬ wå wilì  havå  implementeä 
thå WordStaò deletå-Šworä function.

   Thió  shoulä givå yoõ á senså no÷ oæ ho÷ ZMATÅ caî bå useä tï  implemenô  á 
texô  editoò  oò  wordprocessor®   Althougè ZMATÅ  comeó  witè  somå  standarä 
programó  anä keù bindings¬ yoõ caî changå thå standarä programs¬  caî  attacè 
youò  owî  ne÷  programs¬  anä caî changå thå keù  bindings®   Thuó  yoõ  havå 
extensivå controì oveò thå waù ZMATÅ workó anä caî adä anù functionó yoõ  likå 
tï it.


Thå ZMATÅ Screen

   Thå normaì appearancå oæ thå screeî whilå ZMATÅ ió runninç ió showî iî Fig® 
1®   Iî  fact¬ É captureä thió screeî usinç thå BGié  'screen§  commanä  whilå 
writinç  thió  article®   É havå madå á fe÷ changeó tï adapô  iô  tï  thå  TCÊ 
format®   Thå  reaì  screeî  ió thå fulì widtè oæ  thå  terminal¬  usuallù  8° 
characters¬  anä  thå fulì length¬ usuallù 2´ lines®  É havå reduceä  botè  oæ 
theså sizes.

=================================================================
R70

/------------------------------------------------------------------\
| TCJ: TCJ:TCJ46.WS,TCJ:TCJ46.$$$   buf=T  arg=0      |col = 18    |
| INSERT MODE                                         |line= 204   |
| ----------------------------------------------------|free= 13454 |
|         100 put the tag where the cursor is now<                 |
|         110 move the cursor to the next word<                    |
|         120 delete the block (tag-to-cursor)<                    |
|         130 stop<                                                |
| <                                                                |
| [I am using a BASIC-like pseudo-language for this example.  The  |
| actual ZMATE language, which we will get to next time, is not at |
| all like this.]  If we now bind this program to the ^T key, we   |
| will have implemented the WordStar delete-word function.<        |
| <                                                                |
| <                                                                |
| The ZMATE Screen<                                                |
| <                                                                |
|    The normal appearance of the screen while ZMATE is running is |
| shown in Fig. 1.  In fact, I captured this screen using the BGii |
| 'screen' command while writing this article.  I have made a few  |
| changes to adapt it to the TCJ format.  The real screen is the   |
\------------------------------------------------------------------/
R65
Fig®  1®  Thió ió á snapshoô oæ thå ZMATÅ screeî approximatelù aó iô  appeareä 
whilå É waó writinç thió column.

=================================================================

   Alì  buô  thå  toğ threå lineó arå useä foò thå displaù  oæ  text®  Iî  thå 
originaì PMATE¬ onlù onå buffeò coulä bå viewed®  Witè ZMATE¬ Bridgeò Mitchelì Šmadå  iô possiblå tï looë aô twï bufferó oò aô twï sectionó oæ onå  buffeò  aô 
thå  samå time®  Bù thå way¬ thå '<§ characteró aô thå endó oæ somå  lineó  iî 
Fig® ± indicatå harä carriagå returns®  Thå otheò lineó enä witè sofô returns® 
Iæ onå changeó thå margins¬ thå texô instantlù readjusts.

   Aô  thå lefô oæ thå toğ line¬ ZMATÅ showó thå currentlù  loggeä  directory¬ 
thå  filå  thaô ió opeî foò input¬ anä thå filå thaô ió opeî foò  output®   Iî 
thió  case¬  thå  outpuô filå ió á temporarù file¬  TCJ:TCJ46.$$$®   Wheî  onå 
closeó  thå ediô file¬ thå inpuô filå wilì bå giveî á filå typå oæ BAK¬  whilå 
thå  temporarù  outpuô filå namå wilì bå changeä tï thå  originaì  inpuô  filå 
name.

   Iî  thå  centeò oæ thå toğ line¬ twï statuó variableó arå  displayed®   Thå 
firsô telló uó whicè buffeò ió currentlù beinç editeä (therå arå 1² oæ  them)» 
thå  seconä ió á numericaì valuå returneä bù thå lasô ZMATÅ commanä  thaô  waó 
performed®   Thaô valuå caî conveù informatioî tï thå useò oò caî bå useä  foò 
testinç iî á program.

   Aô  thå  righô  edgå  oæ  thå screen¬  threå  otheò  statuó  variableó  arå 
displayed®   Thå positioî oæ thå cursoò ió giveî aó á columî anä linå  number®  
Thå thirä valuå telló ho÷ mucè freå memorù ió availablå foò additionaì text.

   Thå  seconä linå iî Fig® ± showó thå modå statuó "INSERÔ MODE"®  ZMATÅ  caî 
ruî  iî  threå  modesº insert¬ overtype¬ anä command®  Iî  commanä  mode¬  thå 
seconä  linå ió wherå thå useò enteró ZMATÅ prograí statementó  foò  immediatå 
execution®  Afteò á commanä ió entered¬ iô ió executeä bù pressinç thå  escapå 
keù (ESC).

   Thå  mosô recentlù entereä commanä remainó oî thå commanä linå anä  caî  bå 
executeä agaiî bù pressinç ESÃ again®  Otheò instanô commanä functionó caî  bå 
executeä  iî  between®  Thió giveó ZMATÅ wonderfuì power®  Iô ió  onå  oæ  thå 
thingó thaô thå authoò oæ Vediô ­­ whicè began¬ É believe¬ aó á PMATÅ clonå ­­ 
neveò  understooä  anä  ió onå oæ thå reasonó whù É havå  alwayó  founä  Vediô 
unacceptablå aó aî editor.

   Herå  ió aî examplå oæ ho÷ thió facilitù caî bå used®  Supposå wå  wanô  tï 
changå á numbeò oæ wordó tï uppeò case®  Assuminç thió ió noô alreadù  defineä 
aó á builô-iî editoò function¬ wå writå á commanä linå witè codå thaô  changeó 
alì  letteró oæ thå worä containinç thå cursoò tï uppeò case®  Theî  wå  presó 
ESC¬  anä  thå currenô worä ió converted®  Supposå thå nexô worä  wå  wanô  tï 
converô  ió  dowî  twï  lineó anä oveò threå wordó  froí  wherå  wå  arå  now®  
Assuminç  WordStaò-likå  bindings¬ wå coulä presó "^X^X^F^F^F"®  Theî  wå  caî 
presó ESÃ agaiî tï converô thaô word® Iî á sense¬ ZMATÅ commandó typeä oî  thå 
commanä linå becomå bounä temporarilù aó aî instanô commanä oî thå ESÃ key.

   Iî  inserô mode¬ wå arå effectivelù runninç á ZMATÅ prograí thaô  askó  thå 
useò  tï presó keys¬ whicè arå theî inserteä intï thå text®  Overtypå modå  ió 
thå samå excepô thaô thå ne÷ characteró replacå thå oneó previouslù undeò  thå 
cursor®  Iî botè inserô anä overtypå mode¬ instanô commandó operatå jusô aó iî 
commanä mode®  Thaô is¬ keù sequencå bindinç arå stilì fullù iî effect.

ŠKeù Bindings

   Thió  ió á gooä timå tï makå thå rolå oæ keù bindingó morå explicit®   Witè 
ZMATE¬  onå shoulä thinë oæ nï keyó aó producinç direcô inpuô tï  thå  editor®  
Alì  keyó havå tï bå bounä tï somå functioî iæ theù arå tï havå anù effecô  aô 
all.

   ZMATÅ haó threå sourceó foò thå functionó thaô arå bounä tï thå keys®   Onå 
oæ theså compriseó functionó thaô producå ASCIÉ characters®  Mosô peoplå woulä 
takå  iô foò granteä thaô pressinç thå 'A§ keù woulä producå aî 'A'¬ buô  thió 
ió noô necessarilù sï iî ZMATE®  Thió makeó iô quitå easù tï implemenô á  noî-
standarä keyboarä layout¬ sucè aó thå Dvoraë layout.

   Thå  bindings¬  moreover¬  arå noô onå-tï-one®  Yoõ caî havå  á  numbeò  oæ 
differenô  keù sequenceó bounä tï thå samå function® So¬ iæ yoõ wanô  tï  havå 
twï  ESÃ  keys¬  yoõ caî binä á seconä keyboarä keù  tï  thå  "producå-aî-ESÃ-
character¢  functioî aó well® Anä É wanô tï emphasizå thaô theså bindingó  arå 
oæ  sequenceó oæ onå oò morå keyó (uğ tï somå configurablå maximuí number©  tï 
anù singlå function.

   Thå keù bindingó arå defineä iî á tablå witè thå followinç structure®  Eacè 
entry¬  excepô thå last¬ compriseó á bytå witè á functioî numbeò  followeä  bù 
thå sequencå oæ ASCIÉ keù codeó bounä tï thaô function®  Thå sequenceó arå alì 
exactlù  thå  maximuí lengtè specifieä iî thå configuration®  Iæ  thå  defineä 
sequencå  ió shorteò thaî this¬ nulì byteó (valuå 0© arå useä aó  filler®  Thå 
enä  oæ  thå tablå ió indicateä bù á valuå oæ FÆ heø  iî  thå  functioî-numbeò 
position.

   Thå  characteò-producinç  functionó  havå  numberó  froí  froí  ±  tï   12· 
inclusive®   É  aí  noô surå abouô functioî 0®  Puttinç á nulì  intï  texô  ió 
generallù  noô  allowed¬  aó  nulì ió useä tï separatå  thå  buffers®   Iæ  nï 
expliciô  bindinç ió specifieä foò á singlå ASCIÉ characteò iî thå rangå ±  tï 
127¬  iô  ió bù defaulô bounä tï thå functioî thaô  produceó  thaô  character®  
Thuó  thå  keù sequencå 'A§ (á singlå presó oæ thå 'A§ key© ió  bounä  tï  thå 
"producå-aî-A¢ functioî iæ iô doeó noô appeaò iî thå keù bindinç table.

   Thió direcô mappinç oæ ASCIÉ characteró ió not¬ aó É saiä above¬  required®  
Foò example¬ É uså thå tildå anä bacë-
apostrophå  aó leaä-iî keyó tï otheò sequenceó (somå peoplå woulä  calì  theså 
keyó  'meta§ keys)®  Iî ordeò tï bå ablå tï enteò theså twï characteró  easilù 
intï  text¬ É binä thå sequencå "~~¢ (twï tildeó iî á row© tï thå  "producå-á-
tilde¢ functioî anä "``¢ tï thå "producå-á-bacë-apostrophe¢ function.

   Thå  seconä seô oæ functions¬ numbereä froí 12¸ tï 191¬ ió  implementeä  iî 
ZMATE'ó  internaì code®  However¬ alì buô á fe÷ oæ theí arå iî facô  performeä 
bù macrï statementó iî thå standarä ZMATÅ language®  Iî PMATÅ therå waó nï waù 
tï  modifù these» iî ZMATE¬ theù havå beeî placeä aô thå enä oæ thå  codå  anä 
referenceä  iî á waù thaô allowó thå overlaù configuratioî patcè  tï  redefinå 
theså functionó freely.

   Bù  mù count¬ oæ thå 6´ functionó oæ thió type¬ alì buô 1² arå  defineä  bù 
macrï prograí statements®  Iî somå caseó iô ió obviouó whù somå arå not®   Foò Šexample¬  therå ió á functioî foò settinç á repeaô counô thaô applieó  tï  thå 
nexô  commanä entered®  Therå ió alsï á functioî thaô abortó thå executioî  oæ 
anù macro®  Theså functionó woulä noô makå senså iî thå macrï languagå itself.

   Foò  somå  functionó  iô ió noô sï cleaò whù theù arå  noô  implementeä  aó 
macros®  Foò example¬ therå ió á functioî tï poğ froí thå "garbagå stack¢  thå 
mosô  recentlù deleteä blocë oæ text® Thió ió somethinç thaô cannoô  presentlù 
bå donå iî thå commanä language¬ buô É don'ô seå whù iô couldn'ô oò  shouldn'ô 
be.

   Theî therå arå severaì functionó foò whicè therå exisô macrï commandó  thaô 
perforí  thå  function®  Switchinç tï insert¬ overtype¬ oò  commanä  modå  arå 
examples®  É don'ô kno÷ whù theù arå implementeä directlù iî codå ratheò  thaî 
iî thå macrï language.

   Thå  finaì seô oæ functionó ió numbereä froí 19² tï 254®  Á hexadecimaì  FÆ 
(25µ  decimal© ió useä tï marë thå enä oæ thå bindinç table¬ sï thió  functioî 
numbeò ió noô allowed®  Theså functionó arå associateä witè whaô ió calleä thå 
"permanenô macrï area¢ oò PMÁ iî ZMATE.

   Thå  PMÁ  ió á texô blocë thaô ió permanentlù storeä alonç witè  thå  ZMATÅ 
codå  anä caî bå moveä tï anä froí editinç buffers®  Iô containó á  serieó  oæ 
macrï  definitions¬ eacè onå introduceä bù á controì-Ø characteò  followeä  bù 
thå  onå-characteò namå foò thå macrï anä theî thå program®  Functionó 19²  tï 
25´  corresponä  tï  macroó  whoså onå-characteò namå ió  16°  lesó  thaî  thå 
functioî number¬ i.e.¬ froí spacå (32© tï careô (94)®  Becauså thå PMÁ caî  bå 
editeä  froí  withiî ZMATE¬ theså instanô-commanä functionó  caî  bå  modifieä 
quitå  easily®   Iô  mighô  eveî bå possiblå foò onå oæ  theså  macroó  tï  bå 
modifieä bù anotheò macro!

   Permanenô  macroó  arå noô limiteä tï thå nameó thaô caî bå  bounä  tï  keù 
sequences®   Thå maximuí numbeò oæ permanenô macroó woulä bå 25¶ (°  tï  255)®  
However¬ (1© thå valuå ° ió noô allowed¬ (2© uppeò-caså anä loweò-caså letteró 
arå equivalent¬ anä (3© noô alì characteró witè thå higè biô seô arå  distincô 
froí thå samå characteò withouô thå higè biô seô (thougè somå arå  different)®  
Iî all¬ bù mù counô therå arå 16° possiblå permanenô macrï names¬ oæ whicè 63¬ 
aó  mentioneä earlier¬ caî bå bounä tï keys®  Thå otheró caî bå  invokeä  froí 
thå commanä linå oò froí otheò macros.

   Well¬  thió  completeó thå discussioî oæ ZMATÅ foò thió time® Nexô  timå  É 
wilì presenô itó commanä languagå iî detail.
commands.

[This article was originally published in issue 46 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisheò® Furtheò reproductioî foò non-
commerciaì purposeó ió authorizeä® Thió copyrighô noticå musô bå retained.
(c© Copyrighô 1990¬ 199± Socrateó Presó anä respectivå authors]
