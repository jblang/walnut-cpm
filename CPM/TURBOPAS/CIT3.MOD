{ Patch Routine for T-Room by Matt Wing - Find/Replace Routine for editor.}
{ Also some Misc. Routines at the end of file. This is NOT a include file.}
{ You must type this in or use ^K^R in your Wordstar or Turbo Editor.     }
{ August '86 - DST }
{ August '86 - DST Updated error in Replace and More trivial routines..}
{ Sept. '86 - DST Added the upper to lowercase routine. }

{ Add in Cit.Pas - Var define.. }
replace_string,target_string:string[80];

{ Ok, you are under the editcommand loop.. }

if keyin='?' then.. {Example..}
if keyin='S' then..
if keyin='R' then
 begin    { Find/Replace Start }
  writeln('eplace string');
  write('Enter string: ');
  readln(replace_string);
  count:=0;
  count1:=1;
  savecol:=colposition;
  colposition:=1;
  repeat
   begin
    count:=pos(replace_string,editline[count1];
    count1:=count1+1;
   end;
  until (count1>=row) or (count<>0);
  if count<>0 then
   begin
    write('"',replace_string,'" is replaced with =-> ');
    readln(target_string);
    delete(editline[count1-1],count,length(replace_string));
    insert(target_string,editline[count1-1],count);writeln;
    writeln(editline[count1-1]);
    write(' ':count-1);                        {These 3 lines write the }
    for count:=1 to length(target_string) do   { ^'s that point to the  }
     write('^');                               { Correction made..      }
     writeln;
   end;
  if count=0 then writeln('"',replace_string,'" not found. Check spelling.');
  goto editcommand;
 end; { replace string }

{ This next routine is added to Cit.Pas - Allows the user to .Goto rooms }
{ without having to type in the whole room.
Example:
.Goto <space>news
 will take you to 'System News' or whatever room that has 'news' in it.. }
if keyin='.' then..
 if character='G'..
  while count1<=15 do
   begin
    compstring:=rooma[count1];
    upcaseconv(compstring);
{new} if (pos(instring, compstring)>0) then
{replaces 'if compstring=instring then'..}
     begin
       lastread[roompoint]:=nextmessnum-1;
       ...
{ If you add this patch, you also have to switch this routine: }

procedure upcaseconv(var tranchar:word25);
 begin
   len:=length(tranchar);
   oustring:='';
   count:=1;
   while count <= len do
     begin
       character:=tranchar[count];
       if character in ['a'..'z'] then character:=chr(ord(character)-32_;
       outstring:=outstring+character;
       count:=count+1;
     end;
   tranchar:=oustring;
 end;

oh yeah, and add :

if room='Mail' then
writeln('  ',date,' from ',username,' to ',mailname);
(for user's ease..)
if room<>'Mail' then
writeln('  ',date,' from ',username);

And one more thing:
procedure pause;

Add:
 if (chr(kbdin)='P') OR (chr(kbdin)=#$13) then ....

And at the bottom:
 if chr(kbdin)=#$03 then stopflag:=true;
 if chr(kbdin)='S'...

{ This allows ^S and ^C (<P>ause and <S>top) }

AND another thing with the I/O stuff, I modified mine to I/O check only
between words.. like:

Procedure Dumpfile;
begin...
...
begin
 character:=copy(line,count,1)
 write(character);
 count:=count+1;
 if character=' ' then
  pause;
 if stopflag=true then
 begin...
{ Above might just be a nuisance }

{ Ok, finally figured out how to heed the english syntax for the upper to
  lowercase conversion.  Here is the installation routine: }

{ Find editcommand loop under 'Enter message'.. Find the 'S'ave routine}
if keyin='S' then
 begin
   writeln('aving message.');
   buffercnt:=1;...
    ...
    ...
   count:=endpoint+3;
   endpoint:=count+row-1;
   while count<endpoint do
    begin
{ Add >> }  switch(editline[buffercnt], buffercnt); { << Add }
     count:=count+1;
     buffercnt:=buffercnt+1;
     ...

{ Now, under CIT2.PAS or any other include file, insert the following
 procedure :}
 Procedure Switch(var liner: Word80; Num: integer);
 var counter: integer;
     c: char;
     f, caps: boolean;
     sw: string[80];

  begin
    counter:=1;
    f:=true;
   while (counter<=length(liner)) and (f) do
     begin
       c:=liner[counter];
       counter:=counter+1;
       if c in ['a'..'z'] then f:=false
      else
       f:=true
     end;
    if (f) then
     begin
      counter:=1;
      caps:=false;
      sw:='';
    while counter<=length(liner) do
     begin
      c:=liner[counter];
     if (num=1) and (counter=1) then   { Cap 1st letter in 1st line..}
      caps:=true;
     if (c in ['.','(','?','!']) then  { Any more signs I didn't think of?}
      caps:=true;
     if (c in ['A'..'Z']) and (not caps) then
       c:=chr(ord(c)+32);
     if (caps) and (c in ['A'..'Z']) then
      caps:=false;
     sw:=sw+c;
     counter:=counter+1;
    end;
   liner:=sw;
  end;
 end;


{ I originally had this in 2 separate functions and procedures, but figured
 I wouldn't use a 'Check_to_see_if_a_lower_case_letter_exists' procedure
 more than once.. If you want to maintain the modular type programming you
 can break 'em up.. thought I would save a little code space this way.. }

- Dave T.
