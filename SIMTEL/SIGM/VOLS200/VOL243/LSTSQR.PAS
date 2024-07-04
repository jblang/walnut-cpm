{ PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN }

CONST

MaxNumPts = 55;



VAR

x,y: Array [1..MaxNumPts] of Real;   i,numpts: 1..MaxNumPts;

understood, another, StillErrors: Boolean;    ch: Char;

xavg,yavg,varx,vary,covar,sumxy,sumxsqr,slope,int,sigma,devslope,devint: Real;


BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln(' This program performs a linear least squares fit.  All input and');
Writeln(' output is to the terminal.  You need not turn on the printer.  You');
Writeln(' should keep paper and pencil handy to jot down the results.');
Writeln(' You are allowed a maximum of ',MaxNumPts:3,' points per data set.  You');
Writeln(' need change only one line in the source code to accomodate more.');
Writeln;
understood := TRUE;
REPEAT
  Writeln(' YOU SHOULD ENTER YOUR DATA IN THE FOLLOWING WAY:');
  Writeln(' 1.  Type your first x value; type one or more spaces; type your y');
  Writeln('          value that goes with this x.  Hit return.');
  Writeln(' 2.  Repeat this procedure for all your (x,y) pairs EXCEPT FOR THE');
  Writeln('          LAST (x,y) pair.  FOR THE LAST PAIR, see 3. below.');
  Writeln(' 3.  For your last (x,y) pair, type the x; type one or more spaces;');
  Writeln('          type the y; type a * with ONE space between the y value');
  Writeln('          and the *.  Hit return.');
  Writeln(#7);
  Write(' Did you read these instructions carefully?     ');  Readln(ch);
  Writeln;
  IF ch IN ['y','Y'] THEN understood := TRUE ELSE understood := FALSE
UNTIL understood;
Writeln;
Writeln(' Okay, ENTER YOUR DATA AS INSTRUCTED ABOVE [you will be given a');
Writeln(' chance to correct errors after complete entry of all your data]:');
REPEAT
  Writeln;  Writeln(' ENTER DATA NOW . . .');
  Writeln;
  i := 0;
  REPEAT
    i := i + 1;
    Readln( x[i], y[i], ch);
  UNTIL ch = '*';
  numpts := i;
  Writeln;
  Writeln(' These are your data as received:');
  Writeln;
  FOR i := 1 to numpts DO Writeln(i:3,'.)    x = ',x[i],'   y = ',y[i]);
  Writeln;
  Write(' Are there any errors?   ');  Readln(ch);   Writeln;
  IF ch IN ['y','Y'] THEN
     Begin
       Writeln(' Begin by correcting your first error.');  Writeln;
       StillErrors := TRUE;
       WHILE StillErrors DO
          Begin
          Writeln(' Type the following (where the <> mean to strike a key:');
          Write(' data point number  <space>  x  <space>  y  <return>  --->  ');
          Readln(i,x[i],y[i]);
          Writeln;
          Write(' Any more errors?   ');  Readln(ch);
          IF ch IN ['y','Y'] THEN StillErrors := TRUE ELSE StillErrors := FALSE;
          Writeln
          End
     End;
  xavg := 0;  yavg := 0;  sumxy := 0;  varx := 0;  vary := 0;  covar := 0;
  sumxsqr := 0;
  FOR  i := 1 to numpts DO
     Begin
     xavg := xavg + x[i];
     yavg := yavg + y[i];
     sumxy := sumxy +  x[i] * y[i];
     sumxsqr := sumxsqr + SQR( x[i] )
     End;
  xavg := xavg / numpts;    yavg := yavg / numpts;
  FOR  i := 1 to numpts DO
     Begin
     varx := varx + SQR( x[i] - xavg );
     vary := vary + SQR( y[i] - yavg )
     End;
  varx := varx / numpts;    vary := vary / numpts;
  covar := sumxy / numpts - ( xavg * yavg );
  slope := covar / varx;
  int := yavg - slope * xavg;
  sigma := SQRT( numpts/(numpts-2) * (varx*vary - SQR(covar)) / varx );
  devslope := sigma / SQRT( numpts * varx );
  devint := sigma * SQRT( sumxsqr / ( SQR(numpts) * varx ) );
  Writeln;
  Writeln('          slope = ',   slope,'            intercept = ',   int);
  Writeln(' st. dev. slope = ',devslope,'   st. dev. intercept = ',devint);
  Writeln;
  Write(' the correlation coefficient is');
  Writeln( covar / SQRT(varx * vary) );    Writeln;
  Write(' Do you have another data set for analysis?   ');  Readln(ch);
  IF ch IN ['y','Y'] THEN another := TRUE ELSE another := FALSE
UNTIL NOT ANOTHER
END.   { M A I N    P R O G R A M }






