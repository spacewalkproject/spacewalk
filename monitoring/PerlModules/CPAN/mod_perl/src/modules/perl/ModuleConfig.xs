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

#define CORE_PRIVATE
#include "mod_perl.h"

#define MP_TYPE_DIR 1
#define MP_TYPE_SRV 2

static void *vector_from_sv (SV *sv, int *type)
{

    if(sv_derived_from(sv, "Apache") && SvROK(sv)) {
	request_rec *r = sv2request_rec(sv, "Apache", Nullcv);
	*type = MP_TYPE_DIR;
	return r->per_dir_config;
    }
    else if(sv_derived_from(sv, "Apache::Server") && SvROK(sv)) {
	server_rec *s = (server_rec *) SvIV((SV*)SvRV(sv));
	*type = MP_TYPE_SRV;
	return s->module_config;
    }
    else {
	croak("Argument is not an Apache or Apache::Server object");
    }
}

MODULE = Apache::ModuleConfig  PACKAGE = Apache::ModuleConfig

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

SV *
get(self=Nullsv, obj, svkey=Nullsv)
    SV *self
    SV *obj
    SV *svkey

    PREINIT:
    SV *caller = Nullsv;

    CODE:
    RETVAL = Nullsv;
    if(svkey && (gv_stashpv(SvPV(svkey,na), FALSE)))
        caller = svkey;

    if((svkey == Nullsv) || caller) {
	module *mod = NULL;

	if(!caller)
	    caller = perl_eval_pv("scalar caller", TRUE);

	if(caller) 
	    mod = perl_get_module_ptr(SvPVX(caller), SvCUR(caller));

	if(mod) {
	    int type = 0;
	    void *ptr = vector_from_sv(obj, &type);
	    mod_perl_perl_dir_config *data = 
		get_module_config(ptr, mod);
	    if(data && data->obj) {
		++SvREFCNT(data->obj);
		RETVAL = data->obj;
	    }
	    else
		RETVAL = Nullsv;
	}
    }
    if(!RETVAL) XSRETURN_UNDEF;

    OUTPUT:
    RETVAL

MODULE = Apache::ModuleConfig  PACKAGE = Apache::CmdParms

char *
info(parms)
    Apache::CmdParms parms

    CODE:
    RETVAL = ((mod_perl_cmd_info *)parms->info)->info;

    OUTPUT:
    RETVAL

int
GETC(parms)
    Apache::CmdParms parms

    CODE:
#if MODULE_MAGIC_NUMBER >= 19980413
    RETVAL = cfg_getc(cmd_infile);
#else
    croak("httpd too old for getc");
#endif
    OUTPUT:
    RETVAL

SV *
getline(parms, buff=Nullsv, len=MAX_STRING_LEN)
    Apache::CmdParms parms
    SV *buff
    int len

    ALIAS:
    Apache::CmdParms::READ = 1
    Apache::CmdParms::READLINE = 2

    PREINIT:
    char *l;
    int ret = 0;

    CODE:				   
    RETVAL = newSV(0);
    l = (char *)palloc(parms->temp_pool, len);
    ret = !cfg_getline(l, len, cmd_infile);
    if(!buff) buff = sv_newmortal();

    switch((ix = XSANY.any_i32)) {
	case 0:
	sv_setiv(RETVAL, ret);
	sv_setpv(buff, l);
	break;

	case 1:
	sv_setiv(RETVAL, SvCUR(buff));
	sv_setpv(buff, l);
	break;

	case 2:
	sv_setpv(RETVAL, l);
	break;
    }

    OUTPUT:
    buff
    RETVAL				   

char *
path(parms)
    Apache::CmdParms parms

    CODE:				   
    if(!(RETVAL = parms->path)) XSRETURN_UNDEF;

    OUTPUT:
    RETVAL

Apache::Server
server(parms)
    Apache::CmdParms parms

    CODE:				   
    RETVAL = parms->server;

    OUTPUT:
    RETVAL

Apache::Command
cmd(parms)
    Apache::CmdParms parms

    CODE:				   
    RETVAL = (Apache__Command)parms->cmd;

    OUTPUT:
    RETVAL

int
override(parms)
    Apache::CmdParms parms

    CODE:				   
    RETVAL = parms->override;

    OUTPUT:
    RETVAL

int
limited(parms)
    Apache::CmdParms parms

    CODE:				   
    RETVAL = parms->limited;

    OUTPUT:
    RETVAL
