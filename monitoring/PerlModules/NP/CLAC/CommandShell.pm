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

NOCpulse::CommandShell - an abstract definition of a command shell interface

=head1 SYNOPSIS


 package NOCpulse::SSHRemoteCommandShell;
 use NOCpulse::CommandShell;
 @ISA=qw(NOCpulse::CommandShell);

 sub overview {
    return "This component give shell based probes access to a command shell via an SSH connection"
 }

 sub registerSwitches
 {
 	my $self = shift();
 	$self->SUPER::registerSwitches;
 	$self->addSwitch('sshuser','=s','1','nobody','Name of the user to log in as');
       	$self->addSwitch('sshhost','=s','1','localhost','Host to log into');
 }

 sub initialize
 {
 	my $self = shift();	
 	$self->SUPER::initialize(shift());
 	if ($self->switchesAreValid) {
 		$user = $self->switchValue('sshuser');
 		$host= $self->switchValue('sshhost');
 		$self->set_shellCommand('/usr/bin/ssh');
 		$self->set_shellSwitches('-l', $user,
                       '-p','4545',
                       '-i','%/var/lib/nocpulse/.ssh/nocpulse-identity',
                       '-o','BatchMode=yes',
                       $host,
                       '/bin/sh -s');
 	}
 	return $self;
 }


=head1 DESCRIPTION

NOCpulse::CommandShell is a subclass of CommandLineApplicationComponent that defines a framework
for describing access to a command shell.  By itself it knows nothing - you must subclass
it for it to be useful (examples include NOCpulse::LocalCommandShell and NOCpulse::SSHRemoteCommandShell).


=head1 REQUIRES

Perl 5.004,  CommandLineApplicationComponent, IPC::Open3

=cut

package NOCpulse::CommandShell;
use NOCpulse::CommandLineApplicationComponent;
use IPC::Open3;
use POSIX ":sys_wait_h";
use Fcntl;
@ISA=qw(NOCpulse::CommandLineApplicationComponent);

sub instVarDefinitions
{

=head1 INSTANCE METHODS

=over 4

=item instVarDefinitions()

Defines the following:

shellCommand - the program that gets executed in order to obtain the shell

shellSwitches - switches to the shell command

probeCommands - the command(s) that the user of the Command Shell wants to run

probeSwitches - (deprecated)

stdout - contains the stdout of the probeCommands after execution

stderr - contains the stderr of the probeCommands after execution

exit - the exit level of the probeCommands after execution

=cut

	my $self = shift();	
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('shellCommand');
	$self->addInstVar('shellSwitches');
	$self->addInstVar('probeCommands');
	$self->addInstVar('probeSwitches');
        $self->addInstVar('timeout');
	$self->addInstVar('stdout');
	$self->addInstVar('stderr');
	$self->addInstVar('exit');
        $self->addInstVar('failed');
        $self->addInstVar('timeoutMessage');
}

sub initialize
{

=item initialize()


=cut

	my $self = shift();
	$self->SUPER::initialize;
	$self->set_probeCommands(NULL);
	$self->set_stdout(NULL);
	$self->set_stderr(NULL);
	$self->{'shellSwitches'}=[];
	$self->{'probeSwitches'}=[];
	$self->set_timeout(60);
        $self->set_exit(-1);
        $self->set_failed(0);
	return $self;
}

sub timeoutMessage
{
	my $self = shift();
	my $text = "Shell command timed out after";
	if ($self->get_timeoutMessage) {
		$text = $self->get_timeoutMessage;
	} elsif ($self->configValue('timeoutMessage')) {
		$text = $self->configValue('timeoutMessage');
	}
	return "$text ".$self->get_timeout." seconds\n";
		
}


sub execute
{

=item execute()

Executes probeCommands by passing them into the stdin of shellCommand (where shellCommand is
executed with shellSwitches).  It captures all stdout and stderr to their corresponding
instance variables, and sets the exit instance variable to the exit status of probeCommands.

Both stdout and stderr will contain one string with zero or more newlines.

=cut

	my ($self) = @_;
	my ($stdin,$stdout,$stderr,$pid);
        my $stdoutbuff = '';
        my $stderrbuff = '';
        my $ko;
	# NOTE: There appears to be a problem with doing PIPE traps
	# inside an eval.  This kludge (KludgeOmatic) gets around
	# it and avoids the "Faraldo dives deep into Perl source
	# for two hours" problem and more or less works... ;)
       	local $SIG{'PIPE'} = sub {$ko = "Pipe to shell was broken\n";};

        eval {
           local $SIG{'ALRM'} = sub {
               die $self->timeoutMessage;
           };
           alarm($self->get_timeout);
           local (*PSTDIN,*PSTDOUT,*PSTDERR);
           $pid = open3(\*PSTDIN,\*PSTDOUT,\*PSTDERR,$self->get_shellCommand,$self->get_shellSwitches,$self->get_probeSwitches);


           fcntl(PSTDOUT,F_SETFL,O_NONBLOCK);
           fcntl(PSTDERR,F_SETFL,O_NONBLOCK);

           print PSTDIN $self->get_probeCommands;
           close(PSTDIN);

           while (! waitpid($pid,&WNOHANG)) {
               sysread(PSTDOUT,$stdoutbuff,4096,length($stdoutbuff));
               sysread(PSTDERR,$stderrbuff,4096,length($stderrbuff));
               select(undef,undef,undef,0.1);
           }
           sysread(PSTDOUT,$stdoutbuff,4096,length($stdoutbuff));
           sysread(PSTDERR,$stderrbuff,4096,length($stderrbuff));
           alarm(0);
        };
	if ($@) {
           $stderrbuff .= $@;
           kill(15,$pid);
           sleep(1);
           kill(9,$pid);
           $self->set_failed(1);
        }
	if ($ko) {
		# Both get it - some plugins seem to ignore
		# stderr (at their peril I might add).
		$stdoutbuff .= $ko;
		$stderrbuff .= $ko;
	}
        $self->set_stdout($stdoutbuff);
        $self->set_stderr($stderrbuff);
	$self->set_exit($?);
	$self->dprint(3,'Executed command '.$self->get_shellCommand.' '.$self->get_shellSwitches.' '.$self->get_probeSwitches."\n");
	$self->dprint(4,'STDOUT: |'.$self->get_stdout."|\n");
	$self->dprint(4,'STDERR: |'.$self->get_stderr."|\n");
	$self->dprint(4,'EXIT: |'.$self->get_exit."|\n");
	return $self->get_exit;
}

sub set_shellSwitches
{

=item set_shellSwitches(<@switchList>)

Sets shellSwitches to the array of switches passed in.  (Overrides normal Object set_xxx 
behavior)

=cut

	my $self = shift();
	push(@{$self->{'shellSwitches'}},@_);
}

sub set_probeSwitches
{

=item set_probeSwitches(<@switchList>)

deprecated - don't use

=cut

	my $self = shift();
	push(@{$self->{'probeSwitches'}},@_);
}

sub get_shellSwitches
{

=item get_shellSwitches()

Returns the  shellSwitches array of switches.  (Overrides normal Object set_xxx behavior)

=cut

	my $self = shift();
        return @{$self->{'shellSwitches'}};
}

sub get_probeSwitches
{

=item get_probeSwitches()

deprecated - don't use

=cut

	my $self = shift();
        return @{$self->{'probeSwitches'}};
}

1
