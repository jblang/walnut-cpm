      program simdif
      implicit integer (a-z)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     SIMDIF -- compare two SIMTEL20 index files and list differences.
c
c
c        Author:
c
c           Gregory D. Flint, Purdue University Computing Center, 1990.
c
c
c        Warranty notice:
c
c           Purdue University Computing Center (PUCC) warrants only
c           that PUCC testing has been applied to this code.  No other
c           warranty, expressed or implied, is applicable.
c
c
c        Description:
c
c           The program reads two input files as follows:
c
c              old - previous simtel20 index file,
c              new - current simtel20 index file.
c
c           It compares the two files and generates five report files as
c           follows:
c
c              add - a list of files whose entries were added to the new
c                    index,
c              chg - a list of files whose entries were changed in the
c                    new index (version, size, date, desc, etc.),
c              del - a list of files whose entries were deleted from the
c                    new index,
c              ftp - the contents of the add & chg files formatted for
c                    use by the autoftp program (available from
c                    SIMTEL20), and
c              lst - statistics about the run.
c
c
c         Notes:
c
c            Should the format of the index file change, the parameter
c            statements that appear in each routine will need to be
c            changed.
c
c            Do not try to compare index files across a format change
c            after changing the parameter statements as the old file
c            will fail to parse properly.
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
 


c-----------------------------------------------------------------------
c     parameters:     
c
c        flds = number of fields (+1) in the index files.
c
c        ldrv, ldir, ... = length of a field (+1 if data near max size)
c        pdrv, pdir, ... = position of an output field
c
c        linp = length of an input line (including quote marks)
c
c        add, chg, ... = unit numbers for the seven input/output files
c-----------------------------------------------------------------------
 
      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      parameter ( add =  3 )
      parameter ( chg =  4 )
      parameter ( del =  7 )
      parameter ( ftp =  8 )
      parameter ( lst =  9 )
      parameter ( new = 10 )
      parameter ( old = 11 )


c-----------------------------------------------------------------------
c     /chars/ -- character variable common block
c
c        ascii  = symbol in the index indicating an ascii file
c        inline = input line (from old or new file)
c        outnew = parsed input line from new file
c        outold = parsed output line from old file
c-----------------------------------------------------------------------

      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold


c-----------------------------------------------------------------------
c     /intgrs/ -- integer variable common block
c
c        added  = number of entries added to the new file
c        chged  = number of entries changed in the new file
c        deled  = number of entries deleted from the new file
c        haderr = if non-zero, indicates the file with a parse error
c        nlines = number of entries read from the new file
c        olines = number of entries read from the old file
c-----------------------------------------------------------------------

      common / intgrs / added, chged, deled, haderr, nlines, olines


c-----------------------------------------------------------------------
c     /fields/ -- field related data
c
c        flen() = array containing the length of each field
c        fpos() = array containing the starting position of each field
c        fptr   = integer pointer to field being processed
c        fquo() = logical array indicating whether or not the field is
c                 bracketed by quote marks
c-----------------------------------------------------------------------

      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo


c-----------------------------------------------------------------------
c     /eoflag/ -- end of file detected flags
c
c       ndone = true if eof detected on old file
c       odone = true if eof detected on new file
c-----------------------------------------------------------------------

      common / eoflag / ndone, odone
      logical ndone, odone


c
c     open the files and prime the pumps.
c

      open (old, file="simold")
      open (new, file="simnew")
      open (del, file="simdel")
      open (add, file="simadd")
      open (chg, file="simchg")
      open (lst, file="simlst")
      open (ftp, file="simftp")
c
      read (old, 10, end=50) inline
   10 format (a)
      olines = olines + 1
      call split (old)
      if (haderr .ne. 0) go to 90
      read (new, 10, end=70) inline
      nlines = nlines + 1
      call split (new)
      if (haderr .ne. 0) go to 110

c
c     main loop
c

   20 if (outold(pdrv:pver-1) .lt. outnew(pdrv:pver-1)) then
         call dels
      else if (outold(pdrv:pver-1) .gt. outnew(pdrv:pver-1)) then
         call adds
      else 
         call chgs
      endif
      if (haderr .eq. old) go to 90
      if (haderr .eq. new) go to 110
      if (.not.(odone.and.ndone)) go to 20
c
      write (lst, 30) olines, nlines
   30 format (1x,i6," lines read from old file."/
     *        1x,i6," lines read from new file.")
      write (lst, 40) added, chged, deled
   40 format (/1x,i6," files added."/
     *         1x,i6," files changed."/
     *         1x,i6," files deleted.")
c
      stop "simdif -- normal termination"
 
c
c     error processing
c
c
   50 write (lst, 60)
   60 format (1x,"Empty ""old"" file."/)
      go to 130
c
   70 write (lst, 80)
   80 format (1x,"Empty ""new"" file."/)
      go to 130
c
   90 write (lst, 100) fptr
  100 format (1x,"Parse of ""old"" file failed at field",i2/)
      go to 130
c
  110 write (lst, 120) fptr
  120 format (1x,"Parse of ""new"" file failed at field",i2/)
c     go to 130
c
  130 write (lst, 30) olines, nlines
      stop "simdif -- errors detected."
c
      end
      subroutine adds
      implicit integer (a-z)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     adds -- process entries added to the new index file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      parameter ( add =  3 )
      parameter ( chg =  4 )
      parameter ( del =  7 )
      parameter ( ftp =  8 )
      parameter ( lst =  9 )
      parameter ( new = 10 )
      parameter ( old = 11 )
c
      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold
c
      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo
c
      common / intgrs / added, chged, deled, haderr, nlines, olines
c
      common / eoflag / ndone, odone
      logical ndone, odone


c-----------------------------------------------------------------------
c
c     1) list the addition.
c     2) add it to the autoftp file.
c     3) increment the count.
c     4) get and split another line from the new file.
c     5) if end of file, set parsed new line to all [upper case] Z's.
c
c-----------------------------------------------------------------------

      write (add, 10) (outnew(fpos(i):fpos(i)+flen(i)-1),i=1,flds-1)
   10 format (1x,3("""",a,""","),4(a,","),"""",a,"""")
c
      write (ftp, 20) outnew(pdrv:pdrv+ldrv-1), outnew(pdir:pdir+ldir-1)
   20 format ("-d ",2a)
      if (outnew(ptyp:ptyp) .eq. ascii) then
         write (ftp, 30) outnew(pnam:pnam+lnam-1)
   30    format ("-a ",a)
      else
         write (ftp, 40) outnew(pnam:pnam+lnam-1)
   40    format ("-8 ",a)
      endif
c
      added = added + 1
c
      read (new, 50, end=60) inline
   50 format (a)
      nlines = nlines + 1
      call split (new)
      return
c
   60 ndone = .true.
      do 70 i = 1, pend
         outnew(i:i) = "Z"
   70 continue
      return
c
      end
      subroutine blckda
      implicit integer (a-z)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     blckda -- preset labeled common block data
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold
c
      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo
c
      common / intgrs / added, chged, deled, haderr, nlines, olines
c
      common / eoflag / ndone, odone
      logical ndone, odone


c-----------------------------------------------------------------------
c     note that not all fields in each block are preset
c-----------------------------------------------------------------------

      data ascii / "7" /
c
      data flen / ldrv, ldir, lnam, lver, lsiz, ltyp, ldat, ldes, lend /
      data fpos / pdrv, pdir, pnam, pver, psiz, ptyp, pdat, pdes, pend /
      data fquo / 3*.true., 4*.false., .true., .false. /
c
      data added, chged, deled, haderr, nlines, olines / 6*0 /
c
      data ndone, odone / .false., .false. /
c
      end
      subroutine chgs
      implicit integer (a-z)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     chgs -- process entries that changed from the old to the new file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      parameter ( add =  3 )
      parameter ( chg =  4 )
      parameter ( del =  7 )
      parameter ( ftp =  8 )
      parameter ( lst =  9 )
      parameter ( new = 10 )
      parameter ( old = 11 )
c
      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold
c
      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo
c
      common / intgrs / added, chged, deled, haderr, nlines, olines
c
      common / eoflag / ndone, odone
      logical ndone, odone


c-----------------------------------------------------------------------
c
c     1) if there is no change, skip to 5) below
c     2) list the change.
c     3) add it to the autoftp file.
c     4) increment the count.
c     5) get and split another line from both files.
c     6) if end of file, set parsed new/old line to all Z's.
c
c-----------------------------------------------------------------------

      if (outold .eq. outnew) go to 50
c
      write (chg, 10) olines, nlines,
     *   (outold(fpos(i):fpos(i)+flen(i)-1),i=1,flds-1),
     *   (outnew(fpos(i):fpos(i)+flen(i)-1),i=1,flds-1)
   10 format (1x,"old: ",i6,"   new: ",i6/
     *        1x,"< ",3("""",a,""","),4(a,","),"""",a,""""/
     *        1x,"> ",3("""",a,""","),4(a,","),"""",a,""""/
     *        1x,25("-"))
c
c
      write (ftp, 20) outnew(pdrv:pdrv+ldrv-1), outnew(pdir:pdir+ldir-1)
   20 format ("-d ",2a)
      if (outnew(ptyp:ptyp) .eq. ascii) then
         write (ftp, 30) outnew(pnam:pnam+lnam-1)
   30    format ("-a ",a)
      else
         write (ftp, 40) outnew(pnam:pnam+lnam-1)
   40    format ("-8 ",a)
      endif
      chged = chged + 1
c
   50 read (new, 60, end=70) inline
   60 format (a)
      nlines = nlines + 1
      call split (new)
      if (haderr .ne. 0) return
      go to 90
c
   70 ndone = .true.
      do 80 i = 1, pend
         outnew(i:i) = "Z"
   80 continue
c
   90 read (old, 60, end=100) inline
      olines = olines + 1
      call split (old)
      return
c
  100 odone = .true.
      do 110 i = 1, pend
         outold(i:i) = "Z"
  110 continue
      return
c
      end
      subroutine dels
      implicit integer (a-z)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     dels -- process entries deleted from the new index file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      parameter ( add =  3 )
      parameter ( chg =  4 )
      parameter ( del =  7 )
      parameter ( ftp =  8 )
      parameter ( lst =  9 )
      parameter ( new = 10 )
      parameter ( old = 11 )
c
      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold
c
      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo
c
      common / intgrs / added, chged, deled, haderr, nlines, olines
c
      common / eoflag / ndone, odone
      logical ndone, odone


c-----------------------------------------------------------------------
c
c     1) list the deletion.
c     2) increment the count.
c     3) get and split another line from the old file.
c     4) if end of file, set parsed old line to all [upper case] Z's.
c
c-----------------------------------------------------------------------

      write (del, 10) (outold(fpos(i):fpos(i)+flen(i)-1),i=1,flds-1)
   10 format (1x,3("""",a,""","),4(a,","),"""",a,"""")
c
      deled = deled + 1
c
      read (old, 20, end=30) inline
   20 format (a)
      olines = olines + 1
      call split (old)
      return
c
   30 odone = .true.
      do 40 i = 1, pend
         outold(i:i) = "Z"
   40 continue
      return
c
      end
      subroutine split (newold)
      implicit integer (a-z)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     split -- parse the input line and set the new/old output line
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      parameter ( flds = 9)
c
      parameter ( ldrv =  4    ,  pdrv =           1 )
      parameter ( ldir = 20    ,  pdir = pdrv + ldrv )
      parameter ( lnam = 12    ,  pnam = pdir + ldir )
      parameter ( lver =  2 + 1,  pver = pnam + lnam )
      parameter ( lsiz =  6 + 1,  psiz = pver + lver )
      parameter ( ltyp =  1    ,  ptyp = psiz + lsiz )
      parameter ( ldat =  6    ,  pdat = ptyp + ltyp )
      parameter ( ldes = 46    ,  pdes = pdat + ldat )
      parameter ( lend =  0    ,  pend = pdes + ldes )
c
      parameter ( linp = 1+ldrv+1 + 1+ldir+1 + 1+lnam+1 +
     *                     lver   +   lsiz   +   ltyp   +
     *                     ldat   + 1+ldes+1 +   flds   )
c
      parameter ( add =  3 )
      parameter ( chg =  4 )
      parameter ( del =  7 )
      parameter ( ftp =  8 )
      parameter ( lst =  9 )
      parameter ( new = 10 )
      parameter ( old = 11 )
c
      common / chars / ascii, inline, outnew, outold
      character*1      ascii
      character*(linp) inline
      character*(pend) outnew, outold
c
      common / fields / flen(flds), fpos(flds), fptr, fquo(flds)
      logical fquo
c
      common / intgrs / added, chged, deled, haderr, nlines, olines
c
      character*(pend) splits, temp


c-----------------------------------------------------------------------
c
c     1) preset the input pointer and result string
c     2) loop for each field
c        a) build a temporary string from it
c        b) right justify the field if it is not quote-mark-bracketed
c        c) move the temporary string into the result string
c     3) move the result string into the appropriate output string
c
c-----------------------------------------------------------------------

      inptr = 1
      splits = " "
c
      do 20 fptr = 1, flds-1
         if (fquo(fptr)) inptr = inptr + 1
         temptr = 1
   10    if ((fquo(fptr).and.inline(inptr:inptr).ne."""") .or.
     *       (.not.fquo(fptr).and.inline(inptr:inptr).ne.",")) then
            if (temptr .gt. flen(fptr)) then
               haderr = newold
               return
            endif
            temp(temptr:temptr) = inline(inptr:inptr)
            temptr = temptr + 1
            inptr = inptr + 1
            go to 10
         endif
         if (fquo(fptr)) then
            inptr = inptr + 2
            splits(fpos(fptr):fpos(fptr)+temptr-1-1) = temp(1:temptr-1)
         else
            inptr = inptr + 1
            splits(fpos(fptr+1)-temptr+1:fpos(fptr+1)-1) = 
     *         temp(1:temptr-1)
         endif
   20 continue
c
      if (newold .eq. old) then
         outold = splits
      else
         outnew = splits
      endif
      return
c
      end
