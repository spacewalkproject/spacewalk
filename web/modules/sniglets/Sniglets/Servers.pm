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

package Sniglets::Servers;

use Carp;
use POSIX;
use File::Spec;
use Data::Dumper;
use Date::Parse;

use PXT::Utils;
use PXT::HTML;


use RHN::Server;
use RHN::ServerGroup;
use RHN::Org;
use RHN::Set;
use RHN::Utils;
use RHN::Exception;
use RHN::Channel;
use RHN::ServerActions;
use RHN::Entitlements;
use RHN::Form;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::CheckboxGroup;
use RHN::SatelliteCert;
use RHN::ConfigFile;
use RHN::Kickstart::Session;

use Sniglets::Forms;
use Sniglets::HTML;
use Sniglets::AppInstall;
use Sniglets::ServerActions;
use Sniglets::ActivationKeys;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-up2date-at-least' => \&up2date_at_least);

  $pxt->register_tag('rhn-server-prefs-conf-list' => \&server_prefs_conf_list);
  $pxt->register_tag('rhn-server-name' => \&server_name, 2);

  $pxt->register_tag('rhn-tri-state-system-pref-list' => \&tri_state_system_pref_list);

  $pxt->register_tag('rhn-server-hardware-profile' => \&server_hardware_profile);
  $pxt->register_tag('rhn-dmi-info' => \&server_dmi_info, 1);
  $pxt->register_tag('rhn-server-device' => \&server_device, 1);

  # has to run after server_details
  $pxt->register_tag('rhn-server-network-details' => \&server_network_details, 2);
  # slightly different than the rhn-server-network-details, this gives access to
  # more detailed info about the network interfaces, as opposed to just hostname/ipaddy
  $pxt->register_tag('rhn-server-network-interfaces' => \&server_network_interfaces, 2);


  $pxt->register_tag('rhn-server-history-event-details' => \&server_history_event_details);

  $pxt->register_tag('rhn-system-base-channel-select' => \&system_base_channel_select);

  $pxt->register_tag('rhn-proxy-entitlement-form' => \&proxy_entitlement_form);

  $pxt->register_tag('rhn-system-pending-actions-count' => \&system_pending_actions_count);
  $pxt->register_tag('rhn-system-activation-key-form' => \&system_activation_key_form);

  $pxt->register_tag('rhn-remote-command-form' => \&remote_command_form);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:proxy_entitlement_cb' => \&proxy_entitlement_cb);
  $pxt->register_callback('rhn:cancel_scheduled_proxy_install_cb' => \&cancel_scheduled_proxy_install);

  $pxt->register_callback('rhn:delete_server_cb' => \&delete_server_cb);
  $pxt->register_callback('rhn:reboot_server_cb' => \&reboot_server_cb);

  $pxt->register_callback('rhn:server_prefs_form_cb' => \&server_prefs_form_cb);

  $pxt->register_callback('rhn:server_hardware_list_refresh_cb' => \&server_hardware_list_refresh_cb);

  $pxt->register_callback('rhn:ssm_change_system_prefs_cb' => \&ssm_change_system_prefs_cb);

  $pxt->register_callback('rhn:delete_servers_cb' => \&delete_servers_cb);

  $pxt->register_callback('rhn:system-activation-key-cb' => \&system_activation_key_cb);

  $pxt->register_callback('rhn:server_lock_cb' => \&server_lock_cb);
  $pxt->register_callback('rhn:server_set_lock_cb' => \&server_set_lock_cb);

  $pxt->register_callback('rhn:remote-command-cb' => \&remote_command_cb);
  $pxt->register_callback('rhn:package-action-command-cb' => \&package_action_command_cb);

  $pxt->register_callback('rhn:osa-ping' => \&osa_ping_cb);
}

sub osa_ping_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');

  die "no sid" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server" unless $server;

  $server->osa_ping();

  # $pxt->push_message(site_info => "<strong>" . $server->name . "</strong> has been pinged.  OSA Status will update within the next minute.");
  $pxt->redirect('/rhn/systems/details/Overview.do?sid=' . $sid . "&message=system.osad.pinged&messagep1=" . $server->name);
}

sub system_pending_actions_count {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $sid = $pxt->param('sid');
  die 'no server id' unless $sid;

  my $count = RHN::Server->system_pending_actions_count($sid);
  my $plural;

  if ($count > 1) {
    $plural = 1;
  }
  elsif ($count eq 0) {
    return "no pending events";
  }

  return PXT::HTML->link("/network/systems/details/history/pending.pxt?sid=$sid",
			 "$count pending event" . ($plural ? 's' : ''));
}

# like rhn-require, only shows block if a server's version of up2date is >= required version
sub up2date_at_least {
  my $pxt = shift;
  my %params = @_;

  #PXT::Debug->log(4, "checking up2date version...");

  my $sid = $pxt->param('sid');
  die "no sid" unless ($sid);

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server" unless ($server);

  my $up2date_is_supported;
  eval {
    $up2date_is_supported = $server->up2date_version_at_least(epoch => $params{epoch},
							      version => $params{version},
							      release => $params{release});
  };

  if ($@ =~ /no up2date/) {
    #PXT::Debug->log(4, "no up2date on server $sid ...");
    return '';
  }

  if ($up2date_is_supported) {
    #PXT::Debug->log(4, "version is supported...");
    return $params{__block__};
  }

  return '';
}

sub proxy_entitlement_form {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  throw "User '" . $pxt->user->id . "' attempted to access proxy interface without permission."
    unless $pxt->user->org->has_channel_family_entitlement('rhn-proxy');

  my $sid = $pxt->param('sid');
  throw "no server id!" unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  my %subs;

  $subs{proxy_version_dropdown} = "";
  $subs{proxy_button} = '';

  if ($server->is_proxy()) {
    my @evr = $server->proxy_evr;
    my $version = $evr[1];

    $subs{version} = $version;

    if ($version >= 3.6) {
      my $session = Sniglets::AppInstall::find_session_in_progress(
	 $pxt,
	 -file =>'/applications/rhn-proxy/' . $version . '/install-rhn-proxy.xml',
	 -process => 'install_progress',
	);

      if ($session) {
	$pxt->redirect("/network/systems/details/proxy/install_progress.pxt?sid=$sid&version=$version");
      }
      else {
	$subs{proxy_message} = "This machine is currently a licensed RHN Proxy (v$version).";
	$subs{proxy_button} = PXT::HTML->submit(-name => 'deactivate_proxy', -value => 'Deactivate Proxy');
	$subs{proxy_button} .= PXT::HTML->submit(-name => 'configure_proxy', -value => 'Configure Proxy');
      }
    }
    else {
      $subs{proxy_message} = "This machine is currently a licensed RHN Proxy (v$version).";
      $subs{proxy_button} = PXT::HTML->submit(-name => 'deactivate_proxy', -value => 'Deactivate License');
    }

    $block = PXT::Utils->perform_substitutions($block, \%subs);
    return $block;
  }
  else {
    $server->deactivate_proxy(); # free up the channel entitlement if it is already used.
  }

  #  base requirement for proxy box
  my $base_channel_id = $server->base_channel_id();

  throw "no base channels" unless $base_channel_id;
  throw "not a proxy candidate" unless (RHN::Server->child_channel_candidates(-server_id => $sid, -channel_family_label => 'rhn-proxy'));

  my @channel_families = RHN::Channel->channel_entitlement_overview($pxt->user->org_id);
  my ($proxy_entitlement, @trash) = grep { $_->[1] eq 'Red Hat Network Proxy' } @channel_families;
  my ($current_members,  $max_members) = ($proxy_entitlement->[2], $proxy_entitlement->[3]);

  if (!$max_members or ($current_members < $max_members)) {
    # for bug 12283, we display a dropdown of proxy versions for which the 
    # appropriate channels are available. This will take into account new proxy 
    # versions as long as the proxy_chans_by_version map in RHN::DB::Channel
    # is appropriately updated (and thus RHN::Channel->proxy_channel_versions
    # subsequently returns all the available proxy versions

    my @subscribable_channels = RHN::Channel->subscribable_channels(server_id => $sid,
   								    user_id => $pxt->user->id,
								    base_channel_id => $base_channel_id);
    my @proxy_versions = RHN::Channel->proxy_channel_versions;

    my @possible_proxies;
    foreach my $proxy_ver (sort { $b <=> $a } @proxy_versions) {
        my @valid_channels = RHN::Channel->proxy_channels_by_version(version => $proxy_ver);
        foreach my $sub_chan (@subscribable_channels) {
            if (grep /$sub_chan->{LABEL}/, @valid_channels) {
                push @possible_proxies, ["RHN Proxy v$proxy_ver", $proxy_ver];
                last;
            }
        }
    }

    if (@possible_proxies) {
      $subs{proxy_message} = "You may activate this machine as an RHN Proxy. " .
                             "The following versions are available for activation.";

      $subs{proxy_version_dropdown} = 
          PXT::HTML->select(-name => "proxy_version",
                            -options => \@possible_proxies);

      $subs{proxy_button} = PXT::HTML->submit(-name => 'activate_proxy', -value => 'Activate Proxy');

    }
    else {

      $subs{proxy_message} = "The necessary channels required to activate an RHN Proxy are unavailable.";

    }
  }
  else {
    $subs{proxy_message} = 'All RHN Proxy subscriptions are currently being used.';
  }

  $block = PXT::Utils->perform_substitutions($block, \%subs);

  return $block;
}

sub proxy_entitlement_cb {
  my $pxt = shift;

  throw "User '" . $pxt->user->id . "' attempted to access proxy interface without permission."
    unless $pxt->user->org->has_channel_family_entitlement('rhn-proxy');

  my $sid = $pxt->param('sid');
  throw "no server id!" unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  my $proxy_version = $pxt->dirty_param('proxy_version') || 0;
  if ($proxy_version >= 3.6) {
    # we are installing v.3.6 or greater
    $pxt->redirect("/network/systems/details/proxy/index.pxt?sid=$sid&version=$proxy_version");
  }

  # proxy_version wasn't past in, must be doing a configure
  # let's get the version param
  if ($proxy_version == 0) {
      $proxy_version = $pxt->dirty_param('version') || 0;
  }

  if ($pxt->dirty_param('configure_proxy')) {
    $pxt->redirect("/network/systems/details/proxy/configure.pxt?sid=$sid&version=$proxy_version");
  }

  my $transaction = RHN::DB->connect();

  eval {
    # handle RHN Proxy stuff...
    if ($pxt->dirty_param('deactivate_proxy')) {

      my @evr = $server->proxy_evr;
      my $version = $evr[1];

      if ($version >= 3.6) {
	$pxt->redirect("/network/systems/details/proxy/deactivate.pxt?sid=$sid&version=$version");
      }

      $transaction = $server->deactivate_proxy($transaction);

      $pxt->push_message(site_info => sprintf("The server <strong>%s</strong> has been deactivated as an RHN Proxy (v%s).",
					      PXT::Utils->escapeHTML($server->name), $version));
    }
    elsif ($pxt->dirty_param('activate_proxy')) {

      $transaction = $server->activate_proxy(-transaction => $transaction, -version => $proxy_version);
      $pxt->push_message(site_info => sprintf("The server <strong>%s</strong> has been activated as an RHN Proxy (v%s).",
					      PXT::Utils->escapeHTML($server->name), $proxy_version));


    }
  };

  if ($@) {
    my $E = $@;
    $transaction->rollback();

    if (ref $E and catchable($E)) {

      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {

	$pxt->push_message(local_alert => "This assignment would exceed your allowed RHN Proxy subscriptions.");

	return;
      }
      else {
	throw $E;
      }
    }
    else {
      die $E;
    }
  }

  $pxt->redirect("proxy.pxt", sid => $server->id);
}

sub cancel_scheduled_proxy_install {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  throw "param 'sid' needed but not provided." unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);

  if ($server->is_proxy) {
    $server->deactivate_proxy();
    $pxt->push_message(site_info => 'RHN Proxy installation cancelled');
  }

  my $url = $pxt->uri;
  $pxt->redirect($url . "?sid=$sid");
}

sub server_hardware_list_refresh_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  my $earliest_date = RHN::Date->now->long_date;
  my $action_id = RHN::Scheduler->schedule_hardware_refresh(-org_id => $pxt->user->org_id,
							   -user_id => $pxt->user->id,
							   -earliest => $earliest_date,
							   -server_id => $sid);

  my $system = RHN::Server->lookup(-id => $sid);

  $pxt->push_message(site_info => sprintf("You have successfully scheduled a hardware profile refresh for <strong>%s</strong>.", PXT::Utils->escapeHTML($system->name)));

  return;
}

sub server_name {
  my $pxt = shift;

  my $server = $pxt->pnotes('server');
  return PXT::Utils->escapeHTML($server->name) if (defined $server);

  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  $server = RHN::Server->lookup(-id => $sid);
  die "no valid server" unless $server;

  $pxt->pnotes(server => $server);
  return PXT::Utils->escapeHTML($server->name);
}

# not a sniglet
sub system_status_info {
  my $user = shift;
  my $data = shift;

  my $sid = $data->{ID};
  my $ret;

  my $package_actions_count = RHN::Server->package_actions_count($sid);
  my $actions_count = RHN::Server->actions_count($sid);
  my $errata_count = $data->{SECURITY_ERRATA} + $data->{BUG_ERRATA} + $data->{ENHANCEMENT_ERRATA};

  $ret->{$_} = '' foreach (qw/image status_str status_class message link/);

  if (not $data->{IS_ENTITLED}) {
    $ret->{image} = '/img/icon_unentitled.gif';
    $ret->{image_medium} = '/img/icon_unentitled.gif';
    $ret->{status_str} = 'System not entitled';
    $ret->{status_class} = 'system-status-unentitled';

    if ($user->is('org_admin')) {
      if ($user->org->unused_entitlements || PXT::Config->get('satellite')) {
	$ret->{message} = 'entitle it here';
 	$ret->{link} = "/network/systems/details/edit.pxt?sid=${sid}";
      }
      else {
  	$ret->{message} = 'buy more entitlements';
  	$ret->{link} = "/rhn/account/SubscriptionManagement.do";
      }
    }
  }
  elsif ($data->{LAST_CHECKIN_DAYS_AGO} > PXT::Config->get('system_checkin_threshold')) {
    $ret->{image} = '/img/icon_checkin.gif';
    $ret->{image_medium} = '/img/icon_checkin.gif';
    $ret->{status_str} = 'System not checking in with R H N';
    $ret->{status_class} = 'system-status-awol';
    $ret->{message} = 'more info';
    $ret->{link} = Sniglets::HTML::render_help_link(-user => $user,
						    -href => 's1-sm-systems.html#S3-SM-SYSTEM-LIST-INACT');
  }
  elsif ($data->{LOCKED}) {
    $ret->{image} = '/img/icon_locked.gif';
    $ret->{image_medium} = '/img/icon_locked.gif';
    $ret->{status_str} = 'System locked';
    $ret->{status_class} = 'system-status-locked';
    $ret->{message} = 'more info';
    $ret->{link} = Sniglets::HTML::render_help_link(-user => $user,
						    -href => 's1-sm-systems.html#S3-SM-SYSTEM-DETAILS');

  }
  elsif ($data->{KICKSTART_SESSION_ID}) {
    $ret->{image} = '/img/icon_kickstart_session.gif';
    $ret->{image_medium} = '/img/icon_kickstart_session.gif';
    $ret->{status_str} = 'Kickstart in progress';
    $ret->{status_class} = 'system-status-kickstart';
    $ret->{message} = 'view progress';
    $ret->{link} = "/rhn/systems/details/kickstart/SessionStatus.do?sid=${sid}";
  }
  elsif (not ($errata_count or $data->{OUTDATED_PACKAGES}) and not $package_actions_count) {
    $ret->{image} = '/img/icon_up2date.gif';
    $ret->{image_medium} = '/img/icon_up2date.gif';
    $ret->{status_str} = 'System is up to date';
    $ret->{status_class} = 'system-status-up-to-date';
  }
  elsif ($errata_count and not RHN::Server->unscheduled_errata($sid, $user->id)) {
    $ret->{image} = '/img/icon_pending.gif';
    $ret->{image_medium} = '/img/icon_pending.gif';
    $ret->{status_str} = 'All updates scheduled';
    $ret->{status_class} = 'system-status-updates-scheduled';
    $ret->{message} = 'view actions';
    $ret->{link} = "/network/systems/details/history/pending.pxt?sid=${sid}";
  }
  elsif ($actions_count) {
    $ret->{image} = '/img/icon_pending.gif';
    $ret->{image_medium} = '/img/icon_pending.gif';
    $ret->{status_class} = 'system-status-updates-scheduled';
    $ret->{status_str} = 'Actions scheduled';
    $ret->{message} = 'view actions';
    $ret->{link} = "/network/systems/details/history/pending.pxt?sid=${sid}";
  }
  elsif ($data->{SECURITY_ERRATA}) {
    $ret->{image} = '/img/icon_crit_update.gif';
    $ret->{image_medium} = '/img/icon_crit_update.gif';
    $ret->{status_str} = 'Critical updates available';
    $ret->{status_class} = 'system-status-critical-updates';
    $ret->{message} = 'update now';
    $ret->{link} = "/rhn/systems/details/ErrataConfirm.do?all=true&amp;sid=${sid}";
  }
  elsif ($data->{OUTDATED_PACKAGES}) {
    $ret->{image} = '/img/icon_reg_update.gif';
    $ret->{image_medium} = '/img/icon_reg_update.gif';
    $ret->{status_str} = 'Updates available';
    $ret->{status_class} = 'system-status-updates';
    $ret->{message} = "more info";
    $ret->{link} = "/rhn/systems/details/packages/UpgradableList.do?sid=${sid}";
  }
  else {
    throw "logic error - system '$sid' does not have outdated packages, but is not up2date.";
  }

  return $ret;
}


sub system_monitoring_info {
  my $user = shift;
  my $data = shift;

  my $sid = $data->{ID};
  my $ret;

  $ret->{$_} = '' foreach (qw/image status_str status_class message link/);

  return $ret unless defined $data->{MONITORING_STATUS};

  if ($data->{MONITORING_STATUS} eq "CRITICAL") {
    $ret->{image} = '/img/rhn-mon-down.gif';
    $ret->{status_str} = 'Critical probes';
    $ret->{system_link} = "/network/systems/details/probes/index.pxt?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "WARNING") {
    $ret->{image} = '/img/rhn-mon-warning.gif';
    $ret->{status_str} = 'Warning probes';
    $ret->{system_link} = "/network/systems/details/probes/index.pxt?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "UNKNOWN") {
    $ret->{image} = '/img/rhn-mon-unknown.gif';
    $ret->{status_str} = 'Unknown probes';
    $ret->{system_link} = "/network/systems/details/probes/index.pxt?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "PENDING") {
    $ret->{image} = '/img/rhn-mon-pending.gif';
    $ret->{status_str} = 'Pending probes';
    $ret->{system_link} = "/network/systems/details/probes/index.pxt?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "OK") {
    $ret->{image} = '/img/rhn-mon-ok.gif';
    $ret->{status_str} = 'OK';
    $ret->{system_link} = "/network/systems/details/probes/index.pxt?sid=${sid}";
  }

  return $ret;
}

sub delete_server_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  unless ($pxt->dirty_param('brb_confirm')) {
    my $redir = $pxt->dirty_param('delete_confirm_page');
    throw "param 'delete_confirm_page' needed but not provided." unless $redir;
    $pxt->redirect($redir);
  }

  my $server = RHN::Server->lookup(-id => $sid);

  my $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);

  if ($system_set) {
    $system_set->remove($sid);
    $system_set->commit;
  }

  # bug 247457
  # remove virtualization_host if server has both virtualization_host and
  # virtualization_host_platform
  if ($server->has_entitlement('virtualization_host') and 
      $server->has_entitlement('virtualization_host_platform')) {
      warn "server has both virtualization_host and virtualization_host_platform entitlements, removing virtualization_host prior to deletion";
      $server->remove_virtualization_host_entitlement($sid);
  }

  $server->delete_server;

  my $redir = $pxt->dirty_param('delete_success_page');
  throw "param 'delete_success_page' needed but not provided." unless $redir;
  
  my $message = "?message=message.serverdeleted";
  $pxt->redirect($redir . $message);
}

sub server_history_event_details {
  my $pxt = shift;
  my %params = @_;

  croak "need server and history ids!" unless ($pxt->param('sid') and $pxt->param('hid'));

  my $event = RHN::Server->lookup_server_event($pxt->param('sid'), $pxt->param('hid'));

  return PXT::Utils->perform_substitutions($params{__block__}, $event->render($pxt->user));

  return $params{__block__};
}

sub base_entitlement {
  my $pxt = shift;
  my $server = shift;

  my ($base_entitlement) = grep { $_->{IS_BASE} eq 'Y' } $server->entitlements;

  if ($base_entitlement) {
    return $pxt->user->org->slot_name($base_entitlement->{LABEL});
  }
  else {
    return "None";
  }
}

sub base_entitlement_box {
  my $pxt = shift;
  my $server = shift;

  my ($base_entitlement) = grep { $_->{IS_BASE} eq 'Y' } $server->entitlements;

  $base_entitlement ||= { LABEL => 'none',
			  PERMANENT => 'N' };

  if ($base_entitlement->{PERMANENT} eq 'Y') {
    return $pxt->user->org->slot_name($base_entitlement->{LABEL});
  }

  my @all_entitlements = RHN::Entitlements->valid_system_entitlements_for_org($pxt->user->org_id);
  my @allowed_entitlements = grep { $_->{IS_BASE} eq 'Y' and
				      ( $_->{LABEL} eq $base_entitlement->{LABEL} or
					$server->can_switch_base_entitlement($_->{LABEL})
				      )
				  } @all_entitlements;

  my @options = ( map { {label => $pxt->user->org->slot_name($_->{LABEL}),
			   value => $_->{LABEL}},
			 } @allowed_entitlements);

  if ($base_entitlement->{LABEL} eq 'none') {
    unshift @options,
      { label => 'None',
	value => 'none' };
  }
  else {
    unshift @options,
      { label => 'Unentitle System',
	value => 'unentitle' };
  }

  my $selectbox = new RHN::Form::Widget::Select (name => 'Base Entitlement',
						 label => 'base_entitlement',
						 default => $base_entitlement->{LABEL},
						 options => \@options);
  return $selectbox->render;
}

sub addon_entitlements {
  my $pxt = shift;
  my $server = shift;

  my @system_entitlements = $server->entitlements;
  my @addon_entitlements = grep { $_->{IS_BASE} eq 'N' } @system_entitlements;

  @addon_entitlements = map { $pxt->user->org->slot_name($_->{LABEL}) } @addon_entitlements;

  unless (@addon_entitlements) {
    push @addon_entitlements, "None";
  }

  return join(", ", @addon_entitlements);
}

sub addon_entitlement_box {
  my $pxt = shift;
  my $server = shift;

  my @system_entitlements = $server->entitlements;
  my ($base_entitlement) = grep { $_->{IS_BASE} eq 'Y' } @system_entitlements;
  my %addon_entitlements = map { ($_->{LABEL}, $_) }
    grep { $_->{IS_BASE} eq 'N' } @system_entitlements;

  if (not $base_entitlement) {
    return "A system must have a base entitlement to have add-on entitlements.";
  }

  my @all_entitlements = RHN::Entitlements->valid_system_entitlements_for_org($pxt->user->org_id);
  my %allowed_entitlements = map { ($_->{LABEL}, $_) }
    grep { $_->{IS_BASE} eq 'N' and
	   $server->can_entitle_server($_->{LABEL}) } @all_entitlements;

  my @options;
  my @selected;

  foreach my $ent (@all_entitlements) {
    if (exists $addon_entitlements{$ent->{LABEL}} or
	exists $allowed_entitlements{$ent->{LABEL}}) {
      my $disabled = (exists $addon_entitlements{$ent->{LABEL}} and
		   $ent->{PERMANENT} eq 'Y') ? 1 : 0;

      push @options, { label => $pxt->user->org->slot_name($ent->{LABEL}),
		       value => $ent->{LABEL},
		       disabled => $disabled };
      push(@selected, $ent->{LABEL}) if exists $addon_entitlements{$ent->{LABEL}};
    }
  }

  unless (@options) {
    return "No add-on entitlements available.";
  }

  my $boxes = new RHN::Form::Widget::CheckboxGroup (name => 'Add-On Entitlements',
						    label => 'addon_entitlements',
						    default => \@selected,
						    options => \@options);

  return join("<br/>\n", $boxes->render);
}

sub reboot_server_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server obj" unless $server;

  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);
  my $action_id = RHN::Scheduler->schedule_reboot(-org_id => $pxt->user->org_id,
						  -user_id => $pxt->user->id,
						  -earliest => $earliest_date,
						  -server_id => $sid);


  my $pretty_earliest_date = $pxt->user->convert_time($earliest_date);
  warn("asdfasdfasdf");
#  my $message = sprintf(<<EOM, $server->name, $server->name, $action_id);
#Reboot scheduled for system <strong>%s</strong> for $pretty_earliest_date.  To cancel the reboot, remove <strong>%s</strong> from <a href="/rhn/schedule/InProgressSystems.do?aid=%d"><strong>the list of systems to be rebooted</strong></a>.
#EOM
#
#  $pxt->push_message(site_info => $message);
  $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid&message=system.reboot.scheduled&messagep1=" . $server->name . "&messagep2=" . $pretty_earliest_date . "&messagep3=" . $action_id);
}

sub server_network_details {
  my $pxt = shift;
  my %params = @_;
  my $ret = '';
  my $current;

  my $server = $pxt->pnotes('server');

  throw "No server." unless $server;

  my @netinfos = $server->get_net_infos;

  my %subst;

  if (not @netinfos) {

    %subst = (counter => '', ip => 'unknown', hostname => 'unknown');
    PXT::Debug->log(7, "subst:  " . Data::Dumper->Dump([(\%subst)]));
    return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
  }

  PXT::Debug->log(7, "got netinfos...");

  my $counter = 1;

  my $html = $params{__block__};

  foreach my $netinfo (@netinfos) {
    my %subst;

    $subst{ip} = defined $netinfo->ipaddr ? $netinfo->ipaddr : "";
    $subst{hostname} = defined $netinfo->hostname ? $netinfo->hostname : "";
    $subst{counter} = $counter > 1 ? " ".$counter : "";

    PXT::Utils->escapeHTML_multi(\%subst);

    $ret .= PXT::Utils->perform_substitutions($html, \%subst);
  }

  return $ret;
}


sub server_network_interfaces {
  my $pxt = shift;
  my %params = @_;
  my $ret = '';
  my $current;

  my $server = $pxt->pnotes('server');

  throw "No server." unless $server;

  my @net_interfaces = $server->get_net_interfaces;

  my %subst;

  if (not @net_interfaces) {
    return '';
  }

  PXT::Debug->log(7, "got net_interfaces...");

  my $block = $params{__block__};
  $block =~ m/<rhn-interface-data>(.*?)<\/rhn-interface-data>/gism;
  my $device_data_block = $1;


  my $unknown = '<span class="no-details">(unknown)</span>';
  my $html = '';
  my $counter = 1;
  foreach my $interface (@net_interfaces) {

    my %subst;
    if ($counter % 2) {
      $subst{row_class} = 'list-row-odd';
    }
    else {
      $subst{row_class} = 'list-row-even';
    }


    $subst{interface_name} = $interface->name; # NOT NULL
    $subst{interface_ip_addr} = defined $interface->ip_addr ? PXT::Utils->escapeHTML($interface->ip_addr) : $unknown;
    $subst{interface_netmask} = defined $interface->netmask ? PXT::Utils->escapeHTML($interface->netmask) : $unknown;
    $subst{interface_broadcast} = defined $interface->broadcast ? PXT::Utils->escapeHTML($interface->broadcast) : $unknown;
    $subst{interface_hw_addr} = defined $interface->hw_addr ? PXT::Utils->escapeHTML($interface->hw_addr) : $unknown;
    $subst{interface_module} = defined $interface->module ? PXT::Utils->escapeHTML($interface->module) : $unknown;

    $html .= PXT::Utils->perform_substitutions($device_data_block, \%subst);
    $counter++;
  }

  PXT::Debug->log(7, "html:  $html");

  $block =~ s{<rhn-interface-data>.*?<\/rhn-interface-data>}{$html}ism;

  return $block;
}

# must happen *after* server_hardware_profile... so use tags
# correctly!
sub server_device {
  my $pxt = shift;
  my %params = @_;

  my $current;
  my $devices_html = '';

  my $class = $params{'class'};

  my $server_devices = $pxt->pnotes("server_devices");

  my $device_list = $server_devices->{$class};

  if (!$device_list) {
    return '';
  }

  my %valid_attribs = (HwDevice =>[qw/driver description pcitype bus vendor_id subdevice_id/,
				   qw/detached subvendor_id device device_id vendorstring/],
		       StorageDevice => [qw/driver physical pcitype description bus logical detached device/]);

  my $counter = 0;
  my $block = $params{__block__};
  $block =~ m/<rhn-device-data>(.*?)<\/rhn-device-data>/gism;
  my $device_data_block = $1;

  foreach my $device (@{$device_list}) {

    my %subst;

    if ($counter % 2) {
      $subst{row_class} = 'list-row-even';
    } else {
      $subst{row_class} = 'list-row-odd';
    }

    foreach my $attrib (@{$valid_attribs{(split /::/, ref $device)[-1]}}) {
      $subst{lc($class) . "_${attrib}"} = defined $device->$attrib() ? $device->$attrib() : "";
    }
    $counter++;

    PXT::Utils->escapeHTML_multi(\%subst);

    $devices_html .= PXT::Utils->perform_substitutions($device_data_block, \%subst);
  }


  $block =~ s/<rhn-device-data>.*?<\/rhn-device-data>/$devices_html/gism;

  return $block;
}

sub server_dmi_info {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $server = $pxt->pnotes('server');

  throw "No server found." unless $server;

  my $subst;

  my @dmi_fields = qw/vendor system product bios_vendor board bios_release bios_version asset/;

  my $got_dmi;

  foreach my $field (@dmi_fields) {

    my $fn = 'dmi_' . $field;
    my $temp = $server->$fn();

    if ($temp) {

      $subst->{$fn} = PXT::Utils->escapeHTML($temp);
      $got_dmi = 1;
    }
    else {
      $subst->{$fn} = '&#160;';
    }
  }

  return '' if not $got_dmi;

  $block = PXT::Utils->perform_substitutions($block, $subst);
  return $block;
}

sub server_hardware_profile {
  my $pxt = shift;
  my %params = @_;

  my $sid = $pxt->param('sid');
  die "no server id" unless ($sid);

  my $server = RHN::Server->lookup(-id => $sid);

  $pxt->pnotes(server => $server);

  if (not $server->has_hardware_profile) {
    return "<div align=\"center\"><strong>Hardware not yet profiled.</strong></div>";
  }


  my $ret = $params{__block__};

  my @storage_devices = $server->get_storage_devices;
  my @cd_devices = $server->get_cd_devices;

  # Hardware devices can have the following classes (note
  # that these could have been changed in the db after I
  # write this!!):

  #  CLASS
  #  ----------------
  # AUDIO
  # MODEM
  # MOUSE
  # NETWORK
  # OTHER
  # SCSI
  # SOCKET
  # USB
  # VIDEO


  my @hardware_devices = $server->get_hw_devices;

  # USB fix
  foreach my $hw_device (@hardware_devices) {
    if (defined $hw_device->bus() and $hw_device->bus eq 'USB') {
#      warn "HW USB fix... class from: " . $hw_device->class;
      $hw_device->class('USB');
#      warn "to:  " . $hw_device->class;
    }
  }

  my %hw_dev_sorted;

  # we're mushing these all to be handled by a subtag
  push @{ $hw_dev_sorted{$_->class} }, $_ foreach (@hardware_devices, @storage_devices, @cd_devices);

  my %subst;

  # take care of the one-off's here...
  $subst{server_name} = PXT::Utils->escapeHTML($server->name || '');

  foreach (qw/cpu_model cpu_mhz cpu_bogomips cpu_arch_name cpu_vendor cpu_cache cpu_stepping cpu_family memory_ram memory_swap/) {
    $subst{$_} = defined $server->$_() ? $server->$_() : '';
    $subst{cpu_arch_name} = $server->get_cpu_arch_name || '';
  }

  $subst{cpu_count} = defined $server->cpu_nrcpu() ? $server->cpu_nrcpu() : '';

  PXT::Utils->escapeHTML_multi(\%subst);

  $pxt->pnotes('server_devices' => \%hw_dev_sorted);

  return PXT::Utils->perform_substitutions($ret, \%subst);
  #return Data::Dumper->Dump([($server)]);
  #return "<pre>".Data::Dumper->Dump([(%hw_dev_sorted)])."</pre>";
}

my @user_server_prefs = ( { name => 'receive_notifications',
			    label => 'Receive Notifications of Updates/Errata' },
			  { name => 'include_in_daily_summary',
			    label => 'Include system in Daily Summary'},
			);

my @server_prefs = ( { name => 'auto_update',
		       label => 'Automatic application of relevant errata' },
		   );

sub tri_state_system_pref_list {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $html = '';

  my $counter = 1;

  foreach my $pref (@user_server_prefs, @server_prefs) {
    $counter++;
    my %subst;

    $subst{pref_name} = $pref->{name};
    $subst{pref_label} = $pref->{label};
    $subst{class} = ($counter % 2) ? "list-row-even" : "list-row-odd";

    PXT::Utils->escapeHTML_multi(\%subst);

    $html .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  return $html;
}

sub ssm_change_system_prefs_cb {
  my $pxt = shift;

  my $no_op = 1;
  foreach my $pref (@user_server_prefs, @server_prefs) {
    my $action = $pxt->dirty_param($pref->{name});

    if ($action eq 'set' || $action eq 'unset') {
      $no_op = 0;
    }
  }

  if ($no_op) {
    my $redir = $pxt->dirty_param('do_nothing_redir');
    throw "no redir param" unless $redir;
    $pxt->push_message(site_info => 'Your selections resulted in no change.');
    $pxt->redirect($redir);
  }
}

sub server_prefs_conf_list {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my %subst;

  my $ret = '';
  foreach my $pref (@user_server_prefs, @server_prefs) {
    $subst{pref_name} = $pref->{name};
    $subst{pref_label} = $pref->{label};

    if ($pxt->dirty_param($pref->{name}) eq 'set') {
      $subst{pref_choice} = "Yes";
    }
    elsif ($pxt->dirty_param($pref->{name}) eq 'unset') {
      $subst{pref_choice} = "No";
    }
    else {
      next;
      $subst{pref_choice} = "No Change";
    }

    $ret .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  return $ret;
}

sub server_prefs_form_cb {
  my $pxt = shift;

  if ($pxt->dirty_param('sscd_change_sys_prefs_conf')) {
    my $set = new RHN::DB::Set 'system_list', $pxt->user->id;

    my @extra_messages;

    foreach my $pref (@user_server_prefs) {
      my $action = $pxt->dirty_param($pref->{name});
      next unless $action;

      RHN::Server->change_user_pref_bulk($set, $pxt->user, $pref->{name}, $action eq 'Yes' ? 1 : 0, 1);
    }

    foreach my $pref (@server_prefs) {

      my $action = $pxt->dirty_param($pref->{name});
      next unless $action;

      # if we're setting auto errata updates == Y, then auto upgrade all selected systems
      if ($pref->{name} eq 'auto_update' and $action eq 'Yes') {

	my $system_set = new RHN::DB::Set 'system_list', $pxt->user->id;

	RHN::Scheduler->schedule_all_errata_for_systems(-earliest => RHN::Date->now->long_date,
							-org_id => $pxt->user->org_id,
							-user_id => $pxt->user->id,
							-server_set => $system_set,
						       );

	push @extra_messages, "Selected systems will be fully updated in accordance with new Auto Errata Update setting.";
      }

      RHN::Server->change_pref_bulk($set, $pref->{name}, $action eq 'Yes' ? 1 : 0);
    }

    $pxt->push_message(site_info => "Preferences changed for selected systems.");

    foreach my $message (@extra_messages) {
      $pxt->push_message(site_info => $message);
    }

    $pxt->redirect('/network/systems/ssm/misc/index.pxt');
  }
}

sub system_base_channel_select {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $sid = $pxt->param('sid');

  die "No Server id!"
    unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);

  my $current_base_id = $server->base_channel_id || 0;

  if ($current_base_id and not $pxt->user->verify_channel_subscribe($current_base_id)) {
    $pxt->pnotes(resubscribe_base_warning => 1);
  }

  my @channels = RHN::Channel->user_subscribable_bases_for_system($server, $pxt->user);

  unshift @channels, { ID => 0, NAME => "(none, disable service)", LABEL => "(none)" };

  my @options;

  foreach my $channel (@channels) {
    my $selected = '';

    if ($channel->{ID} == $current_base_id) {
      $selected = '1';
    }

    push @options, [ PXT::Utils->escapeHTML($channel->{NAME} || ''), $channel->{ID}, $selected ];
  }

  return PXT::HTML->select(-name => "system_base_channel",
			   -options => \@options);
}

sub delete_servers_cb {
  my $pxt = shift;

  my $set_name = 'system_list';
  my $set = new RHN::DB::Set $set_name, $pxt->user->id;

  my $count = scalar($set->contents);

  RHN::Server->delete_servers_in_system_list($pxt->user->id);

  my $message = "message=" . sprintf('message.ssm.server%sdeleted', ($count == 1 ? '' : 's')) . "%messagep1=$count";
  $pxt->redirect('/rhn/systems/Overview.do?empty_set=true&return_url=/rhn/systems/Overview.do?' . $message);
}

sub store_bounce {
  my $pxt = shift;
  my %params = @_;

  my $ret = $params{__block__};

  # A bit of an ugly and hurried loop here, but it'll work.

  my @ent_types = ('sw_mgr_', 'enterprise_');
  my $ent_type;

  foreach $ent_type (@ent_types) {
    my $eg = $ent_type . "entitled";
    my ($server_count, $entitled_server_count, $entitlement_count) = $pxt->user->org->entitlement_gap($eg);
    my $recommend = $server_count - $entitlement_count;
    $recommend = int($recommend/5 + 1) * 5;
    $recommend = 5 if $recommend < 5;

    my $remaining = $entitlement_count - $entitled_server_count;
    $remaining = 0 if $remaining < 0;

    my $rq = $ent_type . 'recommend_quantity';
    my $edc = $ent_type . 'entitled_count';
    my $etc = $ent_type . 'entitlement_count';
    my $er = $ent_type . 'entitlement_remaining';

    $ret =~ s/\{$rq\}/$recommend/gms;

    $ret =~ s/\{$edc\}/$entitled_server_count/gms;
    $ret =~ s/\{$etc\}/defined $entitlement_count ? $entitlement_count : '(unlimited)'/egms;
    $ret =~ s/\{$er\}/defined $entitlement_count ? $remaining : '(unlimited)'/egms;

    $ret =~ s/\{quantity\}/$pxt->param('quantity') || 5/egms;

    $ret =~ s/\{rhn_$_\}/$pxt->dir_config("rhn_$_")/egsmi
      foreach qw/item_code store_url/;
  }

  return $ret;
}

sub system_activation_key_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_system_activation_key_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

sub build_system_activation_key_form {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  die "No system id" unless $sid;

  my $form = new RHN::Form::ParsedForm(name => 'System Activation Key',
				       label => 'system_activation_key',
				       action => $attr{action},
				      );

  my $system = RHN::Server->lookup(-id => $sid);
  my $token;
  my $token_exists = 0;

  $token = RHN::Token->lookup(-sid => $sid);

  if ($token and not $token->disabled) {
    $token_exists = 1;
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'ID', value => $token->id) );
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Org ID', value => $token->org_id) );
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Key', value => $token->activation_key_token) );
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:system-activation-key-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(label => 'Delete Key', name => 'delete_key') ) if ($token_exists);
  $form->add_widget( new RHN::Form::Widget::Submit(label => 'Generate New Key', name => 'generate_new_key') );

  return $form;
}

sub system_activation_key_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  my $orig_token = RHN::Token->lookup(-sid => $sid);
  if ($orig_token) {
    $orig_token->purge;
    undef $orig_token;
  }

  if ($pxt->dirty_param('generate_new_key')) {
    my $token = Sniglets::ActivationKeys->create_token($pxt);
    $token->activation_key_token(RHN::Token->generate_random_key);
    my $server = RHN::Server->lookup(-id => $sid);

    $token->server_id($sid);
    $token->note("Activation key for " . $server->name . ".");
    $token->usage_limit(1);

    $token->commit;

    $token->set_entitlements(map { $_->{LABEL} } $server->entitlements);

    $token->commit;
  }

  my $url = $pxt->uri;
  $pxt->redirect($url . "?sid=" . $sid);
}

sub server_lock_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  my $lock = $pxt->dirty_param('lock');

  my $system = RHN::Server->lookup(-id => $sid);
  my $msg;
  if ($lock) {
    $system->lock_server($pxt->user, "Manually locked");
    $msg = "<strong>%s</strong> has been locked.";
  }
  else {
    $system->unlock_server();
    $msg = "<strong>%s</strong> has been unlocked.";
  }

  $pxt->push_message(site_info => sprintf($msg, $system->name));
  $pxt->redirect("index.pxt?sid=$sid");
}

sub server_set_lock_cb {
  my $pxt = shift;
  my $lock = $pxt->dirty_param('lock');

  my $set = new RHN::Set("system_list", $pxt->user->id);

  my $msg;
  if ($lock) {
    RHN::Server->lock_server_set($set, $pxt->user, "Manually locked");
    $msg = "The selected systems have been locked."
  }
  else {
    RHN::Server->unlock_server_set($set);
    $msg = "The selected systems have been unlocked."
  }

  $pxt->push_message(site_info => $msg);
  $pxt->redirect("index.pxt");
}

sub ks_session_redir {
  my $class = shift;
  my $node = shift;
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  throw 'no sid' unless $sid;

  my $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -soft => 1);
  my $state = $session ? $session->session_state_label : '';

  if ($session and $state ne 'complete' and $state ne 'failed') {
    $pxt->redirect('/network/systems/details/kickstart/session_status.pxt?sid=' . $sid);
  }

  return;
}

sub remote_command_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_remote_command_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

my %remote_command_modes = (
			    system_action => { type => 'standalone',
					       location => 'sdc',
					       verb => 'Install',
					     },
			    package_install => { type => 'package',
						 location => 'sdc',
						 verb => 'Install',
					       },
			    package_remove => { type => 'package',
						location => 'sdc',
						verb => 'Remove',
					      },
			    ssm => { type => 'standalone',
				     location => 'ssm',
				     verb => 'Install',
				   },
			    ssm_package_install => { type => 'package',
						     location => 'ssm',
						     verb => 'Install',
					       },
			    ssm_package_upgrade => { type => 'package',
						     location => 'ssm',
						     verb => 'Upgrade',
					       },
			    ssm_package_remove => { type => 'package',
						    location => 'ssm',
						    verb => 'Remove',
						  },
			   );

sub build_remote_command_form {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $mode = $attr{mode} || $pxt->dirty_param('mode') || 'system_action';

  my $form = new RHN::Form::ParsedForm(name => 'Remote Command',
				       label => 'remote_command_form',
				       action => $attr{action},
				      );

  if ($remote_command_modes{$mode}->{type} eq 'package') {
    $form->add_widget(radio_group => { name => 'Run',
				       label => 'run_script',
				       value => 'before',
				       options => [ { value => 'before', label => 'Before package action' },
						    { value => 'after', label => 'After package action' },
						  ],
				     });
  }

  $form->add_widget(text => { name => 'Run as user',
			      label => 'username',
			      default => 'root',
			      maxlength => 32,
			      requires => { response => 1 },
			    } );

  $form->add_widget(text => { name => 'Run as group',
			      label => 'group',
			      default => 'root',
			      maxlength => 32,
			      requires => { response => 1 },
			    } );

  $form->add_widget(text => { name => 'Timeout (seconds)',
			      label => 'timeout',
			      default => '600',
			      mexlenth => 16,
			      size => 6,
			    } );

  $form->add_widget(textarea => { name => 'Script',
				  label => 'script',
				  rows => 8,
				  cols => 80,
                                  wrap => 'off',
				  default => "#!/bin/sh\n",
				  requires => { response => 1 },
				});

  $form->add_widget(hidden => { label => 'mode', value => $mode });

  my $sched_img = PXT::HTML->img(-src => '/img/rhn-icon-schedule.gif', -alt => 'Date Selection');
  my $sched_widget =
    new RHN::Form::Widget::Literal(label => 'pickbox',
				   name => 'Schedule no sooner than',
				   value => $sched_img . Sniglets::ServerActions::date_pickbox($pxt));

  if ($remote_command_modes{$mode}->{type} eq 'package'
      and $remote_command_modes{$mode}->{location} eq 'sdc') {
    die "No system id" unless $sid;

    $form->add_widget(hidden => { label => 'set_label', value => $pxt->dirty_param('set_label') });

    $form->add_widget(hidden => { label => 'pxt:trap', value => 'rhn:package-action-command-cb' });
    $form->add_widget(submit => { label => 'Schedule Package Install', name => 'schedule_remote_command' });
  }
  elsif ($remote_command_modes{$mode}->{type} eq 'package'
	 and $remote_command_modes{$mode}->{location} eq 'ssm') {
    $form->add_widget(hidden => { label => 'pxt:trap', value => 'rhn:package-action-command-cb' });

    $form->add_widget($sched_widget);

    $form->add_widget(submit => { label => 'Schedule Remote Command', name => 'schedule_remote_command' });
  }
  elsif ($remote_command_modes{$mode}->{type} eq 'standalone'
	 and $remote_command_modes{$mode}->{location} eq 'sdc') {
    die "No system id" unless $sid;

    $form->add_widget(hidden => { label => 'pxt:trap', value => 'rhn:remote-command-cb' });
    $form->add_widget($sched_widget);

    $form->add_widget(submit => { label => 'Schedule Remote Command', name => 'schedule_remote_command' });
  }
  elsif ($remote_command_modes{$mode}->{type} eq 'standalone'
	 and $remote_command_modes{$mode}->{location} eq 'ssm') {

    #$form->add_widget(hidden => { label => 'pxt:trap', value => 'rhn:remote-command-ssm-cb' });
    $form->add_widget($sched_widget);

    $form->add_widget(submit => { label => 'Schedule Remote Command', name => 'schedule_remote_command' });
  }
  else {
    throw "Unknown mode: '$mode'\n";
  }

  if ($mode eq 'ssm_package_install') {
    $form->add_widget(hidden => { label => 'sscd_confirm_package_installations', value => 1 });
  }
  elsif ($mode eq 'ssm_package_upgrade') {
    $form->add_widget(hidden => { label => 'sscd_confirm_package_upgrades', value => 1 });
  }
  elsif ($mode eq 'ssm_package_remove') {
    $form->add_widget(hidden => { label => 'sscd_confirm_package_removals', value => 1 });
  }

  if ($sid) {
    $form->add_widget(hidden => { label => 'sid', value => $sid });
  }

  my $cid = $pxt->param('cid');

  if ($cid) {
    $form->add_widget(hidden => {label => 'cid', value => $cid});
  }

  return $form;
}

sub remote_command_cb {
  my $pxt = shift;

  my $pform = build_remote_command_form($pxt);
  my $form = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $form);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $sid = $form->param('sid');
  my $username = $form->param('username');
  my $group = $form->param('group');
  my $script = $form->param('script');
  my $timeout = $form->param('timeout');

  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  my $action_id = RHN::Scheduler->schedule_remote_command(-org_id => $pxt->user->org_id,
							  -user_id => $pxt->user->id,
							  -earliest => $earliest_date,
							  -server_id => $sid,
							  -action_name => undef,
							  -script => $script,
							  -username => $username,
							  -group => $group,
							  -timeout => $timeout,
							 );

  my $system = RHN::Server->lookup(-id => $sid);

#   $pxt->push_message(site_info => sprintf(<<EOQ, $sid, $action_id, $system->name));
# Remote command <a href="/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d">scheduled</a> for <strong>%s</strong>.
# EOQ

  $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid&message=system.remotecommand.scheduled&messagep1=$sid&messagep2=$action_id&messagep3=" . $system->name);
}

sub package_action_command_cb {
  my $pxt = shift;

  my $pform = build_remote_command_form($pxt);
  my $form = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $form);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $sid = $form->param('sid');
  my $username = $form->param('username');
  my $group = $form->param('group');
  my $script = $form->param('script');
  my $order = $form->param('run_script');
  my $timeout = $form->param('timeout');
  my $mode = $form->param('mode');
  my $system_set;

  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  if ($remote_command_modes{$mode}->{location} eq 'ssm') {
    $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);
  }

  my @actions;
  my $actions_by_sid;

  if ($mode eq 'package_install') {
    @actions = Sniglets::ListView::PackageList::install_packages_cb($pxt);
  }
  elsif ($mode eq 'package_remove') {
    @actions = Sniglets::ListView::PackageList::remove_packages_cb($pxt);
  }
  elsif ($mode eq 'ssm_package_install') {
    @actions = Sniglets::Packages::sscd_confirm_package_installations_cb($pxt);
  }
  elsif ($mode eq 'ssm_package_upgrade') {
    $actions_by_sid = Sniglets::Packages::sscd_confirm_package_upgrades_cb($pxt);
  }
  elsif ($mode eq 'ssm_package_remove') {
    @actions = Sniglets::Packages::sscd_confirm_package_removals_cb($pxt);
  }
  else {
    throw "Invalid mode: $mode";
  }

  return unless (@actions or $actions_by_sid);

  my $cmd_aid;

  if (@actions) {
    $cmd_aid = RHN::Scheduler->schedule_remote_command(-org_id => $pxt->user->org_id,
							  -user_id => $pxt->user->id,
							  -earliest => $earliest_date,
							  -server_id => $sid,
							  -server_set => $system_set,
							  -action_name => undef,
							  -script => $script,
							  -username => $username,
							  -group => $group,
							  -timeout => $timeout,
							 );

    schedule_action_prereq($order, $cmd_aid, @actions);

  }
  else {
    foreach my $server_id (keys %{$actions_by_sid}) {
      $cmd_aid = RHN::Scheduler->schedule_remote_command(-org_id => $pxt->user->org_id,
							    -user_id => $pxt->user->id,
							    -earliest => $earliest_date,
							    -server_id => $server_id,
							    -action_name => undef,
							    -script => $script,
							    -username => $username,
							    -group => $group,
							    -timeout => $timeout,
							   );
      schedule_action_prereq($order, $cmd_aid, @{$actions_by_sid->{$server_id}});
    }
  }

  my $verb = $remote_command_modes{$mode}->{verb};

  $pxt->push_message(site_info => 
		     "The remote command action was scheduled to run <strong>$order</strong> the package $verb action" . (scalar @actions == 1 ? '' : 's') . ".");

  if ($remote_command_modes{$mode}->{location} eq 'ssm') {
    $pxt->redirect('/network/systems/ssm/packages/index.pxt');
  }

  return;
}

sub schedule_action_prereq {
  my $order = shift;
  my $target_aid = shift;
  my @actions = @_;

  if ($order eq 'before') {
    $actions[0]->prerequisite($target_aid);
    $actions[0]->commit;
  }
  elsif ($order eq 'after') {
    my $target_action = RHN::Action->lookup(-id => $target_aid);
    $target_action->prerequisite($actions[-1]->id);
    $target_action->commit;
  }
  else {
    throw "Unknown order: '$order'."
  }

  return;
}

1;
