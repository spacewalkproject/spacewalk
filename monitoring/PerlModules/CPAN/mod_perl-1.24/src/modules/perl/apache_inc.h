#ifdef JW_PERL_OBJECT

#ifdef uid_t
#define apache_uid_t uid_t
#undef uid_t
#endif
#define uid_t apache_uid_t

#ifdef gid_t
#define apache_gid_t gid_t
#undef gid_t
#endif
#define gid_t apache_gid_t

#ifdef mode_t
#define apache_mode_t mode_t
#undef mode_t
#endif
#define mode_t apache_mode_t

#ifdef sleep
#define apache_sleep sleep
#undef sleep
#endif

#ifdef stat
#define apache_stat stat
#undef stat
#endif

#ifdef opendir
#define apache_opendir opendir
#undef opendir
#endif

#ifdef pool
#undef pool
#endif

#endif

#ifdef WIN32

#ifdef uid_t
#define apache_uid_t uid_t
#undef uid_t
#endif
#define uid_t apache_uid_t

#ifdef gid_t
#define apache_gid_t gid_t
#undef gid_t
#endif
#define gid_t apache_gid_t

#ifdef mode_t
#define apache_mode_t mode_t
#undef mode_t
#endif
#define mode_t apache_mode_t

#ifdef stat
#define apache_stat stat
#undef stat
#endif

#ifdef sleep
#define apache_sleep sleep
#undef sleep
#endif

#ifdef PERL_IS_5_6

#ifdef opendir
#define apache_opendir opendir
#undef opendir
#endif

#ifdef readdir
#define apache_readdir readdir
#undef readdir
#endif

#ifdef closedir
#define apache_closedir closedir
#undef closedir
#endif

#ifdef crypt
#define apache_crypt crypt
#undef crypt
#endif

#ifdef errno
#define apache_errno errno
#undef errno
#endif

#endif /* endif PERL_IS_56 */ 

#endif /* endif WIN32 */

#ifndef _INCLUDE_APACHE_FIRST
#ifdef __cplusplus
extern "C" {
#endif

/* sfio */
#if !defined(PERLIO_IS_STDIO) && defined(HASATTRIBUTE)
# undef printf
#endif

#include "httpd.h" 
#include "http_config.h" 
#include "http_protocol.h" 
#include "http_log.h" 
#include "http_main.h" 
#include "http_core.h" 
#include "http_request.h" 
#include "util_script.h" 
#include "http_conf_globals.h"
#include "http_vhost.h"

/* sfio */
#if !defined(PERLIO_IS_STDIO) && defined(HASATTRIBUTE)
# define printf PerlIO_stdoutf
#endif

#if defined(APACHE_SSL) || defined(MOD_SSL)
#undef _
#ifdef _config_h_
#ifdef CAN_PROTOTYPE
#define _(args) args
#else
#define _(args) ()
#endif
#endif
#endif
#ifdef __cplusplus
}
#endif
#endif

#ifdef JW_PERL_OBJECT

#undef uid_t
#ifdef apache_uid_t
#define uid_t apache_uid_t
#undef apache_uid_t
#endif

#undef gid_t
#ifdef apache_gid_t
#define gid_t apache_gid_t
#undef apache_gid_t
#endif

#undef mode_t
#ifdef apache_mode_t
#define gid_t apache_mode_t
#undef apache_mode_t
#endif

#ifdef apache_sleep
#undef sleep
#define sleep apache_sleep
#undef apache_sleep
#endif

#ifdef apache_stat
#undef stat
#define stat apache_stat
#undef apache_stat
#endif

#ifdef apache_opendir
#undef opendir
#define opendir apache_opendir
#undef apache_opendir
#endif

#endif

#ifdef WIN32

#undef uid_t
#ifdef apache_uid_t
#define uid_t apache_uid_t
#undef apache_uid_t
#endif

#undef gid_t
#ifdef apache_gid_t
#define gid_t apache_gid_t
#undef apache_gid_t
#endif

#undef mode_t
#ifdef apache_mode_t
#define gid_t apache_mode_t
#undef apache_mode_t
#endif

#ifdef apache_stat
#undef stat
#define stat apache_stat
#undef apache_stat
#endif

#ifdef apache_sleep
#undef sleep
#define sleep apache_sleep
#undef apache_sleep
#endif

#ifdef PERL_IS_5_6

#ifdef apache_opendir
#undef opendir
#define opendir apache_opendir
#undef apache_opendir
#endif

#ifdef apache_readdir
#undef readdir
#define readdir apache_readdir
#undef apache_readdir
#endif

#ifdef apache_closedir
#undef closedir
#define closedir apache_closedir
#undef apache_closedir
#endif

#ifdef apache_crypt
#undef crypt
#define crypt apache_crypt
#undef apache_crypt
#endif

#endif /* endif PERL_IS_5_6 */

#endif /* endif WIN32 */

