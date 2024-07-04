{R+}
program ARKMAIL; {Copyright (c) 1989 Marc Newman
This program invokes the ARK Version .04 program to create ARKs of FIDO
mail via the submit mechanisim.  It calls itself as the last command
to process further .OUT files.  A .FLO file is created, and it
uses the POLL command to create a .OUT file
In addition, if a .FLO file is not found, all MO?,TU?,WE? etc files
are deleted.  If a .FLO file is found, it is checked to see if the
current filename is already waiting to go out, if so, the same file
is updated.  If not, it is added to (or a new .FLO created) and a
poll sent out.  This program MUST be run on the same drive/user as
the ybbaT MAIL.SYS file and all the .OUT files to be processed.
Include ARKMAIL as the command immediately before KSMAIL in your
outgoing batch file.  That way, any outgoing mail will be ARKed.

You MUST use ARK version .04, prior versions (.35) did not support
multiple drives.

You must provide a ROS.CLK insert which reads your clock and returns
a byte array consisting of:
  t[0] = seconds
  t[1] = minutes
  t[2] = hours
  t[3] = day
  t[4] = month
  t[5] = year
 Note, these are integer values in BYTE format (0-255).  Year is 0-99

 Marc K. Newman
The Black Box RCPM/DRBBS/ybbaT
713-480-2686 300/1200 Baud & FIDONET 1:106/601.0
Version 0.1 3/29/89

If you enjoy this program, use it and feel free to distribute it for
non-commercial use.  If you change it, I would appreciate it if you
retain this notice and give me credit for the portions of the program
I wrote.  If you want to use this program or portions thereof for
purposes, a $10/copy royalty for my trouble and work will be charged
Note, this includes use on CLUB BBSes, as they are considered businesses
be they for profit or non-profit.

Mail any royalty payments to:           Marc Newman
                                        14615 Stilesboro Court
                                        Houston, Texas 77062  }
type
     STR3 = string[3];
     STR4 = string[4];
     str8 = string[8];
     STR11 = STRING[11];
     STR16 = STRING[16];
     STR80 = STRING[80];
     byte256 = array[0..256] of byte;
     TAD_array = array[0..5] of BYTE;
const
     MAIN_DRIVE   : INTEGER = 0; {0=DRIVE A:}
     AUX_DRIVE    : INTEGER = 1; {1=DRIVE B:}
     Select_disk  : integer = $0E;
     Search_first : integer = $11;
     Search_next  : integer = $12;
     Set_DMA      : integer = $1A;
     HEX_array    : array[0..15] of CHAR =
                  ('0','1','2','3','4','5','6','7','8','9',
                  'A','B','C','D','E','F');
     VER          : STRING[3] = '0.1';
var
     OK,
     writenew,
     IN_FLO,
     found     : BOOLEAN;
     mail_sys     : byte256;
     mail_sys_file: file;
     i,
     ERROR,
     LOOP,
     START        : integer;
     MY_NET,
     MY_NODE,
     DEST_NET,
     DEST_NODE    : integer;
     SUB          : FILE;
     FLO          : FILE;
     FILENAME     : STR11;
     NEW_FILENAME : STR8;
     DELTA_NET    : STR4;
     DELTA_NODE   : STR4;
     STRING4      : STR4;
     STRING16     : STR16;
     STRING11     : STR11;
     STRING20     : STRING[20];
     STRING80     : STR80;
     TIME         : TAD_ARRAY;
     BYTE128      : ARRAY[0..128] OF BYTE;
     NEW_EXTENSION : STR3;

{$I ROS.CLK}

function weekday(month, date, year : integer) : integer;
{Zeller congruence to calculate any day of the week using
integer math.  From letter by Bob Whitefield, Decatur, AL
in the February, 1989 'Computer Language' magazine.}
var
     day : integer;
begin
     if month <= 2 then
     begin
          month := month + 12;
          year := year - 1
     end;

     Day := (date + month * 2 + (month + 1) * 6 div 10 + year +
         year div 4 - year div 100 + year div 400 + 2) mod 7;
     weekday := day
end; {Weekday}

FUNCTION HEX(x : integer) : STR4;
VAR
          Z : STR4;
begin
          Z := '    ';
          Z[4] := hex_array[LO(x) and $0F];
          Z[3] := hex_array[(LO(X) AND $F0) SHR 4];
          Z[2] := hex_array[HI(X) and $0f];
          Z[1] := hex_array[(HI(X) and $F0) SHR 4];
          HEX := COPY(Z,1,4);
end;

function inttoBCD(intg : integer) : byte;
var x,y : byte;
begin
    x := intg div 10;
    y := intg mod 10;
    inttoBCD := ((x and $0f) shl 4) + y;
end;

function DEC(X : STR4) : integer;
var
     a,y : integer;
     z : STR4;
begin
     a := 0;
     for i := 4 downto 1 do
     begin
          y := ord(x[i])-ord('0');
          if y > 9 then y := ord(x[i]) - ord('A') +10;
          a := a + (y shl ((4-i) * 4));
     end;
     dec := a;
end;

function max(i,j : integer) : integer;
begin
     if i > j then
        max := i
     else
        max := j;
end;

procedure submit(ST : STR80);
{Save command line to submit file record}
var
   len, I : byte;
   buffer : array[1..128] of byte;
begin
   writeln(st);
   bdos(select_disk,main_drive);
   if (length(st) = 0) or (st[1] = ';')
      or (st[1] = ' ') then exit;
   len := length(st);
   buffer[1] := len;
   for i := 1 to len do
       buffer[i+1] := ord(st[I]);
   buffer[len+2] := 0;
   buffer[len+3] := ord('$');
   for i := len+4 to 128 do
       buffer[i] := 0;
   blockwrite(sub, buffer,1);
end; {Submit}

procedure search_file(VAR in_file : str11;
                      var out_file : str11;
                      var found : boolean);
var
      DMA   : BYTE256;
      FCB   : ARRAY[0..25] OF BYTE ABSOLUTE $005C;
      i,
      START,
      error : integer;
begin
      error := BDos(set_dma,ADDR(DMA));
      FCB[0] := 0;
      for i := 1 to 11 do FCB[I] := ord(in_file[i]);
      error := BDos(SEARCH_FIRST,Addr(FCB));
      found := (error <> 255);
      out_file := '';
      start := error * 32;
      if found then
         for i := 1 to 11 do
             out_file := OUT_FILE + char(mem[addr(dma)+i+start]);
end;

function GET_EXTENSION(NET_NODE,FILENAME :STR8) : STR3;
const
     DAY : array[0..6] of string[2] =
         ('SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA');
var
     i, code : integer;
     temp : string[20];
     file_id : FILE;
     TEXT_FILE : TEXT;
     OK,
     DAY_OK,
     FOUND : boolean;
     ext_day : string[2];
     extension : string[3];
     TEMP_FILE,
     filename_found : str11;
begin
     IN_FLO := FALSE;
     ext_day := day[weekday(time[4],time[3],time[5])];
     assign(file_id,char(main_drive+ord('A')) + ':' + NET_NODE+'.FLO');
     {$I-}
     reset(file_id);
     {$I+}
     ok := (ioresult = 0);
     if not OK then
     begin         {No .FLO file found, look for last extension}
          close(file_id);
          bdos(select_disk,aux_drive);
          TEMP_FILE := FILENAME+EXT_DAY+'?';
          search_file(TEMP_FILE,filename_found,FOUND);
          if FOUND then
          begin
               assign(file_id,char(aux_drive+ord('A'))+':'+
                              COPY(filename_found,1,8) +
                              '.' +
                              COPY(FILENAME_FOUND,9,3));
               erase(file_id);              {Erase last file}
               val(filename_found[11], i, code);
               i := (i + 1) mod 10;
               str(i:1, temp);
               get_extension := ext_day + temp
          end
          ELSE
          BEGIN
               {NO FILES FROM TODAY FOUND, SEE ABOUT YESTERDAY}
               get_extension := ext_day + '0';
          END;
          {SEE IF ANYTHING TO DELETE FROM PREVIOUS DAYS}
          REPEAT
                FOUND := FALSE;
                bdos(select_disk,aux_drive);
                TEMP_FILE := FILENAME+'???';
                SEARCH_FILE(TEMP_FILE,FILENAME_FOUND,FOUND);
                I := -1;
                DAY_OK := FALSE;
                REPEAT
                      I := I + 1;
                      IF COPY(FILENAME_FOUND,9,2) = DAY[I] THEN
                         DAY_OK := TRUE;
                UNTIL OK OR (I = 6);
                IF FOUND AND DAY_OK THEN
                BEGIN
                     ASSIGN(FILE_ID,CHAR(AUX_DRIVE+ORD('A'))+':'+
                            COPY(FILENAME_FOUND,1,8) + '.'+
                            COPY(FILENAME_FOUND,9,3));
                     ERASE(FILE_ID);
                END;
          UNTIL NOT FOUND;
     end
     else       {FOUND A .FLO FILE}
     begin
          close(file_id);
          assign(text_file,CHAR(MAIN_DRIVE+ORD('A')) +
                ':' + net_node+'.FLO');
          reset(text_file);
          temp := '';
          repeat
                readln(text_file,temp);
                WRITELN(TEMP);
          until eof(text_file) or
                ((copy(temp,3,8) = NET_NODE) and
                 (copy(temp,12,2) = ext_day) and
                 (temp[1] <> CHAR($7E)));
          close(text_file);
          extension := copy(temp,12,3);
          if copy(extension,1,2) <> ext_day then
          BEGIN
                get_extension := ext_day + '0';
                ASSIGN(FILE_ID,CHAR(AUX_DRIVE+ORD('A')) + ':' +
                       FILENAME + '.' + EXT_DAY + '0');
                {$I-}
                ERASE(FILE_ID);
                {$I+}
                OK := (IORESULT = 0);
          END
          else
          BEGIN
                IN_FLO := TRUE;
                get_extension := extension;
          END;
     END;
end;


begin
      WRITELN;
      WRITELN('ybbaT ARKMAIL Version ' + VER + ' (c) 1989 Marc Newman');
      WRITELN('The Black Box BBS (713)-480-2686 FIDO 1:106/601.0');
      WRITELN;
      assign(mail_sys_file,CHAR(MAIN_DRIVE+ORD('A'))+':'+'MAIL.SYS');
      RESET(MAIL_SYS_FILE);
      BLOCKREAD(MAIL_SYS_FILE,mail_sys,2);
      MY_NODE :=ord(MAIL_SYS[0]) + (256*ord(MAIL_SYS[1]));
      MY_NET := ord(MAIL_SYS[168])+(256*ord(MAIL_SYS[169]));
      close(mail_sys_file);
      STRING11 := '????????OUT';
      search_file(STRING11,filename,found);
      if found then
      begin
           assign(sub,CHAR(MAIN_DRIVE+ORD('A'))+':'+'$$$.SUB');
           {$I-}
           reset(sub);
           {$I+}
           OK := (IORESULT = 0);
           if OK then
               seek(sub,filesize(sub))
           else
               rewrite(sub);
           string80 := 'ARKMAIL';
           submit(STRING80);
           DEST_NET := DEC(copy(filename,1,4));
           DEST_NODE := DEC(copy(filename,5,8));
           DELTA_NET := HEX(MY_NET - DEST_NET);
           DELTA_NODE := HEX(MY_NODE - DEST_NODE);
           str(dest_net,string20);
           string20 := string20 + '/';
           str(dest_node,string11);
           string20 := string20 + string11;
           string80 := 'STATUS HOLD ' + STRING20;
           SUBMIT(STRING80);
           string80 := 'POLL ' + string20;
           submit(string80);
           GETTAD(TIME);
           NEW_FILENAME := HEX((TIME[4] shl 12) +
                       (inttobcd(TIME[3]) * 64) +
                       inttobcd(TIME[2])) +
                       HEX((inttobcd(TIME[1]) * 512) +
                       (inttobcd(TIME[0]) * 4));
           STRING80 := 'ERA '+NEW_FILENAME+'.PKT';
           SUBMIT(STRING80);
           new_extension := get_extension(filename,delta_net+delta_node);
           string80 := 'ARK -K ' + CHAR(ORD('A')+AUX_DRIVE) + ':' +
                    COPY(DELTA_NET,1,4) +
                    COPY(DELTA_NODE,1,4) + '.' +
                    new_extension + ' ' +
                    CHAR(ORD('A')+MAIN_DRIVE) + ':' +
                    copy(NEW_FILENAME,1,8)+'.PKT';
           submit(string80);
           string80 :='REN '+copy(new_filename,1,8)+'.PKT='+
                    copy(FILENAME,1,8)+'.OUT ';
           submit(string80);
           assign(FLO,CHAR(ORD('A')+MAIN_DRIVE) + ':' +
                      HEX(DEST_NET)+HEX(DEST_NODE)+'.FLO');
           {$I-}
           RESET(FLO);
           {$I+}
           OK := (IORESULT = 0);
           IF (NOT OK) THEN
           begin
                REWRITE(FLO);
                for i := 0 to 127 do BYTE128[i] := $1a;
                start := 0;
                WRITENEW := TRUE;
           end
           ELSE
           begin
                WRITENEW := FALSE;
                SEEK(FLO,MAX(FILESIZE(FLO)-1,0));
                BLOCKREAD(FLO,BYTE128,1);
                I := 0;
                REPEAT
                     START := I+1;
                     I := I + 1;
                UNTIL (BYTE128[I] = $1A) OR (I = 127);
                IF START = 127 THEN
                BEGIN
                     START := 0;
                     FOR I := 0 TO 127 DO BYTE128[I] := $1A;
                     WRITENEW := TRUE;
                END;
           end;
           STRING16 := CHAR(ORD('A') + AUX_DRIVE) + ':' +
                           COPY(DELTA_NET,1,4)+
                           COPY(DELTA_NODE,1,4)+ '.' +
                           new_extension+
                           CHR($0D) + CHR($0A);
           FOR I := 0 TO 15 DO BYTE128[START+I] := ORD(STRING16[I+1]);
           IF NOT WRITENEW THEN SEEK(FLO,MAX(FILESIZE(FLO)-1,0));
           IF NOT IN_FLO THEN BLOCKWRITE(FLO,BYTE128,1);
           CLOSE(FLO);
     CLOSE(SUB);
     end;
end.
