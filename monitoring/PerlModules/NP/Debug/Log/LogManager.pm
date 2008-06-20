package NOCpulse::Log::LogManager;

use strict;

use Carp;
use Error(':try');
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      output_handler
     )],
  hash =>
  [qw(
      loggers
      _namespace
     )],
  static_get_set =>
  [qw(
      _instance
     )],
  new_with_init => '_create_singleton',
;


# The namespace has all parts of the package, each of which can
# have its own level. For instance, NOCpulse::Foo::Bar would be
# present in the namespace as NOCpulse, NOCpulse::Foo, and
# NOCpulse::Foo::Bar. If a particular package has no level
# defined, it's possible to walk up the tree to find a higher
# setting.

# Initializes from the default logging file.
sub init {
    my $self = shift;
}

# Returns the singleton manager instance.
sub instance {
    my $class = shift;

    $class or croak __PACKAGE__."::instance() called without a class reference\n";

    unless ($class->_instance) {
        my $instance = $class->_create_singleton();
        $instance->output_handler(NOCpulse::Debug->new());
        $instance->add_stream();
        $class->_instance($instance);
    }
    return $class->_instance;
}

# Adds an output stream. See Debug::addstream for arguments.
sub add_stream {
    my ($self, @args) = @_;
    $self->output_handler->addstream(@args);
}

# Remove an output stream. See Debug::addstream for arguments.
sub del_stream {
    my ($self, @args) = @_;
    $self->output_handler->delstream(@args);
}

# Sets a single output stream. Clears any existing streams.
# See Debug::addstream for arguments.
sub stream {
    my ($self, @args) = @_;
    $self->output_handler->_streams([]);
    $self->output_handler->addstream(@args);
}

# Configures the logger namespace from a hash. Any existing settings
# are lost. Entries should use an empty string for undefined levels
# that should get inherited settings.
sub configure {
    my ($self, %args) = @_;

    ref($self) or croak __PACKAGE__."::configure() called on class, not instance\n";

    $self->_namespace_clear();
    $self->add_configuration(%args);
}

# Adds one or more settings to the existing logger namespace.
sub add_configuration {
    my ($self, %args) = @_;
    ref($self) or croak __PACKAGE__."::add_configuration() called on class, not instance\n";

    $self->_namespace(%args);
    $self->_assign_levels();
}

# Reads logging configuration from a file, by default configDir/logging.ini.
sub read_config_file {
    my ($self, $filename) = @_;

    ref($self) or croak __PACKAGE__."::read_config_file() called on class, not instance\n";

    unless ($filename) {
        my $config = NOCpulse::Config->new();
        my $dir = $config->get('netsaint', 'configDir');
        $filename = $dir."/logging.ini";
    }
    my $log_config = NOCpulse::Config->new($filename);
    my $settings = $log_config->getSection('logging');
    $self->configure(%$settings);
}

# Adds a logger and assigns it a level based on the namespace,
# unless it already has a level defined.
sub add_logger {
    my ($self, $logger) = @_;

    ref($self) or croak __PACKAGE__."::add_logger() called on class, not instance\n";

    $self->loggers($logger->package_name, $logger);
    if (defined $logger->level) {
        # Coming in with its own level
        $self->_namespace($logger->package_name, $logger->level);
    } else {
        # Use the inherited level
        $logger->level($self->level($logger->package_name));
    }
}

# Ensures that a given package is at or above a level.
sub ensure_level {
    my ($self, $package, $level) = @_;

    $self->add_configuration($package => $level) unless $self->level($package) >= $level;
}

# Returns the level setting for a logger package. Starts from
# the full package name and walks up, package component at a time,
# until it finds a defined level, if any. Returns the level or undef
# if nothing in the hierarchy is assigned a level. The level setting
# named 'all' is always the final parent for any package.
sub level {
    my ($self, $package_name) = @_;

    ref($self) or croak __PACKAGE__."::level() called on class, not instance\n";

    # First try the full name.
    my $level = $self->_namespace($package_name);

    # Now try each leading substring of the package name. If the name
    # ends with .pm, strip it off. This allows things like NOCpulse::Event
    # to affect both Event.pm and Event::PluginEvent.pm.
    $package_name =~ s/.pm$//;

    if (!defined($level) || $level eq '') {
        # Try each package prefix.
        my @parts = split(/::/, $package_name);
        for (my $i = @parts-2; $i >= 0; --$i) {
            $level = $self->_namespace(join('::', @parts[0..$i]));
            last if defined($level) && $level ne '';
        }
    }
    $level = $self->_namespace('all') unless defined($level) && $level ne '';

    return $level;
}

# Unconditionally prints to the file handler.
sub print {
    my ($self, @args) = @_;
    $self->output_handler->print(@args);
}

# Assigns levels to all known loggers based on the namespace.
sub _assign_levels {
    my $self = shift;
    foreach my $logger ($self->loggers_values) {
        $logger->level($self->level($logger->package_name));
    }
}


1;

__END__

=head1 NAME

NOCpulse::Log::LogManager - Manager of fine-grain logging objects

=head1 SYNOPSIS

use NOCpulse::Log::LogManager;

   NOCpulse::Log::LogManager->instance()->add_stream(FILE       => 'foo.log',
                                                     APPEND     => 1,
                                                     TIMESTAMPS => 1);
   NOCpulse::Log::LogManager->instance()->configure(
       'NOCpulse::Scheduler'                     => 1,
       'NOCpulse::Scheduler::Event.pm'           => 2);
       'NOCpulse::Scheduler::Event::PluginEvent' => 4);

   NOCpulse::Log::LogManager->instance()->add_configuration('NOCpulse::Probe' => 2);

=head1 DESCRIPTION

C<LogManager> manages level configuration and output for C<Logger>s. 
It keeps track of all instantiated loggers.

Output is handled by the C<Debug> module (see L<Debug>). The
C<add_stream> and C<stream> methods call through to
C<Debug->addstream> and take the corresponding arguments.

Configuration is via hash entries keyed by package name or prefix. For
instance, in the example above, any module that includes ``Scheduler''
in its name will be assigned a level of one, while the ``PluginEvent''
module is assigned a level of four. A logger without a specifcally
assigned level walks up to find the first defined level above it.

You normally use C<LogManager> only during initialization; logging
calls do not refer to the manager.

=head1 METHODS

=over 3

=item instance()

Returns the global singleton instance. You cannot create new
instances. By default the instance logs to STDOUT.


=item add_stream(%args)

Adds an output stream. See L<Debug> for details of C<%args>.


=item del_stream(%args)

Removes an output stream. See L<Debug> for details of C<%args>.


=item stream(%args)

Sets up a single output stream. See L<Debug> for details of C<%args>.


=item configure(%args)

Configures the log level namespace from a hash. Keys are package names
or prefixes, values are level integers. Replaces any existing
configuration.


=item add_configuration(%args)

Adds to an existing log level namespace configuration.


=item read_config_file([$filename])

Reads logging configuration from an ini file. Defaults to
F<logging.ini> in the directory named by the netsaint/configDir
property in F<NOCpulse.ini>, F</opt/home/nocpulse/etc>.


=item add_logger($logger)

Adds a logger and sets its level based on the current namespace. This
is called from C<Logger-E<gt>new> but should not usually be called from
other packages.


=item level($package_name)

Returns the level assigned to C<$package_name>. It first looks for a
specific entry for C<$package_name>, then for each prefix (separated
by ``::''), and finally for an entry named ``all''. Returns undef if
there is no matching level anywhere in the namespace.


=item print(%args)

Unconditionally prints to the current output streams.

=back

=cut
