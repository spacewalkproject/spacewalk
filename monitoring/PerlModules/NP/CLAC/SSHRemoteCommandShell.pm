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

NOCpulse::SSHRemoteCommandShell - a subclass of NOCpulse::CommandShell that describes access to a command shell
via SSH

=head1 DESCRIPTION

NOCpulse::SSHRemoteCommandShell is a subclass of NOCpulse::CommandShell that describes access to a command shell
via SSH.  It makes the presumption that host keys are in sync etc so that no password will
be required.

=head1 REQUIRES

NOCpulse::CommandShell

=cut

package NOCpulse::SSHRemoteCommandShell;
use NOCpulse::CommandShell;
@ISA=qw(NOCpulse::CommandShell);


sub overview {
   return "This component give shell based probes access to a command shell via an SSH connection"
}

sub registerSwitches
{

=head1 INSTANCE METHODS

=over 4

=item registerSwitches()

Defines the following:

sshuser = the username to connect with
sshhost = the host to connect to

=cut

	my $self = shift();
	$self->SUPER::registerSwitches;
	$self->addSwitch('sshuser','=s','1','nobody','Name of the user to log in as');
	$self->addSwitch('sshhost','=s','1','localhost','Host to log into');
}

sub initialize
{

=item initialize()

Sets up the shellCommand and shellSwitches for execution given the value of the switches
registered in registerSwitches()

=cut

	my $self = shift();	
	$self->SUPER::initialize(shift());
	if ($self->switchesAreValid) {
		$user = $self->switchValue('sshuser');
		$host= $self->switchValue('sshhost');
		$self->set_shellCommand('/usr/bin/ssh');
		$self->set_shellSwitches('-l', $user,
                      '-p','4545',
                      '-i','/var/lib/nocpulse/.ssh/nocpulse-identity',
                      '-o','BatchMode=yes',
                      $host,
                      '/bin/sh -s');
	}
	return $self;
}

