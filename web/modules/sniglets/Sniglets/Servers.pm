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

package Sniglets::Servers;

use Carp;
use POSIX;
use File::Spec;
use Data::Dumper;
use Date::Parse;

use PXT::Config ();

use RHN::Server;

sub register_tags {
  my $class = shift;
  my $pxt = shift;
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;
}

sub system_locked_info {
  my $user = shift;
  my $data = shift;

  my $ret = {};
  if ($data->{LOCKED}) {
    $ret->{icon} = 'system-locked';
    $ret->{status_str} = 'System locked';
    $ret->{status_class} = 'system-status-locked';
    $ret->{message} = 'more info';
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
      $ret->{link} = "/rhn/systems/details/Edit.do?sid=${sid}";
    }
  }
  elsif ($data->{LAST_CHECKIN_DAYS_AGO} > PXT::Config->get('system_checkin_threshold')) {
    $ret->{icon} = 'system-unknown';
    $ret->{status_str} = 'System not checking in with R H N';
    $ret->{status_class} = 'system-status-awol';
    $ret->{message} = 'more info';
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
    $ret->{link} = "/rhn/systems/details/history/Pending.do?sid=${sid}";
  }
  elsif ($actions_count) {
    $ret->{icon} = 'action-pending';
    $ret->{status_class} = 'system-status-updates-scheduled';
    $ret->{status_str} = 'Actions scheduled';
    $ret->{message} = 'view actions';
    $ret->{link} = "/rhn/systems/details/history/Pending.do?sid=${sid}";
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
    $ret->{icon} = 'monitoring-crit';
    $ret->{status_str} = 'Critical probes';
    $ret->{system_link} = "/rhn/systems/details/probes/ProbesList.do?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "WARNING") {
    $ret->{icon} = 'monitoring-warn';
    $ret->{status_str} = 'Warning probes';
    $ret->{system_link} = "/rhn/systems/details/probes/ProbesList.do?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "UNKNOWN") {
    $ret->{icon} = 'monitoring-unknown';
    $ret->{status_str} = 'Unknown probes';
    $ret->{system_link} = "/rhn/systems/details/probes/ProbesList.do?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "PENDING") {
    $ret->{icon} = 'monitoring-pending';
    $ret->{status_str} = 'Pending probes';
    $ret->{system_link} = "/rhn/systems/details/probes/ProbesList.do?sid=${sid}";
  }
  elsif ($data->{MONITORING_STATUS} eq "OK") {
    $ret->{icon} = 'monitoring-ok';
    $ret->{status_str} = 'OK';
    $ret->{system_link} = "/rhn/systems/details/probes/ProbesList.do?sid=${sid}";
  }

  return $ret;
}

my @user_server_prefs = ( { name => 'receive_notifications',
                            label => 'Receive Notifications of Updates/Errata' },
                          { name => 'include_in_daily_summary',
                            label => 'Include system in Daily Summary'},
                        );

my @server_prefs = ( { name => 'auto_update',
                       label => 'Automatic application of relevant errata' },
                   );

1;
