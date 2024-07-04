program dgptr(output);  {digital repeater control program}

(*$c-,e-,f-,m-,p-,r-,s+,t-*)

const   maxinfofld = 128;       {maximum info field in a frame}
        maxinfocnt = 129;       {maximum info field count - 1}

type    tcbptr = ^tcb;          {task control block pointer}
        qcbptr = ^qcb;          {queue header pointer}
        mcbptr = ^mcb;          {message control block pointer}
        frmptr = ^frame;        {frame pointer}
        taskstate = (active,ready,blocked);     {task running state}
        prid = 0..255;          {priority and id}

        tcb = record            {task control block}
          tcblk: tcbptr;        {next lower priority tcb}
          tcbwt: tcbptr;        {next waiting tcb}
          tcbsw: taskstate;     {task status word}
          tcbmd: 0..255;        {task mode}
          tcbrm: mcbptr;        {message passed from rcv call}
          tcbid: prid;          {task identity}
          tcbpr: prid;          {task priority: 0=high, 255=low}
          tcbsb: integer;       {bottom of stack}
          tcbst: integer;       {top    of stack}
          tcbhb: integer;       {bottom of heap}
          tcbpc: integer;       {task start address}
        end;

        qcb = record            {queue control block}
          qcblk: frmptr;        {first message in queue}
          qcbwt: tcbptr;        {first waiting tcb in queue}
        end;

        mcb = record            {message control block}
          mcblk: frmptr;        {next message in queue}
          mcbtp: 0..255;        {message type}
          mcbvl: 0..255;        {message value}
        end;

        byte = 0..255;          {a byte}
        code = 0..255;          {frame status}
        addressfield = byte;    {address field octet}
        controlfield = byte;     {control field octet}
        infofield = array[0..maxinfocnt] of byte; {information field length+2}
        textfield = array[1..70] of char;

        frame = record          {frame control block}
          lnk: mcb;             {linkage to next frame}
          len: integer;         {length of info field}
          cnt: integer;         {current rcv or xmt count}
          res: 0..7;            {residual byte length}
          adr: addressfield;    {frame address}
          ctl: controlfield;    {control field}
          inf: infofield;       {information field}

        end;

        lcb = record
          lineno: 0..31;                {physical line in system}
          baudrate: integer;            {system clock divisor baud rate}
          clockrate: integer;           {system clock divisor for 100 ms}
          timeout: 0..255;              {100 ms. clock ticks for T1}
          a1: array[1..7] of byte;
          chfree: boolean;              {current line state}
          modemchar: code;              {modem characteristics}
          modemout: byte;               {modem output status byte}
          modemin: byte;                {modem input status byte}
          a2: array[1..19] of byte;
          rcvstatus: code;              {rcv status}
          rcvmsg: mcb;                  {rcv message location}
          rcvframes: qcb;               {rcv frames queue}
          a3: array[1..10] of byte;
          xmtstatus: code;              {xmt status}
          xmtmsg: mcb;                  {xmt message location}
          xmtframes: qcb;               {xmt frames queue}
          a4: array[1..8] of byte;

        end;

var     qfree: qcb;             {free buffer pool}
        msg: mcbptr;            {incoming message temporary}
        line: lcb;              {line control block}
        iorun: boolean;         {run flag}
        timecount: integer;     {counter for main delay loop}
        freecount: integer;     {counter for channel free condition}
        fp0,fp1,fp2,fp3: frmptr;    {frame pointer temporaries}
        fp4,fp5,fp6,fp7: frmptr;    {frame pointer temporaries}
        i,j,k: integer;

(*$i+*)

procedure initio;external;                      {initialize interrupt system}
procedure enable;external;      {turn on interrupt system, unfreeze proc. env.}

procedure lkopn(var line: lcb);external;        {initialize hdlc hardware}
procedure lkcls(var line: lcb);external;        {deinit hdlc hardware}
procedure lkrcv(var line: lcb);external;        {start packet receiver}
procedure lkxmt(var line: lcb);external;        {start packet transmitter}
procedure lksts(var line: lcb);external;        {line modem status}

procedure cwid(var line: lcb);external;         {cw identification}
procedure delay(time: integer);external;        {100 msec delay loop}

{This procedure adds a frame to the end of the current list of frames.}

procedure enquepkt(var qhdr: qcb; var fp: frmptr);

var     mp: frmptr;             {pointer temporary}
        empty: boolean;         {flag for an empty list}

begin   fp^.lnk.mcblk := nil;   {reset link to next message}
        mp := qhdr.qcblk;       {first message in list}
        empty := mp = nil;      {flag for an empty list}

      if not empty then {queue has messages already waiting}

        begin while mp^.lnk.mcblk<>nil do mp := mp^.lnk.mcblk; {find end list}
              mp^.lnk.mcblk := fp;       {put message at end of list}
        end

      else {queue is empty}

        begin   qhdr.qcblk := fp     {just add a new message}
        end;
end;

{This procedure initializes the receive frames and starts the receiver}

procedure startrcvr;

var     fpr: frmptr;                    {temporary frame pointer}

begin   line.rcvframes.qcblk := nil;    {reset the rcv queue}
        enquepkt(line.rcvframes,fp0);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp1);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp2);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp3);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp4);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp5);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp6);   {enque frame for receiving}
        enquepkt(line.rcvframes,fp7);   {enque frame for receiving}
        fpr := fp0;                     {initialize chain}
        repeat
        fpr^.lnk.mcbvl := 0;            {zero frame status}
        fpr^.len := 2 + maxinfofld + 2; {set packet length maximum size + crc}
        fpr := fpr^.lnk.mcblk;          {next frame in list}
        until fpr = nil;                {end of list}
        lkrcv(line);                    {start the receiver}

end;

{This procedure initializes a new frame for transmission.}

procedure fillpkt(fp: frmptr;adr: addressfield;ctl: controlfield;
                  tfcount: integer;textstr:textfield);

var i: integer;

begin   fp^.len := 4 + tfcount;         {total xmt count}
        fp^.res := 0;                   {no residual bits}
        fp^.adr := adr;                 {initialize address field}
        fp^.ctl := ctl;                 {initialize control field}
        for i := 1 to tfcount do fp^.inf[i-1] := ord(textstr[i]); {move text}
        fp^.inf[tfcount] := 13;         {add carriage return}
        fp^.inf[tfcount+1] := 10;       {add line feed}
end;

{Send packets out for the beacon}

procedure beacon;

begin   line.xmtframes.qcblk := nil;    {reset the xmt queue}
        fillpkt(fp0,255,0,70,
  'This is the KA6M ASCII/HDLC beacon in Menlo Park, California  Rev 2.10');
        fillpkt(fp1,255,2,69,
  'The quick brown fox jumped over the lazy dog''s back. 0123456789 !@#$% ');
        fillpkt(fp2,255,20,70,
  'You are receiving the signal of San Francisco''s first packet repeater.');
        enquepkt(line.xmtframes,fp0);   {enque frame 0}
        enquepkt(line.xmtframes,fp1);   {enque frame 1}
        enquepkt(line.xmtframes,fp2);   {enque frame 2}
        lkxmt(line);                    {transmit the packets}
        while line.xmtstatus = 0 do ;   {wait for end of xmt}
end;

{Validate and repeat a packet.}

procedure retransmit;

var     fpt: frmptr;                    {frame being examined}
        fptnx: frmptr;                  {next frame in linkage}
        adr: addressfield;              {local storage for address}
        adrok: boolean;                 {address in range flag}
        pst: 0..255;                    {packet status}
        pktok: boolean;                 {packet status acceptable flag}

begin   line.xmtframes.qcblk := nil;    {reinit transmit queue}
        fpt := fp0;                     {pointer to first frame in chain}
        repeat
          fptnx := fpt^.lnk.mcblk;        {get next frame in linkage}
          adr := fpt^.adr;                {get received address}
          adrok := (adr>=128) and (adr<160); {address in range}
          pst := fpt^.lnk.mcbvl;          {packet status}
          pktok := (pst=3) or (pst=7);    {packet status without errors}
          if adrok and pktok then         {repeat the packet}
           begin
           fpt^.len := fpt^.cnt;          {set transmit length}
           fpt^.res := 0;                 {no residue bits}
           fpt^.adr := fpt^.adr+32;       {use sender's address offset by 32}
           enquepkt(line.xmtframes,fpt);  {place frame onto transmit queue}
           end;
          fpt := fptnx;                   {point to next frame, if any}
        until fptnx = nil;                {stop if end of chain}
        if line.xmtframes.qcblk <> nil then {if there any good packets}
          begin
          lkxmt(line);                    {transmit them}
          while line.xmtstatus = 0 do {nothing};  {wait for end of transmit}
          end;
        startrcvr;                        {restart receiver}

end;


begin   {main program}

initio;                                 {set up interrupt world}
lkopn(line);                            {initialize the hardware}
enable;                                 {turn on interrupt system}
new(fp0);new(fp1);new(fp2);new(fp3);    {allocate some frames}
new(fp4);new(fp5);new(fp6);new(fp7);    {allocate some frames}

iorun := true;                          {run forever}
while iorun do
 begin  cwid(line);                     {identify}
        beacon;                         {transmit beacon information}
        startrcvr;                      {setup and start the receiver}
        timecount := 3000;              {controls delay before next id}
        freecount := 0;                 {controls free channel timer}
        repeat                          {listen for packets loop}
         delay(1);                      {wait 100 milliseconds}
         lksts(line);                   {get current modem status}
         if ((fp0^.lnk.mcbvl<>1) and line.chfree) then retransmit; {repeat pkt}
         if not line.chfree then freecount := 0 {count up 30 sec of clear chnl}
                        else freecount := freecount + 1;
         if timecount <> 0 then timecount := timecount - 1; {countdown cwid}
        until
         (timecount = 0) and (freecount > 300);

 end;

lkcls(line);                            {close down the hardware}

end.
