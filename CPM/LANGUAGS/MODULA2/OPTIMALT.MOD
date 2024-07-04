(* Find the optimally structured binary search tree for n keys.
   Known are the search frequencies of the keys, b[i] for key[i],
   and the frequencies of searches with arguments that are not
   keys (represented in the tree).  a[i] is the frequency of an
   argument lying between key[i-1] and key[i].  Use Knuth's
   algorithm, "Acta informatica" 1, 1, 14-25 (1971).  The
   following example uses Modula keywords as keys. *)

MODULE optimaltree;

FROM InOut     IMPORT Read, Write, WriteLn, WriteString, WriteCard, OpenInput, Done;
FROM RealInOut IMPORT WriteReal;
FROM Storage   IMPORT ALLOCATE, DEALLOCATE;
IMPORT Terminal;

CONST n = 29;       (* # of keys *)
      kln = 9;     (* max key length *)

TYPE index = [0..n];
     alfa = ARRAY [0..kln] OF CHAR;

VAR ch,tch: CHAR;
    k1,k2,i,j,k: CARDINAL;
    id,buf: alfa;
    key: ARRAY [1..n] OF alfa;
    a: ARRAY index OF CARDINAL;
    b: ARRAY index OF CARDINAL;
    p,w: ARRAY index,index OF CARDINAL;
    r: ARRAY index,index OF index;
    suma,sumb: CARDINAL;

PROCEDURE balltree(i,j: index): CARDINAL;
VAR k,tmp: CARDINAL;

BEGIN
  k := (i+j+1) DIV 2;
  r[i,j] := k;
  IF i >= j THEN
    tmp := b[k]
  ELSE
    tmp := balltree(i,k-1) + balltree(k,j) + w[i,j]
  END;
  RETURN tmp
END balltree;

PROCEDURE copystring(VAR from,to: alfa);
VAR i: CARDINAL;

BEGIN
  FOR i := 0 TO kln DO
    to[i] := from[i]
  END
END copystring;

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
    IF i > kln THEN EXIT END
  END;
  RETURN j;
END compalfa;

PROCEDURE opttree;
VAR x,min: CARDINAL;
    i,j,k,h,m: index;

BEGIN
  j := 0;
  FOR i := 0 TO n DO p[i,i] := w[i,i] END;    (* width of tree h = 0 *)
  FOR i := 0 TO n-1 DO
    INC(j);
    p[i,j] := p[i,i] + p[j,j];
    r[i,j] := j
  END;
  FOR h := 2 TO n DO
    FOR i := 0 TO n-h DO
      j := i + h;
      m := r[i,j-1];
      min := p[i,m-1] + p[m,j];
      FOR k := m+1 TO r[i+1,j] DO
        x := p[i,k-1] + p[k,j];
        IF x < min THEN
          m := k;
          min := x
        END
      END;
      p[i,j] := min + w[i,j];
      r[i,j] := m
    END
  END
END opttree;

PROCEDURE printtree;
CONST lw = 120;

TYPE ref = POINTER TO node;
     lineposition = [0..lw];
     node = RECORD
              key: alfa;
              pos: lineposition;
              left,right,link: ref
            END;
            
VAR q,q1,q2,root,current,next: ref;
    i,k: CARDINAL;
    u,u1,u2,u3,u4: lineposition;

  PROCEDURE tree(i,j: index): ref;
  VAR p: ref;

  BEGIN
    IF i = j THEN
      p := NIL
    ELSE
      NEW(p);
      p^.left := tree(i,r[i,j]-1);
      p^.pos := TRUNC((FLOAT(lw)-FLOAT(kln))*FLOAT(k)/FLOAT(n-1)) + (kln DIV 2);
      INC(k);
      p^.key := key[r[i,j]];
      p^.right := tree(r[i,j],j)
    END;
    RETURN p
  END tree;

BEGIN
  k := 0; root := tree(0,n);
  current := root;
  root^.link := NIL;
  next := NIL;
  WHILE current # NIL DO
    FOR i := 1 TO 3 DO
       q := current;
      REPEAT u := 0;
        u1 := q^.pos;
        REPEAT
          Write(' ');
          INC(u)
        UNTIL u = u1;
        Write(':'); INC(u);
        q := q^.link
      UNTIL q = NIL;
      WriteLn;
    END;
        (* now print master line; descending from nodes on current list collect
           their descendants and form next list *)
    q := current; u := 0;
    REPEAT
      copystring(q^.key,buf);
          (* center key about pos *)
      i := kln;
      WHILE buf[i] = ' ' DO DEC(i) END;
      u2 := q^.pos - ((i-1) DIV 2);
      u3 := u2 + i + 1;
      q1 := q^.left; q2 := q^.right;
      IF q1 = NIL THEN
        u1 := u2
      ELSE
        u1 := q1^.pos;
        q1^.link := next;
        next := q1
      END;
      IF q2 = NIL THEN
        u4 := u3
      ELSE
        u4 := q2^.pos + 1;
        q2^.link := next;
        next := q2
      END;
      i := 0;
      WHILE u < u1 DO Write(' '); INC(u); END;
      WHILE u < u2 DO Write('-'); INC(u); END;
      WHILE u < u3 DO Write(buf[i]); INC(i); INC(u); END;
      WHILE u < u4 DO Write('-'); INC(u); END;
      q := q^.link
    UNTIL q = NIL;
    WriteLn;
        (* now invert next list AND make it current list *)
    current := NIL;
    WHILE next # NIL DO
      q := next;
      next := q^.link;
      q^.link := current;
      current := q
    END
  END
END printtree;

BEGIN    (* initialize table of keys and counters *)
  OpenInput('MOD');
  key[ 1] := "ARRAY     ";     key[ 2] := "BEGIN     ";     key[ 3] := "BY        ";
  key[ 4] := "CASE      ";     key[ 5] := "CONST     ";     key[ 6] := "DIV       ";
  key[ 7] := "DO        ";     key[ 8] := "ELSE      ";     key[ 9] := "END       ";
  key[10] := "FOR       ";     key[11] := "FROM      ";     key[12] := "IF        ";
  key[13] := "IMPORT    ";     key[14] := "IN        ";     key[15] := "MOD       ";
  key[16] := "MODULE    ";     key[17] := "NIL       ";     key[18] := "OF        ";
  key[19] := "PROCEDURE ";     key[20] := "RECORD    ";     key[21] := "REPEAT    ";
  key[22] := "SET       ";     key[23] := "THEN      ";     key[24] := "TO        ";
  key[25] := "TYPE      ";     key[26] := "UNTIL     ";     key[27] := "VAR       ";
  key[28] := "WHILE     ";     key[29] := "WITH      ";
  FOR i := 1 TO n DO
    a[i] := 0;
    b[i] := 0
  END;
  FOR i := 1 TO n DO
    FOR j := 1 TO n DO
      w[i,j] := 0
    END
  END;
  b[0] := 0;
  k2 := kln;
      (* scan input text and determine a and b *)
  LOOP
    Read(ch);
    IF NOT Done THEN EXIT END;
    IF (CAP(ch) >= 'A') AND (CAP(ch) <= 'Z') THEN
      k1 := 0;
      REPEAT
        IF k1 <= kln THEN
          buf[k1] := ch;
          INC(k1);
        END;
        Read(ch)
      UNTIL NOT (((CAP(ch) >= 'A')AND(CAP(ch) <= 'Z')) OR ((ch >= '0')AND(ch <= '9')));
      DEC(k1);
      IF k1 >= k2 THEN
        k2 := k1
      ELSE
        REPEAT
          buf[k2] := ' ';
          DEC(k2)
        UNTIL k2 = k1
      END;
      copystring(buf,id);
      i := 1; j := n;
      REPEAT
        k := (i+j) DIV 2;
        IF compalfa(key[k],id) <= 0 THEN i := k+1 END;
        IF compalfa(key[k],id) >= 0 THEN j := k-1 END
      UNTIL i > j;
      IF compalfa(key[k],id) = 0 THEN
        INC(a[k])
      ELSE
        k := (i+j) DIV 2;
        INC(b[k])
      END
    ELSIF ch = '"' THEN
      REPEAT Read(ch) UNTIL ch = '"'
    END
  END;
  WriteString(' keys and frequencies of occurrence: ');
  WriteLn;
  suma := 0; sumb := 0;
  FOR i := 1 TO n DO
    suma := suma + a[i];
    sumb := sumb + b[i];
    WriteCard(b[i-1],6); WriteCard(a[i],6);
    Write(' '); WriteString(key[i]);
    WriteLn
  END;
  
  WriteCard(b[n],6); WriteLn;
  WriteString('  ------  ------'); WriteLn;
  WriteCard(suma,6); WriteCard(sumb,6);
  WriteLn;

      (* compute w from a and b *)
  FOR i := 0 TO n DO
    w[i,i] := b[i];
    FOR j := i+1 TO n DO w[i,j] := w[i,j-1] + a[j] + b[j] END
  END;
  WriteLn;
  WriteString(' average path length of balanced tree = ');
  WriteReal(FLOAT(balltree(0,n))/FLOAT(w[0,n]),6);
  printtree;
  WriteLn;
  
  opttree;
  WriteLn;
  WriteString(' average path length of optimal tree = ');
  WriteReal(FLOAT(p[0,n])/FLOAT(w[0,n]),6);
  printtree;
  WriteLn;
  
      (* now considering keys only, setting b = 0 *)
  FOR i := 0 TO n DO
    w[i,i] := 0;
    FOR j := i+1 TO n DO w[i,j] := w[i,j-1] + a[j] END
  END;
  opttree;
  WriteLn;
  WriteString(' optimal tree considering keys only ');
  printtree;
END optimaltree.
