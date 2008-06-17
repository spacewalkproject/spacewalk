/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *	Sleepycat Software.  All rights reserved.
 */

#include "db_config.h"

#ifndef lint
static const char revid[] = "$Id: cxx_table.cpp,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $";
#endif /* not lint */

#include <errno.h>
#include <string.h>

#include "db_cxx.h"
#include "cxx_int.h"

#include "db_int.h"
#include "db_page.h"
#include "db_auto.h"
#include "crdel_auto.h"
#include "db_ext.h"
#include "common_ext.h"

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            Db                                      //
//                                                                    //
////////////////////////////////////////////////////////////////////////

// A truism for the DbEnv object is that there is a valid
// DB_ENV handle from the constructor until close().
// After the close, the DB handle is invalid and
// no operations are permitted on the Db (other than
// destructor).  Leaving the Db handle open and not
// doing a close is generally considered an error.
//
// We used to allow Db objects to be closed and reopened.
// This implied always keeping a valid DB object, and
// coordinating the open objects between Db/DbEnv turned
// out to be overly complicated.  Now we do not allow this.

Db::Db(DbEnv *env, u_int32_t flags)
:	imp_(0)
,	env_(env)
,	construct_error_(0)
,	flags_(0)
,	construct_flags_(flags)
{
	if (env_ == 0)
		flags_ |= DB_CXX_PRIVATE_ENV;
	initialize();
}

// Note: if the user has not closed, we call _destroy_check
// to warn against this non-safe programming practice.
// We can't close, because the environment may already
// be closed/destroyed.
//
Db::~Db()
{
	DB *db;

	db = unwrap(this);
	if (db != NULL) {
		DbEnv::_destroy_check("Db", 0);
		cleanup();
	}
}

// private method to initialize during constructor.
// initialize must create a backing DB object,
// and if that creates a new DB_ENV, it must be tied to a new DbEnv.
// If there is an error, construct_error_ is set; this is examined
// during open.
//
int Db::initialize()
{
	u_int32_t cxx_flags;
	DB *db;
	int err;
	DB_ENV *cenv = unwrap(env_);

	cxx_flags = construct_flags_ & DB_CXX_NO_EXCEPTIONS;

	// Create a new underlying DB object.
	// We rely on the fact that if a NULL DB_ENV* is given,
	// one is allocated by DB.
	//
	if ((err = db_create(&db, cenv,
			     construct_flags_ & ~cxx_flags)) != 0) {
		construct_error_ = err;
		return (err);
	}

	// Associate the DB with this object
	imp_ = wrap(db);
	db->cj_internal = this;

	// Create a new DbEnv from a DB_ENV* if it was created locally.
	// It is deleted in Db::close().
	//
	if ((flags_ & DB_CXX_PRIVATE_ENV) != 0)
		env_ = new DbEnv(db->dbenv, cxx_flags);

	return (0);
}

// private method to cleanup after destructor or during close.
// If the environment was created by this Db object, we optionally
// delete it, or return it so the caller can delete it after
// last use.
//
void Db::cleanup()
{
	DB *db = unwrap(this);

	if (db != NULL) {
		// extra safety
		db->cj_internal = 0;
		imp_ = 0;

		// we must dispose of the DbEnv object if
		// we created it.  This will be the case
		// if a NULL DbEnv was passed into the constructor.
		// The underlying DB_ENV object will be inaccessible
		// after the close, so we must clean it up now.
		//
		if ((flags_ & DB_CXX_PRIVATE_ENV) != 0) {
			env_->cleanup();
			delete env_;
			env_ = 0;
		}
	}
	construct_error_ = 0;
}

// Return a tristate value corresponding to whether we should
// throw exceptions on errors:
//   ON_ERROR_RETURN
//   ON_ERROR_THROW
//   ON_ERROR_UNKNOWN
//
int Db::error_policy()
{
	if (env_ != NULL)
		return (env_->error_policy());
	else {
		// If the env_ is null, that means that the user
		// did not attach an environment, so the correct error
		// policy can be deduced from constructor flags
		// for this Db.
		//
		if ((construct_flags_ & DB_CXX_NO_EXCEPTIONS) != 0) {
			return (ON_ERROR_RETURN);
		}
		else {
			return (ON_ERROR_THROW);
		}
	}
}

int Db::close(u_int32_t flags)
{
	DB *db = unwrap(this);
	int err;

	// after a DB->close (no matter if success or failure),
	// the underlying DB object must not be accessed,
	// so we clean up in advance.
	//
	cleanup();

	// It's safe to throw an error after the close,
	// since our error mechanism does not peer into
	// the DB* structures.
	//
	if ((err = db->close(db, flags)) != 0 && err != DB_INCOMPLETE)
		DB_ERROR("Db::close", err, error_policy());

	return (err);
}

int Db::cursor(DbTxn *txnid, Dbc **cursorp, u_int32_t flags)
{
	DB *db = unwrap(this);
	DBC *dbc = 0;
	int err;

	if ((err = db->cursor(db, unwrap(txnid), &dbc, flags)) != 0) {
		DB_ERROR("Db::cursor", err, error_policy());
		return (err);
	}

	// The following cast implies that Dbc can be no larger than DBC
	*cursorp = (Dbc*)dbc;
	return (0);
}

int Db::del(DbTxn *txnid, Dbt *key, u_int32_t flags)
{
	DB *db = unwrap(this);
	int err;

	if ((err = db->del(db, unwrap(txnid), key, flags)) != 0) {
		// DB_NOTFOUND is a "normal" return, so should not be
		// thrown as an error
		//
		if (err != DB_NOTFOUND) {
			DB_ERROR("Db::del", err, error_policy());
			return (err);
		}
	}
	return (err);
}

void Db::err(int error, const char *format, ...)
{
	va_list args;
	DB *db = unwrap(this);

	va_start(args, format);
	__db_real_err(db->dbenv, error, 1, 1, format, args);
	va_end(args);
}

void Db::errx(const char *format, ...)
{
	va_list args;
	DB *db = unwrap(this);

	va_start(args, format);
	__db_real_err(db->dbenv, 0, 0, 1, format, args);
	va_end(args);
}

int Db::fd(int *fdp)
{
	DB *db = unwrap(this);
	int err;

	if ((err = db->fd(db, fdp)) != 0) {
		DB_ERROR("Db::fd", err, error_policy());
		return (err);
	}
	return (0);
}

int Db::get(DbTxn *txnid, Dbt *key, Dbt *value, u_int32_t flags)
{
	DB *db = unwrap(this);
	int err;

	if ((err = db->get(db, unwrap(txnid), key, value, flags)) != 0) {
		// DB_NOTFOUND and DB_KEYEMPTY are "normal" returns,
		// so should not be thrown as an error
		//
		if (err != DB_NOTFOUND && err != DB_KEYEMPTY) {
			const char *name = "Db::get";
			if (err == ENOMEM && DB_OVERFLOWED_DBT(value))
				DB_ERROR_DBT(name, value, error_policy());
			else
				DB_ERROR(name, err, error_policy());
			return (err);
		}
	}
	return (err);
}

int Db::get_byteswapped(int *isswapped)
{
	DB *db = (DB *)unwrapConst(this);
	return (db->get_byteswapped(db, isswapped));
}

int Db::get_type(DBTYPE *dbtype)
{
	DB *db = (DB *)unwrapConst(this);
	return (db->get_type(db, dbtype));
}

int Db::join(Dbc **curslist, Dbc **cursorp, u_int32_t flags)
{
	// Dbc is a "compatible" subclass of DBC -
	// that is, no virtual functions or even extra data members,
	// so this cast, although technically non-portable,
	// "should" always be okay.
	//
	DBC **list = (DBC **)(curslist);
	DB *db = unwrap(this);
	DBC *dbc = 0;
	int err;

	if ((err = db->join(db, list, &dbc, flags)) != 0) {
		DB_ERROR("Db::join_cursor", err, error_policy());
		return (err);
	}
	*cursorp = (Dbc*)dbc;
	return (0);
}

int Db::key_range(DbTxn *txnid, Dbt *key,
		  DB_KEY_RANGE *results, u_int32_t flags)
{
	DB *db = unwrap(this);
	int err;

	if ((err = db->key_range(db, unwrap(txnid), key,
				 results, flags)) != 0) {
		DB_ERROR("Db::key_range", err, error_policy());
		return (err);
	}
	return (0);
}

// If an error occurred during the constructor, report it now.
// Otherwise, call the underlying DB->open method.
//
int Db::open(const char *file, const char *database,
	     DBTYPE type, u_int32_t flags, int mode)
{
	int err;
	DB *db = unwrap(this);

	if ((err = construct_error_) != 0)
		DB_ERROR("Db::open", construct_error_, error_policy());
	else if ((err = db->open(db, file, database, type, flags, mode)) != 0)
		DB_ERROR("Db::open", err, error_policy());

	return (err);
}

int Db::pget(DbTxn *txnid, Dbt *key, Dbt *pkey, Dbt *value, u_int32_t flags)
{
	DB *db = unwrap(this);
	int err;

	if ((err = db->pget(db, unwrap(txnid), key, pkey,
			    value, flags)) != 0) {
		// DB_NOTFOUND and DB_KEYEMPTY are "normal" returns,
		// so should not be thrown as an error
		//
		if (err != DB_NOTFOUND && err != DB_KEYEMPTY) {
			const char *name = "Db::pget";
			if (err == ENOMEM && DB_OVERFLOWED_DBT(value))
				DB_ERROR_DBT(name, value, error_policy());
			else
				DB_ERROR(name, err, error_policy());
			return (err);
		}
	}
	return (err);
}

int Db::put(DbTxn *txnid, Dbt *key, Dbt *value, u_int32_t flags)
{
	int err;
	DB *db = unwrap(this);

	if ((err = db->put(db, unwrap(txnid), key, value, flags)) != 0) {

		// DB_KEYEXIST is a "normal" return, so should not be
		// thrown as an error
		//
		if (err != DB_KEYEXIST) {
			DB_ERROR("Db::put", err, error_policy());
			return (err);
		}
	}
	return (err);
}

int Db::rename(const char *file, const char *database,
	       const char *newname, u_int32_t flags)
{
	int err = 0;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::rename", EINVAL, error_policy());
		return (EINVAL);
	}

	// after a DB->rename (no matter if success or failure),
	// the underlying DB object must not be accessed,
	// so we clean up in advance.
	//
	cleanup();

	if ((err = db->rename(db, file, database, newname, flags)) != 0) {
		DB_ERROR("Db::rename", err, error_policy());
		return (err);
	}
	return (0);
}

int Db::remove(const char *file, const char *database, u_int32_t flags)
{
	int err = 0;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::remove", EINVAL, error_policy());
		return (EINVAL);
	}

	// after a DB->remove (no matter if success or failure),
	// the underlying DB object must not be accessed,
	// so we clean up in advance.
	//
	cleanup();

	if ((err = db->remove(db, file, database, flags)) != 0)
		DB_ERROR("Db::remove", err, error_policy());

	return (err);
}

int Db::truncate(DbTxn *txnid, u_int32_t *countp, u_int32_t flags)
{
	int err = 0;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::truncate", EINVAL, error_policy());
		return (EINVAL);
	}
	if ((err = db->truncate(db, unwrap(txnid), countp, flags)) != 0) {
		DB_ERROR("Db::truncate", err, error_policy());
		return (err);
	}
	return (0);
}

int Db::stat(void *sp, u_int32_t flags)
{
	int err;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::stat", EINVAL, error_policy());
		return (EINVAL);
	}
	if ((err = db->stat(db, sp, flags)) != 0) {
		DB_ERROR("Db::stat", err, error_policy());
		return (err);
	}
	return (0);
}

int Db::sync(u_int32_t flags)
{
	int err;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::sync", EINVAL, error_policy());
		return (EINVAL);
	}
	if ((err = db->sync(db, flags)) != 0 && err != DB_INCOMPLETE) {
		DB_ERROR("Db::sync", err, error_policy());
		return (err);
	}
	return (err);
}

int Db::upgrade(const char *name, u_int32_t flags)
{
	int err;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::upgrade", EINVAL, error_policy());
		return (EINVAL);
	}
	if ((err = db->upgrade(db, name, flags)) != 0) {
		DB_ERROR("Db::upgrade", err, error_policy());
		return (err);
	}
	return (0);
}
////////////////////////////////////////////////////////////////////////
//
// callbacks
//
// *_intercept_c are 'glue' functions that must be declared
// as extern "C" so to be typesafe.  Using a C++ method, even
// a static class method with 'correct' arguments, will not pass
// the test; some picky compilers do not allow mixing of function
// pointers to 'C' functions with function pointers to C++ functions.
//
// One wart with this scheme is that the *_callback_ method pointer
// must be declared public to be accessible by the C intercept.
// It's possible to accomplish the goal without this, and with
// another public transfer method, but it's just too much overhead.
// These callbacks are supposed to be *fast*.
//
// The DBTs we receive in these callbacks from the C layer may be
// manufactured there, but we want to treat them as a Dbts.
// Technically speaking, these DBTs were not constructed as a Dbts,
// but it should be safe to cast them as such given that Dbt is a
// *very* thin extension of the DBT.  That is, Dbt has no additional
// data elements, does not use virtual functions, virtual inheritance,
// multiple inheritance, RTI, or any other language feature that
// causes the structure to grow or be displaced.  Although this may
// sound risky, a design goal of C++ is complete structure
// compatibility with C, and has the philosophy 'if you don't use it,
// you shouldn't incur the overhead'.  If the C/C++ compilers you're
// using on a given machine do not have matching struct layouts, then
// a lot more things will be broken than just this.
//
// The alternative, creating a Dbt here in the callback, and populating
// it from the DBT, is just too slow and cumbersome to be very useful.

/* associate callback */
extern "C" int _db_associate_intercept_c(DB *secondary,
					 const DBT *key,
					 const DBT *data,
					 DBT *retval)
{
	Db *cxxthis;

	DB_ASSERT(secondary != NULL);
	cxxthis = (Db *)secondary->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->associate_callback_ != 0);

	return (*cxxthis->associate_callback_)(cxxthis,
					       Dbt::get_const_Dbt(key),
					       Dbt::get_const_Dbt(data),
					       Dbt::get_Dbt(retval));
}

int Db::associate(Db *secondary, int (*callback)(Db *, const Dbt *,
	const Dbt *, Dbt *), u_int32_t flags)
{
	DB *cthis = unwrap(this);

	/* Since the secondary Db is used as the first argument
	 * to the callback, we store the C++ callback on it
	 * rather than on 'this'.
	 */
	secondary->associate_callback_ = callback;
	return ((*(cthis->associate))
		(cthis, unwrap(secondary), _db_associate_intercept_c, flags));
}

/* feedback callback */
extern "C" void _db_feedback_intercept_c(DB *cthis, int opcode, int pct)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->feedback_callback_ != 0);

	(*cxxthis->feedback_callback_)(cxxthis, opcode, pct);
	return;
}

int Db::set_feedback(void (*arg)(Db *cxxthis, int opcode, int pct))
{
	DB *cthis = unwrap(this);
	feedback_callback_ = arg;
	return ((*(cthis->set_feedback))
		(cthis, _db_feedback_intercept_c));
}

/* append_recno callback */
extern "C" int _db_append_recno_intercept_c(DB *cthis, DBT *data,
					    db_recno_t recno)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->append_recno_callback_ != 0);

	return (*cxxthis->append_recno_callback_)(cxxthis,
						  Dbt::get_Dbt(data),
						  recno);
}

int Db::set_append_recno(int (*arg)(Db *cxxthis, Dbt *data, db_recno_t recno))
{
	DB *cthis = unwrap(this);
	append_recno_callback_ = arg;
	return ((*(cthis->set_append_recno))
		(cthis, _db_append_recno_intercept_c));
}

/* bt_compare callback */
extern "C" int _db_bt_compare_intercept_c(DB *cthis, const DBT *data1,
					  const DBT *data2)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->bt_compare_callback_ != 0);

	return (*cxxthis->bt_compare_callback_)(cxxthis,
						Dbt::get_const_Dbt(data1),
						Dbt::get_const_Dbt(data2));
}

int Db::set_bt_compare(int (*arg)(Db *cxxthis, const Dbt *data1,
				  const Dbt *data2))
{
	DB *cthis = unwrap(this);
	bt_compare_callback_ = arg;
	return ((*(cthis->set_bt_compare))
		(cthis, _db_bt_compare_intercept_c));
}

/* bt_prefix callback */
extern "C" size_t _db_bt_prefix_intercept_c(DB *cthis, const DBT *data1,
					    const DBT *data2)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->bt_prefix_callback_ != 0);

	return (*cxxthis->bt_prefix_callback_)(cxxthis,
					       Dbt::get_const_Dbt(data1),
					       Dbt::get_const_Dbt(data2));
}

int Db::set_bt_prefix(size_t (*arg)(Db *cxxthis, const Dbt *data1,
				    const Dbt *data2))
{
	DB *cthis = unwrap(this);
	bt_prefix_callback_ = arg;
	return ((*(cthis->set_bt_prefix))
		(cthis, _db_bt_prefix_intercept_c));
}

/* dup_compare callback */
extern "C" int _db_dup_compare_intercept_c(DB *cthis, const DBT *data1,
					   const DBT *data2)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->dup_compare_callback_ != 0);

	return (*cxxthis->dup_compare_callback_)(cxxthis,
						 Dbt::get_const_Dbt(data1),
						 Dbt::get_const_Dbt(data2));
}

int Db::set_dup_compare(int (*arg)(Db *cxxthis, const Dbt *data1,
				   const Dbt *data2))
{
	DB *cthis = unwrap(this);
	dup_compare_callback_ = arg;
	return ((*(cthis->set_dup_compare))
		(cthis, _db_dup_compare_intercept_c));
}

/* h_hash callback */
extern "C" u_int32_t _db_h_hash_intercept_c(DB *cthis, const void *data,
					    u_int32_t len)
{
	Db *cxxthis;

	DB_ASSERT(cthis != NULL);
	cxxthis = (Db *)cthis->cj_internal;
	DB_ASSERT(cxxthis != NULL);
	DB_ASSERT(cxxthis->h_hash_callback_ != 0);

	return (*cxxthis->h_hash_callback_)(cxxthis, data, len);
}

int Db::set_h_hash(u_int32_t (*arg)(Db *cxxthis, const void *data,
				    u_int32_t len))
{
	DB *cthis = unwrap(this);
	h_hash_callback_ = arg;
	return ((*(cthis->set_h_hash))
		(cthis, _db_h_hash_intercept_c));
}

// This is a 'glue' function declared as extern "C" so it will
// be compatible with picky compilers that do not allow mixing
// of function pointers to 'C' functions with function pointers
// to C++ functions.
//
extern "C"
int _verify_callback_c(void *handle, const void *str_arg)
{
	char *str;
	ostream *out;

	str = (char *)str_arg;
	out = (ostream *)handle;

	(*out) << str;
	if (out->fail())
		return (EIO);

	return (0);
}

int Db::verify(const char *name, const char *subdb,
	       ostream *ostr, u_int32_t flags)
{
	int err;
	DB *db = unwrap(this);

	if (!db) {
		DB_ERROR("Db::verify", EINVAL, error_policy());
		return (EINVAL);
	}
	if ((err = __db_verify_internal(db, name, subdb, ostr,
					_verify_callback_c, flags)) != 0) {
		DB_ERROR("Db::verify", err, error_policy());
		return (err);
	}
	return (0);
}

// This is a variant of the DB_WO_ACCESS macro to define a simple set_
// method calling the underlying C method, but unlike a simple
// set method, it may return an error or raise an exception.
// Note this macro expects that input _argspec is an argument
// list element (e.g. "char *arg") defined in terms of "arg".
//
#define	DB_DB_ACCESS(_name, _argspec)                          \
\
int Db::set_##_name(_argspec)                                  \
{                                                              \
	int ret;                                               \
	DB *db = unwrap(this);                                 \
							       \
	if ((ret = (*(db->set_##_name))(db, arg)) != 0) {      \
		DB_ERROR("Db::set_" # _name, ret, error_policy()); \
	}                                                      \
	return (ret);                                          \
}

#define	DB_DB_ACCESS_NORET(_name, _argspec)                    \
							       \
void Db::set_##_name(_argspec)                                 \
{                                                              \
	DB *db = unwrap(this);                                 \
							       \
	(*(db->set_##_name))(db, arg);                         \
	return;                                                \
}

DB_DB_ACCESS(bt_compare, bt_compare_fcn_type arg)
DB_DB_ACCESS(bt_maxkey, u_int32_t arg)
DB_DB_ACCESS(bt_minkey, u_int32_t arg)
DB_DB_ACCESS(bt_prefix, bt_prefix_fcn_type arg)
DB_DB_ACCESS(dup_compare, dup_compare_fcn_type arg)
DB_DB_ACCESS_NORET(errfile, FILE *arg)
DB_DB_ACCESS_NORET(errpfx, const char *arg)
DB_DB_ACCESS(flags, u_int32_t arg)
DB_DB_ACCESS(h_ffactor, u_int32_t arg)
DB_DB_ACCESS(h_hash, h_hash_fcn_type arg)
DB_DB_ACCESS(h_nelem, u_int32_t arg)
DB_DB_ACCESS(lorder, int arg)
DB_DB_ACCESS(pagesize, u_int32_t arg)
DB_DB_ACCESS(re_delim, int arg)
DB_DB_ACCESS(re_len, u_int32_t arg)
DB_DB_ACCESS(re_pad, int arg)
DB_DB_ACCESS(re_source, char *arg)
DB_DB_ACCESS(q_extentsize, u_int32_t arg)

// Here are the get/set methods that don't fit the above mold.
//

int Db::set_alloc(db_malloc_fcn_type malloc_fcn,
		     db_realloc_fcn_type realloc_fcn,
		     db_free_fcn_type free_fcn)
{
	DB *db;

	db = unwrap(this);
	return db->set_alloc(db, malloc_fcn, realloc_fcn, free_fcn);
}

void Db::set_errcall(void (*arg)(const char *, char *))
{
	env_->set_errcall(arg);
}

void *Db::get_app_private() const
{
	return unwrapConst(this)->app_private;
}

void Db::set_app_private(void *value)
{
	unwrap(this)->app_private = value;
}

int Db::set_cachesize(u_int32_t gbytes, u_int32_t bytes, int ncache)
{
	int ret;
	DB *db = unwrap(this);

	if ((ret = (*(db->set_cachesize))(db, gbytes, bytes, ncache)) != 0) {
		DB_ERROR("Db::set_cachesize", ret, error_policy());
	}
	return (ret);
}

int Db::set_paniccall(void (*callback)(DbEnv *, int))
{
	return (env_->set_paniccall(callback));
}

void Db::set_error_stream(ostream *error_stream)
{
	env_->set_error_stream(error_stream);
}

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            Dbc                                     //
//                                                                    //
////////////////////////////////////////////////////////////////////////

// It's private, and should never be called, but VC4.0 needs it resolved
//
Dbc::~Dbc()
{
}

int Dbc::close()
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_close(cursor)) != 0) {
		DB_ERROR("Db::close", err, ON_ERROR_UNKNOWN);
		return (err);
	}
	return (0);
}

int Dbc::count(db_recno_t *countp, u_int32_t flags_arg)
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_count(cursor, countp, flags_arg)) != 0) {
		DB_ERROR("Db::count", err, ON_ERROR_UNKNOWN);
		return (err);
	}
	return (0);
}

int Dbc::del(u_int32_t flags_arg)
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_del(cursor, flags_arg)) != 0) {

		// DB_KEYEMPTY is a "normal" return, so should not be
		// thrown as an error
		//
		if (err != DB_KEYEMPTY) {
			DB_ERROR("Db::del", err, ON_ERROR_UNKNOWN);
			return (err);
		}
	}
	return (err);
}

int Dbc::dup(Dbc** cursorp, u_int32_t flags_arg)
{
	DBC *cursor = this;
	DBC *new_cursor = 0;
	int err;

	if ((err = cursor->c_dup(cursor, &new_cursor, flags_arg)) != 0) {
		DB_ERROR("Db::dup", err, ON_ERROR_UNKNOWN);
		return (err);
	}

	// The following cast implies that Dbc can be no larger than DBC
	*cursorp = (Dbc*)new_cursor;
	return (0);
}

int Dbc::get(Dbt* key, Dbt *data, u_int32_t flags_arg)
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_get(cursor, key, data, flags_arg)) != 0) {

		// DB_NOTFOUND and DB_KEYEMPTY are "normal" returns,
		// so should not be thrown as an error
		//
		if (err != DB_NOTFOUND && err != DB_KEYEMPTY) {
			const char *name = "Dbc::get";
			if (err == ENOMEM && DB_OVERFLOWED_DBT(key))
				DB_ERROR_DBT(name, key, ON_ERROR_UNKNOWN);
			else if (err == ENOMEM && DB_OVERFLOWED_DBT(data))
				DB_ERROR_DBT(name, data, ON_ERROR_UNKNOWN);
			else
				DB_ERROR(name, err, ON_ERROR_UNKNOWN);

			return (err);
		}
	}
	return (err);
}

int Dbc::pget(Dbt* key, Dbt *pkey, Dbt *data, u_int32_t flags_arg)
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_pget(cursor, key, pkey, data, flags_arg)) != 0) {

		// DB_NOTFOUND and DB_KEYEMPTY are "normal" returns,
		// so should not be thrown as an error
		//
		if (err != DB_NOTFOUND && err != DB_KEYEMPTY) {
			const char *name = "Dbc::pget";
			if (err == ENOMEM && DB_OVERFLOWED_DBT(key))
				DB_ERROR_DBT(name, key, ON_ERROR_UNKNOWN);
			else if (err == ENOMEM && DB_OVERFLOWED_DBT(data))
				DB_ERROR_DBT(name, data, ON_ERROR_UNKNOWN);
			else
				DB_ERROR(name, err, ON_ERROR_UNKNOWN);

			return (err);
		}
	}
	return (err);
}

int Dbc::put(Dbt* key, Dbt *data, u_int32_t flags_arg)
{
	DBC *cursor = this;
	int err;

	if ((err = cursor->c_put(cursor, key, data, flags_arg)) != 0) {

		// DB_KEYEXIST is a "normal" return, so should not be
		// thrown as an error
		//
		if (err != DB_KEYEXIST) {
			DB_ERROR("Dbc::put", err, ON_ERROR_UNKNOWN);
			return (err);
		}
	}
	return (err);
}

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            Dbt                                 //
//                                                                    //
////////////////////////////////////////////////////////////////////////

Dbt::Dbt()
{
	DBT *dbt = this;
	memset(dbt, 0, sizeof(DBT));
}

Dbt::Dbt(void *data_arg, size_t size_arg)
{
	DBT *dbt = this;
	memset(dbt, 0, sizeof(DBT));
	set_data(data_arg);
	set_size(size_arg);
}

Dbt::~Dbt()
{
}

Dbt::Dbt(const Dbt &that)
{
	const DBT *from = &that;
	DBT *to = this;
	memcpy(to, from, sizeof(DBT));
}

Dbt &Dbt::operator = (const Dbt &that)
{
	if (this != &that) {
		const DBT *from = &that;
		DBT *to = this;
		memcpy(to, from, sizeof(DBT));
	}
	return (*this);
}
