/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: cxx_log.cpp,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $";
#endif /* not lint */

#include <errno.h>

#include "db_cxx.h"
#include "db_int.h"
#include "cxx_int.h"

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            DbLog                                   //
//                                                                    //
////////////////////////////////////////////////////////////////////////

int DbEnv::log_archive(char **list[], u_int32_t flags)
{
	int err;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_archive(env, list, flags)) != 0) {
		DB_ERROR("DbEnv::log_archive", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_compare(const DbLsn *lsn0, const DbLsn *lsn1)
{
	return (::log_compare(lsn0, lsn1));
}

int DbEnv::log_file(DbLsn *lsn, char *namep, size_t len)
{
	int err;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_file(env, lsn, namep, len)) != 0) {
		DB_ERROR("DbEnv::log_file", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_flush(const DbLsn *lsn)
{
	int err;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_flush(env, lsn)) != 0) {
		DB_ERROR("DbEnv::log_flush", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_get(DbLsn *lsn, Dbt *data, u_int32_t flags)
{
	int err;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_get(env, lsn, data, flags)) != 0) {
		if (err == ENOMEM && F_ISSET(data, DB_DBT_USERMEM) &&
		    data->size > data->ulen)
			DB_ERROR_DBT("DbEnv::log_get", data, error_policy());
		else
			DB_ERROR("DbEnv::log_get", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_put(DbLsn *lsn, const Dbt *data, u_int32_t flags)
{
	int err = 0;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_put(env, lsn, data, flags)) != 0) {
		DB_ERROR("DbEnv::log_put", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_register(Db *dbp, const char *name)
{
	int err = 0;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_register(env, unwrap(dbp), name)) != 0) {
		DB_ERROR("DbEnv::log_register", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_stat(DB_LOG_STAT **spp)
{
	int err = 0;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_stat(env, spp)) != 0) {
		DB_ERROR("DbEnv::log_stat", err, error_policy());
		return (err);
	}
	return (0);
}

int DbEnv::log_unregister(Db *dbp)
{
	int err;
	DB_ENV *env = unwrap(this);

	if ((err = ::log_unregister(env, unwrap(dbp))) != 0) {
		DB_ERROR("DbEnv::log_unregister", err, error_policy());
		return (err);
	}
	return (0);
}
