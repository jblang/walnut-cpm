#include	<stdio.h>
#include	<unistd.h>

main()
{
	char	entry[32];

	while (*gets(entry))
		putchar(strtol(entry, NULL, 0));
}

