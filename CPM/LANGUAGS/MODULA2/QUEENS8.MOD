(* Find all settings of 8 queens on an 8x8 chess board such
   that no queen checks another queen.
   [see also, Comm. ACM 14, 4, 221-27 (April 74)]. *)

MODULE queens;

FROM InOut IMPORT Write, WriteLn, WriteInt;

VAR i: INTEGER;
    a: ARRAY [1..8] OF BOOLEAN;
    b: ARRAY [2..16] OF BOOLEAN;
    c: ARRAY [-7..7] OF BOOLEAN;
    x: ARRAY [1..8] OF INTEGER;
    safe: BOOLEAN;

PROCEDURE print;
VAR k: INTEGER;
BEGIN
  Write(' ');
  FOR k:= 1 TO 8 DO WriteInt(x[k],2) END;
  WriteLn
END print;

PROCEDURE trycol(j: INTEGER);
VAR i: INTEGER;

  PROCEDURE setqueen;
  BEGIN
    a[i] := FALSE;
    b[i+j] := FALSE;
    c[i-j] := FALSE
  END setqueen;

  PROCEDURE removequeen;
  BEGIN
    a[i] := TRUE;
    b[i+j] := TRUE;
    c[i-j] := TRUE
  END removequeen;

BEGIN
  i := 0;
  REPEAT
    INC(i);
    safe := a[i] AND b[i+j] AND c[i-j];
    IF safe THEN
      setqueen;
      x[j] := i;
      IF j < 8 THEN trycol(j+1) ELSE print END;
      removequeen
    END
  UNTIL i = 8
END trycol;

BEGIN
  FOR i := 1 TO 8 DO a[i] := TRUE END;
  FOR i := 2 TO 16 DO b[i] := TRUE END;
  FOR i := -7 TO 7 DO c[i] := TRUE END;
  trycol(1)
END queens.
