PROGRAM PrettyPrinter;

(*
**  Filename:       PRETTY.PAS
**  Language:       Turbo Pascal
**  Target machine: Tested on H89 & CP/M 2.2, but should work on any
**                      computer or operating system which runs Turbo.
**  By:             Don McCrady (June 27, 1985)
**  Updated:        July 14, 1985
**
**  This program is a "Pascal Program Spiffyizer".  It takes an
**  ordinary Pascal program and produces a copy of it with all
**  reserved words in upper case.  (If the source file is written
**  entirely in upper case, then this program will have no effect
**  at all on it.)
**
**  The output from PRETTY can be written to the terminal, the printer,
**  a disk file, or all three at once.
**
**  The user can turn off the marking of reserved words, and the page
**  formatting if printer output is selected.  If disk file output is
**  requested, the user can also tell the program to erase the original
**  file when finished.
**
**  There is one bug:  If the source file contains a word which is longer
**  than 16 characters, the pretty printer will drop characters.  A word
**  with 16 characters is pretty long, so the bug shouldn't present much
**  of a problem with most Pascal programs.
*)

CONST   NumReserved = 41;          { Number of reserved words in Turbo. }
        StrLength = 16;      { Maximum word length.  This program won't }
        bell = ^G;            { work properly if there are any words in }
        cr = ^M;             { the source file which are larger than 16 }
        lf = ^J;                                          { characters. }
        esc = ^[;
        tab = ^I;
        ff = ^L;
        space = ' ';
        blank16 = '                ';                      { 16 spaces. }

TYPE    str = PACKED ARRAY [1..StrLength] OF char;
        string15 = STRING[15];
        string80 = STRING[80];
        CharSet = SET OF char;

CONST   AlphaNum : CharSet = ['A'..'Z','a'..'z','0'..'9'];
        (* WARNING:     To modify the following list, change the        *)
        (*      NumReserved constant to the new number of reserved      *)
        (*      words.  Then insert/delete reserved words in the        *)
        (*      following declaration -- but MAKE SURE THAT THE         *)
        (*      NEW LIST REMAINS IN ALPHABETICAL ORDER!!!               *)
        KeyWord : ARRAY [1..NumReserved] OF str =
          ('ABSOLUTE        ',  'AND             ',   'ARRAY           ',
           'BEGIN           ',  'CASE            ',   'CONST           ',
           'DIV             ',  'DO              ',   'DOWNTO          ',
           'ELSE            ',  'END             ',   'EXTERNAL        ',
           'FILE            ',  'FOR             ',   'FORWARD         ',
           'FUNCTION        ',  'GOTO            ',   'IF              ',
           'IN              ',  'LABEL           ',   'MOD             ',
           'NIL             ',  'NOT             ',   'OF              ',
           'OR              ',  'PACKED          ',   'PROCEDURE       ',
           'PROGRAM         ',  'RECORD          ',   'REPEAT          ',
           'SET             ',  'SHL             ',   'SHR             ',
           'STRING          ',  'THEN            ',   'TO              ',
           'TYPE            ',  'UNTIL           ',   'VAR             ',
           'WHILE           ',  'WITH            ');

VAR infile,outfile : text;
    InfileName,OutfileName,OldInfileName : string15;
    NextCh : char;
    FormatPage,               { Boolean flags... control output format. }
    MarkReserved,
    EraseOld,
    ConOut,
    FileOut,
    ListOut : Boolean;
    LineNum,
    PageNum : byte;

{ Read the next character from the source file.  Store the look-ahead   }
{  character into the global variable NextCh.                           }
PROCEDURE ReadChar(VAR ch : char);
BEGIN
    ch := NextCh;
    read(infile,NextCh)
END;

{ Convert a PACKED ARRAY string to uppercase.                           }
PROCEDURE ToUpper(VAR s : str);
VAR wptr : byte;
BEGIN
    FOR wptr := 1 TO StrLength DO
        s[wptr] := upcase(s[wptr])
END;

{ Write a character (ch) to the output device(s).                       }
PROCEDURE out(ch : char);
CONST   MaxLine = 60;
BEGIN
    IF ConOut THEN
        write(con,ch);
    IF ListOut THEN
        BEGIN
        IF FormatPage THEN
            BEGIN
            IF ch = ^M THEN
                LineNum := succ(LineNum);
            IF LineNum = MaxLine THEN
                BEGIN
                LineNum := 1;
                PageNum := succ(PageNum);
                write(lst,cr,ff,InfileName,cr,InfileName);
                write(lst,tab,tab,tab,tab,tab,tab,tab,tab,'Page ',PageNum);
                writeln(lst,lf,lf)
                END
            END;
        write(lst,ch)
        END;
    IF FileOut THEN
        write(outfile,ch)
END;

{ Sound terminal bell.                                                  }
PROCEDURE beep;
BEGIN
    write(bell)
END;

{ Display error message (msg), sound terminal bell, and exit.           }
PROCEDURE error(msg : string80);
BEGIN
    beep;
    writeln(msg);
    halt
END;

{ Read a single character from keyboard.  The only acceptable chara-    }
{  acters are SPACE, CR, ESCAPE, Y, and N.  If the parameter "default"  }
{  is "false", then SPACE, CR, or ESCAPE will produce the same result   }
{  as typing N.  If "default" is "true", then SPACE, CR, or ESCAPE will }
{  be the same as typing Y.                                             }
{ If the user enters Y, the function will write "Yes" to the terminal   }
{  and return a value of true; otherwise it will write "No" and return  }
{  a value of false.  If an unacceptable key is entered, the terminal   }
{  bell is sounded, and the function will await a legal response.       }
FUNCTION yes(default : Boolean) : Boolean;
VAR ch : char;
BEGIN
    REPEAT
        read(kbd,ch);
        IF ch IN [cr,space,esc] THEN
            IF default = false THEN
                ch := 'N'
            ELSE
                ch := 'Y';
        ch := upcase(ch);
        CASE ch OF
            'Y':    BEGIN
                        yes := true;
                        writeln('Yes')
                    END;
            'N':    BEGIN
                        yes := false;
                        writeln('No')
                    END
            ELSE    beep
        END{case}
    UNTIL ch IN ['Y','N']
END;

{ If the parameter string "fname" does not have an extension, then the  }
{  default extension '.PAS' is appended to it.                          }
PROCEDURE MakeFileName(VAR fname : string15);
VAR ExtPos : byte;
BEGIN
    ExtPos := pos('.',fname);
    IF ExtPos = 0 THEN
        fname := fname + '.PAS'
END;

{ Opens a text file for input or output, depending on the parameter     }
{  "mode".  MODE is either "I" for input or "O" for output.             }
PROCEDURE open(mode : char; VAR f : text; name : string15);
BEGIN
    {$I-}
    assign(f,name);
    CASE upcase(mode) OF
        'I':    BEGIN
                    reset(f);
                    IF IOresult <> 0 THEN
                        error('Can''t open '+name)
                END;
        'O':    BEGIN
                    reset(f);
                    IF IOresult = 0 THEN
                        BEGIN
                        beep;
                        write('File ',name,' exists.  Overwrite? ');
                        IF NOT yes(false) THEN
                            error('Aborting')
                        END
                    ELSE
                        rewrite(f)
                END
        ELSE    error('Bad file mode')
    END{case}
    {$I+}
END;  { open }

PROCEDURE MakeBackup(VAR InfileName : string15);
VAR i : byte;
BEGIN
    OldInfileName := InfileName;
    assign(infile,InfileName);
    i := pos('.',InfileName);
    IF i <> 0 THEN
        InfileName := copy(InfileName,1,i) + 'BAK'
    ELSE
        InfileName := InfileName + '.BAK';
    rename(infile,InfileName)
END;

{ Set Boolean flags.                                                    }
PROCEDURE SetParams;
BEGIN
    FormatPage := true;
    MarkReserved := true;
    ConOut := true;
    ListOut := false;
    FileOut := false;
    EraseOld := false;
    writeln;
    write('Source file name? ');
    readln(InfileName);
    MakeFileName(InfileName);
    MakeBackup(InfileName);
    open('i',infile,InfileName);
    writeln;
    write('Suppress marking of reserved words? ');
    IF yes(NOT MarkReserved) THEN
        MarkReserved := NOT MarkReserved;
    write('Disk file output? ');
    IF yes(FileOut) THEN
        FileOut := NOT FileOut;
    IF FileOut THEN
        BEGIN
        write(tab,'Output file name? ');
        readln(OutfileName);
        MakeFileName(OutfileName);
        open('o',outfile,OutfileName);
        write(tab,'Erase original file? ');
        IF yes(false) THEN
            EraseOld := true
        END;
    write('Console output? ');
    IF NOT yes(ConOut) THEN
        ConOut := NOT ConOut;
    write('Printer output? ');
    IF yes(ListOut) THEN
        ListOut := NOT ListOut;
    IF ListOut THEN
        BEGIN
        write('Suppress page formatting? ');
        IF yes(NOT FormatPage) THEN
            FormatPage := NOT FormatPage
        END
END;  { SetParams }

{ Main procedure.  Maps any reserved words to upper case.               }
PROCEDURE PrettyPrint;
VAR ch : char;
    state : (InWord,InStr,InComment,copying);
    word,TestWord : str;
    wptr : byte;

    { Display a PACKED ARRAY string to the output device(s) with all    }
    {  trailing blanks removed.                                         }
    PROCEDURE PrintWord(word : str);
    VAR i : byte;
    BEGIN
        i := 1;
        WHILE (word[i] <> ' ') AND (i <= StrLength) DO
            BEGIN
            out(word[i]);
            i := succ(i)
            END
    END;

    { Binary searches the KEYWORD list (global) to see if the parameter }
    {  "word" is a reserved word.                                       }
    FUNCTION IsReserved(word : str) : Boolean;
    VAR top,bottom,mid : byte;
    BEGIN
        top := NumReserved;
        bottom := 1;
        WHILE top > bottom DO
            BEGIN
            mid := (top + bottom) SHR 1;  { Same as (top+bottom) DIV 2. }
            IF word > KeyWord[mid] THEN
                bottom := succ(mid)
            ELSE
                top := mid
            END;{while}
        IF word = KeyWord[top] THEN
            IsReserved := true
        ELSE
            IsReserved := false
    END;  { IsReserved }

BEGIN { PrettyPrint }
    state := copying;
    word := blank16;
    read(infile,NextCh);                { Initialize the global NextCh. }
    WHILE NOT eof(infile) DO
        BEGIN
        ReadChar(ch);
        CASE state OF
            copying:    BEGIN
                            IF ((ch='(') AND (NextCh='*')) OR (ch='{') THEN
                                BEGIN
                                state := InComment;
                                out(ch)
                                END{if}
                            ELSE IF ch = '''' THEN
                                BEGIN
                                state := InStr;
                                out(ch)
                                END{if}
                            ELSE IF ch IN AlphaNum THEN
                                BEGIN
                                word := blank16;
                                state := InWord;
                                wptr := 1;
                                word[wptr] := ch
                                END{if}
                            ELSE
                                out(ch)
                        END;{case copying}
            InComment:  BEGIN
                            IF ((ch='*') AND (NextCh=')')) OR (ch = '}') THEN
                                state := copying;
                            out(ch)
                        END;{case InComment}
            InStr:      BEGIN
                            IF ch = '''' THEN
                                state := copying;
                            out(ch)
                        END;{case InStr}
            InWord:     BEGIN
                            WHILE (ch IN AlphaNum) AND (wptr <= StrLength) DO
                                BEGIN
                                wptr := succ(wptr);
                                word[wptr] := ch;
                                ReadChar(ch)
                                END;{while}
                            IF MarkReserved THEN
                                BEGIN
                                TestWord := word;
                                ToUpper(TestWord);
                                IF IsReserved(TestWord) THEN
                                    PrintWord(TestWord)
                                ELSE
                                    PrintWord(word)
                                END{if}
                            ELSE
                                PrintWord(word);
                            word := blank16;
                            out(ch);
                            IF ((ch='(') AND (NextCh='*')) OR (ch = '{') THEN
                                state := InComment
                            ELSE
                                state := copying
                        END{case InWord}
            END{case}
        END{while}
END;  { PrettyPrint }

BEGIN   (* Main Program *)
    SetParams;
    IF FormatPage AND ListOut THEN
        BEGIN
        PageNum := 1;
        LineNum := 1;
        write(lst,InfileName,cr,InfileName);
        write(lst,tab,tab,tab,tab,tab,tab,tab,tab,'Page ',PageNum);
        writeln(lst,lf,lf)
        END;
    IF ConOut THEN
        ClrScr;
    PrettyPrint;
    IF FileOut THEN
        BEGIN
        close(outfile);
        IF EraseOld THEN
            erase(infile)
        END
    ELSE
        rename(infile,OldInfileName)
END.











ÙØyá"Sz!óÿ9ùë í