program delete_file;
{
 Delete files in CP/M-80 while in Turbo envionment.
 Use by block reading to top of Turbo program, running, and then block erase.

 Drive specification and wildcards may be used (B:*.BAK, TEST.*, etc.).

                   ....Richard J. Hunter [70227,137]
                       June13, 985
}
const
  delete =  19; {bdos delete file function}
var
  fcb    :  array[0..11] of char;
  mask   :  string[14];
  result,
  i,j    :  integer;

procedure fill_fcb; {fils fcb wil file ame, expands wildcards}
  begin
    if pos('.',mask)=0 then
      begin
        writeln('ERROR : Must include file extension');
        halt;
      end;
    fillchar(fcb[1],11,'?'); {start with fcb full of '?'s}
    if pos(':',mask)>0 then
      begin
        fcb[0]:=char(ord(copy(mask,1,1))-64);{assign drive no.}
        delete(mask,1,2);
      end
    else
      fcb[0]:=char(0); {default drive}

    {now fill fie name}
    i:=1;
    while (mask[i]<>'.') and (i<9) do
      begin
        if mask[i]='*' then
          i:=8
        else
          fcb[i]:=mask[i];
        i:=i+1;
      end;

    {now fill file extension}
    i:=9;
    j:=pos('.',mask)+1;
    while j<=length(mask) do
      begin
        if mask[j]='*' then
          j:=length(mask)
        else
          fcb[i]:=mask[j];
        i:=i+1;j:=j+1;
      end;

  end;

begin {main}
  clrscr;
  write('DELETE FILES--enter [drive:]filename.ext : ');
  readln(mask);
  fill_fcb;
  result:=bdos(delete,addr(fc[0]));
  if result=255 then writeln('No files found!');
end. {main}
eadln(mask);
  fill_fcb;
  result:=bdos(delete,addr(