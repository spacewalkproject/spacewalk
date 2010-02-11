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

package Sniglets::ListView::UserList;

use Sniglets::ListView::List;
use RHN::DataSource::User;

use RHN::Exception qw/throw/;
use RHN::Utils;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:user_list_cb";
}

sub list_of { return "users" }

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "feedback_user_list",
				     -datasource => RHN::DataSource::User->new);

  Sniglets::ListView::List->add_mode(-mode => "group_admins",
				     -datasource => RHN::DataSource::User->new,
				     -provider => \&group_admin_provider,
				     -action_callback => \&group_admin_cb);

  Sniglets::ListView::List->add_mode(-mode => "users_in_org",
				     -datasource => RHN::DataSource::User->new);

  Sniglets::ListView::List->add_mode(-mode => "support_users_in_org",
				     -datasource => RHN::DataSource::User->new);

  Sniglets::ListView::List->add_mode(-mode => "support_find_user",
				     -datasource => RHN::DataSource::User->new,
				     -provider => \&support_find_user_provider);

  Sniglets::ListView::List->add_mode(-mode => "channel_subscribers",
				     -datasource => RHN::DataSource::User->new,
				     -provider => \&channel_subscribers_provider,
				     -action_callback => \&channel_subscribers_cb);

  Sniglets::ListView::List->add_mode(-mode => "channel_managers",
				     -datasource => RHN::DataSource::User->new,
				     -provider => \&channel_managers_provider,
				     -action_callback => \&channel_managers_cb);
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if (exists $row->{ROLE_NAMES}) {
    $row->{ROLE_NAMES} =~ s{,\s}{<br />\n}gism;
  }

  if (exists $row->{USER_FIRST_NAME} and exists $row->{USER_LAST_NAME}) {
    $row->{FULL_NAME} = $row->{USER_LAST_NAME} . ", " . $row->{USER_FIRST_NAME};
  }

  if (exists $row->{LAST_LOGGED_IN} and $row->{LAST_LOGGED_IN}) {
    $row->{LAST_LOGGED_IN} = $pxt->user->convert_time($row->{LAST_LOGGED_IN}, "%F %r %Z");
  }
  
  if (exists $row->{ID}) { #See if user is disabled and add it to the row info
    my $user = RHN::User->lookup(-id => $row->{ID});
    #Mark user either disabled or active
    $row->{DISABLED} = "Active";    
    if ($user->is_disabled()) {
      $row->{DISABLED} = "Disabled";
    }
  }

  return $row;
}

sub support_find_user_provider {
  my $self = shift;
  my $pxt = shift;

  my $search_str = $pxt->dirty_param('search_str') || '';

  return unless $search_str;

  $search_str = $search_str . '%';

  my %ret = $self->default_provider($pxt, -search_str => $search_str);

  return %ret;
}

sub group_admin_provider {
  my $self = shift;
  my $pxt = shift;

  die "user not system group admin!" unless $pxt->user->is('system_group_admin');

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {

    my $user = RHN::User->lookup(-id => $row->{ID});

    # mark special if the user is an org admin or an sga of the
    # system group
    if ($user->is('org_admin')) {
      $row->{GROUP_ADMIN_CHECKBOX} = '[&#160;Admin&#160;Access&#160;]';
    }
    else {
      my $star = '&#160;';
      if ($user->is('system_group_admin')) {
          $star = '*';
      }
      $row->{GROUP_ADMIN_CHECKBOX} =
	PXT::HTML->checkbox(-name => 'user_' . $row->{ID} . '_is_admin',
			    -value => 1,
			    -checked => $row->{IS_ADMIN});
      $row->{GROUP_ADMIN_CHECKBOX} .= $star;
    }

    $row->{GROUP_ADMIN_CHECKBOX} .=
      PXT::HTML->hidden(-name => "sguid", -value => $row->{ID});
  }

  return (%ret);
}

sub group_admin_cb {
  my $self = shift;
  my $pxt = shift;

  die "user not system group admin!" unless $pxt->user->is('system_group_admin');

  my $sgid = $pxt->param('sgid');

  die "No server group id ($sgid)" unless $sgid;

  my @uids =  $pxt->param('sguid');

  my $redirect;

  foreach my $uid (@uids) {

    if ($pxt->dirty_param("user_${uid}_is_admin")) {
      RHN::User->grant_servergroup_permission($uid, $sgid);
    }
    else {
      #If we are removing admin status from ourself, make sure we redirect
      #to the system group overview page instead.
      if ($uid == $pxt->user->id and not $pxt->user->is('org_admin')) {
        $redirect = '/rhn/systems/SystemGroupList.do?message=systemgroups.admins.updated';
      }
      RHN::User->revoke_servergroup_permission($uid, $sgid);
    }
  }

  my $group = RHN::ServerGroup->lookup(-id => $sgid);

  if ($redirect) {
    $redirect .= sprintf("&messageParam=%s", PXT::Utils->escapeHTML($group->name));
    $pxt->redirect($redirect);
  }

  $pxt->push_message(site_info => sprintf("Admin list for system group <strong>%s</strong> updated.", PXT::Utils->escapeHTML($group->name)));
  return 1;
}

sub channel_subscribers_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  populate_users_with_channel_role(-user => $pxt->user, -cid => $cid, -set_label => 'channel_subscription_perms', -role => 'subscribe');

  $self->datasource->mode('user_details');

  my %ret = $self->default_provider($pxt);

  return %ret;
}

sub channel_managers_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  populate_users_with_channel_role(-user => $pxt->user, -cid => $cid, -set_label => 'channel_management_perms', -role => 'manage');

  $self->datasource->mode('user_details');

  my %ret = $self->default_provider($pxt);

  return %ret;
}

# for channel_subscribers and channel_managers modes - populate the selected items set with users of that role
sub populate_users_with_channel_role {
  my %attr = validate(@_, { user => 1, cid => 1, set_label => 1, role => 1 });

  unless ($attr{user}->verify_channel_admin($attr{cid}) or $attr{user}->is('channel_admin') or $attr{user}->is('org_admin')) {
    throw "User '" . $attr{user}->id . "' has no permissions to modify channel $attr{role} prefs for '$attr{cid}'\n";
  }

  my @blessed_users = $attr{user}->org->users_in_org_with_channel_role(-cid => $attr{cid}, -role => $attr{role});

  my $set = RHN::Set->lookup(-label => $attr{set_label}, -uid => $attr{user}->id);

  $set->empty;
  $set->add(@blessed_users);
  $set->commit;

  return;
}

sub channel_subscribers_cb {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  my $changed = update_channel_roles(-user => $pxt->user, -cid => $cid, -set_label => 'channel_subscription_perms', -role => 'subscribe');

  if ($changed) {
    $pxt->push_message(site_info => 'Channel subscription permissions updated.');
  }

  return 1;
}

sub channel_managers_cb {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  my $changed = update_channel_roles(-user => $pxt->user, -cid => $cid, -set_label => 'channel_management_perms', -role => 'manage');

  if ($changed) {
    $pxt->push_message(site_info => 'Channel management permissions updated.');
  }

  return 1;
}

sub update_channel_roles {
  my %attr = validate(@_, { user => 1, cid => 1, set_label => 1, role => 1 });

  my $cid = $attr{cid};
  my $user = $attr{user};

  unless ($user->verify_channel_admin($cid) or $user->is('channel_admin') or $user->is('org_admin')) {
    throw "User '" . $user->id . "' attempted to modify channel prefs for '$cid'\n";
  }

  my @blessed_users = $user->org->users_in_org_with_channel_role(-cid => $cid, -role => $attr{role});
 
  my $set = RHN::Set->lookup(-label => $attr{set_label}, -uid => $user->id);
  my @new_users = $set->contents;

  my @remove_users;
  my %seen = ();
  @seen{@new_users} = (); #lookup table

  # determine blessed users who are not new users and remove manage role 
  for $item (@blessed_users) { push ( @remove_users, $item ) unless exists $seen{$item}; }
  $user->org->remove_channel_permissions(-uids => \@remove_users, -cid => $cid, -role => $attr{role});
 
  # reset new users role that are selected
  $user->org->reset_channel_permissions(-uids => \@new_users, -cid => $cid, -role => $attr{role});

  $set->empty;
  $set->commit;

  return (RHN::Utils::sets_differ(\@blessed_users, \@new_users) ? 1 : 0);
}

sub render_checkbox {
  my $self = shift;
  my %params = validate(@_, { row => 1, checked => 1, blank => 0, pxt => 1 });

  if ($params{blank}) {
    my $checkbox = '[&#160;Admin&#160;Access&#160;]';

    my $checkbox_template = $self->style->checkbox();
    $checkbox_template =~ s/\{checkbox\}/$checkbox/;
    return $checkbox_template;
  }
  else {
    return $self->SUPER::render_checkbox(%params);
  }

}

sub is_row_selectable {
  my $self = shift;
  my $pxt = shift;
  my $row = shift;

  my $mode = $self->datasource->mode();

  if ($mode eq 'user_details') {
    my $user = RHN::User->lookup(-id => $row->{ID});
    my $cid = $pxt->param('cid');

    if ($user->is('channel_admin') or $user->is('org_admin')) {
      return 0;
    }
    else {
      return 1;
    }
  }
}

sub empty_set_action_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  my $mode = $self->datasource->mode();

  if ($mode eq 'channel_subscribers' or $mode eq 'channel_managers') {
    return %action;
  }

  return $self->SUPER::empty_set_action_cb($pxt, %action);
}

#override to clean a set after all_ids are inserted
sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  my $mode = $self->datasource->mode();

  if ($mode eq 'user_details') {
    $set->remove_users_with_role('channel_admin');
    $set->remove_users_with_role('org_admin');
  }

  return;
}

1;
