{$C-}
{$R-}
program Squeezer;

  const version   = '1.8  last update 08-02-84';

{ CP/M compatible file squeezer utility.

  This translation uses the Huffman algorithm to develop a binary tree representing the decoding information
  for a variable length bit string code for each input value.  Each string's length is in inverse proportion
  to its frequency of appearance in the incoming data stream.  The encoding table is derived from the decoding
  table.

  The range of valid values into the Huffman algorithm are the values of a byte stored in an integer plus the
  special endfile value chosen to be an adjacent value. Overall, 0-SPEOF.

  The algorithm develops the single element trees into a single binary tree by forming subtrees rooted in
  interior nodes having weights equal to the sum of weights of all their descendents and having depth counts
  indicating the depth of their longest paths.

  When all trees have been formed into a single tree satisfying the heap property (on weight, with depth as a
  tie breaker) then the binary code assigned to a leaf (value to be encoded) is then the series of left (0) and
  right (1) paths leading from the root to the leaf.  Note that trees are removed from the heaped list by moving
  the last element over the top element and reheaping the shorter list.

  To further compress the output code stream, all bytes pass directly through except for:
        1) DLE is encoded as (DLE, zero).
        2) repeated byte values (count >= 3) are encoded as (value, DLE, count).

  In the original design it was believed that a Huffman code would fit in the same number of bits that will hold
  the sum of all the counts.  That was disproven by a user's file and was a rare but infamous bug. This version
  attempts to choose among equally weighted subtrees according to their maximum depths to avoid unnecessarily long
  codes. In case that is not sufficient to guarantee codes <= 16 bits long, we initially scale the counts so the
  total fits in an unsigned integer, but if codes longer than 16 bits are generated the counts are rescaled to a
  lower ceiling and code generation is retried.

  The "node" array of structures contains the nodes of the binary tree. The first NUMVALS nodes are the leaves
  of the tree and represent the values of the data bytes being encoded and the special endfile, SPEOF.  The
  remaining nodes become the internal nodes of the tree.

  Program states:
     NoHist    don't consider previous input
     SentChar  lastchar set, no lookahead yet
     SendNewC  newchar set, previous sequence done
     SendCnt   newchar set, DLE sent, send count next
}
{.pa}
  const space     = ' ';
        Error     = -1;
        Null      = -2;
        Recognize = $FF76;  { unlikely pattern }
        DLE       = #$90;
        SPEOF     = 256;    { special endfile token }
        NumVals   = 257;    { 256 data values plus SPEOF }
        NumNodes  = 513;    { = 2 * NUMVALS - 1 = number of nodes }
        NoChild   = -1;     { indicates end of path through tree }
        maxcount  = MAXINT; { biggest UNSIGNED integer }

   type FileName = string[30];
        ValType  = array[0..numvals] of integer;
        StateTypes = (NoHist,SentChar,SendNewC,SendCnt,EndFile);
        NodeType = record
                     weight: real;             { number of appearances }
                     tdepth: integer;          { length on longest path in tree }
                     lchild, rchild: integer;  { indices to next level }
                   end;

    var InFileName, OutFileName: FileName;
        InFile, OutFile: file of char;
        start, finish, i: integer;
        crc: integer;      { Cyclic Redundancy Check code }

        likect: integer;   { count of consecutive identical chars }
        lastchar, newchar: char;

        State: StateTypes;
        EOFlag, done: boolean;

        node: array[0..NUMNODES] of NodeType;
        dctreehd: integer;        { index to head node of final tree }

{ This is the encoding table:  The bit strings have first bit in = low bit.
  Note that counts were scaled so code fits UNSIGNED integer }

        codelen, code: array[0..numvals] of integer; { number of bits in code & code itself, right adjusted }
        tcode: integer;     { temporary code value }

        curin: integer;     { Value currently being encoded }
        cbitsrem: integer;  { Number of code string bits remaining }
        ccode: integer;     { Current code shifted so next code bit is at right }
{.pa}
{.cp12}
  procedure zero_tree;
    { Initialize all nodes to single element binary trees with zero weight and depth. }
    var i: integer;
    begin
      for i := 0 to NUMNODES
        do begin
             node[i].weight := 0;
             node[i].tdepth := 0;
             node[i].lchild := NoChild;
             node[i].rchild := NoChild;
           end;
    end;
{.cp8}
  procedure putwe(w: integer);
    { write out low order byte of word to file, then high order byte regardless of host CPU. }
    var b1, b2: char;
    begin
      b1 := chr(w and $FF);
      b2 := chr(w shr 8);
      write(OutFile,b1,b2);
    end;
{.cp8}
  function GetC_CRC: char;
    { Get next byte from file and update checksum }
    var c: char;
    begin
      if not(eof(InFile))
        then begin
               read(InFile,c);
               crc := crc + ord(c); { update checksum }
             end
        else EOFlag := true;
      GetC_CRC := c;  {undefined if EOFlag is true}
    end;
{.cp11}(*
  procedure PrintBits(len, number: integer);
    var i, j: integer;
    begin
      write('  code ');
      for i:=len-1 downto 0
        do begin
             j := (number shr i) and $0001;
             write(j:1);
           end;
      writeln;
    end; *)
{.pa}
  function getcnr: char;
    var return: char;

    function alike: boolean;
      begin
        newchar := getc_crc;
        if EOFlag
          then alike := false
          else begin
                 if (newchar = lastchar) and (likect < 255)
                   then alike := true
                   else alike := false;
               end;
      end;

    procedure NoHistory; {set up the state machine}
      begin
        state := SentChar;
        lastchar := GetC_CRC;
        if EOFlag then state := EndFile;
        return := lastchar;
      end;

    procedure SentAChar;   {Lastchar is set, need lookahead}

      procedure SentDLE;
        begin
          state := NoHist;
          return := chr(0);
        end;

      procedure CheckAlike;
        begin
          likect := 1;   while alike do likect := likect + 1;
          case likect of
            1: begin
                 lastchar := newchar;
                 return := lastchar;
               end;
            2: begin { just pass through }
                 state := SendNewC;
                 return := lastchar;
               end;
          else
            state := SendCnt;
            return := DLE;
          end;
        end;

      begin
        if EOFlag
          then state := EndFile {no return value, set to SPEOF in calling routine}
          else begin
                 if lastchar = DLE
                   then SentDLE
                   else CheckAlike;
               end;
      end;

    procedure SendNewChar;   {Previous sequence complete, newchar set}
      begin
        state := SentChar;
        lastchar := newchar;
        return := lastchar;
      end;

    procedure SendCount;  {Sent DLE for repeat sequence, send count}
      begin
        state := SendNewC;
        return := chr(likect);
      end;

    begin
      case state of
        NoHist:   NoHistory;
        SentChar: SentAChar;
        SendNewC: SendNewChar;
        SendCnt:  SendCount;
      else writeln('program bug - bad state');
      end;
      getcnr := return;
    end;
{.pa}
  procedure Write_Header;
  { Write out the header of the compressed file }

    var i, k, l, r, numnodes: integer;
        { numnodes: nbr of nodes in simplified tree }

    begin
      putwe(RECOGNIZE);   { identifies as compressed }
      putwe(crc);         { unsigned sum of original data }

      { Record the original file name w/o drive }
      if (InFileName[2] = ':')
        then InFileName := copy(InFileName,3,length(InFileName)-2);

      InFileName := InFileName + chr(0);  {mark end of file name}
      for i:=1 to length(InFileName) do write(OutFile,InFileName[i]);

      { Write out a simplified decoding tree. Only the interior nodes are written. When a child is a leaf index
        (representing a data value) it is recoded as -(index + 1) to distinguish it from interior indexes which
        are recoded as positive indexes in the new tree.  Note that this tree will be empty for an empty file. }

      if dctreehd < NUMVALS
        then numnodes := 0
        else numnodes := dctreehd - (NUMVALS - 1);
      putwe(numnodes);

      i := dctreehd;
      for k:=0 to numnodes-1
        do begin
             l := node[i].lchild;
             r := node[i].rchild;
             if l < NUMVALS
               then l := -(l + 1)
               else l := dctreehd - l;
             if r < NUMVALS
               then r := -(r + 1)
               else r := dctreehd - r;
             putwe(l);  { left child }
             putwe(r);  { right child }
             i := i - 1;
           end;
    end;
{.pa}
  procedure Adjust(top, bottom: integer; var list: ValType);
  { Make a heap from a heap with a new top }

    var k, temp: integer;

    function cmptrees(a, b: integer): boolean; {entry with root nodes}
    { Compare two trees, if a > b return true, else return false. }
      begin
        cmptrees := false;
        if node[a].weight > node[b].weight
          then cmptrees := true
          else if node[a].weight = node[b].weight
                 then if node[a].tdepth > node[b].tdepth
                        then cmptrees := true;
      end;

    begin
      k := 2 * top + 1;    { left child of top }
      temp := list[top];   { remember root node of top tree }
      if (k <= bottom)
        then begin
               if (k < bottom) and (cmptrees(list[k], list[k + 1])) then k := k + 1;
               { k indexes "smaller" child (in heap of trees) of top
                 now make top index "smaller" of old top and smallest child }
               if cmptrees(temp,list[k])
                 then begin
                        list[top] := list[k];
                        list[k] := temp;
                        adjust(k, bottom, list);
                      end;
             end;
    end;

{.pa}
{ The count of number of occurrances of each input value have already been prevented from exceeding MAXCOUNT.
  Now we must scale them so that their sum doesn't exceed ceiling and yet no non-zero count can become zero.
  This scaling prevents errors in the weights of the interior nodes of the Huffman tree and also ensures that
  the codes will fit in an unsigned integer.  Rescaling is used if necessary to limit the code length. }

  procedure Scale(ceil: integer);  { upper limit on total weight }

    var i, c, ovflw, divisor: integer;
        w, sum: real;
        increased: boolean;

    begin
      repeat
          sum := 0;   ovflw := 0;
          for i:=0 to numvals-1
            do begin
                 if node[i].weight > (ceil - sum) then ovflw := ovflw + 1;
                 sum := sum + node[i].weight;
               end;

          divisor := ovflw + 1;

          { Ensure no non-zero values are lost }
          increased := FALSE;
          for i:=0 to numvals-1
            do begin
                 w := node[i].weight;
                 if (w < divisor) and (w <> 0)
                   then begin
                          { Don't fail to provide a code if it's used at all }
                          node[i].weight := divisor;
                          increased := TRUE;
                        end;
               end;
        until not(increased);

      { Scaling factor choosen, now scale }
      if divisor > 1
        then for i:=0 to numvals-1
               do with node[i] do weight := int((weight / divisor) + 0.5);
    end;
{.pa}
  function buildenc(level, root: integer): integer; {returns error or null}

  { Recursive routine to walk the indicated subtree and level
    and maintain the current path code in bstree. When a leaf
    is found the entire code string and length are put into
    the encoding table entry for the leaf's data value.

    Returns ERROR if codes are too long. }

    var l, r, return: integer;

    begin
      return := null;
      l := node[root].lchild;
      r := node[root].rchild;

      if (l=NOCHILD) and (r=NOCHILD)
        then begin  {have a leaf}
               codelen[root] := level;
               code[root] := tcode and ($FFFF shr (16 - level));
               if level > 16
                 then return := ERROR
                 else return := NULL;
             end
        else begin
               if l <> NOCHILD
                 then begin  {Clear path bit and go deeper}
                        tcode := tcode and not(1 shl level);
                        if buildenc(level+1,l) = ERROR then return := ERROR;
                      end;
               if r <> NOCHILD
                 then begin  {Set path bit and go deeper}
                        tcode := tcode or (1 shl level);
                        if buildenc(level+1,r)=ERROR then return := ERROR;
                      end;
             end;
      buildenc := return;
    end;
{.pa}
  procedure Build_Tree(var list: ValType; len: integer); {Huffman algorithm}

    var freenode: integer;         {next free node in tree}
        lch, rch: integer;         {temporaries for left, right children}
        i: integer;

    function Maximum(a, b: integer): integer;
      begin
        if a>b then Maximum:=a else Maximum:=b;
      end;

    begin
      write(', Building tree');
      { Initialize index to next available (non-leaf) node.
        Lower numbered nodes correspond to leaves (data values). }
      freenode := NUMVALS;

      { Take from list two btrees with least weight and build an
        interior node pointing to them.  This forms a new tree. }
      while (len > 1)
        do begin
             lch := list[0]; { This one will be left child }

             { delete top (least) tree from the list of trees }
             len := len - 1;
             list[0] := list[len];
             adjust(0, len - 1, list);

             { Take new top (least) tree. Reuse list slot later }
             rch := list[0]; { This one will be right child }

             { Form new tree from the two least trees using a free node as root.
               Put the new tree in the list. }
             with node[freenode]
              do begin;
                   lchild := lch;
                   rchild := rch;
                   weight := node[lch].weight + node[rch].weight;
                   tdepth := 1 + Maximum(node[lch].tdepth, node[rch].tdepth);
                 end;
             list[0] := freenode;       {put at top for now}
             freenode := freenode + 1;  {next free node}
             { reheap list to get least tree at top }
             adjust(0, len - 1, list);
           end;
      dctreehd := list[0];   { head of final tree }
    end;
{.pa}
  procedure Initialize_Huffman;

  { Initialize the Huffman translation. This requires reading the input file through any preceding translation
    functions to get the frequency distribution of the various values. }

    var c, i: integer;
        btlist: ValType;   { list of intermediate binary trees }
        listlen: integer;  { length of btlist }
        ceiling: integer;  { limit for scaling }

{ Heap and Adjust maintain a list of binary trees as a heap with the top indexing the binary tree on the list which
  has the least weight or, in case of equal weights, least depth in its longest path. The depth part is not strictly
  necessary, but tends to avoid long codes which might provoke rescaling. }

    procedure Heap(var list: ValType; l: integer);
      var i, len: integer;
      begin
        len := (l - 2) div 2;
        for i:=len downto 0 do adjust(i, l - 1, list);
      end;
(*
    procedure PrintFrequency;
      var i, j: integer;
      begin
        j := 0;
        for i:=0 to numvals-1
          do if node[i].weight>0
               then begin
                      j := j + 1;
                      writeln(lst,'node ',i:3,'  weight is ',node[i].weight:4:0);
                    end;
        writeln(lst);
        writeln(lst,'Total node count is ',j);
      end;

    procedure PrintList;
      var i: integer;
          str: string[10];
      begin
        writeln(', waiting');   readln(str);
        for i:=0 to numvals-1
          do begin
               write('number ',i:3,'  length ',codelen[i]:2);
               write('  weight ',node[i].weight:4:0);
               if codelen[i]>0 then PrintBits(codelen[i], code[i]) else writeln;
             end;
      end;
  *)
  begin
      write('Pass 1: Analysis');
      crc := 0;   zero_tree;   state := NoHist;   EOFlag := false;

      repeat    { Build frequency info in tree }
          c := ord(getcnr);
          if EOFlag then c := SPEOF;
          with node[c] do if weight < maxcount then weight := weight + 1;
          if EOFlag then write(', End of file found');
        until (EOFlag);
      {PrintFrequency;}

      ceiling := MAXCOUNT;

      { Try to build encoding table. Fail if any code is > 16 bits long. }
      repeat
          if (ceiling <> MAXCOUNT) then write('*** rescaling ***, ');
          scale(ceiling);
          ceiling := ceiling div 2;  {in case we rescale again}

          listlen := 0;   {find length of list and build single nodes}
          for i:=0 to numvals-1
            do begin
                 if node[i].weight > 0
                   then begin
                          node[i].tdepth := 0;
                          btlist[listlen] := i;
                          listlen := listlen + 1;
                        end;
               end;
          heap(btlist, listlen-1);  { *** changed from listlen }
          Build_Tree(btlist, listlen);
          for i := 0 to NUMVALS-1 do codelen[i] := 0;
        until (buildenc(0,dctreehd) <> ERROR);

      {PrintList;}
      { Initialize encoding variables }
      cbitsrem := 0;   curin := 0;
    end;
{.pa}
  function gethuff: char; {returns byte values except for EOF}
  { Get an encoded byte or EOF. Reads from specified stream AS NEEDED.

    There are two unsynchronized bit-byte relationships here:
      The input stream bytes are converted to bit strings of various lengths via
      the static variables named Cxxxxx.  These bit strings are concatenated without
      padding to become the stream of encoded result bytes, which this function
      returns one at a time. The EOF (end of file) is converted to SPEOF for
      convenience and encoded like any other input value. True EOF is returned after
      that. }

    var rbyte: integer;       {Result byte value}
        need, take: integer;  {numbers of bits}
        return: integer;

    begin
      rbyte := 0;
      need := 8;        {build one byte per call}
      return := ERROR;  {start off with an error}

      {Loop to build a byte of encoded data.  Initialization forces read the first time}
      while return=ERROR
        do begin
             if cbitsrem >= need
               then begin {Current code fullfills our needs}
                      if need = 0
                        then return := rbyte and $00FF
                        else begin
                               rbyte := rbyte or (ccode shl (8 - need)); {take what we need}
                               ccode := ccode shr need;                  {and leave the rest}
                               cbitsrem := cbitsrem - need;
                               return := rbyte and $00FF;
                             end;
                    end
               else begin
                      if cbitsrem > 0
                        then begin  {We need more than current code}
                               rbyte := rbyte or (ccode shl (8 - need)); {take what there is}
                               need := need - cbitsrem;
                             end;
                      if curin = SPEOF
                        then begin
                               cbitsrem := 0;
                               if need=8
                                 then begin                       {end of file}
                                        done := true;
                                        return := 0; {any valid char value}
                                      end
                                 else return := rbyte and $00FF;  {data first}
                             end
                        else begin
                               curin := ord(getcnr);
                               if EOFlag then curin := SPEOF;
                               ccode := code[curin];
                               cbitsrem := codelen[curin];
                             end;
                    end;
           end;
      gethuff := chr(return);
    end;
{.pa}
  procedure squeeze;
    var c: char;
    begin
      writeln;   write('Pass 2: Squeezing');
      reset(InFile);   rewrite(OutFile);   EOFlag := false;
      write(', header');   Write_Header;
      write(', body');     state := NoHist;
      done := false;   c := gethuff;  {prime while loop}
      while not(done)
        do begin
             write(OutFile,c);
             c := gethuff;
           end;
    end;


begin { Main }

  clrscr;   gotoxy(1,5);
  writeln('File squeezer version ',version);
  writeln;

  { get filename to process & convert to upper case}
  write('Enter file to squeeze: ');   readln(InFileName);   writeln;
  for i:=1 to length(InFileName) do InFileName[i] := upcase(InFileName[i]);

  { Find and change output file type }
  start := 1; { skip leading blanks }
  while (InFileName[start]=space) and (start <= length(InFileName)) do start := start + 1;
  InFileName := copy(InFileName, start, length(InFileName)-start+1);
  finish := pos('.',InFileName);
  if finish=0
    then OutFileName := InFileName + '.QQQ'
    else begin
           OutFileName := InFileName;
           OutFileName[finish+2] := 'Q';
         end;

  { open source file and check for existence }
  assign(InFile,InFileName);   assign(OutFile,OutFileName);
  {$I-}   reset(InFile);   {$I+}
  if IOresult=0
    then begin
           write('The file ',InFileName,' (',longfilesize(InFile):6:0);
           writeln(' bytes) is being squeezed to ',OutFilename);
           Initialize_Huffman;
           squeeze;
           writeln(', Done.');   close(InFile);   close(OutFile);
         end
    else writeln('Error -- input file doesn''t exist');

end.
