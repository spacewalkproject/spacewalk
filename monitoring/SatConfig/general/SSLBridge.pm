package SSLBridge;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);

# Remainder in NOCpulse.ini

sub startActions
{
        my $self = shift();
        $self->addShellStopAction('killall ssl_bridge.pl');
        $self->SUPER::startActions;
}

1;
