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
package RHN::Task::DailySummary;

use PXT::Config;
use RHN::DailySummaryEngine;

our @ISA = qw/RHN::Task/;

# Sends a daily report of stats relevant to a user
# this task reaps org suggestions from the rhnDailySummaryQueue, 30s-worth of orgs at a time


# perl -I /var/www/lib/ /home/bretm/rhn/tools/taskomatic/taskomatic --pid /tmp/task.pid --debug --task RHN::Task::DailySummary

sub delay_interval { 30 };

sub run {
  my $class = shift;
  my $center = shift;

  my $log_closure = sub {$center->info(@_)};

  my $engine = new RHN::DailySummaryEngine(-email => 1, -debug => 1, -log_fn => $log_closure);
  my @org_batch = $engine->get_org_batch();

  my $start_ts = time();

  while (@org_batch and (time() < ($start_ts + PXT::Config->get('summary_reaper_batch_time')))) {

    my $org_id  = (pop @org_batch)->{ORG_ID};
    $center->info("dealing with org:  $org_id");
    $engine->queue_org_emails($org_id);

    $engine->mail_queued_emails();
    $center->info("org $org_id emails sent");

    $engine->dequeue_org($org_id);
    $center->info("org $org_id removed from queue");
  }

  if (@org_batch) {
    $center->info("batch not fully completed...");
  }

  my $dbh = RHN::DB->connect();
  $class->log_daemon_state($dbh, 'summary_reaper');
  $dbh->commit;
}

1;
