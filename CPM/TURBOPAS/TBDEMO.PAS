(***************************************************************)
(*                                                             *)
(*           TURBO-ACCESS DEMONSTRATION PROGRAM                *)
(*                    Simple Database                          *)
(*                      Version 1.0                            *)
(*                                                             *)
(***************************************************************)

Program ExampleDatabaseToolboxConcepts;

(***************************************************************)
(*  The following constants are required for data structures   *)
(*  internal to the Database Toolbox.  Please see the example  *)
(*  program, SETCONST.PAS (called SCONST.PAS here in DL1 of    *)
(*  SIG), which helps you select optimal values for these      *)
(*  constants.                                                 *)
(***************************************************************)

const
  MaxDataRecSize = 342;
  MaxKeyLen      =  15;
  PageSize       =  16;
  PageStackSize  =  10;
  Order          =   8;
  MaxHeight      =   5;
  NoDuplicates =     0;

(*********************************************************************)
(*  The following include directives load in the Toolbox source code *)
(*********************************************************************)

{$I ACCESS.BOX }    (* Includes the basic data types and file handling *)
{$I ADDKEY.BOX }    (* Includes the AddKey routine                     *)
{$I DELKEY.BOX }    (* Includes the DelKey routine                     *)
{$I GETKEY.BOX }    (* Includes search routines Find, Search, Prev,    *)
                    (* Next and ClearKey.                              *)

(**************************************************************)
(*  The program type definitions can go here.                 *)
(**************************************************************)

TYPE
  CustRec = record
    CustStatus : integer;
    CustCode   : string[15];
    EntryDate  : string[8];
    FirstName  : string[15];
    LastName   : string[30];
    Company    : string[40];
    Addr1      : string[40];
    Addr2      : string[40];
    Phone      : string[15];
    PhoneExt   : string[5];
    Remarks1   : string[40];
    Remarks2   : string[40];
    Remarks3   : string[40];
  end; (* CustRec *)

  FilenameType = string[64];

(**************************************************************)
(*  Global variable are declared here.                        *)
(**************************************************************)

var
  CustFile : DataFile;
  CodeIndx : IndexFile;
  Customer : CustRec;


{  The following code tells you how large to make the MaxDataRecSize
   constant.  If you change the size of you record re-run the code.

   Remove the comment bracket below and then run.  Then replace the bracket. }

               {

    begin
      Writeln('The size of my custrec type is ',SizeOf(CustRec));
      Writeln('The MaxKeyLen is ',sizeof(Customer.CustCode)-1);
    end.
 }

(***********************************************************************)
(*  Utility procedures which can be called from all other procedures   *)
(***********************************************************************)

  procedure Stop;
  begin
    GotoXY(1,24);
    Writeln;
    Writeln;
    Writeln;
    Writeln('Customer database program aborted.');
    Halt;
  end  { Stop execution };

(***********************************************************************)
(*  Open a file if it exist or prompt user if file needs to be created *)
(***********************************************************************)

  procedure OpenDataFile(var CustFile : DataFile;
                             Fname: FilenameType;
                             Size : integer     );
  var
    create : char;
  begin
    OpenFile(CustFile, fname, Size);
    if not OK then
    begin
      Writeln(' The data file: ',fname,' was not found.');
      Write('Do you wish to create it? ');
      Read(KBD, Create);
      Writeln(Create);
      if UpCase(create) = 'Y' then
        MakeFile(CustFile,fname,Size)
      else stop;
    end;
    If not OK Then stop;
  end  { OpenDataFile };


(***********************************************************************)
(*  Obtain customer information from the user to put in the data base  *)
(***********************************************************************)
  procedure InputInformation(var Customer : CustRec);
  begin
    Writeln;
    Writeln(' Enter Customer Information ');
    Writeln;
    with Customer do
    begin
      CustStatus := 0;
      Write('Customer code: '); Readln(CustCode);
      Write('Entry date   : '); Readln(EntryDate);
      Write('First name   : '); Readln(FirstName);
      Write('Last name    : '); Readln(LastName);
      Write('Company      : '); Readln(Company);
      Writeln('Address ');
      Write('   Number & Street   : '); Readln(Addr1);
      Write('   City, State & Zip : '); Readln(Addr2);
      Write('Phone     : '); Readln(Phone);
      Write('Extention : '); Readln(PhoneExt);
      Write('Remarks   : '); Readln(Remarks1);
      Write('Remarks   : '); Readln(Remarks2);
      Write('Remarks   : '); Readln(Remarks3);
    end;
    Writeln;
  end { InputInformation };

(***********************************************************************)
(*  Rebuild index files based on existing data files.                  *)
(***********************************************************************)

  procedure RebuildIndex(VAR CustFile: DataFile;
                         VAR CodeIndex: IndexFile);
  var
    RecordNumber : integer;
  begin
    InitIndex;
    MakeIndex(CodeIndex,'CodeFile.ndx',
              SizeOf(Customer.CustCode)-1,NoDuplicates);
    for RecordNumber := 1 to FileLen(CustFile) - 1 do
    begin
      GetRec(CustFile,RecordNumber,Customer);
      If Customer.CustStatus = 0 then
        AddKey(CodeIndex,RecordNumber,Customer.CustCode);
    end
  end { Rebuild Index };

(***********************************************************************)
(*  Setup index files -- open if exists, create if the user wants to.  *)
(***********************************************************************)

  procedure OpenIndexFile(var CodeIndx : IndexFile;
                              Fname    : FilenameType;
                              KeySize  : integer;
                              Dups     : integer);
  var
    create: char;
  begin
    InitIndex;
    OpenIndex(CodeIndx, Fname,KeySize,Dups);
    if not OK then
    begin
      Writeln(' The index file: ',fname,' was not found.');
      Write('Do you wish to create it? ');
      Read(KBD, Create);
      if UpCase(Create) = 'Y' then
        RebuildIndex(CustFile,CodeIndx)
      else
        Stop;
    end;
    If not OK then Stop;
  end  { OpenIndexFile };

(***********************************************************************)
(*  Place the customer information on the screen to be viewed          *)
(***********************************************************************)

  procedure DisplayCustomer(Customer: CustRec);
  begin
    with Customer do
    begin
      Writeln;
      WriteLn('   Code: ',CustCode,'    Date: ',EntryDate);
      Writeln('   Name: ',FirstName,' ',LastName);
      WriteLn('Company: ',Company);
      Writeln('Address: ',Addr1);
      Writeln('         ',Addr2);
      Writeln('  Phone:',Phone,' ext. ',PhoneExt);
      WriteLn('Remarks: ',Remarks1);
      Writeln('         ',Remarks2);
      WriteLn('         ',Remarks3);
    end;
    Writeln;
  end { Display Customer };

(***********************************************************************)
(*  Access the customer records sequentially  -- no index files.       *)
(***********************************************************************)

    procedure ListCustomers(var CustFile: DataFile);
    var
      NumberOfRecords,
      RecordNumber    : integer;
      Pause           : char;
    begin
      NumberOfRecords := FileLen(CustFile);
      Writeln('                   Customers  ');
      Writeln;
      for RecordNumber := 1 to NumberOfRecords - 1 do
      begin
        GetRec(CustFile,RecordNumber,Customer);
        if Customer.CustStatus = 0 then DisplayCustomer(Customer);
      end;
      Writeln;
      Write(' Press any key to continue . . .');
      Read(KBD,Pause); Writeln;
    end (* ListCustomers *);


(************************************************************************)
(*   Find customer based on customer code                               *)
(************************************************************************)

  procedure FindCustomer(var CustFile: DataFile;
                         var CodeIndx: IndexFile );
  var
    RecordNumber : integer;
    SearchCode   : string[15];
    Pause        : char;

  begin
    Write('Enter the Customer code: '); ReadLn(SearchCode);
    FindKey(CodeIndx,RecordNumber,SearchCode);
    if OK then
    begin
      GetRec(CustFile,RecordNumber,Customer);
      DisplayCustomer(Customer);
    end
    else
      Writeln('A record was not found for the key ',SearchCode);
    Writeln('Press any key to continue . . .');
    Read(KBD,Pause);
  end { FindCustomer };

(************************************************************************)
(*   Search customer based on customer code                             *)
(************************************************************************)

  procedure SearchCustomer(var CustFile: DataFile;
                           var CodeIndx: IndexFile );
  var
    RecordNumber : integer;
    SearchCode   : string[15];
    Pause        : char;
  begin
    Write('Enter the Partial Customer code: '); ReadLn(SearchCode);
    SearchKey(CodeIndx,RecordNumber,SearchCode);
    if OK then
    begin
      GetRec(CustFile,RecordNumber,Customer);
      DisplayCustomer(Customer);
    end
    else
      Writeln('A record was not found greater than the key ',SearchCode);
    Writeln('Press any key to continue  . . .');
    Read(KBD,Pause);
  end { Search Customer };

(************************************************************************)
(*   Next customer based on customer code                               *)
(************************************************************************)

  procedure NextCustomer(var CustFile: DataFile;
                         var CodeIndx: IndexFile );
  var
    RecordNumber : integer;
    SearchCode   : string[15];
    Pause        : char;
  begin
    NextKey(CodeIndx,RecordNumber,SearchCode);
    if OK then
    begin
      GetRec(CustFile,RecordNumber,Customer);
      Write('The next customer is : ');
      DisplayCustomer(Customer);
    end
    else
      Writeln('The end of the database has been reached.');
    Writeln('Press any key to continue  . . .');
    Read(KBD,Pause);
  end { Next Customer };

(************************************************************************)
(*   Previous customer based on customer code                           *)
(************************************************************************)

  procedure PreviousCustomer(var CustFile: DataFile;
                             var CodeIndx: IndexFile);
  var
    RecordNumber : integer;
    SearchCode   : string[15];
    Pause        : char;
  begin
    PrevKey(CodeIndx,RecordNumber,SearchCode);
    if OK then
    begin
      GetRec(CustFile,RecordNumber,Customer);
      Write('The previous customer is : ');
      DisplayCustomer(Customer);
    end
    else
      Writeln('The start of the database has been reached.');
    Writeln('Press any key to continue  . . .');
    Read(KBD,Pause);
  end { Previous Customer };

(****************************************************************************)
(*  AddCustomers inserts records into the data file and keys into the index *)
(****************************************************************************)

  procedure AddCustomer(var CustFile: DataFile;
                        var CodeIndx: IndexFile);
  var
    RecordNumber    : integer;
    Response        : char;
  begin
    repeat
      InputInformation(Customer);
      FindKey(CodeIndx,RecordNumber,Customer.CustCode);
      If not OK then
      begin
        AddRec(CustFile,RecordNumber,Customer);
        AddKey(CodeIndx,RecordNumber,Customer.CustCode);
        Write('Add another record? ');
      end
      else
        Write('Duplicate code exists. Try another code? ');
      Read(KBD,Response); Writeln(UpCase(Response));
    until UpCase(Response) <> 'Y';
  end { Add a Customer };

(****************************************************************************)
(*  DeleteCustomer accepts the customer code and deletes data and key info. *)
(****************************************************************************)
  procedure DeleteCustomer(var CustFile: DataFile;
                           var CodeIndx: IndexFile);
  var
    RecordNumber    : integer;
    Response        : char;
    CustomerCode    : string[15]; { Same as CustRec.CustCode field }
  begin
    repeat
      Write(' Enter code of customer to be deleted: '); Readln(CustomerCode);
      FindKey(CodeIndx,RecordNumber,Customer.CustCode);
      if OK then
      begin
        DeleteKey(CodeIndx,RecordNumber,Customer.CustCode);
        DeleteRec(CustFile,RecordNumber);
        Write('Delete another record? ');
      end
      else
        Write('Customer code was not fould. Try another code? ');
      Read(KBD,Response);
    until UpCase(Response) <> 'Y';
  end { Delete a Customer };

(****************************************************************************)
(* UpdateCustomer show a customer and then allow reentry of information     *)
(****************************************************************************)

  procedure UpdateCustomer(var  CustFile: DataFile;
                           var  CodeIndx: IndexFile);
    var
      RecordNumber    : integer;
      Response        : char;
      CustomerCode    : string[15]; { Same as CustRec.CustCode field }
    begin
      repeat
        Write('Enter code of customer to be updated: ');
        Readln(CustomerCode);
        FindKey(CodeIndx,RecordNumber,CustomerCode);
        if OK then
        begin
          GetRec(CustFile,RecordNumber,Customer);
          DisplayCustomer(Customer);
          InputInformation(Customer);
          PutRec(CustFile,RecordNumber,Customer);
          If CustomerCode <> Customer.CustCode Then
          begin
            DeleteKey(CodeIndx,RecordNumber,CustomerCode);
            AddKey(CodeIndx,RecordNumber,Customer.CustCode);
          end;
          Write('Update another record? ');
        end
        else
          Write('Customer code was not found. Try another code? ');
        Read(KBD,Response); Writeln(UpCase(Response));
      until UpCase(Response) <> 'Y';
  end { Update customer };


(*******************************************************************)
(*                          Main menu                              *)
(*******************************************************************)
  function Menu: char;
  var
    action: char;
  begin
    ClrScr;
    GotoXY(1,3);
    Writeln('   Enter Number or First Letter');
    Writeln;
    Writeln(' 1)  List Customer Records ');
    Writeln(' 2)  Find a Record by Customer Code ');
    Writeln(' 3)  Search on Partial Customer Code ');
    Writeln(' 4)  Next Customer');
    Writeln(' 5)  Previous Customer');
    Writeln(' 6)  Add to Customer Database ');
    Writeln(' 7)  Edit a Customer Record ');
    Writeln(' 8)  Delete a Customer Record ');
    Writeln(' 9)  Rebuild Index files ');
    Writeln(' 0)  Exit ');
    Writeln(' ');
    Read(KBD,Action);
    Writeln;
    Menu := UpCase(action);
  end { menu };

(***********************************************************************)
(*                            Main program                             *)
(***********************************************************************)
var
  Finished: Boolean;
begin
  Finished := false;
  OpenDataFile(CustFile,'CustFile.dat',SizeOf(CustRec));
  OpenIndexFile(CodeIndx,'CodeFile.Ndx',
                SizeOf(Customer.CustCode)-1,NoDuplicates);
  repeat
    case Menu of
      '1','L': ListCustomers(CustFile);
      '2','F': FindCustomer(CustFile,CodeIndx);
      '3','S': SearchCustomer(CustFile,CodeIndx);
      '4','N': NextCustomer(CustFile,CodeIndx);
      '5','P': PreviousCustomer(CustFile,CodeIndx);
      '6','A': AddCustomer(CustFile,CodeIndx);
      '7','U': UpdateCustomer(CustFile,CodeIndx);
      '8','D': DeleteCustomer(CustFile,CodeIndx);
      '9','R': RebuildIndex(CustFile,CodeIndx);
      '0','E': Finished := true;
      else     Write('Choose 0-9: ');
    end; { case }
  until Finished;
  CloseIndex(CodeIndx);
  CloseFile(CustFile);
end.
