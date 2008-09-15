/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 *
 * $Id: cxx_except.h,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */

#ifndef _CXX_EXCEPT_H_
#define	_CXX_EXCEPT_H_

#include "cxx_common.h"

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//
// Forward declarations
//

class DbException;                               // forward
class DbMemoryException;                         // forward
class Dbt;                                       // forward

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//
// Exception classes
//

// Almost any error in the DB library throws a DbException.
// Every exception should be considered an abnormality
// (e.g. bug, misuse of DB, file system error).
//
// NOTE: We would like to inherit from class exception and
//       let it handle what(), but there are
//       MSVC++ problems when <exception> is included.
//
class _exported DbException
{
public:
	virtual ~DbException();
	DbException(int err);
	DbException(const char *description);
	DbException(const char *prefix, int err);
	DbException(const char *prefix1, const char *prefix2, int err);
	int get_errno() const;
	virtual const char *what() const;

	DbException(const DbException &);
	DbException &operator = (const DbException &);

private:
	char *what_;
	int err_;                   // errno
};

//
// A specific sort of exception that occurs when
// user declared memory is insufficient in a Dbt.
//
class _exported DbMemoryException : public DbException
{
public:
	virtual ~DbMemoryException();
	DbMemoryException(Dbt *dbt);
	DbMemoryException(const char *description);
	DbMemoryException(const char *prefix, Dbt *dbt);
	DbMemoryException(const char *prefix1, const char *prefix2, Dbt *dbt);
	Dbt *get_dbt() const;

	DbMemoryException(const DbMemoryException &);
	DbMemoryException &operator = (const DbMemoryException &);

private:
	Dbt *dbt_;
};
#endif /* !_CXX_EXCEPT_H_ */
