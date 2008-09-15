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
package RHN::Task::Test;

# Useful for testing the daemon.  Test thusly:
# perl -I /var/www/lib/ /home/devel/cturner/rhn/tools/taskomatic/taskomatic --pid /tmp/task.pid --debug --task RHN::Task::Test

our @ISA = qw/RHN::Task/;

sub delay_interval { 1 }

sub run_async {
  my $class = shift;
  my $center = shift;

  # this is to simulate a handler that takes much longer to run than its delay interval
  sleep(int((10)));
}

1;
