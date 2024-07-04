(* Find a solution to the stable marriage problem.  n men and
   n women state their preferences of partners.  Find n pairs
   such that no man would prefer to be married to another woman
   who would also prefer him to her partner.  A set of pairs is
   called stable, if no such cases exist.
   [see also Comm. ACM 14, 7, 486-92 (July 71)]. *)

MODULE marriage;

FROM  InOut IMPORT WriteString, Write, WriteLn, WriteCard, ReadCard;

CONST n = 8;

TYPE man = [1..n];
     woman = [1..n];
     rank = [1..n];

VAR m: man;
    w: woman;
    r: rank;
    wmr: ARRAY man,rank OF woman;
    mwr: ARRAY woman,rank OF man;
    rmw: ARRAY man,woman OF rank;
    rwm: ARRAY woman,man OF rank;
    x: ARRAY man OF woman;
    y: ARRAY woman OF man;
    single: ARRAY woman OF BOOLEAN;

PROCEDURE print;
VAR m: man;
    rm,rw: CARDINAL;

BEGIN
  rm := 0; rw := 0;
  FOR m := 1 TO n DO
    WriteCard(x[m],4);
    rm := rm + rmw[m,x[m]];
    rw := rw + rwm[x[m],m]
  END;
  WriteCard(rm,8); WriteCard(rw,4);
  WriteLn
END print;

PROCEDURE try(m: man);
VAR r: rank;
    w: woman;

  PROCEDURE stable(): BOOLEAN;
  VAR pm: man;
      pw: woman;
      i,lim: rank;
      s: BOOLEAN;

  BEGIN
    s := TRUE; i := 1;
    WHILE (i < r) AND s DO
      pw := wmr[m,i];
      INC(i);
      IF NOT single[pw] THEN s := rwm[pw,m] > rwm[pw,y[pw]] END;
    END;
    i := 1;
    lim := rwm[w,m];
    WHILE (i < lim) AND s DO
      pm := mwr[w,i]; INC(i);
      IF pm < m THEN s := rmw[pm,w] > rmw[pm,x[pm]] END;
    END;
    RETURN s
  END stable;

BEGIN
  FOR r := 1 TO n DO
    w := wmr[m,r];
    IF single[w] THEN
      IF stable() THEN
        x[m] := w;
        y[w] := m;
        single[w] := FALSE;
        IF m < n THEN try(m+1) ELSE print END;
        single[w] := TRUE
      END
    END
  END
END try;

BEGIN
  Write('1'); WriteLn;
  FOR m := 1 TO n DO
    FOR r := 1 TO n DO
WriteString('Enter> ');
      ReadCard(wmr[m,r]);
      rmw[m,wmr[m,r]] := r;
WriteLn;
    END
  END;
  FOR w := 1 TO n DO
    FOR r := 1 TO n DO
WriteString('Enter2> ');
      ReadCard(mwr[w,r]);
      rwm[w,mwr[w,r]] := r;
WriteLn;
    END
  END;
  FOR w := 1 TO n DO single[w] := TRUE END;
  try(1)
END marriage.

    (* 5 7 1 2 6 8 4 3
       2 3 7 5 4 1 8 6
       8 5 1 4 6 2 3 7
       3 2 7 4 1 6 8 5
       7 2 5 1 3 6 8 4
       1 6 7 5 8 4 2 3
       2 5 7 6 3 4 8 1
       3 8 4 5 7 2 6 1
       5 3 7 6 1 2 8 4
       8 6 3 5 7 2 1 4
       1 5 6 2 4 8 7 3
       8 7 3 2 4 1 5 6
       6 4 7 3 8 1 2 5
       2 8 5 4 6 3 7 1
       7 5 2 1 8 6 4 3
       7 4 1 5 2 3 6 8 *)
