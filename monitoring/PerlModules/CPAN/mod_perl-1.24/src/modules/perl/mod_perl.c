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


/* 
 * And so it was decided the camel should be given magical multi-colored
 * feathers so it could fly and journey to once unknown worlds.
 * And so it was done...
 */

#define CORE_PRIVATE 
#include "mod_perl.h"

#ifdef WIN32
void *mod_perl_mutex = &mod_perl_mutex;
#else
void *mod_perl_dummy_mutex = &mod_perl_dummy_mutex;
#endif

static IV mp_request_rec;
static int seqno = 0;
static int perl_is_running = 0;
int mod_perl_socketexitoption = 3;
int mod_perl_weareaforkedchild = 0;     
static int callbacks_this_request = 0;
static PerlInterpreter *perl = NULL;
static AV *orig_inc = Nullav;
static AV *cleanup_av = Nullav;
#ifdef PERL_STACKED_HANDLERS
static HV *stacked_handlers = Nullhv;
#endif

#ifdef PERL_OBJECT
CPerlObj *pPerl;
#endif

typedef const char* (*crft)(); /* command_req_func_t */

static command_rec perl_cmds[] = {
#ifdef PERL_SECTIONS
    { "<Perl>", (crft) perl_section, NULL, SECTION_ALLOWED, RAW_ARGS, "Perl code" },
    { "</Perl>", (crft) perl_end_section, NULL, SECTION_ALLOWED, NO_ARGS, "End Perl code" },
#endif
    { "=pod", (crft) perl_pod_section, NULL, OR_ALL, RAW_ARGS, "Start of POD" },
    { "=back", (crft) perl_pod_section, NULL, OR_ALL, RAW_ARGS, "End of =over" },
    { "=cut", (crft) perl_pod_end_section, NULL, OR_ALL, NO_ARGS, "End of POD" },
    { "__END__", (crft) perl_config_END, NULL, OR_ALL, RAW_ARGS, "Stop reading config" },
    { "PerlFreshRestart", (crft) perl_cmd_fresh_restart,
      NULL,
      RSRC_CONF, FLAG, "Tell mod_perl to reload modules and flush Apache::Registry cache on restart" },
    { "PerlTaintCheck", (crft) perl_cmd_tainting,
      NULL,
      RSRC_CONF, FLAG, "Turn on -T switch" },
#ifdef PERL_SAFE_STARTUP
    { "PerlOpmask", (crft) perl_cmd_opmask,
      NULL,
      RSRC_CONF, TAKE1, "Opmask File" },
#endif
    { "PerlWarn", (crft) perl_cmd_warn,
      NULL,
      RSRC_CONF, FLAG, "Turn on -w switch" },
    { "PerlScript", (crft) perl_cmd_require,
      NULL,
      OR_ALL, ITERATE, "this directive is deprecated, use `PerlRequire'" },
    { "PerlRequire", (crft) perl_cmd_require,
      NULL,
      OR_ALL, ITERATE, "A Perl script name, pulled in via require" },
    { "PerlModule", (crft) perl_cmd_module,
      NULL,
      OR_ALL, ITERATE, "List of Perl modules" },
    { "PerlSetVar", (crft) perl_cmd_var,
      NULL,
      OR_ALL, TAKE2, "Perl config var and value" },
    { "PerlAddVar", (crft) perl_cmd_var,
      (void*)1,
      OR_ALL, TAKE2, "Perl config var and value" },
    { "PerlSetEnv", (crft) perl_cmd_setenv,
      NULL,
      OR_ALL, TAKE2, "Perl %ENV key and value" },
    { "PerlPassEnv", (crft) perl_cmd_pass_env, 
      NULL,
      RSRC_CONF, ITERATE, "pass environment variables to %ENV"},  
    { "PerlSendHeader", (crft) perl_cmd_sendheader,
      NULL,
      OR_ALL, FLAG, "Tell mod_perl to parse and send HTTP headers" },
    { "PerlSetupEnv", (crft) perl_cmd_env,
      NULL,
      OR_ALL, FLAG, "Tell mod_perl to setup %ENV by default" },
    { "PerlHandler", (crft) perl_cmd_handler_handlers,
      NULL,
      OR_ALL, ITERATE, "the Perl handler routine name" },
#ifdef PERL_TRANS
    { PERL_TRANS_CMD_ENTRY },
#endif
#ifdef PERL_AUTHEN
    { PERL_AUTHEN_CMD_ENTRY },
#endif
#ifdef PERL_AUTHZ
    { PERL_AUTHZ_CMD_ENTRY },
#endif
#ifdef PERL_ACCESS
    { PERL_ACCESS_CMD_ENTRY },
#endif
#ifdef PERL_TYPE
    { PERL_TYPE_CMD_ENTRY },
#endif
#ifdef PERL_FIXUP
    { PERL_FIXUP_CMD_ENTRY },
#endif
#ifdef PERL_LOG
    { PERL_LOG_CMD_ENTRY },
#endif
#ifdef PERL_CLEANUP
    { PERL_CLEANUP_CMD_ENTRY },
#endif
#ifdef PERL_INIT
    { PERL_INIT_CMD_ENTRY },
#endif
#ifdef PERL_HEADER_PARSER
    { PERL_HEADER_PARSER_CMD_ENTRY },
#endif
#ifdef PERL_CHILD_INIT
    { PERL_CHILD_INIT_CMD_ENTRY },
#endif
#ifdef PERL_CHILD_EXIT
    { PERL_CHILD_EXIT_CMD_ENTRY },
#endif
#ifdef PERL_POST_READ_REQUEST
    { PERL_POST_READ_REQUEST_CMD_ENTRY },
#endif
#ifdef PERL_DISPATCH
    { PERL_DISPATCH_CMD_ENTRY },
#endif
#ifdef PERL_RESTART
    { PERL_RESTART_CMD_ENTRY },
#endif
    { NULL }
};

static handler_rec perl_handlers [] = {
    { "perl-script", perl_handler },
    { DIR_MAGIC_TYPE, perl_handler },
    { NULL }
};

module MODULE_VAR_EXPORT perl_module = {
    STANDARD_MODULE_STUFF,
    perl_module_init,                 /* initializer */
    perl_create_dir_config,    /* create per-directory config structure */
    perl_merge_dir_config,     /* merge per-directory config structures */
    perl_create_server_config, /* create per-server config structure */
    perl_merge_server_config,  /* merge per-server config structures */
    perl_cmds,                 /* command table */
    perl_handlers,             /* handlers */
    PERL_TRANS_HOOK,           /* translate_handler */
    PERL_AUTHEN_HOOK,          /* check_user_id */
    PERL_AUTHZ_HOOK,           /* check auth */
    PERL_ACCESS_HOOK,          /* check access */
    PERL_TYPE_HOOK,            /* type_checker */
    PERL_FIXUP_HOOK,           /* pre-run fixups */
    PERL_LOG_HOOK,          /* logger */
#if MODULE_MAGIC_NUMBER >= 19970103
    PERL_HEADER_PARSER_HOOK,   /* header parser */
#endif
#if MODULE_MAGIC_NUMBER >= 19970719
    PERL_CHILD_INIT_HOOK,   /* child_init */
#endif
#if MODULE_MAGIC_NUMBER >= 19970728
    NULL,   /* child_exit *//* mod_perl uses register_cleanup() */
#endif
#if MODULE_MAGIC_NUMBER >= 19970825
    PERL_POST_READ_REQUEST_HOOK,   /* post_read_request */
#endif
};

#if defined(STRONGHOLD) && !defined(APACHE_SSL)
#define APACHE_SSL
#endif

int PERL_RUNNING (void) 
{
    return (perl_is_running);
}

static void seqno_check_max(request_rec *r, int seqno)
{
    dPPDIR;
    char *max = NULL;
    array_header *vars = (array_header *)cld->vars;

    /* XXX: what triggers such a condition ?*/
    if(vars && (vars->nelts > 100000)) {
	fprintf(stderr, "[warning] PerlSetVar->nelts = %d\n", vars->nelts);
    }
    else {
      if(cld->vars)
	  max = (char *)table_get(cld->vars, "MaxModPerlRequestsPerChild");
    }

#if (MODULE_MAGIC_NUMBER >= 19970912) && !defined(WIN32)
    if(max && (seqno >= atoi(max))) {
	child_terminate(r);
	MP_TRACE_g(fprintf(stderr, "mod_perl: terminating child %d after serving %d requests\n", 
		(int)getpid(), seqno));
    }
#endif
    max = NULL; 
}

void perl_shutdown (server_rec *s, pool *p)
{
    char *pdl = NULL;

    if((pdl = getenv("PERL_DESTRUCT_LEVEL")))
	perl_destruct_level = atoi(pdl);
    else
	perl_destruct_level = PERL_DESTRUCT_LEVEL;

    if(perl_destruct_level < 0) {
	MP_TRACE_g(fprintf(stderr, 
			   "skipping destruction of Perl interpreter\n"));
	return;
    }

    /* execute END blocks we suspended during perl_startup() */
    perl_run_endav("perl_shutdown"); 

    MP_TRACE_g(fprintf(stderr, 
		     "destructing and freeing Perl interpreter (level=%d)...",
	       perl_destruct_level));

    perl_util_cleanup();

    mp_request_rec = 0;

    av_undef(orig_inc);
    SvREFCNT_dec((SV*)orig_inc);
    orig_inc = Nullav;

    av_undef(cleanup_av);
    SvREFCNT_dec((SV*)cleanup_av);
    cleanup_av = Nullav;

#ifdef PERL_STACKED_HANDLERS
    hv_undef(stacked_handlers);
    SvREFCNT_dec((SV*)stacked_handlers);
    stacked_handlers = Nullhv;
#endif
    
    perl_destruct(perl);
    perl_free(perl);

#ifdef USE_THREADS
    PERL_SYS_TERM();
#endif

    perl_is_running = 0;
    MP_TRACE_g(fprintf(stderr, "ok\n"));
}

request_rec *mp_fake_request_rec(server_rec *s, pool *p, char *hook)
{
    request_rec *r = (request_rec *)pcalloc(p, sizeof(request_rec));
    r->pool = p; 
    r->server = s;
    r->per_dir_config = NULL;
    r->uri = hook;
    r->notes = NULL;
    return r;
}

#ifdef PERL_RESTART
void perl_restart_handler(server_rec *s, pool *p)
{
    char *hook = "PerlRestartHandler";
    dSTATUS;
    dPSRV(s);
    request_rec *r = mp_fake_request_rec(s, p, hook);
    PERL_CALLBACK(hook, cls->PerlRestartHandler);   
}
#endif

void perl_restart(server_rec *s, pool *p)
{
    /* restart as best we can */
    SV *rgy_cache = perl_get_sv("Apache::Registry", FALSE);
    HV *rgy_symtab = (HV*)gv_stashpv("Apache::ROOT", FALSE);

    ENTER;

    SAVESPTR(warnhook);
    warnhook = perl_eval_pv("sub {}", TRUE);

    /* the file-stat cache */
    if(rgy_cache)
	sv_setsv(rgy_cache, &sv_undef);

    /* the symbol table we compile registry scripts into */
    if(rgy_symtab)
	hv_clear(rgy_symtab);

    if(endav) {
	SvREFCNT_dec(endav);
	endav = Nullav;
    }

#ifdef STACKED_HANDLERS
    if(stacked_handlers) 
	hv_clear(stacked_handlers);
#endif

    /* reload %INC */
    perl_reload_inc(s, p);

    LEAVE;

    /*mod_perl_notice(s, "mod_perl restarted"); */
    MP_TRACE_g(fprintf(stderr, "perl_restart: ok\n"));
}

U32 mp_debug = 0;

static void mod_perl_set_cwd(void)
{
    char *name = "Apache::Server::CWD";
    GV *gv = gv_fetchpv(name, GV_ADDMULTI, SVt_PV);
    char *pwd = getenv("PWD");

    if(pwd) 
	sv_setpv(GvSV(gv), pwd);
    else 
	sv_setsv(GvSV(gv), 
		 perl_eval_pv("require Cwd; Cwd::getcwd()", TRUE));

    mod_perl_untaint(GvSV(gv));
}

#ifdef PERL_TIE_SCRIPTNAME
static I32 scriptname_val(IV ix, SV* sv)
{ 
    dTHR;
    request_rec *r = perl_request_rec(NULL);
    if(r) 
	sv_setpv(sv, r->filename);
    else if(strNE(SvPVX(GvSV(CopFILEGV(curcop))), "-e"))
	sv_setsv(sv, GvSV(CopFILEGV(curcop)));
    else {
	SV *file = perl_eval_pv("(caller())[1]",TRUE);
	sv_setsv(sv, file);
    }
    MP_TRACE_g(fprintf(stderr, "FETCH $0 => %s\n", SvPV(sv,na)));
    return TRUE;
}

static void mod_perl_tie_scriptname(void)
{
    SV *sv = perl_get_sv("0",TRUE);
    struct ufuncs umg;
    umg.uf_val = scriptname_val;
    umg.uf_set = NULL;
    umg.uf_index = (IV)0;
    sv_unmagic(sv, 'U');
    sv_magic(sv, Nullsv, 'U', (char*) &umg, sizeof(umg));
}
#else
#define mod_perl_tie_scriptname()
#endif

#define saveINC \
    if(orig_inc) SvREFCNT_dec(orig_inc); \
    orig_inc = av_copy_array(GvAV(incgv))

#define dl_librefs "DynaLoader::dl_librefs"
#define dl_modules "DynaLoader::dl_modules"

static array_header *xs_dl_librefs(pool *p)
{
    I32 i;
    AV *librefs = perl_get_av(dl_librefs, FALSE);
    AV *modules = perl_get_av(dl_modules, FALSE);
    array_header *arr;

    if (!librefs) {
	MP_TRACE_g(fprintf(stderr, 
			   "Could not get @%s for unloading.\n",
			   dl_librefs));
	return NULL;
    }

    arr = ap_make_array(p, AvFILL(librefs)-1, sizeof(void *));

    for (i=0; i<=AvFILL(librefs); i++) {
	void *handle;
	SV *handle_sv = *av_fetch(librefs, i, FALSE);
	SV *module_sv = *av_fetch(modules, i, FALSE);

	if(!handle_sv) {
	    MP_TRACE_g(fprintf(stderr, 
			       "Could not fetch $%s[%d]!\n",
			       dl_librefs, (int)i));
	    continue;
	}
	handle = (void *)SvIV(handle_sv);

	MP_TRACE_g(fprintf(stderr, "%s dl handle == 0x%lx\n",
			   SvPVX(module_sv), (unsigned long)handle));
	if (handle) {
	    *(void **)ap_push_array(arr) = handle;
	}
    }

    av_clear(modules);
    av_clear(librefs);

    return arr;
}

static void unload_xs_so(array_header *librefs)
{
    int i;

    if (!librefs) {
	return;
    }

    for (i=0; i < librefs->nelts; i++) {
	void *handle = ((void **)librefs->elts)[i];
	MP_TRACE_g(fprintf(stderr, "unload_xs_so: 0x%lx\n",
			   (unsigned long)handle));
#ifdef _AIX
	/* make sure Perl's dlclose is used, instead of Apache's */
	dlclose(handle);
#else
	ap_os_dso_unload(handle);
#endif
    }
}

#if 0
/* unload_xs_dso should obsolete this hack */
static void cancel_dso_dlclose(void)
{
    module *modp;

    if(!PERL_DSO_UNLOAD)
	return;

    if(strEQ(top_module->name, "mod_perl.c"))
	return;

    for(modp = top_module; modp; modp = modp->next) {
	if(modp->dynamic_load_handle) {
	    MP_TRACE_g(fprintf(stderr, 
			       "mod_perl: cancel dlclose for %s\n", 
			       modp->name));
	    modp->dynamic_load_handle = NULL;
	}
    }
}
#endif

static void mp_dso_unload(void *data) 
{ 
    array_header *librefs = xs_dl_librefs((pool *)data);
    perl_shutdown(NULL, NULL);
    unload_xs_so(librefs);
} 

static void mp_server_notstarting(void *data) 
{
    saveINC;
    require_Apache(NULL); 
    Apache__ServerStarting(FALSE);
}

#define Apache__ServerStarting_on() \
    Apache__ServerStarting(PERL_RUNNING()); \
    if(!PERL_IS_DSO) \
        register_cleanup(p, NULL, mp_server_notstarting, mod_perl_noop) 

#define MP_APACHE_VERSION "1.26"

void mp_check_version(void)
{
    I32 i;
    SV *namesv;
    SV *version;
    STRLEN n_a;

    require_Apache(NULL);

    if(!(version = perl_get_sv("Apache::VERSION", FALSE)))
	croak("Apache.pm failed to load!"); /*should never happen*/
    if(strEQ(SvPV(version,n_a), MP_APACHE_VERSION)) /*no worries*/
	return;

    fprintf(stderr, "Apache.pm version %s required!\n", 
	    MP_APACHE_VERSION);
    fprintf(stderr, "%s", form("%_ is version %_\n", 
			       *hv_fetch(GvHV(incgv), "Apache.pm", 9, FALSE),
			       version));
    fprintf(stderr, 
	    "Perhaps you forgot to 'make install' or need to uninstall an old version?\n");

    namesv = NEWSV(806, 0);
    for(i=0; i<=AvFILL(GvAV(incgv)); i++) {
	char *tryname;
	PerlIO *tryrsfp = 0;
	SV *dir = *av_fetch(GvAV(incgv), i, TRUE);
	sv_setpvf(namesv, "%_/Apache.pm", dir);
	tryname = SvPVX(namesv);
	if((tryrsfp = PerlIO_open(tryname, "r"))) {
	    fprintf(stderr, "Found: %s\n", tryname);
	    PerlIO_close(tryrsfp);
	}
    }
    SvREFCNT_dec(namesv);
    exit(1);
}

#if !HAS_MMN_136
static void set_sigpipe(void)
{
    char *dargs[] = { NULL };
    perl_require_module("Apache::SIG", NULL);
    perl_call_argv("Apache::SIG::set", G_DISCARD, dargs);
}
#endif

void perl_module_init(server_rec *s, pool *p)
{
#if HAS_MMN_130
    ap_add_version_component(MOD_PERL_STRING_VERSION);
    if(PERL_RUNNING()) {
#ifdef PERL_IS_5_6
	char *version = form("Perl/v%vd", PL_patchlevel);
#else
	char *version = form("Perl/%_", perl_get_sv("]", TRUE));
#endif
	if(perl_get_sv("Apache::Server::AddPerlVersion", FALSE)) {
	    ap_add_version_component(version);
	}
    }
#endif
    perl_startup(s, p);
}

void perl_startup (server_rec *s, pool *p)
{
    char *argv[] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL };
    char **entries, *dstr;
    int status, i, argc=1;
    dPSRV(s);
    SV *pool_rv, *server_rv;
    GV *gv, *shgv;

#ifndef WIN32
    argv[0] = server_argv0;
#endif

#ifdef PERL_TRACE
    if((dstr = getenv("MOD_PERL_TRACE"))) {
	if(strEQ(dstr, "all")) {
	    mp_debug = 0xffffffff;
	}
	else if (isALPHA(dstr[0])) {
	    static char debopts[] = "dshgc";
	    char *d;

	    for (; *dstr && (d = strchr(debopts,*dstr)); dstr++) 
		mp_debug |= 1 << (d - debopts);
	}
	else {
	    mp_debug = atoi(dstr);
	}
	mp_debug |= 0x80000000;
    }
#else
    dstr = NULL;
#endif

    if(PERL_RUNNING() && PERL_STARTUP_IS_DONE) {
	saveINC;
	mp_check_version();
#if !HAS_MMN_136
	set_sigpipe();
#endif
    }
    
    if(perl_is_running == 0) {
	/* we'll boot Perl below */
    }
    else if(perl_is_running < PERL_DONE_STARTUP) {
	/* skip the -HUP at server-startup */
	perl_is_running++;
	Apache__ServerStarting_on();
	MP_TRACE_g(fprintf(stderr, "perl_startup: perl aleady running...ok\n"));
	return;
    }
    else {
	Apache__ServerReStarting(TRUE);

#ifdef PERL_RESTART
	perl_restart_handler(s, p);
#endif
	if(cls->FreshRestart)
	    perl_restart(s, p);

	Apache__ServerReStarting(FALSE);

	return;
    }
    perl_is_running++;

    /* fake-up what the shell usually gives perl */
    if(cls->PerlTaintCheck) 
	argv[argc++] = "-T";

    if(cls->PerlWarn)
	argv[argc++] = "-w";

#ifdef WIN32
    argv[argc++] = "nul";
#else
    argv[argc++] = "/dev/null";
#endif

    MP_TRACE_g(fprintf(stderr, "perl_parse args: "));
    for(i=1; i<argc; i++)
	MP_TRACE_g(fprintf(stderr, "'%s' ", argv[i]));
    MP_TRACE_g(fprintf(stderr, "..."));

#ifdef USE_THREADS
# ifdef PERL_SYS_INIT
    PERL_SYS_INIT(&argc,&argv);
# endif
#endif

#ifndef perl_init_i18nl10n
    perl_init_i18nl10n(1);
#else
    /* 5.6 calls during perl_construct() */
#endif

    MP_TRACE_g(fprintf(stderr, "allocating perl interpreter..."));
    if((perl = perl_alloc()) == NULL) {
	MP_TRACE_g(fprintf(stderr, "not ok\n"));
	perror("alloc");
	exit(1);
    }
    MP_TRACE_g(fprintf(stderr, "ok\n"));
  
    MP_TRACE_g(fprintf(stderr, "constructing perl interpreter...ok\n"));
    perl_construct(perl);

    status = perl_parse(perl, xs_init, argc, argv, NULL);
    if (status != OK) {
	MP_TRACE_g(fprintf(stderr,"not ok, status=%d\n", status));
	perror("parse");
	exit(1);
    }
    MP_TRACE_g(fprintf(stderr, "ok\n"));

    perl_clear_env();
    mod_perl_pass_env(p, cls);
    mod_perl_set_cwd();
    mod_perl_tie_scriptname();
    MP_TRACE_g(fprintf(stderr, "running perl interpreter..."));

    pool_rv = perl_get_sv("Apache::__POOL", TRUE);
    sv_setref_pv(pool_rv, Nullch, (void*)p);
    server_rv = perl_get_sv("Apache::__SERVER", TRUE);
    sv_setref_pv(server_rv, Nullch, (void*)s);

    gv = GvSV_init("Apache::ERRSV_CAN_BE_HTTP");
#ifdef ERRSV_CAN_BE_HTTP
    GvSV_setiv(gv, TRUE);
#endif

    perl_tainting_set(s, cls->PerlTaintCheck);
    (void)GvSV_init("Apache::__SendHeader");
    (void)GvSV_init("Apache::__CurrentCallback");
    if (ap_configtestonly)
    	GvSV_setiv(GvSV_init("Apache::Server::ConfigTestOnly"), TRUE);

    Apache__ServerReStarting(FALSE); /* just for -w */
    Apache__ServerStarting_on();

#ifdef PERL_STACKED_HANDLERS
    if(!stacked_handlers) {
	stacked_handlers = newHV();
	shgv = GvHV_init("Apache::PerlStackedHandlers");
	GvHV(shgv) = stacked_handlers;
    }
#endif 
#ifdef MULTITHREAD
    mod_perl_mutex = create_mutex(NULL);
#endif

    if ((status = perl_run(perl)) != OK) {
	MP_TRACE_g(fprintf(stderr,"not ok, status=%d\n", status));
	perror("run");
	exit(1);
    }
    MP_TRACE_g(fprintf(stderr, "ok\n"));

    /* Force the environment to be copied out of its original location
       above argv[].  This fixes a crash caused when a module called putenv()
       before any Perl modified the environment - environ would change to a
       new value, and the check in my_setenv() to duplicate the environment
       would fail, and then setting some environment value which had a previous
       value would cause perl to try to free() something from the original env.
       This crashed free(). */
    my_setenv("MODPERL_ENV_FIXUP", "0");
    my_setenv("MODPERL_ENV_FIXUP", NULL);

    {
	dTHR;
	TAINT_NOT; /* At this time all is safe */
    }

#ifdef APACHE_PERL5LIB
    perl_incpush(APACHE_PERL5LIB);
#else
    av_push(GvAV(incgv), newSVpv(server_root_relative(p,""),0));
    av_push(GvAV(incgv), newSVpv(server_root_relative(p,"lib/perl"),0));
#endif

    /* *CORE::GLOBAL::exit = \&Apache::exit */
    if(gv_stashpv("CORE::GLOBAL", FALSE)) {
	GV *exitgp = gv_fetchpv("CORE::GLOBAL::exit", TRUE, SVt_PVCV);
	GvCV(exitgp) = perl_get_cv("Apache::exit", TRUE);
	GvIMPORTED_CV_on(exitgp);
    }

    if(PERL_STARTUP_DONE_CHECK)	{
 	char *psd = getenv("PERL_STARTUP_DONE");
 	if (!psd) {
 	    MP_TRACE_g(fprintf(stderr, 
 			       "mod_perl: PerlModule,PerlRequire postponed\n"));
 	    my_setenv("PERL_STARTUP_DONE", "1");
 	    saveINC;
	    return;
	}
 	else { 
 	    MP_TRACE_g(fprintf(stderr, 
 			       "mod_perl: postponed PerlModule,PerlRequire enabled\n"));
 	    my_setenv("PERL_STARTUP_DONE", "2");
	}
    }

    ENTER_SAFE(s,p);
    MP_TRACE_g(mod_perl_dump_opmask());

    entries = (char **)cls->PerlRequire->elts;
    for(i = 0; i < cls->PerlRequire->nelts; i++) {
	if(perl_load_startup_script(s, p, entries[i], TRUE) != OK) {
	    fprintf(stderr, "Require of Perl file `%s' failed, exiting...\n", 
		    entries[i]);
	    exit(1);
	}
    }

    entries = (char **)cls->PerlModule->elts;
    for(i = 0; i < cls->PerlModule->nelts; i++) {
	if(perl_require_module(entries[i], s) != OK) {
	    fprintf(stderr, "Can't load Perl module `%s', exiting...\n", 
		    entries[i]);
	    exit(1);
	}
    }

    LEAVE_SAFE;

    MP_TRACE_g(fprintf(stderr, 
	     "mod_perl: %d END blocks encountered during server startup\n",
	     endav ? (int)AvFILL(endav)+1 : 0));
#if MODULE_MAGIC_NUMBER < 19970728
    if(endav)
	MP_TRACE_g(fprintf(stderr, "mod_perl: cannot run END blocks encoutered at server startup without apache_1.3.0+\n"));
#endif

    saveINC;
#if MODULE_MAGIC_NUMBER >= MMN_130
    if(perl_module.dynamic_load_handle) 
	register_cleanup(p, p, mp_dso_unload, null_cleanup); 
#endif
}

int mod_perl_sent_header(request_rec *r, int val)
{
    dPPDIR;

    if(val) MP_SENTHDR_on(cld);
    val = MP_SENTHDR(cld) ? 1 : 0;
    return MP_SENDHDR(cld) ? val : 1;
}

#ifndef perl_init_ids
#define perl_init_ids mod_perl_init_ids()
#endif

int perl_handler(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    dPPREQ;
    dTHR;
    GV *gv = gv_fetchpv("SIG", TRUE, SVt_PVHV);

    (void)acquire_mutex(mod_perl_mutex);
    
#if 0
    /* force 'PerlSendHeader On' for sub-requests
     * e.g. Apache::Sandwich 
     */
    if(r->main != NULL)
	MP_SENDHDR_on(cld); 
#endif

    if(MP_SENDHDR(cld)) 
	MP_SENTHDR_off(cld);

    (void)perl_request_rec(r); 

    MP_TRACE_g(fprintf(stderr, "perl_handler ENTER: SVs = %5d, OBJs = %5d\n",
		     (int)sv_count, (int)sv_objcount));
    ENTER;
    SAVETMPS;

    if (gv) {
	save_hptr(&GvHV(gv)); 
    }

    if (endav) {
	save_aptr(&endav); 
	endav = Nullav;
    }

    /* hookup STDIN & STDOUT to the client */
    perl_stdout2client(r);
    perl_stdin2client(r);

    if(!cfg) {
        cfg = perl_create_request_config(r->pool, r->server);
        set_module_config(r->request_config, &perl_module, cfg);
    }

    cfg->setup_env = 1;
    PERL_CALLBACK("PerlHandler", cld->PerlHandler);
    cfg->setup_env = 0;

    FREETMPS;
    LEAVE;
    MP_TRACE_g(fprintf(stderr, "perl_handler LEAVE: SVs = %5d, OBJs = %5d\n", 
		     (int)sv_count, (int)sv_objcount));

    (void)release_mutex(mod_perl_mutex);
    return status;
}

#ifdef PERL_CHILD_INIT

typedef struct {
    server_rec *server;
    pool *pool;
} server_hook_args;

static void perl_child_exit_cleanup(void *data)
{
    server_hook_args *args = (server_hook_args *)data;
    PERL_CHILD_EXIT_HOOK(args->server, args->pool);
}

void PERL_CHILD_INIT_HOOK(server_rec *s, pool *p)
{
    char *hook = "PerlChildInitHandler";
    dSTATUS;
    dPSRV(s);
    request_rec *r = mp_fake_request_rec(s, p, hook);
    server_hook_args *args = 
	(server_hook_args *)palloc(p, sizeof(server_hook_args));

    args->server = s;
    args->pool = p;
    register_cleanup(p, args, perl_child_exit_cleanup, null_cleanup);

    mod_perl_init_ids();
    Apache__ServerStarting(FALSE);
    PERL_CALLBACK(hook, cls->PerlChildInitHandler);
}
#endif

#ifdef PERL_CHILD_EXIT
void PERL_CHILD_EXIT_HOOK(server_rec *s, pool *p)
{
    char *hook = "PerlChildExitHandler";
    dSTATUS;
    dPSRV(s);
    request_rec *r = mp_fake_request_rec(s, p, hook);

    PERL_CALLBACK(hook, cls->PerlChildExitHandler);

    perl_shutdown(s,p);
}
#endif

static int do_proxy (request_rec *r)
{
    return 
	!(r->parsed_uri.hostname
	  && strEQ(r->parsed_uri.scheme, ap_http_method(r))
	  && ap_matches_request_vhost(r, r->parsed_uri.hostname,
				      r->parsed_uri.port_str ? 
				      r->parsed_uri.port : 
				      ap_default_port(r)));
}

#ifdef PERL_POST_READ_REQUEST
int PERL_POST_READ_REQUEST_HOOK(request_rec *r)
{
    dSTATUS;
    dPSRV(r->server);
#if MODULE_MAGIC_NUMBER > 19980270
    if(r->parsed_uri.scheme && r->parsed_uri.hostname && do_proxy(r)) {
	r->proxyreq = 1;
	r->uri = r->unparsed_uri;
    }
#endif
#ifdef PERL_INIT
    PERL_CALLBACK("PerlInitHandler", cls->PerlInitHandler);
#endif
    PERL_CALLBACK("PerlPostReadRequestHandler", cls->PerlPostReadRequestHandler);
    return status;
}
#endif

#ifdef PERL_TRANS
int PERL_TRANS_HOOK(request_rec *r)
{
    dSTATUS;
    dPSRV(r->server);
    PERL_CALLBACK("PerlTransHandler", cls->PerlTransHandler);
    return status;
}
#endif

#ifdef PERL_HEADER_PARSER
int PERL_HEADER_PARSER_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
#ifdef PERL_INIT
    PERL_CALLBACK("PerlInitHandler", 
			 cld->PerlInitHandler);
#endif
    PERL_CALLBACK("PerlHeaderParserHandler", 
			 cld->PerlHeaderParserHandler);
    return status;
}
#endif

#ifdef PERL_AUTHEN
int PERL_AUTHEN_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlAuthenHandler", cld->PerlAuthenHandler);
    return status;
}
#endif

#ifdef PERL_AUTHZ
int PERL_AUTHZ_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlAuthzHandler", cld->PerlAuthzHandler);
    return status;
}
#endif

#ifdef PERL_ACCESS
int PERL_ACCESS_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlAccessHandler", cld->PerlAccessHandler);
    return status;
}
#endif

#ifdef PERL_TYPE
int PERL_TYPE_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlTypeHandler", cld->PerlTypeHandler);
    return status;
}
#endif

#ifdef PERL_FIXUP
int PERL_FIXUP_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlFixupHandler", cld->PerlFixupHandler);
    return status;
}
#endif

#ifdef PERL_LOG
int PERL_LOG_HOOK(request_rec *r)
{
    dSTATUS;
    dPPDIR;
    PERL_CALLBACK("PerlLogHandler", cld->PerlLogHandler);
    return status;
}
#endif

#ifdef PERL_STACKED_HANDLERS
#define CleanupHandler \
((cld->PerlCleanupHandler && SvREFCNT(cld->PerlCleanupHandler)) ? cld->PerlCleanupHandler : Nullav)
#else
#define CleanupHandler cld->PerlCleanupHandler
#endif

#ifdef PERL_TRACE
static char *my_signame(I32 num)
{
#ifdef psig_name
    return Perl_psig_name[num] ?
	SvPV(Perl_psig_name[num],na) : "?";
#else
    return PL_sig_name[num];
#endif
}

#endif

static void per_request_cleanup(request_rec *r)
{
    dPPREQ;
    perl_request_sigsave **sigs;
    int i;

    if(!cfg) {
	return;
    }
    if(cfg->pnotes) {
	hv_clear(cfg->pnotes);
	SvREFCNT_dec(cfg->pnotes);
	cfg->pnotes = Nullhv;
    }

#ifndef WIN32
    sigs = (perl_request_sigsave **)cfg->sigsave->elts;
    for (i=0; i < cfg->sigsave->nelts; i++) {
	MP_TRACE_g(fprintf(stderr, 
			   "mod_perl: restoring SIG%s (%d) handler from: 0x%lx to: 0x%lx\n",
			   my_signame(sigs[i]->signo), (int)sigs[i]->signo,
			   (unsigned long)rsignal_state(sigs[i]->signo),
			   (unsigned long)sigs[i]->h));
	rsignal(sigs[i]->signo, sigs[i]->h);
    }
#endif
}

void mod_perl_end_cleanup(void *data)
{
    request_rec *r = (request_rec *)data;
    dSTATUS;
    dPPDIR;

#ifdef PERL_CLEANUP
    PERL_CALLBACK("PerlCleanupHandler", CleanupHandler);
#endif

    MP_TRACE_g(fprintf(stderr, "perl_end_cleanup..."));
    perl_run_rgy_endav(r->uri);
    per_request_cleanup(r);

    /* clear %ENV */
    perl_clear_env();

    /* reset @INC */
    av_undef(GvAV(incgv));
    SvREFCNT_dec(GvAV(incgv));
    GvAV(incgv) = Nullav;
    GvAV(incgv) = av_copy_array(orig_inc);

    /* reset $/ */
    sv_setpvn(GvSV(gv_fetchpv("/", TRUE, SVt_PV)), "\n", 1);

    {
	dTHR;
	/* %@ */
	hv_clear(ERRHV);
    }

    callbacks_this_request = 0;

#ifdef PERL_STACKED_HANDLERS
    /* reset Apache->push_handlers, but don't clear ExitHandler */
#define CH_EXIT_KEY "PerlChildExitHandler"
    {
	SV *exith = Nullsv;
	if(hv_exists(stacked_handlers, CH_EXIT_KEY, 20)) {
	    exith = *hv_fetch(stacked_handlers, CH_EXIT_KEY, 20, FALSE);
            /* inc the refcnt since hv_clear will dec it */
	    ++SvREFCNT(exith);
	}
	hv_clear(stacked_handlers);
	if(exith) 
	    hv_store(stacked_handlers, CH_EXIT_KEY, 20, exith, FALSE);
    }

#endif

#ifdef USE_SFIO
    PerlIO_flush(PerlIO_stdout());
#endif

    MP_TRACE_g(fprintf(stderr, "ok\n"));
    (void)release_mutex(mod_perl_mutex); 
}

void mod_perl_cleanup_handler(void *data)
{
    request_rec *r = (request_rec *)data;
    SV *cv;
    I32 i;
    dPPDIR;

    (void)acquire_mutex(mod_perl_mutex); 
    MP_TRACE_h(fprintf(stderr, "running registered cleanup handlers...\n")); 
    for(i=0; i<=AvFILL(cleanup_av); i++) { 
	cv = *av_fetch(cleanup_av, i, 0);
	MARK_WHERE("registered cleanup", cv);
	perl_call_handler(cv, (request_rec *)r, Nullav);
	UNMARK_WHERE;
    }
    av_clear(cleanup_av);
#ifndef WIN32
    if(cld) MP_RCLEANUP_off(cld);
#endif
    (void)release_mutex(mod_perl_mutex); 
}

#ifdef PERL_METHOD_HANDLERS
int perl_handler_ismethod(HV *pclass, char *sub)
{
    CV *cv;
    HV *stash;
    GV *gv;
    SV *sv;
    int is_method=0;

    if(!sub) return 0;
    sv = newSVpv(sub,0);
    if(!(cv = sv_2cv(sv, &stash, &gv, FALSE))) {
	GV *gvp = gv_fetchmethod(pclass, sub);
	if (gvp) cv = GvCV(gvp);
    }

#ifdef CVf_METHOD
    if (CvFLAGS(cv) & CVf_METHOD) {
        is_method = 1;
    }
#endif
    if (!is_method && (cv && SvPOK(cv))) {
	is_method = strnEQ(SvPVX(cv), "$$", 2);
    }

    MP_TRACE_h(fprintf(stderr, "checking if `%s' is a method...%s\n", 
	   sub, (is_method ? "yes" : "no")));
    SvREFCNT_dec(sv);
    return is_method;
}
#endif

void mod_perl_noop(void *data) {}

void mod_perl_register_cleanup(request_rec *r, SV *sv)
{
    dPPDIR;

    if(!MP_RCLEANUP(cld)) {
	(void)perl_request_rec(r); 
	register_cleanup(r->pool, (void*)r,
			 mod_perl_cleanup_handler, mod_perl_noop);
	MP_RCLEANUP_on(cld);
	if(cleanup_av == Nullav) cleanup_av = newAV();
    }
    MP_TRACE_h(fprintf(stderr, "registering PerlCleanupHandler\n"));
    
    ++SvREFCNT(sv); av_push(cleanup_av, sv);
}

#ifdef PERL_STACKED_HANDLERS

int mod_perl_push_handlers(SV *self, char *hook, SV *sub, AV *handlers)
{
    int do_store=0, len=strlen(hook);
    SV **svp;

    if(self && SvTRUE(sub)) {
	if(handlers == Nullav) {
	    svp = hv_fetch(stacked_handlers, hook, len, 0);
	    MP_TRACE_h(fprintf(stderr, "fetching %s stack\n", hook));
	    if(svp && SvTRUE(*svp) && SvROK(*svp)) {
		handlers = (AV*)SvRV(*svp);
	    }
	    else {
		MP_TRACE_h(fprintf(stderr, "%s handlers stack undef, creating\n", hook));
		handlers = newAV();
		do_store = 1;
	    }
	}
	    
	if(SvROK(sub) && (SvTYPE(SvRV(sub)) == SVt_PVCV)) {
	    MP_TRACE_h(fprintf(stderr, "pushing CODE ref into `%s' handlers\n", hook));
	}
	else if(SvPOK(sub)) {
	    if(do_store) {
		MP_TRACE_h(fprintf(stderr, 
				   "pushing `%s' into `%s' handlers\n", 
				   SvPV(sub,na), hook));
	    }
	    else {
		MP_TRACE_d(fprintf(stderr, 
				   "pushing `%s' into `%s' handlers\n", 
				   SvPV(sub,na), hook));
	    }
	}
	else {
	    warn("mod_perl_push_handlers: Not a subroutine name or CODE reference!");
	}

	++SvREFCNT(sub); av_push(handlers, sub);

	if(do_store) 
	    hv_store(stacked_handlers, hook, len, 
		     (SV*)newRV_noinc((SV*)handlers), 0);
	return 1;
    }
    return 0;
}

int perl_run_stacked_handlers(char *hook, request_rec *r, AV *handlers)
{
    dSTATUS;
    I32 i, do_clear=FALSE;
    SV *sub, **svp; 
    int hook_len = strlen(hook);

    if(handlers == Nullav) {
	if(hv_exists(stacked_handlers, hook, hook_len)) {
	   svp = hv_fetch(stacked_handlers, hook, hook_len, 0);
	   if(svp && SvROK(*svp)) 
	       handlers = (AV*)SvRV(*svp);
	}
	else {
	    MP_TRACE_h(fprintf(stderr, "`%s' push_handlers() stack is empty\n", hook));
	    return NO_HANDLERS;
	}
	do_clear = TRUE;
	MP_TRACE_h(fprintf(stderr, 
		 "running %d pushed (stacked) handlers for %s...\n", 
			 (int)AvFILL(handlers)+1, r->uri)); 
    }
    else {
#ifdef PERL_STACKED_HANDLERS
      /* XXX: bizarre, 
	 I only see this with httpd.conf.pl and PerlAccessHandler */
	if(SvTYPE((SV*)handlers) != SVt_PVAV) {
#if MODULE_MAGIC_NUMBER > 19970909 
	    aplog_error(APLOG_MARK, APLOG_NOERRNO|APLOG_DEBUG, r->server,
#else
	    fprintf(stderr, 
#endif
		    "[warning] %s stack is not an ARRAY!\n", hook);
	    sv_dump((SV*)handlers);
	    return DECLINED;
	}
#endif
	MP_TRACE_h(fprintf(stderr, 
		 "running %d server configured stacked handlers for %s...\n", 
			 (int)AvFILL(handlers)+1, r->uri)); 
    }
    for(i=0; i<=AvFILL(handlers); i++) {
	MP_TRACE_h(fprintf(stderr, "calling &{%s->[%d]} (%d total)\n", 
			   hook, (int)i, (int)AvFILL(handlers)+1));

	if(!(sub = *av_fetch(handlers, i, FALSE))) {
	    MP_TRACE_h(fprintf(stderr, "sub not defined!\n"));
	}
	else {
	    if(!SvTRUE(sub)) {
		MP_TRACE_h(fprintf(stderr, "sub undef!  skipping callback...\n"));
		continue;
	    }

	    MARK_WHERE(hook, sub);
	    status = perl_call_handler(sub, r, Nullav);
	    UNMARK_WHERE;
	    MP_TRACE_h(fprintf(stderr, "&{%s->[%d]} returned status=%d\n",
			       hook, (int)i, status));
	    if((status != OK) && (status != DECLINED)) {
		if(do_clear)
		    av_clear(handlers);	
		return status;
	    }
	}
    }
    if(do_clear)
	av_clear(handlers);	
    return status;
}

#endif /* PERL_STACKED_HANDLERS */

/* things to do once per-request */
void perl_per_request_init(request_rec *r)
{
    dPPDIR;
    dPPREQ;
    
    /* PerlSendHeader */
    if(MP_SENDHDR(cld)) {
	MP_SENTHDR_off(cld);
	table_set(r->subprocess_env, 
		  "PERL_SEND_HEADER", "On");
    }
    else
	MP_SENTHDR_on(cld);

    if(!cfg) {
	cfg = perl_create_request_config(r->pool, r->server);
	set_module_config(r->request_config, &perl_module, cfg);
    }
    else if (cfg->setup_env && MP_ENV(cld)) { 
	perl_setup_env(r);
	cfg->setup_env = 0; /* just once per-request */
    }

    if(callbacks_this_request++ > 0) return;

    if (!r->main) {
	/* so Apache->request will work before PerlHandler with CGI.pm
	 * XXX: triggers core dump in subrequests, 
	 * so just do in the main request for now
	 */
	(void)perl_request_rec(r);
    }

    /* PerlSetEnv */
    mod_perl_dir_env(r, cld);

    /* SetEnv PERL5LIB */
    if (!MP_INCPUSH(cld)) {
	char *path = (char *)table_get(r->subprocess_env, "PERL5LIB");

	if (path) {
	    perl_incpush(path);
	    MP_INCPUSH_on(cld);
	}
    }

    {
	dPSRV(r->server);
	mod_perl_pass_env(r->pool, cls);
    }
    mod_perl_tie_scriptname();
    /* will be released in mod_perl_end_cleanup */
    (void)acquire_mutex(mod_perl_mutex); 
    register_cleanup(r->pool, (void*)r, mod_perl_end_cleanup, mod_perl_noop);

#ifdef WIN32
    sv_setpvf(perl_get_sv("Apache::CurrentThreadId", TRUE), "0x%lx",
	      (unsigned long)GetCurrentThreadId());
#endif

    /* hookup stderr to error_log */
#ifndef PERL_TRACE
    if(r->server->error_log) 
	error_log2stderr(r->server);
#endif

    seqno++;
    MP_TRACE_g(fprintf(stderr, "mod_perl: inc seqno to %d for %s\n", seqno, r->uri));
    seqno_check_max(r, seqno);

    /* set $$, $>, etc., if 1.3a1+, this really happens during child_init */
    perl_init_ids; 
}

/* XXX this still needs work, getting there... */
int perl_call_handler(SV *sv, request_rec *r, AV *args)
{
    int count, status, is_method=0;
    dSP;
    perl_dir_config *cld = NULL;
    HV *stash = Nullhv;
    SV *pclass = newSVsv(sv), *dispsv = Nullsv;
    CV *cv = Nullcv;
    char *method = "handler";
    int defined_sub = 0, anon = 0;
    char *dispatcher = NULL;

    if(r->per_dir_config)
	cld = (perl_dir_config *) get_module_config(r->per_dir_config, &perl_module);

#ifdef PERL_DISPATCH
    if(cld && (dispatcher = cld->PerlDispatchHandler)) {
	if(!(dispsv = (SV*)perl_get_cv(dispatcher, FALSE))) {
	    if(strlen(dispatcher) > 0) { /* XXX */
		fprintf(stderr, 
			"mod_perl: unable to fetch PerlDispatchHandler `%s'\n",
			dispatcher); 
	    }
	    dispatcher = NULL;
	}
    }
#endif

    if(r->per_dir_config)
	perl_per_request_init(r);

    if(!dispatcher && (SvTYPE(sv) == SVt_PV)) {
	char *imp = pstrdup(r->pool, (char *)SvPV(pclass,na));

	if((anon = strnEQ(imp,"sub ",4))) {
	    sv = perl_eval_pv(imp, FALSE);
	    MP_TRACE_h(fprintf(stderr, "perl_call: caching CV pointer to `__ANON__'\n"));
	    defined_sub++;
	    goto callback; /* XXX, I swear I've never used goto before! */
	}


#ifdef PERL_METHOD_HANDLERS
	{
	    char *end_pclass = NULL;

	    if ((end_pclass = strstr(imp, "->"))) {
		end_pclass[0] = '\0';
		if(pclass)
		    SvREFCNT_dec(pclass);
		pclass = newSVpv(imp, 0);
		end_pclass[0] = ':';
		end_pclass[1] = ':';
		method = &end_pclass[2];
		imp = method;
		++is_method;
	    }
	}

	if(*SvPVX(pclass) == '$') {
	    SV *obj = perl_eval_pv(SvPVX(pclass), TRUE);
	    if(SvROK(obj) && sv_isobject(obj)) {
		MP_TRACE_h(fprintf(stderr, "handler object %s isa %s\n",
				   SvPVX(pclass),  HvNAME(SvSTASH((SV*)SvRV(obj)))));
		SvREFCNT_dec(pclass);
		pclass = obj;
		++SvREFCNT(pclass); /* this will _dec later */
		stash = SvSTASH((SV*)SvRV(pclass));
	    }
	}

	if(pclass && !stash) stash = gv_stashpv(SvPV(pclass,na),FALSE);
	   
#if 0
	MP_TRACE_h(fprintf(stderr, "perl_call: pclass=`%s'\n", SvPV(pclass,na)));
	MP_TRACE_h(fprintf(stderr, "perl_call: imp=`%s'\n", imp));
	MP_TRACE_h(fprintf(stderr, "perl_call: method=`%s'\n", method));
	MP_TRACE_h(fprintf(stderr, "perl_call: stash=`%s'\n", 
			 stash ? HvNAME(stash) : "unknown"));
#endif

#else
	method = NULL; /* avoid warning */
#endif


    /* if a Perl*Handler is not a defined function name,
     * default to the class implementor's handler() function
     * attempt to load the class module if it is not already
     */
	if(!imp) imp = SvPV(sv,na);
	if(!stash) stash = gv_stashpv(imp,FALSE);
	if(!is_method)
	    defined_sub = (cv = perl_get_cv(imp, FALSE)) ? TRUE : FALSE;
#ifdef PERL_METHOD_HANDLERS
	if(!defined_sub && stash) {
	    GV *gvp;
	    MP_TRACE_h(fprintf(stderr, 
		   "perl_call: trying method lookup on `%s' in class `%s'...", 
		   method, HvNAME(stash)));
	    /* XXX Perl caches method lookups internally, 
	     * should we cache this lookup?
	     */
	    if((gvp = gv_fetchmethod(stash, method))) {
		cv = GvCV(gvp);
		MP_TRACE_h(fprintf(stderr, "found\n"));
		is_method = perl_handler_ismethod(stash, method);
	    }
	    else {
		MP_TRACE_h(fprintf(stderr, "not found\n"));
	    }
	}
#endif

	if(!stash && !defined_sub) {
	    MP_TRACE_h(fprintf(stderr, "%s symbol table not found, loading...\n", imp));
	    if(perl_require_module(imp, r->server) == OK)
		stash = gv_stashpv(imp,FALSE);
#ifdef PERL_METHOD_HANDLERS
	    if(stash) /* check again */
		is_method = perl_handler_ismethod(stash, method);
#endif
	    SPAGAIN; /* reset stack pointer after require() */
	}
	
	if(!is_method && !defined_sub) {
	    MP_TRACE_h(fprintf(stderr, 
			     "perl_call: defaulting to %s::handler\n", imp));
	    sv_catpv(sv, "::handler");
	}
	
#if 0 /* XXX: CV lookup cache disabled for now */
 	if(!is_method && defined_sub) { /* cache it */
	    MP_TRACE_h(fprintf(stderr, 
			     "perl_call: caching CV pointer to `%s'\n", 
			     (anon ? "__ANON__" : SvPV(sv,na))));
	    SvREFCNT_dec(sv);
 	    sv = (SV*)newRV((SV*)cv); /* let newRV inc the refcnt */
	}
#endif
    }
    else {
	MP_TRACE_h(fprintf(stderr, "perl_call: handler is a %s\n", 
			 dispatcher ? "dispatcher" : "cached CV"));
    }

callback:
    ENTER;
    SAVETMPS;
    PUSHMARK(sp);
#ifdef PERL_METHOD_HANDLERS
    if(is_method)
	XPUSHs(sv_2mortal(pclass));
    else
	SvREFCNT_dec(pclass);
#else
    SvREFCNT_dec(pclass);
#endif

    XPUSHs((SV*)perl_bless_request_rec(r)); 

    if(dispatcher) {
	MP_TRACE_h(fprintf(stderr, 
		 "mod_perl: handing off to PerlDispatchHandler `%s'\n", 
			 dispatcher));
        /*XPUSHs(sv_mortalcopy(sv));*/
	XPUSHs(sv);
	sv = dispsv;
    }

    {
	I32 i, len = (args ? AvFILL(args) : 0);

	if(args) {
	    EXTEND(sp, len);
	    for(i=0; i<=len; i++)
		PUSHs(sv_2mortal(*av_fetch(args, i, FALSE)));
	}
    }
    PUTBACK;
    
    /* use G_EVAL so we can trap errors */
#ifdef PERL_METHOD_HANDLERS
    if(is_method)
	count = perl_call_method(method, G_EVAL | G_SCALAR);
    else
#endif
	count = perl_call_sv(sv, G_EVAL | G_SCALAR);
    
    SPAGAIN;

    if(perl_eval_ok(r->server) != OK) {
	dTHRCTX;
	MP_STORE_ERROR(r->uri, ERRSV);
        if (r->notes) {
            ap_table_set(r->notes, "error-notes", SvPVX(ERRSV));
        }
	if(!perl_sv_is_http_code(ERRSV, &status))
	    status = SERVER_ERROR;
    }
    else if(count != 1) {
	mod_perl_error(r->server,
		       "perl_call did not return a status arg, assuming OK");
	status = OK;
    }
    else {
	status = POPi;

	if((status == 1) || (status == 200) || (status > 600)) 
	    status = OK; 

	if((status == SERVER_ERROR) && ERRSV_CAN_BE_HTTP) {
	    SV *errsv = Nullsv;
	    if(MP_EXISTS_ERROR(r->uri) && (errsv = MP_FETCH_ERROR(r->uri))) {
		(void)perl_sv_is_http_code(errsv, &status);
	    }
	}
    }

    PUTBACK;
    FREETMPS;
    LEAVE;
    MP_TRACE_g(fprintf(stderr, "perl_call_handler: SVs = %5d, OBJs = %5d\n", 
	    (int)sv_count, (int)sv_objcount));

    {
	dTHRCTX;
	if(SvMAGICAL(ERRSV))
	    sv_unmagic(ERRSV, 'U'); /* Apache::exit was called */
    }

    return status;
}

request_rec *perl_request_rec(request_rec *r)
{
    if(r != NULL) {
	mp_request_rec = (IV)r;
	return NULL;
    }
    else
	return (request_rec *)mp_request_rec;
}

SV *perl_bless_request_rec(request_rec *r)
{
    SV *sv = sv_newmortal();
    sv_setref_pv(sv, "Apache", (void*)r);
    MP_TRACE_g(fprintf(stderr, "blessing request_rec=(0x%lx)\n",
		     (unsigned long)r));
    return sv;
}

void perl_setup_env(request_rec *r)
{ 
    int i;
    array_header *arr = perl_cgi_env_init(r);
    table_entry *elts = (table_entry *)arr->elts;

    for (i = 0; i < arr->nelts; ++i) {
	if (!elts[i].key || !elts[i].val) continue;
	mp_setenv(elts[i].key, elts[i].val);
    }
    MP_TRACE_g(fprintf(stderr, "perl_setup_env...%d keys\n", i));
}

int mod_perl_seqno(SV *self, int inc)
{
    self = self; /*avoid warning*/
    if(inc) seqno += inc;
    return seqno;
}

