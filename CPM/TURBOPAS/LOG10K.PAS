program log10k;


{

T.A. Elkin's Log(10K!) Benchmark.

Computes number of decimal digits in 10,000 factorial.
Exact answer is 35660

See COMPUTERWORLD. 3/20/87 for more info.

Adapted by the CP/M Basic Version by Jim Lill 7/20/87

Comparision Times:

IBM Compatible, GW-BASIC:   149 secs
MBASIC 5.0 @ 10MHz:         110 secs
Turbo Pascal (CP/M @10MHz): 108 secs

}

const bell = ^G;
      exact = 35660.0;

var i : integer;
    e,x,y,z : real;

begin;  {log10k}
  z:= 10.0;
  x:= 0.0;
  writeln('Elkins Log(10K!) Benchmark',bell);
  for i := 2 to 10000 do
    begin
      y:= i;
      x:= x + ln(y);
    end;
  writeln('Done',bell);
  writeln('Error: ',(exact- x/ln(z)))
end.  {log10k}

