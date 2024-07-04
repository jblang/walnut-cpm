/*
	Program to insert a line feed after carriage return
	in text files with no line feeds in them (i.e. FLEX
	text files)

VERSION LIST, most recent version first

25/Apr/84
	ADDLF created from SCRUB. Bill Bolton

26/Sep/82
	Forces MSB of all characters to 0, then scans for control
	codes. TAB, CR and LF are passed unchanged to the output
	file. US (soft hyphen) is replaced by a hard hyphen.
	Checking for legal CP/M filename on destination file
	added. Expanded "usage" message. Added "working" messages.
	Bill Bolton. 

	This program was developed from a program called SCRUB
	on BDS "C" User Group disk "Utilities 2" (Volume 2 in
	the Software Tools RCPM BDSCAT.ALL).
*/

/*
	Macros for constant definitions
*/

#include BDSCIO.H

#define VERSION 1	/* main version number */
#define REVISION 0	/* sub version number */
#define DEL 0x7F	/* ASCII delete character */
#define WORKING 1024	/* number of chars between progress markers */
#define NEXTLINE (WORKING * 32) /* number of progess chars on a screen line */

/*
	Argument vector indices
*/

#define FROM_FILE 1
#define TO_FILE   2

/*
	main to open the files for addlf()
	and handle invocation errors.
*/

main(argc,argv)
int argc;
char *argv[];

{
	int fdin,fdout;
	char inbuf[BUFSIZ],outbuf[BUFSIZ];
	char buf[12];

	printf("\nChanges CR to CR + LF, Version %d.%d\n",VERSION,REVISION);
	printf("Bill Bolton, Software Tools\n");
	if( argc != 3 )
			usage();
	else {
		if( (fdin = fopen(argv[FROM_FILE],inbuf)) == ERROR){
			printf("\nCannot find file %s\n",argv[FROM_FILE]);
			usage();
		}
		else {
			if(bad_name(argv[TO_FILE])) {
				printf("\nBad file name %s\n",argv[2]);
				usage();
			}
			else {
				if( (fdout  = fcreat(argv[TO_FILE],outbuf)) == ERROR )
					printf("\nCan't open %s\n",argv[TO_FILE]);
				else {
					printf("\nWorking ");
					addlf(inbuf,outbuf);
				}
			}
		}
	}
	exit();
}

/*
	procedure addlf -- copy file to file adding line feed after each
			   carriage return
*/

addlf(filein,fileout)
char filein[];	/* the input file buffer */
char fileout[];	/* the output file buffer */

{
	int c;			/* 1 char buffer */
	unsigned count;		/* count of characters processed */
	unsigned inserted;	/* numbers of bytes inserted */

	count  = 0;
	inserted = 0;

	while( (c = getc(filein) & 0x7F) != EOF  && c != CPMEOF ){
		count++;
		if (count % WORKING == 0)
			printf("*");		/* still alive */
		if (count % NEXTLINE == 0)
			printf("\n\t");		/* new line every so often */
		if( c >= ' ' && c < '\177' )	/* visable character ? */
			putc(c,fileout);
		else
			switch(c) {
				case '\r':
					putc(c,fileout); /* ok control chars */
					putc('\n',fileout);
					inserted++;
					break;

				default:
					putc(c,fileout);
					break;
  			}
	}
	putc(CPMEOF,fileout);			 /* sent textual end of file */
	printf("\n");
	if( fflush(fileout) == ERROR)
		exit(puts("\nOutput file flush error\n"));
	printf("\n%u characters were processed\n",count);
	printf("%u line feeds were inserted\n",inserted);
}

int bad_name(buf)

char	*buf;

{
	char	fcb[36];

	setfcb(fcb,buf);
	if (fcb[0] < 0 || fcb[0] > 15)	/* check for valid drive */
		return(ERROR);
	return(valid_check(fcb));
}

int valid_check(buf)

char	*buf;

{
	int	index;

	for (index = 1; index < 12; ++index){
		if (bad_char(index,buf))
			return(-1);
	}
	return(0);
}

/* Checks if a character is legal in a CP/M directory entry or file control
   block */

int bad_char(index,buf)

int	index;
char	*buf;

{
	char	temp[0];		/* Transient storage for > del test */
	int	space;

	if (index == 1 || index == 9)	/* Reset at start of filename & typ */
		space = 0;		 
	switch (buf[index]){
	case  '*':
	case  ',':
	case  '.':
	case  ':':
	case  ';':
	case  '<':
	case  '=':
	case  '>':
	case  '?':
	case  '[':
	case  ']':
	case  DEL:
		return(-1);
	case  ' ':			/* Space is conditionally illegal */
		if (space == 7)		/* Filename is all spaces is a */
			return(-1);	/* definite error */
		space++;		/* Else just keep track of how many */
		return(0);
	}
	if (buf[index] < ' ' || (buf[index] >= 'a' && buf[index] <= 'z'))
		return(-1);
	if (buf[index] > DEL){		/* Bit 7 set may be legal attribute */
		*temp = buf[index] & DEL; /* so force it to 0 and try again */
		return (bad_char(0,temp));
	}
	else
		return(space);		 /* Space preceeding char IS illegal */
}

usage()

{
		printf("\nUsage:\n\n");
		printf("\tADDLF d:file1 d:file2\n\n");
		printf("Where:\n");
		printf("\tfile1 = source file, (* and ? not allowed)\n");
		printf("\tfile2 = destination file, (* and ? not allowed)\n");
		printf("\td:    = optional drive identifier\n\n");
		printf("i.e.\tADDLF A:FOOBAR.TXT B:FUBAR.DOC\n");
}

/* end of addlf */
