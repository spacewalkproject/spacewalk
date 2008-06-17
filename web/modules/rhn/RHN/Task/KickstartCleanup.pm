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
package RHN::Task::KickstartCleanup;

use RHN::TaskMaster;
use RHN::Kickstart::Session;
use Params::Validate;

our @ISA = qw/RHN::Task/;

sub delay_interval { 600 }

# Clean up kickstarts which are invalid for various reasons.
# Provide remotely topical comments.

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();

  # The logic: Expire kickstart sessions which fall into one of two categories:
  # 1) In progress, but have not checked in within ':hours' hours.
  # 2) Scheduled, but not used withing ':hours * 6' hours.

  my $sth = $dbh->prepare(<<EOS);
SELECT KS.id
  FROM rhnKickstartSessionState KSS,
       rhnKickstartSession KS
 WHERE KSS.id = KS.state_id
   AND KSS.label NOT IN ('created', 'complete', 'failed')
   AND KS.last_action < sysdate - :hours/24
UNION
SELECT KS.id
  FROM rhnKickstartSessionState KSS,
       rhnKickstartSession KS
 WHERE KSS.id = KS.state_id
   AND KSS.label = 'created'
   AND KS.last_action < sysdate - :hours * 6 / 24
EOS
  $sth->execute_h(hours => 2);

  my $n = 0;
  while (my ($session_id) = $sth->fetchrow) {
    $center->info("processing stalled kickstart $session_id");
    process_stale_kickstart($center, $dbh, $session_id);
  }

  $class->log_daemon_state($dbh, 'kickstart_session_check');
  $dbh->commit;
}

sub process_stale_kickstart {
  my $center = shift;
  my $dbh = shift;
  my $session_id = shift;

  my $session = RHN::Kickstart::Session->lookup(-id => $session_id);

  if ($session->session_state_label eq 'created') {
    $session->mark_failed('System never picked up kickstart action.');
  }
  else {
    $session->mark_failed('System failed to check in.');
  }

  return;
}

1;
