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
package RHN::Task::SummaryPopulation;

use PXT::Config;
use RHN::DailySummaryEngine;

our @ISA = qw/RHN::Task/;

# figures out what orgs might be candidates for sending daily summary email

# perl -I /var/www/lib/ /home/bretm/rhn/tools/taskomatic/taskomatic --pid /tmp/task.pid --debug --task RHN::Task::SummaryPopulation


sub crontab {
  return PXT::Config->get('summary_populator_crontab');
}

sub run {
  my $class = shift;
  my $center = shift;

  $center->info("starting interesting org hunt ...");

  my $engine = new RHN::DailySummaryEngine();
  my $dbh = RHN::DB->connect();

  $engine->enqueue_orgs($dbh);

  $center->info("finished queueing interesting orgs for daily summary emails ...");
  $class->log_daemon_state($dbh, 'summary_populator');
  $dbh->commit;
}

1;
