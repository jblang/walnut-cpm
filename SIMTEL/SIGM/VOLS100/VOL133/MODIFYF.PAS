EXTERNAL EDITFILE::MODIFY(2);

Function INRE : integer;
{This is the original INREC function; it is used by MODIFY and
has been renamed INRE because a heavily altered INREC is used by
BUILD}
{
GLOBAL
	valid_build : boolean }
LABEL	10;
VAR	Alfa : STRING 20;
	j :integer;
	valid : boolean;
begin
  Write(' Enter TAG .......... ');
  REPEAT
    READLN(j);
    valid := false;
    IF j>99 then
      begin
	j := 200;
	{exit} goto 10
      end;
    If  (j=0) or (j=1) or (j=2) or
	(j=4) or (j=6) or (j=99) then
      begin{If valid}
        valid := true;
	NBUFFER.tag := j ;
	WITH NBUFFER DO
	  CASE TAG OF
	  0:    begin
		SETLENGTH(NAME,0);
		write(' Program Name........ ');
		READLN(ALFA);
		If Length(ALFA)>20 then SETLENGTH(ALFA,20);
		APPEND(NAME,ALFA);
		write(' No. ROWS............ ');
		READLN(N1);
		write(' No. Columns......... ');
		READLN(N2)
		end;
	  1:    begin
		write(' Header.............. ');
		READLN(header)
		end;
	  2:    begin
		write(' ROW Name............ ');
		READLN(RNAME);
		write(' ROW No. ............ ');
		READLN(RINDEX);
		write(' RHS ................ ');
		READLN(RHS)
		end;
	  4:    begin
		write(' Column Name ........ ');
		READLN(CNAME);
		write(' Column No. ......... ');
		READLN(CINDEX);
		write(' OBJ ................ ');
		READLN(OBJ)
		end;
	  6:    begin
		write(' ROW NO. ............ ');
		READLN(R);
		write(' Column No. ......... ');
		READLN(S);
		write(' ABAR[R,S] .......... ');
		READLN(T)
		end;
	  99:   valid_build := true
	  End{With/CASE}
      end{If valid}
    Else
      Write('INVALID TAG, Reenter ---> ')
  UNTIL valid{TAG};
10: INRE := j
End{of INRE};

Procedure MODIFY;
LABEL	3 {File not found};
VAR	OLDF,		(*---File descriptors <FCB>---*)
	NEWF	: LINEAR;
	REC, j : integer;
	ans : char;
begin
  GETID(OFIL,' Modify what File? ');
  RESET(OFIL, OLDF);	 (*---RESET( <FID> , <FCB> )---*)
  If EOF(OLDF) then
    begin
    writeln(bell,'File ',OFIL,'not found');
    {exit}goto 3
    end;
  GETID(NFIL,' Name of New File? ');
  {--------------------------------------------------------
	WITH PASCAL/Z, THE ACT OF OPENING A NEW FILE
	USING THE SAME <FCB> CLOSES THE PREVIOUS FILE
	BEFORE OPENING THE NEW FILE.
   --------------------------------------------------------}
  REWRITE(NFIL,NEWF);	 (*---REWRITE( <FID> , <FCB> )---*)
  Write(' Starting at which Record? ');
  READLN(J);
  If J>0 then begin
	{Copy previous records from the old file
	 starting at the first record up to but not
	 including the requested record.}
      REC := 0;
      REPEAT
	READ(OLDF:REC+BIAS,OBUFFER); XEOF := (OBUFFER.TAG=99);
	WRITE(NEWF, OBUFFER);
	REC := REC + 1;
      UNTIL XEOF OR (REC = J);
    END;
  REC := J;
  READ(OLDF:REC+BIAS,OBUFFER);
  XEOF := (OBUFFER.TAG=99);
  While not XEOF do
    begin
    PRINT(OBUFFER,REC);
    writeln(' Process this Record?');
    REPEAT
      valid := true;
      write(' K(eep, C(hange, I(nsert, D(elete   >');
      KEYIN(ANS);WRITELN(ANS);
      CASE ans of
	'K','k': begin
		 write(NEWF,OBUFFER);
		 REC := REC + 1
		 end;
	'C','c': begin
		 If INRE < 100 then write(NEWF, NBUFFER);
		 REC := REC + 1
		 end;
	'D','d': REC := REC + 1;
	'I','i': If INRE < 100 then write(NEWF,NBUFFER);
	ELSE:    begin
		 write(BELL);
		 valid := false
		 end
      End{case};
    UNTIL VALID{ANSWER};
    READ(OLDF:REC+BIAS,OBUFFER);
    XEOF := (OBUFFER.TAG=99);
    End{while not XEOF};
{---Write the End_Of_File record to the New file---}
  Write(NEWF,OBUFFER);
3:	{file not found}
End{of MODIFY};
 .
