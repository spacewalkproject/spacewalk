package NOCpulse::BlockingFileNamespace;
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
use NOCpulse::SharedBlockingNamespace;
@ISA=qw(NOCpulse::SharedBlockingNamespace);
use IO::File;
use Fcntl qw(:flock);
use FreezeThaw qw(freeze thaw);


sub initialize
{
	my ($self,$namespaceName,$instanceName) = @_;
	$self->SUPER::initialize;
	my $file = IO::Handle->new();
	open($file,"+>>$namespaceName.$instanceName") ||die("Open failed");
	flock($file,LOCK_EX) || die('Lock failed');
	seek($file,0,0) || die('seek failed');
	$self->{'file'} = $file;
	my $data = <$file>;
	if ($data) {
		my @dataArray = thaw($data);
		$self->{'data'} = shift(@dataArray);
	} else {
		$self->{'data'} = {};
	}
	return $self;					
}

sub DESTROY
{
	my $self = shift();
	my $file = $self->{'file'};
	my $frozenData = freeze($self->{'data'});
	truncate($file,0);
	print $file $frozenData;
	close($file);
}

1
