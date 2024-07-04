program theseus;

{
  This program origionally appeared in the book by: Paul A. Sand called
  Advanced PASCAL Programming Techniques. It was entered and modified for
  Turbo Pascal 3.0 by: Felix M. Daske.

  The easy-to-understand code makes this an ideal program to learn Pascal by
  and lends itself readily to modifications. One such modification was the use
  of character graphics for the maze.

  NOTE; the use of these character graphics also makes this program IBM PC
        dependant. You will have to change the source (at the locations
        indicated) to suit your computer configuration.

  Further, a RANDOMIZE(,) routine was borrowed from the Turbo Tutor to
  produce true random values.
                                                          Later... Felix
}

const
  MazeCols  = 65;
  MazeRows  = 22;
  MaxCrtCol = 66;
  MaxCrtRow = 23;
  Xindent   = 1;
  Yindent   = 1;

type
  MazeSquare = (wall, path);
  MazeArray  = array [0..MazeRows, 0..MazeCols] of MazeSquare;
  CrtCommand = (home, clear, eraseol, eraseos, up, down, left, right, beep);
  Direction  = up..right;

var
  Maze: Mazearray;
  Won: boolean;
  ch: char;

procedure Randomize(I,J: Integer);

{ Please note:  This routine is for MS-Dos/PC-Dos Turbo ONLY! }

var
  RSet    : record
              AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags: Integer;
            end;
  Ch      : Char;

begin  { Randomize }
  if (I=0) and (J=0) then begin     { Generate a random random number seed }
    RSet.AX:=$2C00;                             { DOS time of day function }
    MSDos(RSet);
    I:=RSet.CX;                           { Set I and J to the system time }
    J:=RSet.DX;
    Delay(100);   { This delay may have to be increased for faster systems }
    MSDos(RSet);
    if (I=RSet.CX) and (J=RSet.DX) then begin        { Clock isn't ticking }
      I := 0;
      J := 0;
      while KeyPressed do
        Read(Kbd,Ch);                              { Clear keyboard buffer }
      Write('Hit any key to set the random number generator: ');
      repeat
        I := I+13;
        J := J+17
      until Keypressed;
      Read(Kbd,Ch);                                 { Absorb the character }
      WriteLn
    end
  end;
  MemW[DSeg:$129]:=I;  { This is the core of the routine: store a 32 bit }
  MemW[DSeg:$12B]:=J;  {  seed at locations DSeg:$0129...DSeg:$012C      }
end; { of procedure Randomize }


procedure dispsquare(val: Integer; row, col: integer);

begin  { dispsquare }
  gotoxy(col + Xindent, row + Yindent);
  write(chr(val))                       { CHG to write(ch) }
end;

procedure createmaze(var maze: mazearray);

var
  row, col : integer;
  dir      : direction;

procedure SetSquare(row, col : integer; val : MazeSquare);

begin { setsquare }
  maze[row, col] := val;
  case val of
    path  : dispsquare(032, row, col);    { CHG to " " from 032 }
    wall  : dispsquare(219, row, col);    { CHG to "@" from 219 }
  end
end;

function rnd (low, high: Integer): integer;

begin  { rnd }
  rnd := low + random  (high - low + 1);
end;

function randdir: direction;

begin { randdir }
  case rnd(1, 4) of
    1 : randdir := up;
    2 : randdir := down;
    3 : randdir := left;
    4 : randdir := right;
  end;
end;

function legalpath(row, col: integer; dir: direction): boolean;

var
  legal : boolean;

begin  { legalpath }
  legal := false;
  case dir of
    up    : if row > 2 then
              legal := (maze[row - 2, col] = wall);
    down  : if row < MazeRows - 2 then
              legal := (maze[row + 2, col] = wall);
    left  : if col > 2 then
              legal := (maze[row, col - 2] = wall);
    right : if col < MazeCols - 2 then
              legal := (maze[row, col + 2] = wall);
  end;
  legalpath := legal
end;

procedure buildpath(row, col: integer; dir : direction);

var
  unused: set of direction;

begin  { buildpath }
  case dir of
    up   : begin
             setsquare(row - 1, col, path);
             setsquare(row - 2, col, path);
             row := row -2
           end;
    down : begin
             setsquare(row + 1, col, path);
             setsquare(row + 2, col, path);
             row := row + 2
           end;
    left : begin
             setsquare(row, col - 1, path);
             setsquare(row, col - 2, path);
             col := col - 2
           end;
    right: begin
             setsquare(row, col + 1, path);
             setsquare(row, col + 2, path);
             col := col + 2
           end
   end;
unused := [up..right];
repeat
  dir := randdir;
  if dir in unused then
    begin
      unused := unused - [dir];
      if legalpath(row, col, dir) then
        buildpath(row, col, dir)
    end
  until unused = []
end;


begin { createmaze }
  for row := 0 to MazeRows do
    for col := 0 to MazeCols do
      SetSquare(row, col, wall);
  row   := 2 * rnd(0,trunc(MazeRows / 2 - 1)) + 1;
  col   := 2 * rnd(0,trunc(MazeCols / 2 - 1)) + 1;
  SetSquare(row, col, path);
  repeat
    dir := randdir
  until legalpath(row, col, dir);
  buildpath(row, col, dir);
  col   := 2 * rnd(0,trunc(MazeCols / 2 - 1)) + 1;
  SetSquare(0, col, path);
  col   := 2 * rnd(0,trunc(MazeCols / 2 - 1)) + 1;
  SetSquare(MazeRows, col, path)
end;

function solvemaze(var  maze: mazearray) : boolean;

var
  solved : boolean;
  row, col : integer;
  tried: array [0..mazerows, 0..mazecols] of boolean;

function try(row, col: integer; dir: direction) : boolean;

var
  ok : boolean;

procedure showmove(row, col: integer; dir : direction);

begin  { showmove }
  case dir of
    up    : dispsquare(024, row, col);     { CHG to "|" from 024 }
    down  : dispsquare(025, row, col);     {     "           025 }
    right : dispsquare(026, row, col);     {     "           026 }
    left  : dispsquare(027, row, col);     {     "           027 }
  end
end;

procedure erasemove(row, col : integer);

  begin  { erasemove }
    dispsquare(032, row, col)              { CHG to " " from 023 }
end;

begin  { try }
  ok := (maze[row, col] = path);
  if ok then
    begin
      tried[row, col] := true;
      case dir of
        up   : row := row - 1;
        down : row := row + 1;
        left : col := col - 1;
        right : col := col + 1;
    end;
    ok := (maze[row, col] = path) and not tried[row, col];
    if ok then
      begin
        showmove(row, col, dir);
        ok := (row <= 0) or (row >= mazerows) or
              (col <= 0) or (col >= mazecols);
        if not ok then
          ok := try(row, col, left);
        if not ok then
          ok := try(row, col, down);
        if not ok then
          ok := try(row, col, right);
        if not ok then
          ok := try(row, col, up);
        if not ok then  { no solution from this point }
          erasemove(row, col)
      end
  end;
  try := ok
end;


begin  { solvemaze }
  for row := 0 to mazerows do
    for col := 0 to mazecols do
      tried[row, col] := false;
  solved := false;
  col := 0;
  row := 1;
  while not solved and (row < mazerows) do begin
    solved := try(row, col, right);
    row := row + 1
  end;
  col := mazecols;
  row := 1;
  while not solved and (row < mazerows) do
    begin
      solved := try(row, col, left);
      row := row + 1
  end;
  row := 0;
  col := 1;
  while not solved and (col < mazecols) do
    begin
      solved := try(row, col, down);
      col := col + 1
  end;
  row := mazerows;
  col := 1;
  while not solved and (col < mazecols) do
    begin
      solved := try(row, col, up);
      col := col + 1
  end;
  solvemaze := solved
end;

begin
  Randomize(12,64);
  repeat
    HiRes;                          { CHG as required }
    createmaze(maze);
    gotoxy(68,1);
    writeln('    By:');
    gotoxy(68,2);
    writeln('Paul A. Sand');
    gotoxy(68,4);
    writeln('Press <c>');
    gotoxy(68,5);
    writeln('to continue');
    read(KBD,ch);
    Won := solvemaze(maze);
    gotoxy(68,7);
    writeln('Press <q>');
    gotoxy(68,8);
    writeln('to quit');
    read(KBD,ch)
  until ch in ['q', 'Q'];
  TextMode;                        { CHG as required }
end.                                                                                                                    