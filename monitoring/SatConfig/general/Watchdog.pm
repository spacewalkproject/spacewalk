package Watchdog;
use SysVStep;
@ISA=qw(SysVStep);

sub startActions
{
	my $self = shift();
	$self->shell('mknod /dev/watchdog c 10 130');
	$self->shell('modprobe softdog');
	$self->addShellStopAction('rmmod softdog');
	$self->addShellStopAction('rm /dev/watchdog');
}


1;
