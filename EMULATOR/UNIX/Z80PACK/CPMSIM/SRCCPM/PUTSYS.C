/*
 * CP/M 2.2 writes the CP/M systemfiles to system tracks of drive A
 *
 * Copyright (C) 1988-93 by Udo Munk
 *
 * History:
 * 29-APR-88 Development on TARGON/35 with AT&T Unix System V.3
 * 11-MAR-93 comments in english and ported to COHERENT 4.0
 */

#include <stdio.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#else
#include <fcntl.h>
#endif
#ifndef COHERENT
#include <memory.h>
#endif

/*
 *	This program writes the CP/M 2.2 OS from the following files
 *	onto the system tracks of the boot disk (drivea.cpm):
 *
 *      boot loader             boot.bin   (Mostek binary format)
 *      CCP                     cpm.bin    (Mostek binary format)
 *      BDOS                    cpm.bin    (Mostek binary format)
 *      BIOS                    bios.bin   (Mostek binary format)
 */
main()
{
	unsigned char header[3];
	unsigned char sector[128];
	register int i;
	int fd, drivea, readed;
	void exit(), perror();
	long lseek();

	/* open drive A for writing */
	if ((drivea = open("../disks/drivea.cpm", O_WRONLY)) == -1) {
		perror("file ../disks/drivea.cpm");
		exit(1);
	}
	/* open boot loader (boot.bin) for reading */
	if ((fd = open("boot.bin", O_RDONLY)) == -1) {
		perror("file boot.bin");
		exit(1);
	}
	/* read and check 3 byte header */
	if ((readed = read(fd, (char *) header, 3)) != 3) {
		perror("file boot.bin");
		exit(1);
	}
	if (header[0] != 0xff || header[1] != 0 || header[2] != 0) {
		puts("start adress of boot.bin <> 0");
		exit(0);
	}
	/* read boot loader */
	memset((char *) sector, 0, 128);
	read(fd, (char *) sector, 128);
	close(fd);
	/* and write it to disk in drive A */
	write(drivea, (char *) sector, 128);
	/* open CP/M system file (cpm.bin) for reading */
	if ((fd = open("cpm.bin", O_RDONLY)) == -1) {
		perror("file cpm.bin");
		exit(1);
	}
	/* read and check 3 byte header */
	if ((readed = read(fd, (char *) header, 3)) != 3) {
		perror("file cpm.bin");
		exit(1);
	}
	if (header[0] != 0xff) {
		puts("unknown format of cpm.bin");
		exit(0);
	}
	/* position to CCP in cpm.bin */
	lseek(fd, (long) 19 * 128 + 3, 0);
	/* read CCP and BDOS from cpm.bin and write them to disk in drive A */
	for (i = 0; i < 44; i++) {
		if ((readed = read(fd, (char *) sector, 128)) != 128) {
			perror("file cpm.bin");
			exit(1);
		}
		write(drivea, (char *) sector, 128);
	}
	close(fd);
	/* open BIOS (bios.bin) for reading */
	if ((fd = open("bios.bin", O_RDONLY)) == -1) {
		perror("file bios.bin");
		exit(1);
	}
	/* read and check 3 byte header */
	if ((readed = read(fd, (char *) header, 3)) != 3) {
		perror("file bios.bin");
		exit(1);
	}
	if (header[0] != 0xff) {
		puts("unknown format of bios.bin");
		exit(0);
	}
	/* read BIOS from bios.bin and write it to disk in drive A */
	while ((readed = read(fd, (char *) sector, 128)) == 128)
		write(drivea, (char *) sector, 128);
	if (readed > 0)
		write(drivea, (char *) sector, 128);
	close(fd);
	close(drivea);
}
