(* Find all integers between 1 and 210 whose squares are
   palindromes, e.g. 11^2 = 121, 22^2 = 484. *)

MODULE palindromes;

FROM InOut IMPORT ReadCard, WriteCard, WriteLn, WriteString;

VAR i,j,l,n,r,s: CARDINAL;
    p: BOOLEAN;
    d: ARRAY [1..10] OF CARDINAL;

BEGIN
  n := 0;
  REPEAT
    INC(n); s := n*n;
    l := 0;
    REPEAT
      INC(l); r := s DIV 10;
      d[l] := s - 10*r; s := r;
    UNTIL s = 0;
    i := 1; j := l;
    REPEAT
      p := d[i]=d[j];
      INC(i); DEC(j);
    UNTIL (i >= j) OR NOT p;
    IF p THEN WriteCard(n,6); WriteCard(n*n,6); WriteLn END;
  UNTIL n = 210
END palindromes.
