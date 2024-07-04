{            INVENTORY PROGRAM FOR
                TURBO PASCAL
                WRITTEN BY CHARLES STEWART
                                               }

PROGRAM INVENT;
TYPE
   ITEM=(A,E,T,F,J,M,X); { X IS FOR DELETED FILE FLAG}
   INVRECORD=RECORD
             ID:STRING[6];
             INVTYPE:ITEM;
             DESCRIPTION:STRING[20];
             COST:STRING[6];
   END;

   RINV= ARRAY[1..100] OF INVRECORD;

VAR
   FNAME:STRING[12];
   SELECTION:CHAR;
   RIDNUMBER:STRING[6];
   RTYPE:ITEM;
   RDESCRIPTION:STRING[20];
   RCOST:STRING[6];
   RINVRECORD:INVRECORD;
   INFILE, OUTFILE : FILE OF INVRECORD;
   RESPONSE:STRING[30];
   ALLDONE:BOOLEAN;
   TEMP:INVRECORD;
   TOTAL:REAL;
   AMT:REAL;
   CODE:INTEGER;
   INVENTORY:RINV;

PROCEDURE STALL;
BEGIN
  WRITELN;
  WRITELN('PRESS RETURN TO CONTINUE ');
  WRITELN;
  READLN;
END; {STALL}

PROCEDURE DELETE(VAR R:RINV);
VAR CODE, I:INTEGER;
    ALLDONE:BOOLEAN;
    RE:INTEGER;
    CLASS:CHAR;
    PP,PG:INTEGER;
    RCLASS:ITEM;
BEGIN
   ALLDONE := FALSE;
   CLRSCR;
   PP := 0;
   PG := 20;
   ASSIGN(OUTFILE,FNAME);
   RESET(OUTFILE);
   I:=0;
   CLRSCR;
      REPEAT
      IF PP < PG THEN
       BEGIN
        READ (OUTFILE,RINVRECORD);
        WITH RINVRECORD DO
        BEGIN
           WRITE(I:3,' ');
           WRITE(ID:8);
           WRITE(DESCRIPTION:22);
           WRITE(COST:8);
           IF INVTYPE = X THEN WRITE('----DELETED---');
           WRITELN;
           PP := PP + 1;
           I:=I+1;

         END;
       END
      ELSE
       BEGIN
         WRITE(' PRESS RETURN FOR NEXT PAGE');
         PP := 0;
         READLN;
         CLRSCR;
       END;
   UNTIL EOF(OUTFILE);
   WRITELN;
   I:= I - 1;
   WRITELN('DELETE WHICH ITEM ');
   READLN(RE);
     IF RE > I THEN
        BEGIN
           WRITELN('ERROR',^G,' THAT ITEM DOES NOT EXIST');
           STALL;
        END
     ELSE
        BEGIN
           SEEK(OUTFILE,0); {REWIND THE POINTER TO 0 POS IN FILE}
           SEEK(OUTFILE,RE);
           RINVRECORD.INVTYPE := X; {DELETE FILE CODE}
           WRITE(OUTFILE,RINVRECORD);
        END;
CLOSE(OUTFILE);
END;{DELETE}

PROCEDURE CHANGE(VAR R:RINV);
VAR CODE, I:INTEGER;
    ALLDONE:BOOLEAN;
    PP,PG:INTEGER;
    CLASS:CHAR;
    RE:INTEGER;
    RCLASS:ITEM;
BEGIN
   ALLDONE := FALSE;
   CLRSCR;
   ASSIGN(OUTFILE,FNAME);
   RESET(OUTFILE);
   I:=0;
   CLRSCR;
      PP:= 0; PG := 20;
      REPEAT
      IF PP < PG THEN
       BEGIN
        READ (OUTFILE,RINVRECORD);
        WITH RINVRECORD DO
         BEGIN
           WRITE(I:3,' ');
           WRITE(ID:8);
           WRITE(DESCRIPTION:22);
           WRITE(COST:8);
           IF INVTYPE = X THEN WRITE ('------DELETED-------');
           WRITELN;
           I:=I+1;
           PP := PP +1;
         END;
       END
      ELSE
        BEGIN
           WRITE('PRESS RETURN FOR NEXT PAGE');
           PP :=0;
           READLN;
           CLRSCR;
        END;
   UNTIL EOF(OUTFILE);
   WRITELN;
   I:= I - 1;
   WRITELN('CHANGE WHICH ITEM ');
   READLN(RE);
   IF RE > I THEN
        BEGIN
                 WRITELN('ERROR NO SUCH RECORD',^G);
                 STALL;
        END
   ELSE
        BEGIN
               SEEK(OUTFILE,0); {REWIND THE POINTER TO 0 POS IN FILE}
               SEEK(OUTFILE,RE);
                   WRITELN('PURCHASE DATE AS YYMMDD');
                       READLN(RIDNUMBER);
                       R[I].ID := RIDNUMBER;
                       WRITELN('INVENTORY TYPE  A,E,T,F,J,M,? ');
                       READLN(CLASS);
                       IF CLASS <> '?' THEN
                          BEGIN
                               IF CLASS = 'A' THEN RCLASS := A
                                  ELSE
                                      IF CLASS = 'E' THEN RCLASS := E
                                      ELSE
                                      IF CLASS = 'T' THEN RCLASS := T
                                      ELSE
                                      IF CLASS = 'F' THEN RCLASS := F
                                      ELSE
                                      IF CLASS = 'J' THEN RCLASS := J
                                      ELSE
                                      RCLASS := M;
                          END
                      ELSE
                          BEGIN
                             CLRSCR;
                             WRITELN('A- > APPLIANCE');
                             WRITELN('E- > ELECTRONIC');
                             WRITELN('T- > TOY');
                             WRITELN('F- > FURNITURE');
                             WRITELN('J- > JEWERY');
                             WRITELN('M- > MISC. ');
                             WRITELN('INVENTORY TYPE  A,E,T,F,J,M');
                             READLN(CLASS);
                          END;

     WRITELN('DESCRIPTION OF ITEM 20 CHARACTER MAXIMUM ');
     WRITELN('-------------------* AS INDICATED BY THE ASTERISK');
     READLN(RDESCRIPTION);
     R[I].DESCRIPTION := RDESCRIPTION;
     WRITELN(' ITEM COST TO NEAREST DOLLAR (NO DECIMALS)');
     READLN(RCOST);
     R[I].COST := RCOST;
     WRITE(OUTFILE,R[I]);
     CLOSE(OUTFILE);
END;
END;{CHANGE}

PROCEDURE SORT(VAR R:RINV);
VAR J,I,INDEX:INTEGER;
BEGIN
   CLRSCR;
   WRITELN('SORT ROUTINE OF THE INPUT DATA');
   ASSIGN(INFILE,FNAME);
   RESET(INFILE);
   INDEX := 0;
   WHILE NOT EOF(INFILE) DO
      BEGIN
        INDEX := INDEX + 1;
        READ (INFILE,R[INDEX]);
      END;
   CLOSE(INFILE);
   ASSIGN(OUTFILE,FNAME);
   REWRITE(OUTFILE);
   FOR I := 1 TO INDEX-1 DO
       FOR J := I+1 TO INDEX DO
           IF R[I].ID > R[J].ID
                    THEN
                         BEGIN  {SWAP EM}
                           TEMP := R[I];
                           R[I] := R[J];
                           R[J] := TEMP;
                         END;
   FOR I:= 1 TO INDEX DO
       WRITE(OUTFILE,R[I]);
   WRITELN(' SORTED FILE WRITTEN TO DISK FILE ',FNAME);
   CLOSE(OUTFILE);
   STALL;
END; {SORT ROUTINE}
PROCEDURE TYPESORT(VAR R:RINV);
VAR J,I,INDEX:INTEGER;
BEGIN
   CLRSCR;
   WRITELN('SORT ROUTINE OF THE INPUT DATA');
   RESET(INFILE);
   INDEX := 0;
   WHILE NOT EOF(INFILE) DO
      BEGIN
        INDEX := INDEX + 1;
        READ (INFILE,R[INDEX]);
      END;
   CLOSE(INFILE);
   ASSIGN(OUTFILE,FNAME);
   REWRITE(OUTFILE);
   FOR I := 1 TO INDEX-1 DO
       FOR J := I+1 TO INDEX DO
           IF R[I].INVTYPE > R[J].INVTYPE
                    THEN
                         BEGIN  {SWAP EM}
                           TEMP := R[I];
                           R[I] := R[J];
                           R[J] := TEMP;
                         END;
   FOR I:= 1 TO INDEX DO
       WRITE(OUTFILE,R[I]);
   CLOSE(OUTFILE);
END; {SORT ROUTINE}

PROCEDURE CREATE(VAR R:RINV);
VAR CLASS:CHAR;
   RCLASS:ITEM;
BEGIN
   ALLDONE:=FALSE;
   ASSIGN(OUTFILE,FNAME);
   REWRITE(OUTFILE);
   WHILE NOT ALLDONE DO
      BEGIN
     WRITELN('PURCHASE DATE AS YYMMDD');
     READLN(RIDNUMBER);
     RINVRECORD.ID := RIDNUMBER;
     WRITELN('INVENTORY TYPE  A,E,T,F,J,M,? ');
     READLN(CLASS);
     IF CLASS <> '?' THEN
     BEGIN
         IF CLASS = 'A' THEN RCLASS := A
     ELSE
        IF CLASS = 'E' THEN RCLASS := E
        ELSE
           IF CLASS = 'T' THEN RCLASS := T
           ELSE
              IF CLASS = 'F' THEN RCLASS := F
              ELSE
                 IF CLASS = 'J' THEN RCLASS := J
                 ELSE
                    RCLASS := M;
    END
    ELSE
       BEGIN
         CLRSCR;
         WRITELN('A- > APPLIANCE');
         WRITELN('E- > ELECTRONIC');
         WRITELN('T- > TOY');
         WRITELN('F- > FURNITURE');
         WRITELN('J- > JEWERY');
         WRITELN('M- > MISC. ');
         WRITELN('INVENTORY TYPE  A,E,T,F,J,M,? ');
         READLN(CLASS);
       END;

     RINVRECORD.INVTYPE := RCLASS;
     WRITELN('DESCRIPTION OF ITEM 20 CHARACTER MAXIMUM ');
     WRITELN('-------------------* AS INDICATED BY THE ASTERISK');
     READLN(RDESCRIPTION);
     RINVRECORD.DESCRIPTION := RDESCRIPTION;
     WRITELN(' ITEM COST TO NEAREST DOLLAR (NO DECIMALS)');
     READLN(RCOST);
     RINVRECORD.COST := RCOST;
     WRITE(OUTFILE,RINVRECORD);
     WRITELN(' IF YOU ARE DONE TYPE AN ASTERISK (*), OTHERWISE JUST HIT ENTER');
     READLN (RESPONSE);
     IF RESPONSE = '*' THEN ALLDONE := TRUE;
   END; {WHILE ALLDONE LOOP}
   CLOSE(OUTFILE);
   SORT(INVENTORY);
END; {CREATE}


PROCEDURE MENU(VAR SELECTION:CHAR);
   BEGIN
       CLRSCR;
       WRITELN('Inventory Management System':53);
       WRITELN('by Charles A. Stewart':50);
       WRITELN;
       WRITELN('Copyright 1986 all rights reserved':56);
       WRITELN;
       WRITELN('Work file name ',fname);
       WRITELN;
       WRITELN(' A--> Create new inventory file');
       WRITELN(' B--> Add items to inventory  ');
       WRITELN(' C--> Change items in inventory');
       WRITELN(' D--> Delete item in inventory');
       WRITELN(' E--> Print the inventory to printer');
       WRITELN(' F--> Assign file name ');
       WRITELN(' G--> END PROGRAM');
       WRITELN;
       READLN (SELECTION);
       IF SELECTION = 'F' THEN
          BEGIN
            WRITE('File name please ');
            readln(fname);
          END;
   END;{MENU}

PROCEDURE ADD(VAR R:RINV);
VAR I:INTEGER;
    ALLDONE:BOOLEAN;
     CLASS:CHAR;
     RCLASS:ITEM;
BEGIN
   ALLDONE := FALSE;
   CLRSCR;
   ASSIGN(OUTFILE,FNAME);
   RESET(OUTFILE);
   SEEK(OUTFILE,FILESIZE(OUTFILE));
   WHILE NOT ALLDONE DO
      BEGIN
     WRITELN('PURCHASE DATE AS YYMMDD');
     READLN(RIDNUMBER);
     RINVRECORD.ID := RIDNUMBER;
     WRITELN('INVENTORY TYPE  A,E,T,F,J,M,? ');
     READLN(CLASS);
     IF CLASS <> '?' THEN
     BEGIN
         IF CLASS = 'A' THEN RCLASS := A
     ELSE
        IF CLASS = 'E' THEN RCLASS := E
        ELSE
           IF CLASS = 'T' THEN RCLASS := T
           ELSE
              IF CLASS = 'F' THEN RCLASS := F
              ELSE
                 IF CLASS = 'J' THEN RCLASS := J
                 ELSE
                    RCLASS := M;
    END
    ELSE
       BEGIN
         CLRSCR;
         WRITELN('A- > APPLIANCE');
         WRITELN('E- > ELECTRONIC');
         WRITELN('T- > TOY');
         WRITELN('F- > FURNITURE');
         WRITELN('J- > JEWERY');
         WRITELN('M- > MISC. ');
         WRITELN('INVENTORY TYPE  A,E,T,F,J,M,? ');
         READLN(CLASS);
       END;

     RINVRECORD.INVTYPE := RCLASS;
     WRITELN('DESCRIPTION OF ITEM 20 CHARACTER MAXIMUM ');
     WRITELN('-------------------* AS INDICATED BY THE ASTERISK');
     READLN(RDESCRIPTION);
     RINVRECORD.DESCRIPTION := RDESCRIPTION;
     WRITELN(' ITEM COST TO NEAREST DOLLAR (NO DECIMALS)');
     READLN(RCOST);
     RINVRECORD.COST := RCOST;
     WRITE(OUTFILE,RINVRECORD);
     WRITELN(' IF YOU ARE DONE TYPE AN ASTERISK (*), OTHERWISE JUST HIT ENTER');
     READLN (RESPONSE);
     IF RESPONSE = '*' THEN ALLDONE := TRUE;
   END; {WHILE ALLDONE LOOP}
   FLUSH(OUTFILE);
   CLOSE(OUTFILE);
   SORT(INVENTORY);
END; {ADD}

PROCEDURE PRINT(VAR R:RINV);
CONST PP=56;
VAR PG:INTEGER;
BEGIN
   CLRSCR;
   ASSIGN (INFILE,FNAME);
   RESET(INFILE);
   TYPESORT(INVENTORY);
   WRITELN(LST,'Household Inventory');
   WRITELN;
   WRITELN(LST,'Copyright 1986 by Charles Stewart');
   WRITELN(LST,'All Rights Reserved.');
   WRITELN(LST);
   ASSIGN(INFILE,FNAME);
   RESET(INFILE);
   TOTAL := 0;
   WRITELN(LST,'DATE':8,'DESCRIPTION':22,'       COST':6,'        CLASS');
   WRITELN(LST,'===============================================================');
   Pg := 7;
   REPEAT
        READ (INFILE,RINVRECORD);
        WITH RINVRECORD DO
        BEGIN
         IF Pg > PP THEN
            BEGIN
                WRITELN(LST,^l); { FORM FEED }
                WRITELN(LST,'Household Inventory');
                WRITELN;
                WRITELN(LST,'Copyright 1986 by Charles Stewart');
                WRITELN(LST,'All Rights Reserved.');
                WRITELN(LST);
                WRITELN(LST,'DATE':8,'DESCRIPTION':22,'       COST':6,'        CLASS');
                WRITELN(LST,'===============================================================');
                Pg := 7;
            END; {IF PP}
         IF INVTYPE <> X THEN
          BEGIN
           VAL (COST,AMT,CODE);
           TOTAL := TOTAL + AMT;
           Pg := Pg + 1;
           WRITE(LST,ID:8);
           WRITE(LST,DESCRIPTION:22);
           WRITE(LST,'  $');
           WRITE(LST,COST:6);
           WRITE(LST,'    ');
           CASE INVTYPE OF
           A: WRITE(LST,'APPLANCE');
           E: WRITE(LST,'ELECTRONIC');
           T: WRITE(LST,'TOY');
           J: WRITE(LST,'JEWELRY');
           F: WRITE(LST,'FURNITURE');
           M: WRITE(LST,'MISC. ');
           END; {CASE}
          WRITELN(LST);
          END;{WHILE}
        END;
   UNTIL EOF(INFILE);
   CLOSE(INFILE);
   WRITELN(LST);
   WRITELN(LST,'===============================================================');
   WRITELN(LST,'TOTAL ----------------> $',TOTAL:5:2);
END;{PRINT}

BEGIN {MAIN PROGRAM}
 FNAME :=('INVENT.DAT'); {DEFAULT FILE NAME}
 REPEAT
  MENU(SELECTION);
  CASE SELECTION OF
   'A': CREATE(INVENTORY);
   'B': ADD(INVENTORY);
   'D': DELETE(INVENTORY);
   'C': CHANGE(INVENTORY);
   'E': PRINT(INVENTORY);
  END;{CASE}
 UNTIL SELECTION > 'F';
END. {PROGRAM}

                                                                                                                                