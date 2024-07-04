.he MEXPLUS 1.65 Summary                                  page #
               MEXPLUS 1.65 Documentation Summary

0) Authors          Nite-Owl and George M. Sipe

1) Precepts

<filespec¾     ½    [<drv><usr>:][<filename>][.<ext>]
<sring>        ½    zero or more characters surrounded by double
                       quotes (e.g. "Testing")
                    careô ('^'© may prefix á controì character
<string-var>   =    A B C D E or F (may contain up to 32 chars)
<string-expr>  =    <string> or <string-var>
<ascii-value¾  ½    zero to twï characteró surroundeä bù singlå 
                       quotes (e.g. 'x')
<number-var>   =    %A, %B, ... %Z (from 0 to 65,535)
<number>       =    number, <number-var>, <ascii-value>, VALUE,
                       or STACK
                    numbeò prefixes are $=hex¬ #=decimal
<number-expr>  =    infix numeric expression with opt. parens
                    operatoró are « - ª ¯ ½ <¾ ¼ <½ =¼ ¾ >½ =>
';§            ½    multiplå commanä separatoò (seå STAÔ SEP)

/Ò    specifieó á return (carriagå-returî only»  samå aó ^M)
/Î    specifieó a newline (carriage-return and line-feed)
/Ô    specifieó á tab
/¯    specifieó thå '/§ character
/Onnî specifieó anù binarù valuå (excepô 0)º nnî ió thå decimaì 
      valuå (alì threå digitó musô bå present)

2© Terminaì control (escape) sequences

<ESC>¿         printó á menõ oæ escapå sequences
<ESC>@         sends BREAK to remote system
<ESC>Å         exitó bacë tï commanä level
<ESC>N         disconnects modem
<ESC>Ð         togglås copy-to-printeò on/ofæ
<ESC>Ó         starôs copyinç incominç texô intï filå buffeò
<ESC>Ô         transmiôs á filå tï thå remotå (prompts for name)
<ESC>Õ         enäs (un-starts© copyinç texô intï filå buffeò
<ESC><ESC>     sends one <ESC> to remote system

3© Single-characteò commandó (Primarù options)

Eº  enteò terminaì modå witè Echo
Lº  enteò terminaì modå witè Local-echï only
Rº  Receivå á filå oò grouð oæ fileó usinç error check protocol
Sº  Senä á filå oò grouð oæ fileó usinç error check protocol
Tº  enteò Terminaì modå

4) Single-character command prefixes

K:  use Kermit protocol
M:  use standard christensen Modem7 protocol (default)
Y:  use Ymodem modified christensen protocol
Š5© Secondarù commandó (Secondarù options)

                        COMMANDS
OPÔ       NAMÅ          USEÄ WITÈ       ACTION
---     --------        ---------       ------
Á       Appenä          E, L, and T     Appenä tï á file
Â       Batcè           Ò anä Ó         Batch filå transfers
Ä       Disconnecô      Ò anä Ó         Disconnectó afteò transfer
E       Echo            E, L, and T     enter term mode with Echo
Ë       K-packet        S               senä 1Ë blkó, accept any
Ì       Locaì           E and T         Local-characteò echo
Ñ       Quieô           Ò anä Ó         "Quieô mode¢ filå transfer
Ò       Recv-vie÷       Ò anä Ó         showó Received-charó only
Ó       Send-vie÷       Ò anä Ó         showó Sent charó only
Ô       Terminal-modå   Ò anä Ó         enteò Terí afteò filå xfer
V       Vie÷            Ò anä Ó         Viewó thå filå transfeò 
Ø       Exiô            Ò anä Ó         disc/eXiô afteò transfer




                  MEXPLUS 1.65 Command Summary

.                   - comment follows

?                   - lists avaliable commands

=                   - assignment operator for <string-var> and
                         <number-var¾ (e.g® %a=%b=1¬ wherå thå
                         second = compares %b to 1, and the
                         result, 0 or 1, is assigned to %a)

@ <row>,<column> [SAY <string-expr> | <numeric-expr> [, ...] ]
                    - positions cursor to <row> and <col>
                      SAY displays expression(s)

ACCEPT <string-var>[,<length>]
                    - sets A B C D E or F from operator input
                      optional maximum length (up to 32)

ALÔ [<drv>][<usr>º] - drivå « useò tï searcè foò MEØ LOAÄ fileó 
                         (.MEX, .KEY, .PHN, .LIB, .MOD, .OVR)
                         default disk is 'A', default user is '0'
                         uses search strategy specified by SEARCH
                      if no argument, displays current setting

BELÌ <number¾       - rinçs thå belì once/seã foò <number¾ secs

BOX R1,C1,R2,C2     - draws a box between specified corners
                         (',' are all optional)

.cp 7ŠCAL[LÝ [<numblist¾ Û £ Û <retries¾ Ý Ý ]
                    - dialó <numblist¾ anä stopó afteò <retries¾ 
                      goeó intï 'T'erminaì modå wheî á computeò 
                         ió reached
                      iæ nï argument¬ phonå liârary is listeä 
                         anä promptó foò numâer tï call
                      VALUE set to 0 if no connect, else list #

CLONÅ <filespec¾    - saveó MEØ witè defineä phonå numberó,
                         keystrings, overlays, environment
                      default filename = '        .COM'

CLS                 - clears the terminal screen

COLÄ                - restartó MEX and clearó defineä phonå
                         numbers anä keystrings

COMP <string-expr-1> <string-expr-2>
                    - compare two string expressions for equality
                      result is left in VALUE, honors CASE switch

CSET                - control clock overlay functions

DEL [<filespec¾ [ V Ý ]
                    - deletes file, [V] will ask for verification
                         before erasinç eacè file
                      iæ nï argument¬ deletes open capture file

DIAÌ [<numblist¾ Û £ Û <retries¾ Ý ] ]
                    - samå aó CALÌ excepô returnó tï COMMANÄ mode

DIÒ <filespec¾      - displaùs directory, defaultó tï du:*.*
                      sets VALUE to number of entries found

DRAW <number>       - displays symbol <number> (0 to 13)
                      displays ASCII character <number> (14 up)

DSÃ                 - disconnects modeí

EMUL [ON | OFF]     - controls emulation module (if INSTALLed)

END REV | BRITE | BLINK | ULINE
                    - turns off specified video attribute

EXIT                - exiôs tï system¬ modeí noô disconnected

GLOBAÌ [<2ndopt¾]   - causås secondarù optioî <2ndopt¾ tï bå oî 
                         foò alì primarù options (default: none)
                      <2ndopt>='?' will list available settings
                      <2ndopt>='-' will erase current setting
                      if no argument, displays current setting

GLOBAL READ <string-expr>
                    - causes <string-expr> to be run in place of
                         returning to MEX command modeŠ
GOTO <label>        - transfer control to <label> in batch file
                         (note:  <label> must not be in different
                         IF block)

GOSUB <proc>        - invoke subroutine <proc> in batch file

HELÐ [<topic¾]      - provideó helð informatioî oî <topic>
                      <topic>='?§ wilì lisô thå availablå topics

HLINE <row>[,]<column>[,]<length>
                    - draws line to right of specified length

IÄ <string-expr>    - seôs <string-expr> foò MEX'ó prompt
                         default is "[MEX] " (max 28 char)
 
IF <number-expr> [THEN] <statement> [; <statement>]
                    - executes <statement> if <number-expr> non-0

IÆ <number-expr¾    - executeó statementó oî followinç lineó if
                         <number-expr> is non-zero, up to ENDIF
                      ELSE may be used to reverse the condition

INPUT               - sets VALUE from operator input

INSTALL <filespec¾  - installs optional modules:
                      REMOTE is the REO Remote Command Module
                      EMTDG  is DG D100/D200 emulation
                      EMTVT  is VT52/VT100 emulation
                      EMT925 is TeleVideo 925 emulation
                      EMTADM is LSI ADM-3a emulation

KBYÅ                - terminatå remotå Kermiô server¬ loç ouô 
                         from remote system, and break connection

KEÙ[S] Û <key>=Û <string-expr> Ý ]
                    - definås <key¾ (± char© tï <string-expr>
                      iæ <string-expr> omitted¬ <key¾ ió erased
                      iæ alì argumentó omitted¬ <keys>ó listed
                      invokeä witè '<esc><key>' or function key
                      honors WECHO and WTECHO

KFIN                - terminate remote Kermit server (only)

KGET <filenames>    - request <filenames> from remote Kermit
                         server (may include wildcards)

KLOG                - terminate remote Kermit server, and log out
                         from remote system, but keep connection

KPUÔ <filenames>    - tramsmitó <filenames¾ tï remotå Kermiô
                         server, equivalent to KS command (may
                         also include wildcards in <filenames>)

.cp 4ŠKSET [<keyword¾ [<newvalue>Ý ]
                    - seôs <keyword¾ variablå tï <newvalue>
                      iæ <newvalue¾ omitted¬ presenô valuå shown
                      iæ <keyword>='?'¬ variableó arå listed

LABEL <label>       - up to 16 alphabetic characters for GOTO

LOAÄ <filespec¾     - loaäs MEX'ó LOAÄ fileó (.KEY, .PHN, .OVR)

LOÇ [<drv>][<usr>:] - reseô anä optionally loç tï drive and user

PHONÅ [<name>[=[<number¾[/<comment> [<bps>]]]]
                    - seô <name¾ equivalenô tï <number¾ witè bauä 
                         ratå seô tï <bps¾ wheneveò used
                      iæ only <name>= then <name¾ is erased
                      iæ alì argmtó omitted¬ phonå <name>ó listed

PREFIØ <string-expr> - seôs <string-expr> tï send beforå SENDOUÔ 
                         default is ""

PROC <label>        - up to 16 alphabetic characters for GOSUB,
                         defines start of subroutine up to ENDP

PROTO <protocol>    - specify <protocol> as default, protocol may
                         be M for Modem7 (default), Y for Ymodem,
                         or K for Kermit

REAÄ <filespec¾ [parmlist]
                    - executås batcè filå <filespec>
                      <filespec¾ maù contaiî anù valiä commands
                      chaining of READ commands is permitted
                      default ext = '.MEX' (ext='.   ' illegal)
                      ^Ã from keyboard or STOP command aborts
                      executioî stopó whilå iî 'T'erminaì mode
                      braceó ({}© maù bå useä around commanä linå 
                         paraí tï includå imbeddeä spaces

     {<string-var>} - reference to <string-var>

     {<parmno> [: <defaulô parm¾ ]}
                    - reference to <parm>ó iî READ'ó [parmlist]
                      <defaulô parm¾ provides a default parm for
                         <parmno> if absent in [parmlist]

REÎ[AME] <newfile>[=]<oldfile>
                    - renameó <oldfile¾ tï <newfile>
                      botè nameó musô bå oî samå <drv><usr>

SAVÅ <filespec¾     - savås MEX'ó LOAÄ fileó (.KEY and .PHN)

SAY <string-expr> | <numeric-expr> [, ...]
                    - displays expression(s) at cursor position

SCREEN ON | OFF     - turns screen output on or off
                      automatically goes on when READ terminatesŠ
SENDOUÔ <string-expr> - sends <string-expr> to remote
                      VALUE set to 0 if ok, 1 if failed

SET                 - control hardware overlay functions

SLEEÐ <num-secs>    - invokeó delay, ^Ã will abort

SSET                - control modem overlay functions

START REV | BRITE | BLINK | ULINE
                    - turns on specified video attribute

STAÔ [<keyword¾ [<newvalue>Ý ]
                    - seôs <keyword¾ variablå tï <newvalue>
                      iæ <newvalue¾ omitted¬ presenô valuå shown
                      iæ <keyword>='?'¬ variableó arå listed

STAT DISP <keyword> ON | OFF
                    - controìs listinç oæ keyworä iî STAÔ display
                      STAT ? always displays all keywords

STOP                - terminates currently active READ file

SUFFIØ <string-expr> - seôs <string-expr> tï send afteò SENDOUÔ
                         default is "^M"

TERM                - open capture file toggled by CAPTURE switch

TERMA               - same as TERM but will append to file

TIME                - displays the date and time
                      sets VALUE to hh:mm

TRANSMIT <filespec> [S] - transmits <filespec> to remote system
                         if XON is on, xon/xoff will be honored
                         if [S], time delays will be used

TSET [<parameter> [<value>] ]
                    - terminal control parameters:

     ?              - displays all parameter settings

     BRIGHT [ON|OFF] - display bright text only

     LOWER [ON|OFF] - display lower case text

     MSG [ON|OFF]   - display terminal mode signon message

     WRAP [ON|OFF]  - terminal automatically wraps at end-of-line

TYPÅ <filespec¾ [PÝ - displaùs contentó oæ <filespec¾ oî screen
                      iæ [P], paginate by STAÔ PAGÅ variablå

.cp 2ŠVALUE [<number>]    - sets VALUE to <number>
                      or displays VALUE and STACK in decimal/hex

VER                 - prints the MEX version number and places it
                         into VALUE

VIEW                - displaùs contentó oæ the ASCII capture
                         buffer on the screen

VLINE <row>[,]<column>[,]<length>
                    - draws line down of specified length

WAIT {DATE mm/dd | TIME hh:mm}
                    - waits for the specified date or time
                      VALUE set to hh:mm or unchanged if aborted

WAIT SILENCE [<time>] - waits until no more modem characters
                      <time> is required idle time (default is
                         REPLY variable value) in seconds
                      max characters received of WLIM variable
                      VALUE set to 0 if ok, 1 if > WLIM chars

WAIÔ STRINÇ [<time>] <string-expr¾ [<string-expr>...]
                    - waits until any of up to 4 strings are
                         received from modem
                      <time> is maximum wait time (default is
                         REPLY variable value) in seconds
                      honors CASE switch and WLIM variable
                      VALUE set to 0 if time-out, else 1-4

WRÔ                 - writes¬ closeó opeî capturå filå tï disk




        MEXPLUS 1.65 Backward Compatible Command Summary

ADD <number>        - adds <number> to VALUE

BYE                 - (same as REO LOGOUT)

CPÍ                 - (samå aó EXIT)

DATE                - (same as TIME)

DO                  - (same as READ)

DOS                 - (same as EXIT)

ERÁ[SE] <filespec¾ [VÝ - same as DEL except requires <filespec>

POP                 - sets VALUE from STACK variable

PUSH                - sets STACK from VALUE variable
ŠQUIT                - (same as EXIT)

SKIPIF (operator)<number>
                    - skips next command if condition is true
                    - compares <number> to VALUE using (operator)
                    - operators:  "=", "!", ">", and "<"

STORE <string-expr> to <string-var>
                    - sets A B C D E or F from <string-expr>
                      equivalent tï <string-var>=<string-expr>

SUB <number>        - subtracts <number> from VALUE

SYSTEÍ              - (same as EXIT)

XCHG                - exchanges VALUE and STACK variables

XOR <number>        - exclusive ors <number> to VALUE


 

                   MEXPLUS 1.65 KSET variables

CHECK [1 | 2 | 3]   - Kermit error-check type

MODE [ASCII | BINARY | DEFAULT]
                    - Kermit transfer mode

PARITY [EVEN | MARK | NONE | ODD | SPACE]
                    - Parity setting (including non-protocol)

QUOTE [ON | OFF]    - Kermit 8th-bit quoting switch

RECV [<parameter> [<value>] ]
                    - Kermit receive parameters:

     EOL [<char="/R">]
                    - end-of-line character

     PAD [<char=0>] - padding character

     PADDING [ON | OFF]
                    - enables or disables padding

     PACKET [<size=94>]
                    - sets maximum packet size (up to 94 bytes)

     QUOTE [<char="#">]
                    - specifies quoting character

     SOH [<char=1>] - specifies start of packet character

.cp 3ŠSEND [<parameter> [<value>] ]
                    - Kermit send parameters (see RECV, but send
                         packet size default is 32 bytes)



               MEXPLUS 1.65 Remote Command Summary

ANSWER              - monitor modem for incomming call

DOWÎ <filespec¾     - remote REO downloadó <filespec¾ usinç CIÓ
                         hosô protocol

DUAL [ON | OFF]     - leave local console on when in ANSWER or
                         REMOTE mode

LOCAL               - terminates REMOTE mode

LOGOUT              - disconnect current caller, perform ANSWER

PASS [<password>]   - sets the ANSWER password to <password>
                      maximum allowable password is 8 characters
                      <password> - (hyphen) removes password

REMOTE              - turn control of MEXPLUS over to the serial
                      port immediately

UP <filespec¾       - remote REO uploadó <filespec¾ usinç CIÓ
                         hosô protocol




                   MEXPLUS 1.65 STAT variables

ALERÔ [<val=255>]   - seôs £ oæ beepó madå wheî á connectioî witè 
                         á remotå systeí ió madå resultinç froí á 
                         repeatinç CALÌ oò DIAÌ 

BAK [on|off]        - changås filå tï backuð else prompt erase

BELÌ [on|off]       - enables console bell

BUFFER[S]           - displayó capturå buf stató (sz¬ usd¬ spc)
                      displayó key buffer stató (sz¬ usd¬ spc)

CANCEÌ [<char="^U">] - setó <char¾ tï continuå SENDOUÔ until

CAPTURE [on|off]    - controls (TERM{A}) capture activity

CASE [on|off]       - enables case independence during WAIT

CHAÒ                - listó statuó oæ alì CHARacteò variables

.cp 2ŠCHECKSUÍ [on|off]   - seôs filå transfeò verificatioî method
                      mutuallù exclusivå witè CRC

CIÓ [on|off]        - speciaì filå transfeò protocoì useä bù 
                         Compuservå iî terminal mode

CLOCË [<val=40>]    - seôs clocë speeä iî Mhz*10
                      <val¾ ½ ± tï 25µ =¾ .± tï 25.µ Mhz

COMMENT [<char="/">] - sets <char> as PHONE library comment char

CRÃ [on|off]        - seôs filå transfeò verificatioî method

DEBUÇ [on|off]      - incominç datá iî Terminaì mode
                      displayeä iî DDT'ó Dumð format.
                      disableó FILTEÒ anä CIÓ wheî 'on'

DECIMAÌ [on|off]    - seôs defaulô radiø foò MEX

DIAL [<char="T">]   - sets smartmodem dialing type (T or P)

ESÃ [<char="^J">]   - definås teríinal modå escapå character

EXCLUDÅ [on|off]    - ignorås SYÓ fileó wheî <filespec¾ ió ambig

EXITFILE [on|off]   - searches for EXI.MEX when exiting MEX

EXTENÄ [on|off]     - causås illegaì MEØ commandó tï bå 
                         interpreteä aó REAÄ commands

FILTEÒ [on|off]     - ignorås uncommoî controì charó 
                      (otheò thaî CR¬ LF¬ BS¬ TAB)

HEØ [on|off]        - seôs defaulô radiø foò MEX
                      includinç block number during filå transfer
                      mutuallù exclusivå witè DECIMAL

ID [on|off]         - includes MEX ID in error messages

IDD [<val=15>]      - delays between calls (in 100s of ms)

INITFILÅ [on|off]   - searcèes foò INI.MEØ wheî bootinç MEX

LÆ [on|off]         - adäs LÆ tï alì CÒ iî Terí filå transfers

LISÔ [on|off]       - enablås LSÔ device

PAGÅ [<val=24>]     - screen size for TYPE pagination (0 = none)

PRECHO [on|off]     - enables logging to printer

QUEUE [on|off]      - queues modem characters after X-OFF

.cp 3ŠREPLÙ [<val=8>]     - seôs timå (0-25µ secs© foò SENDOUÔ tï waiô 
                         foò á replù froí remotå system (0 will
                         wait forever)

RETRÙ [<val=6>]     - seô SENDOUT retrieó (1-255© beforå aborting
                      WTECHO must be on

RTIMÅ [<val=1>]     - seôs receiver timeout wait time (1-3° secs© 

RUÂ [on|off]        - backspaceó senô converteä tï rubs

SEARCÈ [<val=2>]    - seôs searcè patterî useä foò REAÄ files¬ 
                         phonå libraries¬ keystrinç files¬ anä 
                         capturå fileó (witè Appenä option)
                      ° - loggeä DÕ     ² - loggeä DU¬ ALT
                      ± - ALÔ           ³ - ALT¬ loggeä DU

SEÐ [<char=";">]    - seôs commanä separatoò foò mult® cmä lines

SILENÔ [on|off]     - suppresóes echï oæ REAÄ filå commanä lines

SMDISC [on|off]     - controls software modem disconnect

SOAK [on|off]       - flushes terminal mode buffer

SODELAY [on|off]    - honors WCHAR and WLINE during SENDOUTs

SPLIÔ [on|off]      - lists phone library ± peò linå witè bps
                      elså listeä ² peò linå withouô bps

SWITCÈ              - lisôs alì '{on|off}§ variables

TAB [on|off]        - expands tabs to multiple spaces

TERM                - lists terminal control sequences

TRIGGEÒ [<char=">">] - setó <char¾ tï waiô foò beforå SENDOUT

TSTAMP [on|off]     - logs time in terminal mode log files

VAÌ                 - lisôs alì <val¾ variables

WCHAÒ [<val=5>]     - delaùs afteò eacè chaò (0-¹ iî 10ó oæ ms)
                      may be suspende by WTECHO

WECHO [<val=4>]     - sets echo-wait time for SENDOUT

WLIM [<val=16>]     - maximum WAIT STRING character count in kb

WLINÅ [<val=5>]     - delaùs afteò eacè linå (0-¹ iî 100ó oæ ms)
                      may be suspended by WTECHO

WTECHÏ [on|off]     - verifies commandó senô witè theiò echo
                      halveó transmissioî time
                      takes precedence over WCHAR and WLINEŠ
XLINÅ [on|off]      - foò teríinal modå filå transfers
                      waitó foò XOÎ afteò eacè linå (uncommon)

XOÎ [on|off]        - foò teríinal modå filå transfers
                      sendó untiì XOFF¬ continueó aô XON
