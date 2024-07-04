Program LUP;
  {[A+,T=3] Instructions to PasMat.}

  {$C-  <--- These are to  }
  {$W0  <--- optimize the  }
  {$X+  <--- compiler.     }

{
                      LUP (Library Utility in Pascal)
                                  1/02/85

   The program help users use the following program, without, having
   to type the LONG commands associated with library files:

                  DIR   (SD 11.0)           XMODEM L  (XMDM 11.7)
                  LTYPE (TYPEL 3.6)         XMODEM LK (XMDM 11.7)

   It also, like LUX, allows you to get to another library file with
   the command LUP filename[.LBR].  But unlike LUX, you may NOT use
   wildcards when specifing a file name to TYPE, which is because of
   the LTYPE program which I'm using.  If you'll notice, that all
   the above files, are (almost) a MUST for any RCP/M (or Z-NODE)
   type system, so the only extra file, would be LUP.COM.  LUX, as I
   understand requires you to have a seperate file for all the command,
   PLUS LUX, and for a small system, thats a lot of space.  Another
   advantage of LUP, over LUX, is that LUP doesn't require warm-booting
   (if you run TPFIX, see below), which (some people) say is bad for
   the drives (I'm not one of them, but it does speed things up a bit).

   This program requires ZCPR3, to run, because, it uses the command
   line.  You should check to see where the location of your command
   line is, by using the Z3LOC.COM program, supplied with ZCPR3, and
   place that value at the constant variable CommandLineLocation.

   After you compile this program, I suggest that you use a program called
   TPFIX, to inhibit the program from warm-booting, in order to speed
   up the operations of this program.

   If you have any questions or comments, please feel free to call my
   RCP/M at (312) 386-9271.

                                                  Thank you,


                                                  Cyrus Patel
                                          SYSOP - The Master Silicone
   Version 1.1  (01/06/86)
           Added Wheel check and NULU support (Wheel set), changed
           to KMD for transfers, LDIR for faster DIR support, Q option
           for easier quit...
                                                  Norman Beeler
                                                  Sysop
                                                  ZeeMachine
                                                  408-245-1420

}

   Const
      Version = '1.0';
      CommandLineLocation = $FF00;

   Type
      String14 = String [14];
      String80 = String [80];

   Var
      CommandLine: String80;
      LBRName, FileName: String14;
      MemTop: Integer Absolute $6;
      Wheel: Byte Absolute $4B;

   Procedure Instructions;

      Begin
         WriteLn;
         Write('Usage: LUP Filename[.LBR]');
         Halt
      End;


   Procedure GetLBRName(Var LBRName: String14);

      Var
         InFile: File;
         Index: Integer;
         CommandLine: String14 Absolute $80;

      Begin
         If CommandLine = '' then
            Instructions
         else
            LBRName := Copy(CommandLine, 2, Length(CommandLine));
         If (LBRName <> '') and (Pos('.', LBRName) > 0) then
            LBRName := Copy(LBRName, 1, Pos('.', LBRName) - 1);
         If LBRName = '' then
            Instructions;
         For Index := 1 to Length(LBRName) do
            LBRName[Index] := UpCase(LBRName[Index]);
         LBRName := LBRName + '.LBR';
         Assign(InFile, LBRName);
         {$I-}
         Reset(InFile);
         If IOResult <> 0 then
            Begin
            WriteLn;
            WriteLn('File: ', LBRName, ' does not exist.');
            Close(InFile);
            Instructions
            End;
         Close(InFile);
         {$I+}
         WriteLn
      End;


   Procedure PutOnCommandLine(Line: String80);

      Var
         Index: Integer;

      Begin
         Line := Line + ';A0:LUP ' + LBRName;
         Mem[CommandLineLocation] := 4;
         Mem[CommandLineLocation + 1] := $FF;
         Mem[CommandLineLocation + 2] := $C8;
         Mem[CommandLineLocation + 3] := Length(Line);
         For Index := 1 to Length(Line) do
            Mem[CommandLineLocation + Index + 3] := Ord(Line[Index]);
         Mem[CommandLineLocation + Length(Line) + 4] := $00;
         Mem[CommandLineLocation + Length(Line) + 5] := $00
      End;


   Procedure Help;

      Begin
         WriteLn;
         WriteLn('': 22, 'LUP (Library Utility in Pascal)');
         WriteLn;
         WriteLn('': 16, '  BYE - Logoff computer.');
         WriteLn('': 16, '  DIR - Directory of library.');
         WriteLn('': 16, 'FILES - Get list of library files.');
         WriteLn('': 16, ' HELP - This list.');
         WriteLn('': 16, '  LUP - Get library of another file.');
         WriteLn('': 16, '           LUP Filename[.LBR]');
         WriteLn('': 16, '    Q - Exit LUP.');
         WriteLn('': 16, ' QUIT - Exit LUP.');
         WriteLn('': 16, '    S - Send file with KMD (128 byte block).');
         WriteLn('': 16, '           S Filename.typ');
         WriteLn('': 16, ' SEND - Send file with KMD (128 byte block).');
         WriteLn('': 16, '           Send Filename.typ');
         WriteLn('': 16, '   SK - Send file with KMD (1K byte block).');
         WriteLn('': 16, '           SK Filename.typ');
         WriteLn('': 16, 'SENDK - Send file with KMD (1K byte block).');
         WriteLn('': 16, '           SendK Filename.typ');
         WriteLn('': 16, ' TYPE - Type a file from library.');
         WriteLn('': 16, '           Type Filename.typ');
         If Wheel > 0 then
         Begin
              WriteLn('': 16, '   -L - Enter NULU Command mode and List files.');
              WriteLn('': 16, '   -F - Enter NULU Sweep mode.')
         End;
              WriteLn;
         CommandLine := ''
      End;


   Procedure GetCommand;

      Var
         Index: Integer;

      Begin
         Write('LUP: [' + LBRName + ']>');
         ReadLn(CommandLine);
         If Pos(' ', CommandLine) > 0 then
            Begin
            FileName := Copy(CommandLine, Pos(' ', CommandLine),
                             Length(CommandLine));
            For Index := 1 to Length(FileName) do
               FileName[Index] := UpCase(FileName[Index]);
            CommandLine := Copy(CommandLine, 1, Pos(' ', CommandLine) - 1)
            End
         else
            FileName := '';
         For Index := 1 to Length(CommandLine) do
            CommandLine[Index] := UpCase(CommandLine[Index])
      End;


   Procedure ProcessCommand;

      Begin
         If CommandLine = 'BYE' then
            CommandLine := 'A0:BYE'
         else If CommandLine = 'DIR' then
            CommandLine := 'A0:LDIR ' + LBRName
         else If CommandLine = 'FILES' then
            CommandLine := 'A0:DIR *.LBR'
         else If (CommandLine = 'HELP') or (CommandLine = '?') then
            Help
         else If CommandLine = 'LUP' then
            CommandLine := 'A0:LUP' + FileName
         else If (CommandLine = 'QUIT') or (CommandLine = 'Q') then
            Halt
         else If (CommandLine = 'S') or (CommandLine = 'SEND') then
            CommandLine := 'A0:KMD L ' + LBRName + FileName
         else If (CommandLine = 'SK') or (CommandLine = 'SENDK') then
            CommandLine := 'A0:KMD LK ' + LBRName + FileName
         else If CommandLine = 'TYPE' then
            CommandLine := 'A0:TYPE ' + LBRName + FileName
         else If (CommandLine = '-F') and (Wheel > 0) then
            CommandLine := 'NULU ' + LBRName + ' -F '
         else If (CommandLine = '-L') and (Wheel > 0) then
            CommandLine := 'NULU ' + LBRName + ' -L '
         else If CommandLine <> '' then
            Begin
            WriteLn;
            CommandLine := '';
            WriteLn('Invalid command, type ? for help, QUIT to exit.');
            WriteLn
            End
      End;

   Begin
      StackPtr := MemTop - $826;
      RecurPtr := StackPtr - $400;
      HeapPtr := $300F;
      GetLBRName(LBRName);
      Repeat
         GetCommand;
         ProcessCommand
      Until CommandLine <> '';
      PutOnCommandLine(CommandLine)
   End.
