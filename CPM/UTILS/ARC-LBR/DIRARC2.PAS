program darc2;
{$R-$U-$C-$K-}
{
  Program:      DIRARC.PAS
  Version:      2.0
  Date:         6/1/86
  Author:       Steve Fox, Albuquerque ROS (505)299-5974
  Revision:     David W. Carroll, High Sierra RBBS (209) 296-3534
  Credits:      Based heavily on DARC.PAS and intended as a companion to
                that program.
  Description:  Display the directory of an archive created by version 4.30
                or earlier of the ARC utility (copyright 1985 by System
                Enhancement Associates) in a format similar to the "v"erbose
                command.  Some minor differences in the computed values of the
                stowage factors may be noted due to rounding.
  Upadtes: 2.0  Supports ARC512 added modes. Displays mode number as item "T"
                as well as complete text description of arc mode.
  Language:     Turbo Pascal Version 3.0 and later (either MS-DOS or CP/M).
  Usage:        DIRARC arcname
                where arcname is the path/file name of the archive file.  If
                the file extent is omitted, .ARC is assumed.
}
const
  BLOCKSIZE = 128;
  arcmarc   = 26;                      { special archive marker }
  arcver    = 8;                       { archive header version code }
  strlen    = 80;                      { standard string length }
  fnlen     = 12;                      { file name length - 1 }
type
  long      = record                   { used to simulate long (4 byte) integers }
                l, h : integer
              end;
  Str10     = string[10];
  StrStd    = string[strlen];
  fntype    = array [0..fnlen] of char;
  buftype   = array [1..BLOCKSIZE] of byte;
  heads     = record
                name   : fntype;
                size   : long;
                date   : integer;
                time   : integer;
                crc    : integer;
                length : long
              end;
  hexvalue  = string[2];
var
  endfile   : boolean;
  hdrver    : byte;
  arcptr    : integer;
  arcname,
  extname   : StrStd;
  arcbuf    : buftype;
  arcfile   : file;

function hexval(bt : byte) : hexvalue;
{ Convert 8 bit value to hex }
  const
    hexcnv : array[0..15] of char = '0123456789ABCDEF';
  begin
    hexval := hexcnv[bt shr 4] + hexcnv[bt and $0F]
  end;

function pad(stg : StrStd; i : integer) : StrStd;
{ Pad string with spaces to length of i }
  var
    j : integer;
  begin
    j := length(stg);
    FillChar(stg[succ(j)], i - j, ' ');
    stg[0] := chr(i);
    pad := stg
  end;

function intstr(n, w: integer): Str10;
{ Return a string value (width 'w')for the input integer ('n') }
  var
    stg: Str10;
  begin
    str(n:w, stg);
    intstr := stg
  end;

procedure abort(msg : StrStd);
{ terminate the program with an error message }
  begin
    writeln('ABORT: ', msg);
    halt
  end;

function fn_to_str(var fn : fntype) : StrStd;
{ convert strings from C format (trailing 0) to
  Turbo Pascal format (leading length byte). }
  var
    s : StrStd;
    i : integer;
  begin
    s := '';
    i := 0;
    while fn[i] <> #0 do
      begin
        s := s + fn[i];
        i := succ(i)
      end;
    fn_to_str := s
  end;

function unsigned_to_real(u : integer) : real;
{ convert unsigned integer to real }
{ note: INT is a function that returns a REAL!!!}
  begin
    if u >= 0
      then unsigned_to_real := Int(u)
    else if u = $8000
      then unsigned_to_real := 32768.0
      else unsigned_to_real := 65536.0 + u
  end;

function long_to_real(l : long) : real;
{ convert long integer to a real }
{ note: INT is a function that returns a REAL!!! }
  const
    rcon = 65536.0;
  var
    r : real;
    s : (POS, NEG);
  begin
    if l.h >= 0
      then
        begin
          r := Int(l.h) * rcon;
          s := POS
        end
      else
        begin
          s := NEG;
          if l.h = $8000
            then r := rcon * rcon
            else r := Int(-l.h) * rcon
        end;
    r := r + unsigned_to_real(l.l);
    if s = NEG
      then long_to_real := -r
      else long_to_real := r
  end;

procedure Read_Block;
{ read a block from the archive file }
  begin
    if EOF(arcfile)
      then endfile := TRUE
      else BlockRead(arcfile, arcbuf, 1);
    arcptr := 1
  end;

function get_arc : byte;
{ read 1 character from the archive file }
  begin
    if endfile
      then get_arc := 0
      else
        begin
          get_arc := arcbuf[arcptr];
          if arcptr = BLOCKSIZE
            then Read_Block
            else arcptr := succ(arcptr)
        end
  end;

procedure fread(var buf; reclen : integer);
{ read a record from the archive file }
  var
    i : integer;
    b : array [1..strlen] of byte absolute buf;
  begin
    for i := 1 to reclen
      do b[i] := get_arc
  end;

function readhdr(var hdr : heads) : boolean;
{ read a file header from the archive file }
{ FALSE = eof found; TRUE = header found }
  var
    try  : integer;
    name : fntype;
  begin
    try := 10;
    if endfile
      then
        begin
          readhdr := FALSE;
          exit
        end;
    while get_arc <> arcmarc do
      begin
        if try = 0
          then abort(arcname + ' is not an archive');
        try := pred(try);
        writeln(arcname, ' is not an archive, or is out of sync');
        if endfile
          then abort('Archive length error')
      end;

    hdrver := get_arc;
    if hdrver < 0
      then abort('Invalid header in archive ' + arcname);
    if hdrver = 0
      then
        begin                          { special end of file marker }
          readhdr := FALSE;
          exit
      end;
    if hdrver > arcver
      then
        begin
          fread(name, fnlen);
          writeln('Cannot handle file ', fn_to_str(name), ' in archive ',
            arcname);
          writeln('You need a newer version of this program.');
          halt
        end;

    if hdrver = 1
      then
        begin
          fread(hdr, sizeof(heads) - sizeof(long));
          hdrver := 2;
          hdr.length := hdr.size
        end
      else fread(hdr, sizeof(heads));

    readhdr := TRUE
  end;

procedure PrintHeading;
  begin
    writeln;
    writeln('Turbo Pascal DIRARC Utility');
    writeln('Version 2.0, 6/1/86');
    writeln('Lists the directory of .ARC files ');
    writeln('created with ARC version 5.12 and earlier');
    writeln
  end;

procedure GetArcName;
{ get the name of the archive file }
  var
    i : integer;
  begin
    if ParamCount = 1
      then arcname := ParamStr(1)
    else if ParamCount > 1
      then abort('Too many parameters')
      else
        begin
          write('Enter archive filename: ');
          readln(arcname);
          if arcname = ''
            then abort('No file name entered');
          writeln;
          writeln
        end;
    for i := 1 to length(arcname) do
      arcname[i] := UpCase(arcname[i]);
    if pos('.', arcname) = 0
      then arcname := arcname + '.ARC'
  end;

function int_time(time : integer) : StrStd;
{ Convert integer format time to printable string }
  var
    ampm : char;
    hour, minute : integer;
    line : string[6];
  begin
    minute := (time shr 5) and $003F;
    hour   := time shr 11;
    if hour > 12
      then
        begin
          hour := hour - 12;
          ampm := 'p'
        end
      else ampm := 'a';
    if hour = 0
      then hour := 12;
    line := intstr(hour, 2) + ':' + intstr(minute, 2) + ampm;
    if line[4] = ' '
      then line[4] := '0';
    int_time := line
  end;

function int_date(date : integer) : StrStd;
{ Convert standard integer format date to printable string }
  const
    month_name : array[1..12] of string[3] =
      ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
  var
    day, month, year : integer;
    line : string[9];
  begin
    day   := date and $001F;
    month := (date shr 5) and $000F;
    year  := (date shr 9 + 80) mod 100;
    if month in [1..12]
      then line := month_name[month]
      else line := '   ';
    line := intstr(day, 2) + ' ' + line + ' ' + intstr(year, 2);
    if line[8] = ' '
      then line[8] := '0';
    int_date := line
  end;

procedure open_arc;
{ open the archive file for input processing }
  begin
    {$I-} assign(arcfile, arcname); {$I+}
    if IOresult <> 0
      then abort('Cannot open archive file.');
    {$I-} reset(arcfile); {$I+}
    if IOresult <> 0
      then abort('Cannot open archive file.');
    endfile := FALSE;
    Read_Block
  end;

procedure close_arc;
{ close the archive file }
  begin
    close(arcfile)
  end;

procedure directory;
  const
    stowage : array[1..8] of string[8] =
      (' -None- ', ' -None- ', ' Packed ', 'Squeezed', 'LZCrunch', 'LZCrunch',
      'LZW Pack','Dynam LZ');
  var
    i, total_files, sf : integer;
    size_org, size_now, next_ptr, total_length, total_size : real;
    stg_time, stg_date : Str10;
    hdr : heads;
  begin
    writeln('Name          Length    Stowage  T   SF   Size now  Date       Time    CRC');
    writeln('============  ========  ======== =  ====  ========  =========  ======  ====');
    total_files  := 0;
    next_ptr     := 0.0;
    total_size   := 0.0;
    total_length := 0.0;
    open_arc;
    while readhdr(hdr) do
      begin
        extname := fn_to_str(hdr.name);
        total_files := succ(total_files);
        size_org := long_to_real(hdr.length);
        total_length := total_length + size_org;
        size_now := long_to_real(hdr.size);
        total_size := total_size + size_now;
        stg_time := int_time(hdr.time);
        stg_date := int_date(hdr.date);
        if size_org > 0
          then sf := round(100.0 * (size_org - size_now) / size_org)
          else sf := 0;
        writeln(
          pad(extname, 12),
          size_org:10:0,
          stowage[hdrver]:10,
          hdrver:2,
          sf:5, '%',
          size_now:10:0,
          stg_date:11,
          stg_time:8,
          hexval(hi(hdr.crc)):4, hexval(lo(hdr.crc)):2);
        next_ptr := next_ptr + size_now + 29.0;
        i := trunc(next_ptr / 128.0);
        seek(arcfile, i);
        Read_Block;
        arcptr := succ(round(next_ptr - 128.0 * i))
      end;
    close_arc;
    writeln('        ====  ========              ====  ========');
    if total_length > 0
      then sf := round(100.0 * (total_length - total_size) / total_length)
      else sf := 0;
    writeln(
      'Total',
      total_files:7,
      total_length:10:0,
      ' ':10,
      '  ',
      sf:5, '%',
      total_size:10:0)
  end;

begin
  PrintHeading;                        { print a heading }
  GetArcName;                          { get the archive file name }
  directory
end.
    