/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1999-2001
 *      Sleepycat Software.  All rights reserved.
 *
 * $Id: DbSecondaryKeyCreate.java,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */

package com.sleepycat.db;

/*
 * This is used as a callback by Db.associate.
 */
public interface DbSecondaryKeyCreate
{
    public int secondary_key_create(Db secondary, Dbt key,
                                    Dbt data, Dbt result)
        throws DbException;
}

// end of DbSecondaryKeyCreate.java
