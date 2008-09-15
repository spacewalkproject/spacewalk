# See the file LICENSE for redistribution information.
#
# Copyright (c) 1996-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: lock003.tcl,v 1.1.1.1 2002-01-11 00:21:38 apingel Exp $
#
# Exercise multi-process aspects of lock.  Generate a bunch of parallel
# testers that try to randomly obtain locks;  make sure that the locks
# correctly protect corresponding objects.
proc lock003 { dir {iter 500} {max 1000} {procs 5} {ldegree 5} {objs 75} \
	{reads 65} {wait 1} {conflicts { 3 0 0 0 0 0 1 0 1 1}} {seeds {}} } {
	source ./include.tcl

	puts "Lock003: Multi-process random lock test"

	# Clean up after previous runs
	env_cleanup $dir

	# Open/create the lock region
	set e [berkdb env -create -lock -home $dir]
	error_check_good env_open [is_substr $e env] 1

	set ret [$e close]
	error_check_good env_close $ret 0

	# Now spawn off processes
	set pidlist {}

	for { set i 0 } {$i < $procs} {incr i} {
		if { [llength $seeds] == $procs } {
			set s [lindex $seeds $i]
		}
		puts "$tclsh_path\
		    $test_path/wrap.tcl \
		    lockscript.tcl $dir/$i.lockout\
		    $dir $iter $objs $wait $ldegree $reads &"
		set p [exec $tclsh_path $test_path/wrap.tcl \
		    lockscript.tcl $testdir/lock003.$i.out \
		    $dir $iter $objs $wait $ldegree $reads &]
		lappend pidlist $p
	}

	puts "Lock003: $procs independent processes now running"
	watch_procs 30 10800

	# Check for test failure
	set e [eval findfail [glob $testdir/lock003.*.out]]
	error_check_good "FAIL: error message(s) in log files" $e 0

	# Remove log files
	for { set i 0 } {$i < $procs} {incr i} {
		fileremove -f $dir/lock003.$i.out
	}
}

# Create and destroy flag files to show we have an object locked, and
# verify that the correct files exist or don't exist given that we've
# just read or write locked a file.
proc lock003_create { rw obj } {
	source ./include.tcl

	set pref $testdir/L3FLAG
	set f [open $pref.$rw.[pid].$obj w]
	close $f
}

proc lock003_destroy { obj } {
	source ./include.tcl

	set pref $testdir/L3FLAG
	set f [glob -nocomplain $pref.*.[pid].$obj]
	error_check_good l3_destroy [llength $f] 1
	fileremove $f
}

proc lock003_vrfy { rw obj } {
	source ./include.tcl

	set pref $testdir/L3FLAG
	if { [string compare $rw "write"] == 0 } {
		set fs [glob -nocomplain $pref.*.*.$obj]
		error_check_good "number of other locks on $obj" [llength $fs] 0
	} else {
		set fs [glob -nocomplain $pref.write.*.$obj]
		error_check_good "number of write locks on $obj" [llength $fs] 0
	}
}

