/*
 * Receive a file out of the named pipe "auxout" from CP/M simulation
 *
 * Copyright (C) 1988-93 by Udo Munk
 *
 * History:
 * 05-OKT-88 Development on TARGON/35 with AT&T Unix System V.3
 * 11-MAR-93 comments in english and ported to COHERENT 4.0
 */

#include <stdio.h>
#include <signal.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#else
#include <fcntl.h>
#endif

int fdin, fdout;

main(argc, argv)
int argc;
char *argv[];
{
	char c;
	void exit(), perror(), int_handler();

	if (argc != 2) {
		puts("usage: receive filname &");
		exit(1);
	}
	if ((fdin = open("auxout", O_RDONLY)) == -1) {
		perror("pipe auxout");
		exit(1);
	}
	if ((fdout = creat(argv[1], 0644)) == -1) {
		perror(argv[1]);
		exit(1);
	}

	signal(SIGINT, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);
	signal(SIGHUP, int_handler);

	for (;;) {
		if (read(fdin, &c, 1) == 1)
			if (c != '\r')
				write(fdout, &c, 1);
	}
}

void int_handler()
{
	close(fdin);
	close(fdout);
	exit(0);
}
