/*
 * Sends a file through named pipe "auxin" to the CP/M simulation
 *
 * Copyright (C) 1988 by Udo Munk
 *
 * History:
 * 05-OKT-88 Development on TARGON/35 with AT&T Unix System V.3
 * 11-MAR-93 comments in english and ported to COHERENT 4.0
 */

#include <stdio.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#else
#include <fcntl.h>
#endif

char buf[BUFSIZ];
char cr = '\r';
int fdout, fdin;
void exit(), perror();

main(argc,argv)
int argc;
char *argv[];
{
	register int readed;

	if (argc != 2) {
		puts("usage: send filname &");
		exit(1);
	}
	if ((fdin = open(argv[1], O_RDONLY)) == -1) {
		perror(argv[1]);
		exit(1);
	}
	if ((fdout = open("auxin", O_WRONLY)) == -1) {
		perror("pipe auxin");
		exit(1);
	}
	while ((readed = read(fdin, buf, BUFSIZ)) == BUFSIZ)
		sendbuf(BUFSIZ);
	if (readed)
		sendbuf(readed);
	close(fdin);
	close(fdout);
	exit(0);
}

sendbuf(size)
register int size;
{
	register char *s = buf;

	while (s - buf < size) {
		if (*s == '\n')
			write(fdout, (char *) &cr, 1);
		write(fdout, s++, 1);
	}
}
