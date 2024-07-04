External btree::disc(2);

PROCEDURE Store;
{ stores contents of tree onto disc }
VAR
  fileroot,
  filename: filestring;
  dummy_end: persondetails;
	{a dummy end of file record is needed because EOF function
	does not work correctly in Pascal/Z.  See page 54}
  slug: shorty;
  i: integer;
  test: boolean;

BEGIN
  { get file name 
  }
  write ('Name of output file - ');
  readln (filename);
  reset(filename,fin);
  if not eof(fin)	{false if file does not exist}
    then begin
         i := 1;
         setlength(fileroot, 0);
         while filename[i] <> '.' do	{strip CPM file type}
           begin
           append( fileroot, filename[i]);
           { filename[i] works ok to READ characters of a string,
           but fileroot[i] will not WRITE characters into the string.
           One of the sneaky differences between strings and arrays
           of characters.}
           i := i + 1;
           end;	{while}
    append(fileroot, '.BAK');
    test := rename (filename, fileroot);
    writeln('Existing ', filename, ' renamed ', fileroot,'.');
    writeln('New ',filename, ' being opened.');
    end;	{then}
  rewrite (filename, fout);
  disc := true;
	{raise flag for use in DISPLAY procedure}
  Preorder ( employee );
  {Preorder is used rather than Inorder so that the tree is stored
  in other than a sorted fashion.  When putting the leaves back
  onto the tree (in FETCH below), inserting them in a sorted order
  will result in a lopsided tree - one pointer in each record will
  always be NIL.  In other words a linked list rather than a full
  b - tree will result.  The program will work, but the speed of
  a balanced tree will be lost.
  }
  slug := '****************************************';
  with dummy_end do
  {for reasons I have been unable to divine, leaving 'city'
  undefined gets a "string too long" fatal error.  Filling
  all fields of the record makes the error go away.  If you
  know why, please tell me.    Buddenberg
  }
    begin
    name := slug;
    company := 'end of file marker';
    address := slug;
    city := slug;
    state := slug;
    zip := slug;
    salary := slug;
    end;	{with}
  write (fout, dummy_end);
END;	{Store}

{$T-}
PROCEDURE Fetch;
{ reads data from disc and causes it to be placed onto tree }
VAR
  filename: string 14;
  fileend: boolean;
  rec: persondetails;
BEGIN
  write ('Name of file where the data is - ');
  readln (filename);
  reset (filename, fin);
  fileend := false;
  while not fileend do
    BEGIN
      read (fin, rec );
    if rec.name = '****************************************'
        then fileend := true;
    if not fileend then
    with rec do
      begin
      key := name;
      new_salary := salary;
      new_company := company;
      new_address := address;
      new_city := city;
      new_state := state;
      new_zip := zip
      end;	{with}
    insert (Employee, key);
  end;	{while}
END;	{fetch}
 .
