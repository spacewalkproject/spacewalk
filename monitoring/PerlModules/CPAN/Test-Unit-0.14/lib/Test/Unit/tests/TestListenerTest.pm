package Test::Unit::tests::TestListenerTest;
    
# Test class used in SuiteTest

use base qw(Test::Unit::TestCase Test::Unit::TestListener Test::Unit::InnerClass);

use Test::Unit::TestResult;

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
    $self->{_my_result} = Test::Unit::TestResult->new();
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

sub test_error {
    my $self = shift;
    my $test = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "noop");
sub run_test {
    die;
}
EOIC
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_error_count});
    $self->assert(1 == $self->{_my_end_count});
}

sub test_failure {
    my $self = shift;
    my $test = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "noop");
sub run_test {
    my $self = shift;
    $self->fail();
}
EOIC
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_failure_count});
    $self->assert(1 == $self->{_my_end_count});
}

sub test_start_stop {
    my $self = shift;
    my $test = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "noop");
sub run_test {
}
EOIC
    $test->run($self->{_my_result});
    $self->assert(1 == $self->{_my_start_count});
    $self->assert(1 == $self->{_my_end_count});
}

1;
