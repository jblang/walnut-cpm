program tbohires;   (* 80 col graphics for c128 cp/m *)
                    (* integrated from various magazine articles and *)
                    (* c128 prog ref guide *)
                    (* leonard howie *)
 const
   vdcport=$d600; vdcplus1=$d601;    (* port addresses for 8563 chip *)

 type
    mask_array = array[0..7] of byte;

 var
   waitport,portreg,regbyte:byte;
   x,y,lcol,lrow:integer;
   ytemp:real;
   m: mask_array;
   ChrAry:Array[0..8192] of byte;

 (* ============= screen plotting routines - 8563 vdc chip =========== *)

  (* 8 mar 87-bitmapping the 8563 video display controller *)
                   (* commodore 128 cp/m - turbo pascal *)

 Procedure RamAddr(z:integer);Forward;

 procedure readvdc;             (* this routine reads any 8563 register *)
 begin
   port[vdcport]:=portreg;               (* desired register number to port *)
   repeat
     waitport:=(port[vdcport]) and 128;  (* read address port value  *)
   until waitport=128;                   (* until bit 7 is one *)
   regbyte:=port[vdcplus1];              (* then read the data port *)
 end;


 procedure writevdc;             (* this routine writes to any 8563 register *)
 begin
   port[vdcport]:=portreg;               (* desired register number to port *)
   repeat
     waitport:=(port[vdcport]) and 128;  (* read address port value  *)
   until waitport=128;                   (* until bit 7 is one *)
   port[vdcplus1]:=regbyte;              (* then write to the data port *)
 end;

(* Procedures Save_Char and Load_Char added 8/24/87 T. Dolan *)

Procedure Save_Char;

Begin
WriteLn(^Z);
WriteLn('Saving Character Ram to Memory');
For Y := 8192 to 16384 Do                  (* Start of VDC Char Ram *)
   Begin
      RamAddr(Y);
      Portreg := 31;                       (* Split 16 bit Value *)
      ReadVdc;                             (* Read Value from VDC Ram *)
      ChrAry[Y-8192] := RegByte;           (* Store it in an array *)
   End;
End;

(* Load_Char has the same basic syntax as Save_Char only it writes the saved
   values back into the VDC Ram *)

Procedure Load_Char;

Begin
For Y := 8192 to 16384 Do
   Begin
      RamAddr(Y);
      PortReg := 31;
      RegByte := ChrAry[Y-8192];
      WriteVdc;
   End;
End;

 procedure zeroram;
 begin
   regbyte:=0;
   portreg:=14;   writevdc;              (* all addresses at start of ram *)
   portreg:=15;   writevdc;
   portreg:=18;   writevdc;
   portreg:=19;   writevdc;
 end;


 procedure setbitmap;                (* put a 1 in bit 7, reg 25 for bitmap *)
 begin                               (* version 7a 8563 chip - value is 128 *)
   portreg:=25;                      (* versions 8 & 9 chips - value is 135 *)
   regbyte:=135;                     (* -otherwise horiz scroll is affected *)
   writevdc;
 end;

 procedure colormap;
 begin
   portreg:=26;
   regbyte:=144;                     (* good value for monochrome *)
   writevdc;                         (* go for self on color      *)
 end;

 procedure fillmap(dumbyte:byte);
 begin
   zeroram;
   portreg:=31;
   regbyte:=dumbyte;
   for lrow:=1 to 200 do begin
     for lcol :=1 to 80 do writevdc;
   end;
 end;

 procedure setmask;                (* set correspondence between remainder *)
 var l:integer;                    (* after (div 8) and position in byte   *)
 begin
   m[7]:=1;
   for l:=6 downto 0 do
     m[l]:=2*m[l+1];
 end;


 procedure ramaddr;
                         (* set pointer to desired 8563 chip ram byte *)
 var
   hybyte,lobyte:byte;
   hyval,loval:integer;

 begin
   hyval:=hi(z);               (* get hi & lo bytes of 16 bit int  *)
   loval:=lo(z);
   hybyte:=ord(chr(hyval));    (* convert to byte *)
   lobyte:=ord(chr(loval));
   portreg:=18;                (* regs 18,19 pair is pointer to chip ram *)
   regbyte:=hybyte;
   writevdc;
   portreg:=19;
   regbyte:=lobyte;
   writevdc;
  end;


 procedure plotvdc(mapcol,maprow:integer);
 var                               (*   plot a dot in vdc memory   *)
   bytenr,leftbit,lmask:integer;
   savebyte:byte;
 begin
   bytenr:=maprow*80 + mapcol div 8;
   leftbit := mapcol mod 8;
   lmask := m[leftbit];
   ramaddr(bytenr);
   portreg := 31;
   readvdc;
   savebyte := regbyte or lmask;
   ramaddr(bytenr);
   portreg := 31;
   regbyte := savebyte;
   writevdc;
  end;

 (* ===================  demo-plotting example ======================= *)

 begin
  Save_Char;
  writeln;
  writeln('******** cp/m hires graphics example for the c-128 ********');
  WriteLn('Hit Return to Continue');
  readln(x);
  setbitmap;                            (* put 8563 in the bitmap mode *)
  colormap;                             (* set bitmap color *)
  fillmap(0);                           (* clear the screen *)
  setmask;                              (* compute pixel mask array m *)

                                        (* plot 1/2 of a parabola *)
  for x := 0 to 639 do begin
    ytemp := x*1.0;
    ytemp := ytemp*ytemp*199.0/(639.0*639.0);
    y := trunc(ytemp);
    plotvdc(x,y);
  end;

  Delay(500);                       (* hold the plot on screen *)
  writeLn(^G);
  PortReg := 25;
  regbyte := 71;                    (*  Version 7a regbyte = 64   *)
  writevdc;                         (* Version 8 & 9 regbyte = 71 *)
  WriteLn(^Z);
  WriteLn(^[^[^['12');
  WriteLn('Please wait while the character set is reloaded into VDC ram');
  WriteLn;
  WriteLn('This will take a few seconds to do');
  Load_Char;
  WriteLn('All Done');
 end.

