(*
 *	Producer/Consumer Test Module
 *
 *	This module tests the WAIT and SEND functions
 *	found in the Processes module and is adapted
 *	from code found on page 346 of Advanced Modula-2
 *	by Herber Schildt available from McGraw-Hill.
 *
 *)

MODULE ProCon;

FROM Terminal IMPORT WriteLn,WriteString;
FROM SYSTEM IMPORT WORD,PROCESS,ADR,NEWPROCESS,TRANSFER;
FROM Processes IMPORT WAIT,SEND,StartProcess,Init,SIGNAL;

VAR
  buf: ARRAY[0..100] OF CHAR;
  S: SIGNAL;

PROCEDURE Consumer;
BEGIN
  LOOP
    WriteString("waiting"); (* This portion of the loop is *)
    WriteLn;                (* executed only once !!!      *)
    WAIT(S);			(* Wait for characters from buffer *)
    WriteLn;                (* Subsequent SEND's cause looping on the *)
    WriteString(buf);       (* WAIT rather than going to the statement *)
  END;                      (* after the LOOP? is it a bug or the way its *)
END Consumer;               (* supposed to work? *)

PROCEDURE Producer;
VAR
  count: CARDINAL;
  ch: CHAR;

BEGIN
  count := 0;
  LOOP
    READ(ch);               	(* Clear character buffer *)
    IF (ch <> CHR(13)) AND (count < 99) THEN
      buf[count] := ch;
      WRITE(ch);
      INC(count);
    ELSE
      buf[count] := CHR(0);	(* Null terminator *)
      count := 0;
      SEND(S);
    END;
  END;
END Producer;

BEGIN
  Init(S);
  StartProcess(Consumer,1000);
  Producer;
  
END ProCon.