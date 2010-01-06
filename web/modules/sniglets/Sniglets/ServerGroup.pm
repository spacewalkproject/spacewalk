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

package Sniglets::ServerGroup;

use RHN::Server;
use RHN::ServerGroup;
use RHN::Org;
use RHN::ServerActions;
use RHN::User;
use RHN::Exception;
use PXT::Utils;

use Carp;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-server-group-name' => \&server_group_name, 2);
  $pxt->register_tag('rhn-admin-server-group-edit-form' => \&admin_server_group_edit_form);
  $pxt->register_tag('rhn-alter-sgroup-membership-list' => \&alter_sgroup_membership_list);
  $pxt->register_tag('rhn-system-group-status-interface' => \&system_group_status_interface);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:admin_server_group_edit_cb' => \&admin_server_group_edit_cb);
  $pxt->register_callback('rhn:server_group_create_cb' => \&admin_server_group_edit_cb);
  $pxt->register_callback('rhn:server_group_delete_cb' => \&delete_server_group_cb);

  $pxt->register_callback('rhn:alter_system_group_membership_cb' => \&alter_system_group_membership_cb);

  $pxt->register_callback('rhn:work_with_group_cb' => \&work_with_group_cb );
}

sub system_group_status_interface {
  my $pxt = shift;
  my %params = @_;

  my $sgid = $pxt->param('sgid');

  my $subst = { map { $_, undef} qw/icon status_str message button/ };
  my $counts = RHN::ServerGroup->errata_counts($pxt->user->org_id, $sgid);

  PXT::Debug->log(7, "counts:  " . Data::Dumper->Dump([($counts)]));

  if (not ($counts->{SECURITY_ERRATA} or $counts->{BUG_ERRATA} or $counts->{ENHANCEMENT_ERRATA})) {

    $subst->{icon} = '<img src="/img/icon_up2date.gif" alt="up to date" />';
    $subst->{status_str} = 'No applicable errata';
    $subst->{status_class} = 'system-status-up-to-date';
  }
  elsif ($counts->{SECURITY_ERRATA}) {

    $subst->{icon} = '<img src="/img/icon_crit_update.gif" alt="critical updates available" />';
    $subst->{status_str} = $counts->{SECURITY_ERRATA} . ' critical updates available';
    $subst->{message} = "(<a href=\"/network/systems/groups/errata_list.pxt?sgid=" . $sgid . "\">more info</a>)";;
    $subst->{status_class} = 'system-status-critical-updates';
  }
  else {

    $subst->{icon} = '<img src="/img/icon_reg_update.gif" alt="updates available" />';
    $subst->{status_str} = ' updates available';
    $subst->{message} = "(<a href=\"/network/systems/groups/errata_list.pxt?sgid=" . $sgid . "\">more info</a>)";
    $subst->{status_class} = 'system-status-updates';
  }

  my $block = $params{__block__};

  $block = PXT::Utils->perform_substitutions($block, $subst);

  return $block;
}


sub server_group_name {
  my $pxt = shift;

  my $servergroupname = $pxt->pnotes('server_group_name');
  return PXT::Utils->escapeHTML($servergroupname) if (defined $servergroupname);

  my $sgid = $pxt->param('sgid');
  die "no system group id" unless $sgid;

  my $servergroup = RHN::ServerGroup->lookup(-id => $sgid);
  die "no valid servergroup " unless $servergroup;

  return PXT::Utils->escapeHTML($servergroup->name);
}

sub alter_system_group_membership_cb {
  my $pxt = shift;

  die "not org admin!" unless $pxt->user->is('org_admin');

  my @params = $pxt->param;

  my %sgroups;
  my @to_add;
  my @to_remove;

  foreach my $param (@params) {
    my ($name, $id) = split /[|]/, $param;

    next unless ($name && $id);

    # this can be dirty, because you need to be an org-admin to reach this point,
    # and the formvars are just the servergroups + whether to remove/add/ignore them
    my $value = $pxt->dirty_param($param);

    push @to_add, [ ($name, $id) ] if ($value eq 'add');
    push @to_remove, [ ($name, $id) ] if ($value eq 'remove');
  }

  $sgroups{add} = \@to_add;
  $sgroups{remove} = \@to_remove;

  $pxt->session->set(system_groups => \%sgroups);
  $pxt->pnotes(add_total => scalar @to_add);
  $pxt->pnotes(remove_total => scalar @to_remove);

  if ($pxt->dirty_param('confirm')) {
    my $system_set = new RHN::DB::Set 'system_list', $pxt->user->id;

    foreach my $group_to_add_to (@to_add) {
      RHN::ServerActions->assign_set_to_group($system_set, $group_to_add_to->[0]);
    }

    foreach my $group_to_remove_from (@to_remove) {
      RHN::ServerActions->remove_set_from_group($system_set, $group_to_remove_from->[0]);
    }


    # again, over-snapshotting.  probably need to tear apart assign_set_to_group and
    # remove_set_from_group to do this though, so postponing...
    RHN::Server->snapshot_set(-reason => "Group membership alteration",
			      -set_label => 'system_list',
			      -user_id => $pxt->user->id
			     );

    $pxt->push_message(site_info => "System group membership changed.");
    $pxt->redirect('/network/systems/ssm/groups/index.pxt');
  }
}

sub alter_sgroup_membership_list {
  my $pxt = shift;
  my %params = @_;

  my $sgroups = $pxt->session->get('system_groups');
  my $type = $params{type};
  my $block = $params{__block__};
  my $html = '';

  my $counter = 0;
  foreach my $group (@{$sgroups->{$type}}) {
    $counter++;
    my %subs;

    $subs{color} = ($counter % 2) ? "white" : "#eeeeee";
    $subs{server_group_id} = $group->[0];
    $subs{server_group_name} = $group->[1];

    PXT::Utils->escapeHTML_multi(\%subs);

    $html .= PXT::Utils->perform_substitutions($block, \%subs);

  }

  $pxt->pnotes($type . "_total" => $counter);
  $pxt->pnotes("system_group_total" => $pxt->pnotes('system_group_total') ? $pxt->pnotes('system_group_total') + $counter : $counter);

  return $html;
}

sub admin_server_group_edit_form {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $sgid = $pxt->param('sgid');
  my $group;
  $group = RHN::ServerGroup->lookup(-id => $sgid) if $sgid;

  my %subs;

  if ($sgid) {
    die "Orgs for admin servergroup edit mistatch (admin: @{[$pxt->server->org_id]} != @{[$group->org_id]}"
      unless $pxt->user->org_id == $group->org_id;
  }
  else {
    croak "No system group id provided!";
  }


  $pxt->pnotes(server_group_name => $group->name);

  $subs{$_} = defined($group->$_()) ? PXT::Utils->escapeHTML($group->$_() || '') : ''
    foreach qw/name description/;

  $subs{$_} = $group->$_() || 0
    foreach qw/id member_count/;

  $subs{admin_count} = $group->num_admins;

  if ($subs{admin_count} eq 0) {
    $subs{admin_count} = '<span class="no-details">(none)</span>';
  }
  else {
    my $plural = $subs{admin_count} > 1 ? 's' : '';
    $subs{admin_count} = $subs{admin_count} . " group administrator$plural"
  }


  $subs{max_members} = defined $group->max_members ? sprintf(" (%d maximum)", $group->max_members) : '';

  $subs{admin_server_group_formvars} = qq{<input type="hidden" name="pxt:trap" value="rhn:admin_server_group_edit_cb" \/>\n<input type="hidden" name="sgid" value="$sgid" />};

  if ($subs{member_count} eq 0) {
    $subs{systems_area} = '<span class="no-details">(none)</span>';
  }
  else {

    my $plural = $subs{member_count} > 1 ? 's' : '';
    $subs{systems_area} = PXT::HTML->link('/rhn/groups/ListRemoveSystems.do?sgid=' . $sgid,
					  $subs{member_count} . " system$plural");
    if($subs{member_count} > 1) {
      $subs{systems_area} .= <<EOH;
<p>

<input type="hidden" name="formvars" value="sgid" />
<input type="hidden" name="pxt:trap" value="rhn:system_list_cb" />
<input type="hidden" name="list_mode" value="systems_in_group" />
<input type="hidden" name="alphabar_column" value="NAME" />
<input type="hidden" name="formvars" value="alphabar_column" />
<input type="hidden" name="sgid" value = "$sgid" />
</p>
EOH
    }
  }

  $block = PXT::Utils->perform_substitutions($block, \%subs);

  return $block;
}

sub delete_server_group_cb {
  my $pxt = shift;

  my $sgid = $pxt->param('sgid');
  throw "must be system_group_admin to delete a system group..." unless $pxt->user->is('system_group_admin');

  if ($pxt->dirty_param('delete_sg_confirm')) {
    eval {
      RHN::ServerGroup->remove($sgid);
    };
    if ($@ and catchable($@)) {
      my $E = $@;

      if ($E->is_rhn_exception('sg_delete_typed')) {
	$pxt->push_message(local_alert => 'You cannot delete groups which have special functionality.');
	return;
      }
      else {
	throw $E;
      }

    }
    elsif ($@) {
      die $@;
    }

    my $redir = $pxt->dirty_param('success_redirect');
    throw "param 'success_redirect' needed but not provided." unless $redir;
    my $message = "?message=message.groupdeleted";
    $pxt->redirect($redir . $message);
  }
}

sub admin_server_group_edit_cb {
  my $pxt = shift;

  my $sgid = $pxt->param('sgid') || 0;
  my $group;

  throw "Attempt to modify or create system group '$sgid' by non-system group admin '" . $pxt->user->id . "'."
    unless $pxt->user->is('system_group_admin');

  if ($pxt->dirty_param('Delete')) {
    my $redir = $pxt->dirty_param('delete_redirect');
    throw "param 'delete_redirect' needed but not provided." unless $redir;
    $pxt->redirect($redir);
  }

  if ($sgid) { # edit
    $group = RHN::ServerGroup->lookup(-id => $sgid);
    throw "Orgs for admin servergroup edit mistatch (admin: @{[$pxt->user->org_id]} != @{[$group->org_id]}"
      unless $pxt->user->org_id == $group->org_id;
  }
  else { # create
    $group = RHN::ServerGroup->create;
    $group->org_id($pxt->user->org_id);
  }

  my $name = $pxt->dirty_param('name') || '';
  my $description = $pxt->dirty_param('description') || '';

  unless ($name && $description) {
    $pxt->push_message(local_alert => 'Both name and description are required for System Groups.');
    return;
  }

  if (length($description) > 1024) {
    $pxt->push_message(local_alert => 'Group description cannot exceed 1024 characters.');
    return;
  }

  $group->name($name);
  $group->description($description);

  eval {
    $group->commit;
  };
  if ($@ and catchable($@)) {
    my $E = $@;

    # unique constraint violation
    if ($E->constraint_value eq 'RHN_SERVERGROUP_OID_NAME_UQ') {
      $pxt->push_message(local_alert => 'That group name is already in use.  Please choose another.');
      return;
    }
    else {
      throw $E;
    }
  }
  elsif ($@) {
    die $@;
  }

  if ($pxt->dirty_param('import_ssm')) {
    my @group_id = ($group->id);
    my $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);
    my @server_ids = $system_set->contents;

    RHN::Server->add_servers_to_groups(\@server_ids, \@group_id);
    RHN::Server->snapshot_set(-reason => "Group membership change",
			      -set_label => 'system_list',
			      -user_id => $pxt->user->id);

  }

  my $escaped = PXT::Utils->escapeHTML($group->name());

  my $redir = $pxt->dirty_param('redirect_to');
  if ($sgid) { # edited
    $pxt->push_message(site_info => "System group <strong>$escaped</strong> modified.");
    if ($redir) {
      $pxt->redirect($redir);
    }
  }
  else { # created
    my $message = "?message=message.groupcreated&messagep1=$escaped";
    # make the server_group_admin the server_group_user by default
    RHN::User->grant_servergroup_permission($pxt->user->id, $group->id);
    if ($redir) {
      $pxt->redirect($redir . $message);
    }
  }

}

sub work_with_group_cb {
  my $pxt = shift;

  PXT::Debug->log(7, "working with group " . $pxt->param('sgid'));

  RHN::Set->copy_from_group($pxt->user->id, "system_list", $pxt->param('sgid'));

  $pxt->redirect("/network/systems/ssm/system_list.pxt");
}

1;
