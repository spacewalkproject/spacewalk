#include "mod_perl.h"

#ifdef PERL_SAFE_STARTUP

static IV opset_len = 0;

static void opmask_add(char *bitmask)
{
    int i,j;
    int myopcode = 0;
    if(!opset_len)
	opset_len = (maxo + 7) / 8;

    for (i=0; i < opset_len; i++) {
	U16 bits = bitmask[i];
	if (!bits) {
	    myopcode += 8;
	    continue;
	}
	for (j=0; j < 8 && myopcode < maxo; )
	    op_mask[myopcode++] |= bits & (1 << j++);
    }
}

#ifdef PERL_DEFAULT_OPMASK

/*PerlOpmask directive is disabled*/
#define op_names_init()
#define get_op_bitspec(op,f) Nullsv
#define set_opset_bits(bitmap, bitspec, on, op)
#define read_opmask(s,p,f) NULL
char *mod_perl_set_opmask(request_rec *r, SV *sv)
{
    croak("Can't override Opmask");
}
#else

static HV *op_named_bits = Nullhv;
static void op_names_init(void)
{
    int i;
    if(op_named_bits) return;
    op_named_bits = newHV();
    for(i=0; i < maxo; ++i) {
	hv_store(op_named_bits, op_name[i], strlen(op_name[i]),
		 newSViv(i), 0);
    }
}

static SV *get_op_bitspec(char *opname, int fatal)
{
    SV **svp;
    int len = strlen(opname);
    svp = hv_fetch(op_named_bits, opname, len, 0);
    if (!svp || !SvOK(*svp)) {
	if(fatal)
	    croak("mod_perl: unknown operator name \"%s\"", opname);
	else
	    return Nullsv;
    }
    return *svp;
}

static void set_opset_bits(char *bitmap, SV *bitspec, int on, char *opname)
{
    if (SvIOK(bitspec)) {
	int myopcode = SvIV(bitspec);
	int offset = myopcode >> 3;
	int bit    = myopcode & 0x07;
	if (myopcode >= maxo || myopcode < 0)
	    croak("mod_perl: opcode \"%s\" value %d is invalid", 
		  opname, myopcode);
	if (on)
	    bitmap[offset] |= 1 << bit;
	else
	    bitmap[offset] &= ~(1 << bit);
    }
    else
	croak("mod_perl: invalid bitspec for \"%s\" (type %u)",
		opname, (unsigned)SvTYPE(bitspec));
}

static char *read_opmask(server_rec *s, pool *p, char *file)
{
#if HAS_MMN_130
    char opname[MAX_STRING_LEN];
    char *mask = (char *)ap_pcalloc(p, maxo);
    configfile_t *cfg = ap_pcfg_openfile(p, file);

    if(!cfg) {
	ap_log_error(APLOG_MARK, APLOG_CRIT, s,
		     "mod_perl: unable to open PerlOpmask file %s", file);
	exit(1);
    }

    op_names_init();
    while (!(ap_cfg_getline(opname, MAX_STRING_LEN, cfg))) {
	SV *bitspec;
	if(*opname == '#') continue;
	if((bitspec = get_op_bitspec(opname, TRUE))) {
	    set_opset_bits(mask, bitspec, TRUE, opname);
	}
    }
    ap_cfg_closefile(cfg);
    return mask;

#else
    croak("Need Apache 1.3.0+ to use PerlOpmask directive");
#endif /*HAS_MMN_130*/
}

static char *av2opmask(pool *p, AV *av)
{
    I32 i;
    char *mask;

    mask = (char *)ap_pcalloc(p, maxo);
    op_names_init();
    for(i=0; i<=AvFILL(av); i++) {
        SV *sv = *av_fetch(av, i, FALSE);
	char *opname = SvPV(sv,na);
	SV *bitspec;

	if((bitspec = get_op_bitspec(opname, TRUE))) {
	    set_opset_bits(mask, bitspec, TRUE, opname);
	}
    }
    return mask;
}

/*
 * $Mask ||= $r->set_opmask([qw(system backtick)]);
 * $r->set_opmask(\$Mask) if $Mask;
 * $r->set_opmask($filename)
 */
char *mod_perl_set_opmask(request_rec *r, SV *sv)
{
    char *mask;
#ifndef PERL_ORALL_OPMASK
    croak("Can't override Opmask");
#endif
    dOPMask;
    SAVEPPTR(op_mask);

    if(SvROK(sv)) {
	if(SvTYPE(SvRV(sv)) == SVt_PVAV) 
	    mask = av2opmask(r->pool, (AV*)SvRV(sv));
	else 
	    mask = SvPV((SV*)SvRV(sv),na);
    }
    else {
	mask = read_opmask(r->server, r->pool, SvPV(sv,na));
    }

    opmask_add(mask);
    MP_TRACE_g(mod_perl_dump_opmask());
    return mask;
}


#endif /*PERL_DEFAULT_OPMASK*/

#include "op_mask.c"

#ifdef PERL_DEFAULT_OPMASK
#define MP_HAS_OPMASK cls
#define MP_DEFAULT_OPMASK 1
#else
#define MP_HAS_OPMASK cls->PerlOpmask
#define MP_DEFAULT_OPMASK !strcasecmp(cls->PerlOpmask, "default")
#endif

#if 0
static char *default_opmask = NULL;

static void reset_default_opmask(void *data)
{
    char *mask = (char *)data;
    mask = NULL;
}
#endif

void mod_perl_init_opmask(server_rec *s, pool *p)
{
    dPSRV(s);
    char *local_opmask = NULL;

    if(!MP_HAS_OPMASK)
	return;

    if(MP_DEFAULT_OPMASK) {
#if 0
	if(!default_opmask) {
	    default_opmask = uudecode(p, MP_op_mask);
	    register_cleanup(p, (void*)default_opmask, 
			     reset_default_opmask, mod_perl_noop);
	}
#endif
	local_opmask = uudecode(p, MP_op_mask);
	MP_TRACE_g(fprintf(stderr, "mod_perl: using PerlOpmask %s\n",
		   cls->PerlOpmask ? cls->PerlOpmask : "__DEFAULT__"));
    }
    else {
	MP_TRACE_g(fprintf(stderr, "mod_perl: using PerlOpmask %s\n",
		   cls->PerlOpmask));
	local_opmask = read_opmask(s, p, 
				   server_root_relative(p, cls->PerlOpmask));
    }

    opmask_add(local_opmask);
}

void mod_perl_dump_opmask(void)
{
#ifdef PERL_TRACE
    int i;
    if(!op_mask) return;
    fprintf(stderr, "op_mask=\n");
    for(i=0; i < maxo; i++) {
	if(!op_mask[i]) continue;
	fprintf(stderr, "%s (%s)\n", op_name[i], op_desc[i]);
    }
#endif
}

#else

void mod_perl_init_opmask(server_rec *s, pool *p)
{
}

void mod_perl_dump_opmask(void)
{
}

char *mod_perl_set_opmask(request_rec *r, SV *sv)
{
    croak("Can't override Opmask");
	return NULL; /* C++ emits an error message otherwise
				  * because of a missing return value.
				  */
}
#endif /*PERL_SAFE_STARTUP*/
