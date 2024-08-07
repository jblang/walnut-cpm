 (**************************************************************
  *	It was about time I included something for the game freaks
  * so I looked around for something good. The best I could come
  * up with was Othello. Unfortunately it is in UCSD but then I
  * realized that it did not make any difference. It is about time
  * we devoted some time to learning how to convert from UCSD to
  * Z. So that is why I included this program. I want someone to
  * convert it. It also is a good guide to some advanced Pascal 
  * programing.
  *	Othello units:
  *			Othello.pas
  *			Othell1.pas
  *			Othell2.pas
  *			Othellin.pas
  *
  * 	Donated by the now defunct UCSD PASCAL USERS GROUP
  * (To the best of my knowledge this software is to be used only)
  * (for us non-commercials. It was originally donated by a )
  * (Company who thought kindly of us.) 	 
  ***************************************************************)

 (*$S+*)
 (* UCSD Pascal *) PROGRAM OTHELLO; (* Steve Brecher 16-Jun-79 *)
 
 (* The position evaluation weights were derived from a FORTRAN program   *)
 (* headed "from Creative Computing/Klaus E Liebold/4-26-78".             *)
 
 (* This program provides playing instructions to the user on request.    *)
  
 CONST
 (* The game pieces are shown on the screen as 2 rows of 3 characters, e.g. *)
 (*                          OOO                                            *)
 (*                          OOO                                            *)
 (* If your crt has a "block" character (like the cursor on some crts), that*)
 (* is good for the white piece, and capital letter O is good for black,    *)
 (* especially if it has a rectangular shape.  Otherwise, choose characters *)
 (* that are centered within the character dot matrix; try to maximize the  *)
                                                                       (* difference in intensity between the black and white pieces while maxi-  *)
 (* mizing the absolute intensity of the black piece.  Avoid characters with*)
 (* semantic content, e.g. "W" and "B" are not so good.                     *)
 whiteascii = 96;     (*ascii value of char making up piece of first mover*)
 blackascii = 79;     (*  "     "   "   "     "     "    "   " 2nd    "   *)
 minticks   = 22.0;   (*min # clock ticks between crt square updates      *)
                      (*--should be long enough for a distinct, separate  *)
 (*terminal bell sound on each square updated        *)
 spaces     = '                             ';
 
TYPE
 coordinate   = 1..8;
 color        = (white,black);
 squareloc    = RECORD
 CASE onboard: BOOLEAN OF
 TRUE:            (row,col:        coordinate);
 END;
 direction    = (north,south,east,west,sw,ne,se,nw); (*pairs of opposites*)
    squarestatus = RECORD
 CASE occupied: BOOLEAN OF
 TRUE:  (occupier:       color                           );
     FALSE: (adjacentpieces: ARRAY[color] OF SET of direction);
 END;
 gamestatus   = RECORD
 boardstatus:  ARRAY[coordinate,coordinate] OF squarestatus;
 nextmover:    color;
 lastmoveloc:  squareloc;
 score:        ARRAY[color] OF INTEGER;
 END;
    movedesc     = RECORD
 moveloc:            squareloc;
 points:             INTEGER;
 dirsflipped:        SET OF direction;
 4bordrsqsflipped:    INTEGER;
 bordnoncorn:        BOOLEAN;
 END;
 movelist     = RECORD
 movecount:          INTEGER;
 okmove:             ARRAY[1..30] OF movedesc;
 END;
    position     = RECORD
 border:             BOOLEAN;
 corner:             BOOLEAN;
 diagnexttocorner:   BOOLEAN;
 incenter4by4:       BOOLEAN;
 adjacentsq:         ARRAY[direction] OF squareloc;
 (* "special" border squares are those border squares        *)
 (* adjacent to a corner or adjacent to board midline; there *)
 (* are 2 pairs of such squares on each border. Sample pair: *)
                                                                (* (1,2) and (1,4); for each we want a pointer to the other *)
 (* and to the border square between them (1,3).             *)
 CASE specialbordersq: BOOLEAN OF
 TRUE:             (otherofpair,between:  squareloc);
 END;
 

 VAR
 board:                       ARRAY[coordinate,coordinate] OF position;
 status,crtstatus:            gamestatus;
 square:                      squareloc;
 legallist:                   movelist;
 move:                        movedesc;
 opposdir:                    ARRAY[direction] OF direction;
 legalmoves:                  ARRAY[color] OF INTEGER;
 colorword:                   ARRAY[color] OF STRING[5];
 usercolor:                   color;
 lastchange:                  REAL; (*time of last square change on crt*)
 
 (*$I OTHELLINIT*)
 (*$I OTHELL1*)
 (*$I OTHELL2*)

 BEGIN (*PROGRAM OTHELLO*)
 REPEAT
 initgame;
 findlegalmoves(status,legallist);
 legalmoves[white] := legallist.movecount;
 REPEAT
 play(white);
 findlegalmoves(status,legallist);
            legalmoves[black] := legallist.movecount;
 play(black);
 findlegalmoves(status,legallist);
 legalmoves[white] := legallist.movecount;
 UNTIL (legalmoves[white]=0) and (legalmoves[black]=0);
    UNTIL userquits;
 END.
 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       