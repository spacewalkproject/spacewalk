package NOCpulse::AbstractObjectRepository;
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
@ISA = qw(NOCpulse::Object);
$databaseMode = 0666;

# Implements a primitive object repository with pluggable storage modules. This
# is especially primitive in that it makes no provisions whatsoever for 
# clamping (recursive object references). This means that your design needs to
# draw explicit deliniating lines as to where and how objects relate - if you
# have large collections who's objects refer to other objects in large
# collections, you should "link" these via lookups as opposed to direct
# object links - if you don't you'll be saving and restoring a mind boggling
# mess of pointers (redundant, possibly recursive, even infinitely so).

# The move towards making this a proper repository would involve making use
# of unique OIDs.  Doable, but well beyond the goals of the current project.

# CLASS METHODS

sub CacheHandles
{
	my ($class,$mode) = @_;
	$class = ref($class) || $class;
	if ($mode) {
		$class->setClassVar('CacheHandles',$mode);
		if ($mode) {
			$class->setClassVar('CachedHandles',{});
		}
	} else { 
		if ($class->getClassVar('CacheHandles')) {
			return $class->getClassVar('CacheHandles');
		} else {
			return 0;
		}
	}
}

sub CachedHandle
{
	my ($class,$instance) = @_;
	$class = ref($class) || $class;
	my $cacheHash = $class->getClassVar('CachedHandles');
	if (exists($cacheHash->{$instance->get_databaseFilename})) {
		return $cacheHash->{$instance->get_databaseFilename}
	} else {	
		return undef;
	}
}

sub CacheHandle
{
	my ($class,$instance) = @_;
	$class = ref($class) || $class;
	my $cacheHash = $class->getClassVar('CachedHandles');
	$cacheHash->{$instance->get_databaseFilename} = $instance->get_databaseHandle;
}

sub UncacheHandle
{
	my ($class,$instance) = @_;
	$class = ref($class) || $class;
	my $cacheHash = $class->getClassVar('CachedHandles');
	delete $cacheHash->{$instance->get_databaseFilename};
}

# INSTANCE METHODS

sub initialize
{
	my ($self,$filename,$mode) = @_;
	$self->SUPER::initialize;
	$self->set_databaseFilename($filename);
	$self->set_databaseFilemode($mode||0666);
	return $self;
}

sub instVarDefinitions
{
	# NOTE: Subclasses MUST call $self->SUPER::instVarDefinitions
	# since this abstract class relies on having an instvar named
	# "name".  BTW - we also assume that you populate it with
	# unique values...
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('databaseFilename');
	$self->addInstVar('databaseHandle');
	$self->addInstVar('databaseFilemode');
}

sub open
{
	my $self = shift();
	my $handle;
	if ($self->CacheHandles) {
		if ($handle = $self->CachedHandle($self)) {
			return $handle
		}
	}
	$handle = $self->_openFile($self->get_databaseFilename);
	$self->set_databaseHandle($handle);
	if ($self->CacheHandles) {
		$self->CacheHandle($self);
	}
	return $handle;
}

sub writeObject
{
	my ($self,$key,$value) = @_;
	return $self->_writeObject($self->get_databaseHandle,$key,$value->storeString);
}

sub readObject
{
	my ($self,$key) = @_;
	my $storeString = $self->_readObject($self->get_databaseHandle,$key);
	if (defined($storeString)){
		my $object = NOCpulse::Object->fromStoreString($storeString);
                return $object;
	} else {
           return undef;
        }
}

sub keys
{
	my ($self) = @_;
	return $self->_keys($self->get_databaseHandle);
}

sub close
{
	my ($self) = @_;
	if (! $self->CacheHandles) {
		my $handle = $self->get_databaseHandle;
		return $self->_closeFile($handle);
	} else {
		return undef
	}
}

sub closeCachedHandle
{
        my ($self) = @_;
        if ($self->CacheHandles) {
                my $handle = $self->get_databaseHandle;
		$self->UncacheHandle($self);
                return $self->_closeFile($handle);
        } else {
                return undef
        }
}

# ABSTRACT METHODS

sub fileExtension
{
	return "";
}

sub _openFile
{
	my ($self,$filename,@params) = @_;
}

sub _closeFile
{
	my ($self,$handle) = @_;
}

sub _readObject
{
	my ($self,$handle,$key) = @_;
}

sub _keys
{
	my ($self,$handle) = @_;
}

sub _writeObject
{
	my ($self,$handle,$key,$value) = @_;
}


1
