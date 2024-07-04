(* A procedure "search" is to locate records with a given key
   in an ordered list.  If the key is not present, then a new
   record is to be inserted so that the ordering of keys is
   maintained.  Use a sentinel at the end of the list. *)

MODULE list;

FROM InOut   IMPORT Write, WriteLn, WriteString, ReadCard, WriteCard;
FROM Storage IMPORT ALLOCATE;

TYPE ref = POINTER TO word;
     word = RECORD
              key: CARDINAL;
              count:CARDINAL;
              next: ref
            END;

VAR k: CARDINAL;
    root,sentinel: ref;

PROCEDURE search(x: CARDINAL; VAR root: ref);
VAR w1,w2,w3: ref;

BEGIN
  w2 := root;
  w1 := w2^.next;
  sentinel^.key := x;
  WHILE w1^.key < x DO
    w2 := w1;
    w1 := w2^.next
  END;
  IF (w1^.key = x) AND (w1 # sentinel) THEN
    INC(w1^.count);
  ELSE
    NEW(w3);  (* insert w3 between w1 and w2 *)
    WITH w3^ DO
      key := x;
      count := 1;
      next := w1
    END;
    w2^.next := w3
  END
END search;

PROCEDURE printlist(w,z: ref);
BEGIN
  WriteString('     Key   Count');
  WriteLn;
  WHILE w # z DO
    WriteCard(w^.key,6);
    WriteCard(w^.count,6);
    w := w^.next; WriteLn
  END
END printlist;

BEGIN
  NEW(root); NEW(sentinel);
  root^.next := sentinel;
  LOOP
    WriteString(' Enter k> ');
    ReadCard(k); WriteLn;
    IF k = 0 THEN EXIT END;
    search(k,root);
  END;
  printlist(root^.next,sentinel)
END list.
