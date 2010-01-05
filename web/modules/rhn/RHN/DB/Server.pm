#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;

package RHN::DB::Server;

use RHN::DB;
use RHN::Org;
use RHN::DB::Channel;
use RHN::DB::Server;
use RHN::DB::Server::CdDevice;
use RHN::DB::Server::HwDevice;
use RHN::DB::Server::StorageDevice;
use RHN::DB::Server::NetInfo;
use RHN::DB::Server::NetInterface;
use RHN::DB::TableClass;

use RHN::DataSource::Errata;
use RHN::DataSource::Package;
use RHN::Package;
use RHN::Entitlements;
use RHN::Manifest;
use RHN::Channel;
use Data::Dumper;
use Frontier::RPC2;
use Digest::MD5;
use Date::Parse;

use Scalar::Util;

use PXT::Config;
use PXT::Utils;

use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

use Carp;

use RHN::Utils;
use RHN::Exception qw/throw/;


# fields in the rhnServer table
my @s_fields = (qw/ID DIGITAL_SERVER_ID SERVER_ARCH_ID OS RELEASE/,
                qw/NAME DESCRIPTION SECRET INFO ORG_ID CREATED:longdate creator_id auto_update auto_deliver last_boot running_kernel/);


my @si_fields = qw/server_id checkin:longdate checkin_counter/;

# fields in the rhnRam table
my @r_fields = qw/ID SERVER_ID RAM SWAP/;

# fields in the rhnCpu table
my @c_fields = (qw/ID SERVER_ID CPU_ARCH_ID BOGOMIPS CACHE FAMILY/,
                qw/MHZ STEPPING FLAGS MODEL VERSION VENDOR/,
                qw/NRCPU ACPIVERSION APIC APMVERSION CHIPSET/);

# fields in the rhnServerArch table
# One weird thing:  the arch in the rhnCpu table can be differnent
# than the one in the rhnServer table.  This is either a bug, or 
# we're simply setting the rhnCpu.arch field to be the minimum value
# for that family of processors.  We should *really* figure out why
# this is happening...
my @a_fields = (qw/ID NAME LABEL/);

my @dmi_fields  = (qw/VENDOR SYSTEM PRODUCT BIOS_VENDOR BIOS_RELEASE BIOS_VERSION ASSET BOARD/);


# placeholder for now... will probably store more info about proxy servers in the future...
my @proxy_fields = (qw/SERVER_ID/);

# Spacewalk stuff
my @satellite_fields = (qw/SERVER_ID/);

# fields in rhnServerLocation table.  soon to change?
my @l_fields = (qw/ID SERVER_ID RACK ROOM MACHINE BUILDING ADDRESS1 ADDRESS2 CITY STATE COUNTRY/);

# the read only fields from the arrays above
# Note:  these should right now only come from @s_fields
my @rw_fields = qw/name description location_rack location_room location_machine location_building location_address1 location_address2 location_city location_state location_country auto_update auto_deliver/;

my %rw_fields = map {$_ => 1} @rw_fields;



my $s_table = new RHN::DB::TableClass("rhnServer", "S", "", @s_fields);
my $si_table = new RHN::DB::TableClass("rhnServerInfo", "SI", "", @si_fields);
my $r_table = new RHN::DB::TableClass("rhnRam", "R", "memory", @r_fields);
my $c_table = new RHN::DB::TableClass("rhnCpu", "C", "cpu", @c_fields);
my $a_table = new RHN::DB::TableClass("rhnServerArch", "SA", "cpu_arch", @a_fields);
my $l_table = new RHN::DB::TableClass("rhnServerLocation", "L", "location", @l_fields);
my $dmi_table = new RHN::DB::TableClass("rhnServerDMI", "D", "dmi", @dmi_fields);
my $proxy_table = new RHN::DB::TableClass("rhnProxyInfo", "P", "proxy", @proxy_fields);
my $satellite_table = new RHN::DB::TableClass("rhnSatelliteInfo", "SAT", "satellite", @satellite_fields);

my $j = $s_table->create_join(
   [$r_table, $si_table, $c_table, $a_table, $l_table, $dmi_table, $proxy_table, $satellite_table],
   {
      "rhnServer" =>
         {
            "rhnServer" => ["ID","ID"],
            "rhnServerInfo" => ["ID","SERVER_ID"],
            "rhnRam" => ["ID","SERVER_ID"],
            "rhnCpu" => ["ID", "SERVER_ID"],
            "rhnServerArch" => ["SERVER_ARCH_ID", "ID" ],
	    "rhnServerLocation" => ["ID","SERVER_ID"],
	    "rhnServerDMI" => ["ID", "SERVER_ID"],
	    "rhnProxyInfo" => ["ID", "SERVER_ID"],
	    "rhnSatelliteInfo" => ["ID", "SERVER_ID"],
         }
   },
   { rhnRam => "(+)",
     rhnCpu => "(+)",
     rhnServerLocation => "(+)",
     rhnServerDMI => "(+)",
     rhnProxyInfo => "(+)",
     rhnSatelliteInfo => "(+)",
   });


############################
# Server object methods
############################

sub applet_activated {
  my $self = shift;

  # never, ever select the uuid.  if you think you need it for something, you're wrong.
  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnServerUuid
 WHERE server_id = :server_id
EOQ

  $sth->execute_h(server_id => $self->id);
  my ($activated) = $sth->fetchrow;
  $sth->finish;

  return $activated;
}

# get the config file list post position-resolution...
sub get_resolved_files {
  my $self = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => 'config_queries',
				       -mode => 'configfiles_for_system',
				      );

  my $files = $ds->execute_query(-sid => $self->id);
  my %by_path;

  foreach my $revision (@{$files}) {
    if (not exists $by_path{$revision->{PATH}}) {
      $by_path{$revision->{PATH}} = $revision;
    }
  }

  my @ret;
  foreach my $path (sort keys %by_path) {
    push @ret, $by_path{$path};
  }

  return @ret;
}

sub get_cpu_arch_name {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT CA.name
  FROM rhnCpuArch CA,
       rhnCpu C
 WHERE C.server_id = :server_id
   AND C.cpu_arch_id = CA.id
EOQ

  $sth->execute_h(server_id => $self->id);

  my ($cpu_arch_name) = $sth->fetchrow;
  $sth->finish;
  return $cpu_arch_name;
}

sub get_latest_action_named {
  my $self = shift;
  my $action_name = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT A.id
  FROM rhnAction A,
       rhnServerAction SA
 WHERE SA.server_id = :server_id
   AND SA.action_id = A.id
   AND A.name = :action_name
ORDER BY SA.created DESC
EOQ

  $sth->execute_h(server_id => $self->id,
		  action_name => $action_name,
		 );

  my ($action_id) = $sth->fetchrow;
  $sth->finish;

  return unless $action_id;

  my $action = RHN::Action->lookup(-id => $action_id);
  die "no action object for action_id $action_id" unless $action;

  return $action;
}

sub remove_custom_value {
  my $self = shift;
  my $key_id = shift;

  die "no key id" unless $key_id;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
DELETE FROM rhnServerCustomDataValue
      WHERE server_id = :server_id
        AND key_id = :key_id
EOQ

  $sth->execute_h(server_id => $self->id, key_id => $key_id);

  $dbh->commit;
}

sub set_custom_value {
  my $self = shift;

  foreach my $param (@_) {
    die "$param tainted!" if Scalar::Util::tainted($param);
  }

  my %params = validate(@_, {user_id => 1, key_label => 1, value => 0, transaction => 0} );

  my $dbh = $params{transaction} || RHN::DB->connect();
  $dbh->call_procedure('rhn_server.set_custom_value', $self->id, $params{user_id}, $params{key_label}, $params{value});

  $dbh->commit unless $params{transaction};
}

sub bulk_set_custom_value {
  my $class = shift;
  my %params = validate(@_, {set_label => 1, user_id => 1, key_label => 1, value => 0});

  my $dbh = RHN::DB->connect();
  my $success_count = $dbh->call_function('rhn_server.bulk_set_custom_value', $params{key_label}, $params{value}, $params{set_label}, $params{user_id});
 warn "Success COunt = " . $success_count;
  $dbh->commit;
  return $success_count;
}

sub bulk_remove_custom_value {
  my $class = shift;
  my %params = validate(@_, {set_label => 1, user_id => 1, key_id => 1});

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
DELETE FROM rhnServerCustomDataValue
      WHERE server_id IN (SELECT element FROM rhnSet WHERE user_id = :user_id AND label = :set_label)
        AND rhn_server.system_service_level(server_id, 'provisioning') = 1
        AND key_id = :key_id
EOQ

  $sth->execute_h(%params);
  $dbh->commit;
}

sub get_custom_value {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, key_id => 1});

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT CDK.label AS KEY,
       SCDV.value AS VALUE,
       TO_CHAR(SCDV.modified, 'YYYY-MM-DD HH24:MI:SS') AS LAST_MODIFIED,
       TO_CHAR(SCDV.created, 'YYYY-MM-DD HH24:MI:SS') AS CREATED,
       wc_creator.login AS CREATED_BY,
       wc_modifier.login AS LAST_MODIFIED_BY
  FROM web_contact wc_creator,
       web_contact wc_modifier,
       rhnCustomDataKey CDK,
       rhnServerCustomDataValue SCDV
 WHERE CDK.id = :key_id
   AND SCDV.server_id = :server_id
   AND CDK.id = SCDV.key_id
   AND SCDV.created_by = wc_creator.id (+)
   AND SCDV.last_modified_by = wc_modifier.id (+)
EOQ

  $sth->execute_h(server_id => $params{server_id}, key_id => $params{key_id});

  my $ret = $sth->fetchrow_hashref;
  $sth->finish;

  return $ret;
}

sub version_of_package_installed {
  my $self = shift;
  my $name = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT PE.epoch, PE.version, PE.release
  FROM rhnPackageEVR PE,
       rhnServerPackage SP
 WHERE SP.evr_id = PE.id
   AND SP.name_id = lookup_package_name(?)
   and SP.server_id = ?
EOS
  $sth->execute($name, $self->id);
  my ($result) = $sth->fetchrow_hashref;
  $sth->finish;

  return $result;
}

sub up2date_version_at_least {
  my $self = shift;
  my %ver_info = @_;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  PE.epoch, PE.version, PE.release, PN.name
  FROM  rhnPackageEVR PE, rhnPackageName PN, rhnServerPackage SP
 WHERE  SP.server_id = ?
   AND  SP.name_id = PN.id
   AND  ((PN.name = 'rhn-check')
    OR   (PN.name = 'up2date'))
   AND  SP.evr_id = PE.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  #PXT::Debug->log(4, "query:  $query");
  #PXT::Debug->log(4, "id:  ". $self->id);

  my @row = $sth->fetchrow;
  $sth->finish;

  die "no up2date" unless (@row);

  #PXT::Debug->log(4, "epoch:  $row[0]\nversion:  $row[1]\nrelease:  $row[2]\n");

  if ($row[3] eq 'rhn-check') {
     return 1; 
  }

  my $cmp = RHN::DB::Package->vercmp($row[0] || 0, $row[1] || 0, $row[2] || 0,
				     $ver_info{epoch} || 0, $ver_info{version} || 0, $ver_info{release} || 0);

  #PXT::Debug->log(4, "up2date cmp value:  $cmp");

  if ($cmp eq 0 or $cmp eq 1) {
    return 1;
  }
  else {
    #PXT::Debug->log(4, "returning undef...");
    return 0;
  }
}

sub is_proxy {
  my $self = shift;

  if (defined $self->{__proxy_server_id__}) {
    return 1;
  }
  else {
    return;
  }
}

sub is_satellite {
  my $self = shift;

  if (defined $self->{__satellite_server_id__}) {
    return 1;
  }
  else {
    return;
  }
}

sub is_virtual {
  my $self = shift;

  if (defined $self-> virtual_guest_details()) {
    return 1;
  }
  else {
    return;
  }
}

sub is_virtual_host {
  my $self = shift;

  if (defined $self-> virtual_host_details() || 
        ($self -> has_entitlement("virtualization_host") ||
         $self -> has_entitlement("virtualization_host_platform"))) {
    return 1;
  }
  else {
    return;
  }
}

sub has_virtualization_entitlement {
  my $self = shift;

  if ($self -> has_entitlement("virtualization_host") ||
         $self -> has_entitlement("virtualization_host_platform")) {
    return 1;
  }
  else {
    return;
  }
}

# If the system is a proxy, return array of (epoch, version, release)
sub proxy_evr {
  my $self_or_class = shift;
  my $sid;

  if (ref $self_or_class and $self_or_class->isa('RHN::Server')) {
    $sid = $self_or_class->id;
  }
  else {
    $sid = shift;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT PE.epoch, PE.version, PE.release
  FROM rhnPackageEVR PE, rhnProxyInfo PI
 WHERE PI.server_id = :sid
   AND PI.proxy_evr_id = PE.id
EOQ

  $sth->execute_h(sid => $sid);
  my @evr = $sth->fetchrow;
  $sth->finish;

  return map { $_ || 0 } @evr; # do not return undefs
}

sub add_system_tag {
  my $self = shift;
  my %params = validate(@_, {tagname => 1, ss_id => 0, transaction => 0});

  my $tagname = $params{tagname};
  my $snapshot_id = $params{ss_id};
  my $transaction = $params{transaction};

  my $dbh = $transaction || RHN::DB->connect();

  my $retry = 0;
  while (not $snapshot_id and $retry < 2) {
    my $sth;
    my $query;
    $query = <<EOQ;
SELECT id
  FROM rhnSnapshot
 WHERE server_id = :server_id
ORDER BY id DESC
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute_h(server_id => $self->id);

    ($snapshot_id) = $sth->fetchrow;
    $sth->finish;
    if (not defined $snapshot_id) {
      RHN::Server->snapshot_server(-server_id => $self->id, -reason => "Initial snapshot");
    }
    $retry++;
  }


  $transaction = RHN::SystemSnapshot->add_tag_to_snapshot(org_id => $self->org_id,
							  snapshot_id => $snapshot_id,
							  tag_name => $tagname,
							  transaction => $dbh,
							 );

  unless ($transaction) {
    $dbh->commit;
  }

  return $dbh;
}



sub proxy_channel_by_version {
  my $self = shift;
  my %params = validate(@_, { version => { type => Params::Validate::SCALAR } });

  my @potential_chans = RHN::Channel->proxy_channels_by_version(-version => $params{version});

  die "no potential proxy channels for this server" unless @potential_chans;

  my $num_potentials = scalar @potential_chans;

  my $base_channel_id = $self->base_channel_id;
  die "no base channel!?" unless $base_channel_id;

  my $query = sprintf(<<EOQ, join(", ", map {":chan$_"} (1..$num_potentials)));
SELECT DISTINCT C.id AS CHANNEL_ID, C.label AS CHANNEL_LABEL
  FROM rhnChannel C
 WHERE C.label IN (%s)
   AND C.parent_channel = :base_channel_id
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);

  my %args = (base_channel_id => $base_channel_id);
  foreach my $placeholder (map {"chan$_"} (1..$num_potentials)) {
    $args{$placeholder} = pop @potential_chans;
  }

  $sth->execute_h(%args);

  my $proxy_channel_info = $sth->fetchrow_hashref;
  $sth->finish;

  throw ("proxy_no_proxy_child_channel") unless $proxy_channel_info;
  return $proxy_channel_info;
}


sub activate_proxy {
  my $self = shift;
  my %params = validate(@_, {transaction => 0, version => 0});

  my $transaction = $params{transaction};
  my $version  = $params{version} || '1.1';

  my $dbh = $transaction || RHN::DB->connect();
  my $query;
  my $sth;

  if ($self->is_satellite()) {
    throw("proxy_system_is_satellite");
  }

  $query = <<EOQ;
DELETE FROM rhnProxyInfo WHERE server_id = ?
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  $query = <<EOQ;
SELECT * FROM rhnServer WHERE id = ?
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @row = $sth->fetchrow;
  $sth->finish;

  $query = <<EOQ;
INSERT INTO  rhnProxyInfo (server_id, proxy_evr_id)
     VALUES  (:server_id, lookup_evr(NULL, :version, '1'))
EOQ

  $sth = $dbh->prepare($query);

  $sth->execute_h(server_id => $self->id, version => $version);

  # In spacewalk that is all, for satellite we subscribe the proxy channel
  if (PXT::Config->get('subscribe_proxy_channel')) {
    my $proxy_chan_info = $self->proxy_channel_by_version(-version => $version);
    my $proxy_label = $proxy_chan_info->{CHANNEL_LABEL};

    if (not $proxy_label) {
      $dbh->rollback;
      throw '(proxy_no_proxy_child_channel)';
    }
    $self->subscribe_to_channel($proxy_label, $dbh);
  }

  unless ($transaction) {
    $dbh->commit;
  }

  return $dbh;
}



sub deactivate_proxy {
  my $self = shift;
  my $transaction = shift;

  my $dbh = $transaction || RHN::DB->connect();

  my $query;
  my $sth;

  $query = <<EOQ;
DELETE FROM  rhnProxyInfo
      WHERE  server_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  $query = <<EOQ;
  SELECT CFM.channel_id
    FROM rhnServerChannel SC, rhnChannelFamilyMembers CFM, rhnChannelFamily CF
   WHERE SC.server_id = ?
     AND CF.label = 'rhn-proxy'
     AND CF.id = CFM.channel_family_id
     AND CFM.channel_id = SC.channel_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my ($channel_id) = $sth->fetchrow;

  $sth->finish;

  $query = <<EOQ;
BEGIN
   rhn_channel.unsubscribe_server(?, ?);
END;
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($self->id, $channel_id);

  #Delete the probe state entires for all probe
  #running on the proxy
  $sth = $dbh->prepare(<<EOQ);
DELETE 
  FROM rhn_probe_state PS
 WHERE PS.probe_id in 
(SELECT CP.probe_id 
   FROM rhn_check_probe CP
  WHERE CP.sat_cluster_id = 
(SELECT SN.sat_cluster_id
   FROM rhn_sat_node SN
  WHERE SN.server_id = :sid))
EOQ

  $sth->execute_h(sid => $self->id);
  
  #Now delete all deployed_probes entries 
  #as scheduleEvents won't be running again for this sat_cluster
  $sth = $dbh->prepare(<<EOQ);
DELETE 
  FROM rhn_deployed_probe DP
 WHERE DP.recid in 
(SELECT CP.probe_id 
   FROM rhn_check_probe CP
  WHERE CP.sat_cluster_id = 
(SELECT SN.sat_cluster_id
   FROM rhn_sat_node SN
  WHERE SN.server_id = :sid))
EOQ

  $sth->execute_h(sid => $self->id);


  #Now, delete any probes configured to run on the proxy
  #before deleting the rhn_sat_cluster entries
  $sth = $dbh->prepare(<<EOQ);
DELETE 
  FROM rhn_probe P
 WHERE P.recid in 
(SELECT CP.probe_id 
   FROM rhn_check_probe CP
  WHERE CP.sat_cluster_id = 
(SELECT SN.sat_cluster_id
   FROM rhn_sat_node SN
  WHERE SN.server_id = :sid))
EOQ

  $sth->execute_h(sid => $self->id);

  #And finally, delete the sat cluster/sat node if there is one.
  $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhn_sat_cluster SC
 WHERE SC.recid in
(SELECT SN.sat_cluster_id 
   FROM rhn_sat_node SN 
  WHERE SN.server_id = :sid)
EOQ

  $sth->execute_h(sid => $self->id);

  unless ($transaction) {
    $dbh->commit;
  }

  delete $self->{__proxy_server_id__};
  return $dbh;
}


sub base_channel_id {
  my $self = shift;
  my $server_id = (ref $self) ? $self->id : shift;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  C.id
  FROM  rhnChannel C, rhnServerChannel SC
 WHERE  SC.server_id = ?
   AND  SC.channel_id = C.id
   AND  C.parent_channel IS NULL
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($server_id);

  my @columns;
  @columns = $sth->fetchrow;
  $sth->finish;

  return $columns[0];
}

sub base_channel_label {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  C.label
  FROM  rhnChannel C, rhnServerChannel SC
 WHERE  SC.server_id = ?
   AND  SC.channel_id = C.id
   AND  C.parent_channel IS NULL
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  @columns = $sth->fetchrow;
  $sth->finish;

  return $columns[0] || '';
}

sub base_channel_name {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  C.name
  FROM  rhnChannel C, rhnServerChannel SC
 WHERE  SC.server_id = ?
   AND  SC.channel_id = C.id
   AND  C.parent_channel IS NULL
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  @columns = $sth->fetchrow;
  $sth->finish;

  return $columns[0];
}

# given a channel family label and server_id, return the child channels
# the server could be subscribed to, if any
sub child_channel_candidates {
  my $class = shift;
  my %params = validate(@_, { server_id => 1, channel_family_label => 1 });

  my $dbh = RHN::DB->connect;
  my $sth;

  my $query = <<EOQ;
SELECT C.id AS CHANNEL_ID, C.label AS CHANNEL_LABEL
  FROM rhnChannel C, rhnChannelFamilyMembers CFM, rhnChannelFamily CF
 WHERE CF.label = ?
   AND CF.id = CFM.channel_family_id
   AND CFM.channel_id = C.id
   AND C.parent_channel = ?
ORDER BY C.label
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($params{channel_family_label}, RHN::Server->base_channel_id($params{server_id}));

  my @ret;
  while (my $chan_info = $sth->fetchrow_hashref) {
    push @ret, $chan_info;
  }

  return @ret;
}


sub system_list_count {
  my $class = shift;
  my $user_id = shift;
  my $dbh = RHN::DB->connect;
  
  my $sth = $dbh->prepare(<<EOS);
SELECT count(*) from rhnSet
	 where label = 'system_list'
   AND user_id = :user_id
EOS

  $sth->execute_h(user_id => $user_id);
  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}


sub delete_server {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  eval {
    $query = <<EOQ;
BEGIN
  delete_server(?);
END;
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($self->id);

    $dbh->commit;
  };

  if ($@) {
    my $E = $@;
    $dbh->rollback;

    die $E;
  }
}

sub delete_servers_in_system_list {
  my $class = shift;
  my $uid = shift;

  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;

  eval {
    $query = <<EOQ;
BEGIN
  delete_server_bulk(?);
END;
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($uid);

    $dbh->commit;
  };

  if ($@) {
    my $E = $@;
    $dbh->rollback;

    die $E;
  }
}

sub server_event_true_history {
  my $class = shift;
  my $sid = shift;
  my $hid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT SH.summary, SH.details, SH.created
  FROM rhnServerHistory SH
 WHERE SH.id = :hid
   AND SH.server_id = :sid
EOS
  $sth->execute_h(hid => $hid, sid => $sid);
  my $ret = $sth->fetchrow_hashref_copy;
  $sth->finish;

  return $ret;
}

# bug 247457
# need to remove virtualization_host by hand to allow removal
# of corrupt servers from satellite. This is lame, but without
# a schema change, it is the only viable solution.
sub remove_virtualization_host_entitlement {
  my $class = shift;
  my $server_id = shift;

  my $query = <<EOQ;
  SELECT sg.id FROM rhnServerGroup sg, rhnServerGroupType sgt
   WHERE sg.group_type = sgt.id 
     AND sgt.label = 'virtualization_host'
EOQ

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);
  $sth->execute_h();
  my ($id) = $sth->fetchrow;
  $sth->finish;
  # if we can't find it, just bail
  return unless $id;

  $class->remove_servers_from_groups([$server_id], [$id], $dbh);
  $dbh->commit;
}

sub system_pending_actions_count {
  my $class = shift;
  my $server_id = shift;

  my $query = <<EOQ;
SELECT COUNT(action_id)
  FROM rhnServerAction
 WHERE server_id = :server_id
   AND status = 0
EOQ

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);
  $sth->execute_h(server_id => $server_id);

  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}



sub server_event_simple_action {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT TO_CHAR(A.earliest_action, 'YYYY-MM-DD HH24:MI:SS') EARLIEST_ACTION,
       A.name,
       AType.name ACTION_TYPE,
       SA.result_msg,
       SA.result_code,
       AStatus.name STATUS,
       TO_CHAR(SA.pickup_time, 'YYYY-MM-DD HH24:MI:SS') PICKUP_TIME,
       TO_CHAR(SA.completion_time, 'YYYY-MM-DD HH24:MI:SS') COMPLETION_TIME,
       U.login,
       TO_CHAR(A.created, 'YYYY-MM-DD HH24:MI:SS') CREATED
  FROM rhnAction A,
       web_contact U,
       rhnActionStatus AStatus,
       rhnActionType AType,
       rhnServerAction SA
 WHERE SA.action_id = :aid
   AND SA.server_id = :sid
   AND A.id = :aid
   AND U.id(+) = A.scheduler
   AND AStatus.id = SA.status
   AND AType.id = A.action_type
EOS
  $sth->execute_h(aid => $aid, sid => $sid);
  my $ret = $sth->fetchrow_hashref_copy;
  $ret->{ACTION_ID} = $aid;
  $ret->{SERVER_ID} = $sid;
  $ret->{LOGIN} ||= '(none)';
  $sth->finish;

  return $ret;
}

sub server_event_errata_action {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT E.id, E.advisory, E.synopsis
  FROM rhnErrata E,
       rhnActionErrataUpdate AEU
 WHERE E.id = AEU.errata_id
   AND AEU.action_id = :aid
EOS
  $sth->execute_h(aid => $aid);
  while (my $row = $sth->fetchrow_hashref_copy) {
    push @{$ret->{ERRATA}}, $row;
  }

  return $ret;
}


sub server_event_package_dep_errors {
  my %params = validate(@_, {sid => 1, aid => 1, action_type => 1, ret => 1});

  my $ret = $params{ret};
  my $aid = $params{aid};
  my $sid = $params{sid};
  my $action_type = $params{action_type};

  # look for any package errors that might exist...
  # we're now abusing the badly-named rhnActionPackageRemovalFailure table...
  my @pkg_actions = qw/packages.remove packages.update packages.runTransaction/;

  # this has no upper bound, so might get slow...
  if (grep {$action_type eq $_} @pkg_actions) {


    my $pkg_rmvl_ds = new RHN::DataSource::Package(-mode => "package_removal_failures");
    my $data = $pkg_rmvl_ds->execute_query(-sid => $sid, -action_id => $aid);

    $ret->{TOTAL_PKG_DEPENDENCY_ERRORS} = @$data;

    $data = $pkg_rmvl_ds->slice_data($data, 1, 20);

    foreach my $dependency (@$data) {

      my $sense = RHN::Package->parse_dep_sense_flags($dependency->{FLAGS});
      $sense .= ' ' if $sense;

      my $sense_flag = RHN::Package->parse_sense_flag($dependency->{SENSE});
      $sense_flag .= ' ' if  $sense_flag;
      

      $dependency->{DEPENDENCY_ERROR} = qq{$dependency->{PACKAGE} $sense_flag$sense$dependency->{NEEDED_CAPABILITY}};
    }

    PXT::Debug->log(7, "data:  " . Data::Dumper->Dump([($data)]));

    $ret->{NUM_SHOWN_PKG_DEPENDENCY_ERRORS} = @$data;

    $ret->{PACKAGE_RMV_DEPENDENCY_ERRORS} = $data;
  }

  return $ret;
}

sub server_event_package_action {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT PN.name || NVL2(PE.evr, ('-' || PE.evr.as_vre_simple()), '') AS NVRE,
       AP.id AS ACTION_PACKAGE_ID,
       PN.id || '|' || PE.id AS id_combo,
       AP.package_arch_id
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnActionPackage AP
 WHERE AP.action_id = :aid
   AND AP.name_id = PN.id
   AND AP.evr_id = PE.id (+)
EOS
  $sth->execute_h(aid => $aid);
  while (my $row = $sth->fetchrow_hashref_copy) {
    push @{$ret->{PACKAGES}}, $row;
  }

  $ret = server_event_package_dep_errors(-action_type => $action_type,
					 -aid => $aid,
					 -sid => $sid,
					 -ret => $ret,
					);

  return $ret;
}

sub server_event_solaris_package_action {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_package_action($sid, $aid, $action_type);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT AP.id, SAPR.result_code, SAPR.stdout, SAPR.stderr
  FROM rhnServerActionPackageResult SAPR, rhnActionPackage AP
 WHERE AP.id = :apid
   AND SAPR.action_package_id = AP.id
EOS

  foreach my $package (@{$ret->{PACKAGES}}) {
    $sth->execute_h(apid => $package->{ACTION_PACKAGE_ID});

    my $row = $sth->fetchrow_hashref_copy;
    $package->{RESULTS} = $row;

    $sth->finish; # one set of results per package, please.
  }

  return $ret;
}

sub server_event_delta_action {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT rTO.label AS OPERATION, PN.name NAME, PN.name || '-' || PE.evr.as_vre_simple() AS NVRE
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnTransactionOperation rTO,
       rhnTransactionPackage TP,
       rhnPackageDeltaElement PDE,
       rhnActionPackageDelta APD
 WHERE APD.action_id = :aid
   AND APD.package_delta_id = PDE.package_delta_id
   AND PDE.transaction_package_id = TP.id
   AND PN.id = TP.name_id
   AND PE.id = TP.evr_id
   AND TP.operation = rTO.id
ORDER BY PN.name, rTO.label -- NOTE: ordering on rTO.label matters for proper display of action
EOS
  $sth->execute_h(aid => $aid);
  while (my $row = $sth->fetchrow_hashref_copy) {
    push @{$ret->{PACKAGES}}, $row;
  }

  $ret = server_event_package_dep_errors(-action_type => $action_type,
					 -aid => $aid,
					 -sid => $sid,
					 -ret => $ret,
					);


  return $ret;
}


sub server_event_config_revisions {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);

  my $ds = new RHN::DataSource::Simple(-querybase => "config_queries",
				       -mode => 'config_action_revisions');
  my $revisions = $ds->execute_query(-sid => $sid, -aid => $aid);

  foreach my $rev (@{$revisions}) {
    push @{$ret->{REVISIONS}}, $rev;
  }

  return $ret;
}

sub server_event_config_upload {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);

  my $ds = new RHN::DataSource::Simple(-querybase => "config_queries",
				       -mode => 'upload_action_status');
  my $files = $ds->execute_query(-sid => $sid, -aid => $aid);

  foreach my $file (@{$files}) {
    push @{$ret->{FILES}}, $file;
  }

  return $ret;
}

sub server_event_config_diff {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;
  my $action_type = shift;

  my $ret = $class->server_event_simple_action($sid, $aid);

  my $ds = new RHN::DataSource::Simple(-querybase => "config_queries",
				       -mode => 'diff_action_revisions');

  my $revisions = $ds->execute_query(-sid => $sid, -aid => $aid);

  foreach my $rev (@{$revisions}) {
    push @{$ret->{REVISIONS}}, $rev;
  }

  return $ret;
}


sub server_event_config_deploy {
  my $class = shift;
  return $class->server_event_config_revisions(@_);
}

sub server_event_details {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT AType.label
  FROM rhnActionType AType,
       rhnAction A
 WHERE AType.id = A.action_type
   AND A.id = :aid
EOS
  $sth->execute_h(aid => $aid);
  my ($label) = $sth->fetchrow;
  $sth->finish;

  if (not defined $label) {
    return ($label, $class->server_event_true_history($sid, $aid));
  }
  elsif ($label eq 'errata.update') {
    return ($label, $class->server_event_errata_action($sid, $aid));
  }
  elsif ($label eq 'packages.update' or $label eq 'packages.remove' or $label eq 'packages.verify') {
    return ($label, $class->server_event_package_action($sid, $aid, $label));
  }
  elsif (grep { $label eq $_ }
	 qw/solarispkgs.install solarispkgs.remove
	    solarispkgs.patchInstall solarispkgs.patchRemove
	    solarispkgs.patchClusterInstall solarispkgs.patchClusterRemove/) {

    return ($label, $class->server_event_solaris_package_action($sid, $aid, $label));
  }
  elsif ($label eq 'packages.runTransaction') {
    return ($label, $class->server_event_delta_action($sid, $aid, $label));
  }
  elsif ($label eq 'configfiles.upload' or $label eq 'configfiles.mtime_upload') {
    return ($label, $class->server_event_config_upload($sid, $aid, $label));
  }
  elsif ($label eq 'configfiles.deploy') {
    return ($label, $class->server_event_config_deploy($sid, $aid, $label));
  }
  elsif ($label eq 'configfiles.diff') {
    return ($label, $class->server_event_config_diff($sid, $aid, $label));
  }
  else {
    return ($label, $class->server_event_simple_action($sid, $aid));
  }
}

sub server_channels {
  my $self = shift;

  my $ds = new RHN::DataSource::Channel(-mode => 'system_channels');
  my $data = $ds->execute_query(-sid => $self->id);

  return @{$data};
}

sub channel_list {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT C.id, C.parent_channel, C.name, C.label FROM rhnChannel C, rhnServerChannel SC WHERE C.id = SC.channel_id AND SC.server_id = ?');
  $sth->execute($self->id);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub unsubscribe_from_channel {
  my $self = shift;
  my $label = shift;
  my $dbh = shift;

  my $commit = 1;

  $commit = 0 if defined $dbh;

  my $channel_id;
  # accept either an id or a channel label
  if ($label =~ /\D/) {
    $channel_id = RHN::DB::Channel->channel_id_by_label($label);
  }
  else {
    $channel_id = $label;
  }

  $dbh = RHN::DB->connect unless ($dbh);

  my $sth = $dbh->prepare(<<EOH);
BEGIN
  rhn_channel.unsubscribe_server(?, ?);
END;
EOH
  $sth->execute($self->id, $channel_id);

  if ($commit) {
    $dbh->commit;
  }
  else {
    return $dbh;
  }
}

sub subscribe_to_channel {
  my $self = shift;
  my $label = shift;
  my $dbh = shift;

  my $commit = 1;

  $commit = 0 if defined $dbh;

  my $channel_id;
  # accept either an id or a channel label
  if ($label =~ /\D/) {
    $channel_id = RHN::DB::Channel->channel_id_by_label($label);
  }
  else {
    $channel_id = $label;
  }

  $dbh = RHN::DB->connect unless ($dbh);
  my $sth;

  # pass the dbh to make it one transaction
  $dbh = $self->unsubscribe_from_channel($label, $dbh);

  $sth = $dbh->prepare(<<EOH);
BEGIN
  rhn_channel.subscribe_server(?, ?);
END;
EOH
  $sth->execute($self->id, $channel_id);

  if ($commit) {
    $dbh->commit;
  }
  else {
    return $dbh;
  }
}

# returns an array of all the cd devices connected to a server
# TODO:  should we be caching this result?
sub get_cd_devices {
  my $self = shift;

  my @cd_devices = RHN::DB::Server::CdDevice->lookup_cd_devices_by_server($self->id);

  return @cd_devices;
}

# returns an array of all the hardware devices attached to a server.
# TODO:  should we be caching this result?
sub get_hw_devices {
  my $self = shift;

  my @hw_devices = RHN::DB::Server::HwDevice->lookup_hw_devices_by_server($self->id);

  return @hw_devices;
}

# returns an array of all the storage devices attached to a server.
# TODO:  should we be caching this result?
sub get_storage_devices {
  my $self = shift;

  my @storage_devices = RHN::DB::Server::StorageDevice->lookup_storage_devices_by_server($self->id);

  return @storage_devices;
}

# returns an array of all the net info objects related to a server
sub get_net_infos {
  my $self = shift;

  my @net_infos = RHN::DB::Server::NetInfo->lookup_net_info_by_server($self->id);
  return @net_infos;
}

# returns an array of all the net info objects related to a server
sub get_net_interfaces {
  my $self = shift;

  my @net_interfaces = RHN::DB::Server::NetInterface->lookup_net_interface_by_server($self->id);
  return @net_interfaces;
}


#
# build some accessors
#
foreach my $field ($j->method_names) {
   my $sub = q {
       sub [[field]] {
         my $self = shift;
         if (@_) {
           if ($rw_fields{[[field]]} or $self->{__newly_created__}) {
             my $value = shift;
             $self->{":modified:"}->{[[field]]} = 1;
             $self->{__[[field]]__} = $value;
           }
           else {
             croak "RHN::DB::Server->[[field]] cannot be used to set a value at this time.  It may be a read-only accessor.";
           }
         }
         return $self->{__[[field]]__};
       }
     };

     $sub =~ s/\[\[field\]\]/$field/g;
     eval $sub;

     if ($@) {
       die $@;
     }
}

# insert/update values depending upon context
#
# TODO:  Hrm.  I have a join, but I'm not sure whether I should be screwing w/ those values...
# since those values that are joined are solely reported by up2date, and they ought to be read only.
sub commit {
  my $self = shift;
  my $dbh = RHN::DB->connect;
  my $sth;
  my @columns_to_use;
  my $mode = 'update';

  if ($self->{__newly_created__}) {
    croak "$self->commit called on newly created object when id != -1\nid == $self->{__id__}" unless $self->{__id__} == -1;

    $sth = $dbh->prepare("SELECT rhn_server_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new server id from seq rhn_server_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;

    $sth = $dbh->prepare("SELECT rhn_server_loc_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($location_id) = $sth->fetchrow;
    die "No new location id from seq rhn_server_loc_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{location_id} = 1;
    $self->{__location_id__} = $location_id;
    $self->{":modified:"}->{location_server_id} = 1;
    $self->{__location_server_id__} = $id;

    # generated the digital server id from the id if it hasn't already been set...
    if (!$self->{__digitalserver_id__}) {
      $self->{":modified:"}->{digitalserver_id} = 1;
      $self->{__digitalserver_id__} = "ID-" . "0" x (9-length($id)) . $id;
    }

    $mode = 'insert';
  }

  die "$self->commit called on org without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;


  my @queries;

  if ($mode eq 'update') {
    @queries = $j->update_queries($j->methods_to_columns(@modified));
  } else {
    @queries = $j->insert_queries($j->methods_to_columns(@modified));
  }

  foreach my $query (@queries) {
    if ($query->[0] =~ /rhnServerLocation/ims) {
      my $sth = $dbh->prepare('SELECT 1 FROM rhnServerLocation WHERE server_id = ?');
      $sth->execute($self->id);
      my ($exists) = $sth->fetchrow;
      $sth->finish;

      if (not $exists) {
	my $sth = $dbh->prepare('INSERT INTO rhnServerLocation (id, server_id) VALUES (rhn_server_loc_id_seq.nextval, ?)');
	$sth->execute($self->id);
      }
    }

    local $" = ":";
    my $sth = $dbh->prepare($query->[0]);
    my @vals = map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]};
    $sth->execute(@vals, $modified{id} ? () : $self->id);
  }

  # tableclass does not support blobs, manually updating cert here
  $sth = $dbh->prepare("UPDATE rhnSatelliteInfo SET cert = :cert WHERE server_id = :id");
  $sth->execute_h(id => $self->id, cert => $dbh->encode_blob($self->{__cert__}, 'cert'));

  $dbh->commit;

  # flush out the thing that allows all attributes to be settable until first commit
  $self->{__newly_created__} = undef;
  delete $self->{":modified:"};
}


sub package_groups {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
  SELECT    SP_NAME.name, SP_EVR.evr.as_vre_simple(), SP.name_id || '|' || SP.evr_id ID_COMBO
    FROM    rhnPackageEvr SP_EVR, rhnPackageName SP_NAME, rhnServerPackage SP
   WHERE    SP.server_id = ?
     AND    SP.name_id = SP_NAME.id
     AND    SP.evr_id = SP_EVR.id
ORDER BY    UPPER(name), SP_EVR.evr DESC
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);
  my %server_pkg;
  while (my ($name, $evr, $id_combo) = $sth->fetchrow) {
#    $server_pkg{$name} = [$id_combo, $nvre, $name_id, $evr_id];
    $server_pkg{$name} = [$name, $evr, $id_combo];
  }

  if (not keys %server_pkg) {
    return;
  }

  $query = <<EOQ;
SELECT PN.name, PG.name
  FROM rhnPackageEVR PE, rhnPackage P, rhnChannelPackage CP, rhnPackageGroup PG, rhnPackageName PN, rhnServerChannel SC
 WHERE SC.server_id = ?
   AND SC.channel_id = CP.channel_id
   AND P.id = CP.package_id
   AND PE.id = P.evr_id
   AND PG.id = P.package_group
   AND P.name_id = PN.id
ORDER BY UPPER(P.name), PE.evr DESC
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my %pkg_seen;
  my %groups;
  my %filter_server_pkg = %server_pkg;
  while (my @row = $sth->fetchrow) {
    delete $filter_server_pkg{$row[0]};
    next if $pkg_seen{$row[0]}++;
    $row[1] =~ s/\s*$//;
    $row[1] =~ s/Enviornment/Environment/; # fix a typo in an old glibc pkg
    my ($upper, $lower) = split m(/), $row[1], 2;
    $lower ||= '';

    push @{$groups{$upper}->{$lower}}, $server_pkg{$row[0]}
      if exists $server_pkg{$row[0]};
  }

  $groups{Ungrouped}->{''} = [ sort { lc $a cmp lc $b } values %filter_server_pkg ];

  return \%groups;
}

sub has_hardware_profile {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query = "SELECT 1 FROM rhnCpu WHERE server_id = ?";
  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my ($profiled) = $sth->fetchrow;
  $sth->finish;

  return $profiled || 0;
}

sub entitlements {
  my $self_or_class = shift;

  my $id;
  if (ref $self_or_class) {
    $id = $self_or_class->id();
  }
  else {
    $id = shift;
  }

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'system_entitlements');

  return @{$ds->execute_query(-sid => $id)};
}

sub has_entitlement {
  my $self = shift;
  my $target_entitlement = shift;

  throw "(invalid_entitlement) Invalid entitlement: $target_entitlement"
    unless RHN::Entitlements->is_valid_entitlement($target_entitlement);

  my @entitlements = $self->entitlements();

  return (grep { $_->{LABEL} eq $target_entitlement } @entitlements) ? 1 : 0;
}

sub server_has_entitlement {
  my $class = shift;
  my $target_entitlement = shift;
  my $sid = shift;

  throw "(invalid_entitlement) Invalid entitlement: $target_entitlement"
    unless RHN::Entitlements->is_valid_entitlement($target_entitlement);

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'system_entitlements');

  my @entitlements = @{$ds->execute_query(-sid => $sid)};

  return (grep { $_->{LABEL} eq $target_entitlement } @entitlements) ? 1 : 0;
}

sub valid_system_features {
  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'valid_system_features');

  return @{$ds->execute_query()};
}

sub is_valid_feature {
  my $target_feature = shift;

  my @valid_features = valid_system_features();

  return (grep { $_->{LABEL} eq $target_feature } @valid_features) ? 1 : 0;
}

sub features {
  my $self = shift;

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'system_features');

  return @{$ds->execute_query(-sid => $self->id)};
}

sub has_feature {
  my $self = shift;
  my $target_feature = shift;

  throw "(invalid_feature) Invalid feature: $target_feature"
    unless is_valid_feature($target_feature);

  my @features = $self->features();

  return (grep { $_->{LABEL} eq $target_feature } @features) ? 1 : 0;
}

# class version of has_feature - prefer has_feature if possible
sub system_has_feature {
  my $class = shift;
  my $sid = shift;
  my $target_feature = shift;

  throw "(no_feature) No feature in call to system_has_feature"
    unless $target_feature;

  throw "(invalid_feature) Invalid feature: $target_feature"
    unless is_valid_feature($target_feature);

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'system_has_feature');
  my $data = $ds->execute_query(-sid => $sid, -feature => $target_feature);

  return (@{$data} ? 1 : 0);
}

sub is_entitled {
  my $self_or_class = shift;

  my @entitlements;
  if (ref $self_or_class) {
    @entitlements = $self_or_class->entitlements;
  }
  else {
    @entitlements = $self_or_class->entitlements(shift);
  }

  return (scalar @entitlements) ? 1 : 0;
}

sub can_entitle_server {
  my $self_or_class = shift;
  my $entitlement = shift;

  my $sid;
  if (ref $self_or_class) {
    $sid = $self_or_class->id;
  }
  else {
    $sid = shift;
  }

  my $dbh = RHN::DB->connect;
  my $can = 0;

  eval {
    $can = $dbh->call_function('rhn_entitlements.can_entitle_server', $sid, $entitlement);
  };

  if ($@) {
    my $E = $@;

    # if it's anything other not function not returning a value, toss
    # the exception further up the chain...
    unless ($E =~ m/ORA-06503/) {
      throw $E;
    }
  }

  return $can ? 1 : 0;
}

sub set_channels {
  my $self = shift;
  my %params = validate(@_, {user_id => 1, channels => 1});
  my %new_channels = map { $_ => 1 } @{$params{channels}};
  my $user_id = $params{user_id};

  my @remove;
  my @add;

  my $dbh = RHN::DB->connect;
  my $query = <<EOS;
SELECT SC.channel_id
  FROM rhnServerChannel SC
 WHERE SC.server_id = ?
EOS

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  while (my ($cid) = $sth->fetchrow) {
    if (exists $new_channels{$cid}) {
      delete $new_channels{$cid};
    }
    else {
      push @remove, $cid;
    }
  }

  @add = keys %new_channels;
  foreach my $add (@add) {

    # do quick unsubscribe + quick subscribe
    my $sth = $dbh->prepare(<<EOS);
BEGIN
    rhn_channel.unsubscribe_server(:server_id, :cid, 0);
    rhn_channel.subscribe_server(:server_id, :cid, 0, :user_id);
END;
EOS
    $sth->execute_h(server_id => $self->id, cid => $add, user_id => $user_id);
  }

  foreach my $remove (@remove) {
    # do quick unsubscribes
    my $sth = $dbh->prepare(<<EOS);
BEGIN
    rhn_channel.unsubscribe_server(:server_id, :cid, 0);
END;
EOS
    $sth->execute_h(server_id => $self->id, cid => $remove);
  }

  # manually recompute the cache so that it's immediate
  my ($add, $remove, $unc) = RHN::DB::Server->update_cache_for_server($dbh, $self->id);

  $dbh->commit;

  return { added => [ @add ],
	   removed => [ @remove ],
	   };
}

sub canonical_package_list {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT SP.name_id, PN.name, SP.evr_id, SPE.evr.as_vre_simple(), SPE.epoch, SPE.version, SPE.release
  FROM rhnPackageName PN,
       rhnPackageEVR SPE,
       rhnServerPackage SP
 WHERE PN.id = SP.name_id
   AND SPE.id = SP.evr_id
   AND SP.server_id = ?
ORDER BY upper(PN.name), SPE.evr
EOS
  $sth->execute($self->id);

  my @packages;
  while (my @row = $sth->fetchrow) {
    push @packages, \@row;
  }

  return @packages;
}

sub entitle_server {
  my $self_or_class = shift;
  my $label = shift;

  my $sid;
  if (ref $self_or_class) {
    $sid = $self_or_class->id;
  }
  else {
    $sid = shift;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOH);
BEGIN
  rhn_entitlements.entitle_server(:sid, :entitlement);
END;
EOH
  $sth->execute_h(sid => $sid, entitlement => $label);

  return;
}

sub unentitle_server {
  my $self_or_class = shift;
  my $sid;
  if (ref $self_or_class) {
    $sid = $self_or_class->id;
  }
  else {
    $sid = shift;
  }

  my $monitoring = 0;
  if (RHN::Server->server_has_entitlement('monitoring_entitled', $sid)) {
    $monitoring = 1;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOH);
BEGIN
  rhn_entitlements.unentitle_server(:sid);
END;
EOH
  $sth->execute_h(sid => $sid);

  if ($monitoring) {
    RHN::Server->cleanup_monitoring_for_system($sid);
  }

  return;
}

sub remove_entitlement {
  my $self_or_class = shift;
  my $entitlement = shift;

  my $sid;
  if (ref $self_or_class) {
    $sid = $self_or_class->id;
  }
  else {
    $sid = shift;
  }

  throw "(invalid_entitlement) Invalid entitlement: $entitlement"
    unless RHN::Entitlements->is_valid_entitlement($entitlement);

  my $dbh = RHN::DB->connect;
  $dbh->call_procedure('rhn_entitlements.remove_server_entitlement', $sid, $entitlement);

  if ($entitlement eq 'monitoring_entitled') {
    RHN::Server->cleanup_monitoring_for_system($sid);
  }

  return;
}

sub channel_license_consent {
  my $self = shift;
  my $user_id = shift;
  my $channel_id = shift;


  my $dbh = RHN::DB->connect;

  $dbh->call_procedure('rhn_channel.license_consent', $channel_id, $user_id, $self->id);

  # used in transaction...
  return $dbh;
}


############################
# Server package functions
############################

sub snapshot_server {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, reason => 1, transaction => 0});

  if (!PXT::Config->get('enable_snapshot')) {
      return;
  }

  my $dbh = $params{transaction} || RHN::DB->connect;

  $dbh->call_procedure('rhn_server.snapshot_server', $params{server_id}, $params{reason});

  # used in transaction...
  if ($params{transaction}) {
    return $dbh;
  }
  else {
    $dbh->commit;
  }
}

sub snapshot_set {
  my $class = shift;
  my %params = validate(@_, {set_label => 1, user_id => 1, reason => 1, transaction => 0});

  if (!PXT::Config->get('enable_snapshot')) {
      return;
  }

  my $dbh = $params{transaction} || RHN::DB->connect;

  $dbh->call_procedure('rhn_server.bulk_snapshot', $params{reason}, $params{set_label}, $params{user_id});

  # used in transaction...
  if ($params{transaction}) {
    return $dbh;
  }
  else {
    $dbh->commit;
  }
}


# create a blank server object to propogate back to the caller
sub _blank_server {
   my $class = shift;

   my $self = bless { }, $class;

   return $self;
}



# retrieve a server given its unique id.
sub lookup {
   my $class = shift;
   my %params = validate(@_, {id => 1});
   my $id = $params{id};

   my @columns;

   my $dbh = RHN::DB->connect;
   my $sqlstmt;

   # digital server id's contain non-digits
   if ($id =~ /\D/) {
     $sqlstmt = $j->select_query("S.DIGITAL_SERVER_ID = ?");
   }
   else {
     $sqlstmt = $j->select_query("S.ID = ?");
   }

   my $sth = $dbh->prepare($sqlstmt);
   $sth->execute($id);
   @columns = $sth->fetchrow;
   $sth->finish;

   my $ret;
   if ($columns[0]) {
     $ret = $class->_blank_server();
     foreach ($j->method_names) {
       $ret->{"__".$_."__"} = shift @columns;
     }

     delete $ret->{":modified:"};
   }
   else {
     local $" = ", ";
     throw '(server_does_not_exist)';
   }

   # handle cert separately since its a blob
   $sth = $dbh->prepare("SELECT cert FROM rhnSatelliteInfo WHERE server_id = ?");
   $sth->execute($id);
   ($ret->{__cert__}) = $sth->fetchrow;
   $sth->finish;

   return $ret;
}

sub org {
  my $self = shift;

  return undef unless $self->org_id;
  return $self->{__orgobj__} if exists $self->{__orgobj__};

  $self->{__orgobj__} = RHN::Org->lookup(-id => $self->org_id);
  return $self->{__orgobj__};
}


#
# Delete a server given a server id
#
# Is this functionality desired??
#
sub remove {
  my $class = shift;
  my $id = shift;
  my $dbh;
  my $sqlstmt;
  my $sth;

  $sqlstmt = "DELETE FROM " . $s_table->table_name . " WHERE id=?";
  $dbh = RHN::DB->connect;
  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  $dbh->commit;
  $sth->finish;
}



sub add_servers_to_groups {
  my $class = shift;
  my @servers = @{+shift};
  my @groups = @{+shift};
  my $transaction = shift;

  unless (@servers and @groups) {

    if (defined $transaction) {
      return $transaction;
    }
    else {
      return;
    }
  }
  my $dbh = $transaction || RHN::DB->connect;

  my $query = <<EOQ;
BEGIN
  :retval := rhn_server.insert_into_servergroup_maybe(:server_id, :server_group_id);
END;
EOQ
  my $sth = $dbh->prepare($query);

  for my $server (@servers) {
    for my $group (@groups) {

      # what, exactly, do we need to do w/ retval?  check it for errors?
      my $retval;
      $sth->execute_h(retval => \$retval,
                      server_id => $server,
		      server_group_id => $group);
    }
  }

  if (defined $transaction) {
    return $transaction;
  }
  else {
    $dbh->commit;
  }
}

sub remove_servers_from_groups {
  my $class = shift;
  my @servers = @{+shift};
  my @groups = @{+shift};
  my $transaction = shift;

  unless (@servers and @groups) {

    if (defined $transaction) {
      return $transaction;
    }
    else {
      return;
    }
  }

  my $dbh = $transaction || RHN::DB->connect;
  my $query = <<EOQ;
BEGIN
  rhn_server.delete_from_servergroup(:server_id, :server_group_id);
END;
EOQ

  my $sth = $dbh->prepare($query);

  for my $server (@servers) {
    for my $group (@groups) {
      $sth->execute_h(server_id => $server, server_group_id => $group);
    }
  }
      
  if (defined $transaction) {
    return $dbh if defined $transaction;
  }
  else {
    $dbh->commit;
  }
}

sub change_user_pref_bulk {
  my $class = shift;
  my $set = shift;
  my $user = shift;
  my $pref = shift;
  my $new_val = shift;
  my $assumed_default = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOS;
DELETE FROM rhnUserServerPrefs
 WHERE user_id = ?
   AND name = ?
   AND server_id IN
       (SELECT element FROM rhnSet WHERE user_id = ? AND label = ?)
EOS
  my $sth = $dbh->prepare($query);
  $sth->execute($user->id, $pref, $user->id, $set->label);

# Prefs have a default - only insert a row if the pref is different from the default value
  if ($new_val ne $assumed_default) {
    my $query = <<EOS;
INSERT INTO rhnUserServerPrefs
(user_id, server_id, name, value)
SELECT :user_id, element, :pref_name, :new_value FROM rhnSet WHERE user_id = :user_id AND label = :set_label
EOS

    my $sth = $dbh->prepare($query);
    $sth->execute_h(user_id => $user->id, pref_name => $pref, new_value => $new_val, set_label => $set->label);
  }

  $dbh->commit;
}

sub change_pref_bulk {
  my $class = shift;
  my $set = shift;
  my $pref = shift;
  my $new_val = shift;

  my %column_map = map { $_ => $_ } qw/auto_update auto_deliver/;
  die "invalid pref $pref" unless exists $column_map{$pref};

  my $dbh = RHN::DB->connect;
  my $query = <<EOS;
UPDATE rhnServer S
   SET $pref = ?
 WHERE S.id IN (SELECT element FROM rhnSet WHERE user_id = ? AND label = ?)
   AND EXISTS (SELECT 1 FROM rhnEntitledServers WHERE id = S.id)
EOS

  my $sth = $dbh->prepare($query);
  $sth->execute($new_val ? 'Y' : 'N', $set->uid, $set->label);

  $dbh->commit;
}

sub compatible_with_server { #returns the id and name of all servers which this server can be profiled against.
  my $class = shift;
  my $server_id = shift;
  my $user_id = shift;
  my $org_id = shift;

  my %params = (sid => $server_id, user_id => $user_id);

  my $org_string;
  if (defined $org_id) {
    $org_string = '= :org_id';
    $params{org_id} = $org_id;
  }
  else {
    $org_string = 'IS NULL';
  }

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT S.id, S.name
  FROM rhnServer S,
       rhnServer SBase
 WHERE S.org_id = SBase.org_id
   AND SBase.id = :sid
   AND EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE user_id = :user_id AND server_id = S.id)
   AND (EXISTS (SELECT 1
                 FROM rhnServerChannel SC, rhnServerChannel SCBase
                WHERE SCBase.server_id = SBase.id
                  AND SC.channel_id = SCBase.channel_id
                  AND SC.server_id = S.id)
       OR EXISTS (SELECT 1
                    FROM rhnChannel C, rhnServerChannel SC
                   WHERE SC.server_id = S.id
                     AND SC.channel_id = C.id
                     AND C.org_id $org_string
                     AND C.parent_channel IS NULL) )
   AND S.id != :sid
   AND EXISTS (SELECT 1 FROM rhnServerFeatureView SFV WHERE SFV.server_id = S.id AND SFV.label = 'ftr_profile_compare')
ORDER BY UPPER(S.name)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(%params);

  my @ret;
  while (my @data = $sth->fetchrow) {
    push @ret, [ @data ];
  }

  return @ret;
}

sub update_cache_for_server {
  my $class = shift;
  my $dbh = shift;
  my $server = shift;
  my $package_name_ids = shift || [];

  my $p_old_query = <<EOS;
select snpc.server_id, snpc.org_id, snpc.errata_id, snpc.package_id
  from rhnServerNeededPackageCache snpc,
       rhnpackage p
  where server_id = :server_id
    and p.id = package_id
EOS

  $p_old_query .= " and P.name_id IN (" . join(", ", @$package_name_ids) . ")"
    if @$package_name_ids;

  my $p_old_sth = $dbh->prepare($p_old_query);

  my $e_old_sth = $dbh->prepare(<<EOS);
select server_id, org_id, errata_id from rhnServerNeededErrataCache where server_id = :server_id
EOS

  my $p_new_query = "select server_id, org_id, errata_id, package_id from rhnServerNeededPackageView where server_id = :server_id";
  $p_new_query .= " and name_id IN (" . join(", ", @$package_name_ids) . ")"
    if @$package_name_ids;

  my $p_new_sth = $dbh->prepare($p_new_query);

  my $p_ins_sth = $dbh->prepare(<<EOS);
INSERT INTO rhnServerNeededPackageCache
            (server_id, org_id, errata_id, package_id)
     VALUES (?, ?, ?, ?)
EOS

  my $p_del_sth = $dbh->prepare(<<EOS);
DELETE FROM rhnServerNeededPackageCache
      WHERE server_id = ?
        AND org_id = ?
        AND (errata_id = ? OR errata_id IS NULL)
        AND package_id = ?
EOS

  my $e_ins_sth = $dbh->prepare(<<EOS);
INSERT INTO rhnServerNeededErrataCache
            (server_id, org_id, errata_id)
     VALUES (?, ?, ?)
EOS

  my $e_del_sth = $dbh->prepare(<<EOS);
DELETE FROM rhnServerNeededErrataCache
      WHERE server_id = ?
        AND org_id = ?
        AND errata_id = ?
EOS

  $p_old_sth->execute_h(server_id => $server);

  my %p_seen;
  while (my @row = $p_old_sth->fetchrow) {
    my $entry = join("|", map { defined $_ ? $_ : '' } @row);
    $p_seen{$entry} = 1;
  }

  $e_old_sth->execute_h(server_id => $server);

  my %e_seen;
  while (my @row = $e_old_sth->fetchrow) {
    my $entry = join("|", map { defined $_ ? $_ : '' } @row[0,1,2]);
    $e_seen{$entry} = 1;
  }

  $p_new_sth->execute_h(server_id => $server);

  my @p_added_rows;
  my @p_deleted_rows;
  my %e_rows;
  my @e_added_rows;
  my @e_deleted_rows;
  my $p_unchanged = 0;

  # the logic: if we see a row on THIS pass that we didn't see
  # before, we need to do an INSERT.  if we've seen it before,
  # remove it from %seen.  anything left in %seen is a row we didn't
  # see on the second pass, and needs inserting

  while (my @row = $p_new_sth->fetchrow) {
    if (defined $row[2]) {
      my $e_entry = join("|", map { defined $_ ? $_ : '' } @row[0,1,2]);
      $e_rows{$e_entry} = 1;
     }
    my $p_entry = join("|", map { defined $_ ? $_ : '' } @row);
    if (not exists $p_seen{$p_entry}) {
      push @p_added_rows, $p_entry;
    }
    else {
      delete $p_seen{$p_entry};
      $p_unchanged++;
    }
  }

  for my $e_entry (keys %e_rows) {
    my @row = split /[|]/, $e_entry;
    if (not exists $e_seen{$e_entry}) {
      push @e_added_rows, $e_entry;
    }
    else {
      delete $e_seen{$e_entry};
    }
  }

  @p_deleted_rows = keys %p_seen;

  if (@p_deleted_rows or @p_added_rows) {
    $p_del_sth->execute(split /[|]/, $_) foreach @p_deleted_rows;
    $p_ins_sth->execute(split /[|]/, $_) foreach @p_added_rows;
  }

  @e_deleted_rows = keys %e_seen;

  if (@e_deleted_rows or @e_added_rows) {
    $e_del_sth->execute(split /[|]/, $_) foreach @e_deleted_rows;
    $e_ins_sth->execute(split /[|]/, $_) foreach @e_added_rows;
  }

  return (\@p_added_rows, \@p_deleted_rows, $p_unchanged);
}

# eids of applicable errata for which the server does not have a
# pending update action
#
# takes user_id for permission check on the server
sub unscheduled_errata {
  my $class_or_self = shift;

  my $sid;
  if (ref $class_or_self) {
    $sid = $class_or_self->id;
  }
  else {
    $sid = shift;
  }

  my $user_id = shift;

  throw "no user id" unless $user_id;

  my $ds = new RHN::DataSource::Errata;
  $ds->mode('unqueued_relevant_to_system'); 
# Not 'unscheduled' because the system details 'Pending' page does not
# show 'Picked Up' actions - they are on the history page

  my $data = $ds->execute_query(-user_id => $user_id, -sid => $sid);

  return map { $_->{ID} } @{$data};
}

# number of actions scheduled which affect the package list
sub package_actions_count {
  my $class_or_self = shift;

  my $sid;
  if (ref $class_or_self) {
    $sid = $class_or_self->id;
  }
  else {
    $sid = shift;
  }

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT count(A.id)
  FROM rhnServerAction SA, rhnActionStatus AST, rhnActionType AT, rhnAction A
 WHERE SA.server_id = :sid
   AND AST.id = SA.status
   AND AST.name = 'Queued'
   AND A.id = SA.action_id
   AND AT.id = A.action_type
   AND AT.label IN('packages.refresh_list', 'packages.update',
                   'packages.remove', 'errata.update', 'packages.delta')
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(sid => $sid);

  my ($first_row) = $sth->fetchrow;

  $sth->finish;

  return $first_row;
}

# total number of actions scheduled
sub actions_count {
  my $class_or_self = shift;

  my $sid;
  if (ref $class_or_self) {
    $sid = $class_or_self->id;
  }
  else {
    $sid = shift;
  }

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT count(distinct SA.action_id)
  FROM rhnServerAction SA, rhnActionStatus AST
 WHERE SA.server_id = :sid
   AND AST.id = SA.status
   AND AST.name = 'Queued'
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(sid => $sid);

  my ($first_row) = $sth->fetchrow;

  $sth->finish;

  return $first_row;
}

sub client_capable {
  my $self = shift;
  my $cap = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT version
  FROM rhnClientCapability CC,
       rhnClientCapabilityName CN
 WHERE server_id = :sid
   AND CN.id = CC.capability_name_id
   AND CN.name = :cap
EOS
  $sth->execute_h(sid => $self->id, cap => $cap);

  my ($version) = $sth->fetchrow;
  $sth->finish;

  return defined $version ? $version : ();
}


sub set_normal_config_channels {
  my $class = shift;
  my %params = validate(@_, {server_ids => 1,
			     config_channel_ids => 1,
			     transaction => 0,
			    });

  my $dbh = $params{transaction} || RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOS);
DELETE
  FROM rhnServerConfigChannel SCC
 WHERE SCC.server_id = :sid
   AND EXISTS (
  SELECT 1
    FROM rhnConfigChannelType CCT, rhnConfigChannel CC
   WHERE CC.id = SCC.config_channel_id
     AND CC.confchan_type_id = CCT.id
     AND CCT.label = 'normal'
)
EOS

  foreach my $sid (@{$params{server_ids}}) {
    $sth->execute_h(sid => $sid);
  }

  $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnServerConfigChannel SCC
  (server_id, config_channel_id, position)
SELECT DISTINCT S.id, :ccid, :pos
  FROM rhnServer S
 WHERE S.id = :sid
   AND EXISTS (
  SELECT 1
    FROM rhnConfigChannelType CCT, rhnConfigChannel CC
   WHERE CC.id = :ccid
     AND CC.confchan_type_id = CCT.id
     AND CCT.label = 'normal'
)
EOS

  foreach my $sid (@{$params{server_ids}}) {
    my $i = 1;

    foreach my $ccid (@{$params{config_channel_ids}}) {
      $sth->execute_h(sid => $sid, ccid => $ccid, pos => $i++);
    }
  }

  if ($params{transaction}) {
    return $dbh;
  }
  else {
    $dbh->commit;
  }
}

sub config_channels {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT DISTINCT CC.id, CC.name, SCC.position, CCT.priority, CCT.label AS type
  FROM rhnConfigChannelType CCT,
       rhnConfigChannel CC,
       rhnServerConfigChannel SCC
 WHERE SCC.server_id = :sid
   AND SCC.config_channel_id = CC.id
   AND CC.confchan_type_id = CCT.id
   AND CCT.label IN ('normal', 'local_override')
ORDER BY CCT.priority, SCC.position
EOS
  $sth->execute_h(sid => $self->id);

  my @ret;
  while (my $row = $sth->fetchrow_hashref) {
    push @ret, $row;
  }

  return @ret;
}

sub unlock_server_set {
  my $class = shift;
  my $set = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
DELETE FROM rhnServerLock SL
 WHERE SL.server_id IN (SELECT element FROM rhnSet S WHERE S.user_id = :user_id AND S.label = :label)
EOQ

  $dbh->do_h($query, user_id => $set->uid, label => $set->label);

  $dbh->commit;
}

sub lock_server_set {
  my $class = shift;
  my $set = shift;
  my $locker = shift;
  my $reason = shift;

  $class->unlock_server_set($set);

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
INSERT INTO rhnServerLock (server_id, locker_id, reason)
SELECT S.element, :lid, :reason
  FROM rhnSet S
 WHERE S.user_id = :user_id
   AND S.label = :label
EOQ

  $dbh->do_h($query, lid => ($locker ? $locker->id : undef),
	     reason => $reason, user_id => $set->uid, label => $set->label);

  $dbh->commit;
}

sub check_lock {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT server_id, locker_id USER_ID, reason FROM rhnServerLock WHERE server_id = :server_id");
  $sth->execute_h(server_id => $self->id);

  my $lock = $sth->fetchrow_hashref;
  $sth->finish;

  return $lock;
}

sub load_package_manifest {
  my $self = shift;

  my $mfst = new RHN::Manifest(-org_id => $self->org_id);
  return $mfst->datasource_into_manifest(-ds_class => 'RHN::DataSource::Package',
  						 -ds_mode => 'system_canonical_package_list',
  						 -sid => $self->id,-org_id => $self->org_id);

}

sub systems_subscribed_to_channel {
  my $class = shift;
  my %params = validate(@_, { org_id => 1, cid => 1, user_id => 1 });

  my $ds = new RHN::DataSource::System(-mode => 'systems_subscribed_to_channel');
  return @{ $ds->execute_query(-org_id => $params{org_id},
			       -cid => $params{cid},
			       -user_id => $params{user_id},
			      ) };
}

sub system_packages_missing_from_channels {
  my $self = shift;
  my %params = validate(@_, { channels => 1, transaction => 0 });

  my %trans_args;

  if ($params{transaction}) {
    $trans_args{-transaction} = $params{transaction};
  }

  my %packages;

  foreach my $cid (@{$params{channels}}) {
    my $chan_ds = new RHN::DataSource::Package(-mode => 'packages_in_channel_by_id_combo');
    my $results = $chan_ds->execute_query(-cid => $cid, %trans_args);

    foreach my $package (@{$results}) { # ensure unique package ids
      $packages{$package->{ID}} = $package;
    }
  }
   
  my $channel_manifest = new RHN::Manifest(-org_id => $self->org_id);
  $channel_manifest = $channel_manifest -> datasource_result_into_manifest([ values %packages ]);

  my $sys_ds = new RHN::DataSource::Package(-mode => 'system_canonical_package_list');
  my $results = $sys_ds->execute_query(-sid => $self->id, -org_id => $self->org_id,%trans_args);

  my $system_manifest = new RHN::Manifest(-org_id => $self->org_id);
  $system_manifest = $system_manifest -> datasource_result_into_manifest($results);

  return $system_manifest->packages_not_available_from($channel_manifest);
}

# The hostname of the proxy this system thinks it's connecting to
sub proxy_hostname {
  my $self = shift;

  my $ds = new RHN::DataSource::System(-mode => 'proxy_path_for_server');
  my $data = $ds->execute_query(-sid => $self->id);

  if ($data and ref $data eq 'ARRAY') {
    return $data->[0]->{HOSTNAME};
  }

  return;
}

sub packaging_type {
  my $class_or_self = shift;

  my $sid;

  if (ref $class_or_self) {
    $sid = $class_or_self->id;
  }
  else {
    $sid = shift;
  }

  throw "RHN::Server::packaging_type called without a sid param" unless $sid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT AT.label, AT.name
  FROM rhnArchType AT, rhnServerArch SA, rhnServer S
 WHERE S.id = :sid
   AND S.server_arch_id = SA.id
   AND SA.arch_type_id = AT.id
EOQ

  $sth->execute_h(sid => $sid);

  my ($label, $name) = $sth->fetchrow;
  $sth->finish;

  throw "Could not determine packaging type for server ($sid)" unless $label;

  return $label;
}

sub is_solaris {
  my $self = shift;
  return $self->packaging_type eq 'sysv-solaris';
}

sub system_profile_capable {
  my $class_or_self = shift;

  my $sid;

  if (ref $class_or_self) {
    $sid = $class_or_self->id;
  }
  else {
    $sid = shift;
  }

  throw "RHN::Server::system_profile_capable called without a sid param" unless $sid;

  my $caps = shift;
  throw "RHN::Server::system_profile_capable called without any capabilites" unless $caps;

  my $packaging_type = RHN::Server->packaging_type($sid);
  my @caps = split(/,\s*/, $caps);

  foreach my $cap (@caps) {
    if ($cap eq 'deploy_answer_file') {
      return unless ($packaging_type eq 'sysv-solaris');
    }
    else {
      throw "unknown capability ($cap)";
    }
  }

  return 1;
}

# for a given system event, and package id_combo, give us the results.
sub event_package_results {
  my $class = shift;
  my %params = validate(@_, { sid => 1, id_combo => 1, aid => 1 });

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT SAPR.RESULT_CODE,
       SAPR.STDOUT,
       SAPR.STDERR,
       PN.name || NVL2(PE.evr, ('-' || PE.evr.as_vre_simple()), '') AS NVRE,
       AP.id AS ACTION_PACKAGE_ID,
       PN.id || '|' || PE.id AS ID_COMBO,
       AP.package_arch_id,
       AT.name AS ACTION_TYPE,
       WC.login
  FROM rhnActionType AT,
       web_contact WC,
       rhnAction A,
       rhnServerActionPackageResult SAPR,
       rhnPackageEVR PE,
       rhnPackageName PN,
       rhnActionPackage AP
 WHERE AP.action_id = :aid
   AND AP.name_id = :name_id
   AND AP.evr_id = :evr_id
   AND SAPR.action_package_id = AP.id
   AND SAPR.server_id = :sid
   AND A.id = AP.action_id
   AND AT.id = A.action_type
   AND WC.id(+) = A.scheduler
EOQ

  my ($name_id, $evr_id) = split(/\|/, $params{id_combo});

  $sth->execute_h(aid => $params{aid}, sid => $params{sid}, name_id => $name_id, evr_id => $evr_id);
  my $row = $sth->fetchrow_hashref_copy();
  $sth->finish;

  return $row;
}

# Make a guess at this system's hostname
sub guess_hostname {
  my $self = shift;

  my $hostname = $self->name;

  my @net_infos = $self->get_net_infos;
  foreach my $net_info (@net_infos) {
    next if (not $net_info->hostname || $net_info->hostname =~ /^localhost/);

    $hostname = $net_info->hostname;
  }

  return $hostname;
}

# Make a guess at this system's RHN parent server
sub guess_rhn_parent {
  my $self = shift;

  my $parent = $self->proxy_hostname;

  $parent ||= PXT::Config->get('kickstart_host') || PXT::Config->get('base_domain');

  return $parent;
}

sub cleanup_monitoring_for_system {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  my @statements;

  push @statements, <<EOQ;
DELETE
  FROM state_change
 WHERE o_id IN (SELECT probe_id
                  FROM rhn_check_probe
                 WHERE host_id = :sid)
EOQ

  push @statements, <<EOQ;
DELETE
  FROM time_series
 WHERE SUBSTR(o_id, INSTR(o_id, '-') + 1,
                    (INSTR(o_id, '-', INSTR(o_id, '-') + 1)
                     - INSTR(o_id, '-')
                    ) - 1)
       IN (SELECT probe_id
             FROM rhn_check_probe
            WHERE host_id = :sid)
EOQ

  push @statements, <<EOQ;
DELETE
  FROM rhn_probe
 WHERE recid IN (SELECT probe_id
                   FROM rhn_check_probe
                  WHERE host_id = :sid)
EOQ

  foreach my $stmt (@statements) {
    my $sth = $dbh->prepare($stmt);
    $sth->execute_h(sid => $id);
  }

  $dbh->commit;

  return;
}

sub sat_clusters_for_system {
  my $class = shift;
  my $sid = shift;

  throw "No server id" unless $sid;

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'sat_clusters_for_system');
  my $data = $ds->execute_full(-sid => $sid);

  return @{$data};
}

sub virtual_guest_details {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);

SELECT VI.id,
       VI.host_system_id,
       VI.UUID,
       S.name AS HOST_SYSTEM_NAME
  FROM rhnVirtualInstance VI,
       rhnServer S
 WHERE VI.virtual_system_id = :sid
   AND VI.host_system_id = S.id (+)
EOQ

  $sth->execute_h(sid => $self->id());
  my $results = $sth->fetchrow_hashref();
  $sth->finish;

  return $results;
}

sub virtual_host_details {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT VI.id, 
       VI.host_system_id, 
       VI.UUID, 
       VII.memory_size_k, 
       VII.vcpus, 
       VIT.name as TYPE_NAME, 
       VIT.label AS TYPE_LABEL, 
       VIS.name AS STATE_NAME, 
       VIS.label AS STATE_LABEL, 
       S.name AS HOST_SYSTEM_NAME 
FROM rhnVirtualInstance VI
    inner join rhnVirtualInstanceInfo VII on VII.instance_id = VI.id
    inner join rhnVirtualInstanceType VIT on VIT.id = VII.instance_type 
    inner join rhnVirtualInstanceState VIS on VIS.id = VII.state
    inner join rhnServer S on VI.host_system_id = S.id
WHERE 
    VI.host_system_id = :sid
EOQ

  $sth->execute_h(sid => $self->id());
  my $results = $sth->fetchrow_hashref();
  $sth->finish;

  return $results;
}


sub satellite_cert {
  my $self = shift;
  if (@_) {
    $self->{__cert__} = shift;
  }
  return $self->{__cert__};
}

1;
