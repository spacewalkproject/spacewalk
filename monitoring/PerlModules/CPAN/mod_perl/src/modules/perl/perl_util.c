/* ====================================================================
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 1996-2000 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Apache" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 */

#include "mod_perl.h"

static HV *mod_perl_endhv = Nullhv;
static int set_ids = 0;

void perl_util_cleanup(void)
{
    hv_undef(mod_perl_endhv);
    SvREFCNT_dec((SV*)mod_perl_endhv);
    mod_perl_endhv = Nullhv;

    set_ids = 0;
}

SV *array_header2avrv(array_header *arr)
{
    AV *av;
    int i;
    dTHR;

    iniAV(av);
    if(arr) {
	for (i = 0; i < arr->nelts; i++) {
	    av_push(av, newSVpv(((char **) arr->elts)[i], 0));
	}
    }
    return newRV_noinc((SV*)av);
}

array_header *avrv2array_header(SV *avrv, pool *p)
{
    AV *av = (AV*)SvRV(avrv);
    I32 i;
    array_header *arr = make_array(p, AvFILL(av)-1, sizeof(char *));

    for(i=0; i<=AvFILL(av); i++) {
	SV *sv = *av_fetch(av, i, FALSE);    
	char **entry = (char **) push_array(arr);
	*entry = pstrdup(p, SvPV(sv,na));
    }

    return arr;
}

table *hvrv2table(SV *rv)
{
    if(SvROK(rv) && SvTYPE(SvRV(rv)) == SVt_PVHV) {
	SV *sv = perl_hvrv_magic_obj(rv);
	if(!sv) croak("HV is not magic!");
	return (table *)SvIV((SV*)SvRV(sv));
    }
    return (table *)SvIV((SV*)SvRV(rv));
}

static char *r_keys[] = { "_r", "r", NULL };

static request_rec *r_magic_get(SV *sv)
{
    MAGIC *mg  = mg_find(sv, '~');
    return mg ? (request_rec *)mg->mg_ptr : NULL;
}

request_rec *sv2request_rec(SV *in, char *pclass, CV *cv)
{
    request_rec *r = NULL;
    SV *sv = Nullsv;

    if(in == &sv_undef) return NULL;

    if(SvROK(in) && (SvTYPE(SvRV(in)) == SVt_PVHV)) {
	int i;
	for (i=0; r_keys[i]; i++) {
	    int klen = strlen(r_keys[i]);
	    if(hv_exists((HV*)SvRV(in), r_keys[i], klen) &&
	       (sv = *hv_fetch((HV*)SvRV(in), 
			       r_keys[i], klen, FALSE)))
		break;
	}
	if(!sv)
	    croak("method `%s' invoked by a `%s' object with no `r' key!",
		  GvNAME(CvGV(cv)), HvNAME(SvSTASH(SvRV(in))));
    }

    if(!sv) sv = in;
    if(SvROK(sv) && (SvTYPE(SvRV(sv)) == SVt_PVMG)) {
	if(sv_derived_from(sv, pclass)) {
	    if((r = r_magic_get(SvRV(sv)))) {
		/* ~ magic */
	    }
	    else {
		r = (request_rec *) SvIV((SV*)SvRV(sv));
	    }
	}
	else {
	    return NULL;
	}
    }
    else if((r = perl_request_rec(NULL))) {
	/*ok*/
    } 
    else {
	croak("Apache->%s called without setting Apache->request!",
	      GvNAME(CvGV(cv)));
    }
    return r;
}

pool *perl_get_util_pool(void)
{
    request_rec *r = NULL;

    if((r = perl_request_rec(NULL)))
        return r->pool;
    else
        return perl_get_startup_pool();
    return NULL;
}

pool *perl_get_startup_pool(void)
{
    SV *sv = perl_get_sv("Apache::__POOL", FALSE);
    if(sv) {
	IV tmp = SvIV((SV*)SvRV(sv));
	return (pool *)tmp;
    }
    return NULL;
}

server_rec *perl_get_startup_server(void)
{
    SV *sv = perl_get_sv("Apache::__SERVER", FALSE);
    if(sv) {
	IV tmp = SvIV((SV*)SvRV(sv));
	return (server_rec *)tmp;
    }
    return NULL;
}

void mod_perl_untaint(SV *sv)
{
    if(!tainting) return;
    if (SvTYPE(sv) >= SVt_PVMG && SvMAGIC(sv)) {
	MAGIC *mg = mg_find(sv, 't');
	if (mg)
	    mg->mg_len &= ~1;
    }
}

/* same as Symbol::gensym() */
SV *mod_perl_gensym (char *pack)
{
    GV *gv = newGVgen(pack);
    SV *rv = newRV((SV*)gv);
    (void)hv_delete(gv_stashpv(pack, TRUE), 
		    GvNAME(gv), GvNAMELEN(gv), G_DISCARD);
    return rv;
}

SV *mod_perl_slurp_filename(request_rec *r)
{
    dTHR;
    PerlIO *fp;
    SV *insv;

    ENTER;
    save_item(rs);
    sv_setsv(rs, &sv_undef); 

    fp = PerlIO_open(r->filename, "r");
    insv = newSV(r->finfo.st_size);
    sv_gets(insv, fp, 0); /*slurp*/
    PerlIO_close(fp);
    LEAVE;
    return newRV_noinc(insv);
}

SV *mod_perl_tie_table(table *t)
{
    HV *hv = newHV();
    SV *sv = sv_newmortal();

    sv_setref_pv(sv, "Apache::table", (void*)t);
    perl_tie_hash(hv, "Apache::Table", sv);
    return sv_bless(sv_2mortal(newRV_noinc((SV*)hv)), 
		    gv_stashpv("Apache::Table", TRUE));
}

SV *perl_hvrv_magic_obj(SV *rv)
{
    HV *hv = (HV*)SvRV(rv); 
    MAGIC *mg;
    if(SvMAGICAL(hv) && (mg = mg_find((SV*)hv, 'P'))) 
        return mg->mg_obj;
    else
	return Nullsv;
}


void perl_tie_hash(HV *hv, char *pclass, SV *sv)
{
    dSP;
    SV *obj, *varsv = (SV*)hv;
    char *methname = "TIEHASH";
    dTHRCTX;

    ENTER;
    SAVETMPS;
    PUSHMARK(sp);
    XPUSHs(sv_2mortal(newSVpv(pclass,0)));
    if(sv) XPUSHs(sv);
    PUTBACK;
    perl_call_method(methname, G_EVAL | G_SCALAR);
    if(SvTRUE(ERRSV)) warn("perl_tie_hash: %s", SvPV(ERRSV,na));

    SPAGAIN;

    obj = POPs;
    sv_unmagic(varsv, 'P');
    sv_magic(varsv, obj, 'P', Nullch, 0);

    PUTBACK;
    FREETMPS;
    LEAVE; 
}

/* execute END blocks */

void perl_run_blocks(I32 oldscope, AV *subs)
{
    STRLEN len;
    I32 i;
    dTHR;
    dTHRCTX;

    for(i=0; i<=AvFILL(subs); i++) {
	CV *cv = (CV*)*av_fetch(subs, i, FALSE);
	SV* atsv = ERRSV;

	MARK_WHERE("END block", (SV*)cv);
	PUSHMARK(stack_sp);
	perl_call_sv((SV*)cv, G_EVAL|G_DISCARD);
	UNMARK_WHERE;
	(void)SvPV(atsv, len);
	if (len) {
	    if (subs == beginav)
		sv_catpv(atsv, "BEGIN failed--compilation aborted");
	    else
		sv_catpv(atsv, "END failed--cleanup aborted");
	    while (scopestack_ix > oldscope)
		LEAVE;
	}
    }
}

void mod_perl_clear_rgy_endav(request_rec *r, SV *sv)
{
    STRLEN klen;
    char *key;

    if(!mod_perl_endhv) return;

    key = SvPV(sv,klen);
    if(hv_exists(mod_perl_endhv, key, klen)) {
	SV *entry = *hv_fetch(mod_perl_endhv, key, klen, FALSE);
	AV *av;
	if(!SvTRUE(entry) && !SvROK(entry)) {
	    MP_TRACE_g(fprintf(stderr, "endav is empty for %s\n", r->uri));
	    return;
	}
	av = (AV*)SvRV(entry);
	av_clear(av);
	SvREFCNT_dec((SV*)av);
	(void)hv_delete(mod_perl_endhv, key, klen, G_DISCARD);
	MP_TRACE_g(fprintf(stderr, 
			 "clearing END blocks for package `%s' (uri=%s)\n",
			 key, r->uri)); 
    }
}

void perl_stash_rgy_endav(char *s, SV *rgystash)
{
    AV *rgyendav = Nullav;
    STRLEN klen;
    char *key;
    dTHR;

    if(!rgystash) 
	rgystash = perl_get_sv("Apache::Registry::curstash", FALSE);

    if(!rgystash || !SvTRUE(rgystash)) {
	MP_TRACE_g(fprintf(stderr, 
        "Apache::Registry::curstash not set, can't stash END blocks for %s\n",
			 s));
	return;
    }

    key = SvPV(rgystash,klen);

    if(mod_perl_endhv == Nullhv)
	mod_perl_endhv = newHV();
    else if(hv_exists(mod_perl_endhv, key, klen)) {
	SV *entry = *hv_fetch(mod_perl_endhv, key, klen, FALSE);
	if(SvTRUE(entry) && SvROK(entry)) 
	    rgyendav = (AV*)SvRV(entry);
    }

    if(endav) {
	I32 i;
	if(rgyendav == Nullav)
	    rgyendav = newAV();

	if(AvFILL(rgyendav) > -1)
	    av_clear(rgyendav);
	else
	    av_extend(rgyendav, AvFILL(endav));

	for(i=0; i<=AvFILL(endav); i++) {
	    SV **svp = av_fetch(endav, i, FALSE);
	    av_store(rgyendav, i, (SV*)newRV((SV*)*svp));
	}
    }

    if(rgyendav)
	hv_store(mod_perl_endhv, key, klen, (SV*)newRV((SV*)rgyendav), FALSE);
}

void perl_run_rgy_endav(char *s) 
{
    SV *rgystash = perl_get_sv("Apache::Registry::curstash", FALSE);
    AV *rgyendav = Nullav;
    STRLEN klen;
    char *key;
    dTHR;

    if(!rgystash || !SvTRUE(rgystash)) {
	MP_TRACE_g(fprintf(stderr, 
        "Apache::Registry::curstash not set, can't run END blocks for %s\n",
			 s));
	return;
    }

    key = SvPV(rgystash,klen);

    if(hv_exists(mod_perl_endhv, key, klen)) {
	SV *entry = *hv_fetch(mod_perl_endhv, key, klen, FALSE);
	if(SvTRUE(entry) && SvROK(entry)) 
	    rgyendav = (AV*)SvRV(entry);
    }

    MP_TRACE_g(fprintf(stderr, 
	     "running %d END blocks for %s\n", rgyendav ? (int)AvFILL(rgyendav)+1 : 0, s));
    ENTER;
    save_aptr(&endav); 
    if((endav = rgyendav)) 
	perl_run_blocks(scopestack_ix, endav);
    LEAVE;
    sv_setpv(rgystash,"");
}

void perl_run_endav(char *s)
{
    dTHR;
    I32 n = 0;
    if(endav)
	n = AvFILL(endav)+1;

    MP_TRACE_g(fprintf(stderr, "running %d END blocks for %s\n", 
		       (int)n, s));
    if(endav) {
	curstash = defstash;
	call_list(scopestack_ix, endav);
    }
}

static I32
errgv_empty_set(IV ix, SV* sv)
{ 
    sv_setsv(sv, &sv_no);
    return TRUE;
}

void perl_call_halt(int status)
{
    dTHR;
    struct ufuncs umg;
    int is_http_code = 
	((status >= 100) && (status < 600) && ERRSV_CAN_BE_HTTP);
    dTHRCTX;

    umg.uf_val = errgv_empty_set;
    umg.uf_set = errgv_empty_set;
    umg.uf_index = (IV)0;
    
    if(is_http_code) {
	croak("%d\n", status);
    }
    else {
	sv_magic(ERRSV, Nullsv, 'U', (char*) &umg, sizeof(umg));

	ENTER;
	SAVESPTR(diehook);
	diehook = Nullsv; 
	croak("");
	LEAVE; /* we don't get this far, but croak() will rewind */

	sv_unmagic(ERRSV, 'U');
    }
}

/*
 * reload %INC: cannot do so while iterating over %INC incase
 * reloaded modules modify %INC at the file-scope
 * this approach also preserves order for modules loaded via PerlModule
 */
void perl_reload_inc(server_rec *s, pool *sp)
{
    dPSRV(s);
    HV *hash = GvHV(incgv);
    HE *entry;
    I32 old_warn = dowarn;
    pool *p = ap_make_sub_pool(sp);
    table *reload = ap_make_table(p, HvKEYS(hash));
    char **entries;
    int i = 0;

    dowarn = FALSE;
    entries = (char **)cls->PerlModule->elts;
    for (i=0; i < cls->PerlModule->nelts; i++) {
	SV *file = perl_module2file(entries[i]);
	ap_table_set(reload, SvPVX(file), "1");
	SvREFCNT_dec(file);
    }

    hv_iterinit(hash);
    while ((entry = hv_iternext(hash))) {
	ap_table_setn(reload, HeKEY(entry), "1");
    }

    {
	array_header *arr = ap_table_elts(reload);
	table_entry *elts = (table_entry *)arr->elts;
	SV *keysv = newSV(0);
	for (i=0; i < arr->nelts; i++) {
	    sv_setpv(keysv, elts[i].key);
	    if (!(entry = hv_fetch_ent(hash, keysv, FALSE, 0))) {
		MP_TRACE_g(fprintf(stderr, 
				   "%s not found in %%INC\n", elts[i].key));
		continue;
	    }
	    SvREFCNT_dec(HeVAL(entry));
	    HeVAL(entry) = &sv_undef;
	    MP_TRACE_g(fprintf(stderr, "reloading %s\n", HeKEY(entry)));
	    perl_require_pv(HeKEY(entry));
	}
	SvREFCNT_dec(keysv);
    }

    dowarn = old_warn;
    ap_destroy_pool(p);
}

I32 perl_module_is_loaded(char *name)
{
    I32 retval = FALSE;
    SV *key = perl_module2file(name);
    if((key && hv_exists_ent(GvHV(incgv), key, FALSE)))
	retval = TRUE;
    if(key)
	SvREFCNT_dec(key);
    return retval;
}

SV *perl_module2file(char *name)
{
    SV *sv = newSVpv(name,0);
    char *s;
    for (s = SvPVX(sv); *s; s++) {
	if (*s == ':' && s[1] == ':') {
	    *s = '/';
	    Move(s+2, s+1, strlen(s+2)+1, char);
	    --SvCUR(sv);
	}
    }
    sv_catpvn(sv, ".pm", 3);
    return sv;
}

int perl_require_module(char *name, server_rec *s)
{
    dTHR;
    SV *sv = sv_newmortal();
    dTHRCTX;

    sv_setpvn(sv, "require ", 8);
    MP_TRACE_d(fprintf(stderr, "loading perl module '%s'...", name)); 
    sv_catpv(sv, name);
    perl_eval_sv(sv, G_DISCARD);
    if(s) {
	if(perl_eval_ok(s) != OK) {
	    MP_TRACE_d(fprintf(stderr, "not ok\n"));
	    return -1;
	}
    }
    else if(SvTRUE(ERRSV)) {
	MP_TRACE_d(fprintf(stderr, "not ok\n"));
	return -1;
    }

    MP_TRACE_d(fprintf(stderr, "ok\n"));
    return 0;
}

void perl_do_file(char *pv)
{
    SV* sv = sv_newmortal();
    sv_setpv(sv, "require '");
    sv_catpv(sv, pv);
    sv_catpv(sv, "'");
    perl_eval_sv(sv, G_DISCARD);
    /*(void)hv_delete(GvHV(incgv), pv, strlen(pv), G_DISCARD);*/
}      

int perl_load_startup_script(server_rec *s, pool *p, char *script, I32 my_warn)
{
    dTHR;
    I32 old_warn = dowarn;

    if(!script) {
	MP_TRACE_d(fprintf(stderr, "no Perl script to load\n"));
	return OK;
    }

    MP_TRACE_d(fprintf(stderr, "attempting to require `%s'\n", script));
    dowarn = my_warn;
    curstash = defstash;
    perl_do_file(script);
    dowarn = old_warn;
    return perl_eval_ok(s);
} 

void mp_magic_setenv(char *key, char *val, int is_tainted)
{
    int klen = strlen(key);
    SV **ptr = hv_fetch(GvHV(envgv), key, klen, TRUE);
    if (ptr) {
	SvSetMagicSV(*ptr, newSVpv(val,0));
	if (is_tainted) {
	    SvTAINTED_on(*ptr);
	}
    }
}

array_header *perl_cgi_env_init(request_rec *r)
{
    table *envtab = r->subprocess_env; 
    char *tz = NULL; 

    add_common_vars(r); 
    add_cgi_vars(r); 

    if (!table_get(envtab, "TZ")) {
	if ((tz = getenv("TZ")) != NULL) {
	    table_set(envtab, "TZ", tz);
	}
    }
    if (!table_get(envtab, "PATH")) {
	table_set(envtab, "PATH", DEFAULT_PATH);
    }
    table_set(envtab, "GATEWAY_INTERFACE", PERL_GATEWAY_INTERFACE);

    return table_elts(envtab);
}

#define untie_env  sv_unmagic((SV*)GvHV(envgv), 'E')
#define tie_env    sv_magic((SV*)GvHV(envgv), (SV*)envgv, 'E', Nullch, 0)
#define delete_env(ken, klen) \
    (void)hv_delete(GvHV(envgv), key, klen, G_DISCARD)

void perl_clear_env(void)
{
    char *key;
    I32 klen;
    SV *val;
    HV *hv = (HV*)GvHV(envgv);

    untie_env;
    if(!hv_exists(hv, "MOD_PERL", 8)) {
        hv_store(hv, "MOD_PERL", 8,
                 newSVpv(MOD_PERL_STRING_VERSION,0), FALSE);
        hv_store(hv, "GATEWAY_INTERFACE", 17,
                 newSVpv("CGI-Perl/1.1",0), FALSE);
    }
    (void)hv_iterinit(hv);
    while ((val = hv_iternextsv(hv, (char **) &key, &klen))) {
        if((*key == 'G') && strEQ(key, "GATEWAY_INTERFACE"))
            continue;
        else if((*key == 'M') && strnEQ(key, "MOD_PERL", 8))
            continue;
        else if((*key == 'T') && strnEQ(key, "TZ", 2))
            continue;
        else if((*key == 'P') && strEQ(key, "PATH"))
            continue;
	else if((*key == 'H') && strnEQ(key, "HTTP_", 5)) {
	    tie_env;
	    delete_env(key, klen);
	    untie_env;
	    continue;
	}
	delete_env(key, klen);
    }
    tie_env;
}

void mod_perl_init_ids(void)  /* $$, $>, $), etc */
{
    if(set_ids++) return;
    sv_setiv(GvSV(gv_fetchpv("$", TRUE, SVt_PV)), (I32)getpid());
#ifndef WIN32
    uid  = (int)getuid(); 
    euid = (int)geteuid(); 
    gid  = (int)getgid(); 
    egid = (int)getegid(); 
    MP_TRACE_g(fprintf(stderr, 
		     "perl_init_ids: uid=%d, euid=%d, gid=%d, egid=%d\n",
		     uid, euid, gid, egid));
#endif
}

int perl_eval_ok(server_rec *s)
{
    int status;
    SV *sv;
    dTHR;
    dTHRCTX;

    sv = ERRSV;
    if (SvTRUE(sv)) {
        if (SvMAGICAL(sv) && (SvCUR(sv) > 4) &&
            strnEQ(SvPVX(sv), " at ", 4))
        {
            /* Apache::exit was called */
            return DECLINED;
        }
        if (perl_sv_is_http_code(ERRSV, &status)) {
            return status;
        }
        MP_TRACE_g(fprintf(stderr, "perl_eval error: %s\n", SvPV(sv,na)));
        mod_perl_error(s, SvPV(sv, na));
        return SERVER_ERROR;
    }
    return OK;
}

int perl_sv_is_http_code(SV *errsv, int *status) 
{
    int i=0, http_code=0, retval = FALSE;
    char *errpv;
    char cpcode[4];
    dTHR;

    if(!SvTRUE(errsv) || !ERRSV_CAN_BE_HTTP)
	return FALSE;

    errpv = SvPVX(errsv);

    for(i=0;i<=2;i++) {
	if(i >= SvCUR(errsv)) 
	    break;
	if(isDIGIT(SvPVX(errsv)[i])) 
	    http_code++;
	else
	    http_code--;
    }

    /* we've looked at the first 3 characters of $@
     * if they're not all digits, $@ is not an HTTP code
     */
    if(http_code != 3) {
	MP_TRACE_g(fprintf(stderr, 
			 "mod_perl: $@ doesn't look like an HTTP code `%s'\n", 
			 errpv));
	return FALSE;
    }

    /* nothin but 3 digits */
    if(SvCUR(errsv) == http_code)
	return TRUE;

    ap_cpystrn((char *)cpcode, errpv, 4);

    MP_TRACE_g(fprintf(stderr, 
		     "mod_perl: possible $@ HTTP code `%s' (cp=`%s')\n", 
		     errpv,cpcode));

    if((SvCUR(errsv) == 4) && (*(SvEND(errsv) - 1) == '\n')) {
	/* nothin but 3 digit code and \n */
	retval = TRUE;
    }
    else {
	char *tmp = errpv;
	tmp += 3;
#ifndef PERL_MARK_WHERE
	if(strNE(SvPVX(GvSV(CopFILEGV(curcop))), "-e")) {
	    SV *fake = newSV(0);
	    sv_setpv(fake, ""); /* avoid -w warning */
	    sv_catpvf(fake, " at %_ line ", GvSV(CopFILEGV(curcop)));

	    if(strnEQ(SvPVX(fake), tmp, SvCUR(fake))) 
		/* $@ is nothing but 3 digit code and the mess die tacks on */
		retval = TRUE;

	    SvREFCNT_dec(fake);
	}
#endif
	if(!retval && strnEQ(tmp, " at ", 4) && instr(errpv, " line "))
	    /* well, close enough */
	    retval = TRUE;
    }

    if(retval == TRUE) {
    	*status = atoi(cpcode);
	MP_TRACE_g(fprintf(stderr, 
			 "mod_perl: $@ is an HTTP code `%d'\n", *status));
    }

    return retval;
}

#ifndef PERLLIB_SEP
#define PERLLIB_SEP ':'
#endif

void perl_incpush(char *p)
{
    if(!p) return;

    while(p && *p) {
	SV *libdir = newSV(0);
	char *s;

	while(*p == PERLLIB_SEP) p++;

	if((s = strchr(p, PERLLIB_SEP)) != Nullch) {
	    sv_setpvn(libdir, p, (STRLEN)(s - p));
	    p = s + 1;
	}
	else {
	    sv_setpv(libdir, p);
	    p = Nullch;
	}
	av_push(GvAV(incgv), libdir);
    }
}

#ifdef PERL_MARK_WHERE
/* XXX find the right place for this! */
static SV *perl_sv_name(SV *svp)
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

void mod_perl_mark_where(char *where, SV *sub)
{
    dTHR;
    SV *name = Nullsv;
    if(CopLINE(curcop)) {
#if 0
	fprintf(stderr, "already know where: %s line %d\n",
		SvPV(GvSV(CopFILEGV(curcop)),na), CopFILEGV(curcop));
#endif
	return;
    }

    SAVECOPFILE(curcop);
    SAVECOPLINE(curcop);

    if(sub) 
	name = perl_sv_name(sub);

    sv_setpv(GvSV(CopFILEGV(curcop)), "");
    sv_catpvf(GvSV(CopFILEGV(curcop)), "%s subroutine `%_'", where, name);
    CopLINE_set(curcop, 1);

    if(name)
	SvREFCNT_dec(name);
}
#endif

#if MODULE_MAGIC_NUMBER < 19971226
char *ap_cpystrn(char *dst, const char *src, size_t dst_size)
{

    char *d, *end;

    if (!dst_size)
        return (dst);

    d = dst;
    end = dst + dst_size - 1;

    for (; d < end; ++d, ++src) {
	if (!(*d = *src)) {
	    return (d);
	}
    }

    *d = '\0';	/* always null terminate */

    return (d);
}

#endif

#if defined(WIN32) && defined(PERL_IS_5_6)
void
Perl_do_join(pTHX_ register SV *sv, SV *del, register SV **mark, register SV **sp)
{
    SV **oldmark = mark;
    register I32 items = sp - mark;
    register STRLEN len;
    STRLEN delimlen;
    register char *delim = SvPV(del, delimlen);
    STRLEN tmplen;

    mark++;
    len = (items > 0 ? (delimlen * (items - 1) ) : 0);
    (void)SvUPGRADE(sv, SVt_PV);
    if (SvLEN(sv) < len + items) {	/* current length is way too short */
	while (items-- > 0) {
	    if (*mark && !SvGMAGICAL(*mark) && SvOK(*mark)) {
		SvPV(*mark, tmplen);
		len += tmplen;
	    }
	    mark++;
	}
	SvGROW(sv, len + 1);		/* so try to pre-extend */

	mark = oldmark;
	items = sp - mark;
	++mark;
    }

    if (items-- > 0) {
	char *s;

	if (*mark) {
	    s = SvPV(*mark, tmplen);
	    sv_setpvn(sv, s, tmplen);
	}
	else
	    sv_setpv(sv, "");
	mark++;
    }
    else
	sv_setpv(sv,"");
    len = delimlen;
    if (len) {
	for (; items > 0; items--,mark++) {
	    sv_catpvn(sv,delim,len);
	    sv_catsv(sv,*mark);
	}
    }
    else {
	for (; items > 0; items--,mark++)
	    sv_catsv(sv,*mark);
    }
    SvSETMAGIC(sv);
}
#endif
