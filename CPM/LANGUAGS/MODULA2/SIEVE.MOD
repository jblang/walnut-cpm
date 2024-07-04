(* Compute a table of the first n primes numbers.  Print m
   numbers per line.  Use the method of the sieve of Erasthenes. *)

MODULE sieve;

FROM Terminal IMPORT WriteString, WriteLn;
FROM InOut    IMPORT WriteCard;

CONST size = 8190;
      m = 10;

VAR flags: ARRAY[0..size] OF BOOLEAN;
    i,prime,k,count: INTEGER;

BEGIN
  count := 0;
  FOR i := 0 TO size DO flags[i] := TRUE END;
  FOR i := 0 TO size DO
    IF flags[i] THEN
      prime := i+i+3;
      k := i+prime;
      WHILE k <= size DO
        flags[k] := FALSE;
        INC(k,prime)
      END;
      INC(count);
      WriteCard(prime,8);
      IF count MOD m = 0 THEN WriteLn END
    END
  END;
  WriteLn; WriteCard(count,0);
  WriteString(' primes'); WriteLn
END sieve.
