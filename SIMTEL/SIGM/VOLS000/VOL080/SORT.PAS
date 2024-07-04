program sort(0);
{insertion sort.  This program is designed to follow the
 data input section.  It sorts the transaction file
into ascending order which is necessary for the merge
program to work correctly.	}

TYPE
  subje = record
	subj		: array[1..45]of char;
	ssic		: array [1..5] of char;
	action		: array [1..6] of char;
	info		: array [1..16] of char;
	acct_number	: array [1..4] of char
	  end;
  ItemRecords  = record
		   item  :subje;
		   Next  :^ItemRecords
		 end;
  ItemPointers = ^ItemRecords;
  str4	= array [1..4] of char;
  str5	= array [1..5] of char;

VAR
  ListHead  :ItemPointers;
  Newitem   :subje;
  done,
  error	    :boolean;
  fin,fout  :file of subje;
  infilename,
  outfilename:string 14;
  i,
  count	: integer;

PROCEDURE Rjust(VAR ssic:str5);
{ssic is a numeric field stored as a string.  In order for a
sort to work properly, it must be right justified.  Any
alphabetics sneaking into the field will be sorted below the
numbers in accordance with the ASCII collating sequence.}
var
  temp	: str5;
  i	: integer;
begin
  temp := '     ';
  while ssic[5] = ' ' do
    begin
    for i := 2 to 5 do
    begin
    temp[i] := ssic[(i-1)];
    end;	{for loop}
    ssic := '     ';	{gotta clear out the string before rewriting}
    ssic := temp;
    end;	{while}
end;	{Rjust}

PROCEDURE Convert(acct_number:str4; VAR count:integer);
begin
count := (((ord(acct_number[1])-48)*1000)+
	  ((ord(acct_number[2])-48)*100 )+
	  ((ord(acct_number[3])-48)*10  )+
	  ((ord(acct_number[4])-48)    ));
end;	{convert procedure}

PROCEDURE InsertItem( Newitem  :subje);
VAR
  entry,
  PriorEntry,
  Newentry 	:ItemPointers;
  Searching	:boolean;
begin
  (* FIND the position where the New item will be Inserted *)
  entry := ListHead;
  Searching := TRUE;
  While Searching and (entry <> NIL) DO
    WITH entry^ DO
{the following IF statement may be changed to sort on any field
of the record 	}
      IF Newitem.ssic < item.ssic then
	Searching := FALSE
      Else
	begin
	PriorEntry := entry;
	entry := Next
	end;
(* CREATE the New entry and Insert it in position *)
  New(Newentry);
  Newentry^.item := Newitem;
  Newentry^.Next := entry;
  IF entry = ListHead then
    ListHead := Newentry
  Else PriorEntry^.Next := Newentry;
end;  (* InsertItem *)

PROCEDURE WriteItems;external;

begin  (* MAIN PROGRAM *)
  ListHead := NIL;  (* MAKE the LIST EMPTY *)
  Writeln(' ':12,'Insertion Sort Using a Linked List');
  writeln;writeln;writeln;
  write(' INPUT FILE: ');
  readln(infilename);
  write(' OUTPUT FILE: ');
  readln(outfilename);
  reset(infilename,fin);
  reset(outfilename,fout);
  if not (eof(fout)) then
    begin
    writeln(' ':12,'        FILE ALREADY EXISTS');
    writeln(' ':12,' Erase it or choose another name');
    end
  else rewrite(outfilename,fout);
  writeln;writeln;writeln;

    Read(fin,Newitem); (* READ the First Item *)
    Convert(Newitem.acct_number,count);
    for i := 2 to count do
	begin
	read(fin,Newitem);
	if (Newitem.ssic <> '     ') and (Newitem.ssic <> 'ZZZZZ')
	  then
	  begin
	  Rjust(newitem.ssic);
	  insertitem(Newitem);
	  end;	{if}
	end;	{for loop}
	(* Insert the New item in its correct position *)
  Writeln(' ':12,'The Sorted List');
  writeln(' ':12,'is being written into ',outfilename);
  (* Write all the Items in order *)
  WriteItems
end. (* SORTLIST *)
