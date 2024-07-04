(* Read a text and produce a copy with flushed left and right margins.
   Place a fixed number of characters (say, length = 72) in each line,
   and distribute blanks as word separators accordingly. *)

MODULE chedit;

FROM InOut IMPORT Write, WriteLn, OpenInput, Done, Read;

CONST length = 72;

VAR ch: CHAR;
    i,m,k,lim: CARDINAL;
    line: ARRAY [1..136] OF CHAR;
    index: ARRAY [1..68] OF CARDINAL;

PROCEDURE setline;
VAR i,j,h,s,spaces,q,l,r: CARDINAL;
    
BEGIN
  IF m = 0 THEN m := 1; index[m] := lim END;
  j := 0; Write(' '); (* printer control *)
  IF m > 1 THEN
    spaces := lim - index[m];
    q := spaces DIV (m-1);
    r := spaces - (m-1)*q;
    l := (m-r) DIV 2;
    r := l + r;  (* distribute spaces *)
    i := 0;
    REPEAT
      INC(i);
      s := index[i];
      REPEAT
        INC(j);
        Write(line[j]);
      UNTIL j = s;
      FOR h := 1 TO q DO Write(' ') END;
      IF (l <= i) AND (i < r) THEN Write(' ') END;
    UNTIL i = m-1;
  END;
  s := index[m]-1;
  REPEAT INC(j); Write(line[j]) UNTIL j = s;
  j := 0; WriteLn;
  FOR h := index[m]+1 TO lim DO
    INC(j);
    line[j] := line[h];
  END;
  k := j; m := 0
END setline;

BEGIN
  OpenInput('TEXT');
  lim := length + 1;
  k := 0;            (* k = # OF characters IN line *)
  m := 0;            (* m = # OF complete words IN line *)
  LOOP
    Read(ch);
    IF NOT Done THEN EXIT END;
    IF ch # ' ' THEN
      REPEAT
        INC(k);
        line[k] := ch;
        Read(ch);
        IF k = lim THEN setline END
      UNTIL (ch = ' ') OR (NOT Done);
      INC(k); line[k] := ' ';
      INC(m); index[m] := k;
      IF k = lim THEN setline END
    END
  END;
  Write(' ');
  FOR i := 1 TO k DO Write(line[i]) END;
  WriteLn;
END chedit.
