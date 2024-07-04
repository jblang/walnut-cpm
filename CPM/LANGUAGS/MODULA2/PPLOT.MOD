MODULE printerplot;

FROM InOut    IMPORT Write, WriteLn;
FROM Terminal IMPORT WriteString;
FROM MathLib0 IMPORT exp, cos;

CONST xscale = 32;
      yscale = 50;
      yshift = 65;
      twopi = 6.2831833071796;

TYPE Double = RECORD
                CASE BOOLEAN OF
                  TRUE: r:REAL|
                  FALSE: h,l:CARDINAL
                END
              END;

VAR i,n: CARDINAL;
    k,j: INTEGER;
    x,y: REAL;

PROCEDURE WriteBits(x: REAL);
VAR high,low: BITSET;
    i: CARDINAL;
    w: Double;

BEGIN
  w.r := x;
  high := BITSET(w.h);
  FOR i := 0 TO 15 DO
    IF i IN high THEN Write('1') ELSE Write('0') END
  END;
  low := BITSET(w.l);
  FOR i := 0 TO 15 DO
    IF i IN low THEN Write('1') ELSE Write('0') END
  END
END WriteBits;

BEGIN
  n := 0;
  REPEAT
    x := FLOAT(n)/FLOAT(xscale); i := 0;
WriteString('x = '); WriteBits(x); WriteLn;
    y := exp(-x)*cos(x*twopi);
WriteString('y = '); WriteBits(y); WriteLn;
    k := TRUNC((y*FLOAT(yscale))+0.5);
WriteString('k = '); WriteBits(k); WriteLn;
    IF k < 0 THEN
      FOR j := 0 TO yshift + k DO Write(' ') END; Write('*');
      k := -k - 1;
      IF k > 0 THEN
        FOR j := 0 TO k DO Write(' ') END; Write('|');
      END
    ELSE
      FOR j := 0 TO yshift DO Write(' ') END;
      IF k > 0 THEN
        Write('|');
        DEC(k);
        IF k > 0 THEN FOR j := 0 TO k DO Write(' ') END END
      END;
      Write('*');
    END;
    WriteLn;
    INC(n);
  UNTIL n > 96;
END printerplot.
