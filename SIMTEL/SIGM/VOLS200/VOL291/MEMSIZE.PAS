



program MemSiz;


  {MEMSIZ.PAS #1.04 85-07-16
              DEMONSTRATE ADJUSTMENT TO SIZE OF CP/M-80 SYSTEM

      V01 L04  updated 85-07-16 by DEH to use tidier parameter settings.
          L01  created on 85-07-10 by Dennis E. Hamilton to report on CP/M-
               80 TPA memory usage on the system being used.}



const

  ProgramTop = $3000; {<<<< MUST AGREE WITH COMPILER E-OPTION VALUE <<<<}
                   {Recompile the program repeatedly,  varying the E-Option
                    (for  compiling to .COM) to the least hexadecimal value
                    that compiles successfully.   Then insert that value as
                    ProgramTop and recompile with that setting. }

   StackSize = $0400;



var       CO: text;
              {File used to receive the program's report}


procedure

   HexWord(v: integer);

   procedure HexByte(b: byte);

      procedure HexNibble(n: byte);
         const hexes:string[16] = '0123456789ABCDEF';
         begin {display hex code for low-order 4 bits of n}
         write(CO, hexes[succ(n and $0f)] );
         end {HexNibble};

      begin {display the two hex codes for the byte value b}
      HexNibble(b shr 4); HexNibble(b);
      end {HexByte};

   begin {HexWord display of 16-bit value in Hexadecimal code}
   write(CO, '$'); HexByte(Hi(v)); HexByte(Lo(v));
   end {HexWord};


procedure uint(i: integer);

   begin {show unsigned value in 6-byte field}
   if i < 0
   then Write(CO, 65535.0+succ(i) :6:0)
   else Write(CO, i :6);
   end {uint};


                                                                   { . . . }
{MEMSIZ.PAS 1.04: 85-07-16                                            page 2}


procedure ubytes(u: integer);

   begin {show byte count in both decimal and hex}
   uint(u); write(CO, '-byte ('); HexWord(u); write(CO, ') ');
   end {ubytes};


procedure indent;

   begin write(CO, '        '); end {indent 8 spaces};



var     HP: ^byte;
            {Derived HeapPtr starter value}

     BDOSE: integer absolute $0006;
              {holding  the address for the CP/M system's  currently-lowest
               point in memory}


BEGIN {MEMSIZ}

{Switch to CP/M-80 dynamic Free Zone: }
  if ParamCount = 0
  then begin
       StackPtr := BDOSE;
       RecurPtr := StackPtr - StackSize;
       HP := ptr(ProgramTop); {V01 L03}
       Release(HP);
       end {conditional initialization};


assign(CO, 'CON:'); {#1.01; #1.00 used 'MEMSIZ.DAT'}
  rewrite(CO); {Direct output to suitable file or device.}


{Tell the folks who we are: }
  writeln(CO, 'MEMSIZ> #1.04 85-07-16 CPM-80 DYNAMIC MEMORY REPORT');
  writeln(CO);


{Show key memory-management pointer values: }
  indent; HexWord(BDOSE); writeln(CO, ' current CP/M base');
  indent; HexWord(StackPtr-1); writeln(CO, ' Stack ceiling');
  indent; HexWord(RecurPtr-1); writeln(CO, ' Heap ceiling');
  indent; HexWord(HeapPtr); writeln(CO, ' Heap base');


{Describe the Free Zone & MemAvail for dynamic use right now: }
  indent; indent; ubytes(StackPtr-HeapPtr); writeln(CO, 'Free Zone');
  indent; indent; ubytes(MemAvail); writeln(CO, 'MemAvail');


{Describe the area used for program and data: }
  indent; HexWord(ProgramTop-1); writeln(CO, ' program end address');
  indent; HexWord(addr(HP));  writeln(CO, ' program data area');
  indent; HexWord($0100); writeln(CO, ' program base address');

                                                                   { . . . }
{MEMSIZ.PAS 1.04: 85-07-16                                            page 3}


{Comment on amount used versus amount available: }
  indent; indent; ubytes(BDOSE - $0100);
    writeln(CO, 'TPA capacity');
  indent; indent;
    if ParamCount = 0
    then ubytes(StackPtr - $0100)
    else ubytes(ProgramTop - $0100); {V01 L03}
    writeln(CO, 'TPA taken');


writeln(CO);


{Explain which variation is being seen: }

  if ParamCount = 0

  then begin
       writeln(CO, ' This memory mapping is obtained after establishing');
       writeln(CO, ' a dynamic Free Zone.  Program data is kept safe at');
       writeln(CO, ' low addresses, with the Free Zone allowed to claim');
       writeln(CO, ' all higher memory left over below CP/M.  To see a');
       writeln(CO, ' typical static allocation, use a command-line such');
       writeln(CO, ' as');
       writeln(CO, '               B0>MEMSIZ STATIC');
       end

  else begin
       writeln(CO, ' This is a standard compiler-determined allocation,');
       writeln(CO, ' using the default or option-selected program end-');
       writeln(CO, ' address as the highest-used location.  The program');
       writeln(CO, ' data area sits above the stack and heap area.  If');
       writeln(CO, ' a low end address is not specified by the user, it');
       writeln(CO, ' is possible to overlay the CP/M system with values');
       writeln(CO, ' of program variables.');
       end;


close(CO);

END. {MEMSIZ.PAS}
e CP/M system with values');
       writeln