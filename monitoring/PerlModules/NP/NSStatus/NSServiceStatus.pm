package NSServiceStatus;
use NOCpulse::NSStatus::NSStatusRecord;
@ISA = qw(NSStatusRecord);

sub Type
{
	return 'SERVICE'
}
sub DataSize
{
	return 25
}

sub last_check
{
	return shift()->timestamp();
}
sub set_last_check
{
	my ($self,$value) = @_;
	return $self()->set_timestamp($value);
}
sub hostname
{
	return shift()->get_data()->[2];
}
sub set_hostname
{
	my ($self,$value) = @_;
	return $self->get_data()->[2] = $value;
}
sub description_field
{
	return shift()->get_data()->[3];
}
sub set_description_field
{
	my ($self,$recid,$custid,$probe_type,$description) = @_;
	my $descrip = "$recid:$custid:$probe_type:$description";
	return $self->get_data()->[3] = $descrip;
}
sub recid
{
	return (split(':',shift()->description_field()))[0];
}
sub custid
{
	return (split(':',shift()->description_field()))[1];
}
sub probe_type
{
	return (split(':',shift()->description_field()))[2];
}
sub description
{
	return (split(':',shift()->description_field()))[3];
}
sub state
{
	return shift()->get_data()->[4];
}
sub set_state
{
	my ($self,$value) = @_;
	return $self->get_data()->[4] = $value;
}
sub attempts
{
	return shift()->get_data()->[5];
}
sub set_attempts
{
	my ($self,$current_attempt,$max_attempts) = @_;
	my $attempts = "$current_attempt/$max_attempts";
	return $self->get_data()->[5] = $attempts;
}
sub current_attempt
{
	return (split('/',shift()->attempts()))[0];
}
sub max_attempts
{
	return (split('/',shift()->attempts()))[1];
}
sub state_type
{
	my ($self,$value) = @_;
	return $self->get_data()->[6];
}
sub set_state_type
{
	my ($self,$value) = @_;
	return $self->get_data()->[6] = $value;
}
sub next_check
{
	my ($self,$value) = @_;
	return $self->get_data()->[7];
}
sub set_next_check
{
	my ($self,$value) = @_;
	return $self->get_data()->[7] = $value;
}
sub last_notification
{
	my ($self,$value) = @_;
	return $self->get_data()->[8];
}
sub set_last_notification
{
	my ($self,$value) = @_;
	return $self->get_data()->[8] = $value;
}

sub check_type
{
	my ($self,$value) = @_;
	return $self->get_data()->[9];
}
sub set_check_type
{
	my ($self,$value) = @_;
	return $self->get_data()->[9] = $value;
}
sub checks_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[10];
}
sub set_checks_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[10] = $value;
}
sub accept_passive_checks
{
	my ($self,$value) = @_;
	return $self->get_data()->[11];
}
sub set_accept_passive_checks
{
	my ($self,$value) = @_;
	return $self->get_data()->[11] = $value;
}
sub event_handler_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[12];
}
sub set_event_handler_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[12] = $value;
}
sub last_state_change
{
	my ($self,$value) = @_;
	return $self->get_data()->[13];
}
sub set_last_state_change
{
	my ($self,$value) = @_;
	return $self->get_data()->[13] = $value;
}
sub problem_has_been_acknowledged
{
	my ($self,$value) = @_;
	return $self->get_data()->[14];
}
sub set_problem_has_been_acknowledged
{
	my ($self,$value) = @_;
	return $self->get_data()->[14] = $value;
}
sub last_hard_state
{
	my ($self,$value) = @_;
	return $self->get_data()->[15];
}
sub set_last_hard_state
{
	my ($self,$value) = @_;
	return $self->get_data()->[15] = $value;
}
sub time_ok
{
	my ($self,$value) = @_;
	return $self->get_data()->[16];
}
sub set_time_ok
{
	my ($self,$value) = @_;
	return $self->get_data()->[16] = $value;
}
sub time_warning
{
	my ($self,$value) = @_;
	return $self->get_data()->[17];
}
sub set_time_warning
{
	my ($self,$value) = @_;
	return $self->get_data()->[17] = $value;
}
sub time_unknown
{
	my ($self,$value) = @_;
	return $self->get_data()->[18];
}
sub set_time_unknown
{
	my ($self,$value) = @_;
	return $self->get_data()->[18] = $value;
}
sub time_critical
{
	my ($self,$value) = @_;
	return $self->get_data()->[19];
}
sub set_time_critical
{
	my ($self,$value) = @_;
	return $self->get_data()->[19] = $value;
}
sub current_notification_number
{
	my ($self,$value) = @_;
	return $self->get_data()->[20];
}
sub set_current_notification_number
{
	my ($self,$value) = @_;
	return $self->get_data()->[20] = $value;
}
sub passive_checks_accepted
{
	my ($self,$value) = @_;
	return $self->get_data()->[21];
}
sub set_passive_checks_accepted
{
	my ($self,$value) = @_;
	return $self->get_data()->[21] = $value;
}
sub notifications_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[22];
}
sub set_notifications_enabled
{
	my ($self,$value) = @_;
	return $self->get_data()->[22] = $value;
}
sub check_latency
{
	my ($self,$value) = @_;
	return $self->get_data()->[23];
}
sub set_check_latency
{
	my ($self,$value) = @_;
	return $self->get_data()->[23] = $value;
}
sub execution_time
{
	my ($self,$value) = @_;
	return $self->get_data()->[24];
}
sub set_execution_time
{
	my ($self,$value) = @_;
	return $self->get_data()->[24] = $value;
}
sub plugin_output
{
	my ($self,$value) = @_;
	return $self->get_data()->[25];
}
sub set_plugin_output
{
	my ($self,$value) = @_;
	return $self->get_data()->[25] = $value;
}

sub dump
{
	my $self = shift();
	print "Last check: ".$self->humanDate($self->last_check());
	print "\n";
	print "Hostname: ".$self->hostname();
	print "\n";
	print "Description field: ".$self->description_field();
	print "\n";
	print "Recid: ".$self->recid();
	print "\n";
	print "Custid: ".$self->custid();
	print "\n";
	print "Probe type: ".$self->probe_type();
	print "\n";
	print "Description: ".$self->description();
	print "\n";
	print "State: ".$self->state();
	print "\n";
	print "Attempts: ".$self->attempts();
	print "\n";
	print "Current attempts: ".$self->current_attempt();
	print "\n";
	print "Max attempts: ".$self->max_attempts();
	print "\n";
	print "State type: ".$self->state_type();
	print "\n";
	print "Next check: ".$self->humanDate($self->next_check());
	print "\n";
	print "Check type: ".$self->check_type();
	print "\n";
	print "Enabled?: ".$self->checks_enabled();
	print "\n";
	print "Accept passive checks?: ".$self->accept_passive_checks();
	print "\n";
	print "Event handler enabled?: ".$self->event_handler_enabled();
	#print "\n";
	#print "Passive checks accepted: ".$self->passive_checks_accepted();
	print "\n";
	print "Last state change: ".$self->humanDate($self->last_state_change());
	print "\n";
	print "Problem has been acknowledged?: ".$self->problem_has_been_acknowledged();
	print "\n";
	print "Last hard state: ".$self->last_hard_state();
	print "\n";
	print "Time ok: ".$self->time_ok();
	print "\n";
	print "Time warning: ".$self->time_warning();
	print "\n";
	print "Time unknown: ".$self->time_unknown();
	print "\n";
	print "Time critical: ".$self->time_critical();
	print "\n";
	print "Last notification: ".$self->humanDate($self->last_notification());
	print "\n";
	print "Current notification number: ".$self->current_notification_number();
	print "\n";
	print "Notifications enabled: ".$self->notifications_enabled();
	print "\n";
	print "Check latency: ".$self->check_latency();
	print "\n";
	print "Execution time: ".$self->execution_time();
	print "\n";
	print "Plugin output: ".$self->plugin_output();
	print "\n\n";
}

1
