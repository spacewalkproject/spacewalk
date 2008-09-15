# See the file LICENSE for redistribution information.
#
# Copyright (c) 2000-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test076.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# DB Test 76: Test creation of many small databases in an env
proc test076 { method { ndbs 1000  } { tnum 76 } args } {
	source ./include.tcl

	set omethod [convert_method $method]
	set args [convert_args $method $args]

	if { [is_record_based $method] == 1 } {
		set key ""
	} else {
		set key "key"
	}
	set data "datamoredatamoredata"

	puts -nonewline "Test0$tnum $method ($args): "
	puts -nonewline "Create $ndbs"
	puts " small databases in one env."

	# Create an env if we weren't passed one.
	set eindex [lsearch -exact $args "-env"]
	if { $eindex == -1 } {
		set deleteenv 1
		env_cleanup $testdir
		set env [eval {berkdb env -create -home} $testdir]
		error_check_good env [is_valid_env $env] TRUE
		set args "$args -env $env"
	} else {
		set deleteenv 0
		incr eindex
		set env [lindex $args $eindex]
	}
	cleanup $testdir $env

	for { set i 1 } { $i <= $ndbs } { incr i } {
		set testfile test0$tnum.$i.db

		set db [eval {berkdb_open -create -truncate -mode 0644}\
		    $args $omethod $testfile]
		error_check_good db_open($i) [is_valid_db $db] TRUE

		error_check_good db_put($i) [$db put $key$i \
		    [chop_data $method $data$i]] 0
		error_check_good db_close($i) [$db close] 0
	}

	if { $deleteenv == 1 } {
		error_check_good env_close [$env close] 0
	}

	puts "\tTest0$tnum passed."
}
