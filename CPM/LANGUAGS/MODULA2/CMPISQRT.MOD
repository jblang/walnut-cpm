(* Compute the largest integer less or equal to the
   square foot of a given integer (due to Hoare). *)

MODULE isqrt;
FROM InOut IMPORT ReadCard, WriteCard, WriteLn, WriteString;

VAR n,a2,b2,ab,t: CARDINAL;

BEGIN
  WriteString('Enter n> ');
  ReadCard(n); WriteLn;
  WHILE n > 0 DO
    a2 := 0; ab :=0;
    b2 := 1;
    WriteString('n = ');
    WriteCard(n,4); WriteLn;
    WHILE b2 <= n DO b2 := 4*b2 END;
    WHILE b2 # 1 DO
      ab := ab DIV 2; b2 := b2 DIV 4;
      t := a2 + 2*ab + b2;
      IF t <= n THEN
        a2 := t;
        ab := ab+b2;
      END
    END;
    WriteCard(a2,4); WriteCard(ab,4);
    WriteCard(b2,4); WriteLn;
    WriteString('Enter n> ');
    ReadCard(n); WriteLn;
  END
END isqrt.
