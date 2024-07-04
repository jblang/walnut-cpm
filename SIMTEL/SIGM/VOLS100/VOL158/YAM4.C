/*
>>:yam4.c 9-6-83
 *
 * Support for Compuserve CIS A protocol
 * file-upload and file-download functions
 * called from term() when ascii SI is received.
 *
 * It seems that the CIS protocol isn't quite as simple as YAM4.C
 * was lead to beleive! 1) The SI and SO may have the high-order
 * bit on, as SI and SO without the high order bit on are used to
 * control external network echoing. 2) If you R FILTRN, then a
 * "redundant" SI is issued when FILTRN transfers control to
 * XFTRAN without sending an SO. 3) Sometimes CIS ends a transfer
 * without any SO at all, just starts sending (with a blank).
 * 5) The fixes therein allow downloading from Micro-quote
 * via TymNet.  DAVID WELCH
 */

#define EXTERN extern
#include "yamc86.h"

FLAG CISasc;			/* CIS xfer is in ascii mode */
char ciscursec;		/* Sector number just received by cisgetsec() */

cispa()
{
	register char *p;

	for(;;) {
		switch( firstch=readline(400)) {
		  case ESC:
			switch(firstch=readline(400)) {
			case 'I':
				pstat("CIS-IDENT");
				p = MYSYSTEM;
				while( *p)
					sendline( *p++);
				continue;
			case 'A':
				if(cisxfer() != ERROR)
					continue;
				sendline(NAK); return ERROR;
			default:
				break;
			}
		default:
			lprintf("Bad CIS request 0%o\n", firstch);
			return ERROR;
		case '\n':
		case SO:
		case (SO | 0x80):
		case ' ':
			return OK;
		case SI:
		case (SI | 0x80):
			break;
		}
	}
}

/*
 * get file request from host and perform the transfer
 */
cisxfer()
{
	char *p;
	CISasc = FALSE;
	if(cisgetsec(Utility.ubuf, (PATHLEN+3)) <= 0)
		return ERROR;
	if(p=index('\r', Utility.ubuf))
		*p = 0;
	CISasc = (Utility.ubuf[1] == 'A');

	if(Utility.ubuf[0] == 'U') {
		if(opentx( &Utility.ubuf[2]) == ERROR)
			return ERROR;
		sendline('.');
		if(readline(400) != '.'  ||  sendcis() == ERROR) {
			closetx(FALSE); return ERROR;
		}
		closetx(TRUE); return OK;
	}
	else if(Utility.ubuf[0] == 'D') {
		if(openrx( &Utility.ubuf[2]) == ERROR) {
			return ERROR;
		}
		sendline('.');
		return getcis();
	}
	else
		return ERROR;
}

sendcis()
{
	unsigned nchars;

	nchars=0;
	while((wcj=filbcis(Utility.ubuf)) > 0) {
		pstat("Char %u", nchars);
		if(scisrec(Utility.ubuf, wcj)==ERROR)
			return ERROR;
		nchars += wcj;
	}
	return scisrec(0,0);	/* send special EOT record */
}

/*
 * fill p with at most 256 chars not incl EOF
 * returns number of chars fetched, 0 for end of file
 */
filbcis(p)
char *p;
{
	int c;
	int count;
	for( count=0; count< 256; ++count) {
		if((c=getc(fin)) == EOF)
			break;
		if(CISasc && c == CPMEOF) {
			ungetc(CPMEOF, fin); break;
		}
		*p++ =c;
	}
	return count;
}
/*
 * send a record at buf with length len to CIS
 * return ERROR if unsuccessful
 * Special case: len==0 causes EOT record to be sent
 * 		 instead of buffer contents
 */
scisrec( buf, len)
char *buf;
{
	char *p;
	int count;
	int retry;
	if( ++ciscursec > '9')
		ciscursec = '0';
	for(retry = 5; --retry; ++toterrs) {
		p = buf; sendline(SOH);
		sendline(oldcrc=ciscursec);
		if(len==0) {
			sendline(firstch=EOT);
			ucksum();
		} else
			for(count=len; --count >=0;) {
				firstch = *p++ & 0377;
				ucksum();
				sendmsk(firstch);
				if(CISasc)
					putcty(firstch);
			}
		sendline(ETX);
		sendmsk(oldcrc);
		if((firstch=readline(400)) == '.')
			return OK;
		if (CISasc)
			lprintf("\n");
		lprintf("Got 0%o for record ACK\n", firstch);
		if(firstch < 0)
			return ERROR;
	}
	return ERROR;
}

/*
 * send most control charsacters as DLE sequence
 * except for BEL to CR inclusive
 */
sendmsk(c)
unsigned c;
{
	c &= 0377;		/* in case of sign extension */
	if( c < 7 || (c < 0x20 && c > 0x0D)) {
		sendline(DLE);
		sendline(c | 0x40);
	}
	else
		sendline(c);
}

/*
 * get (download) a file with CIS A protocol
 */
getcis()
{
	char cursec;
	char *p;
	unsigned nchars;

	cursec = '1'; nchars=0;
	for(;;) {
		pstat("Char %u", nchars);
doagain:
		if((wcj=cisgetsec(Utility.ubuf, KSIZE)) <= 0)
			break;
		if(ciscursec==EOT)
			break;
		if(ciscursec == cursec) {
			sendline('.');
			goto doagain;
		}
		if(ciscursec == cursec+1 ||
		  (cursec == '9' && ciscursec == '0') ) {
			nchars += wcj;
			for(p=Utility.ubuf; --wcj >= 0; )
				fputc( *p++, fout);
			if( ++cursec > '9')
				cursec = '0';
			sendline('.');
		}
		else {
			if (CISasc)
				lprintf("\n");
			lprintf("Got record 0%o expecting 0%o\n",
			  ciscursec, cursec);
			break;
		}
	}
	lprintf("%u Characters Received ", nchars);
	if(ciscursec != EOT) {
		closerx(TRUE);	return ERROR;
	}
	if(CISasc)
		fputc(CPMEOF, fout);
	closerx(FALSE); sendline('.'); return OK;
}
/*
 * gets a CIS A protocol record into buf.  Record number returned in global
 * ciscursec, which equals EOT for EOT record (end of file).  Returns number
 * of characters read.  Returns ERROR if too many chars received.
 * no retry count; it is assumed that sender will send NAK to abort
 * (will abort on timeout)
 * The acknowledge is NOT sent by cisgetsec; the caller must send a '.'
 * when it is ready to proceed.
 */
cisgetsec(buf, maxcount)
char *buf;
{
	char *p;
	int count;

reread:
	for(;;) {
		if((firstch=readline(400)) == SOH)
			break;
		if(firstch==TIMEOUT)
			return ERROR;
		if(firstch==NAK)
			return ERROR;
	}
	ciscursec = oldcrc = readline(400);
	for(p=buf, count=0; ;) {
		switch(firstch=readline(400)) {
		case TIMEOUT:
			  return ERROR;
		case NAK:
			return ERROR;
		case ETX:
			if((firstch=readline(400))==TIMEOUT)
				return ERROR;
			if(firstch==DLE) {
				if((firstch=readline(400))==TIMEOUT)
					return ERROR;
				firstch &= 037;
			}
			if(firstch == oldcrc)
				return count;
			if (CISasc)
				lprintf("\n");
			lprintf("Error Checksum=0%o Got 0%o \n",
			  oldcrc, firstch);
			++toterrs; sendline('/'); goto reread;
		case EOT:
			ciscursec = EOT; break;
		case DLE:
			if((firstch=readline(400))==TIMEOUT)
				return ERROR;
			firstch &= 037;
		}
		if(++count > maxcount)
			return ERROR;
		*p++ = firstch;
		if(CISasc)
			putcty(firstch);
		ucksum();
	}
}
/*
 * ucksum updates oldcrc with firstch
 * CIS uses rotate left, NOT shift left as per protocol.cis
 */
ucksum()
{
	oldcrc += oldcrc;
	if(oldcrc & 0400)
		++oldcrc;
	if( (oldcrc = (oldcrc & 0377) + firstch) & 0400)
		++oldcrc;
	oldcrc &= 0377;
}
