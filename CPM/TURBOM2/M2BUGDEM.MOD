(******************************
This program demonstrates that the ORD function doesn't always return the
correct value for a CHAR variable and that the statement "c := C^;" moves a
16 bit value at address C to the CHAR variable c.  Both have caused serious
gas pains!  Is there a fix or Modula2 update available?
**********************************)

MODULE M2BugDemo;
FROM STORAGE IMPORT ALLOCATE;
FROM SYSTEM  IMPORT ADDRESS, FILL;

VAR
  A     : ADDRESS;
  c     : CHAR;
  C     : POINTER TO CHAR;
  i     : CARDINAL;

BEGIN
  ALLOCATE (A, 10);
  FILL (A, 10, 97);
  FOR i := 0 TO 9 DO
    C := A + i;
    c := C^;
    WRITELN (c, ORD (c));
    END;
END M2BugDemo.
                                                                         