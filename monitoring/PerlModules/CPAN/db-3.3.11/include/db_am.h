/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 *
 * $Id: db_am.h,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */
#ifndef _DB_AM_H_
#define	_DB_AM_H_

#define	DB_MINPAGECACHE	10		/* Min pages access methods cache. */

/* DB recovery operation codes. The low bits used to have flags or'd in. */
#define	DB_ADD_DUP	0x10
#define	DB_REM_DUP	0x20
#define	DB_ADD_BIG	0x30
#define	DB_REM_BIG	0x40
#define	DB_UNUSED_1	0x50
#define	DB_UNUSED_2	0x60
#define	DB_ADD_PAGE	0x70
#define	DB_REM_PAGE	0x80

/*
 * This is a grotesque naming hack.  We have modified the btree page
 * allocation and freeing functions to be generic and have therefore
 * moved them into the access-method independent portion of the code.
 * However, since we didn't want to create new log records and routines
 * for them, we left their logging and recovery functions over in btree.
 * To make the code look prettier, we macro them, but this is sure to
 * confuse the heck out of everyone.
 */
#define	__db_pg_alloc_log	__bam_pg_alloc_log
#define	__db_pg_free_log	__bam_pg_free_log

/*
 * Standard initialization and shutdown macros for all recovery functions.
 *
 * Requires the following local variables:
 *
 *	DB *file_dbp;
 *	DB_MPOOLFILE *mpf;
 *	int ret;
 */
#define	REC_INTRO(func, inc_count) {					\
	file_dbp = NULL;						\
	dbc = NULL;							\
	if ((ret = func(dbenv, dbtp->data, &argp)) != 0)		\
		goto out;						\
	if ((ret = __db_fileid_to_db(dbenv,				\
	    &file_dbp, argp->fileid, inc_count)) != 0) {		\
		if (ret	== DB_DELETED) {				\
			ret = 0;					\
			goto done;					\
		}							\
		goto out;						\
	}								\
	if (file_dbp == NULL)						\
		goto out;						\
	if ((ret = file_dbp->cursor(file_dbp, NULL, &dbc, 0)) != 0)	\
		goto out;						\
	F_SET(dbc, DBC_RECOVER);					\
	mpf = file_dbp->mpf;						\
}

#define	REC_CLOSE {							\
	int __t_ret;							\
	if (argp != NULL)						\
		__os_free(dbenv, argp, sizeof(*argp));			\
	if (dbc != NULL &&						\
	    (__t_ret = dbc->c_close(dbc)) != 0 && ret == 0)		\
		ret = __t_ret;						\
	return (ret);							\
}

/*
 * No-op versions of the same macros.
 */
#define	REC_NOOP_INTRO(func) {						\
	if ((ret = func(dbenv, dbtp->data, &argp)) != 0)		\
		return (ret);						\
}
#define	REC_NOOP_CLOSE							\
	if (argp != NULL)						\
		__os_free(dbenv, argp, sizeof(*argp));			\
	return (ret);							\

/*
 * Standard debugging macro for all recovery functions.
 */
#ifdef DEBUG_RECOVER
#define	REC_PRINT(func)							\
	(void)func(dbenv, dbtp, lsnp, op, info);
#else
#define	REC_PRINT(func)
#endif

/*
 * Flags to __db_lget
 */
#define	LCK_COUPLE	0x01	/* Lock Couple */
#define	LCK_ALWAYS	0x02	/* Lock even for off page dup cursors */
#define	LCK_ROLLBACK	0x04	/* Lock even if in rollback */

/*
 * If doing transactions we have to hold the locks associated with a data item
 * from a page for the entire transaction.  However, we don't have to hold the
 * locks associated with walking the tree.  Distinguish between the two so that
 * we don't tie up the internal pages of the tree longer than necessary.
 */
#define	__LPUT(dbc, lock)						\
	(LOCK_ISSET(lock)? lock_put((dbc)->dbp->dbenv, &(lock)) : 0)

/*
 * __TLPUT -- transactional lock put
 *	If the lock is valid then
 *	   If we are not in a transaction put the lock.
 *	   Else if the cursor is doing dirty reads and this was a read then
 *		put the lock.
 *	   Else if the db is supporting dirty reads and this is a write then
 *		downgrade it.
 *	Else do nothing.
 */
#define	__TLPUT(dbc, lock)						\
	(LOCK_ISSET(lock) ?						\
	    ((dbc)->txn == NULL ?					\
		lock_put((dbc)->dbp->dbenv, &(lock)) :			\
		((F_ISSET(dbc, DBC_DIRTY_READ) &&			\
		     (lock).mode == DB_LOCK_DIRTY) ?			\
			lock_put((dbc)->dbp->dbenv, &(lock)) :		\
			((F_ISSET((dbc)->dbp, DB_AM_DIRTY) &&		\
			     (lock).mode == DB_LOCK_WRITE) ?		\
				__lock_downgrade((dbc)->dbp->dbenv,	\
				     &(lock), DB_LOCK_WWRITE, 0) :	\
				0)))					\
	    : 0)

typedef struct {
	DBC *dbc;
	int count;
} db_trunc_param;

/*
 * Check for common errors: failure to supply a transaction handle to a DB
 * operation, and failure to configure the DB handle in a proper environment.
 */
#ifdef DIAGNOSTIC
#define	DB_CHECK_TXN(dbp, txn)						\
	if (txn == NULL) {						\
		if (F_ISSET(dbp, DB_AM_TXN))				\
			return (__db_missing_txn_err(dbp));		\
	} else {							\
		if (!TXN_ON((dbp)->dbenv))				\
			return (__db_not_txn_env(dbp));			\
		F_SET(dbp, DB_AM_TXN);					\
	}
#else
#define	DB_CHECK_TXN(dbp, txn)
#endif

#include "db_dispatch.h"
#include "db_auto.h"
#include "crdel_auto.h"
#include "db_ext.h"
#endif
