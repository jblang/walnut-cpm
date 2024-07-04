External btree::menu(4);

PROCEDURE SIGNON;
VAR	IX : 1..24;
BEGIN
  FOR IX:=1 TO 24 DO WRITELN;
  WRITELN( ' ':15, 'NAME AND ADDRESS ENTRY PROGRAM Version #', vers );
  FOR IX:=1 TO 4 DO WRITELN;
{    SIGNON TEXT GOES HERE    }
END{of SIGNON};


PROCEDURE MENU;
BEGIN
  WRITELN;
  WRITELN;
  WRITELN( ' ':12, '1  -  INSERT MODE' );
  WRITELN( ' ':12, '2  -  DELETE MODE' );
  WRITELN( ' ':12, '3  -  DISPLAY MODE' );
  WRITELN( ' ':12, '4  -  STORE DATA ON DISC' );
  WRITELN( ' ':12, '5  -  GET DATA FROM DISC' );
  WRITELN( ' ':12, '8  -  INFORMATION' );
  WRITELN( ' ':12, '9  -  TERMINATE' );
  WRITELN;
  CASE Command OF
   '1': WRITELN( 'MODE=INSERT' );
   '2': WRITELN( 'MODE=DELETE' );
   '3': WRITELN( 'MODE=DISPLAY' );
   '4': WRITELN( 'STORE DATA' );
   '5': WRITELN( 'GET DATA' );
   '8': WRITELN( 'INFORMATION' );
  ELSE: WRITELN
  END{CASE}
END{of MENU};


FUNCTION toupper( ch: CHAR ): CHAR;
BEGIN
  IF ( 'a'<=ch ) AND ( ch<='z' ) THEN ch := CHR(ORD(ch) - 32);
  toupper := ch
END{of toupper};


PROCEDURE INPUT( txt: dstring; VAR answer: shorty );
BEGIN
  WRITE( txt );
  READLN( answer );
END{of INPUT};


PROCEDURE LIST;
VAR	ch : CHAR;
	OUTPUT : TEXT;
BEGIN
  WRITELN( 'Output to C(onsole or P(rinter? ' );
  readln( ch );
  con_wanted := ( toupper(ch)='C' );
  tty_wanted := ( toupper(ch)='P' );
  { one or the other but not both }
  if tty_wanted then con_wanted := false;
  if NOT (con_wanted OR tty_wanted) then
    { listing := false }
  else begin
    { listing := true; }
    if con_wanted then REWRITE( 'CON:', OUTPUT );
    if tty_wanted then REWRITE( 'LST:', OUTPUT );
  end;
  WRITELN; WRITELN;
  Inorder( Employee );
  if con_wanted then begin
    writeln;
    WRITE( bell, 'PRESS RETURN TO CONTINUE ' );
    READLN( ch );
  end
END{of LIST}{ CLOSE( OUTPUT ); };
{LIST can be easily altered to allow writing to a disc file
as a third option.  Do not confuse this with the STORE
procedure found in the DISC module.  LIST outputs the file
in key-sort order(Inorder does this).  STORE uses Preorder
which tends to write the file in a more random fashion.
This is done intentionally so that when the file is later
recovered using the FETCH procedure, the B-tree is somewhat
balanced.
}

PROCEDURE Help;
begin
  writeln('This is an explanatory section to be developed.');
{I made this option availiable, and placed it in
a separate module so it can be easily amplified
without necessitating a recompilation and
reassembly of the main program and all the other
modules.
rab
}
end;
 .
