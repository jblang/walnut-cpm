                  RBBS vers. 3.8A Documentation
                          July 30, 1985
                         by Dennis Recla

INTRODUCTION:

UPDATE to RBBS38A from RBBS38    Fixed TWIT problem, that allowed
them to re-enter system.

RBBÓ  (Remotå  Bulletiî  Boarä System© haó growî froí  thå  earlù 
versionó whicè werå simplå messagå systemó tï morå elaboratå oneó 
sucè  aó thió ne÷ RBBS38¬  thaô caî alsï bå useä aó  stanä  alonå 
messagå  systems¬  oò aó á waù tï controì useró accesó tï CP/Í oî 
aî  RCP/Í system®   RBBÓ ió writteî iî MBASIÃ anä compileä  tï  á 
run-filå usinç BASCOM®  Thå originaì  RBBÓ itselæ haó beeî copieä 
anä duplicateä bù á numbeò oæ ne÷ versionó writteî iî Pascal¬  C¬ 
CBASIC¬  aó  welì  aó  .ASÍ code®   Eacè oæ  theså  ne÷  versionó 
provideó foò improvementó upoî thå originaì code¬ anä á chancå tï 
work with another language besides MBASIC.  

Thió versioî ió stilì writteî iî thå originaì MBASIC¬  foò  thoså 
programmeró  whï feeì morå comfortablå iî thió  language®   Therå 
havå  beeî á fe÷ problemó encountereä witè RBBS37¬  anä thió  ne÷ 
releaså  RBBS3¸ ió nï different®   É havå fixeä alì oæ thå  knowî 
bugó  iî RBBS37¬  anä addeä severaì ne÷ featureó tï thaô codå  tï 
creatå  RBBS38®   Iî  additioî thió releaså ió smalleò  thaî  thå 
RBBS37¬  bù  slightlù morå thaî 1.5Ë bytes®   Thió wilì helğ witè 
onå oæ thå nexô twï problemó whicè yoõ mighô encounter®   Iæ youò 
systeí  haó  á  TPÁ oæ lesó thaî 52Ë theî  strangå  thingó  mighô 
happeî  aó RBBS3¸ overwriteó youò CCP®   Thió probleí  mighô  noô 
sho÷  uğ  wheî  yoõ  arå runninç iô iî thå 'local§  modå  oî  thå 
terminal¬ buô wheî yoõ loaä thå BYÅ prograí thå TPÁ ió reduceä bù 
² tï 4Ë byteó dependinç upoî youò implimentation®  Yoõ saù 'buô É 
aí runninç á 64Ë CP/Í system'®  Welì thaô maù bå true¬ anä thingó 
wilì probablù worë jusô finå foò you®   Jusô remembeò thaô  therå 
arå  á numbeò oæ programó thaô yoõ mighô bå usinç thaô dï  reducå 
thå  amounô oæ TPÁ spacå oî á system®   Theså includå manù oæ thå 
CCĞ  replacemenô programó sucè aó EZCPÒ  anä  ZCPR3®   ZCPR3¬  ió 
probablù  thå worså sincå yoõ caî reducå TPÁ bù aó mucè aó 6Ë  tï 
8Ë dependinç upoî ho÷ elaboratå yoõ havå gonå oî youò implimenta
tion®   Sï remembeò á reduceä TPA¬  caî causå runtimå problemó oî 
smalì systems®  Theså arå iî thå minoritù sï yoõ shouldn'ô havå á 
probleí witè this.

Thå  nexô  problem¬  perhapó  ió thaô thå MBASIÃ  codå  foò  thió 
prograí haó gotteî verù largå aó BASIÃ prograí runninç undeò CP/Í 
go®   É don'ô thinë thaô wheî MICROSOFÔ createä thå BASCOÍ  basiã 
compileò  packagå  thaô theù realizeä programmeró werå  goinç  tï 
creatå largå MBASIÃ programs®  Thió versioî comeó witè twï sourcå 
fileó  foò  RBBS38®   Thå  firsô ió RBBS38.ASÃ whicè ió  á  fullù 
commenteä sourcå filå saveä froí MBASIÃ usinç thå (A)SCIÉ  switcè 
iî  MBASIC®   Thió  versioî wilì NOÔ ruî oî nearlù alì systemó  É 
havå trieä tï uså iô on®   Thå reasoî beinç thaô iô ió TOÏ biç tï 
bå  storeä iî memory®   Tï takå carå oæ thió  problem¬  á  seconä 
sourcå  filå  calleä  RBBS38NC.ASÃ  waó  created®    Thió  ió  aî Šidenticaì  file¬  excepô  thaô 99¥ oæ alì thå commentó havå  beeî 
removeä froí thå code®   Iô wilì ruî undeò MBASIÃ oî mosô oæ  thå 
common CP/M systems.  
Iæ  yoõ  decidå tï 'hack§ uğ thå originaì soucå tï suiô youò  owî 
needs¬  thå  leô  må suggesô thaô yoõ alsï modifù  thå  commenteä 
sourcå  anä includå youò owî commentó sï thaô nexô timå yoõ  mesó 
witè  thå  prograí YOÕ caî rememeò whaô  yoõ  did®   BASCOÍ  wilì 
compilå  thå prograí anä creatå á largå .REÌ file®   No÷ herå  ió 
wherå yoõ finä ouô abouô thå seconä problem®   BASCOÍ ió normallù 
supplieä  witè thå L8° Linker¬  aó thió linkeò doeó mosô oæ  it'ó 
worë iî memory¬  iô ió reasonablù fast®  Thaô ió thå rub¬ yoõ arå 
no÷  agaiî limiteä bù thå amounô oæ memorù spacå yoõ havå oî youò 
system®   Iæ yoõ plaî oî makinç anù changeó tï thå RBBS3¸  sourcå 
fileó  yoõ  musô bå awarå thaô eveî thå uncommenteä versioî  wilì 
noô  linë usinç L80®   Tï linë yoõ neeä thå  LD8°  linker¬  whicè 
unfortunatelù  ió noô supplieä witè BASCOM®   Iô ió supplieä witè 
MICROSOFÔ COBOL®   Unlesó yoõ havå á linkeò sucè aó LD8° oò PLINË 
yoõ  wilì  probablù  bå unsuccessfuì iî linkinç  thå  .REÌ  file®  
Theså speciaì linkeró uså thå disë insteaä oæ memorù foò  holdinç 
some of the temporary files created during the link.  

Iî  RBBS3·  anä RBBS3¸ É havå trieä tï solvå thió probleí foò  aó 
manù oæ yoõ aó É can®  Thió prograí ió supplieä aó á runninç .COÍ 
filå thaô haó beeî alreadù compileä anä linked¬  anä wilì ruî  aó 
supplied®  Thå otheò associateä fileó havå alsï beeî compileä anä 
linkeä  tï  makå  iô easieò tï geô youò  RBBS3¸  systeí  running®  
Sincå  everyonå  wantó tï configurå theiò owî  RBBÓ  program¬  aî 
expandeä INSTALÌ prograí haó beeî includeä witè thió update®   Iô 
allowó thå SYSOĞ (systeí operator© tï makå choiceó oî ho÷  he/shå 
wantó  theiò systeí tï operate®   Iô alsï solveó thå probleí  foò 
manù  oæ yoõ whï dï noô havå thå BASCOÍ compiler¬  anä thoså  whï 
prefeò  tï  noô  geô  envolveä witè thå  programminç  aspectó  oæ 
settinç  uğ á RBBÓ system®   Iô ió onå oæ thå fe÷  'READY-TO-RUN§ 
programs available in the Public Domain.

>   DON'T FORGET:

RBBS3¸ ió noô á stanä alonå module¬  foò iô tï operatå aó aî RBBÓ 
oò  RCP/Í yoõ musô havå á workinç copù oæ BYÅ installeä  oî  youò 
computeò system®  BYÅ musô also¬ wheî iô detectó carrier¬ ruî thå 
RBBS.COÍ (RBBS38.COM© program®  

If you need a RBBS program that does more, or you just prefer to 
writå youò owî code¬  theî leô må suggesô RBBS´ whicè ió  writteî 
iî  'C§  oò MSGSYS2° writteî iî CBASIC¬  oò onå oæ thå ne÷  Turbï 
Pascal message system programs.

                   The Lost Island RCP/M-RBBS 
                         Garland, Texas
                          214-681-4789
                       300/450/1200/Vadic

           Like a Lost Island, it is not always there
                     when you look for it !!
                      8:00am to 10:30pm CSTŠ

NEW FEATURES:

Onå oæ thå besô featureó oæ RBBS3¸ oveò earlieò versionó ió  thaô 
iô ió 1.5Ë byteó smaller®   Thió meanó lesó chancå oæ runninç ouô 
of space in your system TPA.  

Therå havå beeî á numbeò oæ changeó froí RBBS37¬  whicè havå comå 
abouô  iî á slo÷ progressioî froí thå daù RBBS3· waó releaseä  tï 
thå  world®   Sï  excuså må iæ iî mù discriptioî oæ updateó  thaô 
somå oæ theså werå reallù updateó froí RBBS3µ tï RBBS37®   É wilì 
trù  tï starô aô entrù tï thå systeí anä talë brieflù  abouô  thå 
changes that were made.

1®   Yoõ cannoô enteò á first/lasô namå oò passworä thaô haó  anù 
spaceó  iî it®   Wheî á namå haä á spacå iô in¬  thå 'searcè  foò 
messages§  codå  diä noô worë correctlù anä thå calleò waó  neveò 
notifieä oæ messageó tï them®  

2®  Therå ió á waù tï directlù enteò CP/Í withouô stoppinç iî thå 
RBBS3¸ program®  Thió ió donå usinç thå 'Direcô tï CP/M§ passworä 
aô  thå  Firsô  Namå prompt®   No÷ yoõ caî  selecô  NOPASÓ  aó  á 
password¬ anä thió featurå wilì bå disabled®  

3®  Yoõ  caî alsï selecô iæ therå ió morå thaî onå SYSOĞ oî  youò 
system®   No÷ insteaä oæ thå taç SYSOĞ oî messages¬  yoõ caî havå 
SYSOĞ (name© foò thå otheò SYSOPS®

4®   Iæ  someonå trieó tï enteò aó SYSOP¬  anä misseó thå correcô 
SYSOĞ  password¬  thå systeí wilì dumğ them®   Alì yoõ seå  ió  á 
brieæ  'Yoõ  arå  noô thå SYSOP§ anä thå systeí dropó  ofæ  line®  
Thió  doeó  meaî yoõ havå bå bå carefulì yourselæ  wheî  enterinç 
youò SYSOĞ password.

5®   Therå ió á ne÷ operationaì modå calleä SECURE®  Wheî yoõ seô 
thå  SECURÅ flaç iî thå instalì program¬  onlù thoså calleró  whï 
are listed in the USERS file will be allowed on the system.

6®    Yoõ  no÷ havå thå capabilitù tï loç oò noô loç ne÷ useró iî 
thå  CALLERÓ  file®   Alonç witè thió thå SYSOĞ ió no÷  noô  eveò 
loggeä iî thå CALLERÓ file¬ oò thå numbeò oæ calló increaseä wheî 
thå SYSOĞ logó on®   Usinç thå SHOLOÃ flaç yoõ caî alsï decidå iæ 
yoõ  wanô  tï sho÷ thå calleró locatioî iî thå USERÓ anä  CALLERÓ 
filå wheî vieweä bù thå caller.

7®    Upoî entrù tï thå prograí thå calleò ió askeä tï verifù thå 
date®   Thió ió onlù askeä oæ validateä callers¬  sï thaô á  twiô 
cannoô  scre÷ thingó up®   Iæ therå ió á DATE.DAÔ filå createä tï 
bå  useä aó thå alternatå soucå oæ datå oò timå informatioî  theî 
thå calleò ió noô askeä thió question®   Iæ thå DATE.DAÔ filå  ió 
noô  founä iî eitheò case¬  thå calleò wilì bå askeä tï inpuô thå 
currenô date®   Havinç thió information¬  aô thå  beginning¬  thå 
LASTCALÒ anä CALLERÓ fileó arå alsï tageä witè thå date.  
Š
8®   RBBS3·  gavå  yoõ thå choicå oæ showinç thå calleò thå  lasô 
messagå  reaä  bù them¬  oò not®   Showinç thå lasô messagå  reaä 
workó  aó  lonç aó thå SYSOĞ didn'ô renumbeò thå  messages¬  wheî 
theù  useä thå utilitù program®   Sï bù noô showinç lasô  messagå 
read¬  iô  waó lesó confusinç iæ thå numberó changed®   Thió  ne÷ 
RBBS3¸  wilì  alerô thå calleò thaô thå messagå  baså  havå  beeî 
renumbered.

9®   Alì  ne÷  useró  tï thå systeí arå showî thå  RBBSMENÕ  filå 
wheneveò  theù firsô call¬  thió letó thå firsô timå  calleò  seå 
whaô  alì thå featureó are®   Therå ió alsï á separatå menõ  filå 
thaô  ió  calleä  uğ  foò thå SYSOĞ iæ theù  forgeô  thå  variouó 
features.

10®   Thå Commanä pompô linå haó alsï beeî modifieä tï á twï linå 
prompt®  Thå firsô linå containó thå calleró firsô anä lasô name¬ 
anä  thå  seconä  linå  containó  thå  codeó  foò  thå  availablå 
commands®   Thió  allowó  thå  SYSOĞ whï ió watchinç  thå  systeí 
being used, see who the current user is.

11®   Therå  ió á ne÷ 'D§ commanä whicè allowó thå viewinç  oæ  á 
named text file by only those callers who are validated.

12®  NEWÓ anä HELĞ fileó caî no÷ bå assigneä tï driveó otheò thaî 
the default drive.

13®    Thå   SYSOĞ   (P)assworä  functioî  no÷  allowó  foò   thå 
unvalidation of a user.

14®   Thå SYSOĞ caî no÷ decidå iæ theù wanô tï seô thå WHEEÌ bytå 
foò  SYSOĞ controì wheneveò theù enteò CP/M®   Á flaç alertó  thå 
SYSOP that the WHEEL has been set.

15®   Aô  entrù tï CP/Í witè thå Ê commanä ió thå ne÷ featurå  oæ 
beinç  ablå  tï  executå á program®   Thió giveó  thå  SYSOĞ  thå 
capablitù oæ lettinç thå calleò whï goeó tï CP/Í chaiî tï anotheò 
prograí  anä  ruî  it®   Thió ne÷ prograí coulä bå  á  numbeò  oæ 
things¬  infacô iô mighô noô eveî leô thå calleò exiô tï CP/Í buô 
chain to another RBBS program for multi-node type of operation.  

16®   Thå  messagå baså summarù no÷ showó thå privatå messageó aó 
beinç <PRIVATE¾ wheî thå calleò useó thå Ó command®   Iî additioî 
thå  codå waó changeä foò entrù oæ Privatå  messages®   Onlù  thå 
sender¬  receiveò  oò  SYSOĞ  caî Kilì  them¬  anä  thå  passworä 
function was eliminated.

Thaô  jusô  abouô  coveró alì thå oæ currenô changeó tï  thå  ne÷ 
RBBS3¸ program®   Therå arå somå otheò smalì ones¬  whicè iæ  yoõ 
arå aî experienceä useò oæ thå oldeò RBBS3· wilì probablù notice®  
Sincå   É  havå  beeî  runninç  thå  olä  versioî  anä  alì   thå 
undocumenteä  versionó betweeî 3· anä 3¸ É can'ô remembeò exactlù 
what all the minor changes are.  

É hopå thió ne÷ versioî wilì helğ somå oæ yoõ whï havå  expresseä Šthe need for some of these features. 



                     HOW IT ALL SHOULD WORK

Oncå thió prograí ió installeä iî USEÒ 1´ oî thå disk¬  iô shoulä 
bå  renameä tï RBBS.COÍ anä no÷ youò BYÅ prograí wilì linë tï it®  
Runninç RBBÓ iî USER1´ ió thå commoî waù tï operatå thió program¬ 
buô  iæ yoõ arå noô allowinç thå calleró tï enteò CP/Í anä  usinç 
iô  onlù aó á messagå systeí theî thå RBBÓ coulä bå installeä  iî 
drivå Aº USEÒ 0®  Thió provideó onå leveì lesó iî security¬ buô á 
simple way to use RBBS38.  

Therå  arå á numbeò oæ wayó tï uså RBBS3¸ dependinç upoî ho÷  yoõ 
wanô youò RCP/M-RBBÓ tï operate®  Aó yoõ probablù noticed¬  therå 
arå á couplå oæ programó calleä BYE.COÍ anä RBBS.COÍ iî thió .LBÒ 
oò  oî thió disë dependinç upoî ho÷ yoõ goô thå  program®   Theså 
arå  prograí  createä bù usinç RUNIT.ASM®   Botè arå  verù  smalì 
programó  writteî tï LINË tï thå reaì programó whicè arå  locateä 
oî  otheò disë driveó oò iî otheò USEÒ areas®   Theù maù  oò  maù 
noô  bå  needeä  dependinç  upoî ho÷ yoõ  configurå  youò  RBBS3¸ 
system®   Leô  må sho÷ á fe÷ exampleó oæ wayó yoõ  caî  configurå 
youò  RBBÓ  anä ho÷ alì thå extrá programó supplieä oî thió  disë 
relatå tï usinç RBBS® 


1. RBBS Message system only.

Thió ió thå verù basiã uså oæ RBBS38¬  yoõ dï noô allo÷ anyonå tï 
enteò  CP/Í witè thå Ê command¬  excepô perhapó á fe÷ verù  closå 
friendó   whï  yoõ  mighô  taç  aó  SUPEÒ   USERS®    Witè   thió 
configuratioî  yoõ  onlù neeä á BYÅ prograí configureä  foò  youò 
hardware®   Puô thå reaì RBBS38.COÍ prograí iî A0º  anä renamå iô 
tï  RBBS.COM®   Bå surå tï seô thå BYÅ prograí sucè thaô iô lookó 
foò thå RBBS.COÍ iî A0º  anä noô A14º   Havinç everythinç iî  A0º 
makeó iô availablå foò anyonå iî CP/Í tï typå thå useró list¬ anä 
otheò  fileó whicè shoulä bå secure®   Sï remembeò onlù thoså yoõ 
trusô  shoulä bå alloweä CP/Í entry®   Therå ió alsï nï  neeä  tï 
instalì á CCĞ replacmenô sucè aó ZCPÒ oò ZCMÄ iî youò system¬  aó 
CP/M entry is never allowed.  


2.  RBBS Message system only with added security.

Noô  mucè  differencå here¬  excepô yoõ puô thå RBBÓ programó  iî 
A14º  anä uså thå smalì RBBS.COÍ filå iî A0º  tï linë tï thå reaì 
RBBS.COÍ  locateä iî A14:®   Yoõ wilì alsï neeä tï puô  thå  reaì 
BYE.COÍ prograí iî A0º  foò youò owî use¬ anä á duplicatå copù iî 
A14º foò RBBS.COÍ tï use®  Yoõ shoulä alsï modifù youò BYÅ tï seô 
thå  MAXUSÒ  sucè thaô á calleò ió neveò alloweä tï geô  tï  USEÒ 
areá  14®   Yoõ  caî alsï uså thå CCĞ replacemenô tï dï thå  samå 
thing.

Š


3.  BASIC RBBS-RCP/M system.

Sincå thå basiã definitioî oæ RCP/Í indicateó thaô yoõ arå  goinç 
tï allo÷ á calleò tï enteò youò CP/Í operatinç systeí anä operatå 
iô  remotelù theî yoõ neeä tï protecô youò system®   Puô thå reaì 
RBBS.COÍ prograí iî A14º  alonç witè á copù oæ BYE.COM®   Puô thå 
psuedï  RBBS.COÍ  prograí  iî A0:¬  aó yoõ  nï  doubô  havå  alsï 
installeä á CCĞ replacemenô prograí tï providå thå necessarù CP/Í 
security®  Thå CCĞ replacemenô usuallù wilì defaulô tï A0º sï yoõ 
neeä thå psuedï RBBS.COÍ herå tï leô á calleò whï ió iî CP/Í linë 
tï  thå  REAÌ  RBBS.COÍ  prograí iî á useò areá  theù  woulä  noô 
normallù bå allowed®  Á duplicatå copù oæ thå REAÌ BYE.COÍ shoulä 
alsï  bå  locateä iî A0º  foò thå calleò tï bå ablå tï  exiô  thå 
systeí  correctly®   Bå surå thaô yoõ alsï modifù alì  thå  otheò 
basiã RCP/Í utilitieó sucè aó SD¬  TYPE¬  WHATSNEW¬ anä XMODEÍ tï 
not allow their use in USER area 14.

4. Expanded RBBS-RCP/M system.

Dï everythinç aó yoõ havå donå iî examplå #³ above¬  buô no÷ takå 
thå REAÌ BYE.COÍ prograí iî A14º anä renamå iô tï SUPER.COM®  Yoõ 
wilì  alsï eraså thå BYE.COÍ prograí iî A0º  anä replacå iô  witè 
thå  psuedï  BYE.COÍ supplied®   Thió smalì versioî  linkó  tï  á 
prograí  calleä EXITRBBS.COÍ whicè ió thå EXIT38.COÍ prograí  re
named®   EXITRBBS.COÍ allowó thå calleò tï leavå Feedbacë foò thå 
SYSOĞ  wheî  theù exiô thå systeí usinç  BYE®   Thå  EXITRBBS.COÍ 
prograí theî linkó tï SUPER.COÍ tï disconnecô anä reloaä thå reaì 
RBBS.COÍ program®   Remembeò yoõ neeä tï changå thå nameä hang-uğ 
prograí  iî  RBBS3¸ froí BYE.COÍ tï  SUPER.COM®   Therå  ió  alsï 
anotheò  littlå  prograí thaô ió kepô iî A0º  aó á hiddeî  systeí 
filå calleä STARTUP.COÍ oò whateveò yoõ mighô wanô tï renamå  it®  
Thió  prograí  linkó directlù tï SUPER.COÍ (thå reaì BYE.COM©  sï 
thaô  aó thå SYSOĞ yoõ caî STARTUĞ thå systeí froí A0:®   Iæ  yoõ 
typeä BYE¬  thå pusedï BYÅ woulä ruî EXITRBBS.COÍ whicè lookó  aô 
LASTCALÒ  anä  askó iæ yoõ wanô tï leavå á messagå foò thå  SYSOĞ 
beforå runninç thå reaì BYE.COÍ (no÷ nameä  SUPER.COM)®   STARTUĞ 
jusô linkó directlù tï SUPER.COÍ tï begiî systeí operation.

5. EVEN MORE ?

Yes¬  remembeò thå RUN-A-FILE-ON-EXIT-TO-CP/Í feature¿  Yoõ mighô 
alsï  writå á prograí thaô askó thå calleò á numbeò oæ  questionó 
beforå yoõ leô theí enteò CP/M®   Thió useò surveù coulä  providå 
yoõ  witè  morå  informatioî  thaî jusô  thå  Namå  anä  Locatioî 
informatioî  thaô thå RBBS3¸ prograí requests®   Iæ theù  alreadù 
gavå  yoõ thå informatioî yoõ coulä leô theí gï directlù tï  CP/Í 
oò bù lookinç aô theiò validatioî leveì decidå iæ yoõ neeä tï asë 
foò informatioî oò not®   Therå arå á numbeò oæ useó foò thió ne÷ 
feature¬  jusô  thinë abouô anä É aí surå yoõ caî figurå ouô somå 
speciaì  ne÷ featureó tï surpriså youò  callers®   Jusô  remembeò 
thaô yoõ neeä tï prevenô CTRÌ C'ó iæ yoõ don'ô wanô thå calleò tï 
be able to exit to CP/M.  Š




Inside RBBS38:

The first thing the caller sees is the Version message that tells 
the caller the name of your system,  it is followed by my own bit 
of  information  indicating that this program is  from  Lillypond 
Software (software written by FROGS and bugfree).  


WELCOME

Thió  filå ió noô reallù parô oæ RBBS38¬  buô onå thaô ió  calleä 
froí BYÅ iæ yoõ wanô iô tï be®   Therå ió aî EQÕ iî BYÅ thaô askó 
iæ yoõ wanô tï ruî á WELCOMÅ file®   Yoõ musô telì BYÅ wherå thió 
program will be located.


INFO

Next the message file called INFO is show to the caller,  this is 
a  file you have created using a text editor and named  INFO,  be 
sure to put a few CR's at the beginning and end to keep the texts 
from  packing  together as they are printed.   The INFO  file  is 
there  for  you to give the caller information about  the  system 
he/she has just called.

 
BULLETIN

Next the message file called BULLETIN is show to the caller.   It 
follows  the  INFO file that was just show to  the  caller.   The 
BULLETIN file is a way of you as the SYSOP to let the caller know 
about new features,  or to give out additional information  about 
the system.


NEWCOM

This  file NEWCOM  is only shown to the caller once,  it is a bit 
of  information  that you have created to let a first  time  user 
know what you expect of them or to give them special  information 
that a first time caller will need to use your system.


MENURBBS

Anotheò featurå  iî RBBS3¸ ió thaô á firsô timå  calleò  ió showî  
thå  MENÕ oæ commandó thaô arå supporteä bù  RBBS38®    Thió wilì  
onlù occuò thå firsô timå thå ne÷ useò  calls¬   afteò  thaô theù  
musô   uså   thå '?§ functioî tï seå   thå   MENÕ   again®    Thå 
followinç  ió á examplå oæ thå MENURBBÓ filå whicè yoõ wilì  neeä Štï  creatå  oò yoõ caî uså thå onå supplieä witè thå  RBBS38.LBR®  
Therå  ió  alsï  anotheò filleä  calleä  SYOPMENU®  thaô  ió  ruî 
whenever the SYSOP wants to see the MENU.

                      sample MENURBBS file

 
Functions supported:     by RBBS vers. 3.8  

<B> Bulletin File               <C> Chat with SYSOP
<E> Enter Message   *           <D> Download Directory  *
<F> Feedback for SYSOP          <N> News and new information
<R> Read Message                <S> Scan message base
<K> Kill Message                <U> Users file (Valid Members)
<T> Toggle BELL                 <L> List last callers   *
<I> Information File   		<P> Password Change
<J> Jump to CP/M                <X> X'pert User
<H> Help files			<G> GO  'Leave the system'

* Verified users only

Repeated Ctrl-K's abort, Ctrl-S pauses
Messages are Private unless addressed to ALL

For Sequential retrieval (not scanning), use '+' after message #.
For example, R;10+ reads message #10 and all that follow, a Ctrl K
can be used to 'SKIP' to the next message in this mode.
 


The  above  sample  of  MENURBBS  lets the  caller  see  all  the 
functions  that are supported by the RBBS38  Program.   Depending 
upon  how you set up the passwording files,  you can prevent  the 
new  caller from leaving messages or seeing some of  the  various 
files.   They  can also be limited in their access to CP/M  using 
the 'J' command.  

Mosô oæ thå variouó commandó arå selæ explanatory¬ excepô foò thå 
'D§  command®   Thió  speciaì functioî letó thå calleò whï  ió  á 
valiä  useò seå á texô filå oæ youò choice®   Iî thå caså  oî  mù 
systeí  É havå choseî tï leô thå calleò vie÷ á copù oæ SD.DIÒ  oæ 
thå  areá oî mù systeí wherå thå ne÷ uploadó arå  located®   Thió 
waù  á valiä calleò anä checë thå uploadó withouô havinç tï gï tï 
CP/M.


SYSOP  functions: 

The  SYSOP has a few extra commands that are available to  he/she 
only®   Theù  arå noô listeä oî thå normaì MENÕ oò arå theù showî 
oî thå commanä line®   Therå ió anotheò MENÕ filå calleä SYOPMENÕ 
thaô doeó sho÷ thå speciaì SYSOĞ functions®   Iæ yoõ arå  crampeä 
foò  space¬  anä  don'ô feeì thå neeä oæ á speciaì menõ  foò  thå 
SYSOĞ  theî lateò iî thió documenô looë aô thå speciaì sectioî oî 
modifyinç  RBBS3¸ usinç DDÔ foò wherå tï changå thå namå  oæ  thå ŠMENÕ  prograí sï thå samå onå ió useä foò normaì calleró anä  thå 
SYSOP.

<Z>
First  is the 'Z' command,  this lets you view the COMMENTS  file 
thaô  haó beeî lefô bù thå calleró iî <F>eedbacë oò upoî  exitinç 
thå RBBÓ program®   Yoõ caî alsï havå commentó iî thió filå  thaô 
arå createä bù thå EXITRBBÓ program.

<XL>
This  command allows you to view the XMODEM.LOG file if you  have 
created one from the XMODEM program.   This command helps to  let 
you  know  who has been uploading or downloading files from  your 
system and as a way to provide audit capabilities without  having 
to  enter CP/M.   You might use this if you run your system  from 
home and have a Modem at work to call and 'see how things are'.
 
<P>
This  PASSWORD command is available to all users in that they can 
modify  their  own password anytime they like.   When  the  SYSOP 
calls  up  the 'P' command you will get an  expanded  version  of 
password  change.   This  is  where you as the SYSOP set  up  the 
validation  of the callers.   You can set up any caller from  the 
validation command to either a <V>alidated user,  a <T>wit,  or a 
<S>uper  user.   If  you don't want to make any  changes  to  the 
validation then just hit the <CR> again until you get the command 
line prompt back.
 
<UALL>
Thió commanä allowó thå SYSOĞ tï seå alì callers¬  whï arå iî thå 
USERÓ file®   Thå normaì 'U§ commanä doeó noô sho÷ unvalidateä oò 
twits while the UALL shows all callers who are in the USERS file.


                       EXITING THE PROGRAM

<G>o Command:
The  easiest  is the 'G' command that first allows the caller  to 
leave  a message for the SYSOP then exits the RBBS  program.   It 
does  this exit by running the BYE.COM program that you have   on 
the  disk.   In  RBBS35 the exit was done by 'POKEing'  the  UART 
control  port to drop the DTR line.   This is probably  a  better 
way,  but  one  that  cannot be made universal  to  all  computer 
systems.
 
<J>ump Command:
Depending  upon the password setup you are using with CP/M  entry 
you  may or may not be asking the caller a question that requires 
a proper answer.   Once the question or password has been entered 
correctly  then  like  in the 'G' command the caller  is  give  a 
chance to leave a message for the SYSOP.   Following the comments 
request  the file called ENTERCPM is show to  the  caller.   This 
file is used to give information to the caller about how you have 
your  RCP/M  set up or about any special commands that are to  be 
used by the caller.Š 



                        DISK DRIVES USED


        DSK$ - DSK2$ - DSK3$ - DSK4$ - DSK5$ - and DSK6$

Sincå somå CP/Í systemó havå verù smalì disë drives¬  (yes¡ µ 1/´ 
ió  small©  oò  É  guesó whaô É shoulä saù arå  thoså  thaô  havå 
limiteä capacity®   Havinç onlù 90Ë byteó oæ spacå oî á disë surå 
caî  puô  á cramğ iî runninç aî RCP/Í oò eveî  simplù  á  messagå 
system®  Bù beinç ablå tï selecô thå disë drivå useä tï storå thå 
variouó  files¬  optimizatioî  oæ  thå  systeí  caî  bå  madå  bù 
selection of drives.  

DSK¤ - Ió thå defaulô drive¬ anä iô ió normalì A:®  Oî thió drivå 
arå storeä thå RBBS38.COÍ program¬  BOOTPWD¬  DATE.DAT¬ ENTERCPM¬ 
INFO, BULLETIN, NEWCOM, MENURBBS, and SYOPMENU.

DSK2¤  - containó  thå  files¬   COUNTERS¬   SUMMARY¬   MESSAGES¬ 
COMMENTS¬  anä  pwds®   Theså  fileó arå thå oneó thaô  gro÷  thå 
fastest on the system.

DSK3$ - contains the files, LASTCALR, CALLERS, and USERS.

DSK4$ - contains the HELP file menu and the other HELPxx files.

DSK5$ - contains the NEWS file menu and the other NEWSxx files.

DSK6¤ - ió á strinç variablå useä tï storå thå currenô valueó foò 
        DSK$ at various places in the program.


Remember..theså  caî  alì bå thå samå drivå oò jusô onlù  twï  oæ 
them¬  sucè  aó DSK¤ oî Aº  anä theî alì thå otheró selecteä  foò 
drive B:.



                          SPECIAL FILES

Aó  mentioneä  beforå therå ió thå 'D§ commanä whicè  allowó  thå 
prograí tï lisô tï thå calleò á texô file®   Thió caî bå anù texô 
filå  yoõ  havå createä iî thå samå manneò aó INFÏ  oò  BULLETIN¬ 
etc®   Thå  onlù  differencå  ió thaô thió filå ió nameä  bù  thå 
INSTALÌ program®   Iô musô bå locateä oî thå DSK¤ drive®  DSK¤ ió 
alsï thå drivå wherå thå RUN-A-FILE-ON-EXIÔ ió located®   Thió ió 
á SYSOĞ selecteä prograí iî INSTALÌ thaô caî bå ruî wheî á calleò 
exitó  tï  CP/M®   Iô  musô bå á .COÍ filå buô yoõ  coulä  uså  á 
prograí  likå  TXT2± tï converô á texô filå tï  á  'runninç  texô 
file' that can be viewed whenever it is called.

Š




             RBBS38 Installation using INSTAL38.COM

INSTAL3¸  waó writteî tï providå á verù simplå waù tï creatå  thå 
twï  passworä fileó useä iî thå RBBS38.COÍ program®   Iî additioî 
tï  thå  INSTAL38.COÍ therå ió anotheò calleä  INSTALL.HLĞ  whicè 
containó  HELĞ  informatioî  incaså yoõ wondeò  whaô  á  specifiã 
instalì  parameteò ió useä for®   (NOTE½ INSTALL.HLĞ  foò  RBBS3· 
will not work with this RBBS38 version)

To  install the RBBS38 program you must put the INSTAL38  program 
and the INSTALL .HLP file in the user area on A:  drive that  you 
will  be running the RBBS38 program from.   If you choose to  use 
other  disk drives for some of the other files created by RBBS38, 
you must have those disk installed in the system.   If because of 
the size of the Install program you don't have enough room,  then 
leave off the RBBS38.COM program for now and put it back in after 
the  INSTAL38  program  has  been run,  and  the  password  files 
created.   Once  they have been created,  the INSTALL  files  can 
then be deleted.

You  are  now  ready to type in INSTAL38  to  start  the  install 
program.   If  you  have  the files BOOTPWD and  pwds  previously 
installed on the system then you will be shown a menu of what the 
password  files have been set up for.   If this is a  first  time 
installation  then  you  will enter right into  the  installation 
program.    After the first bit of information you are asked  the 
first  question about your system,  and that is what drive to put 
the  DSK2$ files on.   You need only to enter the letter  of  the 
drive to be used.   If you enter a '?' at this point, you will be 
shown the HELP file.   Once you have gone past the first question 
whenever  you  enter a '-' you will be returned to  the  previous 
question prompt.   This allows you to correct your entry if after 
you  have entered an answer you change your mind or noticed  that 
it  was incorrect.   If you hit a "+" at this time you will enter 
the menu portion of the install program.   This gives you a quick 
way  to see what you have done so far.   If this is a first  time 
installation  then be sure to return to the point that  you  left 
off and continue entering the password file information.  
 
The menu of password data allows you to modify a single parameter 
and save and exit your new changes to the two password files in a 
system that had already been configured.
  
Iæ  iô  becomeó necessarù tï exiô thå prograí withouô makinç  anù 
changes to the two password files, go to the MENU and do a Ctrl C
anä   thå  INSTAL3¸  prograí  wilì  bå  interrupteä  beforå   anù 
modifications are made to the password files.

Thå  followinç  ió  á lisô oæ thå  INSTALL.HLĞ  prograí  anä  thå 
various questions.Š




Here are the questions you will be asked by the program:


1. Enter drive to be used for DSK2$ files:

This is the drive that will contain the PWDS, COUNTERS, SUMMARY, 
MESSAGES and COMMENTS files.  The MESSAGES and COMMENTS files can 
grow quickly on a busy RBBS.  If you don't have a hard disk 
drive, consider using drive B: for the DSK2$ files.  If you do 
not select the A: drive for DSK2$ files, you must have a disk 
mounted in the DSK2$ drive so that the PWDS file can be written 
when this program terminates.  If you want to use a drive other 
than A: for DSK2$ and don't have a disk mounted in the desired 
DSK2$ drive, terminate this program now with CTRL-C and mount the 
disk that you want to use for the PWDS file in the DSK2$ drive 
before you run the INSTAL38 program again.

NOTE:  The BULLETIN, INFO, ENTERCPM and MENURBBS files must be on 
the A: drive.

This is 'DSK2$'



2. Enter drive to be used for DSK3$ files:

This is the drive that will contain the LASTCALR, CALLERS and 
USERS files.  The USERS file should be protected because it will 
contain the passwords of all your system users.  If you don't 
have a hard disk drive, consider using drive B: for the DSK2$ 
files.

This is 'DSK3$'





3. Enter your FIRST Name:

Your FIRST Name is needed so that RBBS will know the identity of 
the System Operator.  Your users might leave a message addressed 
to either SYSOP or your real First and Last Name.  When you enter 
RBBS as the SYSOP, you will be informed of any messages to either 
SYSOP or your real FIRST and Last Name.

This is 'SYS1$'


Š


4. Enter your LAST Name:

Your LAST Name is needed so that RBBS will know the identity of 
the System Operator.  Your users might leave a message addressed 
to either SYSOP or your real First and LAST Name.  When you enter 
RBBS as the SYSOP, you will be informed of any messages to either 
SYSOP or your real First and LAST Name.

This is 'SYS2$'



5. Enter the name of your RBBS system:

This text entry is what your callers see that identifies your 
RBBS.  It is printed on their screen every time they call.  You 
can use any combination of upper and lower case letters or 
numbers, but this entry is limited to a single line.  This line 
of text will be printed before the RBBS program identifier.

This is 'VERS1$'



6. Enter your direct-to-CP/M FIRST Name password:

This password is used for direct entry to CP/M.  When entered at 
the RBBS FIRST Name prompt, the caller is sent directly to the 
CP/M command prompt in drive A/user 0.  Because it bypasses all 
RBBS identification and access level edits, this password should 
be selected with care and changed periodically.  A random 
combination of alpha and numeric characters will help by making 
this password more difficult to guess.  If you don't want to 
allow direct entry to CP/M, enter NOPASS.

This is 'P1$'



7. Enter your LAST Name password for SYSOP:

The System Operator enters SYSOP at the FIRST Name prompt and 
this password at the LAST Name prompt to enter RBBS as the SYSOP.  
Because the SYSOP has unquestioned CP/M access, can read/kill any 
message, read the COMMENTS file (Z command), look at the entire 
USERS file (UALL command), read the XMODEM.LOG file (XL command) 
and use the user validation software (extended P command); this 
password should be selected with care and changed periodically.  
A random combination of alpha and numeric characters will help by 
making this password more difficult to guess.

This is 'P2$'Š




8. Set the WHEEL for SYSOP on exit to CP/M (Y/N)

This allows a simple way for the SYSOP to call in remotely and 
when he exits the RBBS program to CP/M it sets the WHEEL byte
at 3E to 'FF' hex.  This will normally re-activate all the bad
commands that are protected by the ZCPR program, when a non-SYSOP
caller enters CP/M.  The disadvantage of doing this, is that if
someone got your password, they would be able to do more damage
to your system.  A note appears before CP/M entry to let you know
that the program is setting the WHEEL byte.
 
This is WHEEL



9. Enter your USER Validation password:

This is a special password that is required whenever the SYSOP 
changes the status of a user using the 'P' command.  It is 
particularly useful when there are multiple SYSOPS and only the 
main SYSOP will be using the validation function.  It can also be 
used for extra security in the event that a caller guessed the 
SYSOPs LAST Name password - they would need this password to 
manipulate the USERS file.  If you don't want to enter a 
validation password to change users access levels enter NOPASS.

This is 'VAP$'



10. Enter your CP/M entry question:

This is the question that is asked of UNVALIDATED and VALIDATED 
users before allowing entry to CP/M using the 'J' command in 
RBBS.  TWITs are not allowed CP/M access under any circumstances 
and SUPER users are allowed CP/M access without answering this 
question.  This feature is often used to keep non-CP/M users from 
entering CP/M and questions relating to CP/M are asked.  You 
assume that anyone knowing the answer would have some knowledge 
of CP/M.  If you simply want passworded CP/M access enter 
something like PASSWORD? for this question and provide the answer 
to selected users.  This option, along with your choice for 
GOCPM, determines the CP/M access characteristics of your system.  
If you don't want to ask this question enter NOPASS.

This is 'PC$'



Š




11. Enter the answer to your CP/M entry question:

If you ask VALIDATED and UNVALIDATED users a CP/M entry question, 
this is the answer to that question.  SUPER are allowed CP/M 
access without entering this answer.  If you are not asking a 
CP/M entry question enter NOPASS.

This is 'P3$'



12. More than one SYSOP? (Y/N)

This option allows more than one person to sign on as SYSOP using 
SYSOP at the FIRST Name prompt and the SYSOP LAST Name password 
at the LAST Name prompt.  The SYSOP is then asked for their real 
FIRST Name with the 'Enter your FIRST Name ->' prompt.  This will 
allow the SYSOP to leave messages on RBBS that have a more 
personal identification (FROM) than just SYSOP.  If you have more 
than one SYSOP, take another look at the USER Validation Password 
option to be sure the system is set up the way you want it.

This is 'MSYS'



13. Bell delay value for CHAT (TRY 20000):

This is the value for the timing loop used to ring the bell when 
the SYSOP is paged for CHAT.  This can be set for anywhere from 1 
to 32000.  When using the compiled RBBS program set this value in 
excess of 10000.  A value of 20000 is recommended because it 
seems about right on my system.  When running RBBS with MBASIC 
set this value to less than 500 to see how it works.

This is 'BEEP'



14. Number of lines allowed in messages (try 15):

This value controls the maximum number of lines allowed in 
messages.  A maximum of 15 lines is recommended because it will 
result in messages that are no longer than one screen in length.  
You may have problems with larger maximum line limits because of 
RAM usage.

This is 'SIZE'

Š



15. Number of NEWS files:

This is the value for the number of NEWS files on your system.  
These are ASCII files that you create with a text editor to 
provide information about various topics.  Enter 0 if you are 
only using 1 NEWS file.  If the value is 1 or greater, the NEWS 
file should be a menu of the other NEWS files you are using.  The 
additional files must be named NEWS1, NEWS2, etc. depending on 
the value chosen for this entry and corresponding to the choice 
number specified in the NEWS file (menu).

This is 'NNUM'



16. Which drive contains your NEWS files?

Enter the drive that will be used to store the NEWS file(s) on 
your system.

This is 'DSK5$'



17. Number of HELP files:

This is the value for the number of HELP files on your system.  
These are ASCII files that you create with a text editor to 
provide information about various topics.  Enter 0 if you are 
only using 1 HELP file.  If the value is 1 or greater, the HELP 
file should be a menu of the other HELP files you are using.  The 
additional files must be named HELP1, HELP2, etc. depending on 
the value chosen for this entry and corresponding to the choice 
number specified in the HELP file (menu).

This is 'HNUM'



18. Which drive contains your HELP files:

Enter the drive that will be used to store the HELP file(s) on 
your system.

This is 'DSK4$'



19. Skip 'Highest Message Read' info? (Y/N)

This is 'SKIP'Š



20. Logout TWITs? (Y/N)

TWITs are never allowed to enter messages or go to CP/M.  If you 
answer no to this question, TWITs will be allowed RBBS access.  
If you answer yes, TWITs will be logged off without RBBS access.  
Another alternative to TWITing is to change the users password.  
In either case the user could simply call back using a different 
FIRST and LAST Name on non-secure systems.  There is no real good 
answer to this problem on non-secure systems.

This is 'TWIT'



21. Can <E>veryone enter messages, both <V>alid and Super users, 
    or just <S>uper users?  Enter (E, V or S):

This opton determines which users can enter a message on your 
system.  TWITs are never allowed to enter messages and Super 
users are always allowed to enter messages.

<E> will allow Unvalidated, Validated and Super users to enter 
messages.

<V> will allow both Validated and Super users to enter messages.

<S> will allow only Super users to enter messages.

This is 'LMSG'



22. <E>veryone have passworded CP/M access, both <V>alid and 
    Super users, or just <S>uper users?  Enter (E, V or S):

This option, along with your choice for PC$, determines the CP/M 
access characteristics on your system.  TWITs are never allowed 
access to CP/M.  Super users are always allowed to enter CP/M and 
are never required to enter a CP/M entry password.

<E> will allow Unvalidated, Validated and Super users to enter 
CP/M.  If you decided to require a CP/M entry password, both 
Unvalidated and Validated users will be have to enter it.

<V> will allow both Validated and Super users to enter CP/M.  If 
you decided to require a CP/M password, Validated users will have 
to enter it.

<S> will allow only Super users to enter CP/M.  A CP/M entry 
password is never required for Super users.
ŠThis is 'GOCPM'



23. Do you have an external clock? (Y/N)

In order to provide date/time information for the RBBS program 
there is a section of code that will read a file DATET.DAT on 
the A: drive if you have an external clock.  If you don't have an 
external clock to provide the date/time information, RBBS will 
ask callers if the date in the DATE.DAT file is correct.  If the 
caller indicates that the date is not correct, they are asked for 
the correct date so that the DATE.DAT file can be updated.
 
This is 'DATIM'



24. Enter the filename you want loaded at exit:

This is the name of the file that is run when the caller enters 
the G command.  The caller is first asked if they are sure they 
want to leave the system, asked for comments for the SYSOP and 
then the EXIT$ program is run.  EXIT$ is normally BYE.COM.

This is 'EXIT$'


25. Show location of callers and users? (Y/N)

This seems to be one of the more emotional switches provided in 
the INSTALL program and I wish it wasn't necessary.  It is 
suspected that the FIRST Name, Last Name and Location information 
in the CALLERS and USERS files of remote systems has been used to 
steal computer equipment.  When SHOLOC is set to NO, the LOCATION 
stored in the USERS file is not displayed with the U command.  
Further,  location is not stored in the CALLERS file so it is not 
displayed with the L command.  The SYSOP will see location with 
the U or UALL command no matter how SHOLOC is set.

This is 'SHOLOC'


26. Log unvalidated callers? (Y/N)

TWITs are never logged in the CALLERS file.  Callers can find out 
who has been on the system by listing the CALLERS file with the L 
command.  You may have problems with callers using unsuitable 
words for their FIRST and LAST Name entries, LOGALL can help.  
When set to NO, only VALID and SUPER users are logged in the 
CALLERS file and thus displayed with the L command and since the 
SYSOP must take action to change a users status to either VALID 
or SUPER, the SYSOP can prevent  @#*(&! %@*%#@  from offending 
anyone.  When set to YES, UNVALIDATED users (new callers or those 
purposely left UNVALIDATED) are logged and thus displayed with Šthe L command.

This is 'LOGALL'

27. Display unvalidated users? (Y/N)

TWITs in the USERS file are only shown to the SYSOP if the UALL 
command is used.  You may have problems with callers using 
unsuitable words for their FIRST and LAST Name entries, SHOALL 
can help.  When set to NO, only VALID and SUPER users are shown 
when the USERS file is displayed with the U command and since the 
SYSOP must take action to change a users status to either VALID 
or SUPER, the SYSOP can prevent  @#*(&! %@*%#@  from offending 
anyone.  When set to YES, UNVALIDATED users (new callers or those 
purposely left UNVALIDATED) are shown as well with the U command.

This is 'SHOALL'



28. Set RBBS in secure mode? (Y/N)

The secure mode allows you to shut down your system to new 
callers.  When a caller is listed in the USERS file, they will 
enter the system normally in both secure and non-secure mode.  
When a new caller (someone who is not in the USERS file) logs on 
and the system is in the secure mode, they are not allowed entry.  
The RBBS program will tell the caller that it's a private system, 
hang up and run the EXIT$ file.  If you are running a secure 
system, you must set this switch to not-secure in order to add 
additional users to the USERS file.

This is 'SEC'



29. Name of .COM file/program to run on CP/M entry:

Enter the name of a program or run text file, it must be a .COM
file and it must exist in the same Drive/User as the RBBS program.
This allows you to run a file when the caller exits to CP/M with
the J command.  Be sure that when the file you are running exits
that it exits back to A0: and not the drive/user of RBBS.  This
feature can be used to link to another program you might have 
written and compiled from BASIC that might ask user statistics
or request other information.  If you have no file to be run on
exit to CP/M then enter the word "NOFILE" and it will skip over
any run request at exit to CP/M.

This is EPRG$




Š



30. Name of file to Read with 'D' command:

You now have the capability to have a special text file for the
validated users to read.  This file cannot be read by TWITS or a
caller who is not validated.  This file might contain information
of interest to club members, or those who make up your list of
users who are validated.  If the file named is not found, the
program will return to the command line prompt.  This file must
exist in the Drive/User that the RBBS program is running in.
 
This is DFIL$



31. Ready to create the password files? (Y/N)

The INSTALL program will now write the BOOTPWD file on the A: 
drive and the PWDS file on the drive you selected for DSK2$.  If 
you did not select the A: drive for DSK2$ files, you must have a 
disk mounted in the DSK2$ drive so that the PWDS file can be 
written when this program terminates.  If you are using a drive 
other than A: for DSK2$ and don't have a disk mounted in the 
desired DSK2$ drive, terminate this program now with CTRL-C and 
mount the disk that you want to use for the PWDS file in the 
DSK2$ drive before you run the INSTALL program again.




                 PASSWORD FILES...A discription

Thå  firsô  passworä filå loadeä ió BOOTPWD¬  anä ió  locateä  oî 
DSK$®   Iô  containó  thå formaô oæ stringó anä variableó iî  thå 
following order and used by RBBS38.COM.

DSK2$, DSK3$, DSK4$, DSK5$, SYS1$, SYS2$, VERS1$, TWIT, DATIM,
SEC, SHOLOC, DFIL$, EPRG$, WHEEL



Thå seconä passworä filå loadeä ió 'pwds§ anä ió locateä oî DSK2¤ 
aó describeä iî BOOTPWD®  Yoõ wilì alsï notå thaô thió filå ió iî 
loweò caså oî youò system®  Thió preventó anyonå froí typinç thió 
file®   Tï  vie÷ iô yoõ wilì neeä tï uså SWEEĞ oò NSWP®   Iæ  yoõ 
havå  someho÷ manageä tï makå iô returî tï UPPEÒ  case¬  anä  thå 
RBBS3¸  prograí can'ô finä it¬  theî uså DU.COÍ (Disë Utility© tï 
modifù  thå directorù entrù bacë tï lowercase®   Thå 'pwds§  filå 
containó  thå  followinç stringó anä variableó iî  thå  followinç 
order and used by RBBS38.COM

P1$, P2$, P3$, PC$, VAP$, EXIT$, LOGALL, SHOALL, BEEP, SIZE, MSYSŠNNUM, HNUM, SKIP, LMSG, GOCPM



                      LASTCALR file changes

The  LASTCALR  file created from RBBS38 has an  additional  field 
added  to  the original format found in the earlier  versions  of 
RBBS.   It  consists of FIRSTNAME,LASTNAME,DATE/TIME information.  
Thió  allowó  otheò  programó  sucè aó XMODEÍ wheî  useä  iî  thå 
logging mode to get the date that the file was transfered.


                  RBBS35 & RBBS37 Compatability

Nï problem¬ alì thå fileó yoõ havå createä froí RBBS3µ anä RBBS3· 
arå  compatablå  witè thå ne÷ versioî RBBS38®   Yoõ  caî  replacå 
RBBS3µ oò RBBS3· witè RBBS38¬ anä nï onå wilì bå thå wiser®  Jusô 
replacå  thå  olä  BOOTPWÄ anä pwdó fileó anä  ruî  thå  INSTAL3¸ 
prograí anä yoõ arå readù tï go®  RBBS3¸ useó thå samå formaô foò 
thå MESSAGEÓ anä USERÓ fileó aó the earlier versions.


                     JUST A FEW OF THE FILES

USERS FILE:

With RBBS38 you can create several levels of USERS on the system.  
By leaving the users unvalidated,  you now have the first kind of 
user  on your system.   A non-validated user,  has  very  limited 
capabilities  and cannot leave messages on the board,  unless you 
allow  everyone  the  ability  to  leave  messages.   Next  is  a 
Validated  user,  this user can now leave messages,  and look  at 
other files and may or may not be allowed access to  CP/M.   Then 
there  is a SUPER user,  this is almost a SYSOP,  but not  quite, 
he/she  can go to CP/M whenever they use the 'J' command  without 
having  to  answer any question or provide a password for  entry.  
Iî   additioî wheî á supeò useò enteró hå ió automaticallù iî thå 
Xperô  modå oî thå  commanä line®    Thå lasô typå oæ useò  ió  á 
TWIT¬   thió   useò doeó noô havå anù capabilitieó excepô tï reaä 
messageó oò leavå á comment to the SYSOP.
 
Here is an example of the USER file.


 6                                   ;Number of Users
# DENNIS;RECLA;GARLAND,TX;SINNED; 2  ;SUPER user/last msg =2
! ROBERT;HUFF;DALLAS,TX;BOBHUFF; 0   ;Verified user
  MIKE;MOORE;IRVING,TX;DISKDRIVE;3   ;new user/last msg=3
! STEVE;SANDER;IRVING,TX;SUPERGUY; 4 ;Verified user/last msg =4
* BIG;JOHN;GARLAND,TX;BADGUY; 0      ;Bad Guy use * to keep out
  NEW;USER;ANYWHERE,TX;HELLOTHERE; 0 ;new user not verified yet

REMEMBER..  If you find it necessary to modify the USERS file, be 
sure to correct the 'count' at the beginning of the file,  and to Šerase the entire line.  The program looks for a line length of 65 
characters  and if this changes the USERS file will be  corrupted 
and in some cases made useless.


                         HELP/NEWS FILES

These  files  are an added feature of the program,  the  original 
RBBS35  allowed for only a NEWS file.   In this expanded  version 
you can have as many NEWS and HELP files as you want.   These are 
set up in the INSTAL38 program.   In the installation you need to 
indicate the number of files there will be for HELP and NEWS.  If 
you  put  a 0 then then RBBS38 will know that there is  only  one 
file called NEWS or HELP.  In the case of a single file, the HELP 
or  NEWS file will contain the information you want to  give  the 
caller.   When it is finished typing to the screen, the caller is 
returned to the command line prompt.  If a value larger than 0 is 
entered for NEWS or HELP file numbers, then the files called HELP 
and NEWS are the MENU for the additional files.  A number request 
is  made  from that file asking the caller what file number  they 
want to read.   With only one expansion NEWS or HELP file it is a 
little awkward,  but with two or more it works quite well.   Each 
of the additional files are named NEWS1,  NEWS2,  NEWS3, etc. and 
it is the same for the various HELP files.   A typical menu might 
appear as follows:

---

        HELP Files Available

1> Using RBBS          2> Leaving a Message
3> Using CHAT          4> Going to CP/M
 
 
---

Each time the caller selects a number and that file is viewed, he 
will  be returned to the file menu for the  next  selection.   To 
exit  the  menu  file enter a number 1 greater than  the  highest 
message  number.   A prompt line will indicate this whenever  the 
value  entered in NNUM and HNUM from the installation program  is 
greateò thaî 0®   Iî additioî thå drivå wherå theså programó  arå 
located is configured in the INSTAL38 program.











Š




                      DDT and RBBS38A.COM

Iô  ió possiblå witè DDÔ tï gï iî anä modifù á fe÷ placeó iî  thå 
code®   Insteaä  oæ  DDÔ É woulä reccomenä yoõ uså PATCÈ oò  somå 
similaò  filå  editoò thaô allowó fulì screeî  editinç  anä  botè 
ASCII and HEX modifications to the Binary code.

Wheî  yoõ looë aô RBBS38A.COÍ (Aó distributed© yoõ finä thaô  alì 
thå texô stringó iî iô arå containeä iî thå areá betweeî 4D0° and
590°  hex®   Thå followinç arå thå locationó oæ somå oæ thå  morå 
usefull ASCII strings and called files of the program.

   XMODEM.LOG     @ 4D4C              COMMENTS.      @ 5098 

   MESSAGES.      @ 5199              MENURBBS.      @ 540A

   SYOPMENU.      @ 5415              SUMMARY.       @ 5506

   USERS.         @ 562A              pwds.          @ 5777

   BOOTPWD.       @ 577E


Alì  oæ  thå abovå valueó arå thå HEØ locatioî iî thå  RBBS38.COÍ 
program.

Knowinç  theså locationó yoõ caî modifù theí froí uppeò tï  loweò 
caså  iæ  yoõ wanô tï protecô theí furthuò  froí  typing¬  oò  bù 
changinç thå filå SYOPMENÕ tï MENURBBÓ thå SYOPMENÕ filå wilì noô 
be called.  



















Š



           A few Parting Comments from the Programmer


É  kno÷  É saiä thaô RBBS3· woulä bå thå lasô onå É woulä  write¬ 
buô  É  diä finä á fe÷ problemó thaô havå beeî takeî carå  oæ  iî 
thió  ne÷ version®   É guesó É mighô saù iô oncå again¬  aô  thió 
point®  É reallù don'ô expecô tï dï anotheò majoò revisioî oî thå 
RBBÓ linå oæ programs®  
 
However!

É  dï  expecô  thaô  á  ne÷ UTILITÙ  prograí  wilì  bå  thå  nexô 
modificatioî tï thå RBBS3¸ filå oæ programs®  Thå currenô utilitù 
dealó witè thå messagå base¬  anä seemó tï filì mosô requirementó 
thaô havå beeî puô upoî it®   Thå areá thaô ió lackinç ió á  gooä 
utilitù  tï managå thå USERÓ filå iî thå system®   Futurå effortó 
wilì  bå puô oî replacinç thå existinç utilitù witè  aî  expandeä 
onå thaô alsï takeó carå oæ thå USERÓ base®  Iô wilì bå issueä aó 
aî  updatå filå tï replacå thå currenô utilitù program¬  anä  thå 
remainder of the files will most likely remain the same.


TO ANSWER A FEW QUESTIONS:         An Editorial !!!

Everyonå  haó  differenô  feelingó abouô whaô  á  messagå  systeí 
oò BBÓ prograí shoulä do®  É havå á fe÷ oæ mù own¬ anä aó yoõ caî 
guesó theså havå beeî incorporateä intï RBBS38®   Á currenô trenä 
iî  BBÓ  systemó seemó tï bå thå Multi-nodå oò  multiplå  messagå 
baså  programó wherå thå calleò haó á numbeò oæ  message/interesô 
areaó  thaô  caî bå lookeä at®   RBBS3¸ witè it'ó singlå  messagå 
baså  maù  seeí  á biô 'ouô oæ touch§ buô  É  prefeò  thå  singlå 
messagå base®   Mù basiã feelinç towardó á BBÓ systeí ió thaô thå 
calleò  shoulä  bå  ablå tï geô oî anä spenä aó  littlå  timå  aó 
possiblå  tï allo÷ thå nexô calleò tï geô on®   Aó thå numbeò  oæ 
messagå  baseó increases¬  sï doeó thå timå thaô eacè  individuaì 
calleò  spendó  oî youò system®   Á singlå messagå baså  normallù 
carrieó  á singlå threaä oæ informatioî thaô maù changå froí  daù 
tï  daù  oò calleò tï caller®   Thå  multi-baseä  programó  carrù 
severaì  threadó oæ thoughô thaô á calleò mighô bå interesteä  iî 
readinç oò commentinç on®   Thió takeó time¬ anä aó lonç aó therå 
arå 30° bauä modemó around¬  peoplå wilì calì youò board®  Wheî É 
calì  á  system¬  É don'ô likå tï waiô anä waiô aó thå systeí  ió 
beinç useä tï reaä pageó anä pageó oæ informatioî iî á numbeò  oæ 
messagå  bases®   Iæ thå averagå calleò spendó á  houò  rambling¬ 
reading¬  remarking¬  anä sittinç aô thå keyboarä thinking¬  theî 
yoõ  caî seå thaô thaô allowó onlù 2´ calleò á day®   Believå  må 
froí  abouô 1:0° aí tilì abouô 6:0° yoõ wilì bå luckù tï geô  onå 
caller®   Therå goeó µ oæ thoså houró righô there¬ sï thinë abouô 
whaô yoõ wanô youò systeí tï be¬  anä ho÷ eacè additioî oò changå 
will effect the callers time on line or downloading capability.
 Š

Besideó  thå waù RBBS3¸ waó writteî iô IÓ á MAJOÒ modificatioî tï 
ad another message base.  

Somå oæ thå otheò thingó sucè aó rememberinç iæ thå calleò ió  aî 
experô oò wheî theù lasô called¬  etc®   Caî easilù bå added¬ buô 
thå  codå haó gotteî sï largå aó tï bå á probleí witè sizå oæ thå 
runninç  file®   É  havå  alsï  trieä tï  keeğ  thió  prograí  aó 
compatablå witè oldeò versionó aó possible®  Thió meanó thaô oncå 
yoõ havå establisheä á useró oò messagå base¬ anä wanô tï upgradå 
thå systeí yoõ don'ô neeä tï re-dï alì youò files¬  oò starô  alì 
over®  Compatabilitù witè thå earlieò versionó haó beeî kepô witè 
this version.  

É  havå considereä á ne÷ version¬  anä expecô tï calì iô RBBMÓ oò 
somå sucè thinç (Remotå Bulletiî Boarä Messagå System)®   Iô wilì 
noô bå completelù compatablå witè RBBS38¬  buô wilì takå carå  oæ 
thå  sizå  probleí  anä á fe÷ oæ thå others®   Iô wilì  stilì  bå 
writteî iî MBASIC¬ anä uså BASCOÍ tï compile.

Aó  É  continuå  tï ramblå oî abouô things¬  leô  må  thanë  Garù 
Spenceò  anä  á  fe÷ oæ hió friendó whï helpeä tï makå  thió  ne÷ 
version what it is today.



                       If you need help !!
 
É can'ô helğ everyone¬ buô É trù mù best®  Iæ yoõ dï requirå thaô 
yoõ  rewritå  thå prograí anä cannoô linë iô theî senä iô  tï  mù 
'Losô Islanä RCP/M-RBBS§ durinç it'ó operationaì hours®   É  wilì 
linë   iô  anä  puô  iô  oî  thå  systeí  foò  yoõ  tï  download®  
Alternatelù É caî reaä 8¢ diskó formatteä SSSÄ oò µ 1/´ diskó  iî 
thå  Z-10° DSDÄ format®   Iæ yoõ havå questionó abouô thå prograí 
theî givå mù systeí á call¬  anä leavå må somå feedback®   É wilì 
trù  tï  answeò  iô withiî á daù oò two®   

Iæ  yoõ neeä á copù oæ thió prograí oî 8¢ disë theî senä  må  thå 
blanë  disks¬  anä  sufficienô postagå tï returî thå  disks®   Mù 
schedulå ió alwayó á mess¬ sï expecô ± tï ² weeë turî around¬ buô 
it has been worse.  



                    Good luck with RBBS38 !!
 
             From all of us here at the Lillypond !!



             O O             O O             o o 
            :...:           (:::)           (---)
           _^/ \^_         _^/ \^_        __^\"/^__  
Š




