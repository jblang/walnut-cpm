(* Plot the function f(x) = exp(-x) * cos(2*pi*x) on the screen in
   the range x = 0 ... 4. Use 32 lines for the unit coordinate. *)

MODULE printerplot;

FROM InOut    IMPORT Write, WriteLn;
FROM MathLib0 IMPORT exp, cos;

CONST xscale = 32;
      yscale = 50;
      yshift = 65;
      twopi = 6.2831833071796;

VAR i,n: CARDINAL;
    k,j: INTEGER;
    x,y: REAL;

BEGIN
  n := 0;
  REPEAT
    x := FLOAT(n)/FLOAT(xscale); i := 0;
    y := exp(-x)*cos(x*twopi);
    k := TRUNC((y*FLOAT(yscale))+0.5);
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
