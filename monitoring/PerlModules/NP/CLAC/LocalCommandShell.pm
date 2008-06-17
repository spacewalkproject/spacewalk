package LocalCommandShell;

=head1 NAME

LocalCommandShell - provides access to a shell locally


=head1 DESCRIPTION

LocalCommandShell provides access to a command shell via local fork to /bin/sh

=head1 REQUIRES

CommandShell

=cut

use NOCpulse::CommandShell;
@ISA=qw(CommandShell);

sub overview {
   return "This module gives shell based probes access a local command shell"
}

sub initialize
{
	my $self = shift();	
	$self->SUPER::initialize();
	$self->set_shellCommand('/bin/sh');
	$self->set_shellSwitches('-s');
	return $self;
}


1
