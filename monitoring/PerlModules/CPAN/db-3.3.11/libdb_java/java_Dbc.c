/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: java_Dbc.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#include <jni.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#ifdef DIAGNOSTIC
#include <stdio.h>
#endif

#include "db_int.h"
#include "java_util.h"
#include "com_sleepycat_db_Dbc.h"

JNIEXPORT void JNICALL Java_com_sleepycat_db_Dbc_close
  (JNIEnv *jnienv, jobject jthis)
{
	int err;
	DBC *dbc = get_DBC(jnienv, jthis);

	if (!verify_non_null(jnienv, dbc))
		return;
	err = dbc->c_close(dbc);
	if (verify_return(jnienv, err, 0)) {
		set_private_dbobj(jnienv, name_DBC, jthis, 0);
	}
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_Dbc_count
  (JNIEnv *jnienv, jobject jthis, jint flags)
{
	int err;
	DBC *dbc = get_DBC(jnienv, jthis);
	db_recno_t count;

	if (!verify_non_null(jnienv, dbc))
		return (0);
	err = dbc->c_count(dbc, &count, flags);
	verify_return(jnienv, err, 0);
	return (count);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_Dbc_del
  (JNIEnv *jnienv, jobject jthis, jint flags)
{
	int err;
	DBC *dbc = get_DBC(jnienv, jthis);

	if (!verify_non_null(jnienv, dbc))
		return (0);
	err = dbc->c_del(dbc, flags);
	if (err != DB_KEYEMPTY) {
		verify_return(jnienv, err, 0);
	}
	return (err);
}

JNIEXPORT jobject JNICALL Java_com_sleepycat_db_Dbc_dup
  (JNIEnv *jnienv, jobject jthis, jint flags)
{
	int err;
	DBC *dbc = get_DBC(jnienv, jthis);
	DBC *dbc_ret = NULL;

	if (!verify_non_null(jnienv, dbc))
		return (0);
	err = dbc->c_dup(dbc, &dbc_ret, flags);
	if (!verify_return(jnienv, err, 0))
		return (0);

	return (get_Dbc(jnienv, dbc_ret));
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_Dbc_get
  (JNIEnv *jnienv, jobject jthis,
   /*Dbt*/ jobject key, /*Dbt*/ jobject data, jint flags)
{
	int err, retry, op_flags;
	DBC *dbc;
	LOCKED_DBT lkey, ldata;
	OpKind keyop, dataop;

	/* Depending on flags, the user may be supplying the key,
	 * or else we may have to retrieve it.
	 */
	err = 0;
	keyop = outOp;
	dataop = outOp;

	op_flags = flags & DB_OPFLAGS_MASK;
	if (op_flags == DB_SET) {
		keyop = inOp;
	}
	else if (op_flags == DB_SET_RANGE ||
		 op_flags == DB_SET_RECNO) {
		keyop = inOutOp;
	}
	else if (op_flags == DB_GET_BOTH) {
		keyop = inOutOp;
		dataop = inOutOp;
	}

	dbc = get_DBC(jnienv, jthis);
	if (locked_dbt_get(&lkey, jnienv, key, keyop) != 0)
		goto out2;
	if (locked_dbt_get(&ldata, jnienv, data, dataop) != 0)
		goto out1;

	if (!verify_non_null(jnienv, dbc))
		goto out1;

	for (retry = 0; retry < 3; retry++) {
		err = dbc->c_get(dbc, &lkey.javainfo->dbt, &ldata.javainfo->dbt, flags);

		/* If we failed due to lack of memory in our DBT arrays,
		 * retry.
		 */
		if (err != ENOMEM)
			break;
		if (!locked_dbt_realloc(&lkey, jnienv) && !locked_dbt_realloc(&ldata, jnienv))
			break;
	}
 out1:
	locked_dbt_put(&ldata, jnienv);
 out2:
	locked_dbt_put(&lkey, jnienv);
	if (err != 0 && err != DB_NOTFOUND) {
		if (verify_dbt(jnienv, err, &lkey) &&
		    verify_dbt(jnienv, err, &ldata))
			verify_return(jnienv, err, 0);
	}
	return (err);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_Dbc_pget
  (JNIEnv *jnienv, jobject jthis,
   /*Dbt*/ jobject key, /*Dbt*/ jobject pkey, /*Dbt*/ jobject data, jint flags)
{
	int err, retry, op_flags;
	DBC *dbc;
	LOCKED_DBT lkey, lpkey, ldata;
	OpKind keyop, pkeyop, dataop;

	/* Depending on flags, the user may be supplying the key,
	 * or else we may have to retrieve it.
	 */
	err = 0;
	keyop = outOp;
	pkeyop = outOp;
	dataop = outOp;

	op_flags = flags & DB_OPFLAGS_MASK;
	if (op_flags == DB_SET) {
		keyop = inOp;
	}
	else if (op_flags == DB_SET_RANGE ||
		 op_flags == DB_SET_RECNO) {
		keyop = inOutOp;
	}
	else if (op_flags == DB_GET_BOTH) {
		pkeyop = inOutOp;
		keyop = inOutOp;
		dataop = inOutOp;
	}

	dbc = get_DBC(jnienv, jthis);
	if (locked_dbt_get(&lkey, jnienv, key, keyop) != 0)
		goto out3;
	if (locked_dbt_get(&lpkey, jnienv, pkey, pkeyop) != 0)
		goto out2;
	if (locked_dbt_get(&ldata, jnienv, data, dataop) != 0)
		goto out1;

	if (!verify_non_null(jnienv, dbc))
		goto out1;

	for (retry = 0; retry < 3; retry++) {
		err = dbc->c_pget(dbc, &lkey.javainfo->dbt, &lpkey.javainfo->dbt,
				  &ldata.javainfo->dbt, flags);

		/* If we failed due to lack of memory in our DBT arrays,
		 * retry.
		 */
		if (err != ENOMEM)
			break;
		if (!locked_dbt_realloc(&lkey, jnienv) &&
		    !locked_dbt_realloc(&lpkey, jnienv) &&
		    !locked_dbt_realloc(&ldata, jnienv))
			break;
	}
 out1:
	locked_dbt_put(&ldata, jnienv);
 out2:
	locked_dbt_put(&lpkey, jnienv);
 out3:
	locked_dbt_put(&lkey, jnienv);
	if (err != 0 && err != DB_NOTFOUND) {
		if (verify_dbt(jnienv, err, &lkey) &&
		    verify_dbt(jnienv, err, &lpkey) &&
		    verify_dbt(jnienv, err, &ldata))
			verify_return(jnienv, err, 0);
	}
	return (err);
}

JNIEXPORT jint JNICALL Java_com_sleepycat_db_Dbc_put
  (JNIEnv *jnienv, jobject jthis,
   /*Dbt*/ jobject key, /*Dbt*/ jobject data, jint flags)
{
	int err;
	DBC *dbc;
	LOCKED_DBT lkey, ldata;

	err = 0;
	dbc = get_DBC(jnienv, jthis);
	if (locked_dbt_get(&lkey, jnienv, key, inOp) != 0)
		goto out2;
	if (locked_dbt_get(&ldata, jnienv, data, inOp) != 0)
		goto out1;

	if (!verify_non_null(jnienv, dbc))
		goto out1;
	err = dbc->c_put(dbc, &lkey.javainfo->dbt, &ldata.javainfo->dbt, flags);
	if (err != DB_KEYEXIST) {
		verify_return(jnienv, err, 0);
	}
 out1:
	locked_dbt_put(&ldata, jnienv);
 out2:
	locked_dbt_put(&lkey, jnienv);
	return (err);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_Dbc_finalize
  (JNIEnv *jnienv, jobject jthis)
{
	/* Free any data related to DBC here.
	 * If we ever have java-only data embedded in the DBC
	 * and need to do this, we'll have to track Dbc's
	 * according to which Db owns them, just as
	 * we track Db's according to which DbEnv owns them.
	 * That's necessary to avoid double freeing that
	 * comes about when closes interact with GC.
	 */

#ifdef DIAGNOSTIC
	DBC *dbc;

	dbc = get_DBC(jnienv, jthis);
	if (dbc != NULL)
		fprintf(stderr, "Java API: Dbc has not been closed\n");
#else

	COMPQUIET(jnienv, NULL);
	COMPQUIET(jthis, NULL);

#endif
}
