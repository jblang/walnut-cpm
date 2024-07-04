{ This routine provides english error messages when a program aborts
  due to runtime or IO errors.  To use this routine you must place the
  line :
              ErrorPtr := Ofs(Error);  (* PC/MS-Dos*)
         or   ErrorPtr := Addr(Error); (* CP/M*)

  in your main program }



Procedure Error(ErrorNumber, ErrorAddress : Integer);
Type
  Str30   = String[32];
Const
  RtErrNums : array[1..11] of Integer = ($01,$02,$03,$04,$10,$11,$90,$91,
                                       $92,$F0,$FF);
  IOErrNums : array[1..16] of Integer = ($01,$02,$03,$04,$10,$20,$21,$22,
                                       $90,$91,$99,$F0,$F1,$F2,$F3,$FF);

  RtErrMess : Array[1..12] of Str30 = ('Floating Point Overflow',
                                       'Division by Zero Attempted',
                                       'Square Root Argument Error',
                                       'Logarithm Argument error',
                                       'String Length Error',
                                       'Invalid String Index',
                                       'Index out of range',
                                       'Scalar or Subrange out of Range',
                                       'Out of Integer Range',
                                       'Overlay File Not Found',
                                       'Heap/Stack collision',
                                       'Unknown Error');
  IOErrMess : Array[1..17] of Str30 = ('File Does Not Exist',
                                       'File Not Open for Input',
                                       'File Not Open for Output',
                                       'File Not Open',
                                       'Error In Numeric Format',
                                       'Operation Not Allowed',
                                       'Not Allowed in Direct Mode',
                                       'Assign to Std Files not allowed',
                                       'Record Length Mismatch',
                                       'Seek Beyond End of File',
                                       'Unexpected End of File',
                                       'Disk Write Error',
                                       'Directory is Full',
                                       'File Size OverFlow',
                                       'Too Many Open Files',
                                       'File Disappeared',
                                       'Unknown Error');

Var
  MessNo,I,J : Integer;
  Message    : Str30;
Begin
  J := Lo(ErrorNumber);
  If ErrorNumber > 500  then
    Begin
      MessNo := 12;
      For I  := 1 to 11 do
        If J = RtErrNums[I] then MessNo := I;
      Message := RtErrMess[MessNo];
    End
  Else  If ErrorNumber < 500  then
    Begin
      MessNo := 17;
      For I  := 1 to 16 do
        If J = IOErrNums[I] then MessNo := I;
      Message := IOErrMess[MessNo];
    End;

  Gotoxy(1,24);
  Writeln(^G^G^G);
  If ErrorNumber > 500 then
    Writeln(' *** Runtime Error #',J,' Encountered ! ')
  Else
    Writeln(' *** IO Error #',J,' Encountered ! ');
  Writeln(' *** ',Message);
  Writeln(' *** Please call Joe Ryburn at Extension 354 for help ');
  Writeln(' *** Thank you ');
  Writeln;
  Halt
End;
