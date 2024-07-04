
PROGRAM PortMonitor;

{
   General purpose I/O Port monitor
   Written by Jesse Bob Overholt, Carrollton, Texas
   Copyright (c) 1985, but you can have a copy if you want one!

   DDT and its various relatives does't provide much for examining and
   changing I/O ports under CP/M. When I found myself in need of that
   capability I turned (naturally) to Turbo Pascal and cranked out
   this little program. It should work without pain on most CP/M
   systems, and with a little effort maybe even on 16 bitters.

   You'll want to change the constants to set the control codes used for
   cursor movement. These are for Montezuma Micro CP/M 2.2 on a TRS-80
   Model 4/4P.

   Operation is simple. Select the port by moving the cursor to it. Then
   specify changes by entering the first letter of the item to change.
   For example, type 'P' to set the port number, then enter the number
   in hex. Port numbers are always entered in hex, but data entry
   follows the Type set for the port.

   Commands:
      P = Set Port address (in hex)
      M = Set port Mode (I for Input, O for Output)
      D = Set port Data (value entered according to type)
      T = Set port Type (D for Decimal, H for Hex, B for Binary)
      ENTER or RETURN = Do the actual I/O and display data if input
      S = Scan port to perform continous I/O until 'space' entered
      BREAK or ^C = Exit back to CP/M

   The real problem with quick and dirty software tools is that they
   are always under-documented. This program is no exception, and I'll
   leave it for you to decide how self-documenting Pascal really is.

   Having spent many years in software support for pay the author is not
   all that excited about phone calls with gripes, enhancements, etc. If
   you really need to contact me you can try CompuServe 70130,101 or send
   a SASE to 3139 Oak Hill Road, Carrollton, TX  75007.

Modifications:
 14 July 85 by Gail Graham W5MLY
  Continous scan until keypressed added.

}

CONST
   Up = ^K;       {Kimtron KT-7 and/or (Televideo 925)}
   Down = ^J;
   Left = ^H;
   Right = ^L;
   Break = ^Q;
   Enter = ^M;
   Beep = ^G;

TYPE
   PortSet = SET OF 0..15;
   Modes = (Input, Output);
   DisplayTypes = (Binary, Hex, Decimal);
   KeyList = SET OF CHAR;
   InputLine = STRING[8];
   DispLine = STRING[8];

VAR
   CurPort, CurVal, CurX, CurY: BYTE;
   DefinedPorts: PortSet;
   PortAddress, PortData: ARRAY [0..15] OF BYTE;
   PortMode: ARRAY [0..15] OF Modes;
   PortType: ARRAY [0..15] OF DisplayTypes;
   KeyBuf: CHAR;
   BreakRequested: BOOLEAN;

{-------------------------------------------------------------------------}
 (* Following Keypressed function replaces the KeyPressed Function in
    Turbo Pascal, and is for use only with the NEC-APC. The Turbo Pascal
    keypressed function does not work on the NEC-APC. If your keypressed
    function does not work and you do not have a NEC, then you will have to
    write a similar replacement function to match your machine. If your
    keypressed function does work then this entire function may be deleted.
    The function is included as a remark so it will not compile normally. *)


 (*
Function  KEYPRESSED:BOOLEAN;
VAR
 KEYSTAT:byte;
BEGIN
 KeyStat  := Port[$4C] and $10;
 If KeyStat <> 0 then keypressed  := true else keypressed  := false;
end;
  *)

{-------------------------------------------------------------------------}

PROCEDURE SetXY (DescNum: BYTE);

BEGIN
   CurY := (CurPort DIV 4) * 5 + 5;
   CurX := (CurPort MOD 4) * 20 + 1;
END;

{-------------------------------------------------------------------------}

FUNCTION GetKey (LegalKeys: KeyList): CHAR;

VAR
   InKey: CHAR;

CONST
   Printable: SET OF CHAR = [#$20..#$7E];

BEGIN
   REPEAT
      Read(Kbd,InKey);
      InKey := UpCase(InKey);
   UNTIL InKey IN LegalKeys;
   IF InKey IN Printable THEN Write(InKey);
   GetKey := InKey;
END;

{-------------------------------------------------------------------------}

FUNCTION GetLine (Length: BYTE; ValidKeys: KeyList): InputLine;

VAR
   Buffer: InputLine;
   CurLen: BYTE;
   InKey: CHAR;

{ Local } PROCEDURE BackSpace;
          BEGIN
             Write(^H,'_',^H);
             Delete (Buffer, CurLen, 1);
             CurLen := CurLen - 1;
          END;

BEGIN
   CurLen := 0;
   WHILE CurLen < Length DO
   BEGIN
      Write('*');
      CurLen := CurLen + 1;
   END;
   WHILE CurLen > 0 DO BackSpace;
   Buffer := '';
   REPEAT
      InKey := GetKey (ValidKeys + [^H, ^X]);
      CASE InKey OF
         ^H: IF CurLen > 0 THEN BackSpace;
         ^X: WHILE CurLen > 0 DO BackSpace;
      ELSE
         BEGIN
            Buffer := Buffer + InKey;
            CurLen := CurLen + 1;
         END;
      END;
   UNTIL CurLen = Length;
   GetLine := Buffer;
END;

{-------------------------------------------------------------------------}

FUNCTION GetHex: BYTE;

VAR
   InBuf: InputLine;

{ Local } FUNCTION HexVal (Digit: CHAR): BYTE;
          VAR
             DigitVal: BYTE;
          BEGIN
             DigitVal := Ord(Digit) - Ord('0');
             IF DigitVal > 15 THEN DigitVal := DigitVal - 7;
             HexVal := DigitVal;
          END;

BEGIN
   InBuf := GetLine (2, ['0'..'9']+['A'..'F']);
   GetHex := HexVal(InBuf[1]) SHL 4 + HexVal(InBuf[2]);
END;

{-------------------------------------------------------------------------}

FUNCTION GetDec: BYTE;

VAR
   InBuf: InputLine;
   I, Value: INTEGER;

BEGIN
   REPEAT
      InBuf := GetLine (3, ['0'..'9']);
      Val(InBuf, Value, I);
      IF Value > 255 THEN I := 1;
      IF I > 0 THEN Write(^H,^H,^H,Beep);
   UNTIL I = 0;
   GetDec := Value;
END;

{-------------------------------------------------------------------------}

FUNCTION GetBin: BYTE;

VAR
   Value: BYTE;
   InBuf: InputLine;

BEGIN
   Value := 0;
   InBuf := GetLine (8, ['0'..'1']);
   WHILE Length(InBuf) > 0 DO
   BEGIN
      Value := Value SHL 1;
      IF InBuf[1] = '1' THEN Value := Value + 1;
      Delete (InBuf, 1, 1);
   END;
   GetBin := Value;
END;

{-------------------------------------------------------------------------}

FUNCTION CvtBin: DispLine;

VAR
   Buffer: DispLine;
   Value: BYTE;

BEGIN
   Buffer := '';
   Value := PortData[CurPort];
   REPEAT
      IF Odd(Value) THEN Buffer := '1' + Buffer
      ELSE Buffer := '0' + Buffer;
      Value := Value SHR 1;
   UNTIL Length(Buffer) = 8;
   CvtBin := Buffer;
END;

{-------------------------------------------------------------------------}

FUNCTION CvtHex: DispLine;

VAR
   Buffer: DispLine;

{ Local } FUNCTION HexDig (Value: BYTE): CHAR;
          BEGIN
             Value := Value + Ord('0');
             IF Value > Ord('9') THEN Value := Value + 7;
             HexDig := Chr(Value);
          END;

BEGIN
   CvtHex := HexDig(PortData[CurPort] SHR 4)
           + HexDig(PortData[CurPort] AND $0F);
END;

{-------------------------------------------------------------------------}

PROCEDURE DisplayData;

BEGIN
   GotoXY(CurX+10,CurY+2); Write('        ',^H^H^H^H^H^H^H^H);
   CASE PortType[CurPort] OF
      Binary: Write(CvtBin);
      Hex: Write(CvtHex);
      Decimal: Write(PortData[CurPort]:3);
   END;
END;

{-------------------------------------------------------------------------}

BEGIN

{ Set up opening banner }
   ClrScr;
   LowVideo;
   ClrEol; GotoXY(10,1); Writeln('CCP/M Port Monitor Version 0.02');
   Writeln('     (c) (p) 1985  by Jessie Overholt and modified by others');

   NormVideo;
   Write('    Arrows to select, <P,M,D,T> to set up, ');
   Writeln('<RETURN> for I/O, <BREAK> to quit');
   Writeln('<S> to scan assigned ports, <any key> to stop scan');
{ Build Port desciptors }
   FOR CurPort := 0 TO 15 DO
   BEGIN
      SetXY (CurPort);
      GotoXY(CurX, CurY); Write('[ ] ');
      LowVideo; Write('Port:');
      GotoXY(CurX+4,CurY+1); Write('Mode:');
      GotoXY(CurX+4,CurY+2); Write('Data:');
      GotoXY(CurX+4,CurY+3); Write('Type:');
      NormVideo;
      GotoXY(CurX+10,CurY); Write('??');
      GotoXY(CurX+10,CurY+1); Write('Input');
      GotoXY(CurX+10,CurY+2); Write('00');
      GotoXY(CurX+10,CurY+3); Write('Hex');
      PortAddress[CurPort] := $00;
      PortMode[CurPort] := Input;
      PortData[CurPort] := $00;
      PortType[CurPort] := Hex;
   END;
   DefinedPorts := [];
   CurPort := 0;
   BreakRequested := FALSE;

{ Begin main command loop }
   REPEAT
      SetXY (CurPort); GotoXY(CurX+1, CurY);
      Read (Kbd,KeyBuf);
      CASE UpCase(KeyBuf) OF
         Up: CurPort := (CurPort - 4) AND $0F;
         Down: CurPort := (CurPort + 4) AND $0F;
         Left: CurPort := (CurPort - 1) AND $0F;
         Right: CurPort := (CurPort + 1) AND $0F;
         Break: BreakRequested := TRUE;
         'P': BEGIN
                 GotoXY(CurX+10,CurY);
                 PortAddress[CurPort] := GetHex;
                 DefinedPorts := DefinedPorts + [CurPort];
              END;
         'M': BEGIN
                 GotoXY(CurX+10,CurY+1); Write('? I/O ',^H^H^H^H^H^H);
                 IF GetKey(['I','O']) = 'I' THEN
                 BEGIN
                    Write('nput ');
                    PortMode[CurPort] := Input;
                 END
                 ELSE
                 BEGIN
                    Write('utput');
                    PortMode[CurPort] := Output;
                 END;
              END;
         'D': BEGIN
                 GotoXY(CurX+10,CurY+2);
                 Write('        ',^H^H^H^H^H^H^H^H);
                 CASE PortType[CurPort] OF
                    Binary: PortData[CurPort] := GetBin;
                    Hex: PortData[CurPort] := GetHex;
                    Decimal: PortData[CurPort] := GetDec;
                 END;
              END;
         'T': BEGIN
                 GotoXY(CurX+10,CurY+3); Write('? B/H/D',^H^H^H^H^H^H^H);
                 CASE GetKey(['B','H','D']) OF
                    'B': BEGIN
                            Write('inary  ');
                            PortType[CurPort] := Binary;
                         END;
                    'H': BEGIN
                            Write('ex     ');
                            PortType[CurPort] := Hex;
                         END;
                    'D': BEGIN
                            Write('ecimal ');
                            PortType[CurPort] := Decimal;
                         END;
                 END;
                 DisplayData;
              END;

           'S':BEGIN
                Delay(300); (* allow keypressed time to clear *)
                WHILE not keypressed  DO
                 BEGIN
                  DELAY(500);
                  FOR CurPort  := 0 to 15 do
                   BEGIN
                    IF CurPort IN DefinedPorts THEN
                     BEGIN
                       SetXY(CurPort);
                       GotoXY(CurX,CurY);
                       CASE PortMode[CurPort] OF
                         Input: BEGIN
                                   PortData[CurPort] :=
                                      Port[PortAddress[CurPort]];
                                   DisplayData;
                                END;
                         Output: Port[PortAddress[CurPort]] :=
                                    PortData[CurPort];
                      END;
                     END;
                    END;
                 END;
                END;
         Enter: BEGIN
                   IF CurPort IN DefinedPorts THEN
                   BEGIN
                      CASE PortMode[CurPort] OF
                         Input: BEGIN
                                   PortData[CurPort] :=
                                      Port[PortAddress[CurPort]];
                                   DisplayData;
                                END;
                         Output: Port[PortAddress[CurPort]] :=
                                    PortData[CurPort];
                      END;
                   END
                 ELSE Write(Beep);
                END;
      END;
   UNTIL BreakRequested;
   ClrScr;

END.
