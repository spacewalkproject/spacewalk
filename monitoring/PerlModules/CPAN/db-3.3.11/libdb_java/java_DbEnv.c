/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: java_DbEnv.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#include <jni.h>
#include <stdlib.h>
#include <string.h>

#include "db_int.h"
#include "java_util.h"
#include "com_sleepycat_db_DbEnv.h"

/* We keep these lined up, and alphabetical by field name,
 * for comparison with C++'s list.
 */
JAVADB_WO_ACCESS_STRING(DbEnv,        data_1dir, DB_ENV, data_dir)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lg_1bsize, DB_ENV, lg_bsize)
JAVADB_WO_ACCESS_STRING(DbEnv,        lg_1dir, DB_ENV, lg_dir)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lg_1max, DB_ENV, lg_max)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lg_1regionmax, DB_ENV, lg_regionmax)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lk_1detect, DB_ENV, lk_detect)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lk_1max, DB_ENV, lk_max)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lk_1max_1locks, DB_ENV, lk_max_locks)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lk_1max_1lockers, DB_ENV, lk_max_lockers)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  lk_1max_1objects, DB_ENV, lk_max_objects)
/* mp_mmapsize is declared below, it needs an extra cast */
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  mutexlocks, DB_ENV, mutexlocks)
JAVADB_WO_ACCESS_STRING(DbEnv,        tmp_1dir, DB_ENV, tmp_dir)
JAVADB_WO_ACCESS_METHOD(DbEnv, jint,  tx_1max, DB_ENV, tx_max)

static void DbEnv_errcall_callback(const char *prefix, char *message)
{
	JNIEnv *jnienv;
	DB_ENV_JAVAINFO *envinfo = (DB_ENV_JAVAINFO *)prefix;
	jstring pre;

	/* Note: these error cases are "impossible", and would
	 * normally warrant an exception.  However, without
	 * a jnienv, we cannot throw an exception...
	 * We don't want to trap or exit, since the point of
	 * this facility is for the user to completely control
	 * error situations.
	 */
	if (envinfo == NULL) {
		/* Something is *really* wrong here, the
		 * prefix is set in every environment created.
		 */
		fprintf(stderr, "Error callback failed!\n");
		fprintf(stderr, "error: %s\n", message);
		return;
	}

	/* Should always succeed... */
	jnienv = dbjie_get_jnienv(envinfo);

	if (jnienv == NULL) {

		/* But just in case... */
		fprintf(stderr, "Cannot attach to current thread!\n");
		fprintf(stderr, "error: %s\n", message);
		return;
	}

	pre = dbjie_get_errpfx(envinfo, jnienv);
	report_errcall(jnienv, dbjie_get_errcall(envinfo), pre, message);
}

static void DbEnv_initialize(JNIEnv *jnienv, DB_ENV *dbenv,
			     /*DbEnv*/ jobject jenv,
			     /*DbErrcall*/ jobject jerrcall,
			     int is_dbopen)
{
	DB_ENV_JAVAINFO *envinfo;

	envinfo = get_DB_ENV_JAVAINFO(jnienv, jenv);
	DB_ASSERT(envinfo == NULL);
	envinfo = dbjie_construct(jnienv, jerrcall, is_dbopen);
	set_private_info(jnienv, name_DB_ENV, jenv, envinfo);
	dbenv->set_errpfx(dbenv, (const char*)envinfo);
	dbenv->set_errcall(dbenv, DbEnv_errcall_callback);
	dbenv->cj_internal = envinfo;
	set_private_dbobj(jnienv, name_DB_ENV, jenv, dbenv);
}

/* This is called when this DbEnv was made on behalf of a Db
 * created directly (without a parent DbEnv), and the Db is
 * being closed.  We'll zero out the pointer to the DB_ENV,
 * since it is no longer valid, to prevent mistakes.
 */
JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1notify_1db_1close
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	DB_ENV_JAVAINFO *dbenvinfo;

	set_private_dbobj(jnienv, name_DB_ENV, jthis, 0);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (dbenvinfo != NULL)
		dbjie_dealloc(dbenvinfo, jnienv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_feedback_1changed
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis,
   /*DbEnvFeedback*/ jobject jfeedback)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv) ||
	    !verify_non_null(jnienv, dbenvinfo))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	dbjie_set_feedback_object(dbenvinfo, jnienv, dbenv, jfeedback);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1init
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jobject /*DbErrcall*/ jerrcall,
   jint flags)
{
	int err;
	DB_ENV *dbenv;

	err = db_env_create(&dbenv, flags);
	if (verify_return(jnienv, err, 0))
		DbEnv_initialize(jnienv, dbenv, jthis, jerrcall, 0);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1init_1using_1db
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jobject /*DbErrcall*/ jerrcall,
   /*Db*/ jobject jdb)
{
	DB_ENV *dbenv;
	DB *db;

	db = get_DB(jnienv, jdb);
	dbenv = db->dbenv;
	DbEnv_initialize(jnienv, dbenv, jthis, jerrcall, 1);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_open
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jstring db_home,
   jint flags, jint mode)
{
	int err;
	DB_ENV *dbenv;
	LOCKED_STRING ls_home;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv) ||
	    !verify_non_null(jnienv, dbenvinfo))
		return;
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	if (locked_string_get(&ls_home, jnienv, db_home) != 0)
		goto out;

	/* Java is assumed to be threaded. */
	flags |= DB_THREAD;

	err = dbenv->open(dbenv, ls_home.string, flags, mode);
	verify_return(jnienv, err, EXCEPTION_FILE_NOT_FOUND);
 out:
	locked_string_put(&ls_home, jnienv);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_remove
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jstring db_home, jint flags)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;
	LOCKED_STRING ls_home;
	int err = 0;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return;
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	if (locked_string_get(&ls_home, jnienv, db_home) != 0)
		goto out;

	err = dbenv->remove(dbenv, ls_home.string, flags);
	set_private_dbobj(jnienv, name_DB_ENV, jthis, 0);

	if (dbenvinfo != NULL)
		dbjie_dealloc(dbenvinfo, jnienv);

	verify_return(jnienv, err, 0);
 out:
	locked_string_put(&ls_home, jnienv);
	/* don't call JAVADB_ENV_API_END - env cannot be used */
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1close
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint flags)
{
	int err;
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = dbenv->close(dbenv, flags);
	set_private_dbobj(jnienv, name_DB_ENV, jthis, 0);

	if (dbenvinfo != NULL)
		dbjie_dealloc(dbenvinfo, jnienv);

	/* Throw an exception if the close failed. */
	verify_return(jnienv, err, 0);

	/* don't call JAVADB_ENV_API_END - env cannot be used */
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_err
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint ecode, jstring msg)
{
	LOCKED_STRING ls_msg;
	DB_ENV *dbenv;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	if (locked_string_get(&ls_msg, jnienv, msg) != 0)
		goto out;

	dbenv->err(dbenv, ecode, ls_msg.string);
 out:
	locked_string_put(&ls_msg, jnienv);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_errx
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jstring msg)
{
	LOCKED_STRING ls_msg;
	DB_ENV *dbenv;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	if (locked_string_get(&ls_msg, jnienv, msg) != 0)
		goto out;

	dbenv->errx(dbenv, ls_msg.string);
 out:
	locked_string_put(&ls_msg, jnienv);
	JAVADB_ENV_API_END(dbenv);
}

/*static*/
JNIEXPORT jstring JNICALL Java_com_sleepycat_db_DbEnv_strerror
  (JNIEnv *jnienv, jclass jthis_class, jint ecode)
{
	const char *message;

	COMPQUIET(jthis_class, NULL);
	message = db_strerror(ecode);
	return (get_java_string(jnienv, message));
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1cachesize
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint gbytes, jint bytes,
   jint ncaches)
{
	DB_ENV *dbenv;
	int err;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_cachesize(dbenv, gbytes, bytes, ncaches);
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1flags
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint flags, jboolean onoff)
{
	DB_ENV *dbenv;
	int err;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_flags(dbenv, flags, onoff ? 1 : 0);
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1mp_1mmapsize
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jlong value)
{
	DB_ENV *dbenv;
	int err;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_mp_mmapsize(dbenv, (size_t)value);
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

/*static*/
JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1pageyield
  (JNIEnv *jnienv, jclass jthis_class, jint value)
{
	int err;

	COMPQUIET(jthis_class, NULL);
	err = db_env_set_pageyield(value);
	verify_return(jnienv, err, 0);
}

/*static*/
JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1panicstate
  (JNIEnv *jnienv, jclass jthis_class, jint value)
{
	int err;

	COMPQUIET(jthis_class, NULL);
	err = db_env_set_panicstate(value);
	verify_return(jnienv, err, 0);
}

/*static*/
JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1region_1init
  (JNIEnv *jnienv, jclass jthis_class, jint value)
{
	int err;

	COMPQUIET(jthis_class, NULL);
	err = db_env_set_region_init(value);
	verify_return(jnienv, err, 0);
}

/*static*/
JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1tas_1spins
  (JNIEnv *jnienv, jclass jthis_class, jint value)
{
	int err;

	COMPQUIET(jthis_class, NULL);
	err = db_env_set_tas_spins(value);
	verify_return(jnienv, err, 0);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_recovery_1init_1changed
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbRecoveryInit*/ jobject jrecoveryinit)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv) ||
	    !verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	dbjie_set_recovery_init_object(dbenvinfo, jnienv, dbenv, jrecoveryinit);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_set_1lk_1conflicts
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jobjectArray array)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;
	int err;
	jsize i, len;
	unsigned char *newarr;
	int bytesize;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv) ||
	    !verify_non_null(jnienv, dbenvinfo))
		return;

	len = (*jnienv)->GetArrayLength(jnienv, array);
	bytesize = sizeof(unsigned char) * len * len;

	if ((err = __os_malloc(dbenv, bytesize, &newarr)) != 0) {
		if (!verify_return(jnienv, err, 0))
			return;
	}

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	for (i=0; i<len; i++) {
		jobject subArray =
			(*jnienv)->GetObjectArrayElement(jnienv, array, i);
		(*jnienv)->GetByteArrayRegion(jnienv, (jbyteArray)subArray,
					      0, len,
					      (jbyte *)&newarr[i*len]);
	}
	dbjie_set_conflict(dbenvinfo, newarr, bytesize);
	err = dbenv->set_lk_conflicts(dbenv, newarr, len);
	verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1rpc_1server
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbClient*/ jobject jclient,
   jstring jhost, jlong tsec, jlong ssec, jint flags)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	const char *host = (*jnienv)->GetStringUTFChars(jnienv, jhost, NULL);

	if (jclient != NULL) {
		report_exception(jnienv, "DbEnv.set_rpc_server client arg "
				 "must be null; reserved for future use",
				 EINVAL, 0);
		return;
	}
	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_rpc_server(dbenv, NULL, (char *)host,
					(long)tsec, (long)ssec, flags);

		/* Throw an exception if the call failed. */
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1shm_1key
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jlong shm_key)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);

	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_shm_key(dbenv, (long)shm_key);

		/* Throw an exception if the call failed. */
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv__1set_1tx_1timestamp
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jlong seconds)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	time_t time = seconds;

	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_tx_timestamp(dbenv, &time);

		/* Throw an exception if the call failed. */
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL
  Java_com_sleepycat_db_DbEnv_set_1verbose
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint which, jboolean onoff)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);

	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = dbenv->set_verbose(dbenv, which, onoff ? 1 : 0);

		/* Throw an exception if the call failed. */
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
}

/*static*/
JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_get_1version_1major
  (JNIEnv * jnienv, jclass this_class)
{
	COMPQUIET(jnienv, NULL);
	COMPQUIET(this_class, NULL);

	return (DB_VERSION_MAJOR);
}

/*static*/
JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_get_1version_1minor
  (JNIEnv * jnienv, jclass this_class)
{
	COMPQUIET(jnienv, NULL);
	COMPQUIET(this_class, NULL);

	return (DB_VERSION_MINOR);
}

/*static*/
JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_get_1version_1patch
  (JNIEnv * jnienv, jclass this_class)
{
	COMPQUIET(jnienv, NULL);
	COMPQUIET(this_class, NULL);

	return (DB_VERSION_PATCH);
}

/*static*/
JNIEXPORT jstring JNICALL Java_com_sleepycat_db_DbEnv_get_1version_1string
  (JNIEnv *jnienv, jclass this_class)
{
	COMPQUIET(this_class, NULL);

	return ((*jnienv)->NewStringUTF(jnienv, DB_VERSION_STRING));
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_lock_1id
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err;
	u_int32_t id;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);

	if (!verify_non_null(jnienv, dbenv))
		return (-1);
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	err = lock_id(dbenv, &id);
	verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
	return (id);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_DbEnv_lock_1stat
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	DB_LOCK_STAT *statp = NULL;
	jobject retval = NULL;
	jclass dbclass;

	if (!verify_non_null(jnienv, dbenv))
		return (NULL);
	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = lock_stat(dbenv, &statp);
	if (verify_return(jnienv, err, 0)) {
		retval = create_default_object(jnienv, name_DB_LOCK_STAT);
		dbclass = get_class(jnienv, name_DB_LOCK_STAT);

		/* Set the individual fields */
		set_int_field(jnienv, dbclass, retval,
			      "st_lastid", statp->st_lastid);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxlocks", statp->st_maxlocks);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxlockers", statp->st_maxlockers);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxobjects", statp->st_maxobjects);
		set_int_field(jnienv, dbclass, retval,
			      "st_nmodes", statp->st_nmodes);
		set_int_field(jnienv, dbclass, retval,
			      "st_nlocks", statp->st_nlocks);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxnlocks", statp->st_maxnlocks);
		set_int_field(jnienv, dbclass, retval,
			      "st_nlockers", statp->st_nlockers);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxnlockers", statp->st_maxnlockers);
		set_int_field(jnienv, dbclass, retval,
			      "st_nobjects", statp->st_nobjects);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxnobjects", statp->st_maxnobjects);
		set_int_field(jnienv, dbclass, retval,
			      "st_nconflicts", statp->st_nconflicts);
		set_int_field(jnienv, dbclass, retval,
			      "st_nrequests", statp->st_nrequests);
		set_int_field(jnienv, dbclass, retval,
			      "st_nreleases", statp->st_nreleases);
		set_int_field(jnienv, dbclass, retval,
			      "st_nnowaits", statp->st_nnowaits);
		set_int_field(jnienv, dbclass, retval,
			      "st_ndeadlocks", statp->st_ndeadlocks);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_wait", statp->st_region_wait);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_nowait", statp->st_region_nowait);
		set_int_field(jnienv, dbclass, retval,
			      "st_regsize", statp->st_regsize);

		__os_ufree(dbenv, statp, sizeof(DB_LOCK_STAT));
	}
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_lock_1detect
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint atype, jint flags)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	int aborted;

	if (!verify_non_null(jnienv, dbenv))
		return (0);
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	err = lock_detect(dbenv, atype, flags, &aborted);
	verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
	return (aborted);
}

JNIEXPORT /*DbLock*/ jobject JNICALL Java_com_sleepycat_db_DbEnv_lock_1get
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*u_int32_t*/ jint locker,
   jint flags, /*const Dbt*/ jobject obj, /*db_lockmode_t*/ jint lock_mode)
{
	int err;
	DB_ENV *dbenv;
	DB_LOCK *dblock;
	LOCKED_DBT lobj;
	/*DbLock*/ jobject retval;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	if ((err = __os_malloc(dbenv, sizeof(DB_LOCK), &dblock)) != 0)
		if (!verify_return(jnienv, err, 0))
			return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	memset(dblock, 0, sizeof(DB_LOCK));
	err = 0;
	retval = NULL;
	if (locked_dbt_get(&lobj, jnienv, obj, inOp) != 0)
		goto out;

	err = lock_get(dbenv, locker, flags, &lobj.javainfo->dbt,
		       (db_lockmode_t)lock_mode, dblock);
	if (verify_return(jnienv, err, 0)) {
		retval = create_default_object(jnienv, name_DB_LOCK);
		set_private_dbobj(jnienv, name_DB_LOCK, retval, dblock);
	}
 out:
	locked_dbt_put(&lobj, jnienv);
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jobjectArray JNICALL Java_com_sleepycat_db_DbEnv_log_1archive
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint flags)
{
	int err, len, i;
	char** ret;
	jclass stringClass;
	jobjectArray strarray;
	DB_ENV *dbenv;

	dbenv = get_DB_ENV(jnienv, jthis);
	strarray = NULL;
	if (!verify_non_null(jnienv, dbenv))
		return (0);
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	err = log_archive(dbenv, &ret, flags);
	if (!verify_return(jnienv, err, 0))
		return (0);

	if (ret != NULL) {
		len = 0;
		while (ret[len] != NULL)
			len++;
		stringClass = (*jnienv)->FindClass(jnienv, "java/lang/String");
		strarray = (*jnienv)->NewObjectArray(jnienv, len,
						     stringClass, 0);
		for (i=0; i<len; i++) {
			jstring str = (*jnienv)->NewStringUTF(jnienv, ret[i]);
			(*jnienv)->SetObjectArrayElement(jnienv, strarray,
							 i, str);
		}
	}
	JAVADB_ENV_API_END(dbenv);
	return (strarray);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_log_1compare
  (JNIEnv *jnienv, jclass jthis_class,
   /*DbLsn*/ jobject lsn0, /*DbLsn*/ jobject lsn1)
{
	DB_LSN *dblsn0;
	DB_LSN *dblsn1;

	COMPQUIET(jthis_class, NULL);
	dblsn0 = get_DB_LSN(jnienv, lsn0);
	dblsn1 = get_DB_LSN(jnienv, lsn1);

	return (log_compare(dblsn0, dblsn1));
}

JNIEXPORT jstring JNICALL Java_com_sleepycat_db_DbEnv_log_1file
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbLsn*/ jobject lsn)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	DB_LSN *dblsn = get_DB_LSN(jnienv, lsn);
	char filename[FILENAME_MAX+1] = "";

	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = log_file(dbenv, dblsn, filename, FILENAME_MAX);
	verify_return(jnienv, err, 0);
	filename[FILENAME_MAX] = '\0'; /* just to be sure */
	JAVADB_ENV_API_END(dbenv);
	return (get_java_string(jnienv, filename));
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_log_1flush
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbLsn*/ jobject lsn)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	DB_LSN *dblsn = get_DB_LSN(jnienv, lsn);

	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = log_flush(dbenv, dblsn);
	verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_log_1get
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbLsn*/ jobject lsn,
   /*DbDbt*/ jobject data, jint flags)
{
	int err, retry;
	DB_ENV *dbenv;
	DB_LSN *dblsn;
	LOCKED_DBT ldata;

	err = 0;
	dbenv = get_DB_ENV(jnienv, jthis);
	dblsn = get_DB_LSN(jnienv, lsn);

	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	if (locked_dbt_get(&ldata, jnienv, data, outOp) != 0)
		goto out;

	for (retry = 0; retry < 3; retry++) {
		err = log_get(dbenv, dblsn, &ldata.javainfo->dbt, flags);
		/* If we failed due to lack of memory in our DBT arrays,
		 * retry.
		 */
		if (err != ENOMEM)
			break;
		if (!locked_dbt_realloc(&ldata, jnienv))
			break;
	}

 out:
	locked_dbt_put(&ldata, jnienv);
	if (err != 0) {
		if (verify_dbt(jnienv, err, &ldata))
			verify_return(jnienv, err, 0);
	}

	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_log_1put
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbLsn*/ jobject lsn,
   /*DbDbt*/ jobject data, jint flags)
{
	int err;
	DB_ENV *dbenv;
	DB_LSN *dblsn;
	LOCKED_DBT ldata;

	dbenv = get_DB_ENV(jnienv, jthis);
	dblsn = get_DB_LSN(jnienv, lsn);
	if (!verify_non_null(jnienv, dbenv))
		return;

	/* log_put()'s DB_LSN argument may not be NULL. */
	if (!verify_non_null(jnienv, dblsn))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	if (locked_dbt_get(&ldata, jnienv, data, inOp) != 0)
		goto out;

	err = log_put(dbenv, dblsn, &ldata.javainfo->dbt, flags);
	verify_return(jnienv, err, 0);
 out:
	locked_dbt_put(&ldata, jnienv);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_log_1register
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*Db*/ jobject dbp,
   jstring name)
{
	int err;
	DB_ENV *dbenv;
	DB *dbdb;
	LOCKED_STRING ls_name;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbdb = get_DB(jnienv, dbp);
	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	if (locked_string_get(&ls_name, jnienv, name) != 0)
		goto out;

	err = log_register(dbenv, dbdb, ls_name.string);
	verify_return(jnienv, err, 0);
 out:
	locked_string_put(&ls_name, jnienv);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_log_1unregister
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*Db*/ jobject dbp)
{
	int err;
	DB_ENV *dbenv;
	DB *dbdb;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbdb = get_DB(jnienv, dbp);
	if (!verify_non_null(jnienv, dbenv))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = log_unregister(dbenv, dbdb);
	verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_DbEnv_log_1stat
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err;
	DB_ENV *dbenv;
	DB_LOG_STAT *statp;
	jobject retval;
	jclass dbclass;

	retval = NULL;
	statp = NULL;
	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = log_stat(dbenv, &statp);
	if (verify_return(jnienv, err, 0)) {
		retval = create_default_object(jnienv, name_DB_LOG_STAT);
		dbclass = get_class(jnienv, name_DB_LOG_STAT);

		/* Set the individual fields */
		set_int_field(jnienv, dbclass, retval,
			      "st_magic", statp->st_magic);
		set_int_field(jnienv, dbclass, retval,
			      "st_version", statp->st_version);
		set_int_field(jnienv, dbclass, retval,
			      "st_mode", statp->st_mode);
		set_int_field(jnienv, dbclass, retval,
			      "st_lg_bsize", statp->st_lg_bsize);
		set_int_field(jnienv, dbclass, retval,
			      "st_lg_max", statp->st_lg_max);
		set_int_field(jnienv, dbclass, retval,
			      "st_w_bytes", statp->st_w_bytes);
		set_int_field(jnienv, dbclass, retval,
			      "st_w_mbytes", statp->st_w_mbytes);
		set_int_field(jnienv, dbclass, retval,
			      "st_wc_bytes", statp->st_wc_bytes);
		set_int_field(jnienv, dbclass, retval,
			      "st_wc_mbytes", statp->st_wc_mbytes);
		set_int_field(jnienv, dbclass, retval,
			      "st_wcount", statp->st_wcount);
		set_int_field(jnienv, dbclass, retval,
			      "st_wcount_fill", statp->st_wcount_fill);
		set_int_field(jnienv, dbclass, retval,
			      "st_scount", statp->st_scount);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_wait", statp->st_region_wait);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_nowait", statp->st_region_nowait);
		set_int_field(jnienv, dbclass, retval,
			      "st_cur_file", statp->st_cur_file);
		set_int_field(jnienv, dbclass, retval,
			      "st_cur_offset", statp->st_cur_offset);
		set_int_field(jnienv, dbclass, retval,
			      "st_regsize", statp->st_regsize);

		__os_ufree(dbenv, statp, sizeof(DB_LOG_STAT));
	}
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_DbEnv_memp_1stat
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err;
	jclass dbclass;
	DB_ENV *dbenv;
	DB_MPOOL_STAT *statp;
	jobject retval;

	retval = NULL;
	statp = NULL;
	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = memp_stat(dbenv, &statp, 0);
	if (verify_return(jnienv, err, 0)) {
		retval = create_default_object(jnienv, name_DB_MPOOL_STAT);
		dbclass = get_class(jnienv, name_DB_MPOOL_STAT);

		set_int_field(jnienv, dbclass, retval, "st_cachesize", 0);
		set_int_field(jnienv, dbclass, retval,
			      "st_cache_hit", statp->st_cache_hit);
		set_int_field(jnienv, dbclass, retval,
			      "st_cache_miss", statp->st_cache_miss);
		set_int_field(jnienv, dbclass, retval,
			      "st_map", statp->st_map);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_create", statp->st_page_create);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_in", statp->st_page_in);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_out", statp->st_page_out);
		set_int_field(jnienv, dbclass, retval,
			      "st_ro_evict", statp->st_ro_evict);
		set_int_field(jnienv, dbclass, retval,
			      "st_rw_evict", statp->st_rw_evict);
		set_int_field(jnienv, dbclass, retval,
			      "st_hash_buckets", statp->st_hash_buckets);
		set_int_field(jnienv, dbclass, retval,
			      "st_hash_searches", statp->st_hash_searches);
		set_int_field(jnienv, dbclass, retval,
			      "st_hash_longest", statp->st_hash_longest);
		set_int_field(jnienv, dbclass, retval,
			      "st_hash_examined", statp->st_hash_examined);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_clean", statp->st_page_clean);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_dirty", statp->st_page_dirty);
		set_int_field(jnienv, dbclass, retval,
			      "st_page_trickle", statp->st_page_trickle);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_wait", statp->st_region_wait);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_nowait", statp->st_region_nowait);
		set_int_field(jnienv, dbclass, retval,
			      "st_regsize", statp->st_regsize);

		__os_ufree(dbenv, statp, sizeof(DB_MPOOL_STAT));
	}
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jobjectArray JNICALL Java_com_sleepycat_db_DbEnv_memp_1fstat
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err, i, len;
	jclass fstat_class;
	DB_ENV *dbenv;
	DB_MPOOL_FSTAT **fstatp;
	jobjectArray retval;
	jfieldID filename_id;
	jstring jfilename;

	fstatp = NULL;
	retval = NULL;
	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = memp_stat(dbenv, 0, &fstatp);
	if (verify_return(jnienv, err, 0)) {
		len = 0;
		while (fstatp[len] != NULL)
			len++;
		fstat_class = get_class(jnienv, name_DB_MPOOL_FSTAT);
		retval = (*jnienv)->NewObjectArray(jnienv, len,
						   fstat_class, 0);
		for (i=0; i<len; i++) {
			jobject obj = create_default_object(jnienv,
							    name_DB_MPOOL_FSTAT);
			(*jnienv)->SetObjectArrayElement(jnienv, retval,
							 i, obj);

			/* Set the string field. */
			filename_id =
				(*jnienv)->GetFieldID(jnienv, fstat_class,
						      "file_name",
						      string_signature);
			jfilename =
				get_java_string(jnienv, fstatp[i]->file_name);
			(*jnienv)->SetObjectField(jnienv, obj,
						  filename_id, jfilename);

			set_int_field(jnienv, fstat_class, obj,
				      "st_pagesize", fstatp[i]->st_pagesize);
			set_int_field(jnienv, fstat_class, obj,
				      "st_cache_hit", fstatp[i]->st_cache_hit);
			set_int_field(jnienv, fstat_class, obj,
				      "st_cache_miss", fstatp[i]->st_cache_miss);
			set_int_field(jnienv, fstat_class, obj,
				      "st_map", fstatp[i]->st_map);
			set_int_field(jnienv, fstat_class, obj,
				      "st_page_create", fstatp[i]->st_page_create);
			set_int_field(jnienv, fstat_class, obj,
				      "st_page_in", fstatp[i]->st_page_in);
			set_int_field(jnienv, fstat_class, obj,
				      "st_page_out", fstatp[i]->st_page_out);
			__os_ufree(dbenv, fstatp[i], sizeof(DB_MPOOL_FSTAT));
		}
		__os_ufree(dbenv, fstatp, sizeof(DB_MPOOL_FSTAT*) * (len+1));
	}
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_memp_1trickle
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint pct)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);
	int result = 0;

	if (verify_non_null(jnienv, dbenv)) {
		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		err = memp_trickle(dbenv, pct, &result);
		verify_return(jnienv, err, 0);
		JAVADB_ENV_API_END(dbenv);
	}
	return (result);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_DbEnv_txn_1begin
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbTxn*/ jobject pid, jint flags)
{
	int err;
	DB_TXN *dbpid, *result;
	DB_ENV *dbenv;

	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (0);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	dbpid = get_DB_TXN(jnienv, pid);
	result = 0;

	err = txn_begin(dbenv, dbpid, &result, flags);
	if (!verify_return(jnienv, err, 0))
		return (0);
	JAVADB_ENV_API_END(dbenv);
	return (get_DbTxn(jnienv, result));
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_DbEnv_txn_1checkpoint
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint kbyte, jint min, jint flags)
{
	int err;
	DB_ENV *dbenv = get_DB_ENV(jnienv, jthis);

	if (!verify_non_null(jnienv, dbenv))
		return (0);
	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	err = txn_checkpoint(dbenv, kbyte, min, flags);
	if (err != DB_INCOMPLETE)
		verify_return(jnienv, err, 0);
	JAVADB_ENV_API_END(dbenv);
	return (err);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv_tx_1recover_1changed
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, /*DbFeedback*/ jobject jtxrecover)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv) ||
	    !verify_non_null(jnienv, dbenvinfo))
		return;

	JAVADB_ENV_API_BEGIN(dbenv, jthis);
	dbjie_set_tx_recover_object(dbenvinfo, jnienv, dbenv, jtxrecover);
	JAVADB_ENV_API_END(dbenv);
}

JNIEXPORT jobjectArray JNICALL Java_com_sleepycat_db_DbEnv_txn_1recover
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jint count, jint flags)
{
	int err;
	DB_ENV *dbenv;
	DB_PREPLIST *preps;
	long retcount;
	int i;
	char signature[128];
	size_t bytesize;
	jobject retval;
	jobject obj;
	jobject txnobj;
	jbyteArray bytearr;
	jclass preplist_class;
	jfieldID txn_fieldid;
	jfieldID gid_fieldid;

	retval = NULL;
	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	/*
	 * We need to allocate some local storage for the
	 * returned preplist, and that requires us to do
	 * our own argument validation.
	 */
	if (count <= 0) {
		verify_return(jnienv, EINVAL, 0);
		goto out;
	}

	bytesize = sizeof(DB_PREPLIST) * count;
	if ((err = __os_malloc(dbenv, bytesize, &preps)) != 0) {
		verify_return(jnienv, err, 0);
		goto out;
	}

	err = txn_recover(dbenv, preps, count, &retcount, flags);

	if (verify_return(jnienv, err, 0)) {
		preplist_class = get_class(jnienv, name_DB_PREPLIST);
		retval = (*jnienv)->NewObjectArray(jnienv, retcount,
						   preplist_class, 0);

		(void)snprintf(signature, sizeof(signature),
		    "L%s%s;", DB_PACKAGE_NAME, name_DB_TXN);
		txn_fieldid = (*jnienv)->GetFieldID(jnienv, preplist_class,
						    "txn", signature);
		gid_fieldid = (*jnienv)->GetFieldID(jnienv, preplist_class,
						    "gid", "[B");

		for (i=0; i<retcount; i++) {
			/* First, make a blank DbPreplist object
			 * and set the array entry.
			 */
			obj = create_default_object(jnienv, name_DB_PREPLIST);
			(*jnienv)->SetObjectArrayElement(jnienv, retval,
							 i, obj);

			/* Set the txn field. */
			txnobj = get_DbTxn(jnienv, preps[i].txn);
			(*jnienv)->SetObjectField(jnienv, obj,
						  txn_fieldid, txnobj);

			/* Build the gid array and set the field. */
			bytearr = (*jnienv)->NewByteArray(jnienv,
							  sizeof(preps[i].gid));
			(*jnienv)->SetByteArrayRegion(jnienv, bytearr, 0,
						      sizeof(preps[i].gid),
						      &preps[i].gid[0]);
			(*jnienv)->SetObjectField(jnienv, obj,
						  gid_fieldid,
						  bytearr);
		}
	}
	__os_free(dbenv, preps, bytesize);

 out:
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_DbEnv_txn_1stat
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis)
{
	int err;
	DB_ENV *dbenv;
	DB_TXN_STAT *statp;
	jobject retval, obj;
	jclass dbclass, active_class;
	char active_signature[512];
	jfieldID arrid;
	jobjectArray actives;
	unsigned int i;

	retval = NULL;
	statp = NULL;
	dbenv = get_DB_ENV(jnienv, jthis);
	if (!verify_non_null(jnienv, dbenv))
		return (NULL);

	JAVADB_ENV_API_BEGIN(dbenv, jthis);

	err = txn_stat(dbenv, &statp);
	if (verify_return(jnienv, err, 0)) {
		retval = create_default_object(jnienv, name_DB_TXN_STAT);
		dbclass = get_class(jnienv, name_DB_TXN_STAT);

		/* Set the individual fields */

		set_lsn_field(jnienv, dbclass, retval,
			      "st_last_ckp", statp->st_last_ckp);
		set_lsn_field(jnienv, dbclass, retval,
			      "st_pending_ckp", statp->st_pending_ckp);
		set_long_field(jnienv, dbclass, retval,
			       "st_time_ckp", statp->st_time_ckp);
		set_int_field(jnienv, dbclass, retval,
			      "st_last_txnid", statp->st_last_txnid);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxtxns", statp->st_maxtxns);
		set_int_field(jnienv, dbclass, retval,
			      "st_naborts", statp->st_naborts);
		set_int_field(jnienv, dbclass, retval,
			      "st_nbegins", statp->st_nbegins);
		set_int_field(jnienv, dbclass, retval,
			      "st_ncommits", statp->st_ncommits);
		set_int_field(jnienv, dbclass, retval,
			      "st_nactive", statp->st_nactive);
		set_int_field(jnienv, dbclass, retval,
			      "st_nrestores", statp->st_nrestores);
		set_int_field(jnienv, dbclass, retval,
			      "st_maxnactive", statp->st_maxnactive);

		active_class = get_class(jnienv, name_DB_TXN_STAT_ACTIVE);
		actives = (*jnienv)->NewObjectArray(jnienv, statp->st_nactive,
						  active_class, 0);

		/* Set the st_txnarray field.  This is a little more involved
		 * than other fields, since the type is an array, so none
		 * of our utility functions help.
		 */
		(void)snprintf(active_signature, sizeof(active_signature),
		    "[L%s%s;", DB_PACKAGE_NAME, name_DB_TXN_STAT_ACTIVE);

		arrid = (*jnienv)->GetFieldID(jnienv, dbclass, "st_txnarray",
					      active_signature);
		(*jnienv)->SetObjectField(jnienv, retval, arrid, actives);

		/* Now fill the in the elements of st_txnarray. */
		for (i=0; i<statp->st_nactive; i++) {
			obj = create_default_object(jnienv,
						name_DB_TXN_STAT_ACTIVE);
			(*jnienv)->SetObjectArrayElement(jnienv,
						actives, i, obj);

			set_int_field(jnienv, active_class, obj,
				      "txnid", statp->st_txnarray[i].txnid);
			set_int_field(jnienv, active_class, obj, "parentid",
				      statp->st_txnarray[i].parentid);
			set_lsn_field(jnienv, active_class, obj,
				      "lsn", statp->st_txnarray[i].lsn);
		}
		set_int_field(jnienv, dbclass, retval,
			      "st_region_wait", statp->st_region_wait);
		set_int_field(jnienv, dbclass, retval,
			      "st_region_nowait", statp->st_region_nowait);
		set_int_field(jnienv, dbclass, retval,
			      "st_regsize", statp->st_regsize);

		__os_ufree(dbenv, statp, sizeof(DB_TXN_STAT));
	}
	JAVADB_ENV_API_END(dbenv);
	return (retval);
}

/* See discussion on errpfx, errcall in DB_ENV_JAVAINFO */
JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1set_1errcall
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jobject errcall)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);

	if (verify_non_null(jnienv, dbenv) &&
	    verify_non_null(jnienv, dbenvinfo)) {

		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		dbjie_set_errcall(dbenvinfo, jnienv, errcall);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1set_1errpfx
  (JNIEnv *jnienv, /*DbEnv*/ jobject jthis, jstring str)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *dbenvinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	dbenvinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);

	if (verify_non_null(jnienv, dbenv) &&
	    verify_non_null(jnienv, dbenvinfo)) {

		JAVADB_ENV_API_BEGIN(dbenv, jthis);
		dbjie_set_errpfx(dbenvinfo, jnienv, str);
		JAVADB_ENV_API_END(dbenv);
	}
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbEnv__1finalize
    (JNIEnv *jnienv, /*DbEnv*/ jobject jthis,
     jobject /*DbErrcall*/ errcall, jstring errpfx)
{
	DB_ENV *dbenv;
	DB_ENV_JAVAINFO *envinfo;

	dbenv = get_DB_ENV(jnienv, jthis);
	envinfo = get_DB_ENV_JAVAINFO(jnienv, jthis);
	DB_ASSERT(envinfo != NULL);

	/* Note:  We detect unclosed DbEnvs and report it.
	 */
	if (dbenv != NULL && envinfo != NULL && !dbjie_is_dbopen(envinfo)) {

		/* If this error occurs, this object was never closed. */
		report_errcall(jnienv, errcall, errpfx,
			       "DbEnv.finalize: open DbEnv object destroyed");
	}

	/* Shouldn't see this object again, but just in case */
	set_private_dbobj(jnienv, name_DB_ENV, jthis, 0);
	set_private_info(jnienv, name_DB_ENV, jthis, 0);

	dbjie_destroy(envinfo, jnienv);
}
