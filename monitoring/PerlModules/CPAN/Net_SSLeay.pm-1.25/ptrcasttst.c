#include <stdlib.h>
#include <stdio.h>

/* test if a pointer can be cast to an unsigned long int and back
   (aspa@hip.fi)

   tested on: HP-UX B.10.20, AIX 4.3, IRIX 5.3, OSF1 v4.0B and SunOS 5.6
   with both gcc and native compilers, and linux/gcc (i686) +
   linux/gcc (alpha).

*/

#define FROMTYPE void *
#define FROMTYPESTR "void *"
#define TOTYPE unsigned long int
#define TOTYPESTR "unsigned long int"

int main(argc, argv)
     int argc; /* e.g. HP-UX cc doesn't support ISO C by default */
     char *argv[];
{
  /* heap should be near the end of process's address space */
  FROMTYPE bufptr = (FROMTYPE) malloc(500);
  volatile TOTYPE i; /* prevent optimization */

  printf("%s: '%s' len: %d, '%s' len: %d.\n", argv[0], FROMTYPESTR,
	 sizeof(TOTYPE), TOTYPESTR, sizeof(char *));

  i = (TOTYPE)bufptr;
  if( ((FROMTYPE)i) != bufptr ) {
    printf("%s: failed: (%p != %p).\n", argv[0], (FROMTYPE)i, bufptr);
    printf("ERROR: a '%s' can't be cast to a '%s' and back \n",
	   FROMTYPESTR, TOTYPESTR);
    printf("ERROR: without loss of information on this architecture.\n");
    exit(1);
  } else {
    printf("ptrcasttst: ok (%p == %p).\n", (FROMTYPE)i, bufptr);
    exit(0);
  }

  exit(1);
}

