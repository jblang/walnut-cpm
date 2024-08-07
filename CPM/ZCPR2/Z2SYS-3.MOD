.fo SOFTWARE UPGRADES to SYSLIB and ZCPR2              Page #

              SOFTWARE UPGRADES to SYSLIB and ZCPR2
                          30 April 1983

                               by
                          Richard Conn

                        New TEMPLATE.MAC
                       New ZCPR2 Utilities
            Modified GENINS to Include New Utilities
          Modified Help Files to Document New Utilities
                      COMPARE.HLP Corrected

1.0  Baselines

     Th� followin� baselin� softwar� i� establishe� b� thi� up�
grade:

          COMMENT   PAGE   PHELP   SAK   PRINT3
New Vers: GENINS    TEMPLATE


2.0  Associated Upgrade Documentation

     Z2ALT.HLР ha� bee� modifie� t� documen� th� ne�� utilities�  �
An error has been corrected in COMPARE.HLP.


3.0  Files Affected by this Upgrade

     The following files are provided with this upgrade:

          COMMENT.COM    COMMENT.MAC
          GENINS.COM     GENINS.MAC
          PAGE.COM       PAGE.MAC
          PHELP.COM      PHELP.MAC
          PRINT3.COM     PRINT3.MAC
          SAK.COM        SAK.MAC
                         TEMPLATE.MAC

          Z2ALT.HLP      COMPARE.HLP


     These files have the following CRC values:

    1 File: COMPARE .HLP -- Size:     7K -- CRC: A4 C0
    2 File: PHELP   .COM -- Size:     8K -- CRC: 0A ED
    3 File: PHELP   .MAC -- Size:    29K -- CRC: D7 B0
    4 File: Z2ALT   .HLP -- Size:    28K -- CRC: AD 4E

    1 File: COMMENT .COM -- Size:     1K -- CRC: 88 40
    2 File: COMMENT .MAC -- Size:     6K -- CRC: 51 99
    3 File: GENINS  .COM -- Size:    14K -- CRC: A3 81
    4 File: GENINS  .MAC -- Size:    46K -- CRC: 08 8C
    5 File: PAGE    .COM -- Size:     8K -- CRC: 43 78
    6 File: PAGE    .MAC -- Size:    27K -- CRC: 68 F4
    7 File: PRINT3  .COM -- Size:     8K -- CRC: 19 02
    8 File: PRINT3  .MAC -- Size:    29K -- CRC: 27 12
    9 File: SAK     .COM -- Size:     2K -- CRC: 29 61
   10 File: SAK     .MAC -- Size:     8K -- CRC: 0E D0
   11 File: TEMPLATE.MAC -- Size:    18K -- CRC: 0B 3C


4.0  Reasons for Changes to Programs and Files

     Ne�� utilitie� hav� bee� adde� t� th� ZCPR� System��  GENIN� �
ha� bee� modifie� t� instal� PAGE� PHELP� an� PRINT3�  Th� other� �
can be installed by the previous version of GENINS.

     The design of TEMPLATE has been enhanced.

5.0  Impact on ZCPR2

     N� impac� i� expecte� o� an� o� th� ZCPR� utilities�� excep� �
fo� GENINS�  N� othe� change� ar� issued.

6.0  New Documentation

     Th� followin� i� provide� a� additiona� documentatio� t� �
supplemen�� th� ZCPR� Manuals��  Ne� manual� wil� b� prepare� a� �
som� time� bu� n� change� t� existin� manual� ar� anticipate� fo� �
severa� months��  Th� followin� documentatio� i� extracte� fro� �
Z2ALT.HLP (new version).


6.1  The PAGE Command

     Th� PAG� comman� i� use� t� lis� file� o� th� console��  I� �
offer� � fe� advantage� ove� TYP� i� tha� PAG� know� th� widt� o� �
th� scree� an� handle� wraparoun� (whic� i� � bi� complain�� wit� �
TYPŠ whe� tryin� t� pag� throug� "wide�� listing� lik� tha� �
produce� b� th� assemblers)��  PAG� als� accept� � fil� lis�� an� �
supports named directories.

     PAGE is invoked by a command line of the following form:

          PAGE dir:f1.typ,dir:f2.typ,... o...

wher� "dir:fn.typ� i� a� ambiguou� fil� spe� (wil� card� ma�� b� �
used�� wit� � DI� prefi� (name� directorie� o� D� for�� allowed� �
and "o" is one or more of the following options:

          0-9  Set Character Print Speed (0=fastest=default)

          I    Inspect Files
                    The user is allowed to approve each file to
                    b� printe� befor� th� printin� begins� 
                    default is NO Inspection

          L    Toggle Line Numbering
                    Each line may be numbered; default is NO Line
                    Numbers

          P    Toggle Screen Paging
                    Tur� of� th� facilit� o� pausin� onc� �
                    screen is filled; default is Paging Enabled

          Snn  Skip to Specified Page
                    Skip to indicated page (size of page on
                    printer) before beginning; default is NO Skip

     Th� Spee� optio� o� th� PAG� comman� shoul� b� discusse� i� �
somewha�� mor� detail��  Whil� � fil� i� bein� page� t� th� user� �
th� use� ca� strik� on� o� th� digit� t� var� th� spee� o� th� �
outpu� dynamically�  � i� th� fastest� � i� th� slowest�  I� thi� �
way�� th� use� ca� easil� sca� � fil� b� runnin� PAG� wit� th� � �
optio� (s� i�� doe� no� sto� whe� th� scree� i� filled�� an� �
strikin� � digi� fro� tim� t� tim� t� spee� u� ove� section� h� �
isn't interested in and slow down for sections he is.

     Whil� th� outpu�� i� bein� directe� t� th� screen�� PAG� �
support� th� followin� single-characte� command� t� chang� th� �
output display in one way or another:

          0 to 9 - change speed (0=slowest, 9=fastest)

          P or p - toggle pause when screen fills
                    (the user can dynamically turn on and off
                     the ability to delay when a screen fills)�
          ^X     - skip to next file

          ^C     - abort to operating system

          ^S     - pause output; any key will resume, and all
                    of these commands (except ^S) will work

     PAG� i� constantl� acceptin� use� input�� an� thes� command� �
ar� i� effec� al� o� th� time��  Thi� include� th� tim� whe� PAG� �
ha� pause� afte� fillin� th� scree� (it� default)�� s� th� use� �
ca� tur� of� pagin� o� var� th� spee� a�� thi� time�� i� s� �
desired�  An� othe� characte� wil� b� ignored.

6.2  The PRINT Command

     Th� PRINԠ comman� i� use� t� prin� � fil� o� th� LST� �
device�� lik� LIS� does�� bu� offer� man� mor� options��  I� wil� �
prin�� � heading�� pag� th� file�� numbe� th� pages�� numbe� th� �
lines�� plac� � date/tim� stam� o� th� output�� pu� th� fil� nam� �
o� th� output� an� others.

     The PRINT command is of the following form:

          PRINT dir:f1.typ,dir:f2.typ,... o...

wher� "dir:fn.typ�� i� a� ambigou� fil� nam� wit� � DIҠ prefi� �
(supportin� th� D� for� o� � name� directory� an� "o� i� on� o� �
mor� o� th� following:

          E - Exact Print (Expand Tabs, Form Feed, No Line or
               Page Numbers, No Heading)

          F - Toggle default of file name display on page header
               (defaul� i� ON� so � turn� of� name display)

          H<delim>text<delim> - Define Heading text to appear
               at the top of each page

          I - Inspect Files (allow user to select files before
               printing begins)

          L - Enable numbering of each line

          M - Disable Multiple Run Flag
               (if multiple run is ON, then no "Set Top of Form"
                message appears for each file and PRINT moves
                from one file to another unattended); default is
               with Multiple Run ON

          N - Disable numbering of each page

          Sn - Start printing on page n

�
          T - Toggle date/time stamp in the header of each page
               (a TIME subroutine must be assembled into PRINT
                to enable the date/time stamp feature)

     Th� specifi� feature� o� th� printe� ar� se�� b�� th� �
installe� wit� GENINS��  Suc� feature� includ� th� numbe� o� �
physica� line� o� � page�� th� numbe� o� line� o� tex� o� � page� �
an� th� widt� o� � lin� i� characters.

     Th� date/tim� stam� featur� i� ver�� machine-dependent�� an� �
PRIN� ha� t� b� reassemble� t� suppor� it.

     While PRINT is running, the following commands work:

          ^C   Abort and return to operating system

          ^X   Skip to top of next page and skip to next file

6.3  The PHELP Command

     Th� PHEL� comman� i� � specia� versio� o� PRIN� designe� t� �
prin� Hel� (HLP� files��  PHEL� know� abou� th� structur� o� Hel� �
Files�� an� i� use� thi� informatio� t� prin� the� i� � preferre� �
format�  I� i� i� dealin� wit� a� indexe� Hel� File� PHEL� print� �
th� inde� o� th� firs� pag� an� th� bod� startin� o� th� secon� �
page��  PHELР alway� skip� t� th� to� o� � ne�� pag� whe� i� �
encounter� a� informatio� section��  I� output� � ne� lin� whe� � �
for�� fee� characte� (use� b� HEL� t� brea� scree� displays)�� a� �
opposed to causing a page eject.�

     The PHELP command is of the following form:

          PHELP dir:f1.typ,dir:f2.typ,... o...

wher� "dir:fn.typ�� i� a� ambigou� fil� nam� wit� � DIҠ prefi� �
(supportin� th� D� for� o� � name� directory� an� "o� i� on� o� �
mor� o� th� following:

          H<delim>text<delim> - Define Heading text to appear
               at the top of each page

          I - Inspect Files (allow user to select files before
               printing begins)

          L - Enable numbering of each line

          Sn - Start printing on page n

          T - Toggle date/time stamp in the header of each page
               (a TIME subroutine must be assembled into PRINT
                to enable the date/time stamp feature)

     A� wit� PRINT�� ^� abort� th� printou� an� ^� skip� t� th� �
next file after issuing a form feed.�
6.4  The SAK Command

     SAˠ (Strik� An� Key� wa� designe� t� provid� som� simpl� �
utilit� functions�� on� o� whic� i� associate� wit� th� Multipl� �
Comman� Lin� featur� o� ZCPR2�  I� wa� designe� fo� th� followin� �
purposes:

          1.  to allow the user to program a wait in a multiple
               command line until he instructs the system to
               continue

          2.  to allow the user to abort a multiple command line

          3.  to allow the user to program an interruptable delay
               in the execution of a multiple command line

          4.  to provide a simple alarm for the user

     The SAK command line is:

          SAK o...

where "o" is zero or more of the following options:

          A    -- DO NOT Allow the User to Abort the MCL
          B    -- Ring Bell
          Pnn  -- Pause nn seconds and continue if no response

     Wit� N� options�� SA� wait� fo� use� input�� an� i� th� use� �
strike� � ^C�� the� th� multipl� comman� lin� i� aborte� an� �
control is returned to the user.

     SA� i� particularl� usefu� i� th� use� wishe� t� interjec� � �
dela�� i� � multipl� comman� lin� generate� b�� � Menu��  A� �
applicatio� whic� � foun� usefu� wa� t� displa� th� tim� t� th� �
user�� cal� hi� attentio� t� i� (vi� ECHO)� giv� hi� � dela� (vi� �
SAK), and then invoke dBASE II with an initializing command file.


6.5  The COMMENT Command

     COMMEN� i� � simpl� routin� whic� allow� th� use� t� typ� a� �
man�� line� a� h� wishe� withou� the� bein� processe� b�� ZCPR2�  �
It has no arguments.

     COMMENT has two main applications in the ZCPR2 environment:

          1.  when the console displays are being recorded,
               COMMENT allows the user to easily type notes
               to the future reader without having to begin
               lines with a semicolon (;); all of these lines
               are clearly shown to be comments since they begin
               with the prompt "COMMENT>"
�
          2�  whe� consol� I/� i� redirecte� t� tw� differen�
               users, such as CRT and MODEM I/O in parallel,
               then COMMENT may be used to provide a simple
               mechanism for them to communicate; both users
               can type to each other without having any effect
               on the system (such as command processing)

     COMMENԠ i� aborte� b� strikin� � ^� a� th� firs�� characte� �
o� � line�  Backspac� an� Delet� bot� serv� t� ech� a� Backspace� �
space, backspace, and ^X and ^U both erase the current line.

     I� COMMEN� i� t� b� use� t� cha� betwee� tw� users�� i�� i� �
recommende� tha� a� over/ou� protoco� b� employe� (a� recommende� �
wit� th� UNI� WRIT� program)��  Th� firs� use� types�� and�� whe� �
finished�� terminate� wit� th� lette� "o� fo� over��  Th� secon� �
use� type� an� signal� completio� th� sam� way��  Completio� o� �
th� conversatio� ma� b� signalle� b� "o+o� fo� ove� an� out�  �
Example:

COMMENT> Hi, Charlie, how's it going? o
COMMENT> Hi, Rick, fine ... and you? o
COMMENT> Fine, Charlie
COMMENT> Here is how I use XDIR -- let me do the typing
COMMENT> from now on ... just watch, and I'll reenter COMMENT
COMMENT> when done ... here goes o+o


