(* Compute the harmonic function H(n) = 1 + 1/2 + 1/3 + ... + 1/n
   with m digits accuracy. *)

MODULE harmonic;

FROM InOut IMPORT WriteString, WriteLn, WriteCard, ReadCard, Write;

CONST lim = 100;

VAR i,k,m,n,c,r,q,sum: CARDINAL;
    d,s: ARRAY [0..lim] OF CARDINAL;

BEGIN
  WriteString('Digits of Accuracy> '); ReadCard(m);
  WriteLn; WriteString('n> '); ReadCard(n);
  IF (m > 0) AND (m < lim) THEN
    d[0] := 0; s[0] := 1;
    FOR i := 1 TO m DO s[i] := 0 END;
    FOR k := 2 TO n DO
      (* compute 1/k *)
      r := 1;
      FOR i := 1 TO m DO
        r := 10*r; q := r DIV k;
        r := r - q*k; d[i] := q;
      END;
      IF (10*r DIV k) >= 5 THEN d[m] := d[m]+1 END; (* round *)
      WriteString(' 0.'); (* intermediate output *)
      FOR i := 1 TO m DO WriteCard(d[i],1) END;
      WriteLn;
      (* compute s := s + 1/k *)
      c := 0;
      FOR i := m TO 0 BY -1 DO
        sum := s[i]+d[i]+c;
        IF sum >= 10 THEN
          sum := sum-10; c := 1
        ELSE
          c := 0;
          s[i] := sum
        END
      END
    END;
    Write(' '); WriteCard(s[0],1); Write(' ');
    FOR i := 1 TO m DO WriteCard(s[i],1) END;
    WriteLn;
  END
END harmonic.
