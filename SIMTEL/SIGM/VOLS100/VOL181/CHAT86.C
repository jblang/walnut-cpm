/*
			  CHAT

	    A remote system conversation utility

	This version for Digital Research C compiler for CP/M-86

			Bill Bolton
			Software Tools RCPM
			P.O. Box 357,
			Kenmore,
			QLD, 4069
			Australia

	International 61 7 378-9530+
	Domestic      (07) 378-9530	300bps CCITT V.21 standard

VERSION LIST, most recent version first

25/Feb/84 Initial implemenation. Based on the 8080 assembler
	  program CHAT26.ASM. A first attempt at making CHAT
	  portable to 16 bit environments, this version
	  emulates the 8080 assembler version.
	  Version 3.0 (Bill Bolton)

*/


#define VERSION 3		/* Major version number */
#define REVISION 0		/* Minor version number */

#define MAXTRY 6		/* number of times beep for SYSOP */
#define PAUSE 5			/* seconds between beeps */	
#define MHZ 8			/* clock speed of CPU */
#define SPEED (9400 * MHZ)	/* a value to count to */

#define WIDTH 62		/* length of chat line */
#define EWARN (WIDTH - 9)	/* word wrap zone */

#define ABORT 0x03		/* Control C */
#define BACKSPACE 0x08		/* ASCII backspace */
#define CNTRLX 0x18		/* CP/M clear line */
#define ESC 0x1B		/* ASCII escape */

#define DCON 6			/* CP/M bdos direct console acces */
#define INPUT 0xFF		/* request input from bdos dcon */

#include "STDIO.H"
#include "CTYPE.H"

main(argc,argv)

int argc;
char *argv[];

{

	int	i;

	printf("\nCHAT ver %d.%d - Remote conversation utility.\n\n",
		VERSION,REVISION);

	if (argc >= 2)
	{
		if (argv[1][0] == 'c')
		{
			chat();
			exit();
		}
		else
		{
			usage();
		}
	}
	
	printf("Program returns to system in 30 seconds\n");
	printf("if operator is unavailable.\n\n");
	printf("Alerting operator . \07\07\07");

	if (dinger())
	{
		printf("\n\nOperator is available, enter Control-C to exit CHAT\n");
		printf("Please go ahead:\n\n");
		chat();
		exit();
	}

	printf("Sorry, no operator available -\n");
	printf("Please leave your request on MINIRBBS.\n\n");
	exit();
}

dinger()

{
	long		count;
	int		seconds;
	int		dot;
	char		c;

	for(dot = 0; dot < MAXTRY; dot++)
	{
		for(seconds = 0; seconds < (PAUSE + 1); seconds++)
		{
			if ((c = __BDOS(DCON,INPUT)) != 0)
			{
				if (c == ESC)
				{
					return(TRUE);
				}
			}
			for(count = 0; count < SPEED; count++);
		}
		printf(". \07\07\07");
	}
	printf("\n\n");
	return(FALSE);
}

chat()

{
	char	c;
	int	count;

	for (;;)	/* forever */
	{
		for (count = 0; count < WIDTH; count++)
		{
			do
			{
				c = __BDOS(DCON,INPUT);
			} while (c == 0);

			if (c == ABORT)
			{
				printf("\n\n");
				return;
			}

			if (c == '\r')
			{
				break;
			}

			if (c == '\n')
			{
				break;
			}

			if ((c == BACKSPACE) && (count > 1))
			{
				count--;	/* reduce this loop */
				count--;	/* reduce last loop */
				__BDOS(DCON,BACKSPACE);
				__BDOS(DCON,' ');
				__BDOS(DCON,BACKSPACE);
			}
			else
			{
				if ((c < ' ') && (count > 1))
				{
				count--;
				}
				else
				{
					__BDOS(DCON,c);
				}
			}

			if ((count >= EWARN) && ispunct(c))
			{
				break;
			}
		}

		dcrlf();
	}
}

dcrlf()

{
	__BDOS(DCON,'\r');
	__BDOS(DCON,'\n');
}

usage()

{
	printf("Usage:\n");
	printf("\tCHAT\t\t(There are no commands or arguments)\n\n");
	printf("\n\nWhen  this  program is requested,  it rings the  bell  at the\n");
	printf("operator's  console  indicating  the remote  user  wishes  to\n");
	printf("\"chat\".  If the SYSOP is not available, it returns to CP/M in\n");
	printf("30 seconds.\n\n");

	exit();
}

/* end of CHAT */
