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

package Sniglets::ServerActions;

use Carp;
use Data::Dumper;

use RHN::Action;
use RHN::Set;
use RHN::Scheduler;
use PXT::HTML;
use RHN::ConfigChannel;

use PXT::Utils;
use RHN::Utils;
use Date::Parse;

use RHN::Exception;

use POSIX;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-raw-script-output' => \&raw_script_output);
  $pxt->register_tag('rhn-schedule-action-interface' => \&schedule_action_interface, 2);

  $pxt->register_tag('rhn-reschedule-form-if-failed-action' => \&reschedule_form_if_failed_action);
  $pxt->register_tag('rhn-latest-config-actions' => \&latest_config_actions);

  $pxt->register_tag('rhn-package-event-result' => \&package_event_result);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:server_set_errata_set_actions_cb' => \&server_set_errata_set_actions_cb);

  # currently used for mass deletes, mass pkg/hw prof updates, etc...
  $pxt->register_callback('rhn:server_set_actions_cb' => \&server_set_actions_cb);

  $pxt->register_callback('rhn:reschedule_action_cb' => \&reschedule_action_cb);

  $pxt->register_callback('rhn:sscd_reboot_servers_cb' => \&sscd_reboot_servers_cb);

  $pxt->register_callback('rhn:schedule_config_action_cb' => \&schedule_config_action_cb);
  $pxt->register_callback('rhn:add_managed_files_to_set_cb' => \&add_managed_files_to_set_cb);
  $pxt->register_callback('rhn:add_managed_filenames_to_set_cb' => \&add_managed_filenames_to_set_cb);
  $pxt->register_callback('rhn:schedule_ssm_config_action_cb' => \&schedule_ssm_config_action_cb);

}

sub raw_script_output {
  my $pxt = shift;
  my $aid = $pxt->param('hid');
  my $sid = $pxt->param('sid');

  my $action = RHN::Action->lookup(-id => $aid);
  my $output = $action->script_server_results($sid);
  $output = $output->{OUTPUT};

  $pxt->manual_content(1);

  $pxt->content_type('text/plain; charset=UTF-8');
  $pxt->header_out('Content-Length' => length $output);
  $pxt->send_http_header;

  $pxt->print($output);
}

sub sscd_reboot_servers_cb {
  my $pxt = shift;

  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  my $action_id;

  my $set_label = $pxt->dirty_param('set_label') || 'system_list';
  my $system_set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  $action_id = RHN::Scheduler->sscd_schedule_reboot(-org_id => $pxt->user->org_id,
						    -user_id => $pxt->user->id,
						    -earliest => $earliest_date,
						    -server_set => $system_set);

  my $system_count = $system_set->contents;
  my $message = sprintf(<<EOM, $system_count, $system_count == 1 ? '' : 's', $action_id);
Reboot scheduled for <strong>%d</strong> system%s.  To cancel the reboot, remove the desired systems from the <a href="/rhn/schedule/InProgressSystems.do?aid=%d"><strong>list of systems</strong></a> to be rebooted.
EOM
  $pxt->push_message(site_info => $message);

  $pxt->redirect('/network/systems/ssm/misc/index.pxt');
}

sub schedule_action_interface {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__} || $pxt->include('/network/components/schedule_action-interface.pxi');

  my %subst;

  $subst{date_selection} = date_pickbox($pxt);

  $subst{button} = PXT::HTML->submit(-name => $params{action},
				     -value => $params{label});
  $subst{button} .= PXT::HTML->hidden(-name => 'pxt:trap', -value => $params{callback});
  my $passthrough = $params{passthrough};

  if ($passthrough) {
    $subst{button} .= PXT::HTML->hidden(-name => $passthrough, -value => $pxt->passthrough_param($passthrough));
  }

  $block = PXT::Utils->perform_substitutions($block, \%subst);

  return $block;
}

sub reschedule_form_if_failed_action {
  my $pxt = shift;
  my %params = @_;

  my $action_id = $pxt->param('hid');
  my $sid = $pxt->param('sid');

  $pxt->user->verify_action_access($action_id)
      or $pxt->redirect('/network/permission.pxt');

  my $action = RHN::Action->lookup(-id => $action_id);
  return '' unless $action;

  my $reschedule_text = '';

  if ($action->get_server_status($sid) eq 'Failed') {
    $reschedule_text = $pxt->include('/network/components/systems/reschedule_action_form.pxi');

    my $prereq = $action->prerequisite();

    if ($prereq) {
      my $prereq_action = RHN::Action->lookup(-id => $prereq);

      unless ($prereq_action->get_server_status($sid) eq 'Completed') {
	my $prior_action = PXT::HTML->link2(text => 'prior action',
					    url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=$prereq",
					   );

	$reschedule_text = "This action requires the successful completion of a $prior_action before it can be rescheduled."
      }
    }

    return PXT::Utils->perform_substitutions($params{__block__}, { reschedule_info => $reschedule_text });
  }

  return '';
}

my @months = qw/January February March April May June July August September October November December/;

sub date_pickbox {
  my $pxt = shift;
  my %params = @_;

  my $prefix = $params{prefix} || '';
  my $blank = $params{start_blank} || undef;

  # 1 == +1, which means this year + 1
  # 0 means this year
  # -1 means last year
  my @year_modifiers = $params{years} ? split /[\s,;]/, $params{years} : (0, 1);

  my $ret;
  my $date;
  if ($params{'preserve'}) {
    my $epoch = Sniglets::ServerActions->parse_date_pickbox($pxt,
							    prefix    => $prefix,
							    long_date => 0,
							   );
    $epoch ||= time;
    $date = new RHN::Date(epoch => $epoch, user => $pxt->user);
  }
  else {
    $date = new RHN::Date(now => 1, user => $pxt->user);
  }

  my @month_list = map { [ $months[$_], $_ + 1 ] } 0..11;

  if ($blank) {
    foreach (@month_list) {
      $_->[2] = 0;
    }
    unshift @month_list, ['Month','', 1];
  }
  else {
    foreach (@month_list) {
      $_->[2] = ($_->[1] == $date->month);
    }
  }

  $ret .= PXT::HTML->select(-name => "${prefix}month",
			    -size => 1,
			    -options => [ @month_list ]);

  my @days = map { [ $_, $_, 0] } 1..31;

  if ($blank) {
    foreach (@days) {
       $_->[2] = 0;
     }
    unshift @days, ['Day', '', 1];
  }
  else {
     foreach (@days) {
       $_->[2] = ($_->[1] == $date->day ? 1 : 0);
     }
  }

  $ret .= PXT::HTML->select(-name => "${prefix}day",
			    -size => 1,
			    -options => [@days]);

  my $cur_yr = $date->year;

  my @years;
  foreach my $modifier (@year_modifiers) {
    my $year = ($cur_yr + $modifier);
    push @years, [$year, $year, 0];
  }

  unshift @years, ['Year', '', 1] if $blank;

  $years[0]->[2] = 1;

  $ret .= PXT::HTML->select(-name => "${prefix}year",
			    -size => 1,
			    -options => [ @years ],
			   );

  $ret .= '&#160;';

  my @hours;

  foreach my $hour (1 .. 12) {
    my $date_hour = $date->hour % 12 || "12";
    push @hours, [ $hour, $hour, $hour == $date_hour ? 1 : 0 ];
  }

  unshift @hours, ['Hour', '', 1] if $blank;

  $ret .= PXT::HTML->select(-name => "${prefix}hour",
			    -size => 1,
			    -options => \@hours,
			   );

  $ret .= ':';

  my @minutes;

  foreach my $minute ("00" .. "59") {
    push @minutes, [ $minute, $minute, $minute == $date->minute ? 1 : 0 ];
  }

  unshift @minutes, ['Minute', '', 1] if $blank;

  $ret .= PXT::HTML->select(-name => "${prefix}minute",
			    -size => 1,
			    -options => \@minutes,
			   );

  my $pm = $date->hour > 11 ? 1 : 0;

  $ret .= PXT::HTML->select(-name => "${prefix}am_pm",
			    -size => 1,
			    -options => [ [ 'AM', 'AM', $pm ? 0 : 1 ],
					  [ 'PM', 'PM', $pm ? 1 : 0 ] ]);

  $ret .= " " . $pxt->user->get_tz_str;

  return $ret;
}

# helper function for determining the scheduled date from rhn-date-pickbox
sub parse_date_pickbox {
  my $class = shift;
  my $pxt = shift;
  #my $prefix = shift || '';
  my %params = @_;

  my $prefix = defined $params{prefix} ? $params{prefix} : '';
  my $long_date = defined $params{long_date} ? $params{long_date} : 1;

  my @vars = (qw/month day year hour minute am_pm/);

  if (grep {not $pxt->dirty_param("${prefix}$_")} @vars) {
    return undef;
  }

  my $hour = $pxt->dirty_param("${prefix}hour");
  my $am_pm = $pxt->dirty_param("${prefix}am_pm");

  if ($am_pm eq 'AM') {
    $hour = 0 if $hour == 12;
  }
  elsif ($am_pm eq 'PM') {
    $hour += 12;
    $hour = 12 if $hour == 24;
  }
  else {
    throw "No ${prefix}am_pm parameter in call to parse_date_pickbox";
  }

  my $scheduled_time = RHN::Date->construct(year => $pxt->dirty_param("${prefix}year"),
					    month => $pxt->dirty_param("${prefix}month"),
					    day => $pxt->dirty_param("${prefix}day"),
					    hour => $hour,
					    minute => $pxt->dirty_param("${prefix}minute"),
					    second => 0,
					    time_zone => $pxt->user->get_timezone);

  # the time was from the user's time.  now we must make it local to
  # the app server in order to be passed to the database.
  $scheduled_time->time_zone("local");

  if ($long_date) {
    return $scheduled_time->long_date;
  }
  else {
    return $scheduled_time->epoch;
  }
}

sub server_set_errata_set_actions_cb {
  my $pxt = shift;
  my $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);
  my $errata_set = RHN::Set->lookup(-label => 'errata_list', -uid => $pxt->user->id);

  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  my $action_id;

  PXT::Debug->log(7, "in server_set_errata_set_actions_cb...");

  if ($pxt->dirty_param('schedule_errata_updates')) {
    RHN::Scheduler->schedule_errata_updates_for_systems(-org_id => $pxt->user->org_id,
							-user_id => $pxt->user->id,
							-earliest => $earliest_date,
							-server_set => $system_set,
							-errata_set => $errata_set);

  } else {
    croak "No valid actions selected!";
  }

  $errata_set->empty;
  $errata_set->commit;

  $pxt->push_message(site_info => "Errata updates scheduled.");

  $pxt->redirect('/network/systems/ssm/errata/index.pxt');
}


sub reschedule_action_cb {
  my $pxt = shift;

  my $action_id = $pxt->param('aid');

  die "no action id!" unless $action_id;

  my $action = RHN::Action->lookup(-id => $action_id);
  my $action_name = $action->name;
  $action_name = $action->action_type_name;
  
  #my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);
  my $server_id = $pxt->param('sid');
  RHN::Scheduler->reschedule_action(-action_id => $action_id, -org_id => $pxt->user->org_id,
				    -user_id => $pxt->user->id, -server_id => $server_id, -server_set => undef);


  if (!$server_id) {
    $pxt->redirect("/network/schedule/reschedule_success.pxt?aid=$action_id");
  }
  else {
    $pxt->push_message(site_info => sprintf('<strong>%s</strong> successfully rescheduled.', $action_name));
    my $redir = $pxt->dirty_param('success_redirect');

    throw "Param 'success_redirect' needed but not provided." unless $redir;

    $pxt->redirect($redir . "?sid=$server_id&amp;aid=$action_id");
  }
}

sub server_set_actions_cb {
  my $pxt = shift;
  my $system_set = RHN::Set->lookup(-label => 'system_list', -uid => $pxt->user->id);

  my $num_systems = $system_set->contents;

  if ($pxt->dirty_param('sscd_hw_prof_update_conf')) {
    my $earliest_date = RHN::Date->now->long_date;
    my $action_id = RHN::Scheduler->schedule_hardware_refresh(-org_id => $pxt->user->org_id,
							      -user_id => $pxt->user->id,
							      -earliest => $earliest_date,
							      -server_set => $system_set);

    $pxt->push_message(site_info => "$num_systems hardware profiles will be refreshed.");
    $pxt->redirect('/network/systems/ssm/misc/index.pxt');
  }
  elsif ($pxt->dirty_param('sscd_pkg_prof_update_conf')) {
    my $earliest_date = RHN::Date->now->long_date;
    my @action_ids = RHN::Scheduler->sscd_schedule_package_refresh(-org_id => $pxt->user->org_id,
								   -user_id => $pxt->user->id,
								   -earliest => $earliest_date,
								   -server_set => $system_set);


    $pxt->push_message(site_info => "$num_systems package profiles will be refreshed.");
    $pxt->redirect('/network/systems/ssm/misc/index.pxt');
  }
  else {
    croak 'no valid action specified!';
  }
}

my %config_actions = ('configfiles.verify' => 'verification',
		      'configfiles.diff' => 'diff',
		      'configfiles.upload' => 'upload',
		      'configfiles.deploy' => 'deploy');

sub latest_config_actions {
  my $pxt = shift;
  my %attr = @_;

  my $type = $attr{type};

  die "Invalid type"
    unless grep { $_ eq $type } keys %config_actions;

  my @actions = RHN::Server->get_latest_actions(-server_id => $pxt->param('sid'), -type => $type);

  my $template = $attr{__block__};
  my $html;

  my $sid = $pxt->param('sid');

  my $upload_namespace_id = RHN::ConfigChannel->vivify_server_config_channel($sid, 'server_import');

  foreach my $row (@actions) {
    my %subst;
    $subst{action_type_name} = $config_actions{$attr{type}};
    $subst{action_type_name} =~ s/^(.)/\U$1/;
    $subst{action_status} = $row->{STATUS};
    $subst{action_status} =~ s/^(.)/\L$1/;
    $subst{action_time} = $pxt->user->convert_time($row->{LAST_MODIFIED});

    my $link_text = $row->{STATUS} eq 'Completed' ? 'View Results' : 'View Status';

    if (   (grep { $type eq $_ } qw/configfiles.verify configfiles.deploy/)
        or ($row->{STATUS} ne 'Completed') ) {
      $subst{results_link} =
	PXT::HTML->link(sprintf('/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d', $sid, $row->{ID}),
			$link_text);
    }
    elsif ( $type eq 'configfiles.upload' ) {
      $subst{results_link} =
	PXT::HTML->link(sprintf('/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=%d',
				$sid), $link_text);
    }
    elsif ( $type eq 'configfiles.diff') {
      $subst{results_link} =
	PXT::HTML->link(sprintf('/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d',
				$sid, $row->{ID}), $link_text);
    }

    $html .= PXT::Utils->perform_substitutions($template, \%subst);
  }

  return $html;
}

sub schedule_config_action_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  PXT::Utils->untaint(\$sid);

  my $action;

  foreach my $action_type (keys %config_actions) {
    $action = $action_type if $pxt->dirty_param($action_type);
  }

  die "no action" unless $action;

  my $set_label = $pxt->dirty_param('set_label') || '';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  my %ids = map { ( $_, 1 ) } $set->contents;

  my $count = scalar $set->contents;

  $set->empty;
  $set->commit;

  my $server = RHN::Server->lookup(-id => $sid);

  my $action_id;
  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  if ($action eq 'configfiles.upload') {
    my @filename_ids = keys %ids;

    my $dest_type = $pxt->dirty_param('destination_channel_type') || 'sandbox';

    my $ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, $dest_type eq 'sandbox' ? 'server_import' : 'local_override');

    ($action_id) = RHN::Scheduler->schedule_config_upload(-org_id => $pxt->user->org_id,
							  -user_id => $pxt->user->id,
							  -earliest => $earliest_date,
							  -server_id => $sid,
							  -action_name => 'Configuration ' . $config_actions{$action},
							  -filename_ids => [@filename_ids],
							  -config_channel_id => $ccid,
							 );

  }
  else {
     my @revisions;

     foreach my $revision ($server->latest_managed_config_revisions()) {
       # skip file/rev unless it's truly under management on the server...
       next unless $ids{$revision->{LATEST_CONFIG_REVISION_ID}};
       push @revisions, $revision->{LATEST_CONFIG_REVISION_ID};
     }


    ($action_id) = RHN::Scheduler->schedule_config_action(-org_id => $pxt->user->org_id,
							  -user_id => $pxt->user->id,
							  -earliest => $earliest_date,
							  -server_id => $sid,
							  -action_type => $action,
							  -action_name => 'Configuration ' . $config_actions{$action},
							  -revision_ids => [@revisions],
							 );
  }

  $pxt->push_message( site_info =>
    sprintf('System config <strong><a href="/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d">%s</a></strong> scheduled for <strong>%d</strong> file%s.',
	    $sid, $action_id, $config_actions{$action}, $count, $count == 1 ? '' : 's') );
  $pxt->redirect("/rhn/systems/details/configuration/Overview.do?sid=$sid");
}

sub _schedule_config_action {
  my $user = shift;
  my $action = shift;
  my $earliest_date = shift;
  my $sid = shift;
  my $ids = shift;
  my %id_map = %{$ids};

  my $server = RHN::Server->lookup(-id => $sid);

  my @revisions;

  foreach my $revision ($server->latest_managed_config_revisions()) {
    # skip file/rev unless it's truly under management on the server...
    next unless $id_map{$revision->{LATEST_CONFIG_REVISION_ID}};
    push @revisions, $revision->{LATEST_CONFIG_REVISION_ID};
  }

  RHN::Scheduler->schedule_config_action(-org_id => $user->org_id,
              -user_id => $user->id,
              -earliest => $earliest_date,
              -server_id => $sid,
              -action_type => $action,
              -action_name => 'Configuration ' . $config_actions{$action} . ' for '. $server->name,
              -revision_ids => [@revisions],
             );
}

sub schedule_ssm_config_action_cb {

  my $pxt = shift;

  my $action;

  foreach my $action_type (keys %config_actions) {
    $action = $action_type if $pxt->dirty_param($action_type);
  }

  die "no action" unless $action;


  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);

  # grab all the latest revisions per server
  my $ds = new RHN::DataSource::Simple(-querybase => 'config_queries',
				       -mode => 'ssm_configfile_revisions',
				      );

  my $data = $ds->execute_query(-user_id => $pxt->user->id);

  # Here's the plan.  ssm_configfile_revisions is ordered by
  # SERVER_ID, and SCC.POSITION.  So as we loop through the data, all
  # of the paths for each system are ordered by the
  # priority/position/rank for that system of the config channel they
  # were found in.  So we just take the first instance of each path,
  # and thus avoid scheduling a diff for a path twice if it is in two
  # config channels that a system is subscribed to.

  my %paths_by_server_id;
  foreach my $row (@{$data}) {
    my $sid = $row->{SERVER_ID};
    my $path = $row->{PATH};
    my $crid = $row->{ID};

    next if exists $paths_by_server_id{$sid}->{$path};
    $paths_by_server_id{$sid}->{$path} = $crid;
  }

  my $server;
  foreach my $sid (keys %paths_by_server_id) {
    my %ids = map { ( $_ => 1 ) } values %{$paths_by_server_id{$sid}};
    _schedule_config_action($pxt->user, $action, $earliest_date, $sid, \%ids);
  }

  my $count = keys %paths_by_server_id;
  $pxt->push_message(site_info => sprintf("%d system%s scheduled for %s.", 
    $count, $count > 1 ? "s" : "", $config_actions{$action}));

  $pxt->redirect("/network/systems/ssm/index.pxt");

}


sub add_managed_files_to_set_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $mode = $pxt->dirty_param('mode') eq 'diff' ? 'configfiles_for_system_diff' : 'configfiles_for_system';
  my $ds = new RHN::DataSource::Simple(-querybase => 'config_queries',
				       -mode => $mode,
				      );
  my $data = $ds->execute_query(-sid => $sid);

  my %seen;

  $data = [ sort { $a->{PATH} cmp $b->{PATH} }
	    grep { not $seen{$_->{PATH}}++ } @{$data} ];

  my @ids = map { $_->{ID} } @{$data};

  my $set_label = $pxt->dirty_param('set_label');
  die "No set label" unless $set_label;

  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  $set->empty;
  $set->commit;
  $set->add(@ids);
  $set->commit;

  my $uri = $pxt->uri;
  $pxt->redirect($uri . sprintf('?sid=%d&set_label=%s', $sid, $set_label));
}

sub add_managed_filenames_to_set_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $ds = new RHN::DataSource::Simple(-querybase => 'config_queries',
				       -mode => 'configfiles_for_system',
				      );

  my $data = $ds->execute_query(-sid => $sid);

  my %seen;

  $data = [ sort { $a->{PATH} cmp $b->{PATH} }
	    grep { not $seen{$_->{PATH}}++ } @{$data} ];

  my @ids = map { $_->{CONFIG_FILE_NAME_ID} } @{$data};

  my $set_label = $pxt->dirty_param('set_label');
  die "No set label" unless $set_label;

  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  $set->empty;
  $set->commit;
  $set->add(@ids);
  $set->commit;

  my $uri = $pxt->uri;
  $pxt->redirect($uri . sprintf('?sid=%d&set_label=%s', $sid, $set_label));
}

sub package_event_result {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $hid = $pxt->param('hid');
  my $id_combo = $pxt->dirty_param('id_combo');

  my $result = RHN::Server->event_package_results(-sid => $sid, -aid => $hid, -id_combo => $id_combo);

  my %subst;

  $subst{event_summary} = "$result->{ACTION_TYPE} scheduled by $result->{LOGIN}";
  $subst{result_package_nvre} = $result->{NVRE};
  $subst{result_return_code} = $result->{RESULT_CODE};
  $subst{result_stdout} = $result->{STDOUT};
  $subst{result_stderr} = $result->{STDERR};

  my $html = $attr{__block__} || '';

  return PXT::Utils->perform_substitutions($html, \%subst);
}

1;
