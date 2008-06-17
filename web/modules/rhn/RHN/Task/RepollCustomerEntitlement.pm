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
package RHN::Task::RepollCustomerEntitlement;

use Params::Validate;

use PXT::Config;

our @ISA = qw/RHN::Task/;

sub crontab {
    return PXT::Config->get('ep_crontab');
}

sub run {
    my $class = shift;
    my $center = shift;

    my $dbh = RHN::DB->connect;
    my $duration = PXT::Config->get('ep_poll_duration');
    my $batch = PXT::Config->get('ep_commit_interval');

    my $total = $dbh->call_function('rhn_ep.entitlement_queue_pending');
    my $done = 0;

    $center->info("starting customer entitlement repoll run...");
    $done = $dbh->call_function('rhn_ep.process_queue_batch', $duration, $batch);
    $center->info("processed $done of $total\n");

    $class->log_daemon_state($dbh, 'repoll_customer_entitlement');
    $dbh->commit;
}

1;
