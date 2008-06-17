# See the file LICENSE for redistribution information.
#
# Copyright (c) 1996-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: txn.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# Options are:
# -dir <directory in which to store memp>
# -max <max number of concurrent transactions>
# -iterations <iterations>
# -stat
proc txn_usage {} {
	puts "txn -dir <directory> -iterations <number of ops> \
	    -max <max number of transactions> -stat"
}

proc txntest { args } {
	source ./include.tcl

	# Set defaults
	set iterations 50
	set max 1024
	set dostat 0
	set flags ""
	for { set i 0 } { $i < [llength $args] } {incr i} {
		switch -regexp -- [lindex $args $i] {
			-d.* { incr i; set testdir [lindex $args $i] }
			-f.* { incr i; set flags [lindex $args $i] }
			-i.* { incr i; set iterations [lindex $args $i] }
			-m.* { incr i; set max [lindex $args $i] }
			-s.* { set dostat 1 }
			default {
				puts -nonewline "FAIL:[timestamp] Usage: "
				txn_usage
				return
			}
		}
	}
	if { $max < $iterations } {
		set max $iterations
	}

	# Now run the various functionality tests
	txn001 $testdir $max $iterations $flags
	txn002 $testdir $max $iterations
	txn003 $testdir
}

proc txn001 { dir max ntxns flags} {
	source ./include.tcl

	puts "Txn001: Basic begin, commit, abort"

	# Open environment
	env_cleanup $dir

	set env [eval {berkdb \
	    env -create -mode 0644 -txn -txn_max $max -home $dir} $flags]
	error_check_good evn_open [is_valid_env $env] TRUE
	txn001_suba $ntxns $env
	txn001_subb $ntxns $env
	txn001_subc $ntxns $env
	# Close and unlink the file
	error_check_good env_close:$env [$env close] 0
}

proc txn001_suba { ntxns env } {
	source ./include.tcl

	# We will create a bunch of transactions and commit them.
	set txn_list {}
	set tid_list {}
	puts "Txn001.a: Beginning/Committing $ntxns Transactions in $env"
	for { set i 0 } { $i < $ntxns } { incr i } {
		set txn [$env txn]
		error_check_good txn_begin [is_valid_txn $txn $env] TRUE

		lappend txn_list $txn

		set tid [$txn id]
		error_check_good tid_check [lsearch $tid_list $tid] -1

		lappend tid_list $tid
	}

	# Now commit them all
	foreach t $txn_list {
		error_check_good txn_commit:$t [$t commit] 0
	}
}

proc txn001_subb { ntxns env } {
	# We will create a bunch of transactions and abort them.
	set txn_list {}
	set tid_list {}
	puts "Txn001.b: Beginning/Aborting Transactions"
	for { set i 0 } { $i < $ntxns } { incr i } {
		set txn [$env txn]
		error_check_good txn_begin [is_valid_txn $txn $env] TRUE

		lappend txn_list $txn

		set tid [$txn id]
		error_check_good tid_check [lsearch $tid_list $tid] -1

		lappend tid_list $tid
	}

	# Now abort them all
	foreach t $txn_list {
		error_check_good txn_abort:$t [$t abort] 0
	}
}

proc txn001_subc { ntxns env } {
	# We will create a bunch of transactions and commit them.
	set txn_list {}
	set tid_list {}
	puts "Txn001.c: Beginning/Prepare/Committing Transactions"
	for { set i 0 } { $i < $ntxns } { incr i } {
		set txn [$env txn]
		error_check_good txn_begin [is_valid_txn $txn $env] TRUE

		lappend txn_list $txn

		set tid [$txn id]
		error_check_good tid_check [lsearch $tid_list $tid] -1

		lappend tid_list $tid
	}

	# Now prepare them all
	foreach t $txn_list {
		error_check_good txn_prepare:$t \
		    [$t prepare [make_gid global:$t]] 0
	}

	# Now commit them all
	foreach t $txn_list {
		error_check_good txn_commit:$t [$t commit] 0
	}

}

# Verify that read-only transactions do not create any log records
proc txn002 { dir max ntxns } {
	source ./include.tcl

	puts "Txn002: Read-only transaction test"

	env_cleanup $dir
	set env [berkdb \
	    env -create -mode 0644 -txn -txn_max $max -home $dir]
	error_check_good dbenv [is_valid_env $env] TRUE

	# We will create a bunch of transactions and commit them.
	set txn_list {}
	set tid_list {}
	puts "Txn002.a: Beginning/Committing Transactions"
	for { set i 0 } { $i < $ntxns } { incr i } {
		set txn [$env txn]
		error_check_good txn_begin [is_valid_txn $txn $env] TRUE

		lappend txn_list $txn

		set tid [$txn id]
		error_check_good tid_check [lsearch $tid_list $tid] -1

		lappend tid_list $tid
	}

	# Now commit them all
	foreach t $txn_list {
		error_check_good txn_commit:$t [$t commit] 0
	}

	# Now verify that there aren't any log records.
	set r [$env log_get -first]
	error_check_good log_get:$r [llength $r] 0

	error_check_good env_close:$r [$env close] 0
}

# Test abort/commit/prepare of txns with outstanding child txns.
proc txn003 { dir } {
	source ./include.tcl

	puts "Txn003: Outstanding child transaction test"

	env_cleanup $dir
	set testfile txn003.db

	set env_cmd "berkdb env -create -txn -home $dir"
	set env [eval $env_cmd]
	error_check_good dbenv [is_valid_env $env] TRUE

	set oflags {-create -btree -mode 0644 -env $env $testfile}
	set db [eval {berkdb open} $oflags]
	error_check_good db_open [is_valid_db $db] TRUE

	#
	# Put some data so that we can check commit or abort of child
	#
	set key 1
	set origdata some_data
	set newdata this_is_new_data
	set newdata2 some_other_new_data

	error_check_good db_put [$db put $key $origdata] 0
	error_check_good dbclose [$db close] 0

	set db [eval {berkdb open} $oflags]
	error_check_good db_open [is_valid_db $db] TRUE

	txn003_check $db $key "Origdata" $origdata

	puts "\tTxn003.a: Parent abort"
	set parent [$env txn]
	error_check_good txn_begin [is_valid_txn $parent $env] TRUE
	set child [$env txn -parent $parent]
	error_check_good txn_begin [is_valid_txn $child $env] TRUE
	error_check_good db_put [$db put -txn $child $key $newdata] 0
	error_check_good parent_abort [$parent abort] 0
	txn003_check $db $key "parent_abort" $origdata
	# Check child handle is invalid
	set stat [catch {$child abort} ret]
	error_check_good child_handle $stat 1
	error_check_good child_h2 [is_substr $ret "invalid command name"] 1

	puts "\tTxn003.b: Parent commit"
	set parent [$env txn]
	error_check_good txn_begin [is_valid_txn $parent $env] TRUE
	set child [$env txn -parent $parent]
	error_check_good txn_begin [is_valid_txn $child $env] TRUE
	error_check_good db_put [$db put -txn $child $key $newdata] 0
	error_check_good parent_commit [$parent commit] 0
	txn003_check $db $key "parent_commit" $newdata
	# Check child handle is invalid
	set stat [catch {$child abort} ret]
	error_check_good child_handle $stat 1
	error_check_good child_h2 [is_substr $ret "invalid command name"] 1
	error_check_good dbclose [$db close] 0
	error_check_good env_close [$env close] 0

	#
	# Since the data check assumes what has come before, the 'commit'
	# operation must be last.
	#
	set rlist {
		{begin		"\tTxn003.c"}
		{prepare	"\tTxn003.d"}
		{abort		"\tTxn003.e"}
		{commit		"\tTxn003.f"}
	}
	set count 0
	foreach pair $rlist {
		incr count
		set op [lindex $pair 0]
		set msg [lindex $pair 1]
		txn003_body $env_cmd $testfile $dir $key $newdata2 $msg $op
		set env [eval $env_cmd]
		error_check_good dbenv [is_valid_env $env] TRUE

		berkdb debug_check
		set db [eval {berkdb open} $oflags]
		error_check_good db_open [is_valid_db $db] TRUE
		#
		# For prepare we'll then just
		# end up aborting after we test what we need to.
		# So set gooddata to the same as abort.
		switch $op {
			abort {
				set gooddata $newdata
			}
			begin {
				set gooddata $newdata
			}
			commit {
				set gooddata $newdata2
			}
			prepare {
				set gooddata $newdata
			}
		}
		txn003_check $db $key "parent_$op" $gooddata
		error_check_good dbclose [$db close] 0
		error_check_good env_close [$env close] 0
	}

	puts "\tTxn003.g: Attempt child prepare"
	set env [eval $env_cmd]
	error_check_good dbenv [is_valid_env $env] TRUE
	berkdb debug_check
	set db [eval {berkdb open} $oflags]
	error_check_good db_open [is_valid_db $db] TRUE

	set parent [$env txn]
	error_check_good txn_begin [is_valid_txn $parent $env] TRUE
	set child [$env txn -parent $parent]
	error_check_good txn_begin [is_valid_txn $child $env] TRUE
	error_check_good db_put [$db put -txn $child $key $newdata] 0
	set gid [make_gid child_prepare:$child]
	set stat [catch {$child prepare $gid} ret]
	error_check_good child_prepare $stat 1
	error_check_good child_prep_err \
	    [is_substr $ret "Prepare disallowed on child"] 1

	puts "\tTxn003.h: Attempt child discard"
	set stat [catch {$child discard} ret]
	error_check_good child_discard $stat 1
	error_check_good child_disc_err \
	    [is_substr $ret "not a restored transaction"] 1
	#
	# Just commit everybody.  We are done.
	#
	error_check_good parent_commit [$parent commit] 0
	error_check_good dbclose [$db close] 0
	error_check_good env_close [$env close] 0
}

proc txn003_body { env_cmd testfile dir key newdata2 msg op } {
	source ./include.tcl

	berkdb debug_check
	sentinel_init
	set gidf $dir/gidfile
	fileremove -f $gidf
	set proclist {}
	puts "$msg.0: Executing child script to prepare txns"
	berkdb debug_check
	set p [exec $tclsh_path $test_path/wrap.tcl txnscript.tcl \
	    $testdir/txnout $env_cmd $testfile $gidf $key $newdata2 &]
	lappend proclist $p
	watch_procs 5
	set f1 [open $testdir/txnout r]
	set r [read $f1]
	puts $r
	close $f1
	fileremove -f $testdir/txnout

	berkdb debug_check
	puts -nonewline "$msg.1: Running recovery ... "
	flush stdout
	berkdb debug_check
	set env [eval $env_cmd "-recover -verbose {recovery on}"]
	error_check_good dbenv-recover [is_valid_env $env] TRUE
	puts "complete"

	puts "$msg.2: getting txns from txn_recover"
	set txnlist [$env txn_recover]
	error_check_good txnlist_len [llength $txnlist] 1
	set tpair [lindex $txnlist 0]

	set gfd [open $gidf r]
	set ret [gets $gfd parentgid]
	close $gfd
	set txn [lindex $tpair 0]
	set gid [lindex $tpair 1]
	if { $op == "begin" } {
		puts "$msg.2: $op new txn"
	} else {
		puts "$msg.2: $op parent"
	}
	error_check_good gidcompare $gid $parentgid
	if { $op == "prepare" } {
		set gid [make_gid prepare_recover:$txn]
		set stat [catch {$txn $op $gid} ret]
		error_check_good prep_error $stat 1
		error_check_good prep_err \
		    [is_substr $ret "transaction already prepared"] 1
		error_check_good txn:prep_abort [$txn abort] 0
	} elseif { $op == "begin" } {
		set stat [catch {$env txn} ret]
		error_check_good begin_error $stat 1
		error_check_good begin_err \
		    [is_substr $ret "not yet committed transactions is incomplete"] 1
		error_check_good txn:prep_abort [$txn abort] 0
	} else {
		error_check_good txn:$op [$txn $op] 0
	}
	error_check_good envclose [$env close] 0
}

proc txn003_check { db key msg gooddata } {
	set kd [$db get $key]
	set data [lindex [lindex $kd 0] 1]
	error_check_good $msg $data $gooddata
}
