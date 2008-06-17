/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1998-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: db_am.c,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <string.h>
#endif

#include "db_int.h"
#include "db_page.h"
#include "db_shash.h"
#include "btree.h"
#include "hash.h"
#include "qam.h"
#include "lock.h"
#include "mp.h"
#include "txn.h"
#include "db_am.h"
#include "db_ext.h"

static int __db_append_primary __P((DBC *, DBT *, DBT *));
static int __db_secondary_get __P((DB *, DB_TXN *, DBT *, DBT *, u_int32_t));
static int __db_secondary_close __P((DB *, u_int32_t));

/*
 * __db_cursor --
 *	Allocate and return a cursor.
 *
 * PUBLIC: int __db_cursor __P((DB *, DB_TXN *, DBC **, u_int32_t));
 */
int
__db_cursor(dbp, txn, dbcp, flags)
	DB *dbp;
	DB_TXN *txn;
	DBC **dbcp;
	u_int32_t flags;
{
	DB_ENV *dbenv;
	DBC *dbc;
	db_lockmode_t mode;
	u_int32_t op;
	int dirty, ret;

	dbenv = dbp->dbenv;

	PANIC_CHECK(dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->cursor");

	/* Check for invalid flags. */
	dirty = LF_ISSET(DB_DIRTY_READ) ? 1 : 0;
	LF_CLR(DB_DIRTY_READ);

	if ((ret = __db_cursorchk(dbp, flags, F_ISSET(dbp, DB_AM_RDONLY))) != 0)
		return (ret);

	if ((ret = __db_icursor(dbp,
	    txn, dbp->type, PGNO_INVALID, 0, DB_LOCK_INVALIDID, dbcp)) != 0)
		return (ret);
	dbc = *dbcp;

	/*
	 * If this is CDB, do all the locking in the interface, which is
	 * right here.
	 */
	if (CDB_LOCKING(dbenv)) {
		op = LF_ISSET(DB_OPFLAGS_MASK);
		mode = (op == DB_WRITELOCK) ? DB_LOCK_WRITE :
		    ((op == DB_WRITECURSOR) ? DB_LOCK_IWRITE : DB_LOCK_READ);
		if ((ret = lock_get(dbenv, dbc->locker, 0,
		    &dbc->lock_dbt, mode, &dbc->mylock)) != 0) {
			(void)__db_c_close(dbc);
			return (ret);
		}
		if (op == DB_WRITECURSOR)
			F_SET(dbc, DBC_WRITECURSOR);
		if (op == DB_WRITELOCK)
			F_SET(dbc, DBC_WRITER);
	}

	if (dirty || (txn != NULL && F_ISSET(txn, TXN_DIRTY_READ)))
		F_SET(dbc, DBC_DIRTY_READ);
	return (0);
}

/*
 * __db_icursor --
 *	Internal version of __db_cursor.  If dbcp is
 *	non-NULL it is assumed to point to an area to
 *	initialize as a cursor.
 *
 * PUBLIC: int __db_icursor
 * PUBLIC:     __P((DB *, DB_TXN *, DBTYPE, db_pgno_t, int, u_int32_t, DBC **));
 */
int
__db_icursor(dbp, txn, dbtype, root, is_opd, lockerid, dbcp)
	DB *dbp;
	DB_TXN *txn;
	DBTYPE dbtype;
	db_pgno_t root;
	int is_opd;
	u_int32_t lockerid;
	DBC **dbcp;
{
	DBC *dbc, *adbc;
	DBC_INTERNAL *cp;
	DB_ENV *dbenv;
	int allocated, ret;

	dbenv = dbp->dbenv;
	allocated = 0;

	/*
	 * Take one from the free list if it's available.  Take only the
	 * right type.  With off page dups we may have different kinds
	 * of cursors on the queue for a single database.
	 */
	MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);
	for (dbc = TAILQ_FIRST(&dbp->free_queue);
	    dbc != NULL; dbc = TAILQ_NEXT(dbc, links))
		if (dbtype == dbc->dbtype) {
			TAILQ_REMOVE(&dbp->free_queue, dbc, links);
			dbc->flags = 0;
			break;
		}
	MUTEX_THREAD_UNLOCK(dbenv, dbp->mutexp);

	if (dbc == NULL) {
		if ((ret = __os_calloc(dbp->dbenv, 1, sizeof(DBC), &dbc)) != 0)
			return (ret);
		allocated = 1;
		dbc->flags = 0;

		dbc->dbp = dbp;

		/* Set up locking information. */
		if (LOCKING_ON(dbenv)) {
			/*
			 * If we are not threaded, then there is no need to
			 * create new locker ids.  We know that no one else
			 * is running concurrently using this DB, so we can
			 * take a peek at any cursors on the active queue.
			 */
			if (!DB_IS_THREADED(dbp) &&
			    (adbc = TAILQ_FIRST(&dbp->active_queue)) != NULL)
				dbc->lid = adbc->lid;
			else
				if ((ret = lock_id(dbenv, &dbc->lid)) != 0)
					goto err;

			/*
			 * In CDB, secondary indices should share a lock file
			 * ID with the primary;  otherwise we're susceptible to
			 * deadlocks.  We also use __db_icursor rather
			 * than sdbp->cursor to create secondary update
			 * cursors in c_put and c_del;  these won't
			 * acquire a new lock.
			 *
			 * !!!
			 * Since this is in the one-time cursor allocation
			 * code, we need to be sure to destroy, not just
			 * close, all cursors in the secondary when we
			 * associate.
			 */
			if (CDB_LOCKING(dbp->dbenv) &&
			    F_ISSET(dbp, DB_AM_SECONDARY))
				memcpy(dbc->lock.fileid,
				    dbp->s_primary->fileid, DB_FILE_ID_LEN);
			else
				memcpy(dbc->lock.fileid,
				    dbp->fileid, DB_FILE_ID_LEN);

			if (CDB_LOCKING(dbenv)) {
				if (F_ISSET(dbenv, DB_ENV_CDB_ALLDB)) {
					/*
					 * If we are doing a single lock per
					 * environment, set up the global
					 * lock object just like we do to
					 * single thread creates.
					 */
					DB_ASSERT(sizeof(db_pgno_t) ==
					    sizeof(u_int32_t));
					dbc->lock_dbt.size = sizeof(u_int32_t);
					dbc->lock_dbt.data = &dbc->lock.pgno;
					dbc->lock.pgno = 0;
				} else {
					dbc->lock_dbt.size = DB_FILE_ID_LEN;
					dbc->lock_dbt.data = dbc->lock.fileid;
				}
			} else {
				dbc->lock.type = DB_PAGE_LOCK;
				dbc->lock_dbt.size = sizeof(dbc->lock);
				dbc->lock_dbt.data = &dbc->lock;
			}
		}
		/* Init the DBC internal structure. */
		switch (dbtype) {
		case DB_BTREE:
		case DB_RECNO:
			if ((ret = __bam_c_init(dbc, dbtype)) != 0)
				goto err;
			break;
		case DB_HASH:
			if ((ret = __ham_c_init(dbc)) != 0)
				goto err;
			break;
		case DB_QUEUE:
			if ((ret = __qam_c_init(dbc)) != 0)
				goto err;
			break;
		default:
			ret = __db_unknown_type(dbp->dbenv,
			    "__db_icursor", dbtype);
			goto err;
		}

		cp = dbc->internal;
	}

	/* Refresh the DBC structure. */
	dbc->dbtype = dbtype;
	RESET_RET_MEM(dbc);

	if ((dbc->txn = txn) == NULL) {
		/*
		 * There are certain cases in which we want to create a
		 * new cursor with a particular locker ID that is known
		 * to be the same as (and thus not conflict with) an
		 * open cursor.
		 *
		 * The most obvious case is cursor duplication;  when we
		 * call DBC->c_dup or __db_c_idup, we want to use the original
		 * cursor's locker ID.
		 *
		 * Another case is when updating secondary indices.  Standard
		 * CDB locking would mean that we might block ourself:  we need
		 * to open an update cursor in the secondary while an update
		 * cursor in the primary is open, and when the secondary and
		 * primary are subdatabases or we're using env-wide locking,
		 * this is disastrous.
		 *
		 * In these cases, our caller will pass a nonzero locker ID
		 * into this function.  Use this locker ID instead of dbc->lid
		 * as the locker ID for our new cursor.
		 */
		if (lockerid != DB_LOCK_INVALIDID)
			dbc->locker = lockerid;
		else
			dbc->locker = dbc->lid;
	} else {
		dbc->locker = txn->txnid;
		txn->cursors++;
	}

	/*
	 * These fields change when we are used as a secondary index, so
	 * if the DB is a secondary, make sure they're set properly just
	 * in case we opened some cursors before we were associated.
	 *
	 * __db_c_get is used by all access methods, so this should be safe.
	 */
	if (F_ISSET(dbp, DB_AM_SECONDARY))
		dbc->c_get = __db_c_secondary_get;

	if (is_opd)
		F_SET(dbc, DBC_OPD);
	if (F_ISSET(dbp, DB_AM_RECOVER))
		F_SET(dbc, DBC_RECOVER);

	/* Refresh the DBC internal structure. */
	cp = dbc->internal;
	cp->opd = NULL;

	cp->indx = 0;
	cp->page = NULL;
	cp->pgno = PGNO_INVALID;
	cp->root = root;

	switch (dbtype) {
	case DB_BTREE:
	case DB_RECNO:
		if ((ret = __bam_c_refresh(dbc)) != 0)
			goto err;
		break;
	case DB_HASH:
	case DB_QUEUE:
		break;
	default:
		ret = __db_unknown_type(dbp->dbenv, "__db_icursor", dbp->type);
		goto err;
	}

	MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);
	TAILQ_INSERT_TAIL(&dbp->active_queue, dbc, links);
	F_SET(dbc, DBC_ACTIVE);
	MUTEX_THREAD_UNLOCK(dbenv, dbp->mutexp);

	*dbcp = dbc;
	return (0);

err:	if (allocated)
		__os_free(dbp->dbenv, dbc, sizeof(*dbc));
	return (ret);
}

#ifdef DEBUG
/*
 * __db_cprint --
 *	Display the current cursor list.
 *
 * PUBLIC: int __db_cprint __P((DB *));
 */
int
__db_cprint(dbp)
	DB *dbp;
{
	static const FN fn[] = {
		{ DBC_ACTIVE,		"active" },
		{ DBC_COMPENSATE,	"compensate" },
		{ DBC_OPD,		"off-page-dup" },
		{ DBC_RECOVER,		"recover" },
		{ DBC_RMW,		"read-modify-write" },
		{ DBC_TRANSIENT,	"transient" },
		{ DBC_WRITECURSOR,	"write cursor" },
		{ DBC_WRITEDUP,		"internally dup'ed write cursor" },
		{ DBC_WRITER,		"short-term write cursor" },
		{ 0,			NULL }
	};
	DBC *dbc;
	DBC_INTERNAL *cp;
	char *s;

	MUTEX_THREAD_LOCK(dbp->dbenv, dbp->mutexp);
	for (dbc = TAILQ_FIRST(&dbp->active_queue);
	    dbc != NULL; dbc = TAILQ_NEXT(dbc, links)) {
		switch (dbc->dbtype) {
		case DB_BTREE:
			s = "btree";
			break;
		case DB_HASH:
			s = "hash";
			break;
		case DB_RECNO:
			s = "recno";
			break;
		case DB_QUEUE:
			s = "queue";
			break;
		default:
			DB_ASSERT(0);
			return (1);
		}
		cp = dbc->internal;
		fprintf(stderr, "%s/%#0lx: opd: %#0lx\n",
		    s, P_TO_ULONG(dbc), P_TO_ULONG(cp->opd));
		fprintf(stderr, "\ttxn: %#0lx lid: %lu locker: %lu\n",
		    P_TO_ULONG(dbc->txn),
		    (u_long)dbc->lid, (u_long)dbc->locker);
		fprintf(stderr, "\troot: %lu page/index: %lu/%lu",
		    (u_long)cp->root, (u_long)cp->pgno, (u_long)cp->indx);
		__db_prflags(dbc->flags, fn, stderr);
		fprintf(stderr, "\n");

		switch (dbp->type) {
		case DB_BTREE:
			__bam_cprint(dbc);
			break;
		case DB_HASH:
			__ham_cprint(dbc);
			break;
		default:
			break;
		}
	}
	for (dbc = TAILQ_FIRST(&dbp->free_queue);
	    dbc != NULL; dbc = TAILQ_NEXT(dbc, links))
		fprintf(stderr, "free: %#0lx ", P_TO_ULONG(dbc));
	fprintf(stderr, "\n");
	MUTEX_THREAD_UNLOCK(dbp->dbenv, dbp->mutexp);

	return (0);
}
#endif /* DEBUG */

/*
 * db_fd --
 *	Return a file descriptor for flock'ing.
 *
 * PUBLIC: int __db_fd __P((DB *, int *));
 */
int
__db_fd(dbp, fdp)
	DB *dbp;
	int *fdp;
{
	DB_FH *fhp;
	int ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->fd");

	/*
	 * XXX
	 * Truly spectacular layering violation.
	 */
	if ((ret = __mp_xxx_fh(dbp->mpf, &fhp)) != 0)
		return (ret);

	if (F_ISSET(fhp, DB_FH_VALID)) {
		*fdp = fhp->fd;
		return (0);
	} else {
		*fdp = -1;
		__db_err(dbp->dbenv, "DB does not have a valid file handle.");
		return (ENOENT);
	}
}

/*
 * __db_get --
 *	Return a key/data pair.
 *
 * PUBLIC: int __db_get __P((DB *, DB_TXN *, DBT *, DBT *, u_int32_t));
 */
int
__db_get(dbp, txn, key, data, flags)
	DB *dbp;
	DB_TXN *txn;
	DBT *key, *data;
	u_int32_t flags;
{
	DBC *dbc;
	int mode, ret, t_ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->get");

	if ((ret = __db_getchk(dbp, key, data, flags)) != 0)
		return (ret);

	mode = 0;
	if (LF_ISSET(DB_DIRTY_READ)) {
		mode = DB_DIRTY_READ;
		LF_CLR(DB_DIRTY_READ);
	}
	else if (flags == DB_CONSUME || flags == DB_CONSUME_WAIT)
		mode = DB_WRITELOCK;
	if ((ret = dbp->cursor(dbp, txn, &dbc, mode)) != 0)
		return (ret);

	DEBUG_LREAD(dbc, txn, "__db_get", key, NULL, flags);

	/*
	 * The DBC_TRANSIENT flag indicates that we're just doing a
	 * single operation with this cursor, and that in case of
	 * error we don't need to restore it to its old position--we're
	 * going to close it right away.  Thus, we can perform the get
	 * without duplicating the cursor, saving some cycles in this
	 * common case.
	 *
	 * SET_RET_MEM indicates that if key and/or data have no DBT
	 * flags set and DB manages the returned-data memory, that memory
	 * will belong to this handle, not to the underlying cursor.
	 */
	F_SET(dbc, DBC_TRANSIENT);
	SET_RET_MEM(dbc, dbp);

	if (LF_ISSET(~(DB_RMW | DB_MULTIPLE)) == 0)
		LF_SET(DB_SET);
	ret = dbc->c_get(dbc, key, data, flags);

	if ((t_ret = __db_c_close(dbc)) != 0 && ret == 0)
		ret = t_ret;

	return (ret);
}

/*
 * __db_put --
 *	Store a key/data pair.
 *
 * PUBLIC: int __db_put __P((DB *, DB_TXN *, DBT *, DBT *, u_int32_t));
 */
int
__db_put(dbp, txn, key, data, flags)
	DB *dbp;
	DB_TXN *txn;
	DBT *key, *data;
	u_int32_t flags;
{
	DBC *dbc;
	DBT tdata;
	int ret, t_ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->put");

	if ((ret = __db_putchk(dbp, key, data,
	    flags, F_ISSET(dbp, DB_AM_RDONLY),
	    F_ISSET(dbp, DB_AM_DUP) || F_ISSET(key, DB_DBT_DUPOK))) != 0)
		return (ret);

	DB_CHECK_TXN(dbp, txn);

	if ((ret = dbp->cursor(dbp, txn, &dbc, DB_WRITELOCK)) != 0)
		return (ret);
	SET_RET_MEM(dbc, dbp);

	/*
	 * See the comment in __db_get().
	 *
	 * Note that the c_get in the DB_NOOVERWRITE case is safe to
	 * do with this flag set;  if it errors in any way other than
	 * DB_NOTFOUND, we're going to close the cursor without doing
	 * anything else, and if it returns DB_NOTFOUND then it's safe
	 * to do a c_put(DB_KEYLAST) even if an access method moved the
	 * cursor, since that's not position-dependent.
	 */
	F_SET(dbc, DBC_TRANSIENT);

	DEBUG_LWRITE(dbc, txn, "__db_put", key, data, flags);

	switch (flags) {
	case DB_APPEND:
		/*
		 * If there is an append callback, the value stored in
		 * data->data may be replaced and then freed.  To avoid
		 * passing a freed pointer back to the user, just operate
		 * on a copy of the data DBT.
		 */
		tdata = *data;

		/*
		 * Append isn't a normal put operation;  call the appropriate
		 * access method's append function.
		 */
		switch (dbp->type) {
		case DB_QUEUE:
			if ((ret = __qam_append(dbc, key, &tdata)) != 0)
				goto done;
			break;
		case DB_RECNO:
			if ((ret = __ram_append(dbc, key, &tdata)) != 0)
				goto done;
			break;
		default:
			/* The interface should prevent this. */
			DB_ASSERT(0);
			ret = __db_ferr(dbp->dbenv, "__db_put", flags);
			goto done;
		}

		/*
		 * Secondary indices:  since we've returned zero from
		 * an append function, we've just put a record, and done
		 * so outside __db_c_put.  We know we're not a secondary--
		 * the interface prevents puts on them--but we may be a
		 * primary.  If so, update our secondary indices
		 * appropriately.
		 */
		DB_ASSERT(!F_ISSET(dbp, DB_AM_SECONDARY));

		if (LIST_FIRST(&dbp->s_secondaries) != NULL)
			ret = __db_append_primary(dbc, key, &tdata);

		/*
		 * The append callback, if one exists, may have allocated
		 * a new tdata.data buffer.  If so, free it.
		 */
		FREE_IF_NEEDED(dbp, &tdata);

		/* No need for a cursor put;  we're done. */
		goto done;
	case DB_NOOVERWRITE:
		flags = 0;
		/*
		 * Set DB_DBT_USERMEM, this might be a threaded application and
		 * the flags checking will catch us.  We don't want the actual
		 * data, so request a partial of length 0.
		 */
		memset(&tdata, 0, sizeof(tdata));
		F_SET(&tdata, DB_DBT_USERMEM | DB_DBT_PARTIAL);

		/*
		 * If we're doing page-level locking, set the read-modify-write
		 * flag, we're going to overwrite immediately.
		 */
		if ((ret = dbc->c_get(dbc, key, &tdata,
		    DB_SET | (STD_LOCKING(dbc) ? DB_RMW : 0))) == 0)
			ret = DB_KEYEXIST;
		else if (ret == DB_NOTFOUND || ret == DB_KEYEMPTY)
			ret = 0;
		break;
	default:
		/* Fall through to normal cursor put. */
		break;
	}
	if (ret == 0)
		ret = dbc->c_put(dbc,
		     key, data, flags == 0 ? DB_KEYLAST : flags);

done:	if ((t_ret = __db_c_close(dbc)) != 0 && ret == 0)
		ret = t_ret;

	return (ret);
}

/*
 * __db_delete --
 *	Delete the items referenced by a key.
 *
 * PUBLIC: int __db_delete __P((DB *, DB_TXN *, DBT *, u_int32_t));
 */
int
__db_delete(dbp, txn, key, flags)
	DB *dbp;
	DB_TXN *txn;
	DBT *key;
	u_int32_t flags;
{
	DBC *dbc;
	DBT lkey;
	DBT data;
	u_int32_t f_init, f_next;
	int ret, t_ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->del");
	DB_CHECK_TXN(dbp, txn);

	/* Check for invalid flags. */
	if ((ret =
	    __db_delchk(dbp, key, flags, F_ISSET(dbp, DB_AM_RDONLY))) != 0)
		return (ret);

	/* Allocate a cursor. */
	if ((ret = dbp->cursor(dbp, txn, &dbc, DB_WRITELOCK)) != 0)
		return (ret);

	DEBUG_LWRITE(dbc, txn, "db_delete", key, NULL, flags);

	/*
	 * Walk a cursor through the key/data pairs, deleting as we go.  Set
	 * the DB_DBT_USERMEM flag, as this might be a threaded application
	 * and the flags checking will catch us.  We don't actually want the
	 * keys or data, so request a partial of length 0.
	 */
	memset(&lkey, 0, sizeof(lkey));
	F_SET(&lkey, DB_DBT_USERMEM | DB_DBT_PARTIAL);
	memset(&data, 0, sizeof(data));
	F_SET(&data, DB_DBT_USERMEM | DB_DBT_PARTIAL);

	/*
	 * If locking (and we haven't already acquired CDB locks), set the
	 * read-modify-write flag.
	 */
	f_init = DB_SET;
	f_next = DB_NEXT_DUP;
	if (STD_LOCKING(dbc)) {
		f_init |= DB_RMW;
		f_next |= DB_RMW;
	}

	/* Walk through the set of key/data pairs, deleting as we go. */
	if ((ret = dbc->c_get(dbc, key, &data, f_init)) != 0)
		goto done;

	/*
	 * Hash permits an optimization in DB->del:  since on-page
	 * duplicates are stored in a single HKEYDATA structure, it's
	 * possible to delete an entire set of them at once, and as
	 * the HKEYDATA has to be rebuilt and re-put each time it
	 * changes, this is much faster than deleting the duplicates
	 * one by one.  Thus, if we're not pointing at an off-page
	 * duplicate set, and we're not using secondary indices (in
	 * which case we'd have to examine the items one by one anyway),
	 * let hash do this "quick delete".
	 *
	 * !!!
	 * Note that this is the only application-executed delete call in
	 * Berkeley DB that does not go through the __db_c_del function.
	 * If anything other than the delete itself (like a secondary index
	 * update) has to happen there in a particular situation, the
	 * conditions here should be modified not to call __ham_quick_delete.
	 * The ordinary AM-independent alternative will work just fine with
	 * a hash;  it'll just be slower.
	 */
	if (dbp->type == DB_HASH) {
		if (LIST_FIRST(&dbp->s_secondaries) == NULL &&
		    !F_ISSET(dbp, DB_AM_SECONDARY) &&
		    dbc->internal->opd == NULL) {
			ret = __ham_quick_delete(dbc);
			goto done;
		}
	}

	for (;;) {
		if ((ret = dbc->c_del(dbc, 0)) != 0)
			goto done;
		if ((ret = dbc->c_get(dbc, &lkey, &data, f_next)) != 0) {
			if (ret == DB_NOTFOUND) {
				ret = 0;
				break;
			}
			goto done;
		}
	}

done:	/* Discard the cursor. */
	if ((t_ret = dbc->c_close(dbc)) != 0 && ret == 0)
		ret = t_ret;

	return (ret);
}

/*
 * __db_sync --
 *	Flush the database cache.
 *
 * PUBLIC: int __db_sync __P((DB *, u_int32_t));
 */
int
__db_sync(dbp, flags)
	DB *dbp;
	u_int32_t flags;
{
	int ret, t_ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->sync");

	if ((ret = __db_syncchk(dbp, flags)) != 0)
		return (ret);

	/* Read-only trees never need to be sync'd. */
	if (F_ISSET(dbp, DB_AM_RDONLY))
		return (0);

	/* If it's a Recno tree, write the backing source text file. */
	if (dbp->type == DB_RECNO)
		ret = __ram_writeback(dbp);

	/* If the tree was never backed by a database file, we're done. */
	if (F_ISSET(dbp, DB_AM_INMEM))
		return (0);

	/* Flush any dirty pages from the cache to the backing file. */
	if ((t_ret = memp_fsync(dbp->mpf)) != 0 && ret == 0)
		ret = t_ret;
	return (ret);
}

/*
 * __db_associate --
 *	Associate another database as a secondary index to this one.
 *
 * PUBLIC: int __db_associate __P((DB *, DB *, int (*)(DB *, const DBT *,
 * PUBLIC:     const DBT *, DBT *), u_int32_t));
 */
int
__db_associate(dbp, sdbp, callback, flags)
	DB *dbp, *sdbp;
	int (*callback)(DB *, const DBT *, const DBT *, DBT *);
	u_int32_t flags;
{
	DB_ENV *dbenv;
	DB_TXN *txn;
	DBC *pdbc, *sdbc;
	DBT skey, key, data;
	int build, ret, t_ret;

	dbenv = dbp->dbenv;

	if ((ret = __db_associatechk(dbp, sdbp, callback, flags)) != 0)
		return (ret);

	/*
	 * The assumption we follow is that secondaries may be
	 * associated while a primary is already in active use by
	 * another thread, but that a secondary is newly created
	 * and thus will not be in use anywhere else.  There's
	 * no real way to avoid this assumption without mutex-protecting
	 * every call, so we simply document this as a restriction and
	 * let people coredump or get screwy results if they disobey.
	 */
	sdbp->s_callback = callback;
	sdbp->s_primary = dbp;

	sdbp->stored_get = sdbp->get;
	sdbp->get = __db_secondary_get;

	sdbp->stored_close = sdbp->close;
	sdbp->close = __db_secondary_close;

	/*
	 * Secondary cursors may have the primary's lock file ID, so we
	 * need to make sure that no older cursors are lying around
	 * when we make the transition.
	 */
	if (TAILQ_FIRST(&sdbp->active_queue) != NULL ||
	    TAILQ_FIRST(&sdbp->join_queue) != NULL) {
		__db_err(dbenv,
    "Databases may not become secondary indices while cursors are open");
		return (EINVAL);
	}
	while ((sdbc = TAILQ_FIRST(&sdbp->free_queue)) != NULL)
		if ((ret = __db_c_destroy(sdbc)) != 0)
			return (ret);

	F_SET(sdbp, DB_AM_SECONDARY);

	/*
	 * Check to see if the secondary is empty--and thus if we should
	 * build it--before we link it in and risk making it show up in
	 * other threads.
	 */
	build = 0;
	if (LF_ISSET(DB_CREATE)) {
		if ((ret = sdbp->cursor(sdbp, NULL, &sdbc, 0)) != 0)
			return (ret);

		memset(&key, 0, sizeof(DBT));
		memset(&data, 0, sizeof(DBT));

		/*
		 * We don't care about key or data;  we're just doing
		 * an existence check.
		 */
		F_SET(&key, DB_DBT_PARTIAL | DB_DBT_USERMEM);
		F_SET(&data, DB_DBT_PARTIAL | DB_DBT_USERMEM);
		if ((ret = sdbc->c_real_get(sdbc,
		    &key, &data, DB_FIRST)) == DB_NOTFOUND) {
			build = 1;
			ret = 0;
		}

		/*
		 * Secondary cursors have special refcounting close
		 * methods.  Be careful.
		 */
		if ((t_ret = __db_c_close(sdbc)) != 0)
			ret = t_ret;
		if (ret != 0)
			return (ret);
	}

	/*
	 * Add the secondary to the list on the primary.  Do it here
	 * so that we see any updates that occur while we're walking
	 * the primary.
	 */
	MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);

	/* See __db_s_next for an explanation of secondary refcounting. */
	DB_ASSERT(sdbp->s_refcnt == 0);
	sdbp->s_refcnt = 1;
	LIST_INSERT_HEAD(&dbp->s_secondaries, sdbp, s_links);
	MUTEX_THREAD_UNLOCK(dbenv, dbp->mutexp);

	if (build) {
		/*
		 * We loop through the primary, putting each item we
		 * find into the new secondary.
		 *
		 * We use separate transactions to avoid locking
		 * down the whole secondary.
		 */
		memset(&key, 0, sizeof(DBT));
		memset(&data, 0, sizeof(DBT));
		txn = NULL;
		if ((ret = dbp->cursor(dbp, NULL, &pdbc, 0)) != 0)
			return (ret);
retry:		while ((ret = pdbc->c_get(pdbc, &key, &data, DB_NEXT)) == 0) {
			memset(&skey, 0, sizeof(DBT));
			if ((ret = callback(sdbp, &key, &data, &skey)) != 0) {
				if (ret == DB_DONOTINDEX)
					continue;
				else
					goto err;
			}
retry2:			if (TXN_ON(dbenv) &&
			    (ret = txn_begin(dbenv, NULL, &txn, 0)) != 0)
				goto err;
			if ((ret = sdbp->cursor(sdbp, txn, &sdbc, 0)) != 0) {
				FREE_IF_NEEDED(sdbp, &skey);
				if (TXN_ON(dbenv))
					(void)txn_abort(txn);
				goto err;
			}
			if ((ret = sdbc->c_put(sdbc,
			    &skey, &key, DB_UPDATE_SECONDARY)) != 0) {
				if (TXN_ON(dbenv))
					(void)txn_abort(txn);
				if (ret == DB_LOCK_DEADLOCK)
					goto retry2;
				FREE_IF_NEEDED(sdbp, &skey);
				goto err;
			}
			FREE_IF_NEEDED(sdbp, &skey);

			if ((ret = sdbc->c_close(sdbc)) != 0) {
				if (TXN_ON(dbenv))
					(void)txn_abort(txn);
				goto err;
			}

			if (TXN_ON(dbenv) &&
			    (ret = txn_commit(txn, DB_TXN_NOSYNC)) != 0)
				goto err;
		}
		if (ret == DB_NOTFOUND) {
			ret = 0;
			goto err;
		} else if (ret == DB_LOCK_DEADLOCK)
			goto retry;

		/*
		 * We've done all our txn_commits with NOSYNC, for performance.
		 * Now flush them.
		 */
		ret = log_flush(dbenv, NULL);

err:		if ((t_ret = pdbc->c_close(pdbc)) != 0 && ret == 0)
			ret = t_ret;
	}

	return (ret);
}

/*
 * __db_pget --
 *	Return a primary key/data pair given a secondary key.
 *
 * PUBLIC: int __db_pget __P((DB *, DB_TXN *, DBT *, DBT *, DBT *, u_int32_t));
 */
int
__db_pget(dbp, txn, skey, pkey, data, flags)
	DB *dbp;
	DB_TXN *txn;
	DBT *skey, *pkey, *data;
	u_int32_t flags;
{
	DBC *dbc;
	int ret, t_ret;

	PANIC_CHECK(dbp->dbenv);
	DB_ILLEGAL_BEFORE_OPEN(dbp, "DB->pget");

	if ((ret = __db_pgetchk(dbp, skey, pkey, data, flags)) != 0)
		return (ret);

	if ((ret = dbp->cursor(dbp, txn, &dbc, 0)) != 0)
		return (ret);
	SET_RET_MEM(dbc, dbp);

	DEBUG_LREAD(dbc, txn, "__db_pget", skey, NULL, flags);

	/*
	 * The cursor is just a perfectly ordinary secondary database
	 * cursor.  Call its c_pget() method to do the dirty work.
	 */
	if (flags == 0 || flags == DB_RMW)
		flags |= DB_SET;
	if ((ret = dbc->c_pget(dbc, skey, pkey, data, flags)) != 0)
		return (ret);

	if ((t_ret = __db_c_close(dbc)) != 0 && ret == 0)
		ret = t_ret;
	return (ret);
}

/*
 * __db_secondary_get --
 *	This wrapper function for DB->pget() is the DB->get() function
 *	on a database which has been made into a secondary index.
 */
static int
__db_secondary_get(sdbp, txn, skey, data, flags)
	DB *sdbp;
	DB_TXN *txn;
	DBT *skey, *data;
	u_int32_t flags;
{

	DB_ASSERT(F_ISSET(sdbp, DB_AM_SECONDARY));
	return (sdbp->pget(sdbp, txn, skey, NULL, data, flags));
}

/*
 * __db_secondary_close --
 *	Wrapper function for DB->close() which we use on secondaries to
 *	manage refcounting and make sure we don't close them underneath
 *	a primary that is updating.
 */
static int
__db_secondary_close(sdbp, flags)
	DB *sdbp;
	u_int32_t flags;
{
	DB *primary;
	int doclose;

	doclose = 0;
	primary = sdbp->s_primary;

	MUTEX_THREAD_LOCK(primary->dbenv, primary->mutexp);
	/*
	 * Check the refcount--if it was at 1 when we were called, no
	 * thread is currently updating this secondary through the primary,
	 * so it's safe to close it for real.
	 *
	 * If it's not safe to do the close now, we do nothing;  the
	 * database will actually be closed when the refcount is decremented,
	 * which can happen in either __db_s_next or __db_s_done.
	 */
	DB_ASSERT(sdbp->s_refcnt != 0);
	if (--sdbp->s_refcnt == 0) {
		LIST_REMOVE(sdbp, s_links);
		/* We don't want to call close while the mutex is held. */
		doclose = 1;
	}
	MUTEX_THREAD_UNLOCK(primary->dbenv, primary->mutexp);

	/*
	 * sdbp->close is this function;  call the real one explicitly if
	 * need be.
	 */
	return (doclose ? __db_close(sdbp, flags) : 0);
}

/*
 * __db_append_primary --
 *	Perform the secondary index updates necessary to put(DB_APPEND)
 *	a record to a primary database.
 */
static int
__db_append_primary(dbc, key, data)
	DBC *dbc;
	DBT *key, *data;
{
	DB *dbp, *sdbp;
	DBC *sdbc, *pdbc;
	DBT oldpkey, pkey, pdata, skey;
	int cmp, ret, t_ret;

	dbp = dbc->dbp;
	sdbp = NULL;
	ret = 0;

	/*
	 * Worrying about partial appends seems a little like worrying
	 * about Linear A character encodings.  But we support those
	 * too if your application understands them.
	 */
	pdbc = NULL;
	if (F_ISSET(data, DB_DBT_PARTIAL) || F_ISSET(key, DB_DBT_PARTIAL)) {
		/*
		 * The dbc we were passed is all set to pass things
		 * back to the user;  we can't safely do a call on it.
		 * Dup the cursor, grab the real data item (we don't
		 * care what the key is--we've been passed it directly),
		 * and use that instead of the data DBT we were passed.
		 *
		 * Note that we can get away with this simple get because
		 * an appended item is by definition new, and the
		 * correctly-constructed full data item from this partial
		 * put is on the page waiting for us.
		 */
		if ((ret = __db_c_idup(dbc, &pdbc, DB_POSITIONI)) != 0)
			return (ret);
		memset(&pkey, 0, sizeof(DBT));
		memset(&pdata, 0, sizeof(DBT));

		if ((ret = pdbc->c_get(pdbc, &pkey, &pdata, DB_CURRENT)) != 0)
			goto err;

		key = &pkey;
		data = &pdata;
	}

	/*
	 * Loop through the secondary indices, putting a new item in
	 * each that points to the appended item.
	 *
	 * This is much like the loop in "step 3" in __db_c_put, so
	 * I'm not commenting heavily here;  it was unclean to excerpt
	 * just that section into a common function, but the basic
	 * overview is the same here.
	 */
	for (sdbp = __db_s_first(dbp); sdbp != NULL && ret == 0;
	    ret = __db_s_next(&sdbp)) {
		memset(&skey, 0, sizeof(DBT));
		if ((ret = sdbp->s_callback(sdbp, key, data, &skey)) != 0) {
			if (ret == DB_DONOTINDEX)
				continue;
			else
				goto err;
		}

		if ((ret = __db_icursor(sdbp, dbc->txn, sdbp->type,
		    PGNO_INVALID, 0, dbc->locker, &sdbc)) != 0) {
			FREE_IF_NEEDED(sdbp, &skey);
			goto err;
		}
		if (CDB_LOCKING(sdbp->dbenv)) {
			DB_ASSERT(sdbc->mylock.off == LOCK_INVALID);
			F_SET(sdbc, DBC_WRITER);
		}

		/*
		 * Since we know we have a new primary key, it can't be a
		 * duplicate duplicate in the secondary.  It can be a
		 * duplicate in a secondary that doesn't support duplicates,
		 * however, so we need to be careful to avoid an overwrite
		 * (which would corrupt our index).
		 */
		if (!F_ISSET(sdbp, DB_AM_DUP)) {
			memset(&oldpkey, 0, sizeof(DBT));
			F_SET(&oldpkey, DB_DBT_MALLOC);
			ret = sdbc->c_real_get(sdbc, &skey, &oldpkey,
			    DB_SET | (STD_LOCKING(dbc) ? DB_RMW : 0));
			if (ret == 0) {
				cmp = __bam_defcmp(sdbp, &oldpkey, key);
				/*
				 * XXX
				 * This needs to use the right free function
				 * as soon as this is possible.
				 */
				__os_free(sdbp->dbenv,
				    oldpkey.data, oldpkey.size);
				if (cmp != 0) {
					__db_err(sdbp->dbenv, "%s%s"
			    "Append results in a non-unique secondary key in "
			    "an index not configured to support duplicates");
					ret = EINVAL;
					goto err1;
				}
			} else if (ret != DB_NOTFOUND && ret != DB_KEYEMPTY)
				goto err1;
		}

		ret = sdbc->c_put(sdbc, &skey, key, DB_UPDATE_SECONDARY);

err1:		FREE_IF_NEEDED(sdbp, &skey);

		if ((t_ret = sdbc->c_close(sdbc)) != 0 && ret == 0)
			ret = t_ret;
	}

err:	if (pdbc != NULL && (t_ret = pdbc->c_close(pdbc)) != 0 && ret == 0)
		ret = t_ret;
	if (sdbp != NULL && (t_ret = __db_s_done(sdbp)) != 0 && ret == 0)
		ret = t_ret;
	return (ret);
}
