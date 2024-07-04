program uudecode;

  CONST defaultSuffix = '.uue';
        offset = 32;

  TYPE string80 = string[80];

  VAR infile: text;
      outf : file;
      lineNum: integer;
      line: string80;
      outfilename : string80;

{Binary file read added by Ross Alford,  ...!mcnc!ecsvax!alford.  The original
 MSDOS versions of uuencode/decode just use read/write on a FILE OF BYTE.
 CP/M Turbo expects some file info to be stored in the first 4 bytes of files
 of any type other than TEXT.  Putbyte (below) and Getbyte (in UUENCODE)
 bypass this 'feature' by using blockread and blockwrite.  The only global
 variables either use are  'infilename' and 'inf' or 'outfilename' and 'outf'}

procedure putbyte(b : byte; flush : boolean);

type bufptr = ^bufrec;
     bufrec = record
                next : bufptr;
                buffer : array[1..128] of byte
              end;

const sectstobuf = 8;                {max number of sectors to buffer}
      sectswritten : integer = 1;    {constants are essentially statics}
      bytptr : integer = 1;
      notopen : boolean = TRUE;
      infsize : integer = 0;
      listsaveofs : integer = 0;
      listsaveseg : integer = 0;
      tempsaveofs : integer = 0;
      tempsaveseg : integer = 0;

var list,temp,temp2 : bufptr;
    i : integer;

begin
  if flush then
    begin
      list := ptr(listsaveseg,listsaveofs);
      temp := list;
      for i := 1 to sectswritten do
        begin
          blockwrite(outf,temp^.buffer,1);
          temp := temp^.next
        end;
      close(outf)
    end
    else begin
      if notopen then
        begin
          notopen := FALSE;
          assign(outf,outfilename);
          {$i-}
          reset(outf);
          {$i+}
          if ioresult = 0 then
            begin
              writeln('File ',outfilename,' exists.  Cannot overwrite.');
              halt
            end;
          {$i-}
          rewrite(outf);
          {$i+}
          if ioresult <> 0 then
            begin
              writeln('Cannot open file ',outfilename,' for output.');
              halt
            end;
          new(list);
          temp := list;
          for i := 1 to sectstobuf - 1 do
            begin
              new(temp2);
              temp2^.next := NIL;
              temp^.next := temp2;
              temp := temp2
            end;
          listsaveofs := ofs(list^);
          listsaveseg := seg(list^);
          tempsaveofs := listsaveofs;
          tempsaveseg := listsaveseg;
        end;
      temp := ptr(tempsaveseg,tempsaveofs);
      if bytptr > 128 then
        begin
          if temp^.next <> NIL then
            begin
              sectswritten := succ(sectswritten);
              temp := temp^.next;
              bytptr := 1
            end
            else begin
              temp := ptr(listsaveseg,listsaveofs);
              for i := 1 to sectstobuf do
                begin
                  blockwrite(outf,temp^.buffer,1);
                  temp := temp^.next
                end;
              temp := ptr(listsaveseg,listsaveofs);
              sectswritten := 1;
              bytptr := 1
            end
        end;
      temp^.buffer[bytptr] := b;
      bytptr := succ(bytptr);
      tempsaveofs := ofs(temp^);
      tempsaveseg := seg(temp^)
    end
end;

  procedure Abort(message: string80);

    begin {abort}
      writeln;
      if lineNum > 0 then write('Line ', lineNum, ': ');
      writeln(message);
      halt
    end; {Abort}

  procedure NextLine(var s: string80);

    begin {NextLine}
      LineNum := succ(LineNum);
      write('.');
      readln(infile, s)
    end; {NextLine}

  procedure Init;

    procedure GetInFile;

      VAR infilename: string80;

      begin {GetInFile}
        if ParamCount = 0 then abort ('Usage: uudecode <filename>');
        infilename := ParamStr(1);
        if pos('.', infilename) = 0
          then infilename := concat(infilename, defaultSuffix);
        assign(infile, infilename);
        {$i-}
        reset(infile);
        {$i+}
        if IOresult > 0 then abort (concat('Can''t open ', infilename));
        writeln ('Decoding ', infilename)
      end; {GetInFile}

    procedure GetOutFile;

      var header, mode : string80;
          ch: char;

      procedure ParseHeader;

        VAR index: integer;

        Procedure NextWord(var word:string80; var index: integer);

          begin {nextword}
            word := '';
            while header[index] = ' ' do
              begin
                index := succ(index);
                if index > length(header) then abort ('Incomplete header')
              end;
            while header[index] <> ' ' do
              begin
                word := concat(word, header[index]);
                index := succ(index)
              end
          end; {NextWord}

        begin {ParseHeader}
          header := concat(header, ' ');
          index := 7;
          NextWord(mode, index);
          NextWord(outfilename, index)
        end; {ParseHeader}

      begin {GetOutFile}
        if eof(infile) then abort('Nothing to decode.');
        NextLine (header);
        while not ((copy(header, 1, 6) = 'begin ') or eof(infile)) do
          NextLine(header);
        writeln;
        if eof(infile) then abort('Nothing to decode.');
        ParseHeader;
      end; {GetOutFile}

    begin {init}
      lineNum := 0;
      GetInFile;
      GetOutFile;
    end; { init}

  Function CheckLine: boolean;

    begin {CheckLine}
      if line = '' then abort ('Blank line in file');
      CheckLine := not (line[1] in [' ', '`'])
    end; {CheckLine}


  procedure DecodeLine;

    VAR lineIndex, byteNum, count, i: integer;
        chars: array [0..3] of byte;
        hunk: array [0..2] of byte;

{    procedure debug;

      var i: integer;

      procedure writebin(x: byte);

        var i: integer;

        begin
          for i := 1 to 8 do
            begin
              write ((x and $80) shr 7);
              x := x shl 1
            end;
          write (' ')
        end;

      begin
        writeln;
        for i := 0 to 3 do writebin(chars[i]);
        writeln;
        for i := 0 to 2 do writebin(hunk[i]);
        writeln
      end;      }

    function nextch: char;

      begin {nextch}
      {}  lineIndex := succ(lineIndex);
        if lineIndex > length(line) then abort('Line too short.');
        if not (line[lineindex] in [' '..'`'])
          then abort('Illegal character in line.');
{        write(line[lineindex]:2);}
        if line[lineindex] = '`' then nextch := ' '
                                  else nextch := line[lineIndex]
      end; {nextch}

    procedure DecodeByte;

      procedure GetNextHunk;

        VAR i: integer;

        begin {GetNextHunk}
          for i := 0 to 3 do chars[i] := ord(nextch) - offset;
          hunk[0] := (chars[0] shl 2) + (chars[1] shr 4);
          hunk[1] := (chars[1] shl 4) + (chars[2] shr 2);
          hunk[2] := (chars[2] shl 6) + chars[3];
          byteNum := 0  {;
          debug          }
        end; {GetNextHunk}

      begin {DecodeByte}
        if byteNum = 3 then GetNextHunk;
        putbyte(hunk[byteNum],FALSE);
        {writeln(bytenum, ' ', hunk[byteNum]);}
        byteNum := succ(byteNum)
      end; {DecodeByte}

    begin {DecodeLine}
      lineIndex := 0;
      byteNum := 3;
      count := (ord(nextch) - offset);
      for i := 1 to count do DecodeByte
    end; {DecodeLine}

  procedure terminate;

    var trailer: string80;

    begin {terminate}
      if eof(infile) then abort ('Abnormal end.');
      NextLine (trailer);
      if length (trailer) < 3 then abort ('Abnormal end.');
      if copy (trailer, 1, 3) <> 'end' then abort ('Abnormal end.');
      close (infile);
      putbyte(26,TRUE)
    end;

  begin {uudecode}
    init;
    NextLine(line);
    while CheckLine do
      begin
        DecodeLine;
        NextLine(line)
      end;
    terminate
  end.
