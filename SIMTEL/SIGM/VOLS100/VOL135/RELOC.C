/*-----------------------------------------------------------------------------

				R E L O C . C
				=============

	Part of a system for generating self-relocating programs.

	(See RELOC.DOC for full details of method and application)

	COPYRIGHT NOTICE	(C) 1982   John Hastwell-Batten

These programs have been submitted to the public domain via Bill Bolton's RCPM 
system and comprise a system for simply generating self-relocating programs by 
a  method which relies on a linker to generate two object code files which are 
then  processed to yield an object program consisting of  a  relocator,  user-
supplied  object  code  and  a relocation  bitmap.   These  programs  and  the 
accompanying  documentation may be freely distributed in original or  modified 
form subject to the following conditions:

1.   Although  there is no restriction on the sale of self-relocating programs 
     generated  by  the method described herein,  these programs  or  variants 
     thereof  may not be sold as part of any program package  without  written 
     permission  from the author.   Neither may any program or program package 
     which  is dependent for its operation on the use of this method  be  sold 
     without such permission.

2.   The  author's  name  must  be retained in all source  code  (original  or 
     modified)  and  as an acknowlegement in any message  displayed  by  these 
     programs or variant(s) thereof.  An acknowledgement giving credit for the 
     method  shall contain the author's name or the words "H-B method" or  the 
     words "Ashby method".

3.   This copyright notice must be included in and retained in all source code 
     and documentation pertaining to this system.

                             John Hastwell-Batten
                               38 Silvia Street
                               Hornsby NSW 2077
                                  AUSTRALIA
                                (02) 477 4225

                              1st November, 1982

Acknowledgement

In  testing those relocations which overlay specified portions of CP/M I  have 
made  use of John Woolner's CCP protection scheme obtained via  Bill  Bolton's 
RCPM  system.   Without  the CCP protection the verification of the  relocator 
module  would have been exceedingly difficult as the standard program  testing 
tools  all  overlay  the CCP which,  in the case of  the  CP/M  overlays,  the 
relocator expects to be intact.

-----------------------------------------------------------------------------*/

#include bdscio.h

#define	COPY		TRUE
#define DISCARD		FALSE

#define CCPOFFSET	-8		/*  8 pages below BDOS */
#define BDOSOFFSET	 0
#define BIOSOFFSET	14		/* 14 pages above BDOS */
#define IMPLICIT	0x100
#define PAGEMASK	0xFF

char
	b100[BUFSIZ], b200[BUFSIZ], b300[BUFSIZ];
char
	bitmap[8192];
int
	c, c3;
unsigned
	codelen, i, relparam, relword();

main(argc,argv)
  int  argc;
  char *argv[];
{
  puts("Self-relocating-program generator - version 2.1 (27/11/82)\n");
  puts("\n(C)1982: John Hastwell-Batten,\n\t 38 Silvia Street,\n");
  puts("\t Hornsby NSW 2077.\n\t (02) 477 4225\n");

/* Open the 2 input files and the output code file */

  if (argc < 2) {
      puts("\nNo output file name specified\n");
      usage();
      exit();  }

  if (fopen("ORG200.COM",b200) < 0) {
      puts("\nORG200 linked code file is missing\n");
      exit();  }
  else if (fopen("ORG300.COM",b300) < 0) {
      puts("\nORG300 linked code file is missing\n");
      exit();  }
  else if (fcreat(argv[1],b100) < 0) {
      printf("\nCannot open output %s file",argv[1]);
      exit();  }

/* First establish the relocation parameter for the relocator module.

   The relocator starts with a jump to base+5 to skip over the parameter.
   (For most processors on which this program will be run, the jump is
   a 3-byte instruction.)  The relocation parameter is in the next two
   bytes.

   It would be most convenient to write the object code for the jump
   from this module but to do so is slightly less general in that this
   module must assume knowledge of the processor's instruction set.

   Instead, we copy the first three bytes from the relocator module,
   replace the next two bytes with the relocation parameter, and then
   copy the rest of the relocator.  It is just a little bit messy.	*/

   for (i=0; i<3; i++)
     relmod(COPY);		/* Copy first 3 bytes */

   for (; i<5; i++)
     relmod(DISCARD);		/* Discard next 2 bytes */

   if (argc > 2)		/* i.e. if relocation parameter specified */
     relparam = relword(argv[2],argv[1]);
   else {
     relparam = 0;
     printf("\n%s will load below the BDOS\n",argv[1]);
	}

   putw(relparam,b100);		/* Stuff in the relocation parameter */
   printf("Relocation parameter is %x\n",relparam);

/* Now copy the remainder of the first 0xFE bytes (relocator module)
   from ORG200 to the output code file */

  for (i=5; i<0xFE; i++)
    relmod(COPY);

/* Now get the code length and write it to the output file */

  codelen = getw(b200);
  putw(codelen,b100);
  codelen -= 0x200;
  printf("Relocatable code is %xh long\n",codelen);

/* Skip over all the leading junk in ORG300 */

  for (i=0; i<0x1FE; i++) {
    if (getc(b300) == EOF) {
      puts("\nRelocatable program missing from ORG300\n");
      exit(); } }

/* Check to see that the ORG200 & ORG300 code is at least the same length */

  if (getw(b300)-0x300 != codelen) {
    puts("\nLength of relocatable code in ORG200 and ORG300 is different\n");
    exit(); }

/* If we get this far then we are ready to build the bit map */

  setmem(&bitmap[0],8192,0);

  for (i=0; i<codelen; i++) {
    if (((c=getc(b200))==EOF) | ((c3=getc(b300))==EOF)) {
      puts("\nPremature EOF reading relocatable code\n");
      exit(); }
    putc(c,b100);	/* Copy ORG200 to output */
    if (c != c3)
      setbit(i); }

/* Input ORG200 file now copied to output. Close input files and append
   bitmap to the output file */

  fclose(b200);
  fclose(b300);

/* Bitmap is (codelen+7) div 8 bytes long */

  codelen = (codelen+7) >> 3;
  for (i=0; i<codelen; i++)
    putc(bitmap[i],b100);

/* Wrap up */

  fflush(b100);
  fclose(b100);		}
		
/****************************************************************************/

relmod(copy)
    int   copy;
{
    int   c;

    if ((c=getc(b200)) == EOF) {
      puts("\nPremature EOF copying relocator program\n");
      exit();		      }

    if (copy)
      putc(c,b100);
}

/****************************************************************************/

setbit(bitno)		/* sets a bit in the bitmap */
  unsigned bitno; {
/*printf("Setting bit %xh, changing from %xh",bitno,bitmap[(bitno>>3)]);*/
  bitmap[(bitno / 8)] |= (1 << (7-(bitno % 8)));
/*printf(" to %xh\n",bitmap[(bitno>>3)]);*/
}
 
/****************************************************************************/

usage() {	/* Display a quick summary of how to invoke RELOC */

      puts("\nUsage: RELOC <.COM file name> [option]\n\n");
      puts("Option can be any of:-\n");
      puts("\t<empty>\t    => relocate below BDOS\n");
      puts("\t-\t    => relocate below CCP\n");
      puts("\tBIOS\t    => overlay BIOS\n");
      puts("\tBDOS\t    => overlay BDOS\n");
      puts("\tCCP\t    => overlay CCP\n");
      puts("\thex number  => relocate to specific address\n");	}

/***************************************************************************/

relword(where,what)
    char  where[], what[];
{
  unsigned   addr;
  char       *x;

  for (x=where;*x++;)
    *x = toupper(*x);

  if (!(strcmp(where,"-"))) {
    printf("\n%s will load below the CCP\n",what);
    return(CCPOFFSET & PAGEMASK);
			    }
  if (!(strcmp(where,"BIOS"))) {
    printf("\n%s will overlay the BIOS\n",what);
    return(BIOSOFFSET & PAGEMASK | IMPLICIT);
			       }
  if (!(strcmp(where,"BDOS"))) {
    printf("\n%s will overlay the BDOS\n",what);
    return(BDOSOFFSET & PAGEMASK | IMPLICIT);
			       }
  if (!(strcmp(where,"CCP"))) {
    printf("\n%s will overlay the CCP\n",what);
    return(CCPOFFSET & PAGEMASK | IMPLICIT);
			      }
  sscanf(where,"%x",&addr);
  if (addr % 0x100) {
    puts("\nCode destination must be on a 100h boundary\n");
    exit();	    }
  if (addr < 0x200) { 
    puts("\nCode cannot be relocated to an address below 200h\n");
    exit();	    }
  printf("\n%s will load at %xh\n",what,addr);
  return(addr);
}

/****************************************************************************/
