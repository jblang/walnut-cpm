(* Compute the greatest common divisor (gcd) and the lowest common
   multiple (lcm) of two natural numbers by using addition and
   subtraction only.  Note that gcd(m,n) * lcm(m,n) = m*n.  Repeat
   reading pairs of integers until you encounter a 0.  For each
   pair, print the arguments, the gcd and the lcm.
   Indicate the loop invariant.*)

MODULE gcdlcm;
FROM InOut IMPORT ReadCard, WriteLn, WriteString, WriteCard;

VAR x,y,u,v: CARDINAL;

BEGIN
  WriteString('x = '); ReadCard(x); WriteLn;
  WHILE x # 0 DO
    WriteString('y = '); ReadCard(y);
    u := x; v := y;
    WHILE x # y DO
      (*gcd(x,y) = gcd(x0,y0), x*v + y*u = 2*x0*y0*)
      IF x > y THEN
        x := x-y;
        u := u+v;
      ELSE
        y := y-x;
        v := v+u;
      END
    END;
    WriteCard(x,6); WriteCard((u+v) DIV 2,6); WriteLn;
    WriteString('x = '); ReadCard(x); WriteLn;
  END;
END gcdlcm.
