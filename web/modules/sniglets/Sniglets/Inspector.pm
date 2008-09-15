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

package Sniglets::Inspector;
use strict;

use RHN::User;
use Sniglets::Servers;
use Sniglets::Users;
use RHN::Exception;
use RHN::DB::Inspector;
use RHN::TaskMaster;
use RHN::Server;
use RHN::Utils;
use PXT::Utils;
use RHN::Org;
use RHN::EmailAddress;

use RHN::Form::Widget::Submit;

use POSIX qw/strftime/;

my $MAX_DIGIT_LENGTH = 15;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('inspector-user-disable-toggle-button' => \&disable_toggle_button);

  $pxt->register_tag('inspector-org-details' => \&org_details);

  $pxt->register_tag('inspector-server-history-event-details' => \&server_history_event_details);
  $pxt->register_tag('inspector-system-details' => \&system_details);

  $pxt->register_tag('inspector-user-details' => \&user_details);
  $pxt->register_tag('inspector-user-site-details' => \&user_site_details);
  $pxt->register_tag('inspector-email-state-details' => \&email_state_details);

  $pxt->register_tag('inspector-org-ep-entitlement-history' => \&org_ep_entitlement_history);
  $pxt->register_tag('inspector-org-sg-entitlement' => \&org_sg_entitlement);

  $pxt->register_tag('inspector-daemon-state' => \&daemon_state);
  $pxt->register_tag('inspector-reload' => \&inspector_reload, -100);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('inspector:find_org_cb' => \&find_org_cb);

  $pxt->register_callback('inspector:disable_user_toggle_cb' => \&disable_user_toggle_cb);

  $pxt->register_callback('inspector:daemon_state_cb' => \&daemon_state_cb);
}

sub disable_toggle_button {
  my $pxt = shift;

  my $s_uid = $pxt->param('support_uid');
  my $s_u = RHN::User->lookup(-id => $s_uid);

  my $next_possible_status = $s_u->is_disabled() ? 'enable' : 'disable';

  return PXT::HTML->submit(-name => $next_possible_status,
			   -value => (ucfirst($next_possible_status) . " User"),
			  );
}

sub inspector_reload {
  my $pxt = shift;
  my %params = @_;

  my $uid = $pxt->param('support_uid');
  my $org_id = $pxt->param('support_org_id');

  return if ($uid and $org_id);

  my $user = RHN::User->lookup(-id => $uid);

  $org_id = $user->org->id;
  my $redir = $pxt->uri . "?support_uid=${uid}&support_org_id=${org_id}";
  $pxt->redirect($redir);

  return;
}

sub server_history_event_details {
  my $pxt = shift;
  my %params = @_;

  my ($sid, $hid) = ($pxt->param('support_sid'), $pxt->param('support_hid'));
  throw "need server and history ids!" unless ($sid && $hid);


  my $server = RHN::Server->lookup(-id => $sid);
  my $event = RHN::Server->lookup_server_event($sid, $hid);

  return PXT::Utils->perform_substitutions($params{__block__}, $event->render($pxt->user));
}

sub org_sg_entitlement {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $org_id = $pxt->param('support_org_id');

  my $org = RHN::Org->lookup(-id => $org_id);
  die "no org" unless $org;

  my @basic_entitlement_counts = $org->entitlement_counts('sw_mgr_entitled');
  my @workgroup_entitlement_counts = $org->entitlement_counts('enterprise_entitled');
  my @provisioning_entitlement_counts = $org->entitlement_counts('provisioning_entitled');

  my %subst;

  $subst{basic_used} = $basic_entitlement_counts[0] || 0;
  $subst{basic_total} = $basic_entitlement_counts[1] || 0;
  $subst{workgroup_used} = $workgroup_entitlement_counts[0] || 0;
  $subst{workgroup_total} = $workgroup_entitlement_counts[1] || 0;
  $subst{provisioning_used} = $provisioning_entitlement_counts[0] || 0;
  $subst{provisioning_total} = $provisioning_entitlement_counts[1] || 0;

  $block = PXT::Utils->perform_substitutions($block, \%subst);

  return $block;
}

sub org_ep_entitlement_history {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $org_id = $pxt->param('support_org_id');
  my $org = RHN::Org->lookup(-id => $org_id);
  die "no org" unless $org;

  return Sniglets::Users->org_entitlement_history($org, $block);
}

sub disable_user_toggle_cb {
  my $pxt = shift;


  my $s_uid = $pxt->param('support_uid');
  die "no support user id" unless $s_uid;
  my $s_u = RHN::User->lookup(-id => $s_uid);
  die "no support user" unless $s_u;

  my $message;

  if ($pxt->dirty_param("enable")) {
    $s_u->enable_user($pxt->user->id);
    $message = "User <strong>" . $s_u->login . "</strong> enabled.";
  }
  elsif ($pxt->dirty_param("disable")){
    $s_u->disable_user($pxt->user->id);
    $message = "User <strong>" . $s_u->login . "</strong> disabled.";
  }
  else {
    warn Data::Dumper->Dump([($pxt->params)]);
  }

  $pxt->push_message(site_info => $message) if (defined $message);

  return;
}

sub find_org_cb {
  my $pxt = shift;
  my $search_type = $pxt->dirty_param('search_type');

  die "missing search type!" unless $search_type;

  my $search_str = $pxt->dirty_param('search_str');

  unless ($search_str) {
    $pxt->push_message(local_alert => 'No search string entered.');
    $pxt->redirect('/internal/support/index.pxt');
  }

  $search_str =~ s/^\s+//;
  $search_str =~ s/\s+$//;

  my $org;

  if ($search_type eq 'org_id') {
    if ($search_str =~ /\D/) {
      $pxt->push_message(local_alert => 'Non-numeric org id entered.');
      return;
    }
    elsif (my $org = RHN::Org->lookup(-id => substr($search_str, 0, $MAX_DIGIT_LENGTH))) {
      my $redir = $pxt->dirty_param('org_redirect') || '';
      throw "param org_redirect needed but not provided" unless $redir;
      $pxt->redirect($redir . '?support_org_id=' . $org->id);
    }
    else {
      $pxt->push_message(local_info => 'Org not found');
    }
  }
  elsif ($search_type eq 'org_oracle_customer_num') {
    if ($search_str =~ /\D/) {
      $pxt->push_message(local_alert => 'Non-numeric Oracle customer number entered.');
      return;
    }
    elsif (my $org = RHN::Org->lookup(-customer_number => substr($search_str, 0, $MAX_DIGIT_LENGTH))) {
      my $redir = $pxt->dirty_param('org_redirect') || '';
      throw "param org_redirect needed but not provided" unless $redir;
      $pxt->redirect($redir . '?support_org_id=' . $org->id);
    }
    else {
      $pxt->push_message(local_info => 'Org not found');
    }
  }
  elsif ($search_type eq 'user') {
    my $user = find_user($search_str);
    if ($user) {
      my $redir = $pxt->dirty_param('user_redirect') || '/internal/support/org_user.pxt';
      $pxt->redirect($redir . '?support_org_id=' . $user->org_id . '&support_uid=' . $user->id);
    }
    else {
      my $redir = $pxt->dirty_param('user_search_redirect') || '';
      throw "param user_search_redirect needed but not provided" unless $redir;
      $pxt->redirect($redir . '?search_type=user&search_str=' . PXT::Utils->escapeURI($search_str));
    }
  }
  elsif ($search_type eq 'system') {
    my $server;
    eval {
      unless ($search_str =~ m/\D/) {
	$search_str = substr($search_str, 0, $MAX_DIGIT_LENGTH);
      }
      $server = RHN::Server->lookup(-id => $search_str);
    };

    if ($@ and catchable($@)) {
      my $E = $@;

      unless ($E->is_rhn_exception('server_does_not_exist')) {
	throw $E;
      }
    }

    if (!$server) {
      my $redir = $pxt->dirty_param('system_search_redirect') || '';
      throw "param system_search_redirect needed but not provided" unless $redir;
      $pxt->redirect($redir . '?search_type=system&search_str=' . PXT::Utils->escapeURI($search_str));
    }
    else {
      my $redir = $pxt->dirty_param('system_redirect') || '';
      throw "param system_redirect needed but not provided" unless $redir;

      $pxt->redirect($redir . '?support_org_id=' . $server->org_id . '&support_sid=' . $server->id);
    }
  }
}

sub find_user {
  my $user_string = shift;

  my $user;

  # contains a non-digit? then it's a login
  if ($user_string =~ /\D/) {
    $user = RHN::User->lookup(-username => $user_string);
  }
  else {
    # joek is an evil man...
    $user_string = substr($user_string, 0, $MAX_DIGIT_LENGTH);
    $user = RHN::User->lookup(-id => $user_string);
  }

  return $user;
#  if ($user) {
#    return $user
#  }
#  else {
#    my @possible_users = RHN::DB::Inspector->find_org_by_user($user_string);
#  }
}

sub system_details {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $server = RHN::Server->lookup(-id => $pxt->param('support_sid'));
  throw "no server" unless $server;

  $pxt->pnotes(server => $server);

  my %subst;

  $subst{"server_$_"} = PXT::Utils->escapeHTML($server->$_() || '')
    foreach qw/id digital_server_id cpu_arch_name os release name description info org_id memory_swap memory_ram cpu_bogomips cpu_family cpu_nrcpu cpu_mhz created/;

  my $ent = $server->is_entitled || 'none';
  if ($ent eq 'none') {
    $subst{server_entitled} = 'None';
  }
  elsif ($ent eq 'sw_mgr_entitled') {
    $subst{server_entitled} = 'Update Service';
  }
  elsif ($ent eq 'enterprise_entitled') {
    $subst{server_entitled} = 'Management Service';
  }
  elsif ($ent eq 'provisioning_entitled') {
    $subst{server_entitled} = 'Provisioning Service';
  }

  $subst{server_last_checkin} = $server->checkin() || '';

  my @channels = $server->server_channel_tree;

  # filter out unsubscribed child channels of this server's base channel
  my @subscribed_child_channels;
  foreach my $child_channel (@{$channels[2]}) {
    push @subscribed_child_channels, $child_channel if ($child_channel->[2] eq 1);
  }
  $channels[2] = \@subscribed_child_channels;

  my $channels;
  if (@channels) {
    $channels = "<a href=\"/network/software/channels/details.pxt?cid=$channels[0]\">$channels[1]</a><br />\n";

    if (@{$channels[2]}) {
      foreach my $i (0..$#{$channels[2]}) {
	my $max = '&#160;';

	if (defined $channels[2]->[$i]->[3] and defined $channels[2]->[$i]->[4]) {
	  my $total = $channels[2]->[$i]->[4] + $channels[2]->[$i]->[3];
	  $max = " ($channels[2]->[$i]->[3] of $total subscriptions used)";
	}

	$channels .= '<img src="/img/branch.gif" />' . "<a href=\"/network/software/channels/details.pxt?cid=$channels[2]->[$i]->[0]\">$channels[2]->[$i]->[1]</a>$max<br />\n";
      }
    }
    $channels .= "\n";
  }

  $channels ||= '(no channels)';
  $subst{channel_list} = $channels;

  my @rhn_packages = $server->rhn_packages;
  $subst{server_rhn_packages} = join("<br \/>\n", map { $_->[0] } @rhn_packages);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub user_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $uid = $pxt->param('support_uid');

  my $user = RHN::User->lookup(-id => $uid);

  if (not $user) {
    if ($pxt->dirty_param('login_or_id')) {
      return "No user found.";
    }
    else {
      return "Enter the user's login or id above.";
    }
  }

  my %subst;

  $subst{"user_$_"} = $user->$_() || ''
    foreach qw/id first_names last_name login email company title org_id last_logged_in/;

  $subst{"user_$_"} = '*' x 24
    foreach qw/passwd passwd_confirm/;

  my @role_labels;
  @role_labels = $user->role_labels;

  $subst{user_type} = @role_labels ? join(", ", @role_labels) : '(none)';
  $subst{org_name} = $user->org->name;

  PXT::Utils->escapeHTML_multi(\%subst);

  $subst{user_group_selectbox} = Sniglets::Users::group_checkboxes("user_groups", $user);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub user_site_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $uid = $pxt->param('support_uid');

  my $user = RHN::User->lookup(-id => $uid);
  my $ret;

  foreach my $site (sort { $a->site_type cmp $b->site_type } $user->sites) {
    next unless ($site && $site->isa('RHN::DB::UserSite'));

    my %subst;
    $subst{$_} = $site->$_() || ''
      foreach qw/site_address1 site_address2 site_address3 site_city site_state site_zip site_fax site_phone site_country site_id site_type/;

    PXT::Utils->escapeHTML_multi(\%subst);

    $ret .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  return $ret;
}

my $pump_states = [
		   { label => 'Now',
		     value => 0 },
		   { label => '5 Minutes hence',
		     value => 5 },
		   { label => '1 Hour hence',
		     value => 60 },
		   { label => '1 Day hence',
		     value => 1440 },
		   { label => '1 Week hence',
		     value => 10080 },
		   { label => '1 Month hence',
		     value => 40320 },
		  ];

sub email_state_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $uid = $pxt->param('support_uid');

  my $user = RHN::User->lookup(-id => $uid);

  my @addresses = $user->email_addresses;

  my $ret;

  my $email_address_states = RHN::EmailAddress->email_address_states;

  foreach my $address (@addresses) {
    my $subst = { };

    $subst->{email_address} = $address->address || '';
    $subst->{email_id} = $address->id || '';
    $subst->{email_next_action} = $address->next_action || '(none scheduled)';
    $subst->{send_verify_message} = '';
    $subst->{verify_address} = '';

    PXT::Utils->escapeHTML_multi($subst);

    $subst->{delete_email} = PXT::HTML->submit(-name => 'delete_email_' . $address->id,
					       -value => 'Delete Address');

    if (grep { $address->state eq $_ } qw/unverified pending pending_warned needs_verifying/) {
      $subst->{send_verify_message} = PXT::HTML->submit(-name => 'email_request_verification_' . $address->id,
							-value => 'Send Verification E-Mail');
      $subst->{verify_address} = PXT::HTML->submit(-name => 'email_verify_' . $address->id,
						   -value => 'Verify Address');
      $subst->{email_state} = 'unverified'
    }
    else {
      $subst->{email_state} = 'verified'
    }
	

    if ($address->next_action) {
      $subst->{email_next_action_select} =
	PXT::HTML->select(-name => 'email_next_action_' . $address->id,
			  -size => 1,
			  -options => [ map { [ $_->{label}, $_->{value},
						defined $_->{value} eq 'NO_CHANGE' ] }
					( { label => $address->next_action || '(none scheduled)',
					    value => 'NO_CHANGE' }, @{$pump_states} ) ] );

    $subst->{email_next_action_select} .=
      PXT::HTML->submit(-name => 'Go',
			-value => 'Go');
    }
    else {
      $subst->{email_next_action_select} = '(none scheduled)';
    }

    $ret .= PXT::Utils->perform_substitutions($block, $subst);
  }

  unless ($ret) {
    $ret = PXT::HTML->submit(-name => 'generate_email',
			     -value => 'Generate From User Site Data');
  }

  return $ret;
}

sub org_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $org_id = $pxt->param('support_org_id');
  my $org = RHN::Org->lookup(-id => $org_id);

  my %subst;

  $subst{"org_$_"} = $org->$_() || ''
    foreach qw/id name password oracle_customer_id oracle_customer_number customer_type created modified/;

  $subst{org_paying_customer} = $org->is_paying_customer ? 'Yes' : 'No';

  PXT::Utils->escapeHTML_multi(\%subst);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub daemon_state {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $daemon_states = RHN::Task->get_daemon_states;

  my $subst = {};

  $subst->{$_} = $daemon_states->{$_} || '(no data)'
    foreach (qw/entitlement_run_me last_task_completed email_engine
                errata_engine errata_queue pushed_users
                summary_reaper session_cleanup
                summary_populator rhnproc clean_current_alerts
                synch_probe_state/
            );

  $subst->{current_db_time} = RHN::Date->now->long_date;

  PXT::Utils->escapeHTML_multi($subst);

  my $update_ec_button = new RHN::Form::Widget::Submit(name => 'update_erratacache_now',
						       label => 'Update Now');

  $subst->{update_erratacache_button} = $update_ec_button->render;

  return PXT::Utils->perform_substitutions($block, $subst);
}

sub daemon_state_cb {
  my $pxt = shift;

  my $update_erratacache = $pxt->dirty_param('update_erratacache_now');

  if ($update_erratacache) {
    my @sids = map { $_->[0] } RHN::Org->servers_in_org($pxt->user->org_id, qw/ID/);

    foreach my $sid (@sids) {
      RHN::Server->schedule_errata_cache_update($pxt->user->org_id, $sid);
    }
  }

  return;
}

sub send_user_deleted_notice {
  my $pxt = shift;
  my $user = shift;

  my $letter = new RHN::Postal;
  $letter->template('internal/user_deleted_notice.xml');

  $letter->set_tag('org_id' => $user->org_id);
  $letter->set_tag('user_id' => $user->id);
  $letter->set_tag('user_login' => $user->login);

  $letter->set_tag('support_user_login' => $pxt->user->login);
  $letter->render;
  my $mail = PXT::Config->get('traceback_mail');
  $letter->to($mail);
  $letter->wrap_body;
  $letter->send;

  return;
}

1;
