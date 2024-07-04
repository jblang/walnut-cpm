/*
 * CP/M 2.2 Formats a simulated Disk Drive
 *
 * Copyright (C) 1988-93 by Udo Munk
 *
 * History:
 * 29-APR-88 Development on TARGON/35 with AT&T Unix System V.3
 * 11-MAR-93 comments in english
 */

#include <stdio.h>
#ifndef COHERENT
#include <memory.h>
#endif

#define TRACK   77
#define SECTOR  26

/*
 *      This program is able to format the following disk formats:
 *
 *              drive A:        8" IBM SS,SD
 *              drive B:        8" IBM SS,SD
 *              drive C:        8" IBM SS,SD
 *              drive D:        8" IBM SS,SD
 */
main(argc, argv)
int argc;
char *argv[];
{
	void exit();
	register int i;
	register int fd;
	static unsigned char sector[128];
	static char fn[] = "../disks/drive?.cpm";
	static char usage[] = "usage: format a | b | c | d";

	i = *argv[1];
	if (argc != 2 || (i != 'a' && i != 'b' && i != 'c' && i != 'd')) {
		puts(usage);
		exit(1);
	}
	fn[14] = (char) i;
	memset((char *) sector, 0xe5, 128);
	fd = creat(fn, 0644);
	for (i = 0; i < TRACK * SECTOR; i++)
		write(fd, (char *) sector, 128);
	close(fd);
	exit(0);
}
