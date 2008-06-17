/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */
/*
 * Copyright (c) 1990, 1993, 1994, 1995, 1996
 *	Keith Bostic.  All rights reserved.
 */
/*
 * Copyright (c) 1990, 1993, 1994, 1995
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Mike Olson.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: db_meta.c,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <string.h>
#endif

#include "db_int.h"
#include "db_page.h"
#include "db_shash.h"
#include "lock.h"
#include "txn.h"
#include "db_am.h"
#include "btree.h"

/*
 * __db_new --
 *	Get a new page, preferably from the freelist.
 *
 * PUBLIC: int __db_new __P((DBC *, u_int32_t, PAGE **));
 */
int
__db_new(dbc, type, pagepp)
	DBC *dbc;
	u_int32_t type;
	PAGE **pagepp;
{
	DBMETA *meta;
	DB *dbp;
	DB_LOCK metalock;
	DB_LSN lsn;
	PAGE *h;
	db_pgno_t pgno, newnext;
	int extend, ret;

	dbp = dbc->dbp;
	meta = NULL;
	h = NULL;
	newnext = PGNO_INVALID;

	pgno = PGNO_BASE_MD;
	if ((ret = __db_lget(dbc,
	    LCK_ALWAYS, pgno, DB_LOCK_WRITE, 0, &metalock)) != 0)
		goto err;
	if ((ret = memp_fget(dbp->mpf, &pgno, 0, (PAGE **)&meta)) != 0)
		goto err;
	if (meta->free == PGNO_INVALID) {
		pgno = meta->last_pgno + 1;
		ZERO_LSN(lsn);
		extend = 1;
	} else {
		pgno = meta->free;
		if ((ret = memp_fget(dbp->mpf, &pgno, 0, &h)) != 0)
			goto err;

		/*
		 * We want to take the first page off the free list and
		 * then set meta->free to the that page's next_pgno, but
		 * we need to log the change first.
		 */
		newnext = h->next_pgno;
		lsn = h->lsn;
		extend = 0;
	}

	/*
	 * Log the allocation before fetching the new page.  If we
	 * don't have room in the log then we don't want to tell
	 * mpool to extend the file.
	 */
	if (DB_LOGGING(dbc)) {
		if ((ret = __db_pg_alloc_log(dbp->dbenv,
		    dbc->txn, &LSN(meta), 0, dbp->log_fileid,
		    &LSN(meta), &lsn, pgno,
		    (u_int32_t)type, newnext)) != 0)
			goto err;
	} else
		LSN_NOT_LOGGED(LSN(meta));

	if (meta->free != newnext) {
		meta->free = newnext;
		(void)memp_fset(dbp->mpf, (PAGE *)meta, DB_MPOOL_DIRTY);
	}

	if (extend == 1) {
		if ((ret = memp_fget(dbp->mpf, &pgno, DB_MPOOL_NEW, &h)) != 0)
			goto err;
		ZERO_LSN(h->lsn);
		h->pgno = pgno;
		meta->last_pgno++;
		DB_ASSERT(pgno == meta->last_pgno);
	}
	LSN(h) = LSN(meta);

	DB_ASSERT(TYPE(h) == P_INVALID);

	if (TYPE(h) != P_INVALID)
		return (__db_panic(dbp->dbenv, EINVAL));

	(void)memp_fput(dbp->mpf, (PAGE *)meta, DB_MPOOL_DIRTY);
	(void)__TLPUT(dbc, metalock);

	P_INIT(h, dbp->pgsize, h->pgno, PGNO_INVALID, PGNO_INVALID, 0, type);
	*pagepp = h;
	return (0);

err:	if (h != NULL)
		(void)memp_fput(dbp->mpf, h, 0);
	if (meta != NULL)
		(void)memp_fput(dbp->mpf, meta, 0);
	(void)__TLPUT(dbc, metalock);
	return (ret);
}

/*
 * __db_free --
 *	Add a page to the head of the freelist.
 *
 * PUBLIC: int __db_free __P((DBC *, PAGE *));
 */
int
__db_free(dbc, h)
	DBC *dbc;
	PAGE *h;
{
	DBMETA *meta;
	DB *dbp;
	DBT ldbt;
	DB_LOCK metalock;
	db_pgno_t pgno;
	u_int32_t dirty_flag;
	int ret, t_ret;

	dbp = dbc->dbp;

	/*
	 * Retrieve the metadata page and insert the page at the head of
	 * the free list.  If either the lock get or page get routines
	 * fail, then we need to put the page with which we were called
	 * back because our caller assumes we take care of it.
	 */
	dirty_flag = 0;
	pgno = PGNO_BASE_MD;
	if ((ret = __db_lget(dbc,
	     LCK_ALWAYS, pgno, DB_LOCK_WRITE, 0, &metalock)) != 0)
		goto err;
	if ((ret = memp_fget(dbp->mpf, &pgno, 0, (PAGE **)&meta)) != 0) {
		(void)__TLPUT(dbc, metalock);
		goto err;
	}

	DB_ASSERT(h->pgno != meta->free);
	/* Log the change. */
	if (DB_LOGGING(dbc)) {
		memset(&ldbt, 0, sizeof(ldbt));
		ldbt.data = h;
		ldbt.size = P_OVERHEAD;
		if ((ret = __db_pg_free_log(dbp->dbenv,
		    dbc->txn, &LSN(meta), 0, dbp->log_fileid, h->pgno,
		    &LSN(meta), &ldbt, meta->free)) != 0) {
			(void)memp_fput(dbp->mpf, (PAGE *)meta, 0);
			(void)__TLPUT(dbc, metalock);
			goto err;
		}
	} else
		LSN_NOT_LOGGED(LSN(meta));
	LSN(h) = LSN(meta);

	P_INIT(h, dbp->pgsize, h->pgno, PGNO_INVALID, meta->free, 0, P_INVALID);

	meta->free = h->pgno;

	/* Discard the metadata page. */
	if ((t_ret = memp_fput(dbp->mpf,
	    (PAGE *)meta, DB_MPOOL_DIRTY)) != 0 && ret == 0)
		ret = t_ret;
	if ((t_ret = __TLPUT(dbc, metalock)) != 0 && ret == 0)
		ret = t_ret;

	/* Discard the caller's page reference. */
	dirty_flag = DB_MPOOL_DIRTY;
err:	if ((t_ret = memp_fput(dbp->mpf, h, dirty_flag)) != 0 && ret == 0)
		ret = t_ret;

	/*
	 * XXX
	 * We have to unlock the caller's page in the caller!
	 */
	return (ret);
}

#ifdef DEBUG
/*
 * __db_lprint --
 *	Print out the list of locks currently held by a cursor.
 *
 * PUBLIC: int __db_lprint __P((DBC *));
 */
int
__db_lprint(dbc)
	DBC *dbc;
{
	DB *dbp;
	DB_LOCKREQ req;

	dbp = dbc->dbp;

	if (LOCKING_ON(dbp->dbenv)) {
		req.op = DB_LOCK_DUMP;
		lock_vec(dbp->dbenv, dbc->locker, 0, &req, 1, NULL);
	}
	return (0);
}
#endif

/*
 * __db_lget --
 *	The standard lock get call.
 *
 * PUBLIC: int __db_lget __P((DBC *,
 * PUBLIC:     int, db_pgno_t, db_lockmode_t, int, DB_LOCK *));
 */
int
__db_lget(dbc, flags, pgno, mode, lkflags, lockp)
	DBC *dbc;
	int flags, lkflags;
	db_pgno_t pgno;
	db_lockmode_t mode;
	DB_LOCK *lockp;
{
	DB *dbp;
	DB_ENV *dbenv;
	DB_LOCKREQ couple[2], *reqp;
	int ret;

	dbp = dbc->dbp;
	dbenv = dbp->dbenv;

	/*
	 * We do not always check if we're configured for locking before
	 * calling __db_lget to acquire the lock.
	 */
	if (CDB_LOCKING(dbenv)
	    || !LOCKING_ON(dbenv) || F_ISSET(dbc, DBC_COMPENSATE)
	    || (!LF_ISSET(LCK_ROLLBACK) && F_ISSET(dbc, DBC_RECOVER))
	    || (!LF_ISSET(LCK_ALWAYS) && F_ISSET(dbc, DBC_OPD))) {
		LOCK_INIT(*lockp);
		return (0);
	}

	dbc->lock.pgno = pgno;
	if (lkflags & DB_LOCK_RECORD)
		dbc->lock.type = DB_RECORD_LOCK;
	else
		dbc->lock.type = DB_PAGE_LOCK;
	lkflags &= ~DB_LOCK_RECORD;

	/*
	 * If the transaction enclosing this cursor has DB_LOCK_NOWAIT set,
	 * pass that along to the lock call.
	 */
	if (DB_NONBLOCK(dbc))
		lkflags |= DB_LOCK_NOWAIT;

	if (F_ISSET(dbc, DBC_DIRTY_READ) && mode == DB_LOCK_READ)
		mode = DB_LOCK_DIRTY;
	/*
	 * If the object not currently locked, acquire the lock and return,
	 * otherwise, lock couple.
	 */
	if (LF_ISSET(LCK_COUPLE)) {
		couple[0].op = DB_LOCK_GET;
		couple[0].obj = &dbc->lock_dbt;
		couple[0].mode = mode;
		couple[1].op = DB_LOCK_PUT;
		couple[1].lock = *lockp;

		ret = lock_vec(dbenv,
		    dbc->locker, lkflags, couple, 2, &reqp);
		if (ret == 0 || reqp == &couple[1])
			*lockp = couple[0].lock;
	} else {
		ret = lock_get(dbenv,
		    dbc->locker, lkflags, &dbc->lock_dbt, mode, lockp);
	}

	return (ret);
}
