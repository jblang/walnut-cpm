From : Irv Hoff
Date : 01 Oct 85
Topic : IMP244 and DTR

     Nearly all modems permit using an external DTR voltage on their
RS-232 pin 20.  This is the method by which the operator can
intentionally disconnect the modem when finished.  By either shutting
off that DTR voltage (or momentarily dropping it), the modem
disconnects.

     Some computers (such as the Osborne OS-1) do not have this external
voltage without making an internal change to the wiring.  A few modems
(notably the Anchor Mark XII) do not permit using this external voltage.
They do, however, use a software feature that can disconnect the modem:

     (1 second pause) +++ (1 second pause)

     IMP244 now has an option not previously offered.  I used one of the
spare bytes (address 011E, named SPARE2 on each overlay) to control this
option.  If left 00, IMP drops DTR and expects you to have pin 20 of the
computer hooked to pin 20 of the modem.  This disconnects the modem
almost immediately.

     If you have a modem that does not support pin 20 DTR (or for some
reason you have not - or prefer not to hook up this wire) you can put FF
(anything other than 00) at byte 011E.  You can put this byte in the
overlay itself at the label called SPARE2.  I suggest you then make that
read NODTR rather than SPARE2.  You can also make the change to IMP244
with DDT, then save 72 pages.

     Changing this byte 011E to FF (or anything other than 00) then
substitutes the "pause +++ pause" for the DTR routine.  It disconnects
the modem from the phone line as does dropping DTR - just takes somewhat
longer is all.  (This only works for modems that use the Hayes "AT"
protocol.)

                                        - Irv Hoff
                                        Los Altos Hills, CA 94022
                                        (415) 948-2166

====================================================================

Subject : IMP244 bell suppression
Date : 08 Nov 85
From : Irv Hoff

     Some people don't want to hear the bell ring on incoming text copy
when using a modem program.  (Some systems do seem to ring the bell a
lot, especially when receiving the end of a line, etc. in edit mode.)

     If you do not want the bell to work on incoming copy in terminal
mode make this change with DDT, then save 72 pages:

(ORIGINAL) 1FBC CA 3D 14

(NO BELL) 1FBC C3 00 0B
     0B00 CA 3D 14 FE 07 CA 3D 14 C3 BF 1F

     You might want to call this by a different name, while you try out
the results, etc.

                                        - Irv Hoff
                                        Los Altos Hills, CA 94022
                                        (415) 948-2166

====================================================================

IMPDSC.FIX

     A Fix for the Disconnect Routine in IMP 2.44.

     Larry Davis of Glendale LITTERA seems to have found a solution to
what he rightly calls an "irritating quirk" of IMP - a reluctance to
disconnect when the remote is sending data, or worse, after the remote
disconnects and IMP starts reading line noise as transmitted data.  IMP
users have had to get used to switching their modems off to disconnect.

     Here is Larry's proposed fix: in the IMP overlay three are four
instructions in the GOODBYE routine that delay the disconnect routine.

     mvi   b,'S'-40h  ; send a ^S to stop the remote
     call  j$sndchr   ; this is where Larry thinks it hangs
     mvi   b,1
     call  j$timer

     He believes that deleting or commenting out these instructions will
permit instant disconnect, no matter what the modem is "receiving".  For
those who would rather do a quick patch than a reassembly, here's how I
did it.  The code breaks down to

     06,13,CD,nn,nn,06,01,CD,nn,nn

     A search for 06,13,CD finds this pattern twice, once for a
disconnect by ^N, and again for DSC.  I found the first instance
starting at the last byte in sector 2 (for me, anyway, 01FFh) and the
second time in sector 89 - I found it at 2D52.  Zeroing out the ten
bytes in both instances allows you to test Larry's theory with a minimum
of hassle.  Make note of the actual bytes shown here as nn in case you
run into trouble and want to restore the byte strings.  (In my version
of IMP the bytes were 8C,01 and 92,01, or addresses 018Ch for J$SNDCHR
and 0192h for J$TIMER.

Fred Haines

Glendale LITTERA
818-956-6164
Abel Iwaz, sysop
