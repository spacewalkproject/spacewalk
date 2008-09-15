
=head1 NAME

PortableShellProbe - a ShellProbe subclass that provides for operating system dependent execution of command(s)

=head1 DESCRIPTION

PortableShellProbe enhances ShellProbe in that it allows the subclasser to specify different commands
to be executed depending on operating system, and subsequently provides a mechanism for test
code to find out what operating system the commands actually ran on.

=head1 REQUIRES

ShellProbe

=cut

package PortableShellProbe;
use strict;
use vars qw(@ISA);
use NOCpulse::PlugFrame::ShellProbe;
@ISA=qw(ShellProbe);


sub registerCommands {

=head1 INSTANCE METHODS

=over 4

=item registerCommands()

Protocol method - you must override it.

Override registerCommands() with a method that makes calls to registerCommand() (see below)

=cut

   # You must override this with a method that
   # makes one or more calls to registerCommand('<os>','<command string')
   my $self = shift();
   return 0;
}


# ------------------------- Private stuff below - don't override -------------------------

sub registerCommand {

=item registerCommand(<os>,<commandString>)

Adds <commandString> to the commands hash with a key who's name is <os>.

=cut

   my ($self,$os,$commandString) = @_;
   $self->get_commands->{$os} = $commandString;
}


sub initialize {

=item initialize(<plugin>)

Initializes the instance by setting os and stdout to blank strings, commands to an empty
hash, and calling SUPER::initialize(<plugin>)

=cut

   my ($self,$plugin,@params) = @_;
   $self->set_os('');
   $self->set_stdout('');
   $self->set_commands({});
   $self->SUPER::initialize($plugin,@params);
}

sub instVarDefinitions {

=item instVarDefinitions()

Defines the following:

os - contains the name of the os that the command shell executed it's commands on

stdout - contains the stdout of the commands that got run

commands - a hash who's key is the OS name (according to uname) and whos values are strings containing commands to be executed on that os.

=cut

   my $self = shift();
   $self->SUPER::instVarDefinitions;
   $self->addInstVar('os');
   $self->addInstVar('stdout');
   $self->addInstVar('commands');
}


sub setup
{

=item setup()

Overrides ShellProbe::setup()

Constructs a shell script that detects the operating system on which its run and which 
then executes the commands associated with that os as specified in the commands hash.

Does a bit of in-band relaying of the name of the os using some chicanery (the jist of
which is: please don't execute anything whos output could contain this string: "PINGELLO-PSP-OS="

You should not override this - instead use registerCommands() (above).

=cut

	my $self = shift();
	$self->registerCommands;
        my $command = "PATH=/bin:/usr/bin:/usr/ucb;OS=`uname`\necho PINGELLO-PSP-OS=\$OS\ncase \$OS in\n";
        my $commands = $self->get_commands;
        while (my ($os,$commandString) = each(%$commands)) {
           $command .= "'$os') $commandString;;\n"
        }
        $command .= "esac\n";
        $self->set_probeCommands($command);
}


sub parseStdout {

=item parseStdout()

Strips out the in-band OS detection stuff from stdout and places it in the os instance variable.
Stores a cleansed version of stdout into the stdout instance variable.

=cut

   my $self = shift();
   $self->set_stdout(join("\n",grep(!/^PINGELLO-PSP\-OS=.*$/,split("\n",$self->shell->get_stdout)))."\n");
   my $stdout = $self->shell->get_stdout;
   $stdout =~ /^PINGELLO-PSP\-OS=(.*)$/m;
   my $os = $1;
   $self->set_os($os);
}

sub stdout {

=item stdout()

Returns the value of the stdout instance variable.  If the variable has no data, assumes that
it must first call parseStdout()

=cut

   my $self = shift();
   if (! $self->get_stdout) {
      $self->parseStdout
   }
   return $self->get_stdout;
}

sub os {

=item os()

Returns the value of the os instance variable.  If the variable has no data, assumes that
it must first call parseStdout()

=cut

   my $self = shift();
   if (! $self->get_os) {
      $self->parseStdout;
   }
   return $self->get_os;
}



