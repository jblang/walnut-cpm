(* Compute the greatest common divisor (gcd) of two natuaral
   numbers.  Use addition, subtraction, doubling and halving only. *)

MODULE binarygcd;
FROM InOut IMPORT ReadInt, WriteInt, WriteLn, WriteString;

VAR a,b: INTEGER;

PROCEDURE gcd(x,y: INTEGER): INTEGER;
VAR u,v,d, a,b,k: INTEGER;
BEGIN
  u := x; v := y;
  a := 0; b := 0;
  WHILE NOT ODD(u) DO
    u := u DIV 2;
    INC(a);
  END;
  WHILE NOT ODD(v) DO
    v := v DIV 2;
    INC(b);
  END;
  IF a < b THEN k := a ELSE k := b END;
  d := u-v;
  WHILE d # 0 DO
    REPEAT d := d DIV 2 UNTIL ODD(d);
    IF d < 0 THEN v := -d ELSE u := d END;
    d := u-v;
  END;
  WHILE k > 0 DO
    u := 2*u;
    k := k-1;
  END;
  RETURN u
END gcd;

BEGIN
  WriteString('Enter a> ');
  ReadInt(a); WriteLn;
  WHILE a # 0 DO
    WriteString('Enter b> ');
    ReadInt(b); WriteLn;
    WriteInt(a,6); WriteInt(b,6);
    WriteInt(gcd(a,b),6); WriteLn;
    WriteString('Enter a> ');
    ReadInt(a); WriteLn
  END
END binarygcd.
