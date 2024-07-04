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
  w1 := root;
  sentinel^.key := x;
  IF w1 = sentinel THEN
    NEW(root);
    WITH root^ DO
      key := x;
      count := 1;
      next := sentinel
    END
  ELSIF w1^.key = x THEN
    INC(w1^.count);
  ELSE
    REPEAT w2 := w1; w1 := w2^.next UNTIL w1^.key =x;
    IF w1 = sentinel THEN
      w2 := root;
      NEW(root);
      WITH root^ DO
        key := x;
        count := 1;
        next := w2
      END
    ELSE
      INC(w1^.count);
      w2^.next := w1^.next;
      w1^.next := root;
      root := w1
    END
  END
END search;

PROCEDURE printlist(w,z: ref);
BEGIN
  WriteString('    Key  Count');
  WriteLn;
  WHILE w # z DO
    WriteCard(w^.key,6);
    WriteCard(w^.count,6);
    w := w^.next; WriteLn
  END
END printlist;

BEGIN
  NEW(sentinel);
  root := sentinel;
  LOOP
    WriteString(' Enter k> ');
    ReadCard(k); WriteLn;
    IF k = 0 THEN EXIT END;
    search(k,root);
  END;
  printlist(root,sentinel)
END list.
