PROGRAM testcmd;
{          +---------------------------------------------------------+
           |This is a program to test and demonstrate the procedure, |
           |READCMD, and to illustrate pertinent global declarations.|
		   |It also illustrates the use of the accessory procedure,  |
		   |GETNUMS, to convert numeric arguments from strings to an |
		   |array of integers.                                       |
           +---------------------------------------------------------+        }
{$E+}
  CONST   maxword   = 14;        {MAX NO. OF CHARACTERS AN ARGUMENT CAN HAVE  }
          maxargs   = 11;        {MAX NO. OF ARGUMENTS ALLOWED IN COMMAND TAIL}
          maxline   = 80;
          margin    = '          ';


  TYPE    string0   = string 0;
          string255 = string 255;
          wrdtype   = string maxword;
          wrdarray  = ARRAY[1..maxargs] OF wrdtype;
          numarray  = ARRAY[1..maxargs] OF INTEGER;
          byte      = 0..255;

  VAR     source    : wrdtype;
          key       : CHAR;
          name      : wrdarray;  {IDENTIFIERS FOR THE ARGUMENTS IN THE        }
          i,                                                    {COMMAND TAIL.}
          nargs,                 {ACTUAL NUMBER OF ARGUMENTS IN COMMAND TAIL  }
          numct     : byte;      {NUMBER OF NUMERIC ARGUMENTS                 }
          num       : numarray;  {IDENTIFIERS FOR NUMERIC ARGUMENTS           }
          sum       : INTEGER;

   FUNCTION length ( source: string255 ): INTEGER; external;
{$Igetnums.p }
{$Ireadcmd.p }

  PROCEDURE arguments;
    VAR    i : byte;
    BEGIN {-----------------------------arguments-----------------------------}
      WRITELN('     FOR i := 1 to nargs:');
      FOR i := 1 TO nargs DO
        WRITELN(margin,'name[',i:1,'] = ',name[i]);  
      WRITELN
    END;  {-----------------------------arguments-----------------------------}

  PROCEDURE maxarguments;
    VAR    i : byte;
    BEGIN {---------------------------maxarguments----------------------------}
      WRITELN('     FOR i := 1 to maxargs:');
      FOR i := 1 TO maxargs DO 
        WRITELN(margin,'name[',i:1,'] = ',name[i]);  
      WRITELN;
      FOR i := 1 TO maxargs DO 
        WRITELN(margin,'length(name[',i:1,']) = ',length(name[i]):2);
      WRITELN;
    END;  {---------------------------maxarguments----------------------------}

  PROCEDURE numerics;
    VAR    i : byte;
    BEGIN {-----------------------------numerics------------------------------}
      getnums(name,nargs,num,numct);
      WRITELN('     FOR i := 1 to numct:');
      FOR i := 1 TO numct DO
        WRITELN(margin,'num[',i:1,'] =',num[i]: 5);  
      WRITELN;
      sum := 0;
      FOR i := 1 to numct DO sum := sum + num[i];
      WRITELN(margin,'Sum of numeric arguments = ',sum: 1); WRITELN
    END;  {-----------------------------numerics------------------------------}

  BEGIN {-------------------------------testcmd-------------------------------}
    readcmd(name,nargs);
    IF (name[1] = 'Q') OR (name[1] = 'q')
      THEN WRITELN(margin,'Program aborted.')
      ELSE
        BEGIN
          source := name[1];
          key :=    name[2,1];
          WRITELN(margin,'The source filename is ',source,'.');
          WRITELN(margin,'The key is ',key);          WRITELN;
          IF (key = 'A') OR (key = 'a') OR (source[1] = '\') THEN arguments;
          IF (key = 'M') OR (key = 'm') OR (source[1] = '\') THEN maxarguments;
          IF (key = 'N') OR (key = 'n') OR (source[1] = '\') THEN numerics;
          WRITELN(margin,'The number of arguments, nargs =',nargs: 3)
        END
  END.  {-------------------------------testcmd-------------------------------}

