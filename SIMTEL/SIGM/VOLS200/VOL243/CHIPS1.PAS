{ PROGRAM AUTHOR: Mark Aldon Weiss   PROGRAM DONATED TO PUBLIC DOMAIN }
{ This file should not be compiled; instead, compile CHIPS2.Pas which }
{ uses this file (Chips1.pas) as an include file.                     }

CONST

allotment        = 300;
LowerSuggestion  =   5;
UpperSuggestion  = 150;
list1size        =  15;
list2size        =   4;
list3size        =   3;
PriceChip        =   3;
MinBalance       =  10;

AlphaTravelCost  =  10;

ScoreForNewChip  =   5;
ScoreForOldChip  =   1;
ScoreForComplete = 100;

Arrival1Score    =  20;
Arrival2Score    =  10;
Arrival3Score    =   5;
NthArrivalScore  =   2;

BetaArrivalScore =  15;
GamaArrivalScore =  35;

WarnPenaltyMult  =   2;
Bal2AwardMult    =   6;
MoneyToPointCon  =   4;

IniRankIncFrac   = 2.1;
SubRankIncFrac   = 2.6;




TYPE

Flag1Array = Array[1..List1Size] of Boolean;  Count1Array = Array[1..List1Size] of Byte;
Flag2Array = Array[1..List2Size] of Boolean;  Count2Array = Array[1..List2Size] of Byte;
Flag3Array = Array[1..List3Size] of Boolean;  Count3Array = Array[1..List3Size] of Byte;




VAR

i,score,TripMoney,MoneyLeft,balance1,balance2: Integer;

NumRequested,NewNumRequested,WarnCount,AlphaCount,WholeTripCount: Integer;

NumAlphaGot,OldNumAlphaGot,rank: Integer;

ReadRules,quit,again: Char;

OKamount,CompleteSet,GoingHome: Boolean;

f: Flag1Array;  g: Flag2Array;  h: Flag3Array;

fcount: Count1Array;  gcount: Count2Array;  hcount: Count3Array;

FileName: String[12];  ChipsLog: Text;




PROCEDURE  RULES(rank: integer);

Begin  {RULES}
Writeln;
Writeln('The scoring and other rules are given below; you will be given your score');
Writeln('only after the completion of a trip.  ');
Writeln;
Writeln('For each new chip you will get ',ScoreForNewChip,' points.');
Write('For each old chip you will get ',ScoreForOldChip);
IF ScoreForOldChip = 1 THEN Writeln(' point.') ELSE Writeln('points.');
Writeln;
Writeln('For arriving at Alpha you will get the following number of points:');
Writeln;
Write('1st time ---> ',Arrival1Score,'   2nd time ---> ',Arrival2Score,'   3rd time ---> ',Arrival3Score);
Writeln('   subsequent times ---> ',NthArrivalScore);
Writeln;
Writeln('For arriving at Beta you will get  ',BetaArrivalScore,' points each time.');
Writeln;
Writeln('For arriving at Gamma you will get ',GamaArrivalScore,' points each time.');
Writeln;
Writeln('If you obtain a complete set of Alpha chips you will be told so and also be');
Writeln('awarded a bonus of ',ScoreForComplete,' points.');
Writeln;
Write('There are more rules; when you''re ready to read them, hit return.  ',#7);
Readln(ReadRules);
Writeln;
Writeln('You may end your trip and go home.  To do this, answer zero (type 0) when');
Writeln('asked for how many chips you want.  You will then be asked if you want to');
Writeln('go home.  Any money you have left will be converted to points at the rate');
Writeln('of ',MoneyToPointCon,' dollars per point.');
Writeln;
Writeln('I M P O R T A N T :    If you request too many chips you will be warned about');
Writeln('it.  "too many" does not neccessarily mean that you don''t have the money');
Writeln('that it would cost to buy the chips.  "too many" just means that you would');
Writeln('be left with less money than a certain minimum amount if permitted to pur-');
Writeln('chase the number of chips you requested.  RECEIVING A WARNING SUBTRACTS');
Writeln('POINTS FROM YOUR SCORE ACCORDING TO THE FORMULA:  (n-1) x ',WarnPenaltyMult);
Writeln('where n is the number of warnings you''ve gotten during the current trip.');
Writeln(#7);
Write('Good Luck ');
CASE rank OF
            0: Writeln('Space Cadet!');
            1: Writeln('Space Captain!');
            2: Writeln('Space Avenger!')
End;  {of CASE}
Writeln;  Writeln
End;   {RULES}



PROCEDURE  INITIALIZE;

Begin  {INITIALIZE}
      OKamount := FALSE;
     GoingHome := FALSE;
   CompleteSet := FALSE;
     WarnCount := 0;
    AlphaCount := 0;
         score := 0;
   NumAlphaGot := 0;
FOR i := 1 TO List1Size DO  Begin   f[i] := FALSE;  fcount[i] := 0   End;
FOR i := 1 TO List2Size DO  Begin   g[i] := FALSE;  gcount[i] := 0   End;
FOR i := 1 TO List3Size DO  Begin   h[i] := FALSE;  hcount[i] := 0   End
End;   {INITIALIZE}




PROCEDURE  LIST1(WhichOne: integer);

Begin  {LIST1}
IF f[WhichOne] THEN score := score + ScoreForOldChip ELSE score := score + ScoreForNewChip;
f[WhichOne] := TRUE;
fcount[WhichOne] := fcount[WhichOne] + 1;
CASE  fcount[WhichOne]  OF
                          1: Writeln('You have obtained chip Alpha-',WhichOne,'.');
                          2: Writeln('You now have a second  Alpha-',WhichOne,' chip.');
                          3: Writeln('This gives you a third Alpha-',WhichOne,' chip.');
                       ELSE  Writeln('You now have ',fcount[WhichOne],' Alpha-',WhichOne,' chips.');
                       End;  {of CASE}
CASE  fcount[WhichOne]  OF
                          1: Writeln(ChipsLog,'You have obtained chip Alpha-',WhichOne,'.');
                          2: Writeln(ChipsLog,'You now have a second  Alpha-',WhichOne,' chip.');
                          3: Writeln(ChipsLog,'This gives you a third Alpha-',WhichOne,' chip.');
                       ELSE  Writeln(ChipsLog,'You now have ',fcount[WhichOne],' Alpha-',WhichOne,' chips.');
                       End;  {of CASE}
End;   {LIST1}




PROCEDURE  LIST2(WhichOne: integer);

Begin  {LIST2}
IF g[WhichOne] THEN score := score + ScoreForOldChip ELSE score := score + ScoreForNewChip;
g[WhichOne] := TRUE;
gcount[WhichOne] := gcount[WhichOne] + 1;
CASE  gcount[WhichOne]  OF
                          1: Writeln('You have obtained chip Beta-',WhichOne,'.');
                          2: Writeln('You now have a second  Beta-',WhichOne,' chip.');
                          3: Writeln('This gives you a third Beta-',WhichOne,' chip.');
                       ELSE  Writeln('You now have ',gcount[WhichOne],' Beta-',WhichOne,' chips.');
                       End;  {of CASE}
CASE  gcount[WhichOne]  OF
                          1: Writeln(ChipsLog,'You have obtained chip Beta-',WhichOne,'.');
                          2: Writeln(ChipsLog,'You now have a second  Beta-',WhichOne,' chip.');
                          3: Writeln(ChipsLog,'This gives you a third Beta-',WhichOne,' chip.');
                       ELSE  Writeln(ChipsLog,'You now have ',gcount[WhichOne],' Beta-',WhichOne,' chips.');
                       End;  {of CASE}
End;   {LIST2}




PROCEDURE  LIST3(WhichOne: integer);

Begin  {LIST3}
IF h[WhichOne] THEN score := score + ScoreForOldChip ELSE score := score + ScoreForNewChip;
h[WhichOne] := TRUE;
hcount[WhichOne] := hcount[WhichOne] + 1;
CASE  hcount[WhichOne]  OF
                          1: Writeln('You have obtained chip Gamma-',WhichOne,'.');
                          2: Writeln('You now have a second  Gamma-',WhichOne,' chip.');
                          3: Writeln('This gives you a third Gamma-',WhichOne,' chip.');
                       ELSE  Writeln('You now have ',hcount[WhichOne],' Gamma-',WhichOne,' chips.');
                       End;  {of CASE}
CASE  hcount[WhichOne]  OF
                          1: Writeln(ChipsLog,'You have obtained chip Gamma-',WhichOne,'.');
                          2: Writeln(ChipsLog,'You now have a second  Gamma-',WhichOne,' chip.');
                          3: Writeln(ChipsLog,'This gives you a third Gamma-',WhichOne,' chip.');
                       ELSE  Writeln(ChipsLog,'You now have ',hcount[WhichOne],' Gamma-',WhichOne,' chips.');
                       End;  {of CASE}
End;   {LIST3}




FUNCTION  ProbComplete(NumInCollection,NumTook: integer): REAL;

Var

k,SumIndex,sign,bigger,smaller: Integer;

ratio,CombCoeff,PowerFactor,PartProb: Real;

Begin  {ProbComplete}
PartProb := 0;
IF NumTook <  NumInCollection THEN ProbComplete := 0;
IF NumTook >= NumInCollection THEN
   Begin
   FOR SumIndex := 1 TO (NumInCollection-1) DO
       Begin
       If (SumIndex MOD 2 = 0) Then sign := -1 Else sign := 1;
       If ( SumIndex < (NumInCollection - SumIndex) ) THEN
          begin
          smaller := SumIndex;   bigger := NumInCollection - SumIndex
          end
       Else
          begin
          smaller := NumInCollection - SumIndex;   bigger := SumIndex
          end;
       IF  bigger = NumInCollection THEN CombCoeff := 1;
       IF bigger <> NumInCollection THEN
          Begin
          CombCoeff := 1;
          For k := 1 to smaller Do CombCoeff := CombCoeff * ( (NumInCollection - k + 1) / k )   {See Numerical Math Book}
          End;
       ratio := (NumInCollection - SumIndex) / NumInCollection;
       PowerFactor := ratio;
       For i := 1 To ( NumTook - 1 ) Do  PowerFactor := PowerFactor * ratio;
       PartProb := PartProb + ( sign * CombCoeff * PowerFactor)
       End;
       ProbComplete := 1 - PartProb
   End
End;   {ProbComplete}
