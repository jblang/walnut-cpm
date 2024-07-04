{PROGRAM AUTHOR: Mark Aldon Weiss   Donated to public domain}

{ Statistical Reference:  Probability and Statistics by Morris H. DeGroot }
{ pp. 440-441.                                                            }


CONST

MeanNumPerInterval: Byte = 5;
MaxNumSamples = 1005;
MaxNumIntervals = 204;



TYPE

NumPerInterval = Array[1..MaxNumIntervals] of Byte;
  Partitioning = Array[0..MaxNumIntervals] of Real;



VAR

     again: Boolean;
         Q: Real;
SampleSize: 1..MaxNumSamples;
    NumInt: 1..MaxNumIntervals;
     NumDF: Byte;
       i,j: Integer;
      rand: Real;
         N: NumPerInterval;
     range: Partitioning;
        ch: char;



BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln(' This program performs a chi-square test of the random number generator.');
Writeln(' The relevant statistic, Q, which has approximately a chi-square dis-');
Writeln(' tribution, is calculated.  The program does not have a chi-square table;');
Writeln(' only the value of Q is computed and therefore you will need a table to');
Writeln(' complete the test.  See Morris H. DeGroot  Probability and Statistics,');
Writeln(' pp. 440-441 (table on pp. 578-579).');
Writeln;
Writeln(lst,#27'C'#0#11#27'N'#4#27'G'#27'W'#1#15);
Writeln(lst,' Chi-Square Test of TURBO Pascal RNG'#27'W'#0#18);
Writeln(lst);  Writeln(lst);
again := TRUE;
WHILE again DO
  Begin
  Q := 0;
  Writeln(' It is best to take a large number of samples (up to ',MaxNumSamples,').');
  Writeln(' Please make your sample size a multiple of ',MeanNumPerInterval,'.');
  Write(' What do you choose for your sample size?    ');  Readln(SampleSize);
  Writeln;
  NumInt := SampleSize DIV MeanNumPerInterval;
  NumDF := NumInt - 1;
  FOR i := 0 to NumInt DO range[i] := i * (1/NumInt);
  FOR i := 1 to NumInt DO N[i] := 0;
  FOR i := 1 to SampleSize DO
    Begin
    rand := RANDOM;
    For j := 1 to NumInt Do
      IF NOT(rand > range[j]) AND NOT(rand < range[j-1]) THEN N[j] := N[j] + 1
    End;
  FOR i := 1 to NumInt DO  Q := Q + SQR( N[i] - MeanNumPerInterval );
  Q := Q/MeanNumPerInterval;
  Writeln(' The value of Q (',NumDF,' degrees of freedom) is ',Q:8:4);
  Writeln(lst,' The value of Q (',NumDF,' degrees of freedom) is ',Q:8:4);
  Writeln(lst); Writeln;
  Write(' Do you want to do this again?   ');  Readln(ch);  Writeln;
  IF ch IN ['y','Y'] THEN again := TRUE ELSE again := FALSE
  End
END.   { M A I N    P R O G R A M }
