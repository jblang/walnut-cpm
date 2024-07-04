(* Compute the Fibonacci numbers F(1) ... F(N) in two diff. ways:
     1. By repeated addition according to F(n) = F(n-1) + F(n-2),
          F(0) = F(1) = 1.
     2. Using the formula F(n) ~ (phi^n)/sqrt(5),
          where phi = (1+sqrt(5))/2.
   Terminate as soon as the two results differ
   (or before it overflows). *)

MODULE fibonacci;
FROM InOut IMPORT WriteCard, WriteLn;

CONST root5 = 2.236068;

VAR i,fib0,fib1,fib3,t: CARDINAL;
    phi,fib2: REAL;

BEGIN
  phi := (1.0 + root5)/2.0;
  i := 0; fib0 := 1;
  fib1 := 0; fib2 := 1.0/root5;
  REPEAT
    INC(i);
    t := fib0 + fib1;
    fib0 := fib1; fib1 := t;
    fib2 := fib2 * phi;
    fib3 := TRUNC(fib2 + 0.5);
    WriteCard(i,6); WriteCard(fib1,6);
    WriteCard(fib3,6); WriteLn;
  UNTIL i >= 24;  (*fib1 # fib3*)
END fibonacci.
