# See the file LICENSE for redistribution information.
#
# Copyright (c) 2000-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test082.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# Test 82.
# Test of DB_PREV_NODUP
proc test082 { method {dir -prevnodup} {nitems 100}\
    {tnum 82} args} {
	source ./include.tcl

	eval {test074 $method $dir $nitems $tnum} $args
}
