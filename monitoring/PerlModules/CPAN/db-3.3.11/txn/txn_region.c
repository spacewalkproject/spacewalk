/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: txn_region.c,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#if TIME_WITH_SYS_TIME
#include <sys/time.h>
#include <time.h>
#else
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#else
#include <time.h>
#endif
#endif

#include <string.h>
#endif

#ifdef  HAVE_RPC
#include "db_server.h"
#endif

#include "db_int.h"
#include "db_page.h"
#include "log.h"
#include "txn.h"

#ifdef HAVE_RPC
#include "rpc_client_ext.h"
#endif

static int __txn_init __P((DB_ENV *, DB_TXNMGR *));
static size_t __txn_region_size __P((DB_ENV *));
static int __txn_set_tx_max __P((DB_ENV *, u_int32_t));
static int __txn_set_tx_recover __P((DB_ENV *,
	       int (*)(DB_ENV *, DBT *, DB_LSN *, db_recops)));
static int __txn_set_tx_timestamp __P((DB_ENV *, time_t *));

/*
 * __txn_dbenv_create --
 *	Transaction specific initialization of the DB_ENV structure.
 *
 * PUBLIC: void __txn_dbenv_create __P((DB_ENV *));
 */
void
__txn_dbenv_create(dbenv)
	DB_ENV *dbenv;
{
	dbenv->tx_max = DEF_MAX_TXNS;

	dbenv->set_tx_max = __txn_set_tx_max;
	dbenv->set_tx_recover = __txn_set_tx_recover;
	dbenv->set_tx_timestamp = __txn_set_tx_timestamp;

#ifdef HAVE_RPC
	/*
	 * If we have a client, overwrite what we just setup to point to
	 * client functions.
	 */
	if (F_ISSET(dbenv, DB_ENV_RPCCLIENT)) {
		dbenv->set_tx_max = __dbcl_set_tx_max;
		dbenv->set_tx_recover = __dbcl_set_tx_recover;
		dbenv->set_tx_timestamp = __dbcl_set_tx_timestamp;
	}
#endif
}

/*
 * __txn_set_tx_max --
 *	Set the size of the transaction table.
 */
static int
__txn_set_tx_max(dbenv, tx_max)
	DB_ENV *dbenv;
	u_int32_t tx_max;
{
	ENV_ILLEGAL_AFTER_OPEN(dbenv, "set_tx_max");

	dbenv->tx_max = tx_max;
	return (0);
}

/*
 * __txn_set_tx_recover --
 *	Set the transaction abort recover function.
 */
static int
__txn_set_tx_recover(dbenv, tx_recover)
	DB_ENV *dbenv;
	int (*tx_recover) __P((DB_ENV *, DBT *, DB_LSN *, db_recops));
{
	dbenv->tx_recover = tx_recover;
	return (0);
}

/*
 * __txn_set_tx_timestamp --
 *	Set the transaction recovery timestamp.
 */
static int
__txn_set_tx_timestamp(dbenv, timestamp)
	DB_ENV *dbenv;
	time_t *timestamp;
{
	ENV_ILLEGAL_AFTER_OPEN(dbenv, "set_tx_timestamp");

	dbenv->tx_timestamp = *timestamp;
	return (0);
}

/*
 * __txn_open --
 *	Open a transaction region.
 *
 * PUBLIC: int __txn_open __P((DB_ENV *));
 */
int
__txn_open(dbenv)
	DB_ENV *dbenv;
{
	DB_TXNMGR *tmgrp;
	int ret;

	/* Create/initialize the transaction manager structure. */
	if ((ret = __os_calloc(dbenv, 1, sizeof(DB_TXNMGR), &tmgrp)) != 0)
		return (ret);
	TAILQ_INIT(&tmgrp->txn_chain);
	tmgrp->dbenv = dbenv;

	/* Join/create the txn region. */
	tmgrp->reginfo.type = REGION_TYPE_TXN;
	tmgrp->reginfo.id = INVALID_REGION_ID;
	tmgrp->reginfo.mode = dbenv->db_mode;
	tmgrp->reginfo.flags = REGION_JOIN_OK;
	if (F_ISSET(dbenv, DB_ENV_CREATE))
		F_SET(&tmgrp->reginfo, REGION_CREATE_OK);
	if ((ret = __db_r_attach(dbenv,
	    &tmgrp->reginfo, __txn_region_size(dbenv))) != 0)
		goto err;

	/* If we created the region, initialize it. */
	if (F_ISSET(&tmgrp->reginfo, REGION_CREATE))
		if ((ret = __txn_init(dbenv, tmgrp)) != 0)
			goto err;

	/* Set the local addresses. */
	tmgrp->reginfo.primary =
	    R_ADDR(&tmgrp->reginfo, tmgrp->reginfo.rp->primary);

	/* Acquire a mutex to protect the active TXN list. */
	if (F_ISSET(dbenv, DB_ENV_THREAD)) {
		if ((ret = __db_mutex_alloc(
		    dbenv, &tmgrp->reginfo, 1, &tmgrp->mutexp)) != 0)
			goto err;
		if ((ret = __db_shmutex_init(dbenv, tmgrp->mutexp, 0,
		    MUTEX_THREAD, &tmgrp->reginfo,
		    (REGMAINT *)R_ADDR(&tmgrp->reginfo,
		    ((DB_TXNREGION *)tmgrp->reginfo.primary)->maint_off))) != 0)
			goto err;
	}

	R_UNLOCK(dbenv, &tmgrp->reginfo);

	dbenv->tx_handle = tmgrp;
	return (0);

err:	if (tmgrp->reginfo.addr != NULL) {
		if (F_ISSET(&tmgrp->reginfo, REGION_CREATE))
			ret = __db_panic(dbenv, ret);
		R_UNLOCK(dbenv, &tmgrp->reginfo);

		(void)__db_r_detach(dbenv, &tmgrp->reginfo, 0);
	}
	if (tmgrp->mutexp != NULL)
		__db_mutex_free(dbenv, &tmgrp->reginfo, tmgrp->mutexp);
	__os_free(dbenv, tmgrp, sizeof(*tmgrp));
	return (ret);
}

/*
 * __txn_init --
 *	Initialize a transaction region in shared memory.
 */
static int
__txn_init(dbenv, tmgrp)
	DB_ENV *dbenv;
	DB_TXNMGR *tmgrp;
{
	DB_LSN last_ckp;
	DB_TXNREGION *region;
	int ret;
#ifdef	MUTEX_SYSTEM_RESOURCES
	u_int8_t *addr;
#endif

	ZERO_LSN(last_ckp);
	/*
	 * If possible, fetch the last checkpoint LSN from the log system
	 * so that the backwards chain of checkpoints is unbroken when
	 * the environment is removed and recreated. [#2865]
	 */
	if (LOGGING_ON(dbenv) && (ret = __log_lastckp(dbenv, &last_ckp)) != 0)
		return (ret);

	if ((ret = __db_shalloc(tmgrp->reginfo.addr,
	    sizeof(DB_TXNREGION), 0, &tmgrp->reginfo.primary)) != 0) {
		__db_err(dbenv,
		    "Unable to allocate memory for the transaction region");
		return (ret);
	}
	tmgrp->reginfo.rp->primary =
	    R_OFFSET(&tmgrp->reginfo, tmgrp->reginfo.primary);
	region = tmgrp->reginfo.primary;
	memset(region, 0, sizeof(*region));

	region->maxtxns = dbenv->tx_max;
	region->last_txnid = TXN_MINIMUM;
	ZERO_LSN(region->pending_ckp);
	region->last_ckp = last_ckp;
	region->time_ckp = time(NULL);

	/*
	 * XXX
	 * If we ever do more types of locking and logging, this changes.
	 */
	region->logtype = 0;
	region->locktype = 0;
	region->naborts = 0;
	region->ncommits = 0;
	region->nbegins = 0;
	region->nactive = 0;
	region->nrestores = 0;
	region->maxnactive = 0;

	SH_TAILQ_INIT(&region->active_txn);
#ifdef	MUTEX_SYSTEM_RESOURCES
	/* Allocate room for the txn maintenance info and initialize it. */
	if ((ret = __db_shalloc(tmgrp->reginfo.addr,
	    sizeof(REGMAINT) + TXN_MAINT_SIZE, 0, &addr)) != 0) {
		__db_err(dbenv,
		    "Unable to allocate memory for mutex maintenance");
		return (ret);
	}
	__db_maintinit(&tmgrp->reginfo, addr, TXN_MAINT_SIZE);
	region->maint_off = R_OFFSET(&tmgrp->reginfo, addr);
#endif
	return (0);
}

/*
 * __txn_close --
 *	Close a transaction region.
 *
 * PUBLIC: int __txn_close __P((DB_ENV *));
 */
int
__txn_close(dbenv)
	DB_ENV *dbenv;
{
	DB_TXN *txnp;
	DB_TXNMGR *tmgrp;
	u_int32_t txnid;
	int ret, t_ret;

	ret = 0;
	tmgrp = dbenv->tx_handle;

	/*
	 * This function can only be called once per process (i.e., not
	 * once per thread), so no synchronization is required.
	 *
	 * The caller is doing something wrong if close is called with
	 * active transactions.  Try and abort any active transactions,
	 * but it's quite likely the aborts will fail because recovery
	 * won't find open files.  If we can't abort any transaction,
	 * panic, we have to run recovery to get back to a known state.
	 */
	if (TAILQ_FIRST(&tmgrp->txn_chain) != NULL) {
		__db_err(dbenv,
	"Error: closing the transaction region with active transactions");
		ret = EINVAL;
		while ((txnp = TAILQ_FIRST(&tmgrp->txn_chain)) != NULL) {
			txnid = txnp->txnid;
			if ((t_ret = txn_abort(txnp)) != 0) {
				__db_err(dbenv,
				    "Unable to abort transaction 0x%x: %s",
				    txnid, db_strerror(t_ret));
				ret = __db_panic(dbenv, t_ret);
			}
		}
	}

	/* Flush the log. */
	if (LOGGING_ON(dbenv) &&
	    (t_ret = log_flush(dbenv, NULL)) != 0 && ret == 0)
		ret = t_ret;

	/* Discard the per-thread lock. */
	if (tmgrp->mutexp != NULL)
		__db_mutex_free(dbenv, &tmgrp->reginfo, tmgrp->mutexp);

	/* Detach from the region. */
	if ((t_ret = __db_r_detach(dbenv, &tmgrp->reginfo, 0)) != 0 && ret == 0)
		ret = t_ret;

	__os_free(dbenv, tmgrp, sizeof(*tmgrp));

	dbenv->tx_handle = NULL;
	return (ret);
}

/*
 * __txn_region_size --
 *	 Return the amount of space needed for the txn region.  Make the
 *	 region large enough to hold txn_max transaction detail structures
 *	 plus some space to hold thread handles and the beginning of the
 *	 shalloc region and anything we need for mutex system resource
 *	 recording.
 */
static size_t
__txn_region_size(dbenv)
	DB_ENV *dbenv;
{
	size_t s;

	s = sizeof(DB_TXNREGION) +
	    dbenv->tx_max * sizeof(TXN_DETAIL) + 10 * 1024;
#ifdef MUTEX_SYSTEM_RESOURCES
	if (F_ISSET(dbenv, DB_ENV_THREAD))
		s += sizeof(REGMAINT) + TXN_MAINT_SIZE;
#endif
	return (s);
}

/*
 * __txn_region_destroy
 *	Destroy any region maintenance info.
 *
 * PUBLIC: void __txn_region_destroy __P((DB_ENV *, REGINFO *));
 */
void
__txn_region_destroy(dbenv, infop)
	DB_ENV *dbenv;
	REGINFO *infop;
{
	__db_shlocks_destroy(infop, (REGMAINT *)R_ADDR(infop,
	    ((DB_TXNREGION *)R_ADDR(infop, infop->rp->primary))->maint_off));

	COMPQUIET(dbenv, NULL);
	COMPQUIET(infop, NULL);
}
