program Parser;

{adapted to Turbo Pascal by Glenn Brooke 5/6/86 from a program
 by Herbert Shcildt.

 this program reads an expression and returns the result.  It can
 handle up to 26 one letter (A-Z) variables and real numbers.
 Supports +,-,*,/,and powers.  Not bad!  Speed isn't too bad, either.

 This kind of a program is really best as a function in your own program,
 so that the user can enter an expression, and the program can compute
 the result.  For example, a function plotting program can simply ask
 for a function like 2*X + (3.14/X^4)/1.23, and plot the curve from
 -5 to +5.  Quite powerful!

}
type
    str80 = string[80];
    Ttype = (Delimiter, Variable, Number);
var
   token, prog : str80;
   TokType : Ttype;
   code, t : integer;
   result : real;
   vars : array[0..25] of real;      {26 variables}

function IsAlpha(ch : char) : boolean;
{true if ch is letter in alphabe}
begin
     IsAlpha := (Upcase(ch) in ['A'..'Z'])
end;

function IsWhite(ch : char) : boolean;
{true if newline, space or tab}
begin
     IsWhite := (ch= ' ') or (ch=chr(9)) or (ch=chr(13));
end;

function IsDelim(ch : char) : boolean;
begin
     if pos(ch,' +-/*%^=()$')<>0 then IsDelim := true
     else IsDelim := false
end;

function Isdigit(ch : char) : boolean;
begin
     Isdigit := ch in ['0'..'9']
end;

procedure GetToken;
var temp : str80;
begin
     token := '';
     while (IsWhite(prog[t])) do t := succ(t);
     if prog[t]='$' then token := '$';
     if pos(prog[t],'+-*/%^=()')<>0 then
        begin
        TokType := Delimiter;
        token := prog[t];    {is an operator}
        t := succ(t);
        end
     else if IsAlpha(prog[t]) then
          begin
          while (not IsDelim(prog[t])) do
                begin
                token := token + prog[t];    {build token}
                t := succ(t)
                end;
          TokType := Variable;
          end
     else if IsDigit(prog[t]) then
          begin
          while (not IsDelim(prog[t])) do
                begin
                token := token + prog[t];   {build number}
                t := succ(t);
                Toktype := number;
                end;
          end;
end; {GetToken}

procedure PutBack;  {put back unused token}
begin
     t := t - length(token)
end;

procedure Serror(i : integer);  {print error msg}
begin
     case i of
          1 : writeln('Syntax error');
          2 : writeln('Unbalanced parentheses');
          3 : writeln('No expression Present')
     end;
end;

function Pwr(a,b : real) : real;
{raise a to the b power}
var t : integer;
    temp : real;
begin
     if a= 0 then pwr := 1
     else
         begin
         temp := a;
         for t := trunc(b) downto 2 do a := a * temp;
         Pwr := a
         end
end;

function FindVar(s : str80) : real;
var t : integer;
begin
     FindVar := vars[ord(upcase(s[1]))-ord('A')]
end;

procedure Arith(op : char; var result, operand : real);
begin
     case op of
          '+' : result := result + operand;
          '-' : result := result - operand;
          '*' : result := result * operand;
          '/' : result := result / operand;
          '^' : result := Pwr(result,operand);
    end
end;

{***********  Expression Parser w/ variables and assignment  ********}
procedure Level2(var result : real); forward;
procedure Level1(var result : real); forward;
procedure Level3(var result : real); forward;
procedure Level4(var result : real); forward;
procedure Level5(var result : real); forward;
procedure Level6(var result : real); forward;
procedure Primitive(var result : real); forward;


procedure GetExp(var result: real);
begin
     GetToken;
     if length(token) <> 0 then Level1(result) else Serror(3)
end;

procedure Level1;
var hold : real;
    temp : Ttype;
    slot : integer;
    TempToken : str80;
begin
     if Toktype = Variable then
        begin
        {save old token}
        temptoken := token;
        temp := toktype;
        slot := ord(upcase(token[1]))-ord('A');
        GetToken;  {see if there is an = for assignment}
        if token[1] <> '=' then  {restore}
           begin
           Putback;
           token := temptoken;
           toktype := temp;
           level2(result)
           end
        else {is assignment}
             begin
             Gettoken;
             Level2(result);
             vars[slot] := result;
             end;
        end
    else Level2(result)
end; {Level1}


procedure Level2;
var op : char;
    hold : real;
begin
     Level3(result);
     op := token[1];
     while ((op='+') or (op='-')) do
           begin
           Gettoken;
           Level3(hold);
           arith(op, result, hold);
           op := token[1]
           end;
end; {Level2}

procedure Level3;
var op : char;
    hold : real;

begin
     Level4(result);
     op := token[1];
     while ((op='*') or (op='/')) do
           begin
           Gettoken;
           level4(hold);
           arith(op, result, hold);
           op := token[1]
           end;
end; {Level3}

procedure Level4;
var hold : real;
begin
     Level5(result);
     if token[1] = '^' then
        begin
        GetToken;
        Level4(hold);
        arith('^',result, hold);    {exponent}
        end
end;

procedure Level5;
var op : char;
begin
     op := ' ';
     if ((tokType=Delimiter) and ((token[1]='+') or (token[1]= '-'))) then
        begin  {unary plus or minus}
               op := token[1];
               Gettoken
        end;
     Level6(result);
     if op='-' then result := -result
end; {level5}

procedure Level6;
begin
     if (token[1]='(') and (Toktype=Delimiter) then
        begin {parenthesized expression}
        GetToken;
        Level2(result);
        if token[1]<>')' then Serror(2);  {unbalanced}
        GetToken;
        end
     else Primitive(result);
end; {Level6}


procedure Primitive;
begin
     if TokType=Number then val(token, result, code)
     else if TokType=Variable then result := FindVar(token)
     else serror(1);
     GetToken
end; {Primitive}




{**************************  Main Test body  ******************}
begin
     for t := 0 to 25 do vars[t] := 0;  {initialize variables}
     repeat
           t := 1;
           write('  Enter an expression  (quit to stop) : ');
           readln(prog);
           prog := prog + '$';
           GetExp(result);
           writeln(result);
     until prog = 'quit$';
end.
