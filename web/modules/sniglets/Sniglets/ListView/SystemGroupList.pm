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

package Sniglets::ListView::SystemGroupList;

use Sniglets::ListView::List;
use Sniglets::ServerGroup;
use RHN::DataSource::SystemGroup;
use RHN::ServerGroup;

use Data::Dumper;

use PXT::HTML;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:system_group_list_cb";
}

sub list_of { return "system groups" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "visible_to_user",
			   -datasource => RHN::DataSource::SystemGroup->new,
			   -action_callback => \&work_with_groups_cb);

  Sniglets::ListView::List->add_mode(-mode => "visible_groups_summary",
			   -datasource => RHN::DataSource::SystemGroup->new,
			   -provider => \&visible_groups_summary_provider,
			   -action_callback => \&work_with_groups_cb);

  Sniglets::ListView::List->add_mode(-mode => "comparison_to_snapshot",
			   -datasource => RHN::DataSource::SystemGroup->new,
			   -provider => \&comparison_to_snapshot_provider);

  Sniglets::ListView::List->add_mode(-mode => "user_permissions",
			   -datasource => RHN::DataSource::SystemGroup->new,
			   -provider => \&group_permissions_provider,
			   -action_callback => \&group_permissions_cb);

  Sniglets::ListView::List->add_mode(-mode => "ssm_group_membership_select",
	  	            -datasource => RHN::DataSource::SystemGroup->new,
			    -provider => \&ssm_group_membership_provider,
			    -action_callback => \&ssm_group_membership_cb);
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if ( exists $row->{SECURITY_ERRATA} ) {
    $row->{TOTAL_ERRATA} = $row->{SECURITY_ERRATA} + $row->{BUG_ERRATA} + $row->{ENHANCEMENT_ERRATA};
  }

  if ($row->{uc'security_errata'}) {
    $row->{STATUS_ICON} = '<img src="/img/icon_crit_update.gif" border="0" alt="Security Updates Needed" title="Security Updates Needed" />';
  }
  elsif ($row->{uc'bug_errata'} or $row->{uc'enhancement_errata'}) {
    $row->{STATUS_ICON} = '<img src="/img/icon_reg_update.gif" border="0" alt="Errata Updates Available" title="Errata Updates Available" />';
  }

  $row->{STATUS_ICON} = '<img src="/img/icon_up2date.gif" border="0" alt="No Applicable Errata" title="No Applicable Errata" />' if (!$row->{STATUS_ICON});

  $row->{MONITORING_ICON} = '';
  if (defined $row->{MONITORING_STATUS}) {
    my $icon_data = Sniglets::Servers::system_monitoring_info($pxt->user, $row);
            
    my $image = PXT::HTML->img(-src => $icon_data->{image},
                               -alt => $icon_data->{status_str},
                               -title => $icon_data->{status_str},
                               -border => 0);

    $row->{MONITORING_ICON} = PXT::HTML->link("/network/systems/groups/probe_list.pxt?sgid=" . $row->{ID}, $image);
  }

  my $use_group_btn = PXT::HTML->link(sprintf("/network/systems/ssm/work_with_group.pxt?sgid=%d&amp;pxt_trap=rhn:work_with_group_cb", $row->{ID}),
						  '<img src="/img/button-use_group.gif" border="0" valign="middle" alt="Work with '
						  .$row->{GROUP_NAME}.' Group" title="Work with '
						  .$row->{GROUP_NAME}.' Group" />');

  $row->{WORK_WITH_GROUP}  = ' &#160;' . $use_group_btn;

  return $row;
}


sub comparison_to_snapshot_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params;
  $ds->mode('system_snapshot_group_list');
  %params = $self->lookup_params($pxt, $ds->required_params);

  my $snapshot_groups = $ds->execute_query(%params);
  $snapshot_groups = $ds->elaborate($snapshot_groups, %params);

  my $current_ds = new RHN::DataSource::SystemGroup;

  $current_ds->mode('groups_a_system_is_in');
  %params = $self->lookup_params($pxt, $current_ds->required_params);

  my $current_groups = $current_ds->execute_query(%params);
  $current_groups = $current_ds->elaborate($current_groups, %params);

  # group names are unique within an org.
  my %all_groups;

  foreach my $snapshot_group (@{$snapshot_groups}) {
    # gotta filter out non-normal group types...
    next if defined $snapshot_group->{GROUP_TYPE_LABEL};

    my $permitted_access = ($pxt->user->is('org_admin') or $snapshot_group->{USER_PERMITTED_ACCESS});

    $all_groups{$snapshot_group->{GROUP_NAME}}->{ID} = $snapshot_group->{ID};
    $all_groups{$snapshot_group->{GROUP_NAME}}->{PERMITTED_ACCESS} = $permitted_access;
    $all_groups{$snapshot_group->{GROUP_NAME}}->{IN_SNAPSHOT} = 1;
  }

  foreach my $current_group (@{$current_groups}) {
    # gotta filter out non-normal group types...
    next if defined $current_group->{GROUP_TYPE_LABEL};

    my $permitted_access = ($pxt->user->is('org_admin') or $current_group->{USER_PERMITTED_ACCESS});

    $all_groups{$current_group->{GROUP_NAME}}->{ID} = $current_group->{ID};
    $all_groups{$current_group->{GROUP_NAME}}->{PERMITTED_ACCESS} = $permitted_access,
    $all_groups{$current_group->{GROUP_NAME}}->{CURRENTLY_SUBSCRIBED} = 1;
  }

  my $delta = [];
  my $some_delta;

  foreach my $group_name (sort {uc $a cmp uc $b} keys %all_groups) {

    my $group = $all_groups{$group_name};
    my $url = PXT::HTML->link('/network/systems/groups/details.pxt?sgid=' . $group->{ID},
			      $group_name,
			     );

    my $comparison;

    if ($group->{IN_SNAPSHOT}) {

      if ($group->{CURRENTLY_SUBSCRIBED}) {
	$comparison = 'Both Current and Snapshot';
      }
      else {
	$some_delta = 1;
	$comparison = 'Snapshot Profile Only';
      }
    }
    else {
      $some_delta = 1;
      $comparison = 'Current Profile Only';
    }


    push @{$delta}, { ID => $group->{ID},
		      GROUP_NAME => $group->{PERMITTED_ACCESS} ? $url: $group_name,
		      COMPARISON => $comparison,
		    };
  }

  $delta = [] unless $some_delta;

  my $alphabar = $self->init_alphabar($delta);
  my $on_page = $self->filter_data($delta);

  my @all_ids = map { $_->{ID} } @{$on_page};
  $self->all_ids(\@all_ids);
  $on_page = $current_ds->slice_data($on_page, $self->lower, $self->upper);


  return (data => $on_page,
	  all_ids => \@all_ids,
	  alphabar => $alphabar,
	  full_data => $delta);
}

sub visible_groups_summary_provider {
  my $self = shift;
  my $pxt = shift;

  $self->lower(1);
  $self->upper(10);

  my %ret = $self->default_provider($pxt);

  my $summary = '';

  if (scalar(@{$ret{all_ids}})) {
    $summary = {system_groups_shown => scalar(@{$ret{data}}) || '0',
                system_groups_total => scalar(@{$ret{all_ids}}) || '0'
               };
  }

  $pxt->pnotes('system_group_list_summary', $summary);

  return (%ret);
}

sub group_permissions_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  my $user = RHN::User->lookup(-id => $pxt->param('uid'));

  foreach my $row (@{$ret{data}}) {

    if ($user->is('org_admin')) {
      $row->{GROUP_PERMISSION_CHECKBOX} = '[&#160;Admin&#160;Access&#160;]';
    }
    else {
      $row->{GROUP_PERMISSION_CHECKBOX} =
	PXT::HTML->checkbox(-name => 'group_' . $row->{ID} . '_permission',
			    -value => 1,
			    -checked => $row->{HAS_PERMISSION});

      $row->{GROUP_PERMISSION_CHECKBOX} .=
	PXT::HTML->hidden(-name => "sgid", -value => $row->{ID});
    }
  }

  return (%ret);
}

sub group_permissions_cb {
  my $self = shift;
  my $pxt = shift;

  # think big red button
  my %action = @_;

  PXT::Debug->log(7, "list action:  " . Data::Dumper->Dump([(\%action)]));

  return 1 unless exists $action{label};


  if ($action{label} eq 'update_system_group_permissions') {

    PXT::Debug->log(7, "updating system group permissions");

    my $uid = $pxt->param('uid');
    my $user = RHN::User->lookup(-id => $uid);

    die "no user" unless $pxt->user and $user;

    if ($pxt->user->org_id != $user->org_id) {
      Carp::cluck "Orgs for admin user edit mistatch (admin: @{[$pxt->user->org_id]} != @{[$user->org_id]}";
      $pxt->redirect("/errors/permission.pxt");
    }

    if (not $pxt->user->is('org_admin')) {
      Carp::cluck "Non-orgadmin attempting to edit sgroup permissions";
      $pxt->redirect("/errors/permission.pxt");
    }

    foreach my $sgid ($pxt->param('sgid')) {

      PXT::Debug->log(7, "dealing with group $sgid");

      if ($pxt->dirty_param("group_${sgid}_permission")) {
	PXT::Debug->log(7, "granting access to group $sgid");
	$user->grant_servergroup_permission($sgid);
      }
      else {
	PXT::Debug->log(7, "revoking access to group $sgid");
	$user->revoke_servergroup_permission($sgid);
      }
    }

    $pxt->push_message(site_info => "Permissions Updated");
  }

  return 1;
}


sub ssm_group_membership_provider {
  my $self = shift;
  my $pxt = shift;

  $self->lower(1);
  $self->upper(10000);

  my %ret = $self->default_provider($pxt);
  my @formvars;

  foreach my $row (@{$ret{data}}) {
    $row->{ADD_TO_GROUP_RADIO} =
      PXT::HTML->radio_button(-name => $row->{ID} . '|' . $row->{GROUP_NAME},
			      -value => 'add',
			      -checked => 0);

    $row->{REMOVE_FROM_GROUP_RADIO} =
      PXT::HTML->radio_button(-name => $row->{ID} . '|' . $row->{GROUP_NAME},
			      -value => 'remove',
			      -checked => 0);

    $row->{NO_CHANGE_RADIO} =
      PXT::HTML->radio_button(-name => $row->{ID} . '|' . $row->{GROUP_NAME},
			      -value => 'nochange',
			      -checked => 1);

    $row->{NO_CHANGE_RADIO} .=
      PXT::HTML->hidden(-name => "sgid", -value => $row->{ID});
  }

  $self->upper(scalar @{$ret{data}});

  return (%ret);
}

sub ssm_group_membership_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'ssm_alter_group_membership') {
    Sniglets::ServerGroup::alter_system_group_membership_cb($pxt);
  }

  return 1;
}

sub work_with_groups_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  my $set_name = $pxt->dirty_param('set_name') || 'system_group_select';
  my $set = RHN::Set->lookup(-label => $set_name, -uid => $pxt->user->id);

  if (exists $action{label}) {
    $label = $action{label};
  }

  my @groups = $set->contents;

  if ($label eq 'intersect_and_load') {
    RHN::ServerGroup->intersect_groups($pxt->user->id, 0, @groups);
  }
  elsif ($label eq 'union_and_load') {
    RHN::ServerGroup->union_groups($pxt->user->id, 0, @groups);
  }

  return 1;
}


# override from List.pm
sub render_url {
  my $self = shift;

  my $rendered_url = $self->SUPER::render_url(@_);

  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  if ($url_column eq 'GROUP_NAME' && exists $row->{USER_PERMITTED_ACCESS}) {
    return $row->{$url_column}
      unless $row->{USER_PERMITTED_ACCESS} || $pxt->user->is('org_admin');
  }

  return $rendered_url;
}

1;
