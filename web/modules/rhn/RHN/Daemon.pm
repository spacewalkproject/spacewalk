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

package RHN::Daemon;

use PXT::Config;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use Proc::Daemon;
use Unix::Syslog qw/:subs :macros/;
use POSIX ":sys_wait_h", 'strftime';

use constant TRACE => 3;
use constant DEBUG => 2;
use constant INFO => 1;
use constant SILENT => 0;

sub new {
  my $class = shift;
  my $name = shift;

  my $self = bless {}, $class;
  $self->{name} = $name if $name;
  $self->{loglevel} = LOG_LOCAL7;

  return $self;
}

sub become_daemon {
  my $self = shift;

  $self->die("can't call become_daemon unless no children and not a child") if $self->{children} or $self->{parent};
  Proc::Daemon::Init();

  umask 077;

  my %facilities =
    (
     local0 => LOG_LOCAL0,
     local1 => LOG_LOCAL1,
     local2 => LOG_LOCAL2,
     local3 => LOG_LOCAL3,
     local4 => LOG_LOCAL4,
     local5 => LOG_LOCAL5,
     local6 => LOG_LOCAL6,
     local7 => LOG_LOCAL7,
    );

  my $facility = PXT::Config->get('daemon_logging_facility');
  die "Invalid daemon logging facility '$facility'"
    unless exists $facilities{$facility};

  openlog $0, LOG_ODELAY|LOG_PID, $facilities{$facility};
  $self->{logging} = 1;
}

sub info {
  my $self = shift;
  my $msg = shift;

  $self->log_message(-level => INFO, -msg => $msg);
}

sub debug {
  my $self = shift;
  my $msg = shift;

  $self->log_message(-level => DEBUG, -msg => $msg);
}

sub trace {
  my $self = shift;
  my $msg = shift;

  $self->log_message(-level => TRACE, -msg => $msg);
}

sub log_message {
  my $self = shift;
  my %params = validate(@_, { -level => 1, -msg => 1 });

  return if $self->current_log_level < $params{level};

  if ($self->{logging}) {
    syslog(LOG_INFO, $params{msg});
  }
  else {
    warn sprintf "[ %s ] %s\n", strftime("%Y-%m-%d %H:%M:%S", localtime time), $params{msg};
  }
}

sub current_log_level {
  my $level = PXT::Config->get('daemon_debug_level');

  die "Invalid log level: $level" if $level < SILENT or $level > TRACE;

  return $level;
}

sub die {
  my $self = shift;
  my $msg = shift;

  $self->info($msg) if $self->{logging};
  die $msg;
}

sub write_pidfile {
  my $self = shift;
  my $file = shift;

  $self->die("pidfile called but no name or file") unless $file or $self->{name};
  $file ||= "/var/run/" . $self->{name} . ".pid";

  open PID, ">$file"
    or $self->die("Can't write pidfile $file: $!");
  print PID "$$\n";
  close PID;
}

sub new_child {
  my $self = shift;
  my $coderef = shift;

  $self->die("$coderef not a CODEREF") if $coderef and ref($coderef) ne 'CODE';

  $self->die("process is already a child") if $self->{parent};

  my $parent = $$;
  my $pid = fork();
  $self->die("bad fork? $!") unless defined $pid;

  if ($pid) {
    my $child = RHN::Daemon::Child->new($pid);
    push @{$self->{children}}, $child;

    return $child;
  }
  else {
    $self->{parent} = $parent;

    # coderef passed?  if so, call it, then exit.
    if ($coderef) {
      eval {
	$coderef->($self);
      };
      $self->info($@) if $@;

      exit 0;
    }

    return;
  }
}

sub parent_alive {
  my $self = shift;

  return (getppid() == $self->{parent}) ? 1 : 0;
}

sub find_child {
  my $self = shift;
  my $pid = shift;

  my ($child) = grep { $_->pid == $pid } @{$self->{children}};
  $self->die("no child with pid $pid?") unless $child;

  return $child;
}

sub remove_child {
  my $self = shift;
  my $pid = shift;

  my @new_children;
  my $ret;

  foreach my $child (@{$self->{children}}) {
    if ($child->pid == $pid) {
      $ret = $child;
    }
    else {
      push @new_children, $child;
    }
  }

  $self->{children} = \@new_children;
  return $ret;
}

sub wait_for_children {
  my $self = shift;
  my $nohang = shift;

  my $pid = waitpid(-1, $nohang ? WNOHANG : 0);

  # if error was no processes, ignore it, otherwise die
  if ($nohang and $pid == 0) {
    return;
  }
  if ($pid < 0) {
    if (0 + $! != 10) {
      $self->die("waitpid: $!");
    }
    return;
  }

  my $child = $self->remove_child($pid);
  $child->exit_status($?);

  return $child;
}

sub signal_children {
  my $self = shift;
  my $sig = shift;

  foreach my $child (@{$self->{children}}) {
    kill $sig, $child->pid;
  }
}

sub reap_children {
  my $self = shift;

  my @ret;
  while (my $child = $self->wait_for_children(1)) {
    push @ret, $child;
  }

  return @ret;
}

sub kill_children {
  my $self = shift;

  return unless $self->{children} and @{$self->{children}};

  my @ret;
  my $tries = 0;

  while($tries < 3 and @{$self->{children}}) {
    $self->signal_children("TERM");
    sleep 1;

    push @ret, $self->reap_children;

    $tries++;
  }

  if (not @{$self->{children}}) {
    return @ret;
  }

  warn "Children still left after $tries tries.  Killing harder.";

  $self->signal_children("KILL");
  sleep 1;

  push @ret, $self->reap_children;

  return @ret;
}

package RHN::Daemon::Child;
use POSIX ":sys_wait_h";

sub new {
  my $class = shift;
  my $pid = shift;
  die "no pid" unless $pid;

  my $self = bless { pid => $pid }, $class;

  return $self;
}

sub pid {
  return shift->{pid};
}

sub running {
  my $self = shift;

  my $result = waitpid($self->pid, WNOHANG);

  if ($result == 0) {
    return 1;
  }
  else {
    $self->exit_status($?);
    return 0;
  }
}

sub exit_status {
  my $self = shift;
  my $exit_status = shift;

  $self->{exit_status} = $exit_status if defined $exit_status;

  return $self->{exit_status};
}

1;
