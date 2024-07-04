(* Find an optimal selection of objects from a given set of n objects
   under a given constraint.  Each object is characterised by two
   properties v (for value) and w (for weight).  The optimal selection
   is the one with the largest sum of values of its members.  The
   constraint is that the sum of their weights must not surpass
   a given limit limv.  The algorithm is called branch and bound. *)

MODULE selection;

FROM InOut IMPORT WriteString, WriteCard, ReadCard, WriteLn, Write;

CONST n = 10;

TYPE index = [1..n];
     object = RECORD
                v,w: CARDINAL
              END;
     soi = SET OF index;

VAR i: index;
    a: ARRAY index OF object;
    limw,totv,maxv,w1,w2,w3: CARDINAL;
    s,opts: soi;
    z: ARRAY [0..1] OF CHAR;

PROCEDURE try(i: index; tw,av: CARDINAL);
VAR av1: CARDINAL;

BEGIN
  IF tw + a[i].w <= limw THEN
    INCL(s,i);
    IF i < n THEN
      try(i+1,tw+a[i].w,av)
    ELSE
      IF av > maxv THEN
        maxv := av;
        opts := s
      END;
      EXCL(s,i)
    END
  END;
  av1 := av - a[i].v;
  IF av1 > maxv THEN
    IF i < n THEN
      try(i+1,tw,av1)
    ELSE
      maxv := av1;
      opts := s
    END
  END
END try;

BEGIN
  totv := 0;
  FOR i := 1 TO n DO
    WITH a[i] DO
      WriteString(' Enter the value> '); ReadCard(v);
      WriteString(' Enter the weight> '); ReadCard(w);
      WriteLn;
      totv := totv + v
    END
  END;
  WriteString(' Enter weights 1, 2, 3 > ');
  ReadCard(w1); ReadCard(w2); ReadCard(w3);
  WriteLn;
  z[0] := '*'; z[1] := ' ';
  WriteLn; WriteString(' weight > ');
  FOR i := 1 TO n DO WriteCard(a[i].w,4) END;
  WriteLn; WriteString(' value> ');
  FOR i := 1 TO n DO WriteCard(a[i].v,4) END;
  WriteLn;
  REPEAT
    limw := w1;
    maxv := 0;
    s := soi{}; opts := soi{};
    try(1,0,totv);
    WriteCard(limw,6);
    FOR i := 1 TO n DO
      WriteString('  ');
      IF i IN opts THEN Write(z[0]) ELSE Write(z[1]) END;
    END;
    WriteLn;
    w1 := w1 + w2;
  UNTIL w1 > w3
END selection.
