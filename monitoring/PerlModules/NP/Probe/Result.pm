package NOCpulse::Probe::Result;

use strict;

use NOCpulse::Log::Logger;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::ItemStatus;
use NOCpulse::Probe::Threshold;
use NOCpulse::Probe::MessageCatalog;

use Class::MethodMaker
  get_set =>
  [qw(
      context
      thresholder
      probe_record
      command_record
      error_caught_time
      non_ok_notif_out
      _detail_text
      _notification_text
      _overall_status
      _status_changed
      _should_notify
      _message_catalog
      _finish_called
     )],
  list =>
  [qw(
      _changed_items
      _notifying_items
      _vanished_items
     )],
  counter =>
  [qw(
      attempts
      _next_item_sequence
     )],
  # Hash of status items by name
  hash =>
  [qw(
      item_named
      prior_item_named
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# For convenience
use constant OK       => NOCpulse::Probe::ItemStatus::OK;
use constant WARNING  => NOCpulse::Probe::ItemStatus::WARNING;
use constant UNKNOWN  => NOCpulse::Probe::ItemStatus::UNKNOWN;
use constant CRITICAL => NOCpulse::Probe::ItemStatus::CRITICAL;


# Initializes thresholder and message catalog.
sub init {
    my ($self, %args) = @_;

    $args{probe_record} or throw NOCpulse::Probe::InternalError("No probe_record specified");
    unless ($args{command_record}) {
        my $command_id = $args{probe_record}->command_id;
        $args{command_record} = NOCpulse::Probe::Config::Command->instances($command_id);
    }
    $args{command_record} 
      or throw NOCpulse::Probe::InternalError("Cannot find probe's command record");

    $args{_message_catalog} = NOCpulse::Probe::MessageCatalog->instance();
    $self->hash_init(%args);

    $self->thresholder(NOCpulse::Probe::Threshold->new(
        probe_param_values => $self->probe_record->parameters));
}

# Adds an item to the results and returns it.
sub add_item {
    my ($self, %item_status_init) = @_;
    unless ($item_status_init{sequence}) {
        # Set the sequence to the next one unless it's being overridden
        # in the argument hash.
        $item_status_init{sequence} = $self->_next_item_sequence;
        $self->_next_item_sequence_incr();
    }

    my $item = NOCpulse::Probe::ItemStatus->new(%item_status_init);

    $self->item_named($item->name, $item);

    $Log->log(4, "Item '",    $item->name,
              "', seq #",     $item->sequence, 
              ", status ",    $item->status,
              ": value '",    $item->value, 
              "', format '",  $item->value_format, 
              "', message '", $item->message, "'\n");
    return $item;
}

sub remove_item {
    my ($self, $item_name) = @_;
    $self->item_named_delete($item_name);
}

# Sets status and other info for a data item.
sub item_status {
    my ($self, $status, %item_status_init) = @_;
    my $item = $self->add_item(status => $status, %item_status_init);
    $item->format_detailed_message($self->_message_catalog) unless $item->message;
    return $item;
}

# Records an arbitrary value with OK status.
sub item_value {
    my ($self, $name, $value, $format, %item_status_init) = @_;
    my $item = $self->item_status(OK, 
                                  name         => $name,
                                  value        => $value,
                                  value_format => $format,
                                  %item_status_init);
    $Log->log(4, "Item ", $item->name, " = ", $item->value, "\n");
    return $item;
}

# Records an item's value and checks it against threshold parameters.
# Set remove_if_ok value in %item_status_init to true to remove value
# if its state is OK.
sub item_thresholded_value {
    my ($self, $name, $value, $format, $thresholds, %item_status_init) = @_;

    my $remove_if_ok = delete $item_status_init{remove_if_ok};

    my $item = $self->item_value($name, $value, $format, %item_status_init);

    $item->format_detailed_message($self->_message_catalog);

    my ($crossed, $c_value) = $self->thresholder->value_crossed($item->name,
                                                              $item->value,
                                                              %$thresholds);
    $self->_handle_crossed_threshold($item, $crossed, $c_value);

    $Log->log(4, "Thresholded item ", $item->name, " = ", $item->value, ", ", $item->status, "\n");

    if ($remove_if_ok && $item->is_ok) {
        $self->remove_item($item->name);
    }

    return $item;
}

# Records a metric value.
sub metric_value {
    my ($self, $metric_name, $value, $format, %item_status_init) = @_;

    $self->metric_named($metric_name)
      or print STDERR ("WARNING: No metric named $metric_name for command ID " .
                       $self->command_record->command_id . ', module "' .
                       $self->command_record->command_class, "\"\n");

# For the next release throw the exception instead of just warning about it
#      or throw NOCpulse::Probe::InternalError("No metric named $metric_name for command " .
#                                              $self->command_record->command_id . ", " .
#                                              $self->command_record->command_class);

    my $remove_if_ok = delete $item_status_init{remove_if_ok};

    $Log->log(4, "Metric $metric_name = $value\n");
    my $item = $self->item_value($metric_name, $value, $format, %item_status_init);
    $self->_setup_metric_item($item, 1);

    if ($remove_if_ok && $item->is_ok) {
        $self->remove_item($item->name);
    }
    return $item;
}

sub metric_percentage {
    my ($self, $metric_name, $part_value, $total_value, $format, %item_status_init) = @_;

    my $item = $self->add_item(status       => OK,
                               name         => $metric_name, 
                               value_format => $format,
                               %item_status_init);
    $item->as_percentage($part_value, $total_value);
    $Log->log(4, "Metric $metric_name percentage = ", $item->value,
              " from $part_value and $total_value\n");
    my $msg;
    unless ($item->is_ok) {
        $msg =  "Cannot calculate $part_value as a percentage of $total_value";
    }
    $self->_setup_metric_item($item, 1, $msg);
    return $item;
}

# Records a metric value from which to calculate a rate.
sub metric_rate {
    my ($self, $metric_name, $value, $format, $time_divisor, $wrap, %item_status_init) = @_;

    my $item = $self->add_item(status       => OK,
                               name         => $metric_name, 
                               value_format => $format,
                               %item_status_init);
    $item->as_rate($value, $self->prior_item_named($metric_name), $time_divisor, $wrap);
    $Log->log(4, "Metric $metric_name rate = ", $item->value, " from $value\n");
    return $self->_setup_metric_item($item, 1);
}

# Records a message about a metric, for instance, that a calculation can't be done.
sub metric_message {
    my ($self, $metric_name, $message, %item_status_init) = @_;
    my $item = $self->item_value($metric_name, undef, %item_status_init);
    return $self->_setup_metric_item($item, 0, $message);
}

sub item_ok {
    my ($self, $name, $value, %item_status_init) = @_;
    $self->item_status(OK, name => $name, value => $value, %item_status_init);
}

sub item_warning {
    my ($self, $name, $value, %item_status_init) = @_;
    $self->item_status(WARNING, name => $name, value => $value, %item_status_init);
}

sub item_critical {
    my ($self, $name, $value, %item_status_init) = @_;
    $self->item_status(CRITICAL, name => $name, value => $value, %item_status_init);
}

sub item_unknown {
    my ($self, $name, $value, %item_status_init) = @_;
    $self->item_status(UNKNOWN, name => $name, value => $value, %item_status_init);
}

sub user_data_not_found {
    my ($self, $name, $value, %item_status_init) = @_;
    my $item = $self->item_status(UNKNOWN, name => $name, value => $value, %item_status_init);
    $self->_assign_metric_info($item);
    $item->message(sprintf($self->_message_catalog->status('user_data_not_found'),
                           $item->name, $item->value));
}

sub internal_data_not_found {
    my ($self, $name, %item_status_init) = @_;
    my $item = $self->item_status(UNKNOWN, name => $name, %item_status_init);
    $self->_assign_metric_info($item);
    my $label = $item->label || $item ->name;
    $item->message(sprintf($self->_message_catalog->status('internal_data_not_found'), $label));
}

sub is_valid_state {
    my ($self, $state) = @_;

    return
         $state eq OK
      || $state eq WARNING
      || $state eq UNKNOWN
      || $state eq CRITICAL;
}


# Wrapper methods that ensure finish() has been called

sub detail_text {
    my $self = shift;
    return $self->_detail_text(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_detail_text;
}

sub notification_text {
    my $self = shift;
    return $self->_notification_text(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_notification_text;
}

sub overall_status {
    my $self = shift;
    return $self->_overall_status(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_overall_status;
}

sub status_changed {
    my $self = shift;
    return $self->_status_changed(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_status_changed;
}

sub should_notify {
    my $self = shift;
    return $self->_should_notify(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_should_notify;
}

sub changed_items {
    my $self = shift;
    return $self->_changed_items(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_changed_items;
}

sub notifying_items {
    my $self = shift;
    return $self->_notifying_items(@_) if @_;
    $self->_finish_called or $self->finish();
    return $self->_notifying_items;
}


# Calculates final set of changed and notifying items, formats
# messages, and handles caught errors.
sub finish {
    my ($self, $err) = @_;

    $self->_finish_called(1);

    $self->_overall_status(UNKNOWN);
    $self->_should_notify(0);
    $self->_status_changed(0);
    $self->_changed_items_clear();
    $self->_notifying_items_clear();

    if ($err) {
        $self->_caught($err);

    } else {
        # For a normal run status and notifiers are calculated
        # from the items.
        $self->_calc_overall_status();
        $self->_calc_changed_items();
        $self->_calc_notifying_items();

        # If there was a previous error, status change has to be
        # caculated against the error's UNKNOWN setting.
        if ($self->error_caught_time) {
            $self->status_changed($self->overall_status ne UNKNOWN);
        }
        $self->error_caught_time(undef);
    }

    # Handle attempt count.
    my $max_attempts = $self->probe_record->max_attempts || 1;
    if ($self->overall_status ne $self->OK) {
        $self->attempts_incr();
        if ($self->attempts < $max_attempts) {
            # More attempts to go, act as if nothing needs notifying
            $Log->log(2, "Suppressing change: attempt ", $self->attempts,
                      " of $max_attempts\n");
            # The renotify interval should not kick in after the attempt
            # count is crossed, because no notification has actually gone out.
            foreach my $item ($self->_notifying_items) {
                $item->status_notified_time($item->status, -1);
                $item->renotified_count_reset();
            }
            $self->_notifying_items_clear();
            $self->_changed_items_clear();
            $self->_should_notify(0);
        } else {
            # Tipped over the edge, reset to zero.
            $self->attempts_reset();
        }

        # If _should_notify is true here, we're going to notify.
        $self->non_ok_notif_out(1) if ($self->_should_notify);

    } else {

        # Kill any OK notification if no non-OK notification was sent
        if ($self->_should_notify and not $self->non_ok_notif_out) {
          $Log->log(2, "Supressing OK notification as no non-OK was sent\n");
          $self->_should_notify(0);
        }

        # Probe state is OK, reset everything
        $self->attempts_reset();
        $self->non_ok_notif_out(0);
    }

    $self->_format_messages();
}

# Marks results as UNKNOWN and sets the messages to either 
# the error text, if it's not an internal error or result of a die,
# or to a generic "internal problem" message otherwise.
sub _caught {
    my ($self, $err) = @_;

    my $now = time();

    $self->item_unknown(ref($err));
    # Notify if we're past the renotification for the last time an
    # error was caught AND we're notifying on UNKNOWN.
    my $past_renotify_time = $self->_past_renotify_time($now - $self->error_caught_time);
    $self->_should_notify($self->probe_record->notify_unknown && $past_renotify_time);

    $self->error_caught_time($now);
    $self->overall_status(UNKNOWN);

    # Consider this a status change if it's not the same error as before.
    $self->status_changed(not $self->prior_item_named_exists(ref($err)));

    # Assign the appropriate message.
    my $msg;
    if (!ref($err)
        or $err->isa('NOCpulse::Probe::InternalError')
        or (not $err->isa('NOCpulse::Probe::Error'))) {
        $msg = $self->_message_catalog->status('internal_problem');
    } else {
        $msg = $err->message();
    }
    $msg .= "\n";
    $self->detail_text($msg);
    $self->notification_text($msg);

    $Log->log(2, "Caught error >>>$msg<<<\n");
    $Log->log(2, "Notifying: ", $self->_should_notify ? "YES" : "NO", "\n");

    # Copy item statuses from the prior state for any
    # that have not been recorded in this run. This
    # preserves prior information such as raw value for
    # rate calculations. Clear the actual status setting
    # to UNKNOWN, however, so that once the error is cleared
    # the recovery will trigger notification.
    foreach my $old ($self->prior_item_named_values) {
        unless ($self->item_named_exists($old->name)) {
            $old->status(UNKNOWN);
            $self->item_named($old->name, $old);
        }
    }

    # Clear prior notification times for everything, on the
    # assumption that if the check comes back from UNKNOWN
    # its previous notification times are irrelevant.
    foreach my $item ($self->item_named_values) {
        $item->renotified_count_reset();
        $item->status_notified_time_clear();
    }
}

# Returns the overall status from all the items.
sub _calc_overall_status {
    my $self = shift;

    $self->overall_status(OK);

    foreach my $item ($self->item_named_values) {
        if ($item->has_worse_status($self->overall_status)) {
            $self->overall_status($item->status);
        }
    }
    $Log->log(2, "Overall status ", $self->overall_status, "\n");

    return $self->overall_status;
}

# Marks items as having changed status or not and returns a list of the
# changed ones.
sub _calc_changed_items {
    my $self = shift;

    $self->_changed_items_clear();

    if ($self->prior_item_named_values) {
        foreach my $item ($self->item_named_values) {
            my $prior_item = $self->prior_item_named($item->name);
            if ($prior_item) {
              if ($item->mark_status_change($prior_item->status)) {
                # Old item, status changed
                $Log->log(2, "Item '", $item->name, "' changed from ", 
                             $prior_item->status, " to ", $item->status, "\n");
                $self->_changed_items_push($item);
              }
            } else {
              # New item, mark as changed
              $Log->log(2, "Item '", $item->name, "' is new\n");
              $self->_changed_items_push($item);
            }
        }

        # Now check for any that did exist and now don't; that acts as a change
        foreach my $prior_item ($self->prior_item_named_values) {
            my $item = $self->item_named($prior_item->name);
            unless ($item) {
              $Log->log(2, "Prior item '", $prior_item->name, "' vanished\n");
              $self->_changed_items_push($prior_item);
              $self->_vanished_items_push($prior_item);
            }
        }

    } else {
        # On the first run, everything is marked as changed.
        $Log->log(2, "First run, marking everything as changed\n");
        $self->_changed_items_push($self->item_named_values);
    }

    $self->_status_changed($self->_changed_items_count > 0);

    $Log->log(2, "Overall status changed:  ", 
                 $self->_status_changed ? 'YES' : 'NO', "\n");
    return $self->_status_changed;
}

# Marks items as requiring notification or not.
# 1. State change from one problem state to another within the
#    renotify interval: no.
# 2. Outside the renotify interval: yes.
# Returns a list of the items needing notification.
sub _calc_notifying_items {
    my $self = shift;

    $self->_notifying_items_clear();
    my $now = time();

    my %notify_on = 
      ( OK       => $self->probe_record->notify_recovery,
        WARNING  => $self->probe_record->notify_warning,
        CRITICAL => $self->probe_record->notify_critical,
        UNKNOWN  => $self->probe_record->notify_unknown,
      );

    my $max_attempts = $self->probe_record->max_attempts || 1;

    foreach my $item ($self->item_named_values) {
        # Timestamp the current value.
        $item->value_time($now);

        my $prior_item = $self->prior_item_named($item->name);

        if ($prior_item) {
            $self->_propagate_prior_status($prior_item, $item);

            my $prior_time = $prior_item->status_notified_time($item->status);
            my $elapsed = $prior_time ? $now - $prior_time : -1;
            my $past_renotify_time = $self->_past_renotify_time($elapsed);
            my $should_notify = $item->should_notify($prior_item,
                                                     $past_renotify_time,
                                                     %notify_on);
            if ($should_notify) {
                $item->need_notify(1);
                $item->renotified_count($prior_item->renotified_count + 1);
                $item->status_notified_time($item->status, $now);
                $self->_notifying_items_push($item);
            }

            $Log->log(3, "Item '", $item->name, "' ",
                      $item->need_notify ? 'WILL ' : ' WILL NOT ',
                      "notify: status ", $item->status, ", item thinks it should: ",
                      $should_notify ? 'YES' : 'NO',
                      ", $elapsed elapsed seconds does ", $past_renotify_time ? '' : 'NOT ',
                      "trigger renotification\n");

            # Reset renotify count if item has recovered.
            if ($item->is_ok) {
                $item->renotified_count_reset();
            }

        } else {
            # First run, no prior status, alert if flag allows it
            if ($item->not_ok && $notify_on{$item->status}) {
                $item->need_notify(1);
                $item->status_notified_time($item->status, $now);
                $self->_notifying_items_push($item);
                $Log->log(4, "Item '", $item->name, "' will notify: ", $item->status,
                          ", no prior state\n");
            } else {
                $Log->log(4, "Item '", $item->name, "' first run, is OK\n");
            }
        }
    }

    # Iterate through vanished items to determine notification.  A 
    # vanished item represents either:
    #   1) an item that has become unmeasureable, or
    #   2) a problem that went away.
    # If a problem that went away (prior item was in non-OK state)
    # we want to notify if $notify_on{OK} is true.

    foreach my $vanished_item ($self->_vanished_items) {

      my $name    = $vanished_item->name();
      my $status  = $vanished_item->status();
      my $message = $vanished_item->message();

      # Fake up a new item to compare for should_notify
      my $item = NOCpulse::Probe::ItemStatus->new(
                   name => $name,
                   status => OK
                 );

      # Don't have to worry about renotify time since the item either
      # is now or was previously OK.
      my $should_notify = $item->should_notify($vanished_item, 1,
                                               %notify_on);

      if ($should_notify) {
          $item->need_notify(1);
          $self->_notifying_items_push($item);
      }

      $Log->log(3, "Vanished item '", $item->name, "' ",
                $item->need_notify ? 'WILL ' : ' WILL NOT ',
                "notify: status ", $item->status, ", item thinks it should: ",
                $should_notify ? 'YES' : 'NO', "\n");

    }

    $Log->log(2, $self->_notifying_items_count, " items need notification\n");

    $self->_should_notify($self->_notifying_items_count > 0);

    return $self->_should_notify;
}

# Propagate the previous per-status notification times and renotify count.
sub _propagate_prior_status {
    my ($self, $prior_item, $item) = @_;
    $item->status_notified_time($prior_item->status_notified_time);
    $item->renotified_count($prior_item->renotified_count);
}

# Format the overall status messages.
sub _format_messages {
    my $self = shift;

    # Don't reformat if already done, or if the text was explicitly set.
    return $self->detail_text if $self->detail_text;

    # Get lists of items by status and their renotify messages.
    my %by_status = ();
    my @renotify_msgs = ();
    foreach my $item ($self->item_named_values) {
        push(@{$by_status{$item->status}}, $item);
        my $count_msg = $item->format_renotify_count($self->_message_catalog);
        push(@renotify_msgs, $count_msg) if $count_msg;
    }

    # Lay out the message as criticals, then warnings, then the rest.
    my @message_parts = ();
    foreach my $status (CRITICAL, UNKNOWN, WARNING, OK) {
        next unless exists $by_status{$status};
        foreach my $item (sort { $a->sequence <=> $b->sequence} @{$by_status{$status}}) {
            next unless $item->message;
            push(@message_parts, $item->message);
        }
    }

    my $message = $self->context;
    if ($message) {
        $message .= ': ';
    }
    $message .= join('; ', @message_parts);

    # Escape the eol control characters so that they can be handled in HTML.
    $message =~ s/\r/\\r/g;
    $message =~ s/\n/\\n/g;
    $message .= "\n";

    $self->detail_text($message);

    my $notify_message = $message;
    $notify_message .= join('; ', @renotify_msgs) . "\n" if @renotify_msgs;
    $self->notification_text($notify_message);

    $Log->log(2, "Message: ", $self->detail_text);
    $Log->log(2, "Notification message ", $self->notification_text) if @renotify_msgs;

    return $self->detail_text;
}

sub translated_host_status {
    my $self = shift;

    my $status = $self->overall_status();

    if ($self->probe_record->probe_type eq 'HostProbe') {
        $status = 'UP'   if ($status eq OK);
        $status = 'DOWN' if ($status eq WARNING);
        $status = 'DOWN' if ($status eq CRITICAL);
    } elsif ($status eq 'WARN') {
        $status = WARNING;
    }
    return $status;
}

# Returns a named metric for the current command.
sub metric_named {
    my ($self, $name) = @_;
    return $self->command_record->metrics($name);
}

# Helpers


# Returns true value if the elapsed time is outside the
# renotification interval. Elapsed time of -1 means there
# is no prior time, so we are by definition past time.
sub _past_renotify_time {
    my ($self, $elapsed) = @_;
    my $interval_seconds = $self->probe_record->notification_interval * 60;
    return $elapsed < 0 || $elapsed >= $interval_seconds;
}

# Assigns the label and units from a metric to the item's own label and units.
sub _assign_metric_info {
    my ($self, $item) = @_;

    my $metric = $self->metric_named($item->name);
    if ($metric) {
        $item->label($metric->label);
        $item->units($metric->unit_label);
    }
    return $metric;
}

# Sets up an item as a metric, checking for crossed thresholds if
# $check_thresh is true. Message optionally overrides normal value
# formatting.
sub _setup_metric_item {
    my ($self, $item, $check_thresh, $message) = @_;

    $item->is_metric(1);

    $self->_assign_metric_info($item);

    if ($message) {
        # Override message coming in, such as saying that calculation can't be done
        $item->format_detailed_message($self->_message_catalog, $message);

    } elsif ($check_thresh) {
        my %threshold_cmd_params = $self->command_record->threshold_params_for($item->name)
          or $Log->log(1, "Warning: No threshold parameters for ", $item->name, "\n");

        $Log->dump(5, "Threshold parameters: ", \%threshold_cmd_params, "\n");

        $item->format_detailed_message($self->_message_catalog);

        if (%threshold_cmd_params and $item->is_numeric()) {
            my ($crossed, $what) = $self->thresholder->metric_crossed($item->name, $item->value,
                                                                      \%threshold_cmd_params);
            $self->_handle_crossed_threshold($item, $crossed, $what);
        }
    }
    return $item;
}

# Format the message for a crossed threshold.
sub _handle_crossed_threshold {
    my ($self, $item, $crossed_type, $thresh_value) = @_;

    if ($crossed_type) {
        defined($thresh_value)
          or throw NOCpulse::Probe::InternalError("No threshold value provided");

        $item->status($self->thresholder->threshold_as_status($crossed_type));
        my $thresh_msg = sprintf($self->_message_catalog->threshold($crossed_type), 
                                 $item->formatted_value($thresh_value),
                                 $item->formatted_units);
        $item->message($item->message . ' ' . $thresh_msg);
        $Log->dump(4, "Crossed $crossed_type threshold: ", $item, "\n");
    }
    return $item;
}


1;

__END__

=head1 NAME

NOCpulse::Probe::Result - Records probe status and time series results

=head1 SYNOPSIS

 package My::Probe;

 sub run {
    my %args = @_;

    my $result = $args{result};
    ...
    $result->context("Filesystem $fs");

    # Metrics and metric rates  
    $result->metric_value('pctused', $pctused, '%d');
    $result->metric_rate('writes_per_sec', $writes, '%.2f');

    # Non-metrics

    # Adds a value to the output string without thresholding or
    # recording as a time series metric. Appears in the output
    # message only.
    $result->item_value('Some stuff', $somestuff, '%d');

    # Customize the appearance of an item.
    my $item = $result->item_value('internal_name', $internal_value, '%d');
    $item->label("Thing");
    $item->units("things/sec");

    # Adds value and checks against thresholds, but no time series metric.
    # Only adds the item to the result if its status is not OK.
    $result->item_thresholded_value('Some other stuff', $somestuff, '%d', 
                                    { crit_max => $params{critical},
                                      warn_max => $params{warning} });

    # Can't find something entered by the user?
    $result->user_data_not_found('Filesystem', $fs);

    # Want to set overall status? Set a single item like this:
    $result->item_critical('Nothing works');
 }


=head1 DESCRIPTION

Probes use their Result object to record metrics and values for items
that are not metrics but are still of interest. The Result object
manages threshold and notification decisions and message
formatting.

Probes can record any number of items or metrics. The status for each
is recorded separately, so that changes for individual items can
trigger alerts and status changes.

=head1 METHODS

=over 4


=item context ( [$context_message] )

Gets or sets the context for the final output message. This appears at
the front of the message, and typically indicates the context of the
following metric information, such as "Filesystem: /dev/hda1".


=item metric_value ( $metric_name, $value, [$sprintf_format] )

Records a metric value. Checks against the threshold parameters defined
for the metric in the COMMAND_PARAMETER_THRESHOLD table and sets the
status accordingly. Formats the value with C<sprintf_format>, which defaults
to "%s".

Returns an ItemStatus instance.


=item metric_rate ( $metric_name, $raw_value, $sprintf_format, [$time_divisor], [$wrap] )

Records a metric rate. You provide the raw value, and the rate is
calculated using the previous raw value and timestamp. On the first
iteration, the result is a message indicating another iteration is
required, and the status is set to UNKNOWN.

If C<time_divisor> is provided, the seconds elapsed is divided by it.
For instance, a value of 60 gives you events per minute instead of
per second. The default is one, giving events per second.

If C<wrap> is provided, and the previous raw value for a rate is greater
than the current value, the raw value is assumed to be a counter that
has wrapped. The previous raw value is subtracted from the C<wrap> value
to get the proper difference.

Performs thresholding of the calculated rate as described
for C<metric_value>.

Returns an C<ItemStatus> instance.


=item item_value ( $name, $value, [$sprintf_format] )

Records an arbitrary value with a status of OK. The value appears in
the output message prefixed with C<name>.  You can also set the label and
units of measure that appear by calling the appropriate methods on the
returned C<ItemStatus> object.

Returns an C<ItemStatus> instance.


=item item_ok ( $name, $value )

=item item_warning ( $name, $value )

=item item_critical ( $name, $value )

=item item_unknown ( $name, $value )

These methods record an arbitrary value with a specific
status. Otherwise the same as C<item_value>.

All return an C<ItemStatus> instance.


=back

=head1 BUGS

Don't call C<overall_status> before you've added all your items or
metrics.  It calls C<finish>, which among other things calculates and
caches the overall status based on the worst status of any of its
items. This means that if you call the method before you have added
all your items, the status will not be calculated correctly. This also
applies to the C<detail_text>, C<notification_text>,
C<status_changed>, C<should_notify>, C<changed_items>, and
C<notifying_items> methods.

=head1 AUTHOR

 Rod McChesney <rmcchesney@nocpulse.com>
 Last updated: $Date: 2005-02-15 15:35:17 $

=head1 SEE ALSO

L<NOCpulse::Probe::Overview|PerlModules::NP::Probe::Overview>,
L<NOCpulse::Probe::DataSource::Overview|PerlModules::NP::Probe::DataSource::Overview>,
L<NOCpulse::Probe::ProbeRunner|PerlModules::NP::Probe::ProbeRunner>,
L<NOCpulse::Probe::ItemStatus|PerlModules::NP::Probe::ItemStatus>

=cut
