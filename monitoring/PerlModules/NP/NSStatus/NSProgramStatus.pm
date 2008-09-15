package NSProgramStatus;
use NOCpulse::NSStatus::NSStatusRecord;
@ISA = qw(NSStatusRecord);

sub Type
{
	return 'PROGRAM';
}
sub DataSize 
{
	return 10;
}

sub current_time
{
	return shift()->timestamp();
}
sub set_current_time
{
	my ($self,$time) = @_;
	return $self->set_timestamp($time);
}

sub program_start
{
	return shift()->get_data()->[2];
}
sub set_program_start
{
	my ($self,$time) = @_;
	return $self->get_data()->[2] = $time;
}

sub daemon_mode
{
	return shift()->get_data()->[3];
}
sub set_daemon_mode
{
	my ($self,$mode) = @_;
	return $self->get_data()->[3] = $mode;
}

sub mode
{
	return shift()->get_data()->[4];
}
sub set_mode
{
	my ($self,$mode) = @_;
	return $self->get_data()->[4] = $mode;
}

sub last_mode_change
{
	return shift()->get_data()->[5];
}
sub set_last_mode_change
{
	my ($self,$time) = @_;
	return $self->get_data()->[5] = $time;
}

sub last_command_check
{
	return shift()->get_data()->[6];
}
sub set_last_command_check
{
	my ($self,$time) = @_;
	return $self->get_data()->[6] = $time;
}

sub last_log_rotation
{
	return shift()->get_data()->[7];
}
sub set_last_log_rotation
{
	my ($self,$time) = @_;
	return $self->get_data()->[7] = $time;
}

sub executing_service_checks
{
	return shift()->get_data()->[8];
}
sub set_executing_service_checks
{
	my ($self,$bool) = @_;
	return $self->get_data()->[8] = $bool;
}

sub accept_passive_service_checks
{
	return shift()->get_data()->[9];
}
sub set_accept_passive_service_checks
{
	my ($self,$bool) = @_;
	return $self->get_data()->[9] = $bool;
}

sub enable_event_handlers
{
	return shift()->get_data()->[10];
}
sub set_enable_event_handlers
{
	my ($self,$bool) = @_;
	return $self->get_data()->[10] = $bool;
}

sub obsess_over_services
{
	return shift()->get_data()->[11];
}
sub set_obsess_over_services
{
	my ($self,$bool) = @_;
	return $self->get_data()->[11] = $bool;
}

sub dump
{
	my $self = shift();
	print "Current time: ".$self->humanDate($self->current_time);
	print "\n";
	print "Program start: ".$self->humanDate($self->program_start);
	print "\n";
	print "Daemon mode?: ".$self->daemon_mode;
	print "\n";
	print "Mode: ".$self->mode;
	print "\n";
	print "Last mode change: ".$self->humanDate($self->last_mode_change);
	print "\n";
	print "Last command check: ".$self->humanDate($self->last_command_check);
	print "\n";
	print "Last log rotation: ".$self->humanDate($self->last_log_rotation);
	print "\n";
	print "Executing service checks: ".$self->executing_service_checks;
	print "\n";
	print "Accept service checks: ".$self->accept_passive_service_checks;
	print "\n";
	print "Enable event handlers: ".$self->enable_event_handlers;
	print "\n";
	print "Obsess over services: ".$self->obsess_over_services;
	print "\n\n";

}

1
