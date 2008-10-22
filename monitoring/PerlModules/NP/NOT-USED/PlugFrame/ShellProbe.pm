
=head1 NAME

ShellProbe - An elaboration on Probe that provides probe logic with access to a command shell

=head1 DESCRIPTION

ShellProbe elaborates on Probe in that probes derived from it enjoy access to a command shell
without having to worry about the mechanics of said access.  Command shell access via this
class gives the subclasser free timing and timeout mechanisms.

Note that with this subclass you will not be overriding the run() method from Probe - instead
see setup() and testResults()

=head1 REQUIRES

Probe, Time::HiRes

=cut

package ShellProbe;
use NOCpulse::PlugFrame::Probe;
use Time::HiRes qw(gettimeofday tv_interval);

@ISA=qw(Probe);

sub setup
{

=head1 INSTANCE METHODS

=over 4

=item setup()

Protocol method - you must override it.

Override setup() with a method that makes a call to set_probeCommands() (see below).

=cut
	
	# You *must* override this - at this point you should set up the shell 
	# appropriately for execution.
	my $self = shift();
	return 0;
}

sub testResults {

=item testResults()

Protocol method - you must override it.

Override testResults() with a method that tests the results of the execution of the
shell commands specified in setup().  You can get access to the stderr, stdout, and exitLevel
of your command(s) by calling the methods of the same name (see below).

=cut
	
   # You must override this and carry out any analysis you need to on the shell
   # output/exit status etc.  This is the stuff you'd normally do in the run
   # method for a non-shell plugin.
   my $self = shift();
   return 0;
}


sub initialize {

=item initialize(<plugin>)

Initializes the probe instance by calling SUPER::initialize(<plugin>), adding a 
switch called 'timeout' with a default of 15 seconds, and setting runTime to zero.

=cut
	
   my ($self,$plugin,@params) = @_;
   $self->SUPER::initialize($plugin,@params);
   $self->addSwitch('timeout','=i',0,15,'Number of seconds before this probe gives up');
   $self->set_runTime(0);
   return $self;
}

sub instVarDefinitions {

=item instVarDefinitions()

Defines the runTime instance variable which is used to hold the amount of time it took for
your command(s) to run.

=cut
	
   my $self = shift();
   $self->addInstVar('runTime');
   $self->SUPER::instVarDefinitions;
}



sub shell
{

=item shell()

Returns the an instance of a subclass of CommandShell as instantiated by the plugin.  Run
uses this to execute the commands specified by the subclasser's call to set_ProbeCommands()

=cut
	
	my $self = shift();
	return $self->get_shellModule;
}

sub needsCommandShell
{

=item needsCommandShell()

Returns one.  Probe based derivatives return 0 (unless of course they subtend this class).  
You will probably never need to override this or access it.

=cut
        
	my $self = shift();
	return 1;
}


sub run
{

=item run()

Overrides Probe::run().  This method uses the CommandShell subclass instance returned by 
shell() to execute the command(s) specified in the subclasser's call to set_probeCommands().

The execution of the commands is wrapped by an alarm whos timeout is specified by the 
value of the timeout switch (see above).

Additionally, the amount of time it took (in milliseconds) to execute the command is stored
in the runTime instance variable.

=cut
        
	my $self = shift();
	$self->setup;
        my $start = [gettimeofday];
        $self->shell->set_timeout($self->get_timeout);
        $self->shell->execute;
        my $end = [gettimeofday];
        if ($self->shell->get_failed) {
	   $self->handleShellError($self->shell->get_stderr);
           return undef;
        } else {
           my $elapsed = tv_interval($start,$end);
           $self->set_runTime($elapsed);
           return $self->testResults;
        }
}


sub handleShellError
{

=item handleShellError(<message>)

This method provides default shell error handling.  The error message (if any) is 
passed as a parameter.  The default behavior is to setStatus('UNKNOWN') and
to addStatusString(<message>)

=cut

	my ($self,$message) = @_;
	$self->setStatus('UNKNOWN');
	$self->addStatusString($message);
}

sub stdout
{

=item stdout()

Returns stdout retained by the CommandShell subclass instance subsequent to execution of
probeCommands.

=cut
        
	return shift()->shell->get_stdout;
}
sub stderr
{

=item stderr()

Returns stderr retained by the CommandShell subclass instance subsequent to execution of
probeCommands.

=cut
        
	return shift()->shell->get_stderr;
}
sub exitLevel
{

=item stdout()

Returns exit level retained by the CommandShell subclass instance subsequent to execution of
probeCommands.

=cut
        
	return shift()->shell->get_exit;
}

sub set_probeCommands
{

=item set_probeCommands(<@commands>)

Sets the CommandShell subclass' probeCommands to those you pass in.  Usually a single string
(which can contain multiple lines e.g. a shell script) is sufficient.

=cut
        
	shift()->shell->set_probeCommands(@_);
}

sub set_probeSwitches
{

=item set_probeSwitches()

Deprecated - don't use.

=cut
        
	shift()->shell->set_probeSwitches(@_);
}
