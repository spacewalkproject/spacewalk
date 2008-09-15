/* Do not edit: automatically built by gen_rpc.awk. */
#include "db_config.h"

#ifdef HAVE_RPC
#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>
#include <rpc/rpc.h>
#include <rpc/xdr.h>

#include <string.h>
#endif
#include "db_server.h"

#include "db_int.h"
#include "mp.h"
#include "rpc_client_ext.h"
#include "txn.h"

static int __dbcl_rpc_illegal __P((DB_ENV *, char *));

static int
__dbcl_rpc_illegal(dbenv, name)
	DB_ENV *dbenv;
	char *name;
{
	__db_err(dbenv,
	    "%s method meaningless in RPC environment", name);
	return (__db_eopnotsup(dbenv));
}

/*
 * PUBLIC: int __dbcl_env_alloc __P((DB_ENV *, void *(*)(size_t),
 * PUBLIC:      void *(*)(void *, size_t), void (*)(void *)));
 */
int
__dbcl_env_alloc(dbenv, func0, func1, func2)
	DB_ENV * dbenv;
	void *(*func0) __P((size_t));
	void *(*func1) __P((void *, size_t));
	void (*func2) __P((void *));
{
	COMPQUIET(func0, 0);
	COMPQUIET(func1, 0);
	COMPQUIET(func2, 0);
	return (__dbcl_rpc_illegal(dbenv, "env_alloc"));
}

/*
 * PUBLIC: int __dbcl_env_cachesize __P((DB_ENV *, u_int32_t, u_int32_t, int));
 */
int
__dbcl_env_cachesize(dbenv, gbytes, bytes, ncache)
	DB_ENV * dbenv;
	u_int32_t gbytes;
	u_int32_t bytes;
	int ncache;
{
	CLIENT *cl;
	__env_cachesize_msg req;
	static __env_cachesize_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_cachesize_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	req.gbytes = gbytes;
	req.bytes = bytes;
	req.ncache = ncache;

	replyp = __db_env_cachesize_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_env_close __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_env_close(dbenv, flags)
	DB_ENV * dbenv;
	u_int32_t flags;
{
	CLIENT *cl;
	__env_close_msg req;
	static __env_close_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_close_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	req.flags = flags;

	replyp = __db_env_close_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_env_close_ret(dbenv, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_env_create __P((DB_ENV *, long));
 */
int
__dbcl_env_create(dbenv, timeout)
	DB_ENV * dbenv;
	long timeout;
{
	CLIENT *cl;
	__env_create_msg req;
	static __env_create_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_create_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	req.timeout = timeout;

	replyp = __db_env_create_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_env_create_ret(dbenv, timeout, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_set_data_dir __P((DB_ENV *, const char *));
 */
int
__dbcl_set_data_dir(dbenv, dir)
	DB_ENV * dbenv;
	const char * dir;
{
	COMPQUIET(dir, NULL);
	return (__dbcl_rpc_illegal(dbenv, "set_data_dir"));
}

/*
 * PUBLIC: int __dbcl_env_set_feedback __P((DB_ENV *, void (*)(DB_ENV *, int,
 * PUBLIC:      int)));
 */
int
__dbcl_env_set_feedback(dbenv, func0)
	DB_ENV * dbenv;
	void (*func0) __P((DB_ENV *, int, int));
{
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "env_set_feedback"));
}

/*
 * PUBLIC: int __dbcl_env_flags __P((DB_ENV *, u_int32_t, int));
 */
int
__dbcl_env_flags(dbenv, flags, onoff)
	DB_ENV * dbenv;
	u_int32_t flags;
	int onoff;
{
	CLIENT *cl;
	__env_flags_msg req;
	static __env_flags_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_flags_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	req.flags = flags;
	req.onoff = onoff;

	replyp = __db_env_flags_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_set_lg_bsize __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lg_bsize(dbenv, bsize)
	DB_ENV * dbenv;
	u_int32_t bsize;
{
	COMPQUIET(bsize, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lg_bsize"));
}

/*
 * PUBLIC: int __dbcl_set_lg_dir __P((DB_ENV *, const char *));
 */
int
__dbcl_set_lg_dir(dbenv, dir)
	DB_ENV * dbenv;
	const char * dir;
{
	COMPQUIET(dir, NULL);
	return (__dbcl_rpc_illegal(dbenv, "set_lg_dir"));
}

/*
 * PUBLIC: int __dbcl_set_lg_max __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lg_max(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lg_max"));
}

/*
 * PUBLIC: int __dbcl_set_lg_regionmax __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lg_regionmax(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lg_regionmax"));
}

/*
 * PUBLIC: int __dbcl_set_lk_conflict __P((DB_ENV *, u_int8_t *, int));
 */
int
__dbcl_set_lk_conflict(dbenv, conflicts, modes)
	DB_ENV * dbenv;
	u_int8_t * conflicts;
	int modes;
{
	COMPQUIET(conflicts, 0);
	COMPQUIET(modes, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_conflict"));
}

/*
 * PUBLIC: int __dbcl_set_lk_detect __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lk_detect(dbenv, detect)
	DB_ENV * dbenv;
	u_int32_t detect;
{
	COMPQUIET(detect, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_detect"));
}

/*
 * PUBLIC: int __dbcl_set_lk_max __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lk_max(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_max"));
}

/*
 * PUBLIC: int __dbcl_set_lk_max_locks __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lk_max_locks(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_max_locks"));
}

/*
 * PUBLIC: int __dbcl_set_lk_max_lockers __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lk_max_lockers(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_max_lockers"));
}

/*
 * PUBLIC: int __dbcl_set_lk_max_objects __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_lk_max_objects(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_lk_max_objects"));
}

/*
 * PUBLIC: int __dbcl_set_mp_mmapsize __P((DB_ENV *, size_t));
 */
int
__dbcl_set_mp_mmapsize(dbenv, mmapsize)
	DB_ENV * dbenv;
	size_t mmapsize;
{
	COMPQUIET(mmapsize, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_mp_mmapsize"));
}

/*
 * PUBLIC: int __dbcl_set_mutex_locks __P((DB_ENV *, int));
 */
int
__dbcl_set_mutex_locks(dbenv, do_lock)
	DB_ENV * dbenv;
	int do_lock;
{
	COMPQUIET(do_lock, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_mutex_locks"));
}

/*
 * PUBLIC: int __dbcl_env_open __P((DB_ENV *, const char *, u_int32_t, int));
 */
int
__dbcl_env_open(dbenv, home, flags, mode)
	DB_ENV * dbenv;
	const char * home;
	u_int32_t flags;
	int mode;
{
	CLIENT *cl;
	__env_open_msg req;
	static __env_open_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_open_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	if (home == NULL)
		req.home = "";
	else
		req.home = (char *)home;
	req.flags = flags;
	req.mode = mode;

	replyp = __db_env_open_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_env_open_ret(dbenv, home, flags, mode, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_env_paniccall __P((DB_ENV *, void (*)(DB_ENV *, int)));
 */
int
__dbcl_env_paniccall(dbenv, func0)
	DB_ENV * dbenv;
	void (*func0) __P((DB_ENV *, int));
{
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "env_paniccall"));
}

/*
 * PUBLIC: int __dbcl_set_recovery_init __P((DB_ENV *, int (*)(DB_ENV *)));
 */
int
__dbcl_set_recovery_init(dbenv, func0)
	DB_ENV * dbenv;
	int (*func0) __P((DB_ENV *));
{
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_recovery_init"));
}

/*
 * PUBLIC: int __dbcl_env_remove __P((DB_ENV *, const char *, u_int32_t));
 */
int
__dbcl_env_remove(dbenv, home, flags)
	DB_ENV * dbenv;
	const char * home;
	u_int32_t flags;
{
	CLIENT *cl;
	__env_remove_msg req;
	static __env_remove_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___env_remove_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	if (home == NULL)
		req.home = "";
	else
		req.home = (char *)home;
	req.flags = flags;

	replyp = __db_env_remove_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_env_remove_ret(dbenv, home, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_set_shm_key __P((DB_ENV *, long));
 */
int
__dbcl_set_shm_key(dbenv, shm_key)
	DB_ENV * dbenv;
	long shm_key;
{
	COMPQUIET(shm_key, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_shm_key"));
}

/*
 * PUBLIC: int __dbcl_set_tmp_dir __P((DB_ENV *, const char *));
 */
int
__dbcl_set_tmp_dir(dbenv, dir)
	DB_ENV * dbenv;
	const char * dir;
{
	COMPQUIET(dir, NULL);
	return (__dbcl_rpc_illegal(dbenv, "set_tmp_dir"));
}

/*
 * PUBLIC: int __dbcl_set_tx_recover __P((DB_ENV *, int (*)(DB_ENV *, DBT *,
 * PUBLIC:      DB_LSN *, db_recops)));
 */
int
__dbcl_set_tx_recover(dbenv, func0)
	DB_ENV * dbenv;
	int (*func0) __P((DB_ENV *, DBT *, DB_LSN *, db_recops));
{
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_tx_recover"));
}

/*
 * PUBLIC: int __dbcl_set_tx_max __P((DB_ENV *, u_int32_t));
 */
int
__dbcl_set_tx_max(dbenv, max)
	DB_ENV * dbenv;
	u_int32_t max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_tx_max"));
}

/*
 * PUBLIC: int __dbcl_set_tx_timestamp __P((DB_ENV *, time_t *));
 */
int
__dbcl_set_tx_timestamp(dbenv, max)
	DB_ENV * dbenv;
	time_t * max;
{
	COMPQUIET(max, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_tx_timestamp"));
}

/*
 * PUBLIC: int __dbcl_set_verbose __P((DB_ENV *, u_int32_t, int));
 */
int
__dbcl_set_verbose(dbenv, which, onoff)
	DB_ENV * dbenv;
	u_int32_t which;
	int onoff;
{
	COMPQUIET(which, 0);
	COMPQUIET(onoff, 0);
	return (__dbcl_rpc_illegal(dbenv, "set_verbose"));
}

/*
 * PUBLIC: int __dbcl_txn_abort __P((DB_TXN *));
 */
int
__dbcl_txn_abort(txnp)
	DB_TXN * txnp;
{
	CLIENT *cl;
	__txn_abort_msg req;
	static __txn_abort_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = txnp->mgrp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_abort_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;

	replyp = __db_txn_abort_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_txn_abort_ret(txnp, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_begin __P((DB_ENV *, DB_TXN *, DB_TXN **,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_txn_begin(dbenv, parent, txnpp, flags)
	DB_ENV * dbenv;
	DB_TXN * parent;
	DB_TXN ** txnpp;
	u_int32_t flags;
{
	CLIENT *cl;
	__txn_begin_msg req;
	static __txn_begin_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_begin_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	if (parent == NULL)
		req.parentcl_id = 0;
	else
		req.parentcl_id = parent->txnid;
	req.flags = flags;

	replyp = __db_txn_begin_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_txn_begin_ret(dbenv, parent, txnpp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_checkpoint __P((DB_ENV *, u_int32_t, u_int32_t));
 */
int
__dbcl_txn_checkpoint(dbenv, kbyte, min)
	DB_ENV * dbenv;
	u_int32_t kbyte;
	u_int32_t min;
{
	COMPQUIET(kbyte, 0);
	COMPQUIET(min, 0);
	return (__dbcl_rpc_illegal(dbenv, "txn_checkpoint"));
}

/*
 * PUBLIC: int __dbcl_txn_commit __P((DB_TXN *, u_int32_t));
 */
int
__dbcl_txn_commit(txnp, flags)
	DB_TXN * txnp;
	u_int32_t flags;
{
	CLIENT *cl;
	__txn_commit_msg req;
	static __txn_commit_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = txnp->mgrp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_commit_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.flags = flags;

	replyp = __db_txn_commit_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_txn_commit_ret(txnp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_discard __P((DB_TXN *, u_int32_t));
 */
int
__dbcl_txn_discard(txnp, flags)
	DB_TXN * txnp;
	u_int32_t flags;
{
	CLIENT *cl;
	__txn_discard_msg req;
	static __txn_discard_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = txnp->mgrp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_discard_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.flags = flags;

	replyp = __db_txn_discard_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_txn_discard_ret(txnp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_prepare __P((DB_TXN *, u_int8_t *));
 */
int
__dbcl_txn_prepare(txnp, gid)
	DB_TXN * txnp;
	u_int8_t * gid;
{
	CLIENT *cl;
	__txn_prepare_msg req;
	static __txn_prepare_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = txnp->mgrp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_prepare_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	memcpy(req.gid, gid, 128);

	replyp = __db_txn_prepare_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_recover __P((DB_ENV *, DB_PREPLIST *, long, long *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_txn_recover(dbenv, preplist, count, retp, flags)
	DB_ENV * dbenv;
	DB_PREPLIST * preplist;
	long count;
	long * retp;
	u_int32_t flags;
{
	CLIENT *cl;
	__txn_recover_msg req;
	static __txn_recover_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___txn_recover_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	req.count = count;
	req.flags = flags;

	replyp = __db_txn_recover_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_txn_recover_ret(dbenv, preplist, count, retp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_txn_stat __P((DB_ENV *, DB_TXN_STAT **));
 */
int
__dbcl_txn_stat(dbenv, statp)
	DB_ENV * dbenv;
	DB_TXN_STAT ** statp;
{
	COMPQUIET(statp, 0);
	return (__dbcl_rpc_illegal(dbenv, "txn_stat"));
}

/*
 * PUBLIC: int __dbcl_db_alloc __P((DB *, void *(*)(size_t), void *(*)(void *,
 * PUBLIC:      size_t), void (*)(void *)));
 */
int
__dbcl_db_alloc(dbp, func0, func1, func2)
	DB * dbp;
	void *(*func0) __P((size_t));
	void *(*func1) __P((void *, size_t));
	void (*func2) __P((void *));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	COMPQUIET(func1, 0);
	COMPQUIET(func2, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_alloc"));
}

/*
 * PUBLIC: int __dbcl_db_associate __P((DB *, DB *, int (*)(DB *, const DBT *,
 * PUBLIC:      const DBT *, DBT *), u_int32_t));
 */
int
__dbcl_db_associate(dbp, sdbp, func0, flags)
	DB * dbp;
	DB * sdbp;
	int (*func0) __P((DB *, const DBT *, const DBT *, DBT *));
	u_int32_t flags;
{
	CLIENT *cl;
	__db_associate_msg req;
	static __db_associate_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_associate_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (func0 != NULL) {
		__db_err(dbenv, "User functions not supported in RPC.");
		return (EINVAL);
	}
	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (sdbp == NULL)
		req.sdbpcl_id = 0;
	else
		req.sdbpcl_id = sdbp->cl_id;
	req.flags = flags;

	replyp = __db_db_associate_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_bt_compare __P((DB *, int (*)(DB *, const DBT *,
 * PUBLIC:      const DBT *)));
 */
int
__dbcl_db_bt_compare(dbp, func0)
	DB * dbp;
	int (*func0) __P((DB *, const DBT *, const DBT *));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_bt_compare"));
}

/*
 * PUBLIC: int __dbcl_db_bt_maxkey __P((DB *, u_int32_t));
 */
int
__dbcl_db_bt_maxkey(dbp, maxkey)
	DB * dbp;
	u_int32_t maxkey;
{
	CLIENT *cl;
	__db_bt_maxkey_msg req;
	static __db_bt_maxkey_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_bt_maxkey_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.maxkey = maxkey;

	replyp = __db_db_bt_maxkey_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_bt_minkey __P((DB *, u_int32_t));
 */
int
__dbcl_db_bt_minkey(dbp, minkey)
	DB * dbp;
	u_int32_t minkey;
{
	CLIENT *cl;
	__db_bt_minkey_msg req;
	static __db_bt_minkey_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_bt_minkey_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.minkey = minkey;

	replyp = __db_db_bt_minkey_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_bt_prefix __P((DB *, size_t(*)(DB *, const DBT *,
 * PUBLIC:      const DBT *)));
 */
int
__dbcl_db_bt_prefix(dbp, func0)
	DB * dbp;
	size_t (*func0) __P((DB *, const DBT *, const DBT *));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_bt_prefix"));
}

/*
 * PUBLIC: int __dbcl_db_set_append_recno __P((DB *, int (*)(DB *, DBT *,
 * PUBLIC:      db_recno_t)));
 */
int
__dbcl_db_set_append_recno(dbp, func0)
	DB * dbp;
	int (*func0) __P((DB *, DBT *, db_recno_t));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_set_append_recno"));
}

/*
 * PUBLIC: int __dbcl_db_cachesize __P((DB *, u_int32_t, u_int32_t, int));
 */
int
__dbcl_db_cachesize(dbp, gbytes, bytes, ncache)
	DB * dbp;
	u_int32_t gbytes;
	u_int32_t bytes;
	int ncache;
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(gbytes, 0);
	COMPQUIET(bytes, 0);
	COMPQUIET(ncache, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_cachesize"));
}

/*
 * PUBLIC: int __dbcl_db_close __P((DB *, u_int32_t));
 */
int
__dbcl_db_close(dbp, flags)
	DB * dbp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_close_msg req;
	static __db_close_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_close_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.flags = flags;

	replyp = __db_db_close_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_close_ret(dbp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_create __P((DB *, DB_ENV *, u_int32_t));
 */
int
__dbcl_db_create(dbp, dbenv, flags)
	DB * dbp;
	DB_ENV * dbenv;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_create_msg req;
	static __db_create_reply *replyp = NULL;
	int ret;

	ret = 0;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_create_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbenv == NULL)
		req.dbenvcl_id = 0;
	else
		req.dbenvcl_id = dbenv->cl_id;
	req.flags = flags;

	replyp = __db_db_create_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_create_ret(dbp, dbenv, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_del __P((DB *, DB_TXN *, DBT *, u_int32_t));
 */
int
__dbcl_db_del(dbp, txnp, key, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBT * key;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_del_msg req;
	static __db_del_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_del_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.flags = flags;

	replyp = __db_db_del_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_dup_compare __P((DB *, int (*)(DB *, const DBT *,
 * PUBLIC:      const DBT *)));
 */
int
__dbcl_db_dup_compare(dbp, func0)
	DB * dbp;
	int (*func0) __P((DB *, const DBT *, const DBT *));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_dup_compare"));
}

/*
 * PUBLIC: int __dbcl_db_extentsize __P((DB *, u_int32_t));
 */
int
__dbcl_db_extentsize(dbp, extentsize)
	DB * dbp;
	u_int32_t extentsize;
{
	CLIENT *cl;
	__db_extentsize_msg req;
	static __db_extentsize_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_extentsize_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.extentsize = extentsize;

	replyp = __db_db_extentsize_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_fd __P((DB *, int *));
 */
int
__dbcl_db_fd(dbp, fdp)
	DB * dbp;
	int * fdp;
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(fdp, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_fd"));
}

/*
 * PUBLIC: int __dbcl_db_feedback __P((DB *, void (*)(DB *, int, int)));
 */
int
__dbcl_db_feedback(dbp, func0)
	DB * dbp;
	void (*func0) __P((DB *, int, int));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_feedback"));
}

/*
 * PUBLIC: int __dbcl_db_flags __P((DB *, u_int32_t));
 */
int
__dbcl_db_flags(dbp, flags)
	DB * dbp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_flags_msg req;
	static __db_flags_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_flags_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.flags = flags;

	replyp = __db_db_flags_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_get __P((DB *, DB_TXN *, DBT *, DBT *, u_int32_t));
 */
int
__dbcl_db_get(dbp, txnp, key, data, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBT * key;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_get_msg req;
	static __db_get_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_get_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_db_get_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_get_ret(dbp, txnp, key, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_h_ffactor __P((DB *, u_int32_t));
 */
int
__dbcl_db_h_ffactor(dbp, ffactor)
	DB * dbp;
	u_int32_t ffactor;
{
	CLIENT *cl;
	__db_h_ffactor_msg req;
	static __db_h_ffactor_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_h_ffactor_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.ffactor = ffactor;

	replyp = __db_db_h_ffactor_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_h_hash __P((DB *, u_int32_t(*)(DB *, const void *,
 * PUBLIC:      u_int32_t)));
 */
int
__dbcl_db_h_hash(dbp, func0)
	DB * dbp;
	u_int32_t (*func0) __P((DB *, const void *, u_int32_t));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_h_hash"));
}

/*
 * PUBLIC: int __dbcl_db_h_nelem __P((DB *, u_int32_t));
 */
int
__dbcl_db_h_nelem(dbp, nelem)
	DB * dbp;
	u_int32_t nelem;
{
	CLIENT *cl;
	__db_h_nelem_msg req;
	static __db_h_nelem_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_h_nelem_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.nelem = nelem;

	replyp = __db_db_h_nelem_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_key_range __P((DB *, DB_TXN *, DBT *, DB_KEY_RANGE *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_db_key_range(dbp, txnp, key, range, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBT * key;
	DB_KEY_RANGE * range;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_key_range_msg req;
	static __db_key_range_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_key_range_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.flags = flags;

	replyp = __db_db_key_range_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_key_range_ret(dbp, txnp, key, range, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_lorder __P((DB *, int));
 */
int
__dbcl_db_lorder(dbp, lorder)
	DB * dbp;
	int lorder;
{
	CLIENT *cl;
	__db_lorder_msg req;
	static __db_lorder_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_lorder_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.lorder = lorder;

	replyp = __db_db_lorder_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_open __P((DB *, const char *, const char *, DBTYPE,
 * PUBLIC:      u_int32_t, int));
 */
int
__dbcl_db_open(dbp, name, subdb, type, flags, mode)
	DB * dbp;
	const char * name;
	const char * subdb;
	DBTYPE type;
	u_int32_t flags;
	int mode;
{
	CLIENT *cl;
	__db_open_msg req;
	static __db_open_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_open_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (name == NULL)
		req.name = "";
	else
		req.name = (char *)name;
	if (subdb == NULL)
		req.subdb = "";
	else
		req.subdb = (char *)subdb;
	req.type = type;
	req.flags = flags;
	req.mode = mode;

	replyp = __db_db_open_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_open_ret(dbp, name, subdb, type, flags, mode, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_pagesize __P((DB *, u_int32_t));
 */
int
__dbcl_db_pagesize(dbp, pagesize)
	DB * dbp;
	u_int32_t pagesize;
{
	CLIENT *cl;
	__db_pagesize_msg req;
	static __db_pagesize_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_pagesize_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.pagesize = pagesize;

	replyp = __db_db_pagesize_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_panic __P((DB *, void (*)(DB_ENV *, int)));
 */
int
__dbcl_db_panic(dbp, func0)
	DB * dbp;
	void (*func0) __P((DB_ENV *, int));
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(func0, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_panic"));
}

/*
 * PUBLIC: int __dbcl_db_pget __P((DB *, DB_TXN *, DBT *, DBT *, DBT *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_db_pget(dbp, txnp, skey, pkey, data, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBT * skey;
	DBT * pkey;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_pget_msg req;
	static __db_pget_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_pget_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.skeydlen = skey->dlen;
	req.skeydoff = skey->doff;
	req.skeyulen = skey->ulen;
	req.skeyflags = skey->flags;
	req.skeydata.skeydata_val = skey->data;
	req.skeydata.skeydata_len = skey->size;
	req.pkeydlen = pkey->dlen;
	req.pkeydoff = pkey->doff;
	req.pkeyulen = pkey->ulen;
	req.pkeyflags = pkey->flags;
	req.pkeydata.pkeydata_val = pkey->data;
	req.pkeydata.pkeydata_len = pkey->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_db_pget_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_pget_ret(dbp, txnp, skey, pkey, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_put __P((DB *, DB_TXN *, DBT *, DBT *, u_int32_t));
 */
int
__dbcl_db_put(dbp, txnp, key, data, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBT * key;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_put_msg req;
	static __db_put_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_put_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_db_put_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_put_ret(dbp, txnp, key, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_re_delim __P((DB *, int));
 */
int
__dbcl_db_re_delim(dbp, delim)
	DB * dbp;
	int delim;
{
	CLIENT *cl;
	__db_re_delim_msg req;
	static __db_re_delim_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_re_delim_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.delim = delim;

	replyp = __db_db_re_delim_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_re_len __P((DB *, u_int32_t));
 */
int
__dbcl_db_re_len(dbp, len)
	DB * dbp;
	u_int32_t len;
{
	CLIENT *cl;
	__db_re_len_msg req;
	static __db_re_len_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_re_len_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.len = len;

	replyp = __db_db_re_len_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_re_pad __P((DB *, int));
 */
int
__dbcl_db_re_pad(dbp, pad)
	DB * dbp;
	int pad;
{
	CLIENT *cl;
	__db_re_pad_msg req;
	static __db_re_pad_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_re_pad_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.pad = pad;

	replyp = __db_db_re_pad_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_re_source __P((DB *, const char *));
 */
int
__dbcl_db_re_source(dbp, re_source)
	DB * dbp;
	const char * re_source;
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(re_source, NULL);
	return (__dbcl_rpc_illegal(dbenv, "db_re_source"));
}

/*
 * PUBLIC: int __dbcl_db_remove __P((DB *, const char *, const char *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_db_remove(dbp, name, subdb, flags)
	DB * dbp;
	const char * name;
	const char * subdb;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_remove_msg req;
	static __db_remove_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_remove_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (name == NULL)
		req.name = "";
	else
		req.name = (char *)name;
	if (subdb == NULL)
		req.subdb = "";
	else
		req.subdb = (char *)subdb;
	req.flags = flags;

	replyp = __db_db_remove_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_remove_ret(dbp, name, subdb, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_rename __P((DB *, const char *, const char *,
 * PUBLIC:      const char *, u_int32_t));
 */
int
__dbcl_db_rename(dbp, name, subdb, newname, flags)
	DB * dbp;
	const char * name;
	const char * subdb;
	const char * newname;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_rename_msg req;
	static __db_rename_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_rename_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (name == NULL)
		req.name = "";
	else
		req.name = (char *)name;
	if (subdb == NULL)
		req.subdb = "";
	else
		req.subdb = (char *)subdb;
	if (newname == NULL)
		req.newname = "";
	else
		req.newname = (char *)newname;
	req.flags = flags;

	replyp = __db_db_rename_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_rename_ret(dbp, name, subdb, newname, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_stat __P((DB *, void *, u_int32_t));
 */
int
__dbcl_db_stat(dbp, sp, flags)
	DB * dbp;
	void * sp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_stat_msg req;
	static __db_stat_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_stat_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.flags = flags;

	replyp = __db_db_stat_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_stat_ret(dbp, sp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_sync __P((DB *, u_int32_t));
 */
int
__dbcl_db_sync(dbp, flags)
	DB * dbp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_sync_msg req;
	static __db_sync_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_sync_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	req.flags = flags;

	replyp = __db_db_sync_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_truncate __P((DB *, DB_TXN *, u_int32_t  *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_db_truncate(dbp, txnp, countp, flags)
	DB * dbp;
	DB_TXN * txnp;
	u_int32_t  * countp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_truncate_msg req;
	static __db_truncate_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_truncate_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.flags = flags;

	replyp = __db_db_truncate_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_truncate_ret(dbp, txnp, countp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_upgrade __P((DB *, const char *, u_int32_t));
 */
int
__dbcl_db_upgrade(dbp, fname, flags)
	DB * dbp;
	const char * fname;
	u_int32_t flags;
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(fname, NULL);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_upgrade"));
}

/*
 * PUBLIC: int __dbcl_db_verify __P((DB *, const char *, const char *, FILE *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_db_verify(dbp, fname, subdb, outfile, flags)
	DB * dbp;
	const char * fname;
	const char * subdb;
	FILE * outfile;
	u_int32_t flags;
{
	DB_ENV *dbenv;

	dbenv = dbp->dbenv;
	COMPQUIET(fname, NULL);
	COMPQUIET(subdb, NULL);
	COMPQUIET(outfile, 0);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "db_verify"));
}

/*
 * PUBLIC: int __dbcl_db_cursor __P((DB *, DB_TXN *, DBC **, u_int32_t));
 */
int
__dbcl_db_cursor(dbp, txnp, dbcpp, flags)
	DB * dbp;
	DB_TXN * txnp;
	DBC ** dbcpp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_cursor_msg req;
	static __db_cursor_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_cursor_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	if (txnp == NULL)
		req.txnpcl_id = 0;
	else
		req.txnpcl_id = txnp->txnid;
	req.flags = flags;

	replyp = __db_db_cursor_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_cursor_ret(dbp, txnp, dbcpp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_db_join __P((DB *, DBC **, DBC **, u_int32_t));
 */
int
__dbcl_db_join(dbp, curs, dbcp, flags)
	DB * dbp;
	DBC ** curs;
	DBC ** dbcp;
	u_int32_t flags;
{
	CLIENT *cl;
	__db_join_msg req;
	static __db_join_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;
	DBC ** cursp;
	int cursi;
	u_int32_t * cursq;

	ret = 0;
	dbenv = NULL;
	dbenv = dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___db_join_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbp == NULL)
		req.dbpcl_id = 0;
	else
		req.dbpcl_id = dbp->cl_id;
	for (cursi = 0, cursp = curs; *cursp != 0;  cursi++, cursp++)
		;
	req.curs.curs_len = cursi;
	if ((ret = __os_calloc(dbenv,
	    req.curs.curs_len, sizeof(u_int32_t), &req.curs.curs_val)) != 0)
		return (ret);
	for (cursq = req.curs.curs_val, cursp = curs; cursi--; cursq++, cursp++)
		*cursq = (*cursp)->cl_id;
	req.flags = flags;

	replyp = __db_db_join_3003(&req, cl);
	__os_free(dbenv, req.curs.curs_val, req.curs.curs_len * sizeof(u_int32_t));
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_db_join_ret(dbp, curs, dbcp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_close __P((DBC *));
 */
int
__dbcl_dbc_close(dbc)
	DBC * dbc;
{
	CLIENT *cl;
	__dbc_close_msg req;
	static __dbc_close_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_close_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;

	replyp = __db_dbc_close_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_close_ret(dbc, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_count __P((DBC *, db_recno_t *, u_int32_t));
 */
int
__dbcl_dbc_count(dbc, countp, flags)
	DBC * dbc;
	db_recno_t * countp;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_count_msg req;
	static __dbc_count_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_count_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.flags = flags;

	replyp = __db_dbc_count_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_count_ret(dbc, countp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_del __P((DBC *, u_int32_t));
 */
int
__dbcl_dbc_del(dbc, flags)
	DBC * dbc;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_del_msg req;
	static __dbc_del_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_del_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.flags = flags;

	replyp = __db_dbc_del_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	ret = replyp->status;
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_dup __P((DBC *, DBC **, u_int32_t));
 */
int
__dbcl_dbc_dup(dbc, dbcp, flags)
	DBC * dbc;
	DBC ** dbcp;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_dup_msg req;
	static __dbc_dup_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_dup_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.flags = flags;

	replyp = __db_dbc_dup_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_dup_ret(dbc, dbcp, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_get __P((DBC *, DBT *, DBT *, u_int32_t));
 */
int
__dbcl_dbc_get(dbc, key, data, flags)
	DBC * dbc;
	DBT * key;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_get_msg req;
	static __dbc_get_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_get_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_dbc_get_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_get_ret(dbc, key, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_pget __P((DBC *, DBT *, DBT *, DBT *, u_int32_t));
 */
int
__dbcl_dbc_pget(dbc, skey, pkey, data, flags)
	DBC * dbc;
	DBT * skey;
	DBT * pkey;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_pget_msg req;
	static __dbc_pget_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_pget_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.skeydlen = skey->dlen;
	req.skeydoff = skey->doff;
	req.skeyulen = skey->ulen;
	req.skeyflags = skey->flags;
	req.skeydata.skeydata_val = skey->data;
	req.skeydata.skeydata_len = skey->size;
	req.pkeydlen = pkey->dlen;
	req.pkeydoff = pkey->doff;
	req.pkeyulen = pkey->ulen;
	req.pkeyflags = pkey->flags;
	req.pkeydata.pkeydata_val = pkey->data;
	req.pkeydata.pkeydata_len = pkey->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_dbc_pget_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_pget_ret(dbc, skey, pkey, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_dbc_put __P((DBC *, DBT *, DBT *, u_int32_t));
 */
int
__dbcl_dbc_put(dbc, key, data, flags)
	DBC * dbc;
	DBT * key;
	DBT * data;
	u_int32_t flags;
{
	CLIENT *cl;
	__dbc_put_msg req;
	static __dbc_put_reply *replyp = NULL;
	int ret;
	DB_ENV *dbenv;

	ret = 0;
	dbenv = NULL;
	dbenv = dbc->dbp->dbenv;
	if (dbenv == NULL || dbenv->cl_handle == NULL) {
		__db_err(dbenv, "No server environment.");
		return (DB_NOSERVER);
	}

	if (replyp != NULL) {
		xdr_free((xdrproc_t)xdr___dbc_put_reply, (void *)replyp);
		replyp = NULL;
	}
	cl = (CLIENT *)dbenv->cl_handle;

	if (dbc == NULL)
		req.dbccl_id = 0;
	else
		req.dbccl_id = dbc->cl_id;
	req.keydlen = key->dlen;
	req.keydoff = key->doff;
	req.keyulen = key->ulen;
	req.keyflags = key->flags;
	req.keydata.keydata_val = key->data;
	req.keydata.keydata_len = key->size;
	req.datadlen = data->dlen;
	req.datadoff = data->doff;
	req.dataulen = data->ulen;
	req.dataflags = data->flags;
	req.datadata.datadata_val = data->data;
	req.datadata.datadata_len = data->size;
	req.flags = flags;

	replyp = __db_dbc_put_3003(&req, cl);
	if (replyp == NULL) {
		__db_err(dbenv, clnt_sperror(cl, "Berkeley DB"));
		ret = DB_NOSERVER;
		goto out;
	}
	return (__dbcl_dbc_put_ret(dbc, key, data, flags, replyp));
out:
	return (ret);
}

/*
 * PUBLIC: int __dbcl_lock_detect __P((DB_ENV *, u_int32_t, u_int32_t, int *));
 */
int
__dbcl_lock_detect(dbenv, flags, atype, aborted)
	DB_ENV * dbenv;
	u_int32_t flags;
	u_int32_t atype;
	int * aborted;
{
	COMPQUIET(flags, 0);
	COMPQUIET(atype, 0);
	COMPQUIET(aborted, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_detect"));
}

/*
 * PUBLIC: int __dbcl_lock_get __P((DB_ENV *, u_int32_t, u_int32_t,
 * PUBLIC:      const DBT *, db_lockmode_t, DB_LOCK *));
 */
int
__dbcl_lock_get(dbenv, locker, flags, obj, mode, lock)
	DB_ENV * dbenv;
	u_int32_t locker;
	u_int32_t flags;
	const DBT * obj;
	db_lockmode_t mode;
	DB_LOCK * lock;
{
	COMPQUIET(locker, 0);
	COMPQUIET(flags, 0);
	COMPQUIET(obj, NULL);
	COMPQUIET(mode, 0);
	COMPQUIET(lock, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_get"));
}

/*
 * PUBLIC: int __dbcl_lock_id __P((DB_ENV *, u_int32_t *));
 */
int
__dbcl_lock_id(dbenv, idp)
	DB_ENV * dbenv;
	u_int32_t * idp;
{
	COMPQUIET(idp, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_id"));
}

/*
 * PUBLIC: int __dbcl_lock_put __P((DB_ENV *, DB_LOCK *));
 */
int
__dbcl_lock_put(dbenv, lock)
	DB_ENV * dbenv;
	DB_LOCK * lock;
{
	COMPQUIET(lock, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_put"));
}

/*
 * PUBLIC: int __dbcl_lock_stat __P((DB_ENV *, DB_LOCK_STAT **));
 */
int
__dbcl_lock_stat(dbenv, statp)
	DB_ENV * dbenv;
	DB_LOCK_STAT ** statp;
{
	COMPQUIET(statp, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_stat"));
}

/*
 * PUBLIC: int __dbcl_lock_vec __P((DB_ENV *, u_int32_t, u_int32_t,
 * PUBLIC:      DB_LOCKREQ *, int, DB_LOCKREQ **));
 */
int
__dbcl_lock_vec(dbenv, locker, flags, list, nlist, elistp)
	DB_ENV * dbenv;
	u_int32_t locker;
	u_int32_t flags;
	DB_LOCKREQ * list;
	int nlist;
	DB_LOCKREQ ** elistp;
{
	COMPQUIET(locker, 0);
	COMPQUIET(flags, 0);
	COMPQUIET(list, 0);
	COMPQUIET(nlist, 0);
	COMPQUIET(elistp, 0);
	return (__dbcl_rpc_illegal(dbenv, "lock_vec"));
}

/*
 * PUBLIC: int __dbcl_log_archive __P((DB_ENV *, char ***, u_int32_t));
 */
int
__dbcl_log_archive(dbenv, listp, flags)
	DB_ENV * dbenv;
	char *** listp;
	u_int32_t flags;
{
	COMPQUIET(listp, 0);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_archive"));
}

/*
 * PUBLIC: int __dbcl_log_file __P((DB_ENV *, const DB_LSN *, char *, size_t));
 */
int
__dbcl_log_file(dbenv, lsn, namep, len)
	DB_ENV * dbenv;
	const DB_LSN * lsn;
	char * namep;
	size_t len;
{
	COMPQUIET(lsn, NULL);
	COMPQUIET(namep, NULL);
	COMPQUIET(len, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_file"));
}

/*
 * PUBLIC: int __dbcl_log_flush __P((DB_ENV *, const DB_LSN *));
 */
int
__dbcl_log_flush(dbenv, lsn)
	DB_ENV * dbenv;
	const DB_LSN * lsn;
{
	COMPQUIET(lsn, NULL);
	return (__dbcl_rpc_illegal(dbenv, "log_flush"));
}

/*
 * PUBLIC: int __dbcl_log_get __P((DB_ENV *, DB_LSN *, DBT *, u_int32_t));
 */
int
__dbcl_log_get(dbenv, lsn, data, flags)
	DB_ENV * dbenv;
	DB_LSN * lsn;
	DBT * data;
	u_int32_t flags;
{
	COMPQUIET(lsn, 0);
	COMPQUIET(data, NULL);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_get"));
}

/*
 * PUBLIC: int __dbcl_log_put __P((DB_ENV *, DB_LSN *, const DBT *,
 * PUBLIC:      u_int32_t));
 */
int
__dbcl_log_put(dbenv, lsn, data, flags)
	DB_ENV * dbenv;
	DB_LSN * lsn;
	const DBT * data;
	u_int32_t flags;
{
	COMPQUIET(lsn, 0);
	COMPQUIET(data, NULL);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_put"));
}

/*
 * PUBLIC: int __dbcl_log_register __P((DB_ENV *, DB *, const char *));
 */
int
__dbcl_log_register(dbenv, dbp, namep)
	DB_ENV * dbenv;
	DB * dbp;
	const char * namep;
{
	COMPQUIET(dbp, 0);
	COMPQUIET(namep, NULL);
	return (__dbcl_rpc_illegal(dbenv, "log_register"));
}

/*
 * PUBLIC: int __dbcl_log_stat __P((DB_ENV *, DB_LOG_STAT **));
 */
int
__dbcl_log_stat(dbenv, statp)
	DB_ENV * dbenv;
	DB_LOG_STAT ** statp;
{
	COMPQUIET(statp, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_stat"));
}

/*
 * PUBLIC: int __dbcl_log_unregister __P((DB_ENV *, DB *));
 */
int
__dbcl_log_unregister(dbenv, dbp)
	DB_ENV * dbenv;
	DB * dbp;
{
	COMPQUIET(dbp, 0);
	return (__dbcl_rpc_illegal(dbenv, "log_unregister"));
}

/*
 * PUBLIC: int __dbcl_memp_fclose __P((DB_MPOOLFILE *));
 */
int
__dbcl_memp_fclose(mpf)
	DB_MPOOLFILE * mpf;
{
	DB_ENV *dbenv;

	dbenv = mpf->dbmp->dbenv;
	return (__dbcl_rpc_illegal(dbenv, "memp_fclose"));
}

/*
 * PUBLIC: int __dbcl_memp_fget __P((DB_MPOOLFILE *, db_pgno_t *, u_int32_t,
 * PUBLIC:      void **));
 */
int
__dbcl_memp_fget(mpf, pgno, flags, pagep)
	DB_MPOOLFILE * mpf;
	db_pgno_t * pgno;
	u_int32_t flags;
	void ** pagep;
{
	DB_ENV *dbenv;

	dbenv = mpf->dbmp->dbenv;
	COMPQUIET(pgno, 0);
	COMPQUIET(flags, 0);
	COMPQUIET(pagep, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_fget"));
}

/*
 * PUBLIC: int __dbcl_memp_fopen __P((DB_ENV *, const char *, u_int32_t, int,
 * PUBLIC:      size_t, DB_MPOOL_FINFO *, DB_MPOOLFILE **));
 */
int
__dbcl_memp_fopen(dbenv, file, flags, mode, pagesize, finfop, mpf)
	DB_ENV * dbenv;
	const char * file;
	u_int32_t flags;
	int mode;
	size_t pagesize;
	DB_MPOOL_FINFO * finfop;
	DB_MPOOLFILE ** mpf;
{
	COMPQUIET(file, NULL);
	COMPQUIET(flags, 0);
	COMPQUIET(mode, 0);
	COMPQUIET(pagesize, 0);
	COMPQUIET(finfop, 0);
	COMPQUIET(mpf, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_fopen"));
}

/*
 * PUBLIC: int __dbcl_memp_fput __P((DB_MPOOLFILE *, void *, u_int32_t));
 */
int
__dbcl_memp_fput(mpf, pgaddr, flags)
	DB_MPOOLFILE * mpf;
	void * pgaddr;
	u_int32_t flags;
{
	DB_ENV *dbenv;

	dbenv = mpf->dbmp->dbenv;
	COMPQUIET(pgaddr, 0);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_fput"));
}

/*
 * PUBLIC: int __dbcl_memp_fset __P((DB_MPOOLFILE *, void *, u_int32_t));
 */
int
__dbcl_memp_fset(mpf, pgaddr, flags)
	DB_MPOOLFILE * mpf;
	void * pgaddr;
	u_int32_t flags;
{
	DB_ENV *dbenv;

	dbenv = mpf->dbmp->dbenv;
	COMPQUIET(pgaddr, 0);
	COMPQUIET(flags, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_fset"));
}

/*
 * PUBLIC: int __dbcl_memp_fsync __P((DB_MPOOLFILE *));
 */
int
__dbcl_memp_fsync(mpf)
	DB_MPOOLFILE * mpf;
{
	DB_ENV *dbenv;

	dbenv = mpf->dbmp->dbenv;
	return (__dbcl_rpc_illegal(dbenv, "memp_fsync"));
}

/*
 * PUBLIC: int __dbcl_memp_register __P((DB_ENV *, int, int (*)(DB_ENV *,
 * PUBLIC:      db_pgno_t, void *, DBT *), int (*)(DB_ENV *, db_pgno_t, void *, DBT *)));
 */
int
__dbcl_memp_register(dbenv, ftype, func0, func1)
	DB_ENV * dbenv;
	int ftype;
	int (*func0) __P((DB_ENV *, db_pgno_t, void *, DBT *));
	int (*func1) __P((DB_ENV *, db_pgno_t, void *, DBT *));
{
	COMPQUIET(ftype, 0);
	COMPQUIET(func0, 0);
	COMPQUIET(func1, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_register"));
}

/*
 * PUBLIC: int __dbcl_memp_stat __P((DB_ENV *, DB_MPOOL_STAT **,
 * PUBLIC:      DB_MPOOL_FSTAT ***));
 */
int
__dbcl_memp_stat(dbenv, gstatp, fstatp)
	DB_ENV * dbenv;
	DB_MPOOL_STAT ** gstatp;
	DB_MPOOL_FSTAT *** fstatp;
{
	COMPQUIET(gstatp, 0);
	COMPQUIET(fstatp, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_stat"));
}

/*
 * PUBLIC: int __dbcl_memp_sync __P((DB_ENV *, DB_LSN *));
 */
int
__dbcl_memp_sync(dbenv, lsn)
	DB_ENV * dbenv;
	DB_LSN * lsn;
{
	COMPQUIET(lsn, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_sync"));
}

/*
 * PUBLIC: int __dbcl_memp_trickle __P((DB_ENV *, int, int *));
 */
int
__dbcl_memp_trickle(dbenv, pct, nwrotep)
	DB_ENV * dbenv;
	int pct;
	int * nwrotep;
{
	COMPQUIET(pct, 0);
	COMPQUIET(nwrotep, 0);
	return (__dbcl_rpc_illegal(dbenv, "memp_trickle"));
}

#endif /* HAVE_RPC */
