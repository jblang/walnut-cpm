(* Compute analytic functions as truncated sums.  Determine
   the recurrence relations of their terms. *)

MODULE recurrence;

FROM InOut     IMPORT WriteString, WriteLn;
FROM RealInOut IMPORT WriteReal, ReadReal;

VAR n: CARDINAL;
    i,x,y,s,t: REAL;

BEGIN
  WriteString(' exp'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); y := 1.0;
    i := 0.0; t := 1.0;
    REPEAT
      i := i + 1.0;
      t := t*x/i;
      y := y+t;
    UNTIL y+t = y;
    WriteReal(x,9); WriteReal(y,9); WriteReal(i,9);
    DEC(n);
  UNTIL n = 0;

  WriteString(' sin'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); y := x;
    i := 1.0; s := x*x;
    t := x;
    REPEAT
      i := i + 2.0;
      t := -t*s/((i-1.0)*i);
      y := y + t;
    UNTIL y + t = y;
    WriteReal(x,9); WriteReal(y,9); WriteReal(i/2.0,9);
    DEC(n);
  UNTIL n = 0;

  WriteString(' cos'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); y := 1.0;
    i := 0.0; s := x*x;
    t := 1.0;
    REPEAT
      i := i + 2.0;
      t := -t*s/((i-1.0)*i);
      y := y + t;
    UNTIL y + t = y;
    WriteReal(x,9); WriteReal(y,9); WriteReal(i/2.0,9);
    DEC(n);
  UNTIL n = 0;

  WriteString(' arcsin'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); y := x;
    i := 1.0; s := x*x;
    t := x;
    REPEAT
      i := i + 2.0;
      t := t*s*((i-2.0)*(i-2.0))/((i-1.0)*i);
      y := y + t;
    UNTIL y + t = y;
    WriteReal(x,9); WriteReal(y,9); WriteReal(i/2.0,9);
    DEC(n);
  UNTIL n = 0;

  WriteString(' arctan'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); y := x;
    i := 1.0; s := x*x;
    t := x;
    REPEAT
      i := i + 2.0;
      t := -t*s*(i-2.0)/i;
      y := y + t;
    UNTIL y + t = y;
    WriteReal(x,9); WriteReal(y,9); WriteReal(i/2.0,9);
    DEC(n);
  UNTIL n = 0;

  WriteString(' ln'); WriteLn;
  n := 1;
  REPEAT
    ReadReal(x); x := x - 1.0;
    y := x; t := x; i := 1.0;
    REPEAT
      i := i + 1.0;
      t := -t*x*(i-1.0)/i;
      y := y + t;
    UNTIL y + t = y;
    WriteReal(x + 1.0,9); WriteReal(y,9); WriteReal(i,9);
    DEC(n);
  UNTIL n = 0;
END recurrence.
