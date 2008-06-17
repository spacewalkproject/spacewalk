/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: java_Dbt.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#include <jni.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "db_int.h"
#include "java_util.h"
#include "com_sleepycat_db_Dbt.h"

JNIEXPORT void JNICALL Java_com_sleepycat_db_Dbt_init
  (JNIEnv *jnienv, jobject jthis)
{
	DBT_JAVAINFO *dbtji;

	dbtji = dbjit_construct();
	set_private_dbobj(jnienv, name_DBT, jthis, dbtji);
}

JNIEXPORT jbyteArray JNICALL Java_com_sleepycat_db_Dbt_create_1data
  (JNIEnv *jnienv, jobject jthis)
{
	DBT_JAVAINFO *db_this;
	jbyteArray arr;
	int len;

	db_this = get_DBT_JAVAINFO(jnienv, jthis);
	if (verify_non_null(jnienv, db_this)) {
		len = db_this->dbt.size;
		arr = (*jnienv)->NewByteArray(jnienv, len);
		(*jnienv)->SetByteArrayRegion(jnienv, arr, 0, len,
					      db_this->dbt.data);
		return (arr);
	}
	return (0);
}

JNIEXPORT jboolean JNICALL Java_com_sleepycat_db_Dbt_is_1big_1endian
  (JNIEnv *jnienv, jclass jthis_class)
{
	u_int32_t one;
	u_int8_t *pbyte;

	COMPQUIET(jthis_class, NULL);
	COMPQUIET(jnienv, NULL);

	one = 1;
	pbyte = (u_int8_t *)&one;
	return (*pbyte == 1 ? 0 : 1);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_Dbt_finalize
  (JNIEnv *jnienv, jobject jthis)
{
	DBT_JAVAINFO *dbtji;

	dbtji = get_DBT_JAVAINFO(jnienv, jthis);
	if (dbtji) {
		/* Free any data related to DBT here */
		dbjit_destroy(dbtji);
	}
}
