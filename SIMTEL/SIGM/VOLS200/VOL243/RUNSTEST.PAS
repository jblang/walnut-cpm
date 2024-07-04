{author: Mark Aldon Weiss   donated to public domain}

{ STATISTICAL REF.:  Mendenhall, "Introduction to Probability and Statistics" }
{ 3rd. ed., 382-388.                                                          }

CONST

MaxNumSamples = 200;



TYPE

BinarySequence = Array[1..MaxNumSamples] of 0..1;
RunsType = 0..MaxNumSamples;



VAR

test,WhichTail: Char;

HiLo: BinarySequence;

SampleSize,SizeMinusOne,NumRequested,NumRuns,MaxNumRuns: RunsType;

n0,n1,r0,r1,n01,n11,hn0,hn1,dn0,dn1,hn01,hn11,dn01,dn11: RunsType;

hr0,hr1,dr0,dr1: RunsType;

Hnumruns,Dnumruns,HmaxNumRuns,DmaxNumRuns: RunsType;

RanArray: Array[1..MaxNumSamples] of Real;

i: RunsType;



PROCEDURE  GenerateRanArray;

Begin
For i := 1 to SampleSize Do RanArray[i] := RANDOM
End;



PROCEDURE  GenerateHiLo( mode: char);

Begin
IF mode = 'H' THEN FOR i := 1 to SampleSize DO
                       If RanArray[i] < 0.5 Then HiLo[i] := 0 Else HiLo[i] := 1
ELSE FOR i := 1 to SizeMinusOne DO
             If RanArray[i+1] > RanArray[i] Then HiLo[i] := 1 Else HiLo[i] := 0
End;



PROCEDURE  CollectInfo( mode: char);

Var   c0,c1: RunsType;

      Procedure  Count0;
      Begin  {Count0}
      Repeat  c0 := c0 +1;  If HiLo[c0] = 0 Then n0 := n0 + 1
      Until (HiLo[c0] = 1) Or (c0 = SampleSize);
      r0 := r0 + 1;   c0 := c0 - 1;
      If c0 <> SizeMinusOne Then
         begin
         Repeat  c0 := c0 + 1  Until (HiLo[c0] = 0) Or (c0 = SampleSize);
         r1 := r1 + 1;
         c0 := c0 - 1
         end
      End;   {Count0}

      Procedure  Count1;
      Begin  {Count1}
      Repeat  c1 := c1 +1;  If HiLo[c1] = 1 Then n1 := n1 + 1
      Until (HiLo[c1] = 0) Or (c1 = SampleSize);
      r1 := r1 + 1;   c1 := c1 - 1;
      If c1 <> SizeMinusOne Then
         begin
         Repeat  c1 := c1 + 1  Until (HiLo[c1] = 1) Or (c1 = SampleSize);
         r0 := r0 + 1;
         c1 := c1 - 1
         end
      End;   {Count1}

Begin  {CollectInfo}
c0 := 0;  c1 := 0;  n0 := 0;  n1 := 0;  r0 := 0;  r1 := 0;
IF HiLo[1] = 0 THEN
   Begin
   REPEAT Count0 UNTIL c0 = SizeMinusOne;
   n1 := SampleSize - n0
   End;
IF HiLo[1] = 1 THEN
   Begin
   REPEAT Count1 UNTIL c1 = SizeMinusOne;
   n0 := SampleSize - n1
   End;
{ At this point the values of the global variables n0, n1, r0, r1 are known. }
NumRuns := r0 + r1;
{ The following is a correction for the premature termination of the calling }
{ of the Count subprocedures.  It's difficult to describe--just note that,   }
{ e.g., 0110 has three total runs.  The last 0 constitutes a run.            }
IF HiLo[SampleSize] <> HiLo[SizeMinusOne] THEN
   Begin
   NumRuns := NumRuns + 1;
   IF HiLo[SampleSize] = 0 THEN r0 := r0 + 1 ELSE r1 := r1 + 1
   End;
n01 := n0 - 1;   n11 := n1 - 1;
IF n0 = n1 THEN MaxNumRuns := 2 * n0;
IF n0 < n1 THEN MaxNumRuns := 2 * n0 + 1;
IF n0 > n1 THEN MaxNumRuns := 2 * n1 + 1;
IF mode = 'H' THEN
   Begin
   hn0 := n0;  hn1 := n1;  hn01 := n01;  hn11 := n11;  hr0 := r0;  hr1 := r1;
   Hnumruns := NumRuns;   HmaxNumRuns := MaxNumRuns
   End
ELSE
   Begin
   dn0 := n0;  dn1 := n1;  dn01 := n01;  dn11 := n11;  dr0 := r0;  dr1 := r1;
   Dnumruns := NumRuns;   DmaxNumRuns := MaxNumRuns
   End
End;   {CollectInfo}



FUNCTION  COMB( total,choose: RunsType): Real;

{ This function calculates the combinatorial coefficient =                    }
{ total! / [ choose! x (total-choose)! ]  which may be verified to be         }
{ equivalent to the form of the coefficient as employed in the ForLoop below. }

Var   k,min: RunsType;   save,TotalPlusOne: Real;

Begin  {COMB}
save := 1;   TotalPlusOne := total + 1;
IF choose <= total-choose THEN min := choose ELSE min := total - choose;
FOR k := 1 to min DO save := save * (TotalPlusOne - k)/k;
COMB := save
End;   {COMB}



FUNCTION  ProbRuns( mode:char;  RunsValue:RunsType): Real;

{ The function gives a product of appropriate combinatorial coefficients, and }
{ will be a probability only after multiplication by an appropriate constant  }
{ which will occur in the function ProbLess (below).                          }

Var   pr: RunsType;

Begin  {ProbRuns}
pr := RunsValue DIV 2;
IF mode IN ['h','H'] THEN
  IF RunsValue MOD 2 = 0 THEN
     ProbRuns := 2 * COMB(hn01,pr-1) * COMB(hn11,pr-1)
  ELSE
     ProbRuns := COMB(hn01,pr-1)*COMB(hn11,pr) + COMB(hn01,pr)*COMB(hn11,pr-1);
IF mode IN ['d','D'] THEN
  IF RunsValue MOD 2 = 0 THEN
     ProbRuns := 2 * COMB(dn01,pr-1) * COMB(dn11,pr-1)
  ELSE
     ProbRuns := COMB(dn01,pr-1)*COMB(dn11,pr) + COMB(dn01,pr)*COMB(dn11,pr-1)
End;   {ProbRuns}



FUNCTION  ProbLess( mode:char;  LessThan:RunsType): Real;

Var   pl: RunsType;   SaveLess: Real;

Begin  {ProbLess}
IF mode IN ['h','H'] THEN
   IF LessThan < HmaxNumRuns THEN
      Begin
      SaveLess := 0;
      FOR pl := 2 to LessThan DO SaveLess := SaveLess + ProbRuns(mode,pl);
      SaveLess := SaveLess / COMB(SampleSize,hn0);
      ProbLess := SaveLess
      End
   ELSE
      ProbLess := 1;
IF mode IN ['d','D'] THEN
   IF LessThan < DmaxNumRuns THEN
      Begin
      SaveLess := 0;
      FOR pl := 2 to LessThan DO SaveLess := SaveLess + ProbRuns(mode,pl);
      SaveLess := SaveLess / COMB(SampleSize,dn0);
      ProbLess := SaveLess
      End
   ELSE
      ProbLess := 1
End;   {ProbLess}



FUNCTION  ProbGreater( mode:char; GreaterThan:RunsType): Real;

Begin
ProbGreater := 1 - Probless(mode,GreaterThan-1)
End;



BEGIN   { M A I N    P R O G R A M }
Writeln;
Writeln(#7' TURN ON THE PRINTER.');
Writeln;
Writeln(lst,#27'G'#27'0'#27'U'#1#27'C'#0#11#27'N'#4);
Writeln(lst,#15#14' Runs Testing of TURBO Pascal RNG:'#18);
Writeln(lst);
Writeln(' This program performs two different runs tests on the RNG.  The');
Writeln(' first is  >1/2 \ <1/2.  The second is on signs of successive dif-');
Writeln(' ferences.  A reference for these tests is Mendenhall, "An Intro-');
Writeln(' duction to Probability and Statistics, 3rd ed.", pp. 382 - 388.');
Writeln;
Write(' How many samples of the RNG (max of ',MaxNumSamples,') (0 to quit)?  ');
Readln(SampleSize);  Writeln;  Writeln;
IF SampleSize <> 0 THEN
   Begin
   Writeln(' Later, you will be asked to type one of the following:');
   Writeln(' HL# -- >1/2 \ <1/2 test; probability of less than # runs');
   Writeln(' HG# -- >1/2 \ <1/2 test; probability of greater than # runs');
   Writeln(' DL# -- signs succ. diff.''s test; prob. less than # runs');
   Writeln(' DG# -- signs succ. diff.''s test; prob. greater than # runs');
   Writeln(' QQ# -- type this to quit this sampling');
   Writeln;
   Writeln(' NOTE: Upper or lower case letters are OK; any # is OK for QQ#');
   Writeln;
   Writeln(' REMEMBER THESE INSTRUCTIONS; THIS IS THE YOU WILL SEE THEM!');
   Writeln
   End;
WHILE SampleSize > 0 DO
  Begin
  SizeMinusOne := SampleSize - 1;
  GenerateRanArray;
  GenerateHiLo('H');  CollectInfo('H');
  GenerateHiLo('D');  CollectInfo('D');
  Writeln;
  Writeln(' # <1/2 = ',hn0:3,' ':23,'|',' ':4,'# diff<0 = ',dn0:3);
  Writeln(' # >1/2 = ',hn1:3,' ':23,'|',' ':4,'# diff>0 = ',dn1:3);
  Writeln('|':37);
  Writeln(' # runs of <1/2 = ',hr0:3,'|':16,' ':4,'# runs of diff<0 = ',dr0:3);
  Writeln(' # runs of >1/2 = ',hr1:3,'|':16,' ':4,'# runs of diff>0 = ',dr1:3);
  Writeln('|':37);
  Write(' TOTAL # RUNS --------------> ',Hnumruns:3,'|':4,' ':4);
  Writeln('TOTAL # RUNS ---------------> ',Dnumruns:3);
  Write(' MAXIMUM # RUNS POSSIBLE ---> ',HmaxNumRuns:3,'|':4,' ':4);
  Writeln('MAXIMUM # RUNS POSSIBLE ----> ',DmaxNumRuns:3);
  Writeln(lst);   Writeln(lst);
  Writeln(lst,' # <1/2 = ',hn0:3,' ':23,'|',' ':4,'# diff<0 = ',dn0:3);
  Writeln(lst,' # >1/2 = ',hn1:3,' ':23,'|',' ':4,'# diff>0 = ',dn1:3);
  Writeln(lst,'|':37);
  Writeln(lst,' # runs of <1/2 = ',hr0:3,'|':16,' ':4,'# runs of diff<0 = ',dr0:3);
  Writeln(lst,' # runs of >1/2 = ',hr1:3,'|':16,' ':4,'# runs of diff>0 = ',dr1:3);
  Writeln(lst,'|':37);
  Write(lst,#27'H'#27'E',' TOTAL # RUNS --------------> ',Hnumruns:3,#27'F'#27'G','|':4,' ':4);
  Writeln(lst,#27'E'#27'H','TOTAL # RUNS ---------------> ',Dnumruns:3);
  Write(lst,' MAXIMUM # RUNS POSSIBLE ---> ',HmaxNumRuns:3,#27'G'#27'F','|':4,' ':4);
  Writeln(lst,#27'H'#27'E','MAXIMUM # RUNS POSSIBLE ----> ',DmaxNumRuns:3,#27'G'#27'F');
  Writeln(lst);
  REPEAT
    Writeln;
    Write(' Type:  HL#  HG#  DL#  DG#  or  QQ#  ----->   ');
    Readln(test,WhichTail,NumRequested);   Writeln;
    IF test IN ['h','H'] THEN
       Begin
       IF WhichTail IN ['l','L'] THEN
        Begin
        Write(' Prob. ',NumRequested:3,' or fewer runs ( <1/2 \ >1/2 ) = ');
        Writeln(ProbLess(test,NumRequested):10:7);
        Write(lst,' Prob. ',NumRequested:3,' or fewer runs ( <1/2 \ >1/2 ) = ');
        Writeln(lst,ProbLess(test,NumRequested):10:7)
        End;
       IF WhichTail IN ['g','G'] THEN
        Begin
        Write(' Prob. ',NumRequested:3,' or more runs ( <1/2 \ >1/2 ) = ');
        Writeln(ProbGreater(test,NumRequested):10:7);
        Write(lst,' Prob. ',NumRequested:3,' or more runs ( <1/2 \ >1/2 ) = ');
        Writeln(lst,ProbGreater(test,NumRequested):10:7)
        End
       End;
    IF test IN ['d','D'] THEN
       Begin
       IF WhichTail IN ['l','L'] THEN
        Begin
        Write(' Prob. ',NumRequested:3,' or fewer runs (diff<0 / diff>0) = ');
        Writeln(ProbLess(test,NumRequested):10:7);
        Write(lst,' Prob. ',NumRequested:3,' or fewer runs (diff<0 / diff>0) = ');
        Writeln(lst,ProbLess(test,NumRequested):10:7)
        End;
       IF WhichTail IN ['g','G'] THEN
        Begin
        Write(' Prob. ',NumRequested:3,' or more runs (diff<0 / diff>0) = ');
        Writeln(ProbGreater(test,NumRequested):10:7);
        Write(lst,' Prob. ',NumRequested:3,' or more runs (diff<0 / diff>0) = ');
        Writeln(lst,ProbGreater(test,NumRequested):10:7)
        End
       End;
    IF test in ['q','Q'] THEN
       Begin
       Writeln;
       Write(' How many samples of the RNG (max of ',MaxNumSamples,') (0 to quit)?  ');
       Readln(SampleSize);  Writeln
       End
  UNTIL test IN ['q','Q']
End
END.   { M A I N    P R O G R A M }
