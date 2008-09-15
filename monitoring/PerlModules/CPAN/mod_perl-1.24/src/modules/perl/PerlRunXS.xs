/* ====================================================================
 * Copyright (c) 1995-1998 The Apache Group.  All rights reserved.
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
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by the Apache Group
 *    for use in the Apache HTTP server project (http://www.apache.org/)."
 *
 * 4. The names "Apache Server" and "Apache Group" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please contact
 *    apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * 6. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by the Apache Group
 *    for use in the Apache HTTP server project (http://www.apache.org/)."
 *
 * THIS SOFTWARE IS PROVIDED BY THE APACHE GROUP ``AS IS'' AND ANY
 * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE APACHE GROUP OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Group and was originally based
 * on public domain software written at the National Center for
 * Supercomputing Applications, University of Illinois, Urbana-Champaign.
 * For more information on the Apache Group and the Apache HTTP server
 * project, please see <http://www.apache.org/>.
 *
 */

#include "mod_perl.h"

static const char c2x_table[] = "0123456789abcdef";

static unsigned char *c2x(unsigned what, unsigned char *where)
{
    *where++ = '_';
    *where++ = c2x_table[what >> 4];
    *where++ = c2x_table[what & 0xf];
    return where;
}

/*
 * s/([^A-Za-z0-9\/])/sprintf("_%2x",unpack("C",$1))/eg;
 */
static char *uri2perlish(char *segment, int slen) {
    register int x,y;
    char *copy = (char *)safemalloc(3 * slen + 1);

    for(x=0,y=0; segment[x]; x++,y++) {
	char c = segment[x];
	if((c < 'A' || c > 'Z') && (c < 'a' || c > 'z') && (c < '0' || c >'9')
	   && c != '/')
        {
	    c2x(c, &copy[y]);
	    y += 2;
        }
	else
	    copy[y] = c;
    }
    copy[y] = '\0';
    return copy;
}

/*
 * s{
 *   (/+)       # directory
 *   (\d?)      # package's first character
 *  }[
 *   "::" . ($2 ? sprintf("_%2x",unpack("C",$2)) : "")
 *   ]egx;
 */
static SV *slash2stash(const char *segment) {
    register int x,y;
    SV *sv = newSV(3 * strlen(segment));

    for(x=0,y=0; segment[x]; x++,y++) {
	char c=segment[x];
	if(c == '/') {
	    SvPVX(sv)[y] = ':';
	    SvPVX(sv)[++y] = ':';
	    if(isDIGIT(segment[x+1])) {
		char d = segment[++x];
		c2x(d, &SvPVX(sv)[++y]);
		y += 2;
	    }
        }
	else
	    SvPVX(sv)[y] = c;
    }
    SvPVX(sv)[y] = '\0';
    SvCUR_set(sv, y);
    SvPOK_on(sv);
    return sv;
}

#define ApachePerlRun_import_exit() \
    "use Apache 'exit';\n"

#define ApachePerlRun_chdir_scwd() \
    chdir(SvPV(perl_get_sv("Apache::Server::CWD", TRUE),na))

#ifndef ApachePerlRun_name_with_virtualhost
#define ApachePerlRun_name_with_virtualhost() \
    perl_get_sv("Apache::Registry::NameWithVirtualHost", FALSE)
#endif

SV *ApachePerlRun_namespace(request_rec *r, char *root)
{
    char *copy, *uri;
    int uri_len;
    SV *esc, *RETVAL;

    uri = (char *)pstrdup(r->pool, r->uri);
    uri_len = strlen(uri);  
    if(r->path_info) {
	int n = strlen(r->path_info);
	int chop = (uri_len - n);
	uri[chop] = '\0';
    }
    if(r->server->is_virtual && ApachePerlRun_name_with_virtualhost()) {
	uri = pstrcat(r->pool, r->server->server_hostname, uri, NULL);
	uri_len += strlen(r->server->server_hostname);
    }
    copy = uri2perlish(uri, uri_len);
    RETVAL = newSVpv(root ? root : "Apache::ROOT",0);
    esc = slash2stash(copy);	
    sv_setsv(perl_get_sv("Apache::Registry::curstash", TRUE), esc);
    sv_catsv(RETVAL, esc);
    safefree(copy);
    SvREFCNT_dec(esc);
    return RETVAL;
}

#define log_scripterror(r, rc, msg) \
    aplog_error(APLOG_MARK, APLOG_NOERRNO|APLOG_ERR, r->server, \
		"%s: %s", msg, r->filename); \
    return rc

int ApachePerlRun_can_compile(request_rec *r)
{
    if (!(allow_options(r) & OPT_EXECCGI)) {
	log_scripterror(r, FORBIDDEN, 
			"Options ExecCGI is off in this directory");
    }
    if (r->finfo.st_mode == 0) {
	log_scripterror(r, NOT_FOUND,
			"script not found or unable to stat");
    }
    if (S_ISDIR(r->finfo.st_mode)) {
	return DECLINED;
    }
    if (!can_exec(&r->finfo)) {
	log_scripterror(r, FORBIDDEN,
			"file permissions deny server execution");
    }
    return OK;
}

void ApachePerlRun_compile(request_rec *r, SV *code_ref)
{
     SV *code;

     if(SvROK(code_ref))
	code = (SV*)SvRV(code_ref);
     else
        code = code_ref;

     perl_eval_sv(code, G_DISCARD|G_KEEPERR);
}

/*
 * {
 *   local $/ = undef;
 *   my $fh = gensym;
 *   open $fh, $r->filename;
 *   my $code = <$fh>;
 *   close $fh;
 *   return \$code;
 * }
 */

#define ApachePerlRun_readscript mod_perl_slurp_filename

SV *ApachePerlRun_parse_cmdline(request_rec *r, SV *code)
{
    char *pos = (char *)strstr(SvPVX(code), "\n"), *shebang;
    int plen = pos - SvPVX(code);
    SV *sv;

    if(!pos) return Nullsv;
    sv = newSVpv("",0);
    shebang = (char*)safemalloc(sizeof(char)+plen);
    strncpy(shebang, SvPVX(code), plen);  
    
    if(*shebang == '#') {
	if(strstr(shebang, "-w")) {
	    sv_catpv(sv, "BEGIN {$^W = 1;}; $^W = 1;\n");
	}
    }

    safefree(shebang);
    return sv;
}

int ApachePerlRun_error_check(request_rec *r)
{
    dTHR;
    if((perl_eval_ok(r->server) != 0) && !strnEQ(SvPVX(ERRSV), " at ", 4)) {
	hv_store(ERRHV, r->uri, strlen(r->uri), ERRSV, FALSE);
	sv_setpv(ERRSV, "");
	return SERVER_ERROR;
    }
    else
	return OK;
}

void ApachePerlRun_set_scriptname(request_rec *r)
{
    SV *script_name = perl_get_sv("0", TRUE);
    /*save_item(script_name);*/
    sv_setpv(script_name, r->filename);
}

int handler(request_rec *r)
{
    dTHR;
    int rc = ApachePerlRun_can_compile(r);
    SV *package, *code, *eval, *cmdline;
    if(rc != OK)
	return rc;

    ENTER;
    package = ApachePerlRun_namespace(r, NULL);
    SAVEFREESV(package);
    code = ApachePerlRun_readscript(r);
    SAVEFREESV(code);
    eval = newSV(0);
    SAVEFREESV(eval);
    if((cmdline = ApachePerlRun_parse_cmdline(r, (SV*)SvRV(code)))) {
	sv_catsv(eval, cmdline);
	SvREFCNT_dec(cmdline);
    }
    ApachePerlRun_set_scriptname(r);
    chdir_file(r->filename);

    SAVEI32(hints);
    hints = 0; 

    sv_setpvf(eval, "package %_;\n", package);
    sv_catpv(eval, ApachePerlRun_import_exit());
    sv_catpvf(eval, "#line 1 %s\n", r->filename);
    sv_catsv(eval, (SV*)SvRV(code));
    sv_catpvn(eval, "\n", 1);
    ApachePerlRun_compile(r, eval);

    /*flush the namespace*/
    hv_clear(gv_stashpv(SvPVX(package), TRUE));

    ApachePerlRun_chdir_scwd();
    LEAVE;
    return ApachePerlRun_error_check(r);
}

static int registry_handler(request_rec *r)
{
    dTHR;
    int rc = ApachePerlRun_can_compile(r);
    SV *code, *package;
    SV *rgy_cache_rv = perl_get_sv("Apache::Registry", TRUE);
    HV *rgy_cache, *pkg_ent = Nullhv;
    bool do_compile = FALSE;
    if(rc != OK)
	return rc;

    if(!SvTRUE(rgy_cache_rv))
	sv_setsv(rgy_cache_rv, newRV((SV*)newHV()));

    rgy_cache = (HV*)SvRV(rgy_cache_rv);

    ENTER;
    package = ApachePerlRun_namespace(r, NULL);
    SAVEFREESV(package);

    ApachePerlRun_set_scriptname(r);
    chdir_file(r->filename);
    
    SAVEI32(hints);
    hints = FALSE;
    SAVEI32(dowarn);
    dowarn = FALSE;

    chdir(SvPV(perl_get_sv("Apache::Server::CWD", TRUE),na));
    if(hv_exists(rgy_cache, SvPVX(package), SvCUR(package))) {
	SV **rv = hv_fetch(rgy_cache, SvPVX(package), SvCUR(package), FALSE);
	SV *mtime;
	pkg_ent = (HV*)SvRV(*rv);
	mtime = *hv_fetch(pkg_ent, "mtime", 5, FALSE);
	if(SvTRUE(mtime) && ((int)SvIV(mtime) <= r->finfo.st_mtime)) {
	    /*we have compiled this subroutine already, nothing left to do*/
	}
	else 
	    do_compile = TRUE;
    }
    else
	do_compile = TRUE;

    if(do_compile) {
	int i = 0;
	SV *eval = newSVpv("",0), *cmdline;
	code = ApachePerlRun_readscript(r);
	SAVEFREESV(code);

	if((cmdline = ApachePerlRun_parse_cmdline(r, (SV*)SvRV(code)))) {
	    sv_catsv(eval, cmdline);
	    SvREFCNT_dec(cmdline);
	}

	sv_catpvf(eval, "package %_;\n", package);
	sv_catpv(eval, ApachePerlRun_import_exit());
	sv_catpv(eval, "sub handler {\n");
	sv_catpvf(eval, "#line 1 %s\n", r->filename);
	sv_catsv(eval, (SV*)SvRV(code));
	sv_catpvn(eval, "\n}", 2);
	ApachePerlRun_compile(r, eval);
	perl_stash_rgy_endav(r->uri, 
			     perl_get_sv("Apache::Registry::curstash", TRUE));
	SvREFCNT_dec(eval);
	rc = ApachePerlRun_error_check(r); 
	if(rc != OK) {
	    LEAVE;
	    return rc;
	}
	mod_perl_clear_rgy_endav(r, package);
	while (!pkg_ent) {
	    SV **svp = hv_fetch(rgy_cache, 
				SvPVX(package), SvCUR(package), FALSE);
	    if(svp) {
		pkg_ent = (HV*)SvRV(*svp);
		break;
	    }
	    hv_store(rgy_cache, SvPVX(package), SvCUR(package), 
		     newRV((SV*)newHV()), FALSE);
	    if(++i > 10) {
		fprintf(stderr, "STUCK\n");
		break;
	    }
	}

	hv_store(pkg_ent, "mtime", 5, newSViv(r->finfo.st_mtime), FALSE);
    }

    {
	dSP;
	int count;
	SV *sub = newSVsv(package);
	sv_catpvn(sub, "::handler", 9);
	ENTER;SAVETMPS;PUSHMARK(sp);
	XPUSHs((SV*)perl_bless_request_rec(r)); 
	PUTBACK;
	count = perl_call_sv(sub, G_EVAL | G_SCALAR);
	SvREFCNT_dec(sub);
	FREETMPS;LEAVE;
    }

    ApachePerlRun_chdir_scwd();
    LEAVE;
    if((rc = ApachePerlRun_error_check(r)) != OK)
	return rc;

    return r->status;
}

MODULE = Apache::PerlRunXS PACKAGE = Apache::RegistryXS PREFIX = registry_

int
registry_handler(r)
    Apache r

MODULE = Apache::PerlRunXS PACKAGE = Apache::PerlRunXS PREFIX = ApachePerlRun_

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

int
handler(r)
    Apache r

SV *
ApachePerlRun_namespace(r, root="Apache::ROOT")
    Apache r
    char *root

void
ApachePerlRun_can_compile(r)
    Apache r

    PREINIT:
    int retval = OK;

    PPCODE:
    retval = ApachePerlRun_can_compile(r);
    XPUSHs(sv_2mortal(newSViv(retval)));
    if(GIMME == G_ARRAY) {
	XPUSHs(sv_2mortal(newSViv(r->finfo.st_mtime)));
    }

void
ApachePerlRun_compile(r, code_ref)
     Apache r
     SV *code_ref

SV *
ApachePerlRun_readscript(r)
    Apache r

int
ApachePerlRun_error_check(r)
    Apache r


