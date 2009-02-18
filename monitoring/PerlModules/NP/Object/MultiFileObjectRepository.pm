package NOCpulse::MultiFileObjectRepository;
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
