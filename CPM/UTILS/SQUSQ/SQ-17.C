/* SQ.C CHANGE HISTORY:
 * 1.7  Add checkurk() memory check, changed credits 8-14-83 -CAF
 *	Check for proper linking and sufficient memory to execute
 *	Made inbuff and outbuff global for speed gain.
 * 1.6  Add wild card expansion (wildexp) 6-12-82 -CAF
 * 1.5  Fix BUG that caused a rare few squeezed files
 *	to be incorrect and fail the USQ crc check.
 *	The problem was that some 17 bit codes were
 *	generated but are not supported by other code.
 *	THIS IS A MAJOR CHANGE affecting TR2.C and SQ.H and
 *	requires recompilation of all files which are part
 *	of SQ. Two basic changes were made: tree depth is now
 *	used as a tie breaker when weights are equal. This
 *	makes the tree shallower. Although that may always be
 *	sufficient, an error trap was added to cause rescaling
 *	of the counts if any code > 16 bits long is generated.
 * 	Add debugging displays option '-'.
 * 1.4	Break up long introductory lines.
 * 	Send introduction only to console.
 * 	Send errors only to console.
 * 1.3	Close files properly in case of error exit.
 *
 * This program compresses a file without losing information.
 * The usq.com program is required to unsqueeze the file
 * before it can be used.
 *
 * Typical compression rates are:
 *	.COM	6%	(Don't bother)
 *	.ASM	33%	(using full ASCII set)
 *	.DIC	46%	(using only uppercase and a few others)
 * Squeezing a really big file takes a few minutes.
 *
 * Useage:
 *	SQ item ...
 * where ... represents more (optional) items and
 * "item" is either:
 *	drive:		to change the output drive
 *	file		input file
 *	drive:file	input file
 *	-		toggle debugging display mode
 *
 * If no such items are given on the command line you will be
 * prompted for commands (one at a time). An empty command
 * terminates the program.
 *
 * SQ uses the dio package, so input and output can be redirected
 * by special items on the command line such as:
 *	<file		reads console input from file
 *	>file		sends console output to file
 *	+file		sends console output to console and file
 * Also console output of another program using dio can be piped
 * to the input of this one or vice-versa. Example:
 *	A>fls parameters |sq
 * where fls might be a program that expands patterns like *.com
 * to a list of ambiguous file names for sq to squeeze.
 *
 * The squeezed file name is formed by changing the second
 * letter of the file type to Q. If there is no file type,
 * the squeezed file type is QQQ. If the name exists it is
 * overwritten!
 * 
 * Examples:
 *	A>SQ GRUMP		makes GRUMP.QQQ on A:
 *	A>SQ D:CRAP.XYZ		makes CRAP.XQZ on A:
 *	A>SQ B: D:CRAP.COM	makes CRAP.CQM on B:
 *	B>SQ X.A C: Y.B		makes X.AQ on B: and Y.BQ on C:
 *
 * The transformations compress strings of identical bytes and
 * then encode each resulting byte value and EOF as bit strings
 * having lengths in inverse proportion to their frequency of
 * occurrance in the intermediate input stream. The latter uses
 * the Huffman algorithm. Decoding information is included in
 * the squeezed file, so squeezing short files or files with
 * uniformly distributed byte values will actually increase size.
 */

#define VERSION "1.7   08-14-83"

#include <a:bdscio.h>
#include <a:dio.h>
#include "sqcom.h"
#include "sq.h"
#define STDERR 4	/* console only (error) stream */

/* Sneak in a few "local externs": N.B. sq.crl must be linked first! */
char outfile[16];	/* output file spec. */
unsigned Sentinel;	/* be sure this doesn't get munged ! */
#define SENTINEL	055555

main(argc, argv)
int argc;
char *argv[];
{
	int i,c;
	int getchar();		/* Directed io version */
	char inparg[16];	/* parameter from input */

	checkurk();		/* check for armageddon */
	Sentinel = SENTINEL;	/* unlikely value */
	wildexp(&argc, &argv);	/* do the shell's work */
	dioinit(&argc, argv);	/* obey directed to args */

	debug = FALSE;

	/* Initialize output drive to default drive */
	outdrv[0]  = '\0';
	/* But prepare for a specific drive */
	outdrv[1] = ':';
	outdrv[2] = '\0';	/* string terminator */

	/* Process the parameters in order */
	for(i = 1; i < argc; ++i)
		obey(argv[i]);

	if(argc < 2) {
		if(! _diflag) {
			fprintf(STDERR,"File squeezer %s\n", VERSION);
			fprintf(STDERR,"Conceived by Richard Greenlaw Modified by Chuck Forsberg et al.\n");
			fprintf(STDERR,"Accepts redirection and pipes.\n");
			fprintf(STDERR, "Parameters (from command line or singly from stdin)\nconsist of output drives and input file names.\n");
		}
		do {
			fprintf(STDERR, "\n*");
			for(i = 0; i < 16; ++i) {
				if((c = getchar()) == EOF)
					c = '\n';	/* fake empty (exit) command */
				if((inparg[i] = c) == '\n') {
					inparg[i] = '\0';
					break;
				}
			}
			if(inparg[0] != '\0')
				obey(inparg);
		} while(inparg[0] != '\0');
	}
	dioflush();	/* clean up any directed io */
	if (Sentinel != SENTINEL)
		fprintf(STDERR,"out of memory: translation suspect\007\n");
}

obey(p)
char *p;
{
	char *q;

	if(*p == '-') {
		/* toggle debug option */
		debug = !debug;
		return;
	}
	if(*(p + 1) == ':') {
		/* Got a drive */
		if(isalpha(*p)) {
			if(*(p+2) == '\0') {
				/* Change output drive */
				printf("\nOutput drive =%s",p);
				outdrv[0] = *p;
				return;
			}
		} else {
			fprintf(STDERR, "\nERROR - Ignoring %s", p);
			return;
		}
	}

	/* Check for ambiguous (wild-card) name */
	for(q = p; *q != '\0'; ++q)
		if(*q == '*' || *q == '?') {
			fprintf(STDERR, "\nAmbiguous name %s ignored", p);
			return;
	}
	/* First build output file name */
	outfile[0] = '\0';		/* empty */
	strcat(outfile, outdrv);	/* drive */
	strcat(outfile, (*(p + 1) == ':') ? p + 2 : p);	/* input name */

	/* Find and change output file type */
	for(q = outfile; *q != '\0'; ++q)
		if(*q == '.')
			if(*(q + 1) == '\0')
				*q = '\0';	/* kill trailing dot */
			else
				switch(*(q+2)) {
				case 'q':
				case 'Q':
					fprintf(STDERR, "\n%s ignored ( already squeezed?)", p);
					return;
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
	squeeze(p, outfile);
}

squeeze(infile, outfile)
char *infile, *outfile;
{
	int i, c;

	printf("\n%s -> %s: ", infile, outfile);

	if(fopen(infile, &inbuff) == ERROR) {
		fprintf(STDERR, "Can't open %s\n", infile);
		return;
	}
	if(fcreat(outfile, &outbuff) == ERROR) {
		fprintf(STDERR, "Can't create %s\n", outfile);
		fclose(&inbuff);
		return;
	}

	/* First pass - get properties of file */
	crc = 0;	/* initialize checksum */
	init_ncr();
	printf("scanning, ");
	init_huff();   
	fclose(&inbuff);

	/* Write output file header with decoding info */
	wrt_head(infile);

	/* Second pass - encode the file */
	printf("squeezing, ");
	if(fopen(infile, &inbuff) == ERROR) {
		fprintf(STDERR, "Can't open %s\n", infile);
		goto closeout;
	}
	init_ncr();	/* For second pass */

	/* Translate the input file into the output file */
	while((c = gethuff()) != EOF)
		if(putc(c, &outbuff) == ERROR) {
			fprintf(STDERR, "ERROR - write error in %s\n", outfile);
			goto closeall;
		}
	printf(" done.");
closeall:
	fclose(&inbuff);
closeout:
	fflush(&outbuff);
	fclose(&outbuff);
}
/*
 * Check for proper linking and sufficient memory to execute
 */
checkurk()
{
	char *endext(), *topofmem(), *codend(), *externs();

	if (codend() > externs() 	/* check for bad -e value! */
	 || (topofmem()-1000) < endext() ) {
		printf("checkurk(): bad memory layout\n");
		exit();
	}
}
