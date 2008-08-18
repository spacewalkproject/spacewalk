package NOCpulse::Log::Logger;
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
use strict;
use Data::Dumper;
use NOCpulse::Log::LogManager;

use Class::MethodMaker
  get_set =>
  [qw(
      package_name
      level
      show_method
     )],
  new_with_init => 'new',
;

# Log level for showing method entry/exit messages
use constant ENTER_EXIT_LEVEL => 4;


sub init {
    my ($self, $name, $level, $show_method) = @_;

    # Default to prefixing with the method name.
    $show_method = 1 unless defined $show_method;

    $self->package_name($name);
    $self->level($level);
    $self->show_method($show_method);
    NOCpulse::Log::LogManager->instance->add_logger($self);
}

# Flushes the output.
sub flush {
    NOCpulse::Log::LogManager->instance->output_handler->flush();
}

# Returns true value if messages will be printed at this level.
sub loggable {
    my ($self, $at_level) = @_;

    return 1 if $at_level == 0;
    return defined($self->level) && ($self->level ne '') && ($self->level >= $at_level);
}

# Prints if the level is loggable.
sub log {
    my ($self, $level, @args) = @_;

    if ($self->loggable($level)) {
        my $prefix = $self->_method_name_prefix() if $self->show_method;
        $self->print($prefix, @args);
    }
}

# Prints if the level is loggable. Uses the given method name instead of
# calculating it, useful for inside eval blocks.
sub log_method {
    my ($self, $level, $method, @args) = @_;

    if ($self->loggable($level)) {
        my $prefix = $self->package_name . "::$method " if $self->show_method;
        $self->print($prefix, @args);
    }
}

# Dumps the reference sandwiched between the prefix and suffix
# if the level is loggable.
sub dump {
    my ($self, $level, $prefix, $ref, $suffix) = @_;

    if ($self->loggable($level)) {
        $self->show_method and ($prefix = $self->_method_name_prefix().$prefix);
        $self->print($prefix, Dumper($ref), $suffix);
    }
}

# Prints the calling method followed by "ENTER "
# if ENTER_EXIT_LEVEL is loggable.
sub entering {
    my ($self, @args) = @_;
    my $level = ENTER_EXIT_LEVEL;
    if ($self->loggable($level)) {
        my $prefix = $self->_method_name_prefix().'ENTER ';
        $self->print($prefix, @args);
    }
}

# Prints the calling method followed by "EXIT  "
# if ENTER_EXIT_LEVEL is loggable.
sub exiting {
    my ($self, @args) = @_;
    my $level = ENTER_EXIT_LEVEL;
    if ($self->loggable($level)) {
        my $prefix = $self->_method_name_prefix().'EXIT  ';
        $self->print($prefix, @args);
    }
}

# Prints unconditionally.
sub print {
    my ($self, @args) = @_;
    NOCpulse::Log::LogManager->instance->print(@args);
}

# Returns the caller's method name.
sub _method_name_prefix {
    # Note it's caller(2) because this is a subroutine...
    return (caller(2))[3].' ';
}

1;

__END__

=head1 NAME

NOCpulse::Log::Logger - Fine-grain logging

=head1 SYNOPSIS

    use NOCpulse::Log::Logger;

    my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

    $Log->log(4, "Foo: ", $self->foo, "\n");
    $Log->dump(4, "Self: ", $self, "\n");

    if ($Log->loggable(9)) {
        $Log->log(9, "Entire database contents: ", $self->show_everything, "\n");
    }

    sub do_stuff {
       $Log->entering();
       ...
       $Log->exiting();
    }

=head1 DESCRIPTION

C<Logger> provides methods for conditionally logging debug
output. Each logger has its own level which can be set using the
C<LogManager> configuration methods. This provides fine-grained
control over your output. By default configurations are read in from
F</etc/nocpulse/logging.ini>. The keys are package names or
prefixes, and the values are numeric levels. For example:

    NOCpulse::Dispatcher::Kernel=1
    NOCpulse::Dispatcher::Scheduler=0


=head1 EXAMPLE CONFIGURATION

Suppose you want to print all the level two messages from any subclass
of C<NOCpulse::Probe::DataSource>, and the level four messages
C<NOCpulse::Probe::DataSource::SNMP>. Between C<Logger> and
C<LogManager> this is easy to set up:

    # Some setup code somewhere...
    LogManager->instance->configure(NOCpulse::Probe::DataSource => 1,
                                    NOCpulse::Probe::DataSource::SNMP => 4);
    # ...or /etc/nocpulse/logging.ini contains...
    # NOCpulse::Probe::DataSource=1
    # NOCpulse::Probe::DataSource::SNMP=4

    # In NOCpulse::Probe::DataSource::SNMP.pm:
    my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

    sub do_something {
        $Log->log(2, "Do something\n");
        $Log->log(4, "And here are all the details:", $self->details, "\n");
    }

=head1 METHODS

=over 3

=item new($name [, $level, $show_method])

Creates a new logger. The name is typically C<__PACKAGE__>. You can
specify the initial level number with C<$level>; this overrides any
C<LogManager> configuration (see L<LogManager>).

By default the name of the current method is logged with every message. You can
override this at creation by specifying a false value for
C<$show_method>.


=item package_name()

Returns the name this logger was created with.


=item level([$level])

Returns the current output level for this logger, or sets it to a new
value. The C<log> method will not print anything if its level is
greater than the current level.


=item show_method([$show])

Returns true if currently showing the current method in every log
message, or resets this value if C<$show> is present.


=item loggable($level)

Returns true if a call to C<log()> at C<$level> will actually
print. This is useful to check before creating a large output message
that may or may not be logged.


=item log($level, @args)

Logs a formatted message containg C<@args> if C<$level> is loggable.
Formatting is described in L<Debug>.


=item dump($level, $prefix, $ref, $suffix)

Dumps an object with Data::Dumper (surrounded by C<$prefix> and
C<$suffix>) if the C<$level> is loggable.


=item entering([$msg])

Prints the current method name followed by ``ENTER'' and the optional message if
NOCpulse::Log::ENTER_EXIT_LEVEL is loggable.


=item exiting([$msg])

Prints the current method name followed by ``EXIT '' and the optional message if
NOCpulse::Log::ENTER_EXIT_LEVEL is loggable.


=item print(@args)

Unconditionally prints the arguments.


=back

=head1 CONSTANTS

=over 3

=item ENTER_EXIT_LEVEL

The level at which the C<entering> and C<exiting> methods will print.

=back

=cut
