/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: cxx_txn.cpp,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $";
#endif /* not lint */

#include <errno.h>

#include "db_cxx.h"
#include "cxx_int.h"

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            DbTxnMgr                                //
//                                                                    //
////////////////////////////////////////////////////////////////////////

int DbEnv::txn_begin(DbTxn *pid, DbTxn **tid, u_int32_t flags)
{
	int err;
	DB_ENV *env = unwrap(this);
	DB_TXN *txn;

	if ((err = ::txn_begin(env, unwrap(pid), &txn, flags)) != 0) {
		DB_ERROR("DbEnv::txn_begin", err, error_policy());
		return (err);
	}
	DbTxn *result = new DbTxn();
	result->imp_ = wrap(txn);
	*tid = result;
	return (err);
}

int DbEnv::txn_checkpoint(u_int32_t kbyte, u_int32_t min, u_int32_t flags)
{
	int err;
	DB_ENV *env = unwrap(this);
	if ((err = ::txn_checkpoint(env, kbyte, min, flags)) != 0 &&
	    err != DB_INCOMPLETE) {
		DB_ERROR("DbEnv::txn_checkpoint", err, error_policy());
		return (err);
	}
	return (err);
}

int DbEnv::txn_recover(DB_PREPLIST *preplist, long count,
		       long *retp, u_int32_t flags)
{
	int err;
	DB_ENV *env = unwrap(this);
	if ((err = ::txn_recover(env, preplist, count, retp, flags)) != 0) {
		DB_ERROR("DbEnv::txn_recover", err, error_policy());
		return (err);
	}
	return (err);
}

int DbEnv::txn_stat(DB_TXN_STAT **statp)
{
	int err;
	DB_ENV *env = unwrap(this);
	if ((err = ::txn_stat(env, statp)) != 0) {
		DB_ERROR("DbEnv::txn_stat", err, error_policy());
		return (err);
	}
	return (err);
}

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            DbTxn                                   //
//                                                                    //
////////////////////////////////////////////////////////////////////////

DbTxn::DbTxn()
:	imp_(0)
{
}

DbTxn::~DbTxn()
{
}

int DbTxn::abort()
{
	int err;
	DB_TXN *txn;

	txn = unwrap(this);
	err = txn_abort(txn);

	// It may seem weird to delete this, but is legal as long
	// as we don't access any of its data before returning.
	//
	delete this;

	if (err != 0)
		DB_ERROR("DbTxn::abort", err, ON_ERROR_UNKNOWN);

	return (err);
}

int DbTxn::commit(u_int32_t flags)
{
	int err;
	DB_TXN *txn;

	txn = unwrap(this);
	err = txn_commit(txn, flags);

	// It may seem weird to delete this, but is legal as long
	// as we don't access any of its data before returning.
	//
	delete this;

	if (err != 0)
		DB_ERROR("DbTxn::commit", err, ON_ERROR_UNKNOWN);

	return (err);
}

u_int32_t DbTxn::id()
{
	DB_TXN *txn;

	txn = unwrap(this);
	return (txn_id(txn));         // no error
}

int DbTxn::prepare(u_int8_t *gid)
{
	int err;
	DB_TXN *txn;

	txn = unwrap(this);
	if ((err = txn_prepare(txn, gid)) != 0) {
		DB_ERROR("DbTxn::prepare", err, ON_ERROR_UNKNOWN);
		return (err);
	}
	return (0);
}
