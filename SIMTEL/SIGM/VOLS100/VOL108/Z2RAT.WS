.he                      ZCPR2 Rationale Manual
.fo                                                    Page #
                   Rationale Manual for ZCPR2


1.0  Introduction

     Thió  Rationalå  Manuaì assumeó thaô yoõ havå reaä thå  Con
ceptó  Manuaì oæ ZCPR² anä understanä it®   Havinç reaä  thå  In
stallatioî  Manuaì anä thå User'ó Guidå ió alsï helpful®   Iæ yoõ 
havå noô reaä aô leasô thå Conceptó Manuaì yet¬  É recommenä thaô 
yoõ gï bacë anä reaä it.

     É guesó thå verù firsô questioî tï answeò iî thió manuaì  ió 
"Whù  havå  á  ZCPÒ oò ZCPR² iî thå firsô  place?¢   Ratheò  thaî 
responä witè anotheò question¬  likå "Whù not?"¬ let'ó takå ouô á 
littlå timå tï looë aô CP/M.

     CP/Í waó anä ió á gooä idea®  Iô ió á smalì operatinç systeí 
whicè encapsulateó thå targeô microcomputeò iî á virtuaì machine®  
Througè  thió virtuaì machine¬  softwarå transportabilitù aô  thå 
binarù level“ ió realized®   Aó á generaì rule¬ yoõ caî picë uğ aî 
objecô  prograí (iî absolutå objecô form© whicè runó oî onå  CP/Í 
system¬  transporô  iô  tï anotheò CP/Í systeí whicè  ió  runninç 
differenô  hardware¬  anä executå iô withouô modifyinç iô iî  anù 
way®  Thió ió significant!

     CP/Í ió bù nï meanó á panacea¬ however®  Á typicaì operatinç 
systeí  (iî thå conventionaì sense© manageó fouò resourceó oæ thå 
computeò  system®    Theså  arå   Processes/Processors¬   Memory¬ 
Devices¬  anä  Information®   CP/Í  doeó virtuallù nï procesó  oò 
memorù  management¬  anä  nï protectioî ió affordeä thå  useò  tï 
speaë of®  Oncå á prograí ió alloweä tï execute¬ iæ iô chooseó tï 
eraså CP/Í froí memory¬ iô can®  Iæ iô chooseó tï eraså thå disk¬ 
it can.  There is almost nothing to stop it.

     Thå  CP/Í virtuaì machinå shineó iî thå performancå  oæ  thå 
functionó  oæ  devicå  anä  informatioî  management®    Thå  BIOÓ 
provideó  á software-based¬  machine-independenô interfacå tï thå 
physicaì  deviceó oæ thå computeò system®   Thå BDOÓ  provideó  á 
software-based¬ machine-independenô interfacå tï thå fileó oæ thå 
computeò system®  Aî applicationó prograí caî uså theså twï partó 
oæ CP/Í tï communicatå directlù witè thå hardware¬  regardlesó oæ 
whaô  thå hardwarå actuallù is¬  anä tï manipulatå fileó aô will®  
Theså interfaces¬  generallù speaking¬ arå thå samå regardlesó oæ 
what machine the CP/M system is running on.

     Buô CP/Í ió divideä intï threå parts®  Thå CCĞ ió thå third®  
Thió ió thå interactivå interfacå tï thå CP/Í user®   Througè thå 
CCP¬ thå CP/Í useò communicateó tï thå system®  Interpretatioî oæ 
thå  alì oæ thå user'ó commands¬  executioî oæ somå oæ thå user'ó 
commands¬  interpretatioî  anä executioî oæ commandó  froí  disk-
baseä  commanä  files¬  anä initiatioî oæ processeó (runninç  COÍ 
files©  iî thå CP/Í environmenô arå fouò oæ thå  majoò  functionó 
performeä bù thå CCP.


     ZCPÒ  (oò ZCPR1© waó originallù designeä tï replacå thå  CCĞ 
iî aî attempô tï improvå thå user'ó interfacå tï thå CP/Í system®  
Thå BIOÓ anä BDOÓ werå untoucheä bù ZCPR1¬ sï thå virtuaì machinå 
remaineä  intacô  and¬  witè it¬  thå benefitó deriveä froí  thió 
virtuaì machine®   Witè verù fe÷ exceptions¬  anù COÍ filå  whicè 
raî  undeò CP/Í coulä alsï ruî undeò á ZCPR1-baseä systeí withouô 
modification.

     ZCPR±  changeä thå user'ó interfacå iî onlù á fe÷ keù  ways®  
First¬  iô  provideä á simplå command-searcè hierarchù sï thaô  á 
brieæ searcè woulä bå performeä foò á commanä oncå iô waó issued®  
Iî thió way¬ thå useò neeä nï longeò bå concerneä abouô wherå hió 
COÍ fileó werå located¬ anä hå coulä starô tï makå morå effectivå 
uså oæ USEÒ areaó iî dividinç uğ hió projectó anä such®  Duplica
tioî  oæ  COÍ  fileó iî differenô useò areaó  oò  duplicatioî  oæ 
directorù  entrieó  pointinç tï thå samå COÍ filå werå nï  longeò 
necessary®   Second¬ thå ZCPR1-residenô commandó werå enhanceä iî 
minoò  wayó tï improvå theiò utility®   ERA¬  foò  instance¬  no÷ 
printeä ouô thå nameó oæ thå fileó iô erased¬  anä commandó  likå 
LISÔ  (whicè  TYPEä tï thå printer© anä GÏ (whicè reexecuteä  thå 
COÍ imagå residinç iî memorù aô 100H© werå added®  Alonç thå samå 
lines¬  thå  prompô waó changeä sï thaô thå useò numbeò  waó  in
cluded¬ therebù tellinç thå useò whaô useò areá hå waó in.

     ZCPR± was¬  iî effect¬  á logicaì extensioî tï thå CP/Í CCP¬ 
anä iô cosô nothinç tï implemenô it®   ZCPR± waó thå samå sizå aó 
thå CP/Í CCP¬ anä iô simplù overlaiä it®  Itó solå purposå waó tï 
improvå thå user'ó interfacå tï thå system¬  consequentlù improv
inç hió productivitù aó well®   Thå useò coulä structurå hió worë 
tï somå extenô anä concentratå morå oî thå probleí aô hand.

     No÷  ZCPR²  ió cominç intï play®   Thå basiã reasoî foò  itó 
existencå  ió  thå  samå aó foò ZCPR± -- tï  improvå  thå  user'ó 
interfacå  tï hió CP/Í  system®   Unlikå  ZCPR1¬  however¬  ZCPR² 
significantlù  extendó  thió  interfacå anä ió morå  flexiblå  iî 
allowinç  thå  useò (oò installer© tï tailoò thå  systeí  tï  thå 
user'ó  needs®   Morå humaî engineerinç principleó havå beeî  ap
plieä undeò ZCPR2®  Directorieó maù bå giveî mnemoniã names¬ likå 
JEFÆ oò TEXT¬ thå command-searcè patè maù bå specifieä anä chang
eä bù thå useò dynamically¬  facilitieó arå availablå whicè allo÷ 
thå  useò  tï emploù alì 3² useò areaó oî á disk¬  menuó  maù  bå 
invokeä  aó desireä tï simplifù thå useò interfacå eveî  more¬  á 
serieó  oæ  commandó maù bå expresseä oî thå samå linå  (allowinç 
thå useò tï gï ofæ anä dï somethinç elså whilå thå systeí ió busù 
workinç foò him)¬ anä I/Ï caî bå redirecteä mnemonicallù (Consolå 
caî bå defineä aó MODEÍ ratheò thaî UC1).

     Anä  alì oæ thió ió donå witè á minimuí oæ overhead®   Aó  á 
rule¬  ZCPR² ió thå samå sizå aó thå CP/Í CCP¬ anä á minoò growtè 
iî  thå  BIOÓ (usuallù oî thå ordeò oæ 1K© ió requireä  tï  fullù 
implemenô  á ZCPR² System®   Undeò ZCPR2¬  youò TPÁ maù staù  thå 
samå sizå aó iô haó alwayó been¬  or¬ aó morå featureó arå imple
mented¬ iô maù shrinë slightly¬ buô usuallù nï morå thaî 1K.
Š
     Gettinç bacë tï thå originaì questioî oæ "WHY?"¬ É guesó thå 
answeò ió tï attempô tï improvå thå worlä oæ thå user®   Tï  makå 
thå  machinå  morå  subservienô tï thå wilì oæ thå  useò  anä  tï 
increaså  thå productivitù oæ thå useò arå twï keù wayó iî  whicè 
ZCPR² attemptó tï improvå thå user'ó world.


2.0  Comparison Between ZCPR2 and the CP/M 2.2 CCP

     Thió sectioî oæ thå Rationalå outlineó thå functionaì  diff
erenceó  betweeî ZCPR² anä thå CP/Í 2.² CCĞ witè á brieæ explana
tioî  oæ  whù theså featureó werå implementeä iî  ZCPR²  iî  thió 
fashion.


2.1  The ZCPR2 Prompt

     First¬  thå prompt®  Aó É vie÷ thå purposå oæ thå prompt¬ iô 
serveó tï telì yoõ wherå yoõ arå locateä anä thaô ZCPR² ió  readù 
tï  accepô  á commanä line®   Undeò CP/M'ó CCP¬  thió prompô  waó 
simplù  thå disë letteò followeä bù á  ">"®   Undeò  ZCPR2¬  thió 
prompô maù bå thå samå oò iô maù bå á DÕ form¬  sucè aó "A12>¢ oò 
"B1>"¬ whicè telló yoõ exactlù wherå yoõ are.

     Iî designinç thå ZCPR² System¬  however¬  É founä á neeä foò 
thå  prompô tï servå á thirä function®   Thió functioî ió tï telì 
thå  ZEØ Monitoò thaô iô maù begiî supplyinç inpuô thrõ thå  BIOÓ 
again®   ZEØ respondó tï á commanä whicè telló thå ZEØ Monitoò tï 
stoğ supplyinç characteró thrõ thå BIOÓ anä tï allo÷ thå useò  tï 
inpuô hió owî text®   Thió ió á nicå featurå oæ ZEØ sincå commanä 
filå processinç maù no÷ bå interrupteä foò useò input®   Thå useò 
maù  inpuô  aî  optioî tï á command¬  maù enteò texô anä  ruî  aî 
editor¬  oò  maù perforí otheò functionó requirinç hió  attentioî 
whilå ZEØ ió iî control®   Á questioî oæ ho÷ tï telì ZEØ thaô  iô 
maù  resumå controì camå up¬  however®   Afteò á loô oæ delibera
tion¬  É decideä thaô á speciaì characteò senô tï thå consolå waó 
thå besô waù anä thaô thió characteò shoulä bå senô bù ZCPR2.

     Thió character¬  however¬  haä tï bå unique®  Iô shoulä bå á 
characteò  whicè  ió noô normallù senô tï thå  screeî  sincå  ZEØ 
woulä  starô  uğ immediatelù wheî iô sa÷ thió character®   Iô  ió 
alsï  preferreä thaô thå useò noô bå forceä tï issuå  thió  char
acteò  himselæ  sincå thå humaî interfacå ió incumbereä  bù  thió 
(thå  humaî  ió forceä tï providå aî arbitrarù inpuô tï helğ  thå 
softwarå  along)®   Iô makeó nï differencå iæ thió  characteò  ió 
printablå  oò not¬  sï lonç aó iô caî bå pickeä uğ bù ZEØ aô  thå 
righô timå anä hopefullù aô nï otheò time.


     Again¬  afteò somå thought¬  É opteä tï uså thå ZCPR² prompô 
tï contaiî thió character®   Thió choicå waó madå because¬ iî alì 
practicaì  caseó É coulä envision¬  thå neeä foò useò inpuô woulä 
bå  sucè thaô thå useò woulä inpuô hió datá iî ordeò foò á  func
tioî  tï  bå performeä anä theî controì woulä  returî  tï  ZCPR2®  
ZCPR²  woulä alwayó bå therå tï turî ZEØ bacë oî anä woulä bå thå 
onlù commoî denominatoò É coulä counô on®   É didn'ô wanô tï  adä 
anù  unnecessarù  overheaä tï ZCPR² tï dï  thió  either¬  so¬  iô 
seemeä  reasonablå  tï makå thå ">¢ characteò signficanô tï  ZEX®  
Therå  arå manù caseó wherå thå ">¢ characteò woulä bå  typeä  bù 
thå useò iî matè expressionó anä thå like¬ sï É electeä tï definå 
thå ">¢ witè itó mosô signficanô biô seô tï bå thå prompô charac
ter®   Thió ió ratheò unique®  Iî alì caseó É coulä envision¬ thå 
normaì uså oæ ">¢ ió aó 7-biô ASCIÉ witè thå 8tè biô turneä off.

     Thå  onlù  problemó  É coulä seå witè thió  arå  witè  thoså 
terminaló whï gï intï graphicó modå wheî theù encounteò á charac
teò  witè thå 8tè biô seô anä thoså printeró whï responä tï  sucè 
characters®   Thå  printeò  probleí rearó itó uglù heaä wheî  thå 
useò employó ^Ğ tï prinô consolå output®   Aî answeò tï thå firsô 
probleí ió tï eitheò chooså á prompô characteò thaô doeó noô havå 
thió  effecô oò tï adä á 2nä bytå afteò thå ">¢ whicè ió  á  non-
printing¬ non-graphiã character®  Aî answeò tï thå seconä probleí 
ió noô tï uså thå ^Ğ functioî tï direcô consolå outpuô tï thå CRÔ 
anä  printeò  iî parallel¬  buô tï uså á redirectablå I/Ï  driveò 
whicè  driveó  á consolå witè CRÔ inpuô anä  CRT/printeò  output®  
Thió driveò coulä filteò thå MSÂ froí alì characteró senô tï  thå 
printer.


2.2  The ZCPR2 Resident Command Set

     Thå nexô iteí tï discusó ió thå ZCPR2-residenô commanä  set®  
É  vie÷ thå seô oæ residenô commandó undeò ZCPR² anä thå CP/Í CCĞ 
tï  bå necessarù foò twï reasonsº   (1© tï quicklù  perforí  fre
quently-needeä functionó anä (2© tï providå theså functionó with
ouô  consuminç  disë spacå foò them®   Thå implementatioî oæ  thå 
residenô commandó withiî thå CP/Í CCĞ waó good¬ buô É didn'ô feeì 
iô waó complete®   Foò instance¬ thå CP/Í CCĞ DIÒ commanä diä noô 
allo÷ yoõ tï vie÷ Systeí Files¬  thå ERÁ commanä diä noô sho÷ yoõ 
whaô  iô waó erasing¬  thå TYPÅ commanä diä noô  page¬  thå  SAVÅ 
commanä  requireä  á  decimaì argumenô whilå DDÔ  anä  thå  otheò 
debuggeró  gavå yoõ hexadecimaì valueó tï worë with¬  anä alì  oæ 
thå  commandó  refuseä tï directlù addresó differenô  useò  areaó 
whilå allowinç yoõ tï addresó differenô disks.


     Tï  providå  morå flexibilitù anä consistencù tï  thå  ZCPR² 
System¬ É abolisheä thå USEÒ commanä (notå thaô therå neveò waó á 
DISË  command)¬  anä  incorporateä  á Useò Numbeò intï  thå  Disë 
references®   Thió  seemeä  tï alsï makå thå entirå  systeí  morå 
uniforí iî appearancå tï thå user¬ particularlù wheî hå wanteä tï 
dividå hió worë intï differenô useò areas®  Tï adä tï thå consis
tency¬  É  alloweä thå DÕ forí tï bå useä bù  anù  ZCPR2-residenô 
commanä  oò  anù ZCPR2-supplieä transienô commanä whereveò thå  Ä 
forí waó useä before®   No÷ wå arå consistenô -- tï changå disks¬ 
typå  "d:"»  tï changå users¬  typå "u:"»  tï changå  both¬  typå 
"du:"®   Tï extracô á COÍ filå froí á differenô directory¬ simplù 
prefiø  iô witè á "d:"¬  á "u:"¬  oò á "du:"®   Argumentó tï  thå 
commandó likå DIÒ anä ERÁ werå alsï alloweä tï bå DÕ forms.

     Onlù  onå  probleí existó witè thió ideá thaô É  coulä  see¬ 
however®   Anù "standard¢ CP/Í transient¬ likå Worä Staò oò DBASÅ 
II¬  woulä noô kno÷ abouô thå DÕ forí anä couldn'ô deaì witè  it®  
No÷ wå havå aî inconsistencù -- somå commandó coulä handlå DÕ anä 
otheró onlù D®   Thió starteä må oî thå ideá oæ thå ZCPR² System®  
Questionº   wheî dï yoõ neeä thå DÕ form¿   Answerº  wheî yoõ arå 
crossinç directorieó -- wheî yoõ arå sittinç iî onå directorù anä 
wanô  tï accesó fileó iî anotheò directory®   Afteò workinç  witè 
ZCPR±  anä ZCPR² foò sï long¬  É realizeä that¬  wheî iô comeó tï 
thå commerciaì softwarå packages¬ É typicallù diä noô worë acrosó 
directorù boundaries¬  or¬ iæ É did¬ iô waó alwayó dowî tï disë Á 
iî thå currenô user®   Hence¬  É neveò camå tï uså á prefiø tï  á 
filå  wheî á raî aî editoò oò compiler®   É alwayó useä "EÄ FILE¢ 
oò "CÃ FILE"®   Iô waó onlù wheî É wanteä certaiî directorù  dis
plays¬  wheî É wanteä tï vie÷ certaiî files¬ anä wheî É wanteä tï 
manipulatå fileó (eraså them¬  protecô them¬  renamå them© thaô É 
useä á prefiø tï á filå name.

     Iô  becamå clear¬  then¬  thaô thå DÕ forí waó OK®   É woulä 
establisè á methoä oæ operatioî iî whicè É woulä allocatå  direc
torieó  foò  certaiî functions¬  anä movå intï theså  directorieó 
wheî  É wanteä tï perforí theså functions®   É woulä creatå á  WÓ 
directorù tï worë oî texô files¬ aî ASÍ directorù tï writå assem
blù languagå programs¬  etc®   Iî sucè aî environment¬  mù  humaî 
interfacå waó gooä sincå É agaiî coulä concentratå oî thå probleí 
aô hand¬  thå systeí woulä finä mù commandó foò me¬ anä thå fileó 
É  aí concerneä witè woulä bå thå onlù fileó É seå wheî É displaù 
thå currenô directory®   Á seô oæ utilities¬  however¬ waó needeä 
tï crosó thå directorù boundaries®   Iô woulä alsï bå nicå iæ thå 
ZCPR2-residenô commandó coulä crosó theså boundarieó aô will.

     Sï no÷ wå arå bacë tï thå ZCPR2-residenô commands®  Witè thå 
DÕ  forí accepteä bù alì oæ them¬  directorù boundarieó becamå nï 
probleí aô all®   Iî addition¬ É waó no÷ designinç á seô oæ ZCPR² 
utilitieó  whicè woulä providå á hosô oæ additionaì  capabilitieó 
whicè  madå  iô  easù  tï  perforí  functionó  acrosó   directorù 
boundaries.


2.3  The ZCPR2 Residents Versus the CCP Residents

     Clearly¬ no÷ thå ZCPR² Residenô Commandó caî crosó directorù 
boundarieó aô wilì whilå thå CCĞ Residenô Commandó caî not®  Thió 
ió  aî  instrumentaì  forwarä steğ iî thå  humaî  engineerinç  oæ 
ZCPR2®   Alì  oæ thå ZCPR² Residenô Commandó havå tï dï thió iî á 
consistant¬  simplå way®   Thió simplå waù ió thå DÕ  form®   Thå 
commands now line up like this:

              ZCPR2 Command            CCP Command
               DIR DU:afn               DIR D:afn
               ERA DU:afn               ERA D:afn
               REN DU:ufn1=ufn2         REN D:ufn1=ufn2
               TYPE DU:ufn              TYPE D:ufn
               SAVE n DU:ufn            SAVE n D:ufn
               D:                       D:
               U:                       USER u
               DU:                      --

     Iî  movinç  tï Z80-specifiã code¬  lotó oæ spacå  waó  saveä 
withiî  ZCPR± anä ZCPR2®   Jumğ Relativå instructionó contributeä 
thå mosô tï thió savings¬  aó welì aó constanô restructurinç  anä 
optimizinç  foò  spacå bù combininç functionó intï  onå  routine®  
Witè  sucè  á spacå savings¬  therå waó rooí tï elaboratå oî  thå 
Residenô Commands.

     Iî thå procesó oæ firsô designinç ZCPR± anä lateò ZCPR2¬  iô 
waó obviouó thaô thå CCĞ Residenô Commandó werå nicå tï have¬ buô 
werå incomplete®   Iî ZCPR1¬  É tooë stepó tï makå theí morå com
plete¬  anä iî ZCPR² É tooë furtheò steps®   Thå followinç  para
graphó summarizå thå rationalå behinä thå changes.

     Thå DIÒ commanä undeò CP/Í woulä onlù displaù thå non-Systeí 
Files®   Thió ió typicallù whaô yoõ want¬  buô iô ió nicå tï  seå 
thå Systeí Fileó alsï froí timå tï time®  Undeò CP/M¬ yoõ dï thió 
bù  loadinç á COÍ filå designeä tï perforí thió function®   Undeò 
ZCPR2¬  iô seemeä likå á simplå matteò tï givå ZCPR² itselæ  thió 
capability®   Froí  thió camå thå Ó optioî anä thå Á option®   Tï 
makå  thå  interfacå  aó simplå aó possiblå anä  requirå  aó  fe÷ 
keystrokeó  oî thå parô oæ thå useò aó É could¬  É opteä tï  havå 
theså optionó specifieä bù á spacå followeä bù thå optioî  letteò 
afteò thå firsô "normal¢ parô oæ thå command®   Tï displaù Systeí 
Files¬  then¬  thå useò neeä onlù typå "DIÒ DU:afî S"®   Thå onlù 
tradå  ofæ waó thaô iæ nï afî oò DÕ forí waó specified¬  á filleò 
waó  requireä iæ thå optioî waó desired®   Thió filleò  coulä  bå 
easilù "*.*"¬  buô thå useò haä tï remembeò that®  Otherwise¬ ho÷ 
woulä  DIÒ kno÷ betweeî requestó foò "DIÒ A¢ tï seå iæ filå Á  ió 
therå oò "DIÒ *.ª A¢ tï seå alì files¿  Thió seemeä reasonable.


     Mù  maiî gripå witè thå ERÁ commanä waó thaô iô diä itó  joâ 
silently®   É neveò waó surå oæ whaô iô diä unlesó É issueä á DIÒ 
commanä afterwards®   Hence¬ É addeä aî automatiã DIÒ functioî tï 
ERA®   Iî addition¬ aô verù littlå cost¬ á Verifù optioî coulä bå 
addeä tï allo÷ thå useò tï approvå thå eraså beforå iô waó  done®  
Oæ course¬ thå directorù displaù woulä bå donå first.

     Mù  onlù  complainô abouô REÎ waó thaô yoõ coulä noô  renamå 
over existing files.  I corrected this with ZCPR2.

     Thå  complainô witè TYPÅ ió obvious®   Iô haä tï  page®   Nï 
question®   É  reallù becamå tireä oæ usinç ^Ó tï stoğ outpuô anä 
sometimeó  noô bå quicë enougè tï catcè  everything®   Sometimes¬ 
tho¬  É woulä noô wanô tï page¬  buô skií through®   Havinç á TVÉ 
95° waó nice¬  sincå É coulä uså smootè scrollinç tï skií slowly®  
TYPE¬  then¬  waó  seô uğ tï pagå bù default¬  buô aî  optioî  ió 
availablå tï noô pagå wheî desired.

     LISÔ waó á nicå commanä tï havå thaô cosô little¬ sï whù noô 
have it?  Enough said.

     Thå  biggesô complainô É haä witè SAVÅ waó thå constanô  heø 
tï  decimaì conversioî É waó doinç tï takå numberó  generateä  bù 
DDÔ  anä  uså  theí iî á SAVE®   Sï É addeä á  hexidecimaì  valuå 
optioî tï SAVÅ whilå stilì keepinç thå decimaì optioî foò compat
ibilitù (human-wise).

     GÏ  anä JUMĞ werå addeä becauså (1© theù werå nicå tï  have¬ 
(2© iæ theù werå noô tï affecô thå TPA¬  theù HAÄ tï bå á parô oæ 
ZCPR±  anä  ZCPR2¬  anä (3© theù cosô littlå sincå alì thå  hookó 
werå  alreadù  there®   GEÔ waó addeä bù requesô  sincå  iô  cosô 
littlå  anä  thå  persoî requestinç iô jusô HAÄ tï  havå  it®   É 
personallù neveò uså it.

     Thå followinç tablå compareó thå Residenô Commandó availablå 
under ZCPR2 to those available under the CP/M 2.2 CCP:

ZCPR² Commanä       CCĞ Commanä  | ZCPR² Commanä      CCĞ Command
DIR DU:afn          DIR D:afn    | ERA DU:afn          ERA D:afn
DIR DU:afn S        No Equiv     | ERA DU:afn V        No Equiv
DIR DU:afn A        No Equiv     |
                                 ü REÎ DU:ufn1=ufn²    REÎ D:u=u2
TYPE DU:ufn P       TYPE D:ufn   | REN with Overwrite  No Equiv
TYPE DU:ufn (page)  No Equiv     |
                                 | SAVE n DU:ufn       SAVE n D:u
LIST DU:ufn         No Equiv     | SAVE nH DU:ufn      No Equiv
                                 | SAVE n DU:ufn S     No Equiv
GET adr DU:ufn      No Equiv     | SAVE nH DU:ufn S    No Equiv
                                 |
GO params           No Equiv     | JUMP adr            No Equiv
                                 |
D:                  D:           | U:                  USER n
DU:                 No Equiv     |
Š
2.4  The Structure of ZCPR2

     Foò  thoså familiaò witè thå internaì structurå oæ thå  CP/Í 
2.² CCP¬  yoõ wilì finä thå internaì structurå oæ ZCPR² radicallù 
different®  Iô beginó witè thå samå twï JMĞ instructionó thaô thå 
CP/Í 2.² CCĞ beginó with¬  anä iô may¬  iæ sï configured¬  follo÷ 
theså  instructionó witè á commanä linå buffeò intï whicè maù  bå 
storeä á defaulô command¬ buô thå similaritù endó there.

     É  feeì  thaô thå openinç JMĞ  instructionó  arå  absolutelù 
necessarù  foò  compatabilitù purposes®   Thå  followinç  buffer¬ 
however¬  ió not¬  sincå thió ió aî undocumenteä "feature¢ oæ thå 
systeí iî thå firsô place®  Somå oæ thå publiã domaiî (anä other© 
softwarå uså thió buffer¬  anä thå useò haó thå optioî tï instalì 
iô iæ hå wishes¬  buô sï mucè morå flexibilitù anä capabilitù arå 
deriveä  froí enablinç thå Multiplå Commanä Linå Buffeò  feature¬ 
thaô  É thinë iô ió worthwhilå tï abandoî thå programó whicè  uså 
thió buffeò iî thå ZCPR² environment®  Oæ thå programó É aí awarå 
of¬ thå ZCPR² Systeí provideó equivalentó anyway.

     É aí á stronç proponenô oæ writinç maintainablå software®  É 
believå  iî  designinç softwarå iî thå firsô placå iî sucè á  waù 
thaô  goinç  bacë tï iô aô á lateò timå anä modifyinç iô  caî  bå 
donå witè á minimuí oæ difficulty®  Witè ZCPR2¬ however¬ É foughô 
á battlå iî attemptinç tï writå maintainablå softwarå anä writinç 
space-optimizeä   anä   time-optimizeä   software®    Tï   ensurå 
compatabilitù witè CP/Í 2.2¬  ZCPR² coulä noô exceeä 2Ë byteó  iî 
size¬  sï  manù optimizationó werå performeä thaô saveä oî  spacå 
anä   reduceä   readability®    É  answereä  thió  reductioî   iî 
readabilitù   bù   increasinç  oî  thå   internaì   documentatioî 
(comments)®   Also¬  bù  á modulaò construction¬  É waó  ablå  tï 
producå  morå  maintainablå codå whilå conservinç spacå  iî  somå 
cases.

     Thå openinç commentó iî thå sourcå codå tï ZCPR² outlinå itó 
structure®    Thió   structurå  ió  discusseä  iî  thå  followinç 
paragraphs.

     First¬  thå buffers®   Aó É goô intï thå desigî oæ ZCPR2¬  É 
founä  morå anä morå oæ á neeä tï allocatå buffeò spacå thrõ  thå 
BIOÓ  iî  ordeò  tï providå globaì  bufferó  anä  morå  extensivå 
bufferó thaô weren'ô affecteä bù warí boots®  Hence¬ somå bufferó 
remaineä  iî ZCPR2¬  anä manù werå moveä outside®   Optionó  werå 
retained¬  however¬  tï  allo÷  thå  installeò tï  implemenô  thå 
bufferó  iî  eitheò  way®   Iæ thå bufferó werå  selecteä  tï  bå 
internal¬  however¬  somethinç else¬  likå á feature¬  haä tï  bå 
giveî up®   Thå onlù gooä reasoî É caî seå foò noô implementinç á 
modifieä  BIOÓ  anä  placinç thå recommendeä bufferó  outsidå  oæ 
ZCPR²  itselæ ió becauså thå installeò doeó noô havå  thå  sourcå 
codå tï hió BIOS®  ZCPR² caî bå implementeä withouô modifyinç thå 
BIOS¬ anä somå oæ itó enhanceä featureó wilì bå retaineä bù this¬ 
buô  iô wilì bå á shado÷ oæ whaô iô coulä bå iæ externaì  bufferó 
were available.
Š
     Second¬  thå ZCPR² Startinç Modules®   Alì oæ thå entrù  anä 
reentrù points¬ thå erroò recoverù points¬ anä somå miscellaneouó 
entrieó arå containeä here®  Thió seemeä reasonable.

     Third¬  thå general- anä special-purposå utilities®  Sectioî 
³ containó general-purposå utilities¬ sucè aó consolå output¬ anä 
Sectioî  ´ containó special-purposå utilities¬  sucè á SBLANË  tï 
skiğ blankó foò parsinç purposes®  Thå commanä linå parseò itselæ 
ió classeä aó á special-purposå utility®   Aó á rule¬ iæ É wanteä 
á  functioî tï bå performeä morå thaî oncå anä itó sizå  exceedeä 
threå bytes¬ iô waó madå intï á subroutinå tï conservå space®  Iæ 
thå  sizå oæ thå codå requireä tï perforí thå functioî waó  threå 
byteó oò less¬ theî iô waó simplù duplicateä wherå iô waó needed®  
Iî  considerinç  designó  likå  this¬  É camå uğ  witè  á  simplå 
formula set:

          Cost of Inline Function =
               (number of bytes required)
             * (number of times function was used)

          Cost of Subroutine Function =
               (number of bytes required + 1 [for RET instruction])
             +
               3 [number of bytes required for a subroutine CALL]
             * (number of times function was used)

     Iæ  N=numbeò oæ byteó requireä foò functioî anä T=numbeò  oæ 
times function was used, then the formulae are:

          Cil = NT
          Csb = (N + 1) + 3T

     Clearly, NT < (N+1) + 3T if T=1.  If T=2, then:

          N    Cil=NT    Csb=(N+1)+3T
          1       2         8
          2       4         9
          3       6        10
          4       8        11
          5      10        12
          6      12        13
          7      14        14

     Foò  N>¸ anä T=2¬  Ciì costó morå thaî  Csb®   Iæ  T=3¬  Ciì 
exceeds Csb more quickly:

          N    Cil=NT    Csb=(N+1)+3T
          1       3        11
          2       6        12
          3       9        13
          4      12        14
          5      15        15

     For N>5 and T=3, Cil costs more than Csb.Š
     Iî  á nutshell¬  theså tableó arå sayinç thaô thå borderlinå 
caså  ió wheî thå numbeò oæ timeó thå routinå ió useä  ió  twice¬ 
anä  iæ thå routinå containó morå thaî · byteó (thinë oæ thió  iî 
termó  oæ twï subroutinå calló anä onå byte)¬  theî wå arå  aheaä 
makinç  thió  intï  á  subroutinå ratheò thaî  placinç  thå  codå 
inline.

     Hence¬  thå readeò caî no÷ seå thå reasoninç behinä  placinç 
code inline or making it into a subroutine.

     Finally¬  thå  Residenô  Commandó takå uğ thå lasô  parô  oæ 
ZCPR2®   Theså  arå  divideä intï theiò owî  sections¬  buô  somå 
overlağ exists®  Thå routinå whicè displayó filå nameó (DIRPR© ió 
useä bù DIÒ anä bù ERA¬  foò instance®  Likewise¬ MLOAÄ (loaä COÍ 
file into memory) is used by COM and GET.

     Tï  simplifù thå installatioî procedurå anä tï furtheò modu
larizå  thå  desigî oæ ZCPR2¬  É createä á separatå  headeò  filå 
(ZCPRHDR.LIB©  whicè containó alì oæ thå  customizatioî  informa
tion®   Itó purposå ió two-foldº  (1© tï brinç ouô thå configura
tioî  informatioî iî á smalì filå thaô ió easù tï ediô anä (2© tï 
identifù anä providå tï thå useò everù iteí oæ ZCPR² thaô hå  maù 
wisè tï changå tï meeô hió owî desires®   Again¬ É aí solä oî thå 
ideá oæ bendinç thå systeí tï meeô youò desireó aó opposeä tï thå 
otheò waù around.



2.5  The ZCPR2 Alternate Commands

     Therå  ió á subseô oæ thå ZCPR2-supplieä transientó  thaô  É 
calì  thå  ZCPR²  Alternatå Commandó becauså theù  duplicatå  thå 
functionó   oæ  thå  ZCPR²  Residenô  Commandó  witè   signficanô 
enhancementó  iî capability®   Theså commandó anä  thå  residentó 
they duplicate are:

             ZCPR2 Alternate          ZCPR2 Resident
               XDIR3                    DIR
               ERASE                    ERA
               RENAME                   REN
               PAGE                     TYPE
               PRINT                    LIST



     DIÒ  ió nice¬  buô iæ yoõ arå lookinç aô á loô oæ  files¬  á 
"random¢  listinç oæ nameó doesn'ô helğ much®   XDIR³  sortó  thå 
filå  listinç bù namå anä typå oò typå anä namå (sometimeó É wanô 
iô  onå waù tï seå commonly-nameä fileó anä sometimeó É  wanô  iô 
thå  otheò  waù  tï seå commonly-typeä files¬  anä É  prefeò  thå 
latteò  mosô  oæ thå time)®   Iô alsï displayó thå sizå  oæ  eacè 
file¬  thå totaì spacå takeî uğ bù thå fileó displayed¬  anä  thå 
amounô  oæ spacå remaininç oî disk®   Iô provideó á hosô oæ otheò 
nice¬  extendeä functionó aó well®   Onå keù thinç É wanteä XDIR³ 
tï  dï thaô nï otheò publiã domaiî directorù displaù prograí  diä 
waó  tï crosó directorù boundarieó witè thå DÕ forí anä  thå  DIÒ 
forí aó well®  XDIR³ doeó this¬ anä addó tï thå continuitù oæ thå 
ZCPR²  Systeí  aó such®   Finally¬  XDIR³ alsï haó filå  scanninç 
capabilitù  builô  iî sï thaô configuratioî changeó caî  bå  morå 
easilù detected.

     Alonç  thå lineó oæ DIR¬  ERÁ serveó á  purpose¬  buô  ERASÅ 
enhanceó  this®   ERASÅ  wilì onlù "see¢ non-Systeí Fileó  unlesó 
tolä  tï  looë aô Systeí Fileó also¬  anä iô haó thå  abilitù  tï 
eraså Read/Onlù fileó anä tï allo÷ thå useò tï inspecô eacè  filå 
beforå thå eraså ió performed.

     RENAMÅ  ió  tï REÎ aó ERASÅ ió tï ERA®   RENAMÅ allowó  wilä 
cards¬  inspection¬  anä otheò optionó aó well®   Likå alì oæ thå 
Alternatå commands¬ botè thå DÕ anä DIÒ formó arå supported.

     PAGÅ  anä PRINÔ arå thå alternateó tï TYPÅ anä  LIST®   PAGÅ 
provideó  optionó  foò speeä controì eô al¬  anä  PRINÔ  supportó 
paging¬ timå anä datå stamping¬ headers¬ pagå and/oò linå number
ing¬ anä otheò features.

     Onå featurå É feeì ió signficanô ió thaô oæ permittinç listó 
oæ ambiguouó filå nameó aó argumentó foò ERASE¬  RENAME¬ PROTECT¬ 
PAGE¬ PRINT¬ anä manù otheò ZCPR2-supplieä utilities®  Thió giveó 
thå  useò thå flexibilitù oæ performinç manù similaò functionó iî 
onå commanä aó opposeä tï reissuinç thå commanä oò usinç GO.


     Aó  timå  wenô  along¬  É founä iô morå anä morå  usefuì  tï 
includå  onlinå documentatioî builô intï thå commandó  themselveó 
sï  thaô thió informatioî coulä bå quicklù accessed®   É haä  al
readù adopteä thå conventioî iî whicè commanä lineó whicè consis
teä  oæ á commanä anä optionó onlù woulä prefiø thå  optioî  lisô 
witè á slasè tï distinguisè thå optionó froí á filå name®   This¬ 
oæ course¬ prohibiteä usinç thå slasè aó thå firsô characteò oæ á 
filå name¬  buô É didn'ô thinë thaô thió waó toï restrictive®  Aó 
á logicaì extensioî tï this¬  thå commandó werå designeä tï prinô 
á  helğ messagå iæ anù invaliä optioî waó encountered¬  anä ¯  ió 
neveò  permitteä tï bå aî option¬  sï mosô commandó  consistentlù 
prinô  ouô á helğ messagå wheî á commanä oæ thå forí "CMNÄ //¢ ió 
issued®   Thió ió iî additioî tï thå onlinå documentatioî  avail
ablå viá thå HELĞ command.

2.6  Abandoning ^P

     This¬  oæ course¬  ió á recommendation¬  buô iô ió madå witè 
thå vie÷ oæ thå ZCPR² Systeí iî mind®   Undeò CP/Í 2.2¬ É diä noô 
likå  thå  ^Ğ functioî becauså É considereä iô tï bå  unreliable®  
Iî onå case¬  iæ yoõ issueä ^Ğ jusô beforå givinç á command¬  thå 
commanä  woulä ruî aó desired¬  but¬  wheî thå  prompô  appeared¬ 
dependinç  oî  thå command¬  sometimeó thå ^Ğ woulä stilì  bå  iî 
effecô anä othertimeó iô woulä not®  Iî anotheò case¬ iæ á loadeä 
transienô (likå DU¬  whicè ió whù DÕ haó á Ğ command© useä direcô 
BIOÓ calló foò I/O¬  theî thå ^Ğ woulä bå ignoreä anä thå desireä 
effecô noô obtained.

     Onå finaì poinô againsô ^Ğ ió thaô ZCPR² occasionallù  sendó 
characteró witè thå mosô significanô biô seô tï thå screen®   Thå 
prompô  ió onå example¬  anä iô doeó thió foò ZEØ  compatability®  
Iæ ^Ğ ió useä anä youò printeò respondó tï commandó whicè involvå 
byteó witè thå mosô significanô biô set¬ theî thå printeò wilì dï 
strangå thingó froí timå tï timå undeò ^Ğ control.

     Wheî lookinç aô ZCPR² aó á System¬  manù ZCPR² utilitieó uså 
direcô  BIOÓ calló anä woulä noô bå affecteä bù ^P®   SYSLIÂ  2.´ 
alsï supportó I/Ï viá direcô BIOÓ calló extensively¬  sï programó 
usinç SYSLIÂ maù oò maù noô responä tï ^P.

     Ho÷ ió á functioî likå ^Ğ obtained¬ then¿  Undeò ZCPR² iô ió 
simplå  -- redirectablå  I/O®   Simplù seô uğ á redirectablå  I/Ï 
driveò thaô caî bå assigneä tï thå consolå whicè consistó oæ  CRÔ 
Inpuô  anä CRT/Printeò Output¬  anä havå thaô driveò masë ouô thå 
mosô significanô biô oæ alì characteró senô tï thå printer®  Thió 
solveó  thå  printeò probleí anä alsï provideó á  reliable“  prinô 
controì facility®   Iô ió invokeä onlù wheî thå indicateä consolå 
assignmenô (viá DEVICE© ió made¬  anä iô ió disengageä onlù  wheî 
anotheò  assignmenô  ió  made®   Yoõ caî eveî tiå iî  thå  RECORÄ 
facilitù  tï controì thió iæ desired¬  allowinç thå routineó  en
gageä bù RECORÄ tï turî oî anä ofæ printeò output.


3.0  The ZCPR2 System

     Afteò thå initiaì desigî oæ ZCPR² anä somå oæ itó utilities¬ 
iô becamå appearanô thaô ZCPR² waó noô á stand-alonå entitù  likå 
ZCPR± was®  Instead¬ ZCPR² waó thå huâ oæ aî integrateä systeí oæ 
programó  thaô communicateä witè eacè otheò througè ZCPR²  itselæ 
anä thå bufferó associateä witè ZCPR2.


3.1  Implementing the Named Directories

     Wheî  thå  ideá oæ nameä directorieó firsô camå  up¬  É  waó 
toyinç  witè thå ideá oæ á CHDIÒ commanä tï loç intï á  directorù 
bù name®   Thió commanä waó neveò releaseä witè ZCPR2¬  buô ideaó 
froí iô werå incorporateä intï thå CD¬  MKDIR¬  anä PWÄ commands®  
Iî ordeò tï deaì witè á mnemoniã namå whicè stooä foò á disk/useò 
area¬  aî  associatioî tablå haä tï bå createä whicè paireä nameó 
tï theiò directories®  Sincå CHDIÒ waó thå onlù prograí involved¬ 
iô waó easù tï placå thió tablå intï CHDIR.

     Aó timå wenô along¬  however¬  thå ideá tï allo÷ á numbeò oæ 
commandó referencå directorieó bù namå developed®   Thå olä tech
niquå  oæ continuinç tï storå thå nameó aó parô oæ CHDIR.COÍ  waó 
ruleä ouô foò severaì reasons:

          (1©  unlesó  stepó werå taken¬  aó CHDIÒ  changed¬  thå 
positioî  oæ  thå  namå  tablå maù  changå  aó  welì  (CHDIÒ  waó 
originally written in BDS C)

          (2©  foò onå reasoî oò anotheò (sucè aó security)¬  thå 
namå  oæ CHDIR.COÍ maù noô alwayó bå CHDIÒ -- iô coulä bå  CÄ  oò 
some other shorter name

          (3© CHDIÒ waó largå (duå tï thå overheaä oæ BDÓ C)¬ anä 
É  waó discoverinç (thrõ experimentation© thaô utilitieó  writteî 
witè  SYSLIÂ coulä bå aó mucè aó 1/´ thå sizå oæ similaò utiltieó 
written with BDS C

     Á  reasonablå  steğ  froí  thió poinô  waó  tï  establisè  á 
structurå  foò á directorù filå whicè containeä thå mnemoniã  anä 
user/disë associatioî information®  Alonç witè thió camå MKDIÒ tï 
creatå anä ediô sucè á filå anä CÄ tï replacå CHDIR®  Afteò á loô 
oæ  uså  witè thió typå oæ environment¬  however¬  É  founä  thaô 
constantlù   accessinç  thå  disë  tï  determinå  thå  nameó   oæ 
directorieó  requireä  quitå á biô morå timå tï perforí eveî  thå 
basiã functions®  Sincå É waó alreadù placinç somå ZCPR2-specifiã 
bufferó iî memorù (sucè aó thå multiplå commanä linå  buffer)¬  É 
electeä  tï  incorporatå  aî optioî iî whicè  á  nameä  directorù 
buffeò  maù  bå  loadeä  froí  disë anä  searcheä  firsô  bù  thå 
utilitieó  wheî  resolutioî  oæ  á  namå  waó   required®    Thió 
significantlù  speedeä  thingó  uğ anä addeä  thå  fixed¬  globaì 
directorù  concepô tï thå system®


     NAMES.DIÒ  no÷ becamå á locaì directorù concepô anä coulä bå 
useä tï implemenô differenô locaì directorù environó aó thå  useò 
moveä froí onå directorù oò commanä searcè patè tï another.

     No÷  wå havå thå flexibilitù oæ botè locaì anä globaì  nameä 
directorieó  undeò  ZCPR2®   Thå SYSLIÂ routineó whicè  performeä 
directorù searcheó foò må werå altereä tï utilitizå thió feature¬ 
and¬ oncå SYSLIÂ waó altered¬ alì utilitieó werå altereä aó well®  
The algorithm now employed in SYSLIB is:

          (1© Checë tï seå iæ thå directorù speã ió á DÕ forí anä 
use it if so

          (2© Assumå iô tï bå á DIÒ forí iæ noô DU¬  anä scaî thå 
memory-baseä nameä directorù buffeò foò á matcè iæ therå ió  one» 
if one is found, go with it

          (3©  Iæ therå ió nï memory-baseä nameä directorù buffeò 
oò  therå ió nï matcè iî it¬  scaî alonç thå commanä searcè  patè 
(oò whateveò patè waó specifieä tï thå library© foò thå NAMES.DIÒ 
file»  iæ found¬  loaä anä scaî iô foò thå specifieä namå anä  gï 
with it if found

          (4) If 1, 2, and 3 fail, return with an error code

     É  aí pleaseä witè thió desigî foò itó flexibilitù  anä  itó 
abilitù  tï rapidlù changå thå user'ó visiblå directorù  environ
menô aó hå moveó froí onå directorù tï another.



3.2  Common ZCPR2 Transient Structures and GENINS

     SYSLIÂ  waó  alreadù useä extensivelù iî thå desigî  oæ  thå 
ZCPR²  utilitù programó wheî É decideä tï adopô á standarä buffeò 
structurå  aô  thå beginninç oæ  thå  utilities®   Thió  standarä 
structurå waó á gooä ideá foò severaì reasons:

          (1©  aî installatioî prograí (GENINS© coulä bå designeä 
whicè  coulä bå useä tï customizå alì thå utilitieó  withouô  thå 
neeä foò reassembly

          (2©  certaiî  basiã informatioî waó needeä bù alì  pro
grams¬  anä  thå  utilitieó coulä bå configureä  tï  individuallù 
contaiî thió informatioî iî á uniforí waù oò tï poinô tï  bufferó 
containinç  thió information»  sucè informatioî includeó thå add
resó  oæ  thå multiplå commanä linå buffer¬  thå  addresó  oæ  aî 
externaì  path¬  anä  thå addresó oæ á nameä directorù buffeò  iæ 
therå waó one


          (3©  á SYSLIÂ routinå coulä bå establisheä  thaô  woulä 
uniformlù  initializå  alì  necessarù SYSLIÂ bufferó  withouô  mù 
havinç  tï  worrù abouô correctlù initializinç eacè  buffeò  eacè 
timå  É  designeä á ne÷ utility»  thió SYSLIÂ routinå  ió  ZGPINÓ 
(General-Purposå  Installation© anä neeä onlù bå calleä  oncå  aô 
thå beginninç oæ eacè utility

     Thå commoî buffeò structurå waó extendeä tï includå á commoî 
utilitù structurå later¬ anä thå filå TEMPLATE.MAÃ ió provideä tï 
allow the programmer to program ZCPR2 utilities more easily.


3.3  Multiple Command Line Buffer

     Froí thå beginning¬ É simplù envisioneä thå Multiplå Commanä 
Linå  Buffeò foò itó originaì purposå -- tï providå á gooä  placå 
tï  storå á commanä linå sï multiplå commandó coulä bå  executed®  
Thió ió welì anä good¬  anä thå multiplå commanä featurå ió quitå 
nice.  I use it all the time myself.

     Whaô  waó  funnù abouô thió particulaò featurå oæ thå  ZCPR² 
Systeí  ió  thaô  thå abilitù tï uså thió buffeò tï  chaiî  tï  á 
serieó oæ programó rapidlù becamå morå important¬  froí mù  poinô 
oæ  view¬  thaî  itó  originaì purpose®   Iæ á utilitù  kne÷  thå 
locatioî  oæ  thió buffer¬  iô coulä storå á commanä linå  iî  iô 
(containinç multiplå commandó iæ desired)¬  seô á pointeò tï  thå 
firsô characteò oæ thå firsô command¬ anä ruî thió commanä streaí 
bù  simplù returninç tï ZCPR2®   Verù cleaî anä efficienô waù  tï 
chain¬  anä  iô  madå thå desigî anä implementatioî oæ  thå  MENÕ 
system very simple.

     Witè MENU¬  iô ió desireä tï ruî á commanä anä alwayó returî 
tï  thå MENU®   Beinç ablå tï chaiî tï á commanä streaí madå thió 
simplå  -- allo÷ MENÕ tï builä á commanä linå consistinç  oæ  thå 
desireä  commanä  followeä bù thå commanä "MENÕ  options"¬  wherå 
optionó woulä bå useä tï reenteò MENÕ aô thå correcô point®  Thió 
waó simplicitù itself¬  anä É alreadù haä designeä á simplå  menõ 
systeí  iî  ZMCPÒ  (whicè waó á menu-baseä ZCPÒ  thaô  waó  neveò 
released)®  É builô upoî ZMCPÒ conceptó anä camå uğ witè thå MENÕ 
program with MCHECK in a very short time.


3.4  SYSLIB

     Onå  brieæ  mentioî herå abouô SYSLIÂ 2.4®   Aó É  goô  intï 
designinç ZCPR² utilitieó morå anä more¬  thå valuå oæ SYSLIÂ waó 
proveî  oveò anä oveò again®   É kne÷ SYSLIÂ intimately¬  witè aî 
understandinç  oæ  ho÷ thå routineó fiô  together¬  and¬  oncå  É 
decideä upoî á functioî É wanteä tï perform¬  iô tooë verù littlå 
timå tï desigî iô witè SYSLIB®  Bù thå enä oæ thå desigî phaså oæ 
thå ZCPR² System¬  É spenô aî averagå oæ ² houró tï desigî á  ne÷ 
utilitù   froí  scratch¬   anä  thió  waó  withouô  thå  uså   oæ 
TEMPLATE.MAC¬  whicè  waó  onå oæ thå lasô thingó É designeä  foò 
ZCPR2.Š
     Iô  seemeä  reasonablå tï tiå SYSLIÂ intï thå  ZCPR²  Systeí 
morå closelù tï makå thå developmenô procesó eveî morå efficient®  
Iî  thió light¬  É designeä twï SYSLIÂ moduleó whicè interfacå tï 
the ZCPR2 System and provide ZCPR2-specific functions.

     ZGPINÓ ió thå installatioî routinå whicè initializeó alì  oæ 
thå internaì datá areaó oæ theså twï ZCPR2-specifiã modules®  Thå 
fronô  oæ  eacè oæ thå ZCPR² utilitieó ió uniforí betweeî alì  oæ 
thå standarä utilities¬  anä thå positioî oæ thå buffeò datá herå 
ió thå samå betweeî alì oæ thå utilities®  ZGPINÓ knowó abouô thå 
structurå anä readó datá froí it¬ feedinç thió datá tï thå SYSLIÂ 
modules.  This data falls into eight functional areas:

          1®  Pathó -- ió aî externaì patè available¬ and¬ iæ so¬ 
wherå ió iô located¿   Á requirementó flaç ió presenô whicè telló 
ZGPINÓ iæ patè informatioî ió useä bù thå particulaò utility®   Á 
parô  oæ thå standarä buffeò configuratioî includeó  aî  internaì 
patè  whicè maù bå useä iî placå oæ oò tï supplemenô thå externaì 
path®   Naturally¬ eacè utilitù caî havå itó own¬ uniquå internaì 
path®   Onlù  thå  HELĞ utilitù useó botè externaì  anä  internaì 
paths¬  wherå  iæ  á searcè alonç thå  externaì  patè  fails¬  iô 
switcheó  tï searchinç alonç thå internaì patè beforå givinç  up®  
The other utilities search along only one path or the other.

          2®   Multiplå  Commanä  Linå Buffeò -- ió  thió  buffeò 
available¬  and¬  iæ so¬ wherå ió iô located¿  Again¬ aó witè alì 
oæ  theså  majoò  functionaì sections¬  á  requirementó  flaç  ió 
availablå  tï indicatå iæ thió datá ió useä bù thå  program®   Iæ 
so¬  ZGPINÓ initializeó thå SYSLIÂ bufferó accordingly®   Iæ not¬ 
it does not touch the SYSLIB buffers.

          3®   Maximuí  Useò  anä  Disë -- whaô arå  thå  maximuí 
numbeò  oæ diskó availablå anä thå maximuí useò areá  accessable¿  
Twï byteó arå allocateä tï providå thió information¬  anä á thirä 
requirementó  bytå  telló  ZGPINÓ  iæ  thå  utilitù  needó   thió 
information.

          4®   Allo÷  Disë  oò Useò Changå -- ió thå useò  tï  bå 
permitteä  tï  referencå á differenô useò areá oò tï referencå  á 
differenô disk¿   Again¬  á requirementó bytå ió alsï  available®  
Utilitieó  whicè paù attentioî tï theså bufferó caî bå seô uğ  tï 
allo÷ thå useò tï referencå anù useò areá oî thå currenô disë buô 
noô  anù otheò disë oò tï referencå thå currenô useò areá oî  anù 
disë buô noô thå currenô disk®  Iæ nameä directorieó arå enabled¬ 
á DIÒ forí ió permitteä regardless¬ buô elementó oæ á DÕ forí maù 
bå  disabled®   Hence¬  iæ  JEFÆ  ió knowî tï thå useò  froí  hió 
currenô  directory¬  hå caî referencå thió directorù bù thå  namå 
JEFÆ buô noô bù itó DÕ form®  É diä thió tï allo÷ flexibilitù anä 
security at the same time.

          5®   Baså oæ Privilegeä Useò Areaó anä Passworä -- whaô 
ió thå firsô privilegeä useò areá (thió areá anä alì useò numberó 
greateò  thaî  thió becomå privileged© anä whaô ió  thå  passworä 
required to enter or reference it?Š
          6®  Currenô User/Disë Indicatoò anä DMÁ Addresó -- thió 
permitó non-standarä valueó foò theså itemó tï bå selecteä foò  á 
particulaò utility®   Thå DMÁ Addresó ió oæ speciaì concerî sincå 
thå SYSLIÂ moduleó assumå 80È unlesó tolä otherwise¬  and¬ iæ thå 
programmeò  changeó  thió iî thå courså oæ thå utility¬  hå  MUSÔ 
inforí  SYSLIÂ oæ thå ne÷ DMÁ addresó sï thaô iô caî continuå  tï 
function.

          7®   Nameä  Directorù  Buffeò anä  Filå  Datá  -- theså 
bufferó  providå thå addresó oæ thå memory-baseä nameä  directorù 
buffeò  (oò  °  iæ  nonå ió available)¬  thå  maximuí  numbeò  oæ 
directorù entrieó permitteä iî á nameä directorù buffeò oò  file¬ 
anä thå namå oæ thå disk-baseä nameä directorù filå tï searcè foò 
iæ necessarù (NAMES.DIÒ ió assumed)®   Again¬ á requirementó flaç 
indicateó iæ thió ió necessarù foò thå utility®   GENINÓ installó 
thió  datá  anä  promptó  thå useò foò thió  datá  baseä  oî  thå 
settings of these requirements flags.

          8®  Clasó oæ Utilitù -- thió ió á one-bytå buffeò whicè 
ió useä bù GENINÓ tï determinå iæ speciaì installatioî operationó 
arå  tï bå performed®   Iæ so¬  thió buffeò ió followeä (oveò  1µ 
byteó  later©  bù  thå speciaì bufferó specifiã tï  thaô  utilitù 
which are to be installed.

     Finally¬  SYSLIB¬  aó mentioneä before¬  provideó á grouğ oæ 
routineó   iî  itó  twï  moduleó  whicè  providå   ZCPR2-specifiã 
functions®   Theså  includå  resolutioî oæ DIÒ  formó  anä  otheò 
usefuì functions®   Thå readeò ió inviteä tï studù thå SYSLIÂ 2.´ 
manualó  anä  tï examinå thå sourcå codå oæ thå utilitieó tï  seå 
ho÷  theså routineó comå intï play®   Theù reallù savå á  loô  oæ 
programminç  overheaä anä fiô iî nicelù togetheò aó aî integrateä 
set of utility routines.




3.5  Redirectable I/O

     Redirectablå   I/Ï  aó  implementeä  undeò  ZCPR²  viá   thå 
IOLOADER¬  DEVICE¬  anä  SYSIÏ programs/moduleó meetó á numbeò oæ 
needó  iî thå ZCPR² environment®   Thå requirementó satisfieä  bù 
this redirectable I/O system include:

          (1©   thå  abilitù  tï  dynamicallù  changå   thå   I/Ï 
environment®  Specializeä devicå driveró caî bå addeä aô wilì anä 
changeä  wheneveò  desired¬  anä  thå I/Ï systeí caî bå  madå  aó 
compleø  aó desireä withouô regarä tï thå amounô oæ memorù  takeî 
uğ  sincå á varietù oæ driveró caî bå implementeä  aó  disk-baseä 
packages which are loaded only when needed.

          (2©  thå  abilitù  tï  refeò tï thå I/Ï  driveró  bù  á 
mnemoniã namå anä tï bå ablå tï easilù determinå whaô driveró arå 
currentlù  availablå anä whaô theù do®   Thå DEVICÅ  prograí  waó 
designed explicitly for this purpose.Š
          (3©  thå  abilitù tï implemenô aó compleø á seô oæ  I/Ï 
driveró  aó  desireä  withouô beinç  concerneä  abouô  thå  spacå 
limitationó oæ thå systeí tracks®  Thå maiî OÓ caî bå loadeä froí 
thå  systeí  trackó witè á minimuí oæ I/Ï supporô  (say¬  consolå 
only)¬  anä  thå defaulô I/Ï driveró caî bå immediatelù  overlaiä 
(by an IOLOADER command in a STARTUP.COM file).



3.6  ZCPR2 Utility Overview

     É  thinë  thaô thió topiã haó beeî beateî tï  deatè  iî  thå 
Conceptó Manuaì anä thå User'ó Guide¬ buô twï pointó tï emphasizå 
herå  arå thaô (1© thå ZCPR² utilitù programó arå clearlù divideä 
intï  classes¬  eacè meetinç needó iî specifiã functionaì  areas¬ 
anä (2© thå keù issueó arå systeí  flexibility¬  mutability¬  anä 
susceptabilitù tï thå user'ó whims®  ZCPR² ió intendeä tï bå useä 
aó á tooì whicè increaseó thå user'ó productivity¬  and¬ aó such¬ 
it can be bent to meet the user's demands.

     The major classification areas of the utilities are:

          o I/O                    o Command Files
          o Directories            o Named Directories
          o Disk Utilities         o ZCPR2 Residents and Alts
          o Library Utilities      o Help (Online Documentation)
          o Menu Preprocessor      o File Comparison Utilities
          o File Copy Utility      o Misc

     Iî  thå areá oæ I/O¬  á redirectablå I/Ï systeí ió outlined¬ 
allowinç  thå  useò tï seô uğ aó manù I/Ï driveò packageó  aó  hå 
wishes®   Thå systeí ió baseä oî nameä devices¬  anä thå useò caî 
no÷  redirecô  I/Ï  bù  name¬  ratheò  thaî  havinç  tï  remembeò 
arbitrary mnemonics for implementation-specific devices.

     Thå XDIR³ utilitù allowó thå useò tï displaù thå contentó oæ 
onå oò morå directorieó iî á numbeò oæ formats¬  dependinç oî hió 
tastå anä needó aô thå time®  Iô alsï provideó foò á filå scanneò 
which can be used to keep track of files for him.

     DU² ió á handù tooì tï havå around®   Iô allowó thå useò  tï 
manipulatå  disë  likå DDÔ allowó hií tï manipulatå  memory¬  anä 
accidentiaì  filå erasureó anä thå likå caî bå correcteä  withouô 
any damage being done.

     Thå  LÕ utilitù waó á gooä idea¬  anä LRUNÚ anä LDIRÚ extenä 
thió ideá tï bå morå practicaì iî thå ZCPR² environment®  Partic
ularly¬ theså providå thå baså foò aî extendeä commanä processor®  
Thå  uså  oæ pathó makeó LRUNÚ stanä ouô  froí  itó  predecessor¬ 
LRUN.


     Thå  menõ  systeí standó ouô aó á nicå waù tï  simplifù  thå 
user'ó interface®   É likå thå ideaó oæ havinç multiplå menuó anä 
noô  beinç  lockeä intï anù onå menõ aó beinç twï oæ  thå  stronç 
pointó oæ thió idea®  Iî particular¬ yoõ caî movå froí onå direc
torù  tï thå next¬  automaticallù movinç intï anä ouô oæ menuó aó 
yoõ go.

     Thå  filå  comparå utilitieó arå convenienceó iî  thå  ZCPR² 
environment®   Theù shinå iî beinç ablå tï crosó directorù  boun
daries®   CRÃ provideó nameä directories¬  filå lists¬  anä otheò 
nicå functionó noô founä iî CRCK¬ itó conceptuaì (buô noô design© 
predecessor.

     MCOPÙ  ió instrumentaì iî openinç uğ directorieó beyonä useò 
15®   Witè it¬  yoõ caî copù bù DÕ oò DIÒ forí intï virtuallù anù 
directorù froí anù directory.  MCOPY is also used for backup.

     Commanä  filå processinç ió extendeä bù SUB² anä  ZEX¬  witè 
morå anä morå emphasió beinç placeä oî ZEX®  Thå speeä anä flexi
bilitù oæ ZEØ seeí tï greatlù outweigè thå losó oæ TPÁ aó  advan
tages.

     Nameä  directorieó  puô  á wholå ne÷ lighô  oî  thå  system¬ 
makinç iô mucè morå useò friendlù anä offerinç leveló oæ securitù 
noô founä before.

     Thå ZCPR² Residentó anä Alternateó nicelù extenä basiã capa
bilitieó frequentlù needeä bù thå user®   Therå ió stilì rooí foò 
improvement¬  however®  Beinç ablå tï handlå nameä directorieó bù 
thå residenô commandó woulä bå nice¬  anä beinç ablå tï uså á DIÒ 
forí  whereveò  á DÕ forí applieó woulä bå verù  nice®   PATÈ  ió 
instrumentaì iî establishinç anä changinç commanä anä file-searcè 
environs¬ anä GENINÓ makeó thå installatioî procesó mucè simpler.

     Onlinå documentatioî aó provideä bù HELP² ió verù nice¬ but¬ 
unfortunately¬  á  luxurù permitteä onlù tï thoså whï havå á sig
nificanô  amounô  oæ disë spacå iî whicè  tï  work®   Thå  systeí 
reallù  shineó wheî yoõ caî calì uğ helğ wheî yoõ arå iî develop
ment¬  anä  changinç  diskó (aó woulä bå necessarù oî  á  smalleò 
system©  tï finä thå appropriatå helğ filå reduceó thå utilitù oæ 
the system.

     Onå  iteí  tï notå iî closinç ió thaô É  havå  attempteä  tï 
desigî  manù oæ theså utilitieó tï bå immunå froí changeó iî  thå 
disë environmenô whilå theù arå running®  MCOPY¬ foò instance¬ iî 
thå Multiplå Copù Modå (Í option© allowó thå useò tï changå diskó 
without having to warm boot between each group of files copied.
.paŠ4.0 What next?

     Gooä question® Well¬ firsô oæ all¬ É woulä likå tï emphasizå 
two points:

          (1© thå ZCPR² Systeí ió probablù noô perfect® Therå arå 
bounä tï bå erroró whicè sho÷ themselveó iî thå codå froí timå tï 
time®   Anù  softwarå oæ sucè complexitù ió bounä tï havå theí bù 
its very complex nature.

          (2© thå ZCPR² Systeí ió likelù tï mutatå again®  Iô waó 
designeä from¬  amonç otheò things¬  á lacë oæ satisfactioî  witè 
CP/Í anä ZCPR1¬  and¬  aó ZCPR² ió useä morå anä more¬  ne÷ ideaó 
arå  bounä  tï  comå uğ aó tï ho÷ tï dï thingó betteò oò  ho÷  tï 
refinå   currenô  ideaó  tï  makå  thå  useò   environmenô   morå 
productive.

     Iî  thå waù oæ fixeó tï thå ZCPR² System¬  periodiã  updateó 
arå  tï  bå expected®  Hopefully¬  tho¬  notationó oî thå  erroró 
encountereä  wilì bå accumulateä anä thå systeí wilì  bå  updateä 
onlù  oî occasioî iî responså tï á numbeò oæ errors®  Thió ió  aó 
opposeä  tï updatinç thå systeí everù timå someonå findó aî erroò 
oò  decideó  hå  wantó tï makå á  changå  tï  it®   Additionally¬ 
configuratioî  managemenô  controló should¬  iî  mù  opinion¬  bå 
applied¬  witè formaì procedureó foò erroò analysis¬ duplication¬ 
correction¬  changå proposaì submission¬ anä redistribution® Thió 
wilì probablù noô happen¬  simplù becauså oæ thå amounô oæ efforô 
involved¬  buô froí mù professionaì experiences¬ É feeì thaô thió 
is a key way to satisfactorily maintain the ZCPR2 System.

     Aó foò mutation¬  iô ió good¬  aó á rule®  Naturaì Selectioî 
allowó  thå strongesô traitó tï flourisè whilå thå weakeò  traitó 
diå out¬ anä É feeì thaô thå samå shoulä bå truå oæ software® Thå 
gooä  ideaó  shoulä bå nurtureä anä elaborateä oî whilå  thå  baä 
ideaó shoulä bå noted¬  learneä from¬  anä discarded®  Thå resulô 
is a better productive environment as time goes along.

     Onå  thinç abouô thå Publiã Domaiî thaô É aí reallù solä  oî 
ió thå learninç environmenô thaô iô fosters®  Peoplå caî takå thå 
sourcå  codå tï programó anä learî ho÷ theù  function®  Theù  caî 
theî  uså thió knowledgå tï makå thå programó "better¢ ("better," 
oæ  course¬  ió á subjectivå concept)®  Thå poinô ió thaô  peoplå 
learî  anä  froí froí this®   Thaô ió good®  Aó  thå  readeò  haó 
probablù  alreadù  noted¬  thå  entirå sourcå codå tï  thå  ZCPR² 
Systeí  anä  SYSLIÂ ió availablå foò peoplå tï  studù  anä  learî 
from®  Thió  codå  maù noô bå thå best¬  buô iô ió good¬  anä  iô 
provideó á good¬  fairlù well-documenteä baså froí whicè tï starô 
the learning process.

     Enjoy!

                                        Richard Conn
