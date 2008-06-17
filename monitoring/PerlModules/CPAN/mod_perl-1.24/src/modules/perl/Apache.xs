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
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 * Portions of this software are based upon public domain software
 * originally written at the National Center for Supercomputing Applications,
 * University of Illinois, Urbana-Champaign.
 */

#define CORE_PRIVATE
#include "mod_perl.h"
#include "mod_perl_xs.h"


#ifdef USE_SFIO
#undef send_fd_length    
static long send_fd_length(FILE *f, request_rec *r, long length)
{
    croak("Apache::send_fd() not supported with sfio");
    return 0;
}
#endif

#if defined(PERL_STACKED_HANDLERS) && defined(PERL_GET_SET_HANDLERS)

#define PER_DIR_CONFIG 1
#define PER_SRV_CONFIG 2

typedef struct {
    int type;
    char *name;
    void *offset;
    void (*set_func) (void *, void *, SV *);
} perl_handler_table;

typedef struct {
    I32 fill;
    AV *av;
    AV **ptr;
} perl_save_av;

static void set_handler_dir (perl_handler_table *tab, request_rec *r, SV *sv);
static void set_handler_srv (perl_handler_table *tab, request_rec *r, SV *sv);

#define HandlerDirEntry(name,member) \
PER_DIR_CONFIG, name, (void*)XtOffsetOf(perl_dir_config,member), \
(void(*)(void *, void *, SV *)) set_handler_dir

#define HandlerSrvEntry(name,member) \
PER_SRV_CONFIG, name, (void*)XtOffsetOf(perl_server_config,member), \
(void(*)(void *, void *, SV *)) set_handler_srv

static perl_handler_table handler_table[] = {
    {HandlerSrvEntry("PerlPostReadRequestHandler", PerlPostReadRequestHandler)},
    {HandlerSrvEntry("PerlTransHandler", PerlTransHandler)},
    {HandlerDirEntry("PerlHeaderParserHandler", PerlHeaderParserHandler)},
    {HandlerDirEntry("PerlAccessHandler", PerlAccessHandler)},
    {HandlerDirEntry("PerlAuthenHandler", PerlAuthenHandler)},
    {HandlerDirEntry("PerlAuthzHandler", PerlAuthzHandler)},
    {HandlerDirEntry("PerlTypeHandler", PerlTypeHandler)},
    {HandlerDirEntry("PerlFixupHandler", PerlFixupHandler)},
    {HandlerDirEntry("PerlHandler", PerlHandler)},
    {HandlerDirEntry("PerlLogHandler", PerlLogHandler)},
    { FALSE, NULL }
};

static void perl_restore_av(void *data)
{
    perl_save_av *save_av = (perl_save_av *)data;

    if(save_av->fill != DONE) {
	AvFILLp(*save_av->ptr) = save_av->fill;
    }
    else if(save_av->av != Nullav) {
	*save_av->ptr = save_av->av;
    }
}

static void perl_handler_merge_avs(char *hook, AV **dest)
{
    int i = 0;
    HV *hv = perl_get_hv("Apache::PerlStackedHandlers", FALSE);
    SV **svp = hv_fetch(hv, hook, strlen(hook), FALSE);
    AV *base;
    
    if(!(svp && SvROK(*svp)))
	return;

    base = (AV*)SvRV(*svp);
    for(i=0; i<=AvFILL(base); i++) { 
	SV *sv = *av_fetch(base, i, FALSE);
	av_push(*dest, sv);
    }
}

static void set_handler_base(void *ptr, perl_handler_table *tab, pool *p, SV *sv) 
{
    AV **av = (AV **)((char *)ptr + (int)(long)tab->offset);

    perl_save_av *save_av = 
	(perl_save_av *)palloc(p, sizeof(perl_save_av));

    save_av->fill = DONE;
    save_av->av = Nullav;
    
    if((sv == &sv_undef) || (SvIOK(sv) && SvIV(sv) == DONE)) {
	if(AvTRUE(*av)) {
	    save_av->fill = AvFILL(*av);
	    AvFILLp(*av) = -1;
	}
    }
    else if(SvROK(sv) && SvTYPE(SvRV(sv)) == SVt_PVAV) {
	if(AvTRUE(*av))
	    save_av->av = av_copy_array(*av);
	*av = (AV*)SvRV(sv);
	++SvREFCNT(*av);
    }
    else {
	croak("Can't set_handler with that value");
    }
    save_av->ptr = av;
    register_cleanup(p, save_av, perl_restore_av, mod_perl_noop);
}

static void set_handler_dir(perl_handler_table *tab, request_rec *r, SV *sv)
{
    dPPDIR; 
    set_handler_base((void*)cld, tab, r->pool, sv);
}

static void set_handler_srv(perl_handler_table *tab, request_rec *r, SV *sv)
{
    dPSRV(r->server); 
    set_handler_base((void*)cls, tab, r->pool, sv);
}

static perl_handler_table *perl_handler_lookup(char *name)
{
    int i;
    for (i=0; handler_table[i].name; i++) {
	perl_handler_table *tab = &handler_table[i];
        if(strEQ(name, tab->name))
	    return tab;
    }
    return NULL;
}


static SV *get_handlers(request_rec *r, char *hook)
{
    AV *avcopy;
    AV **av;
    dPPDIR;
    dPSRV(r->server);
    void *ptr;
    perl_handler_table *tab = perl_handler_lookup(hook);

    if(!tab) return Nullsv;

    if(tab->type == PER_DIR_CONFIG)
	ptr = (void*)cld;
    else
	ptr = (void*)cls;

    av = (AV **)((char *)ptr + (int)(long)tab->offset);

    if(*av) 
	avcopy = av_copy_array(*av);
    else
	avcopy = newAV();

    perl_handler_merge_avs(hook, &avcopy);

    return newRV_noinc((SV*)avcopy);
}

static void set_handlers(request_rec *r, SV *hook, SV *sv)
{
    dTHR;
    perl_handler_table *tab = perl_handler_lookup(SvPV(hook,na));
    if(tab && tab->set_func) 
        (*tab->set_func)(tab, r, sv);

    (void)hv_delete_ent(perl_get_hv("Apache::PerlStackedHandlers", FALSE),
			hook, G_DISCARD, FALSE);
}
#endif

#if MODULE_MAGIC_NUMBER < 19970909
static void
child_terminate(request_rec *r)
{
#ifndef WIN32
    log_transaction(r);
#endif
    exit(0);
}
#endif

static char *custom_response(request_rec *r, int status, char *string)
{
    core_dir_config *conf = (core_dir_config *)
	get_module_config(r->per_dir_config, &core_module);
    int idx;
    char *retval = NULL;

    if(conf->response_code_strings == NULL) {
        conf->response_code_strings = (char **)
	  pcalloc(r->pool,
		  sizeof(*conf->response_code_strings) * 
		  RESPONSE_CODES);
    }

    idx = index_of_response(status);
    retval = conf->response_code_strings[idx];
    if (string) {
	conf->response_code_strings[idx] = 
	    ((is_url(string) || (*string == '/')) && (*string != '"')) ? 
		pstrdup(r->pool, string) : pstrcat(r->pool, "\"", string, NULL);
    }

    return retval;
}

static void Apache_terminate_if_done(request_rec *r, int sts)
{
#ifndef WIN32
    if(Apache_exit_is_done(sts)) child_terminate(r);
#endif
}

#if MODULE_MAGIC_NUMBER < 19980317
int basic_http_header(request_rec *r);
#endif

#if MODULE_MAGIC_NUMBER < 19980201
unsigned get_server_port(const request_rec *r)
{
    unsigned port = r->server->port ? r->server->port : 80;

    return r->hostname ? ntohs(r->connection->local_addr.sin_port)
	: port;
}
#define get_server_name(r) \
    (r->hostname ? r->hostname : r->server->server_hostname) 
#endif

#if MODULE_MAGIC_AT_LEAST(19981108, 1)
#define mod_perl_define(sv,name) ap_exists_config_define(name)
#elif(MODULE_MAGIC_NUMBER >= MMN_131) && !defined(WIN32)
static int mod_perl_define(SV *sv, char *name)
{
    char **defines;
    int i;

    defines = (char **)ap_server_config_defines->elts;
    for (i = 0; i < ap_server_config_defines->nelts; i++) {
        if (strcmp(defines[i], name) == 0) {
            return 1;
        }
    }
    return 0;
}
#else
#define mod_perl_define(sv,name) 0
#endif

static int sv_str_header(void *arg, const char *k, const char *v)
{
    SV *sv = (SV*)arg;
    sv_catpvf(sv, "%s: %s\n", k, v);
    return 1;
}

#if MODULE_MAGIC_NUMBER >= 19980806
/*
 * ap_scan_script_header_err_core(r, buffer, getsfunc_SV, sv)
 */
#if 0
static int getsfunc_SV(char *buf, int bufsiz, void *param)
{
    SV *sv = (SV*)param;
    STRLEN len;
    char *tmp = SvPV(sv,len);
    int i;

    if(!SvTRUE(sv)) 
	return 0;

    for(i=0; i<=len; i++) {
	if(tmp[i] == LF) break;
    }

    Move(tmp, buf, i, char);
    buf[i] = '\0';

    if(len < i) {
	sv_setpv(sv, "");
    }
    else {
	tmp += i+1;
	sv_setpv(sv, tmp);
    }
    return 1;
}
#endif /*0*/
#endif /*MODULE_MAGIC_NUMBER*/

static void rwrite_neg_trace(request_rec *r)
{
#if HAS_MMN_130
    ap_log_error(APLOG_MARK, APLOG_DEBUG, r->server,
#else
    fprintf(stderr,
#endif
		 "mod_perl: rwrite returned -1 (fd=%d, B_EOUT=%d)\n",
		 ap_bfileno(r->connection->client, B_WR), 
		 r->connection->client->flags & B_EOUT);
}

MODULE = Apache  PACKAGE = Apache   PREFIX = mod_perl_

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

const char *
current_callback(r)
    Apache     r

    CODE:
    RETVAL = PERL_GET_CUR_HOOK;

    OUTPUT:
    RETVAL

int
mod_perl_sent_header(r, val=0)
    Apache     r
    int val
    
int
mod_perl_seqno(self, inc=0)
    SV *self
    int inc

int
perl_hook(name)
    char *name

#if defined(PERL_GET_SET_HANDLERS)
SV *
get_handlers(r, hook)
    Apache     r
    char *hook

    CODE:
#ifdef get_handlers
    get_handlers(r,hook);
#else
    RETVAL = get_handlers(r,hook);
#endif
   
    OUTPUT:
    RETVAL

void    
set_handlers(r, hook, sv)
    Apache     r
    SV *hook
    SV *sv

#endif

int
mod_perl_push_handlers(self, hook, cv)
    SV *self
    char *hook
    SV *cv;

    CODE:
    RETVAL = mod_perl_push_handlers(self, hook, cv, Nullav);

    OUTPUT:
    RETVAL

int
mod_perl_can_stack_handlers(self)
    SV *self

void
mod_perl_register_cleanup(r, sv)
    Apache     r
    SV *sv

    ALIAS:
    Apache::post_connection = 1

    PREINIT:
    ix = ix; /* avoid -Wall warning */
    
#define APACHE_REGISTRY_CURSTASH perl_get_sv("Apache::Registry::curstash", TRUE)

void
mod_perl_clear_rgy_endav(r, sv=APACHE_REGISTRY_CURSTASH)
    Apache     r
    SV *sv

void
mod_perl_stash_rgy_endav(r, sv=APACHE_REGISTRY_CURSTASH)
    Apache     r
    SV *sv

    CODE:
    perl_stash_rgy_endav(r->uri, sv);

I32
mod_perl_define(sv, name)
    SV *sv
    char *name

    CLEANUP:
    sv = sv; /*-Wall*/

I32
module(sv, name)
    SV *sv
    SV *name

    CODE:
    if((*(SvEND(name) - 2) == '.') && (*(SvEND(name) - 1) == 'c'))
        RETVAL = find_linked_module(SvPVX(name)) ? 1 : 0;
    else
        RETVAL = (sv && perl_module_is_loaded(SvPVX(name)));

    OUTPUT:
    RETVAL

char *
mod_perl_set_opmask(r, sv)
    Apache     r
    SV *sv

void
untaint(...)

    PREINIT:
    int i;

    CODE:
    if(!tainting) XSRETURN_EMPTY;
    for(i=1; i<items; i++) 
        mod_perl_untaint(ST(i));

void
taint(...)

    PREINIT:
    int i;

    CODE:
    if(!tainting) XSRETURN_EMPTY;
    for(i=1; i<items; i++)
        sv_magic(ST(i), Nullsv, 't', Nullch, 0);

#ifndef WIN32

void
child_terminate(r)
    Apache     r

#endif

#CORE::exit only causes trouble when we're embedded
void
exit(...)

    PREINIT:
    int sts = 0;
    request_rec *r = NULL;

    CODE:
    /* $r->exit */
    r = sv2request_rec(ST(0), "Apache", cv);

    if(items > 1) {
        sts = (int)SvIV(ST(1));
    }
    else { /* Apache::exit() */
	if(SvTRUE(ST(0)) && SvIOK(ST(0)))
	    sts = (int)SvIV(ST(0));
    }

    MP_CHECK_REQ(r, "Apache::exit");

    if(!r->connection->aborted)
        rflush(r);
    Apache_terminate_if_done(r,sts);
    perl_call_halt(sts);

#in case you need Apache::fork
# INCLUDE: fork.xs

void 
CLOSE(...)

    ALIAS:
    BINMODE = 1
    
    CODE:
    items = items;
    /*NOOP*/

Apache
TIEHANDLE(classname, r=NULL)
    SV *classname
    Apache r

    CODE:
    RETVAL = r ? r : perl_request_rec(NULL);

    OUTPUT:
    RETVAL

int
OPEN(self, arg1, arg2=Nullsv)
    SV *self
    SV *arg1
    SV *arg2

    PREINIT:
    char *name;
    STRLEN len;
    GV *gv = gv_fetchpv("STDOUT", TRUE, SVt_PVIO);
    SV *arg;

    CODE:
    sv_unmagic((SV*)gv, 'q'); /* untie *STDOUT */
    if (arg2) {
        arg = newSVsv(arg1);
        sv_catsv(arg, arg2);
    }
    else {
        arg = arg1;
    }

    name = SvPV(arg, len);
    RETVAL = do_open(gv, name, len, FALSE, O_RDONLY, 0, Nullfp);

    OUTPUT:
    RETVAL

int
FILENO(r)
    Apache r

    CODE:
    RETVAL = fileno(stdout);

    OUTPUT:
    RETVAL

SV *
as_string(r)
    Apache r

    CODE:
    RETVAL = newSVpv(r->the_request,0);
    sv_catpvn(RETVAL, "\n", 1);

    table_do(sv_str_header, (void*)RETVAL, r->headers_in, NULL);
    sv_catpvf(RETVAL, "\n%s %s\n", r->protocol, r->status_line);

    table_do(sv_str_header, (void*)RETVAL, r->headers_out, NULL);
    table_do(sv_str_header, (void*)RETVAL, r->err_headers_out, NULL);
    sv_catpvn(RETVAL, "\n", 1);

    OUTPUT:
    RETVAL

#httpd.h
     
void
chdir_file(r, file=r->filename)
    Apache r
    const char *file

    CODE:
    chdir_file(file);

SV *
mod_perl_gensym(pack="Apache::Symbol")
    char *pack

SV *
mod_perl_slurp_filename(r)
    Apache r

char *
unescape_url(string)
char *string

    CODE:
    unescape_url(string);
    RETVAL = string;

    OUTPUT:
    RETVAL

#
# Doing our own unscape_url for the query info part of an url
#

char *
unescape_url_info(url)
    char *     url

    CODE:
    register char * trans = url ;
    char digit ;

    RETVAL = url;

    while (*url != '\0') {
        if (*url == '+')
            *trans = ' ';
	else if (*url != '%')
	    *trans = *url;
        else if (!isxdigit(url[1]) || !isxdigit(url[2]))
            *trans = '%';
        else {
            url++ ;
            digit = ((*url >= 'A') ? ((*url & 0xdf) - 'A')+10 : (*url - '0'));
            url++ ;
            *trans = (digit << 4) +
		(*url >= 'A' ? ((*url & 0xdf) - 'A')+10 : (*url - '0'));
        }
        url++, trans++ ;
    }
    *trans = '\0';

    OUTPUT:
    RETVAL

#functions from http_main.c

void
hard_timeout(r, string)
    Apache     r
    char       *string

    CODE:
#ifndef USE_THREADS
    hard_timeout(string, r);
#endif

void
soft_timeout(r, string)
    Apache     r
    char       *string

    CODE:
    soft_timeout(string, r);

void
kill_timeout(r)
    Apache     r

    CODE:
#ifndef USE_THREADS
    kill_timeout(r);
#endif

void
reset_timeout(r)
    Apache     r

#functions from http_config.c

int
translate_name(r)
    Apache     r

    CODE:
#ifdef WIN32
    croak("Apache->translate_name not supported under Win32");
    RETVAL = DECLINED;
#else
    RETVAL = translate_name(r);
#endif

    OUTPUT:
    RETVAL

#functions from http_core.c

char *
custom_response(r, status, string=NULL)
    Apache     r
    int status
    char *string
    
int
satisfies(r)
    Apache     r

int
some_auth_required(r)
    Apache     r

void
requires(r)
    Apache     r

    PREINIT:
    AV *av;
    HV *hv;
    register int x;
    int m;
    char *t;
    MP_CONST_ARRAY_HEADER *reqs_arr;
    require_line *reqs;

    CODE:
    m = r->method_number;
    reqs_arr = requires (r);

    if (!reqs_arr)
	ST(0) = &sv_undef;
    else {
	reqs = (require_line *)reqs_arr->elts;
	iniAV(av);
        for(x=0; x < reqs_arr->nelts; x++) {
	    /* XXX should we do this or let PerlAuthzHandler? */
	    if (! (reqs[x].method_mask & (1 << m))) continue;
	    t = reqs[x].requirement;
	    iniHV(hv);
	    hv_store(hv, "method_mask", 11, 
		     newSViv((IV)reqs[x].method_mask), 0);
	    hv_store(hv, "requirement", 11, 
		     newSVpv(reqs[x].requirement,0), 0);
	    av_push(av, newRV((SV*)hv));
	}
	ST(0) = newRV_noinc((SV*)av); 
    }

int 
allow_options(r)
    Apache	r

unsigned
get_server_port(r)
    Apache	r

const char *
get_server_name(r)
    Apache	r

char *
get_remote_host(r, type=REMOTE_NAME)
    Apache	r
    int type

    CODE:
    RETVAL = (char *)get_remote_host(r->connection, 
				     r->per_dir_config, type);

    OUTPUT:
    RETVAL

const char *
get_remote_logname(r)
    Apache	r

char *
mod_perl_auth_name(r, val=NULL)
    Apache    r
    char *val

const char *
auth_type(r)
    Apache    r

const char *
document_root(r, ...)
    Apache    r

    PREINIT:
    core_server_config *conf;

    CODE:
    conf = (core_server_config *)
      get_module_config(r->server->module_config, &core_module);

    RETVAL = conf->ap_document_root;

    if (items > 1) {
        SV *doc_root = perl_get_sv("Apache::Server::DocumentRoot", TRUE);
        sv_setsv(doc_root, ST(1));
        conf->ap_document_root = SvPVX(doc_root);
    }

    OUTPUT:
    RETVAL

char *
server_root_relative(rsv, name="")
    SV   *rsv
    char *name

    PREINIT:
    pool *p;
    request_rec *r;

    CODE:
    if (SvROK(rsv) && (r = sv2request_rec(rsv, "Apache", cv))) {
	p = r->pool;
    }
    else {
	if(!(p = perl_get_startup_pool()))
	   croak("Apache::server_root_relative: no startup pool available");
    }

    RETVAL = (char *)server_root_relative(p, name);

    OUTPUT:
    RETVAL

#functions from http_protocol.c

void
note_basic_auth_failure(r)
    Apache r

void
get_basic_auth_pw(r)
    Apache r

    PREINIT:
    MP_CONST_CHAR *sent_pw = NULL;
    int ret;

    PPCODE:
    ret = get_basic_auth_pw(r, &sent_pw);
    XPUSHs(sv_2mortal((SV*)newSViv(ret)));
    if(ret == OK)
	XPUSHs(sv_2mortal((SV*)newSVpv((char *)sent_pw, 0)));
    else
	XPUSHs(&sv_undef);

void
basic_http_header(r)
    Apache	r
    
    CODE:
#ifdef WIN32
    croak("Apache->basic_http_header() not supported under Win32!");
#else
    basic_http_header(r);
#endif

void
send_http_header(r, type=NULL)
    Apache	r
    char *type

    CODE:
    if(type)
        r->content_type = pstrdup(r->pool, type);
    send_http_header(r);
    mod_perl_sent_header(r, 1);
    r->status = 200; /* XXX, why??? */

#ifndef PERL_OBJECT

int
send_fd(r, f, length=-1)
    Apache	r
    FILE *f
    long length

    CODE:
    RETVAL = send_fd_length(f, r, length);

    OUTPUT:
    RETVAL

#endif

int
rflush(r)
    Apache     r

void
read_client_block(r, buffer, bufsiz)
    Apache	r
    char    *buffer
    int      bufsiz

    PREINIT:
    long nrd = 0;
    int rc;

    PPCODE:
    buffer = (char*)safemalloc(bufsiz);
    if ((rc = setup_client_block(r, REQUEST_CHUNKED_ERROR)) != OK) {
	aplog_error(APLOG_MARK, APLOG_ERR | APLOG_NOERRNO, r->server, 
		    "mod_perl: setup_client_block failed: %d", rc);
	XSRETURN_UNDEF;
    }

    if(should_client_block(r)) {
	nrd = get_client_block(r, buffer, bufsiz);
	r->read_length = 0;
    } 

    if (nrd > 0) {
	XPUSHs(sv_2mortal(newSViv((long)nrd)));
	sv_setpvn((SV*)ST(1), buffer, nrd);
#ifdef PERL_STASH_POST_DATA
        table_set(r->subprocess_env, "POST_DATA", buffer);
#endif
        safefree(buffer);
	SvTAINTED_on((SV*)ST(1));
    } 
    else {
	ST(1) = &sv_undef;
    }

int
setup_client_block(r, policy=REQUEST_CHUNKED_ERROR)
    Apache	r
    int policy

int
should_client_block(r)
    Apache	r

void
get_client_block(r, buffer, bufsiz)
    Apache	r
    char    *buffer
    int      bufsiz

    PREINIT:
    long nrd = 0;

    PPCODE:
    buffer = (char*)palloc(r->pool, bufsiz);
    nrd = get_client_block(r, buffer, bufsiz);
    if ( nrd > 0 ) {
	XPUSHs(sv_2mortal(newSViv((long)nrd)));
	sv_setpvn((SV*)ST(1), buffer, nrd);
	SvTAINTED_on((SV*)ST(1));
    } 
    else {
	ST(1) = &sv_undef;
    }

int
print(r, ...)
    Apache	r

    ALIAS:
    Apache::PRINT = 1

    CODE:
    ix = ix; /* avoid -Wall warning */

    if(!mod_perl_sent_header(r, 0)) {
	SV *sv = sv_newmortal();
	SV *rp = ST(0);
	SV *sendh = perl_get_sv("Apache::__SendHeader", TRUE);

	if(items > 2)
	    do_join(sv, &sv_no, MARK+1, SP); /* $sv = join '', @_[1..$#_] */
        else
	    sv_setsv(sv, ST(1));

	PUSHMARK(sp);
	XPUSHs(rp);
	XPUSHs(sv);
	PUTBACK;
	sv_setiv(sendh, 1);
	perl_call_pv("Apache::send_cgi_header", G_SCALAR);
	sv_setiv(sendh, 0);
    }
    else {
	CV *cv = GvCV(gv_fetchpv("Apache::write_client", FALSE, SVt_PVCV));
	hard_timeout("mod_perl: Apache->print", r);
	PUSHMARK(mark);
#ifdef PERL_OBJECT
	(void)(*CvXSUB(cv))(cv, pPerl); /* &Apache::write_client; */
#else
	(void)(*CvXSUB(cv))(aTHXo_ cv); /* &Apache::write_client; */
#endif

	if(IoFLAGS(GvIOp(defoutgv)) & IOf_FLUSH) /* if $| != 0; */
#if MODULE_MAGIC_NUMBER >= 19970103
	    rflush(r);
#else
	    bflush(r->connection->client);
#endif
	kill_timeout(r);
    }

    RETVAL = !r->connection->aborted;

    OUTPUT:
    RETVAL

int
write_client(r, ...)
    Apache	r

    PREINIT:
    int i;
    char * buffer;
    STRLEN len;

    CODE:
    RETVAL = 0;

    if (r->connection->aborted)
        XSRETURN_IV(0);

    for(i = 1; i <= items - 1; i++) {
	int sent = 0;
        SV *sv = SvROK(ST(i)) && (SvTYPE(SvRV(ST(i))) == SVt_PV) ?
                 (SV*)SvRV(ST(i)) : ST(i);
	buffer = SvPV(sv, len);
#ifdef APACHE_SSL
        while(len > 0) {
	    sent = rwrite(buffer,
	        	  len < HUGE_STRING_LEN ? len : HUGE_STRING_LEN,
	        	  r);
	    if(sent < 0) {
		rwrite_neg_trace(r);
		/* break out of outer loop too */
		i = items;
		break;
	    }
	    buffer += sent;
	    len -= sent;
	    RETVAL += sent;
        }
#else
        if((sent = rwrite(buffer, len, r)) < 0) {
	    rwrite_neg_trace(r);
	    break;
        }
        RETVAL += sent;
#endif
    }

    OUTPUT:
    RETVAL

#functions from http_request.c
void
internal_redirect_handler(r, location)
    Apache	r
    char *      location

    ALIAS: 
    Apache::internal_redirect = 1

    CODE:
    switch((ix = XSANY.any_i32)) {
	case 0:
	internal_redirect_handler(location, r);
	break;
	case 1:
	internal_redirect(location, r);
	break;
    }

#functions from http_log.c

void
mod_perl_log_reason(r, reason, filename=NULL)
    Apache	r
    char *	reason
    char *	filename

    CODE:
    if(filename == NULL)
        filename = r->uri; 
    mod_perl_log_reason(reason, filename, r);

void
log_error(...)

    ALIAS:
    Apache::warn = 1
    Apache::Server::log_error = 2
    Apache::Server::warn = 3

    PREINIT:
    server_rec *s = NULL;
    request_rec *r = NULL;
    int i=0;
    char *errstr = NULL;
    SV *sv = Nullsv;

    CODE:
    if((items > 1) && (r = sv2request_rec(ST(0), "Apache", cv))) {
	s = r->server;
	i=1;
    }
    else if((items > 1) && sv_derived_from(ST(0), "Apache::Server")) {
	IV tmp = SvIV((SV*)SvRV(ST(0)));
	s = (Apache__Server )tmp;
	i=1;	

	/* if below is true, delay log_error */
	if(PERL_RUNNING() < PERL_DONE_STARTUP) {
	    MP_TRACE_g(fprintf(stderr, "error_log not open yet\n"));
	    XSRETURN_UNDEF;
	}
    }
    else { 
	if(r) 
	    s = r->server;
	else
	    s = perl_get_startup_server();
    }

    if(!s) croak("Apache::warn: no server_rec!");

    if(items > 1+i) {
	sv = newSV(0);
        do_join(sv, &sv_no, MARK+i, SP); /* $sv = join '', @_[1..$#_] */
        errstr = SvPV(sv,na);
    }
    else
        errstr = SvPV(ST(i),na);

    switch((ix = XSANY.any_i32)) {
	case 0:
	case 2:
	mod_perl_error(s, errstr);
	break;

	case 1:
	case 3:
	mod_perl_warn(s, errstr);
	break;

        default:
	mod_perl_error(s, errstr);
	break;
    }

    if(sv) SvREFCNT_dec(sv);

#methods for creating a CGI environment

SV *
subprocess_env(r, key=NULL, ...)
    Apache    r
    char *key

    ALIAS:
    Apache::cgi_env = 1
    Apache::cgi_var = 2

    PREINIT:
    I32 gimme = GIMME_V;
 
    CODE:
    if(((ix = XSANY.any_i32) == 1) && (gimme == G_ARRAY)) {
	/* backwards compat */
	int i;
	array_header *arr  = perl_cgi_env_init(r);
	table_entry *elts = (table_entry *)arr->elts;
	SP -= items;
	for (i = 0; i < arr->nelts; ++i) {
	    if (!elts[i].key) continue;
	    PUSHelt(elts[i].key, elts[i].val, 0);
	}
	PUTBACK;
	return;
    }
    if((items == 1) && (gimme == G_VOID)) {
        (void)perl_cgi_env_init(r);
        XSRETURN_UNDEF;
    }
    TABLE_GET_SET(r->subprocess_env, FALSE);

    OUTPUT:
    RETVAL


#see httpd.h
#struct request_rec {

void
request(self, r=NULL)
    SV *self
    Apache r

    PPCODE: 
    self = self;
    if(items > 1) perl_request_rec(r);
    XPUSHs(perl_bless_request_rec(perl_request_rec(NULL)));

#  pool *pool;
#  conn_rec *connection;
#  server_rec *server;

Apache::Connection
connection(r)
    Apache	r

    CODE:	
    RETVAL = r->connection;

    OUTPUT:
    RETVAL

Apache::Server
server(rsv)
    SV *rsv
	
    PREINIT:
    server_rec *s;
    request_rec *r;

    CODE:
    if (SvROK(rsv) && (r = sv2request_rec(rsv, "Apache", cv))) {
	s = r->server;
    }
    else {
	if(!(s = perl_get_startup_server()))
	   croak("Apache->server: no startup server_rec available");
    }

    RETVAL = s;

    OUTPUT:
    RETVAL

#  request_rec *next;		/* If we wind up getting redirected,
#				 * pointer to the request we redirected to.
#				 */
#  request_rec *prev;		/* If this is an internal redirect,
#				 * pointer to where we redirected *from*.
#				 */
  
#  request_rec *main;		/* If this is a sub_request (see request.h) 
#				 * pointer back to the main request.
#				 */

# ...
#  /* Info about the request itself... we begin with stuff that only
#   * protocol.c should ever touch...
#   */
  
#  char *the_request;		/* First line of request, so we can log it */
#  int assbackwards;		/* HTTP/0.9, "simple" request */
#  int proxyreq;                 /* A proxy request */
#  int header_only;		/* HEAD request, as opposed to GET */

#  char *protocol;		/* Protocol, as given to us, or HTTP/0.9 */
#  char *hostname;		/* Host, as set by full URI or Host: */
#  int hostlen;			/* Length of http://host:port in full URI */

#  char *status_line;		/* Status line, if set by script */
#  int status;			/* In any case */

void
main(r)
    Apache   r

    CODE:
    if(r->main != NULL)
 	ST(0) = perl_bless_request_rec((request_rec *)r->main);
    else
        ST(0) = &sv_undef;

void
prev(r)
    Apache   r

    CODE:
    if(r->prev != NULL)
 	ST(0) = perl_bless_request_rec((request_rec *)r->prev);
    else
        ST(0) = &sv_undef;

void
next(r)
    Apache   r

    CODE:
    if(r->next != NULL)
 	ST(0) = perl_bless_request_rec((request_rec *)r->next);
    else
        ST(0) = &sv_undef;

Apache
last(r)
    Apache   r

    CODE:
    for(RETVAL=r; RETVAL->next; RETVAL=RETVAL->next)
        continue;

    OUTPUT:
    RETVAL

int
is_initial_req(r)
    Apache   r

int 
is_main(r)
    Apache   r

    CODE:
    if(r->main != NULL) RETVAL = 0;
    else RETVAL = 1;
       
    OUTPUT:
    RETVAL

char *
the_request(r, ...)
    Apache   r

    CODE:
    get_set_PVp(r->the_request,r->pool);

    OUTPUT:
    RETVAL

int
proxyreq(r, ...)
    Apache   r

    CODE:
    get_set_IV(r->proxyreq);

    OUTPUT:
    RETVAL

int
header_only(r)
    Apache   r

    CODE:
    RETVAL = r->header_only;

    OUTPUT:
    RETVAL

char *
protocol(r)
    Apache	r

    CODE:
    RETVAL = r->protocol;

    OUTPUT:
    RETVAL

char *
hostname(r)
    Apache	r

    CODE:
    RETVAL = (char *)r->hostname;

    OUTPUT:
    RETVAL

int
status(r, ...)
    Apache	r

    CODE:
    get_set_IV(r->status);

    OUTPUT:
    RETVAL

time_t
request_time(r)
    Apache	r

    CODE:
    RETVAL = r->request_time;

    OUTPUT:
    RETVAL

char *
status_line(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->status_line,r->pool);

    OUTPUT:
    RETVAL
  
#  /* Request method, two ways; also, protocol, etc..  Outside of protocol.c,
#   * look, but don't touch.
#   */
  
#  char *method;			/* GET, HEAD, POST, etc. */
#  int method_number;		/* M_GET, M_POST, etc. */

#  int sent_bodyct;		/* byte count in stream is for body */
#  long bytes_sent;		/* body byte count, for easy access */

char *
method(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->method,r->pool);

    OUTPUT:
    RETVAL

int
method_number(r, ...)
    Apache	r

    CODE:
    get_set_IV(r->method_number);

    OUTPUT:
    RETVAL

long
bytes_sent(r, ...)
    Apache	r

    PREINIT:
    request_rec *last;

    CODE:

    for(last=r; last->next; last=last->next)
        continue;

    if (last->sent_bodyct && !last->bytes_sent) {
	ap_bgetopt(last->connection->client, BO_BYTECT, &last->bytes_sent);
    }

    RETVAL = last->bytes_sent;

    if(items > 1)
        r->bytes_sent = (long)SvIV(ST(1));

    OUTPUT:
    RETVAL

#    /* MIME header environments, in and out.  Also, an array containing
#   * environment variables to be passed to subprocesses, so people can
#   * write modules to add to that environment.
#   *
#   * The difference between headers_out and err_headers_out is that the
#   * latter are printed even on error, and persist across internal redirects
#   * (so the headers printed for ErrorDocument handlers will have them).
#   *
#   * The 'notes' table is for notes from one module to another, with no
#   * other set purpose in mind...
#   */
  
#  table *headers_in;
#  table *headers_out;
#  table *err_headers_out;
#  table *subprocess_env;
#  table *notes;

#  char *content_type;		/* Break these out --- we dispatch on 'em */
#  char *handler;		/* What we *really* dispatch on           */

#  char *content_encoding;
#  char *content_language;
  
#  int no_cache;

SV *
header_in(r, key, ...)
    Apache	r
    char *key

    CODE:
    TABLE_GET_SET(r->headers_in, TRUE);

    OUTPUT:
    RETVAL

void
headers_in(r)
    Apache	r

    PREINIT:
    
    int i;
    array_header *hdrs_arr;
    table_entry  *hdrs;

    PPCODE:
    if(GIMME == G_SCALAR) {
	ST(0) = mod_perl_tie_table(r->headers_in); 
	XSRETURN(1); 	
    }
    hdrs_arr = table_elts (r->headers_in);
    hdrs = (table_entry *)hdrs_arr->elts;

    for (i = 0; i < hdrs_arr->nelts; ++i) {
	if (!hdrs[i].key) continue;
	PUSHelt(hdrs[i].key, hdrs[i].val, 0);
    }

SV *
header_out(r, key, ...)
    Apache	r
    char *key

    CODE:
    TABLE_GET_SET(r->headers_out, TRUE);

    OUTPUT:
    RETVAL

SV *
cgi_header_out(r, key, ...)
    Apache	r
    char *key

    PREINIT:
    char *val;

    CODE:
    if((val = (char *)table_get(r->headers_out, key))) 
	RETVAL = newSVpv(val, 0);
    else
        RETVAL = newSV(0);

    SvTAINTED_on(RETVAL);

    if(items > 2) {
	int status = 302;
	val = SvPV(ST(2),na);
        if(!strncasecmp(key, "Content-type", 12)) {
	    r->content_type = pstrdup (r->pool, val);
	}
        else if(!strncasecmp(key, "Status", 6)) {
            sscanf(val, "%d", &r->status);
            r->status_line = pstrdup(r->pool, val);
        }
        else if(!strncasecmp(key, "Location", 8)) {
	    if (val && val[0] == '/' && r->status == 200) {
		/* not sure if this is quite right yet */
		/* set $Apache::DoInternalRedirect++ to test */
		if(DO_INTERNAL_REDIRECT) {
		    r->method = pstrdup(r->pool, "GET");
		    r->method_number = M_GET;

		    table_unset(r->headers_in, "Content-Length");

		    status = 200;
		    perl_soak_script_output(r);
		    internal_redirect_handler(val, r);
		}
	    }
	    table_set (r->headers_out, key, val);
	    r->status = status;
        }   
        else if(!strncasecmp(key, "Content-Length", 14)) {
	    table_set (r->headers_out, key, val);
        }   
        else if(!strncasecmp(key, "Transfer-Encoding", 17)) {
	    table_set (r->headers_out, key, val);
        }   

#The HTTP specification says that it is legal to merge duplicate
#headers into one.  Some browsers that support Cookies don't like
#merged headers and prefer that each Set-Cookie header is sent
#separately.  Lets humour those browsers.

	else if(!strncasecmp(key, "Set-Cookie", 10)) {
	    table_add(r->err_headers_out, key, val);
	}
        else {
	    table_merge (r->err_headers_out, key, val);
        }
    }

void
headers_out(r)
    Apache	r

    PREINIT:
    int i;
    array_header *hdrs_arr;
    table_entry  *hdrs;

    PPCODE:
    if(GIMME == G_SCALAR) {
	ST(0) = mod_perl_tie_table(r->headers_out); 
	XSRETURN(1); 	
    }
    hdrs_arr = table_elts (r->headers_out);
    hdrs = (table_entry *)hdrs_arr->elts;
    for (i = 0; i < hdrs_arr->nelts; ++i) {
	if (!hdrs[i].key) continue;
	PUSHelt(hdrs[i].key, hdrs[i].val, 0);
    }

SV *
err_header_out(r, key, ...)
    Apache	r
    char *key

    CODE:
    TABLE_GET_SET(r->err_headers_out, TRUE);

    OUTPUT:
    RETVAL

void
err_headers_out(r, ...)
    Apache	r

    PREINIT:
    int i;
    array_header *hdrs_arr;
    table_entry  *hdrs;

    PPCODE:
    if(GIMME == G_SCALAR) {
	ST(0) = mod_perl_tie_table(r->err_headers_out); 
	XSRETURN(1); 	
    }
    hdrs_arr = table_elts (r->err_headers_out);
    hdrs = (table_entry *)hdrs_arr->elts;

    for (i = 0; i < hdrs_arr->nelts; ++i) {
	if (!hdrs[i].key) continue;
	PUSHelt(hdrs[i].key, hdrs[i].val, 0);
    }

SV *
notes(r, key=NULL, ...)
    Apache    r
    char *key

    CODE:
    TABLE_GET_SET(r->notes, FALSE);

    OUTPUT:
    RETVAL

void
pnotes(r, k=Nullsv, val=Nullsv)
    Apache r
    SV *k
    SV *val

    PREINIT:
    perl_request_config *cfg = NULL;
    char *key = NULL;
    STRLEN len;

    CODE:
    if(k) {
	key = SvPV(k,len);
    }
    cfg = (perl_request_config *)
      get_module_config(r->request_config, &perl_module);
    if (!cfg) {
	XSRETURN_UNDEF;
    }

    if(!cfg->pnotes) cfg->pnotes = newHV();
    if(key) {
	if(hv_exists(cfg->pnotes, key, len)) {
	    ST(0) = SvREFCNT_inc(*hv_fetch(cfg->pnotes, key, len, FALSE));
	    sv_2mortal(ST(0));
	}
	else {
	    ST(0) = &sv_undef;
	}
	if(val) {
	    hv_store(cfg->pnotes, key, len, SvREFCNT_inc(val), FALSE);
	}
    }
    else {
	ST(0) = newRV_inc((SV*)cfg->pnotes);
	sv_2mortal(ST(0));
    }

char *
content_type(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->content_type,r->pool);
  
    OUTPUT:
    RETVAL

char *
handler(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->handler,r->pool);
  
    OUTPUT:
    RETVAL

char *
content_encoding(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->content_encoding,r->pool);

    OUTPUT:
    RETVAL

char *
content_language(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->content_language,r->pool);

    OUTPUT:
    RETVAL

void
content_languages(r, avrv=Nullsv)
    Apache	r
    SV *avrv

    PREINIT:   
    I32 gimme = GIMME_V;

    CODE:
    if(avrv && SvROK(avrv))
        r->content_languages = avrv2array_header(avrv, r->pool);

    if(gimme != G_VOID)
        ST(0) = array_header2avrv(r->content_languages);
				   
int
no_cache(r, ...)
    Apache	r

    CODE: 
    get_set_IV(r->no_cache);
    if (r->no_cache) {
	ap_table_setn(r->headers_out, "Pragma", "no-cache");
	ap_table_setn(r->headers_out, "Cache-control", "no-cache");
    }

    OUTPUT:
    RETVAL

#  /* What object is being requested (either directly, or via include
#   * or content-negotiation mapping).
#   */

#  char *uri;                    /* complete URI for a proxy req, or
#                                   URL path for a non-proxy req */
#  char *filename;
#  char *path_info;
#  char *args;			/* QUERY_ARGS, if any */
#  struct stat finfo;		/* ST_MODE set to zero if no such file */

SV *
finfo(r)
    Apache r

    CODE:
    statcache = r->finfo;
    if (r->finfo.st_mode) {
	laststatval = 0;
    }
    else {
	laststatval = -1;
    }
    if(GIMME_V == G_VOID) XSRETURN_UNDEF;
    RETVAL = newRV_noinc((SV*)gv_fetchpv("_", TRUE, SVt_PVIO));

    OUTPUT:
    RETVAL

char *
uri(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->uri,r->pool);

    OUTPUT:
    RETVAL

char *
filename(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->filename,r->pool);
#ifndef WIN32
    if(items > 1)
	stat(r->filename, &r->finfo);
#endif

    OUTPUT:
    RETVAL

char *
path_info(r, ...)
    Apache	r

    CODE:
    get_set_PVp(r->path_info,r->pool);

    OUTPUT:
    RETVAL

void
query_string(r, ...)
    Apache	r

    PREINIT:
    SV *sv = sv_newmortal();

    PPCODE: 
    if(r->args)
	sv_setpv(sv, r->args);
    SvTAINTED_on(sv);
    XPUSHs(sv);

    if(items > 1)
        r->args = pstrdup(r->pool, (char *)SvPV(ST(1),na));

#  /* Various other config info which may change with .htaccess files
#   * These are config vectors, with one void* pointer for each module
#   * (the thing pointed to being the module's business).
#   */
  
#  void *per_dir_config;		/* Options set in config files, etc. */

char *
location(r)
    Apache  r

    CODE:
    if(r->per_dir_config) {				   
	dPPDIR;
        RETVAL = cld->location;
    }
    else XSRETURN_UNDEF;

    OUTPUT:
    RETVAL

SV *
dir_config(r, key=NULL, ...)
    Apache  r
    char *key

    ALIAS:
    Apache::Server::dir_config = 1

    PREINIT:
    perl_dir_config *c;
    perl_server_config *cs;
    server_rec *s;

    CODE:
    ix = ix; /*-Wall*/
    RETVAL = Nullsv;
    if(r && r->per_dir_config) {				   
	c = (perl_dir_config *)get_module_config(r->per_dir_config, 
						 &perl_module);
	TABLE_GET_SET(c->vars, FALSE);
    }
    if (!SvTRUE(RETVAL)) {
	s = r && r->server ? r->server : perl_get_startup_server();
	if (s && s->module_config) {
	    SvREFCNT_dec(RETVAL); /* in case above did newSV(0) */
	    cs = (perl_server_config *)get_module_config(s->module_config, 
							 &perl_module);
	    TABLE_GET_SET(cs->vars, FALSE);
	}
	else XSRETURN_UNDEF;
    }
 
    OUTPUT:
    RETVAL
   
#  void *request_config;		/* Notes on *this* request */

#/*
# * a linked list of the configuration directives in the .htaccess files
# * accessed by this request.
# * N.B. always add to the head of the list, _never_ to the end.
# * that way, a sub request's list can (temporarily) point to a parent's list
# */
#  const struct htaccess_result *htaccess;
#};

Apache::SubRequest
lookup_uri(r, uri)
    Apache r
    char *uri

    CODE:
    RETVAL = sub_req_lookup_uri(uri,r);

    OUTPUT:
    RETVAL

Apache::SubRequest
lookup_file(r, file)
    Apache r
    char *file

    CODE:
    RETVAL = sub_req_lookup_file(file,r);

    OUTPUT:
    RETVAL

MODULE = Apache  PACKAGE = Apache::SubRequest

BOOT:
    av_push(perl_get_av("Apache::SubRequest::ISA",TRUE), newSVpv("Apache",6));

void
DESTROY(r)
    Apache::SubRequest r

    CODE:
    destroy_sub_req(r);
    MP_TRACE_g(fprintf(stderr, 
	    "Apache::SubRequest::DESTROY(0x%lx)\n", (unsigned long)r));

int
run(r)
    Apache::SubRequest r

    CODE:
    RETVAL = run_sub_req(r);

    OUTPUT:
    RETVAL

