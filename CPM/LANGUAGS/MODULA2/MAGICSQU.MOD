(* Read a text and count the number of words with length
   1, 2, ... , 20, and those with length greater than 20.
   Words are separated by blanks or ends of lines. *)

MODULE wordlengths;

FROM InOut IMPORT WriteString, WriteLn, WriteCard, OpenInput, Read, Done;


VAR i,k: CARDINAL;
    ch: CHAR;
    count: ARRAY [1..21] OF CARDINAL;

BEGIN
  OpenInput('TEXT');
  FOR i := 1 TO 21 DO count[i] := 0 END;
  LOOP
    Read(ch);
    IF NOT Done THEN EXIT END;
    IF ('A' <= CAP(ch)) AND (CAP(ch) <= 'Z') THEN
      k := 0;
      REPEAT
        INC(k); Read(ch);
      UNTIL (CAP(ch)< 'A') OR ('Z' < CAP(ch));
      IF k > 20 THEN k := 21 END;
      INC(count[k])
    END
  END;
  WriteLn;
  WriteString('  Length  Count');
  FOR i := 1 TO 21 DO
    WriteCard(i,6); WriteCard(count[i],6)
  END
END wordlengths.
