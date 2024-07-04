/*
 * Z80SIM  -  a Z80-CPU simulator
 *
 * Copyright (C) 1987,88,89,90 by Udo Munk
 *
 * History:
 * 28-SEP-87 Development on TARGON/35 with AT&T Unix System V.3
 * 14-MAR-89 new option -l
 * 23-DEC-90 Ported to COHERENT 3.0
 */

/*
 *      Dieses Modul enthaelt die Bedieneroberflaeche des
 *      Z80-CPU Simulators
 */

#include <stdio.h>
#if defined(COHERENT) && !defined(_I386)
#include <sys/fcntl.h>
#include <sgtty.h>
#else
#include <fcntl.h>
#include <termio.h>
#endif
#include "sim.h"
#include "simglb.h"

/*
 *      Die Funktion holt den CP/M-Boot-Loader aus dem ersten
 *      Sektor des simulierten Diskdrive A (Datei drivea.cpm) in
 *      das Z80-RAM ab Adresse 0, wenn die Option l beim Aufruf
 *      nicht angegeben wurde.
 *      Anschliessend wird die Z80-CPU-Simulation gestartet.
 */
mon()
{
	void perror();

	register int fd;
#if defined(COHERENT) && !defined(_I386)
	static struct sgttyb old_term, new_term;
#else
	static struct termio old_term, new_term;
#endif

	if (!l_flag) {
		if ((fd = open("disks/drivea.cpm", O_RDONLY)) == -1) {
			perror("file disks/drivea.cpm");
			return;
		}
		if (read(fd, (char *) ram, 128) != 128) {
			perror("file disks/drivea.cpm");
			return;
		}
		close(fd);
	}

#if defined(COHERENT) && !defined(_I386)
	gtty(0, &old_term);
	new_term = old_term;
	new_term.sg_flags |= CBREAK;
	new_term.sg_flags &= ~ECHO;
	stty(0, &new_term);
#else
	ioctl(0, TCGETA, &old_term);
	new_term = old_term;
	new_term.c_lflag &= ~(ICANON | ECHO);
	new_term.c_iflag &= ~(IXON | IXANY | IXOFF);
	new_term.c_iflag &= ~(IGNCR | ICRNL | INLCR);
	new_term.c_cc[4] = 1;
	ioctl(0, TCSETAW, &new_term);
#endif

	cpu_state = CONTIN_RUN;
	cpu_error = NONE;
	cpu();

#if defined(COHERENT) && !defined(_I386)
	stty(0, &old_term);
#else
	ioctl(0, TCSETA, &old_term);
#endif

	switch (cpu_error) {
	case NONE:
		break;
	case OPHALT:
		printf("HALT Op-Code reached at %04x\n", PC-ram-1);
		break;
	case IOTRAP:
		printf("I/O Trap at %04x\n", PC-ram);
		break;
	case OPTRAP1:
		printf("Op-code trap at %04x %02x\n", PC-1-ram, *(PC-1));
		break;
	case OPTRAP2:
		printf("Op-code trap at %04x %02x %02x\n", PC-2-ram,
		       *(PC-2), *(PC-1));
		break;
	case OPTRAP4:
		printf("Op-code trap at %04x %02x %02x %02x %02x\n",
		PC-4-ram, *(PC-4), *(PC-3), *(PC-2), *(PC-1));
		break;
	case USERINT:
		puts("User Interrupt");
		break;
	default:
		printf("Unknown error %d\n", cpu_error);
		break;
	}
}
