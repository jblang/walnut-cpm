{***********************************************************************}
{*                                                                     *}
{*              TRANSFORM ** A DATA TRANFORMATION PROGRAM              *}
{*                copyright (c) 1985 by Larry Marshall                 *}
{*                                                                     *}
{*       This program may be used for noncommercial purposes only.     *}
{*       No commercial use of TRANSFORM may be made without the        *}
{*       author's expressed written permission.                        *}
{*                                                                     *}
{***********************************************************************}


{ This program will allow transformation of data for the purposes }
{ of normalization.  The input file must contain only the variable }
{ to be transformed.  The input & output files are not defined by the }
{ program and are supplied by the user when prompted }


Program ArcSine (input,output);

Var
 Sine,Cosine,Tangent,Val,Tval : real;
 Datain,Dataout : text;
 FileName1,FileName2 : String[14];
 Choice : integer;

Begin
 Writeln('          ***********************************************');
 Writeln('          *                                             *');
 Writeln('          *            ** Transform Choices **          *');
 Writeln('          *                                             *');
 Writeln('          *         (1) Arc-sine transformation         *');
 Writeln('          *                                             *');
 Writeln('          *         (2) Log-normal transformation       *');
 Writeln('          *                                             *');
 Writeln('          *         (3) Square root tranformation       *');
 Writeln('          *                                             *');
 Writeln('          ***********************************************');
 Writeln('             Type the number of your choice & <return>');
 Readln(choice);
 Clrscr;
 Writeln;writeln;writeln;writeln;writeln;
 Write('                Name of input file:  ');
 Readln(FileName1);
 Writeln;
 Write('                Name of output file:  ');
 Readln(FileName2);

 Assign(Datain,FileName1);
 Assign(Dataout,FileName2);
 Reset (Datain);
 Rewrite(Dataout);

 Case Choice of

   1 : While not EOF(datain) do
         Begin
           Readln(Datain,Val);
           Sine:=SQRT(Val);
           If Sine = 1 then
            Begin
               Sine:=0.99999999999;
            end
           Else
            Begin
         {   Cosine:=SQRT((1-SQR(Sine))); }
         {   Tangent:=Sine/Cosine;   }
          {  Tval:=Arctan(Tangent); }
             Tval:=arctan(val/sqrt(-val*val+1));
            End;
           Writeln(Dataout,Tval:4:4);
         End;

    2 : While not EOF(datain) do
         Begin
           Readln(Datain,Val);
           Tval:=LN(Val+1);
           Writeln(Dataout,Tval:4:4);
         End;

     3 : While not EOF(datain) do
         Begin
           Readln(Datain,Val);
           Tval:=SQRT(Val+0.5);
           Writeln(Dataout,Tval:4:4);
         End;
 End;

 Close(Datain);
 Close(Dataout);
End.
