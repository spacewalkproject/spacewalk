#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package RHN::DB::Channel;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use RHN::DB::TableClass;
use RHN::Channel ();
use RHN::DataSource::Channel ();
use RHN::Server ();

use Carp;

use RHN::Exception qw/throw/;

#######################################
# Channel Object code
#######################################

my @channel_fields = qw/ID PARENT_CHANNEL ORG_ID CHANNEL_ARCH_ID LABEL BASEDIR NAME SUMMARY DESCRIPTION GPG_KEY_URL GPG_KEY_ID GPG_KEY_FP PRODUCT_NAME_ID END_OF_LIFE:dayofyear LAST_MODIFIED:longdate CHANNEL_ACCESS/;
my @arch_fields = qw/ID NAME LABEL/;

my $c = new RHN::DB::TableClass("rhnChannel", "C", "", @channel_fields);
my $a = new RHN::DB::TableClass("rhnChannelArch", "CA", "arch", @arch_fields);

my $j = $c->create_join(
			[$a],
			{
			 "rhnChannel" =>
			 {
			  "rhnChannel" => ["ID","ID"],
			  "rhnChannelArch" => ["CHANNEL_ARCH_ID","ID"]
			 }
			}
		       );

# build some accessors
foreach my $field ($j->method_names) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = shift;
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


sub commit {
  my $self = shift;
  my $transaction = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = $transaction || RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_channel_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new channel id from seq rhn_channel_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on channel without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = $transaction || RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $c->update_query($c->methods_to_columns(@modified));
    $query .= "C.ID = ?";
  }
  else {
    $query = $c->insert_query($c->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $c->method_names), ($mode eq 'update') ? ($self->id) : ());

#  if ($mode eq 'insert') {
#    $sth = $dbh->prepare('INSERT INTO rhnChannelPermissions (channel_id, org_id) VALUES (?, ?)');
#    $sth->execute($self->id, $self->org_id);
#  }

  $dbh->commit unless $transaction;
  delete $self->{":modified:"};
}


sub is_eoled {
  my $self = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnChannel
 WHERE id = :channel_id
   AND sysdate - end_of_life > 0
EOQ

  $sth->execute_h(channel_id => $self->id);

  my ($row) = $sth->fetchrow;
  $sth->finish;

  return $row;
}

sub is_protected {
  my $self = shift;
  return ($self->channel_access() eq 'protected') ? 1 : 0; 
}

sub license_path {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;

  return $dbh->call_function('rhn_channel.get_license_path', $cid);
}

sub parent {
  my $self = shift;
  my $channel = shift;

  if (defined $channel) {
    $channel = RHN::Channel->lookup(-id => $channel);
  }
  else {
    $channel = $self;
  }

  return undef unless $channel->parent_channel;

  my $parent = RHN::DB::Channel->lookup(-id => $channel->parent_channel);

  return $parent;
}

#returns the total number of packages in a given channel id.
sub package_count {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT COUNT(1) FROM rhnChannelPackage WHERE channel_id = ?');

  $sth->execute($cid);

  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}

#same as above, but uses rhnChannelNewestPackage to only count the latest packages, not previous versions
sub applicable_package_count {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT COUNT(P.package_id) FROM rhnChannelPackage P WHERE channel_id = ?');

  $sth->execute($cid);

  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}

sub children {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT id FROM rhnchannel WHERE parent_channel = ?
EOQ

  $sth->execute($cid);
  my @ret;

  while (my ($id) = $sth->fetchrow) {
    push @ret, $id;
  }

  return @ret;
}

sub trusted_orgs {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }
  die "No channel id" unless defined $cid;
  my $trust_orgs = {};
  foreach my $sid ($self->servers) {
    my $server = RHN::Server->lookup(-id => $sid);
    $trust_orgs->{$server->org_id} += 1 if $server->org_id != $self->org_id;
  }

  return keys %{$trust_orgs};
}


################################
# Channel package functions
################################

my %proxy_chans_by_version = ('1.1' => ['redhat-rhn-proxy-as-i386-2.1', 'redhat-rhn-proxy-i386-7.2'],
			      '3.2' => ['redhat-rhn-proxy-3.2-as-i386-2.1'],
			      '3.6' => ['redhat-rhn-proxy-3.6-as-i386-2.1', 'redhat-rhn-proxy-3.6-as-i386-3'],
			      '3.7' => ['redhat-rhn-proxy-3.7-as-i386-2.1', 'redhat-rhn-proxy-3.7-as-i386-3',
 					'redhat-rhn-proxy-3.7-as-i386-4'],
                   '4.0' => ['redhat-rhn-proxy-4.0-as-i386-3',
        		   			'redhat-rhn-proxy-4.0-as-i386-4',
                           'redhat-rhn-proxy-4.0-as-x86_64-4'],
                   '4.1' => ['redhat-rhn-proxy-4.1-as-i386-3',
                             'redhat-rhn-proxy-4.1-as-i386-4'],
                   '4.2' => ['redhat-rhn-proxy-4.2-as-i386-3',
                             'redhat-rhn-proxy-4.2-as-i386-4'],
                   '5.0' => ['redhat-rhn-proxy-5.0-as-i386-4'],
                   '5.1' => ['redhat-rhn-proxy-5.1-as-i386-4',
                             'redhat-rhn-proxy-5.1-as-x86_64-4',
                             'redhat-rhn-proxy-5.1-as-s390-4',
                             'redhat-rhn-proxy-5.1-as-s390x-4'],
                   '5.2' => ['redhat-rhn-proxy-5.2-as-i386-4',
                             'redhat-rhn-proxy-5.2-as-x86_64-4',
                             'redhat-rhn-proxy-5.2-as-s390-4',
                             'redhat-rhn-proxy-5.2-as-s390x-4',
                             'redhat-rhn-proxy-5.2-server-i386-5',
                             'redhat-rhn-proxy-5.2-server-x86_64-5',
                             'redhat-rhn-proxy-5.2-server-s390x-5',
                            ],
                   '5.3' => ['redhat-rhn-proxy-5.3-as-i386-4',
                         'redhat-rhn-proxy-5.3-as-x86_64-4',
                         'redhat-rhn-proxy-5.3-as-s390-4',
                         'redhat-rhn-proxy-5.3-as-s390x-4',
                         'redhat-rhn-proxy-5.3-server-i386-5',
                         'redhat-rhn-proxy-5.3-server-x86_64-5',
                         'redhat-rhn-proxy-5.3-server-s390x-5',
                            ],

			     );


sub proxy_channel_versions {
  my $class = shift;
  return sort(keys %proxy_chans_by_version);
}

sub proxy_channels_by_version {
  my $class = shift;
  my %params = validate(@_, { version => {type => Params::Validate::SCALAR } });

  if (not exists $proxy_chans_by_version{$params{version}}) {
    die "invalid proxy version";
  }

  return @{$proxy_chans_by_version{$params{version}}};
}


sub available_channels_with_license {
  my $class = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT AC.channel_id, AC.channel_label, AC.channel_name
  FROM rhnChannelFamilyLicense CFL, rhnChannelFamilyMembers CFM, rhnAvailableChannels AC
 WHERE AC.org_id = ?
   AND AC.channel_id = CFM.channel_id
   AND CFM.channel_family_id = CFL.channel_family_id
ORDER BY UPPER(AC.channel_name)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($org_id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub has_downloads {
  my $class = shift;
  my $cid = shift;

  die "no cid" unless $cid;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT 1 FROM rhnChannelDownloads WHERE channel_id = :cid
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(cid => $cid);

  my @row = $sth->fetchrow;
  $sth->finish;

  return 1 if @row;

  return 0;
}

sub tri_state_channel_list {
  my $class = shift;
  my $org_id = shift;
  my $user_id = shift;

  my $ds = new RHN::DataSource::Channel(-mode => 'tri_state_channel_list');
  my $channels = $ds->execute_query(-user_id => $user_id);

  return @$channels;
}

sub subscribable_channels {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, user_id => 1, base_channel_id => 1});

  my $ds = new RHN::DataSource::Channel(-mode => 'subscribable_channels');
  my $channels = $ds->execute_query(-server_id => $params{server_id},
				    -user_id => $params{user_id},
				    -base_channel_id => $params{base_channel_id});

  return @$channels;
}


sub compat_channels_owned_by_org {
  my $class = shift;
  my $org_id = shift;
  my $channel_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  if ($org_id eq 'NULL') {
    $query = <<EOQ;
  SELECT  C1.name, C1.id
    FROM  rhnChannel C2, rhnChannel C1
   WHERE  C1.org_id is NULL
     AND  C2.id = ?
     AND  C1.channel_arch_id = C2.channel_arch_id
ORDER BY  C1.org_id DESC, C1.name
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($channel_id);
  }
  else {
    $query = <<EOQ;
  SELECT  C1.name, C1.id
    FROM  rhnChannel C2, rhnChannel C1
   WHERE  C1.org_id = ?
     AND  C2.id = ?
     AND  C1.channel_arch_id = C2.channel_arch_id
ORDER BY  C1.org_id DESC, C1.name
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($org_id, $channel_id);
  }
  my @channels;

  while (my @row = $sth->fetchrow) {
    push @channels, [ $row[0], 'channel_' . $row[1] ];
  }

  return @channels;
}

sub channels_owned_by_org {
  my $class = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  if ($org_id eq 'NULL') {

  $query = <<EOQ;
   SELECT C.name, C.id
    FROM rhnChannel C
   WHERE C.org_id IS NULL
ORDER BY C.org_id, C.name
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute();
  }
  else {
    $query = <<EOQ;
   SELECT C.name, C.id
    FROM rhnChannel C
   WHERE C.org_id = ?
ORDER BY C.org_id, C.name
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($org_id);

  }

  my @channels;

  while (my @row = $sth->fetchrow) {
    push @channels, [ $row[0], 'channel_' . $row[1] ];
  }

  return @channels;
}

sub cloned_channels_owned_by_org {
  my $class = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  if ($org_id eq 'NULL') {

  $query = <<EOQ;
   SELECT C.name, C.id
    FROM rhnChannel C
   WHERE EXISTS (SELECT 1 FROM rhnChannelCloned CC
                  WHERE CC.id = C.id
                )
ORDER BY C.org_id, C.name
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute();
}
  else {
    $query = <<EOQ;
   SELECT C.name, C.id
    FROM rhnChannel C
   WHERE C.org_id = ?
     AND EXISTS (SELECT 1 FROM rhnChannelCloned CC
                  WHERE CC.id = C.id
                )
ORDER BY C.org_id, C.name
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($org_id);

  }

  my @channels;

  while (my @row = $sth->fetchrow) {
    push @channels, [ $row[0], 'channel_' . $row[1] ];
  }

  return @channels;
}


sub package_groups {
  my $class = shift;
  my $channel_id = shift;

    my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT PN.name, PN.name || '-' || EVR.version || '-' ||  EVR.release || DECODE(EVR.epoch, NULL, '', ':' || EVR.epoch) NVRE, PG.name, PO.name_id || '|' || PO.evr_id, PA.name
  FROM rhnPackageArch PA, rhnChannelPackage CP, rhnPackageGroup PG, rhnPackageName PN, rhnPackageEVR EVR, rhnPackage PO
 WHERE CP.channel_id = ?
   AND PO.id = CP.package_id
   AND PG.id = PO.package_group
   AND PO.name_id = PN.id
   AND PO.evr_id = EVR.id
   AND PO.package_arch_id = PA.id
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute($channel_id);

  my %groups;
  while (my @row = $sth->fetchrow) {
    $row[2] =~ s/\s*$//;
    $row[2] =~ s/Enviornment/Environment/; # fix a typo in an old glibc pkg
    my ($upper, $lower) = split m(/), $row[2], 2;
    $lower ||= '';

    push @{$groups{$upper}->{$lower}}, [ $row[0], $row[1], $row[3], $row[4] ];
  }

  return \%groups;

}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $j->select_query("C.ID = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_channel;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $j->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading channel $id; no ID? (@columns)";
  }

  return $ret;
}

sub blank_channel {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create_channel {
  my $class = shift;

  my $org = $class->blank_channel;
  $org->{__id__} = -1;

  return $org;
}



sub channel_id_by_label {
  my $class = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT C.id FROM rhnChannel C WHERE C.label = ?');
  $sth->execute($label);

  my ($id) = $sth->fetchrow;
  $sth->finish;

  return $id;
}


sub channel_entitlement_overview {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT CFO.id, CFO.name, CFO.current_members, CFO.max_members, CFO.has_subscription, CFO.url
  FROM rhnChannelFamilyOverview CFO
 WHERE CFO.org_id = ?
EOQ
  $sth->execute($org_id);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

#adopt channel into channel_famil(y|ies)
sub adopt_into_family {
  my $self = shift;
  my $family_ids = shift;

  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;

  die "No family_ids" unless (ref $family_ids eq 'ARRAY');
  die "no channel_id or channel object" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
INSERT INTO rhnChannelFamilyMembers
            (channel_id, channel_family_id)
     VALUES (?, ?)
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $fid (@{$family_ids}) {
    $sth->execute($cid, $fid);
  }

  $dbh->commit;
}

sub packages_in_channel {
  my $class = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth;

  my $query = <<EOQ;
SELECT DISTINCT PN.name, PE.epoch, PE.version, PE.release, E.id, E.advisory, E.synopsis
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnErrata E,
       rhnPackage P,
       rhnErrataPackage EP,
       rhnChannelErrata CE,
       rhnChannelPackage CP
 WHERE CP.channel_id = (SELECT id FROM rhnChannel WHERE label = ?)
   AND CP.package_id = P.id
   AND CP.channel_id = CE.channel_id
   AND EP.package_id(+) = P.id
   AND EP.errata_id = CE.errata_id
   AND EP.errata_id = E.id(+)
   AND PN.id = P.name_id
   AND PE.id = P.evr_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($label);

  my @ret;
  while (my @row = $sth->fetchrow) {
    my $h;

    $h->{nevr} = "$row[0]-$row[2]-$row[3]";
    $h->{nevr} .= ":$row[1]" if defined $row[1];

    for my $n (qw/name epoch version release errata_id errata_advisory errata_synopsis/) {
      $h->{$n} = shift @row || '';
    }

    push @ret, $h;
  }

  return @ret;
}

sub distros {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT id FROM rhnKickstartableTree WHERE channel_id = ?
EOQ

  $sth->execute($cid);
  my @ret;

  while (my ($tree_id) = $sth->fetchrow) {
    push @ret, $tree_id;
  }

  return @ret;
}


sub servers {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT server_id FROM rhnServerChannel WHERE channel_id = ?
EOQ

  $sth->execute($cid);
  my @ret;

  while (my ($sid) = $sth->fetchrow) {
    push @ret, $sid;
  }

  return @ret;
}

sub rhn_proxy_channels {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  CFM.channel_id
  FROM  rhnChannelFamilyMembers CFM, rhnChannelFamily CF
 WHERE  CF.label = 'rhn-proxy'
   AND  CF.id = CFM.channel_family_id
EOQ

  $sth->execute();

  my @ret;
  while (my ($id) = $sth->fetchrow) {
    push @ret, $id;
  }

  return @ret;
}

sub rhn_satellite_channels {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
SELECT  CFM.channel_id
  FROM  rhnChannelFamilyMembers CFM, rhnChannelFamily CF
 WHERE  CF.label = 'rhn-satellite'
   AND  CF.id = CFM.channel_family_id
EOQ

  my $sth = $dbh->prepare($query);

  $sth->execute();

  my @ret;
  while (my ($id) = $sth->fetchrow) {
    push @ret, $id;
  }

  return @ret;
}

# what family is this channel in
sub family {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  CF.id, CF.name, CF.label, CF.product_url, CF.org_id
  FROM  rhnChannelFamily CF, rhnChannelFamilyMembers CFM
 WHERE  CFM.channel_id = :cid
   AND  CF.id = CFM.channel_family_id
EOQ

  $sth->execute_h(cid => $cid);
  my ($row) = $sth->fetchrow_hashref;

  $sth->finish;

  return $row;
}



sub packages {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  die "No channel id" unless defined $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT package_id FROM rhnChannelPackage WHERE channel_id = ?
EOQ

  $sth->execute($cid);
  my @ret;

  while (my ($pid) = $sth->fetchrow) {
    push @ret, $pid;
  }

  return @ret;
}

sub refresh_newest_package_cache {
  my $self = shift;
  my $cid;

  if (ref $self) {
    $cid = $self->id;
  }
  else {
    $cid = shift;
  }

  undef $self;
  my $label = shift;

  die "No channel id" unless $cid;
  die "No label" unless $label;

  my $dbh = RHN::DB->connect;

  $dbh->call_procedure('rhn_channel.refresh_newest_package', $cid, $label);

  $dbh->commit;

  return;
}

sub set_cloned_from {
  my $self = shift;
  my $from_cid = shift;

  die "No channel id" unless $from_cid;
  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
DELETE
  FROM rhnChannelCloned CC
 WHERE CC.id = :cid
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(cid => $self->id);

  $query = <<EOQ;
INSERT
  INTO rhnChannelCloned
       (original_id, id, created, modified)
VALUES (:from_cid, :to_cid, sysdate, sysdate)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(from_cid => $from_cid, to_cid => $self->id);

  $dbh->commit;

  return;
}

sub channel_cloned_from {
  my $class = shift;
  my $cid = shift;

  die "No cid" unless $cid;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT CC.original_id
  FROM rhnChannelCloned CC
 WHERE CC.id = :cid
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(cid => $cid);

  my ($progenitor) = $sth->fetchrow;
  $sth->finish;

  return $progenitor;
}

sub relationships {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT CC.original_id, 'cloned_from', 'was cloned from'
  FROM rhnChannelCloned CC
 WHERE CC.id = :cid
EOQ

  my $sth = $dbh->prepare($query);

  $sth->execute_h(cid => $self->id);

  my %ret;

  while (my ($id, $label, $descrip) = $sth->fetchrow) {
    $ret{$self->id}->{$label}->{description} = $descrip;
    push @{$ret{$self->id}->{$label}->{channels}}, $id;
  }

  $query = <<EOQ;
SELECT CC.id, 'cloned_from', 'was cloned from'
  FROM rhnChannelCloned CC
 WHERE CC.original_id = :cid
EOQ

  $sth = $dbh->prepare($query);

  $sth->execute_h(cid => $self->id);

  while (my ($id, $label, $descrip) = $sth->fetchrow) {
    $ret{$id}->{$label}->{description} = $descrip;
    push @{$ret{$id}->{$label}->{channels}}, $self->id;
  }

  return %ret;
}

sub remove_packages_in_set {
  my $self = shift;
  my %attr = validate_with(params => \@_, spec => { set_label => 1, user_id => 1 }, strip_leading => '-');

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhnChannelPackage CP
 WHERE CP.channel_id = :cid
   AND CP.package_id IN (SELECT S.element FROM rhnSet S WHERE S.user_id = :user_id AND S.label = :set_label)
EOQ

  $sth->execute_h(%attr, cid => $self->id);

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::remove_packages_in_set', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  $sth->execute_h(label => $self->label);

  $dbh->call_procedure('rhn_channel.update_channel', $self->id);

  $dbh->commit;

  return;
}

sub add_packages_in_set {
  my $self = shift;
  my %attr = validate_with(params => \@_, spec => { set_label => 1, user_id => 1 });

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnChannelPackage
       (channel_id, package_id)
       SELECT :cid, S.element 
         FROM rhnSet S 
        WHERE S.user_id = :user_id
          AND S.label = :set_label
          AND NOT EXISTS (SELECT 1 FROM rhnChannelPackage CP2 WHERE CP2.channel_id = :cid AND CP2.package_id = S.element)
EOQ

  $sth->execute_h(%attr, cid => $self->id);

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::add_packages_in_set', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  $sth->execute_h(label => $self->label);

  $dbh->call_procedure('rhn_channel.update_channel', $self->id);

  $dbh->commit;

  return;
}

sub package_by_filename_in_tree {
  my $self = shift;
  my $filename = shift;

  die "Invalid filename: contains naughty bits" if $filename =~ m(/);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT P.id, P.path
  FROM rhnPackage P,
       rhnChannelPackage CP,
       rhnChannel C
 WHERE (C.id = :cid OR C.parent_channel = :cid)
   AND CP.channel_id = C.id
   AND CP.package_id = P.id
   AND P.path LIKE :pathlike
EOQ

  $sth->execute_h(cid => $self->id, pathlike => "%/$filename");
  my ($pid, $path) = $sth->fetchrow;

  $sth->finish();
  return ($pid, $path);
}

sub packaging_type {
  my $class_or_self = shift;

  my $cid;

  if (ref $class_or_self) {
    $cid = $class_or_self->id;
  }
  else {
    $cid = shift;
  }

  throw "RHN::Channel::packaging_type called without a cid param" unless $cid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT AT.label, AT.name
  FROM rhnArchType AT, rhnChannelArch CA, rhnChannel C
 WHERE C.id = :cid
   AND C.channel_arch_id = CA.id
   AND CA.arch_type_id = AT.id
EOQ

  $sth->execute_h(cid => $cid);

  my ($label, $name) = $sth->fetchrow;
  $sth->finish;

  throw "Could not determine packaging type for channel ($cid)" unless $label;

  return $label;
}

sub is_solaris {
 my $self = shift; 
 return ($self->packaging_type() eq 'sysv-solaris') ? 1 : 0;
}

sub channel_type_capable {
  my $class_or_self = shift;

  my $cid;

  if (ref $class_or_self) {
    $cid = $class_or_self->id;
  }
  else {
    $cid = shift;
  }

  throw "RHN::Channel::channel_type_capable called without a cid param" unless $cid;

  my $caps = shift;
  throw "RHN::Channel::channel_type_capable called without any capabilites" unless $caps;

  my $packaging_type = RHN::Channel->packaging_type($cid);
  my @caps = split(/,\s*/, $caps);

  foreach my $cap (@caps) {
    if ($cap eq 'errata') {
      return unless ($packaging_type eq 'rpm');
    }
    else {
      throw "unknown capability ($cap)";
    }
  }

  return 1;
}

1;
