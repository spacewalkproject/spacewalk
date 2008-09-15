/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: client.c,v 1.1.1.1 2002-01-11 00:21:38 apingel Exp $";
#endif /* not lint */

#ifdef HAVE_RPC
#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <rpc/rpc.h>

#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#endif
#include "db_server.h"

#include "db_int.h"
#include "txn.h"
#include "rpc_client_ext.h"

static int __dbcl_c_destroy __P((DBC *));
static int __dbcl_txn_close __P((DB_ENV *));

/*
 * __dbcl_envrpcserver --
 *	Initialize an environment's server.
 *
 * PUBLIC: int __dbcl_envrpcserver
 * PUBLIC:     __P((DB_ENV *, void *, const char *, long, long, u_int32_t));
 */
int
__dbcl_envrpcserver(dbenv, clnt, host, tsec, ssec, flags)
	DB_ENV *dbenv;
	void *clnt;
	const char *host;
	long tsec, ssec;
	u_int32_t flags;
{
	CLIENT *cl;
	struct timeval tp;

	COMPQUIET(flags, 0);

#ifdef HAVE_VXWORKS
	if (rpcTaskInit() != 0) {
		__db_err(dbenv, "Could not initialize VxWorks RPC");
		return (ERROR);
	}
#endif
	/*
	 * Only create the client and set its timeout if the user
	 * did not pass us a client structure to begin with.
	 */
	if (clnt == NULL) {
		if ((cl = clnt_create((char *)host, DB_RPC_SERVERPROG,
		    DB_RPC_SERVERVERS, "tcp")) == NULL) {
			__db_err(dbenv, clnt_spcreateerror((char *)host));
			return (DB_NOSERVER);
		}
		if (tsec != 0) {
			tp.tv_sec = tsec;
			tp.tv_usec = 0;
			(void)clnt_control(cl, CLSET_TIMEOUT, (char *)&tp);
		}
	} else {
		cl = (CLIENT *)clnt;
		F_SET(dbenv, DB_ENV_RPCCLIENT_GIVEN);
	}
	dbenv->cl_handle = cl;

	return (__dbcl_env_create(dbenv, ssec));
}

/*
 * __dbclenv_server --
 *	Initialize an environment's server.
 *
 * PUBLIC: int __dbcl_envserver
 * PUBLIC:     __P((DB_ENV *, const char *, long, long, u_int32_t));
 */
int
__dbcl_envserver(dbenv, host, tsec, ssec, flags)
	DB_ENV *dbenv;
	const char *host;
	long tsec, ssec;
	u_int32_t flags;
{
	COMPQUIET(flags, 0);
	return (__dbcl_envrpcserver(dbenv, NULL, host, tsec, ssec, flags));
}

/*
 * __dbcl_env_open_wrap --
 *	Wrapper function for DBENV->open function for clients.
 *	We need a wrapper function to deal with DB_USE_ENVIRON* flags
 *	and we don't want to complicate the generated code for env_open.
 *
 * PUBLIC: int __dbcl_env_open_wrap
 * PUBLIC:     __P((DB_ENV *, const char *, u_int32_t, int));
 */
int
__dbcl_env_open_wrap(dbenv, home, flags, mode)
	DB_ENV * dbenv;
	const char * home;
	u_int32_t flags;
	int mode;
{
	int ret;

	if ((ret = __db_home(dbenv, home, flags)) != 0)
		return (ret);
	return (__dbcl_env_open(dbenv, dbenv->db_home, flags, mode));
}

/*
 * __dbcl_refresh --
 *	Clean up an environment.
 *
 * PUBLIC: int __dbcl_refresh __P((DB_ENV *));
 */
int
__dbcl_refresh(dbenv)
	DB_ENV *dbenv;
{
	CLIENT *cl;
	int ret;

	cl = (CLIENT *)dbenv->cl_handle;

	ret = 0;
	if (dbenv->tx_handle != NULL) {
		/*
		 * We only need to free up our stuff, the caller
		 * of this function will call the server who will
		 * do all the real work.
		 */
		ret = __dbcl_txn_close(dbenv);
		dbenv->tx_handle = NULL;
	}
	if (!F_ISSET(dbenv, DB_ENV_RPCCLIENT_GIVEN) && cl != NULL)
		clnt_destroy(cl);
	dbenv->cl_handle = NULL;
	return (ret);
}

/*
 * __dbcl_txn_close --
 *	Clean up an environment's transactions.
 */
int
__dbcl_txn_close(dbenv)
	DB_ENV *dbenv;
{
	DB_TXN *txnp;
	DB_TXNMGR *tmgrp;
	int ret;

	ret = 0;
	tmgrp = dbenv->tx_handle;

	/*
	 * This function can only be called once per process (i.e., not
	 * once per thread), so no synchronization is required.
	 * Also this function is called *after* the server has been called,
	 * so the server has already closed/aborted any transactions that
	 * were open on its side.  We only need to do local cleanup.
	 */
	while ((txnp = TAILQ_FIRST(&tmgrp->txn_chain)) != NULL)
		__dbcl_txn_end(txnp);

	__os_free(dbenv, tmgrp, sizeof(*tmgrp));
	return (ret);

}

/*
 * __dbcl_txn_end --
 *	Clean up an transaction.
 * RECURSIVE FUNCTION:  Clean up nested transactions.
 *
 * PUBLIC: void __dbcl_txn_end __P((DB_TXN *));
 */
void
__dbcl_txn_end(txnp)
	DB_TXN *txnp;
{
	DB_ENV *dbenv;
	DB_TXN *kids;
	DB_TXNMGR *mgr;

	mgr = txnp->mgrp;
	dbenv = mgr->dbenv;

	/*
	 * First take care of any kids we have
	 */
	for (kids = TAILQ_FIRST(&txnp->kids);
	    kids != NULL;
	    kids = TAILQ_FIRST(&txnp->kids))
		__dbcl_txn_end(kids);

	/*
	 * We are ending this transaction no matter what the parent
	 * may eventually do, if we have a parent.  All those details
	 * are taken care of by the server.  We only need to make sure
	 * that we properly release resources.
	 */
	if (txnp->parent != NULL)
		TAILQ_REMOVE(&txnp->parent->kids, txnp, klinks);
	TAILQ_REMOVE(&mgr->txn_chain, txnp, links);
	__os_free(dbenv, txnp, sizeof(*txnp));

	return;
}

/*
 * __dbcl_txn_setup --
 *	Setup a client transaction structure.
 *
 * PUBLIC: void __dbcl_txn_setup __P((DB_ENV *, DB_TXN *, DB_TXN *, u_int32_t));
 */
void
__dbcl_txn_setup(dbenv, txn, parent, id)
	DB_ENV *dbenv;
	DB_TXN *txn;
	DB_TXN *parent;
	u_int32_t id;
{
	txn->txnid = id;
	txn->mgrp = dbenv->tx_handle;
	txn->parent = parent;
	TAILQ_INIT(&txn->kids);
	txn->flags = TXN_MALLOC;
	if (parent != NULL)
		TAILQ_INSERT_HEAD(&parent->kids, txn, klinks);

	/*
	 * XXX
	 * In DB library the txn_chain is protected by the mgrp->mutexp.
	 * However, that mutex is implemented in the environments shared
	 * memory region.  The client library does not support all of the
	 * region - that just get forwarded to the server.  Therefore,
	 * the chain is unprotected here, but properly protected on the
	 * server.
	 */
	TAILQ_INSERT_TAIL(&txn->mgrp->txn_chain, txn, links);

	return;
}

/*
 * __dbcl_c_destroy --
 *	Destroy a cursor.
 */
static int
__dbcl_c_destroy(dbc)
	DBC *dbc;
{
	DB *dbp;

	dbp = dbc->dbp;

	TAILQ_REMOVE(&dbp->free_queue, dbc, links);
	__os_free(NULL, dbc, sizeof(*dbc));

	return (0);
}

/*
 * __dbcl_c_refresh --
 *	Refresh a cursor.  Move it from the active queue to the free queue.
 *
 * PUBLIC: void __dbcl_c_refresh __P((DBC *));
 */
void
__dbcl_c_refresh(dbcp)
	DBC *dbcp;
{
	DB *dbp;

	dbp = dbcp->dbp;
	dbcp->flags = 0;
	dbcp->cl_id = 0;

	/*
	 * If dbp->cursor fails locally, we use a local dbc so that
	 * we can close it.  In that case, dbp will be NULL.
	 */
	if (dbp != NULL) {
		TAILQ_REMOVE(&dbp->active_queue, dbcp, links);
		TAILQ_INSERT_TAIL(&dbp->free_queue, dbcp, links);
	}
	return;
}

/*
 * __dbcl_c_setup --
 *	Allocate a cursor.
 *
 * PUBLIC: int __dbcl_c_setup __P((long, DB *, DBC **));
 */
int
__dbcl_c_setup(cl_id, dbp, dbcpp)
	long cl_id;
	DB *dbp;
	DBC **dbcpp;
{
	DBC *dbc, tmpdbc;
	int ret;

	if ((dbc = TAILQ_FIRST(&dbp->free_queue)) != NULL)
		TAILQ_REMOVE(&dbp->free_queue, dbc, links);
	else {
		if ((ret =
		    __os_calloc(dbp->dbenv, 1, sizeof(DBC), &dbc)) != 0) {
			/*
			 * If we die here, set up a tmp dbc to call the
			 * server to shut down that cursor.
			 */
			tmpdbc.dbp = NULL;
			tmpdbc.cl_id = cl_id;
			(void)__dbcl_dbc_close(&tmpdbc);
			return (ret);
		}
		dbc->c_close = __dbcl_dbc_close;
		dbc->c_count = __dbcl_dbc_count;
		dbc->c_del = __dbcl_dbc_del;
		dbc->c_dup = __dbcl_dbc_dup;
		dbc->c_get = __dbcl_dbc_get;
		dbc->c_pget = __dbcl_dbc_pget;
		dbc->c_put = __dbcl_dbc_put;
		dbc->c_am_destroy = __dbcl_c_destroy;
	}
	dbc->cl_id = cl_id;
	dbc->dbp = dbp;
	TAILQ_INSERT_TAIL(&dbp->active_queue, dbc, links);
	*dbcpp = dbc;
	return (0);
}

/*
 * __dbcl_retcopy --
 *	Copy the returned data into the user's DBT, handling special flags
 *	as they apply to a client.  Modeled after __db_retcopy().
 *
 * PUBLIC: int __dbcl_retcopy __P((DB_ENV *, DBT *, void *, u_int32_t));
 */
int
__dbcl_retcopy(dbenv, dbt, data, len)
	DB_ENV *dbenv;
	DBT *dbt;
	void *data;
	u_int32_t len;
{
	int ret;

	/*
	 * No need to handle DB_DBT_PARTIAL here, server already did.
	 */
	dbt->size = len;

	/*
	 * Allocate memory to be owned by the application: DB_DBT_MALLOC
	 * and DB_DBT_REALLOC.  Always allocate even if we're copying 0 bytes.
	 * Or use memory specified by application: DB_DBT_USERMEM.
	 */
	if (F_ISSET(dbt, DB_DBT_MALLOC)) {
		if ((ret = __os_malloc(dbenv, len, &dbt->data)) != 0)
			return (ret);
	} else if (F_ISSET(dbt, DB_DBT_REALLOC)) {
		if ((ret = __os_realloc(dbenv, len, &dbt->data)) != 0)
			return (ret);
	} else if (F_ISSET(dbt, DB_DBT_USERMEM)) {
		if (len != 0 && (dbt->data == NULL || dbt->ulen < len))
			return (ENOMEM);
	} else {
		/*
		 * If no user flags, then set the DBT to point to the
		 * returned data pointer and return.
		 */
		dbt->data = data;
		return (0);
	}

	if (len != 0)
		memcpy(dbt->data, data, len);
	return (0);
}

/*
 * __dbcl_dbclose_common --
 *	Common code for closing/cleaning a dbp.
 *
 * PUBLIC: int __dbcl_dbclose_common __P((DB *));
 */
int
__dbcl_dbclose_common(dbp)
	DB *dbp;
{
	int ret, t_ret;
	DBC *dbc;

	/*
	 * Go through the active cursors and call the cursor recycle routine,
	 * which resolves pending operations and moves the cursors onto the
	 * free list.  Then, walk the free list and call the cursor destroy
	 * routine.
	 *
	 * NOTE:  We do not need to use the join_queue for join cursors.
	 * See comment in __dbcl_dbjoin_ret.
	 */
	ret = 0;
	while ((dbc = TAILQ_FIRST(&dbp->active_queue)) != NULL)
		__dbcl_c_refresh(dbc);
	while ((dbc = TAILQ_FIRST(&dbp->free_queue)) != NULL)
		if ((t_ret = __dbcl_c_destroy(dbc)) != 0 && ret == 0)
			ret = t_ret;

	TAILQ_INIT(&dbp->free_queue);
	TAILQ_INIT(&dbp->active_queue);

	memset(dbp, CLEAR_BYTE, sizeof(*dbp));
	__os_free(NULL, dbp, sizeof(*dbp));
	return (ret);
}
#endif /* HAVE_RPC */
