package NOCpulse::SharedBlockingNamespace;
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
use NOCpulse::Namespace;
@ISA=qw(NOCpulse::Namespace);


sub initialize
{
	my ($self,$namespaceName,$instanceName) = @_;
	$self->SUPER::initialize;
	# Load up data here and hold a lock
	#$self->{'data'} = {};
	return $self;					
}

sub addInstVar
{
	my ($self,$varname,$value) = @_;
	if (! $self->has($varname)) {
		return $self->{'data'}->{$varname} = $value;
	};
}
sub set
{
	my ($self,$varname,$value) = @_;
	return $self->{'data'}->{$varname} = $value;
}
sub delete
{
	my ($self,$varname) = @_;
	return delete $self->{'data'}->{$varname};
}
sub get
{
	my ($self,$varname) = @_;
	return $self->{'data'}->{$varname};
}
sub has
{
	my ($self,$varname) = @_;
	return exists($self->{'data'}->{$varname})
}

sub DESTROY
{
	my $self = shift();
	#save data here and free the lock
}

1
