package ConfigObject;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('configFile');
	$self->addInstVar('id',undef);
	$self->addInstVar('parent',undef);
	$self->addInstVar('validators',[]);
}

sub initialize
{
	my ($self,$id,$parent) = @_;
	if (defined($id)) {
		$self->set_id($id);
	}
	if (defined($parent)) {
		$self->set_parent($parent);
	}
	return $self;
}

sub addEach
{
	my ($self,$hashname,$array) = @_;
	my $item;
	foreach $item (@$array) {
		$self->add($hashname,$item);
	}
}

sub add
{
	my ($self,$hashname,$object) = @_;
	my $hash = $self->get($hashname);
	$hash->{$object->get_id} = $object;
}

sub objectNamed
{
	my ($self,$hashname,$id) = @_;
	my $hash = $self->get($hashname);
	if (defined($hash)) {
		return $hash->{$id};
	} else {
		die("Unknown hash $hashname\n");
	}
}

##########################################
# Next  stuff deals with ini file i/o


sub nosave
{
	return {'parent'=>1};
}

sub contextName
{
	my ($self,$parent) = @_;
	if (defined($self->get_id)) {
		if ($parent) {
			return $parent.ref($self).'.'.$self->get_id.'.';
		} else {
			return ref($self).'.'.$self->get_id.'.';
		}
	} else {
		return $parent;
	}
}

sub fullContextName
{
	my $self = shift;
	if ($self->get_parent) {
		return $self->get_parent->fullContextName.ref($self).'.'.$self->get_id.'.';
	} else {
		return '';
	}
}

sub asConfigData
{
	my ($self,$parentContext) = @_;
	my $result;
	my ($name,$class,$value);
	my @blessed;
	while (($name,$value) =  each(%$self)) {
		if ( defined($value) and ($name ne 'id') and ($name ne 'configFile') and (! exists($self->nosave->{$name})) ) {
			if (! ref($value)) {
					$result .= $self->contextName($parentContext)."$name=$value\n";
			} elsif ( ref($value) =~ /HASH/ ) {
				# Assumption: it's a hash of instances of ConfigObjects
				my ($key,$val);
				while (($key,$val) = each(%$value)) {
					push(@blessed,$val->asConfigData($self->contextName($parentContext)));
				}
			}
		}
	}
	$result .= join('',@blessed);
	return $result;
}

sub writeToFile
{
	my ($self) = @_;
	open(FILE,'>'.$self->configValue('configFile'));
	print FILE $self->asConfigData;
	close(FILE);
}

sub applySetting
{
	my ($self,$pathParts,$value) = @_;
	while ($entity = shift(@$pathParts)) {
		if (scalar(@$pathParts)) {
			$id = shift(@$pathParts);
			if ($self->get($entity)) {
				if (! $self->get($entity)->{$id}) {
					my $newOne = $entity->newInitialized($id,$self);
					$self->add($entity,$newOne);
				}
				$self->get($entity)->{$id}->applySetting($pathParts,$value);
			} else {
				# This is something we don't know about - probably
				# a user typo
				$self->dprint(0,"Unrecognized element of ".ref($self).": $entity\n");
			}
		} else {
			$self->set($entity,$value);
		}
	}
}

sub readFromFile
{
	my ($self,$filename) = @_;
	if (! $filename) {
		$filename = $self->configValue('configFile');
	}
	if (! -f $filename ) {
		print "!!! ******* ERROR ******* !!!: NO CONFIG FILE FOR ".ref($self)." ($filename)!!!!\n";
	} else {
		open(FILE,$filename);
		my ($line,$pathPart,$value,@pathParts,$entity,$id);
		while ($line =  <FILE>) {
			if ( $line !~ /^\s*#.*$/ ) {
				chomp($line);
				$line =~ s/(\S+)\s*$/$1/;
				($pathPart,$value) = split(/\=/,$line,2);
				@pathParts = split(/\./,$pathPart);
				$self->applySetting(\@pathParts,$value);
			} # else skip comments
		}
		close(FILE);
	}
	return $self;
}
##########################################
# Next  stuff deals with validation

sub isValid
{
	my ($self,$parent) = @_;
	my $validators = $self->get_validators;
	my $validator;
	my $isValid = 1;
	foreach $validator (@$validators) {
		if (! $validator->isValid($self,$parent)) {
				$self->dprint(0,$validator->get_errorMessage."\n");
			$isValid = 0;
		}
	}
	return $isValid;
}

sub addValidators
{
	my ($self,@newValidators) = @_;
	my $validators = $self->get_validators;
	push(@$validators,@newValidators);
}

sub describe
{
	my ($self,$indents) = @_;
	my $validators = $self->get_validators;
	my $validator;
	my $result = "\t" x $indents;
	$result .= "Class: ".ref($self)."\n";
	$indents = $indents + 1;
	foreach $validator (@$validators) {
		$result .= $validator->describe($indents);
	}
	return $result;
}

package SatConfig::cluster::Validator;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('name');
	$self->addInstVar('description');
	$self->addInstVar('required');
	$self->addInstVar('optional');
	$self->addInstVar('format');
	$self->addInstVar('errorMessage');
}

sub initialize
{
	my ($self,%params) = @_;
	my ($key,$value);
	while (($key,$value) = each(%params)) {
		$self->set($key,$value);
	}
	return $self;
}

sub error
{
	my($self,$object,$value,$umessage) = @_;
	my $context = $object->fullContextName;
	my $message;
	if (! $umessage ) {
		if ($value) {
			$message = $context.$self->get_name."=$value is invalid";
		} else {
			$message = $context.$self->get_name." is invalid";
		}
	} else {
		if ($value) {
			$message = $context.$self->get_name."=$value $umessage";
		} else {
			$message = $context.$self->get_name." $umessage";
		}
	}
	$message .= "\n(".$context.$self->get_name.' should be: '.$self->get_description.")\n";
	$self->set_errorMessage($message);
	return 0;
}

sub isValid
{
	my ($self,$object,$parent) = @_;
	my $name = $self->get_name;
	my $instvar = $object->get($name);
	if ( defined($instvar) ) {
		my $format = $self->get_format;
		my $formatType = ref($format);
		if ( $formatType =~ /CODE/ ) {
			# {}
			if ( &$format($instvar) ) {
				return 1;
			} else {
				return $self->error($object,$instvar);
			};
		} elsif ($formatType =~ /Regexp/ ) {
			# qr//
			if ($instvar =~ $format) {
				return 1;
			} else {
				return $self->error($object,$instvar);
			}
		} elsif ($self->can($format)) {
			# Have a method by the name of the format
			if ($self->$format($instvar)) {
				return 1;
			} else {
				return $self->error($object,$instvar);
			}
		} else {
			# hash of instances of ConfigObject subclasses
			# where the type of instance should be $format
			my ($key,$value);
			my $count = 0;
			while (($key,$value) = each(%$instvar)) {
				# Each instance should be of the proper type
				# and should be valid by its own definition of 
				# valid.
				if ( ref($value) eq $format ) {
					if (! $value->isValid($object)) {
						# Object says it isn't valid
						return $self->error($object,undef);
					} else {
						# We have a good one - count it
						$count++;
					}
				} else {
					# Not of the proper class (probably not possible)
					return $self->error($object,undef,"is the wrong type");
				}
			}
			if ($count < $self->get_required) {
				# They're all valid, but there aren't enough
				# of them.
				return $self->error($object,undef,"should have at least ".$self->get_required." defined");
			} else {
				# They're all valid and there are enough of them
				return 1;
			}
		}
	} else {
		if ($self->get_required) {
			# Field is required but not populated
			return $self->error($object,undef,"is required but not defined");
		} else {
			# Field isn't populated but isn't required, so it's ok
			return 1;
		}
	}
}

sub integer
{
	my ($self,$value) = @_;
	return ($value =~ /^\d+$/);
}

sub ipAddress
{
	my ($self,$value) = @_;
	return (($value =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
        and $1 >= 0 and $1 <= 255 
        and $2 >= 0 and $2 <= 255 
        and $3 >= 0 and $3 <= 255 
        and $4 >= 0 and $4 <= 255);
}

sub fqdn
{
	my ($self,$value) = @_;
	return ($value  =~ /^[a-zA-Z0-9][-\w]*(?:\.[-\w]+)*/);
}

sub cidrMask
{
	my ($self,$value) = @_;
	return ($value =~ /^(\d+)$/ and $1 >= 1 and $1 <= 32);
}

sub boolean
{
	my ($self,$value) = @_;
	return  ($value =~ /^[10]$/);
}

sub deviceName
{
	my ($self,$value) = @_;
	return ($value =~ /^\w+\d+$/);
}

sub macAddress
{
	my ($self,$value) = @_;
	return ($value =~ /^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$/);
}

sub string
{
	my ($self,$value) = @_;
	return ($value =~ /\S+/);
}

sub describe
{
	my ($self,$indents)  = @_;
	my $result = "\t" x $indents;
	$result .= "Name: ".$self->get_name.' ';
	$result .= "Format: ".$self->get_format.' ';
	if ($self->get_required) {
		$result .= "REQUIRED(".$self->get_required.") ";
	}
	if ($self->get_optional) {
		$result .= "OPTIONAL(".$self->get_optional.") ";
	}
	$result .= "\n";
	$result .= "\t" x $indents;
	$result .= "Description: ".$self->get_description."\n\n";
	my $format = $self->get_format;
	my $formatType = ref($format);
	if (( $formatType !~ /CODE/ ) and
		($formatType !~ /Regexp/ ) and
		(! $self->can($format))) {
		$result .= $format->newInitialized->describe($indents+1);
	}
	return $result;
}

1;
