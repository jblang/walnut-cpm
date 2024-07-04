(* Insertion and deletion in a binary tree.  Read a sequence
   of integers.  A positive integer signifies that it should
   be inserted in an ordered binary tree as the key of a node.
   A negative integer signifies that a node with its absolute
   value as key should be searched and deleted. *)

MODULE tree;

FROM Storage  IMPORT ALLOCATE;
FROM InOut IMPORT WriteString, WriteCard, WriteLn, ReadInt, WriteInt;

TYPE ref = POINTER TO word;
     word = RECORD
            key : CARDINAL;
            count : CARDINAL;
            left, right : ref;
            END;

VAR root : ref;
    k : INTEGER;

PROCEDURE printTree(w : ref; l : CARDINAL);
VAR i : CARDINAL;
BEGIN
  IF w # NIL THEN
    WITH w^ DO
      printTree(left, l+1);
      FOR i := 1 TO l DO
        WriteString("   ");
      END;
      WriteCard(key,6);
      WriteLn;
      printTree(right, l+1);
    END; (* with *)
  END; (* if *)
END printTree;

PROCEDURE search(x : CARDINAL; VAR p : ref);
BEGIN
  IF p = NIL THEN (* word is not in tree; insert it *)
  NEW(p);
  WITH p^ DO
   key := x;
   count := 1;
   left := NIL;
   right := NIL;
  END; (* with *)
  ELSIF x<p^.key THEN search(x, p^.left)
  ELSIF x > p^.key THEN search(x,p^.right)
  ELSE p^.count := p^.count + 1;
  END;
END search;

PROCEDURE delete(x : CARDINAL; VAR p : ref);
VAR q : ref;
  PROCEDURE del(VAR r : ref);
  BEGIN
    IF r^.right # NIL THEN
     del(r^.right)
    ELSE
     q^.key := r^.key; 
     q^.count := r^.count;
     q := r;
     r := r^.left;
    END;
  END del;

BEGIN (* delete *)
  IF p = NIL THEN
    WriteString(" word is not in tree");
    WriteLn;
  ELSIF x < p^.key THEN delete(x, p^.left)
  ELSIF x > p^.key THEN delete(x,p^.right)
  ELSE
    q := p;
    IF q^.right = NIL THEN p := q^.left
    ELSIF q^.left = NIL THEN p := q^.right
    ELSE del(q^.left);
    END;
  END;
END delete;

BEGIN (*main*)
  root := NIL;
  ReadInt(k);
  WHILE k # 0 DO
   IF k > 0 THEN
     WriteString(" insert");
     WriteInt(k,6);
     search(k,root);
   ELSE
     WriteString(" delete");
     WriteInt(0-k,6);
     delete(CARDINAL(0-k), root);
   END;
   printTree(root,0);
   ReadInt(k);
  END; (*while *)
END tree.

