Program AppleSound;

{ This program loads a 6502 sound routine at apple address $302
   then duration and frequency are loaded into $300 and $301
   ($F300 and $F301 in Z80) finally the routine is called using
   a general call to an apple subroutine.

  You can use this routine (try different durations and frequencies)
   to get sound from your apple almost like the SOUND procedure
   available to our IBM Turbo friends.
}


{=========================================================================}
{ This is a general procedure which will transfer control to a 6502 subroutine
   in Apple memory.  The argument is the address (in 6502 address location).

    This procedure can easily be included in any program .
}

  Procedure call_appl(AppleAddr : integer);

   Begin
    inline($2A/>AppleAddr/$22/$F3D0/$2A/$F3DE/$77);
   End;

      { here is the Z80 source code

        LD    HL,(addr)    ;get the apple address
        LD    (0F3D0H),HL  ;store it in vector
        LD    HL,(0F3DEH)  ;get the softcard address
        LD    (HL),A       ;hit the softcard address
      }

{============================================================================}

  Procedure LoadSnd;

    CONST
      snd : array [0..25] of byte =
      ($AC,01,03,$AE,01,03,$A9,04,$20,$A8,$FC,$AD,$30,$C0,
       $E8,$D0,$FD,$88,$D0,$EF,$CE,00,03,$D0,$E7,$60);

    var
      i : integer;

    Begin
      for i:= 0 to 25 do
       mem[$F302+i] := snd[i];
    End;

   { now the sound routine is loaded }

  Procedure Sound(duration,frequency : byte);

    Begin
      mem[$F300] := duration;
      mem[$F301] := frequency;
      call_appl($0302);
    End;

  BEGIN
    LoadSnd;
    Sound(10,125);
    Delay(100);
    Sound(10,125);
    Delay(100);
    Sound(10,125);
    Delay(100);
    Sound(18,95);
    Repeat until keypressed;
  END.

