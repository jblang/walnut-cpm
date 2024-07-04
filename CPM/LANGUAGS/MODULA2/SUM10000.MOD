(* 1. Compute the sum 1 - 1/2 + 1/3 - 1/4 + ... - 1/10000 four ways:
     A. proceed strictly from left to right,
     B. sum positive and negative terms separately,
     C. proceed strictly from fight to left,
     D. as in 2, but from right to left.
   Explain the differences in the results. *)

MODULE sum10000;

FROM InOut     IMPORT WriteLn;
FROM RealInOut IMPORT WriteReal;

CONST n = 10000;

VAR i : CARDINAL;
    x, y, s1, s2p, s2n : REAL;

BEGIN
  i := 1;  s1 := 0.0;  s2p := 0.0;  
  s2n := 0.0;
  REPEAT
    x := 1.0/FLOAT(i);   y := 1.0/FLOAT(i+1);
    s1 := s1 + x - y;
    s2p := s2p + x;  s2n := s2n + y;
    i := i + 2;
  UNTIL i > n;
  WriteReal(s1,12);
  WriteReal(s2p-s2n,12);
  i := n;
  s1 := 0.0;  s2p := 0.0;  s2n := 0.0;
  REPEAT
    x := 1.0/FLOAT(i-1);  y := 1.0/FLOAT(i);
    s1 := s1 + x - y;
    s2p := s2p + x;  s2n := s2n + y;
    i := i-2;
  UNTIL i = 0;
  WriteReal(s1,12);
  WriteReal(s2p-s2n,12);
  WriteLn;
END sum10000.

