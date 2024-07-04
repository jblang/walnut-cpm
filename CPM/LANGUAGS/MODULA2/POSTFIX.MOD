(* Convert expressions from infix to postfix form.  Each
   expression is written on a separate line.  Expressions
   have the following syntax:

      expression = term {("+"|"=") term}.
      term =       factor {"*" factor}.
      factor =     letter | "(" expression ")". *)

MODULE postfix;

FROM InOut IMPORT Read, Write, WriteLn, Done, OpenInput;

VAR ch: CHAR;

PROCEDURE expression;
VAR op: CHAR;

  PROCEDURE factor;
  BEGIN
    IF ch = '(' THEN
      Read(ch);
      expression;
      Read(ch);
    ELSE
      Write(ch); Read(ch)
    END
  END factor;

  PROCEDURE term;
  BEGIN
    factor;
    WHILE ch = '*' DO
      Read(ch);
      factor;
      Write('*');
    END
  END term;

BEGIN
  term;
  WHILE (ch = '+') OR (ch = '-') DO
    op := ch;
    Read(ch);
    term;
    Write(op);
  END
END expression;

BEGIN
  OpenInput('TEXT');
  LOOP
    Write(' ');
    Read(ch);
    IF NOT Done THEN EXIT END;
    expression;
    WriteLn;
  END
END postfix.
