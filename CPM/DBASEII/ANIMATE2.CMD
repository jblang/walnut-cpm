* animate2.cmd

IF F

Bill Weinman, 10 May 1983

In answer to Michael Cohn's Animate.cmd

It would appear that the problem you were running into was 
dBASE's steadfast refusal to evaluate an expression as an 
argument to @ SAY.  Really you can only have a variable or a 
literal as an argument to @ SAY.

The routine that I am presenting here has only been tested under 
dBASE II version 2.4 (yet to be released by Ashton-Tate).

Copyright (c) 1983, by:  Bill Weinman, PO Box 60807, Los Angeles, 
CA  90060 pursuant to the following paragraph:

Reserving the right to sell these routines myself in any form 
that I wish, I hereby donate this file in it's origional form as 
of 10 May 1983 to the public domain.  You may do with it as you 
wish.

TIP:  Try turning of the terminal's cursor! ( ?? chr(27)+'.0' for 
the Televideo 950 and ?? chr(27)+'.2' to turn it back on ).

				10 May 1983

				Bill E. Weinman
				Business Computer Services
				P O Box 60807
				Los Angeles, CA 90060

ENDIF F

*****************************************************************
* initialization section
set talk off
set colon off

erase

store '                    ' to string
store 0 to col
store 0 to colfin
store 0 to row

@ 10,10 say 'Enter the string to be animated: ' get string
@ 11,10 say '   Enter the column to start in: ' get col pict '##'
@ 12,10 say '  Enter the column to finish in: ' get colfin pict '##'
@ 13,10 say '   Enter the line to animate on: ' get row pict '##'
read
clear gets

erase

store col+1 to initcol
store trim(string) to string
store len(string) to length

* the "if not firsttime" within the "do while not done" loop 
* is to force dbase to read the entire routine into memory 
* before executing it.  this eliminates any disk bound delays 
* in the middle of animation.
store t to firsttime
store f to done
do while .not. done
	if .not. firsttime
		* the animation starts here
		do while (initcol-col) # length
			* first, evaluate the sub-string
			store $(string,1,initcol-col) to partial
			@ row,col say partial
			store col-1 to col
		enddo
	
		do while col > colfin
			@ row,col say string+' '
			store col-1 to col
		enddo

		* a little flash

		store col+1 to col
		store 0 to wait
		* low is a logical switch used to control the 
		* alternation of the flash (only for terminals
		* that support rev video or dual intensity)
		store t to low
		do while wait < 10
			if .not. low
				set inte off
				@ row,col say string
				store t to low
			else
				set inte on
				@ row,col say string
				store f to low
			endif
			store wait+1 to wait
		enddo

	store t to done
	endif firsttime
store f to firsttime
enddo

* rele firsttime, done, row, col, wait, string, partial, length, low
set inte on

return
