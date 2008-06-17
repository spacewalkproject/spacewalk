# See the file LICENSE for redistribution information.
#
# Copyright (c) 2001
#	Sleepycat Software.  All rights reserved.
#
# $Id: bigfile001.tcl,v 1.1.1.1 2002-01-11 00:21:38 apingel Exp $
#
# Big file test.
# Create a database greater than 4 GB in size.  Close, verify.  Grow
# the database somewhat.  Close, reverify.  Lather, rinse, repeat.
# Since it will not work on all systems, this test is not run by default.
proc bigfile001 { method \
    { itemsize 4096 } { nitems 1048576 } { growby 5000 } { growtms 2 } args } {
	source ./include.tcl

	set args [convert_args $method $args]
	set omethod [convert_method $method]

	puts "Bigfile: $method ($args) $nitems * $itemsize bytes of data"

	env_cleanup $testdir

	# Create the database.  Use 64K pages;  we want a good fill
	# factor, and page size doesn't matter much.  Use a 50MB
	# cache;  that should be manageable, and will help
	# performance.
	set dbname TESTDIR/big.db

	set db [eval {berkdb_open -create} {-pagesize 65536 \
	    -cachesize {0 50000000 0}} $omethod $args $dbname]
	error_check_good db_open [is_valid_db $db] TRUE

	puts -nonewline "\tBigfile.a: Creating database...0%..."
	flush stdout

	set data [string repeat z $itemsize]

	set more_than_ten_already 0
	for { set i 0 } { $i < $nitems } { incr i } {
		set key key[format %08u $i]

		error_check_good db_put($i) [$db put $key $data] 0

		if { $i % 5000 == 0 } {
			set pct [expr 100 * $i / $nitems]
			puts -nonewline "\b\b\b\b\b"
			if { $pct >= 10 } {
				if { $more_than_ten_already } {
					puts -nonewline "\b"
				} else {
					set more_than_ten_already 1
				}
			}

			puts -nonewline "$pct%..."
			flush stdout
		}
	}
	puts "\b\b\b\b\b\b100%..."
	error_check_good db_close [$db close] 0

	puts "\tBigfile.b: Verifying database..."
	error_check_good verify \
	    [verify_dir $testdir "\t\t" 0 0 1 50000000] 0

	puts "\tBigfile.c: Grow database $growtms times by $growby items"

	for { set j 0 } { $j < $growtms } { incr j } {
		set db [eval {berkdb_open} {-cachesize {0 50000000 0}} $dbname]
		error_check_good db_open [is_valid_db $db] TRUE
		puts -nonewline "\t\tBigfile.c.1: Adding $growby items..."
		flush stdout
		for { set i 0 } { $i < $growby } { incr i } {
			set key key[format %08u $i].$j
			error_check_good db_put($j.$i) [$db put $key $data] 0
		}
		error_check_good db_close [$db close] 0
		puts "done."

		puts "\t\tBigfile.c.2: Verifying database..."
		error_check_good verify($j) \
		    [verify_dir $testdir "\t\t\t" 0 0 1 50000000] 0
	}
}
