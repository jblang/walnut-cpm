program sightred;
{this program performs the navigational(spherical) triangle
solution for celestial navigation sight reduction}
const convert = 0.0174532925;
var lat,x,Z,Hc,LHA,Dec : real;
    hemis, hemi, loop  : char;
    continue           : boolean;

function arcsin(x:real):real;
begin arcsin := arctan(x/sqrt(-x*x+1)) end;

function arccos(x:real):real;
begin arccos := -arctan(x/sqrt(-x*x+1))+1.5708 end;

procedure getlat;
var degrees : integer;
    minutes : real;
begin
	repeat
	writeln;
	writeln('  Enter dead reckoning latitude in the format:');
	writeln('degrees <cr> minutes <cr> N/S <cr>');
	writeln;
	write  ('degrees: '); readln(degrees);
	write  ('minutes: '); readln(minutes);
	write  ('N or S : '); read  (hemi);
	until (hemi = 'N') or (hemi = 'S');
lat := (degrees + minutes/60) * convert;     
{change degrees to decimal, then convert degrees to radians}
end;  {getlat procedure}

procedure getlha;
var degrees : integer;
    minutes : real;
    check   : char;
begin
	repeat
	writeln;
	writeln('  Enter local hour angle (LHA) in the format:');
	writeln('degrees <cr> minutes <cr> and A to accept.');
	writeln(' (any character other than A will repeat input)');
	writeln;
	write  ('degrees: ');readln(degrees);
	write  ('minutes: ');readln(minutes);
	write  ('Accept?  ');read  (check);
	until (check = 'a') or (check = 'A');
LHA := (degrees + minutes/60) * convert;
end;  	{of getlha procedure}

procedure getdec;
var degrees : integer;
    minutes : real;
    check   : char;
begin
	repeat
	writeln;
	writeln('  Enter declination in the format:');
	writeln('hemisphere <cr> degrees <cr> minutes <cr>');
	writeln('Then A to accept (any other char will repeat input)');
	writeln;
	repeat
	write  ('hemisphere (N/S) : ');read(hemis);
	until (hemis = 'N') or (hemis = 'S');
	write  ('degrees          : ');readln(degrees);
	write  ('minutes          : ');readln(minutes);
	write  ('Accept ?         : ');read  (check);
	until (check = 'a') or (check = 'A');
Dec := (degrees + minutes/60) * convert;
end;	{getdec procedure}

procedure altitude (var Hc:real);
var alt1 : integer;
    alt2 : real;
begin
	alt1 := trunc(Hc);
	alt2 := (Hc-alt1)*60;
	writeln;
	writeln('  Computed altitude, Hc, is ',alt1,'-',alt2:5:2);
end;	{altitude procedure}

procedure azimuth (var Z,LHA:real; hemi:char);
var Zn : real;
begin
LHA := LHA/convert;
	begin {quadrant determination}
	if hemi = 'N' then if LHA > 180 then Zn := Z
                                        else Zn := 360 - Z
		      else if LHA > 180 then Zn := 180 - Z
					else Zn := 180 + Z
	end;  {of quadrant determination}
writeln('  True azimuth, Zn = ',Zn:5:1);
end;	{azimuth procedure}

begin	{main program}
	continue := true;
getlat;
	while continue = true do
	begin
	getdec;
	getlha;
	if hemi <> hemis then dec := -(dec); {contrary name}
Hc := arcsin(sin(lat)*sin(dec)+cos(lat)*cos(dec)*cos(LHA));
Z  := arccos((sin(dec)-(sin(lat)*sin(Hc)))/(cos(lat)*cos(Hc)));
Hc := Hc/convert; Z := Z/convert; {radians to degrees}
altitude(Hc);
azimuth (Z,LHA,hemi);
writeln;
write  ('  Another reduction from same DR latitude? Y/N ');
read   (loop);
if (loop <> 'Y') and (loop <> 'y') then continue := false;
end;
end.
