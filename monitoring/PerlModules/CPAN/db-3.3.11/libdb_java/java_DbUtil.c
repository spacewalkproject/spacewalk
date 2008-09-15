/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2001
 *	Sleepycat Software.  All rights reserved.
 */
#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: java_DbUtil.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#include <jni.h>

#include "db_int.h"
#include "java_util.h"
#include "com_sleepycat_db_DbUtil.h"

JNIEXPORT jboolean JNICALL
Java_com_sleepycat_db_DbUtil_am_1big_1endian (JNIEnv *jnienv,
    jclass jthis_class)
{
	COMPQUIET(jnienv, NULL);
	COMPQUIET(jthis_class, NULL);

#if defined(WORDS_BIGENDIAN)
	return (JNI_TRUE);
#else
	return (JNI_FALSE);
#endif
}
