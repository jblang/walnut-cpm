/*
 *      Word Processor
 *      similar to Unix NROFF or RSX-11M RNO -
 *      adaptation of text processor given in
 *      "Software Tools", Kernighan and Plauger.
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */

#include <stdio.h>
#include "nro.h"
#include "nrocom.c"

abs(foo)
int foo;
{
        return( (foo > 0) ? foo : -foo);
}


main(argc,argv)
int argc;
char *argv[];
{
        int i;
        int swflg;
        int ifp, ofp;
        
        swflg = FALSE;
        pout = stdout;
        ifp = ofp = 0;
        init();
        for (i=1; i<argc; ++i) {
                if (*argv[i] == '-' || *argv[i] == '+') {
                        if (pswitch(argv[i],&swflg) == ERR) exit(-1);
                }
                else if (*argv[i] == '>') {
                        if (ofp == 0) {
                                if (!strcmp(argv[i]+1,"$P")) {
                                        ofp = 1;
                                        co.lpr = TRUE;
                                }
                                else if ((oub = fopen(argv[i]+1,"w")) == NULL) {
                                        printf("nro: cannot create %s\n",argv[i]+1);
                                        exit(-1);
                                }
                                else {
                                        pout = oub;
                                }
                        }
                        else {
                                puts("nro: too many output files\n");
                                exit(-1);
                        }
                }
        }
        for (i=1; i<argc; ++i) {
                if (*argv[i] != '-' && *argv[i] != '+' && *argv[i] != '>') {
                        if ((sofile[0] = fopen(argv[i],"r")) == NULL) {
                                printf("nro: unable to open file %s\n",argv[i]);
                                exit(-1);
                        }
                        else {
                                profile();
                                fclose(sofile[0]);
                        }
                }
        }
        if (argc == 1) {
                puts("Usage: nro [-n] [+n] [-pxx] [-v] [-b] [-mmacfile] infile ... [>outfile]\n");
                exit(-1);
        }
        if (pout != stdout) {
                putc(CPMEOF,pout);
                fflush(pout);
                fclose(pout);
        }
}



/*
 *      retrieve one line of input text
 */

getlin(p,in_buf)
char *p;
FILE *in_buf;
{
        int i;
        int c;
        char *q;

        q = p;
        for (i=0; i<MAXLINE-1; ++i) {
                c = ngetc(in_buf);
                if (c == CPMEOF || c == EOF) {
                        *q = EOS;
                        c = strlen(p);
                        return(c == 0 ? EOF : c);
                }
                *q++ = c;
                if (c == '\n') break;
        }
        *q = EOS;
        return(strlen(p));
}



/*
 *      initialize parameters for nro word processor
 */

init()
{
        int i;

        dc.fill = YES;
        dc.lsval = 1;
        dc.inval = 0;
        dc.rmval = PAGEWIDTH - 1;
        dc.tival = 0;
        dc.ceval = 0;
        dc.ulval = 0;
        dc.cuval = 0;
        dc.juval = YES;
        dc.boval = 0;
        dc.bsflg = FALSE;
        dc.pgchr = '#';
        dc.cmdchr = '.';
        dc.prflg = TRUE;
        dc.sprdir = 0;
        for (i=0; i<26; ++i) dc.nr[i] = 0;
        pg.curpag = 0;
        pg.newpag = 1;
        pg.lineno = 2;
        pg.plval = PAGELEN;
        pg.m1val = 2;
        pg.m2val = 2;
        pg.m3val = 2;
        pg.m4val = 2;
        pg.bottom = pg.plval - pg.m4val - pg.m3val;
        pg.offset = 0;
        pg.frstpg = 0;
        pg.lastpg = 30000;
        pg.ehead[0] = pg.ohead[0] = '\n';
        pg.efoot[0] = pg.ofoot[0] = '\n';
        for (i=1; i<MAXLINE; ++i) {
                pg.ehead[i] = pg.ohead[i] = EOS;
                pg.efoot[i] = pg.ofoot[i] = EOS;
        }
        pg.ehlim[LEFT] = pg.ohlim[LEFT] = dc.inval;
        pg.eflim[LEFT] = pg.oflim[LEFT] = dc.inval;
        pg.ehlim[RIGHT] = pg.ohlim[RIGHT] = dc.rmval;
        pg.eflim[RIGHT] = pg.oflim[RIGHT] = dc.rmval;
        co.outp = 0;
        co.outw = 0;
        co.outwds = 0;
        co.lpr = FALSE;
        for (i=0; i<MAXLINE; ++i) co.outbuf[i] = EOS;
        for (i=0; i<MXMDEF; ++i) mac.mnames[i] = NULL;
        mac.lastp = 0;
        mac.emb = &mac.mb[0];
        mac.ppb = NULL;
}


/*
 *      get character from input file or push back buffer
 */

ngetc(infp)
FILE *infp;
{
        int c;

        if (mac.ppb >= &mac.pbb[0]) {
                c = *mac.ppb--;
        }
        else {
                c = getc(infp);
        }
        return(c);
}



/*
 *      process input files from command line
 */

profile()
{
        char ibuf[MAXLINE];

        for (dc.flevel=0; dc.flevel>=0; --dc.flevel) {
                while (getlin(ibuf,sofile[dc.flevel]) != EOF) {
                        if (ibuf[0] == dc.cmdchr) comand(ibuf);
                        else text(ibuf);
                }
                if (dc.flevel > 0) fclose(sofile[dc.flevel]);
        }
        if (pg.lineno > 0) space(HUGE);
}



/*
 *      process switch values from command line
 */

pswitch(p,q)
char *p;
int *q;
{
        int swgood;

        swgood = TRUE;
        if (*p == '-') {
                switch (newlower(*++p)) {
                case 'b':
                        dc.bsflg = TRUE;
                        break;
                case 'm':
                        if ((sofile[0] = fopen(++p,"r")) == NULL) {
                                printf("***nro: unable to open file %s\n",p);
                                exit(-1);
                        }
                        profile();
                        fclose(sofile[0]);
                        break;
                case 'p':
                   set(&pg.offset,ctod(++p),'1',0,0,HUGE);
                        break;
                case 'v':
                        printf("NRO version 1.0\n");
                        *q = TRUE;
                        break;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                        pg.lastpg = ctod(p);
                        break;
                default:
                        swgood = FALSE;
                        break;
                }
        }
        else if (*p == '+') {
                pg.frstpg = ctod(++p);
        }
        else {
                swgood = FALSE;
        }
        if (swgood == FALSE) {
                printf("nro: illegal switch %s\n",p);
                return(ERR);
        }
        return(OK);
}

*************
    \nro.h/
*************
/*
 *      Parameter file for NRO word processor
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */


/* some or all of this may be unnecessary for you */

#include <ctype.h>
#define EOS '\0'
#define CPMEOF 0x1a
#define TRUE -1
#define FALSE 0
#define OK 0

/* end of possible bogus hacks */

#define MACRO    0      /* macro definition */
#define BP       1      /* begin page   */
#define BR       2      /* break        */
#define CE       3      /* center       */
#define FI       4      /* fill         */
#define FO       5      /* footer       */
#define HE       6      /* header       */
#define IN       7      /* indent       */
#define LS       8      /* line spacing */
#define NF       9      /* no fill      */
#define PL      10      /* page lenght  */
#define RM      11      /* right margin */
#define SP      12      /* line space   */
#define TI      13      /* temp indent  */
#define UL      14      /* underline    */
#define JU      15      /* justify      */
#define NJ      16      /* no justify   */
#define M1      17      /* top margin   */
#define M2      18      /* second top margin    */
#define M3      19      /* first bottom margin  */
#define M4      20      /* bottom-most margin   */
#define BS      21      /* allow/disallow '\b' in output */
#define NE      22      /* need n lines */
#define PC      23      /* page number character */
#define CC      24      /* control character    */
#define PO      25      /* page offset  */
#define BO      26      /* bold face    */
#define EH      27      /* header for even numbered pages       */
#define OH      28      /* header for odd numbered pages        */
#define EF      29      /* footer for even numbered pages       */
#define OF      30      /* footer for odd numbered pages        */
#define SO      31      /* source file  */
#define CU      32      /* continuous underline */
#define DE      33      /* define macro */
#define EN      34      /* end macro definition */
#define NR      35      /* set number register  */

#define UNKNOWN -1

/*
 *      MAXLINE is set to a value slightly larger
 *      than twice the longest expected input line.
 *      Because of the way underlining is handled, the
 *      input line which is to be underlined, can almost
 *      triple in length.  Unlike normal underlining and
 *      boldfacing, continuous underlining affects all
 *      characters in the buffer, and represents the
 *      worst case condition.  If the distance between
 *      the left margin and the right margin is greater
 *      than about 65 characters, and continuous underlining
 *      is in effect, there is a high probability of buffer
 *      overflow.
 */

#define MAXLINE 200
#define PAGELEN  66
#define PAGEWIDTH 80
#define HUGE    256
#define LEFT    0               /* indecies into header margin limit arrays */
#define RIGHT   1
#define NFILES  4               /* nesting depth for input files */

/*
 *      The following parameters may be defined in bdscio.h
 */

#define YES     1
#define NO      0
#define ERR     -1

/*
 *      The parameter values selected for macro definitions
 *      are somewhat arbitrary.  MACBUF is the storage area
 *      for both macro names and definitions.  Since macro
 *      processing is handled by pushing back the expansion
 *      into the input buffer, the longest possible expansion
 *      would be MAXLINE characters.  Allowing for argument
 *      expansion, MXMLEN was chosen slightly less than MAXLINE.
 *      It is assumed that most macro definitions will not
 *      exceed 20 characters, hence MXMDEF of 100.
 */

#define MXMDEF  100             /* maximum no. of macro definitions */
#define MACBUF  2000            /* macro definition buffer */
#define MXMLEN  150             /* maximum length of each macro definition */
#define MNLEN   10              /* maximum length of macro name */

struct macros {
        char *mnames[MXMDEF];   /* table of pointers to macro names */
        int lastp;              /* index to last mname  */
        char *emb;              /* next char avail in macro defn buffer */
        char mb[MACBUF];        /* table of macro definitions */
        char *ppb;              /* pointer into push back buffer */
        char pbb[MAXLINE];      /* push back buffer */
};


/* control parameters for nro */

struct docctl {
        int fill;       /* fill if YES, init = YES              */
        int lsval;      /* current line spacing, init = 1       */
        int inval;      /* current indent, >= 0, init = 0       */
        int rmval;      /* current right margin, init = 60      */
        int tival;      /* current temp indent, init = 0        */
        int ceval;      /* number of lines to center, init = 0  */
        int ulval;      /* number of lines to underline, init = 0 */
        int cuval;      /* no. lines to continuously underline, init = 0 */
        int juval;      /* justify if YES, init = YES           */
        int boval;      /* number of lines to bold face, init = 0 */
        int bsflg;      /* can output contain '\b', init = FALSE */
        char pgchr;     /* page number character, init = '#'    */
        char cmdchr;    /* command character, init = '.'        */
        int prflg;      /* print on or off, init = TRUE         */
        int sprdir;     /* direction for spread(), init = 0     */
        int flevel;     /* nesting depth for source cmd, init = 0 */
        int nr[26];     /* number registers     */
};


/* output buffer control parameters */

struct cout {
        int outp;       /* next avail char position in outbuf, init = 0 */
        int outw;       /* width of text currently in buffer    */
        int outwds;     /* number of words in buffer, init = 0  */
        int lpr;        /* output to printer, init = FALSE      */
        char outbuf[MAXLINE];   /* output of filled text        */
};

/* page control parameters for nro */

struct page {
        int curpag;     /* current output page number, init =0  */
        int newpag;     /* next output page number, init = 1    */
        int lineno;     /* next line to be printed, init = 0    */
        int plval;      /* page length in lines, init = 66      */
        int m1val;      /* margin before and including header   */
        int m2val;      /* margin after header                  */
        int m3val;      /* margin after last text line          */
        int m4val;      /* bottom margin, including footer      */
        int bottom;     /* last live line on page
                                        = plval - m3val - m4val */
        int offset;     /* page offset from left, init = 0      */
        int frstpg;     /* first page to print, init = 0        */
        int lastpg;     /* last page to print, init = 30000     */
        int ehlim[2];   /* left/right margins for headers/footers       */
        int ohlim[2];   /* init = 0 and PAGEWIDTH                       */
        int eflim[2];
        int oflim[2];
        char ehead[MAXLINE];    /* top of page title, init = '\n'       */
        char ohead[MAXLINE];
        char efoot[MAXLINE];    /* bottom of page title, init = '\n'    */
        char ofoot[MAXLINE];
};

char *getmac();


***********
   \nrocmd.c/
***********
/*
 *      Command processor for NRO text processor
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */

#include <stdio.h>
#include "nro.h"
#include "nroxtrn.c"

char *skipbl();
char *skipwd();

comand(p)
char *p;
{
        int ct, val;
        int spval;
        int index;
        char argtyp;
        char name[MAXLINE];
        char macexp[MXMLEN];

        ct = comtyp(p,macexp);
        if (ct == UNKNOWN) {
                printf("*** nro: unrecognized command %s\n",p);
                return;
        }
        expesc(p,name);
        val = getval(p,&argtyp);
        switch (ct) {
        case BO: /* bold face */
                set(&dc.boval,val,argtyp,1,0,HUGE);
                dc.cuval = dc.ulval = 0;
                break;
        case BP: /* begin page */
                if(pg.lineno > 0) space(HUGE);
                set(&pg.curpag,val,argtyp,pg.curpag+1,-HUGE,HUGE);
                pg.newpag = pg.curpag;
                break;
        case BR: /* break */
                brk();
                break;
        case BS: /* backspaces in output */
                set(&dc.bsflg,val,argtyp,1,0,1);
                break;
        case CC: /* command character */
                if (argtyp == '\r' || argtyp == '\n') dc.cmdchr = '.';
                else dc.cmdchr = argtyp;
                break;
        case CE: /* center */
                brk();
                set(&dc.ceval,val,argtyp,1,0,HUGE);
                break;
        case CU: /* continuous underline */
                set(&dc.cuval,val,argtyp,1,0,HUGE);
                dc.ulval = dc.boval = 0;
                break;
        case DE: /* define macro */
                defmac(p,sofile[dc.flevel]);
                break;
        case EF: /* even footer */
                gettl(p,pg.efoot,&pg.eflim[0]);
                break;
        case EH: /* even header */
                gettl(p,pg.ehead,&pg.ehlim[0]);
                break;
        case EN: /* end macro definition */
                puts("***nro: missing .de command\n");
                break;
        case FI: /* fill */
                brk();
                dc.fill = YES;
                break;
        case FO: /* footer */
                gettl(p,pg.efoot,&pg.eflim[0]);
                gettl(p,pg.ofoot,&pg.oflim[0]);
                break;
        case HE: /* header */
                gettl(p,pg.ehead,&pg.ehlim[0]);
                gettl(p,pg.ohead,&pg.ohlim[0]);
                break;
        case IN: /* indenting */
                set(&dc.inval,val,argtyp,0,0,dc.rmval-1);
                dc.tival = dc.inval;
                break;
        case JU: /* justify */
                dc.juval = YES;
                break;
        case LS: /* line spacing */
                set(&dc.lsval,val,argtyp,1,1,HUGE);
                break;
        case M1: /* set topmost margin */
                set(&pg.m1val,val,argtyp,2,0,HUGE);
                break;
        case M2: /* set second top margin */
                set(&pg.m2val,val,argtyp,2,0,HUGE);
                break;
        case M3: /* set first bottom margin */
                set(&pg.m3val,val,argtyp,2,0,HUGE);
                pg.bottom = pg.plval - pg.m4val - pg.m3val;
                break;
        case M4: /* set bottom-most margin */
                set(&pg.m4val,val,argtyp,2,0,HUGE);
                pg.bottom = pg.plval - pg.m4val - pg.m3val;
                break;
        case MACRO: /* macro expansion */
                maceval(p,macexp);
                break;
        case NE: /* need n lines */
                brk();
                if ((pg.bottom-pg.lineno+1) < (val*dc.lsval)) {
                        space(HUGE);
                }
                break;
        case NF: /* no fill */
                brk();
                dc.fill = NO;
                break;
        case NJ: /* no justify */
                dc.juval = NO;
                break;
        case NR: /* set number register */
                p = skipwd(p);
                p = skipbl(p);
                if (!isalpha(*p)) {
                        puts("***nro: invalid or missing number register name\n");
                }
                else {
                        index = newlower(*p) - 'a';
                        p = skipwd(p);
                        val = getval(p,&argtyp);
                        set(&dc.nr[index],val,argtyp,0,-HUGE,HUGE);
                }
                break;
        case OF: /* odd footer */
                gettl(p,pg.ofoot,&pg.oflim[0]);
                break;
        case OH: /* odd header */
                gettl(p,pg.ohead,&pg.ohlim[0]);
                break;
        case PC: /* page number character */
                if (argtyp == '\r' || argtyp == '\n') dc.pgchr = EOS;
                else dc.pgchr = argtyp;
                break;
        case PL: /* page length */
                set(&pg.plval,val,argtyp,PAGELEN,
                        pg.m1val+pg.m2val+pg.m3val+pg.m4val+1,HUGE);
                pg.bottom = pg.plval - pg.m3val - pg.m4val;
                break;
        case PO: /* page offset */
                set(&pg.offset,val,argtyp,0,0,HUGE);
                break;
        case RM: /* right margin */
                set(&dc.rmval,val,argtyp,PAGEWIDTH,dc.tival+1,HUGE);
                break;
        case SO: /* source file */
                p = skipwd(p);
                p = skipbl(p);
                if (getwrd(p,name) == 0) break;
                if (dc.flevel+1 >= NFILES) {
                        puts("***nro: .so commands nested too deeply\n");
                        exit(-1);
                }
                if ((sofile[dc.flevel+1] = fopen(name,"r")) == NULL) {
                        printf("***nro: unable to open %s\n",name);
                        exit(-1);
                }
                ++dc.flevel;
                break;
        case SP: /* space */
                set(&spval,val,argtyp,1,0,HUGE);
                space(spval);
                break;
        case TI: /* temporary indent */
                brk();
                set(&dc.tival,val,argtyp,0,0,dc.rmval);
                break;
        case UL: /* underline */
                set(&dc.ulval,val,argtyp,0,1,HUGE);
                dc.cuval = dc.boval = 0;
                break;
        }
}



/*
 *      convert ascii character to decimal.
 */

atod(c)
char c;
{
        return(((c < '0') || (c > '9')) ? -1 : c-'0');
}



/*
 *      end current filled line
 */

brk()
{
        if(co.outp > 0) {
                co.outbuf[co.outp] = '\r';
                co.outbuf[co.outp + 1] = '\n';
                co.outbuf[co.outp + 2] = EOS;
                put(co.outbuf);
        }
        co.outp = 0;
        co.outw = 0;
        co.outwds = 0;
}


/*
 *      Collect macro definition from input stream
 */

colmac(p,d,i)
char *p, d[];
int i;
{
        while (*p != EOS) {
                if (i >= MXMLEN-1) {
                        d[i-1] = EOS;
                        return(ERR);
                }
                d[i++] = *p++;
        }
        d[i] = EOS;
        return(i);
}




/*
 *      decodes nro command and returns its associated
 *      value.
 */

comtyp(p,m)
char *p;
char *m;
{
        char c1, c2;
        char macnam[MNLEN];
        char *s;

        p++;
        /*
        *       First check to see if the command is a macro.
        *       If it is, truncate to two characters and return
        *       expansion in m.  Note that upper and lower case
        *       characters are handled differently for macro names,
        *       but not for normal command names.
        */
        getwrd(p,macnam);
        macnam[2] = EOS;
        if ((s = getmac(macnam)) != NULL) {
                strcpy(m,s);
                return(MACRO);
        }
        c1 = newlower(*p++);
        c2 = newlower(*p);
        if (c1 == 'b' && c2 == 'o') return(BO);
        if (c1 == 'b' && c2 == 'p') return(BP);
        if (c1 == 'b' && c2 == 'r') return(BR);
        if (c1 == 'b' && c2 == 's') return(BS);
        if (c1 == 'c' && c2 == 'c') return(CC);
        if (c1 == 'c' && c2 == 'e') return(CE);
        if (c1 == 'c' && c2 == 'u') return(CU);
        if (c1 == 'd' && c2 == 'e') return(DE);
        if (c1 == 'e' && c2 == 'f') return(EF);
        if (c1 == 'e' && c2 == 'h') return(EH);
        if (c1 == 'e' && c2 == 'n') return(EN);
        if (c1 == 'f' && c2 == 'i') return(FI);
        if (c1 == 'f' && c2 == 'o') return(FO);
        if (c1 == 'h' && c2 == 'e') return(HE);
        if (c1 == 'i' && c2 == 'n') return(IN);
        if (c1 == 'j' && c2 == 'u') return(JU);
        if (c1 == 'l' && c2 == 's') return(LS);
        if (c1 == 'm' && c2 == '1') return(M1);
        if (c1 == 'm' && c2 == '2') return(M2);
        if (c1 == 'm' && c2 == '3') return(M3);
        if (c1 == 'm' && c2 == '4') return(M4);
        if (c1 == 'n' && c2 == 'e') return(NE);
        if (c1 == 'n' && c2 == 'f') return(NF);
        if (c1 == 'n' && c2 == 'j') return(NJ);
        if (c1 == 'n' && c2 == 'r') return(NR);
        if (c1 == 'o' && c2 == 'f') return(OF);
        if (c1 == 'o' && c2 == 'h') return(OH);
        if (c1 == 'p' && c2 == 'c') return(PC);
        if (c1 == 'p' && c2 == 'l') return(PL);
        if (c1 == 'p' && c2 == 'o') return(PO);
        if (c1 == 'r' && c2 == 'm') return(RM);
        if (c1 == 's' && c2 == 'o') return(SO);
        if (c1 == 's' && c2 == 'p') return(SP);
        if (c1 == 't' && c2 == 'i') return(TI);
        if (c1 == 'u' && c2 == 'l') return(UL);
        return(UNKNOWN);
}



/*
 *      convert string to decimal.
 *      processes only positive values.
 */

ctod(p)
char *p;
{
        int val, d;

        val = 0;
        while(*p != EOS) {
                d = atod(*p++);
                if(d == -1) return(val);
                val = 10 * val + d;
        }
        return(val);
}


/*
 *      Define a macro
 */

defmac(p,infp)
char *p;
FILE *infp;
{
        int i;
        char name[MNLEN];
        char defn[MXMLEN];
        char *q;

        q = skipwd(p);
        q = skipbl(q);
        i = getwrd(q,name);
        if (!isalpha(*name)) {
                puts("***nro: missing or illegal macro definition name\n");
                exit(-1);
        }
        if (i > 2) name[2] = EOS;
        i = 0;
        while (getlin(p,infp) != EOF) {
                if (p[0] == dc.cmdchr && newlower(p[1]) == 'e' && newlower(p[2]) == 'n') {
                        break;
                }
                if ((i = colmac(p,defn,i)) == ERR) {
                        puts("***nro: macro definition too long\n");
                        exit(-1);
                }
        }
        if (putmac(name,defn) == ERR) {
                puts("***nro: macro definition table full\n");
                exit(-1);
        }
}


/*
 *      Expand escape sequences
 */

expesc(p,q)
char *p;
char *q;
{
        char *s, *t;

        s = p;
        t = q;
        while (*s != EOS) {
                if (*s != '@') {
                        *t++ = *s++;
                }
                else if (*(s+1) == '@') {
                        *t++ = *s++;
                        ++s;
                }
                else if (newlower(*(s+1)) == 'n' && isalpha(*(s+2))) {
                        s += 2;
                        t += itoda(dc.nr[newlower(*s)-'a'],t,6) - 1;
                        ++s;
                }
                else {
                        *t++ = *s++;
                }
        }
        *t = EOS;
        strcpy(p,q);
}



/*
 *      Get macro definition from table
 */

char *getmac(name)
char *name;
{
        int i;

        for (i = mac.lastp; i >= 0; --i) {
                if (!strcmp(name,mac.mnames[i])) {
                        return(mac.mnames[i] + 3);
                }
        }
        return(NULL);
}




/*
 *      get header or footer title
 */

gettl(p,q,limit)
char *p;
char *q;
int limit[];
{
        p = skipwd(p);
        p = skipbl(p);
        strcpy(q,p);
        limit[LEFT] = dc.inval;
        limit[RIGHT] = dc.rmval;
}



/*
 *      retrieves optional argument following nro command.
 *      returns positive integer value with sign (if any)
 *      saved in character addressed by p_argt.
 */

getval(p,p_argt)
char *p;
char *p_argt;
{
        p = skipwd(p);
        p = skipbl(p);
        *p_argt = *p;
        if((*p == '+') || (*p == '-')) ++p;
        return(ctod(p));
}


/*
 *      Evaluate macro expansion
 */

maceval(p,m)
char *p;
char m[];
{
        int i, j;
        char *argp[10];
        char c;

        *p++ = EOS;             /* replace command char with EOS */
        /*
        *       initialize argp array to substitute command
        *       string for any undefined argument
        */
        for (i=0; i<10; ++i) argp[i] = p;
        p = skipwd(p);
        *p++ = EOS;
        for (i=0; i<10; ++i) {
                p = skipbl(p);
                if (*p == '\r' || *p == '\n' || *p == EOS) break;
                if (*p == '\'' || *p == '"') {
                        c = *p++;
                        argp[i] = p;
                        while (*p != c && *p != '\r' && *p != '\n' && *p != EOS) ++p;
                        *p++ = EOS;
                }
                else {
                        argp[i] = p;
                        p = skipwd(p);
                        *p++ = EOS;
                }
        }
        for (i=strlen(m)-1; i>=0; --i) {
                if (i > 0 && m[i-1] == '$') {
                        if (!isdigit(m[i])) {
                                putbak(m[i]);
                        }
                        else {
                                pbstr(argp[m[i]-'0']);
                                --i;
                        }
                }
                else {
                        putbak(m[i]);
                }
        }
}


/*
 *      Push back string into input stream
 */

pbstr(p)
char p[];
{
        int i;

        for (i=strlen(p)-1; i>=0; --i) {
                putbak(p[i]);
        }
}



/*
 *      Push character back into input stream
 */

putbak(c)
char c;
{
        if (mac.ppb < &mac.pbb[0]) {
                mac.ppb = &mac.pbb[0];
                *mac.ppb = c;
        }
        else {
                if (mac.ppb >= &mac.pbb[MAXLINE-1]) {
                        puts("***nro: push back buffer overflow\n");
                        exit(-1);
                }
                *++mac.ppb = c;
        }
}




/*
 *      Put macro definition into table
 */

putmac(name,p)
char *name;
char *p;
{
        if (mac.lastp >= MXMDEF) return(ERR);
        if (mac.emb + strlen(name) + strlen(p) + 1 > &mac.mb[MACBUF]) {
                return(ERR);
        }
        ++mac.lastp;
        mac.mnames[mac.lastp] = mac.emb;
        strcpy(mac.emb,name);
        strcpy(mac.emb + strlen(name) + 1,p);
        mac.emb += strlen(name) + strlen(p) + 2;
        return(OK);
}




/*
 *      set parameter and check range
 */

set(param,val,type,defval,minval,maxval)
int *param;
int val;
char type;
int defval,minval,maxval;
{
        switch(type) {
        case '\r':
        case '\n':
                *param = defval;
                break;
        case '+':
                *param += val;
                break;
        case '-':
                *param -= val;
                break;
        default:
                *param = val;
                break;
        }
        *param = min(*param,maxval);
        *param = max(*param,minval);
}



/*
 *      skip blanks and tabs in character buffer.
 *      return number of characters skipped.
 */

char *skipbl(p)
char *p;
{
        while (*p == ' ' || *p == '\t') ++p;
        return(p);
}


/*
 *      skip over word and punctuation
 */

char *skipwd(p)
char *p;
{
        while (*p != ' ' && *p != '\t' && *p != '\r' && *p != '\n' && *p != EOS)
                ++p;
        return(p);
}



/*
 *      space vertically n lines
 */

space(n)
int n;
{
        brk();
        if (pg.lineno > pg.bottom) return;
        if (pg.lineno == 0) phead();
        skip(min(n,pg.bottom+1-pg.lineno));
        pg.lineno += n;
        if (pg.lineno > pg.bottom) pfoot();
}

**********
   \nrotxt.c/
**********
/*
 *      Text processing portion of NRO word processor
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */

#include <stdio.h>
#include "nro.h"
#include "nroxtrn.c"

text(p)
char *p;
{
        int i;
        char wrdbuf[MAXLINE];

        if (*p == ' ' || *p == '\n' || *p == '\r') leadbl(p);
        expesc(p,wrdbuf);
        if (dc.ulval > 0) {
                /*
                *       Because of the way underlining is handled,
                *       MAXLINE should be declared to be three times
                *       larger than the longest expected input line
                *       for underlining.  Since many of the character
                *       buffers use this parameter, a lot of memory
                *       can be allocated when it may not really be
                *       needed.  A MAXLINE of 180 would allow about
                *       60 characters in the output line to be
                *       underlined (remember that only alphanumerics
                *       get underlined - no spaces or punctuation).
                */
                underl(p,wrdbuf,MAXLINE);
                --dc.ulval;
        }
        if (dc.cuval > 0) {
                underl(p,wrdbuf,MAXLINE);
                --dc.cuval;
        }
        if (dc.boval > 0) {
                bold(p,wrdbuf,MAXLINE);
                --dc.boval;
        }
        if (dc.ceval > 0) {
                center(p);
                put(p);
                --dc.ceval;
        }
        else if (*p == '\r' || *p == '\n') put(p); /* all blank line */
        else if (dc.fill == NO) put(p);         /* unfilled */
        else {
                while ((i = getwrd(p,wrdbuf)) > 0) {
                        putwrd(wrdbuf);
                        p += i;
                }
        }
}


/*
 *      insert bold face text
 */

bold(p0,p1,size)
char *p0, *p1;
int size;
{
        int i, j;

        j = 0;
        for (i=0; (p0[i] != '\n') && (j < size-1); ++i) {
                if (isalpha(p0[i]) || isdigit(p0[i])) {
                        p1[j++] = p0[i];
                        p1[j++] = '\b';
                }
                p1[j++] = p0[i];
        }
        p1[j++] = '\n';
        p1[j] = EOS;
        while (*p1 != EOS) *p0++ = *p1++;
        *p0 = EOS;
}




/*
 *      center a line by setting tival
 */

center(p)
char *p;
{
        dc.tival = max((dc.rmval + dc.tival - width(p)) >> 1,0);
}


/*
 *      expand title buffer to include character string
 */

expand(p0,c,s)
char *p0;
char c;
char *s;
{
        char tmp[MAXLINE];
        char *p, *q, *r;

        p = p0;
        q = tmp;
        while (*p != EOS) {
                if (*p == c) {
                        r = s;
                        while (*r != EOS) *q++ = *r++;
                }
                else *q++ = *p;
                ++p;
        }
        *q = EOS;
        strcpy(p0,tmp);         /* copy it back */
}


/*
 *      get field from title
 */

char *getfield(p,q,delim)
char *p, *q;
char delim;
{
        while (*p != delim && *p != '\r' && *p != '\n' && *p != EOS) {
                *q++ = *p++;
        }
        *q = EOS;
        if (*p == delim) ++p;
        return(p);
}



/*
 *      get non-blank word from p0 into p1.
 *      return number of characters processed.
 */

getwrd(p0,p1)
char *p0,*p1;
{
        int i;
        char *p, c;

        i = 0;
        while (*p0 == ' ' || *p0 == '\t') {
                ++i;
                ++p0;
        }
        p = p0;
        while (*p0 != ' ' && *p0 != EOS && *p0 != '\t') {
                if (*p0 == '\n' || *p0 == '\r') break;
                *p1 = *p0++;
                ++p1;
                ++i;
        }
        c = *(p1-1);
        if (c == '"') c = *(p1-2);
        if (c == '?' || c == '!') {
                *p1++ = ' ';
                ++i;
        }
        if (c == '.' && (*p0 == '\n' || *p0 == '\r' || islower(*p))) {
                *p1++ = ' ';
                ++i;
        }
        *p1 = EOS;
        return(i);
}


/*
 *      convert integer to decimal ascii string
 */

itoda(value,p,size)
int value;
char *p;
int size;
{
        char c[7];
        int i, j, k;
        int aval;

        aval = abs(value);
        c[0] = EOS;
        i = 1;
        do {
                c[i++] = (aval % 10) + '0';
                aval /= 10;
        } while (aval > 0 && i <= size);
        if (value < 0 && i <= size) c[i++] = '-';
        for (j=0; j<i; ++j) *p++ = c[i-j-1];
        return(i);
}


/*
 *      center title text into print buffer
 */

justcntr(p,q,limit)
char *p, *q;
int limit[];
{
        int len;

        len = width(p);
        q = &q[(limit[RIGHT] + limit[LEFT] - len) >> 1];
        while (*p != EOS) *q++ = *p++;
}



/*
 *      left justify title text into print buffer
 */

justleft(p,q,limit)
char *p, *q;
int limit;
{
        q = &q[limit];
        while (*p != EOS) *q++ = *p++;
}


/*
 *      right justify title text into print buffer
 */

justrite(p,q,limit)
char *p, *q;
int limit;
{
        int len;

        len = width(p);
        q = &q[limit - len];
        while (*p != EOS) *q++ = *p++;
}




/*
 *      delete leading blanks, set tival
 */

leadbl(p)
char *p;
{
        int i,j;

        brk();
        for (i=0; p[i] == ' '; ++i) ;
        if (p[i] != '\n' && p[i] != '\r') dc.tival = i;
        for (j=0; p[i] != EOS; ++j) p[j] = p[i++];
        p[j] = EOS;
}



/*
 *      find minimum of two integer
 */

min(v1,v2)
int v1,v2;
{
        return((v1 < v2) ? v1 : v2);
}



/*
 *      find maximum of two integers
 */

max(v1,v2)
int v1,v2;
{
        return((v1 > v2) ? v1 : v2);
}



/*
 *      put out page footer
 */

pfoot()
{
        if (dc.prflg == TRUE) {
                skip(pg.m3val);
                if (pg.m4val > 0) {
                        if ((pg.curpag % 2) == 0) {
                                puttl(pg.efoot,pg.eflim,pg.curpag);
                        }
                        else {
                                puttl(pg.ofoot,pg.oflim,pg.curpag);
                        }
                        skip(pg.m4val - 1);
                }
        }
}



/*
 *      put out page header
 */

phead()
{
        pg.curpag = pg.newpag;
        if (pg.curpag >= pg.frstpg && pg.curpag <= pg.lastpg) {
                dc.prflg = TRUE;
        }
        else {
                dc.prflg = FALSE;
        }
        ++pg.newpag;
        if (dc.prflg == TRUE) {
                if (pg.m1val > 0) {
                        skip(pg.m1val - 1);
                        if ((pg.curpag % 2) == 0) {
                                puttl(pg.ehead,pg.ehlim,pg.curpag);
                        }
                        else {
                                puttl(pg.ohead,pg.ohlim,pg.curpag);
                        }
                }
                skip(pg.m2val);
        }
        /*
        *       initialize lineno for the next page
        */
        pg.lineno = pg.m1val + pg.m2val + 1;
}


/*
 *      print character with test for printer
 */

prchar(c,fp)
char c;
FILE *fp;
{
        if (co.lpr == TRUE) {
                bdos(5,c);
        }
        else {
                putc(c,fp);
        }
}




/*
 *      put out line with proper spacing and indenting
 */

put(p)
char *p;
{
        char os[MAXLINE];
        int j;

        if (pg.lineno == 0 || pg.lineno > pg.bottom) {
                phead();
        }
        if (dc.prflg == TRUE) {
                if (!dc.bsflg) {
                        if (strkovr(p,os) == TRUE) {
                                for (j=0; j<pg.offset; ++j) prchar(' ',pout);
                                for (j=0; j<dc.tival; ++j) prchar(' ',pout);
                                putlin(os,pout);
                        }
                }
                for (j=0; j<pg.offset; ++j) prchar(' ',pout);
                for (j=0; j<dc.tival; ++j) prchar(' ',pout);
                putlin(p,pout);
        }
        dc.tival = dc.inval;
        skip(min(dc.lsval-1,pg.bottom-pg.lineno));
        pg.lineno = pg.lineno + dc.lsval;
        if (pg.lineno > pg.bottom) pfoot();
}


/*
 *      output a null terminated string to the file
 *      specified by pbuf.
 */

putlin(p,pbuf)
char *p;
struct buf *pbuf;
{
        while (*p != EOS) prchar(*p++,pbuf);
}



/*
 *      put out title or footer
 */

puttl(p,lim,pgno)
char *p;
int lim[];
int pgno;
{
        int i;
        char pn[8];
        char t[MAXLINE];
        char h[MAXLINE];
        char delim;

        itoda(pgno,pn,6);
        for (i=0; i<MAXLINE; ++i) h[i] = ' ';
        delim = *p++;
        p = getfield(p,t,delim);
        expand(t,dc.pgchr,pn);
        justleft(t,h,lim[LEFT]);
        p = getfield(p,t,delim);
        expand(t,dc.pgchr,pn);
        justcntr(t,h,lim);
        p = getfield(p,t,delim);
        expand(t,dc.pgchr,pn);
        justrite(t,h,lim[RIGHT]);
        for (i=MAXLINE-4; h[i] == ' '; --i) h[i] = EOS;
        h[++i] = '\n';
        h[++i] = '\r';
        h[++i] = EOS;
        if (strlen(h) > 2) {
                for (i=0; i<pg.offset; ++i) prchar(' ',pout);
        }
        putlin(h,pout);
}



/*
 *      put word in output buffer
 */

putwrd(wrdbuf)
char *wrdbuf;
{
        int w;
        int last;
        int llval;
        char *p0, *p1;
        int nextra;

        w = width(wrdbuf);
        last = strlen(wrdbuf) + co.outp;
        llval = dc.rmval - dc.tival;
        if(((co.outp > 0) && ((co.outw + w) > llval)) || (last > MAXLINE)) {
                last -= co.outp;
                if(dc.juval == YES) {
                        nextra = llval - co.outw + 1;
                        /*
                        *       Check whether last word was end of
                        *       sentence and modify counts so that
                        *       it is right justified.
                        */
                        if (co.outbuf[co.outp-2] == ' ') {
                                --co.outp;
                                ++nextra;
                        }
                        spread(co.outbuf,co.outp-1,nextra,co.outwds);
                        if((nextra > 0) && (co.outwds > 1)) {
                                co.outp += (nextra - 1);
                        }
                }
                brk();
        }
        p0 = wrdbuf;
        p1 = co.outbuf + co.outp;
        while(*p0 != EOS) *p1++ = *p0++;
        co.outp = last;
        co.outbuf[co.outp++] = ' ';
        co.outw += w + 1;
        ++co.outwds;
}


/*
 *      skips the number of lines specified by n.
 */

skip(n)
int n;
{
        int i;

        if (dc.prflg == TRUE && n > 0) {
                for(i=0; i<n; ++i) {
                        prchar('\n',pout);
                }
                prchar('\r',pout);
        }
}



/*
 *      spread words to justify right margin
 */

spread(p,outp,nextra,outwds)
char p[];
int outp,nextra,outwds;
{
        int i,j;
        int nb,ne,nholes;

        if((nextra <= 0) || (outwds <= 1)) return;
        dc.sprdir = ~dc.sprdir;
        ne = nextra;
        nholes = outwds - 1;    /* holes between words */
        i = outp - 1;   /* last non-blank character */
        j = min(MAXLINE-3,i+ne); /* leave room for CR, LF, EOS  */
        while(i < j) {
                p[j] = p[i];
                if(p[i] == ' ') {
                        if(dc.sprdir == 0) nb = (ne - 1)/nholes + 1;
                        else nb = ne/nholes;
                        ne -= nb;
                        --nholes;
                        for(; nb>0; --nb) {
                                --j;
                                p[j] = ' ';
                        }
                }
                --i;
                --j;
        }
}



/*
 *      split overstrikes (backspaces) into seperate buffer
 */

strkovr(p,q)
char *p, *q;
{
        char *pp;
        int bsflg;

        bsflg = FALSE;
        pp = p;
        while (*p != EOS) {
                *q = ' ';
                *pp = *p;
                ++p;
                if (*p == '\b') {
                        if (*pp >= ' ' && *pp <= '~') {
                                bsflg = TRUE;
                                *q = *pp;
                                ++p;
                                *pp = *p;
                                ++p;
                        }
                }
                ++q;
                ++pp;
        }
        *q++ = '\r';
        *q = *pp = EOS;
        return(bsflg);
}



/*
 *      underline a line
 */

underl(p0,p1,size)
char *p0,*p1;
int size;
{
        int i,j;

        j = 0;
        for (i=0; (p0[i] != '\n') && (j < size-1); ++i) {
                if (p0[i] >= ' ' && p0[i] <= '~') {
                        if (isalpha(p0[i]) || isdigit(p0[i]) || dc.cuval > 0) {

                                p1[j++] = '_';
                                p1[j++] = '\b';
                        }
                }
                p1[j++] = p0[i];
        }
        p1[j++] = '\n';
        p1[j] = EOS;
        while (*p1 != EOS) *p0++ = *p1++;
        *p0 = EOS;
}


/*
 *      compute width of character string
 */

width(s)
char *s;
{
        int w;

        w = 0;
        while (*s != EOS) {
                if (*s == '\b') --w;
                else if (*s != '\n' && *s != '\r') ++w;
                ++s;
        }
        return(w);
}


*********
    \an.nro/
*********
.de TH
.in 5
.rm 75
.he |$0 ($1)|$2|$0 ($1)|
.fo ||-#-||
.in 10
.rm 70
.en
.de PP
.sp 1
.ti +5
.en
.de SH
.sp 1
.ti -5
.bo
$0
.br
.en
********
\nrocom.c/
********

/*
 *      external "common" for NRO word processor
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */

struct docctl dc;
struct page pg;
FILE   *oub;
FILE   *pout;
struct cout co;
FILE   *sofile[NFILES]; /* input file buffers   */
struct macros mac;

char newlower(c)
char c;
{
	return (( c >= 'A' && c <= 'Z' ) ? ( c - 'A' + 'a' ) : c) ;
}

bdos(foo,bar)
int foo,bar;
{}


********
\nroxtrn.c/
********
/*
 *      external "common" for NRO word processor
 *
 *      Stephen L. Browning
 *      5723 North Parker Avenue
 *      Indianapolis, Indiana 46220
 */

extern struct docctl dc;
extern struct page pg;
extern FILE   *oub;
extern FILE   *pout;
extern struct cout co;
extern FILE   *sofile[NFILES];  /* input file buffers   */
extern struct macros mac;


*********
\nro.nro/
*********
.TH NRO 1 "Unix V7 Version"
.SH NAME
nro - text processor
.SH SYNOPSIS
.bo
nro [-n] [+n] [-pxx] [-v] [-b] [-mmfile] ifile ... [>ofile]
.SH DESCRIPTION
.ul
NRO
is a text processor and formatter based on the design
provided in 
.bo
"Software Tools"
by Kernighan and Plauger.
The text and commands found in the
.cu
ifile(s)
are processed to
generate formatted text.
The output may be directed into a file or to the printer if
.ul
ofile
is present
in the command line; otherwise, the output will appear at
the user console.
Directing the output to the special filename,
.bo
$P,
will cause the output to be sent to the printer.
.sp
The
.ul
+n
option causes the output to start with page
.ul
n.
The
.ul
-n
option causes the output to stop after page
.ul
n.
.sp
The
.ul
-v
option prints the version number to the console.
.sp
The
.ul
-p
option causes the output to be shifted to the right by
.ul
xx
spaces.
This has the same effect as the
.cc +
+bo
.po
command.
+cc .
.sp
The
.ul
-b
option allows backspaces to appear in the output text when
underlining or overstriking.
This has the same effect as the
.cc +
+bo
.bs
command with a non-zero argument.
+cc .
.sp
The
.ul
-m
option processes the file
.ul
mfile
for macro definitions.
Note that files processed in this way should contain only macro
definitions, no immediate output should be generated from this file.
.sp
Commands typically are distinguished by a period in column one of the input
followed by a two character abbreviation for the command funtion.
The abbreviation may then be followed by an optional numeric or
character argument.
The numeric argument may be an absolute value such as setting
the right margin to a particular column, or the argument may be
preceded by a plus sign or a minus sign to indicate that the
parameter should be modified relative to a previous setting.
The following commands are recognized:
.sp
.nj
.in +6
.br
.ti -6
.cc !
.bo - causes the following lines of text to appear in
boldface.
The optional argument specifies the number of lines to
be typed in boldface.
Boldface and underlining are mutually exclusive features.
The appearance of a boldface command will cause any underlining
to cease.
!sp
!ti -6
.bp - causes succeeding text to appear at the top of
a new page.
The optional argument specifies the page number for the new page.
The initial value is one and the default value is one more than
the previous page number.
!sp
!ti -6
.br - causes succeeding text to start on a new line at the
current left margin.
There is no numeric argument for this command.
!sp
!ti -6
.bs - enables or disables the appearance of backspaces
in the output text.
Underlining and boldface options are implemented by inserting
character - backspace - character combinations into the output
buffer.
This is fine for devices which properly recognize the backspace
character.
Some printers, however, do not recognize backspaces, so the option is
provided to overprint one line buffer with another.
The first line buffer is terminated with just a carriage return
rather than the carriage return - linefeed combination.
A zero argument or no argument to the backspace command removes
backspaces from the output.
A non-zero argument leaves them in the output.
The default is to remove backspaces.
!sp
!ti -6
.cc - changes the
!ul
NRO
command character to that specified by the character argument.
If no argument is provided, the default is a period.
!sp
!ti -6
.ce - causes the next line of text to appear centered on the output.
The optional argument specifies if more than one line is to be centered.
!sp
!ti -6
.de - causes all text and commands following to be used to define
a macro.
The definition is terminated by a
!bo
.en
command.
The first two characters of the argument following the
!bo
.de
command become the name of the new command.
It should be noted that upper and lower case arguments are considered
different.
Thus, the commands
!bo
.PP
and
!bo
.pp
could define two different macros.
Care should be exercised since existing commands may be redefined.
!sp
A macro may contain up to ten arguments.
In the macro definition, the placement of arguments is designated by the
two character sequences, $0, $1, ... $9.
When the macro is invoked, each argument of the macro command line is
substituted for its corresponding designator in the expansion.
The first argument of the macro command is substituted for the $0
in the expansion, the second argument for the $1, and so forth.
Arguments are typically strings which do not contain blanks or tabs.
If an argument is to contain blanks, then it should be surrounded by
either single or double quotes. 
!sp
!ti -6
.cu - causes the next line(s) of text to be continuously underlined.
Unlike the underline command (see
!bo
.ul)
which underlines only alphanumerics, continuous underlining underlines
all printable characters.
The optional argument specifies the number of lines of text to underlined.
Any normal underlining or boldface commands currently in effect will be
terminated.
!sp
!ti -6
.ef - specifies the text for the footer on even numbered pages.
The format is the same as for the footer command (see
!bo
.fo).
!sp
!ti -6
.eh - specifies the text for the header on even numbered pages.
The format is the same as for the footer command (see
!bo
.fo).
!sp
!ti -6
.en - designates the end of a macro definition.
!sp
!ti -6
.fi - causes the input text to be rearranged or filled to obtain the
maximum word count possible between the previously set left and
right margins.
No argument is expected.
!sp
!ti -6
.fo - specifies text to be used for a footer.
The footer text contains three strings seperated by a delimiter
character.
The first non-blank character following the command is designated
as the delimiter.
The first text string is left justified to the current indentation
value (specified by
!bo
.in).
The second string is centered between the current indentation value
and the current right margin value (specified by
!bo
.rm).
The third string is right justified to the current right margin value.
The absence of footer text will result in the footer being printed as
one blank line.
The presence of the page number character (set by
!bo
.pc)
in the footer text results
in the current page number being inserted at that position.
Multiple occurrances of the page number character are allowed.
!sp
!ti -6
.he - specifies text to be used for a header.
The format is the same as for the footer (see
!bo
.fo).
!sp
!ti -6
.in - indents the left margin to the column value specified by the argument.
The default left margin is set to zero.
!sp
!ti -6
.ju - causes blanks to be inserted between words in a line of
output in order to align or justify the right margin.
The default is to justify.
!sp
!ti -6
.ls - sets the line spacing to the value specified by the argument.
The default is for single spacing.
!sp
!ti -6
.m1 - specifies the number of lines in the header margin.
This is the space from the physical top of page to and including
the header text.
A value of zero causes the header to not be printed.
A value of one causes the header to appear at the physical top of page.
Larger argument values cause the appropriate number of blank
lines to appear before the header is printed.
!sp
!ti -6
.m2 - specifies the number of blank lines to be printed between
the header line and the first line of the processed text.
!sp
!ti -6
.m3 - specifies the number of blank lines to be printed between
the last line of processed text and the footer line.
!sp
!ti -6
.m4 - specifies the number of lines in the footer margin.
This command affects the footer the same way the
!bo
.m1
command
affects the header.
!sp
!ti -6
.ne - specifies a number of lines which should not be broken
across a page boundary.
If the number of lines remaining on a page is less than the
value needed, then a new output page is started.
!sp
!ti -6
.nf - specifies that succeeding text should be printed without
rearrangement, or with no fill.
No argument is expected.
!sp
!ti -6
.nj - specifies that no attempt should be made to align or justify
the right margin.
No argument is expected.
!sp
!ti -6
.nr - causes the value of a number register to be set or modified.
A total of twenty-six number registers are available designated
@@na through @@nz (either upper or lower case is allowed).
When the sequence @@nc is imbedded in the text, the current value
of number register c replaces the sequence, thus, such things as
paragraph numbering can be accomplished with relative ease.
!sp
!ti -6
.of - specifies the text for the footer on odd numbered pages.
The format is the same as the footer command (see
!bo
.fo).
!sp
!ti -6
.oh - specifies the text for the header on odd numbered pages.
The format is the same as the footer command (see
!bo
.fo).
!sp
!ti -6
.pc - specifies the page number character to be used in headers
and footers.
The occurrance of this character in the header or footer text
results in the current page number being printed.
The default for this character is the hash mark (#).
!sp
!ti -6
.pl - specifies the page lenght or the number of lines per output page.
The default is sixty-six.
!sp
!ti -6
.po - specifies a page offset value.
This allows the formatted text to be shifted to the right by
the number of spaces specified.
This feature may also be invoked by a switch on the command line.
!sp
!ti -6
.rm - sets the column value for the right margin.
The default is eighty.
!sp
!ti -6
.so - causes input to be retrieved from the file specified
by the command's character string argument.
The contents of the new file are inserted into the output
stream until an EOF is detected.
Processing of the original file is then resumed.
Command nesting is allowed.
!sp
!ti -6
.sp - specifies a number of blank lines to be output before
printing the next line of text.
!sp
!ti -6
.ti - temporarily alters the indentation or left margin value for a single
succeeding line of text.
!sp
!ti -6
.ul - underlines the alphanumeric text in the following line(s).
The optional argument specifies the number of lines to be underlined.
Underlining and boldface are mutually exclusive features.
The appearance of an underline command cancels any existing
boldface operations.


*******
\skelton.nro/
*******
.TH SKELETON 1 "New Manual Name"
.SH NAME
skeleton - sample manual page
.SH SYNOPSIS
.bo
skeleton
[options]
.SH DESCRIPTION
This section describes the program or file.
.SH CAVEATS
.SH EXAMPLES
Just what the name implies.
.SH FILES
an.nro
.SH "RETURN VALUE"
.SH "SEE ALSO"
nro(1),
man(7)
.SH WARNINGS
.SH BUGS
They are everywhere
.SH MISCELLANEOUS
.SH NOTES


******
\newlower/
*******
char newlower(c)
char c;
{
	return (( c >= 'A' && c <= 'Z' ) ? ( c - 'A' + 'a' ) : c) ;
}


*********
\READ_ME/
*********
This version of NRO came from the C User's Group in Yates, Kansas.
The I/O was changed to run under Unix V7 style I/O, and other than that, no
modifications have been made to it.
	In the init() function, pg.lineno must be modified to suit your
printer; it wants the line number the print head is on when you do a top
of form.  On my printer, the way I position the paper, it will start printing
on the second line, so there is a value of 2 there.

	I would be interested in seeing any modifications anyone makes to
this program in the way of extended capabilities, macro packages, and printer
enhancements.  If you have problems in the logic itself, you should contact
the author.

		Happy Hacking,

		Jordan Bortz

		(..decvax!cbosgd!mddc!jordan)


P.S. I tried compiling it on 4.1 BSD, and it didn't work.  It works okay
	on my MS-DOS computer running Computer Innovations Ci C86, so
	there may be portability problems.

   