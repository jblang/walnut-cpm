/*-----------------------------------------------------------------------------

	'SQ' version 1.5	     	Richard Greenlaw,
					251 Colony Ct,
					Gahanna, Ohio 43230,
					U.S.A.

	Version 1.5a amendments 	John Hastwell-Batten,
					38 Silvia St,
					Hornsby, NSW 2077,
					Australia.

This program compresses a file without losing information.  The companion
program USQ.COM is required to unsqueeze the file before it can be used.

Typical compression rates are:
	.COM	6%	(Don't bother)
	.ASM	33%	(using full ASCII set)
	.DIC	46%	(using only uppercase and a few others)
Squeezing a really big file takes a few minutes.

Usage:
	SQ item ...
	where ... represents more (optional) items and
	"item" is either:
		drive:		to change the output drive
		file		input file
		drive:file	input file
		-		toggle debugging display mode
		+		toggle "permission" flag

Ambiguous file names are supported by version 1.5a of this utility through
Leor Zolman's WILDEXP routine which also allows for EXCLUDING files from
the parameter list.  See the documentation in WILDEXP.C for details.

The squeezed file name is formed by changing the second letter of the file
type to Q. If there is no file type, the squeezed file type is QQQ.  If the
name exists it is overwritten!

Examples:
	A>SQ GRUMP		makes GRUMP.QQQ on A:
	A>SQ D:CRAP.XYZ		makes CRAP.XQZ on A:
	A>SQ B: D:CRAP.COM	makes CRAP.CQM on B:
	B>SQ X.A C: Y.B		makes X.AQ on B: and Y.BQ on C:
	A>sq	.*		squeezes all files on A:
	A>sq b:	.*		puts squeezed versions of all
				files from A: onto B:
	A>sq *.* !-.* !*.com	squeezes all files on A: except
				.COM files and those having
				names starting with a hyphen
	A>sq b:	.* !*.com	squeeze all except .COM files
				onto B:

The transformations compress strings of identical bytes and then encode
each resulting byte value and EOF as bit strings having lengths in
inverse proportion to their frequency of occurrence in the intermediate
input stream. The latter uses the Huffman algorithm.  Decoding infor-
mation is included in the squeezed file, so squeezing short files or
files with uniformly distributed byte values will actually increase size.

SQ version 1.5a checks the output file size.  If it is not WORTHWHILE
percent smaller than the original then it will automatically discard the
output file, and, if the output file was created on a different disk from
the original then the input file will be copied in place of the discarded
output.

If the + option is active and a poorly-compressed file is generated then
SQ 1.5a will ask permission before discarding the output file (and maybe
copying the input file.

In general, version 1.5a should make it easy to squeeze whole disks with
a series of commands such as:

	findbad b:			;Validate the output disk
	pip b:=a:-*.*			;Copy the volume id files
	pip b:=a:crclist.*		;Copy the CRC file if it exists
	sq b: *.* !-*.* !crclist.*	;Squeeze everything else

-------------------------------------------------------------------------------

CHANGE HISTORY:

1.3	Close files properly in case of error exit.

1.4	Break up long introductory lines.
	Send introduction only to console.
	Send errors only to console.

1.5	Fix BUG that caused a rare few squeezed files to be incorrect and
	fail the USQ crc check.

	The problem was that some 17 bit codes were generated but are not
	supported by other code.  THIS IS A MAJOR CHANGE affecting TR2.C
	and SQ.H and requires recompilation of all files which are part
	of SQ.  Two basic changes were made: (1) tree depth is now used
	as a tie-breaker when weights are equal.  This makes the tree
	shallower.  Although that may always be sufficient, (2) an error
	trap was added to cause rescaling of the counts if any code more
	than 16 bits long is generated.

	Add debugging displays option '-'.

1.5a	Leor Zolman's WILDEXP command-line preprocessor routine is invoked
	to support ambiguous file names and exclusions.  I/O redirection
	was removed.

	Output file size checking was implemented to trap the creation of
	poorly-compressed files.

	Instead of ignoring files which are already squeezed, SQ will
	copy them if the destination disk is different from the source
	disk.

	The only changes to modules other than SQ.C were to remove the
	"#include <dio.h>" statements and to replace "fprintf(STDERR.."
	with "printf(.."

1.6	(Obsolete)  Added simple wildcard expansion.

-----------------------------------------------------------------------------*/

#define		VERSION		"1.5a"
#define		DATE		"19th June 1983"
#include	<bdscio.h>
#include	"sqcom.h"
#include	"sq.h"
#define 	WORTHWHILE 	8	/* any less compression than 8% is
					   hardly worth it! */
#define		THRESH		9	/* no real point in squeezing any
					   file shorter than 9 sectors */
char	default_drive,
	newdrive,
	permission,
	l_worthwhile[4],
	l_num[4],
	l_den[4],
	one_hundred[4],
	l_pct[8];
int	orig_sects,
	sq_sects,
	unsq_sects;

main(argc, argv)
int argc;
char *argv[];
{
	int i,c;

	if (wildexp(&argc,&argv))
	   exit(puts("\07**** Too many files to process\n"));

	itol(l_worthwhile,WORTHWHILE);
	itol(one_hundred,100);
	permission = TRUE;
	debug = FALSE;
	printf("\n\n\tSQUEEZE version %s (%s)\n",VERSION,DATE);
	printf("\tA file compression utility by Richard Greenlaw\n");
/*	printf("\t251 Colony Ct, Gahanna, Ohio 43230\n");	*/

	/* Initialize output drive to default drive */
	outdrv[0]  = '\0';
	/* But prepare for a specific drive */
	outdrv[1] = ':';
	outdrv[2] = '\0';	/* string terminator */
	default_drive = bdos(25,0)+'A';

	/* Process the parameters in order */
	for(i = 1; i < argc; ++i)
		obey(argv[i]);
	if (argc > 1) {
	    printf("\n\n%d sectors were compressed to %d representing a ",
			orig_sects, sq_sects);
	    printf("%s%c shrinkage.\n",
		percent(orig_sects-sq_sects,orig_sects),'%');
	    printf("%d sectors were not squeezed.  Nett shrinkage was %s%c",
		unsq_sects,
		percent(orig_sects-sq_sects,orig_sects+unsq_sects),'%');
	}
}

percent(numerator,denominator)
int	numerator,denominator;
{
/*
	Returns a pointer to an ASCII string representation of the quantity
			numerator*100/denominator
									*/
   return(ltoa(l_pct,ldiv(l_num,lmul(l_num,itol(l_num,numerator),
		one_hundred),itol(l_den,denominator))));
}

obey(p)
char *p;
{
	char *q, just_copy;
	char outfile[16];	/* output file spec. */

	if((*p == '-') && (*(p+1)=='\0')) {
		/* toggle debug option */
		debug = !debug;
		return;
	}
	if((*p == '+') && (*(p+1)=='\0')) {
		/* toggle "permission" flag */
		permission = !permission;
		return;
	}
	if(*(p + 1) == ':') {
		/* Got a drive */
		if(isalpha(*p)) {
			if(*(p+2) == '\0') {
				/* Change output drive */
				printf("\nOutput drive =%s",p);
				outdrv[0] = *p;
				newdrive=(*p != default_drive);
				return;
			}
		} else {
			printf( "\nERROR - Ignoring %s", p);
			return;
		}
	}

	/* First build output file name */
	outfile[0] = '\0';		/* empty */
	strcat(outfile, outdrv);	/* drive */
	strcat(outfile, (*(p + 1) == ':') ? p + 2 : p);	/* input name */

/* Find and change output file type */
  just_copy = FALSE;
  for(q = outfile; *q != '\0'; ++q)
     if(*q == '.')
        if(*(q + 1) == '\0')
           *q = '\0';	/* kill trailing dot */
	else
	   switch(*(q+2))
	   {
case 'q':
case 'Q':
	     just_copy = TRUE;	/* just copy to output if necessary */
case '\0':
	     *(q+3) = '\0';
	     /* fall thru */
default:
	     *(q + 2) = 'Q';
	     goto named;
	  }
/* No file type */
   strcat(outfile, ".QQQ");
named:
   squeeze(p, outfile, just_copy);
}

squeeze(infile, outfile, just_copy)
char *infile, *outfile, just_copy;
{
	int orgsize, newsize;
	int i, c, gain;
	char junkit, copy_original;
	struct _buf inbuff, outbuff;	/* file buffers */

	printf("\n\n%s -> %s: ", infile, outfile);

	if(fopen(infile, &inbuff) == ERROR) {
	   printf( "Can't open %s for input pass 1\n", infile);
	   return;
	}
	if (((orgsize=cfsize(inbuff._fd)) < THRESH) || just_copy) {
	   unsq_sects += orgsize;
	   printf("%d sectors - ",orgsize);
	   if (just_copy) printf("already squeezed?\n");
	   else printf("too short to be worth squeezing\n");
	   copy_original=newdrive;
	   fabort(inbuff._fd);	/* File gets opened again later */
	   goto copy;
	}
	if(fcreat(outfile, &outbuff) == ERROR) {
	   printf( "Can't create %s\n", outfile);
	   fclose(&inbuff);
	   return;
	}
	junkit = copy_original = FALSE;

/* First pass - get properties of file */
	crc = 0;	/* initialize checksum */
	printf("analyzing, ");
	init_ncr();
	init_huff(&inbuff);   
	fclose(&inbuff);

	/* Write output file header with decoding info */
	wrt_head(&outbuff, infile);

	/* Second pass - encode the file */
	printf("squeezing, ");
	if(fopen(infile, &inbuff) == ERROR) {
	   printf( "Can't open %s for input pass 2\n", infile);
	   junkit = TRUE;
	   goto closeout;
	}
	init_ncr();	/* For second pass */

	/* Translate the input file into the output file */
	while((c = gethuff(&inbuff)) != EOF)
	   if(putc(c, &outbuff) == ERROR) {
	      printf( "ERROR - write failure in %s\n", outfile);
	      junkit = TRUE;
	      goto closeall;
	   }
	printf("done.");

	orgsize=cfsize(inbuff._fd);
	fflush(&outbuff);
	newsize=cfsize(outbuff._fd);
	printf("\nInput %d sectors, output %d sectors, i.e. ",
			orgsize,newsize);
	if (orgsize-newsize) {
	   printf("a%ssion of %d sectors (%s%c)",
		((orgsize<newsize) ? "n expan" : " compres"),
		abs(orgsize-newsize),
		(orgsize ? percent(abs(orgsize-newsize),orgsize) : "INFINITY"),
		'%');
	}
	else
	   printf("no change in file size");

	if ((newsize>=orgsize) || (lcomp(l_num,l_worthwhile)-1))
	   if (junkit=permission) {
	      printf("\nDiscarding output file\n");
	      copy_original = newdrive; }
	   else {
	      printf("\nShould I discard the output file%s?",
		  (newdrive ? " and copy the original" : ""));
	      if (junkit=(tolower(c=getchar()) != 'n')) {
		 copy_original = newdrive;
		 if (c != '\n')
		    putc('\n');
	      }
	   }
	if (junkit)
	   unsq_sects += orgsize;
	else
	{
	   orig_sects += orgsize;
	   sq_sects += newsize;
	}

closeall:
	fclose(&inbuff);
closeout:
	fflush(&outbuff);
	fclose(&outbuff);
	if (junkit)
	   unlink(outfile);
copy:
	if (copy_original) {
	   fopen(infile,&inbuff);    /* don't have to check result */
	   outfile[0] = '\0';		/* empty */
	   strcat(outfile, outdrv);	/* drive */
	   strcat(outfile,(*(infile+1)==':') ? infile+2 : infile);
	   if (fcreat(outfile,&outbuff)==ERROR)
		printf("Cannot open output %s%s for simple copy",
			outdrv,outfile);
	   else {
		printf("Copying %s unchanged to %s disk",infile,outdrv);
		while ((c=getc(&inbuff)) != EOF)
		    if (putc(c,&outbuff)==ERROR) {
			printf("\nError during copy - disk full?");
			break;
		    }
	   }
	   copy_original = junkit = FALSE;
	   goto closeall; /* Go back and tidy up the files */
	}
}