/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */
/*
 * Copyright (c) 1990, 1993, 1994
 *	Margo Seltzer.  All rights reserved.
 */
/*
 * Copyright (c) 1990, 1993, 1994
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Margo Seltzer.
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
static const char revid[] = "$Id: hash.c,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <stdlib.h>
#include <string.h>
#endif

#include "db_int.h"
#include "db_page.h"
#include "db_am.h"
#include "db_ext.h"
#include "db_shash.h"
#include "db_swap.h"
#include "hash.h"
#include "btree.h"
#include "lock.h"
#include "log.h"
#include "mp.h"
#include "txn.h"

static int  __ham_bulk __P((DBC *, DBT *, u_int32_t));
static int  __ham_c_close __P((DBC *, db_pgno_t, int *));
static int  __ham_c_del __P((DBC *));
static int  __ham_c_destroy __P((DBC *));
static int  __ham_c_get __P((DBC *, DBT *, DBT *, u_int32_t, db_pgno_t *));
static int  __ham_c_put __P((DBC *, DBT *, DBT *, u_int32_t, db_pgno_t *));
static int  __ham_c_writelock __P((DBC *));
static int  __ham_dup_return __P((DBC *, DBT *, u_int32_t));
static int  __ham_expand_table __P((DBC *));
static int  __ham_init_htab __P((DBC *,
		const char *, db_pgno_t, u_int32_t, u_int32_t));
static int  __ham_lookup __P((DBC *,
		const DBT *, u_int32_t, db_lockmode_t, db_pgno_t *));
static int  __ham_overwrite __P((DBC *, DBT *, u_int32_t));

/*
 * __ham_metachk --
 *
 * PUBLIC: int __ham_metachk __P((DB *, const char *, HMETA *));
 */
int
__ham_metachk(dbp, name, hashm)
	DB *dbp;
	const char *name;
	HMETA *hashm;
{
	DB_ENV *dbenv;
	u_int32_t vers;
	int ret;

	dbenv = dbp->dbenv;

	/*
	 * At this point, all we know is that the magic number is for a Hash.
	 * Check the version, the database may be out of date.
	 */
	vers = hashm->dbmeta.version;
	if (F_ISSET(dbp, DB_AM_SWAP))
		M_32_SWAP(vers);
	switch (vers) {
	case 4:
	case 5:
	case 6:
		__db_err(dbenv,
		    "%s: hash version %lu requires a version upgrade",
		    name, (u_long)vers);
		return (DB_OLD_VERSION);
	case 7:
		break;
	default:
		__db_err(dbenv,
		    "%s: unsupported hash version: %lu", name, (u_long)vers);
		return (EINVAL);
	}

	/* Swap the page if we need to. */
	if (F_ISSET(dbp, DB_AM_SWAP) && (ret = __ham_mswap((PAGE *)hashm)) != 0)
		return (ret);

	/* Check the type. */
	if (dbp->type != DB_HASH && dbp->type != DB_UNKNOWN)
		return (EINVAL);
	dbp->type = DB_HASH;
	DB_ILLEGAL_METHOD(dbp, DB_OK_HASH);

	/*
	 * Check application info against metadata info, and set info, flags,
	 * and type based on metadata info.
	 */
	if ((ret = __db_fchk(dbenv,
	    "DB->open", hashm->dbmeta.flags,
	    DB_HASH_DUP | DB_HASH_SUBDB | DB_HASH_DUPSORT)) != 0)
		return (ret);

	if (F_ISSET(&hashm->dbmeta, DB_HASH_DUP))
		F_SET(dbp, DB_AM_DUP);
	else
		if (F_ISSET(dbp, DB_AM_DUP)) {
			__db_err(dbenv,
		"%s: DB_DUP specified to open method but not set in database",
			    name);
			return (EINVAL);
		}

	if (F_ISSET(&hashm->dbmeta, DB_HASH_SUBDB))
		F_SET(dbp, DB_AM_SUBDB);
	else
		if (F_ISSET(dbp, DB_AM_SUBDB)) {
			__db_err(dbenv,
	    "%s: multiple databases specified but not supported in file",
			name);
			return (EINVAL);
		}

	if (F_ISSET(&hashm->dbmeta, DB_HASH_DUPSORT)) {
		if (dbp->dup_compare == NULL)
			dbp->dup_compare = __bam_defcmp;
	} else
		if (dbp->dup_compare != NULL) {
			__db_err(dbenv,
		"%s: duplicate sort function specified but not set in database",
			    name);
			return (EINVAL);
		}

	/* Set the page size. */
	dbp->pgsize = hashm->dbmeta.pagesize;

	/* Copy the file's ID. */
	memcpy(dbp->fileid, hashm->dbmeta.uid, DB_FILE_ID_LEN);

	return (0);
}

/*
 * __ham_open --
 *
 * PUBLIC: int __ham_open __P((DB *, const char *, db_pgno_t, u_int32_t));
 */
int
__ham_open(dbp, name, base_pgno, flags)
	DB *dbp;
	const char *name;
	db_pgno_t base_pgno;
	u_int32_t flags;
{
	DB_ENV *dbenv;
	DBC *dbc;
	HASH_CURSOR *hcp;
	HASH *hashp;
	int need_sync, ret, t_ret;

	dbc = NULL;
	dbenv = dbp->dbenv;
	need_sync = 0;

	/* Initialize the remaining fields/methods of the DB. */
	dbp->stat = __ham_stat;

	/*
	 * Get a cursor.  If DB_CREATE is specified, we may be creating
	 * pages, and to do that safely in CDB we need a write cursor.
	 * In STD_LOCKING mode, we'll synchronize using the meta page
	 * lock instead.
	 */
	if ((ret = dbp->cursor(dbp,
	    dbp->open_txn, &dbc, LF_ISSET(DB_CREATE) && CDB_LOCKING(dbenv) ?
	    DB_WRITECURSOR : 0)) != 0)
		return (ret);

	hcp = (HASH_CURSOR *)dbc->internal;
	hashp = dbp->h_internal;
	hashp->meta_pgno = base_pgno;
	if ((ret = __ham_get_meta(dbc)) != 0)
		goto err1;

	/*
	 * If this is a new file, initialize it, and put it back dirty.
	 *
	 * Initialize the hdr structure.
	 */
	if (hcp->hdr->dbmeta.magic == DB_HASHMAGIC) {
		/* File exists, verify the data in the header. */
		if (hashp->h_hash == NULL)
			hashp->h_hash = hcp->hdr->dbmeta.version < 5
			? __ham_func4 : __ham_func5;
		if (!F_ISSET(dbp, DB_RDONLY) &&
		    hashp->h_hash(dbp,
		    CHARKEY, sizeof(CHARKEY)) != hcp->hdr->h_charkey) {
			__db_err(dbp->dbenv,
			    "hash: incompatible hash function");
			ret = EINVAL;
			goto err2;
		}
		if (F_ISSET(&hcp->hdr->dbmeta, DB_HASH_DUP))
			F_SET(dbp, DB_AM_DUP);
		if (F_ISSET(&hcp->hdr->dbmeta, DB_HASH_DUPSORT))
			F_SET(dbp, DB_AM_DUPSORT);
		if (F_ISSET(&hcp->hdr->dbmeta, DB_HASH_SUBDB))
			F_SET(dbp, DB_AM_SUBDB);

		/* We must initialize last_pgno, it could be stale. */
		if (!F_ISSET(dbp, DB_AM_RDONLY) &&
		    dbp->meta_pgno == PGNO_BASE_MD) {
			if ((ret = __ham_dirty_meta(dbc)) != 0)
				goto err2;
			__memp_lastpgno(dbp->mpf, &hcp->hdr->dbmeta.last_pgno);
		}
	} else if (!IS_RECOVERING(dbenv)) {
		/*
		 * File does not exist, we must initialize the header.  If
		 * locking is enabled that means getting a write lock first.
		 * During recovery the meta page will be in the log.
		 */
		dbc->lock.pgno = base_pgno;

		if (STD_LOCKING(dbc) &&
		    ((ret = lock_put(dbenv, &hcp->hlock)) != 0 ||
		    (ret = lock_get(dbenv, dbc->locker,
		    DB_NONBLOCK(dbc) ? DB_LOCK_NOWAIT : 0,
		    &dbc->lock_dbt, DB_LOCK_WRITE, &hcp->hlock)) != 0))
			goto err2;
		else if (CDB_LOCKING(dbp->dbenv)) {
			DB_ASSERT(LF_ISSET(DB_CREATE));
			if ((ret = lock_get(dbenv, dbc->locker,
			    DB_LOCK_UPGRADE, &dbc->lock_dbt, DB_LOCK_WRITE,
			    &dbc->mylock)) != 0)
				goto err2;
		}
		if ((ret = __ham_init_htab(dbc, name,
		    base_pgno, hashp->h_nelem, hashp->h_ffactor)) != 0)
			goto err2;

		need_sync = 1;
	}

err2:	/* Release the meta data page */
	if ((t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;
err1:	if ((t_ret  = dbc->c_close(dbc)) != 0 && ret == 0)
		ret = t_ret;

	/* Sync the file so that we know that the meta data goes to disk. */
	if (ret == 0 && need_sync)
		ret = dbp->sync(dbp, 0);
#if CONFIG_TEST
	if (ret == 0)
		DB_TEST_RECOVERY(dbp, DB_TEST_POSTSYNC, ret, name);

DB_TEST_RECOVERY_LABEL
#endif

	return (ret);
}

/************************** LOCAL CREATION ROUTINES **********************/
/*
 * Returns 0 on No Error
 */
static int
__ham_init_htab(dbc, name, pgno, nelem, ffactor)
	DBC *dbc;
	const char *name;
	db_pgno_t pgno;
	u_int32_t nelem, ffactor;
{
	DB *dbp;
	DB_LOCK metalock;
	DB_LSN orig_lsn;
	DBMETA *mmeta;
	HASH_CURSOR *hcp;
	HASH *hashp;
	PAGE *h;
	db_pgno_t mpgno;
	int32_t l2, nbuckets;
	int dirty_mmeta, i, ret, t_ret;

	hcp = (HASH_CURSOR *)dbc->internal;
	dbp = dbc->dbp;
	hashp = dbp->h_internal;
	mmeta = NULL;
	h = NULL;
	ret = 0;
	dirty_mmeta = 0;
	LOCK_INIT(metalock);

	if (hashp->h_hash == NULL)
		hashp->h_hash = DB_HASHVERSION < 5 ? __ham_func4 : __ham_func5;

	if (nelem != 0 && ffactor != 0) {
		nelem = (nelem - 1) / ffactor + 1;
		l2 = __db_log2(nelem > 2 ? nelem : 2);
	} else
		l2 = 1;
	nbuckets = 1 << l2;

	orig_lsn = hcp->hdr->dbmeta.lsn;
	memset(hcp->hdr, 0, sizeof(HMETA));
	ZERO_LSN(hcp->hdr->dbmeta.lsn);
	hcp->hdr->dbmeta.pgno = pgno;
	hcp->hdr->dbmeta.magic = DB_HASHMAGIC;
	hcp->hdr->dbmeta.version = DB_HASHVERSION;
	hcp->hdr->dbmeta.pagesize = dbp->pgsize;
	hcp->hdr->dbmeta.type = P_HASHMETA;
	hcp->hdr->dbmeta.free = PGNO_INVALID;
	hcp->hdr->dbmeta.last_pgno = pgno;
	hcp->hdr->max_bucket = hcp->hdr->high_mask = nbuckets - 1;
	hcp->hdr->low_mask = (nbuckets >> 1) - 1;
	hcp->hdr->ffactor = ffactor;
	hcp->hdr->h_charkey = hashp->h_hash(dbp, CHARKEY, sizeof(CHARKEY));
	memcpy(hcp->hdr->dbmeta.uid, dbp->fileid, DB_FILE_ID_LEN);

	if (F_ISSET(dbp, DB_AM_DUP))
		F_SET(&hcp->hdr->dbmeta, DB_HASH_DUP);
	if (F_ISSET(dbp, DB_AM_SUBDB))
		F_SET(&hcp->hdr->dbmeta, DB_HASH_SUBDB);
	if (dbp->dup_compare != NULL)
		F_SET(&hcp->hdr->dbmeta, DB_HASH_DUPSORT);

	if ((ret = memp_fset(dbp->mpf, hcp->hdr, DB_MPOOL_DIRTY)) != 0)
		goto err;

	mmeta = (DBMETA *) hcp->hdr;
	if (F_ISSET(dbp, DB_AM_SUBDB)) {
		/*
		 * If this is a subdatabase, then we need to get the LSN off
		 * the master meta data page because that's where free pages
		 * are linked and during recovery we need to access that page
		 * and roll it backward/forward correctly with respect to LSN.
		 */
		mpgno = PGNO_BASE_MD;
		if ((ret = __db_lget(dbc,
		   0, mpgno, DB_LOCK_WRITE, 0, &metalock)) != 0)
			goto err;
		if ((ret = memp_fget(dbp->mpf,
		    &mpgno, 0, (PAGE **)&mmeta)) != 0)
			goto err;
	}

	/*
	 * Create the first and second buckets pages so that we have the
	 * page numbers for them and we can store that page number in the
	 * meta-data header (spares[0]).
	 */
	hcp->hdr->spares[0] = mmeta->last_pgno + 1;

	/* Fill in the last fields of the meta data page. */
	for (i = 1; i <= l2; i++)
		hcp->hdr->spares[i] = hcp->hdr->spares[0];
	for (; i < NCACHED; i++)
		hcp->hdr->spares[i] = PGNO_INVALID;

	/*
	 * Before we are about to put any dirty pages, we need to log
	 * the meta-data page create.
	 */
	ret = __db_log_page(dbp, name, &orig_lsn, pgno, (PAGE *)hcp->hdr);

	if (dbp->open_txn != NULL) {
		if ((t_ret = __ham_groupalloc_log(dbp->dbenv,
		    dbp->open_txn, &LSN(mmeta), 0, dbp->log_fileid,
		    &LSN(mmeta), hcp->hdr->spares[0],
		    hcp->hdr->max_bucket + 1, mmeta->free)) != 0 && ret == 0)
			ret = t_ret;
		if (ret == 0) {
			/* need to update real LSN for buffer manager */
			dirty_mmeta = 1;
		}
	}

	pgno = nbuckets;
	if ((t_ret = memp_fget(dbp->mpf, &pgno, DB_MPOOL_NEW_GROUP, &h)) != 0) {
		if (ret == 0)
			ret = t_ret;
		goto err;
	}

	DB_ASSERT(pgno == hcp->hdr->spares[0] + (nbuckets - 1));
	mmeta->last_pgno = pgno;

	P_INIT(h, dbp->pgsize, pgno, PGNO_INVALID, PGNO_INVALID, 0, P_HASH);

	DB_TEST_RECOVERY(dbp, DB_TEST_POSTLOG, ret, name);

DB_TEST_RECOVERY_LABEL
err:	if (h != NULL &&
	    (t_ret = memp_fput(dbp->mpf, h, DB_MPOOL_DIRTY)) != 0 && ret == 0)
		ret = t_ret;

	if (F_ISSET(dbp, DB_AM_SUBDB) && mmeta != NULL)
		if ((t_ret = memp_fput(dbp->mpf, mmeta,
		    dirty_mmeta ? DB_MPOOL_DIRTY : 0)) != 0 && ret == 0)
			ret = t_ret;
	(void)__TLPUT(dbc, metalock);

	return (ret);
}

/*
 * __ham_quick_delete --
 *	When performing a DB->del operation that does not involve secondary
 *	indices and is not removing an off-page duplicate tree, we can
 *	speed things up substantially by removing the entire duplicate
 *	set, if any is present, in one operation, rather than by conjuring
 *	up and deleting each of the items individually.  (All are stored
 *	in one big HKEYDATA structure.)  We don't bother to distinguish
 *	on-page duplicate sets from single, non-dup items;  they're deleted
 *	in exactly the same way.
 *
 *	This function is called by __db_delete when the appropriate
 *	conditions are met, and it performs the delete in the optimized way.
 *
 *	The cursor should be set to the first item in the duplicate
 *	set, or to the sole key/data pair when the key does not have a
 *	duplicate set, before the function is called.
 *
 * PUBLIC: int __ham_quick_delete __P((DBC *));
 */
int
__ham_quick_delete(dbc)
	DBC *dbc;
{
	HASH_CURSOR *hcp;
	int ret, t_ret;

	hcp = (HASH_CURSOR *)dbc->internal;
	if ((ret = __ham_get_meta(dbc)) != 0)
		return (ret);

	/* Assert that we're not using secondary indices. */
	DB_ASSERT(!F_ISSET(dbc->dbp, DB_AM_SECONDARY));
	/*
	 * We should assert that we're not a primary either, but that
	 * would require grabbing the dbp's mutex, so we don't bother.
	 */

	/* Assert that we're set, but not to an off-page duplicate. */
	DB_ASSERT(IS_INITIALIZED(dbc));
	DB_ASSERT(hcp->opd == NULL);

	ret = __ham_del_pair(dbc, 1);

	if ((t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;

	return (ret);
}

/* ****************** CURSORS ********************************** */
/*
 * __ham_c_init --
 *	Initialize the hash-specific portion of a cursor.
 *
 * PUBLIC: int __ham_c_init __P((DBC *));
 */
int
__ham_c_init(dbc)
	DBC *dbc;
{
	DB_ENV *dbenv;
	HASH_CURSOR *new_curs;
	int ret;

	dbenv = dbc->dbp->dbenv;
	if ((ret = __os_calloc(dbenv,
	    1, sizeof(struct cursor_t), &new_curs)) != 0)
		return (ret);
	if ((ret = __os_malloc(dbenv,
	    dbc->dbp->pgsize, &new_curs->split_buf)) != 0) {
		__os_free(dbenv, new_curs, sizeof(*new_curs));
		return (ret);
	}

	dbc->internal = (DBC_INTERNAL *) new_curs;
	dbc->c_close = __db_c_close;
	dbc->c_count = __db_c_count;
	dbc->c_del = __db_c_del;
	dbc->c_dup = __db_c_dup;
	dbc->c_get = dbc->c_real_get = __db_c_get;
	dbc->c_pget = __db_c_pget;
	dbc->c_put = __db_c_put;
	dbc->c_am_bulk = __ham_bulk;
	dbc->c_am_close = __ham_c_close;
	dbc->c_am_del = __ham_c_del;
	dbc->c_am_destroy = __ham_c_destroy;
	dbc->c_am_get = __ham_c_get;
	dbc->c_am_put = __ham_c_put;
	dbc->c_am_writelock = __ham_c_writelock;

	__ham_item_init(dbc);

	return (0);
}

/*
 * __ham_c_close --
 *	Close down the cursor from a single use.
 */
static int
__ham_c_close(dbc, root_pgno, rmroot)
	DBC *dbc;
	db_pgno_t root_pgno;
	int *rmroot;
{
	HASH_CURSOR *hcp;
	HKEYDATA *dp;
	int doroot, gotmeta, ret, t_ret;
	u_int32_t dirty;

	COMPQUIET(rmroot, 0);
	dirty = 0;
	doroot = gotmeta = ret = 0;
	hcp = (HASH_CURSOR *) dbc->internal;

	/* Check for off page dups. */
	if (dbc->internal->opd != NULL) {
		if ((ret = __ham_get_meta(dbc)) != 0)
			goto done;
		gotmeta = 1;
		if ((ret = __ham_get_cpage(dbc, DB_LOCK_READ)) != 0)
			goto out;
		dp = (HKEYDATA *)H_PAIRDATA(hcp->page, hcp->indx);

		/* If its not a dup we aborted before we changed it. */
		if (HPAGE_PTYPE(dp) == H_OFFDUP)
			memcpy(&root_pgno,
			    HOFFPAGE_PGNO(dp), sizeof(db_pgno_t));
		else
			root_pgno = PGNO_INVALID;

		if ((ret =
		    hcp->opd->c_am_close(hcp->opd, root_pgno, &doroot)) != 0)
			goto out;
		if (doroot != 0) {
			if ((ret = __ham_del_pair(dbc, 1)) != 0)
				goto out;
			dirty = DB_MPOOL_DIRTY;
		}
	}

out:	if (hcp->page != NULL && (t_ret =
	    memp_fput(dbc->dbp->mpf, hcp->page, dirty)) != 0 && ret == 0)
		ret = t_ret;
	if (gotmeta != 0 && (t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;

done:
	__ham_item_init(dbc);
	return (ret);
}

/*
 * __ham_c_destroy --
 *	Cleanup the access method private part of a cursor.
 */
static int
__ham_c_destroy(dbc)
	DBC *dbc;
{
	HASH_CURSOR *hcp;

	hcp = (HASH_CURSOR *)dbc->internal;
	if (hcp->split_buf != NULL)
		__os_free(dbc->dbp->dbenv, hcp->split_buf, dbc->dbp->pgsize);
	__os_free(dbc->dbp->dbenv, hcp, sizeof(HASH_CURSOR));

	return (0);
}

/*
 * __ham_c_count --
 *	Return a count of on-page duplicates.
 *
 * PUBLIC: int __ham_c_count __P((DBC *, db_recno_t *));
 */
int
__ham_c_count(dbc, recnop)
	DBC *dbc;
	db_recno_t *recnop;
{
	DB *dbp;
	HASH_CURSOR *hcp;
	db_indx_t len;
	db_recno_t recno;
	int ret, t_ret;
	u_int8_t *p, *pend;

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *) dbc->internal;

	recno = 0;

	if ((ret = __ham_get_cpage(dbc, DB_LOCK_READ)) != 0)
		return (ret);

	switch (HPAGE_PTYPE(H_PAIRDATA(hcp->page, hcp->indx))) {
	case H_KEYDATA:
	case H_OFFPAGE:
		recno = 1;
		break;
	case H_DUPLICATE:
		p = HKEYDATA_DATA(H_PAIRDATA(hcp->page, hcp->indx));
		pend = p +
		    LEN_HDATA(hcp->page, dbp->pgsize, hcp->indx);
		for (; p < pend; recno++) {
			/* p may be odd, so copy rather than just dereffing */
			memcpy(&len, p, sizeof(db_indx_t));
			p += 2 * sizeof(db_indx_t) + len;
		}

		break;
	default:
		ret = __db_unknown_type(dbp->dbenv, "__ham_c_count",
		    HPAGE_PTYPE(H_PAIRDATA(hcp->page, hcp->indx)));
		goto err;
	}

	*recnop = recno;

err:	if ((t_ret = memp_fput(dbc->dbp->mpf, hcp->page, 0)) != 0 && ret == 0)
		ret = t_ret;
	hcp->page = NULL;
	return (ret);
}

static int
__ham_c_del(dbc)
	DBC *dbc;
{
	DB *dbp;
	DBT repldbt;
	HASH_CURSOR *hcp;
	int ret, t_ret;

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;

	if (F_ISSET(hcp, H_DELETED))
		return (DB_NOTFOUND);

	if ((ret = __ham_get_meta(dbc)) != 0)
		goto out;

	if ((ret = __ham_get_cpage(dbc, DB_LOCK_WRITE)) != 0)
		goto out;

	/* Off-page duplicates. */
	if (HPAGE_TYPE(hcp->page, H_DATAINDEX(hcp->indx)) == H_OFFDUP)
		goto out;

	if (F_ISSET(hcp, H_ISDUP)) { /* On-page duplicate. */
		if (hcp->dup_off == 0 &&
		    DUP_SIZE(hcp->dup_len) == LEN_HDATA(hcp->page,
		    hcp->hdr->dbmeta.pagesize, hcp->indx))
			ret = __ham_del_pair(dbc, 1);
		else {
			repldbt.flags = 0;
			F_SET(&repldbt, DB_DBT_PARTIAL);
			repldbt.doff = hcp->dup_off;
			repldbt.dlen = DUP_SIZE(hcp->dup_len);
			repldbt.size = 0;
			repldbt.data = HKEYDATA_DATA(H_PAIRDATA(hcp->page,
			    hcp->indx));
			if ((ret = __ham_replpair(dbc, &repldbt, 0)) == 0) {
				hcp->dup_tlen -= DUP_SIZE(hcp->dup_len);
				F_SET(hcp, H_DELETED);
				ret = __ham_c_update(dbc,
				    DUP_SIZE(hcp->dup_len), 0, 1);
			}
		}

	} else /* Not a duplicate */
		ret = __ham_del_pair(dbc, 1);

out:	if (ret == 0 && hcp->page != NULL) {
		ret = memp_fput(dbp->mpf, hcp->page, DB_MPOOL_DIRTY);
		hcp->page = NULL;
	}
	if ((t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;
	return (ret);
}

/*
 * __ham_c_dup --
 *	Duplicate a hash cursor, such that the new one holds appropriate
 *	locks for the position of the original.
 *
 * PUBLIC: int __ham_c_dup __P((DBC *, DBC *));
 */
int
__ham_c_dup(orig_dbc, new_dbc)
	DBC *orig_dbc, *new_dbc;
{
	HASH_CURSOR *orig, *new;

	orig = (HASH_CURSOR *)orig_dbc->internal;
	new = (HASH_CURSOR *)new_dbc->internal;

	new->bucket = orig->bucket;
	new->lbucket = orig->lbucket;
	new->dup_off = orig->dup_off;
	new->dup_len = orig->dup_len;
	new->dup_tlen = orig->dup_tlen;

	if (F_ISSET(orig, H_DELETED))
		F_SET(new, H_DELETED);
	if (F_ISSET(orig, H_ISDUP))
		F_SET(new, H_ISDUP);

	/*
	 * If the old cursor held a lock and we're not in transactions, get one
	 * for the new one.   The reason that we don't need a new lock if we're
	 * in a transaction is because we already hold a lock and will continue
	 * to do so until commit, so there is no point in reaquiring it. We
	 * don't know if the old lock was a read or write lock, but it doesn't
	 * matter. We'll get a read lock.  We know that this locker already
	 * holds a lock of the correct type, so if we need a write lock and
	 * request it, we know that we'll get it.
	 */
	if (!LOCK_ISSET(orig->lock) || orig_dbc->txn != NULL)
		return (0);

	return (__ham_lock_bucket(new_dbc, DB_LOCK_READ));
}

static int
__ham_c_get(dbc, key, data, flags, pgnop)
	DBC *dbc;
	DBT *key;
	DBT *data;
	u_int32_t flags;
	db_pgno_t *pgnop;
{
	DB *dbp;
	HASH_CURSOR *hcp;
	db_lockmode_t lock_type;
	int get_key, ret, t_ret;

	hcp = (HASH_CURSOR *)dbc->internal;
	dbp = dbc->dbp;

	/* Clear OR'd in additional bits so we can check for flag equality. */
	if (F_ISSET(dbc, DBC_RMW))
		lock_type = DB_LOCK_WRITE;
	else
		lock_type = DB_LOCK_READ;

	if ((ret = __ham_get_meta(dbc)) != 0)
		return (ret);
	hcp->seek_size = 0;

	ret = 0;
	get_key = 1;
	switch (flags) {
	case DB_PREV_NODUP:
		F_SET(hcp, H_NEXT_NODUP);
		/* FALLTHROUGH */
	case DB_PREV:
		if (IS_INITIALIZED(dbc)) {
			ret = __ham_item_prev(dbc, lock_type, pgnop);
			break;
		}
		/* FALLTHROUGH */
	case DB_LAST:
		ret = __ham_item_last(dbc, lock_type, pgnop);
		break;
	case DB_NEXT_NODUP:
		F_SET(hcp, H_NEXT_NODUP);
		/* FALLTHROUGH */
	case DB_NEXT:
		if (IS_INITIALIZED(dbc)) {
			ret = __ham_item_next(dbc, lock_type, pgnop);
			break;
		}
		/* FALLTHROUGH */
	case DB_FIRST:
		ret = __ham_item_first(dbc, lock_type, pgnop);
		break;
	case DB_NEXT_DUP:
		/* cgetchk has already determined that the cursor is set. */
		F_SET(hcp, H_DUPONLY);
		ret = __ham_item_next(dbc, lock_type, pgnop);
		break;
	case DB_SET:
	case DB_SET_RANGE:
	case DB_GET_BOTH:
		ret = __ham_lookup(dbc, key, 0, lock_type, pgnop);
		get_key = 0;
		break;
	case DB_GET_BOTHC:
		F_SET(hcp, H_DUPONLY);

		ret = __ham_item_next(dbc, lock_type, pgnop);
		get_key = 0;
		break;
	case DB_CURRENT:
		/* cgetchk has already determined that the cursor is set. */
		if (F_ISSET(hcp, H_DELETED)) {
			ret = DB_KEYEMPTY;
			goto err;
		}

		ret = __ham_item(dbc, lock_type, pgnop);
		break;
	}

	/*
	 * Must always enter this loop to do error handling and
	 * check for big key/data pair.
	 */
	for (;;) {
		if (ret != 0 && ret != DB_NOTFOUND)
			goto err;
		else if (F_ISSET(hcp, H_OK)) {
			if (*pgnop == PGNO_INVALID)
				ret = __ham_dup_return (dbc, data, flags);
			break;
		} else if (!F_ISSET(hcp, H_NOMORE)) {
			__db_err(dbp->dbenv,
			     "H_NOMORE returned to __ham_c_get");
			ret = EINVAL;
			break;
		}

		/*
		 * Ran out of entries in a bucket; change buckets.
		 */
		switch (flags) {
			case DB_LAST:
			case DB_PREV:
			case DB_PREV_NODUP:
				ret = memp_fput(dbp->mpf, hcp->page, 0);
				hcp->page = NULL;
				if (hcp->bucket == 0) {
					ret = DB_NOTFOUND;
					hcp->pgno = PGNO_INVALID;
					goto err;
				}
				F_CLR(hcp, H_ISDUP);
				hcp->bucket--;
				hcp->indx = NDX_INVALID;
				hcp->pgno = BUCKET_TO_PAGE(hcp, hcp->bucket);
				if (ret == 0)
					ret = __ham_item_prev(dbc,
					    lock_type, pgnop);
				break;
			case DB_FIRST:
			case DB_NEXT:
			case DB_NEXT_NODUP:
				ret = memp_fput(dbp->mpf, hcp->page, 0);
				hcp->page = NULL;
				hcp->indx = NDX_INVALID;
				hcp->bucket++;
				F_CLR(hcp, H_ISDUP);
				hcp->pgno = BUCKET_TO_PAGE(hcp, hcp->bucket);
				if (hcp->bucket > hcp->hdr->max_bucket) {
					ret = DB_NOTFOUND;
					hcp->pgno = PGNO_INVALID;
					goto err;
				}
				if (ret == 0)
					ret = __ham_item_next(dbc,
					    lock_type, pgnop);
				break;
			case DB_GET_BOTH:
			case DB_GET_BOTHC:
			case DB_NEXT_DUP:
			case DB_SET:
			case DB_SET_RANGE:
				/* Key not found. */
				ret = DB_NOTFOUND;
				goto err;
			case DB_CURRENT:
				/*
				 * This should only happen if you are doing
				 * deletes and reading with concurrent threads
				 * and not doing proper locking.  We return
				 * the same error code as we would if the
				 * cursor were deleted.
				 */
				ret = DB_KEYEMPTY;
				goto err;
			default:
				DB_ASSERT(0);
		}
	}

	if (get_key == 0)
		F_SET(key, DB_DBT_ISSET);

err:	if ((t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;

	F_CLR(hcp, H_DUPONLY);
	F_CLR(hcp, H_NEXT_NODUP);

	return (ret);
}

/*
 * __ham_bulk -- Return bulk data from a btree.
 */
static int
__ham_bulk(dbc, data, flags)
	DBC *dbc;
	DBT *data;
	u_int32_t flags;
{
	HASH_CURSOR *cp;
	PAGE *pg;
	db_indx_t dup_len, dup_off, dup_tlen, indx;
	db_pgno_t pgno;
	int32_t  *endp, key_off, *offp, *saveoff;
	u_int32_t key_size, size, space;
	u_int8_t *dbuf, *dp, *hk, *np;
	int is_dup, is_key, lock_mode;
	int need_pg, next_key, no_dup, pagesize, ret;

	ret = 0;
	key_off = 0;
	dup_len = dup_off = dup_tlen = 0;
	size = 0;
	pagesize = dbc->dbp->pgsize;
	cp = (HASH_CURSOR *)dbc->internal;
	is_key = LF_ISSET(DB_MULTIPLE_KEY) ? 1 : 0;
	next_key = is_key && LF_ISSET(DB_OPFLAGS_MASK) != DB_NEXT_DUP;
	no_dup = LF_ISSET(DB_OPFLAGS_MASK) == DB_NEXT_NODUP;
	dbuf = data->data;
	np = dp = dbuf;

	/* Keep track of space that is left.  There is an termination entry */
	space = data->ulen;
	space -= sizeof(*offp);

	/* Build the offset/size table form the end up. */
	endp = (int32_t *) ((u_int8_t *)dbuf + data->ulen);
	endp--;
	offp = endp;

	key_size = 0;
	lock_mode = F_ISSET(dbc, DBC_RMW) ? DB_LOCK_WRITE: DB_LOCK_READ;

next_pg:
	need_pg = 1;
	indx = cp->indx;
	pg = cp->page;

	do {
		if (is_key) {
			hk = H_PAIRKEY(pg, indx);
			if (HPAGE_PTYPE(hk) == H_OFFPAGE) {
				memcpy(&key_size,
				    HOFFPAGE_TLEN(hk), sizeof(u_int32_t));
				memcpy(&pgno,
				    HOFFPAGE_PGNO(hk), sizeof(db_pgno_t));
				size = key_size;
				if (key_size > space)
					goto get_key_space;
				if ((ret = __bam_bulk_overflow(dbc,
				     key_size, pgno, np)) != 0)
					return (ret);
				space -= key_size;
				key_off = np - dbuf;
				np += key_size;
			} else {
				if (need_pg) {
					dp = np;
					size = pagesize - HOFFSET(pg);
					if (space < size) {
get_key_space:
						if (offp == endp) {
							data->size =
							    ALIGN(size +
							    pagesize,
							    sizeof(u_int32_t));
							return (ENOMEM);
						}
						goto back_up;
					}
					memcpy(dp,
					   (u_int8_t *)pg + HOFFSET(pg), size);
					need_pg = 0;
					space -= size;
					np += size;
				}
				key_size = LEN_HKEY(pg, pagesize, indx);
				key_off = pg->inp[indx] - HOFFSET(pg)
				     + dp - dbuf + SSZA(HKEYDATA, data);
			}
		}

		hk = H_PAIRDATA(pg, indx);
		switch (HPAGE_PTYPE(hk)) {
		case H_DUPLICATE:
		case H_KEYDATA:
			if (need_pg) {
				dp = np;
				size = pagesize - HOFFSET(pg);
				if (space < size) {
back_up:
					if (indx == 0) {
						if ((ret = __ham_item_prev(dbc,
						    lock_mode, &pgno)) != 0)
							return (ret);
						indx = cp->indx;
					} else
						indx -= 2;
get_space:
					/*
					 * See if we put any data in the buffer.
					 */
					if (offp >= endp
					    || F_ISSET(dbc, DBC_TRANSIENT)) {
						data->size = ALIGN(size +
						    data->ulen - space,
						    sizeof(u_int32_t));
						return (ENOMEM);
					}
					/*
					 * Don't continue;  we're all out
					 * of space, even though we're
					 * returning success.
					 */
					next_key = 0;
					break;
				}
				memcpy(dp, (u_int8_t *)pg + HOFFSET(pg), size);
				need_pg = 0;
				space -= size;
				np += size;
			}

			/*
			 * We're about to crack the offset(s) and length(s)
			 * out of an H_KEYDATA or H_DUPLICATE item.
			 * There are three cases:
			 *   1. We were moved into a duplicate set by
			 *      the standard hash cursor code.  Respect
			 *      the dup_off and dup_tlen we were given.
			 *   2. We stumbled upon a duplicate set while
			 *      walking the page on our own.  We need to
			 *      recognize it as a dup and set dup_off and
			 *      dup_tlen.
			 *   3. The current item is not a dup.
			 */
			if (F_ISSET(cp, H_ISDUP)) {
				/* Case 1 */
				is_dup = 1;
				dup_len = cp->dup_len;
				dup_off = cp->dup_off;
				dup_tlen = cp->dup_tlen;
			} else if (HPAGE_PTYPE(hk) == H_DUPLICATE) {
				/* Case 2 */
				is_dup = 1;
				/*
				 * If we run out of memory and bail,
				 * make sure the fact we're in a dup set
				 * isn't ignored later.
				 */
				F_SET(cp, H_ISDUP);
				dup_off = 0;
				dup_len = cp->dup_len;
				dup_tlen = LEN_HDATA(pg, pagesize, indx);
			} else
				/* Case 3 */
				is_dup = dup_len = dup_off = dup_tlen = 0;

			do {
				space -= (is_key ? 4 : 2) * sizeof(*offp);
				size += (is_key ? 4 : 2) * sizeof(*offp);
				if (space > data->ulen) {
					if (!is_dup || dup_off == 0)
						goto back_up;
					dup_off -= DUP_SIZE(offp[1]);
					goto get_space;
				}
				if (is_key) {
					*offp-- = key_off;
					*offp-- = key_size;
				}
				if (is_dup) {
					*offp-- =
					    pg->inp[indx + 1] - HOFFSET(pg) +
					    dp - dbuf + SSZA(HKEYDATA, data) +
					    dup_off + sizeof(db_indx_t);
					memcpy(&dup_len,
					    HKEYDATA_DATA(hk) + dup_off,
					    sizeof(db_indx_t));
					dup_off += DUP_SIZE(dup_len);
					*offp-- = dup_len;
				} else {
					*offp-- =
					    pg->inp[indx + 1] - HOFFSET(pg) +
					    dp - dbuf + SSZA(HKEYDATA, data);
					*offp-- = LEN_HDATA(pg, pagesize, indx);
				}
			} while (is_dup && dup_off < dup_tlen && no_dup == 0);
			F_CLR(cp, H_ISDUP);
			break;
		case H_OFFDUP:
			memcpy(&pgno, HOFFPAGE_PGNO(hk), sizeof(db_pgno_t));
			space -= 2 * sizeof(*offp);
			if (space > data->ulen)
				goto back_up;

			if (is_key) {
				space -= 2 * sizeof(*offp);
				if (space > data->ulen)
					goto back_up;
				*offp-- = key_off;
				*offp-- = key_size;
			}
			saveoff = offp;
			if ((ret = __bam_bulk_duplicates(dbc,
			      pgno, dbuf, is_key ? offp + 2 : NULL,
			      &offp, &np, &space, no_dup)) != 0) {
				if (ret == ENOMEM) {
					size = space;
					if (is_key && saveoff == offp) {
						offp += 2;
						goto back_up;
					}
					goto get_space;
				}
				return (ret);
			}
			break;
		case H_OFFPAGE:
			space -= (is_key ? 4 : 2) * sizeof(*offp);
			if (space > data->ulen)
				goto back_up;

			memcpy(&size, HOFFPAGE_TLEN(hk), sizeof(u_int32_t));
			memcpy(&pgno, HOFFPAGE_PGNO(hk), sizeof(db_pgno_t));
			if (size > space)
				goto back_up;

			if ((ret =
			    __bam_bulk_overflow(dbc, size, pgno, np)) != 0)
				return (ret);

			if (is_key) {
				*offp-- = key_off;
				*offp-- = key_size;
			}

			*offp-- = np - dbuf;
			*offp-- = size;

			np += size;
			space -= size;
			break;
		}
	} while (next_key && (indx += 2) < NUM_ENT(pg));

	cp->indx = indx;
	cp->dup_len = dup_len;
	cp->dup_off = dup_off;
	cp->dup_tlen = dup_tlen;

	/* If we are off the page then try to the next page. */
	if (ret == 0 && next_key && indx >= NUM_ENT(pg)) {
		ret = __ham_item_next(dbc, lock_mode, &pgno);
		if (ret == 0)
			goto next_pg;
		if (ret != DB_NOTFOUND)
			return (ret);
	}
	*offp = (u_int32_t) -1;
	return (0);
}

static int
__ham_c_put(dbc, key, data, flags, pgnop)
	DBC *dbc;
	DBT *key;
	DBT *data;
	u_int32_t flags;
	db_pgno_t *pgnop;
{
	DB *dbp;
	DBT tmp_val, *myval;
	HASH_CURSOR *hcp;
	u_int32_t nbytes;
	int ret, t_ret;

	/*
	 * The compiler doesn't realize that we only use this when ret is
	 * equal to 0 and that if ret is equal to 0, that we must have set
	 * myval.  So, we initialize it here to shut the compiler up.
	 */
	COMPQUIET(myval, NULL);

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;

	if (F_ISSET(hcp, H_DELETED) &&
	    flags != DB_KEYFIRST && flags != DB_KEYLAST)
		return (DB_NOTFOUND);

	if ((ret = __ham_get_meta(dbc)) != 0)
		goto err1;

	switch (flags) {
	case DB_KEYLAST:
	case DB_KEYFIRST:
	case DB_NODUPDATA:
		nbytes = (ISBIG(hcp, key->size) ? HOFFPAGE_PSIZE :
		    HKEYDATA_PSIZE(key->size)) +
		    (ISBIG(hcp, data->size) ? HOFFPAGE_PSIZE :
		    HKEYDATA_PSIZE(data->size));
		if ((ret = __ham_lookup(dbc,
		    key, nbytes, DB_LOCK_WRITE, pgnop)) == DB_NOTFOUND) {
			ret = 0;
			if (hcp->seek_found_page != PGNO_INVALID &&
			    hcp->seek_found_page != hcp->pgno) {
				if ((ret = memp_fput(dbp->mpf, hcp->page, 0))
				    != 0)
					goto err2;
				hcp->page = NULL;
				hcp->pgno = hcp->seek_found_page;
				hcp->indx = NDX_INVALID;
			}

			if (F_ISSET(data, DB_DBT_PARTIAL) && data->doff != 0) {
				/*
				 * A partial put, but the key does not exist
				 * and we are not beginning the write at 0.
				 * We must create a data item padded up to doff
				 * and then write the new bytes represented by
				 * val.
				 */
				if ((ret = __ham_init_dbt(dbp->dbenv, &tmp_val,
				    data->size + data->doff,
				    &dbc->my_rdata.data,
				    &dbc->my_rdata.ulen)) == 0) {
					memset(tmp_val.data, 0, data->doff);
					memcpy((u_int8_t *)tmp_val.data +
					    data->doff, data->data, data->size);
					myval = &tmp_val;
				}
			} else
				myval = (DBT *)data;

			if (ret == 0)
				ret = __ham_add_el(dbc, key, myval, H_KEYDATA);
			goto done;
		}
		break;
	case DB_BEFORE:
	case DB_AFTER:
	case DB_CURRENT:
		ret = __ham_item(dbc, DB_LOCK_WRITE, pgnop);
		break;
	}

	if (*pgnop == PGNO_INVALID && ret == 0) {
		if (flags == DB_CURRENT ||
		    ((flags == DB_KEYFIRST ||
		    flags == DB_KEYLAST || flags == DB_NODUPDATA) &&
		    !(F_ISSET(dbp, DB_AM_DUP) || F_ISSET(key, DB_DBT_DUPOK))))
			ret = __ham_overwrite(dbc, data, flags);
		else
			ret = __ham_add_dup(dbc, data, flags, pgnop);
	}

done:	if (ret == 0 && F_ISSET(hcp, H_EXPAND)) {
		ret = __ham_expand_table(dbc);
		F_CLR(hcp, H_EXPAND);
	}

	if (ret == 0 &&
	    (t_ret = memp_fset(dbp->mpf, hcp->page, DB_MPOOL_DIRTY)) != 0)
		ret = t_ret;

err2:	if ((t_ret = __ham_release_meta(dbc)) != 0 && ret == 0)
		ret = t_ret;

err1:	return (ret);
}

/********************************* UTILITIES ************************/

/*
 * __ham_expand_table --
 */
static int
__ham_expand_table(dbc)
	DBC *dbc;
{
	DB *dbp;
	DB_LOCK metalock;
	DB_LSN lsn;
	DBMETA *mmeta;
	PAGE *h;
	HASH_CURSOR *hcp;
	db_pgno_t mpgno, pgno;
	u_int32_t old_bucket, new_bucket;
	int create_group, ret;

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;
	if ((ret = __ham_dirty_meta(dbc)) != 0)
		return (ret);

	create_group = 0;
	LOCK_INIT(metalock);
	mmeta = NULL;
	h = NULL;

	/*
	 * If the split point is about to increase, make sure that we
	 * have enough extra pages.  The calculation here is weird.
	 * We'd like to do this after we've upped max_bucket, but it's
	 * too late then because we've logged the meta-data split.  What
	 * we'll do between then and now is increment max bucket and then
	 * see what the log of one greater than that is; here we have to
	 * look at the log of max + 2.  VERY NASTY STUFF.
	 *
	 * It just got even nastier.  With subdatabases, we have to request
	 * a chunk of contiguous pages, so we do that here using an
	 * undocumented feature of mpool (the MPOOL_NEW_GROUP flag) to
	 * give us a number of contiguous pages.  Ouch.
	 *
	 * We figure out what we need to do, then we log it, then request
	 * the pages from mpool.  We don't want to fail after extending
	 * the file.
	 */
	if (hcp->hdr->max_bucket == hcp->hdr->high_mask) {
		/*
		 * We need to begin a new doubling.  Figure out how many pages
		 * we need.  If we've already allocated this doubling, then
		 * grab the page number; if we haven't, then get the last
		 * allocation page number off the master meta-data page and
		 * allocate a contiguous chunk of pages for the doubling.
		 * Initialize and write out the last page of the doubling to
		 * do the file extend.
		 */
		pgno = hcp->hdr->max_bucket + 1;
		if (hcp->hdr->spares[__db_log2(pgno) + 1] == PGNO_INVALID) {
			/* Allocate a group of pages. */
			mmeta = (DBMETA *) hcp->hdr;
			if (F_ISSET(dbp, DB_AM_SUBDB)) {
				mpgno = PGNO_BASE_MD;
				if ((ret = __db_lget(dbc,
				   0, mpgno, DB_LOCK_WRITE, 0, &metalock)) != 0)
					return (ret);
				if ((ret = memp_fget(dbp->mpf,
				    &mpgno, 0, (PAGE **)&mmeta)) != 0)
					goto err;
			}
			pgno = mmeta->last_pgno + 1;
			ZERO_LSN(lsn);
			create_group = 1;
		} else {
			/* Just read in the last page of the batch */
			pgno = hcp->hdr->spares[__db_log2(pgno) + 1] +
			    hcp->hdr->max_bucket + 1;
			/* Move to the last page of the group. */
			pgno += hcp->hdr->max_bucket;
			if ((ret = memp_fget(dbp->mpf,
			     &pgno, DB_MPOOL_CREATE, &h)) != 0)
				return (ret);
			pgno -= hcp->hdr->max_bucket;
			lsn = h->lsn;
		}
	} else {
		pgno = BUCKET_TO_PAGE(hcp, hcp->hdr->max_bucket + 1);
		if ((ret =
		    memp_fget(dbp->mpf, &pgno, DB_MPOOL_CREATE, &h)) != 0)
			return (ret);
		lsn = h->lsn;
	}
	/* Now we can log the meta-data split. */
	if (DB_LOGGING(dbc)) {
		if ((ret = __ham_metagroup_log(dbp->dbenv,
		    dbc->txn, &lsn, 0, dbp->log_fileid,
		    hcp->hdr->max_bucket, pgno, &hcp->hdr->dbmeta.lsn,
		    &lsn)) != 0)
			return (ret);
	} else
		LSN_NOT_LOGGED(lsn);

	hcp->hdr->dbmeta.lsn = lsn;

	if (create_group) {
		pgno = hcp->hdr->max_bucket + 1;
		if ((ret = memp_fget(dbp->mpf,
		     &pgno, DB_MPOOL_NEW_GROUP, &h)) != 0)
			goto err;

		mmeta->last_pgno = pgno;
		P_INIT(h, dbp->pgsize,
		     pgno, PGNO_INVALID, PGNO_INVALID, 0, P_HASH);
		pgno -= hcp->hdr->max_bucket;

		if (F_ISSET(dbp, DB_AM_SUBDB)) {
			if ((ret = memp_fput(dbp->mpf,
			    mmeta, DB_MPOOL_DIRTY)) != 0)
				goto err;
			mmeta = NULL;
			if ((ret = __LPUT(dbc, metalock)) != 0)
				goto err;
			LOCK_INIT(metalock);
		}
	}

	h->lsn = lsn;

	/* If we allocated some new pages, write out the last page. */
	if ((ret = memp_fput(dbp->mpf, h, DB_MPOOL_DIRTY)) != 0)
		goto err;
	h = NULL;

	new_bucket = ++hcp->hdr->max_bucket;
	old_bucket = (hcp->hdr->max_bucket & hcp->hdr->low_mask);

	/*
	 * If we started a new doubling, fill in the spares array with
	 * the starting page number negatively offset by the bucket number.
	 */
	if (new_bucket > hcp->hdr->high_mask) {
		/* Starting a new doubling */
		hcp->hdr->low_mask = hcp->hdr->high_mask;
		hcp->hdr->high_mask = new_bucket | hcp->hdr->low_mask;
		if (hcp->hdr->spares[__db_log2(new_bucket) + 1] == PGNO_INVALID)
			hcp->hdr->spares[__db_log2(new_bucket) + 1] =
			    pgno - new_bucket;
	}

	/* Relocate records to the new bucket */
	return (__ham_split_page(dbc, old_bucket, new_bucket));

err:	if (mmeta != NULL)
		(void)memp_fput(dbp->mpf, mmeta, 0);

	if (LOCK_ISSET(metalock) && F_ISSET(dbp, DB_AM_SUBDB))
		(void)__LPUT(dbc, metalock);

	if (h != NULL)
		(void)memp_fput(dbp->mpf, h, 0);

	return (ret);
}

/*
 * PUBLIC: u_int32_t __ham_call_hash __P((DBC *, u_int8_t *, int32_t));
 */
u_int32_t
__ham_call_hash(dbc, k, len)
	DBC *dbc;
	u_int8_t *k;
	int32_t len;
{
	DB *dbp;
	u_int32_t n, bucket;
	HASH_CURSOR *hcp;
	HASH *hashp;

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;
	hashp = dbp->h_internal;

	n = (u_int32_t)(hashp->h_hash(dbp, k, len));

	bucket = n & hcp->hdr->high_mask;
	if (bucket > hcp->hdr->max_bucket)
		bucket = bucket & hcp->hdr->low_mask;
	return (bucket);
}

/*
 * Check for duplicates, and call __db_ret appropriately.  Release
 * everything held by the cursor.
 */
static int
__ham_dup_return (dbc, val, flags)
	DBC *dbc;
	DBT *val;
	u_int32_t flags;
{
	DB *dbp;
	HASH_CURSOR *hcp;
	PAGE *pp;
	DBT *myval, tmp_val;
	db_indx_t ndx;
	db_pgno_t pgno;
	u_int32_t off, tlen;
	u_int8_t *hk, type;
	int cmp, ret;
	db_indx_t len;

	/* Check for duplicate and return the first one. */
	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;
	ndx = H_DATAINDEX(hcp->indx);
	type = HPAGE_TYPE(hcp->page, ndx);
	pp = hcp->page;
	myval = val;

	/*
	 * There are 4 cases:
	 * 1. We are not in duplicate, simply return; the upper layer
	 *    will do the right thing.
	 * 2. We are looking at keys and stumbled onto a duplicate.
	 * 3. We are in the middle of a duplicate set. (ISDUP set)
	 * 4. We need to check for particular data match.
	 */

	/* We should never get here with off-page dups. */
	DB_ASSERT(type != H_OFFDUP);

	/* Case 1 */
	if (type != H_DUPLICATE &&
	    flags != DB_GET_BOTH && flags != DB_GET_BOTHC)
		return (0);

	/*
	 * Here we check for the case where we just stumbled onto a
	 * duplicate.  In this case, we do initialization and then
	 * let the normal duplicate code handle it. (Case 2)
	 */
	if (!F_ISSET(hcp, H_ISDUP) && type == H_DUPLICATE) {
		F_SET(hcp, H_ISDUP);
		hcp->dup_tlen = LEN_HDATA(hcp->page,
		    hcp->hdr->dbmeta.pagesize, hcp->indx);
		hk = H_PAIRDATA(hcp->page, hcp->indx);
		if (flags == DB_LAST
		    || flags == DB_PREV || flags == DB_PREV_NODUP) {
			hcp->dup_off = 0;
			do {
				memcpy(&len,
				    HKEYDATA_DATA(hk) + hcp->dup_off,
				    sizeof(db_indx_t));
				hcp->dup_off += DUP_SIZE(len);
			} while (hcp->dup_off < hcp->dup_tlen);
			hcp->dup_off -= DUP_SIZE(len);
		} else {
			memcpy(&len,
			    HKEYDATA_DATA(hk), sizeof(db_indx_t));
			hcp->dup_off = 0;
		}
		hcp->dup_len = len;
	}

	/*
	 * If we are retrieving a specific key/data pair, then we
	 * may need to adjust the cursor before returning data.
	 * Case 4
	 */
	if (flags == DB_GET_BOTH || flags == DB_GET_BOTHC) {
		if (F_ISSET(hcp, H_ISDUP)) {
			/*
			 * If we're doing a join, search forward from the
			 * current position, not the beginning of the dup set.
			 */
			if (flags == DB_GET_BOTHC)
				F_SET(hcp, H_CONTINUE);

			__ham_dsearch(dbc, val, &off, &cmp);

			/*
			 * This flag is set nowhere else and is safe to
			 * clear unconditionally.
			 */
			F_CLR(hcp, H_CONTINUE);
			hcp->dup_off = off;
		} else {
			hk = H_PAIRDATA(hcp->page, hcp->indx);
			if (((HKEYDATA *)hk)->type == H_OFFPAGE) {
				memcpy(&tlen,
				    HOFFPAGE_TLEN(hk), sizeof(u_int32_t));
				memcpy(&pgno,
				    HOFFPAGE_PGNO(hk), sizeof(db_pgno_t));
				if ((ret = __db_moff(dbp, val,
				    pgno, tlen, dbp->dup_compare, &cmp)) != 0)
					return (ret);
			} else {
				/*
				 * We do not zero tmp_val since the comparison
				 * routines may only look at data and size.
				 */
				tmp_val.data = HKEYDATA_DATA(hk);
				tmp_val.size = LEN_HDATA(hcp->page,
				    dbp->pgsize, hcp->indx);
				cmp = dbp->dup_compare == NULL ?
				    __bam_defcmp(dbp, &tmp_val, val) :
				    dbp->dup_compare(dbp, &tmp_val, val);
			}
		}

		if (cmp != 0)
			return (DB_NOTFOUND);
	}

	/*
	 * If we're doing a bulk get, we don't want to actually return
	 * the data:  __ham_bulk will take care of cracking out the
	 * duplicates appropriately.
	 *
	 * The rest of this function calculates partial offsets and
	 * handles the actual __db_ret, so just return if
	 * DB_MULTIPLE(_KEY) is set.
	 */
	if (F_ISSET(dbc, DBC_MULTIPLE | DBC_MULTIPLE_KEY))
		return (0);

	/*
	 * Now, everything is initialized, grab a duplicate if
	 * necessary.
	 */
	if (F_ISSET(hcp, H_ISDUP)) {	/* Case 3 */
		/*
		 * Copy the DBT in case we are retrieving into user
		 * memory and we need the parameters for it.  If the
		 * user requested a partial, then we need to adjust
		 * the user's parameters to get the partial of the
		 * duplicate which is itself a partial.
		 */
		memcpy(&tmp_val, val, sizeof(*val));
		if (F_ISSET(&tmp_val, DB_DBT_PARTIAL)) {
			/*
			 * Take the user's length unless it would go
			 * beyond the end of the duplicate.
			 */
			if (tmp_val.doff + hcp->dup_off > hcp->dup_len)
				tmp_val.dlen = 0;
			else if (tmp_val.dlen + tmp_val.doff >
			    hcp->dup_len)
				tmp_val.dlen =
				    hcp->dup_len - tmp_val.doff;

			/*
			 * Calculate the new offset.
			 */
			tmp_val.doff += hcp->dup_off;
		} else {
			F_SET(&tmp_val, DB_DBT_PARTIAL);
			tmp_val.dlen = hcp->dup_len;
			tmp_val.doff = hcp->dup_off + sizeof(db_indx_t);
		}
		myval = &tmp_val;
	}

	/*
	 * Finally, if we had a duplicate, pp, ndx, and myval should be
	 * set appropriately.
	 */
	if ((ret = __db_ret(dbp, pp, ndx, myval, &dbc->rdata->data,
	    &dbc->rdata->ulen)) != 0)
		return (ret);

	/*
	 * In case we sent a temporary off to db_ret, set the real
	 * return values.
	 */
	val->data = myval->data;
	val->size = myval->size;

	F_SET(val, DB_DBT_ISSET);

	return (0);
}

static int
__ham_overwrite(dbc, nval, flags)
	DBC *dbc;
	DBT *nval;
	u_int32_t flags;
{
	DB *dbp;
	DB_ENV *dbenv;
	HASH_CURSOR *hcp;
	DBT *myval, tmp_val, tmp_val2;
	void *newrec;
	u_int8_t *hk, *p;
	u_int32_t len, nondup_size;
	db_indx_t newsize;
	int ret;

	dbp = dbc->dbp;
	dbenv = dbp->dbenv;
	hcp = (HASH_CURSOR *)dbc->internal;
	if (F_ISSET(hcp, H_ISDUP)) {
		/*
		 * This is an overwrite of a duplicate. We should never
		 * be off-page at this point.
		 */
		DB_ASSERT(hcp->opd == NULL);
		/* On page dups */
		if (F_ISSET(nval, DB_DBT_PARTIAL)) {
			/*
			 * We're going to have to get the current item, then
			 * construct the record, do any padding and do a
			 * replace.
			 */
			memset(&tmp_val, 0, sizeof(tmp_val));
			if ((ret =
			    __ham_dup_return (dbc, &tmp_val, DB_CURRENT)) != 0)
				return (ret);

			/* Figure out new size. */
			nondup_size = tmp_val.size;
			newsize = nondup_size;

			/*
			 * Three cases:
			 * 1. strictly append (may need to allocate space
			 *	for pad bytes; really gross).
			 * 2. overwrite some and append.
			 * 3. strictly overwrite.
			 */
			if (nval->doff > nondup_size)
				newsize +=
				    (nval->doff - nondup_size + nval->size);
			else if (nval->doff + nval->dlen > nondup_size)
				newsize += nval->size -
				    (nondup_size - nval->doff);
			else
				newsize += nval->size - nval->dlen;

			/*
			 * Make sure that the new size doesn't put us over
			 * the onpage duplicate size in which case we need
			 * to convert to off-page duplicates.
			 */
			if (ISBIG(hcp, hcp->dup_tlen - nondup_size + newsize)) {
				if ((ret = __ham_dup_convert(dbc)) != 0)
					return (ret);
				return (hcp->opd->c_am_put(hcp->opd,
				    NULL, nval, flags, NULL));
			}

			if ((ret = __os_malloc(dbp->dbenv,
			    DUP_SIZE(newsize), &newrec)) != 0)
				return (ret);
			memset(&tmp_val2, 0, sizeof(tmp_val2));
			F_SET(&tmp_val2, DB_DBT_PARTIAL);

			/* Construct the record. */
			p = newrec;
			/* Initial size. */
			memcpy(p, &newsize, sizeof(db_indx_t));
			p += sizeof(db_indx_t);

			/* First part of original record. */
			len = nval->doff > tmp_val.size
			    ? tmp_val.size : nval->doff;
			memcpy(p, tmp_val.data, len);
			p += len;

			if (nval->doff > tmp_val.size) {
				/* Padding */
				memset(p, 0, nval->doff - tmp_val.size);
				p += nval->doff - tmp_val.size;
			}

			/* New bytes */
			memcpy(p, nval->data, nval->size);
			p += nval->size;

			/* End of original record (if there is any) */
			if (nval->doff + nval->dlen < tmp_val.size) {
				len = tmp_val.size - nval->doff - nval->dlen;
				memcpy(p, (u_int8_t *)tmp_val.data +
				    nval->doff + nval->dlen, len);
				p += len;
			}

			/* Final size. */
			memcpy(p, &newsize, sizeof(db_indx_t));

			/*
			 * Make sure that the caller isn't corrupting
			 * the sort order.
			 */
			if (dbp->dup_compare != NULL) {
				tmp_val2.data =
				    (u_int8_t *)newrec + sizeof(db_indx_t);
				tmp_val2.size = newsize;
				if (dbp->dup_compare(
				    dbp, &tmp_val, &tmp_val2) != 0) {
					(void)__os_free(dbenv, newrec,
					    DUP_SIZE(newsize));
					return (__db_duperr(dbp, flags));
				}
			}

			tmp_val2.data = newrec;
			tmp_val2.size = DUP_SIZE(newsize);
			tmp_val2.doff = hcp->dup_off;
			tmp_val2.dlen = DUP_SIZE(hcp->dup_len);

			ret = __ham_replpair(dbc, &tmp_val2, 0);
			(void)__os_free(dbenv, newrec, DUP_SIZE(newsize));

			/* Update cursor */
			if (ret != 0)
				return (ret);

			if (newsize > nondup_size)
				hcp->dup_tlen += (newsize - nondup_size);
			else
				hcp->dup_tlen -= (nondup_size - newsize);
			hcp->dup_len = DUP_SIZE(newsize);
			return (0);
		} else {
			/* Check whether we need to convert to off page. */
			if (ISBIG(hcp,
			    hcp->dup_tlen - hcp->dup_len + nval->size)) {
				if ((ret = __ham_dup_convert(dbc)) != 0)
					return (ret);
				return (hcp->opd->c_am_put(hcp->opd,
				    NULL, nval, flags, NULL));
			}

			/* Make sure we maintain sort order. */
			if (dbp->dup_compare != NULL) {
				tmp_val2.data =
				    HKEYDATA_DATA(H_PAIRDATA(hcp->page,
				    hcp->indx)) + hcp->dup_off +
				    sizeof(db_indx_t);
				tmp_val2.size = hcp->dup_len;
				if (dbp->dup_compare(dbp, nval, &tmp_val2) != 0)
					return (EINVAL);
			}
			/* Overwriting a complete duplicate. */
			if ((ret =
			    __ham_make_dup(dbp->dbenv, nval, &tmp_val,
			    &dbc->my_rdata.data, &dbc->my_rdata.ulen)) != 0)
				return (ret);
			/* Now fix what we are replacing. */
			tmp_val.doff = hcp->dup_off;
			tmp_val.dlen = DUP_SIZE(hcp->dup_len);

			/* Update cursor */
			if (nval->size > hcp->dup_len)
				hcp->dup_tlen += (nval->size - hcp->dup_len);
			else
				hcp->dup_tlen -= (hcp->dup_len - nval->size);
			hcp->dup_len = DUP_SIZE(nval->size);
		}
		myval = &tmp_val;
	} else if (!F_ISSET(nval, DB_DBT_PARTIAL)) {
		/* Put/overwrite */
		memcpy(&tmp_val, nval, sizeof(*nval));
		F_SET(&tmp_val, DB_DBT_PARTIAL);
		tmp_val.doff = 0;
		hk = H_PAIRDATA(hcp->page, hcp->indx);
		if (HPAGE_PTYPE(hk) == H_OFFPAGE)
			memcpy(&tmp_val.dlen,
			    HOFFPAGE_TLEN(hk), sizeof(u_int32_t));
		else
			tmp_val.dlen = LEN_HDATA(hcp->page,
			    hcp->hdr->dbmeta.pagesize, hcp->indx);
		myval = &tmp_val;
	} else
		/* Regular partial put */
		myval = nval;

	return (__ham_replpair(dbc, myval, 0));
}

/*
 * Given a key and a cursor, sets the cursor to the page/ndx on which
 * the key resides.  If the key is found, the cursor H_OK flag is set
 * and the pagep, bndx, pgno (dpagep, dndx, dpgno) fields are set.
 * If the key is not found, the H_OK flag is not set.  If the sought
 * field is non-0, the pagep, bndx, pgno (dpagep, dndx, dpgno) fields
 * are set indicating where an add might take place.  If it is 0,
 * non of the cursor pointer field are valid.
 */
static int
__ham_lookup(dbc, key, sought, mode, pgnop)
	DBC *dbc;
	const DBT *key;
	u_int32_t sought;
	db_lockmode_t mode;
	db_pgno_t *pgnop;
{
	DB *dbp;
	HASH_CURSOR *hcp;
	db_pgno_t pgno;
	u_int32_t tlen;
	int match, ret;
	u_int8_t *hk, *dk;

	dbp = dbc->dbp;
	hcp = (HASH_CURSOR *)dbc->internal;
	/*
	 * Set up cursor so that we're looking for space to add an item
	 * as we cycle through the pages looking for the key.
	 */
	if ((ret = __ham_item_reset(dbc)) != 0)
		return (ret);
	hcp->seek_size = sought;

	hcp->bucket = __ham_call_hash(dbc, (u_int8_t *)key->data, key->size);
	hcp->pgno = BUCKET_TO_PAGE(hcp, hcp->bucket);

	while (1) {
		*pgnop = PGNO_INVALID;
		if ((ret = __ham_item_next(dbc, mode, pgnop)) != 0)
			return (ret);

		if (F_ISSET(hcp, H_NOMORE))
			break;

		hk = H_PAIRKEY(hcp->page, hcp->indx);
		switch (HPAGE_PTYPE(hk)) {
		case H_OFFPAGE:
			memcpy(&tlen, HOFFPAGE_TLEN(hk), sizeof(u_int32_t));
			if (tlen == key->size) {
				memcpy(&pgno,
				    HOFFPAGE_PGNO(hk), sizeof(db_pgno_t));
				if ((ret = __db_moff(dbp,
				    key, pgno, tlen, NULL, &match)) != 0)
					return (ret);
				if (match == 0)
					goto found_key;
			}
			break;
		case H_KEYDATA:
			if (key->size ==
			    LEN_HKEY(hcp->page, dbp->pgsize, hcp->indx) &&
			    memcmp(key->data,
			    HKEYDATA_DATA(hk), key->size) == 0) {
				/* Found the key, check for data type. */
found_key:			F_SET(hcp, H_OK);
				dk = H_PAIRDATA(hcp->page, hcp->indx);
				if (HPAGE_PTYPE(dk) == H_OFFDUP)
					memcpy(pgnop, HOFFDUP_PGNO(dk),
					    sizeof(db_pgno_t));
				return (0);
			}
			break;
		case H_DUPLICATE:
		case H_OFFDUP:
			/*
			 * These are errors because keys are never
			 * duplicated, only data items are.
			 */
			return (__db_pgfmt(dbp, PGNO(hcp->page)));
		}
	}

	/*
	 * Item was not found.
	 */

	if (sought != 0)
		return (ret);

	return (ret);
}

/*
 * __ham_init_dbt --
 *	Initialize a dbt using some possibly already allocated storage
 *	for items.
 *
 * PUBLIC: int __ham_init_dbt __P((DB_ENV *,
 * PUBLIC:     DBT *, u_int32_t, void **, u_int32_t *));
 */
int
__ham_init_dbt(dbenv, dbt, size, bufp, sizep)
	DB_ENV *dbenv;
	DBT *dbt;
	u_int32_t size;
	void **bufp;
	u_int32_t *sizep;
{
	int ret;

	memset(dbt, 0, sizeof(*dbt));
	if (*sizep < size) {
		if ((ret = __os_realloc(dbenv, size, bufp)) != 0) {
			*sizep = 0;
			return (ret);
		}
		*sizep = size;
	}
	dbt->data = *bufp;
	dbt->size = size;
	return (0);
}

/*
 * Adjust the cursor after an insert or delete.  The cursor passed is
 * the one that was operated upon; we just need to check any of the
 * others.
 *
 * len indicates the length of the item added/deleted
 * add indicates if the item indicated by the cursor has just been
 * added (add == 1) or deleted (add == 0).
 * dup indicates if the addition occurred into a duplicate set.
 *
 * PUBLIC: int __ham_c_update
 * PUBLIC:    __P((DBC *, u_int32_t, int, int));
 */
int
__ham_c_update(dbc, len, add, is_dup)
	DBC *dbc;
	u_int32_t len;
	int add, is_dup;
{
	DB *dbp, *ldbp;
	DBC *cp;
	DB_ENV *dbenv;
	DB_LSN lsn;
	DB_TXN *my_txn;
	HASH_CURSOR *hcp, *lcp;
	int found, ret;
	u_int32_t order;

	dbp = dbc->dbp;
	dbenv = dbp->dbenv;
	hcp = (HASH_CURSOR *)dbc->internal;

	/*
	 * Adjustment will only be logged if this is a subtransaction.
	 * Only subtransactions can abort and effect their parent
	 * transactions cursors.
	 */

	my_txn = IS_SUBTRANSACTION(dbc->txn) ? dbc->txn : NULL;
	found = 0;

	MUTEX_THREAD_LOCK(dbenv, dbenv->dblist_mutexp);

	/*
	 * Calculate the order of this deleted record.
	 * This will be one greater than any cursor that is pointing
	 * at this record and already marked as deleted.
	 */
	order = 0;
	if (!add) {
		order = 1;
		for (ldbp = __dblist_get(dbenv, dbp->adj_fileid);
		    ldbp != NULL && ldbp->adj_fileid == dbp->adj_fileid;
		    ldbp = LIST_NEXT(ldbp, dblistlinks)) {
			MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);
			for (cp = TAILQ_FIRST(&ldbp->active_queue); cp != NULL;
			    cp = TAILQ_NEXT(cp, links)) {
				if (cp == dbc || cp->dbtype != DB_HASH)
					continue;
				lcp = (HASH_CURSOR *)cp->internal;
				if (F_ISSET(lcp, H_DELETED) &&
				    hcp->pgno == lcp->pgno &&
				    hcp->indx == lcp->indx &&
				    order <= lcp->order &&
				    (!is_dup || hcp->dup_off == lcp->dup_off))
					order = lcp->order + 1;
			}
			MUTEX_THREAD_UNLOCK(dbenv, dbp->mutexp);
		}
		hcp->order = order;
	}

	for (ldbp = __dblist_get(dbenv, dbp->adj_fileid);
	    ldbp != NULL && ldbp->adj_fileid == dbp->adj_fileid;
	    ldbp = LIST_NEXT(ldbp, dblistlinks)) {
		MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);
		for (cp = TAILQ_FIRST(&ldbp->active_queue); cp != NULL;
		    cp = TAILQ_NEXT(cp, links)) {
			if (cp == dbc || cp->dbtype != DB_HASH)
				continue;

			lcp = (HASH_CURSOR *)cp->internal;

			if (lcp->pgno != hcp->pgno || lcp->indx == NDX_INVALID)
				continue;

			if (my_txn != NULL && cp->txn != my_txn)
				found = 1;

			if (!is_dup) {
				if (add) {
					/*
					 * This routine is not called to add
					 * non-dup records which are always put
					 * at the end.  It is only called from
					 * recovery in this case and the
					 * cursor will be marked deleted.
					 * We are "undeleting" so unmark all
					 * cursors with the same order.
					 */
					if (lcp->indx == hcp->indx
					     && F_ISSET(lcp, H_DELETED)) {
						if (lcp->order == hcp->order)
							F_CLR(lcp, H_DELETED);
						else if (lcp->order >
						    hcp->order) {

						/*
						 * If we've moved this cursor's
						 * index, split its order
						 * number--i.e., decrement it by
						 * enough so that the lowest
						 * cursor moved has order 1.
						 * cp_arg->order is the split
						 * point, so decrement by one
						 * less than that.
						 */
							lcp->order -=
							    (hcp->order - 1);
							lcp->indx += 2;
						}
					} else if (lcp->indx >= hcp->indx)
						lcp->indx += 2;

				} else {
					if (lcp->indx > hcp->indx) {
						lcp->indx -= 2;
						if (lcp->indx == hcp->indx
						    && F_ISSET(lcp, H_DELETED))
							lcp->order += order;
					} else if (lcp->indx == hcp->indx
					    && !F_ISSET(lcp, H_DELETED)) {
						F_SET(lcp, H_DELETED);
						F_CLR(lcp, H_ISDUP);
						lcp->order = order;
					}
				}
			} else if (lcp->indx == hcp->indx) {
				/*
				 * Handle duplicates.  This routine is
				 * only called for on page dups.
				 * Off page dups are handled by btree/rtree
				 * code.
				 */
				if (add) {
					lcp->dup_tlen += len;
					if (lcp->dup_off == hcp->dup_off
					     && F_ISSET(hcp, H_DELETED)
					     && F_ISSET(lcp, H_DELETED)) {
					     /* Abort of a delete. */
						if (lcp->order == hcp->order)
							F_CLR(lcp, H_DELETED);
						else if (lcp->order >
						    hcp->order) {
							lcp->order -=
							    (hcp->order -1);
							lcp->dup_off += len;
						}
					} else if (lcp->dup_off >= hcp->dup_off)
						lcp->dup_off += len;
				} else {
					lcp->dup_tlen -= len;
					if (lcp->dup_off > hcp->dup_off) {
						lcp->dup_off -= len;
						if (lcp->dup_off == hcp->dup_off
						     && F_ISSET(lcp, H_DELETED))
							lcp->order += order;
					} else if (lcp->dup_off ==
					    hcp->dup_off &&
					    !F_ISSET(lcp, H_DELETED)) {
						F_SET(lcp, H_DELETED);
						lcp->order = order;
					}
				}
			}
		}
		MUTEX_THREAD_UNLOCK(dbenv, dbp->mutexp);
	}
	MUTEX_THREAD_UNLOCK(dbenv, dbenv->dblist_mutexp);

	if (found != 0 && DB_LOGGING(dbc)) {
		if ((ret = __ham_curadj_log(dbenv,
		     my_txn, &lsn, 0, dbp->log_fileid, hcp->pgno,
		     hcp->indx, len, hcp->dup_off, add, is_dup, order)) != 0)
			return (ret);
	}

	return (0);
}

/*
 * __ham_get_clist --
 *
 * Get a list of cursors either on a particular bucket or on a particular
 * page and index combination.  The former is so that we can update
 * cursors on a split.  The latter is so we can update cursors when we
 * move items off page.
 *
 * PUBLIC: int __ham_get_clist __P((DB *,
 * PUBLIC:     db_pgno_t, u_int32_t, DBC ***));
 */
int
__ham_get_clist(dbp, pgno, indx, listp)
	DB *dbp;
	db_pgno_t pgno;
	u_int32_t indx;
	DBC ***listp;
{
	DB *ldbp;
	DBC *cp;
	DB_ENV *dbenv;
	int nalloc, nused, ret;

	/*
	 * Assume that finding anything is the exception, so optimize for
	 * the case where there aren't any.
	 */
	nalloc = nused = 0;
	*listp = NULL;
	dbenv = dbp->dbenv;

	MUTEX_THREAD_LOCK(dbenv, dbenv->dblist_mutexp);
	for (ldbp = __dblist_get(dbenv, dbp->adj_fileid);
	    ldbp != NULL && ldbp->adj_fileid == dbp->adj_fileid;
	    ldbp = LIST_NEXT(ldbp, dblistlinks)) {
		MUTEX_THREAD_LOCK(dbenv, dbp->mutexp);
		for (cp = TAILQ_FIRST(&ldbp->active_queue); cp != NULL;
		    cp = TAILQ_NEXT(cp, links))
			/*
			 * We match if cp->pgno matches the specified
			 * pgno, and if either the cp->indx matches
			 * or we weren't given an index.
			 */
			if (cp->internal->pgno == pgno &&
			    (indx == NDX_INVALID ||
			    cp->internal->indx == indx)) {
				if (nused >= nalloc) {
					nalloc += 10;
					if ((ret = __os_realloc(dbp->dbenv,
					    nalloc * sizeof(HASH_CURSOR *),
					    listp)) != 0)
						return (ret);
				}
				(*listp)[nused++] = cp;
			}

		MUTEX_THREAD_UNLOCK(dbp->dbenv, dbp->mutexp);
	}
	MUTEX_THREAD_UNLOCK(dbenv, dbenv->dblist_mutexp);

	if (listp != NULL) {
		if (nused >= nalloc) {
			nalloc++;
			if ((ret = __os_realloc(dbp->dbenv,
			    nalloc * sizeof(HASH_CURSOR *), listp)) != 0)
				return (ret);
		}
		(*listp)[nused] = NULL;
	}
	return (0);
}

static int
__ham_c_writelock(dbc)
	DBC *dbc;
{
	HASH_CURSOR *hcp;
	DB_LOCK tmp_lock;
	int ret;

	/*
	 * All we need do is acquire the lock and let the off-page
	 * dup tree do its thing.
	 */
	if (!STD_LOCKING(dbc))
		return (0);

	hcp = (HASH_CURSOR *)dbc->internal;
	if ((!LOCK_ISSET(hcp->lock) || hcp->lock_mode == DB_LOCK_READ)) {
		tmp_lock = hcp->lock;
		if ((ret = __ham_lock_bucket(dbc, DB_LOCK_WRITE)) != 0)
			return (ret);
		if (LOCK_ISSET(tmp_lock) &&
		    (ret = lock_put(dbc->dbp->dbenv, &tmp_lock)) != 0)
			return (ret);
	}
	return (0);
}
