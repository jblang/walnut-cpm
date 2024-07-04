To:       Irv Hoff
From:     Jon Saxton
Date:     4 May 97
Subject:  CCP configuration for RCPM+



AN RCPM+ WITHOUT CCP104
=======================

You  don't really NEED to implement Jim Lopushinsky's replacement
CCP to run an RCPM+ but it does help.   Without CCP104+ you'd  do
something like this:-

1.   CP/M  Plus supports password protection on disks and  files.
     Since  we'll be using this facility we enable password  pro-
     tection on the A: drive

          set a: [protect=on]

     This  only  needs to be done once and not on every  warm  or
     cold  boot so there's no need,  for example,  to include the
     above command in PROFILE.SUB.   (CP/M Plus will  auto-SUBMIT
     PROFILE.SUB  if it and SUBMIT.COM both exist on the  default
     disk after a cold boot.)

2.   Put ALL executable command files on A0: - including the ones
     you don't want people to use - and make them all SYS files

          A>set *.*[sys]

3.   Establish the command search path.  This needs to be done on
     cold  boot  and  should  be included  in  PROFILE.SUB  or  a
     derivative - more on that later but the basic command is:-

          setdef a:

     which  tells  the  CCP to ALWAYS look on the  A:  drive  and
     NOWHERE  ELSE for command files.   You may have an  extended
     path if you really want but it seems a waste on an RCPM (and
     unnecessarily dangerous):-

          setdef *,a:,g:

     sets the command search path to <current>,A:,G: so that

          D3>prog

     looks for PROG.COM in D3:, D0:, A3:, A0:, G3:, G0:.

     I  use  an  extended setdef command which  does  some  other
     things at the same time:-

          setdef a: [order=(com,sub),temp=p:]

     The [order=(com,sub)] tells the CCP to look for  program.COM
     and if not found the program.SUB; the [temp=p:] tells things
     like SUBMIT to put temporary files on (my tiny ramdisk) P:.

     The  advantage  of the [order...] specification is that  you
     can  execute .SUB files without saying "submit" and  without
     adding a ".sub" suffix, i.e. you can say

          compile prog

     instead of

          submit compile prog

     or
          compile.sub prog

     to invoke COMPILE.SUB.

Now you can execute the programs on A0:  from anywhere.   You may
wish  to  patch  the  standard CCP to  display  the  user  number
regardless of whether or not user 0 is selected.  To do that load
up the CCP under a debugging utility (SID or Z8E are the easiest)

          sid ccp.com    or   z8e ccp.com
          s568                e 568
          cd                  cd
          .                   .
          wccp.com            w ccp.com

The above sequence changes a CALL NZ,0C13  to a simple CALL 0C13.
Before issuing the wccp.com command to SID or Z8E you should also
locate the internal command list (0637h), and change all internal
commands to lower case - for SID use s637 followed by

          "dir type erase rename dirsys user

or for Z8E use e637 followed by

          'dir type erase rename dirsys user'

The  next  trick is to stop remote callers from  executing  those
commands which could compromise the RCPM+.   We have prepared for
this  already by enabling password protection on  the  A:  drive.
Now we just need to protect the appropriate files.  Choose a nice
obscure password...

          set erase.com [protect=read,password=obscure]
          set rename.com[pro=read,pass=obscure]
          set date.com[pro=read,pass=obscure]

and  so  on for each 'nasty' program.   This only has to be  done
once  so  no  need to make a .SUB file - by using  ^W  and  other
editing  keys it is not too painful.   Do NOT set  protection  on
SUBMIT.COM otherwise PROFILE.SUB won't execute.

Somehow  we have to let users 'see' the programs they're  allowed
to execute.  I used a disk editor (SUPERZAP version 3.0 or later)
to  construct  (empty) directory entries in A0:  for things  like
'dir.com', 'type.com' and so on, using LOWER CASE letters.

Now we have all the user commands visible in a directory listing,
all  commands visible to the CCP from anywhere on the system  and
all dangerous commands password-protected so that remote  callers
who  don't know the password cannot execute them.

When  doing sysopy things you can use the SET command to set  the
default password

          set [default=obscure]

and the whole system will be opened up to you.   There's just one
snag - namely that you'd probably want to protect the SET command
itself so you'd have to say

          set;obscure [default=obscure]

Another option is to use a special password-setting utility  such
as PU which is distributed as source code in this library.  PU is
easy to use and has another advantage ....

Finally, we want to set up PROFILE.SUB so that it initializes the
system correctly.  Note that

     a)   PROFILE.SUB cannot be password-protected,
     b)   SUBMIT.COM cannot be password-protected,
     c)   Users should not be able to say SUBMIT PROFILE (or just
          PROFILE) and do anything dangerous.

One way around these constraints is to have two .SUB files, e.g.

     PROFILE.SUB              SETUP.SUB

     pu                       date read
     :submit setup            setdef a:
                              device lst:=null
                              hist

The  PU program mentioned earlier sets the BDOS result flag to an
error  value if the password prompt is not  answered  'correctly'
and  the next line (starting with a colon) will be  skipped.   If
the  PU  response  is correct then SETUP.SUB  will  be  executed.
SETUP.SUB  can and should be password-protected as should all the
programs it invokes.


At  first reading all the above probably seems  more  complicated
than  it  really  is.   The password protection  mechanism  is  a
standard feature  of CP/M Plus and is arguabley far  more  secure
than the ZCPR-style "wheel" byte.   Indeed, with the above system
even  the  sysop cannot execute dangerous programs just by  being
the  sysop - either the correct password must be supplied on  any
protected  utility or the password must be set up as the  default
password.

A  degree of simplification and a number of other benefits can be
had by implementing Jim Lopushinsky's ZCPR-style CCP replacement,
CCP104.


SOME ADVANTAGES OF CCP104
=========================

1.   Programs  no  longer have to be marked as SYS  files  to  be
     executable  from  user 0.   This means that it is no  longer
     necessary  to construct fake directory entries  for  command
     files just to show users what is available.   You can simply
     make the user commands DIR files.

2.   A  command library can be tacked onto the end of the  search
     path in the same fashion as ZCPR2's automatic LRUN facility.
     If  a  command has not been found by the end of  the  search
     path (which probably points to A: and nowhere else) then the
     CCP  can  automatically search COMMAND.LBR and  execute  the
     program from there (if it exists therein).

3.   CCP104 supports many ZCPR-style features such as the "wheel"
     byte along with drive and user limits.

4.   The  command library search can be subject to the wheel byte
     setting.  This means it is possible to put all the dangerous
     programs  into COMMAND.LBR and they will only be  accessible
     when  the wheel byte is set - a security feature  completely
     different from and independent of password protection.

5.   CCP104  is compatible with and supports the HIST  RSX  which
     stores the last few commands for recall, edit and re-issue.


CONFIGURING AND GENERATING CCP104
=================================

(Read this section in conjunction with a listing of CCPHDR.MAC)

CCP should be YES

WHLLBR should probably be YES to inhibit command library searches
when the WHEEL byte is not set in which case you'd put  DANGEROUS
programs  into the command library.   However Tesseract RCPM+ has
been running for a long time with WHLLBR set to NO and with  SAFE
programs  in  the library.   (The dangerous ones are outside  the
library and are password-protected.)

EXPAND should probably be YES.

MYDRV,  MYWHL and MYUSR should be left at their default values of
'P',  0FFh  and 15 respectively (plus applicable offsets).   Your
BBS  software  can (and should) set the  values  appropriate  for
remote callers at login.

TIME  should probably be YES - it is a nice touch.   However  you
might  like  to dive into the main source code  (CCP104.MAC)  and
suppress  the  enclosing  [brackets] which  have  no  information
value.

BYECHK  must be YES if you are going to set NOXOFF to  YES.   I'm
not sure what else is affected by BYECHK.  In any case it doesn't
hurt to leave it set to YES.

NOXOFF - take your pick.   If all your RCPM+ utilities sense XOFF
and XON then I guess there's no need to let the BDOS do it  also,
but I left NOXOFF set to NO.

YESPRL  should probably be set to NO.   Remember that .PRL  files
are  executable  under CP/M+.   You probably don't have any  .PRL
files  that you want to execute and it is a nuisance to have  to
remember to rename any .PRLs to something else.  KMD does protect
against uploaded .PRL files by automatically renaming them,  just
as  it does for .COM files so if you want to say PROG.PRL on  the
odd occasion then set YESPRL to YES.

YESLBR  should be YES if you are going to use the command library
facility.

TIMEON  is  up to you.   Having TIMEON set to YES would  be  more
useful  if it displayed the time remaining rather than  the  time
which has elapsed.

CRNAME - I can think of no reason why you'd want to use  anything
other  than the default name CMDRUN.COM.   However I'd not  waste
time by allowing a path search.  I'd set it up as:-

     crname:
               db        1              ;User 0 (really!)
               db        1              ;Drive A
               db        'CMDRUN  COM'  ;Library processor

That  completes the configuration for CCPHDR.MAC from which a new
CCP will be generated.  On a CP/M+ system you just say

          ccphdr.sub

and CCP.COM pops out the other end.


LIBRARY COMMAND PROCESSOR
=========================

Edit  LRUNHDR.MAC and change EXDRV and EXUSR to match your upload
area.  Tesseract's is B0: so I set

     EXDRV:    db     2
     EXUSR:    db     0

That's it.  Generate CMDRUN.COM by saying

          lrunhdr.sub

NAMED DIRECTORIES
=================

Of  dubious value.   By the time users figure out what names  are
available they know where to look anyway.   Seems pointless using
up TPA space to store directory names.

If  you plan on using Jim Lopushinsky's LD301 (renamed to LD.COM)
to get inside .LBR files then it is a nice touch to include

          dirname on

in the commands executed (indirectly) out of PROFILE.SUB.  When a
user says

          D4>ld bye510

then the prompt changes to something like

          D4\BYE510>

If you're going to use LUX then the above does not apply.

WHAT NOW?
=========

Most  CP/M Plus systems expect to find CCP.COM on  A0:  but  some
(like  the Osborne Executive) load the CCP from the system tracks
in CP/M2.2-style.   That is quite silly, because in a system with
banked  memory it is possible to store a copy of the  CCP  during
cold boot and reload it from banked memory every warm boot.   The
saving  of a directory entry and 4K of file space seems pointless
even  on  a floppy disk system because then you can change  disks
and no longer need to have a "system" disk in any drive once cold
booting is complete.

However it is possible that the computer system on which all this
is  to run has software cast in the old mould,  supplied  without
source code, missing some of the standard configuration tools and
you are stuck with it.

The clue is to look for CCP.COM in user 0 of your ORIGINAL system
disk.   If  it exists then the chances are you can  just  replace
your  current  CCP.COM with the one you've just  generated.   If,
when  you  cold-boot you see the prompt displayed as  A>  or  0A>
instead  of A0> then your computer cannot be loading the CCP from
CCP.COM - it must be getting it from somewhere else,  most likely
the system tracks.

I cannot tell you how your system track(s) is (are) arranged.  If
you  are lucky then your computer manuals will.   Since I do  not
have that information it is difficult for me to suggest a general
method of rewriting selected portions of the system tracks.


COMMAND HISTORY
===============

Once you get CCP104 running,  a really nice extra is to implement
a command history stack so you can recall,  edit and re-issue the
most recent commands.

At least three are available:-

     BUFF12A by Andrew McLean - now superseded.
     HIST by   Jim   Lopushinsky  - derived  from   BUFF12A   but
          substantially rewritten and simplified.
     HISTORY by Stuart Rose.

Assuming  you choose HIST (which is available as HIST+.LBR)  then
you  should  password-protect it and invoke it as the  VERY  LAST
command  of the PROFILE.SUB sequence.   (General rule is that any
program  with  an attached [permanent] RSX should be  LAST  in  a
SUBMIT file.   This precludes having two RSX programs in a SUBMIT
file but there is a work-around if you really need it.)

Note  also that there is a CCP105+ which supports command history
in  the  same style as UNIX's csh.   I don't know it this  is  an
"approved" version of the CCP10X series.

MODIFICATION TO SUBMIT.COM
==========================

With SUMBIT.COM, SUBMOD1.HEX and SID.COM all accessible just say

     submod1.sub

to  patch SUBMIT.COM to allow it to execute non-SYS submit  files
in user 0.  Note that for this to work, CCP104 or similar MUST be
installed.


= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


Well  that's it.   It has been a while since I actually  did  all
this  so my memory is not to be trusted absolutely but I think  I
have it right.      JRS.
