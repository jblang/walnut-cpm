procedure Sort_Data( var Ixs; N_elements, CompareRoutine : integer);
(*                           Z80 Version
                        S  Y  N  O  P  S  I  S

  This is a general purpose sorting routine that uses the quicksort
  method and allows the user to sort one or several types of data in
  the same program.  This single copy of Sort_Data suffices
  for any number of data types to be sorted.  This is accomplished
  by having the user "Pass a procedure" to Sort_Data that will do
  the comparisons for a particular type of data.   Sort_Data is
  the only procedure in this package that is visible to the outer
  block.  This file is ready to be included in a main program.


                        M  E  T  H  O  D  S

  Three procedures within Sort_Data are used:
        1. QSORT - The quicksort algorithm.
        2. BSORT - Bubblesort algorithm.
        3. LessThan_Lnk - Linkup function to the caller's actual
           comparison routine.

  The quicksort algorithm recursively splits the list of elements
  until the list is less than eight elements long, then the bubblesort
  algorithm takes over.  The caller's data comparison routine, which
  is supplied in the call to Sort_Data, is called every time two
  elements are to be compared.  Sort_Data does not ever see the
  actual data that is being sorted.  It merely moves indices
  based on the result of the caller-supplied comparison routine.
  Since the comparison routine is not hard coded into the sorting
  algorithm, Sort_Data can be used several times in the same program
  to sort different types of data.  The only thing that changes is
  the comparison routine that is passed to Sort_Data.

  This code was written for greatest efficiency, thus more goto's
  than usual are in the quicksort routine. The following benchmarks
  were observed on a Z80 running at 4.0 MHz:
                Data type        Number of Elements        Time
                   Integer              1000                4.7 sec
                   Real                 1000                5.8 sec
                   15 char string       1000                7.8 sec


                        U  S  A  G  E
  Ixs:
    Ixs is an  array of indices (integers) that point to the
    respective data elements to be sorted.  During the sorting
    process, the elements in Ixs will be moved around instead
    of the actual data elements.  On return from Sort_Data, the
    elements in Ixs will be in sorted order.  For example, if
    you were going to sort a randomly generated  array of real
    numbers, your program might look like:

        Type IntArray = array [1..1] of integer;
        Var DataToSort : array [1..1000] of Real;
            NumberToSort : Integer;
            Indices : ^IntArray;
            i,j,k : integer;
        Function RealLessThan( index1, index2 : integer ) : boolean;
        begin
          RealLessThan:= DataToSort[Index1] < DataToSort[Index2];
        end;
      begin
        { NumberToSort is the number of valid elements in DataToSort
          to sort.                                                   }
        write('How many: ');  Readln(NumberToSort);
        GetMem(Indices, NumberToSort shl 1);  { Number of bytes }
        for i:=1 to NumberToSort do Indices^[i]:=i;
        for i:=1 to NumberToSort do DataToSort[i]:=Random * 1000.0;
        writeln('Starting Sort...');
        Sort_Data(Indices^, NumberToSort, addr(RealLessThan));
        writeln('Sort done...');
        { Now the elements in Indices are in order.  E.G. to write out
          the sorted real numbers, you could say:                       }
        For i:=1 to NumberToSort do writeln(DataToSort[Indices^[i]]);
        Freemem(Indices, NumberToSort shl 1);
      end.


    By having the caller specify an input array of indices, only chosen
    elements of a large or sparse array may be sorted without having to
    move elements into an "input array".  This can be especially time
    saving when sorting arrays of records, or even files on disk.

  N_elements:
    The number of elements in Ixs.
  CompareRoutine:
    The caller must supply the address  to the his own function
    that will compare two elements in the array.  The function must be
    boolean and it must have its input arguments specified as in the
    following example:
    For example:
      function lessthan( index1, index2 : integer ) : boolean;
        begin
          lessthan:= myarray[index1] < myarray[index2];
        end;
    Returning the result of a "lessthan" comparison between index1 and
    index2, as shown above, results in an ascending ordered list.
    You can reverse the direction of the sort by switching the order of
    of comparison.  Also, if this function  is in an overlay file, it MUST
    BE PRESENT in memory before Sort_Data is called.

   In order to minimize sorting time, the quicksort routine does not
   recursively call itself.  Instead it uses a statically allocated
   "stack" for holding pointers to the successively halved lists.  The
   stack size is modified within this procedure by changing the
   constant StackSize.  The necessary value of StackSize depends on the
   number of elements you are sorting.   With random data, if N is
   the number of data elements being sorted, then the average size
   to which the stack will grow is LOG2(N).  For example, 1000 elements
   will (on the average) take a StackSize of LOG2(1024) = 10.  A
   safe value of StackSize to use is 2 * LOG2(N).
                                                                  *)

    { Local Data for Sort_Data }
    const stacksize = 20;
    var indices : array [1..1] of integer absolute ixs;

    {--------------------  LESSTHAN_LNK FUNCTION ----------------------------}
    function LessThan_Lnk( i,j : integer) : boolean;
    begin
    { Z80 inline code: }
    inline(
      $C1/          { pop bc  ;Get return address }
      $2A/i/        { ld  hl,i }
      $E5/          { push hl  }
      $2A/j/        { ld  hl,j }
      $E5/          { push hl  }
      $C5/          { push bc  ;Restore return address }
      $2A/CompareRoutine/   { ld  hl,CompareRoutine }
      $E9           { jp  (hl) ;Jump to compare routine }
          );
    end;
    {--------------------  BUBBLESORT ROUTINE ----------------------------}
      procedure bsort( start, stop : integer);
      var
          n, i,  k, t, k1 : integer;
          swapped : boolean;
          label gone;
      begin
        n:=stop - start;
        if n < 1 then goto gone;
        for i:=1 to n do
          begin
            swapped:=false;
            for k:=start to stop-i do
              begin
                t:=indices[k];
                k1:=k+1;
                if LessThan_Lnk(indices[K1], t) then
                  begin
                    indices[k]:=indices[K1];  indices[k1]:=t;
                    swapped:=true;
                  end;
              end;
            if not swapped then goto gone;
          end;
    gone:
      end;
    {--------------------  QUICKSORT ROUTINE ----------------------------}
        procedure qsort(  ilsave, irsave : integer);
            var ixmid, ilx, irx, tmpndx, tmp2 : integer;
                left, right : array [1..stacksize] of integer;
            label recurse, recurse2, split, bscan, fscan, swapem, gone;
            const stackindex : integer = 0;
        begin
        split:
                if (irsave - ilsave) < 8 then
                  begin
                    bsort(ilsave, irsave);
                    if stackindex = 0 then goto gone;
                    ilsave:=left[stackindex];
                    irsave:=right[stackindex];
                    stackindex:=stackindex-1;
                    goto split;
                  end;
                ixmid:=(ilsave + irsave) shr 1;
                tmpndx:=indices[ixmid];
                indices[ixmid]:=indices[ilsave];
                ilx:=ilsave+1;  irx:=irsave;
        fscan:
                if LessThan_Lnk(tmpndx, indices[ilx]) then goto bscan;
                ilx:=ilx+1;
                if ilx <= irx then goto fscan;
        recurse:
                ilx:=ilx-1;
        recurse2:
                indices[ilsave]:=indices[ilx];
                indices[ilx]:=tmpndx;
                stackindex:=stackindex + 1;
                left[stackindex]:=irx;  right[stackindex]:=irsave;
                irsave:=ilx - 1;
                goto split;

        bscan:
                if LessThan_Lnk( indices[irx],tmpndx) then goto swapem;
                irx:=irx-1;
                if (irx > ilx) then goto bscan;
                goto recurse;

        swapem:
                tmp2:=indices[ilx]; indices[ilx]:=indices[irx];
                    indices[irx]:=tmp2;
                if (irx > ilx + 1) then goto fscan;
                  goto recurse2;

        gone:   end;
    {---------------------------- SORT_DATA ------------------------}
begin  { Sort_Data }
    qsort(1,N_elements);        { Begin sorting }
end;

