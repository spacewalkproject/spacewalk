package NOCpulse::Probe::ProbeRunner;

use strict;

use Carp;
use Error ':try';
use Time::HiRes qw(gettimeofday);
use NOCpulse::Log::Logger;
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::Log::LogManager;
use NOCpulse::Log::Logger;
use NOCpulse::Gritch;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Error;
use NOCpulse::Probe::PriorState;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::Schedule;
use NOCpulse::Probe::Transaction;

use Class::MethodMaker
  get_set => 
  [qw(
      probe_record
      command_record
      perl_module
      testing
     )],
  hash =>
  [qw(
      override_args
     )],
  new_with_init => 'new',
  ;

# Add the probe directory to INC.
my $config = NOCpulse::Config->new();
my $libdir = $config->get('ProbeFramework', 'probeClassLibraryDirectory')
  or die "Cannot get probe directory from NOCpulse.ini configuration";
push (@INC, $libdir);

# Always generate error stack traces.
$Error::Debug = 1;

# Log to STDOUT without method names.
NOCpulse::Log::LogManager->instance->stream(FILE => \*STDOUT);
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);
$Log->show_method(0);


sub init {
    my ($self, $probe_record, $command_record, $perl_module, $testing) = @_;

    $probe_record or throw NOCpulse::Probe::InternalError("No probe record provided");

    $self->probe_record($probe_record);

    $command_record ||= NOCpulse::Probe::Config::Command->instances($probe_record->command_id);
    $self->command_record($command_record);

    $perl_module ||= $command_record->command_class;
    $self->perl_module($perl_module);

    $self->testing($testing);

    return $self;
}

sub run {
    my $self = shift;

    my $result = NOCpulse::Probe::Result->new(probe_record   => $self->probe_record,
                                              command_record => $self->command_record);

    my $params_ref = $self->probe_record->parameters;
    $self->_assign_override_params($params_ref);

    my $factory = NOCpulse::Probe::DataSource::Factory->new(probe_record => $self->probe_record);

    my ($memory, $schedule) = NOCpulse::Probe::PriorState->instance->load_result($result);

    $memory ||= {};    # Default to empty memory on first run.

    my $start_timestamp = [gettimeofday];
    my $scheduled_start_time;
    if ($schedule) {
        $scheduled_start_time = $schedule->next_run_time;
    } else {
        $scheduled_start_time = $start_timestamp->[0];
    }

    my %probe_args = 
      ( params => $params_ref,
        result => $result,
        memory => $memory,
        data_source_factory => $factory,
      );

    my $class = $self->perl_module || $self->command_record->command_class;

    my $err;
    my $changes;
    my $notifiers;

    try {
        my $ret = eval "require $class";
        $@ and throw NOCpulse::Probe::InternalError("Cannot load module $class: $@");
        no strict 'refs';

        my $runsub = UNIVERSAL::can($class, 'run') 
          or throw NOCpulse::Probe::InternalError("$class has no subroutine named 'run'");

        &$runsub(%probe_args);

        $result->finish();

        $self->_enqueue($result) unless ($self->testing);

    } catch NOCpulse::Probe::UserVisibleError with {
        $err = shift;

    } catch NOCpulse::Probe::Error with {
        $err = shift;
        $self->_complain($err, $class, 1);

    } otherwise {
        $err = shift;
        $self->_complain($err, $class, 0);
    };

    if ($err) {
        # Set up the UNKNOWN result status.
        $result->finish($err);
        $self->_enqueue($result);

        # Try again after the retry interval.
        $scheduled_start_time = $start_timestamp->[0] + $self->probe_record->retry_interval;
    }

    $self->_log_result($result);

    unless ($self->testing) {
        $schedule = NOCpulse::Probe::Schedule->new($result,
                                                   $start_timestamp,
                                                   $scheduled_start_time);
        NOCpulse::Probe::PriorState->instance->save_result($memory, $schedule, $result);
    }
    return $schedule;
}

sub _complain {
    my ($self, $err, $class, $np_error) = @_;

    my $msg;

    if ($np_error) {
        print STDERR $err;
        $msg = $err->message;
    } else {
        print STDERR "Internal problem executing $class: $err";
        $msg = $err->text;
    }

    # Gritch about the error.
    # Disabled for now until we figure a way of sending a digest of messages
    if (0) {
        my $transaction = NOCpulse::Probe::Transaction->new();
        my $truncated = substr($msg, 0, 1400);
        my $recid = $self->probe_record->recid;

        my $gritcher = NOCpulse::Gritch->new($config->get('satellite', 'gritchdb'));

        $gritcher->recipient($transaction->notification_queue);
        $gritcher->gritch("Probe $class code failed: $truncated",
                          "Probe $recid code caused a Perl error: $truncated\n");
    }
}

sub _enqueue {
    my ($self, $result) = @_;

    my $transaction = NOCpulse::Probe::Transaction->new();
    if ($result->status_changed) {
        $transaction->prepare_state_change($result);
    }
    if ($result->should_notify) {
        $transaction->prepare_notification($result);
    }
    $transaction->prepare_time_series($result);

    $transaction->commit();
}

sub _assign_override_params {
    my ($self, $params_ref) = @_;
    if ($self->override_args) {
        while (my ($key, $value) = each %{$self->override_args}) {
            $params_ref->{$key} = $value;
        }
    }
}

sub _log_result {
    my ($self, $result) = @_;

    return unless $Log->loggable(1);

    if ($result->error_caught_time) {
        $Log->log(1, "\tCaught an error, status changing to UNKNOWN\n");
        if ($result->should_notify) {
            $Log->log(1, $self->testing ? "\tWould notify of error\n" : "\tNotifying of error\n");
        }
    } else {
        if ($result->status_changed) {
            $self->_log_items("\tItems changed or removed", 0, $result->changed_items);
        } else {
            $Log->log(1, "\tNo items changed\n");
        }
        if ($result->should_notify) {
            $self->_log_items($self->testing ? "\tWould notify because" : "\tNotifying because",
                              1, $result->notifying_items);
        } else {
            $Log->log(1, "\tNotification not required\n");
        }
    }

    $Log->log(1, "\tNOTE: Running in test mode; no changes saved, nothing enqueued\n")
      if $self->testing;

    $Log->log(1, "\n",
              '=' x 60, "\n",
              $result->overall_status, ": ", $result->detail_text,
              '=' x 60, "\n");
}

sub _log_items {
    my ($self, $label, $show_renotify, @items) = @_;
    $Log->log(1, "$label:\n");
    foreach my $item (@items) {
        my $renotify_msg = '';
        if ($show_renotify && $item->renotified_count) {
            $renotify_msg = " (renotified: " . $item->renotified_count . ")";
        }
        $Log->log(1, "\t\t", $item->name, " '", $item->value, "' is ", $item->status,
                  $renotify_msg, "\n");
    }
}

1;

__END__
