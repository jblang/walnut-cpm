Program TestSortedDirectory;

      {This program (barely) compiled in a 59.0 kilobyte TPA}

Procedure SortedDirectory;

{  Gets and writes an sorted vertically displayed CP/M directory of a
  selected disk: gives file sizes in KiloBytes, sorts alphabetically,
  correctly treats large files > 1 physical extent.  Also, this CP/M
  procedure will accept any drive from "A:" to "P:", and any standard
  CP/M wildcard file specification (i.e. *.COM, *.PAS, C:TUR*.*, etc).
  Files with the "System" attribute set may be displayed if the option
  "/s" is appended to the drive-spec & filename string.

   Based on original program by Mike Yarus, 2231 16th Street, Boulder,
  CO 80302, Compuserve 73145,513.  I extend my thanks to Mike for his
  program code and inspiration.  All I have done is add to his work.

   Somewhat modified, now will work with hard or floppy disks.  The file
  size algorithm now correctly implemented for: Molecular's n/STAR, CP/M,
  CP/M+, MP/M II.  Should also work for TurboDos and other MP/M derived
  operating systems.
   Will properly handle file sizes up to 32 megabytes for the following:
  Molecular's "n/STAR", MP/M, or TurboDos.

   This procedure will add an additional 3,751 bytes code, and 615 bytes
  data to any program which utilizes "SortedDirectory".  Please feel free
  to reduce procedure size, and please let me know how to do so...

     Don V Wells, Jr.  Alexandria, Virginia 22309, CompuServe 72447,666.
                  Turbo Pascal 3.00A CP/M  May 29, 1986
}

                { Version 1.0   May   29, 1986 by DVWjr }

Const
  NO_MORE_FILES     = $FF;  {No more files found on Bdos search for first and next}
  SEARCH_FOR_FIRST  = 17;   {Bdos Search for first function number}
  SEARCH_FOR_NEXT   = 18;   {Bdos Search for Next function number}
  SET_DMA_ADDRESS   = 26;   {Bdos Set DMA Address function number}
  CMD_LINE          = 23;
  MSG_LINE          = 24;

Type
  Str16          = String[16];
  Str14          = String[14];
  Str12          = String[12];
  AnyFcb         = Array[0..35] of Byte;
  AnyDma         = Array[0..127] of Byte;
  DirEntry_Ptr   = ^DirEntryRecord;
  DirEntryRecord =
    record
      FileName    : Str12;         {file name}
      FileSize    : Integer;       {file size in KiloBytes}
      Left_Ptr    : DirEntry_Ptr;  {Left Pointer}
      Right_Ptr   : DirEntry_Ptr;  {Right Pointer}
    end; {DirEntryRecord}

Var
  MyFcb  : AnyFcb;  {a masking File Control Block}
  MyDma  : AnyDma;  {a directory entry buffer, (can not use $80, Turbo Uses!)}

  BdosFuncNum        : Byte;     {number of the CP/M Bdos function required}
  DirPageNdex        : Byte;     {which of the 4 dir entries in MyDma is current?}

  TargetDrive        : Char;                {Drives "A:".."P:"}
  TargetDriveAndFile : Str14;               {The file which will be our directory mask}

  Entry_Ptr          : DirEntry_Ptr;        {the new entry pointer}
  Root_Ptr           : DirEntry_Ptr;        {the root entry pointer}

  BlockSizeInKb      : Byte;                {The variable block-size in kilo-bytes}
  SysFiles           : Boolean;             {Flag for showing (or not) files with }
                                            { the "System" attribute set.         }

  NumOfDirEntries    : Integer;     {number of directory entries, including >1 extents}
  NumOfFiles         : Integer;     {Number of files; controls screen print position;
                                    { and in most casees will be 2048 max}

{***************************************************************************}

Procedure ClrEos;
 begin
  CrtInit;  {I have "Corruptly" used Turbo's CrtInit as a Wyse-50    }
            {Clear-to-End-of-Screen command via Turbo Pascal's Tinst }
            {install program, since there is no formal ClrEos defined}

                      {You must find some way to get a}
            {Terminal-Clear-to-End-of-Screen, or equivalent here}
 end; {Procedure ClrEos}


Function UpperCase(InputStr : Str16) : Str16;
   Var
     index : Byte;

  begin { of function UpperCase}
    For index := 1 to Length(InputStr) do
     InputStr[index] := Upcase(InputStr[index]);
    UpperCase := InputStr;
  end;  { of function UpperCase}


Function DriveLoggedIn(DriveLetter : Char) : Boolean;

   Const
     RETURN_LOGIN_VECTOR   =  24;

   Var
     Result          : Integer;
     DriveNumber     : Byte;
     DriveBitNumber  : Integer;

 begin  {of function DriveLoggedIn}
  DriveLetter := UpCase(DriveLetter);
  DriveNumber := Ord(DriveLetter) - $41;
  DriveBitNumber :=  1 shl DriveNumber;
  Result := BdosHL(RETURN_LOGIN_VECTOR);
  DriveLoggedIn := ((Result and DriveBitNumber) = DriveBitNumber);
 end;   {of function DriveLoggedIn}


Procedure Get_DriveAndFileName_SysFlag(var DriveAndFileName : Str14;
                                       var ShowSystemFiles  : Boolean);
Var
  DriveFileSysFlag  : Str16;
  SlashPos          : Byte;


begin   {Procedure Get_DriveAndFileName_SysFlag}
  GotoXY(1,CMD_LINE); ClrEol;
  write('Directory of drive: ');
  LowVideo;
  write('---> [X]:FileName.Typ >');
  BufLen := 16;
  HighVideo;
  Read(DriveFileSysFlag);
  LowVideo;
  GotoXY(1,MSG_LINE); ClrEol;
  write('working...');
  DriveFileSysFlag := UpperCase(DriveFileSysFlag);
  SlashPos := Pos('/S',DriveFileSysFlag);
  if SlashPos = 0 then ShowSystemFiles := FALSE
  else
   begin
    ShowSystemFiles := TRUE;
    Delete(DriveFileSysFlag,SlashPos,2);
  end; {if}
  DriveAndFileName := DriveFileSysFlag;
end;   {Procedure Get_DriveAndFileName_SysFlag}



Procedure Init_MyFcb(    InputDriveAndFile : Str14;
                     var DriveLetter       : Char;
                     var FcbToInit         : AnyFcb);

       {Note: This procedure, with some modifications, borrowed from }
       {      the program: Turbo Kermit.                             }

{ Initialize an FCB with a filename and filetype for use with BDOS calls.     }
{ File control block set for reading all masked files.                        }
{ Note that when only the first extent of a big file is needed (eg, for a     }
{ list of file names only) one sets 13th byte (Count = 12) of the fcb to zero.}
{ But, in our case, we NEED the 13th byte set to '?' for the FCB BDOS search, }
{ in order to get the file size by getting ALL of a file's physical extents.  }


Type
  Str8  = String[8];
  Str3  = String[3];

Var
  Count        : Byte;
  FileName     : Str8;
  FileType     : Str3;


Procedure Parse_FileName(    InputFile   : Str14;
                         var DriveLetter : Char;
                         var FileName    : Str8;
                         var FileType    : Str3 );


    {Note: This procedure, with some modifications, borrowed from    }
    {      the program: Turbo Kermit.                                }

    {This procedure converts a string into the standard CP/M format  }
    {for processing. This format is all upper case, and inserts ?'s  }
    {into the string if the wildcards ? or * are found in the string.}
    { Finally, the string is expanded so spaces are placed in any    }
    {unfilled positions in the name.  These are placed in the middle }
    {of the filename. (i.e.  abc.de is converted to 'abc     .de ')  }

  Const
    GET_CURRENT_DEFAULT_DISK = 25;  {Bdos Return Current Disk function number}

  Var
    Insert_Position : Byte;
    Count           : Byte;


  begin {Procedure Parse_FileName}
    InputFile := UpperCase(InputFile);
    if Pos('.', InputFile) <> 0 then      {separate the file name and type}
     begin
      FileName := Copy(InputFile,1,Pos('.',InputFile) - 1);
      FileType := Copy(InputFile,Pos('.',InputFile) + 1, 3);
     end
    else
     begin
      FileName := InputFile;
      FileType := '';                     {no file type in this case}
    end; {if}
    if Pos(':', FileName) = 2 then        {check for drive spec}
     begin
      DriveLetter := Copy(FileName,1,1);  {The ":" must be at position #2, and drive spec directly before it.}
      if not (DriveLetter in ['A'..'P']) then DriveLetter := Chr(Bdos(GET_CURRENT_DEFAULT_DISK) + $41);
      Delete(FileName,1,2);               {Delete the Drive spec and the ":"}
     end
    else
     DriveLetter := Chr(Bdos(GET_CURRENT_DEFAULT_DISK) + $41);   {fill in the drive-letter of the current disk}
    {end if}
    if FileName = '' then
     begin
      FileName := '????????';             {must be 8 "?" or := '*'}
      FileType := '???';                  {must be 3 "?" or := '*'}
    end; {if}
    while (Pos('*',FileName) <> 0) do          {find any '*' wildcards}
     begin
      Insert_Position := Pos('*', FileName);   {find the spot}
      Delete(FileName,Insert_Position,1);      {get rid of the "*"}
      while(Length(FileName) < 8) do Insert('?',FileName,Insert_Position);
    end; {while}                               {insert ?'s until filename is filled. Note that the first '*'}
                                               {will fill the string, so any other *'s in the name will be  }
                                               {deleted and replaced with a single '?'.  '*k*' will be      }
                                               {converted to '??????k?'                                     }
    while Pos('*',filetype) <> 0 do             {do the same for the filetype}
      begin
        Insert_Position := Pos('*',FileType);
        Delete(FileType,Insert_Position,1);
        while(Length(FileType) < 3) do Insert('?',FileType,Insert_Position);
    end; {while}
    while Length(FileName) < 8 do              {fill out the filename with spaces}
      FileName := FileName + ' ';
    while Length(FileType) < 3 do              {do the same for the filetype}
      FileType := FileType + ' ';
  end;  {Procedure Parse_FileName}


  begin  {Procedure Init_MyFcb}
    Parse_FileName(InputDriveAndFile,DriveLetter,FileName,FileType);  {put filespec in proper form}
    FcbToInit[0] := Ord(DriveLetter) - $40;                           {store the drive spec}
    for Count := 1 to 8 do                        {put in the filename. Array operation, not string}
      FcbToInit[Count] := Ord(FileName[Count]);
    for Count := 1 to 3 do                        {same for filetype. Must be integers here}
      FcbToInit[8+Count] := Ord(FileType[Count]);
    FcbToInit[12] := Ord('?');                    {must match ALL physical extents(directory entries)}
    for Count := 13 to 35 do
      FcbToInit[Count] := 0;                      {rest of the FCB must be set to 0's}
  end; {Procedure Init_MyFcb}



Procedure Get_BlockSize(    DriveLetter : Char;
                        var BlockSize   : Byte);

    {Block size = "BlockSizeInKb" so that the file sizes }
    {may be calculated in later procedures.  It will also}
    {reset any drive determined to be a removable floppy }
    {for proper directory operation.                     }


  Const
    GET_DISK_PARAMETER_BLOCK_ADDRESS  = 31;
    GET_CURRENT_DEFAULT_DISK          = 25;
    SELECT_LOGICAL_DISK               = 14;
    RESET_LOGICAL_DISK_DRIVE          = 37;   {This BDOS call is said "not" to}
                                              {work for CP/M, but n/STAR does.}
  Type
    DskParmBlockRecord  =
    record
      SectorsPerTrack              : Integer;    { Sectors per Track }
      BlockShiftFactor             : Byte;       { Data Allocation block shift factor }
      BlockMask                    : Byte;       { Block Mask, used here to calculate the allocation block size }
      ExtentMask                   : Byte;       { Extent Mask, not used by this procedure }
      MaxAllocBlockLessOne         : Integer;    { Maximum Allocation blocks for this drive }
      NumDirEntriesLessOne         : Integer;    { Number of Directory Entries less one }
      DirAllocByte0                : Byte;       { Left Byte of Directory Allocation Blocks }
      DirAllocByte1                : Byte;       { Right Byte of Directory Allocation Blocks }
      NumBytesInDirCheckBuffer     : Integer;    { Check buffer for Floppys only }
      ReservedTracks               : Integer     { Reserved System Tracks for OS, usually floppy }
    end;  {DskParmBlockRecord}

  Var
    DskParmBlock_Ptr  : ^DskParmBlockRecord;   {Pointer to DPB}
    DriveNumber       : Byte;                  {CP/M Select disk #, 00 = A:, 01=B:, etc}
    CurrentDisk       : Byte;                  {Remember your roots, from whence you came...}
    DriveBitNumber    : Integer;               {16 drive bit-map}


begin  {Procedure Get_BlockSize}
 DriveLetter := UpCase(DriveLetter);
 DriveNumber := Ord(DriveLetter) - $41;            {CP/M disk #, 00 = A:, etc}
 CurrentDisk := Bdos(GET_CURRENT_DEFAULT_DISK);    {get the present disk #}
 if DriveLoggedIn(DriveLetter) then
  begin
   Bdos(SELECT_LOGICAL_DISK,DriveNumber);          {select the new disk}
   DskParmBlock_Ptr := Ptr(BdosHL(GET_DISK_PARAMETER_BLOCK_ADDRESS));
   with DskParmBlock_Ptr^ do
    begin
     BlockSize := Succ(BlockMask) shr 3;
     if NumBytesInDirCheckBuffer <> 0 then    {...it's a floppy drive}
      begin
       DriveBitNumber := 1 shl DriveNumber;
       Bdos(RESET_LOGICAL_DISK_DRIVE,DriveBitNumber);  {Bdos call #37 works for n/STAR, maybe not for CP/M???}
     end; {if}
   end; {with}
   Bdos(SELECT_LOGICAL_DISK,CurrentDisk);          {"clicking heels three times..." Select the Old disk before exiting}
 end; {if}
end;   {Procedure Get_BlockSize}



Procedure WriteFileNames (    AnyFileName    : Str12;
                              KiloBytes      : Integer;
                              CurrentDrive   : Char;
                          var DisplayCounter : Integer);

    {   Output of directory file information in 4 columns,   }
    {         Sorted Vertically for ease of Reading.         }
    {    This output algorithm deduced by Stephen C. Hill    }

Const
  NUMBER_OF_ROWS            = 13;    {Number of Rows of filenames displayed}
  NUMBER_OF_COLUMNS         =  4;    {Number of Columns of filenames displayed}
  START_OF_DISPLAY_ROW      =  9;    {Cannot be less than 3!}
  CHARS_PER_DISPLAYED_FILE  = 20;    {Limits displayed file sizes to 999 Kb,}
                                     { if Number of Columns displayed is 4, }
                                     { but, file sizes of up to 32,768 Kb   }
                                     { can be calculated and displayed with }
                                     { the appropriate number of display    }
                                     { columns.                             }

begin  {Procedure WriteFileNames}
 if DisplayCounter = 0 then                        {DisplayCounter is a screen display variable}
  begin
   GotoXY(1,(START_OF_DISPLAY_ROW - 2));
   ClrEos;
   GotoXY(1,Pred(START_OF_DISPLAY_ROW));
   HighVideo;
   write('Directory of drive ',CurrentDrive,':');  {Display the directory drive letter}
   LowVideo;
 end; {if}
 GotoXY(Succ((CHARS_PER_DISPLAYED_FILE * ((DisplayCounter div NUMBER_OF_ROWS) mod NUMBER_OF_COLUMNS))),
   (START_OF_DISPLAY_ROW + (DisplayCounter mod NUMBER_OF_ROWS)));
 Write('| ',AnyFileName,' ',KiloBytes:3,'k ');     {This line is where the CHARS_PER_DISPLAYED_FILE  = 20 comes from!}
 DisplayCounter := Succ(DisplayCounter);           {Increment the File counter, as new Unique FCB discovered}
 if (DisplayCounter mod (NUMBER_OF_COLUMNS * NUMBER_OF_ROWS)) = 0 then
  begin
   GotoXY(1,CMD_LINE);
   write('Hit <Return> for more files...');
   BufLen := 0;
   Readln;                                        {The pause that refreshes...}
   GotoXY(1,(START_OF_DISPLAY_ROW - 2));
   ClrEos;
   GotoXY(1,Pred(START_OF_DISPLAY_ROW));
   HighVideo;
   write('Directory of drive ',CurrentDrive,':');
   LowVideo;
 end; {if}
end; {Procedure WriteFileNames}



{$A-}   {**** recursive reference needed around this procedure ****}
Procedure BuildTree (var RootTree_ptr  : DirEntry_Ptr;
                     var EntryTree_ptr : DirEntry_Ptr);

{ Builds an ordered tree of directory entries.  Note that the replace   }
{ function in code takes care of duplicate entries in dictionary due to }
{ large files present in >1 "PHYSICAL" extent. (i.e. - Directory entry) }


begin {Procedure BuildTree}
  if RootTree_ptr = Nil then                                     {end of limb, place current entry}
    RootTree_ptr := EntryTree_ptr
  else
    if RootTree_ptr^.FileName = EntryTree_ptr^.FileName then     {replace entry?, same filename, then skip duplicate}
     begin
      if EntryTree_ptr^.FileSize > RootTree_ptr^.FileSize then   {if the new directory entry file size is bigger, store it}
        RootTree_ptr^.FileSize := EntryTree_ptr^.FileSize;
      Dispose(EntryTree_ptr)
     end {if}
    else
     begin
      if RootTree_ptr^.FileName > EntryTree_ptr^.FileName then   {left for small}
        BuildTree(RootTree_ptr^.Left_Ptr, EntryTree_ptr)
      else
        BuildTree(RootTree_ptr^.Right_Ptr, EntryTree_ptr)        {right for large}
      {end if}
    end {if}
  {end the "top" if}
end;  {Procedure BuildTree}
{$A+}


{$A-}   {**** recursive reference needed around this procedure ****}
Procedure WriteTree (var RootTree_ptr   : DirEntry_Ptr;
                     var DirDriveLetter : Char;
                     var DisplayFileNum : Integer);

  {Recursively writes the directory in order, (alphabetically) from the top.}

begin {WriteTree}
 if RootTree_ptr <> Nil then
  begin
   WriteTree(RootTree_ptr^.Left_Ptr,DirDriveLetter,DisplayFileNum);
   WriteFileNames(RootTree_ptr^.FileName,RootTree_ptr^.FileSize,DirDriveLetter,DisplayFileNum);
   WriteTree(RootTree_ptr^.Right_Ptr,DirDriveLetter,DisplayFileNum);
 end; {if}
end; {WriteTree}
{$A+}


{$A-}   {**** recursive reference needed around this procedure ****}
Procedure DisposeTree (Var RootTree_ptr : DirEntry_Ptr);

{ Disposes of the storage devoted to the directory tree Post-order. }
{ Required for repetitive execution of the program within a larger  }
{ program, even though the directory tree is fairly small.          }


begin  {Procedure DisposeTree}
 if RootTree_ptr <> Nil then
  begin
   DisposeTree(RootTree_ptr^.Left_Ptr);
   DisposeTree(RootTree_ptr^.Right_Ptr);
   Dispose(RootTree_ptr);
 end; {if}
end;  {Procedure DisposeTree}
{$A+}


Procedure GetEntry(    BdosFuncCode    : Byte;
                       KbPerBlock      : Byte;
                       ShowSystemFiles : Boolean;
                   var MaskingFcb      : AnyFcb;
                   var MyDma           : AnyDma;
                   var DirectoryCode   : Byte;
                   var NumDirEntries   : Integer;
                   var RootTree_ptr    : DirEntry_Ptr;
                   var EntryTree_ptr   : DirEntry_Ptr);

  { Finds and writes a single directory entry from the disk directory    }
  { to the directory tree; calculates the proper file size; makes a tree }
  { entry via the BuildTree procedure.                                   }


Var
   FreeMemory            : Integer;  {The positive amount of free memory in the heap}
   SysAttributeSet       : Boolean;  {Flag if System attribute set on directory entry}
   Ndex                  : Byte;     {Just an index counter byte}
   FirstByteOfDirEntry   : Byte;     {Byte location in the MyDma of the first byte of the directory entry in question}
   TempNumOfBlocks       : Real;     {Temporary holder of first-cut number of blocks}
   NumberOfSectorsInFile : Real;     {Total number of 128 byte CP/M sectors in a file;}
                                     { note the algorithm used to calulate!}

begin  {Procedure GetEntry}
  DirectoryCode := Bdos(BdosFuncCode,Addr(MaskingFcb)); {get directory in MyDma}
  if (DirectoryCode <> NO_MORE_FILES) then
   begin                                                {the entry exists, the Bdos does NOT get deleted ($E5) dir entries!}
    FirstByteOfDirEntry := DirectoryCode shl 5;         {Just a * 32}
    if ShowSystemFiles then {skip-null}
    else
     begin
      SysAttributeSet := (((MyDma[(FirstByteOfDirEntry + 10)]) and $80) = $80);
      if SysAttributeSet then  Exit;  {...Skip this directory entry}
    end; {if}
    FreeMemory := Abs(MemAvail);
    if FreeMemory <= 1000 then      {Leave ENOUGH bytes of Heap free...  Guess for now}
     begin
      GotoXY(1,MSG_LINE); ClrEol;
      write('Not enough memory to sort and display all files...');
      Exit;
    end; {if}
    New(EntryTree_ptr);                               {place for new entry}
    with EntryTree_ptr^ do
     begin
      FileName[0] := Chr(12);                         {Set FileName Length to 12, as CP/M}
                                                      {pads all filenames to full length.}
      for Ndex := 1 to 8 do
        FileName[Ndex] := Chr(MyDma[(FirstByteOfDirEntry + Ndex)]);        {get file name}
      FileName[9] := '.';
      for Ndex := 9 to 11 do
        FileName[Succ(Ndex)] := Chr(MyDma[(FirstByteOfDirEntry) + Ndex]);  {get file extension}

      NumberOfSectorsInFile := (MyDma[(FirstByteOfDirEntry) + 14] * 32 * 128) +
                               (MyDma[(FirstByteOfDirEntry) + 12] * 128) +
                               (MyDma[(FirstByteOfDirEntry) + 15]);   {total n/STAR (CP/M,MP/M, TurboDos)}
                                                                      {file-size in 128-byte CP/M sectors}
      TempNumOfBlocks := NumberOfSectorsInFile/(8 * KbPerBlock);
      if Frac(TempNumOfBlocks) <> 0 then
        FileSize := Trunc((Int(TempNumOfBlocks) + 1) * KbPerBlock)
      else
        FileSize := Trunc(Int(TempNumOfBlocks) * KbPerBlock);
      {end if}   {The above if statement: Recalculates file sizes to make}
                 {them end on allocation block borders, as they must.    }
      Left_Ptr := Nil;
      Right_Ptr := Nil;
     end;  {with EntryTree_ptr^}
    NumDirEntries := Succ(NumDirEntries);
    BuildTree(RootTree_ptr,EntryTree_ptr)                  {put the entry in the tree}
  end; {if}
end;  {Procedure GetEntry}



begin  {Procedure SortedDirectory}
  Entry_Ptr := Nil;      {Initialize directory tree pointers}
  Root_Ptr := Nil;       {Initialize directory tree pointers}
  SysFiles := FALSE;     {Initialize the System Attribute Flag}
  NumOfDirEntries := 0;  {Initialize the Number of disk directory entries counter}
  NumOfFiles := 0;       {Initialize the Number of files counter; the output print control counter}

  Bdos(SET_DMA_ADDRESS,Addr(MyDma));                 {Define MyDma to allow directory entry buffering}
  Get_DriveAndFileName_SysFlag(TargetDriveAndFile,SysFiles);
  Init_MyFcb(TargetDriveAndFile,TargetDrive,MyFcb);
  if DriveLoggedIn(TargetDrive) then
   begin
    Get_BlockSize(TargetDrive,BlockSizeInKb);        {BlockSizeInKb now passed.}
    BdosFuncNum := SEARCH_FOR_FIRST;                 {BDOS Search for First file}
    Repeat                                           {Get'em and tree'em}
      GetEntry(BdosFuncNum,BlockSizeInKb,SysFiles,MyFcb,MyDma,
               DirPageNdex,NumOfDirEntries,Root_Ptr,Entry_Ptr);
      BdosFuncNum := SEARCH_FOR_NEXT;             {Switch to BDOS Search for Next after first file}
    Until DirPageNdex = NO_MORE_FILES;            {No more directory entries left to search for}
    WriteTree(Root_Ptr,TargetDrive,NumOfFiles);   {Sorted directory OUT to the screen}
    GotoXY(1,CMD_LINE);                           {Wait for release}
    DisposeTree(Root_Ptr);                        {Release dynamic storage}
    writeln('Number of files: ',NumOfFiles);
    write('Number of directory entries: ',NumOfDirEntries);
   end
  else
   begin
    GotoXY(1,MSG_LINE); ClrEol;            {The DisplayMsg procedure will not work here}
    GotoXY(6,MSG_LINE);
    write(^G'There is no ');
    HighVideo;
    write(TargetDrive,':');
    LowVideo;
    write(' logged drive.');
    Delay(1599);                           {Let'em read the message}
 end; {if}
 NormVideo;
end;  {Procedure SortedDirectory}

begin {Program TestSortedDirectory}
 SortedDirectory;
End. {Program TestSortedDirectory}
