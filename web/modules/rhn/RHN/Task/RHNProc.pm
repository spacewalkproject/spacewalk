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
package RHN::Task::RHNProc;
our @ISA = qw/RHN::Task/;

use RHN::Server;

my $max_actions = 50;

sub delay_interval { 1 }

sub executing_task_sth {
  my $class = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOS);
SELECT rowid, org_id, task_name, task_data
  FROM rhnTaskQueue
 WHERE earliest < sysdate + :threshold/86400
ORDER BY priority DESC NULLS FIRST
EOS

  $sth->execute_h(threshold => 60);
  return $sth;
}

sub ready_to_run {
  my $class = shift;

  my $sth = $class->executing_task_sth;
  my @task = $sth->fetchrow;
  $sth->finish;

  return scalar @task;
}

sub run_async {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $class->executing_task_sth;

  my $n = 0;
  while (my ($rowid, $org_id, $task_name, $task_data) = $sth->fetchrow) {
    eval {
      my %handlers;
      $handlers{update_errata_cache_by_channel} = \&update_errata_cache_by_channel;
      $handlers{update_server_errata_cache} = \&update_server_errata_cache;

      my $handler = $handlers{$task_name};
      $class->$handler($center, $task_data);
    };
    if ($@) {
      my $E = $@;
      $dbh->rollback;
      die $E;
    }

    $dbh->do("DELETE FROM rhnTaskQueue WHERE rowid = ?", {}, $rowid);
    $dbh->commit;

    last if $n++ > $max_actions;
  }

  $class->log_daemon_state($dbh, 'rhnproc');
  $dbh->commit;
}

sub update_server_errata_cache {
  my $class = shift;
  my $center = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect();
  my ($added, $deleted, $unchanged) = RHN::Server->update_cache_for_server($dbh, $server_id);
  $center->info(sprintf "Server $server_id: (%d added, %d removed, %d unchanged)\n", scalar @$added, scalar @$deleted, $unchanged);
}

sub update_errata_cache_by_channel {
  my $class = shift;
  my $center = shift;
  my $channel_id = shift;

  $center->info("update_errata_cache_by_channel($channel_id) called...");
  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare('SELECT server_id FROM rhnServerChannel WHERE channel_id = ?');
  $sth->execute($channel_id);

  my @sids;
  while (my ($sid) = $sth->fetchrow) {
    push @sids, $sid;
  }

  foreach my $sid (@sids) {
    my ($added, $deleted, $unchanged) = RHN::Server->update_cache_for_server($dbh, $sid);
    $center->info(sprintf "Server $sid: (%d added, %d removed, %d unchanged)\n", scalar @$added, scalar @$deleted, $unchanged);
  }

  # now wipe any other tasks for this same channel
  $sth = $dbh->prepare("DELETE FROM rhnTaskQueue WHERE task_name = 'update_errata_cache_by_channel' AND task_data = ?");
  $sth->execute($channel_id);

  $center->info("update_errata_cache_by_channel($channel_id) finished");
}

1;
