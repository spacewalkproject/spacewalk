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
package RHN::Task::SessionCleanup;
use RHN::TaskMaster;
use PXT::Config;

our @ISA = qw/RHN::Task/;

sub delay_interval { 40 } # fifteen minutes

# Deletes expired rows from the PXTSessions table to keep it from
# growing too large.

sub run_async {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();
  my $window = PXT::Config->get('session_database_lifetime');
  my $batch_size = PXT::Config->get('session_delete_batch_size');
  my $commit_interval = PXT::Config->get('session_delete_commit_interval');

  $center->info("session_cleanup: starting delete of stale sessions");

  my $sth = $dbh->prepare(<<EOS);
begin
   pxt_session_cleanup ( :bound, :commit_interval, :batch_size, :sessions_deleted );
end;
EOS

  my $bound = time - 2 * $window;
  my $sessions_deleted = 0;

  $sth->bind_param(":bound" => $bound);
  $sth->bind_param(":commit_interval" => $commit_interval);
  $sth->bind_param(":batch_size" => $batch_size);
  $sth->bind_param_inout(":sessions_deleted" => \$sessions_deleted, 4096);

  $sth->execute;
  $class->log_daemon_state($dbh, 'session_cleanup');
  $dbh->commit;

  $center->info("session_cleanup: $sessions_deleted stale sessions deleted");
}

1;
