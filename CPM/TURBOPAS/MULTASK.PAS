{task #1: keyboard  -> serial out
 task #2: serial in ->  video out
      control-C will abort program}
program main;
const   TASKS=2;
        STACKSIZE=70;
{next 7 constants are needed for the Kaypro}
        KDATA=5;
        KSTAT=7;
        BAUDP=0;
        SDATA=4;
        SSTAT=6;
        RMASK=1;
        TMASK=4;

        CC=3;
type    stack = array[0..STACKSIZE] of integer;
        tasknum = -1..TASKS;
var     sp0,sp1,sp2: integer;{when zero, task not initialized}
        oldn: tasknum;
        nextn: tasknum;
Procedure defer; forward;
procedure exit;
          begin
          writeln('TASK #',oldn,' terminated.');
          oldn:=-1;
          defer;
          end;
function keyin:byte;
         begin
           repeat
             defer;
           until (RMASK = (RMASK and port[KSTAT]));
           keyin:= port[KDATA];
         end;
procedure videout(b:byte);
          begin
          bdos(6,b);
          end;
function serin: byte;
         begin
         repeat
           defer;
         until (RMASK = (RMASK and port[SSTAT]));
         serin:= port[SDATA];
         end;
procedure serout(b:byte);
          begin
          repeat
            defer;
          until (TMASK = (TMASK and port[SSTAT]));
          port[SDATA]:=b;
          end;
.ne 10
Procedure task1;
var       mystack: stack;
          key: byte;
          begin
          stackptr:=addr(mystack[STACKSIZE]);
          repeat
            key:=keyin;
            if key=CC then exit
            else serout(key);
          until false;{forever}
          exit;
          end;
Procedure task2;
var       mystack: stack;
          begin
          stackptr:=addr(mystack[STACKSIZE]);
          repeat
            videout(serin);
          until false{forever};
          exit;
          end;
procedure initall;
var       i: integer;
          Begin
          sp1:=0;
          sp2:=0;
          oldn:=0;
          {initialize Kaypro's SIO}
          port[BAUDP]:=14;{9600 Baud}
          port[SSTAT]:=24;
          port[SSTAT]:=4;
          port[SSTAT]:=68;
          port[SSTAT]:=1;
          port[SSTAT]:=0;
          port[SSTAT]:=3;
          port[SSTAT]:=193;
          port[SSTAT]:=5;
          port[SSTAT]:=234;
          end;
Procedure schedule;
          begin
          if oldn=TASKS then nextn:=1
          else nextn:=oldn+1;
          end;
.bp
procedure defer;
var sp: integer;
        begin
        case oldn of
           0: sp0:=stackptr;
           1: sp1:=stackptr;
           2: sp2:=stackptr;
           end{case};
        schedule;
        oldn:=nextn;
        case nextn of
        0: sp:=sp0;
        1: sp:=sp1;
        2: sp:=sp2;
        end{case};
        if sp<>0 {initialized}
        then begin
          stackptr:=sp;
             end
        else {not initialized}
             begin
             writeln('Starting task #',nextn);
             case nextn of
             1: task1;
             2: task2;
             end{case};
             end;
     end{defer};
begin{main}
initall;
writeln('Multitasking version of simple terminal program');
writeln('Control-C will terminate it');
writeln;
defer;
writeln('Main: done');
end.


{task #1: keyboard -> fifo1
 task #2: fifo1    -> filter -> fifo2
 task #3: fifo2    -> slow display    }
program main;
const   TASKS=3;
        STACKSIZE=20;
        NFIFOS=2;{#1 is for input and #2 for output}
        PRATE=300;{SLOWs the display function}
{the following three constants are for the Kaypro Computer}
        KDATA=5; KSTAT=7; RMASK=1;
        CR=13;
        LF=10;
        CC=3;
        BS=8;
        RUB=127;
        SPACE=32;
        CQ=17;{XON}
        CS=19;{XOFF}
type    stack = array[0..STACKSIZE] of integer;
        fifo = record
               buf: array[0..255] of byte;
               inptr: byte;
               outptr: byte;
               flow: boolean;{for flow control}
               end;
        fifon = 1..NFIFOS;
        tasknum = -1.. TASKS;
var     sp0,sp1,sp2,sp3: integer;{when zero, task not initialized}
        oldn: tasknum;
        nextn: tasknum;
        fifos: array[1..NFIFOS] of fifo;
Procedure defer; forward;
function occupancy(p: fifon):byte;
         begin with fifos[p] do
         occupancy:= inptr-outptr;
         end;
function vacancy(p: fifon): byte;
         begin with fifos[p] do
         vacancy:=outptr-inptr-1;
         end;
function dequeue1: byte;
         begin with fifos[1] do
         begin
         while (occupancy(1)=0) or not flow
               do defer;
         dequeue1:= buf[outptr];
         outptr:=outptr+1;
         end;
         end;
function dequeue2: byte;
         begin with fifos[2] do
         begin
         while (occupancy(2)=0) or not flow
               do defer;
         dequeue2:= buf[outptr];
         outptr:=outptr+1;
         end;
         end;
procedure exit;
          begin
          writeln('JOB #',oldn,' terminated.');
          oldn:=-1;
          defer;
          end;
procedure enqueue1(b:byte);
          begin with fifos[1] do
          begin
          buf[inptr]:=b;
          while vacancy(1)=0 do
             defer;{hang while full}
          inptr:=inptr+1;
          end;
          end;
procedure enqueue2(b:byte);
          begin with fifos[2] do
          begin
          buf[inptr]:=b;
          while vacancy(2)=0 do
             defer;{hang while full}
          inptr:=inptr+1;
          end;
          end;
function keyin:byte;
         begin
           repeat until (RMASK = (RMASK and port[KSTAT]));
           keyin:= port[KDATA];
         end;
procedure vout(b:byte);
          begin
          bdos(6,b);
          end;
Procedure print;{task#3}
var       mystack: stack;
          i: integer;
          begin
          stackptr:=addr(mystack[STACKSIZE]);
          i:=0;
          {initialize fifo#2}
          with fifos[2] do
               begin
               outptr:=0;
               inptr:=0;
               flow:=true;
               end;
          repeat
            i:=i+1;
            if i=PRATE then
               begin
               i:=0;
               vout(dequeue2);
               end
            else
               defer;
          until false;{forever}
          exit;
          end;
Procedure keyboard;{task #1}
var       mystack: stack;
          cb: byte;
          begin
          stackptr:=addr(mystack[STACKSIZE]);
          {initialize fifo #1}
          with fifos[1] do
               begin
               inptr:=0;
               outptr:=0;
               flow:=true;
               end;
          repeat
            if (1 = (1 and port[KSTAT]))
            then
              begin
              cb:= port[KDATA];
              enqueue1(cb);
              end
            else defer;
          until false{forever};
          exit;
          end;
Procedure filter;{task #2}
var       mystack: stack;
          b: byte;
          begin
          stackptr:=addr(mystack[STACKSIZE]);
          repeat
            b:=dequeue1;
            case b of
            CR: begin
                enqueue2(CR);
                enqueue2(LF);
                end;
            LF: {ignore};
            CC: exit;
            BS,RUB:
               begin
               enqueue2(BS);
               enqueue2(SPACE);
               enqueue2(BS);
               end;
            CQ: fifos[2].flow:=true;
            CS: fifos[2].flow:=false;
            else enqueue2(b);
            end{case};
          until false;{forever!}
          exit;
          end;
procedure initall;
var       i: integer;
          Begin
          sp1:=0;
          sp2:=0;
          sp3:=0;
          oldn:=0;
          end;
Procedure schedule;
          begin
          if oldn=TASKS then nextn:=1
          else nextn:=oldn+1;
          end;
procedure defer;
var sp: integer;
          begin
           case oldn of
           0: sp0:=stackptr;
           1: sp1:=stackptr;
           2: sp2:=stackptr;
           3: sp3:=stackptr;
           end{case};
        schedule;
        oldn:=nextn;
        case nextn of
        0: sp:=sp0;
        1: sp:=sp1;
        2: sp:=sp2;
        3: sp:=sp3;
        end{case};
        if sp<>0 {initialized}
        then begin
          stackptr:=sp;
             end
        else {not initialized}
             begin
             case nextn of
             1: keyboard;
             2: filter;
             3: print;
             end{case};
             end;
     end{defer};
begin{main}
initall;
writeln('<Demonstration of multitasking with queues (FIFOs)>');
writeln;
writeln('Control-S stops output (you can still type ahead!)');
writeln('Control-Q restarts output (you can see what you have typed ahead)');
writeln('RUB or BACKSPACE will "undo" on screen the last letter');
writeln('Control-C terminates this program');
writeln;
defer;
writeln('main: done');
end.

