package NOCpulse::NSObject;
#
# Copyright (c) 2009 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

require Exporter;
@EXPORT=qw(WriteSpace);

$WriteSpace = 'primary';

sub Namespaces
{
	# Method must return a hash of the form
	# 'namespaceName'=>'NamespaceClassName',...
	#
	# a namespaceName of $WriteSpace will be the write namespace
	# for the object.
	#
	# If you don't specify a $WriteSpace, the object will be
	# read only (which is a sort of strange thing when you start thinking
	# about it).
	#
	return [$WriteSpace=>'NOCpulse::Namespace'];
}

sub new
# We're entirely overriding Object behavior here - sequence is touchy
{
	my ($self,$namespaceId) = @_;

	# $namespaceId is an id unique to this instance - it is optional
	# depending on the type and use of the namespaces specified in
	# Namespaces

        my $class = ref($self) || $self;
        $self = {};
        bless $self,$class;

	# At this point $self is a hash blessed to the current class
	if (defined($namespaceId)) {
		$self->{'namespaceId'} = $namespaceId;
	}

	my $spacesNamesRef=$self->Namespaces($WriteSpace);
	my (@readSpaces,@readSpaceNames,$writeSpace,$spaceName,$className);
	while ($spaceName = shift(@$spacesNamesRef)) {
		$className = shift(@$spacesNamesRef);
		eval("use $className");
		$className =~ s/.*\:\:(.*)$/$1/g;
		my $namespace = $className->newInitialized($spaceName,$self->namespaceId);
		push(@readSpaces,$namespace);
		push(@readSpaceNames,$spaceName);
		# Write space must be one of the read spaces.
		if ($spaceName eq $WriteSpace) {
			$writeSpace = $namespace;
		}
	}
	$self->{'readSpaces'} = \@readSpaces;
	$self->{'readSpaceNames'} = \@readSpaceNames;
	$self->{'writeSpace'} = $writeSpace;

        $self->_initialize;

	return $self;
}

sub namespaceId
{
	my $self = shift();
	if (exists($self->{'namespaceId'})) {
		return $self->{'namespaceId'};
	} else {
		return undef;
	}
}

sub writeSpace
{
	my $self = shift();
	return $self->{'writeSpace'};
}

sub readSpaces
{
	my $self = shift();
	return $self->{'readSpaces'};
}

sub namespaceIndex
{
	my ($self,$spaceName) = @_;
	my $index = 0;
	my $spaceNames = $self->{'readSpaceNames'};
	while ($index < scalar(@$spaceNames)) {
		if ($spaceNames->[$index] eq $spaceName) {
			return $index;
		} else {
			$index = $index + 1;
		}
	}
	return undef;
}

sub namespace
{
	my ($self,$index) = @_;
	my $namespaces = $self->{'readSpaces'};
	return $namespaces->[$index];
}

sub namespaceNamed
{
	my ($self,$spaceName) = @_;
	my $index = $self->namespaceIndex($spaceName);
	if (defined($index)) {
		return $self->namespace($index);
	} else {
		return undef;
	}
}

sub addInstVar
{
	my ($self,$varname,$value) = @_;
	# kind of a holdover from the original Object
	return $self->writeSpace->addInstVar($varname,$value);
}

sub set
{
	my ($self,$varname,$value) = @_;
	return $self->writeSpace->set($varname,$value);
}

sub delete
{
	my($self,$varname) = @_;
	return $self->writeSpace->delete($varname);
}


sub get
{
	my($self,$varname) = @_;
	my $namespaces = $self->readSpaces;
	my ($index,$namespace);
	$index = 0;
	while ($index < scalar(@$namespaces)) {
		$namespace = @$namespaces->[$index];
		if ($namespace->has($varname)) {
			return $namespace->get($varname);
		} else {
			$index = $index + 1;
		}
	}
	return undef;
}

sub has
{
	my($self,$varname) = @_;
	my $namespaces = $self->readSpaces;
	my ($index,$namespace);
	$index = 0;
	while ($index < scalar(@$namespaces)) {
		$namespace = @$namespaces->[$index];
		if ($namespace->has($varname)) {
			return 1
		} else {
			$index = $index + 1;
		}
	}
	return 0;
}

1
