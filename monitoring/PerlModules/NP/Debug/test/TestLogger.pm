package NOCpulse::Log::test::TestLogger;
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
use NOCpulse::Log::LogManager;
use NOCpulse::Log::Logger;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{log_manager} = NOCpulse::Log::LogManager->instance();
}

sub test_load_ini {
    my $self = shift;
    $self->{log_manager}->read_config_file();
    my $level = $self->{log_manager}->level('all');
    $self->assert($level eq '', "'all' level is defined: '$level'");
}

sub test_configure {
    my $self = shift;
    $self->{log_manager}->configure('Foo::Bar' => 1,
                                    'Foo::Bar::Baz' => 2,
                                    'Foo::Bar::Baz::Blat' => '');
    $self->assert(keys %{$self->{log_manager}->_namespace} == 3,
                  'Wrong number of namespace entries');

    $self->{log_manager}->configure('A::B' => 99);
    $self->assert(keys %{$self->{log_manager}->_namespace} == 1,
                  'Wrong number of namespace entries after second configure');

    $self->{log_manager}->add_configuration('C::D' => 66);
    $self->assert(keys %{$self->{log_manager}->_namespace} == 2,
                  'Wrong number of namespace entries after add_configuration');

    $self->{log_manager}->ensure_level('C::D', 77);
    $self->assert($self->{log_manager}->level('C::D') == 77,
                  'Level not 77 after ensuring: ', $self->{log_manager}->level('C::D'));
    $self->{log_manager}->ensure_level('C::D', 22);
    $self->assert($self->{log_manager}->level('C::D') == 77,
                  'Ensuring lower level failed: ', $self->{log_manager}->level('C::D'));
}

sub test_load {
    my $self = shift;
    $self->{log_manager}->configure('Foo::Bar' => 1,
                                    'Foo::Bar::Baz' => 2,
                                    'Foo::Bar::Baz::Blat' => '');

    $self->assert_level('Foo::Bar', 1);
    $self->assert_level('Foo::Bar::Baz', 2);

    # Should inherit
    $self->assert_level('Foo::Bar::Baz::Blat', 2);

    # Test .pm override
    $self->{log_manager}->add_configuration('Foo::Bar::Baz.pm' => 8);
    $self->assert_level('Foo::Bar::Baz.pm', 8);
}

sub assert_level {
    my ($self, $pkg, $level) = @_;
    $self->assert($self->{log_manager}->level($pkg) == $level, "$pkg level is wrong: $level");
}

sub test_add {
    my $self = shift;

    my $logger = NOCpulse::Log::Logger->new('Blat::Foop');

    my $level = $self->{log_manager}->level('Blat::Foop');
    $self->assert($level eq '', "New logger level is set: $level");

    $self->{log_manager}->configure('Blat' => 36);

    $level = $self->{log_manager}->level('Blat::Foop');
    $self->assert($level == 36, "Inherited setting from manager wrong: $level");

    $level = $logger->level;
    $self->assert($level == 36, "Inherited setting in logger wrong: $level");
}

sub test_loggable {
    my $self = shift;

    my $logger = NOCpulse::Log::Logger->new('Level::Test');
    $self->assert($logger->loggable(0), "Level 0 not loggable");

    $logger->level(3);
    $self->assert(!$logger->loggable(4), "Level 4 is loggable");
    $self->assert($logger->loggable(3), "Level 3 not loggable");
    $self->assert($logger->loggable(1), "Level 1 not loggable");
}

sub test_output {
    my $self = shift;

    $self->{stream} = $self->{log_manager}->stream(FILE => \*STDOUT, BUFFERING => 1);
    my $contents = $self->{stream}->contents;

    my $logger = NOCpulse::Log::Logger->new('Output::Test', 3);

    $logger->log(4, "Should not appear\n");
    $self->assert(@$contents == 0, "Contents not empty: @$contents\n");

    $logger->log(3, "Should in fact appear\n");
    $self->assert(@$contents == 1, "Contents empty after log at 3: @$contents\n");

    $logger->log(1, "This too\n");
    $self->assert(@$contents == 2, "Contents wrong size after log at 100: @$contents\n");

    $logger->level($logger->ENTER_EXIT_LEVEL);
    $logger->entering("Ni hao\n");
    $self->assert(@$contents == 3, "Contents wrong size after enter: @$contents\n");
    $logger->exiting("Zai jian\n");
    $self->assert(@$contents == 4, "Contents wrong size after enter: @$contents\n");
}

1;
