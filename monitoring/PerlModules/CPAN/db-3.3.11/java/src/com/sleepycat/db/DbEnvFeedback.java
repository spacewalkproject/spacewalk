/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1999-2001
 *      Sleepycat Software.  All rights reserved.
 *
 * $Id: DbEnvFeedback.java,v 1.1.1.1 2002-01-11 00:21:36 apingel Exp $
 */

package com.sleepycat.db;

public interface DbEnvFeedback
{
    // methods
    //
    public abstract void feedback(DbEnv env, int opcode, int pct);
}

// end of DbFeedback.java
