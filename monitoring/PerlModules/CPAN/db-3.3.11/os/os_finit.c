/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1998-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: os_finit.c,v 1.1.1.1 2002-01-11 00:21:37 apingel Exp $";
#endif /* not lint */

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <string.h>
#endif

#include "db_int.h"

/*
 * __os_finit --
 *	Initialize a regular file, optionally zero-filling it as well.
 *
 * PUBLIC: int __os_finit __P((DB_ENV *, DB_FH *, size_t, int));
 */
int
__os_finit(dbenv, fhp, size, zerofill)
	DB_ENV *dbenv;
	DB_FH *fhp;
	size_t size;
	int zerofill;
{
	db_pgno_t pages;
	size_t i;
	size_t nw;
	u_int32_t relative;
	int ret;
	char buf[OS_VMPAGESIZE];

	/* Write nuls to the new bytes. */
	memset(buf, 0, sizeof(buf));

	/*
	 * Extend the region by writing the last page.  If the region is >4Gb,
	 * increment may be larger than the maximum possible seek "relative"
	 * argument, as it's an unsigned 32-bit value.  Break the offset into
	 * pages of 1MB each so that we don't overflow (2^20 + 2^32 is bigger
	 * than any memory I expect to see for awhile).
	 */
	if ((ret = __os_seek(dbenv, fhp, 0, 0, 0, 0, DB_OS_SEEK_END)) != 0)
		return (ret);
	pages = (size - OS_VMPAGESIZE) / MEGABYTE;
	relative = (size - OS_VMPAGESIZE) % MEGABYTE;
	if ((ret = __os_seek(dbenv,
	    fhp, MEGABYTE, pages, relative, 0, DB_OS_SEEK_CUR)) != 0)
		return (ret);
	if ((ret = __os_write(dbenv, fhp, buf, sizeof(buf), &nw)) != 0)
		return (ret);
	if (nw != sizeof(buf))
		return (EIO);

	/*
	 * We may want to guarantee that there is enough disk space for the
	 * file, so we also write a byte to each page.  We write the byte
	 * because reading it is insufficient on systems smart enough not to
	 * instantiate disk pages to satisfy a read (e.g., Solaris).
	 */
	if (zerofill) {
		pages = size / MEGABYTE;
		relative = size % MEGABYTE;
		if ((ret = __os_seek(dbenv, fhp,
		    MEGABYTE, pages, relative, 1, DB_OS_SEEK_END)) != 0)
			return (ret);

		/* Write a byte to each page. */
		for (i = 0; i < size; i += OS_VMPAGESIZE) {
			if ((ret = __os_write(dbenv, fhp, buf, 1, &nw)) != 0)
				return (ret);
			if (nw != 1)
				return (EIO);
			if ((ret = __os_seek(dbenv, fhp,
			    0, 0, OS_VMPAGESIZE - 1, 0, DB_OS_SEEK_CUR)) != 0)
				return (ret);
		}
	}
	return (0);
}

/*
 * __os_fs_notzero --
 *	Return 1 if allocated filesystem blocks are not zeroed.
 *
 * PUBLIC: int __os_fs_notzero __P((void));
 */
int
__os_fs_notzero()
{
	/* Most filesystems zero out implicitly created pages. */
	return (0);
}
