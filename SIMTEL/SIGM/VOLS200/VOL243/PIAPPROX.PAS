{PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN}

CONST

pi : Real = 3.141592654;   MaxNumShots = 5001;   MaxNumRuns = 501;



TYPE

Shots  = 1..MaxNumShots;
Trials = 1..MaxNumRuns ;



VAR

s: Shots;   t: Trials;   i: Integer;   x,y: Real;

NumShots,SplashCount: Shots;   NumRuns: Trials;   StDev: Real;

PiApprox: Array[ Trials ] of Real;   PiAvg: Real;   again: Boolean;   ch: Char;



BEGIN   { M A I N    P R O G R A M }
Writeln;
Writeln('This program computes an approximation to pi.  The method and');
Writeln('terminology follow that in Scientific American, April 1985, p. 20.');
Writeln;
REPEAT
  Writeln;
  Writeln('Turn the printer OFF.  Set a page to about three lines below the');
  Writeln('top.  NOW, turn the printer back on.');
  Writeln;
  Write('Did you do as instructed?   ');  Readln(ch)
UNTIL ch IN ['y','Y'];
Write(lst,#27'C'#0'11',#27'G',#27'E',#27'0');
Writeln(lst,#27'N'#8,'            Pi Approximation (TURBO Pascal)',#27'F');
Writeln(lst);  Writeln;
Writeln(lst);  Writeln;
Writeln(lst);
again := TRUE;
WHILE again DO
   Begin
   Write('How many shots do you want (maximum of ',MaxNumShots-1:4);
   Write(') per trial?   ');   Readln(NumShots);
   Write('How many trials do you want (maximum of ',MaxNumRuns-1:3);
   Write(' trials)?      ');   Readln(NumRuns );
   FOR t := 1 to NumRuns DO PiApprox[t] := 0;
   FOR t := 1 to NumRuns DO
       Begin
       SplashCount := 0;
       FOR s := 1 to NumShots DO
           Begin
           x := RANDOM;   y := RANDOM;
           IF SQRT( SQR(x) + SQR(y) ) <= 1 THEN SplashCount := SplashCount + 1
           End;
       PiApprox[t] := SplashCount/NumShots * 4
       End;
   PiAvg := 0;   StDev := 0;
   FOR t := 1 to NumRuns DO
       Begin
       PiAvg := PiAvg + PiApprox[t];
       Write(lst,' run',t:4,'    ',NumShots:4,' shots    Pi approx =');
       Writeln(lst,PiApprox[t]:12:9,'    avg. so far =',PiAvg/t:12:9)
       End;
   Writeln(lst);    PiAvg := PiAvg/NumRuns;
   FOR t := 1 to NumRuns DO StDev := StDev + SQR( PiApprox[t] - PiAvg );
   StDev := SQRT( StDev ) / (NumRuns-1);
   Write(lst,' Over these',t:4,' runs, the standard deviation is ');
   Writeln(lst,StDev:12:9);   Writeln(lst);
   Writeln(lst,' The true value of pi is',pi:12:9);   Writeln(lst);
   Writeln(lst);   Writeln(lst);   Writeln;   Writeln;
   Write('Do you want to do this again?   ');   Readln(ch);
   IF ch IN ['y','Y'] THEN again := TRUE ELSE again := FALSE
   End
END.    { M A I N    P R O G R A M }





