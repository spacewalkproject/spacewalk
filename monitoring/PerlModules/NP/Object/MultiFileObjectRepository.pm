package NOCpulse::MultiFileObjectRepository;
use NOCpulse::AbstractObjectRepository;
use IO::File;
use IO::Dir;
use Fcntl qw(:flock);
use File::Basename;
@ISA = qw(NOCpulse::AbstractObjectRepository);

sub __handleForKey
{
        my ($self,$key) = @_;
        my $file = IO::Handle->new();
	my $filename = $self->get_databaseFilename.'.'.$key;
        if (open($file,"+>>$filename")) {
        	flock($file,LOCK_EX); #Blocks
        	seek($file,0,0);
		return $file;
	} else {
		return undef;
	}
}

sub _readObject
{
	my ($self,$handle,$key) = @_;
	if ($handle = $self->__handleForKey($key)) {
		my $result = join('',<$handle>);
		$handle->close;
		return $result||undef;
	} else {
		return undef;
	}
}

sub _writeObject
{
	my ($self,$handle,$key,$value) = @_;
	if ($handle = $self->__handleForKey($key)) {
		$handle->truncate(0);
		my $result = print $handle $value;
		$handle->close;
		return $result;
	} else {
		return 0;
	}
}

sub _keys
{
	my ($self,$handle) = @_;
	my $dirname = dirname($self->get_databaseFilename);
	my $filename = basename($self->get_databaseFilename);
	my %dir;
	tie %dir, IO::Dir, $dirname; 
	my @keys = grep(s/$filename\.(.*)/$1/,keys(%dir));
	untie %dir;
	return \@keys;
}

1
