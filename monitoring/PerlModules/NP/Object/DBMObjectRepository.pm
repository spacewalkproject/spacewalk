package DBMObjectRepository;
use NOCpulse::AbstractObjectRepository;
use GDBM_File;
@ISA = qw(NOCpulse::AbstractObjectRepository);


sub _openFile
{
	my ($self,$filename) = @_;
	my %database;
        my $tries = 0;
        my $maxtries = 5;
	while (! tie(%database, 'GDBM_File', $filename.'.db', &GDBM_WRCREAT, 0640)) {
                if ("$!" ne "Resource temporarily unavailable") {
                   $tries = $tries + 1;
                   if ($tries >= $maxtries) {
                      print "ERROR: $filename - $!\n";exit -1;
                   }
                }
		sleep(1);
	}
	return \%database;
}

sub _closeFile
{
	my ($self,$handle) = @_;
 	return untie(%$handle);
}

sub _readObject
{
	my ($self,$handle,$key) = @_;
	return $$handle{$key}
}

sub _keys
{
	my ($self,$handle) = @_;
	my @keys = keys(%$handle);
	return \@keys;
}

sub _writeObject
{
	my ($self,$handle,$key,$value) = @_;
	return $$handle{$key} = $value;
}


1
