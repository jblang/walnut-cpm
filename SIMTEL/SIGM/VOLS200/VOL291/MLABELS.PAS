program MakeALable;

 type
   Line = String[40];

 const
   LabelLength = 6;

 var
   X,Y,NumOfLabels : integer;
   Lines           : array[1..LabelLength] of Line;
   Ch              : char;

  begin
    repeat
      for X := 1 to LabelLength do
        begin
          write('Input Line ',X,' > ');
          readln(Lines[X]);
        end;
      writeln;
      write('How many Labels do you want? > ');
      readln(NumOfLabels);
      for Y := 1 to NumOfLabels do
        begin
          for X := 1 to LabelLength do writeln(lst,Lines[X]);
        end;
      writeln;
      write('Do you want to do another label? [Y/N] : ');
      read(kbd,Ch);
      writeln;
      writeln;
    until not(Ch in ['Y','y']);
    end.
