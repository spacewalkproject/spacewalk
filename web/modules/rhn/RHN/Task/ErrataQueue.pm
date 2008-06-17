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
package RHN::Task::ErrataQueue;
use RHN::ErrataMailer;
use RHN::DataSource::Task;
use RHN::Errata;
use RHN::Scheduler;

our @ISA = qw/RHN::Task/;

sub delay_interval { 1 }

# This task takes the rhnErrataQueue and processes it (currently it
# only populates rhnErrataNotificationQueue, but later it may run the
# EC or various other things)

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();

  my $batch_ds = new RHN::DataSource::Task(-mode => 'errata_queue_batch');
  my $batch = $batch_ds->execute_query(-threshold => 60);

  for my $job (@$batch) {
    my ($errata_id, $org_id) = ($job->{ERRATA_ID}, $job->{ORG_ID});

    $center->info("scheduling autoupdate actions for errata $errata_id");
    RHN::Task::ErrataQueue->schedule_autoupdates($dbh, $errata_id);
    $center->info("autoupdate actions scheduled");

    $center->info("processing queue for errata $errata_id");

    my $query;
    $dbh->do("DELETE FROM rhnErrataQueue WHERE errata_id = ?", {}, $errata_id);

    # satellite?  all orgs, always, for custom errata or not
    if (PXT::Config->get('satellite')) {
	$query = <<EOS;
INSERT
  INTO rhnErrataNotificationQueue
       (errata_id, org_id, next_action)
SELECT DISTINCT
       :errata_id, wc.id, sysdate + :minutes / 1440
  FROM web_customer wc,
       rhnChannelErrata CE
 WHERE CE.errata_id = :errata_id
EOS
    }
    else {
      if (not defined $org_id) {
	$center->info("skipping public errata for non-satellite");
	$dbh->commit;
	next;
      }
      else {
	$query = <<EOS;
INSERT
  INTO rhnErrataNotificationQueue
       (errata_id, org_id, next_action)
SELECT DISTINCT
       :errata_id, CFP.org_id, sysdate + :minutes / 1440
  FROM rhnChannelFamilyPermissions CFP,
       rhnChannelFamilyMembers CFM,
       rhnChannelErrata CE
 WHERE CE.errata_id = :errata_id
   AND CFM.channel_id = CE.channel_id
   AND CFM.channel_family_id = CFP.channel_family_id
   AND CFP.org_id IS NOT NULL
EOS
      }
    }
    $dbh->do("DELETE FROM rhnErrataNotificationQueue WHERE errata_id = ?", {}, $errata_id);
    my $sth = $dbh->prepare($query);
    $sth->execute_h(errata_id => $errata_id, minutes => 0);
    $dbh->commit;

    $center->info("finished queue for errata $errata_id");
  }

  $class->log_daemon_state($dbh, 'errata_queue');
  $dbh->commit;
}

sub schedule_autoupdates {
  my $class = shift;
  my $dbh = shift;
  my $errata_id = shift;

  my $errata = RHN::Errata->lookup(-id => $errata_id);
  my $advisory = $errata->advisory . " - " . $errata->synopsis;

  my $server_ds = new RHN::DataSource::Task(-mode => 'autoupdate_servers_for_errata');
  my $servers = $server_ds->execute_query(-errata_id => $errata_id);
  my %orgs;

  for my $s (@$servers) {
    push @{$orgs{$s->{ORG_ID}}}, $s->{SERVER_ID};
  }

  my $now_sth = $dbh->prepare("SELECT TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL");
  $now_sth->execute;
  my ($now) = $now_sth->fetchrow;
  $now_sth->finish;

  my $sa_sth = $dbh->prepare("INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)");
  my $e_sth = $dbh->prepare("INSERT INTO rhnActionErrataUpdate (action_id, errata_id) VALUES (?, ?)");
  for my $org_id (sort keys %orgs) {
    my ($action_id, $stat_id) =
      RHN::Scheduler->make_base_action(-org_id => $org_id,
				       -type_label => 'errata.update',
				       -earliest => $now,
				       -action_name => "Auto Errata Update for Errata $advisory",
				       -transaction => $dbh,
				      );

    $sa_sth->execute($_, $action_id, $stat_id) for @{$orgs{$org_id}};
    $e_sth->execute($action_id, $errata_id);
  }
}

1;
