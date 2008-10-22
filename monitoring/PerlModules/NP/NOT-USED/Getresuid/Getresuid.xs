#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


MODULE = Getresuid		PACKAGE = Getresuid		

void
getresuid()
        PREINIT:
        uid_t ruid;
        uid_t euid;
        uid_t suid;
        PPCODE:
        getresuid(&ruid, &euid, &suid);
        EXTEND(SP, 3);
        PUSHs(sv_2mortal(newSViv(ruid)));
        PUSHs(sv_2mortal(newSViv(euid)));
        PUSHs(sv_2mortal(newSViv(suid)));


void
getresgid()
        PREINIT:
        gid_t rgid;
        gid_t egid;
        gid_t sgid;
        PPCODE:
        getresgid(&rgid, &egid, &sgid);
        EXTEND(SP, 3);
        PUSHs(sv_2mortal(newSViv(rgid)));
        PUSHs(sv_2mortal(newSViv(egid)));
        PUSHs(sv_2mortal(newSViv(sgid)));



int
setresuid(ruid, euid, suid)
        int ruid
        int euid
        int suid


int
setresgid(rgid, egid, sgid)
        int rgid
        int egid
        int sgid
