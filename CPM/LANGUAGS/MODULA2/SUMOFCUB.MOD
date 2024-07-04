(* Find the cmallest positive integer that can be represented
   as the sum of two cubes (integers raised to the third power)
   in two different ways. *)

MODULE sumofcubes;

FROM  InOut IMPORT WriteString, WriteCard, WriteLn;

VAR i,ih,il,min,a,b,k: CARDINAL;
    j,sum,pwr: ARRAY [1..200] OF CARDINAL;
        (* pwr[k] = power of k, sum[k] = p[k] + p[j[k]],
           j[k] = columnindex of last considered candidate in row k,
           ih = rowindex of highest considered fow,
           il = rowindex of least still relevant row *)

BEGIN
  i := 1; il := 1; ih := 2;
  j[1] := 1; j[2] := 1;
  pwr[1] := 1; pwr[2] := 8;
  sum[1] := 2; sum[2] := 9;
  REPEAT
    min := sum[i];
    a := i; b := j[i];
      (* now get the sum in rw i *)
    IF j[i] = i THEN
      INC(il);
    ELSE
      IF j[i] = 1 THEN
          (* the new min was from the first column, now add
            a new row before taking the new sum from the old row *)
        INC(ih);
        pwr[ih] := ih*ih*ih;
        j[ih] := 1;
        sum[ih] := pwr[ih] + 1
      END;
      j[i] := j[i] + 1;
      sum[i] := pwr[i] + pwr[j[i]]
    END;
      (* now find minimal candidate in rows ol..ih *)
    i := il; k := i+1;
    WHILE k <= ih DO
      IF sum[k] < sum[i] THEN i := k END;
      INC(k)
    END
  UNTIL sum[i] = min;
  WriteCard(min,6); WriteCard(a,6);
  WriteCard(b,6); WriteCard(i,6);
  WriteCard(j[i],6); WriteLn
END sumofcubes.
