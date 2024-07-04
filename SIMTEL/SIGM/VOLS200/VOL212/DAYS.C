
/*	days() is hereby placed in the public domain
	Alan Coates 17 JUN 1984

	The function accepts a 6 digit ASCII argument ddmmyy
	and returns a (long) number of days from 1.1.1900,
	corrected for leap years up to 31.12.2099

 */

#include "local.h"	/* from Thomas Plum, or use "libc.h" */


long days(date)
char date[];
{
int dd,mm,dmax;
long daytot,yy;
char *s;
	dd = mm = yy = 0;
	for(s = date;s < date+2 && isdigit(*s); )
		dd = dd*10 + *(s++) -48;
	for(s = date + 2;s < date+4 && isdigit(*s); )
		mm = mm*10 + *(s++) -48;
	for(s = date + 4 ;s < date+ 6 && isdigit(*s); )
		yy = yy*10 + *(s++) -48;
	daytot = dd;
	/*	add months, correct for time of year	*/
	daytot += 30*(mm - 1);
	switch (mm)
			{

		case 2:
			if (!((yy-4)%4))
				dmax = 29;
			else
				dmax = 28;
			break;
		case 4:
		case 6:
		case 9:
		case 11:
			dmax = 30;
			break;
		default:
			dmax = 31;
			break;
			}
	if (dd <1 || dd > dmax)
		remark("bad day  ",dd);
	switch (mm)
			{
		case 1:
		case 4:
		case 5:
			daytot += 0; /*	no correction	*/
			break;
		case 3:
			daytot -= 1;
			break;
		case 2:
		case 6:
		case 7:
			daytot += 1;
			break;
		case 8:
			daytot += 2;
			break;
		case 9:
		case 10:
			daytot += 3;
			break;
		case 11:
		case 12:
			daytot += 4;
			break;
		default:
			remark("Bad month",mm);
			break;
			}
	/*	add for completed years	*/
		daytot += 365*yy;
	/*	correct within a leap year iff after Feb 29	*/
		if(mm > 2 && yy%4 == 0 && yy > 0)
			daytot += 1;
	/*	correct for elapsed leap years	*/
		daytot += (yy-1)/4;
	return(daytot);
}
remark(s1,x)
	char s1[] ;
	int x;
	{
	printf("%s   %d\n",s1,x);
	return;
	}

