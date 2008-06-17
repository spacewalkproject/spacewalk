/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char copyright[] =
    "Copyright (c) 1996-2001\nSleepycat Software Inc.  All rights reserved.\n";
static const char revid[] =
    "$Id: env_recover.c,v 1.1.1.1 2002-01-11 00:21:35 apingel Exp $";
#endif

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#if TIME_WITH_SYS_TIME
#include <sys/time.h>
#include <time.h>
#else
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#else
#include <time.h>
#endif
#endif

#include <string.h>
#endif

#include "db_int.h"
#include "db_page.h"
#include "db_dispatch.h"
#include "db_am.h"
#include "log.h"
#include "txn.h"

static int    __log_earliest __P((DB_ENV *, int32_t *, DB_LSN *));
static double __lsn_diff __P((DB_LSN *, DB_LSN *, DB_LSN *, u_int32_t, int));

/*
 * __db_apprec --
 *	Perform recovery.
 *
 * PUBLIC: int __db_apprec __P((DB_ENV *, u_int32_t));
 */
int
__db_apprec(dbenv, flags)
	DB_ENV *dbenv;
	u_int32_t flags;
{
	DBT data;
	DB_LSN ckp_lsn, first_lsn, last_lsn, lowlsn, lsn, open_lsn;
	DB_TXNREGION *region;
	__txn_ckp_args *ckp_args;
	time_t now, tlow;
	double nfiles;
	int32_t low;
	int is_thread, progress, ret;
	void *txninfo;

	COMPQUIET(nfiles, (double)0);

	ckp_args = NULL;

	/*
	 * Save the state of the thread flag -- we don't need it on at the
	 * moment because we're single-threaded until recovery is complete.
	 */
	is_thread = F_ISSET(dbenv, DB_ENV_THREAD) ? 1 : 0;
	F_CLR(dbenv, DB_ENV_THREAD);

	/* Set in-recovery flags. */
	F_SET((DB_LOG *)dbenv->lg_handle, DBLOG_RECOVER);
	region = ((DB_TXNMGR *)dbenv->tx_handle)->reginfo.primary;
	F_SET(region, TXN_IN_RECOVERY);

	/*
	 * If the user is specifying recovery to a particular point in time,
	 * verify that the logs present are sufficient to do this.
	 */
	ZERO_LSN(lowlsn);
	if (dbenv->tx_timestamp != 0) {
		if ((ret = __log_earliest(dbenv, &low, &lowlsn)) != 0)
			return (ret);
		if ((int32_t)dbenv->tx_timestamp < low) {
			char t1[30], t2[30];

			strcpy(t1, ctime(&dbenv->tx_timestamp));
			tlow = (time_t)low;
			strcpy(t2, ctime(&tlow));
			__db_err(dbenv,
		     "Invalid recovery timestamp %.*s; earliest time is %.*s",
			    24, t1, 24, t2);
			return (EINVAL);
		}
	}

	/* Initialize the transaction list. */
	if ((ret = __db_txnlist_init(dbenv, &txninfo)) != 0)
		return (ret);

	/*
	 * Recovery is done in three passes:
	 * Pass #0:
	 *	We need to find the position from which we will open files.
	 *	We need to open files beginning with the earliest of the next
	 *	to last checkpoint, the most recent checkpoint LSN, and a
	 *	checkpoint LSN before the recovery timestamp, if specified.  We
	 *	need two checkpoints, because we might have crashed after
	 *	writing the last checkpoint record, but before having written
	 *	out all	the open file information.  We need to be before the
	 *	most recent checkpoint LSN because we are also going to collect
	 *	information about which transactions were begun before we
	 *	start rolling forward.  Those that were should never be undone
	 *	because queue cannot use LSNs to determine what operations can
	 *	safely be aborted and it cannot rollback operations in
	 *	transactions for which there may be records not processed
	 *	during recovery.  We need to consider earlier points in time
	 *	in case we are recovering to a particular timestamp.
	 *
	 * Pass #1:
	 *	Read forward through the log from the position found in pass 0
	 *	opening and closing files, and recording transactions for which
	 *	we've seen their first record (the transaction's prev_lsn is
	 *	0,0).  At the end of this pass, we know all transactions for
	 *	which we've seen begins and we have the "current" set of files
	 *	open.
	 *
	 * Pass #2:
	 *	Read backward through the log undoing any uncompleted TXNs.
	 *	There are three cases:
	 *	    1.  If doing catastrophic recovery, we read to the
	 *		beginning of the log
	 *	    2.  If we are doing normal reovery, then we have to roll
	 *		back to the most recent checkpoint that occurs
	 *		before the most recent checkpoint LSN, which is
	 *		returned by __log_findckp().
	 *	    3.  If we are recovering to a point in time, then we have
	 *		to roll back to the checkpoint whose ckp_lsn is earlier
	 *		than the specified time.  __log_earliest will figure
	 *		this out for us.
	 *	In case 2, "uncompleted TXNs" include all those who commited
	 *	after the user's specified timestamp.
	 *
	 * Pass #3:
	 *	Read forward through the log from the LSN found in pass #2,
	 *	redoing any committed TXNs (which commited after any user-
	 *	specified rollback point).  During this pass, checkpoint
	 *	file information is ignored, and file openings and closings
	 *	are redone.
	 */

	/*
	 * Find out the last lsn, so that we can estimate how far along we
	 * are in recovery.  This will help us determine how much log there
	 * is between the first LSN that we're going to be working with and
	 * the last one.  We assume that each of the three phases takes the
	 * same amount of time (a false assumption) and then use the %-age
	 * of the amount of log traversed to figure out how much of the
	 * pass we've accomplished.
	 *
	 * If we can't find any log records, we're kind of done.
	 */
	memset(&data, 0, sizeof(data));
	if (dbenv->db_feedback != NULL &&
	    (ret = log_get(dbenv, &last_lsn, &data, DB_LAST)) != 0) {
		if (ret == DB_NOTFOUND)
			ret = 0;
		else
			__db_err(dbenv, "Last log record not found");
		goto out;
	}

	/*
	 * Pass #0
	 * Find the LSN from which we begin OPENFILES.  It is the minimum of
	 * 1) the second to last checkpoint in the log 2) the LSN of the
	 * ckp_lsn in the last checkpoint, and 3) the checkpoint before the
	 * ckp_lsn before the recovery timestamp.
	 */
	if (LF_ISSET(DB_RECOVER_FATAL)) {
		if ((ret = log_get(dbenv, &ckp_lsn, &data, DB_FIRST)) != 0) {
			if (ret == DB_NOTFOUND)
				ret = 0;
			else
				__db_err(dbenv, "First log record not found");
			goto out;
		}
		open_lsn = ckp_lsn;
	} else {
		/*
		 * Find the first LSN that we need to consider.  This
		 * is either the one in the last checkpoint, the first,
		 * LSN in the log, or the one selected to make timestamp-
		 * based recovery work.
		 */
		if ((ret = __log_findckp(dbenv, &first_lsn)) == DB_NOTFOUND) {
			/*
			 * We don't require that log files exist if recovery
			 * was specified.
			 */
			ret = 0;
			goto out;
		}
		if (ret != 0)
			goto out;


		/*
		 * XXX We just read the last checkpoint in log_findckp; it
		 * would be nice if we didn't have to do it again.
		 */
		if ((ret =
		     log_get(dbenv, &ckp_lsn, &data, DB_CHECKPOINT)) != 0) {
			/*
			 * If we don't find a checkpoint, start from the
			 * beginning.
			 */
			open_lsn = ckp_lsn = first_lsn;
			goto get_it;
		} else if ((ret =
		     __txn_ckp_read(dbenv, data.data, &ckp_args)) != 0) {
			__db_err(dbenv, 
			    "Invalid checkpoint record at [%ld][%ld]",
			    (u_long)ckp_lsn.file, (u_long)ckp_lsn.offset);
			goto out;
		} else if (IS_ZERO_LSN(ckp_args->last_ckp) ||
		    (ret = log_get(dbenv,
		    &ckp_args->last_ckp, &data, DB_SET)) != 0) {
			open_lsn = ckp_lsn = first_lsn;
			goto get_it;
		} else {
			/*
			 * Because queue uses record locking we need back up
			 * till we know all previous transactions are on disk.
			 * This info is contained in the last checkpoint.
			 */

			if (log_compare(&ckp_args->last_ckp, &first_lsn) < 0)
				open_lsn = ckp_args->last_ckp;
			else 
				open_lsn = first_lsn;

			if (dbenv->tx_timestamp != 0
			    && log_compare(&lowlsn, &open_lsn) < 0)
				open_lsn = lowlsn;

			if (log_compare(&open_lsn, &ckp_args->last_ckp) !=0) {
get_it:				if ((ret = log_get(dbenv,
				     &open_lsn, &data, DB_SET)) != 0)
					goto out;
			}
		}
	}

	if (dbenv->db_feedback != NULL) {
		if (last_lsn.file == open_lsn.file)
			nfiles = (double)(last_lsn.offset - open_lsn.offset) /
			    dbenv->lg_max;
		else
			nfiles = (double)(last_lsn.file - open_lsn.file) +
			    (double)(dbenv->lg_max - open_lsn.offset +
			    last_lsn.offset) / dbenv->lg_max;
		/* We are going to divide by nfiles; make sure it isn't 0. */
		if (nfiles == 0)
			nfiles = (double)0.001;
	}

	/*
	 * Pass #1
	 * Now, ckp_lsn is either the lsn of the last checkpoint
	 * or the lsn of the first record in the log.  Open_lsn is
	 * either the second to last checkpoint, the beinning of the log,
	 * or the point to which we'll recover.  That is the point from
	 * which we being OPENFILES.
	 */
	if ((ret = __env_openfiles(dbenv,
	    txninfo, &data, &open_lsn, &last_lsn, nfiles, 1)) != 0)
		goto out;

	/*
	 * Pass #2.
	 *
	 * We used open_lsn to tell us how far back we need to recover,
	 * use it here.
	 */
	first_lsn = open_lsn;

	if (FLD_ISSET(dbenv->verbose, DB_VERB_RECOVERY))
		__db_err(dbenv, "Recovery starting from [%lu][%lu]",
		    (u_long)first_lsn.file, (u_long)first_lsn.offset);

	for (ret = log_get(dbenv, &lsn, &data, DB_LAST);
	    ret == 0 && log_compare(&lsn, &first_lsn) >= 0;
	    ret = log_get(dbenv, &lsn, &data, DB_PREV)) {
		if (dbenv->db_feedback != NULL) {
			progress = 34 + (int)(33 * (__lsn_diff(&open_lsn,
			    &last_lsn, &lsn, dbenv->lg_max, 0) / nfiles));
			dbenv->db_feedback(dbenv, DB_RECOVER, progress);
		}
		ret = __db_dispatch(dbenv,
		    &data, &lsn, DB_TXN_BACKWARD_ROLL, txninfo);
		if (ret != 0) {
			if (ret != DB_TXN_CKP)
				goto msgerr;
			else
				ret = 0;
		}
	}
	if (ret != 0 && ret != DB_NOTFOUND)
		goto out;

	/*
	 * Pass #3.
	 */
	for (ret = log_get(dbenv, &lsn, &data, DB_NEXT);
	    ret == 0; ret = log_get(dbenv, &lsn, &data, DB_NEXT)) {
		if (dbenv->db_feedback != NULL) {
			progress = 67 + (int)(33 * (__lsn_diff(&open_lsn,
			    &last_lsn, &lsn, dbenv->lg_max, 1) / nfiles));
			dbenv->db_feedback(dbenv, DB_RECOVER, progress);
		}
		ret = __db_dispatch(dbenv,
		    &data, &lsn, DB_TXN_FORWARD_ROLL, txninfo);
		if (ret != 0) {
			if (ret != DB_TXN_CKP)
				goto msgerr;
			else
				ret = 0;
		}
	}
	if (ret != DB_NOTFOUND)
		goto out;

	/*
	 * Process any pages that were on the limbo list
	 * and move them to the free list.  Do this
	 * before checkpointing the database.
	 */
	 if ((ret = __db_do_the_limbo(dbenv, txninfo)) != 0)
		goto out;

	/*
	 * Now set the last checkpoint lsn and the current time,
	 * take a checkpoint, and reset the txnid.
	 */
	(void)time(&now);
	region->last_txnid = ((DB_TXNHEAD *)txninfo)->maxid;
	region->last_ckp = ckp_lsn;
	region->time_ckp = (u_int32_t)now;

	/*
	 * Take two checkpoints so that we don't re-recover any of the
	 * work we've already done.
	 */
	if ((ret = txn_checkpoint(dbenv, 0, 0, DB_FORCE)) != 0)
		goto out;

	/* Now close all the db files that are open. */
	__log_close_files(dbenv);

	if ((ret = txn_checkpoint(dbenv, 0, 0, DB_FORCE)) != 0)
		goto out;
	if (region->nrestores == 0)
		region->last_txnid = TXN_MINIMUM;

	if (FLD_ISSET(dbenv->verbose, DB_VERB_RECOVERY)) {
		__db_err(dbenv, "Recovery complete at %.24s", ctime(&now));
		__db_err(dbenv, "%s %lx %s [%lu][%lu]",
		    "Maximum transaction ID",
		    ((DB_TXNHEAD *)txninfo)->maxid,
		    "Recovery checkpoint",
		    (u_long)region->last_ckp.file,
		    (u_long)region->last_ckp.offset);
	}

	if (0) {
msgerr:		__db_err(dbenv, "Recovery function for LSN %lu %lu failed",
		    (u_long)lsn.file, (u_long)lsn.offset);
	}

out:	__db_txnlist_end(dbenv, txninfo);

	if (ckp_args != NULL)
		__os_free(dbenv, ckp_args, sizeof(*ckp_args));

	dbenv->tx_timestamp = 0;

	/* Restore the state of the thread flag, clear in-recovery flags. */
	if (is_thread)
		F_SET(dbenv, DB_ENV_THREAD);
	F_CLR((DB_LOG *)dbenv->lg_handle, DBLOG_RECOVER);
	F_CLR(region, TXN_IN_RECOVERY);

	return (ret);
}

/*
 * Figure out how many logfiles we have processed.  If we are moving
 * forward (is_forward != 0), then we're computing current - low.  If
 * we are moving backward, we are computing high - current.  max is
 * the number of bytes per logfile.
 */
static double
__lsn_diff(low, high, current, max, is_forward)
	DB_LSN *low, *high, *current;
	u_int32_t max;
	int is_forward;
{
	double nf;

	/*
	 * There are three cases in each direction.  If you are in the
	 * same file, then all you need worry about is the difference in
	 * offsets.  If you are in different files, then either your offsets
	 * put you either more or less than the integral difference in the
	 * number of files -- we need to handle both of these.
	 */
	if (is_forward) {
		if (current->file == low->file)
			nf = (double)(current->offset - low->offset) / max;
		else if (current->offset < low->offset)
			nf = (double)(current->file - low->file - 1) +
			    (double)(max - low->offset + current->offset) / max;
		else
			nf = (double)(current->file - low->file) +
			    (double)(current->offset - low->offset) / max;
	} else {
		if (current->file == high->file)
			nf = (double)(high->offset - current->offset) / max;
		else if (current->offset > high->offset)
			nf = (double)(high->file - current->file - 1) +
			    (double)
			    (max - current->offset + high->offset) / max;
		else
			nf = (double)(high->file - current->file) +
			    (double)(high->offset - current->offset) / max;
	}
	return (nf);
}

/*
 * __log_earliest --
 *
 * Return the earliest recovery point for the log files present.  The
 * earliest recovery time is the time stamp of the first checkpoint record
 * whose checkpoint LSN is greater than the first LSN we process.
 */
static int
__log_earliest(dbenv, lowtime, lowlsn)
	DB_ENV *dbenv;
	int32_t *lowtime;
	DB_LSN *lowlsn;
{
	DB_LSN first_lsn, lsn;
	DBT data;
	__txn_ckp_args *ckpargs;
	u_int32_t rectype;
	int cmp, ret;

	memset(&data, 0, sizeof(data));
	/*
	 * Read forward through the log looking for the first checkpoint
	 * record whose ckp_lsn is greater than first_lsn.
	 */

	for (ret = log_get(dbenv, &first_lsn, &data, DB_FIRST);
	    ret == 0; ret = log_get(dbenv, &lsn, &data, DB_NEXT)) {
		if (ret != 0)
			break;
		memcpy(&rectype, data.data, sizeof(rectype));
		if (rectype != DB_txn_ckp)
			continue;
		if ((ret = __txn_ckp_read(dbenv, data.data, &ckpargs)) == 0) {
			cmp = log_compare(&ckpargs->ckp_lsn, &first_lsn);
			*lowlsn = ckpargs->ckp_lsn;
			*lowtime = ckpargs->timestamp;

			__os_free(dbenv, ckpargs, 0);
			if (cmp >= 0)
				break;
		}
	}

	return (ret);
}

/*
 * __env_openfiles --
 * Perform the pass of recovery that opens files.  This is used
 * both during recover and before txn_recover, since we need files
 * open in order to abort prepared, but not yet committed transactions.
 * See the comments in db_apprec for a detailed description of the
 * various recovery passes.
 *
 * If we are not doing feedback processing (i.e., we are doing txn_recover
 * processing and in_recovery is zero), then last_lsn can be NULL.
 *
 * PUBLIC: int __env_openfiles __P((DB_ENV *,
 * PUBLIC:     void *, DBT *, DB_LSN *, DB_LSN *, double, int));
 */
int
__env_openfiles(dbenv, txninfo, data, open_lsn, last_lsn, nfiles, in_recovery)
	DB_ENV *dbenv;
	void *txninfo;
	DBT *data;
	DB_LSN *open_lsn, *last_lsn;
	int in_recovery;
	double nfiles;
{
	DB_LSN lsn;
	int progress, ret;

	lsn = *open_lsn;
	for (;;) {
		if (in_recovery && dbenv->db_feedback != NULL) {
			DB_ASSERT(last_lsn != NULL);
			progress = (int)(33 * (__lsn_diff(open_lsn,
			   last_lsn, &lsn, dbenv->lg_max, 1) / nfiles));
			dbenv->db_feedback(dbenv, DB_RECOVER, progress);
		}
		ret = __db_dispatch(dbenv,
		    data, &lsn,
		    in_recovery ? DB_TXN_OPENFILES : DB_TXN_POPENFILES,
		    txninfo);
		if (ret != 0 && ret != DB_TXN_CKP) {
			__db_err(dbenv,
			    "Recovery function for LSN %lu %lu failed",
			    (u_long)lsn.file, (u_long)lsn.offset);
			break;
		}
		if ((ret = log_get(dbenv, &lsn, data, DB_NEXT)) != 0) {
			if (ret == DB_NOTFOUND)
				ret = 0;
			break;
		}
	}

	return (ret);
}
