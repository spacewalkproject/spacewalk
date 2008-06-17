#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


MODULE = FcntlLock		PACKAGE = FcntlLock		

int
lock_ex(file)
        FILE *file
        PREINIT:
        int rv;
        int fd;
        struct flock lck;
        PPCODE:
        fd = fileno(file);
        lck.l_type   = (short)F_WRLCK;
        lck.l_whence = (short)SEEK_SET;
        lck.l_start  = (off_t)0;
        lck.l_len    = (off_t)0;

        rv = fcntl(fd, F_SETLK, &lck);

        EXTEND(SP, 1);
        PUSHs(sv_2mortal(newSViv(rv)));

int
lock_sh(file)
        FILE *file
        PREINIT:
        int rv;
        int fd;
        struct flock lck;
        PPCODE:
        fd = fileno(file);
        lck.l_type   = (short)F_RDLCK;
        lck.l_whence = (short)SEEK_SET;
        lck.l_start  = (off_t)0;
        lck.l_len    = (off_t)0;

        rv = fcntl(fd, F_SETLK, &lck);

        EXTEND(SP, 1);
        PUSHs(sv_2mortal(newSViv(rv)));

int
lock_un(file)
        FILE *file
        PREINIT:
        int rv;
        int fd;
        struct flock lck;
        PPCODE:
        fd = fileno(file);
        lck.l_type   = (short)F_UNLCK;
        lck.l_whence = (short)SEEK_SET;
        lck.l_start  = (off_t)0;
        lck.l_len    = (off_t)0;

        rv = fcntl(fd, F_SETLK, &lck);

        EXTEND(SP, 1);
        PUSHs(sv_2mortal(newSViv(rv)));

