{$C-}
program Unsqueeze;      { unsqueeze file from in_file to out_file }

{ This program unsqueezes a file which has been squeezed or compressed
  to  reduce  the space required to store it on disk.  The program was
  converted from the original  version  written  for  CP/M  in  the  C
  language.   This  program  can be used to unsqueeze files which have
  been downloaded from RCP/M systems where almost all files are  saved
  in this squeezed format.

  The  technique used is the Huffman encoding technique which converts
  the most common characters in the input file  to  a  compressed  bit
  stream  of  data.   This  program  unsqueezes such a Huffman encoded
  file.

  PUBLIC  DOMAIN  -  Feel  free  to  distribute  this program.  Do not
  distribute it by commercial means or make any charge for this pgm.

  Version 1.0  - 09/05/82  Scott Loftesness
  Version 1.1  - 01/06/83  Added capability to strip off parity bit if
                           output file is text. Ernie LeMay 71435,730
  Version 1.2  - 07/20/84  converted to Turbo Pascal. Steve Freeman
  Version 1.3  - 12/30/84  changed file I/O to run on CP/M as well as
                           MS-DOS.  Changed filetypes to 'file' and
                           used blockread/write for file I/O.
                           Jeff Duncan
}


const
    recognize  = $FF76;
    numvals    = 257;      { max tree size + 1 }
    speof      = 256;      { special end of file marker }
    dle: char  = #$90;
    buffersize = 128; (* 128 byte buffer *)

type
    tree       = array [0..255,0..1] of integer;
    hexstr     = string[4];

var
    debug : boolean;
    in_file, out_file: file;
    in_FN: string[30];
    dnode: tree;
    inchar, curin, filecksum, bpos, i, repct, numnodes: integer;
    c, lastchar: char;
    origfile: string[14];
    docfile, eofin, abort: boolean;
    abortM: string[50];
    infilebuffer : array[1..2048] of byte; (* allow for a 2k input buffer *)
    infilepointer : integer; (* pointer into buffer *)
    infilesize : integer;    (* input filesize for buffer loading *)
    inbuffersize : integer;  (* maximum count for buffer pointer *)
    outfilebuffer : array[1..128] of byte; (* output buffer will be minimum *)
    outfilepointer : integer; (* pointer into output buffer *)
    outbuffer_num : integer;  (* how many buffer-fulls used *)

{ iftext -- find out if output file is text and return true if so. EL }
function iftext : boolean;
  var answer: char;
  begin
    repeat
      write('Is the output file a text file?  ');
      read(kbd,answer);
      answer := upcase(answer);
    until (answer in ['Y','N']);
    writeln(answer);
    if answer='Y'
      then iftext:=true
      else iftext:=false;
  end;


function hex(num: integer): hexstr;
  var i, j: integer;
      h: string[16];
      str: hexstr;
  begin
    str := '0000';   h := '0123456789ABCDEF';   j := num;
    for i:=4 downto 1
      do begin
           str[i] := h[(j and 15)+1];
           j := j shr 4;
         end;
    hex := str;
  end;

function getc: integer;

  begin
    if (infilepointer > inbuffersize) and (not eof(in_file)) then
      begin  (* is input buffer empty and more data to follow *)
        if infilesize < 16 then (* less than 2048 bytes left? *)
          begin
            blockread(in_file, infilebuffer, infilesize); (* no get rest *)
            infilepointer := 1;
            inbuffersize := infilesize * 128;
          end
        else
          begin (* full 2048 left so get maximum *)
            blockread(in_file, infilebuffer, 16);
            inbuffersize := 2048;
            infilepointer := 1;
            infilesize := infilesize - 16;
          end;
      end;
    if not ((infilepointer > inbuffersize) and eof(in_file)) then
      begin  (* another character to read  available *)
        getc := infilebuffer[infilepointer];
        infilepointer := infilepointer + 1;
      end;
  end;

{ getw - get a word value from the input file }
function getw: integer;
    var in1,in2: byte;
  begin
    in1 := getc; (* use getc for these to simplify buffer manipulation *)
    in2 := getc;
    getw := ord(in1) + ord(in2) shl 8;
  end;


procedure initialize;
  var str: string[14];
  begin
    abort := false;     { no error conditions presently exist }
    repct:=0;
    bpos:=99;
    origfile:='';
    eofin:=false;
    clrscr;   gotoxy(1,5);   write('Enter the file to unsqueeze:');
    readln(in_FN);
    assign(in_file,in_FN);
    {$I-}
    reset(in_file);
    {$I+}
    if (IOresult = 0) then (* file is found *)
      begin
        inbuffersize := 0; (* dummy for first pass *)
        infilesize := filesize(in_file); (* filesize at initiate *)
        writeln('Input file ', in_fn,' is ',infilesize * 128,' bytes.');
        infilepointer := 1; (* point beyond buffer, so we get data on entry *)
        i := getw;
      end
    else
      i := 0;
    if (recognize <> i)
      then begin
             abort  := true;
             abortM := 'File is not a squeezed file'; (* could be not found also *)
             numnodes := -1;
           end
      else begin
             filecksum := getw;     { get checksum from chars 2 - 3 of file }
             repeat    { build original file name }
                 inchar:=getc;
                 if inchar <> 0
                   then origfile := origfile + chr(inchar);
               until inchar = 0;
             writeln('Original file name is ',origfile);
             write('Output to (return to default) ? ');
             readln(str);
             if length(str)=0 then
               str:=origfile;
             assign(out_file,str);
             rewrite(out_file);
             outfilepointer := 1; (* good idea to start at beginning of buffer *)
             outbuffer_num := 0; (* not neccessary *)
             numnodes:=ord(getw); { get the number of nodes in this files tree }
             if (numnodes<0) or (numnodes>=numvals)
               then begin
                      abort  := true;
                      abortM := 'File has invalid decode tree size';
                    end;
           end;
    if not(abort)
      then begin
             dnode[0,0]:= -(speof+1);
             dnode[0,1]:= -(speof+1);
             numnodes:=numnodes-1;
             for i:=0 to numnodes
               do begin
                    dnode[i,0]:=getw;
                    dnode[i,1]:=getw;
                  end;
             { following is for test }
             {for i:=0 to numnodes
               do writeln(lst,'#',i:3,' ',hex(dnode[i,0]),' ',hex(dnode[i,1]));}
           end;
  end;

procedure dochar(c: char;  text: boolean);
  begin
    if text then
      c:=chr(ord(c) and $7F); {strip off parity bit}
    outfilebuffer[outfilepointer] := ord(c); (* save data in output buffer *)
    outfilepointer := outfilepointer + 1; (* increment the pointer *)
    if outfilepointer > buffersize then
      begin (* we have a full buffer, lets write it out *)
        blockwrite(out_file,outfilebuffer,1);
        outfilepointer := 1; (* reset pinter *)
        outbuffer_num := outbuffer_num + 1;
      end;
  end;

function getuhuff: char;
var i: integer;
  begin
    i:=0;
    repeat
        bpos:=bpos+1;
        if bpos>7 then begin
                         curin := getc;
                         bpos:=0;
                       end
                  else curin := curin shr 1;
        i := ord(dnode[i,ord(curin and $0001)]);
      until (i<0);
    i := -(i+1);
    if i=speof
      then begin
             eofin:=true;
             getuhuff:=chr(26)
           end
      else getuhuff:=chr(i);
  end;

function getcr: char;
var c: char;
  begin
    if (repct>0)
      then begin
             repct:=repct-1;
             getcr:=lastchar;
           end
      else begin
             c:=getuhuff;
             if c<>dle
               then begin
                      getcr:=c;
                      lastchar:=c;
                    end
               else begin
                      repct:=ord(getuhuff);
                      if repct=0 then getcr:=dle
                                 else begin
                                        repct:=repct-2;
                                        getcr:=lastchar;
                                      end;
                    end;
           end;
  end; {getcr}

begin { main }
  debug := true;
  initialize;
  if not(abort)
    then begin
           docfile := iftext;
           writeln(output,'Tree loaded sucessfully. Un-squeezing begins...');
           while not(eof(in_file)) or not(eofin)
             do begin
                  c:=getcr;
                  dochar(c,docfile);
                end;
           if docfile then (* to close the file we have to write the last
                              buffer.  If it's a text file we need to append
                              a ^Z to the buffer before writing.
                           *)
             if outfilepointer <= buffersize then
               outfilebuffer[outfilepointer] := ord(^Z);
           blockwrite(out_file,outfilebuffer, 1);
           close(out_file); (* write last buffer of data *)
         end
    else writeln('Error -- ',AbortM);
  close(in_file);
end.
 then
  