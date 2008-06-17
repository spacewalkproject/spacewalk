# See the file LICENSE for redistribution information.
#
# Copyright (c) 1999-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test065.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# DB Test 65: Test of DB->stat(DB_RECORDCOUNT)
proc test065 { method args } {
	source ./include.tcl
	global errorCode
	global alphabet

	set args [convert_args $method $args]
	set omethod [convert_method $method]
	set tnum 65

	set eindex [lsearch -exact $args "-env"]
	#
	# If we are using an env, then testfile should just be the db name.
	# Otherwise it is the test directory and the name.
	if { $eindex == -1 } {
		set testfile $testdir/test0$tnum.db
		set env NULL
	} else {
		set testfile test0$tnum.db
		incr eindex
		set env [lindex $args $eindex]
	}
	cleanup $testdir $env

	puts "Test0$tnum: $method ($args) DB->stat(DB_FAST_STAT) test."

	puts "\tTest0$tnum.a: Create database and check it while empty."

	set db [eval {berkdb_open_noerr -create -truncate -mode 0644} \
	    $omethod $args $testfile]
	error_check_good db_open [is_valid_db $db] TRUE

	set ret [catch {eval $db stat -faststat} res]

	error_check_good db_close [$db close] 0

	if { ([is_record_based $method] && ![is_queue $method]) \
	    || [is_rbtree $method] } {
		error_check_good recordcount_ok [is_substr $res \
		    "{{Number of keys} 0}"] 1
	} else {
		puts "\tTest0$tnum: Test complete for method $method."
		return
	}

	# If we've got this far, we're on an access method for
	# which record counts makes sense.  Thus, we no longer
	# catch EINVALs, and no longer care about __db_errs.
	set db [eval {berkdb_open -create -mode 0644} $omethod $args $testfile]

	puts "\tTest0$tnum.b: put 10000 keys."

	if { [is_record_based $method] } {
		set gflags " -recno "
		set keypfx ""
	} else {
		set gflags ""
		set keypfx "key"
	}

	set data [pad_data $method $alphabet]

	for { set ndx 1 } { $ndx <= 10000 } { incr ndx } {
		set ret [eval {$db put} $keypfx$ndx $data]
		error_check_good db_put $ret 0
	}

	set ret [$db stat -faststat]
	error_check_good recordcount_after_puts \
	    [is_substr $ret "{{Number of keys} 10000}"] 1

	puts "\tTest0$tnum.c: delete 9000 keys."
	for { set ndx 1 } { $ndx <= 9000 } { incr ndx } {
		if { [is_rrecno $method] == 1 } {
			# if we're renumbering, when we hit key 5001 we'll
			# have deleted 5000 and we'll croak!  So delete key
			# 1, repeatedly.
			set ret [eval {$db del} [concat $keypfx 1]]
		} else {
			set ret [eval {$db del} $keypfx$ndx]
		}
		error_check_good db_del $ret 0
	}

	set ret [$db stat -faststat]
	if { [is_rrecno $method] == 1 || [is_rbtree $method] == 1 } {
		# We allow renumbering--thus the stat should return 1000
		error_check_good recordcount_after_dels \
		    [is_substr $ret "{{Number of keys} 1000}"] 1
	} else {
		# No renumbering--no change in RECORDCOUNT!
		error_check_good recordcount_after_dels \
		    [is_substr $ret "{{Number of keys} 10000}"] 1
	}

	puts "\tTest0$tnum.d: put 8000 new keys at the beginning."
	for { set ndx 1 } { $ndx <= 8000 } {incr ndx } {
		set ret [eval {$db put} $keypfx$ndx $data]
		error_check_good db_put_beginning $ret 0
	}

	set ret [$db stat -faststat]
	if { [is_rrecno $method] == 1 } {
		# With renumbering we're back up to 8000
		error_check_good recordcount_after_dels \
		    [is_substr $ret "{{Number of keys} 8000}"] 1
	} elseif { [is_rbtree $method] == 1 } {
		# Total records in a btree is now 9000
		error_check_good recordcount_after_dels \
		    [is_substr $ret "{{Number of keys} 9000}"] 1
	} else {
		# No renumbering--still no change in RECORDCOUNT.
		error_check_good recordcount_after_dels \
		    [is_substr $ret "{{Number of keys} 10000}"] 1
	}

	puts "\tTest0$tnum.e: put 8000 new keys off the end."
	for { set ndx 9001 } { $ndx <= 17000 } {incr ndx } {
		set ret [eval {$db put} $keypfx$ndx $data]
		error_check_good db_put_end $ret 0
	}

	set ret [$db stat -faststat]
	if { [is_rbtree $method] != 1 } {
		# If this is a recno database, the record count should
		# be up to 17000, the largest number we've seen, with
		# or without renumbering.
		error_check_good recordcount_after_puts2 \
		    [is_substr $ret "{{Number of keys} 17000}"] 1
	} else {
		# In an rbtree, 1000 of those keys were overwrites,
		# so there are 7000 new keys + 9000 old keys == 16000
		error_check_good recordcount_after_puts2 \
		    [is_substr $ret "{{Number of keys} 16000}"] 1
	}

	error_check_good db_close [$db close] 0
}
