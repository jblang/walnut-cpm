{ PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN }

CONST

MinAlpha = 1.0;    MaxNumInt = 50;



TYPE

IntType = 0..MaxNumInt;



VAR

FileName: String[14];    DataFile,GammaFile: Text;    OK,FirstTime: Boolean;

mode,ch,option,YesNo: Char;    Data: Array[0..100] of Integer;    realx: Real;

Gamma: Array[0..100] of Real;    NumSuccessfulQ,SuccessCount,total,N: Integer;

NumPerInt,x,sub: Byte;    RealExpected,MaxQ,MaxAlpha,ExpectedMean,sum: Real;

MaxBeta,MinBeta,MaxK,MinK,alpha,beta,k,Q: Real;    Expected: Integer;

Interval: Array[IntType] of Byte;    IntervalCount: IntType;



PROCEDURE  GetFileName(var DummyFile:text);

Begin  {GetFileName}
REPEAT
  Write('What is the name of the file?   ');   Readln(Filename);   Writeln;
  ASSIGN(DummyFile,FileName);
  {$I-}  RESET(DummyFile);  {$I+}     {see p. 114 of TURBO manual}
  OK := (IOResult = 0);
  IF NOT OK THEN Writeln(#7,' There is no file--',FileName,'; try another.')
UNTIL OK
End;   {GetFileName}



PROCEDURE  GetData;

Begin  {GetData}
FOR x := 0 to 100 DO Data[x] := 0;
Writeln('You should have a data file; give its name (incl. drive if necc.):');
GetFileName(DataFile);
REPEAT   Read(DataFile,x);   Readln(DataFile,Data[x])   UNTIL EOF(DataFile);
total := 0;     FOR x := 0 to 100 DO total := total + Data[x]
End;   {GetData}



PROCEDURE  GetParameters;

Begin  {GetParameters}
Write('How many expected occurences do you want per interval?   ');
Readln(NumPerInt);   Writeln;
REPEAT
  Write('Is your data peak at  H igh  or  L ow  values?   ');
  Readln(mode);   mode := UpCase(mode);   Writeln
UNTIL mode IN ['H','L'];
Write('Give maximum value of chi-square statistic you would want to list:   ');
Readln(MaxQ);   Writeln;
Write('Give number of successes before you want this run to stop:   ');
Readln(NumSuccessfulQ);   Writeln;
Writeln('Gamma(x|a,b,k) proportional to (x/k)^(a-1) exp[-b(x/k)]');
Writeln;
Writeln('alpha ~ U(',MinAlpha:2:1,',max) ');
Write('Give the maximum value you want:   ');
Readln(MaxAlpha);   Writeln;
Writeln('beta ~ U(min,max) ');
Write('Give min (no less than 0.1 is suggested):   ');   Readln(MinBeta);
Write('Give max (no greater than 5 is suggested):  ');   Readln(MaxBeta);
Writeln;
Writeln('k ~ U(min,max)');
ExpectedMean := (MinAlpha+MaxAlpha)/(MinBeta+MaxBeta);
Writeln('A good choice of min and max would be such that (min+max)/2 is');
Writeln('a little less than ',100/ExpectedMean:5:2,' given your choices for the');
Writeln('ranges of alpha and beta.');
Write('Give min for k:   ');   Readln(MinK);
Write('Give max for k:   ');   Readln(MaxK);   Writeln;
IF FirstTime THEN REPEAT
  Writeln('Set a page on the printer to about two lines below the top and');
  Writeln('T H E N  turn the printer on.');
  Writeln;
  Write('Did you do this?   ');   Readln(YesNo);   Writeln
UNTIL YesNo IN ['y','Y'];
Write(lst,#27'2'#18#27'U'#0);
Write(lst,#27'C'#0#11#27'E'#27'N'#7);
Writeln(lst);   Writeln(lst);   Writeln(lst);   Writeln(lst);
Write(lst,'Average Num. Per Interval = ',NumPerInt:1);
Writeln(lst,'     Maximum Q Value Accepted For Output = ',MaxQ:7:3);
Writeln(lst);
Write(lst,'Data File = ',FileName,'     Data Total = ',total:2,' Occurences');
IF mode = 'H' THEN Writeln(lst,'      Peak On High Side');
IF mode = 'L' THEN Writeln(lst,'      Peak On Low Side');
Writeln(lst);      Write(lst,'Required Number of Successful Q''s = ');
Writeln(lst,NumSuccessfulQ:2);   Writeln(lst);
Writeln(lst,'Alpha:   min =  ',MinAlpha:5:3,'     max =  ',MaxAlpha:5:3);
Writeln(lst,' Beta:   min =  ',MinBeta:5:3, '     max =  ',MaxBeta:5:3);
Writeln(lst,'    k:   min = ',MinK:6:3,     '     max = ',MaxK:6:3);
Writeln(lst);
Writeln(lst);
Writeln(lst,#27'F'#27'0'#27'U'#1#15);
FirstTime := FALSE
End;   {GetParameters}



PROCEDURE  CalculateGamma(ModePosition:char);

Begin  {CalculateGamma}
sum := 0;
IF ModePosition = 'H' THEN FOR x := 0 to 100 DO
   Begin
   IF x = 0 THEN Gamma[100] := 0 ELSE   Begin   realx := x/k;
   Gamma[100-x] := exp( (alpha-1) * ln(realx) - (beta*realx) )  End
   End;
IF ModePosition = 'L' THEN FOR x := 0 to 100 DO
   Begin
   IF x = 0 THEN Gamma[0] := 0 ELSE  Begin  realx := x/k;
   Gamma[x] := exp( (alpha-1) * ln(realx) - (beta*realx) )  End
   End;
FOR x := 0 to 100 DO sum := sum + Gamma[x];
FOR x := 0 to 100 DO Gamma[x] := Gamma[x]/sum
End;   {CalculateGamma}



PROCEDURE  CalculateQ;

Begin  {CalculateQ}
alpha := RANDOM * (MaxAlpha-MinAlpha) + MinAlpha;
 beta := RANDOM * (MaxBeta - MinBeta) + MinBeta;
    k := RANDOM * (MaxK    -    MinK) + MinK;
CalculateGamma(mode);
x := -1;     sub := 0;
REPEAT
  RealExpected := 0;
  Repeat
    x := x + 1;
    RealExpected := Gamma[x] * total + RealExpected;
    Expected := ROUND(RealExpected)
  Until   ( Expected >= NumPerInt )  OR  ( x = 100 );
  sub := sub + 1;
  Interval[sub] := x
UNTIL x = 100;
IntervalCount := sub;
Q := 0;    Interval[0] := 0;
FOR sub := 0 to IntervalCount-1 DO
  Begin
  N := Data[0];    RealExpected := 0;
  For x := Interval[sub]+1 to Interval[sub+1] Do N := N + Data[x];
  For x := Interval[sub]+1 to Interval[sub+1] Do
      Begin
      RealExpected := Gamma[x] * total + RealExpected;
      Expected := ROUND(RealExpected)
      End;
  IF Expected <> 0 THEN Q := Q + SQR(N-Expected) / Expected
  End;
IF Q <= MaxQ THEN
   Begin
   SuccessCount := SuccessCount + 1;
   Write(lst,'tot occur: ',total:2,'  expect occur/interval');
   Write(lst,': ',NumPerInt:1,'   Number Int ');
   Write(lst,'= ',IntervalCount:2);
   Write(lst,'    alpha = ',alpha:6:4);
   Write(lst,'    beta = ',beta:6:4,'    k = ',k:6:3,'    Q = ');
   Writeln(lst,Q:8:4,' (',IntervalCount-1:1,' DF''s)');
   End
End;   {CalculateQ}



PROCEDURE  MakeGammaFile;

Begin  {MakeGammaFile}
Write('Give the value of alpha:   ');   Readln(alpha);
Write('Give the value of beta :   ');   Readln(beta);
Write('Give the value of k    :   ');   Readln(k);   Writeln;
REPEAT
  Write('Is peak near   H igh  or  L ow   values?   ');
  Readln(ch);   ch := UpCase(ch)
UNTIL ch in ['H','L'];
CalculateGamma(ch);
Writeln;
Write('Give a file name (w. drive if necc.) to store this Gamma func.:   ');
Readln(FileName);
ASSIGN(GammaFile,FileName);
REWRITE(GammaFile);
FOR x := 1 to 100 DO Writeln(GammaFile,x:3,'  ',Gamma[x]:10:8);
CLOSE(GammaFile)
End;   {MakeGammaFile}



BEGIN   { M A I N    P R O G R A M }
FirstTime := TRUE;
REPEAT
  Writeln;
  Writeln('Your options are as follows:');
  Writeln;
  Writeln('1:  Try fitting a (truncated) Gamma p.d.f. to a data set.');
  Writeln('2:  Make a file with a specified Gamma p.d.f. (which, after');
  Writeln('    use of TRANSF.COM and PREPLOT.COM of DataPlotter, will');
  Writeln('    allow you to plot a Gamma p.d.f.).');
  Writeln('3:  Quit this program.');
  Writeln;
  Writeln;
  REPEAT
    Write('Select option ----->  ');  Readln(option);
  UNTIL option IN ['1','2','3'];
  IF option = '2' THEN  Begin  Writeln;  MakeGammaFile  End;
  IF option = '3' THEN  Begin  Writeln;  Writeln('Bye.');  Writeln  End;
  IF option = '1' THEN
     Begin
     Writeln;
     GetData;
     Writeln;
     GetParameters;
     Writeln;
     SuccessCount := 0;       RANDOMIZE;
     REPEAT   CalculateQ   UNTIL SuccessCount = NumSuccessfulQ;
     Writeln
     End
UNTIL option = '3'
END.    { M A I N    P R O G R A M }
