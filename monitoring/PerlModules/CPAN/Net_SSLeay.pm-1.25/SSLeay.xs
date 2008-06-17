/* SSLeay.xs - Perl module for using Eric Young's implementation of SSL
 *
 * Copyright (c) 1996-2002 Sampo Kellomaki <sampo@iki.fi>
 * All Rights Reserved.
 *
 * 19.6.1998, Maintenance release to sync with SSLeay-0.9.0, --Sampo
 * 24.6.1998, added write_partial to support ssl_write_all in more
 *            memory efficient way. --Sampo
 * 8.7.1998,  Added SSL_(CTX)?_set_options and associated constants.
 * 31.3.1999, Tracking OpenSSL-0.9.2b changes, dropping support for
 *            earlier versions
 * 30.7.1999, Tracking OpenSSL-0.9.3a changes, --Sampo
 * 7.4.2001,  OpenSSL-0.9.6a update, --Sampo
 * 18.4.2001, added TLSv1 support by Stephen C. Koehler
 *            <koehler@securecomputing.com>, version 1.07, --Sampo
 * 25.4.2001, applied 64 bit fixes by Marko Asplund <aspa@kronodoc.fi> --Sampo
 * 16.7.2001, applied Win filehandle patch from aspa, added
 *            SSL_*_methods --Sampo
 * 25.9.2001, added a big pile of methods by automatically grepping and diffing
 *            openssl headers and my module --Sampo
 * 17.4.2002, applied patch to fix CTX_set_default_passwd_cb() contributed
 *            by Timo Kujala <timo.kujala@@intellitel_.com>, --Sampo
 * 17.5.2002, Added BIO_s_mem, BIO_new, BIO_free, BIO_write, BIO_read ,
 *            BIO_eof, BIO_pending, BIO_wpending, X509_NAME_get_text_by_NID,
 *            RSA_generate_key, BIO_new_file
 *            Fixed problem with return value from verify callback being
 *            ignored.
 *            Fixed a problem with CTX_set_tmp_rsa and CTX_set_tmp_dh
 *            args incorrect
 *            --mikem@open.com_.au
 * 10.8.2002, Added SSL_peek patch to ssl_read_until from 
 *            Peter Behroozi <peter@@fhpwireless_.com> --Sampo
 * 21.8.2002, Added SESSION_get_master_key, SSL_get_client_random, SSL_get_server_random
 *            --mikem@open.com_.au
 * 2.9.2002,  Added SSL_CTX_get_cert_store, X509_STORE_add_cert, X509_STORE_add_crl
 *            X509_STORE_set_flags, X509_load_cert_file, X509_load_crl_file
 *            X509_load_cert_crl_file, PEM_read_bio_X509_CRL
 *            constants for X509_V_FLAG_*
 *            --mikem@open.com_.au
 * 6.9.2002,  applied Mike's patch and fixed X509_STORE_* to X509_STORE_CTX_*
 *	      --Sampo
 * 18.2.2003, RAND patch from Toni Andjelkovic <toni@soth._at>
 * 13.6.2003, applied SSL_X509_LOOKUP patch by Marian Jancar <mjancar@suse._cz>
 * 18.8.2003, fixed some const char pointer warnings --Sampo
 *
 * $Id: SSLeay.xs,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
 * 
 * The distribution and use of this module are subject to the conditions
 * listed in LICENSE file at the root of OpenSSL-0.9.6b
 * distribution (i.e. free, but mandatory attribution and NO WARRANTY).

Removed, perhaps permanently?

int
SSL_add_session(ctx,ses)
     SSL_CTX *          ctx
     SSL_SESSION *      ses

int
SSL_remove_session(ctx,ses)
     SSL_CTX *          ctx
     SSL_SESSION *      ses

void
SSL_flush_sessions(ctx,tm)
     SSL_CTX *          ctx
     long               tm

 */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* OpenSSL-0.9.3a has some strange warning about this in
 *    openssl/des.h
 */
#undef _

#include <openssl/err.h>
#include <openssl/lhash.h>
#include <openssl/rand.h>
#include <openssl/buffer.h>
#include <openssl/ssl.h>
#include <openssl/comp.h>    /* openssl-0.9.6a forgets to include this */
#include <openssl/md5.h>     /* openssl-SNAP-20020227 does not automatically include this */
/* Debugging output */

#if 0
#define PR(s) printf(s);
#define PRN(s,n) printf("'%s' (%d)\n",s,n);
#define SEX_DEBUG 1
#else
#define PR(s)
#define PRN(s,n)
#undef  SEX_DEBUG
#endif

static int
not_here(s)
char *s;
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

/* xsub automagically generated constant evaluator function */

static double
constant(char* name)
{
    errno = 0;
    switch (*name) {
    case 'A':
	if (strEQ(name, "AT_MD5_WITH_RSA_ENCRYPTION"))
#ifdef SSL_AT_MD5_WITH_RSA_ENCRYPTION
	    return SSL_AT_MD5_WITH_RSA_ENCRYPTION;
#else
	    goto not_there;
#endif
	break;
    case 'B':
	break;
    case 'C':
	if (strEQ(name, "CB_ACCEPT_EXIT"))
#ifdef SSL_CB_ACCEPT_EXIT
	    return SSL_CB_ACCEPT_EXIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CB_ACCEPT_LOOP"))
#ifdef SSL_CB_ACCEPT_LOOP
	    return SSL_CB_ACCEPT_LOOP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CB_CONNECT_EXIT"))
#ifdef SSL_CB_CONNECT_EXIT
	    return SSL_CB_CONNECT_EXIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CB_CONNECT_LOOP"))
#ifdef SSL_CB_CONNECT_LOOP
	    return SSL_CB_CONNECT_LOOP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_DES_192_EDE3_CBC_WITH_MD5"))
#ifdef SSL_CK_DES_192_EDE3_CBC_WITH_MD5
	    return SSL_CK_DES_192_EDE3_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_DES_192_EDE3_CBC_WITH_SHA"))
#ifdef SSL_CK_DES_192_EDE3_CBC_WITH_SHA
	    return SSL_CK_DES_192_EDE3_CBC_WITH_SHA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_DES_64_CBC_WITH_MD5"))
#ifdef SSL_CK_DES_64_CBC_WITH_MD5
	    return SSL_CK_DES_64_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_DES_64_CBC_WITH_SHA"))
#ifdef SSL_CK_DES_64_CBC_WITH_SHA
	    return SSL_CK_DES_64_CBC_WITH_SHA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_DES_64_CFB64_WITH_MD5_1"))
#ifdef SSL_CK_DES_64_CFB64_WITH_MD5_1
	    return SSL_CK_DES_64_CFB64_WITH_MD5_1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_IDEA_128_CBC_WITH_MD5"))
#ifdef SSL_CK_IDEA_128_CBC_WITH_MD5
	    return SSL_CK_IDEA_128_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_NULL"))
#ifdef SSL_CK_NULL
	    return SSL_CK_NULL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_NULL_WITH_MD5"))
#ifdef SSL_CK_NULL_WITH_MD5
	    return SSL_CK_NULL_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_RC2_128_CBC_EXPORT40_WITH_MD5"))
#ifdef SSL_CK_RC2_128_CBC_EXPORT40_WITH_MD5
	    return SSL_CK_RC2_128_CBC_EXPORT40_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_RC2_128_CBC_WITH_MD5"))
#ifdef SSL_CK_RC2_128_CBC_WITH_MD5
	    return SSL_CK_RC2_128_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_RC4_128_EXPORT40_WITH_MD5"))
#ifdef SSL_CK_RC4_128_EXPORT40_WITH_MD5
	    return SSL_CK_RC4_128_EXPORT40_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CK_RC4_128_WITH_MD5"))
#ifdef SSL_CK_RC4_128_WITH_MD5
	    return SSL_CK_RC4_128_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CLIENT_VERSION"))
#ifdef SSL_CLIENT_VERSION
	    return SSL_CLIENT_VERSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "CT_X509_CERTIFICATE"))
#ifdef SSL_CT_X509_CERTIFICATE
	    return SSL_CT_X509_CERTIFICATE;
#else
	    goto not_there;
#endif
	break;
    case 'D':
	break;
    case 'E':
      if (strEQ(name, "ERROR_NONE"))
#ifdef SSL_ERROR_NONE
      return SSL_ERROR_NONE;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_SSL"))
#ifdef SSL_ERROR_SSL
      return SSL_ERROR_SSL;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_SYSCALL"))
#ifdef SSL_ERROR_SYSCALL
      return SSL_ERROR_SYSCALL;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_WANT_CONNECT"))
#ifdef SSL_ERROR_WANT_CONNECT
      return SSL_ERROR_WANT_CONNECT;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_WANT_READ"))
#ifdef SSL_ERROR_WANT_READ
      return SSL_ERROR_WANT_READ;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_WANT_WRITE"))
#ifdef SSL_ERROR_WANT_WRITE
      return SSL_ERROR_WANT_WRITE;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_WANT_X509_LOOKUP"))
#ifdef SSL_ERROR_WANT_X509_LOOKUP
      return SSL_ERROR_WANT_X509_LOOKUP;
#else
      goto not_there;
#endif
      if (strEQ(name, "ERROR_ZERO_RETURN"))
#ifdef SSL_ERROR_ZERO_RETURN
      return SSL_ERROR_ZERO_RETURN;
#else
      goto not_there;
#endif
      break;
    case 'F':
	if (strEQ(name, "FILETYPE_ASN1"))
#ifdef SSL_FILETYPE_ASN1
	    return SSL_FILETYPE_ASN1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "FILETYPE_PEM"))
#ifdef SSL_FILETYPE_PEM
	    return SSL_FILETYPE_PEM;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_CLIENT_CERTIFICATE"))
#ifdef SSL_F_CLIENT_CERTIFICATE
	    return SSL_F_CLIENT_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_CLIENT_HELLO"))
#ifdef SSL_F_CLIENT_HELLO
	    return SSL_F_CLIENT_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_CLIENT_MASTER_KEY"))
#ifdef SSL_F_CLIENT_MASTER_KEY
	    return SSL_F_CLIENT_MASTER_KEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_D2I_SSL_SESSION"))
#ifdef SSL_F_D2I_SSL_SESSION
	    return SSL_F_D2I_SSL_SESSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_CLIENT_FINISHED"))
#ifdef SSL_F_GET_CLIENT_FINISHED
	    return SSL_F_GET_CLIENT_FINISHED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_CLIENT_HELLO"))
#ifdef SSL_F_GET_CLIENT_HELLO
	    return SSL_F_GET_CLIENT_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_CLIENT_MASTER_KEY"))
#ifdef SSL_F_GET_CLIENT_MASTER_KEY
	    return SSL_F_GET_CLIENT_MASTER_KEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_SERVER_FINISHED"))
#ifdef SSL_F_GET_SERVER_FINISHED
	    return SSL_F_GET_SERVER_FINISHED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_SERVER_HELLO"))
#ifdef SSL_F_GET_SERVER_HELLO
	    return SSL_F_GET_SERVER_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_GET_SERVER_VERIFY"))
#ifdef SSL_F_GET_SERVER_VERIFY
	    return SSL_F_GET_SERVER_VERIFY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_I2D_SSL_SESSION"))
#ifdef SSL_F_I2D_SSL_SESSION
	    return SSL_F_I2D_SSL_SESSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_READ_N"))
#ifdef SSL_F_READ_N
	    return SSL_F_READ_N;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_REQUEST_CERTIFICATE"))
#ifdef SSL_F_REQUEST_CERTIFICATE
	    return SSL_F_REQUEST_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SERVER_HELLO"))
#ifdef SSL_F_SERVER_HELLO
	    return SSL_F_SERVER_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ACCEPT"))
#ifdef SSL_F_SSL_ACCEPT
	    return SSL_F_SSL_ACCEPT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_CERT_NEW"))
#ifdef SSL_F_SSL_CERT_NEW
	    return SSL_F_SSL_CERT_NEW;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_CONNECT"))
#ifdef SSL_F_SSL_CONNECT
	    return SSL_F_SSL_CONNECT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_DES_CBC_INIT"))
#ifdef SSL_F_SSL_ENC_DES_CBC_INIT
	    return SSL_F_SSL_ENC_DES_CBC_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_DES_CFB_INIT"))
#ifdef SSL_F_SSL_ENC_DES_CFB_INIT
	    return SSL_F_SSL_ENC_DES_CFB_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_DES_EDE3_CBC_INIT"))
#ifdef SSL_F_SSL_ENC_DES_EDE3_CBC_INIT
	    return SSL_F_SSL_ENC_DES_EDE3_CBC_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_IDEA_CBC_INIT"))
#ifdef SSL_F_SSL_ENC_IDEA_CBC_INIT
	    return SSL_F_SSL_ENC_IDEA_CBC_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_NULL_INIT"))
#ifdef SSL_F_SSL_ENC_NULL_INIT
	    return SSL_F_SSL_ENC_NULL_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_RC2_CBC_INIT"))
#ifdef SSL_F_SSL_ENC_RC2_CBC_INIT
	    return SSL_F_SSL_ENC_RC2_CBC_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_ENC_RC4_INIT"))
#ifdef SSL_F_SSL_ENC_RC4_INIT
	    return SSL_F_SSL_ENC_RC4_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_GET_NEW_SESSION"))
#ifdef SSL_F_SSL_GET_NEW_SESSION
	    return SSL_F_SSL_GET_NEW_SESSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_MAKE_CIPHER_LIST"))
#ifdef SSL_F_SSL_MAKE_CIPHER_LIST
	    return SSL_F_SSL_MAKE_CIPHER_LIST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_NEW"))
#ifdef SSL_F_SSL_NEW
	    return SSL_F_SSL_NEW;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_READ"))
#ifdef SSL_F_SSL_READ
	    return SSL_F_SSL_READ;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_RSA_PRIVATE_DECRYPT"))
#ifdef SSL_F_SSL_RSA_PRIVATE_DECRYPT
	    return SSL_F_SSL_RSA_PRIVATE_DECRYPT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_RSA_PUBLIC_ENCRYPT"))
#ifdef SSL_F_SSL_RSA_PUBLIC_ENCRYPT
	    return SSL_F_SSL_RSA_PUBLIC_ENCRYPT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SESSION_NEW"))
#ifdef SSL_F_SSL_SESSION_NEW
	    return SSL_F_SSL_SESSION_NEW;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SESSION_PRINT_FP"))
#ifdef SSL_F_SSL_SESSION_PRINT_FP
	    return SSL_F_SSL_SESSION_PRINT_FP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SET_CERTIFICATE"))
#ifdef SSL_F_SSL_SET_CERTIFICATE
	    return SSL_F_SSL_SET_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SET_FD"))
#ifdef SSL_F_SSL_SET_FD
	    return SSL_F_SSL_SET_FD;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SET_RFD"))
#ifdef SSL_F_SSL_SET_RFD
	    return SSL_F_SSL_SET_RFD;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_SET_WFD"))
#ifdef SSL_F_SSL_SET_WFD
	    return SSL_F_SSL_SET_WFD;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_STARTUP"))
#ifdef SSL_F_SSL_STARTUP
	    return SSL_F_SSL_STARTUP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_CERTIFICATE"))
#ifdef SSL_F_SSL_USE_CERTIFICATE
	    return SSL_F_SSL_USE_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_CERTIFICATE_ASN1"))
#ifdef SSL_F_SSL_USE_CERTIFICATE_ASN1
	    return SSL_F_SSL_USE_CERTIFICATE_ASN1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_CERTIFICATE_FILE"))
#ifdef SSL_F_SSL_USE_CERTIFICATE_FILE
	    return SSL_F_SSL_USE_CERTIFICATE_FILE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_PRIVATEKEY"))
#ifdef SSL_F_SSL_USE_PRIVATEKEY
	    return SSL_F_SSL_USE_PRIVATEKEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_PRIVATEKEY_ASN1"))
#ifdef SSL_F_SSL_USE_PRIVATEKEY_ASN1
	    return SSL_F_SSL_USE_PRIVATEKEY_ASN1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_PRIVATEKEY_FILE"))
#ifdef SSL_F_SSL_USE_PRIVATEKEY_FILE
	    return SSL_F_SSL_USE_PRIVATEKEY_FILE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_RSAPRIVATEKEY"))
#ifdef SSL_F_SSL_USE_RSAPRIVATEKEY
	    return SSL_F_SSL_USE_RSAPRIVATEKEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_RSAPRIVATEKEY_ASN1"))
#ifdef SSL_F_SSL_USE_RSAPRIVATEKEY_ASN1
	    return SSL_F_SSL_USE_RSAPRIVATEKEY_ASN1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_SSL_USE_RSAPRIVATEKEY_FILE"))
#ifdef SSL_F_SSL_USE_RSAPRIVATEKEY_FILE
	    return SSL_F_SSL_USE_RSAPRIVATEKEY_FILE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "F_WRITE_PENDING"))
#ifdef SSL_F_WRITE_PENDING
	    return SSL_F_WRITE_PENDING;
#else
	    goto not_there;
#endif
	break;
    case 'G':
	break;
    case 'H':
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
	if (strEQ(name, "MAX_MASTER_KEY_LENGTH_IN_BITS"))
#ifdef SSL_MAX_MASTER_KEY_LENGTH_IN_BITS
	    return SSL_MAX_MASTER_KEY_LENGTH_IN_BITS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_RECORD_LENGTH_2_BYTE_HEADER"))
#ifdef SSL_MAX_RECORD_LENGTH_2_BYTE_HEADER
	    return SSL_MAX_RECORD_LENGTH_2_BYTE_HEADER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_RECORD_LENGTH_3_BYTE_HEADER"))
#ifdef SSL_MAX_RECORD_LENGTH_3_BYTE_HEADER
	    return SSL_MAX_RECORD_LENGTH_3_BYTE_HEADER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_SSL_SESSION_ID_LENGTH_IN_BYTES"))
#ifdef SSL_MAX_SSL_SESSION_ID_LENGTH_IN_BYTES
	    return SSL_MAX_SSL_SESSION_ID_LENGTH_IN_BYTES;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MIN_RSA_MODULUS_LENGTH_IN_BYTES"))
#ifdef SSL_MIN_RSA_MODULUS_LENGTH_IN_BYTES
	    return SSL_MIN_RSA_MODULUS_LENGTH_IN_BYTES;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_CLIENT_CERTIFICATE"))
#ifdef SSL_MT_CLIENT_CERTIFICATE
	    return SSL_MT_CLIENT_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_CLIENT_FINISHED"))
#ifdef SSL_MT_CLIENT_FINISHED
	    return SSL_MT_CLIENT_FINISHED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_CLIENT_HELLO"))
#ifdef SSL_MT_CLIENT_HELLO
	    return SSL_MT_CLIENT_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_CLIENT_MASTER_KEY"))
#ifdef SSL_MT_CLIENT_MASTER_KEY
	    return SSL_MT_CLIENT_MASTER_KEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_ERROR"))
#ifdef SSL_MT_ERROR
	    return SSL_MT_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_REQUEST_CERTIFICATE"))
#ifdef SSL_MT_REQUEST_CERTIFICATE
	    return SSL_MT_REQUEST_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_SERVER_FINISHED"))
#ifdef SSL_MT_SERVER_FINISHED
	    return SSL_MT_SERVER_FINISHED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_SERVER_HELLO"))
#ifdef SSL_MT_SERVER_HELLO
	    return SSL_MT_SERVER_HELLO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MT_SERVER_VERIFY"))
#ifdef SSL_MT_SERVER_VERIFY
	    return SSL_MT_SERVER_VERIFY;
#else
	    goto not_there;
#endif
	break;
    case 'N':
	if (strEQ(name, "NOTHING"))
#ifdef SSL_NOTHING
	    return SSL_NOTHING;
#else
	    goto not_there;
#endif
	break;
    case 'O':
	if (strEQ(name, "OPENSSL_VERSION_NUMBER"))
#ifdef OPENSSL_VERSION_NUMBER
            return OPENSSL_VERSION_NUMBER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_MICROSOFT_SESS_ID_BUG"))
#ifdef SSL_OP_MICROSOFT_SESS_ID_BUG
	    return SSL_OP_MICROSOFT_SESS_ID_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NETSCAPE_CHALLENGE_BUG"))
#ifdef SSL_OP_NETSCAPE_CHALLENGE_BUG
	    return SSL_OP_NETSCAPE_CHALLENGE_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NETSCAPE_REUSE_CIPHER_CHANGE_BUG"))
#ifdef SSL_OP_NETSCAPE_REUSE_CIPHER_CHANGE_BUG
	    return SSL_OP_NETSCAPE_REUSE_CIPHER_CHANGE_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_SSLREF2_REUSE_CERT_TYPE_BUG"))
#ifdef SSL_OP_SSLREF2_REUSE_CERT_TYPE_BUG
	    return SSL_OP_SSLREF2_REUSE_CERT_TYPE_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_MICROSOFT_BIG_SSLV3_BUFFER"))
#ifdef SSL_OP_MICROSOFT_BIG_SSLV3_BUFFER
	    return SSL_OP_MICROSOFT_BIG_SSLV3_BUFFER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_MSIE_SSLV2_RSA_PADDING"))
#ifdef SSL_OP_MSIE_SSLV2_RSA_PADDING
	    return SSL_OP_MSIE_SSLV2_RSA_PADDING;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_SSLEAY_080_CLIENT_DH_BUG"))
#ifdef SSL_OP_SSLEAY_080_CLIENT_DH_BUG
	    return SSL_OP_SSLEAY_080_CLIENT_DH_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_TLS_D5_BUG"))
#ifdef SSL_OP_TLS_D5_BUG
	    return SSL_OP_TLS_D5_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_SINGLE_DH_USE"))
#ifdef SSL_OP_SINGLE_DH_USE
	    return SSL_OP_SINGLE_DH_USE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_EPHEMERAL_RSA"))
#ifdef SSL_OP_EPHEMERAL_RSA
	    return SSL_OP_EPHEMERAL_RSA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NETSCAPE_CA_DN_BUG"))
#ifdef SSL_OP_NETSCAPE_CA_DN_BUG
	    return SSL_OP_NETSCAPE_CA_DN_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NON_EXPORT_FIRST"))
#ifdef SSL_OP_NON_EXPORT_FIRST
	    return SSL_OP_NON_EXPORT_FIRST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NETSCAPE_DEMO_CIPHER_CHANGE_BUG"))
#ifdef SSL_OP_NETSCAPE_DEMO_CIPHER_CHANGE_BUG
	    return SSL_OP_NETSCAPE_DEMO_CIPHER_CHANGE_BUG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NO_SSLv2"))
#ifdef SSL_OP_NO_SSLv2
	    return SSL_OP_NO_SSLv2;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NO_SSLv3"))
#ifdef SSL_OP_NO_SSLv3
	    return SSL_OP_NO_SSLv3;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_NO_TLSv1"))
#ifdef SSL_OP_NO_TLSv1
	    return SSL_OP_NO_TLSv1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "OP_ALL"))
#ifdef SSL_OP_ALL
	    return SSL_OP_ALL;
#else
	    goto not_there;
#endif

    case 'P':
	if (strEQ(name, "PE_BAD_CERTIFICATE"))
#ifdef SSL_PE_BAD_CERTIFICATE
	    return SSL_PE_BAD_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "PE_NO_CERTIFICATE"))
#ifdef SSL_PE_NO_CERTIFICATE
	    return SSL_PE_NO_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "PE_NO_CIPHER"))
#ifdef SSL_PE_NO_CIPHER
	    return SSL_PE_NO_CIPHER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "PE_UNSUPPORTED_CERTIFICATE_TYPE"))
#ifdef SSL_PE_UNSUPPORTED_CERTIFICATE_TYPE
	    return SSL_PE_UNSUPPORTED_CERTIFICATE_TYPE;
#else
	    goto not_there;
#endif
	break;
    case 'Q':
	break;
    case 'R':
	if (strEQ(name, "READING"))
#ifdef SSL_READING
	    return SSL_READING;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RWERR_BAD_MAC_DECODE"))
#ifdef SSL_RWERR_BAD_MAC_DECODE
	    return SSL_RWERR_BAD_MAC_DECODE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RWERR_BAD_WRITE_RETRY"))
#ifdef SSL_RWERR_BAD_WRITE_RETRY
	    return SSL_RWERR_BAD_WRITE_RETRY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RWERR_INTERNAL_ERROR"))
#ifdef SSL_RWERR_INTERNAL_ERROR
	    return SSL_RWERR_INTERNAL_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_AUTHENTICATION_TYPE"))
#ifdef SSL_R_BAD_AUTHENTICATION_TYPE
	    return SSL_R_BAD_AUTHENTICATION_TYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_CHECKSUM"))
#ifdef SSL_R_BAD_CHECKSUM
	    return SSL_R_BAD_CHECKSUM;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_MAC_DECODE"))
#ifdef SSL_R_BAD_MAC_DECODE
	    return SSL_R_BAD_MAC_DECODE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_RESPONSE_ARGUMENT"))
#ifdef SSL_R_BAD_RESPONSE_ARGUMENT
	    return SSL_R_BAD_RESPONSE_ARGUMENT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_SSL_FILETYPE"))
#ifdef SSL_R_BAD_SSL_FILETYPE
	    return SSL_R_BAD_SSL_FILETYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_SSL_SESSION_ID_LENGTH"))
#ifdef SSL_R_BAD_SSL_SESSION_ID_LENGTH
	    return SSL_R_BAD_SSL_SESSION_ID_LENGTH;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_STATE"))
#ifdef SSL_R_BAD_STATE
	    return SSL_R_BAD_STATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_BAD_WRITE_RETRY"))
#ifdef SSL_R_BAD_WRITE_RETRY
	    return SSL_R_BAD_WRITE_RETRY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_CHALLENGE_IS_DIFFERENT"))
#ifdef SSL_R_CHALLENGE_IS_DIFFERENT
	    return SSL_R_CHALLENGE_IS_DIFFERENT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_CIPHER_CODE_TOO_LONG"))
#ifdef SSL_R_CIPHER_CODE_TOO_LONG
	    return SSL_R_CIPHER_CODE_TOO_LONG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_CIPHER_TABLE_SRC_ERROR"))
#ifdef SSL_R_CIPHER_TABLE_SRC_ERROR
	    return SSL_R_CIPHER_TABLE_SRC_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_CONECTION_ID_IS_DIFFERENT"))
#ifdef SSL_R_CONECTION_ID_IS_DIFFERENT
	    return SSL_R_CONECTION_ID_IS_DIFFERENT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_INVALID_CHALLENGE_LENGTH"))
#ifdef SSL_R_INVALID_CHALLENGE_LENGTH
	    return SSL_R_INVALID_CHALLENGE_LENGTH;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_CERTIFICATE_SET"))
#ifdef SSL_R_NO_CERTIFICATE_SET
	    return SSL_R_NO_CERTIFICATE_SET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_CERTIFICATE_SPECIFIED"))
#ifdef SSL_R_NO_CERTIFICATE_SPECIFIED
	    return SSL_R_NO_CERTIFICATE_SPECIFIED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_CIPHER_LIST"))
#ifdef SSL_R_NO_CIPHER_LIST
	    return SSL_R_NO_CIPHER_LIST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_CIPHER_MATCH"))
#ifdef SSL_R_NO_CIPHER_MATCH
	    return SSL_R_NO_CIPHER_MATCH;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_CIPHER_WE_TRUST"))
#ifdef SSL_R_NO_CIPHER_WE_TRUST
	    return SSL_R_NO_CIPHER_WE_TRUST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_PRIVATEKEY"))
#ifdef SSL_R_NO_PRIVATEKEY
	    return SSL_R_NO_PRIVATEKEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_PUBLICKEY"))
#ifdef SSL_R_NO_PUBLICKEY
	    return SSL_R_NO_PUBLICKEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_READ_METHOD_SET"))
#ifdef SSL_R_NO_READ_METHOD_SET
	    return SSL_R_NO_READ_METHOD_SET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NO_WRITE_METHOD_SET"))
#ifdef SSL_R_NO_WRITE_METHOD_SET
	    return SSL_R_NO_WRITE_METHOD_SET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NULL_SSL_CTX"))
#ifdef SSL_R_NULL_SSL_CTX
	    return SSL_R_NULL_SSL_CTX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PEER_DID_NOT_RETURN_A_CERTIFICATE"))
#ifdef SSL_R_PEER_DID_NOT_RETURN_A_CERTIFICATE
	    return SSL_R_PEER_DID_NOT_RETURN_A_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PEER_ERROR"))
#ifdef SSL_R_PEER_ERROR
	    return SSL_R_PEER_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PEER_ERROR_CERTIFICATE"))
#ifdef SSL_R_PEER_ERROR_CERTIFICATE
	    return SSL_R_PEER_ERROR_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PEER_ERROR_NO_CIPHER"))
#ifdef SSL_R_PEER_ERROR_NO_CIPHER
	    return SSL_R_PEER_ERROR_NO_CIPHER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PEER_ERROR_UNSUPPORTED_CERTIFICATE_TYPE"))
#ifdef SSL_R_PEER_ERROR_UNSUPPORTED_CERTIFICATE_TYPE
	    return SSL_R_PEER_ERROR_UNSUPPORTED_CERTIFICATE_TYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PERR_ERROR_NO_CERTIFICATE"))
#ifdef SSL_R_PERR_ERROR_NO_CERTIFICATE
	    return SSL_R_PERR_ERROR_NO_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PUBLIC_KEY_ENCRYPT_ERROR"))
#ifdef SSL_R_PUBLIC_KEY_ENCRYPT_ERROR
	    return SSL_R_PUBLIC_KEY_ENCRYPT_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PUBLIC_KEY_IS_NOT_RSA"))
#ifdef SSL_R_PUBLIC_KEY_IS_NOT_RSA
	    return SSL_R_PUBLIC_KEY_IS_NOT_RSA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PUBLIC_KEY_NO_RSA"))
#ifdef SSL_R_PUBLIC_KEY_NO_RSA
	    return SSL_R_PUBLIC_KEY_NO_RSA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_READ_WRONG_PACKET_TYPE"))
#ifdef SSL_R_READ_WRONG_PACKET_TYPE
	    return SSL_R_READ_WRONG_PACKET_TYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_REVERSE_KEY_ARG_LENGTH_IS_WRONG"))
#ifdef SSL_R_REVERSE_KEY_ARG_LENGTH_IS_WRONG
	    return SSL_R_REVERSE_KEY_ARG_LENGTH_IS_WRONG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_REVERSE_MASTER_KEY_LENGTH_IS_WRONG"))
#ifdef SSL_R_REVERSE_MASTER_KEY_LENGTH_IS_WRONG
	    return SSL_R_REVERSE_MASTER_KEY_LENGTH_IS_WRONG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_REVERSE_SSL_SESSION_ID_LENGTH_IS_WRONG"))
#ifdef SSL_R_REVERSE_SSL_SESSION_ID_LENGTH_IS_WRONG
	    return SSL_R_REVERSE_SSL_SESSION_ID_LENGTH_IS_WRONG;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_SHORT_READ"))
#ifdef SSL_R_SHORT_READ
	    return SSL_R_SHORT_READ;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_SSL_SESSION_ID_IS_DIFFERENT"))
#ifdef SSL_R_SSL_SESSION_ID_IS_DIFFERENT
	    return SSL_R_SSL_SESSION_ID_IS_DIFFERENT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_UNABLE_TO_EXTRACT_PUBLIC_KEY"))
#ifdef SSL_R_UNABLE_TO_EXTRACT_PUBLIC_KEY
	    return SSL_R_UNABLE_TO_EXTRACT_PUBLIC_KEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_UNDEFINED_INIT_STATE"))
#ifdef SSL_R_UNDEFINED_INIT_STATE
	    return SSL_R_UNDEFINED_INIT_STATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_UNKNOWN_REMOTE_ERROR_TYPE"))
#ifdef SSL_R_UNKNOWN_REMOTE_ERROR_TYPE
	    return SSL_R_UNKNOWN_REMOTE_ERROR_TYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_UNKNOWN_STATE"))
#ifdef SSL_R_UNKNOWN_STATE
	    return SSL_R_UNKNOWN_STATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_UNSUPORTED_CIPHER"))
#ifdef SSL_R_UNSUPORTED_CIPHER
	    return SSL_R_UNSUPORTED_CIPHER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_WRONG_PUBLIC_KEY_TYPE"))
#ifdef SSL_R_WRONG_PUBLIC_KEY_TYPE
	    return SSL_R_WRONG_PUBLIC_KEY_TYPE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_X509_LIB"))
#ifdef SSL_R_X509_LIB
	    return SSL_R_X509_LIB;
#else
	    goto not_there;
#endif
	break;
    case 'S':
	if (strEQ(name, "SERVER_VERSION"))
#ifdef SSL_SERVER_VERSION
	    return SSL_SERVER_VERSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SESSION_ASN1_VERSION"))
#ifdef SSL_SESSION_ASN1_VERSION
	    return SSL_SESSION_ASN1_VERSION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_ACCEPT"))
#ifdef SSL_ST_ACCEPT
	    return SSL_ST_ACCEPT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_BEFORE"))
#ifdef SSL_ST_BEFORE
	    return SSL_ST_BEFORE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_CLIENT_START_ENCRYPTION"))
#ifdef SSL_ST_CLIENT_START_ENCRYPTION
	    return SSL_ST_CLIENT_START_ENCRYPTION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_CONNECT"))
#ifdef SSL_ST_CONNECT
	    return SSL_ST_CONNECT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_FINISHED_A"))
#ifdef SSL_ST_GET_CLIENT_FINISHED_A
	    return SSL_ST_GET_CLIENT_FINISHED_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_FINISHED_B"))
#ifdef SSL_ST_GET_CLIENT_FINISHED_B
	    return SSL_ST_GET_CLIENT_FINISHED_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_HELLO_A"))
#ifdef SSL_ST_GET_CLIENT_HELLO_A
	    return SSL_ST_GET_CLIENT_HELLO_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_HELLO_B"))
#ifdef SSL_ST_GET_CLIENT_HELLO_B
	    return SSL_ST_GET_CLIENT_HELLO_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_MASTER_KEY_A"))
#ifdef SSL_ST_GET_CLIENT_MASTER_KEY_A
	    return SSL_ST_GET_CLIENT_MASTER_KEY_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_CLIENT_MASTER_KEY_B"))
#ifdef SSL_ST_GET_CLIENT_MASTER_KEY_B
	    return SSL_ST_GET_CLIENT_MASTER_KEY_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_FINISHED_A"))
#ifdef SSL_ST_GET_SERVER_FINISHED_A
	    return SSL_ST_GET_SERVER_FINISHED_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_FINISHED_B"))
#ifdef SSL_ST_GET_SERVER_FINISHED_B
	    return SSL_ST_GET_SERVER_FINISHED_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_HELLO_A"))
#ifdef SSL_ST_GET_SERVER_HELLO_A
	    return SSL_ST_GET_SERVER_HELLO_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_HELLO_B"))
#ifdef SSL_ST_GET_SERVER_HELLO_B
	    return SSL_ST_GET_SERVER_HELLO_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_VERIFY_A"))
#ifdef SSL_ST_GET_SERVER_VERIFY_A
	    return SSL_ST_GET_SERVER_VERIFY_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_GET_SERVER_VERIFY_B"))
#ifdef SSL_ST_GET_SERVER_VERIFY_B
	    return SSL_ST_GET_SERVER_VERIFY_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_INIT"))
#ifdef SSL_ST_INIT
	    return SSL_ST_INIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_OK"))
#ifdef SSL_ST_OK
	    return SSL_ST_OK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_READ_BODY"))
#ifdef SSL_ST_READ_BODY
	    return SSL_ST_READ_BODY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_READ_HEADER"))
#ifdef SSL_ST_READ_HEADER
	    return SSL_ST_READ_HEADER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_CERTIFICATE_A"))
#ifdef SSL_ST_SEND_CLIENT_CERTIFICATE_A
	    return SSL_ST_SEND_CLIENT_CERTIFICATE_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_CERTIFICATE_B"))
#ifdef SSL_ST_SEND_CLIENT_CERTIFICATE_B
	    return SSL_ST_SEND_CLIENT_CERTIFICATE_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_CERTIFICATE_C"))
#ifdef SSL_ST_SEND_CLIENT_CERTIFICATE_C
	    return SSL_ST_SEND_CLIENT_CERTIFICATE_C;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_CERTIFICATE_D"))
#ifdef SSL_ST_SEND_CLIENT_CERTIFICATE_D
	    return SSL_ST_SEND_CLIENT_CERTIFICATE_D;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_FINISHED_A"))
#ifdef SSL_ST_SEND_CLIENT_FINISHED_A
	    return SSL_ST_SEND_CLIENT_FINISHED_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_FINISHED_B"))
#ifdef SSL_ST_SEND_CLIENT_FINISHED_B
	    return SSL_ST_SEND_CLIENT_FINISHED_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_HELLO_A"))
#ifdef SSL_ST_SEND_CLIENT_HELLO_A
	    return SSL_ST_SEND_CLIENT_HELLO_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_HELLO_B"))
#ifdef SSL_ST_SEND_CLIENT_HELLO_B
	    return SSL_ST_SEND_CLIENT_HELLO_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_MASTER_KEY_A"))
#ifdef SSL_ST_SEND_CLIENT_MASTER_KEY_A
	    return SSL_ST_SEND_CLIENT_MASTER_KEY_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_CLIENT_MASTER_KEY_B"))
#ifdef SSL_ST_SEND_CLIENT_MASTER_KEY_B
	    return SSL_ST_SEND_CLIENT_MASTER_KEY_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_REQUEST_CERTIFICATE_A"))
#ifdef SSL_ST_SEND_REQUEST_CERTIFICATE_A
	    return SSL_ST_SEND_REQUEST_CERTIFICATE_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_REQUEST_CERTIFICATE_B"))
#ifdef SSL_ST_SEND_REQUEST_CERTIFICATE_B
	    return SSL_ST_SEND_REQUEST_CERTIFICATE_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_REQUEST_CERTIFICATE_C"))
#ifdef SSL_ST_SEND_REQUEST_CERTIFICATE_C
	    return SSL_ST_SEND_REQUEST_CERTIFICATE_C;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_REQUEST_CERTIFICATE_D"))
#ifdef SSL_ST_SEND_REQUEST_CERTIFICATE_D
	    return SSL_ST_SEND_REQUEST_CERTIFICATE_D;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_FINISHED_A"))
#ifdef SSL_ST_SEND_SERVER_FINISHED_A
	    return SSL_ST_SEND_SERVER_FINISHED_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_FINISHED_B"))
#ifdef SSL_ST_SEND_SERVER_FINISHED_B
	    return SSL_ST_SEND_SERVER_FINISHED_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_HELLO_A"))
#ifdef SSL_ST_SEND_SERVER_HELLO_A
	    return SSL_ST_SEND_SERVER_HELLO_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_HELLO_B"))
#ifdef SSL_ST_SEND_SERVER_HELLO_B
	    return SSL_ST_SEND_SERVER_HELLO_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_VERIFY_A"))
#ifdef SSL_ST_SEND_SERVER_VERIFY_A
	    return SSL_ST_SEND_SERVER_VERIFY_A;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SEND_SERVER_VERIFY_B"))
#ifdef SSL_ST_SEND_SERVER_VERIFY_B
	    return SSL_ST_SEND_SERVER_VERIFY_B;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_SERVER_START_ENCRYPTION"))
#ifdef SSL_ST_SERVER_START_ENCRYPTION
	    return SSL_ST_SERVER_START_ENCRYPTION;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_X509_GET_CLIENT_CERTIFICATE"))
#ifdef SSL_ST_X509_GET_CLIENT_CERTIFICATE
	    return SSL_ST_X509_GET_CLIENT_CERTIFICATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "ST_X509_GET_SERVER_CERTIFICATE"))
#ifdef SSL_ST_X509_GET_SERVER_CERTIFICATE
	    return SSL_ST_X509_GET_SERVER_CERTIFICATE;
#else
	    goto not_there;
#endif
	break;
    case 'T':
#if 0
	if (strEQ(name, "TXT_DES_192_EDE3_CBC_WITH_MD5"))
#ifdef SSL_TXT_DES_192_EDE3_CBC_WITH_MD5
	    return SSL_TXT_DES_192_EDE3_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_DES_192_EDE3_CBC_WITH_SHA"))
#ifdef SSL_TXT_DES_192_EDE3_CBC_WITH_SHA
	    return SSL_TXT_DES_192_EDE3_CBC_WITH_SHA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_DES_64_CBC_WITH_MD5"))
#ifdef SSL_TXT_DES_64_CBC_WITH_MD5
	    return SSL_TXT_DES_64_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_DES_64_CBC_WITH_SHA"))
#ifdef SSL_TXT_DES_64_CBC_WITH_SHA
	    return SSL_TXT_DES_64_CBC_WITH_SHA;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_DES_64_CFB64_WITH_MD5_1"))
#ifdef SSL_TXT_DES_64_CFB64_WITH_MD5_1
	    return SSL_TXT_DES_64_CFB64_WITH_MD5_1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_IDEA_128_CBC_WITH_MD5"))
#ifdef SSL_TXT_IDEA_128_CBC_WITH_MD5
	    return SSL_TXT_IDEA_128_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_NULL"))
#ifdef SSL_TXT_NULL
	    return SSL_TXT_NULL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_NULL_WITH_MD5"))
#ifdef SSL_TXT_NULL_WITH_MD5
	    return SSL_TXT_NULL_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_RC2_128_CBC_EXPORT40_WITH_MD5"))
#ifdef SSL_TXT_RC2_128_CBC_EXPORT40_WITH_MD5
	    return SSL_TXT_RC2_128_CBC_EXPORT40_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_RC2_128_CBC_WITH_MD5"))
#ifdef SSL_TXT_RC2_128_CBC_WITH_MD5
	    return SSL_TXT_RC2_128_CBC_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_RC4_128_EXPORT40_WITH_MD5"))
#ifdef SSL_TXT_RC4_128_EXPORT40_WITH_MD5
	    return SSL_TXT_RC4_128_EXPORT40_WITH_MD5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "TXT_RC4_128_WITH_MD5"))
#ifdef SSL_TXT_RC4_128_WITH_MD5
	    return SSL_TXT_RC4_128_WITH_MD5;
#else
	    goto not_there;
#endif
#endif
	break;
    case 'U':
	break;
    case 'V':
	if (strEQ(name, "VERIFY_CLIENT_ONCE"))
#ifdef SSL_VERIFY_CLIENT_ONCE
	    return SSL_VERIFY_CLIENT_ONCE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "VERIFY_FAIL_IF_NO_PEER_CERT"))
#ifdef SSL_VERIFY_FAIL_IF_NO_PEER_CERT
	    return SSL_VERIFY_FAIL_IF_NO_PEER_CERT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "VERIFY_NONE"))
#ifdef SSL_VERIFY_NONE
	    return SSL_VERIFY_NONE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "VERIFY_PEER"))
#ifdef SSL_VERIFY_PEER
	    return SSL_VERIFY_PEER;
#else
	    goto not_there;
#endif
	break;
    case 'W':
	if (strEQ(name, "WRITING"))
#ifdef SSL_WRITING
	    return SSL_WRITING;
#else
	    goto not_there;
#endif
	break;
    case 'X':
	if (strEQ(name, "X509_LOOKUP"))
#ifdef SSL_X509_LOOKUP
	    return SSL_X509_LOOKUP;
#else
	    goto not_there;
#endif

	if (strEQ(name, "X509_V_FLAG_CB_ISSUER_CHECK"))
#ifdef X509_V_FLAG_CB_ISSUER_CHECK
	    return X509_V_FLAG_CB_ISSUER_CHECK;
#else
	    goto not_there;
#endif

	if (strEQ(name, "X509_V_FLAG_USE_CHECK_TIME"))
#ifdef X509_V_FLAG_USE_CHECK_TIME
	    return X509_V_FLAG_USE_CHECK_TIME;
#else
	    goto not_there;
#endif
	if (strEQ(name, "X509_V_FLAG_CRL_CHECK"))
#ifdef X509_V_FLAG_CRL_CHECK
	    return X509_V_FLAG_CRL_CHECK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "X509_V_FLAG_CRL_CHECK_ALL"))
#ifdef X509_V_FLAG_CRL_CHECK_ALL
	    return X509_V_FLAG_CRL_CHECK_ALL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "X509_V_FLAG_IGNORE_CRITICAL"))
#ifdef X509_V_FLAG_IGNORE_CRITICAL
	    return X509_V_FLAG_IGNORE_CRITICAL;
#else
	    goto not_there;
#endif
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

/* ============= typedefs to agument TYPEMAP ============== */

typedef int callback_ret_int();
typedef void callback_no_ret();
typedef RSA * cb_ssl_int_int_ret_RSA(SSL * ssl,int is_export, int keylength);
typedef DH * cb_ssl_int_int_ret_DH(SSL * ssl,int is_export, int keylength);

typedef STACK_OF(X509_NAME) X509_NAME_STACK;

/* ============= callback stuff ============== */

static SV * ssleay_verify_callback = (SV*)NULL;

static int
ssleay_verify_callback_glue (int ok, X509_STORE_CTX* ctx)
{
	dSP ;
	int count,res;
	
	ENTER ;
	SAVETMPS;

	PRN("verify callback glue", ok);

	PUSHMARK(sp);
	XPUSHs(sv_2mortal(newSViv(ok)));
	XPUSHs(sv_2mortal(newSViv((unsigned long int)ctx)));
	PUTBACK ;
	
	if (ssleay_verify_callback == NULL)
		croak ("Net::SSLeay: verify_callback called, but not "
			"set to point to any perl function.\n");

	PR("About to call verify callback.\n");	
	count = perl_call_sv(ssleay_verify_callback, G_SCALAR);
	PR("Returned from verify callback.\n");	

	SPAGAIN;
	
	if (count != 1)
		croak ( "Net::SSLeay: verify_callback "
			"perl function did not return a scalar.\n");
	res = POPi ;

	PUTBACK ;
	FREETMPS ;
	LEAVE ;

	return res;
}

static SV * ssleay_ctx_verify_callback = (SV*)NULL;

static int
ssleay_ctx_verify_callback_glue (int ok, X509_STORE_CTX* ctx)
{
	dSP ;
	int count,res;
	
	ENTER ;
	SAVETMPS;
	
	PRN("ctx verify callback glue", ok);

	PUSHMARK(sp);
	XPUSHs(sv_2mortal(newSViv(ok)));
	XPUSHs(sv_2mortal(newSViv((unsigned long int)ctx)));
	PUTBACK ;
	
	if (ssleay_ctx_verify_callback == NULL)
		croak ("Net::SSLeay: ctx_verify_callback called, but not "
			"set to point to any perl function.\n");

	PR("About to call ctx verify callback.\n");	
	count = perl_call_sv(ssleay_ctx_verify_callback, G_SCALAR);
	PR("Returned from ctx verify callback.\n");	

	SPAGAIN;
	
	if (count != 1)
		croak ( "Net::SSLeay: ctx_verify_callback "
			"perl function did not return a scalar.\n");
	res = POPi ;

	PUTBACK ;
	FREETMPS ;
	LEAVE ;
	
	return res;
}

static SV * ssleay_ctx_set_default_passwd_cb_callback = (SV*)NULL;

/* pem_password_cb function */

static int
ssleay_ctx_set_default_passwd_cb_callback_glue (char *buf, int size,
				 		int rwflag, void *userdata)
{
      dSP;
      int count;
      char *res;

      ENTER;
      SAVETMPS;

      PUSHMARK(sp);
      XPUSHs(sv_2mortal(newSViv(rwflag)));
      XPUSHs(sv_2mortal(newSViv((unsigned long)userdata)));
      PUTBACK;

      if (ssleay_ctx_set_default_passwd_cb_callback == NULL)
              croak ("Net::SSLeay: ctx_passwd_callback called, but not "
                     "set to point to any perl function.\n");

      PR("About to call passwd callback.\n");
      count = perl_call_sv(ssleay_ctx_set_default_passwd_cb_callback, G_SCALAR);
      PR("Returned from ctx passwd callback.\n");

      SPAGAIN;

      if (count != 1)
              croak ("Net::SSLeay: ctx_passwd_callback "
                     "perl function did not return a scalar.\n");
      res = POPp;
      
      if (res == NULL) {
              *buf = '\0';
      } else {
              strncpy(buf, res, size);
              buf[size - 1] = '\0';
      }

      PUTBACK;
      FREETMPS;
      LEAVE;

      return strlen(buf);
}

MODULE = Net::SSLeay		PACKAGE = Net::SSLeay          PREFIX = SSL_

PROTOTYPES: ENABLE

double
constant(name)
     char *		name

int
hello()
        CODE:
        PR("\tSSLeay Hello World!\n");
        RETVAL = 1;
        OUTPUT:
        RETVAL

#define REM1 "============= SSL CONTEXT functions =============="

SSL_CTX *
SSL_CTX_new()
     CODE:
     RETVAL = SSL_CTX_new (SSLv23_method());
     OUTPUT:
     RETVAL

SSL_CTX *
SSL_CTX_v2_new()
     CODE:
     RETVAL = SSL_CTX_new (SSLv2_method());
     OUTPUT:
     RETVAL

SSL_CTX *
SSL_CTX_v3_new()
     CODE:
     RETVAL = SSL_CTX_new (SSLv3_method());
     OUTPUT:
     RETVAL

SSL_CTX *
SSL_CTX_v23_new()
     CODE:
     RETVAL = SSL_CTX_new (SSLv23_method());
     OUTPUT:
     RETVAL

SSL_CTX *
SSL_CTX_tlsv1_new()
     CODE:
     RETVAL = SSL_CTX_new (TLSv1_method());
     OUTPUT:
     RETVAL

SSL_CTX *
SSL_CTX_new_with_method(meth)
     SSL_METHOD *   meth
     CODE:
     RETVAL = SSL_CTX_new (SSLv23_method());
     OUTPUT:
     RETVAL

void
SSL_CTX_free(ctx)
     SSL_CTX *	        ctx

int
SSL_CTX_add_session(ctx,ses)
     SSL_CTX *          ctx
     SSL_SESSION *      ses

int
SSL_CTX_remove_session(ctx,ses)
     SSL_CTX *          ctx
     SSL_SESSION *      ses

void
SSL_CTX_flush_sessions(ctx,tm)
     SSL_CTX *          ctx
     long               tm

int
SSL_CTX_set_default_verify_paths(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_load_verify_locations(ctx,CAfile,CApath)
     SSL_CTX * ctx
     char * CAfile
     char * CApath
     CODE:
     RETVAL = SSL_CTX_load_verify_locations (ctx,
					     CAfile?(*CAfile?CAfile:NULL):NULL,
					     CApath?(*CApath?CApath:NULL):NULL
					     );
     OUTPUT:
     RETVAL

void
SSL_CTX_set_verify(ctx,mode,callback)
     SSL_CTX * ctx
     int                mode
     SV *               callback
     CODE:
     if (ssleay_ctx_verify_callback == (SV*)NULL) {
        ssleay_ctx_verify_callback = newSVsv(callback);
     } else {
         SvSetSV (ssleay_ctx_verify_callback, callback);
     }
     if (SvTRUE(ssleay_ctx_verify_callback)) {
         SSL_CTX_set_verify(ctx,mode,&ssleay_ctx_verify_callback_glue);
     } else {
         SSL_CTX_set_verify(ctx,mode,NULL);
     }

int
SSL_get_error(s,ret)
     SSL *              s
     int ret

#define REM10 "============= SSL functions =============="

SSL *
SSL_new(ctx)
     SSL_CTX *	        ctx

void
SSL_free(s)
     SSL *              s

#if 0 /* this seems to be gone in 0.9.0 */
void
SSL_debug(file)
       char *  file

#endif

int
SSL_accept(s)
     SSL *   s

void
SSL_clear(s)
     SSL *   s

int
SSL_connect(s)
     SSL *   s


#if defined(WIN32)

int
SSL_set_fd(s,fd)
     SSL *   s
     int     fd
     CODE:
     RETVAL = SSL_set_fd(s,_get_osfhandle(fd));
     OUTPUT:
     RETVAL

int
SSL_set_rfd(s,fd)
     SSL *   s
     int     fd
     CODE:
     RETVAL = SSL_set_rfd(s,_get_osfhandle(fd));
     OUTPUT:
     RETVAL

int
SSL_set_wfd(s,fd)
     SSL *   s
     int     fd
     CODE:
     RETVAL = SSL_set_wfd(s,_get_osfhandle(fd));
     OUTPUT:
     RETVAL

#else

int
SSL_set_fd(s,fd)
     SSL *   s
     int     fd

int
SSL_set_rfd(s,fd)
     SSL *   s
     int     fd

int
SSL_set_wfd(s,fd)
     SSL *   s
     int     fd

#endif

int
SSL_get_fd(s)
     SSL *   s

void
SSL_read(s,max=sizeof(buf))
     SSL *   s
     PREINIT:
     char buf[32768];
     INPUT:
     int     max
     PREINIT:
     int got;
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if ((got = SSL_read(s, buf, max)) >= 0)
         sv_setpvn( ST(0), buf, got);

void
SSL_peek(s,max=sizeof(buf))
     SSL *   s
     PREINIT:
     char buf[32768];
     INPUT:
     int     max
     PREINIT:
     int got;
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if ((got = SSL_peek(s, buf, max)) >= 0)
         sv_setpvn( ST(0), buf, got);

int
SSL_write(s,buf)
     SSL *   s
     PREINIT:
     STRLEN len;
     INPUT:
     char *  buf = SvPV( ST(1), len);
     CODE:
     RETVAL = SSL_write (s, buf, (int)len);
     OUTPUT:
     RETVAL

int
SSL_write_partial(s,from,count,buf)
     SSL *   s
     int     from
     int     count
     PREINIT:
     STRLEN len;
     INPUT:
     char *  buf = SvPV( ST(3), len);
     CODE:
      /*
     if (SvROK( ST(3) )) {
       SV* t = SvRV( ST(3) );
       buf = SvPV( t, len);
     } else
       buf = SvPV( ST(3), len);
       */
     PRN("write_partial from",from);
     PRN(&buf[from],len);
     PRN("write_partial count",count);
     len -= from;
     if (len < 0) {
       croak("from beyound end of buffer");
       RETVAL = -1;
     } else
       RETVAL = SSL_write (s, &(buf[from]), (count<=len)?count:len);
     OUTPUT:
     RETVAL

int
SSL_use_RSAPrivateKey(s,rsa)
     SSL *              s
     RSA *              rsa

int
SSL_use_RSAPrivateKey_ASN1(s,d,len)
     SSL *              s
     unsigned char *    d
     long               len

int
SSL_use_RSAPrivateKey_file(s,file,type)
     SSL *              s
     char *             file
     int                type

int
SSL_CTX_use_RSAPrivateKey_file(ctx,file,type)
     SSL_CTX *          ctx
     char *             file
     int                type

int
SSL_use_PrivateKey(s,pkey)
     SSL *              s
     EVP_PKEY *         pkey

int
SSL_use_PrivateKey_ASN1(pk,s,d,len)
     int                pk
     SSL *              s
     unsigned char *    d
     long               len

int
SSL_use_PrivateKey_file(s,file,type)
     SSL *              s
     char *             file
     int                type

int
SSL_CTX_use_PrivateKey_file(ctx,file,type)
     SSL_CTX *          ctx
     char *             file
     int                type

int
SSL_use_certificate(s,x)
     SSL *              s
     X509 *             x

int
SSL_use_certificate_ASN1(s,d,len)
     SSL *              s
     unsigned char *    d
     long               len

int
SSL_use_certificate_file(s,file,type)
     SSL *              s
     char *             file
     int                type

int
SSL_CTX_use_certificate_file(ctx,file,type)
     SSL_CTX *          ctx
     char *             file
     int                type

const char *
SSL_state_string(s)
     SSL *              s

const char *
SSL_rstate_string(s)
     SSL *              s

const char *
SSL_state_string_long(s)
     SSL *              s

const char *
SSL_rstate_string_long(s)
     SSL *              s


long
SSL_get_time(ses)
     SSL_SESSION *      ses

long
SSL_set_time(ses,t)
     SSL_SESSION *      ses
     long               t

long
SSL_get_timeout(ses)
     SSL_SESSION *      ses

long
SSL_set_timeout(ses,t)
     SSL_SESSION *      ses
     long               t

void
SSL_copy_session_id(to,from)
     SSL *              to
     SSL *              from

void
SSL_set_read_ahead(s,yes=1)
     SSL *              s
     int                yes

int
SSL_get_read_ahead(s)
     SSL *              s

int
SSL_pending(s)
     SSL *              s

int
SSL_CTX_set_cipher_list(s,str)
     SSL_CTX *              s
     char *             str

const char *
SSL_get_cipher_list(s,n)
     SSL *              s
     int                n

int
SSL_set_cipher_list(s,str)
     SSL *              s
     char *       str

const char *
SSL_get_cipher(s)
     SSL *              s

char *
SSL_get_shared_ciphers(s,buf,len)
     SSL *              s
     char *             buf
     int                len

X509 *
SSL_get_peer_certificate(s)
     SSL *              s

void
SSL_set_verify(s,mode,callback)
     SSL *              s
     int                mode
     SV *               callback
     CODE:
     if (ssleay_verify_callback == (SV*)NULL)
         ssleay_verify_callback = newSVsv(callback);
     else
         SvSetSV (ssleay_verify_callback, callback);
     if (SvTRUE(ssleay_verify_callback)) {
         SSL_set_verify(s,mode,&ssleay_verify_callback_glue);
     } else {
         SSL_set_verify(s,mode,NULL);
     }

void
SSL_set_bio(s,rbio,wbio)
     SSL *              s
     BIO *              rbio
     BIO *              wbio

BIO *
SSL_get_rbio(s)
     SSL *              s

BIO *
SSL_get_wbio(s)
     SSL *              s


SSL_SESSION *
SSL_SESSION_new()

int
SSL_SESSION_print(fp,ses)
     BIO *              fp
     SSL_SESSION *      ses

void
SSL_SESSION_free(ses)
     SSL_SESSION *      ses

int
i2d_SSL_SESSION(in,pp)
     SSL_SESSION *      in
     unsigned char *    &pp

int
SSL_set_session(to,ses)
     SSL *              to
     SSL_SESSION *      ses

SSL_SESSION *
d2i_SSL_SESSION(a,pp,length)
     SSL_SESSION *      &a
     unsigned char *    &pp
     long               length

#define REM30 "SSLeay-0.9.0 defines these as macros. I expand them here for safety's sake"

SSL_SESSION *
SSL_get_session(s)
     SSL *              s

X509 *
SSL_get_certificate(s)
     SSL *              s

SSL_CTX *
SSL_get_SSL_CTX(s)
     SSL *              s

long
SSL_ctrl(ssl,cmd,larg,parg)
	 SSL * ssl
	 int cmd
	 long larg
	 char * parg

long
SSL_CTX_ctrl(ctx,cmd,larg,parg)
    SSL_CTX * ctx
    int cmd
    long larg
    char * parg

long
SSL_get_options(ssl)
     SSL *          ssl

void
SSL_set_options(ssl,op)
     SSL *          ssl
     unsigned long  op

long
SSL_CTX_get_options(ctx)
     SSL_CTX *      ctx

void
SSL_CTX_set_options(ctx,op)
     SSL_CTX *      ctx
     unsigned long  op

LHASH *
SSL_CTX_sessions(ctx)
     SSL_CTX *          ctx
     CODE:
    /* NOTE: This should be deprecated. Corresponding macro was removed from ssl.h as of 0.9.2 */
     if (ctx == NULL) croak("NULL SSL context passed as argument.");
     RETVAL = ctx -> sessions;
     OUTPUT:
     RETVAL

unsigned long
SSL_CTX_sess_number(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_connect(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_connect_good(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_connect_renegotiate(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_accept(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_accept_renegotiate(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_accept_good(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_hits(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_cb_hits(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_misses(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_timeouts(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_cache_full(ctx)
     SSL_CTX *          ctx

int
SSL_CTX_sess_get_cache_size(ctx)
     SSL_CTX *          ctx

void
SSL_CTX_sess_set_cache_size(ctx,size)
     SSL_CTX *          ctx
     int                size      

int
SSL_want(s)
     SSL *              s

int
SSL_state(s)
     SSL *              s

BIO_METHOD *
BIO_f_ssl()

BIO_METHOD *
BIO_s_mem()

unsigned long
ERR_get_error()

unsigned long
ERR_peek_error()

void
ERR_put_error(lib,func,reason,file,line)
     int                lib
     int                func
     int                reason
     char *             file
     int                line

void
ERR_clear_error()

char *
ERR_error_string(error,buf=NULL)
     unsigned long      error
     char *             buf
     CODE:
     RETVAL = ERR_error_string(error,buf);
     OUTPUT:
     RETVAL

void
SSL_load_error_strings()

void
ERR_load_crypto_strings()

void
SSLeay_add_ssl_algorithms()

void
ERR_load_SSL_strings()

void
ERR_load_RAND_strings()

int
RAND_bytes(buf, num)
    SV *buf
    int num
    PREINIT:
        int rc;
        unsigned char *random;
    CODE:
        New(0, random, num, unsigned char);
        rc = RAND_bytes(random, num);
        sv_setpvn(buf, random, num);
        Safefree(random);
        RETVAL = rc;
    OUTPUT:
        RETVAL

int
RAND_pseudo_bytes(buf, num)
    SV *buf
    int num
    PREINIT:
        int rc;
        unsigned char *random;
    CODE:
        New(0, random, num, unsigned char);
        rc = RAND_pseudo_bytes(random, num);
        sv_setpvn(buf, random, num);
        Safefree(random);
        RETVAL = rc;
    OUTPUT:
        RETVAL

void
RAND_add(buf, num, entropy)
    SV *buf
    int num
    double entropy
    PREINIT:
        STRLEN len;
    CODE:
        RAND_add((const void *)SvPV(buf, len), num, entropy);

int
RAND_poll()

int
RAND_status()

int
RAND_egd_bytes(path, bytes)
    const char *path
    int bytes

SV *
RAND_file_name(num)
    size_t num
    PREINIT:
        char *buf;
    CODE:
        New(0, buf, num, char);
        if (!RAND_file_name(buf, num)) {
            Safefree(buf);
            XSRETURN_UNDEF;
        }
        RETVAL = newSVpv(buf, 0);
        Safefree(buf);
    OUTPUT:
        RETVAL

void
RAND_seed(buf)
     PREINIT:
     STRLEN len;
     INPUT:
     char *  buf = SvPV( ST(1), len);
     CODE:
     RAND_seed (buf, (int)len);

void
RAND_cleanup()

int
RAND_load_file(file_name, how_much)
     char *  file_name
     int     how_much

int
RAND_write_file(file_name)
     char *  file_name

int
RAND_egd(path)
     char *  path

#define REM40 "Minimal X509 stuff..., this is a bit ugly and should be put in its own modules Net::SSLeay::X509.pm"

X509_NAME*
X509_get_issuer_name(cert)
     X509 *      cert

X509_NAME*
X509_get_subject_name(cert)
     X509 *      cert

void
X509_NAME_oneline(name)
     X509_NAME *    name
     PREINIT:
     char buf[32768];
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if (X509_NAME_oneline(name, buf, sizeof(buf)))
         sv_setpvn( ST(0), buf, strlen(buf));

void
X509_NAME_get_text_by_NID(name,nid)
     X509_NAME *    name
     int nid
     PREINIT:
     char buf[32768];
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if (X509_NAME_get_text_by_NID(name, nid, buf, sizeof(buf)))
         sv_setpvn( ST(0), buf, strlen(buf));

X509 *
X509_STORE_CTX_get_current_cert(x509_store_ctx)
     X509_STORE_CTX * 	x509_store_ctx

void *
X509_STORE_CTX_get_ex_data(x509_store_ctx,idx)
     X509_STORE_CTX * x509_store_ctx
     int idx

int
X509_STORE_CTX_get_error(x509_store_ctx)
     X509_STORE_CTX * 	x509_store_ctx

int
X509_STORE_CTX_get_error_depth(x509_store_ctx)
     X509_STORE_CTX * 	x509_store_ctx

int
X509_STORE_CTX_set_ex_data(x509_store_ctx,idx,data)
     X509_STORE_CTX *   x509_store_ctx
     int idx
     void * data

void
X509_STORE_CTX_set_error(x509_store_ctx,s)
     X509_STORE_CTX * x509_store_ctx
     int s

void
X509_STORE_CTX_set_cert(x509_store_ctx,x)
     X509_STORE_CTX * x509_store_ctx
     X509 * x

int 
X509_STORE_add_cert(ctx, x)
    X509_STORE *ctx
    X509 *x

int 
X509_STORE_add_crl(ctx, x)
    X509_STORE *ctx
    X509_CRL *x

void 
X509_STORE_CTX_set_flags(ctx, flags)
    X509_STORE_CTX *ctx
    long flags

int 
X509_load_cert_file(ctx, file, type)
    X509_LOOKUP *ctx
    char *file
    int type

int 
X509_load_crl_file(ctx, file, type)
    X509_LOOKUP *ctx
    char *file
    int type

int 
X509_load_cert_crl_file(ctx, file, type)
    X509_LOOKUP *ctx
    char *file
    int type


ASN1_UTCTIME *
X509_get_notBefore(cert)
     X509 *	cert

ASN1_UTCTIME *
X509_get_notAfter(cert)
     X509 *	cert

void 
P_ASN1_UTCTIME_put2string(tm)
     ASN1_UTCTIME *	tm
     PREINIT:
     BIO *bp;
     int i;
     char buffer[256];
     CODE:
     bp = BIO_new(BIO_s_mem());
     ASN1_UTCTIME_print(bp,tm);
     i = BIO_read(bp,buffer,255);
     buffer[i] = '\0';
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if ( i > 0 )
         sv_setpvn( ST(0), buffer, i );
     BIO_free(bp);

int
EVP_PKEY_copy_parameters(to,from)
     EVP_PKEY *		to
     EVP_PKEY * 	from

void 
PEM_get_string_X509(x509)
     X509 *	x509
     PREINIT:
     BIO *bp;
     int i;
     char buffer[8196];
     CODE:
     bp = BIO_new(BIO_s_mem());
     PEM_write_bio_X509(bp,x509);
     i = BIO_read(bp,buffer,8195);
     buffer[i] = '\0';
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if ( i > 0 )
         sv_setpvn( ST(0), buffer, i );
     BIO_free(bp);

void 
MD5(data)
     PREINIT:
     STRLEN len;
     unsigned char md[MD5_DIGEST_LENGTH];
     unsigned char * ret;
     INPUT:
     unsigned char *  data = (unsigned char *) SvPV( ST(0), len);
     CODE:
     ret = MD5(data,len,md);
     if (ret!=NULL) {
	  XSRETURN_PV((char *) md);
     } else {
	  XSRETURN_UNDEF;
     }

SSL_METHOD *
SSLv2_method()

SSL_METHOD *
SSLv3_method()

SSL_METHOD *
TLSv1_method()

int
SSL_set_ssl_method(ssl, method)
     SSL *          ssl
     SSL_METHOD *   method

SSL_METHOD *
SSL_get_ssl_method(ssl)
     SSL *          ssl

#define REM_AUTOMATICALLY_GENERATED_1_09

BIO *
BIO_new_buffer_ssl_connect(ctx)
     SSL_CTX *	ctx

BIO *
BIO_new_file(filename,mode)
     char * filename
     char * mode

BIO *
BIO_new_ssl(ctx,client)
     SSL_CTX *	ctx
     int 	client

BIO *
BIO_new_ssl_connect(ctx)
     SSL_CTX *	ctx

BIO *
BIO_new(type)
     BIO_METHOD * type;

int
BIO_free(bio)
     BIO * bio;

void
BIO_read(s,max=sizeof(buf))
     BIO *   s
     PREINIT:
     char buf[32768];
     INPUT:
     int     max
     PREINIT:
     int got;
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     if ((got = BIO_read(s, buf, max)) >= 0)
         sv_setpvn( ST(0), buf, got);


int
BIO_write(s,buf)
     BIO *   s
     PREINIT:
     STRLEN len;
     INPUT:
     char *  buf = SvPV( ST(1), len);
     CODE:
     RETVAL = BIO_write (s, buf, (int)len);
     OUTPUT:
     RETVAL

int
BIO_eof(s)
     BIO *   s

int
BIO_pending(s)
     BIO *   s

int
BIO_wpending(s)
     BIO *   s

int 
BIO_ssl_copy_session_id(to,from)
     BIO *	to
     BIO *	from

void 
BIO_ssl_shutdown(ssl_bio)
     BIO *	ssl_bio

int 
SSL_add_client_CA(ssl,x)
     SSL *	ssl
     X509 *	x

const char *
SSL_alert_desc_string(value)
     int 	value

const char *
SSL_alert_desc_string_long(value)
     int 	value

const char *
SSL_alert_type_string(value)
     int 	value

const char *
SSL_alert_type_string_long(value)
     int 	value

long	
SSL_callback_ctrl(ssl,i,fp)
     SSL *  ssl
     int    i
     callback_no_ret * fp

int 
SSL_check_private_key(ctx)
     SSL *	ctx

char *
SSL_CIPHER_description(cipher,buf,size)
     SSL_CIPHER *  cipher
     char *	buf
     int 	size

int	
SSL_CIPHER_get_bits(c,alg_bits)
     SSL_CIPHER *	c
     int *	alg_bits

int 
SSL_COMP_add_compression_method(id,cm)
     int 	id
     COMP_METHOD *	cm

int 
SSL_CTX_add_client_CA(ctx,x)
     SSL_CTX *	ctx
     X509 *	x

long	
SSL_CTX_callback_ctrl(ctx,i,fp)
     SSL_CTX *  ctx
     int        i
     callback_no_ret * fp

int 
SSL_CTX_check_private_key(ctx)
     SSL_CTX *	ctx

void *
SSL_CTX_get_ex_data(ssl,idx)
     SSL_CTX *	ssl
     int 	idx

int 
SSL_CTX_get_quiet_shutdown(ctx)
     SSL_CTX *	ctx

long 
SSL_CTX_get_timeout(ctx)
     SSL_CTX *	ctx

int 
SSL_CTX_get_verify_depth(ctx)
     SSL_CTX *	ctx

int 
SSL_CTX_get_verify_mode(ctx)
     SSL_CTX *	ctx

void 
SSL_CTX_set_cert_store(ctx,store)
     SSL_CTX *     ctx
     X509_STORE *  store

X509_STORE *
SSL_CTX_get_cert_store(ctx)
     SSL_CTX *     ctx

void 
SSL_CTX_set_cert_verify_callback(ctx,cb,arg)
     SSL_CTX *	ctx
     callback_ret_int *  cb
     char *	arg

void 
SSL_CTX_set_client_CA_list(ctx,list)
     SSL_CTX *	ctx
     X509_NAME_STACK * list

void 
SSL_CTX_set_default_passwd_cb(ctx,cb)
    	SSL_CTX *	ctx
	SV * cb
	CODE:
     if (ssleay_ctx_set_default_passwd_cb_callback == (SV*)NULL) {
        ssleay_ctx_set_default_passwd_cb_callback = newSVsv(cb);
     } else {
         SvSetSV (ssleay_ctx_set_default_passwd_cb_callback, cb);
     }
     if (SvTRUE(ssleay_ctx_set_default_passwd_cb_callback)) {
         SSL_CTX_set_default_passwd_cb(ctx,&ssleay_ctx_set_default_passwd_cb_callback_glue);
     } else {
         SSL_CTX_set_default_passwd_cb(ctx,NULL);
     }

void 
SSL_CTX_set_default_passwd_cb_userdata(ctx,u)
     SSL_CTX *	ctx
     void *	u

int 
SSL_CTX_set_ex_data(ssl,idx,data)
     SSL_CTX *	ssl
     int 	idx
     void *	data

int 
SSL_CTX_set_purpose(s,purpose)
     SSL_CTX *	s
     int 	purpose

void 
SSL_CTX_set_quiet_shutdown(ctx,mode)
     SSL_CTX *	ctx
     int 	mode

int 
SSL_CTX_set_ssl_version(ctx,meth)
     SSL_CTX *	ctx
     SSL_METHOD *	meth

long 
SSL_CTX_set_timeout(ctx,t)
     SSL_CTX *	ctx
     long 	t

int 
SSL_CTX_set_trust(s,trust)
     SSL_CTX *	s
     int 	trust

void 
SSL_CTX_set_verify_depth(ctx,depth)
     SSL_CTX *	ctx
     int 	depth

int 
SSL_CTX_use_certificate(ctx,x)
     SSL_CTX *	ctx
     X509 *	x

int	
SSL_CTX_use_certificate_chain_file(ctx,file)
     SSL_CTX *	ctx
     const char * file

int 
SSL_CTX_use_PrivateKey(ctx,pkey)
     SSL_CTX *	ctx
     EVP_PKEY *	pkey

int 
SSL_CTX_use_RSAPrivateKey(ctx,rsa)
     SSL_CTX *	ctx
     RSA *	rsa

int 
SSL_do_handshake(s)
     SSL *	s

SSL *
SSL_dup(ssl)
     SSL *	ssl

SSL_CIPHER *
SSL_get_current_cipher(s)
     SSL *	s

long 
SSL_get_default_timeout(s)
     SSL *	s

void *
SSL_get_ex_data(ssl,idx)
     SSL *	ssl
     int 	idx

size_t 
SSL_get_finished(s,buf,count)
     SSL *	s
     void *	buf
     size_t 	count

size_t 
SSL_get_peer_finished(s,buf,count)
     SSL *	s
     void *	buf
     size_t 	count

int 
SSL_get_quiet_shutdown(ssl)
     SSL *	ssl

int 
SSL_get_shutdown(ssl)
     SSL *	ssl

int	
SSL_get_verify_depth(s)
     SSL *	s

int	
SSL_get_verify_mode(s)
     SSL *	s

long 
SSL_get_verify_result(ssl)
     SSL *	ssl

int 
SSL_library_init()

int 
SSL_renegotiate(s)
     SSL *	s

int	
SSL_SESSION_cmp(a,b)
     SSL_SESSION *	a
     SSL_SESSION *	b

void *
SSL_SESSION_get_ex_data(ss,idx)
     SSL_SESSION *	ss
     int 	idx

long	
SSL_SESSION_get_time(s)
     SSL_SESSION *	s

long	
SSL_SESSION_get_timeout(s)
     SSL_SESSION *	s

int	
SSL_SESSION_print_fp(fp,ses)
     FILE *	fp
     SSL_SESSION *	ses

int 
SSL_SESSION_set_ex_data(ss,idx,data)
     SSL_SESSION *	ss
     int 	idx
     void *	data

long	
SSL_SESSION_set_time(s,t)
     SSL_SESSION *	s
     long 	t

long	
SSL_SESSION_set_timeout(s,t)
     SSL_SESSION *	s
     long 	t

void 
SSL_set_accept_state(s)
     SSL *	s

void 
SSL_set_client_CA_list(s,list)
     SSL *	s
     X509_NAME_STACK *  list

void 
SSL_set_connect_state(s)
     SSL *	s

int 
SSL_set_ex_data(ssl,idx,data)
     SSL *	ssl
     int 	idx
     void *	data

void 
SSL_set_info_callback(ssl,cb)
     SSL *	ssl
     callback_no_ret *  cb

int 
SSL_set_purpose(s,purpose)
     SSL *	s
     int 	purpose

void 
SSL_set_quiet_shutdown(ssl,mode)
     SSL *	ssl
     int 	mode

void 
SSL_set_shutdown(ssl,mode)
     SSL *	ssl
     int 	mode

int 
SSL_set_trust(s,trust)
     SSL *	s
     int 	trust

void
SSL_set_verify_depth(s,depth)
     SSL *	s
     int 	depth

void 
SSL_set_verify_result(ssl,v)
     SSL *	ssl
     long 	v

int 
SSL_shutdown(s)
     SSL *	s

int 
SSL_version(ssl)
     SSL *	ssl

#define REM_MANUALLY_ADDED_1_09

X509_NAME_STACK *
SSL_load_client_CA_file(file)
     const char * file

int	
SSL_add_file_cert_subjects_to_stack(stackCAs,file)
     X509_NAME_STACK * stackCAs
     const char * file

#ifndef WIN32
#ifndef VMS
#ifndef MAC_OS_pre_X

int
SSL_add_dir_cert_subjects_to_stack(stackCAs,dir)
     X509_NAME_STACK * stackCAs
     const char * dir

#endif
#endif
#endif

int
SSL_CTX_get_ex_new_index(argl,argp,new_func,dup_func,free_func)
     long argl
     void *  argp
     CRYPTO_EX_new *   new_func
     CRYPTO_EX_dup *   dup_func
     CRYPTO_EX_free *  free_func

int
SSL_CTX_set_session_id_context(ctx,sid_ctx,sid_ctx_len)
     SSL_CTX *   ctx
     const unsigned char *   sid_ctx
     unsigned int sid_ctx_len

int
SSL_set_session_id_context(ssl,sid_ctx,sid_ctx_len)
     SSL *   ssl
     const unsigned char *   sid_ctx
     unsigned int sid_ctx_len

void
SSL_CTX_set_tmp_rsa_callback(ctx, cb)
     SSL_CTX *   ctx
     cb_ssl_int_int_ret_RSA *   cb

void
SSL_set_tmp_rsa_callback(ssl, cb)
     SSL *   ssl
     cb_ssl_int_int_ret_RSA *  cb

void
SSL_CTX_set_tmp_dh_callback(ctx, dh)
     SSL_CTX *   ctx
     cb_ssl_int_int_ret_DH *  dh

void
SSL_set_tmp_dh_callback(ssl,dh)
     SSL *  ssl
     cb_ssl_int_int_ret_DH *  dh

int
SSL_get_ex_new_index(argl, argp, new_func, dup_func, free_func)
     long argl
     void *   argp
     CRYPTO_EX_new *  new_func
     CRYPTO_EX_dup *  dup_func
     CRYPTO_EX_free * free_func

int
SSL_SESSION_get_ex_new_index(argl, argp, new_func, dup_func, free_func)
     long argl
     void *   argp
     CRYPTO_EX_new *  new_func
     CRYPTO_EX_dup *  dup_func
     CRYPTO_EX_free * free_func

#define REM_SEMIAUTOMATIC_MACRO_GEN_1_09

int 
OpenSSL_add_ssl_algorithms()
  CODE:
  RETVAL = SSL_library_init();
  OUTPUT:
  RETVAL

long
SSL_clear_num_renegotiations(ssl)
  SSL *  ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_CLEAR_NUM_RENEGOTIATIONS,0,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_add_extra_chain_cert(ctx,x509)
     SSL_CTX *	ctx
     X509 *     x509
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_EXTRA_CHAIN_CERT,0,(char*)x509);
  OUTPUT:
  RETVAL

void *
SSL_CTX_get_app_data(ctx)
     SSL_CTX *	ctx
  CODE:
  RETVAL = SSL_CTX_get_ex_data(ctx,0);
  OUTPUT:
  RETVAL

long	
SSL_CTX_get_mode(ctx)
     SSL_CTX *	ctx
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_MODE,0,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_get_read_ahead(ctx)
     SSL_CTX *	ctx
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_GET_READ_AHEAD,0,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_get_session_cache_mode(ctx)
     SSL_CTX *	ctx
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_GET_SESS_CACHE_MODE,0,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_need_tmp_RSA(ctx)
     SSL_CTX *	ctx
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_NEED_TMP_RSA,0,NULL);
  OUTPUT:
  RETVAL

int 
SSL_CTX_set_app_data(ctx,arg)
     SSL_CTX *	ctx
     char *	arg
  CODE:
  RETVAL = SSL_CTX_set_ex_data(ctx,0,arg);
  OUTPUT:
  RETVAL

long	
SSL_CTX_set_mode(ctx,op)
     SSL_CTX *	ctx
     long 	op
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_MODE,op,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_set_read_ahead(ctx,m)
     SSL_CTX *	ctx
     long 	m
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_SET_READ_AHEAD,m,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_set_session_cache_mode(ctx,m)
     SSL_CTX *	ctx
     long 	m
  CODE:
  RETVAL = SSL_CTX_ctrl(ctx,SSL_CTRL_SET_SESS_CACHE_MODE,m,NULL);
  OUTPUT:
  RETVAL

long	
SSL_CTX_set_tmp_dh(ctx,dh)
     SSL_CTX *	ctx
     DH *	dh

long	
SSL_CTX_set_tmp_rsa(ctx,rsa)
     SSL_CTX *	ctx
     RSA *	rsa

void *
SSL_get_app_data(s)
     SSL *	s
  CODE:
  RETVAL = SSL_get_ex_data(s,0);
  OUTPUT:
  RETVAL

int	
SSL_get_cipher_bits(s,np)
     SSL *	s
     int *	np
  CODE:
  RETVAL = SSL_CIPHER_get_bits(SSL_get_current_cipher(s),np);
  OUTPUT:
  RETVAL

long	
SSL_get_mode(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_MODE,0,NULL);
  OUTPUT:
  RETVAL

int 
SSL_get_state(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_state(ssl);
  OUTPUT:
  RETVAL

long	
SSL_need_tmp_RSA(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_NEED_TMP_RSA,0,NULL);
  OUTPUT:
  RETVAL

long	
SSL_num_renegotiations(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_GET_NUM_RENEGOTIATIONS,0,NULL);
  OUTPUT:
  RETVAL

void *
SSL_SESSION_get_app_data(ses)
     SSL_SESSION *	ses
  CODE:
  RETVAL = SSL_SESSION_get_ex_data(ses,0);
  OUTPUT:
  RETVAL

long	
SSL_session_reused(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_GET_SESSION_REUSED,0,NULL);
  OUTPUT:
  RETVAL

int 
SSL_SESSION_set_app_data(s,a)
     SSL_SESSION *	s
     void *	a
  CODE:
  RETVAL = SSL_SESSION_set_ex_data(s,0,(char *)a);
  OUTPUT:
  RETVAL

int 
SSL_set_app_data(s,arg)
     SSL *	s
     void *	arg
  CODE:
  RETVAL = SSL_set_ex_data(s,0,(char *)arg);
  OUTPUT:
  RETVAL

long	
SSL_set_mode(ssl,op)
     SSL *	ssl
     long 	op
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_MODE,op,NULL);
  OUTPUT:
  RETVAL

int	
SSL_set_pref_cipher(s,n)
     SSL *	s
     const char * n
  CODE:
  RETVAL = SSL_set_cipher_list(s,n);
  OUTPUT:
  RETVAL

long	
SSL_set_tmp_dh(ssl,dh)
     SSL *	ssl
     char *	dh
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_SET_TMP_DH,0,(char *)dh);
  OUTPUT:
  RETVAL

long	
SSL_set_tmp_rsa(ssl,rsa)
     SSL *	ssl
     char *	rsa
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_SET_TMP_RSA,0,(char *)rsa);
  OUTPUT:
  RETVAL

RSA *
RSA_generate_key(bits,e,callback=NULL,cb_arg=NULL)
    int           bits
    unsigned long e
    void *        callback
    void *        cb_arg

void
RSA_free(r)
    RSA * r

void
X509_free(a)
    X509 * a

DH *
PEM_read_bio_DHparams(bio,x=NULL,cb=NULL,u=NULL)
	BIO  * bio
	void * x
	void * cb
	void * u

X509_CRL *
PEM_read_bio_X509_CRL(bio,x=NULL,cb=NULL,u=NULL)
	BIO  * bio
	void * x
	void * cb
	void * u

void
DH_free(dh)
	DH * dh

long
SSL_total_renegotiations(ssl)
     SSL *	ssl
  CODE:
  RETVAL = SSL_ctrl(ssl,SSL_CTRL_GET_TOTAL_RENEGOTIATIONS,0,NULL);
  OUTPUT:
  RETVAL

void
SSL_SESSION_get_master_key(s)
     SSL_SESSION *   s
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     sv_setpvn(ST(0), s->master_key, s->master_key_length);

void
SSL_get_client_random(s)
     SSL *   s
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     sv_setpvn(ST(0), s->s3->client_random, SSL3_RANDOM_SIZE);

void
SSL_get_server_random(s)
     SSL *   s
     CODE:
     ST(0) = sv_newmortal();   /* Undefined to start with */
     sv_setpvn(ST(0), s->s3->server_random, SSL3_RANDOM_SIZE);


#define REM_EOF "/* EOF - SSLeay.xs */"
