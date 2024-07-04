/*
   Pause program for use with SUBMIT or BATCH files

   By Bill Bolton
      Software Tools RCPM,
      P.O. Box 357,
      Kenmore,
      QLD, 4069
      Australia

      International 61 7 378-9530+
      Domestic      (07) 378-9530     300bps CCITT V.21 Standard

   VERSION LIST, most recent version first.

   21/Feb/84 Added command line checking, display version number,
             added usage message. Made disk change message optional
	     depending on command line. Version 1.1 Bill Bolton

   21/Feb/84 Initial implementation. Version 1.0. Bill Bolton



	FOR DIGITAL RESEARCH C COMPILER
*/

#define VERSION 1		/* major version number */
#define REVISION 1		/* minor version number */

#include <STDIO.H>		/* DR C standard header  */


main(argc,argv)
int	argc;
char	*argv[];

{

	char	c;		/* a throw away variable */
	char	ibuf[1];

	printf("PAUSE version %d.%d\nBy Bill Bolton\n\n",VERSION,REVISION);

	if (argc > 2)
	{
		usage("too many command line arguments");
	}

	if (argc == 2)
	{
		if ((2 == strlen(argv[1])) && (argv[1][0] >= 'a')
		   && (argv[1][0] <= 'p') && (argv[1][1] == ':'))
		{	
			printf("Change the floppy disk in the %s drive.\n\n",argv[1]);
		}
		else
		{
			usage("illegal drive identifier");
		}
	}

	printf("Push any key to continue....");
	read(0,ibuf,1);
	printf("\n");
	exit();
}


usage(error)

char *error;

{
	printf("Command line ERROR, %s.\n\n",error);
	printf("Usage:\n");
	printf("\tPAUSE\n");
	printf("\tPAUSE d:\n\n");
	printf("Where:\n");
	printf("\td: = Any valid CP/M drive identifier.\n\n");
	exit();
}

/* end of pause */
