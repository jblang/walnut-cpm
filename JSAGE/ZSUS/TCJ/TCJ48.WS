                               Z-System Corneò (c)
                                 by Jay Sage
                        The Computer Journal, Issue 48
                          Reproduced with permission
                           of author and publisher

                  Patchinç MEX-Pluó anä Thå Word¬ Usinç ZEX

Foò thió issuå É havå á largå numbeò oæ smalì subjectó tï cover® É wilì  begiî 
witè thå lonç-promiseä patcheó tï MEØ­ Plus¬ thå oneó É losô wheî mù harä disë 
crasheä anä theî recovereä wheî thå harä disë miraculouslù resurrecteä itself® 
É haven'ô haä timå tï incorporatå alì thå correctionó anä additionó thaô  havå 
beeî oî mù list¬ buô thió wilì bå á gooä starô oî aî oî-goinç project.

Whilå  oî  thå subjecô oæ patching¬ É wilì enlargå oî thå  discussioî  oæ  thå 
patcè  tï  Thå Worä Pluó thaô É presenteä iî issuå #45® Iô turnó ouô  thaô  aô 
leasô  twï differenô versionó oæ TW.COÍ arå currentlù iî circulation¬ anä  thå 
originaì patcè workó onlù witè one.

Á couplå oæ readeró havå requesteä helğ witè ZEX® Theù arå awarå thaô  Bridgeò 
Mitchelì  provideä  fulì documentatioî iî hió columî iî issuå  #38¬  buô  theù 
pointeä  ouô  thaô  thå  subjecô ió ratheò  compleø  anä  woulä  bå  clarifieä 
considerablù  bù á fe÷ examples® Giveî thå poweò oæ commanä aliaó  scripts¬  É 
rarelù havå anù neeä foò ZEX¬ buô É wilì presenô thå twï ZEØ scriptó thaô É dï 
uså regularly® Perhapó somå readeró wilì helğ ouô bù sendinç må copieó oæ somå 
interestinç scriptó thaô theù havå developeä thaô uså thå advanceä featureó oæ 
ZEX5.

Finally¬  É  wilì  continuå mù discussioî oæ ZMATE® Ratheò  thaî  listinç  thå 
remaininç commandó thaô É diä noô coveò lasô time¬ É wilì describå mù  speciaì 
autoexeã  macrï  thaô  allowó  må tï pasó macrï commandó  tï  ZMATÅ  froí  thå 
operatinç systeí commanä line® Thió provideó á verù powerfuì interfacå betweeî 
ZMATÅ anä Ú-Systeí commanä aliaó scripts.

Thió  ió  noô thå onlù informatioî abouô ZMATÅ iî thió issue® É  aí  happù  tï 
announcå thaô wå arå inauguratinç á ne÷ columî bù Cliæ Kinnå oî MATÅ macros.

Onå  otheò quicë announcement® Thå Ú-Systeí Softwarå Updatå Service¬  produceä 
bù Bilì Tisheù anä Chrió McEwen¬ ió expandinç itó services® ZSUÓ wilì no÷ makå 
uğ  custoí  diskó containinç thå fulì LBÒ releaseó oæ anù fileó  yoõ  request® 
Therå wilì alsï sooî bå speciaì softwarå collections® É believå thå firsô wilì 
contaiî materiaì oæ interesô tï assemblù languagå programmers® É invitå yoõ tï 
writå tï må foò á ne÷ flyeò oò tï looë foò announcementó oî BBSs.

Fixinç Uğ MEØ-Plus

Aó  wonderfuì aó É finä MEØ-Plus¬ therå arå quitå á fe÷ bugó thaô neeä  tï  bå 
fixeä  anä quitå á fe÷ additionaì featureó thaô É woulä likå tï seå  added®  É 
havå  jusô  gotteî starteä oî thió projecô anä wilì describå  mù  progresó  tï 
date.

MEØ Improvemenô ListŠ
Besideó thå itemó thaô mù currenô patcè dealó with¬ thå followinç itemó arå oî 
mù lisô oæ needeä improvements.

Thå CLONÅ command¬ whicè createó á ne÷ copù oæ MEØ (i.e.¬ á ne÷ COÍ file© witè 
thå  currenô settingó aó thå default¬ haó thå followinç minoò bugº wheî iô  ió 
entereä withouô specifyinç á filå name¬ iô wilì makå á filå witè extenô  "COM¢ 
anä á filå namå oæ alì spaces¡ Iî thió case¬ iô woulä bå mucè morå sensiblå iæ 
iô eitheò (1© defaulteä tï á namå oæ MEX.COÍ oò (2© refuseä tï dï anything.

Therå  ió á verù annoyinç erroò iî thå waù numericaì variableó arå  processed® 
Wheî thå variableó havå particulaò values¬ MEØ reportó á syntaø error® Sï  faò 
É  havå  noô  beeî ablå tï determinå thå preciså conditionó  undeò  whicè  thå 
probleí  arises¬ buô É hopå thaô witè carefuì studù oæ thå codå É wilì  figurå 
ouô  whaô  ió  wrong®  Mù guesó ió thaô somå CPÕ  flaç  ió  beinç  mió-seô  oò 
misinterpreted.

Therå ió á minoò buç iî thå DATÅ command® Aó thingó arå now¬ TIMÅ anä DATÅ arå 
identicaì  functions¬  anä  botè  returî  thå  timå  iî  thå  VALUÅ  variable® 
Obviously¬ DATÅ shoulä returî thå currenô date.

Iî caså yoõ havå trieä tï uså thå MENU.MOÄ modulå anä havå founä thaô thå HELĞ 
functioî  doeó  noô  work¬ don'ô worry® Yoõ arå noô doinç  anythinç  wronç  oò 
missinç anù piecå oæ thå code® Thió functioî waó implementeä improperlù oò noô 
implementeä  aô alì iî thå CP/Í versioî oæ MEØ-Plus® Wå probablù wilì  noô  bå 
ablå  tï dï mucè abouô thió untiì wå havå figureä ouô MEX'ó interfacå  tï  thå 
externaì modules.

É woulä likå tï mentioî somethinç thaô causeä må grieæ recentlù witè onå oæ mù 
macrosº  WAIÔ  STRINÇ stringó arå limiteä tï 1¶ characters¡ É  don'ô  thinë  É 
woulä changå this¬ buô onå musô beaò thió limitatioî iî mind.

Onå oæ thå mosô importanô additionó woulä bå morå strinç variableó beyonä  thå 
siø  (A..F©  currentlù  implemented® Eveî twï morå woulä benefiô  somå  oæ  mù 
scriptó enormously.

Finally¬  É  woulä  likå  tï  replacå thå  filå  namå  parser¬  whicè  alreadù 
recognizeó  thå  DUº  prefix¬  witè  onå  thaô  handleó  fulì  Ú-Systeí   filå 
specifications.

Mù MEØ Patch

Mù  MEØ patcè ió showî iî Listinç 1® Iô ió heavilù commented¬ anä É  wilì  noô 
repeaô thå detailó iî thå text® Thå patcè makeó threå changes.

MEØ  haó  á  STAÔ commanä thaô turnó oî oò ofæ á functioî  thaô  convertó  thå 
backspacå keù intï á rubout/deletå characteò (whicè wå wilì calì DEÌ froí  no÷ 
on)®  É  havå  alwayó assumeä thaô thió waó includeä froí  oldeî  times¬  wheî 
microcomputeró sometimeó haä nï DEÌ keù anä mainframå computeró­-whicè MEØ waó 
useä tï communicatå witè­-requireä thaô keù foò somå criticaì functions.

Today¬ thå situatioî ió generallù quitå different® First¬ almosô alì computeró Šanä  terminaló no÷ havå á DEÌ key® Second¬ witè thå Ú-System¬ onå  ofteî  useó 
DEÌ interchangeablù witè backspace¬ anä É havå gotteî quitå useä tï that® Wheî 
É  calì noî-Ú remotå accesó systems¬ É finä iô á reaì nuisancå wheî  DEÌ  doeó 
noô work® Thaô ió whù É decideä tï reverså thå functioî oæ thió STAÔ command.

Makinç thå changå itselæ waó quitå simple» thå harä parô waó findinç thå righô 
placeó iî thå code® Threå changeó arå required¬ aó showî aô thå enä oæ Listinç 
1®  Onå bytå containó thå keycodå oæ thå keù tï bå intercepted¬ whilå  anotheò 
bytå containó thå keycodå witè whicè iô ió tï bå replaced® Thå thirä changå ió 
noô  needeä foò propeò operation¬ buô iô ió nicå tï havå thå STAÔ RUÂ  messagå 
reflecô thå ne÷ function.

Thå  nexô changå ió tï thå STAÔ BUÆ command® MEØ verù ofteî haó  itó  commandó 
returî iî thå VALUÅ variablå somå informatioî developeä bù thaô function®  Foò 
example¬  thå  DIÒ  functioî returnó thå numbeò oæ matchinç  fileó  thaô  werå 
found®  Unfortunately¬  thå STAÔ BUÆ commanä displayó  informatioî  abouô  thå 
statuó  oæ  thå  capturå  anä  keù macrï  bufferó  buô  doeó  noô  returî  anù 
informatioî iî VALUE.

É  haä writteî á scripô foò callinç uğ GEniå anä capturinç mù  emaiì  letters® 
Wheî  É relieä oî XON/XOFÆ flo÷ controì tï pauså GEnie'ó outpuô whilå MEØ  waó 
flushinç itó buffer¬ É founä thaô somå texô waó sometimeó lost® Tï geô  arounä 
this¬  É manuallù closeä anä reopeneä thå capturå buffer® Ratheò thaî  wastinç 
thå  timå tï dï thió afteò eacè letter¬ É wanteä tï checë thå amounô oæ  spacå 
remaininç  iî  thå capturå buffer® Iæ thió spacå droppeä belo÷ somå  valuå  (É 
thinë É useä 3K)¬ theî É woulä closå anä reopeî thå buffer.

Implementinç  thió functioî requireä addinç somå ne÷ instructionó tï thå  codå 
foò  thå  STAÔ  BUÆ command® Thió raiseä twï problemsº ho÷  tï  tağ  intï  thå 
originaì codå anä wherå tï puô thå ne÷ instructions.

Leô  uó  starô witè thå seconä problem® Witè somå programs¬ ne÷  codå  caî  bå 
addeä aô thå enä oæ thå originaì code® Iæ thå prograí placeó itó ruî-timå datá 
aô thå enä oæ itó code¬ however¬ thió caî obviouslù presenô somå difficulties® 
Iæ  onå ió patchinç iî somå ne÷ initializatioî codå thaô ió performeä anä  caî 
bå discardeä beforå thå prograí startó tï uså itó datá space¬ theî onå caî geô 
awaù  witè this® Wheî É adä thió kinä oæ patch¬ É trù tï havå iô includå  codå 
thaô  patcheó  ouô thå patcè anä restoreó thå originaì  code®  Otherwise¬  thå 
prograí cannoô safelù bå reruî usinç thå GÏ command¬ sincå thå patcè codå  maù 
havå beeî overwritteî bù prograí data® Attemptinç tï executå datá haó á waù oæ 
wreakinç havoã witè thå system!

Iî  ouò presenô case¬ wå arå addinç codå thaô musô bå availablå aô  anù  time¬ 
anä  MEØ  certainlù  writeó  datá intï thå freå memorù  afteò  itó  owî  code® 
Consequently¬  wå  havå tï finä somå spacå withiî thå boundó oæ  thå  originaì 
program® Thå techniquå É havå useä herå ió tï steaì nonessentiaì internaì datá 
space.

MEØ  normallù  signó oî witè á verù elaboratå screeî displaù  thaô  takeó  34³ 
byteó­-enougè rooí foò á loô oæ patcè code¡ Wå cannoô deletå alì oæ it¬ buô wå 
caî  replacå iô witè á mucè simpleò signoî message® Thå ne÷ onå iî  thå  patcè 
useó  onlù  3±  byteó (iæ É counteä correctly)® Iô letó uó kno÷  thaô  wå  arå Šrunninç thå speciaì versioî oæ MEØ anä telló uó thå datå oæ thå patch.

Tï tağ intï thå originaì code¬ wå chooså á convenienô poinô anä puô iî á  jumğ 
instructioî  tï thå patcè area® Thå instructioî thaô wå replaceä bù thaô  jumğ 
ió thå firsô instructioî iî thå patcè area® Theî wå adä thå additionaì codå tï 
savå thå capturå buffeò freå spacå valuå intï thå VALUÅ variable® Finally¬  wå 
returî tï thå originaì codå jusô pasô thå jumğ wå inserted.

Thå  thirä  changå implementeä iî thå patcè concernó thå  BELÌ  command®  Thió 
commanä  ió  convenienô tï alerô thå useò tï somå event® Iô woulä bå  nicå  tï 
havå  thå belì rinç repeatedlù untiì thå useò signaló thaô hå ió readù  tï  gï 
on® Unfortunately¬ thå commanä "BELÌ 100¢ wilì insisô oî ringinç thå belì  onå 
hundreä  times® "BELÌ 0¢ wilì insisô oî ringinç iô 65,00° times¡ Thå onlù  waù 
onå  caî interrupô thå belì ió tï presó controì-c¬ buô thió abortó thå  entirå 
script®  Thå  patcè  allowó anù keypresó tï aborô  thå  BELÌ  commanä  withouô 
abortinç thå entirå script.

Thió  patcè workó usinç á slightlù differenô technique® Thå BELÌ codå  alreadù 
containó  á  calì tï á routinå thaô checkó foò controì-c® Wå jusô  replacå  iô 
witè  á calì tï á ne÷ routinå iî thå patcè areá thaô checkó foò anù  keypress® 
Afteò  thió call¬ thå originaì codå performeä á conditionaì jumğ tï exiô  froí 
thå routine¬ buô foò reasonó É don'ô remember¬ thió patè waó neveò taken®  Foò 
ouò  ne÷  routine¬ thå conditionaì haó tï bå switcheä froí á zerï checë  tï  á 
nonzerï check.

Patchinç TW.COM

Sincå wå arå alreadù oî thå subjecô oæ patching¬ thió seemó likå á gooä  placå 
foò á follo÷-uğ discussioî oæ mù patcè iî issuå #4µ tï makå TW.COM¬ thå masteò 
prograí oæ Thå Worä Pluó spelì checkinç program¬ noô stoğ anä asë thå useò  iæ 
thå  currenô  configuratioî ió acceptable® Wheî wå arå runninç froí  aî  aliaó 
script¬ wå jusô wanô tï geô oî witè thå job.

Severaì  peoplå trieä implementinç mù patcè scripô anä complaineä thaô iô  diä 
noô worë properly® Thió waó strange¬ becauså É havå beeî usinç iô  constantly® 
Haì  Vogeì finallù figureä ouô whaô waó goinç wrong® Iô seemó thaô  therå  arå 
twï  versionó  oæ T× iî currenô distribution® Mine¬ whicè camå  witè  WordStaò 
Releaså  4¬  ió versioî 1.21® Otheò peoplå havå á lateò  version¬  1.22®  Botè 
displaù  á 198± copyright¬ anä iô seemó odä thaô thå ne÷ versioî  oæ  WordStaò 
woulä  comå witè aî oldeò versioî oæ TW® Iô makeó må wondeò whicè  versioî  ió 
better.

Iî  anù  case¬ versioî 1.2² haó threå byteó morå codå beforå mù  seconä  patcè 
point¬ anä sï botè thå addresó oæ thå pokå anä thå addresó pokeä iî havå tï bå 
incrementeä bù three® Herå ió thå originaì TWPAÔ aliaó foò versioî 1.21:

     geô 10° tw:tw.com
     pokå 10³ c³ 3â 01
     pokå 39µ c³ 2á 04
     gï $*

Foò versioî 1.22¬ onlù thå seconä pokå haó tï bå changed:Š
        pokå 39¸ c³ 2ä 04.

Iî  mù originaì discussion¬ É diä noô describå ho÷ É figureä ouô ho÷ tï  patcè 
arounä  thå  prompt® Haì Vogeì askeä abouô mù method¬ sï É wilì saù  á  littlå 
abouô iô here® It'ó thå leasô É caî dï tï thanë hií foò solvinç thå mystery.

É kne÷ thaô thå offendinç prompô begaî witè "Theså arå thå currenô  settings.¢ 
So¬  É  searcheä  witè á debuggeò foò thaô text¬ anä É founä  iô  startinç  aô 
addresó 07FFH® Sincå iô waó parô oæ á collectioî oæ sucè messages¬ alì  endinç 
witè  á  dollaò  sign¬  É  kne÷ thaô theù werå  noô  parô  oæ  iî-linå  calls® 
Therefore¬  wherå  thå  messagå  waó actuallù  displayeä  therå  woulä  almosô 
certainlù bå aî instructioî loadinç thå addresó oæ thå messagå intï onå oæ thå 
doublå registers.

É  useä thå DSÄ debugger'ó searcè functioî tï locatå occurrenceó oæ  thå  bytå 
paiò FF,07® Thå firsô onå waó parô oæ thå codå sequence

     041ã    lä   de,07ff
     041æ    calì 17bd
     042²    calì 17cb
     042µ    cğ   § '
     042·    jğ   z,02a4
     042a

Iô  waó prettù cleaò thaô 17bä waó thå routinå foò displayinç á  strinç  whoså 
addresó waó iî registeò paiò DÅ anä thaô 17câ waó thå routinå tï geô aî  inpuô 
characteò froí thå user® T× takeó á spacå characteò tï indicatå thaô thå  useò 
wantó  tï makå á change¬ whicè musô bå handleä bù thå codå aô 02a4® Anù  otheò 
characteò  woulä  accepô  thå  defaulô setuğ anä  continuå  aô  addresó  042a® 
Therefore¬ changinç thå codå aô 042³ to

     042³    jğ   042a

woulä bù-pasó thå user'ó responså anä gï righô intï thå spelì checking.

However¬ thaô changå woulä stilì senä thå displaù oæ thå prompô tï thå screen® 
Backinç  uğ anä puttinç mù replacemenô jumğ instructioî aô addresó 041ä  woulä 
suppresó eveî thå displaù oæ thå prompt.

Aó  É  lookeä aô stilì earlieò code¬ É founä instructionó thaô  displayeä  thå 
currenô  settings®  Sincå  wå reallù diä noô neeä tï havå  theí  senô  tï  thå 
screen¬  É continueä tï worë bacë untiì É camå tï thå beginninç oæ thaô  blocë 
oæ codå aô addresó 0395¬ wherå thå messagå "Summary¬ Checkinç file...¢ waó puô 
up® Bù placinç mù jumğ instructioî there¬ alì oæ thió extraneouó codå waó  bù-
passed.

Yoõ  mighô  bå  wonderinç  ho÷ É founä thå placå wherå  thå  otheò  patcè  waó 
required®  Witè thå maiî patcè installed¬ T× terminateä witè aî erroò  messagå 
abouô  á corrupteä file® Guessinç thaô á checë oæ thaô typå woulä bå neaò  thå 
beginninç oæ thå code¬ É jusô executeä TW.COÍ undeò thå debugger® Thå  probleí 
waó cleaò verù quickly.Š
Somå Samplå ZEØ Scripts

Aó  É mentioneä earlier¬ Bridgeò Mitchell¬ authoò oæ ZEØ versioî 5.0¬  covereä 
thå  specificationó foò thå prograí iî hió columî iî issuå #3¸ oæ TCJ®  Havinç 
jusô  rereaä thaô column¬ É havå tï agreå witè thå commentó É receiveä thaô  á 
fe÷ exampleó arå needeä tï appreciatå whaô ZEØ caî do® É wilì assumå thaô  thå 
readeò  ió  alreadù familiaò witè thå basiã operatioî oæ ZEØ anä  presenô  thå 
onlù twï ZEØ scriptó thaô É uså regularly.

Onå  oæ  thå  advantageó  É goô froí writinç  abouô  theså  scriptó  ió  that¬ 
naturally¬  iî  thå courså oæ analyzinç theí É thoughô oæ ne÷  approacheó  anä 
havå  significantlù  rewritteî them® Theù dï seeí tï work¬ buô yoõ  shoulä  bå 
warneä thaô mistakeó maù havå crepô in.

Iæ alì onå wantó tï dï ió ruî á sequencå oæ commanä lines¬ É don'ô thinë  thaô 
ZEØ  ió thå righô approacè (thougè therå maù bå somå exceptionó thaô  É  can'ô 
thinë oæ now)® Oî thå otheò hand¬ ZEØ ió appropriatå­-iî fact¬ necessarù­-wheî 
onå  wantó noô onlù tï invokå á prograí buô alsï tï providå interactivå  inpuô 
tï  thå program® ZEØ ió alsï usefuì foò creatinç fancù screeî displays¬  sincå 
iô  haó thå abilitù tï generatå direcô outpuô tï thå consolå anä  tï  suppresó 
outpuô generateä bù runninç programs® Mù twï samplå scriptó falì primarilù  iî 
thå formeò class.

Mù  firsô script¬ MAP.ZEX¬ ió showî iî Listinç 2® Aó yoõ see¬ iô ió  extremelù 
simple®  Iô  ió  useä  tï invokå thå MAĞ utilitù thaô ió  parô  oæ  thå  XBIOÓ 
extendeä  BIOÓ foò thå SB18° computer® Thió utilitù caî temporarilù  seô  eacè 
floppù drivå tï emulatå onå oæ á numbeò oæ foreigî formats.

É  wanteä tï havå simplå aliaó commands¬ sucè aó "KP4¢ oò "MD3"¬ thaô seô  thå 
appropriatå floppù tï thå Kayprï DSDÄ oò Morro÷ MD³ format® Unfortunately¬ MAĞ 
ió  á  purelù  interactivå program» choiceó cannoô bå passeä tï  iô  froí  thå 
commanä line¬ anä sï ARUNÚ ió powerless® Thió ió wherå ZEØ comeó in.

Thå  firsô  sectioî oæ MAP.ZEØ ió aî extendeä comment® Wheî  á  '{§  characteò 
appearó iî thå firsô columî oæ á line¬ alì texô uğ tï thå firsô closinç  bracå 
characteò '}§ ió treateä aó á commenô anä ignoreä bù ZEX® É stronglù recommenä 
usinç commentó extensively¬ aó witè anù otheò programminç language.

Thå firsô noî-blank¬ noî-commenô linå invokeó thå MAĞ program¬ whicè É keeğ iî 
directorù  B0:® Thå nexô linå ió thå onå thaô doeó thå speciaì joâ  thaô  onlù 
ZEØ  caî  do® Lineó thaô begiî witè á '<§ characteò iî thå  firsô  columî  arå 
interpreteä aó prograí inpuô bù ZEX¬ whicè proceedó tï emulatå youò typinç  aô 
thå  keyboard®  Iî thió case¬ thå firsô characteò emulateä ió 'G'®  Thå  firsô 
inpuô thaô MAĞ expectó ió thå letteò oæ thå drivå tï configure® Sincå alì  thå 
foreigî formató É uså arå foò 4¸-tpé drives¬ É alwayó uså mù Ç drive.

Next¬  MAĞ  wantó onå tï selecô á formaô bù number® Thió wå pasó  tï  thå  ZEØ 
scripô  aó  á parameteò oî thå ZEØ commanä line¬ anä wå represenô  iô  iî  thå 
scripô witè thå symboì "$1"® MAĞ theî wantó á carriagå return® ZEØ ió supposeä 
tï ignorå carriagå returnó iî thå script¬ anä sï wå shoulä includå thå speciaì 
directivå  "|CR|"® However¬ foò reasonó unknowî tï me¬  triaì-anä-erroò  showó Šthaô  thió  ió  noô necessarù here» á carriagå returî  ió  senô  automaticallù 
whetheò wå wanô onå oò not.

MAP.ZEØ ió aî incrediblù simplå script¬ buô iô provideó á loô oæ power® É  caî 
no÷ definå thå followinç ARUNÚ aliases:

  CLEAR=CLÒ     zeø b0:mağ 1;msg
  KP4=KP1°      /xxmağ ¸ KP4
  MD³           /xxmağ ¹ MD3
  TV,80³        /xxmağ 2¸ TV803
  XXMAĞ         zeø b0:mağ $1;msç **ª Drivå Ç ½ $² ***
  MSÇ           echï ^[f$*

Theså  scriptó  implemenô thå nicetù oæ puttinç á messagå iî thå  uppeò  righô 
speciaì messagå areá oî mù Wyså 5° terminaì tï reminä må oæ thå foreigî formaô 
setting®  Iô ió noô reasonablå tï trù tï remembeò thå speciaì escapå  sequencå 
foò programminç thió messagå area¬ sï É providå thå aliaó MSÇ tï dï this.

Á  seconä  subroutinå  alias¬  XXMAP¬ saveó spacå iî  thå  ALIAS.CMÄ  filå  bù 
handlinç  commandó  commoî  tï  á  numbeò  oæ  otheò  aliases®  Iô  takeó  twï 
parameters®  Thå firsô ió thå formaô numbeò foò MAP¬ anä iô ió passeä  tï  thå 
MAĞ ZEØ script® Thå seconä ió thå namå oæ thå format¬ anä iô ió passeä tï  thå 
MSÇ alias® Thå otheò aliases¬ sucè aó MD3¬ seô uğ thå desireä disë format® Thå 
aliaó CLÒ oò CLEAÒ restoreó drivå Ç tï itó defaulô SB18° formaô (MAĞ selectioî 
1).

Thå seconä examplå scripô ió calleä FORMAT.ZEØ ió showî iî Listinç 3® Iô workó 
witè anotheò XBIOÓ utilitù program¬ FVCÄ (Formaô Verifù Copù Duplicate)®  Thió 
prograí  caî formaô disketteó noô onlù iî thå standarä SB18° formató buô  alsï 
iî  severaì foreigî formats® FVCD¬ likå MAP¬ ió á purelù interactivå  program¬ 
buô É wanô tï bå ablå tï format¬ say¬ á Kayprï ² disë bù enterinç jusô "FORMAÔ 
KP2"® Again¬ ZEØ saveó thå day.

Thió  scripô  ió  mucè morå complicated® Sincå É wanô alì thå  formató  tï  bå 
handleä  bù  á  commoî  aliaó calleä FORMAT¬ thå  particulaò  formaô  wilì  bå 
designateä bù á commanä-linå argumenô anä noô bù thå namå oæ thå command® Thió 
requireó  testinç  oæ thå argument¬ á joâ thaô caî bå performeä  nicelù  bù  á 
sequencå  oæ  flo÷-controì commands® Thaô mucè coulä bå handleä bù  á  commanä 
alias¬  buô sincå wå wilì bå providinç interactivå inpuô anyway¬ wå  mighô  aó 
welì havå ZEØ takå carå oæ everything.

Aó witè MAP.ZEX¬ wå begiî thå scripô witè á commenô block® Notå thaô á  doublå 
semicoloî  caî bå useä tï enteò individuaì commentó oî á line® Thå  firsô  twï 
executablå lineó tesô thå firsô argument¬ "$1"¬ tï seå iæ iô ió eitheò "F¢  oò 
"F:"® Thå coloî prefiø beforå thå parameteò ió includeä tï forcå thå  argumenô 
tï  bå  treateä aó á strinç anä noô aó á directorù specificatioî  eveî  iæ  iô 
containó  á  colon® Foò reasonó É cannoô entirelù remember¬ thå  flo÷  controì 
strinç­  equatå testinç commanä doeó noô worë properlù iæ iô beginó witè  jusô 
":"® Foò thaô reason¬ É puô thå definitå strinç firsô anä thå strinç witè  thå 
parameteò second.

No÷ wå comå tï á verù importanô ZEØ directiveº |iæ true|® Thió directivå telló ŠZEØ  tï  ignorå alì characteró uğ tï thå closinç |endifü iæ thå  currenô  flo÷ 
statå  ió false® Yoõ mighô wondeò whù onå woulä neeä this¬ sincå  thå  commanä 
processoò woulä ignorå commandó anyway® Thå answeò ió thaô thå scripô containó 
materiaì otheò thaî commands® Iô containó interactivå inpuô anä direcô consolå 
output® Thå |iæ trueü anä |endifü directiveó makå surå thaô theså arå  ignoreä 
aó well.

Afteò ZEØ processeó á command¬ sucè aó thå linå "b0:fvcd"¬ anä sendó iô tï thå 
commanä  processor¬  iô  lookó  aô thå nexô line® Iæ  iô  beginó  witè  á  '<§ 
characteò iî thå firsô column¬ theî alì thå characteró oî thaô linå uğ tï  buô 
noô  includinç thå endinç carriagå returî arå loadeä intï á  keystrokå  buffeò 
anä  fed¬ aó requested¬ aó interactivå inpuô tï thå runninç program®  Iî  thió 
example¬ wå senä "OSXTFF2"¬ jusô aó iæ wå presseä thoså seveî keyó manually.

Wå alsï senä á carriagå return¬ specifieä bù thå |crü directive® Aó noteä witè 
thå  MAP.ZEØ script¬ ZEØ automaticallù sendó onå carriagå return¬ buô wå  neeä 
twï  foò thió operation® Wå won'ô botheò tï explaiî whaô alì thoså  characteró 
dï iî FVCD® Tï figurå ouô whaô tï include¬ onå jusô runó thå prograí  manuallù 
anä makeó notå oæ everù keù pressed.

Thió simulateä inpuô startó thå firsô diskettå formatting® Wheî thaô operatioî 
ió  complete¬  FVCÄ wantó morå useò input® Sincå thå nexô ZEØ  linå  doeó  noô 
begiî witè á '<'¬ ZEØ nï longeò supplieó thå inpuô anä returnó controì tï  thå 
user® Morå disketteó caî bå formatteä manually.

Wheî  onå eventuallù exitó froí FVCD¬ thå ZEØ scripô continueó witè  thå  linå 
"|say|"®  Thió  turnó  oî direcô consolå output®  Text¬  thió  timå  includinç 
carriagå returns¬ linå feeds¬ anä almosô alì otheò characteró iî thå file¬  ió 
senô  directlù  tï thå screen¬ untiì thå terminatinç |enä  sayü  directivå  ió 
encountered®  Thå directivå |"|¬ seeî lateò iî thå script¬ ió á  morå  compacô 
alternativå  tï  |sayü  anä |enä say|® Iô automaticallù  toggleó  thå  consolå 
outpuô state.

Wå coulä havå useä thå ECHÏ commanä tï displaù thió message¬ buô ZEX'ó  direcô 
screeî outpuô ió easieò anä morå convenient¬ aó iô ió caså sensitive® Yoõ jusô 
writå thingó aó yoõ wanô theí tï looë oî thå screen.

Oncå  wå  arå finisheä witè thå formatting¬ wå caî terminatå  thå  ZEØ  scripô 
immediately® Thió ió donå witè thå |abortü directive® Iô automaticallù returnó 
thå flo÷ statå tï itó originaì condition¬ sï wå dï noô havå tï worrù abouô thå 
facô thå wå havå noô executeä thå "FI¢ commanä thaô balanceó thå "IF¢  commanä 
earlier.

Thå  resô oæ thå scripô jusô proceedó tï tesô foò otheò argumentó anä tï  pasó 
thå  appropriatå  inpuô  tï  FVCD® Thå onlù onå oæ  theså  otheò  caseó  wortè 
commentinç  oî ió thå manuaì formattinç caså neaò thå enä oæ thå script®  Herå 
wå  simulatå inpuô onlù tï puô FVCÄ iî formaô modå witè automatiã  DateStampeò 
initializatioî enableä buô noô tï selecô anù formaô oò tï starô thå operation® 
Wå  musô suppresó thå automatiã carriagå returî thaô ZEØ generateó  (otherwiså 
formattinç  wilì  starô  immediatelù  iî somå  defaulô  format)®  Thå  |untilü 
directivå stopó simulateä inpuô untiì á carriagå returî ió entered.
ŠMù ZMATÅ Autoexeã Macro

Thå twï ZEØ scriptó werå needeä primarilù becauså thå twï programó MAP.COÍ anä 
FVCD.COÍ  diä  noô providå á facilitù foò designatinç optionó oî  thå  commanä 
line®  Amprï alwayó madå á particulaò poinô oæ providinç sucè á facilitù  witè 
itó utilitù programs¬ anä É wisè alì authoró woulä dï that® Iô ió nicå tï havå 
interactivå programs¬ buô iô shoulä bå possiblå tï ruî theí "batcè mode¢ too.

Witè  á worä processoò oò editoò onå expectó thå commanä linå taiì tï  includå 
thå  nameó oæ anù fileó tï worë with® Indeed¬ thió ió ZMATE'ó defaulô  action® 
However¬  therå  arå manù situationó iî whicè onå woulä likå tï dï  more®  Foò 
example¬ onå mighô wanô tï starô ZMATÅ witè á macrï alreadù loadeä intï onå oæ 
thå  auxiliarù  buffers®  Onå  mighô  eveî wanô  thaô  macrï  tï  bå  executeä 
immediately®  Thaô macrï mighô eveî carrù thingó tï thå poinô oæ  closinç  thå 
filå anä exitinç froí ZMATE¡ Iî thaô waù onå coulä uså ZMATÅ tï creatå  custoí 
texô processors.

Ho÷  ió thió done¿ Iî aî earlieò columî É describeä thå permanenô  macrï  areá 
(PMA© iî thå ZMATÅ texô editor® Thió buffeò areá iî thå codå containó á seô oæ 
macroó  thaô becomå á permanenô parô oæ ZMATÅ anä arå availablå aô alì  times® 
Thå firsô macrï iî thå PMÁ caî bå designateä aó aî autoexeã macrï bù placinç á 
controì-Ó iî fronô oæ iô insteaä oæ thå usuaì controì-X® Aó sooî aó ZMATÅ  haó 
loadeä anä initializeä itselæ­-anä beforå iô openó anù fileó­-iô executeó thió 
autoexeã macro.

Herå  ió  á  verù simplå examplå oæ á texô filteò  createä  usinç  thió  ZMATÅ 
facility® Supposå wå havå á macrï thaô openó á file¬ goeó througè iô  changinç 
eacè  oæ  itó characteró tï uppeò case¬ saveó thå file¬ anä exits® Iæ  wå  puô 
thió  macrï intï thå PMÁ aó thå autoexeã macrï anä theî clonå ZMATÅ  witè  thå 
commanä "XDupcase$"¬ wå wilì havå á filå calleä UPCASE.COM® Theî wå caî  enteò 
á commanä like

     upcaså infilå outfile

tï perforí thå caså conversioî oî á file® Thió ió jusô á triviaì example® Witè 
thå  fulì facilitieó oæ ZMATÅ macros¬ onå caî easilù writå somå verù  powerfuì 
filters.

Whaô É wanô tï describå no÷ ió thå autoexeã macrï thaô É havå installeä iî  mù 
standarä  versioî  oæ  ZMATÅ (nameä EDIT.COM)® Wå mighô calì  iô  aî  indirecô 
macro¬  sincå iô allowó onå tï specifù á macrï foò automatiã executioî oî  thå 
commanä line® Somå samplå commandó wilì illustratå ho÷ thió works.

     ediô source.z8° ¤ b9å xicomment.mat¤ bte

Thå  parô  oæ  thå  commanä uğ tï á firsô dollaò sigî ió  takeî  aó  thå  filå 
specification®  Iî  thió case¬ thå assembleò sourcå filå  SOURCE.Z8°  wilì  bå 
opened®  Iî  addition¬ thå macrï followinç thå dollaò sigî wilì  bå  executed® 
Thió  macrï goeó tï ediô buffeò 9¬ readó iî thå filå COMMENT.MAÔ containinç  á 
macrï  foò reformattinç assemblù codå comments¬ anä theî returnó tï  thå  maiî 
editinç buffer® Thå followinç ARUNÚ aliaó caî automatå thió (remembeò thaô onå 
needó doublå dollaò signó tï represenô á singlå '$§ characteò iî thå  expandeä Šscript):

     ZED,IÔ  ediô $1.z8° $¤ b9å xicomment.mat$¤ bte

No÷ wheî É wanô tï worë oî á Z8° assembleò prograí filå calleä PROG.Z80¬ É caî 
enteò thå simplå command

     zeä prog

Herå  ió  á samplå commanä linå foò editinç mù ALIAS.CMÄ filå  witè  automatiã 
searchinç foò thå aliaó definitioî wå jusô showed.

     aleä zed

Thå definitioî foò ALEÄ is

     ALEÄ iæ nõ $1;ediô ram:alias.cmd;else;
          ediô ram:alias.cmä $¤ å s^m$1$$;fi

Iæ  nï  searcè  strinç ió given¬ thå aliaó jusô editó thå file®  Iæ  á  strinç 
argumenô  ió given¬ theî ZMATÅ ió passeä á macrï tï searcè foò thå  strinç  aô 
thå  beginninç  oæ á line® Thå careô followeä bù aî 'm§ ió  interpreteä  aó  á 
controì-Í oò carriagå return.

Á fullù commenteä versioî oæ thå autoexeã aliaó ió giveî iî Listinç 4® Sincå É 
tenä tï uså bufferó froí botè ends¬ keepinç texô iî thå lo÷-numbeò bufferó anä 
macroó  iî  thå higè-numbereä buffers¬ foò thå autoexeã macrï É uså  á  middlå 
buffer¬  numbeò  5®  Thå  macrï switcheó tï iô anä  theî  insertó  thå  strinç 
argumenô passeä oî thå ZMATÅ commanä line® ZMATÅ haó thå speciaì strinç symboì 
controì-Á-coloî foò this® [Iî thå listing¬ controì characteró arå indicateä bù 
leadinç carets¬ anä escapå characteró arå showî aó dollaò signs® However¬ somå 
oæ  thå  characteró reallù arå dollaò signs¬ anä yoõ wilì  havå  tï  determinå 
whicè arå whicè bù thå context.]

Thå  nexô  blocë oæ codå iî thå macrï removeó anù leadinç space® Iæ  therå  ió 
theî  nothinç  left¬  thå maiî texô buffeò ió reselected¬  anä  thå  macrï  ió 
aborted.

Thå  nexô tasë ió tï spliô anù argumentó passeä intï thoså thaô specifù  fileó 
anä  thoså  thaô  compriså á macrï tï execute® Thå  codå  beginó  bù  checkinç 
whetheò  thå firsô characteò ió á dollaò sigî anä savinç thió  informatioî  oî 
thå stack® Iæ thå firsô characteò ió '$'¬ theî nï ediô filå waó specified¬ anä 
thå  resô  oæ thå linå ió á macro® Otherwise¬ wå trù searchinç  foò  á  dollaò 
sign®  Iæ  onå ió found¬ everythinç beforå iô­-whicè specifieó  thå  fileó  tï 
opeî­-ió  moveä  tï buffeò 0® Iæ nonå ió found¬ wå wilì bå aô thå enä  oæ  thå 
buffer¬ anä thå entirå texô wilì bå treateä aó thå filå specification.

Thå  nexô  blocë  oæ codå performó somå speciaì interpretatioî  oî  anù  macrï 
commanä thaô remains® Sincå thå CP/Í commanä linå imposeó somå limitationó  oî 
thå characteró thaô caî bå passed¬ wå providå meanó foò indicatinç thoså  thaô 
cannoô  bå puô intï thå commanä line® Wheî á doublå quotå characteò ió  found¬ 
iô   ió  deleted¬  anä  thå  nexô  characteò  ió  alloweä  tï   pasó   withouô Šinterpretation®  Otherwise¬ thå followinç speciaì conversionó takå placeº  (1© 
alì  alphabetiã  characteró arå converteä froí uppeò caså tï loweò  case»  (2© 
dollaò  signó arå converteä tï escapå characters» (3© á careô ió  deleteä  anä 
thå characteò afteò iô ió converteä intï thå correspondinç controì character.

Oncå  thå macrï iî buffeò µ haó beeî fullù interpreted¬ wå switcè bacë tï  thå 
maiî  editinç buffer® Iæ thå Booleaî valuå oî thå stacë ió true¬ theî wå  opeî 
thå fileó (usinç thå "XF¢ macro© specifieä bù thå strinç iî buffeò 0® É  don'ô 
thinë  wå  talkeä abouô thió beforå­-aô leasô noô iî detaiì­-buô  thió  ió  aî 
examplå  oæ thå waù ZMATÅ caî uså thå contentó oæ bufferó aó strinç  argumentó 
foò otheò macrï commands® Thió greatlù enhanceó ZMATE'ó power.

Thå  macrï completeó itó worë witè threå morå steps® Buffeò ° ió cleareä  out® 
Theî  thå  macrï iî buffeò µ ió executed® Finally¬ buffeò µ  ió  cleareä  out® 
That'ó alì foò thå macro¬ anä that'ó alì foò thió column¡ Seå yoõ agaiî iî thå 
nexô issue® 

LISTINÇ 1
» Programº              MEXPAT.Z80
» Authorº               Jaù Sage
» Createdº              Junå 10¬ 1990
» Lasô Modifiedº        Octobeò 8¬ 1990

» Thió filå containó á collectioî oæ patcheó madå tï Meø-
» Plus¬ versioî 1.65.

» Thå followinç patcheó arå included:
;
»    1® Changå thå functioî oæ thå backspacå-tï-rubout
»       conversioî functioî tï dï thå reverså ­­ make
»       pressinç thå rubout/deletå keù generatå á backspace
»       character®  Thió patcè coulä bå useä tï perforí the
»       conversioî oæ anù singlå characteò intï anù other
»       singlå character®  Thió functioî ió invokeä bù the
»       STAÔ RUÂ [ON|OFFİ command.
;
»    2® Augmenô thå STAÔ BUFFEÒ commanä sï thaô thå amount
»       oæ freå spacå iî thå capturå buffeò ió returneä in
»       thå VALUÅ variable®  MEØ scriptó caî theî checë on
»       thå remaininç spacå anä decidå tï flusè thå buffer
»       manuallù aô convenienô timeó anä tï avoiä overflow
»       problemó thaô caî occuò wheî relyinç oî XON/XOFF
»       control.
;
»    3® Augmenô thå BELÌ commanä sï thaô pressinç anù key
»       wilì terminatå it®  Thå standarä MEØ BELÌ command
»       caî bå cancelleä onlù bù controì-C¬ buô this
»       terminateó thå entirå script®  No÷ thå belì can
»       sounä untiì thå operatoò presseó á noî-aborô key¬ at
»       whicè poinô thå scripô wilì proceed.

» Addresseó iî standarä codeŠ
ilprinô     eqõ 0724fè          » Iî-linå print
hlsubde2    equ 0417ah          ; Subtraction of DE from HL
capstats    equ 06eafh          ; CAPSTATS function
scrollconin equ 049d3h          ; Console input
getconstat  equ 049c5h          ; Console status
bell2       equ 046c2h          ; BELL2 entry point

val     equ     00d64h          ; VALUE variable

logo    equ     02662h          ; LOGO entry point
endlogo equ     027b9h          ; First byte past LOGO code

saycap  equ     06ea6h          ; Point to patch in
                                ; ...SAYCAPSTATS
bellins equ     046aeh + 10     ; Point to patch in BELL

oldkey  equ     5351h           ; Place where key typed by
                                ; ...user is detected
newkey  equ     535dh           ; Place where new character
                                ; ...is substituted
idstr   equ     62a6h           ; Place where STAT command
                                ; ...message is defined

bs      equ       8             ; Backspace character
lf      equ      10             ; Linefeed
cr      equ      13             ; Carriage return
rubout  equ     127             ; Rubout character

; ---------------------------------------------------------

; Standard MEX-Plus has a very elaborate signon screen that
; affords a perfect place to put the code we need for our
; patches.  The first thing we do is to replace the LOGO
; routine with a minimal message.

        org     logo

        call    ilprint
        db      cr,lf
        db      'MEX v 1.65Z, 06/10/90'
        db      cr,lf,lf,0
        ret

; Make the STAT BUFFER command put the amount of free
; capture buffer space into the VALUE variable.  We do this
; by patching some extra code into the SAYCAPSTATS routine.

cappat:
        call    capstats        ; Get status info on capture
                                ; ...buffer
        push    hlŠ        ld      h,b             ; Free space (BC) into HL
        ld      l,c
        ld      (val),hl        ; Put it into VALUE
        pop     hl
        jp      capcont

; This is a new routine that checks to see if ANY key has
; been pressed, not just control-c.  It will be used in the
; patched BELL routine.

chkchar:
        call    getconstat      ; See if key pressed
        ret     z               ; Return now if not
flush:
        call    scrollconin     ; Read in the character
        or      a               ; Set flag to nonzero
        ret

; ---------------------------------------------------------

; Code for cutting into the original code in CAPSTATS

        org     saycap
        jp      cappat
capcont:

; ---------------------------------------------------------

; Code for patching the original code in BELL

        org     bellins
        call    chkchar         ; See if key pressed
        jp      nz,bell2        ; If so, cancel BELL command

; ---------------------------------------------------------

; Patch to backspace-to-rubout conversion function

        org     oldkey

db      rubout

        org     newkey

db      bs

        org     idstr

;       'bs-to-rub conversn'    ; String in standard MEX
db      'rub-to-bs conversn'    ; You must fill same space

        endŠ

LISTINÇ 2
{
MAP.ZEX

This ZEX5 script runs the XBIOS MAP utility that sets
a drive to a designated virtual disk format.  Since
MAP itself does not allow command-line parameters, ZEX
is used to pass a parameter.  We use foreign formats
only on the 48-tpi drive G: and hence always supply the
input "G".  The argument to the script is the number of
the desired format.
}

b0:map
<G$1

LISTINÇ 3
{
FORMAT.ZEX

This ZEX5 script invokes the XBIOS format program FVCD
and feeds it input to perform the desired diskette
formatting operation.  The following arguments are
recognized:

   <none>       manual operation of FVCD
   F or F:      SB180 DSQD format in drive F
   G or G:      SB180 DSDD format in drive G
   KP2 or KP2:  Kaypro SSDD format in drive G
}

;; SB180 DSQD Formatting

if eq :f: :$1           ;; Test for "F:"
or eq :f :$1            ;; Test for "F"
|if true|
b0:fvcd
<OSXTFF2|cr|
|say|
Formatting in SB180 DSQD format complete.
|end say|
|abort|
|endif|
fi

;; SB180 DSDD Formatting

if eq :g: :$1           ;; Test for "G:"
or eq :g :$1            ;; Test for "G"
|if true|Šb0:fvcd
<OSXTGF
|"|
Formatting in SB180 DSDD format complete.
|"|
|abort|
|endif|
fi

;; Kaypro SSDD Formatting

if eq :kp2: :$1         ;; Test for "KP2:"
or eq :kp2 :$1          ;; Test for "KP2"
|if true|
b0:fvcd
<OSXTGF6|cr|
|"|
Formatting in Kaypro 2 (SSDD) format complete.
|"|
|abort|
|endif|
fi

;; Manual Formatting

if eq :$1 :             ;; Test for no argument
|if true|
b0:fvcd
<OSXTGF|until|
|"|
Formatting in interactive mode complete.
|"|
|abort|
|endif|
fi

;; We get here if an illegal argument was given

|"|

--> Illegal format specification given: $1 $2 $3

|"|


LISTINÇ 4
;Autoexec Macro

; This macro allows ZMATE to be invoked with a macro on the
; command line.  The syntax is as follows:
;
;               ZMATE [infile [outfile]][$<macro>]Š;
; The macro line is processed using a special syntax.  All
; letters are normally converted to lower case; characters
; following a '^' are converted to the corresponding control
; character and dollar signs are converted to escape
; characters.  However, a character following a '"' is taken
; literally so that upper case characters, dollar signs, and
; carets can be entered.

B5E                     ; go to buffer 5
I^A:                    ; read in command tail

A                       ; go to beginning
T                       ; tag it
[@T>" _M]               ; move to first non-space, non-
                        ; ...control character
#D                      ; delete the white space
@T=0{                   ; IF nothing left
  BTE                   ;   go to T buffer
  %                     ;   terminate this macro
}                       ; ENDIF

@T="${                  ; IF line starts with dollar sign
  D                     ;   delete it
  0,                    ;   push 0 (false ) onto stack
}{                      ; ELSE
  -1,                   ;   push -1 (true) onto the stack
  E                     ;   suppress error trapping
  S$$                   ;   search for a '$' separator
  @E{                   ;   IF none found
    Z                   ;     go to end of buffer
  }{                    ;   ELSE
    -D                  ;     delete the '$' separator
  }                     ;   ENDIF
  #B0M                  ;   move file name specs to buffer 0
}                       ; ENDIF

[                       ; REPEAT
  @T<"A!(@T>"Z)'{       ;   IF upper case letter
    @T!96R              ;     replace with lower case
    ^                   ;     loop back
  }                     ;   ENDIF
  @T=""{                ;   IF character is double quote
    D                   ;     delete it
    M                   ;     move past next character
    ^                   ;     loop back
  }                     ;   ENDIF
  @T="^{                ;   IF character is caret
    D                   ;     delete it
    @T&31R              ;     convert next char to control
    ^                   ;     loop back
  }                     ;   ENDIFŠ  @T="${                ;   IF character is dollar sign
    "$R                 ;     replace it by escape char
    ^                   ;     loop back
  }                     ;   ENDIF
  M                     ;   (otherwise) move past the char
@T=0]                   ; UNTIL end of text

BTE                     ; go to T buffer
@S{                     ; IF stack was true
  XF^A@0$               ;   open the file spec in buffer 0
}                       ; ENDIF

B0K                     ; clear buffer 0
.5                      ; execute macro in buffer 5
B5K                     ; clear buffer 5

ENÄ OÆ LISTINGS

[This article was originally published in issue 48 of The Computer Journal,
P.O. Box 12, South Plainfield, NJ 07080-0012 and is reproduced with the
permission of the author and the publisheò® Furtheò reproductioî foò non-
commerciaì purposeó ió authorizeä® Thió copyrighô noticå musô bå retained.
(c© Copyrighô 1990¬ 199± Socrateó Presó anä respectivå authors]
