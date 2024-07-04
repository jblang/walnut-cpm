MODULE DiceTest;  (* -- Test of dice rolling.   John W. Fort  24 Mar 87
   I got a little suspicious when my game of Backgammon on a VIC-20 never
   rolled me a double 4 (my favorite) in six months of play, so I checked out
   the way the dice were rolled and found there were several other dice pairs
   that would never occur in the first 100 rolls.  I may not be a hot shot,
   but I want a fair chance!
*)
FROM InOut IMPORT WriteString, WriteReal, WriteLn, Write, WriteCard;
FROM Terminal IMPORT ClearScreen, GotoXY, Highlight, Normal;
FROM MathLib IMPORT Random;
FROM Utility IMPORT AnyKeyMsg;	(* Appended to end of this file *)

CONST
    COUNT = 200;

VAR
    freq1, freq2 : ARRAY[0..5] OF CARDINAL;
    freq3 : ARRAY[0..35] OF CARDINAL;
    x, p, q : CARDINAL;
    y1, y2 : CARDINAL;
    f1, f2 : REAL;
    ch : CHAR;

PROCEDURE Display1;

BEGIN
    (* display p's *)
    GotoXY(freq1[p]-1, p+6);
    IF (freq1[p] MOD 10 # 0) THEN
	Highlight;
	Write('*');
	Normal;
    ELSE
	Write('*');
    END;
    WriteCard(p+1,1);

    (* display q's *)
    GotoXY(freq2[q]-1, q+14);
    IF (freq2[q] MOD 10 # 0) THEN
	Highlight;
	Write('#');
	Normal;
    ELSE
	Write('#');
    END;
    WriteCard(q+1,1);
END Display1;


PROCEDURE Display2();

VAR
    x : CARDINAL;

BEGIN
    FOR x := 0 TO 14 DO
	GotoXY(18, 18-x);
	WriteCard(x,2); WriteString('-');
    END;
    FOR x := 0 TO 35 DO
	GotoXY(22+x, 18-freq3[x]);
	Write('*');
    END;
END Display2;


PROCEDURE RollDice() : CARDINAL;

VAR
    rn : REAL;

BEGIN
    rn := Random() * 6.0;
    RETURN TRUNC(rn);
END RollDice;


BEGIN
    ClearScreen;
    GotoXY(29,3);
    WriteString('Test of Dice Rolling');
    AnyKeyMsg;
    GotoXY(0, 5);  WriteString('First Die (p)');
    GotoXY(0, 13); WriteString('Second Die (q)');
    GotoXY(0, 21); WriteString('Count:');

    (* clear variables *)
    FOR x := 0 TO 5 DO
	freq1[x] := 0;  freq2[x] := 0;
    END;
    f1 := 0.0;  f2 := 0.0;

    (* Main loop *)
    FOR x := 1 TO COUNT DO
	p := RollDice();
	f1 := f1 + FLOAT(p);
	INC(freq1[p]);

	q := RollDice();
	f2 := f2 + FLOAT(q);
	INC(freq2[q]);

	INC(freq3[p + q * 6]);
	Display1;
	GotoXY(7,21); WriteCard(x,3);
    END;
    GotoXY(20,5);  WriteString('Bias: ');
    WriteReal(f1 / 5.0 / FLOAT(COUNT), 4,2);
    GotoXY(20,13); WriteString('Bias: ');
    WriteReal(f2 / 5.0 / FLOAT(COUNT), 4,2);
    AnyKeyMsg;
    ClearScreen;
    GotoXY(29, 3);
    WriteString('Incidence of p + q roll');
    GotoXY(19,19);  WriteString('p: ');
    FOR x := 1 TO 6 DO
        WriteString('123456');
    END;
    GotoXY(19,20);  WriteString('q: ');
    WriteString('111111222222333333444444555555666666');
    GotoXY(10,22);
    WriteString('Total pairs rolled: ');
    WriteCard(COUNT,3);
    WriteString('        Nominal incidence: ');
    WriteReal(FLOAT(COUNT) / 36.0, 2,2);
    Display2;
    AnyKeyMsg;
END DiceTest.

============== Edit here ======================================================

Part of my UTILITY module

    PROCEDURE AnyKeyMsg;
    (* Wait for user response, then seed random number generator *)

    VAR
	seed : CARDINAL;
	ch : CHAR;
    BEGIN
	GotoXY(10, 23);  WriteString('Press any key to continue: ');
	seed := 1;
	BusyRead(ch);
	WHILE ch = 0C DO
	    INC(seed);
	    BusyRead(ch);
	END;
	Randomize(seed);
	GotoXY(0, 23);  ClearToEOL;
    END AnyKeyMsg;

==============================================================================
XY(0, 23);  ClearToEOL;
    END AnyKe