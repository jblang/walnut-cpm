(* Insert and delete elements in a B-tree of page size 2n.
   Read a sequence of keys positive values denote insertion,
   negative ones deletion.  Print the resulting B-tree
   after each operation. *)

MODULE btree;

FROM InOut   IMPORT WriteInt, WriteLn, WriteString, ReadInt;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;

CONST n = 2;
      nn = 4; (* page size *)

TYPE ref = POINTER TO page;

     item = RECORD
              key: INTEGER;
              p: ref;
              count: INTEGER
            END;
     page = RECORD
              m: [0..nn];  (* # of items *)
              p0: ref;
              e: ARRAY [1..nn] OF item;
            END;

VAR root,q: ref;
    x,i: INTEGER;
    h: BOOLEAN;
    u: item;

PROCEDURE printtree(p: ref; l: INTEGER);
VAR i: INTEGER;

BEGIN
  IF p # NIL THEN
    WITH p^ DO
      FOR i := 1 TO l DO WriteString('   ') END;
      FOR i := 1 TO m DO WriteInt(e[i].key,4) END;
      WriteLn;
      printtree(p0,l+1);
      FOR i := 1 TO m DO printtree(e[i].p,l+1) END;
    END
  END
END printtree;

PROCEDURE search(x: INTEGER; a: ref; VAR h: BOOLEAN; VAR v: item);
   (* search key x on B-tree with root a; if found, increment counter.  Otherwise
       insert an item with key x and count 1 in tree.  If an item emerges to be
       passed to a lower level, then assign it to v; h := "tree a has become higher" *)
VAR k,l,r: INTEGER;
    q: ref;
    u: item;

  PROCEDURE insert;
  VAR i: INTEGER;
      b: ref;
      
  BEGIN             (* insert u to the right of a^.e[r] *)
    WITH a^ DO
      IF m < nn THEN
        INC(m); h := FALSE;
        FOR i := m TO r+2 BY -1 DO e[i] := e[i-1] END;
        e[r+1] := u
      ELSE          (* page a^ is full; split it and assign the emerging item to v *)
        NEW(b);
        (*FOR i := 1 TO nn DO b^.e[i].p := NIL END;*)
        IF r <= n THEN
          IF r = n THEN
            v := u
          ELSE
            v := e[n];
            FOR i := n TO r+2 BY -1 DO e[i] := e[i-1] END;
            e[r+1] := u
          END;
          FOR i := 1 TO n DO b^.e[i] := a^.e[i+n] END
        ELSE        (* insert u in right page *)
          r := r - n;
          v := e[n+1];
          FOR i := 1 TO r-1 DO b^.e[i] := a^.e[i+n+1] END;
          b^.e[r] := u;
          FOR i := r+1 TO n DO b^.e[i] := a^.e[i+n] END
        END;
        m := n; b^.m := n;
        b^.p0 := v.p; v.p := b
      END
    END
  END insert;

BEGIN    (* search key x on page a^; h = FALSE *)
  IF a = NIL THEN
    h := TRUE;
    WITH v DO      (* item with key x is not in tree *)
      key := x;
      count := 1;
      p := NIL
    END
  ELSE
    WITH a^ DO
      l := 1; r := m;  (* binary array search *)
      REPEAT
        k := (l+r) DIV 2;
        IF x <= e[k].key THEN r := k-1 END;
        IF x >= e[k].key THEN l := k+1 END;
      UNTIL r < l;
      IF l-r > 1 THEN  (* found *)
        INC(e[k].count);
        h := FALSE
      ELSE             (* item is not on this page *)
        IF r = 0 THEN q := p0 ELSE q := e[r].p END;
        search(x,q,h,u);
        IF h THEN insert END
      END
    END
  END
END search;

PROCEDURE delete(x: INTEGER; a: ref; VAR h: BOOLEAN);
    (* search and delete key x in B-tree a; if a page underlow is necessary,
       balance with adjacent page if possible, otherwise merge; h := "page a
       is undersize" *)
VAR i,k,l,r: INTEGER;
    q: ref;

  PROCEDURE underflow(c,a: ref; s: INTEGER; VAR h: BOOLEAN);
      (* a = underflow page, c = ancestor page *)
  VAR b: ref;
      i,k,mb,mc: INTEGER;

  BEGIN
    mc := c^.m;               (* h = TRUE, a^.m := n-1 *)
    IF s < mc THEN
      INC(s);
      b := c^.e[s].p;
      mb := b^.m;
      k := (mb-n+1) DIV 2;    (* k = # of items available on adjacent page b *)
      a^.e[n] := c^.e[s];
      a^.e[n].p := b^.p0;
      IF k > 0 THEN           (* move k items from b to a *)
        FOR i := 1 TO k-1 DO a^.e[i+n] := b^.e[i] END;
        c^.e[s] := b^.e[k];
        c^.e[s].p := b;
        b^.p0 := b^.e[k].p;
        mb := mb - k;
        FOR i := 1 TO mb DO b^.e[i] := b^.e[i+k] END;
        b^.m := mb;
        a^.m := n-1+k;
        h := FALSE
      ELSE                   (* merge pages a and b *)
        FOR i := 1 TO n DO a^.e[i+n] := b^.e[i] END;
        FOR i := s TO mc-1 DO c^.e[i] := c^.e[i+1] END;
        a^.m := nn; c^.m := mc-1;
        DISPOSE(b)
      END
    ELSE                     (* b := page to the left of a *)
      IF s = 1 THEN b := c^.p0 ELSE b := c^.e[s-1].p END;
      mb := b^.m + 1;
      k := (mb-n) DIV 2;
      IF k > 0 THEN          (* move k items from b to a *)
        FOR i := n-1 TO 1 BY -1 DO a^.e[i+k] := a^.e[i] END;
        a^.e[k] := c^.e[s];
        a^.e[k].p := a^.p0;
        mb := mb - k;
        FOR i := k-1 TO 1 BY -1 DO a^.e[i] := b^.e[i+mb] END;
        a^.p0 := b^.e[mb].p;
        c^.e[s] := b^.e[mb];
        c^.e[s].p := a;
        b^.m := mb - 1;
        a^.m := n - 1 + k;
        h := FALSE
      ELSE
        b^.e[mb] := c^.e[s];
        b^.e[mb].p := a^.p0;
        FOR i := 1 TO n-1 DO b^.e[i+mb] := a^.e[i]; END;
        b^.m := nn; c^.m := mc - 1;
        DISPOSE(a)
      END
    END
  END underflow;

  PROCEDURE del(p: ref; VAR h: BOOLEAN);
  VAR q: ref;      (* global a.k *)

  BEGIN
    WITH p^ DO
      q := e[m].p;
      IF q # NIL THEN
        del(q,h);
        IF h THEN underflow(p,q,m,h) END
      ELSE
        p^.e[m].p := a^.e[k].p;
        a^.e[k] := p^.e[m];
        DEC(m); h := m < n;
      END
    END
  END del;

BEGIN
  IF a = NIL THEN
    WriteString('key is not in tree ');
    WriteLn; h := FALSE
  ELSE
    WITH a^ DO
      l := 1; r := m;     (* binary array search *)
      REPEAT
        k := (l+r) DIV 2;
        IF x <= e[k].key THEN r := k-1 END;
        IF x >= e[k].key THEN l := k+1 END
      UNTIL l > r;
      IF r = 0 THEN  q := p0 ELSE  q := e[r].p END;
      IF l-r > 1 THEN
        IF q = NIL THEN
          DEC(m); h := m < n;
          FOR i := k TO m DO e[i] := e[i+1] END;
        ELSE
          del(q,h);
          IF h THEN underflow(a,q,r,h) END
        END
      ELSE
        delete(x,q,h);
        IF h THEN underflow(a,q,r,h) END;
      END
    END
  END
END delete;

BEGIN
  root := NIL;
  LOOP
    WriteString('Enter key> ');
    ReadInt(x);
    IF x = 0 THEN WriteString(' Exiting Enter loop'); WriteLn; EXIT END;
    WriteString(' search key '); WriteInt(x,6); WriteLn;
    search(x,root,h,u);
    IF h THEN
      q := root;
      NEW(root);
      WITH root^ DO
        m := 1;
        p0 := q;
        (*FOR i := 1 TO nn DO e[i].p := NIL END;*)
        e[1] := u
      END
    END;
    printtree(root,1);
  END;
  WriteString(' Key to delete> ');
  ReadInt(x);
  WHILE x # 0 DO
    WriteString(' deleting key '); WriteInt(x,6); WriteLn;
    delete(x,root,h);
    IF h THEN
      IF root^.m = 0 THEN
        q := root;
        root := q^.p0;
        DISPOSE(q)
      END
    END;
    printtree(root,1);
    WriteString(' Key to delete> ');
    ReadInt(x)
  END
END btree.
