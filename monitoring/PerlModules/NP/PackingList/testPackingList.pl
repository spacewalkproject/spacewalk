#!/usr/bin/perl

use strict;
use Data::Dumper;
use NOCpulse::PackingList;

my $packing_list= new NOCpulse::PackingList;
$packing_list->absorb('MANIFEST');

#print "required users:\n" , &Dumper($packing_list->required_users), "\n";
#print "required packages:\n" , &Dumper($packing_list->required_packages), "\n";
#print "remove packages:\n" , &Dumper($packing_list->remove_packages), "\n";
print "install packages:\n" , &Dumper($packing_list->install_packages), "\n";

print "\n\nHere is the transcribed packing list:\n";
$packing_list->transcribe("$$.dat");
print `cat $$.dat`;
 
print "Please verify output in $$.dat\n";
