MODULE log10k;

FROM MathLib IMPORT Ln;

(*

T.A. Elkin's Log(10K!) Benchmark.

Computes number of decimal digits in 10,000 factorial.
Exact answer is 35660

See COMPUTERWORLD. 3/20/87 for more info.

Adapted from the CP/M Basic Version by Jim Lill 7/20/87

Comparision Times:

IBM Compatible, GW-BASIC:               149 secs
MBASIC 5.0 @ 10MHz:                     110 secs
Turbo Pascal (CP/M @10MHz):             108 secs
Turbo Modula-2 (CP/M 10MHz), M-code:     55 secs
Turbo Modula-2 (CP/M 10MHz), Z80-code:  >55 secs

*)

CONST exact = 3566.0E1;

VAR i : INTEGER;
    e,x,y,z : REAL;

BEGIN;  (*log10k*)
  z:= 1.0E1;
  x:= 0.0E0;
  WRITELN('Elkins Log(10K!) Benchmark',CHR(7));
  FOR i := 2 TO 10000 DO
    y:= FLOAT(i);
    x:= x + Ln(y);
  END;
  WRITELN('Done',CHR(7));
  WRITELN('Error: ',(exact- x/Ln(z)))
END log10k.
                         