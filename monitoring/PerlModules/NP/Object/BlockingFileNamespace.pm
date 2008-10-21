package NOCpulse::BlockingFileNamespace;
use NOCpulse::SharedBlockingNamespace;
@ISA=qw(NOCpulse::SharedBlockingNamespace);
use IO::File;
use Fcntl qw(:flock);
use FreezeThaw qw(freeze thaw);


sub initialize
{
	my ($self,$namespaceName,$instanceName) = @_;
	$self->SUPER::initialize;
	my $file = IO::Handle->new();
	open($file,"+>>$namespaceName.$instanceName") ||die("Open failed");
	flock($file,LOCK_EX) || die('Lock failed');
	seek($file,0,0) || die('seek failed');
	$self->{'file'} = $file;
	my $data = <$file>;
	if ($data) {
		my @dataArray = thaw($data);
		$self->{'data'} = shift(@dataArray);
	} else {
		$self->{'data'} = {};
	}
	return $self;					
}

sub DESTROY
{
	my $self = shift();
	my $file = $self->{'file'};
	my $frozenData = freeze($self->{'data'});
	truncate($file,0);
	print $file $frozenData;
	close($file);
}

1
