# See the file LICENSE for redistribution information.
#
# Copyright (c) 2000-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: test095.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# DB Test 95 {access method}
# Bulk get test.
#
proc test095 { method {nsets 1000} {noverflows 25} {tnum 95} args } {
	source ./include.tcl
	set args [convert_args $method $args]
	set omethod [convert_method $method]

	set eindex [lsearch -exact $args "-env"]
	#
	# If we are using an env, then testfile should just be the db name.
	# Otherwise it is the test directory and the name.
	if { $eindex == -1 } {
		set basename $testdir/test0$tnum
		set env NULL
		# If we've our own env, no reason to swap--this isn't
		# an mpool test.
		set carg { -cachesize {0 25000000 0} }
	} else {
		set basename test0$tnum
		incr eindex
		set env [lindex $args $eindex]
		set carg {}
	}
	cleanup $testdir $env

	puts "Test0$tnum: $method ($args) Bulk get test"

	if { [is_record_based $method] == 1 || [is_rbtree $method] == 1 } {
		puts "Test0$tnum skipping for method $method"
		return
	}

	# We run the meat of the test twice: once with unsorted dups,
	# once with sorted dups.
	for { set dflag "-dup"; set sort "unsorted"; set diter 0 } \
	    { $diter < 2 } \
	    { set dflag "-dup -dupsort"; set sort "sorted"; incr diter } {
		set testfile $basename-$sort.db
		set did [open $dict]

		# Open and populate the database with $nsets sets of dups.
		# Each set contains as many dups as its number
		puts "\tTest0$tnum.a:\
		    Creating database with $nsets sets of $sort dups."
		set dargs "$dflag $carg $args"
		set db [eval {berkdb_open -create} $omethod $dargs $testfile]
		error_check_good db_open [is_valid_db $db] TRUE
		t95_populate $db $did $nsets 0

		# Run basic get tests.
		t95_gettest $db $tnum b [expr 8192] 1
		t95_gettest $db $tnum c [expr 10 * 8192] 0

		# Run cursor get tests.
		t95_cgettest $db $tnum d [expr 100] 1
		t95_cgettest $db $tnum e [expr 10 * 8192] 0

		set m [expr 4000 * $noverflows]
		puts "\tTest0$tnum.f: Growing\
		    database with $noverflows overflow sets (max item size $m)"
		t95_populate $db $did $noverflows 4000

		# Run overflow get tests.
		t95_gettest $db $tnum g [expr 10 * 8192] 1
		t95_gettest $db $tnum h [expr $m * 2] 1
		t95_gettest $db $tnum i [expr $m * $noverflows * 2] 0

		# Run cursor get tests.
		t95_cgettest $db $tnum j [expr 10 * 8192] 1
		t95_cgettest $db $tnum k [expr $m * 2] 0

		error_check_good db_close [$db close] 0
		close $did
	}

}

proc t95_gettest { db tnum letter bufsize expectfail } {
	t95_gettest_body $db $tnum $letter $bufsize $expectfail 0
}
proc t95_cgettest { db tnum letter bufsize expectfail } {
	t95_gettest_body $db $tnum $letter $bufsize $expectfail 1
}

proc t95_gettest_body { db tnum letter bufsize expectfail usecursor } {
	global errorCode

	if { $usecursor == 0 } {
		set action "db get -multi"
	} else {
		set action "dbc get -multi -set/-next"
	}
	puts "\tTest0$tnum.$letter: $action with bufsize $bufsize"

	set allpassed TRUE
	set saved_err ""

	# Cursor for $usecursor.
	if { $usecursor != 0 } {
		set getcurs [$db cursor]
		error_check_good getcurs [is_valid_cursor $getcurs $db] TRUE
	}

	# Traverse DB with cursor;  do get/c_get(DB_MULTIPLE) on each item.
	set dbc [$db cursor]
	error_check_good is_valid_dbc [is_valid_cursor $dbc $db] TRUE
	for { set dbt [$dbc get -first] } { [llength $dbt] != 0 } \
	    { set dbt [$dbc get -nextnodup] } {
		set key [lindex [lindex $dbt 0] 0]
		set datum [lindex [lindex $dbt 0] 1]

		if { $usecursor == 0 } {
			set ret [catch {eval $db get -multi $bufsize $key} res]
		} else {
			set res {}
			for { set ret [catch {eval $getcurs get -multi $bufsize\
			    -set $key} tres] } \
			    { $ret == 0 && [llength $tres] != 0 } \
			    { set ret [catch {eval $getcurs get -multi $bufsize\
			    -nextdup} tres]} {
				eval lappend res $tres
			}
		}

		# If we expect a failure, be more tolerant if the above fails;
		# just make sure it's an ENOMEM, mark it, and move along.
		if { $expectfail != 0 && $ret != 0 } {
			error_check_good multi_failure_errcode \
			    [is_substr $errorCode ENOMEM] 1
			set allpassed FALSE
			continue
		}
		error_check_good get_multi($key) $ret 0
		t95_verify $res FALSE
	}

	set ret [catch {eval $db get -multi $bufsize} res]

	if { $expectfail == 1 } {
		error_check_good allpassed $allpassed FALSE
		puts "\t\tTest0$tnum.$letter:\
		    returned at least one ENOMEM (as expected)"
	} else {
		error_check_good allpassed $allpassed TRUE
		puts "\t\tTest0$tnum.$letter: succeeded (as expected)"
	}

	error_check_good dbc_close [$dbc close] 0
	if { $usecursor != 0 } {
		error_check_good getcurs_close [$getcurs close] 0
	}
}

# Verify that a passed-in list of key/data pairs all match the predicted
# structure (e.g. {{thing1 thing1.0}}, {{key2 key2.0} {key2 key2.1}}).
proc t95_verify { res multiple_keys } {
	global alphabet

	set i 0

	set orig_key [lindex [lindex $res 0] 0]
	set nkeys [string trim $orig_key $alphabet']
	set base_key [string trim $orig_key 0123456789]
	set datum_count 0

	while { 1 } {
		set key [lindex [lindex $res $i] 0]
		set datum [lindex [lindex $res $i] 1]

		if { $datum_count >= $nkeys } {
			if { [llength $key] != 0 } {
				# If there are keys beyond $nkeys, we'd
				# better have multiple_keys set.
				error_check_bad "keys beyond number $i allowed"\
				    $multiple_keys FALSE

				# If multiple_keys is set, accept the new key.
				set orig_key $key
				set nkeys [eval string trim \
				    $orig_key {$alphabet'}]
				set base_key [eval string trim \
				    $orig_key 0123456789]
				set datum_count 0
			} else {
				# datum_count has hit nkeys.  We're done.
				return
			}
		}

		error_check_good returned_key($i) $key $orig_key
		error_check_good returned_datum($i) \
		    $datum $base_key.[format %4u $datum_count]
		incr datum_count
		incr i
	}
}

# Add nsets dup sets, each consisting of {word$ndups word$n} pairs,
# with "word" having (i * pad_bytes)  bytes extra padding.
proc t95_populate { db did nsets pad_bytes } {
	for { set i 1 } { $i <= $nsets } { incr i } {
		# basekey is a padded dictionary word
		gets $did basekey

		append basekey [repeat "a" [expr $pad_bytes * $i]]

		# key is basekey with the number of dups stuck on.
		set key $basekey$i

		for { set j 0 } { $j < $i } { incr j } {
			set data $basekey.[format %4u $j]
			error_check_good db_put($key,$data) \
			    [$db put $key $data] 0
		}
	}

	# This will make debugging easier, and since the database is
	# read-only from here out, it's cheap.
	error_check_good db_sync [$db sync] 0
}
