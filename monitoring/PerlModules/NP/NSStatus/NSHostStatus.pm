package NSHostStatus;
use NOCpulse::NSStatus::NSStatusRecord;
@ISA = qw(NSStatusRecord);

sub Type
{
	return 'HOST'
}
sub DataSize
{
	return 14;
}

sub current_time
{
	my ($self,$value) = @_;
	return $self->timestamp();
}
sub set_current_time
{
	my ($self,$value) = @_;
	return $self->set_timestamp($value);
}

sub hostname_field
{
	my ($self,$value) = @_;
	return $self->get_data()->[2];
}
sub set_hostname_field
{
	my ($self,$value) = @_;
	return $self->get_data()->[2] = $value;
}

sub state
{
	my ($self,$value) = @_;
	return $self->get_data()->[3];
}
sub set_state
{
	my ($self,$value) = @_;
	$value = 'UP' if ($value eq 'OK');
	$value = 'DOWN' if ($value eq 'WARN');
	$value = 'DOWN' if ($value eq 'CRITICAL');
	#$value = 'UNREACHABLE' if ($value eq 'UNKNOWN');
	return $self->get_data()->[3] = $value;
}

sub last_check
{
	my ($self,$value) = @_;
	return $self->get_data()->[4];
}
sub set_last_check
{
	my ($self,$value) = @_;
	return $self->get_data()->[4] = $value;
}

sub last_state_change
{
	my ($self,$value) = @_;
	return $self->get_data()->[5];
}
sub set_last_state_change
{
	my ($self,$value) = @_;
	return $self->get_data()->[5] = $value;
}

sub problem_has_been_acknowledged
{
	my ($self,$value) = @_;
	return $self->get_data()->[6];
}
sub set_problem_has_been_acknowledged
{
	my ($self,$value) = @_;
	return $self->get_data()->[6] = $value;
}

sub time_up
{
	my ($self,$value) = @_;
	return $self->get_data()->[7];
}
sub set_time_up
{
	my ($self,$value) = @_;
	return $self->get_data()->[7] = $value;
}

sub time_down
{
	my ($self,$value) = @_;
	return $self->get_data()->[8];
}
sub set_time_down
{
	my ($self,$value) = @_;
	return $self->get_data()->[8] = $value;
}

sub time_unreachable
{
	my ($self,$value) = @_;
	return $self->get_data()->[9];
}
sub set_time_unreachable
{
	my ($self,$value) = @_;
	return $self->get_data()->[9] = $value;
}

sub last_notification
{
	my ($self,$value) = @_;
	return $self->get_data()->[10];
}
sub set_last_notification
{
	my ($self,$value) = @_;
	return $self->get_data()->[10] = $value;
}

sub current_notification_number
{
	my ($self,$value) = @_;
	return $self->get_data()->[11];
}
sub set_current_notification_number
{
	my ($self,$value) = @_;
	return $self->get_data()->[11] = $value;
}

sub notifications_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[12];
}
sub set_notifications_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[12] = $value;
}

sub event_handler_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[13];
}
sub set_event_handler_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[13] = $value;
}

sub checks_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[14];
}
sub set_checks_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[14] = $value;
}

sub plugin_output
{
	my ($self,$value) = @_;
	return $self->get_data()->[15];
}
sub set_plugin_output
{
	my ($self,$value) = @_;
	return $self->get_data()->[15] = $value;
}

sub dump
{
	my $self = shift();
	print "Current time: ".$self->humanDate($self->current_time());
	print "\n";
	print "Hostname field: ".$self->hostname_field;
	print "\n";
	print "State: ".$self->state;
	print "\n";
	print "Last state change: ".$self->humanDate($self->last_state_change);
	print "\n";
	print "Problem has been acknowledged?: ".$self->problem_has_been_acknowledged;
	print "\n";
	print "Time up: ".$self->time_up;
	print "\n";
	print "Time down: ".$self->time_down;
	print "\n";
	print "Time unreachable: ".$self->time_unreachable;
	print "\n";
	print "Last notification: ".$self->humanDate($self->last_notification);
	print "\n";
	print "Current notification number: ".$self->current_notification_number;
	print "\n";
	print "Notifications enabled?: ".$self->notifications_enabled;
	print "\n";
	print "Event handler enabled?: ".$self->event_handler_enabled;
	print "\n";
	print "Checks enabled?: ".$self->checks_enabled;
	print "\n";
	print "Plugin output: ".$self->plugin_output;
	print "\n\n";
}

1
