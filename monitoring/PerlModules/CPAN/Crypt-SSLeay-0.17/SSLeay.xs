/*
 * $Id: SSLeay.xs,v 1.1 2000-10-14 01:30:56 dfaraldo Exp $
 * Copyright 1998 Gisle Aas.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* ssl.h or openssl/ssl.h is included from the crypt_ssleay_version
 * file which is written when building with perl Makefile.PL
 * #include "ssl.h"
 */
#include "crypt_ssleay_version.h"

#undef Free /* undo namespace pollution from crypto.h */
#ifdef __cplusplus
}
#endif


#define DEBUG_SSL_STATE                0

#if SSLEAY_VERSION_NUMBER >= 0x0800
#define SSLEAY8
#endif

/* moved this out to Makefile.PL so user can 
 * see value being used printed during build
 * #if SSLEAY_VERSION_NUMBER >= 0x0900
 * #define CRYPT_SSL_CLIENT_METHOD SSLv3_client_method()
 * #else
 * #define CRYPT_SSL_CLIENT_METHOD SSLv2_client_method()
 * #endif
 */


#if DEBUG_SSL_STATE

static void InfoCallback(SSL *s,int where,int ret)
    {
    char *str;
    int w;

    w=where&~SSL_ST_MASK;

    if(w & SSL_ST_CONNECT)
       str="SSL_connect";
    else if(w & SSL_ST_ACCEPT)
       str="SSL_accept";
    else
       str="undefined";

    if(where & SSL_CB_LOOP)
       fprintf(stderr,"%s:%s\n",str,SSL_state_string_long(s));
    else if(where & SSL_CB_ALERT)
       {
       str=(where & SSL_CB_READ)?"read":"write";
       fprintf(stderr,"SSL3 alert %s:%s:%s\n",str,
               SSL_alert_type_string_long(ret),
               SSL_alert_desc_string_long(ret));
       }
    else if(where & SSL_CB_EXIT)
       {
       if(ret == 0)
         fprintf(stderr,"%s:failed in %s\n",str,SSL_state_string_long(s));
       else if (ret < 0)
         fprintf(stderr,"%s:error in %s\n",str,SSL_state_string_long(s));
       }
    }
#endif /* DEBUG_SSL_STATE */

MODULE = Crypt::SSLeay		PACKAGE = Crypt::SSLeay

PROTOTYPES: DISABLE

MODULE = Crypt::SSLeay         PACKAGE = Crypt::SSLeay::Err PREFIX = ERR_

char*
ERR_get_error_string()
  CODE:
    unsigned long l;
    char buf[1024];

    if(!(l=ERR_get_error()))
       RETVAL=NULL;
    else
       {
       ERR_error_string(l,buf);
       RETVAL=buf;
       }
  OUTPUT:
    RETVAL

MODULE = Crypt::SSLeay		PACKAGE = Crypt::SSLeay::CTX	PREFIX = SSL_CTX_

SSL_CTX*
SSL_CTX_new(packname, ssl_version)
     SV* packname
     int ssl_version
     CODE:
#ifdef SSLEAY8
	SSL_CTX* ctx;
	static int bNotFirstTime;
	char buf[1024];

	if(!bNotFirstTime) {
               SSLeay_add_all_algorithms();
               SSL_load_error_strings();
               ERR_load_crypto_strings();
	       bNotFirstTime = 1;
        }
        RAND_seed(buf,sizeof buf);

	if(ssl_version == 23) {
		ctx = SSL_CTX_new(SSLv23_client_method());
	} else if(ssl_version == 3) {
		ctx = SSL_CTX_new(SSLv3_client_method());
	} else {
		/* v2 is the default */
		ctx = SSL_CTX_new(SSLv2_client_method());
	}		
	SSL_CTX_set_options(ctx,SSL_OP_ALL|0);
	RETVAL = ctx;
#else
	RETVAL = SSL_CTX_new();
#endif

     OUTPUT:
	RETVAL

void
SSL_CTX_free(ctx)
     SSL_CTX* ctx

int
SSL_CTX_set_cipher_list(ctx, ciphers)
     SSL_CTX* ctx
     char* ciphers

MODULE = Crypt::SSLeay		PACKAGE = Crypt::SSLeay::Conn	PREFIX = SSL_

SSL*
SSL_new(packname, ctx, ...)
	SV* packname
	SSL_CTX* ctx
	CODE:
	   RETVAL = SSL_new(ctx);
#if DEBUG_SSL_STATE
           SSL_set_info_callback(RETVAL,InfoCallback);
#endif	   
	   if (items > 2) {
	       PerlIO* io = IoIFP(sv_2io(ST(2)));
#ifdef _WIN32
	       SSL_set_fd(RETVAL, _get_osfhandle(PerlIO_fileno(io)));
#else
	       SSL_set_fd(RETVAL, PerlIO_fileno(io));
#endif
           }
	OUTPUT:
	   RETVAL


void
SSL_free(ssl)
	SSL* ssl

int
SSL_set_fd(ssl,fd)
	SSL* ssl
	int  fd

int
SSL_connect(ssl)
	SSL* ssl

int
SSL_accept(ssl)
	SSL* ssl

SV*
SSL_write(ssl, buf, ...)
	SSL* ssl
	PREINIT:
	   STRLEN blen;
	   int len;
	   int offset = 0;
	   int n;
	INPUT:
	   char* buf = SvPV(ST(1), blen);
	CODE:
	   if (items > 2) {
	       len = SvOK(ST(2)) ? SvIV(ST(2)) : blen;
	       if (items > 3) {
	           offset = SvIV(ST(3));
	           if (offset < 0) {
		       if (-offset > blen)
			   croak("Offset outside string");
		       offset += blen;
		   } else if (offset >= blen && blen > 0)
		       croak("Offset outside string");
               }
	       if (len > blen - offset)
		   len = blen - offset;
	   } else {
	       len = blen;
           }
	   n = SSL_write(ssl, buf+offset, len);
	   if (n >= 0) {
	       RETVAL = newSViv(n);
	   } else {
	       RETVAL = &PL_sv_undef;
           }
	OUTPUT:
	   RETVAL
	

SV*
SSL_read(ssl, buf, len,...)
	SSL* ssl
	int len
	PREINIT:
	   char *buf;
	   STRLEN blen;
	   int offset = 0;
	   int n;
	INPUT:
	   SV* sv = ST(1);
	CODE:
	   buf = SvPV_force(sv, blen);
	   if (items > 3) {
	       offset = SvIV(ST(3));
	       if (offset < 0) {
		   if (-offset > blen)
		       croak("Offset outside string");
		   offset += blen;
	       }
	       /* this is not a very efficient method of appending
                * (offset - blen) NUL bytes, but it will probably
                * seldom happen.
                */
	       while (offset > blen) {
		   sv_catpvn(sv, "\0", 1);
	           blen++;
               }
	   }
           if (len < 0)
	       croak("Negative length");
	
	   SvGROW(sv, offset + len + 1);
	   buf = SvPVX(sv);  /* it might have been relocated */

	   n = SSL_read(ssl, buf+offset, len);

	   if (n >= 0) {
               SvCUR_set(sv, offset + n);
               buf[offset + n] = '\0';
	       RETVAL = newSViv(n);
	   } else {
	       RETVAL = &PL_sv_undef;
           }

	OUTPUT:
	   RETVAL

X509*
SSL_get_peer_certificate(ssl)
	SSL* ssl

char*
SSL_get_shared_ciphers(ssl)
	SSL* ssl
	PREINIT:
	   char buf[512];
	CODE:
	   RETVAL = SSL_get_shared_ciphers(ssl, buf, sizeof(buf));
	OUTPUT:
	   RETVAL

char*
SSL_get_cipher(ssl)
	SSL* ssl
	CODE:
	   RETVAL = (char*) SSL_get_cipher(ssl);
	OUTPUT:
	   RETVAL	

MODULE = Crypt::SSLeay		PACKAGE = Crypt::SSLeay::X509	PREFIX = X509_

SV*
subject_name(cert)
	X509* cert
	PREINIT:
	   char* str;
	CODE:
#ifdef SSLEAY8
	   str = X509_NAME_oneline(X509_get_subject_name(cert), NULL, 0);
#else
	   str = X509_NAME_oneline(X509_get_subject_name(cert));
#endif
	   RETVAL = newSVpv(str, 0);
	   free(str);
	OUTPUT:
	   RETVAL

SV*
issuer_name(cert)
	X509* cert
	PREINIT:
	   char* str;
	CODE:
#ifdef SSLEAY8
	   str = X509_NAME_oneline(X509_get_issuer_name(cert), NULL, 0);
#else
	   str = X509_NAME_oneline(X509_get_issuer_name(cert));
#endif
	   RETVAL = newSVpv(str, 0);
	   free(str);
	OUTPUT:
	   RETVAL
