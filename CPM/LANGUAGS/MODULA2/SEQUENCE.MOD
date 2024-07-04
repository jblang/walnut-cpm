(* Find sequence of digits 0, 1, 2 and of lengths 1 ... 90, such
   that they contain no two adjacent subsequences that are equal *)

MODULE sequence012;

FROM  InOut IMPORT Write, WriteString, WriteLn, WriteCard;

CONST maxlength = 75;

VAR n: CARDINAL;
    good: BOOLEAN;
    s: ARRAY [1..maxlength] OF CARDINAL;

PROCEDURE printsequence;
VAR k: CARDINAL;

BEGIN
  Write(' ');
  FOR k := 1 TO n DO WriteCard(s[k],1) END;
  WriteLn
END printsequence;

PROCEDURE changesequence;
BEGIN
  IF s[n] = 3 THEN
    DEC(n);
    changesequence;
  ELSE
    s[n] := s[n]+1
  END
END changesequence;

PROCEDURE try;
VAR i,l,nhalf: CARDINAL;

BEGIN
  IF n <= 1 THEN
    good := TRUE
  ELSE
    l := 0; nhalf := n DIV 2;
    REPEAT
      INC(l); i := 0;
      REPEAT
        good := s[n-i] # s[n-l-i];
        INC(i)
      UNTIL good OR (i = l)
    UNTIL NOT good OR (l >= nhalf)
  END
END try;

BEGIN
  n := 0;
  REPEAT
    INC(n);
    s[n] := 1; try;
    WHILE NOT good DO
      changesequence;
      try
    END;
    printsequence;
    UNTIL n = maxlength
  END sequence012.
