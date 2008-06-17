#include "mod_perl.h"
#include "mod_perl_xs.h"

typedef struct {
    uri_components uri;
    pool *pool;
    request_rec *r;
    char *path_info;
} XS_Apache__URI;

typedef XS_Apache__URI * Apache__URI;

MODULE = Apache::URI		PACKAGE = Apache

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

Apache::URI
parsed_uri(r)
    Apache r

    CODE:
    RETVAL = (Apache__URI)safemalloc(sizeof(XS_Apache__URI));
    RETVAL->uri = r->parsed_uri;
    RETVAL->pool = r->pool; 
    RETVAL->r = r;
    RETVAL->path_info = r->path_info;

    OUTPUT:
    RETVAL

MODULE = Apache::URI		PACKAGE = Apache::URI		

void
DESTROY(uri)
    Apache::URI uri

    CODE:
    safefree(uri);

Apache::URI
parse(self, r, uri=NULL)
    SV *self
    Apache r
    const char *uri

    PREINIT:
    int self_uri = 0;

    CODE:
    self = self; /* -Wall */ 
    RETVAL = (Apache__URI)safemalloc(sizeof(XS_Apache__URI));
    if(!uri) {
	uri = ap_construct_url(r->pool, r->uri, r);
	self_uri = 1;
    }
    (void)ap_parse_uri_components(r->pool, uri, &RETVAL->uri);
    RETVAL->pool = r->pool;
    RETVAL->r = r;
    RETVAL->path_info = NULL;
    if(self_uri) 
	RETVAL->uri.query = r->args;

    OUTPUT:
    RETVAL

char *
unparse(uri, flags=UNP_OMITPASSWORD)
    Apache::URI uri
    unsigned flags

    CODE:
    RETVAL = ap_unparse_uri_components(uri->pool, &uri->uri, flags);

    OUTPUT:
    RETVAL

SV *
rpath(uri)
    Apache::URI uri

    CODE:
    RETVAL = Nullsv;

    if(uri->path_info) {
	int uri_len = strlen(uri->uri.path);
        int n = strlen(uri->path_info);
	int set = uri_len - n;
	if(set > 0)
	    RETVAL = newSVpv(uri->uri.path, set);
    } 
    else
        RETVAL = newSVpv(uri->uri.path, 0);

    OUTPUT:
    RETVAL 

char *
scheme(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.scheme,uri->pool);

    OUTPUT:
    RETVAL 

char *
hostinfo(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.hostinfo,uri->pool);

    OUTPUT:
    RETVAL 

char *
user(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.user,uri->pool);

    OUTPUT:
    RETVAL 

char *
password(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.password,uri->pool);

    OUTPUT:
    RETVAL 

char *
hostname(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.hostname,uri->pool);

    OUTPUT:
    RETVAL 

char *
path(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.path,uri->pool);

    OUTPUT:
    RETVAL 

char *
query(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.query,uri->pool);

    OUTPUT:
    RETVAL 

char *
fragment(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.fragment,uri->pool);

    OUTPUT:
    RETVAL 

char *
port(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->uri.port_str,uri->pool);
    if (items > 1) {
        uri->uri.port = (int)SvIV(ST(1));
    }

    OUTPUT:
    RETVAL 

char *
path_info(uri, ...)
    Apache::URI uri

    CODE:
    get_set_PVp(uri->path_info,uri->pool);

    OUTPUT:
    RETVAL 

            
