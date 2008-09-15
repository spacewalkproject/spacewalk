# See the file LICENSE for redistribution information.
#
# Copyright (c) 2000-2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: sdb010.tcl,v 1.1.1.1 2002-01-11 00:21:39 apingel Exp $
#
# Subdatabase Test 10 {access method}
# Test of dbremove
proc subdb010 { method args } {
	global errorCode
	source ./include.tcl

	set args [convert_args $method $args]
	set omethod [convert_method $method]

	puts "Subdb010: Test of DB->remove() and DB->truncate"

	if { [is_queue $method] == 1 } {
		puts "\tSubdb010: Skipping for method $method."
		return
	}

	cleanup $testdir NULL

	set testfile $testdir/subdb010.db
	set testdb DATABASE
	set testdb2 DATABASE2

	set db [eval {berkdb_open -create -truncate -mode 0644} $omethod \
	    $args $testfile $testdb]
	error_check_good db_open [is_valid_db $db] TRUE
	error_check_good db_close [$db close] 0

	puts "\tSubdb010.a: Test of DB->remove()"
	error_check_good file_exists_before [file exists $testfile] 1
	error_check_good db_remove [berkdb dbremove $testfile $testdb] 0

	# File should still exist.
	error_check_good file_exists_after [file exists $testfile] 1

	# But database should not.
	set ret [catch {eval berkdb_open $omethod $args $testfile $testdb} res]
	error_check_bad open_failed ret 0
	error_check_good open_failed_ret [is_substr $errorCode ENOENT] 1

	puts "\tSubdb010.b: Setup for DB->truncate()"
	# The nature of the key and data are unimportant; use numeric key
	# so record-based methods don't need special treatment.
	set key1 1
	set key2 2
	set data1 [pad_data $method data1]
	set data2 [pad_data $method data2]

	set db [eval {berkdb_open -create -mode 0644} $omethod \
	    $args $testfile $testdb]
	error_check_good db_open [is_valid_db $db] TRUE
	error_check_good dbput [$db put $key1 $data1] 0

	set db2 [eval {berkdb_open -create -mode 0644} $omethod \
	    $args $testfile $testdb2]
	error_check_good db_open [is_valid_db $db2] TRUE
	error_check_good dbput [$db2 put $key2 $data2] 0

	error_check_good db_close [$db close] 0
	error_check_good db_close [$db2 close] 0

	puts "\tSubdb010.c: truncate"
	#
	# Return value should be 1, the count of how many items were
	# destroyed when we truncated.
	set db [eval {berkdb_open -create -mode 0644} $omethod \
	    $args $testfile $testdb]
	error_check_good db_open [is_valid_db $db] TRUE
	error_check_good trunc_subdb [$db truncate] 1
	error_check_good db_close [$db close] 0

	puts "\tSubdb010.d: check"
	set db [berkdb_open $testfile $testdb]
	error_check_good db_open [is_valid_db $db] TRUE
	set dbc [$db cursor]
	error_check_good db_cursor [is_valid_cursor $dbc $db] TRUE
	set kd [$dbc get -first]
	error_check_good trunc_dbcget [llength $kd] 0
	error_check_good dbcclose [$dbc close] 0

	set db2 [berkdb_open $testfile $testdb2]
	error_check_good db_open [is_valid_db $db2] TRUE
	set dbc [$db2 cursor]
	error_check_good db_cursor [is_valid_cursor $dbc $db2] TRUE
	set kd [$dbc get -first]
	error_check_bad notrunc_dbcget1 [llength $kd] 0
	set kd [$dbc get -next]
	error_check_good notrunc_dbget2 [llength $kd] 0
	error_check_good dbcclose [$dbc close] 0

	error_check_good db_close [$db close] 0
	error_check_good db_close [$db2 close] 0
	puts "\tSubdb010 succeeded."
}
