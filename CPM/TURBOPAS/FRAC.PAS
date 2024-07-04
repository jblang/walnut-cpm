PROGRAM FRACTIONS;
{$A-}
{J. BEAHM 1/23/86}
{PROGRAM TO ADD OR SUBTRACT FRACTIONS WITH UNLIKE DENOMINATORS}
{SIMPLIFIES ANSWER}
{IF YOU HAVE LONG_INTEGER ON PASCAL VERSION, USE IT INSTEAD OF INTEGER}

VAR

   NUM,                  {NUMERATOR AFTER + OR -}
   DEN,                  {COMMON DENOMINATOR}
   FACTOR,               {GREATEST COMMON FACTOR}
   N1,                   {FIRST NUMERATOR ENTERED}
   N2,                   {SECOND NUMERATOR}
   D1,                   {FIRST DENOMINATOR}
   D2,                   {SECOND DENOMINATOR}
   N3,                   {NUMERATOR FROM N1 FOR EQUIV. FRACTION}
   N4:INTEGER;           {NUMERATOR FROM N2  "   "      "}
   ANS,                  {ANSWER (Y/N)}
   OP:CHAR;              {OPERATION (+ OR -)}
   B1,
   B2:STRING[3];

{********************************************}

FUNCTION GCF(K1,K2:INTEGER):INTEGER;


{RECURSIVE FUNCTION TO FIND G.C.F.}

BEGIN
     IF K1 MOD K2 = 0 THEN
        GCF:=K2
     ELSE
         GCF:=GCF(K2,K1 MOD K2);

END;

{*****************************************}

PROCEDURE ENTRY;

{PROCEDURE TO ENTER NUMBERS AND OPERATION}

BEGIN

      CLRSCR;

      GOTOXY(1,1);
      WRITELN('ENTER THE NUMERATORS, DENOMINATORS, AND OPERATION AS INDICATED');
      GOTOXY(5,6);
      WRITE('-----');
      GOTOXY(5,12);
      WRITE('-----');

      GOTOXY(6,5);
      READLN(N1);

      GOTOXY(6,7);
      READLN(D1);
      REPEAT
            GOTOXY(3,12);
            READLN(OP);
      UNTIL (OP='+') OR (OP='-');


      GOTOXY(6,11);
      READLN(N2);

      GOTOXY(6,13);
      READLN(D2);


      GOTOXY(12,6);
      WRITE('=');

      GOTOXY(12,12);
      WRITE('=');

      GOTOXY(1,16);
      WRITE('-------------------------');

END;

{***********************************}

PROCEDURE EQUIV_FRACT;

{PROCEDURE TO FIND EQUIVALENT FRACTIONS WITH LEAST COMMON DENOMINATOR}


BEGIN
     DEN:=D1 DIV FACTOR*D2;

     {FIND OUT IF WE GO OVER MAXINT}
     IF D1<>DEN DIV D2*FACTOR THEN
        WRITE('DENOMINATOR > MAXIMUM INTEGER, RESULTS NOT VALID');

     N3:=N1*(DEN DIV D1);
     N4:=N2*(DEN DIV D2);

     GOTOXY(15,5);
     WRITE(N3);

     GOTOXY(14,6);
     WRITE('-----');



     GOTOXY(15,7);
     WRITE(DEN);

     GOTOXY(15,11);
     WRITE(N4);

     GOTOXY(14,12);
     WRITE('-----');


     GOTOXY(15,13);
     WRITE(DEN);

END;

{************************************}

PROCEDURE WORK;

{ADD OR SUBTRACT EQUIVALENT FRACTIONS}

BEGIN
     IF OP='+' THEN
        NUM:=N3+N4
     ELSE
        NUM:=N3-N4;

     GOTOXY(15,20);
     WRITE(NUM);

     GOTOXY(14,21);
     WRITE('-----');

     GOTOXY(15,22);
     WRITE(DEN);



END;

{****************************************}

PROCEDURE REDUCE;

{REDUCE IF POSSIBLE}

BEGIN
     FACTOR:=GCF(NUM,DEN);
     IF GCF(NUM,DEN)>1 THEN
        BEGIN
             NUM:=NUM DIV FACTOR;
             DEN:=DEN DIV FACTOR;

             GOTOXY(20,21);
             WRITE('=');


             GOTOXY(23,20);
             WRITE(NUM);


             GOTOXY(22,21);
             WRITE('-----');


             GOTOXY(23,22);
             WRITE(DEN);


       END;

END;

{**************************************}


PROCEDURE SIMPLIFY;

{SIMPLIFY IF IMPROPER FRACTION}

VAR
   WN:INTEGER; {WHOLE NUMBER FROM IMPROPER FRACTION}

BEGIN
     IF NUM>DEN THEN
        BEGIN
             WN:=NUM DIV DEN;
             NUM:=NUM MOD DEN;

             GOTOXY(28,21);
             WRITE('= ',WN,' -----');

             GOTOXY(33,20);
             WRITE(NUM);

             GOTOXY(33,22);
             WRITE(DEN);

          END;

END;

{*******************************************}


BEGIN {MAIN PROGRAM}
   REPEAT
     ENTRY;
     FACTOR:=GCF(D1,D2);
     EQUIV_FRACT;
     WORK;
     REDUCE;
     SIMPLIFY;
     GOTOXY(1,24);
     WRITE('ANOTHER? (Y/N)');
     READLN(ANS);
   UNTIL (ANS='N') OR (ANS='n');
END.
