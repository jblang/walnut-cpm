program LibraryUtility;   { written 10/09/84 by Steve Freeman

  This program was written to function as Gary Novosielski's LU.  As such it
  will function as a utility to manipulate library members under any operating
  system which will support TURBO Pascal.  Minor rewrites may be necessary for
  other versions of Pascal.

  This program is placed into the Public Domain by the author and, as a Public
  Domain program, may NOT be used for commercial purposes.
}

const ProgramVersion = '1.00';
      BufferSize = 127;      { maximum size of data buffer - 1 }
      EntriesPerBuffer = 4;  { (BufferSize+1)/32 }
      maxent = 128;          { maximum dir entries this program will take }

type TimeType = integer;
     FileNameType = array[1..11] of char;
     LibFileType = file;

     EntryType = record
                   status: byte;
                   name: array[1..8] of char;
                   ext:  array[1..3] of char;
                   index: integer;
                   length: integer;
                   CRC: integer;
                   CreationDate: integer;
                   LastChangeDate: integer;
                   CreationTime: TimeType;
                   LastChangeTime: TimeType;
                   PadCount: byte;
                   filler: array[27..31] of byte;
                 end;
     EntryPtr = ^EntryType;

     hexstr = string[4];
     maxstr = string[255];
     filename = string[12];

var buffer: array[0..BufferSize] of byte;
    library, file2: file;
    SizeFile: file of byte;
    DirectoryChanged: boolean;
    LibName, fname: filename;
    LibSize, NumEntries: integer;
    LibEntry: EntryType;
    Dir: array[0..maxent] of EntryPtr;
    active, unused, deleted: integer;
{.cp7}
  procedure WaitKey;
    var c: char;
    begin
      write(^M^J,'Press any key to continue...');
      repeat until keypressed;
      read(kbd,c);
    end;
{.cp13}
  function Confirm: boolean;
    var c: char;
    begin
      write('Confirm operation (Y/N): ');
      repeat
          read(kbd,c);
          c := upcase(c);
        until (c in ['Y','N']);
      writeln(c);
      if c = 'Y'
        then Confirm := true
        else Confirm := false
    end;
{.cp9}
  function CommandLine: maxstr;
    var len, i: integer;
        str: maxstr;
    begin
      str := '';
      len := mem[cseg:$80];
      if len>1
        then for i:=2 to len do str := str + chr(mem[cseg:$80+i]);
      CommandLine := str;
    end;
{.cp13}
  function hex(num: integer): hexstr;
    var i, j: integer;
        h: string[16];
        str: hexstr;
    begin
      str := '0000';   h := '0123456789ABCDEF';   j := num;
      for i:=4 downto 1
        do begin
             str[i] := h[(j and 15)+1];
             j := j shr 4;
           end;
      hex := str;
    end;
{.cp14}
  procedure MakeName(f: filename; var name: FileNameType);
    var dotpos, endname, i: integer;
    begin
      for i:=1 to 11 do name[i] := ' ';
      dotpos := pos('.',f);
      if dotpos > 0
        then endname := dotpos-1
        else endname := length(f);
      for i:=1 to length(f) do f[i] := upcase(f[i]);
      if dotpos > 0
        then for i:=1 to 3 do if f[dotpos+i]<>' '
                                then name[8+i] := f[dotpos+i];
      for i:=1 to endname do name[i] := f[i];
    end;
{.cp8}
  procedure PutName(f: filename; n: integer);
    var i: integer;
        name: FileNameType;
    begin
      MakeName(f,name);
      for i:=1 to 8 do Dir[n]^.name[i] := name[i];
      for i:=1 to 3 do Dir[n]^.ext[i]  := name[i+8];
    end;
{.cp29}
  function FindMember(f: filename): integer;
    var member, dotpos, endname, i, k: integer;
        lookup: FileNameType;
        found: boolean;

    function NamesMatch(entry: integer): boolean;
      var match: boolean;
      begin
        NamesMatch := true;
        with Dir[entry]^
          do begin
               if (status <> 0) and (status <> $FE) then NamesMatch := false;
               for k:=1 to 8 do if name[k]<>lookup[k] then NamesMatch := false;
               for k:=1 to 3 do if ext[k]<>lookup[8+k] then NamesMatch := false;
             end;
      end;

    begin
      MakeName(f,lookup);
      found := false;   i := 1;
      while not(found) and (i<NumEntries)
        do if NamesMatch(i)
             then found := true
             else i := i + 1;

      if (active=1) or not(found)
        then FindMember := 0
        else FindMember := i
    end;
{.cp9}
  function Parse(f: filename): filename;
    var i: integer;
    begin
      for i:=1 to length(f) do f[i]:=upcase(f[i]);
      i := pos('.',f);
      if i>0 then f:=copy(f,1,i-1);
      f := f + '.LBR';
      Parse := f;
    end;
{.cp13}
  procedure WriteDirectoryToDisk(var lib: LibFileType);
    var member, i: integer;
    begin
      reset(lib);
      member := 0;
      while member < NumEntries
        do begin
             for i:=0 to EntriesPerBuffer-1 do move(Dir[member+i]^,buffer[32*i],32);
             blockwrite(lib,buffer,1);
             member := member + 4
           end;
      DirectoryChanged := false
    end;
{.cp6}
  procedure ZeroEntry(n: integer);
    begin
      fillchar(Dir[n]^,32,chr(0));      {clear the record}
      fillchar(Dir[n]^.name[1],11,' '); {clear file name}
      Dir[n]^.status := -1;             {mark unused}
    end;
{.cp38}
  procedure SortDir;
    var i, j: integer;

    function larger(a, b: integer): boolean;
      var ok, x: integer;
          c1, c2: char;
      begin
        ok := 0;   x := 1;
        if (Dir[a]^.status <> 0) and (Dir[b]^.status <> 0) then ok := 2;
        if (Dir[a]^.status <> 0) and (ok = 0) then ok := 1;
        if (Dir[b]^.status <> 0) and (ok = 0) then ok := 2;
        while (x < 12) and (ok=0)
          do begin
               c1 := Dir[a]^.name[x];   c2 := Dir[b]^.name[x];
               if c1 > c2 then ok := 1;
               if c1 < c2 then ok := 2;
               x := x + 1
             end;
        if ok=1
          then larger := true
          else larger := false
      end;

    procedure swap(x, y: integer);
      var temp: EntryPtr;
      begin
        temp   := Dir[x];
        Dir[x] := Dir[y];
        Dir[y] := temp
      end;

    begin
      for i:=1 to NumEntries-1
        do if Dir[i]^.status <> 0 then ZeroEntry(i);
      for i:=1 to NumEntries-2
        do begin
             for j:=i+1 to NumEntries-1
               do if larger(i,j) then swap(i,j);
           end;
    end;
{.cp22}
  procedure CreateDirectory;
    var i: integer;
    begin
      rewrite(library);
      clrscr;  writeln('Creating a new library.  Name = ',LibName);
      write('How many entries? ');  readln(i);
      NumEntries := i + 1; {add 1 for Directory entry}
      i := NumEntries MOD 4;
      if i<>0 then NumEntries := NumEntries + (4 - i);

      for i:=0 to NumEntries-1
        do begin
             new(Dir[i]);
             ZeroEntry(i);
           end;

      Dir[0]^.status := 0; {directory entry is always used}
      Dir[0]^.length := NumEntries DIV 4;
      active := 1;   unused := NumEntries - 1;   deleted := 0;
      WriteDirectoryToDisk(library);
    end;
{.cp26}
  procedure GetDirectory;
    var i, offset: integer;
    begin
      offset := 0;   DirectoryChanged := false;
      LibSize := (1 + filesize(library)) DIV 8;  {in kilobytes}
      blockread(library,buffer,1);
      new(Dir[0]);                 {make space for directory header}
      move(buffer[0],Dir[0]^,32);  {move header entry}
      NumEntries := (128 * Dir[0]^.length) DIV 32;
      for i:=1 to NumEntries-1
        do begin
             if (i MOD EntriesPerBuffer) = 0
               then begin {read next block}
                      blockread(library,buffer,1);
                      offset := offset + EntriesPerBuffer;
                    end;
             new(Dir[i]);
             move(buffer[32*(i-offset)],Dir[i]^,32);
           end;
      active := 1;   unused := 0;   deleted := 0;
      for i:=1 to NumEntries-1
        do if Dir[i]^.status=0
             then active := active + 1
             else if Dir[i]^.status=$FE
                    then deleted := deleted + 1
                    else unused := unused + 1;
    end;
{.cp8}
  procedure OpenLibrary;
    begin
      assign(library,LibName);
      {$I-} reset(library) {$I+};
      if IOresult=0
        then GetDirectory
        else CreateDirectory;
    end;
{.cp23}
  procedure Directory;
    var i, j: integer;
    begin
      clrscr;
      writeln('Library ',LibName,' is ',LibSize,'K',^M^J);
      writeln('  name          index  length    CRC');
      writeln('------------------------------------');
      for i:=1 to NumEntries-1
        do with Dir[i]^
             do begin
                  if status<>$FF
                    then begin
                           for j:=1 to 8 do write(name[j]);
                           write('.');
                           for j:=1 to 3 do write(ext[j]);
                           write(' ',index:8,length:8,'   ',hex(CRC));
                           if status=$FE then write('   deleted');
                           writeln;
                         end;
                end;
      writeln(^M^J,active,' active, ',unused,' unused, ',deleted,' deleted: ',active+unused+deleted,' total entries.');
      WaitKey;
    end;
{.pa}
  procedure Extract;
    var fname2: filename;
        i, blocknum, bytenum: integer;
    begin
      clrscr;   write('Enter filename to extract: ');  readln(fname2);
      if length(fname2)>0
        then begin
               i := FindMember(fname2);
               if i>0
                 then begin
                        assign(file2,fname2);
                        rewrite(file2);
                        with Dir[i]^
                          do begin
                               seek(library,index);
                               blocknum := 1;   bytenum := 0;
                               while blocknum <= length
                                 do begin
                                      blockread(library,buffer,1);
                                      if blocknum<=length
                                        then blockwrite(file2,buffer,1)
                                        else begin
                                               close(file2); {save disk info}
                                               assign(SizeFile,fname2);
                                               reset(SizeFile);
                                               seek(SizeFile,filesize(SizeFile));
                                               while bytenum < ((128 - PadCount) MOD 128)
                                                 do begin
                                                      write(SizeFile,buffer[bytenum]);
                                                      bytenum := bytenum + 1
                                                    end;
                                               close(SizeFile);
                                               reset(file2); {for later close}
                                             end;
                                      blocknum := blocknum + 1
                                    end;
                             end;
                        close(file2);
                      end
                 else writeln('member was not found!!');
             end;
      WaitKey;
    end;
{.cp27}
  procedure Delete;
    var fname2: filename;
        i: integer;
        ok: boolean;
    begin
      clrscr;   write('Enter member to delete: ');  readln(fname2);
      if length(fname2)>0
         then begin
                i := FindMember(fname2);
                if i>0
                  then begin
                         ok := Confirm;
                         write('Member ',fname2);
                         if ok
                           then begin
                                  Dir[i]^.status := $FE;
                                  deleted := deleted + 1;
                                  active := active - 1;
                                  writeln(' was deleted.');
                                  DirectoryChanged := true;
                                end
                           else writeln(' was NOT deleted.')
                       end
                  else writeln(fname2,' does not exist.');
                WaitKey;
              end;
    end;
{.cp21}
  procedure Undelete;
    var fname2: filename;
        i: integer;
        ok: boolean;
    begin
      clrscr;   write('Enter member to undelete: ');  readln(fname2);
      if length(fname2)>0
         then begin
                i := FindMember(fname2);
                if i>0
                  then begin
                         Dir[i]^.status := 0;
                         deleted := deleted - 1;
                         active := active + 1;
                         writeln(fname2,' was undeleted.');
                         DirectoryChanged := true;
                       end
                  else writeln(fname2,' does not exist.');
                WaitKey;
              end;
    end;
{.pa}
  procedure Add;
    var fname2: filename;
        EntryLength, EntryIndex, SizeOfFile, number, i: integer;
    begin
      number := 0;   i := 1;
      while (number = 0) and (i < NumEntries)
        do begin
             if (Dir[i]^.status=$FF) and (number=0)
               then number := i
               else i := i + 1;
           end;
      clrscr;
      if number > 0
        then begin
               write('Enter member to add: ');  readln(fname2);
               if length(fname2)>0
                 then begin
                        if FindMember(fname2) = 0
                          then begin
                                 assign(SizeFile,fname2);
                                 {$I-} reset(SizeFile) {$I+};
                                 if IOresult=0
                                   then begin
                                          SizeOfFile := filesize(SizeFile);
                                          close(SizeFile);

                                          assign(file2,fname2);
                                          reset(file2);
                                          EntryIndex  := filesize(library);
                                          EntryLength := filesize(file2);
                                          seek(library,EntryIndex);
                                          while not(eof(file2))
                                            do begin
                                                 blockread(file2,buffer,1);
                                                 blockwrite(library,buffer,1)
                                               end;
                                          close(file2);

                                          fillchar(Dir[number]^,32,chr(0)); {status:=0}
                                          Dir[number]^.index  := EntryIndex;
                                          Dir[number]^.length := EntryLength;
                                          Dir[number]^.PadCount := (128 - (SizeOfFile MOD 128)) and $7F;
                                          PutName(fname2,number);
                                          unused := unused - 1;
                                          active := active + 1;
                                          write('Member ',fname2,' was added.');
                                          DirectoryChanged := true;
                                        end
                                   else writeln('File ',fname2,' was not found.');
                               end
                          else writeln(fname2,' is already a member.');
                      end;
             end
        else writeln('There are no available places to put this entry.');
      WaitKey;
    end;
{.pa}
  procedure Reorganize;
    var i, j: integer;
    begin
      SortDir;
      assign(file2,'WORK-$$$.LBR');
      reset(library);   rewrite(file2);
      WriteDirectoryToDisk(file2);
      for i:=1 to NumEntries-1
        do with Dir[i]^
             do begin
                  if (status = 0) and (length > 0)
                    then begin
                           writeln('Copying: ',name,'.',ext,'  ',filepos(file2));
                           seek(library,index);
                           index := filepos(file2);
                           for j:=1 to length
                             do begin
                                  blockread (library,buffer,1);
                                  blockwrite(file2,  buffer,1)
                                end
                         end
                end;
      WriteDirectoryToDisk(file2);
      close(file2);     close(library);
      erase(library);   rename(file2,LibName);
      reset(library);
    end;
{.cp8}
  procedure HelpCmdLine;
    begin
      clrscr;
      writeln(^M^J,'You must enter a file name:');
      writeln(^M^J,'LU <filename>[.LBR]');
      writeln(^M^J,'NOTE: the .LBR suffix is optional.');
      WaitKey;
    end;
{.cp14}
  procedure Help;
    begin
      clrscr;
      writeln('Library Utility Commands:',^M^J);
      writeln('Add       - add a new member, can''t be duplicate');
      writeln('Directory - gives the listing of this library''s directory');
      writeln('Extract   - copy a member out to its own file');
      writeln('Kill      - delete a member from the library');
      writeln('Undelete  - reverses the effects of a delete');
      writeln('Reorganize- compresses blank space in library');
      writeln('eXit      - terminate this program');
      writeln('Help      - gives this screen');
      WaitKey;
    end;
{.pa}
  procedure Menu;
    var selection: char;
    begin
      OpenLibrary;
      repeat
          clrscr;
          gotoxy(30,2);  write('Library Utility Menu');
          gotoxy(35,3);  write('version ',ProgramVersion);
          gotoxy(40-length(LibName) DIV 2,5);  write(LibName);
          gotoxy(10,07); write('D - directory');
          gotoxy(10,08); write('E - extract member');
          gotoxy(10,09); write('A - add member');
          gotoxy(10,10); write('K - delete member');
          gotoxy(10,11); write('U - undelete member');
          gotoxy(10,12); write('R - reorganize library');
          gotoxy(10,13); write('X - exit');
          gotoxy(10,14); write('? - help');
          gotoxy(20,20); write('choose one: ');
          repeat
              repeat until keypressed;
              read(kbd,selection);
              selection := upcase(selection);
            until (selection in ['A','D','E','K','R','U','X','?']);
          writeln(selection);
          case selection of
            'A': Add;
            'D': Directory;
            'E': Extract;
            '?': Help;
            'K': Delete;
            'R': Reorganize;
            'U': Undelete;
          end;
        until selection='X';
      if DirectoryChanged then WriteDirectoryToDisk(library);
      close(library);
    end;
{.cp8}
begin {Main}

  LibName := Parse(CommandLine);
  if length(CommandLine) = 0
    then
        begin
             write('Enter name of library file:  ');
             Read(fname);
             Libname := Parse(fname);
             Menu;
        end
    else Menu;

end.
