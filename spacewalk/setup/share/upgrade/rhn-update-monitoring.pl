#!/usr/bin/perl

# This script fixes monitoring problem described in bug #511052
# Earlier Satellites (3.7) set rhn_sat_node.ip and rhn_sat_cluster.vip
# to '127.0.0.1' during installation / monitoring activation. These
# values need to be set to ip address of satellite for MonitoringAccessHandler.pm
# to operate properly.

use strict;
use warnings;

use Sys::Hostname;
use PXT::Config;
use Spacewalk::Setup;
use RHN::SatInstall;

my $db_connect = RHN::SatInstall->test_db_connection();
die "Could not connect to the database" unless $db_connect;

my %answers;
my %opts;

$answers{'hostname'} = Sys::Hostname::hostname;
$answers{'db-backend'} = PXT::Config->get('db_backend');
$answers{'db-host'} = PXT::Config->get('db_host');
$answers{'db-port'} = PXT::Config->get('db_port');
$answers{'db-name'} = PXT::Config->get('db_name');
$answers{'db-user'} = PXT::Config->get('db_user');
$answers{'db-password'} = PXT::Config->get('db_password');

$opts{'upgrade'} = 1;

1;
