program signs;
{kilobaud, Aug '78, page 90
program originally in North Star BASIC by Joseph J. Roehrig
numbers in brackets indicate line numbers in original program
}
LABEL
  1;
CONST
  wdth = 11;		{# letters per line
	Each letter requires 12 spaces; an 80 column screen can
        accomodate 6 letters (6x12=72).  A 132 column printer
        can handle 11 letters
	The program is now constructed so that changing wdth is the
	ONLY thing that is necessary to changing the letter count.}
  alphabet = 27;	{number of letters supported in alphabet}
	{To expand the alphabet several things need to be done:
		1.  Change "alphabet" appropriately.
		2.  Alter procedure ucase so it filters correctly.
		3.  Include new characters in font.dat.
		4.  Main program line "if 0>c then c := 27;" prohibits 
		    mapping characters into negative values in array L.
		    It also effectively prohibits any characters whose
		    ASCII values are less than 64.  You are going to 
		    have to redo the logic there to include numbers...}
VAR
  fout : text;
  V : array[0..31] of integer;		{patterns}
  L$ : array[1..alphabet] of char;	{top of array equ number of chars}
  L  : array[1..alphabet,1..7] of integer;	{dimensions of each letter}
  Z  : array[1..5] of integer;	{decoder}
  D1$ : array[1..wdth]of char;	{wdth equ total # of letters on a line}
  C$ : char;
  a,
  b,
  c,
  d,
  f,
  g,
  q,
  e : integer;

function ucase(ch:char):char;
{This function filters all non-alphabetical characters, replacing
them with blanks.  It also converts all lower case letters to
upper case.}
begin
  if (ch in ['A'..'Z']) {or (ch in ['0'..'9'])} then ucase := ch	
	{accept upper case [and numbers as is]}
  else
    if ch in ['a'..'z'] then	{translate to upper case}
      ucase := chr(ord(ch) - 32)
      else ucase := ' '		{filter illegal characters}
end;	{ucase}

procedure setfont;
{This procedure fills the array L with the font values from
"font.dat".  It takes the place of a series of DATA statements
in the original BASIC program.
Additionally, L$ is filled from the 8th character in each font value.
This allows L$ to grow automatically with alphabet.}
TYPE
  $str8 = string 8;	{for reading font.dat}
var
  letter : $str8;
  a,b    : integer;
  fin    : file of $str8;
  {L     : array [1..alphabet,1..7] of integer - global
   L$	 : array [1..alphabet] of char - global}
begin
  reset('font.dat',fin);	{font.dat contains array values}
  if eof(fin) then writeln('"Font.dat" must be on logged disk.');
  for a := 1 to alphabet do		{70, set loop value to tot # chars formed}
    begin
    readln(fin,letter);	{'letter' contains 8 char; 1st 7 are significant}
    for b := 1 to 7 do	{8th is the L$ label}
      begin
      L[a,b] := ord(letter[b])-64;	{80}
      L$[a] := letter[8];		{15}
      end;	{for b}
    end;	{for a}
end;	{procedure setfont}

procedure initialize;
{fill arrays D1$, Z and V}
begin
  for a := 1 to wdth do D1$[a] := ' ';		{wdth blanks}
  z[1] := 10000; z[2] := 1000; z[3] := 100; z[4] := 10; z[5] := 1;
  v[0]:=0; v[1]:=1; 		{50	read binary number line}
  v[2]:=10; v[3]:=11; v[4]:=100; v[5]:=101; v[6]:=110; v[7]:=111;
  v[8]:=1000; v[9]:=1001; v[10]:= 1010; v[11]:=1011; v[12]:= 1100;
  v[13]:=1101; v[14]:=1110; v[15]:=1111;
  for a := 16 to 31 do v[a] := 10000+v[a-16];	{60}
  {there has to be a better way to fill this array, when you
  find it, let me know}
end;	{procedure initialize}

procedure setdev;
{output direction}
var
  choice : integer;
  filnam : string 14;
begin
  writeln;
  writeln('Do you wish output to:');
  writeln('            1) printer (lst:)');
  writeln('            2) screen  (con:)');
  writeln('            3) a file');
  repeat
  read(choice);
  until choice in [1,2,3];
  case choice of
  1: rewrite('lst:',fout);
  2: rewrite('con:',fout);
  3: begin
     write('Name of file: ');
     readln(filnam);
     rewrite(filnam,fout)
     end;
  end;	{case}
end;	{procedure setdev}

begin	{main program}
  setfont;		{70,80}
  initialize;
  writeln('Pick your device: screen, printer or file.');
  writeln;
  writeln('  This program will accept upper case');
  writeln('characters and blanks. (Lower case letters will translate)');
  writeln;
  writeln('Enter a period and a carriage return to end.');
  setdev;
  writeln;
    while D1$[1] <> '.' do
    begin	{while}
    Writeln('Input line:');
    for a := 1 to wdth do write('_');
    writeln;
    readln(D1$);
      if D1$[1] = '.' then goto 1;	{sorry, had to GOTO}
    for e := 1 to wdth do
    D1$[e] := ucase(D1$[e]);
{98 "get paper ready & enter <cr>}
    for d := 1 to 7 do		{105}
    begin
      for b := 1 to wdth do	{110}
      begin
      c := b;			{120}
      c := ord(D1$[c])-64;
      if 0 > c then c := 27;
      f := L[c,d];		{135}
      f := v[f];		{136}
      q := c;			{137}
      for e := 1 to 5 do	{150}
        begin
        g := trunc(f div z[e]);	{160}
        f := f-(g*z[e]);	{165}
        if g = 1 then write(fout,L$[q],L$[q])	{170}
                 else write(fout,'  ');
        end;	{for e}
      write(fout,'  ');		{200, number of spaces between letters}
      end;	{for b}
    writeln(fout);		{220, ends each line of print}
    end;	{for d}
  writeln(fout); writeln(fout);	{230, 2 blank lines between each printed string}
  1:
  end;	{while}
end.
