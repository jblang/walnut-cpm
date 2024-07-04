
                        VDE-ZCPR3 MODIFICATIONS
        ______________________________________________________

        The inability of VDE to enter a print control code of ^B has
made it of limited use in a ZCPR3 environment. The patches listed below
will enable VDE ver 2.3 and 2.4 to use ^B as a print control code for
generating ^A.....^B standout video sequences.

        NOTE:  This patch does not make VDE recognize ^B as the
WORDSTAR bold print toggle. It merely allows a ^B to be entered as a
text character for use by VMENU, HELP, ETC.

        What it does is substitute 0BH (^K) for 02H (^B) as the block
marker token. The block commands will still be <esc> B and ^QB, but
the marker stored in memory will be ^K instead of ^B. This means that
^K can not now be used as a print control character.

        I have used this modification on VDE ver 2.3 with no apparent
problems. I do not use ver 2.4 because of a problem with the way it
handles word left (^A) commands when at the top of the screen. (Are you
listening E. Meyer ?) I did perform a test however, and the modification
seems to work with VDE24.

        Also, I have included a method of using an ALIAS.CMD file
to allow the automatic selection of the proper terminal overlay when
VDE is invoked.

        -------------------------------------------------
                        VDE23 MODIFICATION


>GET 100 VDE23.COM
>POKE 185F 0B
>POKE 19FC 0B
>POKE 1A29 0B
>POKE 1A3A 0B
>SAVE 39 VDE23.COM
>NOTE You may use your favorite de-bugger instead of the poke command
        __________________________________________________
                        VDE24 MODIFICATION

>GET 100 VDE24.COM
>POKE 1B13 0B
>POKE 1CB9 0B
>POKE 1CE6 0B
>POKE 1CF7 0B
>;IF YOUR SAVE COMMAND CAN HANDLE THE 'S' OPTION
>SAVE 83 VDE24.COM S
>;IF NOT,
>;SAVE 42 VDE24.COM


        __________________________________________________
                USE WITH MORE THAN ONE TERMINAL

        If you regularly use more than one type of terminal on your
system, you can use the power of ARUNZ and ALIAS.CMD to automatically
select the proper overlay for VDE (and other non-ZCPR3 programs).

1. Create a version of VDE for each terminal using VINST2(3 or 4).
2. Then do the following for each version

>GET 100 VDEXX.COM
>;IF VDE ver 2.3
>SAVE 5 TERMNAME.OVL S
>;IF VDE ver 2.4
>;SAVE 7 TERMNAME.OVL S
>ERA VDEXX.COM

3. Insert the following lines into your ALIAS.CMD FILE (modified to
   fit your system). User-Defined byte 1 is used as a terminal id byte.


kaypro stat con:=crt:;ldr kaypro.z3t;poke f4c1 0
vip7200 stat con:=tty:;ldr vip7200.z3t;poke f4c1 1
vde if $mf4c1=00;vde23 $*;else;get 100 vde23.com;get 100 vdeh.ovl;go $*;fi

        NOTES ON ABOVE ALIAS COMMANDS:

        1. The 'kaypro' command sets the kaypro keyboard & internal video
           as the system console. If you use IOP's, then use the DEV
           program instead of STAT.

        2. The 'vip7200' command sets a Honeywell 7200 terminal connected
           to the serial printer port as the system console.

        3. The 'vde' command examines user-byte 1, and loads the proper
           terminal overlay. (I saved a little disk space by not using
           an overlay when the Kaypro is the terminal.)

        4. The above method may be expanded to allow the use of up to
           eight (IF nesting limit) terminals for S-100 and other
           expandable systems.

        5. The same method may be used to customize other terminal
           sensitive programs which don't make use of the TCAP function.



                                FINAL NOTE
        ____________________________________________________________

        In order to honor Eric Meyer's copyright (specifically his
request that modified versions of VDE not be distributed), this patch
file may be passed about freely, but please do not distribute any patched
copies of VDE to others.


                                        Enjoy,

                                        Royce Shofner


        The above info, VDE-Z3.PAT, is the same as VDE-Z3.MOD except
that a typing error has been corrected.

        The line in error was :
>POKE 193A 0B

        The correct entry is :
>POKE 1A3A 0B

        Sorry for any problems this typo may have caused.

                                        Royce Shofner

