/* Chi-square and other analyses for 2 x 2 table. Alan Coates, 15 Aug 1984
	Written for Aztec CII compiler. This program is hereby placed in the 
	public domain.  Please send suggestions for improvements or 
	extensions to Alan Coates, 40 Cook Rd, Centennial Park 2021.
 */
#include "libc.h"	/* or your compiler header file, e.g. stdio.h */
#include "math.h"	/* you will need sqrt() or recode for pow()   */
#define ABS(x) (((x) < 0) ? -(x) : (x)) /* unless already in from header */
#define VERS 	1
#define SUBV 	62
#define DATE 	"15 Aug 1984"
#define NO 	0
#define YES	1
#define BEL	"\007"		/* ASCII bell */

/* HAZELTINE screen controls, octal. Insert your terminal codes as needed
	only one set should be left uncommented
#define INTODIM	"\176\031"
#define OUTODIM	"\176\037"	
#define CLS 	"\176\034"	
 */

/* Wyse 50 or 100 screen controls, octal */
#define INTODIM	"\033\107\160"
#define OUTODIM	"\033\107\060"	
#define CLS 	"\033\052"	


static double a,b,c,d;		

main()
	{

	printf("%s%s\n\tContingency Table Analysis v%d.%d  %s\n\t\t\t%s\n",
		OUTODIM,CLS, VERS, SUBV, DATE,"Alan Coates");
	entry();
	exit(0);
}	/* end of main */


int  chisq(e,f,g,h,y)

/*	Uses formula (n)(|eh-fg|-n/2)**2	(omits "-n/2"if not Yates)
		     ---------------------
		     (e+g)(f+h)(e+f)(g+h)
 */	
	double e,f,g,h;
	int y;

	{
	double n;
	double chis;
	char corr[BUFSIZ];
	
	if (y)
		strcpy(corr,"with Yates correction");
	else
		strcpy(corr,"(uncorrected)");

	n = (e+f+g+h);
	chis=ABS((e*h)-(f*g));
	if (y)
		chis = ((chis-n/2)>0.1) ? (chis-n/2) : 0;/* Yates correction */
	chis = chis*chis;
	chis = chis*n;	
	/* check for zero or negative row totals */
	if (((e+g)<=0.1)||((f+h)<=0.1)||((e+f)<=0.1)||((g+h)<=0.1)){	
		printf("\n** ERROR ** Row or col total .le. zero %s!\n\n",BEL);
		entry();
		}
	chis = chis/(e+g);	
	chis = chis/(f+h);
	chis = chis/(e+f);
	chis = chis/(g+h);

	printf("\n\nChi-squared %s  is %10.2f\n\n", corr, chis);

	signif(chis);

	if (n < 20){
	 printf("\nWARNING - small numbers - consider Fisher's exact test\n");
	 puts(BEL);
	 }	/* end of small number warning */
	printf("\t\t-----------------------------------------\n");
	return;
	}

int  entry()
	{
   	printf("%s\nThis program computes chisquared ", INTODIM);
	printf("(with optional Yates correction)\n");
	printf("and other analyses of a 2 x 2 table.\n\n");
	printf("\t\t\ta   |   b\n");
	printf("\t\t\t---------\n");
	printf("\t\t\tc   |   d\n");
	printf("%s\nEnter a b c d separated by space or cr\n: ", OUTODIM);
	while(scanf("%lf %lf %lf %lf", &a, &b, &c, &d) == 4 )
		doit();	/* got data, go select analysis option*/
	printf("%s\ndata error - try again!\n",INTODIM);
	return; /* if scanf error, crash gracefully(?) to system prompt */
	}	/* end of entry module */

int doit()
	
	{
	int menu();

	for(;;){	 	/* loops back to menu, can exit from there */
		switch(menu())
			{
		case  1 :
		chisq(a,b,c,d,YES);		/* i.e. WITH Yates */
			break;
		case  2 :
			chisq(a,b,c,d,NO);	/*      or WITHOUT */
			break;
		case  4:
			mcn(a,b);
			break;
		case  5:
			odds(a,b,c,d);
			break;
		case  6:
			risk(a,b,c,d);
			break;
		case  7:
			display(a,b,c,d);
			break;
		case  8:
			confid(a,b,c,d);
			break;
		case  9 :
			printf("\n\tExit selected from menu - %s%s bye!\n",
				INTODIM,BEL);
			exit(0);
			break;
		case  3:
			entry(); 
			break;
		default:
			display(a,b,c,d);
			printf("Bad option - restart !\n");
			exit(0);
			break;
			}	/* end of switch   */
		}		/* end of for loop */
	}			/* end of function */

int menu()
	{
	int choice;
	printf("\n%sOptions are:\n", INTODIM);
	printf("1\tChisquare - Yates correction\t5\tOdds Ratio\n");
	printf("2\tChisquare without correction\t6\tRelative Risk\n");
	printf("3\tEnter new data\t\t\t7\tRedisplay data\n");
	printf("4\tMcNemar's (a,b)\t\t\t8\tConfidence Intervals\n");
	printf("9\tExit\n");
	printf("%s\t\t\tYour choice? : ", OUTODIM);
	scanf("%d",&choice);
	return(choice);
	}

int odds(e,f,g,h)

	double e,f,g,h;
	{
	double o;

	o = (e*h)/(f*g);
	printf("\nOdds Ratio ad/bc is %6.2f\n",o);
	return;
	}

int risk(e,f,g,h)

	double e,f,g,h;
	{
	double rr;
	
	rr = (e*(g+h));
	rr = rr/(g*(e+f));
	printf("\nRelative risk, i.e. (a/(a+b))/(c/(c+d)) is %6.2f\n", rr);
	return;
	}

int display(e,f,g,h)

	double e,f,g,h;

	{
	printf("\n\t\t\t%4.0f  |  %4.0f\n", e, f);
	printf("Data are\t\t-------------\n");
	printf("\t\t\t%4.0f  |  %4.0f\n\n", g, h);
	printf("\t------------------+-------------------\n");
	return;
	}

int confid(e,f,g,h)

	double e,f,g,h;

	{
	double n;
	double p1, p2, diff, var1, var2, varc, lcl, ucl;
	double sqrt();
	n = e + f + g + h;
	if(((e+f) == 0) || ((g+h) == 0)){
		printf("Row total zero ! %s\n", BEL);
		return;
	}
	else if((((n*e)/(e+f)) < 10) || (((n*g)/(g+h)) < 10)){
		printf("** WARNING ** at extremes, the ");
		printf("normal assumptions are unreliable! %s\n\n", BEL);
	}
	p1 = e/(e+f);
	p2 = g/(g+h);
	diff = p2 - p1;
	var1 = (p1*(1-p1))/(e+f);
	var2 = (p2*(1-p2))/(g+h);
	varc = var1 + var2;
	lcl =  p1 - 1.96*(sqrt(var1));
	ucl =  p1 + 1.96*(sqrt(var1));
	printf("Response rates:\n");
	printf("a/a+b is %4.2f  \t95 pct conf limits %4.2f to  %4.2f \n",
		p1, lcl, ucl);
	lcl =  p2 - 1.96*(sqrt(var2));
	ucl =  p2 + 1.96*(sqrt(var2));
	printf("c/c+d is %4.2f  \t95 pct conf limits %4.2f to  %4.2f \n",
		p2, lcl, ucl);
	lcl =  diff - 1.96*(sqrt(varc));
	ucl =  diff + 1.96*(sqrt(varc));
	printf("\nDifference is %4.2f \n", diff);
	printf("The 95 percent confidence interval\nof this difference is ");
	printf("\t%4.2f to %4.2f \n\n", ucl, lcl);
	return;
	}

int mcn(e,f)
	double e,f;

	{
	double m;

	if(e+f < 0.10){
		printf("\nCannot calculate McNemar if both 0!\n");
		return;
		}
	m = ABS(e - f);
	m -= 1.0;
	m = m*m;
	m = m/(e+f);
	printf("\nMcNemar's test of p(a) = p(b) = 0.5\n");
	printf("gives Chisquared of %4.2f\n", m);
	signif(m);
	return;
	}

int signif(x)
	double x;

	{
	double p;

	if (x > 10.828)	/* critical values of chi-quared with 1 d.f. */
		p = 0.001;
	else if (x > 6.635)
		p = 0.01;
	else 
		p  = 0.05;

	if (x > 3.841)
		printf("\twhich is significant: p < %6.3f\n",p);
	else
		printf("\twhich is not significant at the 5 percent level\n");
	return;
	}
