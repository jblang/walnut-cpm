

/* A few non-redundant functions from Harvey G. Lord's C80LIB.C, for
   the Software Toolworks C/80 Version 3.1 C compiler, including:

   char	bios(call_number,register_c_value)
   char peek(addr)
	poke(addr,char_value)
   char inp(port_number)
	outp(port_number,char_value)
	pause()                         -- wait for keyboard activity
	sleep(tenths_of_second_value)   -- interruptible by kbhit, 4 mHz(?)
	kbhit()                         -- true iff keypress


   H.G.L's original header refers to C/80 Version 2.  Note that C/80 v3.1,
   the Software Toolworks current version (8-25-84), contains a very nice
   standard library with functions which make nearly all of the HGL library
   obsolete, at this point.  The full C80.LBR for the Toolworks' version 2
   is still available on the Royal Oak Technical RCPM (where it is a
   "squeezed" LBR!), and maybe on the Acropolis board in Georgia.  HGL's
   library is the major part of that LBR, which also contains the originals
   of RANDI1.C and RANDI2.C, plus a nearly incomprehensible (undocumented,
   non-recursive, inaccurately described as the program in K&P's Software
   Tools) version of quicksort.  The time required to download the squeezed
   LBR at Royal Oak makes the final package disappointing; it is not worth
   the expense, now that Toolworks is shipping version 3.1.

   These functions are passed on in exactly the same form as I found them.  No
   warranty expressed or implied, except that they have survived the scrutiny
   of numerous sysops since at least April of 1983.
					--David C. Oshel
					  1219 Harding Ave.
					  Ames, Iowa 50010
					  August 25, 1984

   Original header:

	   Standard library of C functions       
	    for C/80 (Software Toolworks)        (... Bilofsky's is STDLIB.C)



	NOTE:  C/80 requires that you pass the
	number of arguments to a function that
	the function expects. If you only need
	to pass one argument, but the function
	was  written for two,  pass a null for
	the other. Without the second argument
	C/80 bombs.                               (... still true! -dco)
				Harvey G. Lord  
*/

/* abbreviated library follows -dco, 8/25/84 */

char bios(n,c) /* calls bios function number n */
int n,c;
{
	/* get bios address + function # times 3 */
#asm
	JMP .begin
.addr:	DW 0

.begin:	POP H	; save return address
	SHLD .addr

	POP B	; 1st arg into c
	POP D	; get function #
	LXI H,.retadd
	PUSH H	; put return addr on stack

	LHLD 1	; get bios vector
	DCX H
	DCX H
	DCX H
	DAD D	; times 3, add to vector
	DAD D
	DAD D
	PCHL	; jump to bios vector

.retadd: LHLD .addr ; restore stack
	PUSH B
	PUSH B
	PUSH H
	MOV L,A	; return argument in hl
	MVI H,0
#endasm
}

char peek(n) /* return the contents of address n */
	char *n; {
	return(*n);
}

poke(n,b) /* "poke" byte value b into address n */
	char *n,b; {
	*n = b;
}

char inp(n) /* return byte value from port n */
int n; {
#asm
	INX SP ; past return address
	INX SP
	POP H  ; port number
	MOV H,L
	MVI L,0DBH ; input op code
	SHLD .port

.port:	DW 0   ; opcode & port go here, then .port is executed (dco)

	MVI H,0
	MOV A,L
	PUSH H
	DCX SP ; return address
	DCX SP
#endasm
}

outp(n,b) /* send byte value b to port n */
	int n,b; {
#asm
	INX SP ; past return addr
	INX SP

	POP H ; value
	MOV A,H
	POP H ; port
	MOV H,L
	MVI L,0D3H ; out op code
	SHLD .oport

.oport: DW 0 ; opcode & port go here, then .oport is executed (dco)

	PUSH H ; restore stack
	PUSH H
	DCX SP
	DCX SP
#endasm
}

pause() /* sit and wait until the keyboard is hit */
{
	while(!kbhit());
}

sleep(n) /* sleep for n/10 seconds */
int n; {
	int i,j,k;
	for(i=0; i!=n; ++i){
		for(j=0; j!=10; ++j){
			for(k=0; k!=0xAF; ++k);
			if(kbhit()){ getchar(); exit();}
		}
	}
}

kbhit() /* return true if a character is waiting at 
	the console */
{
	return(bdos(11,0)); /* console status */

/* 

kbhit() also works as a bios call. In that case it's

	return(bios(2,0));

				H.G.L.
*/

}
