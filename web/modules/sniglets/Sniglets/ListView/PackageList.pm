#
# Copyright (c) 2008--2014 Red Hat, Inc.
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
use RHN::ErrataTmp;
use RHN::DataSource::Package;
use RHN::DataSource;
use RHN::DataSource::Simple;
use PXT::HTML;
use PXT::Utils;
use RHN::Scheduler;

use RHN::Exception qw/throw/;

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

  Sniglets::ListView::List->add_mode(-mode => "in_set",
                           -datasource => RHN::DataSource::Package->new,
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
  elsif ($label eq 'package_install_remote_command') {
    return install_packages_cb($pxt, 'package_install_remote_command');
  }
  elsif ($label eq 'ssm_package_install_remote_command') {
    return ssm_install_packages_cb($pxt, 'ssm_package_install_remote_command');
  }
  elsif ($label eq 'ssm_package_install_answer_files') {
    return ssm_install_packages_cb($pxt, 'ssm_package_install_answer_files');
  }
  elsif ($label eq 'remove_patches_from_channel') {
    return remove_patches_from_channel_cb($pxt);
  }
  elsif ($label eq 'add_patches_to_channel') {
    return add_patches_to_channel_cb($pxt);
  }
  elsif ($label eq 'add_patchsets_to_channel') {
    return add_patchsets_to_channel_cb($pxt);
  }
  return 1;
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
VALUES (sequence_nextval('rhn_repo_regen_queue_id_seq'),
        :label, 'perl-web::delete_packages_cb', NULL, 'N', 'N', current_timestamp, current_timestamp, current_timestamp)
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

  my $earliest_date = RHN::Date->now_long_date;
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

  my $earliest_date = RHN::Date->now_long_date;
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

my %adv_icon = ('Bug Fix Advisory' => 'errata-bugfix',
                 'Product Enhancement Advisory' => 'errata-enhance',
                 'Security Advisory' => 'errata-security');

sub obsoleting_packages_provider {
  my $self = shift;
  my $pxt = shift;
  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $adv = $row->{ADVISORY};
    my $adv_type = $row->{ADVISORY_TYPE};
    my $adv_id = $row->{ERRATA_ID};

    $row->{RELATED_ERRATA} = defined $adv_id ? sprintf('%s<a href="/rhn/errata/details/Details.do?eid=%s">%s</a>', PXT::HTML->icon(-type => $adv_icon{$adv_type}), $adv_id, $adv) : '';
  }

  return (%ret);
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
