(* Raise integer to a positive power.  Repeat reading pairs
   of integers, until you ecounter a 0.  Indicate invariant of loop.*)

MODULE power;
FROM Terminal IMPORT WriteString, WriteLn;
FROM MathLib0 IMPORT sqrt;
FROM InOut    IMPORT ReadInt,WriteInt;

VAR a,b:INTEGER;

PROCEDURE power(x,n:INTEGER): INTEGER;
VAR w,z,i: INTEGER;

BEGIN
  w := x; i := n;
  z := 1;
  WHILE i # 0 DO
    IF ODD(i) THEN z := z*w END;
    w := w*w;
    i := i DIV 2
  END;
  RETURN(z);
END power;

BEGIN
  WriteString('Enter number> ');
  ReadInt(a);
  WHILE a # 0 DO
    WriteString('Enter power> ');
    ReadInt(b);
    WriteInt(a,4); WriteInt(b,4);
    WriteInt(power(a,b),4);
    WriteLn;
    WriteString('Enter number> ');
    ReadInt(a);
  END;
END power.
