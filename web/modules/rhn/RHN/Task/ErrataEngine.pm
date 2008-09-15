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
package RHN::Task::ErrataEngine;
use RHN::ErrataMailer;

our @ISA = qw/RHN::Task/;

sub delay_interval { 1 }

# This task is what sends emails for errata scheduled for mailing.

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOS);
SELECT enq.errata_id, enq.org_id
  FROM rhnErrataNotificationQueue ENQ
 WHERE enq.next_action < sysdate + :threshold/86400
ORDER BY next_action DESC
EOS

  $sth->execute_h(threshold => 60);

  while (my ($errata_id, $org_id) = $sth->fetchrow) {
    $center->info("processing errata $errata_id");
    eval {
      my $mailer = new RHN::ErrataMailer(-errata_id => $errata_id, -org_id => $org_id);
      $mailer->send_all_emails;
    };
    if ($@) {
      my $E = $@;
      $dbh->rollback;
      die $E;
    }

    $dbh->do("UPDATE rhnErrataNotificationQueue SET next_action = NULL WHERE errata_id = ? AND org_id = ?", {}, $errata_id, $org_id);
    $dbh->commit;

    $center->info("finished errata $errata_id");
  }

  $class->log_daemon_state($dbh, 'errata_engine');
  $dbh->commit;
}

1;
