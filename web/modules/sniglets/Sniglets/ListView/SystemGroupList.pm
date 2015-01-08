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

    $row->{MONITORING_ICON} = PXT::HTML->link("/rhn/groups/ProbesList.do?sgid=" . $row->{ID}, $image);
  }

  my $use_group_btn = PXT::HTML->link(sprintf("/rhn/systems/WorkWithGroup.do?sgid=%d", $row->{ID}),
                                                  '<img src="/img/button-use_group.gif" border="0" valign="middle" alt="Work with '
                                                  .$row->{GROUP_NAME}.' Group" title="Work with '
                                                  .$row->{GROUP_NAME}.' Group" />');

  $row->{WORK_WITH_GROUP}  = ' &#160;' . $use_group_btn;

  return $row;
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
