{AUTHOR: Mark Aldon Weiss    donated to public domain}

CONST

MaxNumPts  =  2000;

MaxNumRuns =    500;



VAR

X,Y,Distance: Array[1..MaxNumPts] of Real;

NearestNeighbor: Array[1..MaxNumPts] of Integer;

Probability: Array[1..MaxNumRuns] of Real;

i,j,NumPts: 1..MaxNumPts;  NumRuns,Run:1..MaxNumRuns;

NumCommuting: 1..MaxNumPts;

ch: char;

Smallest,StDev,Avg: Real;



BEGIN  { M A I N    P R O G R A M }

Writeln;
Writeln('This program is a Monte Carlo computation of the following problem.');
Writeln('Given random points in the plane, what is the probability that a');
Writeln('point''s nearest neighbor has as IT''s nearest neighbor, the first');
Writeln('point?'#7);
Writeln;
Writeln('TURN THE PRINTER ON before we continue.');
Writeln;
REPEAT
 Write('Did you turn the printer on?   ');  Readln(ch);  Writeln;
 IF NOT( ch IN ['y','Y'] ) THEN Writeln('Well go turn it on'#7#7#7)
UNTIL ch IN ['y','Y'];
Writeln(lst);
Writeln(lst,#27'E RESULTS of NEAREST NEIGHBOR TEST on TURBO PASCAL RNG');
Writeln(lst,#27'F');
Write('Good, now how many points per run do you want (',MaxNumPts:5,' max)? ');
Readln(NumPts);  Writeln;
Write('How many runs do you want (',MaxNumRuns:3,' max)?    ');
Readln(NumRuns);  Writeln;
Writeln(lst,#27'G EACH RUN HAS ',NumPts:3,' POINTS'#27'H');  Writeln(lst);
FOR  Run := 1  to  NumRuns  DO
     Begin
     for i := 1 to NumPts do  begin  X[i] := RANDOM;  Y[i] := RANDOM  end;
     NumCommuting := 0;
     FOR i := 1 to NumPts DO
         Begin
         FOR j := 1 to NumPts DO
         Distance[j] := SQR( X[i] - X[j] ) + SQR( Y[i] - Y[j]);
         { whether its the square of the distance or not does't matter }
         { why have the computer take the sqaure root when it's not needed }
         Distance[i] := 20;  {any number > 1 so dist. pt. to self not smallest}
         Smallest := Distance[1];  NearestNeighbor[i] := 1;
         FOR j := 2 to Numpts DO
             IF Distance[j] < Smallest THEN
                begin  Smallest := Distance[j];  NearestNeighbor[i] := j  end
         End;
     FOR i := 1 to NumPts DO
         IF  NearestNeighbor[ NearestNeighbor[i] ] = i  THEN
             NumCommuting := NumCommuting + 1;
     Probability[Run] := NumCommuting/NumPts;
     Writeln;
     Writeln(lst);
     Writeln('Run',Run:4,' There were ',NumCommuting:4,' commuting points out of');
     Writeln(Numpts:5,' the probability was therfore ',Probability[Run]:7:5);
     Writeln(lst,'Run',Run:4,' probability = ',Probability[Run]:11:8);
     Writeln(lst);
     Writeln;
     Avg := 0;  StDev := 0;
     for i := 1 to Run do Avg := Avg + Probability[i];
     Avg := Avg/Run;
     for i := 1 to Run do StDev := StDev + SQR( Probability[i] - Avg );
     if Run <> 1 then StDev := SQRT( StDev/(Run-1) ) else StDev := 0;
     Writeln('The average so far is     ',Avg:7:5);
     Writeln('The standard deviation is ',StDev:7:5);
     Writeln(lst,'The average so far is     ',Avg:11:8);
     Writeln(lst,'The standard deviation is ',StDev:11:8)
     End;
Writeln;  Writeln;
Writeln('The nearest neighbor problem may be solved analytically.');
Writeln('The result is  6pi / ( 8pi + 3 SQRT(3) ) = 0.621505')

END.   { M A I N    P R O G R A M }