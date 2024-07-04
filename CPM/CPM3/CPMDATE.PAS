PROGRAM DateDemo_11_18_86;

(* ------------------------------------------------------------------------ *
 * ------------------------------------------------------------------------ *


      This program is a Turbo Pascal version of the CP/M 'Date' utility.
   It is not intended as a replacement, but only as a source of code
   for the different procedures and functions it uses.  When compiled
   it requires 12k of disk space.

   The program will do the following:

      1. get the date from the system clock and display it in
         day of week, month, day of month, and year.

      2. get the time from the system clock and display it in
         HH:MM:SS format.

      3. get the date, time, or both in any order from the command
         line, parse out the appropriate values, and set the date
         and/or time.  for example: date 11/5/86,14:30:20

      4. prompt for the date and time if the user types 'date set'
         at the command line.

      5. display the date and time continuously until a key is pressed
         if the user types 'date c'.

   My appreciation goes to Ken Kroninger for supplying the code that
   showed how the Bdos calls are made.  The code that Ken supplied was
   written by Milton Hicks and J. Bauernschub Jr.  It was lightly revised
   by Jim LaSalle.

   Requirements : Turbo Pascal v2.0 or higher.
                  CP/M 3.0 (CP/M plus) - banked version.


   Please address any comments or questions to Ben Diss.  On Qlink address
   mail to 'Duque', on GEnie address mail to 'BDiss'.


 * ------------------------------------------------------------------------ *
 * ------------------------------------------------------------------------ *)

{ The Following information will prove useful in understanding this
  program:

  Bdos 105 gets the date and time from the system clock and puts the
  information in a four byte data structure beginning at the address
  passed in the DE register pair.  This program uses two integers to
  input that data: DateInt, and TimeInt. These two integers are
  declared next to each other and so that DateInt will reside higher
  in memory so that the data will be passed to the approriate
  variables.  Bdos uses this four byte structure both in setting and
  in getting the date and time.  Bdos 104 is used to set the time.

       Byte 0 - 1 : Date field as an integer representing
                    the number of days since January 1, 1978.

       Byte 2     : Hours field in BCD.
       Byte 3     : Minutes field in BCD.

  In getting the time the Bdos passes the seconds in register A in BCD.
  Turbo Pascal returns the A register when the Bdos statement is used
  as a function.

  BCD stands for Binary Coded Decimal.  An array was declared that is
  used to transfer the BCD value to an integer value.  A BCD number in
  hexidecimal form when written appears as the integer equivalent.
  For example 12h has an integer value of 18 yet its BCD value is 12.
  A hexidecimal number that does not display integers has no BCD
  equivalent.                                                           }



Const
    Days : Array [1..12] of Integer = (31,28,31,30,31,30,31,31,30,31,30,31);
    BCD  : Array [0..89] of Integer = (0,1,2,3,4,5,6,7,8,9,99,99,99,99,99,99,
                             10,11,12,13,14,15,16,17,18,19,99,99,99,99,99,99,
                             20,21,22,23,24,25,26,27,28,29,99,99,99,99,99,99,
                             30,31,32,33,34,35,36,37,38,39,99,99,99,99,99,99,
                             40,41,42,43,44,45,46,47,48,49,99,99,99,99,99,99,
                             50,51,52,53,54,55,56,57,58,59);

Type
    Date_Type = String [30];
    Time_Type = String [8];

Var
    mm, dd, yy        : Integer;
    hh, mnts, ss      : Integer;
    am                : Boolean;

PROCEDURE Get_CPM_3_Date;

Var TimeInt, DateInt  : Integer;

Begin
    ss := BCD [Bdos (105, Addr (DateInt))];
    hh := BCD [Lo (TimeInt)];
    mnts := BCD [Hi (TimeInt)];
    yy := 78;
    While DateInt > 365 Do
    Begin
        If yy/4 = Int (yy/4) then DateInt := DateInt - 1;
        yy := yy + 1;
        DateInt := DateInt - 365;
    End;
    If yy/4 = Int (yy/4) then Days [2] := 29;
    mm := 1;
    While DateInt > Days [mm] Do
    Begin
        DateInt := DateInt - Days [mm];
        mm := mm + 1;
    End;
    dd := Trunc (DateInt);
End;

PROCEDURE Build_String (Var Date : Date_Type; Var Time : Time_Type);

Const
    Day_Array       : Array [0..6] of String [9] =
                    ('Sunday','Monday','Tuesday','Wednesday',
                     'Thursday','Friday','Saturday');

    Month_Array     : Array [1..12] of String [9] =
                    ('January','February','March','April','May','June','July',
                     'August','September','October','November','December');

Var Temp1, Temp2, Temp3 : String [4];

FUNCTION Day_Of_Week (Month, Day, Year : Integer) : Integer;

Var Century : Integer;

Begin
    If Month < 2 then
    Begin
        Month := Month + 10;
        Year  := Year - 1;
    End
    Else Month := Month - 2;
    Century := Year Div 100;
    Year := Year Mod 100;
    Day_Of_Week := (Day - 1 + ((13 * Month - 1) Div 5) + (5 * Year Div 4)+
                    Century Div 4 - 2 * Century + 1) Mod 7;
End;

Begin
    Str (dd,Temp1);
    Str (yy + 1900,Temp2);
    Date := Concat (Day_Array [Day_of_Week (mm, dd, yy + 1900)],', ',
                       Month_Array [mm],' ',Temp1,', ',Temp2);
    If hh >= 12 then
    Begin
        am := False;
        hh := hh - 12;
    End
    Else am := True;
    Str (hh,Temp1);
    Str (mnts,Temp2);
    Str (ss,Temp3);
    Time := Copy ('0' + Temp1, Length (Temp1), 2) + ':' +
            Copy ('0' + Temp2, Length (Temp2), 2) + ':' +
            Copy ('0' + Temp3, Length (Temp3), 2);
End;

PROCEDURE Set_Date_Time;

Var
    Month, Year, Number_Of_Days : Integer;
    TimeInt, DateInt            : Integer;
    LoTimeInt, HiTimeInt, I     : Integer;
    Chr                         : Char;

Begin
    DateInt := dd;
    If yy/4 = Int (yy/4) then Days [2] := 29;
    For Month := 1 to mm-1 Do DateInt := DateInt + Days [Month];
    For Year := yy downto 79 Do
    Begin
        Number_Of_Days := 365;
        If Year/4 = Int (Year/4) then Number_Of_Days := 366;
        DateInt := DateInt + Number_Of_Days;
    End;
    For I := 0 to 89 Do
    Begin
        If BCD [I] = hh then LoTimeInt := I;
        If BCD [I] = mnts then HiTimeInt := I;
    End;
    TimeInt := (HiTimeInt * 256) + LoTimeInt;
    Write ('Press any key to set the time');
    Read (Kbd,Chr);
    Bdos (104, Addr (DateInt));
End;

PROCEDURE Input_Date_And_Time (Var Date, Time : Time_Type);

Begin
    Write ('Enter the date in MM/DD/YY format: ');
    ReadLn (Date);
    Write ('Enter the time in HH:MM:SS format: ');
    ReadLn (Time);
End;

PROCEDURE Parse (Str              : Time_Type;
                 Delimeter        : Char;
             Var Val1, Val2, Val3 : Integer;
             Var Error            : Boolean);

Var Error1, Error2, Error3 : Integer;

Begin
    Val (Copy (Str, 1, Pos (Delimeter,Str) - 1), Val1, Error1);
    Delete (Str, 1, Pos (Delimeter,Str));
    Val (Copy (Str, 1, Pos (Delimeter,Str) - 1), Val2, Error2);
    Delete (Str, 1, Pos (Delimeter,Str));
    Val (Str, Val3, Error3);
    If (Error1 > 0) or (Error2 > 0) or (Error3 > 0) then Error := True
    Else Error := False;
End;

PROCEDURE Display_Date (Continuous : Boolean);

Var
    Old_String : String [38];
    Date       : Date_Type;
    Time       : Time_Type;
    Chr        : Char;

Begin
    Old_String := '';
    Repeat
        Get_CPM_3_Date;
        Build_String (Date, Time);
        If Old_String <> (Date + Time) then
        Begin
            Write (^m,Date,'; ',Time);
            If am then Write (' am') else Write (' pm');
            Old_String := Date + Time;
        End;
        If KeyPressed then
        Begin
            Continuous := False;
            Read (Kbd,Chr);
        End;
    Until Not Continuous;
    Halt;
End;

PROCEDURE Parse_Parameter;

Var
    ParStr      : String [30];
    Date, Time  : Time_Type;
    Error       : Boolean;
    I           : Integer;

Begin
    Date := '';
    Time := '';
    ParStr := '';
    For I := 1 to ParamCount Do ParStr := ParStr + ParamSTR (I);
    If Pos ('C',ParStr) > 0 then
    Begin
        Display_Date (True);
        Exit;
    End;
    If (Pos (',',ParStr) > 0) then
        If (Pos ('/',ParStr) < Pos (':',ParStr)) then
        Begin
            Date := Copy (ParStr, 1, Pos (',',ParStr) - 1);
            Time := Copy (ParStr, Pos (',',ParStr) + 1, Length (ParStr));
        End
        Else
        Begin
            Time := Copy (ParStr, 1, Pos (',',ParStr) - 1);
            Date := Copy (ParStr, Pos (',',ParStr) + 1, Length (ParStr));
        End
    Else If (Pos ('/',ParStr) > 0) and (Date = '') then
        Date := Copy (ParStr, 1, Length (ParStr))
    Else If (Pos (':',ParStr) > 0) and (Time = '') then
        Time := Copy (ParStr, 1, Length (ParStr))
    Else If Pos ('S',ParStr) > 0 then Input_Date_And_Time (Date,Time);
    Get_CPM_3_Date;
    If Date <> '' then Parse (Date, '/', mm, dd, yy, Error);
    If Time <> '' then Parse (Time, ':', hh, mnts, ss, Error);
    If (mm<0) or (mm>12) or (dd<0) or (dd>31) or (yy<0) or (yy>99)
        or (hh<0) or (hh>24) or (mnts<0) or (mnts>59) or (ss<0) or (ss>59)
        then Error := True;
    If Error then WriteLn ('ERROR: Illegal time/date specification.');
    If (Error = False) and ((Date <> '') or (Time <> '')) then Set_Date_Time;
End;

BEGIN
    If ParamCount > 0 then Parse_Parameter
    Else Display_Date (False);
END.