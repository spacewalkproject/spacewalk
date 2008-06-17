/*
 * $Id: SSLeay.xs,v 1.1.1.1 2004-04-16 22:10:16 rhnuser Exp $
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

/* build problem under openssl 0.9.6 and some builds of perl 5.8.x */
#ifndef PERL5
#define PERL5 1
#endif

/* ssl.h or openssl/ssl.h is included from the crypt_ssleay_version
 * file which is written when building with perl Makefile.PL
 * #include "ssl.h"
 */
#include "crypt_ssleay_version.h"

#undef Free /* undo namespace pollution from crypto.h */
#ifdef __cplusplus
}
#endif


/* moved this out to Makefile.PL so user can 
 * see value being used printed during build
 * #if SSLEAY_VERSION_NUMBER >= 0x0900
 * #define CRYPT_SSL_CLIENT_METHOD SSLv3_client_method()
 * #else
 * #define CRYPT_SSL_CLIENT_METHOD SSLv2_client_method()
 * #endif
 */


static void InfoCallback(SSL *s,int where,int ret)
    {
    char *str;
    int w;

    w = where & ~SSL_ST_MASK;

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
	SSL_CTX* ctx;
	static int bNotFirstTime;
	char buf[1024];
        int rand_bytes_read;

	if(!bNotFirstTime) {
               SSLeay_add_all_algorithms();
               SSL_load_error_strings();
               ERR_load_crypto_strings();
	       bNotFirstTime = 1;
        }

        /**** Code from Devin Heitmueller, 10/3/2002 ****/
        /**** Use /dev/urandom to seed if available  ****/
        rand_bytes_read = RAND_load_file("/dev/urandom", 1024);
        if (rand_bytes_read <= 0) {
		/* Couldn't read /dev/urandom, just seed off
		   of the stack variable (the old way) */
	        RAND_seed(buf,sizeof buf);
	}

	if(ssl_version == 23) {
		ctx = SSL_CTX_new(SSLv23_client_method());
	} else if(ssl_version == 3) {
		ctx = SSL_CTX_new(SSLv3_client_method());
	} else {
		/* v2 is the default */
		ctx = SSL_CTX_new(SSLv2_client_method());
	}		
	SSL_CTX_set_options(ctx,SSL_OP_ALL|0);

	SSL_CTX_set_default_verify_paths(ctx);
	SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL);

	RETVAL = ctx;

     OUTPUT:
	RETVAL

void
SSL_CTX_free(ctx)
     SSL_CTX* ctx

int
SSL_CTX_set_cipher_list(ctx, ciphers)
     SSL_CTX* ctx
     char* ciphers

int
SSL_CTX_use_certificate_file(ctx, filename, mode)
     SSL_CTX* ctx
     char* filename
     int mode

int
SSL_CTX_use_PrivateKey_file(ctx, filename ,mode)
     SSL_CTX* ctx
     char* filename
     int mode


int
SSL_CTX_use_pkcs12_file(ctx, filename, password)
     SSL_CTX* ctx
     char* filename
     char* password
     PREINIT:
	FILE *fp;
        EVP_PKEY *pkey;
        X509 *cert;
	STACK_OF(X509) *ca = NULL;
	PKCS12 *p12;
     CODE:
	if (fp = fopen(filename, "rb")) {
	  p12 = d2i_PKCS12_fp(fp, NULL);
	  fclose (fp);

	  if (p12) { 
	    if(PKCS12_parse(p12, password, &pkey, &cert, &ca)) {
	      if (pkey) {
		RETVAL = SSL_CTX_use_PrivateKey(ctx, pkey);
		EVP_PKEY_free(pkey);
	      }
	      if (cert) {
		RETVAL = SSL_CTX_use_certificate(ctx, cert);
		X509_free(cert);
	      }
	    }
	    PKCS12_free(p12);
	  }

	}
        

     OUTPUT:
	RETVAL


int
SSL_CTX_check_private_key(ctx)
     SSL_CTX* ctx

SV*
SSL_CTX_set_verify(ctx)
     SSL_CTX* ctx
     PREINIT:
        char* CAfile;
        char* CAdir;
     CODE:
        CAfile=getenv("HTTPS_CA_FILE");
        CAdir =getenv("HTTPS_CA_DIR");

        if(!CAfile && !CAdir) {
                SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL);
	        RETVAL = newSViv(0);
        } else {
                SSL_CTX_load_verify_locations(ctx,CAfile,CAdir);
                SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
	        RETVAL = newSViv(1);
        }
     OUTPUT:
       RETVAL

MODULE = Crypt::SSLeay		PACKAGE = Crypt::SSLeay::Conn	PREFIX = SSL_

SSL*
SSL_new(packname, ctx, debug, ...)
	SV* packname
	SSL_CTX* ctx
	SV* debug
	PREINIT:
	SSL* ssl;
	CODE:
	   ssl = SSL_new(ctx);
	   SSL_set_connect_state(ssl);
	   /* The set mode is necessary so the SSL connection can
  	    * survive a renegotiated cipher that results from 
	    * modssl VerifyClient config changing between 
	    * VirtualHost & some other config block.  At modssl
	    * this would be a [trace] ssl message:
	    *  "Changed client verification type will force renegotiation"
	    * -- jc 6/28/2001
	    */	      	
#ifdef SSL_MODE_AUTO_RETRY
	   SSL_set_mode(ssl, SSL_MODE_AUTO_RETRY);
#endif
	   RETVAL = ssl;
	   if(SvTRUE(debug)) {
             SSL_set_info_callback(RETVAL,InfoCallback);
	   }
	   if (items > 2) {
	       PerlIO* io = IoIFP(sv_2io(ST(3)));
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


SV*
SSL_get_verify_result(ssl)
	SSL* ssl
	CODE:
	   RETVAL = newSViv((SSL_get_verify_result(ssl) == X509_V_OK) ? 1 : 0);
	OUTPUT:
	   RETVAL


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

void
X509_free(cert)
       X509* cert

SV*
subject_name(cert)
	X509* cert
	PREINIT:
	   char* str;
	CODE:
	   str = X509_NAME_oneline(X509_get_subject_name(cert), NULL, 0);
	   RETVAL = newSVpv(str, 0);
	   CRYPT_SSLEAY_free(str);
	OUTPUT:
	   RETVAL

SV*
issuer_name(cert)
	X509* cert
	PREINIT:
	   char* str;
	CODE:
	   str = X509_NAME_oneline(X509_get_issuer_name(cert), NULL, 0);
	   RETVAL = newSVpv(str, 0);
	   CRYPT_SSLEAY_free(str);
	OUTPUT:
	   RETVAL

char*
get_notBeforeString(cert)
         X509* cert
         CODE:
            RETVAL = (char*) X509_get_notBefore(cert)->data;
         OUTPUT:
            RETVAL

char*
get_notAfterString(cert)
         X509* cert
         CODE:
            RETVAL = (char*) X509_get_notAfter(cert)->data;
         OUTPUT:
            RETVAL


