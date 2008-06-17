package NOCpulse::Probe::DataSource::EventReaderOutput;

use strict;

use POSIX 'strftime';

use Class::MethodMaker
  get_set =>
  [qw(
      timestamp
      type
      source
      category
      id
      computer
      message
      utc_offset
     )],
  new_with_init => 'new',
  ;

use constant SEVERITY_ORDER => 
  { 'Error'         => 5,
    'Failure Audit' => 4,
    'Warning'       => 3,
    'Success Audit' => 2,
    'Information'   => 1,
  };


sub init {
    my ($self, $event) = @_;

    $event or return;

    # When printing an event, adjust its time according to the GMT offset
    # and include the offset in the output.
    #$self->utc_offset($utc_offset);

    # Format
    # timestamp seconds since epoch
    # type      Error|Warning|Information
    # source    program producing the log entry
    # category  program-specific category
    # event id  numeric description of event
    # computer  the machine that logged the entry
    # message   event text
    if ($event =~ /^(\d+):([^:]+):([^:]+):([^:]+):(\d*):([^:]+):(.*)$/) {
        $self->timestamp($1);
        $self->type($2);
        $self->source($3);
        $self->category($4);
        $self->id($5);
        $self->computer($6);
        $self->message($7);
    } else {
        throw NOCpulse::Probe::DataSource::MalformedEventError("Event reader output cannot be parsed: $event");
    }
    return $self;
}

# Sorts by error severity, then timestamp.
sub compare_relevance {
    my ($self, $other) = @_;

    my $cmp = (SEVERITY_ORDER->{$self->type} <=> SEVERITY_ORDER->{$other->type});
    $cmp == 0 and ($cmp = $self->timestamp <=> $other->timestamp);
    return $cmp;
}

sub to_string {
    my $self = shift;

    my @tm = gmtime($self->timestamp);
    my $date_time = strftime("%a %b %d %T %Z", @tm);

    my @output = ();
    push(@output, "on " . $date_time);
    push(@output, "type " . $self->type);
    push(@output, "source " . $self->source);
    push(@output, "category " . $self->category);
    push(@output, "ID " . $self->id);
    push(@output, "computer " . $self->id);
    my $msg = $self->message;
    $msg =~ s/\r//g;
    push(@output, 'message "' . $msg . '"');

    return join(', ', @output);
}

1;

__END__
