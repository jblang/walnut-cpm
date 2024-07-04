(* This program initializes an array and performs
   various different sorts. *)

MODULE Sort;
FROM InOut IMPORT Write,WriteLn,WriteCard,WriteInt,Read,WriteString;


CONST n= 256;
      nn=512;

TYPE index =[0..nn];
     item = RECORD
              key : INTEGER;
            END;
VAR i : index;
    r : INTEGER;
    a : ARRAY [-15..nn] OF item;
    z : ARRAY [1..n] OF INTEGER;
    Ch: CHAR;

PROCEDURE BubbleSort;
VAR i,j : index;
    x : item;
 
BEGIN
  FOR i := 2 TO n DO
    FOR j := n TO i BY -1 DO
      IF a[j-1].key > a[j].key THEN
        x := a[j-1];
        a[j-1] := a[j];
        a[j] := x;
      END
    END
  END
END BubbleSort;

PROCEDURE Bubblex;
VAR j,k,l : index;
    x : item;

BEGIN
  l := 2;
  REPEAT
    k := n;
    FOR j := n TO l BY -1 DO
      IF a[j-1].key > a[j].key THEN
        x := a[j-1]; a[j-1] := a[j]; a[j] := x;
        k := j
      END
    END;
  l := k + 1;
  UNTIL l > n
END Bubblex;

PROCEDURE ShakerSort;
VAR j,k,l,r : index;
    x : item;

BEGIN
  l := 2; r := n; k := n;
  REPEAT
    FOR j := n TO l BY -1 DO
      IF a[j-1].key > a[j].key THEN
        x := a[j-1];
        a[j-1] := a[j];
        a[j] := x;
        k :=j
      END
    END;
    l := k + 1;
    FOR j := l TO r DO
      IF a[j-1].key > a[j].key THEN
        x := a[j-1];
        a[j-1] := a[j];
        a[j] := x;
        k :=j
      END
    END;
    r := k - 1;
  UNTIL l > r
END ShakerSort;

PROCEDURE QuickSort;

  PROCEDURE sort(l,r:index);
  VAR i,j : index;
      x,w : item;
  BEGIN
    i := l; j :=r;
    x := a[(l + r) DIV 2];
    REPEAT
      WHILE a[i].key < x.key DO INC(i) END;
      WHILE x.key < a[j].key DO DEC(j) END;
      IF i <= j THEN
        w := a[i];
        a[i] := a[j];
        a[j] := w;
        INC(i);
        DEC(j);
      END;
    UNTIL i > j;
    IF l < j THEN sort(l,j) END;
    IF i < r THEN sort(i,r) END;
  END sort;
BEGIN
  sort(1,n)
END QuickSort;
 
PROCEDURE QuickSort1;
CONST m = 12;
TYPE  ss = [0..m];
VAR i,j,l,r : index;
    x,w : item;
    s : ss;
    stack : ARRAY [1..m] OF RECORD l,r : index END;
BEGIN
  s := 1; stack[1].l := 1; stack[1].r := n;
  REPEAT
    l := stack[s].l; r := stack[s].r; DEC(s);
    REPEAT
      i := l; j := r; x := a[(l + r) DIV 2]; 
      REPEAT
        WHILE a[i].key < x.key DO INC(i) END;
        WHILE x.key < a[j].key DO DEC(j) END;
        IF i <= j THEN
          w := a[i]; a[i] := a[j]; a[j] := w;
          INC(i);DEC(j);
        END;
      UNTIL i > j;
      IF i < r THEN
        INC(s); stack[s].l := i; stack[s].r := r;
      END;
      r := j
    UNTIL l >=r
  UNTIL s = 0
END QuickSort1;

BEGIN (*Main*)
  i := 0;
  r :=54;
  REPEAT
    INC(i);
    r := (8 * r) MOD 2141;
    z[i] :=r;
  UNTIL i = n;
  FOR i := 1 TO n DO 
    a[i].key := z[i];
  END;
  BubbleSort;
  FOR i := 1 TO n DO 
    WriteString("Changed BubbleSort-> ");
    WriteInt(a[i].key,3);
    WriteLn;
  END;
  WriteLn;
  Read(Ch);
  FOR i := 1 TO n DO 
    a[i].key := z[i];
  END;
  QuickSort;
  FOR i := 1 TO n DO 
    WriteString("Changed QuickSort-> ");
    WriteInt(a[i].key,3);
    WriteLn;
  END;
  WriteLn;
  Read(Ch);
  FOR i := 1 TO n DO 
    a[i].key := z[i];
  END;
  QuickSort1;
  FOR i := 1 TO n DO 
    WriteString("Changed QuickSort1-> ");
    WriteInt(a[i].key,3);
    WriteLn;
  END;
  WriteLn;
  Read(Ch);
  FOR i := 1 TO n DO 
    a[i].key := z[i];
  END;
  Bubblex;
  FOR i := 1 TO n DO 
    WriteString("Changed Bubblex-> ");
    WriteInt(a[i].key,3);
    WriteLn;
  END;
  WriteLn;
  Read(Ch);
  FOR i := 1 TO n DO 
    a[i].key := z[i];
  END;
  ShakerSort;
  FOR i := 1 TO n DO 
    WriteString("Changed ShakerSort-> ");
    WriteInt(a[i].key,3);
    WriteLn;
  END;
  WriteLn;
END Sort.
