/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2000-2001
 *      Sleepycat Software.  All rights reserved.
 *
 * $Id: DbHash.java,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */

package com.sleepycat.db;

/*
 * This interface is used by DbEnv.set_bt_compare()
 *
 */
public interface DbHash
{
    public abstract int hash(Db db, byte[] data, int len);
}

// end of DbHash.java
