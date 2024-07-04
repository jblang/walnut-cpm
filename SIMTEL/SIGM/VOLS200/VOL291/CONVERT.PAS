{$C-}
Type Str255=String[255];

Function FromBase(Base: Integer; Value: Str255; Var Ok: Boolean): Integer;
  Var
    FB,Negative,Digit,I: Integer;
  Begin
    Negative:=1;
    Ok:=(Base>=2) And (Base<=36);
    If Ok Then
     Begin
      If Copy(Value,1,1)='-' Then
       Begin
        Value:=Copy(Value,2,254);
        Negative:=-1;
       End;
      FB:=0;
      I:=1;
      While (I<=Length(Value)) And Ok Do
       Begin
        Digit:=Ord(Upcase(Value[I]));
        Case Char(Digit) Of
          '0'..'9': Digit:=Digit-48;
          'A'..'Z': Digit:=Digit-55;
          Else Digit:=100;
         End;
        If Digit>=Base Then Ok:=False;
        FB:=FB*Base+Digit;
        I:=I+1;
       End;
     End;
    FromBase:=FB*Negative;
    If Not Ok Then FromBase:=0;
  End;

Function ToBase(Base,Value: Integer; Var Ok: Boolean): Str255;
  Var TB: Str255;
      Negative: String[1];
      D: Integer;
  Const Digits: Array [0..35] Of Char='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Begin
    Ok:=(Base>=2) And (Base<=36);
    If Not Ok Then TB:='Illegal base'
    Else
     Begin
      Negative:='';
      If Value<0 Then Negative:='-';
      TB:='';
      Repeat
        D:=Value Mod Base;
        If D<0 Then D:=-D;
        TB:=Digits[D]+TB;
        Value:=Value Div Base;
      Until Value=0;
      TB:=Negative+TB;
     End;
    ToBase:=TB;
  End;

Var
  Base,ABase,Result: Integer;
  Value: Str255;
  Ok: Boolean;

Begin
  ClrScr;
  For Base:=2 To 36 Do
   Begin
    GotoXY(1+39*((Base-1) Div 18),1+(Base-1) Mod 18);
    Write(Base:2,':');
   End;
  Repeat
    GotoXY(1,20);
    Write('Enter base to convert from (0 to end): ');
    ClrEol;
    ReadLn(ABase);
    If ABase=0 Then Halt;
    Write('Enter value: ');
    ClrEol;
    ReadLn(Value);
    Result:=FromBase(ABase,Value,Ok);
    If Not Ok Then WriteLn('Illegal base or value')
    Else
     Begin
      For Base:=2 To 36 Do
       Begin
        Value:=ToBase(Base,Result,Ok);
        GotoXY(5+39*((Base-1) Div 18),1+(Base-1) Mod 18);
        If Base=ABase Then LowVideo
        Else NormVideo;
        Write(Value);
        NormVideo;
        Write('          ');
       End;
     End;
   Until False;
End.
ideo;
        Write(Value);
    