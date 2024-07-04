.po10

AUTOMATION¡  LEÔ YOUÒ OLÄ CP/Í KAYPRÏ DÏ IÔ FOÒ YOU.
by Dave Green, KUAFC, September 1987

(Tips on auto-start at bootup)

Thå  dedicateä worä processoò É uså aô worë startó automatically®  
Well¬  almosô automatically®   É turî oî thå switch¬ poğ iî aî 8¢ 
disk¬  waiô  á fe÷ seconds¬  anä thå machinå presentó må  witè  á 
blanë  page¬  readù  anä waitinç foò thå wordó tï  starô  flowinç 
(sometimeó iô getó jusô á trickle¬  though)®  Buô untiì recently¬ 
mù  olä  Kayprï IÉ haä nï ideá whaô É wanteä wheî É wenô  througè 
thå samå procedure®   É woulä turî oî thå switch¬  poğ iî á disk¬ 
waiô  á fe÷ secondó anä finä aî A¾ waitinç iî thå corneò  oæ  thå 
screen®   Theî  iæ É wanteä tï uså Wordstar¬  I'ä telì iô tï loaä 
Xtrakeù (tï redefinå mù keypaä foò Wordstar)¬ theî loaä Wordstar¬ 
loç Wordstaò ontï thå Bº drivå tï finä mù texô files¬ anä finallù 
telì iô whicè filå É wanteä tï worë on®          

It'ó á simplå procedure¬  buô it'ó alwayó thå same®   Whù noô leô 
thå machinå dï iô foò må anä speeä uğ thå wholå process?

There'ó  á  simplå  waù tï seô uğ á systeí sï  youò  CP/Í  Kayprï 
startó  uğ  automatically®   Thå secreô ió tï uså á  functioî  oæ 
CP/M'ó  "Copy¢  prograí  tï  marë á filå oî  eacè  disë  tï  loaä 
automaticallù wheî yoõ colä booô thå system®   Iæ you'vå upgradeä 
tï  Advent'ó TurboRoí system¬  yoõ caî configurå thaô  systeí  tï 
alwayó looë foò á particulaò filå namå witè á colä boot.

Witè eitheò system¬  yoõ caî makå thaô startuğ filå á submiô filå 
whicè executeó alì oæ thå stepó yoõ normallù gï througè tï  starô 
computing®   SUBMIT.COÍ ió á publiã domaiî prograí whicè executeó 
á serieó oæ commandó yoõ puô togetheò iî á "submiô file"®  EX.COÍ 
ió  á  similaò  prograí whicè workó betteò iî  somå  applicationó 
becauså iô keepó thå submiô filå iî memory®  (SUBMIT.COÍ writeó á 
temporarù filå tï disk¬  sï yoõ havå tï leavå rooí oî thå  disk.©  
Buô I'vå haä betteò lucë witè SUPERSUB.COM®   It¬  too¬  writeó á 
temporarù filå tï disk¬ buô I'í usinç iô becauså EX.COÍ upseô thå 
applå  carô witè Wordstar--mù lefô arro÷ cursoò controì  requireä 
twï keystrokeó tï movå thå cursoò onå space®  SUBMIT.COÍ wouldn'ô 
completå  thå entirå seô oæ commands¬  sï savå yourselæ somå timå 
anä troublå anä uså SUPERSUB.COM.

SUBMIT.COM¬ EX.COÍ (EX15.COM)¬ anä SUPERSUB.COÍ arå alì availablå 
iî thå KUAFÃ library.

                                    MORE
.paŠADD 1--CP/M AUTOMATION


Iî  ordeò tï automatå mù system¬  I'vå writteî á submiô filå  foò 
eacè disë oæ softwarå É use®   Here'ó thå filå É uså foò Wordstaò 
nameä WSTART.SUB:

    B:                Logs the B: drive for text files                   
    SÄ                SD.COM displayó directorù oæ disë iî B:            
                          and space available                            
    A:XTRA A:WS;WS    Runs Xtrakey redefinition program and              
or  WS                loadó Wordstar®  Iæ yoõ don'ô uså
                          Xtrakeù oò anotheò keù definitioî
                          program¬ uså thå seconä linå instead.          
    ERA *.BAK         Erases all backup files on B: drive                
                          afteò exitinç froí Wordstar®  Leavå            
                          out this step if you want to save              
                          backup files.                                  
    A:                Logs the A: drive                                  
    ERA *.BAK         Erases all backup files on A: drive.               
                          Leave this out if you want to save any         
                          backup files that end up on A:.                

Thå  commanä tï ruî thió procedurå ió SUPERSUÂ WSTART®   Anä thaô 
bringó  uğ  anotheò  problem®    Trù  tï  telì  thå  computeò  tï 
automaticallù ruî SUPERSUÂ WSTARÔ wheî yoõ dï á colä booô anä yoõ 
won'ô  geô anù fartheò thaî before®   Thå tricë ió  anotheò  freå 
publiã  domaiî prograí yoõ caî geô froí thå KUAFÃ librarù  calleä 
SYNONYM.COM®  Synonyí letó yoõ givå thå commanä SUPERSUÂ WSTARÔ á 
ne÷ one-worä commanä filå name®  I'vå useä START.COM¬ buô yoõ caî 
calì  iô  AUTOEXEC.COÍ iæ yoõ wanô tï pretenä you'rå runninç  MS-
DOS®   Witè  mù TurboRoí systeí É puô á filå oî everù disë  nameä 
START.COM®   I'vå alreadù configureä thå TurboRoí systeí tï  looë 
foò  START.COÍ everù timå É dï á colä boot®   Tï makå colä  bootó 
easier¬  É moveä thå reseô buttoî tï thå fronô paneì oæ mù Kayprï 
II®  No÷ wheî É switcè froí Wordstaò tï anotheò softwarå package¬ 
É simplù inserô thå ne÷ disk¬  puncè reset¬  anä thå Kayprï lookó 
foò á filå calleä START.COÍ tï telì iô whaô tï do.

                                    MORE
.paŠADD 2--CP/M AUTOMATION


----------------------------------------------------------------------------
Here's a step-by-step review of the process:
    
    1®     Writå  á submiô filå (xxxxx.SUB© listinç alì  commandó 
    yoõ wanô youò Kayprï tï automaticallù perform®   Uså thå non-
    documenô  modå  iî WordStaò oò anù texô editoò tï creatå  thå 
    file®  Don'ô leavå anù blanë lineó iî thå middlå oæ thå file¬ 
    buô  enä  thå  filå witè á blanë linå witè  jusô  á  carriagå 
    return®   Thå samplå filå abovå includeó explanatorù noteó iî 
    thå righô column®  Don'ô includå thaô columî iî youò file.

    2®     Ruî  SYNONYM.COÍ tï renamå SUPERSUÂ xxxxxx.SUÂ witè  á 
    one-worä commanä sucè aó START.COM®   Thå forí oæ thå commanä 
    tï ruî SYNONYÍ ió "SYNONYÍ newname.COÍ SUPERSUÂ xxxxxx¢ wherå 
    newnamå  ió thå namå yoõ picë foò youò startuğ  commanä  filå 
    (START.COÍ  oò  AUTOEXEC.COM© anä xxxxxø ió thå namå oæ  youò 
    submiô file.

    3®     Configurå youò systeí tï looë foò newname.COÍ wheî yoõ 
    colä  booô  (eitheò  poweò  uğ  oò  pusè  reset)®    Witè   á 
    conventionaì  CP/Í  operatinç system¬  copù eacè  disë  usinç 
    CP/M'ó COPY.COÍ utility®   Afteò thå systeí copieó thå entirå 
    disë  iô  wilì sho÷ yoõ á lisô oæ fileó oî thaô disë anä  asë 
    yoõ  whicè  onå yoõ wanô tï ruî automaticallù wheî  yoõ  colä 
    booô thå system®  Enteò START.COÍ oò AUTOEXEC.COÍ oò whateveò 
    namå yoõ pickeä wheî yoõ raî SYNONYM.COM.

          Iæ  yoõ  havå  á TurboRoí  operatinç  system¬  ruî  thå 
    TurboRoí  TURBOCFG.COÍ  prograí tï configurå youò  systeí  tï 
    looë  foò START.COÍ oò AUTOEXEC.COÍ oò whateveò yoõ  plaî  tï 
    namå youò startuğ procedure®  It'ó easieò iæ yoõ uså thå samå 
    filå  namå foò alì disks®   Numbeò ¸ oî thå TURBOCFG.COÍ menõ 
    ió thå selectioî tï specifù youò automatiã colä booô command®  
    Don'ô forgeô tï writå thå ne÷ systeí imagå tï á filå anä theî 
    writå thå systeí trackó oî anù disë yoõ wanô tï autoload.
----------------------------------------------------------------------------


    Automatioî  ió thå namå oæ thå gamå iî industrù  today®   Whù 
    noô  automatå  youò Kayprï anä leô iô makå  thingó  á  littlå 
    easier?

                                    -30-
