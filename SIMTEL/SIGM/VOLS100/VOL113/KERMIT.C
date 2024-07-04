
/*@ptxt[This is a minimal version of Kermit written in C.  It has many
limitations, but does most of what is necessary.  It has no SET commands, no
command parser, does only ASCII file transmission (no eight-@|bit or @q<.EXE>
files) and some system-@|dependent routines are not filled in (like
@q<gnxtfl()> for multiple sends), and does not implement any of the server
functions.  This is intended mainly as an example, but it also demonstrates how
a minimal version can be implemented.  Any command parser that will parse the
four basic commands would be sufficient.
  @Section<Symbols and Global Variables>
 These are all the global variables and definitions.] */


#include "c:stdio.h"

#define	maxpack	94		/* Maximum packet size */

#define	SOH	1		/* Start of header */
#define	SP	32		/* ASCII space */
#define	CR	13		/* Carriage return */
#define	DEL	127		/* Delete (rubout) */

#define	maxtry	5		/* Times to retry a packet */

#define	myquote	'#'		/* Quote character I will use */
#define	mypad	0		/* Number of padding characters I need */
#define	mypchar	0		/* Padding character I need */
#define	myeol	CR		/* End-Of-Line character I need */
#define mytime	10		/* Seconds after which I should be timed out */

/* Declarations of global variables:  */

int
 size,				/* Size of present data */
 n,				/* Message number */
 rpsiz,				/* Maximum receive packet size */
 spsiz,				/* Maximum send packet size */
 pad,				/* How much padding to send */
 timint,			/* Timeout for foreign host on sends */
 numtry,			/* Times this packet retried */
 oldtry;			/* Times previous packet retried */

char
 state,				/* Present state of the automaton */
 padchar,			/* Padding character to send */
 eol,				/* End-Of-Line to send */
 quote,				/* Quote character in incoming data */
 filnam[50],			/* The file name */
 recpkt[maxpack],		/* Receive packet buffer */
 packet[maxpack];		/* Packet buffer */

FILE *fptr;			/* File pointer

@End<ProgramExample>
@Section<Command Parsing>
@Index[Parsing Commands]@Index[Prompt]
 The parsing depends upon the capabilities of the host, but the
following syntax is recommended for uniformity:
The prompt should be "@q{Kermit-XXX>}" where @q<XXX> denotes the
implementation, e.g. "@q{Kermit-20>}", "@q{Kermit-80>}", etc.  It's important
to have distinct prompts to avoid confusion while the user talks to two
different Kermits from the same terminal.

Commands should be a keyword followed by arguments.  Optional arguments
are shown in square brackets.

@SubSection<Required Commands>
@begin<example>
SEND <filename or filegroup>
RECEIVE [<filename>]
HELP
EXIT
?
@end<example>
"@q<?>" should simply list the commands or arguments possible at that point.

File specifications conform to the requirements of the specific system.
Most systems allow the specification of a file group by the inclusion of
special "wildcard" or pattern-matching characters in the file
specification.  A list of files, or file groups, may also be allowed.

For SEND or RECEIVE, parse and store the file (group) name.
If RECEIVE, the file name is optional, since it can be built from
the name provided in the file header sent by the foreign host.
Including a file name on the receive command implies that the user wants to
store the file under a different name than it was sent with.  This could be
useful if the two hosts have different file name formats, but should not be
done when receiving file groups.

HELP types a help message at the terminal, EXIT terminates execution of
Kermit.

@SubSection<Optional Commands>
@begin<example>
@tabclear()@tabdivide(3)
SET <parameter>@\@i(e.g. padding, packet size, etc.)
SHOW <parameter>@\@i(anything that can be SET)
STATUS@\@i(e.g. of connection) 
CONNECT@\@i(to remote host)
SERVER@\@i(act as a server)
PROMPT@\@i(run interactively)
QUIT@\@i(equivalent to) EXIT
 @end<example>

@Index[Virtual Terminal]@Index[Connect]@Index[Escape Character]
 CONNECT establishes a "virtual terminal" connection to the remote
host.  It is mainly useful on microcomputers with serial i/o ports
which can be plugged in as terminals to the remote host.  An escape
mechanism must be provided to get the user back to the local host;
preferably a two-@|character sequence, in which the first character
(normally control-@|rightbracket) gets the attention of the local host and
the second tells it what to do, for example:
 @begin<description,spread 0,leftmargin +4,indent -4>
@q<C>@\Close the connection, return to local host.

@q<S>@\Show the status of the connection.

@q<B>@\Send a BREAK character.

@q<^]>@\Send a control-rightbracket (or whatever the escape character is).

@q<X>@\Go into extended command mode, e.g. allowing SET commands.

@q<?>@\List the available options
 @end<description>

@Index[Set]
SET should allow establishment of any system-@|dependent parameters.
Here is the suggested syntax:

@begin<Example,group>
    | SEND    |  | PACKET-LENGTH <d> |
SET |         |  | PADDING <d>       |
    | RECEIVE |  | PADCHAR <o>       |
                 | TIMEOUT <d>       |
                 | END-OF-LINE <o>   |
                 | QUOTE <c>         |

    | DEBUGGING    |  | ON  |
    | FILE-WARNING |  | OFF |
    | LOCAL-ECHO   |

    LINE <n>
    ESCAPE <o>
    DELAY <d>
@end<Example>
 where @q(<d>) is a decimal number in the range 0-94, @q(<o>) is an octal
number (0-37), @q(<c>) is a single printable character, and @q(<n>) is a
number in whatever radix the system expresses terminal numbers
in@foot<Some systems might have other ways of identifying
communication lines, such as character strings.>.  The
LINE specification would let Kermit communicate over another terminal port
on the same system, rather than its own controlling terminal.

The following SET parameters are recommended for an implementation of
Kermit that wants to be completely general, i.e. to communicate with as
many different machines as possible:
 @begin<description>
@Index[Packet-Length]
PACKET-LENGTH@\The maximum packet length for either outgoing or incoming
packets.  The maximum packet size can be no bigger than 96 (decimal),
but may have to be smaller than that if the host has trouble buffering
packets of that size (especially at higher baud rates).

@Index[Timeout]
TIMEOUT@\Specify the timeout interval for the outgoing (SEND) and incoming
(RECEIVE) Kermits.

@Index[Padding] 
PADDING@\The user should be able to specify the padding on outgoing
packets (so the first send-init packet can get through) and on
incoming packets (so the local Kermit can inform the remote Kermit of
its own padding requirements).  The argument specifies the number of pad
characters with which to precede each packet.

PADCHAR@\The character to use for padding.  This should default to NUL,
but some systems want others; e.g. IBM uses DEL.

@Index[End-Of-Line (EOL)]
END-OF-LINE@\The user should be able to specify the line terminator for
outgoing packets, so the first @q<send-init> packet can get through.  If the
user knows that the remote Kermit will use a different terminator than the
one the local Kermit expects, then that can be set too, though the
appropriate default should be hardwired into the program and sent to the
remote Kermit in the @q<send-init> packet.

@Index[Quote] 
QUOTE@\The user might need to change the quote character on outgoing
packets in case the default quote character is causing problems at the
other end.

@Index[Eight-Bit-Quote]
EIGHT-BIT-QUOTE@\The character to be used for quoting bytes with the 8th bit
set, for systems that cannot transmit or receive 8-bit ASCII.

@Index[Escape Character] 
ESCAPE@\If a CONNECT command is provided, this allows the default escape
character (Control-@q<]>) to be replaced by the one specified.

@Index[Local-Echo]
LOCAL-ECHO@\For CONNECTing to a half-@|duplex host.

@Index[Parity]
PARITY@\Specify parity on outgoing packets -- NONE, SPACE, MARK, EVEN, or ODD.
If NONE, then the 8th bit can be used for data; all the others usurp the 8th
bit.  If other than NONE, the parity bit is ignored on incoming characters.

@Index[IBM-Mode]
IBM-MODE@\For communicating with an IBM mainframe.  Makes the
local Kermit wait for the half duplex line to turn around (i.e.@ wait for the
receipt of an XON character), and has the local Kermit always send whatever
parity the IBM front ends insist upon.

@Index[Delay] 
DELAY@\Allow the user to specify a delay before sending the @q<send-init>
packet.  If the remote Kermit is sending, this gives the user time to
get back and start up the local receiving Kermit in time to catch the
first incoming packet.

@Index[File-Warning]
FILE-WARNING@\When receiving files, allow the user to elect whether to
be warned if a filename conflict will occur, i.e. if Kermit is about
to receive a file that has the same name as one already on the disk.
If the user elects to be warned, Kermit should allow the user to
specify new names when conflicts arise.

@Index[Debugging] 
DEBUGGING@\Allow the user to see packets as they go by, to receive extra
informative and error messages, and to have some extra controls over the
operation of the program.
 @end<description>
 @Begin<ProgramExample>
 @Section<Main>
/*@ptxt[This is the main routine.  It should parse for the parameters
   specified in the previous section and call the appropriate
   routine (@q<sendsw> for send and @q<recsw> for receive.)]  */

main ()

{
    if(sendsw() == FALSE) printf("Sending failed\n");
	else printf("Sending suceeded\n");
}

/*@ptxt[The main routine is left to the future implementer to fill in.]
@End<ProgramExample>
@Section<Send-switch>
@Begin<ProgramExample>
/*@ptxt[Sendsw is the state table switcher for sending files.  It loops
   until either it is finished or an error is encountered.  The
   routines called by sendsw are responsible for changing the state.]
*/

sendsw ()

{
    state = 'S';		/* Send initiate is the start state */
    n = 0;			/* Initialize message number */
    numtry = 0;			/* Say no tries yet */
    while (TRUE)			/* Do this for as long as necessary */
    {
	printf("State: %c\n",state);	/* Temp for testing */
	switch (state)
	{
	    case 'D':  state = sdata(); break;	/* Data-Send state */
	    case 'F':  state = sfile(); break;	/* File-Send */
	    case 'Z':  state = seof(); break;	/* End-of-File */
	    case 'S':  state = sinit(); break;	/* Send-Init */
	    case 'B':  state = sbreak(); break;	/* Break-Send */
	    case 'C':  return(TRUE);		/* Complete */
	    case 'A':  return(FALSE);		/* Abort */
	    default:   return(FALSE);		/* Unknown, abort */
	}
    }
}						/* Finished.
@End<ProgramExample>
@SubSection<send-init>
@Begin<ProgramExample>

/*@ptxt[This routine initializes the connection with the foreign host.
   sinit is the prototype for all packet sending routines.  It calls  
   spack to send a correctly formatted Send-Initiate packet with
   the necessary data for initialization (packet size, timeouts, etc).
   The foreign host will ACK with a packet containing its own init
   data: how long a packet it can handle, when to time it out, etc.  A
   dumb host can ignore the timeout data; hopefully the other host is
   smart and can handle the timeouts.  If any of the following occur,
   numtry is incremented and the routine returns without changing
   state (this will happen at most maxtry times after which the state
   changes to Abort):
@begin(itemize,spread 0)
   A bad packet (@q<rpack> returns FALSE);

   A NAK is received;

   The wrong ACK is received.
@end(itemize)
   If the foreign host ACKs correctly, the values for packet size,
   etc, should be taken from its ACK packet and the state changed to
   Send-File (F).]
*/

char sinit ()

{
    int num, len;			/* Local variables */

printf("sinit\n");
    if (numtry++ > maxtry) return('A');	/* If too many tries, abort */
    spar(packet);			/* Fill up with init info */
    spack('S',n,6,packet);		/* Send an 'S' packet, */
    switch (rpack(&len,&num,recpkt))	/* What was the reply? */
    {
/* NAK */
	case 'N':
	    if (n != num--) return(state);	/* NAK: fail */
					/* If NAK for next pack its like ACK

/* ACKnowlegement */
	case 'Y':
	{
	    if (n != num) return(state);	/* If wrong ACK, fail */
	    rpar(recpkt);			/* Get the init info */
	    if (eol == 0) eol = '\n';		/* Check and set defaults */
	    if (quote == 0) quote = '#';
	    numtry = 0;				/* reset try counter, */
	    n = (n + 1) % 64;			/* and bump packet count */
	    fptr = fopen(filnam,"r");		/* Open the file to read */
	    if (fptr < 0) return('A');          /* Abort if can't */
	    return('F');			/* Switch state to 'F' */
	}
	case FALSE:  return(state);		/* Receive failure: fail */
	default:     return('A');		/* Just "Abort" */
    }
}						/* Return
@End<ProgramExample>
@SubSection<send-file>
@Begin<ProgramExample>

/*@ptxt[This routine is almost the same as sinit except the data field
   contains the name of the file being sent.  It reacts the same way
   on all packets received except when a correct ACK is received.  In
   that case the state is changed to 'D' (data send) and bufill is
   called to fill up the buffer to send to the foreign host.] */

char sfile ()

{
    int num, len;			/* Local variables */

    if (numtry++ > maxtry) return('A');	/* If too many tries, abort */
    for(len=0;filnam[len] != '\0';len++);	/* Count the length */
    len++;
    spack('F',n,len,filnam);		/* Send an 'F' packet, */
    switch (rpack(&len,&num,recpkt))	/* What was the reply? */
    {
/* NAK */
	case 'N':
	    if (n != num--) return(state);	/* NAK: fail */
					/* If NAK for next pack it's
					  like ACK, fall through
/* ACKnowlegement */
	case 'Y':
	{
	    if (n != num) return(state);	/* If wrong ACK, fail */
	    numtry = 0;				/* Reset try counter, */
	    n = (n + 1) % 64;			/* and bump packet count */
	    size = bufill(packet);		/* Get the data from file */
	    return('D');			/* Switch state to 'D' */
	}
	case FALSE:  return(state);		/* Receive failure: fail */
	default:     return('A')		/* Just "Abort" */;
    }
}						/* Return
@End<ProgramExample>
@SubSection<send-data>
@Begin<ProgramExample>

/*@ptxt[Another similar routine.  It sends a data packet containing the
   contents of the data buffer.  On ACK it does the same as sfile.
   When bufill returns EOF the state changes to 'Z' (EOF send).] */

char sdata ()

{
    int num, len;			/* Local variables */

    if (numtry++ > maxtry) return('A');	/* If too many tries, abort */
    spack('D',n,size,packet);		/* Send an 'D' packet, */
    switch (rpack(&len,&num,recpkt))	/* What was the reply? */
    {
/* NAK */
	case 'N':
	    if (n != num--) return(state);	/* NAK: fail */
					/* If NAK for next pack it's
					  like ACK, fall through

/* ACKnowlegement */
	case 'Y':
	{
	    if (n != num) return(state);	/* If wrong ACK, fail */
	    numtry = 0;				/* Reset try counter, */
	    n = (n + 1) % 64;			/* and bump packet count */
	    if ((size = bufill(packet)) == EOF) return('Z');
			/* Get the data from file; if EOF set state to it */
	    return('D');			/* Switch state to 'D' */
	}
	case FALSE:  return(state);		/* Receive failure: fail */
	default:     return('A')		/* Just "Abort" */;
    }
}						/* Return
@End<ProgramExample>
@SubSection<send-EOF>
@Begin<ProgramExample>

/*@ptxt[Sends an End-Of-File packet.  On ACK it calls gnxtfl.  If that
   succeeds the state becomes 'F' (file send) again.  If it fails the
   state becomes 'B' (break connection).]
*/

char seof ()

{
    int num, len;			/* Local variables */

    if (numtry++ > maxtry) return('A');	/* If too many tries, abort */
    spack('Z',n,0,packet);		/* Send an 'Z' packet, */
    switch (rpack(&len,&num,recpkt))	/* What was the reply? */
    {
/* NAK */
	case 'N':
	    if (n != num--) return(state);	/* NAK: fail */
					/* If NAK for next pack it's
					  like ACK, fall through

/* ACKnowlegement */
	case 'Y':
	{
	    if (n != num) return(state);	/* If wrong ACK, fail */
	    numtry = 0;				/* Reset try counter, */
	    n = (n + 1) % 64;			/* and bump packet count */
	    if (gnxtfl() == EOF) return('B');	/* No more files go to Break */
	    return('F');			/* Switch state to 'F' */
	}
	case FALSE:  return(state);		/* Receive failure: fail */
	default:     return('A')		/* Just "Abort" */;
    }
}						/* Return
@End<ProgramExample>

@SubSection<send-EOT>
@Begin<ProgramExample>
/*@ptxt[Sends a Break (End Of Transmission) packet.  On ACK the state
   becomes 'C' (complete).]
*/

char sbreak ()

{
    int num, len;			/* Local variables */

    if (numtry++ > maxtry) return('A');	/* If too many tries, abort */
    spack('B',n,0,packet);		/* Send an 'B' packet, */
    switch (rpack(&len,&num,recpkt))	/* What was the reply? */
    {
/* NAK */
	case 'N':
	    if (n != num--) return(state);	/* NAK: fail */
					/* If NAK for next pack it's
					  like ACK, fall through

/* ACKnowlegement */
	case 'Y':
	{
	    if (n != num) return(state);	/* If wrong ACK, fail */
	    numtry = 0;				/* Reset try counter, */
	    n = (n + 1) % 64;			/* and bump packet count */
	    return('C');			/* Switch state to 'C' */
	}
	case FALSE:  return(state);		/* Receive failure: fail */
	default:     return('A')		/* Just "Abort" */;
    }
}						/* Return
@End<ProgramExample>
@Section<I/O routines>
@Begin<ProgramExample>

/*@ptxt[The following routines deal with the building, sending and
   receiving of packets as well as the manipulation of files.
   Their low level I/O routines tend to be system dependent.
   The use of a high-level language such as C tends to insulate
   the programmer from this.]
@End<ProgramExample>
@SubSection<Send-packet>
@Begin<ProgramExample>

/*@ptxt[This routine builds and sends the packet according to the
   specifications it is passed.  It computes the checksum.  The
   packet is sent the best way the machine will allow.  It
   assumes that any control characters in the data buffer are
   already quoted, and the count includes the quote characters.

   Packet format (all numbers in octal):]
@begin<verbatim,group>
   @u<Field>          @ux<Chars Allowed>  @u<Length>    @u<Description>
   start of packet  001-037        1       001 by definition
   character count  040-176        1       0 to 136 + SP
   message number   040-137        1       modulo 100 + SP
   message type     040-176        1       mnemonic (see below)
   data             040-176     count-3    0 to 132 chars
   checksum         040-137        1       (sum+((sum & 300)/100) & 77

   Mnemonics for message type:

     D      data packet
     Y      acknowledge
     N      negative acknowledge
     S      send initiate
     B      break transmission
     F      file header
     Z      end of file
     E      error
@end<verbatim>
*/

spack (type,num,len,data)

char type, data[];
int num, len;

{
    int i;
    char chksum;			/* Local variables

/* Initialize some parameters */

printf("spack\n");
    for(i=1;i<=pad;i++) fputc(padchar,stdout);	/* Issue necessary padding */
    fputc(SOH,stdout);			/* Packet marker, ASCII 1 (SOH)*/
    chksum = tochar(len+3);		/* Initialize the checksum */
    fputc(tochar(len+3),stdout);	/* Send the character count */
    chksum = chksum + tochar(num);	/* Init checksum */
    fputc(tochar(num),stdout);		/* Packet number */
    chksum = chksum + type;
    fputc(type,stdout);			/* Packet type


/* Loop for all data characters */

    for(i=0;i<len;i++)
    {
	fputc(data[i],stdout);
	chksum = chksum+data[i];
    }
    chksum = (chksum + (chksum & 192) / 64) & 63;
    fputc(tochar(chksum),stdout);	/* Checksum */
    fputc(eol,stdout);			/* Extra-packet line terminator */
}

/*@ptxt[A system that could only do record (line) output would deposit each
   character into a buffer and then send the buffer.]
@End<ProgramExample>
@SubSection<Receive-packet>
@Begin<ProgramExample>

/*@ptxt[This is a routine which does the opposite of Send-packet. It
   waits for characters to arrive from the foreign host.  Upon
   receiving a SOH character it starts interpreting the ensuing
   characters depending on their position and value.

   If it encounters another SOH before it comes to the end of the
   packet it starts over with the new SOH as the beginning of the
   packet.  If the packet is invalid in any way (bad checksum, invalid
   message number, etc.)  the routine returns FALSE.  If the packet is
   valid its type, message number, length of data and pointer to data
   are set in in the appropriate global variables.]
*/

rpack (len,num,data)

int *len, *num;
char *data;

{
    int i, fld;
    char chksum, t, type;		/* Local variables

printf("\nrpack\n");			/* For testing purposes */
    chksum = 0;				/* Initialize checksum */
    t = 0;				/* Initialize input char value */
    while ((t=fgetc(stdin)) != SOH);	/* Wait for packet header

/* Got one, loop for each field */
    for (fld=1;fld<=5;fld++)
    {
	if(fld != 5 || i != 0)		/* Don't get char on no data packets */
	    if((t=fgetc(stdin)) == SOH) fld = 0;	/* Resynch if SOH */
	if(fld <= 3) chksum = chksum + t;	/* Accumulate checksum */
printf("case: %d, checksum: %d\n",fld,chksum);
	switch (fld)
	{
	    case 0:  chksum = 0; break;		/* Restart loop */
	    case 1:  *len = unchar(t)-3; break;	/* Character count */
	    case 2:  *num = unchar(t); break;	/* Packet number */
	    case 3:  type = t; break;		/* Packet type */
	    case 4:  for(i=0;i<*len;i++)
	    {
		if(i != 0)
		    if((t=fgetc(stdin)) == SOH) /* Get a char */
		    {
			fld = -1;
			break;
		    }
		chksum = chksum + t;	 	/* Add it to the checksum */
printf("i: %d, checksum: %d\n",i,chksum);
		data[i] = t;			/* Normal character */
	    }
		     break;
	    case 5:  chksum = (chksum + (chksum & 192) / 64) & 63;
		     break;
	}
    }						/* We now have all the chars

/* Check the checksum */
    if(chksum != unchar(t))
    {
	printf("Bad checksum: %c, should be: %c\n",t,tochar(chksum));
	return(FALSE);
    }
    return(type);				/* Return packet type */
}

/*@ptxt[A system that has only line or record input would get the line into
   an intermediate buffer and then pick it apart character by
   character.]
@End<ProgramExample>
@SubSection<Buffer-fill>
@Begin<ProgramExample>

/*@ptxt[Bufill gets the characters from the file fptr.  The characters are 
   put into the buffer and any quoting of control characters is done
   here.  As many characters as possible should be put into buffer,
   but the buffer must not be longer than the receiving Kermit's buffer
   size; spsiz minus 5.  The count of characters includes the quoting
   characters.  When EOF is encountered as many characters as are left
   should be put in the buffer.  The next time this routine is called
   it should return failure to indicate EOF.

   All control characters (0-37 and 177) in the data field are
   substituted by a quote character followed by the control character
   plus 100 modulo 200, i.e. the result of transforming the character
   via the ctl function.  The quote character is '#' by default, but
   can be any value 41-76 or 140-176 specified by the host, though for
   efficiency it should be a seldom used character.  Transmission of
   the quote character itself is obtained by quoting it with itself.

   The number of characters put into the buffer is returned.]
*/

bufill (buffer)

char buffer[];

{
    int i, t;				/* Local variables */

    i = 0;				/* Init data buffer pointer */
    while ((t = fgetc(fptr)) != EOF)	/* Get the next character */
    {
	t = t & 0177;			/* Strip parity */
	if(t < SP || t == DEL || t == quote)
	{
	    buffer[i++] = quote;
	    if(t != quote) t = ctl(t);
	}
	buffer[i++] = t;
	if(i >= spsiz-6) return(i);
    }
    if(i == 0) return(EOF);	/* Wind up here only on EOF */
    return(i);
}				/* So the partial buffer isn't lost
@End<ProgramExample>
@SubSection<Buffer-empty>
@Begin<ProgramExample>

/*@ptxt[This is a system dependent routine that takes the characters from
   the buffer and writes them to the file.  The ACK for the packet
   containing the characters should not be given until the characters
   are written.  If there is an error writing the file, particulary of
   the "disk full" or "quota exceeded" type, send an appropriate error
   packet (if a remote Kermit) and then a Break packet to terminate
   transmission.]
*/

bufemp (buffer,filptr,len)

char buffer[];
FILE *filptr;
int len;

{
    int i, t;

    for(i=0;i<len;i++)
    {
	t = buffer[i];
	if(t == myquote)		 /* Handle quoted chars */
	{
	    t = buffer[++i];		 /* Get the quoted char */
	    if(t != myquote) t = ctl(t); /* De-controlify the char */
	}
	fputc(t,filptr);		 /* Put the char in the file */
    }
}					 /* Return
@End<ProgramExample>
@SubSection<Get-file>
@Begin<ProgramExample>

/*@ptxt[This routine gets a file to output data to.  If the user specified
   a file name in the RECEIVE command, that file is used.  If not, the
   information in data supplied by the foreign host is used,
   transformed if necessary to construct a legal file name.  If the
   SET FILE-WARNING feature has been implemented and the user has
   specified that it should be used, that name is looked up on the
   disk to see if a file of that name already exists, and if so the
   file is given another name and the user is informed of the new
   name.  This command is not implemented in this version.  The file
   is opened for output, and fptr becomes the file pointer for that file.
]
*/

getfil (filenm)

char *filenm;

{
    if(filenm[0] == '\0') fptr = fopen(packet,"w");
	else fptr = fopen(filenm,"w");
}
/* If user didn't specify a file use the one from other host. 
@End<ProgramExample>
@SubSection<Get-next-file>
@Begin<ProgramExample>

/*@ptxt[This routine gets the next file in a file group if there is one.
   If not it returns EOF.  In this implementation we only allow single
   file transmission, so this routine always returns EOF.]
*/

gnxtfl ()

{
    return(EOF);
}			/* Don't do anything
@End<ProgramExample>
@Section<Receive-switch>
@Begin<ProgramExample>

/*@ptxt[This routine is another state table switcher, like sendsw.
   It loops until it is finished or an error is encountered.
   The routines called by this one are responsible for changing
   the state.]
*/

recsw ()

{
    state = 'R';		/* Receive is the start state */
    n = 0;			/* Initialize message number */
    numtry = 0;			/* Say no tries yet */
    while (TRUE) switch (state)	/* Do this for as long as necessary */
    {
	case 'D':  state = rdata(); break;	/* Data receive state */
	case 'F':  state = rfile(); break;	/* File receive state */
	case 'R':  state = rinit(); break;	/* Send initiate state */
	case 'C':  return(TRUE);		/* Complete state */
	case 'A':  return(FALSE);		/* Abort state */
	default:   return(FALSE);		/* Unknown state, abort */
    }
}						/* Finished.
@End<ProgramExample>

@SubSection<Receive-init>
@Begin<ProgramExample>
/*@ptxt[This routine initializes the connection with the foreign host.  It
   waits for the foreign host to initiatate the connection.  Upon
   receipt of a send-initiate packet it sets its variables to what the
   foreign host requested and calls spack to send an ACK packet with
   the necessary data for initialization (packet size and time outs).
   The state is then set to 'F' (File-receive).  If the packet
   received is not a send initiate the state goes to abort.  If a
   packet (receive-packet returns FALSE) is received the state is not
   changed.]
*/

rinit ()

{
    int len, num;			/* Local variables */

    if(numtry++ > maxtry) return('A');	/* "Abort" if too many tries */
    switch (rpack(&len,&num,packet))	/* Get a packet */
    {

	case 'S':			/* Send-Init - Get parameters */
	{
	    n = num;			/* Synchronize packet numbers */
	    rpar(packet);		/* Get the init data */
	    spar(packet);		/* Fill up packet with init info */
	    spack('Y',n,6,packet);	/* ACK with my parameters */
	    oldtry = numtry;		/* Save old try count */
	    numtry = 0;			/* And start a new counter */
	    n = (n + 1) % 64;		/* Bump packet number */
	    return('F');		/* OK, now enter File-Send state */
	}

	case FALSE:  return(state);	/* Oops, we didn't receive a packet */
	default:     return('A');	/* Unknown type, "Abort" */
    }
}					/* Return
@End<ProgramExample>
@SubSection<Receive-file>
@Begin<ProgramExample>

/*@ptxt[The rest of the receive routines are similar to this one.  If the
   expected packet is received (in this case an 'F' packet with the
   correct message number) the packet is ACKed and the state changed
   (in this case to 'D', Data-receive).

   In this routine, if no file name was specified by the user the one
   supplied by the foreign host in the 'F' packet is used to build one.
   If the packet is an 'S' or 'Z' packet with the
   previous message number, the routine ACKs the previous packet again
   and returns without changing state.  If a 'B' is received then
   there are no more files and the state goes to 'C'.  If any other
   packet is received the state goes to "Abort".]
*/

char rfile ()

{
    int num, len;

    if(numtry++ > maxtry) return('A');	/* "Abort" if too many tries */
    switch (rpack(&len,&num,packet))	/* Get a packet */
    {
/* Send-Init */
	case 'S':
	{
	    if(oldtry++ > maxtry) return('A');	/* If too many tries */
	    if(num == n - 1)			/* Check packet number */
	    {
		spar(packet);			/* Get the init params */
		spack('Y',num,6,packet);	/* It's right, ACK it */
		numtry = 0;			/* Reset try counter */
		return(state);
	    }
	    else return('A');			/* Sorry, wrong number */
	}					/*

/* End-of-File */
	case 'Z':
	{
	    if(oldtry++ > maxtry) return('A');
	    if(num == n - 1)			/* Acknowledge good packet */
	    {
		spack('Y',num,0,0);
		numtry = 0;
		return(state);
	    }
	    else return('A');			/* or "Abort" on bad one */
	}					/*

/* File-Header */
	case 'F':
	{
	    if(num != n) return('A');
	    getfil(packet);			/* Open the file */
	    spack('Y',n,0,0);			/* Acknowledge */
	    oldtry = numtry;
	    numtry = 0;
	    n = (n + 1) % 64;
	    return('D');			/* Switch to data state */
	}					/*

/* Break transmission */
	case 'B':
	{
	    if(num != n) return('A');
	    spack('Y',n,0,0);			/* Say OK */
	    return('C');			/* and go to Complete state */
	}
	case FALSE:  return(state);
	default:     return('A');
    }
}						/* Return
@End<ProgramExample>
@SubSection<Receive-data>
@Begin<ProgramExample>

/*@ptxt[This routine is almost the same as Rfile except that it must take
   into account that its previous state could have been either 'F' or
   'D'.  If packets of either type with the previous message number
   are received the previous packet is again acknowledged.  Also if
   the packet is a 'Z' (end of file) the packet is ACKed, any
   necessary file closing is done and the state becomes 'F'.  If a
   data packet is received, bufemp is called to write the characters
   into the target file.  To prevent losing packets while writing, the
   packet should not be ACKed until the characters are written out.]
*/

char rdata ()

{
    int num, len;

    if(numtry++ > maxtry) return('A');	/* "Abort" if too many tries */
    switch (rpack(&len,&num,packet))	/* Get a packet */
    {

/* Data */
	case 'D':
	{
	    if(num != n)		/* Right packet? */
	    {				/* No */
		if(oldtry++ > maxtry) return('A'); /* If too many tries */
		if(num == n - 1)		/* Check packet num */
		{
		    spack('Y',num,0,0);		/* It's right, ACK it */
		    numtry = 0;			/* Reset try counter */
		    return(state);
		}
		else return('A');		/* Sorry, wrong number */
	    }					/*

/* Data with right packet number */
	    bufemp(packet,fptr,len);		/* Write out the packet */
	    spack('Y',n,0,0);			/* Right packet, acknowledge */
	    oldtry = numtry;
	    numtry = 0;
	    n = (n + 1) % 64;
	    return('D');			/* Remain in data state */
	}					/*

/* File-Send */
	case 'F':
	{
	    if(oldtry++ > maxtry) return('A');
	    if(num == n - 1)			/* Acknowledge good packet */
	    {
		spack('Y',num,0,0);
		numtry = 0;
		return(state);
	    }
	    else return('A');			/* or "Abort" on bad one */
	}					/*

/* End-of-File */
	case 'Z':
	{
	    if(num != n) return('A');
	    spack('Y',n,0,0);			/* Say OK */
	    close(fptr);			/* Close up the file */	    
	    return('F');			/* and go to File state */
	}
	case FALSE:  return(state);
	default:     return('A');
    }
}						/* Return
@End<ProgramExample>
@Section<Utility Routines>
@Begin<ProgramExample>

/*@ptxt[Converts a control character to a printable one by adding a space.] */

char tochar (ch)

char ch;

{
    return(ch + ' ');		/* Make sure not a control char */
}

/* Undoes tochar. */

char unchar (ch)

char ch;

{
    return(ch - ' ');		/* Restore char */
}

/*@ptxt[Turns a control character into a printable character by toggling
   the @i<control> bit (i.e. ^A becomes A and A becomes ^A.)]
*/

char ctl (ch)

char ch;

{
    return(ch ^ 64);		/* Toggle the "Control" bit */
}				/*


/*@ptxt[Fill the array data with the appropriate Send-init parameters.] */

spar (data)

char data[];

{
printf("spar\n");
    data[0] = tochar(maxpack);		/* Biggest packet I can receive */
    data[1] = tochar(mytime);		/* When I want to be timed out */
    data[2] = tochar(mypad);		/* How much padding I need */
    data[3] = ctl(mypchar);		/* Padding character I want */
    data[4] = tochar(myeol);		/* End-Of-Line character I want */
    data[5] = myquote;			/* Quote character I send */
}					/*


/*@ptxt[Get the other host's Send-init parameters.] */

rpar (data)

char data[];

{
printf("rpar\n");
    spsiz = unchar(data[0]);		/* Maximum send packet size */
    timint = unchar(data[1]);		/* When I should time out */
    pad = unchar(data[2]);		/* Number of pads to send */
    padchar = ctl(data[3]);		/* Padding character to send */
    eol = unchar(data[4]);		/* EOL character I must send */
    quote = data[5];			/* Incoming data quote character */
}
