#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

use PXT::Config ();
use PXT::Utils;
use PXT::HTML;


use RHN::Server;
use RHN::Set;
use RHN::Exception;
use RHN::Channel;
use RHN::ServerActions;
use RHN::Form;
use RHN::Form::Widget::CheckboxGroup;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::Submit;
use RHN::Form::ParsedForm;
use RHN::SatelliteCert;
use RHN::Kickstart::Session;

use Sniglets::Forms;
use Sniglets::HTML;
use Sniglets::ServerActions;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-up2date-at-least' => \&up2date_at_least);

  $pxt->register_tag('rhn-server-prefs-conf-list' => \&server_prefs_conf_list);
  $pxt->register_tag('rhn-server-name' => \&server_name, 2);

  $pxt->register_tag('rhn-tri-state-system-pref-list' => \&tri_state_system_pref_list);

  $pxt->register_tag('rhn-server-history-event-details' => \&server_history_event_details);

  $pxt->register_tag('rhn-proxy-entitlement-form' => \&proxy_entitlement_form);

  $pxt->register_tag('rhn-system-activation-key-form' => \&system_activation_key_form);

  $pxt->register_tag('rhn-remote-command-form' => \&remote_command_form);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:reboot_server_cb' => \&reboot_server_cb);

  $pxt->register_callback('rhn:server_prefs_form_cb' => \&server_prefs_form_cb);

  $pxt->register_callback('rhn:ssm_change_system_prefs_cb' => \&ssm_change_system_prefs_cb);

  $pxt->register_callback('rhn:system-activation-key-cb' => \&system_activation_key_cb);

  $pxt->register_callback('rhn:remote-command-cb' => \&remote_command_cb);
  $pxt->register_callback('rhn:package-action-command-cb' => \&package_action_command_cb);
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
    unless ($pxt->user->org->has_channel_family_entitlement('rhn-proxy') or not PXT::Config->get('subscribe_proxy_channel'));

  my $sid = $pxt->param('sid');
  throw "no server id!" unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  my %subs;

  if ($server->is_proxy()) {
    my @evr = $server->proxy_evr;
    my $version = $evr[1];

    $subs{version} = $version;

  	$subs{proxy_message} = "This machine is currently a licensed Red Hat Satellite Proxy (v$version).";
  } else {
    $subs{proxy_message} = "<div class=\"alert alert-danger\">WebUI Spacewalk Proxy installer is obsoleted since version 5.3. Please use command line installer from package spacewalk-proxy-installer.</div>";
  }

  $block = PXT::Utils->perform_substitutions($block, \%subs);
  return $block;
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

sub system_locked_info {
  my $user = shift;
  my $data = shift;

  my $ret = {};
  if ($data->{LOCKED}) {
    $ret->{icon} = 'fa fa-1-5x spacewalk-icon-locked-system';
    $ret->{status_str} = 'System locked';
    $ret->{status_class} = 'system-status-locked';
    $ret->{message} = 'more info';
    $ret->{link} = Sniglets::HTML::render_help_link(-user => $user,
                                                   -href => 's1-sm-systems.html#S3-SM-SYSTEM-DETAILS');

  }
  return $ret;
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
    $ret->{icon} = 'system-unentitled';
    $ret->{status_str} = 'System not entitled';
    $ret->{status_class} = 'system-status-unentitled';

    if ($user->is('org_admin')) {
      $ret->{message} = 'entitle it here';
      $ret->{link} = "/network/systems/details/edit.pxt?sid=${sid}";
    }
  }
  elsif ($data->{LAST_CHECKIN_DAYS_AGO} > PXT::Config->get('system_checkin_threshold')) {
    $ret->{icon} = 'system-unknown';
    $ret->{status_str} = 'System not checking in with R H N';
    $ret->{status_class} = 'system-status-awol';
    $ret->{message} = 'more info';
    $ret->{link} = Sniglets::HTML::render_help_link(-user => $user,
						    -href => 's1-sm-systems.html#S3-SM-SYSTEM-LIST-INACT');
  }
  elsif ($data->{KICKSTART_SESSION_ID}) {
    $ret->{icon} = 'system-kickstarting';
    $ret->{status_str} = 'Kickstart in progress';
    $ret->{status_class} = 'system-status-kickstart';
    $ret->{message} = 'view progress';
    $ret->{link} = "/rhn/systems/details/kickstart/SessionStatus.do?sid=${sid}";
  }
  elsif (not ($errata_count or $data->{OUTDATED_PACKAGES}) and not $package_actions_count) {
    $ret->{icon} = 'system-ok';
    $ret->{status_str} = 'System is up to date';
    $ret->{status_class} = 'system-status-up-to-date';
  }
  elsif ($errata_count and not RHN::Server->unscheduled_errata($sid, $user->id)) {
    $ret->{icon} = 'action-pending';
    $ret->{status_str} = 'All updates scheduled';
    $ret->{status_class} = 'system-status-updates-scheduled';
    $ret->{message} = 'view actions';
    $ret->{link} = "/network/systems/details/history/pending.pxt?sid=${sid}";
  }
  elsif ($actions_count) {
    $ret->{icon} = 'action-pending';
    $ret->{status_class} = 'system-status-updates-scheduled';
    $ret->{status_str} = 'Actions scheduled';
    $ret->{message} = 'view actions';
    $ret->{link} = "/network/systems/details/history/pending.pxt?sid=${sid}";
  }
  elsif ($data->{SECURITY_ERRATA}) {
    $ret->{icon} = 'system-crit';
    $ret->{status_str} = 'Critical updates available';
    $ret->{status_class} = 'system-status-critical-updates';
    $ret->{message} = 'update now';
    $ret->{link} = "/rhn/systems/details/ErrataConfirm.do?all=true&amp;sid=${sid}";
  }
  elsif ($data->{OUTDATED_PACKAGES}) {
    $ret->{icon} = 'system-warn';
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

sub server_history_event_details {
  my $pxt = shift;
  my %params = @_;

  croak "need server and history ids!" unless ($pxt->param('sid') and $pxt->param('hid'));

  my $event = RHN::Server->lookup_server_event($pxt->param('sid'), $pxt->param('hid'));

  return PXT::Utils->perform_substitutions($params{__block__}, $event->render($pxt->user));

  return $params{__block__};
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
#  my $message = sprintf(<<EOM, $server->name, $server->name, $action_id);
#Reboot scheduled for system <strong>%s</strong> for $pretty_earliest_date.  To cancel the reboot, remove <strong>%s</strong> from <a href="/rhn/schedule/InProgressSystems.do?aid=%d"><strong>the list of systems to be rebooted</strong></a>.
#EOM
#
#  $pxt->push_message(site_info => $message);
  $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid&message=system.reboot.scheduled&messagep1=" . $server->name . "&messagep2=" . $pretty_earliest_date . "&messagep3=" . $action_id);
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

	RHN::Scheduler->schedule_all_errata_for_systems(-earliest => RHN::Date->now_long_date,
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

    $pxt->redirect('landing.pxt');
  }
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
    my $token = RHN::Token->create_token;
    $token->user_id($pxt->user->id);
    $token->org_id($pxt->user->org_id);
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
