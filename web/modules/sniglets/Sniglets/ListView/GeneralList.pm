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

package Sniglets::ListView::GeneralList;

use Sniglets::ListView::List;
use RHN::DataSource::General;
use RHN::DataSource::Simple;
use RHN::Exception qw/throw/;
use RHN::Token;
use RHN::Kickstart;
use RHN::Kickstart::IPRange;
use RHN::Kickstart::Session;
use RHN::Utils;

use RHN::Action;

use Data::Dumper;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:general_list_cb";
}

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "system_snapshots",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "tags_for_system",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "tags_for_provisioning_entitled_in_set",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "snapshot_tags_in_set",
			   -datasource => RHN::DataSource::General->new,
			   -action_callback => \&snapshot_tags_cb);

  Sniglets::ListView::List->add_mode(-mode => "tags_for_snapshot",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "system_events_history",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&system_history_provider);

  Sniglets::ListView::List->add_mode(-mode => "events_in_set",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&system_history_provider,
			   -action_callback => \&events_in_set_cb);

  Sniglets::ListView::List->add_mode(-mode => "system_events_pending",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&system_history_provider);

  Sniglets::ListView::List->add_mode(-mode => "supported_system_history",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&system_history_provider);

  Sniglets::ListView::List->add_mode(-mode => "system_groups",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "system_notes",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&system_notes_provider);

  Sniglets::ListView::List->add_mode(-mode => "activation_keys",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&activation_key_provider,
			   -action_callback => \&activation_key_cb);

  Sniglets::ListView::List->add_mode(-mode => "template_strings",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "kickstarts_for_org",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&kickstarts_for_org_provider,
			   -action_callback => \&kickstarts_for_org_cb);

  Sniglets::ListView::List->add_mode(-mode => "kickstart_packages",
			   -datasource => RHN::DataSource::General->new,
			   -action_callback => \&kickstart_packages_cb);

  Sniglets::ListView::List->add_mode(-mode => "kickstart_sessions_for_org",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&kickstart_sessions_provider);

  Sniglets::ListView::List->add_mode(-mode => "ip_ranges_for_org",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&ip_ranges_provider);

  Sniglets::ListView::List->add_mode(-mode => "private_kstrees_for_user",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "kickstart_session_history",
			   -datasource => RHN::DataSource::General->new,
			   -provider => \&session_history_provider);

  Sniglets::ListView::List->add_mode(-mode => "packages_in_token",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "crypto_keys_for_org",
			   -datasource => new RHN::DataSource::Simple(-querybase => "General_queries"),
			   -action_callback => \&crypto_key_cb);

  Sniglets::ListView::List->add_mode(-mode => "preservations_for_org",
			   -datasource => RHN::DataSource::General->new);
}

sub system_notes_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $note (@{$ret{data}}) {

    if (defined $note->{NOTE}) {
      $note->{NOTE} = '<pre>' . $note->{NOTE} . '</pre>';
    }
  }

  return (%ret);
}

sub activation_key_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    $row->{ACTIVATION_KEY_CHECKBOX} =
      PXT::HTML->checkbox(-name => 'token_' . $row->{ID} . '_active',
			  -value => 1,
			  -checked => !($row->{DISABLED}));

    $row->{ACTIVATION_KEY_CHECKBOX} .=
      PXT::HTML->hidden(-name => "tid", -value => $row->{ID});

    if (defined $row->{USAGE_LIMIT}) {
      if ($row->{USAGE_LIMIT}) {
	$row->{KEY_USAGE} = $row->{SYSTEM_COUNT} . "/" . $row->{USAGE_LIMIT};
      }
      else {
	$row->{KEY_USAGE} = '&#160;0&#160;';
      }
    }
    else {
      $row->{KEY_USAGE} = '(unlimited)';
    }
  }

  return (%ret);
}

my @allowed_sort_columns = qw/FB.created BASIC_SLOTS ENTERPRISE_SLOTS/;

sub kickstarts_for_org_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    $row->{KICKSTART_CHECKBOX} =
      PXT::HTML->checkbox(-name => 'ks_' . $row->{ID} . '_active',
			  -value => 1,
			  -checked => ($row->{ACTIVE} eq 'Y'));

    $row->{KICKSTART_CHECKBOX} .=
      PXT::HTML->hidden(-name => "ksid", -value => $row->{ID});

      $row->{NAME_LINK} = PXT::HTML->link('/rhn/kickstart/KickstartDetailsEdit.do?ksid=' . $row->{ID}, $row->{NAME});

    if ($row->{IS_ORG_DEFAULT} eq 'Y') {
      $row->{NAME_LINK} .= ' (org default)';
    }

    my $default_kstree = RHN::KSTree->lookup(-id => $row->{KSTREE_ID});
    $row->{INSTALL_TYPE} = $default_kstree->install_type_name;
  }

  return (%ret);
}

sub kickstart_sessions_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt, -days => $pxt->dirty_param('days_of_history') || 1);

  foreach my $row (@{$ret{data}}) {

    if ( exists $row->{LAST_ACTION} ) {
      $row->{LAST_ACTION} = $pxt->user->convert_time($row->{LAST_ACTION});
    }

    unless ($row->{SYSTEM_NAME}) {
      $row->{SYSTEM_NAME} = '(New Profile)';
    }

    if (not $row->{DIST}) {
      if ($row->{KICKSTART_ID}) {
	my $ks = RHN::Kickstart->lookup(-id => $row->{KICKSTART_ID});
	$row->{DIST} = $ks->dist || '(unknown)';
      }
      else {
	$row->{DIST} = '(unknown)';
      }
    }
  }

  return (%ret);
}

sub ip_ranges_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $range = new RHN::Kickstart::IPRange(-min => $row->{MIN}, -max => $row->{MAX});

    $row->{RANGE} = sprintf('<tt>%s&#160;-&#160;%s</tt>', $range->min, $range->max);
  }

  return (%ret);
}

sub session_history_provider {
  my $self = shift;
  my $pxt = shift;

  my %extra_params;
  my $sid = $pxt->param('sid');

  if ($sid) {
    my $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -expired => 1);
    $extra_params{-kssid} = $session->id;
  }

  my %ret = $self->default_provider($pxt, %extra_params);

  foreach my $row (@{$ret{data}}) {
    if (RHN::Action->action_is_for_server($row->{ACTION_ID}, $row->{OLD_SERVER_ID})) {
      $row->{SYSTEM_ID} = $row->{OLD_SERVER_ID};
    }
    elsif (RHN::Action->action_is_for_server($row->{ACTION_ID}, $row->{NEW_SERVER_ID})) {
      $row->{SYSTEM_ID} = $row->{NEW_SERVER_ID};
    }
    else {
      $row->{SYSTEM_ID} = 0;
    }

    $row->{ACTION_DESC} = $row->{ACTION_NAME} || $row->{ACTION_TYPE} || '(none)';

    if ($row->{MESSAGE}) {
      $row->{STATE_DESCRIPTION} = $row->{MESSAGE};
    }

  }

  return (%ret);
}

sub crypto_key_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  return (%ret);
}

sub render_url {
  my $self = shift;

  my $rendered_url = $self->SUPER::render_url(@_);

  return $rendered_url unless ($self->datasource->mode() eq 'kickstart_session_history');

  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  if ($url_column eq 'ACTION_DESC') {
    if ($row->{ACTION_DESC} eq '(none)' or not $row->{SYSTEM_ID}) {
      return $row->{$url_column};
    }
  }

  return $rendered_url;
}

# runs even when paging, so we don't have to bother keeping a set of changes
sub kickstarts_for_org_cb {
  my $self = shift;
  my $pxt = shift;

  my @ksids = $pxt->param('ksid');

  foreach my $ksid (@ksids) {
    my $active = $pxt->dirty_param("ks_${ksid}_active") || 0;

    my $ks = RHN::Kickstart->lookup(-id => $ksid);
    $ks->active($active);
    $ks->commit;
  }

  return 1;
}

# bretm -- this one is working correctly, this code should happen on any button press
sub activation_key_cb {
  my $self = shift;
  my $pxt = shift;

  throw "not an org admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  foreach my $tid ($pxt->param('tid')) {
    my $disabled = !($pxt->dirty_param("token_${tid}_active")) || 0;

    my $token = RHN::Token->lookup(-id => $tid);

    throw "no token found - tid = '$tid'" unless $token;
    throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
      unless ($pxt->user->org_id == $token->org_id);

    $token->disabled($disabled);
    $token->commit;
  }

  return 1;
}

sub kickstart_packages_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  if (exists $action{label} and $action{label} eq 'remove_kickstart_packages') {
    my $set_label = $pxt->dirty_param('set_label');
    throw "No set label" unless $set_label;

    my $pnid_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
    my @pnids = $pnid_set->contents;
    $pnid_set->empty;
    $pnid_set->commit;

    my $ksid = $pxt->param('ksid');
    throw "No ks id" unless $ksid;

    my $ks = RHN::Kickstart->lookup(-id => $ksid);

    RHN::Kickstart->remove_packages_by_name_id($ksid, @pnids);

    $pxt->push_message(site_info => sprintf('Packages removed from <strong>%s</strong>', $ks->name) );
  }

  return 1;
}

sub crypto_key_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  if (exists $action{label} and $action{label} eq 'update_crypto_keys') {
    my $set_label = 'kickstart_keys';
    my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

    my $ksid = $pxt->param('ksid');
    throw "No ks id" unless $ksid;

    my $ks = RHN::Kickstart->lookup(-id => $ksid);

    my @keys_in_set = $set->contents;
    my @current_keys = map { $_->{ID} } $ks->crypto_keys;

    if (RHN::Utils::sets_differ(\@keys_in_set, \@current_keys)) {
      $ks->crypto_keys(@keys_in_set);

      $pxt->push_message(site_info => sprintf('GPG and SSL keys updated for <strong>%s</strong>.', $ks->name) );
    }
  }

  return 1;
}

sub snapshot_tags_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  if (exists $action{label} and $action{label} eq 'confirm_snapshot_tag_removal') {
    my $set_label = $pxt->dirty_param('set_label');
    throw "No set label" unless $set_label;

    my $sid = $pxt->param('sid');
    my $s = RHN::Server->lookup(-id => $sid);

    my $tag_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

    my @tags = $tag_set->contents;
    RHN::Tag->remove_tags_from_system(\@tags, $sid);

    $tag_set->empty;
    $tag_set->commit;

    $pxt->push_message(site_info => sprintf('Snapshot Tags removed from <strong>%s</strong>', $s->name) );
  }

  return 1;
}

# If an action button was pressed, and the set is empty, generally
# clear the action, and push an error onto the stack.
sub empty_set_action_cb { #overridden from ListView::List
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

# packages_owned_by_org shoud allow empty selection - channel, errata,
# and package management use this
  if ($self->mode->{__name__} eq 'crypto_keys_for_org') {
    return %action;
  }

  return $self->SUPER::empty_set_action_cb($pxt, %action);
}

1;
