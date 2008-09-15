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
package RHN::Task::NoChannelCheck;
use RHN::TaskMaster;
use RHN::Postal;
use RHN::Org;
use RHN::User;
use RHN::Server;
use Params::Validate;

our @ISA = qw/RHN::Task/;

sub delay_interval { 600 }

# If a new server is registered, but has no channels, we should email
# the user letting them know they may not be getting updates.

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();

  # The logic: find orgs with one server that were made since the last
  # pass of the daemon and that are subscribed to no channels.  Send
  # reminder mail in that case.

  my $sth = $dbh->prepare(<<EOS);
SELECT DISTINCT S.id, S.org_id, S.name
  FROM rhnServer S
 WHERE S.created > NVL((SELECT DS.last_poll FROM rhnDaemonState DS WHERE DS.label = 'server_channel_check'), sysdate - 1)
   AND NOT EXISTS (SELECT 1 FROM rhnServerChannel SC WHERE SC.server_id = S.id)
   AND (SELECT COUNT(1) FROM rhnServer S2 WHERE S2.org_id = S.org_id) = 1
EOS
  $sth->execute_h();

  my $n = 0;
  while (my ($server_id, $org_id, $name) = $sth->fetchrow) {
    $center->info("processing unchanneled server $server_id in org $org_id");
    process_unchanneled_servers($center, $dbh, $org_id, $server_id, $name);
  }

  $class->log_daemon_state($dbh, 'server_channel_check');
  $dbh->commit;
}

sub process_unchanneled_servers {
  my $center = shift;
  my $dbh = shift;
  my $org_id = shift;
  my $server_id = shift;
  my $server_name = shift;

  my $org = RHN::Org->lookup(-id => $org_id);
  my $user = $org->find_responsible_user;

  # yes, there are userless orgs :/
  return unless $user;

  # note: we will send to unverified addresses since the timing here
  # is likely to be before a user could have verified their email.  so
  # we use find_mailable_address instead of just using their verified
  # address

  my $address = $user->find_mailable_address;

  return unless $address;

  my $notice = new RHN::Postal;
  my $filename = "unchanneled_system.xml";
  $notice->template($filename);

  $notice->set_tag("login", $user->login);
  $notice->set_tag("system-name", $server_name);
  $notice->set_tag("email-address", $address->address);
  $notice->to($address->address);
  $notice->render();

  $notice->send;

}

1;
