/* SSLeay.xs - Perl module for using Eric Young's implementation of SSL
 *
 * Copyright (c) 1996-1999 Sampo Kellomaki <sampo@iki.fi>
 * All Rights Reserved.
 *
 * 19.6.1998, Maintenance release to sync with SSLeay-0.9.0, --Sampo
 * 24.6.1998, added write_partial to support ssl_write_all in more
 *            memory efficient way. --Sampo
 * 8.7.1998,  Added SSL_(CTX)?_set_options and associated constants.
 * 31.3.1999, Tracking OpenSSL-0.9.2b changes, dropping support for
 *            earlier versions
 * 30.7.1999, Tracking OpenSSL-0.9.3a changes, --Sampo
 * 
 * The distribution and use of this module are subject to the conditions
 * listed in COPYRIGHT file at the root of Eric Young's SSLeay-0.9.0
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
#include <openssl/buffer.h>
#include <openssl/ssl.h>

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
constant(name, arg)
char *name;
int arg;
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

/* ============= callback stuff ============== */

static SV * ssleay_verify_callback = (SV*)NULL;

static int
ssleay_verify_callback_glue (int ok, X509_STORE_CTX* ctx)
{
	dSP ;
	int count;
	
	ENTER ;
	SAVETMPS;

	PRN("verify callback glue", ok);

	PUSHMARK(sp);
	XPUSHs(sv_2mortal(newSViv(ok)));
	XPUSHs(sv_2mortal(newSViv((int)ctx)));
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

	PUTBACK ;
	FREETMPS ;
	LEAVE ;
	
	return POPi;
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
	XPUSHs(sv_2mortal(newSViv((int)ctx)));
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

MODULE = Net::SSLeay		PACKAGE = Net::SSLeay          PREFIX = SSL_

PROTOTYPES: ENABLE

double
constant(name,arg)
     char *		name
     int		arg

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

char *
SSL_state_string(s)
     SSL *              s

char *
SSL_rstate_string(s)
     SSL *              s

char *
SSL_state_string_long(s)
     SSL *              s

char *
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

char *
SSL_get_cipher_list(s,n)
     SSL *              s
     int                n

int
SSL_set_cipher_list(s,str)
     SSL *              s
     char *       str

char *
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

#define REM_EOF "/* EOF - SSLeay.xs */"
