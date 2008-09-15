/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: mp_fput.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#endif

#ifdef  HAVE_RPC
#include "db_server.h"
#endif

#include "db_int.h"
#include "db_shash.h"
#include "mp.h"

#ifdef HAVE_RPC
#include "rpc_client_ext.h"
#endif

/*
 * memp_fput --
 *	Mpool file put function.
 *
 * EXTERN: int memp_fput __P((DB_MPOOLFILE *, void *, u_int32_t));
 */
int
memp_fput(dbmfp, pgaddr, flags)
	DB_MPOOLFILE *dbmfp;
	void *pgaddr;
	u_int32_t flags;
{
	BH *bhp;
	DB_ENV *dbenv;
	DB_MPOOL *dbmp;
	MPOOL *c_mp, *mp;
	int ret, wrote;

	dbmp = dbmfp->dbmp;
	dbenv = dbmp->dbenv;
	mp = dbmp->reginfo[0].primary;

#ifdef HAVE_RPC
	if (F_ISSET(dbenv, DB_ENV_RPCCLIENT))
		return (__dbcl_memp_fput(dbmfp, pgaddr, flags));
#endif

	PANIC_CHECK(dbenv);

	/* Validate arguments. */
	if (flags) {
		if ((ret = __db_fchk(dbenv, "memp_fput", flags,
		    DB_MPOOL_CLEAN | DB_MPOOL_DIRTY | DB_MPOOL_DISCARD)) != 0)
			return (ret);
		if ((ret = __db_fcchk(dbenv, "memp_fput",
		    flags, DB_MPOOL_CLEAN, DB_MPOOL_DIRTY)) != 0)
			return (ret);

		if (LF_ISSET(DB_MPOOL_DIRTY) && F_ISSET(dbmfp, MP_READONLY)) {
			__db_err(dbenv,
			    "%s: dirty flag set for readonly file page",
			    __memp_fn(dbmfp));
			return (EACCES);
		}
	}

	R_LOCK(dbenv, dbmp->reginfo);

	/* Decrement the pinned reference count. */
	if (dbmfp->pinref == 0) {
		__db_err(dbenv,
		    "%s: more pages returned than retrieved", __memp_fn(dbmfp));
		R_UNLOCK(dbenv, dbmp->reginfo);
		return (EINVAL);
	} else
		--dbmfp->pinref;

	/*
	 * If we're mapping the file, there's nothing to do.  Because we can
	 * stop mapping the file at any time, we have to check on each buffer
	 * to see if the address we gave the application was part of the map
	 * region.
	 */
	if (dbmfp->addr != NULL && pgaddr >= dbmfp->addr &&
	    (u_int8_t *)pgaddr <= (u_int8_t *)dbmfp->addr + dbmfp->len) {
		R_UNLOCK(dbenv, dbmp->reginfo);
		return (0);
	}

	/* Convert the page address to a buffer header. */
	bhp = (BH *)((u_int8_t *)pgaddr - SSZA(BH, buf));

	/* Convert the buffer header to a cache. */
	c_mp = BH_TO_CACHE(dbmp, bhp);

/* UNLOCK THE REGION, LOCK THE CACHE. */

	/* Set/clear the page bits. */
	if (LF_ISSET(DB_MPOOL_CLEAN) &&
	    F_ISSET(bhp, BH_DIRTY) && !F_ISSET(bhp, BH_DIRTY_CREATE)) {
		++c_mp->stat.st_page_clean;
		DB_ASSERT(c_mp->stat.st_page_dirty != 0);
		--c_mp->stat.st_page_dirty;
		F_CLR(bhp, BH_DIRTY);
	}
	if (LF_ISSET(DB_MPOOL_DIRTY) && !F_ISSET(bhp, BH_DIRTY)) {
		DB_ASSERT(c_mp->stat.st_page_clean != 0);
		--c_mp->stat.st_page_clean;
		++c_mp->stat.st_page_dirty;
		F_SET(bhp, BH_DIRTY);
	}
	if (LF_ISSET(DB_MPOOL_DISCARD))
		F_SET(bhp, BH_DISCARD);

	/*
	 * If the buffer is dirty and scheduled to be written as part of a
	 * checkpoint, we no longer know the log is up-to-date -- set a flag
	 * to force a log flush when the buffer is written.  The flag has to
	 * be set here (and not below where we call memp_bhwrite()), because
	 * the actual write may not be done as part of a memp_fput() call,
	 * but rather as part of a memp_sync() call, if the thread dirtying
	 * the buffer manages to acquire and release the buffer after the
	 * checkpoint thread has collected a list of buffers to write but
	 * before it actually writes them.
	 */
	if (F_ISSET(bhp, BH_DIRTY) && F_ISSET(bhp, BH_SYNC))
		F_SET(bhp, BH_SYNC_LOGFLSH);

	/*
	 * Check for a reference count going to zero.  This can happen if the
	 * application returns a page twice.
	 */
	if (bhp->ref == 0) {
		__db_err(dbenv, "%s: page %lu: unpinned page returned",
		    __memp_fn(dbmfp), (u_long)bhp->pgno);
		R_UNLOCK(dbenv, dbmp->reginfo);
		return (EINVAL);
	}

	/*
	 * If more than one reference to the page, we're done.  Ignore the
	 * discard flags (for now) and leave it at its position in the LRU
	 * chain.  The rest gets done at last reference close.
	 */
	if (--bhp->ref > 0) {
		R_UNLOCK(dbenv, dbmp->reginfo);
		return (0);
	}

	/*
	 * Move the buffer to the head/tail of the LRU chain.  We do this
	 * before writing the buffer for checkpoint purposes, as the write
	 * can discard the region lock and allow another process to acquire
	 * buffer.  We could keep that from happening, but there seems no
	 * reason to do so.
	 */
	SH_TAILQ_REMOVE(&c_mp->bhq, bhp, q, __bh);
	if (F_ISSET(bhp, BH_DISCARD))
		SH_TAILQ_INSERT_HEAD(&c_mp->bhq, bhp, q, __bh);
	else
		SH_TAILQ_INSERT_TAIL(&c_mp->bhq, bhp, q);

	/*
	 * If this buffer is scheduled for writing because of a checkpoint, we
	 * need to write it (if it's dirty), or update the checkpoint counters
	 * (if it's not dirty).  If we try to write it and can't, that's not
	 * necessarily an error as it's possible the application didn't have
	 * permission to write the underlying file -- in that case, set a flag
	 * so that the next time the memp_sync function is called the buffer is
	 * written there, as the checkpoint thread of control better be able to
	 * write all of the files.
	 */
	if (F_ISSET(bhp, BH_SYNC)) {
		if (F_ISSET(bhp, BH_DIRTY)) {
			if (!F_ISSET(bhp, BH_LOCKED) && (__memp_bhwrite(dbmp,
			    dbmfp->mfp, bhp, 0, NULL, &wrote) != 0 || !wrote))
				F_SET(mp, MP_LSN_RETRY);
		} else {
			F_CLR(bhp, BH_SYNC);

			--mp->lsn_cnt;
			--dbmfp->mfp->lsn_cnt;
		}
	}

	R_UNLOCK(dbenv, dbmp->reginfo);
	return (0);
}
