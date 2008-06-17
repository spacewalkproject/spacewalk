#define CORE_PRIVATE
#include "mod_perl.h"

#ifndef SERVER_BUILT
#define SERVER_BUILT "unknown"
#endif

#ifndef MOD_PERL_STRING_VERSION
#define MOD_PERL_STRING_VERSION "mod_perl/x.xx"
#endif

#ifdef XS_IMPORT
#include "Exports.c"

static void export_cv(SV *pclass, SV *caller, char *sub)
{
    GV *gv;
#if 0
    fprintf(stderr, "*%s::%s = \\&%s::%s\n",
	    SvPVX(caller), sub, SvPVX(pclass), sub);
#endif
    gv = gv_fetchpv(form("%_::%s", caller, sub), TRUE, SVt_PVCV);
    GvCV(gv) = perl_get_cv(form("%_::%s", pclass, sub), TRUE);
    GvIMPORTED_CV_on(gv);
}

static void my_import(SV *pclass, SV *caller, SV *sv)
{
    char *sym = SvPV(sv,na), **tags;
    int i;

    switch (*sym) {
    case ':':
	++sym;
	tags = export_tags(sym);
	for(i=0; tags[i]; i++) {
	    export_cv(pclass, caller, tags[i]);
	}
	break;
    case '$':
    case '%':
    case '*':
    case '@':
	croak("\"%s\" is not exported by the Apache::Constants module", sym);
    case '&':
	++sym;
    default:
	if(isALPHA(sym[0])) {
	    export_cv(pclass, caller, sym);
	    break;
	}
	else {
	    croak("Can't export symbol: %s", sym);
	}
    }
}
#endif /*XS_IMPORT*/

/* prevent prototype mismatch warnings */

static void check_proto(HV *stash, char *name)
{
    GV **gvp = (GV**)hv_fetch(stash, name, strlen(name), FALSE);
    CV *cv;

    if (!(gvp && *gvp && (cv = GvCVu(*gvp)))) {
	return;
    }
    if (CvROOT(cv)) {
	return;
    }
    if (!SvPOK(cv)) {
	sv_setsv((SV*)cv, &sv_no);
    }
}

#ifdef newCONSTSUB

#define my_newCONSTSUB(stash, name, sv) \
    check_proto(stash, name); \
    newCONSTSUB(stash, name, sv)

#else   

static void my_newCONSTSUB(HV *stash, char *name, SV *sv)
{
#ifdef dTHR
    dTHR;
#endif
    I32 oldhints = hints;
    HV *old_cop_stash = curcop->cop_stash;
    HV *old_curstash = curstash;
    line_t oldline = curcop->cop_line;

    hints &= ~HINT_BLOCK_SCOPE;

    if(stash) {
	save_hptr(&curstash);
	save_hptr(&curcop->cop_stash);
	curstash = curcop->cop_stash = stash;
    }

    check_proto(stash, name);

    (void)newSUB(start_subparse(FALSE, 0),
	   newSVOP(OP_CONST, 0, newSVpv(name,0)),
	   newSVOP(OP_CONST, 0, &sv_no),	
	   newSTATEOP(0, Nullch, newSVOP(OP_CONST, 0, sv)));

    hints = oldhints;
    curcop->cop_stash = old_cop_stash;
    curstash = old_curstash;
    curcop->cop_line = oldline;
}

#endif

static enum cmd_how autoload_args_how(char *name) {
    if (strEQ(name, "FLAG"))
	return FLAG;

    if (strEQ(name, "ITERATE"))
	return ITERATE;

    if (strEQ(name, "ITERATE2"))
	return ITERATE2;

    if (strEQ(name, "NO_ARGS"))
	return NO_ARGS;

    if (strEQ(name, "RAW_ARGS"))
	return RAW_ARGS;

    if (strEQ(name, "TAKE1"))
	return TAKE1;

    if (strEQ(name, "TAKE12"))
	return TAKE12;

    if (strEQ(name, "TAKE123"))
	return TAKE123;

    if (strEQ(name, "TAKE2"))
	return TAKE2;

    if (strEQ(name, "TAKE23"))
	return TAKE23;

    if (strEQ(name, "TAKE3"))
	return TAKE3;
    
    return (enum cmd_how) -1;
}

static double
constant(char *name)
{
    errno = 0;
    switch (*name) {
    case 'A':
	if (strEQ(name, "AUTH_REQUIRED"))
#ifdef AUTH_REQUIRED
	    return AUTH_REQUIRED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ACCESS_CONF"))
#ifdef ACCESS_CONF
	    return ACCESS_CONF;
#else
	    goto not_there;
#endif
	break;
    case 'B':
	if (strEQ(name, "BAD_GATEWAY"))
#ifdef BAD_GATEWAY
	    return BAD_GATEWAY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "BAD_REQUEST"))
#ifdef BAD_REQUEST
	    return BAD_REQUEST;
#else
	    goto not_there;
#endif
	break;
    case 'C':
if (strEQ(name, "CONTINUE"))
    return DECLINED;
	break;
    case 'D':
	if (strEQ(name, "DECLINED"))
#ifdef DECLINED
	    return DECLINED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "DOCUMENT_FOLLOWS"))
#ifdef DOCUMENT_FOLLOWS
	    return DOCUMENT_FOLLOWS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "DONE"))
#ifdef DONE
	    return DONE;
#else
            return -2;
#endif
	if (strEQ(name, "DYNAMIC_MODULE_LIMIT"))
#ifdef DYNAMIC_MODULE_LIMIT
	    return DYNAMIC_MODULE_LIMIT;
#else
	    goto not_there;
#endif
	break;
    case 'E':
	break;
    case 'F':
	if (strEQ(name, "FORBIDDEN"))
#ifdef FORBIDDEN
	    return FORBIDDEN;
#else
	    goto not_there;
#endif
	break;
    case 'G':
	break;
    case 'H':
       if (strEQ(name, "HTTP_ACCEPTED"))
#ifdef HTTP_ACCEPTED
           return HTTP_ACCEPTED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_BAD_GATEWAY"))
#ifdef HTTP_BAD_GATEWAY
           return HTTP_BAD_GATEWAY;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_BAD_REQUEST"))
#ifdef HTTP_BAD_REQUEST
           return HTTP_BAD_REQUEST;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_CONFLICT"))
#ifdef HTTP_CONFLICT
           return HTTP_CONFLICT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_CONTINUE"))
#ifdef HTTP_CONTINUE
           return HTTP_CONTINUE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_CREATED"))
#ifdef HTTP_CREATED
           return HTTP_CREATED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_FORBIDDEN"))
#ifdef HTTP_FORBIDDEN
           return HTTP_FORBIDDEN;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_GATEWAY_TIME_OUT"))
#ifdef HTTP_GATEWAY_TIME_OUT
           return HTTP_GATEWAY_TIME_OUT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_GONE"))
#ifdef HTTP_GONE
           return HTTP_GONE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_INTERNAL_SERVER_ERROR"))
#ifdef HTTP_INTERNAL_SERVER_ERROR
           return HTTP_INTERNAL_SERVER_ERROR;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_LENGTH_REQUIRED"))
#ifdef HTTP_LENGTH_REQUIRED
           return HTTP_LENGTH_REQUIRED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_METHOD_NOT_ALLOWED"))
#ifdef HTTP_METHOD_NOT_ALLOWED
           return HTTP_METHOD_NOT_ALLOWED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_MOVED_PERMANENTLY"))
#ifdef HTTP_MOVED_PERMANENTLY
           return HTTP_MOVED_PERMANENTLY;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_MOVED_TEMPORARILY"))
#ifdef HTTP_MOVED_TEMPORARILY
           return HTTP_MOVED_TEMPORARILY;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_MULTIPLE_CHOICES"))
#ifdef HTTP_MULTIPLE_CHOICES
           return HTTP_MULTIPLE_CHOICES;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NON_AUTHORITATIVE"))
#ifdef HTTP_NON_AUTHORITATIVE
           return HTTP_NON_AUTHORITATIVE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NOT_ACCEPTABLE"))
#ifdef HTTP_NOT_ACCEPTABLE
           return HTTP_NOT_ACCEPTABLE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NOT_FOUND"))
#ifdef HTTP_NOT_FOUND
           return HTTP_NOT_FOUND;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NOT_IMPLEMENTED"))
#ifdef HTTP_NOT_IMPLEMENTED
           return HTTP_NOT_IMPLEMENTED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NOT_MODIFIED"))
#ifdef HTTP_NOT_MODIFIED
           return HTTP_NOT_MODIFIED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_NO_CONTENT"))
#ifdef HTTP_NO_CONTENT
           return HTTP_NO_CONTENT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_OK"))
#ifdef HTTP_OK
           return HTTP_OK;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_PARTIAL_CONTENT"))
#ifdef HTTP_PARTIAL_CONTENT
           return HTTP_PARTIAL_CONTENT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_PAYMENT_REQUIRED"))
#ifdef HTTP_PAYMENT_REQUIRED
           return HTTP_PAYMENT_REQUIRED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_PRECONDITION_FAILED"))
#ifdef HTTP_PRECONDITION_FAILED
           return HTTP_PRECONDITION_FAILED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_PROXY_AUTHENTICATION_REQUIRED"))
#ifdef HTTP_PROXY_AUTHENTICATION_REQUIRED
           return HTTP_PROXY_AUTHENTICATION_REQUIRED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_REQUEST_ENTITY_TOO_LARGE"))
#ifdef HTTP_REQUEST_ENTITY_TOO_LARGE
           return HTTP_REQUEST_ENTITY_TOO_LARGE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_REQUEST_TIME_OUT"))
#ifdef HTTP_REQUEST_TIME_OUT
           return HTTP_REQUEST_TIME_OUT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_REQUEST_URI_TOO_LARGE"))
#ifdef HTTP_REQUEST_URI_TOO_LARGE
           return HTTP_REQUEST_URI_TOO_LARGE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_RESET_CONTENT"))
#ifdef HTTP_RESET_CONTENT
           return HTTP_RESET_CONTENT;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_SEE_OTHER"))
#ifdef HTTP_SEE_OTHER
           return HTTP_SEE_OTHER;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_SERVICE_UNAVAILABLE"))
#ifdef HTTP_SERVICE_UNAVAILABLE
           return HTTP_SERVICE_UNAVAILABLE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_SWITCHING_PROTOCOLS"))
#ifdef HTTP_SWITCHING_PROTOCOLS
           return HTTP_SWITCHING_PROTOCOLS;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_UNAUTHORIZED"))
#ifdef HTTP_UNAUTHORIZED
           return HTTP_UNAUTHORIZED;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_UNSUPPORTED_MEDIA_TYPE"))
#ifdef HTTP_UNSUPPORTED_MEDIA_TYPE
           return HTTP_UNSUPPORTED_MEDIA_TYPE;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_USE_PROXY"))
#ifdef HTTP_USE_PROXY
           return HTTP_USE_PROXY;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_VARIANT_ALSO_VARIES"))
#ifdef HTTP_VARIANT_ALSO_VARIES
           return HTTP_VARIANT_ALSO_VARIES;
#else
           goto not_there;
#endif
       if (strEQ(name, "HTTP_VERSION_NOT_SUPPORTED"))
#ifdef HTTP_VERSION_NOT_SUPPORTED
           return HTTP_VERSION_NOT_SUPPORTED;
#else
           goto not_there;
#endif
	if (strEQ(name, "HUGE_STRING_LEN"))
#ifdef HUGE_STRING_LEN
	    return HUGE_STRING_LEN;
#else
	    goto not_there;
#endif
	break;
    case 'I':
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	if (strEQ(name, "MAX_HEADERS"))
#ifdef MAX_HEADERS
	    return MAX_HEADERS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_STRING_LEN"))
#ifdef MAX_STRING_LEN
	    return MAX_STRING_LEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "METHODS"))
#ifdef METHODS
	    return METHODS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MOVED"))
#ifdef MOVED
	    return MOVED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_CONNECT"))
#ifdef M_CONNECT
	    return M_CONNECT;
#else
	    goto not_there;
#endif
        if (strEQ(name, "MODULE_MAGIC_NUMBER"))
#ifdef MODULE_MAGIC_NUMBER
            return MODULE_MAGIC_NUMBER;
#else
            goto not_there;
#endif
	if (strEQ(name, "M_DELETE"))
#ifdef M_DELETE
	    return M_DELETE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_GET"))
#ifdef M_GET
	    return M_GET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_INVALID"))
#ifdef M_INVALID
	    return M_INVALID;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_OPTIONS"))
#ifdef M_OPTIONS
	    return M_OPTIONS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_POST"))
#ifdef M_POST
	    return M_POST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_PUT"))
#ifdef M_PUT
	    return M_PUT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "M_TRACE"))
#ifdef M_TRACE
	    return M_TRACE;
#else
	    goto not_there;
#endif
        if (strEQ(name, "M_PATCH"))
#ifdef M_PATCH
            return M_PATCH;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_PROPFIND"))
#ifdef M_PROPFIND
            return M_PROPFIND;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_PROPPATCH"))
#ifdef M_PROPPATCH
            return M_PROPPATCH;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_MKCOL"))
#ifdef M_MKCOL
            return M_MKCOL;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_COPY"))
#ifdef M_COPY
            return M_COPY;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_MOVE"))
#ifdef M_MOVE
            return M_MOVE;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_LOCK"))
#ifdef M_LOCK
            return M_LOCK;
#else
            goto not_there;
#endif
        if (strEQ(name, "M_UNLOCK"))
#ifdef M_UNLOCK
            return M_UNLOCK;
#else
            goto not_there;
#endif
	break;
    case 'N':
	if (strEQ(name, "NOT_AUTHORITATIVE"))
#ifdef NOT_AUTHORITATIVE
	    return NOT_AUTHORITATIVE;
#else
	    return DECLINED; 
#endif
	if (strEQ(name, "NOT_FOUND"))
#ifdef NOT_FOUND
	    return NOT_FOUND;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NOT_IMPLEMENTED"))
#ifdef NOT_IMPLEMENTED
	    return NOT_IMPLEMENTED;
#else
	    goto not_there;
#endif
	break;
    case 'O':
	if (strEQ(name, "OK"))
#ifdef OK
	    return OK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_ALL"))
#ifdef OPT_ALL
	    return OPT_ALL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_EXECCGI"))
#ifdef OPT_EXECCGI
	    return OPT_EXECCGI;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_INCLUDES"))
#ifdef OPT_INCLUDES
	    return OPT_INCLUDES;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_INCNOEXEC"))
#ifdef OPT_INCNOEXEC
	    return OPT_INCNOEXEC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_INDEXES"))
#ifdef OPT_INDEXES
	    return OPT_INDEXES;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_MULTI"))
#ifdef OPT_MULTI
	    return OPT_MULTI;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_NONE"))
#ifdef OPT_NONE
	    return OPT_NONE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_SYM_LINKS"))
#ifdef OPT_SYM_LINKS
	    return OPT_SYM_LINKS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_SYM_OWNER"))
#ifdef OPT_SYM_OWNER
	    return OPT_SYM_OWNER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OPT_UNSET"))
#ifdef OPT_UNSET
	    return OPT_UNSET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_NONE"))
#ifdef OR_NONE
	    return OR_NONE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_LIMIT"))
#ifdef OR_LIMIT
	    return OR_LIMIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_OPTIONS"))
#ifdef OR_OPTIONS
	    return OR_OPTIONS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_FILEINFO"))
#ifdef OR_FILEINFO
	    return OR_FILEINFO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_AUTHCFG"))
#ifdef OR_AUTHCFG
	    return OR_AUTHCFG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_INDEXES"))
#ifdef OR_INDEXES
	    return OR_INDEXES;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_UNSET"))
#ifdef OR_UNSET
	    return OR_UNSET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OR_ALL"))
#ifdef OR_ALL
	    return OR_ALL;
#else
	    goto not_there;
#endif
	break;
    case 'P':
	break;
    case 'Q':
	break;
    case 'R':
	if (strEQ(name, "REDIRECT"))
#ifdef REDIRECT
	    return REDIRECT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RSRC_CONF"))
#ifdef RSRC_CONF
	    return RSRC_CONF;
#else
	    goto not_there;
#endif
        if (strEQ(name, "REMOTE_HOST"))
#ifdef REMOTE_HOST
            return REMOTE_HOST;
#else
            goto not_there;
#endif   
        if (strEQ(name, "REMOTE_NAME"))
#ifdef REMOTE_NAME
            return REMOTE_NAME;
#else
            goto not_there;
#endif   
        if (strEQ(name, "REMOTE_NOLOOKUP"))
#ifdef REMOTE_NOLOOKUP
            return REMOTE_NOLOOKUP;
#else
            goto not_there;
#endif   
        if (strEQ(name, "REMOTE_DOUBLE_REV"))
#ifdef REMOTE_DOUBLE_REV
            return REMOTE_DOUBLE_REV;
#else
            goto not_there;
#endif   
   
	if (strEQ(name, "REQUEST_NO_BODY"))
#ifdef REQUEST_NO_BODY
	    return REQUEST_NO_BODY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "REQUEST_CHUNKED_ERROR"))
#ifdef REQUEST_CHUNKED_ERROR
	    return REQUEST_CHUNKED_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "REQUEST_CHUNKED_DECHUNK"))
#ifdef REQUEST_CHUNKED_DECHUNK
	    return REQUEST_CHUNKED_DECHUNK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "REQUEST_CHUNKED_PASS"))
#ifdef REQUEST_CHUNKED_PASS
	    return REQUEST_CHUNKED_PASS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RESPONSE_CODES"))
#ifdef RESPONSE_CODES
	    return RESPONSE_CODES;
#else
	    goto not_there;
#endif
	break;
    case 'S':
	if (strEQ(name, "SATISFY_ALL"))
#ifdef SATISFY_ALL
	    return SATISFY_ALL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SATISFY_ANY"))
#ifdef SATISFY_ANY
	    return SATISFY_ANY;
#else
	    goto not_there;
#endif
       if(strEQ(name, "SATISFY_NOSPEC"))
#ifdef SATISFY_NOSPEC
   	    return SATISFY_NOSPEC;
#else
	    goto not_there;
#endif

	if (strEQ(name, "SERVER_ERROR"))
#ifdef SERVER_ERROR
	    return SERVER_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SERVICE_UNAVAILABLE"))
#ifdef SERVICE_UNAVAILABLE
	    return SERVICE_UNAVAILABLE;
#else
	    goto not_there;
#endif
    case 'T':
	break;
    case 'U':
	if (strEQ(name, "USE_LOCAL_COPY"))
#ifdef USE_LOCAL_COPY
	    return USE_LOCAL_COPY;
#else
	    goto not_there;
#endif
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    default:
    errno = EINVAL;
    return 0;
    }

not_there:
    {
	enum cmd_how args_how = autoload_args_how(name);
	if(((int)args_how) > -1) 
	    return (double)args_how;
    }

    errno = ENOENT;
    return 0;
}

#define __PACKAGE__ "Apache::Constants"
#define __PACKAGE_LEN__ 17
#define __AUTOLOAD__ "Apache::Constants::AUTOLOAD"

/* this is kinda ugly, but wtf */
static void boot_ConstSubs(char *tag) 
{
    dTHR;
    HV *stash = gv_stashpvn(__PACKAGE__, __PACKAGE_LEN__, FALSE);
    I32 i;
#ifdef XS_IMPORT
    char **export = export_tags(tag);

    for (i=0; export[i]; i++) {
#define EXP_NAME export[i]

#else
    HV *exp_tags = perl_get_hv("Apache::Constants::EXPORT_TAGS", TRUE); 
    SV **avrv = hv_fetch(exp_tags, tag, strlen(tag), FALSE);
    AV *export;
    if(avrv)
	export = (AV*)SvRV(*avrv);
    else 
	return;
#define EXP_NAME SvPV(*av_fetch(export, i, 0),na)

    for(i=0; i<=AvFILL(export); i++) { 
#endif
	char *name = EXP_NAME;
	double val = constant(name);
	my_newCONSTSUB(stash, name, newSViv(val));
    }
}

MODULE = Apache::Constants PACKAGE = Apache::Constants
 
PROTOTYPES: DISABLE

BOOT:
    items = items;
#ifndef XS_IMPORT
    perl_require_module("Apache::Constants::Exports", NULL);
#endif
    boot_ConstSubs("common");

#ifdef XS_IMPORT

void
import(pclass, ...)
    SV *pclass

    PREINIT:
    I32 i = 0;
    SV *caller = perl_eval_pv("scalar caller", TRUE);

    CODE:
    for(i=1; i<items; i++) {
	my_import(pclass, caller, ST(i));
    }

#endif

void
__AUTOLOAD()

    PREINIT:
    HV *stash = gv_stashpvn(__PACKAGE__, __PACKAGE_LEN__, FALSE);
    SV *sv = GvSV(gv_fetchpv(__AUTOLOAD__, TRUE, SVt_PV));
    char *name = SvPV(sv,na);
    int len = __PACKAGE_LEN__+2;
    double val;

    CODE:
    while(len--) ++name;

    val = constant(name);
    if(errno != 0) 
	croak("Your vendor has not defined Apache::Constants macro `%s'", name);
    else 
        my_newCONSTSUB(stash, name, newSViv(val));

const char *
SERVER_VERSION()
   CODE: 
#if MODULE_MAGIC_NUMBER >= 19980413
   RETVAL = ap_get_server_version();
#else
   RETVAL = SERVER_VERSION;
#endif
   OUTPUT:
   RETVAL

char *
SERVER_BUILT()
   CODE: 
#if MODULE_MAGIC_NUMBER >= 19980413
   RETVAL = (char *)ap_get_server_built();
#else
   RETVAL = SERVER_BUILT;
#endif

   OUTPUT:
   RETVAL

char *
DECLINE_CMD()
   CODE:
#ifdef DECLINE_CMD
    RETVAL = DECLINE_CMD;
#else
    RETVAL = "\a\b";
#endif
   OUTPUT:
   RETVAL

char *
DIR_MAGIC_TYPE()

    CODE:
    RETVAL = DIR_MAGIC_TYPE;

    OUTPUT:
    RETVAL
