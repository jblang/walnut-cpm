(* This is the corrected version of the sample program illustrating *)
(* TRANSFER() in the Turbo Modula-2 User's Guide (Page 455).  The problem *)
(* with the original is that coroutine workspace is not allocated due to *)
(* use of POINTER declarations instead of "real" variables. *)

MODULE TickTock;
FROM SYSTEM IMPORT
  ADR, NEWPROCESS, TRANSFER, ADDRESS, PROCESS, WORD; (* additional ADR *)
VAR
  tickProcess, tockProcess, main: PROCESS;
  tickWork, tockWork: ARRAY[0..99] OF WORD; (* pointers no longer used *)

  PROCEDURE tick;
  BEGIN
    WRITELN('tick');
    TRANSFER(tickProcess,tockProcess);
  END tick; (* original program had a small error here, also *)

  PROCEDURE tock;
  BEGIN
    WRITELN('tock');
    TRANSFER(tockProcess,tickProcess);
  END tock;

BEGIN
  NEWPROCESS(tick,ADR(tickWork),SIZE(tickWork),tickProcess);
  NEWPROCESS(tock,ADR(tockWork),SIZE(tockWork),tockProcess);
  TRANSFER(main,tickProcess);
END TickTock.
