/*********************************************************************
*             ucsdtran  -- ucsd to cp/m transfer                     *
**********************************************************************
*     Copyright (c) 1983     Ben Goldfarb, Orlando, FL               *
*            All rights reserved				     *
*								     *
*     Permission is hereby granted to copy and distribute all parts  *
*     of this software program and associated documents for any      *
*     non-commercial purpose.  Any use of this material for          *
*     commercial advantage without prior written consent of          *
*     the author is prohibited.                                      *
**********************************************************************
*     This program is designed to read files from a 8" (3740) floppy *
*     disk that has been formatted and written by a UCSD Pascal      *
*     System and write them to files on the CP/M system.  Following  *
*     is the sequence of actions:				     *
*         o  Get drive designation for UCSD disk & set up drives     *
*         o  Read and print UCSD disk directory                      *
*         o  Get filename of file to transfer and target file        *
*         o  Do the transfer					     *
*         o  Repeat the above til done				     *
*								     *
*     UCSDTRAN properly handles UCSD Textfiles, converting them      *
*     to CP/M-compatible ascii files.  Compressed blanks are         *
*     expanded and the editor formatting is undone.  No conversion   *
*     is done to UCSD Codefiles, Datafiles, etc.		     *
*								     *
*								     *
*     Installation requires BDS C Version 1.42 or later.  If         *
*     a version prior to 1.50 is used, delete '#include <hardware.h>'*
*     								     *
*								     *
*     UCSDTRAN makes use of the alloc() function for dynamic memory  *
*     allocation, so be certain this feature is enabled in your      *
*     BDS C compiler before you attempt to compile the program.	     *
*     (See the BDS C compiler documentation.)			     *
*								     *
*     Customization:  The only #define that may be necessary to      *
*     change is SECT0.  If your disk system calls the first sector   *
*     on each track '0', rather than '1', you must leave SECT0       *
*     defined.  Otherwise, comment it out or delete the #define.     *
*     This is necessary because the program directly addresses the   *
*     appropriate track and sector on the UCSD disk; all mapping is  *
*     done by the program.  The Godbout DISK 1 controller numbers    *
*     sectors from 0; most others we've seen in CP/M systems start   *
*     with 1.							     *
*								     *
**********************************************************************
*     UCSD is a registered trademark of the Regents of the           *
*          University of California.				     *
*     CP/M is a trademark of Digital Research, Inc.	             *
*     BDS is a trademark of BD Software, Inc.			     *
*								     *
**********************************************************************
*                                                                    *
*              Author:  Ben Goldfarb                                 *
*                       Orlando, FL                                  *
*                                                                    *
*              Date:    02/11/83                                     *
*                                                                    *
*   Bug reports, comments, and suggestions for improvements to:      *
*                 USENET:  ...!duke!ucf-cs!goldfarb		     *
*                 ARPANET: goldfarb.ucf-cs@Rand-Relay	             *
*                                                                    *
**********************************************************************/

/*
 *          Revision Log
 *
 *   $Log:	/usr1/grad/goldfarb/cpm/src/ucsdtran.c,v $
 * Revision 1.2  83/04/06  14:31:51  goldfarb
 * Added facility for transferring non-Textfiles.  Previously, only
 * Textfiles were handled, so code was added to circumvent reformatting
 * of editor text 'pages.'  Type of file is detected by examining the
 * 'kind' field in the UCSD directory entry for the file in question.
 * 
 * Revision 1.1  83/04/06  13:54:34  goldfarb
 * Initial revision
 * 
 */


#include <bdscio.h>
#include <hardware.h>

#define VERSION 12

/* 
 *  Godbout controller kludge (see title page)
 */

#define SECT0


/*  for versions with no screen handling  */
#ifdef VANILLA
#undef CLEARS
#undef INTOREV
#undef OUTAREV
#define CLEARS ""
#define INTOREV ""
#define OUTAREV ""
#endif

/*  Misc. ASCII defines */
#define DLE 0x10
#define CR  0x0d
#define LF  0x0a

/*
 *	Definitions for various CP/M 2.2 data structures.
 */

/*  Absolute memory loocations  */
#define BIOS_LOC 0x0001
#define IOBYTE   0x0003
#define LOGDRV   0x0004
#define BDOS_LOC 0x0006
#define FCB_1    0x005c
#define TBUFF    0x0080


/*   Disk Parameter Block  */

struct dpb {
	unsigned spt;
	char bsf;
	char bm;
	char nm;
	unsigned dsk_siz;
	unsigned dir_max;
	char al0;
	char al1;
	unsigned chk_siz;
	unsigned trk_ofs;
};


/*   Disk Parameter Header  */

struct dph {
	char *pst_tab;
	int scratch[3];
	char *pdir_buf;
	struct dpb *pdpb;
	char *pchk;
	char *ppalv;
};


/*  BIOS calls */
#define SEL_DSK 9
#define SET_TRK 10
#define SET_SEC 11
#define READ 13
#define WRITE 14

/*  BDOS calls  */
#define INIT_BDOS 13
#define SEL_BDOS 14
#define SET_DMA 26

/*  Miscellaneous CP/M constants  */
#define LOG 0
#define NO_LOG 255

/*  Miscellaneous UCSD constants  */
#define PAGESIZE 1024
#define DIRENTRIES 77
#define DIRENTSIZE 26

/*  UCSD directory structures  */
struct direntry {
    int firstblk, lastblk, kind;
    char title[16];
    int bytesinlast;
    char moddate[2];
};

struct dirhdr {
    int dfirstblk, dlastblk, dkind;
    char dtitle[8];
    int lastblkvol, filesindir, loadtime, access;
    char pad[4];
};

/*
 *  Global Variables 
 */

int ucsddrive, cpmdrive;		/*  Disk drive codes  		*/
int Godbout;				/*  Kludge for Disk 1		*/
char string[16];			/*  Misc. string space		*/
int dirp;    				/*  Ptr. to current dir. entry  */
struct dph *pdph;			/*  Ptr. to disk parm header	*/
char buff[PAGESIZE];   			/*  Input buffer		*/
char cpmbuff[BUFSIZ];			/*  Output buffer		*/
struct direntry dir[DIRENTRIES - 1];	/*  Directory buffer		*/
struct dirhdr volid;			/*  Directory header		*/

main()
{
	char c, error, morefiles;

	
	/*  Print program ident  */
	printf(CLEARS);
	printf("\n\nUCSDtran version %d.%d\n",VERSION/10,VERSION%10);
	printf("\n\nUCSD Pascal to CP/M transfer utility.\n\n");
	printf("Copyright (c) 1983, Ben Goldfarb, Orlando, FL.\n\n");

#ifdef SECT0
	Godbout = TRUE;
#else
	Godbout = FALSE;
#endif

	/*  Initialize alligator  */
	_allocp = 0;

	/*  Input drive names  */
	ucsddrive = getdrive("UCSD");
	cpmdrive = getdrive("CP/M");

	/*  Tell user where to go and reset system  */
	do {
		error = FALSE;
		printf("\n\nPut UCSD disk in Drive %c: ", ucsddrive + 'A');
		printf("and CP/M disk in Drive %c:", cpmdrive + 'A');
		printf("\nHit <CR> when ready: ");
		while((c = getchar()) != '\n');
		if ((pdph = seldsk(ucsddrive, LOG)) == NULL) { 
			printf("Message from drive %c:  ", ucsddrive + 'A');
			eprint("You better put it in!");
			error = TRUE;
		}
		else {
		        if (pdph->pdpb->spt != 26 || pdph->pdpb->dsk_siz > 243 ) {
			        eprint("UCSD disk must be standard 3740.");
			        error = TRUE;
				continue;
		        }
 		}
	} while (error);

	readdir();  /*  get UCSD directory  */

	morefiles = TRUE;
        do {
 	   error = FALSE;
	   do {
		printf(CLEARS);
        	printdir();  /*   print directory  */
		printf("Transfer what file: ");
		if ((dirp = getucsd()) == -1) {
			printf("\007No such file\n");	
			error = TRUE;
		}
	   } while (error);
	   tocpm();
	   printf("Transfer more files? ");
	   morefiles = yesno();
	} while (morefiles);
}

tocpm()    /*  Transfer UCSD file to CP/M file  */
{
	char name[30], istext;
	int fd, i, n;
	unsigned track, sect, nsects;

	/*  note: skip first 1024 byte "page" of text file  */
	nsects = ((dir[dirp].lastblk - dir[dirp].firstblk ) * 4);
        if (istext = (dir[dirp].kind == 3)) 
        /*  skip editor page for Textfile  */
		nsects -= 8;
	block(dir[dirp].firstblk + (istext ? 2 : 0), &track, &sect);

	/*  Get filename and set up file  */
	printf("\nEnter CP/M file name: ");
	gets(name);
	printf("Creating %s...",name);
	if ((fd = fcreat(name, cpmbuff)) < 0) {
		printf("\n\007Can't create %s.\n",name);
		return(eprint(""));
	}

	/*  Perform the transfer  */
	while (nsects > 0) {
		if (rwfor(&track, &sect, buff, (istext ? 8 : 4), READ) < 0) 
			return(eprint("Read error on UCSD disk."));
		if (istext)  /* do textfile conversion */
			cpmconvert();
		else   /*  copy raw data  */
			for (i = 0; i < 512; i++) putc(buff[i], cpmbuff);

		nsects -= (istext? 8 : 4);
	}

 	if (istext) putc(CPMEOF, cpmbuff);
	fflush(cpmbuff);
	printf("\nTransfer complete\n");
	fclose(cpmbuff);
}

cpmconvert()  /*  output translated UCSD 1024 byte buffer to cp/m file */
{
	int i, nospaces, bufptr;
	char c;

	bufptr = 0;
	while (bufptr < 1024) {
		
		switch(c = buff[bufptr++]) {
		   case DLE: 
			nospaces = buff[bufptr++] - 32;
			for (i = 0; i < nospaces; i++)
				putc(' ', cpmbuff);
			break;
		   case CR:
			putc(c, cpmbuff);
			putc(LF, cpmbuff);
		        break;
		   case '\0':
			break;  /* ignore  */
		   default:
			putc(c, cpmbuff);
			break;
		}
	}
}

			
rwfor(t,s,buff,n,rw)   /*  Read or write a sector from UCSD disk  */
unsigned *t,*s,n,rw;
char *buff;
{
	char *buffa;

	/*  Reset buffer  */
	buffa = buff;
	
	/*  Select UCSD Disk  */
	seldsk(ucsddrive, NO_LOG);

	/*  Now read or write n sectors  */
	while (n-- > 0) {
		register unsigned ps;

		bios(SET_TRK, *t);
		ps = map(*s, *t);
		/*  Set sector (note Godbout kludge)  */
		bios(SET_SEC, ps + ((Godbout) ? 0 : 1)); 
		bdos(SET_DMA, buffa);
		if ((bios(rw, 0) & 1) == 1)
			return(ERROR);

		/*  Bump track, if necessary  */
		if (++(*s) > 25) {
 			*s = 0;
			(*t)++;
		}
		buffa += 128;
	}
	bdos(SET_DMA, buff);
	seldsk(cpmdrive, NO_LOG);
	return(OK);
}

getdrive(s)  /*  get disk drive designation and validate  */
char *s;
{
	char c;

	for (;;) {  /*  until the dummy gets it right!  */
	  	printf("\n\nDrive for %s disk: (A - P) ", s);
		if ((c = toupper(getchar())) > 'P' || c < 'A')  
			eprint("Drive value out of range!");
		else
			return(c - 'A');
	}
}

yesno()   /*  ask for a response and return true for 'yes'  */
{
	char c;

	return(((c = toupper(getchar())) == 'Y') ? TRUE : FALSE);
}

eprint(s)  /*  Print error message, hold screen, and return error  */
char *s;
{
	printf("\n\007");
	rprintf(s);
	printf("\nHit <CR> to continue: ");
	getchar();
	bdos(INIT_BDOS);
	return(ERROR);
}


rprintf(s)   /*  Print in reverse video  */
char *s;
{
	printf(INTOREV);
	printf(s);
	printf(OUTAREV);
}

struct dph
*seldsk(dn, log)   /*  BIOS function to select drive and return dph */
char dn, log;
{
	unsigned *pbios;
	unsigned *psel_dsk;

	pbios = BIOS_LOC;
	psel_dsk = *pbios + 0x0019;
	return(call(*psel_dsk, dn, 0, dn, log));
}

block(blk, track, sect)   /*  translates UCSD block to logical track/sector  */
int blk, *track, *sect;
{
	int abssector;
	
	abssector = blk * 4;
	*track = (abssector / 26) + 1;
	*sect = abssector % 26;
}

	
	
map(secno, trkno)   /*  maps logical to physical sector  */
int secno, trkno;
{
	int s;
	
	if (secno > 12)
		s = ((secno * 2) + 1 + ((trkno-1) * 6 )) % 26;
	else 
		s = ((secno * 2) + ((trkno-1) * 6)) % 26;
	return(s);
}

readdir()   /*  read the directory on the UCSD disk   */
{
	int track, sect;
	char *alloc(), *dirbuf; 

	if ((dirbuf = alloc(DIRENTRIES * DIRENTSIZE)) == 0) {
		printf("Not enough memory -- aborting.\n");
		exit(ERROR);
	} 

	block(2, &track, &sect);   /*  2 is the directory block  */
	rwfor(&track, &sect, dirbuf, 4*4, READ);

	/* big kludge because no casts in BDS  */
	movmem(dirbuf, &volid, DIRENTSIZE);
	movmem(dirbuf + DIRENTSIZE, &dir[0], (DIRENTRIES - 1) * DIRENTSIZE);
	free(dirbuf);
}

printdir()  /*  print UCSD disk's directory  */
{
	int i;
	char *s;

	printf("Volume ID: %s\n", makestr(volid.dtitle));

	for (i = 0; i < volid.filesindir; i++) {
	   printf("%-14s\t%3d", makestr(dir[i].title),
		dir[i].lastblk - dir[i].firstblk);
	   printf("\t");
	   printdate(dir[i].moddate);
	   printf("\t");
	   switch(dir[i].kind) {  /*  Ain't BDS nice ? */
		case 0:  printf("Datafile"); break;
		case 1:  printf("Xdskfile"); break;
		case 2:  printf("Codefile"); break;
		case 3:  printf("Textfile"); break;
		case 4:  printf("Infofile"); break;
		case 5:  printf("Datafile"); break;
		case 6:  printf("Graffile"); break;
		case 7:  printf("Fotofile"); break;
		default: printf("Foofile"); break;
	   }
	   printf("\n");
	}
	printf("\n");	
}

char *
makestr(s)  /*  make a C string from UCSD variable string  */
char *s;
{
	int i;
	char *t;

	t = &string[0];
	for (i = 0;  i < s[0]; i++)
		t[i] = s[i+1];
	t[i] = '\0';
	return(&string[0]);
}

printdate(d) /*  prints a UCSD date record  */
char d[];
{

	int t1;

	/*
    	 *  The UCSD format is:
 	 *  
	 *  DATEREC = PACKED RECORD
	 *       MONTH: 0..12;
	 *       DAY:   0..31;
	 *       YEAR:  0..100
	 *  END;
	 *
	 *  This routine expects a char[2] array with the
	 *  information stored as above.
	 */

	t1 = (d[0] >> 4) | ((d[1] & 1) << 4);
	printf("%2d", t1);
	t1 = d[0] & 0x0f;
	printf("-");
	switch (t1) {  /*  because of no init in BDS  */
	   case 1:  printf("Jan"); break;
	   case 2:  printf("Feb"); break;
	   case 3:  printf("Mar"); break;
	   case 4:  printf("Apr"); break;
	   case 5:  printf("May"); break;
	   case 6:  printf("Jun"); break;
	   case 7:  printf("Jul"); break;
	   case 8:  printf("Aug"); break;
	   case 9:  printf("Sep"); break;
	   case 10: printf("Oct"); break;
	   case 11: printf("Nov"); break;
	   case 12: printf("Dec"); break;
	   default: printf("Foo"); break;
	}
	printf("-");
	t1 = d[1] >> 1;
	printf("%02d", t1);
}

getucsd()   /*  returns a ptr to dir entry if valid, else -1 */
{
	char temp[81];
	int i, j, l, found;


	gets(temp);
	
	/*  see if we can find it in dir  */
	for (i = 0; i < volid.filesindir; i++) {
		if ((l = strlen(temp)) != dir[i].title[0])
			continue;
		else {
			found = TRUE;
			for (j = 1; j <= l; j++) {
				if (toupper(temp[j-1]) != dir[i].title[j]){
					found = FALSE;
					break;
				}
			}
			if (found) return(i);
		}
	}
	return(-1);
}
