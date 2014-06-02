#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package RHN::DB::SystemSnapshot;

use strict;

use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

use Carp;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::DataSource::Channel;
use RHN::DataSource::SystemGroup;
use RHN::DataSource::Package;
use RHN::DataSource::ConfigChannel;
use RHN::Exception;
use RHN::Manifest;

use RHN::Action ();
use RHN::DataSource::Simple ();
use RHN::Date ();
use RHN::Scheduler ();
use RHN::Server ();
use RHN::SystemSnapshot ();

my @s_fields = qw/id org_id server_id created:longdate modified:longdate/;
my @i_fields = qw/id label name/;

my $s_table = new RHN::DB::TableClass("rhnSnapshot", "S", "", @s_fields);
my $i_table = new RHN::DB::TableClass("rhnSnapshotInvalidReason", "IR", "invalid_reason", @i_fields);

my $j = $s_table->create_join([$i_table],
			      {
			       "rhnSnapshot" =>
			       {
				"rhnSnapshot" => ["ID", "ID"],
				"rhnSnapshotInvalidReason" => ["INVALID", "ID"],
			       }
			      },
			     {
			      rhnSnapshotInvalidReason => "(+)"
			     });



foreach my $field ($j->method_names) {
   my $sub = q {
       sub [[field]] {
         my $self = shift;
         if (@_) {
           if ($self->{__newly_created__}) {
             my $value = shift;
             $self->{":modified:"}->{[[field]]} = 1;
             $self->{__[[field]]__} = $value;
           }
           else {
             croak "RHN::DB::SystemSnapshot->[[field]] cannot be used to set a value at this time.  It may be a read-only accessor.";
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

sub gen_diff {
  my $self = shift;
  my %params = validate(@_, {current => 1, snapshot => 1});

  my %universe = map {$_->{ID} => {snapshot => 1}} @{$params{snapshot}};

  foreach my $current (@{$params{current}}) {
    $universe{$current->{ID}}->{current} = 1;
  }

  my @diffs;

  foreach my $id (keys %universe) {
    unless ((exists $universe{$id}->{current}) and (exists $universe{$id}->{snapshot})) {
      push @diffs, {$id => (keys %{$universe{$id}})[0]};
    }
  }

  return @diffs;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my @columns;

  my $dbh = RHN::DB->connect;
  my $sqlstmt;

  $sqlstmt = $j->select_query("S.ID = ?");

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;

  if ($columns[0]) {
    $ret = bless {}, $class;

    foreach ($j->method_names) {
      $ret->{"__".$_."__"} = shift @columns;
    }

    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    throw '(snapshot_does_not_exist)';
  }

  return $ret;
}


sub add_tag_to_snapshot {
  my $class = shift;
  my %params = validate(@_, {org_id => 1,
			     snapshot_id => 1,
			     tag_name => 1,
			     transaction => 0});

  my $dbh = $params{transaction} || RHN::DB->connect;

  $dbh->call_procedure('rhn_server.tag_snapshot', $params{snapshot_id}, $params{org_id}, $params{tag_name});

  $dbh->commit unless $params{transaction};
  return $dbh if $params{transaction};
}


sub bulk_snapshot_tag {
  my $class = shift;
  my %params = validate(@_, {user_id => 1,
			     org_id => 1,
			     set_label => 1,
			     tag_name => 1,
			     transaction => 0,
			    });

  my $dbh = $params{transaction} || RHN::DB->connect;
  $dbh->call_procedure('rhn_server.bulk_snapshot_tag',
		       $params{org_id},
		       $params{tag_name},
		       $params{set_label},
		       $params{user_id},
		      );

  $dbh->commit unless $params{transaction};
  return $dbh if $params{transaction};
}

sub snapshot_configfiles_list {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, snapshot_id => 1});

  my $ds = new RHN::DataSource::Simple(-querybase => 'config_queries', -mode => 'configfiles_for_snapshot');
  my $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id});

  return $data;
}


sub snapshot_config_channel_list {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, snapshot_id => 1});

  my $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_for_snapshot');
  my $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id});

  return $data;
}

sub snapshot_channel_list {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, snapshot_id => 1});

  my $ds = new RHN::DataSource::Channel(-mode => "system_snapshot_channel_list");
  my $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id});

  return $data;
}

sub snapshot_group_list {
  my $class = shift;
  my %params = validate(@_, {user_id => 1, server_id => 1, snapshot_id => 1});

  my $ds = new RHN::DataSource::SystemGroup(-mode => "system_snapshot_group_list");
  my $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id}, -user_id => $params{user_id});

  return $data;
}


sub snapshot_pkg_delta {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, snapshot_id => 1});

  my $current_ds = new RHN::DataSource::Package(-mode => "system_package_list");
  my $current_data = $current_ds->execute_query(-sid => $params{server_id});


  my $snapshot_ds = new RHN::DataSource::Package(-mode => "system_snapshot_package_list");
  my $snapshot_data = $snapshot_ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id}, -org_id => $params{org_id});

  my $current_manifest = RHN::Manifest->new(-org_id => $params{org_id});
  $current_manifest->datasource_result_into_manifest($current_data);

  my $snapshot_manifest = RHN::Manifest->new(-org_id => $params{org_id});
  $snapshot_manifest->datasource_result_into_manifest($snapshot_data);

  # do comparison... diff only.
  my $comparison = $snapshot_manifest->compare_manifests($current_manifest, 1);

  return $comparison;
}

1;
