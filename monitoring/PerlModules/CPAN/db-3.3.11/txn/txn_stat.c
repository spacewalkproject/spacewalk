/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: txn_stat.c,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <string.h>
#endif

#ifdef  HAVE_RPC
#include "db_server.h"
#endif

#include "db_int.h"
#include "txn.h"

#ifdef HAVE_RPC
#include "rpc_client_ext.h"
#endif

/*
 * txn_stat --
 *
 * EXTERN: int txn_stat __P((DB_ENV *, DB_TXN_STAT **));
 */
int
txn_stat(dbenv, statp)
	DB_ENV *dbenv;
	DB_TXN_STAT **statp;
{
	DB_TXNMGR *mgr;
	DB_TXNREGION *region;
	DB_TXN_STAT *stats;
	TXN_DETAIL *txnp;
	size_t nbytes;
	u_int32_t ndx;
	int ret;

#ifdef HAVE_RPC
	if (F_ISSET(dbenv, DB_ENV_RPCCLIENT))
		return (__dbcl_txn_stat(dbenv, statp));
#endif

	PANIC_CHECK(dbenv);
	ENV_REQUIRES_CONFIG(dbenv, dbenv->tx_handle, "txn_stat", DB_INIT_TXN);

	*statp = NULL;

	mgr = dbenv->tx_handle;
	region = mgr->reginfo.primary;

	/*
	 * Allocate for the maximum active transactions -- the DB_TXN_ACTIVE
	 * struct is small and the maximum number of active transactions is
	 * not going to be that large.  Don't have to lock anything to look
	 * at the region's maximum active transactions value, it's read-only
	 * and never changes after the region is created.
	 */
	nbytes = sizeof(DB_TXN_STAT) + sizeof(DB_TXN_ACTIVE) * region->maxtxns;
	if ((ret = __os_umalloc(dbenv, nbytes, &stats)) != 0)
		return (ret);

	R_LOCK(dbenv, &mgr->reginfo);
	stats->st_last_txnid = region->last_txnid;
	stats->st_last_ckp = region->last_ckp;
	stats->st_maxtxns = region->maxtxns;
	stats->st_naborts = region->naborts;
	stats->st_nbegins = region->nbegins;
	stats->st_ncommits = region->ncommits;
	stats->st_nrestores = region->nrestores;
	stats->st_pending_ckp = region->pending_ckp;
	stats->st_time_ckp = region->time_ckp;
	stats->st_nactive = region->nactive;
	stats->st_maxnactive = region->maxnactive;
	stats->st_txnarray = (DB_TXN_ACTIVE *)&stats[1];

	ndx = 0;
	for (txnp = SH_TAILQ_FIRST(&region->active_txn, __txn_detail);
	    txnp != NULL;
	    txnp = SH_TAILQ_NEXT(txnp, links, __txn_detail)) {
		stats->st_txnarray[ndx].txnid = txnp->txnid;
		if (txnp->parent == INVALID_ROFF)
			stats->st_txnarray[ndx].parentid = TXN_INVALID_ID;
		else
			stats->st_txnarray[ndx].parentid =
			    ((TXN_DETAIL *)R_ADDR(&mgr->reginfo,
			    txnp->parent))->txnid;
		stats->st_txnarray[ndx].lsn = txnp->begin_lsn;
		ndx++;
	}

	stats->st_region_wait = mgr->reginfo.rp->mutex.mutex_set_wait;
	stats->st_region_nowait = mgr->reginfo.rp->mutex.mutex_set_nowait;
	stats->st_regsize = mgr->reginfo.rp->size;

	R_UNLOCK(dbenv, &mgr->reginfo);

	*statp = stats;
	return (0);
}
