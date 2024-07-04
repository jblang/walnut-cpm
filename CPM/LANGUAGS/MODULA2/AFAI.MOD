IMPLEMENTATION MODULE afai;

CONST eps = 1.0E-8;

PROCEDURE sqrt(x:REAL):REAL;
VAR a,c: REAL;   (* 0<x<2 *)

BEGIN
  a := x; c := 1.0 - x;  (* abs(c) < 1 *)
  REPEAT  (* a^2=b*(1-c)>=(a*(1+c/2))^2=b*(1-c)*(1+c/2)^2=b*(1-0.75*(c^2)-0.25*c^3)) *)
    a := a*(1.0 + 0.5*c);
          (* a^2 = b*(1-0.75*(c^2)-0.25*(c^3)) = b*(1-(c^2)*0.75+0.25*c)*)
    c := c*c * (0.75 + 0.25*c);
          (* a^2 = b*(1-c) *)
  UNTIL ABS(c) < eps;
  RETURN a
END sqrt;

PROCEDURE log(x:REAL):REAL;
VAR a,b,sum: REAL;  (* 1<=x<2 *)

BEGIN
  a := x; b := 1.0;
  sum := 0.0;
  REPEAT
    (* log(x) = s + b*log(a), b <= 1, 1 <= a < 2 *)
    a := a*a; b := 0.5*b;
    IF a >= 2.0 THEN
      sum := sum + b;
      a := 0.5*a;
    END
  UNTIL ABS(b) < eps;
  RETURN sum
END log;

PROCEDURE recip(x:REAL):REAL;
VAR a,c: REAL;       (* 0<x<2 *)

BEGIN
  a := 1.0;
  c := 1.0-x;
  REPEAT             (* a*x = 1-c, abs(c) < 1 *)
    a := a*(1.0+c);  (* x*a = (1-c)*(1+c) = 1 - c^2 *)
    c := c*c;        (* x*a = 1-c *)
  UNTIL ABS(c) < eps;
  RETURN a           (* recip = 1/x *)
END recip;

END afai.
