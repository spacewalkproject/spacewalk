package KudzuDevice;
use Data::Dumper;

sub Initialize
{
	my $class = shift;
	$class = ref($class) || $class;
	$class->{'records'} = [];
	open(FILE,'/etc/sysconfig/hwconf');
	$text = join('',<FILE>);
	close(FILE);
	@rawrecords = split(/^-$/m,$text);
	my $rawrecord;
	foreach $rawrecord (@rawrecords) {
		push(@{$class->{'records'}},$class->newInitialized($rawrecord));
	}
	return $class->{'records'};
}

sub AllWhereKeyOfValue
{
        my ($class,$key,$value) = @_;
        $class = ref($class) || $class;
	$class->Initialize if ! $class->{'records'};
	my (@result,$record);
	foreach $record (@{$class->{'records'}}) {
		if ( exists($record->{$key}) ) {
			if ($record->{$key} eq $value) {
				push(@result,$record);
			}
		}
	}
	return \@result;
}

sub AllOfClass
{
	my ($class,$hwclass) = @_;
	return $class->AllWhereKeyOfValue('class',$hwclass);
}

sub newInitialized
{
	my $class = shift();
	my %self;
	my $rawrecord = shift();
	%self = map {
		split(/: /,$_,2);
	} split(/\n/,$rawrecord);

	bless(\%self,$class);
	return \%self;
}

1;
