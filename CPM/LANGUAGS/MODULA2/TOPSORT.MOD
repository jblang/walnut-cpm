(* Read a sequence of relations defining a directed, finite
   graph.  Then establish whether or not a partial ordering
   is defined.  If so, print the element in a sequence showing
   the partial ordering. (Topological sorting)  *)

MODULE topsort;

FROM InOut   IMPORT WriteLn, WriteCard, ReadCard, WriteString;
FROM Storage IMPORT ALLOCATE;

TYPE lref = POINTER TO leader;

     tref = POINTER TO trailer;
     
     leader = RECORD
                key: CARDINAL;
                count: CARDINAL;
                trail: tref;
                next: lref;
              END;
     
     trailer = RECORD
                 id: lref;
                 next: tref
               END;

VAR head,tail,p,q: lref;
    t: tref;
    z,x,y: CARDINAL;

PROCEDURE l(w: CARDINAL): lref;
  (* reference fo leader with key w *)
VAR h: lref;

BEGIN
  h := head;
  tail^.key := w;     (* sentinel *)
  WHILE h^.key # w DO h := h^.next END;
  IF h = tail THEN    (* no element with key w in the list *)
    NEW(tail); INC(z);
    h^.count := 0;
    h^.trail := NIL;
    h^.next := tail
  END;
  RETURN h
END l;

BEGIN  (* initialize list of leaders with a dummy *)
  NEW(head); z := 0;
  tail := head;
  LOOP            (* input phase *)
    ReadCard(x);
    IF x = 0 THEN EXIT END;
    ReadCard(y); WriteCard(x,6);
    WriteCard(y,6); WriteLn;
    p := l(x); q := l(y);
    NEW(t); t^.id := q;
    t^.next := p^.trail;
    p^.trail := t;
    INC(q^.count)
  END;
  
(* search for leaders with count = 0 *)
  p := head;
  head := NIL;
  WHILE p # tail DO
    q := p; p := p^.next;
    IF q^.count = 0 THEN
      q^.next := head;
      head := q
    END
  END;
  
(* output phase *)
  q := head;
  WHILE q # NIL DO
    WriteCard(q^.key,6); WriteLn;
    DEC(z);
    t := q^.trail;
    q := q^.next;
    WHILE t # NIL DO
      p := t^.id;
      DEC(p^.count);
      IF p^.count = 0 THEN   (* insert p^ in q-list *)
        p^.next := q;
        q := p
      END;
      t := t^.next
    END
  END;
  IF z # 0 THEN WriteString(' This set is not partially ordered. ') END;
END topsort.
