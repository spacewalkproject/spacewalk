/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2001
 *      Sleepycat Software.  All rights reserved.
 *
 * $Id: DbTxn.java,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */

package com.sleepycat.db;

/**
 *
 * @author Donald D. Anderson
 */
public class DbTxn
{
    // methods
    //
    public native void abort()
         throws DbException;

    public native void commit(int flags)
         throws DbException;

    public native /*u_int32_t*/ int id()
         throws DbException;

    public native void prepare(byte[] gid)
         throws DbException;

    protected native void finalize()
         throws Throwable;

    // We override Object.equals because it is possible for
    // the Java API to create multiple DbTxns that reference
    // the same underlying object.  This can happen for example
    // during DbEnv.txn_recover().
    //
    public boolean equals(Object obj)
    {
        if (this == obj)
            return true;

        if (obj != null && (obj instanceof DbTxn)) {
            DbTxn that = (DbTxn)obj;
            return (this.private_dbobj_ == that.private_dbobj_);
        }
        return false;
    }

    // We must override Object.hashCode whenever we override
    // Object.equals() to enforce the maxim that equal objects
    // have the same hashcode.
    //
    public int hashCode()
    {
        return ((int)private_dbobj_ ^ (int)(private_dbobj_ >> 32));
    }

    // get/set methods
    //

    // private data
    //
    private long private_dbobj_ = 0;

    static {
        Db.load_db();
    }
}

// end of DbTxn.java
