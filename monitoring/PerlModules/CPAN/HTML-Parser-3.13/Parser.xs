/* $Id: Parser.xs,v 1.1 2000-10-13 20:26:51 dfaraldo Exp $
 *
 * Copyright 1999-2000, Gisle Aas.
 * Copyright 1999-2000, Michael A. Chase.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */


/*
 * Standard XS greeting.
 */
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif



/*
 * Some perl version compatibility gruff.
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

#if 0 /* Makefile.PL option now */ && (PATCHLEVEL >= 6)
#define UNICODE_ENTITIES /**/
#endif /* perl-5.6 or better */

#ifndef MEMBER_TO_FPTR
   #define MEMBER_TO_FPTR(x) (x)
#endif

/*
 * Include stuff.  We include .c files instead of linking them,
 * so that they don't have to pollute the external dll name space.
 */

#ifdef EXTERN
  #undef EXTERN
#endif

#define EXTERN static /* Don't pollute */

EXTERN
HV* entity2char;            /* %HTML::Entities::entity2char */

#include "hparser.h"
#include "util.c"
#include "hparser.c"


/*
 * Support functions for the XS glue
 */

static SV*
check_handler(SV* h)
{
  if (SvROK(h)) {
    SV* myref = SvRV(h);
    if (SvTYPE(myref) == SVt_PVCV)
      return newSVsv(h);
    if (SvTYPE(myref) == SVt_PVAV)
      return SvREFCNT_inc(myref);
    croak("Only code or array references allowed as handler");
  }
  return SvOK(h) ? newSVsv(h) : 0;
}


static PSTATE*
get_pstate_iv(SV* sv)
{
    PSTATE* p = (PSTATE*)SvIV(sv);
    if (p->signature != P_SIGNATURE)
      croak("Bad signature in parser state object at %p", p);
    return p;
}


static PSTATE*
get_pstate_hv(SV* sv)                               /* used by XS typemap */
{
  HV* hv;
  SV** svp;

  sv = SvRV(sv);
  if (!sv || SvTYPE(sv) != SVt_PVHV)
    croak("Not a reference to a hash");
  hv = (HV*)sv;
  svp = hv_fetch(hv, "_hparser_xs_state", 17, 0);
  if (svp) {
    if (SvROK(*svp))
      return get_pstate_iv(SvRV(*svp));
    else
      croak("_hparser_xs_state element is not a reference");
  }
  croak("Can't find '_hparser_xs_state' element in HTML::Parser hash");
  return 0;
}


static void
free_pstate(PSTATE* pstate)
{
  int i;
  SvREFCNT_dec(pstate->buf);
  SvREFCNT_dec(pstate->pend_text);
#ifdef MARKED_SECTION
  SvREFCNT_dec(pstate->ms_stack);
#endif
  SvREFCNT_dec(pstate->bool_attr_val);
  for (i = 0; i < EVENT_COUNT; i++) {
    SvREFCNT_dec(pstate->handlers[i].cb);
    SvREFCNT_dec(pstate->handlers[i].argspec);
  }
  pstate->signature = 0;
  Safefree(pstate);
}


#ifndef pTHX_
#define pTHX_
#endif

static int
magic_free_pstate(pTHX_ SV *sv, MAGIC *mg)
{
  free_pstate(get_pstate_iv(sv));
  return 0;
}


MGVTBL vtbl_free_pstate = {0, 0, 0, 0, MEMBER_TO_FPTR(magic_free_pstate)};



/*
 *  XS interface definition.
 */

MODULE = HTML::Parser		PACKAGE = HTML::Parser

PROTOTYPES: DISABLE

void
_alloc_pstate(self)
	SV* self;
    PREINIT:
	PSTATE* pstate;
	SV* sv;
	HV* hv;
        MAGIC* mg;

    CODE:
	sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV)
            croak("Not a reference to a hash");
	hv = (HV*)sv;

	Newz(56, pstate, 1, PSTATE);
	pstate->signature = P_SIGNATURE;

	sv = newSViv((IV)pstate);
	sv_magic(sv, 0, '~', 0, 0);
	mg = mg_find(sv, '~');
        assert(mg);
        mg->mg_virtual = &vtbl_free_pstate;
	SvREADONLY_on(sv);

	hv_store(hv, "_hparser_xs_state", 17, newRV_noinc(sv), 0);

SV*
parse(self, chunk)
	SV* self;
	SV* chunk
    PREINIT:
	PSTATE* p_state = get_pstate_hv(self);
    CODE:
	if (p_state->parsing)
    	    croak("Parse loop not allowed");
        p_state->parsing = 1;
	parse(p_state, chunk, self);
        p_state->parsing = 0;
	if (p_state->eof) {
	    p_state->eof = 0;
            ST(0) = sv_newmortal();
        }

SV*
eof(self)
	SV* self;
    PREINIT:
	PSTATE* p_state = get_pstate_hv(self);
    CODE:
        if (p_state->parsing)
            p_state->eof = 1;
        else
	    parse(p_state, 0, self); /* flush */

SV*
strict_comment(pstate,...)
	PSTATE* pstate
    ALIAS:
	HTML::Parser::strict_comment = 1
	HTML::Parser::strict_names = 2
        HTML::Parser::xml_mode = 3
	HTML::Parser::unbroken_text = 4
        HTML::Parser::marked_sections = 5
    PREINIT:
	bool *attr;
    CODE:
        switch (ix) {
	case  1: attr = &pstate->strict_comment;       break;
	case  2: attr = &pstate->strict_names;         break;
	case  3: attr = &pstate->xml_mode;             break;
	case  4: attr = &pstate->unbroken_text;        break;
        case  5:
#ifdef MARKED_SECTION
		 attr = &pstate->marked_sections;      break;
#else
	         croak("marked sections not supported"); break;
#endif
	default:
	    croak("Unknown boolean attribute (%d)", ix);
        }
	RETVAL = boolSV(*attr);
	if (items > 1)
	    *attr = SvTRUE(ST(1));
    OUTPUT:
	RETVAL

SV*
boolean_attribute_value(pstate,...)
        PSTATE* pstate
    CODE:
	RETVAL = pstate->bool_attr_val ? newSVsv(pstate->bool_attr_val)
				       : &PL_sv_undef;
	if (items > 1) {
	    SvREFCNT_dec(pstate->bool_attr_val);
	    pstate->bool_attr_val = newSVsv(ST(1));
        }
    OUTPUT:
	RETVAL

SV*
handler(pstate, eventname,...)
	PSTATE* pstate
	SV* eventname
    PREINIT:
	SV* self = ST(0);
	STRLEN name_len;
	char *name = SvPV(eventname, name_len);
        int event = -1;
        int i;
        struct p_handler *h;
    CODE:
	/* map event name string to event_id */
	for (i = 0; i < EVENT_COUNT; i++) {
	    if (strEQ(name, event_id_str[i])) {
	        event = i;
	        break;
	    }
	}
        if (event < 0)
	    croak("No handler for %s events", name);

	h = &pstate->handlers[event];

	/* set up return value */
	if (h->cb) {
	    ST(0) = (SvTYPE(h->cb) == SVt_PVAV)
	                 ? sv_2mortal(newRV_inc(h->cb))
	                 : sv_2mortal(newSVsv(h->cb));
	}
        else {
	    ST(0) = &PL_sv_undef;
        }

        /* update */
        if (items > 3) {
	    SvREFCNT_dec(h->argspec);
	    h->argspec = 0;
	    h->argspec = argspec_compile(ST(3));
	}
        if (items > 2) {
	    SvREFCNT_dec(h->cb);
            h->cb = 0;
	    h->cb = check_handler(ST(2));
	}


MODULE = HTML::Parser		PACKAGE = HTML::Entities

void
decode_entities(...)
    PREINIT:
        int i;
    PPCODE:
	if (GIMME_V == G_SCALAR && items > 1)
            items = 1;
	for (i = 0; i < items; i++) {
	    if (GIMME_V != G_VOID)
	        ST(i) = sv_2mortal(newSVsv(ST(i)));
	    else if (SvREADONLY(ST(i)))
		croak("Can't inline decode readonly string");
	    decode_entities(ST(i), entity2char);
	}
	SP += items;

int
UNICODE_SUPPORT()
    PROTOTYPE:
    CODE:
#ifdef UNICODE_ENTITIES
       RETVAL = 1;
#else
       RETVAL = 0;
#endif
    OUTPUT:
       RETVAL


MODULE = HTML::Parser		PACKAGE = HTML::Parser

BOOT:
    entity2char = perl_get_hv("HTML::Entities::entity2char", TRUE);
