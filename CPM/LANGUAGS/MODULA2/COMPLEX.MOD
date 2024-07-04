(* Multiply the complex number z = 5/13 + 12/13i 50 times
   with the complex number w = (0.6 + 0.8i).  Print intermediate
   products and the square of their absolute value.
   Note that |z| = |w| = 1. *)

MODULE complexmult;
FROM RealInOut IMPORT WriteReal;
FROM Terminal  IMPORT WriteLn;

CONST u = 0.6;
      v = 0.8;

VAR i,j: CARDINAL;
    x,x1,y: REAL;

BEGIN
  x := 5.0/13.0; y := 12.0/13.0;
  FOR i := 1 TO 50 DO
    FOR j := 1 TO 10 DO
      (* (x+iy) := (x+iy) * (u+iv) *)
      x1 := x*u - y*v;
      y := y*u + x*v;
      x := x1
    END;
    WriteReal(x,6); WriteReal(y,6);
    WriteReal(x*x + y*y,6); WriteLn
  END
END complexmult.
