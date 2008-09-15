#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "patchlevel.h" 
#if ((PATCHLEVEL >= 4) && (SUBVERSION >= 76)) || (PATCHLEVEL >= 5) 
#define na PL_na 
#endif 

#ifdef PERL_OBJECT
#define sv_name(svp) svp
#define undef(ref) 
#else
static void undef(SV *ref)
{
    GV *gv;
    SV *sv;
    CV *cv;
    I32 has_proto=FALSE;

    if(SvROK(ref))
        sv = SvRV(ref);
    else 
        croak("Apache::Symbol::undef called without a reference!");

    switch (SvTYPE(sv)) {
    case SVt_PVCV:
	cv = (CV*)sv;
	if (!CvXSUB(cv) && CvROOT(cv) && CvDEPTH(cv)) {
	    return; 	    /* subroutine is active */
	}

	gv = (GV*)SvREFCNT_inc(CvGV(cv));
        if(SvPOK(cv)) 
	    has_proto = TRUE;

	cv_undef(cv);
	CvGV(cv) = gv;   /* let user-undef'd sub keep its identity */
        if(has_proto) 
            SvPOK_on(cv); /* otherwise we get `Prototype mismatch:' */

        break;
 
    default:
        warn("Apache::Symbol::undef called without a CODE reference!\n");
    }
}

static SV *sv_name(SV *svp)
{
    SV *sv = Nullsv;
    SV *RETVAL = Nullsv;

    if(svp && SvROK(svp) && (sv = SvRV(svp))) {
	switch(SvTYPE(sv)) {
	case SVt_PVCV:
	    RETVAL = newSV(0);
	    gv_fullname(RETVAL, CvGV(sv));
	    break;

	default:
	    break;
	}
    }
    else if(svp && SvPOK(svp)) {
	RETVAL = newSVsv(svp);
    }

    return RETVAL;
}
#endif

MODULE = Apache::Symbol		PACKAGE = Apache::Symbol		

PROTOTYPES: DISABLE

void
undef(sv)
    SV *sv

SV *
sv_name(sv)
    SV *sv

SV *
cv_const_sv(sv)
    SV* sv
    
    PREINIT:
    CV *cv;
    GV *gv;
    HV *stash;

    CODE:
    
    switch (SvTYPE(sv)) {
    default:
	if (!SvROK(sv)) {
	    char *sym;

	    if (SvGMAGICAL(sv)) {
		mg_get(sv);
		sym = SvPOKp(sv) ? SvPVX(sv) : Nullch;
	    }
	    else
		sym = SvPV(sv, na);
	    if(sym)
		cv = perl_get_cv(sym, TRUE);
	    break;
	}
	cv = (CV*)SvRV(sv);
	if (SvTYPE(cv) == SVt_PVCV)
	    break;

    case SVt_PVHV:
    case SVt_PVAV:
	croak("Not a CODE reference");
    case SVt_PVCV:
	cv = (CV*)sv;
	break;
    case SVt_PVGV:
	if (!(cv = GvCVu((GV*)sv)))
	    cv = sv_2cv(sv, &stash, &gv, TRUE);
	break;
    }

    if(!(RETVAL = cv_const_sv(cv)))
       XSRETURN_UNDEF;
    
    SvREADONLY_off(RETVAL);

    OUTPUT:
    RETVAL
