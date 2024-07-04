{       Pascal/Z compiler options               }
{$C- <<<control-c keypress checking OFF>>>}
{$M- <<<int mult & divd error checking OFF>>>}
{$F- <<<floating point error checking OFF>>>}

PROGRAM BTREE(0);
{for notes, see .doc file}
{ associated separately compiled modules:
DELETE     (1)     CONTAINS DELETE-FROM-TREE PROCEDURES
DISC       (2)     CONTAINS STORE AND FETCH TO/FM DISC PROCEDURES
ORDER      (3)     CONTAINS INORDER, PREORDER, POSTORDER PROCEDURES
MENU       (4)     CONTAINS MENU AND SEVERAL UTILITY/MISC PROCEDURES
}
CONST
  default = 80;
  vers    =  5; { PROGRAM VERSION NUMBER }

TYPE
  alpha    = packed array [1..10] of char;
  int      = integer;
  str0     = string 0;
  shorty   = string 40;
  dstring  = string default;
  str255   = string 255;

  PersonDetails = RECORD
		    Name,		{ KEY FIELD }
		    Company,
		    address,
		    city,
		    state,
		    zip,
		    salary : shorty;
   	          END;

  apointer  = ^PERSON;

  PERSON = RECORD
	        details : PersonDetails;
		Left,
		Right  : apointer
	     END;

  filestring = string 14;

VAR
  bell		: char;
  Command	: CHAR;
  disc,
  con_wanted,
  tty_wanted    : boolean;
  answer        : shorty;	{ Console inputs here }

  KEY,				{ Name field is the "KEY" field }
  New_Salary,
  New_Company,
  New_address,
  New_City,
  New_State,
  New_Zip        : shorty;

  fout,
  fin,
  STDOUT        : FILE OF PersonDetails;

  Employee	: apointer;



function length( x: str255 ): int; external;

function index( x,y: str255 ): int; external;

procedure setlength( var x:str0; y: int ); external;

function rename( oldfile, newfile: filestring): boolean; external;

PROCEDURE InitTree( VAR Employee : apointer );
{  initialize the tree to empty  }
BEGIN
  Employee := NIL
END{of InitTree};


PROCEDURE INSERT( VAR Employee : apointer;
		      key : shorty );
{ insert key into the tree. If it }
{ is there already then do nothing }
BEGIN
  IF Employee = NIL THEN BEGIN
    NEW(Employee);
    WITH Employee^, details DO BEGIN
	Name    := key;
	Salary  := New_Salary;
	Company := New_Company;
	address := New_address;
	City    := New_City;
	State   := New_State;
	zip     := New_Zip;
	left    := NIL;
	right   := NIL
    END{WITH}
  END
  ELSE IF key = Employee^.details.Name THEN
    WRITELN( bell, key,' already in data file' )
  ELSE IF key < Employee^.details.Name THEN
    Insert( Employee^.left, key )
  ELSE IF key > Employee^.details.Name THEN
    Insert( Employee^.right, key )
END{of INSERT};


PROCEDURE DeleteLeftMost( VAR Employee : apointer;
			  VAR DeleteName : shorty );
     external;
{ delete the leftmost node in the tree and }
{  returns its value in DeleteName	   }

PROCEDURE DeleteRoot( VAR Employee : apointer );
     external;
{ deletes the root of the nonempty tree by replacing it  }
{ by its successor (or child) if it has only one, or     }
{ replacing its value by that of the leftmost descendant }
{ of the rightmost subtree.				 }

PROCEDURE Delete( VAR Employee : apointer;
		      key : shorty );
     external;
{ delete key from the tree--if it is not }
{ in the tree, do nothing		  }

PROCEDURE DISPLAY( Employee: apointer );
BEGIN
 IF NOT disc THEN BEGIN
  WITH Employee^.details do begin
    writeln( Name );
    if length( Company ) > 0 then writeln( Company );
    if length( address ) > 0 then writeln( address );
    writeln( City, ', ', State, ' ', Zip );
    writeln
  end	{with}
 end	{if}
 else write (fout, employee^.details);
END{of DISPLAY};


PROCEDURE Store; external;
{  stores the tree onto disc  }

PROCEDURE Fetch; external;
{  gets tree from disc  }

PROCEDURE Help; external;
{  calls an explanation  }

PROCEDURE Preorder( Employee : apointer );
     external;
{  prints data from left side of tree to right  } 

PROCEDURE Inorder( Employee : apointer );
     external;
{  prints data outer to inner of tree  }

PROCEDURE Postorder( Employee : apointer );
    external;
{  prints data from leaves first then branchs  }

{****************************}
{***   UTILITY ROUTINES   ***}
{****************************}


PROCEDURE SIGNON;
	external;

PROCEDURE MENU;
	external;

FUNCTION toupper( ch: CHAR ): CHAR;
	external;

PROCEDURE INPUT( txt: dstring; VAR answer: shorty );
	external;

PROCEDURE LIST;
	external;

BEGIN{ MAIN PROGRAM BLOCK }
  InitTree( Employee );
  bell := chr(7);
  Command := ' ';
  SIGNON;
  MENU;
  INPUT( 'COMMAND: ', answer );
  Command := toupper( answer[1] );
  WHILE Command <> '9' DO BEGIN
    IF Command IN ['1','2','3','4','5','8'] THEN BEGIN
      WRITELN;
      CASE Command  OF
        '1': begin { INSERT MODE }
	     REPEAT
		writeln( 'ENTER:' );
		INPUT('1 - NAME <Key field>               !', key );
		INPUT('2 - Salary amount <12000>          !', New_Salary );
		input('3 - Company Name <address line 1>  !', New_Company );
		input('4 - Address line 2                 !', New_address );
		input('5 - City                           !', New_City );
		input('6 - State <e.g. MD>                !', New_State );
		input('7 - Zip Code                       !', New_Zip );
		writeln;
		write( 'DATA OK? ' );
		readln( answer );
	      UNTIL toupper(answer[1])<>'N';
	      INSERT( Employee,key );
	     end;

        '2': begin { DELETE MODE }
	     REPEAT
	       INPUT( 'Enter NAME <Key field>      --> ',key );
	       writeln;
	       writeln( 'Deleting > ', key );
	       write( 'OK? ' );
	       readln( answer );
	     UNTIL toupper(answer[1])<>'N';
	     Delete( Employee,key );
	     end;

	'3': begin { LIST MODE }
               disc := false;
	       LIST;
	     end;
        '4': begin {store data to disc}
                STORE;
                end;
        '5': begin {get data from disc}
                FETCH;
                end;
        '8': begin {call explanation}
                HELP;
                end
      END{CASE}
    END{IF};
    MENU;
    INPUT( 'COMMAND: ', answer );
    Command := toupper( answer[1] );
  END{WHILE Command <> '9'}
END{of PROGRAM BTREE}.
