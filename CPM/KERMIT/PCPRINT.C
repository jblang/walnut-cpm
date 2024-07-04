/* pcprint.c -- Print files on a printer which is locally attached to a DEC 
 * VT102, VT200, VT300, or compatible, or to a PC that emulates them (e.g. IBM 
 * PC with Kermit 2.31 or later).
 *
 * Usage:
 *   command | pcprint
 *   pcprint < file
 *   pcprint file(s)
 * and in MM, "set print-filter pcprint", then use MM's "print" command.
 *
 * "pcprint" allows printing of text files and binary files with no parity.
 * To do this, the terminal has to be put in "raw mode", in which none of its
 * other functions work.  Therefore, the terminal is periodically restored to
 * normal so that it can be interrupted with Ctrl-C, do Xon/Xoff, etc.
 *
 * Authors: Christine Gianone and Frank da Cruz, CUCCA, March 14, 1989
 */

/* Preprocessor includes and defines */

#include <stdio.h>			/* Standard i/o */
#include <sgtty.h>			/* Set/Get terminal modes */
#include <signal.h>			/* For keyboard interrupts */
#include <sys/types.h>			/* For stat.h... */
#include <sys/stat.h>			/* For file status queries */
#define BUFL 1000			/* Input buffer length */

/* Global Declarations */

static struct sgttyb old, new;		/* Terminal modes structure */
static struct stat statbuf;		/* File status structure */
int fd;					/* Input file descriptor */
int doexit();				/* Forward declaration of doexit() */

/* Main function */

main(argc,argv) int argc; char *argv[]; {
    int nf;				/* File number from command line. */
    int x;				/* Temporary variable. */

/* Find out the current terminal settings from Unix */

    gtty(1,&old);			/* For restoring tty to how it was. */
    gtty(1,&new);			/* Plus a new copy, */
    new.sg_flags |= RAW;		/* for putting tty in "raw mode" */
					/* to allow 8-bit data output */
					/* with no parity. */

/* Send the ANSI "begin transparent print" sequence, "ESC [ 5 i".  This */
/* makes the terminal send its input to the printer instead of the screen. */

    printf("%c[5i",'\033');		/* Print the escape sequence. */
    fflush(stdout);			/* Make sure it goes out */
					/* before we change tty modes. */

/* Since programs can be halted by users typing Ctrl-C or other keyboard */
/* interrupt characters, we must catch these interrupts in order to restore */
/* the terminal to normal (non-printing, non-raw) mode before exiting. */

    signal(SIGINT,doexit);		/* Control-C */
    signal(SIGQUIT,doexit);		/* Control-\ */

/* Input can either be from standard input (redirected stdin, pipe, or MM */
/* PRINT command), or else from a list of files given on the command line. */

/* Case 1: Print from Standard Input, e.g. "pcprint < test.txt". */

    if (argc == 1) {			/* If printing from standard input */
	fd = 0;				/* File descriptor 0 = stdin */
	dofile();			/* Print until no more data */
	doexit();			/* Done */
    }

/* Case 2: Filename(s) specified on command line, e.g. "pcprint x.a x.b". */
/* Each file must be opened, printed, & closed.  Skip over directory files. */

    nf = 0;				/* Current file number. */
    while (++nf < argc) {		/* Start with file 1, if any .*/
	if (stat(argv[nf],&statbuf) < 0) /* First see if the file exists. */
	  continue;			/* Doesn't exist, try next one. */
	x = statbuf.st_mode & S_IFMT;	/* Check file format. */
	if ((x != 0) && (x != S_IFREG))	/* If not a regular file, */
	  continue;			/* try the next file. */
	if ((fd = open(argv[nf]),0) < 0) /* Try to open the file read-only. */
	  continue;			/* On failure, try next file. */
	dofile();			/* Opened OK, call printing function */
	close(fd);			/* and after printing close the file */
    }
    doexit();				/* No more files, clean up and exit. */
}

/* Function to print one file */

dofile() {
    char buf[BUFL];			/* Input buffer */
    int i;				/* Input buffer counter */
    int n;				/* Input character EOF indicator */
    char c;				/* Input character itself */
    int done;				/* Flag for done */

    done = 0;				/* Initial condition for loop. */
    while (!done) {			/* While not done... */
	stty(1,&old);			/* Put terminal in normal mode */
					/* to catch terminal interrupts. */
	for (i = 0; i < BUFL-1; i++) {  /* Loop to fill the input buffer. */
	    n = read(fd,&c,1);		/* Read one character. */
	    if (n == 0) {		/* If no more, */
		done = 1;		/* we're done! */
		break;			/* Break out of this for-loop. */
	    }
	    if (c == '\n') 		/* If character is a newline, */
	      buf[i++] = '\r';		/* supply a carriage return. */
	    buf[i] = c;			/* Deposit character in buffer. */
	}
	stty(1,&new);			/* Put tty in raw (no-parity) mode. */
	write(1,buf,i);			/* Request UNIX write the buffer. */
	fflush(stdout);			/* Now make UNIX really do it. */
    }
}

/* Exit function.  Leave user's terminal the way it was upon entry. */
/* Turn off transparent print by sending the escape sequence "ESC [ 4 i". */

doexit() {				/* Program exit. */
    if (fd != 0) close(fd);		/* Close any open input file. */
    signal(SIGINT,SIG_DFL);		/* Return keyboard interrupts */
    signal(SIGQUIT,SIG_DFL);		/* to normal. */
    printf("%c[4i",'\033');		/* Turn off transparent print. */
    fflush(stdout);			/* Make sure it goes out. */
    stty(1,&old);			/* Restore terminal to normal. */
    exit(0);				/* And exit. */
}
