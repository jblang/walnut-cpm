Here is a set of patches I've made to the CP/M Aztec Vers. 1.06D
C library which I consider to be bug fixes.  They have been tested
to my satisfaction; I use them myself.  Of course, if you apply
these "changes" to some other version of an Aztec C library,
you're on your own.  The code fragments shown are bracketed vertically
by ********'s.  Lines which were deleted begin with '-' and lines
which were modified or added begin with '+'.
		Howard Johnson, 11 Dec '85

This modification of FSUBS.ASM fixes an obscure bug which is manifest
on overflow when converting a floating point number to a long integer.

********	FSUBS.ASM, starting near line 1261
  ltoobig:
  	xchg
  	mov	a,c
  	ora	a
  	jm	bigneg
+ 	mvi	m,0ffH		; was 07fH
  	inx	h
  	mvi	m,0ffH
  	inx	h
  	mvi	m,0ffH
  	inx	h
+ 	mvi	m,07fH		; was 0ffH
  	jmp	oflow
  bigneg:
+ 	mvi	m,0		; was 080H
  	inx	h
  	mvi	m,0
  	inx	h
  	mvi	m,0
  	inx	h
+ 	mvi	m,080H		; was 0
  	jmp	oflow
********

This modification of FTOA.ASM was made so floating point numbers
get printed the same way they would be printed under UNIX.
N.B.:  These changes are rather subtle.

********	FTOA.ASM, starting near line 168
  	jm	chkm4
  	mov	a,c
  	cmp	l
+ 	mvi	a,2		;%g -> %e
+ 	jnc	setformat
+ 	mvi	a,3		;exp < maxdig, so use %g -> %f
  	jmp	setformat
  ;
  chkm4:
********	FTOA.ASM, starting near line 215
  	call	.utod		;and repair if necessary
  	inx	b
  	lda	fflag
+ 	ani	1		; was ora a
  	jz	rndok
  	lhld	ndig
  	inx	h
  	shld	ndig
  rndok:
  	mov	h,b
  	mov	l,c
  	shld	exp
  	lda	fflag
+ 	ani	1		; was ora a
  	jz	unpack
  	mov	a,b
  	ora	a
********	FTOA.ASM, starting near line 312
  ;
  unpdone:
  	lda	fflag
+ 	ani	2		; originally %g ?
+ 	jz	nochop
+ 	mvi	a,'0'
+ 	lhld	chrptr
+ chopdig:
+ 	dcx	h
+ 	cmp	m
+ 	jz	chopdig
+ 	mvi	a,'.'
+ 	cmp	m
+ 	jz	chopdun
+ 	inx	h
+ chopdun:
+ 	shld	chrptr
+ nochop:
+ 	lda	fflag
+ 	ani	1		;%f or %g -> %f ?
  	jnz	alldone
  ;
  	lhld	chrptr
********

This modification to SCAN.C changes the %[ conversion of scanf() to work
the way it does under UNIX.  It no longer skips over blank characters
before reading characters from the specified set.
N.B.:  The skip-over-blanks peculiarity is documented in Aztec scanf()
manuals.  Changing "%[a-z]" to " %[a-z]" will fix existing Aztec C programs
broken by this modification.

********	SCAN.C, starting near line 113
  				for (cp = tlist ; (c = *fmt++) != ']' ; )
  					*cp++ = c;
  				*cp = 0;
+ 				goto charstring; /* instead of goto string */
  			case 's':
  				lflag = 1;
  				tlist[0] = ' ';
********

This modification to IOCTL.C initializes the internal tty structure to
values a program calling ioctl(fd, TIOCGETP, &tty) might expect to see.

********	IOCTL.C, starting near line 9
  extern int (*Rd_tab[])();
  extern int (*Wrt_tab[])();
  
+ struct sgttyb Tty_ctl = { '\b', '\030', CRMOD|ECHO };
  extern char _Eol;
  extern int tty_rd();
  static int raw_rd(), raw_wr();
********
