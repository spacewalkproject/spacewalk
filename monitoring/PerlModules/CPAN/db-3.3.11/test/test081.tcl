# See the file LICENSE for redistribution information.
#
# Copyright (c) 1999-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test081.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# Test 81.
# Test off-page duplicates and overflow pages together with
# very large keys (key/data as file contents).
#
proc test081 { method {ndups 13} {tnum 81} args} {
	source ./include.tcl

	eval {test017 $method 1 $ndups $tnum} $args
}
