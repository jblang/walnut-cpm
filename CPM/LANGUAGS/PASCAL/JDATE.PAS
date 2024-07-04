program julian;
var
julian,year,month,day : integer;

procedure DtoJ(Day,Month,Year: integer;var Julian: integer);
  { Convert from a date to a Julian number -- January 1, 1900 = -32767 }
  { Note that much care is taken to avoid problems with inaccurate bit representations inherent in the binary fractions
    of the real numbers used as temporary variables.  Thus the seemingly unnecessary use of small fractional offsets
    and int() functions }
  begin
  if (Year=1900) and (Month<3)                   { Handle the first two months as a special case since the general }
   then                                          {   algorithm used doesn't start until March 1, 1900 }
    if Month=1
     then
      Julian := Day-$8000                        { Compiler won't accept -32768 as a valid integer, so use the hex form }
     else
      Julian := Day-32737
   else
    begin
    if Month>2
     then
      Month := Month-3
     else
      begin
      Month := Month+9;
      Year := Year-1
      end;
    Year := Year-1900;
    Julian := round(-32709.0+Day+int(0.125+int(1461.0*Year+0.5)/4.0))+((153*Month+2) div 5)
    end
  end;

procedure JtoD(Julian: integer;var Day,Month,Year: integer);
  { Convert from a Julian date to a calendar date }
  { Note that much care is taken to avoid problems with inaccurate bit representations inherent in the binary fractions
    of the real numbers used as temporary variables.  Thus the seemingly unnecessary use of small fractional offsets
    and int() functions }
  var Temp: real;
  begin
  Temp := int(32767.5+Julian);                   { Convert 16 bit quantity into a real number }
  if Temp<58.5
   then
    begin                                        { The first two months of the twentieth century are handled as a special }
    Year := 1900;                                {   case of the general algorithm used which handles all of the rest }
    if Temp<30.5
     then
      begin
      Month := 1;
      Day := round(Temp+1.0)
      end
     else
      begin
      Month := 2;
      Day := round(Temp-30.0)
      end
    end
   else
    begin
    Temp := int(4.0*(Temp-59.0)+3.5);
    Year := trunc(Temp/1461.0+0.00034223);     { 0.00034223 is about one half of the reciprocal of 1461.0 }
    Day := succ(round(Temp-Year*1461.0) div 4);
    Month := (5*Day-3) div 153;
    Day := succ((5*Day-3) mod 153 div 5);
    Year := Year+1900;
    if Month<10
     then
      Month := Month+3
     else
      begin
      Month := Month-9;
      Year := succ(Year)
      end
    end
  end;

function DayOfWeek(Julian: integer): integer;
  { Return an integer representing the day of week for the date }
  { Sunday = 0, etc. }
  var Temp: real;
  begin
  Temp := Julian+32767.0;                        { Convert into a real temporary variable }
  DayOfWeek := round(frac((Temp+1.0)/7.0)*7.0)   { Essentially this is a real number version of Julian mod 7 with }
  end;                                           { an offset to make Sunday = 0 }

procedure WriteDate(Julian: integer);
  { Write the date out to the console in long form , e.g. "Monday, September 10, 1984" }
  const Days: array[0..6] of string[9]=('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
        Months: array[1..12] of string[9] = ('January','February','March','April','May','June',
                                             'July','August','September','October','November','December');
  var Day,Month,Year: integer;
  begin
  JtoD(Julian,Day,Month,Year);                   { Convert into date form }
  writeln(Days[DayOfWeek(Julian)]);
  Write(Months[Month],' ',Day,', ',Year);
  end;

begin
  clrscr;
  write('Day    ');   readln(Day);
  write('Month  ');   readln(month);
  write('Year   ');   readln(Year);
  year := year + 1900;
  DtoJ(Day,Month,Year,Julian);
  writeln(julian);
  writedate(julian);

end.