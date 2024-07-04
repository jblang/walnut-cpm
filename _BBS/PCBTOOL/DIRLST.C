/*
 * build pcboard dir.lst
 */


// xxx two trailing \\'s.

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#if 0
123456789012345678901234567890
J:\BBS\PCB\ADA                
12345678901234567890123456789012345678901234567890123456789012345
E:\MSDOS\ADA\                                                    
#endif



/*
 * output:
 *
 * 1) path of index file	buf1
 * 2) path of file area		buf2
 * 3) file description		(from area path && dir)
 */

#if 0
old:
dirlst %output%\dir%2 %cdrom%%1\ %1 < %cdrom%\_bbs\dirs.txt >> dir.lst

new:
dirlst %output%\dir%2 %cdrom% %1 < %cdrom%\_bbs\dirs.txt >> dir.lst
#endif

void
usage(void) {
	fprintf(stderr,
	"usage: dirlst <index file path> <cdrom drive letter> <file area path>\n");
	exit(1);
}

/*
 * description file, directory where files are, directory description
 */
void _Cdecl
main(int argc, char *argv[]) {
	char buf[200];
	char buf1[80];
	char buf2[80];
	char buf3[80];
	int len;
	char *p;
	
	strcpy(buf1, argv[1]);
	buf1[30] = '\0';
	len = strlen(buf1);
	if (buf1[len - 1] == '\\' && buf1[len - 2] == '\\')
		buf1[len - 2] = '\0';

	sprintf(buf2, "%s%s", argv[2], argv[3]);
	buf2[30] = '\0';
	len = strlen(buf2);
	if (buf2[len - 1] == '\\' && buf2[len - 2] == '\\')
		buf2[len - 2] = '\0';


	strcpy(buf3, argv[3]);
	buf3[35] = '\0';
	len = strlen(buf3);
	if (!len) {
		fprintf(stderr, "dirlst: no area path found.\n");
		usage();
	}
	if (buf3[len - 1] == '\\' && buf3[len - 2] == '\\')
		buf3[len - 2] = '\0';
	else if (buf3[len - 1] != '\\') {
		buf3[len] = '\\';
		buf3[len + 1] = '\0';
	}
	buf3[35] = '\0';

#if 0		
	sprintf(buf, "%s\\00_index.txt", argv[4]);
	if (NULL == (in_fp = fopen(buf, "r"))) {
		print_err("failed opening input file '%s'\n", buf);
		exit(1);
	}
#endif	

	/* find area description in dirs.txt */
	buf3[0] = '\0';
	while (NULL != gets(buf)) {
		if (0 == strncmpi(argv[3], buf, len)) {
			p = buf + len;
			while (isspace(*p))
				++p;
			strcpy(buf3, p);
			buf3[35] = '\0';
			break;
		}
	}
	if (! buf3[0]) {
		fprintf(stderr, "no area found:\n%s\n", argv[3]);
		exit(1);
	}
	
	printf("%-30s%-30s%-35s", buf1, buf2, buf3);
	exit(0);
}
