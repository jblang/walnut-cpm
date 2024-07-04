(* Insertion and deletion in an AVL-balanced tree.  In the
   previous program (tree), the binary tree may grow in all sorts
   of shapes -- if the inserted keys are ordered upon arrival,
   the "tree" even degenerates into a linear list.  In the
   following program, a balance is maintained, such that at
   each node the heights of its two subtree differ by at most 1. *)

MODULE BalTree;
FROM InOut IMPORT WriteString,WriteInt,WriteLn,ReadInt;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;


TYPE  ref = POINTER  TO word;
      word = RECORD 
               key         : INTEGER;
               count       : INTEGER; 
               left ,right : ref;
               bal         : [-1..1]
             END;
VAR root : ref;
    h    : BOOLEAN;
    k    : INTEGER;


(******************************************************)
PROCEDURE printree(w: ref; l: INTEGER);
  VAR  i : INTEGER;
BEGIN
  IF w <> NIL THEN 
     WITH w^ DO
         printree(left, l+1);
         FOR i := 1 TO l DO WriteString("    ") END;
         WriteInt(key,5); WriteInt(bal,5);WriteLn;
         printree(right,l+1);
     END;(*with*);
   END; (*if*)                  
END printree;

(******************************************************)

PROCEDURE search(x: INTEGER; VAR p:ref; VAR h: BOOLEAN);
  VAR  p1,p2: ref;                           (* h = FALSE*)
BEGIN
  IF p = NIL THEN                            (* word is not in tree; insert it *)
    NEW(p); h:= TRUE;
    WITH p^ DO
      key := x; count := 1;
      left := NIL; right := NIL;
      bal := 0 
    END;(*with*)
  ELSIF x < p^.key THEN 
    search(x,p^.left,h);
    IF h THEN                              (* left branch has grown higher *)
      CASE p^.bal OF
          1 : p^.bal:= 0; h:= FALSE;
       |  0 : p^.bal:= -1; 
       | -1 : p1 := p^.left;               (* rebalance *)
              IF p1^.bal = -1 THEN         (* single LL rotation *)
                 p^.left:= p1^.right;
                 p1^.right:= p;
                 p^.bal:= 0; p := p1;
              ELSE                         (* double LR rotation *)
                 p2 := p1^.right;
                 p1^.right:= p2^.left;
                 p2^.left:= p1;
                 p^.left:= p2^.right;
                 p2^.right:= p;
                 IF p2^.bal = -1 THEN p^.bal := +1 ELSE p^.bal:= 0 END;
                 IF p2^.bal = +1 THEN p1^.bal := -1 ELSE p1^.bal:= 0 END;
                 p := p2;
              END; (*if*)
              p^.bal:= 0; h:= FALSE;
       END; (*case*)
    END; (*if*)
  ELSIF x > p^.key THEN 
    search(x,p^.right,h);
    IF h THEN                              (*right branch has grown higher *)
      CASE p^.bal OF
         -1 : p^.bal:= 0; h:= FALSE;
       |  0 : p^.bal:= +1; 
       |  1 : p1 := p^.right;              (* rebalance *)
              IF p1^.bal = +1 THEN         (* single RR rotation *)
                 p^.right:= p1^.left;
                 p1^.left:= p;
                 p^.bal:= 0; p := p1;
              ELSE                         (* double RL rotation *)
                 p2 := p1^.left;
                 p1^.left:= p2^.right;
                 p2^.right:= p1;
                 p^.right:= p2^.left;
                 p2^.left:= p;
                 IF p2^.bal = +1 THEN p^.bal := -1 ELSE p^.bal:= 0 END;
                 IF p2^.bal = -1 THEN p1^.bal := +1 ELSE p1^.bal:= 0 END;
                 p := p2
              END; (*if*)
              p^.bal:= 0; h:= FALSE
       END; (*case*)
    END; (*if*)
  ELSE  INC(p^.count); h:= FALSE
  END; (*if*)
END search;
 
(******************************************************)

PROCEDURE delete(x: INTEGER; VAR p:ref; VAR h: BOOLEAN);
  VAR  q: ref;                           (* h = FALSE*)


  PROCEDURE balance1(VAR p:ref; VAR h: BOOLEAN);
    VAR  p1,p2: ref;
         b1,b2: [-1..+1];
  BEGIN                                  (*h = true, left branch has become less high *)
    CASE p^.bal OF
        -1 : p^.bal:= 0;
       | 0 : p^.bal:= +1; h:= FALSE;       (* rebalance *)
       | 1 : p1:= p^.right;
             b1:= p1^.bal;
             IF b1 >= 0 THEN               (* single RR rotation *)
                p^.right := p1^.left;
                p1^.left:=p;
                IF b1 = 0 THEN 
                   p^.bal:= +1;
                   p1^.bal := -1;
                   h:= FALSE
                ELSE 
                   p^.bal:= 0;
                   p1^.bal:= 0
                END; (*if*)
                p := p1;
             ELSE                         (* double RL rotation *)
                p2 := p1^.left;
                b2 := p2^.bal;
                p1^.left:= p2^.right;
                p2^.right:= p1;
                p^.right:= p2^.left;
                p2^.left:= p;
                IF b2 = +1 THEN p^.bal := -1 ELSE p^.bal:= 0 END;
                IF b2 = -1 THEN p1^.bal := +1 ELSE p1^.bal:= 0 END;
                p := p2;
                p2^.bal := 0;
             END; (*if*)
    END; (*case*)
  END balance1;

  PROCEDURE balance2(VAR p:ref; VAR h: BOOLEAN);
    VAR  p1,p2: ref;
         b1,b2: [-1..+1];
  BEGIN                                  (*h = true, right braanch has become less high *)
    CASE p^.bal OF
         1 : p^.bal:= 0;
      |  0 : p^.bal:= -1; h:= FALSE;       
      | -1 : p1:= p^.left;                (* rebalance *) 
             b1:= p1^.bal;
             IF b1 <= 0 THEN               (* single LL rotation *)
                p^.left:= p1^.right;
                p1^.right:=p;
                IF b1 = 0 THEN 
                   p^.bal:= -1;
                   p1^.bal := +1;
                   h:= FALSE
                ELSE 
                   p^.bal:= 0;
                   p1^.bal:= 0
                END; (*if*)
                p := p1;
             ELSE                         (* double LR rotation *)
                p2 := p1^.right;
                b2 := p2^.bal;
                p1^.right:= p2^.left;
                p2^.left:= p1;
                p^.left:= p2^.right;
                p2^.right:= p;
                IF b2 = -1 THEN p^.bal := +1 ELSE p^.bal:= 0 END;
                IF b2 = +1 THEN p1^.bal := -1 ELSE p1^.bal:= 0 END;
                p := p2;
                p2^.bal := 0;
             END; (*if*)
    END; (*case*)
  END balance2;

  PROCEDURE del(VAR r:ref; VAR h: BOOLEAN);
  BEGIN                                            (* h = false *)
    IF r^.right <> NIL THEN
       del(r^.right,h);
       IF h THEN balance2(r,h) END;
    ELSE
       q^.key := r^.key; 
       q^.count := r^.count;
       r := r^.left;
       h := TRUE;
    END; (*if*)
   END del;

BEGIN (*delete*)
  IF p = NIL THEN 
     WriteString("key is not in tree");WriteLn;
     h := FALSE;
  ELSIF x < p^.key THEN 
     delete(x,p^.left,h);
     IF h THEN balance1(p,h) END; (*if*)
  ELSIF x > p^.key THEN 
     delete(x,p^.right,h);
     IF h THEN balance2(p,h) END; (*if*)
  ELSE (* delete p^*)
     q := p;
     IF q^.right = NIL THEN
        p := q^.left;
        h := TRUE;
     ELSIF q^.left = NIL THEN
        p := q^.right;
        h := TRUE
     ELSE del(q^.left,h);
        IF h THEN balance1(p,h) END; (*if*)
     END; (*if*)
     (*dispose q*)
  END; (*if*)
END delete;

(******************************************************)

BEGIN
 WriteString("enter a 0 to quit and a negative number for deletion"); WriteLn;
 WriteString("enter a node ->  ");
 ReadInt(k); WriteLn;
 root := NIL;
 WHILE k <> 0 DO
    IF k >= 0 THEN
      WriteString("insert"); WriteInt(k,4); WriteLn;
      search(k,root,h);
    ELSE 
      WriteString("delete");WriteInt(-k,4); WriteLn;
      delete(-k,root,h)
    END; (*if*)
    printree(root,0);
    WriteString("enter a node ->  ");
    ReadInt(k); WriteLn;
 END; (*while*)
END BalTree.
