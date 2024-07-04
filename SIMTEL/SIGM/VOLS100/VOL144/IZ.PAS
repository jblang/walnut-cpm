{$e+,p+,i+}
 
Program IZ;
 
{A program to translate assembly-language assembler programs from Intel or}
{TDL mnemonics to Zilog mnemonics.  Accepts a filename to which .ASM is}
{appended to yield the assembler file name and to which .MAC is appended}
{for the translated file name.  Assemble the translated program with M80.}
 
  const
	serial		= 45;
	cr		= 13;
	space		= 32;
	tab		= 9;
	semic		= 59;
	colon		= 58;
	quote1		= 39;
	quote2		= 34;
	excl		= 33;
	comma		= 44;
	lparen		= 40;
	rparen		= 41;
	lbrack		= 91;
	rbrack		= 93;
	langle		= 60;
	rangle		= 62;
	at		= 64;
	hash		= 35;
	ampersand	= 38;
	percent		= 37;
	caret		= 94;
 
  type
	delim		= quote2 .. quote1;
	$string0	= string 0;
	$string255	= string 255;
	$string80	= string 80;
	$str20		= string 20;
	asmf		= file of char;
	label_info	= record
			    colons:	string 2;
			    the_label:	$str20
			  end;
	instruction	= record
			    raw_opcode: string 12;
			    uc_opcode:  string 12;
			    max_colons: integer;
			    op_start:	integer
			  end;
	argument	= record
			    raw_arg,
			    uc_arg:	$string80;
			    arg_start:	integer
			  end;
	comments	= record
			    comment:	string 100;
			    com_start:  integer
			  end;
	opcode		= array [1..12] of char;
	a4		= array [1..4] of char;
	arg_action	= (asis,base,p,r8,r16,r16p,m);
	language	= (any,I8080,TDL);
	iz_ptr		= ^iztab;
	iztab		= record
			    i_opcode:		opcode;
			    z_opcode:		opcode;
			    prefix,
			    infix1,
			    infix2,
			    suffix:		a4;
			    action_1:		arg_action;
			    action_2:		arg_action;
			    reversed:		boolean;
			    max_colons:		integer;
			    next_iz:		iz_ptr;
			  end;
 
  var
	assembler:	language;
	locwarning,
	display,
	extlabels,
	held:		boolean;
	iz_first,
	iz_entry:	iz_ptr;
	intel,
	zilog:		asmf;
	trec,
	irec,
	zrec:		$string255;
	source_lines,
	Z80_lines,
	translations,
	si,				{index into assembler image (irec)}
	sp:		integer;
	lower_case,
	expops,
	id,
	idstart:	set of char;
	a_label:	label_info;
	a_instruction:	instruction;
	arg1,
	arg2:		argument;
	a_comment:	comments;
	reg16:		array[1..12] of string 3;
 	$delim:		delim;

function length(s: $string255): integer;		external;
 
procedure setlength(var s: $string0; l:integer);	external;
 
function index(s, t: $string255): integer;		external;

function upcase(i:$string80): $string80;
  var
	x:	integer;
begin
  for x:=1 to length(i) do
    if i[x] in lower_case then
      i[x] := chr(ord(i[x])-32)
    else
      if i[x] = '%' then
	i[x] := '?';
  upcase := i
end {upcase};

procedure combine;
  var
	pref,
	inf1,
	inf2,
	suff:	a4;
	rev:	boolean;
	x:	integer;
  procedure insert(extra:a4);
    var
	ex:	integer;
	nb:	boolean;
    begin
      x := 5;
      repeat
	x := x-1;
	nb := (extra[x] <> ' ')
      until (x=1) or nb;
      if nb then
	for ex := 1 to x do
	  append(zrec,extra[ex]);
    end {insert};
begin
  if iz_entry = nil then
    begin
      pref := '    ';
      suff := '    ';
      inf1 := '    ';
      inf2 := '    ';
      rev := false
    end
  else
    with iz_entry^ do
      begin
        pref := prefix;
	suff := suffix;
	inf1 := infix1;
	inf2 := infix2;
	rev := reversed
      end;
  zrec := '';
  with a_label do
    begin
      if a_instruction.max_colons = 0 then
	colons := ''
      else
	if (length(colons) = 0) and (length(the_label) <> 0) then
	  colons := ':';
      append(zrec,the_label);
      append(zrec,colons);
      if length(zrec) > 8 then
	begin
	  if display then
	    writeln(zrec);
	  writeln(zilog,zrec);
	  Z80_lines := Z80_lines+1;
	  zrec := ''
	end;
      if length(zrec) <> 8 then
	append(zrec,chr(tab))
      else
	if length(colons)=0 then
	  append(zrec,' ')
    end;
  append(zrec,a_instruction.uc_opcode);
  append(zrec,chr(tab));
  if rev then
    begin
      arg1.raw_arg := arg2.uc_arg;
      arg2.uc_arg := arg1.uc_arg;
      arg1.uc_arg := arg1.raw_arg
    end;
  insert(pref);
  append(zrec,arg1.uc_arg);
  insert(inf1);
  if length(arg2.uc_arg) > 0 then
    append(zrec,',');
  insert(inf2);
  append(zrec,arg2.uc_arg);
  insert(suff);
  if length(a_comment.comment) > 0 then
    if a_comment.com_start = 1 then
      zrec := a_comment.comment
    else
      begin
	append(zrec,chr(tab));
	append(zrec,a_comment.comment)
      end
end {combine};
 
function xy(arg:$string80): $string80;
  var
	b:		$string80;
	la:		integer;
begin
  la := length(arg);
  if (la <= 3) or (assembler <> TDL) then
    xy := arg
  else
    if (arg[la]=')') and
       ((arg[la-1]='X') or (arg[la-1]='Y')) and
       (arg[la-2]='(') then {we have an IX- or IY-indexed operand}
      begin
	b := '(I';
	append(b,arg[la-1]);
	setlength(arg,la-3);
	if arg[1] <> '-' then
	  append(b,'+');
	append(b,arg);
	append(b,')');
	xy := b
      end
    else
      xy := arg
end;
 
procedure relocate(var operand:argument;var op:instruction);
  type
	loc = (dseg,cseg,bcommon,ncommon,org);
  var
	x:	integer;
  function analysearg(arg:$string80): loc;
    var
	x:	integer;
	b:	boolean;
	s:	set of char;
	trunk:	$string80;
  begin
    s := id + ['#'];
    trunk := arg;
    setlength(trunk,6);
    case index('.BLNK..PROG..DATA.',trunk) of
1:    analysearg := bcommon;
7:    analysearg := cseg;
13:   analysearg := dseg;
else: begin
	b := true;
	for x:=1 to length(arg) do
	  b := b and (arg[x] in s);
	if b then
	  analysearg := ncommon
	else
	  analysearg := org
      end
    end {case}
  end {analysearg};

begin
  case analysearg(operand.uc_arg) of
dseg:
    begin
      operand.uc_arg := '';
      op.uc_opcode := 'DSEG'
    end;
cseg:
    begin
      operand.uc_arg := '';
      op.uc_opcode := 'CSEG'
    end;
bcommon:
    begin
      operand.uc_arg := '';
      op.uc_opcode := 'COMMON'
    end;
ncommon:
    begin
      operand.uc_arg := '/';
      for x:=1 to length(operand.raw_arg) do
	if operand.raw_arg[x] <> '#' then
	  append(operand.uc_arg,operand.raw_arg);
      append(operand.uc_arg,'/');
      op.uc_opcode := 'COMMON'
    end;
org:
    operand.uc_arg := operand.raw_arg
  end;
  locwarning := true
end {relocate};

function txarg(arg:argument;arg_no:integer): $string80;
  var
	oa:		arg_action;
	ai:		integer;
begin
  if iz_entry = nil then
    oa := asis
  else
    if arg_no = 1 then
      oa := iz_entry^.action_1
    else
      oa := iz_entry^.action_2;
  ai := 1;
  case oa of
r8:
    if arg.uc_arg = 'M' then
      arg.uc_arg := '(HL)'
    else
      arg.uc_arg := xy(arg.uc_arg);
r16:
    begin
      while (ai < 7) and (arg.uc_arg <> reg16[ai]) do
	ai := ai+1;
      if ai < 7 then {found 16-bit register argument}
        arg.uc_arg := reg16[ai+6]
    end;
r16p:
    begin
      while (ai < 7) and (arg.uc_arg <> reg16[ai]) do
	ai := ai+1;
      if ai < 7 then {found 16-bit register argument}
	begin
	  arg.uc_arg := '(';
	  append(arg.uc_arg,reg16[ai+6]);
	  append(arg.uc_arg,')')
	end
    end;
p:
    begin
      arg.uc_arg := '(';
      append(arg.uc_arg,arg.raw_arg);
      append(arg.uc_arg,')')
    end;
base:
   {if assembler=tdl then}      {this type only occurs in TDL programs}
      relocate(arg,a_instruction);
else:
    arg.uc_arg := arg.raw_arg
  end;
  txarg := arg.uc_arg
end {txarg};
 
function findarg(action:arg_action):	argument;
  var
      brackets,
      x:		integer;
      arg:		argument;
      in_id,
      in_string,
      in_arg:		boolean;

  procedure radnot;
    const
	bin1	=	66;
	bin2	=	98;
	dec1	=	68;
	dec2	=	100;
	hex1	=	72;
	hex2	=	104;
	oct1	=	79;
	oct2	=	111;
	oct3	=	81;
	oct4	=	113;
    var
	hex:		boolean;
	radix:		char;
	digits:		set of '0' .. 'f';
    begin
      if si < length(irec) then
	if irec[si+1] in ['b','B','d','D','h','H','o','O','q','Q'] then
	  begin
	    si := si+1;
	    radix := irec[si];
	    hex := false;
	    case ord(irec[si]) of
bin1,bin2:    digits := ['0','1'];
dec1,dec2:    digits := ['0' .. '9'];
hex1,hex2:    begin
		digits := ['0' .. '9','A' .. 'F','a' .. 'f'];
		hex := true
	      end;
oct1,oct2,
oct3,oct4:    digits := ['0'..'7']
	    end;
	    if hex and (ord(irec[si+1])>ord('9')) then
	      append(arg.raw_arg,'0');
	    while (si<length(irec)) and (irec[si+1] in digits) do
	      begin
		si := si+1;
		append(arg.raw_arg,irec[si])
	      end;
	    append(arg.raw_arg,radix)
	  end
	else
	  append(arg.raw_arg,'not ')
      else
	append(arg.raw_arg,'^')
    end;

begin
  in_arg := false;
  while (si <= length(irec)) and not in_arg do
    begin
      case ord(irec[si]) of
space:
	sp := sp+1;
tab:
	sp := (sp-1) div 8 * 8 + 9;
else:
	begin
	  in_arg := true;
	  arg.arg_start := sp;
	  si := si-1
	end
      end;
      si := si+1
    end;   
  arg.raw_arg := '';
  in_string := false;
  brackets := 0;
  in_id := false;
  while (si <= length(irec)) and in_arg do
    begin
      case ord(irec[si]) of
comma:
	begin
	  in_id := false;
	  in_arg := in_string or (brackets <> 0) or (action = m);
	  if in_arg then
	    append(arg.raw_arg,irec[si])
	end;
quote1,
quote2:
	begin
	  in_id := false;
	  if in_string then
	    in_string := ord(irec[si]) <> $delim
	  else
	    begin
	      in_string := true;
	      $delim := ord(irec[si])
	    end;
	  append(arg.raw_arg,irec[si])
	end;
lparen:
	begin
	  in_id := false;
	  if not in_string then
	    brackets := brackets+1;
	  append(arg.raw_arg,irec[si])
	end;
rparen:
	begin
	  in_id := false;
	  if not in_string then
	    brackets := brackets-1;
	  append(arg.raw_arg,irec[si])
	end;
tab:
	begin
	  in_id := false;
	  sp := (sp-1) div 8 * 8 + 8;
	  if in_string or (brackets > 0) then
	    append(arg.raw_arg,irec[si])
	  else
	    in_arg := false
	end;
semic:
	begin
	  in_id := false;
	  if in_string or (brackets > 0) then
	    append(arg.raw_arg,irec[si])
	  else
	    begin
	      si := si-1;
	      in_arg := false
	    end
	end;
excl:
	begin
	  in_id := false;
	  if in_string then
	    append(arg.raw_arg,irec[si])
	  else
	    if assembler=tdl then
	      append(arg.raw_arg,' or ')
	    else
	      begin
		trec := '	'; {...there's a tab in there}
		si := si+1;
		for sp:=si to length(irec) do
		  append(trec,irec[sp]);
		sp := 0;
		held := (length(trec)>1);
		setlength(irec,si-2)
	      end
	end;
rangle:
	if in_string then
	  append(arg.raw_arg,irec[si])
	else
	  begin
	    in_id := false;
	    if assembler=tdl then
	      append(arg.raw_arg,' shr ')
	    else
	      begin
		brackets := brackets-1;
		append(arg.raw_arg,irec[si])
	      end
	  end;
langle:
	if in_string then
	  append(arg.raw_arg,irec[si])
	else
	  begin
	    in_id := false;
	    if assembler=tdl then
	      append(arg.raw_arg,' shl ')
	    else
	      begin
		brackets := brackets+1;
		append(arg.raw_arg,irec[si])
	      end
	  end;
hash:
	begin
	  if in_string or (assembler<>tdl) then
	    append(arg.raw_arg,irec[si])
	  else
	    if in_id then
	      append(arg.raw_arg,'##')
	    else
	      append(arg.raw_arg,'not ');
	  in_id := false
	end;
at:
	if in_string or (assembler<>tdl) then
	  append(arg.raw_arg,irec[si])
	else
	  begin
	    append(arg.raw_arg,' mod ');
	    in_id := false
	  end;
ampersand:
	begin
	  in_id := false;
	  if in_string or (assembler<>tdl) then
	    append(arg.raw_arg,irec[si])
	  else
	    append(arg.raw_arg,' and ')
	end;
caret:
	begin
	  in_id := false;
	  if in_string or (assembler<>tdl) then
	    append(arg.raw_arg,irec[si])
	  else
	    radnot
	end;
percent:
	if in_string or (assembler<>tdl) then
	  append(arg.raw_arg,irec[si])
	else
	  begin
	    append(arg.raw_arg,'@');
	    in_id := true
	  end;
else:
	begin
	  append(arg.raw_arg,irec[si]);
	  in_id := ((irec[si] in idstart) and not in_id)
		or ((irec[si] in id) and in_id)
		and not in_string
	end
      end;
      sp := sp+1;
      si := si+1
    end;
  x := length(arg.raw_arg);
  if (x>0) and (arg.raw_arg[1]='.') then
    if (x=1) or (arg.raw_arg[2]='-') or (arg.raw_arg[2]='+') then
      arg.raw_arg[1] := '$';
  if x>0 then
    begin
      in_arg := false;
      repeat
	in_arg := (arg.raw_arg[x]<>' ') and (arg.raw_arg[x]<>'	');
	if not in_arg then
	  begin
	    x := x-1;
	    in_arg := (x=0)
	  end
      until in_arg;
      setlength(arg.raw_arg,x);
    end;
  arg.uc_arg := upcase(arg.raw_arg);
  findarg := arg
end {findarg};
 
function remarks: comments;
  var
      in_c:	boolean;
      c:	comments;
begin
  in_c := false;
  c.com_start := sp;
  while (si <= length(irec)) and not in_c do
    begin
      case ord(irec[si]) of
space:
	sp := sp+1;
tab:
	sp := (sp-1) div 8 * 8 + 9;
else:
	begin
	  c.com_start := sp;
	  in_c := true;
	  si := si-1
	end
      end;
      si := si+1
    end;   
  c.comment := '';
  while si <= length(irec) do
    begin
      append(c.comment,irec[si]);
      si := si+1
    end;
  remarks := c
end {remarks};

function findlabel: label_info;
  var
      l:	label_info;
begin
  si := 1;
  with l do
    begin
      colons := '';
      the_label := '';
      if (length(irec)>0) and (irec[1] in idstart) then 
        while (si<=length(irec)) and (irec[si] in id) do
          begin
	    if irec[si] = '%' then
	      irec[si] := '?';
            append(the_label,irec[si]);
            si := si+1
          end;
      if si > 1 then {found a label}
	begin
          while (si <= length(irec)) and (irec[si] = ':') do
            begin
              if length(colons) < 2 then
                append(colons,':');
              si := si+1
            end;
	  if extlabels then
	    colons := '::'
	end
    end;
  sp := si;
  findlabel := l
end {findlabel};
 
function txinstruction: instruction;
  var
      x:		integer;
      i:		instruction;
      found,
      in_op:		boolean;
      i_op,
      z_op:		opcode;
begin
  with i do
    begin
      raw_opcode := '';
      uc_opcode := '';
      in_op := false;
      op_start := sp;
      while (si<=length(irec)) and not in_op do
        begin
          case ord(irec[si]) of
space:	    op_start := op_start+1;
tab:	    op_start := (op_start-1) div 8 * 8 + 9;
else:	    begin
	      in_op := true;
	      si := si-1
	    end
	  end;
	  si := si+1
        end
    end;
  iz_entry := nil;
  if (si<=length(irec)) and (irec[si] in idstart) then
    begin
      with i do
        begin
          while (si<=length(irec)) and (irec[si] in id) do
            begin
              append(raw_opcode,irec[si]);
              si := si+1
            end;
          uc_opcode := upcase(raw_opcode);
	  if length(uc_opcode) > 0 then
	    begin
	      i_op := '            ';
	      for x:=1  to length(uc_opcode) do
		i_op[x] := uc_opcode[x];
	      iz_entry := iz_first;
	      found := false;
	      while (iz_entry <> nil) and not found do
		begin
		  found := (i_op = iz_entry^.i_opcode);
		  if not found then
		    iz_entry := iz_entry^.next_iz
		end;
	      max_colons := 2;
	      if found then
		begin
		  translations := translations+1;
		  max_colons := iz_entry^.max_colons;
		  z_op := iz_entry^.z_opcode;
		  uc_opcode := '';
		  for x:=1 to 12 do
		    if z_op[x] <> ' ' then
		      append(uc_opcode,z_op[x]);
		end
	    end
        end
    end;
  sp := i.op_start + length(i.raw_opcode);
  txinstruction := i
end {txinstruction};

procedure iread;
  var
	iztable:	file of char;
	a8,
	b8:		array [1..8] of char;
	x:		integer;
	source:	language;
	top:		iz_ptr;
begin
  reset('IZ.DAT',iztable);
  iz_first := nil;
  while not eof(iztable) do
    begin
      mark(top);
      new(iz_entry);
      with iz_entry^ do
	begin
          readln(iztable,a8,b8,prefix,infix1,infix2,suffix,
		 action_1,action_2,reversed,max_colons,source);
	  if (source=any) or (source=assembler) then
	    begin
	      for x:=1 to 8 do
		begin
		  i_opcode[x] := a8[x];
		  z_opcode[x] := b8[x]
		end;
	      for x:=9 to 12 do
		begin
		  i_opcode[x] := ' ';
		  z_opcode[x] := ' '
		end;
	      next_iz := iz_first;
	      iz_first := iz_entry
	    end
	  else
	    release(top)
        end
    end
end {iread};
 
procedure settitle;
  label
	45,
	85;
  var
	asm:		boolean;
	scratch:	array[1..14] of char;
	c,x,y:		integer;
begin
  lower_case := ['a'..'z'];
  writeln(chr(12),'Intel/TDL to Z80 assembly source translator ',
	  '- version 2.1, serial number ',serial:1);
  writeln(chr(10),'Copyright  C1982 by:',chr(9),'John Hastwell-Batten',chr(13),
	  chr(10),chr(9),chr(9),chr(9),'38 Silvia Street, Hornsby, NSW 2077',
	  chr(13),chr(10),chr(9),chr(9),chr(9),'(02) 477 4225',chr(10));
  scratch := '              ';
  if (scratch[1] = chr(cr)) or (scratch[1] = ' ') then
    begin
      write('Enter name of .ASM file to be translated: ');
      readln(scratch)
    end;
  asm := true;
  x := 1;
  while (x < 15) and (ord(scratch[x]) <> cr) and (scratch[x] <> ' ') do
    begin
      if scratch[x] in lower_case then
        scratch[x] := chr(ord(scratch[x])-32)
      else
	if scratch[x] = '.' then
	  begin
	    asm := false;
	    y := x+1
	  end;
      x := x+1
    end;
  if asm then
    begin
      scratch[x] := '.';
      scratch[x+1] := 'A';
      scratch[x+2] := 'S';
      scratch[x+3] := 'M';
      y := x+1
    end;
  write('Translating ',scratch:0);
  reset(scratch,intel);
  scratch[y] := 'M';
  scratch[y+1] := 'A';
  scratch[y+2] := 'C';
  rewrite(scratch,zilog);
  writeln(' to ',scratch:0);
  assembler := any;
  repeat
    write('Is this program in Intel or TDL mnemonics? ');
    readln(scratch);
    if (scratch[1] = 't') or (scratch[1]='T') then
      assembler := TDL
    else
      if (scratch[1]='i') or (scratch[1]='I') then
 	assembler := I8080
  until assembler <> any;
45:
  write('Do you want all labels declared global? ');
  readln(scratch);
  if (scratch[1]='Y') or (scratch[1]='y') then
    extlabels := true
  else
    if (scratch[1]='N') or (scratch[1]='n') then
      extlabels := false
    else
      begin
	writeln('Please answer the question...');
	goto 45
      end;
85:
  write('Do you want the translation displayed? ');
  readln(scratch);
  if (scratch[1]='Y') or (scratch[1]='y') then
    display := true
  else
    if (scratch[1]='N') or (scratch[1]='n') then
      display := false
    else
      begin
	writeln('Please answer the question...');
	goto 85
      end
end; {of settitle}
 
procedure initset;
begin
  source_lines := 0;
  translations := 0;
  Z80_lines := 1;	{We always write the .Z80 line}
  id := ['a'..'z','A'..'Z','0'..'9','$','.','_','?','@','='];
  if assembler = tdl then
    id := id - ['_','?','@'] + ['%'];
  idstart := id - ['0'..'9'];
  reg16[1] := 'PSW';
  reg16[2] := 'B';
  reg16[3] := 'D';
  reg16[4] := 'H';
  reg16[5] := 'X';
  reg16[6] := 'Y';
  reg16[7] := 'AF';
  reg16[8] := 'BC';
  reg16[9] := 'DE';
  reg16[10] := 'HL';
  reg16[11] := 'IX';
  reg16[12] := 'IY'
end {initset};

{MAIN PROGRAM}

begin
  settitle;
  initset;
  iread;
  writeln(zilog,'	.Z80	;Accept Z80 instruction format');
  if display then
    writeln    ('	.Z80	;Accept Z80 instruction format');
  held := false;
  while held or not eof(intel) do
    begin
      if held then
	begin
	  irec := trec;
	  held := false
	end
      else
	begin
          readln(intel,irec);
	  source_lines := source_lines+1
	end;
      if display then
	writeln(irec);
      if length(irec) > 0 then
        if irec[1] = ';' then
	  begin
	    writeln(zilog,irec);
	    Z80_lines := Z80_lines+1
	  end
	else
          begin
	    a_label := findlabel;
	    a_instruction := txinstruction;
	    arg1 := findarg(iz_entry^.action_1);
	    arg2 := findarg(iz_entry^.action_2);
	    arg1.uc_arg := txarg(arg1,1);
	    arg2.uc_arg := txarg(arg2,2);
	    a_comment := remarks;
	    combine;
	    writeln(zilog,zrec);
	    Z80_lines := Z80_lines+1;
	    if display then
	      begin
		writeln(zrec);
		writeln
	      end
	  end;
    end;
  writeln(chr(10),chr(10),source_lines:1,' assembler lines were read,');
  writeln(translations:1,' lines were translated,');
  writeln(Z80_lines:1,' lines of Zilog code were produced.');
  if locwarning then
    begin
      writeln;
      writeln('WARNING: Check all relocation bases for accuracy!')
    end
end.
