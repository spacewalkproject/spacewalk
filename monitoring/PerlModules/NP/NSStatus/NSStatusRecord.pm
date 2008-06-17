package NSStatusRecord;
use NOCpulse::Object;
use NOCpulse::NSStatus::NSProgramStatus;
use NOCpulse::NSStatus::NSHostStatus;
use NOCpulse::NSStatus::NSServiceStatus;
use Date::Manip;

@ISA = qw(Object);

sub Initialize
{
	my $class = shift();
	my @objects;
	if ($class eq "NSStatusRecord") {
		NSProgramStatus->Initialize;
		NSHostStatus->Initialize;
		NSServiceStatus->Initialize;
	} else {
		$class->setClassVar('objects',\@objects);
	}
}

sub AddObject
{
	my $class = shift();
	my $object = shift();
	push(@{$class->getClassVar('objects')},$object);
}

sub Objects
{
	my $class = shift();
	if ($class eq "NSStatusRecord") {
		my %result;
		$result{'program'} = NSProgramStatus->Objects;
		$result{'hosts'} = NSHostStatus->Objects;
		$result{'services'} = NSServiceStatus->Objects;
		return \%result;
	} else {
		return $class->getClassVar('objects');
	}
}

sub DataSize
{
	return  1;
}

sub initialize
{
	my $self = shift();
	my $line = shift();
	if ($line) {
        	chomp($line);
        	my @parts = split(';',$line);
        	my ($date,$type) = split(' ',$parts[0]);
        	$date =~ s/\[(.*)\]/$1/;
        	shift(@parts);
        	unshift(@parts,$type);
        	unshift(@parts,$date);
		$self->set_data(\@parts);
		$self->morph;
		$self->AddObject($self);
	} else {
		my $array = [];
		$$array[$self->DataSize] = undef;
		$$array[1] = $self->Type;
		$self->set_data($array);
	}
	return $self;
}

sub asLine
{
	my $self = shift();
	my $parts = $self->get_data;
	my $savedate = shift(@$parts);
	my $line = "[$savedate] ".join(';',@$parts);
	unshift(@$parts,$savedate);
	return $line;
}


sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('data');
}

sub timestamp
{
	return shift()->get_data->[0];
}

sub set_timestamp
{
	my ($self,$value) = @_;
	return $self->get_data->[0] = $value;
}

sub type
{
	return shift()->get_data->[1];
}

sub set_type
{
	my ($self,$value) = @_;
	return $self->get_data->[1] = $value;
}

sub morph
{
	my $self = shift();
	if ($self->type eq 'PROGRAM') {return bless $self,NSProgramStatus}
	if ($self->type eq 'HOST') {return bless $self,NSHostStatus}
	if ($self->type eq 'SERVICE') {return bless $self,NSServiceStatus}
	return $self
}

sub humanDate
{
	my ($self,$seconds) = @_;
	return UnixDate("epoch ".$seconds,'%g');
}

sub dump
{
	my $self = shift();
	my $count = 0;
	foreach $item (@{$self->get_data}) {
		print $count.": ".$item."\n";
		$count ++;
	}
}

1
