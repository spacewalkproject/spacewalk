/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: java_DbLsn.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#include <jni.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>              /* needed for FILENAME_MAX */

#include "db_int.h"
#include "java_util.h"
#include "com_sleepycat_db_DbLsn.h"

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbLsn_init_1lsn
  (JNIEnv *jnienv, /*DbLsn*/ jobject jthis)
{
	/* Note: the DB_LSN object stored in the private_dbobj_
	 * is allocated in get_DbLsn() or get_DB_LSN().
	 */

	COMPQUIET(jnienv, NULL);
	COMPQUIET(jthis, NULL);
}

JNIEXPORT void JNICALL Java_com_sleepycat_db_DbLsn_finalize
  (JNIEnv *jnienv, jobject jthis)
{
	DB_LSN *dblsn;

	dblsn = get_DB_LSN(jnienv, jthis);
	if (dblsn) {
		(void)__os_free(NULL, dblsn, sizeof(DB_LSN));
	}
}
