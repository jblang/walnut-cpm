/*
hexcom.c
makes a com file from a hex file.  Uses standard I/O

Sample input file:

:100100003EFF87D200003E0187DA0000AFC2000048
:100110003CCA00003DFA00003DF200003E7F3CE298
:100120000000E6FFEA00001132010E09CD0500C310
:0701300000004F4B0D0A24F3
:0000000000

*/

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<stdarg.h>

static char	*progname;

static void	err_exit(const char *s, ...)
{
	va_list	ap;

	fprintf(stderr, "%s: ", progname);
	va_start(ap, s);
	vfprintf(stderr, s, ap);
	va_end(ap);
	exit(1);
}

static int	gethex(const char *p)
{
	int		r, c;

	if (!(c = *p++))
		return(-1);

	if (c >= 'A')
		c += 9;

	r = (c & 0x0f) << 4;

	if (!(c = *p))
		return(-1);

	if (c >= 'A')
		c += 9;

	return(r + (c & 0x0f));
}

static void	hexcom(FILE *in_fp, FILE *out_fp)
{
	char	*p;
	int		count, b;

	while ((p = getline(in_fp, 0)) != NULL)
	{
		if (*p++ != ':')
			err_exit("Line doesn't start with colon");

		if ((count = gethex(p)) == -1)
			err_exit("Invalid byte count in line");

		p += 8;

		while (count--)
		{
			if ((b = gethex(p)) == -1)
				err_exit("invalid byte in line");

			p += 2;
			putc(b, out_fp);
		}
	}
}

int		main(int argc, char **argv)
{
	FILE	*in_fp, *out_fp;
	char	buf[256], *p, *q;
	int		k;

	if ((progname = strrchr(argv[0], '/')) == NULL)
		progname = argv[0];
	else
		progname++;

	if (argc == 1)
	{
		hexcom(stdin, stdout);
		return(0);
	}

	for (k = 1; k < argc; k++)
	{
		strcpy(buf, argv[k]);

		if ((p = strrchr(buf, '.')) == NULL ||
			((q = strrchr(buf, '/')) != NULL && p < q))
				strcat(buf, ".hex");

		if ((in_fp = fopen(buf, "rt")) == NULL)
			err_exit("Can't open %s: %s", buf, strerror(errno));

		strcpy(strrchr(buf, '.'), ".com");

		if ((out_fp = fopen(buf, "wb")) == NULL)
			err_exit("Can't open %s: %s", buf, strerror(errno));

		hexcom(in_fp, out_fp);
	}

	return(0);
}
