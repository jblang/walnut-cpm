(************************************************************************)
(*       Requires MRI Modula2                                           *)
(*       From JOURNAL OF PASCAL, ADA AND MODULA2                        *)
(*                                                                      *)
(*        Strlib:                                                       *)
(*               Library module to handle strings.  Included is         *)
(*               terminal I/O, string length, assignment, conc-         *)
(*               atention, insertion, deletion, alteration and          *)
(*               the ability to select portions of a string.            *)
(*                                                                      *)
(*       Verson :                                                       *)
(*               1.0 ; November 16, 83 ;   Namir C. Shammas             *)
(*               1.1 ; November 21, 84 ;   Walter Maner                 *)
(*                                                                      *)
(************************************************************************)
 
 
IMPLEMENTATION MODULE Strlib;
 
FROM Terminal IMPORT WriteString,WriteLn,Write,Read;
FROM InOut IMPORT ReadCard,WriteCard;
 
PROCEDURE Len(Str : ARRAY OF CHAR):CARDINAL;
 
(* Returns the length of the string *)
 
VAR  i : CARDINAL;
 Found : BOOLEAN;
BEGIN
    i := 0; Found :=FALSE;
 
(* Scan the string until the eos is found *)
 
    WHILE (NOT Found) AND (i <= HIGH(Str)) DO
        IF Str[i] = eos THEN Found := TRUE 
                        ELSE INC(i)
        END;
    END;
    RETURN i
END Len;
 
PROCEDURE StringIs (VAR Str1 : ARRAY OF CHAR; Str2 : ARRAY OF CHAR);
 
(* Procedure will assign string Str2 to string Str1 *)
 
VAR 
   i,long1,long2 : CARDINAL;
BEGIN
 
(* Obtain the length of both strings Str1 & Str2 *)
    long1 := Len(Str1);
    long2 := Len(Str2);
 
(* If string Str2 if too long pick up only the portion that will *)
(* fit  in string Str1.                                          *)
    IF long2 > (HIGH(Str1)+1) THEN long2 := HIGH(Str1)+1 END;
    FOR i := 0 TO (long2-1) DO
        Str1[i] := Str2[i]
    END;
 
(* Put the eos if string Str1 is not full to capacity *)
    IF HIGH(Str1) # (long2-1) THEN Str1[long2] := eos END;
END StringIs;
 
PROCEDURE ShowString(Str : ARRAY OF CHAR );
 
(* Procedure to display a string on the console *)
 
VAR i,long : CARDINAL;
BEGIN
    long := Len(Str);
    FOR i := 0 TO (long-1) DO
        Write(Str[i]);
    END;
END ShowString;
 
PROCEDURE StringAdd (VAR Str1 : ARRAY OF CHAR; Str2 : ARRAY OF CHAR );
 
(* Procedure to concatenate two strings such that,                 *)
(*                     Str1 = Str1 + Str2                          *)
(*                                                                 *)
(*-----------------------------------------------------------------*)
(*  Error Handling : If Str2 will be concatenated to strign Str1   *)
(*  in as much "free space" is availble.                           *)
(*-----------------------------------------------------------------*)
 
 
VAR 
    i,long1,long2, hi : CARDINAL;
BEGIN
 
(* Obtain the length of the strings  *)
    hi := HIGH(Str1);
    long1 := Len(Str1);
    long2 := Len(Str2);
 
(* If string Str2 if too long pick up only the portion that will *)
(* fit  in string Str1.                                          *)  
    IF (long1+long2-1) > hi THEN long2 := hi - long1 + 1 END;
        FOR i := 0 TO (long2-1) DO
            Str1[i+long1] := Str2[i]
        END;
 
(* Put the eos if string Str1 is not full to capacity *)
        IF hi # (long1+long2-1) THEN Str1[long1+long2] := eos END;
END StringAdd;
 
PROCEDURE StringDelete(VAR Str : ARRAY OF CHAR ; First,Last : CARDINAL);
 
(* Procedure to delete a portion of a string by specifying the first *)
(* and last character by position.                                   *)
(*                                                                   *)
(*-------------------------------------------------------------------*)
(*  Error Handling :                                                 *)
(*                                                                   *)
(*  (1) If Fisrt is greater than the string length, string Str will  *)
(*      remain intact.                                               *)
(*  (2) If Last is graeter than the string length, string Str will   *)
(*      end at position Last.                                        *)
(*-------------------------------------------------------------------*)
 
 
VAR i,long : CARDINAL;
BEGIN
    long := Len(Str);
 
(* If the first character is greater than the string length ignore   *)
(* the Procedure altogether.                                         *)
 
    IF First < long THEN
 
 
       IF Last >= long (* Check if the last character *)
                       (* position is within limits.  *)
              THEN
        Str[First] := eos
 
              ELSE (* Delete up to the last character *)
                FOR i := Last TO (long-1) DO
            Str[First+i-Last-1] := Str[i]
        END;
 
        (* Put the eos if string Str1 *)
        Str[long+First-Last-1] := eos
       END;
    END;
END StringDelete;    
 
PROCEDURE StringPos(Str1,Str2 : ARRAY OF CHAR ; Start : CARDINAL):CARDINAL;
 
(* Returns the position where the sub-string Str2 occurs within string *)
(* starting at positon 'Start' Str1.                                   *)
(*                                                                     *)
(*---------------------------------------------------------------------*)
(*  Error Handling :                                                   *)
(*  (1) If Str2 is bigger than Str1 to begin with, then there can be   *)
(*      no matching of Str2 in Str1.                                   *)
(*  (2) If Start is greater than the length of Str1 then return zero   *)
(*      as a result.                                                   *)
(*---------------------------------------------------------------------*)
 
 
VAR 
    long1,long2,ptr1,ptr2,last : CARDINAL;
    Found : BOOLEAN;
    
BEGIN
 
(* Initialize and obtain string lengths *)
    IF Start = 0 THEN Start := 1 END;
    ptr1 := Start-1; ptr2 :=0; last := ptr1;
    Found := FALSE;
    long1 := Len(Str1);
    long2 := Len(Str2);
(* Peform the function if the sub-string is indeed the smaller *)
    IF (long1 >= long2) AND (Start <= (long1-1)) THEN
        REPEAT    
            IF Str1[ptr1] = Str2[ptr2]
                THEN
                    IF ptr2 = 0 THEN last := ptr1 END;
                    IF ptr2 = long2-1 
                          THEN 
                        Found := TRUE
                          ELSE        
                        INC(ptr2)
                    END;    
                ELSE
                    IF ptr2 > 0 THEN ptr1 := last; ptr2 := 0 END;
            END;
            INC(ptr1)
        UNTIL (Found = TRUE) OR (ptr1 >= long1-1);
    END; 
(* Return zero if there was no match.                          *)
    IF NOT Found THEN ptr1 := 0 
             ELSE DEC(ptr1,long2-1)
    END;
    RETURN ptr1        
END StringPos;
 
PROCEDURE StringLeft(VAR Str1 : ARRAY OF CHAR ;
                         Str2 : ARRAY OF CHAR; Count : CARDINAL);
 
(* Procedure will return the 'Count' leftmost characters of string *)
(* Str2 and save the result in string Str1.                        *)
(*                                                                 *)
(*-----------------------------------------------------------------*)
(*  Error Handling :                                               *)
(* (1) If Count = 0 then reassugn Count as 1.                      *)
(* (2) If Count is greater than the string length then adjust it   *)
(*     to equal the latter.                                        *)
(*-----------------------------------------------------------------*)
 
VAR long : CARDINAL;
 
BEGIN
 
    StringIs(Str1,Str2);
    long := Len(Str1) - 1;
    IF Count = 1 THEN Count := 1 END;
    IF Count > long THEN Count := long END;
    IF Count <> long THEN
          Str1[Count] := eos
    END;
END StringLeft;
 
PROCEDURE StringRight(VAR Str1 : ARRAY OF CHAR ;
                          Str2 : ARRAY OF CHAR;  Count : CARDINAL);
 
(* Procedure will return the 'Count' rightmost characters of string *)
(* Str2 and save the result in string Str1.                         *)
(*                                                                  *)
(*------------------------------------------------------------------*)
(*  Error Handling : If Count is zero or greater than the string    *)
(*  length then string Str1 will be an exact copy of Str2.          *)
(*------------------------------------------------------------------*)
 
VAR i,long ,used: CARDINAL;
BEGIN
 
(* Copy string Str2 into string Str1 and obtain its length.         *)
    StringIs(Str1,Str2);
    long := Len(Str1);
    IF (Count <= long) AND (Count # 0) THEN 
 
(* Obtain the first character position to relocate string Str1.     *)
        used := long - Count;
        FOR i := 0 TO (Count-1) DO
            Str1[i] := Str1[used+i]
        END;
        Str1[Count] := eos
    END;
END StringRight;
 
PROCEDURE StringMid(VAR Str1 : ARRAY OF CHAR ;
                        Str2 : ARRAY OF CHAR;  Start, Count : CARDINAL);
 
(* Procedure will copy the portion of string Str2 from the character   *)
(* position 'Start' and for 'Count' characters into string Str1.       *)
(*                                                                     *)
(*---------------------------------------------------------------------*)
(*  Error Handling : If the sum of Start and Count is greater than the *)
(*  string length then the resulting string Str1 will be identical to  *)
(*  string Str2.                                                       *)
(*---------------------------------------------------------------------*)
 
VAR i,long : CARDINAL;
BEGIN
    StringIs(Str1,Str2);
    IF Start > 0 THEN DEC(Start) END;
    long := Len(Str1);
    IF (Start + Count) <= long THEN 
        FOR i := Start TO (Start+Count-1) DO
            Str1[i-Start] := Str1[i]
        END;
        IF HIGH(Str1) # Count THEN Str1[Count] := eos END;
    END;
END StringMid;
 
PROCEDURE StringRemove(VAR Str1 : ARRAY OF CHAR; Str2 : ARRAY OF CHAR);
 
(* Procedure to remove all occurences of sub-string Str2 from Str1. *)
 
VAR 
    i,long1,long2,ptr,position,move,high : CARDINAL;

BEGIN
    high := HIGH(Str1);
    long1 := Len(Str1);
    long2 := Len(Str2);
    ptr := 1;
    REPEAT 
        position := StringPos(Str1,Str2,ptr);
        IF position # 0 THEN (* Shift characters to overwrite Str2 *)
            ptr := position - 1;
            FOR i := (ptr+long2) TO (long1-1) DO
                Str1[i-long2] := Str1[i]
            END;
            DEC(long1,long2);
            Str1[long1] := eos;
        END;
    UNTIL position = 0; (* Cannot find any more sub-strings *)
END StringRemove;
 
PROCEDURE StringInsert(VAR Str1 : ARRAY OF CHAR; Str2 : ARRAY OF CHAR; 
                          Start : CARDINAL);
 
(* Procedure will insert string Str2 in Str1 at the character *)
(* position 'Start' of string Str1.                           *)
(*                                                            *)
(*------------------------------------------------------------*)
(*  Error Handling : If there no room for string Str2 to be   *)
(*  inserted entirely string Str1 will remain intact.         *)
(*------------------------------------------------------------*)
 
VAR
   i,long1,long2 : CARDINAL;
BEGIN
        DEC(Start);
        long1 := Len(Str1);
        long2 := Len(Str2);
        IF (long1+long2-1) <= HIGH(Str1) THEN 
 
(* Relocate portions of Str1 to make way for string Str2.      *)
                FOR i := (long1-1) TO Start BY -1 DO
                        Str1[i+long2] := Str1[i]
                END;
 
(* Copy string Str2 into the reserved loaction of string Str1. *)
                FOR i := Start TO (Start+long2-1) DO
                        Str1[i] := Str2[i-Start]
                END;
                INC(long1,long2);
                IF (long1-1) < HIGH(Str1) THEN Str1[long1] := eos END;
        END;                
END StringInsert;
 
PROCEDURE StringReplace(VAR Str1 : ARRAY OF CHAR; Str2,Str3 : ARRAY OF CHAR);
 
(* Procedure will replace all occurences of sub-string Str2, in string *)
(* Str1, by sub-string Str3.                                           *)
 
VAR 
    i,long1,long2,long3,ptr,pos,Stringhigh : CARDINAL;
BEGIN
    long1 := Len(Str1);
    long2 := Len(Str2);
    long3 := Len(Str3);
    ptr := 1;
    Stringhigh := HIGH(Str1)+1;
    REPEAT
        pos := StringPos(Str1,Str2,ptr);
        IF pos # 0 THEN
            ptr := pos;
            StringDelete(Str1,ptr,(ptr+long2-1));
            StringInsert(Str1,Str3,ptr);
            long1 := long1 - long2 + long3;
            IF long1 = Stringhigh THEN pos :=0
                                  ELSE Str1[long1] := eos
            END;
        END;
    UNTIL pos = 0;
END StringReplace;
 
PROCEDURE StringChange(VAR Str1 : ARRAY OF CHAR; Str2,Str3 : ARRAY OF CHAR;
                           Start,Repeat:CARDINAL);
 
(* Procedure will replace sub-string Str2 with Str3 in string Str1 *)
(* start at character position 'Start' and for 'Repeat' times.     *)
 
VAR 
    i,long1,long2,long3,ptr,pos,Stringhigh : CARDINAL;
BEGIN
    long1 := Len(Str1);
    long2 := Len(Str2);
    long3 := Len(Str3);
    ptr := Start;
    Stringhigh := HIGH(Str1)+1;
    REPEAT
        pos := StringPos(Str1,Str2,ptr);
        IF pos # 0 THEN
            ptr := pos;
            StringDelete(Str1,ptr,(ptr+long2-1));
            StringInsert(Str1,Str3,ptr);
            long1 := long1 - long2 + long3;
            IF long1 = Stringhigh THEN pos :=0
                                  ELSE Str1[long1] := eos
            END;
        DEC(Repeat);
        END;
    UNTIL pos*Repeat = 0;
END StringChange;
 
PROCEDURE StringAlter(VAR Str1 : ARRAY OF CHAR; Str2 : ARRAY OF CHAR; 
                                Start : CARDINAL);
 
(* Procedure will overwrite string Str1 with sub-string Str2 starting *)
(* at position 'Start'.                                               *)
(*                                                                    *)
(*--------------------------------------------------------------------*)
(*  Error Handling : If there is no room for string Str2 to fit in    *)
(*  its entirey string Str1 will remain intact.                       *)
(*--------------------------------------------------------------------*)
 
VAR
    i,long,ptr : CARDINAL;
BEGIN
    DEC(Start);
    long := Len(Str2);
    IF (Start+long-1) <= HIGH(Str1) THEN 
        FOR i := Start TO (Start+long-1) DO
            Str1[i] := Str2[i-Start]
        END;
    END;
END StringAlter;
 
PROCEDURE InputString (VAR Str : ARRAY OF CHAR);
 
(* Read string from the keyboard.                                    *)
 
VAR 
    i,high : CARDINAL;
    ch : CHAR;
BEGIN
    high := HIGH(Str);
    i := 0;
    REPEAT
        Read(ch);
        Write(ch);
        IF ch # CHAR(177C)
                THEN 
                    Str[i] := ch;
                    INC(i)
                ELSE
                    Write(' ');
                    Write(ch);
                    IF i > 0 THEN DEC(i) END;
        END;
    UNTIL (ch = CHAR(36C)) OR (i > high);
    IF i <= high THEN 
           DEC(i);
           Str[i] := eos
    END;
END InputString;
 
END Strlib.
