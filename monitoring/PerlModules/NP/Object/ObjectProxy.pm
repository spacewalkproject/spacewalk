package NOCpulse::ObjectProxy;
use FreezeThaw qw(freeze thaw);

sub newInitialized
{
	my ($class,$connection) = @_;
	$class = ref($class)||$class;
	my $self = {};
	bless($self,$class);
	$self->{'connection'} = $connection;
	return $self;
}

sub DESTROY
{
	# so we actually do nothing
}

sub AUTOLOAD
{
        my ($self,@params) = @_;
        my ($class,$method) = ($AUTOLOAD =~ /(.*)::(.*)$/);
	my $frozenParams = freeze(@params);
	my $protoString = $method.','.$frozenParams;
	$self->{'connection'}->sendAll($protoString);
	# This must block 'til the remote end returns something.
	my $frozenData = $self->{'connection'}->readAll;
	return thaw($frozenData);
}
1
