(* Natural merge sort with 3 files and 2 phases. *)

MODULE mergesort;

FROM InOut       IMPORT Write,WriteCard,WriteString,WriteInt,
                        WriteLn,ReadInt,Read;
FROM FileNames    IMPORT ReadFileName;
FROM FileSystem  IMPORT File,Response,Close,Create,ReadWord,
                        WriteWord,SetPos,GetPos,Reset,SetRead,SetWrite;
FROM ByteBlockIO IMPORT WriteByteBlock,ReadByteBlock;

TYPE item = RECORD 
              key : INTEGER
            END;

VAR f,a,b,c : File;
    n,buf: item;
    FileA,FileB,FileC : ARRAY [0..10] OF CHAR;
    high1,low1,high2,low2 : CARDINAL;
    ch : CHAR;

PROCEDURE list(VAR f: File);
  VAR x: item;
BEGIN
  Reset(f);
  LOOP
    ReadByteBlock(f,x);
    IF f.eof THEN EXIT END;
    WriteInt(x.key,4);
    WriteString('  ');
  END;
  WriteLn
END list; 

PROCEDURE naturalmerge;
  VAR l: INTEGER;  (*no. of runs merged*)
    eor: BOOLEAN; (*end-of-run indicator*)

  PROCEDURE copy(VAR x,y: File);
    VAR buf,next: item;
        high,low : CARDINAL; 
  BEGIN 
    ReadByteBlock(x, buf);
    IF  x.eof THEN
      eor:= TRUE 
    ELSE 
     WriteByteBlock(y,buf);
     GetPos(x,high,low);
     ReadByteBlock(x,next);
     SetPos(x,high,low);
     eor:= buf.key > next.key;
    END
  END copy;

  PROCEDURE copyrun(VAR x,y: File);
  BEGIN (*copy one run from x to y*)
    REPEAT copy(x,y) UNTIL eor
  END copyrun;

  PROCEDURE distribute;
  BEGIN (*from c to a & b*)
    REPEAT
      copyrun (c,a);
      IF NOT c.eof THEN copyrun(c,b) END;
    UNTIL c.eof;
  END distribute;

  PROCEDURE mergerun;
    VAR nexta,nextb : item;
  BEGIN (*from a and b to c*)
    REPEAT
      GetPos(a,high1,low1);
      ReadByteBlock(a,nexta);
      SetPos(a,high1,low1);
      GetPos(b,high2,low2);
      ReadByteBlock(b,nextb);
      SetPos(b,high2,low2);
      IF nexta.key < nextb.key THEN
        copy(a,c);
        IF eor THEN copyrun(b,c) END
      ELSE
       copy(b,c);
       IF eor THEN copyrun (a,c) END
      END
    UNTIL eor
  END mergerun;

  PROCEDURE merge;
  VAR dummy: item;
      high,low: CARDINAL;
      teof: BOOLEAN;

  BEGIN (*from a and b to c*)
    REPEAT mergerun; INC(l)
    UNTIL a.eof OR b.eof;
    GetPos(a,high,low);
    ReadByteBlock(a,dummy);
    teof := a.eof;
    SetPos(a,high,low);
    WHILE NOT teof DO
      copyrun(a,c);
      INC(l);
      teof := a.eof
    END ;
    GetPos(b,high,low);
    ReadByteBlock(b,dummy);
    teof := b.eof;
    SetPos(b,high,low);
    WHILE NOT teof DO
      copyrun (b,c);
      INC(l);
      teof := b.eof
    END;
    list(c)
  END merge;

BEGIN (*naturalmerge*)
  REPEAT 
WriteLn; WriteString('In Loop:');
    Close(a);
    Create(a,'DK.');
    Close(b);
    Create(b,'DK.');
    Reset(c);
    distribute;
    Reset(a);
    Reset(b);
    Reset(c);
    l := 0;
    merge;
  UNTIL l = 1
END naturalmerge;

BEGIN (*main program. read input sequence ending with 0*)
  Create(a,'DK.');
  IF a.res # done THEN WriteString('FileA not opened.') END;
  Create(b,'DK.');
  IF b.res # done THEN WriteString('FileB not opened.') END;
  Create(c,'DK.');
  IF c.res # done THEN WriteString('FileC not opened.') END;
  WriteString('Type in an Integer, exit by typing a 0 -> ');   
  ReadInt(buf.key);
  WriteLn;
  REPEAT
    WriteByteBlock(c,buf);
    WriteString('Type in an Integer, exit by typing a 0 -> ');
    ReadInt(buf.key);
    WriteLn
  UNTIL buf.key = 0;
  list(c);
WriteString('Before naturalmerge'); WriteLn;
  naturalmerge;
WriteString('After naturalmerge'); WriteLn;
  list(c);
  Close(a);
  Close(b);
  Close(c);
END mergesort .
