#!/usr/bin/perl

use NOCpulse::TroubleTicket;

my $tt = LogTroubleTicket(30,'short 2','long',0,'update',3);
print "ticket id $tt\n";
$tt = LogTroubleTicket(30,'short 2','long',1,'update',3);
print "ticket id $tt\n";
$tt = LogTroubleTicket(30,'short 2','long',1,'update');
print "ticket id $tt\n";
$tt = LogTroubleTicket(30,'short 2','long',1);
print "ticket id $tt\n";
$tt = LogTroubleTicket(30,'short 2','long');
print "ticket id $tt\n";
