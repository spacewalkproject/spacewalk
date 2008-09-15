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
package RHN::Task::SandboxCleanup;
use RHN::TaskMaster;
use PXT::Config;

our @ISA = qw/RHN::Task/;

sub delay_interval { 86400 } # one day

# Cleans up the sandbox config channels to save space.

sub run_async {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();
  my $window = PXT::Config->get('sandbox_lifetime');

  my $sth = $dbh->prepare(<<EOS);
DELETE FROM rhnConfigChannel CC
 WHERE CC.created < sysdate - :window
   AND CC.confchan_type_id = (SELECT id FROM rhnConfigChannelType WHERE label = 'server_import')
EOS
  my $chans_deleted = 0 + $sth->execute_h(window => $window);

  $sth = $dbh->prepare(<<EOS);
DELETE FROM rhnConfigContent CC
 WHERE NOT EXISTS (SELECT 1 FROM rhnConfigRevision CR WHERE CC.id = CR.config_content_id)
EOS
  my $content_deleted = 0 + $sth->execute;

  $sth = $dbh->prepare(<<EOS);
DELETE FROM rhnConfigInfo CC
 WHERE NOT EXISTS (SELECT 1 FROM rhnConfigRevision CR WHERE CC.id = CR.config_info_id)
EOS
  my $info_deleted = 0 + $sth->execute;

  $class->log_daemon_state($dbh, 'sandbox_cleanup');
  $dbh->commit;

  $center->info("sandbox_cleanup: $chans_deleted stale sandboxes deleted ($content_deleted bodies, $info_deleted info entries)");
}

1;
