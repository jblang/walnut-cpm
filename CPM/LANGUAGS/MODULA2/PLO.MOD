(* Skeleton compiler which checks the syntax of its input text
   according to the following grammar.  Principle is top-down,
   recursive descent with one symbol lookahead.  (see also N.
   Wirth, Algorithms + Data Structures = Programs, Ch. 5,
   Prentice-Hall, Inc. 1975)

   program =   block ".".
   block =     ["CONST" ident "=" number {"," ident "=" number} ";"]
   	       ["VAR" ident {"," ident} ";"]
	       ["PROCEDURE" ident ";" block ";"} statement.
   statement = ident ":=" expression| "CALL" ident |
               "BEGIN" statement {";" statement} "END" |
               "IF" condition "THEN" statement |
               "WHILE" condition "DO" statement].
   condition = "ODD" expression |
               expression ("="|"#"|">"|"<"|"<="|">=") expression.
   expression= ["+"|"-"] term {("+"|"-") term}.
   term      = factor {("*"|"/") factor}.
   factor    = ident | number | "(" expression ")". *)

MODULE plo;

FROM InOut    IMPORT OpenInput,Done,CloseInput,Read,in,WriteInt;
FROM Terminal IMPORT WriteString,Write,WriteLn;

CONST
  norw = 11;
  tmax = 100;
  nmax = 14;
  al = 10;
  chsetsize = 128;

TYPE
  symbol = (nul,ident,number,plus,minus,times,slash,oddsym,
            eql,neq,lss,leq,gtr,geq,lparen,rparen,comma,semicolon,
            period,becomes,beginsym,endsym,ifsym,thensym,
            whilesym,dosym,callsym,constsym,varsym,procsym);

  alfa = ARRAY [0..al] OF CHAR;
  object = (constant,variable,prozedure);

VAR
  tch,ch:   CHAR;
  sym:  symbol;
  id:   alfa;
  num:  INTEGER;
  cc:   INTEGER;
  ll:   INTEGER;
  kk:   INTEGER;
  line: ARRAY [1..81] OF CHAR;
  a:    alfa;
  word: ARRAY [1..norw] OF alfa;
  wsym: ARRAY [1..norw] OF symbol;
  ssym: ARRAY [0C..'}'] OF symbol;
  table:ARRAY [0..tmax] OF
        RECORD
          name: alfa;
          kind: object
        END;

PROCEDURE error(n: INTEGER);
  VAR i: INTEGER;

BEGIN
  FOR i := 1 TO cc DO Write(' ') END;
  Write('>'); WriteInt(n,2);
  HALT
END error;

PROCEDURE compalfa(a,b:alfa):symbol;
VAR res: symbol; i: INTEGER;

BEGIN
  i := 1;
  res := eql;
  LOOP
    IF CAP(a[i]) < CAP(b[i]) THEN res := lss; EXIT
    ELSIF CAP(a[i]) > CAP(b[i]) THEN res := gtr; EXIT
    ELSE INC(i)
    END;
    IF i >= al THEN EXIT END;
  END;
  RETURN(res);
END compalfa;

PROCEDURE getsym;
  VAR i,j,k: INTEGER;

  PROCEDURE getch;
  BEGIN
    IF cc = ll THEN
      IF in.eof THEN WriteString(' program incomplete'); HALT END;
      Read(ch);
      ll := 0; cc := 0; Write(' ');
      WHILE (ch <> 36C) AND NOT in.eof DO
        INC(ll); Write(ch); line[ll] := ch; Read(ch)
      END;
      WriteLn;
    END;
    INC(cc); ch := line[cc]
  END getch;

BEGIN
  WHILE ch = ' ' DO getch END;
  IF (ch >= 'a') AND (ch <= 'z') THEN
    k := 0;
    REPEAT
      IF k < al THEN INC(k); a[k] := ch END;
      getch;
    UNTIL ((ch < 'a') OR (ch > 'z')) AND ((ch < '0') OR (ch > '9'));
    IF k >= kk THEN kk := k
    ELSE REPEAT a[kk] := ' '; DEC(kk); UNTIL kk = k
    END;
    id := a; i := 1; j := norw;
    REPEAT
      k := (i+j) DIV 2;
      IF compalfa(id,word[k]) # gtr THEN j := k-1 END;
      IF compalfa(id,word[k]) # lss THEN i := k+1 END;
    UNTIL i > j;
    IF i-1 > j THEN sym := wsym[k] ELSE sym := ident END;
  ELSIF (ch >= '0') AND (ch <= '9') THEN
    k := 0; num := 0;
    sym := number;
    REPEAT
      num := 10 * num + INTEGER((ORD(ch)-ORD('0')));
      INC(k); getch;
    UNTIL (ch < '0') OR (ch > '9');
    IF k > nmax THEN error(30) END;
  ELSIF ch = ':' THEN
    getch;
    IF ch = '=' THEN sym := becomes; getch
    ELSE sym := nul;
    END;
  ELSIF ch = '<' THEN
    getch;
    IF ch = '=' THEN sym := leq; getch
    ELSE sym := lss;
    END;
  ELSIF ch = '>' THEN
    getch;
    IF ch = '=' THEN sym := geq; getch
    ELSE sym := gtr;
    END;
  ELSE sym := ssym[ch]; getch
  END;
END getsym;

PROCEDURE block(tx: INTEGER);

  PROCEDURE enter(k: object);
  BEGIN
    INC(tx);
    WITH table[tx] DO
      name := id; kind := k;
    END;
  END enter;

  PROCEDURE position(id: alfa): INTEGER;
  VAR i: INTEGER;
  BEGIN
    table[0].name := id; i := tx;
    WHILE compalfa(table[i].name,id) # eql DO i := i-1 END;
    RETURN(i);
  END position;

  PROCEDURE constdeclaration;
  BEGIN
    IF sym = ident THEN
      getsym;
      IF sym = eql THEN
        getsym;
        IF sym = number THEN
          enter(constant); getsym
        ELSE error(2); END
      ELSE error(3) END
    ELSE error(4) END
  END constdeclaration;

  PROCEDURE vardeclaration;
  BEGIN
    IF sym = ident THEN
      enter(variable); getsym
    ELSE error(4) END;
  END vardeclaration;

  PROCEDURE statement;
  VAR i: INTEGER;
  
    PROCEDURE expression;

      PROCEDURE term;

        PROCEDURE factor;
        VAR i: INTEGER;
        BEGIN
          IF sym = ident THEN
            i := position(id);
            IF i = 0 THEN error(0)
            ELSIF table[i].kind = prozedure THEN error(21)
            END; getsym;
          ELSIF sym = number THEN
            getsym;
          ELSIF sym = lparen THEN
            getsym; expression;
            IF sym = rparen THEN getsym;
            ELSE error(22)
            END
          ELSE error(23)
          END;
        END factor;

      BEGIN (* term *)
        factor;
        WHILE (sym = times) OR (sym = slash) DO
          getsym; factor;
        END;
      END term;

    BEGIN (* expression *)
      IF (sym = plus) OR (sym = minus) THEN
        getsym; term
      ELSE term
      END;
      WHILE (sym = plus) OR (sym = minus) DO
        getsym; term
      END;
    END expression;

    PROCEDURE condition;
    BEGIN
      IF sym = oddsym THEN
        getsym; expression
      ELSE
        expression;
        IF (ORD(sym) < ORD(eql)) OR (ORD(sym) > ORD(geq)) THEN error(20)
        ELSE getsym; expression
        END
      END;
    END condition;

  BEGIN (* statement *)
    IF sym = ident THEN
      i := position(id);
      IF i = 0 THEN error (11)
      ELSIF table[i].kind # variable THEN error(12)
      END; getsym;
      IF sym = becomes THEN getsym ELSE error(13) END;
      expression
    ELSIF sym = callsym THEN getsym;
      IF sym # ident THEN error(14)
      ELSE i := position(id);
        IF i = 0 THEN error(11)
        ELSIF table[i].kind # prozedure THEN error(15)
        END; getsym
      END;
    ELSIF sym = ifsym THEN
      getsym; condition;
      IF sym = thensym THEN getsym ELSE error(16) END;
      statement;
    ELSIF sym = beginsym THEN
      getsym; statement;
      WHILE sym = semicolon DO
        getsym; statement
      END;
      IF sym = endsym THEN getsym ELSE error(17) END;
    ELSIF sym = whilesym THEN
      getsym; condition;
      IF sym = dosym THEN getsym ELSE error(18) END;
      statement
    END;
  END statement;

BEGIN (* block *)
  IF sym = constsym THEN
    getsym; constdeclaration;
    WHILE sym = comma DO
     getsym;  constdeclaration
    END;
    IF sym = semicolon THEN getsym ELSE error(5) END;
  END;
  IF sym = varsym THEN
    getsym; vardeclaration;
    WHILE sym = comma DO
      getsym; vardeclaration
    END;
    IF sym = semicolon THEN getsym ELSE error(5) END;
  END;
  WHILE sym = procsym DO
    getsym;
    IF sym = ident THEN enter(prozedure); getsym ELSE error(4); END;
    IF sym = semicolon THEN getsym ELSE error(5) END;
    block(tx);
    IF sym = semicolon THEN getsym ELSE error(5) END
  END;
  statement;
END block;

BEGIN (* main program *)
  FOR ch := 0C TO '}' DO ssym[ch] := nul END;
  word[ 1] := " BEGIN    "; word[ 2] := " CALL     ";
  word[ 3] := " CONST    "; word[ 4] := " DO       ";
  word[ 5] := " END      "; word[ 6] := " IF       ";
  word[ 7] := " ODD      "; word[ 8] := " PROCEDURE";
  word[ 9] := " THEN     "; word[10] := " VAR      ";
  word[11] := " WHILE    ";
  wsym[ 1] := beginsym;    wsym[ 2] := callsym;
  wsym[ 3] := constsym;    wsym[ 4] := dosym;
  wsym[ 5] := endsym;      wsym[ 6] := ifsym;
  wsym[ 7] := oddsym;      wsym[ 8] := procsym;
  wsym[ 9] := thensym;     wsym[10] := varsym;
  wsym[11] := whilesym;
  ssym['+'] := plus;       ssym['-'] := minus;
  ssym['*'] := times;      ssym['/'] := slash;
  ssym['('] := lparen;     ssym[')'] := rparen;
  ssym['='] := eql;        ssym[','] := comma;
  ssym['.'] := period;     ssym['#'] := neq;
  ssym['<'] := lss;        ssym['>'] := gtr;
  ssym[';'] := semicolon;
  Write(14C);
  OpenInput("PLO"); a[0] := ' ';
  in.eof := FALSE;
  cc := 0; ll := 0; ch := ' '; kk := al; getsym;
  block(0);
  IF sym # period THEN error(9) END;
END plo.
