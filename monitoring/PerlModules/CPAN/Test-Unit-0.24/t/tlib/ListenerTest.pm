package ListenerTest;
    
# Test class used in SuiteTest

use base qw(Test::Unit::TestCase Test::Unit::Listener);

use Test::Unit::Result;

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_my_result} = 0;
    $self->{_my_start_count} = 0;
    $self->{_my_end_count} = 0;
    $self->{_my_failure_count} = 0;
    $self->{_my_error_count} = 0;
    return $self;
}

sub add_error {
    my $self = shift;
    my ($test, $t) = @_;
    $self->{_my_error_count}++;
}
    
sub add_failure {
    my $self = shift;
    my ($test, $t) = @_;
    $self->{_my_failure_count}++;
}
    
sub end_test {
    my $self = shift;
    my ($test) = @_;
    $self->{_my_end_count}++;
}

sub set_up {
    my $self = shift;
    $self->{_my_result} = Test::Unit::Result->new();
    $self->{_my_result}->add_listener($self);
    $self->{_my_start_count} = 0;
    $self->{_my_end_count} = 0;
    $self->{_my_failure_count} = 0;
}

sub start_test {
    my $self = shift;
    $self->{_my_start_count}++;
}

sub add_pass {
}

# the tests
sub make_dummy_testcase {
    my $self = shift;
    my $sub  = pop;
    my $method_name = shift || 'run_test';

    Class::Inner->new(parent  => 'Test::Unit::TestCase',
                      methods => { $method_name => $sub },
                      args    => [ $method_name ]);
}

sub test_error {
    my $self = shift;
    my $test = $self->make_dummy_testcase(sub {die});
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_error_count});
    $self->assert(1 == $self->{_my_end_count});
}

sub test_failure {
    my $self = shift;
    my $test = $self->make_dummy_testcase(sub {shift->fail()});
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_failure_count});
    $self->assert(1 == $self->{_my_end_count});
}

sub test_start_stop {
    my $self = shift;
    my $test = $self->make_dummy_testcase(sub {});
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_start_count});
    $self->assert(1 == $self->{_my_end_count});
}

1;
