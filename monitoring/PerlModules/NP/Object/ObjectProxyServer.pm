package NOCpulse::ObjectProxyServer;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);
use FreezeThaw qw(freeze thaw);

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('object');
	$self->addInstVar('connection');
	return $self;
}

sub initialize
{
	my ($self,$object,$connection) = @_;
	$self->set_object($object);
	$self->set_connection($connection);
	return $self;
}

sub run
{
	my $self = shift();
	my $protoString = $self->get_connection->readAll;
	my ($message,$frozenParams) = split(/,/,$protoString,2);
	my @params = thaw($frozenParams);
	my $object = $self->get_object;
	my $perlCode = 'sub {$object->'.$message.'(@params)}';
	my $closure = eval($perlCode);
	my $result = &$closure;
	$self->get_connection->sendAll(freeze($result));
}

1
