
/* #define OWNER */
#include "metab.h"

#undef BI
#undef OV
#define OV( a, b, c ) /* */
#define BI( a, b ) a, b,
KEYTAB	keytab[] =
{
#include "mapping.h"
	-1, 0
}
;

int NKEYTAB = (sizeof(keytab)/sizeof(keytab[0]));

#undef BI
#undef OV
#define OV( a, b, c ) a, b, c,
#define BI( a, b ) /* */
struct OVERTAB overtab[] =
{
#include "mapping.h"
	-1, 0, 0,
	-1, 0, 0,
	-1, 0, 0,
	-1, 0, 0,
	-1, 0, 0
};
int NOVERTAB = (sizeof(overtab) / sizeof(overtab[0]));
