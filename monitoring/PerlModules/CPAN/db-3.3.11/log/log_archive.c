/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: log_archive.c,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#endif

#ifdef  HAVE_RPC
#include "db_server.h"
#endif

#include "db_int.h"
#include "db_page.h"
#include "log.h"
#include "qam.h"
#include "clib_ext.h"			/* XXX: needed for getcwd. */

#ifdef HAVE_RPC
#include "rpc_client_ext.h"
#endif

static int __absname __P((DB_ENV *, char *, char *, char **));
static int __build_data __P((DB_ENV *, char *, char ***));
static int __cmpfunc __P((const void *, const void *));
static int __usermem __P((DB_ENV *, char ***));

/*
 * log_archive --
 *	Supporting function for db_archive(1).
 *
 * EXTERN: int log_archive __P((DB_ENV *, char **[], u_int32_t));
 */
int
log_archive(dbenv, listp, flags)
	DB_ENV *dbenv;
	char ***listp;
	u_int32_t flags;
{
	DBT rec;
	DB_LOG *dblp;
	DB_LSN stable_lsn;
	u_int32_t fnum;
	int array_size, db_arch_abs, n, ret;
	char **array, **arrayp, *name, *p, *pref, buf[MAXPATHLEN];

#ifdef HAVE_RPC
	if (F_ISSET(dbenv, DB_ENV_RPCCLIENT))
		return (__dbcl_log_archive(dbenv, listp, flags));
#endif

	PANIC_CHECK(dbenv);
	ENV_REQUIRES_CONFIG(dbenv,
	    dbenv->lg_handle, "log_archive", DB_INIT_LOG);

	name = NULL;
	dblp = dbenv->lg_handle;
	COMPQUIET(fnum, 0);

#define	OKFLAGS	(DB_ARCH_ABS | DB_ARCH_DATA | DB_ARCH_LOG)
	if (flags != 0) {
		if ((ret =
		    __db_fchk(dbenv, "log_archive", flags, OKFLAGS)) != 0)
			return (ret);
		if ((ret =
		    __db_fcchk(dbenv,
			"log_archive", flags, DB_ARCH_DATA, DB_ARCH_LOG)) != 0)
			return (ret);
	}

	if (LF_ISSET(DB_ARCH_ABS)) {
		db_arch_abs = 1;
		LF_CLR(DB_ARCH_ABS);
	} else
		db_arch_abs = 0;

	if (flags == 0 || flags == DB_ARCH_DATA)
		ENV_REQUIRES_CONFIG(dbenv,
		    dbenv->tx_handle, "log_archive", DB_INIT_TXN);

	/*
	 * Get the absolute pathname of the current directory.  It would
	 * be nice to get the shortest pathname of the database directory,
	 * but that's just not possible.
	 *
	 * XXX
	 * Can't trust getcwd(3) to set a valid errno.  If it doesn't, just
	 * guess that we ran out of memory.
	 */
	if (db_arch_abs) {
		__os_set_errno(0);
		if ((pref = getcwd(buf, sizeof(buf))) == NULL) {
			if (__os_get_errno() == 0)
				__os_set_errno(ENOMEM);
			return (__os_get_errno());
		}
	} else
		pref = NULL;

	switch (flags) {
	case DB_ARCH_DATA:
		return (__build_data(dbenv, pref, listp));
	case DB_ARCH_LOG:
		memset(&rec, 0, sizeof(rec));
		if (F_ISSET(dbenv, DB_ENV_THREAD))
			F_SET(&rec, DB_DBT_MALLOC);
		if ((ret = log_get(dbenv, &stable_lsn, &rec, DB_LAST)) != 0)
			return (ret);
		if (F_ISSET(dbenv, DB_ENV_THREAD))
			__os_free(dbenv, rec.data, rec.size);
		fnum = stable_lsn.file;
		break;
	case 0:
		if ((ret = __log_findckp(dbenv, &stable_lsn)) != 0) {
			/*
			 * A return of DB_NOTFOUND means that we didn't find
			 * any records in the log (so we are not going to be
			 * deleting any log files).
			 */
			if (ret != DB_NOTFOUND)
				return (ret);
			*listp = NULL;
			return (0);
		}
		/* Remove any log files before the last stable LSN. */
		fnum = stable_lsn.file - 1;
		break;
	}

#define	LIST_INCREMENT	64
	/* Get some initial space. */
	array_size = 10;
	if ((ret = __os_malloc(dbenv,
	    sizeof(char *) * array_size, &array)) != 0)
		return (ret);
	array[0] = NULL;

	/* Build an array of the file names. */
	for (n = 0; fnum > 0; --fnum) {
		if ((ret = __log_name(dblp, fnum, &name, NULL, 0)) != 0)
			goto err;
		if (__os_exists(name, NULL) != 0) {
			if (LF_ISSET(DB_ARCH_LOG) && fnum == stable_lsn.file)
				continue;
			__os_freestr(dbenv, name);
			name = NULL;
			break;
		}

		if (n >= array_size - 1) {
			array_size += LIST_INCREMENT;
			if ((ret = __os_realloc(dbenv,
			    sizeof(char *) * array_size, &array)) != 0)
				goto err;
		}

		if (db_arch_abs) {
			if ((ret = __absname(dbenv,
			    pref, name, &array[n])) != 0)
				goto err;
			__os_freestr(dbenv, name);
		} else if ((p = __db_rpath(name)) != NULL) {
			if ((ret = __os_strdup(dbenv, p + 1, &array[n])) != 0)
				goto err;
			__os_freestr(dbenv, name);
		} else
			array[n] = name;

		name = NULL;
		array[++n] = NULL;
	}

	/* If there's nothing to return, we're done. */
	if (n == 0) {
		*listp = NULL;
		ret = 0;
		goto err;
	}

	/* Sort the list. */
	qsort(array, (size_t)n, sizeof(char *), __cmpfunc);

	/* Rework the memory. */
	if ((ret = __usermem(dbenv, &array)) != 0)
		goto err;

	*listp = array;
	return (0);

err:	if (array != NULL) {
		for (arrayp = array; *arrayp != NULL; ++arrayp)
			__os_freestr(dbenv, *arrayp);
		__os_free(dbenv, array, sizeof(char *) * array_size);
	}
	if (name != NULL)
		__os_freestr(dbenv, name);
	return (ret);
}

/*
 * __build_data --
 *	Build a list of datafiles for return.
 */
static int
__build_data(dbenv, pref, listp)
	DB_ENV *dbenv;
	char *pref, ***listp;
{
	DBT rec;
	DB_LSN lsn;
	__log_register_args *argp;
	u_int32_t rectype;
	int array_size, last, n, nxt, ret;
	char **array, **arrayp, **list, **lp, *p, *real_name;

	/* Get some initial space. */
	array_size = 10;
	if ((ret = __os_malloc(dbenv,
	    sizeof(char *) * array_size, &array)) != 0)
		return (ret);
	array[0] = NULL;

	memset(&rec, 0, sizeof(rec));
	if (F_ISSET(dbenv, DB_ENV_THREAD))
		F_SET(&rec, DB_DBT_MALLOC);
	for (n = 0, ret = log_get(dbenv, &lsn, &rec, DB_LAST);
	    ret == 0; ret = log_get(dbenv, &lsn, &rec, DB_PREV)) {
		if (rec.size < sizeof(rectype)) {
			ret = EINVAL;
			__db_err(dbenv, "log_archive: bad log record");
			goto lg_free;
		}

		memcpy(&rectype, rec.data, sizeof(rectype));
		if (rectype != DB_log_register) {
			if (F_ISSET(dbenv, DB_ENV_THREAD)) {
				__os_free(dbenv, rec.data, rec.size);
				rec.data = NULL;
			}
			continue;
		}
		if ((ret = __log_register_read(dbenv, rec.data, &argp)) != 0) {
			ret = EINVAL;
			__db_err(dbenv,
			    "log_archive: unable to read log record");
			goto lg_free;
		}

		if (n >= array_size - 1) {
			array_size += LIST_INCREMENT;
			if ((ret = __os_realloc(dbenv,
			    sizeof(char *) * array_size, &array)) != 0)
				goto lg_free;
		}

		if ((ret = __os_strdup(dbenv,
		    argp->name.data, &array[n++])) != 0)
			goto lg_free;

		if (argp->ftype == DB_QUEUE) {
			if ((ret = __qam_extent_names(dbenv,
			    argp->name.data, &list)) != 0)
				goto q_err;
			for (lp = list;
			    lp != NULL && *lp != NULL; lp++) {
				if (n >= array_size - 1) {
					array_size += LIST_INCREMENT;
					if ((ret = __os_realloc(dbenv,
					    sizeof(char *) *
					    array_size, &array)) != 0)
						goto q_err;
				}
				if ((ret =
				    __os_strdup(dbenv, *lp, &array[n++])) != 0)
					goto q_err;
			}

q_err:
			if (list != NULL)
				__os_free(dbenv, list, 0);
		}

lg_free:
		__os_free(dbenv, argp, 0);
		if (F_ISSET(dbenv, DB_ENV_THREAD && rec.data != NULL)) {
			__os_free(dbenv, rec.data, rec.size);
			rec.data = NULL;
		}
		if (ret != 0)
			goto err1;
	}

	/* If there's nothing to return, we're done. */
	if (n == 0) {
		ret = 0;
		*listp = NULL;
		goto err1;
	}

	array[n] = NULL;

	/* Sort the list. */
	qsort(array, (size_t)n, sizeof(char *), __cmpfunc);

	/*
	 * Build the real pathnames, discarding nonexistent files and
	 * duplicates.
	 */
	for (last = nxt = 0; nxt < n;) {
		/*
		 * Discard duplicates.  Last is the next slot we're going
		 * to return to the user, nxt is the next slot that we're
		 * going to consider.
		 */
		if (last != nxt) {
			array[last] = array[nxt];
			array[nxt] = NULL;
		}
		for (++nxt; nxt < n &&
		    strcmp(array[last], array[nxt]) == 0; ++nxt) {
			__os_freestr(dbenv, array[nxt]);
			array[nxt] = NULL;
		}

		/* Get the real name. */
		if ((ret = __db_appname(dbenv,
		    DB_APP_DATA, NULL, array[last], 0, NULL, &real_name)) != 0)
			goto err2;

		/* If the file doesn't exist, ignore it. */
		if (__os_exists(real_name, NULL) != 0) {
			__os_freestr(dbenv, real_name);
			__os_freestr(dbenv, array[last]);
			array[last] = NULL;
			continue;
		}

		/* Rework the name as requested by the user. */
		__os_freestr(dbenv, array[last]);
		array[last] = NULL;
		if (pref != NULL) {
			ret = __absname(dbenv, pref, real_name, &array[last]);
			__os_freestr(dbenv, real_name);
			if (ret != 0)
				goto err2;
		} else if ((p = __db_rpath(real_name)) != NULL) {
			ret = __os_strdup(dbenv, p + 1, &array[last]);
			__os_freestr(dbenv, real_name);
			if (ret != 0)
				goto err2;
		} else
			array[last] = real_name;
		++last;
	}

	/* NULL-terminate the list. */
	array[last] = NULL;

	/* Rework the memory. */
	if ((ret = __usermem(dbenv, &array)) != 0)
		goto err1;

	*listp = array;
	return (0);

err2:	/*
	 * XXX
	 * We've possibly inserted NULLs into the array list, so clean up a
	 * bit so that the other error processing works.
	 */
	if (array != NULL)
		for (; nxt < n; ++nxt)
			__os_freestr(dbenv, array[nxt]);
	/* FALLTHROUGH */

err1:	if (array != NULL) {
		for (arrayp = array; *arrayp != NULL; ++arrayp)
			__os_freestr(dbenv, *arrayp);
		__os_free(dbenv, array, array_size * sizeof(char *));
	}
	return (ret);
}

/*
 * __absname --
 *	Return an absolute path name for the file.
 */
static int
__absname(dbenv, pref, name, newnamep)
	DB_ENV *dbenv;
	char *pref, *name, **newnamep;
{
	size_t l_pref, l_name;
	int isabspath, ret;
	char *newname;

	l_name = strlen(name);
	isabspath = __os_abspath(name);
	l_pref = isabspath ? 0 : strlen(pref);

	/* Malloc space for concatenating the two. */
	if ((ret = __os_malloc(dbenv,
	    l_pref + l_name + 2, &newname)) != 0)
		return (ret);
	*newnamep = newname;

	/* Build the name.  If `name' is an absolute path, ignore any prefix. */
	if (!isabspath) {
		memcpy(newname, pref, l_pref);
		if (strchr(PATH_SEPARATOR, newname[l_pref - 1]) == NULL)
			newname[l_pref++] = PATH_SEPARATOR[0];
	}
	memcpy(newname + l_pref, name, l_name + 1);

	return (0);
}

/*
 * __usermem --
 *	Create a single chunk of memory that holds the returned information.
 *	If the user has their own malloc routine, use it.
 */
static int
__usermem(dbenv, listp)
	DB_ENV *dbenv;
	char ***listp;
{
	size_t len;
	int ret;
	char **array, **arrayp, **orig, *strp;

	/* Find out how much space we need. */
	for (len = 0, orig = *listp; *orig != NULL; ++orig)
		len += sizeof(char *) + strlen(*orig) + 1;
	len += sizeof(char *);

	/* Allocate it and set up the pointers. */
	if ((ret = __os_umalloc(dbenv, len, &array)) != 0)
		return (ret);

	strp = (char *)(array + (orig - *listp) + 1);

	/* Copy the original information into the new memory. */
	for (orig = *listp, arrayp = array; *orig != NULL; ++orig, ++arrayp) {
		len = strlen(*orig);
		memcpy(strp, *orig, len + 1);
		*arrayp = strp;
		strp += len + 1;

		__os_freestr(dbenv, *orig);
	}

	/* NULL-terminate the list. */
	*arrayp = NULL;

	__os_free(dbenv, *listp, 0);
	*listp = array;

	return (0);
}

static int
__cmpfunc(p1, p2)
	const void *p1, *p2;
{
	return (strcmp(*((char * const *)p1), *((char * const *)p2)));
}
