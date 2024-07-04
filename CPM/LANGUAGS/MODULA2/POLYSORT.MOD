(* Polyphase sort program.  There are n-1 source files for
   merging and a single output file.  The destination of the
   merged data chabges, when a certain number of runs has been
   distributed.  This number is computed according to a
   Fibonacci distribution. *)

MODULE polysort;

FROM InOut       IMPORT WriteCard;
FROM Terminal    IMPORT WriteString, WriteLn, Read;
FROM FileSystem  IMPORT File, Lookup, Create, Reset, SetPos, GetPos, Response, Close;
FROM ByteBlockIO IMPORT ReadByteBlock, WriteByteBlock;

CONST n = 6;		(* # of files *)
      numrecs = 10;

TYPE item = RECORD
              key: CARDINAL;
            END;

    tapeno = [1..n];

VAR leng,high,low,rand: CARDINAL;
    eot: BOOLEAN;
    buf,next: item;
    f0: File;
    f: ARRAY [1..n] OF File;
    ch: CHAR;

PROCEDURE list(VAR f: File; n: tapeno);
VAR z: CARDINAL;

BEGIN
  z := 0;
  WriteLn; WriteString(' tape ');
  WriteCard(n,2); WriteLn;
  LOOP
    ReadByteBlock(f,buf);
    IF f.eof THEN EXIT END;
    WriteCard(buf.key,5);
    INC(z);
    IF z = 15 THEN WriteLn; z := 0 END
  END;
  WriteLn;
  Reset(f)
END list;


PROCEDURE polyphasesort;
VAR i,j,mx,tn,dn,x,min,z: CARDINAL(* tapeno *);
    k,level:CARDINAL;
    a,d,last,t,ta: ARRAY tapeno OF CARDINAL;
      (* a[j] = ideal # of runs on file j *)
      (* d[j] = # of dummy runs on file *)
      (* last[j] = key of tail item on tape *)
      (* t,ta = mappings of tape #'s *)

  PROCEDURE selectfile;
  VAR i: tapeno;
      z: CARDINAL;

  BEGIN
    IF d[j] < d[j+1] THEN
      INC(j)
    ELSE
      IF d[j] = 0 THEN
        INC(level); z := a[1];
        FOR i := 1 TO n-1 DO
          d[i] := z + a[i+1] - a[i];
          a[i] := z + a[i+1]
        END
      END;
      j := 1
    END;
    DEC(d[j]);
  END selectfile;  
  
  PROCEDURE copyrun;
  VAR buf,next: item;
      high,low : CARDINAL; 

  BEGIN (*copy one run from x to y*)
    ReadByteBlock(f0,next);
    REPEAT
      buf := next;
      IF NOT f0.eof THEN
        WriteByteBlock(f[j],buf);
        GetPos(f0,high,low);
        ReadByteBlock(f0,next);
      END;
    UNTIL f0.eof OR (buf.key > next.key);
    IF NOT f0.eof THEN SetPos(f0,high,low) END;
    last[j] := buf.key
  END copyrun;

BEGIN  (* polyphasesort *)
  FOR i := 1 TO n(* -1 *) DO
    a[i] := 1; d[i] := 1;
    Create(f[i],'DK.')
  END;
  level := 1; j := 1;
  a[n] := 0; d[n] := 0;
  REPEAT
    selectfile;
    copyrun;
  UNTIL f0.eof OR (j = n-1);
  LOOP
    IF f0.eof THEN EXIT END;
    selectfile;
    GetPos(f0,high,low);
    ReadByteBlock(f0,next);
    SetPos(f0,high,low);
    IF last[j] <= next.key THEN
      copyrun;
      IF f0.eof THEN d[j] := d[j]+1 ELSE copyrun END
    ELSE copyrun
    END
  END;
  FOR i := 1 TO n-1 DO Reset(f[i]) END;

  FOR i := 1 TO n DO t[i] := i END;
  REPEAT
    z := a[n-1]; d[n] := 0;
    Close(f[t[n]]); Create(f[t[n]],'DK.');
    WriteString(' level'); WriteCard(level,4); WriteLn;
    WriteString(' tape'); WriteCard(t[n],4); WriteLn;
    FOR i := 1 TO n DO
      WriteCard(t[i],6);
      WriteCard(a[i],6);
      WriteCard(d[i],6);
      WriteLn
    END;
    REPEAT
      k := 0;
      FOR i := 1 TO n-1 DO
        IF d[i] > 0 THEN
          DEC(d[i])
        ELSE
          INC(k);
          ta[k] := t[i]
        END
      END;
      IF k = 0 THEN
        INC(d[n])
      ELSE
        REPEAT
          i := 1; mx := 1;
          GetPos(f[ta[1]],high,low);
          ReadByteBlock(f[ta[1]],next);
          SetPos(f[ta[1]],high,low);
          min := next.key;
          WHILE i < k DO
            INC(i);
            GetPos(f[ta[i]],high,low);
            ReadByteBlock(f[ta[i]],next);
            SetPos(f[ta[i]],high,low);
            x := next.key;
            IF x < min THEN
              min := x;
              mx := i
            END
          END;
          (* ta[mx] has minimal element, move it to t[j] *)
          ReadByteBlock(f[ta[mx]],buf);
          WriteByteBlock(f[t[n]],buf);
          GetPos(f[ta[mx]],high,low);
          ReadByteBlock(f[ta[mx]],next);
          eot := f[ta[mx]].eof;
          SetPos(f[ta[mx]],high,low);
          IF (buf.key > next.key) OR eot THEN
            ta[mx] := ta[k];
            DEC(k)
          END
        UNTIL k = 0;
      END;
      DEC(z);
    UNTIL z = 0;
    Reset(f[t[n]]);
    list(f[t[n]],t[n]);
    tn := t[n];
    dn := d[n];
    z := a[n-1];
    FOR i := n TO 2 BY -1 DO
      t[i] := t[i-1];
      d[i] := d[i-1];
      a[i] := a[i-1] - z
    END;
    t[1] := tn;
    d[1] := dn;
    a[1] := z;
    DEC(level)
  UNTIL level = 0;
END polyphasesort;

BEGIN
  leng := numrecs;
  Lookup(f0,'tmp.TEXT',TRUE);
  IF f0.res # done THEN WriteString(' File not opened. ') END;
  REPEAT
    buf.key := leng;
    WriteCard(buf.key,4);
    WriteByteBlock(f0,buf);
    DEC(leng);
    IF (leng MOD 20) = 0 THEN WriteLn END;
  UNTIL leng = 0;
  WriteLn;
  Reset(f0); list(f0,1);
  polyphasesort;
  FOR low := 1 TO n-1 DO Close(f[low]) END;
END  polysort.
