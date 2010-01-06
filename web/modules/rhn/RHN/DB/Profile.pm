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

package RHN::DB::Profile;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::Manifest;
use RHN::DataSource::Simple;
use RHN::DataSource::Package;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @p_fields = qw/id org_id base_channel name description info created modified profile_type_id/;

my $p = new RHN::DB::TableClass("rhnServerProfile", "P", "", @p_fields);

sub blank_profile {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create {
  my $class = shift;

  my $p = $class->blank_profile;
  $p->{__id__} = -1;

  $p->set_profile_type('normal');
  return $p;
}

# build some accessors
foreach my $field ($p->method_names) {
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

sub set_profile_type {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id FROM rhnServerProfileType WHERE label = :l');
  $sth->execute_h(l => $label);

  my ($ret) = $sth->fetchrow;
  die "invalid profile type $label" unless defined $ret;

  $self->profile_type_id($ret);
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $p->select_query("P.ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_profile;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $p->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading profile $id; no ID? (@columns)";
  }

  return $ret;
}

sub commit {
  my $self = shift;
  my $transaction = shift;
  my $mode = 'update';

  my $dbh = $transaction || RHN::DB->connect;

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT rhn_server_profile_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on server profile without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;
  if ($mode eq 'update') {
    $query = $p->update_query($p->methods_to_columns(@modified));
    $query .= "P.ID = ?";
  }
  else {
    $query = $p->insert_query($p->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $p->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit unless $transaction;
  delete $self->{":modified:"};
}

sub copy_from {
  my $self = shift;
  my %params = validate(@_, { sid => 0, prid => 0, transaction => 0 });

  die "need sid or prid" unless ($params{sid} or $params{prid});

  my $query;
  my %query_params;

  if ($params{sid}) {
# BZ 145708 - need to add package_arch_id to rhnServerProfilePackage,
# or switch to rhnServerProfilePackage.installed_package_id
    $query =<<EOQ;
INSERT INTO rhnServerProfilePackage
    (server_profile_id, name_id, evr_id)
SELECT :prid, SP.name_id, SP.evr_id
  FROM rhnServerPackage SP
 WHERE SP.server_id = :sid
EOQ

    %query_params = (prid => $self->id,
		     sid => $params{sid},
		    );
  }
  else {
# BZ 145708 - need to add package_arch_id to rhnServerProfilePackage,
# or switch to rhnServerProfilePackage.installed_package_id
    $query =<<EOQ;
INSERT INTO rhnServerProfilePackage
    (server_profile_id, name_id, evr_id)
SELECT :prid, name_id, evr_id
  FROM rhnServerProfilePackage SPP
 WHERE SPP.server_profile_id = :old_prid
EOQ

    %query_params = (prid => $self->id,
		     old_prid => $params{prid},
		    );
  }

  my $dbh = $params{transaction} || RHN::DB->connect;
  my $sth = $dbh->prepare("DELETE FROM rhnServerProfilePackage WHERE server_profile_id = ?");
  $sth->execute($self->id);

  $sth = $dbh->prepare($query);

  $sth->execute_h(%query_params);

  $dbh->commit unless $params{transaction};
}

sub compatible_with_server {
  my $class = shift;
  my $server_id = shift;
  my $org_id = shift;

  my %params = (sid => $server_id);

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
SELECT DISTINCT P.id, P.name
  FROM rhnServer S,
       rhnServerProfile P
 WHERE P.org_id = S.org_id
   AND S.id = :sid
   AND P.profile_type_id = (SELECT id FROM rhnServerProfileType WHERE label = 'normal')
   AND (EXISTS (SELECT 1
                 FROM rhnServerChannel SC
                WHERE SC.server_id = S.id
                  AND SC.channel_id = P.base_channel)
       OR EXISTS (SELECT 1
                    FROM rhnChannel C
                   WHERE C.id = P.base_channel
                     AND C.org_id $org_string
                     AND C.parent_channel IS NULL) )

EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(%params);

  my @ret;
  while (my @data = $sth->fetchrow) {
    push @ret, [ @data ];
  }

  return @ret;
}

sub compatible_with_channel {
  my $class = shift;
  my %params = validate(@_, { cid => 1, org_id => 1 });

  my $ds = new RHN::DataSource::Simple(-querybase => "profile_queries", -mode => "compatible_with_channel");
  return @{$ds->execute_query( map { ("-$_", $params{$_} ) } keys %params )};
}

sub canonical_package_list {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT SPP.name_id, PN.name, SPP.evr_id, SPPE.evr.as_vre_simple(), SPPE.epoch, SPPE.version, SPPE.release
  FROM rhnPackageName PN,
       rhnPackageEVR SPPE,
       rhnServerProfilePackage SPP
 WHERE PN.id = SPP.name_id
   AND SPPE.id = SPP.evr_id
   AND SPP.server_profile_id = ?
ORDER BY upper(PN.name), SPPE.evr
EOS
  $sth->execute($self->id);

  my @packages;

  while (my @row = $sth->fetchrow) {
    push @packages, \@row;
  }

  return @packages;
}

sub load_package_manifest {
  my $self = shift;
  my $mfst = new RHN::Manifest(-org_id => $self->org_id);
  return $mfst->datasource_into_manifest(-ds_class => 'RHN::DataSource::Package',
						 -ds_mode => 'profile_canonical_package_list',
						 -prid => $self->id,-org_id => $self->org_id);

}

sub profile_packages_missing_from_channels {
  my $self = shift;
  my %params = validate(@_, { channels => 1, transaction => 0 });

  my %trans_args;

  if ($params{transaction}) {
    $trans_args{-transaction} = $params{transaction};
  }

  my %packages;

  foreach my $cid (@{$params{channels}}) {
    my $chan_ds = new RHN::DataSource::Package(-mode => 'packages_in_channel_by_id_combo');
    my $results = $chan_ds->execute_query(-cid => $cid,%trans_args);

    foreach my $package (@{$results}) { # ensure unique package ids
      $packages{$package->{ID}} = $package;
    }
  }

  my $channel_manifest = new RHN::Manifest(-org_id => $self->org_id);
  $channel_manifest = $channel_manifest -> datasource_result_into_manifest([ values %packages ]);

  my $prof_ds = new RHN::DataSource::Package(-mode => 'profile_canonical_package_list');
  my $results = $prof_ds->execute_query(-prid => $self->id,-org_id => $self->org_id, %trans_args);

  my $profile_manifest = new RHN::Manifest(-org_id => $self->org_id);
  $profile_manifest = $profile_manifest -> datasource_result_into_manifest($results);

  return $profile_manifest->packages_not_available_from($channel_manifest);
}

sub create_from_system {
  my $class = shift;
  my %params = validate(@_, { sid => 1, org_id => 1, name => 1, description => 1, type => 1, transaction => 0 });

  my $profile = RHN::Profile->create;

  $profile->org_id($params{org_id});

  $profile->base_channel(RHN::Server->base_channel_id($params{sid}));
  $profile->name($params{name});
  $profile->description($params{description});
  $profile->set_profile_type($params{type});

  $profile->commit($params{transaction});
  $profile->copy_from(-sid => $params{sid}, -transaction => $params{transaction});

  return $profile;
}

# goofy, but useful
sub base_channel_id {
  my $self = shift;

  return $self->base_channel;
}

1;
