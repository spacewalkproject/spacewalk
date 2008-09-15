# See the file LICENSE for redistribution information.
#
# Copyright (c) 1999-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: env009.tcl,v 1.1.1.1 2002-01-11 00:21:38 apingel Exp $
#
# Env Test 9
# Test calls to all the various stat functions.
# We have several sprinkled throughout the test suite, but
# this will ensure that we run all of them at least once.
proc env009 { } {
	source ./include.tcl

	puts "Env009: Various stat function test."

	env_cleanup $testdir
	puts "\tEnv009.a: Setting up env and a database."

	set e [berkdb env -create -home $testdir -txn]
	error_check_good dbenv [is_valid_env $e] TRUE
	set dbbt [berkdb_open -create -btree $testdir/env009bt.db]
	error_check_good dbopen [is_valid_db $dbbt] TRUE
	set dbh [berkdb_open -create -hash $testdir/env009h.db]
	error_check_good dbopen [is_valid_db $dbh] TRUE
	set dbq [berkdb_open -create -btree $testdir/env009q.db]
	error_check_good dbopen [is_valid_db $dbq] TRUE

	set rlist {
	{ "lock_stat" "Max locks" "Env009.b"}
	{ "log_stat" "Magic" "Env009.c"}
	{ "mpool_stat" "Number of caches" "Env009.d"}
	{ "txn_stat" "Max Txns" "Env009.e"}
	}

	foreach pair $rlist {
		set cmd [lindex $pair 0]
		set str [lindex $pair 1]
		set msg [lindex $pair 2]
		puts "\t$msg: $cmd"
		set ret [$e $cmd]
		error_check_good $cmd [is_substr $ret $str] 1
	}
	puts "\tEnv009.f: btree stats"
	set ret [$dbbt stat]
	error_check_good $cmd [is_substr $ret "Magic"] 1
	puts "\tEnv009.g: hash stats"
	set ret [$dbh stat]
	error_check_good $cmd [is_substr $ret "Magic"] 1
	puts "\tEnv009.f: queue stats"
	set ret [$dbq stat]
	error_check_good $cmd [is_substr $ret "Magic"] 1
	error_check_good dbclose [$dbbt close] 0
	error_check_good dbclose [$dbh close] 0
	error_check_good dbclose [$dbq close] 0
	error_check_good envclose [$e close] 0
}
