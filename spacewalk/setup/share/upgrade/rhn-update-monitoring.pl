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
use RHN::Utils;
use RHN::DataSource::Simple;

my $org_id = RHN::SatInstall->get_satellite_org_id();
my $db_connect = RHN::SatInstall->test_db_connection();
die "Could not connect to the database" unless $db_connect;

my $ds = new RHN::DataSource::Simple(-querybase => "scout_queries",
                                     -mode => 'scouts_for_org');
my $data = $ds->execute_query(-org_id => $org_id);
my ($scout) = grep { not $_->{SERVER_ID} } @{$data};

exit 0 unless $scout;

my ($ip, $vip) = ($scout->{IP}, $scout->{VIP});
my ($sn_id, $sc_id) = ($scout->{SAT_NODE_ID}, $scout->{ID});

if ($ip eq '127.0.0.1' or $vip eq '127.0.0.1') {
	my $hostname = Sys::Hostname::hostname;
	my $ip_addr = RHN::Utils::find_ip_address($hostname);

	my $dbh = RHN::DB->connect;

	my $sql1 = q{
        update rhn_sat_node
            set ip = :ip,
                last_update_user = 'upgrade',
                last_update_date = sysdate
            where ip = '127.0.0.1' and
                  recid = :recid
	};
	my $sql2 = q{
        update rhn_sat_cluster
            set vip = :vip,
                last_update_user = 'upgrade',
                last_update_date = sysdate
            where vip = '127.0.0.1' and
                  recid = :recid
	};

	$dbh->do_h($sql1,
		ip      => $ip_addr,
		recid   => $sn_id,
	);
	$dbh->do_h($sql2,
		vip     => $ip_addr,
		recid   => $sc_id,
	);
	$dbh->commit;
}
  
1;
