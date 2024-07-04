(* Read a text and replace any sequence
   of one or more blanks by a single blank. *)

MODULE crunch;

FROM InOut IMPORT Write, WriteLn, Read, Done, OpenInput;

CONST blank = ' ';

VAR ch: CHAR;

BEGIN
  OpenInput('TEXT');
  LOOP
    Read(ch);
    IF NOT Done THEN EXIT END;
    Write(blank);
    WHILE ch = blank DO Read(ch) END;
    WHILE ch # 36C DO
      REPEAT
        Write(ch);
        Read(ch);
        IF NOT Done THEN EXIT END;
      UNTIL ch = blank;
      Write(blank);
      LOOP
        IF (ch # blank) OR (ch = 36C) THEN EXIT END;
        Read(ch);
        IF NOT Done THEN EXIT END
      END
    END;
    WriteLn; Read(ch)
  END
END crunch.
