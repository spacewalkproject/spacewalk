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

package RHN::DB::SystemSnapshot;

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
           if ($rw_fields{[[field]]} or $self->{__newly_created__}) {
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

sub group_diffs {
  my $self = shift;
  my $org_id = shift;

  my $ds = new RHN::DataSource::SystemGroup;

  $ds->mode('system_snapshot_group_list');
  my $snapshot_groups = $ds->execute_query(-user_id => undef, -sid => $self->server_id, -ss_id => $self->id);

  $ds->mode('groups_a_system_is_in');
  my $current_groups = $ds->execute_query(-sid => $self->server_id, -user_id => undef, -org_id => $org_id);

  return $self->gen_diff(current => [grep {not $_->{GROUP_TYPE_LABEL}} @{$current_groups}],
			 snapshot => [grep {not $_->{GROUP_TYPE_LABEL}} @{$snapshot_groups}],
			);
}

sub channel_diffs {
  my $self = shift;

  my $ds = new RHN::DataSource::Channel;

  $ds->mode('system_snapshot_channel_list');
  my $snapshot_channels = $ds->execute_query(-user_id => undef, -sid => $self->server_id, -ss_id => $self->id);

  $ds->mode('system_channels');
  my $current_channels = $ds->execute_query(-sid => $self->server_id, -user_id => undef, -org_id => $org_id);

 return $self->gen_diff(current => $current_channels,
			 snapshot => $snapshot_channels,
			);
}

sub package_diffs {
  my $self = shift;


  my $ds = new RHN::DataSource::Package;

  $ds->mode('snapshot_canonical_package_list');
  my $snapshot_packages = $ds->execute_query(-user_id => undef, -sid => $self->server_id, -ss_id => $self->id, -org_id => $self->org_id);

  $ds->mode('system_canonical_package_list');
  my $current_packages = $ds->execute_query(-sid => $self->server_id, -user_id => undef, -org_id => $org_id);

 return $self->gen_diff(current => $current_packages,
			snapshot => $snapshot_packages,
		       );

}

sub package_list_is_servable {
  my $self = shift;

  my $ds = new RHN::DataSource::Package;

  $ds->mode('snapshot_unservable_package_list');
  my $unservable_packages = $ds->execute_query(-sid => $self->server_id, -ss_id => $self->id, -org_id => $self->org_id);

  return (not @{$unservable_packages});
}

sub config_channel_diffs {
  my $self = shift;


  my $ds = new RHN::DataSource::ConfigChannel;

  $ds->mode('normal_namespaces_for_snapshot');
  my $snapshot_config_channels = $ds->execute_query(-user_id => undef, -sid => $self->server_id, -ss_id => $self->id);

  $ds->mode('normal_namespaces_for_system');
  my $current_config_channels = $ds->execute_query(-sid => $self->server_id, -user_id => undef, -org_id => $org_id);

 return $self->gen_diff(current => $current_config_channels,
			snapshot => $snapshot_config_channels,
		       );

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

  $ds = new RHN::DataSource::Simple(-querybase => 'config_queries', -mode => 'configfiles_for_snapshot');
  $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id});

  return $data;
}


sub snapshot_config_channel_list {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, snapshot_id => 1});

  $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_for_snapshot');
  $data = $ds->execute_query(-sid => $params{server_id}, -ss_id => $params{snapshot_id});

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

  my $current_manifest = RHN::Manifest->new(-org_id => $org_id);
  $current_manifest->datasource_result_into_manifest($current_data);

  my $snapshot_manifest = RHN::Manifest->new(-org_id => $org_id);
  $snapshot_manifest->datasource_result_into_manifest($snapshot_data);

  # do comparison... diff only.
  my $comparison = $snapshot_manifest->compare_manifests($current_manifest, 1);

  return $comparison;
}

sub rollback_to_snapshot {
  my $class = shift;
  my %params = validate(@_, {user_id => 1,
			     org_id => 1,
			     server_id => 1,
			     snapshot_id => 1,
			     transaction => 0,
			    });

  my $sid = $params{server_id};
  my $snapshot_id = $params{snapshot_id};

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server obj" unless $server;

  my $transaction = $params{transaction} || RHN::DB->connect();

  my $user_id = $params{user_id};
  my $org_id = $params{org_id};

  my $last_aid;

  # returned for messaging reasons...
  my $is_some_pkg_delta;
  my $deployed_config_files;

  eval {
    # 1.  remove system from all pending scheduled actions
    $transaction = RHN::Action->cancel_pending_for_system(-server_id => $sid,
							  -transaction => $transaction);



    # 2.  a) unsubscribe from all channels
    #     b) subscribe to appropriate channels

    my $ds = new RHN::DataSource::Channel(-mode => "system_channels");
    my $data = $ds->execute_query(-sid => $sid);

    my @channels = map {$_->{LABEL}} @{$data};

    foreach my $chan_label (@channels) {
      $transaction = $server->unsubscribe_from_channel($chan_label, $transaction);
    }

    my $channels = RHN::SystemSnapshot->snapshot_channel_list(server_id => $sid,
							      snapshot_id => $snapshot_id);

    foreach my $chan_label (map {$_->{LABEL}} @{$channels}) {
      $transaction = $server->subscribe_to_channel($chan_label, $transaction);
    }



    # 3.  a) remove from all groups
    #     b) add to appropriate groups
    $ds = new RHN::DataSource::SystemGroup(-mode => 'groups_a_system_is_in_unsafe');
    $data = $ds->execute_query(-sid => $sid, -org_id => $org_id);

    $transaction = RHN::Server->remove_servers_from_groups([ $sid ], [ map {$_->{ID}} @{$data} ], $transaction);

    my $groups = RHN::SystemSnapshot->snapshot_group_list(server_id => $sid,
							  snapshot_id => $snapshot_id,
							  user_id => $user_id,
							 );

    $transaction = RHN::Server->add_servers_to_groups([ $sid ], [ map {$_->{ID}} @{$groups} ], $transaction);



    # 4.  schedule package delta, if needed
    if ($server->client_capable('packages.runTransaction')) {
      my $comparison = RHN::SystemSnapshot->snapshot_pkg_delta(server_id => $sid,
							       snapshot_id => $snapshot_id);
      $is_some_pkg_delta = 1 if @{$comparison};

      if ($is_some_pkg_delta) {
	my $pkg_delta_aid;
	($pkg_delta_aid, $transaction) = RHN::Scheduler->schedule_package_sync(org_id => $org_id,
									       user_id => $user_id,
									       server_id => $sid,
									       earliest => RHN::Date->now->long_date,
									       comparison => $comparison,
									       action_name => "Package sync to System Snapshot",
									       transaction => $transaction,
									       prerequisite => $last_aid);

	$last_aid = $pkg_delta_aid;
      }
    }

    # 5.  get the config_channels recorded from the snapshot
    my $config_channels = RHN::SystemSnapshot->snapshot_config_channel_list(server_id => $sid, snapshot_id => $snapshot_id);
    my @config_channels = @{$config_channels};  # this might get changed depending if we need a local_override one...


    # 6.  tie config_channel list to server
    $transaction = RHN::Server->set_normal_config_channels(-server_ids => [$sid],
							   -config_channel_ids => [map {$_->{ID}} @config_channels],
							   -transaction => $transaction);

    # 7.  deploy the particular config files

    my $files = RHN::SystemSnapshot->snapshot_configfiles_list(server_id => $sid, snapshot_id => $snapshot_id);

    if (@{$files}) {
      my $deploy_aid;
      my $now = RHN::Date->now->long_date;

      ($deploy_aid, $transaction) = RHN::Scheduler->schedule_config_action(-org_id => $org_id,
									   -user_id => $user_id,
									   -earliest => $now,
									   -server_id => $sid,
									   -action_type => 'configfiles.deploy',
									   -action_name => 'Rollback config file deployment',
									   -revision_ids => [map {$_->{REVISION_ID} } @{$files}],
									   -transaction => $transaction,
									  );

      $deployed_config_files = 1;
      $last_aid = $deploy_aid;
    }

    # don't leave temp set lying around...
    if ($files_set) {
      $files_set->empty;
      $transaction = $files_set->commit($transaction);
    }
  };

  if ($@) {
    my $E = $@;
    $transaction->rollback();
    die $E;
  }

  my %ret = (is_some_pkg_delta => $is_some_pkg_delta,
	     deployed_config_files => $deployed_config_files);

  $ret{transaction} = $transaction if $params{transaction};

  return %ret;
}

1;
