/*
	Full K&R malloc() and free() for AZTEC C II

This module adapted for the CP/M environment from source code in Brian
W. Kernighan and Dennis M. Ritchie's "The C Programming Language" by
William C. Colley III -- 4 OCT 1982.

This module implements the functions alloc(), morecore(), xsbrk(), and
free() as per pp. 173-7 of Kernighan and Ritchie.  Since xsbrk() is
responsible for preventing collision between the allocated data and
the stack, it must know how much space to leave for the stack.  Thus,
a function rsvstk() is provided to override the default 1024 bytes.

The functions in this package are:

	char *alloc(nb)			allocates a block of nb bytes and
	unsigned nb;			returns a pointer to it.  If no such
					block is available, the value NULL (0)
					is returned.

	free(blk)			Attaches the storage allocation block
	char *blk;			blk to the free list.  Returns no
					meaningful value.

	HEADER *morecore(nb)		Gets a storage allocation block of
	unsigned nb;			size nb from the heap and returns a
					pointer to it.  Returns NULL (0) if
					not enough space is available.

	char *xsbrk(nb)			Gets nb bytes from the heap.  Returns
	unsigned nb;			a pointer to the bytes or -1 if not
					enough bytes are available.

	char *xsettop(nb)		Gets nb bytes from the heap.  Returns
	unsigned nb;			a pointer to the bytes or NULL (0) if
					not enough bytes are available.

	rsvstk(stk)			Changes the minimum allowable remaining
	unsigned stk;			stack size at a call to xsbrk() to stk
					bytes.  Default value is 1024 bytes.
*/

#define	NULL	0

union header {
	struct {
		union header *ptr;
		unsigned size;
		} s;
	long l;
};

typedef union header HEADER;

static HEADER base, *allocp = NULL;

char *alloc(nb)
unsigned nb;
{
	HEADER *morecore();
	register HEADER *p, *q;
	register unsigned nu;

	nu = ((nb + 3) >> 2) + 1;
	if ((q = allocp) == NULL) {
		base.s.ptr = allocp = q = &base;
		base.s.size = 1;
		}
	for (p = q->s.ptr; ; q = p, p = p->s.ptr) {
		if (p->s.size >= nu) {
			if (p->s.size == nu) q->s.ptr = p->s.ptr;
			else {
				p->s.size -= nu;
				p += p->s.size;
				p->s.size = nu;
				}
			allocp = q;  return (char *)(p + 1);
			}
		if (p == allocp)
			if ((p = morecore(nu)) == NULL) return NULL;
		}
}

HEADER *morecore(nu)
unsigned nu;
{
	char *xsbrk();
	register char *cp;
	register HEADER *up;

	if ((int)(cp = xsbrk(nu << 2)) == -1) return NULL;
	up = (HEADER *)cp;
	up->s.size = nu;
	free((char *)(up + 1));
	return allocp;
}

free(blk)
char *blk;
{
	register HEADER *p, *q;

	p = (HEADER *)blk - 1;
	for (q = allocp; !(p > q && p < q->s.ptr); q = q->s.ptr)
		if (q >= q ->s.ptr && (p > q || p < q->s.ptr)) break;

	if (p + p->s.size == q->s.ptr) {
		p->s.size += q->s.ptr->s.size;
		p->s.ptr = q->s.ptr->s.ptr;
		}
	else p->s.ptr = q->s.ptr;
	if (q + q->s.size == p) {
		q->s.size += p->s.size;
		q->s.ptr = p->s.ptr;
		}
	else q->s.ptr = p;
	allocp = q;
}

/*  The functions xsbrk(), xsettop(), and rsvstk() live in the module xsbrk.mac
	as they have to beat on machine things like the stack pointer.	*/

