(* Compute all n! permutations of the integers 1 ... n. *)

MODULE permute;

FROM InOut IMPORT Read, Write, WriteLn;

VAR n: CARDINAL;
    ch: CHAR;
    a: ARRAY [1..20] OF CHAR;

PROCEDURE output;
VAR i: CARDINAL;

BEGIN
  FOR i := 1 TO n DO Write(a[i]) END;
  WriteLn
END output;

PROCEDURE permute(k: CARDINAL);
VAR i: CARDINAL;
    t: CHAR;

BEGIN
  IF k = 1 THEN output
  ELSE
    permute(k-1);
    FOR i := 1 TO k-1 DO
      t := a[i];
      a[i] := a[k];
      a[k] := t;
      permute(k-1);
      t := a[i];
      a[i] := a[k];
      a[k] := t;
    END
  END
END permute;

BEGIN
  Write('>'); Read(ch);
  n := 0;
  WHILE ch > ' ' DO
    INC(n); a[n] := ch;
    Write(ch); Read(ch);
  END;
  WriteLn;
  permute(n)
END permute.
