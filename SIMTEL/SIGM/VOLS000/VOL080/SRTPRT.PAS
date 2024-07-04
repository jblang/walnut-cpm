EXTERNAL SORT::srtprt(1);

PROCEDURE WriteItems;
VAR
  ptr	: boolean;
  fptr	: file of char;
  printer: char;
  entry  :ItemPointers;
begin
  write('Enter "P" for a printer listing, anything else to skip');
  readln(printer);
  if (printer = 'P') or (printer = 'p') then
    begin
    ptr := true;
    rewrite('lst:',fptr);
    write(fptr,chr(15));	{single space key}
    writeln(fptr,'    File number (ssic) ordered listing');
    writeln(fptr,' SSIC    Subject                         Action  Info');
    end else ptr := false;
  entry := ListHead;
  While entry <> NIL DO
    WITH entry^ DO
      begin
      Write(fout,item);
      if ptr = true then 
         begin
         WITH item do begin
         writeln(fptr,ssic,' ',subj,' ',action,' ',info);
	 end {with}
	 end; {if ptr = true}
      entry := Next
      end;	{with}
    with newitem do
      begin
      ssic := '-----';
      subj := 'end of sort by ssic                          ';
      action := '      ';
      info := 'EOF             ';
      end; {with}
      write(fout,newitem);
end; (* WriteItems *)
 .
