package NOCpulse::LocalCommandShell;
#
# Copyright (c) 2008 Red Hat, Inc.
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

=head1 NAME

NOCpulse::LocalCommandShell - provides access to a shell locally

=head1 DESCRIPTION

LocalCommandShell provides access to a command shell via local fork to /bin/sh

=head1 REQUIRES

CommandShell

=cut

use NOCpulse::CommandShell;
@ISA=qw(NOCpulse::CommandShell);

sub overview {
   return "This module gives shell based probes access a local command shell"
}

sub initialize
{
	my $self = shift();	
	$self->SUPER::initialize();
	$self->set_shellCommand('/bin/sh');
	$self->set_shellSwitches('-s');
	return $self;
}


1
