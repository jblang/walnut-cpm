(* Divide an integer by a natural number, using operations of
   addition, subtraction    , doubling and halving only.  Repeat
   reading pairs of integers, until you encounter a 0.  For each pair,
   print dividend, divisor, quotient, and remainder.  Indicate
   invariant of loop.*)

MODULE divide;
FROM Terminal IMPORT WriteString, WriteLn;
FROM InOut    IMPORT ReadInt,WriteInt;

VAR a,b,q,r:INTEGER;

PROCEDURE divide(x,y: INTEGER; VAR z,a:INTEGER);
VAR q,r,w: INTEGER;

BEGIN
  r := x; w := y; q := 0;
  WHILE w <= r DO w := 2*w END;
  WHILE w # y DO
    w := w DIV 2;
    q := 2*q;
    IF w <= r THEN
      r := r-w; INC(q);
    END
  END;
  z := q; a := r;
END divide;

BEGIN
  WriteString('Enter dividend> ');
  ReadInt(a);
  WHILE a # 0 DO
    WriteString('Enter divisor> ');
    ReadInt(b);
    divide(a,b,q,r);
    WriteInt(a,3); WriteInt(b,3);
    WriteInt(q,3); WriteInt(r,3);
    WriteLn;
    WriteString('Enter dividend> ');
    ReadInt(a);
  END
END divide.
