# See the file LICENSE for redistribution information.
#
# Copyright (c) 1999-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: sdb011.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# SubDB Test 11 {access method}
# Create 1 db with many large subdbs.
# Test subdatabases with overflow pages.
proc subdb011 { method {ndups 13} {nsubdbs 10} args} {
	global names
	source ./include.tcl

	set args [convert_args $method $args]
	set omethod [convert_method $method]

	if { [is_queue $method] == 1 || [is_fixed_length $method] == 1 } {
		puts "Subdb011: skipping for method $method"
		return
	}

	puts "Subdb011: $method ($args) overflow dups with \
	    filename=key filecontents=data pairs"

	# Create the database and open the dictionary
	set testfile $testdir/subdb011.db

	cleanup $testdir NULL

	# Here is the loop where we put and get each key/data pair
	set file_list [get_file_list]
	puts "\tSubdb011.a: Create each subdb and dups"
	set slist {}
	set i 0
	set count 0
	foreach f $file_list {
		set i [expr $i % $nsubdbs]
		if { [is_record_based $method] == 1 } {
			set key [expr $count + 1]
			set names([expr $count + 1]) $f
		} else {
			set key $f
		}
		# Should really catch errors
		set fid [open $f r]
		fconfigure $fid -translation binary
		set filecont [read $fid]
		set subdb subdb$i
		lappend slist $subdb
		close $fid
		set db [eval {berkdb_open -create -mode 0644} \
		    $args {$omethod $testfile $subdb}]
		error_check_good dbopen [is_valid_db $db] TRUE
		for {set dup 0} {$dup < $ndups} {incr dup} {
			set data $dup:$filecont
			set ret [eval {$db put} {$key \
			    [chop_data $method $data]}]
			error_check_good put $ret 0
		}
		error_check_good dbclose [$db close] 0
		incr i
		incr count
	}

	puts "\tSubdb011.b: Verify overflow pages"
	foreach subdb $slist {
		set db [eval {berkdb_open -create -mode 0644} \
		    $args {$omethod $testfile $subdb}]
		error_check_good dbopen [is_valid_db $db] TRUE
		set stat [$db stat]

		# What everyone else calls overflow pages, hash calls "big
		# pages", so we need to special-case hash here.  (Hash
		# overflow pages are additional pages after the first in a
		# bucket.)
		if { [string compare [$db get_type] hash] == 0 } {
			error_check_bad overflow \
			    [is_substr $stat "{{Number of big pages} 0}"] 1
		} else {
			error_check_bad overflow \
			    [is_substr $stat "{{Overflow pages} 0}"] 1
		}
		error_check_good dbclose [$db close] 0
	}

	puts "\tSubdb011.c: Delete subdatabases"
	for {set i $nsubdbs} {$i > 0} {set i [expr $i - 1]} {
		#
		# Randomly delete a subdatabase
		set sindex [berkdb random_int 0 [expr $i - 1]]
		set subdb [lindex $slist $sindex]
		#
		# Delete the one we did from the list
		set slist [lreplace $slist $sindex $sindex]
		error_check_good file_exists_before [file exists $testfile] 1
		error_check_good db_remove [berkdb dbremove $testfile $subdb] 0
	}
}

