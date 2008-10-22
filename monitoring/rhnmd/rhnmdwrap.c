#include <sys/types.h>
#include <unistd.h>
#include <grp.h>
#include <security/pam_appl.h>

/* This hack is needed to get around a Red Hat patch that disallows
non-root users to run the sshd binary. */ 

int setgroups(size_t size, const gid_t *list)
{
  return 0;
}
