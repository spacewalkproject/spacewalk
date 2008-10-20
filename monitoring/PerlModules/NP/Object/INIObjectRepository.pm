package NOCpulse::INIObjectRepository;
use NOCpulse::AbstractObjectRepository;
use Config::IniFiles;
@ISA = qw(NOCpulse::AbstractObjectRepository);

$iniParameter = "storeString";

sub fileExtension
{
	my $class = shift();
	return ".ini";
}

sub _openFile
{
	my ($self,$filename,$params) = @_;
	return Config::IniFiles->new( -file=>"$filename");
}

sub _closeFile
{
	my ($self,$handle) = @_;
	# Not done with INIs just return true
	1
}

sub _readObject
{
	my ($self,$handle,$key) = @_;
	return $handle->val($key,$iniParameter);
}

sub _writeObject
{
	my ($self,$handle,$key,$value) = @_;
	print "Writing $handle $key $value\n\n";
	if (! $handle->setval($key,$iniParameter,$value)) {
		$handle->newval($key,$iniParameter,$value);
	};
	$handle->RewriteConfig;
}

sub _keys
{
	my ($self,$handle) = @_;
	@keys = $handle->Sections;
	return \@keys;
}

1
