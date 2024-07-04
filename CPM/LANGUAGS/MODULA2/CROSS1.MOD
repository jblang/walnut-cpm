(* Read a text and generate a cross reference table of all
   words, i.e. sequences of characters that begin with a
   letter and consist of letters and digits only.  Blanks
   ends of lines, and special characters are considered
   to be separators.  Use a binary tree to store the words. *)

MODULE cref;

FROM Terminal IMPORT WriteString, Write, WriteLn;
FROM InOut    IMPORT OpenInput, CloseInput, Done, Read, WriteCard;
FROM Storage  IMPORT ALLOCATE, DEALLOCATE;

CONST c1 = 10;
      c2 = 8;
      c3 = 6;
      c4 = 9999;

TYPE alfa = ARRAY [0..c1] OF CHAR;
     wordref = POINTER TO word;
     itemref = POINTER TO item;
     word = RECORD
              key: alfa;
              first,last: itemref;
              left,right: wordref
            END;
     item = RECORD
              lno: CARDINAL;
              next: itemref
            END;

VAR root: wordref;
    k,k1,n: INTEGER;
    id,a: alfa;
    ch: CHAR;

PROCEDURE compalfa(a,b:alfa):INTEGER;
VAR i,j: INTEGER;

BEGIN
  i := 0;
  j := 0;
  LOOP
    IF CAP(a[i]) < CAP(b[i]) THEN
      j := -1; EXIT
    ELSIF CAP(a[i]) > CAP(b[i]) THEN
      j := 1; EXIT
    ELSE
      INC(i)
    END;
    IF i > c1 THEN EXIT END
  END;
  RETURN j;
END compalfa;

PROCEDURE search(VAR w1: wordref);
VAR w: wordref;
    x: itemref;

BEGIN
  w := w1;
  IF w = NIL THEN
    NEW(w); NEW(x);
    WITH w^ DO
      key := id;
      left := NIL;
      right := NIL;
      first := x;
      last := x
    END;
    x^.lno := n;
    x^.next := NIL;
    w1 := w;
  ELSIF compalfa(id,w^.key) < 0 THEN
    search(w^.left)
  ELSIF compalfa(id,w^.key) > 0 THEN
    search(w^.right)
  ELSE
    NEW(x);
    x^.lno := n;
    x^.next := NIL;
    w^.last^.next := x;
    w^.last := x
  END
END search;

PROCEDURE printtree(w: wordref);

  PROCEDURE printword(w: word);
  VAR l,i: INTEGER;
      x: itemref;

  BEGIN
    Write(' ');
    WriteString(w.key);
    x := w.first;
    l := 0;
    REPEAT
      IF l = c2 THEN
        WriteLn;
        l := 0;
        FOR i := 0 TO c1 DO Write(' ') END
      END;
      INC(l);
      WriteCard(x^.lno,c3);
      x := x^.next
    UNTIL x = NIL;
    WriteLn;
  END printword;

BEGIN
  IF w # NIL THEN
    printtree(w^.left);
    printword(w^);
    printtree(w^.right)
  END
END printtree;

BEGIN
  root := NIL;
  n := 0; k1 := c1;
  Write(14C);
  OpenInput("MOD");
  Read(ch);
  WHILE Done DO
    IF n = c4 THEN n := 0 END;
    INC(n); WriteCard(n,c3);
    Write(' ');Write(ch);
    WHILE (ch # 36C) AND Done DO
      IF (CAP(ch) >= 'A') AND (CAP(ch) <= 'Z')  THEN
        k := 0;
        REPEAT
          IF k < c1 THEN
            a[k] := ch;
            INC(k);
          END;
          Read(ch);
          Write(ch);
        UNTIL NOT((CAP(ch) >= 'A') AND (CAP(ch) <= 'Z')) OR ((ch >= '0') AND (ch <= '9')) AND Done;
        DEC(k);
        IF k >= k1 THEN
          k1 := k
        ELSE
          REPEAT
            a[k1] := ' ';
            DEC(k1);
          UNTIL k1 = k
        END;
        id := a;
        search(root)
      ELSE
        IF ch = '"' THEN
          REPEAT
            Read(ch);
            Write(ch);
          UNTIL ch = '"'
        ELSIF ch = '{' THEN
          REPEAT
            Read(ch);
            Write(ch);
          UNTIL ch = '}'
        END;
        Read(ch);
        Write(ch)
      END
    END;
    Read(ch);
  END;
  Write(14C);
  printtree(root);
  CloseInput;
END cref.
