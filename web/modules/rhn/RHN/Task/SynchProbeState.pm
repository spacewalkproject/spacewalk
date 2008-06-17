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
package RHN::Task::SynchProbeState;

use PXT::Config;
use RHN::DB;

our @ISA = qw/RHN::Task/;

# Runs the rhn_synch_probe_state stored procedure to:
#  1) set state to PENDING when current probe state is too old;
#  2) delete state for probes that no longer exist;
#  3) calculate current state summaries;
#  4) update MULTI_SCOUT_THRESHOLD;
#  5) record last satellite check-in time.


sub delay_interval { 60 }; # every minute

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect;

  $center->info("Starting SynchProbeState run ...");

  $dbh->do("BEGIN rhn_synch_probe_state; END;");

  $center->info("Finished SynchProbeState run.");
  $class->log_daemon_state($dbh, 'synch_probe_state');
  $dbh->commit;
}

1;
