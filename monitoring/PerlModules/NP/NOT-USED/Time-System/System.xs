#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <sys/time.h>
#include <unistd.h>


MODULE = Time::System		PACKAGE = Time::System		

void
_gettimeofday()
        PREINIT:
        struct timeval tv;
        PPCODE:
        gettimeofday(&tv, (struct timezone *)0);
        EXTEND(SP, 2);
        PUSHs(sv_2mortal(newSViv(tv.tv_sec)));
        PUSHs(sv_2mortal(newSViv(tv.tv_usec)));

int
_settimeofday(sec, usec)
	long sec
	long usec
        PREINIT:
        struct timeval tv;
	int rv;
        PPCODE:
	tv.tv_sec = sec;
	tv.tv_usec = usec;
        rv = settimeofday(&tv, (struct timezone *)0);
	EXTEND(SP, 1);
	PUSHs(sv_2mortal(newSViv(rv)));


