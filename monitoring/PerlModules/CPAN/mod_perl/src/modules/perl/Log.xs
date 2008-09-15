#include "mod_perl.h"

#if MODULE_MAGIC_NUMBER >= MMN_132
#define HAVE_LOG_RERROR 1
#else
#define HAVE_LOG_RERROR 0
#endif

static void perl_cv_alias(char *to, char *from)
{
    GV *gp = gv_fetchpv(to, TRUE, SVt_PVCV);
    GvCV(gp) = perl_get_cv(from, TRUE);
}

static void ApacheLog(int level, SV *sv, SV *msg)
{
 dTHR;
    char *file = NULL;
    int line   = 0;
    char *str;
    SV *svstr = Nullsv;
    int lmask = level & APLOG_LEVELMASK;
    server_rec *s;
    request_rec *r = NULL;

    if(sv_isa(sv, "Apache::Log::Request") && SvROK(sv)) {
	r = (request_rec *) SvIV((SV*)SvRV(sv));
	s = r->server;
    }
    else if(sv_isa(sv, "Apache::Log::Server") && SvROK(sv)) {
	s = (server_rec *) SvIV((SV*)SvRV(sv));
    }
    else {
        croak("Argument is not an Apache or Apache::Server object");
    }

    if((lmask == APLOG_DEBUG) && (s->loglevel >= APLOG_DEBUG)) {
	SV *caller;
	bool old_T = tainting; tainting = FALSE;
	caller = perl_eval_pv("[ (caller)[1,2] ]", TRUE);
	tainting = old_T;
	file = SvPV(*av_fetch((AV *)SvRV(caller), 0, FALSE),na);
	line = (int)SvIV(*av_fetch((AV *)SvRV(caller), 1, FALSE));
    }

    if((s->loglevel >= lmask) && 
       SvROK(msg) && (SvTYPE(SvRV(msg)) == SVt_PVCV)) {
	dSP;
	ENTER;SAVETMPS;
	PUSHMARK(sp);
	(void)perl_call_sv(msg, G_SCALAR);
	SPAGAIN;
	svstr = POPs;
	++SvREFCNT(svstr);
	PUTBACK;
	FREETMPS;LEAVE;
	str = SvPV(svstr,na);
    }
    else
	str = SvPV(msg,na);

    if(r && HAVE_LOG_RERROR) {
#if HAVE_LOG_RERROR > 0
	ap_log_rerror(file, line, APLOG_NOERRNO|level, r, "%s", str);
#endif
    }
    else {
	ap_log_error(file, line, APLOG_NOERRNO|level, s, "%s", str);
    }

    SvREFCNT_dec(msg);
    if(svstr) SvREFCNT_dec(svstr);
}

#define join_stack_msg \
SV *msgstr; \
if(items > 2) { \
    msgstr = newSV(0); \
    do_join(msgstr, &sv_no, MARK+1, SP); \
} \
else { \
    msgstr = ST(1); \
    ++SvREFCNT(msgstr); \
} 

#define MP_AP_LOG(l,s) \
{ \
join_stack_msg; \
ApacheLog(l, s, msgstr); \
}

#define Apache_log_emerg(s) \
MP_AP_LOG(APLOG_EMERG, s)

#define Apache_log_alert(s) \
MP_AP_LOG(APLOG_ALERT, s)

#define Apache_log_crit(s) \
MP_AP_LOG(APLOG_CRIT, s)

#define Apache_log_error(s) \
MP_AP_LOG(APLOG_ERR, s)

#define Apache_log_warn(s) \
MP_AP_LOG(APLOG_WARNING, s)

#define Apache_log_notice(s) \
MP_AP_LOG(APLOG_NOTICE, s)

#define Apache_log_info(s) \
MP_AP_LOG(APLOG_INFO, s)

#define Apache_log_debug(s) \
MP_AP_LOG(APLOG_DEBUG, s)

MODULE = Apache::Log		PACKAGE = Apache

PROTOTYPES: DISABLE

BOOT:
    perl_cv_alias("Apache::log", "Apache::Log::log");
    perl_cv_alias("Apache::Server::log", "Apache::Log::log");
    perl_cv_alias("emergency", "emerg");
    perl_cv_alias("critical", "crit");

    av_push(perl_get_av("Apache::Log::Request::ISA",TRUE), 
	    newSVpv("Apache::Log",11));
    av_push(perl_get_av("Apache::Log::Server::ISA",TRUE), 
	    newSVpv("Apache::Log",11));

    items = items; /*avoid warning*/ 

MODULE = Apache::Log		PACKAGE = Apache::Log PREFIX=Apache_log_

void
Apache_log_log(sv)
    SV *sv

    PREINIT:
    void *retval;
    char *pclass = "Apache::Log::Request";

    CODE:
    if(!SvROK(sv))
        croak("Argument is not a reference");

    if(sv_derived_from(sv, "Apache")) {
	retval = (void*)sv2request_rec(sv, "Apache", cv);
    }
    else if(sv_derived_from(sv, "Apache::Server")) {
	pclass = "Apache::Log::Server";
	retval = (void *) SvIV((SV*)SvRV(sv));
    }
    else {
        croak("Argument is not an Apache or Apache::Server object");
    }

    ST(0) = sv_newmortal();
    sv_setref_pv(ST(0), pclass, (void*)retval);

void
Apache_log_emerg(s, ...)
	SV *s

void
Apache_log_alert(s, ...)
	SV *s

void
Apache_log_crit(s, ...)
	SV *s

void
Apache_log_error(s, ...)
	SV *s

void
Apache_log_warn(s, ...)
	SV *s

void
Apache_log_notice(s, ...)
	SV *s

void
Apache_log_info(s, ...)
	SV *s

void
Apache_log_debug(s, ...)
	SV *s

MODULE = Apache::Log		PACKAGE = Apache::Server

PROTOTYPES: DISABLE

BOOT:
#ifdef newCONSTSUB
 {
    HV *stash = gv_stashpv("Apache::Log", TRUE);
    newCONSTSUB(stash, "EMERG",   newSViv(APLOG_EMERG));
    newCONSTSUB(stash, "ALERT",   newSViv(APLOG_ALERT));
    newCONSTSUB(stash, "CRIT",    newSViv(APLOG_CRIT));
    newCONSTSUB(stash, "ERR",     newSViv(APLOG_ERR));
    newCONSTSUB(stash, "WARNING", newSViv(APLOG_WARNING));
    newCONSTSUB(stash, "NOTICE",  newSViv(APLOG_NOTICE));
    newCONSTSUB(stash, "INFO",    newSViv(APLOG_INFO));
    newCONSTSUB(stash, "DEBUG",   newSViv(APLOG_DEBUG));
 }
#endif

int
loglevel(server)
    Apache::Server	server

    CODE:
    RETVAL = server->loglevel;

    OUTPUT:
    RETVAL
