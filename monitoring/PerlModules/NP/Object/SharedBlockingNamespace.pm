package NOCpulse::SharedBlockingNamespace;
use NOCpulse::Namespace;
@ISA=qw(NOCpulse::Namespace);


sub initialize
{
	my ($self,$namespaceName,$instanceName) = @_;
	$self->SUPER::initialize;
	# Load up data here and hold a lock
	#$self->{'data'} = {};
	return $self;					
}

sub addInstVar
{
	my ($self,$varname,$value) = @_;
	if (! $self->has($varname)) {
		return $self->{'data'}->{$varname} = $value;
	};
}
sub set
{
	my ($self,$varname,$value) = @_;
	return $self->{'data'}->{$varname} = $value;
}
sub delete
{
	my ($self,$varname) = @_;
	return delete $self->{'data'}->{$varname};
}
sub get
{
	my ($self,$varname) = @_;
	return $self->{'data'}->{$varname};
}
sub has
{
	my ($self,$varname) = @_;
	return exists($self->{'data'}->{$varname})
}

sub DESTROY
{
	my $self = shift();
	#save data here and free the lock
}

1
