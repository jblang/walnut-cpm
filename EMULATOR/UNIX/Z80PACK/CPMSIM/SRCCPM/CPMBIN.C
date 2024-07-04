/*
 * CP/M 2.2 Converts an CP/M kernel to Mostek binary format
 *
 * Copyright (C) 1990-93 by Udo Munk
 *
 * History:
 * 23-DEZ-90 Development with Coherent 3.0
 * 11-MAR-93 comments in english and ported to COHERENT 4.0
 */

#include <stdio.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#else
#include <fcntl.h>
#endif

/*
 *	This program converts a CPMxx.COM file, which was created
 *	with MOVCPM, into a Mostek binary, that can be written to
 *	the system tracks of the boot disk with putsys.
 */


char buf[128];

main(argc, argv)
int argc;
char *argv[];
{
	int in, out;

	if (argc != 2) {
		puts("usage: cpmbin infile");
		exit(1);
	}

	if ((in = open(argv[1], O_RDONLY)) == -1) {
		perror(argv[1]);
		exit(2);
	}

	if (creat("cpm.bin", 0644) == -1) {
		perror("cpm.bin");
		exit(3);
	}

	if ((out = open("cpm.bin", O_WRONLY)) == -1) {
		perror("cpm.bin");
		exit(4);
	}

	memset(buf, 0, 128);
	buf[0] = 0xff;
	write(out, buf, 3);
	buf[0] = 0x00;
	write(out, buf, 128);
	write(out, buf, 128);
	while (read(in, buf, 128) != 0)
		write(out, buf, 128);

	close(out);
	close(in);
	exit(0);
}
