/*

   LMODEM.C -- Little MODEM program 
                                      
   Byte, Nov. 1983, pages 410-28                       
                                                                             
   This program implements the Ward Christensen assembly-language           
   program in C.  It is derived from the cmodem13.c program                 
   by Jack M. Wierda and Roderick W. Hart.  The modes available have         
   been greatly reduced.  The program provides terminal emulation           
   and text capture as well as file send and receive capabilities.          
                                                                             
   Hardware-dependent functions have been isolated from the                 
   majority of the program.                                                 
                                                                             
   Written by David D. Clark                                                
   9-Jan-83                                                                 
  
   Adapted to the KayPro II and Software Toolworks' (C/80 V. 3.0) 
   C compiler by Lee R. Bradley

   To compile and assemble with AS.COM, use the following:
                                                    
   A>C -C2500 -D800 B:LMODEM.ASM=LMODEM.C
   A>AS B:LMODEM.COM=B:LMODEM.ASM                     

   Incorporated dynamic allocation of buffer space.  Used ideas in Clark's 
   version 2. 

   To compile, assemble and link with M80 and L80, use the following commands 

   A>C -C2500 -D800 -M1 B:LMODEM.MAC=LMODEM.C
   A>M80 B:LMODEM.REL=B:LMODEM.MAC             
   A>L80 B:LMODEM,STDLIB,CLIBRARY,B:LMODEM/N/E

*/

#include "printf.h"
#include "printf.c"
#include "scanf.h"
#include "scanf.c"

#define    DOTS            50        /* sector counting dots per line */
#define    SPS             12000     /* loops per second  */
#define    SECSIZ          0x80
#define    DATAMASK        0x7f
#define    BUFSECS         128       /* number of file sectors to buffer */
#define    BLKSIZ          16384     /* size of blocks written (1 extent) */
#define    ERRORMAX        10        /* maximum errors before abort */
#define    RETRYMAX        5         /* maximum retrys before abort */
#define    DIRCTIO         6         /* cpm bdos direct-console io command */
#define    INPUT           0xff      /* direct-console io input */
#define    FALSE           0
#define    TRUE            1         /* lrb */
#define    NULL            0         /* lrb */

/***************************************************************************/
/*                                                                         */
/*   Special characters used in the file transfer-protocol.                */
/*                                                                         */
/***************************************************************************/

#define      TIMEOUT  -1   /* timeout character  */
#define      SOH      1    /* start of sector character */
#define      EOT      4    /* end of transmission character  */
#define      ACK      6    /* acknowledge sector transmission */
#define      NAK      21   /* error in transmission detected */

/****************************************************************************/
/*                                                                          */
/*   Miscellaneous ASCII characters                                         */
/*                                                                          */
/****************************************************************************/

#define    TAB             9
#define    LF             10
#define    CR             13
#define    CTRLZ          26  /* end of text-file character */

/****************************************************************************/
/*                                                                          */
/*    These #defines determine which keys will be interpreted as            */
/*    command characters.                                                   */
/*                                                                          */
/****************************************************************************/

#define      CTRLB   2
#define      CTRLE   5
#define      CTRLK   11
#define      CTRLL   12
#define      CTRLQ   17
#define      CTRLR   18
#define      CTRLS   19
#define      CTRLT   20
#define      CTRLV   22

#define      SETBAUD   CTRLB   /* set baudrate */
#define      CAPTURE   CTRLT   /* toggle text capture */
#define      HELP      CTRLE   /* get instructions */
#define      KEEP      CTRLK   /* keep text buffer  */
#define      LITERAL   CTRLL   /* send literal character */
#define      QUIT      CTRLQ   /* quit */
#define      RECEIVE   CTRLR   /* receive file by sectors  */
#define      SEND      CTRLS   /* send file by sectors */
#define      VIEW      CTRLV   /* view data transfered  */

char ViewMode, BFlag, KbData, ModData;
char AsciiFlg, ShowTrans, ShowRec, View;
char *Bufr;
char FileName[14];
int Fd;
unsigned BufSiz,BufPtr;

char *baudrate;
extern char Cmode;

main(argc, argv)
int argc;
char **argv;
{

   Cmode = 0;
   AsciiFlg = ShowRecv = ShowTrans = BFlag = View = FALSE;
   BufPtr = 0;
   BufSiz=0x7f80;                     /*  make sure this isn't too big !! */
   ViewMode = KbData = NULL;
   if ((Bufr = alloc(BufSiz)) == 0) {
      printf("Can't allocate the buffer\n");
      exit();
      }

   instruct();
   initializemodem();

   while (ctsready() && (KbData != QUIT)) {
      if (KbData = bdos(DIRCTIO, INPUT)) /* get any char at kbd */
         switch (KbData) {

         case SETBAUD:
            printf("\nEnter 1 for 300, 2 for 1200 or 3 for 2400 baud.\n");
            switch (getchar())
               { case '1': baud(5); baudrate = "300"; break; 
                 case '2': baud(7); baudrate = "1200"; break; 
                 case '3': baud(10); baudrate = "2400"; 
               }
            printf("\nBaud rate set at %s bps.\n", baudrate);
            break;

         case HELP:
            instruct();
            break;

         case CAPTURE:
            BFlag = ~BFlag;
            if (BFlag)
               printf("Capture initiated");
            else
               printf("Capture terminated");
            printf(", %u", BufSiz - BufPtr);
            printf(" bytes free\n");
            break;

         case KEEP:
            if (!BufPtr)
               printf("Nothing to save\n");
            else {
               printf("Save as what file? ");
               scanf("%s", FileName);
               Bufr[BufPtr] = CTRLZ;
               Fd = fopen(FileName,"w");
               if (Fd == NULL)
                 printf("Cannot create %s\n",
                     FileName);
               else {
                  write(Fd, Bufr,
                     (BufPtr/SECSIZ+1)*SECSIZ);
                  fclose(Fd);
                  BFlag = FALSE;
                  BufPtr = 0;
               }
            }
            break;

         case RECEIVE:
            printf("Receive what file? ");
            scanf("%s", FileName);
            readfile(FileName);
            break;

         case SEND:
            printf("Send what file? ");
            scanf("%s", FileName);
            sendfile(FileName);
            break;

         case QUIT:
            hangup();
            break;

         case VIEW:
            View = ~View;
            if (View) {
               printf("View as Ascii or Hex? ");
               ViewMode = toupper(getchar());
               printf("\nDisplay will be in ");
               if (ViewMode == 'A')
                    printf("Ascii\n");
               else
                  printf("Hex\n");
            }
            else
               printf("Viewing disabled\n");
            break;

         case LITERAL:
            while ( !(KbData = bdos(DIRCTIO, INPUT)) );
                  mcharout(KbData);
                  break;

         default:
            mcharout(KbData);
            break;
         }

      if (minprdy()) {
         ModData = mcharinp();
         if (BFlag && (BufPtr < BufSiz))
            Bufr[BufPtr++] = ModData;
         else if   (BFlag)
            printf("Capture Bufr overflow\n");
         putchar(ModData);
      }
   }
}   

instruct()
{
   printf("\n\nLMODEM.C, 5/21/86");
   printf("\nDavid D. Clark, Byte, Nov. '83, pages 410-428");
   printf("\n");
   printf("\nAdapted to C/80 \n");
   printf("Lee R. Bradley, Mouse House Software\n");
   printf("\n");
   printf("LMODEM.C is a small remote communication program.\n");
   printf("When started it acts simply as a dumb terminal. \n");
   printf("The following commands are available:\n\n");

   printf("Press RETURN to continue\n");
   getchar();

   show_char(SETBAUD);
   printf("\t- Set baudrate.  \n");

   show_char(CAPTURE);
   printf("\t- Toggles text capture.  Initially inactive.  When\n");
   printf("\t  acting as a terminal, all text received will be\n");
   printf("\t  saved in a buffer.  The buffer may be saved on disk\n");
   printf("\t  with the 'keep' command below.\n");

   show_char(HELP);
   printf("\t- Help on the commands.  In case you forget what\n");
   printf("\t  you are reading right now, type ctrl-E and you will\n");
   printf("\t  be told what commands do what.\n");

   show_char(KEEP);
   printf("\t- Keep.  Lets you save captured text in a diskfile. \n");
   printf("\t  You will be asked to name the file in which the text\n");
   printf("\t  will be saved.  The text buffer will be cleared if the\n");
   printf("\t  text is saved successfully.\n");

   show_char(RECEIVE);
   printf("\t- Receive file in Ward Christensen protocol.  You will\n");
   printf("\t  be asked for the name of the file to write into.\n");

   show_char(SEND);
   printf("\t- Send file in Ward Christensen protocol.\n");

   show_char(VIEW);
   printf("\t- Toggle data viewing.  Initially inactive.  Data \n");
   printf("\t  transmitted will be displayed in Ascii or Hex.\n");

   show_char(LITERAL);
   printf("\t- Send literal character.  A character typed after this\n");
   printf("\t  character will be sent as is.  In this way, characters\n");
   printf("\t  that represent commands may be sent without being\n");
   printf("\t  interpreted as a command.\n");

   show_char(QUIT);
   printf("\t- Quit.  Exit program.\n\n");

   return;

}
show_char(c)
char c;
{
   if ((c>= 0) && (c<= 31))
      printf("ctrl-%c", c + '@');
   else if (c == ' ')
      printf("<spc>");
   else if ((c >='@') && (c <= '~'))
      putchar(c);
   else if (c == 127)
      printf("<del>");
   else
      printf("%xH", c);
   return;
}

readfile(file)
char *file;
{
   int firstchar, sectnum, sectcurr, sectcomp, errors;
   int checksum;
   int errorflag;
   unsigned j, bufptr;

   if (View) {
      ShowRecv = TRUE;
      ShowTrans = FALSE;
   }

   Fd = fopen(file,"w");
   if (Fd == 0) {
      printf("Cannot create %s\n", file);
      return;
   }
   else
      printf("Receiving %s\n\n", file);
   sectnum = errors = bufptr = 0;
   initializemodem();
   sendchar(NAK);
   do {
      errorflag = FALSE;
      do {                /* get synchronization character */
         firstchar = readchar(5);
      } while (    firstchar != SOH
                && firstchar != EOT
                && firstchar != TIMEOUT);
      if (firstchar == TIMEOUT) {
         errorflag = TRUE;
         printf("Timeout error\n");
      }
      if (firstchar == SOH) {        /* main if */
         sectcurr = readchar(1);
         sectcomp = readchar(1);
         if ((sectcurr + sectcomp) == -1) {
            if ((sectcurr & 0xff) == (sectnum + 1 & 0xff)) { /* lrb */
               checksum = 0;
               if (ViewMode == 'A')
                  AsciiFlg = TRUE;
               for (j = bufptr; j < (bufptr + SECSIZ); j++) {
                    Bufr[j] = readchar(1);
                    checksum = (checksum + Bufr[j]) & 0xff;
               }
               AsciiFlg = FALSE;
               if ((checksum & 0xff) == (readchar(1) & 0xff)) {	/* lrb */
                  errors = 0;
                  sectnum++;
                  bufptr += SECSIZ;
                  if ((sectnum % BUFSECS) == 0) {
                     bufptr = 0;
                     if (write(Fd, Bufr, BLKSIZ) == NULL) {
                        printf("Error writing file\n");
                        fclose(Fd);
                        return;
                     }
                     do ; 
                     while (readchar(1) != TIMEOUT);
                  }
                  if (!ShowRecv)
                     if (((sectnum - 1 ) % DOTS) ==0)
                        printf("\n<%4d>.", sectnum);
                     else
                        printf(".");
                  sendchar(ACK);
               }
               else {
                  printf("\nChecksum error, expected ");
                  printf("<%0x>\n", checksum);
                  errorflag = TRUE;
               }	/*  This is a comment  */
           }   
           else 
              if ((sectcurr & 0xff) == (sectnum & 0xff)) {  /* lrb */ 
                 printf("\nReceived duplicate sector %d\n", sectnum);
                 /* wait for silence on the line */
                 do ;  /* nothing */
                 while (readchar(1) != TIMEOUT);
                 sendchar(ACK);
              }
              else {
                 printf("\nSynchronization error\n");
                 errorflag = TRUE;
              }
          }
          else {
             printf("\nSector number error\n");
             errorflag = TRUE;
          }
      }  /* end of main if.   This right brace was missing from Byte */ 

      if (errorflag == TRUE) {
         errors++;
         printf("Error %d\n", errors);
         while (readchar(1) != TIMEOUT);
         sendchar(NAK);
      }

   }  while (firstchar != EOT && errors != ERRORMAX);
    
   if ((firstchar == EOT) && (errors < ERRORMAX)) {
      sendchar(ACK);
      write(Fd, Bufr, bufptr);
      fclose(Fd);
      printf("\n\nTransfer complete\n");
   }
   else
      printf("\n\nAborting\n");
}


readchar (seconds)
unsigned seconds;
{
   char data;
   seconds = seconds*SPS;
   while (!minprdy() && seconds)  /* wait until input ready */
      --seconds;
   if (!seconds)
      return(TIMEOUT);            /* nothing arrived in time */
   data = mcharinp();             /* get it */
   if (ShowRecv) {                /* show if needed */
      if (AsciiFlg)
         if (((data >= ' ') && (data <= DATAMASK))
             || data == LF || data == CR || data == TAB)
            putchar(data);
         else
            printf("[%0x]", data);
      else
         printf("[%0x]", data);
   }
   return data;
}

sendfile(file)
char *file;
{
   int sectnum, sectors, attempts;
   int checksum;
   unsigned j, bufptr;

   if (View) {
      ShowRecv = FALSE;
      ShowTrans = TRUE;
   }
   Fd = fopen(file, "r");
   if (Fd == NULL) {
      printf("Cannot open %s\n", file);
      return;
   }
   else
      printf("Sending %s\n\n", file);
   initializemodem();
   attempts = 0;
   sectnum = 1;

   while ((sectors = read(Fd, Bufr, BufSiz)) && (attempts != RETRYMAX)) {
      if (sectors == NULL) {
         printf("\nError reading file\n");
         fclose(Fd);
         return;
      }
      else {
         sectors = sectors / SECSIZ + 1;
         bufptr = 0;
         do {
            attempts = 0;
            do {
               if (!ShowTrans)
                  if (((sectnum - 1) % DOTS) == 0)
                     printf("\n<%4d>.", sectnum);
                  else
                     printf(".");
               sendchar(SOH);
               sendchar(sectnum);
               sendchar(~sectnum);
               checksum = 0;
               if (ViewMode = 'A')
                  AsciiFlg = TRUE;
               for (j= bufptr; j < (bufptr + SECSIZ); j++) {
                  sendchar(Bufr[j]);
                  checksum = (checksum + Bufr[j]) & 0xff;
               }
               AsciiFlg = FALSE;
               sendchar(checksum);
               purgeline();
               attempts++;
            } while ((readchar(10) != ACK) && 
                      (attempts != RETRYMAX));
            bufptr += SECSIZ;
            sectnum++;
            sectors--;
         } while (sectors && (attempts != RETRYMAX));
      }
   }

   if (attempts == RETRYMAX)
      printf("\nNo acknowledgement of sector, aborting\n");
   else {
      attempts = 0;
      do {
         sendchar(EOT);
         purgeline();
         attempts++;
      } while ((readchar(10) != ACK) && (attempts != RETRYMAX));
      if (attempts == RETRYMAX) {
         printf("\nNo acknowledgement of end of file");
         printf(", aborting\n");
      }
      else 
         printf("\nTransfer complete\n");
   }
   fclose(Fd);
   return;
}

sendchar(data)
char data;
{
   while (!moutrdy());           /* wait until output ready */
   
   mcharout(data);               /* send it */
 
   if (ShowTrans) {              /* show it, if needed */
      if (AsciiFlg)
         if (((data >= ' ') && (data <= DATAMASK))
             || data == LF || data == CR || data == TAB)
            putchar(data);
         else
            printf("[%0x]", data);
      else
         printf("[%0x]", data);
   }
   return;
}

/* Hardware dependent code */

#define     BAUDRATE    0
#define     DATAPORT    4
#define     STATUSPORT  6
#define     DAV   1
#define     TBE   4

initializemodem()
{
   purgeline();               /* minimal code */
}

purgeline()
{
   while (minprdy())           /* while there are characters ... */
      mcharinp();                   /* gobble them */
}

mcharinp()
{
   char c;

   while (!minprdy());   /* do nothing until ready */
   c = rx();             /* get data  */
   return c;
}

mcharout(c)
char c;
{
   while (!moutrdy());    /* do nothing until ready */
   tx(c);                 /* put data */
}

int rx()
{
#asm
   IN  DATAPORT           ; get data from port
   MVI  H,0
   MOV  L,A   
#endasm
}
   
minprdy()
{                         /* returns 0 or 1 if (un)ready */
#asm
   IN  STATUSPORT
   ANI  DAV
   MVI  H,0
   MOV  L,A    
   RZ
   MVI  L,1 
#endasm
}

moutrdy()
{                         /* returns 0 of 1 if (un)ready */
#asm
   IN  STATUSPORT
   ANI  TBE
   MVI  H,0
   MOV  L,A
   RZ
   MVI  L,1
#endasm
}

int tx(c)
char c;
{
#asm
   POP  H
   POP  D
   PUSH  D
   PUSH  H
   MOV   A,E
   OUT   DATAPORT
#endasm
}

int baud(c)
char c;
{
#asm
   POP  H
   POP  D
   PUSH  D
   PUSH  H
   MOV   A,E
   OUT   BAUDRATE
#endasm
}
ctsready()
{
   return TRUE;
}

hangup()
{
   return TRUE;           /* nothing to do */
}

#include "stdlib.c"

}
ctsready()
{
   return TRUE;
}

hangup()
{
   return TRUE;           /* noth