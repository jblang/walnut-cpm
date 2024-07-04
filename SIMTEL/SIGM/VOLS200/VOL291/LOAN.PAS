program amortization;

var
  loan,rate,pmt,bal,interest,int_to_date,principal,prin_to_date,totalpay,
  finalpay,cal:real;
  ch:char;
  length_of_loan,month:integer;
  z:text;

procedure init;
begin
  int_to_date:=0;
  principal:=0;
  prin_to_date:=0;
  totalpay:=0;
end;

procedure header;

begin
  clrscr;
  writeln ('DECLINING INTEREST PROGRAM ');
  writeln;
  write ('Do you wish to display or print <D or P> ');
  repeat
    read (ch);
    write (#8);
  until upcase (ch) in ['D','P'];
  if upcase(ch)='P' then assign (z,'LST:') else assign (z,'CON:');
  reset (z);
  writeln;
  writeln;
  write ('Amount of Loan - ');
  readln (loan);
  write ('Interest rate (e.g. 9.25) /year) - ');
  readln (rate);
  write ('Length of loan (in months) - ');
  readln (length_of_loan);
  writeln;
  writeln;
  writeln (z,loan:14:2,' for ',length_of_loan:5,' months at ',rate:5:2,
           ' per cent');
  rate:=rate/1200;
  cal:=exp(length_of_loan*ln(1.0+rate));
  pmt:=loan*((rate*cal)/(cal-1.0));
  writeln (z);
  writeln (z,' ':9,'Monthly payment = ',pmt:8:3);
  writeln (z);
  write ('Do you want a monthly breakdown <Y or N> ');
  repeat
    read (ch);
    write (#8);
  until upcase (ch) in ['Y','N'];
  writeln (z);
  if upcase(ch)='Y' then
  begin
    write (z,'Month     Balance      Interest   Int T.D.     ');
    writeln (z,'Principal     Prin T.D. ');
  end;
end;

begin
  repeat
    header;
    init;
    bal:=loan;
    for month:= 1 to length_of_loan do
    begin
      interest:=bal*rate;
      if month=length_of_loan then pmt:=bal+interest;
      totalpay:=totalpay+pmt;
      principal:=pmt-interest;
      bal:=bal-principal;
      int_to_date:=int_to_date+interest;
      prin_to_date:=prin_to_date+principal;
      if upcase(ch)='Y' then
      writeln (z,' ',month:4,bal:12:2,interest:14:2,int_to_date:11:2,
      principal:14:2,prin_to_date:14:2);
    end;
    writeln (z);
    writeln (z,' ':9,'Final Payment = ',pmt:12:2);
    writeln (z);
    writeln (z,' ':9,'Total Payment = ',totalpay:12:2);
    writeln;
    write ('Do you wish another amortization table <Y or N> ');
    repeat
      read (ch);
      write (#8);
    until upcase (ch) in ['Y','N'];
    close(z);
  until upcase (ch)='N';
end.



      read (ch);
      write (#8);
    until upcase (ch) in ['Y','N'];
    close(z);
  until upcase (ch)='N';
en