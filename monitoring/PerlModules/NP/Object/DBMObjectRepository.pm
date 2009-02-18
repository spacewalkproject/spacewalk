package NOCpulse::DBMObjectRepository;
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
use GDBM_File;
@ISA = qw(NOCpulse::AbstractObjectRepository);


sub _openFile
{
	my ($self,$filename) = @_;
	my %database;
        my $tries = 0;
        my $maxtries = 5;
	while (! tie(%database, 'GDBM_File', $filename.'.db', &GDBM_WRCREAT, 0640)) {
                if ("$!" ne "Resource temporarily unavailable") {
                   $tries = $tries + 1;
                   if ($tries >= $maxtries) {
                      print "ERROR: $filename - $!\n";exit -1;
                   }
                }
		sleep(1);
	}
	return \%database;
}

sub _closeFile
{
	my ($self,$handle) = @_;
 	return untie(%$handle);
}

sub _readObject
{
	my ($self,$handle,$key) = @_;
	return $$handle{$key}
}

sub _keys
{
	my ($self,$handle) = @_;
	my @keys = keys(%$handle);
	return \@keys;
}

sub _writeObject
{
	my ($self,$handle,$key,$value) = @_;
	return $$handle{$key} = $value;
}


1
