program stripper;

{ V1.2, 850912 - Modified to allow for files that don't end with a
  ^Z.  (Hangs up otherwise.)

  850820 - Modified to tabify ONLY if the space-filled blank is more
  than 4 chars long, and/or NOT following a non-space character with
  the 8th bit set (WS's way of marking a right-justify space.
  (BIG problems in WS-formatted document files.)

  850725, Toad Hall.  Author (?) David P Kirschbaum.
  Used the guts of a public domain hex conversion program
  (HEXTOBIN.PAS) for the structure, stuffed in a stripped down
  tabify routine from TURBTOOLS (another PD library), added the
  command line processing (source forgotten, but PD).
  Many thanks to the other Public Domain authors.  I regret I can't
  give your names here - my software library is such a mishmash of
  chunks and pieces!

  Simple little program to process WordStar files (with all their
  hi-bit flagged characters) into a nice clean 7-bit file.  As a
  side benefit, Stripper also changes all the long space-filled
  blanks into 8-character tabs.

  Because of a problem with some files coming down from weird sources
  (I think certain Vaxen are bad for this) with only carriage returns
  to end lines (yep, no line feeds!), Stripper also forces a CR/LF
  combination whenever it finds a CR.  Unfortunately, it also throws
  out all solitary line feeds.  (Sorry, guys -- just didn't feel like
  screwing about with line feed flags during buffer fills, etc.  Some
  other soul can add that back if they want.)

  This file is given to the Public Domain for all uses, public and
  private, with the usual provisos that you (1) leave in any credits and
  version/update comments, and (2) no commercial or "for profit" applications
  or sales without express written permission of the author.  And just to be
  sure (and keep my lawyers content) ....

  Copyright (C) 1985 David P Kirschbaum  All Rights Reserved

  Toad Hall
  7573 Jennings Lane
  Fayetteville NC  28303
  (919) 868-3471
}


CONST
  TheHEADER = 'Stripper WS Conversion Program';
  TheVERSION = 'Version 1.2 -- 850912';
  ToadCredits = 'Toad Hall TurboPascal conversion.';
  TheCount = ' sectors converted.';
  SpaceCount = ' spaces converted.';
  TrailingCount = ' trailing spaces stripped.';
  TheTRAILER = 'Stripping done.  Ribbet.';
  HarType    = '.HAR';
  maxrecs    = 64;             {64 recs per bufferful}
  maxline    = 128;            {max length of a line for us}
  mintab     = 4;              {min # spaces before we tabify}
  buffsize   = 8192;           {maxrecs * maxline or 128-byte rec}
  tabspace   = 8;              {make a tab 8 spaces for entab - fits WS}
  Tab        : CHAR = #9;      {tab char Ctrl I}
  Space      : CHAR = ' ';     {regular space}
  Cr         : CHAR = #13;     {carriage return char}
  Lf         : CHAR = #10;     {line feed char}
  spaceval   = 32;             {ASCII for space}
  crval      = 13;             {carriage return}
  lfval      = 10;             {line feed}
  eofval     = 26;             {Ctrl Z}

TYPE
  Buffer    = ARRAY [1..buffsize] OF BYTE;   {64 rec, 8 Kb buffer for now}
  Line      = STRING[maxline];               {max length line for us}
  TxtBuffer = ARRAY[1..maxrecs] OF Line;     {64 128-byte lines}
  tabtype   = ARRAY[1..maxline] OF BOOLEAN;  {flags for tab columns}
  FileName  = STRING[14];                    {drive but NOT path in MS-DOS}
                                             {donno HOW yet!}
  Args      = ARRAY[1..2] OF FileName;       {Cmd line parameters}

VAR
  Harfilename ,
  WSfilename : FileName;

  Argv      : Args;
  { ArgStr    : STRING[80] ABSOLUTE $80;}         {CP/M}
  ArgStr    : STRING[80] ABSOLUTE CSEG : $80;  {MS-DOS}
  WSfile    : FILE;
  Harfile   : TEXT;

  WSbuff    : Buffer;
  Strng     : TxtBuffer;

  sectorct,
  WSfilesize,
  ip,space_cnt,
  trailing_cnt,
  WSbuffsize : INTEGER;

  b,c,ch,s,
  col,newcol,
  argc,reccnt : BYTE;

  hiflag      : BOOLEAN;

  PROCEDURE DoCmdLine(VAR argc : BYTE; VAR Argv : Args);

{This routine performs several functions.  It reads the CP/M command tail
 (if any) and breaks the command tail into Argvs.  An Argv is any string
 of characters delimited by either the beginning of the command tail, the
 end of the command tail, or a space.  The routine returns the Argv count
 (argc, usually), and all Argvs found.
 There are several versions around -- I forget where I got the basic guts
 for this simple one, but somebody else gave me the idea!  [Toad Hall]
}
    VAR
      i, j: INTEGER;

    BEGIN
      argc := 0;
      i := 0;
    {if the following is true there is a command tail, otherwise leave
     the count set to 0 and do not parse the command line}
      j := length(ArgStr);
      IF j > 0 THEN BEGIN
        Repeat  {until i = length(ArgStr)}
          i := succ(i);
          IF ArgStr[i] <> Space THEN BEGIN
            argc := succ(argc);
            Argv[argc] := Argv[argc] + UpCase(ArgStr[i]);
            WHILE (ArgStr[i+1] <> Space) AND (i < j) DO BEGIN
              i := succ(i);
              Argv[argc] := Argv[argc] + UpCase(ArgStr[i]);
            END;  {while}
          END;  {if}
        Until i = j;
      END;  {j > 0}
    END;  {of DoCmdLine}


  FUNCTION OpenInp(VAR WSfilename : FileName) : BOOLEAN;

    BEGIN
      OpenInp := TRUE;
      IF argc > 0 THEN BEGIN
        WSfilename := Argv[1];
        Write(WSfilename);
      END
      ELSE BEGIN
        Write('Input File: ');
        Read(WSfilename);
      END;
      Assign(WSfile,WSfilename);
      Reset(WSfile);
      IF Eof(WSfile) THEN BEGIN
        Writeln(' ... file is empty...');
        OpenInp := FALSE;
      END;
    END;  {of OpenInp}


  FUNCTION OpenOut(VAR Harfilename : FileName) : BOOLEAN;

    VAR period,strip : BYTE;

    BEGIN
      OpenOut := TRUE;
      IF argc = 2 THEN BEGIN
        Harfilename := Argv[2];
        Write(Harfilename);
      END
      ELSE BEGIN
        Harfilename := WSfilename;
        period := pos('.',Harfilename);
        IF period > 1 THEN BEGIN
          strip := length(Harfilename) - period + 1;
          Delete(Harfilename,period,strip);
        END;
        Harfilename := Harfilename + HarType;
        Write(Harfilename);
      END;
      Assign(Harfile,Harfilename);
      Rewrite(Harfile);
    END;  {of OpenOut}


  Procedure FillBuff(VAR WSfilesize,WSbuffsize : INTEGER;
                     VAR WSBuff : Buffer);
  {refills buffer, sets various pointers, ec.}
    VAR
      reccnt : INTEGER;

    BEGIN
      IF WSfilesize < maxrecs THEN BEGIN       {less than 64 recs left?}
        reccnt := WSfilesize;                  {# recs remaining }
        WSbuffsize := reccnt * 128;
        WSfilesize := 0;                       {all done}
      END  {WSfilesize < 64}
      ELSE BEGIN                          {full 64 recs left so get maximum}
        reccnt := maxrecs;                     {all 64}
        WSbuffsize := buffsize;                {maxrecs (64) * 128}
        WSfilesize := WSfilesize - maxrecs;    {figure new remaining}
      END;  {else}
      Blockread(WSfile,WSBuff,reccnt);         {fill the buffer}
    END;  {fill inbuffer}


  Procedure FillSpace(VAR col,newcol,s : BYTE; VAR Strng : TxtBuffer);
  {If we were tabifying, fills in the remaining space with real spaces.
   Else puts in all the spaces that were there originally.}
    VAR b : BYTE;

    BEGIN
      FOR b := 1 TO newcol DO BEGIN        {...spaces not tabified}
        col := succ(col);                  {bump string pointer}
        Strng[s][col] := Space;            {stick in a space}
      END;  {b loop}
      newcol := 0;                         {reset the tab pointer}
    END;  {FillSpace}


  Procedure Tabify(VAR col,newcol,s : BYTE;
                   VAR Strng : TxtBuffer;
                   VAR space_cnt : INTEGER);
  {checks tab counter; if time to tab, do it}
    BEGIN
      newcol := succ(newcol);                  {bump tab pointer}
      IF hiflag  THEN FillSpace(col,newcol,s,Strng)
      ELSE IF newcol = tabspace THEN BEGIN     {oops, hit a tab stop}
        col := succ(col);                      {bump the string pointer}
        Strng[s][col] := Tab;                  {stick in a tab}
        space_cnt := space_cnt + newcol;       {add in to space count}
        newcol := 0;                           {reset the tab pointer}
      END;   {hit a tab stop or hi bit flag}
    END;  {tabify}


  Procedure DoCrLf(VAR col,newcol,s : BYTE;
                   VAR Strng : TxtBuffer);
  {forces line length, resets counters and pointers}

    BEGIN
      Strng[s][0] := Chr(col);               {force the length (tricky, no?)}
      s := succ(s);                          {next string}
      col := 0;                              {point to beginning of string}
      newcol := 0;                           {tab pointer too}
    END;   {DoCrLf}


  Procedure WriteFile(reccnt : BYTE; Strng : TxtBuffer);
  {write full text buffer to new file}
    VAR rec: BYTE;

  BEGIN
    FOR rec := 1 TO reccnt DO BEGIN           {always smaller than WS file}
        Writeln(Harfile,Strng[rec]);             {write each string}
        Strng[rec] := '';                        {why not? tho doesn't matter}
    END;  {write maxrec strings}
  END;  {WriteFile}


{stripper main body begins}
BEGIN
  Writeln(TheHEADER);
  Writeln(TheVERSION);
  Writeln(ToadCredits);
  FOR argc := 1 TO 2 DO Argv[argc] := '';
  DoCmdLine(argc,Argv);
  Repeat until OpenInp(WSfilename);
  Writeln(' ------> File opened.');
  Repeat until OpenOut(Harfilename);
  Writeln(' ------> File opened.');

  FOR s := 1 TO maxrecs DO
    Strng[s] := '';                            {initialize strings}
  s := 1;                                      {string counter}
  col := 0;                                    {string col pointer}
  newcol := 0;                                 {tab alt pointer}
  ip := 1;                                     {WS buffer pointer}
  ch := 0;                                     {initialize char ASCII val}
  space_cnt := 0;                              {space counter}
  trailing_cnt := 0;                           {trailing space counter}
  hiflag := FALSE;                             {turn hi bit flag off}
  WSbuffsize := 0;
  WSfilesize := filesize(WSfile);
  sectorct := WSfilesize;
  c := sectorct DIV 8 ;
  Write('KB to process:  ',c : 4,Cr);  {start a counter display}

{  WHILE ch <> eofval DO BEGIN}
  Repeat
    IF (ip MOD 1024) = 0 THEN BEGIN    {post progress every Kb}
      c := pred(c);
      Write('Kb to process:  ',c : 4,Cr);
    END;

    IF ((ip > WSbuffsize) AND (Eof(WSfile) = FALSE))
      THEN BEGIN                       {time to fill buffer}
      ip := 1;                         {reset buff pointer}
      FillBuff(WSfilesize,WSbuffsize,WSBuff);  {refill buffer}
    END;  {fill inbuffer}

{WS marks justified spacing by setting the hi bit of the last non-space
 char prior to a series of spaces.  We do NOT want to do any tabifying
 there because of massive problems later if reformatting.  So just strip
 that 8th bit and set a flag saying NO tabifying.}

    ch := WSbuff[ip];
    IF (ch > 127) THEN BEGIN
      hiflag := TRUE;
      ch := ch AND 127;                {strip 8th bit}
    END;
    ip := succ(ip);                    {bump buff pointer}
    IF s = 0 THEN s := 1;              {insure no double write}

    CASE ch OF
      spaceval :                       {got a space}
        Tabify(col,newcol,s,Strng,space_cnt); {gotcha, dirty little space}
      crval :
        BEGIN               {handle CRs, LFs be damned}
          trailing_cnt := trailing_cnt + newcol; {add in trailing spaces}
          DoCrLf(col,newcol,s,Strng);  {finalize line}
          hiflag := FALSE;             {turn off hi bit flag}
        END;
      lfval : BEGIN END;               {skip lf's}
      ELSE BEGIN                       {not end of line}
        IF newcol > 0 THEN             {process any left over...}
          FillSpace(col,newcol,s,Strng); {...spaces not tabified}
        hiflag := FALSE;
        col := succ(col);              {bump string pointer}
        Strng[s][col] := Chr(ch);      {put in the stripped old char}
      END;  {not end of line}
    END;  {case}

    IF (s > maxrecs) THEN BEGIN        {string buffer full}
      WriteFile(maxrecs,Strng);        {write text buffer to file}
      s := 0;                          {reset string counter}
    END;  {do maxrec strings}
    ch := WSbuff[ip];                  {in case a ^Z coming}
 { END; }  {while not eof}                {sure hope it's in this buff}
  Until (Eof(WSFile) AND (ip > WSbuffsize));

  IF s > 0 THEN                        {any leftover strings?}
    WriteFile(s,Strng);                {write to file}
  c := pred(c);                        {count down last Kb to... }
  Writeln('Kb to process:  ',c : 4,Cr);  {...make them happy}
  Close(Harfile);                      {shut down}
  Close(WSfile);
  Writeln(sectorct,TheCount);          {brag a little}
  Writeln(space_cnt,SpaceCount);
  Writeln(trailing_cnt, TrailingCount);
  Writeln(TheTRAILER);                 {bye}
END.

