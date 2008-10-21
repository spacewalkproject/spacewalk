package RestartCounter;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

sub instVarDefinitions
{
	my ($self,@params) = @_;
	$self->SUPER::instVarDefinitions(@params);
	$self->addInstVar('config');
	$self->addInstVar('restarts',[]);
	$self->addInstVar('windowSize',5);
	return $self;
}

sub initialize 
{
	my ($self,$npconfig,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->set_config($npconfig);
}

sub windowStart
{
	my ($self,$now) = @_;
	$now = $now||time();
	return $now-($self->get_windowSize * 60);
}

sub recordRestart
{
	my $self = shift();
	my $restarts = $self->get_restarts;
	my $now = time();
	push(@$restarts,$now);
	my $windowStart = $self->windowStart($now);
	my $restart = 0;
	while ($restart < $windowStart) {
		$restart = shift(@$restarts);
	}
	unshift(@$restarts,$restart);
}

sub restartsInWindow
{
	my $self = shift();
	my $restarts = $self->get_restarts;
	return scalar(@$restarts);
}

sub writeStatusFile
{
	my ($self) = @_;
	
}
