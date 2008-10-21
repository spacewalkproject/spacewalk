package NOCpulse::BlockingDBMNamespace;
use NOCpulse::SharedBlockingNamespace;
use GDBM_File;
@ISA=qw(NOCpulse::SharedBlockingNamespace);


sub initialize
{
	my ($self,$namespaceName,$instanceName) = @_;
	$self->SUPER::initialize;
        my %database;
        my $tries = 0;
        my $maxtries = 5;
        while (! tie(%database, 'GDBM_File', $instanceName.'.db', &GDBM_WRCREAT, 0640)) {
                if ("$!" ne "Resource temporarily unavailable") {
                   $tries = $tries + 1;
                   if ($tries >= $maxtries) {
                      print "ERROR: $filename - $!\n";exit -1;
                   }
                }
                sleep(1);
        }
	$self->{'data'} = \%database;
	return $self;					
}

sub DESTROY
{
	my $self = shift();
	my $tie = $self->{'data'};
	untie %$tie;
}

1
