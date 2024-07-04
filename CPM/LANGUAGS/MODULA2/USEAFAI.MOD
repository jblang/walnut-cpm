MODULE useafai;

FROM Terminal  IMPORT WriteString, WriteLn;
FROM RealInOut IMPORT ReadReal, WriteReal;
FROM afai      IMPORT sqrt, log, recip;

VAR x: REAL;

BEGIN
  WriteString(' Square root test, Enter number> ');
  ReadReal(x); WriteLn;
  WriteReal(sqrt(x),12); WriteLn;
  WriteString(' Log test, Enter number> ');
  ReadReal(x); WriteLn;
  WriteReal(log(x),12); WriteLn;
  WriteString(' Reciprocal test, Enter number> ');
  ReadReal(x); WriteLn;
  WriteReal(recip(x),12); WriteLn;
END useafai.
