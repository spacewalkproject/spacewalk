#!/usr/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..29\n"; }
END {print "not ok 1\n" unless $loaded;}
use DB_File::Lock qw( O_CREAT O_RDWR $DB_HASH );
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $TEST_NUM = 2;

sub report_result {
	print ( $_[0] ? "ok $TEST_NUM\n" : "not ok $TEST_NUM\n" );
	if ($ENV{TEST_VERBOSE} and not $_[0]) { print "Error is '$!'\n" }
	$TEST_NUM++;
}

sub permissions_of_file { return (stat(shift))[2] & 0777 }

my $file1 = 'db/db1';
my $file2 = 'db/db2';
my $file1_lock = $file1 . ".lock";
my $file2_lock = $file2 . ".lock";
unlink $file1;
unlink $file2;
unlink $file1_lock;
unlink $file2_lock;

## 2: Check if the export worked
report_result( O_CREAT != 0 );

## 3-6: Create a simple database and test permissions
report_result( tie %hash1, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, "write" );
report_result( permissions_of_file($file1_lock) == 0600 );
report_result( untie %hash1 );
report_result( unlink($file1) and unlink($file1_lock) );

## 7-10: Create a simple database and test permissions again
report_result( tie %hash1, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0664, $DB_HASH, "write" );
report_result( permissions_of_file($file1_lock) == 0666 );
report_result( untie %hash1 );
report_result( unlink($file1) and unlink($file1_lock) );

## 11-14: Test the lockfile_name and lockfile_mode options
report_result( tie %hash1, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0664, $DB_HASH,
	{ mode => "write", lockfile_name => $file2_lock, lockfile_mode => 0623 } );
report_result( permissions_of_file($file2_lock) == 0623 );
report_result( untie %hash1 );
report_result( unlink($file1) and unlink($file2_lock) );

## 15-22: See that flock is really getting called
my $nonblock_write = { mode => "write", nonblocking => 1 };
my $nonblock_read  = { mode => "read",  nonblocking => 1 };
tie %hash1, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, $nonblock_write;  # create the DB file
untie %hash1;
my $pid = fork();
if ( not defined $pid ) {
	print STDERR "fork failed: skipping tests 15-22\n";
	$TEST_NUM += 9;
} elsif ( not $pid ) { # child
	report_result( tie %hash1, 'DB_File::Lock', $file1, O_RDWR, 0600, $DB_HASH, $nonblock_read );
	report_result( tie %hash2, 'DB_File::Lock', $file1, O_RDWR, 0600, $DB_HASH, $nonblock_read );
	sleep(3);
	$TEST_NUM += 2;
	report_result( untie %hash1 and untie %hash2 );
	exit(0);
} else { # parent
	sleep(1);
	$TEST_NUM += 2;
	report_result( not tie %hash3, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, $nonblock_write );
	report_result( not defined %hash3 ); # double check and satisfy -w about %hash3
	$TEST_NUM += 1;
	report_result( wait() == $pid );
	report_result( tie %hash3, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, $nonblock_write );
	report_result( untie %hash3 );
	report_result( unlink($file1) and unlink($file1_lock) );
}

## 24-30: See that data can really be written
report_result( tie %hash1, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, $nonblock_write );
$hash1{a} = 1;
$hash1{b} = 2;
report_result( $hash1{a} == 1 and $hash1{b} == 2 );
report_result( untie %hash1 );
report_result( tie %hash2, 'DB_File::Lock', $file1, O_CREAT|O_RDWR, 0600, $DB_HASH, $nonblock_read );
report_result( $hash2{a} == 1 and $hash2{b} == 2 );
report_result( untie %hash2 );
report_result( unlink($file1) and unlink($file1_lock) );

