{ evaluate ver 5.0 -- arithmetic expression evaluator by Ken Waldron Nov85 }

{ This file is being distributed as a demonstration of
    1) Recursive descent parsing
    2) Improved stream i/o in Turbo
  The standard types, constants, variables, stream i/o package, & error handler
  are normally placed in an include file; they are merged into the program
  here to simplify distribution. }

{ Usage: evaluate                  -- reads from & writes to con:
     or  evaluate srcname          -- reads from srcfile, writes to con:
     or  evaluate srcname dstname

  Evaluates arithmetic expressions.  If the expression is preceded by a
  question mark then the result is printed on the destination file.  If
  the expression is preceded by a variable name and an equal sign, then
  the result is placed in the variable named.  To see it, you must enter
  the variable name preceded by a question mark. There are 26 variables
  available, named after the letters of the alphabet.  They are all real,
  and are initiallized to zero.  These rules are similar to some versions
  of BASIC.  Example (the output is the stuff in scientific notation):

    ? 2 + 4;
      6.00000000E+00
    a = 17
    b = 2
    ? a + b;
      1.90000000E+01

  Statements may be optionally terminated with a semicolon.  Evaluate reads
  input until it is sure the next character cannot be part of the current
  statment, then evaluates the result.  This can be confusing when entering
  statments from the console, because the result will not be output until
  after the next statement has been entered.  A semicolon will force an
  immediate evaluation.

  If entering input from the console, type CTRL-Z to exit.

  If an error is encountered, Evaluate reports the error at the console and
  halts. Some errors are left to the Turbo run-time & i/o error handlers.
}

{$w0 reduces code size }

const
  version : string[40] = 'EVALUATE 5.0 Nov6/85 K.Waldron';

{ standard types, constants, variables, stream i/o package, & error handler }

{ NOTE: uses procedure dispose. Do not include in program using mark/release! }

type
  cset = set of char;
  sstring = string[80];
  lstring = string[128];
  mstring = string[255];

const
  AMPER = '&';
  ATSIGN = '@';
  BACKSLASH = '\';
  BACKSPACE = ^H;
  BAR = '|';
  BLANK = ' ';
  CARET = '^';
  COLON = ':';
  COMMA = ',';
  CR = ^M;
  ENDLINE = CR;
  DOLLAR = '$';
  DQUOTE = '"';
  ENDFILE = ^Z;
  EQUAL = '=';
  ESCAPE = ^[;
  ESC = ESCAPE;
  EXCLAM = '!';
  GRAVE = '`';
  GREATER = '>';
  LBRACE = '{';
  LBRACK = '[';
  LESS = '<';
  LINEFEED = ^J;
  LF = LINEFEED;
  LPAREN = '(';
  MINUS = '-';
  DASH = MINUS;
  PERCENT = '%';
  PERIOD = '.';
  DOT = PERIOD;
  PLUS = '+';
  QUESTION = '?';
  RBRACE = '}';
  RBRACK = ']';
  RPAREN = ')';
  SEMICOL = ';';
  SHARP = '#';
  SLASH = '/';
  SQUOTE = '''';
  ACUTE = SQUOTE;
  STAR = '*';
  TAB = ^I;
  TILDE = '~';
  UNDERLINE = '_';
  PUNCTUATION : cset = [COMMA, SEMICOL, COLON, DOT];
  WHITESPACE : cset = [BLANK, TAB, ENDLINE, LF];

var
  errno : integer;

procedure error (msg : mstring); forward;

{ The following stream i/o package is designed to:

  - Enhance Turbo stream (text) file input.  getc is more flexible than Turbo's
    read(c), since it (1) returns the character both in the variable and in the
    function and (2) happily reads through the end of a line or file, returning
    an ENDLINE or ENDFILE character.  ungetc allows the caller to put back a
    character if it has read too far.  nextc skips white space and returns the
    next significant character.  Line and character counts are kept by these
    functions which can be used to improve debugging and error messages.

  - The routines use their own line buffer for each file to overcome a defect
    in CP/M Turbo i/o whereby pending characters in the console or terminal
    buffer may be overwritten by writing to these files.

  - The fopen and fclose routines simplify file management.  They eliminate the
    need for the caller to remember which files are open and should be closed
    when program is ended.  To minimize memory overhead a file variable is
    created only when needed, and disposed of when the file is closed.

  - Unlike similar routines in Kernighan & Plauger's "Software Tools in Pascal
    these routines do not include "put" procedures; I regard this as an
    advantage, as output is faster and quite flexible using the standard Turbo
    write procedure.  Note that you cannot simply write to the stream returned
    by fopen; the stream is a pointer to a record containing a text file f, so
    use: write(stream^.f, var1, var2, ... varN).  Note that, unlike Kernighan
    & Plauger, characters are still characters in this package, not integers.

  To use:

  - Call initio before using any of these routines!
  - getc, ungetc, & nextc are used with the standard input (ie: the file input)
  - getcf, ungetcf, & nextcf are used if your program is setting up it's own
    input file(s).  Use fopen to open the file(s), and give the stream returned
    in the first argument to getcf, etc.  Use fclose to close the files, or
    quit to close all and halt.
  - Refer to the file evaluat5.pas for an example use of this package. }

const
  maxopen = 8;
type
  iomode = (IOREAD, IOWRITE);
  iostream = ^ioblock;
  ioblock = record
    f : text;
    case m : iomode of
      IOREAD  : (buffer : mstring;
                 buflin : integer;
                 bufcol : byte);
      IOWRITE : ()
  end;
var
  openlist : array[1..maxopen] of iostream;
  stderr : iostream; { because Turbo provides no preassigned error file }
  stdinbuffer : mstring; { buffer used by standard input }
  stdinbuflin : integer;
  stdinbufcol : byte;

function fopen (name : lstring; mode : iomode) : iostream;
{ returns the iostream opened if ok, nil otherwise }
var
  i : integer;
  p : iostream;
begin
  {$i-}
  fopen := nil;
  i := 1;
  while openlist[i] <> nil do
    if i = maxopen then
      exit
    else
      i := succ(i);
  new(p);
  assign(p^.f, name);
  errno := ioresult;
  if errno <> 0 then
    exit;
  p^.m := mode;
  case mode of
    IOREAD : begin
               p^.buffer := '';
               p^.buflin := 0;
               p^.bufcol := 0;
               reset(p^.f)
             end;
    IOWRITE : rewrite(p^.f)
  end;
  errno := ioresult;
  if errno <> 0 then
    exit;
  openlist[i] := p;
  fopen := p
  {$i+}
end;

function fclose (stream : iostream) : iostream;
{ returns nil if iostream closed, stream otherwise }
var
  i : integer;
begin
  {$i-}
  fclose := stream;
  i := 1;
  while openlist[i] <> stream do
    if i = maxopen then
      exit
    else
      i := succ(i);
  close(openlist[i]^.f);
  if ioresult <> 0 then
    exit;
  dispose(openlist[i]);
  openlist[i] := nil;
  fclose := nil
  {$i+}
end;

procedure initio;
{ if using with MS-DOS, stderr should be opened with 'err:' }
begin
  stdinbuffer := '';
  stdinbuflin := 0;
  stdinbufcol := 0;
  fillchar(openlist, sizeof(openlist), 0);
  stderr := fopen('con:', IOWRITE)
end;

function getcf (stream : iostream; var c : char) : char;
{ getcf & getc work equally well with src assigned to con:, trm: or a file,
  unlike read(trm) which buffer gets trashed by some writes to console }
begin
  if stream^.bufcol < ord(stream^.buffer[0]) then
    stream^.bufcol := succ(stream^.bufcol)
  else begin
    if eof(stream^.f) then
      stream^.buffer := ENDFILE
    else begin
      readln(stream^.f, stream^.buffer);
      if ord(stream^.buffer[0]) > 254 then
         error('Line too long')
      else
        stream^.buffer := stream^.buffer + ENDLINE;
      stream^.buflin := succ(stream^.buflin)
    end;
    stream^.bufcol := 1
  end;
  c := stream^.buffer[stream^.bufcol];
  getcf := c
end;

function nextcf (stream : iostream; var c : char) : char;
begin
  repeat
    nextcf := getcf(stream, c)
  until not (c in [BLANK, TAB, ENDLINE, LF])
end;

procedure ungetcf (stream : iostream);
{ ungetcf & ungetc are not guarranteed to unget more than one char }
begin
  if ord(stream^.buffer[0]) > 0 then
    stream^.bufcol := pred(stream^.bufcol)
end;

(* standard input is not used in this program

function getc (c : char) : char;
{ get char from standard input }
begin
  if stdinbufcol < ord(stdinbuffer[0]) then
    stdinbufcol := succ(stdinbufcol)
  else begin
    if eof then
      stdinbuffer := ENDFILE
    else begin
      readln(stdinbuffer);
      if ord(stdinbuffer[0]) > 254 then
         error('Line too long')
      else
        stdinbuffer := stdinbuffer + ENDLINE;
      stdinbuflin := succ(stdinbuflin)
    end;
    stdinbufcol := 1
  end;
  c := stdinbuffer[stdinbufcol];
  getc := c
end;

function nextc (var c : char) : char;
begin
  repeat
    nextc := getc(c)
  until not (c in [BLANK, TAB, ENDLINE, LF])
end;

procedure ungetc;
begin
  if ord(stdinbuffer[0]) > 0 then
    stdinbufcol := pred(stdinbufcol)
end;

*)

{ Useful routines }

procedure message (msg : mstring);
begin
  writeln(stderr^.f, msg)
end;

procedure quit;
var
  i : integer;
begin
  for i := 1 to maxopen do
    if openlist[i] <> nil then
      close(openlist[i]^.f);
  halt
end;

procedure error;
begin
  message(version + CR + LF + msg);
  quit
end;

var
  src, dst : iostream;

{$a- recursion on }

procedure evaluate;

(* The grammer used for parsing (in Backus-Naur form):

  addingOperator ::= PLUS | MINUS
  multiplyingOperator ::= TIMES | DIVIDE
  assignment ::= variable-identifier = expression
  expression ::= ? simpleExpression { addingOperator simpleExpression }
  simple_expression ::= term { multiplyingOperator term }
  term ::= signedFactor { EXPONETIATION signedFactor }
  signedFactor ::= factor | -factor
  factor ::= number | variable-identifier |
             (expression) | function-identifier(expression)  *)

const
  MINUS = DASH;
  TIMES = STAR;
  DIVIDE = SLASH;
  EXPONENTIATION = CARET;
  ENDEXPR = SEMICOL;
  digits : cset = ['0'..'9'];
  letters : cset = ['A'..'Z'];
  initiallized : boolean = false;
var
  c : char;
  r : real;
  i : integer;
  variables : array[1..26] of real;

  procedure evalerror (msg : mstring);
  var
    lin, col : string[5];
  begin
    str(src^.buflin, lin);
    str(src^.bufcol, col);
    error(msg + CR + LF + 'Line ' + lin + '  Column ' + col)
  end;

  function idindex : integer;
  var
    s : sstring;
  begin
    s := '';
    while upcase(getcf(src, c)) in letters do
      s := s + upcase(c);
    ungetcf(src);
    if length(s) = 1 then idindex := succ(ord(upcase(s[1])) - ord('A'))
    else if s = 'ABS' then idindex := 128
    else if s = 'ARCTAN' then idindex := 129
    else if s = 'COS' then idindex := 130
    else if s = 'EXP' then idindex := 131
    else if s = 'LN' then idindex := 132
    else if s = 'SIN' then idindex := 133
    else if s = 'SQR' then idindex := 134
    else if s = 'SQRT' then idindex := 135
    else evalerror('Unknown identifier ' + s)
  end;

  function number : real;
  var
    s : sstring;
    errpos : integer;
  begin { number }
    s := '';
    while getcf(src, c) in digits do
      s := s + c;
    if c = DOT then begin
      s := s + DOT;
      while getcf(src, c) in digits do
        s := s + c
    end;
    if upcase(c) = 'E' then begin
      s := s + 'E';
      if getcf(src, c) in [MINUS, PLUS] then
        s := s + c
      else
        ungetcf(src);
      while getcf(src, c) in digits do
        s := s + c
    end;
    ungetcf(src);
    val(s, r, errpos);
    if errpos <> 0 then
      evalerror('Floating point overflow')
    else
      number := r
  end;

  function expression : real;

    function simpleExpression : real;

      function term : real;

        function signedFactor : real;

          function factor : real;
          begin
            if (nextcf(src, c) in digits) or (c = DOT) then begin
              ungetcf(src);
              factor := number
            end
            else if c = LPAREN then begin
              factor := expression;
              if nextcf(src, c) <> RPAREN then begin
                ungetcf(src);
                evalerror('Right parenthesis expected')
              end
            end
            else if upcase(c) in letters then begin
              ungetcf(src);
              i := idindex;
              if i in [1..26] then
                factor := variables[i]
              else begin
                if nextcf(src, c) <> LPAREN then
                  evalerror('Left parenthesis expected');
                case i of
                  128 : factor := abs(expression);
                  129 : factor := arctan(expression);
                  130 : factor := cos(expression);
                  131 : factor := exp(expression);
                  132 : factor := ln(expression);
                  133 : factor := sin(expression);
                  134 : factor := sqr(expression);
                  135 : factor := sqrt(expression)
                end;
                if nextcf(src, c) <> RPAREN then
                  evalerror('Right parenthesis expected')
              end
            end
            else
              evalerror('Factor expected')
          end;

        begin { signedFactor }
          case nextcf(src, c) of
            MINUS : signedFactor := - factor;
            PLUS  : signedFactor := factor
            else    begin
                      ungetcf(src);
                      signedFactor := factor
                    end
          end
        end;

     begin { term }
        r := signedFactor;
        while nextcf(src, c) = EXPONENTIATION do
          r := exp(ln(r) * signedFactor);
        ungetcf(src);
        term := r
       end;

    begin { simpleExpression }
      r := term;
      while nextcf(src, c) in [TIMES, DIVIDE] do
        case c of
          TIMES : r := r * term;
          DIVIDE: r := r / term
        end;
      ungetcf(src);
      simpleExpression := r
    end;

  begin { expression }
    r := simpleExpression;
    while nextcf(src, c) in [PLUS, MINUS] do
      case c of
        PLUS  : r := r + simpleExpression;
        MINUS : r := r - simpleExpression
      end;
    ungetcf(src);
    expression := r
  end;

begin { evaluate }
  if not initiallized then begin
    fillchar(variables, sizeof(variables), 0);
    initiallized := true
  end;
  while nextcf(src, c) = ENDEXPR do { throw away any optional terminators }
    ;
  if c <> ENDFILE then begin
    if c = QUESTION then begin
      r := expression;
      writeln(dst^.f, r)
    end
    else if upcase(c) in letters then begin
      ungetcf(src);
      i := idindex;
      if not (i in [1..26]) then
        evalerror('Not a variable name');
      if nextcf(src, c) <> EQUAL then
        evalerror('''='' expected');
      variables[i] := expression
    end
    else
      evalerror('''?'' or variable name expected');
    evaluate
  end
end;

{$a+ recursion off }

{ main }

begin
  initio;
  if paramcount > 0 then begin
    src := fopen(paramstr(1), IOREAD);
    if src = nil then
      error('Unable to open ' + paramstr(1))
  end
  else
    src := fopen('con:', IOREAD);
  if paramcount > 1 then begin
    dst := fopen(paramstr(2), IOWRITE);
    if dst = nil then
      error('Unable to open ' + paramstr(2))
  end
  else
    dst := fopen('con:', IOWRITE);
  evaluate;
  quit
end.
