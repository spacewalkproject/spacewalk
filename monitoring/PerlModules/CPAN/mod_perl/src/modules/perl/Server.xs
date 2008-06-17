#define CORE_PRIVATE 
#include "mod_perl.h" 

typedef struct {
    request_rec *r;
    SV *cv;
    int refcnt;
} srv_cleanup_t;

static void srv_cleanup_handler(void *data)
{
    srv_cleanup_t *srv = (srv_cleanup_t*)data;
    (void)acquire_mutex(mod_perl_mutex);
    perl_call_handler(srv->cv, srv->r, Nullav);
    if(srv->refcnt) SvREFCNT_dec(srv->cv);
    (void)release_mutex(mod_perl_mutex);
}

static void ApacheServer_register_cleanup(SV *self, SV *cv)
{
    pool *p = perl_get_startup_pool();
    server_rec *s;
    srv_cleanup_t *srv = (srv_cleanup_t *)palloc(p, sizeof(srv_cleanup_t));

    if(SvROK(self) && sv_derived_from(self, "Apache::Server")) 
        s = (server_rec *)SvIV((SV*)SvRV(self));
    else 
	s = perl_get_startup_server();
    srv->r = mp_fake_request_rec(s, p, "Apache::Server::register_cleanup");
    srv->cv = cv;
    if(SvREFCNT(srv->cv) == 1) {
	srv->refcnt = 1;
	SvREFCNT_inc(srv->cv);
    }
    else
	srv->refcnt = 0;
    register_cleanup(p, srv, srv_cleanup_handler, mod_perl_noop);
}

MODULE = Apache::Server  PACKAGE = Apache::Server   PREFIX = ApacheServer_

void
ApacheServer_register_cleanup(self, cv)
    SV *self
    SV *cv

PROTOTYPES: DISABLE

BOOT: 
    items = items; /*avoid warning*/  

#/* Per-vhost config... */

#struct server_rec {

#  server_rec *next;
  
#  /* Full locations of server config info */
  
#  char *srm_confname;
#  char *access_confname;
  
#  /* Contact information */
  
#  char *server_admin;
#  char *server_hostname;
#  short port;                    /* for redirects, etc. */

Apache::Server
next(server)
    Apache::Server	server

    CODE:
    if(!(RETVAL = server->next)) XSRETURN_UNDEF;

    OUTPUT:
    RETVAL

char *
server_admin(server, ...)
    Apache::Server	server

    CODE:
    RETVAL = server->server_admin;

    OUTPUT:
    RETVAL

char *
server_hostname(server)
    Apache::Server	server

    CODE:
    RETVAL = server->server_hostname;

    OUTPUT:
    RETVAL

short
port(server, ...)
    Apache::Server	server

    CODE:
    RETVAL = server->port;

    if(items > 1)
        server->port = (short)SvIV(ST(1));

    OUTPUT:
    RETVAL
  
#  /* Log files --- note that transfer log is now in the modules... */
  
#  char *error_fname;
#  FILE *error_log;

#  /* Module-specific configuration for server, and defaults... */

#  int is_virtual;               /* true if this is the virtual server */
#  void *module_config;		/* Config vector containing pointers to
#				 * modules' per-server config structures.
#				 */
#  void *lookup_defaults;	/* MIME type info, etc., before we start
#				 * checking per-directory info.
#				 */
#  /* Transaction handling */

#  struct in_addr host_addr;	/* The bound address, for this server */
#  short host_port;              /* The bound port, for this server */
#  int timeout;			/* Timeout, in seconds, before we give up */
#  int keep_alive_timeout;	/* Seconds we'll wait for another request */
#  int keep_alive_max;		/* Maximum requests per connection */
#  int keep_alive;		/* Use persistent connections? */

#  char *names;			/* Wildcarded names for HostAlias servers */
#  char *virthost;		/* The name given in <VirtualHost> */

char *
error_fname(server)
    Apache::Server	server

    CODE:
    RETVAL = server->error_fname;

    OUTPUT:
    RETVAL

int
timeout(server, set=0)
    Apache::Server	server
    int set

    CODE:
    RETVAL = server->timeout;

    if (set) {
	server->timeout = set;
    }

    OUTPUT:
    RETVAL

uid_t
uid(server)
    Apache::Server	server

    CODE:
    RETVAL = server->server_uid;

    OUTPUT:
    RETVAL

gid_t
gid(server)
    Apache::Server	server

    CODE:
    RETVAL = server->server_gid;

    OUTPUT:
    RETVAL

int
is_virtual(server)
    Apache::Server	server

    CODE:
    RETVAL = server->is_virtual;

    OUTPUT:
    RETVAL

void
names(server)
    Apache::Server	server

    CODE:
#if MODULE_MAGIC_NUMBER < 19980305
    ST(0) = sv_2mortal(newSVpv(server->names,0));
#else
    ST(0) = array_header2avrv(server->names);
#endif

