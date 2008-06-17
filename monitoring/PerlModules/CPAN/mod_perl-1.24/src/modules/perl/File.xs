
#include "mod_perl.h"

#define ap_fopen(r, name, mode) \
        ap_pfopen(r->pool, name, mode)
#define ap_fclose(r, fd) \
        ap_pfclose(r->pool, fd)

#define ap_mtime(r) r->mtime

#ifndef SvCLASS
#define SvCLASS(o) HvNAME(SvSTASH(SvRV(o)))
#endif

static bool ApacheFile_open(SV *obj, SV *sv)
{
    PerlIO *IOp = Nullfp;
    GV *gv = (GV*)SvRV(obj);
    STRLEN len;
    char *filename = SvPV(sv,len);

    return do_open(gv, filename, len, FALSE, 0, 0, IOp); 
}

static SV *ApacheFile_new(char *pclass)
{
    SV *RETVAL = sv_newmortal();
    GV *gv = newGVgen(pclass);
    HV *stash = GvSTASH(gv);

    sv_setsv(RETVAL, sv_bless(sv_2mortal(newRV((SV*)gv)), stash));
    (void)hv_delete(stash, GvNAME(gv), GvNAMELEN(gv), G_DISCARD);
    return RETVAL;
}

#if 0

static char *ApacheFile_basename(SV *self, const char *filename)
{
    char *RETVAL = strrchr(filename, '/'); 
    ++RETVAL;
    return RETVAL;
}

static SV *ApacheFile_dirname(SV *self, const char *filename)
{
    SV *RETVAL = newSVpv(ap_make_dirstr_parent(perl_get_util_pool(), filename), 0);
    *(SvEND(RETVAL) - 1) = '\0';
    --SvCUR(RETVAL); 
    return RETVAL;
}

typedef struct {
    SV *base;
    SV *ext;
} AFparsed;

AFparsed *ApacheFile_parse(SV *fname, SV *pattern)
{
    AFparsed *afp = (AFparsed *)safemalloc(sizeof(AFparsed));
    regexp *re;
    PMOP pm;
    STRLEN len;
    STRLEN slen;
    char *s = SvPV(pattern,len), *ptr = SvPV(fname,slen);
    Zero(&pm,1,PMOP);
    re = Perl_pregcomp(s, s+len, &pm);
    Perl_pregexec(re, ptr, ptr+slen, ptr, 0, Nullsv, 1);
    if (re->endp[1]) {
	afp->ext = sv_newmortal();
	afp->base = sv_newmortal();
	sv_setpvn(afp->ext, re->startp[1], re->endp[1] - re->startp[1]);
	sv_setpvn(afp->base, ptr, slen - SvCUR(afp->ext));
    }
    else {
	afp->ext = &sv_undef;
	afp->base = sv_2mortal(newSVsv(fname));
    }
    Perl_pregfree(re);
    return afp;
}
#endif

MODULE = Apache::File		PACKAGE = Apache::File    PREFIX = ApacheFile_

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

void
ApacheFile_new(pclass, filename=Nullsv)
    char *pclass
    SV *filename

    PREINIT:
    SV *RETVAL;

    PPCODE:
    RETVAL = ApacheFile_new(pclass);
    if(filename) {
	if(!ApacheFile_open(RETVAL, filename))
	    XSRETURN_UNDEF;
    }
    XPUSHs(RETVAL);

bool
ApacheFile_open(self, filename)
    SV *self
    SV *filename

#if 0

void
ApacheFile_tmp(self)
    SV *self

    PREINIT:
    PerlIO *fp = PerlIO_tmpfile();
    char *pclass = SvROK(self) ? SvCLASS(self) : SvPV(self,na);
    SV *RETVAL = ApacheFile_new(pclass);

    PPCODE:
    if(!do_open((GV*)SvRV(RETVAL), "+>&", 3, FALSE, 0, 0, fp))
        XSRETURN_UNDEF;
    else
        XPUSHs(RETVAL);

#endif

bool
ApacheFile_close(self)
    SV *self
    
    CODE:
    RETVAL = do_close((GV*)SvRV(self), TRUE);

    OUTPUT:
    RETVAL

#if 0
 
SV *
ApacheFile_dirname(self, filename)
    SV *self
    const char *filename

char *
ApacheFile_basename(self, filename)
    SV *self
    const char *filename

void
parse(self, filename, pattern)
    SV *self
    SV *filename
    SV *pattern

    PREINIT:
    SV *name, *path, *base, *par = newSVpv("",0);
    AFparsed *afp;

    PPCODE:
    path = ApacheFile_dirname(self, SvPVX(filename));
    sv_2mortal(path);
    base = newSVpv(ApacheFile_basename(self, SvPVX(filename)),0);
    sv_setpvf(par, "%c%_%c", '(', pattern, ')');
    afp = ApacheFile_parse(base, par);
    EXTEND(sp, 3); PUSHs(afp->base); PUSHs(path); PUSHs(afp->ext);
    safefree(afp); SvREFCNT_dec(base); SvREFCNT_dec(par);

#endif

MODULE = Apache::File  PACKAGE = Apache   PREFIX = ap_

PROTOTYPES: DISABLE

int
ap_set_content_length(r, clength=r->finfo.st_size)
    Apache r
    long clength

void
ap_set_last_modified(r, mtime=0)
    Apache r
    time_t mtime

    CODE:
    if(mtime) ap_update_mtime(r, mtime);
    ap_set_last_modified(r);

void
ap_set_etag(r)
    Apache r

int
ap_meets_conditions(r)
    Apache r

time_t
ap_update_mtime(r, dependency_mtime=r->finfo.st_mtime)
    Apache r
    time_t dependency_mtime

time_t
ap_mtime(r)
    Apache r

int
ap_discard_request_body(r)
    Apache r

int
ap_set_byterange(r)
    Apache r

void
ap_each_byterange(r)
    Apache r

    PREINIT:
    long offset, length;

    PPCODE:
    if (!ap_each_byterange(r, &offset, &length)) {
	XSRETURN_EMPTY;
    }
    EXTEND(sp, 2);
    PUSHs(sv_2mortal(newSViv(offset)));
    PUSHs(sv_2mortal(newSViv(length)));
