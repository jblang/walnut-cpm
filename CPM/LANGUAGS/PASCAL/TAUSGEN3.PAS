program Tausgen ;

{
 Demonstration of Tausworthe Pseudorandom Number Generator
 30 April 1985
 David P Kirschbaum, Toad Hall
 7573 Jennings Lane, Fayetteville NC  28303
 on ARPANet:  ABN.ISCAMS@USC-ISID
 See extracts from Professor Thesen's paper (the source of this code) at
 the end of this program.

 Expect an initial delay during the initialization of the byte table and
 offset pointers when the program actually runs.  During actual implementation
 in a program, the table would be initialized only once (until you wanted to
 reseed again, anyway).

 If using my simple screen display version below, you have flow control.
 Enter any key to pause, and enter RETURN to continue.  (Your system may
 stop on its own occasionally if your system XOFFs high-speed printing to the
 console.  Just enter RETURN to continue.)

 Enter Q or q to end.
}

{Relax string parameter checking}

{V$-}

Type
  Line  = string[79] ;
  Menu  = string[25] ;


const
  pminusl = 97  ; {p = 98; q = 27}
  maxbit  = 255 ;
  maxs    = 26  ;
  Selection : array[1..4] of Menu  =
              ('1  Random Number Display ' ,
               '2  Speed Run (no display)' ,
               '3  Distribution Display  ' ,
               '4  Quit                  ') ;
var
  Ch        : Char ;
  Sentence  : Line ;
  BlankLine : Line ;
  Halted    : Boolean ;
  Quit      : Boolean ;
  Error     : Boolean ;
  f,s       : Integer ;
  x,y       : Integer ;
  count     : Integer ;
  prandom   : Integer ;
  choice    : Integer ;
  ByteTable : array[0..pminusl]of byte ;
  RCounter  : array[0..maxbit] of Integer ;

procedure CenterPrint(Sentence : Line) ;
var
  Centered : Line ;

  begin
    Centered := BlankLine ;
    y := (80 - Length(Sentence)) div 2 ;
    Insert(Sentence,Centered,y) ;
    Writeln(Centered) ;
  end ;


procedure PlotXY(var number : integer; value : integer) ;

  begin
    x := (number mod 12) * 4 + 12 ;
    y := (number div 12) + 2 ;
    GoToXY(x,y) ;
    Write(value:4) ;
  end ;  {PlotXY}


procedure CheckUser ;

  begin
    if KeyPressed then
      begin
        GoToXY(1,24) ;
        Read(Ch) ;
        Quit := Ch in ['Q', 'q'] ;
      end ;  {KeyPressed}
  end ; {CheckUser}

procedure ContPrompt ;

  begin
    Writeln ;
    GoToXY(1,22) ;
    CenterPrint('Hit any key to continue:  ' ) ;
    Writeln ;
    GoToXY(54,22) ;
    Repeat until KeyPressed = True ;
  end ;

procedure TauInit(var f,s : integer) ;
var
  BitIndex  : integer ;
  WorkTable : array[0..pminusl]of byte ;

  begin
    for count := 0 to pminusl do
      begin
        ByteTable[count] := maxbit ;
        WorkTable[count] := 0   ;
      end ;  {count loop}
    f := pminusl ;
    s := maxs ;
    Quit := False ;
    for BitIndex := 1 to 16 do
      begin
        CheckUser ;
        If NOT Quit then
          begin
            for count := 1 to 9800 do
              begin
                if f < pminusl then
                  f := f + 1
                else
                  f := 0 ;
                if s < pminusl then
                  s := s + 1
                else
                  s := 0 ;
                ByteTable[f] := ByteTable[f] xor ByteTable[s] ;
              end;  {count loop}
            if BitIndex > 8 then
              begin
                ClrScr ;
                Writeln ;
                Writeln('Loop ',BitIndex) ;
                for count := 0 to pminusl do
                  begin
                    if odd(ByteTable[count]) then
                      WorkTable[count] := (WorkTable[count] div 2) + 128
                    else
                      WorkTable[count] := WorkTable[count] div 2 ;
                    ByteTable[count] := ByteTable[count] div 2 ;
                    PlotXY(count,WorkTable[count]) ;
                  end;  {count loop}
              end ; {BitIndex > 8}
          end ;  {not Quit}
      end ;  {BitIndex loop}
    ClrScr ;
    CenterPrint('Final Byte Table.') ;
    for count := 0 to pminusl do
      begin
        ByteTable[count] := WorkTable[count] ;
        PlotXY(count,ByteTable[count]) ;
      end;  {count loop}
    f := pminusl ;
    s := maxs ;
  end ;  {TauInit}


function RByte : byte ;
  begin
    if f < pminusl then
      f := f + 1
    else
      f := 0 ;
    if s < pminusl then
      s := s + 1
    else
      s := 0 ;
    RByte := ByteTable[f] ;
    ByteTable[f] := ByteTable[f] xor ByteTable[s] ;
  end ;  {RByte}


{main program               [Toad Hall]}
begin
  FillChar(BlankLine,79,chr(32)) ;
  ClrScr ;
  CenterPrint('A Toad Hall Demonstration.') ;
  CenterPrint('of a Tausworthe Pseudorandom Number Generator.') ;
  CenterPrint('as described by Thesen et al.') ;
  Writeln ;
  CenterPrint('Beginning table initialization.') ;
  TauInit(f,s) ;
  ContPrompt ;
  ClrScr ;
  Writeln ;
  CenterPrint('Initialization complete.') ;
  Writeln ;
  for x := 1 to 4 do
    CenterPrint(Selection[x]) ;
  Writeln ;
  Quit  := False ;
  Error := True ;
  repeat
    GoToXY(30,10) ;
    Write('Enter Selection (1-4):  ') ;
    Readln(choice) ;
    if choice in [1..4] then
      Error := False ;
    if choice = 4 then
      Quit := True ;
  until Error = False ;

  If NOT Quit then
    begin
      ClrScr ;
      CenterPrint('Beginning random number generation.') ;
      for prandom := 0 to maxbit do
        RCounter[prandom] := 0 ;

{ This is a screen display so you (human) can see the numbers.  Comment
 this out, and use the next segment if you want clock timing.  Add in your
 own file-related stuff if you want to collect lots of numbers for some sort
 of statistical analysis.  Easy... but YOU can do it!
}

      if choice = 1 then
        repeat
          for y := 5 to 23 do
            begin
              If NOT Quit then
                begin
                  for x := 1 to 16 do
                    begin
                      GoToXY(x * 4,y) ;
                      Write(RByte:4) ;
                    end;  {x}
                  CheckUser ;
                end ;  {NOT Quit}
            end;  {y}
        until Quit = True ;  {choice 1}

{And if you want to do some timing loops - this sucker is FAST!
 Kludge in any system clock you have at the beginning and end of this
 next routine, bring it on line instead of the display one above, and
 do some timing.  On my Z80B CP/M system (Morrow Decision I), wristwatch
 timing looked like 8 or 9 seconds for the 32000 loop.  Prof. Thesen
 reported 8 seconds on an IBM-PC.}

        if choice = 2 then
          begin
            CenterPrint('30 000 random numbers.') ;
            Writeln ;
            CenterPrint('The big hand is pointing to .') ;
            for count := 1 to 32000 do
              prandom := RByte ;
            CenterPrint('The big hand is pointing to .') ;
            for x := 1 to 20 do
              Write(' ') ;
            Write('Completed with count = ',count) ;
            Writeln(', and last number = ',prandom) ;
          end ;  {choice 2}

{
 And if you want a down-and-dirty analysis of random number distribution,
 try this one ...
}

        if choice = 3 then
          repeat
            CheckUser ;
            prandom := RByte ;
            if RCounter[prandom] < maxbit then
              RCounter[prandom] := RCounter[prandom] + 1
            else RCounter[prandom] := 0 ;
            PlotXY(prandom,RCounter[prandom]) ;
          until Quit = True ;  {choice 3}

    end  ;  {not Quit}

  GoToXY(1,23) ;
  Writeln ;
  Writeln ;
  CenterPrint('Terminating.') ;
end.

{
 Algorithms extracted from
 "Some Efficient Random Number Generators for Microcomputers"
 by Arne Thesen, Shanshan Sun and Tzyh-Jong Wang
 Industrial Engineering Department
 University of Wisconsin-Madison

 (Released to the Public Domain by Professor Thesen, 23 April 1985
 (message on file at Toad Hall))

 This is a Tausworthe Generator.  Extracts from Prof. Thesen's paper, the
 implementing demonstration code, and some comments...

 by David Kirschbaum, Toad Hall (ABN.ISCAMS@USC-ISID
 "A Tausworthe generator

 "Tausworthe [5] has suggested a different approach to the generation of
 pseudo-random integers.  This procedure, which operates directly on bits
 to form a stream of random bits, has been shown to produce random number
 sequences that (1) have improved statistical properties over LC [linear
 congruential] generators, and (2) have an arbitrarily long period independent
 of the word size of the computer used.

"Tausworthe generators are not in widespread use.  This could be because they
are difficult to implement efficiently in a higher level language, or because
their improved statistical properties are of marginal utility on larger
computers.  On microcomputers, the situation is quite different.  Here the
improvement in period length and in statistical properties is quite
substantial, and well written Tausworthe generators are not necessarily
more time consuming than other classes of generators.

"Algorithm

The basic procedure of a Tausworthe type generator is illustrated in
Figure 1:

         B[i-p]   B[i-r]     B[i]
   B = . . x . . . . x . . . . x . . . . .
           |         |         |
           +-->xor<--+         |
                |              |
                +--------------+

 "Figure 1: Relationship between bits in a Tausworthe
            generated bit stream.

 "Here B is defined as a sequence of bits, and the relationship between
 individual bits in the sequence is defined in Algorithm 2:

    B[i] = B[i-r]  XOR  B[i-p]

    where:   i   = any integer
         r , p   = fixed integers with 0<r<p.
          XOR    = the exclusive OR operator
                   yielding 0 if the terms are
                   equal and 1 if they are not.

  "Algorithm 2: Tausworthe generator

 "When r and p are properly selected (as primitive trimodals [8]), the maximum
 period of the stream (B) is 2**p - 1.

 "Implementation

 "In Program 3 we present a FORTRAN implementation of the Tausworthe based on
 an idea first proposed by Lewis and Payne [3].  To avoid the need to access
 individual bits, the algorithm maintains 15 independent and parallel streams
 of bits, and the exclusive OR operation is performed on all bits at once.
 Since each of the independent bit streams have a period of 2**p - 1, the
 resulting stream of integers will also have a period of 2**p - 1."

 [Algorithm omitted - Toad Hall]

 "BIBLIOGRAPHY  [segment - Toad Hall]
  ...
  5.  Tausworthe, R.C., Random Numbers Generated by
      Linear Recurrence, Modulo Two, Math. Comp. 19
      (1965) 201-209.

  6.  Thesen, Arne, An Efficient Generator of Uniformly
      Distributed Random Deviates Between Zero and One.
      Technical Report.  Mathematics Research Center,
      University of Wisconsin-Madison, 1983.  To appear
      in Simulation.

  7.  Thesen, Arne and Tzyh-Jong Wang, Some Efficient
      Random Number Generators for Micro Computers.  MRC
      Technical Summary Report #2562.  Mathematics Research
      Center, University of Wisconsin-Madison, 1983.

  8.  Zierler, Niel and John Brillhart, On Primitive
      Trinomials (Mod 2), Information and Control,
      Vol. 13 pp 541-554, 1968."

 Toad Hall Notes

 In the Pascal code from Prof. Thesen et al, a random byte (expressed as a
 integer 0-255) is generated from eight parallel streams of random bits.  It
 uses the xor operator built in to TurboPascal.

 The initial seed values pminusl and s were (I believe) chosen because of
 their long period.  Not fully understanding all this yet, I expect there are
 other suitable seeds (perhaps more of the primitive trimodals referred to in
 the basic paper), or perhaps ANY value between 0 and 97 for pminusl, and any
 lesser value for s?  (Sorry, guys, if my thinking is kind of dumb - I'm no
 mathemetician - just a cut-and-try hacker.)

 Prof. Thesen states the Tausworthe algorithm is not constrained by the word
 size of the computer.  This leads me to believe we might be able to implement
 more than the 8 random bit streams he used in this example, but I expect it
 will impact severely on the code speed.
}
