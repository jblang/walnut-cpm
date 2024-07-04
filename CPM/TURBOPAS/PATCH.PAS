Program Patch;

{
  PATCH: Patches a Turbo program to save the command line and
          suppress the automatic calls to terminal initialization.
  Written by CSEB (EBM)
  Net address: J. Eliot B. Moss <EBM@MIT-XX.ARPA>
  Last update: 07 JUN 84, 1650 EDT
}

{$I-,W0}

const
  SkelSize = 14;

var
  Base     : integer;
  CmdAddr  : integer;           { place for the command line to be stored }
  EndAddr  : integer;           { next free byte after code }
  StartAddr: integer;           { starting place of original Turbo code }
  Buffer   : array [0..255] of byte;
  FileName : string[16];
  CmdString: string[31] absolute $0080;
  ComFile  : file;

{ - - - level 1 - - - }

Function GetInt (Offset: integer): integer;

begin
  GetInt := Buffer[Offset] + (Buffer[Offset + 1] SHL 8);
end;  { function GetInt }

{ - - - level 1 - - - }

procedure PutInt (Offset, Value: integer);

begin
  Buffer[Offset    ] := Lo (Value);
  Buffer[Offset + 1] := Hi (Value);
end;  { procedure PutInt }

{ - - - level 1 - - - }

procedure Skeleton;

begin
  Inline ($21 / $80 / $00 /     { LXI H, $0080 }
          $11 / $00 / $00 /     { LXI D,  .... }
          $01 / $80 / $00 /     { LXI B, $0080 }
          $ED / $B0 /           { LDIR         }
          $C3 / $00 / $00);     { JMP     .... }
end;  { procedure Skeleton }

{ - - - level 0b - - - }

begin  { program Patch }

  FileName := CmdString;
  while (Length (FileName) > 0) AND (FileName[1] = ' ') do
    Delete (FileName, 1, 1);
  if FileName = '' then
    Writeln ('PATCH takes the name of the file to patch as an argument.')
  else begin  { do it all }
    if Pos ('.', FileName) = 0 then
      FileName := FileName + '.COM';
    Assign (ComFile, FileName);
    Reset (ComFile);
    if IOResult <> 0 then
      Writeln ('Sorry, could not open ', FileName, '.')
    else begin  { find things out }
      Seek (ComFile, 0);
      BlockRead (ComFile, Buffer, 1);
      StartAddr := GetInt ($01);
      if StartAddr <> $1FC9 then
        Writeln ('Program appears to have been patched already!')
      else begin  { fix file }
        Seek (ComFile, (StartAddr - $100) SHR 7);
        BlockRead (ComFile, Buffer, 2);
        Base := StartAddr AND $7F;
        EndAddr := GetInt (Base + $10);
        CmdAddr := GetInt (Base + $04);

        Seek (ComFile, 0);
        BlockRead (ComFile, Buffer, 1);
        PutInt ($01, EndAddr);
        Seek (ComFile, 0);
        BlockWrite (ComFile, Buffer, 1);

        Seek (ComFile, ($400 - $100) SHR 7);
        BlockRead (ComFile, Buffer, 2);
        Buffer[$D1] := Buffer[$D7];  { eliminate terminal calls }
        Seek (ComFile, ($400 - $100) SHR 7);
        BlockWrite (ComFile, Buffer, 2);

        Seek (ComFile, (EndAddr - $100) SHR 7);
        BlockRead (ComFile, Buffer, 2);
        Base := EndAddr AND $7F;
        Move (Mem[Addr (Skeleton)], Buffer[Base], SkelSize);
        PutInt (Base + $04, CmdAddr  );
        PutInt (Base + $0C, StartAddr);
        Seek (ComFile, (EndAddr - $100) SHR 7);
        BlockWrite (ComFile, Buffer, (Base + SkelSize + 128) SHR 7);

        Close (ComFile)
      end { fix file }
    end { find things out }
  end { do it all }

end.  { program Patch }
