{$U-}
{$C-}
{
  TYPEX.PAS  Jim Mischel, June 1, 1986

  Program listing and variable cross-reference generator for
  Turbo Pascal programs.

  Usage is TYPEX <source> [<destination>] [;<options>]
     Options are: I - INCLUDE files also
                  X - Create program Cross-reference
     Defaults:
        Output   - LST:
        Includes - NO
        Xref     - NO

  If memory size is a consideration, INITIALIZE, PROCESS_FILE, and PRINT_XREF
  can be made overlay procedures, with a savings of approximately 2.5K bytes.

  This program evolved from LISTER.PAS that was included on the Turbo Pascal
  distribution disk.  Some of the original code still exists.

  The procedure GETDATE may have to be changed for use with MS-DOS.
  It will NOT work with CP/M 2.2 without modification.  It will work
  with MP/M, CP/M 3.x, and TurboDOS 1.3 or higher.

  This program was written using Turbo Pascal version 3.0 for CP/M.  I have
  not tested it on any other operating system, though it should work except
  as noted above.

  MODIFICATIONS:

  06/01/86 - jim - Initial coding.

  10/21/86 - jim - Use a pointer-reversal in PRINT_REFS in place of the
                   recurrsive list traversal.

  11/30/86 - jim - Make the tree a right in-threaded tree.  This speeds
                   printing of the cross-reference.
                   Add the FSTPTR field to the node record.  References are
                   now added in order of occurance.  FSTPTR points to the
                   first reference record, and NXTPTR points to the last.
                   Also added NUMREFS to the record to prevent having
                   to scan the list twice.  PRINT_REFS is now a simple linked
                   list traversal procedure.
}
program typex;
const
  version_no    = '2.5';
  printwidth    = 70;                   { print width for each line }
  printlength   = 55;                   { # of lines to print on each page }
  pathlength    = 14;                   { maximum length of file name }
  default_output = 'LST:';              { default destination }
  include_default = false;              { default to no include files }
  xref_default  = false;                { default to no cross-reference }
  refs_per_line = 10;                   { max. number of references per line }
  max_id_len    = 15;                   { max. id length for references on same line }
  optchr        = ';';                  { option seperator character }

type
  filename      = string[pathlength];
  string8       = string[8];
  string255     = string[255];
  strptr        = ^string255;
  refptr        = ^reference;
  reference     = record                { item reference record }
                    line,               { source line of reference }
                    incl     : integer; { line in include file (if any) }
                    nxtptr   : refptr;  { pointer to next reference }
                  end;

  itmptr        = ^item;
  item          = record
                    idname : strptr;    { pointer to id name }
                    left,               { left node of binary tree }
                    right  : itmptr;    { right node of binary tree }
                    rthrd  : boolean;   { TRUE if right is thread pointer }
                    fstptr,             { pointer to first reference }
                    nxtptr : refptr;    { pointer to last reference }
                    numrefs : integer;  { Reference counter.  This is NOT a
                                          count of references to this ID.  It
                                          is used by PRINT_REFS to figure out
                                          how many lines it will take to print
                                          all the references for this item. }
                  end;
var
  page_no,                              { current page number }
  currow        : integer;              { current row in output file }
  outfile,                              { listing file }
  mainfile      : text;                 { source file }
  mainfilename  : filename;             { input file name }
  search        : array[1..4] of string[4]; { search strings for includes }
  date,                                 { date returned from get_date }
  time          : string8;              { time returned from get_date }
  dots          : string[70];           { line of dots for page header }
  xref,                                 { TRUE = generate cross-reference }
  includes      : boolean;              { TRUE = process include files }
  xref_head     : itmptr;               { root of cross-reference tree }

{ PAGE - move output to new page }
procedure page(var outfile : text);
const
  ff            = ^L;
begin
  write(outfile,ff);
end;

{ HEADINGS - move to new page and print headings. }
procedure headings;
begin
  page(outfile);
  page_no := page_no + 1;
  write(outfile,date:8);
  write(outfile,mainfilename:39);
  writeln(outfile,time:33);
  writeln(outfile,dots,'Page ',page_no:5);
  writeln(outfile);
  currow := 0;
end; { headings }

{ OPEN - open file FP with name NAME. Return TRUE if operation successful. }
function open(var fp : text; name : filename) : boolean;
begin
  assign(fp,name);
  {$i- turn off I/O error checking}
  reset(fp);
  {$i+ error checking back on}
  if ioresult <> 0 then
    begin
      open := false;
      close(fp);
    end
  else
    open := true;
end { open };

{ INITIALIZE - set parameters and open files }
procedure initialize;

{ GET_DATE - get date and time from system and convert to two strings.
             Date is stored as MM/DD/YY.  Time is stored as HH:MM:SS,
             with seconds set to 00.
             This routine will not work for dates prior to 01/01/78
}

procedure get_date(var date_ptr,time_ptr);
type
  month_array   = array[1..2,1..12] of integer;
  string8       = string[8];
var
  date          : string8 absolute date_ptr;
  time          : string8 absolute time_ptr;
  date_time     : packed array [1..4] of char;
  jdate         : integer absolute date_time; { #days since 12/31/77 }
  x,
  month         : byte;
  year          : integer;
const
  day_table     : month_array =
                  ((31,59,90,120,151,181,212,243,273,304,334,365),
                   (31,60,91,121,152,182,213,244,274,305,335,366));

{ LEAP - return TRUE if YEAR is a leap year }
function leap(year : integer) : boolean;
begin
  leap := (year mod 4 = 0) and (year <> 100);
end; {leap}

{ DAYS_IN - return number of days in YEAR }
function days_in(year : integer) : integer;
begin
  if (leap(year)) then days_in := 366
  else days_in := 365;
end; {days_in}

begin
  bdos(105,addr(date_time));            { get system date/time }
  time := '00:00:00';                   { initialize time }
  time[1] := chr((ord(date_time[3]) div 16) + 48); { hours first digit }
  time[2] := chr((ord(date_time[3]) mod 16) + 48); {       second digit }
  time[4] := chr((ord(date_time[4]) div 16) + 48); { minutes first digit }
  time[5] := chr((ord(date_time[4]) mod 16) + 48); {         second digit }

  year := 78;
  while (jdate > days_in(year)) do
    begin
      jdate := jdate-days_in(year);
      year := year + 1;
    end;

  if (leap(year)) then x := 2           { set proper date table }
  else x := 1;

  month := 1;
  while (jdate > day_table[x,month]) do { move us to the proper month }
    month := month + 1;
  if (month > 1) then
    jdate := jdate - day_table[x,month-1]; { and set the date }

  date := '00/00/00';
  date[1] := chr(month div 10 + 48);    { month first digit }
  date[2] := chr(month mod 10 + 48);    {       second digit }
  date[4] := chr(jdate div 10 + 48);    { day first digit }
  date[5] := chr(jdate mod 10 + 48);    { day second digit }
  date[7] := chr(year div 10 + 48);     { year first digit }
  date[8] := chr(year mod 10 + 48);     {      second digit }
end; { get_date }

{ PRINTUSE - print usage information and exit }
procedure printuse;
begin
  writeln;
  writeln('Turbo Pascal program listing and variable Cross-reference generator');
  writeln;
  writeln('Usage is TYPEX <source> [<destination>] [',optchr:1,'<options>]');
  writeln('   Options are: I - INCLUDE files also');
  writeln('                X - Create program Cross-reference');
  write  ('   DEFAULTS:  Output   - ');
  writeln(default_output);
  write  ('              Includes - ');
  if include_default then
    writeln('YES')
  else
    writeln('NO');
  write  ('              Xref     - ');
  if xref_default then
    writeln('YES')
  else
    writeln('NO');
  halt;
end; { printuse }

{ OPENMAIN - Open main input and output files.  Set XREF and INCLUDE options. }
procedure openmain;
var
  tmpstr,
  option_string : string[32];
  param         : byte;
  outfilename   : filename;             { output file name }

function get_param(var param : byte) : string255;
var
  x             : byte;
begin
  if (length(tmpstr) > 0) then
    begin                               { there's an option string here }
      get_param := tmpstr;
      tmpstr := '';
    end
  else
  if (param > paramcount) then
    get_param := ''                     { no more parameters }
  else
    begin
      tmpstr := paramstr(param);        { get next parameter }
      param := param+1;                 { bump parameter count }
      x := pos(optchr,tmpstr);
      if (x > 1) then                   { see if it's an option string }
        begin
          get_param := copy(tmpstr,1,x-1);    { this is the returned parameter }
          tmpstr := copy(tmpstr,x,length(tmpstr)-x+1); { save this for next time }
        end
      else
        begin
          get_param := tmpstr;          { return this }
          tmpstr := '';                 { nothing saved }
        end;
    end;
end; { get_param }

begin { openmain }
  if (paramcount = 0) then
    printuse;
  includes := include_default;          { set default parameters }
  xref := xref_default;
  tmpstr := '';
  option_string := '';
  param := 1;
  mainfilename := get_param(param);     { get input file name }
  if not (open(mainfile,mainfilename)) then
    begin
      writeln('ERROR - cannot open input file ',mainfilename);
      halt;
    end;
  outfilename := get_param(param);      { get output file name and options }
  if (length(outfilename) > 0) then
    if (outfilename[1] = optchr) then
      begin
        option_string := outfilename;   { options }
        outfilename := default_output;  { but no defined file name }
      end
    else
      option_string := get_param(param) { get options (if any) }
  else
    begin
      option_string := '';              { no options }
      outfilename := default_output;    { no defined file name }
    end;
  assign(outfile,outfilename);
  {$I-}
  rewrite(outfile);
  {$I+}
  if (ioresult <> 0) then
    begin
      writeln('ERROR - cannot open output file ',outfilename);
      halt;
    end;
  if (pos(optchr,option_string) = 1) then
    begin                               { set options }
      includes := (include_default xor (pos('I',option_string) > 0));
      xref := (xref_default xor (pos('X',option_string) > 0));
    end;
end {openmain};

begin {initialize}
  openmain;                             { open files and get options }
  get_date(date,time);                  { get date and time for headings }
  fillchar(dots,sizeof(dots),'.');
  dots[0] := chr(70);                   { set length of dot line }
  search[1] := '{$'+'i';
  search[2] := '{$'+'I';
  search[3] := '(*$'+'i';               { setup search strings for includes }
  search[4] := '(*$'+'I';
  page_no := 0;
  headings;
  xref_head := nil;
end; {initialize}
{
  PROCESS_FILE - print each line of the input file and INCLUDED files,
  if requested.  Create cross-reference records for each variable
  if requested.
}
procedure process_file;
var
  linebuffer    : strptr;
  line_no,                              { current line number in input file }
  include_line  : integer;              { line number in include file }

  including,                            { TRUE = processing include file }
  quote         : boolean;              { quote flag }
  comment_type  : byte;                 { type of comment being processed:
                                           0 = no comment
                                           1 = '{'-type comment
                                           2 = '(*'-type comment }

{ INCLUDEIN - return TRUE if there is an INCLUDE statement in the current line }
function includein(curstr : strptr) : boolean;
var
  x,
  column        : byte;
begin
  x := 0;
  column := 0;
  repeat
    x := x+1;
    column := pos(search[x],curstr^);
  until (x = 4) or (column > 0);
  if (column = 0) then
    includein := false
  else
    includein := not (curstr^[column+length(search[x])] in ['-','+']);
end; {includein}

{ PROCESS_LINE - write PRINTSTR to the output file, updating work_line.
                 If cross-referencing, generate XREF records for each
                 item found in PRINTSTR }
procedure process_line(printstr : strptr; var work_line : integer);
var
  x             : byte;

{ XREF_LINE - create reference records for each item found in PRINTSTR }
procedure xref_line;
var
  x             : byte;
  wkstr         : string255;
  ch            : char;

{
  ADD_TREE - add a reference to the tree.  If WKSTR is not in the tree,
  create a new node for it.
}
procedure add_tree(var tree : itmptr);
var
  q,p           : itmptr;
  less,
  found         : boolean;

{ MAKETREE - create a new tree node. }
function maketree : itmptr;
var
  p             : itmptr;
begin {maketree}
  new(p);
  with p^ do
    begin
      getmem(idname,length(wkstr)+1);   { allocate just enough for IDNAME }
      idname^ := wkstr;
      if (length(idname^) < max_id_len) then
        numrefs := 0
      else
        numrefs := refs_per_line;
      left := nil;
      right := nil;
      rthrd := false;
      nxtptr := nil;                    { set reference pointer }
      fstptr := nil;
    end;
  maketree := p;
end; {maketree}

procedure setleft(p : itmptr);
var
  q             : itmptr;
begin {setleft}
  q := maketree;
  p^.left := q;
  q^.right := p;                        { inorder successor of q is p }
  q^.rthrd := true;
end; {setleft}

procedure setright(p : itmptr);
var
  q             : itmptr;
begin {setright}
  q := maketree;
  q^.right := p^.right;                 { inorder successor of q is successor of p }
  q^.rthrd := p^.rthrd;                 { may or may not be thread pointer }
  p^.right := q;
  p^.rthrd := false;
end; {setright}

procedure add_ref(p : itmptr; line_no,include_line : integer);
var
  r             : refptr;
begin {add_ref}
  new(r);                               { create a new reference record }
  with r^ do
    begin
      line := line_no;
      incl := include_line;
      nxtptr := nil;
    end;
  with p^ do
    begin
      if (fstptr = nil) then            { if first reference for this record }
        fstptr := r                     { setup list head pointer }
      else
        nxtptr^.nxtptr := r;            { link previous last ref to new }
      nxtptr := r;                      { point to last }
      if (include_line > 0) then        { update reference counter }
        numrefs := numrefs+2            { INCLUDEs take 2 spaces }
      else
        numrefs := numrefs+1;
    end;
end; {add_ref}

begin {add_tree}
  if tree = nil then
    begin                               { nothing in the tree }
      tree := maketree;                 { so we'll make it }
      p := tree;
    end
  else
    begin
      q := tree;
      p := tree;
      found := false;
      while (q <> nil) and not found do     { search the tree }
        begin
          p := q;
          if (p^.idname^ = wkstr) then
            found := true                   { found it }
          else
            begin
              less := (wkstr < p^.idname^);
              if (less) then
                q := p^.left
              else
              if (p^.rthrd) then
                q := nil
              else
                q := p^.right;
            end;
        end;
      if (not found) then               { not found, create a new node }
        if (less) then
          begin
            setleft(p);
            p := p^.left;
          end
        else
          begin
            setright(p);
            p := p^.right;
          end;
    end;
  add_ref(p,line_no,include_line);      { create a new reference record }
end; {add_tree}

{ GETCHR - get the next character in the line.  Return 0 at end of line }
procedure getchr;
begin
  if (x = 0) or (x > length(printstr^)) then
    x := 0                              { end of line }
  else
    begin
      ch := upcase(printstr^[x]);       { convert to uppercase for xref }
      x := x+1;
    end;
end;

{ KEYWORD - return TRUE if WKSTR is in the key word table.
            This is a simple binary search }
function keyword : boolean;
const
  nkwords       = 44;                   { number of key words in table }
type
  key_word_table= array[1..nkwords] of string[9];
const
  key_words     : key_word_table =
                  ('ABSOLUTE' ,'AND'      ,'ARRAY'    ,'BEGIN',
                   'CASE'     ,'CONST'    ,'DIV'      ,'DO',
                   'DOWNTO'   ,'ELSE'     ,'END'      ,'EXTERNAL',
                   'FILE'     ,'FOR'      ,'FORWARD'  ,'FUNCTION',
                   'GOTO'     ,'IF'       ,'IN'       ,'INLINE',
                   'LABEL'    ,'MOD'      ,'NIL'      ,'NOT',
                   'OF'       ,'OR'       ,'OVERLAY'  ,'PACKED',
                   'PROCEDURE','PROGRAM'  ,'RECORD'   ,'REPEAT',
                   'SET'      ,'SHL'      ,'SHR'      ,'STRING',
                   'THEN'     ,'TO'       ,'TYPE'     ,'UNTIL',
                   'VAR'      ,'WHILE'    ,'WITH'     ,'XOR');
var
  high,
  low,
  mid           : byte;
begin
  high := nkwords;
  low := 1;
  while (low <= high) do
    begin
      mid := (high+low) div 2;
      if (key_words[mid] = wkstr) then
        begin
          keyword := true;
          exit;
        end
      else
      if (key_words[mid] > wkstr) then
        high := mid-1
      else
        low := mid+1;
    end;
  keyword := false;
end;

begin {xref_line}
  x := 1;                               { start at beginning }
  wkstr := '';
  getchr;
  while (x > 0) do                      { while not end of line }
    begin
      if (ch = '''') and (comment_type = 0) then { set quote flag }
        quote := not(quote)
      else
      if not quote then                 { if not in quote then go }
        case comment_type of
          0 : if ch = '{' then
                comment_type := 1       { start a comment }
              else
              if ch = '(' then
                begin
                  getchr;
                  if (x > 0) then
                    if (ch = '*') then
                      comment_type := 2 { start a comment }
                    else
                      x := x-1;
                end
              else
              if ch in ['A'..'Z'] then  { start a word }
                begin
                  repeat
                    wkstr := wkstr+ch;
                    getchr;
                  until (not (ch in ['0'..'9','A'..'Z','_'])) or (x = 0);
                  if not keyword then   { check for keyword }
                    add_tree(xref_head);{ not keyword, add to xref tree }
                  wkstr := '';
                  if x > 0 then         { if not end of line }
                    x := x-1;           { go back to previous character }
                end;
          1 : if ch = '}' then          { end comment }
                comment_type := 0;
          2 : if ch = '*' then
                begin
                  getchr;
                  if (x > 0) then
                    if (ch = ')') then
                      comment_type := 0 { end comment }
                    else
                      x := x-1;
                end;
        end; { case }
      getchr;
    end; { while }
end; {xref_line}

{ FINDSPACE - find end of last full word that will fit on the line }
function findspace(printstr : strptr; var x : byte) : byte;
var
  y             : byte;
begin
  y := x;
  x := x+printwidth;
  if (x > length(printstr^)) then       { the whole line will fit }
    x := length(printstr^)+1
  else
    begin
      while (printstr^[x] <> ' ') and (x > y) do { look back for first space }
        x := x-1;
      if (x > y) then                   { found it }
        x := x+1
      else
        x := y+printwidth+1;            { no space, break in middle of word }
    end;
  findspace := x-1;
end; {findspace}

{ DETAB - replace all tabs in the line with appropriate number of spaces }
procedure detab(var printstr : string255);
type
  string8       = string[8];
const
  tab           = ^I;
  tab_string    : string8 = '        ';
var
  x             : byte;
begin
  x := pos(tab,printstr);
  while (x > 0) do
    begin
      delete(printstr,x,1);            { remove the tab }
      insert(copy(tab_string,1,8-((x-1) mod 8)),printstr,x); { insert spaces }
      x := pos(tab,printstr);
    end;
end; {detab}

begin {process_line}
  detab(printstr^);
  currow := currow + ((length(printstr^)-1) div printwidth) + 1;
  if currow > printlength then
    begin
      headings;
      currow := currow + ((length(printstr^)-1) div printwidth) + 1;
    end;
  work_line := work_line + 1;
  if including then
    write(outfile,'<',work_line:5,'> : ')
  else
    write(outfile,' ',work_line:5,'  : ');
  x := 1;
  writeln(outfile,copy(printstr^,1,findspace(printstr,x)));
  while x <= length(printstr^) do
    writeln(outfile,' ':10,copy(printstr^,x,findspace(printstr,x)));
  if xref then
    xref_line;
end; {process_line}

procedure process_include_file(incstr : strptr);
var
  namestart,
  nameend       : integer;
  includefile   : text;
  includefilename : filename;

function parse(incstr : strptr) : filename;
begin
  namestart := pos('$I',incstr^)+2;
  if namestart = 2 then
    namestart := pos('$i',incstr^)+2;
  while (incstr^[namestart] = ' ') do
    namestart := namestart + 1;
  nameend := namestart;
  while (not (incstr^[nameend] in [' ','}','*']))
         and ((nameend - namestart) <= pathlength) do
    nameend := nameend + 1;
  nameend := nameend - 1;
  parse := copy(incstr^,namestart,(nameend-namestart+1));
end; {parse}

begin  {process_include_file}
  includefilename := parse(incstr);
  if (pos('.',includefilename) = 0) then
    includefilename := includefilename + '.PAS';
  including := true;
  include_line := 0;
  if not open(includefile,includefilename) then
    begin
      linebuffer^ := 'ERROR -- Include file not found:  ' + includefilename;
      process_line(linebuffer,include_line);
    end
  else
    begin
      while not eof(includefile) do
        begin
          readln(includefile,linebuffer^);
          process_line(linebuffer,include_line);
        end;
      close(includefile);
    end;
  including := false;
  include_line := 0;
end; {process_include_file}

begin  {process_file}
  new(linebuffer);
  quote := false;
  comment_type := 0;
  line_no := 0;
  include_line := 0;
  including := false;                   { not including a file now }
  while not eof(mainfile) do
    begin
      readln(mainfile,linebuffer^);
      process_line(linebuffer,line_no);
      if includes and includein(linebuffer) then
        process_include_file(linebuffer);
    end;
  dispose(linebuffer);
end; {process_file}

{ PRINT_XREF - print the cross-reference listing }
procedure print_xref(xref_head : itmptr);
var
  ref_count     : integer;
  p,q           : itmptr;

{ LPWRITELN - write a newline on output file.  Check for page break. }
procedure lpwriteln;
begin
  if (currow > printlength) then
    headings;                           { new page }
  writeln(outfile);
  currow := currow + 1;
end;

{ NEWLINE - need another line for references.  Start at position (MAX_ID_LEN+1) }
procedure newline;
begin
  lpwriteln;
  write(outfile,' ':(max_id_len + 1));
  ref_count := 1;
end;

{ PRINT_REFS - Print the list of references for the current node. }
procedure print_refs(node : itmptr);
var
  list          : refptr;

{ WRITE_REF - output one reference to the print file }
procedure write_ref(ref : refptr);
var
  inclstr       : string8;
  inclen        : byte absolute inclstr; {easier than length(inclstr)}
begin
  with ref^ do
    begin
      if (ref_count > refs_per_line) then
        newline;
      write(outfile,line:1);
      if (incl = 0) then
        begin                           { no include in this reference }
          str(line:1,inclstr);
          if (inclen < 6) then
            write(outfile,' ':(6-inclen));
          ref_count := ref_count + 1;
        end
      else
        begin                           { process INCLUDEd reference }
          write(outfile,'<',incl:1,'>');
          str(line:1,inclstr);
          if (inclen < 6) then
            write(outfile,' ':(6-inclen));
          str(incl:1,inclstr);
          if (inclen < 4) then
            write(outfile,' ':(4-inclen));
          ref_count := ref_count + 2;
        end;
    end; {with}
end; {write_ref}

begin {print_refs}
  if ((node^.numrefs div refs_per_line) > (printlength - currow)) then
    headings;
  write(outfile,node^.idname^);         { output idname }
  if (length(node^.idname^) >= max_id_len) then
    newline
  else
    write(outfile,' ':(max_id_len-length(node^.idname^)+1));

  ref_count := 1;
  list := node^.fstptr;
  repeat
    write_ref(list);
    list := list^.nxtptr;
  until (list = nil);
  lpwriteln;
end; {print_refs}

{ in-order traversal of a right in-threaded binary tree. }
begin {print_xref}
  headings;
  p := xref_head;
  repeat
    q := nil;
    while (p <> nil) do
      begin                             { traverse left branch }
        q := p;
        p := p^.left;
      end;
    if (q <> nil) then
      begin
        print_refs(q);
        p := q^.right;
        while (q^.rthrd) do
          begin                         { back up }
            print_refs(p);
            q := p;
            p := p^.right;
          end;
      end;
  until (q = nil);
end; {print_xref}

begin { typex }
  writeln('[TYPEX Version ',version_no,']');
  initialize;
  process_file;
  if xref then
    print_xref(xref_head);
  page(outfile);
  close(mainfile);
  close(outfile);
end. { typex }
