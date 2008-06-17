#!/usr/bin/perl

BEGIN
{
    unshift @INC, ".";
}

use strict;
use NOCpulse::BDB2;

sub list_eq
{
    my $l1 = shift;
    my $l2 = shift;

    if( ( scalar @$l1 ) != ( scalar @$l2 ) )
    {
	return 0;
    }

    my $i;
    while( $i < ( scalar @$l1 ) )
    {
	if( $l1->[$i] != $l2->[$i] )
	{
	    return 0;
	}
	$i++;
    }

    return 1;
}

sub verify
{
    my $label = shift;
    my $l1 = shift;
    my $l2 = shift;
    
    print "correct : ".join(", ", @{$l2})."\n";
    print "observed: ".join(", ", @{$l1})."\n";
    
    if( list_eq($l1, $l2) )
    {
	print "$label ok\n";
    }
    else
    {
	print "$label ERROR\n";
    }
    
}



sub do_tests
{
    my $db = shift;
    my $filename = shift;

    $db->insert($filename,  999999000, 1);
    $db->insert($filename,  999999100, 2);
    $db->insert($filename, 1000000000, 6);
    $db->insert($filename, 1000000100, 7);
    
    my ($last_t, $last_v) = $db->last($filename);

    print "last  = ($last_t, $last_v)\n";
    
    print "\n";
    
    my $ts;
    
    $ts = $db->fetch($filename,
		     999990000,
		     999999900, 1);
    
    verify("test1", $ts, [999999000, 1, 999999100, 2]);
    
    print "-" x 80 . "\n";
    
    $ts = $db->fetch($filename,
		     999990000,
		     1000001000, 1);
    
    verify("test2", $ts, [999999000, 1, 999999100, 2, 1000000000, 6, 1000000100, 7]);
    
    print "-" x 80 . "\n";
    
    $ts = $db->fetch($filename,
		     999999999,
		     1000001000, 1);
    
    verify("test3", $ts, [999999100, 2, 1000000000, 6, 1000000100, 7]);
    
    print "-" x 80 . "\n";
    
    $ts = $db->fetch($filename,
		     1000000000,
		     1000001000, 1);
    
    
    verify("test4", $ts, [1000000000, 6, 1000000100, 7]);
    
    print "-" x 80 . "\n";
    
    $ts = $db->fetch($filename,
		     1900000000,
		     1900001000, 1);
    
    verify("test5", $ts, [1000000100, 7]);
    
    print "-" x 80 . "\n";
    
    $ts = $db->fetch($filename,
		     1000000050,
		     1000001000, 1);
    
    verify("test6", $ts, [1000000000, 6, 1000000100, 7]);
    
    print "-" x 80 . "\n";
    
    $db->delete($filename, 1000000000);
    
    $ts = $db->fetch($filename,
		     1000000050,
		     1000001000, 1);
    
    verify("test7", $ts, [999999100, 2, 1000000100, 7]);
    
}

my $filename = "test";

unlink($filename);

my $db = NOCpulse::BDB2->new();

do_tests($db, $filename);

unlink($filename);
unlink($filename.".lock");
