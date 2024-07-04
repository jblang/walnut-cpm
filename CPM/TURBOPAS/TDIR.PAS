{
  CP/M-80 directory program written in Turbo Pascal 2.0.
  Based loosely on wildcard.pas, author and compiler unknown.
  Accepts ambiguous file names and displays sorted directory.
    File sizes rounded to next 1k increment.
  Steve Fox - Albuquerque RCP/M  (505)299-5974
  Version 1.0     29 Mar 1985

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  Revised 23 Apr 85 by : William L. Mabee, CRNA Followin attributes added
  Functions  :
   Centered
   Dash
   ConstStr
  Procedures :
   PutItUp

  Changed Code to allow automatic display of logged DU directory will allow
  code to be included in Turbo Pascal Program or chaining from main turbo
  routine.

  Added prompt for which drive change source for your own system
  if you have more than two drives add something like ['A..P']; and
  change appropriate prompt.

  Added code to display total amount disk space used.

  Added header.

}

Program dir;
label start;
const
  columns   = 4;
  fence     = ' | ';
  header    = 'File     Ext Size   File     Ext Size   File     Ext Size   File     Ext Size';
type
  CharSet   = set of char;
  FileName  = string[14];                   { d:filename.ext }
  str80     = string[80];
  StrStd    = string[127];
  FilePtr   = ^FileDescr;
  FileDescr =
    record
      fname: FileName;                      { Name of a matching file }
      fsize: integer;                       { Size of file }
      Next: FilePtr;                        { Points to next name on linked list }
    end;
  FileBlock =
    record
      case boolean of
        true:
          (drive: byte;                     { Byte code }
           fname: array[1..11] of char;     { File name }
           extent,                          { Current extent }
           s1, s2, reccount: byte;          { Used to compute file size }
           dn: array[16..31] of byte);
        false:
          (init: array[1..32] of byte);
    end;

var
  CH : Char;
  entries: integer;                         { Count of directory entries }
  prototype: FileName;                      { Directory mask }
  first: FilePtr;                           { Start of linked list }
  searchblk: FileBlock;                     { Block for search }
  CtrPrg: File;

Function ConstStr(C : Char; N : Integer) : Str80;
var
  S : string[80];
begin
  if N < 0 then
    N := 0;
  S[0] := Chr(N);
  FillChar(S[1],N,C);
  ConstStr := S;
end;

Function Centered(TheString:Str80):Str80;
begin
  Centered := ConstStr(' ',((80 - Length(TheString)) Div 2)) +
  TheString;
end;

Function Dash(Spaces : Integer) : Str80;
var
  Column : Integer;
  Temp   : Str80;
begin
  Temp :='';
  For Column := 1 to Spaces do
  begin
    Temp := Temp + '-';
    Dash := Temp;
  end;
end;

Function Tab(Spaces : Integer) : Str80;
var
  Column : Integer;
  Temp   : Str80;
begin
  Temp :='';
  For Column := 1 to Spaces do
  begin
    Temp := Temp + '-';
    Dash := Temp;
  end;
end;

Procedure Choice(    Prompt : Str80;
                     Term   : CharSet;
                 var TC     : Char    );
var
  Ch : Char;
begin
  GotoXY(1,23); Write(Prompt); ClrEol;
  repeat
    Read(Kbd,Ch);
    TC := Upcase(Ch);
    if not (TC in Term) then
      write(^G);
  until TC in Term;
  Write(Ch);
end;

Procedure ClearFrame;
var
  I : Integer;
begin
  for I := 20 downto 3  do
  begin
    GotoXY(1,I + 1); ClrEol ;
  end;
end;

  procedure GetMask(var prototype: FileName);
  { Get ambiguous file name and expand into directory mask (prototype) }
    var
      i, j: integer;
      line: StrStd;

    function trim(st: StrStd): StrStd;
    { Trim leading and trailing blanks }
      var
       i, j: integer;
      begin
        i := 1;
        j := length(st);
        while (st[i] = ' ') and (i <= j) do
          i := succ(i);
        while (st[j] = ' ') and (j >= i) do
          j := pred(j);
        trim := copy(st, i, j - i + 1)
      end;

    function pad(line: StrStd; i: integer): StrStd;
    { Pad line with spaces to length of i }
      begin
        while length(line) < i do
          line := line + ' ';
        pad := line
      end;

    begin
      repeat
        Choice('Directory for which drive ( A or B ) ? ',['A','B'],Ch);
      until Ch <> '';
      ClearFrame;
      line := Ch+':*.*';
      line := trim(line);
      for i := 1 to length(line) do
        line[i] := UpCase(line[i]);
      if line = ''
        then line := '*.*';
      line := pad(line, 14);
      prototype := copy(line, 1, 14);
      FillChar(searchblk.init, 32, 0);
      with searchblk do
        begin
          if prototype[2] = ':'
            then
              begin
                drive := succ(ord(prototype[1]) - ord('A'));
                i := 3
              end
            else
              begin
                drive := 0;
                i := 1
              end;
          fname := '           ';
          j := 1;
          repeat
            begin
              if prototype[i] = '*'
                then while j <= 8 do
                  begin
                    fname[j] := '?';
                    j := succ(j)
                  end
                else
                  begin
                    fname[j] := prototype[i];
                    j := succ(j)
                  end
            end;
            i := succ(i)
          until (j > 8) or (prototype[i] = '.');

          while (prototype[i] <> '.') and (prototype[i] <> ' ') do
            i := succ(i);

          i := succ(i);
          j := 9;
          repeat
            begin
              if prototype[i] = '*'
                then while j <= 11 do
                  begin
                    fname[j] := '?';
                    j := succ(j)
                  end
                else
                  begin
                    fname[j] := prototype[i];
                    j := succ(j)
                  end
            end;
            i := succ(i)
          until (j > 11) or (prototype[i] = '.');
          extent := ord('?');
          s1     := ord('?');
          s2     := ord('?')
        end
    end;

  procedure ReadDir(prototype: filename; var entries: integer; var first: FilePtr);
  { Create an alphabetized list of files which match the prototype }
    const
      findfirst = 17;                       { BDOS function - search for first file }
      findnext  = 18;                       { BDOS function - search for next file}
      setdma    = 26;                       { BDOS function - set dma buffer address }
      fcb       = $80;                      { Default dma buffer address }
    type
      dirblock  = array [0..3] of FileBlock;
      fileblptr = ^FileBlock;
    var
      off: integer;                         { dir entry offset or end flag }
      fn: FileName;
      answerblk: dirblock;                  { block to receive file name }

    procedure insertfile(fn: FileName; fs: integer; var entries: integer; var first: FilePtr);
    { Insert a new file name in the alphabetic list }
      var
        f,                                  { file name entry being created }
        this, previous: FilePtr;            { followers for insertion }
      begin
        previous := nil;
        this := first;
        while (this <> nil) and (this^.fname < fn) do
          begin
            previous := this;
            this := this^.next
          end;
        if this^.fname <> fn
          then
            begin
              entries := succ(entries);
              new(f);
              f^.fname := fn;
              f^.fsize := fs;
              f^.next  := this;
              if previous = nil
                then first := f
                else previous^.next := f
            end
          else if this^.fsize < fs
                 then this^.fsize := fs
      end;

    begin { ReadDir }
      entries := 0;
      first := nil;
      BDOS(setdma, addr(answerblk));
      off := BDOS(findfirst, addr(searchblk));
      while off <> 255 do
        begin
          with answerblk[off] do
            if (ord(fname[10]) and $80) = 0 { Non-system? }
              then
                begin
                  drive := 11;              { File name length }
                  move(drive, fn, 12);      { File name }
                  insert('.', fn, 9);
                  insertfile(fn, reccount + (extent + (s2 shl 5)) shl 7, entries, first)
                end;
          off := BDOS(findnext, addr(searchblk));
        end;
      BDOS(setdma, fcb)                     { Restore DMA buffer }
    end;

  procedure DispDir(entries: integer; first: FilePtr);
  { Display directory list }
    var
      i, size,totsize: integer;
      OldName: FilePtr;
    begin
      i := 0;
      totsize := 0;
      GotoXY(1,6);
      WriteLn(Header); WriteLn;
      while first <> nil do
        begin                               { Scan the whole list }
          size := first^.fsize shr 3;
          totsize := totsize + size;
          if 0 <> (first^.fsize mod 8)
            then size := succ(size);
          write(first^.fname, size:4, 'k');
          i := succ(i);
          Oldname := first;
          first := first^.Next;             { Go to next on chain }
          dispose(Oldname);                 { Reclaim space }
          if i < columns
            then write(fence)
            else
              begin
                writeln;
                i := 0
              end
        end;
        WriteLn;
        WriteLn;
        write('Total number of Files : ',entries);
        writeln('              Using a total of : ',totsize,' K');
    end;

  begin { main }
    ClrScr;
    GotoXY(1,1); Writeln(ConstStr('-',79)); WriteLn; Write(ConstStr('-',79));
    GotoXY(1,2); Write(Centered('Disk Directory Routine'));
    GotoXY(1,22); Writeln(ConstStr('-',79)); WriteLn; Write(ConstStr('-',79));
    start :
    clearFrame;
    GetMask(prototype);                     { Read mask }
    ReadDir(prototype, entries, first);     { Read directory }
    DispDir(entries, first);                { Display directory }
    repeat
      Choice('Do directory on another drive ( Y or N ) : ',['Y','N'],CH);
      if Ch = 'Y' then goto start;
    until Ch = 'N';
    ClrScr;
  end.
