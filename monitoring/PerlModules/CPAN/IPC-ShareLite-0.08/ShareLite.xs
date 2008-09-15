#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/ipc.h> 
#include "sharelite.h"

/*
 * Some perl version compatibility stuff.
 * Taken from HTML::Parser
 */
#include "patchlevel.h"
#if PATCHLEVEL <= 4 /* perl5.004_XX */

#ifndef PL_sv_undef
   #define PL_sv_undef sv_undef
   #define PL_sv_yes   sv_yes
#endif

#ifndef PL_hexdigit
   #define PL_hexdigit hexdigit
#endif
                                                              
#if (PATCHLEVEL == 4 && SUBVERSION <= 4)
/* The newSVpvn function was introduced in perl5.004_05 */
static SV *
newSVpvn(char *s, STRLEN len)
{
    register SV *sv = newSV(0);
    sv_setpvn(sv,s,len);
    return sv;
}
#endif /* not perl5.004_05 */
#endif /* perl5.004_XX */            

static int
not_here(s)
char *s;
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(name, arg)
     char *name;
     int arg;
{
  errno = 0;
  switch (*name) {
  case 'A':
    break;
  case 'B':
    break;
  case 'C':
    break;
  case 'D':
    break;
  case 'E':
    break;
  case 'F':
    break;
  case 'G':
    if (strEQ(name, "GETALL"))
#ifdef GETALL
      return GETALL;
#else
    goto not_there;
#endif
    if (strEQ(name, "GETNCNT"))
#ifdef GETNCNT
      return GETNCNT;
#else
    goto not_there;
#endif
    if (strEQ(name, "GETPID"))
#ifdef GETPID
      return GETPID;
#else
    goto not_there;
#endif
    if (strEQ(name, "GETVAL"))
#ifdef GETVAL
      return GETVAL;
#else
    goto not_there;
#endif
    if (strEQ(name, "GETZCNT"))
#ifdef GETZCNT
      return GETZCNT;
#else
    goto not_there;
#endif
    break;
  case 'H':
    break;
  case 'I':
    if (strEQ(name, "IPC_ALLOC"))
#ifdef IPC_ALLOC
      return IPC_ALLOC;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_CREAT"))
#ifdef IPC_CREAT
      return IPC_CREAT;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_EXCL"))
#ifdef IPC_EXCL
      return IPC_EXCL;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_NOWAIT"))
#ifdef IPC_NOWAIT
      return IPC_NOWAIT;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_O_RMID"))
#ifdef IPC_O_RMID
      return IPC_O_RMID;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_O_SET"))
#ifdef IPC_O_SET
      return IPC_O_SET;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_O_STAT"))
#ifdef IPC_O_STAT
      return IPC_O_STAT;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_PRIVATE"))
#ifdef IPC_PRIVATE
      return IPC_PRIVATE;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_RMID"))
#ifdef IPC_RMID
      return IPC_RMID;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_SET"))
#ifdef IPC_SET
      return IPC_SET;
#else
    goto not_there;
#endif
    if (strEQ(name, "IPC_STAT"))
#ifdef IPC_STAT
      return IPC_STAT;
#else
    goto not_there;
#endif
    break;
  case 'J':
    break;
  case 'K':
    break;
  case 'L':
    if (strEQ(name, "LOCK_EX"))
#ifdef LOCK_EX 
      return LOCK_EX;
#else
    goto not_there;
#endif              
    if (strEQ(name, "LOCK_SH"))
#ifdef LOCK_SH 
      return LOCK_SH;
#else
    goto not_there;
#endif        
    if (strEQ(name, "LOCK_NB"))
#ifdef LOCK_NB
      return LOCK_NB;
#else
    goto not_there;
#endif             
    if (strEQ(name, "LOCK_UN"))
#ifdef LOCK_UN
      return LOCK_UN;
#else
    goto not_there;
#endif                      
    break;
  case 'M':
    break;
  case 'N':
    break;
  case 'O':
    break;
  case 'P':
    break;
  case 'Q':
    break;
  case 'R':
    break;
  case 'S':
    if (strEQ(name, "SEM_A"))
#ifdef SEM_A
      return SEM_A;
#else
    goto not_there;
#endif
    if (strEQ(name, "SEM_R"))
#ifdef SEM_R
      return SEM_R;
#else
    goto not_there;
#endif
    if (strEQ(name, "SEM_UNDO"))
#ifdef SEM_UNDO
      return SEM_UNDO;
#else
    goto not_there;
#endif
    if (strEQ(name, "SETALL"))
#ifdef SETALL
      return SETALL;
#else
    goto not_there;
#endif
    if (strEQ(name, "SETVAL"))
#ifdef SETVAL
      return SETVAL;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_LOCK"))
#ifdef SHM_LOCK
      return SHM_LOCK;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_R"))
#ifdef SHM_R
      return SHM_R;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_RDONLY"))
#ifdef SHM_RDONLY
      return SHM_RDONLY;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_RND"))
#ifdef SHM_RND
      return SHM_RND;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_SHARE_MMU"))
#ifdef SHM_SHARE_MMU
      return SHM_SHARE_MMU;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_UNLOCK"))
#ifdef SHM_UNLOCK
      return SHM_UNLOCK;
#else
    goto not_there;
#endif
    if (strEQ(name, "SHM_W"))
#ifdef SHM_W
      return SHM_W;
#else
    goto not_there;
#endif
    break;
  case 'T':
    break;
  case 'U':
    break;
  case 'V':
    break;
  case 'W':
    break;
  case 'X':
    break;
  case 'Y':
    break;
  case 'Z':
    break;
  }
  errno = EINVAL;
  return 0;
  
 not_there:
  errno = ENOENT;
  return 0;
}

MODULE = IPC::ShareLite	PACKAGE = IPC::ShareLite

double
constant(name,arg)
	char *		name
	int		arg

Share*
new_share(key, segment_size, flags)
	key_t		key
	int		segment_size
	int		flags

int
write_share(share, data, length)
	Share*		share
	char*		data
        int             length

char* 
read_share(share)
    Share*   share
  PREINIT:
    char*    data; 
    int      length;
  CODE:
    share  = (Share *)SvIV(ST(0));
    length = read_share(share, &data);
    ST(0) = sv_newmortal();
    if (length >= 0) {
      sv_usepvn((SV*)ST(0), data, length);
    } else {
      sv_setsv(ST(0), &PL_sv_undef);
    }
 
int
destroy_share(share, rmid)
	Share*		share
	int		rmid

int
sharelite_lock(share, flags)
	Share*		share
	int		flags

int
sharelite_unlock(share)
	Share*		share

unsigned int
sharelite_version(share)
	Share*		share

int
sharelite_num_segments(share)
	Share*		share
