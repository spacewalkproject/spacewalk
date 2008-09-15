/^#include <netinet.in.h>/a\
\
#include "db_int.h"\
#include "db_server_int.h"\
#include "rpc_server_ext.h"
/^	return;/i\
\	__dbsrv_timeout(0);
s/^main/void __dbsrv_main/
