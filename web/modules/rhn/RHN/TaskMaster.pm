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
package RHN::TaskMaster;
use Time::HiRes;
use RHN::DB;

sub new {
  my $class = shift;

  my $self = bless { active => [] }, $class;
  return $self;
}

sub active_tasks {
  return scalar @{shift->{active}};
}

sub next_task {
  my $self = shift;
  my $task = shift @{$self->{active}};

  return $task;
}

sub register_task {
  my $self = shift;
  my $task = shift;
  die "not an RHN::Task" unless $task->isa('RHN::Task');
  die "task has no when" unless $task->when;

  $task->master($self);
  my $i = 0;
  my $added;
  my @new_queue;
  while ($i <= $#{$self->{active}}) {
    if (not $added and $task->when < $self->{active}->[$i]->when) {
      push @new_queue, $task;
      $added = 1;
    }
    push @new_queue, $self->{active}->[$i];
    $i++;
  }

  push @new_queue, $task if not $added;

  $self->{active} = \@new_queue;
}

package RHN::Task;

use Schedule::Cron::Events;
use Time::Local;


sub new {
  my $class = shift;

  my $self = bless { when => 0 }, $class;
  return $self;
}

# default delay between runs
sub delay_interval {
  my $self = shift;

  if ($self->can('crontab')) {
    my $cron_tab_line = $self->crontab();
    my $time = time();
    my $cron = new Schedule::Cron::Events($cron_tab_line, Seconds => $time);

    return (timelocal($cron->nextEvent) - $time);
  }

  return 300;
}

sub when {
  my $self = shift;

  if (@_) {
    $self->{when} = shift;
  }

  return $self->{when};
}

sub run {
  die "pure virtual method 'run' called on RHN::Task object";
}

sub ready_to_run {
  # tasks assume runnable; mainly usefully overridden for async
  # actions.  this allows us to check for jobs before expensive async
  # tasks.

  return 1;
}

sub log_daemon_state {
  my $class = shift;
  my $dbh = shift;
  my $state = shift;

  $dbh ||= RHN::DB->connect;

  $dbh->do("DELETE FROM rhnDaemonState WHERE label = ?", undef, $state);
  $dbh->do("INSERT INTO rhnDaemonState (label, last_poll) VALUES (?, sysdate)", undef, $state);
}

sub get_daemon_states {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT DS.label, TO_CHAR(DS.last_poll, 'YYYY-MM-DD HH24:MI:SS')
  FROM rhnDaemonState DS
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute();

  my %ret;

  while (my ($label, $last_poll) = $sth->fetchrow) {
    $ret{$label} = $last_poll;
  }

  return \%ret;
}


sub schedule {
  my $self = shift;
  my $last_run_duration = shift || 0;

  # never schedule for less time than the last run took.  this helps
  # prevent starvation from fast-running tasks.

  my $delay = $self->delay_interval;
  if ($delay < $last_run_duration) {
    $delay = $last_run_duration;
    if ($delay > 5 * $self->delay_interval) {
      $delay = 5 * $self->delay_interval;
    }
  }
  $delay = 5 * $self->delay_interval if $delay > 5 * $self->delay_interval;

  $self->when(Time::HiRes::time() + $delay);

  $self->master->register_task($self);
}

sub master {
  my $self = shift;

  if (@_) {
    $self->{master} = shift;
  }

  return $self->{master};
}

1;
