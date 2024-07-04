(* Compute a table of the first n prime numbers.
   Print m numbers per line. *)

MODULE primes;

FROM InOut IMPORT WriteLn, WriteCard;

CONST N = 500;
      M = 23;  (* M ~ sqrt(N) *)
      LL = 10; (* # of primes placed on a line *)

VAR i,k,x: CARDINAL;
    inc,lim,square,L: CARDINAL;
    prime: BOOLEAN;
    P,V: ARRAY [0..M] OF CARDINAL;

BEGIN
  L := 0; x := 1; inc := 4;
  lim := 1; square := 9;
  FOR i := 3 TO N DO
    (* find next prime number p[i] *)
    REPEAT
      x := x+inc;
      inc := 6-inc;
      IF square <= x THEN
        INC(lim); V[lim] := square;
        square := P[lim+1] * P[lim+1]
      END;
      k := 2; prime := TRUE;
      WHILE prime & (k < lim) DO
        INC(k);
        IF V[k] < x THEN V[k] := V[k] + 2*P[k] END;
        prime := x # V[k]
      END
    UNTIL prime;
    IF i <= M THEN P[i] := x END;
    WriteCard(x,6); INC(L);
    IF L = LL THEN WriteLn; L := 0 END
  END
END primes.
