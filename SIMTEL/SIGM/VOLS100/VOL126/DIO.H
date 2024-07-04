/*June 27, 1983 eliminate directed input*/
/*??? modified by EEB Nov 82 for dioinit(),dioflush() */
/*
	External data used by DIO.C for directed I/O simulation:
	(BDSCIO.H must also be #included in the main file.)
*/

char _doflag;	/* flag if directed /O being used */
char  **_nullpos; /*???*/
char _dobuf[BUFSIZ];	/* /O buffer used for direction  */
char sav_out_file[20];	/*??? added to work with dioinit
				and dioflush() ???*/
