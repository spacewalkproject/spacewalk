package NOCpulse::Probe::ItemStatus;

use strict;
use Data::Dumper;

use constant PERSISTENT_FIELDS =>
    qw(
       name
       value
       message
       status
       raw_value
       value_time
       is_metric
       need_second_iteration
       zero_percentage_divisor
       status_changed
       need_notify
      );

use Class::MethodMaker
  get_set => 
  [qw(
       sequence
       label
       units
       value_format
      ), PERSISTENT_FIELDS],
  counter =>
  [qw(
      renotified_count
     )],
  # Hash of last notification time indexed by status
  hash =>
  [qw(
      status_notified_time
     )],
  # Hash of status strings mapped to numeric levels for comparisons
  static_hash =>
  [qw(
      status_level
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant OK       => 'OK';
use constant WARNING  => 'WARNING';
use constant UNKNOWN  => 'UNKNOWN';
use constant CRITICAL => 'CRITICAL';

NOCpulse::Probe::ItemStatus->status_level({OK => 1, WARNING => 2, UNKNOWN => 3, CRITICAL => 4});


sub init {
    my ($self, %args) = @_;
    $args{value_format} = '%s' unless $args{value_format};
    $self->hash_init(%args);
}

# Converts a counter value to a rate given its previous value and time.
# Handles wrapping if necessary.
# Returns the rate if there is a previous value, or undef if not.
sub counter_to_rate {
   my ($self, %args) = @_;

   my $previous_time  = $args{previous_time};
   my $previous_value = $args{previous_value};
   my $current_value  = $args{current_value};
   my $wrap           = $args{wrap};
   my $time_divisor   = $args{time_divisor} || 1;
   my $rate;

   if (defined($previous_value)) {
       my $counter_change;
       if ($current_value < $previous_value) {
           defined($wrap) and $counter_change = ($wrap - $previous_value) + $current_value;
           $Log->log(2, "Counter wrapped ($current_value < $previous_value), ",
                     "wrap offset '$wrap', real change $counter_change\n");
       } else {
           $Log->log(4, "Counter not wrapped ($current_value >= $previous_value)\n");
           $counter_change = ($current_value - $previous_value);
       }
       if (defined($counter_change)) {
           my $counter_elapsed = (time() - $previous_time);
           if ($counter_elapsed > 0) {
               $counter_elapsed /= $time_divisor;
               $rate = ($counter_change / $counter_elapsed);
               $Log->log(4, "Found $counter_change events in $counter_elapsed ",
                         "seconds/$time_divisor: $rate events/sec\n");
           } else {
               $Log->log(4, "Found $counter_change events, but elapsed time is zero\n");
           }
       } else {
           $Log->log(4, "Counter wrapped and no wrap offset provided, need 2nd iteration\n");
       }
   } else {
       $Log->log(4, "No previous value for counter, need 2nd iteration\n");
   }
   return $rate;
}

# Calculates a rate based on the difference between $value and $prior->raw_value.
# Sets this item's raw value to the value, and its value to the rate.
sub as_rate {
    my ($self, $raw_value, $prior, $time_divisor, $wrap) = @_;

    $Log->log(4, "Raw value $raw_value, prior $prior\n");

    $self->raw_value($raw_value);

    if ($prior) {
        my $rate = $self->counter_to_rate(previous_time  => $prior->value_time,
                                          previous_value => $prior->raw_value,
                                          current_value  => $raw_value,
                                          time_divisor   => $time_divisor,
                                          wrap           => $wrap);
        if (defined($rate)) {
            $self->value($rate);
            $self->need_second_iteration(0);
        }
    }
    unless (defined($self->value)) {
        $self->need_second_iteration(1);
        $self->status(OK);
    }
    return $self;
}

# Calculates a percentage value and sets this item's value to it.
sub as_percentage {
    my ($self, $part_value, $total_value) = @_;

    $Log->log(4, "Calculate percent as $part_value / $total_value * 100\n");

    if ($total_value != 0) {
        $self->value(($part_value / $total_value) * 100);
    } else {
        $self->zero_percentage_divisor(1);
        $self->value(0.0);
        $self->status(OK);
    }
    return $self;
}

# Returns true if current status is worse than the other status constant.
sub has_worse_status {
    my ($self, $other_status) = @_;
    return $self->status_level($self->status) gt $self->status_level($other_status);
}

# Returns units formatted with a leading space if they start with letters.
sub formatted_units {
    my $self = shift;
    if (length($self->units) > 0 && $self->units =~ /^\w/) {
        return ' '.$self->units;
    }
    return $self->units;
}

# Sets this item's message to the formatted string with the message catalog's
# result->detailed format of the current label, value, and units.
# If $message is present, uses it instead of the value and units.
sub format_detailed_message {
    my ($self, $message_catalog, $message) = @_;

    $message_catalog ||= NOCpulse::Probe::MessageCatalog->instance();

    my $label = $self->label || $self->name;

    if ($message) {
        $self->message(sprintf($message_catalog->result('detailed'), $label, $message));
    } elsif ($self->need_second_iteration) {
        $self->message(sprintf($message_catalog->result('need_second_iteration'), $label));
    } elsif ($self->zero_percentage_divisor) {
        $self->message(sprintf($message_catalog->result('zero_percentage_divisor'), $label));
    } else {
        $self->message(sprintf($message_catalog->result('detailed'),
                               $label, $self->formatted_value, $self->formatted_units));
    }
    return $self->message;
}

# Formats the renotification count for this item if it needs
# notification and its count is > 0.
sub format_renotify_count {
    my ($self, $message_catalog) = @_;

    my $rnc = $self->renotified_count;
    $Log->log(4, "renotified_count for ", $self->name, " = $rnc \n");
    if ($rnc and $self->need_notify) {
        my $label = $self->label || $self->name;
        return sprintf($message_catalog->result('renotification'), $rnc, $label);
    }
    return undef;
}

# Formats this item's value using its value_format as an sprintf
# format specifier, and adding commas as thousands separators.
# Optionally accepts another value to format by these rules,
# for instance a threshold value.
sub formatted_value {
    my ($self, $format_what) = @_;

    defined($format_what) or $format_what = $self->value;

    my $sprintf_format = $self->value_format || '%s';
    unless ($self->is_numeric($self->value)) {
        $sprintf_format = '%s';
    }
    my $value = sprintf($sprintf_format, $format_what);

    if ($sprintf_format ne '%s') {
        $value = $self->add_thousands_separator($value);
    }
    return $value;
}

sub is_numeric {
    my ($self, $value) = @_;
    $value ||= $self->value;
    # See Perl Cookbook recipe 2.1
    return $value =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;
}

sub add_thousands_separator {
  my ($class, $value) = @_;

  # See Perl Cookbook recipe 2.17
  $value = reverse($value);
  $value =~ s/(\d{3})(?=\d)(?!\d*\.)/$1,/g;
  return scalar reverse $value;
}

sub is_ok {
    my $self = shift;
    return $self->status eq OK;
}

sub not_ok {
    my $self = shift;
    return not $self->is_ok;
}

# Marks this item as changed compared to a previous one if the status is different.
# Returns true if changed.
sub mark_status_change {
    my ($self, $prior_status) = @_;
    $self->status_changed($self->status ne $prior_status);
    return $self->status_changed;
}

# Returns true if current state is:
#   not OK and the other state is OK and the new state should notify;
#   OK, the other state is not OK, and $notify_on{OK} is true
sub should_notify {
    my ($self, $prior, $past_renotify, %notify_on) = @_;

    my $changed = (($self->not_ok and $prior->is_ok)
                   or ($notify_on{OK} and $self->is_ok and $prior->not_ok)
                   or $self->has_worse_status($prior->status));

    if ($self->not_ok) {
        # If it was bad before and still is bad, and it's time for renotification,
        # notify. Notification might still be suppressed by attempt count, however.
        $changed ||= ($past_renotify && $prior->not_ok);

        # Match against the notify types -- recovery already handled above.
        $changed &&= $notify_on{$self->status};
    }

    $Log->log(2, "for '", $self->name, "'? ", $changed ? 'YES' : 'NO',
              "\n\tStatus ", $self->status,
              ", prior ", $prior->status,
              ", due for renotify '", $past_renotify, "'",
              ", worse status '", $self->has_worse_status($prior->status), "'",
              "\n\tNotify flags ",
              (map { "$_ => $notify_on{$_} " } sort keys %notify_on),
             "\n");

    return $changed;
}

sub deep_equal {
    my ($self, $other) = @_;
    return $self->name eq $other->name
      and $self->sequence == $other->sequence
      and $self->value == $other->value
      and $self->label eq $other->label
      and $self->units eq $other->units
      and $self->message eq  $other->message
      and $self->status eq  $other->status
      and $self->raw_value == $other->raw_value
      and $self->value_time == $other->value_time
      and $self->value_format eq $other->value_format
      and $self->is_metric == $other->is_metric;
}

sub to_string {
    my $self = shift;
    return Dumper($self);
}

1;

__END__

=head1 NAME

NOCpulse::Probe::ItemStatus - Status for a single item calculated by a probe

=head1 SYNOPSIS

 # Create an item
 my $item = NOCpulse::Probe::ItemStatus->new();

 # Modify its appearance
 my $hit_rate = 93.25678;
 $item->name('hit_rate');
 $item->label('Hit rate');
 $item->units('%');
 $item->value_format('%.2f');

 # Produces this message: Hit rate 93.26%
 $item->format_detailed_message();

 # Override automatic message
 $item->message('The hit rate is....', $hit_rate);


=head1 DESCRIPTION

Each probe records the value and status of one or more items in a
L<Result|PerlModules::NP::Probe::Result> object. These items are C<ItemStatus>
instances. Usually you work with the items through the C<Result> object, but
in some cases you need to override some of the automatic settings.


=head1 METHODS

=over 4

=item name ( [$new_name] )

Gets or sets name. The name is the key under which
the item is stored in the state file, so adding a second item with the
same name overwrites the first.


=item label ( [$new_label] )

Gets or sets label. The label is used by C<format_detailed_message>
if present, otherwise the name is used.


=item value ( [$new_value] )

Gets or sets the value. This is typically numeric, but may be a string
when reporting something like router status.


=item value_time ( [$new_time] )

Gets or sets the time (as seconds since epoch) when the value was recorded.


=item raw_value ( [$new_value] )

Gets or sets the raw value. The raw value is stored for use in rate
calculations; in this case the C<value> stores the rate and the
C<raw_value> stores the actual value retrieved.


=item units ( [$new_units] )

Gets or sets units of measure. The units are appended
to the formatted value in the message created by
C<format_detailed_message>.


=item value_format ( [$new_format] )

Gets or sets C<sprintf> format for the value. Default is %s.


=item is_metric ( [$new_flag] )

Gets or sets the flag for this item being a metric. Metrics attempt to
do threshold calculations based on the C<COMMAND_PARAMETER_THRESHOLD>
metadata, and their values are queued when the probe finishes.


=item need_second_iteration ( [$new_flag] )

Gets or sets the flag for this item requiring a second iteration to
calculate.  Applies to rate calculations only, in which two values
must be collected before the first rate can be calculated.


=item zero_percentage_divisor ( [$new_flag] )

Gets or sets the flag for this item being unable to calculate a
percentage because the base value was zero. Set in C<as_percentage>
and used for error reporting.


=item status_changed ( [$new_flag] )

Gets or sets the flag for whether this item has a different status
than the last time it was collected.


=item need_notify ( [$new_flag] )

Gets or sets the flag for whether this item has a different status
than the last time it was collected.


=item renotified_count ( [$new_count] )

Gets or sets the number of times this item has caused a notification.


=item status_notified_time ( [$status_string] )

Hash of last notification time indexed by status. For instance,
CRITICAL, WARNING, and OK could each trigger a notification for this
item, but subsequent alerts should be throttled according to the
renotification interval. Storing the time for each status makes this possible.


=item format_detailed_message ( [$message_catalog], [$message] )

Sets the message to the formatted string using the C<sprintf> format
defined in C<$message_catalog-E<gt>result-E<gt>("detailed")> with the label,
value, and units.  If C<label> is unset, uses C<name>. If C<$message>
is present, uses it instead of the value and units. If
C<$message_catalog> is not set, uses C<MessageCatalog-E<gt>instance()>.
Also handles formatting of C<need_second_iteration> and
C<zero_percentage_divisor> messages.

Returns the message.


=item formatted_value ( )

Returns the value formatted using the C<value_format>. If the format
is not %s, commas are inserted as thousands separators with C<add_thousands_separator>.


=item formatted_units ( )

Returns units of measure formatted for appending to a data value. If the unit string is a
punctuation mark, no space is added before it, otherwise one is. For
instance, "%" is formatted as 10%, while "events/sec" is formatted as
10 events/sec.


=item format_renotify_count ( [$message_catalog] )

Formats the renotification count for this item if it needs
notification and its count is > 0.


=item is_numeric ( $value )

Returns 1 if the value is a valid integer or floating-point number.


=item add_thousands_separator ( $value )

Adds commas as thousands separators to a numeric value and returns it.


=item as_percentage ( $part_value, $total_value )

Calculates a percentage as

 $part_value / $total_value) * 100

if C<$total_value> is nonzero. Sets the C<zero_percentage_divisor>
flag accordingly.


=item as_rate ( $raw_value, $prior_item, $time_divisor, $wrap )

Calculates a rate based on the difference between C<$value> and C<$prior-E<gt>raw_value>.
Sets C<$self-E<gt>raw_value> to C<$raw_value>, and C<$self-E<gt>value> to the rate.
Also sets the C<need_second_iteration> flag as appropriate.


=item counter_to_rate ( %args )

Calculates a rate from the previous time and value and the current
value. Possible arguments are:

 previous_time
 previous_value
 current_value
 wrap
 time_divisor

C<wrap> is the maximum value the counter can have, if any. If
the current value is less than the previous value and C<wrap> is
specified, the counter is adjusted to account for the apparent
wraparound. Returns a value in events per second unless
C<time_divisor> is specified, in which case the elapsed time is
divided by it to produce events per any desired period.  Called by
C<as_rate>.


=item is_ok ( )

Returns 1 if the current status is OK.


=item not_ok ( )

Returns 1 if the current status is not OK.


=item has_worse_status ( $other_status )

Returns true if current status is worse than the other status constant.
Worse is defined by this order: CRITICAL > UNKNOWN > WARNING > OK.


=item mark_status_change ( $prior_status_item )

Marks this item as changed compared to a previous one if the status is different.
Returns true if changed.


=item should_notify ( $prior_item, $is_past_renotify_time, %notify_on )

Returns true if the current status is ready for notification or
renotification and the current state is:

Not OK and the other state is OK and C<$notify_on{$self-E<gt>status}> is true
(the new state should notify);

OK, the other state is not OK, and $notify_on{OK} is true


=back

=head1 BUGS

=head1 AUTHOR

Rod McChesney <rmcchesney@nocpulse.com>

Last update: $Date: 2004-11-18 17:13:17 $

=head1 SEE ALSO

L<NOCpulse::Probe::Overview|PerlModules::NP::Probe::Overview>,
L<NOCpulse::Probe::Result|PerlModules::NP::Probe::Result>

=cut
