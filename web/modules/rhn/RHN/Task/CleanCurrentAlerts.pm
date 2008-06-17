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
package RHN::Task::CleanCurrentAlerts;

use PXT::Config;
use RHN::DB;

our @ISA = qw/RHN::Task/;

# Cleans the RHN_CURRENT_ALERTS table.


sub delay_interval { 86400 }; # once per day

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect;

  $center->info("Starting clean_current_alerts run ...");

  my($sql, $sth, $rows);

  # First, set DATE_COMPLETED on any alerts that may be left
  # hanging around (e.g. from a server crash)

  $center->debug("\tUpdating DATE_COMPLETED");
  $sql = q{
    UPDATE current_alerts
    SET    date_completed = sysdate, in_progress = '0'
    WHERE  date_completed is null
    AND    sysdate - date_submitted > 1
  };
  $sth = $dbh->prepare($sql);
  $rows = 0 + $sth->execute();
  $center->debug("\t\t$rows rows updated");


  # Next, delete old CURRENT_ALERTS records.

  $center->debug("\tDeleting old CURRENT_ALERTS records");
  $sql = q{
    DELETE FROM current_alerts
    WHERE sysdate - date_completed > 1
  };
  $sth = $dbh->prepare($sql);
  $rows = 0 + $sth->execute();
  $center->debug("\t\t$rows rows deleted");

  $center->info("Finished clean_current_alerts run.");
  $class->log_daemon_state($dbh, 'clean_current_alerts');
  $dbh->commit;
}

1;
