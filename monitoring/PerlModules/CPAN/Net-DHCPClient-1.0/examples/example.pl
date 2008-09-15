#!/usr/bin/perl 

##use lib '..';

use strict;
use Net::DHCPClient;

my %options;

my $i;

my $a = new Net::DHCPClient( macaddr => '00:90:27:17:c8:dc', interface => 'eth0', debug => 1 );

$i = 0;
while ( $i == 0 ) {
 print "Sending discover\n";
 $i = $a->discover( 61 => '00 90 27 17 c8 dc' );
 print "$i ", $a->reply, "\n";
}

$i = 0;
while ( $i == 0 ) {
 print "Sending request\n";
 $i = $a->request( 61 => '00 90 27 17 c8 dc' );
 print "$i ", $a->reply, "\n";
}

$i = 0;
while ( $i == 0 ) {
 print "Sending release\n";
 $i = $a->release();
 print "$i ", $a->reply, "\n";
}
