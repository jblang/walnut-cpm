{ PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN }

VAR

CollectionSize,NumAcquired: Integer;    Probability: Real;

FileName: String[12];   CollectorsResults: Text;




FUNCTION  ProbComplete(NumInCollection,NumTook: integer): REAL;

Var

i,k,SumIndex,sign,bigger,smaller: Integer;

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




BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln('This is a program to calculate the probabilities in "The Collectors Problem."');
Writeln('The question posed is the following:  given so many different items in a set,');
Writeln('what is the probability of getting a complete set having acquired a given');
Writeln('number of items?  The assumption is that the items are randomly acquired and');
Writeln('the identity of each item is independent of the previous acquisition.');
Writeln;
Writeln('Please give the name of a file to record the results; you may print the file.');
Write('What will be the name for this file?   ');  Readln(FileName);
ASSIGN(CollectorsResults,FileName);
REWRITE(CollectorsResults);
Writeln;
Writeln(CollectorsResults);
Writeln(CollectorsResults,'This is a program to calculate the probabilities in "The Collectors Problem."');
Writeln(CollectorsResults,'The question posed is the following:  given so many different items in a set,');
Writeln(CollectorsResults,'what is the probability of getting a complete set having acquired a given');
Writeln(CollectorsResults,'number of items?  The assumption is that the items are randomly acquired and');
Writeln(CollectorsResults,'the identity of each item is independent of the previous acquisition.');
Writeln(CollectorsResults);
REPEAT
  Writeln;
  Write(' Give number in collection [zero to stop] ----->   ');
  Readln(CollectionSize);
  IF CollectionSize <> 0 THEN Write(' Give number aquistions ----------------------->   ');
  IF CollectionSize <> 0 THEN Readln(NumAcquired);
  IF CollectionSize > 0 THEN Probability := ProbComplete(CollectionSize,NumAcquired) ELSE Probability := 0;
  Writeln;
  IF CollectionSize > 0 THEN
     Begin
     Writeln(CollectorsResults);
     Writeln(CollectorsResults,' FOR:  ',CollectionSize,' IN COLLECTION');
     Writeln(CollectorsResults,'       ',NumAcquired,' ACQUISITIONS ');
     Writeln(CollectorsResults,'            PROBABILITY =',Probability);
     Writeln(CollectorsResults);
     Writeln(' The probability is ',Probability)
     End;
  Writeln;  Writeln;
UNTIL CollectionSize = 0;
CLOSE(CollectorsResults)
END.   { M A I N    P R O G R A M }


