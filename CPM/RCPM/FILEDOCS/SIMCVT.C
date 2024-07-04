/******************************************************************************

Written by reynolds@sun.com                                     01/21/90

This SIMCVT.C filter should convert Simtel-20's "SIMIBM.IDX" file into a
readable "SIMIBM.LST" that is compatible with the other convert programs,
except for the run-date at the top of the output file.

This program, written in "C" should compile on both 4.3BSD Unix machines,
as well as IBM/pc compatible machines.  It works on both VAXen, and Suns.

To Compile on Unix, type "cc SIMCVT.C", and this should create "a.out"
To Compile on IBM/pcs, see your C manual that came with the compiler, and
change the first "c = getchar()" statement depending upon the EOL character.

To run on Unix machines, type    "cat SIMIBM.IDX | a.out > SIMIBM.LST"
To run on IBM/pcs machines, type "type SIMIBM.IDX | simcvt > SIMIBM.LST"

******************************************************************************/

#include <stdio.h>

main()

{
char  fs[10],dir[20],name[15],descr[60]; /* input variables */
int   rev,bits;                          /* input variables */
float length,date;                       /* input variables */
char  lfs[10],ldir[20];                  /* stores last filesystem/directory */
char  type;                              /* output variable for 'A' or 'B' */
char  c;                                 /* picks off EOF,",linefeed */

printf("WSMR-SIMTEL20.ARMY.MIL PUBLIC DOMAIN LISTING\n\n");
printf("NOTE: Type B is Binary; Type A is ASCII\n");

while (c != EOF)  {

   scanf("\"%[^\"]\",\"%[^\"]\",\"%[^\"]\",%i,%f,%i,%f,\"%[^\"]\"",
            fs, dir, name, &rev, &length, &bits, &date, descr);

   c = getchar(); /* remove the linefeed - ONLY NEEDED IN UNIX */ 
   c = getchar(); /* remove the ^M from the input line, and trap EOF */

   if (c != EOF) {

      type = 'B';                        /* Binary 8-bit */
      if (bits == 7) type = 'A';         /* ASCII  7-bit */

      if (strcmp(ldir,dir) || strcmp(lfs,fs)) {  /* New Directory */
         printf("\nDirectory %s%s\n",fs,dir);
         printf(" Filename   Type Length   Date    Description\n");
         printf("==============================================\n");
         strcpy(ldir, dir);          /* Remember last directory with ldir  */
         strcpy(lfs,fs);             /* Remember last file system with lfs */
         }                           /* End of the New Directory routine   */

      strcat(name, "            ");  /* fill out the filename to 12 spaces */

      printf("%12.12s  %c %7.0f  %6.0f  %s\n",name,type,length,date,descr);
      }
   }
} /* end of main() program by Ray */

/*****************************************************************************

   This filter takes data in the following format:
"PD1:","<MSDOS.ADA>","ADA-LRM2.ARC",1,320086,8,890411,"The Ada Language Reference Manual reader (2/4)"

   And converts it to the following format:
ADA-LRM1.ARC  B  231947  890411  The Ada Language Reference Manual reader (1/4)

*****************************************************************************/
