program mastermind;
label 870;

type
  colors=(colorless,red,blue,brown,green,yellow,orange,space);
  row=array [1..4] of colors;
  eval = record
         black,white:0..4
         end;

var
  evaluations:array [1..10] of eval;
  rows:array [1..10] of row;
  name:array[colors] of packed array [1..6] of char;
  color:array [0..7] of colors;
  redrow:row;
  last:row;
  version:1..2;
  maxcolor:orange..space;
  i,j:integer;
  ch:char;
  done:boolean;

procedure printscreen;
begin
  done:=true;
  writeln;
  writeln ('Mastermind is a logic game -');
  writeln;
  writeln ('  In this version you are the code maker and the computer');
  writeln ('  the code breaker. At the beginning you form a code consisting');
  writeln ('  of 4 colors (e.g. RED,GREEN,RED,YELLOW ).');
  writeln;
  writeln ('  The computer then attempts to deduce the code by guessing.');
  writeln ('  You then give the computer clues to indicate how close the');
  writeln ('  guess was to the code.');
  writeln;
  writeln ('Press <ENTER> to continue');
  readln (ch);
  clrscr;
  writeln;
  writeln ('  For every right color AND in the right position, the computer');
  writeln ('  gets a Black peg.');
  writeln;
  writeln ('  For every color that is right BUT NOT in the right position,');
  writeln ('  the computer gets a White peg.');
  writeln;
  writeln ('  For example if the code was :');
  writeln;
  writeln ('    YELLOW  RED  RED  GREEN');
  writeln;
  writeln ('  and the computer''s guess was :');
  writeln;
  writeln ('    RED  RED  YELLOW  BLACK');
  writeln;
  writeln ('  You would give the computer 1 Black peg (for the RED',
             ' in position 2');
  writeln ('  and 2 White pegs (for RED and YELLOW) the correct colors');
  writeln ('  but in the wrong position.');
  writeln ;
  writeln ('  The computer is given 10 chances to deduce the code.');
  writeln;
  writeln ('Press <ENTER> to continue');
  read (kbd,ch);
  clrscr;
end;


procedure initialization;
var
  c:colors;
  i:1..4;

begin
  name[red] :='  RED ';   name[green] :=' GREEN';  name[yellow]:='YELLOW';
  name[blue]:='  BLUE';   name[orange]:='ORANGE';  name[brown] :=' BROWN';
  name[space]:=' SPACE';
  for c:=colorless to space do color[ord(c)]:=c;
  for i:=1 to 4 do redrow[i]:=red;
  last:=redrow;
  clrscr;
  writeln ('MASTERMIND CODEBREAKER');
  writeln;
  writeln ('Please be patient, sometimes I take a few minutes on my move.');
  if not done then printscreen;
  writeln;
  writeln ('Two versions are available:');
  writeln (' ':10,'Version (1) is easier with colors: red,green,yellow,blue,');
  writeln (' ':45,'orange and brown');
  writeln;
  writeln (' ':10,'Version (2) is harder with the same colors + Space');
  writeln;
  repeat
    write ('Which version would you like (1 or 2) ? ');
    readln (version);
  until (version in [1..2]);
  maxcolor:=color[version+5];
  for i:=1 to 4 do rows[1,i]:=color[trunc((version+5)*random+1)];
end;

procedure checkconsistency (hypothesis,previousrow:row;var e:eval);
label 1090;
var
  j1,j2:integer;

begin
  e.black:=0;
  for j1:=1 to 4 do if hypothesis[j1]=previousrow[j1] then e.black:=e.black+1;
  e.white:=0;
  for j1:=1 to 4 do
  begin
    for j2:=1 to 4 do
    if (j1<>j2) and (hypothesis[j1]<>previousrow[j1]) and
                    (hypothesis[j2]<>previousrow[j2]) and
                    (hypothesis[j1]= previousrow[j2]) then
    begin
      e.white:=e.white+1;
      previousrow[j2]:=colorless;
      goto 1090;
    end;
    1090:end
end;

function formhypothesis:boolean;
label 820;
var
  i1,i2,i3,i4:colors;
  r:integer;
  hyp:row;
  eval1:eval;
  viable,ok,ok2:boolean;

begin
  viable:=true;
  for i1:=last[1] to maxcolor do
  for i2:=last[2] to maxcolor do
  for i3:=last[3] to maxcolor do
  for i4:=last[4] to maxcolor do
  begin
    last:=redrow;
    hyp[1]:=i1; hyp[2]:=i2; hyp[3]:=i3; hyp[4]:=i4;
    r:=0;
    repeat
      r:=r+1;
      checkconsistency(hyp,rows[r],eval1);

      ok:= (eval1.black=evaluations[r].black)
           and (eval1.white=evaluations[r].white);

    until  (not ok) or (r=i);
    ok2:= (hyp[1]=rows[1,1]) and (hyp[2]=rows[1,2])
          and (hyp[3]=rows[1,3]) and (hyp[4]=rows[1,4]);
    if ok then if (not ok2) then goto 820;
  end;
  viable:=false;
  820: if viable then
  begin
    last:=hyp;
    rows[i+1]:=hyp;
  end
  else
  begin
    writeln;
    writeln ('I have reached an impasse....');
    writeln ('Could you have made an error ?');
  end;
  formhypothesis:=viable
end;


begin
  done:=false;
  repeat
    initialization;
    for i:=1 to 9 do
    begin
      writeln;
      writeln ('My move for row',i:2,' is ');
      for j:=1 to 4 do
      write (name[rows[i,j]]:8);
      writeln;
      write ('How many black pegs ? ');
      readln (evaluations[i].black);
      if evaluations[i].black = 4 then
      begin
        writeln;
        writeln ('Thanks for the game');
        goto 870
      end;
      if evaluations[i].black=3 then evaluations[i].white:=0
      else
      begin
        write ('How many white pegs ? ');
        readln (evaluations[i].white)
      end;
      if not formhypothesis then goto 870
    end;
    writeln ('I am STUMPED --- you win !!');
    870:
    repeat
      write ('Another game ?');
      readln (ch)
    until upcase (ch) in ['Y','N'];
  until upcase(ch)='N';
end.
e