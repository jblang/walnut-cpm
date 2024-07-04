    {$C-}
    const
        Changed : Boolean = False;
       DiskFull : Boolean = False;
    type
        Entry = Record
                          Name : String[34];
                    Ingredient : Array[1..15] of String[20];
                     Direction : Array[1..13] of String[79];
                end;
        Str12 = String[12];
        Str80 = String[80];
    var
         RecipeFile : File of Entry;
             Recipe : Entry;
         TestString : Str80;
        CurrentFile : Str12;
        CurrentType : String[30];
             Choice : Char;
           Continue : Char;
             Option : Integer;
      HighestRecord : Integer;
    function Exist(FileName : Str12) : Boolean;
        var
            Fil : File;
        begin
            Assign(Fil, FileName);
            {$I-} Reset(Fil) {$I+};
            Exist := (IOresult = 0)
        end;
    procedure DrawStatusLine;
        begin
            GotoXY(1,21); Write(' ==============================================================================');
            GotoXY(1,23); Write(' ==============================================================================');
        end;
    procedure WriteStatusLine(Status : Str80);
        var
            Margin : Integer;
        begin
            Margin := ((80-length(Status)) div 2);
            GotoXY(1,22); ClrEol;
            GotoXY(Margin,22); Write(^G,Status + '  ');
        end;
    procedure DrawMask;
        begin
            GotoXY(8,1); Write('NAME :');
            GotoXY(1,2); Write('INGREDIENTS :');
            GotoXY(2,7); Write('DIRECTIONS :');
        end;
    procedure DrawScreen;
        var
           A,B,J  : Integer;
        begin
            With Recipe do
            begin
                GotoXY(14,1);ClrEol;Write(Name);
                A := 14; B := 2;
                For J := 1 to 15 Do
                begin
                    GotoXY(A,B);Write('                    '); GotoXY(A,B);
                    Write(Ingredient[J]); A := A + 22;
                    If A = 80 then
                    begin
                        A := 14; B := B + 1;
                    end;
                end;
                B := 8;
                For J := 1 to 13 Do
                begin
                    GotoXY(1,B); ClrEol; Write(Direction[J]);
                    B := B + 1;
                end;
            end;
        end;
    procedure Accept;
        begin
            Assign(RecipeFile,CurrentFile);
            If not Exist(CurrentFile) then Rewrite(RecipeFile)
            else Reset(RecipeFile);
            With Recipe Do
            begin
                {$I-} Seek(RecipeFile, FileSize(RecipeFile)) {$I+};
                DiskFull := (IOresult = $F0);
                If DiskFull then
                begin
                    WriteStatusLine('DISK FULL !!!  Erase Unnecessary Files.  (ANY KEY) to QUIT.');
                    Read(Continue); Halt;
                end;
                Write(RecipeFile,Recipe);
                Flush(RecipeFile);
                Close(RecipeFile);
            end;
            Changed := False;
        end;
    procedure Change;
        var
            X,Y,I : Integer;
        begin
            With Recipe Do
            begin
                GotoXY(14,1); Read(TestString);
                If TestString <> '' then
                begin
                    Changed := True;
                    Name := TestString;
                    DrawScreen;
                end;
                X := 14; Y := 2;
                For I := 1 to 15 Do
                begin
                    GotoXY(X,Y); Read(TestString);
                    If TestString <> '' then
                    begin
                        Changed := True;
                        Ingredient[I] := TestString;
                        DrawScreen;
                    end;
                    X := X + 22;
                    If X = 80 then
                    begin
                        X := 14; Y := Y + 1;
                    end;
                end;
                Y := 8;
                For I := 1 to 13 Do
                begin
                    GotoXY(1,Y); Read(TestString);
                    If TestString <> '' then
                    begin
                        Changed := True;
                        Direction[I] := TestString;
                        DrawScreen;
                    end;
                    Y := Y + 1;
                end;
            end;
        end;
    procedure FindRecipe(Rec : Integer);
        begin
            Assign(RecipeFile,CurrentFile);
            Reset(RecipeFile);
            With Recipe Do
            begin
                Seek(RecipeFile,Rec);
                Read(RecipeFile,Recipe);
                Close(RecipeFile);
            end;
        end;
    procedure PrintRecipe;
        var
            A,B,J : Integer;
           Blanks : String[25];
        begin
            Blanks := '                         ';
            WriteStatusLine('Printer ON Then Press (RETURN)');
            Read(Continue);
            With Recipe Do
            begin
                Writeln(Lst,'NAME : ',Name); Writeln(Lst);
                Writeln(Lst,'INGREDIENTS :');
                For J := 1 to 15 Do
                begin
                    Write(Lst,Ingredient[J] + Copy(Blanks,1,(25 - length(Ingredient[J]))));
                    If J mod 3 = 0 then
                        Write(Lst,^M^J);
                end;
                Writeln(Lst);
                Writeln(Lst,'DIRECTIONS :');
                For J := 1 to 13 Do
                begin
                    Writeln(Lst,Direction[J]);
                end;
                Writeln(Lst,#12);
            end;
        end;
    procedure DisplayRecipe(Number : Integer);
        begin
            If Number > HighestRecord then
            begin
                WriteStatusLine('That Recipe Does NOT Exist.  (ANY KEY) to Continue.');
                Read(Continue); Exit;
            end;
            With Recipe Do
            begin
                FindRecipe(Number);
                ClrScr;
                DrawMask;
                DrawStatusLine;
                DrawScreen;
                WriteStatusLine('(P)rint      (ANY KEY) for MENU');
                Read(Choice);
                If (Choice = 'P') or (Choice = 'p') then
                    PrintRecipe
                else
                    Exit;
            end;
        end;
    procedure ListNames;
        var
            I,X,Y : Integer;
        begin
            ClrScr; DrawStatusLine;
            GotoXY(((80 - length(CurrentType)) div 2),3);
            Write(CurrentType); X := 1; Y := 5;
            For I := 1 to 30 Do
            begin
                GotoXY(X,Y); Write(I:2,': ');
                If I = 15 then
                begin
                    X := 41; Y := 4;
                end;
                Y := Y + 1;
            end;
            If not Exist(CurrentFile) then
            begin
                WriteStatusLine('That File Does NOT Exist.  (ANY KEY) to Continue.');
                Read(Kbd,Continue); Exit;
            end;
            Assign(RecipeFile,CurrentFile);
            Reset(RecipeFile);
            I := 0; X := 5; Y := 5;
            With Recipe Do
            begin
                Repeat
                    Seek(RecipeFile,I); Read(RecipeFile,Recipe);
                    GotoXY(X,Y); Write(Name);
                    If I = 14 then
                    begin
                        X := 45; Y := 4;
                    end;
                    I := I + 1; Y := Y + 1;
                Until (I = 29) or (EOF(RecipeFile));
                HighestRecord := I-1;
            end;
            Close(RecipeFile);
            Option := 40;
            Repeat
                WriteStatusLine('(1-30) to DISPLAY.    (0) for MENU.');
                Read(Option);
            Until Option in [0..30];
            If Option = 0 then Exit;
            DisplayRecipe(Option - 1);
        end;
    procedure EnterRecipe;
        var
            C,D,K : Integer;
        begin
            ClrScr;
            DrawMask;
            DrawStatusLine;
            WriteStatusLine('Enter NAME of Recipe.');
            With Recipe Do
            begin
                GotoXY(14,1); Write('??????????????????????????????????');
                GotoXY(14,1); Read(Name); GotoXY(14,1); ClrEol;
                Write(Name); C := 14; D := 2;
                WriteStatusLine('Enter INGREDIENTS.');
                For K := 1 to 15 Do
                begin
                    GotoXY(C,D); Write('????????????????????'); GotoXY(C,D);
                    Read(Ingredient[K]); GotoXY(C,D); ClrEol;
                    Write(Ingredient[K]); C := C + 22;
                    If C = 80 then
                    begin
                        C := 14; D := D + 1;
                    end;
                end;
                WriteStatusLine('Enter DIRECTIONS.  Enter RETURN For Blank Lines.');
                D := 8;
                For K := 1 to 13 Do
                begin
                    GotoXY(1,D); Read(Direction[K]);
                    D := D + 1;
                end;
                Repeat
                    WriteStatusLine('(A)ccept   (C)hange   (D)elete');
                    Read(Kbd,Choice);
                    Case Choice of
                        'A','a' : Accept;
                        'C','c' : Change;
                        'D','d' : Exit;
                    end;
                Until (Choice in ['A','a','C','c','D','d']) and (not Changed);
            end;
        end;
begin
Repeat
    Repeat
        Option := 20;
        ClrScr; DrawStatusLine;
        GotoXY(32,2);  Write('* RECIPE FILE *');
        GotoXY(30,3);  Write('===================');
        GotoXY(32,5);  Write(' 1) Beef');
        GotoXY(32,6);  Write(' 2) Pork');
        GotoXY(32,7);  Write(' 3) Lamb');
        GotoXY(32,8);  Write(' 4) Poultry');
        GotoXY(32,9);  Write(' 5) Seafood');
        GotoXY(32,10); Write(' 6) Meat Less');
        GotoXY(32,11); Write(' 7) Vegetables');
        GotoXY(32,12); Write(' 8) Breads');
        GotoXY(32,13); Write(' 9) Salads');
        GotoXY(32,14); Write('10) Appetizers');
        GotoXY(32,15); Write('11) Cakes');
        GotoXY(32,16); Write('12) Cookies');
        GotoXY(32,17); Write('13) Pies');
        GotoXY(32,18); Write('14) Sauces');
        GotoXY(32,19); Write('15) Drinks');
        WriteStatusLine('Choose Option (1-15)     (0) to EXIT to CP/M');
        Read(Option);
    Until Option in [0..15];
        Case Option of
            0 : begin
                    ClrScr; Halt;
                end;
            1 : begin
                    CurrentType := 'BEEF RECIPES'; CurrentFile := 'BEEF.DTA';
                end;
            2 : begin
                    CurrentType := 'PORK RECIPES'; CurrentFile := 'PORK.DTA';
                end;
            3 : begin
                    CurrentType := 'LAMB RECIPES'; CurrentFile := 'LAMB.DTA';
                end;
            4 : begin
                    CurrentType := 'POULTRY RECIPES'; CurrentFile := 'POULTRY.DTA';
                end;
            5 : begin
                    CurrentType := 'SEAFOOD RECIPES'; CurrentFile := 'SEAFOOD.DTA';
                end;
            6 : begin
                    CurrentType := 'MEATLESS RECIPES'; CurrentFile := 'MEATLESS.DTA';
                end;
            7 : begin
                    CurrentType := 'VEGETABLE RECIPES'; CurrentFile := 'VEGIES.DTA';
                end;
            8 : begin
                    CurrentType := 'BREAD RECIPES'; CurrentFile := 'BREAD.DTA';
                end;
            9 : begin
                    CurrentType := 'SALAD RECIPES'; CurrentFile := 'SALAD.DTA';
                end;
           10 : begin
                    CurrentType := 'APPETIZER RECIPES'; CurrentFile := 'APETIZER.DTA';
                end;
           11 : begin
                    CurrentType := 'CAKE RECIPES'; CurrentFile := 'CAKE.DTA';
                end;
           12 : begin
                    CurrentType := 'COOKIE RECIPES'; CurrentFile := 'COOKIE.DTA';
                end;
           13 : begin
                    CurrentType := 'PIE RECIPES'; CurrentFile := 'PIE.DTA';
                end;
           14 : begin
                    CurrentType := 'SAUCE RECIPES'; CurrentFile := 'SAUCE.DTA';
                end;
           15 : begin
                    CurrentType := 'DRINK RECIPES'; CurrentFile := 'DRINK.DTA';
                end;
        end;
        Repeat
            WriteStatusLine('(E)nter New Recipe      (L)ist Recipes In File      e(X)it To CP/M');
            Read(Kbd,Choice);
        Until Choice in ['E','e','L','l','X','x'];
        Case Choice of
            'E','e' : EnterRecipe;
            'L','l' : ListNames;
            'X','x' : begin
                          ClrScr;
                          Halt;
                      end;
        end;
Until (Choice = 'X') or (Choice = 'x');
end.
