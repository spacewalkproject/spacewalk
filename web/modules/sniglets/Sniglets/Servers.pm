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
use Sniglets::Org;
use Sniglets::HTML;
use Sniglets::AppInstall;
use Sniglets::ServerActions;
use Sniglets::ActivationKeys;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-up2date-at-least' => \&up2date_at_least);

  $pxt->register_tag('rhn-server-child-channel-interface' => \&server_child_channel_interface, -1);
  $pxt->register_tag('rhn-resubscribe-warning-sdc' => \&resubscribe_warning_sdc, 3);
  $pxt->register_tag('rhn-resubscribe-base-warning-sdc' => \&resubscribe_base_warning_sdc, 3);
  $pxt->register_tag('rhn-server-base-channel' => \&server_base_channel, 2);
  $pxt->register_tag('rhn-server-child-channels' => \&server_child_channels, 3);

  $pxt->register_tag('rhn-server-prefs-conf-list' => \&server_prefs_conf_list);
  $pxt->register_tag('rhn-server-name' => \&server_name, 2);
  $pxt->register_tag('rhn-admin-server-edit-form' => \&admin_server_edit_form);

  $pxt->register_tag('rhn-tri-state-system-pref-list' => \&tri_state_system_pref_list);
  $pxt->register_tag('rhn-tri-state-system-entitlement-list' => \&tri_state_system_entitlement_list);
  $pxt->register_tag('rhn-server-brb-checkin-message' => \&server_brb_checkin_message);

  $pxt->register_tag('rhn-server-hardware-profile' => \&server_hardware_profile);
  $pxt->register_tag('rhn-dmi-info' => \&server_dmi_info, 1);
  $pxt->register_tag('rhn-server-device' => \&server_device, 1);

  # has to run after server_details
  $pxt->register_tag('rhn-server-network-details' => \&server_network_details, 2);
  # slightly different than the rhn-server-network-details, this gives access to
  # more detailed info about the network interfaces, as opposed to just hostname/ipaddy
  $pxt->register_tag('rhn-server-network-interfaces' => \&server_network_interfaces, 2);


  $pxt->register_tag('rhn-server-history-event-details' => \&server_history_event_details);

  $pxt->register_tag('rhn-server-status-interface' => \&server_status_interface, 10);

  $pxt->register_tag('rhn-system-base-channel-select' => \&system_base_channel_select);

  $pxt->register_tag('rhn-proxy-entitlement-form' => \&proxy_entitlement_form);

  $pxt->register_tag('rhn-satellite-entitlement-form' => \&satellite_entitlement_form);

  $pxt->register_tag('rhn-entitlement-count' => \&entitlement_count);
  $pxt->register_tag('rhn-system-pending-actions-count' => \&system_pending_actions_count);
  $pxt->register_tag('rhn-system-activation-key-form' => \&system_activation_key_form);

  $pxt->register_tag('rhn-check-config-client' => \&check_config_client);

  $pxt->register_tag('rhn-remote-command-form' => \&remote_command_form);

  $pxt->register_tag('rhn-server-virtualization-guest-details' => \&server_virtualization_details, 2);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:activate_sat_applet_cb' => \&activate_sat_applet_cb);

  $pxt->register_callback('rhn:proxy_entitlement_cb' => \&proxy_entitlement_cb);
  $pxt->register_callback('rhn:cancel_scheduled_proxy_install_cb' => \&cancel_scheduled_proxy_install);
  $pxt->register_callback('rhn:satellite_entitlement_cb' => \&satellite_entitlement_cb);

  $pxt->register_callback('rhn:admin_server_edit_cb' => \&admin_server_edit_cb);

  $pxt->register_callback('rhn:delete_server_cb' => \&delete_server_cb);
  $pxt->register_callback('rhn:reboot_server_cb' => \&reboot_server_cb);

  $pxt->register_callback('rhn:server_prefs_form_cb' => \&server_prefs_form_cb);

  # this now gets called in some cases by admin_server_edit_cb
  $pxt->register_callback('rhn:system_update_brb_cb' => \&system_update_brb_cb);

  $pxt->register_callback('rhn:system_package_list_refresh_cb' => \&system_package_list_refresh_cb);
  $pxt->register_callback('rhn:server_hardware_list_refresh_cb' => \&server_hardware_list_refresh_cb);

  $pxt->register_callback('rhn:server_child_channel_interface_cb' => \&server_child_channel_interface_cb);

  $pxt->register_callback('rhn:system_base_channel_select_cb' => \&system_base_channel_select_cb);

  $pxt->register_callback('rhn:ssm_change_system_prefs_cb' => \&ssm_change_system_prefs_cb);

  $pxt->register_callback('rhn:delete_servers_cb' => \&delete_servers_cb);

  $pxt->register_callback('rhn:system-activation-key-cb' => \&system_activation_key_cb);
  $pxt->register_callback('rhn:add-filenames-to-set-cb' => \&add_filenames_to_set_cb);

  $pxt->register_callback('rhn:server_lock_cb' => \&server_lock_cb);
  $pxt->register_callback('rhn:server_set_lock_cb' => \&server_set_lock_cb);

  $pxt->register_callback('rhn:remote-command-cb' => \&remote_command_cb);
  $pxt->register_callback('rhn:package-action-command-cb' => \&package_action_command_cb);

  $pxt->register_callback('rhn:osa-ping' => \&osa_ping_cb);
}

sub register_xmlrpc {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_xmlrpc('server_needed_packages', \&server_outdated_package_list_xmlrpc);
  $pxt->register_xmlrpc('server_schedule_errata_update', \&server_schedule_errata_update_xmlrpc);
  $pxt->register_xmlrpc('server_schedule_package_update', \&server_schedule_package_update_xmlrpc);
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

sub activate_sat_applet_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  die "no sid" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server" unless $server;

  my $earliest_date = RHN::Date->now->long_date;
  my $action_id = RHN::Scheduler->schedule_sat_applet(org_id => $pxt->user->org_id,
						      user_id => $pxt->user->id,
						      earliest => $earliest_date,
						      server_id => $server->id);

  my $url = PXT::HTML->link2(text => "scheduled",
			     url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=$action_id");

  $pxt->push_message(site_info => "RHN Applet Spacewalk activation $url.");
  $pxt->redirect("index.pxt?sid=$sid");
}

sub resubscribe_warning_sdc {
  my $pxt = shift;
  my %params = @_;

  if ($pxt->pnotes('resubscribe_warning')) {
    return $params{__block__};
  }

  return '';
}

sub resubscribe_base_warning_sdc {
  my $pxt = shift;
  my %params = @_;

  if ($pxt->pnotes('resubscribe_base_warning')) {
    return $params{__block__};
  }

  return '';
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

# gets the channels from the admin_server_edit_form via pnote, 2nd link in chain.
sub server_base_channel {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $server_channels = $pxt->pnotes('server_channels');

  my ($base_channel) = grep { not defined $_->{PARENT_CHANNEL} }  @{$server_channels};
  $block = PXT::Utils->perform_substitutions($block, {base_id => $base_channel->{ID}, base_name => PXT::Utils->escapeHTML($base_channel->{NAME} || '')});
  return $block;
}

# gets the channels from server_base_channel via pnote, 3rd link in chain.
sub server_child_channels {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $server_channels = $pxt->pnotes('server_channels');
  PXT::Debug->log_dump(7, \$server_channels);
  my $ret = '';
  foreach my $sc (grep { defined $_->{PARENT_CHANNEL} } @{$server_channels}) {
    my %subst = (child_channel_name => PXT::Utils->escapeHTML($sc->{NAME} || ''), child_channel_id => $sc->{ID});
    PXT::Debug->log_dump(\%subst);
    $ret .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  PXT::Debug->log(7, "server channels:  $ret");

  return $ret;
}

sub server_child_channel_interface {
  my $pxt = shift;
  my %params = @_;

  my $server_id = $pxt->param('sid');

  my $server = RHN::Server->lookup(-id => $server_id);
  my $base_chan_id = $server->base_channel_id();

  my $block = $params{__block__};

  my @server_channels = $server->user_server_channels_info($pxt->user->id);

  # save a lookup for subscribed channels for use in loop below... important in warning resubscription...
  my %subscribed = map { $_->{ID} => 1 } @server_channels;

  my @subscribable_channels = RHN::Channel->subscribable_channels(server_id => $server_id,
								  user_id => $pxt->user->id,
								  base_channel_id => $base_chan_id);

  my %sat_channels = map { $_ => 1 } RHN::Channel->rhn_satellite_channels();
  my %proxy_channels = map { $_ => 1 } RHN::Channel->rhn_proxy_channels();

  # filter out proxy and satellite channels, they're handled by seperate interface,
  # and filter out the base channel as well...
  my @channels = grep { not exists $sat_channels{$_->{ID}} and not exists $proxy_channels{$_->{ID}} and $_->{ID} ne $base_chan_id}
    (@server_channels, @subscribable_channels);

  $pxt->pnotes(child_channels_total => scalar @channels);

  $block =~ m/<child_channel>(.*?)<\/child_channel>/ism;
  my $child_channel_block = $1;

  $child_channel_block =~ m/<gpg_key>(.*?)<\/gpg_key>/ism;
  my $gpg_key_block = $1;

  my $child_channels_html = '';

  # determines whether we render the guts of rhn-resubscribe-warning
  my $resubscribe_warning;

  foreach my $channel (sort { $a->{NAME} cmp $b->{NAME} } @channels) {
    my $current = $child_channel_block;
    my $current_gpg = '';

    my %subs;
    $subs{checkbox} = PXT::HTML->checkbox(-name => "child_channel",
					  -value => PXT::Utils->escapeHTML($channel->{ID} || ''),
					  -checked => ((grep { $_->{LABEL} eq $channel->{LABEL} } @server_channels) ? 1 : 0));

    $subs{channel_id} = PXT::Utils->escapeHTML($channel->{ID});
    $subs{channel_name} = PXT::Utils->escapeHTML($channel->{NAME});
    $subs{channel_summary} = PXT::Utils->escapeHTML($channel->{SUMMARY});
    $subs{resubscribe_warning} = '';

    if ($subscribed{$channel->{ID}} and not $channel->{RESUBSCRIBABLE}) {

      # we'll need to show warning text...
      $resubscribe_warning = 1;

      $subs{resubscribe_warning} = PXT::HTML->img(-src => '/img/rhn-listicon-alert.gif',
						  -title => 'Resubscription Warning',
						 );

      $subs{resubscribe_warning} = "<span class=\"resubscribe-warning\">$subs{resubscribe_warning}</span>";
    }

    $current = PXT::Utils->perform_substitutions($current, \%subs);

    if ($channel->{GPG_KEY_URL}) {
      $current_gpg = $gpg_key_block;
      $current_gpg =~ s{\{gpg_key_url\}}{$pxt->derelative_url("/network/software/channels/details.pxt?cid=" . $channel->{ID}, 'https')}eg;
    }

    $current =~ s{<gpg_key>.*?</gpg_key>}{$current_gpg}gis;
    $child_channels_html .= $current;
  }

  $block =~ s{<child_channel>.*?</child_channel>}{$child_channels_html}is;

  $pxt->pnotes('resubscribe_warning' => 1) if $resubscribe_warning;
  $pxt->pnotes('server_details_subscribable_child_channels_seen' => scalar @channels);

  return $block;
}


sub server_child_channel_interface_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  die "no server id!" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);

  my %proxy_channels = map { $_ => 1 } RHN::Channel->rhn_proxy_channels();

  # figure out any satellite channels that could theoretically apply to this system...
  my %sat_chan_ids = map {$_ => 1} RHN::Channel->rhn_satellite_channels();

  PXT::Debug->log(7, "satellite channel ids:  " . join(", ", sort keys %sat_chan_ids));

  my $diff;

  eval {
    my @channels;
    my @eula_channels;

    my @requested_channels = $pxt->dirty_param('child_channel');

    my @sc = $server->server_channels();
    my %already_subscribed = map { $_->{ID} => 1} @sc;

    my @subscribable_channels = RHN::Channel->subscribable_channels(server_id => $sid,
								    user_id => $pxt->user->id,
								    base_channel_id => $server->base_channel_id());

    # see if any of the requested channels are no longer allowed to be subscribed,
    # also protects against forged requests...
    my @requested_not_already_subscribed = grep { not $already_subscribed{$_} } @requested_channels;

    if (not $pxt->user->verify_channel_subscribe(@requested_not_already_subscribed)) {
      my $error_msg = <<EOM;
You no longer have subscription access to some of the channels you selected.<br />
Please review your selections and try again.
EOM
      $pxt->push_message(local_alert => $error_msg);
      $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
    }

    my %sc_hash = map { ($_->{ID} => 1) } @sc;


    my %channels_with_eula = map { $_->{ID} => 1 }  grep { defined $_->{HAS_LICENSE} } @subscribable_channels;

    foreach my $req_cid (@requested_channels) {

      # only require eula for ones needing it which haven't already been subscribed to for this server.
      if ($channels_with_eula{$req_cid} and !$sc_hash{$req_cid}) {
	push @eula_channels, $req_cid;
      }
      else {
	push @channels, $req_cid
      }
    }

    PXT::Debug->log(7, Data::Dumper->Dump([(@sc)]));

    # this might be a satellite, so it's possible no proxy channels were found...
    if (%proxy_channels) {
      # is the system a proxy?  if so, add the appropriate proxy channel
      my ($is_proxy) = grep { $proxy_channels{$_->{ID}} } @sc;

      if ($is_proxy) {
	push @channels, $is_proxy->{ID};
	PXT::Debug->log(7, "added proxy channel to subscription list...");
      }
    }

    # is the system a satellite?  if so, add the appropriate satellite channel
    my ($is_sat) = grep { exists $sat_chan_ids{$_->{ID}} } @sc;
    if ($is_sat) {
      push @channels, $is_sat->{ID};
      PXT::Debug->log(7, "added satellite channel to subscription list...");
    }

    PXT::Debug->log(7, Data::Dumper->Dump([(@channels)]));

    $diff = $server->set_channels(user_id => $pxt->user->id, channels => [$server->base_channel_id, @channels]);
    my $added = @{$diff->{added}};
    my $removed = @{$diff->{removed}};

    if ($added) {
      $pxt->push_message(site_info => sprintf('<strong>%s</strong> subscribed to <strong>%d</strong> child channel%s.',
					      PXT::Utils->escapeHTML($server->name),
					      $added, $added == 1 ? '' : 's' ));
    }

    if ($removed) {
      $pxt->push_message(site_info => sprintf('<strong>%s</strong> unsubscribed from <strong>%d</strong> child channel%s.',
					      PXT::Utils->escapeHTML($server->name),
					      $removed, $removed == 1 ? '' : 's' ));
    }

    if (($added or $removed) and $server->has_feature('ftr_snapshotting')) {
      # go ahead and snapshot now instead of at the end of the eula channel subscription chain.
      RHN::Server->snapshot_server(-server_id => $sid, -reason => "Channel subscription alterations");
    }

    if (@eula_channels) {

      PXT::Debug->log(7, "eula channels:  " . join(", ", @eula_channels));

      my $params = pop @eula_channels;

      if (@eula_channels) {
	$params .= "&additional_channel=" . join("&additional_channel=", @eula_channels);
      }

      my $redir = $pxt->dirty_param('license_redirect') || '';
      throw "param 'license_redirect' needed but not provided." unless $redir;
      $pxt->redirect($redir . "?sid=$sid&current_channel=$params");
    }
  };
  if ($@) {
    my $E = $@;
    if (ref $E and catchable($E)) {
      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
	$pxt->push_message(local_alert => "This assignment would exceed your allowed subscriptions in one or more channels.");
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
  my ($proxy_entitlement, @trash) = grep { $_->[1] eq 'Spacewalk Proxy' } @channel_families;
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
      if ($server->is_satellite) {
	$pxt->push_message(local_alert => <<EOQ);
This system is already registered as an Spacewalk.
A system cannot be both an RHN Proxy and an Spacewalk
EOQ
	return;
      }

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

sub satellite_entitlement_form {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  throw "User '" . $pxt->user->id . "' attempted to access satellite interface without permission."
    unless $pxt->user->org->entitled_satellite_families();

  my $sid = $pxt->param('sid');
  throw "no server id!" unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  my $cert_str = $server->satellite_cert();
  my $cert;

  # put this back in later when it won't hork the boxes...
  if ($cert_str) {
    eval {
      $cert = RHN::SatelliteCert->parse_cert($cert_str);
    };
    if ($@) {
      warn "parse_cert for server '$sid': $@";
    }
  }

  # the cert mis-parsed?  then deactivate satellite.
  if ($server->is_satellite() and not $cert) {
    $pxt->push_message(local_alert => 'This system has an invalid satellite certificate.  Please check your certificate and try again.');
    $server->deactivate_satellite();
  }

  my @channel_families = RHN::Channel->channel_entitlement_overview($pxt->user->org_id);
  my ($proxy_entitlement, @trash) = grep { $_->[1] eq 'Spacewalk Management Spacewalk' } @channel_families;
  my ($current_members,  $max_members) = ($proxy_entitlement->[2], $proxy_entitlement->[3]);

  my %subs;

  if ($server->is_satellite()) {
    $subs{sat_message} = 'This machine is a registered Spacewalk.';
    $subs{sat_cert} = PXT::HTML->htmlify_text($cert_str);
    $subs{sat_button} = PXT::HTML->submit(-name => 'deactivate_satellite', -value => 'Deactivate Spacewalk License');
  }
  elsif (!$max_members or ($current_members < $max_members)) {

    $subs{sat_message} = "Select your Spacewalk Certificate file or paste the contents into the text area below";

    $subs{sat_cert} = PXT::HTML->file(-name => 'sat-cert-file');
    $subs{sat_cert} .= "<p><strong>OR</strong></p>";
    $subs{sat_cert} .= PXT::HTML->textarea(-name => 'cert', -wrap => 'virtual', -rows => 6, -cols => 40);

    $subs{sat_button} = PXT::HTML->hidden(-name => 'activate_satellite', -value => 1)
      . PXT::HTML->submit(-name => 'modify_cert', -value => 'Update Certificate');
  }
  else {
    $subs{sat_message} = 'All Spacewalk subscriptions are currently being used.';
    $subs{sat_cert} = 'No license.';
    $subs{sat_button} = '';
  }

  $block = PXT::Utils->perform_substitutions($block, \%subs);

  return $block
}

sub satellite_entitlement_cb {
  my $pxt = shift;
  my %params = @_;

  throw "User '" . $pxt->user->id . "' attempted to access satellite interface without permission."
    unless $pxt->user->org->entitled_satellite_families();

  my $sid = $pxt->param('sid');
  throw "no server id!" unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  if ($pxt->dirty_param('deactivate_satellite')) {
    unless ($pxt->dirty_param('confirm_deactivation')) {
      my $redir = $pxt->dirty_param('deactivate_redirect');
      throw "param 'deactivate_redirect' needed but not provided"
	unless $redir;

      $pxt->redirect($redir . "?sid=$sid");
    }

    $server->deactivate_satellite();
    $pxt->push_message(site_info => sprintf("The server <strong>%s</strong> has been deactivated as an Spacewalk.", PXT::Utils->escapeHTML($server->name)));

  }
  elsif ($pxt->dirty_param('activate_satellite')) {

    if ($server->is_proxy) {
      $pxt->push_message(local_alert => <<EOQ);
This server is already registered as an RHN Proxy.
A system cannot be both an RHN Proxy and an Spacewalk
EOQ
      return;
    }

    my $cert;
    my $upload = $pxt->upload('sat-cert-file');

    if ($upload) {

      $cert = '';

      my $fh = $upload->fh;

      while (<$fh>) {
	$cert .= $_;
      }
    }
    elsif ($pxt->dirty_param('cert')) {
      $cert = $pxt->dirty_param('cert');
    }
    else {
      $pxt->push_message(local_alert =>'No certificate was provided.  Please supply a valid Spacewalk license certificate.');
      return;
    }

    # remove the magic pixie dust, yay!
    PXT::Utils->untaint(\$cert);

    # this won't be catching anything until we have some sort of parsing
    # *actually* going on here...
    my $transaction = RHN::DB->connect();

    eval {
      $server->activate_satellite($cert, $transaction);
      $transaction->commit;
    };
    if($@) {
      my $E = $@;
      $transaction->rollback;

      my %map =
	(
	 channel_family_no_subscriptions => "This activation would exceed your allowed Spacewalk subscriptions.",
	 invalid_sat_certificate => "Certificate invalid; please confirm it is correct and try again.",
	 no_management_slots => "You have no Management slots left to activate this satellite",
	 no_access_to_sat_channel => "You do not have permission to subscribe this system to the Spacewalk channel.",
	 no_sat_chan_for_version => "There is no available Spacewalk channel for this system's base channel.",
	 satellite_no_base_channel => "This system is not subscribed to a base channel.",
	 satellite_cert_too_old => "The certificate you are using is out of date; please contact your Red Hat representative for a new certificate.",
	 __default__ => "Unknown error activating satellite; please contact Spacewalk.",
	);

      $pxt->exception_message_map($E, %map);

      warn sprintf("Spacewalk certificate validation failed (%s); user (%d) for system (%d):\n%s",
		   $E, $pxt->user->id, $sid, ((split /[\n]/, $@)[0]));
    }
  }

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided"
    unless $redir;
  $pxt->redirect($redir . "?sid=$sid");
}

sub system_package_list_refresh_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  throw "no server id" unless $sid;

  my $earliest_date = RHN::Date->now->long_date;
  my $action_id = RHN::Scheduler->schedule_package_refresh(-org_id => $pxt->user->org_id,
							   -user_id => $pxt->user->id,
							   -earliest => $earliest_date,
							   -server_id => $sid);

  my $system = RHN::Server->lookup(-id => $sid);

  $pxt->push_message(site_info => sprintf("You have successfully scheduled a package profile refresh for <strong>%s</strong>.", PXT::Utils->escapeHTML($system->name)));
  return;
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

sub server_status_interface {
  my $pxt = shift;
  my %params = @_;

  my $system = $pxt->pnotes('server');
  die "no system!" unless $system;

  my $data = $system->applicable_errata_counts();

  $data->{ID} = $system->id;
  $data->{IS_ENTITLED} = $system->is_entitled;
  $data->{LAST_CHECKIN_DAYS_AGO} = $system->last_checked_in_days_ago;
  $data->{LOCKED} = $system->check_lock;

  my $session = RHN::Kickstart::Session->lookup(-sid => $system->id, -org_id => $pxt->user->org_id, -soft => 1);
  my $state = $session ? $session->session_state_label : '';
  $data->{KICKSTART_SESSION_ID} = ($session and $state ne 'complete' and $state ne 'failed') ? $session->id : undef;

  my $subst = system_status_info($pxt->user, $data);

  if ($subst->{link}) {
    $subst->{message} = "(" . PXT::HTML->link($subst->{link}, $subst->{message}) . ")";
  }

  if ($subst->{image_medium}) {
    $subst->{image_medium} = PXT::HTML->img(-src => $subst->{image_medium}, -alt => $subst->{status_str}, -title => $subst->{status_str});
  }

  if ($subst->{image}) {
    $subst->{image} = PXT::HTML->img(-src => $subst->{image}, -alt => $subst->{status_str}, -title => $subst->{status_str});
  }

  my $block = $params{__block__};

  $block = PXT::Utils->perform_substitutions($block, $subst);

  return $block;
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

sub admin_server_edit_form {
  my $pxt = shift;
  my %params = @_;

  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server" unless $server;

  # save for use by other tags
  $pxt->pnotes(server => $server);

  #  heh, this is why network information wasn't shown... used to be in server_details, but never made it here :-/
  my @netinfos = $server->get_net_infos;
  $pxt->pnotes('net_infos' => \@netinfos);

  my $block = $params{__block__};

  my %subst;

  foreach my $attrib (qw/id digital_server_id server_arch_id os release name description info org_id memory_swap memory_ram cpu_bogomips cpu_family cpu_nrcpu cpu_mhz base_channel_name base_channel_id/) {
    $subst{$attrib} = defined $server->$attrib() ? PXT::Utils->escapeHTML($server->$attrib()) : '';
  }

  foreach my $time (qw/created checkin/) {
    $subst{$time} = $pxt->user->convert_time($server->$time());
  }

  my $lock = $server->check_lock;
  if ($lock) {
    my $desc = "System is currently <strong>locked</strong>.";

    if ($lock->{USER_ID} and $lock->{REASON}) {
      my $u = RHN::User->lookup(-id => $lock->{USER_ID});
      $desc = sprintf "System has been <strong>locked</strong> by %s: %s.", $u->login, $lock->{REASON};
    }
    elsif ($lock->{USER_ID}) {
      my $u = RHN::User->lookup(-id => $lock->{USER_ID});
      $desc = sprintf "System has been <strong>locked</strong> by %s.", $u->login;
    }
    elsif ($lock->{REASON}) {
      my $u = RHN::User->lookup(-id => $lock->{USER_ID});
      $desc = sprintf "System has been <strong>locked</strong>: %s.", $lock->{REASON};
    }
    $desc .= "<br />" . PXT::HTML->link(sprintf("index.pxt?sid=%s&amp;pxt:trap=rhn:server_lock_cb&amp;lock=0", $server->id),
					"Unlock system.");

    $subst{system_locked} = $desc;
  }
  else {
    $subst{system_locked} = "System is not locked.<br />" .
      PXT::HTML->link(sprintf("index.pxt?sid=%s&amp;pxt:trap=rhn:server_lock_cb&amp;lock=1", $server->id),
		      "Lock system.");
  }

  my $applet_activate = $server->applet_activated();
  if ($applet_activate) {
    $subst{system_applet} = 'Activated.<br />';
    $subst{system_applet} .= PXT::HTML->link2(text => "Reactivate rhn-applet for Spacewalk usage.",
					      url => sprintf("index.pxt?sid=%s&amp;pxt:trap=rhn:activate_sat_applet_cb", $server->id),
					     );
  }
  else {
    $subst{system_applet} = 'Not activated.<br />';
    $subst{system_applet} .= PXT::HTML->link2(text => "Activate rhn-applet for Spacewalk usage.",
					      url => sprintf("index.pxt?sid=%s&amp;pxt:trap=rhn:activate_sat_applet_cb", $server->id),
					     );
  }

  $subst{html_description} = PXT::HTML->htmlify_text($server->description() || '');

  # hack because last_boot is NOT NULL in db :-/
  my $last_boot_time = $server->last_boot;
  if ($last_boot_time > 0) {
    $subst{last_boot} = RHN::Date->new(epoch => $last_boot_time)->long_date_with_zone($pxt->user);
  }
  else {
    $subst{last_boot} = "unknown";
  }

  $subst{bus_status} = $server->osa_status || "unknown";
  $subst{bus_status} = sprintf("<span class=\"osa-%s\">%s</span>", $subst{bus_status}, $subst{bus_status});

  my $osa_timestamps = $server->osa_timestamps;
  $subst{bus_last_ping} = '';

  if (not $osa_timestamps) {
    $subst{bus_modified} = $subst{bus_last_message} = "unknown";
  }
  else {
    $subst{bus_modified} = $osa_timestamps->{MODIFIED} ? $pxt->user->convert_time($osa_timestamps->{MODIFIED}) : "unknown";
    $subst{bus_last_message} = $osa_timestamps->{LAST_MESSAGE_TIME} ? $pxt->user->convert_time($osa_timestamps->{LAST_MESSAGE_TIME}) : "unknown";
    $subst{bus_last_ping} = $osa_timestamps->{LAST_PING_TIME} ? $pxt->user->convert_time($osa_timestamps->{LAST_PING_TIME}) : '';
  }

  if ($subst{bus_last_ping}) {
    $subst{bus_last_ping} = sprintf("Last pinged: %s <br />", $subst{bus_last_ping});
  }

  $subst{running_kernel} = $server->running_kernel() ? $server->running_kernel() : "unknown";

  my @ents = $server->entitlements;

  my $server_auto_update = lc $server->auto_update eq 'y';

  if ($pxt->user->org->is_paying_customer()) {
    if (scalar(@ents) and $server->has_feature('ftr_auto_errata_updates')) {
      $subst{auto_update_options} .= PXT::HTML->checkbox(-name => 'auto_update',
							 -value => 1,
							 -checked => ($server_auto_update ? 1 : 0));

      $subst{auto_update_options} .= "&#160; Automatic application of relevant errata";

      $subst{current_auto_update} = $server_auto_update ? "Yes" : "No";
    }
    elsif (not $server->has_feature('ftr_auto_errata_updates')) {
      $subst{auto_update_options} = 'Auto Errata Update not available for this system.';
      $subst{current_auto_update} = 'No';
    }
    else {
      $subst{auto_update_options} = 'Auto Errata Update not available for unentitled systems.';
      $subst{current_auto_update} = 'No';
    }
  }
  else {
    my $upsell_link = '';
    if ($pxt->user->is('org_admin') and (not PXT::Config->get('satellite'))) {
	$upsell_link = "<br />" . PXT::HTML->link("/rhn/account/SubscriptionManagement.do", "Buy Now") ;
    }

    $subst{auto_update_options} = 'Auto Errata Update only available for paying accounts' . $upsell_link;
    $subst{current_auto_update} = 'Auto Errata Update only available for paying accounts' . $upsell_link;
  }

  my $current_entitlements = join(', ', map { $pxt->user->org->slot_name($_->{LABEL}) } @ents) || 'none';
  $subst{current_entitlement} = $current_entitlements;

  $subst{entitled} = $subst{current_entitlement};

  if ($pxt->user->is('org_admin')) {
    $subst{base_entitlement} = base_entitlement_box($pxt, $server);
    $subst{addon_entitlements} = addon_entitlement_box($pxt, $server);
  }
  else {
    $subst{base_entitlement} = base_entitlement($pxt, $server);
    $subst{addon_entitlements} = addon_entitlements($pxt, $server);
  }

  my $global_notify = $pxt->user->get_pref('email_notify');

  # notifications default to yes; if there is no row, make sure we default to yes.
  my $errata_pref = $pxt->user->get_server_pref($sid, 'receive_notifications');

  if (not defined $errata_pref) {
    $errata_pref = 1;
  }
  else {
    $errata_pref ||= 0;
  }


  # include in summary default to yes...
  my $summary_pref = $pxt->user->get_server_pref($sid, 'include_in_daily_summary');
  if (not defined $summary_pref) {
    $summary_pref = 1;
  }
  else {
    $summary_pref ||= 0;
  }


  if ($current_entitlements ne 'none') {
    if (not $global_notify) {
      $subst{notification_options} = "Email Notifications disabled globally.";
      $subst{current_notification} = "Email Notifications disabled globally.";
    }
    else {

      if ($server->has_feature('ftr_errata_updates')) {
	$subst{notification_options} = PXT::HTML->checkbox(-name => 'receive_notifications', -value => 1, -checked => $errata_pref);
	$subst{notification_options} .= "\nReceive Notifications of Updates/Errata.<br />";
	$subst{current_notification} .= "Errata Email<br />" if $errata_pref;
      }

      # daily summary inclusion only for enterprise entitled systems
      if ($server->has_feature('ftr_daily_summary')) {
	$subst{notification_options} .= PXT::HTML->checkbox(-name => 'include_in_daily_summary', -value => 1, -checked => $summary_pref);
	$subst{notification_options} .= "\nInclude system in daily summary report calculations.";
	$subst{current_notification} .= "Daily Summary<br />" if $summary_pref;
      }
      else {
	$subst{notification_options} .= "<br />\nDaily Summary report requires a Management entitlement.<br />";
	my $upsell_link = '';
	if ($pxt->user->is('org_admin') and (not PXT::Config->get('satellite'))) {
	    $upsell_link = PXT::HTML->link("/rhn/account/SubscriptionManagement.do", "Buy Now") . "<br />" ;
	}
	$subst{notification_options} .= "$upsell_link";
      }
    }
  }
  else {
    $subst{notification_options} = "Notifications not available for unentitled systems.";
  }

  $subst{current_notification} = "None" if not $subst{current_notification};


  $subst{admin_server_formvars} = PXT::HTML->hidden(-name => "pxt:trap", -value => "rhn:admin_server_edit_cb");
  $subst{admin_server_formvars} .= PXT::HTML->hidden(-name => "sid", -value => $sid);

  if ($pxt->pnotes('server_details_subscribable_child_channels_seen')) {
    $subst{change_subscriptions_button} = PXT::HTML->submit(-name => "Change Subscriptions",
							    -value => "Change Subscriptions");
  }
  else {
    $subst{change_subscriptions_button} = "";
  }

  my @location;
  push @location, [ $server->location_machine ? "Machine " . $server->location_machine : (),
		    $server->location_room ? "Room " . $server->location_room : (),
		    $server->location_rack ? "Rack " . $server->location_rack : () ];

  push @location, [ $server->location_building ? "Building " . $server->location_building : () ];

  push @location, [ $server->location_address1 ? $server->location_address1 : () ];
  push @location, [ $server->location_address2 ? $server->location_address2 : () ];

  push @location, [ $server->location_city ? $server->location_city : (),
		    $server->location_state ? $server->location_state : (),
		    $server->location_country ? $server->location_country : (),
		  ];

  my @nonempty_locations = grep { scalar @$_ > 0 } @location;
  if (@nonempty_locations) {
    my $location_string;

    for my $loc (@nonempty_locations) {
      $location_string .= PXT::Utils->escapeHTML(join(", ", @$loc)) . "<br />";
    }
    $subst{location} .= $location_string;
  }
  else {
    $subst{location} = "none";
  }

  if ($subst{location} eq 'none') {
    $subst{location} = '<span class="no-details">(none)</span>'
  }

  # save this for future use on the main sdc page...
  my @server_channels = $server->server_channels();
  $pxt->pnotes('server_channels', \@server_channels);


  $block = PXT::Utils->perform_substitutions($block, \%subst);

  #reuse server location code
  $block = server_location($pxt, (__block__ => $block));
  return $block;
}

sub server_virtualization_details {
  my $pxt = shift;
  my %params = @_;
  my $ret = '';

  my $server = $pxt->pnotes('server');

  throw "No server." unless $server;

  my %subst;

  my $virt_details = $server->virtual_guest_details();

  return unless $virt_details;

  my $block = $params{__block__};

  $subst{virtualization_type} = $virt_details->{TYPE_NAME} || "None";
  $subst{virtualization_uuid} = $virt_details->{UUID} || "Unknown";
  $subst{virtualization_host} = "Unknown";

  if ($virt_details->{HOST_SYSTEM_ID}) {
    if ($pxt->user->verify_system_access($virt_details->{HOST_SYSTEM_ID})) {
      $subst{virtualization_host} =
        PXT::HTML->link2(text => $virt_details->{HOST_SYSTEM_NAME},
          url => "/rhn/systems/details/Overview.do?sid=" . $virt_details->{HOST_SYSTEM_ID});

    }
    else {
      $subst{virtualization_host} = sprintf("%s (%d)",
                                            $virt_details->{HOST_SYSTEM_NAME},
                                            $virt_details->{HOST_SYSTEM_ID});

    }
  }

  my $html = PXT::Utils->perform_substitutions($block, \%subst);

  return $html;
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

sub server_edit_location_cb {
  my $pxt = shift;
  my $transaction = shift;

  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  my $server = $transaction || RHN::Server->lookup(-id => $sid);

  die "Orgs for admin server edit mistatch (admin: @{[$pxt->user->org_id]} != @{[$server->org_id]}"
    unless $pxt->user->org_id == $server->org_id;

  foreach my $form_var (qw/country state city address1 address2 building room rack/) {
    my $function = 'location_' . $form_var;
    $server->$function($pxt->dirty_param($form_var));
  }

  $server->commit unless $transaction;

  return $server;
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

sub admin_server_edit_cb {
  my $pxt = shift;

  my @extra_messages;

  my $sid = $pxt->param('sid');
  die "no server id" unless ($sid);

  my $server = RHN::Server->lookup(-id => $sid);

  my $trunc_name = substr($pxt->dirty_param('name'), 0, 128);
  $trunc_name =~ s/^\s+//;
  $trunc_name =~ s/\s+$//;

  unless (length $trunc_name > 2) {
    $pxt->push_message(local_alert => "A system name must be at least three characters in length.");
    return;
  }

  unless ($trunc_name =~ /^[\x20-\x7e]+$/) {
    $pxt->push_message(local_alert => "Desired System Name contains invalid characters. In addition to alphanumeric characters, '-', '_', '.', and '\@' are allowed. Please try again");
    return;
  }


  $server->name($trunc_name);
  my $trunc_desc = substr($pxt->dirty_param('description'), 0, 256);
  $server->description($trunc_desc);

  $pxt->user->set_server_pref($server->id,
			      'receive_notifications',
			      $pxt->dirty_param('receive_notifications') ? 1 : 0, 1);
  $pxt->user->set_server_pref($server->id,
			      'include_in_daily_summary',
			      ($pxt->dirty_param('include_in_daily_summary') and
			       $server->has_feature('ftr_daily_summary')
			      ) ? 1 : 0, 1);

  if ($pxt->user->is('org_admin')) {
    handle_system_entitlement_change($pxt, $server);
  }

  $server = server_edit_location_cb($pxt, $server);

  my $auto_update = $pxt->dirty_param('auto_update') ? 'Y' : 'N';

  if (($auto_update ne uc $server->auto_update) and $server->has_feature('ftr_auto_errata_updates')) {
    $server->auto_update($auto_update);

# only do the auto update if we're switching to an auto-updated enterprise slot system...
    if ($auto_update eq 'Y') {
      RHN::Scheduler->schedule_all_errata_updates_for_system(-earliest => RHN::Date->now->long_date,
							     -org_id => $pxt->user->org_id,
							     -user_id => $pxt->user->id,
							     -server_id => $server->id,
							    );

      push @extra_messages, $server->name . " will be <strong>fully updated</strong> in accordance with Auto Errata Update preference.";
    }
  }

  $server->commit;
  $pxt->push_message(site_info => "System properties changed for <strong>" . $server->name . "</strong>.");

  foreach my $message (@extra_messages) {
    $pxt->push_message(site_info => $message);
  }
  $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
}

# Not a sniglet - handle system entitlement changes from server
# properties edit page.
sub handle_system_entitlement_change {
  my $pxt = shift;
  my $server = shift;

  my $base_entitlement = $pxt->dirty_param('base_entitlement');

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  eval {
    my $changed = 0;

    my %addon_entitlements = map { ($_, 1) } $pxt->dirty_param('addon_entitlements');
    my %current_entitlements = map { ($_->{LABEL}, $_) }
      grep { $_->{IS_BASE} eq 'N' } $server->entitlements;

    my $has_monitoring = ( grep { $_ eq 'monitoring_entitled' } keys %current_entitlements ) ? 1 : 0;
    my $removed_monitoring = 0;
    my @sat_clusters;

    if ($has_monitoring) {
      @sat_clusters = RHN::Server->sat_clusters_for_system($server->id);
    }

    foreach my $ent (keys %addon_entitlements) {
      unless (exists $current_entitlements{$ent}) {
	$server->entitle_server($ent);
	$changed = 1;
      }
    }

    foreach my $ent (keys %current_entitlements) {
      unless (exists $addon_entitlements{$ent}) {
	if ($ent eq 'monitoring_entitled') {
	  $removed_monitoring = 1;
	}
	$server->remove_entitlement($ent);
	$changed = 1;
      }
    }

    if ($base_entitlement eq 'unentitle') {
      $changed = 1;

      if ($has_monitoring) {
	$removed_monitoring = 1;
      }

      $server->unentitle_server();
    } elsif ($base_entitlement ne 'none' and
	     not $server->has_entitlement($base_entitlement)) {
      $changed = 1;

      if ($has_monitoring) {
	$removed_monitoring = 1;
      }

      $server->unentitle_server();
      $server->entitle_server($base_entitlement);
    }

    if ($changed and $server->has_feature('ftr_snapshotting')) {
      RHN::Server->snapshot_server(-server_id => $server->id,
				   -reason => "Entitlement change");
    }

    if ($removed_monitoring) {
      $server->schedule_sat_cluster_push($pxt->user->id, @sat_clusters);
    }
  };

  if ($@) {
    my $E = $@;
    $transaction->nested_rollback();

    if (ref $E and catchable($E)) {
      if ($E->is_rhn_exception('servergroup_max_members')) {
	$pxt->push_message(local_alert => sprintf("You do not have enough entitlements to entitle <strong>%s</strong>.", PXT::Utils->escapeHTML($server->name)));
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
  else {
    $transaction->nested_commit();
  }

  return;
}

sub server_outdated_package_list_xmlrpc {
  my $pxt = shift;
  my $params = shift;

  my ($token, $sid) = @{$params}{qw/token server_id/};
  $pxt->user->verify_system_access($sid) or die "No permissions to server";

  my $server = RHN::Server->lookup(-id => $sid);

  my $unused;
  my @rows = $server->outdated_package_overview(-lower => 0, -upper => 10000, -total_rows => \$unused);

  my @ret = map { { (nvre => $_->[4], advisory => $_->[6] || '', errata_id => $_->[5], name_id => $_->[2], evr_id => $_->[3]) } } @rows;

  return \@ret;
}

sub server_schedule_package_update_xmlrpc {
  my $pxt = shift;
  my $params = shift;
  my ($token, $sid, $name_id, $evr_id) = @{$params}{qw/token server_id name_id evr_id/};

  $pxt->user->verify_system_access($sid) or die "No permissions to server";
  my $server = RHN::Server->lookup(-id => $sid);

  my $package_id = RHN::Package->guestimate_package_id(-server_id => $sid, -name_id => $name_id, -evr_id => $evr_id);

  my $earliest_date = RHN::Date->now->long_date;
  my $action_id = RHN::Scheduler->schedule_package_install(-org_id => $pxt->user->org_id,
							   -user_id => $pxt->user->id,
							   -earliest => $earliest_date,
							   -package_id => $package_id,
							   -server_id => $server->id);

  return $action_id;
}

sub server_schedule_errata_update_xmlrpc {
  my $pxt = shift;
  my $params = shift;
  my ($token, $sid, $eid) = @{$params}{qw/token server_id errata_id/};

  $pxt->user->verify_system_access($sid) or die "No permissions to server";
  my $server = RHN::Server->lookup(-id => $sid);

  my $earliest_date = RHN::Date->now->long_date;
  my ($action_id) = RHN::Scheduler->schedule_errata_updates_for_system(-org_id => $pxt->user->org_id,
								       -user_id => $pxt->user->id,
								       -earliest => $earliest_date,
								       -errata_ids => [ $eid ],
								       -server_id => $server->id);

  return $action_id;
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

sub server_location {
  my $pxt = shift;
  my %params = @_;
  my $sid = $pxt->param('sid');
  die "no server id" unless ($sid);

  # if possible, reuse existing server object
  my $server = RHN::Server->lookup(-id => $sid);

  my %subst;

  $subst{country} = defined $server->location_country ? $server->location_country : "";

  $subst{state} = defined $server->location_state ? $server->location_state : "";

  $subst{city} = defined $server->location_city ? $server->location_city : "";

  $subst{address1} = defined $server->location_address1 ? $server->location_address1 : "";
  $subst{address2} = defined $server->location_address2 ? $server->location_address2 : "";

  $subst{building} = defined $server->location_building ? $server->location_building : "";

  $subst{room} = defined $server->location_room ? $server->location_room : "" ;
  $subst{rack} = defined $server->location_rack ? $server->location_rack : "" ;

  $subst{machine} = defined $server->location_machine ? $server->location_machine : "";

  PXT::Utils->escapeHTML_multi(\%subst);

  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
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

sub tri_state_system_entitlement_list {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $html = '';

  my $counter = 1;

  my @all_entitlements = RHN::Entitlements->valid_system_entitlements_for_org($pxt->user->org_id);
  my @addon_entitlements = grep { $_->{IS_BASE} eq 'N' } @all_entitlements;

  foreach my $ent (@addon_entitlements) {
    $counter++;
    my %subst;

    $subst{entitlement_name} = $ent->{LABEL};
    $subst{entitlement_label} = $pxt->user->org->slot_name($ent->{LABEL});
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

sub server_brb_checkin_message {
  my $pxt = shift;
  my %params = @_;

  my $server = RHN::Server->lookup(-id => $pxt->param('sid'));

  my $last_checkin = new RHN::Date(string => $server->checkin);
  my $now = RHN::Date->now;

  # last checkin times...
  my $checkin_rel = PXT::Utils->relative_time_diff($last_checkin->epoch, $now->epoch);
  my $prettythen = $pxt->user->convert_time($server->checkin);
  $prettythen .= ' (' . PXT::Utils->pretty_relative_time($checkin_rel, qw/day hour minute/) . ' ago)';


  # current rhn time
  my $prettynow = $now->long_date_with_zone($pxt->user);

  # expected checkin time...
  my $next_checkin = $last_checkin->clone;
  $next_checkin->add(hours => 2);

  my $next_expected_rel = PXT::Utils->relative_time_diff($now->epoch, $next_checkin->epoch);
  my $prettysoon = $next_checkin->long_date_with_zone($pxt->user);

  my $time_str = ' from now';
  $time_str = ' ago' if ($next_expected_rel->{direction} < 0);
  $prettysoon .= ' (' . PXT::Utils->pretty_relative_time($next_expected_rel, qw/day hour minute/) . " $time_str)";


  if ($server->last_checked_in_days_ago > PXT::Config->get('system_checkin_threshold')) {
    return <<EOH;
<table border="0" cellspacing="0" cellpadding="6">
  <tr><td>System last check-in:</td><td>$prettythen</td></tr>
  <tr><td>Current RHN time:</td><td>$prettynow</td></tr>
</table>
<br />
<strong>NOTE:</strong> This system has not checked into the Spacewalk recently.  Since a system cannot be updated if it does not check in to RHN, it is unlikely that this action will succeed.
<br /><br />
Please check the system and ensure rhnsd is running (<a href="/help/faq.pxt#15">more info</a>).  If it is failing to run, please <a href="/help/contact.pxt">contact us</a>.
<br />
EOH
  }
  else {
    return <<EOH
<table border="0" cellspacing="0" cellpadding="6">
  <tr><td>System last check-in:</td><td>$prettythen</td></tr>
  <tr><td>Current RHN time:</td><td>$prettynow</td></tr>
  <tr><td>Expected check-in time:</td><td>$prettysoon</td></tr>
</table>
EOH
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

sub system_base_channel_select_cb {
  my $pxt = shift;
  my $new_base = $pxt->dirty_param('system_base_channel') || 0;
  my $sid = $pxt->param('sid');

  my $server = RHN::Server->lookup(-id => $sid);

  if ($server->is_proxy() or $server->is_satellite()) {
    $pxt->push_message(local_alert => 'You may not change the base channel of an Spacewalk Proxy or Spacewalk.');
    $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
  }


  if ($new_base and not $pxt->user->verify_channel_subscribe($new_base)) {
      my $error_msg = <<EOM;
You no longer have subscription access to the base channel choice you selected.<br />
Please review your selection and try again.
EOM
      $pxt->push_message(local_alert => $error_msg);
      $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
  }

  my $current_base = $server->base_channel_id || 0;

  eval {
    $server->change_base_channel($new_base);

    if ($server->has_feature('ftr_snapshotting')) {
      RHN::Server->snapshot_server(-server_id => $server->id,
				   -reason => "Base channel change");
    }
  };
  if ($@) {
    my $E = $@;
    if (ref $E and catchable($E)) {
      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
	$pxt->push_message(local_alert => "This assignment would exceed your allowed subscriptions.");
	return;
      }
      elsif ($E->is_rhn_exception('channel_subscribe_no_consent')) {
	$pxt->push_message(local_alert => "You have not agreed to the license for this channel.");
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

  if ($current_base != $new_base) {
    $pxt->push_message(site_info => sprintf('Base channel changed for <strong>%s</strong>.', 
					    PXT::Utils->escapeHTML($server->name)));
  }
  return;
}

sub entitlement_count {
  my $pxt = shift;
  my %params = @_;

  my $ent_data = $pxt->user->org->entitlement_data;

  my ($ret, $ret_wg, $ret_prov, $ret_mon, $ret_nonlinux);

  $ret = <<EOQ;
<h3>Base Entitlements</h3>
<div class="page-content">
EOQ

  if (not PXT::Config->get("satellite")) {
    $ret .= sprintf('%s Service: You have <strong>%d subscription%s</strong>',
		    $pxt->user->org->basic_slot_name(),
		    $ent_data->{sw_mgr_entitled}->{max},
		    $ent_data->{sw_mgr_entitled}->{max} == 1 ? '' : 's',
		   );
    $ret .= sprintf(', and you have <strong>%d system%s subscribed</strong>.<br/>',
		    $ent_data->{sw_mgr_entitled}->{used},
		    $ent_data->{sw_mgr_entitled}->{used} == 1 ? '' : 's');
  }

  $ret_wg .= sprintf('Management Service: You have <strong>%d subscription%s</strong>',
		     $ent_data->{enterprise_entitled}->{max},
		     $ent_data->{enterprise_entitled}->{max} == 1 ? '' : 's');

  $ret_wg .= sprintf(', and you have <strong>%d system%s subscribed</strong>.<br/>',
		     $ent_data->{enterprise_entitled}->{used},
		     $ent_data->{enterprise_entitled}->{used} == 1 ? '' : 's');

  $ret_prov .= sprintf('Provisioning Service: You have <strong>%d subscription%s</strong>',
		     $ent_data->{provisioning_entitled}->{max},
		     $ent_data->{provisioning_entitled}->{max} == 1 ? '' : 's');
  $ret_prov .= sprintf(', and you have <strong>%d system%s subscribed</strong>.<br/>',
		     $ent_data->{provisioning_entitled}->{used},
		     $ent_data->{provisioning_entitled}->{used} == 1 ? '' : 's');

  $ret_mon .= sprintf('Monitoring Service: You have <strong>%d subscription%s</strong>',
		     $ent_data->{monitoring_entitled}->{max},
		     $ent_data->{monitoring_entitled}->{max} == 1 ? '' : 's');
  $ret_mon .= sprintf(', and you have <strong>%d system%s subscribed</strong>.<br/>',
		     $ent_data->{monitoring_entitled}->{used},
		     $ent_data->{monitoring_entitled}->{used} == 1 ? '' : 's');

  if ($ent_data->{enterprise_entitled}->{max} > 0) {
    $ret .= $ret_wg;
  }

  $ret .= "</div>\n";
  if ($ent_data->{provisioning_entitled}->{max} > 0 or
      $ent_data->{monitoring_entitled}->{max} > 0) {
    $ret .= <<EOQ;
<h3>Add-On Entitlements</h3>
<div class="page-content">
EOQ
  if ($ent_data->{provisioning_entitled}->{max} > 0) {
    $ret .= $ret_prov;
  }
  if ($ent_data->{monitoring_entitled}->{max} > 0) {
    $ret .= $ret_mon;
  }
    $ret .= "</div>\n";
  }
  return $ret;
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

sub add_filenames_to_set_cb {
  my $pxt = shift;

  my $filenames = $pxt->dirty_param('input_filenames');

  my @filenames = split(/,\s*/, $filenames);

  my $errors;

  foreach my $file (@filenames) {
    my $errmsg = RHN::ConfigFile->validate_path_name($file);
    if ($errmsg) {
      $pxt->push_message(local_alert => sprintf('Invalid path <strong>%s</strong>: %s', PXT::Utils->escapeHTML($file), $errmsg));
      $errors++;
    }
  }

  return if $errors;

  my $set_label = 'selected_configfilenames';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  foreach my $file (@filenames) {
    $set->add(RHN::ConfigFile->path_to_id($file));
  }

  $set->commit;

  my $sid = $pxt->param('sid');
  my $uri = $pxt->uri;

  $pxt->redirect($uri . '?sid=' . $sid);
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

sub check_config_client {
  my $pxt = shift;

  my $server = RHN::Server->lookup(-id => $pxt->param('sid'));

  # can't just push_message since there are odd redirects going on with the navi selected node code
  if (not $server->client_capable('configfiles.deploy')) {
    return '<div class="local-alert">This system does not have the "rhncfg-actions" package; scheduled actions will fail until it is installed.</div>';
  }
  else {
    return '';
  }
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

  my $earliest_date = RHN::Date->now->long_date;

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
