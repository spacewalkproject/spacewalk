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

package Sniglets::ListView::PackageList;

use Sniglets::ListView::List;
use RHN::Package;
use RHN::Channel;
use RHN::DB;
use RHN::Action;
use RHN::Errata;
use RHN::ErrataTmp;
use RHN::DataSource::Package;
use RHN::DataSource;
use RHN::DataSource::Simple;
use RHN::Utils;
use PXT::Utils;
use RHN::Scheduler;
use RHN::Manifest;

use RHN::Exception qw/throw/;

use Time::HiRes;
use Data::Dumper;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:package_list_cb";
}

sub list_of { return "packages" }

sub _register_modes {


 Sniglets::ListView::List->add_mode(-mode => "snapshot_unservable_package_list",
				    -datasource => RHN::DataSource::Package->new,
				   );

  Sniglets::ListView::List->add_mode(-mode => "comparison_to_snapshot",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&snapshot_comparison_provider);

  Sniglets::ListView::List->add_mode(-mode => "package_search_results",
			   -datasource => new RHN::DataSource::Simple(-querybase => "package_search_elaborators"),
			   -provider => \&package_search_results_provider);

  Sniglets::ListView::List->add_mode(-mode => "package_removal_failures",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&package_removal_failures_provider);

  Sniglets::ListView::List->add_mode(-mode => "package_verification_results",
				     -datasource => RHN::DataSource::Package->new,
				     -provider => \&package_verification_results_provider);


  Sniglets::ListView::List->add_mode(-mode => "patches_from_server_set",
			   -datasource => RHN::DataSource::Package->new,
 			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_from_server_set",
			   -datasource => RHN::DataSource::Package->new,
 			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "verify_packages_from_server_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_in_channel",
                           -provider => \&packages_in_channel_provider, 
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "patches_in_channel",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "patchsets_in_channel",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_in_errata",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&packages_in_errata_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "latest_packages_in_channel",
                           -provider => \&latest_packages_in_channel_provider,
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "latest_patches_in_channel",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "latest_patchsets_in_channel",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "ssm_packages_for_upgrade",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&ssm_packages_for_upgrade_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_in_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "package_ids_in_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "patch_ids_in_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "patchset_ids_in_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

   Sniglets::ListView::List->add_mode(-mode => "packages_owned_by_org",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&packages_owned_by_org_provider);

   Sniglets::ListView::List->add_mode(-mode => "packages_available_to_channel",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&packages_available_to_channel_provider,
 			   -action_callback => \&default_callback);

   Sniglets::ListView::List->add_mode(-mode => "patches_available_to_channel",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&patches_available_to_channel_provider,
 			   -action_callback => \&default_callback);

   Sniglets::ListView::List->add_mode(-mode => "patchsets_available_to_channel",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&patchsets_available_to_channel_provider,
 			   -action_callback => \&default_callback);

   Sniglets::ListView::List->add_mode(-mode => "packages_available_to_errata",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&packages_available_to_errata_provider,
 			   -action_callback => \&default_callback);

   Sniglets::ListView::List->add_mode(-mode => "obsoleting_packages",
 			   -datasource => RHN::DataSource::Package->new,
 			   -provider => \&obsoleting_packages_provider,
 			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "system_package_list",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "system_upgradable_package_list",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&system_upgradable_package_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "in_set",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "system_available_packages",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "system_profile_comparison",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&profile_comparison_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_selected_for_sync",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&packages_for_sync_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "packages_associated_with_action",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "channel_errata_comparison",
			   -datasource => RHN::DataSource::Package->new,
			   -provider => \&channel_errata_comparison_provider,     
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "channel_errata_intersection",
			   -datasource => RHN::DataSource::Package->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "package_download_for_system_arch_select",
			   -datasource => RHN::DataSource::Package->new,
                           -provider => \&package_download_for_system_arch_select_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "compare_managed_channel_packages",
			   -datasource => RHN::DataSource::Package->new,
                           -provider => \&compare_managed_channel_packages_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "managed_channel_merge_preview",
			   -datasource => RHN::DataSource::Package->new,
                           -provider => \&managed_channel_merge_preview_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "sync_confirm_packages_in_set",
			   -datasource => RHN::DataSource::Package->new,
                           -provider => \&sync_confirm_packages_in_set_provider,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "missing_packages_for_session",
				     -datasource => RHN::DataSource::Package->new,
				     -provider => \&missing_packages_for_session_provider,
				     -action_callback => \&missing_packages_for_session_cb,
				     );

  Sniglets::ListView::List->add_mode(-mode => "missing_packages_for_sync",
				     -datasource => RHN::DataSource::Package->new,
				     -provider => \&missing_packages_for_sync_provider,
				     -action_callback => \&missing_packages_for_sync_cb
				     );

  Sniglets::ListView::List->add_mode(-mode => "patches_for_package",
				     -datasource => RHN::DataSource::Package->new,
				     -provider => \&patches_for_package_provider,
				     -action_callback => \&default_callback,
				     );

  Sniglets::ListView::List->add_mode(-mode => "packages_for_patch",
				     -datasource => RHN::DataSource::Package->new,
				     -action_callback => \&default_callback,
				     );

  Sniglets::ListView::List->add_mode(-mode => "patchsets_for_patch",
				     -datasource => RHN::DataSource::Package->new,
				     -action_callback => \&default_callback,
				     );

  Sniglets::ListView::List->add_mode(-mode => "patches_for_patchset",
				     -datasource => RHN::DataSource::Package->new,
				     -action_callback => \&default_callback,
				     );
}

sub default_callback {
  my $self = shift;
  my $pxt = shift;

  # think big red button
  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'confirm_package_delete') {
    return delete_packages_cb($pxt);
  }
  elsif ($label eq 'confirm_package_removal') {
    return remove_packages_cb($pxt);
  }
  elsif ($label eq 'confirm_package_upgrade') {
    return install_packages_cb($pxt);
  }
  elsif ($label eq 'confirm_package_install') {
    return install_packages_cb($pxt);
  }
  elsif ($label eq 'confirm_package_verify') {
    return verify_packages_cb($pxt);
  }
  elsif ($label eq 'package_install_remote_command') {
    return install_packages_cb($pxt, 'package_install_remote_command');
  }
  elsif ($label eq 'ssm_package_install_remote_command') {
    return ssm_install_packages_cb($pxt, 'ssm_package_install_remote_command');
  }
  elsif ($label eq 'ssm_package_install_answer_files') {
    return ssm_install_packages_cb($pxt, 'ssm_package_install_answer_files');
  }
  elsif ($label eq 'package_remove_remote_command') {
    return package_remove_remote_command_cb($pxt);
  }
  elsif ($label eq 'update_channel_packages_from_errata') {
    return add_channel_packages_cb($pxt);
  }
  elsif ($label eq 'remove_packages_from_channel') {
    return remove_packages_from_channel_cb($pxt);
  }
  elsif ($label eq 'remove_patches_from_channel') {
    return remove_patches_from_channel_cb($pxt);
  }
  elsif ($label eq 'add_packages_to_channel') {
    return add_packages_to_channel_cb($pxt);
  }
  elsif ($label eq 'add_patches_to_channel') {
    return add_patches_to_channel_cb($pxt);
  }
  elsif ($label eq 'add_patchsets_to_channel') {
    return add_patchsets_to_channel_cb($pxt);
  }
  elsif ($label eq 'remove_packages_from_errata') {
    return remove_packages_from_errata_cb($pxt);
  }
  elsif ($label eq 'add_packages_to_errata') {
    return add_packages_to_errata_cb($pxt);
  }
  elsif ($label eq 'sync_packages_to_channel') {
    return sync_packages_to_channel_cb($pxt);
  }
  return 1;
}

sub missing_packages_for_session_provider {
  my $self = shift;
  my $pxt = shift;

  my $kickstart_options = $pxt->session->get('kickstart_options');

# can't use the 'back' button b/c we clear the 'kickstart_options' session var
# So redirect if it doesn't exist
  unless (defined $kickstart_options) { 
    my $sid = $pxt->param('sid');
    $pxt->redirect('/network/systems/details/kickstart/index.pxt?sid=' . $sid);
  }

  my $trans = RHN::DB->connect;
  $trans->nest_transactions;

  my $profile = find_package_profile($pxt, $kickstart_options);

  my @channels = @{$kickstart_options->{channels}};
  my @missing_packages = $profile->profile_packages_missing_from_channels(-channels => \@channels);

  my $data;

  foreach my $package (sort { lc($a->name_arch) cmp lc($b->name_arch) } @missing_packages) {
    my $row;

    foreach my $field (qw/id name name_id epoch version release evr_id/) {
      $row->{uc($field)} = $package->$field() || '';
    }

    $row->{NVRE} = join('-', ($row->{NAME}, $row->{VERSION}, $row->{RELEASE}));
    $row->{NVRE} .= ($row->{EPOCH} ? ":" . $row->{EPOCH} : "");

    push @{$data}, $row;
  }

  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $self->datasource->slice_data($data, $self->lower, $self->upper);

  # Only look for channels for packages we are displaying on the page.

  my $base_channel_id = $profile->base_channel;
  my @valid_child_channels =
    grep { $pxt->user->verify_channel_access($_) } RHN::Channel->children($base_channel_id);

  my $channel_set = RHN::Set->lookup(-uid => $pxt->user->id, -label => 'child_channels');
  $channel_set->empty;
  $channel_set->add(@valid_child_channels);
  $channel_set->commit;

  my $package_set = RHN::Set->lookup(-uid => $pxt->user->id, -label => 'packages');
  $package_set->empty;
  $package_set->add(map { [ $_->{NAME_ID}, $_->{EVR_ID} ] } @{$data});
  $package_set->commit;

  my $channel_package_intersection =
    RHN::Package->channel_package_intersection_from_set(-user_id => $pxt->user->id,
							-package_set_label => $package_set->label,
							-channel_set_label => $channel_set->label);

  $trans->nested_rollback;

  foreach my $row (@$data) {
    my %child_channels = map { $_->{CHANNEL_NAME} } @{$channel_package_intersection->{$row->{ID}}};
    $row->{CHANNELS} = join("<br/>\n", keys %child_channels) || '';
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub missing_packages_for_session_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  my $label = $action{label};

  if ($label) {
    my $kickstart_options = $pxt->session->get('kickstart_options');

    $kickstart_options->{missing_packages_option} = $label;
    $pxt->session->set('kickstart_options', $kickstart_options);

    if (grep { $label eq $_ } qw/remove_packages subscribe_to_channels/) {
      Sniglets::Kickstart::schedule_kickstart_cb($pxt);
    }
  }

  return 1;
}

sub missing_packages_for_sync_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  my $label = $action{label};

  if ($label) {
    if (grep { $label eq $_ } qw/remove_packages subscribe_to_channels/) {
      Sniglets::Profiles::sync_server_cb($pxt, $label);
    }
    else { # going to select a different package profile, clear the set
      my $set_label = $pxt->dirty_param('set_label');
      my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
      $set->empty;
      $set->commit;
    }
  }

  return 1;
}

sub find_package_profile {
  my $pxt = shift;
  my $kickstart_options = shift;

  my $profile;

  if ($kickstart_options->{package_profile} eq 'system_profile') {
    $profile = RHN::Profile->create_from_system(-sid => $kickstart_options->{sid},
						-org_id => $pxt->user->org_id,
						-name => "Test Profile for " . $kickstart_options->{kssid},
						-description => "Test Profile" . $kickstart_options->{kssid},
						-type => 'sync_profile',
					       );

  }
  elsif ($kickstart_options->{package_profile} eq 'other_system_profile') {
    $profile = RHN::Profile->create_from_system(-sid => $kickstart_options->{sync_sid},
						-org_id => $pxt->user->org_id,
						-name => "Test Profile" . $kickstart_options->{kssid},
						-description => "Test Profile" . $kickstart_options->{kssid},
						-type => 'sync_profile',
					       );

  }
  elsif ($kickstart_options->{package_profile} eq 'stored_profile') {
    $profile = RHN::Profile->lookup(-id => $kickstart_options->{prid});
  }

  return $profile;
}

sub missing_packages_for_sync_provider {
  my $self = shift;
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my %valid_name_id = map { $_, 1 } $set->contents;

  my $source_profile_id = $pxt->param('prid');
  my $source_system_id = $pxt->param('sid_1');

  my $source;
  my $victim = RHN::Server->lookup(-id => $pxt->param('sid'));

  if ($source_profile_id) {
    $source = RHN::Profile->lookup(-id => $source_profile_id);
  }
  elsif ($source_system_id) {
    $source = RHN::Server->lookup(-id => $source_system_id);
  }
  else {
    die 'no source for sync operation?';
  }

  my $source_manifest = $source->load_package_manifest;
  my $victim_manifest = $victim->load_package_manifest;

  my @channels = map { $_->{ID} } $victim->server_channels;
  my @missing_packages = 
    grep { $valid_name_id{$_->name_id} }
      ($source_profile_id
       ? $source->profile_packages_missing_from_channels(-channels => \@channels)
       : $source->system_packages_missing_from_channels(-channels => \@channels));

  my $data;

  foreach my $package (sort { lc($a->name_arch) cmp lc($b->name_arch) } @missing_packages) {
    my $row;

    foreach my $field (qw/id name name_id epoch version release evr_id/) {
      $row->{uc($field)} = $package->$field() || '';
    }

    $row->{NVRE} = join('-', ($row->{NAME}, $row->{VERSION}, $row->{RELEASE}));
    $row->{NVRE} .= ($row->{EPOCH} ? ":" . $row->{EPOCH} : "");

    push @{$data}, $row;
  }

  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $self->datasource->slice_data($data, $self->lower, $self->upper);

  my $base_channel_id = $source->base_channel_id;
  my @valid_child_channels =
    grep { $pxt->user->verify_channel_access($_) } RHN::Channel->children($base_channel_id);

  my $channel_set = RHN::Set->lookup(-uid => $pxt->user->id, -label => 'child_channels');
  $channel_set->empty;
  $channel_set->add(@valid_child_channels);
  $channel_set->commit;

  my $package_set = RHN::Set->lookup(-uid => $pxt->user->id, -label => 'packages');
  $package_set->empty;
  $package_set->add(map { [ $_->{NAME_ID}, $_->{EVR_ID} ] } @{$data});
  $package_set->commit;

  my $channel_package_intersection =
    RHN::Package->channel_package_intersection_from_set(-user_id => $pxt->user->id,
							-package_set_label => $package_set->label,
							-channel_set_label => $channel_set->label);

  foreach my $row (@$data) {
    my @child_channels = map { $_->{CHANNEL_NAME} } @{$channel_package_intersection->{$row->{ID}}};
    $row->{CHANNELS} = join("\n", @child_channels) || '';

    Sniglets::ListView::List::escape_row($row);
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub package_name_provider {
  my $self = shift;
  my $pxt = shift;

  my $search = RHN::SearchTypes->find_type('package');
  my $mode = 'packages_by_name';

  if ($pxt->dirty_param('search_subscribed_channels')) {
    if ($pxt->user->org->server_count > 0) {
      $mode = "packages_by_name_smart";
    }
    else {
      $mode = "packages_by_name_clabel";
    }
  }

  my $ds = $self->datasource;
  $ds->mode($mode);

  my %params = map { ("-$_" => ($pxt->passthrough_param($_) || '')) } qw/channel_arch_ia32 channel_arch_ia64 channel_arch_x86_64/;
  my %ret = $self->default_provider($pxt, %params);

  return %ret;
}

sub package_removal_failures_provider {
  my $self = shift;
  my $pxt = shift;

  my %params = (-sid => $pxt->param('sid'), -action_id => $pxt->param('hid'));

  my %ret = $self->default_provider($pxt, %params);

  foreach my $row (@{$ret{data}}) {

    my $sense = RHN::Package->parse_dep_sense_flags($row->{FLAGS});
    $sense .= ' ' if $sense;

    $row->{DEPENDENCY_ERROR} = qq{$row->{PACKAGE} needs $sense$row->{NEEDED_CAPABILITY}};
  }

  return %ret;
}

sub package_verification_results_provider {
  my $self = shift;
  my $pxt = shift;

  my %params = (-sid => $pxt->param('sid'), -action_id => $pxt->param('hid'));

  my %ret = $self->default_provider($pxt, %params);

  foreach my $row (@{$ret{data}}) {
    my $package_name = join("-", $row->{PACKAGE_NAME}, $row->{PACKAGE_EVR}) . "." . $row->{PACKAGE_ARCH};
    my $verify_result = "(none)";

    my @column_message_map =
      (
       [ mode_differs => "Mode" ],
       [ size_differs => "Size" ],
       [ md5_differs => "Checksum" ],
       [ uid_differs => "User" ],
       [ gid_differs => "Group" ],
       [ mtime_differs => "Modify Time" ],
       [ devnum_differs => "Device Number" ],
       [ readlink_differs => "Symlink changed" ],
      );

    my @differs;
    for my $tuple (@column_message_map) {
      my ($col, $lab) = @$tuple;
      if ($row->{+uc $col} eq 'Y') {
	push @differs, $lab;
      }
      if ($row->{+uc $col} eq '?') {
	push @differs, $lab . " (?)";
      }
    }

    if (@differs) {
      $verify_result = join(", ", @differs);
    }
    elsif ($row->{MISSING}) {
      $verify_result = 'Missing';
    }

    $row->{VERIFY_RESULT} = $verify_result;
    $row->{PACKAGE_NAME} = $package_name;
  }

  return %ret;
}

sub package_search_results_provider {
  my $self = shift;
  my $pxt = shift;

  my $search = RHN::SearchTypes->find_type('package');
  my $mode = $pxt->dirty_param('view_mode') || '';

  die "No mode specified for package_search_results"
    unless $mode;

  my $ds = $self->datasource;
  $ds->mode($mode);

  my %ret = $self->default_provider($pxt);

  my $url_string = PXT::Utils->escapeURI($pxt->dirty_param('search_string'));

  my $string = quotemeta($pxt->dirty_param('search_string') || '');
  foreach my $row (@{$ret{data}}) {
    my $field = $row->{MATCHING_FIELD};

    # this is a weird hack.  basically MATCHING_FIELD for package
    # searches is an array ref of summaries.  we searched on
    # summaries.  but!  summaries can change between versions.  since
    # we store only package name matches, we need to find at least one
    # summary thatmatched the original search, else it not be obvious
    # why a match hit (example: ipchains when searching for kernel;
    # packagename doesn't have kernel, desc does in some versions but
    # not others)

    if (ref $field eq 'ARRAY') {
      my ($matching_field) = grep { /$string/i } @$field;
      $field = $matching_field || $row->{PACKAGE_NAME};

      $field =~ s/($string)/<strong>$1<\/strong>/gi;
    }
    else {
      $field ||= $row->{PACKAGE_NAME} || '&#160;';

      $field =~ s/($string)/<strong>$1<\/strong>/gi;
    }

    $row->{MATCHING_FIELD} = $field;
  }

  return %ret;
}

sub packages_in_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  my $mode = $channel->is_solaris() ? 'solaris_packages_in_channel' : 'packages_in_channel';

  my $ds = $self->datasource;
  $ds->mode($mode);

  return $self->default_provider($pxt);
}

sub latest_packages_in_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  my $mode = ($channel->is_solaris() == 1 ) ? 'latest_solaris_packages_in_channel' : 'latest_packages_in_channel';

  my $ds = $self->datasource;
  $ds->mode($mode);

  return $self->default_provider($pxt);
}


sub packages_available_to_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $mode = $pxt->param('view_channel') || '';
  # capture if we are working w/solaris channel
  my $solpkgmode = $channel->is_solaris();  

  if ($mode eq 'no_channels') {
    if( $solpkgmode ) {
      $ds->mode('unused_solaris_packages_available_to_channel');
    }
    else {
      $ds->mode('unused_packages_available_to_channel');
    } 
    $params{-org_id} = $pxt->user->org_id;
    $params{-cid} = $cid;
  }
  elsif ($mode =~ /channel_(\d+)/) {
    my $view_channel = $1;
    if( $solpkgmode ) {
      $ds->mode('solaris_packages_available_to_channel');
    }
    else {
      $ds->mode('packages_available_to_channel');
    }

    $params{-source_cid} = $view_channel;
    $params{-target_cid} = $cid;
  }
  elsif ($mode eq 'any_channel') {
    if( $solpkgmode ) {
      $ds->mode('all_solaris_packages_available_to_channel');
    }
    else {
      $ds->mode('all_packages_available_to_channel');
    }
    $params{-cid} = $cid;
  }
  else {
    throw "invalid mode: '$mode'";
  }

  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    if ($ds->mode eq 'unused_packages_available_to_channel') {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
    else {
      if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
	$row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
      }
      else {
	$row->{PACKAGE_CHANNELS} = '(none)';
      }
    }
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub patches_available_to_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $mode = $pxt->param('view_channel') || '';
  if ($mode eq 'no_channels') {
    $ds->mode('unused_patches_available_to_channel');
    $params{-org_id} = $pxt->user->org_id;
    $params{-cid} = $cid;
  }
  elsif ($mode =~ /channel_(\d+)/) {
    my $view_channel = $1;
    $ds->mode('patches_available_to_channel');

    $params{-source_cid} = $view_channel;
    $params{-target_cid} = $cid;
  }
  elsif ($mode eq 'any_channel') {
    $ds->mode('all_patches_available_to_channel');
    $params{-cid} = $cid;
  }
  else {
    throw "invalid mode: '$mode'";
  }

  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    if ($ds->mode eq 'unused_patches_available_to_channel') {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
    else {
      if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
	$row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
      }
      else {
	$row->{PACKAGE_CHANNELS} = '(none)';
      }
    }
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub patchsets_available_to_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $mode = $pxt->param('view_channel') || '';
  if ($mode eq 'no_channels') {
    $ds->mode('unused_patchsets_available_to_channel');
    $params{-org_id} = $pxt->user->org_id;
    $params{-cid} = $cid;
  }
  elsif ($mode =~ /channel_(\d+)/) {
    my $view_channel = $1;
    $ds->mode('patchsets_available_to_channel');

    $params{-source_cid} = $view_channel;
    $params{-target_cid} = $cid;
  }
  elsif ($mode eq 'any_channel') {
    $ds->mode('all_patchsets_available_to_channel');
    $params{-cid} = $cid;
  }
  else {
    throw "invalid mode: '$mode'";
  }

  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    if ($ds->mode eq 'unused_patchsets_available_to_channel') {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
    else {
      if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
	$row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
      }
      else {
	$row->{PACKAGE_CHANNELS} = '(none)';
      }
    }
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub packages_available_to_errata_provider {
  my $self = shift;
  my $pxt = shift;

  my $eid = $pxt->param('eid');

  my $ds = $self->datasource;
  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  my %extra_params;

  my $mode = $pxt->param('view_channel') || '';
  if ($mode =~ /channel_(\d+)/) {
    my $view_channel = $1;

    if ($errata->isa('RHN::DB::ErrataTmp')) {
      $ds->mode('packages_available_to_tmp_errata_in_channel');
    }
    elsif ($errata->isa('RHN::DB::Errata')) {
      $ds->mode('packages_available_to_errata_in_channel');
    }
    else {
      throw "Not an errata: '$errata'\n";
    }

    $extra_params{-source_cid} = $view_channel;
    $extra_params{-target_eid} = $eid;
  }
  elsif ($mode eq 'any_channel') {
    if ($errata->isa('RHN::DB::ErrataTmp')) {
      $ds->mode('packages_available_to_tmp_errata');
    }
    elsif ($errata->isa('RHN::DB::Errata')) {
      $ds->mode('packages_available_to_errata');
    }
    else {
      throw "Not an errata: '$errata'\n";
    }
  }
  else {
    throw "invalid mode: '$mode'";
  }

  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $data = $ds->execute_query(%params, %extra_params);

  $data = [ grep { RHN::Package->package_type_capable($_->{ID}, 'errata') } @{$data} ];

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    if ($ds->mode eq 'packages_in_no_channels_owned_by_org') {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
    else {
      if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
	$row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
      }
      else {
	$row->{PACKAGE_CHANNELS} = '(none)';
      }
    }
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub channel_errata_comparison_provider {
  my $self = shift;
  my $pxt = shift;

  my $eid = $pxt->param('eid');

  my $ds = $self->datasource;
  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  if ($errata->isa('RHN::DB::ErrataTmp')) {
    $ds->mode('channel_erratatmp_comparison');
  }
  elsif ($errata->isa('RHN::DB::Errata')) {
    $ds->mode('channel_errata_comparison');
  }
  else {
    throw "Not an errata: '$errata'\n";
  }

  my %ret = $self->default_provider($pxt);

  return %ret;
}

sub packages_in_errata_provider {
  my $self = shift;
  my $pxt = shift;

  my $eid = $pxt->param('eid');
  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  if ($errata->isa('RHN::DB::ErrataTmp')) {
    $self->datasource->mode('packages_in_tmp_errata');
  }

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
      $row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
    }
    else {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
  }

  return (%ret);
}

sub packages_owned_by_org_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $mode = $pxt->param('view_channel') || 'packages_owned_by_org';

  if ($mode eq 'no_channels') {
    $ds->mode('packages_in_no_channels_owned_by_org');
  }
  elsif ($mode =~ /channel_(\d+)/) {
    my $view_channel = $1;
    $ds->mode('managed_packages_in_channel');

    $params{-channel_id} = $view_channel;
  }

  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    if ($ds->mode eq 'packages_in_no_channels_owned_by_org') {
      $row->{PACKAGE_CHANNELS} = '(none)';
    }
    else {
      if (exists $row->{PACKAGE_CHANNELS} && ref $row->{PACKAGE_CHANNELS} eq 'ARRAY') {
	$row->{PACKAGE_CHANNELS} = join("<br />\n", @{$row->{PACKAGE_CHANNELS}});
      }
      else {
	$row->{PACKAGE_CHANNELS} = '(none)';
      }
    }
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub ssm_packages_for_upgrade_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    $row->{NVRE} = "$row->{PACKAGE_NAME}-$row->{PACKAGE_VERSION}-$row->{PACKAGE_RELEASE}";
    if ($row->{PACKAGE_EPOCH}) {
      $row->{NVRE} .= ":$row->{PACKAGE_EPOCH}";
    }
  }

  return (%ret);
}

sub package_download_for_system_arch_select_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);

  $params{set_label} = 'package_downloadable_list';

  my $data = $ds->execute_query(%params);

  my $prefix = '/pub/';

# get an md5 using the paths of all downloadable files
  my $computed_md5 = Digest::MD5::md5_hex(join(":", sort(map { $prefix . $_->{PATH} } @{$data})));

# filter out the packages with only one arch
  my %nvre_count;
  foreach my $package (@{$data}) {
    $nvre_count{$package->{NVRE}}++;
  }

  my $singles = [ grep { $nvre_count{$_->{NVRE}} == 1 } @{$data} ];
  $data = [ grep { $nvre_count{$_->{NVRE}} > 1 } @{$data} ];

  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $pxt->pnotes(download_packages => [ map { $prefix . $_->{PATH} } @{$singles} ]);
  $pxt->pnotes(optional_packages => [ map { $prefix . $_->{PATH} } @{$data} ]);
  $pxt->pnotes(computed_md5 => $computed_md5);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@$data) {
    Sniglets::ListView::List::escape_row($row);
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub delete_packages_cb {
  my $pxt = shift;
  my $set_label = shift || 'deletable_package_list';

  my $set = new RHN::DB::Set $set_label, $pxt->user->id;

  my @pids =  $set->contents;
  return 1 unless @pids;

  my $count = scalar @pids;

  my $package_list_edited = $pxt->session->get('package_list_edited') || { };

  my @channels = RHN::Package->package_set_channels($set_label, $pxt->user->id, $pxt->user->org_id);

  foreach my $cid (@channels) {
    next unless (RHN::Channel->channel_type_capable($cid, 'errata'));
    $package_list_edited->{$cid} = time;
  }

  $pxt->session->set(package_list_edited => $package_list_edited);

  $pxt->user->verify_package_admin(@pids);
  RHN::Package->delete_packages_from_set($set_label, $pxt->user->id);

  $set->empty;
  $set->commit;
  
  my $dbh = RHN::DB->connect();
  my $rrqh = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::delete_packages_cb', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  foreach my $cid (@channels) {
    my $channel = RHN::Channel->lookup(-id => $cid);
	$rrqh->execute_h(label => $channel->label);
  }
  

  my $channel_count = scalar(@channels);
  $pxt->push_message(site_info => sprintf("<strong>%d</strong> package%s deleted from <strong>%d</strong> channel%s.",
					  $count, $count == 1 ? '' : 's',
					  $channel_count, $channel_count == 1 ? '' : 's'));

# Now, update the latest package cache
  foreach my $cid (@channels) {
    RHN::Channel->refresh_newest_package_cache($cid, 'web.package_manager');
  }

  return 1;
}

sub remove_packages_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $earliest_date = RHN::Date->now->long_date;
  my $actions_scheduled =
    RHN::Scheduler->schedule_system_package_action(-org_id => $pxt->user->org_id,
						   -user_id => $pxt->user->id,
						   -earliest => $earliest_date,
						   -sid => $sid,
						   -id_combos => [ $package_set->contents ],
						   -action_type => 'remove',
						  );

  my $system = RHN::Server->lookup(-id => $sid);

  my @actions = map { RHN::Action->lookup(-id => $_) } keys %{$actions_scheduled};

  foreach my $action_id (keys %{$actions_scheduled}) {
    my $package_count = scalar @{$actions_scheduled->{$action_id}};
    $pxt->push_message(site_info => 
		       sprintf('<strong>%d</strong> package removal%s been <a href="/rhn/schedule/ActionDetails.do?aid=%d">scheduled</a> for <a href="/rhn/systems/details/Overview.do?sid=%d"><strong>%s</strong></a>.',
			     $package_count, $package_count == 1 ? ' has' : 's have', $action_id,
			     $sid, PXT::Utils->escapeHTML($system->name)));
  }

  $package_set->empty;
  $package_set->commit;

  return @actions;
}

sub check_action_file_upload_status {
  my $pxt = shift;
  my $mode = shift;

  my $packages_needing_answer_files_set = RHN::Set->lookup(-label => 'package_answer_file_list', -uid => $pxt->user->id);
  my @packages_needing_answer_files = map { join('|', @{$_}) } $packages_needing_answer_files_set->contents;

  my $package_answer_files = $pxt->session->get('package_answer_files') || { };
  my @not_yet_provided = grep { not defined $package_answer_files->{$_} } @packages_needing_answer_files;

  if (@not_yet_provided) {
    my $redir;

    if ($mode eq 'ssm_package_install_remote_command'
	or $mode eq 'ssm_package_install_answer_files') {
      $redir = sprintf(
      '/network/systems/ssm/packages/upload_answer_file.pxt?cid=%d&set_label=%s&id_combo=%s&mode=%s',
      $pxt->param('cid'),
      $pxt->dirty_param('set_label'), $not_yet_provided[0], $mode);
    }
    else {
      $redir = sprintf(
      '/network/systems/details/packages/upload_answer_file.pxt?sid=%d&set_label=%s&id_combo=%s&mode=%s',
      $pxt->param('sid'), $pxt->dirty_param('set_label'),
      $not_yet_provided[0], $mode,
      );
    }

    $pxt->redirect($redir);
  }

  if ($mode eq 'package_install_remote_command') {
    package_install_remote_command_cb($pxt);
  }
  elsif (grep { $mode eq $_ }
      qw/ssm_package_install_answer_files
	 ssm_package_install_remote_command
	 confirm_package_install/) {
  # noop
  }
  else {
    die "unknown mode: $mode";
  }

  $pxt->session->unset('package_answer_files');

  return $package_answer_files;
}

sub install_packages_cb {
  my $pxt = shift;
  my $mode = shift || 'confirm_package_install';

  my $sid = $pxt->param('sid');
  my $package_answer_files;

  if (RHN::Server->system_profile_capable($sid, 'deploy_answer_file')) {
    $package_answer_files = check_action_file_upload_status($pxt, $mode);

    my $packages_needing_answer_files_set = RHN::Set->lookup(-label => 'package_answer_file_list', -uid => $pxt->user->id);
    $packages_needing_answer_files_set->empty;
    $packages_needing_answer_files_set->commit;
  }
  elsif ($mode eq 'package_install_remote_command') {
    package_install_remote_command_cb($pxt);
  }

  my $package_set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $package_set_label;

  my $package_set = RHN::Set->lookup(-label => $package_set_label, -uid => $pxt->user->id);

  my $earliest_date = RHN::Date->now->long_date;
  my $actions_scheduled =
    RHN::Scheduler->schedule_system_package_action(-org_id => $pxt->user->org_id,
						   -user_id => $pxt->user->id,
						   -earliest => $earliest_date,
						   -sid => $sid,
						   -id_combos => [ $package_set->contents ],
						   -action_type => 'install',
						  );

  if (RHN::Server->system_profile_capable($sid, 'deploy_answer_file')) {
    foreach my $action_id (keys %{$actions_scheduled}) {
      RHN::Scheduler->associate_answer_files_with_action($action_id, $package_answer_files);
    }
  }

  my $system = RHN::Server->lookup(-id => $sid);

  my @actions = map { RHN::Action->lookup(-id => $_) } keys %{$actions_scheduled};

  my ($pkg_action) = grep { $_->action_type_label =~ /\.(install|update)/ } @actions;
  my ($pcluster_action) = grep { $_->action_type_label =~ /\.patchClusterInstall/ } @actions;
  my ($patch_action) = grep { $_->action_type_label =~ /\.patchInstall/ } @actions;

  if ($pkg_action) {
    if ($pcluster_action) {
      $pcluster_action->prerequisite($pkg_action->id);
    }
    elsif ($patch_action) {
      $patch_action->prerequisite($pkg_action->id)
    }
  }

  if ($pcluster_action and $patch_action) {
    $patch_action->prerequisite($pcluster_action->id);
  }

  $pkg_action->commit if $pkg_action;
  $pcluster_action->commit if $pcluster_action;
  $patch_action->commit if $patch_action;

  foreach my $action_id (keys %{$actions_scheduled}) {
    my $package_count = scalar @{$actions_scheduled->{$action_id}};
    $pxt->push_message(site_info =>
		       sprintf('<strong>%d</strong> package install%s been <a href="/rhn/schedule/ActionDetails.do?aid=%d">scheduled</a> for <a href="/rhn/systems/details/Overview.do?sid=%d"><strong>%s</strong></a>.',
			       $package_count, $package_count == 1 ? ' has' : 's have', $action_id,
			       $sid, PXT::Utils->escapeHTML($system->name)));
  }

  $package_set->empty;
  $package_set->commit;

  my @action_order = grep { defined $_ } ($pkg_action, $pcluster_action, $patch_action);

  return wantarray ? @action_order : 1;
}

sub verify_packages_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  my $package_set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $package_set_label;

  my $package_set = RHN::Set->lookup(-label => $package_set_label, -uid => $pxt->user->id);

  my $earliest_date = RHN::Date->now->long_date;
  my $actions_scheduled =
    RHN::Scheduler->schedule_system_package_action(-org_id => $pxt->user->org_id,
						   -user_id => $pxt->user->id,
						   -earliest => $earliest_date,
						   -sid => $sid,
						   -id_combos => [ $package_set->contents ],
						   -action_type => 'verify',
						  );

  my $system = RHN::Server->lookup(-id => $sid);

  foreach my $action_id (keys %{$actions_scheduled}) {
    my $package_count = scalar @{$actions_scheduled->{$action_id}};
    $pxt->push_message(site_info =>
		       sprintf('<strong>%d</strong> package verif%s been <a href="/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d">scheduled</a> for <a href="/rhn/systems/details/Overview.do?sid=%d"><strong>%s</strong></a>.',
			       $package_count, $package_count == 1 ? 'y has' : 'ies have', $system->id, $action_id,
			       $sid, PXT::Utils->escapeHTML($system->name)));
  }

  $package_set->empty;
  $package_set->commit;

  return 1;
}

sub ssm_install_packages_cb {
  my $pxt = shift;
  my $mode = shift || 'confirm_ssm_package_install';

  my $package_answer_files;

  $package_answer_files = check_action_file_upload_status($pxt, $mode);

  my $packages_needing_answer_files_set = RHN::Set->lookup(-label => 'package_answer_file_list', -uid => $pxt->user->id);
  $packages_needing_answer_files_set->empty;
  $packages_needing_answer_files_set->commit;

  if ($mode eq 'ssm_package_install_answer_files') {
    $pxt->session->set('package_answer_files', $package_answer_files);
    $pxt->redirect('/network/systems/ssm/packages/install_conf.pxt?cid=' . $pxt->param('cid'));
  }
  elsif ($mode eq 'ssm_package_install_remote_command') {
    $pxt->session->set('package_answer_files', $package_answer_files);
    $pxt->redirect('/network/systems/ssm/packages/schedule_remote_command.pxt?mode=ssm_package_install&cid=' . $pxt->param('cid'));
  }

  return;
}

sub package_install_remote_command_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  my $set_label = $pxt->dirty_param('set_label');

  $pxt->redirect("/rhn/systems/details/packages/ScheduleRemoteCommand.do?sid=$sid&set_label=$set_label&mode=package_install");

  return 1;
}

sub package_remove_remote_command_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  my $set_label = $pxt->dirty_param('set_label');

  $pxt->redirect("/rhn/systems/details/packages/ScheduleRemoteCommand.do?sid=$sid&set_label=$set_label&mode=package_remove");

  return 1;
}

my %adv_icon = ('Bug Fix Advisory' => '/img/wrh-bug.gif',
		 'Product Enhancement Advisory' => '/img/wrh-product.gif',
		 'Security Advisory' => '/img/wrh-security.gif');

sub system_upgradable_package_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $data = $ds->execute_query(%params);

  my %latest;

  foreach my $row (@{$data}) {
     my @eids;
     my @eadvs;
     my @etypes;

     push @eids, $row->{ERRATA_ID} if $row->{ERRATA_ID};
     push @eadvs, $row->{ERRATA_ADVISORY} if $row->{ERRATA_ADVISORY};
     push @etypes, $row->{ERRATA_ADVISORY_TYPE} if $row->{ERRATA_ADVISORY_TYPE};

     if (not exists $latest{$row->{NAME_ID}}) {
       $latest{$row->{NAME_ID}} = $row;
     }
     else {
       my $cmp = RHN::Package->vercmp($row->{EPOCH},
				      $row->{VERSION},
				      $row->{RELEASE},
				      $latest{$row->{NAME_ID}}->{EPOCH},
				      $latest{$row->{NAME_ID}}->{VERSION},
				      $latest{$row->{NAME_ID}}->{RELEASE});

       push @eids, @{$latest{$row->{NAME_ID}}->{ERRATA_ID}};
       push @eadvs, @{$latest{$row->{NAME_ID}}->{ERRATA_ADVISORY}};
       push @etypes, @{$latest{$row->{NAME_ID}}->{ERRATA_ADVISORY_TYPE}};

       $latest{$row->{NAME_ID}} = $row
 	if $cmp >= 0;
     }
     $latest{$row->{NAME_ID}}->{ERRATA_ID} = \@eids;
     $latest{$row->{NAME_ID}}->{ERRATA_ADVISORY} = \@eadvs;
     $latest{$row->{NAME_ID}}->{ERRATA_ADVISORY_TYPE} = \@etypes;
  }

  my $ret = [ map { $latest{$_} } sort { uc($latest{$a}->{NVRE}) cmp uc($latest{$b}->{NVRE}) } keys %latest ];

# done with munging - we have the actual list we want to work with.
# Work out the alphabar, the filter, save the ids, and slice it.

  my $alphabar = $self->init_alphabar($ret);
  $ret = $self->filter_data($ret);

  my @all_ids = map { $_->{ID} } @{$ret};
  $self->all_ids(\@all_ids);

  $ret = $ds->slice_data($ret, $self->lower, $self->upper);

# now do some custom row display for multiple installed packages, and
# the related errata
  foreach my $row (@{$ret}) {
    my $name_id = $row->{NAME_ID};
    my $evr_id = $row->{EVR_ID};

    my @nvres = RHN::Package->installed_package_nvre($pxt->param('sid'), $name_id, $evr_id);

    $row->{INSTALLED_PACKAGE_NVRE} = join("<br />\n", @nvres);

    my @adv_types = @{$row->{ERRATA_ADVISORY_TYPE}};
    my @errata;

    foreach my $adv (@{$row->{ERRATA_ADVISORY}}) {
      my $adv_id = shift @{$row->{ERRATA_ID}};
      my $adv_type = shift @adv_types;
      push @errata, sprintf('<img src="%s" alt="%s" />&#160;<a href="/rhn/errata/details/Details.do?eid=%s">%s</a>', $adv_icon{$adv_type}, $adv_type, $adv_id, $adv);
    }

    $row->{RELATED_ERRATA} = join("<br />\n", @errata);
  }

  return (data => $ret,
	  all_ids => \@all_ids,
	  alphabar => $alphabar);
}


sub obsoleting_packages_provider {
  my $self = shift;
  my $pxt = shift;
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $adv = $row->{ADVISORY};
    my $adv_type = $row->{ADVISORY_TYPE};
    my $adv_id = $row->{ERRATA_ID};

    $row->{RELATED_ERRATA} = sprintf('<img src="%s" alt="%s" />&#160;<a href="/rhn/errata/details/Details.do?eid=%s">%s</a>', $adv_icon{$adv_type}, $adv_type, $adv_id, $adv);
  }

  return (%ret);
}


sub profile_comparison_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params;
  my $compare_sid;
  my $compare_prid;

  my $other_name = 'Profile';

  if ($compare_sid = $pxt->param('sid_1')) {
    $pxt->user->verify_system_access($compare_sid)
	or $pxt->redirect('/errors/permission.pxt');

    my $s = RHN::Server->lookup(-id => $compare_sid);
    $other_name = $s->name;
    $ds->mode('system_canonical_package_list');
    %params = $self->lookup_params($pxt, $ds->required_params);

    $params{-sid} = $compare_sid;
  }
  elsif ($compare_prid = $pxt->param('prid')) {
    $ds->mode('profile_canonical_package_list');
    %params = $self->lookup_params($pxt, $ds->required_params);
  }
  else {
    throw 'profile comparison provider needs a profile to compare to.';
  }

  my $compare_data = $ds->execute_query(%params);
  $compare_data = $ds->elaborate($compare_data, %params);

  my $primary_ds = RHN::DataSource::Package->new;
  $primary_ds->mode('system_canonical_package_list');
  my %prim_params = $self->lookup_params($pxt, $primary_ds->required_params);

  my $primary_data = $primary_ds->execute_query(%prim_params);

  my $delta = RHN::Package->delta_canonical_lists_hashref($compare_data, $primary_data);

  my @present;
  my @missing;
  my @newer;
  my @older;

  foreach my $row (@$delta) {
    if ($row->{S1}->{EVR_ID} and not $row->{S2}->{EVR_ID}) {
      $row->{RPM_COMPARISON} = "$other_name only";
    }
    elsif ($row->{S2}->{EVR_ID} and not $row->{S1}->{EVR_ID}) {
      $row->{RPM_COMPARISON} = "This system only";
    }
    elsif ($row->{COMPARISON} < 0) {
      $row->{RPM_COMPARISON} = "This system newer";
    }
    elsif ($row->{COMPARISON} > 0) {
      $row->{RPM_COMPARISON} = "$other_name newer";
    }
    $row->{SYSTEM_PACKAGE_EVR} = $row->{S2}->{EVR} || '&#160;';
    $row->{PROFILE_PACKAGE_EVR} = $row->{S1}->{EVR} || '&#160;';

    $row->{ID} = $row->{NAME_ID};
  }

  $delta = [ sort { lc $a->{NAME} cmp lc $b->{NAME} } @{$delta} ];

# done with munging - we have the actual list we want to work with.  slice it.
  my $alphabar = $self->init_alphabar($delta);
  my $on_page = $self->filter_data($delta);

  my @all_ids = map { $_->{ID} } @{$on_page};
  $self->all_ids(\@all_ids);
  $on_page = $primary_ds->slice_data($on_page, $self->lower, $self->upper);

  return (data => $on_page,
	  all_ids => \@all_ids,
	  alphabar => $alphabar,
	  full_data => $delta);
}

sub snapshot_comparison_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params;

  my $snapshot_label = "Snapshot";

  $ds->mode('snapshot_canonical_package_list');
  %params = $self->lookup_params($pxt, $ds->required_params);

  my $compare_data = $ds->execute_query(%params);
  $compare_data = $ds->elaborate($compare_data, %params);

  my $primary_ds = RHN::DataSource::Package->new;
  $primary_ds->mode('system_canonical_package_list');
  my %prim_params = $self->lookup_params($pxt, $primary_ds->required_params);

  my $primary_data = $primary_ds->execute_query(%prim_params);

  my $delta = RHN::Package->delta_canonical_lists_hashref($compare_data, $primary_data);

  my @present;
  my @missing;
  my @newer;
  my @older;

  foreach my $row (@$delta) {
    if ($row->{S1}->{EVR_ID} and not $row->{S2}->{EVR_ID}) {
      $row->{RPM_COMPARISON} = "$snapshot_label only";
    }
    elsif ($row->{S2}->{EVR_ID} and not $row->{S1}->{EVR_ID}) {
      $row->{RPM_COMPARISON} = "Current profile only";
    }
    elsif ($row->{COMPARISON} < 0) {
      $row->{RPM_COMPARISON} = "Current profile newer";
    }
    elsif ($row->{COMPARISON} > 0) {
      $row->{RPM_COMPARISON} = "$snapshot_label newer";
    }
    $row->{CURRENT_PACKAGE_EVR} = $row->{S2}->{EVR} || '&#160;';
    $row->{SNAPSHOT_PACKAGE_EVR} = $row->{S1}->{EVR} || '&#160;';

    $row->{ID} = $row->{NAME_ID};
  }

  $delta = [ sort { lc $a->{NAME} cmp lc $b->{NAME} } @{$delta} ];

# done with munging - we have the actual list we want to work with.  slice it.
  my $alphabar = $self->init_alphabar($delta);
  my $on_page = $self->filter_data($delta);

  my @all_ids = map { $_->{ID} } @{$on_page};
  $self->all_ids(\@all_ids);
  $on_page = $primary_ds->slice_data($on_page, $self->lower, $self->upper);

  return (data => $on_page,
	  all_ids => \@all_ids,
	  alphabar => $alphabar,
	  full_data => $delta);
}

sub packages_for_sync_provider {
  my $self = shift;
  my $pxt = shift;

  $self->datasource->mode('system_profile_comparison');

  my %results = $self->profile_comparison_provider($pxt);

  my $set_label = $pxt->dirty_param('set_label');
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  my %name_ids = map { $_, 1 } $set->contents;

  $results{full_data} = [ grep { $name_ids{$_->{NAME_ID}} } @{$results{full_data}} ];
  $results{all_ids} = [ map { $_->{NAME_ID} } @{$results{full_data}} ];
  $self->all_ids($results{all_ids});

  $results{data} = $self->datasource->slice_data($results{full_data}, $self->lower, $self->upper);


  foreach my $row (@{$results{data}}) {
    if ($row->{S1}->{EVR_ID} and not $row->{S2}->{EVR_ID}) {
      $row->{ACTION} = 'Install';
    }
    elsif ($row->{S2}->{EVR_ID} and not $row->{S1}->{EVR_ID}) {
      $row->{ACTION} = 'Remove';
    }
    elsif ($row->{COMPARISON} < 0) {
      $row->{ACTION} = 'Downgrade to ' . $row->{S1}->{EVR};
    }
    elsif ($row->{COMPARISON} > 0) {
      $row->{ACTION} = 'Upgrade to ' . $row->{S1}->{EVR};
    }

    $row->{NVRE} = $row->{NAME};
    if (defined $row->{S2}->{EVR}) {
      $row->{NVRE} .= '-' . $row->{S2}->{EVR};
    }
    elsif (defined $row->{S1}->{EVR}) {
      $row->{NVRE} .= '-' . $row->{S1}->{EVR};
    }
  }

  return (%results);
}

sub compare_managed_channel_packages_provider {
  my $self = shift;
  my $pxt = shift;

  my $left_ds = new RHN::DataSource::Package(-mode => 'newest_packages_in_channel');
  my $right_ds = new RHN::DataSource::Package(-mode => 'newest_packages_in_channel');

  my $right_cid = $pxt->param('view_channel') || '';
  $right_cid =~ s/^channel_//;

  return (data => [ ],
	  all_ids => [ ],
	  alphabar => '') unless $right_cid;

  my $left_data = $left_ds->execute_query(-cid => $pxt->param('cid'));
  my $right_data = $right_ds->execute_query(-cid => $right_cid);

  my $left_manifest = datasource_result_into_manifest($left_data,$pxt->user->org_id);
  my $right_manifest = datasource_result_into_manifest($right_data,$pxt->user->org_id);

  my $comparison = $left_manifest->compare_manifests($right_manifest);

  @{$comparison} = grep { (exists $_->{COMPARISON}) ? $_->{COMPARISON} != 0 : 1 } @{$comparison};

  my $comp_channel = RHN::Channel->lookup(-id => $right_cid);
  my $other_name = $comp_channel->name;

  my $data = [ sort { $a->{LC_NAME} cmp $b->{LC_NAME} }
    map { { ID => ($_->{S1}->{name_id} || '') . '|' . ($_->{S1}->{evr_id} || ''),
	    NAME => $_->{NAME},
            LC_NAME => lc($_->{NAME}),
	    ARCH => (ref $_->{S1} eq 'RHN::Manifest::Package') ? $_->{S1}->arch
	            : (ref $_->{S2} eq 'RHN::Manifest::Package') ? $_->{S2}->arch : '',
	    LEFT_NVREA => (ref $_->{S1} eq 'RHN::Manifest::Package') ? $_->{S1}->as_vre : "&#160;",
	    LEFT_ID => (ref $_->{S1} eq 'RHN::Manifest::Package') ? $_->{S1}->id : 0,
	    RIGHT_ID => (ref $_->{S2} eq 'RHN::Manifest::Package') ? $_->{S2}->id : 0,
	    RIGHT_NVREA => (ref $_->{S2} eq 'RHN::Manifest::Package') ? $_->{S2}->as_vre : "&#160;",
	    COMPARISON => comparison_string($_, $other_name),
      	  } } @{$comparison} ];

  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my @all_ids = map { $_->{ID} } @{$data};
  $self->all_ids(\@all_ids);

  $data = RHN::DataSource->slice_data($data, $self->lower, $self->upper);

  return (data => $data,
	  all_ids => \@all_ids,
	  alphabar => $alphabar);
}

sub comparison_string {
  my $row = shift;
  my $other_name = shift;

  if ($row->{S1} and $row->{S1}->{evr_id} and not $row->{S2}->{evr_id}) {
    return "This channel only";
  }
  elsif ($row->{S2} and $row->{S2}->{evr_id} and not $row->{S1}->{evr_id}) {
    return "$other_name only";
  }

  my $comparison = $row->{S1} cmp $row->{S2};

  if ($comparison > 0) {
    return "This channel newer";
  }
  elsif ($comparison < 0) {
    return "$other_name newer";
  }

  die "Invalid comparison in '" . Data::Dumper->Dump([($row)]) . "'\n";
}

sub managed_channel_merge_preview_provider {
  my $self = shift;
  my $pxt = shift;

  my $row_map = create_package_sync_map($pxt);

  my @data;
  my $sync_type = $pxt->dirty_param('sync_type') || '';

  if ($sync_type eq 'full_sync') {
    @data = grep { not ($_->{EXISTS_RIGHT} and $_->{EXISTS_LEFT}) } values %{$row_map};
  }
  elsif ($sync_type eq 'add_only') {
    @data = grep { $_->{EXISTS_RIGHT} and not $_->{EXISTS_LEFT} } values %{$row_map};
  }
  elsif ($sync_type eq 'remove_only') {
    @data = grep { not $_->{EXISTS_RIGHT} and $_->{EXISTS_LEFT} } values %{$row_map};
  }
  else {
    throw "Invalid sync type: '$sync_type'\n";
  }

  @data = sort { $a->{NAME} cmp $b->{NAME}
		   || RHN::Manifest::Package->vercmp($a->{EPOCH}, $a->{VERSION}, $a->{RELEASE},
						     $a->{EPOCH}, $a->{VERSION}, $a->{RELEASE}) } @data;

  my $data = $self->filter_data(\@data);
  my $alphabar = $self->init_alphabar($data);

  my @all_ids = map { $_->{ID} } @{$data};
  $self->all_ids(\@all_ids);

  $data = RHN::DataSource->slice_data($data, $self->lower, $self->upper);

  return (data => $data,
	  all_ids => \@all_ids,
	  alphabar => $alphabar);
}

sub create_package_sync_map {
  my $pxt = shift;

  my $left_ds = new RHN::DataSource::Package(-mode => 'packages_in_channel');
  my $right_ds = new RHN::DataSource::Package(-mode => 'packages_in_channel');

  my $right_cid = $pxt->param('view_channel') || '';
  $right_cid =~ s/^channel_//;

  return (data => [ ],
	  all_ids => [ ],
	  alphabar => '') unless $right_cid;

  my $left_data = $left_ds->execute_query(-cid => $pxt->param('cid'));
  my $right_data = $right_ds->execute_query(-cid => $right_cid);

  $left_data = [ sort { lc($a->{NVREA}) cmp lc($b->{NVREA}) } @{$left_data} ];
  $right_data = [ sort { lc($a->{NVREA}) cmp lc($b->{NVREA}) } @{$right_data} ];

  my %row_map;

  foreach my $row (@{$left_data}) {
      $row->{EXISTS_LEFT} = 1;
      $row->{EXISTS_RIGHT} = 0;
      $row->{ACTION} = 'remove';
      $row->{ID} = $row->{ID};
      $row_map{$row->{ID}} = $row;
  }

  foreach my $row (@{$right_data}) {
    my $preexist_id = $row->{ID};
    if (exists $row_map{$preexist_id}) {
      $row_map{$preexist_id}->{EXISTS_RIGHT} = 1;
      $row_map{$preexist_id}->{ACTION} = 'noop';
    }
    else {
      $row->{EXISTS_RIGHT} = 1;
      $row->{EXISTS_LEFT} = 0;
      $row->{ACTION} = 'add';
      $row->{ID} = $row->{ID};
      $row_map{$row->{ID}} = $row;
    }
  }

  return \%row_map;
}

sub sync_confirm_packages_in_set_provider {
  my $self = shift;
  my $pxt = shift;

  my $row_map = create_package_sync_map($pxt);

  $self->datasource->mode('package_ids_in_set');
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    throw "Package '" . $row->{ID} . "' in set, but not available for merge.\n"
      unless exists $row_map->{$row->{ID}};

    $row->{ACTION} = $row_map->{$row->{ID}}->{ACTION};
  }

  return %ret;
}

sub patches_for_package_provider {
  my $self = shift;
  my $pxt = shift;

  my $pid = $pxt->param('pid');
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    if (exists $row->{__data__} && ref $row->{__data__} eq 'ARRAY') {
      $row->{PATCH_SET_URLS} = join("<br />\n",
        map { PXT::HTML->link("/rhn/software/packages/Details.do?pid=" . $_->{PATCH_SET_ID},
			      $_->{PATCH_SET_SUMMARY})
  	    } @{$row->{__data__}}
				   );
    }
    else {
      $row->{PATCH_SET_URLS} = '(none)';
    }
  }

  return (%ret);
}

sub sync_packages_to_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my @contents = $set->contents;

  my $row_map = create_package_sync_map($pxt);
  my (@add, @remove);

  foreach my $id (@contents) {
    push @add, $id if $row_map->{$id}->{ACTION} eq 'add';
    push @remove, $id if $row_map->{$id}->{ACTION} eq 'remove';
  }

  RHN::ChannelEditor->add_channel_packages($cid, @add);
  RHN::ChannelEditor->remove_channel_packages($cid, @remove);

  $set->empty;
  $set->commit;

  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');
  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $channel->id, 3600);

  if (RHN::Channel->channel_type_capable($channel->id, 'errata')) {
    my $package_list_edited = $pxt->session->get('package_list_edited') || { };
    $package_list_edited->{$channel->id} = time;
    $pxt->session->set(package_list_edited => $package_list_edited);
  }

  $pxt->param("message", "channel.manage.merge.finished");
  $pxt->param("messagep1", scalar @add ? scalar @add : "0");
  $pxt->param("messagep2", scalar @remove ? scalar @remove : "0");

  return 1;
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if ($self->{__mode__}->{__name__} eq "ssm_packages_for_upgrade" and $row->{ADVISORY}) {
    $row->{ADVISORY} = PXT::HTML->img(-src => '/img/wrh-' . lc ((split /[\s]/, $row->{ADVISORY_TYPE})[0]) . '.gif',
				      -alt => $row->{ADVISORY_TYPE},
				      -title => $row->{ADVISORY_TYPE}) . ' &#160;' . $row->{ADVISORY};
  }
  elsif (($self->{__mode__}->{__name__} eq "packages_from_server_set") || 
         ($self->{__mode__}->{__name__} eq "verify_packages_from_server_set" ) ||
         ($self->{__mode__}->{__name__} eq "patches_from_server_set")) {

    $row->{NVRE} = "$row->{NAME}-$row->{VERSION}-$row->{RELEASE}";
    if ($row->{EPOCH}) {
      $row->{NVRE} .= ":$row->{EPOCH}";
    }
  }

  return $row;
}

sub sets_differ {
  my ($first, $second) = @_;

  my %elements;

  foreach my $elem (@{$first}, @{$second}) {
    $elements{$elem}++;
  }

  foreach my $elem (keys %elements) {
    return 1 unless ($elements{$elem} == 2);
  }

  return 0;
}

# If an action button was pressed, and the set is empty, generally
# clear the action, and push an error onto the stack.
sub empty_set_action_cb { #overridden from ListView::List
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

# packages_owned_by_org shoud allow empty selection - channel, errata,
# and package management use this
  if ($self->mode->{__name__} eq 'packages_owned_by_org') {
    return %action;
  }
  elsif ($self->mode->{__name__} eq 'packages_in_set') {
    return %action;
  }

  return $self->SUPER::empty_set_action_cb($pxt, %action);
}

sub add_channel_packages_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  my $channel_id = $pxt->param('cid');
  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  RHN::ChannelEditor->add_channel_packages($channel_id, $package_set->contents);
  RHN::Channel->refresh_newest_package_cache($channel_id, 'web.errata_cloning');
  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $channel_id, 0);

  if (RHN::Channel->channel_type_capable($channel_id, 'errata')) {
    my $package_list_edited = $pxt->session->get('package_list_edited') || { };
    $package_list_edited->{$channel_id} = 0;
    $pxt->session->set(package_list_edited => $package_list_edited);
  }

  $package_set->empty;
  $package_set->commit;

  my $action_type;
  if ($pxt->dirty_param('publish_errata')) {
    $action_type = 'publish_errata';
  }
  elsif ($pxt->dirty_param('update_channels')) {
    $action_type = 'update_channels';
  }
  else {
    throw "The action type parameter is missing.  It should have been preserved."
  }

  my $channel_set = RHN::Set->lookup(-label => 'update_channels_list', -uid => $pxt->user->id);

  my @updates_needed = $channel_set->contents;

  if (@updates_needed) {
    my $cid = pop @updates_needed;

    my $next_package_set = RHN::Set->lookup(-label => 'update_package_list', -uid => $pxt->user->id);
    $next_package_set->empty;

    my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $pxt->param('eid'));
    my $eid_cloned_from = $errata->cloned_from;
    my $cid_cloned_from = RHN::Channel->channel_cloned_from($cid);

    if ($eid_cloned_from and $cid_cloned_from
	and RHN::Channel->is_errata_for_channel($eid_cloned_from, $cid_cloned_from)) {
      my $ds = new RHN::DataSource::Package(-mode => 'channel_errata_full_intersection');
      my $data = $ds->execute_full(-eid => $eid_cloned_from, -cid => $cid_cloned_from);

      if (@{$data}) {
	$next_package_set->add(map { $_->{ID} } @{$data});
	$pxt->push_message(local_info => 'This errata is cloned from an official Red Hat errata, and the channel you are publishing this errata to is the clone of a Red Hat channel.  Packages which are associated with the original channel and errata are preselected below.');
      }
    }
    $next_package_set->commit;

    $channel_set->empty;
    $channel_set->add(@updates_needed);
    $channel_set->commit;

    my $redir = $pxt->dirty_param('update_channel_redirect');

    throw "Param 'update_channel_redirect' needed but not provided"
      unless $redir;

    my $eid = $pxt->param('eid');
    # bugzilla: 197966 - need to retain the action_type
    $pxt->redirect($redir . "?eid=${eid}&cid=${cid}&${action_type}=1");
  }
  elsif ($action_type eq 'publish_errata') {
    Sniglets::ErrataEditor::errata_publish_cb($pxt);
  }
  else {
    Sniglets::ErrataEditor::select_channels_cb($pxt);
  }

  return 1;
}

sub remove_packages_from_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  $channel->remove_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');
  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $channel->id, 3600);

  if (RHN::Channel->channel_type_capable($channel->id, 'errata')) {
    my $package_list_edited = $pxt->session->get('package_list_edited') || { };
    $package_list_edited->{$channel->id} = time;
    $pxt->session->set(package_list_edited => $package_list_edited);
  }

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> package%s removed from channel <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 's',
					  $channel->name));

  return 1;
}

sub remove_patches_from_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  # patches are also rhnPackages
  $channel->remove_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  # upate rhnChannelNewestPackage
  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> patch%s removed from channel <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 'es',
					  $channel->name));

  return 1;
}

sub add_packages_to_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  $channel->add_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');
  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $channel->id, 3600);

  if (RHN::Channel->channel_type_capable($channel->id, 'errata')) {
    my $package_list_edited = $pxt->session->get('package_list_edited') || { };
    $package_list_edited->{$channel->id} = time;
    $pxt->session->set(package_list_edited => $package_list_edited);
  }

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> package%s added to channel <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 's',
					  $channel->name));

  return 1;
}

sub add_patches_to_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No patch set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  $channel->add_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> patch%s added to channel <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 'es',
					  $channel->name));

  return 1;
}

sub add_patchsets_to_channel_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No patchset set label" unless $set_label;

  my $cid = $pxt->param('cid');
  my $channel = RHN::Channel->lookup(-id => $cid);

  $channel->add_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  RHN::Channel->refresh_newest_package_cache($channel->id, 'web.channel_manager');

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> patchset%s added to channel <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 's',
					  $channel->name));

  return 1;
}

sub remove_packages_from_errata_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $eid = $pxt->param('eid');
  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  $errata->remove_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $count = scalar $package_set->contents;

  $package_set->empty;
  $package_set->commit;

  unless ($errata->isa('RHN::DB::ErrataTmp')) {

    foreach my $cid (RHN::Errata->channels($eid)) {
      RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 3600);
    }
    my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
    $package_list_edited->{$eid} = time;
    $pxt->session->set(errata_package_list_edited => $package_list_edited);
  }

  $errata->refresh_erratafiles;

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> package%s removed from errata <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 's',
					  $errata->advisory));

  return 1;
}

sub add_packages_to_errata_cb {
  my $pxt = shift;

  my $set_label = $pxt->dirty_param('set_label');
  throw "No package set label" unless $set_label;

  my $eid = $pxt->param('eid');
  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  $errata->add_packages_in_set(-set_label => $set_label, -user_id => $pxt->user->id);

  my $package_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  my $count = scalar $package_set->contents;
  $package_set->empty;
  $package_set->commit;

  unless ($errata->isa('RHN::DB::ErrataTmp')) {
    foreach my $cid (RHN::Errata->channels($eid)) {
      RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 3600);
    }

    my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
    $package_list_edited->{$eid} = time;
    $pxt->session->set(errata_package_list_edited => $package_list_edited);
  }

  $errata->refresh_erratafiles;

  $pxt->push_message(site_info => sprintf("<strong>%d</strong> package%s added to errata <strong>%s</strong>.",
					  $count, $count == 1 ? '' : 's',
					  $errata->advisory));

  return 1;
}

sub datasource_result_into_manifest {
  my $data = shift;
  my $org_id = shift;

  my $manifest = new RHN::Manifest(-org_id => $org_id);
  for my $row (@$data) {
    my $pkg = new RHN::Manifest::Package(map { ("-$_" => $row->{+uc $_}) } qw/id name version release epoch name_id evr_id arch/);
    $pkg->associate_data('errata' => $row->{ERRATA}) if exists $row->{ERRATA};

    $manifest->add_package($pkg);
  }

  $manifest->filter_old_packages;

  return $manifest;
}

sub is_row_selectable {
  my $self = shift;
  my $pxt = shift;
  my $row = shift;

  my $mode = $self->datasource->mode();

  if (    $mode eq 'packages_in_set'
      and $self->listview->set_label eq 'package_answer_file_list') {
    my $id_combo = $row->{ID};
    my ($name_id, $evr_id) = split(/\|/, $id_combo);

    my $sid = $pxt->param('sid');
    my $cid = $pxt->param('cid');

    my $pid = RHN::Package->guestimate_package_id(-server_id => $sid,
						  -channel_id => $cid,
						  -name_id => $name_id, -evr_id => $evr_id);

    return 0 unless ($pid and RHN::Package->package_type_capable($pid, 'deploy_answer_file'));
  }
  elsif ($mode eq 'system_package_list') {
    my $id_combo = $row->{ID};
    my ($name_id, $evr_id) = split(/\|/, $id_combo);

    my $pid = RHN::Package->guestimate_package_id(-server_id => $pxt->param('sid'),
						  -name_id => $name_id, -evr_id => $evr_id);

    return 1 unless $pid;
    return 0 unless (RHN::Package->package_type_capable($pid, 'remove'));
  }

  return 1;
}

# clean the set after all_ids are inserted
sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  my $mode = $self->datasource->mode();

  if (    $mode eq 'packages_in_set'
      and $set->label eq 'package_answer_file_list') {

    foreach my $id_combo ($set->contents) {
      my ($name_id, $evr_id) = @{$id_combo};

      my $pid = RHN::Package->guestimate_package_id(-server_id => $formvars->{sid},
						    -channel_id => $formvars->{cid},
						    -name_id => $name_id, -evr_id => $evr_id);

      next unless ($pid);

      $set->remove($id_combo) unless (RHN::Package->package_type_capable($pid, 'deploy_answer_file'));
    }
    $set->commit;
  }
  elsif ($mode eq 'system_package_list') {

    foreach my $id_combo ($set->contents) {
      my ($name_id, $evr_id) = @{$id_combo};

      my $pid = RHN::Package->guestimate_package_id(-server_id => $formvars->{sid},
						    -name_id => $name_id, -evr_id => $evr_id);

      next unless ($pid);

      $set->remove($id_combo) unless (RHN::Package->package_type_capable($pid, 'remove'));
    }
    $set->commit;
  }

  return;
}

1;
