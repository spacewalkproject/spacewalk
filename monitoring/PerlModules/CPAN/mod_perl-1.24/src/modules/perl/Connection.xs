#define CORE_PRIVATE 
#include "mod_perl.h" 

MODULE = Apache::Connection  PACKAGE = Apache::Connection

PROTOTYPES: DISABLE

BOOT: 
    items = items; /*avoid warning*/  

#/* Things which are per connection
# */

#struct conn_rec {

#  pool *pool;
#  server_rec *server;
  
#  /* Information about the connection itself */
  
#  BUFF *client;			/* Connetion to the guy */
#  int aborted;			/* Are we still talking? */
  
#  /* Who is the client? */
  
#  struct sockaddr_in local_addr; /* local address */
#  struct sockaddr_in remote_addr;/* remote address */
#  char *remote_ip;		/* Client's IP address */
#  char *remote_host;		/* Client's DNS name, if known.
#                                 * NULL if DNS hasn't been checked,
#                                 * "" if it has and no address was found.
#                                 * N.B. Only access this though
#				 * get_remote_host() */

int
fileno(conn, ...)
    Apache::Connection	conn

    PREINIT:
    int sts = 1;	/* default is output fd */

    CODE:
    if(items > 1) {
        sts = (int)SvIV(ST(1));
    }
    RETVAL = ap_bfileno(conn->client, sts ? B_WR : B_RD);

    OUTPUT:
    RETVAL

int
aborted(conn)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->aborted;

    OUTPUT:
    RETVAL

SV *
local_addr(conn)
    Apache::Connection        conn

    CODE:
    RETVAL = newSVpv((char *)&conn->local_addr,
		     sizeof conn->local_addr);

    OUTPUT:
    RETVAL

SV *
remote_addr(conn, sv_addr=Nullsv)
    Apache::Connection        conn
    SV *sv_addr

    CODE:
    RETVAL = newSVpv((char *)&conn->remote_addr,
                      sizeof conn->remote_addr);
    if(sv_addr) {
        struct sockaddr_in addr; 
        STRLEN sockaddrlen; 
        char * new_addr = SvPV(sv_addr,sockaddrlen); 
        if (sockaddrlen != sizeof(addr)) { 
            croak("Bad arg length for remote_addr, length is %d, should be %d", 		  sockaddrlen, sizeof(addr)); 
        } 
        Copy(new_addr, &addr, sizeof addr, char); 
        conn->remote_addr = addr;
    }

    OUTPUT:
    RETVAL

char *
remote_ip(conn, ...)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->remote_ip;
 
    if(items > 1) {
#ifdef SGI_BOOST
        ap_cpystrn(conn->remote_ip, (char *)SvPV(ST(1),na),
                   sizeof(conn->remote_ip));
        conn->remote_ip_len = strlen(conn->remote_ip);
#else
        conn->remote_ip = pstrdup(conn->pool, (char *)SvPV(ST(1),na));
#endif
        conn->remote_addr.sin_addr.s_addr = inet_addr(conn->remote_ip);
    }

    OUTPUT:
    RETVAL

char *
remote_host(conn, ...)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->remote_host;

    if(items > 1)
         conn->remote_host = pstrdup(conn->pool, (char *)SvPV(ST(1),na));

    OUTPUT:
    RETVAL

#  char *remote_logname;		/* Only ever set if doing_rfc931
#                                 * N.B. Only access this through
#				 * get_remote_logname() */
#    char *user;			/* If an authentication check was made,
#				 * this gets set to the user name.  We assume
#				 * that there's only one user per connection(!)
#				 */
#  char *auth_type;		/* Ditto. */

char *
remote_logname(conn)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->remote_logname;

    OUTPUT:
    RETVAL

char *
user(conn, ...)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->user;

    if(items > 1)
        conn->user = pstrdup(conn->pool, (char *)SvPV(ST(1),na));

    OUTPUT:
    RETVAL

char *
auth_type(conn, ...)
    Apache::Connection	conn

    CODE:
    RETVAL = conn->auth_type;

    if(items > 1)
        conn->auth_type = pstrdup(conn->pool, (char *)SvPV(ST(1),na));

    OUTPUT:
    RETVAL

#  int keepalive;		/* Are we using HTTP Keep-Alive? */
#  int keptalive;		/* Did we use HTTP Keep-Alive? */
#  int keepalives;		/* How many times have we used it? */
#};


