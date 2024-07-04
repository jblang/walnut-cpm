(* Find a path of a knight on a chess board which
   covers all 64 squares. *)

MODULE knightstour;

FROM  InOut IMPORT WriteCard, WriteString, WriteLn;

CONST n = 5;
      nsq = 25;

TYPE index = [1..n];
     soi = SET OF index;

VAR i,j: index;
    q: BOOLEAN;
    s: soi;
    a,b: ARRAY [1..8] OF INTEGER;
    h: ARRAY [1..n],[1..n] OF INTEGER;

PROCEDURE try(i: INTEGER; x,y: index; VAR q: BOOLEAN);
VAR k,u,v: INTEGER;
    q1: BOOLEAN;

BEGIN
  k := 0;
  REPEAT
    INC(k); q1 := FALSE;
    u := INTEGER(x) + a[k];
    v := INTEGER(y) + b[k];
    IF (index(u) IN s) AND (index(v) IN s) THEN
      IF h[u,v] = 0 THEN
        h[u,v] := i;
        IF i < nsq THEN
          try(i+1,u,v,q1);
          IF NOT q1 THEN h[u,v] := 0 END
        ELSE
          q1 := TRUE
        END
      END
    END
  UNTIL q1 OR (k = 8);
  q := q1
END try;

BEGIN
  a[1] :=  2; b[1] :=  1;
  a[2] :=  1; b[2] :=  2;
  a[3] := -1; b[3] :=  2;
  a[4] := -2; b[4] :=  1;
  a[5] := -2; b[5] := -1;
  a[6] := -1; b[6] := -2;
  a[7] :=  1; b[7] := -2;
  a[8] :=  2; b[8] := -1;
  s := soi{1..5};
  FOR i := 1 TO n DO
    FOR j := 1 TO n DO h[i,j] := 0 END
  END;
  h[1,1] := 1; try(2,1,1,q);
  IF q THEN
    FOR i := 1 TO n DO
      FOR j := 1 TO n DO WriteCard(h[i,j],5) END;
      WriteLn
    END
  ELSE
    WriteString('No Solution');
    WriteLn
  END
END knightstour.
