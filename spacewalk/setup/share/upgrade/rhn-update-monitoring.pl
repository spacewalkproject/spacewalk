#!/usr/bin/perl

# This script fixes monitoring problem described in bug #511052
# Earlier Satellites (3.7) set rhn_sat_node.ip and rhn_sat_cluster.vip
# to '127.0.0.1' during installation / monitoring activation. These
# values need to be set to ip address of satellite for MonitoringAccessHandler.pm
# to operate properly.

use strict;
use warnings;

use Sys::Hostname;
use RHN::SatInstall;
use Spacewalk::Setup;

my $db_connect = RHN::SatInstall->test_db_connection();
die "Could not connect to the database" unless $db_connect;

my %answers;
my %opts;

$answers{'hostname'} = Sys::Hostname::hostname;
$opts{'upgrade'} = 1;

Spacewalk::Setup::update_monitoring_scout(\%opts, \%answers);
  
1;
