package NOCpulse::ObjectProxyServer;
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
use FreezeThaw qw(freeze thaw);

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('object');
	$self->addInstVar('connection');
	return $self;
}

sub initialize
{
	my ($self,$object,$connection) = @_;
	$self->set_object($object);
	$self->set_connection($connection);
	return $self;
}

sub run
{
	my $self = shift();
	my $protoString = $self->get_connection->readAll;
	my ($message,$frozenParams) = split(/,/,$protoString,2);
	my @params = thaw($frozenParams);
	my $object = $self->get_object;
	my $perlCode = 'sub {$object->'.$message.'(@params)}';
	my $closure = eval($perlCode);
	my $result = &$closure;
	$self->get_connection->sendAll(freeze($result));
}

1
