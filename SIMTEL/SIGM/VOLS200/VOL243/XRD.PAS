{PROGRAM AUTHOR: Mark Aldon Weiss   PROGRAM DONATED TO PUBLIC DOMAIN}

CONST

CuKalpha : Real = 1.541838;
CuKalpha1: Real = 1.540562;
CuKalpha2: Real = 1.544390;

MaxNumLines = 160;
MaxLengthLabel = 75;
MaxLengthComment = 24;

pi: Real = 3.141592654;

TYPE

Dtype = Array[1..MaxNumLines] of Real;



VAR

Data: Text;    DataLine: String[80];

Label1,Label2: String[MaxLengthLabel];

CommaPos,code: Integer;    i,NumLines: 1..MaxNumLines;    ch: Char;

dplus,dminus,dist0_180,UncDist0_180,ShrinkFactor,UncShrinkFactor: Real;

pos0,pos180,unc0pos,unc180pos: Real;    again: Boolean;

AnglePos,UncAnglePos,correc2theta,unc2theta,d,d1,d2,uncd: Dtype;

QualIntens: Array[1..MaxNumLines] of String[2];

Comment: Array[1..MaxNumLines] of String[MaxLengthComment];



PROCEDURE  EraseLabels;

Begin  {EraseLabels}
FOR i := 1 to MaxLengthLabel DO
    Begin
    Label1[i] := ' ';
    Label2[i] := ' '
    End
End;   {EraseLabels}




{$I GetName.Pro}



PROCEDURE GetInfo;

Begin  {GetInfo}
Writeln(' You should already have a file of XRD data.');  Writeln;
GetFileName(Data);
Writeln(' Give the first line of the label for this data:');
Readln(Label1);
Writeln;
Writeln(' Give the second line of the label for this data:');
Readln(Label2);
Writeln;
Write('Give 0-angle position in cm -------------------->  ');  Readln(pos0);
Write('Give uncertainty (95 % conf) of 0-angle pos. --->  ');  Readln(unc0pos);
Writeln;
Write('Give 180-degrees position in cm -------------->  ');  Readln(pos180);
Write('Give uncertainty (95 %) of 180 position ------>  ');  Readln(unc180pos);
Writeln
End;   {GetInfo}



PROCEDURE ReadData;

Begin  {ReadData}
i := 0;
WHILE NOT EOF(Data) DO
      Begin
      i := i + 1;
      Readln(Data,DataLine);  Comment[i][1] := ' ';  Comment[i][2] := ' ';
      commapos := POS(',',DataLine);
      VAL(  COPY( DataLine, 1 , commapos-1 ) , AnglePos[i] , code  );
      DataLine := COPY( DataLine, commapos+1, LENGTH(DataLine) );
      commapos := POS(',',DataLine);
      VAL(  COPY( DataLine, 1 , commapos-1 ) , UncAnglePos[i] , code  );
      DataLine := COPY( DataLine, commapos+1, LENGTH(DataLine) );
      commapos := POS(',',DataLine);
      QualIntens[i] := COPY( DataLine,1,commapos-1);
      Comment[i] := COPY( DataLine,commapos+1,LENGTH(DataLine) )
      End;
NumLines := i
End;   {ReadData}



PROCEDURE  ConvertData;

Begin  {ConvertData}
FOR i := 1 to NumLines DO
    Begin
    IF AnglePos[i] > pos180 THEN
       Begin
       correc2theta[i] := ABS(pos0 - AnglePos[i]) * 10 * ShrinkFactor;
       unc2theta[i] :=(SQR(unc0pos)+SQR(UncAnglePos[i]))/SQR(AnglePos[i]-pos0);
       unc2theta[i] := unc2theta[i] + SQR(UncShrinkFactor/ShrinkFactor);
       unc2theta[i] := SQRT( unc2theta[i] ) * correc2theta[i]
       End;
    IF AnglePos[i] <= pos180 THEN
       Begin
       correc2theta[i]:=( pos0 - 2*pos180 + AnglePos[i] ) * 10 * ShrinkFactor;
       unc2theta[i] := SQR(unc0pos) + 2*SQR(unc180pos) + SQR(UncAnglePos[i]);
       unc2theta[i] := unc2theta[i]/(pos0 - 2*pos180 + AnglePos[i]);
       unc2theta[i] := unc2theta[i] + SQR(UncShrinkFactor/ShrinkFactor);
       unc2theta[i] := SQRT( unc2theta[i] ) * correc2theta[i]
       End;
    d[i] := (CuKalpha/2) / sin( correc2theta[i]/2 * pi / 180);
    d1[i] := 0;  d2[i] := 0;
    IF (comment[i][1] = '1') OR (comment[i][2] = '1') THEN
       d1[i] := (CuKalpha1/2) / sin( correc2theta[i]/2 * pi / 180);
    IF (comment[i][1] = '2') OR (comment[i][2] = '2') THEN
       d2[i] := (CuKalpha2/2) / sin( correc2theta[i]/2 * pi / 180);
    IF comment[i][1] IN ['1','2'] THEN DELETE(Comment[i],1,1);
    IF comment[i][1] IN ['1','2'] THEN DELETE(Comment[i],1,1);
    dplus  := (CuKalpha/2) / sin( (correc2theta[i]+unc2theta[i])/2 * pi / 180);
    dminus := (CuKalpha/2) / sin( (correc2theta[i]-unc2theta[i])/2 * pi / 180);
    uncd[i] := (  ABS(d[i]-dplus) + ABS(d[i]-dminus)  ) / 2
    End
End;   {ConvertData}



BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln(' This program calculates and prints results from Debye-Scherrer');
Writeln(' xray diffraction powder patterns.  You should have a data file as');
Writeln(' follows:');
Writeln;
Writeln(' 23.015,.015,M,w/i diffuse region');
Writeln;
Writeln(' This is a sample line from the file.  The first number is the line');
Writeln(' position in cm; the second number is its uncertainty; next is');
Writeln(' qualitative intensity given as one or two letters (M = "moderate")');
Writeln(' Finally, there is a comment field.  YOU MUST TYPE ALL THE COMMAS');
Writeln(' SHOWN.  DON''T leave spaces.');
Writeln;
REPEAT
Writeln(#7,' GET THE PRINTER PAPER TO ABOUT 3 LINES BELOW THE TOP OF A PAGE.');
Writeln(' TURN OFF THE PRINTER.  NOW, TURN THE PRINTER BACK ON.');  Writeln;
Write(' Did you do this?    ');  Readln(ch);  Writeln
UNTIL ch IN ['y','Y'];
Writeln;
Writeln(lst,#27'N'#9);
again := TRUE;
WHILE again DO
Begin
EraseLabels;
GetInfo;
dist0_180 := ABS(pos0 - pos180) * 10;
UncDist0_180 := SQRT( SQR(unc0pos) + SQR(unc180pos) );
ShrinkFactor := 180 / dist0_180;   Writeln('shrink factor = ',shrinkfactor);
UncShrinkFactor := (UncDist0_180/dist0_180) * ShrinkFactor;
ReadData;
ConvertData;
Writeln(lst,#27'2',#18,#27'E',#27'G','   ',Label1);
Writeln(lst,#27'2',#18,#27'F',#27'G','   ',Label2);
Writeln(lst);
Write(lst,#27'0'#27'H'#15#27'U'#1);
Write(lst,'      ','Corrected',' ':4,'Uncertainty',' ':4,'Qualitative',' ':4);
Write(lst,'     d - s p a c i n g        ',' ':2,'Uncertainty',' ':2);
Writeln(lst,'       Comments       ',' ':4,'Quantitative');
Write(lst,'      ',' 2-theta ',' ':4,'  2-theta  ',' ':4,' intensity ',' ':4);
Write(lst,' Cu Ka    Cu Ka1    Cu Ka2  ',' ':4,' d-spacing ',' ':4);
Writeln(lst,'                      ',' ':2,' intensity  ');
Writeln(lst);
FOR i := 1 to NumLines DO
    Begin
    Write(lst,' ',i:3,' ':2,correc2theta[i]:7:2,' ':8,unc2theta[i]:5:2);
    Write(lst,' ':12,QualIntens[i]:2,' ':8,d[i]:8:5,'  ');
    IF d1[i] <> 0 THEN Write(lst,d1[i]:8:5,'  ') ELSE Write(lst,' ':10);
    IF d2[i] <> 0 THEN Write(lst,d2[i]:8:5,' ':6) ELSE Write(lst,' ':14);
    Writeln(lst,uncd[i]:8:5,' ':3,comment[i]:24)
    End;
Writeln;
Write(' Do you have another set of XRD data?   ');
Readln(ch);
IF ch IN ['y','Y'] THEN
   Begin
   again := TRUE;
   Writeln(lst,#12)
   End
ELSE
   again := FALSE
End
END.   { M A I N    P R O G R A M }




