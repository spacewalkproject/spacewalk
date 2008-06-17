package Windows::EventLog;

use strict;

use Error ':try';
use constant MAX_MESSAGES_SHOWN => 5;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $memory = $args{memory};

    my $log      = $params{log};
    my $type     = $params{eventtype};
    my $source   = $params{source};
    my $category = $params{category};
    my $event_id = $params{eventid};
    my $computer = $params{computer};

    my $ctx = "$log log";
    $ctx .= " $type events" if $type;
    $ctx .= ", source $source" if $source;
    $ctx .= ", category $category" if $category;
    $ctx .= ", event ID $event_id" if $event_id;
    $ctx .= ", computer $computer" if $computer;

    $result->context($ctx);

    my $command = $args{data_source_factory}->windows_command(%params);

    $params{prevtime} = $memory->{previous_time};

    try {
        my $last_event;
        my @events = $command->event_reader(%params);

        my $count = scalar(@events);

        if ($count > 0) { 
            # Sort in reverse order, first by severity, then by timestamp.
            # So the first event is the most recent, most severe event.
            my @sorted_events =  sort { $b->compare_relevance($a) } @events;
            $last_event = $sorted_events[0];
            $memory->{previous_time} = $last_event->timestamp;
        }

        my $label = 'Matching events';

        if ($params{prevtime}) {
            # Use %s to return exactly what perfdata gives
            $result->metric_value('evt_matches', $count);
        } else {
            # Don't threshold on the first run, because the counts will be
            # large and meaningless.
            $result->item_value($label . ' (first run)', $count, '%d');
        }
        if ($last_event) {
            $result->item_value("Last event", $last_event->to_string());
        }
    }
    catch NOCpulse::Probe::DataSource::MalformedEventError with {
        my $error = shift;
        my $msg = $error->message;
        $result->item_unknown($msg);
    }
}

1;
