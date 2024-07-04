{EASYBUFF.PAS ----Easy buffered text output for CP/M Turbo Pascal v.2.00
 By Benjamin Ho
 Evanston, IL
 4/11/86

 Did you ever try to process a text file using this traditional,
 straightforward method of text processing ?

   while not eof(input) do begin
     read (input, ch) ;
     process (ch) ;
     write (output, ch) ;
   end ;

  If so, you've undoubtly heard your disk heads jumping madly between the
  input and output files.  This activity, which is very bad for your drives,
  is caused by Turbo's use of a pitifully small buffer (128 bytes) for
  text output.

  These routines provide a larger, user-selectable buffer for the standard
  procedures write and writeln.  Eliminate fussing with user-written buffering
  procedures which have to be tailored for each program and save your disk
  drives from excessive wear and tear by using these routines.

  Caveats : If your program uses the USR standard device, these routines
            are NOT for you.

  Useage:
    include this file at the beginning of your program.  Set the constant
    ZSIZE to a multiple of 128, and then

  1) Instead of opening your output file with

     var output: text ;
     assign (output, 'filename.ext') ;
     reset (output),

     just call initwrite ('filename.ext').

  2) When output is desired, use writeln (usr,var1,var2...) ;
  3) Instead of close(f), use endwrite.

  Make sure to use endwrite! If you don't, data will be lost!

  These routines work by re-directing USR output to a buffer
  which is automatically written to disk when full.  }

{   Date         : May 8, 1986                                           }
{   Update By    : Ken Isacson                                           }
{   Instructions : Set Max to the maximum nuumber of buffers to be       }
{                  open at one time.  When you call either InitWrite     }
{                  or EndWrite or Writeln(Usr, Var) be sure you have     }
{                  BufferNumber set to the correct buffer number.        }
{                  I.e. File number one gets BufferNumber := 1.          }
{                       File number two gets BufferNumber := 2.          }
{                       etc...                                           }
{   Reason       :  Allows you to have more than just one buffer!        }
{. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . }

const zsize = 4096 ; {default 4K buffer}
      Max   = 1    ; {Maximum number of buffers to be opened at one time}

type outfilename = string [14] ;
var zbuff        : array [1..zsize] of char ;
    zcount,zi    : integer ;
    zf           : file ;
    BufferNumber : Integer; {You need to be setting this accordingly in your
                             Program }

{----------------------------------------------------------}
procedure diskoff ;
{The disk drive motors on Kaypro machines don't always know when to stop
 spinning, so this routine is included to turn them off.}

var i : integer ;
    junk : boolean ;

begin
  for i := 1 to 256 do
    junk := keypressed ;
end ;

{----------------------------------------------------------}
procedure bwrite (ch : char) ;
{This replaces the USROUT routine called by write/ln.  Instead of going
 to the USR device, characters go into a buffer.  When the buffer is
 full, it is automatically written to disk.  Direct bdos calls are
 used to write the buffer because using Blockwrite can't be used.
 Evidently, Turbo has problems when its i/o procedures call each other.}

var i : integer ;

begin
  if zcount[BufferNumber] < zsize then begin  {put char into buffer}
    zcount[BufferNumber] := zcount[BufferNumber] + 1 ;
    zbuff [BufferNumber, zcount[BufferNumber]] := ch ;
  end
  else begin                                             {handle full buffer}
    for i := 1 to zsize div 128 do begin                 {Flush buffer      }
      bdos (26, addr(zbuff[BufferNumber,1])+128*(i-1)) ; {Set dma addr      }
      bdos (21, addr(zf[BufferNumber])+12);              {write 128 bytes   }
    end ;
    DiskOff ;
    for i := 1 to zsize do                               {re-init buffer    }
      zbuff [BufferNumber, i] := #26 ;
    zcount[BufferNumber] := 1 ;                         {reset buffer pointer}
    zbuff [BufferNumber, zcount[BufferNumber]] := ch ;
  end ;
end ;



{----------------------------------------------------------}
procedure initwrite (name: outfilename) ;
{sets up buffer, redirects USR output to buffer, opens output file}

var i :integer ;

begin {initwrite}
  zcount[BufferNumber] := 0 ;        {initialize buffer ptr}
  usroutptr := addr(bwrite) ;        {make our routine the usr routine}
  for i := 1 to zsize do             {initialize buffer}
    zbuff [BufferNumber, i] := #26 ;
  assign (zf[BufferNumber], name) ;  {connect to proper file}
  rewrite (zf[BufferNumber]) ;
end ; {initwrite}

{----------------------------------------------------------}
procedure endwrite ;
{Flushes out any remaining characters in buffer, closes file}

var even : boolean ;
    sec,i : integer ;

begin {endwrite}
  if zcount[BufferNumber] <> 0 then begin    {flush out unwritten buffer}
    even := (zcount[BufferNumber] mod 128 = 0) ;
    if even then sec := zcount[BufferNumber] div 128
      else sec := zcount[BufferNumber] div 128 + 1 ;
    for i := 1 to sec do begin               {flush buffer}
      bdos (26, addr(zbuff[BufferNumber, 1])+128*(i-1)) ;  {set dma addr}
      bdos (21, addr(zf[BufferNumber])+12)                 {write 128 bytes}
    end ;
    DiskOff ;
  end ;
  close (zf[BufferNumber]) ;
end ;   {endwrite}
