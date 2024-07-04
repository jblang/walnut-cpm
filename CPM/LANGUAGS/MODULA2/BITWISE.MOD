MODULE BitWise;

FROM SYSTEM   IMPORT WORD,
                     ADDRESS;

FROM InOut    IMPORT Read,
                     Write,
                     WriteCard,
                     WriteHex,
                     WriteString,
                     WriteLn;

PROCEDURE ShowBits(Data : ADDRESS);

VAR Bit:        INTEGER;
    BsData:     BITSET;

BEGIN

  BsData := BITSET(Data);

  WriteHex(Data,4); Write(' ');

  FOR Bit := 15 TO 0 BY -1 DO  (* Please Note if Bit is CARDINAL *)
      IF Bit IN BsData         (* Then the for loop is ignored   *)
        THEN Write('1');
        ELSE Write('0');
      END;
  END;

  WriteLn;

END ShowBits;

PROCEDURE BitShr(Data    : ADDRESS;
                 NumBits : ADDRESS) : ADDRESS;

VAR I:           CARDINAL;
    Shift:       CARDINAL;

BEGIN

  IF CARDINAL(NumBits) < 1
    THEN RETURN Data;
  END;

  IF CARDINAL(NumBits) > 15
    THEN RETURN ADDRESS(0);
  END;

  Shift := 1;

  FOR I := 1 TO CARDINAL(NumBits) DO
      Shift := Shift * 2;
  END;

  RETURN ADDRESS(CARDINAL(Data) DIV CARDINAL(Shift));

END BitShr;

PROCEDURE BitShl(Data    : ADDRESS;
                 NumBits : ADDRESS) : ADDRESS;

VAR I:           CARDINAL;
    Shift:       CARDINAL;

BEGIN

  IF CARDINAL(NumBits) < 1
    THEN RETURN Data;
  END;

  IF CARDINAL(NumBits) > 15
    THEN RETURN ADDRESS(0);
  END;

  Shift := 1;

  FOR I := 1 TO CARDINAL(NumBits) DO
      Shift := Shift * 2;
  END;

  RETURN ADDRESS(CARDINAL(Data) * CARDINAL(Shift));

END BitShl;

VAR
  Adata,
  Bdata,
  Cdata:        WORD;
  Count:        CARDINAL;
  CReply:       CHAR;

BEGIN

  WriteLn;

  ShowBits(ADDRESS(1));
  HALT;

  FOR Count := 0 TO 16 DO
    ShowBits(BitShr(8000H,ADDRESS(Count)));
  END;

  WriteString('Done with BitShr');WriteLn;

  FOR Count := 0 TO 16 DO
    ShowBits(BitShl(ADDRESS(1),ADDRESS(Count)));
  END;

  WriteString('Done');Read(CReply);

END BitWise.
