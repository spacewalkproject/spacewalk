# See the file LICENSE for redistribution information.
#
# Copyright (c) 1996-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test005.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# DB Test 5 {access method}
# Check that cursor operations work.  Create a database; close database and
# reopen it.  Then read through the database sequentially using cursors and
# delete each element.
proc test005 { method {nentries 10000} args } {
	eval {test004 $method $nentries 5 0} $args
}
