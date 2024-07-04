#include	<stdio.h>
#include	<unistd.h>

unsigned char	prg[] = { 0x00, 0x00, 0x00, 0xc3, 0x00, 0x00, 0x00 };

void	main(void)
{
	int		k;
	char	fn[16];
	FILE	*fp;

	for (k = 0; k < 256; k++)
	{
		sprintf(fn, "%02.2X.COM", k);

		if ((fp = fopen(fn, "wb")) == NULL)
		{
			perror("Can't open file");
			exit(0);
		}

		*prg = k;
		fwrite(prg, sizeof(prg), 1, fp);
		fclose(fp);
	}
}

