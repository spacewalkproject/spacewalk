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

package Sniglets::ListView::SystemList;

use Sniglets::ListView::List;
use Sniglets::Search;
use Sniglets::Servers;
use RHN::Entitlements;
use RHN::DataSource::System;
use RHN::DataSource::Simple;
use RHN::Scheduler;
use RHN::Set;
use RHN::Exception qw/throw catchable/;

use RHN::Action;
use RHN::Server;
use RHN::Errata;
use RHN::Channel;
use RHN::Package;
use RHN::Date;
use RHN::SatCluster;
use RHN::Kickstart::Session;

use PXT::HTML;

use Data::Dumper;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:system_list_cb";
}

sub list_of { return "systems" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "taggable_systems_in_set",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "ssm_remote_commandable",
			   -datasource => RHN::DataSource::System->new,
                           -action_callback => \&ssm_remote_command_action_cb);

  Sniglets::ListView::List->add_mode(-mode => "provisioning_systems_in_set_with_tag",
			   -datasource => RHN::DataSource::System->new,
			   -action_callback => \&ssm_rollback_by_tag_action_cb);

  Sniglets::ListView::List->add_mode(-mode => "provisioning_systems_in_set",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&provisioning_systems_in_set_cb);

  Sniglets::ListView::List->add_mode(-mode => "provisioning_systems_in_ks_set",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&provisioning_systems_in_set_cb);

  Sniglets::ListView::List->add_mode(-mode => "users_systems_with_value_for_key",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&custominfo_values_provider);

  Sniglets::ListView::List->add_mode(-mode => "visible_to_user",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "visible_to_uid",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&visible_to_uid_provider);

  Sniglets::ListView::List->add_mode(-mode => "systems_with_package_nvre_in_set",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "selected_systems_installed_package",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&selected_systems_installed_package_provider);

  #Sniglets::ListView::List->add_mode(-mode => "ssm_package_upgrades_conf",
#			   -datasource => RHN::DataSource::System->new);
  Sniglets::ListView::List->add_mode(-mode => "ssm_package_upgrades_conf",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&system_set_upgrade_packages_conf_provider);

  Sniglets::ListView::List->add_mode(-mode => "system_entitlement_list",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&user_system_list_provider,
			   -action_callback => \&system_entitlement_list_cb);

  Sniglets::ListView::List->add_mode(-mode => "systems_with_package",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "potential_systems_for_package",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "in_set",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&in_set_provider,
			   -action_callback => \&in_set_cb);

  Sniglets::ListView::List->add_mode(-mode => "systems_subscribed_to_channel",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "systems_subscribed_to_channel_in_set",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "target_systems_for_channel",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "target_systems_for_channel_in_set",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "affected_by_errata",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&affected_by_errata_provider);

  Sniglets::ListView::List->add_mode(-mode => "in_group_and_affected_by_errata",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "in_set_and_affected_by_errata",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "system_set_supports_reboot_expanded",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "system_set_remove_packages_versions",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "system_set_remove_packages_conf",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&system_set_remove_packages_conf_provider);

  Sniglets::ListView::List->add_mode(-mode => "system_set_remove_patches_conf",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&system_set_remove_patches_conf_provider);

  Sniglets::ListView::List->add_mode(-mode => "system_set_verify_packages_conf",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&system_set_verify_packages_conf_provider);

  Sniglets::ListView::List->add_mode(-mode => "system_search_results",
			   -datasource => new RHN::DataSource::Simple(-querybase => "system_search_elaborators"),
			   -provider => \&system_search_results_provider);

  Sniglets::ListView::List->add_mode(-mode => "systems_registered_with_key",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "out_of_date",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "unentitled",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "ungrouped",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "inactive",
			   -datasource => RHN::DataSource::System->new,
  		           -provider => sub {
			     Sniglets::ListView::List::default_provider(@_, -checkin_threshold => PXT::Config->get('system_checkin_threshold'))
			     });

  Sniglets::ListView::List->add_mode(-mode => "proxy_servers",
			   -datasource => RHN::DataSource::System->new);
  Sniglets::ListView::List->add_mode(-mode => "clients_through_proxy",
			   -datasource => RHN::DataSource::System->new);
  Sniglets::ListView::List->add_mode(-mode => "proxy_path_for_server",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "systems_in_channel_family",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "systems_potentially_in_channel_family",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "systems_completed_action",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "systems_failed_action",
			   -datasource => RHN::DataSource::System->new,
			   -action_callback => \&reschedule_action_cb);

  Sniglets::ListView::List->add_mode(-mode => "systems_in_progress_action",
			   -datasource => RHN::DataSource::System->new,
			   -action_callback => \&remove_systems_from_action_cb);

  Sniglets::ListView::List->add_mode(-mode => "org_systems",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&org_systems_provider);

  Sniglets::ListView::List->add_mode(-mode => "support_find_system",
			   -datasource => RHN::DataSource::System->new,
			   -provider => \&support_find_system_provider);

  Sniglets::ListView::List->add_mode(-mode => "systems_with_namespace",
			   -datasource => RHN::DataSource::System->new);

  Sniglets::ListView::List->add_mode(-mode => "target_systems_for_namespace",
			   -datasource => RHN::DataSource::System->new,
                           -action_callback => \&add_systems_to_namespace_cb);

  Sniglets::ListView::List->add_mode(-mode => "config_managed_systems",
				     -datasource => RHN::DataSource::System->new,
				     -action_callback => \&Sniglets::ConfigManagement::config_managed_systems_cb);

  Sniglets::ListView::List->add_mode(-mode => "config_systems_list",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&config_systems_list);

  Sniglets::ListView::List->add_mode(-mode => "systems_with_patch",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&systems_with_patch_provider);

  Sniglets::ListView::List->add_mode(-mode => "potential_systems_for_patch",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&potential_systems_for_patch_provider);

  Sniglets::ListView::List->add_mode(-mode => "systems_with_patchset",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&systems_with_patchset_provider,
				    );

  Sniglets::ListView::List->add_mode(-mode => "potential_systems_for_patchset",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&potential_systems_for_patchset_provider,
				    );

  Sniglets::ListView::List->add_mode(-mode => "entitlement_changes_in_set",
				     -datasource => RHN::DataSource::System->new,
				     -provider => \&entitlement_changes_in_set_provider,
				     -action_callback => \&entitlement_changes_in_set_cb);
}


sub config_systems_list {
  my $self = shift;
  my $pxt = shift;

  my @data;
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    if ($row->{CHANNELS}) {
      $row->{CHANNELS} = join("<br />\n", @{$row->{CHANNELS}});
      push @data, $row;
    }
  }

  $ret{data} = \@data;
  return (%ret);
}

sub add_systems_to_namespace_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'lo_rank' or $label eq 'hi_rank') {

    my $ccid = $pxt->param('ccid');
    throw "No config channel."
      unless $ccid;
   
    my $cc = RHN::ConfigChannel->lookup(-id => $ccid);
   
    my $set_label = $pxt->dirty_param('set_label') || 'target_systems';
   
    my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
   
    my @systems = $set->contents;

    throw sprintf('user (%d) does not have access to one or more systems: (%s)', $pxt->user->id, join(', ', @systems))
      unless $pxt->user->verify_system_access(@systems);
   
    foreach my $sid ( @systems ) {
      my @local_channel_ids = ();
      my @global_channel_ids = ();
   
      my $server = RHN::Server->lookup(-id => $sid);
   
      my @existing_config_channels = $server->config_channels;
   
      # while gathering channel ids, separate local config channel;s
      # from global config channels
      foreach my $chan (@existing_config_channels) {
        # assume local config channels don't have POSITION defined
        if ( not $chan->{POSITION} ) {
          push @local_channel_ids, $chan->{ID};
        }
        else {
          push @global_channel_ids, $chan->{ID};
        }
      }
   
      # highest rank (this config channel overrides all others)
      if ($label eq 'hi_rank') {
        unshift @global_channel_ids, $ccid
      }
      # lowest rank (all other config channels override this one)
      elsif ($label eq 'lo_rank') {
        push @global_channel_ids, $ccid
      }
   
      # assemble config channels to finall array 
      my @new_channel_ids = @local_channel_ids;
      push @new_channel_ids, @global_channel_ids;
   
      unless ($pxt->user->verify_config_channel_access(@new_channel_ids)) {
        $pxt->redirect("/errors/permission.pxt");
      }
   
   
      # do the deed
      RHN::Server->set_normal_config_channels(-server_ids => [$sid],
                                              -config_channel_ids => [@new_channel_ids],
                                             );
   
       
    }
   
    RHN::Server->snapshot_set(-reason => "Config channel alteration",
                              -set_label => $set_label,
                              -user_id => $pxt->user->id,
                             );
   
    $pxt->push_message(site_info => sprintf("<strong>%d</strong> system%s added to <strong>%s</strong> config channel with %s rank.", scalar(@systems), (scalar(@systems) == 1 ? '' : 's'), PXT::Utils->escapeHTML($cc->name), ($label eq 'hi_rank' ? 'highest' : 'lowest')));
   
    $set->empty;
    $set->commit;
   
  }


  return 1;
}

sub ssm_remote_command_action_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label} and $action{label} eq 'schedule_command') {
    my $ds = new RHN::DataSource::System (-mode => 'ssm_remote_commandable');
    my $data = $ds->execute_query(-user_id => $pxt->user->id);

    my $transaction = RHN::DB->connect();
    $transaction->nest_transactions();

    eval {
      my $username = $pxt->dirty_param('username');
      my $group = $pxt->dirty_param('group');
      my $script = $pxt->dirty_param('script');
      my $timeout = $pxt->dirty_param('timeout');

      my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

      my $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);

      my $action_id = RHN::Scheduler->schedule_remote_command(-org_id => $pxt->user->org_id,
							      -user_id => $pxt->user->id,
							      -earliest => $earliest_date,
							      -server_set => $system_set,
							      -action_name => undef,
							      -script => $script,
							      -username => $username,
							      -group => $group,
							      -timeout => $timeout,
							     );
    };

    if ($@) {
      my $E = $@;
      $transaction->nested_rollback();
      die $E;
    }
    else {
      $transaction->nested_commit();
      $pxt->push_message(site_info => "Remote commands scheduled.");
      $pxt->redirect("/network/systems/ssm/provisioning/remote_command.pxt");
    }
  }

  return 1;
}

sub ssm_rollback_by_tag_action_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label} and $action{label} eq 'rollback_systems') {

    my $tag_id = $pxt->param('tag_id');
    my $ds = new RHN::DataSource::System (-mode => 'provisioning_systems_in_set_with_tag');
    my $data = $ds->execute_query(-user_id => $pxt->user->id, -tag_id => $tag_id);

    my $transaction = RHN::DB->connect();

    eval {
      foreach my $server_data (@{$data}) {

	my $sid = $server_data->{ID};
	my $snapshot_id = $server_data->{SNAPSHOT_ID};

	my %results = RHN::SystemSnapshot->rollback_to_snapshot(user_id => $pxt->user->id,
								org_id => $pxt->user->org_id,
								server_id => $sid,
								snapshot_id => $snapshot_id,
								transaction => $transaction,
							       );
	$transaction = $results{transaction};
      }
    };

    if ($@) {
      my $E = $@;
      $transaction->rollback();
      die $E;
    }
    else {
      $pxt->push_message(site_info => "Rollbacks scheduled.");
      $pxt->redirect("/network/systems/ssm/provisioning/rollback.pxt");
    }
  }

  return 1;
}

sub provisioning_systems_in_set_cb {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);
  my $prov_sets = scalar @{$ret{data}}; #num provisioning systems
  my $systems = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);
  my $total_sets = scalar $systems->contents; #num systems in ssm
  my $non_prov = $total_sets - $prov_sets; #num non provisioning systems
  if ($total_sets > $prov_sets) {
  my $msg = <<EOM; 
This operation could not be performed on some of the selected systems because they have insufficient entitlements or incompatible architectures. You may continue this operation with the listed compatible systems.
EOM
  $pxt->push_message(local_alert => $msg); #warn user 
  }
  return (%ret);
}

sub custominfo_values_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $key (@{$ret{data}}) {

    if (defined $key->{VALUE}) {
      $key->{VALUE} = '<pre>' . $key->{VALUE} . '</pre>';
    }
  }

  return (%ret);
}


sub selected_systems_installed_package_provider {
  my $self = shift;
  my $pxt = shift;

  my ($name_id, $evr_id) = split /[|]/, $pxt->dirty_param('id_combo');
  die "missing name_id or evr_id" unless ($name_id and $evr_id);

  PXT::Debug->log(7, "name_id == $name_id, evr_id = $evr_id");

  my %ret = $self->default_provider($pxt, 
	      -name_id => $name_id, -evr_id => $evr_id);

  return (%ret);
}

sub remove_systems_from_action_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label} and $action{label} eq 'unschedule_action') {
    my $action_id = $pxt->param('aid');
    my $set_name = 'unschedule_action';
    my $user_id = $pxt->user->id;
    my $set = new RHN::DB::Set $set_name, $user_id;

    my $action = RHN::Action->lookup(-id => $action_id);
    my $name = $action->name;
    $name = $action->action_type_name unless $name;
    my $num_systems = scalar $set->contents;

    RHN::Action->delete_set_from_action($action_id, $user_id, $set_name);

    $set->empty;
    $set->commit;

    $pxt->push_message(site_info => sprintf("<strong>%s</strong> unscheduled for <strong>%d</strong> system%s.",
					    PXT::Utils->escapeHTML($name), $num_systems, ($num_systems == 1 ? '' : 's')));

    if ($pxt->user->verify_action_access($action_id)) { # the user can still access the action
      $pxt->redirect($pxt->uri . "?aid=$action_id");
    }
    else { # all of the user's systems have been removed from the action
      $pxt->redirect('/rhn/schedule/PendingActions.do');
    }
  }

  return 1;
}

sub visible_to_uid_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt, -some_user_id => $pxt->param('uid'));

  return (%ret);
}

sub system_set_remove_packages_conf_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt, 
	      -package_set_label => 'sscd_removable_package_list');

  my $server_id = $pxt->param('sid') || '';
  foreach my $row (@{$ret{data}}) {
    my $num_packages = scalar @{$row->{NVRE}}; #list at most 6 packages
    if ( $num_packages > 6 && ( $server_id ne $row->{ID} ) ) { #give user option to expand
      $row->{NVRES_TO_REMOVE} =
            join("<br />\n", @{$row->{NVRE}}[0..5],
            "<a href=\"remove_conf.pxt?sid=$row->{ID}\">[expand package list]</a>
             <b>($num_packages total packages)</b>");
    }
    else {
      $row->{NVRES_TO_REMOVE} = "<a href=\"remove_conf.pxt\">[collapse package list]</a><br/>\n"
        if $server_id eq $row->{ID}; #give user option to collapse list
      $row->{NVRES_TO_REMOVE} .= join("<br />\n", @{$row->{NVRE}});
    }
  }

  return (%ret);
}

sub system_set_upgrade_packages_conf_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);
  my $server_id = $pxt->param('sid') || '';
  foreach my $row (@{$ret{data}}) {
    my $num_packages = scalar  @{$row->{__data__}}; #list at most 6 packages
    if ( $num_packages > 6 && ( $server_id ne $row->{ID} ) ) { #give user option to expand
      $row->{NVRES_TO_UPGRADE} =
            join("<br />\n", (map { $_->{NVRE} } @{$row->{__data__}}[0..5]),
            "<a href=\"upgrade_conf.pxt?sid=$row->{ID}\">[expand package list]</a>
             <b>($num_packages total packages)</b>");
    }
    else {
      $row->{NVRES_TO_UPGRADE} = "<a href=\"upgrade_conf.pxt\">[collapse package list]</a><br/>\n"
        if $server_id eq $row->{ID}; #give user option to collapse list
      $row->{NVRES_TO_UPGRADE} .= join("<br />\n", map { $_->{NVRE} } @{$row->{__data__}});
    }
  }

  return (%ret);
}

sub system_set_remove_patches_conf_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt, 
	      -package_set_label => 'sscd_removable_patch_list');

  foreach my $row (@{$ret{data}}) {
    $row->{NVRES_TO_REMOVE} = join("<br />\n", @{$row->{NVRE}});
  }

  return (%ret);
}

sub system_set_verify_packages_conf_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt, 
	      -package_set_label => 'sscd_verify_package_list');
  my $server_id = $pxt->param('sid') || '';
  foreach my $row (@{$ret{data}}) {
    my $num_packages = scalar @{$row->{NVRE}}; #list at most 6 packages
    if ( $num_packages > 6 && ( $server_id ne $row->{ID} ) ) { #give user option to expand 
      $row->{NVRES_TO_VERIFY} = 
            join("<br />\n", @{$row->{NVRE}}[0..5], 
            "<a href=\"verify_conf.pxt?sid=$row->{ID}\">[expand package list]</a>
             <b>($num_packages total packages)</b>");
    }
    else {
      $row->{NVRES_TO_VERIFY} = "<a href=\"verify_conf.pxt\">[collapse package list]</a><br/>\n"
        if $server_id eq $row->{ID}; #give user option to collapse list 
      $row->{NVRES_TO_VERIFY} .= join("<br />\n", @{$row->{NVRE}});
    }
  }

  return (%ret);
}

sub ssm_channel_change_conf_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  my $data = $ret{data};

  foreach my $row (@{$data}) {
    $row->{SERVER_NAME} = $row->{__data__}->[0]->{SERVER_NAME};
    $row->{CHANNELS_TO_UNSUBSCRIBE} = join("<br />\n", map {$_->{CHANNEL_NAME}} grep { $_->{ACTION} eq 'unsubscribe' } @{$row->{__data__}});
    $row->{CHANNELS_TO_SUBSCRIBE} = join("<br />\n", map {$_->{CHANNEL_NAME}} grep { $_->{ACTION} eq 'subscribe' } @{$row->{__data__}});
  }

  return %ret;
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  my $org = $pxt->user->org;
  if (exists $row->{__data__} and exists $row->{__data__}->[0]->{ENTITLEMENT}) {
    my @ent_level;
    foreach my $ent (map { $_->{ENTITLEMENT} } @{$row->{__data__}}) {
      push @ent_level, $org->slot_name($ent);
    }
    $row->{ENTITLEMENT_LEVEL} = join(', ', @ent_level);
  }
  else {
    $row->{ENTITLEMENT_LEVEL} = 'Unentitled';
  }

  if (exists $row->{LAST_CHECKIN_DAYS_AGO} and exists $row->{ENTITLEMENT_LEVEL}) {
    $row->{IS_ENTITLED} = 0;
    if ($row->{ENTITLEMENT_LEVEL} ne 'Unentitled') {
      $row->{IS_ENTITLED} = 1;
    }

    if ($pxt->user->org->has_entitlement('rhn_provisioning')) {
      my $session = RHN::Kickstart::Session->lookup(-sid => $row->{ID}, -org_id => $pxt->user->org_id, -soft => 1);
      my $state = $session ? $session->session_state_label : '';
      $row->{KICKSTART_SESSION_ID} = ($session and $state ne 'complete' and $state ne 'failed') ? $session->id : undef;
    }

    my $icon_data = Sniglets::Servers::system_status_info($pxt->user, $row);

    my $image = PXT::HTML->img(-src => $icon_data->{image},
			       -alt => $icon_data->{status_str},
			       -title => $icon_data->{status_str},
 			       -border => 0);

    $row->{ADVISORY_ICON} = PXT::HTML->link($icon_data->{link}, $image);
  }

  $row->{MONITORING_ICON} = '';
  if (RHN::Server->system_has_feature($row->{ID}, 'ftr_probes')) {
    if (defined $row->{MONITORING_STATUS}) {
      my $icon_data = Sniglets::Servers::system_monitoring_info($pxt->user, $row);

      my $image = PXT::HTML->img(-src => $icon_data->{image},
                                 -alt => $icon_data->{status_str},
                                 -title => $icon_data->{status_str},
                                 -border => 0);

      $row->{MONITORING_ICON} = PXT::HTML->link($icon_data->{system_link}, $image);
    }
  }

  if (not RHN::Server->system_has_feature($row->{ID}, 'ftr_errata_updates')) {
    $row->{TOTAL_ERRATA} = '';
  }
  elsif (exists $row->{SECURITY_ERRATA}) {
    $row->{TOTAL_ERRATA} = $row->{SECURITY_ERRATA} + $row->{BUG_ERRATA} + $row->{ENHANCEMENT_ERRATA};
  }

  if (exists $row->{LAST_CHECKIN}) {
    my $date = new RHN::Date(string => $row->{LAST_CHECKIN},
			     user => $pxt->user);
    $row->{LAST_CHECKIN} = $date->short_date;
  }

  foreach my $time_column (qw/COMPLETION_TIME EARLIEST_EXECUTION_TIME FAILED_TIME/) {
    if (exists $row->{$time_column} and $row->{$time_column}) {
      $row->{$time_column} = $pxt->user->convert_time($row->{$time_column});
    }
  }

  if (exists $row->{CHANNEL_LABELS}) {
    $row->{CHANNEL_LABELS} =~ s/\s(for\s)?i386//;
  }

  return $row;
}

sub system_search_results_provider {
  my $self = shift;
  my $pxt = shift;

  my $search = RHN::SearchTypes->find_type('system');
  my $mode = $pxt->dirty_param('view_mode') || '';

  throw "No mode specified for system_search_results"
    unless $mode;

  $self->datasource->mode($mode);

  # We need to go ahead an strip out invalid characters, so that the
  # matching field will be populated properly.  For instance, package
  # searches for 'foo.rpm' - we strip of '.rpm', and find all packages
  # that match 'foo'.
  my $string = $pxt->dirty_param('search_string') || '';
  $string = Sniglets::Search->strip_invalid_chars($string, $mode);
  $pxt->dirty_param(search_string => $string);

  my %ret = $self->default_provider($pxt);

  my $quicksearch = $pxt->dirty_param('quicksearch') || 0;
  if (scalar @{$ret{all_ids}} == 1 and $quicksearch) {
    my $sid = $ret{all_ids}->[0];
    $pxt->push_message(site_info => "Your search returned one result, displayed below.");
    $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
  }

  if (defined $self->listview()) { # don't run this in callback - no listview
    foreach my $col (@{$self->listview->columns}) {
      if ($col->label eq 'matching_field') {
	$col->name($search->label_to_column_name($mode));
      }
    }
  }

  $string = quotemeta($string); #escape regexpy characters

  foreach my $row (@{$ret{data}}) {
    my $field = defined $row->{MATCHING_FIELD} ? $row->{MATCHING_FIELD} : '';

    if (ref $field eq 'ARRAY') {
      $field = join "<br />\n", @{$field};
    }

    if ($mode eq 'search_simple') { #special case b/c we're searching 2 fields
      $field = $row->{SERVER_NAME};

      unless ($field =~ /$string/i) {
	$field = $row->{MATCHING_FIELD};
      }
    }

    $field =~ s/($string)/<strong>$1<\/strong>/gi;
    $row->{MATCHING_FIELD} = defined $field ? $field : '&nbsp;';
  }

  return (%ret);
}

sub is_row_selectable {
  my $self = shift;
  my $pxt = shift;
  my $row = shift;

  # this sucks.  mode should return the mode, not some super complicated struct.
  # mode_data or something should return all the various data.  argh.
  my $mode = $self->datasource->mode();

  # For the system entitlement list, all rows are selectable
  if ($mode eq 'system_entitlement_list') {
    return 1;
  }

  unless ($row->{SELECTABLE}) {
    return;
  }

  if ($mode eq 'systems_in_progress_action') {
    unless ($row->{ACTION_STATUS} eq 'Queued') {
      return;
    }

    if (defined $row->{PREREQUISITE}) {
      # actions w/ a prerequisite cannot be selected by themselves for cancelation...
      # gotta kill off the entire chain to avoid unexpected states
      return;
    }
  }

  return 1;
}

sub allow_selections {
  my $self = shift;
  my $pxt = shift;

  return $pxt->user->org->has_entitlement('sw_mgr_enterprise');
}


sub user_system_list_provider {
  my $self = shift;
  my $pxt = shift;

  my $org = $pxt->user->org;
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $ent_data = $row->{__data__} || [];
    my @ents = @{$ent_data};

    my ($base) = grep { $_->{IS_BASE} eq 'Y' } @ents;
    my @addons = grep { $_->{IS_BASE} eq 'N' } @ents;
    $row->{BASE_ENTITLEMENT} = $base ? $org->slot_name($base->{ENTITLEMENT}) : '(none)';

    $row->{ADDON_ENTITLEMENTS} = join("<br/>\n",
				      map { $org->slot_name($_->{ENTITLEMENT}) } @addons);

    $row->{ADDON_ENTITLEMENTS} ||= '(none)';
  }

  return (%ret);
}

sub org_systems_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    $row->{HISTORY_LINK} = 'System History';
  }

  return (%ret);
}

sub support_find_system_provider {
  my $self = shift;
  my $pxt = shift;

  my $search_str = $pxt->dirty_param('search_str') || '';

  return unless $search_str;

  $search_str = '%' . $search_str . '%';

  my %ret = $self->default_provider($pxt, -search_str => $search_str);

  return %ret;
}

# Allow override of 'set_label' param with 'target_set_label' - useful in the ssm
sub in_set_provider {
  my $self = shift;
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('target_set_label') || $pxt->dirty_param('set_label') || 'system_list';

  my %ret = $self->default_provider($pxt, -set_label => $set_label);

  return (%ret);
}

sub in_set_cb {
  my $self = shift;
  my $pxt = shift;

  # think big red button
  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'remove') {
    my $to_remove_set = new RHN::DB::Set 'removable_system_list', $pxt->user->id;
    my $system_set = new RHN::DB::Set 'system_list', $pxt->user->id;

    my $num_to_remove = $to_remove_set->contents;

    PXT::Debug->log(7, "removing:  " . Data::Dumper->Dump([($to_remove_set->contents)]) . " from system_list...");

    $system_set->remove($to_remove_set->contents);
    $system_set->commit;
    $to_remove_set->empty;
    $to_remove_set->commit;

    PXT::Debug->log(7, "adding in feedback...");
    $pxt->push_message(site_info => "$num_to_remove system(s) removed from set.");
  }
  elsif ($label eq 'confirm_errata_application') {
    return apply_errata_cb($pxt);
  }
  elsif ($label eq 'confirm_channel_unsubscribe') {
    my $set_label = $pxt->dirty_param('set_label');
    my $set = new RHN::DB::Set $set_label, $pxt->user->id;

    $self->clean_set($set, $pxt->user);

    my $channel_id = $pxt->param('cid');
    throw "No channel id!" unless $channel_id;

    foreach my $sid ($set->contents) {
      my $system = RHN::Server->lookup(-id => $sid);
      $system->unsubscribe_from_channel($channel_id);
    }

    RHN::Server->snapshot_set(-reason => 'Channel subscriptions alteration',
			      -set_label => $set_label,
			      -user_id => $pxt->user->id);

    my $channel = RHN::Channel->lookup(-id => $channel_id);
    my $count = scalar($set->contents);
    $pxt->push_message(site_info => sprintf('<strong>%d</strong> system%s unsubscribed from <strong>%s</strong>.',
					      $count, ($count == 1 ? '' : 's'), PXT::Utils->escapeHTML($channel->name)));
    $set->empty;
    $set->commit;
  }
  elsif ($label eq 'confirm_channel_subscribe') {
    my $set_label = $pxt->dirty_param('set_label');
    my $set = new RHN::DB::Set $set_label, $pxt->user->id;
    $self->clean_set($set, $pxt->user);

    my $channel_id = $pxt->param('cid');
    throw "No channel id!" unless $channel_id;
    my $channel = RHN::Channel->lookup(-id => $channel_id);

    my $transaction = RHN::DB->connect;

    PXT::Debug->log(7, "starting transaction");

    eval {
      foreach my $sid ($set->contents) {

	my $system = RHN::Server->lookup(-id => $sid);
	$transaction = $system->subscribe_to_channel($channel_id, $transaction);
      }

      $transaction = RHN::Server->snapshot_set(-reason => "Channel subscription alteration",
					       -set_label => $set_label,
					       -user_id => $pxt->user->id,
					       -transaction => $transaction);

      PXT::Debug->log(7, "finished subscribing all systems...");
    };

    if ($@ and catchable($@)) {
      my $E = $@;

      PXT::Debug->log(7, "caught an exception");
      #  What could go here?  What exceptions might we run into?  Not enough entitlements?
      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
	PXT::Debug->log(7, "caught an exception, ran out of slots");
        $pxt->push_message(local_alert => "Channel subscriptions would be exceeded, no systems subscribed.  Please contact Red Hat for more channel entitlements (1-866-2-REDHAT).");
	$transaction->rollback;
	return;
      }
      else {
      PXT::Debug->log(7, "unknown exception");
        throw $E;
      }
    }
    else {
      PXT::Debug->log(7, "committing transaction...");
      $transaction->commit;
      my $count = scalar($set->contents);
      $pxt->push_message(site_info => sprintf('<strong>%d</strong> system%s subscribed to <strong>%s</strong>.',
					      $count, ($count == 1 ? '' : 's'), PXT::Utils->escapeHTML($channel->name)));
      $set->empty;
      $set->commit;
    }
  }
  elsif ($label eq 'confirm_package_install') {
    install_package($pxt);
  }

  return 1;
}

sub system_entitlement_list_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  return 1 unless $label;

  my $check_monitoring = 0;
  my %sat_clusters;

  my ($set_entitlement, $add_entitlement, $remove_entitlement, $unentitle);
  if ($label eq 'set_to_updates') {
    $set_entitlement = 'sw_mgr_entitled';
  }
  elsif ($label eq 'set_to_management') {
    $set_entitlement = 'enterprise_entitled';
  }
  elsif ($label eq 'add_monitoring') {
    $add_entitlement = 'monitoring_entitled';
  }
  elsif ($label eq 'add_provisioning') {
    $add_entitlement = 'provisioning_entitled';
  }
  elsif ($label eq 'remove_monitoring') {
    $remove_entitlement = 'monitoring_entitled';
    $check_monitoring = 1;
  }
  elsif ($label eq 'remove_provisioning') {
    $remove_entitlement = 'provisioning_entitled';
  }
  elsif ($label eq 'unentitle') {
    $unentitle = 1;
    $check_monitoring = 1;
  }

  my $set_label = $pxt->dirty_param('set_label');
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  my @system_ids = $set->contents;

  unless (@system_ids) {
    $pxt->push_message(site_info => 'No systems selected.');
  }

  # Loop through the selected systems, and perform the specified
  # action on each.
  #
  # We are handling two different types of exceptions.  The first
  # exception is servergroup_max_members, and simply means that the
  # user does not have enough entitlements to entitle all of the
  # selected systems.  If this exception is thrown, then it just means
  # we rollback the inner transaction, and display a message to the
  # user.  However, if some unexpected exception is thrown, the user
  # will see a 500 error, so we want to roll back everything.

  my $full_transaction = RHN::DB->connect();
  $full_transaction->nest_transactions();

  my @successful;
  my @failed;

  foreach my $sid (@system_ids) {

    my $system_transaction = RHN::DB->connect;
    $system_transaction->nest_transactions();

    my $has_monitoring = 0;

    eval {

      my @sat_clusters;

      if ($check_monitoring) {
	@sat_clusters = RHN::Server->sat_clusters_for_system($sid);
      }

      # Don't unentitle and re-entitle if the system already has the entitlement in question.
      if ($set_entitlement and not RHN::Server->server_has_entitlement($set_entitlement, $sid)) {
	RHN::Server->unentitle_server($sid);
      }

      if ($unentitle) {
	my @ents = RHN::Server->entitlements($sid);

	if ($check_monitoring) {
	  $has_monitoring = ( grep { $_->{LABEL} eq 'monitoring_entitled' } @ents ) ? 1 : 0;
	}

	RHN::Server->unentitle_server($sid);
	push @successful, $sid if (@ents);
      }

      if ($set_entitlement) {
	if (RHN::Server->can_entitle_server($set_entitlement, $sid)) {
	  RHN::Server->entitle_server($set_entitlement, $sid);
	  push @successful, $sid;
	}
      }

      if ($add_entitlement) {
	if (RHN::Server->can_entitle_server($add_entitlement, $sid)) {
	  RHN::Server->entitle_server($add_entitlement, $sid);
	  push @successful, $sid;
	}
      }

      if ($remove_entitlement) {
	if (RHN::Server->server_has_entitlement($remove_entitlement, $sid)) {

	  if ($check_monitoring) {
	    $has_monitoring = 1;
	  }

	  RHN::Server->remove_entitlement($remove_entitlement, $sid);
	  push @successful, $sid;
	}
      }

      if ($check_monitoring and $has_monitoring) {
	foreach my $row (@sat_clusters) {
	  $sat_clusters{$row->{SAT_CLUSTER_ID}} = 1;
	}
      }

    };

    if ($@) {
      my $E = $@;
      $system_transaction->nested_rollback();

      if (ref $E and catchable($E)) {
	if ($E->is_rhn_exception('servergroup_max_members')) {
	  push @failed, $sid;
	}
	else {
	  $full_transaction->nested_rollback();
	  throw $E;
	}
      }
      else {
	$full_transaction->nested_rollback();
	die $E;
      }
    }
    else {
      $system_transaction->nested_commit();
    }
  }

  foreach my $sat_cluster_id (keys %sat_clusters) {
    RHN::SatCluster->push_config($pxt->user->org_id, $sat_cluster_id, $pxt->user->id);
  }

  $full_transaction->nested_commit();

  if (($set_entitlement or $add_entitlement) and @failed) {
    $pxt->push_message(site_info => sprintf("You did not have enough <strong>%s</strong> "
					    . "entitlements to entitle all the selected systems, "
					    . "so <strong>%d</strong> system%s not entitled.",
					    $pxt->user->org->slot_name($set_entitlement or $add_entitlement),
					    scalar(@failed),
					    scalar(@failed) == 1 ? ' was' : 's were'
					   )
		      );
  }

  if ($set_entitlement and @successful) {
    $pxt->push_message(site_info => sprintf("<strong>%d</strong> system%s set to <strong>%s</strong>.",
					    scalar(@successful),
					    scalar(@successful) == 1 ? '' : 's',
					    $pxt->user->org->slot_name($set_entitlement)
					   )
		      );
  }

  if ($add_entitlement and @successful) {
    $pxt->push_message(site_info => sprintf("Added <strong>%s</strong> to <strong>%d</strong> system%s.",
					    $pxt->user->org->slot_name($add_entitlement),
					    scalar(@successful),
					    scalar(@successful) == 1 ? '' : 's',
					   )
		      );
  }

  if ($unentitle and @successful) {
    $pxt->push_message(site_info => sprintf("<strong>%d</strong> system%s unentitled.",
					    scalar(@successful),
					    scalar(@successful) == 1 ? '' : 's',
					   )
		      );
  }

  if ($remove_entitlement and @successful) {
    $pxt->push_message(site_info => sprintf("Removed <strong>%s</strong> from <strong>%d</strong> system%s.",
					    $pxt->user->org->slot_name($remove_entitlement),
					    scalar(@successful),
					    scalar(@successful) == 1 ? '' : 's',
					   )
		      );
  }

  return 1;
}

sub apply_errata_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid');

  throw "No errata id" unless $eid;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No set label" unless $set_label;
  my $system_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  #do not commit this set
  my $errata_set = new RHN::DB::Set 'errata_list', $pxt->user->id;
  $errata_set->empty;
  $errata_set->add($eid);

  my $earliest_date = RHN::Date->now->long_date;
  my @action_ids = RHN::Scheduler->schedule_errata_updates_for_systems(-org_id => $pxt->user->org_id,
								       -user_id => $pxt->user->id,
								       -earliest => $earliest_date,
								       -errata_set => $errata_set,
								       -server_set => $system_set);

  my $errata = RHN::Errata->lookup(-id => $eid);

  my $sys_count = scalar $system_set->contents;
  $pxt->push_message(site_info => sprintf('Errata <a href="/rhn/errata/details/Details.do?eid=%d"><strong>%s</strong></a> has been scheduled for <strong>%d</strong> system%s.', $eid, $errata->advisory, $sys_count, $sys_count == 1 ? '' : 's'));

  $system_set->empty;
  $system_set->commit;

  return 1;
}

sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  my $mode = $self->datasource->mode();

  if ($mode eq 'system_entitlement_list') {
    $set->remove_unowned_servers($user);
  }
  else {
    $set->remove_illegal_servers($user);
  }

  if($mode eq 'systems_in_progress_action') {
    $set->remove_picked_up_for_action($formvars->{aid});

    my $action = RHN::Action->lookup(-id => $formvars->{aid});
    my $prereq = $action->prerequisite;
    if ($prereq) {
      my $prereq_action = RHN::Action->lookup(-id => $prereq);

      foreach my $sid ($set->contents) {
	$set->remove($sid) unless $prereq_action->get_server_status($sid) eq 'Completed';
      }
      $set->commit;
    }
  }

  return;
}

# override from List.pm
sub render_url {
  my $self = shift;

  my $rendered_url = $self->SUPER::render_url(@_);

  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  if ($url_column eq 'TOTAL_ERRATA' || $url_column eq 'OUTDATED_PACKAGES') {
    if (exists $row->{ENTITLEMENT_LEVEL}) {
      if (($row->{ENTITLEMENT_LEVEL} eq 'Unentitled') or
	  ($row->{ENTITLEMENT_LEVEL} eq 'None')) {
	return $row->{$url_column};
      }
    }
  }

  return $rendered_url;
}

sub reschedule_action_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  if (exists $action{label} and $action{label} eq 'reschedule_action') {

    my $action_id = $pxt->param('aid');

    throw "no action id!" unless $action_id;

    my $action = RHN::Action->lookup(-id => $action_id);

    RHN::Scheduler->reschedule_action(-action_id => $action_id, -org_id => $pxt->user->org_id,
				      -user_id => $pxt->user->id);

    $pxt->push_message(site_info => sprintf('<strong>%s</strong> rescheduled.', PXT::Utils->escapeHTML($action->name)));
  }

  return 1;
}

sub install_package {
  my $pxt = shift;

  my $pid = $pxt->param('pid');

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $system_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $earliest_date = RHN::Date->now->long_date;
  my $action_id = RHN::Scheduler->schedule_package_install(-org_id => $pxt->user->org_id,
							   -user_id => $pxt->user->id,
							   -earliest => $earliest_date,
							   -server_set => $system_set,
							   -package_id => $pid);

  my $package = RHN::Package->lookup(-id => $pid);

  my $system_count = scalar $system_set->contents;
  $pxt->push_message(site_info => sprintf('<strong>%s</strong> has been scheduled for install on <a href="/rhn/schedule/InProgressSystems.do?aid=%d"><strong>%d</strong> system%s</a>.', PXT::Utils->escapeHTML($package->nvre), $action_id, $system_count, $system_count == 1 ? '' : 's'));

  $system_set->empty;
  $system_set->commit;
}

sub affected_by_errata_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $stat = $row->{__data__}->[0];
    if ($stat->{STATUS}) {
      if ($stat->{STATUS} eq 'Queued') {
        $stat->{STATUS} = 'Pending';
      }
      $row->{STATUS} = PXT::HTML->link('/rhn/schedule/ActionDetails.do?aid=' . $stat->{ACTION_ID}, $stat->{STATUS});
    }
    else {
      $row->{STATUS} = 'None';
    }
  }

  return %ret;
}

sub systems_with_patch_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    if (exists $row->{__data__} && ref $row->{__data__} eq 'ARRAY') {
      $row->{PATCHED_PACKAGE_URLS} = join("<br />\n",
        map { PXT::HTML->link(sprintf("/rhn/software/packages/Details.do?id_combo=%s&amp;sid=%d",
				      $_->{PACKAGE_ID_COMBO},
				      $row->{ID}),
			      $_->{PACKAGE_NVRE})
  	    } @{$row->{__data__}}
				   );
    }
    else {
      $row->{PATCHED_PACKAGE_URLS} = '(none)';
    }
  }

  return (%ret);
}

sub potential_systems_for_patch_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    if (exists $row->{__data__} && ref $row->{__data__} eq 'ARRAY') {
      $row->{UNPATCHED_PACKAGE_URLS} = join("<br />\n",
        map { PXT::HTML->link(sprintf("/rhn/software/packages/Details.do?id_combo=%s&amp;sid=%d",
				      $_->{PACKAGE_ID_COMBO},
				      $row->{ID}),
			      $_->{PACKAGE_NVRE})
  	    } @{$row->{__data__}}
					   );
    }
    else {
      $row->{UNPATCHED_PACKAGE_URLS} = '(none)';
    }
  }

  return (%ret);
}

sub systems_with_patchset_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
      $row->{TIMESTAMP} ||= '(unknown)';
  }

  return (%ret);
}

sub potential_systems_for_patchset_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    $row->{TIMESTAMP} ||= '(none)';
    $row->{ACTION_STATUS} ||= '(none)';
  }

  return (%ret);
}

sub entitlement_changes_in_set_provider {
  my $self = shift;
  my $pxt = shift;
  my $in_cb = shift;

  my %ret = $self->get_entitlement_changes_in_set_data($pxt);

  my @all_entitlements = RHN::Entitlements->valid_system_entitlements_for_org($pxt->user->org_id);
  my @addon_entitlements = map { $_->{LABEL} }
    grep { $_->{IS_BASE} eq 'N' } @all_entitlements;

  my $avail_ents = $pxt->user->org->entitlement_data();

  my %add_ents;
  my %remove_ents;

  foreach my $ent (@addon_entitlements) {
    if ($pxt->dirty_param($ent) eq 'add') {
      $add_ents{$ent} = 1;
    }
    elsif ($pxt->dirty_param($ent) eq 'remove') {
      $remove_ents{$ent} = 1;
    }
  }

  my $something_to_do = 0;

  my %not_enough_entitlements;
  my %entitlement_counts;

  foreach my $row (@{$ret{data}}) {
    my @display_changes;
    my @add;
    my @remove;

    my %current_ents = map { $_->{ENTITLEMENT} => 1 } @{$row->{__data__}};
    foreach my $ent (@addon_entitlements) {
      if (exists $add_ents{$ent} and
	  not exists $current_ents{$ent} and
	  RHN::Server->can_entitle_server($ent, $row->{ID})) {

	if ($avail_ents->{$ent}->{available} > 0) {
	  push @add, $ent;
	  push @display_changes, 'add&#160;' . $pxt->user->org->slot_name($ent);
	  $something_to_do = 1;
	  $avail_ents->{$ent}->{available}--;
	  $entitlement_counts{$ent}++;
	}
	else {
	  $not_enough_entitlements{$ent}++;
	}
      }
      elsif (exists $remove_ents{$ent} and
	     exists $current_ents{$ent}) {
	push @remove, $ent;
	push @display_changes, 'remove&#160;' . $pxt->user->org->slot_name($ent);
	$something_to_do = 1;
      }
    }

    $row->{ENTITLEMENT_MODIFICATION} = join(', ', @display_changes) || '(do&#160;nothing)';
    $row->{ADD_ENTITLEMENTS} = \@add;
    $row->{REMOVE_ENTITLEMENTS} = \@remove;
  }

  if (%not_enough_entitlements and not $in_cb) {
    my $not_enough_msg = <<EOQ;
You need <strong>%d</strong> more <strong>%s</strong> entitlements to
entitle all of the selected systems.  If you click the
<strong>Confirm</strong> button, the <strong>%d</strong> systems
indicated below will be entitled for <strong>%s</strong>, and the rest
will not be.
EOQ
    foreach my $ent (keys %not_enough_entitlements) {
      $pxt->push_message(site_info => sprintf($not_enough_msg,
					      $not_enough_entitlements{$ent},
					      $pxt->user->org->slot_name($ent),
					      $entitlement_counts{$ent},
					      $pxt->user->org->slot_name($ent)
					     )
			);
    }
  }

  unless ($something_to_do) {
    $pxt->push_message(site_info => sprintf(<<EOQ));
Based upon the options you selected, your system's current
entitlements, and your available entitlements, there are no system
entitlements to add or remove.
EOQ
    $pxt->redirect('/network/systems/ssm/misc/index.pxt');
  }

  if (not $in_cb) {
    $ret{data} = $self->filter_data($ret{data});
    $ret{alphabar} = $self->init_alphabar($ret{data});

    $ret{data} = $ret{ds}->slice_data($ret{data}, $self->lower, $self->upper);
  }

  return (%ret);
}

sub get_entitlement_changes_in_set_data {
  my $self = shift;
  my $pxt = shift;
  my %extra_params = @_;

  my $ds = $self->datasource;

  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $data = $ds->execute_query(%params, %extra_params);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->elaborate($data, %params, %extra_params);

  foreach my $row (@$data) {
    Sniglets::ListView::List::escape_row($row);
  }

  return (data => $data,
	  all_ids => $all_ids,
	  ds => $ds);
}

sub entitlement_changes_in_set_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  if (exists $action{label} and
      $action{label} eq 'confirm') {
    my %ret = $self->entitlement_changes_in_set_provider($pxt, 'in_callback');

    my $transaction = RHN::DB->connect;
    $transaction->nest_transactions();

    my %adds;
    my %removes;

    my %sat_clusters;

    foreach my $row (@{$ret{data}}) {
      foreach my $ent (@{$row->{ADD_ENTITLEMENTS}}) {
	RHN::Server->entitle_server($ent, $row->{ID});
	$adds{$ent}++;
      }

      foreach my $ent (@{$row->{REMOVE_ENTITLEMENTS}}) {

	if ($ent eq 'monitoring_entitled') {
	  my @sat_clusters = RHN::Server->sat_clusters_for_system($row->{ID});
	  foreach my $cluster (@sat_clusters) {
	    $sat_clusters{$cluster->{SAT_CLUSTER_ID}} = 1;
	  }
	}

	RHN::Server->remove_entitlement($ent, $row->{ID});
	$removes{$ent}++;
      }
    }

    foreach my $sat_cluster_id (keys %sat_clusters) {
      RHN::SatCluster->push_config($pxt->user->org_id, $sat_cluster_id, $pxt->user->id);
    }

    $transaction->nested_commit();

    foreach my $ent (keys %adds) {
      $pxt->push_message(site_info => sprintf('Added <strong>%s</strong> to <strong>%d</strong> system%s.',
					      $pxt->user->org->slot_name($ent),
					      $adds{$ent},
					      ($adds{$ent} == 1 ? '' : 's')
					     )
			);
    }

    foreach my $ent (keys %removes) {
      $pxt->push_message(site_info => sprintf('Removed <strong>%s</strong> from <strong>%d</strong> system%s.',
					      $pxt->user->org->slot_name($ent),
					      $removes{$ent},
					      ($removes{$ent} == 1 ? '' : 's')
					     )
			);
    }
  }

  return 1;
}

1;
