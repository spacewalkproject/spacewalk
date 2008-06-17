/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: mp_fget.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <string.h>
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

#ifdef HAVE_FILESYSTEM_NOTZERO
static int __memp_fs_notzero
    __P((DB_ENV *, DB_MPOOLFILE *, MPOOLFILE *, db_pgno_t *));
#endif

/*
 * memp_fget --
 *	Get a page from the file.
 *
 * EXTERN: int memp_fget __P((DB_MPOOLFILE *, db_pgno_t *, u_int32_t, void *));
 */
int
memp_fget(dbmfp, pgnoaddr, flags, addrp)
	DB_MPOOLFILE *dbmfp;
	db_pgno_t *pgnoaddr;
	u_int32_t flags;
	void *addrp;
{
	BH *bhp;
	DB_ENV *dbenv;
	DB_MPOOL *dbmp;
	DB_HASHTAB *dbht;
	MPOOL *c_mp, *mp;
	MPOOLFILE *mfp;
	size_t n_bucket, n_cache, mf_offset;
	u_int32_t st_hsearch;
	int b_incr, bh_dirty_create, first, ret;

	dbmp = dbmfp->dbmp;
	dbenv = dbmp->dbenv;
	mp = dbmp->reginfo[0].primary;
	mfp = dbmfp->mfp;
#ifdef HAVE_RPC
	if (F_ISSET(dbenv, DB_ENV_RPCCLIENT))
		return (__dbcl_memp_fget(dbmfp, pgnoaddr, flags, addrp));
#endif

	PANIC_CHECK(dbenv);

	/*
	 * Validate arguments.
	 *
	 * !!!
	 * Don't test for DB_MPOOL_CREATE and DB_MPOOL_NEW flags for readonly
	 * files here, and create non-existent pages in readonly files if the
	 * flags are set, later.  The reason is that the hash access method
	 * wants to get empty pages that don't really exist in readonly files.
	 * The only alternative is for hash to write the last "bucket" all the
	 * time, which we don't want to do because one of our big goals in life
	 * is to keep database files small.  It's sleazy as hell, but we catch
	 * any attempt to actually write the file in memp_fput().
	 */
#define	OKFLAGS	\
    (DB_MPOOL_CREATE | DB_MPOOL_LAST | DB_MPOOL_NEW | DB_MPOOL_NEW_GROUP)
	if (flags != 0) {
		if ((ret = __db_fchk(dbenv, "memp_fget", flags, OKFLAGS)) != 0)
			return (ret);

		switch (flags) {
		case DB_MPOOL_CREATE:
		case DB_MPOOL_LAST:
		case DB_MPOOL_NEW:
		case DB_MPOOL_NEW_GROUP:
		case 0:
			break;
		default:
			return (__db_ferr(dbenv, "memp_fget", 1));
		}
	}

#ifdef DIAGNOSTIC
	/*
	 * XXX
	 * We want to switch threads as often as possible.  Yield every time
	 * we get a new page to ensure contention.
	 */
	if (DB_GLOBAL(db_pageyield))
		__os_yield(dbenv, 1);
#endif

	/* Initialize remaining local variables. */
	mf_offset = R_OFFSET(dbmp->reginfo, mfp);
	bhp = NULL;
	st_hsearch = 0;
	b_incr = bh_dirty_create = ret = 0;

	R_LOCK(dbenv, dbmp->reginfo);

	/*
	 * Check for the last, last + 1 or new group page requests.
	 *
	 * !!!
	 * DB_MPOOL_NEW_GROUP is undocumented -- the hash access method needs
	 * to allocate contiguous groups of pages in order to do subdatabases.
	 * We return the first page in the group, but the caller must put an
	 * LSN on the *last* page and write it, otherwise after a crash we may
	 * not create all of the pages we need to create.
	 */
	switch(flags) {
	case DB_MPOOL_LAST:
		*pgnoaddr = mfp->last_pgno;
		break;
	case DB_MPOOL_NEW:
		*pgnoaddr = mfp->last_pgno + 1;
		break;
	case DB_MPOOL_NEW_GROUP:
		*pgnoaddr = mfp->last_pgno + *pgnoaddr;
		break;
	default:
		break;
	}

	/*
	 * If we're returning a page after our current notion of the last-page,
	 * update the mpool end-of-file information.  Note: there's no way to
	 * un-instantiate this page, it's going to exist whether it's returned
	 * to us dirty or not.
	 */
	if (*pgnoaddr > mfp->last_pgno) {
		if (!LF_ISSET(
		    DB_MPOOL_NEW | DB_MPOOL_NEW_GROUP | DB_MPOOL_CREATE)) {
			ret = DB_PAGE_NOTFOUND;
			goto err;
		}
#ifdef HAVE_FILESYSTEM_NOTZERO
		if (__os_fs_notzero() &&
		    F_ISSET(&dbmfp->fh, DB_FH_VALID) && (ret =
		    __memp_fs_notzero(dbenv, dbmfp, mfp, pgnoaddr)) != 0)
			goto err;
#endif
		mfp->last_pgno = *pgnoaddr;

		bh_dirty_create = 1;
	} else
		bh_dirty_create = 0;

	/*
	 * Determine the hash bucket where this page will live, and get local
	 * pointers to the cache and its hash table.
	 */
	n_cache = NCACHE(mp, *pgnoaddr);
	c_mp = dbmp->reginfo[n_cache].primary;
	n_bucket = NBUCKET(c_mp, mf_offset, *pgnoaddr);
	dbht = R_ADDR(&dbmp->reginfo[n_cache], c_mp->htab);

	if (LF_ISSET(DB_MPOOL_NEW | DB_MPOOL_NEW_GROUP))
		goto alloc;

	/*
	 * If mmap'ing the file and the page is not past the end of the file,
	 * just return a pointer.
	 *
	 * The page may be past the end of the file, so check the page number
	 * argument against the original length of the file.  If we previously
	 * returned pages past the original end of the file, last_pgno will
	 * have been updated to match the "new" end of the file, and checking
	 * against it would return pointers past the end of the mmap'd region.
	 *
	 * If another process has opened the file for writing since we mmap'd
	 * it, we will start playing the game by their rules, i.e. everything
	 * goes through the cache.  All pages previously returned will be safe,
	 * as long as the correct locking protocol was observed.
	 *
	 * XXX
	 * We don't discard the map because we don't know when all of the
	 * pages will have been discarded from the process' address space.
	 * It would be possible to do so by reference counting the open
	 * pages from the mmap, but it's unclear to me that it's worth it.
	 */
	if (dbmfp->addr != NULL && F_ISSET(mfp, MP_CAN_MMAP)) {
		if (*pgnoaddr > mfp->orig_last_pgno) {
			/*
			 * !!!
			 * See the comment above about non-existent pages and
			 * the hash access method.
			 *
			 * Further, it's not an error to attempt to acquire an
			 * an extent-file page that doesn't yet exist, even if
			 * DB_MPOOL_CREATE is not set; we may just be doing a
			 * get from a gap in the record numbers.
			 *
			 * So, even if we're pretty sure the application is
			 * doing something wrong, let it go -- we'll complain
			 * if they ever try and write the page.
			 */
			if (!LF_ISSET(DB_MPOOL_CREATE)) {
				ret = DB_PAGE_NOTFOUND;
				goto err;
			}
		} else {
			*(void **)addrp =
			    R_ADDR(dbmfp, *pgnoaddr * mfp->stat.st_pagesize);
			++mfp->stat.st_map;
			goto done;
		}
	}

	/* Search the hash chain for the page. */
	for (bhp = SH_TAILQ_FIRST(&dbht[n_bucket], __bh);
	    bhp != NULL; bhp = SH_TAILQ_NEXT(bhp, hq, __bh)) {
		++st_hsearch;
		if (bhp->pgno != *pgnoaddr || bhp->mf_offset != mf_offset)
			continue;

		/* Increment the reference count. */
		if (bhp->ref == UINT16_T_MAX) {
			__db_err(dbenv,
			    "%s: page %lu: reference count overflow",
			    __memp_fn(dbmfp), (u_long)bhp->pgno);
			ret = EINVAL;
			goto err;
		}

		/*
		 * Increment the reference count.  We may discard the region
		 * lock as we evaluate and/or read the buffer, so we need to
		 * ensure that it doesn't move and that its contents remain
		 * unchanged.
		 */
		++bhp->ref;
		b_incr = 1;

		/*
		 * Any buffer we find might be trouble.
		 *
		 * BH_LOCKED --
		 * I/O is in progress.  Because we've incremented the buffer
		 * reference count, we know the buffer can't move.  Unlock
		 * the region lock, wait for the I/O to complete, and reacquire
		 * the region.
		 */
		for (first = 1;
		    F_ISSET(bhp, BH_LOCKED) && dbenv->db_mutexlocks;
		    first = 0) {
			R_UNLOCK(dbenv, dbmp->reginfo);

			/*
			 * Explicitly yield the processor if it's not the first
			 * pass through this loop -- if we don't, we might end
			 * up running to the end of our CPU quantum as we will
			 * simply be swapping between the two locks.
			 */
			if (!first)
				__os_yield(dbenv, 1);

			MUTEX_LOCK(dbenv, &bhp->mutex, dbenv->lockfhp);
			/* Wait for I/O to finish... */
			MUTEX_UNLOCK(dbenv, &bhp->mutex);
			R_LOCK(dbenv, dbmp->reginfo);
		}

		/*
		 * BH_TRASH --
		 * The contents of the buffer are garbage.  Shouldn't happen,
		 * and this read is likely to fail, but might as well try.
		 */
		if (F_ISSET(bhp, BH_TRASH))
			goto reread;

		/*
		 * BH_CALLPGIN --
		 * The buffer was converted so it could be written, and the
		 * contents need to be converted again.
		 */
		if (F_ISSET(bhp, BH_CALLPGIN)) {
			if ((ret = __memp_pg(dbmfp, bhp, 1)) != 0)
				goto err;
			F_CLR(bhp, BH_CALLPGIN);
		}

		++mfp->stat.st_cache_hit;
		*(void **)addrp = bhp->buf;
		goto done;
	}

alloc:	/* Allocate new buffer header and data space. */
	if ((ret = __memp_alloc(dbmp,
	    &dbmp->reginfo[n_cache], mfp, 0, NULL, &bhp)) != 0)
		goto err;

	/*
	 * Initialize the BH fields so that we can call the __memp_bhfree
	 * routine if an error occurs.
	 */
	memset(bhp, 0, sizeof(BH));
	bhp->ref = 1;
	bhp->pgno = *pgnoaddr;
	bhp->mf_offset = mf_offset;

	/* If we extended the file, make sure the page is never lost. */
	if (bh_dirty_create) {
		++c_mp->stat.st_page_dirty;
		F_SET(bhp, BH_DIRTY | BH_DIRTY_CREATE);
	} else
		++c_mp->stat.st_page_clean;

	/* Increment the count of buffers referenced by this MPOOLFILE. */
	++mfp->block_cnt;

	/*
	 * Prepend the bucket header to the head of the appropriate MPOOL
	 * bucket hash list.  Append the bucket header to the tail of the
	 * MPOOL LRU chain.
	 */
	SH_TAILQ_INSERT_HEAD(&dbht[n_bucket], bhp, hq, __bh);
	SH_TAILQ_INSERT_TAIL(&c_mp->bhq, bhp, q);

#ifdef DIAGNOSTIC
	if ((db_alignp_t)bhp->buf & (sizeof(size_t) - 1)) {
		__db_err(dbenv, "Internal error: BH data NOT size_t aligned.");
		ret = EINVAL;
		__memp_bhfree(dbmp, bhp, 1);
		goto err;
	}
#endif

	if ((ret = __db_shmutex_init(dbenv, &bhp->mutex,
	    R_OFFSET(dbmp->reginfo, &bhp->mutex) + DB_FCNTL_OFF_MPOOL,
	    0, &dbmp->reginfo[n_cache],
	    (REGMAINT *)R_ADDR(&dbmp->reginfo[n_cache], c_mp->maint_off)))
	    != 0) {
		__memp_bhfree(dbmp, bhp, 1);
		goto err;
	}

	/*
	 * If we created the page, zero it out and continue.
	 *
	 * !!!
	 * Note: DB_MPOOL_NEW specifically doesn't call the pgin function.
	 * If DB_MPOOL_CREATE is used, then the application's pgin function
	 * has to be able to handle pages of 0's -- if it uses DB_MPOOL_NEW,
	 * it can detect all of its page creates, and not bother.
	 *
	 * If we're running in diagnostic mode, smash any bytes on the
	 * page that are unknown quantities for the caller.
	 *
	 * Otherwise, read the page into memory, optionally creating it if
	 * DB_MPOOL_CREATE is set.
	 */
	if (LF_ISSET(DB_MPOOL_NEW | DB_MPOOL_NEW_GROUP)) {
		if (mfp->clear_len == 0)
			memset(bhp->buf, 0, mfp->stat.st_pagesize);
		else {
			memset(bhp->buf, 0, mfp->clear_len);
#if defined(DIAGNOSTIC) || defined(UMRW)
			memset(bhp->buf + mfp->clear_len, CLEAR_BYTE,
			    mfp->stat.st_pagesize - mfp->clear_len);
#endif
		}

		++mfp->stat.st_page_create;
	} else {
		/*
		 * It's possible for the read function to fail, which means
		 * that we fail as well.  Note, the __memp_pgread() function
		 * discards the region lock, so the buffer must be pinned
		 * down so that it cannot move and its contents are unchanged.
		 */
reread:		if ((ret = __memp_pgread(dbmfp,
		    bhp, LF_ISSET(DB_MPOOL_CREATE) ? 1 : 0)) != 0) {
			/*
			 * !!!
			 * Discard the buffer unless another thread is waiting
			 * on our I/O to complete.  It's OK to leave the buffer
			 * around, as the waiting thread will see the BH_TRASH
			 * flag set, and will not use the buffer.  If there's a
			 * waiter, we need to decrement our reference count.
			 */
			if (bhp->ref == 1)
				__memp_bhfree(dbmp, bhp, 1);
			else
				b_incr = 1;
			goto err;
		}

		++mfp->stat.st_cache_miss;
	}

	*(void **)addrp = bhp->buf;

done:	/* Update the chain search statistics. */
	if (st_hsearch) {
		++c_mp->stat.st_hash_searches;
		if (st_hsearch > c_mp->stat.st_hash_longest)
			c_mp->stat.st_hash_longest = st_hsearch;
		c_mp->stat.st_hash_examined += st_hsearch;
	}

	/* Update the file's reference count. */
	++dbmfp->pinref;

	R_UNLOCK(dbenv, dbmp->reginfo);

	return (0);

err:	/* Discard our reference. */
	if (b_incr)
		--bhp->ref;
	R_UNLOCK(dbenv, dbmp->reginfo);

	*(void **)addrp = NULL;
	return (ret);
}

/*
 * __memp_lastpgno --
 *	Return the last page in the file.
 *
 * PUBLIC: void __memp_lastpgno __P((DB_MPOOLFILE *, db_pgno_t *));
 */
void
__memp_lastpgno(dbmfp, pgnoaddr)
	DB_MPOOLFILE *dbmfp;
	db_pgno_t *pgnoaddr;
{
	DB_ENV *dbenv;
	DB_MPOOL *dbmp;

	dbmp = dbmfp->dbmp;
	dbenv = dbmp->dbenv;

	R_LOCK(dbenv, dbmp->reginfo);
	*pgnoaddr = dbmfp->mfp->last_pgno;
	R_UNLOCK(dbenv, dbmp->reginfo);
}

#ifdef HAVE_FILESYSTEM_NOTZERO
/*
 * __memp_fs_notzero --
 *	Initialize the underlying allocated pages in the file.
 */
static int
__memp_fs_notzero(dbenv, dbmfp, mfp, pgnoaddr)
	DB_ENV *dbenv;
	DB_MPOOLFILE *dbmfp;
	MPOOLFILE *mfp;
	db_pgno_t *pgnoaddr;
{
	DB_IO db_io;
	u_int32_t i, npages;
	size_t nw;
	int ret;
	char *fail, *page;

	/*
	 * Pages allocated by writing pages past end-of-file are not zeroed,
	 * on some systems.  Recovery could theoretically be fooled by a page
	 * showing up that contained garbage.  In order to avoid this, we
	 * have to write the pages out to disk, and flush them.  The reason
	 * for the flush is because if we don't sync, the allocation of another
	 * page subsequent to this one might reach the disk first, and if we
	 * crashed at the right moment, leave us with this page as the one
	 * allocated by writing a page past it in the file.
	 *
	 * Hash is the only access method that allocates groups of pages.  We
	 * know that it will use the existence of the last page in a group to
	 * signify that the entire group is OK; so, write all the pages but
	 * the last one in the group, flush them to disk, and then write the
	 * last one to disk and flush it.
	 */
	if ((ret = __os_calloc(dbenv, 1, mfp->stat.st_pagesize, &page)) != 0)
		return (ret);

	db_io.fhp = &dbmfp->fh;
	db_io.mutexp = dbmfp->mutexp;
	db_io.pagesize = db_io.bytes = mfp->stat.st_pagesize;
	db_io.buf = page;

	npages = *pgnoaddr - mfp->last_pgno;
	for (i = 1; i < npages; ++i) {
		db_io.pgno = mfp->last_pgno + i;
		if ((ret = __os_io(dbenv, &db_io, DB_IO_WRITE, &nw)) != 0) {
			fail = "write";
			goto err;
		}
	}
	if (i != 1 && (ret = __os_fsync(dbenv, &dbmfp->fh)) != 0) {
		fail = "sync";
		goto err;
	}

	db_io.pgno = mfp->last_pgno + npages;
	if ((ret = __os_io(dbenv, &db_io, DB_IO_WRITE, &nw)) != 0) {
		fail = "write";
		goto err;
	}
	if ((ret = __os_fsync(dbenv, &dbmfp->fh)) != 0) {
		fail = "sync";
err:		__db_err(dbenv, "%s: %s failed for page %lu",
		    __memp_fn(dbmfp), fail, (u_long)db_io.pgno);
	}

	__os_free(dbenv, page, mfp->stat.st_pagesize);
	return (ret);
}
#endif
