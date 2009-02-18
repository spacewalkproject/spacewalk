package NOCpulse::INIObjectRepository;
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
