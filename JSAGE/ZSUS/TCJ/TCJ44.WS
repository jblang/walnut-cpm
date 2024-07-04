                               Z-System Corneò (c)
                                 by Jay Sage
                        The Computer Journal, Issue 44
                          Reproduced with permission
                           of author and publisher


   Foò thió issuå (anä thå next© É aí goinç tï indulgå myselæ anä writå  abouô 
abouô  somethinç thaô É enjoy¬ eveî though¬ strictlù speaking¬ iô haó  nothinç 
tï   dï  witè  Ú-System®   Thió  subjecô  ió  MEØ-Plus¬  thå   mosô   advanceä 
telecommunicationó  packagå availablå foò CP/Í computers®  É supposå  É  coulä 
arguå  thaô therå ió á philosophicaì oò spirituaì connection¬  sincå  MEØ-Pluó 
allowó  thå  useò dï foò telecommunicationó manù oæ thå samå  thingó  thaô  Ú-
Systeí  allowó  onå  tï dï witè thå operatinç  system¬  namelù  automate®   Iî 
particular¬ É wilì bå describinç MEØ-Plus'ó scriptinç capabilities¬ whicè  arå 
similaò iî somå wayó tï aliaó anä ARUNÚ scriptó iî Ú-System.

   É haä beeî hopinç thaô á regulaò MEØ columî woulä develoğ herå iî TCJ¬  buô 
thaô hasn'ô happened®  Twï oæ thå peoplå whï mighô havå gotteî iô going¬ Brucå 
Morgeî  anä Ricë Charnes¬ arå no÷ employeä iî thå MÓ-DOÓ industry¬ and¬  afteò 
programminç  alì  daù professionally¬ theù don'ô seeí tï havå aó  mucè  energù 
lefô foò hobbù computinç aó theù useä to®  Recently¬ Daviä Goodenough¬  authoò 
oæ  thå QTERÍ telecommunicationó package¬ camå oveò tï mù houså anä goô  QTERÍ 
runninç oî mù SB18° witè itó Wyså 5° terminal®  É aí enormouslù impresseä witè 
whaô  Daviä haó accomplisheä witè thió program» iô ió rapidlù developinç  manù 
oæ thå capabilitieó oæ MEØ-Plus®  É caî envisioî mucè discussioî iî thå futurå 
oæ  botè  MEØ-Pluó anä QTERÍ scripts®  Yoõ caî alsï expecô aî articlå  oò  twï 
abouô QTERM.

   Foò  thió  columî É wilì givå aî overvie÷ oæ MEX'ó commanä  structure¬  anä 
nexô  timå É wilì describå iî detaiì mù suitå oæ scriptó foò usinç  PÃ-Pursuiô 
aó aî examplå oæ whaô caî bå donå usinç thoså commands®  (É originallù planneä 
tï  coveò  botè  iî onå article¬ buô afteò finishinç thå  descriptioî  oæ  thå 
commands¬  É waó alreadù aô mù limit.©  Alonç thå waù É wilì trù tï poinô  ouô 
somå oæ thå bugó anä idiosyncrasieó thaô useró havå discovereä iî MEØ commandó 
anä suggesô meanó tï geô arounä them®  É hopå thaô mù exampleó wilì helğ  givå 
otheró ideaó abouô ho÷ tï makå betteò uså oæ MEØ-Plus®  Althougè regrettablù É 
havå haä verù fe÷ takeró iî thå past¬ É agaiî extenä aî invitatioî tï  readeró 
tï senä må suggestionó anä exampleó foò scripts.


                           Overview of MEX Commands


   Thå  originaì  CP/Í telecommunicatioî prograí MODEM· anä  itó  derivatives¬ 
sucè  aó IMP¬ operatå iî twï modesº terminaì modå anä commanä mode®   Terminaì 
modå  ió useä foò talkinç tï thå remotå system¬ whilå commanä modå ió useä  tï 
controì  thå  locaì  system®  Theså programó havå á relativelù  smalì  seô  oæ 
commandó  fallinç  principallù  intï  twï classesº  thoså  requireä  foò  filå 
transferó anä thoså relateä tï thå setuğ oæ thå program.

   Iî  MEØ-Pluó thå arsenaì oæ commandó ió extendeä enormously¬  anä  anythinç Šthaô  coulä bå donå froí terminaì modå caî bå donå froí commanä modå aó  well® 
(Yoõ  woulä noô wanô tï ruî aî interactivå sessioî thió way¬ buô iô  coulä  bå 
done.©   Therå arå sï manù commandó that¬ thougè É wilì mentioî almosô alì  oæ 
them¬  É  wilì noô bå ablå tï explaiî theí alì iî detail®  Rather¬ É  hopå  tï 
givå yoõ á generaì picturå oæ thå kindó oæ tooló onå haó tï worë witè iî  MEØ-
Plus®  É wilì takå uğ thå commandó iî groups.


Setuğ Commands
­­­­­­­­­­­­­-

   Mosô oæ MEX'ó configuratioî ió controlleä bù threå commandsº STAT¬ SET¬ anä 
TSET®   Thå  STAÔ commanä workó witè morå thaî 5° differenô options¡   Alì  oæ 
theí caî displaù informatioî abouô ho÷ thå systeí ió configured¬ anä alì buô á 
fe÷ alsï allo÷ thå configuratioî tï bå changed®  Thå MEØ STAÔ parameteró  falì 
intï fouò classesº switches¬ characters¬ values¬ anä miscellaneous.

   Switcheó  havå valueó oæ OÎ oò OFF®  Onå examplå ió FILTER¬ whicè  controló 
whetheò MEØ wilì filteò froí thå incominç modeí streaí anù controì  characteró 
otheò  thaî  tab¬ backspace¬ carriagå return¬ anä linefeed®  Iæ onå  wantó  tï 
perforí fulì screeî operations¬ thió filteò musô bå off® Otherwise¬ thå escapå 
characteró thaô initiatå á screeî controì sequencå wilì bå swalloweä bù MEX.

   Characteò STAÔ parameteró takå á singlå ASCIÉ characteò aó theiò value®  Aî 
examplå ió SEP¬ thå multiplå commanä separatoò (likå Ú-System¬ MEØ-Pluó allowó 
multiplå commandó oî á line)®  Valuå parameteró takå oî numericaì values®  Foò 
example¬  PAGÅ setó thå numbeò oæ lineó iî á pagå oî thå screen¬ anä CLOCË  ió 
seô tï thå clocë speeä oæ youò microprocessoò chiğ sï thaô timinç delayó  wilì 
comå ouô right®  Thå miscellaneouó STAÔ parameteró mostlù controì thå  displaù 
oæ groupó oæ information®  "STAÔ ?¢ listó alì thå STAÔ parameters» "STAÔ  VAL¢ 
showó thå valuå parameters.

   Thå SEÔ commanä controló thå modeí setup®  Iô ió useä foò settinç thå  bauä 
rate¬ worä length¬ numbeò oæ stoğ bits¬ anä paritù mode®  Thå TSEÔ commanä waó 
onå É neveò useä untiì workinç oî thió article®  Iô controló speciaì  featureó 
relateä tï thå terminaì (whaô ió doeó dependó oî thå terminaì yoõ arå  using)®  
Witè mù Wyså 50¬ á TSEÔ parameteò caî forcå alì characteró tï bå displayeä  iî 
uppeò caså characteró oò iî highlighteä videï (thaô shoulä givå yoõ somå  ideá 
oæ whù É havå neveò useä thió command).


Operatinç Systeí Commands
­­­­­­­­­­­­­­­­­­­­­­­­-

   Anotheò grouğ oæ commandó dealó witè thå interfacå tï thå operatinç system.

   Naturally¬  therå  haó  tï  bå á waù tï geô ouô oæ  MEØ  anä  bacë  tï  thå 
operatinç  systeí  prompt®  Havå yoõ eveò beeî trappeä insidå á  program¬  noô 
knowinç  ho÷  tï  exit¿   Well¬ MEØ authoò Roî Fowleò musô  havå  haä  sucè  á 
harrowinç  experience¬  becauså hå haó siø (counô 'em!© commandó  foò  gettinç 
outº  BYE¬  EXIT¬ QUIT¬ CPM¬ DOS¬ anä SYSTEM®  SYSTEÍ musô  comå  froí  BASIC¬ 
whicè  ió  thå onlù CP/Í prograí É eveò becamå trappeä  inside®   MEØ-Pluó  ió Šavailablå iî aî MÓ-DOÓ versioî aó well¬ anä thaô ió wherå thå exiô commanä DOÓ 
comeó from®  Aó á CP/Í diehard¬ É takå greaô pleasure¬ aó yoõ caî imagine¬  iî 
exitinç  froí  mù DOÓ versioî usinç thå commanä CPÍ (iô doesn'ô  helğ  ­­  I'í 
stilì iî MÓ-DOÓ afteò É exit).

   Therå  arå commandó foò doinç operatinç systeí choresº DIR¬ REN¬  ERÁ  (or¬ 
followinç  MÓ-DOS¬  DEL)¬ TYPE¬ anä LOÇ (changå drive/user)®   Somå  oæ  theså 
commandó  noô onlù perforí theiò functions» theù alsï returî  informatioî  foò 
uså iî á scripô file®  DIR¬ foò example¬ setó á speciaì variablå tï thå numbeò 
oæ  matchinç  fileó  found¬  anä  thuó caî bå  useä  tï  determinå  whetheò  á 
particulaò filå existó oò not.

   Therå  arå thå commandó KEÙ foò associatinç stringó witè anù ASCIÉ  keù  oî 
thå keyboarä anä PHONÅ foò enterinç phonå numberó intï á dialinç library®  Thå 
keù definitionó anä phonå numbeò librarù caî bå storeä iî disë fileó witè  thå 
respectivå extensionó KEÙ anä PHN®  Thå commandó SAVÅ anä LOAÄ writå thå  datá 
tï anä reaä thå datá froí thå files.

   MEØ-Pluó  haó á facility¬ viá thå INSTALÌ command¬ tï loaä  optionaì  extrá 
codå  modules®   Onå  sucè modulå (thå REMOTÅ module© allowó  MEØ-Pluó  tï  bå 
operateä  aó á remotå accesó system®  É havå useä thió witè botè  direcô  wirå 
anä modeí connectionó betweeî machines®  Thå formeò ió handù wheî twï machineó 
arå connecteä bù á cable¬ aó iô relieveó onå oæ thå neeä tï ruî bacë anä fortè 
betweeî thå twï keyboardó tï issuå filå transfeò commands®  É sometimeó  leavå 
mù systeí aô worë iî remotå modå sï thaô É caî calì iô froí homå tï picë uğ  á 
filå thaô É forgoô tï takå witè me®  Otheò optionaì moduleó supporô  emulatioî 
oæ variouó terminals¬ includinç thå VT100.

   Thå  TERÍ anä TERMÁ commandó opeî á filå tï recorä thå  incominç  characteò 
streaí  froí thå modem®  TERÍ createó á ne÷ file¬ whilå TERMÁ appendó thå  ne÷ 
texô  tï aî existinç file®  Thå terminaì modå commandó T¬ L¬ anä  Å  describeä 
belo÷  caî alsï takå aî optionaì 'A§ suffiø anä capturå filå name®   Iî  thoså 
cases¬  oncå thå capturå filå haó beeî opened¬ MEØ ió puô intï terminaì  mode® 
Thå  TERÍ  anä  TERMÁ commandó leavå MEØ iî commanä modå  foò  furtheò  scripô 
processing®   Thå VIE× commanä allowó thå contentó oæ thå capturå filå  tï  bå 
revieweä whilå online¬ therebù affordinç somå scrolì-bacë capabilitù (thaô is¬ 
á  waù tï seå texô thaô haó alreadù scrolleä ofæ thå screen)®  WRÔ closeó  thå 
capturå filå (saveó it© wheî yoõ arå done» DEÌ discardó it.

   Thå ALÔ commanä specifieó aî alternatå drive/useò areá (iî additioî tï  thå 
currentlù  loggeä  one© wherå MEØ caî searcè automaticallù  foò  fileó  (e.g.¬ 
scripts¬ phonå directory¬ etc.)®  Thå SEARCÈ commanä telló MEØ ho÷ tï gï abouô 
searchinç  foò files¬ sucè aó whetheò tï searcè thå alternatå areá  beforå  oò 
afteò thå loggeä area.

   Aó  yoõ  caî probablù guesó already¬ iô ió noô easù tï remembeò  alì  theså 
commandó anä thå syntaø theù require®  Thaô ió wherå thå HELĞ commanä comeó iî 
handy®   Iô  accesseó  aî extensivå HLĞ filå (oveò 70K)®  Therå  ió  alsï  thå 
wonderfuì  CLONÅ command¬ whicè createó á ne÷ versioî oæ MEØ (i.e.¬ á ne÷  COÍ 
file©  witè thå currenô configuratioî embeddeä ­­ afteò thå STAT¬  SET¬  TSET¬ 
anä otheò commandó havå beeî useä tï changå parameteró tï one'ó liking.
Š
Telephonå Interfacå Commands
­­­­­­­­­­­­­­­­­­­­­­­­­­­-

   MEØ-Pluó haó twï phonå-dialinç commands¬ CALÌ anä DIAL®  Botè accepô  listó 
oæ  eitheò literaì telephonå numberó oò nameó froí thå phonå library®  Numberó 
anä  nameó  maù  bå mixed®  Numberó iî thå librarù maù  havå  associateä  bauä 
rates¬  whicè  wilì bå selecteä automaticallù wheî thaô numbeò ió  dialed®  Aî 
optionaì  parameteò  specifieó thå numbeò oæ timeó tï trù  connectinç  tï  thå 
numberó  beforå givinç up¬ anä thå commandó returî á valuå tï  indicatå  whicè 
number¬ iæ any¬ waó reached®  Herå ió aî example:

                CALÌ LADERÁ 61·-96µ-725¹ #3

Thió  wilì  alternatelù  calleä  thå Laderá Ú-Nodå (whoså  numbeò  ió  iî  thå 
library©  anä  mù  Ú-Nodå uğ tï threå timeó beforå givinç  up®   Thå  commandó 
diffeò  iî thaô CALÌ putó onå iî terminaì modå afteò á successfuì  connection¬ 
whilå DIAÌ leaveó onå iî commanä modå foò furtheò scripô processing.

   Therå ió alsï á waù tï geô ouô oæ á connection®  DSÃ wilì telì thå modeí tï 
droğ  thå connection®  Iô caî bå configureä (usinç á STAÔ command¬ oæ  course© 
tï uså eitheò thå DTÒ (datá terminaì ready© hardwarå controì linå oò thå Hayeó 
AÔ hanguğ command.


Terminaì Commands
­­­­­­­­­­­­­­­­-

   Therå  arå  threå  commandó  foò enterinç terminaì  mode®   Thå  commanä  Ô 
(terminal©  setó  uğ  á fulì-dupleø terminaì mode®  Characteró  typeä  aô  thå 
keyboarä arå senô tï thå modem» characteró receiveä froí thå modeí arå senô tï 
thå  screen®   Iæ yoõ arå tï seå whaô yoõ arå typing¬ thå remotå  systeí  musô 
echï bacë thå characteró iô receiveó froí you®  Mosô microcomputeò BBÓ systemó 
dï that.

   Thå  Ì  (locaì  echo© commanä setó uğ á  halæ-dupleø  terminaì  mode®   Thå 
differencå ió thaô thå characteró thaô yoõ typå arå noô onlù senô tï thå modeí 
foò transmissioî tï thå remotå system» theù arå alsï echoeä locally® Thió modå 
woulä bå useä witè systemó likå GEniå thaô dï noô normallù echï thå characteró 
theù receivå froí you.

   Finally¬  thå  Å (echo© commanä setó yoõ uğ aó iæ yoõ werå á  remotå  host® 
Everù  characteò yoõ receivå ió theî echoeä bacë tï thå modem®  Iæ twï  peoplå 
runninç  MEØ  calì  eacè otheò (oò twï machineó arå hookeä uğ bù  cablå  aó  É 
mentioneä  earlier)¬  eitheò botè shoulä bå iî Ì mode¬ oò onå shoulä bå  iî  Ô 
modå  anä  thå  otheò  iî  Å mode®  É prefeò  thå  latter¬  sincå  seeinç  thå 
characteró oî thå screeî oæ thå machinå iî Ô modå assureó thaô thå  connectioî 
ió  working®  É leavå iô aó aî exerciså tï thå readeò tï figurå ouô whaô  wilì 
happeî  iæ botè machineó arå iî Å mode®  (Hintº feeì freå tï  experiment»  yoõ 
caî geô ouô oæ thå infinitå looğ bù exitinç froí terminaì mode» yoõ don'ô havå 
tï reboot.)
Š
Filå Transfeò Commands
­­­­­­­­­­­­­­­­­­­­­-

   Fileó arå senô tï thå otheò computeò usinç thå Ó command¬ anä receiveä froí 
thå otheò computeò usinç thå Ò command®  MEØ-Pluó supportó threå filå transfeò 
protocolsº  KERMIT¬ XMODEM¬ anä YMODEM®  Thå defaulô protocoì ió seô witè  thå 
PROTÏ  command®  Thå protocoì caî alsï bå specifieä explicitlù usinç á  prefiø 
(K¬ M¬ oò Y© tï thå Ó oò Ò command.

   Thå commandó wilì alsï accepô anù oæ severaì suffixeó aó well®  Thå  suffiø 
Â indicateó á batcè-modå transfer®  Thå Ë suffiø witè thå Ó commanä  indicateó 
thaô thå filå shoulä bå senô iî blockó oæ 1Ë byteó insteaä oæ thå standarä 12¸ 
bytes®   Iæ  yoõ  appenä  T¬ L¬ oò E¬ yoõ wilì  returî  tï  thå  correspondinç 
terminaì modå afteò thå transfeò ió completed®  Thå Ä anä Ø suffixeó wilì telì 
MEØ tï disconnecô froí thå remotå systeí afteò thå transfeò ió finished»  witè 
Ä yoõ wilì returî tï MEX¬ whilå witè Ø yoõ wilì exiô MEØ aó well®  Herå ió  aî 
example.

                YSBKØ FILE± FILE² FILE3

Thió wilì senä thå threå fileó usinç YMODEÍ batcè witè 1Ë blocks¬ hanç uğ  thå 
phone¬ anä exiô froí MEX.

   Transactionó  witè  á hosô iî thå KERMIÔ serveò modå arå supporteä  witè  á 
numbeò oæ speciaì commandó (KGET¬ KPUT¬ KBYE¬ KLOG¬ KFIN).


Videï Commands
­­­­­­­­­­­­­-

   Theså arå thå commandó thaô Ricë Charneó loveó so¡  Therå arå commandó  foò 
cursoò  addressinç  (@)¬  beginninç anä endinç thå uså oæ  uğ  tï  fouò  videï 
attributeó   (STARÔ  anä  END)¬  displayinç  speciaì   linå-drawinç   graphicó 
characteró  (DRAW)¬  anä creatinç lineó anä boxeó (HLINE¬  VLINE¬  BOX)®   Thå 
screeî caî bå cleareä (CLS)®  Iô caî alsï bå turneä oî anä ofæ (SCREEN© sï yoõ 
caî controì whaô outpuô ió seeî anä whaô ió not.


Variables
­­­­­­­­-

   Iô ió harä tï dï verù sophisticateä processinç withouô variables®  MEØ-Pluó 
offeró  variableó oæ twï typesº numericaì anä string®  Thå formeò  arå  1¶-biô 
integeró  (i.e.¬ numberó froí ° tï 65535)» thå latteò arå stringó oæ uğ tï  3² 
characters.

   Therå arå 2¶ numericaì useò variableó designateä bù á percenô sigî followeä 
bù  á  letteò (caså doeó noô matter¬ e.g.¬ %á oò %S)®  Therå  arå  siø  strinç 
variableó  designateä  bù  thå letteró Á througè F®  I'vå  neveò  ruî  ouô  oæ 
numericaì variables¬ buô É surå wisè therå werå morå strinç variables.
Š   Therå arå alsï twï speciaì numericaì variableó calleä VALUÅ anä STACK®  Thå 
formeò  ió useä tï holä thå valuå returneä froí á numbeò oæ MEØ commandó  (DIÒ 
anä  DIAL/CALÌ werå mentioneä earlier)®  STACË ió á morå  lonç-liveä  variablå 
thaô caî bå exchangeä iî variouó wayó witè VALUÅ (thå commandó PUSH¬ POP¬  anä 
XCHG)®  É thinë theså arå lefô oveò froí earlieò versionó oæ MEØ thaô diä  noô 
offeò  thå 2¶ useò variables®  Therå ió littlå reasoî tï uså STACË  anù  more®  
Therå  arå threå speciaì operationó (ADD¬ SUB¬ anä XOR© thaô caî bå  performeä 
oî thå VALUÅ variable®  I'vå neveò founä anù uså foò these¬ either.

   MEØ  caî  evaluatå  arithmetiã expressionó consistinç  oæ  combinationó  oæ 
literaì  numbers¬ numericaì variables¬ anä arithmetiã operatoró («-*/)®   Herå 
ió aî examplå thaô returnó thå leasô significanô bytå oæ thå twï-bytå variablå 
%V:

                %Ö ­ 25¶ ª ¨ %Ö ¯ 25¶ )

Numberó  caî bå entereä iî hexadecimaì formaô bù prefixinç thå numbeò  witè  á 
dollaò sigî ($10° ió 256).

   Thå valuå oæ aî expressioî ió assigneä tï á variablå bù thå equaì  operatoò 
(=©  aó  iî %B=%A+3®  NOTEº iî mosô placeó iî MEØ-Plus¬ extrá  spaceó  maù  bå 
includeä iî commanä expressions®  However¬ therå arå unfortunatelù á numbeò oæ 
bugó  iî  MEØ-Plus¬  anä  somå reaò theiò headó iî  thió  area®  Therefore¬  É 
recommenä thaô extrá spaceó bå omitteä iî workinç scriptó (aó opposeä tï fullù 
commenteä referencå versions¬ wherå extrá spaceó mighô bå includeä tï  improvå 
readability).

   Literaì  strinç expressionó arå composeä bù surroundinç texô  witè  doublå-
quotå characteró (")®  Thå MEØ manuaì sayó thaô valueó arå assigneä tï  strinç 
variableó usinç thå STORÅ commanä aó in:

             STORÅ "thió ió á test¢ TÏ A.

Experimenô  showó thaô thå followinç simpler¬ undocumenteä syntaø alsï  worksº 
A="test"®   Herå É kno÷ froí bitteò experiencå thaô therå shoulä bå  nï  extrá 
spaceó arounä thå equaì sign®  Iô ofteî works¬ buô noô always®  Mosô  commandó 
thaô  accepô quoteä literaì stringó wilì alsï accepô strinç  variableó  (e.g.¬ 
B=Á oò COMĞ Á "yes").

   Commanä  linå parameteró arå alsï availablå tï scripts» theù arå passeä  iî 
thå  forí  oæ variableó representeä bù thå numberó ± througè ¹  surroundeä  bù 
curlù  braces®  Theså variableó caî alwayó acô aó strings®  Iæ theù expresó  á 
number¬  theù caî alsï bå useä aó numericaì expressions®  Thus¬ wå mighô  havå 
A="{1}¢  oò %A={1}®  Thå latteò expressioî wilì producå aî erroò iæ thå  firsô 
commanä linå tokeî doeó noô represenô á number.

   Iæ  thå scripô invocatioî commanä linå doeó noô havå á tokeî referenceä  bù 
aî  expressioî oæ thå forí {1}¬ {2}¬ etc.¬ thå scripô wilì bomâ witè aî  erroò 
message®   Thå  expressioî {n:default© allowó á defaulô valuå tï bå  useä  foò 
parameteò 'n§ iæ nonå ió giveî oî thå commanä line®  Thió defaulô valuå caî bå 
null¬ aó iî {1:}.
Š   Strinç  variableó  can¬  likå thå commanä linå tokens¬  bå  representeä  iî 
expressionó  bù curlù braceó arounä thå letteò (e.g.¬ {B})®  Iî sucè  á  case¬ 
thå  valuå  oæ thå expressioî ió thå strinç oæ characteró  alone¬  anä  doublå 
quotå  characteró musô surrounä thå expressioî iî mosô situations®  Therå  arå 
exceptions®  Thå SAÙ anä SENDOUÔ commandó (describeä iî thå nexô section©  caî 
bå useä directlù witè á variable¬ aó iî SAÙ A®  Thå followinç twï commandó arå 
equivalent:

                SAÙ "Variablå Á haó thå valueº ",A,"/n"
                SAÙ "Variablå Á haó thå valueº {A}/n"

   Thå curlù-bracå expressionó caî bå useä tï concatenatå text¬ aó in

                A="{Bı anä {C}"

Expressionó  oæ  thió typå arå noô documenteä anä worë onlù iî  scripô  files» 
theù  wilì  noô worë iæ entereä directlù aô thå MEØ commanä  prompt®   Similaò 
expressionó caî alsï bå useä tï finesså variableó intï commandó thaô  normallù 
dï noô takå them®  Herå arå somå examples:

                seô bauä {bı       (where¬ say¬ B="1200")
                seô bauä {c}0°     (where¬ say¬ C="24")
                gotï {1ı           (where¬ say¬ tokeî ± ió LOOP)
                {aı                (where¬ say¬ A="seô bauä 1200")

   É  havå noô figureä ouô ho÷ tï spliô á strinç variablå intï partó (sucè  aó 
words)®  É alsï haä neveò beeî ablå tï figurå ouô á waù tï converô á numericaì 
variablå  intï á string®  É stilì can'ô dï iô directlù (thingó likå B={%Bı  dï 
noô  work)¬ buô thå scripô iî Fig® ± doeó iô indirectlù (inventionó likå  thió 
arå  parô  oæ thå fuî oæ writinç thió column)®  Yoõ maù noô bå ablå  tï  fullù 
understanä  thaô  scripô untiì yoõ havå reaä througè thå resô oæ  thå  commanä 
descriptions.

­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­-

B="¢                    initializå tï nulì string
%y=%â                   seô uğ scratcè variablå %y

LABEÌ LOOĞ              loop
%x=%ù-10*(%y/10©        geô thå lowesô digiô ¨ %ù MOÄ 1° )
iæ %x=° B="0{B}¢        preconcatenatå thå appropriatå digit
iæ %x=± B="1{B}"
iæ %x=² B="2{B}"
iæ %x=³ B="3{B}"
iæ %x=´ B="4{B}"
iæ %x=µ B="5{B}"
iæ %x=¶ B="6{B}"
iæ %x=· B="7{B}"
iæ %x=¸ B="8{B}"
iæ %x=¹ B="9{B}"
%y=%y/1°                dividå numbeò bù 10
iæ %y>° GOTÏ LOOĞ       continuå untiì numbeò ió reduceä tï 0Š
Figurå  1®   Commenteä  listinç oæ á scripô thaô wilì  converô  thå  numericaì 
variablå  %Â intï strinç forí iî strinç variablå B¬ froí whicè iô caî bå  useä 
iî  variouó commands¬ sucè asº SEÔ BAUÄ {B}®  Thió codå coulä bå madå  intï  á 
subroutinå bù addinç thå commanä PROÃ NUM2STÒ aô thå beginninç anä ENDĞ aô thå 
end®  Iæ yoõ trù thió script¬ dï noô enteò thå comments¬ oæ course.

­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­-


Input/Outpuô Commands
­­­­­­­­­­­­­­­­­­­­-

   Programó  generallù arå noô terriblù usefuì iæ therå ió nï waù tï geô  datá 
iî oò out®  Herå ió whaô MEØ-Pluó offers.

   Thå  SAÙ commanä allowó onå tï senä characteró tï thå screen®   Iô  acceptó 
argumentó oæ literaì strings¬ strinç variables¬ anä numericaì expressions¬  aó 
in

                SAÙ "Thå suí is",%A+%B,"/n"

Therå  arå speciaì characteò codes¬ sucè aó "/n¢ (newline© oò  "/r¢  (return)® 
Combineä  witè  thå  videï commandó mentioneä earlier¬  thå  SAÙ  commanä  caî 
producå somå prettù fancù displays.

   Therå ió alsï thå undocumenteä PRINÔ commanä thaô doeó almosô exactlù  whaô 
SAÙ does¬ excepô thaô iô doeó noô neeä quotatioî markó arounä thå literaì texô 
anä  doeó  noô interpreô anù speciaì expressions®  Tï PRINT¬ everythinç  ió  á 
purå  string®   Therå  are¬ thus¬ á couplå oæ thingó PRINÔ  caî  dï  thaô  SAÙ 
cannot®  Herå arå somå examples:

                PRINÔ Pleaså enteò "Hello¢ aô thå prompt.
		PRINÔ Uså thå expressioî {1ı foò á token.

Iî  thå firsô case¬ PRINÔ allowó onå tï senä á doublå quotå characteò  tï  thå 
screen®  Iî thå seconä case¬ á strinç thaô woulä bå á variablå expressioî  caî 
bå displayed.

   Thå SENDOUÔ commanä ió useä tï senä literaì texô oò thå contentó oæ  strinç 
variableó tï thå modem®  Thå PREFIØ anä SUFFIØ commandó caî bå useä tï  definå 
stringó  thaô arå automaticallù senô beforå anä afteò thå designateä  texô  tï 
savå  onå  thå  troublå  oæ havinç tï includå  certaiî  characteró  (sucè  as¬ 
perhaps¬ á carriagå returî anä linefeed© explicitlù witè eacè string®  Longer¬ 
fixeä stringó caî bå senô usinç thå TRANSMIÔ command¬ whicè sendó thå contentó 
oæ  á  filå jusô aó iæ yoõ werå typinç iô iî terminaì mode®  Á paiò  oæ  delaù 
constantó controló thå speeä witè whicè thió "automatiã typist¢ performs.

   Thå  INPUÔ  commanä allowó interactivå entrù oæ thå valuå foò  á  numericaì 
variable» ACCEPÔ doeó thå samå thinç foò á strinç variable®  Thå TIMÅ anä DATÅ 
commandó  allo÷  onå  tï accesó á reaì-timå  clock®   Besideó  displayinç  thå 
informatioî oî thå screen¬ thå commandó arå supposeä tï puô thå  correspondinç Šdatá intï thå VALUÅ variable®  Therå ió á buç here¬ anä thå timå valuå ió useä 
bù  botè  commands®   Therå appearó tï bå nï waù tï determinå  thå  datå  froí 
withiî  á script®  Thå PEEË anä POKÅ commandó allo÷ onå tï looë aô anä  modifù 
memorù  foò thå ultimatå iî hackinç froí á script¡ (Thaô probablù  meanó  thaô 
therå woulä bå á waù tï finä thå datå iæ onå reallù needeä iô badly®  Iô  alsï 
meanó thaô thå completå Ú-Systeí environmenô caî bå accessed.)


Flo÷ Controì Commands
­­­­­­­­­­­­­­­­­­­­-

   Likå  Ú-System¬  MEØ-Pluó haó flo÷ controì commandó tï allo÷  á  scripô  tï 
perforí  testó anä tï acô differentlù dependinç oî thå results®  Therå ió  thå 
standarä  seô oæ flo÷ commandó IF¬ ELSE¬ anä ENDIF®  Theù supporô ¸ leveló  oæ 
nestinç (jusô likå Ú-System)®  Herå ió aî example:

                IÆ %B=1200
                  B="1200"
                ELSE
                  B="2400"
                ENDIF

   Additionally¬ therå ió á singlå-linå IÆ command®  Iô ió distinguisheä  froí 
thå  multiplå-linå  IÆ bù á commanä (á 'then§ clause© thaô ió parô oæ  thå  IÆ 
statement®  Herå ió aî example:

                IÆ %B=240° B="2400";SAÙ "240° bps";GOTÏ CONTINUE

Witè  thå  singlå-linå IF¬ wheî thå tesô fails¬ thå entirå  linå  ió  ignored® 
Pleaså notå thaô haä therå beeî á semicoloî afteò thå "IÆ %B=2400"¬ theî  thió 
woulä havå beeî á multiplå-linå IÆ (albeiô witè severaì oæ itó 'lines§ oî  onå 
line).

   Thå  singlå-linå  IÆ  commanä  comeó iî especiallù  handy¬  becauså  iô  ió 
generallù  awkwarä  tï  perforí á GOTÏ jumğ ouô  oæ  aî  IF/ELSE/ENDIÆ  block® 
Althougè  thå manuaì warnó againsô it¬ therå ió (I'í prettù sure© nï harí  peò 
så  iî doinç it®  Iô ió jusô thaô yoõ havå tï makå surå thaô thå ENDIÆ ió  noô 
skippeä lesô yoõ geô nesteä deepeò anä deeper®  Aó witè Ú-System¬ yoõ havå  tï 
makå surå thå IFó geô terminated» unfortunately¬ thió ió noô sï easy¬ because¬ 
unlikå  Ú-System¬  MEØ-Pluó  haó  nï  XIÆ oò ZIÆ  command®   Herå  ió  á  verù 
convoluteä examplå oæ á waù iî whicè iô coulä bå done:

                iæ %b
                  saù "TRUE/n"
                  gotï cont
                endif
                .
                saù "FALSE/n"
                gotï done
                .
                labeì cont
                endifŠ                .
                labeì done
                saù "No÷ wå arå done/n"

   Therå ió alsï á SKIPIÆ command®  Iæ itó tesô ió true¬ theî thå nexô commanä 
ió  skipped®  Notå welì thaô whilå thå IÆ commanä maù skiğ aî entirå  linå  oæ 
commands¬  SKIPIÆ  skipó  onlù onå command¬ nï matteò ho÷  manù  commandó  maù 
appeaò oî thå samå line.


Numericaì Tests
­­­­­­­­­­­­­­-

   Flo÷  controì woulä noô bå verù usefuì withouô wayó tï tesô things®   Firsô 
wå wilì consideò testó oî numbers.

   Tesô resultó arå expresseä numerically¬ witè ° representinç falså anä  noî-
zerï (usuallù 1© representinç true®  Yoõ caî seå thió foò yourselæ bù enterinç 
thå  commanä "SAÙ 1<2¢ oò "SAÙ 1>2"®  Thå followinç logicaì operatoró  caî  bå 
useä foò comparisonsº equaló (=)¬ noô equaló (<>)¬ lesó thaî (<)¬ lesó thaî oò 
equaì tï (<½ oò =<)¬ greateò thaî (>)¬ oò greateò thaî oò equaì tï (>½ oò =>)®  
Notå thaô thå MEØ manuaì haó á misprinô iî onå placå anä giveó thå  noô-equaì-
tï operatoò aó '!'®  Thaô ió incorrecô anä wilì noô work.

   Althougè  comparisoî testó returî á numericaì value¬ thoså valueó foò  somå 
reasoî  cannoô bå useä iî arithmetiã expressions®  Iî otheò words¬  yoõ  can'ô 
havå  (%A>%B)*(%A<%C)®   Aó  faò aó É caî tell¬ thió  meanó  thaô  yoõ  cannoô 
perforí  compounä  tests¬  sucè  aó "IÆ %A>%Â  ANÄ  %A<%C"®   Performinç  sucè 
compounä testó ió madå morå difficulô bù thå facô thaô thå 'then§ clauså oæ  á 
singlå-linå  IÆ  cannoô  bå anotheò IF®  Iæ yoõ won'ô bå  usinç  GOTO¬  nesteä 
multé-linå IÆ commandó wilì dï thå trick®  Otherwise¬ yoõ mighô havå tï resorô 
tï somå expliciô arithmetiã aó iî thå following:

                %z=1
                if %a<=%b then %z=0
                if %a>=%c then %z=0  
                if %z then ....

Wå  starteä ouô assuminç TRUÅ (%z=1)®  Theî iæ eitheò conditioî waó false¬  wå 
seô %ú tï false.

   Beforå wå leavå thió topiã (É kno÷ we'vå beeî herå á lonç time)¬ É havå  tï 
mentioî  thaô  MEØ  haó  á buç thaô causeó iô tï  issuå  fallaciouó  buô  verù 
annoyinç erroò reportó wheî comparisoî operationó arå performeä witè numericaì 
variableó  havinç  particulaò  values®   É  havå  carrieä  ouô  á  numbeò   oæ 
experimentó  tï  trù  tï determinå thå exacô circumstanceó  undeò  whicè  thió 
probleí  occurs¬  buô  sï faò É cannoô fathoí á pattern®   Thå  troublå  ofteî 
appears¬ however¬ witè comparisonó tï standarä datá ratå values¬ sucè aó  300®  
Tï geô arounä thå problem¬ É sometimeó dividå thå variablå bù 100¬ comparå  iô 
tï  3¬ 12¬ oò 24¬ anä theî multiplù iô bù 10° tï restorå itó  originaì  value®  
Whaô á pain!
Š
Strinç Tests
­­­­­­­­­­­-

   Stringó arå compareä usinç thå COMĞ command®  Iô acceptó twï strings¬  eacè 
oæ  whicè caî bå eitheò á literaì strinç oò á strinç variable®  Thå resulô  oæ 
thå comparisoî ió returneä iî thå VALUÅ variable¬ whicè caî theî bå testeä foò 
á  valuå oæ ° oò 1®  Thå STAÔ CASÅ settinç determineó whetheò  thå  comparisoî 
wilì bå caså sensitivå oò not®  Therå ió á buç witè thå COMĞ command» iô  wilì 
noô  givå thå answeò ± (true© wheî botè stringó arå nulì ("")¬ thougè iô  wilì 
worë  iæ onlù onå strinç ió null®  Iæ yoõ wanô tï seå iæ á commanä linå  tokeî 
waó given¬ yoõ caî uså thå followinç tests:

                COMĞ "{1:ı ¢ ¢ "
                COMĞ "{1:}X¢ "X"

Aî extrá characteò (spacå oò 'X'© ió concatenateä tï thå strinç representeä bù 
{1:}®  Yoõ mighô alsï use

                COMĞ "{1:null}¢ "null"

Here¬  thå  firsô  parameteò cannoô bå null®  Iæ tokeî ±  ió  noô  given¬  thå 
defaulô  valuå  "null¢ wilì bå useä instead®  Oæ course¬ iæ  thå  useò  enteró 
"null"¬ thå samå resulô wilì bå obtained®  Thå twï earlieò exampleó are¬ thus¬ 
morå robust.

   Therå ió onå oddbalì commanä thaô É don'ô kno÷ wherå tï putº SLEEP®  Iô  ió 
sorô  oæ  á flo÷ controì command¬ sï I'lì sticë iô here®  Iô  jusô  telló  thå 
systeí tï gï tï sleeğ (pause© foò á designateä timå interval.


Prograí Controì Commands
­­­­­­­­­­­­­­­­­­­­­­­-

   MEØ-Pluó  supportó severaì scripô prograí structures®  Thå maiî uniô  oæ  á 
scripô prograí ió á scripô file¬ whicè haó á filå extensioî oæ MEX®  Iô caî bå 
invokeä  aó á maiî prograí bù thå REAÄ command®  Iô caî alsï bå invokeä  aó  á 
subprograí  bù  thå DÏ command¬ whicè allowó scriptó tï bå nested®  É  dï  noô 
kno÷  ho÷ deeğ thió nestinç caî be¬ buô É jusô testeä iô tï fivå levels®   Thå 
STOĞ  commanä ió useä tï exiô froí á REAÄ oò DÏ command®  Iî thå formeò  case¬ 
controì returnó tï thå MEØ prograí (possiblù iî terminaì mode)» iî thå latter¬ 
controì  returnó tï thå scripô thaô calleä thå currenô script®  Á scripô  alsï 
terminateó  automaticallù aô thå enä-oæ-file®  Thå STOĞ commanä  unfortunatelù 
displayó  aî  annoyinç  messagå  abouô  thå  scripô  beinç  aborted®  Tï  exiô 
gracefully¬  iô ió betteò tï puô á labeì aô thå enä (e.g.¬ LABEÌ END©  anä  tï 
exiô usinç GOTÏ END.

   Á  REAÄ  commanä maù bå giveî insidå á script®  Iî thió  case¬  controì  ió 
transferreä tï thå ne÷ script¬ whicè overwriteó thå olä scripô iî memory® Witè 
thå  DÏ  command¬  thå ne÷ scripô lineó arå reaä intï memorù  alonç  witè  thå 
currentlù runninç script.
Š   É  alwayó  enjoù  writinç theså columnó becauså É enä uğ  askinç  somå  ne÷ 
questionó  anä learninç somå ne÷ answers®  Jusô now¬ tï seå ho÷ MEØ  works¬  É 
waó examininç thå memorù imagå afteò á MEØ scripô filå ran®  First¬ É  learneä 
thaô thå scripô texô ió storeä backwardó iî memorù startinç froí neaò thå top®  
É  verifieä  thaô afteò eacè DÏ ió finished¬ thå memorù ió  reclaimeä  anä  ió 
availablå  foò uså bù anotheò subroutinå script®  É alsï discovereä  thaô  thå 
entirå scripô file¬ includinç alì comments¬ ió reaä intï memory.

   Wå  caî dra÷ somå importanô conclusionó froí theså observationó  abouô  ho÷ 
compleø scriptó shoulä bå implemented®  First¬ therå arå severaì advantageó tï 
usinç  versionó  oæ scripô fileó froí whicè commentó havå beeî  stripped®  Thå 
fileó will¬ oæ course¬ loaä faster¬ anä therå wilì alsï bå morå rooí iî memorù 
foò  sucè  thingó  aó filå transfeò buffers®  Manù MEØ  useró  havå  ruî  intï 
problemó oæ insufficienô memorù whilå runninç compleø scripts®  Second¬ iô  ió 
á  gooä  ideá  tï  chaiî  froí onå scripô  tï  anotheò  ratheò  thaî  buildinç 
everythinç  intï á singlå script®  Iî mù PÃ-Pursuiô script¬ É chaiî tï á  verù 
smalì  scripô jusô afteò thå remotå systeí haó beeî reacheä anä thå scripô  ió 
abouô tï puô må intï terminaì mode.

   Structurå ió permitteä withiî aî individuaì scripô filå aó welì iî thå forí 
oæ  internaì subroutines®  Subroutineó begiî witè á PROÃ  (procedure©  commanä 
anä  enä witè aî ENDĞ (enä-procedure© command®  Theù arå invokeä bù thå  GOSUÂ 
command®   Again¬  É  dï noô kno÷ ho÷ deeplù theù maù bå nested¬  buô  É  jusô 
testeä theí tï ¹ levels.

   Scripô fileó maù alsï contaiî unstructureä prograí groupingó (thaô anathemá 
tï moderî structureä programming)®  Thå LABEÌ commanä allowó anù poinô iî  thå 
scripô tï bå giveî á name¬ anä thå GOTÏ commanä allowó á brancè tï thaô point®  
Thå manuaì indicateó thaô thå namå maù havå uğ tï 1¶ alphabetiã characteró anä 
warnó thaô thå linå witè thå LABEÌ commanä maù noô havå anù otheò commandó  oî 
thå line®  É kno÷ thaô É havå ruî afouì oæ thaô restrictioî iî thå past¬  but¬ 
oddlù enough¬ iî mù testinç no÷ É waó totallù unablå tï generatå á problem®  É 
trieä everythinç É coulä thinë ofº aî immediatå semicolon¬ á semicoloî afteò á 
spacå  oò  á tab¬ tabó afteò thå semicolon®  Theù alì workeä  jusô  finå  (ho÷ 
coulä MEØ telì thaô thió waó jusô á test?).

   Thå  manuaì ió clearlù wronç wheî iô sayó thaô onlù  alphabetiã  characteró 
caî  bå  used®   É  assumeä  thaô iô reallù  meanô  alphanumeric¬  buô  iî  mù 
experimentó  É learneä thaô absolutelù anù characteró caî bå  used¬  includinç 
spaces¡   Herå arå thå ruleó thaô emergeä froí mù testing®  First¬ alì  spaceó 
anä tabó afteò thå LABEÌ commanä arå ignored®  Thaô poinô markó thå  beginninç 
oæ  thå  name®   Nexô  onå startó froí thå enä oæ  thå  linå  oò  thå  commanä 
separatoò characteò anä stripó alì tabó anä spaceó backward®  Thaô poinô markó 
thå enä oæ thå name®  Whaô ió betweeî thoså markó ió takeî aó thå label®   Foò 
example¬  onå caî havå á labeì oæ "ENTRÙ 1¢ (witè thå embeddeä spacå anä  witè 
oò  withouô thå quotå characters¬ iî fact)®  Minä you¬ É aí noô bù  anù  meanó 
suggestinç thaô yoõ uså sucè labels®  Aó É mentioneä before¬ É havå noô alwayó 
founä  MEØ tï behavå exactlù thå waù iô diä iî theså experiments®   Iæ  anyonå 
caî figurå thió ouô morå precisely¬ É woulä reallù likå tï heaò abouô it.

   Thå  otheò thinç É learneä froí theså experimentó ió thaô MEØ alwayó  scanó 
foò á labeì froí thå beginninç oæ thå script®  Thió meanó thaô iæ yoõ uså  thå Šsamå labeì á seconä time¬ thå seconä occurrencå wilì neveò bå found.


                            Onå Scripô Example

   É  jusô don'ô feeì righô abouô presentinç alì thió informatioî  abouô  MEØ-
Pluó commandó withouô showinç aô leasô onå reaì-lifå example®  Figurå ²  showó 
thå  finaì  scripô iî mù PÃ-Pursuiô scripô suite®  Oncå  É  havå  successfullù 
connecteä tï thå outdiaì citù anä reacheä thå remotå systeí there¬ É chaiî  tï 
thió script®  Let'ó looë aô iô linå bù line.

   Thå firsô linå beginó witè á period¬ sï iô ió á comment®  É alwayó  includå 
á titlå linå anä ofteî adä somå descriptioî oæ thå functioî oæ thå scripô  anä 
thå parameteró iô takes.

   Thå reaì worë oæ thå scripô beginó aô linå 3®  Iî manù partó oæ thå script¬ 
É dï noô wanô thå outpuô froí commandó tï sho÷ oî thå screen®  No÷ É do¬ sï  É 
issuå thå "SCREEÎ ON¢ command®  I'ä alsï likå tï starô witè á cleaî screen¬ sï 
É issuå CLS¬ too.

   Iî  linå 5¬ thå scripô telló thå useò thå namå oæ thå systeí thaô haó  beeî 
reacheä  (thaô  waó previouslù storeä iî strinç variablå F© anä aô  whaô  bauä 
ratå (previouslù storeä iî strinç variablå B)®  Theî thå scripô dropó onå intï 
terminaì mode¬ wherå onå caî worë interactivelù aó lonç aó onå likes.

   Wheî  terminaì modå ió exiteä (bù pressinç <ESC¾ E)¬ thå scripô resumeó  aô 
thå  labeì  LOOP®  Linå ¹ promptó thå useò tï enteò á command®   Iæ  thå  useò 
enteró  "M"¬  theî thå maiî menõ scripô ió run¬ allowinç onå tï  calì  anotheò 
systeí iî anotheò oò thå samå city®  Linå 1° acceptó thå answeò froí thå  useò 
anä placeó iô intï strinç variablå A.

   Iî  linå  11¬ thå user'ó answeò ió compareä tï thå strinç "M"®  Iæ  iô  waó 
"M"¬  theî thå variablå VALUÅ wilì havå thå valuå ± (true)¬ anä linå  1²  wilì 
causå thå scripô tï chaiî tï thå scripô filå PCPMENU.MEX®  Iæ thå useò entereä 
anythinç  otheò thaî "M"¬ theî executioî wilì continuå aô linå 13¬  wherå  thå 
user'ó  commanä  ió executed®  Wheî thaô commanä haó completed¬  controì  wilì 
returî tï linå 14¬ whicè brancheó bacë tï labeì LOOĞ anä á prompô foò  anotheò 
command.

   Thå user'ó commanä caî bå jusô abouô anything®  Foò example¬ iæ iô ió  "T"¬ 
theî  MEØ  wilì  enteò  terminaì modå foò  morå  interactivå  work®   Thå  onå 
restrictioî  É  havå found¬ ió thaô onlù á singlå commanä caî bå  entered®   Á 
multiplå commanä line¬ witè commandó separateä bù semicolonó (oò whateveò  thå 
designateä  SEĞ  characteò  is)¬  doeó  noô worë foò  reasonó  É  dï  noô  yeô 
understand®   Maybå  É wilì havå figureä iô ouô (oò onå oæ yoõ wilì  have©  bù 
nexô time¬ wheî É wilì coveò thå reaì gutó oæ thå PÃ-Pursuiô script.

­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­-

01  .. PCPCONN SCRIPT -- Connected to Destination System
02  
03  screen onŠ04  cls
05  say "Connected to ",F," at ",B,"00 bps/n/n"
06  t
07  
08  LABEL LOOP
09  say "/nEnter single MEX command (or M for menu): "
10  accept A
11  comp A "M"
12  if value=1 READ PCPMENU
13  {A}
14  GOTO LOOP

Figurå  2®   Thió  ió thå finaì scripô iî mù  PÃ-Pursuiô  suite®   Jusô  afteò 
connectinç  tï  á  remotå system¬ É chaiî tï thió scripô tï freå  uğ  aó  mucè 
memorù  aó  possiblå  foò  otheò uses¬ sucè aó  capturå  bufferó  and/oò  filå 
transfeò buffers®  Linå numberó havå beeî addeä foò referencå purposeó iî  thå 
text.

[This article was originally published in issue 44 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisher. Further reproduction for non-
commercial purposes is authorized. This copyright notice must be retained.
(c) Copyright 1990, 1991 Socrates Press and respective authors]
