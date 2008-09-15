# See the file LICENSE for redistribution information.
#
# Copyright (c) 1996, 1997, 1998, 1999, 2000
#	Sleepycat Software.  All rights reserved.
#
#	$Id: ddoyscript.tcl,v 1.1.1.1 2002-01-11 00:21:38 apingel Exp $
#
# Deadlock detector script tester.
# Usage: ddoyscript dir lockerid numprocs
# dir: DBHOME directory
# lockerid: Lock id for this locker
# numprocs: Total number of processes running

source ./include.tcl
source $test_path/test.tcl
source $test_path/testutils.tcl

set usage "ddoyscript dir lockerid numprocs oldoryoung"

# Verify usage
if { $argc != 4 } {
	puts stderr "FAIL:[timestamp] Usage: $usage"
	exit
}

# Initialize arguments
set dir [lindex $argv 0]
set lockerid [ lindex $argv 1 ]
set numprocs [ lindex $argv 2 ]
set old_or_young [lindex $argv 3]

set myenv [berkdb env -lock -home $dir -create -mode 0644]
error_check_bad lock_open $myenv NULL
error_check_good lock_open [is_substr $myenv "env"] 1

# There are two cases here -- oldest/youngest or a ring locker.

if { $lockerid == 0 || $lockerid == [expr $numprocs - 1] } {
	set waitobj NULL
	set ret 0

	if { $lockerid == 0 } {
		set objid 2
		if { $old_or_young == "o" } {
			set waitobj [expr $numprocs - 1]
		}
	} else {
		if { $old_or_young == "y" } {
			set waitobj 0
		}
		set objid 4
	}

	# Acquire own read lock
	if {[catch {$myenv lock_get read $lockerid $lockerid} selflock] != 0} {
		puts $errorInfo
	} else {
		error_check_good selfget:$objid [is_substr $selflock $myenv] 1
	}

	# Acquire read lock
	if {[catch {$myenv lock_get read $lockerid $objid} lock1] != 0} {
		puts $errorInfo
	} else {
		error_check_good lockget:$objid [is_substr $lock1 $myenv] 1
	}

	tclsleep 10

	if { $waitobj == "NULL" } {
		# Sleep for a good long while
		tclsleep 90
	} else {
		# Acquire write lock
		if {[catch {$myenv lock_get write $lockerid $waitobj} lock2]
		    != 0} {
			puts $errorInfo
			set ret ERROR
		} else {
			error_check_good lockget:$waitobj \
			    [is_substr $lock2 $myenv] 1

			# Now release it
			if {[catch {$lock2 put} err] != 0} {
				puts $errorInfo
				set ret ERROR
			} else {
				error_check_good lockput:oy:$objid $err 0
			}
		}

	}

	# Release self lock
	if {[catch {$selflock put} err] != 0} {
		puts $errorInfo
		if { $ret == 0 } {
			set ret ERROR
		}
	} else {
		error_check_good selfput:oy:$lockerid $err 0
		if { $ret == 0 } {
			set ret 1
		}
	}

	# Release first lock
	if {[catch {$lock1 put} err] != 0} {
		puts $errorInfo
		if { $ret == 0 } {
			set ret ERROR
		}
	} else {
		error_check_good lockput:oy:$objid $err 0
		if { $ret == 0 } {
			set ret 1
		}
	}

} else {
	# Make sure that we succeed if we're locking the same object as
	# oldest or youngest.
	if { [expr $lockerid % 2] == 0 } {
		set mode read
	} else {
		set mode write
	}
	# Obtain first lock (should always succeed).
	if {[catch {$myenv lock_get $mode $lockerid $lockerid} lock1] != 0} {
		puts $errorInfo
	} else {
		error_check_good lockget:$lockerid [is_substr $lock1 $myenv] 1
	}

	tclsleep 30

	set nextobj [expr $lockerid + 1]
	if { $nextobj == [expr $numprocs - 1] } {
		set nextobj 1
	}

	set ret 1
	if {[catch {$myenv lock_get write $lockerid $nextobj} lock2] != 0} {
		if {[string match "*DEADLOCK*" $lock2] == 1} {
			set ret DEADLOCK
		} else {
			set ret ERROR
		}
	} else {
		error_check_good lockget:$nextobj [is_substr $lock2 $myenv] 1
	}

	# Now release the first lock
	error_check_good lockput:$lock1 [$lock1 put] 0

	if {$ret == 1} {
		error_check_bad lockget:$nextobj $lock2 NULL
		error_check_good lockget:$nextobj [is_substr $lock2 $myenv] 1
		error_check_good lockput:$lock2 [$lock2 put] 0
	}
}

puts $ret
error_check_good envclose [$myenv close] 0
exit
