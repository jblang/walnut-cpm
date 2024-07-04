.cw 11
.po 11
.pn 1
.fo                                                           Page #




                 The ZCPR3 INSTALLATION WORKBOOK

                         by Richard Conn


                  First Revision, 8 March 1985
                Original Draft, 20 February 1985




.he                                  The ZCPR3 INSTALLATION WORKBOOK

About this Workbook

     Thió  workbooë  takeó yoõ througè thå eighô stepó  oæ  ZCPR³ 
installation®   Yoõ shoulä havå á copù oæ thå Installatioî Manuaì 
(oò  SAMPLER© handù aó yoõ worë througè it®   Thió workbooë  wilì 
servå  tï  direcô  youò readinç oæ thå  Installatioî  Manuaì  anä 
providå á placå foò yoõ tï writå dowî informatioî requireä durinç 
thå  installatioî  process®   Therå  arå blankó tï  filì  iî  anä 
scratcè  areaó  iî  whicè yoõ maù perforí computationó  anä  makå 
notes»  iô ió recommendeä thaô yoõ makå alì oæ youò  computationó 
anä noteó here®  Thió workbooë caî servå aó á documenô oî ho÷ yoõ 
seô  uğ youò ZCPR³ system¬  sï yoõ caî refeò bacë tï iô lateò  iæ 
yoõ wanô tï makå á change.

     Eacè  steğ  oæ thå installatioî procesó ió detaileä  iî  thå 
followinç pageó anä ió presenteä witè thå followinç format:

          Objective:
               The goal to be achieved
          Required Files:
               The programs and other files required to perform
               this step
          References:
               The chapters and sections in the Installation
               Manual and in ZCPR3:_The_Manual associated
               with this step; the indicated sections of the
               Installation Manual are required reading, while
               those sections in ZCPR3:_The_Manual contain
               supplementary information
          Instructions:
               Step-by-step details on what to do; places are
               also provided for you to write down important
               information


.paŠ
Overview of ZCPR3 Installation

     Objective To summarize the goals of the installation
               process

     Required_Files None

     References
          Installation Manual -- Chapter 1
          ZCPR3: The Manual   -- Chapters 1, 2, 9-16

     Instructions
     1®   Revie÷   chapteò  ±  oæ  thå  Installatioî  Manuaì  anä 
(optionally© revie÷ thå indicateä chapteró oæ ZCPR3º_Thå_Manual.

     2®   Iî summary¬ thå followinç itemó arå goinç tï bå createä 
foò youò microcomputeò system.

          A®  Á  ne÷  SYSGEÎ imagå containinç thå  ZCPR³  Commanä 
Processoò  iî placå oæ thå CP/Í Consolå Commanä Processoò  (CCP)®  
Thå  BIOÓ  maù  alsï bå modified®   Figurå 1-± (pagå  6©  oæ  thå 
Installatioî  Manuaì  showó thå SYSGEÎ imageó oæ  á  conventionaì 
CP/Í systeí anä á ZCPR³ system®  Thå modifieä BIOÓ ió requireä iî 
ordeò tï initializå thå ZCPR³ bufferó foò youò system.

          B®  Thå  Systeí  Segmentó requireä foò youò  choicå  oæ 
ZCPR³  configuration®   Sectioî  1.³ oæ thå  Installatioî  Manuaì 
(pagå 7© anä chapteró 2¬  10¬ anä 1¶ oæ ZCPR3º_Thå_Manual“ discusó 
thå topiã oæ thå Systeí Segments®  Thå ZCPR³ Systeí Segmentó are:

               o Environment Descriptor
               o TCAP File for your terminal
               o Flow Command Packages
               o Input/Output Packages
               o Resident Command Packages
               o Named Directory Files

          C®   Thå  ZCPR³  Utilitieó  installeä  foò  youò  ZCPR³ 
configuration®   Sectioî  1.´ oæ thå Installatioî Manuaì (pagå 7© 
anä chapteró 3-8¬  15¬  anä 1¶ oæ ZCPR3º_Thå_Manual“ discusó  thå 
utilities.

.paŠ
     3®  Thå  installatioî procesó foò á ZCPR³ systeí consistó oæ 
these steps:
          1) Select the features of the target ZCPR3 system
          2) Plan the memory structure of the target ZCPR3 system
               (create Z3BASE.LIB)
          3© Modifù thå colä booô routinå iî thå BIOÓ tï
               initialize buffers as required
          4) Select the features of the ZCPR3 Command Processor
               (create Z3HDR.LIB)
          5© Overlaù thå CP/Í CCĞ witè thå ZCPR³ Commanä
               Processor and overlay the old BIOS with the
               new BIOS; create the new SYSGEN image for your
               ZCPR3 System
          6) Place the new SYSGEN image for your ZCPR3 System
               onto the Operating System tracks of a disk
          7) Select the features of your System Segments and
               create the System Segments
          8) Install the ZCPR3 utilities

     Read chapter 1 of the Installation Manual now.

.paŠ
Step 1: Selecting the Features

     Objective Select the features your ZCPR3 System will
               have

     Required_Files None

     References
          Installation Manual -- Chapter 2
          ZCPR3: The Manual   -- Chapters 2, 9-11, and 17

     Instructions
     A® Reaä Chapteò ² oæ thå Installatioî Manual.

     B. Make the following decisions:

          1® Arå yoõ goinç tï includå thå standarä     YES   NO
1Ë   overheaä  iî  youò  ZCPR³  System¿    Iô   ió 
recommendeä  thaô yoõ answeò YEÓ tï thió question®  
Iæ YES¬ gï tï decisioî 3» iæ NO¬ gï tï questioî 2.

          2®  Yoõ  arå  NOÔ goinç tï  includå  thå 
standarä 1Ë overheaä iî youò ZCPR³ System®   Whicè 
partó  oæ thå standarä overheaä arå yoõ  goinç  tï 
include?

               2a. External Stack                      YES   NO

               2b. Command Line Buffer                 YES   NO

               2c. Memory-Based Named Directory        YES   NO

               2d. External File Control Block         YES   NO

               2e. Message Buffers                     YES   NO

               2f. Shell Stack                         YES   NO

               2g. Environment Descriptor              YES   NO

          3®  Whicè  oæ thå followinç packageó arå 
yoõ goinç tï implemenô iî youò ZCPR³  System?   Iô 
ió  suggesteä thaô Flo÷ Commanä Packageó arå  mosô 
important¬  Residenô  Commanä Packageó arå second¬ 
anä Input/Outpuô Packageó arå third.

               3a. Flow Command Packages               YES   NO

               3b. Resident Command Packages           YES   NO

               3c. Input/Output Packages               YES   NO

.paŠ
          4®  Whicè  oæ thå otheò bufferó arå  yoõ 
goinç  tï provide¿   Thå Externaì Patè  ió  highlù 
recommended.

               4a. External Path                       YES   NO

               4b. Wheel Byte                          YES   NO



                 -- Blank Space for Comments --


.paŠ
Step 2: ZCPR3 Memory Structure

     Objective To plan the memory structure of your ZCPR3
               System and to create your Z3BASE.LIB file

     Required_Files Z3BASE.LIB (ZCPR3 File)
                    Z3LOC.COM (ZCPR3 File)
                    MOVCPM.COM or equiv
                    DDT.COM or equiv (ZDM and DSD)
                    your favorite editor

     References
          Installation Manual -- Chapter 3
          ZCPR3: The Manual   -- Chapters 2 and 18

     Instructions
     A® Reaä Chapteò ³ oæ thå Installatioî Manual.

     B® Yoõ arå no÷ goinç tï figurå ouô ho÷ mucè spacå youò ZCPR³ 
Systeí ió goinç tï take®   Filì ouô thå followinç tablå baseä  oî 
youò answeró iî Steğ 1®  

          1®  Iæ  yoõ answereä YEÓ tï questioî  1¬ 
enteò 1Ë anä gï oî tï thå bottoí oæ thå page®   Iæ 
yoõ  answereä NÏ tï questioî 1¬  enteò ° anä gï oî 
tï question 2.                                         _________

          2®   Foò  eacè oæ thå YEÓ answeró  undeò 
questioî 2¬  enteò thå indicateä value®   Foò eacè 
oæ thå NÏ answers¬  enteò 0®  Itemó 2b¬ 2c¬ anä 2æ 
may be adjusted if you want more or less space.

               2a. External Stack = 48                 _________

               2b. Command Line Buffer = 208
                   (allows for 200 chars/line)         _________

               2c. Named Directory Buffer = 256
                   (allowó foò 1´ 18-bytå entries)     _________

               2d. External FCB = 48
                                                       _________

               2e. Message Buffers = 80
                                                       _________

               2f. Shell Stack = 128
                   (allows for 4 32-byte shells)       _________

               2g. Environment Descriptor = 256
                                                       _________

          Computå thå totaì oæ alì valueó yoõ havå 
entered in on this page.                               =========
.paŠ
          2h®  Enteò  thå totaì froí thå bottoí oæ 
thå previouó pagå here.
                                                       ==========

          3®  Enteò thå followinç valueó foò  eacè 
oæ thå packageó yoõ selecteä iî questioî ³ iî steğ 
1®   Iæ yoõ wisè tï modifù theså valueó tï providå 
morå  oò  lesó spacå foò eacè oæ  theså  packages¬ 
feeì  freå tï dï so®   Thå indicateä sizeó arå thå 
recommendeä values.

               3a. Flow Command Package = 0.5K         _________

               3b. Resident Command Package = 2K
                                                       _________

               3c. Input/Output Package = 1.5K
                                                       _________



               3d. Total of 3a-3c                      =========

          4®   Itemó  4á anä 4â iî steğ ±  requirå 
virtuallù nï additionaì spacå (oî thå ordeò oæ 10-
1¶ byteó total)¬  anä spacå foò theså entrieó  caî 
usuallù  bå founä somewherå iî fixeä memorù  (dowî 
iî  thå  firsô 25¶ byteó oò uğ iî thå  BIOS)®   Nï 
spacå entrù wilì bå madå foò theså selections.


     Computå thå totaì oæ thå entrieó oî thió pagå 
anä rounä thå numbeò uğ tï thå nexô 1Ë iæ therå ió 
any fraction.  Enter the total of 2h and 3d.           =========


     C®  Figurå  ouô thå sizå oæ youò  BIOS®   Thå 
prograí  Z3LOÃ wilì givå yoõ thå startinç  addresó 
oæ youò BIOÓ iæ yoõ ruî iô oî youò currenô system®  
Aó aî alternative¬ thå addresó aô memorù locationó 
±  anä  ²  caî bå examineä witè DDÔ  tï  determinå 
wherå  youò BIOÓ starts®   Writå dowî thå sizå  oæ 
youò BIOÓ here.                                        _________

.paŠ
     D®    Determinå  wherå  yoõ  caî  placå  thå  ZCPR³  Commanä 
Processoò  (ZCPR³  CP)®   Thió  hingeó oî wherå youò  MOVCPÍ  (oò 
equivalent©  prograí  placeó  thå systeí wheî tolä  tï  movå  it®  
MOVCPÍ  relocateó thå BDOÓ foò you¬  anä thió ió thå onå parô  oæ 
youò olä CP/Í systeí whicè wå arå retaining¬  sï wå wilì havå  tï 
plaî  thå memorù mağ oæ youò systeí baseä oî wherå yoõ caî  placå 
thå BDOS®  Iæ yoõ arå goinç tï uså ZRDOS± oò ZRDOS² froí Echelon¬ 
thió  becomeó  mucè  lesó oæ á probleí sincå  yoõ  havå  absolutå 
controì oæ wherå yoõ caî placå thå ZRDOS®  Sincå thå installatioî 
manuaì  ió  geareä foò thoså whï wilì continuå tï  uså  thå  CP/Í 
BDOS¬  wå  wilì  direcô thå discussioî tï thå BDOÓ anä noô  coveò 
installation with ZRDOS at this time.

     Tï  assisô yoõ furtheò iî determininç thå addresseó foò  thå 
componentó  oæ youò ZCPR³ System¬  thå followinç tablå showó  thå 
addresseó  oæ  thå ZCPR³ Commanä Processor¬  BDOS¬  anä BIOÓ  foò 
variouó  sizeó oæ TPÁ (bù "TPA"¬  É aí referrinç tï thå  areá  oæ 
memorù  belo÷ thå ZCPR³ Commanä Processoò whicè doeó NOÔ  includå 
thå ZCPR³ Commanä Processoò itself).

                 ------------ Locations ----------
TPA Size         ZCPR3 CP           BDOS      BIOS

   44K              0B000          0B800     0C600
   45K              0B400          0BC00     0CA00
   46K              0B800          0C000     0CE00
   47K              0BC00          0C400     0D200
   48K              0C000          0C800     0D600
   49K              0C400          0CC00     0DA00
   50K              0C800          0D000     0DE00
   51K              0CC00          0D400     0E200
   52K              0D000          0D800     0E600
   53K              0D400          0DC00     0EA00
   54K              0D800          0E000     0EE00
   55K              0DC00          0E400     0F200
   56K              0E000          0E800     0F600

     Foò  example¬  iæ  thå  amounô oæ  additionaì  overhead¬  aó 
indicateä bù youò answeò tï questioî B´ oî thå previouó page¬  ió 
1K¬  anä  youò BDOÓ currentlù resideó aô E400¬  theî yoõ neeä  tï 
movå thå BDOÓ dowî bù 1Ë (1Ë ½ 400H© tï E000®  Hence¬ yoõ neeä tï 
ruî  MOVCPÍ  witè  thå  correcô valuå tï placå  youò  BDOÓ  aô  á 
startinç addresó nï higheò thaî E000.

     Find this value now.  Record the following values:


          ZCPR3 CP Address  _____________

          BDOS Address      _____________

          BIOS Address      _____________

.paŠ
     E®  Usinç  thå  memorù mağ iî Figurå 3-± (pagå  22©  oæ  thå 
Installatioî  Manuaì anä thå exampleó oî thå followinç twï  pageó 
aó á guide¬  filì ouô thå followinç tablå aó á memorù mağ foò thå 
systeí  yoõ  arå  planning®   Uså thå datá froí Steğ  ±  anä  thå 
questionó  iî  thió  steğ (A-D© tï helğ you®   Thå  answeró  froí 
questioî  Ä (previouó page© shoulä bå copieä directlù  intï  thió 
tablå aó theù arå (startinç addresseó oæ thå ZCPR³ CP¬  BDOS¬ anä 
BIOS)®  Leavå blanë thå elementó yoõ diä noô select®  Iæ youò ROÍ 
ió aô aî odä location¬  adjusô youò memorù usagå accordinglù (yoõ 
maù wanô tï placå somå oæ thå bufferó AFTEÒ thå ROM).

                                               ADDRESS
FUNCTION                        SIZE      STARTING  ENDING


ZCPR3 Command Processor          2   K    ________  ________

BDOS                             3.5 K    ________  ________

Your BIOS                     _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Resident Command Package      _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Input/Output Package          _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Flow Command Package          _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Environment Descriptor        _______     ________  ________

Shell Stack                   _______     ________  ________

Message Buffers               _______     ________  ________

External FCB                  _______     ________  ________

Named Directory Buffer        _______     ________  ________

Command Line Buffer           _______     ________  ________

External Stack                _______     ________  ________

ROM (if at top of memory)     _______     ________  ________

     Seå  thå followinç twï pageó foò exampleó oæ ho÷ tï filì  iî 
thió table®  Refeò alsï tï pagå 2² oæ thå Installatioî Manual.
.paŠ.fo                                                          Page #

     Examplå  1º  Nï ROÍ iî memorù anä nï  Input/Outpuô  Package®  
All other features selected.


                                               ADDRESS
FUNCTION                      SIZE      STARTING  ENDING


ZCPR3 Command Processor          2   K    _ D600 _  _ DDFF _

BDOS                             3.5 K    _ DE00 _  _ EBFF _

Your BIOS                     __ 1.5 K    _ EC00 _  _ F1FF _

ROM (if not at top of memory) _______     ________  ________

Resident Command Package      __ 2.0 K    _ F200 _  _ F9FF _

ROM (if not at top of memory) _______     ________  ________

Input/Output Package          _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Flow Command Package          __ 0.5 K    _ FA00 _  _ FBFF _

ROM (if not at top of memory) _______     ________  ________

Environment Descriptor        _ 256 _     _ FC00 _  _ FCFF _

Shell Stack                   _ 128 _     _ FD00 _  _ FD7F _

Message Buffers               _  80 _     _ FD80 _  _ FDCF _

External FCB                  _  48 _     _ FDD0 _  _ FDFF _

Named Directory Buffer        _ 256 _     _ FE00 _  _ FEFF _

Command Line Buffer           _ 208 _     _ FF00 _  _ FFCF _

External Stack                _  48 _     _ FFD0 _  _ FFFF _

ROM (if at top of memory)     _______     ________  ________

.paŠ
     Examplå 2º  1Ë ROÍ froí F800-FBFÆ anä nï Input/Outpuô  Pack
age®  Alì otheò featureó selected.


                                               ADDRESS
FUNCTION                      SIZE      STARTING  ENDING


ZCPR3 Command Processor          2   K    _ D200 _  _ D9FF _

BDOS                             3.5 K    _ DA00 _  _ E7FF _

Your BIOS                     __ 1.5 K    _ E800 _  _ EDFF _

ROM (if not at top of memory) _______     ________  ________

Resident Command Package      __ 2.0 K    _ EE00 _  _ F5FF _

ROM (if not at top of memory) _______     ________  ________

Input/Output Package          _______     ________  ________

ROM (if not at top of memory) _______     ________  ________

Flow Command Package          __ 0.5 K    _ F600 _  _ F7FF _

ROM (if not at top of memory) __ 1.0 K    _ F800 _  _ FBFF _

Environment Descriptor        _ 256 _     _ FC00 _  _ FCFF _

Shell Stack                   _ 128 _     _ FD00 _  _ FD7F _

Message Buffers               _  80 _     _ FD80 _  _ FDCF _

External FCB                  _  48 _     _ FDD0 _  _ FDFF _

Named Directory Buffer        _ 256 _     _ FE00 _  _ FEFF _

Command Line Buffer           _ 208 _     _ FF00 _  _ FFCF _

External Stack                _  48 _     _ FFD0 _  _ FFFF _

ROM (if at top of memory)     _______     ________  ________

.paŠ
     F®  Yoõ  no÷ havå alì thå datá requireä tï ediô  Z3BASE.LIB®  
Run your favorite editor on Z3BASE.LIB:

          1®  Ediô  thå commenô headeò anä filì iî thå valueó foò 
youò  systeí aó presenteä iî thå tablå yoõ jusô filleä iî  above®  
Yoõ wilì finä thió tï bå á tediouó procesó whicè reallù payó  ofæ 
iî thå lonç run.

          2®  Seô alì oæ thå equateó iî Z3BASE.LIÂ tï contaiî thå 
propeò valueó aó yoõ planneä oî thå tablå above®   Follo÷ througè 
sectioî 3.³ oæ thå Installatioî Manuaì aó yoõ dï this.


          -- Blank Space for Calculations and Notes --


.paŠ
Step 3: Modify the BIOS Cold Boot Routine

     Objective Modifù thå Colä Booô routinå iî youò BIOÓ to
               initialize the buffers you selected above.

     Required_Files source to your BIOS
                    your favorite editor
                    an assembler that will assemble your
                          BIOS and generate a HEX file

     References
          Installation Manual -- Chapter 4, Section 4.1
          ZCPR3: The Manual   -- Chapter 19

     Instructions
     A®  Studù  sectioî  4.±  oæ Chapteò ´  oæ  thå  Installatioî 
Manual®  Refeò tï thå samplå sessioî iî sectioî 4.5®

     B®  Writå codå intï thå Colä Booô routinå tï initializå  thå 
bufferó  yoõ includeä iî youò ZCPR³ System®   Yoõ maù wanô tï uså 
thå  codå iî sectioî 4.± afteò thå labeì CBOOTº  aó á  modeì  foò 
youò code.

     Thå followinç bufferó musô bå initializeä tï zero:

          1. Resident Command Package
          2. Flow Command Package
          3. Environment Descriptor
          4. Shell Stack
          5. Message Buffers
          6. Named Directory Buffer

     The following buffers must be initialized with data:

          1. External Path
               Initialize the path
          2. Wheel Byte
               Clear it or set it
          3. Input/Output Package
               Place initial set of drivers
          4® Commanä Linå Buffer
               Initializå sizå anä startuğ command

     The following buffers do not need to be initialized:

          1. External Stack
          2. External File Control Block

     C®  Assemblå  youò BIOÓ anä makå surå iô  assembleó  withouô 
error®   Alsï  makå  surå thaô iô ió smalì enougè tï fiô  oî  thå 
Systeí Trackó foò youò microcomputer®  Yoõ no÷ havå á HEØ filå oæ 
youò ne÷ BIOS.

.paŠ
Step 4: Editing Z3HDR.LIB

     Objective To select the features of the ZCPR3
               Command Processor

     Required_Files Z3HDR.LIB (ZCPR3 File)
                    Z3BASE.LIB (ZCPR3 File)
                    ZCPR3.ASM (ZCPR3 File)
                    your favorite editor
                    Digital Research MAC, Echelon ZAS,
                          or equivalent assembler

     References
          Installation Manual -- Chapter 4, Section 4.2
          ZCPR3: The Manual   -- Chapters 2, 9, and 19

     Instructions
     A®  Reaä  sectioî 4.² oæ thå Installatioî Manual®   Refeò tï 
thå samplå sessioî iî sectioî 4.5.

     B® Ediô Z3HDR.LIÂ anä seô thå equateó aó yoõ desire®  Follo÷ 
alonç iî sectioî 4.² oæ thå Installatioî Manuaì sincå iô provideó 
á runninç dialoç oæ youò basiã tradeoffs.

     C®  Assemblå ZCPR³ anä makå surå iô assembleó withouô error®  
Thió  automaticallù  checkó  tï  ensurå thaô  thå  ZCPR³  Commanä 
Processoò ió 2Ë oò lesó iî sizå (aî erroò ió raiseä iæ iô ió oveò 
2Ë  iî size)®   Yoõ havå tï uså aî assembleò likå  Echelon'ó  ZAÓ 
becauså  oæ thå uså oæ macros®   Yoõ no÷ havå á HEØ filå oæ  youò 
ZCPR3 Command Processor.

.paŠ
Step 5: Overlaying the old BIOS and the CCP

     Objective Replace the CP/M CCP with ZCPR3 and your old
               BIOS with the modified BIOS created above.

     Required_Files MOVCPM.COM
                    SYSGEN.COM
                    DDT.COM, SID.COM, or equivalent
                    ZCPR3.HEX (from previous assembly)
                    BIOS.HEX (from previous assembly)

     References
          Installation Manual -- Chapter 4, Section 4.3
          ZCPR3: The Manual   -- Chapter 19

     Instructions
     A®  Reaä  sectioî 4.³ oæ thå Installatioî Manual®   Refeò tï 
the sample session in section 4.5.

     B®  Yoõ  maù wanô tï builä á conventionaì CP/Í systeí  whicè 
containó youò ne÷ BIOÓ anä runó aô thå addresó oæ youò ne÷  ZCPR³ 
system®   Thió ió aî additionaì steğ whicè ió noô detaileä iî thå 
Installatioî  Manuaì aô thió point¬  anä iô maù savå yoõ á loô oæ 
frustratioî later®   Amonç otheò things¬ iô assureó yoõ thaô youò 
BIOÓ ió correcô anä thaô youò BOOÔ ió alsï workinç properly®   Tï 
dï this:

          1. Ruî MOVCPÍ witè thå propeò value
          2® SAVÅ thå memorù imagå tï á disë filå (CPM.BIN)
          3. Run DDT on CPM.BIN to load it
          4® Loaä thå BIOÓ (sectioî 4.5.1± showó thå procedure)
          5. Correct the BOOT if necessary
          6. Exit DDT and SAVE the result to disk
          7. Run SYSGEN on the new image, place it on the
               system tracks, and make sure it boots and runs
               correctly

     Iæ yoõ dï thió parô oæ Steğ 5¬  yoõ no÷ havå á workinç  CP/Í 
systeí  whicè  runó  wherå  youò ZCPR³ wilì  run¬  anä  yoõ  havå 
confirmeä thaô youò BIOÓ ió OK®   Yoõ arå alsï iî á gooä placå tï 
follo÷ thå Installatioî Manuaì aô steğ 4.5.10.

     C®  Iæ  yoõ diä noô dï Â above¬  ruî MOVCPÍ oî youò  currenô 
CP/Í Systeí tï locatå thå BDOÓ aô thå propeò location®   Savå thå 
resultanô  systeí  imagå oî disë aó á filå viá thå SAVÅ  command®  
Iæ yoõ diä Â above¬ thå imagå generateä ió readù foò you.

     D®  Uså  DDÔ  tï reaä iî thå systeí imagå saveä iî Â  oò  C®  
Examinå  thå areá occupieä bù thå CCĞ anä BDOÓ tï makå surå  theù 
arå wherå theù shoulä be.

.paŠ
     E® Stilì iî DDTº Zerï ouô thå areá occupieä bù thå CCP®  Uså 
thå É anä Ò commandó tï reaä iî thå HEØ filå oæ thå ZCPR³ Commanä 
Processor®   Follo÷  alonç iî sectioî 4.5.1± oæ thå  Installatioî 
Manual if you need to.

     F®   Stilì iî DDTº  Zerï ouô thå areá occupieä bù thå  BIOS®  
Uså  thå  É anä Ò commandó tï reaä iî thå HEØ filå oæ  thå  BIOS®  
Follo÷  alonç iî sectioî 4.5.1± oæ thå Installatioî Manuaì iæ yoõ 
need to.

     G®   Exiô  DDÔ  anä savå thió ne÷ systeí imagå oî disë aó  á 
file®  É wilì refeò tï thió filå aó ZCPR3.BIN.


               -- Blank Space for Calculations --


.paŠ
Step 6: Implanting the Operating System Image

     Objective Place the image created above on the
               operating system tracks of a scratch disk.

     Required_Files DDT.COM
                    SYSGEN.COM
                    ZCPR3.BIN

     References
          Installation Manual -- Chapter 4, Section 4.4
          ZCPR3: The Manual   -- Chapter 19

     Instructions
     A®  Reaä sectioî 4.´ oæ thå Installatioî Manual®   Refeò  tï 
the sample session in section 4.5.

     B®  Uså DDÔ (É anä Ò commands© tï loaä thå systeí imagå filå 
(ZCPR3.BIN© intï memory®  Checë iô tï makå surå thaô alì ió well®  
Aó á minimum¬ makå surå thå followinç ió true:

          1® Thå ZCPR³ Commanä Processoò ió iî placå anä thå 
             addresseó withiî iô arå correct.

          2® Thå BIOÓ ió iî placå anä thå addresseó withiî iô 
             arå correct.

          3® Thå BOOÔ ió correcô foò loadinç thå operatinç 
             systeí aô thå correcô memorù location.

     C®  Uså SYSGEÎ tï placå thió memorù imagå ontï thå operatinç 
systeí  trackó  oæ  á  scratcè  disk®    Sectioî  4.5.1²  iî  thå 
Installatioî Manuaì giveó yoõ aî examplå oæ thió step.

     D®   Removå  alì diskó froí youò system®   Placå thå scratcè 
disë iî youò Á drivå anä trù tï booô it.

     Iæ  alì wenô well¬  ZCPR³ shoulä havå comå uğ anä  presenteä 
yoõ  witè á prompt®   Sincå youò scratcè disë ió  blank¬  iæ  yoõ 
loadeä  thå  Commanä Linå Buffeò witè á  STARTUĞ  command¬  ZCPR³ 
shoulä  havå  echoeä thió commanä followeä bù á questioî marë  tï 
indicatå thaô iô waó noô found.

.paŠ
Step 7: System Segment Installation

     Objective Install the System Segments your selected.

     Requireä_Files“ LIÂ anä ASÍ fileó foò thå Systeí Segments:
                         SYSRCP.LIB and SYSRCP.ASM
                         SYSFCP.LIB and SYSFCP.ASM
                         SYSIOP.LIB and SYSIOP.ASM
                         SYSNDR.LIB and SYSNDR.ASM
                         SYSENV.LIB and SYSENV.ASM
                    your favorite editor
                    MAC.COM or equivalent
                    MLOAD.COM or equivalent

     References
          Installation Manual -- Chapter 5
          ZCPR3: The Manual   -- Chapter 20

     Instructions
     A. Read Chapter 5 of the Installation Manual.

     B® Ediô thå LIÂ fileó tï selecô thå featureó foò youò Systeí 
Segments®   Chapteò  µ  provideó  á runninç  commentarù  oæ  youò 
options¬  anä  yoõ  maù  finä iô usefuì tï follo÷  alonç  iî  thå 
appropriatå  sectioî  oæ  Chapteò µ aó yoõ ediô  eacè  LIÂ  file®  
The following sections of Chapter 5 cover the indicated segments:

          5.1 - Resident Command Packages
          5.2 - Flow Command Packages
          5.3 - Input/Output Packages
          5.4 - Named Directory Files
          5.5 - TCAP Files
          5.6 - the Environment Descriptor

     C®  Assemblå youò Systeí Segments®   Makå surå theù assemblå 
withouô  error®   Givå thå assembleä objecô fileó thå propeò filå 
types®  Sectionó 4.5.± tï 4.5.· providå overviewó oæ thió procesó 
and may prove useful.

     Chapteò  · oæ thå Installatioî Manuaì goeó intï somå  detaiì 
oî  thå  TCAĞ  anä ho÷ tï creatå youò owî iæ onå ió  noô  alreadù 
available via the TCSELECT program.

     Alsï  notå thaô yoõ maù lateò wanô tï ruî somå oæ thå  ZCPR³ 
utilitieó tï ediô anä creatå ne÷ nameä directorù files.

.paŠ
Step 8: Utility Installation

     Objective Install the ZCPR3 Utilities for your system

     Required_Files Z3INS.COM
                    an INS file naming the utilities
                    your favorite editor
                    the utilities (COM files) you want to install

     References
          Installation Manual -- Chapter 6
          ZCPR3: The Manual   -- Chapter 21

     Instructions
     A®  Reaä Chapteò ¶ oæ thå Installatioî Manual.

     B®  Uså youò favoritå editoò tï creatå aî INÓ filå iæ yoõ dï 
noô  alreadù  havå  one®   Placå thå nameó oæ  thå  fileó  tï  bå 
installed in this file, one file per line.

     C®   Placå  alì  fileó  tï  bå  installed¬  Z3INS.COM¬  youò 
Environmenô  Descriptoò  file¬  anä  youò INÓ filå  iî  thå  samå 
directorù  oî  disk®   Ruî  Z3INÓ  oî  youò  INÓ  filå  anä  youò 
Environmenô Descriptoò file.

     D®   Optionallù  creatå á TCAĞ filå iæ yoõ havå noô  alreadù 
donå sï (seå Chapteò · oæ thå Installatioî Manual).

     E®   Placå  alì oæ youò systeí fileó iî thå rooô  directory¬ 
creatå thå STARTUĞ aliaó iæ yoõ neeä one¬ anä booô youò ne÷ ZCPR³ 
System.


                        CONGRATULATIONS!



