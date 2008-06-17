/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1999-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: os_root.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <unistd.h>
#endif

#include "db_int.h"

/*
 * __os_isroot --
 *	Return if user has special permissions.
 *
 * PUBLIC: int __os_isroot __P((void));
 */
int
__os_isroot()
{
#ifdef HAVE_GETUID
	return (getuid() == 0);
#else
	return (0);
#endif
}
