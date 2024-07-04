EXTERNAL EDITFILE::BUILD(1);

Function INREC (j,i,l: INTEGER): integer;
{
GLOBAL
	valid_build : boolean }
LABEL	10;
VAR	Alfa : STRING 20;
	valid : boolean;
begin
  REPEAT
    valid := false;
    IF j>99 then
      begin
	j := 200;
	{exit} goto 10
      end;
    If  (j=0) or (j=1) or (j=2) or
	(j=4) or (j=6) or (j=99) then
      begin{If valid}
        valid := true;
	NBUFFER.tag := j ;
	WITH NBUFFER DO
	  CASE TAG OF
	  0:    begin
		SETLENGTH(NAME,0);
                writeln('                      ____________________');
		write(' Program Name........ ');
		READLN(ALFA);
		If Length(ALFA)>20 then SETLENGTH(ALFA,20);
		APPEND(NAME,ALFA);
		write(' No. Nutrients..(integer). ');
		READLN(N1);
		write(' No. Feeds...(integer).... ');
		READLN(N2);
		N2 := N2 + N1;	{must account for surplus accounts}
		end;
	  1:    begin
		writeln;
		writeln('Make any identifying notes about this data');
		write(' Header..(notes) ');
		READLN(header)
		end;
	  2:    begin
		writeln('                         ____________________');
		write(' Nutrient Name..(char).. ');
		READLN(RNAME);
		RINDEX := i;
		write(' Nutrient Requirement ..(real #).. ');
		READLN(RHS)
		end;
	  4:    begin
		writeln('                          ____________________');
		write(' Feed Name ..(char)...... ');
		READLN(CNAME);
		CINDEX := i;
		write(' Cost ................$');
		READLN(OBJ)
		end;
	  6:    begin
		writeln;
		R := l;
		S := i;
		write(' Feed #',i:3,' Nutrient #',l:3,' ..(real #). ');
		READLN(T)
		end;
	  99:   valid_build := true
	  End{With/CASE}
      end{If valid}
    Else
      Write('INVALID TAG, Reenter ---> ')
  UNTIL valid{TAG};
10: INREC := j
End{of INREC};

Procedure BUILD;
VAR	FX : LINEAR;
	 i,k,l,
	 n1count,n2count,
	 N : INTEGER;
begin
  GETID(NFIL,' Build what File? ');
  REWRITE(NFIL, FX);	  (*---REWRITE( <FID> , <FCB> )---*)
  valid_build := false;
  N := 0;
  While (N < 100) DO
    begin
      {start building.  One 0-tag required, only one allowed}
      k := 0;
      N := INREC(k,i,l);
      n1count := NBUFFER.N1;	{need these below}
      n2count := NBUFFER.N2 - n1count;{take the surplus accounts back out}
      write(FX, NBUFFER);
      {continue building.  One 1-tag comment allowed}
      k := 1;
      N := INREC(k,i,l);
      write(FX, NBUFFER);
      {continue building.  Each nutrient requires one 2-tag.}
      k := 2;
      for i := 1 to n1count do
	begin
	N := INREC(k,i,l);
	write(fx,nbuffer);
	end;	{for n1count loop}
      {continue building. Each feed requires one 4-tag (name & cost)
	and one 6-tag for each nutrient}
      for i := 1 to n2count do	{# feeds}
	begin
	k := 4;		{4-tag, one per feed}
	N := INREC(k, i, l);
	write(fx,nbuffer);
        writeln('Enter the nutrient analysis for this feed; ');
	writeln('  nutrients are numbered in the order you entered them.');
	for l := 1 to n1count do	{# nutrients}
	  begin
	  k := 6;
	  N := INREC(k, i, l);
	  write(fx,nbuffer);
	  end;	{n1count}
	end;	{n2count}

      for i := 1 to n1count do
      {dummy surplus records with 4-tags}
	begin
	with NBUFFER do
	  begin
	  tag := 4;
	  cname := '        surplus     ';
	  cindex := n2count + i;
	  obj := 0.0;
	  end;	{with}
	write(fx,nbuffer);
	end;	{for}
{insert  6-tag records here.  dummies} 
      for i := 1 to n1count do
	begin
	with nbuffer do
	  begin
	  tag := 6;
	  R := i;
	  S := i + n2count;
	  T := -1.0;
	  end;	{with}
	write(fx,nbuffer);
	end;	{for}
      {end it all, 99-tag}
      k := 99;
      N := INREC(k,i,l);
	If (N<100) then
	   Write(FX, NBUFFER);
	If (N=99) AND valid_build then{finished}
	  N:=200
	Else
	  If (N>99) AND (not valid_build) then
	    begin
	    writeln('You MUST enter a TAG record of 99');
	    N := 0
	    end
    end{while}
End{of build};
 .
