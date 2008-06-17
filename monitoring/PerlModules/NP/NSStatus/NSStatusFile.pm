package NSStatusFile;
use NOCpulse::Object;
use NOCpulse::NSStatus::NSStatusRecord;
@ISA = qw(Object);

#Class Methods
sub Parse
{
	my $class = shift();
	#Object::SystemIni('/etc/NOCpulse.ini');
	NSStatusRecord->Initialize;
	return $class->newInitialized($class->ConfigValue('filename'));
}

sub initialize
{
	my ($self,$filename) = @_;
	if ($filename) {
		my @records;
		open(FILE,$filename);
		if (-d FILE) {
			opendir(DIR,$filename);
			while ($file = readdir(DIR)) {
				if ($file !~ /^\..*/) {
					open(FILE,"$filename/$file");
					NSStatusRecord->newInitialized(join('',<FILE>));
					close(FILE);
				}
			}
			closedir(DIR);
			$self->set_objects(NSStatusRecord->Objects);
		} else {
			while ($line = <FILE>) {
				NSStatusRecord->newInitialized($line);
			}
			close(FILE);
			$self->set_objects(NSStatusRecord->Objects);
		}
	} else {
		$self->set_objects({'program'=>[undef],'hosts'=>[],'services'=>[]});
	}
	return $self;
}


sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('objects');
}

sub program
{
	my $self = shift();
	return $self->get_objects()->{'program'}->[0]
}

sub addProgram
{
	my ($self,$program) = @_;
	$self->get_objects()->{'program'} = [$program];
}

sub hosts
{
	my $self = shift();
	return $self->get_objects()->{'hosts'}
}

sub addHost
{
	my ($self,$host) = @_;
	push(@{$self->get_objects()->{'hosts'}},$host);
}

sub services
{
	my $self = shift();
	return $self->get_objects()->{'services'}
}

sub addService
{
	my ($self,$service) = @_;
	push(@{$self->get_objects()->{'services'}},$service);
}

sub asLines
{
	my $self = shift();
	my $result;
	if (defined($self->program)) {
		$result .= $self->program->asLine;
	}
	map {$result .= $_->asLine()} @{$self->hosts()};
	map {$result .= $_->asLine()} @{$self->services()};
	return $result;
}

sub writeTo
{
	my ($self,$filename) = @_;
	my $fullPath = $self->configValue('logDirectory')."/$filename";
	if (open(FILE,">$fullPath")){
		print FILE $self->asLines;
		return close(FILE);
	} else {
		return 0;
	}
}

sub remove
{
	my ($self,$filename) = @_;
	my $fullPath = $self->configValue('logDirectory')."/$filename";
	return unlink($fullPath);
}


sub dump
{
	my $self = shift();
	if (defined($self->program)) {
		$self->program->dump();
	}
	map {$_->dump()} @{$self->hosts()};
	map {$_->dump()} @{$self->services()};
}

1
