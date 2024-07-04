{ PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN }
{ This file should be compiled; below is a compiler directive to use }
{ the include file, CHIPS1.Pas.                                      }

{$I CHIPS1.PAS}



BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln('This program is a game called "CHIPS."  The main idea is to do some detective');
Writeln('work in order to discover the restrictions and algortihms of the game.  Most');
Writeln('important of all is to EXPERIMENT--purposely trying all sorts of things.');
Writeln;   Writeln;
Writeln('* * * *  KEEP PAPER AND PENCIL HANDY  * * * * *');
Writeln;
Writeln('* * * *  EXPERIMENT AND NOTE RESULTS  * * * * *');
Writeln;
Writeln('* * * *  KEEP TRACK OF YOUR BALANCE   * * * * *');
Writeln;   Writeln;
Writeln('YOUR MISSION:  Collect all the computer chips you can--preferably different');
Writeln('               ones.  Try to get a complete set of Alpha chips.  Your score');
Writeln('               indicates the degree of success of your mission.');
Writeln;
Writeln('HINTS:  Try to EXPERIMENT to find out answers to such questions as:');
Writeln('        1.)  How many alpha chips are there?');
Writeln('        2.)  How much money can I take to start with?');
Writeln('        3.)  What is the minimum balance I must have after purchasing chips?');
Writeln('        & many others.');
Writeln;
again := 'y';     rank := 0;    OldNumAlphaGot := 0;    WholeTripCount :=0;
WHILE again IN ['y','Y'] DO
  Begin
  INITIALIZE;
  WholeTripCount := WholeTripCount + 1;
  Write(#7,'Please give a name for a file to record this trip--->  ');
  Readln(FileName);
  ASSIGN(ChipsLog,FileName);
  REWRITE(ChipsLog);
  Writeln;
  Writeln('You may print or display this file on the terminal after exiting this program.');
  Writeln;
  Writeln;
  Write(#7,'Do you want to see the rules?   ');
  Readln(ReadRules);
  IF ReadRules IN ['y','Y'] THEN RULES(rank) ELSE
     Begin
     Writeln;
     Write('OK, Good luck ');
     CASE rank OF
                 0: Writeln('Space Cadet!');
                 1: Writeln('Space Captain!');
              ELSE  Writeln('Space Avenger!');
     End;  {of CASE}
     Writeln;
     End;
  REPEAT
     Writeln('How much money are you going to take with you (between ',LowerSuggestion);
     Write('& ',UpperSuggestion,' is suggested)?     ');
     Readln(TripMoney);
     Writeln;
     IF TripMoney < 0 THEN  Writeln('Negative money is nonsense!');
     IF TripMoney = 0 THEN  Writeln('You must take at least 1 dollar.');
     IF TripMoney > Allotment THEN  Writeln('I''m sorry, we can''t let you take that much money.');
     IF (TripMoney > 0) AND (TripMoney <= Allotment) THEN
        Begin
        OKamount := TRUE;
        MoneyLeft := TripMoney;
        Writeln(ChipsLog,'BEGINNING BALANCE = ',MoneyLeft);
        Writeln(ChipsLog);
        End;
     Writeln
  UNTIL OKamount;
  REPEAT  {until MoneyLeft = 0 or GoingHome}
     IF MoneyLeft >= MinBalance THEN
        Begin
        Writeln;
        AlphaCount := AlphaCount + 1;
        CASE AlphaCount OF
                              1:  score := score + Arrival1Score;
                              2:  score := score + Arrival2Score;
                              3:  score := score + Arrival3Score;
                           ELSE   score := score + NthArrivalScore;
        End;  {of CASE}
        IF AlphaCount = 1 THEN Writeln('Welcome to Alpha!') ELSE
                                   Writeln('You have visited Alpha ',AlphaCount,' times counting this one.');
        IF AlphaCount = 1 THEN Writeln(ChipsLog,'Welcome to Alpha!')  ELSE  Begin  Writeln(ChipsLog);
                                   Writeln(ChipsLog,'You have visited Alpha ',AlphaCount,' times counting this one.')  End;
        MoneyLeft := MoneyLeft - AlphaTravelCost;
        Writeln('It cost you ',AlphaTravelCost,' dollars to get here.');
        Writeln(ChipsLog,'It cost you ',AlphaTravelCost,' dollars to get here.');
        Writeln;  Writeln(ChipsLog);
        REPEAT  {until NumRequested >= 0 and NumRequested <= List1Size}
           Write('How many chips would you like (they are ',PriceChip,' dollars each)?  ');
           Readln(NumRequested);
           IF NumRequested >= 0 THEN IF NumRequested <> 1 THEN Writeln(ChipsLog,'[you asked for ',NumRequested,' chips.]');
           IF NumRequested >= 0 THEN IF NumRequested = 1 THEN Writeln(ChipsLog,'[you asked for 1 chip.]');
           IF NumRequested < 0 THEN Writeln('A negative number of chips is nonsense!');
           IF NumRequested > List1Size THEN
              Begin
              Writeln('I''m sorry we don''t have that many chips.');
              Writeln(ChipsLog,'I''m sorry we don''t have that many chips.')
              End;
           Writeln;  Writeln(ChipsLog)
        UNTIL (NumRequested >= 0) AND (NumRequested <= List1Size);
        Writeln;
        IF NumRequested = 0 THEN
           Begin
           Write('Do you want to go home?   ');  Readln(quit);
           Writeln;
           IF quit IN ['y','Y'] THEN
              Begin
              GoingHome := TRUE;
              Writeln(ChipsLog,'[you said you wanted to go home]')
              End
           End;
        IF NumRequested > 0 THEN
           Begin
           balance1 := MoneyLeft - (NumRequested * PriceChip);
           IF balance1 < MinBalance THEN
              Begin
              Writeln('I''m sorry, we feel that you cannot afford to spend that much money.  Please');
              Writeln('reevaluate your situation and give us a new request.  If your new request is');
              Writeln('again unsuitable, we will take the money that it would cost you but without');
              Writeln('giving you the chips.');
              Writeln(ChipsLog,'I''m sorry, we feel that you cannot afford to spend that much money.  Please');
              Writeln(ChipsLog,'reevaluate your situation and give us a new request.  If your new request is');
              Writeln(ChipsLog,'again unsuitable, we will take the money that it would cost you but without');
              Writeln(ChipsLog,'giving you the chips.');
              REPEAT  {until NewNumRequested >= 0 and <= list1size}
                 Write('Now, how many chips do you want?  ');  Readln(NewNumRequested);
                 Writeln;
                 IF NewNumRequested >= 0 THEN
                    Begin
                    Writeln(ChipsLog);
                    If NewNumRequested <> 1 Then Writeln(ChipsLog,'[you then asked for ',NewNumRequested,' chips.]');
                    If NewNumRequested = 1 Then Writeln(ChipsLog,'[you then asked for 1 chip.]');
                    End;
                 IF NewNumRequested < 0 THEN  Writeln('A negative number of chips is nonsense!');
                 IF NewNumRequested > List1Size THEN Writeln('I''m sorry, we don''t have that many chips.');
                 Writeln;  Writeln(ChipsLog)
              UNTIL (NewNumRequested >= 0) AND (NewNumRequested <= List1Size);
              Writeln;  Writeln(ChipsLog);
              WarnCount := WarnCount + 1;
              score := score - (WarnCount-1) * WarnPenaltyMult;
              IF NewNumRequested = 0 THEN
                 Begin
                 Write('Do you want to end this trip and go home?  ');
                 Readln(quit);
                 IF quit IN ['y','Y'] THEN
                    Begin
                    GoingHome := TRUE;
                    Writeln(ChipsLog,'[you then said you wanted to go home.]');
                    Writeln(ChipsLog)
                    End
                 End;
              IF NewNumRequested > 0 THEN
                 Begin
                 balance2 := MoneyLeft - (NewNumRequested * PriceChip);
                 IF balance2 < MinBalance THEN
                    Begin
                    Writeln('Welcome to Beta!');  Writeln(ChipsLog,'Welcome to Beta!');
                    score := score + BetaArrivalScore;
                    Writeln;  Writeln(ChipsLog);
                    IF balance2 <= 0 THEN
                       Begin
                       MoneyLeft := 0;
                       Writeln('It cost you nothing to get here.  Seeing that someone took all your');
                       Writeln('money, we will give you one free chip.');
                       Writeln;
                       Writeln(ChipsLog,'It cost you nothing to get here.  Seeing that someone took all your');
                       Writeln(ChipsLog,'money, we will give you one free chip.');
                       Writeln(ChipsLog);
                       LIST2( TRUNC(RANDOM*List2Size) + 1 )
                       End
                    ELSE
                       Begin
                       MoneyLeft := Bal2AwardMult * balance2 - PriceChip;
                       Writeln('It cost you ',balance2,' dollars to get here.  We have taken that, but we are');
                       Writeln('giving you ',MoneyLeft,' dollars so that you may continue your journey.');
                       Writeln('Meanwhile here is a chip for you.');
                       Writeln;
                       Writeln(ChipsLog,'It cost you ',balance2,' dollars to get here.  We have taken that, but we are');
                       Writeln(ChipsLog,'giving you ',MoneyLeft,' dollars so that you may continue your journey.');
                       Writeln(ChipsLog,'Meanwhile here is a chip for you.');
                       Writeln(ChipsLog);
                       LIST2( TRUNC(RANDOM*List2Size) + 1 )
                       End;
                    Writeln;  Writeln(ChipsLog)
                    End;
                    IF balance2 >= MinBalance THEN
                       Begin
                       MoneyLeft := Balance2;
                       FOR i := 1 TO NewNumRequested DO LIST1( TRUNC(RANDOM*List1Size) + 1)
                       End
                 End
              End;
           IF balance1 >= MinBalance THEN
              Begin
              MoneyLeft := balance1;
              FOR i := 1 TO NumRequested DO LIST1( TRUNC(RANDOM*List1Size) + 1)
              End
           End
        End;
     IF (MoneyLeft < MinBalance) AND (MoneyLeft > 0) AND (NOT GoingHome) THEN
        Begin
        score := score + GamaArrivalScore;
        Writeln;  Writeln(ChipsLog);
        If MoneyLeft = 1 Then Writeln('Welcome to Gamma!  It cost you only 1 dollar to get here.')
                         Else Writeln('Welcome to Gamma!  It cost you ',Moneyleft,' dollars to get here.');
        Writeln;
        If MoneyLeft = 1 Then Writeln(ChipsLog,'Welcome to Gamma!  It cost you only 1 dollar to get here.')
                         Else Writeln(ChipsLog,'Welcome to Gamma!  It cost you ',Moneyleft,' dollars to get here.');
        Writeln(ChipsLog);
        MoneyLeft := 0;
        Writeln('Here is a chip for you.');  Writeln(ChipsLog,'Here is a chip for you.');
        Writeln;  Writeln(ChipsLog);
        LIST3 ( TRUNC(RANDOM*List3Size) + 1 )
        End
  UNTIL (MoneyLeft = 0) OR (GoingHome);
  Writeln;  Writeln;  Writeln(ChipsLog);  Writeln(ChipsLog);
  FOR i := 1 TO List1Size DO NumAlphaGot := NumAlphaGot + fcount[i];
  i := 0;  REPEAT  i := i + 1;  CompleteSet := f[i]  UNTIL (NOT CompleteSet) OR (i = List1Size);
  IF CompleteSet THEN
     Begin
     score := score + ScoreForComplete;
     Writeln(#7,'Congratulations, you have obtained a complete set of Alpha chips!!!');
     Writeln('You are hereby awarded ',ScoreForComplete,' bonus points for your achievement.');
     Writeln;
     Writeln('For your information, the probability of obtaining the complete set was');
     Writeln(ProbComplete(List1Size,NumAlphaGot),'.  This probability is based on the number');
     Writeln('of Alpha chips you got (',NumAlphaGot,') and the number of different Alpha');
     Writeln('chips in the collection.  Your score award, however, didn''t depend');
     Writeln('on this probability.');
     Writeln(ChipsLog,'Congratulations, you have obtained a complete set of Alpha chips!!!');
     Writeln(ChipsLog,'You are hereby awarded ',ScoreForComplete,' bonus points for your achievement.');
     Writeln(ChipsLog);
     Writeln(ChipsLog,'For your information, the probability of obtaining the complete set was');
     Writeln(ChipsLog,ProbComplete(List1Size,NumAlphaGot),'.  This probability is based on the number');
     Writeln(ChipsLog,'of Alpha chips you got (',NumAlphaGot,') and the number of different Alpha');
     Writeln(ChipsLog,'chips in the collection.  Your score award, however, didn''t depend');
     Writeln(ChipsLog,'on this probability.')
     End;
  IF GoingHome THEN
     Begin
     score := score + (MoneyLeft DIV MoneyToPointCon);
     Writeln;
     Writeln('Since you ended your trip, you were entitled to convert any leftover');
     Writeln('money to points at the rate of ',MoneyToPointCon,' dollars per point.');
     Writeln('These points have been added to your socre.');
     Writeln(ChipsLog);
     Writeln(ChipsLog,'Since you ended your trip, you were entitled to convert any leftover');
     Writeln(ChipsLog,'money to points at the rate of ',MoneyToPointCon,' dollars per point.');
     Writeln(ChipsLog,'These points have been added to your socre.')
     End;
  Writeln;  Writeln(ChipsLog);
  Writeln(#7,'* * * * *  YOUR SCORE FOR THE TRIP IS ',score,'  * * * * *');
  Writeln(ChipsLog,'* * * * *  YOUR SCORE FOR THE TRIP IS ',score,'  * * * * *');
  IF (WholeTripCount = 1) AND (NOT CompleteSet) AND ( NumAlphaGot >= TRUNC(IniRankIncFrac*List1Size) ) THEN
     Begin
     Writeln;
     Writeln('You have collected enough chips to be promoted to Space Captain!');
     Writeln(ChipsLog);
     Writeln(ChipsLog,'You have collected enough chips to be promoted to Space Captain!');
     rank := 1
     End;
  IF (rank < 2) AND (CompleteSet) THEN
     Begin
     Writeln;
     Writeln('In addition to your score award, you have been promoted to Space Avenger');
     Writeln('for having collected a complete set of Alpha chips.');
     Writeln(ChipsLog);
     Writeln(ChipsLog,'In addition to your score award, you have been promoted to Space Avenger');
     Writeln(ChipsLog,'for having collected a complete set of Alpha chips.');
     rank := 2
     End;
  IF (WholeTripCount > 1) AND (rank < 2) AND (NumAlphaGot > OldNumAlphaGot) AND (NOT CompleteSet)
     AND ( NumAlphaGot > TRUNC(SubRankIncFrac*List1Size) ) THEN
     Begin
     rank := rank + 1;
     Writeln;
     Write('You have obtained a sufficient number of chips to be promoted to ');
     CASE rank OF  1: Writeln('Space Captain!');  2: Writeln('Space Avenger!')  End;
     Writeln(ChipsLog);
     Write(ChipsLog,'You have obtained a sufficient number of chips to be promoted to ');
     CASE rank OF  1: Writeln(ChipsLog,'Space Captain!');  2: Writeln(ChipsLog,'Space Avenger!')  End
     End;
  Writeln;  Writeln;  Writeln(ChipsLog);  Writeln(ChipsLog);
  OldNumAlphaGot := NumAlphaGot;
  IF NOT CompleteSet THEN
     Begin
     Writeln('For your information the probability of you obtaining the complete');
     Write('set of Alpha chips was ');
     IF NumAlphaGot < List1Size THEN  Writeln('zero.')  ELSE  Writeln(ProbComplete(List1Size,NumAlphaGot),'.');
     Writeln('This probability is based on the number of Alpha chips you got (',NumAlphaGot,')');
     Writeln('and the number of different Alpha chips in the collection.');
     Writeln(ChipsLog,'For your information the probability of you obtaining the complete');
     Write(ChipsLog,'set of Alpha chips was ');
     IF NumAlphaGot < List1Size  THEN Writeln(ChipsLog,'zero.') ELSE Writeln(ChipsLog,ProbComplete(List1Size,NumAlphaGot));
     Writeln(ChipsLog,'This probability is based on the number of Alpha chips you got (',NumAlphaGot,')');
     Writeln(ChipsLog,'and the number of different Alpha chips in the collection.')
     End;
  Writeln;  Writeln;
  CLOSE(ChipsLog);
  Write('Would you like to take another trip?   ');  Readln(again);
  Writeln
  End;
Writeln;
Writeln('Goodbye!');
Writeln
END.   { M A I N    P R O G R A M }




